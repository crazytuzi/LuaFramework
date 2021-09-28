local SyNative = {}
SyNative.cls_and = "com/hk/core/SYNative"
function SyNative.startListenMemoryWarning(listener)
  if device.platform == "ios" then
    luaoc.callStaticMethod("SYNative", "startListenMemoryWarning", {listener = listener})
  elseif device.platform == "android" then
    luaj.callStaticMethod(SyNative.cls_and, "startListenMemoryWarning", {listener}, "(I)Ljava/lang/String;")
  end
end
function SyNative.getDeviceName()
  local deviceName
  if device.platform == "ios" then
    local ok, ret = luaoc.callStaticMethod("SYNative", "getDeviceName")
    if ok and ret ~= nil then
      deviceName = ret
    end
  elseif device.platform == "android" then
    local ok, ret = luaj.callStaticMethod(SyNative.cls_and, "getDeviceName", {}, "()Ljava/lang/String;")
    if ok and ret ~= nil then
      deviceName = ret
    end
  else
    deviceName = "pc"
  end
  if deviceName == nil then
    deviceName = "unknow"
  end
  return deviceName
end
function SyNative.getMemoryInfo()
  if device.platform == "ios" then
    local ok, ret = luaoc.callStaticMethod("SYNative", "getMemoryInfo")
    if ok and ret ~= nil then
      local t, f, a = string.match(ret, "(.*),(.*),(.*)")
      return tonumber(t), tonumber(f), tonumber(a)
    end
  elseif device.platform == "android" then
    local ok, ret = luaj.callStaticMethod(SyNative.cls_and, "getMemoryInfo", {}, "()Ljava/lang/String;")
    if ok and ret ~= nil then
      local t, f, a = string.match(ret, "(.*),(.*),(.*)")
      return tonumber(t), tonumber(f), tonumber(a)
    end
  end
end
function SyNative.createLocalNotification(name, msg, repeatType, time, badgeNumParam)
  if device.platform == "ios" then
    luaoc.callStaticMethod("SYNative", "createLocalNotification", {
      name = name,
      msg = msg,
      repeatType = repeatType,
      time = time,
      badgeNumParam = badgeNumParam
    })
  elseif device.platform == "android" then
    luaj.callStaticMethod(SyNative.cls_and, "createLocalNotification", {
      name,
      msg,
      repeatType,
      time
    }, "(Ljava/lang/String;Ljava/lang/String;IF)Ljava/lang/String;")
  end
end
function SyNative.deleteLocalNotification(name)
  if device.platform == "ios" then
    luaoc.callStaticMethod("SYNative", "deleteLocalNotification", {name = name})
  elseif device.platform == "android" then
    luaj.callStaticMethod(SyNative.cls_and, "createLocalNotification", {name}, "(Ljava/lang/String;)Ljava/lang/String;")
  end
end
function SyNative.deleteAllNotification()
  if device.platform == "ios" then
    luaoc.callStaticMethod("SYNative", "deleteAllNotification")
  elseif device.platform == "android" then
  end
end
function SyNative.setIconBadgeNumber(number)
  if device.platform == "ios" then
    luaoc.callStaticMethod("SYNative", "setIconBadgeNumber", {number = number})
  elseif device.platform == "android" then
  end
end
function SyNative.getAppChannelId()
  if device.platform == "android" then
    return SyNative.getAppChannelInfo("XiYouChannelId", "nil")
  elseif device.platform == "ios" then
    return SyNative.getInfoStringValueIOS("XiYouChannelId")
  end
end
function SyNative.getNMGMk()
  if device.platform == "android" then
    return SyNative.getAppChannelInfo("NMG_MK", "N")
  elseif device.platform == "ios" then
    return SyNative.getInfoStringValueIOS("XiYouChannelId")
  end
  return "N"
