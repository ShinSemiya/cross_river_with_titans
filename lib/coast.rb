class Coast
  attr_reader :max_number, :matrix

  # numberにより配置される兵士と巨人の数を可変としている
  # この実装ではSoldierとTitanと数は同数しか対応していない
  def initialize(number = 3)
    @max_number = number
    @matrix     = set_up_matrix(number)
  end

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
    if y == 0 ||
       y == max_number ||
       y == x
      return 1
    end
    0
  end
end