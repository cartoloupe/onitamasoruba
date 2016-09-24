# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

if false
  b = jsboard.board({ attach: "board", size: "5x5"  });
  p = jsboard.piece({ text: "bs", fontSize: "40px", textAlign: "center"  });

  $("#game").data("position").forEach (d, i) ->
    x = Math.floor(i / 5)
    y = (i % 5)
    piece = p.clone()
    unless d == "--"
      piece.textContent = d
      b.cell([x,y]).place(piece);

  b.cell("each").on("click", -> beginMove(this))

  beginMove = (piece) ->
    console.log "beginMove2"
    b.cell("each").removeOn("click", -> beginMove(this))
    b.cell("each").on("click", -> movePiece())
    b.cell("each").style({"background-color": "green"});

    movePiece = () ->
      console.log "movePiece"
      #b.cell(this).place(piece);
      b.removeEvents("click", movePiece);
      #b.cell("each").style({"background-color": "gray"});

