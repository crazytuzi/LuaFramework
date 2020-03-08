local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECGUIMan = require("GUI.ECGUIMan")
local PubroleTip = Lplus.Extend(ECPanelBase, "PubroleTip")
local CommonRoleOperateMenu = require("GUI.CommonRoleOperateMenu")
local FriendModule = Lplus.ForwardDeclare("FriendModule")
local FriendUtils = Lplus.ForwardDeclare("FriendUtils")
local TitleInterface = require("Main.title.TitleInterface")
local Vector3 = require("Types.Vector3").Vector3
local def = PubroleTip.define
def.static("table", "table", "table", "=>", "table").ShowTip = function(pos, roleInfo, operations)
  local info = roleInfo
  local bIsOnline = roleInfo.onlineStatus == 1
  local closeness = 0
  local remarkName = ""
  local friendInfo = FriendModule.Instance():GetFriendInfo(info.roleId)
  if friendInfo then
    closeness = friendInfo.relationValue
    remarkName = friendInfo.remarkName
  end
  local intimacyPerBattle = FriendUtils.GetValuePerbattle()
  local fightdayLimit, fightTotalLimit, flowerdayLimt, flowerTotalLimit = FriendUtils.GetFriendValueLimit()
  local desc = string.format(textRes.Friend[23], intimacyPerBattle, fightTotalLimit, fightdayLimit, flowerTotalLimit)
  local tip = CommonRoleOperateMenu.Instance()
  tip.name = info.name
  tip.level = info.level
  tip.occupationId = info.occupationId
  tip.gender = info.gender
  tip.teamMenberNum = info.teamMemberNum
  tip.isOnline = bIsOnline
  tip.roleId = info.roleId
  tip.closeness = closeness
  tip.closenessTips = desc
  tip.avatarId = info.avatarId
  tip.avatarFrameId = info.avatarFrameId or 0
  tip.remarkName = remarkName
  tip.isFriend = friendInfo ~= nil
  if info.appellationInfo then
    local appellationId, appArgs = info.appellationInfo.appellationId, info.appellationInfo.appArgs
    tip.appellation = TitleInterface.GetAppellationName(appellationId, appArgs)
  end
  if Int64.eq(-1, info.gangId) == false and info.gangName ~= nil then
    tip.gangName = info.gangName
  end
  tip.operateItemList = {}
  for i, v in ipairs(operations) do
    table.insert(tip.operateItemList, v:GetOperationName())
  end
  local tag = {roleInfo = roleInfo, operations = operations}
  tip:ShowPanel(PubroleTip.CommonOperateCallback, tag)
  tip:SetPos(pos)
  return tip
end
def.static("number", "table", "=>", "boolean").CommonOperateCallback = function(index, tag)
  local roleInfo = tag.roleInfo
  local operations = tag.operations
  local operation = operations[index]
  return operation:ExecuteOperation(roleInfo)
end
return PubroleTip.Commit()
