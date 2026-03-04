// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_log_doc.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetNutritionLogDocCollection on Isar {
  IsarCollection<NutritionLogDoc> get nutritionLogDocs => this.collection();
}

const NutritionLogDocSchema = CollectionSchema(
  name: r'NutritionLogDoc',
  id: -7298412871314574592,
  properties: {
    r'avgHealthScore': PropertySchema(
      id: 0,
      name: r'avgHealthScore',
      type: IsarType.double,
    ),
    r'calciumMg': PropertySchema(
      id: 1,
      name: r'calciumMg',
      type: IsarType.double,
    ),
    r'date': PropertySchema(
      id: 2,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'fiberG': PropertySchema(
      id: 3,
      name: r'fiberG',
      type: IsarType.double,
    ),
    r'hitCalorieGoal': PropertySchema(
      id: 4,
      name: r'hitCalorieGoal',
      type: IsarType.bool,
    ),
    r'hitProteinGoal': PropertySchema(
      id: 5,
      name: r'hitProteinGoal',
      type: IsarType.bool,
    ),
    r'insightGeneratedAt': PropertySchema(
      id: 6,
      name: r'insightGeneratedAt',
      type: IsarType.dateTime,
    ),
    r'insightJson': PropertySchema(
      id: 7,
      name: r'insightJson',
      type: IsarType.string,
    ),
    r'ironMg': PropertySchema(
      id: 8,
      name: r'ironMg',
      type: IsarType.double,
    ),
    r'mealCount': PropertySchema(
      id: 9,
      name: r'mealCount',
      type: IsarType.long,
    ),
    r'mealTypesLogged': PropertySchema(
      id: 10,
      name: r'mealTypesLogged',
      type: IsarType.string,
    ),
    r'potassiumMg': PropertySchema(
      id: 11,
      name: r'potassiumMg',
      type: IsarType.double,
    ),
    r'sodiumMg': PropertySchema(
      id: 12,
      name: r'sodiumMg',
      type: IsarType.double,
    ),
    r'sugarG': PropertySchema(
      id: 13,
      name: r'sugarG',
      type: IsarType.double,
    ),
    r'totalCalories': PropertySchema(
      id: 14,
      name: r'totalCalories',
      type: IsarType.long,
    ),
    r'totalCarbsG': PropertySchema(
      id: 15,
      name: r'totalCarbsG',
      type: IsarType.long,
    ),
    r'totalFatG': PropertySchema(
      id: 16,
      name: r'totalFatG',
      type: IsarType.long,
    ),
    r'totalProteinG': PropertySchema(
      id: 17,
      name: r'totalProteinG',
      type: IsarType.long,
    ),
    r'vitaminCMg': PropertySchema(
      id: 18,
      name: r'vitaminCMg',
      type: IsarType.double,
    ),
    r'vitaminDMcg': PropertySchema(
      id: 19,
      name: r'vitaminDMcg',
      type: IsarType.double,
    ),
    r'waterMl': PropertySchema(
      id: 20,
      name: r'waterMl',
      type: IsarType.long,
    )
  },
  estimateSize: _nutritionLogDocEstimateSize,
  serialize: _nutritionLogDocSerialize,
  deserialize: _nutritionLogDocDeserialize,
  deserializeProp: _nutritionLogDocDeserializeProp,
  idName: r'id',
  indexes: {
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: true,
      replace: false,
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
  getId: _nutritionLogDocGetId,
  getLinks: _nutritionLogDocGetLinks,
  attach: _nutritionLogDocAttach,
  version: '3.1.0+1',
);

int _nutritionLogDocEstimateSize(
  NutritionLogDoc object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.insightJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.mealTypesLogged.length * 3;
  return bytesCount;
}

void _nutritionLogDocSerialize(
  NutritionLogDoc object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.avgHealthScore);
  writer.writeDouble(offsets[1], object.calciumMg);
  writer.writeDateTime(offsets[2], object.date);
  writer.writeDouble(offsets[3], object.fiberG);
  writer.writeBool(offsets[4], object.hitCalorieGoal);
  writer.writeBool(offsets[5], object.hitProteinGoal);
  writer.writeDateTime(offsets[6], object.insightGeneratedAt);
  writer.writeString(offsets[7], object.insightJson);
  writer.writeDouble(offsets[8], object.ironMg);
  writer.writeLong(offsets[9], object.mealCount);
  writer.writeString(offsets[10], object.mealTypesLogged);
  writer.writeDouble(offsets[11], object.potassiumMg);
  writer.writeDouble(offsets[12], object.sodiumMg);
  writer.writeDouble(offsets[13], object.sugarG);
  writer.writeLong(offsets[14], object.totalCalories);
  writer.writeLong(offsets[15], object.totalCarbsG);
  writer.writeLong(offsets[16], object.totalFatG);
  writer.writeLong(offsets[17], object.totalProteinG);
  writer.writeDouble(offsets[18], object.vitaminCMg);
  writer.writeDouble(offsets[19], object.vitaminDMcg);
  writer.writeLong(offsets[20], object.waterMl);
}

NutritionLogDoc _nutritionLogDocDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = NutritionLogDoc();
  object.avgHealthScore = reader.readDouble(offsets[0]);
  object.calciumMg = reader.readDouble(offsets[1]);
  object.date = reader.readDateTime(offsets[2]);
  object.fiberG = reader.readDouble(offsets[3]);
  object.hitCalorieGoal = reader.readBool(offsets[4]);
  object.hitProteinGoal = reader.readBool(offsets[5]);
  object.id = id;
  object.insightGeneratedAt = reader.readDateTimeOrNull(offsets[6]);
  object.insightJson = reader.readStringOrNull(offsets[7]);
  object.ironMg = reader.readDouble(offsets[8]);
  object.mealCount = reader.readLong(offsets[9]);
  object.mealTypesLogged = reader.readString(offsets[10]);
  object.potassiumMg = reader.readDouble(offsets[11]);
  object.sodiumMg = reader.readDouble(offsets[12]);
  object.sugarG = reader.readDouble(offsets[13]);
  object.totalCalories = reader.readLong(offsets[14]);
  object.totalCarbsG = reader.readLong(offsets[15]);
  object.totalFatG = reader.readLong(offsets[16]);
  object.totalProteinG = reader.readLong(offsets[17]);
  object.vitaminCMg = reader.readDouble(offsets[18]);
  object.vitaminDMcg = reader.readDouble(offsets[19]);
  object.waterMl = reader.readLong(offsets[20]);
  return object;
}

