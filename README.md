# ASCII Timecard tracking 

Text file based time tracking, no web app, no mouse clicking.

## Installation

Install it as:

    $ gem install ascii-tracker

## Usage

TODO: Write usage instructions here
 
Example: render report of lasts month activties to stdout:

  $ atracker scan ~/.timecard report last-month txt

*processing steps*

- scan

for `scan` you can use a single filename, a comma seperated list or even a
wildcard regex pattern. When using a regexp pattern you must escape it from
the shell, e.G.: ... scan "\*.txt"

- include

remove all groups which are not in the include list, e.g: .. include foo,bar ...

## Options

    --outfile=<path>    for reports written to file     <default to $stdout>
    --delimiter=.       floating point printing         <defaults to ','>

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
