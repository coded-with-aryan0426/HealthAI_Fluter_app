// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan_doc.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMealPlanDocCollection on Isar {
  IsarCollection<MealPlanDoc> get mealPlanDocs => this.collection();
}

const MealPlanDocSchema = CollectionSchema(
  name: r'MealPlanDoc',
  id: 671965533362585847,
  properties: {
    r'avgDailyCalories': PropertySchema(
      id: 0,
      name: r'avgDailyCalories',
      type: IsarType.long,
    ),
    r'avgDailyProtein': PropertySchema(
      id: 1,
      name: r'avgDailyProtein',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'durationDays': PropertySchema(
      id: 3,
      name: r'durationDays',
      type: IsarType.long,
    ),
    r'goal': PropertySchema(
      id: 4,
      name: r'goal',
      type: IsarType.string,
    ),
    r'planJson': PropertySchema(
      id: 5,
      name: r'planJson',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 6,
      name: r'status',
      type: IsarType.string,
    ),
    r'targetDate': PropertySchema(
      id: 7,
      name: r'targetDate',
      type: IsarType.dateTime,
    ),
    r'userContextSnapshot': PropertySchema(
      id: 8,
      name: r'userContextSnapshot',
      type: IsarType.string,
    )
  },
  estimateSize: _mealPlanDocEstimateSize,
  serialize: _mealPlanDocSerialize,
  deserialize: _mealPlanDocDeserialize,
  deserializeProp: _mealPlanDocDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _mealPlanDocGetId,
  getLinks: _mealPlanDocGetLinks,
  attach: _mealPlanDocAttach,
  version: '3.1.0+1',
);

int _mealPlanDocEstimateSize(
  MealPlanDoc object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.goal.length * 3;
  bytesCount += 3 + object.planJson.length * 3;
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.userContextSnapshot.length * 3;
  return bytesCount;
}

void _mealPlanDocSerialize(
  MealPlanDoc object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.avgDailyCalories);
  writer.writeLong(offsets[1], object.avgDailyProtein);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeLong(offsets[3], object.durationDays);
  writer.writeString(offsets[4], object.goal);
  writer.writeString(offsets[5], object.planJson);
  writer.writeString(offsets[6], object.status);
  writer.writeDateTime(offsets[7], object.targetDate);
  writer.writeString(offsets[8], object.userContextSnapshot);
}

MealPlanDoc _mealPlanDocDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MealPlanDoc();
  object.avgDailyCalories = reader.readLong(offsets[0]);
  object.avgDailyProtein = reader.readLong(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.durationDays = reader.readLong(offsets[3]);
  object.goal = reader.readString(offsets[4]);
  object.id = id;
  object.planJson = reader.readString(offsets[5]);
  object.status = reader.readString(offsets[6]);
  object.targetDate = reader.readDateTime(offsets[7]);
  object.userContextSnapshot = reader.readString(offsets[8]);
  return object;
}

