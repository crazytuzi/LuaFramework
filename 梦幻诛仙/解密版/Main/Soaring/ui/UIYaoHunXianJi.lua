local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local UIYaoHunXianJi = Lplus.Extend(ECPanelBase, "UIYaoHunXianJi")
local GUIUtils = require("GUI.GUIUtils")
local def = UIYaoHunXianJi.define
local instance
def.field("number")._petId = 0
def.field("number")._needNum = 0
def.field("table")._uiGOs = nil
def.const("number").FX_DURATION = 2
def.static("=>", UIYaoHunXianJi).Instance = function()
  if instance == nil then
    instance = UIYaoHunXianJi()
  end
  return instance
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.SOARING, gmodule.notifyId.Soaring.YHXJ_COMMIT_SUCCESS, UIYaoHunXianJi.OnCommitPetSuccess)
  self._uiGOs = {}
  local fx = self.m_panel:FindDirect("Img _Bg0/Fx")
  fx:SetActive(false)
  self._uiGOs.fx = fx
  local texPet = self.m_panel:FindDirect("Img _Bg0/Img_Pet/Texture_pet")
  local lblNeed = self.m_panel:FindDirect("Img _Bg0/Img_Pet/LabelNum")
  local petCfgInfo = require("Main.Pet.PetUtility").Instance():GetPetCfg(self._petId)
  local headerIcon = require("Main.Pubrole.PubroleInterface").GetModelCfg(petCfgInfo.modelId).headerIconId
  GUIUtils.SetText(lblNeed, self._needNum)
  GUIUtils.SetTexture(texPet, headerIcon)
end
def.method("=>", "number").GetPetsNum = function(self)
  local PetInterface = require("Main.Pet.Interface")
  local petList = PetInterface.GetPetList()
  local petNum = PetInterface.GetPetNum()
  local iCount = 0
  for _, pet in pairs(petList) do
    local petCfgInfo = pet:GetPetCfgData()
    if petCfgInfo.templateId == self._petId then
      iCount = iCount + 1
    end
  end
  return iCount
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.SOARING, gmodule.notifyId.Soaring.YHXJ_COMMIT_SUCCESS, UIYaoHunXianJi.OnCommitPetSuccess)
  self._uiGOs = nil
  self._petId = 0
end
def.method("number", "number").ShowPanel = function(self, petId, needNum)
  if self:IsShow() or petId == 0 then
    return
  end
  self._petId = petId
  self._needNum = needNum
  self:CreatePanel(RESPATH.PREFAB_UI_YAOHUNXIANJI, 1)
  self:SetOutTouchDisappear()
end
def.method().HidePanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" then
    self:HidePanel()
  elseif id == "Btn_ConFirm" then
    self:OnBtnCommitClick()
  end
end
def.method().OnBtnCommitClick = function(self)
  local iHasNum = self:GetPetsNum()
  if iHasNum < self._needNum then
    Toast(textRes.Soaring.YaoHunXianJi[1])
  else
    local TaskYaoHunXianJi = require("Main.Soaring.proxy.TaskYaoHunXianJi")
    TaskYaoHunXianJi.SendAttendCommitPetActivityReq()
  end
end
def.static("table", "table").OnCommitPetSuccess = function(self)
  local self = UIYaoHunXianJi.Instance()
  if not self:IsShow() then
    return
  end
  self:DisplayEffect()
end
def.method().DisplayEffect = function(self)
  self._uiGOs.fx:SetActive(true)
  GameUtil.AddGlobalTimer(UIYaoHunXianJi.FX_DURATION, true, function()
    self:HidePanel()
  end)
end
return UIYaoHunXianJi.Commit()
