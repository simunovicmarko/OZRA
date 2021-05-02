require 'ramaze'
require 'httparty'
require 'json'
require 'ostruct'


class MyController < Ramaze::Controller
    map '/'
    layout :main
    
    
    
    def index
        render_view '/index'
        response = HTTParty.get('https://api.openweathermap.org/data/2.5/weather?q=Celje&appid=53887813d2159184f1784360b47a8b39')
        res = OpenStruct.new(response)
        main = OpenStruct.new(res.main)
        temp  = main.temp
        return temp
    end
    
    # dobi ime mesta iz url in vrne temperaturo
    def vreme
        mesto = request[:mesto]
        
        if mesto.nil? == true|| mesto == ""
            return
        end
        #pridobi koordinate in ime
        response = HTTParty.get("https://api.openweathermap.org/data/2.5/weather?q=#{mesto}&appid=53887813d2159184f1784360b47a8b39")
        if response.code != 200
            return
        end
        res = OpenStruct.new(response)
        @name = res.name
        coords = OpenStruct.new(res.coord)
        lat = coords.lat
        lon = coords.lon
        main = OpenStruct.new(res.main)
        @curTemp = tempToCelsius( main.temp)
        
        #Pridobi dnevno napoved iz OpenWeatherAPI iz koordinat
        response = HTTParty.get("https://api.openweathermap.org/data/2.5/onecall?lat=#{lat}&lon=#{lon}&appid=53887813d2159184f1784360b47a8b39")
        res = OpenStruct.new(response)
        current = OpenStruct.new(res.current)
        daily = res.daily
        temp  = tempToCelsius(current.temp)
        
        #Seznam Temperatur in za keteri dan        
        @tempList = []
        for day in daily do
            d = OpenStruct.new(day)
            tempD = OpenStruct.new(d.temp)
            max = tempD.max
            dt = d.dt
            obj = OpenStruct.new
            obj.day = getDaySlo(dt)
            obj.temperatura = tempToCelsius(max)
            @tempList.push(obj)
        end
        
        
        return ""
    end 
    
    def getDay(timestamp)
        days = ["Sunday", "Monday",  "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" ]
        return days[Time.at(timestamp).wday]
        
        # return 
    end
    def getDaySlo(timestamp)
        days = ["Nedelja", "Ponedeljek",  "Torek", "Sreda", "Četrtek", "Petek", "Sobota" ]
        return days[Time.at(timestamp).wday]
    end
    
    
    # #Primer kako bi to dal v metodo
    # def getDailyForecast(lat, lon)
    #     response = HTTParty.get("https://api.openweathermap.org/data/2.5/onecall?lat=#{lat}&lon=#{lon}&appid=53887813d2159184f1784360b47a8b39")
    #     res = OpenStruct.new(response)
    #     current = OpenStruct.new(res.current)
    #     return daily = res.daily
    # end
    
    
    def tempToCelsius(temp)
        temp = temp.to_f - 273
        return temp.round(1)
    end
end

Ramaze.start