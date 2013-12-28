//
//  Copyright (c) 2011 Oleg Geier
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//  of the Software, and to permit persons to whom the Software is furnished to do
//  so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#ifdef __BLOCKS__
typedef void(^buttonClicked)(NSString *title, BOOL *dismiss);
#endif

@interface OGActionButton : NSObject {}
@property (nonatomic, copy) NSString *title;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, assign) BOOL enabled;
#ifdef __BLOCKS__
@property (nonatomic, copy) buttonClicked block;
+ (id)buttonWithTitle:(NSString*)t image:(UIImage*)i enabled:(BOOL)en block:(buttonClicked)b;
+ (id)buttonWithTitle:(NSString*)t imageName:(NSString*)n enabled:(BOOL)en block:(buttonClicked)b;
#endif
+ (id)buttonWithTitle:(NSString*)t image:(UIImage*)i enabled:(BOOL)en;
+ (id)buttonWithTitle:(NSString*)t imageName:(NSString*)n enabled:(BOOL)en;
@end

@protocol OGActionChooserDelegate; 

@interface OGActionChooser : UIView <UIScrollViewDelegate> {}
@property (nonatomic, assign) id<OGActionChooserDelegate> delegate;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, retain) UIColor *backgroundColor; // r17 g25 b68 a0.8
@property (nonatomic) BOOL shouldDrawShadow; // YES
@property (nonatomic) BOOL dismissAfterwards; // NO

+ (id)actionChooserWithDelegate:(id<OGActionChooserDelegate>)dlg;
+(void)showWithTitle:(NSString*)title buttons:(NSArray*)buttons view:(UIView*)view;
- (void)setButtonsWithArray:(NSArray*)buttons;
- (void)presentInView:(UIView*)parentview;
- (void)dismiss;
@end

@protocol OGActionChooserDelegate <NSObject>
@optional
- (void)actionChooser:(OGActionChooser*)ac buttonPressedWithIndex:(NSInteger)index;
- (void)actionChooserFinished:(OGActionChooser*)ac;
@end
