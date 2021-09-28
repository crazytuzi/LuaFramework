MapPlayerShape = class("MapPlayerShape", CMapRoleShape)
function MapPlayerShape:ctor(playerId, mainHeroId, posChangedListener)
  self.m_PlayerId = playerId
  if mainHeroId == nil then
    local player = g_DataMgr:getPlayer(self.m_PlayerId)
    local mainHero = player:getMainHero()
    mainHeroId = mainHero:getTypeId()
  end
  self.m_RoleId = mainHeroId
  local shapeId = data_getRoleShape(self.m_RoleId)
  self.super.ctor(self, shapeId, LOGICTYPE_HERO, posChangedListener)
  self.m_ShowingShape = nil
  self.m_CurShowChengweiId = nil
  self.m_ChengweiTxt = nil
end
function MapPlayerShape:getPlayerId()
  return self.m_PlayerId
end
function MapPlayerShape:setBpId(bpId, placeId)
  self.m_BpId = bpId
  self.m_PlaceId = placeId
end
function MapPlayerShape:getBpId()
  return self.m_BpId
end
function MapPlayerShape:getPlayerMapZuoqiTypeId()
  local player = g_DataMgr:getPlayer(self.m_PlayerId)
  if player == nil then
    return nil
  end
  local mainHero = player:getMainHero()
  if mainHero == nil then
    return nil
  end
  local num = mainHero:getProperty(PROPERTY_MAPZuoqiTypeId)
  if num == 0 then
    return nil
  end
  return num
end
function MapPlayerShape:OnShapeAniLoadFinish()
  MapPlayerShape.super.OnShapeAniLoadFinish(self)
  self:setRoleBpName(self.m_BpName)
end
function MapPlayerShape:setMoveSpeed()
  self.m_RoleMoveSpeed = DefineRoleMoveSpeedInMap
  local AsPlayerId = self.m_PlayerId
  local teamId = g_TeamMgr:getPlayerTeamId(self.m_PlayerId)
  if teamId ~= 0 then
    local captainId = g_TeamMgr:getTeamCaptain(teamId)
    if g_TeamMgr:getPlayerTeamState(self.m_PlayerId) == TEAMSTATE_FOLLOW then
      AsPlayerId = captainId
    end
  end
  if AsPlayerId == g_LocalPlayer:getPlayerId() then
    self.m_RoleMoveSpeed = DefineRoleMoveSpeedInMap * g_LocalPlayer:getAddSpeedNum()
  else
    local player = g_DataMgr:getPlayer(AsPlayerId)
    if player == nil then
      return
    end
    local role = player:getMainHero()
    if role ~= nil then
      local addSpeedEndTime = role:getProperty(PROPERTY_ADDSPEED_ENDTIME)
      if addSpeedEndTime ~= 0 and addSpeedEndTime > g_DataMgr:getServerTime() then
        self.m_RoleMoveSpeed = DefineRoleMoveSpeedInMap * JSFSpeedNum
      end
    end
  end
end
function MapPlayerShape:changeBSF()
  local shape = self:getRoleShapeForCreateImage()
  if shape == nil then
    return
  end
  if shape == self.m_ShowingShape then
    return
  end
  self.m_ShowingShape = shape
  self:createShape()
end
function MapPlayerShape:changeZuoqiShape()
  local zqShapeId
  if self.getPlayerMapZuoqiTypeId then
    zqShapeId = self:getPlayerMapZuoqiTypeId()
  end
  self:setZuoqi(zqShapeId)
end
function MapPlayerShape:getRoleShapeForCreateImage()
  local shape = self.m_ShapeId
  if g_LocalPlayer == nil then
    return shape
  end
  if self.m_PlayerId == g_LocalPlayer:getPlayerId() then
    local hero = g_LocalPlayer:getMainHero()
    if hero == nil then
      printLog("ERROR", "找不到主英雄30")
      return self.m_ShapeId
    end
    shape = hero:getTypeId()
    local bsfType = g_LocalPlayer:getBianShenFuType()
    if bsfType ~= 0 and bsfType ~= nil then
      shape = bsfType
    end
  else
    local hero = g_TeamMgr:getPlayerMainHero(self.m_PlayerId)
    if hero == nil then
      printLog("ERROR", "找不到其他英雄30")
      return self.m_ShapeId
    end
    shape = hero:getBSFShapeId()
  end
  return shape
