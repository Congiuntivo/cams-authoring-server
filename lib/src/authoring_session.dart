import 'dart:convert';

import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:carp_serializable/carp_serializable.dart';
import 'package:carp_backend/carp_backend.dart';
import 'package:carp_core/carp_core.dart';

import 'authoring_requirements.dart';

class AuthoringSession {
  static const String startedState = 'protocolStarted';

  final AuthoringRequirements _authoringRequirements = AuthoringRequirements();

  SmartphoneStudyProtocol? protocol;

  void newProtocol(
    String name,
    String? ownerId,
  ) {
    protocol = SmartphoneStudyProtocol(
      name: name,
      ownerId: ownerId ?? const Uuid().v1,
    );

    // add the localized description
    protocol!.studyDescription = StudyDescription(
        title: 'study.description.title',
        description: 'study.description.description',
        purpose: 'study.description.purpose',
        studyDescriptionUrl: 'study.description.url',
        privacyPolicyUrl: 'study.description.privacy',
        responsible: StudyResponsible(
          id: 'study.responsible.id',
          title: 'study.responsible.title',
          address: 'study.responsible.address',
          affiliation: 'study.responsible.affiliation',
          email: 'study.responsible.email',
          name: 'study.responsible.name',
        ));
  }

  void addDataEndPoint(String endPointType, CarpUploadMethod? uploadMethod,
      String? name, bool? deleteWhenUploaded) {
    switch (endPointType) {
      case DataEndPointTypes.CAWS:
        if (name == null) {
          throw ArgumentError('Name is required for CAWS endpoint');
        }
        if (uploadMethod == null) {
          throw ArgumentError('Upload method is required for CAWS endpoint');
        }
        protocol!.dataEndPoint = CarpDataEndPoint(
          uploadMethod: uploadMethod,
          name: name,
          deleteWhenUploaded: deleteWhenUploaded ?? false,
        );
        break;
      case DataEndPointTypes.SQLITE:
        protocol!.dataEndPoint = SQLiteDataEndPoint();
      default:
        throw ArgumentError('Unsupported endpoint type: $endPointType');
    }

    _authoringRequirements.dataEndPoint.isFulfilled = true;
  }

  void addPrimaryDevice(String deviceType, String? roleName) {
    switch (deviceType) {
      case "smartphone":
        final phone =
            roleName == null ? Smartphone() : Smartphone(roleName: roleName);
        protocol!.addPrimaryDevice(phone);
        break;
      case "browser":
        final browser =
            roleName == null ? WebBrowser() : WebBrowser(roleName: roleName);
        protocol!.addPrimaryDevice(browser);
        break;
      default:
        throw ArgumentError('Unsupported device type: $deviceType');
    }

    _authoringRequirements.primaryDevice.isFulfilled = true;
  }

  Map<String, dynamic> toRequirementsJson() => <String, dynamic>{
        'unfulfilledRequirements': {
          'warnings': _authoringRequirements.unfulfilledWarnings,
          'critical': _authoringRequirements.unfulfilledCritical,
        }
      };

  Map<String, dynamic> serialize() {
    if (!_authoringRequirements.checkCritical().item1) {
      throw AuthoringRequirementsException(
          _authoringRequirements.checkCritical().item2.join(', '));
    }

    var warnings = _authoringRequirements.check();

    if (protocol == null) {
      throw StateError('No protocol to serialize');
    }
    // return jsonDecode(toJsonString(protocol));
    if (!warnings.item1) {
      return {
        'protocol': jsonDecode(toJsonString(protocol)),
        'warnings': warnings.item2,
      };
    } else {
      return {'protocol': jsonDecode(toJsonString(protocol))};
    }
  }
}
