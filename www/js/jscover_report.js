function run_jscover_report() {
  out = '';
  out += "<pre>\n";
  for (filename in _$jscoverage) {
    if (filename == 'branchData') continue;
    for (line_num in _$jscoverage[filename]['source']) {
      var count = _$jscoverage[filename][parseInt(line_num) + 1];
      out += ((count == 0) ? "* " : "  ");
      out += (line_num);
      out += (_$jscoverage[filename]['source'][line_num]);
      out += ("\n");
    }
  }
  out += ("</pre>\n");
  return out;
}