end
function MapPlayerShape:getIsBSFing()
  if g_LocalPlayer == nil then
    return false
  end
  if self.m_PlayerId == g_LocalPlayer:getPlayerId() then
    local hero = g_LocalPlayer:getMainHero()
    if hero == nil then
      return false
    end
    local bsfType = g_LocalPlayer:getBianShenFuType()
    if bsfType ~= 0 and bsfType ~= nil then
      return true
    end
  else
    local hero = g_TeamMgr:getPlayerMainHero(self.m_PlayerId)
    if hero == nil then
      return false
    end
    local shape = hero:getProperty(PROPERTY_SHAPE)
    return shape ~= hero:getBSFShapeId()
  end
  return false
end
function MapPlayerShape:setRoleName(name, color)
  MapPlayerShape.super.setRoleName(self, name, color)
  self:resetRoleNameColor()
  self:flushChengwei()
end
function MapPlayerShape:resetRoleNameColor()
  local txtIns = self:getRoleNameTxt()
  if txtIns == nil then
    return
  end
  if g_MapMgr:IsInBangPaiWarMap() then
    if g_TeamMgr:IsPlayerOfLocalPlayerTeam(self.m_PlayerId) and self.m_PlayerId ~= g_LocalPlayer:getPlayerId() then
      self.m_BpId = g_BpMgr:getLocalPlayerBpId()
    end
    local flag = g_BpWarMgr:getIsAttacker(self.m_BpId)
    if flag == true then
      txtIns:setColor(BpNameColorOfBpWarAttacker)
    else
      txtIns:setColor(BpNameColorOfBpWarDefender)
    end
  else
    local player = g_DataMgr:getPlayer(self.m_PlayerId)
    if player == nil then
      printLog("error", "MapPlayerShape:resetRoleNameColor(), player == nil")
      return
    end
    local mainHero = player:getMainHero()
    if mainHero == nil then
      printLog("error", "MapPlayerShape:resetRoleNameColor(), mainHero == nil")
      return
    end
    local zs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
    print("---------->resetRoleNameColor:zs", zs)
    local color = NameColor_MainHero[zs]
    if color and txtIns then
      txtIns:setColor(color)
    end
  end
end
function MapPlayerShape:setRoleBpName(bpName)
  self.m_BpName = bpName
  if self.m_ShapeAni == nil then
    return
  end
  if bpName ~= nil then
    if self.m_BpNameTxt == nil then
      local bpnameTxt = ui.newTTFLabelWithShadow({
        text = bpName,
        font = KANG_TTF_FONT,
        size = 19
      })
      bpnameTxt.shadow1:realign(1, 0)
      self:addNode(bpnameTxt, 11)
      self.m_BpNameTxt = bpnameTxt
      local s = bpnameTxt:getContentSize()
      self.m_BpNameTxt:setPosition(ccp(-s.width / 2, 0 + self.m_NamePosDy + 11))
    else
      self.m_BpNameTxt:setString(bpName)
    end
    if self.m_NameTxt then
      local x, _ = self.m_NameTxt:getPosition()
      self.m_NameTxt:setPosition(ccp(x, self.m_NamePosDy - 10))
    end
    self:setBpNameColor()
  else
    if g_MapMgr:IsInBangPaiWarMap() and self.m_BpName == nil then
      g_MapMgr:AddOneReqPlayerInfo(self.m_PlayerId)
      print("------>>如果在帮战地图还是没有帮派信息，则查询帮派信息:", self.m_PlayerId)
    end
    if self.m_BpNameTxt then
      self.m_BpNameTxt:removeFromParent()
      self.m_BpNameTxt = nil
    end
    if self.m_NameTxt then
      local x, _ = self.m_NameTxt:getPosition()
      self.m_NameTxt:setPosition(ccp(x, self.m_NamePosDy))
    end
  end
  self:flushChengwei()
end
function MapPlayerShape:setBpNameColor()
  if self.m_BpNameTxt ~= nil then
    if g_MapMgr:IsInBangPaiWarMap() then
      if g_TeamMgr:IsPlayerOfLocalPlayerTeam(self.m_PlayerId) and self.m_PlayerId ~= g_LocalPlayer:getPlayerId() then
        self.m_BpId = g_BpMgr:getLocalPlayerBpId()
      end
      local nameTxt = self:getRoleNameTxt()
      local flag = g_BpWarMgr:getIsAttacker(self.m_BpId)
      if flag == true then
        if nameTxt then
          nameTxt:setColor(BpNameColorOfBpWarAttacker)
        end
        self.m_BpNameTxt:setColor(BpNameColorOfBpWarAttacker)
      elseif flag == false then
        if nameTxt then
          nameTxt:setColor(BpNameColorOfBpWarDefender)
        end
        self.m_BpNameTxt:setColor(BpNameColorOfBpWarDefender)
      else
        print("------>>如果在帮战地图还是没有帮派信息，则查询帮派信息2:", self.m_PlayerId)
        g_MapMgr:AddOneReqPlayerInfo(self.m_PlayerId)
      end
    else
      self.m_BpNameTxt:setColor(BpNameColor)
    end
  end
  self:flushChengwei()
