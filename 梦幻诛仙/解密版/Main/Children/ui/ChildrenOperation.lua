local Lplus = require("Lplus")
local SubPanel = require("Main.Children.ui.SubPanel")
local ChildrenOperation = Lplus.Extend(SubPanel, "ChildrenOperation")
local def = ChildrenOperation.define
def.field("userdata").childId = nil
def.static("userdata", "userdata", "=>", ChildrenOperation).CreateNew = function(uiGo, cid)
  local ret = ChildrenOperation()
  ret:Create(uiGo)
  ret:SetChildId(cid)
  ret:Hide()
  return ret
end
def.method("userdata").SetChildId = function(self, cid)
  self.childId = cid
end
def.override().Hide = function(self)
  if self.m_node and not self.m_node.isnil then
    self.m_node:SetActive(false)
  end
end
def.override("table").Show = function(self, data)
  if self.m_node and not self.m_node.isnil then
    self.m_node:SetActive(true)
    self.m_node:FindDirect("Img_Bg2/List_Item/Btn_Operate_3"):SetActive(IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CHILD_FASHION))
  end
end
def.override("string", "=>", "boolean").onClick = function(self, id)
  if self:IsShow() then
    if id == "Btn_Operate_1" then
      require("Main.Children.ChildrenModule").Instance():ChangeChildName(self.childId)
      return true
    elseif id == "Btn_Operate_2" then
      require("Main.Children.ChildrenModule").Instance():ShowChildDiary(self.childId)
      return true
    elseif id == "Btn_Operate_3" then
      require("Main.Children.ChildrenModule").Instance():ShowChildFashion(self.childId)
      return true
    elseif id == "Btn_Operate_4" then
      require("Main.Children.ChildrenInterface").AbandonChildWithConfirm(self.childId)
      return true
    else
      return false
    end
  else
    return false
  end
end
ChildrenOperation.Commit()
return ChildrenOperation
