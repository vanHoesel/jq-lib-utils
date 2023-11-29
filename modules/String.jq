def trim_whitespace:
    sub("^\\s*(?<X>.*?)\\s*$";"\(.X)")
;

def skip_empty:
    if ( . == "" ) then empty else . end
;

def split_trim_skip_empty($str):
    split($str) | map(trim_whitespace | skip_empty )
;

def serial_comma($conjunction): . as $list |
    if $list | length == 0
    then
        empty
    elif $list | length == 1
    then
        $list[0] | tostring
    elif $list | length == 2
    then
        $list[:-1] +   [$conjunction] + $list[-1:] | join(" ")
    else
        $list[:-1] + [ [$conjunction] + $list[-1:] | join(" ") ] | join(", ")
    end
;

def serial_or:
    serial_comma("or")
;

def serial_and:
    serial_comma("and")
;



def left_pad($n; $str):  tostring | ($n - length) as $l | ($str * $l)[:$l] + .;

def left_pad($n):        left_pad($n; " ");

def left_pad:            left_pad(4);

def right_pad($n; $str): tostring | ($n - length) as $l | . + ($str * $l)[:$l];

def right_pad($n):       right_pad($n; " ");

def right_pad:           right_pad(4);


 
