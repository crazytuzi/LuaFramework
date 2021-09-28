selectPetItem = class("selectPetItem", CcsSubView)
function selectPetItem:ctor(petId)
  selectPetItem.super.ctor(self, "views/select_pet_item.json")
  self.m_PetId = petId
  self.m_PetObj = g_LocalPlayer:getObjById(petId)
  local name = self.m_PetObj:getProperty(PROPERTY_NAME)
  self:getNode("petName"):setText(name)
  local lv = self.m_PetObj:getProperty(PROPERTY_ROLELEVEL)
  local zhuan = self.m_PetObj:getProperty(PROPERTY_ZHUANSHENG)
  self:getNode("petLV"):setText(string.format("%d转%d", zhuan, lv))
  local color = NameColor_Pet[zhuan]
  if color == nil then
    color = ccc3(255, 255, 255)
  end
  self:getNode("petName"):setColor(color)
  local typeId = self.m_PetObj:getTypeId()
  local grayFlag = false
  if g_WarScene and (g_WarScene:petIsDead(petId) or g_WarScene:petIsHasInWar(petId)) then
    grayFlag = true
  end
  local tempImg = createHeadIconByRoleTypeID(typeId, self:getNode("petImg"):getContentSize(), grayFlag)
  tempImg:setAnchorPoint(ccp(0.5, 0))
  local x, y = self:getNode("petImg"):getPosition()
  local size = self:getNode("petImg"):getContentSize()
  local z = self:getNode("petImg"):getZOrder()
  tempImg:setPosition(ccp(x, y - size.height / 2 + 8))
  self.m_UINode:addNode(tempImg, z + 1)
end
function selectPetItem:getPetID()
  return self.m_PetId
end
function selectPetItem:Clear()
  self.m_PetObj = nil
end
return selectPetItem
