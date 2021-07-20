### Warning

This is currently very hackish.
Code organization is not the best, and APIs might change without notice.
You might think of using this in production, but be warned that this might break.

# Forage

Dynamic ecto queries for ecto, with adapters for Plug applications.
It was inspired by Rummage, but with a different API.
It doesn't share any actual code.

## Installation

This package is available on [hex.pm](https://hex.pm/packages/forage).
It can be installed like any other hex package.

## Overview

This package is divided into two namespaces: `Forage` and `ForageWeb`.

If you're building a Phoenix application, the `Forage` namespace is something which you want use in your contexts, while the `ForageWeb` is something which you'll want to use in your views (`ForageWeb.ForageView`) and controllers (`ForageWeb.ForageController`).

### Forage

The `Forage` namespace contains the query generator, which converts maps in a certain format into ecto queries at runtime in a safe way (i.e., it can't be used to attack the BEAM).

This can be useful to generate dynamic ecto queries from request `params` inside a Plug (or Phoenix) application.

However, the functions in the `Forage` namespace are independent of Plug, and can be used anywhere you might need to build a dynamic Ecto query.

### ForageWeb

The `ForageWeb` namespace contains utilities to integrate with Plug applications.
It contains form input widgets which can be used to build filters, pagination widgets and sort links.
These input widgets are built in a way such that when the request is parsed by Plug, the `params` map will be compatible with the query builders in the `Forage` namespace.

Currently this package is used by the [mandarin](https://github.com/tmbb/mandarin). package.

## Features

`Forage` supports:

1. Search filter, i.e. Ecto queries with `where` clauses
2. Sorting, i.e. Ecto queries with an `order_by` clause
3. Pagination, using the [paginator](https://github.com/duffelhq/paginator) package,
   for cursor-based pagination.
   This approach is more efficient than the more common offset-based pagination.
   [Thhe links here](https://github.com/duffelhq/paginator#learn-more)
   go over the main differences.

## Usage

TODO

## Contributing

Pull requests (both code and documentation are appreciated)

## Roadmap

1. Add tests
2. Add a richer set of widgets where it makes sense
3. Decide on how to package the javascript code on the frontend
4. Support the SQL `or` operators. Currently only the `and` operator is supported.