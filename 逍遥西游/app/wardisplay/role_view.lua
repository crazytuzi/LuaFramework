Define_WarRoleScale = 1
TalkBubbleZOrder = 100
SelectArrowZOrder = 40
SelectCircleZOrder = 30
HPBarZOrder = 20
RoleNameZOrder = 10
RoleZOrder = 0
NeiDanCircleZOrder = -5
ShadowZOrder = -200
ShowHPBarFlag = false
ShowHPTextFlag = false
local CRoleViewBase = class("CRoleViewBase", function()
  return Widget:create()
end)
function CRoleViewBase:ctor(pos, roleData, warScene)
  self:setNodeEventEnabled(true)
  self.m_WarPos = pos
  self.m_typeId = roleData.typeId
  self.m_Hp = roleData.hp
  self.m_MaxHp = roleData.maxHp
  self.m_Mp = roleData.mp
  self.m_MaxMp = roleData.maxMp
  self.m_WarScene = warScene
  self.m_Team = roleData.team
  self.m_RoleName = CheckStringIsLegal(roleData.name, true, REPLACECHAR_FOR_INVALIDNAME)
  self.m_PlayerId = roleData.playerId
  self.m_RoleId = roleData.objId
  self.m_LvNum = roleData.lv or 0
  self.m_Zs = roleData.zs or 0
  self.m_RanColorList = roleData.cList or {
    0,
    0,
    0
  }
  self.m_BsType = roleData.bsType or nil
  if roleData.bsType ~= nil then
    self.m_RanColorList = {
      0,
      0,
      0
    }
  end
  self.m_InitOpacity = roleData.op
  if self.m_InitOpacity == 0 or self.m_InitOpacity == nil then
    self.m_InitOpacity = 255
  end
  self.m_IsPlayerMainHero = roleData.mFlag ~= nil
  self.m_IsInFrozenState = false
  self.m_IsStealth = false
  self.m_CurrRoleState = ""
  self.m_EffectAni = {}
  self.m_BodyHeight = data_getBodyHeightByTypeID(self:getShowingTypeId()) * Define_WarRoleScale
  self.m_InitDirection = self:GetInitDirection(pos)
  self.m_Direction = self.m_InitDirection
  self.m_AniInfo = data_getBodyNormalAttackAniByTypeID(self:getShowingTypeId(), self.m_InitDirection)
  self.m_AniInfo_Reverse = data_getBodyNormalAttackAniByTypeID(self:getShowingTypeId(), self:getReverseDirection(self.m_InitDirection))
  self.m_RoleOpacity = self.m_InitOpacity
  self.m_WarState = ROLE_WAR_STATE_READY
  self.m_DisplayingFlag = false
  self.m_TouchNode = clickwidget.create(100, self.m_BodyHeight, 0.5, 0.1, function(touchNode, event)
    if self.TouchOnRole then
      self:TouchOnRole(event)
    end
  end)
  self:addChild(self.m_TouchNode)
  self:createShape()
  self:setName(self.m_RoleName)
  self:setGuard()
  self:initHpAndMpBar()
end
function CRoleViewBase:getShowingTypeId()
  if self.m_BsType ~= nil and self.m_BsType ~= 0 then
    return self.m_BsType
  end
  return self.m_typeId
end
function CRoleViewBase:getPlayerId()
  return self.m_PlayerId
end
function CRoleViewBase:getTypeId()
  return self.m_typeId
end
function CRoleViewBase:getShapeId()
  return data_getRoleShape(self:getShowingTypeId())
end
function CRoleViewBase:getType()
  return LOGICTYPE_HERO
end
function CRoleViewBase:getBodyHeight()
  return self.m_BodyHeight
end
function CRoleViewBase:getIsStealth()
  return self.m_IsStealth
end
function CRoleViewBase:getIsPlayerMainHero()
  return self.m_IsPlayerMainHero
end
function CRoleViewBase:getRanColorList()
  return self.m_RanColorList
end
function CRoleViewBase:getHpMpInfo()
  return self.m_Hp, self.m_MaxHp, self.m_Mp, self.m_MaxMp
end
function CRoleViewBase:getHpMpShow()
  if self.m_HpBar then
    return self.m_HpBar:isVisible()
  else
    return false
  end
end
function CRoleViewBase:createShape()
  local shape = data_getRoleShape(self:getShowingTypeId())
  local path = data_getWarBodyPngPathByShape(shape, self.m_Direction)
  local dynamicLoadTextureMode = getBodyDynamicLoadTextureMode(shape)
  addDynamicLoadTexture(path, function(handlerName, texture)
    if self.m_WarScene ~= nil and self.m_WarScene.m_HasBeenClosed ~= true and self.m_IsDirty ~= true and self.addNode ~= nil then
      self.m_ShapeAni, offx, offy = createWarBodyByShape(shape, self.m_Direction, self.m_RanColorList)
      self.m_ShapeAni:setPosition(offx, offy)
      self:addNode(self.m_ShapeAni, RoleZOrder)
      self.m_ShapeAni:setOpacity(0)
      self.m_ShapeAni:setScale(Define_WarRoleScale)
      self.m_ShapeAni:runAction(CCFadeTo:create(0.5, self.m_RoleOpacity))
      self:setGuard(true)
      if self.m_IsInFrozenState then
        self.m_ShapeAni:pauseAnimation()
      end
    end
  end, {pixelFormat = dynamicLoadTextureMode})
  self.m_SelectCircle = display.newSprite("xiyou/pic/pic_circle_select.png")
  self:addNode(self.m_SelectCircle, SelectCircleZOrder)
  self.m_SelectCircle:setVisible(false)
  self.m_SelectCircle:setPosition(ccp(0, self.m_BodyHeight / 2 - 5))
  local shadow = display.newSprite("xiyou/pic/pic_shapeShadow.png")
  self:addNode(shadow, ShadowZOrder)
end
function CRoleViewBase:setName(name)
  local nameColor = self:getNameColor()
  self.m_Name = ui.newTTFLabelWithShadow({
    text = name,
    font = KANG_TTF_FONT,
    size = 24,
    align = ui.TEXT_ALIGN_CENTER,
    color = nameColor
  }):pos(0, -20)
  self.m_Name.shadow1:realign(1, 0)
  self:addNode(self.m_Name, RoleNameZOrder)
end
function CRoleViewBase:getNameColor()
  return ccc3(255, 255, 0)
end
function CRoleViewBase:addTalkMsg(msg, showTime, yy)
  if self.m_TalkBubbleObj ~= nil then
    self.m_TalkBubbleObj:removeFromParentAndCleanup(true)
    self.m_TalkBubbleObj = nil
  end
  self.m_TalkBubbleObj = CMapChatBubble.new(msg, yy, handler(self, self.onTalkBubbleClear), showTime)
  self:addChild(self.m_TalkBubbleObj, TalkBubbleZOrder)
  self.m_TalkBubbleObj:setPosition(ccp(0, self.m_BodyHeight + 10))
end
function CRoleViewBase:onTalkBubbleClear(obj)
  if self.m_TalkBubbleObj == obj then
    self.m_TalkBubbleObj:removeFromParentAndCleanup(true)
    self.m_TalkBubbleObj = nil
  end
end
function CRoleViewBase:checkRoundTalk(round, delay)
  return 0
end
function CRoleViewBase:checkFightTalk(seqType, round)
  return 0
end
function CRoleViewBase:getPos()
  return self.m_WarPos
end
function CRoleViewBase:initHpAndMpBar()
  if self.m_MaxMp > 0 then
    self.m_HpBar = ProgressClip.new("xiyou/pic/pic_HpBar_war.png", "xiyou/pic/pic_HpBarBg_war.png", self.m_Hp, self.m_MaxHp, true)
    self:addChild(self.m_HpBar, HPBarZOrder)
    local size = self.m_HpBar:getContentSize()
    self.m_HpBar:setPosition(ccp(-size.width / 2, self.m_BodyHeight + 15))
    self.m_HpBar:barOffset(2, -1)
    self.m_HpBar:bg():setOpacity(self.m_RoleOpacity)
    self.m_HpBar:bar():setOpacity(self.m_RoleOpacity)
    self.m_MpBar = ProgressClip.new("xiyou/pic/pic_MpBar_war.png", "xiyou/pic/pic_MpBarBg_war.png", self.m_Mp, self.m_MaxMp, true)
    self:addChild(self.m_MpBar, HPBarZOrder)
    local size = self.m_MpBar:getContentSize()
    self.m_MpBar:setPosition(ccp(-size.width / 2, self.m_BodyHeight))
    self.m_MpBar:barOffset(2, 5)
    self.m_MpBar:bg():setOpacity(self.m_RoleOpacity)
    self.m_MpBar:bar():setOpacity(self.m_RoleOpacity)
  else
    self.m_HpBar = ProgressClip.new("xiyou/pic/pic_HpBar_war.png", "xiyou/pic/pic_MpBarBg_war.png", self.m_Hp, self.m_MaxHp, true)
    self:addChild(self.m_HpBar, HPBarZOrder)
    local size = self.m_HpBar:getContentSize()
    self.m_HpBar:setPosition(ccp(-size.width / 2, self.m_BodyHeight))
    self.m_HpBar:barOffset(2, 5)
    self.m_HpBar:bg():setOpacity(self.m_RoleOpacity)
    self.m_HpBar:bar():setOpacity(self.m_RoleOpacity)
  end
  self.m_ShowHpBarFlag = ShowHPBarFlag or self.m_WarScene:ConvertWarPosOfDefend(self.m_WarPos) < DefineDefendPosNumberBase and (self.m_WarScene:getWarType() ~= WARTYPE_HUANGGONG or not self.m_WarScene:getIsWatching())
  if self.m_ShowHpBarFlag then
    self:showHpBarAndMpBar(true)
  else
    self:showHpBarAndMpBar(false)
  end
  if ShowHPTextFlag then
    local hpText = string.format("%d/%d", self.m_Hp, self.m_MaxHp)
    self.m_HpText = CCLabelTTF:create(hpText, KANG_TTF_FONT, 25, CCSize(500, 0), ui.TEXT_ALIGN_CENTER, ui.TEXT_VALIGN_CENTER)
    self.m_HpText:setAnchorPoint(ccp(0.5, 0))
    self.m_HpText:setColor(ccc3(255, 255, 0))
    self.m_HpText:setPosition(ccp(0, self.m_BodyHeight))
    self:addNode(self.m_HpText, HPBarZOrder)
    local warId = self.m_WarScene:getWarID()
    if g_WarAiInsList[warId] then
      local role = g_WarAiInsList[warId]:getObjectByPos(self.m_WarPos)
      local ap = role:getProperty(PROPERTY_AP)
      local sp = role:getMaxProperty(PROPERTY_SP)
      local t = role:getTempProperty(PROPERTY_SP)
      local v = 0
      if t and type(t) == "table" then
        for effectID, value in pairs(t) do
          v = v + value
        end
        sp = sp * (1 + v)
      end
      local apText = string.format("ap%s  sp%s", ap, sp)
      self.m_ApText = CCLabelTTF:create(apText, KANG_TTF_FONT, 25, CCSize(500, 0), ui.TEXT_ALIGN_CENTER, ui.TEXT_VALIGN_CENTER)
      self.m_ApText:setAnchorPoint(ccp(0.5, 0))
      self.m_ApText:setColor(ccc3(255, 0, 0))
      self:addNode(self.m_ApText, HPBarZOrder)
    end
  end
