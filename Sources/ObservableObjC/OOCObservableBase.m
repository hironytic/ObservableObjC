//
// OOCObservableBase.m
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

#import "OOCObservableBase.h"
#import "OOCAnonymousCancellable.h"
#import "OOCAnonymousObserver.h"
#import "OOCOperator.h"
#import "OOCPipeBuilder.h"

@interface OOCObservableBase ()
@end

@implementation OOCObservableBase

- (id <OOCObservable>)pipe:(void (^)(OOCPipeBuilder *))buildBlock {
    OOCPipeBuilder *builder = [OOCPipeBuilder new];
    buildBlock(builder);
    
    NSArray<id <OOCOperator>> *operators = [builder build];
    
    id <OOCObservable> result = self;
    for (id <OOCOperator> operator in operators) {
        result = [operator transformFrom:result];
    }
    return result;
}

- (id <OOCCancellable>)subscribe:(void (^)(id value))subscriber {
    return [self subscribeByObserver:[[OOCAnonymousObserver alloc] initWithSubscriber:subscriber]];
}

- (id <OOCCancellable>)subscribeByObserver:(id <OOCObserver>)observer {
    return [OOCAnonymousCancellable new];
}

@end
