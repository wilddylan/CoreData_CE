CoreData_CE
===========

XXCoreData Handle

//
//  ADCoreData.h
//  CoreData_CE
//
//  Created by Dylan on 14-10-11.
//  Copyright (c) 2014年 Dylan. All rights reserved.
//

/*!
 *  @Author Dylan.
 *
 *  Please add CoreData.FrameWork
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface ADCoreData : NSObject

/*!
 *  @Author Dylan.
 *
 *  context
 */
@property (nonatomic, strong, readonly) NSManagedObjectContext * manageContext;

+ (instancetype)shareInstanceWithStoreName: (NSString *)storeName;

/*!
 *  @Author Dylan.
 *
 *  Methods
 */

- (NSMutableArray *)findByModel: (id)model;
- (NSMutableArray *)findByModel: (id)model
                   predicateString: (NSString *)predicateString;
/*!
 *  Update
 */
- (BOOL)create: (id)model;

- (BOOL)remove: (id)model;
- (BOOL)remove: (id)model
      predicateString: (NSString *)predicateString;
- (BOOL)modify: (id)model
 predicateString: (NSString *)predicateString;

@end
