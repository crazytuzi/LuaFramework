local Lplus = require("Lplus")
local BattleFieldMgr = Lplus.Class("BattleFieldMgr")
local BattleFeature = require("Main.CaptureTheFlag.mgr.BattleFeature")
local KillingRecorder = require("Main.CaptureTheFlag.data.KillingRecorder")
local RoleInfoData = require("Main.CaptureTheFlag.data.RoleInfoData")
local BattleBaseInfo = require("Main.CaptureTheFlag.data.BattleBaseInfo")
local RoleBaseInfo = require("netio.protocol.mzm.gsp.singlebattle.RoleBaseInfo")
local ServerListMgr = require("Main.Login.ServerListMgr")
local CaptureTheFlagUtils = require("Main.CaptureTheFlag.CaptureTheFlagUtils")
local ScoreBoard = require("Main.CaptureTheFlag.ui.ScoreBoard")
local SSynBattleStage = require("netio.protocol.mzm.gsp.singlebattle.SSynBattleStage")
local CommonCountDown = require("GUI.CommonCountDown")
local RobResPointFeature = require("Main.CaptureTheFlag.mgr.RobResPointFeature")
local def = BattleFieldMgr.define
local instance
def.static("=>", BattleFieldMgr).Instance = function()
  if instance == nil then
    instance = BattleFieldMgr()
  end
  return instance
end
def.const("table").BattleFeatures = {
  require("Main.CaptureTheFlag.mgr.ResStatisticsFeature"),
  require("Main.CaptureTheFlag.mgr.RobResPointFeature"),
  require("Main.CaptureTheFlag.mgr.CTFFeature"),
  require("Main.CaptureTheFlag.mgr.RobGroundResFeature"),
  require("Main.CaptureTheFlag.mgr.BuffFeature"),
  require("Main.CaptureTheFlag.mgr.PersonalTaskFeature")
}
def.field(KillingRecorder).recorder = nil
def.field(RoleInfoData).roleInfos = nil
def.field(BattleBaseInfo).baseInfo = nil
def.field("number").stage = 0
def.field("number").team1 = 0
def.field("number").team2 = 0
def.field("number").myTeam = 0
def.field("number").cfgId = 0
def.field("number").startTime = 0
def.field("table").activeFeature = nil
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SSynBattleTotalInfo", BattleFieldMgr.OnSSynBattleTotalInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SNewGuyTotalInfoBro", BattleFieldMgr.OnSNewGuyTotalInfoBro)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SSynBattleStage", BattleFieldMgr.OnSSynBattleStage)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SSynBattleGlobalInfo", BattleFieldMgr.OnSSynBattleGlobalInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SRoleDieBro", BattleFieldMgr.OnSRoleDieBro)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SJoinBattleBro", BattleFieldMgr.OnSJoinBattleBro)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SLogoutBro", BattleFieldMgr.OnSLogoutBro)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SLeaveSingleBattleBro", BattleFieldMgr.OnSLeaveSingleBattleBro)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SSynBattleFinalInfo", BattleFieldMgr.OnSSynBattleFinalInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SSingleBattleNormalInfo", BattleFieldMgr.OnSSingleBattleNormalInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SyncSingleBattalAppellation", BattleFieldMgr.OnSyncSingleBattalAppellation)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SSynAllPositionInfo", BattleFieldMgr.OnSSynAllPositionInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SSinglePositionBro", BattleFieldMgr.OnSSinglePositionBro)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.singlebattle.SynBattleMatchEnd", BattleFieldMgr.OnSynBattleMatchEnd)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_STATUS_CHANGED, BattleFieldMgr.OnStatusChanged)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MAINUI_SHOW, BattleFieldMgr.OnMainUIReady)
  Event.RegisterEvent(ModuleId.CTF, gmodule.notifyId.CTF.RoleResPointUpdate, BattleFieldMgr.OnRoleResPointUpdate)
  Event.RegisterEvent(ModuleId.CTF, gmodule.notifyId.CTF.SyncAllResPoint, BattleFieldMgr.OnRoleResPointInit)
  for k, v in ipairs(BattleFieldMgr.BattleFeatures) do
    if v.Instance() then
      v.Instance():Init()
    end
  end
