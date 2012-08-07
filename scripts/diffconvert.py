#!/usr/bin/env python

# Copyright (C) 2012 Texas Instruments
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Author: James W. Mills <jameswmills@ti.com>
#
# Description: Parse the output of difftool.sh, converting the raw
# data into plain text, XML, or HTML.

import sys
import argparse
import re
import string
from xml.etree.ElementTree import Element, SubElement, Comment, tostring

if __name__ == "__main__":

  def indent(elem, level=0):
    i = "\n" + level*"  "
    if len(elem):
      if not elem.text or not elem.text.strip():
        elem.text = i + "  "
      if not elem.tail or not elem.tail.strip():
        elem.tail = i
      for elem in elem:
        indent(elem, level+1)
      if not elem.tail or not elem.tail.strip():
        elem.tail = i
    else:
      if level and (not elem.tail or not elem.tail.strip()):
        elem.tail = i
    return elem

  def populate_data(rdiff):
    data = {}
    project = None
    pline = re.compile('^Project ')
    dline = re.compile('#')
    for l in rdiff:
      if pline.match(l):
        project = l.split()[-1].strip()
        data[project] = []
      else:
        if not project:
          project = "kernel"
          data[project] = []
        cinfo = [x.strip().strip("'") for x in l.split('#') if x.strip().strip("'") != '']
        cdata = {}
        cdata['commit'] = cinfo[0]
        cdata['title'] = cinfo[1]
        cdata['date'] = cinfo[2]
        cdata['author'] = cinfo[3]
        data[project].append(cdata)
    return data

  def convert_to_xml(data):
    top = Element('ManifestDifferences')
    comment = Comment('Changes from %s' % (args.prev))
    top.append(comment)
    for k in data.keys():
      proj = SubElement(top, 'project')
      proj.text = k
      for cd in data[k]:
        ci = SubElement(proj, 'commit')
        commit_id = SubElement(ci, 'id')
        commit_id.text = cd['commit']
        commit_title = SubElement(ci, 'title')
        commit_title.text = cd['title']
        commit_date = SubElement(ci, 'date')
        commit_date.text = cd['date']
        commit_author = SubElement(ci, 'author')
        commit_author.text = cd['author']
    return top

  def convert_to_html_table(data):
    html_data = []
    html_data.append("<table width=80% align=center>")
    html_data.append("<tr bgcolor=%s><td align=center colspan=4><b>Changes from %s</b></td></tr>" % (args.first_color, args.prev))
    for k in data.keys():
      html_data.append("<tr bgcolor=%s><td colspan=4><b>Project: %s</b></td></tr>" % (args.first_color, k))
      for cd in data[k]:
        html_data.append("<tr bgcolor=%s>" % (args.second_color))
        html_data.append("<td>%s</td>" % (cd['commit']))
        html_data.append("<td>%s</td>" % (cd['title']))
        html_data.append("<td>%s</td>" % (cd['date']))
        html_data.append("<td>%s</td>" % (cd['author']))
        html_data.append("</tr>")
    html_data.append("</table>")
    return html_data

  def convert_to_text(data):
    text_data = []
    text_data.append("Changes from %s" % (args.prev))
    text_data.append("=" * len("Changes from %s" % (args.prev)))
    for k in data.keys():
      text_data.append("Project: %s:" % (k))
      for cd in data[k]:
        cl = ""
        cl += string.ljust(cd['commit'], 10)
        cl += string.ljust(cd['date'][:25].strip('+').strip('-'), 28)
        cl += string.ljust(cd['author'], 20)
        cl += cd['title']
        text_data.append(cl)
    return text_data

  parser = argparse.ArgumentParser(description='Convert manifest differences to various formats.')
  parser.add_argument(dest='filename', nargs='?', metavar='FILE', help='Files to convert')
  parser.add_argument('-t', '--type', type =str, choices=['text', 'xml', 'html'], help='Convert input to plaintext, HTML, or XML')
  parser.add_argument('-p', '--prev', default="Previous Manifest", help='Previous Manifest title')
  parser.add_argument('-fc', '--first-color', default="EEF3E2", help='Initial table row color')
  parser.add_argument('-sc', '--second-color', default="ffffff", help='Alternative table row color')
  args = parser.parse_args()

  try:
    rdiff = open(args.filename).readlines()
  except:
    print "Unable to open file: \"%s\".  Exiting." % (args.filename)
    parser.print_help()
    sys.exit(1)
  data = populate_data(rdiff)

  if "xml" in args.type:
    xml = convert_to_xml(data)
    indent(xml)
    print tostring(xml)
    sys.exit()
  elif "html" in args.type:
    fdata = convert_to_html_table(data)
    print '\n'.join(fdata)
    sys.exit()
  elif "text" in args.type:
    fdata = convert_to_text(data)
    print '\n'.join(fdata)
    sys.exit()
  else:
    parser.print_help()
    sys.exit()
