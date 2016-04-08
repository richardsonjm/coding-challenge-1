require_relative './spec_helper.rb'

describe AverageDegree do
  before do
    allow(File).to receive(:read)
    allow(File).to receive(:open)
    @average_degree = AverageDegree.new('source', 'destination', 60)
    @average_degree.instance_variable_set(:@time, 60)
  end

  subject { @average_degree }

  describe "#add_tweet_to_tweets_in_order" do
    before do
      @tweet1 = [DateTime.now, %w(foo bar)]
      @tweet2 = [DateTime.now + 30, %w(bar baz)]
      subject.instance_variable_set(:@tweets, [@tweet1, @tweet2])
    end

    it "adds tweet to tweets in correct order" do
      tweet3 = [DateTime.now + 15, %w(foo baz)]
      subject.add_tweet_to_tweets_in_order(tweet3[0], tweet3[1])
      tweets = subject.instance_variable_get(:@tweets)
      expect(tweets[0]).to eq @tweet1
      expect(tweets[2]).to eq @tweet2
      expect(tweets[1]).to eq tweet3
    end
  end

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
      expect(subject.instance_variable_get(:@current_avg)).to eq '1.60'
    end
  end
end
