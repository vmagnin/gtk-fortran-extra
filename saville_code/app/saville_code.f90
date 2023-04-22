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
! Last modification: vmagnin 2023-04-08
!-------------------------------------------------------------------------------

! We create a GtkApplication:
program saville_code
    use, intrinsic :: iso_c_binding
    use gui, only: activate
    use gtk, only: gtk_application_new, g_signal_connect, G_APPLICATION_FLAGS_NONE
    use g, only: g_application_run, g_object_unref

    implicit none
    integer(c_int) :: exit_status
    type(c_ptr)    :: app

    app = gtk_application_new("gtk-fortran.examples.saville_code"//c_null_char, &
                             & G_APPLICATION_FLAGS_NONE)
    call g_signal_connect(app, "activate"//c_null_char, c_funloc(activate), &
                        & c_null_ptr)
    exit_status = g_application_run(app, 0_c_int, [c_null_ptr])
    call g_object_unref(app)
end program
