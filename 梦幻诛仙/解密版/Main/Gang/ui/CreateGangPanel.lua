local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CreateGangPanel = Lplus.Extend(ECPanelBase, "CreateGangPanel")
local GangNameValidator = require("Main.Gang.GangNameValidator")
local GangPurposeValidator = require("Main.Gang.GangPurposeValidator")
local def = CreateGangPanel.define
local instance
local GangUtility = require("Main.Gang.GangUtility")
def.field("function").callback = nil
def.field("table").tag = nil
def.static("=>", CreateGangPanel).Instance = function(self)
  if nil == instance then
    instance = CreateGangPanel()
  end
  return instance
end
def.static("function", "table").ShowCreateGangPanel = function(callback, tag)
  CreateGangPanel.Instance().callback = callback
  CreateGangPanel.Instance().tag = tag
  CreateGangPanel.Instance():SetModal(true)
  CreateGangPanel.Instance():CreatePanel(RESPATH.PREFAB_CREATE_GANG_PANEL, 1)
end
def.override().OnCreate = function(self)
  self:UpdateInfo()
end
def.override().OnDestroy = function(self)
end
def.method().UpdateInfo = function(self)
  local inputName = self.m_panel:FindDirect("Img_Bg/Group_Name/Group_NameContent"):FindDirect("Label_NameContent"):GetComponent("UIInput")
  local nameMax = GangUtility.GetGangConsts("GANG_NAME_MAX_LENGTH")
  inputName:set_characterLimit(0)
  local inputNameCount = self.m_panel:FindDirect("Img_Bg/Group_Name/Group_NameContent"):FindDirect("Label_NameCount"):GetComponent("UILabel")
  local val1 = inputName:get_value()
  local len1 = string.len(val1)
  inputNameCount:set_text(string.format("%d/%d", len1, nameMax))
  local inputContent = self.m_panel:FindDirect("Img_Bg/Group_Target/Group_TargetContent"):FindDirect("Label_TargetContent"):GetComponent("UIInput")
  local contentMax = GangUtility.GetGangConsts("GANG_PURPOSE_MAX_LENGTH")
  inputContent:set_characterLimit(0)
  local inputContentCount = self.m_panel:FindDirect("Img_Bg/Group_Target/Group_TargetContent"):FindDirect("Label_TargetCount"):GetComponent("UILabel")
  local val2 = inputContent:get_value()
  local len2 = string.len(val2)
  inputContentCount:set_text(string.format("%d/%d", len2, contentMax))
  local yuanbao = self.m_panel:FindDirect("Img_Bg/Group_Create/Label3"):GetComponent("UILabel")
  local cost = GangUtility.GetGangConsts("CREATE_NEED_YUANBAO")
  yuanbao:set_text(cost)
end
def.method("userdata").FocusOnInput = function(self, clickobj)
  local input = clickobj:GetComponent("UIInput")
  input:set_isSelected(true)
end
def.method("string", "string").onTextChange = function(self, id, val)
  local inputName = self.m_panel:FindDirect("Img_Bg/Group_Name/Group_NameContent"):FindDirect("Label_NameContent"):GetComponent("UIInput")
  local inputContent = self.m_panel:FindDirect("Img_Bg/Group_Target/Group_TargetContent"):FindDirect("Label_TargetContent"):GetComponent("UIInput")
  if inputName:get_isSelected() then
    local inputNameCount = self.m_panel:FindDirect("Img_Bg/Group_Name/Group_NameContent"):FindDirect("Label_NameCount"):GetComponent("UILabel")
    local val = inputName:get_value()
    local nameMax = GangUtility.GetGangConsts("GANG_NAME_MAX_LENGTH")
    GangNameValidator.Instance():SetCharacterNum(1, nameMax)
    local b, _, len = GangNameValidator.Instance():IsValid(val)
    if nameMax < len then
      Toast(string.format(textRes.Gang[95], nameMax))
      local real = GangNameValidator.Instance():GetWordMaxVal(val)
      inputName:set_value(real)
    else
      inputNameCount:set_text(string.format("%d/%d", len, nameMax))
    end
  elseif inputContent:get_isSelected() then
    local inputContentCount = self.m_panel:FindDirect("Img_Bg/Group_Target/Group_TargetContent"):FindDirect("Label_TargetCount"):GetComponent("UILabel")
    local val = inputContent:get_value()
    local contentMax = GangUtility.GetGangConsts("GANG_PURPOSE_MAX_LENGTH")
    GangPurposeValidator.Instance():SetCharacterNum(1, contentMax)
    local b, _, len = GangPurposeValidator.Instance():IsValid(val)
    if contentMax < len then
      Toast(string.format(textRes.Gang[95], contentMax))
      local real = GangPurposeValidator.Instance():GetWordMaxVal(val)
      inputContent:set_value(real)
    else
      inputContentCount:set_text(string.format("%d/%d", len, contentMax))
    end
  end
