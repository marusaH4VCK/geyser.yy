#import "GameMenuUI.h"
#import <objc/runtime.h>

// ═══════════════════════════════════════════════════════════════════════════════
// MARK: - Helpers
// ═══════════════════════════════════════════════════════════════════════════════

static UIImage *CheckmarkImage(CGFloat size, UIColor *color) {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [color setStroke];
    CGContextSetLineWidth(ctx, size * 0.14f);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGFloat p = size * 0.18f;
    CGContextMoveToPoint(ctx, p, size * 0.52f);
    CGContextAddLineToPoint(ctx, size * 0.40f, size * 0.74f);
    CGContextAddLineToPoint(ctx, size - p, size * 0.26f);
    CGContextStrokePath(ctx);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
static UIView * __unused Separator(BOOL dark) {
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    v.backgroundColor = dark
        ? [UIColor colorWithWhite:1.0f alpha:0.07f]
        : [UIColor colorWithWhite:0.0f alpha:0.07f];
    return v;
}


// ═══════════════════════════════════════════════════════════════════════════════
// MARK: - GMToggleRow
// ═══════════════════════════════════════════════════════════════════════════════

@implementation GMToggleRow {
    UILabel  *_titleLabel;
    UILabel  *_subtitleLabel;
    UIButton *_checkBtn;
    UIView   *_trackView;
    UIView   *_thumbView;
    BOOL      _dark;
}

- (instancetype)initWithTitle:(NSString *)title
                     subtitle:(NSString *)subtitle
                         isOn:(BOOL)isOn
                  circleStyle:(BOOL)circle
                       isDark:(BOOL)dark {
    self = [super initWithFrame:CGRectZero];
    if (!self) return nil;
    _title = [title copy];
    _subtitle = [subtitle copy];
    _isOn = isOn;
    _useCircleStyle = circle;
    _dark = dark;

    self.layer.cornerRadius = 16.0f;
    self.clipsToBounds = YES;

    // Title
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    _titleLabel.text = title;
    [self addSubview:_titleLabel];

    // Subtitle
    if (subtitle.length) {
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = [UIFont systemFontOfSize:11.0f];
        _subtitleLabel.text = subtitle;
        _subtitleLabel.numberOfLines = 1;
        [self addSubview:_subtitleLabel];
    }

    if (circle) {
        // Pill toggle track
        _trackView = [[UIView alloc] init];
        _trackView.layer.cornerRadius = 13.0f;
        _trackView.clipsToBounds = YES;
        _trackView.userInteractionEnabled = NO;
        [self addSubview:_trackView];

        _thumbView = [[UIView alloc] init];
        _thumbView.layer.cornerRadius = 10.0f;
        _thumbView.userInteractionEnabled = NO;
        _thumbView.layer.shadowColor = [UIColor blackColor].CGColor;
        _thumbView.layer.shadowOpacity = 0.30f;
        _thumbView.layer.shadowRadius = 2.0f;
        _thumbView.layer.shadowOffset = CGSizeMake(0, 1);
        [_trackView addSubview:_thumbView];
    } else {
        // Circle checkmark button
        _checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _checkBtn.layer.cornerRadius = 15.0f;
        _checkBtn.clipsToBounds = YES;
        _checkBtn.userInteractionEnabled = NO;
        [self addSubview:_checkBtn];
    }

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
        initWithTarget:self action:@selector(_tapped)];
    [self addGestureRecognizer:tap];

    [self applyTheme:dark];
    [self _updateToggleVisual:NO];
    return self;
}

- (void)_tapped {
    _isOn = !_isOn;
    [self _updateToggleVisual:YES];
    if (self.onToggle) self.onToggle(_isOn);
}

- (void)_updateToggleVisual:(BOOL)animated {
    void (^update)(void) = ^{
        if (self->_useCircleStyle) {
            if (self->_isOn) {
                self->_trackView.backgroundColor = self->_dark
                    ? [UIColor colorWithWhite:0.40f alpha:1]
                    : [UIColor colorWithWhite:0.67f alpha:1];
            } else {
                self->_trackView.backgroundColor = self->_dark
                    ? [UIColor colorWithWhite:0.42f alpha:1]
                    : [UIColor colorWithWhite:0.80f alpha:1];
            }
            CGFloat tw = 42.0f, tPad = 3.0f, tSize = 20.0f;
            CGFloat tx = self->_isOn ? (tw - tPad - tSize) : tPad;
            self->_thumbView.frame = CGRectMake(tx, tPad, tSize, tSize);
            self->_thumbView.backgroundColor = self->_dark
                ? [UIColor colorWithWhite:0.85f alpha:1]
                : [UIColor colorWithWhite:0.96f alpha:1];
        } else {
            self->_checkBtn.backgroundColor = self->_isOn
                ? GM_CHECK_BG
                : (self->_dark
                    ? [UIColor colorWithWhite:0.40f alpha:1]
                    : [UIColor colorWithWhite:0.80f alpha:1]);
            UIImage *img = self->_isOn
                ? CheckmarkImage(30, [UIColor whiteColor])
                : nil;
            [self->_checkBtn setImage:img forState:UIControlStateNormal];
        }
    };

    if (animated) {
        [UIView animateWithDuration:0.18 delay:0
             usingSpringWithDamping:0.80 initialSpringVelocity:0.5
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:update completion:nil];
    } else {
        update();
    }
}

