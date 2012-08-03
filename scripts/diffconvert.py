#!/usr/bin/env python

import sys
import argparse
import re
import string

if __name__ == "__main__":

  def populate_data(rdiff):
    data = {}
    pline = re.compile('^Project ')
    dline = re.compile('#')
    for l in rdiff:
      if pline.match(l):
        project = l.split()[-1].strip()
        data[project] = []
      else:
        cinfo = [x.strip().strip("'") for x in l.split('#') if x.strip().strip("'") != '']
        cdata = {}
        cdata['commit'] = cinfo[0]
        cdata['title'] = cinfo[1]
        cdata['date'] = cinfo[2]
        cdata['author'] = cinfo[3]
        data[project].append(cdata)
    return data

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
    print "I wiould do XML"
  elif "html" in args.type:
    fdata = convert_to_html_table(data)
  elif "text" in args.type:
    fdata = convert_to_text(data)
  else:
    parser.print_help()
    sys.exit()
  print '\n'.join(fdata)
