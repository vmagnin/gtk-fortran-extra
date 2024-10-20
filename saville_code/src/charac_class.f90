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
! Contributed by Vincent Magnin: 2023-04-02
! Last modification: vmagnin 2024-10-20
!-------------------------------------------------------------------------------

module charac_class
    use glyph_class
    use, intrinsic :: iso_c_binding, only: c_ptr, dp=>c_double
    use cairo, only: cairo_line_to, cairo_move_to, cairo_close_path, &
      & cairo_set_source_rgb, cairo_stroke, cairo_rectangle, cairo_fill

    implicit none

    ! A character is a glyph printed somewhere in a Cairo context:
    type, extends(Glyph) :: Charac
        real(dp)    :: x, y
        real(dp)    :: width
        type(c_ptr) :: cr       ! Cairo context
    contains
        procedure :: draw
        ! Overrides the Glyph print():
        procedure :: print=>print_charac
    end type Charac

contains

    subroutine draw(self)
        class(Charac), intent(inout) :: self
        real(dp) :: seph  ! Separator height
        real(dp) :: a

        ! Let set the glyph:
        call self%set(self%name)

        ! Color of the first half of the square or the octagon:
        call cairo_set_source_rgb(self%cr, self%left%RGB(1), &
                                           self%left%RGB(2), &
                                           self%left%RGB(3))

        if (self%name /= " ") then
            ! Drawing the first half:
            call cairo_rectangle(self%cr, self%x, self%y, self%width/2, self%width)
            call cairo_fill(self%cr)
            call cairo_stroke(self%cr)

            ! Color of the second half of the square:
            call cairo_set_source_rgb(self%cr, self%right%RGB(1), &
                                               self%right%RGB(2), &
                                               self%right%RGB(3))
            call cairo_rectangle(self%cr, self%x+self%width/2, self%y, self%width/2, self%width)
            call cairo_fill(self%cr)
            call cairo_stroke(self%cr)

            ! A thin white separator for two colors glyphs:
            if (self%separator) then
                seph =  self%width / 20._dp
                call cairo_set_source_rgb(self%cr, 1._dp, 1._dp, 1._dp)
                call cairo_rectangle(self%cr, self%x+self%width/2 - seph/2, self%y, seph, self%width)
                call cairo_fill(self%cr)
                call cairo_stroke(self%cr)
            end if
        else
            ! A space is represented by a grey octagon:
            a = self%width

            ! We use the fact that the vertices of an octagon can be obtained
            ! by reporting on the square sides the half-diagonals with a compass:
            ! Vertices on the top:
            call cairo_move_to(self%cr, self%x + a*(1._dp - 1._dp/sqrt(2._dp)), self%y)
            call cairo_line_to(self%cr, self%x + a/sqrt(2._dp), self%y)
            ! Vertices on the right:
            call cairo_line_to(self%cr, self%x + self%width, self%y + a*(1._dp - 1._dp/sqrt(2._dp)))
            call cairo_line_to(self%cr, self%x + self%width, self%y + a/sqrt(2._dp))
            ! Vertices on the bottom:
            call cairo_line_to(self%cr, self%x + a/sqrt(2._dp), self%y + self%width)
            call cairo_line_to(self%cr, self%x + a*(1._dp - 1._dp/sqrt(2._dp)), self%y + self%width)
            ! Vertices on the left:
            call cairo_line_to(self%cr, self%x, self%y + a/sqrt(2._dp))
            call cairo_line_to(self%cr, self%x, self%y + a*(1._dp - 1._dp/sqrt(2._dp)))

            call cairo_close_path(self%cr);
            call cairo_fill(self%cr)
            call cairo_stroke(self%cr)
        end if
    end subroutine

    ! Useful for testing and debugging:
    subroutine print_charac(self)
        class(Charac), intent(inout) :: self

        print *, "------ Charac -----"
        print *, self%name, self%x, self%y, self%width
        print *, "---------------------"
    end subroutine

end module charac_class