- (void)applyTheme:(BOOL)dark {
    _dark = dark;
    self.backgroundColor = dark ? GM_ROW_DARK : GM_ROW_LIGHT;
    _titleLabel.textColor = dark ? GM_TEXT_DARK : GM_TEXT_LIGHT;
    if (_subtitleLabel) _subtitleLabel.textColor = dark ? GM_SUBTEXT_DARK : GM_SUBTEXT_LIGHT;
    [self _updateToggleVisual:NO];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat W = self.bounds.size.width;
    CGFloat pad = 14.0f;

    CGFloat toggleW = _useCircleStyle ? 42.0f : 30.0f;
    CGFloat toggleH = _useCircleStyle ? 26.0f : 30.0f;
    CGFloat toggleX = W - pad - toggleW;
    CGFloat toggleMidY = _subtitleLabel ? 18.0f : self.bounds.size.height * 0.5f;

    if (_useCircleStyle) {
        _trackView.frame = CGRectMake(toggleX, toggleMidY - toggleH * 0.5f, toggleW, toggleH);
    } else {
        _checkBtn.frame = CGRectMake(toggleX, toggleMidY - 15.0f, 30, 30);
        [self _updateToggleVisual:NO];
    }

    CGFloat labelW = toggleX - pad - 6.0f;
    if (_subtitleLabel) {
        _titleLabel.frame = CGRectMake(pad, 9.0f, labelW, 18.0f);
        _subtitleLabel.frame = CGRectMake(pad, 29.0f, labelW, 14.0f);
    } else {
        _titleLabel.frame = CGRectMake(pad, 0, labelW, self.bounds.size.height);
    }
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, _subtitle.length ? 52.0f : 46.0f);
}

@end

// ═══════════════════════════════════════════════════════════════════════════════
// MARK: - GMSliderRow
// ═══════════════════════════════════════════════════════════════════════════════

@implementation GMSliderRow {
    UILabel  *_titleLabel;
    UILabel  *_valueLabel;
    UIView   *_trackBg;
    UIView   *_trackFill;
    UIView   *_thumb;
    float     _min, _max, _step;
    BOOL      _dark;
    BOOL      _dragging;
}

- (instancetype)initWithTitle:(NSString *)title
                          min:(float)min
                          max:(float)max
                         step:(float)step
                        value:(float)value
                       isDark:(BOOL)dark {
    self = [super initWithFrame:CGRectZero];
    if (!self) return nil;
    _min = min; _max = max; _step = step; _value = value; _dark = dark;

    self.layer.cornerRadius = 16.0f;
    self.clipsToBounds = YES;

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    _titleLabel.text = title;
    [self addSubview:_titleLabel];

    _valueLabel = [[UILabel alloc] init];
    _valueLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    _valueLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_valueLabel];

    _trackBg = [[UIView alloc] init];
    _trackBg.layer.cornerRadius = 9.0f;
    _trackBg.clipsToBounds = YES;
    [self addSubview:_trackBg];

    _trackFill = [[UIView alloc] init];
    _trackFill.layer.cornerRadius = 9.0f;
    _trackFill.clipsToBounds = YES;
    [_trackBg addSubview:_trackFill];

    _thumb = [[UIView alloc] init];
    _thumb.layer.cornerRadius = 12.0f;
    _thumb.layer.shadowColor = [UIColor blackColor].CGColor;
    _thumb.layer.shadowOpacity = 0.35f;
    _thumb.layer.shadowRadius = 3.0f;
    _thumb.layer.shadowOffset = CGSizeMake(0, 2);
    [self addSubview:_thumb];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
        initWithTarget:self action:@selector(_panned:)];
    [self addGestureRecognizer:pan];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
        initWithTarget:self action:@selector(_tapped:)];
    [self addGestureRecognizer:tap];

    [self applyTheme:dark];
    [self _updateValueLabel];
    return self;
}

- (void)_panned:(UIPanGestureRecognizer *)gr {
    CGFloat trackX = 14.0f, trackW = self.bounds.size.width - 28.0f;
    CGFloat x = [gr locationInView:self].x;
    float pct = (float)((x - trackX) / trackW);
    pct = MAX(0.0f, MIN(1.0f, pct));
    float raw = _min + pct * (_max - _min);
    if (_step > 0) raw = roundf(raw / _step) * _step;
    _value = MAX(_min, MIN(_max, raw));
    [self setNeedsLayout];
    [self _updateValueLabel];
    if (self.onValueChange) self.onValueChange(_value);
}

- (void)_tapped:(UITapGestureRecognizer *)gr {
    CGFloat trackX = 14.0f, trackW = self.bounds.size.width - 28.0f;
    CGFloat x = [gr locationInView:self].x;
    float pct = (float)((x - trackX) / trackW);
    pct = MAX(0.0f, MIN(1.0f, pct));
    float raw = _min + pct * (_max - _min);
    if (_step > 0) raw = roundf(raw / _step) * _step;
    _value = MAX(_min, MIN(_max, raw));
    [UIView animateWithDuration:0.15 animations:^{ [self setNeedsLayout]; [self layoutIfNeeded]; }];
    [self _updateValueLabel];
    if (self.onValueChange) self.onValueChange(_value);
}

