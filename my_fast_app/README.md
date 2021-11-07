# Fast computation gtk-fortran example

**This gtk-fortran application demonstrates how you can write an application that can work both with a GTK 4 graphical user interface (GUI) and as a simple command line executable.** You can therefore enjoy your graphical application on your machine, and launch it on a machine where [gtk-fortran](https://github.com/vmagnin/gtk-fortran/wiki) is not installed, or launch it on a distant machine via an ssh connection. You may also want to run a long computation with or without its GUI to reach full speed, as there can be some performance impediment when you draw heavily on screen: in that case, look in the `my_long_app` directory.  

## The application

`my_fast_app` is a gtk-fortran application for fast computations (ideally < 1 second). In that case, you can use the [GtkApplication API](https://docs.gtk.org/gtk4/class.Application.html). The `activate()` GUI callback function will call the scientific computing subroutine and draw the GUI and the graphical result. In the present case, it draws a [Lorenz attractor](https://en.wikipedia.org/wiki/Lorenz_system), with three planar views and a text view. The command line version will simply print the x, y, z position of the final point.

## Technical aspects

The application can be built with either the `with_GUI.sh` or `without_GUI.sh` scripts. And the tree is:

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

## References

* Ondrej CERTIK's code (MIT license) for PPM format: https://github.com/certik/fortran-utils/blob/master/src/ppm.f90