P _mealPlanDocDeserializeProp<P>(
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
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _mealPlanDocGetId(MealPlanDoc object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _mealPlanDocGetLinks(MealPlanDoc object) {
  return [];
}

void _mealPlanDocAttach(
    IsarCollection<dynamic> col, Id id, MealPlanDoc object) {
  object.id = id;
}

extension MealPlanDocQueryWhereSort
    on QueryBuilder<MealPlanDoc, MealPlanDoc, QWhere> {
  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MealPlanDocQueryWhere
    on QueryBuilder<MealPlanDoc, MealPlanDoc, QWhereClause> {
  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterWhereClause> idBetween(
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

extension MealPlanDocQueryFilter
    on QueryBuilder<MealPlanDoc, MealPlanDoc, QFilterCondition> {
  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      avgDailyCaloriesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avgDailyCalories',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      avgDailyCaloriesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'avgDailyCalories',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      avgDailyCaloriesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'avgDailyCalories',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      avgDailyCaloriesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'avgDailyCalories',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      avgDailyProteinEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avgDailyProtein',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      avgDailyProteinGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'avgDailyProtein',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      avgDailyProteinLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'avgDailyProtein',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      avgDailyProteinBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'avgDailyProtein',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      durationDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationDays',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      durationDaysGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'durationDays',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      durationDaysLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'durationDays',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      durationDaysBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'durationDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition> goalEqualTo(
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

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition> goalGreaterThan(
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

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition> goalLessThan(
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

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition> goalBetween(
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

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition> goalStartsWith(
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

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition> goalEndsWith(
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

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition> goalContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'goal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition> goalMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'goal',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition> goalIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'goal',
        value: '',
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      goalIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'goal',
        value: '',
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition> idBetween(
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

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition> planJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'planJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      planJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'planJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      planJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'planJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition> planJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'planJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      planJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'planJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      planJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'planJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      planJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'planJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition> planJsonMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'planJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      planJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'planJson',
        value: '',
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      planJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'planJson',
        value: '',
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition> statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition> statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition> statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition> statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition> statusContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition> statusMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      targetDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      targetDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      targetDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      targetDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      userContextSnapshotEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userContextSnapshot',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      userContextSnapshotGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userContextSnapshot',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      userContextSnapshotLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userContextSnapshot',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      userContextSnapshotBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userContextSnapshot',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      userContextSnapshotStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userContextSnapshot',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      userContextSnapshotEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userContextSnapshot',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      userContextSnapshotContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userContextSnapshot',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      userContextSnapshotMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userContextSnapshot',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      userContextSnapshotIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userContextSnapshot',
        value: '',
      ));
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterFilterCondition>
      userContextSnapshotIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userContextSnapshot',
        value: '',
      ));
    });
  }
}

extension MealPlanDocQueryObject
    on QueryBuilder<MealPlanDoc, MealPlanDoc, QFilterCondition> {}

extension MealPlanDocQueryLinks
    on QueryBuilder<MealPlanDoc, MealPlanDoc, QFilterCondition> {}

extension MealPlanDocQuerySortBy
    on QueryBuilder<MealPlanDoc, MealPlanDoc, QSortBy> {
  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy>
      sortByAvgDailyCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgDailyCalories', Sort.asc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy>
      sortByAvgDailyCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgDailyCalories', Sort.desc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy> sortByAvgDailyProtein() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgDailyProtein', Sort.asc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy>
      sortByAvgDailyProteinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgDailyProtein', Sort.desc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy> sortByDurationDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationDays', Sort.asc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy>
      sortByDurationDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationDays', Sort.desc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy> sortByGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goal', Sort.asc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy> sortByGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goal', Sort.desc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy> sortByPlanJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planJson', Sort.asc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy> sortByPlanJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planJson', Sort.desc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy> sortByTargetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDate', Sort.asc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy> sortByTargetDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDate', Sort.desc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy>
      sortByUserContextSnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userContextSnapshot', Sort.asc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy>
      sortByUserContextSnapshotDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userContextSnapshot', Sort.desc);
    });
  }
}

extension MealPlanDocQuerySortThenBy
    on QueryBuilder<MealPlanDoc, MealPlanDoc, QSortThenBy> {
  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy>
      thenByAvgDailyCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgDailyCalories', Sort.asc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy>
      thenByAvgDailyCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgDailyCalories', Sort.desc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy> thenByAvgDailyProtein() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgDailyProtein', Sort.asc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy>
      thenByAvgDailyProteinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgDailyProtein', Sort.desc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy> thenByDurationDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationDays', Sort.asc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy>
      thenByDurationDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationDays', Sort.desc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy> thenByGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goal', Sort.asc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy> thenByGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goal', Sort.desc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy> thenByPlanJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planJson', Sort.asc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy> thenByPlanJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planJson', Sort.desc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy> thenByTargetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDate', Sort.asc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy> thenByTargetDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetDate', Sort.desc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy>
      thenByUserContextSnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userContextSnapshot', Sort.asc);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QAfterSortBy>
      thenByUserContextSnapshotDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userContextSnapshot', Sort.desc);
    });
  }
}

extension MealPlanDocQueryWhereDistinct
    on QueryBuilder<MealPlanDoc, MealPlanDoc, QDistinct> {
  QueryBuilder<MealPlanDoc, MealPlanDoc, QDistinct>
      distinctByAvgDailyCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avgDailyCalories');
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QDistinct>
      distinctByAvgDailyProtein() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avgDailyProtein');
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QDistinct> distinctByDurationDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationDays');
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QDistinct> distinctByGoal(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'goal', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QDistinct> distinctByPlanJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'planJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QDistinct> distinctByTargetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetDate');
    });
  }

  QueryBuilder<MealPlanDoc, MealPlanDoc, QDistinct>
      distinctByUserContextSnapshot({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userContextSnapshot',
          caseSensitive: caseSensitive);
    });
  }
}

extension MealPlanDocQueryProperty
    on QueryBuilder<MealPlanDoc, MealPlanDoc, QQueryProperty> {
  QueryBuilder<MealPlanDoc, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MealPlanDoc, int, QQueryOperations> avgDailyCaloriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avgDailyCalories');
    });
  }

  QueryBuilder<MealPlanDoc, int, QQueryOperations> avgDailyProteinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avgDailyProtein');
    });
  }

  QueryBuilder<MealPlanDoc, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<MealPlanDoc, int, QQueryOperations> durationDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationDays');
    });
  }

  QueryBuilder<MealPlanDoc, String, QQueryOperations> goalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'goal');
    });
  }

  QueryBuilder<MealPlanDoc, String, QQueryOperations> planJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'planJson');
    });
  }

  QueryBuilder<MealPlanDoc, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<MealPlanDoc, DateTime, QQueryOperations> targetDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetDate');
    });
  }

  QueryBuilder<MealPlanDoc, String, QQueryOperations>
      userContextSnapshotProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userContextSnapshot');
    });
  }
}
