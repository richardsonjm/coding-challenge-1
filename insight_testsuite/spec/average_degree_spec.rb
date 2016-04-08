require_relative './spec_helper.rb'

describe AverageDegree do
  before do
    allow(File).to receive(:read)
    allow(File).to receive(:open)
    @average_degree = AverageDegree.new('source', 'destination', 60)
    @average_degree.instance_variable_set(:@time, 60)
  end

  subject { @average_degree }

  describe "#tweet_within_timeframe?" do
    before do
      tweets = [[DateTime.now, ['foo', 'bar']]]
      subject.instance_variable_set(:@tweets, tweets)
    end

    it "return true when tweets is within timeframe" do
      expect(subject.tweet_within_timeframe?(DateTime.now + 15)).to eq true
    end

    it "return false when tweets is outside timeframe" do
      expect(subject.tweet_within_timeframe?(DateTime.now + 61)).to eq false
    end
  end

  describe "#calculate_current_average" do
    it "divides total number of edges for each node by total nodes" do
      subject.instance_variable_set(:@nodes, %w(foo bar baz moe mop))
      edges = [['foo','bar'],['foo','baz'],['bar','baz'],['moe','mop']]
      subject.instance_variable_set(:@edges, edges)
      subject.calculate_current_average
      p
      expect(subject.instance_variable_get(:@current_avg)).to eq '1.60'
    end
  end
end
