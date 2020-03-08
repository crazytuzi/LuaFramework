local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECGUIMan = require("GUI.ECGUIMan")
local CommonRenamePanel = Lplus.Extend(ECPanelBase, "CommonRenamePanel")
local def = CommonRenamePanel.define
def.field("function").callbackFunc = nil
def.field("table").tag = nil
def.field("string").promptText = ""
def.field("boolean").handleSubmit = false
def.field("number").limit = 0
def.field("userdata").ui_Img_Bg0 = nil
def.field("userdata").ui_Img_BgInput = nil
def.field("userdata").ui_Label_NameCount = nil
local instance
def.static("=>", CommonRenamePanel).Instance = function()
  if instance == nil then
    instance = CommonRenamePanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method("string", "boolean", "number", "function", "table").ShowPanel2 = function(self, promptText, handleSubmit, limit, callbackFunc, tag)
  self.promptText = promptText
  self.callbackFunc = callbackFunc
  self.tag = tag
  self.handleSubmit = handleSubmit
  self.limit = handleSubmit and 0 or limit
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.COMMON_RENAME_PANEL_RES, 2)
  self:SetModal(true)
end
def.method("string", "boolean", "function", "table").ShowPanel = function(self, promptText, handleSubmit, callbackFunc, tag)
  self:ShowPanel2(promptText, handleSubmit, 0, callbackFunc, tag)
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
  self.ui_Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.ui_Img_BgInput = self.ui_Img_Bg0:FindDirect("Img_BgInput")
  self.ui_Label_NameCount = self.ui_Img_Bg0:FindChild("Label_NameCount")
  self.m_panel:FindDirect("Img_Bg0/Img_Correct"):SetActive(false)
  self.m_panel:FindDirect("Img_Bg0/Img_Wrong"):SetActive(false)
  self.ui_Img_BgInput:GetComponent("UIInput"):set_characterLimit(0)
  self:UpdatePromptText()
  self:UpdateLimitTip("")
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
end
def.override().OnDestroy = function(self)
  self.promptText = ""
  self.callbackFunc = nil
  self.tag = nil
  self.ui_Img_BgInput = nil
  self.ui_Img_Bg0 = nil
end
def.method("string").onClick = function(self, id)
  print(string.format("%s click event: id = %s", tostring(self), id))
  if id == "Btn_Confirm" then
    self:DoCallBack()
  elseif id == "Btn_Cancel" then
    self:HidePanel()
  elseif id == "Modal" then
    self:HidePanel()
  end
end
def.method("string", "userdata").onSubmit = function(self, id, ctrl)
  if not self.handleSubmit then
    return
  end
  print(string.format("%s submit event: id = %s", tostring(self), id))
  if id == "Img_BgInput" then
    local enteredName = self.ui_Img_BgInput:GetComponent("UIInput"):get_value()
    local isValid = self:ValidEnteredName(enteredName)
    self.m_panel:FindDirect("Img_Bg0/Img_Correct"):SetActive(isValid)
    self.m_panel:FindDirect("Img_Bg0/Img_Wrong"):SetActive(not isValid)
  end
end
def.method("string", "string").onTextChange = function(self, id, val)
  if id == "Img_BgInput" then
    self:UpdateLimitTip(val)
  end
end
def.method("string", "=>", "boolean").ValidEnteredName = function(self, enteredName)
  local NameValidator = require("Main.Common.NameValidator")
  local isValid, reason, _ = NameValidator.Instance():IsValid(enteredName)
  if isValid then
    return true
  else
    if reason == NameValidator.InvalidReason.TooShort then
      Toast(textRes.Login[15])
    elseif reason == NameValidator.InvalidReason.TooLong then
      Toast(textRes.Login[14])
    elseif reason == NameValidator.InvalidReason.NotInSection then
      Toast(textRes.Login[25])
    end
    self:TrimContent()
    return false
  end
end
def.method("string").UpdateLimitTip = function(self, content)
  if self.limit > 0 then
    local len, clen, hlen = Strlen(content)
    local showLen = math.ceil(clen / 2 + hlen)
    if showLen <= self.limit then
      self.ui_Label_NameCount:GetComponent("UILabel"):set_text(string.format("%d/%d", showLen, self.limit))
    else
      self.ui_Label_NameCount:GetComponent("UILabel"):set_text(string.format("[ff0000]%d/%d[-]", showLen, self.limit))
    end
  else
    self.ui_Label_NameCount:SetActive(false)
  end
end
def.method().UpdatePromptText = function(self)
  local label_prompt = self.m_panel:FindChild("Label_Tips"):GetComponent("UILabel")
  label_prompt:set_text(self.promptText)
end
def.method().TrimContent = function(self)
  local input_value = _G.TrimIllegalChar(self:GetInputContent())
  local input_content = self.ui_Img_BgInput:GetComponent("UIInput")
  input_content:set_value(input_value)
end
def.method().ClearContent = function(self)
  local input_content = self.ui_Img_BgInput:GetComponent("UIInput")
  input_content:set_value("")
end
def.method("function").SetCallBackFunc = function(self, func)
  self.callbackFunc = func
end
def.method().DoCallBack = function(self)
  if self.callbackFunc == nil then
    return
  end
  local inputContent = self:GetInputContent()
  local isKeepPanel = self.callbackFunc(inputContent, self.tag)
  if not isKeepPanel then
    self:HidePanel()
  end
end
def.method("=>", "string").GetInputContent = function(self)
  local input_content = self.ui_Img_BgInput:GetComponent("UIInput")
  return input_content:get_value()
end
CommonRenamePanel.Commit()
return CommonRenamePanel
