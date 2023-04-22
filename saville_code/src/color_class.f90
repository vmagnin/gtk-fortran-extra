! The MIT License (MIT)
!
! Copyright (c) 2023 Vincent Magnin
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
! Contributed by Vincent Magnin: 2023-03-26
! Last modification: vmagnin 2023-04-21
!-------------------------------------------------------------------------------


module color_class
    use, intrinsic :: iso_c_binding, only: dp=>c_double

    implicit none

    type :: Color
        ! Range [0, 1]:
        real(dp) :: CMYK(4) = [0_dp, 0_dp, 0_dp, 0_dp]
        ! Range [0, 1] in Cairo:
        real(dp) :: RGB(3)  = [0_dp, 0_dp, 0_dp]
    contains
        procedure :: convert_RGB_to_CMYK
        procedure :: convert_CMYK_to_RGB
        procedure :: print
    end type Color

contains

    ! https://www.rapidtables.com/convert/color/rgb-to-cmyk.html
    subroutine convert_RGB_to_CMYK(self)
        class(Color), intent(inout) :: self
        real(dp) :: K

        associate(Rp => self%RGB(1), Gp => self%RGB(2), Bp => self%RGB(3))
            K = 1_dp - max(Rp, Gp, Bp)

            self%CMYK(1) = (1_dp - Rp - K) / (1_dp - K)
            self%CMYK(2) = (1_dp - Gp - K) / (1_dp - K)
            self%CMYK(3) = (1_dp - Bp - K) / (1_dp - K)
            self%CMYK(4) = K
        end associate
    end subroutine convert_RGB_to_CMYK

    ! https://www.rapidtables.com/convert/color/cmyk-to-rgb.html
    subroutine convert_CMYK_to_RGB(self)
        class(Color), intent(inout) :: self

        associate(C => self%CMYK(1), M => self%CMYK(2), Y => self%CMYK(3), &
                & K => self%CMYK(4))
            self%RGB(1) = (1_dp - C) * (1_dp - K)
            self%RGB(2) = (1_dp - M) * (1_dp - K)
            self%RGB(3) = (1_dp - Y) * (1_dp - K)
        end associate
    end subroutine convert_CMYK_to_RGB

    ! Useful for testing and debugging:
    subroutine print(self)
        class(Color), intent(inout) :: self

        print *, "------ Color -----"
        print *, "RGB:",  self%RGB
        print *, "CMYK:", self%CMYK
        print *, "------------------"
    end subroutine

end module color_class
