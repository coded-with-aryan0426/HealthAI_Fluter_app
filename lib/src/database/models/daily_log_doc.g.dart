// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_log_doc.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDailyLogDocCollection on Isar {
  IsarCollection<DailyLogDoc> get dailyLogDocs => this.collection();
}

const DailyLogDocSchema = CollectionSchema(
  name: r'DailyLogDoc',
  id: 6267000021811869029,
  properties: {
    r'caloriesBurned': PropertySchema(
      id: 0,
      name: r'caloriesBurned',
      type: IsarType.long,
    ),
    r'caloriesBurnedGoal': PropertySchema(
      id: 1,
      name: r'caloriesBurnedGoal',
      type: IsarType.long,
    ),
    r'caloriesConsumed': PropertySchema(
      id: 2,
      name: r'caloriesConsumed',
      type: IsarType.long,
    ),
    r'carbsGrams': PropertySchema(
      id: 3,
      name: r'carbsGrams',
      type: IsarType.long,
    ),
    r'date': PropertySchema(
      id: 4,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'exerciseCompletedMinutes': PropertySchema(
      id: 5,
      name: r'exerciseCompletedMinutes',
      type: IsarType.long,
    ),
    r'exerciseGoalMinutes': PropertySchema(
      id: 6,
      name: r'exerciseGoalMinutes',
      type: IsarType.long,
    ),
    r'fatGrams': PropertySchema(
      id: 7,
      name: r'fatGrams',
      type: IsarType.long,
    ),
    r'proteinGrams': PropertySchema(
      id: 8,
      name: r'proteinGrams',
      type: IsarType.long,
    ),
    r'sleepMinutes': PropertySchema(
      id: 9,
      name: r'sleepMinutes',
      type: IsarType.long,
    ),
    r'standCompletedHours': PropertySchema(
      id: 10,
      name: r'standCompletedHours',
      type: IsarType.long,
    ),
    r'standGoalHours': PropertySchema(
      id: 11,
      name: r'standGoalHours',
      type: IsarType.long,
    ),
    r'stepCount': PropertySchema(
      id: 12,
      name: r'stepCount',
      type: IsarType.long,
    ),
    r'waterGoalMl': PropertySchema(
      id: 13,
      name: r'waterGoalMl',
      type: IsarType.long,
    ),
    r'waterMl': PropertySchema(
      id: 14,
      name: r'waterMl',
      type: IsarType.long,
    )
  },
  estimateSize: _dailyLogDocEstimateSize,
  serialize: _dailyLogDocSerialize,
  deserialize: _dailyLogDocDeserialize,
  deserializeProp: _dailyLogDocDeserializeProp,
  idName: r'id',
  indexes: {
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _dailyLogDocGetId,
  getLinks: _dailyLogDocGetLinks,
  attach: _dailyLogDocAttach,
  version: '3.1.0+1',
);

int _dailyLogDocEstimateSize(
  DailyLogDoc object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _dailyLogDocSerialize(
  DailyLogDoc object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.caloriesBurned);
  writer.writeLong(offsets[1], object.caloriesBurnedGoal);
  writer.writeLong(offsets[2], object.caloriesConsumed);
  writer.writeLong(offsets[3], object.carbsGrams);
  writer.writeDateTime(offsets[4], object.date);
  writer.writeLong(offsets[5], object.exerciseCompletedMinutes);
  writer.writeLong(offsets[6], object.exerciseGoalMinutes);
  writer.writeLong(offsets[7], object.fatGrams);
  writer.writeLong(offsets[8], object.proteinGrams);
  writer.writeLong(offsets[9], object.sleepMinutes);
  writer.writeLong(offsets[10], object.standCompletedHours);
  writer.writeLong(offsets[11], object.standGoalHours);
  writer.writeLong(offsets[12], object.stepCount);
  writer.writeLong(offsets[13], object.waterGoalMl);
  writer.writeLong(offsets[14], object.waterMl);
}

DailyLogDoc _dailyLogDocDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DailyLogDoc();
  object.caloriesBurned = reader.readLong(offsets[0]);
  object.caloriesBurnedGoal = reader.readLong(offsets[1]);
  object.caloriesConsumed = reader.readLong(offsets[2]);
  object.carbsGrams = reader.readLong(offsets[3]);
  object.date = reader.readDateTime(offsets[4]);
  object.exerciseCompletedMinutes = reader.readLong(offsets[5]);
  object.exerciseGoalMinutes = reader.readLong(offsets[6]);
  object.fatGrams = reader.readLong(offsets[7]);
  object.id = id;
  object.proteinGrams = reader.readLong(offsets[8]);
  object.sleepMinutes = reader.readLong(offsets[9]);
  object.standCompletedHours = reader.readLong(offsets[10]);
  object.standGoalHours = reader.readLong(offsets[11]);
  object.stepCount = reader.readLong(offsets[12]);
  object.waterGoalMl = reader.readLong(offsets[13]);
  object.waterMl = reader.readLong(offsets[14]);
  return object;
}

P _dailyLogDocDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dailyLogDocGetId(DailyLogDoc object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _dailyLogDocGetLinks(DailyLogDoc object) {
  return [];
}

void _dailyLogDocAttach(
    IsarCollection<dynamic> col, Id id, DailyLogDoc object) {
  object.id = id;
}

extension DailyLogDocByIndex on IsarCollection<DailyLogDoc> {
  Future<DailyLogDoc?> getByDate(DateTime date) {
    return getByIndex(r'date', [date]);
  }

  DailyLogDoc? getByDateSync(DateTime date) {
    return getByIndexSync(r'date', [date]);
  }

  Future<bool> deleteByDate(DateTime date) {
    return deleteByIndex(r'date', [date]);
  }

  bool deleteByDateSync(DateTime date) {
    return deleteByIndexSync(r'date', [date]);
  }

  Future<List<DailyLogDoc?>> getAllByDate(List<DateTime> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return getAllByIndex(r'date', values);
  }

  List<DailyLogDoc?> getAllByDateSync(List<DateTime> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'date', values);
  }

  Future<int> deleteAllByDate(List<DateTime> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'date', values);
  }

  int deleteAllByDateSync(List<DateTime> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'date', values);
  }

  Future<Id> putByDate(DailyLogDoc object) {
    return putByIndex(r'date', object);
  }

  Id putByDateSync(DailyLogDoc object, {bool saveLinks = true}) {
    return putByIndexSync(r'date', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByDate(List<DailyLogDoc> objects) {
    return putAllByIndex(r'date', objects);
  }

  List<Id> putAllByDateSync(List<DailyLogDoc> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'date', objects, saveLinks: saveLinks);
  }
}

