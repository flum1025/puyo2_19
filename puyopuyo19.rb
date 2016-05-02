#人材募集企画 2011年版: 人生を書き換える者すらいた。 [http://okajima.air-nifty.com/b/2011/01/2011-ffac.html]

class PuyoPuyo
  attr_accessor :board
  attr_reader :width, :height
  def initialize(board)
    arr = []
    board.each_line do |line|
      arr << line.chomp.split("")
    end
    @board = arr
    @width = @board[0].size
    @height = @board.size
    @elms = []
  end
  
  def board_text
    @board.map{|line|line.join}.join("\n")
  end
  
  def adjacent(i,j)
    {
#      left: j.zero? ? nil: @board[i][j-1],
      right: j+1 == @width ? nil : @board[i][j+1],
      up: i-1 < 0 ? nil : @board[i-1][j],
      down: @height-(i+1) == 0 ? nil : @board[i+1][j]
    }
  end
  
  def search(i,j)
    elm = @board[i][j]
    return [] if elm == " "
    return [] if @elms.include?([i,j])
    @elms << [i,j]
    adj = adjacent(i,j)
    adj.each do |k,v|
      unless elm == v
        next
      end
      case k
      when :right
        search(i,j+1)
      when :down
        search(i+1,j)
      when :up
        search(i-1,j) unless (i-1).zero?
      end
    end
    @elms
  end
  
  def pack
    loop do
      arr = Array.new(@height){Array.new(@width){" "}}
      @board.each_with_index do |line, i|
        line.each_with_index do |elm, j|
          if i+1 == @height
            arr[i][j] = elm if arr[i][j] == " "
          else
            if @board[i+1][j] == " "
              arr[i+1][j] = elm
            elsif arr[i][j] == " "
              arr[i][j] = elm
            end
          end
        end
      end
      break if @board == arr
      @board = arr
    end
  end
  
  def forward
    count = 0
    catch(:exit) do
      @board.each_with_index do |line, i|
        line.each_with_index do |elm, j|
          elms = search(i,j)
          if elms.size >= 4
            elms.each do |e1, e2|
              @board[e1][e2] = " "
            end
            @elms = []
            throw :exit
          end
          @elms = []
        end
      end
    end
    pack
  end
end

board = <<EOF
  GYRR
RYYGYG
GYGYRR
RYGYRG
YGYRYG
GYRYRG
YGYRYR
YGYRYR
YRRGRG
RYGYGG
GRYGYR
GRYGYR
GRYGYR
EOF
#board = <<EOF
#GGR
#YGG
#EOF
puyo2 = PuyoPuyo.new board
puts puyo2.board_text
puts "combo: 0"
puts '------------'
puts
i = 0
loop do
  i += 1
  puyo2.forward
  puts puyo2.board_text
  puts "combo: #{i}"
  puts '------------'
  puts
  break if puyo2.board.last.uniq.size == 1 && puyo2.board.last.uniq.first == " "
end
