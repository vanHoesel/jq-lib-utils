# jq-lib-utils

A library containing several useful filters

# JQ Library Utilities

JQ is an amazing commandline tool to manipulate JSON structures through smart
filters that transform one object, array, or value into another. But as with
many tools and programming languages, there are allways features missing.

These files are hopefully a good set of useful filters.

## Synopsis

Assuming the files contained in this repositories are located in a (local) `.jq`
directory, `jq` can be invoked as `jq -L .jq`, which will then make it possible
to `import "SomeLib" as Some;` and later use the filter like `Some::filter`.

### making duration readable for humans

```
jq --null-input -L .jq 'import "DateTime" as DT; 65.4321 | DT::to_human_string'
```
will print:
```
"1 minute and 5.4 seconds"
```
on the terminal.

### having arbitrary rounding

```
jq -n -L .jq ' include "Number"; 12345.678 | round, round(2), round(-1)'
```
will produce
```
12346
12345.68
12350
```

> This latter example also demonstrates the possiblity to redefine standard
> functions and let `jq` figure out which to use, based on 'multi-signature'
> subroutines

## Number.jq

### round($n)


## String.jq

### trim_whitespace

### skip_empty

### split_trim_skip_empty($str)

### serial_comma($conjunction)

### serial_or

### serial_and

### left_pad($n; $str)

## DateTime::jq

### fromdateiso8601sub_second

### from_sec

### to_milli_sec

### to_sec

### to_min_sec

### to_hrs_min_sec

### to_min

### to_hrs_min

### to_day_hrs_min

### to_hrs

### to_day_hrs

### to_day

### to_wks_day

### to_human_components

### components_to_short_string

### components_to_long_human_readable_string

### components_to_zero_padded_string

### from_sec_to_short_string

### from_sec_to_long_human_readable_string

### from_sec_to_zero_padded_hrs_min_sec_string

### sec2hms

### sec2short_string

### sec2human_string