end
function CRoleViewBase:showHpBarAndMpBar(flag)
  if self.m_HpBar then
    self.m_HpBar:setVisible(flag)
  end
  if self.m_MpBar then
    self.m_MpBar:setVisible(flag)
  end
end
function CRoleViewBase:checkShowEnenmyHpMp()
  if g_WarScene:ConvertWarPosOfDefend(self.m_WarPos) > DefineDefendPosNumberBase then
    if self.m_WarScene:getShowEnemyHpMp() and (self.m_WarScene:getWarType() ~= WARTYPE_HUANGGONG or not self.m_WarScene:getIsWatching()) then
      self:showHpBarAndMpBar(true)
    else
      self:showHpBarAndMpBar(false)
    end
  end
end
function CRoleViewBase:setHp(hp, deadAniFlag)
  self.m_Hp = hp
  if self.m_HpBar then
    self.m_HpBar:progressTo(hp, 0.5)
  end
  if g_WarScene and g_WarScene:getMainHeroPos() == self.m_WarPos then
    setMainRoleHp(hp, self.m_MaxHp)
  end
  if g_WarScene and g_WarScene:getMainHeroPos() == self.m_WarPos - DefineRelativePetAddPos then
    setMainPetHp(hp, self.m_MaxHp)
  end
  if deadAniFlag == nil then
    deadAniFlag = true
  end
  if self.m_Hp <= 0 and deadAniFlag ~= false then
    self:setReadyToDead()
  end
  if ShowHPTextFlag and self.m_HpText then
    local hpText = string.format("%d/%d", self.m_Hp, self.m_MaxHp)
    self.m_HpText:setString(hpText)
  end
  SendMessage(MsgID_WarScene_ViewHpMpChanged, self.m_PlayerId, self.m_RoleId)
end
function CRoleViewBase:setMp(mp)
  self.m_Mp = mp
  if self.m_MpBar then
    self.m_MpBar:progressTo(mp, 0.5)
  end
  if g_WarScene and g_WarScene:getMainHeroPos() == self.m_WarPos then
    setMainRoleMp(mp, self.m_MaxMp)
  end
  if g_WarScene and g_WarScene:getMainHeroPos() == self.m_WarPos - DefineRelativePetAddPos then
    setMainPetMp(mp, self.m_MaxMp)
  end
  SendMessage(MsgID_WarScene_ViewHpMpChanged, self.m_PlayerId, self.m_RoleId)
end
function CRoleViewBase:getShowData()
  return {
    hp = self.m_Hp,
    maxHp = self.m_MaxHp,
    mp = self.m_Mp,
    maxMp = self.m_MaxMp,
    typeId = self.m_typeId,
    objId = self.m_RoleId,
    playerId = self.m_PlayerId,
    name = self.m_RoleName,
    team = self.m_Team,
    zs = self.m_Zs,
    lv = self.m_LvNum
  }
end
function CRoleViewBase:getDirection()
  return self.m_Direction
end
function CRoleViewBase:getRoleName()
  return self.m_RoleName
end
function CRoleViewBase:getTeam()
  return self.m_Team
end
function CRoleViewBase:GetInitDirection(pos)
  pos = g_WarScene:ConvertWarPosOfDefend(pos)
  if pos < DefineDefendPosNumberBase then
    return DIRECTIOIN_LEFTUP
  else
    return DIRECTIOIN_RIGHTDOWN
  end
end
function CRoleViewBase:getReverseDirection(direction)
  if direction == DIRECTIOIN_LEFTUP then
    return DIRECTIOIN_RIGHTDOWN
  else
    return DIRECTIOIN_LEFTUP
  end
end
function CRoleViewBase:convertDir(direction)
  return tostring(direction)
end
function CRoleViewBase:setFightToTargetDir(targetDir)
  if self.m_ShapeAni == nil then
    return
  end
  if targetDir == nil then
    return
  end
  local tempDir
  if targetDir == DIRECTIOIN_LEFTUP then
    tempDir = DIRECTIOIN_RIGHTDOWN
  else
    tempDir = DIRECTIOIN_LEFTUP
  end
  if self.m_InitDirection ~= tempDir then
    if self.m_Direction ~= tempDir then
      self.m_Direction = tempDir
      if self.m_ShapeAni_Temp == nil then
        self.m_ShapeAni_Temp, offx, offy = createWarBodyByRoleTypeID(self:getShowingTypeId(), self.m_Direction, self.m_RanColorList)
        self.m_ShapeAni_Temp:setPosition(offx, offy)
        self:addNode(self.m_ShapeAni_Temp, RoleZOrder)
        self.m_ShapeAni_Temp:setScale(Define_WarRoleScale)
      end
      local temp = self.m_ShapeAni
      self.m_ShapeAni = self.m_ShapeAni_Temp
      self.m_ShapeAni_Temp = temp
      self.m_ShapeAni:setVisible(true)
      self.m_ShapeAni:setOpacity(self.m_RoleOpacity)
      self.m_ShapeAni_Temp:setVisible(false)
    end
    self:setGuard(true)
  else
    self.m_Direction = tempDir
    self:setGuard(true)
  end
end
function CRoleViewBase:recoverDirToNormalStand()
  if self.m_ShapeAni == nil then
    return
  end
  if self.m_Direction ~= self.m_InitDirection then
    self:recoverInitDirection()
    self:setGuard(true)
  end
end
function CRoleViewBase:recoverInitDirection()
  if self.m_InitDirection ~= self.m_Direction then
    if self.m_ShapeAni_Temp then
      local temp = self.m_ShapeAni
      self.m_ShapeAni = self.m_ShapeAni_Temp
      self.m_ShapeAni_Temp = temp
      self.m_ShapeAni:setVisible(true)
      self.m_ShapeAni_Temp:setVisible(false)
    end
    self.m_Direction = self.m_InitDirection
  end
end
function CRoleViewBase:getNeedFlipX()
  return false
end
function CRoleViewBase:getAniInfo()
  if self.m_Direction == self.m_InitDirection then
    return self.m_AniInfo
  else
    return self.m_AniInfo_Reverse
  end
end
function CRoleViewBase:showSelectCircle(flag, canSelectDeadPeople, extraParam)
  local deadFlag = self.m_CurrRoleState == "dead"
  if canSelectDeadPeople ~= true and deadFlag == true then
    flag = false
  end
  if extraParam ~= nil and g_WarScene then
    if extraParam.exceptSelf == true and extraParam.settingPos == self.m_WarPos then
      flag = false
    end
    if extraParam.onlySelf == true and extraParam.settingPos ~= self.m_WarPos then
      flag = false
    end
    if extraParam.onlyPet == true and self:getType() ~= LOGICTYPE_PET then
      flag = false
    end
    if extraParam.onlyDead == true and (not self:isDead() or g_WarScene:getRoleViewByPos(self.m_WarPos) == nil) then
      flag = false
    end
  end
  if self.m_SelectCircle ~= nil then
    self.m_SelectCircle:setVisible(flag)
  end
end
function CRoleViewBase:showSelectArrow(flag)
  if self.m_SelectArrow ~= nil then
    self.m_SelectArrow:removeFromParent()
    self.m_SelectArrow = nil
  end
  if flag then
    self.m_SelectArrow = display.newSprite("xiyou/pic/pic_arrow.png")
    local x, y = 0, self.m_BodyHeight + 40
    self.m_SelectArrow:setPosition(ccp(x, y))
    self:addNode(self.m_SelectArrow, SelectArrowZOrder)
    self.m_SelectArrow:setAnchorPoint(ccp(1, 0.5))
    self.m_SelectArrow:setRotation(90)
    self.m_SelectArrow:setPosition(x, y)
    local act1 = CCMoveBy:create(0.5, ccp(0, 30))
    local act2 = CCMoveBy:create(0.5, ccp(0, -30))
    self.m_SelectArrow:runAction(CCRepeatForever:create(transition.sequence({act1, act2})))
  end
