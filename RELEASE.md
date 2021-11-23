RELEASE_TYPE: minor

Main changes were:

* Complete refactor - many parameter changes throughout the code;
  In many places, optional arguments of the form `opts \\ []` were made
  into required arguments to avoid having many functions with multiple arities

* Documentation coverage was improved - pretty much all functions now have
  a `@doc` attribute, even if it0s only a placeholder

* Better integration with PostgreSQL search

This should be considered *pre-1.0* version: the API is not expected to change
in the v1.0 version.
Some very important issues remain before being able to release v1.0:

* **Testing**: testing coverage is pretty much non-existing.
  Tests only cover parameter encoding and decoding.
  View code isn't tested at all.
  Query generation isn't tested either.

* **Documentation**: documentation coverage isn't very good either.
  Before v1.0, all functions should have usable documentation
  and at least one usage example.


