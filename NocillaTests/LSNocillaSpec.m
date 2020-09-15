#import "Kiwi.h"
#import "LSNocilla.h"
#import "LSStubRequest.h"
#import "LSStubResponse.h"

SPEC_BEGIN(LSNocillaSpec)

describe(@"-responseForRequest:", ^{
    context(@"when the specified request matches a previously stubbed request", ^{
        it(@"returns the associated response", ^{
            LSStubRequest *stubbedRequest = [[LSStubRequest alloc] initWithMethod:@"GET" url:@"http://www.google.com"];
            LSStubResponse *stubbedResponse = [[LSStubResponse alloc] initWithStatusCode:403];
            stubbedRequest.response = stubbedResponse;
            [[LSNocilla sharedInstance] addStubbedRequest:stubbedRequest];

            NSObject<LSHTTPRequest> *actualRequest = [KWMock nullMockForProtocol:@protocol(LSHTTPRequest)];
            [actualRequest stub:@selector(url) andReturn:[NSURL URLWithString:@"http://www.google.com"]];
            [actualRequest stub:@selector(method) andReturn:@"GET"];

            LSStubResponse *result = [[LSNocilla sharedInstance] responseForRequest:actualRequest];

            [[result should] equal:stubbedResponse];

            [[LSNocilla sharedInstance] clearStubs];
        });

        describe(@"when a stubbed request is replaced with a new stub", ^{
            it(@"returns the response for the newer stub", ^{
                LSStubRequest *firstStub = [[LSStubRequest alloc] initWithMethod:@"GET" url:@"http://www.google.com"];
                LSStubResponse *firstResponse = [[LSStubResponse alloc] initWithStatusCode:403];
                firstStub.response = firstResponse;
                [[LSNocilla sharedInstance] addStubbedRequest:firstStub];

                LSStubRequest *secondStub = [[LSStubRequest alloc] initWithMethod:@"GET" url:@"http://www.google.com"];
                LSStubResponse *secondResponse = [[LSStubResponse alloc] initWithStatusCode:200];
                secondStub.response = secondResponse;
                [[LSNocilla sharedInstance] addStubbedRequest:secondStub];

                NSObject<LSHTTPRequest> *actualRequest = [KWMock nullMockForProtocol:@protocol(LSHTTPRequest)];
                [actualRequest stub:@selector(url) andReturn:[NSURL URLWithString:@"http://www.google.com"]];
                [actualRequest stub:@selector(method) andReturn:@"GET"];

                LSStubResponse *result = [[LSNocilla sharedInstance] responseForRequest:actualRequest];

                [[result shouldNot] equal:firstResponse];
                [[result should] equal:secondResponse];

                [[LSNocilla sharedInstance] clearStubs];
            });
        });
    });

    context(@"when the specified request does not match any stubbed request", ^{
        it(@"response should be nil", ^{
            NSObject<LSHTTPRequest> *actualRequest = [KWMock nullMockForProtocol:@protocol(LSHTTPRequest)];
            [actualRequest stub:@selector(url) andReturn:[NSURL URLWithString:@"http://www.google.com"]];
            [actualRequest stub:@selector(method) andReturn:@"GET"];

            [[[[LSNocilla sharedInstance] responseForRequest:actualRequest] should] beNil];

            [[LSNocilla sharedInstance] clearStubs];
        });
    });
});

SPEC_END
