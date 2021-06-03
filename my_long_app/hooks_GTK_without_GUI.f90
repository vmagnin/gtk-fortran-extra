!------------------------------------------------------------------------------
! Contributed by Vincent Magnin
! Last modifications: vmagnin 2021-05-27
! MIT license
!------------------------------------------------------------------------------

module hooks_GTK

  implicit none

contains

  subroutine hook_print_string(string)
    character(len=*), intent(in) :: string
    write(*,'(A)') trim(string)
  end subroutine

  subroutine hook_gtk_widget_queue_draw
    ! Do nothing
  end subroutine

  subroutine hook_pending_events()
    ! Do nothing
  end subroutine

end module hooks_GTK
