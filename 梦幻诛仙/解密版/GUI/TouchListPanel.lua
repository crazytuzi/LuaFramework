local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TouchListPanel = Lplus.Extend(ECPanelBase, "TouchListPanel")
local def = TouchListPanel.define
def.field("table").m_listdata = nil
def.field("table").m_uiObjs = nil
def.field("function").onSelectCallback = nil
local instance
def.static("=>", TouchListPanel).Instance = function()
  if nil == instance then
    instance = TouchListPanel()
  end
  return instance
end
def.method("table", "function").ShowPanel = function(self, list, onSelectCallback)
  self.m_listdata = list
  self.onSelectCallback = onSelectCallback
  if self:IsShow() then
    self:UpdateUI()
    return
  end
  self:CreatePanel(RESPATH.PREFAB_TOUCH_LIST_PANEL, 2)
  self:SetOutTouchDisappear()
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
end
def.method().InitUI = function(self)
  self.m_uiObjs = {}
  self.m_uiObjs.listPanel = self.m_panel:FindDirect("Scrollview_MP/List_MP")
end
def.method().UpdateUI = function(self)
  if self.m_uiObjs == nil or self.m_listdata == nil then
    return
  end
  local uilist = self.m_uiObjs.listPanel:GetComponent("UIList")
  local count = #self.m_listdata
  uilist.itemCount = count
  uilist:Resize()
  for i = 1, count do
    local p = self.m_uiObjs.listPanel:FindDirect(string.format("Btn_Name_%d/Label_Name_%d", i, i))
    if self.m_listdata[i]:tryget("GetName") then
      p:GetComponent("UILabel").text = self.m_listdata[i]:GetName()
    else
      p:GetComponent("UILabel").text = ""
    end
  end
end
def.method("string").onClick = function(self, id)
  if string.find(id, "Btn_Name_") then
    local idx = tonumber(string.sub(id, #"Btn_Name_" + 1, -1))
    if self.onSelectCallback then
      local cb = self.onSelectCallback
      local target = self.m_listdata[idx]
      self:DestroyPanel()
      self.onSelectCallback = nil
      cb(target)
    end
  elseif id == "Btn_Close" then
    self:DestroyPanel()
  end
end
def.method().HidePanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
end
def.override().OnDestroy = function(self)
  self.m_listdata = nil
  self.m_uiObjs = nil
end
TouchListPanel.Commit()
return TouchListPanel
