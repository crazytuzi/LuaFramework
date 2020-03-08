local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local WingModule = Lplus.Extend(ModuleBase, "WingModule")
local WingUtils = require("Main.Wing.WingUtils")
local WingData = require("Main.Wing.WingData")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local def = WingModule.define
local instance
def.static("=>", WingModule).Instance = function()
  if instance == nil then
    instance = WingModule()
    instance.m_moduleId = ModuleId.WING
  end
  return instance
end
def.field(WingData).wingData = nil
def.override().Init = function(self)
  ModuleBase.Init(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wing.SSynWingsData", WingModule.OnSSynWingsData)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wing.SAddWingExpRep", WingModule.OnSAddWingExpRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wing.SAddWingRankRep", WingModule.OnSAddWingRankRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wing.SResetWingRep", WingModule.OnSResetWingRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wing.SRpWingContentRep", WingModule.OnSRpWingContentRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wing.SSynOutLook", WingModule.OnSSynOutLook)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wing.SSynWingColor", WingModule.OnSSynWingColor)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wing.SWingNormalResult", WingModule.OnSWingNormalResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wing.SGetNewWing", WingModule.OnSGetNewWing)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wing.SCheckWingsRep", WingModule.OnSCheckWingsRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wing.SSetTargetSkillRep", WingModule.OnSSetTargetSkillRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wing.SUnsetTargetSkillRep", WingModule.OnSUnsetTargetSkillRep)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wing.SRenameOccupationPlanNameRep", WingModule.OnSRenameOccupationPlanNameRep)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_WINGS_CLICK, WingModule.OnWingsBtnClicked)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, WingModule.OnFeatureInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, WingModule.OnFeatureOpenChange)
end
def.override().OnReset = function(self)
  self.wingData = nil
end
def.static("table").OnSSynWingsData = function(p)
  local self = WingModule.Instance()
  self.wingData = WingData.new()
  self.wingData:SetLevel(p.curLv)
  self.wingData:SetPhase(p.curRank)
  self.wingData:SetExp(p.curExp)
  self.wingData:SetCurWingId(p.curWing)
  self.wingData:SetWings(p.wings)
  self.wingData:SetCurOccupationId(p.effectOccupationId)
  self.wingData:SetOccPlansNames(p.occPalns)
  self.wingData:SetNewOccPlans(p.newOccPlans)
  if p.synType == p.TYPE__OPEN_WING then
    GameUtil.AddGlobalTimer(1, true, function()
      local wingId = self.wingData:GetFirstWingId()
      if wingId then
        self:ChangCurWing(wingId)
      end
    end)
    Toast(textRes.Wing[27])
    self:OpenWingPanel()
  end
  Event.DispatchEvent(ModuleId.WING, gmodule.notifyId.Wing.WINGS_CHANGE_PLAN_SUCCESS, nil)
end
def.static("table").OnSAddWingExpRep = function(p)
  local self = WingModule.Instance()
  if self:IsWingSetup() then
    self.wingData:SetExp(p.curExp)
    self.wingData:SetLevel(p.newLv)
    Event.DispatchEvent(ModuleId.WING, gmodule.notifyId.Wing.WINGS_EXP_CHANGE, nil)
    Toast(string.format(textRes.Wing[15], p.addExp))
    if p.newLv > p.oldLv then
      Toast(string.format(textRes.Wing[16], p.newLv))
    end
  end
end
def.static("table").OnSAddWingRankRep = function(p)
  local self = WingModule.Instance()
  if self:IsWingSetup() then
    self.wingData:SetWing(p.wing)
    do
      local wing = self.wingData:GetWingByWingId(p.wing.cfgId)
      local newPhase = self.wingData:GetPhase() + 1
      self.wingData:SetPhase(newPhase)
      Event.DispatchEvent(ModuleId.WING, gmodule.notifyId.Wing.WINGS_PHASE_CHANGE, nil)
      Event.DispatchEvent(ModuleId.WING, gmodule.notifyId.Wing.WINGS_GET_WING, nil)
      Toast(string.format(textRes.Wing[17], newPhase))
      local ownedSkills = self.wingData:GetSkills()
      for _, ownedSkillId in pairs(ownedSkills) do
        self.wingData:UnsertAllPhaseTargetSkillBySkillId(ownedSkillId)
      end
      self:ShowPromote(wing, 1)
      GameUtil.AddGlobalTimer(1, true, function()
        self:ChangCurWing(wing.id)
      end)
    end
  end
