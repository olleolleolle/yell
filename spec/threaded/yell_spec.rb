require 'spec_helper'

describe 'running Yell multi-threaded' do
  let!(:threads) { 100 }
  let!(:range) { (1..threads) }

  let!(:filename) { fixture_path.join('threaded.log') }
  let(:lines) { `wc -l #{filename}`.to_i }

  context 'one instance, same file' do
    before do
      logger = Yell.new(filename)

      range.map do |count|
        Thread.new { 10.times { logger.info(count) } }
      end.each(&:join)
    end

    it 'should write all messages' do
      lines.should == 10 * threads
    end
  end

  # context "one instance per thread" do
  #   before do
  #     range.map do |count|
  #       Thread.new do
  #         logger = Yell.new( filename )

  #         10.times { logger.info count }
  #       end
  #     end.each(&:join)

  #     sleep 0.5
  #   end

  #   it "should write all messages" do
  #     lines.should == 10*threads
  #   end
  # end

  context 'one instance in the repository, same file' do
    before do
      Yell['threaded'] = Yell.new(filename)
    end

    it 'should write all messages' do
      range.map do |count|
        Thread.new { 10.times { Yell['threaded'].info(count) } }
      end.each(&:join)

      lines.should == 10 * threads
    end
  end

  context 'multiple instances, datefile with rollover' do
    let(:keep_count) { 2 }
    let(:threadlist) { [] }
    let(:date) { Time.new(1212, 12, 12, 12) }

    before do
      Timecop.freeze(date - 86_400)

      range.each do |_count|
        threadlist << Thread.new do
          logger = Yell.new(:datefile, filename, symlink: false, keep: keep_count)
          loop { logger.info :info; sleep 0.01 }
        end
      end

      sleep 0.2 # sleep to get some messages into the file
    end

    after do
      threadlist.each(&:kill)
    end

    it 'should safely rollover' do
      # now cycle the days
      7.times do |count|
        Timecop.freeze(date + 86_400 * count)
        sleep 0.2

        expect(Dir[fixture_path.join('*.log')].size).to eq(keep_count)
      end
    end
  end

  private

  def datefile_pattern_for(time)
    time.strftime(Yell::Adapters::Datefile::DefaultDatePattern)
  end
end