- (void)_updateValueLabel {
    if (_step < 1.0f && _step > 0.0f) {
        _valueLabel.text = [NSString stringWithFormat:@"%.1f", _value];
    } else {
        _valueLabel.text = [NSString stringWithFormat:@"%d", (int)_value];
    }
}

- (void)applyTheme:(BOOL)dark {
    _dark = dark;
    self.backgroundColor = dark ? GM_ROW_DARK : GM_ROW_LIGHT;
    _titleLabel.textColor = dark ? GM_TEXT_DARK : GM_TEXT_LIGHT;
    _valueLabel.textColor = dark ? GM_TEXT_DARK : GM_TEXT_LIGHT;
    _trackBg.backgroundColor = dark
        ? [UIColor colorWithWhite:0.20f alpha:1]
        : [UIColor colorWithWhite:0.47f alpha:1];
    _trackFill.backgroundColor = dark
        ? [UIColor colorWithWhite:0.42f alpha:1]
        : [UIColor colorWithWhite:0.27f alpha:1];
    _thumb.backgroundColor = dark ? GM_THUMB_DARK : GM_CHECK_BG;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat W = self.bounds.size.width;
    CGFloat pad = 14.0f;
    _titleLabel.frame = CGRectMake(pad, 8.0f, W * 0.6f, 18.0f);
    _valueLabel.frame = CGRectMake(W * 0.6f, 8.0f, W * 0.4f - pad, 18.0f);

    CGFloat tH = 20.0f, tY = 32.0f;
    CGFloat trackX = pad, trackW = W - pad * 2;
    _trackBg.frame = CGRectMake(trackX, tY, trackW, tH);

    float pct = (_max > _min) ? (_value - _min) / (_max - _min) : 0;
    _trackFill.frame = CGRectMake(0, 0, trackW * pct, tH);

    CGFloat thumbSize = 24.0f;
    CGFloat thumbX = trackX + trackW * pct - thumbSize * 0.5f;
    thumbX = MAX(trackX - thumbSize * 0.5f, MIN(trackX + trackW - thumbSize * 0.5f, thumbX));
    _thumb.frame = CGRectMake(thumbX, tY + tH * 0.5f - thumbSize * 0.5f, thumbSize, thumbSize);
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, 62.0f);
}

@end

// ═══════════════════════════════════════════════════════════════════════════════
// MARK: - GMSegmentRow
// ═══════════════════════════════════════════════════════════════════════════════

@implementation GMSegmentRow {
    UILabel             *_label;
    NSArray<UIButton *> *_buttons;
    UIView              *_track;
    NSArray<NSString *> *_options;
    BOOL                 _dark;
}

- (instancetype)initWithOptions:(NSArray<NSString *> *)options
                  selectedIndex:(NSInteger)index
                          label:(NSString *)label
                         isDark:(BOOL)dark {
    self = [super initWithFrame:CGRectZero];
    if (!self) return nil;
    _options = options;
    _selectedIndex = index;
    _dark = dark;

    if (label.length) {
        _label = [[UILabel alloc] init];
        _label.font = [UIFont systemFontOfSize:11.0f];
        _label.text = label;
        [self addSubview:_label];
    }

    _track = [[UIView alloc] init];
    _track.layer.cornerRadius = 14.0f;
    _track.clipsToBounds = YES;
    [self addSubview:_track];

    NSMutableArray *btns = [NSMutableArray array];
    for (NSInteger i = 0; i < (NSInteger)options.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:options[i] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        btn.layer.cornerRadius = 12.0f;
        btn.tag = i;
        [btn addTarget:self action:@selector(_segTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_track addSubview:btn];
        [btns addObject:btn];
    }
    _buttons = [btns copy];

    [self applyTheme:dark];
    return self;
}

- (void)_segTapped:(UIButton *)sender {
    _selectedIndex = sender.tag;
    [self _updateButtons];
    if (self.onSelect) self.onSelect(_selectedIndex);
}

- (void)_updateButtons {
    for (UIButton *btn in _buttons) {
        BOOL active = btn.tag == _selectedIndex;
        btn.backgroundColor = active ? GM_SEG_ACTIVE : [UIColor clearColor];
        [btn setTitleColor:active
            ? [UIColor whiteColor]
            : (_dark
                ? [UIColor colorWithWhite:0.55f alpha:1]
                : [UIColor colorWithWhite:0.80f alpha:1])
            forState:UIControlStateNormal];
    }
}

- (void)applyTheme:(BOOL)dark {
    _dark = dark;
    if (_label) _label.textColor = dark ? GM_SUBTEXT_DARK : GM_SUBTEXT_LIGHT;
    _track.backgroundColor = dark
        ? [UIColor colorWithWhite:0.23f alpha:1]
        : [UIColor colorWithWhite:0.53f alpha:1];
    [self _updateButtons];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat W = self.bounds.size.width;
    CGFloat pad = 2.0f;
    CGFloat labelH = _label ? 18.0f : 0.0f;
    if (_label) _label.frame = CGRectMake(4, 0, W, labelH);

    CGFloat trackH = 40.0f;
    _track.frame = CGRectMake(0, labelH + (_label ? 2.0f : 0), W, trackH);

    CGFloat btnW = (W - pad * 2) / (CGFloat)_buttons.count;
    for (NSInteger i = 0; i < (NSInteger)_buttons.count; i++) {
        _buttons[i].frame = CGRectMake(pad + i * btnW, pad, btnW, trackH - pad * 2);
    }
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, (_label ? 60.0f : 44.0f));
}

