import '../request_parsing_utils.dart';

class CreateProtocolRequest {
  const CreateProtocolRequest({
    required this.name,
    this.ownerId,
    this.protocolVersionTag,
    this.protocolApiLevel,
    this.applicationName,
    this.privacySchemaName,
  });

  final String name;
  final String? ownerId;
  final String? protocolVersionTag;
  final String? protocolApiLevel;
  final String? applicationName;
  final String? privacySchemaName;

  factory CreateProtocolRequest.fromJson(Map<String, dynamic> json) {
    const context = 'create protocol request body';

    ensureNoUnknownFields(
      json,
      const <String>{
        'name',
        'ownerId',
        'protocolVersionTag',
        'protocolApiLevel',
        'applicationName',
        'privacySchemaName',
      },
      context,
    );

    return CreateProtocolRequest(
      name: requireNonBlankString(
        json,
        'name',
        context: context,
      ),
      ownerId: parseOptionalString(
        json['ownerId'],
        'ownerId',
        context: context,
      ),
      protocolVersionTag: parseOptionalString(
        json['protocolVersionTag'],
        'protocolVersionTag',
        context: context,
      ),
      protocolApiLevel: parseOptionalString(
        json['protocolApiLevel'],
        'protocolApiLevel',
        context: context,
      ),
      applicationName: parseOptionalString(
        json['applicationName'],
        'applicationName',
        context: context,
      ),
      privacySchemaName: parseOptionalString(
        json['privacySchemaName'],
        'privacySchemaName',
        context: context,
      ),
    );
  }
}

class PrimaryDeviceRoleRequest {
  const PrimaryDeviceRoleRequest({
    this.roleName,
  });

  final String? roleName;

  factory PrimaryDeviceRoleRequest.fromJson(Map<String, dynamic> json) {
    const context = 'primary device request body';

    ensureNoUnknownFields(
      json,
      const <String>{'roleName'},
      context,
    );

    return PrimaryDeviceRoleRequest(
      roleName: parseOptionalString(
        json['roleName'],
        'roleName',
        context: context,
      ),
    );
  }
}

class DataEndpointRequest {
  const DataEndpointRequest({
    required this.endpointType,
    this.uploadMethod,
    this.name,
    this.deleteWhenUploaded,
    this.bufferSize,
    this.zip,
    this.encrypt,
    this.publicKey,
  });

  final String endpointType;
  final String? uploadMethod;
  final String? name;
  final bool? deleteWhenUploaded;
  final int? bufferSize;
  final bool? zip;
  final bool? encrypt;
  final String? publicKey;

  factory DataEndpointRequest.fromJson(Map<String, dynamic> json) {
    const context = 'data endpoint request body';

    ensureNoUnknownFields(
      json,
      const <String>{
        'endpointType',
        'uploadMethod',
        'name',
        'deleteWhenUploaded',
        'bufferSize',
        'zip',
        'encrypt',
        'publicKey',
      },
      context,
    );

    return DataEndpointRequest(
      endpointType: parseOptionalString(
            json['endpointType'],
            'endpointType',
            context: context,
          ) ??
          '',
      uploadMethod: parseOptionalString(
        json['uploadMethod'],
        'uploadMethod',
        context: context,
      ),
      name: parseOptionalString(
        json['name'],
        'name',
        context: context,
      ),
      deleteWhenUploaded: parseOptionalBool(
        json['deleteWhenUploaded'],
        'deleteWhenUploaded',
        context: context,
      ),
      bufferSize: parseOptionalInt(
        json['bufferSize'],
        'bufferSize',
        context: context,
      ),
      zip: parseOptionalBool(
        json['zip'],
        'zip',
        context: context,
      ),
      encrypt: parseOptionalBool(
        json['encrypt'],
        'encrypt',
        context: context,
      ),
      publicKey: parseOptionalString(
        json['publicKey'],
        'publicKey',
        context: context,
      ),
    );
  }
}
