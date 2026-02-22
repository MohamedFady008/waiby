import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

Future<void> main(List<String> args) async {
  final config = MigrationConfig.fromArgs(args);
  final migrator = SupabaseToFirestoreMigrator(config);
  final report = await migrator.run();

  final reportFile = File(
    'migration_report_${DateTime.now().toUtc().toIso8601String().replaceAll(':', '-')}.json',
  );
  await reportFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(report.toJson()),
  );

  stdout.writeln('\nMigration finished.');
  stdout.writeln('Report saved to: ${reportFile.path}');
}

class MigrationConfig {
  MigrationConfig({
    required this.supabaseUrl,
    required this.supabaseServiceRoleKey,
    required this.firebaseProjectId,
    required this.firebaseServiceAccountPath,
    required this.tables,
    required this.tableToCollectionMap,
    required this.schema,
    required this.fetchBatchSize,
    required this.writeBatchSize,
    required this.dryRun,
  });

  final String supabaseUrl;
  final String supabaseServiceRoleKey;
  final String firebaseProjectId;
  final String firebaseServiceAccountPath;
  final List<String> tables;
  final Map<String, String> tableToCollectionMap;
  final String schema;
  final int fetchBatchSize;
  final int writeBatchSize;
  final bool dryRun;

  static MigrationConfig fromArgs(List<String> args) {
    final options = <String, String>{};
    final flags = <String>{};

    for (final arg in args) {
      if (!arg.startsWith('--')) {
        continue;
      }

      final value = arg.substring(2);
      final separator = value.indexOf('=');
      if (separator == -1) {
        flags.add(value.trim());
      } else {
        final key = value.substring(0, separator).trim();
        final rawValue = value.substring(separator + 1).trim();
        options[key] = rawValue;
      }
    }

    String readOption(String key, String envKey, {String fallback = ''}) {
      final fromArgs = options[key];
      if (fromArgs != null && fromArgs.isNotEmpty) {
        return fromArgs;
      }
      final fromEnv = Platform.environment[envKey];
      if (fromEnv != null && fromEnv.isNotEmpty) {
        return fromEnv;
      }
      return fallback;
    }

    List<String> readCsvList(String key, String envKey) {
      final raw = readOption(key, envKey);
      return raw
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(growable: false);
    }

    Map<String, String> parseTableMapping(String mapping) {
      final result = <String, String>{};
      if (mapping.trim().isEmpty) {
        return result;
      }

      final pairs = mapping.split(',');
      for (final pair in pairs) {
        final clean = pair.trim();
        if (clean.isEmpty) continue;
        final separator = clean.indexOf(':');
        if (separator == -1) {
          throw ArgumentError(
            'Invalid --table-map entry "$clean". Expected source:target.',
          );
        }
        final source = clean.substring(0, separator).trim();
        final target = clean.substring(separator + 1).trim();
        if (source.isEmpty || target.isEmpty) {
          throw ArgumentError(
            'Invalid --table-map entry "$clean". Source and target are required.',
          );
        }
        result[source] = target;
      }

      return result;
    }

    int parseInt(String key, String envKey, int defaultValue) {
      final raw = readOption(key, envKey, fallback: '$defaultValue');
      final parsed = int.tryParse(raw);
      if (parsed == null || parsed <= 0) {
        throw ArgumentError('Invalid $key value: "$raw". Must be positive.');
      }
      return parsed;
    }

    final supabaseUrl = readOption('supabase-url', 'SUPABASE_URL');
    final supabaseServiceRoleKey = readOption(
      'supabase-service-role-key',
      'SUPABASE_SERVICE_ROLE_KEY',
    );
    final firebaseProjectId = readOption('project-id', 'FIREBASE_PROJECT_ID');
    final firebaseServiceAccountPath = readOption(
      'firebase-service-account',
      'GOOGLE_APPLICATION_CREDENTIALS',
    );
    final tables = readCsvList('tables', 'SUPABASE_TABLES');
    final tableToCollectionMap = parseTableMapping(
      readOption('table-map', 'SUPABASE_TABLE_MAP'),
    );
    final schema = readOption('schema', 'SUPABASE_SCHEMA', fallback: 'public');
    final fetchBatchSize = parseInt(
      'fetch-batch-size',
      'FETCH_BATCH_SIZE',
      500,
    );
    final writeBatchSize = parseInt(
      'write-batch-size',
      'WRITE_BATCH_SIZE',
      200,
    );
    final dryRun = flags.contains('dry-run');

    final missing = <String>[];
    if (supabaseUrl.isEmpty) missing.add('--supabase-url or SUPABASE_URL');
    if (supabaseServiceRoleKey.isEmpty) {
      missing.add('--supabase-service-role-key or SUPABASE_SERVICE_ROLE_KEY');
    }
    if (firebaseProjectId.isEmpty) {
      missing.add('--project-id or FIREBASE_PROJECT_ID');
    }
    if (firebaseServiceAccountPath.isEmpty) {
      missing.add(
        '--firebase-service-account or GOOGLE_APPLICATION_CREDENTIALS',
      );
    }
    if (tables.isEmpty) {
      missing.add('--tables or SUPABASE_TABLES');
    }

    if (missing.isNotEmpty) {
      final message = [
        'Missing required configuration:',
        ...missing.map((item) => '  - $item'),
        '',
        'Example:',
        'dart run tool/migrate_supabase_to_firestore.dart '
            '--supabase-url=https://YOUR_PROJECT.supabase.co '
            '--supabase-service-role-key=YOUR_SERVICE_ROLE_KEY '
            '--project-id=your-firebase-project '
            '--firebase-service-account=./service-account.json '
            '--tables=profiles,orders '
            '--table-map=profiles:users,orders:orders',
      ].join('\n');
      throw ArgumentError(message);
    }

    return MigrationConfig(
      supabaseUrl: supabaseUrl,
      supabaseServiceRoleKey: supabaseServiceRoleKey,
      firebaseProjectId: firebaseProjectId,
      firebaseServiceAccountPath: firebaseServiceAccountPath,
      tables: tables,
      tableToCollectionMap: tableToCollectionMap,
      schema: schema,
      fetchBatchSize: fetchBatchSize,
      writeBatchSize: writeBatchSize,
      dryRun: dryRun,
    );
  }
}

