class Coast
  attr_reader :max_number, :matrix, :payload, :fail_log

  # numberにより配置される兵士と巨人の数を可変としている
  # この実装ではSoldierとTitanと数は同数しか対応していない
  def initialize(number = 3, payload = 2)
    @max_number = number
    @matrix     = set_up_matrix(number)
    @payload    = payload
    @left_titans_number   = 0
    @left_soldiers_number = 0
    @fail_log = []
  end

=begin
【左向き】
1. payload(乗客数) を決める
2. 人数比(titanの人数を決める)
3. その人数を載せて運行して大丈夫か？(t, s)==1か？チェック
   is_ok?
4. 記録取る
5. 運ぶ
【右向き】
1. payload(乗客数) を決める
2. 人数比(titanの人数を決める)
3. その人数を載せて運行して大丈夫か？(t, s)==1か？チェック
   is_ok?
4. 左岸到着時の位置は往復前に比べて前進しているか？
   anyone_to_right?
5. 記録取る
6. 運ぶ
=end
  def battery(t, s, log)

  end

  def to_right_first(battery_params)
    to_right(battery_params)
  end
  def to_right(battery_params)
    # 右岸に向かうボートの乗員数は常に２人とする
    passengers_number = payload
    # 乗員数内の巨人と兵士の人数の組み合わせを試す
    passengers_number.downto(0) do |titans_passengers_number|
      soldiers_passenger_number = passengers_number - titans_passengers_number

      battery_params[:to_right] = { :t => titans_passengers_number, :s => soldiers_passenger_number }

      if is_ok_to_right?(battery_params) &&
          any_to_right_in_right?(battery_params) &&
         log_check_to_left?(battery_params, titans_passengers_number, soldiers_passenger_number)
        if cross_all?(battery_params[:from][:t] + titans_passengers_number,
                      battery_params[:from][:s] + soldiers_passenger_number)
          # 全員渡りきったので表示処理
          battery_params[:to_right] = { :t => titans_passengers_number, :s => soldiers_passenger_number }
          print_log(battery_params)
        else
          edit_params_to_right(battery_params, titans_passengers_number, soldiers_passenger_number)
          to_left(battery_params)
        end
      else
        battery_params[:to_right] = { :t => titans_passengers_number, :s => soldiers_passenger_number }
        regist_fail_log(battery_params)
        puts "失敗"
      end
    end
  end

  def edit_params_to_right(battery_params, titans_passengers_number, soldiers_passenger_number)
    battery_params[:to_right] = { :t => titans_passengers_number, :s => soldiers_passenger_number }
    battery_params
  end

  def edit_params_for_recursive(battery_params)
    log = add_log(battery_params)
    # 往復後の巨人と兵士の人数の計算
    after_battery_titans   = battery_params[:from][:t] + battery_params[:to_right][:t] - battery_params[:to_left][:t]
    after_battery_soldiers = battery_params[:from][:s] + battery_params[:to_right][:s] - battery_params[:to_left][:s]

    return {:from => {:t => after_battery_titans, :s => after_battery_soldiers },
            :log => log }
  end

  def to_left(battery_params)
    1.upto(2) do |passengers_number|

    #1.upto(payload) do |passengers_number|
      passengers_number.downto(0) do |titans_passengers_number|
        soldiers_passenger_number = passengers_number - titans_passengers_number
        battery_params[:to_left] = { :t => titans_passengers_number, :s => soldiers_passenger_number }

        if counter_battery?(battery_params)
          battery_retry(battery_params)
        else
          regist_fail_log(battery_params)
          "失敗"
        end
      end
    end
  end

  def battery_retry(battery_params)
    new_battery_params = edit_params_for_recursive(battery_params)
    to_right(new_battery_params)
  end

  # 一往復で巨人か兵士か１人以上右岸に渡ったか？
  def counter_battery?(battery_params)
    # 「往復前の人数 + 右岸に渡った人数 - 左岸に渡った人数」で左岸にもどったときの人数配置を計算
    result =
        is_ok_to_left?(battery_params) &&
            log_check?(battery_params) &&
            any_to_right?(battery_params)
    result
  end

  def any_to_right?(battery_params)
    # 左岸にいるときに比較
    # 一往復で巨人か兵士か１人以上右岸に渡ったか？
    before_battery = battery_params[:log].split(',')[-1]
    after_battery  = add_log(battery_params).split(',')[-1]

    after_battery[0] > before_battery[0] || # 兵士が１人以上渡っている
    after_battery[1] > before_battery[1]    # 巨人が１人以上渡っている
  end

  def any_to_right_in_right?(battery_params)
    # 右岸にいるときに比較
    # 一往復で巨人か兵士か１人以上右岸に渡ったか？
    before_battery = battery_params[:log].split(',')[-2]
    after_battery  = add_log(battery_params).split(',')[-1]

    battery_params[:log].split(',').size < 2 ||
    after_battery[0] > before_battery[0] || # 兵士が１人以上渡っている
    after_battery[1] > before_battery[1]    # 巨人が１人以上渡っている
  end

  def add_log(battery_params)
    log =
        battery_params[:log] +
            # 往路で右岸についたときのログの追加
            generate_log(battery_params[:from][:t] + battery_params[:to_right][:t],
                         battery_params[:from][:s] + battery_params[:to_right][:s]) +
            (battery_params[:to_left].nil? ?
              "" :
              # 復路で左岸についたときのログの追加
              generate_log(battery_params[:from][:t] + battery_params[:to_right][:t] - battery_params[:to_left][:t],
                         battery_params[:from][:s] + battery_params[:to_right][:s] - battery_params[:to_left][:s]))
    log
  end

  def print_log(battery_params)
    puts "全員が渡河に成功しました"
    battery_params[:log].split(',').map do |tunr_log|
      number = tunr_log.split('')
      puts ('S' * (max_number - number[0].to_i) +
            'T' * (max_number - number[1].to_i) +
            '/' +
            'S' * number[0].to_i +
            'T' * number[1].to_i)
    end
    puts  "/" + 'S' * max_number + 'T' * max_number
  end

  def generate_log(t, s)
    "#{s}#{t},"
  end

  def write_log(point_log)
    point_log[:from][:s].to_s +
        point_log[:from][:t].to_s + ',' +
        point_log[:to][:s].to_s +
        point_log[:to][:t].to_s + ','
  end

  # (x,y)から右岸に向かう組み合わせはあるか？
  def ship?(t, s)
    result = false
    payload.downto(1) do |passenger_number|
      passenger_number.downto(0) do |titan_passenger_number|
        result ||= ship_to_right?(t + titan_passenger_number, s + (passenger_number - titan_passenger_number))
      end
    end
    result
  end

  # 右岸に行くとき配置(t,s)にして大丈夫か？
  def ship_to_right?(t, s)
    # 「(t, s)にいっても食べられないか」&&「(t, s)から帰れる場所はあるか」
    is_ok?(t, s) && ship_return_from?(t, s)
  end

  # 配置(x,y)から左岸に帰れる組み合わせはあるか？
  def ship_return_from?(t, s)
    result = false
    payload.downto(1) do |passenger_number|
      passenger_number.downto(0) do |titan_passenger_number|
        result ||= is_ok?(t - titan_passenger_number, s - (passenger_number - titan_passenger_number))
      end
    end
    result
  end

  def log_check_to_left?(battery_params, titans_passengers_number, soldiers_passenger_number)
    battery_params[:to_right] = { :t => titans_passengers_number, :s => soldiers_passenger_number }
    log = add_log(battery_params)
    return (log.length < 100) && fail_log.index(log).nil?
  end
  # この航路は前に試した航路か？
  def log_check?(battery_params)
    log = add_log(battery_params)
    return (log.length < 100) && fail_log.index(log).nil?
  end
  # 配置(t, s)にしたとき食べられないか
  def is_ok?(t, s)
    in_range?(t) && in_range?(s) && matrix[t][s] == 1
  end

  def is_ok_to_right?(battery_params)
    is_ok?(battery_params[:from][:t] + battery_params[:to_right][:t],
           battery_params[:from][:s] + battery_params[:to_right][:s])
  end

  def is_ok_to_left?(battery_params)
    is_ok?(battery_params[:from][:t] + battery_params[:to_right][:t] - battery_params[:to_left][:t],
           battery_params[:from][:s] + battery_params[:to_right][:s] - battery_params[:to_left][:s])
  end

  def cross_all?(t, s)
    t == max_number && s == max_number
  end

  #
  def in_range?(number)
    number >= 0 && number <= max_number
  end

  def ship_without_predation?(x, y)
    # 座標(t, s)のとき一往復で左岸から１人以上右岸に運ぶときの人数の変化は5通り
    # (t-1,s+1)はmatrixの組み合わせ上ありえない
    matrix[t + 2][s - 1] == 1 ||
    matrix[t + 1][s    ] == 1 ||
    matrix[t + 1][s - 1] == 1 ||
    matrix[t    ][s + 1] == 1 ||
    matrix[t - 1][s + 2] == 1
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

  def regist_fail_log(battery_params)
    @fail_log << add_log(battery_params)
  end
end
