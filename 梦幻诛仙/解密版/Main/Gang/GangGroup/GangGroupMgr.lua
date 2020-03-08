local Lplus = require("Lplus")
local GangData = require("Main.Gang.data.GangData")
local GangGroupData = require("Main.Gang.GangGroup.GangGroupData")
local GangGroupUtility = require("Main.Gang.GangGroup.GangGroupUtility")
local ECMSDK = require("ProxySDK.ECMSDK")
local GangGroupMgr = Lplus.Class("GangGroupMgr")
local def = GangGroupMgr.define
def.field("boolean").isOnBindQQGroupQuery = false
def.field("boolean").isReqJoinQQGroupQuery = false
def.field("boolean").isUnbindQQGroupQuietly = false
def.field(GangGroupData).data = nil
local instance
def.static("=>", GangGroupMgr).Instance = function()
  if instance == nil then
    instance = GangGroupMgr()
    instance.data = GangGroupData.Instance()
  end
  return instance
end
def.method().ResetStates = function(self)
  self.isOnBindQQGroupQuery = false
  self.isReqJoinQQGroupQuery = false
end
def.method().Reset = function(self)
  self:ResetStates()
  self.data:Reset()
end
def.method().QueryGroupInfo = function(self)
  if _G.LoginPlatform == _G.MSDK_LOGIN_PLATFORM.WX then
    self:QueryWXGroupInfo()
  elseif _G.LoginPlatform == _G.MSDK_LOGIN_PLATFORM.QQ then
    if _G.platform == _G.Platform.android then
      self:QueryQQGroupInfo()
    elseif _G.platform == _G.Platform.ios then
    end
  end
end
def.method().QueryQQGroupInfo = function(self)
  local gangGroupId = GangGroupUtility.GetGangGroupId()
  if gangGroupId == "" then
    return
  end
  ECMSDK.QueryQQGroupInfo(gangGroupId)
end
def.method().QueryWXGroupInfo = function(self)
  local gangGroupId = GangGroupUtility.GetGangGroupId()
  if gangGroupId == "" then
    return
  end
  local openId = ECMSDK.GetMSDKInfo().openId
  if platform == 2 then
    ECMSDK.QueryWXGroupInfo(gangGroupId, openId)
  elseif platform == 1 then
    do
      local json = require("Utility.json")
      local sdkInfo = ECMSDK.GetMSDKInfo()
      if not sdkInfo or not sdkInfo.accessToken or not sdkInfo.appId then
        return
      end
      local url = "http://game.weixin.qq.com/cgi-bin/chatroom/gamechatroommember?access_token=" .. sdkInfo.accessToken
      local params = {
        appid = sdkInfo.appId,
        groupid = gangGroupId,
        openidlist = openId
      }
      local body = json.encode(params)
      url = _G._NormalizeHttpURL(url)
      GameUtil.httpPost(url, 0, body, function(success, url, postId, retdata)
        if success then
          if retdata and retdata.string then
            local result = json.decode(retdata.string)
            warn(result.errcode, "***Group Test--->QueryWXGroupInfo -------------------", result.openidlist, result.membercount)
            if result and result.errcode == 0 or result.errcode == -10005 then
              self.data:SetGroupBoundState(true)
              local openIdList = result.openidlist
              local isInGroup = GangGroupUtility.IsOpenIDInList(openIdList)
              self.data:SetInGroupState(isInGroup)
              warn("***Group Test--->OnQueryWXGroupInfo--->DispatchEvent--->Gang_GroupStateChanged")
              Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_GroupStateChanged, nil)
            elseif result and result.errcode == -10007 then
              Debug.LogWarning("\231\190\164ID\228\184\141\229\173\152\229\156\168")
              self.data:SetGroupBoundState(false)
            else
              Debug.LogWarning("\230\159\165\232\175\162\229\190\174\228\191\161\231\190\164\229\164\177\232\180\165")
            end
          else
            Debug.LogWarning("\232\167\163\230\158\144\230\159\165\232\175\162\229\184\174\230\180\190\231\190\164\228\191\161\230\129\175\229\164\177\232\180\165")
          end
        else
          Debug.LogWarning("\232\142\183\229\143\150\230\159\165\232\175\162\229\184\174\230\180\190\231\190\164\228\191\161\230\129\175\229\164\177\232\180\165")
        end
      end)
    end
  end
