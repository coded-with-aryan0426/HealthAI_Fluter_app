// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_doc.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMealDocCollection on Isar {
  IsarCollection<MealDoc> get mealDocs => this.collection();
}

const MealDocSchema = CollectionSchema(
  name: r'MealDoc',
  id: 1311895663935999561,
  properties: {
    r'aiGenerated': PropertySchema(
      id: 0,
      name: r'aiGenerated',
      type: IsarType.bool,
    ),
    r'barcode': PropertySchema(
      id: 1,
      name: r'barcode',
      type: IsarType.string,
    ),
    r'calciumMg': PropertySchema(
      id: 2,
      name: r'calciumMg',
      type: IsarType.double,
    ),
    r'calories': PropertySchema(
      id: 3,
      name: r'calories',
      type: IsarType.long,
    ),
    r'carbsGrams': PropertySchema(
      id: 4,
      name: r'carbsGrams',
      type: IsarType.long,
    ),
    r'dateLogged': PropertySchema(
      id: 5,
      name: r'dateLogged',
      type: IsarType.dateTime,
    ),
    r'fatGrams': PropertySchema(
      id: 6,
      name: r'fatGrams',
      type: IsarType.long,
    ),
    r'fiberGrams': PropertySchema(
      id: 7,
      name: r'fiberGrams',
      type: IsarType.double,
    ),
    r'healthScore': PropertySchema(
      id: 8,
      name: r'healthScore',
      type: IsarType.double,
    ),
    r'imageLocalPath': PropertySchema(
      id: 9,
      name: r'imageLocalPath',
      type: IsarType.string,
    ),
    r'imageUrl': PropertySchema(
      id: 10,
      name: r'imageUrl',
      type: IsarType.string,
    ),
    r'ingredientsDetected': PropertySchema(
      id: 11,
      name: r'ingredientsDetected',
      type: IsarType.stringList,
    ),
    r'ironMg': PropertySchema(
      id: 12,
      name: r'ironMg',
      type: IsarType.double,
    ),
    r'mealType': PropertySchema(
      id: 13,
      name: r'mealType',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 14,
      name: r'name',
      type: IsarType.string,
    ),
    r'planned': PropertySchema(
      id: 15,
      name: r'planned',
      type: IsarType.bool,
    ),
    r'portionMultiplier': PropertySchema(
      id: 16,
      name: r'portionMultiplier',
      type: IsarType.double,
    ),
    r'potassiumMg': PropertySchema(
      id: 17,
      name: r'potassiumMg',
      type: IsarType.double,
    ),
    r'proteinGrams': PropertySchema(
      id: 18,
      name: r'proteinGrams',
      type: IsarType.long,
    ),
    r'saturatedFatGrams': PropertySchema(
      id: 19,
      name: r'saturatedFatGrams',
      type: IsarType.double,
    ),
    r'sodiumMg': PropertySchema(
      id: 20,
      name: r'sodiumMg',
      type: IsarType.double,
    ),
    r'source': PropertySchema(
      id: 21,
      name: r'source',
      type: IsarType.string,
    ),
    r'sugarGrams': PropertySchema(
      id: 22,
      name: r'sugarGrams',
      type: IsarType.double,
    ),
    r'userApproved': PropertySchema(
      id: 23,
      name: r'userApproved',
      type: IsarType.bool,
    ),
    r'userNote': PropertySchema(
      id: 24,
      name: r'userNote',
      type: IsarType.string,
    ),
    r'vitaminCMg': PropertySchema(
      id: 25,
      name: r'vitaminCMg',
      type: IsarType.double,
    ),
    r'vitaminDMcg': PropertySchema(
      id: 26,
      name: r'vitaminDMcg',
      type: IsarType.double,
    )
  },
  estimateSize: _mealDocEstimateSize,
  serialize: _mealDocSerialize,
  deserialize: _mealDocDeserialize,
  deserializeProp: _mealDocDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _mealDocGetId,
  getLinks: _mealDocGetLinks,
  attach: _mealDocAttach,
  version: '3.1.0+1',
);

