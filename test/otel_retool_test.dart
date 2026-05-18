// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_retool/otel_retool.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_retool-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('queries.run records app + resource + rows', () async {
    await tracedRetool<String>(
      operation: 'queries.run',
      invoke: () async => const RetoolCallResult(
        value: 'ok',
        result: RetoolResult(
          organizationId: 'org_1',
          appId: 'app_1',
          appName: 'order-ops',
          queryId: 'q_1',
          queryName: 'find_recent_orders',
          queryResource: 'postgres-prod',
          environment: 'production',
          permissionGroup: 'support',
          rowsReturned: 120,
          executionMs: 380,
          statusCode: 200,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('retool queries.run')!);
    expect(a['retool.app.name'], 'order-ops');
    expect(a['retool.query.resource'], 'postgres-prod');
    expect(a['retool.environment'], 'production');
    expect(a['retool.permission.group'], 'support');
    expect(a['retool.query.rows_returned'], 120);
  });

  test('workflow error sets span error', () async {
    await tracedRetool<String>(
      operation: 'workflows.trigger',
      invoke: () async => const RetoolCallResult(
        value: 'ok',
        result: RetoolResult(
          workflowId: 'wf_1',
          workflowRunId: 'wfr_1',
          workflowStatus: 'error',
          usedAiAction: true,
        ),
      ),
    );
    final s = spans.findSpanByName('retool workflows.trigger')!;
    expect(s.status, SpanStatusCode.Error);
    expect(attrsOf(s)['retool.ai_action.used'], true);
  });

  test('suppression skips spans', () async {
    await runWithoutRetoolInstrumentationAsync(() async {
      await tracedRetool<String>(
        operation: 'apps.list',
        invoke: () async => const RetoolCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('retool '), isEmpty);
  });
}
