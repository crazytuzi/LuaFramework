local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ConditionShow = Lplus.Extend(ECPanelBase, "ConditionShow")
local def = ConditionShow.define
def.field("table").conditions = nil
def.field("function").callback = nil
def.static("table", "function").ShowCondition = function(conditions, cb)
  local dlg = ConditionShow()
  dlg.conditions = conditions
  dlg.callback = cb
  dlg:CreatePanel(RESPATH.PREFAB_CONDITION, 1)
  dlg:SetModal(true)
end
def.override().OnCreate = function(self)
  local scroll = self.m_panel:FindDirect("Img_Bg/Group_Center/Group_List/Scroll View")
  local list = scroll:FindDirect("List_Member")
  local listCmp = list:GetComponent("UIList")
  local count = #self.conditions
  listCmp:set_itemCount(count)
  listCmp:Resize()
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local condition = self.conditions[i]
    self:FillCondition(uiGo, condition.desc, condition.meet)
    self.m_msgHandler:Touch(uiGo)
  end
  local fail = false
  for k, v in ipairs(self.conditions) do
    if v.meet == false then
      fail = true
    end
  end
  if fail then
    local createBtn = self.m_panel:FindDirect("Img_Bg/Group_Bottom/Btn_Creat")
    createBtn:GetComponent("UIButton"):set_isEnabled(false)
  end
end
def.method("userdata", "string", "boolean").FillCondition = function(self, uiGo, desc, meet)
  local descLbl = uiGo:FindDirect("Label_TermName")
  descLbl:GetComponent("UILabel"):set_text(desc)
  local right = uiGo:FindDirect("Group_Result/Img_Right")
  local wrong = uiGo:FindDirect("Group_Result/Img_Wrong")
  right:SetActive(meet)
  wrong:SetActive(not meet)
end
def.override().OnDestroy = function(self)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Creat" then
    for k, v in ipairs(self.conditions) do
      if v.meet == false then
        Toast(textRes.Corps[62])
        return
      end
    end
    self:DestroyPanel()
    if self.callback then
      self.callback(true)
    end
  elseif id == "Btn_Quit" then
    self:DestroyPanel()
    if self.callback then
      self.callback(false)
    end
  end
end
return ConditionShow.Commit()
