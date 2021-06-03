!------------------------------------------------------------------------------
! Contributed by Vincent Magnin
! Last modifications: vmagnin 2021-05-25
! MIT license
!------------------------------------------------------------------------------

module with_or_without_GUI
  use, intrinsic :: iso_c_binding
  use, intrinsic :: iso_fortran_env, only: wp=>real128, int16

  implicit none
  ! The pixbuffers and their parameters:
  character(kind=c_char), dimension(:), pointer :: pixels1, pixels2, pixels3
  integer(kind=c_int) :: nch, rowstride
  integer(kind=c_int), parameter :: pixwidth  = 800
  integer(kind=c_int), parameter :: pixheight = 450
  ! GUI flag:
  logical :: GUI
  ! Text buffer:
  type(c_ptr) :: buffer

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
