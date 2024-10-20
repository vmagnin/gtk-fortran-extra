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
! Last modification: vmagnin 2024-10-20
!-------------------------------------------------------------------------------

program check
    use glyph_class
    use charac_class
    use color_class

    implicit none
    type(Color) :: my_color = Color(RGB=[0.823523_dp, 0.843137_dp, 0.894117_dp])
    type(Glyph) :: my_glyph = Glyph(name="A", &
                          & left = Color(CMYK=[0.7_dp, 0._dp, 0.4_dp, 0._dp]), &
                          & right= Color(CMYK=[0.7_dp, 0._dp, 0.4_dp, 0._dp]))
    type(Glyph) :: another_glyph

    call my_color%print()
    call my_color%convert_RGB_to_CMYK()
    call my_color%print()
    print *
    call my_color%convert_CMYK_to_RGB()
    call my_color%print()
    print *

    call my_glyph%print()
    call my_glyph%left%convert_CMYK_to_RGB()
    call my_glyph%left%print()
    print *
    call another_glyph%set("d")
    call another_glyph%print()
    call another_glyph%left%print()

end program check
