// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fasting_doc.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFastingDocCollection on Isar {
  IsarCollection<FastingDoc> get fastingDocs => this.collection();
}

const FastingDocSchema = CollectionSchema(
  name: r'FastingDoc',
  id: 3369955482240864711,
  properties: {
    r'durationHours': PropertySchema(
      id: 0,
      name: r'durationHours',
      type: IsarType.double,
    ),
    r'durationMinutes': PropertySchema(
      id: 1,
      name: r'durationMinutes',
      type: IsarType.long,
    ),
    r'endTime': PropertySchema(
      id: 2,
      name: r'endTime',
      type: IsarType.dateTime,
    ),
    r'hitTarget': PropertySchema(
      id: 3,
      name: r'hitTarget',
      type: IsarType.bool,
    ),
    r'isActive': PropertySchema(
      id: 4,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'notes': PropertySchema(
      id: 5,
      name: r'notes',
      type: IsarType.string,
    ),
    r'protocolName': PropertySchema(
      id: 6,
      name: r'protocolName',
      type: IsarType.string,
    ),
    r'startTime': PropertySchema(
      id: 7,
      name: r'startTime',
      type: IsarType.dateTime,
    ),
    r'targetHours': PropertySchema(
      id: 8,
      name: r'targetHours',
      type: IsarType.long,
    )
  },
  estimateSize: _fastingDocEstimateSize,
  serialize: _fastingDocSerialize,
  deserialize: _fastingDocDeserialize,
  deserializeProp: _fastingDocDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _fastingDocGetId,
  getLinks: _fastingDocGetLinks,
  attach: _fastingDocAttach,
  version: '3.1.0+1',
);

int _fastingDocEstimateSize(
  FastingDoc object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.notes.length * 3;
  bytesCount += 3 + object.protocolName.length * 3;
  return bytesCount;
}

void _fastingDocSerialize(
  FastingDoc object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.durationHours);
  writer.writeLong(offsets[1], object.durationMinutes);
  writer.writeDateTime(offsets[2], object.endTime);
  writer.writeBool(offsets[3], object.hitTarget);
  writer.writeBool(offsets[4], object.isActive);
  writer.writeString(offsets[5], object.notes);
  writer.writeString(offsets[6], object.protocolName);
  writer.writeDateTime(offsets[7], object.startTime);
  writer.writeLong(offsets[8], object.targetHours);
}

FastingDoc _fastingDocDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FastingDoc();
  object.endTime = reader.readDateTimeOrNull(offsets[2]);
  object.id = id;
  object.isActive = reader.readBool(offsets[4]);
  object.notes = reader.readString(offsets[5]);
  object.protocolName = reader.readString(offsets[6]);
  object.startTime = reader.readDateTime(offsets[7]);
  object.targetHours = reader.readLong(offsets[8]);
  return object;
}

