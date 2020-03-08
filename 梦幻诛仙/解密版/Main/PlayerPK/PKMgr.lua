local Lplus = require("Lplus")
local PKMgr = Lplus.Class("PKMgr")
local def = PKMgr.define
local instance
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local PKProtocols = require("Main.PlayerPK.PK.PKProtocols")
local PKInterface = require("Main.PlayerPK.PK.PKInterface")
local PKData = require("Main.PlayerPK.PK.data.PKData")
local TeamData = require("Main.Team.TeamData")
local TeamModule = require("Main.Team.TeamModule")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local txtConst = textRes.PlayerPK.PK
local const = constant.CPKConsts
def.field("table")._data = nil
def.static("=>", PKMgr).Instance = function()
  if instance == nil then
    instance = PKMgr()
    instance._data = PKData()
  end
  return instance
end
def.method().Init = function(self)
  PKProtocols.Instance():Init()
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, PKMgr.OnFeatureInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, PKMgr.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, PKMgr.OnNPCService)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, PKMgr.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.PLAYER_PK, gmodule.notifyId.PlayerPK.GetRoleName, PKMgr.OnGetRoleName)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, PKMgr.OnActivityTodo)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, PKMgr.OnMapChange)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_InfoChanged, PKMgr.OnActivityInfoChanged)
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  ItemTipsMgr.RegisterPostTipsHandler(ItemType.PK_REVENGE_ITEM, PKMgr.PostTipsContentHandler)
end
def.static("table", "table").OnFeatureInit = function(p, c)
  local bIsFeatureOpen = PKMgr.IsFeatureOpen()
  PKMgr._updateActivityInterface()
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {
    npcid = const.PK_NPC_ID,
    show = bIsFeatureOpen
  })
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {
    npcid = const.MORAL_VALUE_NPC_ID,
    show = bIsFeatureOpen
  })
end
def.static("table", "table").OnFeatureOpenChange = function(p, c)
  local bIsFeatureOpen = PKMgr.IsFeatureOpen()
  PKMgr._updateActivityInterface()
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {
    npcid = const.PK_NPC_ID,
    show = bIsFeatureOpen
  })
  Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {
    npcid = const.MORAL_VALUE_NPC_ID,
    show = bIsFeatureOpen
  })
end
def.static("table", "table").OnNPCService = function(p, c)
  if not PKMgr.IsFeatureOpen() then
    return
  end
  local srvcId = p[1] and p[1] or 0
  local npcId = p[2] and p[2] or 0
  if npcId ~= const.PK_NPC_ID and npcId ~= const.MORAL_VALUE_NPC_ID then
    return
  end
  if srvcId == const.ENABLE_PK_SERVICE_ID then
    PKMgr._doSwitchOnPkSrvc()
  elseif srvcId == const.BUY_MORAL_VALUE_SERVICE_ID then
    PKMgr._doBuyMeritSrvc()
  elseif srvcId == const.MORAL_ACTIVITY_SERVICE_ID then
    PKMgr._doMeritActivitySrvc()
  end
end
def.static("table", "table").OnLeaveWorld = function(p, c)
  PKMgr.Instance()._data = PKData()
end
def.static("table", "table").OnEnterFight = function(p, c)
  if not PKMgr.IsFeatureOpen() then
    return
  end
  local fightMgr = require("Main.Fight.FightMgr").Instance()
  local FIGHT_TYPE = require("consts.mzm.gsp.fight.confbean.FightType")
  local data = PKMgr.GetData()
  if data.activeRoleId == nil or data.passiveRoleId == nil then
    return
  end
  local activeTeam = fightMgr.teams[_G.FightConst.ACTIVE_TEAM]
  local passiveTeam = fightMgr.teams[_G.FightConst.PASSIVE_TEAM]
  local myRoleId = _G.GetHeroProp().id
  local pRoleInfo, aRoleInfo, myFightUnit
  for k, roleInfo in pairs(fightMgr.fightUnits) do
    if roleInfo.roleId:eq(data.passiveRoleId) then
      pRoleInfo = roleInfo
    elseif roleInfo.roleId:eq(data.activeRoleId) then
      aRoleInfo = roleInfo
    end
    if roleInfo.roleId:eq(myRoleId) then
      myFightUnit = roleInfo
    end
  end
  if myRoleId:eq(data.activeRoleId) then
    Toast(txtConst[43]:format(pRoleInfo.name))
  elseif myFightUnit.team == passiveTeam.teamId then
    Toast(txtConst[44]:format(aRoleInfo.name))
  end
end
def.static("table", "table").OnGetRoleName = function(p, c)
  PKMgr.UpdateItemTipsContent(p.name)
end
def.static("table", "table").OnActivityTodo = function(p, c)
  local actId = p[1] and p[1] or 0
  if actId ~= const.MORAL_TASK_ACTIVITY_ID then
    return
  end
  if PKMgr.IsBeWanted() then
    Toast(txtConst[61])
    return
  end
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
    const.PK_NPC_ID
  })
end
def.static("table", "table").OnActivityInfoChanged = function(p, c)
  local actId = p[1] and p[1] or 0
  if actId == const.MORAL_TASK_ACTIVITY_ID then
    local ActivityInterface = require("Main.activity.ActivityInterface")
    local activityInfo = ActivityInterface.Instance():GetActivityInfo(actId)
    local actCfgInfo = ActivityInterface.GetActivityCfgById(actId)
    if activityInfo ~= nil and activityInfo.count >= actCfgInfo.limitCount then
    else
      local times = activityInfo and activityInfo.count or 0
      local strContent = txtConst[78]:format(actCfgInfo.limitCount - times)
      if 1 > actCfgInfo.limitCount - times then
        return
      end
      CommonConfirmDlg.ShowConfirm(txtConst[77], strContent, function(select)
        if select == 1 then
          PKProtocols.SendAcceptMeritTaskReq()
        end
      end, nil)
    end
  end
