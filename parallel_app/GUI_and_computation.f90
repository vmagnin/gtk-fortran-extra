!------------------------------------------------------------------------------
! Contributed by Vincent Magnin
! Last modifications: vmagnin 2022-05-30
! MIT license
!------------------------------------------------------------------------------

module GUI_and_computation

  use gtk_sup, only: gtktextiter

  use gtk, only: gtk_init, gtk_window_new, gtk_window_destroy, &
  & g_signal_connect, gtk_window_set_child, gtk_box_append, &
  & gtk_scrolled_window_set_child, gtk_drawing_area_new, &
  & gtk_drawing_area_set_content_width, gtk_drawing_area_set_content_height, &
  & gtk_drawing_area_set_draw_func, &
  & gtk_widget_queue_draw, gtk_widget_show, &
  & gtk_window_set_default_size, gtk_window_set_title, &
  & GDK_COLORSPACE_RGB, gtk_grid_new, gtk_grid_attach, &
  & gtk_box_new, gtk_text_view_new, gtk_text_view_get_buffer, &
  & gtk_text_buffer_set_text, gtk_scrolled_window_new, &
  & gtk_text_buffer_insert_at_cursor, gtk_text_view_set_monospace, &
  & gtk_statusbar_new, gtk_label_new, &
  & gtk_statusbar_push, gtk_statusbar_get_context_id, &
  & GTK_ORIENTATION_VERTICAL, gtk_grid_set_column_homogeneous, &
  & gtk_grid_set_row_homogeneous, gtk_widget_set_vexpand, &
  & gtk_grid_set_column_spacing, gtk_grid_set_row_spacing, &
  & gtk_widget_set_halign, GTK_ALIGN_CENTER, &
  & gtk_widget_set_margin_start, gtk_widget_set_margin_end, &
  & gtk_text_buffer_get_end_iter, gtk_text_buffer_create_mark, &
  & gtk_text_buffer_insert_at_cursor, gtk_widget_queue_draw, &
  & gtk_text_iter_set_line_offset, &
  & gtk_text_buffer_move_mark, gtk_text_view_scroll_mark_onscreen, &
  & FALSE, TRUE

  use g, only: g_main_loop_new, g_main_loop_run, g_main_loop_quit, &
    & g_main_context_iteration, g_main_context_pending

  use, intrinsic :: iso_c_binding
  use, intrinsic :: iso_fortran_env, only: wp=>real64, int16, int32, int64, &
                                         & event_type

  implicit none
  type(c_ptr)    :: my_gmainloop
  type(c_ptr)    :: my_window
  type(c_ptr)    :: my_pixbuf1
  type(c_ptr)    :: scrolled_window, statusBar
  integer(c_int) :: width, height

  ! The pixbuffer and its parameters:
  character(kind=c_char), dimension(:), pointer :: pixels1
  integer(c_int) :: nch, rowstride
  integer(c_int), parameter :: pixwidth  = 800
  integer(c_int), parameter :: pixheight = 800

  type(c_ptr)    :: my_drawing_area1
  integer(c_int) :: boolresult
  type(c_ptr)    :: textView, text_mark
  ! Text buffer:
  type(c_ptr) :: buffer
  ! That type is defined in the gtk_sup module:
  type(gtktextiter), target :: text_iter

  ! run_status is TRUE until the user closes the top window:
  integer(c_int)   :: run_status = TRUE
  ! computing will be set to .true. at the beginning of the scientific computation
  ! and .false. at the end.
  logical          :: computing = .false.
  ! That event variable will be used to tell other images that the GTK window
  ! has been closed by image 1:
  type(event_type) :: stop_notification[*]

  contains

  recursive subroutine destroy_signal(widget, event, gdata) bind(c)
    type(c_ptr), value, intent(in) :: widget, event, gdata
    integer :: i, status

    if (num_images() >= 2) then
      do i = 2, num_images()
        event post(stop_notification[i], STAT=status)
        print '(A, I3, A, I3)', "Image 1 sending event post stop_notification to", i, " status=", status
      end do
    end if

    ! Some functions and subroutines need to know that it's finished:
    run_status = FALSE
    ! Makes the innermost invocation of the main loop return when it regains control:
    if (.not. computing)   call g_main_loop_quit(my_gmainloop)
  end subroutine destroy_signal


  ! This function is needed to update the GUI during long computations.
  subroutine pending_events()
    do while(IAND(g_main_context_pending(c_null_ptr), run_status) /= FALSE)
      ! FALSE for non-blocking:
      boolresult = g_main_context_iteration(c_null_ptr, FALSE)
    end do
  end subroutine


  ! Set the color of the pixel (i, j) in the 'pixels' pixbuffer:
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


  ! "It is called whenever GTK needs to draw the contents of the drawing area
  ! to the screen."
  ! https://docs.gtk.org/gtk4/method.DrawingArea.set_draw_func.html
  subroutine my_draw_function1(widget, my_cairo_context, width, height, gdata) bind(c)
    use cairo, only: cairo_paint
    use gdk, only: gdk_cairo_set_source_pixbuf

    type(c_ptr), value, intent(in)    :: widget, my_cairo_context, gdata
    integer(c_int), value, intent(in) :: width, height

    ! We redraw the pixbuf:
    call gdk_cairo_set_source_pixbuf(my_cairo_context, my_pixbuf1, 0d0, 0d0)
    call cairo_paint(my_cairo_context)
  end subroutine my_draw_function1


  ! Save a picture:
  ! https://mail.gnome.org/archives/gtk-list/2004-October/msg00186.html
  subroutine save_pixbuf(pixbuf, filename)
    use gdk_pixbuf, only: gdk_pixbuf_savev

    type(c_ptr), intent(in)      :: pixbuf
    character(len=*), intent(in) :: filename
    integer(c_int) :: cstatus
    integer(c_int) :: message_id
    character(80)  :: string
 
    cstatus = gdk_pixbuf_savev(pixbuf, filename//c_null_char, &
              & "png"//c_null_char, c_null_ptr, c_null_ptr, c_null_ptr)

    if (cstatus == TRUE) then
      string = "Successfully saved: "//filename//c_null_char
    else
      string = "Failed"//c_null_char
    end if

    message_id = gtk_statusbar_push (statusBar, gtk_statusbar_get_context_id(&
                       & statusBar, "Saved"//c_null_char), trim(string))
  end subroutine save_pixbuf


  subroutine print_text_view(string)
    character(len=*), intent(in) :: string

    call gtk_text_buffer_insert_at_cursor(buffer, trim(string)//c_new_line//c_null_char, -1_c_int)
    ! Managing the scroll:
    call gtk_text_buffer_get_end_iter (buffer, c_loc(text_iter))
    ! To avoid horizontal scrolling:
    call gtk_text_iter_set_line_offset (c_loc(text_iter), 0_c_int)
    call gtk_text_buffer_move_mark (buffer, text_mark, c_loc(text_iter))
    call gtk_text_view_scroll_mark_onscreen (textView, text_mark)
  end subroutine


  subroutine initialize_GUI
    use gdk_pixbuf, only: gdk_pixbuf_get_n_channels, gdk_pixbuf_get_pixels, &
                      & gdk_pixbuf_get_rowstride, gdk_pixbuf_new

    integer(c_int) :: message_id
    ! Pointers toward our GTK widgets:
    type(c_ptr)    :: table, box1
    type(c_ptr)    :: label1

    call gtk_init()

    ! Creates the window:
    my_window = gtk_window_new()
    call g_signal_connect(my_window, "destroy"//c_null_char, &
                        & c_funloc(destroy_signal))
    call gtk_window_set_title(my_window, "A parallel gtk-fortran application"//c_null_char)

    !******************************************************************
    ! Adding widgets in the window:
    !******************************************************************

    ! A table container will contain buttons and labels:
    table = gtk_grid_new ()
    call gtk_grid_set_column_homogeneous(table, TRUE)
    call gtk_grid_set_column_spacing(table, 5_c_int)
    call gtk_grid_set_row_spacing(table, 5_c_int)

    ! We create a vertical box container:
    box1 = gtk_box_new (GTK_ORIENTATION_VERTICAL, 10_c_int)
    call gtk_box_append(box1, table)

    ! We need a widget where to draw our pixbuf.
    ! The drawing area is contained in the vertical box:
    my_drawing_area1 = gtk_drawing_area_new()
    call gtk_drawing_area_set_content_width(my_drawing_area1, pixwidth)
    call gtk_drawing_area_set_content_height(my_drawing_area1, pixheight)
    call gtk_drawing_area_set_draw_func(my_drawing_area1, &
                     & c_funloc(my_draw_function1), c_null_ptr, c_null_funptr)
    label1 = gtk_label_new("The Buddhabrot"//c_null_char)

    call gtk_widget_set_halign(my_drawing_area1, GTK_ALIGN_CENTER)
    call gtk_grid_attach(table, label1,           0_c_int, 0_c_int, 1_c_int, 1_c_int)
    call gtk_grid_attach(table, my_drawing_area1, 0_c_int, 1_c_int, 1_c_int, 1_c_int)

    ! The lower part of the window will be used for printing text:
    textView = gtk_text_view_new ()
    call gtk_text_view_set_monospace(textView, TRUE)
    ! A 10 pixels margin at the left and right of the widget:
    call gtk_widget_set_margin_start(textView, 10_c_int)
    call gtk_widget_set_margin_end  (textView, 10_c_int)

    buffer = gtk_text_view_get_buffer (textView)
    call gtk_text_buffer_set_text (buffer, "The Buddhabrot"//c_new_line// &
        & "Waiting for the ghost..."//c_new_line// &
        & "https://en.wikipedia.org/wiki/Buddhabrot"//c_new_line//c_null_char,&
        & -1_c_int)
    ! We need a GtkTextIter iterator and a GtkTextMark to manage scrolling:
    call gtk_text_buffer_get_end_iter (buffer, c_loc(text_iter))
    ! TRUE is for left gravity:
    text_mark = gtk_text_buffer_create_mark (buffer, "scroll", c_loc(text_iter), TRUE)
    scrolled_window = gtk_scrolled_window_new()
    call gtk_scrolled_window_set_child(scrolled_window, textView)
    call gtk_grid_attach(table, scrolled_window, 1_c_int, 1_c_int, 1_c_int, 1_c_int)

    call gtk_widget_set_vexpand (scrolled_window, TRUE)
    call gtk_widget_set_vexpand (box1, TRUE)

    ! The window status bar can be used to print messages:
    statusBar = gtk_statusbar_new ()
    message_id = gtk_statusbar_push (statusBar, gtk_statusbar_get_context_id(statusBar, &
                & "Start"//c_null_char), "Computing..."//c_null_char)
    call gtk_box_append(box1, statusBar)

    ! Let's finalize the GUI:
    call gtk_window_set_child(my_window, box1)
    call gtk_widget_show(my_window)

    ! We create a pixbuffer to store the pixels of the image:
    my_pixbuf1 = gdk_pixbuf_new(GDK_COLORSPACE_RGB, FALSE, 8_c_int, pixwidth, pixheight)
    nch = gdk_pixbuf_get_n_channels(my_pixbuf1)
    rowstride = gdk_pixbuf_get_rowstride(my_pixbuf1)
    call c_f_pointer(gdk_pixbuf_get_pixels(my_pixbuf1), pixels1, (/pixwidth*pixheight*nch/))
    ! We use char() for "pixels1" because we need unsigned integers.
    ! This pixbuffer has no Alpha channel (15% faster), only RGB.
    pixels1 = char(0)   ! Black background

    ! If you don't show it, nothing will appear on screen...
    call gtk_widget_show(my_window)

  end subroutine initialize_GUI


  subroutine my_computation()
    character(len=200) :: s       ! String for text printing
    integer(int16) :: grey        ! Intensity of a pixel
    integer(int64) :: i, max_iter ! Main loop
    integer(int32) :: k           ! Loop counter for the Mandelbrot sequence
    integer(int32), parameter :: iterations = 200   ! Maximum iterations
    real(wp)       :: rx, ry      ! Random numbers
    complex(wp)    :: c           ! First term of the Mandelbrot sequence
    complex(wp), dimension(0:iterations) :: z     ! To memorize the sequence
    ! Arrays to count the number of visits of the sequence in each pixel:
    integer(int32), dimension(0:pixwidth-1, 0:pixheight-1) :: p, backup
    integer(int32) :: ii, jj      ! Pixbuffer coordinates
    integer        :: counter     ! Event counter

    ! It's time for Science!
    computing = .true.

    p = 0
    max_iter = 800000000 / num_images()

    computation: do i = 1, max_iter
      ! A random point c in the complex plane:
      call random_number(rx)
      call random_number(ry)
      c = cmplx(-2.0_wp + 3.0_wp * rx, -1.5_wp + 3.0_wp * ry, kind=wp)

      ! Iterations of the Mandelbrot mathematical sequence:
      z(0) = (0.0_wp, 0.0_wp)    ! First term z0
      do k = 1, iterations
        z(k) = z(k-1)**2 + c
      end do

      ! The intensity of a pixel is proportionnal to the number of times this
      ! pixel was visited. We consider only sequences where c is not in the
      ! Mandelbrot set:
      if (real(z(iterations))**2 + aimag(z(iterations))**2 >= 4.0_wp) then
        do k = 2, iterations
          ii = nint((real(z(k))  + 2.0_wp) / (3.0_wp / pixwidth))
          if ((ii >= 0) .and. (ii < pixwidth)) then
            jj = nint((aimag(z(k)) + 1.5_wp) / (3.0_wp / pixheight))
            if ((jj >= 0) .and. (jj < pixheight)) then
              ! This pixel has been visited by z:
              p(ii,jj) = p(ii,jj) + 1
            end if
          end if
        end do
      end if

      ! **************************************************************************
      ! Displays progressively the result during computation. Using mod()
      ! we provoke a draw event only once in a while to avoid degrading
      ! the performances. We don't use cpu_time() for the same reason.
      ! **************************************************************************
      if (mod(i, 10*int(pixwidth*pixheight, kind=int64)) == 0) then

        ! Does image 1 closed the GTK window?
        call event_query(stop_notification, counter)
        print '(A, I3, A, I3)', "I am image", this_image(), " ; event counter", counter
        if (counter /=0) return

        if (this_image() == 1) then
          ! That backup is needed because all p arrays will be summed in the
          ! p array of image 1, but it is just an intermediate result
          backup = p(:,:)
        end if

        ! Like in astrophotography, we sum the pictures computed by each
        ! Fortran image to obtain a detailed picture of the Buddhabrot:
        print '(A, I3, A)', "I am image", this_image(), " doing co_sum(p, 1)"
        call co_sum(p, 1)

        ! Let's display it in the GTK window:
        if (this_image() == 1) then
          do ii = 0, pixwidth-1
            do jj = pixheight-1, 0, -1
              grey = int(min(p(ii,jj), 255), kind=int16)
              ! We write in the pixbuffers:
              call set_pixel(pixels1, jj, ii, grey, grey, grey)
            end do
          end do
          call gtk_widget_queue_draw(my_drawing_area1)
          ! Preparing image 1 for the next co_sum():
          p(:,:) = backup
        end if
      end if

      ! You also need, more often, to manage the GTK events during computation if you
      ! want the GUI to be reactive to user actions (like closing the window):
      if ((this_image() == 1) .and. (mod(i, int(pixwidth*pixheight, kind=int64)) == 0)) then
        call pending_events()
        if (run_status == FALSE) return ! Exit if we had a destroy signal.
      end if

      if ((this_image() == 1) .and. (mod(i, max_iter/100) == 0)) then
        write(s, '(i3, "%")') i / (max_iter/100)
        call print_text_view(s)
      end if
    end do computation

    computing = .false.
  end subroutine my_computation

end module GUI_and_computation