end
function CRoleViewBase:SetStateInWar(state)
  self.m_WarState = state
  if self.m_StateImg ~= nil then
    self.m_StateImg:removeFromParent()
    self.m_StateImg = nil
  end
  local x, y = 0, self.m_BodyHeight + 40
  if self.m_DisplayingFlag == true then
    if state == ROLE_WAR_STATE_OFFLINE then
      self.m_StateImg = display.newSprite("xiyou/pic/pic_offline.png")
      self:addNode(self.m_StateImg, SelectArrowZOrder)
      self.m_StateImg:setPosition(x, y)
    end
  elseif state == ROLE_WAR_STATE_READY then
  elseif state == ROLE_WAR_STATE_OFFLINE then
    self.m_StateImg = display.newSprite("xiyou/pic/pic_offline.png")
    self:addNode(self.m_StateImg, SelectArrowZOrder)
    self.m_StateImg:setPosition(x, y)
  elseif state == ROLE_WAR_STATE_SETTING then
    self.m_StateImg = display.newSprite("xiyou/pic/pic_ready.png")
    self:addNode(self.m_StateImg, SelectArrowZOrder)
    self.m_StateImg:setPosition(x, y)
  end
end
function CRoleViewBase:SetDisplayingFlag(flag)
  self.m_DisplayingFlag = flag
  self:SetStateInWar(self.m_WarState)
  self:SetSelected(false)
end
function CRoleViewBase:playCurrRoleStateAni(times, callFunc)
  times = times or -1
  if self.m_ShapeAni then
    self.m_ShapeAni:playAniWithName(self.m_CurrRoleState .. "_" .. self:convertDir(self.m_Direction), times, callFunc)
  elseif callFunc then
    callFunc()
  end
  if self.m_ShapeAni_Temp then
    local d = self:getReverseDirection(self.m_Direction)
    self.m_ShapeAni_Temp:playAniWithName(self.m_CurrRoleState .. "_" .. self:convertDir(d), times)
  end
end
function CRoleViewBase:setGuard(byForce)
  if self.m_CurrRoleState == "guard" and byForce ~= true then
    return
  end
  if self.m_CurrRoleState == "dead" then
    self:setDead()
  else
    self.m_CurrRoleState = "guard"
    self:playCurrRoleStateAni(-1, nil)
  end
end
function CRoleViewBase:setWalk(byForce)
  if g_WarScene:isChasing() then
    return
  end
  if self.m_CurrRoleState == "walk" and byForce ~= true then
    return
  end
  self.m_CurrRoleState = "walk"
  self:playCurrRoleStateAni(-1, nil)
end
function CRoleViewBase:setNormalAttack(attackMiss)
  if g_WarScene:isChasing() then
    if self.m_AttackCallBackFunc then
      self.m_AttackCallBackFunc()
      self.m_AttackCallBackFunc = nil
    end
    return
  end
  if self.m_CurrRoleState == "dead" then
    return
  end
  self.m_CurrRoleState = "attack"
  if self.m_ShapeAni == nil then
    local act1 = CCDelayTime:create(0.8)
    local act2 = CCCallFunc:create(function()
      if self.m_AttackCallBackFunc then
        self.m_AttackCallBackFunc()
        self.m_AttackCallBackFunc = nil
      end
      self:setGuard()
    end)
    self:runAction(transition.sequence({act1, act2}))
    return
  end
  self:playCurrRoleStateAni(1, function()
    if self.m_AttackCallBackFunc then
      self.m_AttackCallBackFunc()
      self.m_AttackCallBackFunc = nil
    end
    self:setGuard()
  end)
  local aniInfo = self:getAniInfo()
  local attAni = aniInfo.attAni
  if attAni ~= nil then
    do
      local attAni_offx = (aniInfo.attAni_offx or 0) * Define_WarRoleScale
      local attAni_offy = (aniInfo.attAni_offy or 0) * Define_WarRoleScale
      local attDelay = aniInfo.attAniDelay
      local flipx = aniInfo.attAni_Flip[1]
      local flipy = aniInfo.attAni_Flip[2]
      local act1 = CCDelayTime:create(attDelay)
      local act2 = CCCallFunc:create(function()
        local attAniSprite = warAniCreator.createAni(attAni, 1, nil, true, false)
        attAniSprite:setPosition(attAni_offx, attAni_offy)
        attAniSprite:setScale(2)
        if flipx ~= 0 then
          attAniSprite:setScaleX(-1)
        end
        if flipy ~= 0 then
          attAniSprite:setScaleY(-1)
        end
        self:addNode(attAniSprite, RoleZOrder + 1)
      end)
      self:runAction(transition.sequence({act1, act2}))
    end
  end
  if attackMiss ~= true then
    local delay = aniInfo.attSoundDelay or 0
    local act1 = CCDelayTime:create(delay)
    local act2 = CCCallFunc:create(function()
      soundManager.playSound(string.format("xiyou/sound/war_weapon_%d.wav", aniInfo.attSound))
    end)
    self:runAction(transition.sequence({act1, act2}))
  end
end
function CRoleViewBase:setSkillAttack(showMagicAni, skillID)
  if g_WarScene:isChasing() then
    if self.m_AttackCallBackFunc then
      self.m_AttackCallBackFunc()
      self.m_AttackCallBackFunc = nil
    end
    return
  end
  if self.m_CurrRoleState == "dead" then
    return
  end
  self.m_CurrRoleState = "magic"
  if self.m_ShapeAni == nil then
    local act1 = CCDelayTime:create(0.8)
    local act2 = CCCallFunc:create(function()
      if self.m_AttackCallBackFunc then
        self.m_AttackCallBackFunc()
        self.m_AttackCallBackFunc = nil
      end
      self:setGuard()
    end)
    self:runAction(transition.sequence({act1, act2}))
    return
  end
  if self:isInSleepState() or self:isInFrozenState() then
    if self.m_AttackCallBackFunc then
      self.m_AttackCallBackFunc()
      self.m_AttackCallBackFunc = nil
    end
    self.m_CurrRoleState = "guard"
  else
    self:playCurrRoleStateAni(1, function()
      if self.m_AttackCallBackFunc then
        self.m_AttackCallBackFunc()
        self.m_AttackCallBackFunc = nil
      end
      self:setGuard()
    end)
  end
  if showMagicAni ~= false then
    self:creatMagicAni(skillID)
  end
end
function CRoleViewBase:creatMagicAni(skillID)
  if skillID == 30065 then
    local aniInfoList = data_getSkillAniPathByAniIDList(101)
    self.m_WarScene:displayObjAniAtPos(aniInfoList, self.m_WarPos)
    soundManager.playSound("xiyou/sound/war_magic.wav")
  else
    local aniInfo = self:getAniInfo()
    local magicAni_offx = aniInfo.magicAni_offx or 0
    local magicAni_offy = aniInfo.magicAni_offy or 0
    local magicAniSprite = warAniCreator.createAni("xiyou/ani/magic1_4.plist", 1, nil, true, false, nil)
    magicAniSprite:setPosition(magicAni_offx, magicAni_offy)
    magicAniSprite:setScale(1)
    self:addNode(magicAniSprite, RoleZOrder + 2)
    local magicAniSprite_2 = warAniCreator.createAni("xiyou/ani/magic2_4.plist", 1, nil, true, false, nil)
    magicAniSprite_2:setPosition(magicAni_offx, magicAni_offy)
    magicAniSprite_2:setScale(1)
    self:addNode(magicAniSprite_2, RoleZOrder - 2)
    soundManager.playSound("xiyou/sound/war_magic.wav")
  end
end
function CRoleViewBase:setAttack(skillID, callback, attackMiss)
  if self.m_AttackCallBackFunc ~= nil then
    self.m_AttackCallBackFunc()
  end
  self.m_AttackCallBackFunc = callback
  if JudgeSkillIsMagicAttack(skillID) then
    self:setSkillAttack(true, skillID)
  else
    self:setNormalAttack(attackMiss)
  end
end
function CRoleViewBase:setUseDrug(callback)
  if self.m_AttackCallBackFunc ~= nil then
    self.m_AttackCallBackFunc()
  end
  if self:isInSleepState() then
    if callback then
      callback()
    end
    self:creatMagicAni()
  else
    self.m_AttackCallBackFunc = callback
    self:setSkillAttack(false)
  end
end
function CRoleViewBase:setHurt(deltaHp, deltaMp, attEffectList, objEffectList, hurtSkill, extraParam)
  if g_WarScene:isChasing() then
    return
  end
  self:displayHpAndMp(-deltaHp, -deltaMp, attEffectList)
  if self.m_ShapeAni == nil then
    self:setGuard()
    return
  end
  if self:isInFrozenState() then
    return
  end
  if extraParam and extraParam.noAct == true then
    return
  end
  if deltaHp > 0 or deltaMp > 0 or hurtSkill ~= nil and JudgeSkillIsActive(hurtSkill) and (_getEffectIsExisted(EFFECTTYPE_SLEEP, objEffectList) or _getEffectIsExisted(EFFECTTYPE_CONFUSE, objEffectList) or _getEffectIsExisted(EFFECTTYPE_FROZEN, objEffectList) or _getEffectIsExisted(EFFECTTYPE_SHUAIRUO, objEffectList) or _getEffectIsExisted(EFFECTTYPE_YIWANG, objEffectList)) then
    if self.m_CurrRoleState ~= "magic" and self.m_CurrRoleState ~= "attack" then
      if self.m_CurrRoleState ~= "dead" then
        self.m_CurrRoleState = "hurt"
      end
      self:playCurrRoleStateAni(1, function()
        self:setGuard()
      end)
    end
    if self:CheckNeedHurtAni(hurtSkill) then
      local aniInfo = self:getAniInfo()
      local hurtAni = aniInfo.hurtAni
      if hurtAni ~= nil then
        local hurtAni_offx = aniInfo.hurtAni_offx or 0
        local hurtAni_offy = aniInfo.hurtAni_offy or 0
        local hurtAniSprite = warAniCreator.createAni(hurtAni, 1, nil, true, false)
        hurtAniSprite:setPosition(hurtAni_offx * Define_WarRoleScale, hurtAni_offy * Define_WarRoleScale)
        hurtAniSprite:setScale(1)
        self:addNode(hurtAniSprite, RoleZOrder + 1)
      end
    end
    if extraParam ~= nil and extraParam.hurtSound == true then
      soundManager.playSound("xiyou/sound/war_weapon_0.wav")
    end
  end
