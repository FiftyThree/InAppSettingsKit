//
//  IASKPSSliderSpecifierViewCell.m
//  http://www.inappsettingskit.com
//
//  Copyright (c) 2009-2010:
//  Luc Vandal, Edovia Inc., http://www.edovia.com
//  Ortwin Gentz, FutureTap GmbH, http://www.futuretap.com
//  All rights reserved.
// 
//  It is appreciated but not required that you give credit to Luc Vandal and Ortwin Gentz, 
//  as the original authors of this code. You can give credit in a blog post, a tweet or on 
//  a info page of your app. Also, the original authors appreciate letting them know if you use this code.
//
//  This code is licensed under the BSD license that is available at: http://www.opensource.org/licenses/bsd-license.php
//

#import "IASKPSSliderSpecifierViewCell.h"
#import "IASKSlider.h"
#import "IASKSettingsReader.h"

@implementation IASKPSSliderSpecifierViewCell

@synthesize slider=_slider, 
            minImage=_minImage, 
            maxImage=_maxImage;
@synthesize minValueLabel, currentValueLabel, maxValueLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Setting only frame data that will not be overwritten by layoutSubviews
        // Slider
        _slider = [[[IASKSlider alloc] initWithFrame:CGRectMake(0, 0, 0, 23)] autorelease];
        _slider.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin |
        UIViewAutoresizingFlexibleWidth;
        _slider.continuous = NO;
        [self.contentView addSubview:_slider];

        // MinImage
        _minImage = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 21, 21)] autorelease];
        _minImage.autoresizingMask = UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleBottomMargin;
        [self.contentView addSubview:_minImage];

        // MaxImage
        _maxImage = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 21, 21)] autorelease];
        _maxImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleBottomMargin;
        [self.contentView addSubview:_maxImage];

        self.minValueLabel = [[[UILabel alloc] init] autorelease];
        self.currentValueLabel = [[[UILabel alloc] init] autorelease];
        self.maxValueLabel = [[[UILabel alloc] init] autorelease];
        [minValueLabel setFont:[UIFont systemFontOfSize:14.f]];
        [currentValueLabel setFont:[UIFont systemFontOfSize:14.f]];
        [maxValueLabel setFont:[UIFont systemFontOfSize:14.f]];
        [minValueLabel setTextColor:[UIColor blackColor]];
        [currentValueLabel setTextColor:[UIColor blackColor]];
        [maxValueLabel setTextColor:[UIColor blackColor]];
        minValueLabel.textAlignment = UITextAlignmentLeft;
        currentValueLabel.textAlignment = UITextAlignmentCenter;
        maxValueLabel.textAlignment = UITextAlignmentRight;
        minValueLabel.backgroundColor = [UIColor clearColor];
        currentValueLabel.backgroundColor = [UIColor clearColor];
        maxValueLabel.backgroundColor = [UIColor clearColor];
        minValueLabel.opaque = NO;
        currentValueLabel.opaque = NO;
        maxValueLabel.opaque = NO;
        [self.contentView addSubview:minValueLabel];
        [self.contentView addSubview:currentValueLabel];
        [self.contentView addSubview:maxValueLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
	CGRect  sliderBounds    = _slider.bounds;
    CGPoint sliderCenter    = _slider.center;
    const double superViewWidth = _slider.superview.frame.size.width;
    
    sliderCenter.x = superViewWidth / 2;
    sliderCenter.y = self.contentView.center.y;
    sliderBounds.size.width = superViewWidth - kIASKSliderNoImagesPadding * 2;
	_minImage.hidden = YES;
	_maxImage.hidden = YES;

	// Check if there are min and max images. If so, change the layout accordingly.
	if (_minImage.image) {
		// Min image
		_minImage.hidden = NO;
		sliderCenter.x    += (kIASKSliderImagesPadding - kIASKSliderNoImagesPadding) / 2;
		sliderBounds.size.width  -= (kIASKSliderImagesPadding - kIASKSliderNoImagesPadding);
        _minImage.center = CGPointMake(_minImage.frame.size.width / 2 + kIASKPaddingLeft,
                                       self.contentView.center.y);
    }
	if (_maxImage.image) {
		// Max image
		_maxImage.hidden = NO;
		sliderCenter.x    -= (kIASKSliderImagesPadding - kIASKSliderNoImagesPadding) / 2;
		sliderBounds.size.width  -= (kIASKSliderImagesPadding - kIASKSliderNoImagesPadding);
        _maxImage.center = CGPointMake(self.contentView.bounds.size.width - _maxImage.frame.size.width / 2 - kIASKPaddingRight,
                                       self.contentView.center.y);
	}
    [_slider addTarget:self
                action:@selector(sliderValueDidChange:)
      forControlEvents:UIControlEventAllTouchEvents | UIControlEventValueChanged];
    
    [minValueLabel sizeToFit];
    [currentValueLabel sizeToFit];
    [maxValueLabel sizeToFit];
    minValueLabel.frame = CGRectMake(+5,
                                     -5 + self.contentView.bounds.size.height - minValueLabel.bounds.size.height,
                                     minValueLabel.frame.size.width,
                                     minValueLabel.frame.size.height);
    // Round location to ensure pixel alignment.
    currentValueLabel.frame = CGRectMake(roundf((self.contentView.bounds.size.width - currentValueLabel.bounds.size.width) / 2.f),
                                         -5 + self.contentView.bounds.size.height - currentValueLabel.bounds.size.height,
                                         currentValueLabel.frame.size.width,
                                         currentValueLabel.frame.size.height);
    maxValueLabel.frame = CGRectMake(-5 + self.contentView.bounds.size.width - maxValueLabel.bounds.size.width,
                                     -5 + self.contentView.bounds.size.height - maxValueLabel.bounds.size.height,
                                     maxValueLabel.frame.size.width,
                                     maxValueLabel.frame.size.height);
	
    sliderBounds = _slider.superview.bounds;
    sliderBounds.origin = CGPointZero;
    sliderBounds.size.height -= 5 + MAX(minValueLabel.frame.size.height,
                                        MAX(currentValueLabel.frame.size.height,
                                            maxValueLabel.frame.size.height));
	_slider.frame = sliderBounds;
}

- (void)sliderValueDidChange:(id)sender {
    [self.currentValueLabel setText:[NSString stringWithFormat:@"%0.2f", self.slider.value]];
    [self.currentValueLabel sizeToFit];
}

- (void)dealloc {
	_minImage.image = nil;
	_maxImage.image = nil;
	self.minValueLabel = nil;
	self.currentValueLabel = nil;
	self.maxValueLabel = nil;
    [super dealloc];
}

- (void)prepareForReuse {
	_minImage.image = nil;
	_maxImage.image = nil;
    [minValueLabel setText:@""];
    [currentValueLabel setText:@""];
    [maxValueLabel setText:@""];
}

@end
