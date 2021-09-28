g_Click_Attr_View = nil
CAttrDetailView = class("CAttrDetailView", CcsSubView)
function CAttrDetailView:ctor(attrName, posPara, paramListener, delControlFlag)
  CAttrDetailView.super.ctor(self, "views/attrdesc.json")
  self.m_DelControlFlag = delControlFlag or false
  self.m_DeleteFlag = false
  self.m_CanDelete = false
  self:SetAttrInfo(attrName, paramListener)
  self:AutoDelSelf()
  local act1 = CCDelayTime:create(0.01)
  local act2 = CCCallFunc:create(function()
    tipsviewExtend.extend(self)
  end)
  self:runAction(transition.sequence({act1, act2}))
  tipssetposExtend.extend(self, posPara)
  if g_Click_Attr_View ~= nil then
    g_Click_Attr_View:removeFromParentAndCleanup(true)
    g_Click_Attr_View = nil
  end
  g_Click_Attr_View = self
end
function CAttrDetailView:SetAttrInfo(attrName, paramListener)
  local offx = 10
  local offy = 8
  local attrTip = data_AttrTip[attrName]
  if attrName == PROPERTY_GenGu or attrName == PROPERTY_Lingxing or attrName == PROPERTY_LiLiang or attrName == PROPERTY_MinJie then
    if paramListener ~= nil then
      local race = paramListener()
      local temp = AttrTipExtra[attrName]
      if temp then
        local extip = temp[race]
        if extip ~= nil then
          attrTip = string.format("%s,%s", attrTip, extip)
        end
      end
    end
  elseif attrName == "itemhjd" and paramListener ~= nil then
    local petType = paramListener()
    if data_getPetTypeIsCanHuaLing(petType) then
      attrTip = data_AttrTip.itemhlw
    end
  end
  local tipObj = CRichText.new({
    width = 200,
    font = KANG_TTF_FONT,
    fontSize = 20,
    color = ccc3(255, 255, 255)
  })
  tipObj:addRichText(attrTip)
  self:addChild(tipObj, 1)
  local size = tipObj:getRealRichTextSize()
  local w = math.max(size.width + offx * 2, 60)
  local h = math.max(size.height + offy * 2, 42)
  tipObj:setPosition(ccp((w - size.width) / 2, (h - size.height) / 2))
  self:getNode("bg"):setSize(CCSize(w, h))
  self.m_UINode:ignoreContentAdaptWithSize(false)
  self.m_UINode:setSize(CCSize(w, h))
end
function CAttrDetailView:AutoDelSelf()
  local act1 = CCDelayTime:create(5)
  local act2 = CCCallFunc:create(function()
    self:DelSelf()
  end)
  self:runAction(transition.sequence({act1, act2}))
end
function CAttrDetailView:DelSelf()
  self.m_DeleteFlag = true
  if self.m_DelControlFlag then
    if self.m_CanDelete then
      self:removeFromParentAndCleanup(true)
    end
  else
    self:removeFromParentAndCleanup(true)
  end
end
function CAttrDetailView:setCanDelete()
  self.m_CanDelete = true
  if self.m_DeleteFlag then
    self:removeFromParentAndCleanup(true)
  end
end
function CAttrDetailView:getViewSize()
  local size = self.m_UINode:getSize()
  return self.m_UINode:getSize()
end
function CAttrDetailView:Clear()
  print("CAttrDetailView---del")
  if g_Click_Attr_View == self then
    g_Click_Attr_View = nil
  end
end
