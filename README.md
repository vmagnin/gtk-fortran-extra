# gtk-fortran extra examples

**These gtk-fortran applications demonstrate how you can write an application that can work both with a GTK 4 graphical user interface (GUI) and as a simple command line executable.** You can therefore enjoy your graphical application on your machine, and launch it on a machine where [gtk-fortran](https://github.com/vmagnin/gtk-fortran/wiki) is not installed, or launch it on a distant machine via an ssh connection. You may also want to run a long computation without its GUI to reach full speed, as there can be some performance impediment when you draw heavily on screen.  

**These examples are under MIT license** (contrarily to the gtk-fortran repository which is under GPL), so you can begin working on your own gtk-fortran application without worrying about license problems. You can pick an app and adapt it to your own needs.

## The applications

Each application is in a directory:

* `my_fast_app`: a gtk-fortran application for fast computations (ideally < 1 second). In that case, you can use the [GtkApplication API](https://docs.gtk.org/gtk4/class.Application.html). The `activate()` GUI callback function will call the scientific computing subroutine and draw the GUI and the graphical result. In the present case, it draws a [Lorenz attractor](https://en.wikipedia.org/wiki/Lorenz_system), with three planar views and a text view. The command line version will simply print the x, y, z position of the final point.
* `my_long_app`: a gtk-fortran application for long computations, with a picture that is updated regularly. In that case you can not declare a GtkApplication: you must manage the events of the GLib main loop to keep the GUI reactive during the computation. The application is drawing a [Buddhabrot](https://en.wikipedia.org/wiki/Buddhabrot). The command line version will finally save a picture in [portable pixmap format (PPM)](https://en.wikipedia.org/wiki/Netpbm#File_formats).

You can see the windows of those apps in the `screenshots/` directory.

## Technical aspects

The applications can be built with either the `with_GUI.sh` or `without_GUI.sh` scripts. And their tree is typically:

```bash
$ tree my_fast_app
my_fast_app
├── with_or_without_GUI.f90
├── GUI_module.f90
├── hooks_GTK_with_GUI.f90
├── hooks_GTK_without_GUI.f90
├── scientific_computing.f90
├── main_with_GUI.f90
├── main_without_GUI.f90
├── with_GUI.sh
└── without_GUI.sh
```

There are three kinds of Fortran instructions in those apps:

* instructions that are not related in any way to gtk-fortran, typically the scientific computation. They will be compiled and executed in both cases.
* Instructions which are related to the GUI but which does not use gtk-fortran modules. It can be for example instructions which fill an integer array containing RGB values that will be used in another place to draw pixels. Those instructions blocks can be put in an `if (GUI) then ... end if` structure. Some declarations will be put in the `with_or_without_GUI.f90` module. The `GUI` boolean flag is defined in the main program `main_with_GUI.f90` or `main_without_GUI.f90`.
* Instructions blocks calling gtk-fortran functions, to define the GUI or draw on screen. You must isolate them in one or several files (modules) that will be compiled only by the `with_GUI.sh` script: `GUI_module.f90` and `hooks_GTK_with_GUI.f90`. In your scientific computation, instead of calling directly gtk-fortran functions you will call *hook functions*, which will either call the gtk-fortran functions in the GUI version or do nothing in the command line version.

Following those principles, it should always be possible to obtain an application that can be compiled with or without its GUI. The main practical difficulty is to avoid modules circular dependencies. 

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

```bash
$ git clone git@github.com:vmagnin/gtk-fortran-extra.git
$ cd gtk-fortran-extra
$ cd my_fast_app
$ ./with_GUI.sh
```

# References

* Vincent MAGNIN, James TAPPIN, Jens HUNGER, Jerry DE LISLE, "gtk-fortran: a GTK+ binding to build Graphical User Interfaces in Fortran", _Journal of Open Source Software,_ 4(34), 1109, 12th January 2019, [https://doi.org/10.21105/joss.01109](https://doi.org/10.21105/joss.01109)
* Ondrej CERTIK's code (MIT license) for PPM format: https://github.com/certik/fortran-utils/blob/master/src/ppm.f90