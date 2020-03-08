local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BlessDlg = Lplus.Extend(ECPanelBase, "BlessDlg")
local GUIUtils = require("GUI.GUIUtils")
local def = BlessDlg.define
local _instance
def.static("=>", "table").Instance = function()
  if _instance == nil then
    _instance = BlessDlg()
  end
  return _instance
end
def.field("string").title = ""
def.field("string").desc = ""
def.field("string").prefix = ""
def.field("table").content1 = nil
def.field("table").content2 = nil
def.field("function").callback = nil
def.field("number").select = 0
def.static("string", "string", "string", "table", "table", "function").ShowBlessDlg = function(title, desc, prefix, names, presets, cb)
  local dlg = BlessDlg.Instance()
  if dlg.m_created then
    dlg:DestroyPanel()
  end
  dlg.title = title
  dlg.desc = desc
  dlg.prefix = prefix
  dlg.content1 = names
  dlg.content2 = presets
  dlg.callback = cb
  dlg:CreatePanel(RESPATH.PREFAB_BLESS, 2)
end
def.override().OnCreate = function(self)
  self:UpdateText()
  self:SetPopup()
end
def.override().OnDestroy = function(self)
end
def.method().UpdateText = function(self)
  local title = self.m_panel:FindDirect("Img_0/Label_Title")
  local titleLbl = title:GetComponent("UILabel")
  titleLbl:set_text(self.title)
  local desc = self.m_panel:FindDirect("Img_0/Label_Desc")
  local descLbl = desc:GetComponent("UILabel")
  descLbl:set_text(self.desc)
  local prefix = self.m_panel:FindDirect("Img_0/Label_Prefix")
  local prefixLbl = prefix:GetComponent("UILabel")
  prefixLbl:set_text(self.prefix)
  self:SetContent1("")
  self:SetContent2("")
end
def.method().SetPopup = function(self)
  local pop1 = self.m_panel:FindDirect("Img_0/Img_Popup")
  local pop1Cmp = pop1:GetComponent("UIPopupList")
  local r = math.random(#self.content1)
  pop1Cmp:set_items(self.content1)
  pop1Cmp.selectIndex = r - 1
  pop1Cmp.value = self.content1[r]
  self.select = r
  warn("SetPopup:", self.select)
  local pop2 = self.m_panel:FindDirect("Img_0/Img_Preset")
  local pop2Cmp = pop2:GetComponent("UIPopupList")
  r = math.random(#self.content2)
  pop2Cmp:set_items(self.content2)
  pop2Cmp.selectIndex = r - 1
  pop2Cmp.value = self.content2[r]
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Confirm" and self:DoCallback() then
    self:DestroyPanel()
  end
end
def.method("string").SetContent1 = function(self, cnt)
  local cnt1 = self.m_panel:FindDirect("Img_0/Img_Popup/Label_Input")
  local cnt1Cmp = cnt1:GetComponent("UILabel")
  cnt1Cmp:set_text(cnt)
end
def.method("string").SetContent2 = function(self, cnt)
  local cnt2 = self.m_panel:FindDirect("Img_0/Img_Preset/Label_Input")
  local cnt2Cmp = cnt2:GetComponent("UILabel")
  cnt2Cmp:set_text(cnt)
end
def.method("string", "string", "number").onSelect = function(self, id, selected, index)
  if "Img_Popup" == id and index ~= -1 then
    local text = self.content1[index + 1]
    self:SetContent1(text)
    self.select = index + 1
  elseif "Img_Preset" == id and index ~= -1 then
    local text = self.content2[index + 1]
    self:SetContent2(text)
  end
end
def.method("=>", "boolean").DoCallback = function(self)
  if self.callback then
    local cnt1 = self.m_panel:FindDirect("Img_0/Img_Popup/Label_Input")
    local cnt1Cmp = cnt1:GetComponent("UILabel")
    local cnt2 = self.m_panel:FindDirect("Img_0/Img_Preset/Label_Input")
    local cnt2Cmp = cnt2:GetComponent("UILabel")
    local text1 = cnt1Cmp:get_text()
    local text2 = cnt2Cmp:get_text()
    if #text1 > 0 and #text2 > 0 then
      local ret = self.prefix .. text1 .. text2
      self.callback(ret, self.select)
      return true
    else
      Toast(textRes.Marriage[95])
      return false
    end
  else
    return true
  end
end
BlessDlg.Commit()
return BlessDlg
