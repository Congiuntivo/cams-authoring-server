import 'package:flutter_test/flutter_test.dart';

import 'package:study_protocol_authoring_server/src/authoring_service/authoring_service.dart';

void main() {
  test('task usage warning is added on task creation and removed on control',
      () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S1T',
    );

    final sessionId =
        service.createNewProtocol('Protocol', 'owner')['sessionId'] as String;
    service.addSmartphonePrimaryDevice(sessionId, 'User Phone');
    service.addESenseDevice(sessionId, 'Left Earbud', 'User Phone', false, 20);

    const taskName = 'daily_context_collection';
    final expectedWarning =
        'Task "$taskName" must be used by at least one task control.';

    final addTaskState = service.addBackgroundTask(
      sessionId,
      taskName,
      'Collect context snapshots during the day.',
      const [],
      null,
    );

    expect(
      addTaskState['unfulfilledRequirements']['warnings'],
      contains(expectedWarning),
    );

    service.addImmediateTrigger(sessionId, 'start_now');
    final addTaskControlState = service.addTaskControl(
      sessionId,
      taskName,
      'start_now',
      'Left Earbud',
    );

    expect(
      addTaskControlState['unfulfilledRequirements']['warnings'],
      isNot(contains(expectedWarning)),
    );
  });

  test('task usage warnings are tracked independently per task', () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S1M',
    );

    final sessionId =
        service.createNewProtocol('Protocol', 'owner')['sessionId'] as String;
    service.addSmartphonePrimaryDevice(sessionId, 'User Phone');
    service.addESenseDevice(sessionId, 'Left Earbud', 'User Phone', false, 20);

    const taskA = 'daily_context_collection';
    const taskB = 'daily_survey';
    final warningA = 'Task "$taskA" must be used by at least one task control.';
    final warningB = 'Task "$taskB" must be used by at least one task control.';

    service.addBackgroundTask(
      sessionId,
      taskA,
      'Collect context snapshots during the day.',
      const [],
      null,
    );
    final addSecondTaskState = service.addBackgroundTask(
      sessionId,
      taskB,
      'Collect survey context.',
      const [],
      null,
    );

    expect(
      addSecondTaskState['unfulfilledRequirements']['warnings'],
      contains(warningA),
    );
    expect(
      addSecondTaskState['unfulfilledRequirements']['warnings'],
      contains(warningB),
    );

    service.addImmediateTrigger(sessionId, 'start_now');
    final addTaskControlState = service.addTaskControl(
      sessionId,
      taskA,
      'start_now',
      'Left Earbud',
    );

    expect(
      addTaskControlState['unfulfilledRequirements']['warnings'],
      isNot(contains(warningA)),
    );
    expect(
      addTaskControlState['unfulfilledRequirements']['warnings'],
      contains(warningB),
    );
  });

  test(
      'trigger usage warning is added on trigger creation and removed on control',
      () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S1TR',
    );

    final sessionId =
        service.createNewProtocol('Protocol', 'owner')['sessionId'] as String;
    service.addSmartphonePrimaryDevice(sessionId, 'User Phone');
    service.addESenseDevice(sessionId, 'Left Earbud', 'User Phone', false, 20);

    const taskName = 'daily_context_collection';
    const triggerName = 'start_now';
    final triggerWarning =
        'Trigger "$triggerName" must be used by at least one task control.';

    service.addBackgroundTask(
      sessionId,
      taskName,
      'Collect context snapshots during the day.',
      const [],
      null,
    );

    final addTriggerState = service.addImmediateTrigger(sessionId, triggerName);
    expect(
      addTriggerState['unfulfilledRequirements']['warnings'],
      contains(triggerWarning),
    );

    final addTaskControlState = service.addTaskControl(
      sessionId,
      taskName,
      triggerName,
      'Left Earbud',
    );
    expect(
      addTaskControlState['unfulfilledRequirements']['warnings'],
      isNot(contains(triggerWarning)),
    );
  });

  test(
      'device usage warning is added on device creation and removed on control',
      () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S1DV',
    );

    final sessionId =
        service.createNewProtocol('Protocol', 'owner')['sessionId'] as String;
    service.addSmartphonePrimaryDevice(sessionId, 'User Phone');

    const taskName = 'daily_context_collection';
    const triggerName = 'start_now';
    const deviceRoleName = 'Left Earbud';
    final deviceWarning =
        'Device "$deviceRoleName" must be used by at least one task control.';

    service.addBackgroundTask(
      sessionId,
      taskName,
      'Collect context snapshots during the day.',
      const [],
      null,
    );
    service.addImmediateTrigger(sessionId, triggerName);

    final addDeviceState = service.addESenseDevice(
        sessionId, deviceRoleName, 'User Phone', false, 20);
    expect(
      addDeviceState['unfulfilledRequirements']['warnings'],
      contains(deviceWarning),
    );

    final addTaskControlState = service.addTaskControl(
      sessionId,
      taskName,
      triggerName,
      deviceRoleName,
    );
    expect(
      addTaskControlState['unfulfilledRequirements']['warnings'],
      isNot(contains(deviceWarning)),
    );
  });

  test(
      'service usage warning is added on service creation and removed on control',
      () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S1SV',
    );

    final sessionId =
        service.createNewProtocol('Protocol', 'owner')['sessionId'] as String;
    service.addSmartphonePrimaryDevice(sessionId, 'User Phone');

    const taskName = 'daily_context_collection';
    const triggerName = 'start_now';
    const serviceRoleName = 'Local Weather';
    final serviceWarning =
        'Service "$serviceRoleName" must be used by at least one task control.';

    service.addBackgroundTask(
      sessionId,
      taskName,
      'Collect context snapshots during the day.',
      const [],
      null,
    );
    service.addImmediateTrigger(sessionId, triggerName);

    final addServiceState =
        service.addWeatherService(sessionId, serviceRoleName, 'User Phone');
    expect(
      addServiceState['unfulfilledRequirements']['warnings'],
      contains(serviceWarning),
    );

    final addTaskControlState = service.addTaskControl(
      sessionId,
      taskName,
      triggerName,
      serviceRoleName,
    );
    expect(
      addTaskControlState['unfulfilledRequirements']['warnings'],
      isNot(contains(serviceWarning)),
    );
  });

  test('addTaskControl throws when device role name is unknown', () {
    final service = ProtocolAuthoringService(
      sessionIdGenerator: () => 'S1UNK',
    );

    final sessionId =
        service.createNewProtocol('Protocol', 'owner')['sessionId'] as String;
    service.addSmartphonePrimaryDevice(sessionId, 'User Phone');

    const taskName = 'daily_context_collection';
    const triggerName = 'start_now';
    const unknownDeviceRole = 'Missing Device';

    service.addBackgroundTask(
      sessionId,
      taskName,
      'Collect context snapshots during the day.',
      const [],
      null,
    );
    service.addImmediateTrigger(sessionId, triggerName);

    expect(
      () => service.addTaskControl(
        sessionId,
        taskName,
        triggerName,
        unknownDeviceRole,
      ),
      throwsA(
        isA<ArgumentError>().having(
          (error) => error.message,
          'message',
          contains('Device role "$unknownDeviceRole" is not defined'),
        ),
      ),
    );
  });
}