end
def.method().Reset = function(self)
  for k, v in ipairs(BattleFieldMgr.BattleFeatures) do
    if v.Instance() then
      v.Instance():Reset()
    end
  end
  require("Main.Map.MapModule").Instance():SetPolygonEnable(false)
  if self.cfgId > 0 then
    require("GUI.ECGUIMan").Instance():SetHudTouchable(false)
  end
  self.recorder = nil
  self.roleInfos = nil
  self.baseInfo = nil
  self.stage = 0
  self.team1 = 0
  self.team2 = 0
  self.cfgId = 0
  self.startTime = 0
  self.activeFeature = nil
  Timer:RemoveListener(BattleFieldMgr.TickSecond)
  require("Main.CaptureTheFlag.ui.BattleFieldDetail").ClearCache()
end
def.static("table").OnSSynBattleTotalInfo = function(p)
  local self = BattleFieldMgr.Instance()
  self.cfgId = p.battleCfgId
  self.stage = p.stage
  self.startTime = p.startTime
  local battleCfg = CaptureTheFlagUtils.GetBattleCfg(self.cfgId)
  local team1 = battleCfg.camp1
  local team2 = battleCfg.camp2
  self.team1 = team1
  self.team2 = team2
  local camp1 = p.campInfos[self.team1]
  local camp2 = p.campInfos[self.team2]
  if camp1 and camp2 then
    self.baseInfo = BattleBaseInfo.new()
    self.roleInfos = RoleInfoData.new()
    self.recorder = KillingRecorder.new()
    self.baseInfo:SetBaseInfo(self.team1, camp1.campInfo)
    self.baseInfo:SetBaseInfo(self.team2, camp2.campInfo)
    local myRoleId = GetMyRoleID()
    for k, v in pairs(camp1.roleInfos) do
      if myRoleId == k then
        self.myTeam = self.team1
      end
      self.roleInfos:AddRoleToTeam(v.baseInfo, k, self.team1)
    end
    for k, v in pairs(camp2.roleInfos) do
      if myRoleId == k then
        self.myTeam = self.team2
      end
      self.roleInfos:AddRoleToTeam(v.baseInfo, k, self.team2)
    end
    for k, v in pairs(camp1.roleInfos) do
      self.recorder:SetKillData(k, v.fightRecord)
    end
    for k, v in pairs(camp2.roleInfos) do
      self.recorder:SetKillData(k, v.fightRecord)
    end
    Timer:RegisterListener(BattleFieldMgr.TickSecond, self)
  else
    warn("enter battle fail", self.team1, camp1, self.team2, camp2)
    return
  end
  self.activeFeature = {}
  for k, v in pairs(BattleFieldMgr.BattleFeatures) do
    if v.Instance() and v.Instance():IsActive(self.cfgId) then
      table.insert(self.activeFeature, v.Instance())
    end
  end
  for k, v in ipairs(self.activeFeature) do
    v:OnEnterBattle()
  end
  if self.stage == SSynBattleStage.STAGE_PREPARE then
    require("Main.Map.MapModule").Instance():SetPolygonEnable(true)
  end
  self:ShowScoreboard()
  self:ShowActivityBtn()
  local killInfo = self.recorder:GetInfo(GetMyRoleID())
  if killInfo.respawn > GetServerTime() then
    require("Main.CaptureTheFlag.ui.DeadBlind").ShowDeadBlind(killInfo.respawn)
  end
  if self.stage == SSynBattleStage.STAGE_PREPARE then
    local endTime = self.startTime + battleCfg.prepareDuration
    local time = endTime - GetServerTime()
    if not (time <= battleCfg.prepareDuration) or not time then
      time = battleCfg.prepareDuration
    end
    CommonCountDown.StartSimple(time)
    local str = string.format(textRes.CaptureTheFlag[7], time)
    CaptureTheFlagUtils.ShowInBattlefieldChannel(str)
  end
  if require("Main.MainUI.ui.MainUIPanel").Instance():IsShow() then
    require("Main.MainUI.ui.MainUIMainMenu").Instance():CloseMenuList()
  end
