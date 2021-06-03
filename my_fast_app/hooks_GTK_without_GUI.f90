!------------------------------------------------------------------------------
! Contributed by Vincent Magnin
! Last modifications: vmagnin 2021-05-26
! MIT license
!------------------------------------------------------------------------------

module hooks_GTK

  implicit none

contains

  subroutine hook_print_string(string)
    character(len=*), intent(in) :: string
    write(*,'(A)') trim(string)
  end subroutine

end module hooks_GTK
