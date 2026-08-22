#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

static UIWindow *overlayWindow = nil;
static BOOL is_key_valid = NO;
static NSInteger touch_counter = 0;
static NSTimer *touch_reset_timer = nil;
static BOOL menu_toggle_ready = YES;

// ---------------------------------------------------------------------
// Проверка ключа
// ---------------------------------------------------------------------
static BOOL validate_key(NSString *input) {
    NSString *valid = @"4955424GIV4805WL026841119Gn0DNt7Etjue6F";
    return [input isEqualToString:valid];
}

// ---------------------------------------------------------------------
// Показ алерта
// ---------------------------------------------------------------------
static void show_key_alert() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController 
            alertControllerWithTitle:@"Hack77"
            message:@"Enter activation key:"
            preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"Key";
            textField.secureTextEntry = YES;
            textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        }];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Activate" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *entered = alert.textFields.firstObject.text;
            if (validate_key(entered)) {
                is_key_valid = YES;
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Hack77_Activated"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                UIAlertController *success = [UIAlertController 
                    alertControllerWithTitle:@"✅ Activated!" 
                    message:@"Hack77 is now active.\nTriple tap with 3 fingers to open menu." 
                    preferredStyle:UIAlertControllerStyleAlert];
                [success addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
                [root presentViewController:success animated:YES completion:nil];
            } else {
                show_key_alert();
            }
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Exit" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            exit(0);
        }]];
        
        UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
        [root presentViewController:alert animated:YES completion:nil];
    });
}

// ---------------------------------------------------------------------
// Инициализация
// ---------------------------------------------------------------------
__attribute__((constructor)) static void init_tweak() {
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL activated = [[NSUserDefaults standardUserDefaults] boolForKey:@"Hack77_Activated"];
        if (activated) is_key_valid = YES;
        
        // Создаем окно для меню
        if (!overlayWindow) {
            overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            overlayWindow.windowLevel = UIWindowLevelStatusBar + 999;
            overlayWindow.backgroundColor = [UIColor clearColor];
            overlayWindow.userInteractionEnabled = YES;
            overlayWindow.hidden = NO;
            overlayWindow.rootViewController = [[UIViewController alloc] init];
            overlayWindow.rootViewController.view.backgroundColor = [UIColor clearColor];
        }
        
        if (!is_key_valid) show_key_alert();
    });
}

// ---------------------------------------------------------------------
// Хук UIApplication для обработки касаний
// ---------------------------------------------------------------------
%hook UIApplication
- (void)sendEvent:(UIEvent *)event {
    %orig;
    
    if (!is_key_valid) return;
    
    if (event.type == UIEventTypeTouches) {
        NSSet *touches = [event allTouches];
        NSInteger touchCount = touches.count;
        
        // Тройной тап тремя пальцами
        if (touchCount >= 3 && menu_toggle_ready) {
            BOOL all_began = YES;
            for (UITouch *t in touches) {
                if (t.phase != UITouchPhaseBegan && t.phase != UITouchPhaseStationary) {
                    all_began = NO;
                    break;
                }
            }
            
            if (all_began) {
                touch_counter++;
                [touch_reset_timer invalidate];
                touch_reset_timer = [NSTimer scheduledTimerWithTimeInterval:0.8 
                    target:self 
                    selector:@selector(resetTouchCounter) 
                    userInfo:nil 
                    repeats:NO];
                
                if (touch_counter >= 3) {
                    touch_counter = 0;
                    [touch_reset_timer invalidate];
                    // Показываем уведомление вместо меню (для теста)
                    UIAlertController *alert = [UIAlertController 
                        alertControllerWithTitle:@"Hack77" 
                        message:@"✅ Menu would open here!\n(full GUI coming soon)" 
                        preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                    UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
                    [root presentViewController:alert animated:YES completion:nil];
                    AudioServicesPlaySystemSound(1519);
                    
                    menu_toggle_ready = NO;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        menu_toggle_ready = YES;
                    });
                }
            }
        }
    }
}

%new
- (void)resetTouchCounter {
    touch_counter = 0;
}
%end
