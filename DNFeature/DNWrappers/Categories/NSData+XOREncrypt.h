//
//  NSData+XOREncrypt.h
//  EADemo
//
//  Created by eisen.chen on 2018/9/18.
//  Copyright © 2018年 eisen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (XOREncrypt)

- (NSData *)xor_encrypt;

- (NSData *)xor_decrypt;

@end