end
def.method().BindGangGroup = function(self)
  if _G.LoginPlatform == _G.MSDK_LOGIN_PLATFORM.WX then
    local isWXInstalled = ECMSDK.IsPlatformInstalled(_G.MSDK_LOGIN_PLATFORM.WX)
    if not isWXInstalled then
      Toast(textRes.Gang.GangGroup[1])
    else
      self:CreateWXGroup()
    end
  elseif _G.LoginPlatform == _G.MSDK_LOGIN_PLATFORM.QQ then
    if _G.platform == _G.Platform.android then
      local isQQInstalled = ECMSDK.IsPlatformInstalled(_G.MSDK_LOGIN_PLATFORM.QQ)
      if not isQQInstalled then
        Toast(textRes.Gang.GangGroup[2])
      else
        self:BindQQGroup()
      end
    elseif _G.platform == _G.Platform.ios then
    end
  end
end
def.method().BindQQGroup = function(self)
  local gangGroupId = GangGroupUtility.GetGangGroupId()
  if gangGroupId == "" then
    return
  end
  local gangName = GangData.Instance():GetGangName() .. textRes.Gang.GangGroup[3]
  local HaveGangPanel = require("Main.Gang.ui.HaveGangPanel")
  if HaveGangPanel.Instance():IsShow() then
    HaveGangPanel.Instance():DestroyPanel()
  end
  ECMSDK.BindQQGroup(gangGroupId, gangName)
end
def.method().CreateWXGroup = function(self)
  local gangGroupId = GangGroupUtility.GetGangGroupId()
  if gangGroupId == "" then
    return
  end
  local gangName = GangData.Instance():GetGangName()
  local groupName = gangName .. textRes.Gang.GangGroup[3]
  local heroName = require("Main.Hero.Interface").GetHeroProp().name
  ECMSDK.SendTLogToServer(_G.TLOGTYPE.WXGROUP, {
    GangData.Instance():GetGangId():tostring(),
    gangName,
    1
  })
  if platform == 2 then
    ECMSDK.CreateWXGroup(gangGroupId, groupName, heroName)
  elseif platform == 1 then
    do
      local json = require("Utility.json")
      local sdkInfo = ECMSDK.GetMSDKInfo()
      if not sdkInfo or not sdkInfo.accessToken then
        return
      end
      local url = "http://game.weixin.qq.com/cgi-bin/chatroom/gamecreatechatroom?access_token=" .. sdkInfo.accessToken
      local params = {
        groupid = gangGroupId,
        chatroomname = groupName,
        displayname = heroName,
        devicetype = 2
      }
      local body = json.encode(params)
      url = _G._NormalizeHttpURL(url)
      GameUtil.httpPost(url, 0, body, function(success, url, postId, retdata)
        if success then
          if retdata and retdata.string then
            local result = json.decode(retdata.string)
            warn("***Group Test--->OnCreateWXGroup -------------------", result)
            if result and result.errcode == 0 then
              local chatroomURL = result.createchatroomurl
              if ECMSDK.IsUrlInnerEncodeVersion() then
                Application.OpenURL(chatroomURL)
              else
                ECMSDK.OpenURL(chatroomURL)
              end
              warn("***Group Test--->OnCreateWXGroup--->DispatchEvent--->Gang_GroupStateChanged----------------------", result.createchatroomurl)
              require("Main.Gang.ui.HaveGangPanel").Instance():DestroyPanel()
            elseif result and result.errcode == -10008 then
              Toast(textRes.Gang.GangGroup[27])
            else
              Debug.LogWarning("\229\136\155\229\187\186\229\190\174\228\191\161\231\190\164\229\164\177\232\180\165")
            end
          else
            Debug.LogWarning("\232\167\163\230\158\144\229\136\155\229\187\186\229\184\174\230\180\190\231\190\164\228\191\161\230\129\175\229\164\177\232\180\165")
          end
        else
          Debug.LogWarning("\232\142\183\229\143\150\229\136\155\229\187\186\229\184\174\230\180\190\231\190\164\228\191\161\230\129\175\229\164\177\232\180\165")
        end
      end)
    end
  end
