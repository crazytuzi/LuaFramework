local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local GuideModule = Lplus.Extend(ModuleBase, "GuideModule")
require("Main.module.ModuleId")
local GuideUtils = require("Main.Guide.GuideUtils")
local GUIUtils = require("GUI.GUIUtils")
local ForceGuide = require("Main.Guide.ui.ForceGuide")
local MainUIPanel = require("Main.MainUI.ui.MainUIPanel")
local MainUIModule = require("Main.MainUI.MainUIModule")
local GuideConsts = require("netio.protocol.mzm.gsp.guide.GuideConsts")
local NewActivity = require("Main.Guide.ui.NewActivity")
local GuideType = require("consts.mzm.gsp.guide.confbean.GuideType")
local ECGUIMan = require("GUI.ECGUIMan")
local ECMSDK = require("ProxySDK.ECMSDK")
local def = GuideModule.define
local instance
def.static("=>", GuideModule).Instance = function()
  if nil == instance then
    instance = GuideModule()
    instance.m_moduleId = ModuleId.GUIDE
    instance.guides = {}
    instance.funcs = {}
    instance.fightGuideProcess = {}
    instance._cacheNewActivity = nil
    instance.recordGuides = {}
  end
  return instance
end
def.const("table").FIGHTGUIDEID = {
  NEW = {
    [550001030] = 1,
    [550001060] = 2
  },
  OLD = {
    [550001030] = 1,
    [550001060] = 2
  }
}
def.const("table").FIGHTGUIDESTEP = {
  [1] = {
    [1] = {
      [1] = 550100000,
      [2] = 550100001,
      [3] = 550100002
    },
    [2] = {
      [1] = 550100003,
      [2] = 550100004
    }
  },
  [2] = {
    [1] = {
      [1] = 550100020,
      [2] = 550100021,
      [3] = 550100022,
      [4] = 550100023
    },
    [2] = {
      [1] = 550100024
    }
  }
}
def.field("table").fightGuideProcess = nil
def.field("boolean").isInFightGuide = false
def.field("number").newOld = 0
def.field("table").guides = nil
def.field("number").currentGuide = 0
def.field("number").currentStep = 0
def.field("table").recordGuides = nil
def.field("table").funcs = nil
def.field("boolean").firstStep = true
def.field("number").CGStepAfterFight = 0
def.field("function")._cacheNewActivity = nil
def.const("table").AdvanceConst = {
  HERO = 1,
  PET = 2,
  SKILL = 3
}
def.field("table").advWays = nil
def.override().Init = function(self)
  if _G.guide_open then
    gmodule.network.registerProtocol("netio.protocol.mzm.gsp.guide.SSynAllGuideId", GuideModule.onSynGuide)
    gmodule.network.registerProtocol("netio.protocol.mzm.gsp.guide.SSynNewGuideIds", GuideModule.onAddGuide)
    gmodule.network.registerProtocol("netio.protocol.mzm.gsp.guide.SSynUserGuideType", GuideModule.onGuideType)
    Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_PROP_INIT, GuideModule.OnRoleInit)
    Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
      self:Reset()
    end)
    Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, GuideModule.OnFightEnd)
    Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, GuideModule.OnFightStart)
    Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.NEXT_ROUND, GuideModule.OnFightRoundChange)
    Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, GuideModule.OnRoleLvUp)
    Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_DramaOver, GuideModule.OnDramaEnd)
    Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.FIGHTING_PET_INFO_UPDATE, GuideModule.SomeThingUp)
    Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.SYNC_HERO_PROP, GuideModule.SomeThingUp)
    Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, GuideModule.SomeThingUp)
    Event.RegisterEvent(ModuleId.SKILL, gmodule.notifyId.Skill.OCCUPATION_SKILL_BAG_LEVEL_UP_SUCCESS, GuideModule.SomeThingUp)
    Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_GUIDE_UP_CLICK, GuideModule.UpShow)
    Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.MAINUI_SHOW, GuideModule.OnMainUIReady)
    Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_ListChanged, GuideModule.OnActivityListChanged)
  else
    self:OpenAllFunction()
  end
  self.newOld = GuideConsts.GUIDE_TYPE_SURVEY_NEW
  ModuleBase.Init(self)
