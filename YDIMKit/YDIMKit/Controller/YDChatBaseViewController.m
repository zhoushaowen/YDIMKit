//
//  YDChatBaseViewController.m
//  Chat
//
//  Created by 周少文 on 2016/10/24.
//  Copyright © 2016年 周少文. All rights reserved.
//

#import "YDChatBaseViewController.h"
#import <SWExtension/UIView+SWAutoLayout.h>
#import "UIViewController+Authorization.h"
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>
#import "YDChatRefreshControl.h"
#import "YDChatBottomToolView.h"

extern CGFloat const YDKeyboardHeight;

@interface YDChatBaseViewController ()<YDChatBottomToolViewDelegate>
{
    UITableView *_tableView;
    YDChatBottomToolView *_bottomToolView;
    NSLayoutConstraint *_bottomToolHeightConstraint;
    NSLayoutConstraint *_bottomToolBottomConstraint;
    CGFloat _bottomToolTextViewTextOriginalHeight;
    NSInteger _keyboardAnimationCurver;
    void(^_refreshComplete)();
    CGFloat _criticalHeight;//记录textView超过临界值的高度
}

@property (nonatomic,strong) NSCache *rowHeightCache;
@property (nonatomic,strong) NSMutableArray *messageTypes;
@property (nonatomic,strong) YDChatRefreshControl *chatRefreshControl;
@property (nonatomic,strong) UITableViewController *tableViewController;

@end

