local Lplus = require("Lplus")
require("Main.module.ModuleId")
local ModuleBase = require("Main.module.ModuleBase")
local PlantTreeModule = Lplus.Extend(ModuleBase, "PlantTreeModule")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local ActivityInterface = require("Main.activity.ActivityInterface")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local UIPlantTree = require("Main.PlantTree.ui.UIPlantTree")
local def = PlantTreeModule.define
def.field("boolean")._bMoneyTreeFeatureOpen = false
local instance
def.static("=>", PlantTreeModule).Instance = function()
  if instance == nil then
    instance = PlantTreeModule()
    instance.m_moduleId = ModuleId.PLANT_TREE
  end
  return instance
end
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.planttree.SGetRelatedRolePlantTreeSpecialStateSuccess", UIPlantTree.OnSGetRelatedRolePlantTreeSpecialStateSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.planttree.SGetRelatedRolePlantTreeSpecialStateFail", UIPlantTree.OnSGetRelatedRolePlantTreeSpecialStateFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.planttree.SAddPointFail", UIPlantTree.OnAddPointFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.planttree.SAddPointSuccess", UIPlantTree.OnAddPointSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.planttree.SGetActivityCompleteAwardFail", UIPlantTree.OnSGetActivityCompleteAwardFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.planttree.SGetActivityCompleteAwardSuccess", UIPlantTree.OnSGetActivityCompleteAwardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.planttree.SGetPlantTreeDetailInfoFail", UIPlantTree.OnSGetPlantTreeDetailInfoFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.planttree.SGetSectionCompleteAwardSuccess", UIPlantTree.OnSGetSectionCompleteAwardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.planttree.SGetSectionCompleteAwardFail", UIPlantTree.OnSGetSectionCompleteAwardFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.planttree.SRemoveSpecialStateFail", UIPlantTree.OnSRemoveSpecialStateFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.planttree.SSynPlantTreeBasicInfo", PlantTreeModule.OnSSynPlantTreeBasicInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.planttree.SSynPlantTreeDetailInfo", PlantTreeModule.OnSSynPlantTreeDetailInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.planttree.SSynPlantTreeUpdateInfo", PlantTreeModule.OnSSynPlantTreeUpdateInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.planttree.SSynRolePlantTreeInfo", PlantTreeModule.OnSSynRolePlantTreeInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.friend.SAddNewFriendRes", UIPlantTree.OnSyncFriendList)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.moneytree.SAttendMoneyTreeFail", PlantTreeModule.OnSAttendMoneyTreeFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.moneytree.SAttendMoneyTreeSuccess", PlantTreeModule.OnSAttendMoneyTreeSuccess)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, PlantTreeModule.OnActivityTodo)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, PlantTreeModule.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, PlantTreeModule.OnMoneyTreeFeatureOpenChange)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, PlantTreeModule.OnNPCService)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, PlantTreeModule.OnMoneyTreeFeatureInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, PlantTreeModule.OnFeatureInit)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, UIPlantTree.OnHeroLvUp)
  ModuleBase.Init(self)
end
def.static("table", "table").OnActivityTodo = function(param, context)
  if constant.CMoneyTreeConsts.ACTIVITY_CFG_ID == param[1] then
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
      constant.CMoneyTreeConsts.NPC_ID
    })
    return
  end
  if not PlantTreeModule.PlantTreeFeatureOpen() then
    return
  end
  local acts = require("Main.PlantTree.PlantTreeUtils").GetModuleActs()
  if acts == nil then
    return
  end
  local bHasAct = false
  for i = 1, #acts do
    local data = acts[i]
    if data.actId == param[1] then
      bHasAct = true
      break
    end
  end
  if not bHasAct then
    return
  end
  local objUIPlantTree = UIPlantTree.Instance()
  objUIPlantTree._activityId = param[1]
  objUIPlantTree:ShowPanel()