end
def.override().OnReset = function(self)
  self.guides = {}
  self.funcs = {}
  GameUtil.RemoveGlobalTimer(self.fightGuideProcess.findTimer)
  self.fightGuideProcess = {}
  self.recordGuides = {}
  self.firstStep = true
  self.isInFightGuide = false
  self.currentGuide = 0
  self.currentStep = 0
  self._cacheNewActivity = nil
  self.newOld = GuideConsts.GUIDE_TYPE_SURVEY_NEW
  self.CGStepAfterFight = 0
end
def.static("table", "table").UpShow = function(p1, p2)
  if instance.advWays == nil then
    GuideModule.SomeThingUp()
  end
  if next(instance.advWays) then
    local x, y = p1[1], p1[2]
    local PromoteGuide = require("Main.Guide.ui.PromoteGuide")
    PromoteGuide.ShowPromote(x, y)
  else
    Toast(textRes.Guide[3])
  end
end
def.static("table", "table").SomeThingUp = function(p1, p2)
  instance.advWays = {}
  local PetModule = require("Main.Pet.PetModule")
  local HeroModule = require("Main.Hero.HeroModule")
  local SkillModule = require("Main.Skill.SkillModule")
  if HeroModule.Instance():NeedAssignProp() then
    instance.advWays[GuideModule.AdvanceConst.HERO] = true
  end
  if PetModule.Instance():IsFightingPetNeedAssignProp() then
    instance.advWays[GuideModule.AdvanceConst.PET] = true
  end
  if SkillModule.Instance():CanEnhanceSkillFunc(SkillModule.SkillFuncType.Occupation) then
    instance.advWays[GuideModule.AdvanceConst.SKILL] = true
  end
  local hasAdv = next(instance.advWays)
  Event.DispatchEvent(ModuleId.GUIDE, gmodule.notifyId.Guide.New_Promote_Way, {hasAdv})
end
def.static("table", "table").OnActivityListChanged = function(p1, p2)
  local self = instance
  if p1 ~= nil and p1[1] ~= nil then
    do
      local activityID = p1[1]
      local ActivityInterface = require("Main.activity.ActivityInterface")
      local cfg = ActivityInterface.GetActivityCfgById(activityID)
      if cfg ~= nil then
        local isForce = ActivityInterface.Instance():isForceOpenActivity(activityID)
        if isForce then
          return
        end
        if cfg.hasOpenEffect == true then
          local function fn()
            MainUIPanel.Instance():ExpandAll(true)
            MainUIPanel.Instance():OpenMainInfoUI()
            NewActivity.ShowNewActivity(cfg, function()
              instance._cacheNewActivity = nil
              instance:GuideOne()
            end)
          end
          instance._cacheNewActivity = fn
          if instance.currentGuide == 0 and instance.isInFightGuide == false then
            instance._cacheNewActivity()
          end
        end
      else
      end
    end
  end
end
def.static("table", "table").OnRoleInit = function(p1, p2)
  instance:InitFuncOpen()
end
def.static("table", "table").OnRoleLvUp = function(p1, p2)
end
def.method().OpenAllFunction = function(self)
  self.funcs = {}
  local FunType = require("consts.mzm.gsp.guide.confbean.FunType")
  for k, v in pairs(FunType) do
    self.funcs[v] = {}
    self.funcs[v].active = true
  end
end
def.method("number", "=>", "boolean").CheckFunction = function(self, func)
  if self.funcs[func] and self.funcs[func].active == true then
    return true
  else
    return false
  end
end
def.method("=>", "table").GetFunctionActiveState = function(self)
  return self.funcs
end
def.method().InitFuncOpen = function(self)
  self:ClearAllFunction()
  local myLv = require("Main.Hero.Interface"):GetBasicHeroProp().level
  local opened = GuideUtils.GetOpenedFunction(myLv)
  for k, v in pairs(opened) do
    self.funcs[v] = {}
    self.funcs[v].active = true
  end
