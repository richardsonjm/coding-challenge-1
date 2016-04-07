#!/usr/bin/env ruby
require 'JSON'

class AverageDegree
  def initialize(source, destination, time)
    @source = File.read(source)
    @destination = File.open(destination, 'w')
    @time = time
    @tweets = []
    @edges = []
    @nodes = []
    @current_avg = 0.to_s
  end

  def avg_degree(timestamp, hashtags)
    return if @tweets.any? && (timestamp < @tweets.last[0]) && (timestamp < (@tweets.first[0]))

    @tweets << [timestamp, hashtags]
    @tweets.sort_by {|tweet| tweet[0]}
    if (hashtags.count > 1) && (timestamp < (@tweets.first[0] + @time))
      add_hashtags_to_nodes_and_edges(hashtags)
      @current_avg = (@edges.count/@nodes.count.to_f).round(2).to_s
      @destination.write(@current_avg + "\n")
    elsif timestamp < (@tweets.first[0] + @time)
      @destination.write(@current_avg + "\n")
    else
      while timestamp >= (@tweets.first[0] + @time)
        @tweets.shift
      end
      @tweets.pop
      reset_nodes_and_edges
      avg_degree(timestamp, hashtags)
    end
  end

  def reset_nodes_and_edges
    @edges = []
    @node = []
    @tweets.each do |tweet|
      add_hashtags_to_nodes_and_edges(tweet[1])
    end
  end

  def add_hashtags_to_nodes_and_edges(hashtags)
    hashtags.each_with_index do |hashtag, index|
      return unless hashtags[index + 1]
      edge = [hashtags[index], hashtags[index + 1]]
      if !@edges.include?(edge) && !@edges.include?(edge.reverse)
        @edges.concat(edge)
      end
      @nodes << hashtag unless @nodes.include? hashtag
    end
  end

  def run
    @source.each_line do |line|
      line = JSON.parse(line)
      return unless line['entities']
      date_string = line['created_at']
      timestamp = DateTime.strptime(date_string, "%a %b %d %k:%M:%S %z %Y")
      hashtags = line['entities']['hashtags'].map{|hash| hash['text'] }
      avg_degree(timestamp, hashtags)
    end
  end
end

AverageDegree.new('./tweet_input/tweets.txt', './tweet_output/output.txt', 60).run
