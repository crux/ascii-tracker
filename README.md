# ASCII Timecard tracking 

Text file based time tracking, no web app, no mouse clicking.

## Installation

Install it as:

    $ gem install ascii-tracker

## Usage

TODO: Write usage instructions here
 
Example: render report of lasts month activties to stdout:

  $ atracker scan ~/.timecard report last-month txt

for `scan` you can use a single filename, a comma seperated list or even a
wildcard regex pattern. When using a regexp pattern you must escape it from
the shell, e.G.: ... scan "\*.txt"

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
