local GuideArrowAni = class("GuideArrowAni", function()
  return CCNode:create()
end)
function GuideArrowAni:ctor(param)
  dump(param)
  local ani = self:makeTargetAni(param.aniType, param.objSize)
  if ani ~= nil then
    self:addChild(ani)
    self:setContentSize(ani:getContentSize())
  end
end
function GuideArrowAni:makeTargetAni(anitype, objsize)
  print("=================  ", anitype, objsize)
  dump(objsize)
  if anitype == GuideAnimitionTyPe_Hand then
    local ani = CreateSeqAnimation("xiyou/ani/eff_guide_hand.plist", -1)
    self:setAnchorPoint(ccp(0.5, 0.5))
    return ani
  elseif anitype == GuideAnimitionTyPe_Ret then
    objsize = objsize or {}
    objsize[1] = objsize[1] or 70
    objsize[2] = objsize[2] or 70
    if objsize[1] < 50 or objsize[2] < 50 then
      objsize[1] = 68
      objsize[2] = 66
    end
    local mainNode = CCNode:create()
    local tl = display.newSprite("views/pic/pic_selectcorner_sm.png", 11, objsize[2] - 11)
    local tr = display.newSprite("views/pic/pic_selectcorner_sm.png", objsize[1] - 11, objsize[2] - 11)
    local bl = display.newSprite("views/pic/pic_selectcorner_sm.png", 11, 11)
    local br = display.newSprite("views/pic/pic_selectcorner_sm.png", objsize[1] - 11, 11)
    tl:setAnchorPoint(ccp(0.5, 0.5))
    tr:setAnchorPoint(ccp(0.5, 0.5))
    bl:setAnchorPoint(ccp(0.5, 0.5))
    br:setAnchorPoint(ccp(0.5, 0.5))
    tr:setFlipX(true)
    bl:setFlipY(true)
    br:setRotation(180)
    mainNode:addChild(tl, -1)
    mainNode:addChild(tr, -1)
    mainNode:addChild(bl, -1)
    mainNode:addChild(br, -1)
    mainNode:setContentSize(CCSizeMake(objsize[1], objsize[2]))
    mainNode:setPosition(ccp(0, 0))
    mainNode:runAction(CCRepeatForever:create(transition.sequence({
      CCScaleTo:create(1, 1.1),
      CCScaleTo:create(1, 1)
    })))
    mainNode:setAnchorPoint(ccp(0.5, 0.5))
    print("************************************** 1 ")
    return mainNode
  elseif anitype == GuideAnimitionTyPe_Arrow then
  end
end
function GuideArrowAni:setDir(dir)
  print("GuideArrowAni:setDir:", dir)
end
function GuideArrowAni:onCleanup()
  print("GuideArrowAni:onCleanup:")
  self.m_PointAction = nil
end
return GuideArrowAni
