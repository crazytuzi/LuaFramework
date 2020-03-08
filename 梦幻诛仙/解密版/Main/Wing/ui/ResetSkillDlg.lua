local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ResetSkillDlg = Lplus.Extend(ECPanelBase, "ResetSkillDlg")
local WingModule = require("Main.Wing.WingModule")
local WingUtils = require("Main.Wing.WingUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local SkillUtility = require("Main.Skill.SkillUtility")
local def = ResetSkillDlg.define
local instance
def.static("=>", ResetSkillDlg).Instance = function()
  if instance == nil then
    instance = ResetSkillDlg()
  end
  return instance
end
def.field("number").wingId = 0
def.field("number").curSkill = 0
def.field("number").resetSkill = 0
def.field("boolean").useYuanbao = false
def.field("boolean").locked = false
def.field("number").lockTimer = 0
def.field("number")._selectIdx = 0
def.const("number").MAX_GOAL_SKILLS = 3
def.static().PlayEffect = function()
  local self = ResetSkillDlg.Instance()
  if self:IsShow() then
    local effect = self.m_panel:FindDirect("UITexiao")
    effect:SetActive(false)
    effect:SetActive(true)
  end
end
def.static("number", "number", "number").ResetSkill = function(wingId, curSkill, resetSkill)
  if curSkill <= 0 then
    return
  end
  local self = ResetSkillDlg.Instance()
  if self:IsShow() then
    if wingId == self.wingId then
      self.curSkill = curSkill
      self.resetSkill = resetSkill
      self:Unlock()
      self:UpdateCompare()
      self:UpdateUIGoalSettingSkills()
    end
  else
    self.useYuanbao = false
    self.wingId = wingId
    self.curSkill = curSkill
    self.resetSkill = resetSkill
    self:Unlock()
    self:CreatePanel(RESPATH.PANEL_WINGRESETSKILL, 2)
    self:SetModal(true)
  end
end
def.method().Unlock = function(self)
  self.locked = false
  GameUtil.RemoveGlobalTimer(self.lockTimer)
  self.lockTimer = 0
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, ResetSkillDlg.OnItemChange, self)
  Event.RegisterEvent(ModuleId.WING, gmodule.notifyId.Wing.GOAL_WINGSKILL_CHANGE, ResetSkillDlg.OnGoalWingSkillChange)
  Event.RegisterEvent(ModuleId.WING, gmodule.notifyId.Wing.UNSET_TARGET_SKILL, ResetSkillDlg.OnUnsetTargetSkill)
  self:UpdateCompare()
  self:UpdateResetBtn()
  self:UpdateUIGoalSettingSkills()
end
def.override("boolean").OnShow = function(self, isShow)
end
def.override().OnDestroy = function(self)
  self:Unlock()
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, ResetSkillDlg.OnItemChange)
  Event.UnregisterEvent(ModuleId.WING, gmodule.notifyId.Wing.GOAL_WINGSKILL_CHANGE, ResetSkillDlg.OnGoalWingSkillChange)
  Event.UnregisterEvent(ModuleId.WING, gmodule.notifyId.Wing.UNSET_TARGET_SKILL, ResetSkillDlg.OnUnsetTargetSkill)
  self._selectIdx = 0
end
def.method().UpdateUIGoalSettingSkills = function(self)
  if not self:IsShow() then
    return
  end
  if not WingModule.IsSetTargetSkillFeatureOpen() then
    self.m_panel:FindDirect("Img_Bg/Group_Target"):SetActive(false)
    return
  else
    self.m_panel:FindDirect("Img_Bg/Group_Target"):SetActive(true)
  end
  local targetSkills = {}
  local wingData = WingModule.Instance():GetWingData()
  wingData:UnsertAllPhaseTargetSkillBySkillId(self.curSkill)
  for i = 1, ResetSkillDlg.MAX_GOAL_SKILLS do
    local skillId = wingData:GetTargetSkillIdByIdx(self.wingId, i)
    table.insert(targetSkills, skillId)
  end
  wingData:UnsertAllPhaseTargetSkillBySkillId(self.curSkill)
  for i = 1, ResetSkillDlg.MAX_GOAL_SKILLS do
    local ctrlRoot = self.m_panel:FindDirect(("Img_Bg/Group_Target/Img_BgSkill%02d"):format(i))
    local imgGoal = ctrlRoot:FindDirect("Img_HS_IconSkill01")
    local imgAdd = ctrlRoot:FindDirect("Img_HS_SkillAdd01")
    local skill_id = targetSkills[i]
    if skill_id == nil or skill_id == 0 then
      GUIUtils.SetActive(imgGoal, false)
      GUIUtils.SetActive(imgAdd, true)
    else
      local skillCfg = SkillUtility.GetSkillCfg(skill_id)
      GUIUtils.FillIcon(imgGoal:GetComponent("UITexture"), skillCfg.iconId)
      GUIUtils.SetActive(imgGoal, true)
      GUIUtils.SetActive(imgAdd, false)
    end
  end