@end

// ═══════════════════════════════════════════════════════════════════════════════
// MARK: - Tab Content Builders
// ═══════════════════════════════════════════════════════════════════════════════

static NSMutableArray<UIView *> *BuildESPTab(BOOL dark) {
    NSMutableArray *rows = [NSMutableArray array];
    [rows addObject:[[GMToggleRow alloc] initWithTitle:@"Enable" subtitle:nil isOn:YES circleStyle:NO isDark:dark]];
    [rows addObject:[[GMToggleRow alloc] initWithTitle:@"ESP Box" subtitle:nil isOn:NO circleStyle:YES isDark:dark]];
    [rows addObject:[[GMToggleRow alloc] initWithTitle:@"ESP Lines" subtitle:nil isOn:YES circleStyle:NO isDark:dark]];
    [rows addObject:[[GMSegmentRow alloc] initWithOptions:@[@"Top", @"Bottom", @"Alternate"] selectedIndex:1 label:@"Line from" isDark:dark]];
    [rows addObject:[[GMToggleRow alloc] initWithTitle:@"Skeleton" subtitle:nil isOn:NO circleStyle:YES isDark:dark]];
    [rows addObject:[[GMToggleRow alloc] initWithTitle:@"Name Tag" subtitle:nil isOn:YES circleStyle:NO isDark:dark]];
    [rows addObject:[[GMToggleRow alloc] initWithTitle:@"Distance" subtitle:nil isOn:NO circleStyle:YES isDark:dark]];
    [rows addObject:[[GMToggleRow alloc] initWithTitle:@"Health Text" subtitle:nil isOn:YES circleStyle:NO isDark:dark]];
    [rows addObject:[[GMToggleRow alloc] initWithTitle:@"Health Bar" subtitle:nil isOn:NO circleStyle:YES isDark:dark]];
    return rows;
}

static NSMutableArray<UIView *> *BuildAimbotTab(BOOL dark) {
    NSMutableArray *rows = [NSMutableArray array];
    [rows addObject:[[GMToggleRow alloc] initWithTitle:@"Enable Aimbot" subtitle:nil isOn:YES circleStyle:NO isDark:dark]];
    [rows addObject:[[GMToggleRow alloc] initWithTitle:@"Aimsilent" subtitle:@"Hides Aimbot from killcam & replays" isOn:NO circleStyle:YES isDark:dark]];
    [rows addObject:[[GMToggleRow alloc] initWithTitle:@"Ignore Wall Check" subtitle:@"Always aim at enemy head, ignore wall/tanghin..." isOn:NO circleStyle:YES isDark:dark]];
    [rows addObject:[[GMToggleRow alloc] initWithTitle:@"Aimkillv2" subtitle:@"Automatically kills enemies when aiming at the..." isOn:NO circleStyle:YES isDark:dark]];
    [rows addObject:[[GMToggleRow alloc] initWithTitle:@"Increase Rate of fire" subtitle:@"Increases weapon fire rate for faster shooting" isOn:NO circleStyle:YES isDark:dark]];
    [rows addObject:[[GMSliderRow alloc] initWithTitle:@"FOV Radius" min:0 max:500 step:1 value:500 isDark:dark]];
    [rows addObject:[[GMSegmentRow alloc] initWithOptions:@[@"Always", @"Firing", @"Scope"] selectedIndex:0 label:@"Trigger When" isDark:dark]];
    [rows addObject:[[GMSliderRow alloc] initWithTitle:@"Fly Move Value" min:0 max:100 step:1 value:60 isDark:dark]];
    [rows addObject:[[GMSliderRow alloc] initWithTitle:@"Go Teleport Radius" min:0 max:10 step:0.1f value:2.3f isDark:dark]];
    [rows addObject:[[GMToggleRow alloc] initWithTitle:@"Second Phase Fire" subtitle:@"Enable get_StartFiring, OnFirstphasefire, OnS..." isOn:NO circleStyle:YES isDark:dark]];
    [rows addObject:[[GMToggleRow alloc] initWithTitle:@"First Phase Fire" subtitle:@"Enable phasefire(rivalTarget)" isOn:NO circleStyle:YES isDark:dark]];
    return rows;
}

