class Coast
  attr_reader :max_number, :matrix

  # numberにより配置される兵士と巨人の数を可変としている
  # この実装ではSoldierとTitanと数は同数しか対応していない
  def initialize(number = 3)
    @max_number = 3
    @matrix     = set_up_matrix(number)
  end

  def set_up_matrix(max_number)
    []
  end
end