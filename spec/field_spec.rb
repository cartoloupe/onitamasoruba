require_relative '../field.rb'
require_relative '../helper.rb'

RSpec.describe Field do
  let(:span) { 2 }
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
    expect(subject.send(:vectorify, subject.bmovement.first, /kk/)).to be_an Array
  end

  it "can vectorize pieces" do
    expect(subject.bpieces).to be_an Array
    expect(subject.bpieces).to all( be_a Vector )
  end

  it "knows possible moves" do
    expect(subject.bmoves).to be_an Array
    expect(subject.bmoves).to all( be_a Move )
  end

  context "when evaluating moves" do
    let(:span) { 2 }
    it "knows illegal moves due to out of bounds" do
      d movement1
      d starting_position
      puts subject.bmoves
      expect(subject.bmoves).to be_an Array
      expect(subject.bmoves).to satisfy do |bmoves|
        bmoves.all? do |move|
          move.destination.x <= span && move.destination.x >= -span
          move.destination.y <= span && move.destination.y >= -span
        end
      end
    end

    it "knows illegal moves due to self-capture" do
      puts subject.bpieces
      expect(subject.bmoves).to satisfy do |bmoves|
        !bmoves.any? do |move|
          subject.bpieces.include? move.destination
        end
      end
      puts subject.bmoves
    end
  end

  describe "making moves" do
    context "making moves" do
    end
    it "making a move updates the field" do
      puts subject.bpieces
      puts subject.bmoves
      move = subject.bmoves.first
      puts move
      d subject.position
      subject.make move
      d subject.position
    end
  end

  let(:starting_position) {
    %w(
      wc wc ws wc wc
      -- -- -- -- --
      -- -- -- -- --
      -- -- -- -- --
      bc bc bs bc bc
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
