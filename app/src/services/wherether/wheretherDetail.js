import React, { useState, useEffect } from 'react';


import VuiBox from 'components/VuiBox';
import VuiTypography from 'components/VuiTypography';
import CircularProgress from '@mui/material/CircularProgress';

const WeatherDetailComponent = () => {
  const [weatherData, setWeatherData] = useState(null);
  const [loading, setLoading] = useState(true);
  const getUVIndexInfo = (uvIndex) => {
    let color, level;
    if (uvIndex <= 2) {
      color = 'green'; // Low
      level = 'Low';
    } else if (uvIndex <= 5) {
      color = 'yellow'; // Moderate
      level = 'Moderate';
    } else if (uvIndex <= 7) {
      color = 'orange'; // High
      level = 'High';
    } else if (uvIndex <= 10) {
      color = 'red'; // Very high
      level = 'Very High';
    } else {
      color = 'purple'; // Extreme
      level = 'Extreme';
    }
    return { color, level };
  };


  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await fetch('https://api.weatherapi.com/v1/current.json?key=743e830025c54455a8e215629242003&q=Ho_Chi_Minh&aqi=yes');
        const data = await response.json();
        setWeatherData(data);
        setLoading(false);
      } catch (error) {
        console.error('Error fetching weather data:', error);
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  return (
    <div>
      {loading ? (
        <p>Loading...</p>
      ) : (
        weatherData && (
          <div>

             <VuiBox sx={{ position: 'relative', display: 'inline-flex' }}>
				<CircularProgress
					variant='determinate'
					value={weatherData.current.uv *10}
					size={window.innerWidth >= 1024 ? 200 : window.innerWidth >= 768 ? 170 : 200}
					color='success'
				/>
				<VuiBox
					sx={{
					top: 0,
					left: 0,
					bottom: 0,
					right: 0,
					position: 'absolute',
					display: 'flex',
					alignItems: 'center',
					justifyContent: 'center'
				}}>
				<VuiBox display='flex' flexDirection='column' justifyContent='center' alignItems='center'>
					<VuiTypography color='text' variant='button' mb='4px'>
						UV
					</VuiTypography>
					<VuiTypography
					    color='white'
						variant='d5'
						fontWeight='bold'
						mb='4px'
						sx={({ breakpoints }) => ({
						[breakpoints.only('xl')]: {
						fontSize: '32px'
						}
					})}>
						{weatherData.current.uv}
					</VuiTypography>
					<VuiTypography color='text' variant='button'>
                        {getUVIndexInfo(weatherData.current.uv).level}
					</VuiTypography>
					</VuiBox>
					</VuiBox>
			</VuiBox>   

            {/* <h2>Weather in {weatherData.location.name}, {weatherData.location.country}</h2>
            <p>Temperature: {weatherData.current.temp_c}°C / {weatherData.current.temp_f}°F</p>
            <p>Condition: {weatherData.current.condition.text}</p>
            <img src={`http:${weatherData.current.condition.icon}`} alt="Weather Icon" />
            <p>Wind: {weatherData.current.wind_kph} km/h from {weatherData.current.wind_dir}</p>
            <p>Pressure: {weatherData.current.pressure_mb} mb</p>
            <p>Humidity: {weatherData.current.humidity}%</p>
            <p>Cloud: {weatherData.current.cloud}%</p>
            <p>Feels Like: {weatherData.current.feelslike_c}°C / {weatherData.current.feelslike_f}°F</p>
            <p>Visibility: {weatherData.current.vis_km} km / {weatherData.current.vis_miles} miles</p>
            <p>UV Index: {weatherData.current.uv}</p>
            <p>Gust: {weatherData.current.gust_kph} km/h</p>
            <p>Air Quality Index: {weatherData.current.air_quality['us-epa-index']}</p> */}
          </div>
        )
      )}
    </div>
  );
};

export default WeatherDetailComponent;