static NSMutableArray<UIView *> *BuildMSLTab(BOOL dark) {
    NSMutableArray *rows = [NSMutableArray array];
    [rows addObject:[[GMToggleRow alloc] initWithTitle:@"Speed Bypass" subtitle:@"Increases movement beyond normal lim..." isOn:NO circleStyle:YES isDark:dark]];
    [rows addObject:[[GMToggleRow alloc] initWithTitle:@"Up Player" subtitle:@"Elevates player position above ground" isOn:YES circleStyle:NO isDark:dark]];
    [rows addObject:[[GMToggleRow alloc] initWithTitle:@"Telekill" subtitle:@"Teleports to enemies and kills them instantly" isOn:NO circleStyle:YES isDark:dark]];
    [rows addObject:[[GMToggleRow alloc] initWithTitle:@"Underground Kill2" subtitle:@"Kills enemies through the ground" isOn:NO circleStyle:YES isDark:dark]];
    [rows addObject:[[GMToggleRow alloc] initWithTitle:@"Ninja Run" subtitle:@"Move silently without footstep sounds" isOn:NO circleStyle:YES isDark:dark]];
    [rows addObject:[[GMToggleRow alloc] initWithTitle:@"Fly Altura" subtitle:@"Enables flight at set altitude" isOn:YES circleStyle:NO isDark:dark]];
    [rows addObject:[[GMSliderRow alloc] initWithTitle:@"Fly Speed" min:1 max:20 step:1 value:5 isDark:dark]];
    [rows addObject:[[GMSliderRow alloc] initWithTitle:@"Teleport Radius" min:1 max:50 step:1 value:10 isDark:dark]];
    return rows;
}

static NSMutableArray<UIView *> *BuildMISCTab(BOOL dark) {
    NSMutableArray *rows = [NSMutableArray array];

    // Section label
    UILabel *secLabel = [[UILabel alloc] init];
    secLabel.text = @"Fullsbrend Menu";
    secLabel.font = [UIFont systemFontOfSize:12.0f];
    secLabel.textColor = dark ? GM_SUBTEXT_DARK : GM_SUBTEXT_LIGHT;
    [rows addObject:secLabel];

    [rows addObject:[[GMSliderRow alloc] initWithTitle:@"Width" min:480 max:2560 step:10 value:1080 isDark:dark]];
    [rows addObject:[[GMSliderRow alloc] initWithTitle:@"Height" min:480 max:2560 step:10 value:1920 isDark:dark]];
    [rows addObject:[[GMSliderRow alloc] initWithTitle:@"Refresh Rate (FPS)" min:30 max:240 step:10 value:120 isDark:dark]];
    [rows addObject:[[GMToggleRow alloc] initWithTitle:@"Reset resolution" subtitle:nil isOn:YES circleStyle:NO isDark:dark]];
    [rows addObject:[[GMToggleRow alloc] initWithTitle:@"Anti-Aim" subtitle:@"Randomizes aim angles to confuse enemies" isOn:NO circleStyle:YES isDark:dark]];
    [rows addObject:[[GMToggleRow alloc] initWithTitle:@"No Recoil" subtitle:@"Removes weapon recoil for accurate shooting" isOn:YES circleStyle:NO isDark:dark]];
    return rows;
}

static NSMutableArray<UIView *> *BuildUITab(BOOL dark) {
    NSMutableArray *rows = [NSMutableArray array];
    [rows addObject:[[GMToggleRow alloc] initWithTitle:@"Show TeleVIP UI" subtitle:nil isOn:NO circleStyle:YES isDark:dark]];
    [rows addObject:[[GMToggleRow alloc] initWithTitle:@"Show Underground UI" subtitle:nil isOn:NO circleStyle:YES isDark:dark]];
    [rows addObject:[[GMToggleRow alloc] initWithTitle:@"Show AI Telekill UI" subtitle:nil isOn:YES circleStyle:NO isDark:dark]];
    [rows addObject:[[GMToggleRow alloc] initWithTitle:@"Show Ninja Run UI" subtitle:nil isOn:NO circleStyle:YES isDark:dark]];
    [rows addObject:[[GMToggleRow alloc] initWithTitle:@"Show Fly Altura UI" subtitle:nil isOn:YES circleStyle:NO isDark:dark]];
    [rows addObject:[[GMToggleRow alloc] initWithTitle:@"Show ESP UI" subtitle:nil isOn:YES circleStyle:NO isDark:dark]];
    [rows addObject:[[GMToggleRow alloc] initWithTitle:@"Show Aimbot UI" subtitle:nil isOn:NO circleStyle:YES isDark:dark]];
    [rows addObject:[[GMToggleRow alloc] initWithTitle:@"Show MISC UI" subtitle:nil isOn:YES circleStyle:NO isDark:dark]];
    return rows;
}

