// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_doc.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserDocCollection on Isar {
  IsarCollection<UserDoc> get userDocs => this.collection();
}

const UserDocSchema = CollectionSchema(
  name: r'UserDoc',
  id: -5320591025975529541,
  properties: {
    r'activityLevel': PropertySchema(
      id: 0,
      name: r'activityLevel',
      type: IsarType.string,
    ),
    r'ageYears': PropertySchema(
      id: 1,
      name: r'ageYears',
      type: IsarType.long,
    ),
    r'aiContextSummary': PropertySchema(
      id: 2,
      name: r'aiContextSummary',
      type: IsarType.string,
    ),
    r'calorieGoal': PropertySchema(
      id: 3,
      name: r'calorieGoal',
      type: IsarType.long,
    ),
    r'carbGoalG': PropertySchema(
      id: 4,
      name: r'carbGoalG',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 5,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'cuisinePreference': PropertySchema(
      id: 6,
      name: r'cuisinePreference',
      type: IsarType.string,
    ),
    r'dailyInsightGeneratedAt': PropertySchema(
      id: 7,
      name: r'dailyInsightGeneratedAt',
      type: IsarType.dateTime,
    ),
    r'dailyInsightText': PropertySchema(
      id: 8,
      name: r'dailyInsightText',
      type: IsarType.string,
    ),
    r'displayName': PropertySchema(
      id: 9,
      name: r'displayName',
      type: IsarType.string,
    ),
    r'dob': PropertySchema(
      id: 10,
      name: r'dob',
      type: IsarType.dateTime,
    ),
    r'eatingProfileJson': PropertySchema(
      id: 11,
      name: r'eatingProfileJson',
      type: IsarType.string,
    ),
    r'email': PropertySchema(
      id: 12,
      name: r'email',
      type: IsarType.string,
    ),
    r'fatGoalG': PropertySchema(
      id: 13,
      name: r'fatGoalG',
      type: IsarType.long,
    ),
    r'fitnessLevel': PropertySchema(
      id: 14,
      name: r'fitnessLevel',
      type: IsarType.string,
    ),
    r'foodAllergies': PropertySchema(
      id: 15,
      name: r'foodAllergies',
      type: IsarType.stringList,
    ),
    r'gender': PropertySchema(
      id: 16,
      name: r'gender',
      type: IsarType.string,
    ),
    r'habitInsightGeneratedAt': PropertySchema(
      id: 17,
      name: r'habitInsightGeneratedAt',
      type: IsarType.dateTime,
    ),
    r'habitInsightText': PropertySchema(
      id: 18,
      name: r'habitInsightText',
      type: IsarType.string,
    ),
    r'heightCm': PropertySchema(
      id: 19,
      name: r'heightCm',
      type: IsarType.double,
    ),
    r'lastActive': PropertySchema(
      id: 20,
      name: r'lastActive',
      type: IsarType.dateTime,
    ),
    r'mealsPerDay': PropertySchema(
      id: 21,
      name: r'mealsPerDay',
      type: IsarType.long,
    ),
    r'medicalConditions': PropertySchema(
      id: 22,
      name: r'medicalConditions',
      type: IsarType.stringList,
    ),
    r'photoUrl': PropertySchema(
      id: 23,
      name: r'photoUrl',
      type: IsarType.string,
    ),
    r'preferences': PropertySchema(
      id: 24,
      name: r'preferences',
      type: IsarType.object,
      target: r'UserPreferences',
    ),
    r'primaryGoal': PropertySchema(
      id: 25,
      name: r'primaryGoal',
      type: IsarType.string,
    ),
    r'proteinGoalG': PropertySchema(
      id: 26,
      name: r'proteinGoalG',
      type: IsarType.long,
    ),
    r'totalPoints': PropertySchema(
      id: 27,
      name: r'totalPoints',
      type: IsarType.long,
    ),
    r'uid': PropertySchema(
      id: 28,
      name: r'uid',
      type: IsarType.string,
    ),
    r'unlockedAchievements': PropertySchema(
      id: 29,
      name: r'unlockedAchievements',
      type: IsarType.stringList,
    ),
    r'waterGoalMl': PropertySchema(
      id: 30,
      name: r'waterGoalMl',
      type: IsarType.long,
    ),
    r'weeklyAiSummary': PropertySchema(
      id: 31,
      name: r'weeklyAiSummary',
      type: IsarType.string,
    ),
    r'weeklyAiSummaryGeneratedAt': PropertySchema(
      id: 32,
      name: r'weeklyAiSummaryGeneratedAt',
      type: IsarType.dateTime,
    ),
    r'weightKg': PropertySchema(
      id: 33,
      name: r'weightKg',
      type: IsarType.double,
    )
  },
  estimateSize: _userDocEstimateSize,
  serialize: _userDocSerialize,
  deserialize: _userDocDeserialize,
  deserializeProp: _userDocDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'UserPreferences': UserPreferencesSchema},
  getId: _userDocGetId,
  getLinks: _userDocGetLinks,
  attach: _userDocAttach,
  version: '3.1.0+1',
);

