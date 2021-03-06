//
//  BXFoodInfoViewController.m
//  lingdang
//
//  Created by zengming on 13-8-17.
//  Copyright (c) 2013年 baixing.com. All rights reserved.
//

#import <MobileCoreServices/UTCoreTypes.h>

#import "BXFoodInfoViewController.h"
#import "BXShop.h"
#import "BXShopProvider.h"
#import "BXFoodProvider.h"

@interface BXFoodInfoViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField    *nameTf;
@property (weak, nonatomic) IBOutlet UITextField    *priceTf;
@property (weak, nonatomic) IBOutlet UIImageView    *imageView;
@property (weak, nonatomic) IBOutlet UIButton       *foodCmdButton;

@property (nonatomic, strong) NSArray               *shopData;

@property (nonatomic, strong) AVFile                *image;

// private
- (IBAction)foodCmdButtonClicked:(id)sender;

@end

@implementation BXFoodInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.navigationController.navigationBar.translucent = YES;
        
    self.title = _food ? @"更新菜品" : @"新增菜品";
    if (_food)
    {
        [self.foodCmdButton setTitle:@"更新菜品" forState:UIControlStateNormal];
        self.nameTf.text = _food.name;
        self.priceTf.text = [NSString stringWithFormat:@"%g",_food.price];
        
        __weak BXFoodInfoViewController *weakself = self;
        AVFile *file = _food.image;
        if (file != nil) {
            [file getThumbnail:YES width:_imageView.bounds.size.width height:_imageView.bounds.size.height withBlock:^(UIImage *image, NSError *error) {
                if (error == nil) {
                    weakself.imageView.image = image;
                }
            }];
        }
    }
}

#pragma mark - refresh data

- (IBAction)foodCmdButtonClicked:(id)sender
{
    if (self.food)
    {
        [self editFood];
    }
    else
    {
        [self addFood];
    }
   
}

- (void)addFood
{
    [SVProgressHUD showWithStatus:@"新增菜品中" maskType:SVProgressHUDMaskTypeGradient];
    [[BXFoodProvider sharedInstance] addFoodWithName:_nameTf.text
                                               price:([_priceTf.text floatValue])
                                                shop:_shop
                                               image:self.image
                                           upImgUser:nil
                                             success:^(BXFood *food) {
        NSString *title = [NSString stringWithFormat:@"%@已新增", food.name];
        [SVProgressHUD showSuccessWithStatus:title];
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.navigationController popViewControllerAnimated:YES];
        });
    } fail:^(NSError *err) {
        [SVProgressHUD showErrorWithStatus:@"新增店铺失败"];
    }];
}

- (void)editFood
{
    [SVProgressHUD showWithStatus:@"更新菜品中" maskType:SVProgressHUDMaskTypeGradient];
    self.food.name = _nameTf.text;
    self.food.price = [_priceTf.text floatValue];
    self.food.image = self.image;
    [[BXFoodProvider sharedInstance] updateFood:self.food onSuccess:^{
        NSString *title = [NSString stringWithFormat:@"更新成功"];
        [SVProgressHUD showSuccessWithStatus:title];
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.navigationController popViewControllerAnimated:YES];
        });
    } onFail:^(NSError *err) {
        [SVProgressHUD showErrorWithStatus:@"菜品更新失败"];
    }];
}

#pragma mark button actions
- (IBAction)backgroundTapped:(id)sender
{
    [self.view endEditing:YES];
}

- (IBAction)imageButtonAction:(id)sender
{
    [self.view endEditing:YES];
    UIActionSheet *acSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                         delegate:self
                                                cancelButtonTitle:@"取消"
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:@"拍照", @"从手机相册选择", nil];
    [acSheet showInView:self.view];
}

#define TakePhotoButtonIndex                        0
#define SelectPhotoFromLibraryButtonIndex           1
#define CancelButtonIndex                           2

#pragma mark - uiactionsheet action delegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerControllerSourceType sourceType;
    switch (buttonIndex) {
        case TakePhotoButtonIndex:
            sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
        case SelectPhotoFromLibraryButtonIndex:
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
    }
    
    if (buttonIndex == TakePhotoButtonIndex ||
        buttonIndex == SelectPhotoFromLibraryButtonIndex) {
        if ([UIImagePickerController isSourceTypeAvailable:sourceType] == false) {
            [SVProgressHUD showErrorWithStatus:@"哥，换个新手机吧"];
            return ;
        }
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = sourceType;
        imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        imagePicker.allowsEditing = NO;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerViewController delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    __weak BXFoodInfoViewController *weakself = self;
    [self dismissViewControllerAnimated:YES completion:^{
        weakself.navigationController.view.userInteractionEnabled = NO;
        
        //上传image到AVCloud
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
        AVFile *imageFile = [AVFile fileWithName:_food.objectId data:imageData];
        
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            weakself.navigationController.view.userInteractionEnabled = YES;
            if (error != nil) {
                [SVProgressHUD showErrorWithStatus:@"上传失败！"];
            }
            if (succeeded) {
                [SVProgressHUD showSuccessWithStatus:@"上传成功！"];
                weakself.imageView.image = image;
            }
        } progressBlock:^(int percentDone) {
            [SVProgressHUD showProgress:percentDone / 100.0f status:@"正在上传"];
        }];
        
        if (weakself.food != nil) {
            AVFile *oldFile = weakself.food.image;
            if (oldFile != nil && [oldFile isKindOfClass:[NSNull class]] == false) {
                [oldFile deleteInBackgroundWithBlock:nil];
            }
        }
        weakself.image = imageFile;
    }];
}
@end
