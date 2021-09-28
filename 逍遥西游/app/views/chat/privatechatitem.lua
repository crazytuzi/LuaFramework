local DefineWithOff = 100
local DefineBgOffy = 4
CPrivateChatItem_Time = class(".CPrivateChatItem_Time", function()
  return Widget:create()
end)
function CPrivateChatItem_Time:ctor(month, day, hour, min, iwidth)
  local curTime = os.time()
  local temp = os.date("*t", curTime)
  local txt = string.format("%.2d:%.2d", hour, min)
  if temp.month ~= month or temp.day ~= day then
    txt = string.format("%.2d-%.2d %.2d:%.2d", month, day, hour, min)
  end
  local timeTxt = ui.newTTFLabel({
    text = txt,
    font = KANG_TTF_FONT,
    size = 18,
    color = ccc3(255, 255, 255)
  })
  self:addNode(timeTxt, 1)
  local offx = 6
  local size = timeTxt:getContentSize()
  timeTxt:setPosition(iwidth / 2, size.height / 2 + offx)
  self:ignoreContentAdaptWithSize(false)
  self:setSize(CCSize(iwidth, size.height + offx * 2 + 5))
  self:setAnchorPoint(ccp(0, 0))
  local bg = CCScale9Sprite:create("views/mainviews/pic_time_bg.png", CCRect(0, 0, 42, 14), CCRect(6, 4, 28, 5))
  bg:setAnchorPoint(ccp(0, 0))
  self:addNode(bg)
  bg:setContentSize(CCSize(size.width + 20, size.height + 8))
  local x, y = timeTxt:getPosition()
  local bgsize = bg:getContentSize()
  bg:setPosition(x - bgsize.width / 2, y - bgsize.height / 2)
end
CPrivateChatItem_Other = class(".CPrivateChatItem_Other", function()
  return Widget:create()
end)
function CPrivateChatItem_Other:ctor(pid, msg, yy, vip, iwidth, clickListener, showname)
  self.m_PlayerId = pid
  self.m_Showname = showname
  self.m_YY = yy
  self.m_Channel = CHANNEL_FRIEND
  if self.m_Showname == nil then
    self.m_Showname = true
  end
  local inx = 28
  local iny = 39
  local inw = 24
  local inh = 5
  local picw = 67
  local pich = 53
  local rightoffx = picw - inx - inw
  local param = {
    width = iwidth - DefineWithOff - inx - rightoffx,
    verticalSpace = 4,
    font = KANG_TTF_FONT,
    fontSize = 22,
    color = ccc3(0, 0, 0),
    align = CRichText_AlignType_Left,
    clickTextHandler = clickListener
  }
  local content = CRichText.new(param)
  self:addChild(content, 1)
  if self.m_YY ~= nil then
    self.m_YYIcon = CYYIcon.new(self.m_YY, 1)
    content:addOneNode({
      obj = self.m_YYIcon,
      isWidget = true,
      offXY = ccp(0, 5)
    })
    content:addRichTextEmpty(18)
  end
  content:addRichText(msg)
  self.m_Content = content
  self.m_JBMsg = msg
  local size = self.m_Content:getRealRichTextSize()
  local w = math.max(size.width + inx + rightoffx, picw)
  local h = math.max(size.height + 30, pich)
  local msgBg = CCScale9Sprite:create("views/pic/pic_chatmsgbg.png", CCRect(0, 0, picw, pich), CCRect(inx, iny, inw, inh))
  msgBg:setContentSize(CCSize(w, h))
  msgBg:setAnchorPoint(ccp(0, 0))
  self:addNode(msgBg)
  self.m_MsgBg = msgBg
  self.m_Inx = inx
  self.m_Vip = vip
  self.m_VipIcon = nil
  self:SetPlayerInfo(false)
  local spacey = 15
  if self.m_Showname or self.m_VipIcon ~= nil then
    spacey = 25
  end
  self:ignoreContentAdaptWithSize(false)
  self:setSize(CCSize(iwidth, h + DefineBgOffy * 2 + spacey))
  self:setAnchorPoint(ccp(0, 0))
  if self.m_YY ~= nil then
    local yyTime = self.m_YY.time
    local yyTimeTxt = ui.newTTFLabel({
      text = string.format("%d''", checkint(yyTime)),
      size = 18,
      font = KANG_TTF_FONT,
      color = ccc3(255, 255, 255)
    })
    msgBg:addChild(yyTimeTxt)
    yyTimeTxt:setAnchorPoint(ccp(0, 0))
    local size = msgBg:getContentSize()
    yyTimeTxt:setPosition(ccp(size.width + 3, 10))
  end
  clickArea_check.extend(self)
  self:click_check_withObj(self, handler(self, self.OnClicked), handler(self, self.OnTouchInSide), 0)
  self:setNodeEventEnabled(true)
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_Friends)
  self:ListenMessage(MsgID_OtherPlayer)
end
function CPrivateChatItem_Other:GetPlayerInfo()
  local info = g_FriendsMgr:getPlayerInfo(self.m_PlayerId)
  return info