int _userDocEstimateSize(
  UserDoc object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.activityLevel.length * 3;
  {
    final value = object.aiContextSummary;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.cuisinePreference.length * 3;
  {
    final value = object.dailyInsightText;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.displayName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.eatingProfileJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.email.length * 3;
  bytesCount += 3 + object.fitnessLevel.length * 3;
  bytesCount += 3 + object.foodAllergies.length * 3;
  {
    for (var i = 0; i < object.foodAllergies.length; i++) {
      final value = object.foodAllergies[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.gender;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.habitInsightText;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.medicalConditions.length * 3;
  {
    for (var i = 0; i < object.medicalConditions.length; i++) {
      final value = object.medicalConditions[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.photoUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 +
      UserPreferencesSchema.estimateSize(
          object.preferences, allOffsets[UserPreferences]!, allOffsets);
  bytesCount += 3 + object.primaryGoal.length * 3;
  bytesCount += 3 + object.uid.length * 3;
  bytesCount += 3 + object.unlockedAchievements.length * 3;
  {
    for (var i = 0; i < object.unlockedAchievements.length; i++) {
      final value = object.unlockedAchievements[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.weeklyAiSummary;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _userDocSerialize(
  UserDoc object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.activityLevel);
  writer.writeLong(offsets[1], object.ageYears);
  writer.writeString(offsets[2], object.aiContextSummary);
  writer.writeLong(offsets[3], object.calorieGoal);
  writer.writeLong(offsets[4], object.carbGoalG);
  writer.writeDateTime(offsets[5], object.createdAt);
  writer.writeString(offsets[6], object.cuisinePreference);
  writer.writeDateTime(offsets[7], object.dailyInsightGeneratedAt);
  writer.writeString(offsets[8], object.dailyInsightText);
  writer.writeString(offsets[9], object.displayName);
  writer.writeDateTime(offsets[10], object.dob);
  writer.writeString(offsets[11], object.eatingProfileJson);
  writer.writeString(offsets[12], object.email);
  writer.writeLong(offsets[13], object.fatGoalG);
  writer.writeString(offsets[14], object.fitnessLevel);
  writer.writeStringList(offsets[15], object.foodAllergies);
  writer.writeString(offsets[16], object.gender);
  writer.writeDateTime(offsets[17], object.habitInsightGeneratedAt);
  writer.writeString(offsets[18], object.habitInsightText);
  writer.writeDouble(offsets[19], object.heightCm);
  writer.writeDateTime(offsets[20], object.lastActive);
  writer.writeLong(offsets[21], object.mealsPerDay);
  writer.writeStringList(offsets[22], object.medicalConditions);
  writer.writeString(offsets[23], object.photoUrl);
  writer.writeObject<UserPreferences>(
    offsets[24],
    allOffsets,
    UserPreferencesSchema.serialize,
    object.preferences,
  );
  writer.writeString(offsets[25], object.primaryGoal);
  writer.writeLong(offsets[26], object.proteinGoalG);
  writer.writeLong(offsets[27], object.totalPoints);
  writer.writeString(offsets[28], object.uid);
  writer.writeStringList(offsets[29], object.unlockedAchievements);
  writer.writeLong(offsets[30], object.waterGoalMl);
  writer.writeString(offsets[31], object.weeklyAiSummary);
  writer.writeDateTime(offsets[32], object.weeklyAiSummaryGeneratedAt);
  writer.writeDouble(offsets[33], object.weightKg);
}

UserDoc _userDocDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserDoc();
  object.activityLevel = reader.readString(offsets[0]);
  object.ageYears = reader.readLong(offsets[1]);
  object.aiContextSummary = reader.readStringOrNull(offsets[2]);
  object.calorieGoal = reader.readLong(offsets[3]);
  object.carbGoalG = reader.readLong(offsets[4]);
  object.createdAt = reader.readDateTime(offsets[5]);
  object.cuisinePreference = reader.readString(offsets[6]);
  object.dailyInsightGeneratedAt = reader.readDateTimeOrNull(offsets[7]);
  object.dailyInsightText = reader.readStringOrNull(offsets[8]);
  object.displayName = reader.readStringOrNull(offsets[9]);
  object.dob = reader.readDateTimeOrNull(offsets[10]);
  object.eatingProfileJson = reader.readStringOrNull(offsets[11]);
  object.email = reader.readString(offsets[12]);
  object.fatGoalG = reader.readLong(offsets[13]);
  object.fitnessLevel = reader.readString(offsets[14]);
  object.foodAllergies = reader.readStringList(offsets[15]) ?? [];
  object.gender = reader.readStringOrNull(offsets[16]);
  object.habitInsightGeneratedAt = reader.readDateTimeOrNull(offsets[17]);
  object.habitInsightText = reader.readStringOrNull(offsets[18]);
  object.heightCm = reader.readDoubleOrNull(offsets[19]);
  object.id = id;
  object.lastActive = reader.readDateTime(offsets[20]);
  object.mealsPerDay = reader.readLong(offsets[21]);
  object.medicalConditions = reader.readStringList(offsets[22]) ?? [];
  object.photoUrl = reader.readStringOrNull(offsets[23]);
  object.preferences = reader.readObjectOrNull<UserPreferences>(
        offsets[24],
        UserPreferencesSchema.deserialize,
        allOffsets,
      ) ??
      UserPreferences();
  object.primaryGoal = reader.readString(offsets[25]);
  object.proteinGoalG = reader.readLong(offsets[26]);
  object.totalPoints = reader.readLong(offsets[27]);
  object.uid = reader.readString(offsets[28]);
  object.unlockedAchievements = reader.readStringList(offsets[29]) ?? [];
  object.waterGoalMl = reader.readLong(offsets[30]);
  object.weeklyAiSummary = reader.readStringOrNull(offsets[31]);
  object.weeklyAiSummaryGeneratedAt = reader.readDateTimeOrNull(offsets[32]);
  object.weightKg = reader.readDoubleOrNull(offsets[33]);
  return object;
}

P _userDocDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readStringList(offset) ?? []) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 18:
      return (reader.readStringOrNull(offset)) as P;
    case 19:
      return (reader.readDoubleOrNull(offset)) as P;
    case 20:
      return (reader.readDateTime(offset)) as P;
    case 21:
      return (reader.readLong(offset)) as P;
    case 22:
      return (reader.readStringList(offset) ?? []) as P;
    case 23:
      return (reader.readStringOrNull(offset)) as P;
    case 24:
      return (reader.readObjectOrNull<UserPreferences>(
            offset,
            UserPreferencesSchema.deserialize,
            allOffsets,
          ) ??
          UserPreferences()) as P;
    case 25:
      return (reader.readString(offset)) as P;
    case 26:
      return (reader.readLong(offset)) as P;
    case 27:
      return (reader.readLong(offset)) as P;
    case 28:
      return (reader.readString(offset)) as P;
    case 29:
      return (reader.readStringList(offset) ?? []) as P;
    case 30:
      return (reader.readLong(offset)) as P;
    case 31:
      return (reader.readStringOrNull(offset)) as P;
    case 32:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 33:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userDocGetId(UserDoc object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userDocGetLinks(UserDoc object) {
  return [];
}

void _userDocAttach(IsarCollection<dynamic> col, Id id, UserDoc object) {
  object.id = id;
}

extension UserDocQueryWhereSort on QueryBuilder<UserDoc, UserDoc, QWhere> {
  QueryBuilder<UserDoc, UserDoc, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserDocQueryWhere on QueryBuilder<UserDoc, UserDoc, QWhereClause> {
  QueryBuilder<UserDoc, UserDoc, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<UserDoc, UserDoc, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterWhereClause> idBetween(
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

extension UserDocQueryFilter
    on QueryBuilder<UserDoc, UserDoc, QFilterCondition> {
  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> activityLevelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activityLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      activityLevelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activityLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> activityLevelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activityLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> activityLevelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activityLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> activityLevelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'activityLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> activityLevelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'activityLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> activityLevelContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'activityLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> activityLevelMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'activityLevel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> activityLevelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activityLevel',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      activityLevelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'activityLevel',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> ageYearsEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ageYears',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> ageYearsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ageYears',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> ageYearsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ageYears',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> ageYearsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ageYears',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      aiContextSummaryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'aiContextSummary',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      aiContextSummaryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'aiContextSummary',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> aiContextSummaryEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiContextSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      aiContextSummaryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiContextSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      aiContextSummaryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiContextSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> aiContextSummaryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiContextSummary',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      aiContextSummaryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aiContextSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      aiContextSummaryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aiContextSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      aiContextSummaryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aiContextSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> aiContextSummaryMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aiContextSummary',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      aiContextSummaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiContextSummary',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      aiContextSummaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aiContextSummary',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> calorieGoalEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'calorieGoal',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> calorieGoalGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'calorieGoal',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> calorieGoalLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'calorieGoal',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> calorieGoalBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'calorieGoal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> carbGoalGEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'carbGoalG',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> carbGoalGGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'carbGoalG',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> carbGoalGLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'carbGoalG',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> carbGoalGBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'carbGoalG',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      cuisinePreferenceEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cuisinePreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      cuisinePreferenceGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cuisinePreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      cuisinePreferenceLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cuisinePreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      cuisinePreferenceBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cuisinePreference',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      cuisinePreferenceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cuisinePreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      cuisinePreferenceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cuisinePreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      cuisinePreferenceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cuisinePreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      cuisinePreferenceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cuisinePreference',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      cuisinePreferenceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cuisinePreference',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      cuisinePreferenceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cuisinePreference',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      dailyInsightGeneratedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dailyInsightGeneratedAt',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      dailyInsightGeneratedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dailyInsightGeneratedAt',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      dailyInsightGeneratedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dailyInsightGeneratedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      dailyInsightGeneratedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dailyInsightGeneratedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      dailyInsightGeneratedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dailyInsightGeneratedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      dailyInsightGeneratedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dailyInsightGeneratedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      dailyInsightTextIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dailyInsightText',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      dailyInsightTextIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dailyInsightText',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> dailyInsightTextEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dailyInsightText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      dailyInsightTextGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dailyInsightText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      dailyInsightTextLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dailyInsightText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> dailyInsightTextBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dailyInsightText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      dailyInsightTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dailyInsightText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      dailyInsightTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dailyInsightText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      dailyInsightTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dailyInsightText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> dailyInsightTextMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dailyInsightText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      dailyInsightTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dailyInsightText',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      dailyInsightTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dailyInsightText',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> displayNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'displayName',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> displayNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'displayName',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> displayNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> displayNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> displayNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> displayNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'displayName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> displayNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> displayNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> displayNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> displayNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'displayName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> displayNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayName',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      displayNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'displayName',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> dobIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dob',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> dobIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dob',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> dobEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dob',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> dobGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dob',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> dobLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dob',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> dobBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dob',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      eatingProfileJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'eatingProfileJson',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      eatingProfileJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'eatingProfileJson',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      eatingProfileJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eatingProfileJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      eatingProfileJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'eatingProfileJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      eatingProfileJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'eatingProfileJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      eatingProfileJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'eatingProfileJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      eatingProfileJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'eatingProfileJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      eatingProfileJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'eatingProfileJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      eatingProfileJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'eatingProfileJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      eatingProfileJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'eatingProfileJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      eatingProfileJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eatingProfileJson',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      eatingProfileJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'eatingProfileJson',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> emailEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> emailGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> emailLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> emailBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'email',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> emailStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> emailEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> emailContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> emailMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'email',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> emailIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'email',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> emailIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'email',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> fatGoalGEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fatGoalG',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> fatGoalGGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fatGoalG',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> fatGoalGLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fatGoalG',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> fatGoalGBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fatGoalG',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> fitnessLevelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fitnessLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> fitnessLevelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fitnessLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> fitnessLevelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fitnessLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> fitnessLevelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fitnessLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> fitnessLevelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fitnessLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> fitnessLevelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fitnessLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> fitnessLevelContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fitnessLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> fitnessLevelMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fitnessLevel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> fitnessLevelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fitnessLevel',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      fitnessLevelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fitnessLevel',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      foodAllergiesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'foodAllergies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      foodAllergiesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'foodAllergies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      foodAllergiesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'foodAllergies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      foodAllergiesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'foodAllergies',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      foodAllergiesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'foodAllergies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      foodAllergiesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'foodAllergies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      foodAllergiesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'foodAllergies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      foodAllergiesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'foodAllergies',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      foodAllergiesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'foodAllergies',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      foodAllergiesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'foodAllergies',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      foodAllergiesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'foodAllergies',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> foodAllergiesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'foodAllergies',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      foodAllergiesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'foodAllergies',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      foodAllergiesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'foodAllergies',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      foodAllergiesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'foodAllergies',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      foodAllergiesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'foodAllergies',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> genderIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'gender',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> genderIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'gender',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> genderEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> genderGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> genderLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> genderBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gender',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> genderStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> genderEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> genderContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> genderMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'gender',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> genderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gender',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> genderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'gender',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      habitInsightGeneratedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'habitInsightGeneratedAt',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      habitInsightGeneratedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'habitInsightGeneratedAt',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      habitInsightGeneratedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'habitInsightGeneratedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      habitInsightGeneratedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'habitInsightGeneratedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      habitInsightGeneratedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'habitInsightGeneratedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      habitInsightGeneratedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'habitInsightGeneratedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      habitInsightTextIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'habitInsightText',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      habitInsightTextIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'habitInsightText',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> habitInsightTextEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'habitInsightText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      habitInsightTextGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'habitInsightText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      habitInsightTextLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'habitInsightText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> habitInsightTextBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'habitInsightText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      habitInsightTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'habitInsightText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      habitInsightTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'habitInsightText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      habitInsightTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'habitInsightText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> habitInsightTextMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'habitInsightText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      habitInsightTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'habitInsightText',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      habitInsightTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'habitInsightText',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> heightCmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'heightCm',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> heightCmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'heightCm',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> heightCmEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'heightCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> heightCmGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'heightCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> heightCmLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'heightCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> heightCmBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'heightCm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> idBetween(
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

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> lastActiveEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastActive',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> lastActiveGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastActive',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> lastActiveLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastActive',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> lastActiveBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastActive',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> mealsPerDayEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mealsPerDay',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> mealsPerDayGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mealsPerDay',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> mealsPerDayLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mealsPerDay',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> mealsPerDayBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mealsPerDay',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      medicalConditionsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'medicalConditions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      medicalConditionsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'medicalConditions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      medicalConditionsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'medicalConditions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      medicalConditionsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'medicalConditions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      medicalConditionsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'medicalConditions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      medicalConditionsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'medicalConditions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      medicalConditionsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'medicalConditions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      medicalConditionsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'medicalConditions',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      medicalConditionsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'medicalConditions',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      medicalConditionsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'medicalConditions',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      medicalConditionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'medicalConditions',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      medicalConditionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'medicalConditions',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      medicalConditionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'medicalConditions',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      medicalConditionsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'medicalConditions',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      medicalConditionsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'medicalConditions',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      medicalConditionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'medicalConditions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> photoUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'photoUrl',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> photoUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'photoUrl',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> photoUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> photoUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'photoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> photoUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'photoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> photoUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'photoUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> photoUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'photoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> photoUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'photoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> photoUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'photoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> photoUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'photoUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> photoUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photoUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> photoUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'photoUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> primaryGoalEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'primaryGoal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> primaryGoalGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'primaryGoal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> primaryGoalLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'primaryGoal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> primaryGoalBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'primaryGoal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> primaryGoalStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'primaryGoal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> primaryGoalEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'primaryGoal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> primaryGoalContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'primaryGoal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> primaryGoalMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'primaryGoal',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> primaryGoalIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'primaryGoal',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      primaryGoalIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'primaryGoal',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> proteinGoalGEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proteinGoalG',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> proteinGoalGGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'proteinGoalG',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> proteinGoalGLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'proteinGoalG',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> proteinGoalGBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'proteinGoalG',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> totalPointsEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalPoints',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> totalPointsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalPoints',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> totalPointsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalPoints',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> totalPointsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalPoints',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> uidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> uidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> uidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> uidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> uidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> uidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> uidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> uidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      unlockedAchievementsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlockedAchievements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      unlockedAchievementsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unlockedAchievements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      unlockedAchievementsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unlockedAchievements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      unlockedAchievementsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unlockedAchievements',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      unlockedAchievementsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'unlockedAchievements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      unlockedAchievementsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'unlockedAchievements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      unlockedAchievementsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'unlockedAchievements',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      unlockedAchievementsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'unlockedAchievements',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      unlockedAchievementsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlockedAchievements',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      unlockedAchievementsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unlockedAchievements',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      unlockedAchievementsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedAchievements',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      unlockedAchievementsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedAchievements',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      unlockedAchievementsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedAchievements',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      unlockedAchievementsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedAchievements',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      unlockedAchievementsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedAchievements',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      unlockedAchievementsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedAchievements',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> waterGoalMlEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'waterGoalMl',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> waterGoalMlGreaterThan(
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

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> waterGoalMlLessThan(
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

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> waterGoalMlBetween(
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

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      weeklyAiSummaryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'weeklyAiSummary',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      weeklyAiSummaryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'weeklyAiSummary',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> weeklyAiSummaryEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weeklyAiSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      weeklyAiSummaryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weeklyAiSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> weeklyAiSummaryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weeklyAiSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> weeklyAiSummaryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weeklyAiSummary',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      weeklyAiSummaryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'weeklyAiSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> weeklyAiSummaryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'weeklyAiSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> weeklyAiSummaryContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'weeklyAiSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> weeklyAiSummaryMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'weeklyAiSummary',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      weeklyAiSummaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weeklyAiSummary',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      weeklyAiSummaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'weeklyAiSummary',
        value: '',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      weeklyAiSummaryGeneratedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'weeklyAiSummaryGeneratedAt',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      weeklyAiSummaryGeneratedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'weeklyAiSummaryGeneratedAt',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      weeklyAiSummaryGeneratedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weeklyAiSummaryGeneratedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      weeklyAiSummaryGeneratedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weeklyAiSummaryGeneratedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      weeklyAiSummaryGeneratedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weeklyAiSummaryGeneratedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition>
      weeklyAiSummaryGeneratedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weeklyAiSummaryGeneratedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> weightKgIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'weightKg',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> weightKgIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'weightKg',
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> weightKgEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> weightKgGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> weightKgLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weightKg',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> weightKgBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weightKg',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension UserDocQueryObject
    on QueryBuilder<UserDoc, UserDoc, QFilterCondition> {
  QueryBuilder<UserDoc, UserDoc, QAfterFilterCondition> preferences(
      FilterQuery<UserPreferences> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'preferences');
    });
  }
}

extension UserDocQueryLinks
    on QueryBuilder<UserDoc, UserDoc, QFilterCondition> {}

extension UserDocQuerySortBy on QueryBuilder<UserDoc, UserDoc, QSortBy> {
  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByActivityLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityLevel', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByActivityLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityLevel', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByAgeYears() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ageYears', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByAgeYearsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ageYears', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByAiContextSummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiContextSummary', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByAiContextSummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiContextSummary', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByCalorieGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calorieGoal', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByCalorieGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calorieGoal', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByCarbGoalG() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbGoalG', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByCarbGoalGDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbGoalG', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByCuisinePreference() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cuisinePreference', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByCuisinePreferenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cuisinePreference', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByDailyInsightGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyInsightGeneratedAt', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy>
      sortByDailyInsightGeneratedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyInsightGeneratedAt', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByDailyInsightText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyInsightText', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByDailyInsightTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyInsightText', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByDob() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dob', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByDobDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dob', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByEatingProfileJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eatingProfileJson', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByEatingProfileJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eatingProfileJson', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByFatGoalG() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatGoalG', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByFatGoalGDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatGoalG', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByFitnessLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fitnessLevel', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByFitnessLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fitnessLevel', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByGender() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByGenderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByHabitInsightGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitInsightGeneratedAt', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy>
      sortByHabitInsightGeneratedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitInsightGeneratedAt', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByHabitInsightText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitInsightText', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByHabitInsightTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitInsightText', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByHeightCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heightCm', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByHeightCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heightCm', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByLastActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastActive', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByLastActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastActive', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByMealsPerDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealsPerDay', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByMealsPerDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealsPerDay', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByPhotoUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoUrl', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByPhotoUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoUrl', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByPrimaryGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryGoal', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByPrimaryGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryGoal', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByProteinGoalG() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinGoalG', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByProteinGoalGDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinGoalG', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByTotalPoints() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPoints', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByTotalPointsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPoints', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByWaterGoalMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterGoalMl', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByWaterGoalMlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterGoalMl', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByWeeklyAiSummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyAiSummary', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByWeeklyAiSummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyAiSummary', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy>
      sortByWeeklyAiSummaryGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyAiSummaryGeneratedAt', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy>
      sortByWeeklyAiSummaryGeneratedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyAiSummaryGeneratedAt', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> sortByWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.desc);
    });
  }
}

extension UserDocQuerySortThenBy
    on QueryBuilder<UserDoc, UserDoc, QSortThenBy> {
  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByActivityLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityLevel', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByActivityLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityLevel', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByAgeYears() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ageYears', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByAgeYearsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ageYears', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByAiContextSummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiContextSummary', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByAiContextSummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiContextSummary', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByCalorieGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calorieGoal', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByCalorieGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calorieGoal', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByCarbGoalG() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbGoalG', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByCarbGoalGDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbGoalG', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByCuisinePreference() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cuisinePreference', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByCuisinePreferenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cuisinePreference', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByDailyInsightGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyInsightGeneratedAt', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy>
      thenByDailyInsightGeneratedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyInsightGeneratedAt', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByDailyInsightText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyInsightText', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByDailyInsightTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyInsightText', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByDob() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dob', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByDobDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dob', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByEatingProfileJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eatingProfileJson', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByEatingProfileJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eatingProfileJson', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByFatGoalG() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatGoalG', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByFatGoalGDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatGoalG', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByFitnessLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fitnessLevel', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByFitnessLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fitnessLevel', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByGender() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByGenderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByHabitInsightGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitInsightGeneratedAt', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy>
      thenByHabitInsightGeneratedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitInsightGeneratedAt', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByHabitInsightText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitInsightText', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByHabitInsightTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'habitInsightText', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByHeightCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heightCm', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByHeightCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heightCm', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByLastActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastActive', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByLastActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastActive', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByMealsPerDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealsPerDay', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByMealsPerDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealsPerDay', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByPhotoUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoUrl', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByPhotoUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoUrl', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByPrimaryGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryGoal', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByPrimaryGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryGoal', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByProteinGoalG() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinGoalG', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByProteinGoalGDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinGoalG', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByTotalPoints() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPoints', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByTotalPointsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPoints', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByWaterGoalMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterGoalMl', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByWaterGoalMlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waterGoalMl', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByWeeklyAiSummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyAiSummary', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByWeeklyAiSummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyAiSummary', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy>
      thenByWeeklyAiSummaryGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyAiSummaryGeneratedAt', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy>
      thenByWeeklyAiSummaryGeneratedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weeklyAiSummaryGeneratedAt', Sort.desc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.asc);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QAfterSortBy> thenByWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.desc);
    });
  }
}

extension UserDocQueryWhereDistinct
    on QueryBuilder<UserDoc, UserDoc, QDistinct> {
  QueryBuilder<UserDoc, UserDoc, QDistinct> distinctByActivityLevel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activityLevel',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QDistinct> distinctByAgeYears() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ageYears');
    });
  }

  QueryBuilder<UserDoc, UserDoc, QDistinct> distinctByAiContextSummary(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiContextSummary',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QDistinct> distinctByCalorieGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'calorieGoal');
    });
  }

  QueryBuilder<UserDoc, UserDoc, QDistinct> distinctByCarbGoalG() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'carbGoalG');
    });
  }

  QueryBuilder<UserDoc, UserDoc, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<UserDoc, UserDoc, QDistinct> distinctByCuisinePreference(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cuisinePreference',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QDistinct>
      distinctByDailyInsightGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dailyInsightGeneratedAt');
    });
  }

  QueryBuilder<UserDoc, UserDoc, QDistinct> distinctByDailyInsightText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dailyInsightText',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QDistinct> distinctByDisplayName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QDistinct> distinctByDob() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dob');
    });
  }

  QueryBuilder<UserDoc, UserDoc, QDistinct> distinctByEatingProfileJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'eatingProfileJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QDistinct> distinctByEmail(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'email', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QDistinct> distinctByFatGoalG() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fatGoalG');
    });
  }

  QueryBuilder<UserDoc, UserDoc, QDistinct> distinctByFitnessLevel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fitnessLevel', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QDistinct> distinctByFoodAllergies() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'foodAllergies');
    });
  }

  QueryBuilder<UserDoc, UserDoc, QDistinct> distinctByGender(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gender', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QDistinct>
      distinctByHabitInsightGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'habitInsightGeneratedAt');
    });
  }

  QueryBuilder<UserDoc, UserDoc, QDistinct> distinctByHabitInsightText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'habitInsightText',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QDistinct> distinctByHeightCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'heightCm');
    });
  }

  QueryBuilder<UserDoc, UserDoc, QDistinct> distinctByLastActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastActive');
    });
  }

  QueryBuilder<UserDoc, UserDoc, QDistinct> distinctByMealsPerDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mealsPerDay');
    });
  }

  QueryBuilder<UserDoc, UserDoc, QDistinct> distinctByMedicalConditions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'medicalConditions');
    });
  }

  QueryBuilder<UserDoc, UserDoc, QDistinct> distinctByPhotoUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'photoUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QDistinct> distinctByPrimaryGoal(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'primaryGoal', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QDistinct> distinctByProteinGoalG() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proteinGoalG');
    });
  }

  QueryBuilder<UserDoc, UserDoc, QDistinct> distinctByTotalPoints() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalPoints');
    });
  }

  QueryBuilder<UserDoc, UserDoc, QDistinct> distinctByUid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QDistinct> distinctByUnlockedAchievements() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unlockedAchievements');
    });
  }

  QueryBuilder<UserDoc, UserDoc, QDistinct> distinctByWaterGoalMl() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'waterGoalMl');
    });
  }

  QueryBuilder<UserDoc, UserDoc, QDistinct> distinctByWeeklyAiSummary(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weeklyAiSummary',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserDoc, UserDoc, QDistinct>
      distinctByWeeklyAiSummaryGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weeklyAiSummaryGeneratedAt');
    });
  }

  QueryBuilder<UserDoc, UserDoc, QDistinct> distinctByWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weightKg');
    });
  }
}