end
def.static("table").OnSNewGuyTotalInfoBro = function(p)
  local self = BattleFieldMgr.Instance()
  if self.roleInfos then
    self.roleInfos:AddRoleToTeam(p.roleTotalInfo.baseInfo, p.roleId, p.campId)
  end
  if self.recorder then
    self.recorder:SetKillData(p.roleId, p.roleTotalInfo.fightRecord)
  end
  Event.DispatchEvent(ModuleId.CTF, gmodule.notifyId.CTF.RoleDataChange, {
    p.roleId
  })
end
def.static("table").OnSSynBattleStage = function(p)
  local self = BattleFieldMgr.Instance()
  self.stage = p.stage
  for k, v in ipairs(self.activeFeature) do
    v:OnEnterStage(self.stage)
  end
  if self.stage == p.STAGE_PLAY then
    require("Main.Map.MapModule").Instance():SetPolygonEnable(false)
    CommonCountDown.End()
    CaptureTheFlagUtils.ShowInBattlefieldChannel(textRes.CaptureTheFlag[4])
  elseif self.stage == p.STAGE_WAIT_CLEAN then
    CaptureTheFlagUtils.ShowInBattlefieldChannel(textRes.CaptureTheFlag[5])
  end
  self:ShowScoreboard()
end
def.static("table").OnSSynBattleGlobalInfo = function(p)
  local self = BattleFieldMgr.Instance()
  local info1 = p.campInfos[self.team1]
  local info2 = p.campInfos[self.team2]
  if self.baseInfo then
    self.baseInfo:SetBaseInfo(self.team1, info1)
    self.baseInfo:SetBaseInfo(self.team2, info2)
    self:UpdateScore()
  end
end
def.static("table").OnSRoleDieBro = function(p)
  local self = BattleFieldMgr.Instance()
  self.recorder:RecordKill(p.killerId, p.dieRoleId, p.reviveTime)
  Event.DispatchEvent(ModuleId.CTF, gmodule.notifyId.CTF.RoleDataChange, {
    p.dieRoleId,
    p.killerId
  })
  if p.dieRoleId == GetMyRoleID() then
    require("Main.CaptureTheFlag.ui.DeadBlind").ShowDeadBlind(p.reviveTime)
  end
  if not RobResPointFeature.Instance():IsActive(self.cfgId) and self:IsEnemy(p.dieRoleId) then
    local killRole = self.roleInfos:GetRoleInfo(p.killerId)
    local dieRole = self.roleInfos:GetRoleInfo(p.dieRoleId)
    if killRole and dieRole then
      local str = string.format(textRes.CaptureTheFlag[6], killRole.name, dieRole.name)
      CaptureTheFlagUtils.ShowInBattlefieldChannel(str)
    end
  end
end
def.static("table").OnSJoinBattleBro = function(p)
  local self = BattleFieldMgr.Instance()
  self.roleInfos:SetRoleState(p.roleId, RoleBaseInfo.STATE_NORMAL)
  Event.DispatchEvent(ModuleId.CTF, gmodule.notifyId.CTF.RoleDataChange, {
    p.roleId
  })
end
def.static("table").OnSLogoutBro = function(p)
  local self = BattleFieldMgr.Instance()
  self.roleInfos:SetRoleState(p.roleId, RoleBaseInfo.STATE_OUTLINE)
  Event.DispatchEvent(ModuleId.CTF, gmodule.notifyId.CTF.RoleDataChange, {
    p.roleId
  })
end
def.static("table").OnSLeaveSingleBattleBro = function(p)
  local self = BattleFieldMgr.Instance()
  if p.roleId == GetMyRoleID() then
    CommonCountDown.End()
    self:OnBattleEnd()
  else
    self.roleInfos:SetRoleState(p.roleId, RoleBaseInfo.STATE_LEAVE)
    Event.DispatchEvent(ModuleId.CTF, gmodule.notifyId.CTF.RoleDataChange, {
      p.roleId
    })
  end
