# Source:
# http://lowrank.net/gnuplot/intro/plotfunc-e.html
# http://gnuplot.sourceforge.net/docs_4.2/node82.html

# Defining variables.
q = 12499.8; # 2700 As = 0.750 Ah
c = 0.0115428;
k = 0.0855179;

# Defining function.
f(x) = (k*c*q) / ( (1-exp(-k*x)) + (c*(k*x -1 + exp(-k*x))) );   # original.
# f(x) = (c*q*k) * (1+exp(-k*x/c)) - (c/exp(-k*x))/2;     # my modification.

#  Defining plot zone.
set xrange [0:750];
set yrange [0:860];
plot f(x);


# Runing into gnuplot:
# gnuplot> fit f(x) "teste16-out.dat" using 4:2 via q,c,k