end
def.static("table").OnSGetNewWing = function(p)
  local self = WingModule.Instance()
  if self:IsWingSetup() then
    self.wingData:SetWing(p.wing)
    do
      local wing = self.wingData:GetWingByWingId(p.wing.cfgId)
      Event.DispatchEvent(ModuleId.WING, gmodule.notifyId.Wing.WINGS_GET_WING, nil)
      local wingFakeItem = WingUtils.GetWingFakeItemByWingId(wing.id)
      Toast(string.format(textRes.Wing[18], wingFakeItem.name))
      self:ShowPromote(wing, 2)
      GameUtil.AddGlobalTimer(1, true, function()
        self:ChangCurWing(wing.id)
      end)
    end
  end
end
def.static("table").OnSResetWingRep = function(p)
  local self = WingModule.Instance()
  if self:IsWingSetup() then
    local wing = self.wingData:GetWingByWingId(p.cfgId)
    if wing then
      if p.resetType == 0 then
        wing.resetProps = 0 < #p.reIds and clone(p.reIds) or nil
        self:ShowResetAttr(wing.id, false)
        Toast(textRes.Wing[31])
      elseif p.resetType == 1 then
        wing.resetSkills = 0 < #p.reIds and clone(p.reIds) or nil
        self:ShowResetSkill(wing.id, false)
        Toast(textRes.Wing[32])
      end
    end
  end
end
def.static("table").OnSRpWingContentRep = function(p)
  local self = WingModule.Instance()
  if self:IsWingSetup() then
    local wing = self.wingData:GetWingByWingId(p.cfgId)
    if wing then
      if p.resetType == 0 then
        wing.props = 0 < #p.curIds and clone(p.curIds) or nil
        wing.resetProps = nil
        self:ShowResetAttr(wing.id, true)
      elseif p.resetType == 1 then
        wing.skills = 0 < #p.curIds and clone(p.curIds) or nil
        wing.resetSkills = nil
        self:ShowResetSkill(wing.id, true)
      end
      Event.DispatchEvent(ModuleId.WING, gmodule.notifyId.Wing.WINGS_DATA_CHANGE, {
        p.cfgId
      })
      Toast(textRes.Wing[33])
    end
  end
end
def.static("table").OnSSynOutLook = function(p)
  local self = WingModule.Instance()
  if self:IsWingSetup() then
    self.wingData:SetCurWingId(p.curCfgId)
    Event.DispatchEvent(ModuleId.WING, gmodule.notifyId.Wing.WINGS_CHANGE, {
      p.curCfgId
    })
    if p.curCfgId > 0 then
      local wingFakeItem = WingUtils.GetWingFakeItemByWingId(p.curCfgId)
      Toast(string.format(textRes.Wing[22], wingFakeItem.name))
    else
      Toast(textRes.Wing[23])
    end
  end
end
def.static("table").OnSSynWingColor = function(p)
  local self = WingModule.Instance()
  if self:IsWingSetup() then
    local wing = self.wingData:GetWingByWingId(p.cfgId)
    if wing then
      wing.colorId = p.colorId
    end
    self:ShowDyeWingPanel(p.cfgId)
    Toast(textRes.Wing[29])
  end