end
function CPrivateChatItem_Other:SetPlayerInfo(isUpdate)
  local info = self:GetPlayerInfo()
  if isUpdate == true and info == nil then
    return
  end
  local msgBgOffX = 65
  local size = self.m_Content:getRealRichTextSize()
  local bgsize = self.m_MsgBg:getContentSize()
  local w, h = bgsize.width, bgsize.height
  if info then
    if info.zs ~= nil then
      self.m_Zhuan = info.zs
    end
    if info.level ~= nil then
      self.m_Level = info.level
    end
    if self.m_Head ~= nil then
      self.m_Head:removeFromParentAndCleanup(true)
      self.m_Head = nil
    end
    local s = 0.5
    local param = {
      roleTypeId = info.rtype,
      clickListener = function()
        ShowPlayerInfoOfChat(self.m_PlayerId, info.rtype, info.name, self.m_Zhuan, self.m_Level, self.m_Channel, self.m_JBMsg)
      end,
      noBgFlag = false
    }
    local head = createClickHead(param)
    head:setScale(s)
    self:addChild(head, 1)
    self.m_Head = head
    local hsize = head:getContentSize()
    local hoffx = 15
    local _, hy = hsize.width * s / 2 + hoffx, h - hsize.height * s + 10
    head:setPosition(ccp(hoffx, hy))
    msgBgOffX = hsize.width * s + hoffx
  end
  self.m_MsgBg:setPosition(msgBgOffX, DefineBgOffy)
  self.m_MsgBg:setAnchorPoint(ccp(0, 0))
  local msgBgx, msgBgy = self.m_MsgBg:getPosition()
  self.m_Content:setPosition(ccp(msgBgx + self.m_Inx, msgBgy + (h - size.height) / 2))
  if self.m_Vip ~= nil and 0 < self.m_Vip and self.m_VipIcon == nil then
    if 15 < self.m_Vip and self.m_Vip ~= VIP_LELVEL_ZHUBO then
      self.m_Vip = 15
    end
    self.m_VipIcon = display.newSprite(string.format("xiyou/pic/vip%d.png", self.m_Vip))
    self:addNode(self.m_VipIcon)
    self.m_VipIcon:setAnchorPoint(ccp(0, 0))
    if self.m_Vip == VIP_LELVEL_ZHUBO then
      self.m_VipIcon:setPosition(msgBgx + 15, msgBgy + h + 3)
    else
      self.m_VipIcon:setPosition(msgBgx + 15, msgBgy + h)
    end
  end
  local nameX = msgBgx + 15
  local nameY = msgBgy + h
  if self.m_VipIcon ~= nil then
    local vx, vy = self.m_VipIcon:getPosition()
    local vSize = self.m_VipIcon:getContentSize()
    nameX = vx + vSize.width + 5
  end
  if info and self.m_Showname then
    if self.m_NameTxt ~= nil then
      self.m_NameTxt:removeFromParentAndCleanup(true)
      self.m_NameTxt = nil
    end
    local zs = self.m_Zhuan or 0
    self.m_NameTxt = ui.newTTFLabel({
      text = info.name,
      size = 16,
      font = KANG_TTF_FONT,
      color = ccc3(142, 117, 81)
    })
    self:addNode(self.m_NameTxt)
    self.m_NameTxt:setPosition(nameX, nameY)
    self.m_NameTxt:setAnchorPoint(ccp(0, 0))
    if self.m_Zhuan ~= nil and self.m_Level ~= nil then
      if self.m_LevelTxt ~= nil then
        self.m_LevelTxt:removeFromParentAndCleanup(true)
        self.m_LevelTxt = nil
      end
      self.m_LevelTxt = ui.newTTFLabel({
        text = string.format("%d转%d", self.m_Zhuan, self.m_Level),
        size = 16,
        font = KANG_TTF_FONT,
        color = ccc3(142, 117, 81)
      })
      self:addNode(self.m_LevelTxt)
      self.m_LevelTxt:setAnchorPoint(ccp(0, 0))
      local x, y = self.m_NameTxt:getPosition()
      local size = self.m_NameTxt:getContentSize()
      self.m_LevelTxt:setPosition(x + size.width + 5, y)
    end
  end
end
function CPrivateChatItem_Other:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_Friends_UpdateFirend then
    local pid = arg[1]
    if pid == self.m_PlayerId then
      self:SetPlayerInfo(true)
    end
  elseif msgSID == MsgID_OtherPlayer_UpdatePlayer then
    local pid = arg[1]
    if pid == self.m_PlayerId then
      self:SetPlayerInfo(true)
    end
  end
end
function CPrivateChatItem_Other:OnTouchInSide(touch)
  if touch then
    self.m_MsgBg:setColor(ccc3(200, 200, 200))
  else
    self.m_MsgBg:setColor(ccc3(255, 255, 255))
  end
