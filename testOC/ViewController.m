//
//  ViewController.m
//  testOC
//
//  Created by mac on 2021/10/26.
//

#import "ViewController.h"
#import "TestPopView.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) UITableView * tableView;
@property(nonatomic, copy) NSArray * dataArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataArr = @[@"中间弹出",@"从上弹到中间",@"从下弹到中间",@"从下弹出"];
    [self.tableView reloadData];
    
    
}

-(void)loadView{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, NavigationBarHEIGHT, SCREENWIDTH, SCREENWIDTH) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 60;
    }
    return _tableView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellfile = @"tesTcell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellfile];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellfile];
    }
    cell.textLabel.text = self.dataArr[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    int row = (int)indexPath.row;
    
    TestPopView * popView = [[TestPopView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
    popView.backgroundColor = [UIColor redColor];
    
    //根据需要设置不同的弹出动画
    switch (row) {
        case 0:
            
            
            break;
        case 1:
            popView.popStyle = WKAnimationPopStyleShakeFromTop;
            popView.dismissStyle = WKAnimationDismissStyleDropToTop;
            
            break;
        case 2:
            popView.popStyle = WKAnimationPopStyleShakeFromBottom;
            popView.dismissStyle = WKAnimationDismissStyleDropToBottom;
            
            break;
        case 3:
            popView.popStyle = WKAnimationPopStyleBottomToTop;
            popView.dismissStyle = WKAnimationDismissStyleBottomToTop;
            
            break;
            
        default:
            break;
    }
    popView.addOnView = self.view;
    [popView show];
}



@end
