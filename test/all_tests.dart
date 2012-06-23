// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

#library('all_tests');

#import('/Applications/Dart/dart-sdk/lib/unittest/unittest.dart');

#import('petitparser_tests.dart', prefix: 'petitparser');

#import('dart_tests.dart', prefix: 'dart');
#import('json_tests.dart', prefix: 'json');
#import('xml_tests.dart', prefix: 'xml');

void main() {
  group('PetitParser', petitparser.main);
  group('Dart', dart.main);
  group('JSON', json.main);
  group('XML', xml.main);
}
