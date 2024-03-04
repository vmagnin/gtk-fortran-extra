!------------------------------------------------------------------------------
! Turing patterns: Reaction Diffusion, Gray-Scott Algorithm
! Vincent MAGNIN
! MIT license
! C version: 28-06-2022
! Translated in Fortran: 2024-02-27, modified 2024-03-04
! Command for creating a movie with FFmpeg:
!    ffmpeg -i image%05d.png -y -r 24 -crf 17 turing.mp4
!------------------------------------------------------------------------------

module scientific_computing
    use common_module

    implicit none
    ! Image size:
    integer, parameter :: W = pixwidth
    integer, parameter :: H = pixheight
    ! Chemical compounds A and B (current state and t+1 state):
    real(wp), dimension(0:W+1, 0:H+1) :: A, B, Ap, Bp

contains

    subroutine add_random_pixels_in_B(p)
        real(wp), intent(in) :: p     ! Probability
        real(wp) :: r
        integer  :: i, j

        do j = 1, H
           do i = 1, W
               call random_number(r)
               if (r < p) B(i, j) = 1.0_wp
           end do
        end do
    end subroutine


    subroutine my_computation()
        use forcolormap, only: Colormap, fcm=>wp

        integer  :: i, j, t
        ! The colormap will be changed periodically:
        integer, parameter :: change_map = 1000
        ! Image number (FFmpeg needs consecutive values):
        integer :: pic
        character(len=14) :: filename = "image00000.png"
        character(len=80) :: string
        ! To use with the ForColormap library:
        integer :: red, green, blue
        type(Colormap) :: cmap

        real(wp) :: laplacianA, laplacianB
        ! Model parameters:
        real(wp), parameter :: DA = 1.0_wp
        real(wp), parameter :: DB = 0.5_wp
        real(wp), parameter :: dt = 1.0_wp
        real(wp) :: f
        real(wp) :: k

        f = 0.051_wp ; k = 0.061_wp

        ! Initializing the A and B arrays:
        A = 1.0_wp
        B = 0.0_wp
        ! with a central square in B:
        B(W/2-39:W/2+39, H/2-39:H/2+39) = 1.0_wp

        computing = .true.
        pic = 0

        ! Interesting colormaps:
        ! lajolla lipari oslo black_body rainbow plasma
        ! roma lisbon vik
        ! romaO
        ! oleron
        ! lajollaS

        ! Time loop :
        do t = 0, 12000
            ! We change regularly the colormap and sometimes modify
            ! the parameter of the physical model to add some diversity
            ! in the movie:
            select case(t)
                case(0)
                    call cmap%set("roma", 0.0_fcm, 1.0_fcm, 256)
                case(1*change_map)
                    call cmap%set("plasma", 0.0_fcm, 1.0_fcm, 256)
                case(2*change_map)
                    call add_random_pixels_in_B(0.002_wp)
                    call cmap%set("romaO", 0.0_fcm, 1.0_fcm, 256)
                case(3*change_map)
                    f = 0.055_wp ; k = 0.062_wp
                    call cmap%set("oleron", 0.0_fcm, 1.0_fcm, 256)
                case(4*change_map)
                    f = 0.056_wp ; k = 0.063_wp
                    call cmap%set("lajolla", 0.0_fcm, 1.0_fcm, 256)
                case(5*change_map)
                    f = 0.057_wp ; k = 0.064_wp
                    call cmap%set("lipari", 0.0_fcm, 1.0_fcm, 256)
                case(6*change_map)
                    f = 0.058_wp ; k = 0.065_wp
                    call cmap%set("vik", 0.0_fcm, 1.0_fcm, 256)
                case(7*change_map)
                    f = 0.059_wp ; k = 0.066_wp
                    call cmap%set("oslo", 0.0_fcm, 1.0_fcm, 256)
                case(8*change_map)
                    f = 0.060_wp ; k = 0.067_wp
                    call cmap%set("black_body", 0.0_fcm, 1.0_fcm, 256)
                case(9*change_map)
                    f = 0.061_wp ; k = 0.068_wp
                    call cmap%set("lisbon", 0.0_fcm, 1.0_fcm, 256)
                case(10*change_map)
                    f = 0.062_wp ; k = 0.069_wp
                    call cmap%set("rainbow", 0.0_fcm, 1.0_fcm, 256)
            end select

            ! Periodical boundary conditions:
            ! Left and right edges preparation
            A(0,   0:H+1) = A(W, 0:H+1)
            A(W+1, 0:H+1) = A(1, 0:H+1)
            B(0,   0:H+1) = B(W, 0:H+1)
            B(W+1, 0:H+1) = B(1, 0:H+1)

            ! Top and Bottom edges preparation
            A(0:W, 0)   = A(0:W, H)
            A(0:W, H+1) = A(0:W, 1)
            B(0:W, 0)   = B(0:W, H)
            B(0:W, H+1) = B(0:W, 1)

            ! The four corners:
            A(0,     0) = A(W, H)
            A(W+1,   0) = A(1, H)
            A(W+1, H+1) = A(1, 1)
            A(0,   H+1) = A(W, 1)
            B(0,     0) = B(W, H)
            B(W+1,   0) = B(1, H)
            B(W+1, H+1) = B(1, 1)
            B(0,   H+1) = B(W, 1)

            ! Scanning tables A and B to calculate the new concentrations in Ap and Bp:
            do concurrent (j=1:H, i=1:W)
                laplacianA = -A(i, j) + 0.20_wp*(A(i-1, j)   + A(i+1, j)   + A(i, j-1)   + A(i, j+1)) &
                                    & + 0.05_wp*(A(i-1, j-1) + A(i-1, j+1) + A(i+1, j-1) + A(i+1, j+1))
                Ap(i, j) = A(i, j) + (DA * laplacianA - A(i, j)*B(i, j)*B(i, j) + f*(1.0_wp - A(i, j))) * dt

                laplacianB = -B(i, j) + 0.20_wp*(B(i-1, j)   + B(i+1, j)   + B(i, j-1)   + B(i, j+1)) &
                                    & + 0.05_wp*(B(i-1, j-1) + B(i-1, j+1) + B(i+1, j-1) + B(i+1, j+1))
                Bp(i, j) = B(i, j) + (DB * laplacianB + A(i, j)*B(i, j)*B(i, j) - (k + f)*B(i, j)) * dt
            end do

            ! Updating A & B arrays from Ap and Bp:
            A(1:W , 1:H) = Ap(1:W , 1:H)
            B(1:W , 1:H) = Bp(1:W , 1:H)

            ! Graphical display:
            if (mod(t, 10) == 0) then
                do j = 1, H
                    do i = 1, W
                        ! Using ForColormap:
                        call cmap%compute_RGB(A(i,j), red, green, blue)
                        ! Remark: the image coordinates start at x=0 and y=0
                        call set_pixel(pixels1, i-1, j-1, int(red,  kind=int16), &
                                & int(green, kind=int16), int(blue, kind=int16))
                    end do
                end do

                write(string, '("t=",I7)') t
                call print_string(string)

                ! Updating the graphical display:
                call gtk_widget_queue_draw(my_drawing_area1)

                write(filename, '("image", I5.5, ".png")') pic
                call save_pixbuf(my_pixbuf1, trim(filename))
                pic = pic + 1

                ! Manage the GTK events during computation to have a reactive GUI:
                call pending_events()
                if (run_status == FALSE) return ! Exit if we had a destroy signal.
            end if
        end do

        computing = .false.
    end subroutine my_computation

  ! Save a picture:
  ! https://docs.gtk.org/gdk-pixbuf/method.Pixbuf.save.html
  ! https://mail.gnome.org/archives/gtk-list/2004-October/msg00186.html
  subroutine save_pixbuf(pixbuf, filename)
        use gtk_os_dependent, only: gdk_pixbuf_savev

        type(c_ptr), intent(in)      :: pixbuf
        character(len=*), intent(in) :: filename
        integer(c_int) :: cstatus
        character(80)  :: string

        cstatus = gdk_pixbuf_savev(pixbuf, filename//c_null_char, &
                & "png"//c_null_char, c_null_ptr, c_null_ptr, c_null_ptr)

        if (cstatus == TRUE) then
            string = "Successfully saved: "//filename
        else
            string = "Failed"
        end if
        call print_string(string)
  end subroutine save_pixbuf

end module scientific_computing
