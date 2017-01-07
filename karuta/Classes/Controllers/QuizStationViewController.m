//
//  QuizStationViewController.m
//  karuta
//
//  Created by 荻原有二 on 2016/12/26.
//  Copyright © 2016年 Yuji Ogihara. All rights reserved.
//

#import "QuizStationViewController.h"
#import "HomeViewController.h"

@interface QuizStationViewController ()<AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *answer1Button;
@property (weak, nonatomic) IBOutlet UIButton *tryAgainButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *commentText;

@property int currentPosition ;

@property NSMutableArray *order ;

- (void)updateView ;
- (void)swap123:(int *)table pos_1:(int)a pos_2:(int)b ;
- (void)onAnswer:(int)answer ;

@property(nonatomic) AVAudioPlayer *audioPlayer ;
@property(nonatomic) NSTimer *timeBeforeReading, *timeAfterReading ;

@property(nonatomic) int repeatCount ;

@end

@implementation QuizStationViewController

@synthesize routeContent = _routeContent ;

#define NUMBER_OF_ANSWERS (3)

int answers[NUMBER_OF_ANSWERS] ;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentPosition =  0;
    
    [self setRandomOrder];
    
    [self prepareReading] ;
//    [self initAudio];
//    [self updateView] ;
}


- (void)setRandomOrder {
    self.order = [[NSMutableArray alloc] init];

    int numberOfStations = [self.routeContent getNumberOfStations];

    for (int i = 0;i < numberOfStations;i++) {
        [self.order addObject:[NSNumber numberWithInteger:i]];
    }
    for (int i = 0;i < numberOfStations;i++) {
        int dest = i + ((uint64_t)arc4random() % (numberOfStations - i)) ;
        NSNumber *tmp = [self.order objectAtIndex:i] ;
        
        [self.order replaceObjectAtIndex:i withObject:[self.order objectAtIndex:dest]];
        [self.order replaceObjectAtIndex:dest withObject:tmp];
    }
    for(int i = 0;i < numberOfStations; i++){
        int order = [[self.order objectAtIndex:i] intValue];
        NSLog(@"%d:%d",i,order);
    }
}

- (void)prepareReading {

    int order = [[self.order objectAtIndex:self.currentPosition] intValue];

    StationContent *station = [self.routeContent getStationContent:order];
    NSError *error ;
    
    NSData *voiceData = [station getVoiceData] ;

    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:voiceData error:&error];
    self.audioPlayer.numberOfLoops = 0 ;
    if ( error != nil ) {
        NSLog(@"Error %@", [error localizedDescription]);
    }
    [self.audioPlayer setDelegate:self];
    self.repeatCount = 5 ;
    
    _timeBeforeReading = [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(expiredTimerBeforeReading:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)expiredTimerBeforeReading:(NSTimer*)t {
    [self startReading];
}
    
- (void)startReading {
    
    self.navigationItem.title = [NSString stringWithFormat:@"第%d番/%d",
                        self.currentPosition + 1,
                        [self.routeContent getNumberOfStations]];

    int order = [[self.order objectAtIndex:self.currentPosition] intValue];
    StationContent *station = [self.routeContent getStationContent:order];
    
    self.commentText.text = [station getText];
    
    [self.audioPlayer play] ;
    NSLog(@"Reading.... Order=%d,Text=%@",order,[station getText]) ;
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"Finished reading");
    
    _timeAfterReading = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                          target:self
                                                        selector:@selector(expiredTimerAfterReading:)
                                                        userInfo:nil
                                                         repeats:NO];
}

- (void)expiredTimerAfterReading:(NSTimer*)t {

    if (self.repeatCount > 0) {
        self.repeatCount-- ;
        [self startReading] ;
    } else {
        [self gotoNextItem] ;
    }
}

    
    
- (void)showLastView {
    self.answer1Button.hidden = YES ;
    self.answer1Button.enabled = NO ;
    
    self.tryAgainButton.hidden = NO ;
    self.backButton.hidden = NO ;
    self.tryAgainButton.enabled= YES;
    self.backButton.enabled = YES ;
    self.commentText.text = @"到着〜!";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation

- (void)gotoNextItem {
    
    [_timeBeforeReading invalidate ] ;
    [_timeAfterReading invalidate ] ;
    [_audioPlayer stop] ;
    
    int numberOfStations = [self.routeContent getNumberOfStations];
    
    if (self.currentPosition < numberOfStations - 1) {
        self.currentPosition++ ;
        [self prepareReading] ;
    } else {
        self.currentPosition = 0 ;
        [self showLastView];
    }
}

- (void)onAnswer1:(int)answer {
    [self gotoNextItem];
}

- (IBAction)onTryAgain:(id)sender {
    NSInteger count       = self.navigationController.viewControllers.count - 2;
    HomeViewController *vc = [self.navigationController.viewControllers objectAtIndex:count];
    [self.navigationController popToViewController:vc animated:YES];
}

- (IBAction)onBack:(id)sender {
    NSInteger count       = self.navigationController.viewControllers.count - 3;
    HomeViewController *vc = [self.navigationController.viewControllers objectAtIndex:count];
    [self.navigationController popToViewController:vc animated:YES];
}

@end