end
def.method().UnbindGangGroup = function(self)
  if _G.LoginPlatform == _G.MSDK_LOGIN_PLATFORM.WX then
  elseif _G.LoginPlatform == _G.MSDK_LOGIN_PLATFORM.QQ then
    if _G.platform == _G.Platform.android then
      local isQQInstalled = ECMSDK.IsPlatformInstalled(_G.MSDK_LOGIN_PLATFORM.QQ)
      if not isQQInstalled then
        Toast(textRes.Gang.GangGroup[2])
      else
        self:UnbindQQGroup()
      end
    elseif _G.platform == _G.Platform.ios then
    end
  end
end
def.method().UnbindQQGroup = function(self)
  local gangGroupId = GangGroupUtility.GetGangGroupId()
  if gangGroupId == "" then
    return
  end
  local openId = self.data:GetQQGroupOpenID()
  if openId == "" then
    return
  end
  self.isUnbindQQGroupQuietly = false
  ECMSDK.UnBindQQGroup(openId, gangGroupId)
end
def.method("string").UnBindQQGroupQuietly = function(self, gangOpenId)
  if _G.LoginPlatform ~= _G.MSDK_LOGIN_PLATFORM.QQ then
    return
  end
  if _G.platform ~= _G.Platform.android then
    return
  end
  local gangGroupId = GangGroupUtility.GetGangGroupId()
  if not gangOpenId or not gangGroupId or gangGroupId == "" or gangOpenId == "" then
    return
  end
  self.isUnbindQQGroupQuietly = true
  ECMSDK.UnBindQQGroup(gangOpenId, gangGroupId)
end
def.method().JoinGangGroup = function(self)
  if _G.LoginPlatform == _G.MSDK_LOGIN_PLATFORM.WX then
    local isWXInstalled = ECMSDK.IsPlatformInstalled(_G.MSDK_LOGIN_PLATFORM.WX)
    if not isWXInstalled then
      Toast(textRes.Gang.GangGroup[1])
    else
      self:JoinWXGroup()
    end
  elseif _G.LoginPlatform == _G.MSDK_LOGIN_PLATFORM.QQ then
    if _G.platform == _G.Platform.android then
      local isQQInstalled = ECMSDK.IsPlatformInstalled(_G.MSDK_LOGIN_PLATFORM.QQ)
      if not isQQInstalled then
        Toast(textRes.Gang.GangGroup[2])
      else
        self:JoinQQGroup()
      end
    elseif _G.platform == _G.Platform.ios then
    end
  end
end
def.method().JoinQQGroup = function(self)
  self.isReqJoinQQGroupQuery = true
  self:QueryQQGroupInfo()
end
def.method().QueryQQGroupKey = function(self)
  local groupOpenId = self.data:GetQQGroupOpenID()
  if groupOpenId == "" then
    return Toast(textRes.Gang.GangGroup[23])
  end
  ECMSDK.QueryQQGroupKey(groupOpenId)
