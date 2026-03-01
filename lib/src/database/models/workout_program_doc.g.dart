// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_program_doc.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWorkoutProgramDocCollection on Isar {
  IsarCollection<WorkoutProgramDoc> get workoutProgramDocs => this.collection();
}

const WorkoutProgramDocSchema = CollectionSchema(
  name: r'WorkoutProgramDoc',
  id: 6590048863895590229,
  properties: {
    r'aiSummary': PropertySchema(
      id: 0,
      name: r'aiSummary',
      type: IsarType.string,
    ),
    r'currentWeek': PropertySchema(
      id: 1,
      name: r'currentWeek',
      type: IsarType.long,
    ),
    r'goal': PropertySchema(
      id: 2,
      name: r'goal',
      type: IsarType.string,
    ),
    r'isActive': PropertySchema(
      id: 3,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'lastActiveAt': PropertySchema(
      id: 4,
      name: r'lastActiveAt',
      type: IsarType.dateTime,
    ),
    r'mode': PropertySchema(
      id: 5,
      name: r'mode',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 6,
      name: r'name',
      type: IsarType.string,
    ),
    r'planDocIds': PropertySchema(
      id: 7,
      name: r'planDocIds',
      type: IsarType.longList,
    ),
    r'startedAt': PropertySchema(
      id: 8,
      name: r'startedAt',
      type: IsarType.dateTime,
    ),
    r'weeklyPlanJson': PropertySchema(
      id: 9,
      name: r'weeklyPlanJson',
      type: IsarType.stringList,
    ),
    r'weeksTotal': PropertySchema(
      id: 10,
      name: r'weeksTotal',
      type: IsarType.long,
    )
  },
  estimateSize: _workoutProgramDocEstimateSize,
  serialize: _workoutProgramDocSerialize,
  deserialize: _workoutProgramDocDeserialize,
  deserializeProp: _workoutProgramDocDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _workoutProgramDocGetId,
  getLinks: _workoutProgramDocGetLinks,
  attach: _workoutProgramDocAttach,
  version: '3.1.0+1',
);

int _workoutProgramDocEstimateSize(
  WorkoutProgramDoc object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.aiSummary;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.goal.length * 3;
  bytesCount += 3 + object.mode.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.planDocIds.length * 8;
  bytesCount += 3 + object.weeklyPlanJson.length * 3;
  {
    for (var i = 0; i < object.weeklyPlanJson.length; i++) {
      final value = object.weeklyPlanJson[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _workoutProgramDocSerialize(
  WorkoutProgramDoc object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.aiSummary);
  writer.writeLong(offsets[1], object.currentWeek);
  writer.writeString(offsets[2], object.goal);
  writer.writeBool(offsets[3], object.isActive);
  writer.writeDateTime(offsets[4], object.lastActiveAt);
  writer.writeString(offsets[5], object.mode);
  writer.writeString(offsets[6], object.name);
  writer.writeLongList(offsets[7], object.planDocIds);
  writer.writeDateTime(offsets[8], object.startedAt);
  writer.writeStringList(offsets[9], object.weeklyPlanJson);
  writer.writeLong(offsets[10], object.weeksTotal);
}

WorkoutProgramDoc _workoutProgramDocDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WorkoutProgramDoc();
  object.aiSummary = reader.readStringOrNull(offsets[0]);
  object.currentWeek = reader.readLong(offsets[1]);
  object.goal = reader.readString(offsets[2]);
  object.id = id;
  object.isActive = reader.readBool(offsets[3]);
  object.lastActiveAt = reader.readDateTimeOrNull(offsets[4]);
  object.mode = reader.readString(offsets[5]);
  object.name = reader.readString(offsets[6]);
  object.planDocIds = reader.readLongList(offsets[7]) ?? [];
  object.startedAt = reader.readDateTime(offsets[8]);
  object.weeklyPlanJson = reader.readStringList(offsets[9]) ?? [];
  object.weeksTotal = reader.readLong(offsets[10]);
  return object;
}

P _workoutProgramDocDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLongList(offset) ?? []) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readStringList(offset) ?? []) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _workoutProgramDocGetId(WorkoutProgramDoc object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _workoutProgramDocGetLinks(
    WorkoutProgramDoc object) {
  return [];
}

void _workoutProgramDocAttach(
    IsarCollection<dynamic> col, Id id, WorkoutProgramDoc object) {
  object.id = id;
}

extension WorkoutProgramDocQueryWhereSort
    on QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QWhere> {
  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension WorkoutProgramDocQueryWhere
    on QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QWhereClause> {
  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WorkoutProgramDocQueryFilter
    on QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QFilterCondition> {
  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      aiSummaryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'aiSummary',
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      aiSummaryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'aiSummary',
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      aiSummaryEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      aiSummaryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      aiSummaryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      aiSummaryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiSummary',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      aiSummaryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aiSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      aiSummaryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aiSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      aiSummaryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aiSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      aiSummaryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aiSummary',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      aiSummaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiSummary',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      aiSummaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aiSummary',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      currentWeekEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentWeek',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      currentWeekGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentWeek',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      currentWeekLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentWeek',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      currentWeekBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentWeek',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      goalEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'goal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      goalGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'goal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      goalLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'goal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      goalBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'goal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      goalStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'goal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      goalEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'goal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      goalContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'goal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      goalMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'goal',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      goalIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'goal',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      goalIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'goal',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      isActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      lastActiveAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastActiveAt',
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      lastActiveAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastActiveAt',
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      lastActiveAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastActiveAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      lastActiveAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastActiveAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      lastActiveAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastActiveAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      lastActiveAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastActiveAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      modeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      modeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      modeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      modeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      modeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      modeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      modeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      modeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      modeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mode',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      modeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mode',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      planDocIdsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'planDocIds',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      planDocIdsElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'planDocIds',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      planDocIdsElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'planDocIds',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      planDocIdsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'planDocIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      planDocIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'planDocIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      planDocIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'planDocIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      planDocIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'planDocIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      planDocIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'planDocIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      planDocIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'planDocIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      planDocIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'planDocIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      startedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      startedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      startedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      startedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      weeklyPlanJsonElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weeklyPlanJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      weeklyPlanJsonElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weeklyPlanJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      weeklyPlanJsonElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weeklyPlanJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      weeklyPlanJsonElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weeklyPlanJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      weeklyPlanJsonElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'weeklyPlanJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      weeklyPlanJsonElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'weeklyPlanJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      weeklyPlanJsonElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'weeklyPlanJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      weeklyPlanJsonElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'weeklyPlanJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      weeklyPlanJsonElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weeklyPlanJson',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      weeklyPlanJsonElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'weeklyPlanJson',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      weeklyPlanJsonLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weeklyPlanJson',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      weeklyPlanJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weeklyPlanJson',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      weeklyPlanJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weeklyPlanJson',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      weeklyPlanJsonLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weeklyPlanJson',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      weeklyPlanJsonLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weeklyPlanJson',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      weeklyPlanJsonLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weeklyPlanJson',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      weeksTotalEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weeksTotal',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      weeksTotalGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weeksTotal',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      weeksTotalLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weeksTotal',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterFilterCondition>
      weeksTotalBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weeksTotal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WorkoutProgramDocQueryObject
    on QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QFilterCondition> {}

extension WorkoutProgramDocQueryLinks
    on QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QFilterCondition> {}

extension WorkoutProgramDocQuerySortBy
    on QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QSortBy> {
  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      sortByAiSummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiSummary', Sort.asc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      sortByAiSummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiSummary', Sort.desc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      sortByCurrentWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentWeek', Sort.asc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      sortByCurrentWeekDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentWeek', Sort.desc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      sortByGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goal', Sort.asc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      sortByGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goal', Sort.desc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      sortByLastActiveAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastActiveAt', Sort.asc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      sortByLastActiveAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastActiveAt', Sort.desc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      sortByMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mode', Sort.asc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      sortByModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mode', Sort.desc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      sortByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      sortByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      sortByWeeksTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeksTotal', Sort.asc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      sortByWeeksTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeksTotal', Sort.desc);
    });
  }
}

extension WorkoutProgramDocQuerySortThenBy
    on QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QSortThenBy> {
  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      thenByAiSummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiSummary', Sort.asc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      thenByAiSummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiSummary', Sort.desc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      thenByCurrentWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentWeek', Sort.asc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      thenByCurrentWeekDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentWeek', Sort.desc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      thenByGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goal', Sort.asc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      thenByGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goal', Sort.desc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      thenByLastActiveAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastActiveAt', Sort.asc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      thenByLastActiveAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastActiveAt', Sort.desc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      thenByMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mode', Sort.asc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      thenByModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mode', Sort.desc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      thenByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      thenByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      thenByWeeksTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeksTotal', Sort.asc);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QAfterSortBy>
      thenByWeeksTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeksTotal', Sort.desc);
    });
  }
}

