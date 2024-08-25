AREA = [-30, -59, -35, -53] #If we want to do the Salto Grande area we need to set the invervals to  [-26,-60,-36,-48]
YEARS = range(1980,2101)

from datetime import datetime, timedelta
import pandas as pd
import pvlib

def sun_position(time):
    
    latitude = (AREA[0] + AREA[2]) / 2
    longitude = (AREA[1] + AREA[3]) / 2

    solar_position = pvlib.solarposition.get_solarposition(time, latitude, longitude)
    elevation = solar_position['elevation'].values
    azimuth = solar_position['azimuth'].values

    return elevation, azimuth


def amount_of_solar_hours_in_seconds(time):
    print(time)
    latitude = (AREA[0] + AREA[2]) / 2
    longitude = (AREA[1] + AREA[3]) / 2
    
    times = pd.date_range(time, time + timedelta(days=1), freq='1s')

    # Calculate the solar position
    solar_position = pvlib.solarposition.get_solarposition(times, latitude, longitude, altitude=141)

    # Determine when the sun is above the horizon (altitude > 0)
    daylight_hours = solar_position[solar_position['apparent_elevation'] > 0]

    # Calculate the total daylight time in seconds
    total_daylight_seconds = len(daylight_hours) 

    return total_daylight_seconds


def main():
    
    start = datetime(YEARS[0], 1, 1, 0, 0, 0)
    end = datetime(YEARS[-1], 12, 31, 23, 0, 0)
    
    # time_range = pd.date_range(start=start, end=end, freq="H")
    # elevation,azimuth = sun_position(time_range)
    # output = pd.DataFrame({"time": time_range, "elevation": elevation, "azimuth": azimuth})
    # output.to_csv("data/external_data/sun.csv", index=False)

    # #Get frequence at day scale
    time_range = pd.date_range(start=start, end=end, freq="D")
    daylight_seconds = [amount_of_solar_hours_in_seconds(time) for time in time_range]
    output = pd.DataFrame({"time": time_range, "daylight_seconds": daylight_seconds})
    output.to_csv("data/external_data/daylight.csv", index=False)

if __name__ == "__main__":
    main()
   