end
def.static("table").OnSCheckWingsRep = function(p)
  local ItemUtils = require("Main.Item.ItemUtils")
  local roleId = p.roleId
  local wingId = p.checkWing
  local level = p.curLv
  local phase = p.curRank
  local wingCfg = WingUtils.GetWingCfg(wingId)
  local outlookId = wingCfg and wingCfg.outlook or 0
  local wings = p.wings
  local curWing = wings[wingId]
  local colorId = curWing and curWing.colorId or 0
  local outlookCfg = WingUtils.GetWingViewCfg(outlookId)
  local fakeItemId = outlookCfg and outlookCfg.fakeItemId or constant.WingConsts.WING_FAKE_ITEM_ID
  local itemBase = ItemUtils.GetItemBase(fakeItemId)
  local name = itemBase.name
  local skills = {}
  for k, v in pairs(wings) do
    local skill = v.skills and v.skills[1] or nil
    if skill then
      table.insert(skills, skill)
    end
  end
  table.sort(skills)
  local property = WingUtils.GetWingLevelProps(level)
  for k, v in pairs(wings) do
    if v.proIds then
      local prop = WingUtils.ConvertWingProps(v.proIds)
      property:Plus(prop)
    end
  end
  require("Main.Wing.ui.WingCheckDlg").CheckWing(name, level, phase, outlookId, colorId, property, skills)
end
def.static("table").OnSSetTargetSkillRep = function(p)
  local skillCfgData = require("Main.Skill.SkillUtility").GetSkillCfg(p.skill_id)
  if skillCfgData == nil then
    return
  end
  Toast(textRes.Wing[46]:format(skillCfgData.name))
  Event.DispatchEvent(ModuleId.WING, gmodule.notifyId.Wing.GOAL_WINGSKILL_CHANGE, p)
end
def.static("table").OnSUnsetTargetSkillRep = function(p)
  Toast(textRes.Wing[47])
  Event.DispatchEvent(ModuleId.WING, gmodule.notifyId.Wing.UNSET_TARGET_SKILL, p)
end
def.static("table").OnSRenameOccupationPlanNameRep = function(p)
  warn("-----OnSRenameOccupationPlanNameRep:", p.result)
  if p.result == p.RES_SUC then
    local self = WingModule.Instance()
    self.wingData:SetOccPlanName(p.occupationId, p.newName)
    Event.DispatchEvent(ModuleId.WING, gmodule.notifyId.Wing.WING_PLAN_NAME_CHANGE, nil)
  end
end
def.static("table").OnSWingNormalResult = function(p)
  local ret = p.result
  local params = p.args
  if ret == p.NOT_ENOUGH_YUANBAO then
    _G.GotoBuyYuanbao()
  else
    local tip = textRes.Wing.Error[ret]
    if tip then
      Toast(tip)
    end
  end
  if ret == p.NO_MORE_SKILLS_TO_RAN then
    require("Main.Wing.ui.ResetSkillDlg").Instance():Unlock()
  elseif ret == p.TARGET_SKILL_ALREADY_SET then
    warn(">>>>Target skill already set <<<<")
  end
end
def.static("table", "table").OnWingsBtnClicked = function(p1, p2)
  local self = WingModule.Instance()
  if self:IsWingSetup() then
    self:OpenWingPanel()
  elseif not _G.CheckCrossServerAndToast() then
    local graphID = constant.WingConsts.WING_GRAPH_ID
    local taskID = self:GetCurWingsTaskID()
    if taskID ~= 0 then
      Toast(textRes.Wing[5])
      Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.TASK_TRACE_ITEM_CLICK, {taskID, graphID})
    else
      Toast(textRes.Wing[6])
    end
  end
end
def.method("=>", "boolean").IsWingSetup = function(self)
  return self.wingData ~= nil
end
def.method("=>", WingData).GetWingData = function(self)
  return self.wingData
end
def.method().OpenWingPanel = function(self)
  if self:IsWingSetup() then
    require("Main.Wing.ui.WingPanel").ShowWingPanel(-1)
  end
end
def.method().TryUpgrade = function(self)
  if CheckCrossServerAndToast() then
    return
  end
  if self:IsWingSetup() then
    local level = self.wingData:GetLevel()
    local levelCfg = WingUtils.GetUpgradeCfgByLevel(level)
    if levelCfg == nil then
      return
    end
    local curPhase = self.wingData:GetPhase()
    if curPhase < levelCfg.needrank then
      Toast(textRes.Wing[12])
      return
    end
    local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
    require("Main.Wing.ui.CommonItemUse").ShowCommonUse(textRes.Wing[14], {
      ItemType.WING_EXP_ITEM
    }, function(itemId, useAll)
      local level = self.wingData:GetLevel()
      local levelCfg = WingUtils.GetUpgradeCfgByLevel(level)
      if levelCfg == nil then
        return false
      end
      local curPhase = self.wingData:GetPhase()
      if curPhase < levelCfg.needrank then
        Toast(textRes.Wing[12])
        return false
      end
      self:SendAddExp(itemId, useAll)
    end)
  end
