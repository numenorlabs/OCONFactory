#import "OCONFactory.h"

using namespace Cedar::Matchers;


@interface SimplePropertyClass : NSObject

@property (nonatomic) NSInteger integer;
@property (strong, nonatomic) NSString *string;

@end


@implementation SimplePropertyClass; @end


@interface SpecialPropertyClass : SimplePropertyClass

@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSURL *url2;

@end


@implementation SpecialPropertyClass; @end


@interface ArrayPropertyClass : NSObject

@property (strong, nonatomic) NSArray *urls;

- (Class)classForArrayProperty:(NSString *)propertyName;

@end


@implementation ArrayPropertyClass

- (Class)classForArrayProperty:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"urls"]) {
        return [NSURL class];
    }
    return nil;
}

@end


SPEC_BEGIN(OCONFactorySpec)

describe(@"OCONFactory", ^{
    __block OCONFactory *factory = nil;

    beforeEach(^{
        factory = [[OCONFactory new] autorelease];
    });

    describe(@"simple values", ^{
        it(@"should be applied", ^{
            NSDictionary *values = @{
                @"integer": @42,
                @"string": @"Hi",
            };
            SimplePropertyClass *instance = [[SimplePropertyClass new] autorelease];

            [factory applyProperties:values toObject:instance];

            expect(instance.integer).to(equal(42));
            expect(instance.string).to(equal(@"Hi"));
        });
    });

    describe(@"special values", ^{
        it(@"should be translated from simple values and applied", ^{
            NSDictionary *values = @{
                @"url": [NSURL URLWithString:@"http://a.url"],
                @"url2": @"http://another.url",
            };
            SpecialPropertyClass *instance = [[SpecialPropertyClass new] autorelease];

            [factory applyProperties:values toObject:instance];

            expect(instance.url.absoluteString).to(equal(@"http://a.url"));
            expect(instance.url2.absoluteString).to(equal(@"http://another.url"));
        });
    });

    describe(@"arrays of values", ^{
        it(@"should be collected and applied", ^{
            NSDictionary *values = @{
                @"urls": @[
                    [NSURL URLWithString:@"http://a.url"],
                    @"http://another.url",
                ],
            };
            ArrayPropertyClass *instance = [[ArrayPropertyClass new] autorelease];

            [factory applyProperties:values toObject:instance];

            expect([[instance.urls objectAtIndex:0] absoluteString]).to(equal(@"http://a.url"));
            expect([[instance.urls objectAtIndex:1] absoluteString]).to(equal(@"http://another.url"));
        });
    });
});

SPEC_END