end
def.static("table").OnSSynBattleFinalInfo = function(p)
  local self = BattleFieldMgr.Instance()
  self:ShowStatistics(p)
end
def.static("table").OnSSingleBattleNormalInfo = function(p)
  local self = BattleFieldMgr.Instance()
  local tip = textRes.CaptureTheFlag.Error[p.result]
  if tip then
    Toast(string.format(tip, unpack(p.args)))
  end
end
def.static("table", "table").OnSyncSingleBattalAppellation = function(role, p)
  local self = BattleFieldMgr.Instance()
  if role == nil then
    return
  end
  if p then
    if self.roleInfos == nil then
      Debug.LogError("OnSyncSingleBattalAppellation: roleInfos is nil!")
      return
    end
    local roleInfo = self.roleInfos:GetRoleInfo(role.roleId)
    if not roleInfo then
      return
    end
    local teamId = roleInfo.teamId
    local campCfg = CaptureTheFlagUtils.GetCampCfg(teamId)
    local campName = campCfg and campCfg.campName or ""
    local campIcon = campCfg.iconId
    local zoneName = roleInfo.zoneName
    local index = roleInfo.index
    local nameColor, allColor
    if self:IsMyTeam(teamId) then
      allColor = GetColorData(constant.SingleBattleConsts.friendColour)
    else
      allColor = GetColorData(constant.SingleBattleConsts.attackColour)
    end
    if role:IsInState(RoleState.SINGLEBATTLE_PROTECT) then
      nameColor = GetColorData(constant.SingleBattleConsts.protectColour)
    else
      nameColor = allColor
    end
    role:SetName("", nameColor)
    role:SetShowTitle(zoneName, allColor)
    local res = RobResPointFeature.Instance():GetRoleResPoint(role.roleId)
    role:SetHeadText(string.format(textRes.CaptureTheFlag[8], index, campName, res), allColor)
    role:SetOrganizationIcon(campIcon)
  else
    local nameColor = GetColorData(701300001)
    role:SetName("", nameColor)
    role:SetShowTitle("", nil)
    role:SetHeadText("", nil)
    role:SetOrganizationIcon(0)
  end
end
def.static("table").OnSSynAllPositionInfo = function(p)
  local self = BattleFieldMgr.Instance()
  if self.roleInfos == nil then
    Debug.LogError("OnSSynAllPositionInfo: no roleInfos")
    return
  end
  for roleId, pos in pairs(p.positionInfos) do
    self.roleInfos:SetStartPos(roleId, pos)
  end
end
def.static("table").OnSSinglePositionBro = function(p)
  local self = BattleFieldMgr.Instance()
  if self.roleInfos == nil then
    Debug.LogError("OnSSinglePositionBro: no roleInfos")
    return
  end
  self.roleInfos:SetStartPos(p.roleId, p.position)
end
def.static("table").OnSynBattleMatchEnd = function(p)
  if p.reason == p.REASON_TIME_OUT then
    Toast(textRes.CaptureTheFlag.EndReason[1])
  elseif p.reason == p.REASON_RESOURCE_DIFF then
    local self = BattleFieldMgr.Instance()
    local cfg = CaptureTheFlagUtils.GetBattleCfg(self.cfgId)
    local diffSource = cfg.diffScores
    Toast(string.format(textRes.CaptureTheFlag.EndReason[2], diffSource))
  elseif p.reason == p.REASON_ALL_LEAVE then
    Toast(textRes.CaptureTheFlag.EndReason[3])
  end
