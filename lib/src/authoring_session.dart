import 'dart:convert';

import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:carp_serializable/carp_serializable.dart';
import 'package:carp_backend/carp_backend.dart';

import 'authoring_session_fsm.dart';

class AuthoringSession {
  static const String startedState = 'protocolStarted';

  final AuthoringSessionWorkflow _workflow = AuthoringSessionWorkflow();

  SmartphoneStudyProtocol? protocol;

  void newProtocol(
    String name,
    String? ownerId,
  ) {
    _workflow.startProtocol();

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
    _workflow.addDataEndPoint();

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
  }

  Map<String, dynamic> toStateJson() => <String, dynamic>{
        'state': _workflow.stateName,
      };

  Map<String, dynamic> serialize() {
    _workflow.requestSerialization();

    if (protocol == null) {
      throw StateError('No protocol to serialize');
    }
    return jsonDecode(toJsonString(protocol));
  }
}
