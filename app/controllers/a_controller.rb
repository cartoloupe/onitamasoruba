require 'field'

class AController < ApplicationController

  def m
    redirect_to "/a/welcome/#{Field.default_starting_position}"
  end

  def welcome
    position = welcome_params[:id]
    @field = Field.new(position)
  end

  def welcome_move
    position = welcome_params[:position]
    move_as_parameters = [
      welcome_params[:move][:piece_x].to_i,
      welcome_params[:move][:piece_y].to_i,
      welcome_params[:move][:destination_x].to_i,
      welcome_params[:move][:destination_y].to_i,
      welcome_params[:move][:movement],
    ]

    @field = Field.new(position)
    @field.make *move_as_parameters

    render json: { position: @field.to_s }
  end

  def welcome_params
    params
      .permit(:id, :position, move: [
        :piece_x,
        :piece_y,
        :destination_x,
        :destination_y,
        :movement,
      ])
      #.require(:position)
  end
end
