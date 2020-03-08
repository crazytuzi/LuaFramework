local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ChangeGangNamePanel = Lplus.Extend(ECPanelBase, "ChangeGangNamePanel")
local GangNameValidator = require("Main.Gang.GangNameValidator")
local GangPurposeValidator = require("Main.Gang.GangPurposeValidator")
local def = ChangeGangNamePanel.define
local instance
local GangUtility = require("Main.Gang.GangUtility")
def.field("function").callback = nil
def.field("table").tag = nil
def.field("boolean").bIsName = true
def.static("=>", ChangeGangNamePanel).Instance = function(self)
  if nil == instance then
    instance = ChangeGangNamePanel()
  end
  return instance
end
def.static("function", "table", "boolean").ShowChangeGangNamePanel = function(callback, tag, bIsName)
  ChangeGangNamePanel.Instance().callback = callback
  ChangeGangNamePanel.Instance().tag = tag
  ChangeGangNamePanel.Instance().bIsName = bIsName
  ChangeGangNamePanel.Instance():SetModal(true)
  ChangeGangNamePanel.Instance():CreatePanel(RESPATH.PREFAB_MODIFY_GANG_PANEL, 0)
end
def.override().OnCreate = function(self)
  self:UpdateInfo()
end
def.override().OnDestroy = function(self)
end
def.method().UpdateInfo = function(self)
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local Label_Title = Img_Bg:FindDirect("Img_Title/Label_Title"):GetComponent("UILabel")
  local Label_Content = Img_Bg:FindDirect("Group_Content/Label_Content")
  local Label_Count = Img_Bg:FindDirect("Group_Content/Label_Count"):GetComponent("UILabel")
  local Group_Cost = Img_Bg:FindDirect("Group_Cost")
  if self.bIsName then
    Label_Title:set_text(textRes.Gang[71])
    Label_Content:GetComponent("UILabel"):set_text(textRes.Gang[73])
    local nameMax = GangUtility.GetGangConsts("GANG_NAME_MAX_LENGTH")
    Label_Content:GetComponent("UIInput"):set_characterLimit(0)
    local val = Label_Content:GetComponent("UIInput"):get_value()
    local len = string.len(val)
    Label_Count:set_text(string.format("%d/%d", len, nameMax))
    Group_Cost:SetActive(true)
    local Label_CostNum = Group_Cost:FindDirect("Label_CostNum"):GetComponent("UILabel")
    local cost = GangUtility.GetGangConsts("MODIFY_NAME_NEED_YUANBAO")
    Label_CostNum:set_text(cost)
  else
    Label_Title:set_text(textRes.Gang[72])
    Label_Content:GetComponent("UILabel"):set_text(textRes.Gang[74])
    local contentMax = GangUtility.GetGangConsts("GANG_PURPOSE_MAX_LENGTH")
    Label_Content:GetComponent("UIInput"):set_characterLimit(0)
    local GangData = require("Main.Gang.data.GangData")
    local curGangPurpose = GangData.Instance():GetGangPurpose()
    Label_Content:GetComponent("UIInput"):set_value(curGangPurpose)
    GangPurposeValidator.Instance():SetCharacterNum(1, contentMax)
    local b, tmp, len = GangPurposeValidator.Instance():IsValid(curGangPurpose)
    Label_Count:set_text(string.format("%d/%d", len, contentMax))
    Group_Cost:SetActive(false)
  end
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
      local Label_Count = Img_Bg:FindDirect("Group_Content/Label_Count"):GetComponent("UILabel")
      local val = inputContent:get_value()
      local contentMax = GangUtility.GetGangConsts("GANG_PURPOSE_MAX_LENGTH")
      local b, tmp, len = false, 0, 0
      if self.bIsName then
        contentMax = GangUtility.GetGangConsts("GANG_NAME_MAX_LENGTH")
        GangNameValidator.Instance():SetCharacterNum(1, contentMax)
        b, tmp, len = GangNameValidator.Instance():IsValid(val)
      else
        GangPurposeValidator.Instance():SetCharacterNum(1, contentMax)
        b, tmp, len = GangPurposeValidator.Instance():IsValid(val)
      end
      if contentMax < len then
        Toast(string.format(textRes.Gang[95], contentMax))
        if self.bIsName then
          local real = GangNameValidator.Instance():GetWordMaxVal(val)
          inputContent:set_value(real)
        else
          local real = GangPurposeValidator.Instance():GetWordMaxVal(val)
          inputContent:set_value(real)
        end
      else
        Label_Count:set_text(string.format("%d/%d", len, contentMax))
      end
    end
  end
end
def.static("number", "table").BuyYuanbaoCallback = function(i, tag)
  if i == 1 then
    local dlg = tag.id
  end
end
def.static("number", "table").SureToModifyCallback = function(i, tag)
  if i == 1 then
    local self = tag.id
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CRenameReq").new(tag.content))
    if self.callback then
      self.callback(self.tag)
    end
    self:Hide()
  end
end
def.method().OnModifyGangClick = function(self)
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local inputContent = Img_Bg:FindDirect("Group_Content/Label_Content"):GetComponent("UIInput")
  local content = inputContent:get_value()
  if content == "" then
    if self.bIsName then
      Toast(textRes.Gang[54])
    else
      Toast(textRes.Gang[55])
    end
    return
  end
  local contentMax = GangUtility.GetGangConsts("GANG_PURPOSE_MAX_LENGTH")
  local isValid = true
  if self.bIsName then
    contentMax = GangUtility.GetGangConsts("GANG_NAME_MAX_LENGTH")
    GangNameValidator.Instance():SetCharacterNum(1, contentMax)
    isValid = GangUtility.ValidEnteredName(content)
  else
    GangPurposeValidator.Instance():SetCharacterNum(1, contentMax)
    isValid = GangUtility.ValidEnteredContent(content)
  end
  if false == isValid then
    return
  end
  if self.bIsName then
    local ItemModule = require("Main.Item.ItemModule")
    local yuanbao = ItemModule.Instance():GetAllYuanBao()
    local cost = GangUtility.GetGangConsts("MODIFY_NAME_NEED_YUANBAO")
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    if Int64.lt(yuanbao, cost) then
      Toast(textRes.Gang[58])
      local tag = {id = self}
      CommonConfirmDlg.ShowConfirm("", textRes.Gang[59], ChangeGangNamePanel.BuyYuanbaoCallback, tag)
      return
    end
    local tag = {id = self, content = content}
    CommonConfirmDlg.ShowConfirm("", string.format(textRes.Gang[149], cost, content), ChangeGangNamePanel.SureToModifyCallback, tag)
  else
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CGangPurposeModifyReq").new(content))
    if self.callback then
      self.callback(self.tag)
    end
    self:Hide()
  end
end
def.method().Hide = function(self)
  self:DestroyPanel()
  self = nil
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Label_Content" == id then
    self:FocusOnInput(clickobj)
  elseif "Btn_Close" == id then
    self:Hide()
  elseif "Modal" == id then
    self:Hide()
  elseif "Btn_Cancel" == id then
    self:Hide()
  elseif "Btn_Modify" == id then
    self:OnModifyGangClick()
  end
end
return ChangeGangNamePanel.Commit()
