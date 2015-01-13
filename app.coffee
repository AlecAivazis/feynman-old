
# import modules
express = require "express" 
routes = require "./routes" 
http = require "http" 
path = require "path" 

# configure express application
app = express()
app.set "port", process.env.PORT or 3000
app.set "views", __dirname + "/views"
app.set "view engine", "jade"
app.use express.favicon()
app.use express.logger("dev")
app.use app.router
app.use require('connect-assets')()
app.use express.static(path.join(__dirname, "assets"))

app.use express.errorHandler()
app.locals.pretty = true

# url configs
app.get "/", routes.index

# create the server
http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")