end
local G_bPlantTreeOpened = false
def.static("=>", "boolean").PlantTreeFeatureOpen = function()
  return G_bPlantTreeOpened
end
def.static("number", "=>", "table").GetActivityIdByModuleId = function(moduleId)
  local data = {}
  local record = DynamicData.GetRecord(CFG_PATH.DATA_PLANT_TREE_MODULE_CFG, moduleId)
  if record == nil then
    warn(">>>>Get PlantTreeModule cfg data return nil, moduleId = " .. moduleId .. "<<<<")
    return data
  end
  data.activityId = record:GetIntValue("activity_cfg_id")
  return data
end
def.static("table").OnSSynPlantTreeBasicInfo = function(p)
  UIPlantTree.OnGetPlantTreeBasicInfo(p)
end
def.static("table").OnSSynPlantTreeDetailInfo = function(p)
  UIPlantTree.OnGetPlantTreeDetailInfo(p)
end
def.static("table").OnSSynPlantTreeUpdateInfo = function(p)
  UIPlantTree.OnUpdatePlantTreeState(p)
end
def.static("table").OnSSynRolePlantTreeInfo = function(p)
  UIPlantTree.OnRcvRolePlantTreeInfo(p)
end
def.static("table", "table").OnNPCService = function(tbl, p2)
  local featureOpenModule = FeatureOpenListModule.Instance()
  local bFeatureOpen = featureOpenModule:CheckFeatureOpen(Feature.TYPE_MONEY_TREE)
  if not bFeatureOpen then
    return
  end
  local CMoneyTreeConsts = constant.CMoneyTreeConsts
  local srvId = tbl[1]
  warn("==>SERVICE id  = " .. srvId .. " cfg srvId = " .. CMoneyTreeConsts.NPC_SERVICE_ID)
  if srvId == CMoneyTreeConsts.NPC_SERVICE_ID then
    local actCfg = ActivityInterface.GetActivityCfgById(CMoneyTreeConsts.ACTIVITY_CFG_ID)
    local maxCount = actCfg.limitCount
    if not PlantTreeModule.IsCanJoinActivity(CMoneyTreeConsts.ACTIVITY_CFG_ID, maxCount, textRes.PlantTree[31]) then
      return
    end
    local p = require("netio.protocol.mzm.gsp.moneytree.CAttendMoneyTreeReq").new()
    gmodule.network.sendProtocol(p)
  end
end
def.static("number", "number", "string", "=>", "boolean").IsCanJoinActivity = function(actId, maxCount, tipMsg)
  local myselfInfo = require("Main.Hero.HeroModule").Instance():GetHeroProp()
  local activityInterface = ActivityInterface.Instance()
  local activityCfg = ActivityInterface.GetActivityCfgById(actId)
  if myselfInfo.level < activityCfg.levelMin or myselfInfo.level > activityCfg.levelMax then
    Toast(string.format(textRes.PlantTree[34], activityCfg.levelMin))
    return false
  end
  local activityInfo = activityInterface:GetActivityInfo(actId)
  if activityInfo ~= nil and maxCount <= activityInfo.count then
    Toast(string.format(tipMsg, activityInfo.count, maxCount))
    return false
  end
  return true
end
def.static("table").OnSAttendMoneyTreeFail = function(p)
  local SAttendMoneyTreeFail = require("netio.protocol.mzm.gsp.moneytree.SAttendMoneyTreeFail")
  if p.res == SAttendMoneyTreeFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN then
    warn(">>>>MODULE_CLOSE_OR_ROLE_FORBIDDEN<<<<")
  elseif p.res == SAttendMoneyTreeFail.CHECK_NPC_SERVICE_ERROR then
    warn(">>>>ROLE_STATUS_ERROR<<<<")
  elseif p.res == SAttendMoneyTreeFail.CAN_NOT_JOIN_ACTIVITY then
    warn(">>>>CAN_NOT_JOIN_ACTIVITY<<<<")
  elseif p.res == SAttendMoneyTreeFail.AWARD_FAIL then
    warn(">>>>AWARD_FAIL<<<<")
  end