class MigrationReport {
  MigrationReport({
    required this.startedAt,
    required this.finishedAt,
    required this.projectId,
    required this.dryRun,
    required this.tables,
  });

  final DateTime startedAt;
  final DateTime finishedAt;
  final String projectId;
  final bool dryRun;
  final List<TableMigrationResult> tables;

  bool get hasFailures => tables.any((table) => !table.integrityPassed);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'started_at': startedAt.toUtc().toIso8601String(),
      'finished_at': finishedAt.toUtc().toIso8601String(),
      'firebase_project_id': projectId,
      'dry_run': dryRun,
      'has_failures': hasFailures,
      'tables': tables.map((table) => table.toJson()).toList(),
    };
  }
}

class TableMigrationResult {
  TableMigrationResult({
    required this.sourceTable,
    required this.targetCollection,
    required this.sourceReportedCount,
    required this.sourceFetchedCount,
    required this.uniqueDocumentIds,
    required this.duplicateDocumentIdCount,
    required this.firestoreCountBefore,
    required this.firestoreCountAfter,
    required this.writeOperations,
    required this.writeErrors,
    required this.strictCountMatch,
    required this.integrityPassed,
    required this.notes,
  });

  final String sourceTable;
  final String targetCollection;
  final int sourceReportedCount;
  final int sourceFetchedCount;
  final int uniqueDocumentIds;
  final int duplicateDocumentIdCount;
  final int firestoreCountBefore;
  final int firestoreCountAfter;
  final int writeOperations;
  final int writeErrors;
  final bool? strictCountMatch;
  final bool integrityPassed;
  final List<String> notes;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'source_table': sourceTable,
      'target_collection': targetCollection,
      'source_reported_count': sourceReportedCount,
      'source_fetched_count': sourceFetchedCount,
      'unique_document_ids': uniqueDocumentIds,
      'duplicate_document_id_count': duplicateDocumentIdCount,
      'firestore_count_before': firestoreCountBefore,
      'firestore_count_after': firestoreCountAfter,
      'write_operations': writeOperations,
      'write_errors': writeErrors,
      'strict_count_match': strictCountMatch,
      'integrity_passed': integrityPassed,
      'notes': notes,
    };
  }
}

class SupabaseToFirestoreMigrator {
  SupabaseToFirestoreMigrator(this.config) : _supabaseClient = http.Client();

  final MigrationConfig config;
  final http.Client _supabaseClient;

  static const List<String> _firestoreScopes = <String>[
    'https://www.googleapis.com/auth/datastore',
    'https://www.googleapis.com/auth/cloud-platform',
  ];

