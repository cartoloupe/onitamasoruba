class AController < ApplicationController
  STARTING_POSITION=
    %w(
      wc wc ws wc wc
      -- -- -- -- --
      -- -- -- -- --
      -- -- -- -- --
      bc bc bs bc bc
    )
  MOVEMENT1=
    %w(
      -- -- -- -- --
      -- kk -- kk --
      kk -- cs -- kk
      -- -- -- -- --
      -- -- -- -- --
    )
  MOVEMENT2=
    %w(
      -- -- -- -- --
      -- -- kk -- --
      -- kk cs kk --
      -- -- kk -- --
      -- -- -- -- --
    )
  MOVEMENT3=
    %w(
      -- -- -- -- --
      -- kk kk kk --
      -- -- cs -- --
      -- -- -- -- --
      -- -- -- -- --
    )
  MOVEMENT4=
    %w(
      -- -- kk -- --
      -- -- kk -- --
      -- -- cs -- --
      -- -- -- -- --
      -- -- -- -- --
    )
  BMOVEMENT= [MOVEMENT3, MOVEMENT4]
  MMOVEMENT= [MOVEMENT3]
  WMOVEMENT= [MOVEMENT4, MOVEMENT3]
  MOVEMENTS= [BMOVEMENT, MMOVEMENT, WMOVEMENT]
  TURN=0
  STRINGIFIED_POSITION= [STARTING_POSITION, MOVEMENTS, TURN].flatten.join

  def welcome
    @field = Field.new(STRINGIFIED_POSITION)


  end
end
