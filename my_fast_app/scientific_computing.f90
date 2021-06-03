!------------------------------------------------------------------------------
! Contributed by Vincent Magnin
! Last modifications: vmagnin 2021-05-26
! MIT license
!------------------------------------------------------------------------------

module scientific_computing

contains

  subroutine my_computation()
    use with_or_without_GUI
    use hooks_GTK, only: hook_print_string

    implicit none
    integer        :: i
    integer(int16) :: red, green, blue     ! rgb color
    ! Parameters of the attractor:
    real(wp), parameter :: a = 10.0_wp
    real(wp), parameter :: b = 28.0_wp
    real(wp), parameter :: c = 8.0_wp / 3.0_wp
    real(wp), parameter :: dt = 0.0001_wp   ! Time step
    real(wp), parameter :: factor = 9.0_wp  ! Scale factor
    real(wp) :: x, y, z, dx, dy, dz         ! Coordinates and differentials
    character(len=200)  :: string

    ! https://en.wikipedia.org/wiki/Lorenz_system
    ! Starting point:
    x = 0.1_wp
    y = 0.1_wp
    z = 27.0_wp

    do i = 1, 1000000
      ! Lorentz attractor equations:
      dx = a * (y - x) * dt
      dy = (x * (b - z) - y) * dt
      dz = (x*y - c*z) * dt
      ! Next point:
      x = x + dx
      y = y + dy
      z = z + dz

      if (GUI) then
        red   = 255_int16 - min(nint(abs(dx)*2.5e4, kind=int16), 200_int16)
        green = 255_int16 - min(nint(abs(dy)*2.5e4, kind=int16), 200_int16)
        blue  = 255_int16 - min(nint(abs(dz)*2.5e4, kind=int16), 200_int16)

        ! We write in the pixbuffers:
        call set_pixel(pixels1, nint(pixwidth/2 + y*factor), nint(pixheight - z*factor),   red, green, blue)
        call set_pixel(pixels2, nint(pixwidth/2 + x*factor), nint(pixheight/2 - y*factor), red, green, blue)
        call set_pixel(pixels3, nint(pixwidth/2 + x*factor), nint(pixheight - z*factor),   red, green, blue)
      end if
    end do

    write(string, '("Final position: ", 3F10.6, A)') x, y, z, c_new_line//c_null_char
    call hook_print_string(TRIM(string))
  end subroutine my_computation

end module scientific_computing
