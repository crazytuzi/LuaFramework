local g_TestShape = 11001
local g_ParentNode
local g_TestData_Main = {
  11001,
  11002,
  11004,
  11006,
  11008,
  11009,
  12001,
  12002,
  12004,
  12006,
  12007,
  12009,
  13001,
  13003,
  13004,
  13006,
  13008,
  13009,
  14001,
  14002,
  14003,
  14004
}
local g_TestData_Monster = {20001, 20050}
local g_TestData_Npc = {30001, 30017}
local g_TestShapeNodeList = {}
local testShape_Btn = function(path, callback)
  local btn = display.newSprite(path)
  btn:setTouchEnabled(true)
  btn:registerScriptTouchHandler(function(event, tx, ty)
    if event == "began" then
      if callback then
        callback()
      end
      btn:setScale(0.9)
      local act1 = CCDelayTime:create(0.3)
      local act2 = CCCallFunc:create(function()
        local a1 = CCCallFunc:create(function()
          if callback then
            callback()
          end
        end)
        local a2 = CCDelayTime:create(0.05)
        local a3 = CCRepeatForever:create(transition.sequence({a1, a2}))
        btn:runAction(a3)
      end)
      btn:runAction(transition.sequence({act1, act2}))
      return true
    elseif event == "ended" or event == "canceld" then
      btn:setScale(1)
      btn:stopAllActions()
    end
  end)
  return btn
end
local testOffBtn = class("testOffBtn", function()
  local node = display.newNode()
  return node
end)
function testOffBtn:ctor(shapeObj, offData, listener)
  self.m_OffData = offData
  self.m_Listener = listener
  local btn_left = testShape_Btn("views/rolelist/btn_subpro.png", handler(self, self.OnLeft))
  self:addChild(btn_left)
  btn_left:setPosition(-35, 0)
  local btn_right = testShape_Btn("views/rolelist/btn_addpro.png", handler(self, self.OnRight))
  self:addChild(btn_right)
  btn_right:setPosition(35, 0)
  local btn_up = testShape_Btn("views/rolelist/btn_addpro.png", handler(self, self.OnUp))
  self:addChild(btn_up)
  btn_up:setPosition(0, 35)
  local btn_down = testShape_Btn("views/rolelist/btn_subpro.png", handler(self, self.OnDown))
  self:addChild(btn_down)
  btn_down:setPosition(0, -35)
  self.m_LabelX = ui.newTTFLabel({
    text = tostring(0),
    size = 20,
    font = KANG_TTF_FONT,
    color = ccc3(255, 0, 0)
  })
  self:addChild(self.m_LabelX)
  self.m_LabelX:setAnchorPoint(ccp(0, 0.5))
  self.m_LabelX:setPosition(60, 11)
  self.m_LabelY = ui.newTTFLabel({
    text = tostring(0),
    size = 20,
    font = KANG_TTF_FONT,
    color = ccc3(255, 0, 0)
  })
  self:addChild(self.m_LabelY)
  self.m_LabelY:setAnchorPoint(ccp(0, 0.5))
  self.m_LabelY:setPosition(60, -11)
  self:setLabel()
  local x, y = shapeObj:getPosition()
  self:setPosition(x, y - 80)
end
function testOffBtn:setLabel()
  self.m_LabelX:setString(string.format("x: %d", self.m_OffData[1]))
  self.m_LabelY:setString(string.format("y: %d", self.m_OffData[2]))
end
function testOffBtn:OnLeft()
  self:OnTestOff(-1, 0)
end
function testOffBtn:OnRight()
  self:OnTestOff(1, 0)
end
function testOffBtn:OnUp()
  self:OnTestOff(0, 1)
end
function testOffBtn:OnDown()
  self:OnTestOff(0, -1)
end
function testOffBtn:OnTestOff(offx, offy)
  self.m_OffData[1] = self.m_OffData[1] + offx
  self.m_OffData[2] = self.m_OffData[2] + offy
  self:setLabel()
  if self.m_Listener then
    self.m_Listener()
  end
