#import "UITextFieldPlugin.h"

#import "UIUtil.h"

@interface TNUITextField : UITextField {
 @private
}
@end

@implementation TNUITextField

- (void) drawPlaceholderInRect:(CGRect)rect {
  [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3] setFill];
  [self.placeholder drawInRect:rect 
                      withFont:self.font 
                 lineBreakMode:UILineBreakModeTailTruncation 
                     alignment:self.textAlignment];
}

@end

@implementation UITextFieldPlugin

@synthesize textFieldBeingEdited = textFieldBeingEdited_;

static NSDictionary* createEventDict(TNUITextField* textField)
{
  return [NSDictionary dictionaryWithObject:textField.text forKey:@"text"];
}

- (void)textFieldDone:(TNUITextField*)sender
{
  [[self class] fireEvent:@"done" 
      withData:createEventDict(sender)
      forComponent:sender];
}

- (void)textFieldChanged:(TNUITextField*)sender
{
  [[self class] fireEvent:@"change" 
      withData:createEventDict(sender)
      forComponent:sender];
}

- (void)textFieldDidBeginEditing:(TNUITextField*)textField
{
  self.textFieldBeingEdited = textField;
  [[self class] fireEvent:@"click" withData:nil forComponent:textField];
}

- (void)textFieldDidEndEditing:(TNUITextField*)textField
{
  self.textFieldBeingEdited = nil;
}

+ (Class)uiKitSubclass
{
  return [TNUITextField class];
}

- (void)setupComponent:(TNUITextField*)textField 
           withOptions:(NSDictionary*)options
{
  [super setupComponent:textField withOptions:options];

  textField.clearButtonMode = UITextFieldViewModeWhileEditing;
  textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;

  textField.returnKeyType = UIReturnKeyDone;
  
  textField.delegate = self;

  // For some reason, merely adding this target makes the keyboard disappear
  // when clicking the 'done' button.
  [textField addTarget:self
                action:@selector(textFieldDone:)
      forControlEvents:UIControlEventEditingDidEndOnExit];

  [textField addTarget:self
                action:@selector(textFieldChanged:)
      forControlEvents:UIControlEventEditingChanged];
  
  [self setProperties:
    [NSArray arrayWithObjects:@"align", @"hint", @"text", 
        @"leftView", @"rightView", nil]
    forComponent:textField
    fromOptions:options];
}

- (id)getProperty:(NSString*)name
     forComponent:(TNUITextField*)textField
{
  if ([name isEqual:@"text"]) {
    if (textField.text) {
      return textField.text;
    } else {
      return @"";
    }
  } else {
    return [super getProperty:name forComponent:textField];
  }
}

- (void)setProperty:(NSString*)name 
          withValue:(id)value
       forComponent:(TNUITextField*)textField
{
  if ([name isEqual:@"align"]) {
    textField.textAlignment = [UIUtil textAlignmentFromString:value];
  } else if ([name isEqual:@"text"]) {
    textField.text = ([value isKindOfClass:[NSNull class]]) ? @"" : value;
  } else if ([name isEqual:@"hint"]) {
    textField.placeholder = value;
  } else if ([name isEqual:@"leftView"]) {
    if (![value isKindOfClass:[NSNull class]]) {
      textField.leftView = [[self class] componentWithOptions:value];
      textField.leftViewMode = UITextFieldViewModeAlways;
    } else {
      textField.leftView = nil;
      textField.leftViewMode = UITextFieldViewModeNever;
    }
  } else if ([name isEqual:@"rightView"]) {
    if (![value isKindOfClass:[NSNull class]]) {
      textField.rightView = [[self class] componentWithOptions:value];
      textField.rightViewMode = UITextFieldViewModeAlways;
    } else {
      textField.rightView = nil;
      textField.rightViewMode = UITextFieldViewModeNever;
    }
  } else {
    [super setProperty:name 
             withValue:value 
          forComponent:textField];
  }
}

- (void)dismissKeyboard:(NSMutableArray*)arguments
               withDict:(NSMutableDictionary*)options
{
  [textFieldBeingEdited_ resignFirstResponder];
}

@end
