Capture the response time of an app using jmeter in non gui mode, push the captured response time data to time series database Influx DB. Query the influx dbthrough Grafana dashboard to view the results in time series chart. 

Three easy ways to capture the response time of a page

1. Setup the application url, jmeter and influx DB configurations in setup.sh
```sh
    # Site Configurations

    export SITE_USERNAME=admin@phptravels.com
    export SITE_PASSWORD=demoadmin
    export SITE_URL=https://www.phptravels.net
    
    # Jmeter Configurations

    export THROUGHPUT_PER_MINUTE=10
    export THREAD_COUNT=1
    export USERS_RAMPUP_TIME=10
    export LOOP_COUNT=2
    
    # Influx DB Configurations

    export DATABASE_NAME=performance_jmeter
    export DB_HOST=127.0.0.1
    export DB_PORT=8086
    export TEST_ENV=phptravels
```
2. Add the url path to capture the response time to load the page in .json file as 

```sh
    {
      "scenarios": {
        "scenario1": {
          "name": "load_admin_page",
          "method": "GET",
          "url": "/admin"
        },
        "scenario2": {
          "name": "load_booking_page",
          "method": "GET",
          "url": "admin/bookings"
        }
      }
    }
```
3. Execute the script as 
```sh
    $ rake performance:test[file_name.json]
```

![Alt text](/performance-setup.png?raw=true "Optional Title")


## Installation
Before running test,
run following commands from command line (make sure you are in your project root directory ):
- Ruby
```sh
    $ brew update
    $ brew install rbenv
    $ brew install ruby-build
    $ rbenv install (this will install jruby version mentioned in your .ruby-version file)
    $ bundle install (this will install all necessary gems mentioned in your Gemfile)
```
- Influx DB
```sh
    $ brew install influxdb
```
- Grafana 
```sh
    $ brew install grafana
```
- Jmeter 
```sh
    $ brew install jmeter
```

## Execution
- Make sure Influxdb is up and listening to the port 8086 and host and port details are updated in script file
```sh
    $ influxd -config /usr/local/etc/influxdb.conf
    $ source setup.sh (this will export all necessary env and change your USER_NAME, 
      USER_PASSWORD, SITE_URL and jmeter influxdb configuaration.
```
- To executae single tests in the scenario folder
```sh
    $ rake performance:test[load_admin_page.json]
```
- To execute all the tests in folder
```sh
    $ rake performance:test_all
```
## Streaming in Grafana
- Run the grafana server locally
```sh
    $ brew services start grafana (visit localhost:3000 to view the dashboard)
```