end
def.method().ClearAllFunction = function(self)
  self.funcs = {}
  local FunType = require("consts.mzm.gsp.guide.confbean.FunType")
  for k, v in pairs(FunType) do
    self.funcs[v] = {}
  end
end
def.static("table").onGuideType = function(p)
  instance.newOld = p.guidetype
  warn("you are a " .. instance.newOld .. " player")
end
def.static("table").onSynGuide = function(p)
  for k, v in ipairs(p.guideids) do
    warn("onSynGuide", v)
    table.insert(instance.guides, v)
  end
  table.sort(instance.guides)
end
def.static("table").onAddGuide = function(p)
  for k, v in ipairs(p.guideids) do
    warn("onAddGuide", v)
    local isRepeat = false
    for k1, v1 in ipairs(instance.guides) do
      if v == v1 then
        isRepeat = true
        break
      end
    end
    if not isRepeat then
      table.insert(instance.guides, v)
    end
  end
  table.sort(instance.guides)
  instance:GuideOne()
end
def.method().GuideOne = function(self)
  if self.currentGuide > 0 or self.isInFightGuide or NewActivity.IsExist() or CGPlay then
    warn("GuideOne Return because", self.currentGuide, self.isInFightGuide, NewActivity.IsExist())
    return
  end
  self.currentGuide = 0
  self.currentStep = 0
  warn("GuideOne", #self.guides)
  if 0 < #self.guides then
    local guideId = self.guides[1]
    table.remove(self.guides, 1)
    if GuideModule.FIGHTGUIDEID.NEW[guideId] or GuideModule.FIGHTGUIDEID.OLD[guideId] then
      self:GuideFight(guideId)
    else
      local guideCfg = GuideUtils.GetGuideCfg(guideId)
      if guideCfg then
        self.currentGuide = guideId
        if self.newOld == GuideConsts.GUIDE_TYPE_SURVEY_NEW then
          self:StepOne(guideCfg.stepNew, true)
        elseif self.newOld == GuideConsts.GUIDE_TYPE_SURVEY_OLD then
          self:StepOne(guideCfg.stepOld, true)
        end
      else
        self:GuideOne()
      end
    end
  elseif self._cacheNewActivity then
    self._cacheNewActivity()
  end
end
def.method().ClearGuide = function(self)
  warn("ClearGuide")
  self.currentGuide = 0
  self.currentStep = 0
end
def.static("table", "table").OnFightEnd = function(p1, p2)
  local FIGHT_TYPE = require("netio.protocol.mzm.gsp.fight.Fight")
  local FIGHT_SUB_TYPE = require("consts.mzm.gsp.fight.confbean.FightType")
  local FIGHT_END = require("netio.protocol.mzm.gsp.fight.SFightEndBrd")
  local fightType = p1.FightType
  local isWin = p1.Result
  local rightSubType = p1.Fight_SubType ~= FIGHT_SUB_TYPE.HULA
  if fightType == FIGHT_TYPE.TYPE_PVE and not isWin and rightSubType then
    GameUtil.AddGlobalTimer(0.5, true, function()
      local DeadGuide = require("Main.Guide.ui.DeadGuide")
      DeadGuide.ShowDeadGuide()
    end)
  end
  GameUtil.RemoveGlobalTimer(instance.fightGuideProcess.findTimer)
  instance.fightGuideProcess.findTimer = 0
  instance.isInFightGuide = false
  ECGUIMan.Instance():LockUI(false)
  ForceGuide.Close()
end
def.static("table", "table").OnFightStart = function(p1, p2)
  local DeadGuide = require("Main.Guide.ui.DeadGuide")
  DeadGuide.CloseDeadGuide()
end
def.static("table", "table").OnFightRoundChange = function(p1, p2)
  if instance.isInFightGuide then
    GameUtil.RemoveGlobalTimer(instance.fightGuideProcess.findTimer)
    instance.fightGuideProcess.findTimer = 0
    local FightMgr = require("Main.Fight.FightMgr")
    if p1 then
      local roundCount = p1[1]
      if instance.fightGuideProcess.turn == roundCount then
        warn("Round Operation End")
        ForceGuide.Close()
        ECGUIMan.Instance():LockUI(false)
      else
        warn("Round Operation Start")
        instance.fightGuideProcess.turn = roundCount
        instance.fightGuideProcess.step = 1
        instance:StepFightGuide()
      end
    end
  end
end
def.static("table", "table").OnMainUIReady = function()
  if instance.firstStep == true then
    instance:ClearGuide()
    instance:GuideOne()
    instance.firstStep = false
  end
end
def.static("table", "table").OnDramaEnd = function(p1, p2)
  instance:GuideOne()
end
def.method("number", "number").RecordGuide = function(self, id, param)
  if self.currentGuide > 0 and not self.recordGuides[self.currentGuide] then
    local guideSave = require("netio.protocol.mzm.gsp.guide.CSendGuidedid").new(self.currentGuide, param)
    gmodule.network.sendProtocol(guideSave)
    self.recordGuides[self.currentGuide] = true
  end
end
def.method("number").GuideFight = function(self, guideId)
  local whichFight
  if self.newOld == GuideConsts.GUIDE_TYPE_SURVEY_NEW then
    whichFight = GuideModule.FIGHTGUIDEID.NEW[guideId]
  elseif self.newOld == GuideConsts.GUIDE_TYPE_SURVEY_OLD then
    whichFight = GuideModule.FIGHTGUIDEID.NEW[guideId]
  end
  if not whichFight then
    return
  end
  local FightMgr = require("Main.Fight.FightMgr")
  FightMgr.Instance():SetAutoFightStatus(false)
  self.fightGuideProcess.fight = whichFight
  self.fightGuideProcess.step = 1
  self.fightGuideProcess.turn = 0
  GameUtil.RemoveGlobalTimer(self.fightGuideProcess.findTimer)
  self.fightGuideProcess.findTimer = 0
  self.isInFightGuide = true
end
def.method().StepFightGuide = function(self)
  local ForceGuide = require("Main.Guide.ui.ForceGuide")
  local whichFight = self.fightGuideProcess.fight
  local whichTurn = self.fightGuideProcess.turn
  local whichStep = self.fightGuideProcess.step
  warn("StepFightGuide:", whichFight, whichTurn, whichStep)
  if GuideModule.FIGHTGUIDESTEP[whichFight] == nil or GuideModule.FIGHTGUIDESTEP[whichFight][whichTurn] == nil or GuideModule.FIGHTGUIDESTEP[whichFight][whichTurn][whichStep] == nil then
    return
  end
  local stepId = GuideModule.FIGHTGUIDESTEP[whichFight][whichTurn][whichStep]
  ECGUIMan.Instance():LockUI(true)
  local stepCfg = GuideUtils.GetStepCfg(stepId)
  local uipath = stepCfg.uipath
  local param = stepCfg.param
  local destroyUI = false
  if string.sub(uipath, 1, 12) == "panel_fight/" then
    destroyUI = true
  end
  self.fightGuideProcess.findTimer = GameUtil.AddGlobalLateTimer(0, false, function()
    local retryTimes = 120
    local isValid = GuideUtils.ValidateUI(uipath, param)
    if isValid then
      GameUtil.RemoveGlobalTimer(self.fightGuideProcess.findTimer)
      self.fightGuideProcess.findTimer = 0
      ForceGuide.ShowForceGuide(stepId, destroyUI, function(id, success)
        if success then
          ForceGuide.Close()
          local next = self.fightGuideProcess.step + 1
          if GuideModule.FIGHTGUIDESTEP[self.fightGuideProcess.fight][self.fightGuideProcess.turn][next] then
            self.fightGuideProcess.step = next
            self:StepFightGuide()
          end
        else
          ForceGuide.Close()
        end
      end)
    else
      retryTimes = retryTimes - 1
      if retryTimes < 0 then
        ECGUIMan.Instance():LockUI(false)
        GameUtil.RemoveGlobalTimer(self.fightGuideProcess.findTimer)
        self.fightGuideProcess.findTimer = 0
      end
    end
  end)
end
def.method("number", "boolean").StepOne = function(self, stepId, firstStep)
  warn("Step One", stepId)
  if firstStep then
  else
    ECGUIMan.Instance():LockUI(true)
  end
  self.currentStep = stepId
  local stepCfg = GuideUtils.GetStepCfg(stepId)
  if stepCfg == nil then
    ECGUIMan.Instance():LockUI(false)
    self:ClearGuide()
    self:GuideOne()
    return
  end
  if stepCfg.guidetype == GuideType.FORCE then
    do
      local uipath = stepCfg.uipath
      if string.sub(uipath, 1, 11) == "panel_main/" or uipath == "task" then
        MainUIPanel.Instance():ExpandAll(true)
        MainUIModule.OpenAssociatedMenu(uipath)
      end
      if string.sub(uipath, 1, 16) == "panel_commonuse/" then
        require("Main.Item.ui.EasyUseDlg").CloseAll()
      end
      local destroyUI = false
      if string.sub(uipath, 1, 11) == "panel_main/" or uipath == "task" then
        destroyUI = true
      end
      local param = stepCfg.param
      local retryTimer = 0
      local retryTimes = 120
      retryTimer = GameUtil.AddGlobalLateTimer(0, false, function()
        local isValid = GuideUtils.ValidateUI(uipath, param)
        if isValid then
          gmodule.moduleMgr:GetModule(ModuleId.HERO):Stop()
          require("Main.MainUI.ui.MainUIMainMenu").Instance():SetAllowAutoClose(false)
          GameUtil.RemoveGlobalTimer(retryTimer)
          ForceGuide.ShowForceGuide(stepId, destroyUI, function(id, success)
            require("Main.MainUI.ui.MainUIMainMenu").Instance():SetAllowAutoClose(true)
            if success then
              self:RecordGuide(self.currentGuide, 0)
              ForceGuide.Close()
              self:StepNext(id)
            else
              ForceGuide.Close()
              self:StepFail(stepId)
            end
          end)
        else
          retryTimes = retryTimes - 1
          if retryTimes < 0 then
            GameUtil.RemoveGlobalTimer(retryTimer)
            ECGUIMan.Instance():LockUI(false)
            self:StepFail(stepId)
          end
        end
      end)
    end
  elseif stepCfg.guidetype == GuideType.LIGHT_EFFECT then
    do
      local uipath = stepCfg.uipath
      local param = stepCfg.param
      local retryTimer = 0
      local retryTimes = 120
      retryTimer = GameUtil.AddGlobalLateTimer(0, false, function()
        local isValid = GuideUtils.ValidateUI(uipath, param)
        if isValid then
          GameUtil.RemoveGlobalTimer(retryTimer)
          self:AddLightEffect(stepId)
          ECGUIMan.Instance():LockUI(false)
          self:StepNext(stepId)
        else
          retryTimes = retryTimes - 1
          if retryTimes < 0 then
            GameUtil.RemoveGlobalTimer(retryTimer)
            ECGUIMan.Instance():LockUI(false)
            self:StepFail(stepId)
          end
        end
      end)
    end
  elseif stepCfg.guidetype == GuideType.NEW_FUNCTION then
    self:InitFuncOpen()
    MainUIPanel.Instance():ExpandAll(true)
    ECGUIMan.Instance():DestroyUIAtLevel(1)
    gmodule.moduleMgr:GetModule(ModuleId.HERO):Stop()
    require("Main.Chat.ui.ChannelChatPanel").CloseChannelChatPanel()
    require("Main.friend.ui.SocialDlg").CloseSocialDlg()
    do
      local NewFunction = require("Main.Guide.ui.NewFunction")
      NewFunction.ShowNewFunction(stepId, function(id)
        self:RecordGuide(self.currentGuide, 0)
        NewFunction.Close()
        self:StepNext(id)
      end)
    end
  elseif stepCfg.guidetype == GuideType.I_SEE then
    do
      local ISeeGuide = require("Main.Guide.ui.ISeeGuide")
      local uipath = stepCfg.uipath
      local param = stepCfg.param
      local retryTimer = 0
      local retryTimes = 120
      retryTimer = GameUtil.AddGlobalLateTimer(0, false, function()
        local isValid = GuideUtils.ValidateUI(uipath, param)
        if isValid then
          gmodule.moduleMgr:GetModule(ModuleId.HERO):Stop()
          GameUtil.RemoveGlobalTimer(retryTimer)
          ISeeGuide.ShowISee(stepId, function(id, success)
            if success then
              self:RecordGuide(self.currentGuide, 0)
              ISeeGuide.Close()
              self:StepNext(id)
            else
              ISeeGuide.Close()
              self:StepFail(stepId)
            end
          end)
        else
          retryTimes = retryTimes - 1
          if retryTimes < 0 then
            ECGUIMan.Instance():LockUI(false)
            GameUtil.RemoveGlobalTimer(retryTimer)
            self:StepFail(stepId)
          end
        end
      end)
    end
  elseif stepCfg.guidetype == GuideType.PLAY_PLOT then
    gmodule.moduleMgr:GetModule(ModuleId.HERO):Stop()
    local TaskInterface = require("Main.task.TaskInterface")
    local operaCfg = TaskInterface.GetOperaCfg(stepCfg.param)
    if operaCfg ~= nil then
      local CG = require("CG.CG")
      local resTable = CG.Instance():Play(operaCfg.path, tostring(stepId), function(identity)
        ECGUIMan.Instance():LockUI(false)
        Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_DramaOver, GuideModule.OnDramaEnd)
      end)
      if next(resTable) ~= nil then
        ECGUIMan.Instance():ShowAllUI(false)
        Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_DramaStart, {
          operaCfg.path
        })
        local TaskInterface = require("Main.task.TaskInterface")
        TaskInterface.Instance()._playingOpera = tostring(stepId)
      end
    else
      warn("Guide want play drama:", stepCfg.param, "but can't find it in configs")
      ECGUIMan.Instance():LockUI(false)
      self:StepFail(stepId)
    end
  elseif stepCfg.guidetype == GuideType.SELECT_PET then
    gmodule.moduleMgr:GetModule(ModuleId.HERO):Stop()
    self:ChoosePet(stepId)
  elseif stepCfg.guidetype == GuideType.GIVE_PET then
    gmodule.moduleMgr:GetModule(ModuleId.HERO):Stop()
    self:SendPet(stepId)
  elseif stepCfg.guidetype == GuideType.FIGHT then
    warn("\230\136\152\230\150\151\230\140\135\229\188\149\231\137\185\230\174\138\229\164\132\231\144\134\228\186\134\239\188\140\229\166\130\230\158\156\230\137\147\229\135\186\232\191\153\230\157\161\230\151\165\229\191\151\239\188\140\232\175\180\230\152\142\229\135\186\233\148\153\228\186\134")
  elseif stepCfg.guidetype == GuideType.SURVEY then
    gmodule.moduleMgr:GetModule(ModuleId.HERO):Stop()
    local SurveyDlg = require("Main.Guide.ui.SurveyDlg")
    SurveyDlg.ShowSurvey(stepId, function(id, select)
      if select == 0 then
        self:RecordGuide(self.currentGuide, GuideConsts.GUIDE_TYPE_SURVEY_NEW)
      elseif select == 1 then
        self:RecordGuide(self.currentGuide, GuideConsts.GUIDE_TYPE_SURVEY_OLD)
      end
      self:StepNext(id)
    end)
  end