end
local testWarBody = class("testWarBody", function()
  local node = display.newNode()
  return node
end)
function testWarBody:ctor(testShapeId, direction, actName)
  self.m_TestShapeId = testShapeId
  self.m_Direction = direction
  local offx, offy = 0, 0
  self.m_Body, offx, offy = createWarBodyByShape(testShapeId, direction)
  self.m_Body:setPosition(offx, offy)
  self.m_Body:playAniWithName(actName, -1)
  self:addChild(self.m_Body)
  local data = data_Shape[self.m_TestShapeId]
  self.m_BodyOff = {
    data.body_offx,
    data.body_offy
  }
  local aniInfo = data_getBodyNormalAttackAniByShape(self.m_TestShapeId, self.m_Direction)
  local attAni_offx = aniInfo.attAni_offx or 0
  local attAni_offy = aniInfo.attAni_offy or 0
  self.m_AttackAniOff = {attAni_offx, attAni_offy}
  local offx = aniInfo.magicAni_offx or 0
  local offy = aniInfo.magicAni_offy or 0
  self.m_MagicAniOff = {offx, offy}
  local hurtAni_offx = aniInfo.hurtAni_offx or 0
  local hurtAni_offy = aniInfo.hurtAni_offy or 0
  self.m_HurtAniOff = {hurtAni_offx, hurtAni_offy}
end
function testWarBody:freshBodyOff()
  local _, offx, offy = data_getWarBodyPathByShape(self.m_TestShapeId, self.m_Direction)
  self.m_Body:setPosition(offx, offy)
end
function testWarBody:playAniWithName(aniName, times, cblistener, autoDestroy)
  return self.m_Body:playAniWithName(aniName, times, cblistener, autoDestroy)
end
function testWarBody:OnGuardOffChanged()
  local data = data_Shape[self.m_TestShapeId]
  data.body_offx = self.m_BodyOff[1]
  data.body_offy = self.m_BodyOff[2]
  for _, shapeObj in pairs(g_TestShapeNodeList) do
    shapeObj:freshBodyOff()
  end
end
function testWarBody:testGuardAni()
  if self.m_BodyOffBtn == nil then
    self.m_BodyOffBtn = testOffBtn.new(self, self.m_BodyOff, handler(self, self.OnGuardOffChanged))
    self:addChild(self.m_BodyOffBtn)
  end
end
function testWarBody:testAttackAni()
  self.m_Body:playAniWithName(string.format("attack_%d", self.m_Direction), 1, function()
    self:testAttackAni()
  end, false)
  local aniInfo = data_getBodyNormalAttackAniByShape(self.m_TestShapeId, self.m_Direction)
  local attAni = aniInfo.attAni
  if attAni ~= nil then
    do
      local attDelay = aniInfo.attAniDelay
      local flipx = aniInfo.attAni_Flip[1]
      local flipy = aniInfo.attAni_Flip[2]
      local act1 = CCDelayTime:create(attDelay)
      local act2 = CCCallFunc:create(function()
        local attAniSprite = warAniCreator.createAni(attAni, 1, nil, true, true)
        attAniSprite:setPosition(self.m_AttackAniOff[1], self.m_AttackAniOff[2])
        attAniSprite:setScale(1)
        if flipx ~= 0 then
          attAniSprite:setScaleX(-1)
        end
        if flipy ~= 0 then
          attAniSprite:setScaleY(-1)
        end
        self:addChild(attAniSprite, 3)
      end)
      self:runAction(transition.sequence({act1, act2}))
    end
  end
