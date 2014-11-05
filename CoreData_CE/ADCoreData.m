//
//  ADCoreData.m
//  CoreData_CE
//
//  Created by Dylan on 14-10-11.
//  Copyright (c) 2014年 Dylan. All rights reserved.
//

#import "ADCoreData.h"
#import "ADCoreDataManager.h"
#import <objc/runtime.h>

#define CLASS_NAME(PRAM) NSStringFromClass([PRAM class])

@interface ADCoreData ()

@property (nonatomic, strong) NSManagedObjectModel * managedobjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator * persistentStoreCoordinator;

/*!
 *  @Author Dylan.
 *
 *  storeName
 */
@property (nonatomic, strong) NSString * storeName;

- (NSURL *)applicationDomainUrl;

@end

static ADCoreData * coreData;

@implementation ADCoreData

+ (instancetype)shareInstanceWithStoreName:(NSString *)storeName {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coreData = [[self alloc] init];
        coreData.storeName = storeName;
        NSLog(@"%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]);
    });
    
    return coreData;
}

/*!
 *  @Author Dylan.
 *
 *  synthesize
 */
@synthesize manageContext = _manageContext;
@synthesize managedobjectModel = _managedobjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark -
#pragma mark - GET
- (NSManagedObjectContext *)manageContext {
    
    if (_manageContext) {
        return _manageContext;
    }
    
    NSPersistentStoreCoordinator * coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _manageContext = [[NSManagedObjectContext alloc] init];
        [_manageContext setPersistentStoreCoordinator:coordinator];
    }
    return _manageContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSURL * storeUrl = [[self applicationDomainUrl] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", _storeName]];
    // when version changed can't crash
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
    						 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
    						 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedobjectModel];
    [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:nil];
    return _persistentStoreCoordinator;
}

- (NSManagedObjectModel *)managedobjectModel {
    
    if (_managedobjectModel) {
        return _managedobjectModel;
    }
    
    NSURL * modelUrl = [[NSBundle mainBundle] URLForResource:_storeName withExtension:@"momd"];
    _managedobjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelUrl];
    return _managedobjectModel;
}

#pragma mark - Methods
- (NSMutableArray *)findByModel: (id)model {
    
    NSError * error = nil;
    NSArray * listArray = [_manageContext executeFetchRequest:[self bindRequest:CLASS_NAME(model) predicate:nil] error:&error];
    NSMutableArray * resultArray = [NSMutableArray array];
    
    for (ADCoreDataManager * manager in listArray) {
        
        for (NSString * propertyName in [self ClassAttributes:model]) {
            [model setValue:[manager valueForKey:propertyName] forKey:propertyName];
        }
        [resultArray addObject:model];
    }
    return resultArray;
}

- (NSMutableArray *)findByModel: (id)model
                predicateString: (NSString *)predicateString; {
    
    NSError * error = nil;
    NSArray * listArray = [_manageContext executeFetchRequest:[self bindRequest:CLASS_NAME(model) predicate:predicateString] error:&error];
    NSMutableArray * resultArray = [NSMutableArray array];
    
    if (listArray.count >= 1) {
        for (ADCoreDataManager * manager in listArray) {
            
            for (NSString * propertyName in [self ClassAttributes:model]) {
                [model setValue:[manager valueForKey:propertyName] forKey:propertyName];
            }
            [resultArray addObject:model];
        }
    }
    return resultArray;
}

#pragma mark update
- (BOOL)create: (id)model {
    ADCoreDataManager * manager = [NSEntityDescription insertNewObjectForEntityForName:CLASS_NAME(model) inManagedObjectContext:_manageContext];
    
    for (NSString * propertyName in [self ClassAttributes:model]) {
        [manager setValue:[model valueForKey:propertyName] forKey:propertyName];
    }
    BOOL result = [self saveContext];
    return result;
}

- (BOOL)remove: (id)model {
    
    NSError * error = nil;
    NSArray * listArray = [_manageContext executeFetchRequest:[self bindRequest:CLASS_NAME(model) predicate:nil] error:&error];
    if (listArray.count > 0) {
        for (ADCoreDataManager * manager in listArray) {
            [_manageContext deleteObject:manager];
        }
    }
    return [self saveContext];
}

- (BOOL)remove: (id)model
predicateString: (NSString *)predicateString {
    
    NSError * error = nil;
    NSArray * listArray = [_manageContext executeFetchRequest:[self bindRequest:CLASS_NAME(model) predicate:predicateString] error:&error];
    
    if (listArray.count > 0) {
        for (ADCoreDataManager * manager in listArray) {
            [_manageContext deleteObject:manager];
        }
    }
    return [self saveContext];
}

- (BOOL)modify: (id)model
 predicateString: (NSString *)predicateString {
    
    NSError * error = nil;
    NSArray * listArray = [_manageContext executeFetchRequest:[self bindRequest:CLASS_NAME(model) predicate:predicateString] error:&error];
    
    if (listArray.count > 0) {
        
        for (ADCoreDataManager * manager in listArray) {
            for (NSString * propertyName in [self ClassAttributes:model]) {
                [manager setValue:[model valueForKey:propertyName] forKey:propertyName];
            }
        }
    }
    return [self saveContext];
}

#pragma mark - collect
- (NSFetchRequest *)bindRequest: (NSString *)className
          predicate: (NSString *)predicateString {
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:className inManagedObjectContext:_manageContext]];
    
    if (predicateString != nil) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:predicateString];
        NSLog(@"%@", predicate);
        NSLog(@"%@", predicateString);
        [request setPredicate:predicate];
    }
    return request;
}

#pragma mark - save
- (BOOL)saveContext {
    
    NSManagedObjectContext * context = [self manageContext];
    if (context != nil) {
        
        NSError * error = nil;
        if ([context hasChanges] && ![context save:&error]) {
            NSLog(@"%@", [error userInfo]);
            abort();
            return NO;
        }
    }
    
    return YES;
}


- (NSURL *)applicationDomainUrl {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - allAttributes
- (NSMutableArray *) ClassAttributes: (id)classModel {
    
    NSMutableArray * array = [NSMutableArray array];
    NSString *className = NSStringFromClass([classModel class]);
    const char * cClassName = [className UTF8String];
    
    id classM = objc_getClass(cClassName);
    unsigned int outCount, i;
    objc_property_t * properties = class_copyPropertyList(classM, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString * attributeName = [NSString stringWithUTF8String:property_getName(property)];
        
        [array addObject:attributeName];
    }
    return array;
}

@end
