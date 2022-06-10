class Holiday
  attr_reader :name_1, :date_1, :name_2, :date_2, :name_3, :date_3

  def initialize(data)
    @name_1 = data[0][:name]
    @date_1 = data[0][:date]
    @name_2 = data[1][:name]
    @date_2 = data[1][:date]
    @name_3 = data[2][:name]
    @date_3 = data[2][:date]
    # binding.pry
  end
end
