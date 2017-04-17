# package-cmark

CommonMark parsing and rendering library and program in C. <http://commonmark.org>

A secondary version `commonmark-gfm` is an [upstream-compatible fork](https://github.com/github/cmark) which includes “GitHub-flavored Markdown” enhancements. This fork is maintained by GitHub.

See <https://github.com/jgm/cmark/releases> for releases.

## Generating the RPM package

Edit the `Makefile` to ensure that you are setting the intended version, then run `make`.

```bash
make standard
make gfm
```
