//
//  NSData+XOREncrypt.m
//  EADemo
//
//  Created by eisen.chen on 2018/9/18.
//  Copyright © 2018年 eisen. All rights reserved.
//

#import "NSData+XOREncrypt.h"

static NSString const *privateKey = @"Y0Ih";

@implementation NSData (XOREncrypt)

- (NSData *)xor_decrypt
{
    return [self xor_encrypt];
}

- (NSData *)xor_encrypt
{
    NSString *encryptKey = [privateKey stringByAppendingString:@"WA=="];
    NSData* decodeData = [[NSData alloc] initWithBase64EncodedString:encryptKey options:0];
    encryptKey = [[NSString alloc] initWithData:decodeData encoding:NSASCIIStringEncoding];
    
    NSInteger length = encryptKey.length;
    
    // 将OC字符串转换为C字符串
    const char *keys = [encryptKey cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cKey[length];
    memcpy(cKey, keys, length);
    // 数据初始化，空间未分配 配合使用 appendBytes
    NSMutableData *encryptData = [[NSMutableData alloc] initWithCapacity:length];
    
    // 获取字节指针
    const Byte *point = self.bytes;
    for (int i = 0; i < self.length; i++) {
        Byte b;
        if (i < 2 || i >= self.length-2) {
            b = (Byte)(point[i]);         //数据以*#开头，以#*结尾，这4个字符不用加密
        } else {
            int l = (i-2) % length;               // 算出当前位置字节，要和密钥的异或运算的密钥字节
            char c = cKey[l];
            b = (Byte) ((point[i]) ^ c); // 异或运算
        }
        [encryptData appendBytes:&b length:1];  // 追加字节
    }
    return encryptData.copy;
}

@end
