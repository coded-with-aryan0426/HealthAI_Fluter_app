// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_entry_doc.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBodyEntryDocCollection on Isar {
  IsarCollection<BodyEntryDoc> get bodyEntryDocs => this.collection();
}

const BodyEntryDocSchema = CollectionSchema(
  name: r'BodyEntryDoc',
  id: -8793035406042439114,
  properties: {
    r'bodyFatPct': PropertySchema(
      id: 0,
      name: r'bodyFatPct',
      type: IsarType.double,
    ),
    r'date': PropertySchema(
      id: 1,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'hipCm': PropertySchema(
      id: 2,
      name: r'hipCm',
      type: IsarType.double,
    ),
    r'note': PropertySchema(
      id: 3,
      name: r'note',
      type: IsarType.string,
    ),
    r'waistCm': PropertySchema(
      id: 4,
      name: r'waistCm',
      type: IsarType.double,
    ),
    r'weightKg': PropertySchema(
      id: 5,
      name: r'weightKg',
      type: IsarType.double,
    )
  },
  estimateSize: _bodyEntryDocEstimateSize,
  serialize: _bodyEntryDocSerialize,
  deserialize: _bodyEntryDocDeserialize,
  deserializeProp: _bodyEntryDocDeserializeProp,
  idName: r'id',
  indexes: {
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: false,
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
  getId: _bodyEntryDocGetId,
  getLinks: _bodyEntryDocGetLinks,
  attach: _bodyEntryDocAttach,
  version: '3.1.0+1',
);

int _bodyEntryDocEstimateSize(
  BodyEntryDoc object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.note.length * 3;
  return bytesCount;
}

void _bodyEntryDocSerialize(
  BodyEntryDoc object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.bodyFatPct);
  writer.writeDateTime(offsets[1], object.date);
  writer.writeDouble(offsets[2], object.hipCm);
  writer.writeString(offsets[3], object.note);
  writer.writeDouble(offsets[4], object.waistCm);
  writer.writeDouble(offsets[5], object.weightKg);
}

BodyEntryDoc _bodyEntryDocDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BodyEntryDoc();
  object.bodyFatPct = reader.readDouble(offsets[0]);
  object.date = reader.readDateTime(offsets[1]);
  object.hipCm = reader.readDouble(offsets[2]);
  object.id = id;
  object.note = reader.readString(offsets[3]);
  object.waistCm = reader.readDouble(offsets[4]);
  object.weightKg = reader.readDouble(offsets[5]);
  return object;
}

P _bodyEntryDocDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _bodyEntryDocGetId(BodyEntryDoc object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _bodyEntryDocGetLinks(BodyEntryDoc object) {
  return [];
}

void _bodyEntryDocAttach(
    IsarCollection<dynamic> col, Id id, BodyEntryDoc object) {
  object.id = id;
}

extension BodyEntryDocQueryWhereSort
    on QueryBuilder<BodyEntryDoc, BodyEntryDoc, QWhere> {
  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterWhere> anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }
}

extension BodyEntryDocQueryWhere
    on QueryBuilder<BodyEntryDoc, BodyEntryDoc, QWhereClause> {
  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterWhereClause> idBetween(
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

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterWhereClause> dateEqualTo(
      DateTime date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterWhereClause> dateNotEqualTo(
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

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterWhereClause> dateGreaterThan(
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

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterWhereClause> dateLessThan(
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

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterWhereClause> dateBetween(
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

extension BodyEntryDocQueryFilter
    on QueryBuilder<BodyEntryDoc, BodyEntryDoc, QFilterCondition> {
  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition>
      bodyFatPctEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bodyFatPct',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition>
      bodyFatPctGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bodyFatPct',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition>
      bodyFatPctLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bodyFatPct',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition>
      bodyFatPctBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bodyFatPct',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition> dateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition>
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

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition> dateLessThan(
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

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition> dateBetween(
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

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition> hipCmEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hipCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition>
      hipCmGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hipCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition> hipCmLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hipCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition> hipCmBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hipCm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition> idBetween(
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

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition> noteEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition>
      noteGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition> noteLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition> noteBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'note',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition>
      noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition> noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition> noteContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition> noteMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'note',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition>
      noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition>
      noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition>
      waistCmEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'waistCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition>
      waistCmGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'waistCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition>
      waistCmLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'waistCm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition>
      waistCmBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'waistCm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition>
      weightKgEqualTo(
    double value, {
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

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition>
      weightKgGreaterThan(
    double value, {
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

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition>
      weightKgLessThan(
    double value, {
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

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterFilterCondition>
      weightKgBetween(
    double lower,
    double upper, {
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

extension BodyEntryDocQueryObject
    on QueryBuilder<BodyEntryDoc, BodyEntryDoc, QFilterCondition> {}

extension BodyEntryDocQueryLinks
    on QueryBuilder<BodyEntryDoc, BodyEntryDoc, QFilterCondition> {}

extension BodyEntryDocQuerySortBy
    on QueryBuilder<BodyEntryDoc, BodyEntryDoc, QSortBy> {
  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterSortBy> sortByBodyFatPct() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyFatPct', Sort.asc);
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterSortBy>
      sortByBodyFatPctDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyFatPct', Sort.desc);
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterSortBy> sortByHipCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hipCm', Sort.asc);
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterSortBy> sortByHipCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hipCm', Sort.desc);
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterSortBy> sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterSortBy> sortByWaistCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waistCm', Sort.asc);
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterSortBy> sortByWaistCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waistCm', Sort.desc);
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterSortBy> sortByWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.asc);
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterSortBy> sortByWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.desc);
    });
  }
}

extension BodyEntryDocQuerySortThenBy
    on QueryBuilder<BodyEntryDoc, BodyEntryDoc, QSortThenBy> {
  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterSortBy> thenByBodyFatPct() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyFatPct', Sort.asc);
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterSortBy>
      thenByBodyFatPctDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyFatPct', Sort.desc);
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterSortBy> thenByHipCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hipCm', Sort.asc);
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterSortBy> thenByHipCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hipCm', Sort.desc);
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterSortBy> thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterSortBy> thenByWaistCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waistCm', Sort.asc);
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterSortBy> thenByWaistCmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'waistCm', Sort.desc);
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterSortBy> thenByWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.asc);
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QAfterSortBy> thenByWeightKgDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightKg', Sort.desc);
    });
  }
}

extension BodyEntryDocQueryWhereDistinct
    on QueryBuilder<BodyEntryDoc, BodyEntryDoc, QDistinct> {
  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QDistinct> distinctByBodyFatPct() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bodyFatPct');
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QDistinct> distinctByHipCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hipCm');
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QDistinct> distinctByNote(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QDistinct> distinctByWaistCm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'waistCm');
    });
  }

  QueryBuilder<BodyEntryDoc, BodyEntryDoc, QDistinct> distinctByWeightKg() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weightKg');
    });
  }
}

extension BodyEntryDocQueryProperty
    on QueryBuilder<BodyEntryDoc, BodyEntryDoc, QQueryProperty> {
  QueryBuilder<BodyEntryDoc, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BodyEntryDoc, double, QQueryOperations> bodyFatPctProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bodyFatPct');
    });
  }

  QueryBuilder<BodyEntryDoc, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<BodyEntryDoc, double, QQueryOperations> hipCmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hipCm');
    });
  }

  QueryBuilder<BodyEntryDoc, String, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<BodyEntryDoc, double, QQueryOperations> waistCmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'waistCm');
    });
  }

  QueryBuilder<BodyEntryDoc, double, QQueryOperations> weightKgProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weightKg');
    });
  }
}