end
def.method("number", "boolean").SendAddExp = function(self, itemId, useAll)
  local ItemModule = require("Main.Item.ItemModule")
  local num = ItemModule.Instance():GetNumberByItemId(ItemModule.BAG, itemId)
  local key, item = ItemModule.Instance():SelectOneItemByItemId(ItemModule.BAG, itemId)
  if key >= 0 then
    local uuid = item.uuid[1]
    local num = useAll and -1 or 1
    local p = require("netio.protocol.mzm.gsp.wing.CAddWingExpReq").new(uuid, num)
    gmodule.network.sendProtocol(p)
  else
    Toast(textRes.Wing[30])
  end
end
def.method("table", "number").ShowPromote = function(self, wing, type)
  local wingId = wing.id
  if wing.props and wing.skills then
    local desc = WingUtils.PropsToString2(wingId, wing.props, "")
    local desc2 = WingUtils.SkillToString(wing.skills[1])
    require("Main.Wing.ui.PromoteDlg").ShowWingPromote2(wingId, desc, desc2, type)
  elseif wing.props then
    local desc = WingUtils.PropsToString2(wingId, wing.props, "")
    require("Main.Wing.ui.PromoteDlg").ShowWingPromote(wingId, desc, type)
  elseif wing.skills then
    local desc = WingUtils.SkillToString(wing.skills[1])
    require("Main.Wing.ui.PromoteDlg").ShowWingPromote(wingId, desc, type)
  end
end
def.method().TryPromote = function(self)
  if CheckCrossServerAndToast() then
    return
  end
  if self:IsWingSetup() then
    local curPhase = self.wingData:GetPhase()
    local maxPhase = WingUtils.GetMaxPhase()
    if curPhase >= maxPhase then
      Toast(textRes.Wing[7])
      return
    end
    local needWingLevel = WingUtils.GetLevelLimitByPhase(curPhase + 1)
    local myWingLevel = self.wingData:GetLevel()
    if needWingLevel > myWingLevel then
      Toast(string.format(textRes.Wing[8], needWingLevel, curPhase + 1))
      return
    end
    local phaseCfg = WingUtils.GetPromoteCfgByPhase(curPhase + 1)
    local needRoleLv = phaseCfg.upNeedRoleLv
    local myLevel = require("Main.Hero.Interface").GetBasicHeroProp().level
    if needRoleLv > myLevel then
      Toast(string.format(textRes.Wing[9], needRoleLv, curPhase + 1))
      return
    end
    local needItemId = phaseCfg.needItemId
    local needItemNum = phaseCfg.itemNum
    local ItemConsumeHelper = require("Main.Item.ItemConsumeHelper")
    ItemConsumeHelper.Instance():ShowItemConsume(textRes.Wing[10], string.format(textRes.Wing[11], curPhase + 1), needItemId, needItemNum, function(select)
      if select == 0 then
        instance:SendPhaseUp(false)
      elseif select > 0 then
        instance:SendPhaseUp(true)
      else
        return
      end
    end)
  end
end
def.method("boolean").SendPhaseUp = function(self, useYuanbao)
  local ItemModule = require("Main.Item.ItemModule")
  local curPhase = self.wingData:GetPhase()
  local phaseCfg = WingUtils.GetPromoteCfgByPhase(curPhase + 1)
  local needItemId = phaseCfg.needItemId
  local useYb = useYuanbao
  local num = ItemModule.Instance():GetNumberByItemId(ItemModule.BAG, needItemId)
  local key, item = ItemModule.Instance():SelectOneItemByItemId(ItemModule.BAG, needItemId)
  if key >= 0 or useYb then
    local uuid = item and item.uuid[1] or Int64.new()
    local yuanbao = ItemModule.Instance():GetAllYuanBao()
    local p = require("netio.protocol.mzm.gsp.wing.CAddWingRankReq").new(uuid, num, useYb and 1 or 0, yuanbao)
    gmodule.network.sendProtocol(p)
  else
    Toast(textRes.Wing[30])
  end