end
def.static("table", "table").OnStatusChanged = function(p1, p2)
  local self = BattleFieldMgr.Instance()
  local statusChanged = p1 and p1[1]
  local role = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if statusChanged.Check(RoleState.SINGLEBATTLE) then
    local pubMgr = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
    if role:IsInState(RoleState.SINGLEBATTLE) then
      require("GUI.ECGUIMan").Instance():SetHudTouchable(true)
      pubMgr.enableSingleMode = false
      pubMgr:SetForceVisibleNum(80)
      Event.DispatchEvent(ModuleId.CTF, gmodule.notifyId.CTF.EnterSingleBattle, nil)
    else
      require("GUI.ECGUIMan").Instance():SetHudTouchable(false)
      pubMgr.enableSingleMode = true
      pubMgr:SetForceVisibleNum(-1)
      Event.DispatchEvent(ModuleId.CTF, gmodule.notifyId.CTF.LeaveSingleBattle, nil)
      self:OnBattleEnd()
    end
  end
end
def.static("table", "table").OnMainUIReady = function(p1, p2)
  local self = BattleFieldMgr.Instance()
  if self.cfgId > 0 then
    require("Main.MainUI.ui.MainUIMainMenu").Instance():CloseMenuList()
  end
end
def.static("table", "table").OnRoleResPointUpdate = function(p1, p2)
  local pubMgr = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  local self = BattleFieldMgr.Instance()
  local changeInfo = p1[1]
  for roleId, point in pairs(changeInfo) do
    local role = pubMgr:GetRole(roleId)
    if role then
      local roleInfo = self.roleInfos:GetRoleInfo(roleId)
      if roleInfo then
        local teamId = roleInfo.teamId
        local campCfg = CaptureTheFlagUtils.GetCampCfg(teamId)
        local campName = campCfg and campCfg.campName or ""
        local index = roleInfo.index
        local allColor
        if self:IsMyTeam(teamId) then
          allColor = GetColorData(constant.SingleBattleConsts.friendColour)
        else
          allColor = GetColorData(constant.SingleBattleConsts.attackColour)
        end
        local res = point
        role:SetHeadText(string.format(textRes.CaptureTheFlag[8], index, campName, res), allColor)
      end
    end
  end
end
def.static("table", "table").OnRoleResPointInit = function(p1, p2)
  local pubMgr = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE)
  local self = BattleFieldMgr.Instance()
  local changeInfo = p1[1]
  for roleIdStr, point in pairs(changeInfo) do
    local roleId = Int64.new(roleIdStr)
    local role = pubMgr:GetRole(roleId)
    if role then
      local roleInfo = self.roleInfos:GetRoleInfo(roleId)
      if roleInfo then
        local teamId = roleInfo.teamId
        local campCfg = CaptureTheFlagUtils.GetCampCfg(teamId)
        local campName = campCfg and campCfg.campName or ""
        local index = roleInfo.index
        local allColor
        if self:IsMyTeam(teamId) then
          allColor = GetColorData(constant.SingleBattleConsts.friendColour)
        else
          allColor = GetColorData(constant.SingleBattleConsts.attackColour)
        end
        local res = point
        role:SetHeadText(string.format(textRes.CaptureTheFlag[8], index, campName, res), allColor)
      end
    end
  end
end
def.method("=>", "boolean").IsInSingleBattle = function(self)
  local role = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if role then
    return role:IsInState(RoleState.SINGLEBATTLE)
  else
    return false
  end
end
def.method("number").TickSecond = function(self, delta)
  if self.recorder then
    local respawnRoles = self.recorder:Tick()
    if #respawnRoles > 0 then
      Event.DispatchEvent(ModuleId.CTF, gmodule.notifyId.CTF.RoleDataChange, respawnRoles)
    end
  end
  if self.activeFeature then
    for k, v in ipairs(self.activeFeature) do
      v:TickSecond()
    end
  end
end
def.method("table").SetProtect = function(self, role)
  role:SetName("", GetColorData(constant.CCompetitionConsts.ProtectColour))
end
def.method("table").SetUnProtect = function(self, role)
  if self.roleInfos then
    local roleInfo = self.roleInfos:GetRoleInfo(role.roleId)
    local teamId = roleInfo and roleInfo.teamId or 0
    local nameColor
    if self:IsMyTeam(teamId) then
      nameColor = GetColorData(constant.CCompetitionConsts.FriendColour)
    else
      nameColor = GetColorData(constant.CCompetitionConsts.AttackColour)
    end
    role:SetName("", nameColor)
  end
