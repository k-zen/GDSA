#import "AKCustomView.h"

@implementation AKCustomView
// MARK: UIView Overriding
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSString *className = NSStringFromClass([self class]);
        // Load NIB file.
        self.customView = [[[NSBundle mainBundle] loadNibNamed:className.pathExtension owner:self options:nil] firstObject];
        // Configure view.
        [self.customView setUserInteractionEnabled:YES];
        // Add view.
        [self addSubview:self.customView];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        NSString *className = NSStringFromClass([self class]);
        // Load NIB file.
        self.customView = [[[NSBundle mainBundle] loadNibNamed:className.pathExtension owner:self options:nil] firstObject];
        // Configure view.
        [self.customView setUserInteractionEnabled:YES];
        // Add view.
        [self addSubview:self.customView];
    }
    
    return self;
}
@end
