local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local QixiModule = Lplus.Extend(ModuleBase, "QixiModule")
require("Main.module.ModuleId")
local ActivityInterface = require("Main.activity.ActivityInterface")
local def = QixiModule.define
local instance
local NPCServiceConst = require("Main.npc.NPCServiceConst")
def.field("table").gamedata = nil
def.const("number").CAGE_NUM = 3
def.field("table").gamecfg = nil
def.static("=>", QixiModule).Instance = function()
  if instance == nil then
    instance = QixiModule()
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chinesevalentine.SChineseValentineJoinFailRep", QixiModule.OnSChineseValentineJoinFailRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chinesevalentine.SChineseValentineGameInfo", QixiModule.OnSChineseValentineGameInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chinesevalentine.SChineseValentinePrepare", QixiModule.OnSChineseValentinePrepare)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chinesevalentine.SChineseValentineClickErrorRep", QixiModule.OnSChineseValentineClickErrorRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chinesevalentine.SNotifyChineseValentineClick", QixiModule.OnSNotifyChineseValentineClick)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chinesevalentine.SChineseValentineRound", QixiModule.OnSChineseValentineRound)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chinesevalentine.SChineseValentineRoundResult", QixiModule.OnSChineseValentineRoundResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chinesevalentine.SNotifyPreviewChineseValentine", QixiModule.OnSNotifyPreviewChineseValentine)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, QixiModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, QixiModule.OnActivityTodo)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, QixiModule.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, QixiModule.OnFeatureOpenInit)
end
def.method("number", "=>", "table").GetActivityCfg = function(self, activityId)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_QIXI_CFG, activityId)
  if record == nil then
    warn("[GetQixiCfg]get nil record for id: ", activityId)
    return nil
  end
  local cfg = {}
  cfg.activityId = record:GetIntValue("activityId")
  cfg.endEffectId = record:GetIntValue("endEffectId")
  cfg.endRoundEffectTime = record:GetIntValue("endRoundEffectTime") / 1000
  cfg.failEffectId = record:GetIntValue("failEffectId")
  cfg.prepareTime = record:GetIntValue("prepareTime") / 1000
  cfg.highLightTime = record:GetIntValue("highLightTime") / 1000
  cfg.roadMaxTime = record:GetIntValue("roadMaxTime") / 1000
  cfg.roundMax = record:GetIntValue("roundMax")
  cfg.ruleId = record:GetIntValue("ruleId")
  cfg.successEffectId = record:GetIntValue("successEffectId")
  cfg.finalRoundDelayTime = record:GetIntValue("finalRoundDelayTime") / 1000
  cfg.birdsCollisionEffectId = record:GetIntValue("birdsCollisionEffectId")
  return cfg
end
def.method().PrepareData = function(self)
  if instance.gamedata ~= nil then
    return
  end
  instance.gamedata = {}
  if instance.gamecfg == nil then
    instance.gamecfg = instance:GetActivityCfg(constant.QixiConsts.activityId)
  end
  instance.gamedata.curRound = 0
end
def.method("userdata", "=>", "boolean").IsCaptain = function(self, roleId)
  if self.gamedata == nil then
    return false
  end
  if roleId == nil then
    roleId = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetMyRoleId()
  end
  local captainId = self.gamedata.roleIdList and self.gamedata.roleIdList[1]
  if roleId and captainId and roleId:eq(captainId) then
    return true
  else
    return false
  end
end
def.static("table").OnSChineseValentineGameInfo = function(p)
  instance:PrepareData()
  instance.gamedata.curRound = p.roundNumber
  instance.gamedata.rightCount = p.rightCount
  instance.gamedata.wrongCount = p.wrongCount
  instance.gamedata.roleIdList = p.roleIdList
  if instance:IsCaptain(nil) then
    instance.gamedata.myteam = 1
  else
    instance.gamedata.myteam = 2
  end
  require("Main.Qixi.ui.QixiInstruction").Instance():Hide()
  require("Main.Qixi.ui.QixiGame").Instance():ShowDlg()
end
def.static("table").OnSChineseValentineJoinFailRep = function(p)
  local tipstr = textRes.activity.Qixi.ErrorCode.JoinFail[p.code]
  if tipstr then
    Toast(tipstr)
  else
    Toast(string.format(textRes.activity.Qixi.ErrorCode[0], "JoinFail", p.code))
  end
end
def.static("table").OnSChineseValentinePrepare = function(p)
  if instance.gamedata == nil then
    return
  end
  instance.gamedata.curRound = instance.gamedata.curRound + 1
  instance.gamedata.highLightMap = nil
  require("Main.Qixi.ui.QixiGame").Instance():Prepare()
end
def.static("table").OnSChineseValentineClickErrorRep = function(p)
  local tipstr = textRes.activity.Qixi.ErrorCode.ClickError[p.code]
  if tipstr then
    Toast(tipstr)
  else
    Toast(string.format(textRes.activity.Qixi.ErrorCode[0], "ClickError", p.code))
  end
