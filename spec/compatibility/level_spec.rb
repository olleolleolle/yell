require 'spec_helper'
require 'logger'

RSpec.describe 'backwards compatible level' do
  let(:level) { Yell::Level.new(:error) }
  let(:logger) { Logger.new($stdout) }

  before do
    logger.level = level
  end

  it 'formats out the level correctly' do
    expect(logger.level).to eq(level.to_i)
  end
end