end
def.static("table").OnSAttendMoneyTreeSuccess = function(p)
  local PubroleModule = require("Main.Pubrole.PubroleModule").Instance()
  local CMoneyTreeConsts = constant.CMoneyTreeConsts
  local npcRoleInfo = PubroleModule.npcMap[CMoneyTreeConsts.NPC_ID]
  if npcRoleInfo ~= nil then
    local effRes = GetEffectRes(CMoneyTreeConsts.EFFECT_ID)
    if effRes then
      npcRoleInfo:AddChildEffect(effRes.path, 2, "", -2.5)
    end
  end
  local AwardUtils = require("Main.Award.AwardUtils")
  local str = textRes.PlantTree[30]
  local awardTbl = AwardUtils.GetHtmlTextsFromAwardBean(p.awardInfo, str)
  for _, v in pairs(awardTbl) do
    Toast(v)
  end
end
def.static("table", "table").OnMoneyTreeFeatureOpenChange = function(p, context)
  local activityInterface = ActivityInterface.Instance()
  local activityId = constant.CMoneyTreeConsts.ACTIVITY_CFG_ID
  if p.feature == Feature.TYPE_MONEY_TREE then
    if p.open then
      activityInterface:removeCustomCloseActivity(activityId)
    else
      activityInterface:addCustomCloseActivity(activityId)
    end
    local objPlantTreeModule = PlantTreeModule.Instance()
    objPlantTreeModule._bMoneyTreeFeatureOpen = p.open
  end
end
def.static("table", "table").OnMoneyTreeFeatureInit = function(p, context)
  local featureOpenModule = FeatureOpenListModule.Instance()
  local activityInterface = ActivityInterface.Instance()
  local bFeatureOpen = featureOpenModule:CheckFeatureOpen(Feature.TYPE_MONEY_TREE)
  local activityId = constant.CMoneyTreeConsts.ACTIVITY_CFG_ID
  if bFeatureOpen then
    activityInterface:removeCustomCloseActivity(activityId)
  else
    activityInterface:addCustomCloseActivity(activityId)
  end
end
def.static("table", "table").OnFeatureInit = function(p, context)
  local featureOpenModule = FeatureOpenListModule.Instance()
  local activityInterface = ActivityInterface.Instance()
  local acts = require("Main.PlantTree.PlantTreeUtils").GetModuleActs()
  if acts == nil then
    return
  end
  for i = 1, #acts do
    local data = acts[i]
    local bFeatureOpen = featureOpenModule:CheckFeatureOpen(data.moduleId)
    if bFeatureOpen then
      local uiPlantTree = UIPlantTree.Instance()
      uiPlantTree._activityId = data.actId
      activityInterface:removeCustomCloseActivity(data.actId)
      G_bPlantTreeOpened = true
    else
      activityInterface:addCustomCloseActivity(data.actId)
      G_bPlantTreeOpened = false
    end
  end
end
def.static("table", "table").OnFeatureOpenChange = function(p, context)
  local activityInterface = ActivityInterface.Instance()
  local acts = require("Main.PlantTree.PlantTreeUtils").GetModuleActs()
  if acts == nil then
    return
  end
  local bHasAct = false
  for i = 1, #acts do
    local data = acts[i]
    if p.feature == data.moduleId then
      if p.open then
        local uiPlantTree = UIPlantTree.Instance()
        uiPlantTree._activityId = data.actId
        activityInterface:removeCustomCloseActivity(data.actId)
        G_bPlantTreeOpened = true
      else
        activityInterface:addCustomCloseActivity(data.actId)
        G_bPlantTreeOpened = false
      end
    end
  end
end
PlantTreeModule.Commit()
return PlantTreeModule