// Settings card view
@interface GMSettingsCard : UIView
- (instancetype)initWithName:(NSString *)name author:(NSString *)author downloaded:(BOOL)dl isDark:(BOOL)dark;
@end
@implementation GMSettingsCard {
    UILabel  *_nameLabel, *_authorLabel;
    UIButton *_deleteBtn, *_applyBtn, *_downloadBtn;
    BOOL      _downloaded, _dark;
}
- (instancetype)initWithName:(NSString *)name author:(NSString *)author downloaded:(BOOL)dl isDark:(BOOL)dark {
    self = [super initWithFrame:CGRectZero];
    if (!self) return nil;
    _downloaded = dl; _dark = dark;
    self.layer.cornerRadius = 16.0f;
    self.backgroundColor = dark ? [UIColor colorWithWhite:0.33f alpha:1] : [UIColor colorWithWhite:0.94f alpha:1];

    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    _nameLabel.text = name;
    _nameLabel.textColor = dark ? GM_TEXT_DARK : GM_TEXT_LIGHT;
    [self addSubview:_nameLabel];

    _authorLabel = [[UILabel alloc] init];
    _authorLabel.font = [UIFont systemFontOfSize:11.0f];
    _authorLabel.text = author;
    _authorLabel.textColor = dark ? GM_SUBTEXT_DARK : [UIColor colorWithWhite:0.47f alpha:1];
    [self addSubview:_authorLabel];

    if (dl) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_deleteBtn setTitle:@"Delete" forState:UIControlStateNormal];
        [_deleteBtn setTitleColor:[UIColor colorWithRed:0.8f green:0.0f blue:0.0f alpha:1] forState:UIControlStateNormal];
        _deleteBtn.backgroundColor = [UIColor colorWithRed:1.0f green:0.70f blue:0.70f alpha:1];
        _deleteBtn.layer.cornerRadius = 10.0f;
        [self addSubview:_deleteBtn];

        _applyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_applyBtn setTitle:@"Apply" forState:UIControlStateNormal];
        [_applyBtn setTitleColor:(dark ? GM_TEXT_DARK : GM_TEXT_LIGHT) forState:UIControlStateNormal];
        _applyBtn.backgroundColor = dark ? [UIColor colorWithWhite:0.40f alpha:1] : [UIColor colorWithWhite:0.86f alpha:1];
        _applyBtn.layer.cornerRadius = 10.0f;
        [self addSubview:_applyBtn];
    } else {
        _downloadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_downloadBtn setTitle:@"Download" forState:UIControlStateNormal];
        [_downloadBtn setTitleColor:(dark ? GM_TEXT_DARK : GM_TEXT_LIGHT) forState:UIControlStateNormal];
        _downloadBtn.backgroundColor = dark ? [UIColor colorWithWhite:0.40f alpha:1] : [UIColor colorWithWhite:0.86f alpha:1];
        _downloadBtn.layer.cornerRadius = 10.0f;
        [self addSubview:_downloadBtn];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat W = self.bounds.size.width, H = self.bounds.size.height;
    CGFloat pad = 14.0f, btnH = 32.0f, btnW = 76.0f;
    _nameLabel.frame   = CGRectMake(pad, 10, W * 0.55f, 18);
    _authorLabel.frame = CGRectMake(pad, 30, W * 0.55f, 14);
    if (_downloaded) {
        _deleteBtn.frame = CGRectMake(W - pad - btnW*2 - 6, (H - btnH) * 0.5f, btnW, btnH);
        _applyBtn.frame  = CGRectMake(W - pad - btnW,       (H - btnH) * 0.5f, btnW, btnH);
    } else if (_downloadBtn) {
        _downloadBtn.frame = CGRectMake(W - pad - btnW - 14, (H - btnH) * 0.5f, btnW + 14, btnH);
    }
}
- (CGSize)intrinsicContentSize { return CGSizeMake(UIViewNoIntrinsicMetric, 58.0f); }
@end

static NSMutableArray<UIView *> *BuildSettingsTab(BOOL dark) {
    NSMutableArray *rows = [NSMutableArray array];

    UILabel *secLabel = [[UILabel alloc] init];
    secLabel.text = @"Settings from Server";
    secLabel.font = [UIFont systemFontOfSize:12.0f];
    secLabel.textColor = dark ? GM_SUBTEXT_DARK : GM_SUBTEXT_LIGHT;
    [rows addObject:secLabel];

    [rows addObject:[[GMSettingsCard alloc] initWithName:@"Brutal S..." author:@"Beady" downloaded:YES isDark:dark]];
    [rows addObject:[[GMSettingsCard alloc] initWithName:@"Medium Settings" author:@"FLY , downicaded" downloaded:NO isDark:dark]];
    [rows addObject:[[GMSettingsCard alloc] initWithName:@"Safe Settings" author:@"Not downicaded" downloaded:NO isDark:dark]];
    [rows addObject:[[GMSettingsCard alloc] initWithName:@"Pro Config" author:@"Not downloaded" downloaded:NO isDark:dark]];
    return rows;
}

// ═══════════════════════════════════════════════════════════════════════════════
// MARK: - GMMenuViewController
// ═══════════════════════════════════════════════════════════════════════════════

static GMMenuViewController *_sharedController;

@implementation GMMenuViewController {
    UIView               *_container;
    UIView               *_sidebar;
    NSArray<UIButton *>  *_tabButtons;
    UIScrollView         *_scrollView;
    UIView               *_contentView;
    UIView               *_headerPill;
    UILabel              *_headerLabel;
    UIImageView          *_headerIcon;
    GMTab                 _activeTab;
    CGPoint               _dragStart;
    CGPoint               _containerOrigin;
}

