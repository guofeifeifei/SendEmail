//
//  ViewController.m
//  SendEmail
//
//  Created by 飞鱼2100 on 2018/5/9.
//  Copyright © 2018年 feiyu. All rights reserved.
//

#import "ViewController.h"
#import "SKPSMTPMessage.h"
#import "NSData+Base64Additions.h"
#import "ZSSDemoViewController.h"
#import "MBProgressHUD+NHAdd.h"

#import <MessageUI/MessageUI.h>
@interface ViewController ()<SKPSMTPMessageDelegate, UITableViewDelegate, UITableViewDataSource,MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"邮件发送";
    self.view.backgroundColor = [UIColor blackColor];
    self.dataArray = @[@"openURL（原生）",@"MFMailComposeViewController（原生）",@"SKPSMTPMessage文字发送", @"SKPSMTPMessage html发送"];
    [self.view addSubview:self.tableView];

    
}

- (UITableView *)tableView{
    if (_tableView == nil) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.rowHeight = 50;
        
        
    }
    return _tableView;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" ];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        if (indexPath.row == 0) {
            //创建可变的地址字符串对象：
            NSMutableString *mailUrl = [[NSMutableString alloc] init];
            //添加收件人：
            NSArray *toRecipients = @[@"1780575208@qq.com"];
            // 注意：如有多个收件人，可以使用componentsJoinedByString方法连接，连接符为@","
            [mailUrl appendFormat:@"mailto:%@", toRecipients[0]];
            //添加抄送人：
            NSArray *ccRecipients = @[@"1780575208@qq.com"];
            [mailUrl appendFormat:@"?cc=%@", ccRecipients[0]];
           // 添加密送人：
            NSArray *bccRecipients = @[@"1780575208@qq.com"];
            [mailUrl appendFormat:@"&bcc=%@", bccRecipients[0]];
            
            //添加邮件主题和邮件内容：
            [mailUrl appendString:@"&subject=my email"];
            [mailUrl appendString:@"&body=<b>Hello</b> World!"];
            //打开地址，这里会跳转至邮件发送界面：
            NSString *emailPath = [mailUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailPath]];
            
        }else if (indexPath.row == 1){
            if ([MFMailComposeViewController canSendMail]) { // 用户已设置邮件账户
                [self sendEmailAction]; // 调用发送邮件的代码
            }else{
                NSLog(@"请先设置邮箱号");
                
            }
    
        }else if (indexPath.row == 2) {
            [self sendText];
        }else if (indexPath.row == 3){
            ZSSDemoViewController *vc = [[ZSSDemoViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            
        }
}
- (void)sendEmailAction
{
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
    NSString *emailContent = @"我是邮件内容";
    // 是否为HTML格式
    [mailCompose setMessageBody:emailContent isHTML:NO];
    // 如使用HTML格式，则为以下代码
    //    [mailCompose setMessageBody:@"<html><body><p>Hello</p><p>World！</p></body></html>" isHTML:YES];
    
    /**
     *  添加附件
     */
    UIImage *image = [UIImage imageNamed:@"1"];
    NSData *imageData = UIImagePNGRepresentation(image);
    [mailCompose addAttachmentData:imageData mimeType:@"" fileName:@"image.png"];
    
    NSString *file = [[NSBundle mainBundle] pathForResource:@"123" ofType:@"pdf"];
    NSData *pdf = [NSData dataWithContentsOfFile:file];
    [mailCompose addAttachmentData:pdf mimeType:@"" fileName:@"file"];
    
    // 弹出邮件发送视图
    [self presentViewController:mailCompose animated:YES completion:nil];
}
- (void)sendText {
    [MBProgressHUD showOnlyLoadToView:self.view];
    /*
     邮箱号和SMTP的授权码是我自己编的，需要换成你们的
     */
    SKPSMTPMessage *myMessage = [[SKPSMTPMessage alloc] init];
    //发信人
    myMessage.fromEmail=@"1230@163.com";
    //收件人
    myMessage.toEmail=@"2545706530@qq.com";
    //bccEmail、ccEmail可传可不传，如果需要的填写
    //    myMessage.bccEmail=@"123567@163.com";//暗抄送
    //    myMessage.ccEmail = @"123567@163.com";//抄送人
    //发送邮件代理服务器
    // myMessage.relayHost=@"smtp.qq.com";//qq个人
    //    myMessage.relayHost=@"smtp.exmail.qq.com";qq企业账号
    
    myMessage.relayHost=@"smtp.163.com";
    myMessage.requiresAuth=YES;//验证身份是否登录
    if (myMessage.requiresAuth) {
        //发信人
        myMessage.login=@"12300@163.com"; //发信人账号
        myMessage.pass=@"1111000";//发信人的SMTP的授权码
    }
    myMessage.wantsSecure =YES; //需要加密
    /*
     163邮箱报错的
     S: 554 DT:SPM 163 smtp9,DcCowADXPVEoF_FaG5peAg--.47217S3 1525749544,please see http://mail.163.com/help/help_spam_16.htm?ip=125.118.133.189&hostid=smtp9&time=1525749544
     重新修改subject内容
     */
    myMessage.subject = @"你的第三封信";//// 设置邮件主题
    myMessage.delegate = self;// 设置邮件代理
    //设置邮件内容
    NSString *sendMessageStr = @"hello";
    
    NSDictionary *plainPart = [NSDictionary dictionaryWithObjectsAndKeys:@"text/plain; charset=UTF-8",kSKPSMTPPartContentTypeKey,sendMessageStr,kSKPSMTPPartMessageKey,@"8bit",kSKPSMTPPartContentTransferEncodingKey,nil];
    NSString *vcfPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"vcf"];
    NSData *vcfData = [NSData dataWithContentsOfFile:vcfPath];
    
    NSDictionary *vcfPart = [NSDictionary dictionaryWithObjectsAndKeys:@"text/directory;\r\n\tx-unix-mode=0644;\r\n\tname=\"test.vcf\"",kSKPSMTPPartContentTypeKey,
                             @"attachment;\r\n\tfilename=\"test.vcf\"",kSKPSMTPPartContentDispositionKey,[vcfData encodeBase64ForData],kSKPSMTPPartMessageKey,@"base64",kSKPSMTPPartContentTransferEncodingKey,nil];
    myMessage.parts = [NSArray arrayWithObjects:plainPart,vcfPart,nil];
// 邮件首部字段、邮件内容格式和传输编码
//    [myMessage setParts:@[plainPart]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //发送
        [myMessage send];
    });
}



- (void)messageSent:(SKPSMTPMessage *)message
{
    [MBProgressHUD hideHUDForView:self.view];
    
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



@end
