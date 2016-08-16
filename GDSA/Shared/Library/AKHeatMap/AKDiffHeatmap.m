#import "AKDiffHeatmap.h"
#import "AKDiffColorProvider.h"

@interface AKDiffHeatmap ()
@property double maxValue;
@property double zoomedOutMax;
@property NSDictionary *pointsWithHeat;
@property CLLocationCoordinate2D center;
@property MKMapRect boundingRect;
@end

@implementation AKDiffHeatmap

@synthesize maxValue, pointsWithHeat = _pointsWithHeat;
@synthesize zoomedOutMax;
@synthesize center, boundingRect;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.colorProvider = [AKDiffColorProvider new];
    }
    
    return self;
}

- (void)setBeforeData:(NSDictionary *)before
            afterData:(NSDictionary *)after
{
    self.maxValue = 0;
    
    NSMutableDictionary *newHeatMapData = [NSMutableDictionary new];
    for (NSValue *mapPointValue in [before allKeys]) {
        newHeatMapData[mapPointValue] = @(-1 * [before[mapPointValue] doubleValue]);
    }
    
    for (NSValue *mapPointValue in [after allKeys]) {
        if (newHeatMapData[mapPointValue]) {
            double beforeValue = [newHeatMapData[mapPointValue] doubleValue];
            double afterValue = [after[mapPointValue] doubleValue];
            newHeatMapData[mapPointValue] = @(beforeValue + afterValue);
        } else {
            newHeatMapData[mapPointValue] = after[mapPointValue];
        }
    }
    
    [super setData:newHeatMapData];
}

@end