extension WorkoutProgramDocQueryWhereDistinct
    on QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QDistinct> {
  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QDistinct>
      distinctByAiSummary({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiSummary', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QDistinct>
      distinctByCurrentWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentWeek');
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QDistinct> distinctByGoal(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'goal', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QDistinct>
      distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QDistinct>
      distinctByLastActiveAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastActiveAt');
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QDistinct> distinctByMode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QDistinct>
      distinctByPlanDocIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'planDocIds');
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QDistinct>
      distinctByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startedAt');
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QDistinct>
      distinctByWeeklyPlanJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weeklyPlanJson');
    });
  }

  QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QDistinct>
      distinctByWeeksTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weeksTotal');
    });
  }
}

extension WorkoutProgramDocQueryProperty
    on QueryBuilder<WorkoutProgramDoc, WorkoutProgramDoc, QQueryProperty> {
  QueryBuilder<WorkoutProgramDoc, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WorkoutProgramDoc, String?, QQueryOperations>
      aiSummaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiSummary');
    });
  }

  QueryBuilder<WorkoutProgramDoc, int, QQueryOperations> currentWeekProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentWeek');
    });
  }

  QueryBuilder<WorkoutProgramDoc, String, QQueryOperations> goalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'goal');
    });
  }

  QueryBuilder<WorkoutProgramDoc, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<WorkoutProgramDoc, DateTime?, QQueryOperations>
      lastActiveAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastActiveAt');
    });
  }

  QueryBuilder<WorkoutProgramDoc, String, QQueryOperations> modeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mode');
    });
  }

  QueryBuilder<WorkoutProgramDoc, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<WorkoutProgramDoc, List<int>, QQueryOperations>
      planDocIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'planDocIds');
    });
  }

  QueryBuilder<WorkoutProgramDoc, DateTime, QQueryOperations>
      startedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startedAt');
    });
  }

  QueryBuilder<WorkoutProgramDoc, List<String>, QQueryOperations>
      weeklyPlanJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weeklyPlanJson');
    });
  }

  QueryBuilder<WorkoutProgramDoc, int, QQueryOperations> weeksTotalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weeksTotal');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const ProgramWeekSchema = Schema(
  name: r'ProgramWeek',
  id: -4158251956543549567,
  properties: {
    r'focus': PropertySchema(
      id: 0,
      name: r'focus',
      type: IsarType.string,
    ),
    r'planDocIds': PropertySchema(
      id: 1,
      name: r'planDocIds',
      type: IsarType.longList,
    ),
    r'weekNumber': PropertySchema(
      id: 2,
      name: r'weekNumber',
      type: IsarType.long,
    )
  },
  estimateSize: _programWeekEstimateSize,
  serialize: _programWeekSerialize,
  deserialize: _programWeekDeserialize,
  deserializeProp: _programWeekDeserializeProp,
);

