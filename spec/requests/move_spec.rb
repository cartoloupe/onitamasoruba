require 'rails_helper'

RSpec.describe "moving", type: :request do
  let(:starting_position) {Field.default_starting_position}
  it 'accepts a move' do

    post '/a/welcome_move', \
      move: {
        piece_x: 1,
        piece_y: 3,
        destination_x: 1,
        destination_y: 3,
        movement: "TODO"
      },
      position: starting_position

    expect(response.body).to be_a String
    expect(response.body).to_not eq starting_position
    expect(response.status).to eq 200

  end
end