@implementation YDChatBaseViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        self.numberOfPageCount = 15;
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        self.numberOfPageCount = 15;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI {
    self.extendedLayoutIncludesOpaqueBars = YES;
    _tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    [self addChildViewController:_tableViewController];
    [_tableViewController didMoveToParentViewController:self];
    [self.view addSubview:_tableViewController.view];
    _tableViewController.view.frame = CGRectZero;
    _tableViewController.tableView.delegate = self;
    _tableViewController.tableView.dataSource = self;
    _tableViewController.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.chatTableViewBackgroundColor = _tableViewController.tableView.backgroundColor;
    _chatTableView = _tableViewController.tableView;
    _tableView = _tableViewController.tableView;
    _bottomToolView = [[YDChatBottomToolView alloc] initWithFrame:CGRectZero];
    _chatBottomToolView = _bottomToolView;
    _bottomToolView.delegate = self;
    [self.view addSubview:_bottomToolView];
    [_bottomToolView sw_addConstraintsWithFormat:@"H:|-0-[_bottomToolView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_bottomToolView)];
    NSArray<NSLayoutConstraint *> *bottomToolVConstraints = [_bottomToolView sw_addConstraintsWithFormat:@"V:[_bottomToolView(h)]-0-|" options:0 metrics:@{@"h":@(YDBottomToolViewOriginalHeight)} views:NSDictionaryOfVariableBindings(_bottomToolView)];
    _bottomToolHeightConstraint = [bottomToolVConstraints firstObject];
    _bottomToolBottomConstraint = [bottomToolVConstraints lastObject];
    _bottomToolTextViewTextOriginalHeight = 35;
    [_tableView sw_addConstraintsWithFormat:@"H:|-0-[_tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)];
    NSArray *constraints = [_tableView sw_addConstraintsWithFormat:@"V:|-0-[_tableView]-0-[_bottomToolView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView,_bottomToolView)];
    _chatTableViewTopConstraint = [constraints firstObject];
    self.actionItems = _bottomToolView.plusView.actionItems;
    _audioPressShortView = _bottomToolView.audioPressShortView;
    _cancelSendView = _bottomToolView.cancelSendView;
    _recordingView = _bottomToolView.recordingView;
    _voiceButton = _bottomToolView.centerButton;
    _chatToolBarBackgroundColor = _bottomToolView.backgroundColor;
    _emojiSendBtnBackgroundColor = _bottomToolView.emojiSendBtnBackgroundColor;
    self.defaultInputStyle = YDChatInputStyleText;
    self.view.backgroundColor = self.chatTableViewBackgroundColor;
}

void dynamicMethodIMP(id self,SEL _cmd,id parameter)
{
    unsigned int count;
    Ivar *vars = class_copyIvarList([self class], &count);//获取所有成员变量
    for(int i = 0; i < count; i++)
    {
        Ivar var = vars[i];
        NSString *name = [NSString stringWithUTF8String:ivar_getName(var)];//获取某个成员变量的名称
        if([name isEqualToString:@"_indexPath"])
        {
            object_setIvar(self, var, parameter);//给成员变量赋值
            break;
        }
    }
    //copy之后必须要释放
    free(vars);
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<YDMessageProtocol> model = self.dataArray[indexPath.row];
    //由于YDMessageProtocol的indexPath的属性设为了只读,所以这里使用runtime来动态添加indexPath的Setter方法
    class_addMethod([model class], @selector(setIndexPath:), (IMP)dynamicMethodIMP, "v@:@");
    [model performSelector:@selector(setIndexPath:) withObject:indexPath];
    const char * classCString = object_getClassName(model);
    NSString *className = [NSString stringWithCString:classCString encoding:NSUTF8StringEncoding];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[className stringByAppendingString:@"-YDChatCell"] forIndexPath:indexPath];
    SEL selector = NSSelectorFromString(@"setDataModel:");
    NSString *str = [NSString stringWithFormat:@"%@必须实现setDataModel:方法",className];
    NSAssert([cell respondsToSelector:selector], str);
    NSMethodSignature *signature = [cell methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = cell;
    invocation.selector = selector;
    //0和1默认已经被系统占据了
    [invocation setArgument:&model atIndex:2];
    //调用setDataModel方法
    [invocation invoke];
    [self ydConversationCell:cell forMessageModel:model atIndex:indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self getTableViewCellHeight:tableView forRowAtIndexPath:indexPath];
}

- (CGFloat)getTableViewCellHeight:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    CGFloat height = [[self.rowHeightCache objectForKey:key] doubleValue];
    if(height)
    {
        return height;
    }
    id model = self.dataArray[indexPath.row];
    const char * classCString = object_getClassName(model);
    NSString *className = [NSString stringWithCString:classCString encoding:NSUTF8StringEncoding];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[className stringByAppendingString:@"-YDChatCell"]];
    SEL selector = NSSelectorFromString(@"rowHeightWithModel:");
    NSString *str = [NSString stringWithFormat:@"%@必须实现rowHeightWithModel:方法",className];
    NSAssert([cell respondsToSelector:selector], str);
    NSMethodSignature *signature = [cell methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = cell;
    invocation.selector = selector;
    [invocation setArgument:&model atIndex:2];
    [invocation invoke];
    NSAssert(signature.methodReturnLength > 0, @"rowHeightWithModel:方法必须要有返回值");
#if CGFLOAT_IS_DOUBLE
    NSAssert(strcmp(signature.methodReturnType, "d") == 0, @"rowHeightWithModel:方法的返回值必须是CGFload或者double");
#else
    NSAssert(strcmp(signature.methodReturnType, "f") == 0, @"rowHeightWithModel:方法的返回值必须是CGFload或者float");
#endif
    [invocation getReturnValue:&height];
    [self.rowHeightCache setObject:@(height) forKey:key];
    return height;

}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_bottomToolView resignTextViewFirstResponder];
}

