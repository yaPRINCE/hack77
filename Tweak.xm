%hook UIApplication
- (void)sendEvent:(UIEvent *)event {
    %orig;
    NSLog(@"[Hack77] Test hook working!");
}
%end