end
function CRoleViewBase:CheckNeedHurtAni(hurtSkill)
  if hurtSkill == nil or hurtSkill == SKILLTYPE_NORMALATTACK then
    return true
  end
  local aniInfoList = data_getSkillObjAniPath(hurtSkill)
  if aniInfoList ~= nil then
    return false
  else
    return true
  end
end
function CRoleViewBase:setMiss()
  if g_WarScene:isChasing() then
    return
  end
  if self:isInFrozenState() then
    return
  end
  if self:isInSleepState() then
    return
  end
  local offx, offy
  if self.m_Direction == DIRECTIOIN_LEFTUP then
    offx = 50
    offy = -20
  else
    offx = -55
    offy = 20
  end
  local mt = 0.25
  local dt = 0.2
  local act1 = CCMoveBy:create(mt, ccp(offx, offy))
  local act2 = CCDelayTime:create(dt)
  local act3 = CCMoveBy:create(mt, ccp(-offx, -offy))
  self:runAction(transition.sequence({
    act1,
    act2,
    act3
  }))
  local function _CreateMissShadow(delay)
    local p = self:getParent()
    local z = self:getZOrder()
    local shadow, bodyoffx, bodyoffy = createWarBodyByRoleTypeID(self:getShowingTypeId(), self.m_Direction, self.m_RanColorList)
    shadow:setScale(Define_WarRoleScale)
    p:addNode(shadow, z)
    shadow:playAniWithName("guard_" .. self:convertDir(self.m_Direction), -1)
    if self:getNeedFlipX() then
      shadow:runAction(CCFlipX:create(true))
    end
    shadow:setVisible(false)
    shadow:setOpacity(100)
    local x, y = self:getPosition()
    shadow:setPosition(x + bodyoffx, y + bodyoffy)
    local a0 = CCDelayTime:create(delay or 0)
    local a1 = CCShow:create()
    local a2 = CCMoveBy:create(mt, ccp(offx, offy))
    local a3 = CCCallFunc:create(function()
      shadow:removeFromParentAndCleanup(true)
    end)
    shadow:runAction(transition.sequence({
      a0,
      a1,
      a2,
      a3
    }))
  end
  _CreateMissShadow(0.075)
  _CreateMissShadow(0.15)
end
function CRoleViewBase:setStealth(delayTime)
  self.m_IsStealth = true
  delayTime = delayTime or 0
  if delayTime > 0 and not g_WarScene:isChasing() then
    local act1 = CCDelayTime:create(delayTime)
    local act2 = CCCallFunc:create(function()
      self:setStealth(0)
    end)
    self:runAction(transition.sequence({act1, act2}))
    return
  end
  self.m_RoleOpacity = math.floor(self.m_InitOpacity / 2)
  local children = self:getChildren()
  if children ~= nil then
    for i = 0, children:count() - 1 do
      local node = children:objectAtIndex(i)
      if node ~= self.m_TalkBubbleObj and node ~= self.m_SelectCircle and node.setOpacity then
        node:setOpacity(self.m_RoleOpacity)
      end
    end
  end
  local children = self:getNodes()
  if children ~= nil then
    for i = 0, children:count() - 1 do
      local node = children:objectAtIndex(i)
      if node ~= self.m_TalkBubbleObj and node ~= self.m_SelectCircle and node.setOpacity then
        node:setOpacity(self.m_RoleOpacity)
      end
    end
  end
  if self.m_HpBar then
    self.m_HpBar:bg():setOpacity(self.m_RoleOpacity)
    self.m_HpBar:bar():setOpacity(self.m_RoleOpacity)
  end
  if self.m_MpBar then
    self.m_MpBar:bg():setOpacity(self.m_RoleOpacity)
    self.m_MpBar:bar():setOpacity(self.m_RoleOpacity)
  end
end
function CRoleViewBase:cancelStealth()
  self.m_IsStealth = false
  self.m_RoleOpacity = self.m_InitOpacity
  local children = self:getChildren()
  if children ~= nil then
    for i = 0, children:count() - 1 do
      local node = children:objectAtIndex(i)
      if node ~= self.m_TalkBubbleObj and node.setOpacity then
        node:setOpacity(self.m_RoleOpacity)
      end
    end
  end
  local children = self:getNodes()
  if children ~= nil then
    for i = 0, children:count() - 1 do
      local node = children:objectAtIndex(i)
      if node ~= self.m_TalkBubbleObj and node.setOpacity then
        node:setOpacity(self.m_RoleOpacity)
      end
    end
  end
  if self.m_HpBar then
    self.m_HpBar:bg():setOpacity(self.m_RoleOpacity)
    self.m_HpBar:bar():setOpacity(self.m_RoleOpacity)
  end
  if self.m_MpBar then
    self.m_MpBar:bg():setOpacity(self.m_RoleOpacity)
    self.m_MpBar:bar():setOpacity(self.m_RoleOpacity)
  end
end
function CRoleViewBase:setDead()
  self.m_CurrRoleState = "dead"
  if self.m_IsStealth then
    self:cancelStealth()
  end
  if self.m_CurrRoleState ~= "dead" then
    return
  end
  if not g_WarScene:isChasing() then
    do
      local function _deadfunc()
        if self:getType() == LOGICTYPE_HERO then
          if not g_WarScene:checkRoleIsInOriPos(self.m_WarPos) then
            local act1 = CCDelayTime:create(1)
            local act2 = CCCallFunc:create(function()
              local p = g_WarScene:getXYByPos(self.m_WarPos)
              self:setPosition(p)
              self:recoverInitDirection()
              if self.m_ShapeAni then
                self.m_ShapeAni:runAction(CCFadeTo:create(0.5, self.m_RoleOpacity))
              end
            end)
            self.m_DeadAction = transition.sequence({act1, act2})
            self:runAction(self.m_DeadAction)
          end
        else
          local act1 = CCDelayTime:create(0.5)
          local act2 = CCCallFunc:create(function()
            self:setShapeAniWhenDead()
          end)
          local act3 = CCDelayTime:create(1)
          local act4 = CCCallFuncN:create(function()
            self:setRoleHide()
          end)
          self.m_DeadAction = transition.sequence({
            act1,
            act2,
            act3,
            act4
          })
          self:runAction(self.m_DeadAction)
        end
      end
      self:playCurrRoleStateAni(1, function()
        _deadfunc()
      end)
      if self:getType() ~= LOGICTYPE_HERO then
        self.m_WarScene:deleteRoleAtPos(self.m_WarPos)
      end
    end
  elseif self:getType() ~= LOGICTYPE_HERO then
    self:setRoleHide()
    self.m_WarScene:deleteRoleAtPos(self.m_WarPos)
  else
    self:playCurrRoleStateAni(1, nil)
    local p = g_WarScene:getXYByPos(self.m_WarPos)
    self:setPosition(p)
    self:recoverInitDirection()
  end
  if self.m_AttackCallBackFunc then
    self.m_AttackCallBackFunc()
    self.m_AttackCallBackFunc = nil
  end
end
function CRoleViewBase:setReadyToDead()
  if self.m_CurrRoleState == "dead" then
    return
  end
  if self.m_CurrRoleState == "guard" then
    self:setDead()
  else
    self.m_CurrRoleState = "dead"
  end
end
function CRoleViewBase:setRoleHide()
  for _, aniObjData in pairs(self.m_EffectAni) do
    do
      local effAni = aniObjData.aniObj
      if effAni then
        local act1 = CCFadeTo:create(0.5, 0)
        local act2 = CCCallFunc:create(function()
          effAni:removeFromParentAndCleanup(true)
        end)
        effAni:runAction(transition.sequence({act1, act2}))
      end
    end
  end
  self.m_EffectAni = {}
  if self.m_TalkBubbleObj ~= nil then
    self.m_TalkBubbleObj:removeFromParentAndCleanup(true)
    self.m_TalkBubbleObj = nil
  end
  self.m_TouchNode:setTouchEnabled(false)
  local children = self:getChildren()
  if children ~= nil then
    for i = 0, children:count() - 1 do
      local node = children:objectAtIndex(i)
      if node ~= self.m_TalkBubbleObj then
        node:setVisible(false)
      end
    end
  end
  local children = self:getNodes()
  if children ~= nil then
    for i = 0, children:count() - 1 do
      local node = children:objectAtIndex(i)
      if node ~= self.m_TalkBubbleObj then
        node:setVisible(false)
      end
    end
  end
  self.m_IsDirty = true
end
function CRoleViewBase:setShapeAniWhenDead()
  local dt = 1
  if self.m_ShapeAni then
    self.m_ShapeAni._fadeAction = CCFadeTo:create(dt, 0)
    self.m_ShapeAni:runAction(self.m_ShapeAni._fadeAction)
  end
  if self.m_HpBar then
    self.m_HpBar:bg()._fadeAction = CCFadeTo:create(dt, 0)
    self.m_HpBar:bg():runAction(self.m_HpBar:bg()._fadeAction)
    self.m_HpBar:bar()._fadeAction = CCFadeTo:create(dt, 0)
    self.m_HpBar:bar():runAction(self.m_HpBar:bar()._fadeAction)
  end
  if self.m_MpBar then
    self.m_MpBar:bg()._fadeAction = CCFadeTo:create(dt, 0)
    self.m_MpBar:bg():runAction(self.m_MpBar:bg()._fadeAction)
    self.m_MpBar:bar()._fadeAction = CCFadeTo:create(dt, 0)
    self.m_MpBar:bar():runAction(self.m_MpBar:bar()._fadeAction)
  end
  for _, aniObjData in pairs(self.m_EffectAni) do
    local effAni = aniObjData.aniObj
    if effAni then
      effAni:runAction(CCFadeTo:create(dt, 0))
    end
  end
