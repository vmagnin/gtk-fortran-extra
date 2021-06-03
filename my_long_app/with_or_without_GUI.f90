!------------------------------------------------------------------------------
! Contributed by Vincent Magnin
! Last modifications: vmagnin 2021-05-25
! MIT license
!------------------------------------------------------------------------------

module with_or_without_GUI
  use, intrinsic :: iso_c_binding
  use, intrinsic :: iso_fortran_env, only: wp=>real64, int16

  implicit none
  ! The pixbuffer and its parameters:
  character(kind=c_char), dimension(:), pointer :: pixels1
  integer(c_int) :: nch, rowstride
  integer(c_int), parameter :: pixwidth  = 600
  integer(c_int), parameter :: pixheight = 600
  ! Also defined in gtk-fortran, but we also need them without GUI:
  integer(c_int), parameter :: FALSE = 0
  integer(c_int), parameter :: TRUE = 1
  ! GUI flag:
  logical :: GUI
  ! Text buffer:
  type(c_ptr) :: buffer
  ! run_status is TRUE until the user closes the top window:
  integer(c_int) :: run_status = TRUE
  logical        :: computing = .false.

  contains

  ! Set the color of the pixel (i, j) in the pixels pixbuffer:
  subroutine set_pixel(pixels, i, j, red, green, blue)
    character(kind=c_char), dimension(:), pointer, intent(inout) :: pixels
    integer, intent(in)        :: i, j
    integer(int16), intent(in) :: red, green, blue     ! rgb color
    integer :: p

    ! We write in the pixbuffer:
    p = i * nch + j * rowstride + 1
    if ((p >= 1).and.(p <= size(pixels))) then
      pixels(p)   = char(red)
      pixels(p+1) = char(green)
      pixels(p+2) = char(blue)
    end if
  end subroutine

end module with_or_without_GUI
