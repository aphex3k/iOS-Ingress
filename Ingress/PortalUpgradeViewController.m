//
//  PortalUpgradeViewController.m
//  Ingress
//
//  Created by Alex Studnička on 14.05.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "PortalUpgradeViewController.h"

@implementation PortalUpgradeViewController {
	int currentSlotForDeploy;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	CGFloat viewWidth = [UIScreen mainScreen].bounds.size.width;
	CGFloat viewHeight = [UIScreen mainScreen].bounds.size.height-113;

	_carousel = [[iCarousel alloc] initWithFrame:self.view.bounds];
	_carousel.frame = CGRectMake(0, 100, viewWidth, viewHeight-110);
	_carousel.backgroundColor = self.view.backgroundColor;
//	_carousel.backgroundColor = [UIColor colorWithRed:0 green:.5 blue:1 alpha:.5];
	_carousel.type = iCarouselTypeCylinder;
    _carousel.delegate = self;
    _carousel.dataSource = self;
	[self.view addSubview:_carousel];
	[_carousel scrollToItemAtIndex:2 animated:NO];

}

- (void)dealloc {
    _carousel.delegate = nil;
    _carousel.dataSource = nil;
}

- (void)viewWillLayoutSubviews {
	[self refresh];
}

#pragma mark - Refresh

- (void)refresh {

	Player *player = [[API sharedInstance] playerForContext:[NSManagedObjectContext MR_contextForCurrentThread]];

	for (int i = 0; i < 4; i++) {

		UIButton *button = (UIButton *)[self.view viewWithTag:100+i];

		button.titleLabel.numberOfLines = 0;
		button.titleLabel.font = [UIFont fontWithName:[[[[UIButton appearance] titleLabel] font] fontName] size:10];

		DeployedMod *mod = [DeployedMod MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"portal = %@ && slot = %d", self.portal, i]];

		if ([mod isKindOfClass:[DeployedShield class]]) {
//			[button setTitle:[[(DeployedShield *)mod rarityStr] stringByAppendingString:@"\nShield"] forState:UIControlStateNormal];
			switch ([(DeployedShield *)mod rarity]) {
				case ItemRarityVeryCommon:
					[button setImage:[UIImage imageNamed:@"shield_verycommon.png"] forState:UIControlStateNormal];
					break;
				case ItemRarityCommon:
					[button setImage:[UIImage imageNamed:@"shield_common.png"] forState:UIControlStateNormal];
					break;
				case ItemRarityLessCommon:
					[button setImage:[UIImage imageNamed:@"shield_lesscommon.png"] forState:UIControlStateNormal];
					break;
				case ItemRarityRare:
					[button setImage:[UIImage imageNamed:@"shield_rare.png"] forState:UIControlStateNormal];
					break;
				case ItemRarityVeryRare:
					[button setImage:[UIImage imageNamed:@"shield_veryrare.png"] forState:UIControlStateNormal];
					break;
				case ItemRarityExtraRare:
					[button setImage:[UIImage imageNamed:@"shield_extrarare.png"] forState:UIControlStateNormal];
					break;
				default:
					[button setImage:[UIImage imageNamed:@"shield_verycommon.png"] forState:UIControlStateNormal];
					break;
			}
		} else {
			[button setImage:nil forState:UIControlStateNormal];
		}

		if (self.portal.controllingTeam && ([self.portal.controllingTeam isEqualToString:player.team] || [self.portal.controllingTeam isEqualToString:@"NEUTRAL"])) {
			[button setEnabled:YES];
		} else {
			[button setEnabled:NO];
		}

	}

	NSMutableArray *tmpResonators = [NSMutableArray arrayWithCapacity:8];
	for (int i = 0; i < 8; i++) {
		tmpResonators[i] = [NSNull null];
	}
	for (DeployedResonator *resonator in self.portal.resonators) {
		if (![resonator isKindOfClass:[NSNull class]]) {

			int slot = resonator.slot;

			if (self.portal.controllingTeam && ([self.portal.controllingTeam isEqualToString:player.team] || [self.portal.controllingTeam isEqualToString:@"NEUTRAL"])) {
				UIButton *button = (UIButton *)[self.view viewWithTag:50+slot];
				[button setTitle:@"UPGRADE" forState:UIControlStateNormal];
				tmpResonators[slot] = resonator;
			}

		}
	}
	_resonators = tmpResonators;

	[_carousel reloadData];
	
}