end
def.static("table", "table").OnMapChange = function(p, c)
  if not PKMgr.IsFeatureOpen() then
    return
  end
  local mapId = p[1] and p[1] or 0
  local oldMapId = p[2] and p[2] or 0
  local mapCfg = require("Main.Map.MapUtility").GetMapCfg(mapId)
  if mapCfg.canPK then
    Toast(txtConst[66])
  end
end
def.static()._updateActivityInterface = function()
  local activityInterface = require("Main.activity.ActivityInterface").Instance()
  local bFeatureOpen = PKMgr.IsFeatureOpen()
  if bFeatureOpen then
    activityInterface:removeCustomCloseActivity(const.MORAL_TASK_ACTIVITY_ID)
  else
    activityInterface:addCustomCloseActivity(const.MORAL_TASK_ACTIVITY_ID)
  end
end
def.static("=>", "boolean").IsFeatureOpen = function()
  local bFeatureOpen = FeatureOpenListModule.Instance():CheckFeatureOpen(Feature.TYPE_PK)
  return bFeatureOpen
end
def.static("=>", "table").GetData = function()
  return PKMgr.Instance()._data
end
def.static("=>", "table").GetProtocols = function()
  return PKProtocols
end
def.static("=>", "boolean").IsInTeamAndNotLeader = function()
  if not TeamData.Instance():HasTeam() then
    return false
  end
  if TeamData.Instance():MeIsCaptain() then
    return false
  end
  if TeamData.Instance():GetStatus() == require("netio.protocol.mzm.gsp.team.TeamMember").ST_NORMAL then
    return true
  else
    return false
  end
end
def.static()._doSwitchOnPkSrvc = function()
  if _G.GetHeroProp().level < const.ENABLE_PK_LEVEL then
    Toast(txtConst[63]:format(const.ENABLE_PK_LEVEL))
    return
  end
  if PKInterface.IsInEnablePKST() then
    Toast(txtConst[23])
  elseif PKInterface.IsInForceProtectionST() then
    Toast(txtConst[31])
  else
    require("Main.PlayerPK.PK.ui.UIPKConds").Instance():ShowPanel()
  end
end
def.static()._doBuyMeritSrvc = function()
  if _G.GetHeroProp().level < const.ENABLE_PK_LEVEL then
    Toast(txtConst[63]:format(const.ENABLE_PK_LEVEL))
    return
  end
  if PKMgr.IsBeWanted() then
    Toast(txtConst[54])
  else
    require("Main.PlayerPK.PK.ui.UIBuyMerit").Instance():ShowPanel()
  end
end
def.static()._doMeritActivitySrvc = function()
  if _G.GetHeroProp().level < const.ENABLE_PK_LEVEL then
    Toast(txtConst[63]:format(const.ENABLE_PK_LEVEL))
    return
  end
  if PKMgr.IsBeWanted() then
    Toast(txtConst[54])
  elseif PKMgr.IsActivityFinish() then
    Toast(txtConst[55])
  else
    PKProtocols.SendAcceptMeritTaskReq()
  end
end
def.static("=>", "boolean").IsActivityFinish = function()
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local actId = const.MORAL_TASK_ACTIVITY_ID
  local activityInfo = ActivityInterface.Instance():GetActivityInfo(actId)
  local actCfgInfo = ActivityInterface.GetActivityCfgById(actId)
  if activityInfo ~= nil and activityInfo.count >= actCfgInfo.limitCount then
    return true
  end
  return false
end
def.static("=>", "boolean").IsBeWanted = function()
  local ItemModule = require("Main.Item.ItemModule")
  local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
  local curMerit = ItemModule.Instance():GetCredits(TokenType.MORAL_VALUE) or Int64.new(0)
  return Int64.lt(curMerit, const.WANTED_MORAL_VALUE) or Int64.eq(curMerit, const.WANTED_MORAL_VALUE)
end
def.static("table", "table", "table").PostTipsContentHandler = function(item, itemBase, itemTips)
  if itemTips == nil then
    return
  end
  local data = PKMgr.GetData()
  data:SetItemTips(itemTips)
  data:SetItem(item)
  local roleId = PKMgr.GetRoleIdFromItem(item)
  data:SetRoleId(roleId)
  if roleId ~= nil then
    PKProtocols.SendQueryUsrnameReq(roleId)
  end
end
def.static("table", "=>", "userdata").GetRoleIdFromItem = function(item)
  if item == nil then
    return Int64.new(0)
  end
  local ItemUtils = require("Main.Item.ItemUtils")
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local roleId = ItemUtils.GetRoleIdByItem(item, ItemXStoreType.PK_REVENGE_ITEM_BIND_LOW, ItemXStoreType.PK_REVENGE_ITEM_BIND_HIGH)
  return roleId
end
def.static("string").UpdateItemTipsContent = function(strTarget)
  local data = PKMgr.GetData()
  local itemTips = data:GetItemTips()
  if itemTips == nil or not itemTips:IsShow() then
    return
  end
  local desc = itemTips.desc
  itemTips.desc = ""
  local roleid = data:GetRoleId()
  local idNum = require("Main.Hero.HeroUtility").Instance():RoleIDToDisplayID(roleid)
  idNum = idNum and idNum:tostring() or ""
  local appendHtml = desc:format(strTarget, idNum)
  itemTips:AppendContent(appendHtml)
end
return PKMgr.Commit()