extension DailyLogDocQueryWhereSort
    on QueryBuilder<DailyLogDoc, DailyLogDoc, QWhere> {
  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterWhere> anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }
}

extension DailyLogDocQueryWhere
    on QueryBuilder<DailyLogDoc, DailyLogDoc, QWhereClause> {
  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterWhereClause> idBetween(
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

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterWhereClause> dateEqualTo(
      DateTime date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterWhereClause> dateNotEqualTo(
      DateTime date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterWhereClause> dateGreaterThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [date],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterWhereClause> dateLessThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [],
        upper: [date],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterWhereClause> dateBetween(
    DateTime lowerDate,
    DateTime upperDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [lowerDate],
        includeLower: includeLower,
        upper: [upperDate],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DailyLogDocQueryFilter
    on QueryBuilder<DailyLogDoc, DailyLogDoc, QFilterCondition> {
  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      caloriesBurnedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'caloriesBurned',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      caloriesBurnedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'caloriesBurned',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      caloriesBurnedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'caloriesBurned',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      caloriesBurnedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'caloriesBurned',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      caloriesBurnedGoalEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'caloriesBurnedGoal',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      caloriesBurnedGoalGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'caloriesBurnedGoal',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      caloriesBurnedGoalLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'caloriesBurnedGoal',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      caloriesBurnedGoalBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'caloriesBurnedGoal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      caloriesConsumedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'caloriesConsumed',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      caloriesConsumedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'caloriesConsumed',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      caloriesConsumedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'caloriesConsumed',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      caloriesConsumedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'caloriesConsumed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      carbsGramsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'carbsGrams',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      carbsGramsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'carbsGrams',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      carbsGramsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'carbsGrams',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      carbsGramsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'carbsGrams',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition> dateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition> dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition> dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      exerciseCompletedMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'exerciseCompletedMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      exerciseCompletedMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'exerciseCompletedMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      exerciseCompletedMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'exerciseCompletedMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      exerciseCompletedMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'exerciseCompletedMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      exerciseGoalMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'exerciseGoalMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      exerciseGoalMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'exerciseGoalMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      exerciseGoalMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'exerciseGoalMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      exerciseGoalMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'exerciseGoalMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition> fatGramsEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fatGrams',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      fatGramsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fatGrams',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      fatGramsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fatGrams',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition> fatGramsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fatGrams',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition> idBetween(
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

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      proteinGramsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proteinGrams',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      proteinGramsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'proteinGrams',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      proteinGramsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'proteinGrams',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      proteinGramsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'proteinGrams',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      sleepMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sleepMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      sleepMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sleepMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      sleepMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sleepMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      sleepMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sleepMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      standCompletedHoursEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'standCompletedHours',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      standCompletedHoursGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'standCompletedHours',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      standCompletedHoursLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'standCompletedHours',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      standCompletedHoursBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'standCompletedHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      standGoalHoursEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'standGoalHours',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      standGoalHoursGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'standGoalHours',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      standGoalHoursLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'standGoalHours',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      standGoalHoursBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'standGoalHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      stepCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stepCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      stepCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stepCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      stepCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stepCount',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      stepCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stepCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      waterGoalMlEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'waterGoalMl',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      waterGoalMlGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'waterGoalMl',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      waterGoalMlLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'waterGoalMl',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      waterGoalMlBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'waterGoalMl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition> waterMlEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'waterMl',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition>
      waterMlGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'waterMl',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition> waterMlLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'waterMl',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterFilterCondition> waterMlBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'waterMl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DailyLogDocQueryObject
    on QueryBuilder<DailyLogDoc, DailyLogDoc, QFilterCondition> {}

extension DailyLogDocQueryLinks
    on QueryBuilder<DailyLogDoc, DailyLogDoc, QFilterCondition> {}

extension DailyLogDocQuerySortBy
    on QueryBuilder<DailyLogDoc, DailyLogDoc, QSortBy> {
  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> sortByCaloriesBurned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caloriesBurned', Sort.asc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy>
      sortByCaloriesBurnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caloriesBurned', Sort.desc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy>
      sortByCaloriesBurnedGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caloriesBurnedGoal', Sort.asc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy>
      sortByCaloriesBurnedGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caloriesBurnedGoal', Sort.desc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy>
      sortByCaloriesConsumed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caloriesConsumed', Sort.asc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy>
      sortByCaloriesConsumedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caloriesConsumed', Sort.desc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> sortByCarbsGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsGrams', Sort.asc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> sortByCarbsGramsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsGrams', Sort.desc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy>
      sortByExerciseCompletedMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseCompletedMinutes', Sort.asc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy>
      sortByExerciseCompletedMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseCompletedMinutes', Sort.desc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy>
      sortByExerciseGoalMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseGoalMinutes', Sort.asc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy>
      sortByExerciseGoalMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseGoalMinutes', Sort.desc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> sortByFatGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatGrams', Sort.asc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> sortByFatGramsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatGrams', Sort.desc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> sortByProteinGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinGrams', Sort.asc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy>
      sortByProteinGramsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinGrams', Sort.desc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> sortBySleepMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepMinutes', Sort.asc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy>
      sortBySleepMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepMinutes', Sort.desc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy>
      sortByStandCompletedHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'standCompletedHours', Sort.asc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy>
      sortByStandCompletedHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'standCompletedHours', Sort.desc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> sortByStandGoalHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'standGoalHours', Sort.asc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy>
      sortByStandGoalHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'standGoalHours', Sort.desc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> sortByStepCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepCount', Sort.asc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> sortByStepCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepCount', Sort.desc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> sortByWaterGoalMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterGoalMl', Sort.asc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> sortByWaterGoalMlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterGoalMl', Sort.desc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> sortByWaterMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterMl', Sort.asc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> sortByWaterMlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterMl', Sort.desc);
    });
  }
}

extension DailyLogDocQuerySortThenBy
    on QueryBuilder<DailyLogDoc, DailyLogDoc, QSortThenBy> {
  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> thenByCaloriesBurned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caloriesBurned', Sort.asc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy>
      thenByCaloriesBurnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caloriesBurned', Sort.desc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy>
      thenByCaloriesBurnedGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caloriesBurnedGoal', Sort.asc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy>
      thenByCaloriesBurnedGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caloriesBurnedGoal', Sort.desc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy>
      thenByCaloriesConsumed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caloriesConsumed', Sort.asc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy>
      thenByCaloriesConsumedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'caloriesConsumed', Sort.desc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> thenByCarbsGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsGrams', Sort.asc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> thenByCarbsGramsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsGrams', Sort.desc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy>
      thenByExerciseCompletedMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseCompletedMinutes', Sort.asc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy>
      thenByExerciseCompletedMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseCompletedMinutes', Sort.desc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy>
      thenByExerciseGoalMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseGoalMinutes', Sort.asc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy>
      thenByExerciseGoalMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseGoalMinutes', Sort.desc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> thenByFatGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatGrams', Sort.asc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> thenByFatGramsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatGrams', Sort.desc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> thenByProteinGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinGrams', Sort.asc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy>
      thenByProteinGramsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinGrams', Sort.desc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> thenBySleepMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepMinutes', Sort.asc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy>
      thenBySleepMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepMinutes', Sort.desc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy>
      thenByStandCompletedHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'standCompletedHours', Sort.asc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy>
      thenByStandCompletedHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'standCompletedHours', Sort.desc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> thenByStandGoalHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'standGoalHours', Sort.asc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy>
      thenByStandGoalHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'standGoalHours', Sort.desc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> thenByStepCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepCount', Sort.asc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> thenByStepCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepCount', Sort.desc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> thenByWaterGoalMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterGoalMl', Sort.asc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> thenByWaterGoalMlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterGoalMl', Sort.desc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> thenByWaterMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterMl', Sort.asc);
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QAfterSortBy> thenByWaterMlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterMl', Sort.desc);
    });
  }
}

