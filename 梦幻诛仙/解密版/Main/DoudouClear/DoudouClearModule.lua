local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local DoudouClearModule = Lplus.Extend(ModuleBase, "DoudouClearModule")
require("Main.module.ModuleId")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ECPlayer = Lplus.ForwardDeclare("ECPlayer")
local def = DoudouClearModule.define
local instance
def.static("=>", DoudouClearModule).Instance = function()
  if instance == nil then
    instance = DoudouClearModule()
    instance.m_moduleId = ModuleId.DOUDOU_CLEAR
  end
  return instance
end
def.field("number").blockTimer = 0
def.field("number").resultTimer = 0
def.field("table").resultCache = nil
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.hula.SErrorInfo", DoudouClearModule.OnError)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.hula.SSynDoudouComeoutStagetRes", DoudouClearModule.OnSSynDoudouComeoutStagetRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.hula.SSynDeleteStageRes", DoudouClearModule.OnSSynDeleteStageRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.hula.SMarkMonsterRes", DoudouClearModule.OnSMarkMonsterRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.hula.SSynActivityResultRes", DoudouClearModule.OnSSynActivityResultRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.hula.SSynMonsterListRes", DoudouClearModule.OnSSynMonsterListRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.hula.SSynMonsterStateRes", DoudouClearModule.OnSSynMonsterStateRes)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, DoudouClearModule.OnActivityTodo)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, DoudouClearModule.OnNpcService)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, DoudouClearModule.OnMapChange)
  Event.RegisterEvent(ModuleId.DOUDOU_CLEAR, gmodule.notifyId.Hula.ROUND_START, DoudouClearModule.OnNewRound)
  Event.RegisterEvent(ModuleId.DOUDOU_CLEAR, gmodule.notifyId.Hula.CLEAR_BEGIN, DoudouClearModule.OnStartClear)
  Event.RegisterEvent(ModuleId.DOUDOU_CLEAR, gmodule.notifyId.Hula.CLEAR_END, DoudouClearModule.OnWait)
  Event.RegisterEvent(ModuleId.DOUDOU_CLEAR, gmodule.notifyId.Hula.SCORE_UPDATE, DoudouClearModule.OnScoreChange)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, DoudouClearModule.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, DoudouClearModule.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, DoudouClearModule.OnFeatureOpenInit)
  ModuleBase.Init(self)
end
def.static("table", "table").OnActivityTodo = function(p1, p2)
  local activityId = p1 and p1[1]
  if nil == activityId then
    return
  end
  if activityId == constant.CHulaCfgConsts.ACTIVITY_ID then
    local npcId = constant.CHulaCfgConsts.NPCID
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {npcId})
  end
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  instance:ClearCache()
  require("Main.DoudouClear.DoudouMgr").Instance():Destroy()
end
def.static("table", "table").OnNpcService = function(p1, p2)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_HULA) then
    return
  end
  local serviceID = p1[1]
  if serviceID == nil then
    return
  end
  local npcId = p1[2]
  if serviceID == constant.CHulaCfgConsts.NPC_SERVICE then
    instance:JoinDouDouClear()
  end