end
def.method("number").ChangCurWing = function(self, wingId)
  if CheckCrossServerAndToast() then
    return
  end
  if self:IsWingSetup() then
    if wingId > 0 then
      local p = require("netio.protocol.mzm.gsp.wing.CGetOnWingReq").new(wingId)
      gmodule.network.sendProtocol(p)
    else
      local p = require("netio.protocol.mzm.gsp.wing.CGetOffWingReq").new()
      gmodule.network.sendProtocol(p)
    end
  end
end
def.method("number", "boolean").ShowResetAttr = function(self, wingId, withEffect)
  if self:IsWingSetup() then
    local wing = self.wingData:GetWingByWingId(wingId)
    if wing then
      require("Main.Wing.ui.ResetAttrDlg").ResetAttr(wing.id, wing.props, wing.resetProps)
      if withEffect then
        require("Main.Wing.ui.ResetAttrDlg").PlayEffect()
      end
    end
  end
end
def.method("number", "boolean").ShowResetSkill = function(self, wingId, withEffect)
  if self:IsWingSetup() then
    local wing = self.wingData:GetWingByWingId(wingId)
    if wing then
      require("Main.Wing.ui.ResetSkillDlg").ResetSkill(wing.id, wing.skills[1], wing.resetSkills and wing.resetSkills[1] or 0)
      if withEffect then
        require("Main.Wing.ui.ResetSkillDlg").PlayEffect()
      end
    end
  end
end
local propScore = {
  0,
  0,
  0,
  1,
  1
}
def.method("number", "=>", "boolean").IsWingAttrGood = function(self, wingId)
  local ret = false
  local wing = self.wingData:GetWingByWingId(wingId)
  if wing then
    local props = wing.resetProps
    if props then
      local totalScore = 0
      for k, v in ipairs(props) do
        local propCfg = WingUtils.GetWingProperty(v)
        local color = propCfg and propCfg.propColor or 1
        local colorScore = propScore[color] or 0
        totalScore = totalScore + colorScore
      end
      if totalScore > 1 then
        ret = true
      end
    end
  end
  return ret
end
def.method("number", "boolean", "function", "=>", "number").WashAttr = function(self, wingId, useYb, cb)
  local ItemModule = require("Main.Item.ItemModule")
  local wingCfg = WingUtils.GetWingCfg(wingId)
  local needItemId = wingCfg.resetProItemId
  local useYb = useYb
  local num = ItemModule.Instance():GetNumberByItemId(ItemModule.BAG, needItemId)
  local key, item = ItemModule.Instance():SelectOneItemByItemId(ItemModule.BAG, needItemId)
  if not useYb and key < 0 then
    return -1
  end
  local function SendReq()
    local uuid = item and item.uuid[1] or Int64.new()
    local yuanbao = ItemModule.Instance():GetAllYuanBao()
    local p = require("netio.protocol.mzm.gsp.wing.CResetWingReq").new(wingId, 0, uuid, num, useYb and 1 or 0, yuanbao)
    gmodule.network.sendProtocol(p)
  end
  if self:IsWingAttrGood(wingId) then
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowConfirm("", textRes.Wing[43], function(select)
      if select == 1 then
        SendReq()
        if cb then
          cb()
        end
      end
    end, nil)
    return 1
  else
    SendReq()
    return 0
  end
  return 0
end
def.method("number", "boolean", "=>", "number").WashSkill = function(self, wingId, useYb)
  local ItemModule = require("Main.Item.ItemModule")
  local wingCfg = WingUtils.GetWingCfg(wingId)
  local needItemId = wingCfg.resetSkillItemId
  local useYb = useYb
  local num = ItemModule.Instance():GetNumberByItemId(ItemModule.BAG, needItemId)
  local key, item = ItemModule.Instance():SelectOneItemByItemId(ItemModule.BAG, needItemId)
  if not useYb and key < 0 then
    return -1
  end
  local uuid = item and item.uuid[1] or Int64.new()
  local yuanbao = ItemModule.Instance():GetAllYuanBao()
  local p = require("netio.protocol.mzm.gsp.wing.CResetWingReq").new(wingId, 1, uuid, num, useYb and 1 or 0, yuanbao)
  gmodule.network.sendProtocol(p)
  return 0