extension DailyLogDocQueryWhereDistinct
    on QueryBuilder<DailyLogDoc, DailyLogDoc, QDistinct> {
  QueryBuilder<DailyLogDoc, DailyLogDoc, QDistinct> distinctByCaloriesBurned() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'caloriesBurned');
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QDistinct>
      distinctByCaloriesBurnedGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'caloriesBurnedGoal');
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QDistinct>
      distinctByCaloriesConsumed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'caloriesConsumed');
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QDistinct> distinctByCarbsGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'carbsGrams');
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QDistinct>
      distinctByExerciseCompletedMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'exerciseCompletedMinutes');
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QDistinct>
      distinctByExerciseGoalMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'exerciseGoalMinutes');
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QDistinct> distinctByFatGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fatGrams');
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QDistinct> distinctByProteinGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proteinGrams');
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QDistinct> distinctBySleepMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sleepMinutes');
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QDistinct>
      distinctByStandCompletedHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'standCompletedHours');
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QDistinct> distinctByStandGoalHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'standGoalHours');
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QDistinct> distinctByStepCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stepCount');
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QDistinct> distinctByWaterGoalMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'waterGoalMl');
    });
  }

  QueryBuilder<DailyLogDoc, DailyLogDoc, QDistinct> distinctByWaterMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'waterMl');
    });
  }
}

