//
//  Alice.h
//  CoreData_CE
//
//  Created by Dylan on 14-10-17.
//  Copyright (c) 2014年 Dylan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Alice : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * age;

@end
