local seqAnimation = {}
function seqAnimation.extend(object)
  function object:preloadSkillAni(seqInfo)
    local recordDict = {}
    for _, info in pairs(seqInfo) do
      local skillID = info.skillID
      if skillID ~= nil then
        local aniInfoList = data_getSkillDaZhaoAniPath(skillID)
        if aniInfoList == nil then
          aniInfoList = {}
        end
        local aniInfoList_2 = data_getSkillObjAniPath(skillID)
        if aniInfoList_2 ~= nil then
          for _, aniInfo in pairs(aniInfoList_2) do
            aniInfoList[#aniInfoList + 1] = aniInfo
          end
        end
        for _, aniInfo in pairs(aniInfoList) do
          local skillAniPath = aniInfo.aniPath
          if skillAniPath then
            local pngPath
            if skillAniPath:sub(-6) == ".plist" then
              pngPath = skillAniPath:sub(1, -6) .. "png"
            elseif skillAniPath:sub(-4) == ".png" then
              pngPath = skillAniPath
            end
            if pngPath and recordDict[pngPath] == nil then
              recordDict[pngPath] = true
              addDynamicLoadTexture(pngPath, nil, {pixelFormat = kCCTexture2DPixelFormat_RGBA4444})
            end
          end
        end
      end
    end
  end
  function object:displaySkillDaZhaoAniAtPos(skillID, pos)
    if object:isChasing() then
      return
    end
    if skillID == nil then
      return
    end
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
          object:showSkillBackground()
          local act1 = CCDelayTime:create(dt)
          local act2 = CCCallFunc:create(function()
            local p = object:getDaZhaoAniPos(pos, tobody)
            local skillAni = warAniCreator.createAni(skillAniPath, times, nil, true, false, nil)
            skillAni:setPosition(p.x + offx, p.y + offy)
            skillAni:setScale(scale)
            if tobody == Define_Tobody_GroupMiddle_Bottom or tobody == Define_Tobody_BattleMiddle_Bottom then
              object.m_AniNode_Bottom:addNode(skillAni)
            else
              object.m_AniNode:addNode(skillAni)
            end
            if sound ~= "0" then
              soundManager.playWarSound(sound)
            end
          end)
          object:runAction(transition.sequence({act1, act2}))
        end
      end
    end
    local shake, shaketime = data_getSkillShakeInfo(skillID)
    if shake > 0 then
      local act1 = CCDelayTime:create(shaketime)
      local act2 = CCCallFunc:create(function()
        object:ShakeScreenForWar(shake)
      end)
      object:runAction(transition.sequence({act1, act2}))
    end
  end
  function object:displayObjAniAtPos(aniInfoList, pos)
    if object:isChasing() then
      return
    end
    local roleObj = object:getViewObjByPos(pos)
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
              if object.m_LastSkillAniTime[pos] == nil then
                object.m_LastSkillAniTime[pos] = {}
              end
              local tempInfo = object.m_LastSkillAniTime[pos]
              local curTime = cc.net.SocketTCP.getTime()
              local lastTime = tempInfo[skillAniPath] or 0
              if curTime - lastTime > 0.1 then
                tempInfo[skillAniPath] = curTime
                local act1 = CCDelayTime:create(dt)
                local act2 = CCCallFunc:create(function()
                  local skillAni = warAniCreator.createAni(skillAniPath, times, nil, true, false, nil)
                  local bodyx, bodyy = roleObj:getTobodyOff(tobody)
                  skillAni:setPosition(x + bodyx + offx, y + bodyy + offy)
                  skillAni:setScale(scale)
                  if tobody == Define_Tobody_sole then
                    object.m_AniNode_Bottom:addNode(skillAni)
                  else
                    local z = roleObj:getZOrder()
                    object.m_RoleNode:addNode(skillAni, z + 1)
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
                  if sound ~= "0" then
                    soundManager.playWarSound(sound)
                  end
                end)
                object:runAction(transition.sequence({act1, act2}))
              end
            end
          end
        end
      end
    end
  end
  function object:displaySkillObjAniAtPos(skillID, pos)
    if object:isChasing() then
      return
    end
    if skillID == nil then
      return
    end
    local aniInfoList = data_getSkillObjAniPath(skillID)
    object:displayObjAniAtPos(aniInfoList, pos)
  end
  function object:displaySkillObjAniAtPosWithDelay(dt, skillID, pos)
    if object:isChasing() then
      return
    end
    dt = dt or 0
    local act1 = CCDelayTime:create(dt)
    local act2 = CCCallFunc:create(function()
      object:displaySkillObjAniAtPos(skillID, pos)
    end)
    object:runAction(transition.sequence({act1, act2}))
  end
  function object:displayCertainObjAniAtPos(aniID, pos)
    if object:isChasing() then
      return
    end
    if aniID == nil then
      return
    end
    local aniInfoList = data_getSkillAniPathByAniIDList(aniID)
    object:displayObjAniAtPos(aniInfoList, pos)
  end
  function object:displayCertainObjAniAtPosWithDelay(dt, aniID, pos)
    if object:isChasing() then
      return
    end
    dt = dt or 0
    local act1 = CCDelayTime:create(dt)
    local act2 = CCCallFunc:create(function()
      object:displayCertainObjAniAtPos(aniID, pos)
    end)
    object:runAction(transition.sequence({act1, act2}))
  end
  function object:displayAttackAniAtObjPos(skillID, roleObj, targetPos)
    if object:isChasing() then
      return
    end
    if JudgeSkillIsMagicAttack(skillID) then
      return
    end
    local targetObj = object:getViewObjByPos(targetPos)
    if targetObj == nil then
      return
    end
    local roleType = roleObj:getShowingTypeId()
    local dir = roleObj:getDirection()
    local aniPath, aniDelay, off, scale, posType = data_getShapeHitAniInfo(roleType, dir)
    if aniPath ~= nil and aniDelay ~= nil and off ~= nil and scale ~= nil then
      do
        local x, y = targetObj:getPosition()
        if posType == 1 then
          x, y = roleObj:getPosition()
        end
        local pre_dt, end_dt = 0, 0
        if type(aniDelay) == "table" then
          pre_dt = aniDelay[1] or 0
          end_dt = aniDelay[2] or 0
        else
          pre_dt = aniDelay
        end
        local actList = {}
        local ani
        local function _DeleteFunc(aniObj)
          local a1 = CCFadeOut:create(end_dt)
          local a2 = CCCallFunc:create(function()
            aniObj:removeFromParentAndCleanup(true)
            aniObj = nil
          end)
          aniObj:runAction(transition.sequence({a1, a2}))
        end
        actList[#actList + 1] = CCDelayTime:create(pre_dt)
        actList[#actList + 1] = CCCallFunc:create(function()
          ani = CreateSeqAnimation(aniPath, 1, function()
            _DeleteFunc(ani)
          end, false, false)
          object.m_AniNode:addNode(ani)
          ani:setScale(scale)
          ani:setPosition(x + off[1], y + off[2])
        end)
        object:runAction(transition.sequence(actList))
      end
    end
  end
  function object:displayCatchPetAniAtPos(petPos, success)
    object:displayCertainObjAniAtPos(CATCHPET_ANIID, petPos)
    if success == 1 then
      do
        local roleObj = object:getViewObjByPos(petPos)
        if roleObj then
          if object:isChasing() then
            roleObj:setIsCatchByOther()
          else
            local actList = {}
            actList[#actList + 1] = CCDelayTime:create(0.2)
            actList[#actList + 1] = CCCallFunc:create(function()
              roleObj:setIsCatchByOther()
            end)
            object:runAction(transition.sequence(actList))
          end
        end
      end
    end
  end
  function object:displayEffectAniAtPosWithDelay(dt, pos, effectId)
    if object:isChasing() then
      return
    end
    dt = dt or 0
    if dt <= 0 then
      object:displayEffectAniAtPos(pos, effectId)
    else
      local actList = {}
      actList[#actList + 1] = CCDelayTime:create(dt)
      actList[#actList + 1] = CCCallFunc:create(function()
        object:displayEffectAniAtPos(pos, effectId)
      end)
      object:runAction(transition.sequence(actList))
    end
  end
  function object:displayEffectAniAtPos(pos, effectId)
    if object:isChasing() then
      return
    end
    local roleObj = object:getViewObjByPos(pos)
    if roleObj == nil then
      return
    end
    local curTime = cc.net.SocketTCP.getTime()
    local lastTime, offy = 0, 0
    local timeInfo = object.m_LastSkillNameTime[pos]
    if timeInfo ~= nil then
      lastTime = timeInfo[1]
      offy = timeInfo[2] - 30
    end
    if curTime - lastTime > 0.1 then
      offy = 0
    end
    object.m_LastSkillNameTime[pos] = {curTime, offy}
    local bodyHeight = roleObj:getBodyHeight()
    local posxy = object:getRoleXYByPos(pos)
    posxy.y = posxy.y + bodyHeight / 2 + offy - 20
    local effectAni = display.newSprite(string.format("xiyou/warskill/effectname_%d.png", effectId))
    object.m_AniNode:addNode(effectAni)
    effectAni:setPosition(posxy)
    local act1 = CCMoveBy:create(1, ccp(0, 40))
    local act4 = CCCallFunc:create(function()
      effectAni:removeFromParentAndCleanup(true)
    end)
    effectAni:runAction(transition.sequence({act1, act4}))
  end
  function object:displayEffectAniAtPos_2(pos, effectId)
    if object:isChasing() then
      return
    end
    local roleObj = object:getViewObjByPos(pos)
    if roleObj == nil then
      return
    end
    local bodyHeight = roleObj:getBodyHeight()
    local posxy = object:getRoleXYByPos(pos)
    posxy.y = posxy.y + bodyHeight / 2
    local effectAni = display.newSprite(string.format("xiyou/warskill/effectname_%d.png", effectId))
    object.m_AniNode:addNode(effectAni)
    effectAni:setPosition(posxy)
    effectAni:setScale(0.1)
    local dt = 0.1
    local act1 = CCScaleTo:create(dt, 1)
    local act2 = CCMoveBy:create(dt, ccp(0, 30))
    local act3 = CCSpawn:createWithTwoActions(act1, act2)
    local act5 = CCScaleTo:create(dt, 1.5)
    local act6 = CCMoveBy:create(dt, ccp(0, 30))
    local act7 = CCSpawn:createWithTwoActions(act5, act6)
    local act8 = CCScaleTo:create(dt, 1)
    local act10 = CCDelayTime:create(0.5)
    local act11 = CCCallFunc:create(function()
      effectAni:removeFromParentAndCleanup(true)
    end)
    effectAni:runAction(transition.sequence({
      act3,
      act7,
      act8,
      act10,
      act11
    }))
  end
  function object:displayRoleNeiDanAniAtPos(pos, ndList)
    local roleObj = object:getViewObjByPos(pos)
    if roleObj == nil then
      return
    end
    local bodyHeight = roleObj:getBodyHeight()
    local posxy = object:getRoleXYByPos(pos)
    posxy.x = posxy.x
    posxy.y = posxy.y + bodyHeight / 2 - 20
    for _, nd in pairs(ndList) do
      object:doRoleNeiDanAniAtPos(pos, nd, posxy)
    end
  end
  function object:doRoleNeiDanAniAtPos(pos, nd, posxy)
    if object:isChasing() then
      return
    end
    if nd == nil or nd == 0 then
      return
    end
    local aniPath = string.format("xiyou/warskill/skillname_%d.png", nd)
    local fullPath = CCFileUtils:sharedFileUtils():fullPathForFilename(aniPath)
    if not os.exists(fullPath) then
      return
    end
    local curTime = cc.net.SocketTCP.getTime()
    local lastTime, offy = 0, 0
    local timeInfo = object.m_LastSkillNameTime[pos]
    if timeInfo ~= nil then
      lastTime = timeInfo[1]
      offy = timeInfo[2] - 30
    end
    if curTime - lastTime > 0.1 then
      offy = 0
    end
    object.m_LastSkillNameTime[pos] = {curTime, offy}
    local ndAni = display.newSprite(aniPath)
    object.m_AniNode:addNode(ndAni)
    ndAni:setPosition(ccp(posxy.x, posxy.y + offy))
    ndAni:setOpacity(0)
    local actList = {}
    local act1 = CCFadeIn:create(0.2)
    local act2 = CCMoveBy:create(0.2, ccp(0, 20))
    actList[#actList + 1] = CCSpawn:createWithTwoActions(act1, act2)
    actList[#actList + 1] = CCMoveBy:create(1, ccp(0, 20))
    actList[#actList + 1] = CCFadeOut:create(0.3)
    actList[#actList + 1] = CCCallFunc:create(function()
      ndAni:removeFromParentAndCleanup(true)
    end)
    ndAni:runAction(transition.sequence(actList))
  end
  function object:isNeiDanActWhenStart(nd)
    return nd == NDSKILL_HONGYANBAIFA or nd == NDSKILL_MEIHUASANNONG or nd == NDSKILL_KAITIANPIDI
  end
  function object:displayRoleNeiDanAniAtPosWhenStart(pos, ndList)
    if object:isChasing() then
      return
    end
    if ndList == nil then
      return
    end
    local temp = {}
    for _, nd in pairs(ndList) do
      if object:isNeiDanActWhenStart(nd) then
        temp[#temp + 1] = nd
      end
    end
    if #temp > 0 then
      object:displayRoleNeiDanAniAtPos(pos, temp)
    end
  end
  function object:displayRoleNeiDanAniAtPosWhenDamage(pos, ndList)
    if object:isChasing() then
      return
    end
    if ndList == nil then
      return
    end
    local temp = {}
    for _, nd in pairs(ndList) do
      if not object:isNeiDanActWhenStart(nd) then
        temp[#temp + 1] = nd
      end
    end
    if #temp > 0 then
      object:displayRoleNeiDanAniAtPos(pos, temp)
    end
  end
  function object:displayRoleNeiDanAniAtPosWhenDamageWithDelay(dt, pos, ndList)
    if object:isChasing() then
      return
    end
    if ndList == nil then
      return
    end
    local temp_delay = {}
    local temp = {}
    for _, nd in pairs(ndList) do
      if nd == NDSKILL_WANFOCHAOZONG or nd == NDSKILL_GESHANDANIU then
        temp_delay[#temp_delay + 1] = nd
      else
        temp[#temp + 1] = nd
      end
    end
    if #temp_delay > 0 then
      dt = dt or 0
      local act1 = CCDelayTime:create(dt)
      local act2 = CCCallFunc:create(function()
        object:displayRoleNeiDanAniAtPosWhenDamage(pos, temp_delay)
      end)
      object:runAction(transition.sequence({act1, act2}))
    end
    if #temp > 0 then
      object:displayRoleNeiDanAniAtPosWhenDamage(pos, temp)
    end
  end
  function object:displayPetSkillAniAtPosWhenDamageWithDelay(dt, pos, petSkill, isTxFlag)
    if object:isChasing() then
      return
    end
    if petSkill == nil or petSkill == 0 then
      return
    end
    dt = dt or 0
    local act1 = CCDelayTime:create(dt)
    local act2 = CCCallFunc:create(function()
      object:displayPetSkillAniAtPosWhenDamage(pos, petSkill, isTxFlag)
    end)
    object:runAction(transition.sequence({act1, act2}))
  end
  function object:displayPetSkillAniAtPosWhenDamage(pos, petSkill, isTxFlag)
    if object:isChasing() then
      return
    end
    if petSkill == nil or petSkill == 0 then
      return
    end
    local roleObj = object:getViewObjByPos(pos)
    local aniPath = string.format("xiyou/warskill/skillname_%d.png", petSkill)
    if isTxFlag == true then
      aniPath = string.format("xiyou/warskill/txname_%d.png", petSkill)
    end
    local fullPath = CCFileUtils:sharedFileUtils():fullPathForFilename(aniPath)
    if not os.exists(fullPath) then
      return
    end
    local curTime = cc.net.SocketTCP.getTime()
    local lastTime, offy = 0, 0
    local timeInfo = object.m_LastSkillNameTime[pos]
    if timeInfo ~= nil then
      lastTime = timeInfo[1]
      offy = timeInfo[2] - 30
    end
    if curTime - lastTime > 0.1 then
      offy = 0
    end
    object.m_LastSkillNameTime[pos] = {curTime, offy}
    local petSkillAni = display.newSprite(aniPath)
    object.m_AniNode:addNode(petSkillAni)
    local posxy = object:getRoleXYByPos(pos)
    if roleObj then
      offy = offy + roleObj:getBodyHeight() / 2
    else
      offy = offy + 40
    end
    petSkillAni:setPosition(ccp(posxy.x, posxy.y + offy - 20))
    petSkillAni:setOpacity(0)
    local actList = {}
    local act1 = CCFadeIn:create(0.2)
    local act2 = CCMoveBy:create(0.2, ccp(0, 20))
    actList[#actList + 1] = CCSpawn:createWithTwoActions(act1, act2)
    actList[#actList + 1] = CCMoveBy:create(1, ccp(0, 20))
    actList[#actList + 1] = CCFadeOut:create(0.3)
    actList[#actList + 1] = CCCallFunc:create(function()
      petSkillAni:removeFromParentAndCleanup(true)
    end)
    petSkillAni:runAction(transition.sequence(actList))
  end
  function object:createNumberAni(numberTxt, fntPath, posxy, pos, param)
    local roleObj = object:getViewObjByPos(pos)
    local fntPath_n = string.format("xiyou/fnt/%s.fnt", fntPath)
    local fntPath_s = string.format("xiyou/fnt/%s_s.fnt", fntPath)
    local curTime = cc.net.SocketTCP.getTime()
    local lastTime, offy = 0, 0
    local timeInfo = object.m_LastHpMpNumberAniTime[pos]
    if timeInfo ~= nil then
      lastTime = timeInfo[1]
      offy = timeInfo[2] - 25
      if offy <= -125 then
        offy = 0
      end
    end
    if curTime - lastTime > 0.4 then
      offy = 0
    end
    object.m_LastHpMpNumberAniTime[pos] = {curTime, offy}
    local aniNode = display.newNode()
    object.m_AniNode:addNode(aniNode)
    aniNode:setPosition(posxy.x, posxy.y + offy)
    aniNode:setScale(0.1)
    local showText = ui.newBMFontLabel({
      text = numberTxt,
      font = fntPath_n,
      align = ui.TEXT_ALIGN_CENTER
    })
    aniNode:addChild(showText)
    local showText_s = ui.newBMFontLabel({
      text = numberTxt,
      font = fntPath_s,
      align = ui.TEXT_ALIGN_CENTER
    })
    aniNode:addChild(showText_s)
    showText_s:setVisible(false)
    if param then
      if _getEffectIsExisted(EFFECTTYPE_FURY, param) then
        local showText_k = ui.newBMFontLabel({
          text = "k",
          font = fntPath_n,
          align = ui.TEXT_ALIGN_CENTER
        })
        aniNode:addChild(showText_k)
        showText_k:setPosition(0, 25)
      elseif _getEffectIsExisted(EFFECTTYPE_FATALLY, param) then
        local showText_z = ui.newBMFontLabel({
          text = "z",
          font = fntPath_n,
          align = ui.TEXT_ALIGN_CENTER
        })
        aniNode:addChild(showText_z)
        showText_z:setPosition(0, 25)
      elseif _getEffectIsExisted(EFFECTTYPE_REVERBERATE, param) then
        local showText_f = ui.newBMFontLabel({
          text = "f",
          font = fntPath_n,
          align = ui.TEXT_ALIGN_CENTER
        })
        aniNode:addChild(showText_f)
        showText_f:setPosition(0, 25)
      end
    end
    local dt = 0.1
    local act1 = CCScaleTo:create(dt, 1)
    local act2 = CCMoveBy:create(dt, ccp(0, 30))
    local act3 = CCSpawn:createWithTwoActions(act1, act2)
    local act4 = CCCallFunc:create(function()
      showText:setVisible(false)
      showText_s:setVisible(true)
    end)
    local act5 = CCScaleTo:create(dt, 1.5)
    local act6 = CCMoveBy:create(dt, ccp(0, 30))
    local act7 = CCSpawn:createWithTwoActions(act5, act6)
    local act8 = CCScaleTo:create(dt, 1)
    local act9 = CCCallFunc:create(function()
      showText:setVisible(true)
      showText_s:setVisible(false)
    end)
    local act10 = CCDelayTime:create(0.5)
    local act11 = CCCallFunc:create(function()
      aniNode:removeFromParentAndCleanup(true)
    end)
    aniNode:runAction(transition.sequence({
      act3,
      act4,
      act7,
      act8,
      act9,
      act10,
      act11
    }))
  end
  function object:displayAniAtPosOfHpWithDelay(dt, deltaHp, posxy, pos, param)
    if object:isChasing() then
      return
    end
    dt = dt or 0
    local act1 = CCDelayTime:create(dt)
    local act2 = CCCallFunc:create(function()
      object:displayAniAtPosOfHp(deltaHp, posxy, pos, param)
    end)
    object:runAction(transition.sequence({act1, act2}))
  end
  function object:displayAniAtPosOfHp(deltaHp, posxy, pos, param)
    if object:isChasing() then
      return
    end
    if deltaHp < 0 then
      object:createNumberAni(tostring(deltaHp), "fnt_hp_sub", posxy, pos, param)
    else
      object:createNumberAni(string.format("+%d", deltaHp), "fnt_hp_add", posxy, pos, param)
    end
  end
  function object:displayAniAtPosOfMp(deltaMp, posxy, pos, param)
    if object:isChasing() then
      return
    end
    if deltaMp < 0 then
      object:createNumberAni(tostring(deltaMp), "fnt_mp_sub", posxy, pos, param)
    else
      object:createNumberAni(string.format("+%d", deltaMp), "fnt_mp_add", posxy, pos, param)
    end
  end
  function object:shoutUsingSkillNameAni(dt, pos, skillID)
    if object:isChasing() then
      return 0.1
    end
    local skillNameAni = warSkillName.new(skillID)
    object.m_AniNode:addNode(skillNameAni)
    local k = 1
    if g_WarScene:ConvertWarPosOfDefend(pos) > DefineDefendPosNumberBase then
      skillNameAni:setPosition(object.m_SkillAniPos_Enemy.x, object.m_SkillAniPos_Enemy.y)
      k = -1
    else
      skillNameAni:setPosition(object.m_SkillAniPos.x, object.m_SkillAniPos.y)
    end
    skillNameAni:setScale(0)
    local act0 = CCDelayTime:create(dt)
    local act1 = CCScaleTo:create(0.2, 1.1)
    local act2 = CCMoveBy:create(0.2, ccp(0, 50))
    local act3 = CCSpawn:createWithTwoActions(act1, act2)
    local act4 = CCScaleTo:create(0.1, 1)
    local act5 = CCDelayTime:create(0.2)
    local act6 = CCMoveBy:create(0.7, ccp(-200 * k, 0))
    local act7 = CCCallFunc:create(function()
      skillNameAni:Clear()
    end)
    local act8 = CCMoveBy:create(0.5, ccp(-40 * k, 0))
    local act9 = CCCallFunc:create(function()
      skillNameAni:DeleteSelf()
    end)
    skillNameAni:runAction(transition.sequence({
      act0,
      act3,
      act4,
      act5,
      act6,
      act7,
      act8,
      act9
    }))
    return 0.1
  end
  function object:ShakeScreenForWar(shake)
    if object:isChasing() then
      return
    end
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
    object:runAction(CCRepeat:create(seq, shake))
  end
  function object:createAttackXuanRenAni()
    if object.m_AttackXuanRenAni == nil then
      local plistpath = "xiyou/ani/ps_xr.plist"
      object.m_AttackXuanRenAni = CreateSeqAnimation(plistpath, -1, nil, nil, false, 12)
      object.m_AniNode:addNode(object.m_AttackXuanRenAni, 999)
      local pos = object:getXuanRenAniOfTeam(TEAM_ATTACK)
      object.m_AttackXuanRenAni:setPosition(pos)
      object.m_AttackXuanRenAni:setScale(2)
      object.m_AttackXuanRenAni:runAction(CCFadeIn:create(0.5))
    end
  end
  function object:createDefendXuanRenAni()
    if object.m_DefendXuanRenAni == nil then
      local plistpath = "xiyou/ani/ps_xr.plist"
      object.m_DefendXuanRenAni = CreateSeqAnimation(plistpath, -1, nil, nil, false, 12)
      object.m_AniNode:addNode(object.m_DefendXuanRenAni, 999)
      local pos = object:getXuanRenAniOfTeam(TEAM_DEFEND)
      object.m_DefendXuanRenAni:setPosition(pos)
      object.m_DefendXuanRenAni:setScale(2)
      object.m_DefendXuanRenAni:runAction(CCFadeIn:create(0.5))
    end
  end
  function object:deleteAttackXuanRenAni()
    if object.m_AttackXuanRenAni ~= nil then
      if object:isChasing() then
        object.m_AttackXuanRenAni:removeFromParentAndCleanup(true)
        object.m_AttackXuanRenAni = nil
      else
        local act1 = CCFadeOut:create(1)
        local act2 = CCCallFunc:create(function()
          object.m_AttackXuanRenAni:removeFromParentAndCleanup(true)
          object.m_AttackXuanRenAni = nil
        end)
        object.m_AttackXuanRenAni:runAction(transition.sequence({act1, act2}))
      end
    end
  end
  function object:deleteDefendXuanRenAni()
    if object.m_DefendXuanRenAni ~= nil then
      if object:isChasing() then
        object.m_DefendXuanRenAni:removeFromParentAndCleanup(true)
        object.m_DefendXuanRenAni = nil
      else
        local act1 = CCFadeOut:create(1)
        local act2 = CCCallFunc:create(function()
          object.m_DefendXuanRenAni:removeFromParentAndCleanup(true)
          object.m_DefendXuanRenAni = nil
        end)
        object.m_DefendXuanRenAni:runAction(transition.sequence({act1, act2}))
      end
    end
  end
  function object:damageXuanRenAni(pos)
    local team
    if pos < DefineDefendPosNumberBase then
      team = TEAM_DEFEND
    else
      team = TEAM_ATTACK
    end
    if team == TEAM_ATTACK then
      if object.m_AttackXuanRenAni ~= nil then
        if object:isChasing() then
          object.m_AttackXuanRenAni:removeFromParentAndCleanup(true)
          object.m_AttackXuanRenAni = nil
        else
          do
            local skillId = 30031
            local p = object:getXuanRenAniOfPos(pos)
            local act1 = CCEaseOut:create(CCMoveTo:create(0.3, p), 2)
            local act2 = CCCallFunc:create(function()
              object:displaySkillObjAniAtPos(skillId, pos)
            end)
            local act3 = CCDelayTime:create(1)
            local act4 = CCFadeOut:create(1)
            local act5 = CCCallFunc:create(function()
              object.m_AttackXuanRenAni:removeFromParentAndCleanup(true)
              object.m_AttackXuanRenAni = nil
            end)
            object.m_AttackXuanRenAni:runAction(transition.sequence({
              act1,
              act2,
              act3,
              act4,
              act5
            }))
          end
        end
        return true
      else
        return false
      end
    elseif object.m_DefendXuanRenAni ~= nil then
      if object:isChasing() then
        object.m_DefendXuanRenAni:removeFromParentAndCleanup(true)
        object.m_DefendXuanRenAni = nil
      else
        do
          local skillId = 30031
          local p = object:getXuanRenAniOfPos(pos)
          local act1 = CCEaseOut:create(CCMoveTo:create(0.3, p), 2)
          local act2 = CCCallFunc:create(function()
            object:displaySkillObjAniAtPos(skillId, pos)
          end)
          local act3 = CCDelayTime:create(1)
          local act4 = CCFadeOut:create(1)
          local act5 = CCCallFunc:create(function()
            object.m_DefendXuanRenAni:removeFromParentAndCleanup(true)
            object.m_DefendXuanRenAni = nil
          end)
          object.m_DefendXuanRenAni:runAction(transition.sequence({
            act1,
            act2,
            act3,
            act4,
            act5
          }))
        end
      end
      return true
    else
      return false
    end
  end
  function object:createAttackYiHuanAni()
    if object.m_AttackYiHuanAni == nil then
      local plistpath = "xiyou/ani/ps_yh.plist"
      object.m_AttackYiHuanAni = CreateSeqAnimation(plistpath, -1, nil, nil, false, 12)
      object.m_AniNode:addNode(object.m_AttackYiHuanAni, 1000)
      local pos = object:getYiHuanAniOfTeam(TEAM_ATTACK)
      object.m_AttackYiHuanAni:setPosition(pos)
      object.m_AttackYiHuanAni:runAction(CCFadeIn:create(0.5))
    end
  end
  function object:createDefendYiHuanAni()
    if object.m_DefendYiHuanAni == nil then
      local plistpath = "xiyou/ani/ps_yh.plist"
      object.m_DefendYiHuanAni = CreateSeqAnimation(plistpath, -1, nil, nil, false, 12)
      object.m_AniNode:addNode(object.m_DefendYiHuanAni, 1000)
      local pos = object:getYiHuanAniOfTeam(TEAM_DEFEND)
      object.m_DefendYiHuanAni:setPosition(pos)
      object.m_DefendYiHuanAni:runAction(CCFadeIn:create(0.5))
    end
  end
  function object:deleteAttackYiHuanAni()
    if object.m_AttackYiHuanAni ~= nil then
      if object:isChasing() then
        object.m_AttackYiHuanAni:removeFromParentAndCleanup(true)
        object.m_AttackYiHuanAni = nil
      else
        local act1 = CCFadeOut:create(1)
        local act2 = CCCallFunc:create(function()
          object.m_AttackYiHuanAni:removeFromParentAndCleanup(true)
          object.m_AttackYiHuanAni = nil
        end)
        object.m_AttackYiHuanAni:runAction(transition.sequence({act1, act2}))
      end
    end
  end
  function object:deleteDefendYiHuanAni()
    if object.m_DefendYiHuanAni ~= nil then
      if object:isChasing() then
        object.m_DefendYiHuanAni:removeFromParentAndCleanup(true)
        object.m_DefendYiHuanAni = nil
      else
        local act1 = CCFadeOut:create(1)
        local act2 = CCCallFunc:create(function()
          object.m_DefendYiHuanAni:removeFromParentAndCleanup(true)
          object.m_DefendYiHuanAni = nil
        end)
        object.m_DefendYiHuanAni:runAction(transition.sequence({act1, act2}))
      end
    end
  end
  function object:damageYiHuanAni(pos)
    local team
    if pos < DefineDefendPosNumberBase then
      team = TEAM_DEFEND
    else
      team = TEAM_ATTACK
    end
    if team == TEAM_ATTACK then
      if object.m_AttackYiHuanAni ~= nil then
        if object:isChasing() then
          object.m_AttackYiHuanAni:removeFromParentAndCleanup(true)
          object.m_AttackYiHuanAni = nil
        else
          do
            local skillId = 30031
            local skillTime, _ = data_getObjSkillAniKeepTime(skillId)
            local p = object:getYiHuanAniOfPos(pos)
            local act1 = CCEaseOut:create(CCMoveTo:create(0.3, p), 2)
            local act2 = CCCallFunc:create(function()
              object:displaySkillObjAniAtPos(skillId, pos)
            end)
            local act3 = CCDelayTime:create(skillTime)
            local act4 = CCFadeOut:create(1)
            local act5 = CCCallFunc:create(function()
              object.m_AttackYiHuanAni:removeFromParentAndCleanup(true)
              object.m_AttackYiHuanAni = nil
            end)
            object.m_AttackYiHuanAni:runAction(transition.sequence({
              act1,
              act2,
              act3,
              act4,
              act5
            }))
          end
        end
        return true
      else
        return false
      end
    elseif object.m_DefendYiHuanAni ~= nil then
      if object:isChasing() then
        object.m_DefendYiHuanAni:removeFromParentAndCleanup(true)
        object.m_DefendYiHuanAni = nil
      else
        do
          local skillId = 30031
          local skillTime, _ = data_getObjSkillAniKeepTime(skillId)
          local p = object:getYiHuanAniOfPos(pos)
          local act1 = CCEaseOut:create(CCMoveTo:create(0.3, p), 2)
          local act2 = CCCallFunc:create(function()
            object:displaySkillObjAniAtPos(skillId, pos)
          end)
          local act3 = CCDelayTime:create(skillTime)
          local act4 = CCFadeOut:create(1)
          local act5 = CCCallFunc:create(function()
            object.m_DefendYiHuanAni:removeFromParentAndCleanup(true)
            object.m_DefendYiHuanAni = nil
          end)
          object.m_DefendYiHuanAni:runAction(transition.sequence({
            act1,
            act2,
            act3,
            act4,
            act5
          }))
        end
      end
      return true
    else
      return false
    end
  end
  object.m_LastSkillAniTime = {}
  object.m_LastHpMpNumberAniTime = {}
  object.m_LastSkillNameTime = {}
end
return seqAnimation
