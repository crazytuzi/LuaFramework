local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ChangeTextDlg = Lplus.Extend(ECPanelBase, "ChangeTextDlg")
local def = ChangeTextDlg.define
local instance
def.field("string").title = ""
def.field("string").initContent = ""
def.field("string").defaultContent = ""
def.field("number").limit = 0
def.field("function").callback = nil
def.field("userdata").input = nil
def.field("userdata").label = nil
def.static("string", "string", "string", "number", "function").ShowChangeTextDlg = function(title, initContent, default, limit, cb)
  local dlg = ChangeTextDlg()
  dlg.title = title
  dlg.initContent = initContent
  dlg.defaultContent = default
  dlg.limit = limit
  dlg.callback = cb
  dlg:CreatePanel(RESPATH.PREFAB_MODIFY_GANG_PANEL, 2)
  dlg:SetModal(true)
end
def.override().OnCreate = function(self)
  self.input = self.m_panel:FindDirect("Img_Bg/Group_Content/Label_Content"):GetComponent("UIInput")
  self.input:set_defaultText(self.defaultContent)
  self.label = self.m_panel:FindDirect("Img_Bg/Group_Content/Label_Count"):GetComponent("UILabel")
  self:UpdateInfo()
end
def.override().OnDestroy = function(self)
end
def.method().UpdateInfo = function(self)
  self.input:set_value(self.initContent)
  local titleLbl = self.m_panel:FindDirect("Img_Bg/Img_Title/Label_Title")
  titleLbl:GetComponent("UILabel"):set_text(self.title)
  self:UpdateCount()
end
def.method().UpdateCount = function(self)
  local content = self.input:get_value()
  local len, clen, hlen = Strlen(content)
  local showLen = math.ceil(clen / 2 + hlen)
  if showLen <= self.limit then
    self.label:set_text(string.format("%d/%d", showLen, self.limit))
  else
    self.label:set_text(string.format("[ff0000]%d/%d[-]", showLen, self.limit))
  end
end
def.method("string", "string").onTextChange = function(self, id, val)
  if id == "Label_Content" then
    self:UpdateCount()
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Cancel" or id == "Btn_Close" then
    self:DestroyPanel()
  else
    if id == "Btn_Modify" then
      local content = self.input:get_value()
      local len, clen, hlen = Strlen(content)
      local showLen = clen / 2 + hlen
      if showLen <= self.limit and content ~= self.initContent and self.callback and self.callback(content) then
        self:DestroyPanel()
      end
    else
    end
  end
end
return ChangeTextDlg.Commit()