end
function CPrivateChatItem_Other:OnClicked()
  if self.m_YY == nil or self.m_YYIcon == nil then
    return
  end
  if self.m_YYIcon.__play == true then
    return
  end
  local pcmString = self.m_YY.voice
  local time = self.m_YY.time
  local yyid = self.m_YY.id
  if pcmString ~= nil and time ~= nil and yyid ~= nil then
    g_VoiceMgr:playPCMString(pcmString, yyid, time, nil, self.m_Channel, {
      pid = self.m_PlayerId
    })
  end
end
function CPrivateChatItem_Other:onCleanup()
  self:RemoveAllMessageListener()
end
CPrivateChatItem_Local = class(".CPrivateChatItem_Local", function()
  return Widget:create()
end)
function CPrivateChatItem_Local:ctor(msg, yy, vip, iwidth, clickListener)
  self.m_YY = yy
  self.m_Channel = CHANNEL_FRIEND
  local inx = 18
  local iny = 39
  local inw = 24
  local inh = 5
  local picw = 67
  local pich = 53
  local rightoffx = picw - inx - inw
  local param = {
    width = iwidth - DefineWithOff - inx - rightoffx,
    verticalSpace = 4,
    font = KANG_TTF_FONT,
    fontSize = 22,
    color = ccc3(0, 0, 0),
    align = CRichText_AlignType_Left,
    clickTextHandler = clickListener
  }
  local content = CRichText.new(param)
  self:addChild(content, 1)
  content:addRichText(msg)
  if self.m_YY ~= nil then
    self.m_YYIcon = CYYIcon.new(self.m_YY, 0)
    content:addRichTextEmpty(25)
    content:addOneNode({
      obj = self.m_YYIcon,
      isWidget = true,
      offXY = ccp(0, 5)
    })
  end
  local size = content:getRealRichTextSize()
  local w = math.max(size.width + inx + rightoffx, picw)
  local h = math.max(size.height + 30, pich)
  local msgBg = CCScale9Sprite:create("views/pic/pic_chatmsgbg_me.png", CCRect(0, 0, picw, pich), CCRect(inx, iny, inw, inh))
  msgBg:setContentSize(CCSize(w, h))
  self:addNode(msgBg)
  self.m_MsgBg = msgBg
  local s = 0.5
  local headbg = display.newSprite("views/mainviews/pic_headiconbg.png")
  headbg:setScale(s)
  self:addNode(headbg, 1)
  local mainhero = g_LocalPlayer:getMainHero()
  local shapeID = mainhero:getProperty(PROPERTY_SHAPE)
  local head = createHeadIconByShape(shapeID)
  head:setScale(s)
  self:addNode(head, 2)
  local hoffx = 15
  local hsize = headbg:getContentSize()
  local hx, hy = iwidth - hsize.width * s / 2 - hoffx, h - hsize.height * s / 2 + 10
  headbg:setPosition(ccp(hx, hy))
  head:setPosition(ccp(hx, hy + 3))
  local msgBgOffX = hsize.width * s + hoffx
  msgBg:setAnchorPoint(ccp(0, 0))
  msgBg:setPosition(iwidth - w - msgBgOffX, DefineBgOffy)
  local x, y = msgBg:getPosition()
  content:setPosition(ccp(x + inx, y + (h - size.height) / 2))
  self:ignoreContentAdaptWithSize(false)
  self:setSize(CCSize(iwidth, h + DefineBgOffy * 2 + 15))
  self:setAnchorPoint(ccp(0, 0))
  if self.m_YY ~= nil then
    local yyTime = self.m_YY.time
    local yyTimeTxt = ui.newTTFLabel({
      text = string.format("%d''", checkint(yyTime)),
      size = 18,
      font = KANG_TTF_FONT,
      color = ccc3(255, 255, 255)
    })
    msgBg:addChild(yyTimeTxt)
    yyTimeTxt:setAnchorPoint(ccp(1, 0))
    yyTimeTxt:setPosition(ccp(-3, 10))
  end
  clickArea_check.extend(self)
  self:click_check_withObj(self, handler(self, self.OnClicked), handler(self, self.OnTouchInSide), 0)
end
function CPrivateChatItem_Local:OnTouchInSide(touch)
  if touch then
    self.m_MsgBg:setColor(ccc3(200, 200, 200))
  else
    self.m_MsgBg:setColor(ccc3(255, 255, 255))
  end
end
function CPrivateChatItem_Local:OnClicked()
  if self.m_YY == nil or self.m_YYIcon == nil then
    return
  end
  if self.m_YYIcon.__play == true then
    return
  end
  local pcmString = self.m_YY.voice
  local time = self.m_YY.time
  local yyid = self.m_YY.id
  if pcmString ~= nil and time ~= nil and yyid ~= nil then
    g_VoiceMgr:playPCMString(pcmString, yyid, time)
  end
end
function CPrivateChatItem_Local:OnPlayFinish()
  if self.m_YYIcon == nil then
    return
  end
  if self.m_YYIcon.__play == false then
    return
  end
  self.m_YYIcon:playAniWithName("stop", 1, nil, false)
  self.m_YYIcon.__play = false
end