end
def.method().OnBattleEnd = function(self)
  if self.activeFeature then
    for k, v in ipairs(self.activeFeature) do
      v:OnQuitBattle()
    end
  end
  require("Main.Map.MapModule").Instance():SetPolygonEnable(false)
  if self.cfgId > 0 then
    require("GUI.ECGUIMan").Instance():SetHudTouchable(false)
  end
  self.recorder = nil
  self.roleInfos = nil
  self.baseInfo = nil
  self.stage = 0
  self.team1 = 0
  self.team2 = 0
  self.cfgId = 0
  self.startTime = 0
  self.activeFeature = nil
  Timer:RemoveListener(BattleFieldMgr.TickSecond)
  self:HideScoreBoard()
  self:HideActivityBtn()
  require("Main.CaptureTheFlag.ui.DeadBlind").Close()
  require("Main.CaptureTheFlag.ui.BattleFieldDetail").Close()
  require("Main.CaptureTheFlag.ui.BattleFieldDetail").ClearCache()
end
def.method("userdata", "=>", "boolean").IsEnemy = function(self, roleId)
  if self.roleInfos then
    local roleInfo = self.roleInfos:GetRoleInfo(roleId)
    if roleInfo then
      return roleInfo.teamId ~= self:GetMyTeam()
    else
      return false
    end
  else
    return false
  end
end
def.method("number", "=>", "boolean").IsMyTeam = function(self, teamId)
  return teamId == self.myTeam
end
def.method("=>", "number").GetMyTeam = function(self)
  return self.myTeam
end
def.method("=>", "number").GetTeam1 = function(self)
  return self.team1
end
def.method("=>", "number").GetTeam2 = function(self)
  return self.team2
end
def.method("table").FightRole = function(self, role)
  if role and self:IsEnemy(role.roleId) then
    if role:IsInState(RoleState.SINGLEBATTLE_PROTECT) then
      Toast(textRes.CaptureTheFlag[1])
    else
      local myRole = require("Main.Hero.HeroModule").Instance().myRole
      if myRole:IsInState(RoleState.SINGLEBATTLE_PROTECT) then
        Toast(textRes.CaptureTheFlag[121])
      else
        local p = require("netio.protocol.mzm.gsp.singlebattle.CTryFight").new(role.roleId)
        gmodule.network.sendProtocol(p)
      end
    end
  end
end
def.method().LeaveSingleBattle = function(self)
  if self.cfgId > 0 then
    local p = require("netio.protocol.mzm.gsp.singlebattle.CTryLeaveBattle").new()
    gmodule.network.sendProtocol(p)
  end
end
def.method().ShowActivityBtn = function(self)
  local CommonActivityPanel = require("GUI.CommonActivityPanel")
  CommonActivityPanel.Instance():ShowActivityPanel(false, true, nil, nil, function()
    if self.stage == require("netio.protocol.mzm.gsp.singlebattle.SSynBattleStage").STAGE_CLEAN then
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      CommonConfirmDlg.ShowConfirm("", textRes.CaptureTheFlag[3], function(sel)
        if sel == 1 then
          self:LeaveSingleBattle()
        end
      end, nil)
    else
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      CommonConfirmDlg.ShowConfirm("", textRes.CaptureTheFlag[2], function(sel)
        if sel == 1 then
          self:LeaveSingleBattle()
        end
      end, nil)
    end
  end, nil, false, CommonActivityPanel.ActivityType.SINGLE_BATTLE)
end
def.method().HideActivityBtn = function(self)
  local CommonActivityPanel = require("GUI.CommonActivityPanel")
  CommonActivityPanel.Instance():HidePanel(CommonActivityPanel.ActivityType.SINGLE_BATTLE)
