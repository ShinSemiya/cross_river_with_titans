require_relative 'rubicon.rb'
class LoadMaster
  def initialize
    @payload = 2
    @rubicon = Rubicon.new
    to_right(0, 0)
  end

  # t,s は現在地
  def to_right(t, s)
    puts "to_right"
    # payload
#    load_plannning(t,s,2)
    2.downto(1) do |payload|
      load_plannning(t,s,payload)
    end
  end

  def load_plannning(t,s,passenger_number)
    #puts "load_plannning"
#    (0..passenger_number).each do |titan_passengers|
    0.upto(passenger_number) do |titan_passengers|
      soldier_passengers = passenger_number - titan_passengers
      if @rubicon.port?(t + titan_passengers, s + soldier_passengers)
        @rubicon.ship(t + titan_passengers, s + soldier_passengers)
        puts @rubicon.log
        hash = {:from => { :t => (t + titan_passengers), :s => (s + soldier_passengers) }}
        to_left(t + titan_passengers, s + soldier_passengers, hash)
      end
    end
  end

  # t,s は現在地
  def to_left(t, s, hash)
    puts "to_left"
    # payload
    1.upto(2) do |payload|
      load_plannning_to_left(t,s,payload, hash)
    end
  end

  def load_plannning_to_left(t,s,passenger_number, hash)
#    (0..passenger_number).each do |titan_passengers|
    0.upto(passenger_number) do |titan_passengers|
      soldier_passengers = passenger_number - titan_passengers
      if @rubicon.port?(t - titan_passengers, s - soldier_passengers)
        zenshin_hash = Hash.new
        zenshin_hash[:from] = hash[:from]
        zenshin_hash[:to]   = { :t => t - titan_passengers, :s => s - soldier_passengers }
        if @rubicon.cross?(zenshin_hash)
          @rubicon.ship(t - titan_passengers, s - soldier_passengers)
          puts @rubicon.log
          to_right(t - titan_passengers, s - soldier_passengers)
        end
      end
    end
  end

end