P _fastingDocDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _fastingDocGetId(FastingDoc object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _fastingDocGetLinks(FastingDoc object) {
  return [];
}

void _fastingDocAttach(IsarCollection<dynamic> col, Id id, FastingDoc object) {
  object.id = id;
}

extension FastingDocQueryWhereSort
    on QueryBuilder<FastingDoc, FastingDoc, QWhere> {
  QueryBuilder<FastingDoc, FastingDoc, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FastingDocQueryWhere
    on QueryBuilder<FastingDoc, FastingDoc, QWhereClause> {
  QueryBuilder<FastingDoc, FastingDoc, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<FastingDoc, FastingDoc, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterWhereClause> idBetween(
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

extension FastingDocQueryFilter
    on QueryBuilder<FastingDoc, FastingDoc, QFilterCondition> {
  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition>
      durationHoursEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition>
      durationHoursGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'durationHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition>
      durationHoursLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'durationHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition>
      durationHoursBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'durationHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition>
      durationMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition>
      durationMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'durationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition>
      durationMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'durationMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition>
      durationMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'durationMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition> endTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endTime',
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition>
      endTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endTime',
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition> endTimeEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition>
      endTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition> endTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition> endTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition> hitTargetEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hitTarget',
        value: value,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition> idBetween(
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

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition> isActiveEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition> notesEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition> notesGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition> notesLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition> notesBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition> notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition> notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition> notesContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition> notesMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition>
      protocolNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'protocolName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition>
      protocolNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'protocolName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition>
      protocolNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'protocolName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition>
      protocolNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'protocolName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition>
      protocolNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'protocolName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition>
      protocolNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'protocolName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition>
      protocolNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'protocolName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition>
      protocolNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'protocolName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition>
      protocolNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'protocolName',
        value: '',
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition>
      protocolNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'protocolName',
        value: '',
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition> startTimeEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition>
      startTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition> startTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition> startTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition>
      targetHoursEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetHours',
        value: value,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition>
      targetHoursGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetHours',
        value: value,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition>
      targetHoursLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetHours',
        value: value,
      ));
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterFilterCondition>
      targetHoursBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FastingDocQueryObject
    on QueryBuilder<FastingDoc, FastingDoc, QFilterCondition> {}

extension FastingDocQueryLinks
    on QueryBuilder<FastingDoc, FastingDoc, QFilterCondition> {}

extension FastingDocQuerySortBy
    on QueryBuilder<FastingDoc, FastingDoc, QSortBy> {
  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> sortByDurationHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationHours', Sort.asc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> sortByDurationHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationHours', Sort.desc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> sortByDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMinutes', Sort.asc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy>
      sortByDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMinutes', Sort.desc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> sortByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.asc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> sortByEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.desc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> sortByHitTarget() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hitTarget', Sort.asc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> sortByHitTargetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hitTarget', Sort.desc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> sortByProtocolName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'protocolName', Sort.asc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> sortByProtocolNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'protocolName', Sort.desc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> sortByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> sortByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> sortByTargetHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetHours', Sort.asc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> sortByTargetHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetHours', Sort.desc);
    });
  }
}

extension FastingDocQuerySortThenBy
    on QueryBuilder<FastingDoc, FastingDoc, QSortThenBy> {
  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> thenByDurationHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationHours', Sort.asc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> thenByDurationHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationHours', Sort.desc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> thenByDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMinutes', Sort.asc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy>
      thenByDurationMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationMinutes', Sort.desc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> thenByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.asc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> thenByEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.desc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> thenByHitTarget() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hitTarget', Sort.asc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> thenByHitTargetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hitTarget', Sort.desc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> thenByProtocolName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'protocolName', Sort.asc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> thenByProtocolNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'protocolName', Sort.desc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> thenByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> thenByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> thenByTargetHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetHours', Sort.asc);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QAfterSortBy> thenByTargetHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetHours', Sort.desc);
    });
  }
}

extension FastingDocQueryWhereDistinct
    on QueryBuilder<FastingDoc, FastingDoc, QDistinct> {
  QueryBuilder<FastingDoc, FastingDoc, QDistinct> distinctByDurationHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationHours');
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QDistinct> distinctByDurationMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationMinutes');
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QDistinct> distinctByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endTime');
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QDistinct> distinctByHitTarget() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hitTarget');
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QDistinct> distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QDistinct> distinctByProtocolName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'protocolName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QDistinct> distinctByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startTime');
    });
  }

  QueryBuilder<FastingDoc, FastingDoc, QDistinct> distinctByTargetHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetHours');
    });
  }
}

extension FastingDocQueryProperty
    on QueryBuilder<FastingDoc, FastingDoc, QQueryProperty> {
  QueryBuilder<FastingDoc, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FastingDoc, double, QQueryOperations> durationHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationHours');
    });
  }

  QueryBuilder<FastingDoc, int, QQueryOperations> durationMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationMinutes');
    });
  }

  QueryBuilder<FastingDoc, DateTime?, QQueryOperations> endTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endTime');
    });
  }

  QueryBuilder<FastingDoc, bool, QQueryOperations> hitTargetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hitTarget');
    });
  }

  QueryBuilder<FastingDoc, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<FastingDoc, String, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<FastingDoc, String, QQueryOperations> protocolNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'protocolName');
    });
  }

  QueryBuilder<FastingDoc, DateTime, QQueryOperations> startTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startTime');
    });
  }

  QueryBuilder<FastingDoc, int, QQueryOperations> targetHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetHours');
    });
  }
}
