PushMsg = {}
function PushMsg.getFlushShopRestTime()
  local tempDict = {
    9,
    12,
    18,
    21
  }
  local curTime = g_DataMgr:getServerTime()
  local timeTable = os.date("*t", checkint(curTime))
  local hour = timeTable.hour
  local nextHour = -1
  local addDay = 0
  for _, tempH in ipairs(tempDict) do
    if tempH > hour then
      nextHour = tempH
      break
    end
  end
  if nextHour == -1 then
    nextHour = 9
    addDay = 1
  end
  local nextTime = os.time({
    year = timeTable.year,
    month = timeTable.month,
    day = timeTable.day,
    hour = nextHour,
    min = 0,
    sec = 0,
    isdst = timeTable.isdst
  })
  if addDay == 1 then
    nextTime = nextTime + 86400
  end
  local restTime = math.floor(nextTime - curTime)
  return restTime
end
function startClientService()
  if g_LocalPlayer == nil then
    print("用户 数据还没初始化")
    return
  end
  local pushSetting = g_LocalPlayer:getSysSetting() or {}
  local flushshop = 0
  local openactivity = 0
  if pushSetting.flushshop ~= false then
    flushshop = PushMsg.getFlushShopRestTime() or 0
    flushshop = flushshop + g_DataMgr:getServerTime()
  end
  function getOneTime(h, m, s)
    local curTime = g_DataMgr:getServerTime()
    local timeTable = os.date("*t", checkint(curTime))
    local result = os.time({
      year = timeTable.year,
      month = timeTable.month,
      day = timeTable.day,
      hour = h,
      min = m,
      sec = s,
      isdst = timeTable.isdst
    })
    return result
  end
  local mainHeroIns = g_LocalPlayer:getMainHero()
  if mainHeroIns == nil then
    print(" mainHeroIns == nil")
    return
  end
  local lv = mainHeroIns:getProperty(PROPERTY_ROLELEVEL)
  local zs = mainHeroIns:getProperty(PROPERTY_ZHUANSHENG)
  local msgTb = {}
  function getPushPoint(time, rptype, wday, deftime)
    if time == nil or rptype == nil or wday == nil then
      return
    end
    if rptype == 0 then
      return deftime
    elseif rptype == 1 then
      return getOneTime(time[1], time[2], time[3])
    elseif rptype == 2 then
      local tbtime = getOneTime(time[1], time[2], time[3])
      local curtimetb = os.date("*t", os.time())
      local curwday = curtimetb.wday
      local def = wday - curtimetb.wday
      if def >= 0 then
        return tbtime + def * 24 * 3600
      else
        return tbtime + (7 + def) * 24 * 3600
      end
    end
  end
  local tbMsgPush = data_LocalMsgPush
  if tbMsgPush == nil then
    return
  end
  for k, v in pairs(tbMsgPush) do
    if v ~= nil and type(tbMsgPush) == "table" then
      local namecode = v.nameCode
      local typeCode = v.typeCode
      local oplv = v.lv
      local opzs = v.zs
      local pushmsg = v.msg
      local pushtime = v.time
      local rpType = v.rpType
      local wday = v.wday
      local expCondition = true
      local deftime = g_DataMgr:getServerTime()
      if typeCode == "tilifull" then
        expCondition = false
      elseif typeCode == "bangzhan" then
        expCondition = g_BpMgr:localPlayerHasBangPai()
      elseif typeCode == "callperson" then
        deftime = g_DataMgr:getServerTime() + 172800
      end
      if (zs > opzs or zs == opzs and lv >= oplv) and pushSetting[typeCode] ~= false and expCondition == true then
        local pushtimeSecond = getPushPoint(pushtime, rpType, wday + 1, deftime)
        if typeCode == "callperson" then
          pushtimeSecond = deftime
        end
        if pushtimeSecond ~= nil then
          msgTb[#msgTb + 1] = {
            namecode,
            pushmsg,
            rpType,
            pushtimeSecond
          }
        end
      end
    end
  end
  if device.platform == "android" then
    local sendStr = ""
    for k, v in ipairs(msgTb) do
      local namecode, pushmsg, rpType, pushtimeSecond = unpack(v, 1, 4)
      if k == 1 then
        sendStr = string.format("%s:::%s:::%d:::%d", namecode, pushmsg, rpType, pushtimeSecond)
      else
        sendStr = string.format("%s###%s:::%s:::%d:::%d", sendStr, namecode, pushmsg, rpType, pushtimeSecond)
      end
    end
    print(" 发送 推送消息   ==== =   ", sendStr)
    if "" ~= sendStr then
      luaj.callStaticMethod(SyNative.cls_and, "createLocalNotificationInCollection", {sendStr}, "(Ljava/lang/String;)V")
    end
  elseif device.platform == "ios" then
    SyNative.deleteAllNotification()
    for k, v in ipairs(msgTb) do
      local namecode, pushmsg, rpType, pushtimeSecond = unpack(v, 1, 4)
      pushmsg = string.gsub(pushmsg, "%%", "%%%%")
      SyNative.createLocalNotification(namecode, pushmsg, rpType, pushtimeSecond, 1)
    end
  end
end
function flushTiLiPushRestTime(restime)
  PushMsg.curFlushRestTime = restime or -100
  local h, m, s = getHMSWithSeconds(PushMsg.getFlushShopRestTime())
  print(" ========>  flushTiLiPushRestTime  ", restime / 60, g_LocalPlayer:GetTiliRestTime() / 60, h, m, s)
end
function reSetClientServiceTime(type, time)
end
function shutDownClientService()
end
function androidPushMsg(tb)
end
shutDownClientService()
