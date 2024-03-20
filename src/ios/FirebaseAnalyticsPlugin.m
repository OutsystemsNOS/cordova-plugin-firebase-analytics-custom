#import "FirebaseAnalyticsPlugin.h"

@import Firebase;
@import AppTrackingTransparency;

@implementation FirebaseAnalyticsPlugin

- (void)pluginInitialize {
    NSLog(@"Starting Firebase Analytics plugin");

    if(![FIRApp defaultApp]) {
        [FIRApp configure];
    }
}

- (void)setConsent:(CDVInvokedUrlCommand *)command {
    NSString* ConsentTypeAnalyticsStorage = [command.arguments objectAtIndex:0];
    NSString* ConsentTypeAdStorage = [command.arguments objectAtIndex:1];
    NSString* ConsentTypeAdUserData = [command.arguments objectAtIndex:2];
    NSString* ConsentTypeAdPersonalization = [command.arguments objectAtIndex:3];

    NSMutableDictionary *consentDictionary = [NSMutableDictionary dictionary];
    
    if ([ConsentTypeAnalyticsStorage isEqualToString:@"true"]) {
        [consentDictionary setObject:FIRConsentStatusGranted forKey:FIRConsentTypeAnalyticsStorage];
    } else {
        [consentDictionary setObject:FIRConsentStatusDenied forKey:FIRConsentTypeAnalyticsStorage];
    }
    
    if ([ConsentTypeAdStorage isEqualToString:@"true"]) {
        [consentDictionary setObject:FIRConsentStatusGranted forKey:FIRConsentTypeAdStorage];
    } else {
        [consentDictionary setObject:FIRConsentStatusDenied forKey:FIRConsentTypeAdStorage];
    }
    
    if ([ConsentTypeAdUserData isEqualToString:@"true"]) {
        [consentDictionary setObject:FIRConsentStatusGranted forKey:FIRConsentTypeAdUserData];
    } else {
        [consentDictionary setObject:FIRConsentStatusDenied forKey:FIRConsentTypeAdUserData];
    }
    
    if ([ConsentTypeAdPersonalization isEqualToString:@"true"]) {
        [consentDictionary setObject:FIRConsentStatusGranted forKey:FIRConsentTypeAdPersonalization];
    } else {
        [consentDictionary setObject:FIRConsentStatusDenied forKey:FIRConsentTypeAdPersonalization];
    }
    
    [FIRAnalytics setConsent:consentDictionary];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)logEvent:(CDVInvokedUrlCommand *)command {
    NSString* name = [command.arguments objectAtIndex:0];
    NSDictionary* parameters = [command.arguments objectAtIndex:1];

    [FIRAnalytics logEventWithName:name parameters:parameters];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setUserId:(CDVInvokedUrlCommand *)command {
    NSString* id = [command.arguments objectAtIndex:0];

    [FIRAnalytics setUserID:id];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setUserProperty:(CDVInvokedUrlCommand *)command {
    NSString* name = [command.arguments objectAtIndex:0];
    NSString* value = [command.arguments objectAtIndex:1];

    [FIRAnalytics setUserPropertyString:value forName:name];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setEnabled:(CDVInvokedUrlCommand *)command {
    bool enabled = [[command.arguments objectAtIndex:0] boolValue];

    [FIRAnalytics setAnalyticsCollectionEnabled:enabled];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setCurrentScreen:(CDVInvokedUrlCommand *)command {
    NSString* screenName = [command.arguments objectAtIndex:0];

    [FIRAnalytics logEventWithName:kFIREventScreenView parameters:@{
        kFIRParameterScreenName: screenName
    }];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setScreenView:(CDVInvokedUrlCommand *)command {
    NSString* screenName = [command.arguments objectAtIndex:0];
    NSString* screenClass = [command.arguments objectAtIndex:1];

    [FIRAnalytics logEventWithName:kFIREventScreenView parameters:@{
        kFIRParameterScreenName: screenName,
         kFIRParameterScreenClass: screenClass
    }];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)resetAnalyticsData:(CDVInvokedUrlCommand *)command {
    [FIRAnalytics resetAnalyticsData];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setDefaultEventParameters:(CDVInvokedUrlCommand *)command {
    NSDictionary* params = [command.arguments objectAtIndex:0];

    [FIRAnalytics setDefaultEventParameters:params];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)requestTrackingAuthorization:(CDVInvokedUrlCommand *)command {
    
    bool showInformation = [[command.arguments objectAtIndex:0] boolValue];

    if(showInformation) {
        
        NSString* title = [command.arguments objectAtIndex:1];
        NSString* message = [command.arguments objectAtIndex:2];
        NSString* buttonTitle = [command.arguments objectAtIndex:3];
        
        [self showPermissionInformationPopup:title :message :buttonTitle :^(UIAlertAction *action ) {
            [self showTrackingAuthorizationPopup:command];
        }];
        
    }
    else {
        [self showTrackingAuthorizationPopup:command];
    }
}

- (void)showTrackingAuthorizationPopup:(CDVInvokedUrlCommand *)command {
    
    if (@available(iOS 14, *)) {
        
        NSDictionary *dict = NSBundle.mainBundle.infoDictionary;
        
        if([dict objectForKey:@"NSUserTrackingUsageDescription"]){
            [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                BOOL result = status == ATTrackingManagerAuthorizationStatusAuthorized;
                
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:result];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }];
            return;
        }
    }
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:true];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

typedef void (^showPermissionInformationPopupHandler)(UIAlertAction*);
- (void)showPermissionInformationPopup:
(NSString *)title :
(NSString *)message :
(NSString *)buttonTitle :
(showPermissionInformationPopupHandler)confirmationHandler
{
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:title
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:buttonTitle
                               style:UIAlertActionStyleDefault
                               handler:confirmationHandler];
    
    [alert addAction:okAction];
    [self.viewController presentViewController:alert animated:YES completion:nil];
}



@end
