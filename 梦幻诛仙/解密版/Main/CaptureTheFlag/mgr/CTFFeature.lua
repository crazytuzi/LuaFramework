local Lplus = require("Lplus")
local BattleFeature = require("Main.CaptureTheFlag.mgr.BattleFeature")
local CTFFeature = Lplus.Extend(BattleFeature, "CTFFeature")
local PlayType = require("consts.mzm.gsp.singlebattle.confbean.PlayType")
local BattleFieldMgr = Lplus.ForwardDeclare("BattleFieldMgr")
local PositionData = require("netio.protocol.mzm.gsp.singlebattle.PositionData")
local CaptureTheFlagUtils = require("Main.CaptureTheFlag.CaptureTheFlagUtils")
local CollectSliderPanel = require("GUI.CollectSliderPanel")
local ROLE_SERVER_STATUS = require("netio.protocol.mzm.gsp.status.StatusEnum")
local def = CTFFeature.define
local instance
def.final("=>", "table").Instance = function()
  if instance == nil then
    instance = CTFFeature()
    instance.playType = PlayType.GRAB_FLAG
  end
  return instance
end
def.field("table").towerState = nil
def.field("table").roleData = nil
def.field("function").finishCall = nil
def.field("table").result = nil
def.field(CollectSliderPanel).collectPanel = nil
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SSynTotalPositionInfo", CTFFeature.OnSSynTotalPositionInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SSynPositionChangeBro", CTFFeature.OnSSynPositionChangeBro)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SBeginGrapPositionBro", CTFFeature.OnSBeginGrapPositionBro)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SGrapPositionSucBro", CTFFeature.OnSGrapPositionSucBro)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SSynGrapPositionRes", CTFFeature.OnSSynGrapPositionRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SGrapPositionFail", CTFFeature.OnSGrapPositionFail)
  Event.RegisterEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.CLICK_TOP_BTN, CTFFeature.OnTopBtnClick)
end
def.override().Reset = function(self)
  self.towerState = nil
  self.roleData = nil
  self.finishCall = nil
  self.result = nil
  self.collectPanel = nil
end
def.static("table").OnSSynTotalPositionInfo = function(p)
  local self = CTFFeature.Instance()
  self.towerState = {}
  for k, v in pairs(p.positionInfos) do
    self.towerState[k] = {
      state = v.positionState,
      campId = v.campId
    }
  end
  self.roleData = {}
  for k, v in pairs(p.roleGrabInfo) do
    self.roleData[k:tostring()] = {
      total = v.count
    }
  end
end
def.static("table").OnSSynPositionChangeBro = function(p)
  local self = CTFFeature.Instance()
  local protectStartTime
  if p.positionData.positionState == PositionData.STATE_PROTECT then
    protectStartTime = GetServerTime()
  end
  self.towerState[p.positionId] = {
    state = p.positionData.positionState,
    campId = p.positionData.campId,
    protectStartTime = protectStartTime
  }
  Event.DispatchEvent(ModuleId.CTF, gmodule.notifyId.CTF.TowerStateChange, nil)
end
def.static("table").OnSBeginGrapPositionBro = function(p)
  if p.roleId == GetMyRoleID() then
    local self = CTFFeature.Instance()
    if self.collectPanel then
      self.collectPanel:HidePanel()
    end
    local useTime = p.endTime - GetServerTime()
    self.collectPanel = CollectSliderPanel.ShowCollectSliderPanelEx(textRes.CaptureTheFlag[14], useTime, nil, nil, nil)
  end
  local roleInfoData = BattleFieldMgr.Instance():GetRoleInfoData()
  local towerCfg = CaptureTheFlagUtils.GetTowerCfg(p.positionId)
  local roleInfo = roleInfoData:GetRoleInfo(p.roleId)
  if towerCfg == nil or roleInfoData == nil or roleInfo == nil then
    return
  end
  if BattleFieldMgr.Instance():IsEnemy(p.roleId) then
    local str = string.format(textRes.CaptureTheFlag[16], roleInfo.name, towerCfg.positionName)
    CaptureTheFlagUtils.ShowInBattlefieldChannel(str)
  else
    local str = string.format(textRes.CaptureTheFlag[15], roleInfo.name, towerCfg.positionName)
    CaptureTheFlagUtils.ShowInBattlefieldChannel(str)
  end
