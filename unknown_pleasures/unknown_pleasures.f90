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
! Last modification: vmagnin 2021-11-13
!-------------------------------------------------------------------------------

module handlers
  use, intrinsic :: iso_c_binding, only: c_ptr, c_int, c_null_char, c_funloc, &
                    & c_null_funptr, c_null_ptr, dp=>c_double

  use gtk, only: gtk_application_window_new, gtk_drawing_area_new, &
  & gtk_drawing_area_set_content_width, gtk_drawing_area_set_content_height, &
  & gtk_drawing_area_set_draw_func, gtk_window_set_child, gtk_widget_show, &
  & gtk_window_set_default_size, gtk_window_set_title, &
  & FALSE, CAIRO_ANTIALIAS_BEST

  use cairo, only: cairo_get_target, cairo_line_to, cairo_move_to, &
  & cairo_set_line_width, cairo_set_source_rgb, cairo_stroke, &
  & cairo_surface_write_to_png, cairo_rectangle, cairo_fill, &
  & cairo_set_antialias, cairo_fill_preserve

  use random

  implicit none
  ! Scale factor:
  real(dp), parameter :: factor = 1.7_dp

contains

  ! The GUI is defined here:
  subroutine activate(app, gdata) bind(c)
    type(c_ptr), value, intent(in)  :: app, gdata
    type(c_ptr)     :: window, my_drawing_area
    integer(c_int)  :: width, height

    window = gtk_application_window_new(app)
    width  = nint(625*factor)
    height = nint(593*factor)
    call gtk_window_set_default_size(window, width, height)
    call gtk_window_set_title(window, "Fortran Unknown Pleasures (GTK & Cairo)"//c_null_char)

    ! https://docs.gtk.org/gtk4/class.DrawingArea.html
    my_drawing_area = gtk_drawing_area_new()
    call gtk_drawing_area_set_content_width(my_drawing_area, width)
    call gtk_drawing_area_set_content_height(my_drawing_area, height)
    call gtk_drawing_area_set_draw_func(my_drawing_area, &
                   & c_funloc(my_draw_function), c_null_ptr, c_null_funptr)

    call gtk_window_set_child(window, my_drawing_area)
    call gtk_widget_show(window)
  end subroutine activate

  ! "It is called whenever GTK needs to draw the contents of the drawing area
  ! to the screen."
  ! cr is the Cairo context
  subroutine my_draw_function(widget, cr, width, height, gdata) bind(c)
    type(c_ptr), value, intent(in)    :: widget, cr, gdata
    integer(c_int), value, intent(in) :: width, height
    integer                           :: cstatus
    integer :: xMin, xMax, yMin, yMax
    integer :: nLines, nPoints, nModes
    integer, parameter :: nModesMax = 5
    real(dp), dimension(0:nModesMax-1) :: mus, sigmas
    real(dp) :: mx, dx, dy, x, y, w, noise, yy
    integer :: i, j, k, l
    real(dp) :: r1, r2

    ! Black background:
    call cairo_set_source_rgb(cr, 0.0_dp, 0.0_dp, 0.0_dp)
    call cairo_set_line_width(cr, 0.0_dp)
    call cairo_rectangle(cr, 0.0_dp, 0.0_dp, real(width, KIND=dp), real(height, KIND=dp))
    call cairo_fill(cr)

    ! Settings for the lines:
    call cairo_set_line_width(cr, 1.5_dp)
    call cairo_set_antialias(cr, CAIRO_ANTIALIAS_BEST)

    ! Determine x and y range
    xMin = nint(140*factor)
    xMax = width - xMin
    yMin = nint(100*factor)
    yMax = height - yMin

    ! Determine the number of lines and the number of points per line
    nLines = 80
    nPoints = 100

    mx = real(xMin + xMax, KIND=dp) / 2
    dx = real(xMax - xMin, KIND=dp) / nPoints
    dy = real(yMax - yMin, KIND=dp) / nLines

    y = yMin
    do i = 0, nLines-1
      x = xMin
      call cairo_move_to(cr, real(x, KIND=dp), real(y, KIND=dp))

      ! Generate random parameters for the line's normal distribution
      nModes = randInt(1, nModesMax)
      do j = 0, nModes-1
        mus(j) = rand(mx - 50*factor, mx + 50*factor)
        sigmas(j) = randNormal(24.0_dp, 30.0_dp)*factor
      end do

      w = y
      do k = 0, nPoints-1
        x = x + dx
        noise = 0
        do l = 0, nModes-1
          noise = noise + normalPDF(x, mus(l), sigmas(l))*factor*factor
        end do

        call random_number(r1)
        call random_number(r2)
        yy = 0.3_dp*w + 0.7_dp * (y - 600*noise + noise*r1*200 + r2*1.7_dp*factor)

        call cairo_line_to(cr, real(x, KIND=dp), real(yy, KIND=dp))
        w = yy
      end do

      ! Cover the previous lines with black:
      call cairo_set_source_rgb(cr, 0.0_dp, 0.0_dp, 0.0_dp)
      call cairo_fill_preserve(cr)
      ! Draw the current line in white:
      call cairo_set_source_rgb(cr, 1.0_dp, 1.0_dp, 1.0_dp)
      ! Display the line:
      call cairo_stroke(cr)

      ! Go to the next line:
      y = y + dy
    end do

    ! Save the image as a PNG:
    print '("Saving the PNG file: ", I0, " x ", I0, " pixels")', width, height
    cstatus = cairo_surface_write_to_png(cairo_get_target(cr), &
                    & "Fortran_unknown_pleasures.png"//c_null_char)

  end subroutine my_draw_function
end module handlers


! We create a GtkApplication:
program unknown_pleasures
  use, intrinsic :: iso_c_binding
  use handlers, only: activate
  use gtk, only: gtk_application_new, g_signal_connect, G_APPLICATION_FLAGS_NONE
  use g, only: g_application_run, g_object_unref

  implicit none
  integer(c_int) :: exit_status
  type(c_ptr)    :: app

  app = gtk_application_new("gtk-fortran.examples.unknown_pleasures"//c_null_char, &
                            & G_APPLICATION_FLAGS_NONE)
  call g_signal_connect(app, "activate"//c_null_char, c_funloc(activate), &
                      & c_null_ptr)
  exit_status = g_application_run(app, 0_c_int, [c_null_ptr])
  call g_object_unref(app)
end program
