local lfs = require("lfs")
local AppID = "7bab42df18992f9387fa6ba204090fed"
local AppSecret = "dbe3fc2d9eee5b964d9f7dab4ebc25d8"
local RestApiVer = "http://xy01.youvipwan.com/xiyou/classes/"
local gamelogDir = device.writablePath .. "log/"
local maxSaveLogNum = 10
local g_LogFileIns
local g_SverLogStr = ""
local g_WriteLogFlag = false
local g_LuaErrorFlag = false
local g_LogFileName = ""
local g_SvrLogMark = {}
function _gamelogPrint()
  function print(...)
    if not g_LogFileIns then
    end
    local arg = {
      ...
    }
    for _, s in ipairs(arg) do
      s = tostring(s)
      if g_LuaErrorFlag then
        g_SverLogStr = string.format("%s %s", g_SverLogStr, s)
      end
    end
    if g_LuaErrorFlag then
      g_SverLogStr = string.format("%s%s", g_SverLogStr, "\n")
    end
  end
end
function _gamelogClose()
  if g_LogFileIns ~= nil then
    g_LogFileIns:close()
    g_LogFileIns = nil
  end
  g_SvrLogMark = {}
  g_SverLogStr = ""
end
function _gamelogRefresh()
  if g_WriteLogFlag then
    _gamelogPrint()
  end
end
local onRequestFinished = function(event)
  if event.name ~= "inprogress" then
    local ok = event.name == "completed"
    local request = event.request
    if not ok then
      print(request:getErrorCode(), request:getErrorMessage())
      return
    end
    local code = request:getResponseStatusCode()
    if code ~= 200 then
      print(code)
      return
    end
    local response = request:getResponseString()
    print(response)
  end
end
local function _uploadErrorLogToServer(logtxt)
  local url = RestApiVer .. "log"
  print("url=", url)
  local request = network.createHTTPRequest(onRequestFinished, url, kCCHTTPRequestMethodPOST)
  request:addRequestHeader("Content-Type:application/json")
  request:addRequestHeader(string.format("X-Bmob-Application-Id:%s", AppID))
  request:addRequestHeader(string.format("X-Bmob-REST-API-Key:%s", AppSecret))
  local setData = {}
  logtxt = crypto.encryptXXTEA(logtxt, "lk>-=45L")
  logtxt = crypto.encodeBase64(logtxt)
  setData.log = logtxt
  setData.udid = device.getOpenUDID()
  if g_LocalPlayer then
    setData.pid = g_LocalPlayer:getPlayerId()
    local mainHero = g_LocalPlayer:getMainHero()
    if mainHero then
      setData.pname = mainHero:getProperty(PROPERTY_NAME)
    end
  end
  request:setPOSTData(json.encode(setData))
  request:start()
end
function _markLuaErrorLogFlag(flag)
  g_LuaErrorFlag = flag
  if not g_LuaErrorFlag and string.len(g_SverLogStr) > 0 then
    local tag = crypto.md5(g_SverLogStr, false)
    if g_SvrLogMark[tag] == nil then
      g_SvrLogMark[tag] = 1
      _uploadErrorLogToServer(g_SverLogStr)
    end
    g_SverLogStr = ""
    if channel.errorWarning == true then
      device.showAlert("警告", "客户端发现报错", {"确定"}, nil)
    end
  end
end