end
def.static("table", "table").OnMapChange = function(param, context)
  local mapId = param[1]
  local oldMapId = param[2]
  if mapId == constant.CHulaCfgConsts.PREPARE_MAP_ID then
    instance:SetHulaState(true)
    require("Main.DoudouClear.DoudouMgr").Instance()
    Event.DispatchEvent(ModuleId.DOUDOU_CLEAR, gmodule.notifyId.Hula.ENTER_HULA, nil)
    instance:ShowActivityBtnWithTeam()
    instance:ShowOutPlayTitle()
  elseif mapId == constant.CHulaCfgConsts.MAP_ID then
    if oldMapId == constant.CHulaCfgConsts.PREPARE_MAP_ID then
      instance:CloseActivityBtn()
      instance:ShowActivityBtn()
      Event.DispatchEvent(ModuleId.DOUDOU_CLEAR, gmodule.notifyId.Hula.ROUND_START, {round = 1})
      Event.DispatchEvent(ModuleId.DOUDOU_CLEAR, gmodule.notifyId.Hula.SCORE_UPDATE, {
        score = 0,
        delta = 0,
        times = 0
      })
    else
      instance:SetHulaState(true)
      Event.DispatchEvent(ModuleId.DOUDOU_CLEAR, gmodule.notifyId.Hula.ENTER_HULA, nil)
      instance:ShowActivityBtn()
    end
    require("Main.DoudouClear.DoudouMgr").Instance():PlayMapEffect()
  elseif oldMapId == constant.CHulaCfgConsts.MAP_ID and mapId ~= constant.CHulaCfgConsts.MAP_ID then
    instance:SetHulaState(false)
    Event.DispatchEvent(ModuleId.DOUDOU_CLEAR, gmodule.notifyId.Hula.QUIT_HULA, nil)
    instance:CloseActivityBtn()
    instance:CloseTitle()
    instance:ClearCache()
    require("Main.DoudouClear.DoudouMgr").Instance():Destroy()
    require("Main.DoudouClear.ui.DouDouClearResultDlg").Close()
  elseif oldMapId == constant.CHulaCfgConsts.PREPARE_MAP_ID and mapId ~= constant.CHulaCfgConsts.PREPARE_MAP_ID and mapId ~= constant.CHulaCfgConsts.MAP_ID then
    instance:SetHulaState(false)
    Event.DispatchEvent(ModuleId.DOUDOU_CLEAR, gmodule.notifyId.Hula.QUIT_HULA, nil)
    instance:CloseActivityBtn()
    instance:CloseTitle()
    require("Main.DoudouClear.DoudouMgr").Instance():Destroy()
  end
end
def.static("table", "table").OnNewRound = function(p1, p2)
  local Title = require("Main.DoudouClear.ui.DouDouClearTitle")
  local stage = p1.round
  local totalTurn = constant.CHulaCfgConsts.TOTAL_TURNS
  local actStartTime = require("Main.activity.ActivityInterface").GetActivityBeginningTime(constant.CHulaCfgConsts.ACTIVITY_ID)
  local playStartTime = actStartTime + constant.CHulaCfgConsts.PREPARE_MINUTES * 60
  Title.SetUpTitle(string.format(textRes.Hula[14], stage, totalTurn))
  local endTime = playStartTime + stage * (constant.CHulaCfgConsts.DOUDOU_STAY_MINUTES + constant.CHulaCfgConsts.DOUDOU_DELETE_MINUTES) * 60 - constant.CHulaCfgConsts.DOUDOU_DELETE_MINUTES * 60
  Title.SetMiddleTitle(textRes.Hula[15], endTime)
end
def.static("table", "table").OnWait = function(p1, p2)
  instance:ReleaseCache()
  local Title = require("Main.DoudouClear.ui.DouDouClearTitle")
  local stage = p1.round
  local totalTurn = constant.CHulaCfgConsts.TOTAL_TURNS
  local actStartTime = require("Main.activity.ActivityInterface").GetActivityBeginningTime(constant.CHulaCfgConsts.ACTIVITY_ID)
  local playStartTime = actStartTime + constant.CHulaCfgConsts.PREPARE_MINUTES * 60
  if stage < totalTurn then
    local endTime = playStartTime + stage * (constant.CHulaCfgConsts.DOUDOU_STAY_MINUTES + constant.CHulaCfgConsts.DOUDOU_DELETE_MINUTES) * 60
    Title.SetMiddleTitle(textRes.Hula[16], endTime)
  else
    local endTime = require("Main.activity.ActivityInterface").GetActivityEndingTime(constant.CHulaCfgConsts.ACTIVITY_ID)
    Title.SetMiddleTitle(textRes.Hula[17], endTime)
  end