  Future<MigrationReport> run() async {
    final startedAt = DateTime.now().toUtc();
    stdout.writeln('Starting migration...');
    stdout.writeln('Firebase project: ${config.firebaseProjectId}');
    stdout.writeln('Schema: ${config.schema}');
    stdout.writeln('Tables: ${config.tables.join(', ')}');
    stdout.writeln('Dry run: ${config.dryRun}');

    final credentialsFile = File(config.firebaseServiceAccountPath);
    if (!credentialsFile.existsSync()) {
      throw FileSystemException(
        'Firebase service account file not found',
        config.firebaseServiceAccountPath,
      );
    }

    final credentialsJson =
        json.decode(await credentialsFile.readAsString())
            as Map<String, dynamic>;
    final credentials = ServiceAccountCredentials.fromJson(credentialsJson);

    final firestoreClient = await clientViaServiceAccount(
      credentials,
      _firestoreScopes,
    );

    final results = <TableMigrationResult>[];

    try {
      for (final table in config.tables) {
        final targetCollection = config.tableToCollectionMap[table] ?? table;
        stdout.writeln('\nMigrating "$table" -> "$targetCollection"...');

        final result = await _migrateTable(
          firestoreClient: firestoreClient,
          sourceTable: table,
          targetCollection: targetCollection,
        );
        results.add(result);
      }
    } finally {
      _supabaseClient.close();
      firestoreClient.close();
    }

    final finishedAt = DateTime.now().toUtc();
    return MigrationReport(
      startedAt: startedAt,
      finishedAt: finishedAt,
      projectId: config.firebaseProjectId,
      dryRun: config.dryRun,
      tables: results,
    );
  }

  Future<TableMigrationResult> _migrateTable({
    required AuthClient firestoreClient,
    required String sourceTable,
    required String targetCollection,
  }) async {
    final firestoreBefore = await _countFirestoreCollection(
      firestoreClient: firestoreClient,
      collection: targetCollection,
    );

    int offset = 0;
    int reportedCount = 0;
    int fetchedCount = 0;
    int writeOperations = 0;
    int writeErrors = 0;

    final docIds = <String>{};
    int duplicateDocIdCount = 0;
    final notes = <String>[];

    while (true) {
      final response = await _fetchSupabaseRows(
        table: sourceTable,
        offset: offset,
        limit: config.fetchBatchSize,
      );

      final rows = response.rows;
      if (reportedCount == 0) {
        reportedCount = response.reportedTotal;
      }

      if (rows.isEmpty) {
        break;
      }

      fetchedCount += rows.length;
      stdout.writeln(
        '  fetched $fetchedCount / ${max(reportedCount, fetchedCount)}',
      );

      final writes = <_FirestoreWrite>[];
      for (var i = 0; i < rows.length; i++) {
        final row = rows[i];
        final docId = _resolveDocumentId(
          row: row,
          table: sourceTable,
          rowOffset: offset + i,
        );

        if (!docIds.add(docId)) {
          duplicateDocIdCount++;
          notes.add(
            'Duplicate document id detected in source table "$sourceTable": $docId',
          );
          continue;
        }

        writes.add(
          _FirestoreWrite(
            collection: targetCollection,
            docId: docId,
            fields: _toFirestoreFields(row),
          ),
        );
      }

      if (!config.dryRun && writes.isNotEmpty) {
        final chunked = _chunk(writes, config.writeBatchSize);
        for (final chunk in chunked) {
          try {
            await _commitWriteBatch(
              firestoreClient: firestoreClient,
              writes: chunk,
            );
            writeOperations += chunk.length;
          } catch (error) {
            writeErrors += chunk.length;
            notes.add('Write batch failed (${chunk.length} docs): $error');
          }
        }
      } else {
        writeOperations += writes.length;
      }

      if (rows.length < config.fetchBatchSize) {
        break;
      }
      offset += rows.length;
    }

    final firestoreAfter = await _countFirestoreCollection(
      firestoreClient: firestoreClient,
      collection: targetCollection,
    );

    final strictCountMatch = firestoreBefore == 0
        ? firestoreAfter == fetchedCount
        : null;

    final integrityPassed =
        duplicateDocIdCount == 0 &&
        writeErrors == 0 &&
        fetchedCount == reportedCount &&
        (strictCountMatch != false);

    if (strictCountMatch == null) {
      notes.add(
        'Target collection was not empty before migration; strict row count check is skipped.',
      );
    }

    if (config.dryRun) {
      notes.add('Dry-run mode: no Firestore writes executed.');
    }

    stdout.writeln(
      '  done | source=$fetchedCount, unique_ids=${docIds.length}, '
      'writes=$writeOperations, errors=$writeErrors, '
      'firestore_before=$firestoreBefore, firestore_after=$firestoreAfter',
    );

    return TableMigrationResult(
      sourceTable: sourceTable,
      targetCollection: targetCollection,
      sourceReportedCount: reportedCount,
      sourceFetchedCount: fetchedCount,
      uniqueDocumentIds: docIds.length,
      duplicateDocumentIdCount: duplicateDocIdCount,
      firestoreCountBefore: firestoreBefore,
      firestoreCountAfter: firestoreAfter,
      writeOperations: writeOperations,
      writeErrors: writeErrors,
      strictCountMatch: strictCountMatch,
      integrityPassed: integrityPassed,
      notes: notes,
    );
  }