+ (instancetype)sharedController {
    if (!_sharedController) {
        _sharedController = [[GMMenuViewController alloc] init];
    }
    return _sharedController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    _activeTab = GMTabESP;
    [self _buildLayout];
}

- (void)_buildLayout {
    BOOL dark = _isDark;

    // Container
    _container = [[UIView alloc] initWithFrame:CGRectMake(30, 100, 370, 480)];
    _container.layer.cornerRadius = 20.0f;
    _container.clipsToBounds = NO;
    _container.layer.shadowColor = [UIColor blackColor].CGColor;
    _container.layer.shadowOpacity = 0.35f;
    _container.layer.shadowRadius = 16.0f;
    _container.layer.shadowOffset = CGSizeMake(0, 6);
    [self.view addSubview:_container];

    // Drag gesture
    UIPanGestureRecognizer *drag = [[UIPanGestureRecognizer alloc]
        initWithTarget:self action:@selector(_dragged:)];
    [_container addGestureRecognizer:drag];

    // Inner clip view
    UIView *clip = [[UIView alloc] initWithFrame:_container.bounds];
    clip.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    clip.layer.cornerRadius = 20.0f;
    clip.clipsToBounds = YES;
    clip.backgroundColor = dark ? GM_BG_DARK : GM_BG_LIGHT;
    [_container addSubview:clip];

    // Sidebar
    _sidebar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 64, _container.bounds.size.height)];
    _sidebar.backgroundColor = dark ? GM_SIDEBAR_DARK : GM_SIDEBAR_LIGHT;
    _sidebar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [clip addSubview:_sidebar];

    // Sidebar buttons
    NSArray *icons = @[@"eye", @"scope", @"gamecontroller", @"wrench.and.screwdriver", @"square.grid.2x2", @"gear"];
    NSMutableArray *btns = [NSMutableArray array];
    for (NSInteger i = 0; i < (NSInteger)icons.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        UIImage *img = [UIImage systemImageNamed:icons[i]];
        [btn setImage:img forState:UIControlStateNormal];
        btn.tintColor = (i == _activeTab) ? (dark ? GM_TEXT_DARK : GM_TEXT_LIGHT) : [UIColor colorWithWhite:0.50f alpha:1];
        btn.backgroundColor = (i == _activeTab)
            ? [UIColor colorWithWhite:dark ? 0.38f : 0.60f alpha:1]
            : [UIColor clearColor];
        btn.layer.cornerRadius = 22.0f;
        btn.frame = CGRectMake(10, 16 + i * 62, 44, 44);
        btn.tag = i;
        [btn addTarget:self action:@selector(_tabTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_sidebar addSubview:btn];
        [btns addObject:btn];
    }
    _tabButtons = [btns copy];

    // Right panel
    UIView *rightPanel = [[UIView alloc] initWithFrame:CGRectMake(64, 0, _container.bounds.size.width - 64, _container.bounds.size.height)];
    rightPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    rightPanel.backgroundColor = [UIColor clearColor];
    [clip addSubview:rightPanel];

    // Header
    [self _buildHeaderIn:rightPanel];

    // Scroll
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 58, rightPanel.bounds.size.width, rightPanel.bounds.size.height - 58)];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.showsVerticalScrollIndicator = NO;
    [rightPanel addSubview:_scrollView];

    [self _reloadTab];
}

- (void)_buildHeaderIn:(UIView *)parent {
    BOOL dark = _isDark;
    CGFloat W = parent.bounds.size.width;

    // Title pill
    _headerPill = [[UIView alloc] initWithFrame:CGRectMake(8, 8, W - 8 - 3*(36+6), 42)];
    _headerPill.backgroundColor = dark ? GM_PILL_DARK : GM_PILL_LIGHT;
    _headerPill.layer.cornerRadius = 21.0f;
    [parent addSubview:_headerPill];

    _headerIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 22, 22)];
    _headerIcon.tintColor = dark ? GM_TEXT_DARK : GM_TEXT_LIGHT;
    _headerIcon.contentMode = UIViewContentModeScaleAspectFit;
    [_headerPill addSubview:_headerIcon];

    _headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(36, 0, _headerPill.bounds.size.width - 40, 42)];
    _headerLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    _headerLabel.textColor = dark ? GM_TEXT_DARK : GM_TEXT_LIGHT;
    [_headerPill addSubview:_headerLabel];

    NSArray *systemNames = @[@"arrow.down.to.line", @"sun.max", @"xmark"];
    SEL actions[] = {@selector(_saveTapped), @selector(_brightnessTapped), @selector(_closeTapped)};
    for (NSInteger i = 0; i < 3; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        CGFloat bx = W - (3 - i) * (36 + 6) + 6;
        btn.frame = CGRectMake(bx, 11, 36, 36);
        btn.backgroundColor = dark ? GM_PILL_DARK : GM_PILL_LIGHT;
        btn.layer.cornerRadius = 18.0f;
        btn.tintColor = dark ? GM_TEXT_DARK : GM_TEXT_LIGHT;
        [btn setImage:[UIImage systemImageNamed:systemNames[i]] forState:UIControlStateNormal];
        [btn addTarget:self action:actions[i] forControlEvents:UIControlEventTouchUpInside];
        [parent addSubview:btn];
    }
    [self _updateHeader];
}

