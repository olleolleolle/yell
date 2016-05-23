require 'spec_helper'

RSpec.describe Yell::Configuration do
  describe '.load!' do
    let(:file) { fixture_path.join('yell.yml') }
    let(:config) { Yell::Configuration.load!(file) }

    subject { config }

    it { is_expected.to be_kind_of(Hash) }
    it { is_expected.to have_key(:level) }
    it { is_expected.to have_key(:adapters) }

    context ':level' do
      subject { config[:level] }

      it { is_expected.to eq('info') }
    end

    context ':adapters' do
      subject { config[:adapters] }

      it { is_expected.to be_kind_of(Array) }

      # stdout
      it { expect(subject.first).to eq(:stdout) }

      # stderr
      it { expect(subject.last).to be_kind_of(Hash) }
      it { expect(subject.last).to eq(stderr: { level: 'gte.error' }) }
    end
  end
end
