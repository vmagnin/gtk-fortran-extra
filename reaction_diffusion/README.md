# Reaction-Diffusion using the Gray-Scott algorithm

The primary goal of this example is to create a movie using some colormaps available in the ForColormap Fortran library.

In 1952, Alan Turing (1912-1954) published an article entitled "The Chemical Basis of Morphogenesis". He mathematically explored systems of chemical reactions including diffusion phenomena. Computer simulations were also envisaged in that paper. These chemical systems can form various patterns resembling those on the skin of animals such as leopards and zebras, but can also lead to oscillating or chaotic systems depending on model parameters. We will use Gray and Scott's Reaction Diffusion algorithm to study these patterns, using two chemical compounds A and B. See the references at the end of this page for more information.

## Requirements

- The GTK 4 development files are supposed to be installed on your system.
- A modern Fortran compiler.
- The Fortran Package Manager [fpm](https://fpm.fortran-lang.org/).

The `fpm.toml` manifest contains a dependencies section:

```toml
[dependencies]
gtk-fortran = { git = "https://github.com/vmagnin/gtk-fortran.git", branch = "gtk4" }
forcolormap = {git = "https://github.com/vmagnin/forcolormap.git" }
```
Note that ForColormap depends itself on the [ForImage](https://github.com/gha3mi/forimage) fpm library. All these dependencies will be automatically downloaded by fpm.


## Building and running

The project can be downloaded, built and run very simply:

```bash
$ git clone git@github.com:vmagnin/gtk-fortran-extra.git
$ cd reaction_diffusion
$ fpm run
```

But you should rather use the optimisation options of your compiler to accelerate the computation. For example, with GFortran:
```bash
$ fpm run --flag "-Ofast -march=native -mtune=native"
```

The program is displaying the evolution of the system in a GTK window and writes the images in PNG files. You can then create a movie with FFmpeg:
```bash
$ ffmpeg -i image%05d.png -y -r 24 -crf 17 turing.mp4
```

The movie is available on YouTube: https://www.youtube.com/watch?v=cVHLCVVvZ4U

## License

This example is under MIT license. You can therefore use it to begin your own project, and just copy that license above the concerned code sections.


## References

* Turing, A. M. "The Chemical Basis of Morphogenesis", *Philosophical Transactions of the Royal Society of London,* *Series B, Biological Sciences* 237, no 641, pp.37-72, 14 August 1952, [https://doi.org/10.1098/rstb.1952.0012](https://doi.org/10.1098/rstb.1952.0012)
* John E. Pearson, ["Complex Patterns in a Simple System"](https://www.researchgate.net/publication/6011915_Complex_Patterns_in_a_Simple_System), Science, 261,pp. 189-192, 1993, DOI:10.1126/science.261.5118.189
* Karl Sims, [Reaction-Diffusion Tutorial](http://www.karlsims.com/rd.html)
* Greg Cope, [Reaction Diffusion: The Gray-Scott Algorithm](https://www.algosome.com/articles/reaction-diffusion-gray-scott.html)
