CSysMsgItem_Tip = class(".CSysMsgItem_Tip", function()
  return Widget:create()
end)
function CSysMsgItem_Tip:ctor(tip, iwidth, clickListener)
  local offx = 10
  local offy = 7
  local tipBg = display.newScale9Sprite("views/common/bg/bg1041.png", 10, 3, CCSize(1, 1))
  tipBg:setAnchorPoint(ccp(0, 0))
  self:addNode(tipBg, 0)
  local tipTxt = CRichText.new({
    width = iwidth - offx * 2,
    color = MsgColor_SysChannel_s,
    fontSize = 20,
    clickTextHandler = clickListener
  })
  tipTxt:addRichText(string.format("#<Channel:%d># %s", CHANNEL_SYS, tip))
  self:addChild(tipTxt, 2)
  local size = tipTxt:getRichTextSize()
  tipTxt:setPosition(ccp(offx, offy))
  tipBg:setContentSize(CCSize(iwidth, size.height + (offy - 1) * 2))
  tipBg:setPosition(ccp(0, 1))
  self:ignoreContentAdaptWithSize(false)
  self:setSize(CCSize(iwidth, size.height + offy * 2))
  self:setAnchorPoint(ccp(0, 0))
end
CSysHelpItem_Tip = class(".CSysHelpItem_Tip", function()
  return Widget:create()
end)
function CSysHelpItem_Tip:ctor(tip, iwidth, clickListener)
  local offx = 10
  local offy = 7
  local tipBg = display.newScale9Sprite("views/common/bg/bg1041.png", 10, 3, CCSize(1, 1))
  tipBg:setAnchorPoint(ccp(0, 0))
  self:addNode(tipBg, 0)
  local tipTxt = CRichText.new({
    width = iwidth - offx * 2,
    color = MsgColor_HelpChannel_s,
    fontSize = 20,
    clickTextHandler = clickListener
  })
  tipTxt:addRichText(string.format("#<Channel:%d># %s", CHANNEL_HELP, tip))
  self:addChild(tipTxt, 2)
  local size = tipTxt:getRichTextSize()
  tipTxt:setPosition(ccp(offx, offy))
  tipBg:setContentSize(CCSize(iwidth, size.height + (offy - 1) * 2))
  tipBg:setPosition(ccp(0, 1))
  self:ignoreContentAdaptWithSize(false)
  self:setSize(CCSize(iwidth, size.height + offy * 2))
  self:setAnchorPoint(ccp(0, 0))
end
CSysHelpItem_Kuaixun = class(".CSysHelpItem_Kuaixun", function()
  return Widget:create()
end)
function CSysHelpItem_Kuaixun:ctor(tip, iwidth, clickListener)
  local offx = 10
  local offy = 7
  local tipBg = display.newScale9Sprite("views/common/bg/bg1041.png", 10, 3, CCSize(1, 1))
  tipBg:setAnchorPoint(ccp(0, 0))
  self:addNode(tipBg, 0)
  local tipTxt = CRichText.new({
    width = iwidth - offx * 2,
    color = MsgColor_KuaixunChannel_s,
    fontSize = 20,
    clickTextHandler = clickListener
  })
  tipTxt:addRichText(string.format("#<Channel:%d># %s", CHANNEL_KUAI_XUN, tip))
  self:addChild(tipTxt, 2)
  local size = tipTxt:getRichTextSize()
  tipTxt:setPosition(ccp(offx, offy))
  tipBg:setContentSize(CCSize(iwidth, size.height + (offy - 1) * 2))
  tipBg:setPosition(ccp(0, 1))
  self:ignoreContentAdaptWithSize(false)
  self:setSize(CCSize(iwidth, size.height + offy * 2))
  self:setAnchorPoint(ccp(0, 0))
end
CSysHelpItem_Xinxi = class(".CSysHelpItem_Xinxi", function()
  return Widget:create()
end)
function CSysHelpItem_Xinxi:ctor(tip, iwidth, clickListener)
  local offx = 10
  local offy = 7
  local tipBg = display.newScale9Sprite("views/common/bg/bg1041.png", 10, 3, CCSize(1, 1))
  tipBg:setAnchorPoint(ccp(0, 0))
  self:addNode(tipBg, 0)
  local tipTxt = CRichText.new({
    width = iwidth - offx * 2,
    color = MsgColor_XinxiChannel_s,
    fontSize = 20,
    clickTextHandler = clickListener
  })
  tipTxt:addRichText(string.format("#<Channel:%d># %s", CHANNEL_XINXI, tip))
  self:addChild(tipTxt, 2)
  local size = tipTxt:getRichTextSize()
  tipTxt:setPosition(ccp(offx, offy))
  tipBg:setContentSize(CCSize(iwidth, size.height + (offy - 1) * 2))
  tipBg:setPosition(ccp(0, 1))
  self:ignoreContentAdaptWithSize(false)
  self:setSize(CCSize(iwidth, size.height + offy * 2))
  self:setAnchorPoint(ccp(0, 0))
end
CSysHelpItem_Common = class(".CSysHelpItem_Common", function()
  return Widget:create()
end)
function CSysHelpItem_Common:ctor(tip, iwidth, clickListener)
  local offx = 10
  local offy = 7
  local tipBg = display.newScale9Sprite("views/common/bg/bg1041.png", 10, 3, CCSize(1, 1))
  tipBg:setAnchorPoint(ccp(0, 0))
  self:addNode(tipBg, 0)
  local tipTxt = CRichText.new({
    width = iwidth - offx * 2,
    color = MsgColor_XinxiChannel_s,
    fontSize = 20,
    clickTextHandler = clickListener
  })
  tipTxt:addRichText(string.format("#<Channel:%d># %s", CHANNEL_COMMON, tip))
  self:addChild(tipTxt, 2)
  local size = tipTxt:getRichTextSize()
  tipTxt:setPosition(ccp(offx, offy))
  tipBg:setContentSize(CCSize(iwidth, size.height + (offy - 1) * 2))
  tipBg:setPosition(ccp(0, 1))
  self:ignoreContentAdaptWithSize(false)
  self:setSize(CCSize(iwidth, size.height + offy * 2))
  self:setAnchorPoint(ccp(0, 0))
end
