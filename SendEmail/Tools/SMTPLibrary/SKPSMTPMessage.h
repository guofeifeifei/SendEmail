//
//  SKPSMTPMessage.h
//
//  Created by Ian Baird on 10/28/08.
//
//  Copyright (c) 2008 Skorpiostech, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import <CFNetwork/CFNetwork.h>

enum 
{
    kSKPSMTPIdle = 0,
    kSKPSMTPConnecting,
    kSKPSMTPWaitingEHLOReply,
    kSKPSMTPWaitingTLSReply,
    kSKPSMTPWaitingLOGINUsernameReply,
    kSKPSMTPWaitingLOGINPasswordReply,
    kSKPSMTPWaitingAuthSuccess,
    kSKPSMTPWaitingFromReply,
    kSKPSMTPWaitingToReply,
    kSKPSMTPWaitingForEnterMail,
    kSKPSMTPWaitingSendSuccess,
    kSKPSMTPWaitingQuitReply,
    kSKPSMTPMessageSent
};
typedef NSUInteger SKPSMTPState;
    
// Message part keys
extern NSString *kSKPSMTPPartContentDispositionKey;
extern NSString *kSKPSMTPPartContentTypeKey;
extern NSString *kSKPSMTPPartMessageKey;
extern NSString *kSKPSMTPPartContentTransferEncodingKey;

// Error message codes
#define kSKPSMPTErrorConnectionTimeout -5
#define kSKPSMTPErrorConnectionFailed -3
#define kSKPSMTPErrorConnectionInterrupted -4
#define kSKPSMTPErrorUnsupportedLogin -2
#define kSKPSMTPErrorTLSFail -1
#define kSKPSMTPErrorNonExistentDomain 1
#define kSKPSMTPErrorInvalidUserPass 535
#define kSKPSMTPErrorInvalidMessage 550
#define kSKPSMTPErrorNoRelay 530

@class SKPSMTPMessage;

@protocol SKPSMTPMessageDelegate
@required

-(void)messageSent:(SKPSMTPMessage *)message;
-(void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error;

@end

@interface SKPSMTPMessage : NSObject <NSCopying, NSStreamDelegate>
{
    NSString *login;
    NSString *pass;
    NSString *relayHost;
    NSArray *relayPorts;
    
    NSString *subject;
    NSString *fromEmail;
    NSString *toEmail;
	NSString *ccEmail;
	NSString *bccEmail;
    NSArray *parts;
    
    NSOutputStream *outputStream;
    NSInputStream *inputStream;
    
    BOOL requiresAuth;
    BOOL wantsSecure;
    BOOL validateSSLChain;
    
    SKPSMTPState sendState;
    BOOL isSecure;
    NSMutableString *inputString;
    
    // Auth support flags
    BOOL serverAuthCRAMMD5;
    BOOL serverAuthPLAIN;
    BOOL serverAuthLOGIN;
    BOOL serverAuthDIGESTMD5;
    
    // Content support flags
    BOOL server8bitMessages;
    
    id <SKPSMTPMessageDelegate> delegate;
    
    NSTimeInterval connectTimeout;
    
    NSTimer *connectTimer;
    NSTimer *watchdogTimer;
}

@property(nonatomic, retain) NSString *login;
@property(nonatomic, retain) NSString *pass;
@property(nonatomic, retain) NSString *relayHost;//// 发送邮件代理服务器

@property(nonatomic, retain) NSArray *relayPorts;
@property(nonatomic, assign) BOOL requiresAuth;//验证身份是否登录
@property(nonatomic, assign) BOOL wantsSecure;// 需要加密
@property(nonatomic, assign) BOOL validateSSLChain;

@property(nonatomic, retain) NSString *subject;// 设置邮件主题
@property(nonatomic, retain) NSString *fromEmail; // 发送者邮箱
@property(nonatomic, retain) NSString *toEmail;// 目标邮箱
@property(nonatomic, retain) NSString *ccEmail;//设置抄送人
@property(nonatomic, retain) NSString *bccEmail;// 设置密抄送
@property(nonatomic, retain) NSArray *parts;

@property(nonatomic, assign) NSTimeInterval connectTimeout;

@property(nonatomic, assign) id <SKPSMTPMessageDelegate> delegate;

- (BOOL)send;

@end