int _mealDocEstimateSize(
  MealDoc object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.barcode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.imageLocalPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.imageUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.ingredientsDetected.length * 3;
  {
    for (var i = 0; i < object.ingredientsDetected.length; i++) {
      final value = object.ingredientsDetected[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.mealType.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.source.length * 3;
  {
    final value = object.userNote;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _mealDocSerialize(
  MealDoc object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.aiGenerated);
  writer.writeString(offsets[1], object.barcode);
  writer.writeDouble(offsets[2], object.calciumMg);
  writer.writeLong(offsets[3], object.calories);
  writer.writeLong(offsets[4], object.carbsGrams);
  writer.writeDateTime(offsets[5], object.dateLogged);
  writer.writeLong(offsets[6], object.fatGrams);
  writer.writeDouble(offsets[7], object.fiberGrams);
  writer.writeDouble(offsets[8], object.healthScore);
  writer.writeString(offsets[9], object.imageLocalPath);
  writer.writeString(offsets[10], object.imageUrl);
  writer.writeStringList(offsets[11], object.ingredientsDetected);
  writer.writeDouble(offsets[12], object.ironMg);
  writer.writeString(offsets[13], object.mealType);
  writer.writeString(offsets[14], object.name);
  writer.writeBool(offsets[15], object.planned);
  writer.writeDouble(offsets[16], object.portionMultiplier);
  writer.writeDouble(offsets[17], object.potassiumMg);
  writer.writeLong(offsets[18], object.proteinGrams);
  writer.writeDouble(offsets[19], object.saturatedFatGrams);
  writer.writeDouble(offsets[20], object.sodiumMg);
  writer.writeString(offsets[21], object.source);
  writer.writeDouble(offsets[22], object.sugarGrams);
  writer.writeBool(offsets[23], object.userApproved);
  writer.writeString(offsets[24], object.userNote);
  writer.writeDouble(offsets[25], object.vitaminCMg);
  writer.writeDouble(offsets[26], object.vitaminDMcg);
}

MealDoc _mealDocDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MealDoc();
  object.aiGenerated = reader.readBool(offsets[0]);
  object.barcode = reader.readStringOrNull(offsets[1]);
  object.calciumMg = reader.readDouble(offsets[2]);
  object.calories = reader.readLong(offsets[3]);
  object.carbsGrams = reader.readLong(offsets[4]);
  object.dateLogged = reader.readDateTime(offsets[5]);
  object.fatGrams = reader.readLong(offsets[6]);
  object.fiberGrams = reader.readDouble(offsets[7]);
  object.healthScore = reader.readDouble(offsets[8]);
  object.id = id;
  object.imageLocalPath = reader.readStringOrNull(offsets[9]);
  object.imageUrl = reader.readStringOrNull(offsets[10]);
  object.ingredientsDetected = reader.readStringList(offsets[11]) ?? [];
  object.ironMg = reader.readDouble(offsets[12]);
  object.mealType = reader.readString(offsets[13]);
  object.name = reader.readString(offsets[14]);
  object.planned = reader.readBool(offsets[15]);
  object.portionMultiplier = reader.readDouble(offsets[16]);
  object.potassiumMg = reader.readDouble(offsets[17]);
  object.proteinGrams = reader.readLong(offsets[18]);
  object.saturatedFatGrams = reader.readDouble(offsets[19]);
  object.sodiumMg = reader.readDouble(offsets[20]);
  object.source = reader.readString(offsets[21]);
  object.sugarGrams = reader.readDouble(offsets[22]);
  object.userApproved = reader.readBoolOrNull(offsets[23]);
  object.userNote = reader.readStringOrNull(offsets[24]);
  object.vitaminCMg = reader.readDouble(offsets[25]);
  object.vitaminDMcg = reader.readDouble(offsets[26]);
  return object;
}

P _mealDocDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readStringList(offset) ?? []) as P;
    case 12:
      return (reader.readDouble(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readBool(offset)) as P;
    case 16:
      return (reader.readDouble(offset)) as P;
    case 17:
      return (reader.readDouble(offset)) as P;
    case 18:
      return (reader.readLong(offset)) as P;
    case 19:
      return (reader.readDouble(offset)) as P;
    case 20:
      return (reader.readDouble(offset)) as P;
    case 21:
      return (reader.readString(offset)) as P;
    case 22:
      return (reader.readDouble(offset)) as P;
    case 23:
      return (reader.readBoolOrNull(offset)) as P;
    case 24:
      return (reader.readStringOrNull(offset)) as P;
    case 25:
      return (reader.readDouble(offset)) as P;
    case 26:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _mealDocGetId(MealDoc object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _mealDocGetLinks(MealDoc object) {
  return [];
}

void _mealDocAttach(IsarCollection<dynamic> col, Id id, MealDoc object) {
  object.id = id;
}

extension MealDocQueryWhereSort on QueryBuilder<MealDoc, MealDoc, QWhere> {
  QueryBuilder<MealDoc, MealDoc, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MealDocQueryWhere on QueryBuilder<MealDoc, MealDoc, QWhereClause> {
  QueryBuilder<MealDoc, MealDoc, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<MealDoc, MealDoc, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterWhereClause> idBetween(
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

extension MealDocQueryFilter
    on QueryBuilder<MealDoc, MealDoc, QFilterCondition> {
  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> aiGeneratedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiGenerated',
        value: value,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> barcodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'barcode',
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> barcodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'barcode',
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> barcodeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'barcode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> barcodeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'barcode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> barcodeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'barcode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> barcodeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'barcode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> barcodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'barcode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> barcodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'barcode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> barcodeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'barcode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> barcodeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'barcode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> barcodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'barcode',
        value: '',
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> barcodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'barcode',
        value: '',
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> calciumMgEqualTo(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> calciumMgGreaterThan(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> calciumMgLessThan(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> calciumMgBetween(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> caloriesEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'calories',
        value: value,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> caloriesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'calories',
        value: value,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> caloriesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'calories',
        value: value,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> caloriesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'calories',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> carbsGramsEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'carbsGrams',
        value: value,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> carbsGramsGreaterThan(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> carbsGramsLessThan(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> carbsGramsBetween(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> dateLoggedEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateLogged',
        value: value,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> dateLoggedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateLogged',
        value: value,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> dateLoggedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateLogged',
        value: value,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> dateLoggedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateLogged',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> fatGramsEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fatGrams',
        value: value,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> fatGramsGreaterThan(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> fatGramsLessThan(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> fatGramsBetween(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> fiberGramsEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fiberGrams',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> fiberGramsGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fiberGrams',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> fiberGramsLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fiberGrams',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> fiberGramsBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fiberGrams',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> healthScoreEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'healthScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> healthScoreGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'healthScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> healthScoreLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'healthScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> healthScoreBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'healthScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> idBetween(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> imageLocalPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'imageLocalPath',
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition>
      imageLocalPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'imageLocalPath',
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> imageLocalPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition>
      imageLocalPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imageLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> imageLocalPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imageLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> imageLocalPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imageLocalPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition>
      imageLocalPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imageLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> imageLocalPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imageLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> imageLocalPathContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imageLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> imageLocalPathMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imageLocalPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition>
      imageLocalPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageLocalPath',
        value: '',
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition>
      imageLocalPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imageLocalPath',
        value: '',
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> imageUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'imageUrl',
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> imageUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'imageUrl',
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> imageUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> imageUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> imageUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> imageUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imageUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> imageUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> imageUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> imageUrlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> imageUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imageUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> imageUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> imageUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition>
      ingredientsDetectedElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ingredientsDetected',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition>
      ingredientsDetectedElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ingredientsDetected',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition>
      ingredientsDetectedElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ingredientsDetected',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition>
      ingredientsDetectedElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ingredientsDetected',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition>
      ingredientsDetectedElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ingredientsDetected',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition>
      ingredientsDetectedElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ingredientsDetected',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition>
      ingredientsDetectedElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ingredientsDetected',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition>
      ingredientsDetectedElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ingredientsDetected',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition>
      ingredientsDetectedElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ingredientsDetected',
        value: '',
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition>
      ingredientsDetectedElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ingredientsDetected',
        value: '',
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition>
      ingredientsDetectedLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ingredientsDetected',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition>
      ingredientsDetectedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ingredientsDetected',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition>
      ingredientsDetectedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ingredientsDetected',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition>
      ingredientsDetectedLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ingredientsDetected',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition>
      ingredientsDetectedLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ingredientsDetected',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition>
      ingredientsDetectedLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ingredientsDetected',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> ironMgEqualTo(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> ironMgGreaterThan(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> ironMgLessThan(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> ironMgBetween(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> mealTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mealType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> mealTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mealType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> mealTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mealType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> mealTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mealType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> mealTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mealType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> mealTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mealType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> mealTypeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mealType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> mealTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mealType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> mealTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mealType',
        value: '',
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> mealTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mealType',
        value: '',
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> nameGreaterThan(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> nameStartsWith(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> plannedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'planned',
        value: value,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition>
      portionMultiplierEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'portionMultiplier',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition>
      portionMultiplierGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'portionMultiplier',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition>
      portionMultiplierLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'portionMultiplier',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition>
      portionMultiplierBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'portionMultiplier',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> potassiumMgEqualTo(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> potassiumMgGreaterThan(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> potassiumMgLessThan(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> potassiumMgBetween(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> proteinGramsEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proteinGrams',
        value: value,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> proteinGramsGreaterThan(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> proteinGramsLessThan(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> proteinGramsBetween(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition>
      saturatedFatGramsEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'saturatedFatGrams',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition>
      saturatedFatGramsGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'saturatedFatGrams',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition>
      saturatedFatGramsLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'saturatedFatGrams',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition>
      saturatedFatGramsBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'saturatedFatGrams',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> sodiumMgEqualTo(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> sodiumMgGreaterThan(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> sodiumMgLessThan(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> sodiumMgBetween(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> sourceEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> sourceGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> sourceLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> sourceBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'source',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> sourceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> sourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> sourceContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> sourceMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'source',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> sourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> sourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> sugarGramsEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sugarGrams',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> sugarGramsGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sugarGrams',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> sugarGramsLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sugarGrams',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> sugarGramsBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sugarGrams',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> userApprovedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'userApproved',
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition>
      userApprovedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'userApproved',
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> userApprovedEqualTo(
      bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userApproved',
        value: value,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> userNoteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'userNote',
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> userNoteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'userNote',
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> userNoteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> userNoteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> userNoteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> userNoteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userNote',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> userNoteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> userNoteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> userNoteContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> userNoteMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userNote',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> userNoteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userNote',
        value: '',
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> userNoteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userNote',
        value: '',
      ));
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> vitaminCMgEqualTo(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> vitaminCMgGreaterThan(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> vitaminCMgLessThan(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> vitaminCMgBetween(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> vitaminDMcgEqualTo(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> vitaminDMcgGreaterThan(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> vitaminDMcgLessThan(
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

  QueryBuilder<MealDoc, MealDoc, QAfterFilterCondition> vitaminDMcgBetween(
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
}

extension MealDocQueryObject
    on QueryBuilder<MealDoc, MealDoc, QFilterCondition> {}

extension MealDocQueryLinks
    on QueryBuilder<MealDoc, MealDoc, QFilterCondition> {}

extension MealDocQuerySortBy on QueryBuilder<MealDoc, MealDoc, QSortBy> {
  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByAiGenerated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiGenerated', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByAiGeneratedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiGenerated', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByBarcode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'barcode', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByBarcodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'barcode', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByCalciumMg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calciumMg', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByCalciumMgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calciumMg', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calories', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calories', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByCarbsGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsGrams', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByCarbsGramsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsGrams', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByDateLogged() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateLogged', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByDateLoggedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateLogged', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByFatGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatGrams', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByFatGramsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatGrams', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByFiberGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiberGrams', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByFiberGramsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiberGrams', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByHealthScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'healthScore', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByHealthScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'healthScore', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByImageLocalPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageLocalPath', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByImageLocalPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageLocalPath', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByIronMg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ironMg', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByIronMgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ironMg', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByMealType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealType', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByMealTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealType', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByPlanned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planned', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByPlannedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planned', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByPortionMultiplier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'portionMultiplier', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByPortionMultiplierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'portionMultiplier', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByPotassiumMg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'potassiumMg', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByPotassiumMgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'potassiumMg', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByProteinGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinGrams', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByProteinGramsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinGrams', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortBySaturatedFatGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saturatedFatGrams', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortBySaturatedFatGramsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saturatedFatGrams', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortBySodiumMg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sodiumMg', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortBySodiumMgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sodiumMg', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortBySugarGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sugarGrams', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortBySugarGramsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sugarGrams', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByUserApproved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userApproved', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByUserApprovedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userApproved', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByUserNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userNote', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByUserNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userNote', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByVitaminCMg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vitaminCMg', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByVitaminCMgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vitaminCMg', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByVitaminDMcg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vitaminDMcg', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> sortByVitaminDMcgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vitaminDMcg', Sort.desc);
    });
  }
}

extension MealDocQuerySortThenBy
    on QueryBuilder<MealDoc, MealDoc, QSortThenBy> {
  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByAiGenerated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiGenerated', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByAiGeneratedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiGenerated', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByBarcode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'barcode', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByBarcodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'barcode', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByCalciumMg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calciumMg', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByCalciumMgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calciumMg', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calories', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calories', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByCarbsGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsGrams', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByCarbsGramsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsGrams', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByDateLogged() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateLogged', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByDateLoggedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateLogged', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByFatGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatGrams', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByFatGramsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatGrams', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByFiberGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiberGrams', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByFiberGramsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiberGrams', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByHealthScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'healthScore', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByHealthScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'healthScore', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByImageLocalPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageLocalPath', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByImageLocalPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageLocalPath', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByIronMg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ironMg', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByIronMgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ironMg', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByMealType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealType', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByMealTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealType', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByPlanned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planned', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByPlannedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planned', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByPortionMultiplier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'portionMultiplier', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByPortionMultiplierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'portionMultiplier', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByPotassiumMg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'potassiumMg', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByPotassiumMgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'potassiumMg', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByProteinGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinGrams', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByProteinGramsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinGrams', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenBySaturatedFatGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saturatedFatGrams', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenBySaturatedFatGramsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saturatedFatGrams', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenBySodiumMg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sodiumMg', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenBySodiumMgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sodiumMg', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenBySugarGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sugarGrams', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenBySugarGramsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sugarGrams', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByUserApproved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userApproved', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByUserApprovedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userApproved', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByUserNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userNote', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByUserNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userNote', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByVitaminCMg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vitaminCMg', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByVitaminCMgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vitaminCMg', Sort.desc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByVitaminDMcg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vitaminDMcg', Sort.asc);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QAfterSortBy> thenByVitaminDMcgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vitaminDMcg', Sort.desc);
    });
  }
}

extension MealDocQueryWhereDistinct
    on QueryBuilder<MealDoc, MealDoc, QDistinct> {
  QueryBuilder<MealDoc, MealDoc, QDistinct> distinctByAiGenerated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiGenerated');
    });
  }

  QueryBuilder<MealDoc, MealDoc, QDistinct> distinctByBarcode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'barcode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QDistinct> distinctByCalciumMg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'calciumMg');
    });
  }

  QueryBuilder<MealDoc, MealDoc, QDistinct> distinctByCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'calories');
    });
  }

  QueryBuilder<MealDoc, MealDoc, QDistinct> distinctByCarbsGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'carbsGrams');
    });
  }

  QueryBuilder<MealDoc, MealDoc, QDistinct> distinctByDateLogged() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateLogged');
    });
  }

  QueryBuilder<MealDoc, MealDoc, QDistinct> distinctByFatGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fatGrams');
    });
  }

  QueryBuilder<MealDoc, MealDoc, QDistinct> distinctByFiberGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fiberGrams');
    });
  }

  QueryBuilder<MealDoc, MealDoc, QDistinct> distinctByHealthScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'healthScore');
    });
  }

  QueryBuilder<MealDoc, MealDoc, QDistinct> distinctByImageLocalPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imageLocalPath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QDistinct> distinctByImageUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imageUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QDistinct> distinctByIngredientsDetected() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ingredientsDetected');
    });
  }

  QueryBuilder<MealDoc, MealDoc, QDistinct> distinctByIronMg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ironMg');
    });
  }

  QueryBuilder<MealDoc, MealDoc, QDistinct> distinctByMealType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mealType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QDistinct> distinctByPlanned() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'planned');
    });
  }

  QueryBuilder<MealDoc, MealDoc, QDistinct> distinctByPortionMultiplier() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'portionMultiplier');
    });
  }

  QueryBuilder<MealDoc, MealDoc, QDistinct> distinctByPotassiumMg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'potassiumMg');
    });
  }

  QueryBuilder<MealDoc, MealDoc, QDistinct> distinctByProteinGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proteinGrams');
    });
  }

  QueryBuilder<MealDoc, MealDoc, QDistinct> distinctBySaturatedFatGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'saturatedFatGrams');
    });
  }

  QueryBuilder<MealDoc, MealDoc, QDistinct> distinctBySodiumMg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sodiumMg');
    });
  }

  QueryBuilder<MealDoc, MealDoc, QDistinct> distinctBySource(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'source', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QDistinct> distinctBySugarGrams() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sugarGrams');
    });
  }

  QueryBuilder<MealDoc, MealDoc, QDistinct> distinctByUserApproved() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userApproved');
    });
  }

  QueryBuilder<MealDoc, MealDoc, QDistinct> distinctByUserNote(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userNote', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MealDoc, MealDoc, QDistinct> distinctByVitaminCMg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vitaminCMg');
    });
  }

  QueryBuilder<MealDoc, MealDoc, QDistinct> distinctByVitaminDMcg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vitaminDMcg');
    });
  }
}

