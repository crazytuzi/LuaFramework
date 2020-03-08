local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SelectIconDlg = Lplus.Extend(ECPanelBase, "SelectIconDlg")
local GUIUtils = require("GUI.GUIUtils")
local def = SelectIconDlg.define
def.field("table").icons = nil
def.field("table").grays = nil
def.field("number").select = 0
def.field("function").callback = nil
def.static("table", "table", "function").ShowSelectIcon = function(icons, grays, cb)
  local dlg = SelectIconDlg()
  dlg.icons = icons
  dlg.grays = grays
  dlg.callback = cb
  dlg:CreatePanel(RESPATH.PREFAB_SELECT_ICON, 2)
  dlg:SetModal(true)
end
def.override().OnCreate = function(self)
  local scroll = self.m_panel:FindDirect("Img_Bg/Group_SignList/ScrollView_List")
  local list = scroll:FindDirect("List")
  local listCmp = list:GetComponent("UIList")
  local count = #self.icons
  listCmp:set_itemCount(count)
  listCmp:Resize()
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local icon = self.icons[i]
    local uiTex = uiGo:FindDirect(string.format("Img_Icon_%d", i)):GetComponent("UITexture")
    GUIUtils.FillIcon(uiTex, icon)
    uiGo:FindDirect(string.format("Img_Use_%d", i)):SetActive(self.grays[icon] and true or false)
    self.m_msgHandler:Touch(uiGo)
  end
end
def.override().OnDestroy = function(self)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Confirm" then
    self:DestroyPanel()
    if self.select > 0 and self.callback then
      self.callback(self.select)
    else
    end
  elseif id == "Btn_Close" then
    self:DestroyPanel()
  elseif string.sub(id, 1, 10) == "Item_Sign_" then
    local index = tonumber(string.sub(id, 11))
    if index then
      self.select = index
    end
  end
end
return SelectIconDlg.Commit()
