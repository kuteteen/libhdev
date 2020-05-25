#import "HPSLinkCell.h"

@implementation HPSLinkCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
  self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];
  if (self) {
    HPSRootListController *rootLC = (HPSRootListController *)specifier.target;
    self.textLabel.textColor = [HCommon colorFromHex:rootLC.labelTextColorHex?:@"#333333"];

    NSString *subTitleValue = [specifier.properties objectForKey:@"subtitle"];
    self.detailTextLabel.text = [HCommon localizedItem:subTitleValue bundlePath:((HPSRootListController *)specifier.target).bundlePath];
    self.detailTextLabel.textColor = [HCommon colorFromHex:rootLC.subtitleTextColorHex?:@"#828282"];
  }
  return self;
}

- (void)setSeparatorStyle:(UITableViewCellSeparatorStyle)style {
  [super setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}
@end
