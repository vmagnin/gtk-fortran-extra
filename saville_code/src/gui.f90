! The MIT License (MIT)
!
! Copyright (c) 2023 Vincent Magnin
!
! Permission is hereby granted, free of charge, to any person obtaining a copy
! of this software and associated documentation files (the "Software"), to deal
! in the Software without restriction, including without limitation the rights
! to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
! copies of the Software, and to permit persons to whom the Software is
! furnished to do so, subject to the following conditions:
!
! The above copyright notice and this permission notice shall be included in all
! copies or substantial portions of the Software.
!
! THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
! IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
! FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
! AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
! LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
! OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
! SOFTWARE.
!-------------------------------------------------------------------------------
! Contributed by Vincent Magnin: 2023-03-26
! Last modification: vmagnin 2023-04-23
!-------------------------------------------------------------------------------

module gui
    ! Cairo needs 64 bits reals:
    use, intrinsic :: iso_c_binding, only: c_int, dp=>c_double, c_null_char, &
                                         & c_null_ptr, c_null_funptr, c_funloc

    use gtk, only: gtk_application_window_new, gtk_drawing_area_new, &
    & gtk_drawing_area_set_content_width, gtk_drawing_area_set_content_height, &
    & gtk_widget_queue_draw, &
    & gtk_drawing_area_set_draw_func, gtk_window_set_child, gtk_widget_show, &
    & gtk_window_destroy, gtk_window_set_default_size, gtk_window_set_title, &
    & gtk_button_new_with_label, gtk_entry_get_buffer, gtk_entry_buffer_get_text, &
    & gtk_grid_attach, gtk_grid_new, gtk_grid_set_row_homogeneous, &
    & gtk_grid_set_column_homogeneous, &
    & gtk_widget_set_margin_start, gtk_widget_set_margin_end, &
    & gtk_widget_set_margin_top, gtk_widget_set_margin_bottom, &
    & g_signal_connect, g_signal_connect_swapped, gtk_label_new, gtk_entry_new, &
    & gtk_link_button_new_with_label, gtk_spin_button_new_with_range, &
    & gtk_spin_button_set_value, gtk_spin_button_get_value, &
    & gtk_statusbar_new, gtk_statusbar_push, gtk_statusbar_get_context_id, &
    & gtk_toggle_button_new_with_label, gtk_toggle_button_set_group, &
    & gtk_toggle_button_set_active, gtk_toggle_button_get_active, TRUE, &
    & CAIRO_SVG_VERSION_1_2

    use cairo, only: cairo_get_target, cairo_line_to, cairo_move_to, &
    & cairo_set_line_width, cairo_set_source_rgb, &
    & cairo_surface_write_to_png, cairo_rectangle, cairo_fill, &
    & cairo_svg_surface_create, cairo_svg_surface_restrict_to_version, &
    & cairo_surface_destroy, cairo_create, cairo_destroy

    use grapheme_class

    implicit none
    ! Widgets that must be global:
    type(c_ptr) :: window, my_drawing_area, entry1, statusBar
    type(c_ptr) :: toggleButtonH, toggleButtonV, spinButton1, spinButton2

