local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ResetLivingSkillConfirmPanel = Lplus.Extend(ECPanelBase, "ResetLivingSkillConfirmPanel")
local LivingSkillUtility = require("Main.Skill.LivingSkillUtility")
local GUIUtils = require("GUI.GUIUtils")
local def = ResetLivingSkillConfirmPanel.define
def.field("table").skillBag = nil
def.field("table").uiObjs = nil
local dlg
def.static("=>", ResetLivingSkillConfirmPanel).Instance = function(self)
  if nil == dlg then
    dlg = ResetLivingSkillConfirmPanel()
  end
  return dlg
end
def.method("table").ShowPanelWithSkillBag = function(self, skillBag)
  if skillBag == nil then
    return
  end
  self.skillBag = skillBag
  self:CreatePanel(RESPATH.PREFAB_RESET_LIVING_SKILL_PANEL, 2)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:FillReturnInfo()
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.skillBag = nil
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Label_Title = self.m_panel:FindDirect("Img_0/Label_Title")
  self.uiObjs.Label = self.m_panel:FindDirect("Img_0/Img_BgWords/Label")
  self.uiObjs.Label_Life_UseMoneyNum = self.m_panel:FindDirect("Img_0/Group_Return/Label_Life_UseMoneyNum")
  self.uiObjs.Label_Life_UseGangNum = self.m_panel:FindDirect("Img_0/Group_Return/Label_Life_UseGangNum")
end
def.method().FillReturnInfo = function(self)
  local resetSkillLevel = LivingSkillUtility.GetLivingSkillConst("LIFESKILL_LEVEL_RESET_TO")
  local resetReturnRate = LivingSkillUtility.GetLivingSkillConst("LIFESKILL_LEVEL_RESET_RESTORE_RATE") / 10000
  local costSilver, costBanggong = LivingSkillUtility.GetTotalLevelUpInfo(self.skillBag.levelUpTypeId, resetSkillLevel, self.skillBag.level)
  GUIUtils.SetText(self.uiObjs.Label_Title, textRes.Skill[133])
  GUIUtils.SetText(self.uiObjs.Label, string.format(textRes.Skill[134], self.skillBag.name, resetSkillLevel, resetReturnRate * 100))
  GUIUtils.SetText(self.uiObjs.Label_Life_UseMoneyNum, math.ceil(costSilver * resetReturnRate))
  GUIUtils.SetText(self.uiObjs.Label_Life_UseGangNum, math.ceil(costBanggong * resetReturnRate))
end
def.method().OnClickConfirm = function(self)
  local resetSkillLevel = LivingSkillUtility.GetLivingSkillConst("LIFESKILL_LEVEL_RESET_TO")
  local resetReturnRate = LivingSkillUtility.GetLivingSkillConst("LIFESKILL_LEVEL_RESET_RESTORE_RATE") / 10000
  local costSilver, costBanggong = LivingSkillUtility.GetTotalLevelUpInfo(self.skillBag.levelUpTypeId, resetSkillLevel, self.skillBag.level)
  local returnSilver = math.ceil(costSilver * resetReturnRate)
  local returnBanggong = math.ceil(costBanggong * resetReturnRate)
  local GangModule = require("Main.Gang.GangModule")
  local hasGang = GangModule.Instance():HasGang()
  if returnBanggong > 0 and not hasGang then
    Toast(textRes.Skill[135])
    return
  end
  local skillBagId = self.skillBag.id
  local CaptchaConfirmDlg = require("GUI.CaptchaConfirmDlg")
  local function showCaptchaConfirm(select)
    if select == 1 then
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.lifeskill.CLifeSkillLevelResetReq").new(skillBagId, Int64.new(returnSilver), Int64.new(returnBanggong)))
      self:DestroyPanel()
    else
    end
  end
  local confirmStr = string.format(textRes.Skill[137], self.skillBag.name, resetSkillLevel)
  CaptchaConfirmDlg.ShowConfirm(confirmStr, "", textRes.Skill[136], nil, showCaptchaConfirm, nil)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Cancel" or id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Confirm" then
    self:OnClickConfirm()
  end
end
ResetLivingSkillConfirmPanel.Commit()
return ResetLivingSkillConfirmPanel