extension UserDocQueryProperty
    on QueryBuilder<UserDoc, UserDoc, QQueryProperty> {
  QueryBuilder<UserDoc, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserDoc, String, QQueryOperations> activityLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activityLevel');
    });
  }

  QueryBuilder<UserDoc, int, QQueryOperations> ageYearsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ageYears');
    });
  }

  QueryBuilder<UserDoc, String?, QQueryOperations> aiContextSummaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiContextSummary');
    });
  }

  QueryBuilder<UserDoc, int, QQueryOperations> calorieGoalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'calorieGoal');
    });
  }

  QueryBuilder<UserDoc, int, QQueryOperations> carbGoalGProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'carbGoalG');
    });
  }

  QueryBuilder<UserDoc, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<UserDoc, String, QQueryOperations> cuisinePreferenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cuisinePreference');
    });
  }

  QueryBuilder<UserDoc, DateTime?, QQueryOperations>
      dailyInsightGeneratedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dailyInsightGeneratedAt');
    });
  }

  QueryBuilder<UserDoc, String?, QQueryOperations> dailyInsightTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dailyInsightText');
    });
  }

  QueryBuilder<UserDoc, String?, QQueryOperations> displayNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayName');
    });
  }

  QueryBuilder<UserDoc, DateTime?, QQueryOperations> dobProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dob');
    });
  }

  QueryBuilder<UserDoc, String?, QQueryOperations> eatingProfileJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'eatingProfileJson');
    });
  }

  QueryBuilder<UserDoc, String, QQueryOperations> emailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'email');
    });
  }

  QueryBuilder<UserDoc, int, QQueryOperations> fatGoalGProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fatGoalG');
    });
  }

  QueryBuilder<UserDoc, String, QQueryOperations> fitnessLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fitnessLevel');
    });
  }

  QueryBuilder<UserDoc, List<String>, QQueryOperations>
      foodAllergiesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'foodAllergies');
    });
  }

  QueryBuilder<UserDoc, String?, QQueryOperations> genderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gender');
    });
  }

  QueryBuilder<UserDoc, DateTime?, QQueryOperations>
      habitInsightGeneratedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'habitInsightGeneratedAt');
    });
  }

  QueryBuilder<UserDoc, String?, QQueryOperations> habitInsightTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'habitInsightText');
    });
  }

  QueryBuilder<UserDoc, double?, QQueryOperations> heightCmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'heightCm');
    });
  }

  QueryBuilder<UserDoc, DateTime, QQueryOperations> lastActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastActive');
    });
  }

  QueryBuilder<UserDoc, int, QQueryOperations> mealsPerDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mealsPerDay');
    });
  }

  QueryBuilder<UserDoc, List<String>, QQueryOperations>
      medicalConditionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'medicalConditions');
    });
  }

  QueryBuilder<UserDoc, String?, QQueryOperations> photoUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'photoUrl');
    });
  }

  QueryBuilder<UserDoc, UserPreferences, QQueryOperations>
      preferencesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'preferences');
    });
  }

  QueryBuilder<UserDoc, String, QQueryOperations> primaryGoalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'primaryGoal');
    });
  }

  QueryBuilder<UserDoc, int, QQueryOperations> proteinGoalGProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proteinGoalG');
    });
  }

  QueryBuilder<UserDoc, int, QQueryOperations> totalPointsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalPoints');
    });
  }

  QueryBuilder<UserDoc, String, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }

  QueryBuilder<UserDoc, List<String>, QQueryOperations>
      unlockedAchievementsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unlockedAchievements');
    });
  }

  QueryBuilder<UserDoc, int, QQueryOperations> waterGoalMlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'waterGoalMl');
    });
  }

  QueryBuilder<UserDoc, String?, QQueryOperations> weeklyAiSummaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weeklyAiSummary');
    });
  }

  QueryBuilder<UserDoc, DateTime?, QQueryOperations>
      weeklyAiSummaryGeneratedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weeklyAiSummaryGeneratedAt');
    });
  }

  QueryBuilder<UserDoc, double?, QQueryOperations> weightKgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weightKg');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const UserPreferencesSchema = Schema(
  name: r'UserPreferences',
  id: -7545901164102504045,
  properties: {
    r'dietary': PropertySchema(
      id: 0,
      name: r'dietary',
      type: IsarType.stringList,
    ),
    r'habitRemindersEnabled': PropertySchema(
      id: 1,
      name: r'habitRemindersEnabled',
      type: IsarType.bool,
    ),
    r'notificationsEnabled': PropertySchema(
      id: 2,
      name: r'notificationsEnabled',
      type: IsarType.bool,
    ),
    r'theme': PropertySchema(
      id: 3,
      name: r'theme',
      type: IsarType.string,
    ),
    r'unitSystem': PropertySchema(
      id: 4,
      name: r'unitSystem',
      type: IsarType.string,
    ),
    r'waterRemindersEnabled': PropertySchema(
      id: 5,
      name: r'waterRemindersEnabled',
      type: IsarType.bool,
    )
  },
  estimateSize: _userPreferencesEstimateSize,
  serialize: _userPreferencesSerialize,
  deserialize: _userPreferencesDeserialize,
  deserializeProp: _userPreferencesDeserializeProp,
);

