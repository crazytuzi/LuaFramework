local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local CaptchaConfirmDlg = Lplus.Extend(ECPanelBase, "CaptchaConfirmDlg")
local Vector = require("Types.Vector")
local def = CaptchaConfirmDlg.define
def.static("string", "string", "string", "table", "function", "table", "=>", CaptchaConfirmDlg).ShowConfirm = function(content, btnLeft, btnRight, avatar, callback, context)
  local dlg = CaptchaConfirmDlg()
  dlg.m_content = content
  dlg.m_btnLeft = btnLeft
  dlg.m_btnRight = btnRight
  dlg.m_avatar = avatar
  dlg.m_callback = callback
  dlg.m_context = context
  dlg:ShowDlg()
  return dlg
end
local NOT_SET = -1
def.const("number").MAX_CAPTCHA = 4
def.field("string").m_captcha = ""
def.field("string").m_content = ""
def.field("string").m_btnLeft = ""
def.field("string").m_btnRight = ""
def.field("table").m_avatar = nil
def.field("table").m_digitalEntered = nil
def.field("function").m_callback = nil
def.field("table").m_context = nil
def.method().ShowDlg = function(self)
  if self:IsShow() then
    self:OnShow(true)
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
  self:UpdateContent()
  self:UpdateAvatar()
  self:UpdateCaptcha()
  self:UpdateEnteredValue()
  self:UpdateBtns()
  GameUtil.AddGlobalLateTimer(0, true, function()
    self:ShowDigitalKeyboard()
  end)
end
def.override().OnDestroy = function(self)
  self:Clear()
end
def.method().Init = function(self)
  self.m_digitalEntered = {}
  self.m_captcha = _G.GetDigitalCaptcha()
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
  self.m_captcha = ""
  self.m_content = ""
  self.m_btnLeft = ""
  self.m_btnRight = ""
  self.m_avatar = nil
  self.m_digitalEntered = nil
  self.m_callback = nil
  self.m_context = nil
end
def.static("string", "table").DigitalKeyboardCallback = function(key, context)
  local self = context.self
  if key == "ENTER" then
  elseif key == "DEL" then
    table.remove(self.m_digitalEntered)
    self:UpdateEnteredValue()
  elseif key == "CANCEL" then
  elseif #self.m_digitalEntered < CaptchaConfirmDlg.MAX_CAPTCHA then
    table.insert(self.m_digitalEntered, key)
    self:UpdateEnteredValue()
  end
end
def.method().OnComfirm = function(self)
  local enteredValue = self:GetEnteredStringValue()
  if enteredValue == self.m_captcha then
    if self.m_callback then
      local ret = self.m_callback(1, self.m_context)
      if ret ~= false then
        self:DestroyPanel()
      end
    else
      self:DestroyPanel()
    end
  else
    Toast(textRes.Common[16])
    self.m_digitalEntered = {}
    self:UpdateEnteredValue()
    self:OnInputFieldClick()
  end
end
def.method().OnCancel = function(self)
  if self.m_callback then
    self.m_callback(0, self.m_context)
  end
  self:DestroyPanel()
end
def.method().OnInputFieldClick = function(self)
  local CommonDigitalKeyboard = require("GUI.CommonDigitalKeyboard")
  if not CommonDigitalKeyboard.Instance():IsShow() then
    self:ShowDigitalKeyboard()
  end
end
def.method().ShowDigitalKeyboard = function(self)
  require("GUI.CommonDigitalKeyboard").Instance():ShowPanel(CaptchaConfirmDlg.DigitalKeyboardCallback, {self = self})
  require("GUI.CommonDigitalKeyboard").Instance():SetPos(275, 0)
end
def.method().UpdateContent = function(self)
  local tipsLabel = self.m_panel:FindDirect("Img_0/Label_Title")
  GUIUtils.SetText(tipsLabel, self.m_content)
end
def.method().UpdateAvatar = function(self)
  local Img_BgHead = self.m_panel:FindDirect("Img_0/Img_BgHead")
  if self.m_avatar == nil then
    GUIUtils.SetActive(Img_BgHead, false)
    return
  end
  GUIUtils.SetActive(Img_BgHead, true)
  local Icon_Head = Img_BgHead:FindDirect("Icon_Head")
  local avatar = self.m_avatar
  local line1 = avatar.line1 or ""
  local line2 = avatar.line2 or ""
  local iconId = avatar.iconId or 0
  local bgSprite = avatar.bgSprite or "Cell_00"
  GUIUtils.SetText(Img_BgHead:FindDirect("Label_PetName"), line1)
  GUIUtils.SetText(Img_BgHead:FindDirect("Label_Lv"), line2)
  GUIUtils.SetTexture(Icon_Head, iconId)
  GUIUtils.SetSprite(Img_BgHead, bgSprite)
end
def.method().UpdateCaptcha = function(self)
  local captcha = self.m_captcha
  local labelObj = self.m_panel:FindDirect("Img_0/Img_BgWords/Img_BgConfirmNum/Label_ConfirmNum2")
  GUIUtils.SetText(labelObj, captcha)
end
def.method().UpdateEnteredValue = function(self)
  local Img_BgWords = self.m_panel:FindDirect("Img_0/Img_BgWords")
  for i = 1, CaptchaConfirmDlg.MAX_CAPTCHA do
    local labelObj = Img_BgWords:FindDirect(string.format("Img_Bg%d/Label_Num%d", i, i))
    local value = self.m_digitalEntered[i] or ""
    GUIUtils.SetText(labelObj, value)
  end
end
def.method().UpdateBtns = function(self)
  if self.m_btnLeft ~= "" then
    local LabelObj = self.m_panel:FindDirect("Btn_Cancel/Label_Cancel")
    GUIUtils.SetText(LabelObj, self.m_btnLeft)
  end
  if self.m_btnRight ~= "" then
    local LabelObj = self.m_panel:FindDirect("Btn_Confirm/Label_Confirm")
    GUIUtils.SetText(LabelObj, self.m_btnRight)
  end
end
def.method("=>", "string").GetEnteredStringValue = function(self)
  return table.concat(self.m_digitalEntered)
end
return CaptchaConfirmDlg.Commit()