#pragma mark - YDChatBottomToolViewDelegate
- (void)chatBottomToolView:(YDChatBottomToolView *)toolView textViewTextDidChange:(UITextView *)textView
{
    CGRect rect = [textView.text boundingRectWithSize:CGSizeMake(textView.frame.size.width - textView.textContainerInset.left - textView.textContainerInset.right - textView.textContainer.lineFragmentPadding*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:textView.font} context:nil];
    CGFloat height = ceil(rect.size.height);
    UIEdgeInsets insets = textView.textContainerInset;
    if(height < 100)
    {
        if(height > _bottomToolTextViewTextOriginalHeight)
        {
            insets.top = 0;
            insets.bottom = 0;
            textView.textContainerInset = insets;
            textView.contentOffset = CGPointZero;
            _bottomToolHeightConstraint.constant = height + 25+7 + textView.textContainerInset.top + textView.textContainerInset.bottom;
        }else{
            insets.top = 8;
            insets.bottom = 8;
            textView.textContainerInset = insets;
            _bottomToolHeightConstraint.constant = YDBottomToolViewOriginalHeight;
        }
    }else{
        insets.top = 0;
        insets.bottom = 0;
        textView.textContainerInset = insets;
        if(_criticalHeight == 0){
            _criticalHeight = height;
        }
        _bottomToolHeightConstraint.constant = _criticalHeight+ 25+7 + textView.textContainerInset.top + textView.textContainerInset.bottom;
    }
    [UIView animateWithDuration:0.25f animations:^{
        [UIView setAnimationCurve:_keyboardAnimationCurver];
        [_bottomToolView layoutIfNeeded];
        [self.view layoutIfNeeded];
        [textView scrollRangeToVisible:NSMakeRange(textView.text.length, 1)];
        [self tableViewScrollToLastIndexAnimated:NO];
    }];

}

