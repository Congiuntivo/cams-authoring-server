import 'dart:convert';

import 'package:carp_backend/carp_backend.dart';
import 'package:carp_context_package/carp_context_package.dart';
import 'package:carp_core/carp_core.dart';
import 'package:carp_esense_package/esense.dart';
import 'package:carp_health_package/health_package.dart';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:carp_movesense_package/carp_movesense_package.dart';
import 'package:carp_movisens_package/carp_movisens_package.dart';
import 'package:carp_polar_package/carp_polar_package.dart';
import 'package:carp_serializable/carp_serializable.dart';
import 'package:carp_survey_package/survey.dart';
import 'package:health/health.dart';
import 'package:is_valid/is_valid.dart';

import '../authoring_requirements.dart';

part 'devices.dart';
part 'services.dart';
part 'primary_device.dart';
part 'participants.dart';
part 'tasks.dart';

class AuthoringSession {
  static const String startedState = 'protocolStarted';

  final AuthoringRequirements _authoringRequirements;

  SmartphoneStudyProtocol? smartphoneProtocol;
  StudyProtocol? defaultProtocol;

  bool isSmartphoneProtocol;

  StudyProtocol? get protocol =>
      isSmartphoneProtocol ? smartphoneProtocol : defaultProtocol;

  PrimaryDeviceConfiguration? primaryDeviceConfiguration;

  List<DeviceConfiguration> serviceConfigurations = [];
  List<DeviceConfiguration> deviceConfigurations = [];

  List<TaskConfiguration> taskConfigurations = [];

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

  final _appTaskTypes = [
    BackgroundSensingUserTask.SENSING_TYPE,
    SurveyUserTask.SURVEY_TYPE,
    SurveyUserTask.COGNITIVE_ASSESSMENT_TYPE,
    SurveyUserTask.AUDIO_TYPE,
    SurveyUserTask.VIDEO_TYPE,
    SurveyUserTask.IMAGE_TYPE,
    SurveyUserTask.INFORMED_CONSENT_TYPE,
  ];

  AuthoringSession(String protocolName, String? ownerId, bool isSmartphone)
      : _authoringRequirements = AuthoringRequirements(isSmartphone),
        isSmartphoneProtocol = isSmartphone {
    if (isSmartphone) {
      newSmartphoneProtocol(protocolName, ownerId);
    } else {
      newDefaultProtocol(protocolName, ownerId);
    }
  }

  void newSmartphoneProtocol(
    String name,
    String? ownerId,
  ) {
    smartphoneProtocol = SmartphoneStudyProtocol(
      name: name,
      ownerId: ownerId ?? const Uuid().v1,
    ); // TODO: Add support for `privacySchemaName`

    isSmartphoneProtocol = true;
    assert(defaultProtocol == null,
        'Default protocol should be null when starting a smartphone protocol');

    // add the localized description
    _addDescription();
  }

  void newDefaultProtocol(String name, String? ownerId) {
    defaultProtocol = StudyProtocol(
      name: name,
      ownerId: ownerId ?? const Uuid().v1,
      description: 'study.description.description',
    );

    isSmartphoneProtocol = false;
    assert(smartphoneProtocol == null,
        'Smartphone protocol should be null when starting a default protocol');
  }

  void _addDescription() {
    if (smartphoneProtocol == null) {
      throw StateError('Cannot add description before protocol has started.');
    }
    smartphoneProtocol!.studyDescription = StudyDescription(
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
    if (!isSmartphoneProtocol) {
      throw StateError(
          'Data endpoints can only be added to smartphone protocols');
    }
    switch (endPointType) {
      // TODO: There are more endpoint types!!!!
      case DataEndPointTypes.CAWS:
        if (name == null) {
          throw ArgumentError('Name is required for CAWS endpoint');
        }
        if (uploadMethod == null) {
          throw ArgumentError('Upload method is required for CAWS endpoint');
        }
        smartphoneProtocol!.dataEndPoint = CarpDataEndPoint(
          uploadMethod: uploadMethod,
          name: name,
          deleteWhenUploaded: deleteWhenUploaded ?? false,
        );
        break;
      case DataEndPointTypes.SQLITE:
        smartphoneProtocol!.dataEndPoint = SQLiteDataEndPoint();
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
    if (!_authoringRequirements.checkCritical().allFulfilled) {
      throw AuthoringRequirementsException(
          _authoringRequirements.checkCritical().unfulfilled.join(', '));
    }

    var warnings = _authoringRequirements.check();

    if (protocol == null) {
      throw StateError('No protocol to serialize');
    }
    // return jsonDecode(toJsonString(protocol));
    if (!warnings.allFulfilled) {
      return {
        'protocol': jsonDecode(toJsonString(protocol)),
        'warnings': warnings.unfulfilled,
      };
    } else {
      return {'protocol': jsonDecode(toJsonString(protocol))};
    }
  }
}
