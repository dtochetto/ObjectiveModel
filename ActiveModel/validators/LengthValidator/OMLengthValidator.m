/*!
 * Copyright © 2011-2012 Michael R. Fleet (github.com/f1337)
 *
 * Portions of this software were transliterated from Ruby on Rails.
 * https://github.com/rails/rails/blob/master/activemodel/lib/active_model/validations/length.rb
 * Ruby on Rails is Copyright © 2004-2012 David Heinemeier Hansson.
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



#import "OMLengthValidator.h"



@implementation OMLengthValidator



@synthesize equals = _equals;
@synthesize maximum = _maximum;
@synthesize minimum = _minimum;
@synthesize tooLongMessage = _tooLongMessage;
@synthesize tooShortMessage = _tooShortMessage;
@synthesize wrongLengthMessage = _wrongLengthMessage;



- (void)dealloc
{
    [self setEquals:nil];
    [self setMaximum:nil];
    [self setMinimum:nil];
    [self setTooLongMessage:nil];
    [self setTooShortMessage:nil];
    [self setWrongLengthMessage:nil];
    [super dealloc];
}



- (NSString *)message
{
    return [super message];
}



// TODO: move into OMValidator base class after refactoring other siblings
- (void)setOptions:(NSDictionary *)options
{
    // filter out the properties that require special attention
    NSMutableDictionary *filteredOptions = [NSMutableDictionary dictionaryWithDictionary:options];
    NSMutableArray *keys = [NSMutableArray array];
    [keys addObject:@"allowBlank"];
    [keys addObject:@"allowNil"];
    // when this is moved into the base class, "message" no longer needs filtered
    [keys addObject:@"message"];
    [filteredOptions removeObjectsForKeys:keys];

    // this is where the magic happens: KVC, baby!
    [self setValuesForKeysWithDictionary:filteredOptions];

    // and hit the superclass for the special handling of allowNil, allowBlank
    [super setOptions:options];
}



- (BOOL)validateModel:(OMActiveModel *)model withValue:(NSObject *)value forKey:(NSString *)inKey error:(NSError **)outError
{
    // the superclass' validation will return YES if validation is to be skipped
    if ( [self shouldSkipValidationForValue:value] )
    {
        return YES;
    }

    // split the string into tokens?
    // use case: counting words
    // value = tokenize(value)

    // value_length = value.respond_to?(:length) ? value.length : value.to_s.length
    NSNumber *valueLength;
    if ( [value respondsToSelector:@selector(length)] )
    {
        valueLength = [NSNumber numberWithUnsignedInteger:[(id)value length]];
    }
    else if ( [value respondsToSelector:@selector(count)] )
    {
        valueLength = [NSNumber numberWithUnsignedInteger:[(id)value count]];
    }
    else
    {
        valueLength = [NSNumber numberWithUnsignedInteger:[[value description] length]];
    }

    // MESSAGES  = { :is => :wrong_length, :minimum => :too_short, :maximum => :too_long }.freeze
    // TODO: make MESSAGES static!
    NSDictionary *messageKeys = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"wrongLengthMessage", @"equals",
                            @"tooShortMessage", @"minimum",
                            @"tooLongMessage", @"maximum",
                            nil];

    NSDictionary *defaultMessages = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"is the wrong length (should be %{count} characters)", @"wrongLengthMessage",
                              @"is too short (minimum is %{count} characters)", @"tooShortMessage",
                              @"is too long (maximum is %{count} characters)", @"tooLongMessage",
                              nil];

    // CHECKS    = { :is => :==, :minimum => :>=, :maximum => :<= }.freeze
    // TODO: make CHECKS static!
    NSDictionary *checks = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"isEqualToNumber:", @"equals",
                            @"isGreaterThanOrEqualToNumber:", @"minimum",
                            @"isLessThanOrEqualToNumber:", @"maximum",
                            nil];

    // RESERVED_OPTIONS  = [:minimum, :maximum, :within, :is, :tokenizer, :too_short, :too_long]

    BOOL valid = YES;

    // CHECKS.each do |key, validity_check|
    for (NSString *key in checks)
    {
        NSNumber *checkValue;
        SEL validityCheckSelector;

        if (
            // next unless check_value = options[key]
            // skip the check if it isn't defined
            ( checkValue = [self valueForKey:key] )
            // extra sanity check to ensure the selector isn't nil
            && ( validityCheckSelector = NSSelectorFromString([checks objectForKey:key]) )
            // next if value_length.send(validity_check, check_value)
            // if the selector returns true, skip to the next check
            && ( ! ([valueLength performSelector:validityCheckSelector withObject:checkValue]) )
        )
        {
            valid = NO;

            //errors_options = options.except(*RESERVED_OPTIONS)
            //errors_options[:count] = check_value
            //default_message = options[MESSAGES[key]]
            //errors_options[:message] ||= default_message if default_message
            NSString *message;
            if ( ! (
                    ( message = [self message] )
                    ||
                    (message = [self valueForKey:[messageKeys objectForKey:key]])
            ))
            {
                message = [defaultMessages objectForKey:[messageKeys objectForKey:key]];
            }
            message = [message stringByReplacingOccurrencesOfString:@"%{count}" withString:[checkValue stringValue]];

            //record.errors.add(attribute, MESSAGES[key], errors_options)
            [self errorWithOriginalError:outError value:value forKey:inKey message:message];
        }

    }

    return valid;
}



@end