end
def.static("table", "table").OnStartClear = function(p1, p2)
  local Title = require("Main.DoudouClear.ui.DouDouClearTitle")
  local stage = p1.round
  Title.SetMiddleTitle(textRes.Hula[20], -1)
end
def.static("table", "table").OnScoreChange = function(p1, p2)
  local score = p1.score
  local add = p1.delta
  local level = p1.times
  local DouDouClearTitle = require("Main.DoudouClear.ui.DouDouClearTitle")
  GameUtil.AddGlobalTimer(1, true, function()
    DouDouClearTitle.SetDownTitle(textRes.Hula[18], score)
  end)
  if add and add > 0 then
    DouDouClearTitle.PlayAddEffect(add, level or 1)
  end
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if p1 and p1.feature == Feature.TYPE_HULA then
    local ActivityInterface = require("Main.activity.ActivityInterface")
    if p1.open then
      ActivityInterface.Instance():removeCustomCloseActivity(constant.CHulaCfgConsts.ACTIVITY_ID)
      Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {
        npcid = constant.CHulaCfgConsts.NPCID,
        show = true
      })
    else
      ActivityInterface.Instance():addCustomCloseActivity(constant.CHulaCfgConsts.ACTIVITY_ID)
      Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {
        npcid = constant.CHulaCfgConsts.NPCID,
        show = false
      })
    end
  end
end
def.static("table", "table").OnFeatureOpenInit = function(p1, p2)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local isOpen = _G.IsFeatureOpen(Feature.TYPE_HULA)
  local ActivityInterface = require("Main.activity.ActivityInterface")
  if isOpen then
    ActivityInterface.Instance():removeCustomCloseActivity(constant.CHulaCfgConsts.ACTIVITY_ID)
    Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {
      npcid = constant.CHulaCfgConsts.NPCID,
      show = true
    })
  else
    ActivityInterface.Instance():addCustomCloseActivity(constant.CHulaCfgConsts.ACTIVITY_ID)
    Event.DispatchEvent(ModuleId.PUBROLE, gmodule.notifyId.Pubrole.SET_NPC_ENABLE, {
      npcid = constant.CHulaCfgConsts.NPCID,
      show = false
    })
  end
end
def.static("table").OnError = function(p)
  local tip = textRes.Hula.Error[p.errorCode]
  if tip then
    Toast(tip)
  end
end
def.static("table").OnSSynDoudouComeoutStagetRes = function(p)
  local mgr = require("Main.DoudouClear.DoudouMgr").Instance()
  local last1, last2 = mgr:GetLastTwo()
  local id1 = last1 and last1.cfgId or 0
  local id2 = last2 and last2.cfgId or -1
  local doudouList = require("Main.DoudouClear.DouDouClearUtils").GenDoudou(p.seed, constant.CHulaCfgConsts.MONSTER_COUNT_EVERY_TURN, id1, id2)
  mgr:StartNextRound(p.turn, doudouList)
end
def.static("table").OnSSynDeleteStageRes = function(p)
  instance:Block(true)
  require("Main.DoudouClear.DoudouMgr").Instance():CheckReadyToClear(p.turn)
end
def.static("table").OnSMarkMonsterRes = function(p)
  local tag = _G.GetStringFromOcts(p.content)
  require("Main.DoudouClear.DoudouMgr").Instance():STagDouDou(p.seq, tag or "")
end
def.static("table").OnSSynActivityResultRes = function(p)
  instance.resultCache = p
  instance.resultTimer = GameUtil.AddGlobalTimer(constant.CHulaCfgConsts.DOUDOU_DELETE_MINUTES * 60, true, function()
    instance:PopResult()
  end)
