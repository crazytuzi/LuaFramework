local Lplus = require("Lplus")
local ECMSDK = require("ProxySDK.ECMSDK")
local GangGroupUtility = Lplus.Class("GangGroupUtility")
local def = GangGroupUtility.define
def.const("string").CREATED_GANGID = "CreatedGangID"
def.const("string").JOINED_GANGID = "JoinedGangID"
def.const("table").MsgShareType = {
  INVITE = 1,
  SHOWOFF = 2,
  PRESENT = 3,
  DEMAND = 4
}
def.static("=>", "boolean").IsBangzhu = function()
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local memberInfo = require("Main.Gang.data.GangData").Instance():GetMemberInfoByRoleId(heroProp.id)
  local bangzhuId = require("Main.Gang.GangUtility").GetGangConsts("BANGZHU_ID")
  return memberInfo and memberInfo.duty == bangzhuId
end
def.static("string", "=>", "boolean").IsOpenIDInList = function(openIdList)
  local idList = string.split(openIdList, ",")
  local openId = ECMSDK.GetMSDKInfo().openId
  for i = 1, #idList do
    if idList[i] == openId then
      return true
    end
  end
  return false
end
def.static("string", "string").SaveGangGroupPlayerConst = function(name, value)
  if not name or not value then
    return
  end
  local PlayerPref = require("Main.Common.LuaPlayerPrefs")
  PlayerPref.SetRoleString(name, value)
  PlayerPref.Save()
end
def.static("=>", "boolean").ShouldShowBindGroupGuide = function()
  if _G.LoginPlatform ~= _G.MSDK_LOGIN_PLATFORM.WX and _G.LoginPlatform ~= _G.MSDK_LOGIN_PLATFORM.QQ then
    return false
  end
  local curGangId = require("Main.Gang.data.GangData").Instance():GetGangId()
  if not curGangId then
    return false
  end
  local isBangzhu = GangGroupUtility.IsBangzhu()
  if not isBangzhu then
    return false
  end
  local GangGroupData = require("Main.Gang.GangGroup.GangGroupData")
  local isGroupBound = GangGroupData.Instance():IsGroupBound()
  if isGroupBound then
    return false
  end
  local PlayerPref = require("Main.Common.LuaPlayerPrefs")
  local createdGangId = PlayerPref.GetRoleString(GangGroupUtility.CREATED_GANGID)
  curGangId = Int64.tostring(curGangId)
  if not createdGangId or createdGangId ~= curGangId then
    GangGroupUtility.SaveGangGroupPlayerConst(GangGroupUtility.CREATED_GANGID, curGangId)
    return true
  end
  return false
end
def.static("=>", "boolean").ShouldShowJoinGroupGuide = function()
  if _G.LoginPlatform ~= _G.MSDK_LOGIN_PLATFORM.WX and _G.LoginPlatform ~= _G.MSDK_LOGIN_PLATFORM.QQ then
    return false
  end
  local curGangId = require("Main.Gang.data.GangData").Instance():GetGangId()
  if not curGangId then
    return false
  end
  local isBangzhu = GangGroupUtility.IsBangzhu()
  if isBangzhu then
    return false
  end
  local GangGroupData = require("Main.Gang.GangGroup.GangGroupData")
  local isGroupBound = GangGroupData.Instance():IsGroupBound()
  if not isGroupBound then
    return false
  end
  local isJoinedGroup = GangGroupData.Instance():IsInGroup()
  if isJoinedGroup then
    return false
  end
  local PlayerPref = require("Main.Common.LuaPlayerPrefs")
  local joinedGangId = PlayerPref.GetRoleString(GangGroupUtility.JOINED_GANGID)
  curGangId = Int64.tostring(curGangId)
  if not joinedGangId or joinedGangId ~= curGangId then
    GangGroupUtility.SaveGangGroupPlayerConst(GangGroupUtility.JOINED_GANGID, curGangId)
    return true
  end
  return false
end
def.static().CheckShowJoinGroupPrompt = function()
  local GangGroupMgr = require("Main.Gang.GangGroup.GangGroupMgr")
  if GangGroupUtility.ShouldShowJoinGroupGuide() then
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowConfirm(textRes.Gang[296], textRes.Gang[295], function(id, tag)
      if id == 1 then
        GangGroupMgr.Instance():JoinGangGroup()
      end
    end, nil)
  end
end
def.static().CheckShowBindGroupPrompt = function()
  local GangGroupMgr = require("Main.Gang.GangGroup.GangGroupMgr")
  if GangGroupUtility.ShouldShowBindGroupGuide() then
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowConfirm(textRes.Gang[297], textRes.Gang[298], function(id, tag)
      if id == 1 then
        GangGroupMgr.Instance():BindGangGroup()
      end
    end, nil)
  end
end
def.static("=>", "string").GetGangGroupId = function()
  local GangData = require("Main.Gang.data.GangData")
  local gangId = GangData.Instance():GetGangId()
  if not gangId then
    return ""
  end
  local createTime = GangData.Instance():GetGangCreateTime()
  return tostring(createTime) .. Int64.tostring(gangId)
end
GangGroupUtility.Commit()
return GangGroupUtility
