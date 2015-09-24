#!/usr/bin/python
# -*- encoding: utf-8
#*****************************************************************************
#
#% BEALE computes the Beale function.
#
#  Discussion:
#
#    This function has a global minimizer:
#
#      X = ( 3.0, 0.5 )
#
#    for which
#
#      F(X) = 0.
#
#    For a relatively easy computation, start the search at
#
#      X = ( 1.0, 1.0 )
#
#    A harder computation starts at
#
#      X = ( 1.0, 4.0 )
#
#  Licensing:
#
#    This code is distributed under the GNU LGPL license.
#
#  Modified:
#
#    03 January 2011
#
#  Author:
#
#    John Burkardt
#
#  Reference:
#
#    Evelyn Beale,
#    On an Iterative Method for Finding a Local Minimum of a Function
#    of More than One Variable,
#    Technical Report 25, 
#    Statistical Techniques Research Group,
#    Princeton University, 1958.
#
#    Richard Brent,
#    Algorithms for Minimization with Derivatives,
#    Dover, 2002,
#    ISBN: 0-486-41998-3,
#    LC: QA402.5.B74.
#
#  Parameters:
#
#    Input, real X(N,2), the argument of the function.
#
#    Output, real F, the value of the function at X.
#

import time
import random

#rt = np.random.rand(1,1)[0][0]

import sys

sleepR = float(sys.argv[1])
rt = random.random()
time.sleep(rt*sleepR)

x1 = float(sys.argv[2])
x2 = float(sys.argv[3])


f1 = 1.5   - x1 * ( 1.0 - x2    );
f2 = 2.25  - x1 * ( 1.0 - x2**2 );
f3 = 2.625 - x1 * ( 1.0 - x2**3 );

f = f1**2 + f2**2 + f3**2;
print f








# the end
