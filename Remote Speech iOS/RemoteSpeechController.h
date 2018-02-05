//
//  RemoteSpeechController.h
//  Remote Speech
//
//  Created by Collin Mistr on 1/1/17.
//  Copyright (c) 2017 Got 'Em Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RemoteSpeechControllerLoginDelegate <NSObject>
@optional
-(void)didLoginSuccessfully:(BOOL)loginStatus;
-(void)streamErrorOccurred:(int)errNum;
@end

@protocol RemoteSpeechControllerTargetSettingsDelegate <NSObject>
@optional
-(void)didReceiveVoicesList:(NSArray *)voices;
-(void)didReceiveCurrentVolume:(NSInteger)vol;
-(void)audioSendingWillStart;
-(void)audioSendingProgressDidChange:(float)value animated:(BOOL)anim;
-(void)audioDidFinishSending;
@end

@protocol RemoteSpeechControllerTargetTableDelegate <NSObject>
@optional
-(void)didReceiveTargetsList:(NSArray *)inTargets;
@end

@interface RemoteSpeechController : NSObject <NSStreamDelegate>
{
    NSInputStream *inputStream;
	NSOutputStream *outputStream;
    BOOL isConnected;
    BOOL isSignedIn;
    NSString *username;
    NSString *password;
    NSString *documentsDirectory;
    NSMutableDictionary *preferences;
    NSData *audioDataToSend;
    NSString *sentAudioFileName;
    BOOL sendingRawData;
}
@property (nonatomic, strong) id <RemoteSpeechControllerLoginDelegate> loginDelegate;
@property (nonatomic, strong) id <RemoteSpeechControllerTargetSettingsDelegate> targetSettingsDelegate;
@property (nonatomic, strong) id <RemoteSpeechControllerTargetTableDelegate> tableDelegate;

-(id)init;
-(void)initSocket;
-(void)closeSocket;
-(void)temporarilyCloseSocket;
-(void)resumeSocket;
-(void)sendToServer:(NSString *)stringToSend;
-(void)loginToServer:(NSString *)inUsername withPassword:(NSString *)inPassword isRememberedAccount:(BOOL)isRemembered;
-(void)getVolumeForTargetID:(NSString *)targetID;
-(void)getVoicesListForTargetID:(NSString *)targetID;
-(void)setVoiceOfTargetID:(NSString *)targetID withVoice:(NSString *)voice;
-(void)setVolumeOfTargetID:(NSString *)targetID withVolume:(NSInteger)vol;
-(void)sendMessageToTargetIDs:(NSArray *)targetIDs withMessage:(NSString *)messageToSend;
-(void)deleteTargetID:(NSString *)targetID;
-(void)addTargetWithID:(NSString *)targetID withName:(NSString *)targetName;
-(void)sendAudioFile:(NSString *)audioFilePath toTarget:(NSString *)targetID;

@end
