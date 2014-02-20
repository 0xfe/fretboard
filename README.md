# Vex Fretboard

A JavaScript library for rendering guitar and bass fretboards.
Copyright (c) 2013 Mohit Muthanna Cheppudira.

## Prerequisites

CoffeeScript and PaperJS.

## Usage

Simply instantiate a `Vex.Fretboard.Div` passing in the selector of a `div`
element as the first parameter.

Call `build(code)` on the instance to draw. If `code` is specified, it must
be in the syntax described below. If `code` is not specified, the contents
of the `div` element are parsed.

## Fretboard Syntax

![Example](https://github.com/0xfe/fretboard/raw/master/img/example.png "Example")

The above fretboard was rendered with the following code:

    fretboard
    show frets=3,4,5 string=1
    show frets=3,4,5 string=2 color=red
    show fret=3 string=6 text=G
    show notes=10/1,10/2,9/3,9/4

Take a look at the [article on My VexFlow](http://my.vexflow.com/articles/119)
for usage and examples.

## MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

