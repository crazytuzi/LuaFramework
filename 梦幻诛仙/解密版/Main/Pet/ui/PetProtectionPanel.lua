local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PetProtectionPanel = Lplus.Extend(ECPanelBase, "PetProtectionPanel")
local def = PetProtectionPanel.define
local Vector = require("Types.Vector")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local PetData = Lplus.ForwardDeclare("PetData")
local PetUtility = require("Main.Pet.PetUtility")
local PetModule = require("Main.Pet.PetModule")
local GUIUtils = require("GUI.GUIUtils")
local instance
local NOT_SET = -1
def.const("number").MAX_CAPTCHA = 4
def.field("userdata").petId = nil
def.field("function").protectOperation = nil
def.field("string").operationName = ""
def.field("string").protectTips = ""
def.field("string")._captcha = ""
def.field("table").digitalEntered = nil
def.static("=>", PetProtectionPanel).Instance = function()
  if instance == nil then
    instance = PetProtectionPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_PET_FREE_PROTECTION_PANEL_RES, 2)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:Init()
end
def.override("boolean").OnShow = function(self, s)
  if not s then
    return
  end
  self:UpdateCaptcha()
  self:UpdateEnteredValue()
  self:UpdatePetInfo()
  GameUtil.AddGlobalLateTimer(0, true, function()
    self:ShowDigitalKeyboard()
  end)
end
def.override().OnDestroy = function(self)
  self:Clear()
end
def.method().Init = function(self)
  self.digitalEntered = {}
  self._captcha = _G.GetDigitalCaptcha()
  self.m_panel.localPosition = Vector.Vector3.new(-135, 0, 0)
end
def.method("string").onClick = function(self, id)
  print(string.format("%s click event: id = %s", tostring(self), id))
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Confirm" then
    self:OnComfirm()
  elseif id == "Btn_Cancel" then
    self:OnCancel()
  elseif id == "Img_BgWords" then
    self:OnInputFieldClick()
  elseif string.sub(id, 1, 6) == "Img_Bg" and tonumber(string.sub(id, -1, -1)) ~= nil then
    self:OnInputFieldClick()
  end
end
def.method("userdata", "function", "string", "string").SetProtectOpertation = function(self, petId, operation, operationName, tips)
  self.petId = petId
  self.protectOperation = operation
  self.operationName = operationName
  self.protectTips = tips
end
def.method().Clear = function(self)
  self.petId = nil
  self.protectOperation = nil
  self.operationName = ""
  self.protectTips = ""
end
def.static("string", "table").DigitalKeyboardCallback = function(key, context)
  local self = context.self
  if key == "ENTER" then
  elseif key == "DEL" then
    table.remove(self.digitalEntered)
    self:UpdateEnteredValue()
  elseif key == "CANCEL" then
  elseif #self.digitalEntered < PetProtectionPanel.MAX_CAPTCHA then
    table.insert(self.digitalEntered, key)
    self:UpdateEnteredValue()
  end
end
def.method().OnComfirm = function(self)
  local enteredValue = self:GetEnteredStringValue()
  if enteredValue == self._captcha then
    if self.protectOperation ~= nil then
      self.protectOperation(self.petId)
    end
    self:DestroyPanel()
  else
    Toast(textRes.Common[16])
    self.digitalEntered = {}
    self:UpdateEnteredValue()
  end
end
def.method().OnCancel = function(self)
  self:DestroyPanel()
end
def.method().OnInputFieldClick = function(self)
  local CommonDigitalKeyboard = require("GUI.CommonDigitalKeyboard")
  if not CommonDigitalKeyboard.Instance():IsShow() then
    self:ShowDigitalKeyboard()
  end
end
def.method().ShowDigitalKeyboard = function(self)
  require("GUI.CommonDigitalKeyboard").Instance():ShowPanel(PetProtectionPanel.DigitalKeyboardCallback, {self = self})
  require("GUI.CommonDigitalKeyboard").Instance():SetPos(275, 0)
end
def.method().UpdateCaptcha = function(self)
  local captcha = self._captcha
  local labelObj = self.m_panel:FindDirect("Img_0/Img_BgWords/Img_BgConfirmNum/Label_ConfirmNum2")
  labelObj:GetComponent("UILabel").text = captcha
end
def.method().UpdateEnteredValue = function(self)
  local Img_BgWords = self.m_panel:FindDirect("Img_0/Img_BgWords")
  for i = 1, PetProtectionPanel.MAX_CAPTCHA do
    local labelObj = Img_BgWords:FindDirect(string.format("Img_Bg%d/Label_Num%d", i, i))
    local value = self.digitalEntered[i] or ""
    labelObj:GetComponent("UILabel").text = value
  end
end
def.method().UpdatePetInfo = function(self)
  local pet = PetMgr.Instance():GetPet(self.petId)
  local petCfgData = pet:GetPetCfgData()
  local petInfoRoot = self.m_panel:FindDirect("Img_0/Img_BgHead")
  petInfoRoot:FindDirect("Label_PetName"):GetComponent("UILabel").text = pet.name
  petInfoRoot:FindDirect("Label_Lv"):GetComponent("UILabel").text = string.format(textRes.Common[3], pet.level)
  local modelCfg = require("Main.Pubrole.PubroleInterface").GetModelCfg(petCfgData.modelId)
  local iconId = modelCfg.headerIconId
  local uiTexture = petInfoRoot:FindDirect("Icon_Head"):GetComponent("UITexture")
  local GUIUtils = require("GUI.GUIUtils")
  GUIUtils.FillIcon(uiTexture, iconId)
  local spriteName = pet:GetHeadIconBGSpriteName()
  GUIUtils.SetSprite(petInfoRoot, spriteName)
  local tipsLabel = self.m_panel:FindDirect("Img_0/Label_Title")
  GUIUtils.SetText(tipsLabel, self.protectTips)
  local confirmLabel = self.m_panel:FindDirect("Btn_Confirm/Label_Confirm")
  GUIUtils.SetText(confirmLabel, self.operationName)
end
def.method("=>", "string").GetEnteredStringValue = function(self)
  return table.concat(self.digitalEntered)
end
return PetProtectionPanel.Commit()