P _nutritionLogDocDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readDouble(offset)) as P;
    case 12:
      return (reader.readDouble(offset)) as P;
    case 13:
      return (reader.readDouble(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    case 16:
      return (reader.readLong(offset)) as P;
    case 17:
      return (reader.readLong(offset)) as P;
    case 18:
      return (reader.readDouble(offset)) as P;
    case 19:
      return (reader.readDouble(offset)) as P;
    case 20:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _nutritionLogDocGetId(NutritionLogDoc object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _nutritionLogDocGetLinks(NutritionLogDoc object) {
  return [];
}

void _nutritionLogDocAttach(
    IsarCollection<dynamic> col, Id id, NutritionLogDoc object) {
  object.id = id;
}

extension NutritionLogDocByIndex on IsarCollection<NutritionLogDoc> {
  Future<NutritionLogDoc?> getByDate(DateTime date) {
    return getByIndex(r'date', [date]);
  }

  NutritionLogDoc? getByDateSync(DateTime date) {
    return getByIndexSync(r'date', [date]);
  }

  Future<bool> deleteByDate(DateTime date) {
    return deleteByIndex(r'date', [date]);
  }

  bool deleteByDateSync(DateTime date) {
    return deleteByIndexSync(r'date', [date]);
  }

  Future<List<NutritionLogDoc?>> getAllByDate(List<DateTime> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return getAllByIndex(r'date', values);
  }

  List<NutritionLogDoc?> getAllByDateSync(List<DateTime> dateValues) {
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

  Future<Id> putByDate(NutritionLogDoc object) {
    return putByIndex(r'date', object);
  }

  Id putByDateSync(NutritionLogDoc object, {bool saveLinks = true}) {
    return putByIndexSync(r'date', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByDate(List<NutritionLogDoc> objects) {
    return putAllByIndex(r'date', objects);
  }

  List<Id> putAllByDateSync(List<NutritionLogDoc> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'date', objects, saveLinks: saveLinks);
  }
}

extension NutritionLogDocQueryWhereSort
    on QueryBuilder<NutritionLogDoc, NutritionLogDoc, QWhere> {
  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterWhere> anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }
}

extension NutritionLogDocQueryWhere
    on QueryBuilder<NutritionLogDoc, NutritionLogDoc, QWhereClause> {
  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterWhereClause>
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

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterWhereClause> idBetween(
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

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterWhereClause> dateEqualTo(
      DateTime date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterWhereClause>
      dateNotEqualTo(DateTime date) {
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

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterWhereClause>
      dateGreaterThan(
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

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterWhereClause>
      dateLessThan(
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

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterWhereClause> dateBetween(
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

extension NutritionLogDocQueryFilter
    on QueryBuilder<NutritionLogDoc, NutritionLogDoc, QFilterCondition> {
  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      avgHealthScoreEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avgHealthScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      avgHealthScoreGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'avgHealthScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      avgHealthScoreLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'avgHealthScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      avgHealthScoreBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'avgHealthScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      calciumMgEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'calciumMg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      calciumMgGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'calciumMg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      calciumMgLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'calciumMg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      calciumMgBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'calciumMg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      dateGreaterThan(
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

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      dateLessThan(
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

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      dateBetween(
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

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      fiberGEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fiberG',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      fiberGGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fiberG',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      fiberGLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fiberG',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      fiberGBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fiberG',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      hitCalorieGoalEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hitCalorieGoal',
        value: value,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      hitProteinGoalEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hitProteinGoal',
        value: value,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
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

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
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

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
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

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      insightGeneratedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'insightGeneratedAt',
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      insightGeneratedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'insightGeneratedAt',
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      insightGeneratedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'insightGeneratedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      insightGeneratedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'insightGeneratedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      insightGeneratedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'insightGeneratedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      insightGeneratedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'insightGeneratedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      insightJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'insightJson',
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      insightJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'insightJson',
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      insightJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'insightJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      insightJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'insightJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      insightJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'insightJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      insightJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'insightJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      insightJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'insightJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      insightJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'insightJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      insightJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'insightJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      insightJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'insightJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      insightJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'insightJson',
        value: '',
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      insightJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'insightJson',
        value: '',
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      ironMgEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ironMg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      ironMgGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ironMg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      ironMgLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ironMg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      ironMgBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ironMg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      mealCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mealCount',
        value: value,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      mealCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mealCount',
        value: value,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      mealCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mealCount',
        value: value,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      mealCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mealCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      mealTypesLoggedEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mealTypesLogged',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      mealTypesLoggedGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mealTypesLogged',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      mealTypesLoggedLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mealTypesLogged',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      mealTypesLoggedBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mealTypesLogged',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      mealTypesLoggedStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mealTypesLogged',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      mealTypesLoggedEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mealTypesLogged',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      mealTypesLoggedContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mealTypesLogged',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      mealTypesLoggedMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mealTypesLogged',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      mealTypesLoggedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mealTypesLogged',
        value: '',
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      mealTypesLoggedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mealTypesLogged',
        value: '',
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      potassiumMgEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'potassiumMg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      potassiumMgGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'potassiumMg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      potassiumMgLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'potassiumMg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      potassiumMgBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'potassiumMg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      sodiumMgEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sodiumMg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      sodiumMgGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sodiumMg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      sodiumMgLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sodiumMg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      sodiumMgBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sodiumMg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      sugarGEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sugarG',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      sugarGGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sugarG',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      sugarGLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sugarG',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      sugarGBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sugarG',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      totalCaloriesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalCalories',
        value: value,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      totalCaloriesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalCalories',
        value: value,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      totalCaloriesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalCalories',
        value: value,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      totalCaloriesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalCalories',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      totalCarbsGEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalCarbsG',
        value: value,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      totalCarbsGGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalCarbsG',
        value: value,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      totalCarbsGLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalCarbsG',
        value: value,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      totalCarbsGBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalCarbsG',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      totalFatGEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalFatG',
        value: value,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      totalFatGGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalFatG',
        value: value,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      totalFatGLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalFatG',
        value: value,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      totalFatGBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalFatG',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      totalProteinGEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalProteinG',
        value: value,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      totalProteinGGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalProteinG',
        value: value,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      totalProteinGLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalProteinG',
        value: value,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      totalProteinGBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalProteinG',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      vitaminCMgEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vitaminCMg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      vitaminCMgGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'vitaminCMg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      vitaminCMgLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'vitaminCMg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      vitaminCMgBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'vitaminCMg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      vitaminDMcgEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vitaminDMcg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      vitaminDMcgGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'vitaminDMcg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      vitaminDMcgLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'vitaminDMcg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      vitaminDMcgBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'vitaminDMcg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      waterMlEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'waterMl',
        value: value,
      ));
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
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

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      waterMlLessThan(
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

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterFilterCondition>
      waterMlBetween(
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

extension NutritionLogDocQueryObject
    on QueryBuilder<NutritionLogDoc, NutritionLogDoc, QFilterCondition> {}

extension NutritionLogDocQueryLinks
    on QueryBuilder<NutritionLogDoc, NutritionLogDoc, QFilterCondition> {}

extension NutritionLogDocQuerySortBy
    on QueryBuilder<NutritionLogDoc, NutritionLogDoc, QSortBy> {
  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByAvgHealthScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgHealthScore', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByAvgHealthScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgHealthScore', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByCalciumMg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calciumMg', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByCalciumMgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calciumMg', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy> sortByFiberG() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiberG', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByFiberGDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiberG', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByHitCalorieGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hitCalorieGoal', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByHitCalorieGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hitCalorieGoal', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByHitProteinGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hitProteinGoal', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByHitProteinGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hitProteinGoal', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByInsightGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insightGeneratedAt', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByInsightGeneratedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insightGeneratedAt', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByInsightJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insightJson', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByInsightJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insightJson', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy> sortByIronMg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ironMg', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByIronMgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ironMg', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByMealCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealCount', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByMealCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealCount', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByMealTypesLogged() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealTypesLogged', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByMealTypesLoggedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealTypesLogged', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByPotassiumMg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'potassiumMg', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByPotassiumMgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'potassiumMg', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortBySodiumMg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sodiumMg', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortBySodiumMgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sodiumMg', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy> sortBySugarG() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sugarG', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortBySugarGDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sugarG', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByTotalCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCalories', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByTotalCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCalories', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByTotalCarbsG() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCarbsG', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByTotalCarbsGDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCarbsG', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByTotalFatG() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFatG', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByTotalFatGDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFatG', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByTotalProteinG() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalProteinG', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByTotalProteinGDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalProteinG', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByVitaminCMg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vitaminCMg', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByVitaminCMgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vitaminCMg', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByVitaminDMcg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vitaminDMcg', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByVitaminDMcgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vitaminDMcg', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy> sortByWaterMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterMl', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      sortByWaterMlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterMl', Sort.desc);
    });
  }
}

extension NutritionLogDocQuerySortThenBy
    on QueryBuilder<NutritionLogDoc, NutritionLogDoc, QSortThenBy> {
  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByAvgHealthScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgHealthScore', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByAvgHealthScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgHealthScore', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByCalciumMg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calciumMg', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByCalciumMgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calciumMg', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy> thenByFiberG() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiberG', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByFiberGDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiberG', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByHitCalorieGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hitCalorieGoal', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByHitCalorieGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hitCalorieGoal', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByHitProteinGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hitProteinGoal', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByHitProteinGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hitProteinGoal', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByInsightGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insightGeneratedAt', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByInsightGeneratedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insightGeneratedAt', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByInsightJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insightJson', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByInsightJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insightJson', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy> thenByIronMg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ironMg', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByIronMgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ironMg', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByMealCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealCount', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByMealCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealCount', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByMealTypesLogged() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealTypesLogged', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByMealTypesLoggedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealTypesLogged', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByPotassiumMg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'potassiumMg', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByPotassiumMgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'potassiumMg', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenBySodiumMg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sodiumMg', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenBySodiumMgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sodiumMg', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy> thenBySugarG() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sugarG', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenBySugarGDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sugarG', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByTotalCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCalories', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByTotalCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCalories', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByTotalCarbsG() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCarbsG', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByTotalCarbsGDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCarbsG', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByTotalFatG() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFatG', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByTotalFatGDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalFatG', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByTotalProteinG() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalProteinG', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByTotalProteinGDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalProteinG', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByVitaminCMg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vitaminCMg', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByVitaminCMgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vitaminCMg', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByVitaminDMcg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vitaminDMcg', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByVitaminDMcgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vitaminDMcg', Sort.desc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy> thenByWaterMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterMl', Sort.asc);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QAfterSortBy>
      thenByWaterMlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterMl', Sort.desc);
    });
  }
}

extension NutritionLogDocQueryWhereDistinct
    on QueryBuilder<NutritionLogDoc, NutritionLogDoc, QDistinct> {
  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QDistinct>
      distinctByAvgHealthScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avgHealthScore');
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QDistinct>
      distinctByCalciumMg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'calciumMg');
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QDistinct> distinctByFiberG() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fiberG');
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QDistinct>
      distinctByHitCalorieGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hitCalorieGoal');
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QDistinct>
      distinctByHitProteinGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hitProteinGoal');
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QDistinct>
      distinctByInsightGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'insightGeneratedAt');
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QDistinct>
      distinctByInsightJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'insightJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QDistinct> distinctByIronMg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ironMg');
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QDistinct>
      distinctByMealCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mealCount');
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QDistinct>
      distinctByMealTypesLogged({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mealTypesLogged',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QDistinct>
      distinctByPotassiumMg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'potassiumMg');
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QDistinct>
      distinctBySodiumMg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sodiumMg');
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QDistinct> distinctBySugarG() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sugarG');
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QDistinct>
      distinctByTotalCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalCalories');
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QDistinct>
      distinctByTotalCarbsG() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalCarbsG');
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QDistinct>
      distinctByTotalFatG() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalFatG');
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QDistinct>
      distinctByTotalProteinG() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalProteinG');
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QDistinct>
      distinctByVitaminCMg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vitaminCMg');
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QDistinct>
      distinctByVitaminDMcg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vitaminDMcg');
    });
  }

  QueryBuilder<NutritionLogDoc, NutritionLogDoc, QDistinct>
      distinctByWaterMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'waterMl');
    });
  }
}

