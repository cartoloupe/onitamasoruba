require_relative '../field.rb'

RSpec.describe Field do
  subject { described_class.new(stringified_position) }

  it "initializes from a string" do
    expect(stringified_position.length).to eq 300
    expect(subject.position.flatten).to eq starting_position
    expect(subject.bmovement.flatten.join).to eq [movement1, movement2].flatten.join
    expect(subject.mmovement.flatten.join).to eq [movement1].flatten.join
    expect(subject.wmovement.flatten.join).to eq [movement1, movement2].flatten.join
  end

  it "stringifies" do
    expect(subject.to_s).to eq stringified_position
  end

  it "knows number of pieces" do
    expect(subject.send(:nb)).to eq 5
  end

  it "knows score" do
    expect(subject.score).to eq 0
  end

  it "can convert movement into vectors" do
    expect(subject.send(:vectorify, bmovement.first)).to be_an Array
  end

  it "can vectorize pieces" do
    expect(subject.bpieces).to be_an Array
  end

  it "knows possible moves" do
    expect(subject.bmoves).to be_an Array
  end

  let(:starting_position) {
    %w(
      bc bc bs bc bc
      -- -- -- -- --
      -- -- -- -- --
      -- -- -- -- --
      wc wc ws wc wc
    )
  }
  let(:movement1) {
    %w(
      -- -- -- -- --
      -- kk -- kk --
      kk -- cs -- kk
      -- -- -- -- --
      -- -- -- -- --
    )
  }
  let(:movement2) {
    %w(
      -- -- -- -- --
      -- -- kk -- --
      -- kk cs kk --
      -- -- kk -- --
      -- -- -- -- --
    )
  }
  let(:bmovement) { [movement1, movement2] }
  let(:mmovement) { [movement1] }
  let(:wmovement) { [movement1, movement2] }
  let(:movements) { [bmovement, mmovement, wmovement] }
  let(:stringified_position) do
    [starting_position, movements].flatten.join
  end
end