end
function testWarBody:testMagicAni()
  self.m_Body:playAniWithName(string.format("magic_%d", self.m_Direction), 1, function()
    self:testMagicAni()
  end, false)
  local magicAniSprite = warAniCreator.createAni(string.format("xiyou/ani/magic1_4.plist", 4), 1, nil, true, true)
  magicAniSprite:setPosition(0, 0)
  self:addChild(magicAniSprite, 3)
  magicAniSprite:setPosition(self.m_MagicAniOff[1], self.m_MagicAniOff[2])
  magicAniSprite:setScale(1)
  local magicAniSprite = warAniCreator.createAni(string.format("xiyou/ani/magic2_4.plist", 4), 1, nil, true, true)
  magicAniSprite:setPosition(0, 0)
  self:addChild(magicAniSprite, -1)
  magicAniSprite:setPosition(self.m_MagicAniOff[1], self.m_MagicAniOff[2] - 35)
  if self.m_MagicOffBtn == nil then
    self.m_MagicOffBtn = testOffBtn.new(self, self.m_MagicAniOff)
    self:addChild(self.m_MagicOffBtn)
  end
end
function testWarBody:testHurtAni()
  self.m_Body:playAniWithName(string.format("hurt_%d", self.m_Direction), 1, function()
    self:testHurtAni()
  end, false)
  local aniInfo = data_getBodyNormalAttackAniByShape(self.m_TestShapeId, self.m_Direction)
  local hurtAni = aniInfo.hurtAni
  if hurtAni ~= nil then
    local hurtAniSprite = warAniCreator.createAni(hurtAni, 1, nil, true, true)
    hurtAniSprite:setPosition(self.m_HurtAniOff[1], self.m_HurtAniOff[2])
    hurtAniSprite:setScale(1)
    self:addChild(hurtAniSprite, 3)
  end
  if self.m_HurtOffBtn == nil then
    self.m_HurtOffBtn = testOffBtn.new(self, self.m_HurtAniOff)
    self:addChild(self.m_HurtOffBtn)
  end
end
local align_left = 1
local align_right = 2
local align_up = 3
local align_down = 4
local testClickLayer = class("testClickLayer", function()
  local node = display.newNode()
  return node
end)
function testClickLayer:ctor()
  local data = data_Shape[g_TestShape]
  local w = data.bodyWidth
  local h = data.bodyHeight
  self.m_hNumber = h
  self.m_wNumber = w
  self.m_hLayerOff = {80, 0}
  self.m_wLayerOff = {0, -45}
  local wLayer = CCLayerColor:create(ccc4(0, 0, 200, 180))
  wLayer:setContentSize(CCSize(w, 10))
  self:addChild(wLayer)
  self.m_WLayer = wLayer
  local hLayer = CCLayerColor:create(ccc4(0, 0, 200, 180))
  hLayer:setContentSize(CCSize(10, h))
  self:addChild(hLayer)
  hLayer:setTouchEnabled(true)
  hLayer:registerScriptTouchHandler(function(event, tx, ty)
    return self:onClickLayer(event, tx, ty)
  end)
  self.m_HLayer = hLayer
  self.m_HNumberTxt = ui.newTTFLabel({
    text = tostring(self.m_hNumber),
    size = 20,
    font = KANG_TTF_FONT,
    color = ccc3(255, 0, 0)
  })
  self.m_HNumberTxt:setAnchorPoint(ccp(0.5, 0.5))
  self:addChild(self.m_HNumberTxt)
  self.m_WNumberTxt = ui.newTTFLabel({
    text = tostring(self.m_wNumber),
    size = 20,
    font = KANG_TTF_FONT,
    color = ccc3(255, 0, 0)
  })
  self.m_WNumberTxt:setAnchorPoint(ccp(0.5, 0.5))
  self:addChild(self.m_WNumberTxt)
  self:setNumber()
