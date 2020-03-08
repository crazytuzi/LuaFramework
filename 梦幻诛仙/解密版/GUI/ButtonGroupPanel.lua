local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECGUIMan = require("GUI.ECGUIMan")
local ButtonGroupPanel = Lplus.Extend(ECPanelBase, "ButtonGroupPanel")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local def = ButtonGroupPanel.define
def.field("table").m_uiGOs = nil
def.field("table").m_btns = nil
def.field("function").m_callback = nil
def.field("table").m_pos = nil
def.field("string").m_title = ""
def.static("table", "table", "function", "=>", ButtonGroupPanel).ShowPanel = function(btns, pos, callback)
  local self = ButtonGroupPanel()
  self.m_btns = btns
  self.m_pos = pos
  self.m_callback = callback
  self.m_title = ""
  self:CreatePanel(RESPATH.PREFAB_BUTTON_GROUP_PANEL, 2)
  self:SetOutTouchDisappear()
  return self
end
def.static("table", "string", "table", "function", "=>", ButtonGroupPanel).ShowPanelWithTitle = function(btns, title, pos, callback)
  local self = ButtonGroupPanel()
  self.m_btns = btns
  self.m_title = title
  self.m_pos = pos
  self.m_callback = callback
  self:CreatePanel(RESPATH.PREFAB_BUTTON_GROUP_TITLE_PANEL, 2)
  self:SetOutTouchDisappear()
  return self
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self.m_btns = nil
  self.m_callback = nil
end
def.method().InitUI = function(self)
  self.m_uiGOs = {}
  self.m_uiGOs.Table_Btn = self.m_panel:FindDirect("List_Btn")
  self.m_uiGOs.Btn_Template = self.m_uiGOs.Table_Btn:FindDirect("Btn_Common")
  GUIUtils.SetActive(self.m_uiGOs.Btn_Template, false)
  local uiTable = self.m_uiGOs.Table_Btn:GetComponent("UITableResizeBackground")
  uiTable.hideInactive = true
end
def.method().UpdateUI = function(self)
  self:UpdateBtns()
  self:UpdatePos()
  self:UpdateTitle()
end
def.method().UpdateTitle = function(self)
  local titleLbl = self.m_panel:FindDirect("List_Btn/Label")
  if titleLbl then
    GUIUtils.SetText(titleLbl, self.m_title)
  end
end
def.method().UpdateBtns = function(self)
  local btnNum = #self.m_btns
  for i = 1, btnNum do
    local btnInfo = self.m_btns[i]
    self:SetBtnInfo(i, btnInfo)
  end
  self.m_msgHandler:Touch(self.m_uiGOs.Btn_Template)
  local uiTable = self.m_uiGOs.Table_Btn:GetComponent("UITableResizeBackground")
  uiTable:Reposition()
end
def.method("number", "table").SetBtnInfo = function(self, index, btnInfo)
  local btnGO = self.m_uiGOs.Table_Btn:FindDirect("Btn_" .. index)
  if btnGO == nil then
    btnGO = GameObject.Instantiate(self.m_uiGOs.Btn_Template)
    btnGO:SetActive(true)
    btnGO.name = "Btn_" .. index
    btnGO.parent = self.m_uiGOs.Table_Btn
    btnGO.localScale = Vector.Vector3.one
    btnGO.localPosition = Vector.Vector3.zero
  end
  local Label_BtnName = btnGO:FindDirect("Label_BtnName")
  GUIUtils.SetText(Label_BtnName, btnInfo.name)
end
def.method("table").SetPos = function(self, pos)
  self.m_pos = pos
  if self.m_panel then
    self:UpdatePos()
  end
end
def.method().UpdatePos = function(self)
  local pos = self.m_pos
  if pos == nil then
    return
  end
  if pos.auto then
    local tipFrame = self.m_uiGOs.Table_Btn
    local tipWidth = tipFrame:GetComponent("UISprite"):get_width()
    local tipHeight = tipFrame:GetComponent("UISprite"):get_height()
    local targetX, targetY = require("Common.MathHelper").ComputeTipsAutoPosition(pos.sourceX, pos.sourceY, pos.sourceW, pos.sourceH, tipWidth, tipHeight, pos.prefer, 1)
    targetY = targetY + tipHeight / 2
    tipFrame:set_localPosition(Vector.Vector3.new(targetX, targetY, 0))
  elseif pos then
    self.m_uiGOs.Table_Btn.localPosition = Vector.Vector3.new(pos.x, pos.y, 0)
  end
end
def.method("string").onClick = function(self, id)
  if string.find(id, "Btn_") then
    local index = tonumber(string.sub(id, #"Btn_" + 1, -1))
    if index and self.m_callback then
      local close = self.m_callback(index)
      if close then
        self:DestroyPanel()
      end
    end
  end
end
return ButtonGroupPanel.Commit()
