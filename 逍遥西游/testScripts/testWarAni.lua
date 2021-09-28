function testWarAni()
  local parentNode = CCScene:create()
  display.replaceScene(parentNode)
  g_WarScene = CTestWarScene.new()
  g_WarScene:Show()
end
CTestWarScene = class("CTestWarScene", CcsSceneView)
function CTestWarScene:ctor()
  CTestWarScene.super.ctor(self, "views/war_scene.json")
  self:InitXYByAllPos()
  self.m_AniList = {}
  local mapName = "pic_warbg_1.jpg"
  self.m_WarBg = display.newSprite(string.format("xiyou/pic/%s", mapName))
  self.m_WarBg:setAnchorPoint(ccp(0, 0))
  self:addNode(self.m_WarBg, -99999)
  self.m_AniNode = Widget:create()
  self:addChild(self.m_AniNode, 999999)
  self.m_UINode:setTouchEnabled(true)
  self.m_UINode:addTouchEventListener(function(touchObj, t)
    if t == TOUCH_EVENT_BEGAN then
      local startPos = touchObj:getTouchStartPos()
      if startPos.x < display.width / 2 then
        self.m_SkillIndex, skillId = self:getSkillId(self.m_SkillIndex - 1)
        self:testSkillAni(skillId)
      else
        self.m_SkillIndex, skillId = self:getSkillId(self.m_SkillIndex + 1)
        self:testSkillAni(skillId)
      end
    end
  end)
  scheduler.performWithDelayGlobal(handler(self, self.CreateTestHero), 0.1)
