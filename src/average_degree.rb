#!/usr/bin/env ruby
require 'JSON'
require 'date'

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
    return if @tweets.any? && (timestamp < (@tweets.first[0]))

    @tweets << [timestamp, hashtags]
    @tweets.sort_by {|tweet| tweet[0]}
    if (hashtags.count > 1) && tweet_within_timeframe?(timestamp)
      add_hashtags_to_nodes_and_edges(hashtags)
      calculate_current_average
      write_current_average
    elsif tweet_within_timeframe?(timestamp)
      write_current_average
    else
      while timestamp >= (@tweets.first[0] + @time)
        @tweets.shift
      end
      @tweets.pop
      reset_nodes_and_edges
      avg_degree(timestamp, hashtags)
    end
  end

  def tweet_within_timeframe?(timestamp)
    timestamp < (@tweets.first[0] + @time)
  end

  def write_current_average
    @destination.write(@current_avg + "\n")
  end

  def calculate_current_average
    node_edges = 0
    @nodes.each do |node|
      @edges.each do |edge|
        node_edges += 1 if edge.include? node
      end
    end
    @current_avg = "%.2f" % (node_edges/@nodes.count.to_f)
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
      i = 1
      while hashtags[index + i]
        edge = [hashtag, hashtags[index + i]]
        if !@edges.include?(edge) && !@edges.include?(edge.reverse)
          @edges << edge
        end
        i+=1
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
