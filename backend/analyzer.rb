# encoding: UTF-8
require 'ferret'

text = 'Estoy *muy* convencido que esto te castigará'

class MyAnalyzer
  def initialize(do_stem)
    @do_stem = do_stem
  end

  def token_stream(field, str)
    ts = Ferret::Analysis::StandardTokenizer.new(str)
    ts = Ferret::Analysis::LowerCaseFilter.new(ts)
#    ts = Ferret::Analysis::StopFilter.new(ts,
#       Ferret::Analysis::FULL_SPANISH_STOP_WORDS)
    ts = Ferret::Analysis::HyphenFilter.new(ts)
    ts = Ferret::Analysis::StemFilter.new(ts, "spanish") if @do_stem
    ts
  end
end

#analyzer = MyAnalyzer.new
#token_stream = analyzer.token_stream(:lyrics, text)
#while token = token_stream.next
#  puts token.text
#end