end
function CTestWarScene:CreateTestHero()
  self.m_WarRoleObj = {}
  local temp = 20000
  local testShape = {
    [1] = temp + 1,
    [2] = temp + 2,
    [3] = temp + 3,
    [4] = temp + 4,
    [5] = temp + 5,
    [101] = temp + 6,
    [102] = temp + 7,
    [103] = temp + 8,
    [104] = temp + 9,
    [105] = temp + 10
  }
  for pos, posInfo in pairs(self.m_AllPosInfo) do
    local tid = testShape[pos]
    if pos > 10000 then
      tid = testShape[pos - 10000]
    end
    if tid ~= nil then
      local shapeId, name = data_getRoleShapeAndName(tid)
      local roleData = {
        typeId = tid,
        hp = 100,
        maxHp = 100,
        mp = 100,
        maxMp = 100,
        team = 1,
        name = name,
        playerId = 10001,
        objId = 1
      }
      local hero = CHeroView.new(pos, roleData, self)
      self:addChild(hero, 1000000 - posInfo.y)
      hero:setPosition(ccp(posInfo.x, posInfo.y))
      self.m_WarRoleObj[pos] = hero
    end
  end
  local _sortFunc = function(a, b)
    if a == nil or b == nil then
      return false
    end
    return a < b
  end
  self.m_SkillIdList = {}
  for k, _ in pairs(data_Skill) do
    self.m_SkillIdList[#self.m_SkillIdList + 1] = k
  end
  table.sort(self.m_SkillIdList, _sortFunc)
  self.m_SkillIndex = 1
  self.m_SkillIndex, skillId = self:getSkillId(self.m_SkillIndex)
  self:testSkillAni(skillId)
end
function CTestWarScene:getSkillId(idx)
  if idx > #self.m_SkillIdList then
    idx = 1
  elseif idx < 1 then
    idx = #self.m_SkillIdList
  end
  return idx, self.m_SkillIdList[idx]
end
function CTestWarScene:testSkillAni(skillId)
  print("---->>>>>skillId:", skillId)
  for _, aniObj in pairs(self.m_AniList) do
    aniObj:removeFromParent()
  end
  self.m_AniList = {}
  self:displaySkillObjAniAtPos(skillId, 10102)
  self:displaySkillObjAniAtPos(skillId, 102)
  self:displaySkillObjAniAtPos(skillId, 10105)
  self:displaySkillObjAniAtPos(skillId, 105)
  self:displaySkillDaZhaoAniAtPos(skillId, 10103)
  self:displaySkillDaZhaoAniAtPos(skillId, 103)
  self:displaySkillObjAniAtPos(skillId, 1)
  self:displaySkillObjAniAtPos(skillId, 10001)
  self:displaySkillDaZhaoAniAtPos(skillId, 1)
  self:displaySkillDaZhaoAniAtPos(skillId, 10001)
end
function CTestWarScene:getViewObjByPos(pos)
  return self.m_WarRoleObj[pos]
end
function CTestWarScene:InitXYByAllPos()
  self.m_AllPosInfo = {}
  for _, pos in pairs({
    1,
    2,
    3,
    4,
    5,
    101,
    102,
    103,
    104,
    105,
    10001,
    10002,
    10003,
    10004,
    10005,
    10101,
    10102,
    10103,
    10104,
    10105
  }) do
    local p = pos
    local posLayer = self:getNode(string.format("pos%d", p))
    if posLayer then
      local x, y = posLayer:getPosition()
      local size = posLayer:getContentSize()
      local offx = (display.width - 960) / 2
      local offy = (display.height - 640) / 2
      if display.width > 960 then
        if p < DefineDefendPosNumberBase then
          offx = offx + offx * 0.5
        else
          offx = offx - offx * 0.5
        end
      end
      self.m_AllPosInfo[pos] = ccp(x + size.width / 2 + offx, y + size.height / 2 + offy)
      posLayer:setEnabled(false)
    end
  end
end
function CTestWarScene:ConvertWarPosOfDefend(p)
  return p
end
function CTestWarScene:displaySkillObjAniAtPos(skillID, pos)
  if skillID == nil then
    return
  end
  local aniInfoList = data_getSkillObjAniPath(skillID)
  self:displayObjAniAtPos(aniInfoList, pos)
end
function CTestWarScene:displayObjAniAtPos(aniInfoList, pos)
  local roleObj = self:getViewObjByPos(pos)
  if roleObj == nil then
    return
  end
  if aniInfoList ~= nil then
    do
      local x, y = roleObj:getPosition()
      for _, aniInfo in pairs(aniInfoList) do
        do
          local skillAniPath = aniInfo.aniPath
          local times = aniInfo.playtimes
          local offx = aniInfo.offx
          local offy = aniInfo.offy
          local tobody = aniInfo.tobody
          local dt = aniInfo.delaytime
          local scale = aniInfo.scale
          local flip = aniInfo.flip
          local sound = aniInfo.sound
          if skillAniPath ~= nil then
            local act1 = CCDelayTime:create(dt)
            local act2 = CCCallFunc:create(function()
              local skillAni = warAniCreator.createAni(skillAniPath, 1000, nil, true, false)
              self.m_AniList[#self.m_AniList + 1] = skillAni
              local bodyx, bodyy = roleObj:getTobodyOff(tobody)
              skillAni:setPosition(x + bodyx + offx, y + bodyy + offy)
              skillAni:setScale(scale)
              if tobody == Define_Tobody_sole then
                self.m_AniNode_Bottom:addNode(skillAni)
              else
                local z = roleObj:getZOrder()
                self:addNode(skillAni, z + 1)
              end
              local direction = roleObj:getDirection()
              local flipInfo
              if direction == DIRECTIOIN_LEFTUP then
                flipInfo = flip[1]
                skillAni:setRotation(flipInfo[3])
              else
                flipInfo = flip[2]
                skillAni:setRotation(flipInfo[3])
              end
              if flipInfo[1] ~= 0 or flipInfo[2] ~= 0 then
                if flipInfo[1] ~= 0 then
                  skillAni:setScaleX(-1 * scale)
                  offx = -offx
                end
                if flipInfo[2] ~= 0 then
                  skillAni:setScaleY(-1 * scale)
                  offy = -offy
                end
                skillAni:setPosition(x + bodyx + offx, y + bodyy + offy)
              end
              local x, y = skillAni:getPosition()
              skillAni:setPosition(ccp(x + flipInfo[4], y + flipInfo[5]))
            end)
            self:runAction(transition.sequence({act1, act2}))
          end
        end
      end
    end
  end
end
function CTestWarScene:displaySkillDaZhaoAniAtPos(skillID, pos)
  local aniInfoList = data_getSkillDaZhaoAniPath(skillID)
  for _, aniInfo in pairs(aniInfoList) do
    do
      local skillAniPath = aniInfo.aniPath
      local times = aniInfo.playtimes
      local offx = aniInfo.offx
      local offy = aniInfo.offy
      local tobody = aniInfo.tobody
      local dt = aniInfo.delaytime
      local scale = aniInfo.scale
      local sound = aniInfo.sound
      if skillAniPath then
        local act1 = CCDelayTime:create(dt)
        local act2 = CCCallFunc:create(function()
          local p = self:getDaZhaoAniPos(pos, tobody)
          local skillAni = warAniCreator.createAni(skillAniPath, 1000, nil, true, false)
          self.m_AniList[#self.m_AniList + 1] = skillAni
          skillAni:setPosition(p.x + offx, p.y + offy)
          skillAni:setScale(scale)
          if tobody == Define_Tobody_GroupMiddle_Bottom or tobody == Define_Tobody_BattleMiddle_Bottom then
            self:addNode(skillAni, 0)
          else
            self:addNode(skillAni, 99)
          end
          if sound ~= "0" then
            soundManager.playWarSound(sound)
          end
        end)
        self:runAction(transition.sequence({act1, act2}))
      end
    end
  end
  local shake, shaketime = data_getSkillShakeInfo(skillID)
  if shake > 0 then
    local act1 = CCDelayTime:create(shaketime)
    local act2 = CCCallFunc:create(function()
      self:ShakeScreenForWar(shake)
    end)
    self:runAction(transition.sequence({act1, act2}))
  end
end
function CTestWarScene:getDaZhaoAniPos(pos, tobody)
  if tobody == Define_Tobody_GroupFront then
    if pos < DefineDefendPosNumberBase then
      return self:getAttackXYByPos(103)
    else
      return self:getAttackXYByPos(10103)
    end
  elseif tobody == Define_Tobody_BattleMiddle or tobody == Define_Tobody_BattleMiddle_Bottom then
    local p1 = self:getRoleXYByPos(103)
    local p2 = self:getRoleXYByPos(10103)
    return ccp((p1.x + p2.x) / 2, (p1.y + p2.y) / 2)
  elseif pos < DefineDefendPosNumberBase then
    local p1 = self:getRoleXYByPos(3)
    local p2 = self:getRoleXYByPos(103)
    return ccp((p1.x + p2.x) / 2, (p1.y + p2.y) / 2)
  else
    local p1 = self:getRoleXYByPos(10003)
    local p2 = self:getRoleXYByPos(10103)
    return ccp((p1.x + p2.x) / 2, (p1.y + p2.y) / 2)
  end
end
function CTestWarScene:getAttackXYByPos(pos)
  local xy = self:getRoleXYByPos(pos)
  if self:ConvertWarPosOfDefend(pos) < DefineDefendPosNumberBase then
    xy.x = xy.x - 100
    xy.y = xy.y + 40
  else
    xy.x = xy.x + 100
    xy.y = xy.y - 40
  end
  return ccp(xy.x, xy.y)
end
function CTestWarScene:getRoleXYByPos(pos)
  local roleObj = self.m_WarRoleObj[pos]
  if roleObj == nil then
    return self:getXYByPos(pos)
  else
    local x, y = roleObj:getPosition()
    return ccp(x, y)
  end
end
function CTestWarScene:ShakeScreenForWar(shake)
  if shake <= 0 then
    return
  end
  local act1 = CCMoveBy:create(0.1, ccp(8, -10))
  local act2 = CCMoveBy:create(0.1, ccp(-4, 5))
  local act3 = CCMoveBy:create(0.1, ccp(-4, 5))
  local seq = transition.sequence({
    act1,
    act2,
    act3
  })
  self:runAction(CCRepeat:create(seq, shake))
end
function CTestWarScene:isChasing()
  return false
end
function CTestWarScene:getWarID()
  return 1
end
function CTestWarScene:getWarType()
  return WARTYPE_FUBEN
end
