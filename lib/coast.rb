class Coast
  attr_reader :max_number, :matrix

  # numberにより配置される兵士と巨人の数を可変としている
  # この実装ではSoldierとTitanと数は同数しか対応していない
  def initialize(number = 3)
    @max_number = number
    @matrix     = set_up_matrix(number)
  end

  def ship_without_predation?(x, y)
    # 座標(x, y)のとき一往復で左岸から１人以上右岸に運ぶときの人数の変化は5通り
    # (x+1,y-1)はmatrixの組み合わせ上ありえない
    matrix[x + 2, y - 1] == 1 ||
    matrix[x + 1, y    ] == 1 ||
    matrix[x    , y + 1] == 1 ||
    matrix[x - 1, y + 1] == 1 ||
    matrix[x - 1, y + 2] == 1
  end

  # matrix上に人数配置ごとの兵士が食べられるときと食べられないときをプロットする
  # matrix において右岸の兵士と巨人がそれぞれx人とy人だったとき、
  # 座標(x,y) = 1なら兵士は巨人に食べられないので、移動できる
  # 座標(x,y) = 0なら兵士は巨人に食べられるので、移動できない
  def set_up_matrix(matrix_size)
    matrix = []
    0.upto(matrix_size) {|y| matrix << set_up_row(y) }
    matrix
  end

  def set_up_row(y)
    row = []
    0.upto(max_number) {|x| row << set_up_cell(x, y) }
    row
  end

  def set_up_cell(x, y)
    if y == 0 ||          # 巨人が全員左岸にいる
       y == max_number || # 巨人が全員右岸にいる
       y == x             # 両岸で兵士と巨人の人数が釣り合っている
      return 1
    end
    0
  end
end