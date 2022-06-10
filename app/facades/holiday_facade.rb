class HolidayFacade

  def service
    HolidayService.new
  end

  def get_3_next_holidays
    Holiday.new(service.get_holidays)
  end


end
