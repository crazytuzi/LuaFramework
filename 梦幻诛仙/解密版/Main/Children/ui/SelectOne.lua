local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SelectOne = Lplus.Extend(ECPanelBase, "SelectOne")
local def = SelectOne.define
def.field("string").title = ""
def.field("table").selections = nil
def.field("function").callback = nil
def.static("string", "table", "function").ShowSelectOne = function(title, selections, cb)
  if selections == nil then
    return
  end
  local dlg = SelectOne()
  dlg.title = title
  dlg.selections = selections
  dlg.callback = cb
  if not dlg:IsShow() then
    dlg:CreatePanel(RESPATH.PREFAB_TEEN_SELECT, 2)
  else
    dlg:UpdateUI()
  end
end
def.override().OnCreate = function(self)
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
end
def.method().UpdateUI = function(self)
  self:UpdateTitle()
  self:UpdateBtns()
end
def.method().UpdateTitle = function(self)
  local titleLbl = self.m_panel:FindDirect("Img_Bg0/Label_Info")
  titleLbl:GetComponent("UILabel"):set_text(self.title)
end
def.method().UpdateBtns = function(self)
  local count = #self.selections
  local list = self.m_panel:FindDirect("Img_Bg0/Group_List")
  local listCmp = list:GetComponent("UIList")
  listCmp:set_itemCount(count)
  listCmp:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not listCmp.isnil then
      listCmp:Reposition()
    end
  end)
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local name = self.selections[i]
    uiGo:FindDirect("Label"):GetComponent("UILabel"):set_text(name)
    self.m_msgHandler:Touch(uiGo)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif string.sub(id, 1, 5) == "item_" then
    local index = tonumber(string.sub(id, 6))
    self:DestroyPanel()
    if self.callback then
      self.callback(index)
    end
  end
end
return SelectOne.Commit()