#pragma mark - iCarouselDataSource & iCarouselDelegate

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return 8;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    
	DeployedResonator *resonator = _resonators[index];
	
    UILabel *label = nil;
	GUIButton *deployButton = nil;
	GUIButton *rechargeButton = nil;
    
    if (!view) {
        
		view = [[GlowingLabel alloc] initWithFrame:CGRectMake(0, 0, 220, 220)];
//        view.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.95];
		view.backgroundColor = [UIColor colorWithRed:16.0/255.0 green:32.0/255.0 blue:34.0/255.0 alpha:0.95];

        label = [[GlowingLabel alloc] initWithFrame:CGRectMake(0, 0, 220, 112)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [label.font fontWithSize:20];
		label.minimumScaleFactor = .75;
		label.adjustsFontSizeToFitWidth = YES;
		label.numberOfLines = 0;
        label.tag = 1;
        [view addSubview:label];
        
		deployButton = [[GUIButton alloc] initWithFrame:CGRectMake(20, 112, 180, 44)];
		[deployButton addTarget:self action:@selector(resonatorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        deployButton.tag = 2;
        [view addSubview:deployButton];

		rechargeButton = [[GUIButton alloc] initWithFrame:CGRectMake(20, 166, 180, 44)];
		[rechargeButton setTitle:@"RECHARGE" forState:UIControlStateNormal];
		[rechargeButton addTarget:self action:@selector(rechargeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        rechargeButton.tag = 3;
		rechargeButton.hidden = YES;
        [view addSubview:rechargeButton];
        
    } else {
        label = (UILabel *)[view viewWithTag:1];
        deployButton = (GUIButton *)[view viewWithTag:2];
        rechargeButton = (GUIButton *)[view viewWithTag:3];
    }
    
	view.tag = index;
	NSString *resonatorOctant = @[@"E", @"NE", @"N", @"NW", @"W", @"SW", @"S", @"SE"][index];
    
	if (![resonator isKindOfClass:[NSNull class]]) {

		NSMutableString *resonatorString = [NSMutableString string];
		[resonatorString appendFormat:@"Octant: %@\n", resonatorOctant];
		[resonatorString appendFormat:@"Level: %d\n", resonator.level];
		[resonatorString appendFormat:@"%d / %d XM\n", resonator.energy, [Utilities maxEnergyForResonatorLevel:resonator.level]];

		NSString *nickname = resonator.owner.nickname;
		if (nickname) { [resonatorString appendFormat:@"Owner: %@", nickname]; }

		[label setText:resonatorString];

		[deployButton setTitle:@"UPGRADE" forState:UIControlStateNormal];

		rechargeButton.hidden = NO;
	} else {
		label.text = [NSString stringWithFormat:@"Octant: %@", resonatorOctant];
        
		[deployButton setTitle:@"DEPLOY" forState:UIControlStateNormal];

		rechargeButton.hidden = YES;
	}
    
    return view;
	
}

- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {

    switch (option) {
        case iCarouselOptionWrap: {
            return YES;
        }
        case iCarouselOptionSpacing: {
            return value * 1.05;
        }
        default: {
            return value;
        }
    }
	
}

//- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
//	
//}

#pragma mark - Resonators

- (IBAction)resonatorButtonPressed:(GUIButton *)sender {

	if (sender.disabled) { return; }

	MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
	HUD.userInteractionEnabled = YES;
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.dimBackground = YES;
	HUD.removeFromSuperViewOnHide = YES;
	HUD.showCloseButton = YES;

	_levelChooser = [ChooserViewController levelChooserWithTitle:@"Choose resonator level" completionHandler:^(int level) {
		[HUD hide:YES];
		[self deployResonatorOfLevel:level toSlot:sender.superview.tag];
		_levelChooser = nil;
	}];
	HUD.customView = _levelChooser.view;

	[[AppDelegate instance].window addSubview:HUD];
	[HUD show:YES];

}

- (void)deployResonatorOfLevel:(int)level toSlot:(int)slot {

	if ([_resonators[slot] isKindOfClass:[NSNull class]]) {

		Resonator *resonatorItem = [Resonator MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && level = %d", level]];

		if (!resonatorItem) {
			[Utilities showWarningWithTitle:@"No resonator of that level remaining!"];
		} else {

			[[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Game Action" withAction:@"Deploy Resonator" withLabel:self.portal.name withValue:@(resonatorItem.level)];

			MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
			HUD.userInteractionEnabled = YES;
			HUD.dimBackground = YES;
			HUD.removeFromSuperViewOnHide = YES;
			HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
			HUD.labelText = [NSString stringWithFormat:@"Deploying resonator of level: %d", level];
			[[AppDelegate instance].window addSubview:HUD];
			[HUD show:YES];

			[[API sharedInstance] deployResonator:resonatorItem toPortal:self.portal toSlot:slot completionHandler:^(NSString *errorStr) {

				[HUD hide:YES];

				if (errorStr) {
					[Utilities showWarningWithTitle:errorStr];
				} else {

					dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
						[self refresh];
					});
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
                        [[SoundManager sharedManager] playSound:@"Sound/sfx_resonator_power_up.aif"];
                    }
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleSpeech]) {
                        [[API sharedInstance] playSounds:@[@"SPEECH_RESONATOR", @"SPEECH_DEPLOYED"]];
                        if ([self.portal.resonators count] == 1) {
                            [[API sharedInstance] playSounds:@[@"SPEECH_PORTAL", @"SPEECH_ONLINE", @"SPEECH_GOOD_WORK"]];
                        }
                    }
				}

			}];

		}

	} else {

		Resonator *resonatorItem = [Resonator MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && level = %d", level]];

		if (!resonatorItem) {

			[Utilities showWarningWithTitle:@"No resonator of that level remaining!"];

		} else {

			[[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Game Action" withAction:@"Upgrade Resonator" withLabel:self.portal.name withValue:@(resonatorItem.level)];

			MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
			HUD.userInteractionEnabled = YES;
			HUD.dimBackground = YES;
			HUD.removeFromSuperViewOnHide = YES;
			HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
			HUD.labelText = [NSString stringWithFormat:@"Upgrading resonator to level: %d", level];
			[[AppDelegate instance].window addSubview:HUD];
			[HUD show:YES];

			[[API sharedInstance] upgradeResonator:resonatorItem toPortal:self.portal toSlot:slot completionHandler:^(NSString *errorStr) {
				[HUD hide:YES];

				if (errorStr) {
					[Utilities showWarningWithTitle:errorStr];
				} else {

					dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
						[self refresh];
					});
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
                        [[SoundManager sharedManager] playSound:@"Sound/sfx_resonator_power_up.aif"];
                    }
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleSpeech]) {
                        [[API sharedInstance] playSounds:@[@"SPEECH_RESONATOR", @"SPEECH_UPGRADED"]];
                    }
				}

			}];

		}

	}

}

