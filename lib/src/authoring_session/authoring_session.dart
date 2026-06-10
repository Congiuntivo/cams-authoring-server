import 'package:carp_backend/carp_backend.dart';
import 'package:carp_context_package/carp_context_package.dart';
import 'package:carp_core/carp_core.dart' hide Smartphone;
import 'package:carp_esense_package/esense.dart';
import 'package:carp_health_package/health_package.dart';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:carp_movesense_package/carp_movesense_package.dart';
import 'package:carp_movisens_package/carp_movisens_package.dart';
import 'package:carp_polar_package/carp_polar_package.dart';
import 'package:carp_serializable/carp_serializable.dart';
import 'package:health/health.dart';
import 'package:is_valid/is_valid.dart';

import 'utils/authoring_requirements.dart';
import 'utils/authoring_session_state.dart';
import 'utils/in_memory_authoring_session_state.dart';

part 'devices.dart';
part 'services.dart';
part 'primary_device.dart';
part 'participants.dart';
part 'tasks.dart';
part 'task_controls.dart';
part 'triggers.dart';

class AuthoringSession {
  final AuthoringRequirements _authoringRequirements;
  final AuthoringSessionState _state;

  SmartphoneStudyProtocol get protocol => _state.protocol;

  static const Map<String, String> inputDataTypesMap = {
    "sex": InputType.SEX,
    "phone_number": InputType.PHONE_NUMBER,
    "ssn": InputType.SSN,
    "full_name": InputType.FULL_NAME,
    "informed_consent": InputType.INFORMED_CONSENT,
    "address": InputType.ADDRESS,
    "diagnosis": InputType.DIAGNOSIS,
    "note": InputType.NOTE,
    "educational_degree": InputType.EDUCATIONAL_DEGREE,
    "onboarding_researcher": InputType.ONBOARDING_RESEARCHER,
    "language": InputType.LANGUAGE,
    "occupation": InputType.OCCUPATION,
  };

  final _appTaskTypes = [
    // BackgroundSensingUse  /// A background sensing user task which can be started and stopped by the user.
    'sensing',

    /// A survey app task. Used in the carp_survey_package for `RPAppTask`s.
    'survey',

    /// A cognitive assessment app task. Used in the carp_survey_package for `RPAppTask`s.
    'cognition',

    /// An audio app task. Used in the carp_audio_package.
    'audio',

    /// A video app task. Used in the carp_audio_package.
    'video',

    /// An image app task. Used in the carp_audio_package.
    'image',

    /// An informed consent app task.
    'informed_consent',

    /// An app task collecting health data. Used in the carp_health_package.
    'health',
  ];

  AuthoringSession(
    String protocolName,
    String? ownerId, {
    String? protocolVersionTag,
    String? applicationName,
    String? privacySchemaName,
    AuthoringSessionState? state,
  })  : _authoringRequirements = AuthoringRequirements(),
        _state = state ?? InMemoryAuthoringSessionState() {
    _newSmartphoneProtocol(
      protocolName,
      ownerId,
      protocolVersionTag: protocolVersionTag,
      applicationName: applicationName,
      privacySchemaName: privacySchemaName,
    );
  }

  void _newSmartphoneProtocol(
    String name,
    String? ownerId, {
    String? protocolVersionTag,
    String? applicationName,
    String? privacySchemaName,
  }) {
    final protocol = SmartphoneStudyProtocol(
      name: name,
      ownerId: ownerId ?? const Uuid().v1,
    );

    protocol.privacySchemaName = privacySchemaName;
    _setSmartphoneProtocolMetadata(
      protocol,
      protocolVersionTag: protocolVersionTag,
      applicationName: applicationName,
    );

    // add the localized description
    _addDescription(protocol);
    _state.initProtocol(protocol);
  }

  void _setSmartphoneProtocolMetadata(
    SmartphoneStudyProtocol protocol, {
    String? protocolVersionTag,
    String? applicationName,
  }) {
    final applicationData = Map<String, dynamic>.from(
      protocol.applicationData ?? <String, dynamic>{},
    );

    if (protocolVersionTag != null) {
      applicationData['protocolVersionTag'] = protocolVersionTag;
    }
    if (applicationName != null) {
      applicationData['applicationName'] = applicationName;
    }

    protocol.applicationData = applicationData;
  }

  void setApplicationData(Map<String, dynamic> data) {
    final existing = _state.protocol.applicationData?['applicationData'];
    if (existing is Map<String, dynamic>) {
      for (final key in existing.keys.toList()) {
        _state.protocol.removeApplicationData(key);
      }
    }
    for (final entry in data.entries) {
      _state.protocol.addApplicationData(entry.key, entry.value);
    }
  }

  void _addDescription(SmartphoneStudyProtocol protocol) {
    protocol.studyDescription = StudyDescription(
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

  void addDataEndPoint(
    String endPointType,
    CarpUploadMethod? uploadMethod,
    String? name,
    bool? deleteWhenUploaded, {
    int? bufferSize,
    bool? zip,
    bool? encrypt,
    String? publicKey,
  }) {
    switch (endPointType) {
      case DataEndPointTypes.CAWS:
        if (name == null) {
          throw ArgumentError('Name is required for CAWS endpoint');
        }
        if (uploadMethod == null) {
          throw ArgumentError('Upload method is required for CAWS endpoint');
        }
        protocol.dataEndPoint = CarpDataEndPoint(
          uploadMethod: uploadMethod,
          name: name,
          deleteWhenUploaded: deleteWhenUploaded ?? false,
        );
        break;
      case DataEndPointTypes.SQLITE:
        protocol.dataEndPoint = SQLiteDataEndPoint();
        break;
      case DataEndPointTypes.FILE:
        if ((encrypt ?? false) &&
            (publicKey == null || publicKey.trim().isEmpty)) {
          throw ArgumentError(
              'publicKey is required when encrypt is true for FILE endpoint');
        }

        final fileEndPoint = FileDataEndPoint();
        if (bufferSize != null) fileEndPoint.bufferSize = bufferSize;
        if (zip != null) fileEndPoint.zip = zip;
        if (encrypt != null) fileEndPoint.encrypt = encrypt;
        if (publicKey != null && publicKey.trim().isNotEmpty) {
          fileEndPoint.publicKey = publicKey.trim();
        }

        protocol.dataEndPoint = fileEndPoint;
        break;
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

    final warnings = _authoringRequirements.check();

    if (!warnings.allFulfilled) {
      return {
        'protocol': protocol.toJson(),
        'warnings': warnings.unfulfilled,
      };
    } else {
      return {'protocol': protocol.toJson()};
    }
  }
}
