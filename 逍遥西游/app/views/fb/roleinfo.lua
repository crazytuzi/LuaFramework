local roleinfo = class("roleinfo", CcsUIConfigView)
function roleinfo:ctor(param)
  roleinfo.super.ctor(self, "views/fbroleitem.json")
  self.m_Param = param
  local headPos = self:getNode("head")
  local headParent = headPos:getParent()
  local hx, hy = headPos:getPosition()
  local zOrder = headPos:getZOrder()
  local headIcon = createHeadIconByRoleTypeID(param.rTypeID)
  headParent:addNode(headIcon, zOrder + 1)
  headIcon:setPosition(hx, hy + 7)
  self.m_Name = self:getNode("name")
  local rName = getSubNameStrWithObj(self.m_Name, param.rName, 155)
  self.m_Name:setText(rName)
  self.m_Race = self:getNode("race")
  self.m_Race:setText(RACENAME_DICT[param.rRace] or "")
end
function roleinfo:getParam()
  return self.m_Param
end
return roleinfo
