  def d(position)
    display = position.flatten.each_slice(5).map do |l|
      l.join("|")
    end

    puts "______________"
    puts display
    puts "^^^^^^^^^^^^^^"
    puts ""
  end


