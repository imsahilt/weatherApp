# Weather App
This webapp uses http://openweathermap.org/api to fetch and cache weather data.

## How to use?
```
git clone git@github.com:imsahilt/weatherApp.git
```
And then create database.yml and application.yml from database.yml.sample and application.yml.sample

And Execute:
```
$ rake db:create
```
```
$ rake db:migrate
```
Then load cities data from private/city.list.min.json (Latest can be found [here](http://bulk.openweathermap.org/sample/))
```
$ rake db:seed 
```
Then run your server.
```
$ rails server
```