end
def.method("number").ReplaceAttr = function(self, wingId)
  local p = require("netio.protocol.mzm.gsp.wing.CRpWingContentReq").new(wingId, 0)
  gmodule.network.sendProtocol(p)
end
def.method("number").ReplaceSkill = function(self, wingId)
  local p = require("netio.protocol.mzm.gsp.wing.CRpWingContentReq").new(wingId, 1)
  gmodule.network.sendProtocol(p)
end
def.method("number").ShowDyeWingPanel = function(self, wingId)
  if self:IsWingSetup() then
    local wing = self.wingData:GetWingByWingId(wingId)
    if wing then
      local colorId = wing.colorId
      require("Main.Wing.ui.WingDyePanel").ShowDyeWing(wingId, colorId)
    end
  end
end
def.method("number", "boolean", "=>", "number").DyeWingRandom = function(self, wingId, useYb)
  local ItemModule = require("Main.Item.ItemModule")
  local wingCfg = WingUtils.GetWingCfg(wingId)
  local needItemId = constant.WingConsts.WING_DYE_ITEM_ID
  local useYb = useYb
  local num = ItemModule.Instance():GetNumberByItemId(ItemModule.BAG, needItemId)
  local key, item = ItemModule.Instance():SelectOneItemByItemId(ItemModule.BAG, needItemId)
  if not useYb and key < 0 then
    return -1
  end
  local uuid = item and item.uuid[1] or Int64.new()
  local yuanbao = ItemModule.Instance():GetAllYuanBao()
  local p = require("netio.protocol.mzm.gsp.wing.CChangeWingColor").new(wingId, uuid, num, useYb and 1 or 0, yuanbao)
  gmodule.network.sendProtocol(p)
  return 0
end
def.method("=>", "number").GetCurWingsTaskID = function(self)
  local TaskInterface = require("Main.task.TaskInterface")
  local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
  local graphID = constant.WingConsts.WING_GRAPH_ID
  local taskInfos = TaskInterface.Instance():GetTaskInfos()
  for taskId, graphIdValue in pairs(taskInfos) do
    for graphId, info in pairs(graphIdValue) do
      if graphId == graphID and (info.state == TaskConsts.TASK_STATE_ALREADY_ACCEPT or info.state == TaskConsts.TASK_STATE_CAN_ACCEPT or info.state == TaskConsts.TASK_STATE_FINISH) then
        return taskId
      end
    end
  end
  return 0
end
def.method("userdata", "number").CheckOtherWing = function(self, roleId, wingId)
  local p = require("netio.protocol.mzm.gsp.wing.CCheckWingsReq").new(roleId, wingId)
  gmodule.network.sendProtocol(p)
end
def.static("table", "table").OnFeatureInit = function(p, context)
end
def.static("table", "table").OnFeatureOpenChange = function(p, context)
  if p.feature == Feature.TYPE_WING_SET_TARGET_SKILL then
    local ResetSkillDlg = require("Main.Wing.ui.ResetSkillDlg")
    local WingSkillGallery = require("Main.Wing.ui.WingSkillGallery")
    ResetSkillDlg.Instance():UpdateUIGoalSettingSkills()
    WingSkillGallery.Instance():UpdateUISkillInfo()
  elseif p.feature == Feature.TYPE_WING_OCC_PLAN then
    local self = WingModule.Instance()
    if self.wingData and _G.IsFeatureOpen(Feature.TYPE_WING_OCC_PLAN) then
      self.wingData:SetNewOpendFlag(true)
    end
    Event.DispatchEvent(ModuleId.WING, gmodule.notifyId.Wing.WINGS_RED_POINT_REFRESH, nil)
  end
end
def.static("=>", "boolean").IsSetTargetSkillFeatureOpen = function()
  local featureOpenModule = FeatureOpenListModule.Instance()
  local bFeatureOpen = featureOpenModule:CheckFeatureOpen(Feature.TYPE_WING_SET_TARGET_SKILL)
  return bFeatureOpen
end
WingModule.Commit()
return WingModule