extension NutritionLogDocQueryProperty
    on QueryBuilder<NutritionLogDoc, NutritionLogDoc, QQueryProperty> {
  QueryBuilder<NutritionLogDoc, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<NutritionLogDoc, double, QQueryOperations>
      avgHealthScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avgHealthScore');
    });
  }

  QueryBuilder<NutritionLogDoc, double, QQueryOperations> calciumMgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'calciumMg');
    });
  }

  QueryBuilder<NutritionLogDoc, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<NutritionLogDoc, double, QQueryOperations> fiberGProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fiberG');
    });
  }

  QueryBuilder<NutritionLogDoc, bool, QQueryOperations>
      hitCalorieGoalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hitCalorieGoal');
    });
  }

  QueryBuilder<NutritionLogDoc, bool, QQueryOperations>
      hitProteinGoalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hitProteinGoal');
    });
  }

  QueryBuilder<NutritionLogDoc, DateTime?, QQueryOperations>
      insightGeneratedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'insightGeneratedAt');
    });
  }

  QueryBuilder<NutritionLogDoc, String?, QQueryOperations>
      insightJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'insightJson');
    });
  }

  QueryBuilder<NutritionLogDoc, double, QQueryOperations> ironMgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ironMg');
    });
  }

  QueryBuilder<NutritionLogDoc, int, QQueryOperations> mealCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mealCount');
    });
  }

  QueryBuilder<NutritionLogDoc, String, QQueryOperations>
      mealTypesLoggedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mealTypesLogged');
    });
  }

  QueryBuilder<NutritionLogDoc, double, QQueryOperations>
      potassiumMgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'potassiumMg');
    });
  }

  QueryBuilder<NutritionLogDoc, double, QQueryOperations> sodiumMgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sodiumMg');
    });
  }

  QueryBuilder<NutritionLogDoc, double, QQueryOperations> sugarGProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sugarG');
    });
  }

  QueryBuilder<NutritionLogDoc, int, QQueryOperations> totalCaloriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalCalories');
    });
  }

  QueryBuilder<NutritionLogDoc, int, QQueryOperations> totalCarbsGProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalCarbsG');
    });
  }

  QueryBuilder<NutritionLogDoc, int, QQueryOperations> totalFatGProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalFatG');
    });
  }

  QueryBuilder<NutritionLogDoc, int, QQueryOperations> totalProteinGProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalProteinG');
    });
  }

  QueryBuilder<NutritionLogDoc, double, QQueryOperations> vitaminCMgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vitaminCMg');
    });
  }

  QueryBuilder<NutritionLogDoc, double, QQueryOperations>
      vitaminDMcgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vitaminDMcg');
    });
  }

  QueryBuilder<NutritionLogDoc, int, QQueryOperations> waterMlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'waterMl');
    });
  }
}
