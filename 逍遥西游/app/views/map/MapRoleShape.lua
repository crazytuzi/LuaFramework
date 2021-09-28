DefineRoleMoveSpeedInMap = 180
NormalSpeedNum = 1
JSFSpeedNum = 1.5
ShowFootPrintPerTime = 0.33
ShowHeadEffectPerTime = 5
ShowBodyEffectPerTime = 5
MapRoleNameZOrder = 100
MapRoleZOrder = 10
local DirrectConvert = {
  [6] = 4,
  [7] = 3,
  [8] = 2
}
local func_setPosition = Widget.setPosition
CMapRoleShape = class("CMapRoleShape", function()
  return Widget:create()
end)
function CMapRoleShape:ctor(shapeId, roleShapeType, posChangedListener, opaque)
  self:setNodeEventEnabled(true)
  self.m_ShapeId = shapeId
  self.m_MapRoleShapeType = roleShapeType
  self.m_Status = nil
  self.m_Dir = -1
  self.m_CurAniName = nil
  self.m_IsExist = true
  self.m_ChiBangId = 0
  self.m_RanColorList = {
    0,
    0,
    0
  }
  self.m_state = 1
  self.m_IsCreatedRole = false
  self.m_idForDynamicCreateAndDelete = nil
  self.m_isDynamicCreateAndDelete = g_MapMgr:detectRoleNeedDynamicCreateAndRelease(self, self.m_MapRoleShapeType)
  self.m_Opaque = opaque
  if self.m_Opaque == nil or self.m_Opaque == 0 then
    self.m_Opaque = 100
  end
  if self.getPlayerMapZuoqiTypeId then
    local zqShapeId = self:getPlayerMapZuoqiTypeId()
    if zqShapeId == nil or zqShapeId == 0 then
      self.m_ZuoqiShapeID = 0
    else
      self.m_ZuoqiShapeID = zqShapeId
    end
  end
  self:createShape()
  local function listener(event)
    local name = event.name
    if name == "cleanup" then
      self.m_IsExist = false
      self:Clear()
    end
  end
  local handle = self:addNodeEventListener(cc.NODE_EVENT, listener)
  self.m_NameTxt = nil
  self.m_NamePosDy = 0
  self.m_RoleName = nil
  self.m_IsOpaque = nil
  self.m_PosChangedListener = posChangedListener
  self.m_RoleMoveSpeed = DefineRoleMoveSpeedInMap
  self:setMoveSpeed()
  self.m_MoveStartPos = nil
  self.m_MoveDstPos = nil
  self.m_MoveDeltaDis = nil
  self.m_MoveTotalTimes = nil
  self.m_MoveTimes = 0
  self.m_Moving = false
  self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.frameUpdate))
  self.m_FollowingRoleIns = nil
  self.m_FollowToRoleIns = nil
  self.m_FollowToRoleInsStatus = ROLE_STATE_STAND
  self.m_MyTeamCaptainRoleIns = nil
  self.m_TopStatus = {}
  self.m_CurMissionStatus = {}
  self.m_IsRoutingForCaptain = false
  self.m_SyncParamCache = {}
  self.m_IsSpecialShapeFromLocalPlayer = false
end
function CMapRoleShape:OnMessage(msgSID, ...)
  if msgSID == MsgID_HeroUpdate then
    self:_setSpecialShapeCololfulFromLocalPlayer()
  end
end
function CMapRoleShape:getShapeOpacity()
  return 255
end
function CMapRoleShape:setMoveSpeed()
  self.m_RoleMoveSpeed = DefineRoleMoveSpeedInMap
end
function CMapRoleShape:setIsLocalPlayer(flag)
  self.m_IsLocalPlayer = flag
end
function CMapRoleShape:onEnterEvent()
  self:scheduleUpdate()
end
function CMapRoleShape:getShapeId()
  return self.m_ShapeId
end
function CMapRoleShape:getMapRoleType()
  return self.m_MapRoleShapeType
end
function CMapRoleShape:getShapeAni()
  return self.m_ShapeAni
end
function CMapRoleShape:setPosition(...)
  func_setPosition(self, ...)
  local x, y = self:getPosition()
  if self.m_PosChangedListener ~= nil then
    self.m_PosChangedListener(self, x, y)
  end
  if self.m_FollowingRoleIns then
    self.m_FollowingRoleIns:FollowToRolePosChanged(self.m_Dir, x, y)
  end
  if self.m_FollowToRoleIns and self.m_MapRoleShapeType == LOGICTYPE_HERO then
    g_MapMgr:saveFollowingPlayerPos(self.m_PlayerId, x, y)
  end
end
function CMapRoleShape:setHide(isHide)
  if isHide then
    for k, node in pairs(self.m_TopStatus) do
      node:setVisible(false)
    end
  end
  self:setEnabled(not isHide)
end
function CMapRoleShape:getHide()
  return not self:isEnabled()
end
function CMapRoleShape:createShape()
  self.m_AniSize = data_getBodySizeByShape(self:getRoleShapeForCreateImage())
  if self.m_AniSize.height == 0 then
    self.m_AniSize.height = 120
  end
  if self.m_AniSize.width == 0 then
    self.m_AniSize.width = 80
  end
  if self:getIsBSFing() then
  elseif self.m_ZuoqiShapeID ~= 0 and self.m_ZuoqiShapeID ~= nil then
    self.m_AniSize.height = self.m_AniSize.height + 60
    self.m_AniSize.width = self.m_AniSize.width + 100
  end
  self.m_BodyHeight = self.m_AniSize.height
  local touchWidth = self.m_AniSize.width
  if touchWidth > 80 then
    touchWidth = 80
  end
  self.m_TouchSize = CCSize(touchWidth, self.m_BodyHeight)
  if self.m_Status == nil then
    self.m_Status = ROLE_STATE_STAND
    self.m_Dir = math.floor(math.random(1, 8))
    if self:getIsBSFing() then
    elseif self.m_ZuoqiShapeID ~= 0 and self.m_ZuoqiShapeID ~= nil then
      self.m_Dir = DIRECTIOIN_RIGHTDOWN
    end
  end
  if self.m_ShadowImg == nil then
    self.m_ShadowImg = display.newSprite("xiyou/pic/pic_shapeShadow.png")
    self:addNode(self.m_ShadowImg, 9)
  end
  if not self.m_isDynamicCreateAndDelete then
    self:createShapeAsync()
  end
  self:updateTopStatusPos()
