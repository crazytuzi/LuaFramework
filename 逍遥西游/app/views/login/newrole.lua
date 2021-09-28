MinLengthOfName = 1
MaxLengthOfName = 5
CNewRole = class("CNewRole", CcsSceneView)
function CNewRole:ctor(roleIdx)
  CNewRole.super.ctor(self, "views/newrole_new.json")
  clickArea_check.extend(self)
  self.m_RoleIndex = roleIdx
  self.m_RandomTimes = 0
  self.m_EditName = 0
  local btnBatchListener = {
    btn_back = {
      listener = handler(self, self.Btn_Back),
      variName = "btn_back"
    },
    btn_create = {
      listener = handler(self, self.Btn_Create),
      variName = "btn_create"
    },
    btn_pre = {
      listener = handler(self, self.Btn_Pre),
      variName = "btn_pre"
    },
    btn_next = {
      listener = handler(self, self.Btn_Next),
      variName = "btn_next"
    },
    btn_random = {
      listener = handler(self, self.Btn_Random),
      variName = "btn_random"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  local btn_back_txt = display.newSprite("views/common/btn/btntxt_back.png")
  self.btn_back:addNode(btn_back_txt)
  btn_back_txt:setPosition(ccp(-5, 20))
  local btn_back_create = display.newSprite("views/common/btn/btntxt_create.png")
  self.btn_create:addNode(btn_back_create)
  btn_back_create:setScaleX(-1)
  btn_back_create:setPosition(ccp(-5, 20))
  self.m_RoleTypeId = {
    11001,
    11006,
    12001,
    12006,
    13001,
    13008,
    14001,
    14003
  }
  self.m_RaceRole = {
    [11001] = RACE_REN,
    [11006] = RACE_REN,
    [12001] = RACE_XIAN,
    [12006] = RACE_XIAN,
    [13001] = RACE_MO,
    [13008] = RACE_MO,
    [14001] = RACE_GUI,
    [14003] = RACE_GUI
  }
  self.m_MinLengOfName = MinLengthOfName
  self.m_MaxLengOfName = MaxLengthOfName
  self.rootlayer = self:getNode("rootlayer")
  self.race_xian = self:getNode("race_xian")
  self.race_ren = self:getNode("race_ren")
  self.race_mo = self:getNode("race_mo")
  self.race_gui = self:getNode("race_gui")
  self.role_aureole = self:getNode("role_aureole")
  self.role_aureole:setVisible(false)
  self.bg2 = self:getNode("bg2")
  self.bg3 = self:getNode("bg3")
  self.bg_1 = self:getNode("bg_1")
  self.bg_2 = self:getNode("bg_2")
  self.bg_3 = self:getNode("bg_3")
  self.bg_4 = self:getNode("bg_4")
  self.namebg = self:getNode("namebg")
  self.layerinfo = self:getNode("layerinfo")
  self.input_name = self:getNode("input_name")
  self.bg_1:setVisible(false)
  self.bg_2:setVisible(false)
  self.bg_3:setVisible(false)
  self.bg_4:setVisible(false)
  self:adjustWithLogicSize()
  local size = self.input_name:getContentSize()
  TextFieldEmoteExtend.extend(self.input_name, nil, {
    width = size.width,
    align = CRichText_AlignType_Center
  }, self.namebg)
  self.input_name:setMaxLengthEnabled(true)
  self.input_name:setMaxLength(self.m_MaxLengOfName)
  self.input_name:SetFieldTextOffY(0)
  self.input_name:SetKeyBoardListener(handler(self, self.onKeyBoardListener))
  local parent = self.role_aureole:getParent()
  local zOrder = self.role_aureole:getZOrder()
  local x, y = self.role_aureole:getPosition()
  local role_aureole = CreateSeqAnimation("xiyou/ani/role_aureole.plist", -1, nil, nil, nil, 6)
  parent:addNode(role_aureole, zOrder)
  role_aureole:setPosition(x + AUREOLE_OFF_X, y + AUREOLE_OFF_Y)
  local shadow = display.newSprite("xiyou/pic/pic_shapeShadow.png")
  parent:addNode(shadow, zOrder)
  shadow:setPosition(x, y)
  local rdIndex = math.random(1, #self.m_RoleTypeId)
  self:InitAllRoleImage(rdIndex)
  self:SetLastHeroIndex(rdIndex)
  self:Btn_Random()
  self.rootlayer:setTouchEnabled(true)
  self.rootlayer:addTouchEventListener(function(touchObj, t)
    if t == TOUCH_EVENT_BEGAN then
      self.m_LastPosX = self.rootlayer:getTouchStartPos().x
      self.m_HasMoved = false
      self.m_LastMoveTime = 0
      self.m_MoveSpaceTime = -1
      self.m_LastMoveSpaceX = 0
      self.m_TouchIsEffect = true
      local x, y = self.btn_next:getPosition()
      if x < self.m_LastPosX then
        self.m_TouchIsEffect = false
      end
    elseif t == TOUCH_EVENT_MOVED then
      if not self.m_TouchIsEffect then
        return
      end
      if not self.m_HasMoved then
        local sPos = self.rootlayer:getTouchStartPos()
        local mPos = self.rootlayer:getTouchMovePos()
        if math.abs(sPos.x - mPos.x) + math.abs(sPos.y - mPos.y) > 10 then
          self.m_HasMoved = true
        end
        local movePosX = self.rootlayer:getTouchMovePos().x
        self.m_LastPosX = movePosX
      else
        local movePosX = self.rootlayer:getTouchMovePos().x
        self.m_LastMoveSpaceX = movePosX - self.m_LastPosX
        self.m_LastPosX = movePosX
        local curTime = cc.net.SocketTCP.getTime()
        self.m_MoveSpaceTime = curTime - self.m_LastMoveTime
        self.m_LastMoveTime = curTime
        self:checkMoveRole(self.m_LastMoveSpaceX)
      end
    elseif t == TOUCH_EVENT_ENDED or t == TOUCH_EVENT_CANCELED then
      if not self.m_TouchIsEffect then
        return
      end
      local curTime = cc.net.SocketTCP.getTime()
      self.m_MoveSpaceTime = curTime - self.m_LastMoveTime
      local endPos = self.rootlayer:getTouchEndPos()
      if 0 < self.m_MoveSpaceTime and self.m_MoveSpaceTime < 0.1 and math.abs(self.m_LastMoveSpaceX) > 15 then
        if 0 < self.m_LastMoveSpaceX then
          self:ShowPre()
        else
          self:ShowNext()
        end
      else
        self:checkEndRole()
      end
    end
  end)
end
function CNewRole:onKeyBoardListener(event)
  if event == TEXTFIELDEXTEND_EVENT_TEXT_CHANGE and not self.m_IsRandoming then
    self.m_EditName = 1
  end
end
function CNewRole:adjustWithLogicSize()
  for i = 1, 4 do
    local obj = self:getNode(string.format("bg_%d", i))
    local size = obj:getContentSize()
    if size.width < display.width or size.height < display.height then
      obj:setSize(CCSize(display.width, display.height))
    end
  end
  local x, y = self.bg2:getPosition()
  local size = self.bg2:getContentSize()
  local basex = 666
  local baseoffx = 960 - basex
  local basew = size.width - baseoffx
  local x = display.width - baseoffx - basew * (display.width - 960) / 176
  local pos = self.rootlayer:convertToNodeSpace(ccp(display.width - size.width, display.height / 2))
  if x < pos.x then
    x = pos.x
  end
  self.bg2:setPosition(ccp(x, pos.y))
  local size = self.bg3:getContentSize()
  local s = (display.height - 20) / size.height
  self.bg3:setScaleY(s)
  if display.height > 640 then
    for _, roleType in pairs(self.m_RoleTypeId) do
      local obj = self:getNode(string.format("desc_%d", roleType))
      local x, y = obj:getPosition()
      local parent = obj:getParent()
      local pos = parent:convertToNodeSpace(ccp(0, display.height - 95))
      obj:setPosition(ccp(x, pos.y))
    end
  end
  if display.height > 640 then
    for _, obj in pairs({
      self.race_ren,
      self.race_mo,
      self.race_xian,
      self.race_gui
    }) do
      if obj then
        local x, y = obj:getPosition()
        local parent = obj:getParent()
        local pos = parent:convertToNodeSpace(ccp(0, display.height - 95))
        obj:setPosition(ccp(x, pos.y))
      end
    end
  end
  local pos = self.rootlayer:convertToNodeSpace(ccp(display.width, 0))
  local nx = (pos.x + x + 70) / 2
  local x, y = self.layerinfo:getPosition()
  self.layerinfo:setPosition(ccp(nx, y))
  local parent = self.btn_next:getParent()
  local pos = parent:convertToNodeSpace(ccp(0, display.height / 2))
  local x, y = self.bg2:getPosition()
  self.btn_next:setPosition(ccp(x + 95, pos.y))
  local parent = self.btn_pre:getParent()
  local pos = parent:convertToNodeSpace(ccp(40, display.height / 2))
  self.btn_pre:setPosition(ccp(pos.x, pos.y))
  local x1, y1 = self.btn_back:getPosition()
  local x1, y1 = self.btn_back:getPosition()
  local size = self.btn_back:getContentSize()
  local x2, y2 = self.bg2:getPosition()
  local x, y = self.namebg:getPosition()
  self.namebg:setPosition(ccp((x1 + size.width / 2 + x2) / 2, y))
end
function CNewRole:checkMoveRole(movex)
  if self.m_LastRoleImage == nil or self.m_LastRoleImage:getIsAction() then
    return
  end
  local x, y = self.m_LastRoleImage:getPosition()
  x = x + movex
  self.m_LastRoleImage:setPosition(ccp(x, y))
  local x1, y1 = self.btn_pre:getPosition()
  local x2, y2 = self.btn_next:getPosition()
  local midx = (x1 + x2) / 2
  if x > (midx + x2) / 2 then
    self:ShowPre()
    self.m_TouchIsEffect = false
  elseif x < (midx + x1) / 2 then
    self:ShowNext()
    self.m_TouchIsEffect = false
  end
end
function CNewRole:checkEndRole()
  if self.m_LastRoleImage == nil or self.m_LastRoleImage:getIsAction() then
    return
  end
  local x1, y1 = self.btn_pre:getPosition()
  local x2, y2 = self.btn_next:getPosition()
  local midx, midy = (x1 + x2) / 2, (y1 + y2) / 2
  self.m_LastRoleImage:setBackAction(ccp(midx, midy))
end
function CNewRole:InitAllRoleImage(rdIndex)
  self.m_RoleImage = {}
  local dynamicLoad = false
  local n = #self.m_RoleTypeId
  for _, i in pairs({
    0,
    1,
    -1,
    2,
    -2,
    3,
    -3,
    4
  }) do
    local j = rdIndex + i
    if j < 1 then
      j = rdIndex + i + n
    elseif n < j then
      j = rdIndex + i - n
    end
    local roleType = self.m_RoleTypeId[j]
    local obj = CNewRoleShow.new(roleType, dynamicLoad)
    self.rootlayer:addChild(obj, 1)
    obj:setVisible(false)
    self.m_RoleImage[roleType] = obj
    dynamicLoad = true
  end
end
function CNewRole:ShowRoleImage(roleType, isNext, forceOri)
  local x1, y1 = self.btn_pre:getPosition()
  local x2, y2 = self.btn_next:getPosition()
  local midx, midy = (x1 + x2) / 2, (y1 + y2) / 2
  if self.m_LastRoleImage ~= nil then
    local hidePos
    if isNext then
      hidePos = ccp(x1, y1 - 200)
    else
      hidePos = ccp(x2, y2 - 200)
    end
    if forceOri == true then
      local startPos = ccp(midx, midy)
      self.m_LastRoleImage:setPosition(startPos)
      self.m_LastRoleImage:setScale(1)
    end
    self.m_LastRoleImage:setHideAction(hidePos)
    self.m_LastRoleImage = nil
  end
  local roleImg = self.m_RoleImage[roleType]
  if roleImg then
    local showPos = ccp(midx, midy)
    if isNext == nil then
      roleImg:setVisible(true)
      roleImg:setPosition(showPos)
    else
      local startPos
      if isNext then
        startPos = ccp(x2, y2 - 150)
      else
        startPos = ccp(x1, y1 - 150)
      end
      roleImg:setShowAction(showPos, startPos)
    end
    self.m_LastRoleImage = roleImg
  end
end
function CNewRole:SetLastHeroIndex(index, isNext, forceOri)
  local temp = self.m_LastHeroIndex
  self.m_LastHeroIndex = index
  if self.m_LastHeroIndex ~= temp then
    self:CreateShape()
  end
  local roleType = self.m_RoleTypeId[self.m_LastHeroIndex]
  local race = self.m_RaceRole[roleType]
  self:OnSelectRace(race)
  for _, rType in pairs(self.m_RoleTypeId) do
    self:getNode(string.format("desc_%d", rType)):setVisible(rType == roleType)
    self:getNode(string.format("attr_%d", rType)):setVisible(rType == roleType)
  end
  self:ShowRoleImage(roleType, isNext, forceOri)
end
function CNewRole:getCurrSelectType()
  local roleType = self.m_RoleTypeId[self.m_LastHeroIndex]
  return roleType
end
function CNewRole:CreateShape()
  local roleType = self:getCurrSelectType()
  if self.m_ShapeAni ~= nil then
    if self.m_ShapeAni._addClickWidget then
      self.m_ShapeAni._addClickWidget:removeFromParentAndCleanup(true)
      self.m_ShapeAni._addClickWidget = nil
    end
    if self.m_RoleAni_War then
      self.m_RoleAni_War:removeFromParentAndCleanup(true)
      self.m_RoleAni_War = nil
    end
    self.m_ShapeAni:removeFromParentAndCleanup(true)
    self.m_ShapeAni = nil
  end
  local parent = self.role_aureole:getParent()
  local x, y = self.role_aureole:getPosition()
  local ZOrder = self.role_aureole:getZOrder()
  local offx, offy = 0, nil
  self.m_ShapeAni, offx, offy = createBodyByRoleTypeIDForDlg(roleType)
  self.m_ShapeAni:setPosition(x + offx, y + offy)
  parent:addNode(self.m_ShapeAni, ZOrder + 2)
  self:addclickAniForHeroAni(self.m_ShapeAni, self.role_aureole, nil, nil, nil, nil, nil, 0.5)
end
function CNewRole:OnSelectRace(race)
  self.race_ren:setVisible(race == RACE_REN)
  self.race_mo:setVisible(race == RACE_MO)
  self.race_xian:setVisible(race == RACE_XIAN)
  self.race_gui:setVisible(race == RACE_GUI)
  if self.m_LastSelectRace ~= race then
    if self.m_LastSelectRace == nil then
      for i = 1, 4 do
        local obj = self:getNode(string.format("bg_%d", i))
        obj:setVisible(i == race)
      end
      self.m_LastSelectRace = race
    else
      for i = 1, 4 do
        local obj = self:getNode(string.format("bg_%d", i))
        obj:stopAllActions()
        if i == self.m_LastSelectRace then
          obj:runAction(transition.sequence({
            CCFadeTo:create(0.5, 0),
            CCHide:create()
          }))
        elseif i == race then
          obj:setOpacity(0)
          local z = obj:getZOrder()
          obj:getParent():reorderChild(obj, z + 1)
          obj:runAction(transition.sequence({
            CCShow:create(),
            CCFadeTo:create(0.5, 255)
          }))
        else
          obj:setVisible(false)
        end
      end
      self.m_LastSelectRace = race
    end
  end
end
function CNewRole:Btn_Pre()
  local index = self:correctIndex(self.m_LastHeroIndex - 1)
  self:SetLastHeroIndex(index, false, true)
end
function CNewRole:ShowPre()
  local index = self:correctIndex(self.m_LastHeroIndex - 1)
  self:SetLastHeroIndex(index, false, false)
end
function CNewRole:Btn_Next()
  local index = self:correctIndex(self.m_LastHeroIndex + 1)
  self:SetLastHeroIndex(index, true, true)
end
function CNewRole:ShowNext()
  local index = self:correctIndex(self.m_LastHeroIndex + 1)
  self:SetLastHeroIndex(index, true, false)
end
function CNewRole:correctIndex(index)
  if index < 1 then
    index = #self.m_RoleTypeId
  elseif index > #self.m_RoleTypeId then
    index = 1
  end
  return index
end
function CNewRole:Btn_Random(obj, t)
  self.m_IsRandoming = true
  local roleType = self:getCurrSelectType()
  local data = data_Hero[roleType] or {}
  local sex = data.GENDER or HERO_MALE
  local rdName = ""
  if sex == HERO_MALE then
    rdName = GetRandomName_Male()
  else
    rdName = GetRandomName_Female()
  end
  self.input_name:setMaxLengthEnabled(false)
  self.input_name:SetFieldText(rdName)
  self.input_name:setMaxLengthEnabled(true)
  self.m_LastRandomName = rdName
  self.m_RandomTimes = self.m_RandomTimes + 1
  self.m_IsRandoming = false
end
function CNewRole:Btn_Back(obj, t)
  ShowLoginView(false)
end
function CNewRole:Btn_Create(obj, t)
  local name = self.input_name:GetFieldText()
  local nLen = GetMyUTF8Len_ex(name)
  if nLen < self.m_MinLengOfName then
    ShowNotifyTips(string.format("名字不能少于%d个字", self.m_MinLengOfName))
    return
  end
  if nLen > self.m_MaxLengOfName then
    ShowNotifyTips(string.format("名字不能多于%d个字", self.m_MaxLengOfName))
    return
  end
  if string.find(name, " ") ~= nil then
    ShowNotifyTips("名字不能包含空格")
    return
  end
  if string.find(name, "#") ~= nil then
    ShowNotifyTips("名字不能包含#")
    return
  end
  if self.m_LastRandomName ~= name and not checkText_DFAFilter(name) then
    ShowNotifyTips("名字不合法")
    return
  end
  local roleType = self:getCurrSelectType()
  g_DataMgr:EnterGameWithCreateRole(roleType, name, self.m_RoleIndex, self.m_RandomTimes, self.m_EditName)
  self.m_RandomTimes = 0
  self.m_EditName = 0
end
function CNewRole:Clear()
  self.input_name:CloseTheKeyBoard()
  self.input_name:ClearTextFieldExtend()
end
CNewRoleShow = class("CNewRoleShow", function()
  return Widget:create()
end)
function CNewRoleShow:ctor(roleType, dynamicLoad)
  self.m_RoleType = roleType
  self.m_IsAction = false
  self.m_HasCleanUp = false
  local namex, namey = -245, -40
  local rolex, roley = 0, 0
  local shadowData = {
    30,
    -270,
    5,
    5
  }
  if roleType == 11001 then
    namex = -235
    namey = 66
    rolex = 0
    roley = 0
    shadowData = {
      25,
      -255,
      1,
      1
    }
  elseif roleType == 11006 then
    namey = 15
    rolex = 50
    roley = 25
    shadowData = {
      10,
      -260,
      1,
      1
    }
  elseif roleType == 12001 then
    rolex = 30
    roley = -10
    shadowData = {
      25,
      -260,
      1,
      1
    }
  elseif roleType == 12006 then
    namex = -240
    namey = 50
    rolex = 15
    roley = -5
    shadowData = {
      20,
      -270,
      0.7,
      0.7
    }
  elseif roleType == 13001 then
    namey = 20
    rolex = 35
    roley = -10
    shadowData = {
      30,
      -250,
      1,
      1
    }
  elseif roleType == 13008 then
    namex = -225
    namey = 82
    rolex = 25
    roley = 5
    shadowData = {
      30,
      -260,
      0.7,
      0.7
    }
  elseif roleType == 14001 then
    namey = 65
    rolex = 20
    roley = 5
    shadowData = {
      30,
      -260,
      1,
      1
    }
  elseif roleType == 14003 then
    namex = -245
    namey = 42
    rolex = 15
    roley = -10
    shadowData = {
      30,
      -260,
      1,
      1
    }
  end
  self.m_RolePos = ccp(rolex, roley)
  local nameImgPath = string.format("views/newrole/newrolename_%d.png", self.m_RoleType)
  local fullPath = CCFileUtils:sharedFileUtils():fullPathForFilename(nameImgPath)
  if not os.exists(fullPath) then
    nameImgPath = "views/newrole/newrolename_12001.png"
  end
  local nameImg = display.newSprite(nameImgPath)
  self:addNode(nameImg, 3)
  self.m_NameImg = nameImg
  nameImg:setPosition(ccp(namex, namey))
  if dynamicLoad == true then
    local path = string.format("views/newrole/newrole_%d.png", self.m_RoleType)
    local fullPath = CCFileUtils:sharedFileUtils():fullPathForFilename(path)
    if not os.exists(fullPath) then
      path = "views/newrole/newrole_12001.png"
    end
    addDynamicLoadTexture(path, function(handlerName, texture)
      print("------>>异步加载:", self.m_RoleType)
      if not self.m_HasCleanUp then
        self:createImage()
      end
    end, {})
  else
    self:createImage()
  end
  self.m_ShadowImg = display.newSprite("views/newrole/newroleShadow.png")
  self:addNode(self.m_ShadowImg, 1)
  local x, y, sx, sy = unpack(shadowData, 1, 4)
  self.m_ShadowImg:setPosition(ccp(x, y))
  self.m_ShadowImg:setScaleX(sx)
  self.m_ShadowImg:setScaleY(sy)
  self:setNodeEventEnabled(true)
end
function CNewRoleShow:createImage()
  if self.m_RoleImg ~= nil then
    return
  end
  local path = string.format("views/newrole/newrole_%d.png", self.m_RoleType)
  local fullPath = CCFileUtils:sharedFileUtils():fullPathForFilename(path)
  if not os.exists(fullPath) then
    path = "views/newrole/newrole_12001.png"
  end
  local roleImg = display.newSprite(path)
  self:addNode(roleImg, 2)
  self.m_RoleImg = roleImg
  roleImg:setPosition(self.m_RolePos)
end
function CNewRoleShow:setHideAction(hidePos)
  if self.m_RoleImg == nil then
    print("------>>强制加载1:", self.m_RoleType)
    self:createImage()
  end
  local dt = 0.3
  self:stopAllActions()
  self.m_NameImg:stopAllActions()
  self.m_RoleImg:stopAllActions()
  self:runAction(CCEaseIn:create(CCMoveTo:create(dt, hidePos), 1))
  self:runAction(transition.sequence({
    CCScaleTo:create(dt, 0.2),
    CCHide:create(),
    CCCallFunc:create(function()
      self.m_IsAction = false
    end)
  }))
  self.m_NameImg:runAction(CCFadeOut:create(dt))
  self.m_RoleImg:runAction(CCFadeOut:create(dt))
  self.m_IsAction = true
end
function CNewRoleShow:setShowAction(showPos, startPos)
  if self.m_RoleImg == nil then
    print("------>>强制加载2:", self.m_RoleType)
    self:createImage()
  end
  local dt = 0.3
  self:stopAllActions()
  self.m_NameImg:stopAllActions()
  self.m_RoleImg:stopAllActions()
  self:setPosition(startPos)
  self:setScale(0.2)
  self:setVisible(true)
  self.m_NameImg:setOpacity(0)
  self.m_RoleImg:setOpacity(0)
  self:runAction(CCEaseIn:create(CCMoveTo:create(dt, showPos), 1))
  self:runAction(transition.sequence({
    CCScaleTo:create(dt, 1),
    CCCallFunc:create(function()
      self.m_IsAction = false
    end)
  }))
  self.m_NameImg:runAction(CCFadeIn:create(dt))
  self.m_RoleImg:runAction(CCFadeIn:create(dt))
  self.m_IsAction = true
end
function CNewRoleShow:setBackAction(showPos)
  if self.m_RoleImg == nil then
    print("------>>强制加载3:", self.m_RoleType)
    self:createImage()
  end
  local dt = 0.3
  self:stopAllActions()
  self:runAction(transition.sequence({
    CCMoveTo:create(dt, showPos),
    CCCallFunc:create(function()
      self.m_IsAction = false
    end)
  }))
  self.m_IsAction = true
end
function CNewRoleShow:getIsAction()
  return self.m_IsAction
end
function CNewRoleShow:onCleanup()
  self.m_HasCleanUp = true
end