- (IBAction)rechargeButtonPressed:(GUIButton *)sender {

	__block MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
	HUD.userInteractionEnabled = YES;
	HUD.mode = MBProgressHUDModeIndeterminate;
	HUD.dimBackground = YES;
	HUD.removeFromSuperViewOnHide = YES;
	HUD.labelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
	HUD.labelText = @"Recharging...";
	[[AppDelegate instance].window addSubview:HUD];
	[HUD show:YES];

	[[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Game Action" withAction:@"Resonator Recharge" withLabel:self.portal.name withValue:@(sender.superview.tag)];

	[[API sharedInstance] rechargePortal:self.portal slots:@[@(sender.superview.tag)] completionHandler:^(NSString *errorStr) {

		[HUD hide:YES];

		if (errorStr) {
			[Utilities showWarningWithTitle:errorStr];
		} else {

			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
				[self refresh];
			});
			if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
                [[SoundManager sharedManager] playSound:@"Sound/sfx_resonator_recharge.aif"];
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleSpeech]) {
                [[API sharedInstance] playSounds:@[@"SPEECH_RESONATOR", @"SPEECH_RECHARGED"]];
            }
		}

	}];
	
}

#pragma mark - Shields

- (IBAction)shieldButtonPressed:(GUIButton *)sender {

	if (sender.disabled) { return; }

	MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
	HUD.userInteractionEnabled = YES;
	HUD.removeFromSuperViewOnHide = YES;
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.dimBackground = YES;
	HUD.showCloseButton = YES;

	_levelChooser = [ChooserViewController rarityChooserWithTitle:@"Choose shield rarity" completionHandler:^(ItemRarity rarity) {
		[HUD hide:YES];
		[self deployShieldOfRarity:rarity toSlot:sender.tag-100];
		_levelChooser = nil;
	}];
	HUD.customView = _levelChooser.view;

	[[AppDelegate instance].window addSubview:HUD];
	[HUD show:YES];

}

- (void)deployShieldOfRarity:(ItemRarity)rarity toSlot:(int)slot {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleEffects]) {
        [[SoundManager sharedManager] playSound:@"Sound/sfx_mod_power_up.aif"];
    }
    
	Shield *shieldItem = [Shield MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"dropped = NO && rarity = %d", rarity]];

	if (!shieldItem) {
		[Utilities showWarningWithTitle:@"No shield of that rarity remaining!"];
	} else {

		[[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Game Action" withAction:@"Deploy Shield" withLabel:self.portal.name withValue:@(shieldItem.rarity)];

		MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[AppDelegate instance].window];
		HUD.userInteractionEnabled = YES;
		HUD.dimBackground = YES;
		HUD.removeFromSuperViewOnHide = YES;
		HUD.detailsLabelFont = [UIFont fontWithName:[[[UILabel appearance] font] fontName] size:16];
		HUD.detailsLabelText = @"Deploying shield...";
		[[AppDelegate instance].window addSubview:HUD];
		[HUD show:YES];

		[[API sharedInstance] addMod:shieldItem toItem:self.portal toSlot:slot completionHandler:^(NSString *errorStr) {

			[HUD hide:YES];

			if (errorStr) {
				[Utilities showWarningWithTitle:errorStr];
			} else {

				[self refresh];
                if ([[NSUserDefaults standardUserDefaults] boolForKey:DeviceSoundToggleSpeech]) {
                    [[API sharedInstance] playSounds:@[@"SPEECH_SHIELD", @"SPEECH_DEPLOYED"]];
                }
			}
			
		}];
		
	}
	
}

@end
