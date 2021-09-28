local MomoInter = {}
MomoInter.cls_ios = "MomoInter"
MomoInter.cls_and = "com/md/core/MomoInter"
function MomoInter.setMessageListener(listener)
  if device.platform == "ios" then
    luaoc.callStaticMethod(MomoInter.cls_ios, "setMessageListener", {listener = listener})
  elseif device.platform == "android" then
    callStaticMethodJava(MomoInter.cls_and, "setMessageListener", {listener})
  end
end
function MomoInter.getAuthInfo()
  if device.platform == "ios" then
    local ok, ret = luaoc.callStaticMethod(MomoInter.cls_ios, "getAuthInfo")
    if ok and ret ~= nil then
      local r, t, ut, un = string.match(ret, "(.*),(.*),(.*),(.*)")
      return tonumber(r) == 1, t, tonumber(ut), un
    end
  elseif device.platform == "android" then
    local ok, ret = callStaticMethodJava(MomoInter.cls_and, "getAuthInfo")
    if ok and ret ~= nil then
      local r, t, ut, un = string.match(ret, "(.*),(.*),(.*),(.*)")
      return tonumber(r) == 1, t, tonumber(ut), un
    end
  end
end
function MomoInter.loginMomo()
  if device.platform == "ios" then
    local ok, ret = luaoc.callStaticMethod(MomoInter.cls_ios, "loginMomo")
    if ok and ret == "1" then
      return true
    else
      return false
    end
  elseif device.platform == "android" then
    local ok, ret = callStaticMethodJava(MomoInter.cls_and, "loginMomo", {})
    if ok and ret == "1" then
      return true
    else
      return false
    end
  end
end
function MomoInter.logoutMomo()
  if device.platform == "ios" then
    local ok, ret = luaoc.callStaticMethod(MomoInter.cls_ios, "logoutMomo")
    if ok and ret == "1" then
      return true
    else
      return false
    end
  elseif device.platform == "android" then
  end
end
function MomoInter.setGameServer(gameServer)
  if device.platform == "ios" then
    local ok, ret = luaoc.callStaticMethod(MomoInter.cls_ios, "setGameServer", {server = gameServer})
    if ok and ret == "1" then
      return true
    else
      return false
    end
  elseif device.platform == "android" then
    local ok, ret = callStaticMethodJava(MomoInter.cls_and, "setGameServer", {gameServer})
    if ok and ret == "1" then
      return true
    else
      return false
    end
  end
end
function MomoInter.setShowMomoLogo(isShow, showPlace)
  if device.platform == "ios" then
    if isShow == true then
      isShow = 1
      if showPlace == nil then
        showPlace = MDKLogoPlaceLeftLower
      end
    else
      isShow = 0
      showPlace = nil
    end
    local ok, ret = luaoc.callStaticMethod(MomoInter.cls_ios, "setShowMomoLogo", {show = isShow, place = showPlace})
    if ok and ret == "1" then
      return true
    else
      return false
    end
  elseif device.platform == "android" then
  end
end
function MomoInter.showPersonalCenter()
  if device.platform == "ios" then
    local ok, ret = luaoc.callStaticMethod(MomoInter.cls_ios, "showPersonalCenter")
    if ok and ret == "1" then
      return true
    else
      return false
    end
  elseif device.platform == "android" then
  end
end
function MomoInter.getLocalPersonalInfo()
  if device.platform == "ios" then
    local ok, ret = luaoc.callStaticMethod(MomoInter.cls_ios, "getLocalPersonalInfo")
    if ok and ret == "1" then
      return true
    else
      return false
    end
  elseif device.platform == "android" then
  end
end
function MomoInter.getOtherPersonalInfo(userID)
  if device.platform == "ios" then
    local ok, ret = luaoc.callStaticMethod(MomoInter.cls_ios, "getOtherPersonalInfo", {userID = userID})
    if ok and ret == "1" then
      return true
    else
      return false
    end
  elseif device.platform == "android" then
  end
end
function MomoInter.launchToUserProfile(userID)
  if device.platform == "ios" then
    local ok, ret = luaoc.callStaticMethod(MomoInter.cls_ios, "launchToUserProfile", {userID = userID})
    if ok and ret == "1" then
      return true
    else
      return false
    end
  elseif device.platform == "android" then
  end
end
function MomoInter.getFriendList()
  if device.platform == "ios" then
    local ok, ret = luaoc.callStaticMethod(MomoInter.cls_ios, "getFriendList")
    if ok and ret == "1" then
      return true
    else
      return false
    end
  elseif device.platform == "android" then
  end
end
function MomoInter.showFAQView()
  if device.platform == "ios" then
    local ok, ret = luaoc.callStaticMethod(MomoInter.cls_ios, "showFAQView")
    if ok and ret == "1" then
      return true
    else
      return false
    end
  elseif device.platform == "android" then
  end
end
function MomoInter.launchToTieba()
  if device.platform == "ios" then
    local ok, ret = luaoc.callStaticMethod(MomoInter.cls_ios, "launchToTieba")
    if ok and ret == "1" then
      return true
    else
      return false
    end
  elseif device.platform == "android" then
  end
end
return MomoInter
