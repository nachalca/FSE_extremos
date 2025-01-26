from datetime import datetime, timedelta
import pandas as pd
import pvlib
import yaml 
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.firefox.service import Service
from selenium.webdriver.firefox.options import Options
from selenium.webdriver.support.ui import WebDriverWait

YEARS = []
AREA = []


#Given the lat and lon get the height of the location. I used suncalc since it was the reference for the daylight duration.
def get_altitude(lat, lon):

    # Dummy datetime
    date_time = "2024.01.01/03:00"

    # Construct the URL for SunCalc
    url = f"https://www.suncalc.org/#/{lat},{lon},3/{date_time}/1/0"
    
    options = Options()
    options.add_argument("--headless")
    service = Service("/usr/bin/geckodriver")  # Replace with the path to your geckodriver
    driver = webdriver.Firefox(service=service, options=options)
    
    # Load the page
    driver.get(url)

    # Wait for the page to load completely
    WebDriverWait(driver, 10).until(
        lambda d: d.execute_script("return document.readyState") == "complete"
    )    
    
    # Wait for the page to load and locate the elevation element
    elevation_element = driver.find_element(By.XPATH, "//*[@id='hoehe']") 
    
    elevation = elevation_element.text
    
    print(elevation)
    
    #Strip the "m" from the elevation
    elevation = elevation.replace("m", "")
    elevation = float(elevation) #Transform it to float
    return elevation


def load_configuration():
    global YEARS, AREA

    with open("code/conf.yml", 'r') as file:
        conf = yaml.safe_load(file)
    
    YEARS = list(range(conf["REANALYSIS_YEARS"]["START"], conf["PROJECTION_YEARS"]["END"] + 1))
    AREA = conf["AREA"]

    return conf


def sun_position(time):
    
    latitude = (AREA[0] + AREA[2]) / 2
    longitude = (AREA[1] + AREA[3]) / 2

    solar_position = pvlib.solarposition.get_solarposition(time, latitude, longitude)
    elevation = solar_position['elevation'].values
    azimuth = solar_position['azimuth'].values

    return elevation, azimuth


def amount_of_solar_hours_in_seconds(time, lat, lon, h):    
    times = pd.date_range(time, time + timedelta(days=1), freq='1s')

    print(f"Getting daylight hours for {time} (lat:{lat}, lon:{lon}, h: {h})")

    # Calculate the solar position
    solar_position = pvlib.solarposition.get_solarposition(times, lat, lon, altitude=h)

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

    # Get daylight hours for each day
    lat = (AREA[0] + AREA[2]) / 2
    lon = (AREA[1] + AREA[3]) / 2
    h = get_altitude(lat, lon)    
    time_range = pd.date_range(start=start, end=end, freq="D")
    daylight_seconds = [amount_of_solar_hours_in_seconds(time, lat, lon, h) for time in time_range]
    output = pd.DataFrame({"time": time_range, "daylight_seconds": daylight_seconds})
    output.to_csv("data/external_data/daylight.csv", index=False)

if __name__ == "__main__":
    load_configuration()
    main()
   
