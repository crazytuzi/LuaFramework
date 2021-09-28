game = {}
local showTime = 0.2
function game.startup()
  local crypto1 = crypto.encodeBase64("md_yios_1")
  print("crytest1", crypto1)
  local ds = crypto.decodeBase64(crypto1)
  print("crytest2", ds)
  if SYCommon ~= nil then
    local scriptupPath = device.writablePath .. "script_up/"
    local updateLuaFileData = UpdateLuaFile.ReadData()
    dump(updateLuaFileData, "updateLuaFileData")
    local fileArray = CCArray:create()
    for i, v in ipairs(updateLuaFileData) do
      package.preload[v] = nil
      package.loaded[v] = nil
      fileArray:addObject(CCString:create(v))
    end
    SYCommon:LoadLuaFiles(scriptupPath, fileArray)
  end
  require("app.gameInit")
  print("startup1 g_IsRelease", g_IsRelease, channel.svrlog)
  import(".gamelog")
  if g_IsRelease then
    if channel.svrlog == true then
      _gamelogPrint()
    else
      function print()
      end
      function dump()
      end
    end
  end
  print("startup2")
  require("Update.init")
  local deviceName = SyNative.getDeviceName() or "UnKnown"
  local strInfo = [[

============================================
]]
  strInfo = strInfo .. "#版本号\t\t\t\t:" .. tostring(g_gameUpdate:getVersion()) .. "\n"
  strInfo = strInfo .. "#设备类型\t\t\t\t:" .. tostring(device.platform) .. "\n"
  strInfo = strInfo .. "#设备名称\t\t\t\t:" .. tostring(deviceName) .. "\n"
  strInfo = strInfo .. "============================================\n"
  print(strInfo)
  if false and CCCallFunc.__func__create == nil then
    CCCallFunc.__func__create = CCCallFunc.create
    function CCCallFunc:create(...)
      print("----------------------------------------")
      print("CCCallFunc: " .. "\n")
      print(debug.traceback(""))
      print("----------------------------------------")
      return CCCallFunc.__func__create(self, ...)
    end
  end
  if false then
    g_MemoryDetect:PrintObjMemory()
    return
  end
  if false then
    require("app.views.commonviews.ShowMomoTest")
    ShowMomoTestScene()
    return
  end
  print("startup3")
  local resetLogoSpriteShowWithSprite = function(sprite, posType)
    if sprite == nil then
      return
    end
    if posType == 0 then
      sprite:setPosition(display.width / 2, display.height / 2)
    elseif posType == 1 then
      sprite:setPosition(display.width / 4, display.height / 2)
    elseif posType == 2 then
      sprite:setPosition(display.width * 3 / 4, display.height / 2)
    end
    local spriteSize = sprite:getContentSize()
    local sx = display.width * 0.4 / spriteSize.width
    local sy = display.height * 0.4 / spriteSize.height
    if sx < sy then
      sprite:setScale(sx)
    else
      sprite:setScale(sy)
    end
  end
  local scene = display.newScene()
  display.replaceScene(scene)
  if channel.showLaunchLogo == true then
    local layerC = CCLayerColor:create(ccc4(255, 255, 255, 255))
    scene:addChild(layerC)
    local sprite1 = display.newSprite("res/logo/loading_nomoga.png")
    local sprite2 = display.newSprite("res/logo/loading_momo.png")
    scene:addChild(sprite1)
    scene:addChild(sprite2)
    resetLogoSpriteShowWithSprite(sprite1, 2)
    resetLogoSpriteShowWithSprite(sprite2, 1)
    showTime = 2
  else
    showTime = 0.01
    setDefaultAlphaPixelFormat(PixelFormat_MapBg)
    local sprite = display.newSprite("views/common/bg/loginbg.png")
    resetDefaultAlphaPixelFormat()
    scene:addChild(sprite)
    sprite:setPosition(display.width / 2, display.height / 2)
    local size = sprite:getContentSize()
    local sx = display.width / size.width
    local sy = display.height / size.height
    if sx > 1 or sy > 1 then
      local s = math.min(sx, sy)
      sprite:setScale(1 / s)
    end
  end
  local function _start()
    scheduler.performWithDelayGlobal(function()
      print("game.startupGame--->> 1  2")
      g_ChannelMgr:Init(function()
        print("game.startupGame--->> 2  2")
        print("game.startupGame--->> 3")
        if device.platform == "ios" or device.platform == "android" then
          print("game.startupGame--->> 更新")
          g_gameUpdate:CheckUpdate()
        else
          print("game.startupGame--->> 开始游戏")
          game.startupGame()
        end
      end)
    end, showTime)
  end
  local isNeedPlayeCG = false
  print("SyNative.canPlayMovie(  ):", SyNative.canPlayMovie(), _g_HadPlayedMovie, channel_is_reload_module)
  if SyNative.canPlayMovie() and _g_HadPlayedMovie == nil then
    local playTimes = tonumber(getConfigByName("cghadplayed"))
    if playTimes == nil then
      playTimes = 0
    end
    print("playTimes:", playTimes)
    if playTimes < 5 then
      isNeedPlayeCG = true
      _g_HadPlayedMovie = true
      setConfigData("cghadplayed", playTimes + 1, true)
      SyNative.playeMovie("res/xiyou/video/xiyou_cg.mp4", function()
        _start()
      end, true)
    end
  end
  if isNeedPlayeCG == false then
    _start()
  end
end
function game.startupGame()
  require("app.MyApp").new():run()
end
