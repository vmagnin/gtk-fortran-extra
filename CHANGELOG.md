# Changelog
All notable changes to the project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [gtk-fortran-extra dev]

### Added
- `saville_code/`: now saves also the image in a SVG file.

## [gtk-fortran-extra 1.2.0] 2023-04-22

### Added
- `saville_code/`: encodes a text using Peter Saville's color code.
- `unknown_pleasures/` can now also be built with the Fortran Package Manager fpm.
- `unknown_pleasures/`: Cairo text was added on the figure. It can be deactivated with a boolean flag in the code.
- `parallel_app/` demonstrates how you can use parallel Fortran 2008 and 2018 features (coarrays, collective routines...) in a gtk-fortran application.

## [gtk-fortran-extra 1.1.0] 2021-11-13

### Added
- `unknown_pleasures/`: a new example to generate figures similar to the iconic Unknown Pleasures cover.
- `my_fast_app/` and `my_long_app/`: margins at left and/or right of the TextView widgets, in order they do not touch the window's borders.
- `my_long_app/`: the TextView is now automatically scrolling.

### Changed
- The main README.md was updated, and README.md files were added in the `my_fast_app/` and `my_long_app/` directories. It was needed as more applications will be added in this repository.

### Fixed
- `my_long_app/`: the events are now treated more often.

## [gtk-fortran-extra 1.0.0] 2021-06-03

### Added
- `my_fast_app/`: computes the Lorentz attractor.
- `my_long_app/`: computes the Buddhabrot.
- `screenshots/` directory.
- `README.md` file.