- (void)_updateHeader {
    NSArray *icons = @[@"eye", @"scope", @"gamecontroller", @"wrench.and.screwdriver", @"square.grid.2x2", @"gear"];
    NSArray *labels = @[@"ESP", @"AIMBOT", @"MSL", @"MISC", @"UI", @"SETTI..."];
    _headerLabel.text = labels[_activeTab];
    _headerIcon.image = [UIImage systemImageNamed:icons[_activeTab]];
}

- (void)_tabTapped:(UIButton *)sender {
    _activeTab = (GMTab)sender.tag;
    [self _updateHeader];
    [self _updateSidebarSelection];
    [self _reloadTab];
}

- (void)_updateSidebarSelection {
    BOOL dark = _isDark;
    for (UIButton *btn in _tabButtons) {
        BOOL active = btn.tag == (NSInteger)_activeTab;
        btn.backgroundColor = active
            ? [UIColor colorWithWhite:dark ? 0.38f : 0.60f alpha:1]
            : [UIColor clearColor];
        btn.tintColor = active
            ? (dark ? GM_TEXT_DARK : GM_TEXT_LIGHT)
            : [UIColor colorWithWhite:0.50f alpha:1];
    }
}

- (void)_reloadTab {
    for (UIView *v in _scrollView.subviews) [v removeFromSuperview];

    NSMutableArray<UIView *> *rows;
    switch (_activeTab) {
        case GMTabESP:      rows = BuildESPTab(_isDark);      break;
        case GMTabAimbot:   rows = BuildAimbotTab(_isDark);   break;
        case GMTabMSL:      rows = BuildMSLTab(_isDark);      break;
        case GMTabMISC:     rows = BuildMISCTab(_isDark);     break;
        case GMTabUI:       rows = BuildUITab(_isDark);       break;
        case GMTabSettings: rows = BuildSettingsTab(_isDark); break;
    }

    CGFloat W = _scrollView.bounds.size.width;
    CGFloat y = 6.0f, gap = 6.0f, pad = 10.0f;

    for (UIView *row in rows) {
        CGSize sz = [row intrinsicContentSize];
        CGFloat h = (sz.height > 0) ? sz.height : 20.0f;

        // Labels (section headers) have no corner radius and a different style
        if ([row isKindOfClass:[UILabel class]]) {
            row.frame = CGRectMake(pad, y, W - pad * 2, h);
            y += h + 2.0f;
        } else {
            row.frame = CGRectMake(pad, y, W - pad * 2, h);
            y += h + gap;
        }
        [_scrollView addSubview:row];
    }
    _scrollView.contentSize = CGSizeMake(W, y + 10.0f);
}

- (void)_dragged:(UIPanGestureRecognizer *)gr {
    if (gr.state == UIGestureRecognizerStateBegan) {
        _dragStart = [gr locationInView:self.view];
        _containerOrigin = _container.frame.origin;
    } else if (gr.state == UIGestureRecognizerStateChanged) {
        CGPoint pt = [gr locationInView:self.view];
        CGFloat dx = pt.x - _dragStart.x;
        CGFloat dy = pt.y - _dragStart.y;
        _container.frame = CGRectMake(_containerOrigin.x + dx, _containerOrigin.y + dy,
                                       _container.bounds.size.width, _container.bounds.size.height);
    }
}

- (void)_saveTapped {}

- (void)_brightnessTapped {
    _isDark = !_isDark;
    // Rebuild UI
    for (UIView *v in self.view.subviews) [v removeFromSuperview];
    [self _buildLayout];
}

- (void)_closeTapped {
    [self dismiss];
}

- (void)show {
    if (self.view.superview) return;
    UIWindow *w = nil;
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive &&
                [scene isKindOfClass:[UIWindowScene class]]) {
                w = [(UIWindowScene *)scene windows].firstObject;
                break;
            }
        }
    }
    if (!w) w = [UIApplication sharedApplication].keyWindow;
    [w addSubview:self.view];
    self.view.frame = w.bounds;
    self.view.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^{ self.view.alpha = 1; }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.20 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL done) {
        (void)done;
        [self.view removeFromSuperview];
    }];
}

@end

// ═══════════════════════════════════════════════════════════════════════════════
// MARK: - GMMenuWindow
// ═══════════════════════════════════════════════════════════════════════════════

static GMMenuWindow *_sharedWindow;

@implementation GMMenuWindow

+ (instancetype)sharedWindow {
    if (!_sharedWindow) {
        _sharedWindow = [[GMMenuWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _sharedWindow.windowLevel = UIWindowLevelAlert + 100;
        _sharedWindow.backgroundColor = [UIColor clearColor];
        _sharedWindow.rootViewController = [GMMenuViewController sharedController];
    }
    return _sharedWindow;
}

- (void)show {
    self.hidden = NO;
    [[GMMenuViewController sharedController] show];
}

- (void)hide {
    [[GMMenuViewController sharedController] dismiss];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.hidden = YES;
    });
}

// Hit-test: pass touches through transparent areas
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    if (hit == self || hit == self.rootViewController.view) return nil;
    return hit;
}

@end