end
function testClickLayer:onClickLayer(event, tx, ty)
  if event == "began" then
    do
      local size = self.m_HLayer:getContentSize()
      local p = self.m_HLayer:convertToNodeSpace(ccp(tx, ty))
      local x, y = p.x, p.y
      self.m_ClickFlag = 0
      if x < 0 or x > size.width or y < 0 or y > size.height then
        local size = self.m_WLayer:getContentSize()
        local p = self.m_WLayer:convertToNodeSpace(ccp(tx, ty))
        x, y = p.x, p.y
        if x < 0 or x > size.width or y < 0 or y > size.height then
          return false
        else
          self.m_ClickFlag = 2
        end
      else
        self.m_ClickFlag = 1
      end
      self:clicked(x, y, self.m_ClickFlag)
      local act1 = CCDelayTime:create(0.3)
      local act2 = CCCallFunc:create(function()
        local a1 = CCCallFunc:create(function()
          self:clicked(x, y, self.m_ClickFlag)
        end)
        local a2 = CCDelayTime:create(0.05)
        local a3 = CCRepeatForever:create(transition.sequence({a1, a2}))
        self.m_HLayer:runAction(a3)
      end)
      self.m_HLayer:runAction(transition.sequence({act1, act2}))
      return true
    end
  elseif event == "ended" or event == "canceld" then
    self.m_HLayer:stopAllActions()
  end
end
function testClickLayer:setNumber()
  self.m_HNumberTxt:setString(tostring(self.m_hNumber))
  local size = self.m_HLayer:getContentSize()
  local nsize = self.m_HNumberTxt:getContentSize()
  local off = 2
  self.m_HLayer:setPosition(self.m_hLayerOff[1], self.m_hLayerOff[2])
  self.m_HNumberTxt:setPosition(self.m_hLayerOff[1] + size.width / 2, self.m_hLayerOff[2] + size.height + nsize.height / 2 + off)
  self.m_WNumberTxt:setString(tostring(self.m_wNumber))
  local size = self.m_WLayer:getContentSize()
  local nsize = self.m_WNumberTxt:getContentSize()
  local off = 2
  self.m_WLayer:setPosition(self.m_wLayerOff[1] - size.width / 2, self.m_wLayerOff[2])
  self.m_WNumberTxt:setPosition(self.m_wLayerOff[1], self.m_wLayerOff[2] - nsize.height / 2 - off)
end
function testClickLayer:clicked(x, y, clickType)
  if clickType == 2 then
    local size = self.m_WLayer:getContentSize()
    if x < size.width / 2 then
      self.m_wNumber = self.m_wNumber - 1
      if self.m_wNumber < 0 then
        self.m_wNumber = 0
      end
      self:OnWidthChanged(self.m_wNumber)
      self:setNumber(self.m_wNumber)
    else
      self.m_wNumber = self.m_wNumber + 1
      self:OnWidthChanged(self.m_wNumber)
      self:setNumber(self.m_wNumber)
    end
  elseif clickType == 1 then
    local size = self.m_HLayer:getContentSize()
    if y < size.height / 2 then
      self.m_hNumber = self.m_hNumber - 1
      if 0 > self.m_hNumber then
        self.m_hNumber = 0
      end
      self:OnHeightChanged(self.m_hNumber)
      self:setNumber(self.m_hNumber)
    else
      self.m_hNumber = self.m_hNumber + 1
      self:OnHeightChanged(self.m_hNumber)
      self:setNumber(self.m_hNumber)
    end
  end
end
function testClickLayer:OnHeightChanged(v)
  local data = data_Shape[g_TestShape]
  if data == nil then
    return
  end
  data.bodyHeight = v
  local size = self.m_HLayer:getContentSize()
  self.m_HLayer:setContentSize(CCSize(size.width, v))
end
function testClickLayer:OnWidthChanged(v)
  local data = data_Shape[g_TestShape]
  if data == nil then
    return
  end
  data.bodyWidth = v
  local size = self.m_WLayer:getContentSize()
  self.m_WLayer:setContentSize(CCSize(v, size.height))
end
local TestSprite = function(parentNode)
  local s1 = display.newSprite("xiyou/head/head30001.png")
  s1:setPosition(480, 320)
  parentNode:addChild(s1)
  local s2 = display.newSprite("xiyou/head/head44001.png")
  s2:setOpacity(128)
  s2:setPosition(480, 320)
  parentNode:addChild(s2)
