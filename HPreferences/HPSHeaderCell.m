#import "HPSHeaderCell.h"

@implementation HPSHeaderCell {
  UILabel *label;
  UILabel *underLabel;
}

- (id)initWithSpecifier:(PSSpecifier *)specifier {
  self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HPSHeaderCell"];
  if (self) {
    int kWidth = [[UIApplication sharedApplication] keyWindow].frame.size.width;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      kWidth = kWidth / 2;
    }

    CGRect labelFrame = CGRectMake(0, 10, kWidth, 80);
    label = [[UILabel alloc] initWithFrame:labelFrame];
    [label setNumberOfLines:1];
    label.font = [UIFont systemFontOfSize:35];
    [label setText:[specifier.properties objectForKey:@"label"]];
    label.textColor = [HCommon colorFromHex:((HPSRootListController *)specifier.target).tintColorHex];
    label.textAlignment = NSTextAlignmentCenter;

    CGRect underLabelFrame = CGRectMake(0, 60, kWidth, 60);
    NSArray *subtitles = [specifier.properties objectForKey:@"subtitle"];
    underLabel = [[UILabel alloc] initWithFrame:underLabelFrame];
    [underLabel setNumberOfLines:1];
    underLabel.font = [UIFont systemFontOfSize:15];
    uint32_t rnd = arc4random_uniform([subtitles count]);
    [underLabel setText:[subtitles objectAtIndex:rnd]];
    underLabel.textColor = [UIColor grayColor];
    underLabel.textAlignment = NSTextAlignmentCenter;

    [self addSubview:label];
    [self addSubview:underLabel];
  }
  return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 {
  CGFloat prefHeight = 110.0;
  return prefHeight;
}
@end