contains

    ! The GUI is defined here:
    subroutine activate(app, gdata) bind(c)
        type(c_ptr), value, intent(in)  :: app, gdata
        type(c_ptr)    :: table, button1, button3, label1, linkButton
        type(c_ptr)    :: label2, label3
        integer(c_int) :: width, height
        integer(c_int) :: message_id

        window = gtk_application_window_new(app)
        width  = 800
        height = 600
        call gtk_window_set_default_size(window, width, height)
        call gtk_window_set_title(window, "Peter Saville's color code (gtk-fortran)"//c_null_char)

        table = gtk_grid_new()
        call gtk_grid_set_column_homogeneous(table, TRUE)
        call gtk_grid_set_row_homogeneous(table, TRUE)
        ! Set the border width around the container:
        call gtk_widget_set_margin_start(table, 10_c_int)
        call gtk_widget_set_margin_end(table, 10_c_int)
        call gtk_widget_set_margin_top(table, 10_c_int)
        call gtk_widget_set_margin_bottom(table, 10_c_int)

        button1 = gtk_button_new_with_label("Encode"//c_null_char)
        call g_signal_connect(button1, "clicked"//c_null_char, c_funloc(firstbutton))
        call gtk_widget_set_margin_bottom(button1, 10_c_int)

        button3 = gtk_button_new_with_label("Exit"//c_null_char)
        call g_signal_connect(button3, "clicked"//c_null_char, c_funloc(destroy))
        call gtk_widget_set_margin_bottom(button3, 10_c_int)

        ! A clickable URL link:
        linkButton = gtk_link_button_new_with_label( &
            &"https://en.wikipedia.org/wiki/Peter_Saville_(graphic_designer)"//c_null_char,&
            &"About Peter Saville"//c_null_char)

        label1 = gtk_label_new("Enter your text:"//c_null_char)
        entry1 = gtk_entry_new()

        ! By default the text will be printed horizontally:
        toggleButtonH = gtk_toggle_button_new_with_label("Horizontal"//c_null_char)
        toggleButtonV = gtk_toggle_button_new_with_label("Vertical"//c_null_char)
        call gtk_toggle_button_set_group(toggleButtonH, toggleButtonV)
        call gtk_toggle_button_set_active(toggleButtonH, TRUE)

        ! The spin buttons to set the parameters:
        label2 = gtk_label_new("Square width"//c_null_char)
        ! Min, max, step:
        spinButton1 = gtk_spin_button_new_with_range(2._dp, 100._dp, 2._dp)
        ! Initial value:
        call gtk_spin_button_set_value(spinButton1, 50._dp)

        label3 = gtk_label_new("Line spacing"//c_null_char)
        spinButton2 = gtk_spin_button_new_with_range(0._dp, 100._dp, 1._dp)
        call gtk_spin_button_set_value(spinButton2, 0._dp)

        ! https://docs.gtk.org/gtk4/class.DrawingArea.html
        my_drawing_area = gtk_drawing_area_new()
        call gtk_drawing_area_set_content_width(my_drawing_area, width)
        call gtk_drawing_area_set_content_height(my_drawing_area, height)
        call gtk_drawing_area_set_draw_func(my_drawing_area, &
                      & c_funloc(my_draw_function), c_null_ptr, c_null_funptr)

        ! The drawing should be called when pressing the Enter key
        ! in the entry1 field, or changing the spinbuttons values,
        ! or choosing one of the toggled buttons:
        call g_signal_connect_swapped(entry1, "activate"//c_null_char, c_funloc(firstbutton), my_drawing_area)
        call g_signal_connect_swapped(spinButton1, "value-changed"//c_null_char, c_funloc(firstbutton), my_drawing_area)
        call g_signal_connect_swapped(spinButton2, "value-changed"//c_null_char, c_funloc(firstbutton), my_drawing_area)
        call g_signal_connect_swapped(toggleButtonH, "toggled"//c_null_char, c_funloc(firstbutton), my_drawing_area)

        ! GtkStatusbar DEPRECATED since: 4.10 - This widget will be removed in GTK 5
        ! The window status bar can be used to print messages:
        statusBar = gtk_statusbar_new()
        message_id = gtk_statusbar_push(statusBar, gtk_statusbar_get_context_id(statusBar, &
                    & "Start"//c_null_char), "Waiting for the text to encode..."//c_null_char)

        ! In the grid container: x, y, width, height
        block
            integer(c_int) :: line = 0_c_int
            call gtk_grid_attach(table, label1,          0_c_int, line, 1_c_int, 1_c_int)
            call gtk_grid_attach(table, entry1,          1_c_int, line, 2_c_int, 1_c_int)
            line = line + 1
            call gtk_grid_attach(table, toggleButtonH,   0_c_int, line, 1_c_int, 1_c_int)
            call gtk_grid_attach(table, toggleButtonV,   1_c_int, line, 1_c_int, 1_c_int)
            line = line + 1
            call gtk_grid_attach(table, label2,          0_c_int, line, 1_c_int, 1_c_int)
            call gtk_grid_attach(table, spinButton1,     1_c_int, line, 1_c_int, 1_c_int)
            call gtk_grid_attach(table, linkButton,      2_c_int, line, 1_c_int, 1_c_int)
            line = line + 1
            call gtk_grid_attach(table, label3,          0_c_int, line, 1_c_int, 1_c_int)
            call gtk_grid_attach(table, spinButton2,     1_c_int, line, 1_c_int, 1_c_int)
            line = line + 1
            call gtk_grid_attach(table, button1,         0_c_int, line, 1_c_int, 1_c_int)
            call gtk_grid_attach(table, button3,         2_c_int, line, 1_c_int, 1_c_int)
            line = line + 1
            call gtk_grid_attach(table, my_drawing_area, 0_c_int, line, 3_c_int, 15_c_int)
            line = line + 15
            call gtk_grid_attach(table, statusBar,       0_c_int, line, 3_c_int, 1_c_int)
        end block

        call gtk_window_set_child(window, table)
        call gtk_widget_show(window)
    end subroutine activate

    ! "It is called whenever GTK needs to draw the contents of the drawing area
    ! to the screen."
    ! cr is the Cairo context
    subroutine my_draw_function(widget, cr_screen, width, height, gdata) bind(c)
        use gtk_sup, only: c_f_string_copy_alloc

        type(c_ptr), value, intent(in)    :: widget, cr_screen, gdata
        integer(c_int), value, intent(in) :: width, height
        integer(c_int) :: maxi
        integer        :: i
        type(Grapheme) :: graph
        real(dp) :: w, ls
        real(dp) :: x, y   ! Position of a character
        logical  :: horizontal
        type(c_ptr) :: buffer
        integer     :: cstatus
        integer(c_int) :: message_id
        character(:), allocatable :: my_string, filename
        integer :: rendering
        type(c_ptr) :: surface_svg, cr_svg, cr

        ! The string to encode:
        buffer = gtk_entry_get_buffer(entry1)
        call c_f_string_copy_alloc(gtk_entry_buffer_get_text(buffer), my_string)
        filename = my_string

        if (len(my_string) == 0) then
            print *, "Empty string => no drawing"
            return
        end if

        ! Width of a square:
        w = gtk_spin_button_get_value(spinButton1)
        ! Line spacing:
        ls = gtk_spin_button_get_value(spinButton2)

        ! Is the text horizontal (default) or vertical?
        horizontal = (gtk_toggle_button_get_active(toggleButtonH) == TRUE)

        ! Size of a "line":
        if (horizontal) then
            maxi = width
        else
            maxi = height
        end if

        ! We will draw two times, once for screen, once in a SVG file:
        do rendering = 1, 2

            if (rendering == 1) then
                ! Rendering on screen:
                cr = cr_screen
            else
                ! Rendering in a SVG file:
                surface_svg = cairo_svg_surface_create(filename//".svg"//c_null_char, &
                                        & real(width, KIND=dp), real(height, KIND=dp))
                cr_svg = cairo_create(surface_svg)
                call cairo_svg_surface_restrict_to_version(surface_svg, CAIRO_SVG_VERSION_1_2)
                cr = cr_svg
            end if

            ! Black background:
            call cairo_set_source_rgb(cr, 0.0_dp, 0.0_dp, 0.0_dp)
            call cairo_rectangle(cr, 0.0_dp, 0.0_dp, real(width, KIND=dp), real(height, KIND=dp))
            call cairo_fill(cr)

            ! Starting position at top left:
            y = 2*w
            x = 2*w

            do i = 1, len(my_string)
                ! The PNG filename should not contain spaces:
                if (my_string(i:i) == " ") filename(i:i) = "_"
                ! End of line?
                if (x > maxi - 3*w) then
                    ! Line feed:
                    y = y + w + ls
                    ! Carriage return:
                    x = 2*w
                end if
                ! Draw the character i:
                if (horizontal) then
                    graph = Grapheme(name=my_string(i:i), x=x, y=y, width=w, cr=cr)
                else
                    graph = Grapheme(name=my_string(i:i), x=y, y=x, width=w, cr=cr)
                end if
                call graph%draw()

                ! Next position:
                x = x + w
            end do

            if (rendering == 1) then
                ! Screen
                print '("Saving the PNG file: ", I0, " x ", I0, " pixels")', width, height
                cstatus = cairo_surface_write_to_png(cairo_get_target(cr), &
                                            & filename//".png"//c_null_char)
                call cairo_destroy(cr_screen)
            else
                ! SVG
                call cairo_surface_destroy(surface_svg)
            end if

            message_id = gtk_statusbar_push(statusBar, gtk_statusbar_get_context_id(statusBar, &
                & "Saville"//c_null_char), "Image saved: "//filename//".png and "//filename//".svg"//c_null_char)
        end do
    end subroutine my_draw_function


    ! GtkObject signal:
    subroutine destroy(widget, gdata) bind(c)
        type(c_ptr), value, intent(in) :: widget, gdata

        print *, "my destroy"
        ! This is the end of the program:
        call gtk_window_destroy(window)
    end subroutine destroy


    ! GtkButton signal ("encode" button):
    subroutine firstbutton(widget, gdata) bind(c)
        type(c_ptr), value, intent(in) :: widget, gdata

        call gtk_widget_queue_draw(my_drawing_area)
    end subroutine firstbutton

end module gui