end
def.static("table").OnSChineseValentineRound = function(p)
  if instance.gamedata == nil then
    return
  end
  instance.gamedata.highLightMap = {}
  for k, v in pairs(p.highLightMap) do
    local teamIdx = instance:GetTeamIdx(k)
    if teamIdx > 0 then
      instance.gamedata.highLightMap[teamIdx] = v
    end
  end
  require("Main.Qixi.ui.QixiGame").Instance():ShowHighLightCage()
end
def.method("userdata", "=>", "number").GetTeamIdx = function(self, roleId)
  if roleId == nil then
    return 0
  end
  if self:IsCaptain(roleId) then
    return 1
  else
    return 2
  end
end
def.method("number", "=>", "number").GetTargetIdx = function(self, teamIdx)
  if instance.gamedata == nil or instance.gamedata.highLightMap == nil then
    return 0
  end
  local targetIdx = 0
  for k, v in pairs(instance.gamedata.highLightMap) do
    if k ~= teamIdx then
      targetIdx = v + (k - 1) * QixiModule.CAGE_NUM
      break
    end
  end
  return targetIdx
end
def.static("table").OnSNotifyChineseValentineClick = function(p)
  if instance.gamedata == nil or instance.gamedata.highLightMap == nil then
    return
  end
  local teamIdx = instance:GetTeamIdx(p.roleId)
  if teamIdx > 0 then
    local idx = instance.gamedata.highLightMap[teamIdx]
    local cage_idx = (teamIdx - 1) * QixiModule.CAGE_NUM + idx
    local targetIdx = instance:GetTargetIdx(teamIdx)
    require("Main.Qixi.ui.QixiGame").Instance():FlyBird(cage_idx, targetIdx)
  end
end
def.static("table").OnSNotifyPreviewChineseValentine = function(p)
  require("Main.Qixi.ui.QixiInstruction").Instance():ShowDlg()
end
def.static("table").OnSChineseValentineRoundResult = function(p)
  if instance.gamedata == nil then
    return
  end
  local success = p.code == p.SUCCESS
  if success then
    instance.gamedata.rightCount = instance.gamedata.rightCount + 1
  else
    instance.gamedata.wrongCount = instance.gamedata.wrongCount + 1
  end
  local dlg = require("Main.Qixi.ui.QixiGame").Instance()
  if instance.gamedata.highLightMap then
    for k, v in pairs(instance.gamedata.highLightMap) do
      local highlight_idx = (k - 1) * QixiModule.CAGE_NUM + v
      dlg:RemoveHighLightCage(highlight_idx)
    end
  end
  dlg:ShowResult(success)
  if p.roundNumber == instance.gamecfg.roundMax then
    local close_delay = instance.gamecfg.endRoundEffectTime + instance.gamecfg.finalRoundDelayTime
    GameUtil.AddGlobalTimer(instance.gamecfg.endRoundEffectTime, true, function()
      if instance.gamecfg == nil then
        return
      end
      local effdata = _G.GetEffectRes(instance.gamecfg.endEffectId)
      require("Fx.GUIFxMan").Instance():Play(effdata.path, "", 0, 0, -1, false)
    end)
    GameUtil.AddGlobalTimer(close_delay, true, function()
      instance:LeaveGame()
      require("Main.Qixi.ui.QixiGame").Instance():Hide()
    end)
  end
end
def.method().LeaveGame = function(self)
  require("Main.Qixi.ui.QixiGame").Instance():Hide()
  self.gamedata = nil
  self.gamecfg = nil
end
def.static("table", "table").OnLeaveWorld = function()
  instance:LeaveGame()
end
def.static("table", "table").OnActivityTodo = function(p1, p2)
  local activityId = p1 and p1[1]
  if activityId == constant.QixiConsts.activityId then
    local teamData = require("Main.Team.TeamData").Instance()
    if not teamData:MeIsCaptain() then
      Toast(textRes.Team[61])
      return
    end
    require("Main.Qixi.ui.QixiCondition").Instance():ShowDlg()
  end
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if p1 and p1.feature == Feature.TYPE_CHINESE_VALENTINE then
    local isOpen = _G.IsFeatureOpen(Feature.TYPE_CHINESE_VALENTINE)
    local activityInterface = require("Main.activity.ActivityInterface").Instance()
    if isOpen then
      activityInterface:removeCustomCloseActivity(constant.QixiConsts.activityId)
    else
      instance:LeaveGame()
      activityInterface:addCustomCloseActivity(constant.QixiConsts.activityId)
    end
  end
end
def.static("table", "table").OnFeatureOpenInit = function(p1, p2)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local isOpen = _G.IsFeatureOpen(Feature.TYPE_CHINESE_VALENTINE)
  local activityInterface = require("Main.activity.ActivityInterface").Instance()
  if isOpen then
    activityInterface:removeCustomCloseActivity(constant.QixiConsts.activityId)
  else
    instance:LeaveGame()
    activityInterface:addCustomCloseActivity(constant.QixiConsts.activityId)
  end
end
QixiModule.Commit()
return QixiModule
