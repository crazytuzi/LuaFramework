local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECGUIMan = require("GUI.ECGUIMan")
local ScrollButtonGroupPanel = Lplus.Extend(ECPanelBase, "ScrollButtonGroupPanel")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local def = ScrollButtonGroupPanel.define
def.field("table").m_btns = nil
def.field("function").m_callback = nil
def.field("table").m_pos = nil
def.static("table", "table", "function", "=>", ScrollButtonGroupPanel).ShowPanel = function(btns, pos, callback)
  if btns == nil or pos == nil then
    return
  end
  local self = ScrollButtonGroupPanel()
  self.m_btns = btns
  self.m_pos = pos
  self.m_callback = callback
  self:CreatePanel(RESPATH.PREFAB_SCROLL_BTN_LIST, 2)
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
  self.m_pos = nil
end
def.method().InitUI = function(self)
  local list = self.m_panel:FindDirect("Img_Bg/Scroll View/List_Item")
  local listCmp = list:GetComponent("UIScrollList")
  local GUIScrollList = list:GetComponent("GUIScrollList")
  if GUIScrollList == nil then
    list:AddComponent("GUIScrollList")
  end
  ScrollList_setUpdateFunc(listCmp, function(item, i)
    self:FillItemInfo(item, i)
  end)
end
def.method().UpdateUI = function(self)
  self:UpdatePos()
  self:UpdateList()
end
def.method().UpdateList = function(self)
  local list = self.m_panel:FindDirect("Img_Bg/Scroll View/List_Item")
  local listCmp = list:GetComponent("UIScrollList")
  ScrollList_setCount(listCmp, #self.m_btns)
end
def.method("userdata", "number").FillItemInfo = function(self, item, index)
  local info = self.m_btns[index]
  if info then
    item:FindDirect("Label_Name"):GetComponent("UILabel"):set_text(info.name)
  end
end
def.method().UpdatePos = function(self)
  local pos = self.m_pos
  if pos == nil then
    return
  end
  local tipFrame = self.m_panel:FindDirect("Img_Bg")
  if pos.auto then
    local tipWidth = tipFrame:GetComponent("UISprite"):get_width()
    local tipHeight = tipFrame:GetComponent("UISprite"):get_height()
    local targetX, targetY = require("Common.MathHelper").ComputeTipsAutoPosition(pos.sourceX, pos.sourceY, pos.sourceW, pos.sourceH, tipWidth, tipHeight, pos.prefer, 1)
    targetY = targetY + tipHeight / 2
    tipFrame:set_localPosition(Vector.Vector3.new(targetX, targetY, 0))
  elseif pos then
    tipFrame:set_localPosition(Vector.Vector3.new(pos.x, pos.y, 0))
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if id == "Btn_Item" then
    local item, idx = ScrollList_getItem(clickobj)
    if item then
      local btnInfo = self.m_btns[idx]
      if btnInfo and self.m_callback then
        self.m_callback(idx, btnInfo.tag)
      end
    end
    self:DestroyPanel()
  end
end
return ScrollButtonGroupPanel.Commit()
