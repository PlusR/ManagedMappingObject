//
//  ManagedMappingObjectTests.m
//  ManagedMappingObjectTests
//
//  Created by azu on 2013/09/11.
//  Copyright (c) 2013 azu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MagicalRecord+Setup.h"
#import "PersonJSONModel.h"
#import "Person.h"
#import "NSManagedObjectContext+MagicalRecord.h"
#import "UnitJSONModel.h"
#import "Unit.h"

@interface ManagedMappingObjectTests : XCTestCase

@end

@implementation ManagedMappingObjectTests

- (void)setUp {
    [super setUp];
    [MagicalRecord setupCoreDataStackWithInMemoryStore];
}

- (void)tearDown {
    // Tear-down code here.
    [MagicalRecord cleanUp];
    [super tearDown];
}

- (PersonJSONModel *)personJSONModel {
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"person" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    PersonJSONModel *personJSONModel = [PersonJSONModel modelObjectWithDictionary:dictionary];
    return personJSONModel;
}

- (UnitJSONModel *)unitJSONModel {
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"unit" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    UnitJSONModel *jsonModel = [UnitJSONModel modelObjectWithDictionary:dictionary];
    return jsonModel;
}

- (void)testInsertWithDictionary {
    PersonJSONModel *jsonModel = [self personJSONModel];
    Person *person = [Person insertNewWithDictionary:jsonModel.dictionaryRepresentation managedObjectContext:[NSManagedObjectContext MR_defaultContext]];
    XCTAssertEqualObjects([person dictionaryRepresentation], [jsonModel dictionaryRepresentation], @"dict -> NSManagedObject -> dict");
}

- (void)testNilDictionaryRepresentation {
    PersonJSONModel *jsonModel = [self personJSONModel];
    jsonModel.name = nil;
    Person *person = [Person insertNewWithDictionary:jsonModel.dictionaryRepresentation managedObjectContext:[NSManagedObjectContext MR_defaultContext]];
    XCTAssertEqualObjects([person dictionaryRepresentation], [jsonModel dictionaryRepresentation], @"name doesn't exist");
}

- (void)testTransform {
    UnitJSONModel *jsonModel = [self unitJSONModel];
    Unit *unit = [Unit insertNewWithDictionary:jsonModel.dictionaryRepresentation managedObjectContext:[NSManagedObjectContext MR_defaultContext]];
    XCTAssertEqualObjects([unit dictionaryRepresentation], [jsonModel dictionaryRepresentation], @"dict -> NSManagedObject -> dict");
}

- (void)testUpdateWithDictionary {
    PersonJSONModel *jsonModel = [self personJSONModel];
    Person *person = [Person insertNewWithDictionary:jsonModel.dictionaryRepresentation managedObjectContext:[NSManagedObjectContext MR_defaultContext]];
    Person *person_tw = [Person insertNewWithDictionary:jsonModel.dictionaryRepresentation managedObjectContext:[NSManagedObjectContext MR_defaultContext]];
    XCTAssertTrue([self isEqualPropertyOfPerson:person toPerson:person_tw], @"All property is same");
    jsonModel.name = @"new name";
    [person_tw updateWithDictionary:jsonModel.dictionaryRepresentation];
    XCTAssertTrue(![self isEqualPropertyOfPerson:person toPerson:person_tw], @"name is difference");
}

- (void)testUpdateWithNilDictionary {
    PersonJSONModel *jsonModel = [self personJSONModel];
    Person *person = [Person insertNewWithDictionary:jsonModel.dictionaryRepresentation managedObjectContext:[NSManagedObjectContext MR_defaultContext]];
    Person *person_tw = [Person insertNewWithDictionary:jsonModel.dictionaryRepresentation managedObjectContext:[NSManagedObjectContext MR_defaultContext]];
    XCTAssertTrue([self isEqualPropertyOfPerson:person toPerson:person_tw], @"All property is same");
    jsonModel.name = nil;
    jsonModel.internalBaseClassIdentifier = nil;
    [person_tw updateWithDictionary:jsonModel.dictionaryRepresentation];
    XCTAssertTrue([self isEqualPropertyOfPerson:person toPerson:person_tw], @"not update with missing key");
}

- (void)testTransformRelationShipToMany {
    PersonJSONModel *jsonModel = [self personJSONModel];
    Person *person = [Person insertNewWithDictionary:jsonModel.dictionaryRepresentation managedObjectContext:[NSManagedObjectContext MR_defaultContext]];
    XCTAssertTrue([[person dictionaryRepresentation] isKindOfClass:[NSDictionary class]], @"should be NSDictionary");
}

- (void)testUpdateNullPerson {
    PersonJSONModel *jsonModel = [self personJSONModel];
    Person *person = [Person insertNewWithDictionary:jsonModel.dictionaryRepresentation managedObjectContext:[NSManagedObjectContext MR_defaultContext]];
    NSDictionary *dictionary = @{
            PersonAttributes.age: [NSNull null],
            @"id": [NSNull null],
            PersonAttributes.name: [NSNull null],
            @"units": [NSNull null],
    };
    [person updateWithDictionary:dictionary];
    XCTAssertEqualObjects([person dictionaryRepresentation], @{ @"units":@[] }, @"update null property");
}

- (BOOL)isEqualPropertyOfPerson:(Person *)person toPerson:(Person *)toPerson {
    return ([person.name isEqualToString:toPerson.name]
            && [person.identifier isEqualToString:toPerson.identifier]
            && [person.age isEqualToNumber:toPerson.age]);
}
@end
