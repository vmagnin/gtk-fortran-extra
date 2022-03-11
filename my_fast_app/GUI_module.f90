!------------------------------------------------------------------------------
! Contributed by Vincent Magnin
! Last modifications: vmagnin 2021-06-04
! MIT license
!------------------------------------------------------------------------------

module GUI_module
  use gtk, only: gtk_application_window_new, gtk_window_destroy, &
  & g_signal_connect, gtk_window_set_child, gtk_box_append, &
  & gtk_scrolled_window_set_child, gtk_drawing_area_new, &
  & gtk_drawing_area_set_content_width, gtk_drawing_area_set_content_height, &
  & gtk_drawing_area_set_draw_func, &
  & gtk_widget_queue_draw, gtk_widget_show, &
  & gtk_window_set_default_size, gtk_window_set_title, &
  & TRUE, FALSE, GDK_COLORSPACE_RGB, gtk_grid_new, gtk_grid_attach, &
  & gtk_box_new, gtk_text_view_new, gtk_text_view_get_buffer, &
  & gtk_text_buffer_set_text, gtk_scrolled_window_new, &
  & gtk_text_buffer_insert_at_cursor, gtk_text_view_set_monospace, &
  & gtk_statusbar_new, gtk_label_new, &
  & gtk_statusbar_push, gtk_statusbar_get_context_id, &
  & GTK_ORIENTATION_VERTICAL, gtk_grid_set_column_homogeneous, &
  & gtk_grid_set_row_homogeneous, gtk_widget_set_vexpand, &
  & gtk_grid_set_column_spacing, gtk_grid_set_row_spacing, &
  & gtk_widget_set_margin_end

  use, intrinsic :: iso_c_binding

  implicit none
  type(c_ptr)           :: my_window
  type(c_ptr)           :: my_pixbuf1, my_pixbuf2, my_pixbuf3
  type(c_ptr)           :: my_drawing_area1, my_drawing_area2, my_drawing_area3
  type(c_ptr)           :: textView, scrolled_window, statusBar
  integer(kind=c_int)   :: width, height

