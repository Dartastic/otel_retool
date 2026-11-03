// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_retool/otel_retool.dart';

/// Traces Retool calls with OpenTelemetry.
///
/// `otel_retool` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Retool call in
/// [tracedRetool]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'retool-example');

  // Wraps a Retool API call in a CLIENT span.
  final retoolId = await tracedRetool<String>(
    operation: 'queries.run',
    invoke: () async {
      // Make the Retool call here, then report what it returned.
      const id = 'retool_8f3a2c';
      return const RetoolCallResult(
          value: id,
          result: RetoolResult(
              organizationId: 'organization_8f3a2c',
              spaceId: 'space_8f3a2c',
              appId: 'app_8f3a2c',
              appName: 'example',
              queryId: 'query_8f3a2c',
              queryName: 'example',
              queryResource: 'postgres-prod',
              workflowId: 'workflow_8f3a2c',
              workflowRunId: 'workflowrun_8f3a2c',
              workflowStatus: 'success',
              permissionGroup: 'example',
              environment: 'production',
              deployedVersion: '1',
              rowsReturned: 1,
              executionMs: 120,
              usedAiAction: true,
              statusCode: 200));
    },
  );
  OTelLog.info('tracedRetool queries.run returned $retoolId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutRetoolInstrumentationAsync.
  await runWithoutRetoolInstrumentationAsync(
    () => tracedRetool<String>(
      operation: 'queries.run',
      invoke: () async {
        const id = 'retool_8f3a2c';
        return const RetoolCallResult(
            value: id,
            result: RetoolResult(
                organizationId: 'organization_8f3a2c',
                spaceId: 'space_8f3a2c',
                appId: 'app_8f3a2c',
                appName: 'example',
                queryId: 'query_8f3a2c',
                queryName: 'example',
                queryResource: 'postgres-prod',
                workflowId: 'workflow_8f3a2c',
                workflowRunId: 'workflowrun_8f3a2c',
                workflowStatus: 'success',
                permissionGroup: 'example',
                environment: 'production',
                deployedVersion: '1',
                rowsReturned: 1,
                executionMs: 120,
                usedAiAction: true,
                statusCode: 200));
      },
    ),
  );

  await OTel.shutdown();
}
