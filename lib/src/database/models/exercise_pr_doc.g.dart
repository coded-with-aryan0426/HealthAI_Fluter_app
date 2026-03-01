// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_pr_doc.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetExercisePRDocCollection on Isar {
  IsarCollection<ExercisePRDoc> get exercisePRDocs => this.collection();
}

const ExercisePRDocSchema = CollectionSchema(
  name: r'ExercisePRDoc',
  id: 6523226572942992271,
  properties: {
    r'achievedAt': PropertySchema(
      id: 0,
      name: r'achievedAt',
      type: IsarType.dateTime,
    ),
    r'estimated1RMKg': PropertySchema(
      id: 1,
      name: r'estimated1RMKg',
      type: IsarType.double,
    ),
    r'exerciseName': PropertySchema(
      id: 2,
      name: r'exerciseName',
      type: IsarType.string,
    ),
    r'maxReps': PropertySchema(
      id: 3,
      name: r'maxReps',
      type: IsarType.long,
    ),
    r'maxWeightKg': PropertySchema(
      id: 4,
      name: r'maxWeightKg',
      type: IsarType.double,
    )
  },
  estimateSize: _exercisePRDocEstimateSize,
  serialize: _exercisePRDocSerialize,
  deserialize: _exercisePRDocDeserialize,
  deserializeProp: _exercisePRDocDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _exercisePRDocGetId,
  getLinks: _exercisePRDocGetLinks,
  attach: _exercisePRDocAttach,
  version: '3.1.0+1',
);

int _exercisePRDocEstimateSize(
  ExercisePRDoc object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.exerciseName.length * 3;
  return bytesCount;
}

void _exercisePRDocSerialize(
  ExercisePRDoc object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.achievedAt);
  writer.writeDouble(offsets[1], object.estimated1RMKg);
  writer.writeString(offsets[2], object.exerciseName);
  writer.writeLong(offsets[3], object.maxReps);
  writer.writeDouble(offsets[4], object.maxWeightKg);
}

ExercisePRDoc _exercisePRDocDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ExercisePRDoc();
  object.achievedAt = reader.readDateTime(offsets[0]);
  object.estimated1RMKg = reader.readDouble(offsets[1]);
  object.exerciseName = reader.readString(offsets[2]);
  object.id = id;
  object.maxReps = reader.readLong(offsets[3]);
  object.maxWeightKg = reader.readDouble(offsets[4]);
  return object;
}

P _exercisePRDocDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _exercisePRDocGetId(ExercisePRDoc object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _exercisePRDocGetLinks(ExercisePRDoc object) {
  return [];
}

void _exercisePRDocAttach(
    IsarCollection<dynamic> col, Id id, ExercisePRDoc object) {
  object.id = id;
}

extension ExercisePRDocQueryWhereSort
    on QueryBuilder<ExercisePRDoc, ExercisePRDoc, QWhere> {
  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ExercisePRDocQueryWhere
    on QueryBuilder<ExercisePRDoc, ExercisePRDoc, QWhereClause> {
  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterWhereClause> idBetween(
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

extension ExercisePRDocQueryFilter
    on QueryBuilder<ExercisePRDoc, ExercisePRDoc, QFilterCondition> {
  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterFilterCondition>
      achievedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'achievedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterFilterCondition>
      achievedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'achievedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterFilterCondition>
      achievedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'achievedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterFilterCondition>
      achievedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'achievedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterFilterCondition>
      estimated1RMKgEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estimated1RMKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterFilterCondition>
      estimated1RMKgGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'estimated1RMKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterFilterCondition>
      estimated1RMKgLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'estimated1RMKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterFilterCondition>
      estimated1RMKgBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'estimated1RMKg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterFilterCondition>
      exerciseNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'exerciseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterFilterCondition>
      exerciseNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'exerciseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterFilterCondition>
      exerciseNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'exerciseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterFilterCondition>
      exerciseNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'exerciseName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterFilterCondition>
      exerciseNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'exerciseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterFilterCondition>
      exerciseNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'exerciseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterFilterCondition>
      exerciseNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'exerciseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterFilterCondition>
      exerciseNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'exerciseName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterFilterCondition>
      exerciseNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'exerciseName',
        value: '',
      ));
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterFilterCondition>
      exerciseNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'exerciseName',
        value: '',
      ));
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterFilterCondition>
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

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterFilterCondition>
      maxRepsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxReps',
        value: value,
      ));
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterFilterCondition>
      maxRepsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxReps',
        value: value,
      ));
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterFilterCondition>
      maxRepsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxReps',
        value: value,
      ));
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterFilterCondition>
      maxRepsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxReps',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterFilterCondition>
      maxWeightKgEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxWeightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterFilterCondition>
      maxWeightKgGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxWeightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterFilterCondition>
      maxWeightKgLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxWeightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterFilterCondition>
      maxWeightKgBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxWeightKg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension ExercisePRDocQueryObject
    on QueryBuilder<ExercisePRDoc, ExercisePRDoc, QFilterCondition> {}