end
function SyNative.getBinaryVersion()
  if device.platform == "android" then
    local versionCode = SyNative.getAppChannelInfo("versionCode", "0")
    return string.format("0.0.%s", versionCode)
  elseif device.platform == "ios" then
    return SyNative.getInfoStringValueIOS("CFBundleShortVersionString")
  end
end
function SyNative.getAppChannelInfo(key, defvalue)
  if device.platform == "android" then
    local ok, result = luaj.callStaticMethod(SyNative.cls_and, "getAppChannelInfo", {key, defvalue}, "(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;")
    if ok then
      return result
    else
      return defvalue
    end
  end
end
function SyNative.logcatPrint(msg)
  if device.platform == "android" then
    local ok, result = luaj.callStaticMethod(SyNative.cls_and, "logcatPrint", {msg}, "(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;")
    if ok then
      return result
    else
      return defvalue
    end
  end
end
function SyNative.getInfoStringValueIOS(key)
  if device.platform == "ios" then
    local ok, result = luaoc.callStaticMethod("SYNative", "getInfoStringValue", {key = key})
    if ok then
      return result
    else
      return nil
    end
  end
end
function SyNative.getLocation(listener)
  if device.platform == "ios" then
    local function getLocationResult(strResult)
      local t, l1, l2 = string.match(strResult, "(.*),(.*),(.*)")
      t = tonumber(t)
      local localtion
      if t == 1 then
        localtion = {
          tonumber(l1),
          tonumber(l2)
        }
      else
      end
      if listener then
        listener(t == 1, localtion)
      end
    end
    local ok, result = luaoc.callStaticMethod("SYNative", "getLocation", {listener = getLocationResult})
    if ok and result == "1" then
      return true
    else
      if getLocation then
        getLocation(false)
      end
      return false
    end
  end
end
function SyNative.getPasteboardText(maxLength, afterGetString)
  afterGetString = afterGetString or 0
  if device.platform == "android" then
    if maxLength == nil or maxLength <= 0 then
      maxLength = 1024
    end
    local ok, result = luaj.callStaticMethod(SyNative.cls_and, "getPasteboardText", {maxLength, afterGetString}, "(II)Ljava/lang/String;")
    if ok then
      return
    end
  elseif device.platform == "ios" then
    local ok, result = luaoc.callStaticMethod("SYNative", "getPasteboardText", {maxLength = maxLength})
    if ok then
      if afterGetString ~= nil then
        afterGetString(result)
      end
      return result
    end
  end
  if afterGetString ~= nil then
    afterGetString()
  end
  return nil
end
function SyNative.getBatteryInfo()
  if device.platform == "android" then
    local ok, ret = luaj.callStaticMethod(SyNative.cls_and, "getBatteryInfo", {}, "()Ljava/lang/String;")
    if ok and ret ~= nil then
      local l, t = string.match(ret, "(.*),(.*)")
      local level = tonumber(l)
      local mtype = tonumber(t)
      if level ~= -1 then
        level = level / 100
      end
      return level, mtype
    end
  elseif device.platform == "ios" then
    local ok, ret = luaoc.callStaticMethod("SYNative", "getBatteryInfo")
    if ok and ret ~= nil then
      local l, t = string.match(ret, "(.*),(.*)")
      local level = tonumber(l)
      local mtype = tonumber(t)
      return level, mtype
    end
  end
  return -1, 0
end
function SyNative.canPlayMovie()
  if device.platform == "android" then
    if channel ~= nil and channel.needRename == ChannelRenameType.kRename_MoMoXiYou or channel.needRename == ChannelRenameType.kRename_DaShengTianGong then
      return false
    end
    local ok, ret = luaj.callStaticMethod(SyNative.cls_and, "canPlayCG", {}, "()Ljava/lang/String;")
    if ok and ret == "1" then
      return true
    else
      return false
    end
  elseif device.platform == "ios" then
    local ok, ret = luaoc.callStaticMethod("SYNative", "canPlayMovie")
    if ok and ret == "1" then
      return true
    end
    return false
  end
  return false
