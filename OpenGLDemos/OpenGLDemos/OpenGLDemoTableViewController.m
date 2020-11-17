//
//  OpenGLDemoTableViewController.m
//  OpenGLDemos
//
//  Created by cqh on 2017/10/4.
//  Copyright © 2017年 cqh. All rights reserved.
//

#import "OpenGLDemoTableViewController.h"

@interface OpenGLDemoTableViewController ()

@property (nonatomic, strong) NSMutableArray *titles;
@property (nonatomic, strong) NSMutableArray *classNames;

@end

@implementation OpenGLDemoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"CQH OpenGL Demos";
    
    [self addCell:@"用GLKit显示图片" className:@"GLKitViewController"];
    [self addCell:@"简单使用shader" className:@"ShaderDemoViewController"];
    [self addCell:@"简单使用矩阵旋转" className:@"Shader3DMatrixDemoViewController"];
    [self addCell:@"简单画图，可切换画笔颜色和擦除" className:@"PaintViewController"];
//    [self addCell:@"Text Parser (Markdown)" className:@"YYTextMarkdownExample"];
//    [self addCell:@"Text Parser (Emoticon)" className:@"YYTextEmoticonExample"];
//    [self addCell:@"Text Binding" className:@"YYTextBindingExample"];
//    [self addCell:@"Copy and Paste" className:@"YYTextCopyPasteExample"];
//    [self addCell:@"Undo and Redo" className:@"YYTextUndoRedoExample"];
//    [self addCell:@"Ruby Annotation" className:@"YYTextRubyExample"];
//    [self addCell:@"Async Display" className:@"YYTextAsyncExample"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - methods
- (void)addCell:(NSString *)title className:(NSString *)className
{
    if (title && className) {
        
        [self.titles addObject:title];
        [self.classNames addObject:className];
    }
}

#pragma getters and setters
- (NSMutableArray *)titles
{
    if (!_titles) {
        _titles = [NSMutableArray array];
    }
    return _titles;
}

- (NSMutableArray *)classNames
{
    if (!_classNames) {
        _classNames = [NSMutableArray array];
    }
    return _classNames;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIndentifier = @"myOpenGLDemo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIndentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIndentifier];
    }
    cell.textLabel.text = self.titles[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSString *className = self.classNames[indexPath.row];
    Class class = NSClassFromString(className);
    if (class && [class isSubclassOfClass:[UIViewController class]]) {
        UIViewController *vc = class.new;
        vc.title = self.titles[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