extension ExercisePRDocQueryLinks
    on QueryBuilder<ExercisePRDoc, ExercisePRDoc, QFilterCondition> {}

extension ExercisePRDocQuerySortBy
    on QueryBuilder<ExercisePRDoc, ExercisePRDoc, QSortBy> {
  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterSortBy> sortByAchievedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'achievedAt', Sort.asc);
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterSortBy>
      sortByAchievedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'achievedAt', Sort.desc);
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterSortBy>
      sortByEstimated1RMKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimated1RMKg', Sort.asc);
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterSortBy>
      sortByEstimated1RMKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimated1RMKg', Sort.desc);
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterSortBy>
      sortByExerciseName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseName', Sort.asc);
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterSortBy>
      sortByExerciseNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseName', Sort.desc);
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterSortBy> sortByMaxReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxReps', Sort.asc);
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterSortBy> sortByMaxRepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxReps', Sort.desc);
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterSortBy> sortByMaxWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxWeightKg', Sort.asc);
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterSortBy>
      sortByMaxWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxWeightKg', Sort.desc);
    });
  }
}

extension ExercisePRDocQuerySortThenBy
    on QueryBuilder<ExercisePRDoc, ExercisePRDoc, QSortThenBy> {
  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterSortBy> thenByAchievedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'achievedAt', Sort.asc);
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterSortBy>
      thenByAchievedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'achievedAt', Sort.desc);
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterSortBy>
      thenByEstimated1RMKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimated1RMKg', Sort.asc);
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterSortBy>
      thenByEstimated1RMKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimated1RMKg', Sort.desc);
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterSortBy>
      thenByExerciseName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseName', Sort.asc);
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterSortBy>
      thenByExerciseNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseName', Sort.desc);
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterSortBy> thenByMaxReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxReps', Sort.asc);
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterSortBy> thenByMaxRepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxReps', Sort.desc);
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterSortBy> thenByMaxWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxWeightKg', Sort.asc);
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QAfterSortBy>
      thenByMaxWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxWeightKg', Sort.desc);
    });
  }
}

extension ExercisePRDocQueryWhereDistinct
    on QueryBuilder<ExercisePRDoc, ExercisePRDoc, QDistinct> {
  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QDistinct> distinctByAchievedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'achievedAt');
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QDistinct>
      distinctByEstimated1RMKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estimated1RMKg');
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QDistinct> distinctByExerciseName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'exerciseName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QDistinct> distinctByMaxReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxReps');
    });
  }

  QueryBuilder<ExercisePRDoc, ExercisePRDoc, QDistinct>
      distinctByMaxWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxWeightKg');
    });
  }
}

extension ExercisePRDocQueryProperty
    on QueryBuilder<ExercisePRDoc, ExercisePRDoc, QQueryProperty> {
  QueryBuilder<ExercisePRDoc, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ExercisePRDoc, DateTime, QQueryOperations> achievedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'achievedAt');
    });
  }

  QueryBuilder<ExercisePRDoc, double, QQueryOperations>
      estimated1RMKgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estimated1RMKg');
    });
  }

  QueryBuilder<ExercisePRDoc, String, QQueryOperations> exerciseNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'exerciseName');
    });
  }

  QueryBuilder<ExercisePRDoc, int, QQueryOperations> maxRepsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxReps');
    });
  }

  QueryBuilder<ExercisePRDoc, double, QQueryOperations> maxWeightKgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxWeightKg');
    });
  }
}
