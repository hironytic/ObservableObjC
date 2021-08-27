//
// OOCObserverList.m
// 
//
// Copyright (c) 2021 Hironori Ichimiya <hiron@hironytic.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "OOCObserverList.h"

@interface OOCObserverList ()
@property(nonatomic, strong) NSMutableArray<id <OOCObserver>> *storage;
@end

@implementation OOCObserverList

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _storage = [NSMutableArray new];
    }
    return self;
}

- (void)addObserver:(id <OOCObserver>)observer {
    @synchronized (self) {
        [self.storage addObject:observer];
    }
}

- (void)removeObserver:(id <OOCObserver>)observer {
    @synchronized (self) {
        [self.storage removeObject:observer];
    }
}

- (void)removeAllObservers {
    @synchronized (self) {
        [self.storage removeAllObjects];
    }
}

- (void)sendToAllObservers:(id)value {
    NSArray *allObservers;
    
    @synchronized (self) {
        allObservers = [self.storage copy];
    }
    
    for (id <OOCObserver> observer in allObservers) {
        [observer onValue:value];
    }
}

@end