end
def.method("number").StepNext = function(self, stepId)
  if ClientCfg.GetSDKType() == ClientCfg.SDKTYPE.MSDK then
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.GUIDE, {stepId})
  end
  local stepCfg = GuideUtils.GetStepCfg(stepId)
  warn("StepNext", stepId, "=>", stepCfg.nextstep)
  if stepCfg.nextstep > 0 then
    if stepCfg.nextstep == 550100125 then
      do
        local protector = GameUtil.AddGlobalLateTimer(8, true, function()
          Event.UnregisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_New_Dlg_Close, ContinueStep)
          self:StepFail(stepCfg.nextstep)
        end)
        local function ContinueStep()
          GameUtil.RemoveGlobalTimer(protector)
          Event.UnregisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_New_Dlg_Close, ContinueStep)
          self:StepOne(stepCfg.nextstep, false)
        end
        Event.RegisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_New_Dlg_Close, ContinueStep)
        return
      end
    else
      self:StepOne(stepCfg.nextstep, false)
    end
  else
    self:ClearGuide()
    self:GuideOne()
  end
end
def.method("number").AddLightEffect = function(self, stepId)
  local stepCfg = GuideUtils.GetStepCfg(stepId)
  local uiName = stepCfg.uipath
  if uiName == "task" then
    Event.DispatchEvent(ModuleId.GUIDE, gmodule.notifyId.Guide.Apply_TaskTrace_Light, {
      stepCfg.param
    })
  elseif MainUIModule.IsMenuBtn(GuideUtils.GetEndControl(uiName)) then
    local ret = MainUIModule.AddMenuBtnEffect(uiName)
    if not ret then
      warn("AddMenuBtnEffect Return false, add failed, ", uiName)
    end
  else
    local uiRoot = ECGUIMan.Instance().m_UIRoot
    local target = uiRoot:FindDirect(uiName)
    if stepCfg.param > 0 then
      GUIUtils.AddLightEffectToPanel(uiName, stepCfg.param)
    else
      GUIUtils.AddLightEffectToPanel(uiName, GUIUtils.Light.Round)
    end
  end
  self:RecordGuide(self.currentGuide, 0)