extension DailyLogDocQueryProperty
    on QueryBuilder<DailyLogDoc, DailyLogDoc, QQueryProperty> {
  QueryBuilder<DailyLogDoc, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DailyLogDoc, int, QQueryOperations> caloriesBurnedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'caloriesBurned');
    });
  }

  QueryBuilder<DailyLogDoc, int, QQueryOperations>
      caloriesBurnedGoalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'caloriesBurnedGoal');
    });
  }

  QueryBuilder<DailyLogDoc, int, QQueryOperations> caloriesConsumedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'caloriesConsumed');
    });
  }

  QueryBuilder<DailyLogDoc, int, QQueryOperations> carbsGramsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'carbsGrams');
    });
  }

  QueryBuilder<DailyLogDoc, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<DailyLogDoc, int, QQueryOperations>
      exerciseCompletedMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'exerciseCompletedMinutes');
    });
  }

  QueryBuilder<DailyLogDoc, int, QQueryOperations>
      exerciseGoalMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'exerciseGoalMinutes');
    });
  }

  QueryBuilder<DailyLogDoc, int, QQueryOperations> fatGramsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fatGrams');
    });
  }

  QueryBuilder<DailyLogDoc, int, QQueryOperations> proteinGramsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proteinGrams');
    });
  }

  QueryBuilder<DailyLogDoc, int, QQueryOperations> sleepMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sleepMinutes');
    });
  }

  QueryBuilder<DailyLogDoc, int, QQueryOperations>
      standCompletedHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'standCompletedHours');
    });
  }

  QueryBuilder<DailyLogDoc, int, QQueryOperations> standGoalHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'standGoalHours');
    });
  }

  QueryBuilder<DailyLogDoc, int, QQueryOperations> stepCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stepCount');
    });
  }

  QueryBuilder<DailyLogDoc, int, QQueryOperations> waterGoalMlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'waterGoalMl');
    });
  }

  QueryBuilder<DailyLogDoc, int, QQueryOperations> waterMlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'waterMl');
    });
  }
}
