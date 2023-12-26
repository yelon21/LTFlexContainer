//
//  ViewController.m
//  LTStudy
//
//  Created by 龙 on 2023/10/24.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import <objc/NSObjCRuntime.h>

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>{
    
    NSArray *menus;
}

@property(nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

-(UITableView *)tableView{
    
    if(!_tableView){
        
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _tableView.delegate = self;
        _tableView.dataSource = self;
//        UIEdgeInsets layoutMargins = _tableView.layoutMargins;
//        layoutMargins.left = 100;
//        layoutMargins.right = 50;
//        _tableView.layoutMargins = layoutMargins;
    }
    return _tableView;
}

- (NSDictionary *)getPlistObject{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Menu" ofType:@"plist"];
    
    NSPropertyListFormat format;
    NSError *error = nil;
   
    NSData *plistData = [[NSFileManager defaultManager] contentsAtPath:path];
    
    NSDictionary *rootObj = [NSPropertyListSerialization propertyListWithData:plistData
                                                    options:NSPropertyListMutableContainersAndLeaves
                                                     format:&format
                                                      error:&error];
    
    if (error) {
        
        NSLog(@"error=%@",error);
        return nil;
    }
    
    
    return rootObj;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"好好学习，天天向上";
    
    NSDictionary *plistObj = [self getPlistObject];
    menus = plistObj[@"menus"];
    
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:@"UITableViewCell"];
//    self.tableView.userInteractionEnabled = NO;
    [self.view addSubview:self.tableView];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    NSLog(@"view:%@", NSStringFromUIEdgeInsets(self.view.layoutMargins));
    NSLog(@"tableView:%@", NSStringFromUIEdgeInsets(self.tableView.layoutMargins));
}

- (void)didSelectItem:(NSDictionary *)item{
    
    NSString *classString = item[@"class"];
    Class class = NSClassFromString(classString);
    UIViewController *obj = (UIViewController *)[[class alloc] init];
    obj.title = item[@"name"];
    [self.navigationController pushViewController:obj animated:YES];
}
#pragma mark - UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return menus.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSArray *subMenus = menus[section][@"menus"];
    return [subMenus count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return menus[section][@"name"];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    
    NSArray *subMenus = menus[indexPath.section][@"menus"];
    cell.textLabel.text = subMenus[indexPath.row][@"name"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *menuItem = menus[indexPath.section][@"menus"][indexPath.row];
    
    [self didSelectItem:menuItem];
}

@end
