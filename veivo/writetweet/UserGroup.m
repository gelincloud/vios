//
//  UserGroup.m
//  veivo
//
//  Created by LinXiaojun on 2019/5/9.
//  Copyright © 2019 Fn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserEntity.h"

@interface UserGroup : NSObject

@property(nonatomic,strong)NSMutableArray *userEntities;
@property(nonatomic,strong)NSString *groupIdentifier;
@property(nonatomic,strong)NSString *groupIntro;

-(id)initWithEntities:(NSArray *)entities GroupIdentifier:(NSString *)groupIdentifier GroupIntro:(NSString *)groupIntro;

@end

@implementation UserGroup

-(id)initWithEntities:(NSMutableArray *)entities GroupIdentifier:(NSString *)groupIdentifier GroupIntro:(NSString *)groupIntro {
    self = [super init];
    if (self) {
        self.userEntities = entities;
        self.groupIdentifier = groupIdentifier;
        self.groupIntro = groupIntro;
    }
    return self;
}
-(void)addEntity:(UserEntity *)entity{
    [self.userEntities addObject:entity];
}

@end
