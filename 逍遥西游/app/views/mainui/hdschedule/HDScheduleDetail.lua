CHDScheduleDetail = class("CHDScheduleDetail", function()
  return Widget:create()
end)
function CHDScheduleDetail:ctor(hdId, clickpos, clicksize, dlgObj)
  self.m_DlgObj = dlgObj
  local offx = 15
  local offy = 15
  local w = 300
  local desc = data_getHuodongOpenTypeDesc(hdId)
  local textBox = CRichText.new({
    width = w,
    color = ccc3(255, 255, 255),
    fontSize = 20,
    align = CRichText_AlignType_Left,
    verticalSpace = 2
  })
  self:addChild(textBox, 2)
  textBox:addRichText(desc)
  textBox:setPosition(ccp(offx, offy))
  local tipSize = textBox:getRealRichTextSize()
  local name = data_getHuodongOpenTypeName(hdId)
  local nameTxt = ui.newTTFLabel({
    text = name,
    font = KANG_TTF_FONT,
    size = 22,
    color = ccc3(255, 245, 121)
  })
  self:addNode(nameTxt, 2)
  nameTxt:setPosition(ccp(tipSize.width / 2 + offx, tipSize.height + 22 + offx))
  local bg = display.newScale9Sprite("views/common/bg/bg_tips_scale.png", 4, 4, CCSize(10, 10))
  self:addNode(bg, 0)
  bg:setAnchorPoint(ccp(0, 0))
  bg:setContentSize(CCSize(tipSize.width + offx * 2, tipSize.height + offy + 50))
  bg:setPosition(ccp(0, 0))
  local bgSize = bg:getContentSize()
  self:setAnchorPoint(ccp(0, 0))
  self:ignoreContentAdaptWithSize(false)
  self:setSize(CCSize(bgSize.width, bgSize.height))
  tipssetposExtend.extend(self, {
    x = clickpos.x,
    y = clickpos.y,
    w = clicksize.width,
    h = clicksize.height
  })
  self:setNodeEventEnabled(true)
  self:setTouchEnabled(true)
  self:addTouchEventListener(function(touchObj, t)
    if t == TOUCH_EVENT_ENDED or t == TOUCH_EVENT_CANCELED then
      self.m_DlgObj:ClearHuoDongDetail()
    end
  end)
end
function CHDScheduleDetail:getViewSize()
  return self:getSize()
end
function CHDScheduleDetail:AutoClear()
  local act1 = CCDelayTime:create(5)
  local act2 = CCCallFunc:create(function()
    self.m_DlgObj:ClearHuoDongDetail()
  end)
  self:runAction(transition.sequence({act1, act2}))
end
function CHDScheduleDetail:onCleanup()
  self.m_DlgObj = nil
end
