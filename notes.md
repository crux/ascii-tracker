# Mon Nov 30 14:54:52 CET 2015

CSV report option implemented. 

    $ ./bin/atracker \
        --report=/tmp/h.csv scan ~/.timecard report this-month \
        --delimiter=. \
        include hoccer csv

also check the delimiter option for floating point values!

# Mon Nov 30 10:54:00 CET 2015

must start tacking notes. to many things got forgotten over time...

$ atracker --debug \
      scan timecard-*.txt,/Users/dluesebrink/.timecard \
      report 2010-04-01 2013-12-01 \
      include hertie txt >
      hertie-timecard.txt