end
function CRoleViewBase:setRoleEscape()
  self:setRoleHide()
  self.m_WarScene:deleteRoleAtPos(self.m_WarPos)
end
function CRoleViewBase:setRoleLeaveBattleNow()
  self:setRoleHide()
  self.m_WarScene:deleteRoleAtPos(self.m_WarPos)
end
function CRoleViewBase:setRoleLeaveBattle()
  self:setHp(0, false)
  self.m_WarScene:deleteRoleAtPos(self.m_WarPos)
  for _, aniObjData in pairs(self.m_EffectAni) do
    local effAni = aniObjData.aniObj
    if effAni then
      effAni:removeFromParentAndCleanup(true)
    end
  end
  self.m_EffectAni = {}
  if g_WarScene:isChasing() then
    self:setRoleHide()
  else
    local act1 = CCCallFunc:create(function()
      self:setShapeAniWhenDead()
    end)
    local act2 = CCDelayTime:create(1)
    local act3 = CCCallFuncN:create(function()
      self:setRoleHide()
    end)
    self:runAction(transition.sequence({
      act1,
      act2,
      act3
    }))
  end
end
function CRoleViewBase:setIsCatchByOther()
  self.m_WarScene:deleteRoleAtPos(self.m_WarPos)
  for _, aniObjData in pairs(self.m_EffectAni) do
    local effAni = aniObjData.aniObj
    if effAni then
      effAni:removeFromParentAndCleanup(true)
    end
  end
  self.m_EffectAni = {}
  if g_WarScene:isChasing() then
    self:setRoleHide()
  else
    local dt = 0.6
    self:runAction(CCRepeatForever:create(CCRotateBy:create(0.4, 360)))
    local act1 = CCSpawn:createWithTwoActions(CCScaleTo:create(dt, 0), CCJumpBy:create(dt, ccp(18, 178), 20, 1))
    local act2 = CCCallFunc:create(function()
      self:setRoleHide()
    end)
    self:runAction(transition.sequence({act1, act2}))
  end
end
function CRoleViewBase:isDead()
  return self.m_CurrRoleState == "dead"
end
function CRoleViewBase:displayHpAndMp(deltaHp, deltaMp, param)
  if g_WarScene:isChasing() then
    return
  end
  local x, y = self:getPosition()
  if deltaHp ~= 0 then
    SendMessage(MsgID_WarScene_HpChanged, deltaHp, ccp(x, y + self.m_BodyHeight / 2), self.m_WarPos, param)
    if _getEffectIsExisted(EFFECTTYPE_USEDRUG_HP, param) then
      self:addEffectForObj(EFFECTTYPE_USEDRUG_HP)
    end
  end
  if deltaMp ~= 0 then
    SendMessage(MsgID_WarScene_MpChanged, deltaMp, ccp(x, y + self.m_BodyHeight / 2), self.m_WarPos, param)
    if _getEffectIsExisted(EFFECTTYPE_USEDRUG_MP, param) then
      self:addEffectForObj(EFFECTTYPE_USEDRUG_MP)
    end
  end
end
function CRoleViewBase:setDamageRoleHpAndMpNoAction(hp, mp, dhp, dmp, param)
  if self.m_CurrRoleState ~= "dead" then
    self:setHp(hp)
    self:setMp(mp)
  end
  self:displayHpAndMp(-dhp, -dmp, param)
end
function CRoleViewBase:setDamageRoleHpAndMpNoActionWithDelay(dt, hp, mp, dhp, dmp, param)
  if g_WarScene:isChasing() then
    self:setDamageRoleHpAndMpNoAction(hp, mp, dhp, dmp, param)
  else
    dt = dt or 0
    local act1 = CCDelayTime:create(dt)
    local act2 = CCCallFunc:create(function()
      self:setDamageRoleHpAndMpNoAction(hp, mp, dhp, dmp, param)
    end)
    self:runAction(transition.sequence({act1, act2}))
  end
end
function CRoleViewBase:setDamageRoleHpAndMp(hp, mp, dhp, dmp, attEffectList, objEffectList, hurtSkill, extraParam)
  self:setHurt(dhp, dmp, attEffectList, objEffectList, hurtSkill, extraParam)
  if self.m_CurrRoleState ~= "dead" then
    self:setHp(hp)
    self:setMp(mp)
  end
end
function CRoleViewBase:setDamageRoleHpAndMpWithDelay(dt, hp, mp, dhp, dmp, attEffectList, objEffectList, hurtSkill, extraParam)
  if g_WarScene:isChasing() then
    self:setDamageRoleHpAndMp(hp, mp, dhp, dmp, attEffectList, objEffectList, hurtSkill, extraParam)
  else
    dt = dt or 0
    if dt > 0 then
      local act1 = CCDelayTime:create(dt)
      local act2 = CCCallFunc:create(function()
        self:setDamageRoleHpAndMp(hp, mp, dhp, dmp, attEffectList, objEffectList, hurtSkill, extraParam)
      end)
      self:runAction(transition.sequence({act1, act2}))
    else
      self:setDamageRoleHpAndMp(hp, mp, dhp, dmp, attEffectList, objEffectList, hurtSkill, extraParam)
    end
  end
end
function CRoleViewBase:setAddRoleHpAndMp(hp, mp, addhp, addmp, param, fuhuo, aniFlag)
  if fuhuo == 1 then
    self:setRelive(hp, mp, aniFlag == 0)
  end
  self:setHp(hp)
  self:setMp(mp)
  self:displayHpAndMp(addhp, addmp, param)
