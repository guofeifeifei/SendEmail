//
//  SendViewController.m
//  AddressBook
//
//  Created by 飞鱼2100 on 2018/5/9.
//  Copyright © 2018年 ZZCN77. All rights reserved.
//

#import "SendViewController.h"
#import "SKPSMTPMessage.h"
#import "NSData+Base64Additions.h"
#import "MBProgressHUD+NHAdd.h"
#import <MessageUI/MessageUI.h>

@interface SendViewController ()<SKPSMTPMessageDelegate,UIWebViewDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, copy) NSString *sendStr;

@end

@implementation SendViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"邮件内容";
    self.view.backgroundColor = [UIColor blackColor];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    //    webView.scalesPageToFit = NO;
    webView.delegate = self;
    //    webView.scrollView.bounces = NO;
    //    [webView setAutoresizingMask:UIViewAutoresizingNone];
    
    [self.view addSubview:webView];
    _webView = webView;
    self.sendStr = [NSString stringWithFormat:@"<html> \n"
                         "<head> \n"
                         "<style type=\"text/css\"> \n"
                         "</style> \n"
                         "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, user-scalable=no\">"
                         "</head> \n"
                         "<body>"
                         "<script type='text/javascript'>"
                         "window.onload = function(){\n"
                         "var $img = document.getElementsByTagName('img');\n"
                         "for(var p in  $img){\n"
                         " $img[p].style.width = '100%%';\n"
                         "$img[p].style.height ='auto'\n"
                         "}\n"
                         "}"
                         "</script>%@"
                         "</body>"
                         "</html>",self.htmlStr];
    [_webView loadHTMLString:self.sendStr baseURL:nil];
    
    
       self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(mfSendHtmlEmail)];
    
}

//1.MFMailComposeViewController发送
- (void)mfSendHtmlEmail {
    if ([MFMailComposeViewController canSendMail]) { // 用户已设置邮件账户
        // 邮件服务器
        MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
        // 设置邮件代理
        [mailCompose setMailComposeDelegate:self];
        
        // 设置邮件主题
        [mailCompose setSubject:@"我是邮件主题"];
        
        // 设置收件人
        [mailCompose setToRecipients:@[@"1780575208@qq.com"]];
        // 设置抄送人
        [mailCompose setCcRecipients:@[@"1780575208@qq.com"]];
        // 设置密抄送
        [mailCompose setBccRecipients:@[@"1780575208@qq.com"]];
        
        /**
         *  设置邮件的正文内容
         */
        NSString *emailContent = self.sendStr;
        // 如使用HTML格式，则为以下代码
        [mailCompose setMessageBody:emailContent isHTML:YES];
        // 弹出邮件发送视图
        [self presentViewController:mailCompose animated:YES completion:nil];
    }else{
        NSLog(@"请先设置邮箱号");
        
    }
}

//2.SKPSMTPMessage发送
- (void)sendHtmlEmail {
    /*
     邮箱号和SMTP的授权码是我自己编的，需要换成你们的
     */
    SKPSMTPMessage *myMessage = [[SKPSMTPMessage alloc] init];
    //发信人
    myMessage.fromEmail=@"1230@qq.com";
    //收件人
    myMessage.toEmail=@"2545706530@qq.com";
    //bccEmail、ccEmail可传可不传，如果需要的填写
    //    myMessage.bccEmail=@"123567@163.com";//暗抄送
    //    myMessage.ccEmail = @"123567@163.com";//抄送人
    //发送邮件代理服务器
     myMessage.relayHost=@"smtp.qq.com";//qq个人
    //    myMessage.relayHost=@"smtp.exmail.qq.com";qq企业账号
    
//    myMessage.relayHost=@"smtp.163.com";
    myMessage.requiresAuth=YES;//验证身份是否登录
    if (myMessage.requiresAuth) {
        //发信人
        myMessage.login=@"12300@qq.com"; //发信人账号
        myMessage.pass=@"111ddd";//发信人的SMTP的授权码
    }
    myMessage.wantsSecure =YES; //需要加密
    /*
     163邮箱报错的
     S: 554 DT:SPM 163 smtp9,DcCowADXPVEoF_FaG5peAg--.47217S3 1525749544,please see http://mail.163.com/help/help_spam_16.htm?ip=125.118.133.189&hostid=smtp9&time=1525749544
     重新修改subject内容
     */
    myMessage.subject = @"你好啊我是";//// 设置邮件主题
    myMessage.delegate = self;// 设置邮件代理
    //设置邮件内容
    NSString *dataStr = self.sendStr;
    NSString *sendMessageStr =  [self htmlEntityDecode:dataStr];
    NSDictionary *plainPart = [NSDictionary dictionaryWithObjectsAndKeys:@"text/html",kSKPSMTPPartContentTypeKey,sendMessageStr,kSKPSMTPPartMessageKey,@"8bit",kSKPSMTPPartContentTransferEncodingKey,nil];
    
    myMessage.parts = [NSArray arrayWithObjects:plainPart,nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //发送
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showOnlyLoadToView:self.view];
        });
        [myMessage send];

    });
    
    
}

//将 &lt 等类似的字符转化为HTML中的“<”等
- (NSString *)htmlEntityDecode:(NSString *)string
{
    string = [string stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    string = [string stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    string = [string stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    string = [string stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    string = [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"]; // Do this last so that, e.g. @"&amp;lt;" goes to @"&lt;" not @"<"
    string = [NSString stringWithFormat:@"<html> \n"
              "<head> \n"
              "<style type=\"text/css\"> \n"
              "</style> \n"
              "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, user-scalable=no\">"
              "</head> \n"
              "<body>"
              "<script type='text/javascript'>"
              "window.onload = function(){\n"
              "var $img = document.getElementsByTagName('img');\n"
              "for(var p in  $img){\n"
              " $img[p].style.width = '100%%';\n"
              "$img[p].style.height ='auto'\n"
              "}\n"
              "}"
              "</script>%@"
              "</body>"
              "</html>",string];
    return string;
}

- (void)messageSent:(SKPSMTPMessage *)message
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    NSLog(@"邮件发送成功");
}

- (void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error
{
    [MBProgressHUD showError:[NSString stringWithFormat:@"不好意思,邮件发送失败%@",error] toView:self.view];

    NSLog(@"不好意思,邮件发送失败%@",error);
    
    
}
//MFMailComposeViewControllerDelegate的代理方法：
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled: // 用户取消编辑
            NSLog(@"Mail send canceled...");
            break;
        case MFMailComposeResultSaved: // 用户保存邮件
            NSLog(@"Mail saved...");
            break;
        case MFMailComposeResultSent: // 用户点击发送
            NSLog(@"Mail sent...");
            break;
        case MFMailComposeResultFailed: // 用户尝试保存或发送邮件失败
            NSLog(@"Mail send errored: %@...", [error localizedDescription]);
            break;
    }
    
    // 关闭邮件发送视图
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
