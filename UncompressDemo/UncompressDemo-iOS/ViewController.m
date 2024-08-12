//
//  ViewController.m
//  UncompressDemo-iOS
//
//  Created by anwu on 2024/8/9.
//

#import "ViewController.h"
#import "UncompressDemo_iOS-Swift.h"
#import "VTMUncompressUtils.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray<NSDictionary *> *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataSource = @[@{@"title": @"ER1", @"name": @"20240419175643", @"type": @(1)},
                        @{@"title": @"ER3", @"name": @"20240418104759", @"type": @(2)}];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = 45.0;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellIdentifier"];
    [self.view addSubview:tableView];
}

//MARK: - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.dataSource[indexPath.row][@"title"];
    
    return cell;
}

//MARK: - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger type = [self.dataSource[indexPath.row][@"type"] integerValue];
    NSString *name = self.dataSource[indexPath.row][@"name"];
    BOOL result = NO;
    VTRecordEcgController *vc = [[VTRecordEcgController alloc] init];
    vc.title = name;
    if (type == 1) {
        // ER1
        result = [VTMUncompressUtils uncompressER1WithResource:name];
        if (result) {
            NSData *shortData = [VTMUncompressUtils er1DataWithResource:name];
            NSArray *points = [self pointsWithShortData:shortData isER3:YES];
            vc.ecgPoints = points;
            vc.sampleRate = 125;
        }
    } else if (type == 2) {
        // ER3
        result = [VTMUncompressUtils uncompressER3WithResource:name andLead:VTER3ShowLead_I];
        if (result) {
            NSData *shortData = [VTMUncompressUtils er3DataWithResource:name andLead:VTER3ShowLead_I];
            NSArray *points = [self pointsWithShortData:shortData isER3:YES];
            vc.ecgPoints = points;
            vc.sampleRate = 250;
        }
    }
    if (result) {
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        NSLog(@"Uncompress error");
    }
    
}

- (NSArray<NSNumber *> *)pointsWithShortData:(NSData *)shortData isER3:(BOOL)isER3 {
    shortData = [shortData subdataWithRange:NSMakeRange(sizeof(VTERFileHead), shortData.length - sizeof(VTERFileHead) - sizeof(VTERFileHead))];
    NSLog(@"length:%li", shortData.length);
    NSMutableArray<NSNumber *> *floatArrays = [NSMutableArray arrayWithCapacity:shortData.length / sizeof(short)];
    short *bytes = (short *)[shortData bytes];
    short mv = 0;
    float floatValue = 0.0;
    for (NSUInteger i = 0; i < shortData.length / sizeof(short); i++) {
        mv = bytes[i];
        floatValue = 0;
        if (mv != 0x7fff) {
            if (isER3) {
                floatValue = [VTBLEParser er3MvFromShort:mv];
            } else {
                floatValue = [VTBLEParser mVFromShort:mv];
            }
        }
        [floatArrays addObject:@(floatValue)];
    }
    return floatArrays;
}

@end
