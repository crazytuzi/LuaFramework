local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GangSignStrEditPanel = Lplus.Extend(ECPanelBase, "GangSignStrEditPanel")
local GangPurposeValidator = require("Main.Gang.GangPurposeValidator")
local def = GangSignStrEditPanel.define
local instance
local GangUtility = require("Main.Gang.GangUtility")
def.const("number").StrMax = 15
def.static("=>", GangSignStrEditPanel).Instance = function(self)
  if nil == instance then
    instance = GangSignStrEditPanel()
  end
  return instance
end
def.static().ShowGangSignStrEditPanel = function()
  GangSignStrEditPanel.Instance():SetModal(true)
  GangSignStrEditPanel.Instance():CreatePanel(RESPATH.PREFAB_GANG_SIGN_PANEL, 0)
end
def.override().OnCreate = function(self)
end
def.override().OnDestroy = function(self)
end
def.method().Hide = function(self)
  self:DestroyPanel()
  self = nil
end
def.method("userdata").FocusOnInput = function(self, clickobj)
  local input = clickobj:GetComponent("UIInput")
  input:set_isSelected(true)
end
def.method("string", "string").onTextChange = function(self, id, val)
  if self.m_panel and false == self.m_panel.isnil then
    local Img_Bg = self.m_panel:FindDirect("Img_Bg")
    local inputContent = Img_Bg:FindDirect("Group_Content/Label_Content"):GetComponent("UIInput")
    if inputContent:get_isSelected() then
      local val = inputContent:get_value()
      GangPurposeValidator.Instance():SetCharacterNum(0, GangSignStrEditPanel.StrMax)
      local b, error, len = GangPurposeValidator.Instance():IsValid(val)
      if len > GangSignStrEditPanel.StrMax then
        Toast(string.format(textRes.Gang[95], GangSignStrEditPanel.StrMax))
        local real = GangPurposeValidator.Instance():GetWordMaxVal(val)
        inputContent:set_value(real)
      end
    end
  end
end
def.method().OnConfirmEditSignClick = function(self)
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local inputContent = Img_Bg:FindDirect("Group_Content/Label_Content"):GetComponent("UIInput")
  local content = inputContent:get_value()
  if content == "" then
    content = textRes.Gang[137]
  end
  GangPurposeValidator.Instance():SetCharacterNum(1, GangSignStrEditPanel.StrMax)
  local isValid = GangUtility.ValidEnteredContent(content)
  if false == isValid then
    return
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CChangeSignStrReq").new(content))
  self:Hide()
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Btn_Close" == id then
    self:Hide()
  elseif "Btn_Cancel" == id then
    self:Hide()
  elseif "Btn_Confirm" == id then
    self:OnConfirmEditSignClick()
  elseif "Label_Content" == id then
    self:FocusOnInput(clickobj)
  end
end
return GangSignStrEditPanel.Commit()
