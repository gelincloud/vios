//
//  UserEntity.h
//  TableViewDemo
//
//  Created by zanglitao on 14/12/5.
//  Copyright (c) 2014年 臧立涛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserEntity.h"


@interface UserEntity : NSObject

@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *appid;

-(id)initWithName:(NSString *)name appid:(NSString *)appid;
@end
