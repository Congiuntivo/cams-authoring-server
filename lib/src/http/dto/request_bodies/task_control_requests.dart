import '../request_parsing_utils.dart';

class TaskControlRequest {
  const TaskControlRequest({
    required this.taskName,
    required this.triggerName,
    required this.deviceRoleName,
  });

  final String taskName;
  final String triggerName;
  final String deviceRoleName;

  factory TaskControlRequest.fromJson(Map<String, dynamic> json) {
    const context = 'task control request body';

    ensureNoUnknownFields(
      json,
      const <String>{'taskName', 'triggerName', 'deviceRoleName'},
      context,
    );

    return TaskControlRequest(
      taskName: requireNonBlankString(
        json,
        'taskName',
        context: context,
      ),
      triggerName: requireNonBlankString(
        json,
        'triggerName',
        context: context,
      ),
      deviceRoleName: requireNonBlankString(
        json,
        'deviceRoleName',
        context: context,
      ),
    );
  }
}