end
def.method().JoinWXGroup = function(self)
  local gangGroupId = GangGroupUtility.GetGangGroupId()
  if gangGroupId == "" then
    return
  end
  ECMSDK.SendTLogToServer(_G.TLOGTYPE.WXGROUP, {
    GangData.Instance():GetGangId():tostring(),
    gangName,
    2
  })
  local heroName = require("Main.Hero.Interface").GetHeroProp().name
  if platform == 2 then
    ECMSDK.JoinWXGroup(gangGroupId, heroName)
  elseif platform == 1 then
    do
      local json = require("Utility.json")
      local sdkInfo = ECMSDK.GetMSDKInfo()
      if not sdkInfo or not sdkInfo.accessToken then
        return
      end
      local url = "http://game.weixin.qq.com/cgi-bin/chatroom/gamejoinchatroom?access_token=" .. sdkInfo.accessToken
      local params = {
        groupid = gangGroupId,
        displayname = heroName,
        devicetype = 2
      }
      warn("????????????????", gangGroupId, heroName)
      local body = json.encode(params)
      url = _G._NormalizeHttpURL(url)
      GameUtil.httpPost(url, 0, body, function(success, url, postId, retdata)
        if success then
          if retdata and retdata.string then
            local result = json.decode(retdata.string)
            warn("***Group Test--->JoinWXGroup -------------------", result.errcode)
            if result and result.errcode == 0 then
              local url = result.joinchatroomurl
              if ECMSDK.IsUrlInnerEncodeVersion() then
                Application.OpenURL(chatroomURL)
              else
                ECMSDK.OpenURL(chatroomURL)
              end
              require("Main.Gang.ui.HaveGangPanel").Instance():DestroyPanel()
            else
              Toast(textRes.Gang.GangGroup[21])
              Debug.LogWarning("\229\138\160\229\133\165\229\190\174\228\191\161\231\190\164\229\164\177\232\180\165")
            end
          else
            Debug.LogWarning("\232\167\163\230\158\144\229\138\160\229\133\165\229\184\174\230\180\190\231\190\164\228\191\161\230\129\175\229\164\177\232\180\165")
          end
        else
          Debug.LogWarning("\232\142\183\229\143\150\229\138\160\229\133\165\229\184\174\230\180\190\231\190\164\228\191\161\230\129\175\229\164\177\232\180\165")
        end
      end)
    end
  end
end
def.method().SendGangGroupMsg = function(self)
  if _G.LoginPlatform == _G.MSDK_LOGIN_PLATFORM.WX then
    self:SendWXGroupMsg()
  elseif _G.LoginPlatform == _G.MSDK_LOGIN_PLATFORM.QQ then
    self:SendQQGroupMsg()
  end