end
function CMapRoleShape:createShapeAsync()
  self.m_IsCreatedRole = true
  local compatible = self.m_MapRoleShapeType ~= LOGICTYPE_NPC and self.m_MapRoleShapeType ~= LOGICTYPE_MONSTER
  local path, x, y = data_getBodyPathByShape(self:getRoleShapeForCreateImage(), compatible)
  if self:getIsBSFing() then
  elseif self.m_ZuoqiShapeID ~= 0 and self.m_ZuoqiShapeID ~= nil then
    path, x, y = data_getBodyPathByZqShape(shapeAfterBianShen, compatible)
  end
  if type(path) == "table" then
    local pathList = path
    path = {}
    for _, onePath in pairs(pathList) do
      local newPath = onePath
      if onePath:sub(-6) == ".plist" then
        newPath = onePath:sub(1, -6) .. "png"
      else
        newPath = onePath .. ".png"
      end
      path[#path + 1] = newPath
    end
  elseif path:sub(-6) == ".plist" then
    path = path:sub(1, -6) .. "png"
  else
    path = path .. ".png"
  end
  local dynamicLoadTextureMode = getBodyDynamicLoadTextureMode(self:getRoleShapeForCreateImage())
  if self:getIsBSFing() == false then
    dynamicLoadTextureMode = kCCTexture2DPixelFormat_RGBA4444
  end
  addDynamicLoadTexture(path, function(handlerName, texture)
    if self.m_IsExist ~= true then
      return
    end
    if self.m_IsCreatedRole == false then
      return
    end
    if self.m_ShapeAni ~= nil then
      self.m_ShapeAni:removeFromParent()
      self.m_ShapeAni = nil
    end
    self:deleteZuoQi()
    self.m_DirFor_ShapeUseWarForWalk = nil
    if self.m_Dir then
      self.m_DirFor_ShapeUseWarForWalk = self:getNewDirForUseWar2Walk(self.m_Dir, self.m_DirFor_ShapeUseWarForWalk)
    end
    if self:getIsBSFing() then
      self.m_ShapeAni, offx, offy = createBodyByShape(self:getRoleShapeForCreateImage(), compatible)
    elseif self.m_ZuoqiShapeID ~= 0 and self.m_ZuoqiShapeID ~= nil then
      self.m_ShapeAni, offx, offy = createBodyByZqShape(self:getRoleShapeForCreateImage(), compatible, self.m_RanColorList, self.m_DirFor_ShapeUseWarForWalk)
    else
      self.m_ShapeAni, offx, offy = createBodyByShape(self:getRoleShapeForCreateImage(), compatible, self.m_RanColorList)
    end
    self.m_ShapeAni:setPosition(offx, offy)
    self:addNode(self.m_ShapeAni, MapRoleZOrder)
    local opa = self:getShapeOpacity()
    self.m_ShapeAni:setOpacity(opa)
    if self.m_ZuoqiShapeID ~= 0 and self.m_ZuoqiShapeID ~= nil then
      self:createZuoQi()
    end
    self:flushAni(true, true)
    if self.m_ChiBangId ~= 0 then
      self:createChiBang()
    end
    local isOpaque = self.m_IsOpaque
    self.m_IsOpaque = nil
    if isOpaque ~= nil then
      self:changeOpaque(isOpaque)
    end
    self:OnShapeAniLoadFinish()
  end, {pixelFormat = dynamicLoadTextureMode})
end
function CMapRoleShape:OnShapeAniLoadFinish()
  if self.m_RoleName ~= nil and self.m_NameTxt == nil then
    self:setRoleName(self.m_RoleName, self.m_RoleNameColor)
  end
end
function CMapRoleShape:flushAni(isInit, force)
  local shapeID = self:getRoleShapeForCreateImage()
  if SHAPE_CHANGE_WALK_IN_MAP_USEWAR_DICT[shapeID] ~= true then
    if self.m_ShapeAni ~= nil then
      local d = self.m_Dir
      if d >= 6 then
        d = DirrectConvert[d]
        self.m_ShapeAni:setScaleX(-1)
        if self.m_ChiBangAni then
          self.m_ChiBangAni:setScaleX(-1)
        end
        if self.m_ZuoqiAni then
          self.m_ZuoqiAni:setScaleX(-1)
        end
      else
        self.m_ShapeAni:setScaleX(1)
        if self.m_ChiBangAni then
          self.m_ChiBangAni:setScaleX(1)
        end
        if self.m_ZuoqiAni then
          self.m_ZuoqiAni:setScaleX(1)
        end
      end
      local aniName = string.format("%s_%d", self.m_Status, d)
      if self.m_CurAniName ~= aniName or force == true then
        self.m_ShapeAni:playAniWithName(aniName, -1)
        if self.m_ChiBangAni then
          self.m_ChiBangAni:SetActAndDir(self.m_Status, d)
        end
        if self.m_ZuoqiAni then
          self.m_ZuoqiAni:SetActAndDir(self.m_Status, d)
        end
        self.m_CurAniName = aniName
        if isInit then
          self.m_ShapeAni:setVisible(false)
          if self.m_ChiBangAni then
            local v = self:getChiBangVisible()
            self.m_ChiBangAni:setVisible(v)
          end
          if self.m_ZuoqiAni then
            self.m_ZuoqiAni:setVisible(false)
          end
          scheduler.performWithDelayGlobal(function()
            if self.m_ShapeAni then
              self.m_ShapeAni:setVisible(true)
            end
            if self.m_ZuoqiAni then
              self.m_ZuoqiAni:setVisible(true)
            end
            if self.m_ChiBangAni then
              local v = self:getChiBangVisible()
              self.m_ChiBangAni:setVisible(v)
            end
          end, 0.001)
        end
      end
      if self.m_ChiBangAni then
        local temp = string.format("%s_%d", self.m_Status, self.m_Dir)
        local off = data_getChiBangOffInfo(self:getRoleShapeForCreateImage(), temp)
        self.m_ChiBangAni:setPosition(ccp(off[1], off[2]))
      end
      self:updateZuoqiDelPosition()
    end
  elseif self.m_ShapeAni ~= nil then
    local d = self.m_Dir
    local tempDir = self:getNewDirForUseWar2Walk(d, self.m_DirFor_ShapeUseWarForWalk)
    local tempScale = 1
    if tempDir == DIRECTIOIN_RIGHTDOWN then
      if d >= 6 then
        tempScale = -1
      else
        tempScale = 1
      end
    elseif d >= 6 then
      tempScale = 1
    else
      tempScale = -1
    end
    if (self.m_Dir == DIRECTIOIN_DOWN or self.m_Dir == DIRECTIOIN_UP) and self.m_ScaleFor_ShapeUseWarForWalk then
      self.m_ShapeAni:setScaleX(self.m_ScaleFor_ShapeUseWarForWalk)
    else
      self.m_ShapeAni:setScaleX(tempScale)
      self.m_ScaleFor_ShapeUseWarForWalk = tempScale
    end
    if self.m_DirFor_ShapeUseWarForWalk ~= tempDir then
      self:createShape()
      return
    end
    local aniName = string.format("%s_%d", "guard", tempDir)
    if self.m_CurAniName ~= aniName or force == true then
      self.m_ShapeAni:playAniWithName(aniName, -1)
      if self.m_ChiBangAni then
        self.m_ChiBangAni:SetActAndDir(self.m_Status, d)
      end
      if self.m_ZuoqiAni then
        self.m_ZuoqiAni:SetActAndDir(self.m_Status, d)
      end
      self.m_CurAniName = aniName
    end
    if self.m_ChiBangAni then
      self.m_ChiBangAni:setVisible(false)
    end
  end
end
function CMapRoleShape:getNewDirForUseWar2Walk(dir, oldWarDir)
  local tempDir = DIRECTIOIN_FOR_USEWAR[dir] or DIRECTIOIN_RIGHTDOWN
  if oldWarDir then
    if dir == DIRECTIOIN_RIGHT then
      return oldWarDir
    elseif dir == DIRECTIOIN_LEFT then
      return oldWarDir
    end
  end
  return tempDir
end
function CMapRoleShape:addTalkMsg(msg, yy)
  if self.m_TalkBubbleObj ~= nil then
    self.m_TalkBubbleObj:removeFromParentAndCleanup(true)
    self.m_TalkBubbleObj = nil
  end
  self.m_TalkBubbleObj = CMapChatBubble.new(msg, yy, handler(self, self.onTalkBubbleClear))
  self:addChild(self.m_TalkBubbleObj, 99)
  self.m_TalkBubbleObj:setPosition(ccp(0, self.m_BodyHeight + 10))
end
function CMapRoleShape:onTalkBubbleClear(obj)
  if self.m_TalkBubbleObj == obj then
    self.m_TalkBubbleObj:removeFromParentAndCleanup(true)
    self.m_TalkBubbleObj = nil
  end
end
function CMapRoleShape:getCenterPos()
  local x, y = self:getPosition()
  return x, y + self.m_AniSize.height / 2
end
function CMapRoleShape:getShapeSize()
  return self.m_AniSize
end
function CMapRoleShape:getTouchSize()
  return self.m_TouchSize
end
function CMapRoleShape:setDirAndStatus(dir, status)
  if self:getIsBSFing() then
  elseif self.m_ZuoqiShapeID ~= 0 and self.m_ZuoqiShapeID ~= nil then
    if dir == DIRECTIOIN_DOWN then
      dir = DIRECTIOIN_RIGHTDOWN
    elseif dir == DIRECTIOIN_UP then
      dir = DIRECTIOIN_RIGHTUP
    elseif dir == DIRECTIOIN_RIGHT or dir == DIRECTIOIN_LEFT then
      dir = DIRECTIOIN_RIGHTDOWN
    end
  end
  if self.m_Dir ~= dir or self.m_Status ~= status then
    if self.m_Status ~= status then
      self.m_Status = status
      if self.m_FollowingRoleIns then
        self.m_FollowingRoleIns:FollowToRoleStatusChanged(status)
      end
    end
    self.m_Dir = dir
    self:flushAni()
  end
end
function CMapRoleShape:setDirection(dir)
  if self:getIsBSFing() then
  elseif self.m_ZuoqiShapeID ~= 0 and self.m_ZuoqiShapeID ~= nil then
    if dir == DIRECTIOIN_DOWN then
      dir = DIRECTIOIN_RIGHTDOWN
    elseif dir == DIRECTIOIN_UP then
      dir = DIRECTIOIN_RIGHTUP
    elseif dir == DIRECTIOIN_RIGHT or dir == DIRECTIOIN_LEFT then
      dir = DIRECTIOIN_RIGHTDOWN
    end
  end
  if self.m_Dir ~= dir then
    self.m_Dir = dir
    self:flushAni()
  end
end
function CMapRoleShape:getDirection()
  return self.m_Dir
end
function CMapRoleShape:setStatus(status)
  if self.m_Status ~= status then
    self.m_Status = status
    self:flushAni()
    if self.m_FollowingRoleIns then
      self.m_FollowingRoleIns:FollowToRoleStatusChanged(status)
    end
  end
end
function CMapRoleShape:getStatus()
  return self.m_Status
end
function CMapRoleShape:flushtRanColorList()
  print("------>>> flushtRanColorList")
  self:setRanColorList(self.m_RanColorList, true)
end
function CMapRoleShape:setRanColorList(colorList, isForceSet)
  if colorList == nil or colorList == 0 or type(colorList) == "table" and #colorList == 0 then
    colorList = {
      0,
      0,
      0
    }
  end
  if self:getIsBSFing() == true then
    self.m_RanColorList = colorList
    if self.m_ShapeAni then
      SetOneBodyChangeColor(self.m_ShapeAni, self:getRoleShapeForCreateImage(), {
        0,
        0,
        0
      })
    end
    return
  end
  if colorList == nil or colorList == 0 or type(colorList) == "table" and #colorList == 0 then
    colorList = {
      0,
      0,
      0
    }
  end
  if isForceSet or not isListEqual(self.m_RanColorList, colorList) then
    self.m_RanColorList = colorList
    if self.m_ShapeAni then
      SetOneBodyChangeColor(self.m_ShapeAni, self:getRoleShapeForCreateImage(), colorList)
    end
  end
end
function CMapRoleShape:getRoleShapeForCreateImage()
  return self.m_ShapeId
end
function CMapRoleShape:getIsBSFing()
  return false
end
function CMapRoleShape:changeOpaque(isOpaque)
  if self.m_ShapeAni ~= nil then
    if self.m_IsOpaque ~= isOpaque then
      self.m_IsOpaque = isOpaque
      local opa
      if self.m_IsOpaque then
        local oriOpa = self:getShapeOpacity()
        oriOpa = math.min(oriOpa, 150)
        opa = oriOpa * self.m_Opaque / 100
      else
        local oriOpa = self:getShapeOpacity()
        opa = oriOpa * self.m_Opaque / 100
      end
      self.m_ShapeAni:setOpacity(opa)
      if self.m_ChiBangAni then
        self.m_ChiBangAni:setOpacity(opa)
      end
      if self.m_ZuoqiAni then
        self.m_ZuoqiAni:setOpacity(opa)
      end
    end
  else
    self.m_IsOpaque = isOpaque
  end
end
function CMapRoleShape:setGridPos(gridX, gridY)
  self.m_GridX = gridX
  self.m_GridY = gridY
end
function CMapRoleShape:getGridPos()
  return self.m_GridX, self.m_GridY
end
function CMapRoleShape:setRoleName(name, color)
  self.m_RoleName = name
  self.m_RoleNameColor = color
  if self.m_ShapeAni == nil then
    return
  end
  if self.m_NameTxt == nil then
    local nameTxt = ui.newTTFLabelWithShadow({
      text = name,
      font = KANG_TTF_FONT,
      size = 19
    })
    nameTxt.shadow1:realign(1, 0)
    if color ~= nil then
      nameTxt:setColor(color)
    end
    self:addNode(nameTxt, MapRoleNameZOrder)
    self.m_NameTxt = nameTxt
    local s = nameTxt:getContentSize()
    self.m_NamePosDy = -s.height
    self.m_NameTxt:setPosition(ccp(-s.width / 2, self.m_NamePosDy))
  else
    self.m_NameTxt:setString(name)
  end
end
function CMapRoleShape:getRoleName()
  return self.m_RoleName
end
function CMapRoleShape:getRoleNameTxt()
  return self.m_NameTxt
end
function CMapRoleShape:setChiBang(cbID)
  if cbID == nil or cbID == 0 then
    self.m_ChiBangId = 0
  else
    self.m_ChiBangId = cbID
  end
  if self.m_ZuoqiShapeID == nil or self.m_ZuoqiShapeID == 0 then
  else
    self.m_ChiBangId = 0
  end
  if self.m_ChiBangId ~= 0 then
    self:createChiBang()
  else
    self:deleteChiBang()
  end
end
function CMapRoleShape:setZuoqi(zqID)
  if zqID == nil or zqID == 0 then
    self.m_ZuoqiShapeID = 0
  else
    self.m_ZuoqiShapeID = zqID
  end
  self:createShape()
  if self.m_ZuoqiShapeID ~= 0 then
    self:createZuoQi()
    if self.m_Dir == DIRECTIOIN_LEFT or self.m_Dir == DIRECTIOIN_UP then
      self:setDirAndStatus(DIRECTIOIN_LEFTUP, self.m_Status)
    elseif self.m_Dir == DIRECTIOIN_DOWN or self.m_Dir == DIRECTIOIN_RIGHT then
      self:setDirAndStatus(DIRECTIOIN_RIGHTDOWN, self.m_Status)
    end
  else
    self:deleteZuoQi()
  end
  self:setChiBang(self.m_ChiBangId)
  self:updateZuoqiDelPosition()
end
function CMapRoleShape:createChiBang()
  if self.m_ShapeAni == nil then
    return
  end
  local shapeId = self:getRoleShapeForCreateImage()
  if self.m_ChiBangAni == nil or self.m_ChiBangAni:getShapeId() ~= shapeId then
    self:deleteChiBang()
    local p = self.m_ShapeAni:getParent()
    setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    self.m_ChiBangAni = CChiBang.new(shapeId, self.m_ChiBangId, self.m_ShapeAni)
    resetDefaultAlphaPixelFormat()
  end
  local v = self:getChiBangVisible()
  self.m_ChiBangAni:setVisible(v)
  self:flushAni(false, true)
  local color = data_getWingColor(self.m_ChiBangId)
  self.m_ChiBangAni:setColor(color)
end
function CMapRoleShape:getChiBangVisible()
  local v = false
  if self.m_ShapeAni ~= nil then
    v = self.m_ShapeAni:isVisible()
  end
  local bzhdType, zghdType
  if g_LocalPlayer and self.m_PlayerId == g_LocalPlayer:getPlayerId() then
    local hero = g_LocalPlayer:getMainHero()
    bzhdType = hero:getProperty(PROPERTY_HUODONGBIANSHENG)
    zghdType = hero:getProperty(PROPERTY_ZHENGGUBIANSHENG)
  elseif g_TeamMgr then
    local hero = g_TeamMgr:getPlayerMainHero(self.m_PlayerId)
    if hero ~= nil then
      bzhdType = hero:getProperty(PROPERTY_HUODONGBIANSHENG)
      zghdType = hero:getProperty(PROPERTY_ZHENGGUBIANSHENG)
    end
  end
  if bzhdType ~= 0 and bzhdType ~= nil then
    v = false
  end
  if zghdType ~= 0 and zghdType ~= nil then
    v = false
  end
  return v
end
function CMapRoleShape:createZuoQi()
  if self.m_ShapeAni == nil then
    return
  end
  if self:getIsBSFing() then
    self:deleteZuoQi()
    self:flushAni(false, true)
    return
  end
  local shapeId = self:getRoleShapeForCreateImage()
  if self.m_ZuoqiAni == nil or self.m_ZuoqiAni:getShapeId() ~= shapeId then
    self:deleteZuoQi()
    local p = self.m_ShapeAni:getParent()
    setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    self.m_ZuoqiAni = CZuoQiShapeAni.new(shapeId, self.m_ZuoqiShapeID, self.m_ShapeAni)
    resetDefaultAlphaPixelFormat()
  end
  self:flushAni(false, true)
end
function CMapRoleShape:deleteZuoQi()
  if self.m_ZuoqiAni ~= nil then
    self.m_ZuoqiAni:Clear()
    self.m_ZuoqiAni = nil
  end
end
function CMapRoleShape:setState(state)
  self.m_state = state or 1
end
function CMapRoleShape:getState()
  return self.m_state
end
function CMapRoleShape:deleteChiBang()
  if self.m_ChiBangAni ~= nil then
    self.m_ChiBangAni:Clear()
    self.m_ChiBangAni = nil
  end
end
function CMapRoleShape:showTopStatus(statusType, isShow)
  if isShow == false then
    local node = self.m_TopStatus[statusType]
    if node then
      node:setVisible(false)
    end
  else
    local node = self.m_TopStatus[statusType]
    if node == nil then
      node = self:createTopStatusNodeByType(statusType)
      self.m_TopStatus[statusType] = node
    end
    node:setVisible(true)
  end
end
function CMapRoleShape:updateTopStatusPos()
  self.m_TopStatus = self.m_TopStatus or {}
  for statusType, node in pairs(self.m_TopStatus) do
    local dx = 0
    local dy = 0
    if statusType == MapRoleStatus_InBattle then
      dy = -10
    end
    node:setPosition(ccp(dx, self.m_BodyHeight + 40 + dy))
  end
end
function CMapRoleShape:setCaptainTopStatus(statusType)
  if statusType == MapRoleStatus_Captain then
    self:showTopStatus(MapRoleStatus_Captain, true)
    self:showTopStatus(MapRoleStatus_CaptainNotFull, false)
  elseif statusType == MapRoleStatus_CaptainNotFull then
    self:showTopStatus(MapRoleStatus_Captain, false)
    self:showTopStatus(MapRoleStatus_CaptainNotFull, true)
  else
    self:showTopStatus(MapRoleStatus_Captain, false)
    self:showTopStatus(MapRoleStatus_CaptainNotFull, false)
  end
end
function CMapRoleShape:setMissionStatus(statusType, isShow)
  if isShow == true then
    self.m_CurMissionStatus[statusType] = true
  else
    self.m_CurMissionStatus[statusType] = nil
  end
  if self.m_CurMissionStatus[MapRoleStatus_TaskCanCommit] == true then
    self:showTopStatus(MapRoleStatus_TaskCanCommit, true)
    self:showTopStatus(MapRoleStatus_TaskCanAccept, false)
    self:showTopStatus(MapRoleStatus_TaskNotComplete, false)
  elseif self.m_CurMissionStatus[MapRoleStatus_TaskCanAccept] == true then
    self:showTopStatus(MapRoleStatus_TaskCanCommit, false)
    self:showTopStatus(MapRoleStatus_TaskCanAccept, true)
    self:showTopStatus(MapRoleStatus_TaskNotComplete, false)
  elseif self.m_CurMissionStatus[MapRoleStatus_TaskNotComplete] == true then
    self:showTopStatus(MapRoleStatus_TaskCanCommit, false)
    self:showTopStatus(MapRoleStatus_TaskCanAccept, false)
    self:showTopStatus(MapRoleStatus_TaskNotComplete, true)
  else
    self:showTopStatus(MapRoleStatus_TaskCanCommit, false)
    self:showTopStatus(MapRoleStatus_TaskCanAccept, false)
    self:showTopStatus(MapRoleStatus_TaskNotComplete, false)
  end
end
function CMapRoleShape:clearMissionStatus()
  print("===========清除Npc 状态", self.m_NameTxt, self.m_RoleName)
  self.m_CurMissionStatus = {}
  self:showTopStatus(MapRoleStatus_TaskCanCommit, false)
  self:showTopStatus(MapRoleStatus_TaskCanAccept, false)
  self:showTopStatus(MapRoleStatus_TaskNotComplete, false)
end
function CMapRoleShape:createTopStatusNodeByType(statusType)
  local normalPicPath, normalAniPath
  local zOrder = 0
  local dx = 0
  local dy = 0
  if statusType == MapRoleStatus_AutoRoute then
    return self:createAutoRouteOrXunluoAni(1)
  elseif statusType == MapRoleStatus_AutoXunluo then
    return self:createAutoRouteOrXunluoAni(2)
  elseif statusType == MapRoleStatus_Captain then
    normalAniPath = "xiyou/ani/eff_captain.plist"
    zOrder = 10
  elseif statusType == MapRoleStatus_CaptainNotFull then
    normalAniPath = "xiyou/ani/eff_captain_notfull.plist"
    zOrder = 10
  elseif statusType == MapRoleStatus_InBattle then
    normalAniPath = "xiyou/ani/eff_inbattle.plist"
    zOrder = 10
    dy = -10
  elseif statusType == MapRoleStatus_TaskCanAccept then
    return self:createMissoinStatusAni("xiyou/ani/eff_can_accept.png", statusType)
  elseif statusType == MapRoleStatus_TaskCanCommit then
    return self:createMissoinStatusAni("xiyou/ani/eff_can_commit.png", statusType)
  elseif statusType == MapRoleStatus_TaskNotComplete then
    return self:createMissoinStatusAni("xiyou/ani/eff_not_complete.png", statusType)
  end
  if normalAniPath then
    local eff = CreateSeqAnimation(normalAniPath, -1)
    self:addNode(eff, zOrder)
    local size = eff:getTextureRect().size
    eff:setPosition(ccp(dx, self.m_BodyHeight + 40 + dy))
    return eff
  elseif normalPicPath then
    local eff = display.newSprite(normalPicPath)
    self:addNode(eff, zOrder)
    eff:setPosition(ccp(dx, self.m_BodyHeight + 40 + dy))
    return eff
  end
end
function CMapRoleShape:createMissoinStatusAni(aniPath, statusType)
  local eff = display.newSprite(aniPath)
  self:addNode(eff, 10)
  eff:setPosition(ccp(0, self.m_BodyHeight + eff:getContentSize().height / 2 + 25))
  eff:runAction(CCRepeatForever:create(transition.sequence({
    CCMoveBy:create(1, ccp(0, 10)),
    CCMoveBy:create(1, ccp(0, -10))
  })))
  return eff
end
function CMapRoleShape:setIsAutoRouteStatus(isAutoStatus)
  print("--->>>setIsAutoRouteStatus:", isAutoStatus)
  if isAutoStatus == true then
    self:setIsAutoXunluoStatus(false)
  end
  self:showTopStatus(MapRoleStatus_AutoRoute, isAutoStatus)
end
function CMapRoleShape:setIsAutoXunluoStatus(isAutoStatus)
  print("--->>>setIsAutoXunluoStatus:", isAutoStatus)
  if isAutoStatus == true then
    self:setIsAutoRouteStatus(false)
  end
  self:showTopStatus(MapRoleStatus_AutoXunluo, isAutoStatus)
end
function CMapRoleShape:createAutoRouteOrXunluoAni(t)
  local spriteList
  if t == 1 then
    spriteList = {
      1,
      2,
      3,
      4,
      5,
      6,
      6,
      6
    }
  else
    spriteList = {
      1,
      2,
      7,
      8,
      5,
      6,
      6,
      6
    }
  end
  local aniPathPro = "xiyou/ani/eff_autoroute"
  display.addSpriteFramesWithFile(aniPathPro .. ".plist", aniPathPro .. ".png")
  local batch = display.newBatchNode(aniPathPro .. ".png", 0)
  local aniList = {}
  local w = 0
  local pointWAdd = 5
  local len = #spriteList
  local actionTime = 0.2
  local totalTime = actionTime * len / 2
  for i, v in ipairs(spriteList) do
    do
      local node = display.newSprite(string.format("#eff_autoroute_%d.png", v))
      batch:addChild(node)
      node:setAnchorPoint(cc.p(0.5, 0))
      local nw = node:getContentSize().width
      if v == 6 then
        nw = nw + pointWAdd
      else
      end
      aniList[#aniList + 1] = {
        node,
        v,
        nw
      }
      w = w + nw
      local function createAction()
        if self.m_IsExist ~= true then
          return
        end
        node:runAction(CCRepeatForever:create(transition.sequence({
          CCMoveBy:create(0, cc.p(0, 6)),
          CCDelayTime:create(actionTime),
          CCMoveBy:create(0, cc.p(0, -6)),
          CCDelayTime:create(totalTime)
        })))
      end
      if i == 1 then
        createAction()
      else
        scheduler.performWithDelayGlobal(function()
          createAction()
        end, (i - 1) * actionTime / 2)
      end
    end
  end
  local x = -w / 2 + pointWAdd
  for i, aniData in ipairs(aniList) do
    local node, k, nw = unpack(aniData, 1, 3)
    node:setPosition(x + nw / 2, 0)
    x = x + nw
  end
  self:addNode(batch)
  batch:setPosition(ccp(0, self.m_BodyHeight + 20))
  return batch
end
function CMapRoleShape:MoveLocalRoleToPos(lPos, moveFinishListener)
  local x, y = lPos.x, lPos.y
  local ox, oy = self:getPosition()
  if x == ox and y == oy then
    if moveFinishListener then
      moveFinishListener()
    end
    return
  end
  self.m_MoveFinishListener = moveFinishListener
  local d = self:getDirByPos(lPos.x, lPos.y)
  self:setDirAndStatus(d, ROLE_STATE_WALK)
  self.m_MoveStartPos = ccp(ox, oy)
  self.m_MoveDstPos = lPos
  self.m_MoveDeltaDis = {
    x - ox,
    y - oy
  }
  local dis = math.pow(self.m_MoveDeltaDis[1] * self.m_MoveDeltaDis[1] + self.m_MoveDeltaDis[2] * self.m_MoveDeltaDis[2], 0.5)
  self.m_MoveTotalTimes = dis / self.m_RoleMoveSpeed
  self.m_MoveTimes = 0
  self.m_Moving = true
end
function CMapRoleShape:setRouteMoveFinishListener(listener)
  self.m_MoveRouteFinishListener = listener
end
function CMapRoleShape:MoveLocalRoleToPosRoute(route, finishDirForFollow)
  if self.m_IsLocalPlayer and g_TeamMgr:getPlayerIsCaptain(self.m_PlayerId) then
    local p = route[#route]
    if p then
      g_MapMgr:setCaptainSyncParam({
        math.round(p[1]),
        math.round(p[2])
      }, 1)
    end
  end
  if self.m_SyncParamCache ~= nil then
    self.m_IsRoutingForCaptain = true
  end
  self.m_Route = route
  self.m_MoveFinishDirForFollow = finishDirForFollow
  self.m_MoveRouteIndex = 1
  self:MoveNewIdxForToue_()
end
function CMapRoleShape:getIsMoving()
  return self.m_Moving
end
function CMapRoleShape:StopMoveForRoute()
  self.m_Moving = false
  self.m_MoveRouteIndex = 1
  self.m_Route = {}
  self:setIsAutoRouteStatus(false)
  self:setIsAutoXunluoStatus(false)
end
function CMapRoleShape:StopMove()
  self.m_Moving = false
  self.m_MoveRouteIndex = 1
  self.m_Route = {}
  self:setIsAutoRouteStatus(false)
  self:setIsAutoXunluoStatus(false)
  self:setStatus(ROLE_STATE_STAND)
  self.m_IsRoutingForCaptain = false
end
function CMapRoleShape:MoveNewIdxForToue_()
  if self.m_MoveRouteIndex <= #self.m_Route then
    local v = self.m_Route[self.m_MoveRouteIndex]
    self.m_MoveRouteIndex = self.m_MoveRouteIndex + 1
    local lPos = ccp(v[1], v[2])
    self:MoveLocalRoleToPos(lPos, handler(self, self.MoveNewIdxForToue_))
  else
    self.m_IsRoutingForCaptain = false
    if self.m_IsLocalPlayer and g_TeamMgr:getPlayerIsCaptain(self.m_PlayerId) then
      g_MapMgr:setCaptainSyncParam(nil, 2)
    end
    if self.m_FollowToRoleIns == nil or self.m_FollowToRoleInsStatus == ROLE_STATE_STAND then
      self:setStatus(ROLE_STATE_STAND)
    end
    if self.m_MoveFinishDirForFollow then
      self:setDirection(self.m_MoveFinishDirForFollow)
      if self.m_FollowingRoleIns then
        local x, y = self:getPosition()
        self.m_FollowingRoleIns:FollowToRolePosChanged(self.m_Dir, x, y, true)
      end
    end
    if self.m_MoveRouteFinishListener then
      self.m_MoveRouteFinishListener(self)
    end
  end
end
function CMapRoleShape:moveRoleUpdate(dt)
  self.m_MoveTimes = self.m_MoveTimes + dt
  if self.m_MoveTimes >= self.m_MoveTotalTimes then
    self.m_Moving = false
    self:setPosition(self.m_MoveDstPos)
    if self.m_MoveFinishListener then
      self.m_MoveFinishListener()
    else
      self:setStatus(ROLE_STATE_STAND)
    end
  else
    local ddt = dt / self.m_MoveTotalTimes
    local dx = self.m_MoveDeltaDis[1] * ddt
    local dy = self.m_MoveDeltaDis[2] * ddt
    local x, y = self:getPosition()
    self:setPosition(ccp(x + dx, y + dy))
  end
end
function CMapRoleShape:updateZuoqiDelPosition()
  if self.m_ZuoqiAni then
    local actName, dirName = self.m_ZuoqiAni:getActAndDirName()
    local zqShape = self.m_ZuoqiAni:GetZuoqiPngType()
    local key = string.format("%s_%s_%s_%s", self.m_ShapeId, zqShape, dirName, actName)
    print(key)
    if self.m_ShapeAni and ZuoQiOffsetDict[key] then
      local data = ZuoQiOffsetDict[key]
      local offx = data[1]
      local offy = data[2]
      local zuoqiX = data[3]
      local zuoqiY = data[4]
      offy = 0 - offy
      if self.m_ZuoqiAni:getScaleX() == -1 then
        offx = 0 - offx
        zuoqiX = 0 - zuoqiX
      end
      self.m_ZuoqiAni:setPosition(zuoqiX, zuoqiY)
      self.m_ShapeAni:setPosition(offx + zuoqiX, offy + zuoqiY)
    end
  end
end
function CMapRoleShape:getDirByPos(x, y)
  local ox, oy = self:getPosition()
  local dx = x - ox
  local dy = y - oy
  local noCrossFlag
  if self:getIsBSFing() then
  elseif self.m_ZuoqiShapeID ~= 0 and self.m_ZuoqiShapeID ~= nil then
    noCrossFlag = false
  end
  local d = getDirectionByDelayPos(dx, dy, noCrossFlag)
  return d
end
function CMapRoleShape:getRouteInfo()
  if self.m_Route == nil or not self.m_Moving then
    return {}
  end
  local route = {}
  for index = self.m_MoveRouteIndex - 1, #self.m_Route do
    local temp = self.m_Route[index]
    if temp ~= nil then
      route[#route + 1] = temp
    end
  end
  return route
end
function CMapRoleShape:getPositionWithDeltaTime(deltaTime)
  if deltaTime == nil then
    deltaTime = 1
  end
  if self.m_Moving == false then
    print("getPositionWithDeltaTime:  1")
    return self:getPosition()
  end
  local endTime = self.m_MoveTimes + deltaTime
  if endTime > self.m_MoveTotalTimes then
    local curIdx = self.m_MoveRouteIndex
    local dTime = endTime - self.m_MoveTotalTimes
    while true do
      local curPos = self.m_Route[curIdx - 1]
      local dstPos = self.m_Route[curIdx]
      curIdx = curIdx + 1
      if curIdx - 1 > #self.m_Route or dstPos == nil then
        print("getPositionWithDeltaTime:  2")
        return curPos[1], curPos[2]
      else
        local dPos = {
          dstPos[1] - curPos[1],
          dstPos[2] - curPos[2]
        }
        local dis = math.pow(dPos[1] * dPos[1] + dPos[2] * dPos[2], 0.5)
        local totalMoveTime = dis / self.m_RoleMoveSpeed
        if dTime <= totalMoveTime then
          local ddt = dTime / totalMoveTime
          local dx = dPos[1] * ddt
          local dy = dPos[2] * ddt
          print("getPositionWithDeltaTime:  3")
          return curPos[1] + dx, curPos[2] + dy
        else
          dTime = dTime - totalMoveTime
        end
      end
    end
  else
    local ddt = deltaTime / self.m_MoveTotalTimes
    local dx = self.m_MoveDeltaDis[1] * ddt
    local dy = self.m_MoveDeltaDis[2] * ddt
    local x, y = self:getPosition()
    print("getPositionWithDeltaTime:  4")
    return x + dx, y + dy
  end
end
function CMapRoleShape:frameUpdate(dt)
  if self.m_Moving then
    self:moveRoleUpdate(dt)
  end
end
function CMapRoleShape:RemoveAll()
  if self.m_NameTxt then
    self.m_NameTxt:removeSelf()
  end
  if self.m_FollowingRoleIns and self.m_FollowingRoleIns.getFollowToRole and self.m_FollowingRoleIns:getFollowToRole() == self then
    self.m_FollowingRoleIns:setFollowTo(nil)
    self.m_FollowingRoleIns = nil
  end
  if self.m_FollowToRoleIns and self.m_FollowToRoleIns.getFollowingRole and self.m_FollowToRoleIns:getFollowingRole() == self then
    self.m_FollowToRoleIns:setFollowing(nil)
    self.m_FollowToRoleIns = nil
  end
  self:removeSelf()
end
function CMapRoleShape:Clear()
  if self.RemoveAllMessageListener then
    self:RemoveAllMessageListener()
  end
  g_MapMgr:delRoleFromDynamicCreateAndRelease(self)
  self.m_MoveRouteFinishListener = nil
  self.m_PosChangedListener = nil
  self.m_NameTxt = nil
  self.m_ShapeAni = nil
  self.m_FollowingRoleIns = nil
  self.m_FollowToRoleIns = nil
  self.m_MyTeamCaptainRoleIns = nil
  self.m_TopStatus = {}
end
function CMapRoleShape:setFollowTo(role, resetPos)
  print("====>>>CMapRoleShape:setFollowTo:", role, resetPos)
  self.m_MyTeamCaptainRoleIns = nil
  if role == nil then
    if self.m_FollowToRoleIns and self.m_FollowToRoleIns.getFollowingRole and self.m_FollowToRoleIns:getFollowingRole() == self then
      self.m_FollowToRoleIns:setFollowing(nil)
      if self:getHide() == false then
        print("============.>>>>> getHide == false")
        self:StopMove()
      end
    end
    self.m_FollowToRoleIns = nil
  else
    print("self.m_FollowToRoleIns ~= role:", self.m_FollowToRoleIns ~= role)
    if self.m_FollowToRoleIns ~= role then
      self.m_FollowToRoleIns = role
      local dir = role:getDirection()
      local x, y = role:getPosition()
      print("dir, x, y:", dir, x, y)
      if dir > 0 then
        self:FollowToRolePosChanged(dir, x, y, true, true, resetPos)
      end
    end
  end
end
function CMapRoleShape:getFollowToRole()
  return self.m_FollowToRoleIns
end
function CMapRoleShape:setFollowing(role)
  self.m_FollowingRoleIns = role
end
function CMapRoleShape:getFollowingRole()
  return self.m_FollowingRoleIns
end
function CMapRoleShape:FollowToRolePosChanged(dir, x, y, isAdjustDir, isInit, resetPos)
  local mapview = g_MapMgr:getMapViewIns()
  if mapview == nil then
    return
  end
  if self.m_MyTeamCaptainRoleIns == nil then
    self:flushMyTeamCaptainRole()
  end
  local cx, cy = self:getPosition()
  if self.m_MyTeamCaptainRoleIns and self.m_MyTeamCaptainRoleIns.m_IsExist == true then
    local captainx, captainy = self.m_MyTeamCaptainRoleIns:getPosition()
    local cdis = (cx - captainx) * (cx - captainx) + (cy - captainy) * (cy - captainy)
    if cdis < FOLLOWCAPTAIN_DIS_HOLD then
      if self.m_Moving == false then
        self:setStatus(ROLE_STATE_STAND)
      end
      print("在队长身边不用动")
      return
    end
  end
  local dis = FOLLOW_DELTA_DIS[dir]
  local dx, dy = dis[1], dis[2]
  local dstx, dsty = x, y
  for i = 1, FOLLOW_DIS_DETECT_TIMES do
    local temp_x = x + dx * i / FOLLOW_DIS_DETECT_TIMES
    local temp_y = y + dy * i / FOLLOW_DIS_DETECT_TIMES
    if mapview:PosCanGo(temp_x, temp_y) then
      dstx, dsty = temp_x, temp_y
    else
      break
    end
  end
  local route
  local ddisx = math.abs(cx - dstx)
  local ddisy = math.abs(cy - dsty)
  local ddis = ddisx + ddisy
  if isInit ~= true and ddisx <= FOLLOW_DETECT_FINDROUTE and ddisy <= FOLLOW_DETECT_FINDROUTE then
    route = {
      {cx, cy},
      {dstx, dsty}
    }
  else
    route = g_MapMgr:FindRouteInCurMap(cx, cy, dstx, dsty)
  end
  if route and #route > 0 then
    if resetPos == true then
      local v = route[#route]
      self:setPosition(ccp(v[1], v[2]))
    elseif isAdjustDir == true then
      self:MoveLocalRoleToPosRoute(route, dir)
    else
      self:MoveLocalRoleToPosRoute(route)
    end
  end
end
function CMapRoleShape:FollowToRoleStatusChanged(status)
  self.m_FollowToRoleInsStatus = status
  if self.m_Moving == false and self.m_FollowToRoleInsStatus == ROLE_STATE_STAND then
    self:setStatus(ROLE_STATE_STAND)
  end
end
function CMapRoleShape:flushMyTeamCaptainRole()
  self.m_MyTeamCaptainRoleIns = nil
  local pid = self.m_PlayerId
  if pid == nil then
    return false
  end
  local teamId = g_TeamMgr:getPlayerTeamId()
  if teamId == nil then
    return false
  end
  local captainId = g_TeamMgr:getTeamCaptain(teamId)
  if captainId == nil then
    return false
  end
  local role = g_MapMgr:getRole(captainId)
  if role == nil then
    return false
  end
  self.m_MyTeamCaptainRoleIns = role
  return true
end
function CMapRoleShape:setDynamicCreateAndDelete(setId)
  self.m_idForDynamicCreateAndDelete = setId
end
function CMapRoleShape:getDynamicCreateAndDelete()
  return self.m_idForDynamicCreateAndDelete
end
function CMapRoleShape:isRoleCreated()
  return self.m_IsCreatedRole
end
function CMapRoleShape:doDynamicCreate()
  if self.m_IsCreatedRole == false and self.m_ShapeAni == nil then
    self:createShapeAsync()
  end
end
function CMapRoleShape:doDynamicRelease()
  self.m_IsCreatedRole = false
  if self.m_ShapeAni ~= nil then
    self.m_ShapeAni:removeFromParent()
    self.m_ShapeAni = nil
  end
  self:deleteZuoQi()
end
function CMapRoleShape:setCaptainRouteParam(routingFlag, param)
  self.m_SyncParamCache = param
  if routingFlag ~= nil then
    self.m_IsRoutingForCaptain = routingFlag
  end
end
function CMapRoleShape:getCaptainRouteParam(param)
  return self.m_IsRoutingForCaptain, self.m_SyncParamCache
end
function CMapRoleShape:_setSpecialShapeCololfulFromLocalPlayer()
  if self.m_IsSpecialShapeFromLocalPlayer and self.m_ShapeAni then
    SetOneBodyChangeColorWithLocalPlayerColor(self.m_ShapeAni)
  end
end
