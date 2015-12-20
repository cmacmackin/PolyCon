# PolyCon

Provides an abstract container derived type which can be used 
as a sort of unlimited polymorphic entity whose contents are
retrievable with type-guards. Different subclasses are created
in order to hold different data-types. Subclasses are provided for
the default variable types in Fortran. The abstract type can be used
within data structures to so that a single implementation can hold
arbitrary types of contents. The type of the contents can be selected
when the data structure is constructed, by passing a particular subclass
of the abstract container to the constructor.

Extensions to the abstract type must implement the procedure
`typeguard`, which tests that variables being passed to the
container or to which the container's contents are assigned are of the
correct type. An example of a concrete implementation to hold a user-defined
derived type is provided below.

```fortran
module example_container_mod

  use abstract_container_mod
  implicit none
  private

  type example
    integer, public :: i
  end type example

  type, extends(container_type) :: example_container
  contains
    private
    procedure :: typeguard => example_guard
  end type example_container

contains

  logical function example_guard(this, lhs) result(ret)
    class(example_container), intent(in) :: this
    class(*), intent(inout) :: lhs
    select type(lhs)
      type is(example)
        lhs = transfer(this%contents(), lhs)
        ret = .true.
      class default
        ret = .false.
    end select
  end function example_guard

end module example_container_mod
```

## Compiling
PolyCon is known to work with Gfortran 5.3.0 and ifort 16.0.1. The latter
requires the `-assume realloc_lhs` to be used. A makefile is provided which
calls `gfortran-5`. Static and shared libraries are compiled using `make static`
and `make shared`, respectively. The test program can be build using
`make test`. At present there is no facility to install the libraries on your
system.

## Documentation
In addition to the documentation in the README, the API is documented
using [FORD](https://github.com/cmacmackin/ford). This documentation can
be found in the `./doc` directory in the repository.

## License
This code is licensed under the GPLv3. More permissive licensing _may_ be
considered in future.
