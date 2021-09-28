CRoleListItemBase = class("CRoleListItemBase", function()
  return Widget:create()
end)
function CRoleListItemBase:ctor(heroId, itemW)
  self.m_RoleId = heroId
  self.m_IconFlag = false
  self.m_IsChoosed = false
  self.m_IsMainHero = self.m_RoleId == g_LocalPlayer:getMainHeroId()
  self.m_SelectOpacity = 255
  self.m_UnSelectOpacity = 150
  self.m_ScaleOffx = -2
  local heroIns = g_LocalPlayer:getObjById(heroId)
  local typeId = heroIns:getTypeId()
  self.m_HeadIcon = createWidgetFrameHeadIconByRoleTypeID(typeId)
  self:addChild(self.m_HeadIcon)
  local iSize = self.m_HeadIcon:getContentSize()
  self:ignoreContentAdaptWithSize(false)
  local offy = 10
  self:setSize(CCSize(itemW, iSize.height + offy))
  self.m_HeadIcon:setPosition(ccp(1.5, -4))
  local x, y = self.m_HeadIcon:getPosition()
  self.m_HeadIcon._initPos = ccp(x, y)
  self:setTouchEnabled(true)
  self:SetRedIcon()
  self:ShowExpIcon()
  if not self.m_IsMainHero then
    self:setScale(0.8)
    self:SetOpacity(self.m_UnSelectOpacity)
  end
  self:setNodeEventEnabled(true)
  MessageEventExtend.extend(self)
end
function CRoleListItemBase:onEnterEvent()
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_ItemInfo)
end
function CRoleListItemBase:setShowIconFlag(flag)
  if self.m_IconFlag == flag then
    return
  end
  self.m_IconFlag = flag
  if flag then
    if self.m_WarFlagIconObj == nil then
      local iconPath = self:GetIconPath()
      self.m_WarFlagIconObj = display.newSprite(iconPath)
      self:addNode(self.m_WarFlagIconObj, 10)
      self.m_WarFlagIconObj:setAnchorPoint(ccp(1, 0))
      local size = self:getContentSize()
      self.m_WarFlagIconObj:setPosition(ccp(size.width / 2 - 1, -size.height / 2 + 6))
      local x, y = self.m_WarFlagIconObj:getPosition()
      self.m_WarFlagIconObj._initPos = ccp(x, y)
      if self.m_IsChoosed and not self.m_IsMainHero then
        self.m_WarFlagIconObj:setPosition(ccp(x + self.m_ScaleOffx, y))
      end
    else
      self.m_WarFlagIconObj:setVisible(true)
    end
  elseif self.m_WarFlagIconObj then
    self.m_WarFlagIconObj:setVisible(false)
  end
end
function CRoleListItemBase:getIconFlagShow()
  return self.m_IconFlag
end
function CRoleListItemBase:SetOpacity(a)
  self.m_HeadIcon._BgIcon:setOpacity(a)
  self.m_HeadIcon._HeadIcon:setOpacity(a)
  if self.m_WarFlagIconObj then
    self.m_WarFlagIconObj:setOpacity(a)
  end
  if self.m_ChoosedFrame then
    self.m_ChoosedFrame:setOpacity(a)
  end
end
function CRoleListItemBase:setChoosed(isChoosed)
  if self.m_IsChoosed == isChoosed then
    return
  end
  self.m_IsChoosed = isChoosed
  if self.m_IsChoosed then
    if self.m_ChoosedFrame == nil then
      self.m_ChoosedFrame = display.newSprite("views/rolelist/pic_role_selected.png")
      self:addNode(self.m_ChoosedFrame, 0)
      local x, y = self.m_HeadIcon:getPosition()
      self.m_ChoosedFrame:setPosition(x, y)
      local x, y = self.m_ChoosedFrame:getPosition()
      self.m_ChoosedFrame._initPos = ccp(x, y)
    else
      self.m_ChoosedFrame:setVisible(true)
    end
    if not self.m_IsMainHero then
      local dt = 0.15
      self:stopAllActions()
      self:runAction(CCScaleTo:create(dt, 1))
      self:SetOpacity(self.m_SelectOpacity)
      for _, obj in pairs({
        self.m_HeadIcon,
        self.m_WarFlagIconObj,
        self.m_ChoosedFrame
      }) do
        if obj then
          local initPos = obj._initPos
          obj:stopAllActions()
          obj:runAction(CCMoveTo:create(dt, ccp(initPos.x + self.m_ScaleOffx, initPos.y)))
        end
      end
    end
  else
    if self.m_ChoosedFrame ~= nil then
      self.m_ChoosedFrame:setVisible(false)
    end
    if not self.m_IsMainHero then
      local dt = 0.15
      self:stopAllActions()
      self:runAction(CCScaleTo:create(dt, 0.8))
      self:SetOpacity(self.m_UnSelectOpacity)
      for _, obj in pairs({
        self.m_HeadIcon,
        self.m_WarFlagIconObj,
        self.m_ChoosedFrame
      }) do
        if obj then
          local initPos = obj._initPos
          obj:stopAllActions()
          obj:runAction(CCMoveTo:create(dt, ccp(initPos.x, initPos.y)))
        end
      end
    end
  end
