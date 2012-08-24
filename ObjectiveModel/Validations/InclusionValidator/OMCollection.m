/*
 * Copyright © 2011-2012 Michael R. Fleet (github.com/f1337)
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */



#import "OMCollection.h"



@implementation NSDictionary (ContainsObject)



- (BOOL)containsObject:(id)object
{
    if ( object )
    {
        NSEnumerator *enumerator = [self objectEnumerator];
        id value = nil;
        while ( (value = [enumerator nextObject]) )
        {
            if ( [value isEqual:object] )
            {
                return YES;
                break;
            }
        }
    }

    return NO;
}



@end



@implementation NSString (ContainsObject)



- (BOOL)containsObject:(id)object
{
    if ( object && [object respondsToSelector:@selector(description)] )
    {
        NSRange range = [self rangeOfString:[object description]];
        return ( range.location != NSNotFound );
    }

    return NO;
}



@end
