import { Card, Icon } from "@mui/material";
import VuiBox from "components/VuiBox";
import VuiTypography from "components/VuiTypography";

import gif from "assets/images/abc1.jpeg";

import React, { useState, useEffect } from 'react';
import WeatherComponent from "services/wherether/wherether";

const Wherether = () => {
  const [formattedDate, setFormattedDate] = useState(getFormattedDate());
  useEffect(() => {
    const intervalId = setInterval(() => {
      setFormattedDate(getFormattedDate());
    }, 1); // 1 giây

    return () => clearInterval(intervalId); // Clear interval khi component unmount
  }, []);

  function getFormattedDate() {
    var date = new Date();
    var month = date.getMonth() + 1;
    var day = date.getDate();
    var hour = date.getHours();
    var min = date.getMinutes();
    var sec = date.getSeconds();

    month = (month < 10 ? "0" : "") + month;
    day = (day < 10 ? "0" : "") + day;
    hour = (hour < 10 ? "0" : "") + hour;
    min = (min < 10 ? "0" : "") + min;
    sec = (sec < 10 ? "0" : "") + sec;
    var str = day + "/" + month + "/" + date.getFullYear() + ", " + hour + ":" + min + ":" + sec;
    return str;
  }


  return (
    <Card sx={() => ({
      height: "340px",
      py: "32px",
      backgroundImage: `url(${gif})`,
      backgroundSize: "cover",
      backgroundPosition: "50%"
    })}>
      <VuiBox height="100%" display="flex" flexDirection="column" justifyContent="space-between">
        <VuiBox>
          <VuiTypography color="text" variant="button" fontWeight="regular" mb="12px">
           Today is
          </VuiTypography>
          <VuiTypography color="white" variant="h3" fontWeight="bold" mb="18px">
           {formattedDate}
          </VuiTypography>

          <WeatherComponent></WeatherComponent>

          <VuiTypography color="text" variant="h6" fontWeight="regular" mb="auto">
          </VuiTypography>
        </VuiBox>
        <VuiTypography
          component="a"
          href="#"
          variant="button"
          color="white"
          fontWeight="regular"
          sx={{
            mr: "5px",
            display: "inline-flex",
            alignItems: "center",
            cursor: "pointer",

            "& .material-icons-round": {
              fontSize: "1.125rem",
              transform: `translate(2px, -0.5px)`,
              transition: "transform 0.2s cubic-bezier(0.34,1.61,0.7,1.3)",
            },

            "&:hover .material-icons-round, &:focus  .material-icons-round": {
              transform: `translate(6px, -0.5px)`,
            },
          }}
        >
          Tap to record
          <Icon sx={{ fontWeight: "bold", ml: "5px" }}>arrow_forward</Icon>
        </VuiTypography>
      </VuiBox>
    </Card>
  );
};

export default Wherether ;