end
function CRoleViewBase:setAddRoleHpAndMpWithDelay(hp, mp, addhp, addmp, param, dt, fuhuo, aniFlag)
  dt = dt or 0
  local totalTime = dt
  local addHpMpTime = 0
  local aniId
  if aniFlag ~= 0 then
    if addhp > 0 and addmp > 0 then
      aniId = DRUG_ANIID_HPMP
    elseif addhp > 0 then
      aniId = DRUG_ANIID_HP
    elseif addmp > 0 then
      aniId = DRUG_ANIID_MP
    end
  end
  if aniId ~= nil then
    local aniTime, effTime = data_getSkillAniTime(aniId)
    totalTime = totalTime + aniTime
    addHpMpTime = effTime
  end
  if g_WarScene:isChasing() then
    self:setAddRoleHpAndMp(hp, mp, addhp, addmp, param, fuhuo, aniFlag)
  elseif dt > 0 then
    local actList = {}
    actList[#actList + 1] = CCDelayTime:create(dt)
    actList[#actList + 1] = CCCallFunc:create(function()
      self:setAddRoleHpAndMp(hp, mp, addhp, addmp, param, fuhuo, aniFlag)
      if aniId ~= nil then
        g_WarScene:displayCertainObjAniAtPos(aniId, self.m_WarPos)
      end
      soundManager.playSound(SOUND_PATH_USEDRUG, false)
    end)
    self:runAction(transition.sequence(actList))
  else
    self:setAddRoleHpAndMp(hp, mp, addhp, addmp, param, fuhuo, aniFlag)
    if aniId ~= nil then
      g_WarScene:displayCertainObjAniAtPos(aniId, self.m_WarPos)
    end
    soundManager.playSound(SOUND_PATH_USEDRUG, false)
  end
  return totalTime
end
function CRoleViewBase:setRoleBaseHpAndMpWithDelay(dt, hp, mp, maxhp, maxmp)
  if g_WarScene:isChasing() then
    self:setRoleBaseHpAndMp(hp, mp, maxhp, maxmp)
  else
    dt = dt or 0
    if dt > 0 then
      local act1 = CCDelayTime:create(dt)
      local act2 = CCCallFunc:create(function()
        self:setRoleBaseHpAndMp(hp, mp, maxhp, maxmp)
      end)
      self:runAction(transition.sequence({act1, act2}))
    else
      self:setRoleBaseHpAndMp(hp, mp, maxhp, maxmp)
    end
  end
end
function CRoleViewBase:setRoleBaseHpAndMp(hp, mp, maxhp, maxmp)
  if maxhp ~= nil then
    self.m_MaxHp = maxhp
    if self.m_HpBar then
      self.m_HpBar:value(self.m_Hp, self.m_MaxHp)
    end
  end
  if maxmp ~= nil then
    self.m_MaxMp = maxmp
    if self.m_MpBar then
      self.m_MpBar:value(self.m_Mp, self.m_MaxMp)
    end
  end
  if hp ~= nil then
    self:setHp(hp)
  end
  if mp ~= nil then
    self:setMp(mp)
  end
end
function CRoleViewBase:setRelive(hp, mp, aniFlag)
  if self.m_DeadAction then
    self:stopAction(self.m_DeadAction)
    self.m_DeadAction = nil
  end
  self.m_RoleOpacity = self.m_InitOpacity
  if self.m_ShapeAni and self.m_ShapeAni._fadeAction ~= nil then
    self.m_ShapeAni:stopAction(self.m_ShapeAni._fadeAction)
    self.m_ShapeAni:setOpacity(self.m_RoleOpacity)
    self.m_ShapeAni._fadeAction = nil
  end
  if self.m_HpBar then
    if self.m_HpBar:bg()._fadeAction ~= nil then
      self.m_HpBar:bg():stopAction(self.m_HpBar:bg()._fadeAction)
      self.m_HpBar:bg():setOpacity(self.m_RoleOpacity)
      self.m_HpBar:bg()._fadeAction = nil
    end
    if self.m_HpBar:bar()._fadeAction ~= nil then
      self.m_HpBar:bar():stopAction(self.m_HpBar:bar()._fadeAction)
      self.m_HpBar:bar():setOpacity(self.m_RoleOpacity)
      self.m_HpBar:bar()._fadeAction = nil
    end
  end
  if self.m_MpBar then
    if self.m_MpBar:bg()._fadeAction ~= nil then
      self.m_MpBar:bg():stopAction(self.m_MpBar:bg()._fadeAction)
      self.m_MpBar:bg():setOpacity(self.m_RoleOpacity)
      self.m_MpBar:bg()._fadeAction = nil
    end
    if self.m_MpBar:bar()._fadeAction ~= nil then
      self.m_MpBar:bar():stopAction(self.m_MpBar:bar()._fadeAction)
      self.m_MpBar:bar():setOpacity(self.m_RoleOpacity)
      self.m_MpBar:bar()._fadeAction = nil
    end
  end
  self.m_TouchNode:setTouchEnabled(true)
  local children = self:getChildren()
  if children ~= nil then
    for i = 0, children:count() - 1 do
      local node = children:objectAtIndex(i)
      node:setVisible(true)
      if node.setOpacity then
        node:setOpacity(self.m_RoleOpacity)
      end
    end
  end
  local children = self:getNodes()
  if children ~= nil then
    for i = 0, children:count() - 1 do
      local node = children:objectAtIndex(i)
      node:setVisible(true)
      if node.setOpacity then
        node:setOpacity(self.m_RoleOpacity)
      end
    end
  end
  self.m_SelectCircle:setVisible(false)
  if self.m_ShapeAni_Temp then
    self.m_ShapeAni_Temp:setVisible(false)
  end
  if self.m_ShowHpBarFlag then
    self:showHpBarAndMpBar(true)
  else
    self:showHpBarAndMpBar(false)
  end
  self:checkShowEnenmyHpMp()
  self.m_CurrRoleState = "guard"
  self.m_IsDirty = false
  self:recoverInitDirection()
  self:setGuard(true)
  g_WarScene:reliveRoleAtPos(self.m_WarPos, self.m_RoleId, self)
  if not g_WarScene:checkRoleIsInOriPos(self.m_WarPos) then
    local p = g_WarScene:getXYByPos(self.m_WarPos)
    self:setPosition(p)
  end
  if aniFlag == nil then
    aniFlag = true
  end
  if not g_WarScene:isChasing() and aniFlag then
    if mp > self.m_Mp then
      g_WarScene:displayCertainObjAniAtPos(DRUG_ANIID_HPMP, self.m_WarPos)
    else
      g_WarScene:displayCertainObjAniAtPos(DRUG_ANIID_HP, self.m_WarPos)
    end
    soundManager.playSound(SOUND_PATH_USEDRUG, false)
  end
end
function CRoleViewBase:getAniXYAndZ(effectID, tobody, offx, offy)
  local x = 0
  local y = 0
  local z = RoleZOrder
  offy = offy * Define_WarRoleScale
  x = offx * Define_WarRoleScale
  if tobody == Define_Tobody_Top then
    y = self.m_BodyHeight + offy
    z = RoleZOrder + 1
  elseif tobody == Define_Tobody_Mid then
    y = self.m_BodyHeight / 2 + offy
    z = RoleZOrder + 1
  elseif tobody == Define_Tobody_Bottom then
    y = offy
    z = RoleZOrder + 1
  elseif tobody == Define_Tobody_sole then
    y = offy
    z = RoleZOrder - 1
  end
  if self.m_HpBar ~= nil and self.m_HpBar:isVisible() then
    if effectID == EFFECTTYPE_CONFUSE then
      y = y + 30
    elseif effectID == EFFECTTYPE_ADV_DAMAGE or effectID == EFFECTTYPE_ADV_MINGZHONG or effectID == EFFECTTYPE_ADV_NIAN then
      y = y + 25
    elseif effectID == EFFECTTYPE_ADV_WULI or effectID == EFFECTTYPE_ADV_RENZU or effectID == EFFECTTYPE_ADV_XIANZU or effectID == EFFECTTYPE_RUHUTIANYI then
      y = y + 25
    elseif effectID == EFFECTTYPE_FENGMO then
      y = y + 25
    elseif effectID == EFFECTTYPE_SHUAIRUO or effectID == EFFECTTYPE_YIWANG then
      y = y + 25
    end
  end
  if effectID == EFFECTTYPE_TONGCHOUDIKAI or effectID == EFFECTTYPE_MONSTER_WUDI then
    x = x + 7
  end
  if effectID == EFFECTTYPE_ADV_DAMAGE or effectID == EFFECTTYPE_ADV_MINGZHONG or effectID == EFFECTTYPE_ADV_NIAN then
    z = z + 5
  elseif effectID == EFFECTTYPE_CONFUSE then
    z = z + 4
  elseif effectID == EFFECTTYPE_FENGMO then
    z = z + 3
  elseif effectID == EFFECTTYPE_ADV_WULI or effectID == EFFECTTYPE_ADV_RENZU or effectID == EFFECTTYPE_ADV_XIANZU or effectID == EFFECTTYPE_RUHUTIANYI then
    z = z + 2
  elseif effectID == EFFECTTYPE_YIWANG then
    z = z + 1
  end
  return x, y, z
end
function CRoleViewBase:getTobodyOff(tobody)
  local x = 0
  local y = 0
  if tobody == Define_Tobody_Top then
    y = self.m_BodyHeight
  elseif tobody == Define_Tobody_Mid then
    y = self.m_BodyHeight / 2
  end
  return x, y
end
function CRoleViewBase:setEffectForObj(effectID, dt)
  if effectID == EFFECTTYPE_MISS then
    self:setMiss()
    return 0.5
  elseif effectID == EFFECTTYPE_IMMUNITY then
    g_WarScene:displayEffectAniAtPosWithDelay(dt, self.m_WarPos, EFFECTTYPE_IMMUNITY)
    return 0
  elseif effectID == EFFECTTYPE_INVALID then
    g_WarScene:displayEffectAniAtPosWithDelay(dt, self.m_WarPos, EFFECTTYPE_INVALID)
    return 0
  elseif effectID == EFFECTTYPE_IMMUNITY_DAMAGE then
    g_WarScene:displayEffectAniAtPosWithDelay(dt, self.m_WarPos, EFFECTTYPE_IMMUNITY_DAMAGE)
    return 0
  elseif effectID == EFFECTTYPE_ADDHPFAILED_DHSM then
    if self.m_PlayerId == g_LocalPlayer:getPlayerId() then
      ShowNotifyTips("目标被夺魂索命，加血失败")
    end
    return 0
  elseif effectID == EFFECTTYPE_SHAREDAMAGE then
    g_WarScene:displayEffectAniAtPosWithDelay(dt, self.m_WarPos, EFFECTTYPE_SHAREDAMAGE)
    return 0
  elseif effectID == EFFECTTYPE_COUNTERATTACK then
    g_WarScene:displayEffectAniAtPos_2(self.m_WarPos, EFFECTTYPE_COUNTERATTACK)
    return 0
  elseif effectID == EFFECTTYPE_JIRENTIANXIANG then
    g_WarScene:displayPetSkillAniAtPosWhenDamageWithDelay(0.1, self.m_WarPos, PETSKILL_JIRENTIANXIANG)
    return self:addEffectForObj(effectID, dt)
  elseif effectID == EFFECTTYPE_JINGGUANBAIRI then
    g_WarScene:displayPetSkillAniAtPosWhenDamage(self.m_WarPos, PETSKILL_JINGGUANBAIRI)
    return 0
  elseif effectID == EFFECTTYPE_STEALTH then
    self:setStealth(0.8)
    return 1.3
  elseif effectID == EFFECTTYPE_STEALTH_OFF then
    self:cancelStealth()
    return 0
  elseif effectID == EFFECTTYPE_CONFUSE_OFF then
    self:removeEffectForObj(EFFECTTYPE_CONFUSE, dt)
  elseif effectID == EFFECTTYPE_FROZEN_OFF then
    self:removeEffectForObj(EFFECTTYPE_FROZEN, dt)
  elseif effectID == EFFECTTYPE_SLEEP_OFF then
    self:removeEffectForObj(EFFECTTYPE_SLEEP, dt)
  elseif effectID == EFFECTTYPE_POISON_OFF then
    self:removeEffectForObj(EFFECTTYPE_POISON, dt)
  elseif effectID == EFFECTTYPE_ADV_SPEED_OFF then
    self:removeEffectForObj(EFFECTTYPE_ADV_SPEED, dt)
  elseif effectID == EFFECTTYPE_ADV_DAMAGE_OFF then
    self:removeEffectForObj(EFFECTTYPE_ADV_DAMAGE, dt)
  elseif effectID == EFFECTTYPE_ADV_WULI_OFF then
    self:removeEffectForObj(EFFECTTYPE_ADV_WULI, dt)
  elseif effectID == EFFECTTYPE_ADV_RENZU_OFF then
    self:removeEffectForObj(EFFECTTYPE_ADV_RENZU, dt)
  elseif effectID == EFFECTTYPE_ADV_XIANZU_OFF then
    self:removeEffectForObj(EFFECTTYPE_ADV_XIANZU, dt)
  elseif effectID == EFFECTTYPE_ADV_MINGZHONG_OFF then
    self:removeEffectForObj(EFFECTTYPE_ADV_MINGZHONG, dt)
  elseif effectID == EFFECTTYPE_ADV_DEFEND_OFF then
    self:removeEffectForObj(EFFECTTYPE_ADV_DEFEND, dt)
  elseif effectID == EFFECTTYPE_DEC_WULI_OFF then
    self:removeEffectForObj(EFFECTTYPE_DEC_WULI, dt)
  elseif effectID == EFFECTTYPE_DEC_RENZU_OFF then
    self:removeEffectForObj(EFFECTTYPE_DEC_RENZU, dt)
  elseif effectID == EFFECTTYPE_DEC_XIANZU_OFF then
    self:removeEffectForObj(EFFECTTYPE_DEC_XIANZU, dt)
  elseif effectID == EFFECTTYPE_DEC_ZHEN_OFF then
    self:removeEffectForObj(EFFECTTYPE_DEC_ZHEN, dt)
  elseif effectID == EFFECTTYPE_SHUAIRUO_OFF then
    self:removeEffectForObj(EFFECTTYPE_SHUAIRUO, dt)
  elseif effectID == EFFECTTYPE_YIWANG_OFF then
    self:removeEffectForObj(EFFECTTYPE_YIWANG, dt)
  elseif effectID == EFFECTTYPE_ADV_NIAN_OFF then
    self:removeEffectForObj(EFFECTTYPE_ADV_NIAN, dt)
  elseif effectID == EFFECTTYPE_DEC_SPEED_OFF then
    self:removeEffectForObj(EFFECTTYPE_DEC_SPEED, dt)
  elseif effectID == EFFECTTYPE_SHOUHUCANGSHENG_OFF then
    self:removeEffectForObj(EFFECTTYPE_SHOUHUCANGSHENG, dt)
  elseif effectID == EFFECTTYPE_FURY_OFF then
    self:removeEffectForObj(EFFECTTYPE_FURY, dt)
  elseif effectID == EFFECTTYPE_RUHUTIANYI_OFF then
    self:removeEffectForObj(EFFECTTYPE_RUHUTIANYI, dt)
  elseif effectID == EFFECTTYPE_HENGYUNDUANFENG_OFF then
    self:removeEffectForObj(EFFECTTYPE_HENGYUNDUANFENG, dt)
  elseif effectID == EFFECTTYPE_SHUSHOUWUCE_OFF then
    self:removeEffectForObj(EFFECTTYPE_SHUSHOUWUCE, dt)
  elseif effectID == EFFECTTYPE_LONGZHANYUYE_OFF then
    self:removeEffectForObj(EFFECTTYPE_LONGZHANYUYE, dt)
  elseif effectID == EFFECTTYPE_SHUNSHUITUIZHOU_OFF then
    self:removeEffectForObj(EFFECTTYPE_SHUNSHUITUIZHOU, dt)
  elseif effectID == EFFECTTYPE_DUOHUNSUOMING_OFF then
    self:removeEffectForObj(EFFECTTYPE_DUOHUNSUOMING, dt)
  elseif effectID == EFFECTTYPE_WUXING_OFF then
    self:removeEffectForObj(EFFECTTYPE_WUXING_JIN, dt)
    self:removeEffectForObj(EFFECTTYPE_WUXING_MU, dt)
    self:removeEffectForObj(EFFECTTYPE_WUXING_SHUI, dt)
    self:removeEffectForObj(EFFECTTYPE_WUXING_HUO, dt)
    self:removeEffectForObj(EFFECTTYPE_WUXING_TU, dt)
  elseif effectID == EFFECTTYPE_WUXING_JIN_OFF then
    self:removeEffectForObj(EFFECTTYPE_WUXING_JIN, dt)
  elseif effectID == EFFECTTYPE_WUXING_MU_OFF then
    self:removeEffectForObj(EFFECTTYPE_WUXING_MU, dt)
  elseif effectID == EFFECTTYPE_WUXING_SHUI_OFF then
    self:removeEffectForObj(EFFECTTYPE_WUXING_SHUI, dt)
  elseif effectID == EFFECTTYPE_WUXING_HUO_OFF then
    self:removeEffectForObj(EFFECTTYPE_WUXING_HUO, dt)
  elseif effectID == EFFECTTYPE_WUXING_TU_OFF then
    self:removeEffectForObj(EFFECTTYPE_WUXING_TU, dt)
  elseif effectID == EFFECTTYPE_TONGCHOUDIKAI_OFF then
    self:removeEffectForObj(EFFECTTYPE_TONGCHOUDIKAI, dt)
  elseif effectID == EFFECTTYPE_MONSTER_WUDI_OFF then
    self:removeEffectForObj(EFFECTTYPE_MONSTER_WUDI, dt)
  elseif effectID == EFFECTTYPE_WUXING_JIN or effectID == EFFECTTYPE_WUXING_MU or effectID == EFFECTTYPE_WUXING_SHUI or effectID == EFFECTTYPE_WUXING_HUO or effectID == EFFECTTYPE_WUXING_TU then
    local rt = 0
    for _, effID in pairs({
      EFFECTTYPE_WUXING_JIN,
      EFFECTTYPE_WUXING_MU,
      EFFECTTYPE_WUXING_SHUI,
      EFFECTTYPE_WUXING_HUO,
      EFFECTTYPE_WUXING_TU
    }) do
      if effectID == effID then
        rt = self:addEffectForObj(effID, dt)
      else
        self:removeEffectForObj(effID, dt)
      end
    end
    return rt
  elseif effectID == EFFECTTYPE_FENGMO_OFF then
    self:removeEffectForObj(EFFECTTYPE_FENGMO)
  else
    return self:addEffectForObj(effectID, dt)
  end
  return 0
end
function CRoleViewBase:addEffectForObj(effectID, dt)
  if dt ~= nil and dt > 0 then
    if g_WarScene:isChasing() then
      self:addEffectForObj(effectID)
    else
      local a1 = CCDelayTime:create(dt)
      local a2 = CCCallFunc:create(function()
        self:addEffectForObj(effectID)
      end)
      self:runAction(transition.sequence({a1, a2}))
    end
    return
  end
  self:addEffectTip(effectID)
  local aniID = data_getEffectAniID(effectID)
  if aniID == nil then
    return 0
  end
  if self.m_EffectAni[aniID] == nil then
    self.m_EffectAni[aniID] = {}
  end
  local aniObjData = self.m_EffectAni[aniID]
  if aniObjData.effList == nil then
    aniObjData.effList = {}
  end
  local effList = aniObjData.effList
  for _, effID in pairs(effList) do
    if effID == effectID then
      return 0
    end
  end
  if aniObjData.aniObj ~= nil then
    effList[#effList + 1] = effectID
    return 0
  end
  local aniInfo = data_getSkillAniPathByAniID(aniID)
  if aniInfo == nil then
    return 0
  end
  local aniPath = aniInfo.aniPath
  local times = aniInfo.playtimes
  local offx = aniInfo.offx
  local offy = aniInfo.offy
  local tobody = aniInfo.tobody
  local et = aniInfo.addtime
  local dt = aniInfo.delaytime
  local flip = aniInfo.flip
  local loopspace = aniInfo.loopspace
  local scale = aniInfo.scale
  local autoDestoy = true
  if g_WarScene:isChasing() and effectID == EFFECTTYPE_ADV_DEFEND then
    return et
  end
  if effectID == EFFECTTYPE_SLEEP then
    local extraOff = data_getBodySleepBuffOffByTypeID(self:getShowingTypeId(), self.m_Direction)
    offx = offx + extraOff[1]
    offy = offy + extraOff[2]
  end
  if effectID == EFFECTTYPE_CONFUSE then
    local shape = data_getRoleShape(self:getShowingTypeId())
    local path = data_getWarBodyPngPathByShape(shape, self:getReverseDirection(self.m_InitDirection))
    local dynamicLoadTextureMode = getBodyDynamicLoadTextureMode(shape)
    addDynamicLoadTexture(path, function(handlerName, texture)
    end, {pixelFormat = dynamicLoadTextureMode})
  end
  if times <= -1 or effectID == EFFECTTYPE_FROZEN then
    autoDestoy = false
  end
  local ani
  if string.sub(aniPath, -4, -1) == ".png" then
    ani = display.newSprite(aniPath)
  elseif loopspace <= 0 then
    ani = CreateSeqAnimation(aniPath, times, function()
      self:addEffectAniFinish(effectID)
    end, autoDestoy, false)
  else
    ani = CreateSeqAnimation(aniPath, 1, function()
      self:OnSeqAnimation(ani, times, loopspace, effectID)
    end, false)
  end
  local x, y, z = self:getAniXYAndZ(effectID, tobody, offx, offy)
  ani:setPosition(x, y)
  self:addNode(ani, z)
  ani:setScale(scale)
  if self.m_Direction == DIRECTIOIN_LEFTUP then
    local flipLU = flip[1]
    if flipLU[1] == 1 or flipLU[2] == 1 then
      if flipLU[1] == 1 then
        ani:setScaleX(-1 * scale)
        offx = -offx
      end
      if flipLU[2] == 1 then
        ani:setScaleY(-1 * scale)
        offy = -offy
      end
      local x2, y2, _ = self:getAniXYAndZ(effectID, tobody, offx, offy)
      ani:setPosition(x2, y2)
    end
  elseif self.m_Direction == DIRECTIOIN_RIGHTDOWN then
    local flipRD = flip[2]
    if flipRD[1] == 1 or flipRD[2] == 1 then
      if flipRD[1] == 1 then
        ani:setScaleX(-1 * scale)
        offx = -offx
      end
      if flipRD[2] == 1 then
        ani:setScaleY(-1 * scale)
        offy = -offy
      end
      local x2, y2, _ = self:getAniXYAndZ(effectID, tobody, offx, offy)
      ani:setPosition(x2, y2)
    end
  end
  if times < 0 then
    effList[#effList + 1] = effectID
    aniObjData.aniObj = ani
  elseif effectID == EFFECTTYPE_FROZEN then
    self.m_IsInFrozenState = true
    effList[#effList + 1] = effectID
    aniObjData.aniObj = ani
  end
  if not g_WarScene:isChasing() then
    ani:setOpacity(0)
    local act1 = CCDelayTime:create(dt)
    local act2 = CCFadeTo:create(0.5, self.m_RoleOpacity)
    ani:runAction(transition.sequence({act1, act2}))
  else
    ani:setOpacity(self.m_RoleOpacity)
  end
  return et
end
function CRoleViewBase:OnSeqAnimation(ani, times, loopspace, effectID)
  if times <= -1 then
    local act1 = CCHide:create()
    local act2 = CCDelayTime:create(loopspace)
    local act3 = CCShow:create()
    local act4 = CCCallFunc:create(function()
      ani:playAniFromStart(1, function()
        self:OnSeqAnimation(ani, times, loopspace, effectID)
      end, false)
    end)
    ani:runAction(transition.sequence({
      act1,
      act2,
      act3,
      act4
    }))
  else
    time = time - 1
    if time <= 0 then
      self:addEffectAniFinish(effectID)
      return
    end
    local act1 = CCHide:create()
    local act2 = CCDelayTime:create(loopspace)
    local act3 = CCShow:create()
    local act4 = CCCallFunc:create(function()
      ani:playAniFromStart(1, function()
        self:OnSeqAnimation(ani, times - 1, loopspace, effectID)
      end, false)
    end)
    ani:runAction(transition.sequence({
      act1,
      act2,
      act3,
      act4
    }))
  end
end
function CRoleViewBase:addEffectAniFinish(effectID)
  if effectID == EFFECTTYPE_FROZEN then
    if self.m_ShapeAni and self.m_IsInFrozenState then
      self.m_ShapeAni:pauseAnimation()
    end
  else
    self:removeEffectForObj(effectID)
  end
end
function CRoleViewBase:removeEffectForObj(effectID, dt)
  if dt ~= nil and dt > 0 then
    local a1 = CCDelayTime:create(dt)
    local a2 = CCCallFunc:create(function()
      self:removeEffectForObj(effectID)
    end)
    self:runAction(transition.sequence({a1, a2}))
    return
  end
  local aniID = data_getEffectAniID(effectID)
  if aniID == nil then
    return
  end
  local aniObjData = self.m_EffectAni[aniID]
  if aniObjData == nil then
    return
  end
  local effList = aniObjData.effList or {}
  for index, effID in pairs(effList) do
    if effID == effectID then
      table.remove(effList, index)
      break
    end
  end
  if #effList > 0 then
    return
  end
  self.m_EffectAni[aniID] = nil
  local effectAni = aniObjData.aniObj
  if effectAni == nil then
    return
  end
  if effectID == EFFECTTYPE_FROZEN then
    self.m_IsInFrozenState = false
    if self.m_ShapeAni then
      self.m_ShapeAni:resumeAnimation()
    end
  end
  if not g_WarScene:isChasing() then
    local act1 = CCFadeTo:create(0.5, 0)
    local act2 = CCCallFunc:create(function()
      effectAni:removeFromParentAndCleanup(true)
    end)
    effectAni:runAction(transition.sequence({act1, act2}))
  else
    effectAni:removeFromParentAndCleanup(true)
  end
end
function CRoleViewBase:addEffectTip(effectID)
  if g_WarScene:isChasing() then
    return
  end
  local tipPath_Up, tipPath_Down
  if effectID == EFFECTTYPE_ADV_SPEED then
    tipPath_Up = "xiyou/pic/pic_speedup.png"
  elseif effectID == EFFECTTYPE_ADV_WULI then
    tipPath_Up = "xiyou/pic/pic_defendup.png"
  elseif effectID == EFFECTTYPE_ADV_DAMAGE then
    tipPath_Up = "xiyou/pic/pic_attackup.png"
  elseif effectID == EFFECTTYPE_ADV_NIAN then
    tipPath_Up = "xiyou/pic/pic_attackup.png"
  elseif effectID == EFFECTTYPE_DEC_WULI or effectID == EFFECTTYPE_DEC_ZHEN or effectID == EFFECTTYPE_SHUAIRUO then
    tipPath_Down = "xiyou/pic/pic_kangdown.png"
  elseif effectID == EFFECTTYPE_DEC_SPEED then
    tipPath_Down = "xiyou/pic/pic_speeddown.png"
  end
  if tipPath_Up ~= nil then
    do
      local tipObj = display.newSprite(tipPath_Up)
      self.m_WarScene.m_AniNode:addNode(tipObj, 1)
      tipObj:setAnchorPoint(ccp(0.5, 0.5))
      local x, y = self:getPosition()
      local ex, ey = x, y + self.m_BodyHeight + 25
      local sx, sy = ex, ey - 50
      local dt_1, dt_2, dt_3 = 0.15, 0.5, 0.3
      local actList = {}
      local forceDelay = 0
      local forceOffY = 0
      local curTime = cc.net.SocketTCP.getTime()
      if self._lastTipUpTime ~= nil then
        local lastTime = self._lastTipUpTime[1]
        local space = curTime - lastTime
        if space < 0.1 then
          forceDelay = 0.1 - space
          forceOffY = self._lastTipUpTime[2] - 25
        end
      else
        self._lastTipUpTime = {}
      end
      self._lastTipUpTime[1] = curTime + forceDelay
      self._lastTipUpTime[2] = forceOffY
      sy = sy + forceOffY
      ey = ey + forceOffY
      if forceDelay > 0 then
        tipObj:setVisible(false)
        actList[#actList + 1] = CCDelayTime:create(forceDelay)
        actList[#actList + 1] = CCShow:create()
      end
      tipObj:setPosition(sx, sy)
      actList[#actList + 1] = CCMoveTo:create(dt_1, ccp(ex, ey + 7))
      actList[#actList + 1] = CCMoveTo:create(0.12, ccp(ex, ey))
      actList[#actList + 1] = CCDelayTime:create(dt_2)
      actList[#actList + 1] = CCSpawn:createWithTwoActions(CCFadeTo:create(dt_3, 0), CCMoveBy:create(dt_3, ccp(0, 30)))
      actList[#actList + 1] = CCCallFunc:create(function()
        tipObj:removeFromParentAndCleanup(true)
      end)
      tipObj:runAction(transition.sequence(actList))
    end
  elseif tipPath_Down ~= nil then
    do
      local tipObj = display.newSprite(tipPath_Down)
      self.m_WarScene.m_AniNode:addNode(tipObj, 1)
      tipObj:setAnchorPoint(ccp(0.5, 0.5))
      local x, y = self:getPosition()
      local sx, sy = x, y + self.m_BodyHeight / 2 + 5
      local dt_1, dt_2, dt_3 = 0.15, 0.5, 0.4
      local actList = {}
      local forceDelay = 0
      local forceOffY = 0
      local curTime = cc.net.SocketTCP.getTime()
      if self._lastTipDownTime ~= nil then
        local lastTime = self._lastTipDownTime[1]
        local space = curTime - lastTime
        if space < 0.1 then
          forceDelay = 0.1 - space
          forceOffY = self._lastTipDownTime[2] + 25
        end
      else
        self._lastTipDownTime = {}
      end
      self._lastTipDownTime[1] = curTime + forceDelay
      self._lastTipDownTime[2] = forceOffY
      sy = sy + forceOffY
      if forceDelay > 0 then
        tipObj:setVisible(false)
        actList[#actList + 1] = CCDelayTime:create(forceDelay)
        actList[#actList + 1] = CCShow:create()
      end
      tipObj:setPosition(sx, sy)
      tipObj:setScale(0)
      actList[#actList + 1] = CCScaleTo:create(dt_1, 1.1)
      actList[#actList + 1] = CCScaleTo:create(dt_1, 1)
      actList[#actList + 1] = CCDelayTime:create(dt_2)
      actList[#actList + 1] = CCSpawn:createWithTwoActions(CCFadeTo:create(dt_3, 0), CCMoveBy:create(dt_3, ccp(0, -40)))
      actList[#actList + 1] = CCCallFunc:create(function()
        tipObj:removeFromParentAndCleanup(true)
      end)
      tipObj:runAction(transition.sequence(actList))
    end
  end
end
function CRoleViewBase:isInFrozenState()
  return self.m_IsInFrozenState
end
function CRoleViewBase:isInSleepState()
  local aniID = data_getEffectAniID(EFFECTTYPE_SLEEP)
  if aniID ~= nil and self.m_EffectAni[aniID] ~= nil and self.m_EffectAni[aniID].aniObj ~= nil then
    return true
  else
    return false
  end
end
function CRoleViewBase:onCleanup()
  self.m_WarScene = nil
end
function CRoleViewBase:TouchOnRole(event)
  if g_WarScene and g_WarScene.m_WaruiObj and g_WarScene.m_WaruiObj:GetIsShowFighting() then
    return
  end
  if event == TOUCH_EVENT_BEGAN then
    self:SetSelected(true)
    self.m_IsTouchMoved = false
  elseif event == TOUCH_EVENT_MOVED then
    if not self.m_IsTouchMoved then
      local startPos = self.m_TouchNode:getTouchStartPos()
      local movePos = self.m_TouchNode:getTouchMovePos()
      if math.abs(startPos.x - movePos.x) + math.abs(startPos.y - movePos.y) > 20 then
        self.m_IsTouchMoved = true
        self:SetSelected(false)
      end
    end
  elseif (event == TOUCH_EVENT_ENDED or event == TOUCH_EVENT_CANCELED) and not self.m_IsTouchMoved then
    if self.m_WarScene and self.m_WarScene.m_WaruiObj and self.m_WarScene.m_WaruiObj.SelectTarget then
      local deadFlag = self.m_CurrRoleState == "dead"
      self.m_WarScene.m_WaruiObj:SelectTarget(self.m_WarPos, deadFlag)
    end
    self:SetSelected(false)
  end
end
function CRoleViewBase:SetSelected(isel)
  if self.m_ShapeAni == nil then
    return
  end
  if self.m_SelAction ~= nil then
    self.m_ShapeAni:stopAction(self.m_SelAction)
    self.m_SelAction = nil
  end
  if self.m_RoleOpacity > 0 then
    if isel then
      self.m_ShapeAni:setOpacity(self.m_RoleOpacity / 2)
    else
      self.m_SelAction = CCFadeTo:create(0.3, self.m_RoleOpacity)
      self.m_ShapeAni:runAction(self.m_SelAction)
    end
  end
end
return CRoleViewBase
