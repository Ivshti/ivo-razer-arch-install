set term wxt title "Battery"
set term wxt size 1400,900
set datafile separator ","
set style data lines
set xdata time
set mouse mouseformat 3
set timefmt "%d/%m/%y %H:%M"
set xlabel "Time"
set ylabel "Battery Charge"
set key off
set autoscale y
plot "/dev/stdin" using (timecolumn(1, "%Y-%m-%d %H:%M:%S")):2
