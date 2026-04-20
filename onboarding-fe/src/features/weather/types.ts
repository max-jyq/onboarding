export type WeatherDay = {
  id: number;
  date: string;
  high_temp: number;
  low_temp: number;
  inserted_at?: string;
  updated_at?: string;
};

export type WeatherDayResponse = {
  data: WeatherDay;
};

export type WeatherDayListResponse = {
  data: WeatherDay[];
};