end
def.method().ShowScoreboard = function(self)
  local camp1Cfg = CaptureTheFlagUtils.GetCampCfg(self.team1)
  local camp2Cfg = CaptureTheFlagUtils.GetCampCfg(self.team2)
  local baseData1 = self.baseInfo:GetBaseInfo(self.team1)
  local baseData2 = self.baseInfo:GetBaseInfo(self.team2)
  local battleCfg = CaptureTheFlagUtils.GetBattleCfg(self.cfgId)
  local endTime = -1
  if self.stage == require("netio.protocol.mzm.gsp.singlebattle.SSynBattleStage").STAGE_PLAY then
    endTime = self.startTime + battleCfg.matchDuration + battleCfg.prepareDuration
  end
  ScoreBoard.ShowScoreboard(camp1Cfg.campNameIcon, camp2Cfg.campNameIcon, baseData1.score, baseData2.score, camp1Cfg.icon, camp2Cfg.icon, endTime)
end
def.method().UpdateScore = function(self)
  local baseData1 = self.baseInfo:GetBaseInfo(self.team1)
  local baseData2 = self.baseInfo:GetBaseInfo(self.team2)
  ScoreBoard.SetScore(baseData1.score, baseData2.score)
end
def.method().HideScoreBoard = function(self)
  ScoreBoard.Close()
end
def.method("userdata", "=>", "table").GetRoleById = function(self, roleId)
  local roleInfo = self.roleInfos:GetRoleInfo(roleId)
  local killRecord = self.recorder:GetInfo(roleId)
  if roleInfo then
    local role = {
      id = roleInfo.roleId,
      name = roleInfo.name,
      gender = roleInfo.gender,
      occupation = roleInfo.occupation,
      level = roleInfo.level,
      avatarId = roleInfo.avatarId,
      zoneName = roleInfo.zoneName,
      state = roleInfo.state,
      index = roleInfo.index,
      kill = killRecord.kill,
      die = killRecord.die,
      respawn = killRecord.respawn
    }
    return role
  else
    return nil
  end
end
def.method("=>", "table").GetRoleDataSorted = function(self)
  local myRoleId = GetMyRoleID()
  local data = {}
  local feature
  local extraSprite = ""
  for k, v in ipairs(self.activeFeature) do
    if v:GetExtraSprite() ~= "" then
      feature = v
      extraSprite = v:GetExtraSprite()
      break
    end
  end
  local team1 = {}
  local roles = self.roleInfos:GetTeamRoles(self.team1)
  for k, v in pairs(roles) do
    local roleId64 = Int64.new(k)
    local role = self:GetRoleById(roleId64)
    role.extra = feature and feature:GetExtraData(roleId64)
    table.insert(team1, role)
  end
  local team2 = {}
  local roles = self.roleInfos:GetTeamRoles(self.team2)
  for k, v in pairs(roles) do
    local roleId64 = Int64.new(k)
    local role = self:GetRoleById(roleId64)
    role.extra = feature and feature:GetExtraData(roleId64)
    table.insert(team2, role)
  end
  local function cmp(a, b)
    if a.id == myRoleId then
      return true
    elseif b.id == myRoleId then
      return false
    end
    if a.kill > b.kill then
      return true
    elseif a.kill < b.kill then
      return false
    end
    if a.die < b.die then
      return true
    elseif a.die > b.die then
      return false
    end
    if a.extra and b.extra then
      if a.extra < b.extra then
        return true
      elseif a.extra > b.extra then
        return false
      end
    end
    return a.index < b.index
  end
  table.sort(team1, cmp)
  table.sort(team2, cmp)
  data.team1Id = self.team1
  data.team2Id = self.team2
  data.team1 = team1
  data.team2 = team2
  data.extra = extraSprite
  return data
