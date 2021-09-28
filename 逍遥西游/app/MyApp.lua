local MyApp = class("MyApp", cc.mvc.AppBase)
function MyApp:ctor()
  MyApp.super.ctor(self)
end
function MyApp:run()
  collectgarbage("setpause", 100)
  collectgarbage("setstepmul", 5000)
  require("app.GlobalTouchEvent")
  require("app.CGuideSwallowMessage")
  ShowSelectSerView()
end
return MyApp
