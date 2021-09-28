local CEquipDetail = class("CEquipDetail", CcsSubView)
function CEquipDetail:ctor(itemObjId, paramTable)
  paramTable = paramTable or {}
  if paramTable.fromPackageFlag then
    CEquipDetail.super.ctor(self, "views/equip_detail_short.json", {
      opacityBg = paramTable.opacityBg
    })
  else
    CEquipDetail.super.ctor(self, "views/equip_detail.json", {
      opacityBg = paramTable.opacityBg
    })
  end
  self.m_ItemObjId = itemObjId
  self.m_ParamTable = paramTable
  local btnBatchListener = {
    btn_left = {
      listener = handler(self, self.OnBtn_Left),
      variName = "btn_left"
    },
    btn_right = {
      listener = handler(self, self.OnBtn_Right),
      variName = "btn_right"
    },
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    boxbg = {
      listener = handler(self, self.OnBtn_Close),
      variName = "boxbg",
      param = {0}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_CloseListener = paramTable.closeListener
  self.btn_close:setEnabled(false)
  if paramTable.leftBtnFontSize ~= nil then
    self.btn_left:setTitleFontSize(paramTable.leftBtnFontSize)
  end
  if paramTable.rightBtnFontSize ~= nil then
    self.btn_right:setTitleFontSize(paramTable.rightBtnFontSize)
  end
  local lx, ly = self.btn_left:getPosition()
  local rx, ry = self.btn_right:getPosition()
  self.m_MidBtnPos = ccp((lx + rx) / 2, (ly + ry) / 2)
  local paramLeft = paramTable.leftBtn
  if paramLeft == nil or type(paramLeft) ~= "table" then
    self.btn_left:setEnabled(false)
  else
    local txt = paramLeft.btnText or ""
    self.btn_left:setTitleText(txt)
    self.m_LeftBtnListener = paramLeft.listener
  end
  local paramRight = paramTable.rightBtn
  if paramRight == nil or type(paramRight) ~= "table" then
    self.btn_right:setEnabled(false)
  else
    local txt = paramRight.btnText or ""
    self.btn_right:setTitleText(txt)
    self.m_RightBtnListener = paramRight.listener
  end
  self:SetButtonsPos()
  self.list_detail = self:getNode("list_detail")
  local x, y = self.list_detail:getPosition()
  local lSize = self.list_detail:getContentSize()
  local w, h = lSize.width, lSize.height
  if not self.btn_left:isEnabled() and not self.btn_right:isEnabled() then
    local offy = 70
    self.list_detail:setPosition(ccp(x, y - offy))
    self.list_detail:ignoreContentAdaptWithSize(false)
    self.list_detail:setSize(CCSize(lSize.width, lSize.height + offy))
  end
  local showSourceFlag = true
  if paramTable.fromPackageFlag == true then
    showSourceFlag = false
  end
  self.m_ItemDetailText = CItemDetailText.new(self.m_ItemObjId, {
    width = lSize.width
  }, paramTable.itemType, paramTable.eqptRoleId, nil, showSourceFlag, handler(self, self.OnItemDetialTextSizeChanged))
  self.list_detail:pushBackCustomItem(self.m_ItemDetailText)
  local isEqptFlag = false
  local tmpLargeType
  if self.m_ItemObjId == nil then
    tmpLargeType = GetItemTypeByItemTypeId(paramTable.itemType)
  else
    local tmpObj = g_LocalPlayer:GetOneItem(self.m_ItemObjId)
    tmpLargeType = tmpObj:getType()
  end
  if tmpLargeType == ITEM_LARGE_TYPE_EQPT or tmpLargeType == ITEM_LARGE_TYPE_XIANQI or tmpLargeType == ITEM_LARGE_TYPE_SENIOREQPT or tmpLargeType == ITEM_LARGE_TYPE_HUOBANEQPT or tmpLargeType == ITEM_LARGE_TYPE_NEIDAN then
    isEqptFlag = true
  end
  local tSize = self.m_ItemDetailText:getContentSize()
  if not isEqptFlag and lSize.height >= tSize.height then
    self.list_detail:setTouchEnabled(false)
  end
  if self.m_ItemDetailHead then
    self.m_ItemDetailHead:removeFromParent()
  end
  self.m_ItemDetailHead = CItemDetailHead.new({
    width = w - 5,
    showName = paramTable.showName
  })
  self:getNode("boxbg"):addChild(self.m_ItemDetailHead)
  local isHuobanFlag = false
  if paramTable.isHuobanFlag == true then
    isHuobanFlag = true
  end
  self.m_ItemDetailHead:ShowItemDetail(self.m_ItemObjId, paramTable.itemType, paramTable.eqptRoleId, nil, paramTable.isCurrEquipShow, isHuobanFlag)
  local newSize = self.m_ItemDetailHead:getContentSize()
  self.m_ItemDetailHead:setPosition(ccp(x, y + h + newSize.height))
  if paramTable.enableTouchDetect ~= false then
    self:enableCloseWhenTouchOutside(self:getNode("boxbg"), true)
  end
end
function CEquipDetail:OnItemDetialTextSizeChanged()
  self.list_detail:refreshView()
end
function CEquipDetail:SetButtonsPos()
  if self.btn_left:isEnabled() and not self.btn_right:isEnabled() then
    self.btn_left:setPosition(self.m_MidBtnPos)
  elseif not self.btn_left:isEnabled() and self.btn_right:isEnabled() then
    self.btn_right:setPosition(self.m_MidBtnPos)
  end
end
function CEquipDetail:ShowCloseBtn(btnWPos)
  self.btn_close:setEnabled(true)
  if btnWPos ~= nil then
    local p = self.btn_close:getParent()
    local pos = p:convertToNodeSpace(btnWPos)
    self.btn_close:setPosition(ccp(pos.x, pos.y))
  end
end
function CEquipDetail:getItemObjId()
  return self.m_ItemObjId
end
function CEquipDetail:UpdateLeftButton(paramLeft)
  if paramLeft == nil then
    self.btn_left:setEnabled(false)
  else
    self.btn_left:setEnabled(true)
    local txt = paramLeft.btnText or ""
    self.btn_left:setTitleText(txt)
    self.m_LeftBtnListener = paramLeft.listener
  end
  self:SetButtonsPos()
end
function CEquipDetail:UpdateRightButton(paramRight)
  if paramRight == nil then
    self.btn_right:setEnabled(false)
  else
    self.btn_right:setEnabled(true)
    local txt = paramRight.btnText or ""
    self.btn_right:setTitleText(txt)
    self.m_RightBtnListener = paramRight.listener
  end
  self:SetButtonsPos()
end
function CEquipDetail:OnBtn_Left(btnObj, touchType)
  if self.m_LeftBtnListener then
    self.m_LeftBtnListener(self.m_ItemObjId)
  end
end
function CEquipDetail:OnBtn_Right(btnObj, touchType)
  if self.m_RightBtnListener then
    self.m_RightBtnListener(self.m_ItemObjId)
  end
end
function CEquipDetail:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function CEquipDetail:getBoxSize()
  return self:getNode("boxbg"):getSize()
end
function CEquipDetail:setEffectClickArea(areaRect)
  self:enableCloseWhenTouchOutsideBySize(areaRect)
end
function CEquipDetail:Clear()
  if self.m_CloseListener ~= nil then
    self.m_CloseListener()
  end
  self.m_LeftBtnListener = nil
  self.m_RightBtnListener = nil
  self.m_CloseListener = nil
end
return CEquipDetail
