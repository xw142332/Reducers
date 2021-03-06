//  Copyright (c) 2014 Rob Rix. All rights reserved.

#import "REDJoin.h"
#import "REDReducer.h"

id<REDIterable, REDReducible> REDJoin(id<REDIterable, REDReducible> collection, id separator) {
	return [REDReducer reducerWithReducible:collection transformer:^REDReducingBlock(REDReducingBlock reduce) {
		__block id currentSeparator;
		// Reduce as normal on the first call, and into the reduction of the separator on subsequent calls.
		return ^(id into, id each) {
			into = currentSeparator?
				reduce(into, currentSeparator)
			:	into;
			currentSeparator = separator;
			return reduce(into, each);
		};
	}];
}

l3_addTestSubjectTypeWithFunction(REDJoin)
l3_test(&REDJoin) {
	NSString *(^append)(NSString *, id) = ^(NSString *into, id each) { return [into stringByAppendingString:[each description]]; };
	id<REDIterable, REDReducible> reducible = @[ @0, @1, @2, @3 ];
	id separator = @".";
	
	id into = @"";
	id joined = @"0.1.2.3";
	l3_expect([REDJoin(reducible, separator) red_reduce:into usingBlock:append]).to.equal(joined);
}
