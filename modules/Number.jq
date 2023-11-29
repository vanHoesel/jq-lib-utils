# round
#
# round number to the given precision
#
# Note, this also works with negative precision, using to round to the nearest
# ten or hundred, or thousand.

def round($n):
    . * ( $n | exp10 ) | round | . / ( $n | exp10 )
;