extension MealDocQueryProperty
    on QueryBuilder<MealDoc, MealDoc, QQueryProperty> {
  QueryBuilder<MealDoc, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MealDoc, bool, QQueryOperations> aiGeneratedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiGenerated');
    });
  }

  QueryBuilder<MealDoc, String?, QQueryOperations> barcodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'barcode');
    });
  }

  QueryBuilder<MealDoc, double, QQueryOperations> calciumMgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'calciumMg');
    });
  }

  QueryBuilder<MealDoc, int, QQueryOperations> caloriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'calories');
    });
  }

  QueryBuilder<MealDoc, int, QQueryOperations> carbsGramsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'carbsGrams');
    });
  }

  QueryBuilder<MealDoc, DateTime, QQueryOperations> dateLoggedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateLogged');
    });
  }

  QueryBuilder<MealDoc, int, QQueryOperations> fatGramsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fatGrams');
    });
  }

  QueryBuilder<MealDoc, double, QQueryOperations> fiberGramsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fiberGrams');
    });
  }

  QueryBuilder<MealDoc, double, QQueryOperations> healthScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'healthScore');
    });
  }

  QueryBuilder<MealDoc, String?, QQueryOperations> imageLocalPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imageLocalPath');
    });
  }

  QueryBuilder<MealDoc, String?, QQueryOperations> imageUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imageUrl');
    });
  }

  QueryBuilder<MealDoc, List<String>, QQueryOperations>
      ingredientsDetectedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ingredientsDetected');
    });
  }

  QueryBuilder<MealDoc, double, QQueryOperations> ironMgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ironMg');
    });
  }

  QueryBuilder<MealDoc, String, QQueryOperations> mealTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mealType');
    });
  }

  QueryBuilder<MealDoc, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<MealDoc, bool, QQueryOperations> plannedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'planned');
    });
  }

  QueryBuilder<MealDoc, double, QQueryOperations> portionMultiplierProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'portionMultiplier');
    });
  }

  QueryBuilder<MealDoc, double, QQueryOperations> potassiumMgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'potassiumMg');
    });
  }

  QueryBuilder<MealDoc, int, QQueryOperations> proteinGramsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proteinGrams');
    });
  }

  QueryBuilder<MealDoc, double, QQueryOperations> saturatedFatGramsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'saturatedFatGrams');
    });
  }

  QueryBuilder<MealDoc, double, QQueryOperations> sodiumMgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sodiumMg');
    });
  }

  QueryBuilder<MealDoc, String, QQueryOperations> sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'source');
    });
  }

  QueryBuilder<MealDoc, double, QQueryOperations> sugarGramsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sugarGrams');
    });
  }

  QueryBuilder<MealDoc, bool?, QQueryOperations> userApprovedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userApproved');
    });
  }

  QueryBuilder<MealDoc, String?, QQueryOperations> userNoteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userNote');
    });
  }

  QueryBuilder<MealDoc, double, QQueryOperations> vitaminCMgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vitaminCMg');
    });
  }

  QueryBuilder<MealDoc, double, QQueryOperations> vitaminDMcgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vitaminDMcg');
    });
  }
}