end
function TestSeqAnimation(parentNode)
  local bg = display.newColorLayer(ccc4(180, 180, 180, 255))
  parentNode:addChild(bg, -1)
  local roleData = {
    typeId = 11001,
    hp = 100,
    maxHp = 100,
    mp = 100,
    maxMp = 100,
    team = 1
  }
  local testRole1 = CHeroView.new(10001, roleData, parentNode)
  parentNode:addChild(testRole1)
  testRole1:setPosition(ccp(150, 380))
  local roleData = {
    typeId = 11001,
    hp = 100,
    maxHp = 100,
    mp = 100,
    maxMp = 100,
    team = 1
  }
  local testRole2 = CHeroView.new(1, roleData, parentNode)
  parentNode:addChild(testRole2)
  testRole2:setPosition(ccp(300, 380))
  local roleData = {
    typeId = 50001,
    hp = 100,
    maxHp = 100,
    mp = 100,
    maxMp = 100,
    team = 1
  }
  local testRole3 = CHeroView.new(10001, roleData, parentNode)
  parentNode:addChild(testRole3)
  testRole3:setPosition(ccp(150, 180))
  local roleData = {
    typeId = 50001,
    hp = 100,
    maxHp = 100,
    mp = 100,
    maxMp = 100,
    team = 1
  }
  local testRole4 = CHeroView.new(1, roleData, parentNode)
  parentNode:addChild(testRole4)
  testRole4:setPosition(ccp(300, 180))
  local roleData = {
    typeId = 20001,
    hp = 100,
    maxHp = 100,
    mp = 100,
    maxMp = 100,
    team = 1
  }
  local testRole5 = CHeroView.new(10001, roleData, parentNode)
  parentNode:addChild(testRole5)
  testRole5:setPosition(ccp(450, 180))
  local roleData = {
    typeId = 20001,
    hp = 100,
    maxHp = 100,
    mp = 100,
    maxMp = 100,
    team = 1
  }
  local testRole6 = CHeroView.new(1, roleData, parentNode)
  parentNode:addChild(testRole6)
  testRole6:setPosition(ccp(600, 180))
  local roleData = {
    typeId = 20015,
    hp = 100,
    maxHp = 100,
    mp = 100,
    maxMp = 100,
    team = 1
  }
  local testRole7 = CHeroView.new(10001, roleData, parentNode)
  parentNode:addChild(testRole7)
  testRole7:setPosition(ccp(450, 380))
  local roleData = {
    typeId = 20015,
    hp = 100,
    maxHp = 100,
    mp = 100,
    maxMp = 100,
    team = 1
  }
  local testRole8 = CHeroView.new(1, roleData, parentNode)
  parentNode:addChild(testRole8)
  testRole8:setPosition(ccp(600, 380))
end
btn_x1 = 150
btn_x2 = 280
btn_y = 60
function testShape()
  local root = CCScene:create()
  display.replaceScene(root)
  local bg = display.newColorLayer(ccc4(180, 180, 180, 255))
  root:addChild(bg, -1)
  g_ParentNode = display.newNode()
  root:addChild(g_ParentNode, 1)
  local red_add = testShape_Btn("views/rolelist/btn_addpro.png", testShapeNext)
  root:addChild(red_add, 10)
  red_add:setPosition(btn_x2, btn_y)
  local red_sub = testShape_Btn("views/rolelist/btn_subpro.png", testShapePre)
  root:addChild(red_sub, 10)
  red_sub:setPosition(btn_x1, btn_y)
  testShapeID()
