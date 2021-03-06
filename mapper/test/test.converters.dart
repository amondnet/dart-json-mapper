part of json_mapper.test;

class CustomStringConverter implements ICustomConverter<String> {
  const CustomStringConverter() : super();

  @override
  String fromJSON(dynamic jsonValue, [JsonProperty jsonProperty]) {
    return jsonValue;
  }

  @override
  dynamic toJSON(String object, [JsonProperty jsonProperty]) {
    return '_${object}_';
  }
}

@jsonSerializable
class BinaryData {
  Uint8List data;

  BinaryData(this.data);
}

@jsonSerializable
class BigIntData {
  BigInt bigInt;

  BigIntData(this.bigInt);
}

void testConverters() {
  group('[Verify converters]', () {
    test('Map<String, dynamic> converter', () {
      // given
      final json = '{"a":"abc","b":3}';

      // when
      final target = JsonMapper.deserialize<Map<String, dynamic>>(json);

      // then
      expect(target, TypeMatcher<Map<String, dynamic>>());
      expect(target['a'], TypeMatcher<String>());
      expect(target['b'], TypeMatcher<num>());
    });

    test('BigInt converter', () {
      // given
      final rawString = '1234567890000000012345678900';
      final json = '{"bigInt":"${rawString}"}';

      // when
      final targetJson = JsonMapper.serialize(
          BigIntData(BigInt.parse(rawString)), compactOptions);
      // then
      expect(targetJson, json);

      // when
      final target = JsonMapper.deserialize<BigIntData>(json);
      // then
      expect(rawString, target.bigInt.toString());
    });

    test('Uint8List converter', () {
      // given
      final json = '{"data":"QmFzZTY0IGlzIHdvcmtpbmch"}';
      final rawString = 'Base64 is working!';

      // when
      final targetJson = JsonMapper.serialize(
          BinaryData(Uint8List.fromList(rawString.codeUnits)), compactOptions);
      // then
      expect(targetJson, json);

      // when
      final target = JsonMapper.deserialize<BinaryData>(json);
      // then
      expect(rawString, String.fromCharCodes(target.data));
    });

    test('Custom String converter', () {
      // given
      final json = '''{
 "id": 1,
 "name": "_Bob_",
 "car": {
  "modelName": "_Audi_",
  "color": "Color.Green"
 }
}''';
      JsonMapper.registerConverter<String>(CustomStringConverter());

      final i = Immutable(1, 'Bob', Car('Audi', Color.Green));
      // when
      final target = JsonMapper.serialize(i);
      // then
      expect(target, json);

      JsonMapper.registerConverter<String>(defaultConverter);
    });
  });
}