- (void)chatBottomToolView:(YDChatBottomToolView *)toolView keyboardWillChangeFrameNotification:(NSNotification *)notification
{
    NSDictionary *dic = notification.userInfo;
    CGFloat offY = [UIScreen mainScreen].bounds.size.height - [dic[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    _bottomToolBottomConstraint.constant = offY;
    _keyboardAnimationCurver = [dic[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    if(offY == 0)//键盘下落
    {
        _bottomToolHeightConstraint.constant = YDBottomToolViewOriginalHeight;
    }else{//键盘弹起
        [self chatBottomToolView:toolView textViewTextDidChange:toolView.textView];
    }
    [UIView animateWithDuration:[dic[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        [UIView setAnimationCurve:_keyboardAnimationCurver];
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        [_tableView layoutIfNeeded];
        [_bottomToolView layoutIfNeeded];
        if([_tableView numberOfRowsInSection:0] < 1)
            return;
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_tableView numberOfRowsInSection:0] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }];
}

- (void)chatBottomToolView:(YDChatBottomToolView *)toolView didClickSendButton:(NSString *)text
{
    [self chatControllerBeginSendText:text];
}

- (void)chatBottomToolView:(YDChatBottomToolView *)toolView actionItemClick:(id<YDActionItemProtocol>)item
{
    [self chatControllerActionItemClick:item];
}

- (void)chatBottomToolView:(YDChatBottomToolView *)toolView recordButtonTouchUpInside:(UIButton *)recordBtn completeRecord:(BOOL)isComplete
{
    if(!isComplete)
        return;
    [self chatControllerCompleteRecording];
}

- (void)chatBottomToolView:(YDChatBottomToolView *)toolView recordButtonTouchUpOutside:(UIButton *)recordBtn
{
    [self chatControllerCancelRecording];
}

- (void)chatBottomToolView:(YDChatBottomToolView *)toolView recordButtonTouchDragEnter:(UIButton *)recordBtn
{
    [self chatControllerContinueRecording];
}

- (void)chatBottomToolView:(YDChatBottomToolView *)toolView recordButtonTouchDragExit:(UIButton *)recordBtn
{
    [self chatControllerSuspendRecording];
}

- (void)chatBottomToolView:(YDChatBottomToolView *)toolView recordButtonTouchDown:(UIButton *)recordBtn
{
    [self chatControllerStartRecording];
}

- (void)chatBottomToolView:(YDChatBottomToolView *)toolView recordButtonShortPress:(UIButton *)recordBtn
{
    [self chatControllerShortPressRecordingBtn];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *orignalImage = info[UIImagePickerControllerOriginalImage];
    CGFloat scale = orignalImage.size.height/orignalImage.size.width;
    CGRect rect = CGRectMake(0, 0, 500, 500*scale);
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.0);
    [orignalImage drawInRect:rect];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self chatControllerDidFinishPickingImage:resultImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_bottomToolView resignTextViewFirstResponder];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(_tableViewController.refreshControl.isRefreshing && _tableViewController.refreshControl != nil)
    {
        [self refresh];
    }
}

#pragma mark - Setter
- (void)setDataArray:(NSArray *)dataArray
{
    _dataArray = dataArray;
    [self reloadTableView];
}

- (void)setActionItems:(NSArray<id<YDActionItemProtocol>> *)actionItems
{
    _actionItems = actionItems;
    _bottomToolView.plusView.actionItems = actionItems;
}

- (void)setDefaultInputStyle:(YDChatInputStyle)defaultInputStyle
{
    _defaultInputStyle = defaultInputStyle;
    _bottomToolView.inputStyle = defaultInputStyle;
}

- (void)setChatToolBarBackgroundColor:(UIColor *)chatToolBarBackgroundColor
{
    _chatToolBarBackgroundColor = chatToolBarBackgroundColor;
    _bottomToolView.backgroundColor = chatToolBarBackgroundColor;
}

- (void)setInputViewBackgroundColor:(UIColor *)inputViewBackgroundColor
{
    _inputViewBackgroundColor = inputViewBackgroundColor;
    _bottomToolView.emojiKeyboardView.collectionView.backgroundColor = inputViewBackgroundColor;
    _bottomToolView.plusView.collectionView.backgroundColor = inputViewBackgroundColor;
}

- (void)setEmojiSendBtnBackgroundColor:(UIColor *)emojiSendBtnBackgroundColor
{
    _emojiSendBtnBackgroundColor = emojiSendBtnBackgroundColor;
    _bottomToolView.emojiSendBtnBackgroundColor = emojiSendBtnBackgroundColor;
}

- (void)setChatStyle:(YDChatStyle)chatStyle
{
    _chatStyle = chatStyle;
    _bottomToolView.chatStyle = chatStyle;
}

#pragma mark - Public
- (void)setInitializedDataArray:(NSArray<id<YDMessageProtocol>> *)dataArray
{
    if(dataArray.count < 1)
        return;
    _dataArray = dataArray;
    if(dataArray.count >= self.numberOfPageCount)
    {
        _tableViewController.refreshControl = self.chatRefreshControl;
    }else{
        _tableViewController.refreshControl = nil;
    }
    [self tableViewScrollToLastIndexAnimated:NO];
}

- (void)ydConversationCell:(UITableViewCell *)cell forMessageModel:(id<YDMessageProtocol>)model atIndex:(NSInteger)index{}

- (void)chatControllerBeginSendText:(NSString *)text
{
    NSAssert(NO, @"要发送消息子类必须重写- (void)sendMessageButtonClick:(NSString *)text方法");
}

- (void)chatControllerAddMessages:(NSArray<id<YDMessageProtocol>> *)messages
{
    if(messages.count < 1) return;
    NSMutableArray *mutableArr = nil;
    if(self.dataArray)
    {
        mutableArr = [self.dataArray mutableCopy];
    }else{
        mutableArr = [NSMutableArray arrayWithCapacity:0];
    }
    [mutableArr addObjectsFromArray:messages];
    _dataArray = mutableArr;
    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:mutableArr.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
    [self tableViewScrollToLastIndexAnimated:YES];
}

- (void)reloadTableView
{
    [self.rowHeightCache removeAllObjects];
    [_tableView reloadData];
    [self tableViewScrollToLastIndexAnimated:NO];
}

- (void)chatControllerDeleteMessageAtIndex:(NSInteger)index
{
    if(self.dataArray == nil)
        return;
    NSMutableArray *arr = [self.dataArray mutableCopy];
    [arr removeObjectAtIndex:index];
    _dataArray = arr;
    [self.rowHeightCache removeAllObjects];
    [_tableView beginUpdates];
    [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
}

- (void)chatControllerDeleteMessage:(id<YDMessageProtocol>)message
{
    if(message == nil)
        return;
    NSInteger index = [_dataArray indexOfObject:message];
    [self chatControllerDeleteMessageAtIndex:index];
}

- (void)chatControllerDeleteMessages:(NSArray<id<YDMessageProtocol>> *)messages
{
    if(messages.count < 1)
        return;
    [messages enumerateObjectsUsingBlock:^(id<YDMessageProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self chatControllerDeleteMessage:obj];
    }];
}

- (void)chatControllerReplaceMessageWithNewMessage:(id<YDMessageProtocol>)newMessage atIndex:(NSInteger)index
{
    NSMutableArray *mutableArr = [_dataArray mutableCopy];
    [mutableArr replaceObjectAtIndex:index withObject:newMessage];
    _dataArray = mutableArr;
    [_tableView beginUpdates];
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
}

- (void)chatControllerClearAllMessages
{
    _dataArray = nil;
    [self reloadTableView];
}

- (void)registerMessageClass:(Class)messageClass forCellClass:(Class)cellClass
{
    const char *messageClassCString = class_getName(messageClass);
    NSString *cellClassName = [NSString stringWithCString:messageClassCString encoding:NSUTF8StringEncoding];
    [_tableView registerClass:cellClass forCellReuseIdentifier:[cellClassName stringByAppendingString:@"-YDChatCell"]];
}

- (void)chatControllerActionItemClick:(id<YDActionItemProtocol>)item
{
    if([item.titleName isEqualToString:@"照片"])
    {
        [self showImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }else if([item.titleName isEqualToString:@"拍照"])
    {
        [self showImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    }
}

- (void)showImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType{
    if(sourceType == UIImagePickerControllerSourceTypePhotoLibrary || sourceType == UIImagePickerControllerSourceTypeSavedPhotosAlbum){
        if(![self isHavePhotoLibarayAuthorization])
            return;
    }else if (sourceType == UIImagePickerControllerSourceTypeCamera){
        if(![self isHaveCameraAuthorization])
            return;
    }
    if(![UIImagePickerController isSourceTypeAvailable:sourceType])
        return;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = sourceType;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)chatControllerDidFinishPickingImage:(UIImage *)image{}
- (void)chatControllerStartRecording{}
- (void)chatControllerCompleteRecording{}
- (void)chatControllerCancelRecording{}
- (void)chatControllerContinueRecording{}
- (void)chatControllerSuspendRecording{}
- (void)chatControllerShortPressRecordingBtn{}

#pragma mark - Private
- (void)tableViewScrollToLastIndexAnimated:(BOOL)animated
{
    if([_tableView numberOfRowsInSection:0] < 1)
        return;
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_tableView numberOfRowsInSection:0] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}

- (NSCache *)rowHeightCache
{
    if(!_rowHeightCache)
    {
        _rowHeightCache = [[NSCache alloc] init];
    }
    return _rowHeightCache;
}

- (NSMutableArray *)messageTypes
{
    if(!_messageTypes)
    {
        _messageTypes = [NSMutableArray arrayWithCapacity:0];
    }
    return _messageTypes;
}

- (YDChatRefreshControl *)chatRefreshControl
{
    if(!_chatRefreshControl)
    {
        _chatRefreshControl = [[YDChatRefreshControl alloc] init];
    }
    return _chatRefreshControl;
}

- (void)setChatTableViewBackgroundColor:(UIColor *)chatTableViewBackgroundColor
{
    _chatTableViewBackgroundColor = chatTableViewBackgroundColor;
    _tableView.backgroundColor = chatTableViewBackgroundColor;
    self.chatRefreshControl.refreshView.backgroundColor = chatTableViewBackgroundColor;
    self.view.backgroundColor = chatTableViewBackgroundColor;
}

- (void)refresh
{
    [self chatControllerBeginPullToRefreshCompletionHandler:^(NSArray *newMessages) {
        [_tableViewController.refreshControl endRefreshing];
        if(newMessages.count > 0)
        {
            NSMutableArray *mutableArr = [NSMutableArray arrayWithArray:_dataArray];
            [mutableArr insertObjects:newMessages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newMessages.count)]];
            self.dataArray = mutableArr;
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:newMessages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            if(newMessages.count < self.numberOfPageCount)
            {
                _tableViewController.refreshControl = nil;
            }
        }else{
            _tableViewController.refreshControl = nil;
        }
        
    }];
}

- (void)chatControllerBeginPullToRefreshCompletionHandler:(void(^)(NSArray<id<YDMessageProtocol>> *newMessages))completionHandler{}


@end
