# A gtk-fortran parallel example

**This [gtk-fortran](https://github.com/vmagnin/gtk-fortran/wiki) example demonstrates you can write a GTK application that uses the modern Fortran parallel features like coarrays (Fortran 2008) or collective routines, teams, events (Fortran 2018).** Everything concerning the GUI must simply be managed by the first Fortran image using structures like `if (this_image() == 1) then ...GUI STUFF... end if`.

## The application

The application is drawing a [Buddhabrot](https://en.wikipedia.org/wiki/Buddhabrot) and finally save the picture in a file.

Each Fortran image is computing its own Buddhabrot, and they are regularly summed with the `co_sum()` intrinsic. The process is very similar to what is done in astrophotography.

## Building and running

For GFortran, you need to install [OpenCoarrays](http://www.opencoarrays.org/) and type that command (4 images here):

```bash
$ caf -O3 GUI_and_computation.f90  main.f90 && cafrun -n 4 ./a.out
```

And for ifort:

```bash
$ ifort -O3 -coarray GUI_and_computation.f90  main.f90 && ./a.out
```

**Note that gtk-fortran must have been built with the same compiler.**

Tested on a PC with Intel(R) Core(TM) i7-5500U CPU @ 2.40GHz (dual core bi-thread)

## Bibliography

* Curcic, Milan. [Modern Fortran - Building efficient parallel applications](https://learning.oreilly.com/library/view/-/9781617295287/?ar), Manning Publications, 1st edition, novembre 2020, ISBN 978-1-61729-528-7.
* Metcalf, Michael, John Ker Reid, et Malcolm Cohen. *[Modern Fortran Explained: Incorporating Fortran 2018.](https://oxford.universitypressscholarship.com/view/10.1093/oso/9780198811893.001.0001/oso-9780198811893)* Numerical Mathematics and Scientific Computation. Oxford (England): Oxford University Press, 2018, ISBN 978-0-19-185002-8.