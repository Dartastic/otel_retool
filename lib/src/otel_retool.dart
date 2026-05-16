// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_retool_suppression.dart';

const _tracerName = 'dartastic_otel_libs_retool';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class RetoolResult {
  const RetoolResult({
    this.organizationId,
    this.spaceId,
    this.appId,
    this.appName,
    this.queryId,
    this.queryName,
    this.queryResource,
    this.workflowId,
    this.workflowRunId,
    this.workflowStatus,
    this.permissionGroup,
    this.environment,
    this.deployedVersion,
    this.rowsReturned,
    this.executionMs,
    this.usedAiAction,
    this.statusCode,
  });

  /// Retool organization (tenant).
  final String? organizationId;

  /// Retool space (sub-tenant grouping under organization).
  final String? spaceId;

  final String? appId;
  final String? appName;

  final String? queryId;
  final String? queryName;

  /// The resource the query runs against (`postgres-prod` /
  /// `salesforce-rest` / `s3-uploads` / `rest_api_users` / etc.).
  final String? queryResource;

  /// Retool Workflows id (the headless flow product).
  final String? workflowId;

  final String? workflowRunId;

  /// `success` / `error` / `running` / `cancelled` / `timeout`.
  final String? workflowStatus;

  /// Permission group / role used when authorizing this request
  /// (helpful for audit traces).
  final String? permissionGroup;

  /// `production` / `staging` / `development` — Retool resource
  /// environment.
  final String? environment;

  /// Deployed version (Retool versions every save in source-controlled
  /// orgs).
  final String? deployedVersion;

  /// Rows returned from a query.
  final int? rowsReturned;

  final int? executionMs;

  /// `true` if Retool's AI Action ran (LLM step inside a workflow or
  /// app event).
  final bool? usedAiAction;

  final int? statusCode;
}

class RetoolCallResult<T> {
  const RetoolCallResult({required this.value, this.result});
  final T value;
  final RetoolResult? result;
}

/// Wraps a Retool API call in a CLIENT span. [operation] is one of
/// `apps.list`, `apps.export`, `apps.import`, `queries.run`,
/// `workflows.list`, `workflows.trigger`, `workflows.runs.get`,
/// `workflows.runs.list`, `users.list`, `groups.list`,
/// `resources.list`, `audit.events`.
Future<T> tracedRetool<T>({
  required String operation,
  required Future<RetoolCallResult<T>> Function() invoke,
}) async {
  if (retoolInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'retool',
    'rpc.method': operation,
    'retool.operation': operation,
  };

  final span = _tracer().startSpan(
    'retool $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final extras = <Attribute<Object>>[];
      if (r.result!.organizationId != null) {
        extras.add(OTel.attributeString(
          'retool.organization.id',
          r.result!.organizationId!,
        ));
      }
      if (r.result!.spaceId != null) {
        extras.add(OTel.attributeString(
          'retool.space.id',
          r.result!.spaceId!,
        ));
      }
      if (r.result!.appId != null) {
        extras.add(OTel.attributeString(
          'retool.app.id',
          r.result!.appId!,
        ));
      }
      if (r.result!.appName != null) {
        extras.add(OTel.attributeString(
          'retool.app.name',
          r.result!.appName!,
        ));
      }
      if (r.result!.queryId != null) {
        extras.add(OTel.attributeString(
          'retool.query.id',
          r.result!.queryId!,
        ));
      }
      if (r.result!.queryName != null) {
        extras.add(OTel.attributeString(
          'retool.query.name',
          r.result!.queryName!,
        ));
      }
      if (r.result!.queryResource != null) {
        extras.add(OTel.attributeString(
          'retool.query.resource',
          r.result!.queryResource!,
        ));
      }
      if (r.result!.workflowId != null) {
        extras.add(OTel.attributeString(
          'retool.workflow.id',
          r.result!.workflowId!,
        ));
      }
      if (r.result!.workflowRunId != null) {
        extras.add(OTel.attributeString(
          'retool.workflow_run.id',
          r.result!.workflowRunId!,
        ));
      }
      if (r.result!.workflowStatus != null) {
        extras.add(OTel.attributeString(
          'retool.workflow.status',
          r.result!.workflowStatus!,
        ));
        if (r.result!.workflowStatus == 'error' ||
            r.result!.workflowStatus == 'timeout') {
          span.setStatus(
            SpanStatusCode.Error,
            'Retool workflow ${r.result!.workflowStatus}',
          );
        }
      }
      if (r.result!.permissionGroup != null) {
        extras.add(OTel.attributeString(
          'retool.permission.group',
          r.result!.permissionGroup!,
        ));
      }
      if (r.result!.environment != null) {
        extras.add(OTel.attributeString(
          'retool.environment',
          r.result!.environment!,
        ));
      }
      if (r.result!.deployedVersion != null) {
        extras.add(OTel.attributeString(
          'retool.deployed.version',
          r.result!.deployedVersion!,
        ));
      }
      if (r.result!.rowsReturned != null) {
        extras.add(OTel.attributeInt(
          'retool.query.rows_returned',
          r.result!.rowsReturned!,
        ));
      }
      if (r.result!.executionMs != null) {
        extras.add(OTel.attributeInt(
          'retool.execution_ms',
          r.result!.executionMs!,
        ));
      }
      if (r.result!.usedAiAction != null) {
        extras.add(OTel.attributeBool(
          'retool.ai_action.used',
          r.result!.usedAiAction!,
        ));
      }
      if (r.result!.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          r.result!.statusCode!,
        ));
        if (r.result!.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Retool HTTP ${r.result!.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
