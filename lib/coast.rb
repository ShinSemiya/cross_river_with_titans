=begin
【左向き】
1. payload(乗客数) を決める
2. 人数比(titanの人数)を決める
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
class Coast
  BIG_NUMBER = 100
  attr_reader :max_number, :matrix, :payload

  # numberにより配置される兵士と巨人の数を可変としている
  # この実装ではSoldierとTitanと数は同数しか対応していない
  def initialize(number = 3, payload = 2)
    @max_number = number
    @payload    = payload
    @matrix     = set_up_matrix(number)
    @try_number     = 0 # 試行回数
    @succeed_number = 0 # 成功した組み合わせ
  end

  def battery(s = 0, t = 0, log = '00,')
    to_right({ :log => log,
                     :from => { :s => s, :t => t, }})
  end

  def edit_params_to_left(battery_params)
    # 右岸到着時の巨人と兵士の人数の計算
    new_soldiers_number = battery_params[:from][:s] + battery_params[:to][:s]
    new_titans_number   = battery_params[:from][:t] + battery_params[:to][:t]

    log = battery_params[:log] + generate_log(new_titans_number, new_soldiers_number)

    return { :log  => log, :from => { :s => new_soldiers_number, :t => new_titans_number, } }
  end


  def edit_params_to_right(battery_params)
    # 左岸到着時の巨人と兵士の人数の計算
    after_battery_soldiers = battery_params[:from][:s] - battery_params[:to][:s]
    after_battery_titans   = battery_params[:from][:t] - battery_params[:to][:t]

    log = battery_params[:log] + generate_log(after_battery_titans, after_battery_soldiers)

    return {:log => log, :from => { :s => after_battery_soldiers, :t => after_battery_titans, },}
  end

  def to_right(battery_params)
    # 右岸に向かうボートの乗員数は常に２人とする
    passengers_number = payload
    # 乗員数内の巨人と兵士の人数の組み合わせを試す
    passengers_number.downto(0) do |titans_passengers_number|
      soldiers_passenger_number = passengers_number - titans_passengers_number
      battery_params[:to]       = { :s => soldiers_passenger_number, :t => titans_passengers_number, }

      if is_ok_to_right?(battery_params) && # この人数は位置にして大丈夫か
          log_check?(battery_params)     &&
          is_progress?(battery_params, record_in_right(battery_params)) # 一往復前と比較して前進しているか？


        if cross_all?(battery_params)
          # 全員渡りきったので表示処理
          print_suceed_log(battery_params)
        else
          battery_params = edit_params_to_left(battery_params)
          to_left(battery_params)
        end
      else
        #puts "失敗"
      end
    end
  end

  def to_left(battery_params)
    1.upto(@payload) do |passengers_number|
      passengers_number.downto(0) do |titans_passengers_number|
        soldiers_passenger_number = passengers_number - titans_passengers_number
        battery_params[:to] = { :s => soldiers_passenger_number, :t => titans_passengers_number }

        if is_ok_to_left?(battery_params) &&
           is_progress?(battery_params, record_in_left(battery_params))

          battery_retry(battery_params)
        else
          #puts "失敗"
        end
      end
    end
  end


  def battery_retry(battery_params)
    new_battery_params = edit_params_to_right(battery_params)
    to_right(new_battery_params)
  end

  def is_progress?(battery_params, now_position)
    # 右岸にいるときに比較
    # 一往復で巨人か兵士か１人以上右岸に渡ったか？
    before_battery = battery_params[:log].split(',')[-2]
    after_battery  = now_position
    battery_params[:log].split(',').size < 2 ||
        after_battery[0] > before_battery[0] || # 兵士が１人以上渡っている
        after_battery[1] > before_battery[1]    # 巨人が１人以上渡っている
  end


  def print_suceed_log(battery_params)
    print_tracs(add_last_log(battery_params))
  end

  # 右岸に着いたときのログの追加
  def add_last_log(battery_params)
    battery_params[:log] +
        generate_log(battery_params[:from][:s] + battery_params[:to][:s],
                     battery_params[:from][:t] + battery_params[:to][:t])
  end

  def print_tracs(log)
    puts "全員が渡河に成功しました"
    log.split(',').map do |turn_log|
      number = turn_log.split('')
      puts ('S' * (max_number - number[0].to_i) +
          'T' * (max_number - number[1].to_i) +
          '/' +
          'S' * number[0].to_i +
          'T' * number[1].to_i)
    end
  end

  def generate_log(t, s)
    "#{s}#{t},"
  end

  # 無限ループ予防措置
  def log_check?(battery_params)
    return (battery_params[:log].length < BIG_NUMBER)
  end

  # 配置(t, s)にしたとき食べられないか
  def is_ok?(s, t)
    in_range?(t) && in_range?(s) && matrix[t][s] == 1
  end

  def is_ok_to_right?(battery_params)
    is_ok?(battery_params[:from][:s] +
               battery_params[:to][:s],
           battery_params[:from][:t] +
               battery_params[:to][:t])
  end

  def is_ok_to_left?(battery_params)
    is_ok?(battery_params[:from][:s] - battery_params[:to][:s],
           battery_params[:from][:t] - battery_params[:to][:t])
  end

  def cross_all?(battery_params)
    (battery_params[:from][:s] + battery_params[:to][:s]) == max_number &&
    (battery_params[:from][:t] + battery_params[:to][:t]) == max_number
  end

  def record_in_right(battery_params)
    overwrite_log({ :soldier => battery_params[:from][:s] + battery_params[:to][:s],
                    :titan   => battery_params[:from][:t] + battery_params[:to][:t],
                    :log     =>battery_params[:log] }).split(',')[-1]
  end


  def record_in_left(battery_params)
    overwrite_log({ :soldier => battery_params[:from][:s] - battery_params[:to][:s],
                    :titan   => battery_params[:from][:t] - battery_params[:to][:t],
                    :log     =>battery_params[:log] }).split(',')[-1]
  end

  def in_range?(number)
    number >= 0 && number <= max_number
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

  def set_up_row(titans)
    row = []
    0.upto(max_number) {|soldiers| row << set_up_cell(soldiers, titans) }
    row
  end

  def set_up_cell(soldiers, titans)
    if soldiers == 0          || # 兵士が全員左岸にいる
       soldiers == max_number || # 兵士が全員右岸にいる
       soldiers == titans        # 両岸で兵士と巨人の人数が釣り合っている
      return 1
    end
    0
  end

  def overwrite_log(params)
    params[:log] + generate_log(params[:titan], params[:soldier])
  end
end
puts "=========================================="
rubicon =Coast.new
rubicon.battery(0, 0, "00,")
puts "=========================================="
puts "=========================================="
puts "=========================================="
puts "=========================================="
