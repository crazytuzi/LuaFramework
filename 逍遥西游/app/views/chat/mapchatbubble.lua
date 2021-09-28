CMapChatBubble = class(".CMapChatBubble", function()
  return Widget:create()
end)
function CMapChatBubble:ctor(msg, yy, clearCallBack, showTime)
  self.m_ClearCallBack = clearCallBack
  local iwidth = 160
  local minWith = 31
  local minHeight = 30
  local inx = 6
  local iny = 8
  local inw = 19
  local inh = 16
  local delw = 24
  local delh = 20
  local txtfont = FONT_NAME_MISSION
  local txtfontSize = 18
  local txtcolor = ccc3(255, 255, 255)
  local param = {
    width = iwidth - delw,
    font = txtfont,
    fontSize = txtfontSize,
    color = txtcolor,
    align = CRichText_AlignType_Left,
    maxLineNum = 4
  }
  local content = CRichText.new(param)
  self:addChild(content, 1)
  if yy ~= nil then
    local yyIcon = CYYIcon.new(yy, 1)
    content:addOneNode({
      obj = yyIcon,
      isWidget = true,
      offXY = ccp(0, 3)
    })
    content:addRichTextEmpty(18)
    content:addRichText(string.format("%.1fs", yy.time))
    content:addRichTextEmpty(5)
  end
  content:addRichText(msg)
  local size = content:getRealRichTextSize()
  local w = math.max(size.width + delw, minWith)
  local h = math.max(size.height + delh, minHeight)
  local msgBg = CCScale9Sprite:create("views/pic/pic_mapmsgbg.png", CCRect(0, 0, minWith, minHeight), CCRect(inx, iny, inw, inh))
  msgBg:setContentSize(CCSize(w, h))
  msgBg:setAnchorPoint(ccp(0.5, 0))
  self:addNode(msgBg)
  local bottomPic = display.newSprite("views/pic/pic_mapmsgbg_b.png")
  bottomPic:setAnchorPoint(ccp(0.5, 0))
  self:addNode(bottomPic)
  local bsize = bottomPic:getContentSize()
  local offy = bsize.height
  msgBg:setPosition(ccp(0, offy))
  content:setPosition(ccp(-size.width / 2, (h - size.height) / 2 + offy))
  showTime = showTime or 5
  local act1 = CCDelayTime:create(showTime)
  local act2 = CCCallFunc:create(function()
    if self.m_ClearCallBack then
      self.m_ClearCallBack(self)
    end
  end)
  self:runAction(transition.sequence({act1, act2}))
end
