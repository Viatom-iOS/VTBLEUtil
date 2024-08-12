//
//  ViewController.m
//  UncompressDemo
//
//  Created by anwu on 2024/8/7.
//

#import "ViewController.h"
#import "VTMUncompressUtils.h"
#import "UncompressDemo-Swift.h"

@interface ViewController () <NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary *> *dataSources;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSources = @[@{@"title": @"ER1", @"name": @"20240419175643", @"type": @(1)},
                         @{@"title": @"ER3", @"name": @"20240418104759", @"type": @(2)}];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 40.0;
    BOOL result = [VTMUncompressUtils uncompressER3WithResource:@"20240418104759" andLead:VTER3ShowLead_I];
    NSLog(@"result:%i", result);
    
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

//MARK: - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.dataSources.count;
}

//MARK: - NSTabViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *view = [tableView makeViewWithIdentifier:@"cellID" owner:nil];
    view.textField.stringValue = self.dataSources[row][@"title"];
    return view;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger row = self.tableView.selectedRow;
    NSUInteger type = [self.dataSources[row][@"type"] integerValue];
    NSString *name = self.dataSources[row][@"name"];
    BOOL result = NO;
    VTRecordEcgController *vc = [[NSStoryboard mainStoryboard] instantiateControllerWithIdentifier:@"VTRecordEcgController"];
    vc.title = name;
    if (type == 1) {
        result = [VTMUncompressUtils uncompressER1WithResource:name];
        if (result) {
            NSData *shortData = [VTMUncompressUtils er1DataWithResource:name];
            NSArray *points = [self pointsWithShortData:shortData isER3:NO];
            vc.ecgPoints = points;
            vc.sampleRate = 125;
        }
    } else if (type == 2) {
        result = [VTMUncompressUtils uncompressER3WithResource:name andLead:VTER3ShowLead_II];
        if (result) {
            NSData *shortData = [VTMUncompressUtils er3DataWithResource:name andLead:VTER3ShowLead_II];
            NSArray *points = [self pointsWithShortData:shortData isER3:YES];
            vc.ecgPoints = points;
            vc.sampleRate = 250;
        }
    }
    if (result) {
        [self presentViewControllerAsModalWindow:vc];
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
