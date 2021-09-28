local TalkingDataMgr = class("TalkingDataMgr")
local debugFlag = 0
TalkingDataMgr.cls_ios = "TalkingDataInter"
function TalkingDataMgr:ctor()
  if channel.useTalkingData then
    local channelStr = channel.getChannelIdForTalkingData()
    local appId = "8bd928fb2dd34dea85674685d418aae3"
    self:inter_InitSDK(appId, channelStr)
    MessageEventExtend.extend(self)
    self:ListenMessage(MsgID_PlayerInfo)
  end
end
function TalkingDataMgr:OnMessage(msgSID, ...)
  if channel.useTalkingData and msgSID == MsgID_HeroUpdate then
    print("===========>>>>TalkingDataMgr:OnMessage")
    local arg = {
      ...
    }
    local heroInfo = arg[1]
    if heroInfo and heroInfo.pro then
      local playerId = heroInfo.pid
      local heroId = heroInfo.heroId
      local lv = heroInfo.pro[PROPERTY_ROLELEVEL]
      local zs = heroInfo.pro[PROPERTY_ZHUANSHENG] or 0
      print("playerId, heroId, lv, zs:", playerId, heroId, lv, zs)
      if (heroId == 1 and lv ~= nil or zs ~= nil) and zs == 0 and lv == 25 then
        print("-->> 升级到0转25级")
        self:onCustEvent(1)
      end
    end
  end
end
function TalkingDataMgr:inter_InitSDK(appId, channelStr)
  if device.platform == "ios" then
    luaoc.callStaticMethod(TalkingDataMgr.cls_ios, "InitSDK", {
      appId = appId,
      channelId = channelStr,
      debug = debugFlag
    })
  elseif device.platform == "android" then
  end
end
function TalkingDataMgr:onRegister(account)
  if device.platform == "ios" then
    luaoc.callStaticMethod(TalkingDataMgr.cls_ios, "onRegister", {account = account})
  elseif device.platform == "android" then
  end
end
function TalkingDataMgr:onLogin(account)
  if device.platform == "ios" then
    luaoc.callStaticMethod(TalkingDataMgr.cls_ios, "onLogin", {account = account})
  elseif device.platform == "android" then
  end
end
function TalkingDataMgr:onCreateRole(name)
  if device.platform == "ios" then
    luaoc.callStaticMethod(TalkingDataMgr.cls_ios, "onCreateRole", {name = name})
  elseif device.platform == "android" then
  end
end
function TalkingDataMgr:onCustEvent(event)
  if device.platform == "ios" then
    luaoc.callStaticMethod(TalkingDataMgr.cls_ios, "onCustEvent", {event = event})
  elseif device.platform == "android" then
  end
end
g_TalkingDataMgr = TalkingDataMgr.new()
