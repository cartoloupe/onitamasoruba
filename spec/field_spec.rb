require 'spec_helper'
require 'field'
require 'helper'

RSpec.describe Field do
  let(:span) { 2 }
  subject { described_class.new(stringified_position) }

  it "initializes from a string" do
    expect(stringified_position.length).to eq 301
    expect(subject.position.flatten).to eq starting_position
    expect(subject.bmovement.flatten.join).to eq [movement3, movement4].flatten.join
    expect(subject.mmovement.to_s).to eq [movement3].flatten.join
    expect(subject.wmovement.flatten.join).to eq [movement4, movement3].flatten.join
  end

  it "stringifies" do
    expect(subject.to_s).to eq stringified_position
  end

  it "knows number of pieces" do
    expect(subject.send(:nb)).to be_a Fixnum
  end

  it "knows score" do
    expect(subject.score(subject.color)).to be_a Float
  end

  it "can convert movement into vectors" do
    expect(subject.send(:vectorify, subject.bmovement.first, /kk/)).to be_an Array
  end

  context "understanding pieces" do
    it "can vectorize pieces" do
      expect(subject.bpieces).to be_an Array
      expect(subject.bpieces).to all( be_a Piece )
      expect(
        subject.bpieces.map(&:coordinates)
      ).to eq [[4, 0], [4, 1], [4, 2], [4, 3], [4, 4]]
    end
  end

  describe "#moves" do
    it "knows possible moves" do
      expect(subject.moves).to be_an Array
      expect(subject.moves).to all( be_a Move )
    end

    describe "#valid_moves" do
      it "can organize moves in a lookup" do
        expect(subject.valid_moves).to be_an Hash
      end
    end
  end

  context "when evaluating moves" do
    let(:span) { 2 }
    it "knows illegal moves due to out of bounds" do
      putsd movement1
      putsd starting_position
      expect(subject.moves).to be_an Array
      expect(subject.moves).to satisfy do |moves|
        moves.all? do |move|
          move.destination.x <= 2*span && move.destination.x >= 0
          move.destination.y <= 2*span && move.destination.y >= 0
        end
      end
    end

    it "knows illegal moves due to self-capture" do
      puts subject.bpieces
      expect(subject.moves).to satisfy do |moves|
        !moves.any? do |move|
          subject.bpieces.include? move.destination
        end
      end
      puts subject.moves
    end

    it "knows black score and white score" do
      expect(subject.score(:black)).to be_a Float
      expect(subject.score(:white)).to be_a Float
    end
  end

  describe "making moves" do
    it "making a move updates the field" do
      puts "pieces:"
      puts subject.bpieces
      puts "moves:"
      puts subject.moves
      move = subject.moves.first
      puts move
      putsd subject.position
      subject.make *move.to_splat
      putsd subject.position
    end

    it "moves can be evaluated before making them" do
      move = subject.moves.first
      subject.make *move.to_splat
      expect(subject.evaluate1 move).to be_a Float
    end

    context "when multiple possible moves with same score" do
      it "will choose a move among them randomly" do
        expect(subject.make_a_move!).to be_a Move
      end
    end

    it "keeps track of whose turn it is" do
      expect(subject.turn).to be_a Fixnum
      expect{subject.make_a_move!}.to change {subject.turn}
      expect{subject.make_a_move!}.to change {subject.turn}
    end

    it "rotates movements" do
      expect{subject.make_a_move!}.to change {subject.movements}
    end

    context "playing the game by itself" do
      it "will reach an end state" do
        4.times do
          r = subject.make_a_move!
          unless r.nil?
            putsd subject.position
            puts "black score: #{subject.score(:black)}"
            puts "white score: #{subject.score(:white)}"
          end
        end
      end
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
  let(:movement3) {
    %w(
      -- -- -- -- --
      -- kk kk kk --
      -- -- cs -- --
      -- -- -- -- --
      -- -- -- -- --
    )
  }
  let(:movement4) {
    %w(
      -- -- kk -- --
      -- -- kk -- --
      -- -- cs -- --
      -- -- -- -- --
      -- -- -- -- --
    )
  }
  let(:bmovement) { [movement3, movement4] }
  let(:mmovement) { [movement3] }
  let(:wmovement) { [movement4, movement3] }
  let(:movements) { [bmovement, mmovement, wmovement] }
  let(:turn) { 0 }
  let(:stringified_position) do
    [starting_position, movements, turn].flatten.join
  end
end