end
def.method().SendQQGroupMsg = function(self)
end
def.method().SendWXGroupMsg = function(self)
  if self.data:GetGangAnno() == "" then
    return
  end
  local title = self.data:GetGangAnno()
  self.data:SetGangAnno("")
  local subType = GangGroupUtility.MsgShareType.INVITE
  local gangGroupId = GangGroupUtility.GetGangGroupId()
  if gangGroupId == "" then
    return
  end
  local heroName = require("Main.Hero.Interface").GetHeroProp().name
  local desc = heroName .. textRes.Gang.GangGroup[22]
  local msgExt = ""
  local mediaTagName = "MSG_INVITE"
  local imgUrl = ECMSDK.LogoURL
  local msdkExtInfo = ""
  if platform == 2 then
    ECMSDK.SendToWXGroup(subType, gangGroupId, title, desc, msgExt, mediaTagName, imgUrl, msdkExtInfo)
  elseif platform == 1 then
    do
      local json = require("Utility.json")
      local sdkInfo = ECMSDK.GetMSDKInfo()
      if not sdkInfo or not sdkInfo.accessToken or not sdkInfo.appId then
        return
      end
      local url = "http://game.weixin.qq.com/cgi-bin/chatroom/gamechatroommessage?access_token=" .. sdkInfo.accessToken
      local params = {
        msg_type = 1,
        sub_type = subType,
        appid = sdkInfo.appId,
        groupid = gangGroupId,
        open = {
          title = title,
          desc = desc,
          ext_info = msgExt,
          message_ext = msdkExtInfo,
          media_tag_name = mediaTagName,
          url = imgUrl
        }
      }
      local body = json.encode(params)
      url = _G._NormalizeHttpURL(url)
      GameUtil.httpPost(url, 0, body, function(success, url, postId, retdata)
        if success then
          if retdata and retdata.string then
            local result = json.decode(retdata.string)
            warn("***Group Test--->JoinWXGroup -------------------", result)
            if result and result.errcode == 0 then
              Toast(textRes.Gang.GangGroup[24] or "")
              self.data:SetGroupBoundState(true)
              self.data:SetInGroupState(true)
              warn("***Group Test--->OnJoinWXGroup--->DispatchEvent--->Gang_GroupStateChanged")
              Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_GroupStateChanged, nil)
            else
              Toast(textRes.Gang.GangGroup[25] or "")
              Debug.LogWarning("\229\138\160\229\133\165\229\190\174\228\191\161\231\190\164\229\164\177\232\180\165")
            end
          else
            Debug.LogWarning("\232\167\163\230\158\144\229\138\160\229\133\165\229\184\174\230\180\190\231\190\164\228\191\161\230\129\175\229\164\177\232\180\165")
          end
        else
          Debug.LogWarning("\232\142\183\229\143\150\229\138\160\229\133\165\229\184\174\230\180\190\231\190\164\228\191\161\230\129\175\229\164\177\232\180\165")
        end
      end)
    end
  end
end
def.method("table").OnQueryGroupInfo = function(self, groupRet)
  if groupRet.platform == _G.MSDK_LOGIN_PLATFORM.QQ then
    self:OnQueryQQGroupInfo(groupRet)
  elseif groupRet.platform == _G.MSDK_LOGIN_PLATFORM.WX then
    self:OnQueryWXGroupInfo(groupRet)
  end
end
def.method("table").OnQueryQQGroupInfo = function(self, groupRet)
  if groupRet.flag == 0 then
    self.data:SetGroupBoundState(true)
    self.data:SetInGroupState(true)
    if self.isOnBindQQGroupQuery then
      self.isOnBindQQGroupQuery = false
      Toast(textRes.Gang.GangGroup[4])
    end
    if self.isReqJoinQQGroupQuery then
      self.isReqJoinQQGroupQuery = false
      Toast(textRes.Gang.GangGroup[5])
    end
    if GangGroupUtility.IsBangzhu() then
      self.data:UpdateQQGroupInfo(groupRet.mQQGroupInfo)
    end
  elseif groupRet.errorCode == 2002 then
    self.data:SetGroupBoundState(false)
    self.data:SetInGroupState(false)
    if self.isReqJoinQQGroupQuery then
      self.isReqJoinQQGroupQuery = false
      Toast(textRes.Gang.GangGroup[6])
    end
    if GangGroupUtility.IsBangzhu() then
      local groupOpenId = self.data:GetQQGroupOpenID()
      if groupOpenId ~= "" then
        self.data:NofityQQGroupUnbind()
      end
    end
  elseif groupRet.errorCode == 2003 then
    self.data:SetGroupBoundState(true)
    self.data:SetInGroupState(false)
    if self.isReqJoinQQGroupQuery then
      self.isReqJoinQQGroupQuery = false
      self:QueryQQGroupKey()
    end
  else
    if groupRet.errorCode == 2007 then
      if self.isReqJoinQQGroupQuery then
        self.isReqJoinQQGroupQuery = false
        Toast(textRes.Gang.GangGroup[7])
      end
      if GangGroupUtility.IsBangzhu() then
        Toast(textRes.Gang.GangGroup[8])
        self.data:SetGroupBoundState(true)
      else
        self.data:SetGroupBoundState(false)
      end
    else
    end
  end
  Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_GroupStateChanged, nil)