end
def.method("number").SetSelectIdx = function(self, idx)
  self._selectIdx = idx
end
def.static("table", "table").OnGoalWingSkillChange = function(p, context)
  local self = ResetSkillDlg.Instance()
  if not self:IsShow() then
    return
  end
  local wingData = WingModule.Instance():GetWingData()
  warn("wingId = " .. p.cfg_id .. " index=" .. p.index .. " skill_id=" .. p.skill_id)
  wingData:SetTargetSkill(p.cfg_id, p.index, p.skill_id)
  self:UpdateUIGoalSettingSkills()
end
def.static("table", "table").OnUnsetTargetSkill = function(p, context)
  if p.index > ResetSkillDlg.MAX_GOAL_SKILLS then
    return
  end
  local self = ResetSkillDlg.Instance()
  local wingData = WingModule.Instance():GetWingData()
  wingData:SetTargetSkill(p.cfg_id, p.index, 0)
  self:UpdateUIGoalSettingSkills()
end
def.method("table").OnItemChange = function(self, parms)
  self:UpdateResetBtn()
end
def.method().UpdateCompare = function(self)
  local currentGroup = self.m_panel:FindDirect("Img_Bg/Group_Current")
  local resetGroup = self.m_panel:FindDirect("Img_Bg/Group_Result")
  local resetTip = self.m_panel:FindDirect("Label_ResetTips")
  self:SetSkillInfo(currentGroup, self.curSkill)
  local replaceBtn = self.m_panel:FindDirect("Img_Bg/Gruop_Btn/Btn_Replace")
  if self.resetSkill > 0 then
    resetGroup:SetActive(true)
    resetTip:SetActive(false)
    self:SetSkillInfo(resetGroup, self.resetSkill)
    replaceBtn:GetComponent("UIButton"):set_isEnabled(true)
  else
    resetGroup:SetActive(false)
    resetTip:SetActive(true)
    replaceBtn:GetComponent("UIButton"):set_isEnabled(false)
  end
end
def.method("userdata", "number").SetSkillInfo = function(self, skillUI, skillId)
  local nameLbl = skillUI:FindDirect("Label_SkillName")
  local infoLbl = skillUI:FindDirect("Label_SkillInfo")
  local icon = skillUI:FindDirect("Img_SkillKuang/Img_SkillIcon")
  local skillCfg = SkillUtility.GetSkillCfg(skillId)
  local uiTex = icon:GetComponent("UITexture")
  GUIUtils.FillIcon(uiTex, skillCfg.iconId)
  infoLbl:GetComponent("UILabel"):set_text(skillCfg.description)
  nameLbl:GetComponent("UILabel"):set_text(skillCfg.name)
end
def.method().UpdateResetBtn = function(self)
  local ItemModule = require("Main.Item.ItemModule")
  local wingCfg = WingUtils.GetWingCfg(self.wingId)
  local needItem = wingCfg.resetSkillItemId
  local needNum = wingCfg.resetSkillItemNum
  local hasNum = ItemModule.Instance():GetItemCountById(needItem)
  local itemUI = self.m_panel:FindDirect("Img_Bg/Img_Item")
  local itemBase = ItemUtils.GetItemBase(needItem)
  local tex = itemUI:FindDirect("Texture_Item")
  local uiTex = tex:GetComponent("UITexture")
  GUIUtils.FillIcon(uiTex, itemBase.icon)
  local numlbl = itemUI:FindDirect("Label")
  numlbl:GetComponent("UILabel"):set_text(string.format("%d/%d", hasNum, needNum))
  local nameLbl = itemUI:FindDirect("Label_ItemName")
  nameLbl:GetComponent("UILabel"):set_text(itemBase.name)
  self:SetUseYuanbao(self.useYuanbao)
