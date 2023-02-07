class Offset < ActiveRecord::Base
  belongs_to :user
  belongs_to :team, optional: true
  belongs_to :region
  belongs_to :individual, optional: true
  validates_numericality_of :cost, :pounds

  COST_PER_POUND = 0.0125
  PROPANE_RATE = 12.17
  FUEL_OIL_RATE = 22.37
  NATURAL_GAS_RATE = 11
  ELECTRICITY_RATE = 0.7208
  LBS_CO2_PER_GALLON = 19.64
  MPG = 25
  MILES_PER_METER = 0.000621371
  AVERAGE_MONTHLY_HOME_ENERGY = 1240
  AVERAGE_MONTHLY_CAR_TRAVEL = 722
  AVERAGE_MONTHLY_DOMESTIC_AIR_TRAVEL = 42
  AVERAGE_YEARLY_INTERNATIONAL_AIR_TRAVEL = 105.66

  def self.from_air_travel(flights, travelers)
    offset_weight = 0
    flights.each do |miles|
      miles = miles.to_f
      offset_weight = if miles < 400
                        miles * 0.56
                      elsif miles < 1500
                        miles * 0.45
                      elsif miles < 3000
                        miles * 0.4
                      else
                        miles * 0.39
                      end
    end

    offset_weight *= travelers.to_i
    offset_cost = offset_weight * COST_PER_POUND

    { pounds_co2: offset_weight.round(2), cost: offset_cost.round(2) }
  end

  def self.from_car_travel(miles, mpg)
    gallons_gas = miles.to_f / mpg.to_f
    offset_weight = gallons_gas * LBS_CO2_PER_GALLON
    offset_cost = offset_weight * COST_PER_POUND
    { pounds_co2: offset_weight.round(2), cost: offset_cost.round(2) }
  end

  def self.from_home_energy(propane, natural_gas, fuel_oil, electricity)
    offset_weight = 0
    unless propane.nil?
      co2 = PROPANE_RATE * propane.to_f
      offset_weight += co2
    end
    unless natural_gas.nil?
      co2 = NATURAL_GAS_RATE * natural_gas.to_f
      offset_weight += co2
    end
    unless fuel_oil.nil?
      co2 = FUEL_OIL_RATE * fuel_oil.to_f
      offset_weight += co2
    end
    unless electricity.nil?
      co2 = ELECTRICITY_RATE * electricity.to_f
      offset_weight += co2
    end
    offset_cost = offset_weight * COST_PER_POUND
    { pounds_co2: offset_weight.round(2), cost: offset_cost.round(2) }
  end

  def self.from_quick_entry(offset_mode, months)
    case offset_mode
    when 'domestic-air-travel'
      offset_weight = AVERAGE_MONTHLY_DOMESTIC_AIR_TRAVEL * months.to_f
    when 'international-air-travel'
      offset_weight = AVERAGE_YEARLY_INTERNATIONAL_AIR_TRAVEL * months.to_f
    when 'car-travel'
      offset_weight = AVERAGE_MONTHLY_CAR_TRAVEL * months.to_f
    when 'home-energy'
      offset_weight = AVERAGE_MONTHLY_HOME_ENERGY * months.to_f
    end
    offset_cost = offset_weight * COST_PER_POUND
    { pounds_co2: offset_weight.round(2), cost: offset_cost.round(2) }
  end
end
