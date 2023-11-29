import "String" as Str;

include "Number";



# fromdateiso8601sub_second
#
# Filter to convert an ISO8601 formatted timestamp to epoch seconds.
#
# note:
# - timestamp MUST be in 'zulu' timzone
# - this filter suports milliseconds
#
def datestamp2epoch:
    . | scan( "(.+?)([.][0-9]+)?Z$" )
    |
    ( .[0] + "Z" | fromdateiso8601 ) + ( .[1] // 0 | tonumber )
;



# Sadly computers do have a hard time computing with numbers outside base-2.
# This is resulted in a bit more comlicated code then first expected. There are
# a few things to consider:
# - rounding
#   the built in round only rounds to integers, therefore there is a 'decimals'
#   that returns a number rounded to what ever number of decimals to the right
#   of the decimal-comma. ( works with negative number of digits too)
# - modulo
#   the modulo arithematic opperator has the tendency to work on integers, not
#   on floating point numbers



# from_sec
#
# Filter that turns the given number of seconds into a 'duration-object', that
# must be used in the filters here after.
#
def from_sec:
{ 
    duration:       .,
    seconds:        .
}
;



# The below `to_*` filters all need a 'duration-object' from above and will
# return a 'duration-object' with the apropriate components.
#
# The mandatory `$i` parameter is used to specify the rounding of the least
# significant component.

def to_milli_sec($i):
{
    duration:   ( .duration ),
    milli_sec:  ( .duration * 1000 | round($i) )
}
;

def to_sec($i):
{
    duration:   ( .duration ),
    seconds:    ( .duration | round($i) )
}
;

def to_min_sec($i): to_sec($i) |
{
    duration:   ( .duration ),
    minutes:    ( .seconds / 60 | floor ),
    seconds:    ( .seconds -
                ( .seconds / 60 | floor * 60 ) | round($i)
                )
}
;

def to_hrs_min_sec($i): to_min_sec($i) |
{
    duration:   ( .duration ),
    hours:      ( .minutes / 60 | floor ),
    minutes:    ( .minutes -
                ( .minutes / 60 | floor * 60 )
                ),
    seconds:    ( .seconds )
}
;

def to_min($i):
{
    duration:   ( .duration ),
    minutes:    ( .duration / 60 | round($i) )
}
;

def to_hrs_min($i): to_min($i) |
{
    duration:   ( .duration ),
    hours:      ( .minutes / 60 | floor ),
    minutes:    ( .minutes -
                ( .minutes / 60 | floor * 60 ) | round($i)
                )
}
;

def to_day_hrs_min($i): to_hrs_min($i) |
{
    duration:   ( .duration ),
    days:       ( .hours / 24 | floor ),
    hours:      ( .hours -
                ( .hours / 24 | floor * 24 )
                ),
    minutes:    ( .minutes )
}
;

def to_hrs($i):
{
    duration:   ( .duration ),
    hours:      ( .duration / 3600 | round($i) )
}
;

def to_day_hrs($i): to_hrs($i) |
{
    duration:   ( .duration ),
    days:       ( .hours / 24 | floor ),
    hours:      ( .hours -
                ( .hours / 24 | floor * 24 ) | round($i)
                )
}
;

def to_day($i):
{
    duration:   ( .duration ),
    days:       ( .duration / 86400 | round($i) )
}
;

def to_wks_day($i): to_day($i) |
{
    duration:   ( .duration ),
    weeks:      ( .days / 7 | floor ),
    days:       ( .days -
                ( .days / 7 | floor * 7 ) | round($i)
                )
}
;



# to_human_components
#
# Filter that takes a 'duration-object' and returns a 'duration-object' that
# consists of one or two components (besides the `.duration` itself)
#
def to_human_components:
if   .duration < 1.0000 then to_milli_sec(0)
elif .duration < 60.000 then to_sec(3)
elif .duration < 3600.0 then to_min_sec(1)
elif .duration < 86400. then to_hrs_min(0)
elif .duration < 345600 then to_day_hrs(0)
elif .duration < 604800 then to_day(0)
else                         to_wks_day(0)
end
;



# components_to_short_string
#
# Filter that converts a 'duration-object' into a short string
#
def components_to_short_string:
[
    if has("weeks"    ) and .weeks     > 0 then "\(.weeks)w"      else empty end,
    if has("days"     ) and .days      > 0 then "\(.days)d"       else empty end,
    if has("hours"    ) and .hours     > 0 then "\(.hours)h"      else empty end,
    if has("minutes"  ) and .minutes   > 0 then "\(.minutes)m"    else empty end,
    if has("seconds"  ) and .seconds   > 0 then "\(.seconds)s"    else empty end,
    if has("milli_sec") and .milli_sec > 0 then "\(.milli_sec)ms" else empty end
]
| join("")
;



# _pick
#
# Filter that picks either the first or the last item of the list, depending on
# the value of the `$n` parameter. If `$n` is 1 then it picks the first element.
#
# This is particular usefull for picking either singular or plural nouns/verbs,
# assuming that the first element contains the singular version.
#
# Example
#   input:
#       3 as $count | [
#           "There is one word",
#           "There are \($count) words"
#       ] | _pick($count)
#   output:
#       "There are 3 words"
#
def _pick($n):
    if $n == 1 then .[0] else .[-1] end
;



# components_to_long_human_readable_string
#
# Filter that returns a 'long' human readable string containing each off the
# components in the 'duration-object'
#
def components_to_long_human_readable_string:
[
    if has("weeks") then .weeks as $n |
        [
            "\($n) week",
            "\($n) weeks"
        ] | _pick($n)
    else
        empty
    end,

    if has("days") then .days as $n |
        [
            "\($n) day",
            "\($n) days"
        ] | _pick($n)
    else
        empty
    end,

    if has("hours") then .hours as $n |
        [
            "\($n) hour",
            "\($n) hours"
        ] | _pick($n)
    else
        empty
    end,

    if has("minutes") then .minutes as $n |
        [
            "\($n) minute",
            "\($n) minutes"
        ] | _pick($n)
    else
        empty
    end,

    if has("seconds") then .seconds as $n |
        [
            "\($n) second",
            "\($n) seconds"
        ] | _pick($n)
    else
        empty
    end,
    
    if has("milli_sec") then .milli_sec as $n |
        [
            "\($n) milli-second",
            "\($n) milli-seconds"
        ] | _pick($n)
    else
        empty
    end
]
| Str::serial_and
;



def components_to_zero_padded_string:
[
    if has("weeks"    )
        then "\(.weeks     | Str::left_pad(2;"0") )w"      else empty end,
    if has("days"     )
        then "\(.days      | Str::left_pad(2;"0") )d"      else empty end,
    if has("hours"    )
        then "\(.hours     | Str::left_pad(2;"0") )h"      else empty end,
    if has("minutes"  )
        then "\(.minutes   | Str::left_pad(2;"0") )m"      else empty end,
    if has("seconds"  )
        then "\(.seconds   | Str::left_pad(2;"0") )s"      else empty end,
    if has("milli_sec")
        then "\(.milli_sec | Str::left_pad(3;"0") )ms"     else empty end
]
| join("")
;



# from_sec_to_short_string
#
# Filter that turns a duration in (fractional) seconds into a short string
# representation.
#
# Example
#   input:
#       123.45 | from_sec_to_short_string
#   output:
#       "2m3.5s"
#
def from_sec_to_short_string:
    from_sec | to_human_components | components_to_short_string
;



# from_sec_to_long_human_readable_string
#
# Filter that turns a duration in (fractional) seconds into a string that humans
# prefer to 'read' as text.
#
# Example
#   input:
#       65.4321 | from_sec_to_long_human_readable_string
#   output:
#       "1 minute and 5.4 seconds"
#
def from_sec_to_long_human_readable_string:
    from_sec | to_human_components | components_to_long_human_readable_string
;



# from_sec_to_zero_padded_hrs_min_sec_string
#
def from_sec_to_zero_padded_hrs_min_sec_string:
    from_sec | to_hrs_min_sec(0) | components_to_zero_padded_string
;



def to_hms:          from_sec_to_zero_padded_hrs_min_sec_string;
def to_short_string: from_sec_to_short_string;
def to_human_string: from_sec_to_long_human_readable_string;