end
def.method("table").OnBindQQGroup = function(self, groupRet)
  if groupRet.flag == 0 then
    self.isOnBindQQGroupQuery = true
    GameUtil.AddGlobalTimer(5, true, function()
      self:QueryQQGroupInfo()
    end)
  else
  end
end
def.method("table").OnUnbindQQGroup = function(self, groupRet)
  if self.isUnbindQQGroupQuietly then
    self.isUnbindQQGroupQuietly = false
    if groupRet.flag == 0 then
      self.data:NofityQQGroupUnbind()
    else
    end
    return
  end
  if groupRet.flag == 0 then
    Toast(textRes.Gang.GangGroup[9])
    self.data:SetGroupBoundState(false)
    self.data:SetInGroupState(false)
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_GroupStateChanged, nil)
    self.data:NofityQQGroupUnbind()
  elseif groupRet.errorCode == 2001 then
    Toast(textRes.Gang.GangGroup[10])
  elseif groupRet.errorCode == 2003 then
    Toast(textRes.Gang.GangGroup[11])
  elseif groupRet.errorCode == 2004 then
    Toast(textRes.Gang.GangGroup[12])
  elseif groupRet.errorCode == 2005 then
    Toast(textRes.Gang.GangGroup[13])
  else
    Toast(textRes.Gang.GangGroup[14])
  end
end
def.method("table").OnQueryQQGroupKey = function(self, groupRet)
  if groupRet.flag == 0 then
    local groupKey = groupRet.mQQGroupInfo.groupKey
    if not groupKey or groupKey == "" then
      return
    end
    require("Main.Gang.ui.HaveGangPanel").Instance():DestroyPanel()
    ECMSDK.JoinQQGroup(groupKey)
  else
    Toast(textRes.Gang.GangGroup[15])
  end
end
def.method("table").OnQueryWXGroupInfo = function(self, groupRet)
  if groupRet.flag == 0 then
    self.data:SetGroupBoundState(true)
    local openIdList = groupRet.mWXGroupInfo.openIdList
    local isInGroup = GangGroupUtility.IsOpenIDInList(openIdList)
    self.data:SetInGroupState(isInGroup)
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_GroupStateChanged, nil)
  else
    self:HandleWXErrorCode(groupRet)
  end
end
def.method("table").HandleWXErrorCode = function(self, groupRet)
  if groupRet.errorCode == -10001 then
    Toast(textRes.Gang.GangGroup[16])
  elseif groupRet.errorCode == -10002 then
  elseif groupRet.errorCode == -10005 then
    Toast(textRes.Gang.GangGroup[17])
  elseif groupRet.errorCode == -10006 then
    Toast(textRes.Gang.GangGroup[18])
  elseif groupRet.errorCode == -10008 then
    Toast(textRes.Gang.GangGroup[27])
  else
    if groupRet.errorCode == -10007 then
      self.data:SetGroupBoundState(false)
      self.data:SetInGroupState(false)
      Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_GroupStateChanged, nil)
    else
    end
  end
end
def.method("table").OnCreateWXGroup = function(self, groupRet)
  if groupRet.flag == 0 then
    Toast(textRes.Gang.GangGroup[19])
    self.data:SetGroupBoundState(true)
    self.data:SetInGroupState(true)
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_GroupStateChanged, nil)
  else
    self:HandleWXErrorCode(groupRet)
  end
end
def.method("table").OnJoinWXGroup = function(self, groupRet)
  if groupRet.flag == 0 then
    Toast(textRes.Gang.GangGroup[20])
    self.data:SetGroupBoundState(true)
    self.data:SetInGroupState(true)
    Event.DispatchEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_GroupStateChanged, nil)
  else
    Toast(textRes.Gang.GangGroup[21])
    self:HandleWXErrorCode(groupRet)
  end
end
GangGroupMgr.Commit()
return GangGroupMgr
