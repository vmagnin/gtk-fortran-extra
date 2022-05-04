# gtk-fortran extra examples

**These examples are under MIT license** (contrarily to the gtk-fortran repository which is under GPL), so you can begin working on your own gtk-fortran application without worrying about license problems. You can pick an app and adapt it to your own needs.

## The applications

Each application is in a directory:

* `my_fast_app`: a gtk-fortran application for fast computations (ideally < 1 second). In that case, you can use the [GtkApplication API](https://docs.gtk.org/gtk4/class.Application.html). The `activate()` GUI callback function will call the scientific computing subroutine and draw the GUI and the graphical result. In the present case, it draws a [Lorenz attractor](https://en.wikipedia.org/wiki/Lorenz_system), with three planar views and a text view. The command line version will simply print the x, y, z position of the final point.
* `my_long_app`: a gtk-fortran application for long computations, with a picture that is updated regularly. In that case you can not declare a GtkApplication: you must manage the events of the GLib main loop to keep the GUI reactive during the computation. The application is drawing a [Buddhabrot](https://en.wikipedia.org/wiki/Buddhabrot). The command line version will finally save a picture in [portable pixmap format (PPM)](https://en.wikipedia.org/wiki/Netpbm#File_formats).
* `unknown_pleasures/`: a Fortran generator of figures similar to the iconic Joy Division's *Unknown Pleasures* cover.

You can see the windows of those apps in the `screenshots/` directory.

## Installation

### Dependencies

The gtk-4-fortran library must be built and installed on your machine. Typically, on a Linux Ubuntu system, you just need to type:

```bash
$ sudo apt install libgtk-4-dev cmake git
$ git clone git@github.com:vmagnin/gtk-fortran.git
$ cd gtk-fortran
$ mkdir build && cd build
$ cmake ..
$ make -j
$ sudo make install
```

Note that your application must be compiled with the same compiler as the one used for building gtk-fortran. The default compiler used by the shell scripts is [gfortran](https://gcc.gnu.org/wiki/GFortran).

See https://github.com/vmagnin/gtk-fortran/wiki#installation-and-building for more installation instructions, especially for other OS.

### Compiling and running the apps

Typically, you need to type in your terminal:

```bash
$ git clone git@github.com:vmagnin/gtk-fortran-extra.git
$ cd gtk-fortran-extra
$ cd my_fast_app
$ ./with_GUI.sh
```

### fpm

For the moment, only the `unknown_pleasures` example can be built and run with the Fortran Package Manager:

```bash
$ cd unknown_pleasures
$ fpm run
```

In that case, gtk-fortran will be cloned and built automatically by fpm.

# References

* Vincent MAGNIN, James TAPPIN, Jens HUNGER, Jerry DE LISLE, "gtk-fortran: a GTK+ binding to build Graphical User Interfaces in Fortran", _Journal of Open Source Software,_ 4(34), 1109, 12th January 2019, [https://doi.org/10.21105/joss.01109](https://doi.org/10.21105/joss.01109)
