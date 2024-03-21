import React, { useState, useEffect } from 'react';

const WeatherComponent = () => {
  const [weatherData, setWeatherData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await fetch('http://api.weatherapi.com/v1/current.json?key=743e830025c54455a8e215629242003&q=Ho_Chi_Minh&aqi=yes');
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
            <h2>{weatherData.location.name}, {weatherData.location.country}</h2>
            <img src={`http:${weatherData.current.condition.icon}`} alt="Weather Icon" />
            <p>Temperature: {weatherData.current.temp_c}°C / {weatherData.current.temp_f}°F</p>
          </div>
        )
      )}
    </div>
  );
};

export default WeatherComponent;
