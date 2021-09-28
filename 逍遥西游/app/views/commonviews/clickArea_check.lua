clickArea_check = {}
function clickArea_check.extend(object)
  function object:clickArea_check_withObj(checkObj, clickOusideListener)
    local _clickOusideListener = clickOusideListener
    local touchBeganOutSide = false
    local parent = checkObj:getParent()
    local zOrder = checkObj:getZOrder()
    local clickLayer = Widget:create()
    parent:addChild(clickLayer, zOrder - 1)
    clickLayer:setAnchorPoint(ccp(0, 0))
    clickLayer:setTouchEnabled(true)
    clickLayer:ignoreContentAdaptWithSize(false)
    clickLayer:setSize(CCSize(display.width, display.height))
    local pos = parent:convertToNodeSpace(ccp(0, 0))
    clickLayer:setPosition(pos)
    local function _checkTouchOutSide(p)
      local cSize = checkObj:getContentSize()
      local ap = checkObj:getAnchorPoint()
      if p.x < -ap.x * cSize.width or p.x > (1 - ap.x) * cSize.width or p.y < -ap.y * cSize.height or p.y > (1 - ap.y) * cSize.height then
        return true
      else
        return false
      end
    end
    clickLayer:addTouchEventListener(function(touchObj, t)
      if t == TOUCH_EVENT_BEGAN then
        local touchPos = clickLayer:getTouchStartPos()
        local p = checkObj:convertToNodeSpace(ccp(touchPos.x, touchPos.y))
        touchBeganOutSide = _checkTouchOutSide(p)
      elseif t == TOUCH_EVENT_ENDED or t == TOUCH_EVENT_CANCELED then
        local touchPos = clickLayer:getTouchEndPos()
        local p = checkObj:convertToNodeSpace(ccp(touchPos.x, touchPos.y))
        if touchBeganOutSide and _checkTouchOutSide(p) and _clickOusideListener then
          _clickOusideListener()
        end
      end
    end)
  end
  function object:click_check_withObj(checkObj, clickListener, touchInsideListener, clickSoundType, useContentSize)
    local _clickListener = clickListener
    local _touchInsideListener = touchInsideListener
    local touchBeganInSide = false
    local hasTouchMoved = false
    if clickSoundType == nil then
      clickSoundType = 1
    end
    if useContentSize == nil then
      useContentSize = false
    end
    checkObj:setTouchEnabled(true)
    local function _checkTouchInSide(p)
      local cSize
      if checkObj.getRealRichTextSize and useContentSize ~= true then
        cSize = checkObj:getRealRichTextSize()
      elseif checkObj.getSize ~= nil then
        cSize = checkObj:getSize()
      else
        cSize = checkObj:getContentSize()
      end
      local ap = checkObj:getAnchorPoint()
      if p.x < -ap.x * cSize.width or p.x > (1 - ap.x) * cSize.width or p.y < -ap.y * cSize.height or p.y > (1 - ap.y) * cSize.height then
        return false
      else
        return true
      end
    end
    checkObj:addTouchEventListener(function(touchObj, t)
      if t == TOUCH_EVENT_BEGAN then
        local touchPos = checkObj:getTouchStartPos()
        local p = checkObj:convertToNodeSpace(ccp(touchPos.x, touchPos.y))
        touchBeganInSide = _checkTouchInSide(p)
        hasTouchMoved = false
        if touchBeganInSide then
          if _touchInsideListener then
            _touchInsideListener(true)
          end
          if clickSoundType ~= 0 then
            soundManager.playSound(string.format("xiyou/sound/clickbutton_%d.wav", clickSoundType))
          end
        end
        return true
      elseif t == TOUCH_EVENT_MOVED then
        local sPos = checkObj:getTouchStartPos()
        local touchPos = checkObj:getTouchMovePos()
        if not hasTouchMoved and math.abs(sPos.x - touchPos.x) + math.abs(sPos.y - touchPos.y) > 10 then
          hasTouchMoved = true
        end
        if not hasTouchMoved then
          local p = checkObj:convertToNodeSpace(ccp(touchPos.x, touchPos.y))
          local check = _checkTouchInSide(p)
          if _touchInsideListener then
            _touchInsideListener(check)
          end
        elseif _touchInsideListener then
          _touchInsideListener(false)
        end
      elseif t == TOUCH_EVENT_ENDED or t == TOUCH_EVENT_CANCELED then
        if not hasTouchMoved then
          local touchPos = checkObj:getTouchEndPos()
          local p = checkObj:convertToNodeSpace(ccp(touchPos.x, touchPos.y))
          if touchBeganInSide and _checkTouchInSide(p) and _clickListener then
            _clickListener()
          end
        end
        if _touchInsideListener then
          _touchInsideListener(false)
        end
      end
    end)
  end
  function object:attrclick_check_withWidgetObj(checkObj, attrName, posObj, paramListener, checkType, actObj)
    local function _showAttrTip()
      if data_AttrTip[attrName] ~= nil then
        local tempObj = posObj
        if tempObj == nil then
          tempObj = checkObj
        end
        local size = tempObj:getContentSize()
        local ap = tempObj:getAnchorPoint()
        local wPos = tempObj:convertToWorldSpace(ccp(size.width * -ap.x, size.height * -ap.y))
        CAttrDetailView.new(attrName, {
          x = wPos.x,
          y = wPos.y,
          w = size.width,
          h = size.height
        }, paramListener, true)
      end
    end
    if checkType == nil then
      checkType = 0
    end
    checkObj:setTouchEnabled(true)
    checkObj:addTouchEventListener(function(touchObj, t)
      if t == TOUCH_EVENT_BEGAN then
        checkObj._hasMoved = false
        if checkType == 0 and checkObj:isVisible() then
          _showAttrTip()
        end
        if actObj == nil then
          actObj = checkObj
        end
        actObj:setOpacity(200)
      elseif t == TOUCH_EVENT_MOVED then
        if not checkObj._hasMoved then
          local sPos = checkObj:getTouchStartPos()
          local mPos = checkObj:getTouchMovePos()
          if math.abs(sPos.x - mPos.x) + math.abs(sPos.y - mPos.y) > 10 then
            checkObj._hasMoved = true
          end
        end
      elseif t == TOUCH_EVENT_ENDED or t == TOUCH_EVENT_CANCELED then
        if not checkObj._hasMoved and checkType == 1 and checkObj:isVisible() then
          _showAttrTip()
        end
        if g_Click_Attr_View then
          g_Click_Attr_View:setCanDelete()
        end
        if actObj == nil then
          actObj = checkObj
        end
        actObj:setOpacity(255)
      end
    end)
  end
  function object:attrclick_check_withObj(checkObj, attrName, posObj, paramListener)
    if checkObj._clickCheckWidget == nil then
      local parent = checkObj:getParent()
      local x, y = checkObj:getPosition()
      local zOrder = checkObj:getZOrder()
      local size = checkObj:getContentSize()
      local ap = checkObj:getAnchorPoint()
      local tempWidget = Widget:create()
      parent:addChild(tempWidget, zOrder)
      tempWidget:setPosition(ccp(x, y))
      tempWidget:ignoreContentAdaptWithSize(false)
      tempWidget:setSize(CCSize(size.width, size.height))
      tempWidget:setAnchorPoint(ccp(ap.x, ap.y))
      object:attrclick_check_withWidgetObj(tempWidget, attrName, posObj, paramListener, 1, checkObj)
      checkObj._clickCheckWidget = tempWidget
    else
      object:attrclick_check_withWidgetObj(checkObj._clickCheckWidget, attrName, posObj, paramListener, 1, checkObj)
    end
    return checkObj._clickCheckWidget
  end
  function object:addclickAniForHeroAni(checkObj, posObj, offx, offy, clickFunc, visibleListener, touchListener, initAct)
    if offx == nil then
      offx = 0
    end
    if offy == nil then
      offy = 0
    end
    local parent = checkObj:getParent()
    local zOrder = checkObj:getZOrder()
    local ap = checkObj:getAnchorPoint()
    local x, y = checkObj:getPosition()
    local aniSprite = checkObj:getSprite()
    local size = aniSprite:getTextureRect().size
    local tempWidget = checkObj._addClickWidget
    if tempWidget == nil then
      tempWidget = Widget:create()
      parent:addChild(tempWidget, zOrder + 1)
      checkObj._addClickWidget = tempWidget
    end
    local px, py = posObj:getPosition()
    tempWidget:setPosition(ccp(px + offx, py + offy))
    tempWidget:ignoreContentAdaptWithSize(false)
    tempWidget:setSize(CCSize(size.width, size.height))
    tempWidget:setAnchorPoint(ccp(0.5, 0.1))
    local function _clickListener()
      if object.m_RoleAni_War and object.m_RoleAni_War._shape ~= checkObj._shape then
        object.m_RoleAni_War:removeFromParentAndCleanup(true)
        object.m_RoleAni_War = nil
      end
      if object.m_RoleAni_War and object.m_RoleAni_War:isVisible() then
        return
      end
      if object.m_RoleAni_War == nil then
        object.m_RoleAni_War, _, _ = createWarBodyByShape(checkObj._shape, DIRECTIOIN_RIGHTDOWN, checkObj._colorList)
        parent:addNode(object.m_RoleAni_War, zOrder)
        object.m_RoleAni_War:setPosition(x, y)
        object.m_RoleAni_War._shape = checkObj._shape
      end
      checkObj:setVisible(false)
      if visibleListener then
        visibleListener(false)
      end
      object.m_RoleAni_War:setVisible(true)
      if math.random(1, 2) == 1 then
        object.m_RoleAni_War:playAniWithName("attack_4", 1, function()
          if checkObj._addClickWidget == nil then
            return
          end
          checkObj:setVisible(true)
          if visibleListener then
            visibleListener(true)
          end
          object.m_RoleAni_War:setVisible(false)
        end, false)
        object:playNormalAttackWeaponAni(checkObj, posObj, offx, offy)
      else
        object.m_RoleAni_War:playAniWithName("magic_4", 1, function()
          if checkObj._addClickWidget == nil then
            return
          end
          checkObj:setVisible(true)
          if visibleListener then
            visibleListener(true)
          end
          object.m_RoleAni_War:setVisible(false)
        end, false)
      end
      soundManager.playShapeDlgSound(checkObj._shape)
    end
    tempWidget.__clicked = false
    tempWidget:setTouchEnabled(true)
    tempWidget:addTouchEventListener(function(touchObj, t)
      if t == TOUCH_EVENT_BEGAN then
        tempWidget._hasMoved = false
        if touchListener then
          touchListener(true)
        end
      elseif t == TOUCH_EVENT_MOVED then
        if not tempWidget._hasMoved then
          local sPos = tempWidget:getTouchStartPos()
          local mPos = tempWidget:getTouchMovePos()
          if math.abs(sPos.x - mPos.x) + math.abs(sPos.y - mPos.y) > 10 then
            tempWidget._hasMoved = true
            if touchListener then
              touchListener(false)
            end
          end
        end
      elseif (t == TOUCH_EVENT_ENDED or t == TOUCH_EVENT_CANCELED) and not tempWidget._hasMoved then
        if touchListener then
          touchListener(false)
        end
        tempWidget.__clicked = true
        if clickFunc then
          clickFunc()
        elseif _clickListener then
          _clickListener()
        end
      end
    end)
    if initAct ~= nil and initAct > 0 then
      local act1 = CCDelayTime:create(initAct)
      local act2 = CCCallFunc:create(function()
        if tempWidget.__clicked ~= true then
          if clickFunc then
            clickFunc()
          elseif _clickListener then
            _clickListener()
          end
        end
      end)
      checkObj:runAction(transition.sequence({act1, act2}))
    end
  end
  function object:addclickAniForPetAni(checkObj, posObj, offx, offy)
    if offx == nil then
      offx = 0
    end
    if offy == nil then
      offy = 0
    end
    local parent = checkObj:getParent()
    local zOrder = checkObj:getZOrder()
    local ap = checkObj:getAnchorPoint()
    local x, y = checkObj:getPosition()
    local aniSprite = checkObj:getSprite()
    local size = aniSprite:getTextureRect().size
    local tempWidget = checkObj._addClickWidget
    if tempWidget == nil then
      tempWidget = Widget:create()
      parent:addChild(tempWidget, zOrder + 1)
      checkObj._addClickWidget = tempWidget
    end
    local px, py = posObj:getPosition()
    tempWidget:setPosition(ccp(px + offx, py + offy))
    tempWidget:ignoreContentAdaptWithSize(false)
    tempWidget:setSize(CCSize(size.width, size.height))
    tempWidget:setAnchorPoint(ccp(0.5, 0.1))
    local function _clickListener()
      if checkObj._aniState == "attack" or checkObj._aniState == "magic" then
        return
      end
      if math.random(1, 2) == 1 then
        checkObj._aniState = "attack"
        checkObj:playAniWithName("attack_4", 1, function()
          if checkObj._addClickWidget == nil then
            return
          end
          checkObj._aniState = "guard"
          checkObj:playAniWithName("guard_4", -1)
        end, false)
        object:playNormalAttackWeaponAni(checkObj, posObj, offx, offy)
        object:playNormalAttackAni(checkObj, posObj, offx, offy)
      else
        checkObj._aniState = "magic"
        checkObj:playAniWithName("magic_4", 1, function()
          if checkObj._addClickWidget == nil then
            return
          end
          checkObj._aniState = "guard"
          checkObj:playAniWithName("guard_4", -1)
        end, false)
      end
      soundManager.playShapeDlgSound(checkObj._shape)
    end
    tempWidget:setTouchEnabled(true)
    tempWidget:addTouchEventListener(function(touchObj, t)
      if t == TOUCH_EVENT_BEGAN then
        tempWidget._hasMoved = false
      elseif t == TOUCH_EVENT_MOVED then
        if not tempWidget._hasMoved then
          local sPos = tempWidget:getTouchStartPos()
          local mPos = tempWidget:getTouchMovePos()
          if math.abs(sPos.x - mPos.x) + math.abs(sPos.y - mPos.y) > 10 then
            tempWidget._hasMoved = true
          end
        end
      elseif (t == TOUCH_EVENT_ENDED or t == TOUCH_EVENT_CANCELED) and not tempWidget._hasMoved and _clickListener then
        _clickListener()
      end
    end)
  end
  function object:playNormalAttackWeaponAni(checkObj, posObj, offx, offy)
    if offx == nil then
      offx = 0
    end
    if offy == nil then
      offy = 0
    end
    local aniInfo = data_getBodyNormalAttackAniByShape(checkObj._shape, DIRECTIOIN_RIGHTDOWN)
    local attAni = aniInfo.attAni
    if attAni ~= nil then
      do
        local attAni_offx = aniInfo.attAni_offx or 0
        local attAni_offy = aniInfo.attAni_offy or 0
        local attDelay = aniInfo.attAniDelay
        local flipx = aniInfo.attAni_Flip[1]
        local flipy = aniInfo.attAni_Flip[2]
        local act1 = CCDelayTime:create(attDelay)
        local act2 = CCCallFunc:create(function()
          local x2, y2 = posObj:getPosition()
          local parent2 = posObj:getParent()
          local z2 = posObj:getZOrder()
          local attAniSprite = warAniCreator.createAni(attAni, 1, nil, true, false)
          attAniSprite:setPosition(x2 + offx + attAni_offx, y2 + offy + attAni_offy)
          attAniSprite:setScale(2)
          if flipx ~= 0 then
            attAniSprite:setScaleX(-1)
          end
          if flipy ~= 0 then
            attAniSprite:setScaleY(-1)
          end
          parent2:addNode(attAniSprite, z2 + 3)
        end)
        object:runAction(transition.sequence({act1, act2}))
      end
    end
  end
  function object:playNormalAttackAni(checkObj, posObj, offx, offy)
    if offx == nil then
      offx = 0
    end
    if offy == nil then
      offy = 0
    end
    if checkObj._shape == SHAPEID_SHENLONG then
      do
        local aniPath, aniDelay, off, scale, posType = data_getShapeHitAniInfoByShape(checkObj._shape, DIRECTIOIN_RIGHTDOWN)
        if aniPath ~= nil and aniDelay ~= nil and off ~= nil and scale ~= nil then
          do
            local x, y = posObj:getPosition()
            local parent2 = posObj:getParent()
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
              parent2:addNode(ani)
              ani:setScale(scale)
              ani:setPosition(x + off[1] + offx, y + off[2] + offy)
            end)
            object:runAction(transition.sequence(actList))
          end
        end
      end
    end
  end
end