end
function testShapePre()
  local s = math.floor(g_TestShape / 10000)
  if s == 1 then
    if g_TestShape == g_TestData_Main[1] then
      g_TestShape = g_TestData_Npc[2]
      testShapeID_Npc()
    else
      for index, sID in pairs(g_TestData_Main) do
        if sID == g_TestShape then
          g_TestShape = g_TestData_Main[index - 1]
          testShapeID()
          break
        end
      end
    end
  elseif s == 2 then
    if g_TestShape <= g_TestData_Monster[1] then
      g_TestShape = g_TestData_Main[#g_TestData_Main]
      testShapeID()
    else
      g_TestShape = g_TestShape - 1
      testShapeID()
    end
  elseif s == 3 then
    if g_TestShape <= g_TestData_Npc[1] then
      g_TestShape = g_TestData_Monster[2]
      testShapeID()
    else
      g_TestShape = g_TestShape - 1
      testShapeID_Npc()
    end
  end
end
function testShapeNext()
  local s = math.floor(g_TestShape / 10000)
  if s == 1 then
    if g_TestShape == g_TestData_Main[#g_TestData_Main] then
      g_TestShape = g_TestData_Monster[1]
      testShapeID()
    else
      for index, sID in pairs(g_TestData_Main) do
        if sID == g_TestShape then
          g_TestShape = g_TestData_Main[index + 1]
          testShapeID()
          break
        end
      end
    end
  elseif s == 2 then
    if g_TestShape >= g_TestData_Monster[2] then
      g_TestShape = g_TestData_Npc[1]
      testShapeID_Npc()
    else
      g_TestShape = g_TestShape + 1
      testShapeID()
    end
  elseif s == 3 then
    if g_TestShape >= g_TestData_Npc[2] then
      g_TestShape = g_TestData_Main[1]
      testShapeID()
    else
      g_TestShape = g_TestShape + 1
      testShapeID_Npc()
    end
  end
end
function testShapeID()
  g_TestShapeNodeList = {}
  local y_up = 480
  local y_down = 150
  g_ParentNode:removeAllChildren()
  local testShapeId = g_TestShape
  local idtxt = ui.newTTFLabel({
    text = tostring(testShapeId),
    size = 22,
    font = KANG_TTF_FONT,
    color = ccc3(255, 0, 0)
  })
  g_ParentNode:addChild(idtxt)
  idtxt:setPosition((btn_x1 + btn_x2) / 2, btn_y)
  local shapeNode = display.newNode()
  g_ParentNode:addChild(shapeNode)
  local role1 = testWarBody.new(testShapeId, 8, "guard_8")
  shapeNode:addChild(role1)
  shapeNode:setPosition(130, y_up)
  g_TestShapeNodeList[#g_TestShapeNodeList + 1] = role1
  local shadow = display.newSprite("xiyou/pic/pic_shapeShadow.png")
  shapeNode:addChild(shadow, -1)
  local height = data_Shape[testShapeId].bodyHeight
  local hLayer = testClickLayer.new(10, height, height, align_up, false)
  shapeNode:addChild(hLayer, 99)
  local shapeNode = display.newNode()
  g_ParentNode:addChild(shapeNode)
  local role1 = testWarBody.new(testShapeId, 4, "guard_4")
  shapeNode:addChild(role1)
  shapeNode:setPosition(330, y_up)
  g_TestShapeNodeList[#g_TestShapeNodeList + 1] = role1
  local shadow = display.newSprite("xiyou/pic/pic_shapeShadow.png")
  shapeNode:addChild(shadow, -1)
  role1:testGuardAni()
  local shapeNode = display.newNode()
  g_ParentNode:addChild(shapeNode)
  local role1, x, y = testWarBody.new(testShapeId, 8, "attack_8")
  shapeNode:addChild(role1)
  shapeNode:setPosition(130, y_down)
  g_TestShapeNodeList[#g_TestShapeNodeList + 1] = role1
  local shadow = display.newSprite("xiyou/pic/pic_shapeShadow.png")
  shapeNode:addChild(shadow, -1)
  role1:testAttackAni()
  local shapeNode = display.newNode()
  g_ParentNode:addChild(shapeNode)
  local role1 = testWarBody.new(testShapeId, 4, "attack_4")
  shapeNode:addChild(role1)
  shapeNode:setPosition(330, y_down)
  g_TestShapeNodeList[#g_TestShapeNodeList + 1] = role1
  local shadow = display.newSprite("xiyou/pic/pic_shapeShadow.png")
  shapeNode:addChild(shadow, -1)
  role1:testAttackAni()
  local shapeNode = display.newNode()
  g_ParentNode:addChild(shapeNode)
  local role1, x, y = testWarBody.new(testShapeId, 8, "magic_8")
  shapeNode:addChild(role1)
  shapeNode:setPosition(600, y_up)
  g_TestShapeNodeList[#g_TestShapeNodeList + 1] = role1
  local shadow = display.newSprite("xiyou/pic/pic_shapeShadow.png")
  shapeNode:addChild(shadow, -1)
  role1:testMagicAni()
  local shapeNode = display.newNode()
  g_ParentNode:addChild(shapeNode)
  local role1, x, y = testWarBody.new(testShapeId, 4, "magic_4")
  shapeNode:addChild(role1)
  shapeNode:setPosition(800, y_up)
  g_TestShapeNodeList[#g_TestShapeNodeList + 1] = role1
  local shadow = display.newSprite("xiyou/pic/pic_shapeShadow.png")
  shapeNode:addChild(shadow, -1)
  role1:testMagicAni()
  local shapeNode = display.newNode()
  g_ParentNode:addChild(shapeNode)
  local role1, x, y = testWarBody.new(testShapeId, 8, "hurt_8")
  shapeNode:addChild(role1)
  shapeNode:setPosition(600, y_down)
  g_TestShapeNodeList[#g_TestShapeNodeList + 1] = role1
  local shadow = display.newSprite("xiyou/pic/pic_shapeShadow.png")
  shapeNode:addChild(shadow, -1)
  role1:testHurtAni()
  local shapeNode = display.newNode()
  g_ParentNode:addChild(shapeNode)
  local role1, x, y = testWarBody.new(testShapeId, 4, "hurt_4")
  shapeNode:addChild(role1)
  shapeNode:setPosition(800, y_down)
  g_TestShapeNodeList[#g_TestShapeNodeList + 1] = role1
  local shadow = display.newSprite("xiyou/pic/pic_shapeShadow.png")
  shapeNode:addChild(shadow, -1)
  role1:testHurtAni()
end
function testShapeID_Npc()
  g_ParentNode:removeAllChildren()
  local testShapeId = g_TestShape
  local idtxt = ui.newTTFLabel({
    text = tostring(testShapeId),
    size = 22,
    font = KANG_TTF_FONT,
    color = ccc3(255, 0, 0)
  })
  g_ParentNode:addChild(idtxt)
  idtxt:setPosition((btn_x1 + btn_x2) / 2, btn_y)
  local shapeNode = display.newNode()
  g_ParentNode:addChild(shapeNode)
  local role1, x, y = createBodyByShape(testShapeId)
  shapeNode:addChild(role1)
  shapeNode:setPosition(130, 400)
  role1:playAniWithName("stand_5", -1)
  role1:setPosition(x, y)
  local shadow = display.newSprite("xiyou/pic/pic_shapeShadow.png")
  shapeNode:addChild(shadow, -1)
  local width = data_Shape[testShapeId].bodyWidth
  local hLayer = CCLayerColor:create(ccc4(0, 0, 200, 180))
  hLayer:setPosition(-width / 2, -40)
  hLayer:setContentSize(CCSize(width, 10))
  shapeNode:addChild(hLayer, 99)
  local height = data_Shape[testShapeId].bodyHeight
  local hLayer = CCLayerColor:create(ccc4(0, 0, 200, 180))
  hLayer:setPosition(60, 0)
  hLayer:setContentSize(CCSize(10, height))
  shapeNode:addChild(hLayer, 99)
end
