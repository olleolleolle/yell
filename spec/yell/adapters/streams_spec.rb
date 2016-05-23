require 'spec_helper'

RSpec.describe Yell::Adapters::Stdout do
  it { is_expected.to be_kind_of(Yell::Adapters::Io) }

  context '#stream' do
    subject { Yell::Adapters::Stdout.new.send(:stream) }

    it { is_expected.to be_kind_of(IO) }
  end
end

RSpec.describe Yell::Adapters::Stderr do
  it { is_expected.to be_kind_of(Yell::Adapters::Io) }

  context '#stream' do
    subject { Yell::Adapters::Stderr.new.send(:stream) }

    it { is_expected.to be_kind_of(IO) }
  end
end
