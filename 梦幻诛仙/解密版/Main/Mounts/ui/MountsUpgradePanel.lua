local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MountsUpgradePanel = Lplus.Extend(ECPanelBase, "MountsUpgradePanel")
local GUIUtils = require("GUI.GUIUtils")
local MountsUIModel = require("Main.Mounts.MountsUIModel")
local MountsUtils = require("Main.Mounts.MountsUtils")
local MountsMgr = require("Main.Mounts.mgr.MountsMgr")
local SkillUtility = require("Main.Skill.SkillUtility")
local SkillTipMgr = require("Main.Skill.SkillTipMgr")
local def = MountsUpgradePanel.define
local instance
def.static("=>", MountsUpgradePanel).Instance = function()
  if instance == nil then
    instance = MountsUpgradePanel()
  end
  return instance
end
def.const("number").STAYTIME = 1.5
def.field("number").createTime = 0
def.field(MountsUIModel).model = nil
def.field("userdata").mountsId = nil
def.static("userdata").ShowPanel = function(mountsId)
  local self = MountsUpgradePanel.Instance()
  if self:IsShow() or mountsId == nil then
    return
  end
  self.mountsId = mountsId
  self:CreatePanel(RESPATH.PANEL_WINGUPGRADE, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self.createTime = GetServerTime()
  self:UpdateTitle()
  self:UpdateDesc()
end
def.override().OnDestroy = function(self)
  if self.model then
    self.model:Destroy()
    self.model = nil
  end
  self.createTime = 0
  self.mountsId = nil
end
def.method().UpdateTitle = function(self)
  local title1 = self.m_panel:FindDirect("Img_Bg0/Img_Bg1/Title_UpgradeSuccess")
  local title2 = self.m_panel:FindDirect("Img_Bg0/Img_Bg1/Title_GetWing")
  title1:SetActive(true)
  title2:SetActive(false)
end
def.method().UpdateDesc = function(self)
  local descLbl = self.m_panel:FindDirect("Img_Bg0/Label_Middle")
  local descLblLeft = self.m_panel:FindDirect("Img_Bg0/Label_Left")
  local descLblRight = self.m_panel:FindDirect("Img_Bg0/Label_Right")
  descLbl:SetActive(false)
  descLblLeft:SetActive(false)
  descLblRight:SetActive(false)
  local Label_Info = self.m_panel:FindDirect("Img_Bg0/Label_Info")
  GUIUtils.SetText(Label_Info, textRes.Mounts[61])
  local Group_RidingPet = self.m_panel:FindDirect("Img_Bg0/Img_Bg1/Group_RidingPet")
  local realDesc = Group_RidingPet:FindDirect("Label_Middle")
  local Model_RidingPet = Group_RidingPet:FindDirect("Model_RidingPet")
  local uiModel = Model_RidingPet:GetComponent("UIModel")
  if self.model then
    self.model:Destroy()
  end
  local mounts = MountsMgr.Instance():GetMountsById(self.mountsId)
  if mounts == nil then
    GUIUtils.SetActive(Group_RidingPet, false)
    return
  end
  local showSkillId
  local unlockPassiveSkillLevel = MountsUtils.GetMountsSortedUnlockPassiveSkillRank(mounts.mounts_cfg_id)
  local hasUnlockPassiveSkill = false
  for i = 1, #unlockPassiveSkillLevel do
    if mounts.mounts_rank == unlockPassiveSkillLevel[i] then
      hasUnlockPassiveSkill = true
      showSkillId = mounts.passive_skill_list[i].current_passive_skill_cfg_id
      break
    end
  end
  local hasUnlockActiveSkill = false
  if not hasUnlockPassiveSkill then
    local activeSkillCfg = MountsUtils.GetMountsActiveSkillRankChange(mounts.mounts_cfg_id)
    if activeSkillCfg[mounts.mounts_rank] ~= nil then
      if activeSkillCfg[mounts.mounts_rank - 1] == nil or activeSkillCfg[mounts.mounts_rank - 1].skillId ~= activeSkillCfg[mounts.mounts_rank].skillId then
        hasUnlockActiveSkill = true
      end
      showSkillId = activeSkillCfg[mounts.mounts_rank].skillId
    end
  end
  self.model = MountsUtils.LoadMountsModel(uiModel, mounts.mounts_cfg_id, mounts.current_ornament_rank, mounts.color_id, function()
    if self.model ~= nil then
      self.model:SetDir(-135)
    end
  end)
  local desc = ""
  if showSkillId ~= nil then
    local skill = SkillUtility.GetSkillCfg(showSkillId)
    if skill ~= nil then
      if hasUnlockPassiveSkill then
        desc = string.format(textRes.Mounts[62], skill.name)
      elseif hasUnlockActiveSkill then
        desc = string.format(textRes.Mounts[63], skill.name)
      else
        desc = string.format(textRes.Mounts[64], skill.name)
      end
      realDesc.name = "Label_Middle" .. showSkillId
    end
  end
  GUIUtils.SetActive(Group_RidingPet, true)
  GUIUtils.SetText(realDesc, desc)
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if string.find(id, "Label_Middle") then
    local skillId = tonumber(string.sub(id, #"Label_Middle" + 1))
    if skillId ~= nil then
      SkillTipMgr.Instance():ShowTipByIdEx(skillId, obj, 0)
    end
  else
    self:onClick(id)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Modal" then
    local curTime = GetServerTime()
    if curTime - self.createTime > MountsUpgradePanel.STAYTIME then
      self:DestroyPanel()
    end
  end
end
return MountsUpgradePanel.Commit()