contains

  recursive subroutine destroy_signal(widget, event, gdata) bind(c)
    type(c_ptr), value, intent(in) :: widget, event, gdata

    print *, "Your destroy_signal() function has been invoked !"
    call gtk_window_destroy(my_window)
  end subroutine destroy_signal


  ! "It is called whenever GTK needs to draw the contents of the drawing area
  ! to the screen."
  ! https://developer.gnome.org/gtk4/stable/GtkDrawingArea.html#gtk-drawing-area-set-draw-func
  subroutine my_draw_function1(widget, my_cairo_context, width, height, gdata) bind(c)
    use cairo, only: cairo_paint
    use gdk, only: gdk_cairo_set_source_pixbuf

    type(c_ptr), value, intent(in)    :: widget, my_cairo_context, gdata
    integer(c_int), value, intent(in) :: width, height

    ! We redraw the pixbuf:
    call gdk_cairo_set_source_pixbuf(my_cairo_context, my_pixbuf1, 0d0, 0d0)
    call cairo_paint(my_cairo_context)
  end subroutine my_draw_function1

  subroutine my_draw_function2(widget, my_cairo_context, width, height, gdata) bind(c)
    use cairo, only: cairo_paint
    use gdk, only: gdk_cairo_set_source_pixbuf

    type(c_ptr), value, intent(in)    :: widget, my_cairo_context, gdata
    integer(c_int), value, intent(in) :: width, height

    ! We redraw the pixbuf:
    call gdk_cairo_set_source_pixbuf(my_cairo_context, my_pixbuf2, 0d0, 0d0)
    call cairo_paint(my_cairo_context)
  end subroutine my_draw_function2

  subroutine my_draw_function3(widget, my_cairo_context, width, height, gdata) bind(c)
    use cairo, only: cairo_paint
    use gdk, only: gdk_cairo_set_source_pixbuf

    type(c_ptr), value, intent(in)    :: widget, my_cairo_context, gdata
    integer(c_int), value, intent(in) :: width, height

    ! We redraw the pixbuf:
    call gdk_cairo_set_source_pixbuf(my_cairo_context, my_pixbuf3, 0d0, 0d0)
    call cairo_paint(my_cairo_context)
  end subroutine my_draw_function3


  ! Save a picture:
  ! https://developer.gnome.org/gdk-pixbuf/stable/gdk-pixbuf-File-saving.html
  ! https://mail.gnome.org/archives/gtk-list/2004-October/msg00186.html
  subroutine save_pixbuf(pixbuf, filename)
    use gtk_os_dependent, only: gdk_pixbuf_savev

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
                       & statusBar, "Saved"//c_null_char), TRIM(string))
  end subroutine save_pixbuf


  subroutine activate(app, gdata) bind(c)
    use gdk_pixbuf, only: gdk_pixbuf_get_n_channels, gdk_pixbuf_get_pixels, &
                      & gdk_pixbuf_get_rowstride, gdk_pixbuf_new
    use with_or_without_GUI
    use scientific_computing

    type(c_ptr), value, intent(in)  :: app, gdata
    integer(c_int) :: message_id
    ! Pointers toward our GTK widgets:
    type(c_ptr)    :: table, box1
    type(c_ptr)    :: label1, label2, label3

    ! Creates the window:
    my_window = gtk_application_window_new(app)
    call g_signal_connect(my_window, "destroy"//c_null_char, &
                        & c_funloc(destroy_signal))
    call gtk_window_set_title(my_window, "My fast scientific app"//c_null_char)

    ! Properties of the main window :
    width  = 1200
    height = 1000
    call gtk_window_set_default_size(my_window, width, height)
 
    !******************************************************************
    ! Adding widgets in the window:
    !******************************************************************

    ! A table container will contain buttons and labels:
    table = gtk_grid_new ()
    call gtk_grid_set_column_homogeneous(table, TRUE)
    !call gtk_grid_set_row_homogeneous(table, TRUE)
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
    label1 = gtk_label_new("y, z"//c_null_char)

    my_drawing_area2 = gtk_drawing_area_new()
    call gtk_drawing_area_set_content_width(my_drawing_area2, pixwidth)
    call gtk_drawing_area_set_content_height(my_drawing_area2, pixheight)
    call gtk_drawing_area_set_draw_func(my_drawing_area2, &
                     & c_funloc(my_draw_function2), c_null_ptr, c_null_funptr)
    label2 = gtk_label_new("x, y"//c_null_char)

    my_drawing_area3 = gtk_drawing_area_new()
    call gtk_drawing_area_set_content_width(my_drawing_area3, pixwidth)
    call gtk_drawing_area_set_content_height(my_drawing_area3, pixheight)
    call gtk_drawing_area_set_draw_func(my_drawing_area3, &
                     & c_funloc(my_draw_function3), c_null_ptr, c_null_funptr)
    label3 = gtk_label_new("x, z"//c_null_char)

    call gtk_grid_attach(table, label1,           0_c_int, 0_c_int, 1_c_int, 1_c_int)
    call gtk_grid_attach(table, my_drawing_area1, 0_c_int, 1_c_int, 1_c_int, 1_c_int)
    call gtk_grid_attach(table, label2,           0_c_int, 2_c_int, 1_c_int, 1_c_int)
    call gtk_grid_attach(table, my_drawing_area2, 0_c_int, 3_c_int, 1_c_int, 1_c_int)
    call gtk_grid_attach(table, label3,           1_c_int, 0_c_int, 1_c_int, 1_c_int)
    call gtk_grid_attach(table, my_drawing_area3, 1_c_int, 1_c_int, 1_c_int, 1_c_int)

    ! The third screen quarter will be used for printing text:
    textView = gtk_text_view_new ()
    call gtk_text_view_set_monospace(textView, TRUE)
    ! A 10 pixels margin at the right of the widget:
    call gtk_widget_set_margin_end (textView, 10_c_int)

    buffer = gtk_text_view_get_buffer (textView)
    call gtk_text_buffer_set_text (buffer, "My scientific app: drawing the Lorenz attractor"//c_new_line// &
        & "You can copy this text and even edit it !"//c_new_line//c_null_char,&
        & -1_c_int)
    scrolled_window = gtk_scrolled_window_new()
    call gtk_scrolled_window_set_child(scrolled_window, textView)
    call gtk_grid_attach(table, scrolled_window, 1_c_int, 3_c_int, 1_c_int, 1_c_int)

    call gtk_widget_set_vexpand (box1, TRUE)

    ! The window status bar can be used to print messages:
    statusBar = gtk_statusbar_new ()
    message_id = gtk_statusbar_push (statusBar, gtk_statusbar_get_context_id(statusBar, &
                & "Computing..."//c_null_char), "Start"//c_null_char)
    call gtk_box_append(box1, statusBar)

    ! Let's finalize the GUI:
    call gtk_window_set_child(my_window, box1)
    call gtk_widget_show(my_window)

    ! We create three pixbuffers to store the pixels of each image:
    my_pixbuf1 = gdk_pixbuf_new(GDK_COLORSPACE_RGB, FALSE, 8_c_int, pixwidth, pixheight)
    nch = gdk_pixbuf_get_n_channels(my_pixbuf1)
    rowstride = gdk_pixbuf_get_rowstride(my_pixbuf1)
    call c_f_pointer(gdk_pixbuf_get_pixels(my_pixbuf1), pixels1, (/pixwidth*pixheight*nch/))
    ! We use char() for "pixels" because we need unsigned integers.
    ! This pixbuffer has no Alpha channel (15% faster), only RGB.
    pixels1 = char(0)

    my_pixbuf2 = gdk_pixbuf_new(GDK_COLORSPACE_RGB, FALSE, 8_c_int, pixwidth, pixheight)
    nch = gdk_pixbuf_get_n_channels(my_pixbuf2)
    rowstride = gdk_pixbuf_get_rowstride(my_pixbuf2)
    call c_f_pointer(gdk_pixbuf_get_pixels(my_pixbuf2), pixels2, (/pixwidth*pixheight*nch/))
    pixels2 = char(0)

    my_pixbuf3 = gdk_pixbuf_new(GDK_COLORSPACE_RGB, FALSE, 8_c_int, pixwidth, pixheight)
    nch = gdk_pixbuf_get_n_channels(my_pixbuf3)
    rowstride = gdk_pixbuf_get_rowstride(my_pixbuf3)
    call c_f_pointer(gdk_pixbuf_get_pixels(my_pixbuf3), pixels3, (/pixwidth*pixheight*nch/))
    pixels3 = char(0)
    !******************************************************************

    ! If you don't show it, nothing will appear on screen...
    call gtk_widget_show(my_window)

    ! Let's call our scientific computation:
    call my_computation()

    ! Final update of the display:
    call gtk_widget_queue_draw(my_drawing_area1)
    call gtk_widget_queue_draw(my_drawing_area2)
    call gtk_widget_queue_draw(my_drawing_area3)
    call save_pixbuf(my_pixbuf1, "my_pixbuf1.png")

    call gtk_text_buffer_insert_at_cursor (buffer, &
         & "Done!"//c_new_line//c_null_char, -1_c_int)
  end subroutine activate


  subroutine initialize_GUI
    use gtk, only: gtk_application_new, G_APPLICATION_FLAGS_NONE
    use g, only: g_application_run, g_object_unref

    integer(c_int)     :: status
    type(c_ptr)        :: app

    app = gtk_application_new("fast_app.with_or_without.gui"//c_null_char, &
                                & G_APPLICATION_FLAGS_NONE)
    call g_signal_connect(app, "activate"//c_null_char, c_funloc(activate), &
                        & c_null_ptr)
    status = g_application_run(app, 0_c_int, [c_null_ptr])

    call g_object_unref(app)
  end subroutine initialize_GUI
end module GUI_module