  Future<_SupabasePageResponse> _fetchSupabaseRows({
    required String table,
    required int offset,
    required int limit,
  }) async {
    final uri = Uri.parse('${config.supabaseUrl}/rest/v1/$table').replace(
      queryParameters: <String, String>{
        'select': '*',
        'limit': '$limit',
        'offset': '$offset',
        'order': 'id.asc.nullslast',
      },
    );

    final response = await _requestWithRetry(() {
      return _supabaseClient.get(
        uri,
        headers: <String, String>{
          'apikey': config.supabaseServiceRoleKey,
          'Authorization': 'Bearer ${config.supabaseServiceRoleKey}',
          'Accept-Profile': config.schema,
          'Content-Profile': config.schema,
          'Prefer': 'count=exact',
        },
      );
    });

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Supabase read failed (${response.statusCode}) '
        'for table "$table": ${response.body}',
      );
    }

    final decoded = json.decode(response.body);
    if (decoded is! List) {
      throw const FormatException(
        'Unexpected Supabase response format: expected JSON array.',
      );
    }

    final rows = decoded
        .whereType<Map>()
        .map((row) => row.map((key, value) => MapEntry(key.toString(), value)))
        .toList(growable: false);

    final reportedTotal =
        _extractContentRangeCount(response.headers) ?? rows.length;

    return _SupabasePageResponse(rows: rows, reportedTotal: reportedTotal);
  }

  int? _extractContentRangeCount(Map<String, String> headers) {
    final contentRange = headers.entries
        .firstWhere(
          (entry) => entry.key.toLowerCase() == 'content-range',
          orElse: () => const MapEntry('', ''),
        )
        .value;
    if (contentRange.isEmpty) return null;

    final slash = contentRange.lastIndexOf('/');
    if (slash == -1 || slash == contentRange.length - 1) return null;
    final rawCount = contentRange.substring(slash + 1);
    return int.tryParse(rawCount);
  }

  Future<int> _countFirestoreCollection({
    required AuthClient firestoreClient,
    required String collection,
  }) async {
    final uri = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/'
      '${config.firebaseProjectId}/databases/(default)/documents:runAggregationQuery',
    );

    final body = json.encode(<String, dynamic>{
      'structuredAggregationQuery': <String, dynamic>{
        'aggregations': <Map<String, dynamic>>[
          <String, dynamic>{'alias': 'total', 'count': <String, dynamic>{}},
        ],
        'structuredQuery': <String, dynamic>{
          'from': <Map<String, dynamic>>[
            <String, dynamic>{'collectionId': collection},
          ],
        },
      },
    });

    final response = await _requestWithRetry(() {
      return firestoreClient.post(
        uri,
        headers: <String, String>{'Content-Type': 'application/json'},
        body: body,
      );
    });

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Firestore aggregation failed (${response.statusCode}) '
        'for "$collection": ${response.body}',
      );
    }

    final lines = response.body
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty);

    for (final line in lines) {
      final jsonLine = json.decode(line);
      if (jsonLine is! Map<String, dynamic>) {
        continue;
      }
      final result = jsonLine['result'];
      if (result is! Map<String, dynamic>) {
        continue;
      }
      final aggregateFields = result['aggregateFields'];
      if (aggregateFields is! Map<String, dynamic>) {
        continue;
      }
      final total = aggregateFields['total'];
      if (total is! Map<String, dynamic>) {
        continue;
      }
      final integerValue = total['integerValue']?.toString();
      final count = int.tryParse(integerValue ?? '');
      if (count != null) {
        return count;
      }
    }

    return 0;
  }

  Future<void> _commitWriteBatch({
    required AuthClient firestoreClient,
    required List<_FirestoreWrite> writes,
  }) async {
    final uri = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/'
      '${config.firebaseProjectId}/databases/(default)/documents:commit',
    );

    final payload = <String, dynamic>{
      'writes': writes
          .map((write) {
            return <String, dynamic>{
              'update': <String, dynamic>{
                'name':
                    'projects/${config.firebaseProjectId}/databases/(default)/documents/'
                    '${write.collection}/${write.docId}',
                'fields': write.fields,
              },
            };
          })
          .toList(growable: false),
    };

    final response = await _requestWithRetry(() {
      return firestoreClient.post(
        uri,
        headers: <String, String>{'Content-Type': 'application/json'},
        body: json.encode(payload),
      );
    });

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Firestore commit failed (${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<http.Response> _requestWithRetry(
    Future<http.Response> Function() request,
  ) async {
    var attempt = 0;
    while (true) {
      final response = await request();
      if (!_isRetryableStatus(response.statusCode)) {
        return response;
      }

      attempt++;
      if (attempt > 5) {
        return response;
      }

      final delay = Duration(milliseconds: 400 * pow(2, attempt).toInt());
      stdout.writeln(
        '  transient HTTP ${response.statusCode}, retrying in ${delay.inMilliseconds}ms...',
      );
      await Future<void>.delayed(delay);
    }
  }

  bool _isRetryableStatus(int statusCode) {
    return statusCode == 429 || statusCode >= 500;
  }

  String _resolveDocumentId({
    required Map<String, dynamic> row,
    required String table,
    required int rowOffset,
  }) {
    const preferredIdKeys = <String>['id', 'uuid', 'uid', 'user_id'];

    for (final key in preferredIdKeys) {
      final value = row[key];
      if (value == null) continue;
      final id = _sanitizeDocId(value.toString());
      if (id.isNotEmpty) {
        return id;
      }
    }

    final canonical = _canonicalJson(row);
    final digest = sha1.convert(utf8.encode(canonical)).toString();
    return _sanitizeDocId('${table}_${rowOffset}_${digest.substring(0, 16)}');
  }

  String _sanitizeDocId(String value) {
    final normalized = value.trim().replaceAll('/', '_');
    if (normalized.isEmpty) {
      return '';
    }
    return normalized.length > 512 ? normalized.substring(0, 512) : normalized;
  }

  String _canonicalJson(dynamic input) {
    dynamic normalize(dynamic value) {
      if (value is Map) {
        final keys = value.keys.map((key) => key.toString()).toList()..sort();
        return <String, dynamic>{
          for (final key in keys) key: normalize(value[key]),
        };
      }
      if (value is List) {
        return value.map(normalize).toList(growable: false);
      }
      return value;
    }

    return json.encode(normalize(input));
  }

  Map<String, dynamic> _toFirestoreFields(Map<String, dynamic> data) {
    final fields = <String, dynamic>{};
    for (final entry in data.entries) {
      fields[entry.key] = _toFirestoreValue(entry.value);
    }
    return fields;
  }

  Map<String, dynamic> _toFirestoreValue(dynamic value) {
    if (value == null) {
      return <String, dynamic>{'nullValue': null};
    }
    if (value is bool) {
      return <String, dynamic>{'booleanValue': value};
    }
    if (value is int) {
      return <String, dynamic>{'integerValue': value.toString()};
    }
    if (value is double) {
      return <String, dynamic>{'doubleValue': value};
    }
    if (value is num) {
      if (value == value.roundToDouble()) {
        return <String, dynamic>{'integerValue': value.toInt().toString()};
      }
      return <String, dynamic>{'doubleValue': value.toDouble()};
    }
    if (value is String) {
      return <String, dynamic>{'stringValue': value};
    }
    if (value is List) {
      return <String, dynamic>{
        'arrayValue': <String, dynamic>{
          'values': value.map(_toFirestoreValue).toList(growable: false),
        },
      };
    }
    if (value is Map) {
      final mapFields = <String, dynamic>{};
      value.forEach((key, nestedValue) {
        mapFields[key.toString()] = _toFirestoreValue(nestedValue);
      });
      return <String, dynamic>{
        'mapValue': <String, dynamic>{'fields': mapFields},
      };
    }

    return <String, dynamic>{'stringValue': value.toString()};
  }

  List<List<T>> _chunk<T>(List<T> values, int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < values.length; i += size) {
      final end = min(i + size, values.length);
      chunks.add(values.sublist(i, end));
    }
    return chunks;
  }
}

class _SupabasePageResponse {
  _SupabasePageResponse({required this.rows, required this.reportedTotal});

  final List<Map<String, dynamic>> rows;
  final int reportedTotal;
}

class _FirestoreWrite {
  _FirestoreWrite({
    required this.collection,
    required this.docId,
    required this.fields,
  });

  final String collection;
  final String docId;
  final Map<String, dynamic> fields;
}
