selectDrugItem = class("selectDrugItem", CcsSubView)
function selectDrugItem:ctor(drugShape, drugNum)
  selectDrugItem.super.ctor(self, "views/select_drug_item.json")
  self.m_DrugShape = drugShape
  self.m_DrugNum = drugNum
  local shapeID = data_getItemShapeID(drugShape)
  local path = data_getItemPathByShape(shapeID)
  local tempImg = display.newSprite(path)
  local x, y = self:getNode("drugImg"):getPosition()
  local z = self:getNode("drugImg"):getZOrder()
  local size = self:getNode("drugImg"):getSize()
  local itemBg = display.newSprite("xiyou/item/itembg.png")
  tempImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  itemBg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self.m_UINode:addNode(itemBg, z)
  self.m_UINode:addNode(tempImg, z)
  local name = data_getItemName(drugShape)
  self:getNode("drugName"):setText(name)
  local itemPj = data_getItemPinjie(drugShape)
  local color = NameColor_Item[itemPj] or NameColor_Item[0]
  self:getNode("drugName"):setColor(color)
  local num = drugNum
  local numLabel = CCLabelTTF:create(string.format("%s", num), ITEM_NUM_FONT, 22)
  numLabel:setAnchorPoint(ccp(1, 0))
  numLabel:setPosition(ccp(x + size.width - 14, y + 14))
  numLabel:setColor(ccc3(255, 255, 255))
  AutoLimitObjSize(numLabel, 70)
  self.m_UINode:addNode(numLabel, 10)
  local desc = data_getItemDes(drugShape)
  if data_LifeSkill_Drug[drugShape] ~= nil then
    local drugData = data_LifeSkill_Drug[drugShape]
    local addHPValue = drugData.AddHp or 0
    local addMPValue = drugData.AddMp or 0
    if addHPValue == 0 then
      desc = string.format("法力+%d", addMPValue)
    elseif addMPValue == 0 then
      desc = string.format("气血+%d", addHPValue)
    else
      desc = string.format("气血+%d\n法力+%d", addHPValue, addMPValue)
    end
  end
  local x, y = self:getNode("drugDesc"):getPosition()
  local descSize = self:getNode("drugDesc"):getSize()
  local tempDesc = CCLabelTTF:create(desc, KANG_TTF_FONT, 18, CCSize(descSize.width, 0), ui.TEXT_ALIGN_LEFT, ui.TEXT_VALIGN_CENTER)
  tempDesc:setAnchorPoint(ccp(0, 1))
  tempDesc:setPosition(ccp(x, y + descSize.height))
  tempDesc:setColor(ccc3(255, 255, 255))
  self.m_UINode:addNode(tempDesc)
end
function selectDrugItem:getDrugShape()
  return self.m_DrugShape
end
function selectDrugItem:Clear()
end
return selectDrugItem