end
function SyNative.playeMovie(moviePath, finishListener, canSkip)
  if canSkip == false then
    canSkip = 0
  else
    canSkip = 1
  end
  if channel ~= nil and channel.needRename == ChannelRenameType.kRename_MoMoXiYou or channel.needRename == ChannelRenameType.kRename_DaShengTianGong then
    if finishListener then
      finishListener(false)
    end
    return
  end
  local isMusicOn = sysIsMusicOn()
  function afterPlay(result)
    print("===================>>>>  music  afterplay  ====== >>>> ")
    if g_DataMgr and g_DataMgr.m_IsBackGroud ~= true then
      print(" ======================>>>> CG  Call back  ============>>>>  ", result)
      g_DataMgr.isPlayingCG = false
      if isMusicOn then
        soundManager.setIsPlayingVideo(false)
      end
    end
    if finishListener then
      finishListener(result)
    end
  end
  if SyNative.canPlayMovie() == false then
    finishListener(true)
    return
  end
  if isMusicOn then
    soundManager.setIsPlayingVideo(true)
  end
  g_DataMgr.isPlayingCG = true
  if device.platform == "android" then
    local ok, ret = luaj.callStaticMethod(SyNative.cls_and, "playMovie", {
      moviePath,
      afterPlay,
      canSkip
    }, "(Ljava/lang/String;II)Ljava/lang/String;")
    if ok and ret == "1" then
      return
    end
  elseif device.platform == "ios" then
    local ok, ret = luaoc.callStaticMethod("SYNative", "playeMovie", {
      moviePath = moviePath,
      listener = afterPlay,
      canSkip = canSkip
    })
    if ok and ret == "1" then
      return
    end
  end
  afterPlay(false)
end
SyNative.keyboardListener = {}
function SyNative.onAndroidSoftKeyBoardChange(param)
  param = param or {}
  SyNative.keyboardListener = SyNative.keyboardListener or {}
  for k, v in pairs(SyNative.keyboardListener) do
    if type(v) == "function" then
      v(param)
    end
  end
end
function SyNative.regSoftKeyBoardEvent(listener)
  if device.platform == "android" then
    SyNative.keyboardListener = SyNative.keyboardListener or {}
    SyNative.keyboardListener[listener] = listener
  end
end
function SyNative.unRegSoftKeyBoardEvent(listener)
  SyNative.keyboardListener = SyNative.keyboardListener or {}
  if SyNative.keyboardListener[listener] ~= nil then
    SyNative.keyboardListener[listener] = nil
  end
end
function SyNative.initAndroidKeyBoardStateListener()
  if device.platform == "android" then
    callStaticMethodJava(SyNative.cls_and, "initKeyBoardCallBack", {
      function(param)
        SyNative.onAndroidSoftKeyBoardChange(param)
      end
    })
  end
end
function SyNative.jinzhuPay(payParam)
  if device.platform == "android" then
    local sendParam = {
      payParam.roleId,
      payParam.amount,
      crypto.encodeBase64(payParam.serverId),
      payParam.payDataName,
      "商品描述",
      crypto.encodeBase64(payParam.customInfo)
    }
    local ok, ret = callStaticMethodJava(SyNative.cls_and, "jinzhuPay", sendParam, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;")
    if ok and ret == "1" then
      return
    end
  end
end
function SyNative.jubaoPay(payParam)
  if device.platform == "android" then
    local sendParam = {
      payParam.roleId,
      payParam.amount,
      crypto.encodeBase64(payParam.serverId),
      payParam.payDataName,
      "商品描述",
      crypto.encodeBase64(payParam.customInfo)
    }
    local ok, ret = callStaticMethodJava(SyNative.cls_and, "jubaoPay", sendParam, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;")
    if ok and ret == "1" then
      return
    end
  end
end
SyNative.initAndroidKeyBoardStateListener()
return SyNative