end
function CRoleListItemBase:getRoleId()
  return self.m_RoleId
end
function CRoleListItemBase:SetRedIcon()
  local roleId = self:getRoleId()
  local ins = g_LocalPlayer:getObjById(roleId)
  local freeP = ins:getProperty(PROPERTY_FREEPOINT)
  local addFlag = false
  if freeP > 0 then
    local warsetting = g_LocalPlayer:getWarSetting()
    for index, pos in ipairs({
      3,
      2,
      4,
      1,
      5
    }) do
      local tempHeroId = warsetting[pos]
      if roleId == tempHeroId then
        addFlag = true
        break
      end
      if tempHeroId ~= nil then
        local tempHero = g_LocalPlayer:getObjById(tempHeroId)
        if tempHero then
          local tempPet = tempHero:getProperty(PROPERTY_PETID)
          if roleId == tempPet then
            addFlag = true
            break
          end
        end
      end
    end
  end
  if addFlag then
    if self.m_HeadIcon.redIcon == nil then
      local redIcon = display.newSprite("views/pic/pic_tipnew.png")
      self.m_HeadIcon:addNode(redIcon, 10)
      redIcon:setPosition(ccp(30, 40))
      self.m_HeadIcon.redIcon = redIcon
    end
  elseif self.m_HeadIcon.redIcon then
    self.m_HeadIcon.redIcon:removeFromParent()
    self.m_HeadIcon.redIcon = nil
  end
  return addFlag
end
function CRoleListItemBase:ShowExpIcon()
  local addFlag = false
  if g_LocalPlayer and g_LocalPlayer:GetJiaYiWanPetId() == self.m_RoleId then
    addFlag = true
  end
  if addFlag then
    if self.m_HeadIcon.expIcon == nil then
      local expIcon = display.newSprite("views/pic/pic_expicon.png")
      self.m_HeadIcon:addNode(expIcon, 10)
      expIcon:setPosition(ccp(-30, 40))
      self.m_HeadIcon.expIcon = expIcon
    end
  elseif self.m_HeadIcon.expIcon then
    self.m_HeadIcon.expIcon:removeFromParent()
    self.m_HeadIcon.expIcon = nil
  end
end
function CRoleListItemBase:onCleanup()
  self:RemoveAllMessageListener()
end
function CRoleListItemBase:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_HeroUpdate then
    local d = arg[1]
    if d.heroId == self:getRoleId() then
      self:SetRedIcon()
    end
  elseif msgSID == MsgID_PetUpdate then
    local d = arg[1]
    if d.petId == self:getRoleId() then
      self:SetRedIcon()
    end
  elseif msgSID == MsgID_WarSetting_Change then
    self:SetRedIcon()
  elseif msgSID == MsgID_ItemInfo_JiaYiWanDataUpdate then
    self:ShowExpIcon()
  end
end
CHeroListHeadItem = class("CHeroListHeadItem", CRoleListItemBase)
function CHeroListHeadItem:ctor(heroId, itemW)
  CHeroListHeadItem.super.ctor(self, heroId, itemW)
end
function CHeroListHeadItem:GetIconPath()
  return "views/mainviews/pic_mission_wartips.png"
end
CPetListHeadItem = class("CPetListHeadItem", CRoleListItemBase)
function CPetListHeadItem:ctor(heroId, itemW)
  CPetListHeadItem.super.ctor(self, heroId, itemW)
end
function CPetListHeadItem:GetIconPath()
  return "views/mainviews/pic_mission_wartips.png"
end
CPetEmptyItem = class("CPetEmptyItem", function()
  return Widget:create()
end)
function CPetEmptyItem:ctor(itemW)
  local icon = display.newSprite("views/mainviews/btn_pet.png")
  self:addNode(icon, 0)
  local iSize = icon:getContentSize()
  self:ignoreContentAdaptWithSize(false)
  local offy = 10
  self:setSize(CCSize(itemW, iSize.height + offy))
  self:setTouchEnabled(true)
end
CPetMoreItem = class("CPetMoreItem", function()
  return Widget:create()
end)
function CPetMoreItem:ctor(itemW)
  local icon = display.newSprite("views/mainviews/btn_pet.png")
  self:addNode(icon, 0)
  local addIcon = display.newSprite("views/common/btn/btn_add_2.png")
  self:addNode(addIcon, 1)
  addIcon:setPosition(ccp(0, 4))
  local iSize = icon:getContentSize()
  self:ignoreContentAdaptWithSize(false)
  local offy = 10
  self:setSize(CCSize(itemW, iSize.height + offy))
  self:setTouchEnabled(true)
end