end
def.static("table").OnSSynMonsterListRes = function(p)
  require("Main.DoudouClear.DoudouMgr").Instance():CreateExistingDoudous(p.turn, p.stage, p.monsterlist)
  require("Main.DoudouClear.data.Doudou").ResetInstanceId(p.maxseq + 1)
  require("Main.DoudouClear.DoudouMgr").Instance().score = p.point
  Event.DispatchEvent(ModuleId.DOUDOU_CLEAR, gmodule.notifyId.Hula.SCORE_UPDATE, {
    score = p.point
  })
  instance:ShowInPlayTitle()
end
def.static("table").OnSSynMonsterStateRes = function(p)
  require("Main.DoudouClear.DoudouMgr").Instance():SetDoudouState(p.seq, p.state)
end
def.method().ReleaseCache = function(self)
  self:Block(false)
  if self.resultCache then
    self:PopResult()
    GameUtil.RemoveGlobalTimer(self.resultTimer)
    self.resultTimer = 0
  end
end
def.method().ClearCache = function(self)
  self:Block(false)
  if self.resultTimer > 0 then
    GameUtil.RemoveGlobalTimer(self.resultTimer)
  end
  self.resultCache = nil
end
def.method().PopResult = function(self)
  local p = self.resultCache
  self.resultCache = nil
  if p == nil then
    return
  end
  local DouDouClearUtils = require("Main.DoudouClear.DouDouClearUtils")
  local totalScore = {
    name = textRes.Hula[21],
    score = p.point
  }
  local otherScores = {}
  local normalKill = 0
  local specialKill = 0
  for k, v in pairs(p.kill_monsterid_2_count) do
    local doudouCfg = DouDouClearUtils.GetDouDouCfg(k)
    if not doudouCfg.canDelete then
      specialKill = specialKill + v
    else
      normalKill = normalKill + v
    end
  end
  table.insert(otherScores, {
    name = textRes.Hula[22],
    score = normalKill
  })
  table.insert(otherScores, {
    name = textRes.Hula[23],
    score = specialKill
  })
  local typeCount = {
    [1] = 0,
    [2] = 0,
    [3] = 0,
    [4] = 0,
    [5] = 0,
    [6] = 0
  }
  for k, v in pairs(p.delete_type_2_count) do
    if typeCount[k] then
      typeCount[k] = typeCount[k] + v
    else
      typeCount[6] = typeCount[6] + v
    end
  end
  table.insert(otherScores, {
    name = textRes.Hula[24],
    score = typeCount[1]
  })
  table.insert(otherScores, {
    name = textRes.Hula[25],
    score = typeCount[2]
  })
  table.insert(otherScores, {
    name = textRes.Hula[26],
    score = typeCount[3]
  })
  table.insert(otherScores, {
    name = textRes.Hula[27],
    score = typeCount[4]
  })
  table.insert(otherScores, {
    name = textRes.Hula[28],
    score = typeCount[5]
  })
  table.insert(otherScores, {
    name = textRes.Hula[29],
    score = typeCount[6]
  })
  require("Main.DoudouClear.ui.DouDouClearResultDlg").ShowDouDouClearResultDlg(totalScore, otherScores)
end
def.method("boolean").Block = function(self, b)
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  if b then
    PersonalHelper.Block(true)
    self.blockTimer = GameUtil.AddGlobalTimer(constant.CHulaCfgConsts.DOUDOU_DELETE_MINUTES * 60, true, function()
      PersonalHelper.Block(false)
    end)
  elseif self.blockTimer ~= 0 then
    GameUtil.RemoveGlobalTimer(self.blockTimer)
    self.blockTimer = 0
    PersonalHelper.Block(false)
  end
end
def.method("boolean").SetHulaState = function(self, set)
  if gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole then
    if set then
      gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole:SetState(RoleState.HULA)
    else
      gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole:RemoveState(RoleState.HULA)
    end
  end
