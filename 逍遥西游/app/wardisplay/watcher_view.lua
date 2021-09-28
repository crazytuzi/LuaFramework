local CWatcherView = class("CWatcherView", function()
  return Widget:create()
end)
function CWatcherView:ctor(pos, playerId, info, warSceneObj)
  self:setNodeEventEnabled(true)
  self.m_WarScene = warSceneObj
  self.m_Scale = 0.8
  self.m_PlayerId = playerId
  self.m_typeId = info.typeId
  self.m_BsType = info.bsType
  local roleTypeId = self:getShowingTypeId()
  self.m_BodyHeight = data_getBodyHeightByTypeID(roleTypeId) * self.m_Scale
  local cList = info.cList
  if self.m_BsType ~= nil then
    cList = {
      0,
      0,
      0
    }
  end
  local shape = data_getRoleShape(roleTypeId)
  local path, x, y = data_getBodyPathByShape(shape)
  if path:sub(-6) == ".plist" then
    path = path:sub(1, -6) .. "png"
  else
    path = path .. ".png"
  end
  local dynamicLoadTextureMode = getBodyDynamicLoadTextureMode(shape)
  addDynamicLoadTexture(path, function(handlerName, texture)
    if self.m_WarScene ~= nil and self.m_WarScene.m_HasBeenClosed ~= true and self.addNode ~= nil then
      self.m_ShapeAni, offx, offy = createBodyByShape(shape, nil, cList)
      self.m_ShapeAni:setPosition(offx, offy)
      self:addNode(self.m_ShapeAni, 1)
      self.m_ShapeAni:playAniWithName("stand_4")
      self.m_ShapeAni:setScaleX(-1)
      self.m_ShapeAni:setVisible(false)
      self.m_ShapeAni:runAction(CCShow:create())
    end
  end, {pixelFormat = dynamicLoadTextureMode})
  local shadow = display.newSprite("xiyou/pic/pic_shapeShadow.png")
  self:addNode(shadow, -1)
  self.m_Zs = info.zs or 0
  local name = info.name or ""
  local nameColor = self:getNameColor()
  self.m_Name = ui.newTTFLabelWithShadow({
    text = name,
    font = KANG_TTF_FONT,
    size = 24,
    align = ui.TEXT_ALIGN_CENTER,
    color = nameColor
  }):pos(0, -20)
  self.m_Name.shadow1:realign(1, 0)
  self:addNode(self.m_Name, 0)
  self:setScale(self.m_Scale)
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_Message)
end
function CWatcherView:OnMessage(msgSID, ...)
  if msgSID == MsgID_Message_TeamMsg then
    local arg = {
      ...
    }
    local chatpid = arg[1]
    local msg = arg[2]
    local yy = arg[4]
    if chatpid == self.m_PlayerId then
      self:addTalkMsg(msg, nil, yy)
    end
  end
end
function CWatcherView:addTalkMsg(msg, showTime, yy)
  if self.m_TalkBubbleObj ~= nil then
    self.m_TalkBubbleObj:removeFromParentAndCleanup(true)
    self.m_TalkBubbleObj = nil
  end
  self.m_TalkBubbleObj = CMapChatBubble.new(msg, yy, handler(self, self.onTalkBubbleClear), showTime)
  self:addChild(self.m_TalkBubbleObj, 100)
  self.m_TalkBubbleObj:setPosition(ccp(0, self.m_BodyHeight + 10))
end
function CWatcherView:onTalkBubbleClear(obj)
  if self.m_TalkBubbleObj == obj then
    self.m_TalkBubbleObj:removeFromParentAndCleanup(true)
    self.m_TalkBubbleObj = nil
  end
end
function CWatcherView:getPlayerId()
  return self.m_PlayerId
end
function CWatcherView:getNameColor()
  local nameColor = NameColor_MainHero[self.m_Zs] or ccc3(0, 150, 5)
  return nameColor
end
function CWatcherView:getShowingTypeId()
  if self.m_BsType ~= nil and self.m_BsType ~= 0 then
    return self.m_BsType
  end
  return self.m_typeId
end
function CWatcherView:onCleanup()
  self.m_WarScene = nil
  self:RemoveAllMessageListener()
end
return CWatcherView
