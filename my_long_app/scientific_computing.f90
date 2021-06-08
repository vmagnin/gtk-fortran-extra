!------------------------------------------------------------------------------
! Contributed by Vincent Magnin
! Last modifications: vmagnin 2021-06-08
! MIT license
! https://en.wikipedia.org/wiki/Buddhabrot
!------------------------------------------------------------------------------

module scientific_computing
  use with_or_without_GUI
  use iso_fortran_env, only: int32, int64
  use hooks_GTK, only: hook_print_string, hook_gtk_widget_queue_draw, &
                       & hook_pending_events
  implicit none

contains

  subroutine my_computation()
    character(len=200) :: s       ! String for text printing
    integer(int16) :: grey        ! Intensity of a pixel
    integer(int64) :: i, max_iter ! Main loop
    integer(int32) :: k           ! Loop counter for the sequence
    integer(int32), parameter :: iterations = 200
    integer        :: u           ! File unit
    real(wp)       :: rx, ry      ! Random numbers
    complex(wp)    :: c
    complex(wp), dimension(0:iterations) :: z
    integer(int32), dimension(0:pixwidth-1, 0:pixheight-1) :: p
    integer(int32) :: ii, jj  ! Pixbuffer coordinates

    computing = .true.

    p = 0
    max_iter = 400000000

    do i = 1, max_iter
      ! A random point c in the plane:
      call random_number(rx)
      call random_number(ry)
      c = cmplx(-2.0_wp + 3.0_wp * rx, -1.5_wp + 3.0_wp * ry, kind=wp)

      ! Iterations of the Mandelbrot mathematical sequence:
      z(0) = (0.0_wp, 0.0_wp)    ! First term z0
      do k = 1, iterations
        z(k) = z(k-1)**2 + c
      end do

      ! The intensity of a pixel is proportionnal to the number of times this
      ! pixel was visited:
      if (abs(z(iterations)) >= 2.0_wp) then
        do k = 2, iterations
          ii = nint((real(z(k))  + 2.0_wp) / (3.0_wp / pixwidth))
          if ((ii >= 0).and.(ii < pixwidth)) then
            jj = nint((aimag(z(k)) + 1.5_wp) / (3.0_wp / pixheight))

            if ((jj >= 0).and.(jj < pixheight)) then
              p(ii,jj) = p(ii,jj) + 1
            end if
          end if
        end do
      end if

      if (GUI) then
        ! **************************************************************************
        ! Needed if you want to display progressively the result during computation.
        ! We provoke a draw event only once in a while to avoid degrading
        ! the performances. We don't use cpu_time() for the same reason.
        ! **************************************************************************
        if (mod(i, 10*int(pixwidth*pixheight, kind=int64)) == 0) then
          do ii = 0, pixwidth-1
            do jj = pixheight-1, 0, -1
              grey = int(min(p(ii,jj), 255), kind=int16)
              ! We write in the pixbuffers:
              call set_pixel(pixels1, jj, ii, grey, grey, grey)
            end do
          end do
          call hook_gtk_widget_queue_draw()
        end if

        ! You also need, more often, to manage the GTK events during computation if you
        ! want the GUI to be reactive:        
        if (mod(i, int(pixwidth*pixheight, kind=int64)) == 0) then
          call hook_pending_events()
          if (run_status == FALSE) return ! Exit if we had a destroy signal.
        end if
      end if

      if (mod(i, max_iter/100) == 0) then
        write(s, '(i3, "%")') i / (max_iter/100)
        call hook_print_string(s)
      end if
    end do

    call hook_print_string("Saving an image in 'buddhabrot.ppm'")
    ! Saves an image in PPM format.
    ! Based on Ondrej Certik's code (MIT license):
    ! https://github.com/certik/fortran-utils/blob/master/src/ppm.f90
    open(newunit=u, file="buddhabrot.ppm", status="replace")
    write(u, '(a2)') "P6"
    write(u, '(i0," ",i0)') pixwidth, pixheight
    write(u, '(i0)') 255
    do ii = 0, pixwidth-1
      do jj = pixheight-1, 0, -1
        grey = int(min(p(ii,jj), 255), kind=int16)
        write(u, '(3a1)', advance='no') achar(grey), achar(grey), achar(grey)
      end do
    end do
    close(u)

    computing = .false.
  end subroutine my_computation

end module scientific_computing
