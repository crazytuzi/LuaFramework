local Lplus = require("Lplus")
local BattleFeature = require("Main.CaptureTheFlag.mgr.BattleFeature")
local RobGroundResFeature = Lplus.Extend(BattleFeature, "RobGroundResFeature")
local PlayType = require("consts.mzm.gsp.singlebattle.confbean.PlayType")
local BattleFieldMgr = Lplus.ForwardDeclare("BattleFieldMgr")
local CaptureTheFlagUtils = require("Main.CaptureTheFlag.CaptureTheFlagUtils")
local CollectSliderPanel = require("GUI.CollectSliderPanel")
local def = RobGroundResFeature.define
local instance
def.final("=>", "table").Instance = function()
  if instance == nil then
    instance = RobGroundResFeature()
    instance.playType = PlayType.BATTLE_GATHER
  end
  return instance
end
def.field(CollectSliderPanel).collectPanel = nil
def.field("function").finishCall = nil
def.field("table").result = nil
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SGatherItemAppearanceBro", RobGroundResFeature.OnSGatherItemAppearanceBro)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SGatherBattleItemRep", RobGroundResFeature.OnSGatherBattleItemRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SGatherItemSuc", RobGroundResFeature.OnSGatherItemSuc)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SGatherItemSucCampBro", RobGroundResFeature.OnSGatherItemSucCampBro)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SGatherBattleItemFail", RobGroundResFeature.OnSGatherBattleItemFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SGatherSourceResult", RobGroundResFeature.OnSGatherSourceResult)
end
def.override().Reset = function(self)
  self.finishCall = nil
  self.result = nil
  self.collectPanel = nil
end
def.override().OnEnterBattle = function(self)
end
def.override("number").OnEnterStage = function(self, stage)
end
def.override().OnQuitBattle = function(self)
  self:Reset()
end
def.static("table").OnSGatherItemAppearanceBro = function(p)
  local names = {}
  for k, v in pairs(p.areaIds) do
    local areaCfg = CaptureTheFlagUtils.GetAreaCfg(v)
    if areaCfg then
      table.insert(names, areaCfg.name)
    end
  end
  local str = string.format(textRes.CaptureTheFlag[33], table.concat(names, textRes.Common.Dunhao))
  CaptureTheFlagUtils.ShowInBattlefieldChannel(str)
end
def.static("table").OnSGatherBattleItemRep = function(p)
  local self = RobGroundResFeature.Instance()
  if self.collectPanel then
    self.collectPanel:HidePanel()
  end
  local useTime = p.endTime - GetServerTime()
  self.collectPanel = CollectSliderPanel.ShowCollectSliderPanelEx(textRes.CaptureTheFlag[31], useTime, nil, nil, nil)
end
def.static("table").OnSGatherItemSuc = function(p)
  local self = RobGroundResFeature.Instance()
  if self.collectPanel then
    self.collectPanel:HidePanel()
    self.collectPanel = nil
  end
  local gatherItemCfg = CaptureTheFlagUtils.GetGatherItemCfg(p.gatherItemCfgId)
  if gatherItemCfg then
    Toast(string.format(textRes.CaptureTheFlag[34], gatherItemCfg.source))
  end
end
def.static("table").OnSGatherItemSucCampBro = function(p)
  local roleInfoData = BattleFieldMgr.Instance():GetRoleInfoData()
  if roleInfoData then
    local roleInfo = roleInfoData:GetRoleInfo(p.roleId)
    if roleInfo then
      local roleName = roleInfo.name
      local gatherItemCfg = CaptureTheFlagUtils.GetGatherItemCfg(p.gatherItemCfgId)
      if gatherItemCfg then
        local str = string.format(textRes.CaptureTheFlag[35], roleName, gatherItemCfg.name, gatherItemCfg.source)
        CaptureTheFlagUtils.ShowInBattlefieldChannel(str)
      end
    end
  end
end
def.static("table").OnSGatherBattleItemFail = function(p)
  local self = RobGroundResFeature.Instance()
  if self.collectPanel then
    self.collectPanel:HidePanel()
    self.collectPanel = nil
  end
  local tip = textRes.CaptureTheFlag.GatherFail[p.reason]
  if tip then
    Toast(tip)
  end
end
def.static("table").OnSGatherSourceResult = function(p)
  local self = RobGroundResFeature.Instance()
  self.result = {}
  for k, v in pairs(p.role2TotalSource) do
    self.result[k:tostring()] = v
  end
  if self.finishCall then
    self.finishCall()
    self.finishCall = nil
  end
end
def.method("userdata").GatherItem = function(self, instanceId)
  local myRole = require("Main.Hero.HeroModule").Instance().myRole
  if myRole:IsInState(RoleState.SINGLEBATTLE_PROTECT) then
    Toast(textRes.CaptureTheFlag[121])
    return
  end
  local p = require("netio.protocol.mzm.gsp.singlebattle.CGatherBattleItemReq").new(instanceId)
  gmodule.network.sendProtocol(p)
end
def.override("userdata", "=>", "string").GetFinalData = function(self, roleId)
  local point = self.result[roleId:tostring()]
  return tostring(point or 0)
end
def.override("function").IsStatisticsReady = function(self, func)
  if self.result then
    func()
  else
    self.finishCall = func
  end
end
return RobGroundResFeature.Commit()
