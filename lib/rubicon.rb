require_relative 'boat.rb'
class Rubicon
  attr_reader :max_number, :matrix, :log

  # numberにより配置される兵士と巨人の数を可変としている
  # この実装ではSoldierとTitanと数は同数しか対応していない
  def initialize(number = 3, payload = 2)
    @max_number = number
    @matrix     = set_up_matrix(number)
    @boat = Boat.new(payload)
    @left_titans_number   = 0
    @left_soldiers_number = 0
    @point = {:t => 0, :s => 0}
    @log = ''
  end

  def move_to(t, s)
    if port?(t, s)
      ship(t, s)
      @log << "#{t}#{s},"
    end
  end

  def ship(titans, soldiers)
    @point[:t] = titans
    @point[:s] = soldiers
  end

  def port?(t, s)
    in_range?(t, s) && (@matrix[t][s] == 1)
  end

  def in_range?(t, s)
    (0..max_number).include?(t) && (0..max_number).include?(s)
  end

  # 一往復で巨人か兵士か１人以上右岸に渡ったか？
  def cross?(point)
    return (point[:from][:t] < point[:to][:t]) || (point[:from][:s] < point[:to][:s])
  end

  # matrix上に人数配置ごとの兵士が食べられるときと食べられないときをプロットする
  # matrix において右岸の兵士と巨人がそれぞれx人とy人だったとき、
  # 座標(x,y) = 1なら兵士は巨人に食べられないので、移動できる
  # 座標(x,y) = 0なら兵士は巨人に食べられるので、移動できない
  def set_up_matrix(matrix_size)
    matrix = []
    0.upto(matrix_size) {|t| matrix << set_up_row(t) }
    matrix
  end

  def set_up_row(t)
    row = []
    0.upto(max_number) {|s| row << set_up_cell(t, s) }
    row
  end

  def set_up_cell(t, s)
    if s == 0 ||          # 兵士が全員左岸にいる
        s == max_number || # 兵士が全員右岸にいる
        s == t             # 両岸で兵士と巨人の人数が釣り合っている
      return 1
    end
    0
  end
end
=begin
rubicon = Rubicon.new
rubicon.move_to(1, 1)
rubicon.move_to(1, 0)
rubicon.move_to(3, 0)
rubicon.move_to(2, 0)
rubicon.move_to(2, 2)
rubicon.move_to(1, 1)
rubicon.move_to(1, 3)
rubicon.move_to(3, 3)
puts "*-----log-------------"
puts rubicon.log
=end
