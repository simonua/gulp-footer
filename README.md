gulp-footer
===========

Gulp extension to add a footer to file(s) in the pipeline

    var footer = require('gulp-footer');

Structure
---------

* `footer` = function([footerText], [options])
  * `footerText` string optional
    * The text to use for the footer to be prepended to the files in the stream.
    * Will be formatted against the markdown processor, and passed an options object with the following fields added
      * `filename` - the name of the file being added
      * `now` - ISO-8601 formatted datetime
      * `year` - the current year
  * `options` object optional
    * `file` string optional
      * a file to use for the footerText, if footerText isn't specified
    * other parameters will be passed through to the markdown processor against `footerText`

Example
-------
    var footer = require('gulp-footer');
    var gc = require('gulp-concat');
    //footer = function([footerText], [options]);
    
    ...footerText from string...
    var footerText = '' +
        '/*! {{filename}} - '+
        'Copyright {{year}} MyCompany - '+
        'MIT License - '+
        'generated {{now}} - {{foo}} */'+
        '';
    gulp.src('./lib/*.js')
        .pipe(gc('merged.js'))
        .pipe(footer(footerText, {foo:'bar'}))
        .pipe(gulp.dest('./dist/')
    
    ...options - footerText from file...
    gulp.src('./lib/*.js')
        .pipe(gc('merged.js'))
        .pipe(footer({
            file:__dirname + '/text/footer.txt'
            ,foo:'bar'
        }))
        .pipe(gulp.dest('./dist/')

Testing
-------

Unit Tests

    npm test

Code Coverage

    npm run-script coverage


License
-------

The MIT License (MIT)

Copyright (c) 2013 GoDaddy.com

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
