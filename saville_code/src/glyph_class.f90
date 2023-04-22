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

module glyph_class
    use color_class, only: Color

    implicit none

    type :: Glyph
        character   :: name
        type(Color) :: left
        type(Color) :: right
        logical     :: separator = .false.
    contains
        procedure :: set
        procedure :: print
    end type Glyph

contains

    subroutine set(self, charac)
        class(Glyph), intent(inout) :: self
        character, intent(in) :: charac
        character :: upper_char

        ! Uppercase conversion:
        select case(charac)
        case("a":"z")
            upper_char = achar(iachar(charac) - (iachar("a") - iachar("A")))
        case default
            upper_char = charac
        end select

        self%name = upper_char

        select case(upper_char)
        case('0')
            self%left = Color(CMYK=[0.0, 0.0, 0.0, 0.0])
            self%right    = Color(CMYK=[0.0, 0.0, 0.0, 0.0])
            self%separator = .false.
        case(' ')
            ! Pantone 538C: #D2D7E4 (R:210 G:215 B:228)
            self%left = Color(CMYK=[0.07895, 0.05702, 0.0, 0.1056])
            self%right = self%left
            self%separator = .false.
        case('A', '1')
            self%left = Color(CMYK=[0.7, 0.0, 0.4, 0.0])
            self%right = self%left
            self%separator = .false.
        case('B', '2')
            self%left = Color(CMYK=[0.0, 0.0, 1.0, 0.0])
            self%right = self%left
            self%separator = .false.
        case('C', '3')
            self%left = Color(CMYK=[0.5, 0.5, 0.0, 0.0])
            self%right = self%left
            self%separator = .false.
        case('D', '4')
            self%left = Color(CMYK=[0.0, 0.6, 1.0, 0.0])
            self%right = self%left
            self%separator = .false.
        case('E', '5')
            self%left = Color(CMYK=[0.4, 0.0, 0.0, 0.0])
            self%right = self%left
            self%separator = .false.
        case('F', '6')
            self%left = Color(CMYK=[0.0, 0.4, 0.0, 0.0])
            self%right = self%left
            self%separator = .false.
        case('G', '7')
            self%left = Color(CMYK=[0.8, 0.9, 0.0, 0.0])
            self%right = self%left
            self%separator = .false.
        case('H', '8')
            self%left = Color(CMYK=[0.0, 1.0, 0.0, 0.0])
            self%right = self%left
            self%separator = .false.
        case('I', '9')
            self%left = Color(CMYK=[1.0, 0.0, 0.0, 0.0])
            self%right = self%left
            self%separator = .false.
        case('J')
            self%left = Color(CMYK=[0.7, 0.0, 0.4, 0.0])
            self%right    = Color(CMYK=[0.0, 0.0, 0.0, 0.0])
            self%separator = .true.
        case('K')
            self%left = Color(CMYK=[0.7, 0.0, 0.4, 0.0])
            self%right    = Color(CMYK=[0.7, 0.0, 0.4, 0.0])
            self%separator = .true.
        case('L')
            self%left = Color(CMYK=[0.7, 0.0, 0.4, 0.0])
            self%right    = Color(CMYK=[0.0, 0.0, 1.0, 0.0])
            self%separator = .true.
        case('M')
            self%left = Color(CMYK=[0.7, 0.0, 0.4, 0.0])
            self%right    = Color(CMYK=[0.5, 0.5, 0.0, 0.0])
            self%separator = .true.
        case('N')
            self%left = Color(CMYK=[0.7, 0.0, 0.4, 0.0])
            self%right    = Color(CMYK=[0.0, 0.6, 1.0, 0.0])
            self%separator = .true.
        case('O')
            self%left = Color(CMYK=[0.7, 0.0, 0.4, 0.0])
            self%right    = Color(CMYK=[0.4, 0.0, 0.0, 0.0])
            self%separator = .true.
        case('P')
            self%left = Color(CMYK=[0.7, 0.0, 0.4, 0.0])
            self%right    = Color(CMYK=[0.0, 0.4, 0.0, 0.0])
            self%separator = .true.
        case('Q')
            self%left = Color(CMYK=[0.7, 0.0, 0.4, 0.0])
            self%right    = Color(CMYK=[0.5, 0.9, 0.0, 0.0])
            self%separator = .true.
        case('R')
            self%left = Color(CMYK=[0.7, 0.0, 0.4, 0.0])
            self%right    = Color(CMYK=[0.0, 1.0, 0.0, 0.0])
            self%separator = .true.
        case('S')
            self%left = Color(CMYK=[0.7, 0.0, 0.4, 0.0])
            self%right    = Color(CMYK=[1.0, 0.0, 0.0, 0.0])
            self%separator = .true.
        case('T')
            self%left = Color(CMYK=[0.0, 0.0, 1.0, 0.0])
            self%right    = Color(CMYK=[0.0, 0.0, 0.0, 0.0])
            self%separator = .true.
        case('U')
            self%left = Color(CMYK=[0.0, 0.0, 1.0, 0.0])
            self%right    = Color(CMYK=[0.7, 0.0, 0.4, 0.0])
            self%separator = .true.
        case('V')
            self%left = Color(CMYK=[0.0, 0.0, 1.0, 0.0])
            self%right    = Color(CMYK=[0.0, 0.0, 1.0, 0.0])
            self%separator = .true.
        case('W')
            self%left = Color(CMYK=[0.0, 0.0, 1.0, 0.0])
            self%right    = Color(CMYK=[0.5, 0.5, 0.0, 0.0])
            self%separator = .true.
        case('X')
            self%left = Color(CMYK=[0.0, 0.0, 1.0, 0.0])
            self%right    = Color(CMYK=[0.0, 0.6, 1.0, 0.0])
            self%separator = .true.
        case('Y')
            self%left = Color(CMYK=[0.0, 0.0, 1.0, 0.0])
            self%right    = Color(CMYK=[0.4, 0.0, 0.0, 0.0])
            self%separator = .true.
        case('Z')
            self%left = Color(CMYK=[0.0, 0.0, 1.0, 0.0])
            self%right    = Color(CMYK=[0.0, 0.4, 0.0, 0.0])
            self%separator = .true.
        end select

        ! Saville's code was defined for printing (CMYK), but to draw
        ! on screen with Cairo, we need RGB values instead:
        call self%left%convert_CMYK_to_RGB()
        call self%right%convert_CMYK_to_RGB()
    end subroutine

    ! Useful for testing and debugging:
    subroutine print(self)
        class(Glyph), intent(inout) :: self

        print *, "------ Glyph -----"
        print *, self%name
        call self%left%print()
        call self%right%print()
        print *, self%separator
        print *, "------------------"
    end subroutine

end module glyph_class