end
def.static("table").OnSGrapPositionSucBro = function(p)
  if p.roleId == GetMyRoleID() then
    local self = CTFFeature.Instance()
    if self.collectPanel then
      self.collectPanel:HidePanel()
      self.collectPanel = nil
    end
    local effectPath = GetEffectRes(constant.SingleBattleConsts.grabSucEffectId)
    require("Fx.GUIFxMan").Instance():Play(effectPath.path, "grapsuc", 0, 0, -1, false)
  end
  local roleInfoData = BattleFieldMgr.Instance():GetRoleInfoData()
  local towerCfg = CaptureTheFlagUtils.GetTowerCfg(p.positionId)
  local roleInfo = roleInfoData:GetRoleInfo(p.roleId)
  if towerCfg == nil or roleInfoData == nil or roleInfo == nil then
    return
  end
  if BattleFieldMgr.Instance():IsEnemy(p.roleId) then
    local str = string.format(textRes.CaptureTheFlag[18], roleInfo.name, towerCfg.positionName)
    CaptureTheFlagUtils.ShowInBattlefieldChannel(str)
  else
    local str = string.format(textRes.CaptureTheFlag[17], roleInfo.name, towerCfg.positionName)
    CaptureTheFlagUtils.ShowInBattlefieldChannel(str)
  end
end
def.static("table").OnSGrapPositionFail = function(p)
  local self = CTFFeature.Instance()
  if self.collectPanel then
    self.collectPanel:HidePanel()
  end
  local tip = textRes.CaptureTheFlag.GrapFail[p.reason]
  if tip then
    Toast(tip)
  end
end
def.static("table").OnSSynGrapPositionRes = function(p)
  local self = CTFFeature.Instance()
  self.result = {}
  for k, v in pairs(p.position2firstBlood) do
    local roleStr = v:tostring()
    if self.result[roleStr] == nil then
      self.result[roleStr] = {}
    end
    local towerCfg = CaptureTheFlagUtils.GetTowerCfg(k)
    local name = towerCfg.name
    table.insert(self.result[roleStr], name)
  end
  if self.finishCall then
    self.finishCall()
    self.finishCall = nil
  end
end
def.static("table", "table").OnTopBtnClick = function(p1, p2)
  local name = p1.btn
  if name == "capture" then
    local pubMgr = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
    local roleId = p1.roleId
    local role = pubMgr:GetRole(roleId)
    if role then
      BattleFieldMgr.Instance():FightRole(role)
    end
  end
end
def.override().OnEnterBattle = function(self)
end
def.override("number").OnEnterStage = function(self, stage)
end
def.override().OnQuitBattle = function(self)
  if self.collectPanel then
    self.collectPanel:HidePanel()
  end
  self:Reset()
end
def.override("=>", "string").GetExtraName = function(self)
  return textRes.CaptureTheFlag[11]
end
def.override("=>", "string").GetExtraSprite = function(self)
  return "Img_Place"
end
def.override("userdata", "=>", "string").GetExtraData = function(self, roleId)
  if self.roleData then
    local roleInfo = self.roleData[roleId:tostring()]
    return roleInfo and tostring(roleInfo.total) or "0"
  else
    return "0"
  end
end
def.override("userdata", "=>", "string").GetFinalData = function(self, roleId)
  local towerNames = self.result[roleId:tostring()]
  return towerNames and table.concat(towerNames, " ") or ""
end
def.override("function").IsStatisticsReady = function(self, func)
  if self.result then
    func()
  else
    self.finishCall = func
  end
end
def.method("number").RobTower = function(self, towerId)
  local myRole = require("Main.Hero.HeroModule").Instance().myRole
  if _G.IsInServerStatus(myRole, ROLE_SERVER_STATUS.STATUS_SINGLE_BATTLE_GRABING) then
    return
  end
  if myRole:IsInState(RoleState.SINGLEBATTLE_PROTECT) then
    Toast(textRes.CaptureTheFlag[121])
    return
  end
  local tower = self.towerState[towerId]
  if tower then
    if not BattleFieldMgr.Instance():IsMyTeam(tower.campId) then
      if tower.state == PositionData.STATE_PROTECT then
        if tower.protectStartTime then
          local towerCfg = CaptureTheFlagUtils.GetTowerCfg(towerId)
          if towerCfg then
            local leftTime = tower.protectStartTime + towerCfg.positionProtectInterval - GetServerTime()
            if leftTime >= 0 then
              Toast(string.format(textRes.CaptureTheFlag[20], leftTime))
            else
              Toast(textRes.CaptureTheFlag[12])
            end
          else
            Toast(textRes.CaptureTheFlag[12])
          end
        else
          Toast(textRes.CaptureTheFlag[12])
        end
      elseif tower.state == PositionData.STATE_GRABING then
        Toast(textRes.CaptureTheFlag[13])
      else
        local p = require("netio.protocol.mzm.gsp.singlebattle.CGrapPositionReq").new(towerId)
        gmodule.network.sendProtocol(p)
      end
    else
      Toast(textRes.CaptureTheFlag[19])
    end
  end
end
def.method("=>", "table").GetAllFlagInfo = function(self)
  local infos = {}
  if self.towerState then
    for k, v in pairs(self.towerState) do
      local info = {}
      info.id = k
      info.state = v.state
      info.campId = v.campId
      info.cfg = CaptureTheFlagUtils.GetTowerCfg(k)
      table.insert(infos, info)
    end
  end
  return infos
end
return CTFFeature.Commit()