end
def.method("number").ChoosePet = function(self, stepId)
  local ChoosePet = require("Main.Guide.ui.ChoosePet")
  local stepCfg = GuideUtils.GetStepCfg(stepId)
  local pet1 = stepCfg.otherParam[1]
  local pet2 = stepCfg.otherParam[2]
  if pet1 and pet2 then
    ChoosePet.ShowChoosePet(pet1, pet2, function(id)
      local choosePet = require("netio.protocol.mzm.gsp.guide.CSelectPet").new(self.currentGuide, id)
      gmodule.network.sendProtocol(choosePet)
      ChoosePet.Close()
      self:StepNext(stepId)
    end)
  else
    self:StepFail(stepId)
  end
end
def.method("number").SendPet = function(self, stepId)
  local SendPet = require("Main.Guide.ui.SendPet")
  local stepCfg = GuideUtils.GetStepCfg(stepId)
  local pet1 = stepCfg.otherParam[1]
  if pet1 then
    local time = GuideUtils.GetGuideConst().WAITTIME
    warn("SendPet Time:", time)
    SendPet.ShowSendPet(pet1, time, function()
      self:RecordGuide(self.currentGuide, pet1)
      SendPet.Close()
      self:StepNext(stepId)
    end)
  else
    self:StepFail(stepId)
  end
end
def.method("number").StepFail = function(self, step)
  warn("StepFail", step)
  local failStep = GuideUtils.GetStepCfg(step)
  local id = failStep.nextstep
  while id > 0 do
    local cfg = GuideUtils.GetStepCfg(id)
    if cfg then
      if cfg.guidetype == GuideType.NEW_FUNCTION then
        break
      else
        id = cfg.nextstep
      end
    else
      id = 0
    end
  end
  if id > 0 then
    self:StepOne(id, false)
  else
    self:ClearGuide()
    self:GuideOne()
  end
end
GuideModule.Commit()
return GuideModule