end
def.method().JoinDouDouClear = function(self)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.hula.CJoinHulaReq").new())
end
def.method().LeaveDouDouClear = function(self)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.hula.CLeaveHulaWorldReq").new())
end
def.method().ShowActivityBtnWithTeam = function(self)
  local CommonActivityPanel = require("GUI.CommonActivityPanel")
  CommonActivityPanel.Instance():ShowActivityPanel(true, true, function()
    require("Main.Team.TeamUtils").JoinTeam()
  end, nil, function()
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowConfirm("", textRes.Hula[3], function(sel)
      if sel == 1 then
        local teamData = require("Main.Team.TeamData")
        if teamData.Instance():HasTeam() then
          if teamData.Instance():MeIsCaptain() then
            instance:LeaveDouDouClear()
          else
            Toast(textRes.Hula[4])
          end
        else
          instance:LeaveDouDouClear()
        end
      end
    end, nil)
  end, nil, false, CommonActivityPanel.ActivityType.HULA)
end
def.method().ShowActivityBtn = function(self)
  local CommonActivityPanel = require("GUI.CommonActivityPanel")
  CommonActivityPanel.Instance():ShowActivityPanel(false, true, nil, nil, function()
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowConfirm("", textRes.Hula[5], function(sel)
      if sel == 1 then
        local teamData = require("Main.Team.TeamData")
        if teamData.Instance():HasTeam() then
          if teamData.Instance():MeIsCaptain() then
            instance:LeaveDouDouClear()
          else
            Toast(textRes.Hula[4])
          end
        else
          instance:LeaveDouDouClear()
        end
      end
    end, nil)
  end, nil, false, CommonActivityPanel.ActivityType.HULA)
end
def.method().CloseActivityBtn = function(self)
  local CommonActivityPanel = require("GUI.CommonActivityPanel")
  CommonActivityPanel.Instance():HidePanel(CommonActivityPanel.ActivityType.HULA)
end
def.method().ShowOutPlayTitle = function(self)
  local actStartTime = require("Main.activity.ActivityInterface").GetActivityBeginningTime(constant.CHulaCfgConsts.ACTIVITY_ID)
  local endTime = actStartTime + constant.CHulaCfgConsts.PREPARE_MINUTES * 60
  require("Main.DoudouClear.ui.DouDouClearTitle").ShowDouDouClearTitle("", textRes.Hula[6], endTime, "", 0)
end
def.method().ShowInPlayTitle = function(self)
  local DoudouMgr = require("Main.DoudouClear.DoudouMgr")
  local round, phase, score = DoudouMgr.Instance():GetCurrentState()
  local totalTurn = constant.CHulaCfgConsts.TOTAL_TURNS
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local actStartTime = ActivityInterface.GetActivityBeginningTime(constant.CHulaCfgConsts.ACTIVITY_ID)
  local playStartTime = actStartTime + constant.CHulaCfgConsts.PREPARE_MINUTES * 60
  local upTitle = string.format(textRes.Hula[14], round, totalTurn)
  local middleTitle = ""
  local endTime = playStartTime + round * (constant.CHulaCfgConsts.DOUDOU_STAY_MINUTES + constant.CHulaCfgConsts.DOUDOU_DELETE_MINUTES) * 60
  if phase == DoudouMgr.PHASE.PREPARE then
    if round < totalTurn then
      middleTitle = textRes.Hula[16]
    else
      middleTitle = textRes.Hula[17]
      endTime = ActivityInterface.GetActivityEndingTime(constant.CHulaCfgConsts.ACTIVITY_ID)
    end
  else
    middleTitle = textRes.Hula[15]
    endTime = endTime - constant.CHulaCfgConsts.DOUDOU_DELETE_MINUTES * 60
  end
  require("Main.DoudouClear.ui.DouDouClearTitle").ShowDouDouClearTitle(upTitle, middleTitle, endTime, textRes.Hula[18], score)
end
def.method().CloseTitle = function(self)
  require("Main.DoudouClear.ui.DouDouClearTitle").Close()
end
DoudouClearModule.Commit()
return DoudouClearModule