int _userPreferencesEstimateSize(
  UserPreferences object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.dietary.length * 3;
  {
    for (var i = 0; i < object.dietary.length; i++) {
      final value = object.dietary[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.theme.length * 3;
  bytesCount += 3 + object.unitSystem.length * 3;
  return bytesCount;
}

void _userPreferencesSerialize(
  UserPreferences object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.dietary);
  writer.writeBool(offsets[1], object.habitRemindersEnabled);
  writer.writeBool(offsets[2], object.notificationsEnabled);
  writer.writeString(offsets[3], object.theme);
  writer.writeString(offsets[4], object.unitSystem);
  writer.writeBool(offsets[5], object.waterRemindersEnabled);
}

UserPreferences _userPreferencesDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserPreferences();
  object.dietary = reader.readStringList(offsets[0]) ?? [];
  object.habitRemindersEnabled = reader.readBool(offsets[1]);
  object.notificationsEnabled = reader.readBool(offsets[2]);
  object.theme = reader.readString(offsets[3]);
  object.unitSystem = reader.readString(offsets[4]);
  object.waterRemindersEnabled = reader.readBool(offsets[5]);
  return object;
}

P _userPreferencesDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension UserPreferencesQueryFilter
    on QueryBuilder<UserPreferences, UserPreferences, QFilterCondition> {
  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      dietaryElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dietary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      dietaryElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dietary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      dietaryElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dietary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      dietaryElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dietary',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      dietaryElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dietary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      dietaryElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dietary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      dietaryElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dietary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      dietaryElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dietary',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      dietaryElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dietary',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      dietaryElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dietary',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      dietaryLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dietary',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      dietaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dietary',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      dietaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dietary',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      dietaryLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dietary',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      dietaryLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dietary',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      dietaryLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'dietary',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      habitRemindersEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'habitRemindersEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      notificationsEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notificationsEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      themeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'theme',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      themeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'theme',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      themeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'theme',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      themeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'theme',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      themeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'theme',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      themeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'theme',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      themeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'theme',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      themeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'theme',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      themeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'theme',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      themeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'theme',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      unitSystemEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unitSystem',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      unitSystemGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unitSystem',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      unitSystemLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unitSystem',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      unitSystemBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unitSystem',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      unitSystemStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'unitSystem',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      unitSystemEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'unitSystem',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      unitSystemContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'unitSystem',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      unitSystemMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'unitSystem',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      unitSystemIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unitSystem',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      unitSystemIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unitSystem',
        value: '',
      ));
    });
  }

  QueryBuilder<UserPreferences, UserPreferences, QAfterFilterCondition>
      waterRemindersEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'waterRemindersEnabled',
        value: value,
      ));
    });
  }
}

extension UserPreferencesQueryObject
    on QueryBuilder<UserPreferences, UserPreferences, QFilterCondition> {}
