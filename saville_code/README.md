# Peter Saville's color code

In 1983-1984, the Manchester graphic designer [Peter Saville](https://en.wikipedia.org/wiki/Peter_Saville_(graphic_designer)) used a color code to write information on four Factory Records covers, the first being the [Blue Monday](https://www.youtube.com/watch?v=c1GxjzHm5us) 12" single (best selling 12" single of all time). The idea was to underline the modernity of the music track with a color code evoking a computer-readable code (barcode readers were still a novelty). The *Blue Monday* cover is also famous for its cut-out in the shape of a 5.25" floppy disk (a modern medium at the time, generally storing 360 KB).

In Saville's code, the available characters are only the ten digits, the A-Z letters and the space. In our application, lowercase letters are automatically converted into uppercase letters. All other characters are treated like spaces.

Except the space which is coded by a grey octagon, all the glyphs are represented by a square whose each half can have its own color. If the two halves have different colors, they are separated by a white line. The letters A to I (which share the same glyphs as the digits 1 to 9) use only one color.

Remark: depending on the sources available on the Web, the 0 character is either a white square or similar to the character J. It is uncertain as the zero was not used in the four covers. For the moment, we have chosen the first interpretation, as suggested by some graphical notes by Peter Saville available on the web.


## Fortran implementation

This Fortran implementation of Saville's color code is based on [gtk-fortran](https://github.com/vmagnin/gtk-fortran/wiki) (GTK 4), and especially its [Cairo graphics library](https://www.cairographics.org/).

### Color class

This project was a pretext to study the basics of Object Oriented Programming in modern Fortran (OOP was introduced in the Fortran 2003 standard). The color class contains two arrays CMYK and RGB to store the color values, and two subroutines for conversions between those two systems. Peter Saville wanting to print an album cover, he defined the colors of his code using the [CMYK color model](https://en.wikipedia.org/wiki/CMYK_color_model).
Note that we do not use any [ICC profile](https://en.wikipedia.org/wiki/ICC_profile). It is therefore just a simplistic conversion. We used the formula available on those two pages:

* https://www.rapidtables.com/convert/color/rgb-to-cmyk.html
* https://www.rapidtables.com/convert/color/cmyk-to-rgb.html

### Glyph and grapheme classes

A [glyph](https://en.wikipedia.org/wiki/Glyph) is defined by its name, the colors of its two halves and the presence or absence of a separator between the two halves. The `set()` method receives the name of the glyph (for example "A") and sets its other properties, using the Peter Saville's color code.
 
The [grapheme](https://en.wikipedia.org/wiki/Grapheme) class extends the glyph class. It has x and y coordinates, a width in pixels and a Cairo context. The method `draw()` is used to draw it on screen.


## Build and run

### With fpm

If you have installed the Fortran Package Manager [fpm](https://fpm.fortran-lang.org/), you have just to type from the `saville_code/` directory:

```bash
$ fpm run
```

fpm will automatically clone the gtk-fortran repository and build everything.

### With the build.sh script

gtk-fortran is supposed to be installed in your system.

#### With GFortran

On a UNIX-like system, you can use the build script:

```bash
$ ./build.sh && ./a.out
```

#### With another compiler

You can use another compiler, for example Intel ifx:

```bash
$ FC="ifx" ./build.sh
$ ./a.out
```
but in that case **gtk-fortran must be compiled with the same compiler.**

## Perspectives

* A SVG output would be interesting.

## Contributing

* Post a message in the GitHub *Issues* tab to discuss the feature you want to work on,
* Concerning coding conventions, follow the stdlib conventions:
https://github.com/fortran-lang/stdlib/blob/master/STYLE_GUIDE.md
* When ready, make a *Pull Request*.


## Bibliography
* The four album covers using the color code:
  - New Order, *Blue Monday,* 12" single, March 1983, [FAC 73](https://factoryrecords.org/cerysmatic/fac73.php).
    - Official Lyric Video: https://youtu.be/c1GxjzHm5us
    - Songs that Changed Music: New Order - *Blue Monday:* https://www.youtube.com/watch?v=Iyzk1Gwwu7c
  - New Order, *Power Corruption and Lies,* May 1983, [FACT 75](https://factoryrecords.org/cerysmatic/fact75.php).
  - New Order, *Confusion,* 12" single, August 1983, [FACT 93](https://factoryrecords.org/cerysmatic/fac93.php).
    - Official Lyric Video (single version): https://youtu.be/c_L_-CKg6pw
  - Section 25, *From the Hip,* March 1984, [FACT 90](https://factoryrecords.org/cerysmatic/fact90c.php).
* Matthew Robertson, [_Factory Records: The Complete Graphic Album_](https://factoryrecords.org/cerysmatic/fac461_factory_records_the_complete_graphic_album.php), FAC 461, Chronicle Books, 2006,  ISBN‎ 978-0811856768.
* About Peter Saville:
  - https://designmuseum.org/designers/peter-saville
  - https://www.thisisdig.com/feature/best-peter-saville-artworks-album-covers/
* About its color code:
  - https://wharferj.wordpress.com/2011/04/19/peter-saville-new-order-colour-code/
  - https://www.pinterest.fr/pin/304978205990432253/
  - https://lukeholland2.wordpress.com/2012/11/19/savilles-client-base/ps1-screen-shot-2013-01-14-at-16-16-21/#main
  - https://xpressivo.wordpress.com/2013/06/18/proj-02-peter-saville-colour-code/
  - https://new-order.fandom.com/wiki/Peter_Saville%27s_Code
