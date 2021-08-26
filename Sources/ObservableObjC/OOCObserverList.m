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

// MARK: - OOCObserverWithTag

@interface OOCObserverWithTag : NSObject
@property(nonatomic, copy) OOCObserver observer;
@property(nonatomic, assign) NSUInteger tag;
@end

@implementation OOCObserverWithTag
@end

// MARK: - OOCObserverList

@interface OOCObserverList ()
@property(nonatomic, assign) NSUInteger lastTag;
@property(nonatomic, strong) NSMutableArray<OOCObserverWithTag *> *storage;
@end

@implementation OOCObserverList

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _lastTag = OOC_INVALID_OBSERVER_LIST_TAG;
        _storage = [NSMutableArray new];
    }
    return self;
}

- (NSUInteger)addObserver:(OOCObserver)observer {
    @synchronized (self) {
        NSUInteger tag = ++_lastTag;
        OOCObserverWithTag *owt = [OOCObserverWithTag new];
        owt.observer = observer;
        owt.tag = tag;
        [self.storage addObject:owt];
        return tag;
    }
}

- (void)removeObserver:(NSUInteger)tag {
    @synchronized (self) {
        NSUInteger index = [self.storage indexOfObjectPassingTest:^BOOL(OOCObserverWithTag * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return obj.tag == tag;
        }];
        if (index != NSNotFound) {
            [self.storage removeObjectAtIndex:index];
        }
    }
}

- (void)removeAllObservers {
    @synchronized (self) {
        [self.storage removeAllObjects];
    }
}

- (void)sendToAllObservers:(id)value {
    NSMutableArray *allObservers;
    
    @synchronized (self) {
        allObservers = [[NSMutableArray alloc] initWithCapacity:[self.storage count]];
        for (OOCObserverWithTag *owt in self.storage) {
            [allObservers addObject:owt.observer];
        }
    }
    
    for (OOCObserver observer in allObservers) {
        observer(value);
    }
}

@end
