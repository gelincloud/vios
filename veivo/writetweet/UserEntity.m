//
//  UserEntity.m
//  veivo
//
//  Created by LinXiaojun on 2019/5/9.
//  Copyright © 2019 Fn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserEntity : NSObject

@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *appid;

-(id)initWithName:(NSString *)name appid:(NSString *)appid;

@end

@implementation UserEntity

-(id)initWithName:(NSString *)name appid:(NSString *)appid {
    self = [super init];
    if (self) {
        self.name = name;
        self.appid = appid;
    }
    
    return self;
}

@end
