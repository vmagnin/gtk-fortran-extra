!------------------------------------------------------------------------------
! Contributed by Vincent Magnin, 2024-02-28
! Last modifications: vmagnin 2024-03-04
!------------------------------------------------------------------------------

module GUI_module
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
  & gtk_text_buffer_get_end_iter, gtk_text_buffer_create_mark

  use g, only: g_main_loop_new, g_main_loop_run, g_main_loop_quit

  use common_module

  implicit none
  type(c_ptr)    :: my_gmainloop
  type(c_ptr)    :: my_window
  type(c_ptr)    :: scrolled_window, statusBar

contains

  recursive subroutine destroy_signal(widget, event, gdata) bind(c)
    type(c_ptr), value, intent(in) :: widget, event, gdata

    ! Some functions and subroutines need to know that it's finished:
    run_status = FALSE
    ! Makes the innermost invocation of the main loop return when it regains control:
    if (.not. computing)   call g_main_loop_quit(my_gmainloop)
  end subroutine destroy_signal


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


  subroutine initialize_GUI
    use gdk_pixbuf, only: gdk_pixbuf_get_n_channels, gdk_pixbuf_get_pixels, &
                      & gdk_pixbuf_get_rowstride, gdk_pixbuf_new
    use gtk_os_dependent, only: gdk_pixbuf_savev
    use scientific_computing, only: my_computation

    integer(c_int) :: height
    integer(c_int) :: message_id
    ! Pointers toward our GTK widgets:
    type(c_ptr)    :: table, box1

    call gtk_init()

    ! Creates the window:
    my_window = gtk_window_new()
    call g_signal_connect(my_window, "destroy"//c_null_char, &
                        & c_funloc(destroy_signal))
    call gtk_window_set_title(my_window, &
        & "Reaction Diffusion by Gray-Scott algorithm (gtk-fortran+ForColormap+ForImage)"//c_null_char)

    ! Properties of the main window (we impose only the height) :
    height = pixheight + 180
    call gtk_window_set_default_size(my_window, -1, height)
 
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

    call gtk_widget_set_halign(my_drawing_area1, GTK_ALIGN_CENTER)
    call gtk_grid_attach(table, my_drawing_area1, 0_c_int, 1_c_int, 1_c_int, 1_c_int)

    ! The lower part of the window will be used for printing text:
    textView = gtk_text_view_new ()
    call gtk_text_view_set_monospace(textView, TRUE)
    ! A 10 pixels margin at the left and right of the widget:
    call gtk_widget_set_margin_start(textView, 10_c_int)
    call gtk_widget_set_margin_end  (textView, 10_c_int)

    buffer = gtk_text_view_get_buffer (textView)
    call gtk_text_buffer_set_text (buffer, "Reaction Diffusion model"//c_new_line//c_null_char, -1_c_int)
    ! We need a GtkTextIter iterator and a GtkTextMark to manage scrolling:
    call gtk_text_buffer_get_end_iter (buffer, c_loc(text_iter))
    ! TRUE is for left gravity:
    text_mark = gtk_text_buffer_create_mark (buffer, "scroll", c_loc(text_iter), TRUE)
    scrolled_window = gtk_scrolled_window_new()
    call gtk_scrolled_window_set_child(scrolled_window, textView)
    call gtk_grid_attach(table, scrolled_window, 0_c_int, 2_c_int, 1_c_int, 1_c_int)

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

    ! We create a pixbuffer to store the pixels the image:
    my_pixbuf1 = gdk_pixbuf_new(GDK_COLORSPACE_RGB, FALSE, 8_c_int, pixwidth, pixheight)
    nch = gdk_pixbuf_get_n_channels(my_pixbuf1)
    rowstride = gdk_pixbuf_get_rowstride(my_pixbuf1)
    call c_f_pointer(gdk_pixbuf_get_pixels(my_pixbuf1), pixels1, (/pixwidth*pixheight*nch/))
    ! We use char() for "pixels1" because we need unsigned integers.
    ! This pixbuffer has no Alpha channel (15% faster), only RGB.
    pixels1 = char(0)   ! Initialization with a black background

    ! If you don't show it, nothing will appear on screen...
    call gtk_widget_show(my_window)

    !******************************************************************
    ! Let's call our scientific computation:
    !******************************************************************
    call my_computation()

    !******************************************************************
    ! The window will stay opened after the computation, but we need to verify
    ! that the user has not closed the window during the computation.
    ! https://docs.gtk.org/glib/main-loop.html
    if (run_status /= FALSE) then
      ! Final update of the display:
      call gtk_widget_queue_draw(my_drawing_area1)

      message_id = gtk_statusbar_push (statusBar, gtk_statusbar_get_context_id(statusBar, &
                & "End"//c_null_char), "Done!"//c_null_char)

      my_gmainloop = g_main_loop_new(c_null_ptr, FALSE)
      call g_main_loop_run(my_gmainloop)
    end if

  end subroutine initialize_GUI

end module GUI_module
