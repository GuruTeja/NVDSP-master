//
//  ViewController.m
//  NVDSPExample
//
//  Created by Bart Olsthoorn on 25/04/2013.
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
int segmentnumber;



- (void)viewDidLoad
{
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    ringBuffer = new RingBuffer(32768, 2);
    audioManager = [Novocaine audioManager];
    
    
    float samplingRate = 10000.0;//audioManager.samplingRate;
    
    // Audio File Reading
    NSURL *inputFileURL = [[NSBundle mainBundle] URLForResource:@"TLC" withExtension:@"mp3"];

    HPF = [[NVHighpassFilter alloc] initWithSamplingRate:samplingRate];
    HPF.Q = 0.5f;
    _HPF_cornerFrequency = 2000.0f;
    LPF = [[NVLowpassFilter alloc] initWithSamplingRate:samplingRate];
    _LPF_cornerFrequency = 800.0f;
    LPF.Q = 0.8f;
    BPF = [[NVBandpassFilter alloc] initWithSamplingRate:samplingRate];
    _BPF_centerFrequency = 2500.0f;;
    BPF.Q = 0.9f;

    CDT = [[NVClippingDetection alloc] init];
    
    fileReader = [[AudioFileReader alloc]
                  initWithAudioFileURL:inputFileURL 
                  samplingRate:audioManager.samplingRate
                  numChannels:audioManager.numOutputChannels];
    
    
    [fileReader play];  //plays the audio file ,if any changes applied it will apply it and play back from bufferNewAudio method (ringbuffer)
    fileReader.currentTime = 30.0;
    NSLog(@"in here1");
    [self SegmentControlAction:nil];
}

- (IBAction)SegmentControlAction:(id)sender {
    NSLog(@"in here");
    
    switch (_SegmentControl.selectedSegmentIndex) {
        case 0:
            NSLog(@"in High");
            segmentnumber = 1;
            [self segmentControlChanged];
            break;
        case 1:
            NSLog(@"in Low");
            segmentnumber = 2;
            [self segmentControlChanged];
            break;
        case 2:
            NSLog(@"in Band");
            segmentnumber = 3;
            [self segmentControlChanged];
            break;
        default:
            break;
    }
}

- (void)HPFSliderChanged:(UISlider *)sender
{
    _HPF_cornerFrequency = sender.value;
    NSLog(@"\n HPF slider value %f",_HPF_cornerFrequency);
    [self segmentControlChanged];
}

- (void)LPFSliderChanged:(UISlider *)sender {
    _LPF_cornerFrequency = sender.value;
    NSLog(@"\n LPF slider value %f",_LPF_cornerFrequency);
    [self segmentControlChanged];
}

- (IBAction)BPFSliderChanged:(UISlider *)sender {
    _BPF_centerFrequency = sender.value;
    NSLog(@"\n BPF slider value %f",_BPF_centerFrequency);
    [self segmentControlChanged];
}



#pragma SegmentControl Changed

- (void)segmentControlChanged {
    NSLog(@"segment number is %d",segmentnumber);
    switch (segmentnumber) {
            NSLog(@"in switch case");
        case 1:
            NSLog(@"in High Pass");
            [audioManager setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
             {
                 //NSLog(@"SetOutputBlock audio data %f",*data);
                 [fileReader retrieveFreshAudio:data numFrames:numFrames numChannels:numChannels];
                 HPF.cornerFrequency = _HPF_cornerFrequency;
                 [HPF filterData:data numFrames:numFrames numChannels:numChannels];
                 [CDT counterClipping:data numFrames:numFrames numChannels:numChannels];
             }];
            break;
        case 2:
            NSLog(@"in Low Pass");
            [audioManager setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
             {
                 [fileReader retrieveFreshAudio:data numFrames:numFrames numChannels:numChannels];
                 LPF.cornerFrequency = _LPF_cornerFrequency;
                 [LPF filterData:data numFrames:numFrames numChannels:numChannels];
                 [CDT counterClipping:data numFrames:numFrames numChannels:numChannels];
             }];
            break;
        case 3:
            NSLog(@"in Band Pass");
            [audioManager setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
             {
                 [fileReader retrieveFreshAudio:data numFrames:numFrames numChannels:numChannels];
                 BPF.centerFrequency = _BPF_centerFrequency;
                 [BPF filterData:data numFrames:numFrames numChannels:numChannels];
                 [CDT counterClipping:data numFrames:numFrames numChannels:numChannels];
             }];
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc {
    //[_LPF_cornerFrequency release];
    [_SegmentControl release];
    [super dealloc];
}
@end
