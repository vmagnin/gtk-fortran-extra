! The MIT License (MIT)
!
! Copyright (c) 2016 Max Halford (original Javascript version)
! Copyright (c) 2021 Vincent Magnin (Fortran version)
!
! Permission is hereby granted, free of charge, to any person obtaining a copy
! of this software and associated documentation files (the "Software"), to deal
! in the Software without restriction, including without limitation the rights
! to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
! copies of the Software, and to permit persons to whom the Software is
! furnished to do so, subject to the following conditions:
!
! The above copyright notice and this permission notice shall be included in all
! copies or substantial portions of the Software.
!
! THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
! IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
! FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
! AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
! LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
! OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
! SOFTWARE.
!-------------------------------------------------------------------------------
! Fortran version contributed by Vincent Magnin: 2021-11-02
! Last modification: vmagnin 2021-11-04
!-------------------------------------------------------------------------------

module random
  use, intrinsic :: iso_c_binding, only: dp=>c_double

  implicit none
  real(dp), parameter :: PI = 3.14159265358979323846_dp

contains

  ! Returns a pseudorandom real number rmin <= rand < rmax
  real(dp) function rand(rmin, rmax)
    real(dp), intent(in) :: rmin, rmax
    real(dp) :: r

    call random_number(r)
    rand = rmin + r * (rmax - rmin)
  end function

  ! Returns a pseudorandom integer number rmin <= randInt <= rmax
  integer function randInt(rmin, rmax)
    integer, intent(in) :: rmin, rmax
    real(dp) :: r

    call random_number(r)
    randInt = rmin + floor(r * (rmax - rmin + 1))
  end function


  real(dp) function randNormal(mu, sigma)
    real(dp), intent(in) :: mu, sigma
    real(dp) :: s
    integer :: i
    integer, parameter :: imax = 6

    s = 0.0_dp
    do i = 0, imax
      s = s + rand(-1.0_dp, +1.0_dp)
    end do

    randNormal = mu + sigma * s / imax
  end function

  ! Normal Probability Distribution Function
  real(dp) function normalPDF (x, mu, sigma)
    real(dp), intent(in) :: x, mu, sigma

    normalPDF = exp(-(x - mu)**2 / (2 * sigma**2)) / sqrt(2 * PI * sigma**2)
  end function

end module random