end
def.method("boolean").SetUseYuanbao = function(self, use)
  local ItemModule = require("Main.Item.ItemModule")
  local wingCfg = WingUtils.GetWingCfg(self.wingId)
  local needItem = wingCfg.resetSkillItemId
  local needNum = wingCfg.resetSkillItemNum
  local hasNum = ItemModule.Instance():GetItemCountById(needItem)
  if use and needNum <= hasNum then
    Toast(textRes.Wing[28])
    use = false
  end
  self.useYuanbao = use
  local btn_useGold = self.m_panel:FindDirect("Img_Bg/Img_Item/Btn_UseGold")
  btn_useGold:GetComponent("UIToggle"):set_value(self.useYuanbao)
  local washBtn = self.m_panel:FindDirect("Img_Bg/Gruop_Btn/Btn_Wash")
  local noyuanbao = washBtn:FindDirect("Label_Wash")
  local yuanbao = washBtn:FindDirect("Group_Yuanbao")
  if use then
    noyuanbao:SetActive(false)
    yuanbao:SetActive(true)
    do
      local yuanbaoLbl = yuanbao:FindDirect("Label_Money"):GetComponent("UILabel")
      yuanbaoLbl:set_text("----")
      require("Main.Item.ItemConsumeHelper").Instance():GetItemYuanBaoPrice(needItem, function(result)
        if yuanbaoLbl.isnil then
          return
        end
        yuanbaoLbl:set_text(tostring(result * (needNum - hasNum)))
      end)
    end
  else
    noyuanbao:SetActive(true)
    yuanbao:SetActive(false)
  end
end
def.method("string").onClick = function(self, id)
  warn(">>>>id = " .. id .. "<<<<<")
  if id == "Btn_Wash" then
    self:OnBtnWashClick()
  elseif id == "Btn_Replace" then
    if CheckCrossServerAndToast() then
      return
    end
    WingModule.Instance():ReplaceSkill(self.wingId)
  elseif id == "Btn_SkillLib" then
    local phase = WingUtils.WingIdToPhase(self.wingId)
    if phase >= 0 then
      require("Main.Wing.ui.WingSkillGallery").ShowWingSkills(phase)
    else
      require("Main.Wing.ui.WingSkillGallery").ShowOneWingSkills(self.wingId)
    end
  elseif id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Tips" then
    WingUtils.ShowQA(constant.WingConsts.SKILL_RESET_TIP_ID)
  elseif id == "Texture_Item" then
    local wingCfg = WingUtils.GetWingCfg(self.wingId)
    local needItem = wingCfg.resetSkillItemId
    local go = self.m_panel:FindDirect("Img_Bg/Img_Item/" .. id)
    if go then
      require("Main.Item.ItemTipsMgr").Instance():ShowBasicTipsWithGO(needItem, go, 0, true)
    end
  elseif string.find(id, "Img_BgSkill%d%d") ~= nil then
    local idx = tonumber(string.sub(id, id:find("%d%d")))
    self:SetSelectIdx(idx)
    local phase = WingUtils.WingIdToPhase(self.wingId)
    local bSetTargetOpen = WingModule.IsSetTargetSkillFeatureOpen()
    if phase >= 0 and bSetTargetOpen then
      require("Main.Wing.ui.WingSkillGallery").ShowWingSkillsByTargetPosIdx(phase, idx)
    else
      require("Main.Wing.ui.WingSkillGallery").ShowOneWingSkills(self.wingId)
    end
  end
end
def.method("string", "boolean").onToggle = function(self, id, active)
  if id == "Btn_UseGold" then
    if active then
      self:SetUseYuanbao(true)
    else
      self:SetUseYuanbao(false)
    end
  end
end
def.method().OnBtnWashClick = function(self)
  if CheckCrossServerAndToast() then
    return
  end
  if self.locked then
    Toast(textRes.Wing[42])
    return
  end
  if WingModule.IsSetTargetSkillFeatureOpen() then
    local bHasTargetSkill = false
    for i = 1, ResetSkillDlg.MAX_GOAL_SKILLS do
      local targetSkill = WingModule.Instance():GetWingData():GetTargetSkillIdByIdx(self.wingId, i)
      if targetSkill ~= 0 and targetSkill == self.resetSkill then
        bHasTargetSkill = true
        break
      end
    end
    if bHasTargetSkill and self.curSkill ~= self.resetSkill then
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      CommonConfirmDlg.ShowConfirm(textRes.Wing[49], textRes.Wing[50], function(select)
        if select == 1 then
          self:ToWashSkill()
        end
      end, nil)
      return
    end
  end
  self:ToWashSkill()
end
def.method().ToWashSkill = function(self)
  local ret = WingModule.Instance():WashSkill(self.wingId, self.useYuanbao)
  if ret == -1 then
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowConfirm(textRes.Wing[38], textRes.Wing[39], function(select)
      if select == 1 then
        self:SetUseYuanbao(true)
      end
    end, nil)
  elseif ret == 0 then
    self.locked = true
    self.lockTimer = GameUtil.AddGlobalTimer(3, true, function()
      self.locked = false
    end)
  end
end
return ResetSkillDlg.Commit()