int _programWeekEstimateSize(
  ProgramWeek object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.focus.length * 3;
  bytesCount += 3 + object.planDocIds.length * 8;
  return bytesCount;
}

void _programWeekSerialize(
  ProgramWeek object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.focus);
  writer.writeLongList(offsets[1], object.planDocIds);
  writer.writeLong(offsets[2], object.weekNumber);
}

ProgramWeek _programWeekDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProgramWeek();
  object.focus = reader.readString(offsets[0]);
  object.planDocIds = reader.readLongList(offsets[1]) ?? [];
  object.weekNumber = reader.readLong(offsets[2]);
  return object;
}

P _programWeekDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLongList(offset) ?? []) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension ProgramWeekQueryFilter
    on QueryBuilder<ProgramWeek, ProgramWeek, QFilterCondition> {
  QueryBuilder<ProgramWeek, ProgramWeek, QAfterFilterCondition> focusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'focus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgramWeek, ProgramWeek, QAfterFilterCondition>
      focusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'focus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgramWeek, ProgramWeek, QAfterFilterCondition> focusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'focus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgramWeek, ProgramWeek, QAfterFilterCondition> focusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'focus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgramWeek, ProgramWeek, QAfterFilterCondition> focusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'focus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgramWeek, ProgramWeek, QAfterFilterCondition> focusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'focus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgramWeek, ProgramWeek, QAfterFilterCondition> focusContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'focus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgramWeek, ProgramWeek, QAfterFilterCondition> focusMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'focus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProgramWeek, ProgramWeek, QAfterFilterCondition> focusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'focus',
        value: '',
      ));
    });
  }

  QueryBuilder<ProgramWeek, ProgramWeek, QAfterFilterCondition>
      focusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'focus',
        value: '',
      ));
    });
  }

  QueryBuilder<ProgramWeek, ProgramWeek, QAfterFilterCondition>
      planDocIdsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'planDocIds',
        value: value,
      ));
    });
  }

  QueryBuilder<ProgramWeek, ProgramWeek, QAfterFilterCondition>
      planDocIdsElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'planDocIds',
        value: value,
      ));
    });
  }

  QueryBuilder<ProgramWeek, ProgramWeek, QAfterFilterCondition>
      planDocIdsElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'planDocIds',
        value: value,
      ));
    });
  }

  QueryBuilder<ProgramWeek, ProgramWeek, QAfterFilterCondition>
      planDocIdsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'planDocIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProgramWeek, ProgramWeek, QAfterFilterCondition>
      planDocIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'planDocIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ProgramWeek, ProgramWeek, QAfterFilterCondition>
      planDocIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'planDocIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ProgramWeek, ProgramWeek, QAfterFilterCondition>
      planDocIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'planDocIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ProgramWeek, ProgramWeek, QAfterFilterCondition>
      planDocIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'planDocIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ProgramWeek, ProgramWeek, QAfterFilterCondition>
      planDocIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'planDocIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ProgramWeek, ProgramWeek, QAfterFilterCondition>
      planDocIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'planDocIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ProgramWeek, ProgramWeek, QAfterFilterCondition>
      weekNumberEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weekNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<ProgramWeek, ProgramWeek, QAfterFilterCondition>
      weekNumberGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weekNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<ProgramWeek, ProgramWeek, QAfterFilterCondition>
      weekNumberLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weekNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<ProgramWeek, ProgramWeek, QAfterFilterCondition>
      weekNumberBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weekNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ProgramWeekQueryObject
    on QueryBuilder<ProgramWeek, ProgramWeek, QFilterCondition> {}
