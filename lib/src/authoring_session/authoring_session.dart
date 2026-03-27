import 'dart:convert';

import 'package:carp_backend/carp_backend.dart';
import 'package:carp_core/carp_core.dart';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:carp_serializable/carp_serializable.dart';

import '../authoring_requirements.dart';

part 'services.dart';
part 'primary_device.dart';
part 'participants.dart';

class AuthoringSession {
  static const String startedState = 'protocolStarted';

  final AuthoringRequirements _authoringRequirements = AuthoringRequirements();

  SmartphoneStudyProtocol? protocol;

  PrimaryDeviceConfiguration? primaryDeviceConfiguration;

  final _inputDataTypesMap = {
    "sex": SexInput.type,
    "phone_number": PhoneNumberInput.type,
    "ssn": SocialSecurityNumberInput.type,
    "full_name": FullNameInput.type,
    "informed_consent": InformedConsentInput.type,
    "address": AddressInput.type,
    "diagnosis": DiagnosisInput.type,
    "custom": CustomInput.type,
  };

  void newSmartphoneProtocol(
    String name,
    String? ownerId,
  ) {
    protocol = SmartphoneStudyProtocol(
      name: name,
      ownerId: ownerId ?? const Uuid().v1,
    );

    // add the localized description
    addDescription();
  }

  void addDescription() {
    if (protocol == null) {
      throw StateError('Cannot add description before protocol has started.');
    }
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