end
function MapPlayerShape:flushChengwei()
  if self.m_ShapeAni == nil then
    return
  end
  local player = g_DataMgr:getPlayer(self.m_PlayerId)
  if player == nil then
    printLog("error", "MapPlayerShape:flushChengwei(), player == nil")
    return
  end
  local curId, endTime, isHide = player:getCurChengwei()
  print("flushLocalPlayerChengwei:", self.m_PlayerId, curId, endTime, isHide)
  if g_MapMgr:IsInBangPaiWarMap() then
    if self.m_ChengweiTxt then
      self.m_ChengweiTxt:setVisible(false)
    end
    print("隐藏称谓2:", self.m_BpNameTxt)
    if self.m_BpNameTxt then
      self.m_BpNameTxt:setVisible(true)
    end
  elseif curId == nil or curId == 0 or isHide == true then
    if self.m_ChengweiTxt then
      self.m_ChengweiTxt:setVisible(false)
    end
    print("隐藏称谓:", self.m_BpNameTxt)
    if self.m_BpNameTxt then
      self.m_BpNameTxt:setVisible(false)
    end
    if self.m_NameTxt then
      local x, _ = self.m_NameTxt:getPosition()
      self.m_NameTxt:setPosition(ccp(x, self.m_NamePosDy))
    end
  else
    local d = data_Title[curId] or {}
    if d.Category == "org" then
      if self.m_BpNameTxt then
        self.m_BpNameTxt:setVisible(true)
        if self.m_ChengweiTxt then
          self.m_ChengweiTxt:setVisible(false)
        end
      end
    else
      if self.m_ChengweiTxt == nil then
        self.m_ChengweiTxt = ui.newTTFLabelWithShadow({
          text = "",
          font = KANG_TTF_FONT,
          size = 19
        })
        self.m_ChengweiTxt.shadow1:realign(1, 0)
        self:addNode(self.m_ChengweiTxt, 11)
        local s = self.m_ChengweiTxt:getContentSize()
        self.m_ChengweiTxt:setPosition(ccp(-s.width / 2, 0 + self.m_NamePosDy + 11))
        self.m_ChengweiTxt:setColor(BpNameColorOfBpWarDefender)
      else
        self.m_ChengweiTxt:setVisible(true)
      end
      local title = d.Title or ""
      if d.Category == "marry" then
        if g_LocalPlayer and g_FriendsMgr and g_LocalPlayer:getPlayerId() == self.m_PlayerId then
          local banlvId = g_FriendsMgr:getBanLvId()
          local banlvName = g_FriendsMgr:getFriendName(banlvId)
          if banlvName == "" or banlvName == 0 and banlvName == nil then
            banlvName = "某人"
          end
          if g_FriendsMgr:getIsBanLv(banlvId) and g_LocalPlayer:getObjProperty(1, PROPERTY_GENDER) == HERO_FEMALE then
            title = banlvName .. "的娘子"
          elseif g_FriendsMgr:getIsBanLv(banlvId) and g_LocalPlayer:getObjProperty(1, PROPERTY_GENDER) == HERO_MALE then
            title = banlvName .. "的夫君"
          elseif g_FriendsMgr:getIsJiYou(banlvId) and g_LocalPlayer:getObjProperty(1, PROPERTY_GENDER) == HERO_FEMALE then
            title = banlvName .. "的姐妹"
          elseif g_FriendsMgr:getIsJiYou(banlvId) and g_LocalPlayer:getObjProperty(1, PROPERTY_GENDER) == HERO_MALE then
            title = banlvName .. "的兄弟"
          end
        else
          local banlvName = player:getCurChengweiBanLvName() or "某人"
          title = banlvName .. "的" .. title
        end
      end
      self.m_ChengweiTxt:setString(title)
      self.m_CurShowChengweiId = curId
      if self.m_BpNameTxt then
        self.m_BpNameTxt:setVisible(false)
      end
    end
    if self.m_NameTxt then
      local x, _ = self.m_NameTxt:getPosition()
      self.m_NameTxt:setPosition(ccp(x, self.m_NamePosDy - 10))
    end
  end
end
function MapPlayerShape:Clear()
  self.m_CurShowChengweiId = nil
  self.m_ChengweiTxt = nil
  MapPlayerShape.super.Clear(self)
end
