class Rubicon
  BIG_NUMBER = 100
  attr_reader :max_number, :matrix, :payload, :failed_number, :succeed_number, :succeed_logs

  # numberにより配置される兵士と巨人の数を可変としている
  # この実装ではSoldierとTitanと数は同数しか対応していない
  def initialize(number = 3, payload = 2)
    @max_number = number
    @payload    = payload
    @matrix     = set_up_matrix(number)
    @failed_number  = 0 # 試行回数
    @succeed_number = 0 # 成功した組み合わせ
    @succeed_logs   = []
  end

  def battery(s = 0, t = 0, log = '00,')
    to_right({ :log => log,
               :from => { :s => s, :t => t, }})
    print_succeed_log
  end

  def edit_params_to_left(battery_params)
    # 右岸到着時の巨人と兵士の人数の計算
    new_soldiers_number = battery_params[:from][:s] + battery_params[:to][:s]
    new_titans_number   = battery_params[:from][:t] + battery_params[:to][:t]

    return { :log  => overwrite_log({ :log => battery_params[:log],
                                      :soldier => new_soldiers_number, :titan => new_titans_number }),
             :from => { :s => new_soldiers_number, :t => new_titans_number },
             :new_comer => {:s => battery_params[:to][:s], :t => battery_params[:to][:t] } }
  end


  def edit_params_to_right(battery_params)
    # 左岸到着時の巨人と兵士の人数の計算
    new_soldiers_number = battery_params[:from][:s] - battery_params[:to][:s]
    new_titans_number   = battery_params[:from][:t] - battery_params[:to][:t]

    return { :log  => overwrite_log({ :log => battery_params[:log],
                                      :soldier => new_soldiers_number, :titan => new_titans_number }),
             :from => { :s => new_soldiers_number, :t => new_titans_number },
             :new_comer => {:s => battery_params[:to][:s], :t => battery_params[:to][:t] } }
  end

  def to_right(battery_params)
    # 右岸に向かうボートの乗員数は常に２人とする (2..2)なので。ボートがn人乗りなら(n..2)になる
    passengers_number = payload
    # 乗員数内の巨人と兵士の人数の組み合わせを試す
    passengers_number.downto(0) do |titans_passengers_number|
      soldiers_passenger_number = passengers_number - titans_passengers_number
      battery_params[:to]       = { :s => soldiers_passenger_number, :t => titans_passengers_number, }

      if is_ok_to_right?(battery_params) && # この人数は位置にして大丈夫か
          log_check?(battery_params)     && # 無限ループ防止
          landing?(battery_params)
        if cross_all?(battery_params)
          # 全員渡りきったので登録
          record_suceed_log(battery_params)
        else
          battery_params = edit_params_to_left(battery_params)
          to_left(battery_params)
        end
      else
        failed
      end
    end
  end

  def to_left(battery_params)
    1.upto(@payload) do |passengers_number|
      passengers_number.downto(0) do |titans_passengers_number|
        soldiers_passenger_number = passengers_number - titans_passengers_number
        battery_params[:to] = { :s => soldiers_passenger_number, :t => titans_passengers_number }

        if is_ok_to_left?(battery_params) &&
           landing?(battery_params)

          battery_retry(battery_params)
        else
          failed
        end
      end
    end
  end

  def battery_retry(battery_params)
    new_battery_params = edit_params_to_right(battery_params)
    to_right(new_battery_params)
  end

  # さっき船で来た人数と同じ人数がそのまま船で対岸に戻っていかないか？
  # これをしないと無限ループになる
  def landing?(battery_params)
    !(battery_params[:new_comer] &&
      battery_params[:new_comer][:s] == battery_params[:to][:s] &&
      battery_params[:new_comer][:t] == battery_params[:to][:t])
  end

  # 全員が渡れる組み合わせを記録
  def record_suceed_log(battery_params)
    succeed
    @succeed_logs << add_last_log(battery_params)
  end

  # 右岸に着いたときのログの追加
  def add_last_log(battery_params)
    overwrite_log({ :log => battery_params[:log],
                    :soldier => battery_params[:from][:s] + battery_params[:to][:s],
                    :titan => battery_params[:from][:t] + battery_params[:to][:t]})
  end

  def print_succeed_log
    puts "#{try_number}通り試行し、#{succeed_number}通りのパターンがあることを発見しました。"
    number = 1
    succeed_logs.each do |succeed_log|
      print_tracs(number, succeed_log)
      number + 1
    end
  end

  def print_tracs(number, succeed_log)
    puts "解答#{number}"
    succeed_log.split(',').map do |turn_log|
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

  # 配置(s, t)にしたとき食べられないか
  def is_ok?(s, t)
    in_range?(t) && in_range?(s) && matrix[s][t] == 1
  end

  def is_ok_to_right?(battery_params)
    is_ok?(battery_params[:from][:s] + battery_params[:to][:s],
           battery_params[:from][:t] + battery_params[:to][:t])
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
                    :log     => battery_params[:log] }).split(',')[-1]
  end

  def record_in_left(battery_params)
    overwrite_log({ :soldier => battery_params[:from][:s] - battery_params[:to][:s],
                    :titan   => battery_params[:from][:t] - battery_params[:to][:t],
                    :log     => battery_params[:log] }).split(',')[-1]
  end

  def in_range?(number)
    number >= 0 && number <= max_number
  end

  def overwrite_log(params)
    params[:log] + generate_log(params[:titan], params[:soldier])
  end

  def failed
    @failed_number += 1
  end

  def succeed
    @succeed_number += 1
  end

  def try_number
    failed_number + succeed_number
  end

  # matrix上に人数配置ごとの兵士が食べられるときと食べられないときをプロットする
  # matrix において右岸の兵士と巨人がそれぞれx人とy人だったとき、
  # 座標(x,y) = 1なら兵士は巨人に食べられないので、移動できる
  # 座標(x,y) = 0なら兵士は巨人に食べられるので、移動できない
  def set_up_matrix(matrix_size)
    matrix = []
    0.upto(matrix_size) {|soldiers| matrix << set_up_row(soldiers) }
    matrix
  end

  def set_up_row(soldiers)
    row = []
    0.upto(max_number) {|titans| row << set_up_cell(soldiers, titans) }
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
end
puts "=========================================="
rubicon = Rubicon.new
rubicon.battery(0, 0, "00,")
puts "=========================================="
puts "=========================================="
puts "=========================================="
puts "=========================================="