end
def.method("table").ShowStatistics = function(self, p)
  local result = 0
  if p.winCampId == self.myTeam then
    result = 1
  elseif p.winCampId == 0 then
    result = 0
  else
    result = -1
  end
  local extraTitle = ""
  local extraFeature
  for k, v in ipairs(self.activeFeature) do
    if v:GetExtraName() ~= "" then
      extraFeature = v
      extraTitle = v:GetExtraName()
      break
    end
  end
  local function genStatisticsData()
    local myRoleId = GetMyRoleID()
    local roleData1 = {}
    local team = p.campFinalInfos[self.team1]
    if team == nil then
      return
    end
    for k, v in pairs(team.roleFinalInfos) do
      local role = self:GetRoleById(k)
      role.roleId = k
      role.kill = v.killCount
      role.die = v.dieCount
      role.point = v.point
      role.extra = extraFeature and extraFeature:GetFinalData(k) or nil
      table.insert(roleData1, role)
    end
    table.sort(roleData1, function(a, b)
      if a.roleId == myRoleId then
        return true
      elseif b.roleId == myRoleId then
        return false
      else
        return a.point > b.point
      end
    end)
    local maxIndex = 0
    local maxPoint = 0
    for k, v in ipairs(roleData1) do
      if maxPoint < v.point then
        maxIndex = k
        maxPoint = v.point
      end
    end
    if maxIndex > 0 then
      roleData1[maxIndex].vip = true
    end
    local roleData2 = {}
    local team = p.campFinalInfos[self.team2]
    if team == nil then
      return
    end
    for k, v in pairs(team.roleFinalInfos) do
      local role = self:GetRoleById(k)
      role.roleId = k
      role.kill = v.killCount
      role.die = v.dieCount
      role.point = v.point
      role.extra = extraFeature and extraFeature:GetFinalData(k) or nil
      table.insert(roleData2, role)
    end
    table.sort(roleData2, function(a, b)
      if a.roleId == myRoleId then
        return true
      elseif b.roleId == myRoleId then
        return false
      else
        return a.point > b.point
      end
    end)
    local maxIndex = 0
    local maxPoint = 0
    for k, v in ipairs(roleData2) do
      if maxPoint < v.point then
        maxIndex = k
        maxPoint = v.point
      end
    end
    if maxIndex > 0 then
      roleData2[maxIndex].vip = true
    end
    local data = {
      extra = extraTitle,
      result = result,
      roleInfos = {
        [self.team1] = roleData1,
        [self.team2] = roleData2
      },
      team1 = self.team1,
      team2 = self.team2,
      myTeam = self.myTeam,
      score1 = p.campFinalInfos[self.team1] and p.campFinalInfos[self.team1].totalSource or 0,
      score2 = p.campFinalInfos[self.team2] and p.campFinalInfos[self.team2].totalSource or 0
    }
    require("Main.CaptureTheFlag.ui.BattleFieldStatistics").ShowBattleFieldStatistics(data)
  end
  if extraFeature then
    extraFeature:IsStatisticsReady(genStatisticsData)
  else
    genStatisticsData()
  end
end
def.method("=>", "table").GetAllActiveFeatures = function(self)
  return self.activeFeature or {}
end
def.method("=>", "table").GetRoleInfoData = function(self)
  return self.roleInfos
end
def.method("=>", "table").GetKillingRecorder = function(self)
  return self.recorder
end
def.method("=>", "number").GetStage = function(self)
  return self.stage
end
def.method("userdata", "=>", "table").GetRolePos = function(self, roleId)
  local pos = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRolePos(roleId)
  if pos == nil and self.roleInfos then
    local roleInfo = self.roleInfos:GetRoleInfo(roleId)
    if roleInfo then
      pos = roleInfo.startPos
    end
  end
  return pos
end
def.method("=>", "number").GetCfgId = function(self)
  return self.cfgId
end
def.method("userdata", "=>", "number").GetGrabIconId = function(self, roleId)
  if self.roleInfos then
    local info = self.roleInfos:GetRoleInfo(roleId)
    if info then
      local teamId = info.teamId
      local campCfg = CaptureTheFlagUtils.GetCampCfg(teamId)
      if campCfg then
        return campCfg.gatherIcon or 0
      else
        return 0
      end
    else
      return 0
    end
  else
    return 0
  end
end
return BattleFieldMgr.Commit()
