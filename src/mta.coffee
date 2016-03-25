# Original work Copyright (c) 2014 GitHub Inc.
# Modified work Copyright (c) 2016 Lucas Chi
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# Description:
#   See the status of NYC subways.
#
# Dependencies:
#   "xml2js": "0.1.14"
#
# Configuration:
#   None
#
# Commands:
#   hubot mta me <train> - the status of a nyc subway line
#
# Author:
#   jgv - original
#   lchi - updated

striptags = require('striptags')
xml2js = require('xml2js')

module.exports = (robot) ->
  robot.respond /mta\s*(?:me)?\s*(\w+)?/i, (response) ->
    mta response

mta = (response) ->
  response.http('http://web.mta.info/status/serviceStatus.txt')
    .get() (err, res, body) ->
      if err
        throw err

      parser = new xml2js.Parser({'explicitRoot' : 'service', 'normalize' : 'false' })
      parser.parseString body, (err, res) ->
        if err
          throw err

        requested_line = response.match[1]
        requested_line_re = new RegExp(requested_line, 'gi')
        for line in res.service.subway.line

          line_name = line.name
          if line_name.match(requested_line_re)

            response_string = "#{line_name} - #{line.status}"
            if typeof(line.Time) is "string"
              response_string += " (updated #{line.Time})"

            response.send response_string

            status_text = striptags(line.text).replace(/(&nbsp;)*\s*/g, ' ').trim()
            if status_text
              response.send "#{status_text}"