end
def.static("number", "table").BuyYuanbaoCallback = function(i, tag)
  if i == 1 then
    local self = tag.id
    local MallPanel = require("Main.Mall.ui.MallPanel")
    require("Main.Mall.MallModule").RequireToShowMallPanel(MallPanel.StateConst.Pay, 0, 0)
  end
end
def.static("number", "table").SureToCreateCallback = function(i, tag)
  if i == 1 then
    local self = tag.id
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CCreateGangReq").new(tag.name, tag.content))
    if self.callback then
      self.callback(self.tag)
    end
    self:Hide()
  end
end
def.method().OnCreateGangClick = function(self)
  local inputName = self.m_panel:FindDirect("Img_Bg/Group_Name/Group_NameContent"):FindDirect("Label_NameContent"):GetComponent("UIInput")
  local inputContent = self.m_panel:FindDirect("Img_Bg/Group_Target/Group_TargetContent"):FindDirect("Label_TargetContent"):GetComponent("UIInput")
  local name = inputName:get_value()
  local content = inputContent:get_value()
  if name == "" then
    Toast(textRes.Gang[54])
    return
  end
  if content == "" then
    Toast(textRes.Gang[55])
    return
  end
  local nameMax = GangUtility.GetGangConsts("GANG_NAME_MAX_LENGTH")
  GangNameValidator.Instance():SetCharacterNum(1, nameMax)
  local isValid = GangUtility.ValidEnteredName(name)
  if false == isValid then
    return
  end
  local contentMax = GangUtility.GetGangConsts("GANG_PURPOSE_MAX_LENGTH")
  GangPurposeValidator.Instance():SetCharacterNum(1, contentMax)
  isValid = GangUtility.ValidEnteredContent(content)
  if false == isValid then
    return
  end
  local ItemModule = require("Main.Item.ItemModule")
  local yuanbao = ItemModule.Instance():GetAllYuanBao()
  local cost = GangUtility.GetGangConsts("CREATE_NEED_YUANBAO")
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  if Int64.lt(yuanbao, cost) then
    local tag = {id = self}
    CommonConfirmDlg.ShowConfirm("", textRes.Gang[59], CreateGangPanel.BuyYuanbaoCallback, tag)
    return
  end
  local tag = {
    id = self,
    name = name,
    content = content
  }
  CommonConfirmDlg.ShowConfirm("", string.format(textRes.Gang[60], cost, name), CreateGangPanel.SureToCreateCallback, tag)
end
def.method().Hide = function(self)
  self:DestroyPanel()
  self = nil
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Label_NameContent" == id then
    self:FocusOnInput(clickobj)
  elseif "Label_TargetContent" == id then
    self:FocusOnInput(clickobj)
  elseif "Btn_Close" == id then
    self:Hide()
  elseif "Modal" == id then
    self:Hide()
  elseif "Btn_Cancel" == id then
    self:Hide()
  elseif "Btn_Create" == id then
    self:OnCreateGangClick()
  end
end
return CreateGangPanel.Commit()
