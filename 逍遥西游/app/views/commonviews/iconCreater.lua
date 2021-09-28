local Disable_RBGA4444 = {
  [20004] = true,
  [20005] = true,
  [20009] = true,
  [20014] = true,
  [20022] = true
}
function getBodyDynamicLoadTextureMode(shapeID)
  if Disable_RBGA4444[shapeID] == true then
    return nil
  else
    return kCCTexture2DPixelFormat_RGBA4444
  end
end
function createBodyByShape(shapeID, compatible, colorList)
  if Disable_RBGA4444[shapeID] ~= true then
    setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
  end
  local bodyPath, offx, offy, color = data_getBodyPathByShape(shapeID, compatible)
  local body = CreateSeqAnimation(bodyPath, -1)
  if Disable_RBGA4444[shapeID] ~= true then
    resetDefaultAlphaPixelFormat()
  end
  body._shape = shapeID
  body._colorList = DeepCopyTable(colorList)
  if color ~= nil and type(color) == "table" and #color == 3 then
    body:setColor(ccc3(color[1], color[2], color[3]))
  end
  SetOneBodyChangeColor(body, shapeID, colorList)
  return body, offx, offy
end
function createBodyByZqShape(shapeID, compatible, colorList, direction)
  if Disable_RBGA4444[shapeID] ~= true then
    setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
  end
  local bodyPath, offx, offy, color = data_getBodyPathByZqShape(shapeID, compatible, direction)
  local body = CreateSeqAnimation(bodyPath, -1)
  if Disable_RBGA4444[shapeID] ~= true then
    resetDefaultAlphaPixelFormat()
  end
  body._shape = shapeID
  body._colorList = DeepCopyTable(colorList)
  if color ~= nil and type(color) == "table" and #color == 3 then
    body:setColor(ccc3(color[1], color[2], color[3]))
  end
  SetOneBodyChangeColor(body, shapeID, colorList)
  return body, offx, offy
end
function createBodyByRoleTypeID(typeId, compatible, colorList)
  local shapeID = data_getRoleShape(typeId)
  return createBodyByShape(shapeID, compatible, colorList)
end
function createWarBodyByShape(shapeID, direction, colorList)
  if Disable_RBGA4444[shapeID] ~= true then
    setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
  end
  local bodyPath, offx, offy, color = data_getWarBodyPathByShape(shapeID, direction)
  local body = CreateSeqAnimation(bodyPath, -1)
  if Disable_RBGA4444[shapeID] ~= true then
    resetDefaultAlphaPixelFormat()
  end
  body._shape = shapeID
  body._colorList = DeepCopyTable(colorList)
  if color ~= nil and type(color) == "table" and #color == 3 then
    body:setColor(ccc3(color[1], color[2], color[3]))
  end
  SetOneBodyChangeColor(body, shapeID, colorList)
  return body, offx, offy
end
function createWarBodyByRoleTypeID(typeId, direction, colorList)
  local shapeID = data_getRoleShape(typeId)
  return createWarBodyByShape(shapeID, direction, colorList)
end
function createBodyByShapeForDlg(shapeID, colorList)
  if Disable_RBGA4444[shapeID] ~= true then
    setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
  end
  local bodyPath, offx, offy, color = data_getBodyPathByShapeForDlg(shapeID)
  local body = CreateSeqAnimation(bodyPath, -1)
  if Disable_RBGA4444[shapeID] ~= true then
    resetDefaultAlphaPixelFormat()
  end
  body._shape = shapeID
  body._colorList = DeepCopyTable(colorList)
  if color ~= nil and type(color) == "table" and #color == 3 then
    body:setColor(ccc3(color[1], color[2], color[3]))
  end
  SetOneBodyChangeColor(body, shapeID, colorList)
  return body, offx, offy
end
function createBodyByRoleTypeIDForDlg(typeId, colorList)
  local shapeID = data_getRoleShape(typeId)
  return createBodyByShapeForDlg(shapeID, colorList)
end
function createHeadIconByShape(shapeID, autoSize, isGray, headPath)
  local headPath = headPath or data_getHeadPathByShape(shapeID)
  local headIcon
  if isGray == true then
    headIcon = display.newGraySprite(headPath)
  else
    headIcon = display.newSprite(headPath)
  end
  if autoSize ~= nil then
    local size = headIcon:getContentSize()
    headIcon:setScaleX(autoSize.width / size.width)
    headIcon:setScaleY(autoSize.height / size.height)
  end
  return headIcon
end
function createHeadIconByRoleTypeID(typeId, autoSize, isGray)
  local shapeID = data_getRoleShape(typeId)
  return createHeadIconByShape(shapeID, autoSize, isGray)
end
function createWidgetFrameHeadIconByRoleTypeID(typeId, autoSize, isGray, offsetxy, headPath)
  local pWidget = Widget:create()
  local bg
  if isGray == true then
    bg = display.newGraySprite("views/mainviews/pic_headiconbg.png")
  else
    bg = display.newSprite("views/mainviews/pic_headiconbg.png")
  end
  pWidget:addNode(bg, 0)
  pWidget._BgIcon = bg
  local wSize = bg:getContentSize()
  local shapeID = data_getRoleShape(typeId)
  local headIcon = createHeadIconByShape(shapeID, autoSize, isGray, headPath)
  pWidget:addNode(headIcon, 1)
  pWidget._HeadIcon = headIcon
  local scaleX = headIcon:getScaleX()
  local scaleY = headIcon:getScaleY()
  bg:setScaleX(scaleX)
  bg:setScaleY(scaleY)
  local x, y = bg:getPosition()
  local nox, noy = HEAD_OFF_X, HEAD_OFF_Y
  if offsetxy ~= nil then
    offsetxy.x = offsetxy.x or 0
    offsetxy.y = offsetxy.y or 0
    nox = offsetxy.x + HEAD_OFF_X
    noy = offsetxy.y + HEAD_OFF_Y
  end
  headIcon:setPosition(x + nox, y + noy)
  pWidget:ignoreContentAdaptWithSize(false)
  pWidget:setSize(wSize)
  return pWidget
end
function createClickHead(para)
  local roleTypeId = para.roleTypeId
  local autoSize = para.autoSize
  local clickListener = para.clickListener
  local noBgFlag = para.noBgFlag
  local offx = para.offx
  local offy = para.offy
  local clickDel = para.clickDel
  local LongPressTime = para.LongPressTime
  local LongPressListener = para.LongPressListener
  local LongPressEndListner = para.LongPressEndListner
  local clickSoundType = para.clickSoundType
  if clickSoundType == nil then
    clickSoundType = 1
  end
  local shapeID = data_getRoleShape(roleTypeId)
  local path = data_getHeadPathByShape(shapeID)
  local bgPath = "views/mainviews/pic_headiconbg.png"
  if noBgFlag == true then
    bgPath = nil
  end
  local obj = createOneClickObj({
    path = path,
    bgPath = bgPath,
    autoSize = autoSize,
    clickDel = clickDel,
    LongPressTime = LongPressTime,
    clickListener = clickListener,
    LongPressListener = LongPressListener,
    LongPressEndListner = LongPressEndListner,
    clickSoundType = clickSoundType,
    grayFlag = nil
  })
  if obj._BgIcon then
    local x, y = obj._BgIcon:getPosition()
    local bgSize = obj._BgIcon:getContentSize()
    local iconSize = obj._Icon:getContentSize()
    obj._Icon:setPosition(ccp(x + bgSize.width / 2 - iconSize.width / 2 + HEAD_OFF_X, y + bgSize.height / 2 - iconSize.height / 2 + HEAD_OFF_Y))
  end
  offx = offx or 0
  offy = offy or 0
  local x, y = obj._Icon:getPosition()
  obj._Icon:setPosition(x + offx, y + offy)
  if obj._BgIcon then
    local x, y = obj._BgIcon:getPosition()
    obj._BgIcon:setPosition(x + offx, y + offy)
  end
  local size = obj:getContentSize()
  obj:setSize(CCSize(size.width + 2 * offx, size.height + 2 * offy))
  return obj
end
function createClickPetHead(para)
  local roleTypeId = para.roleTypeId
  local autoSize = para.autoSize
  local clickListener = para.clickListener
  local noBgFlag = para.noBgFlag
  local offx = para.offx
  local offy = para.offy
  local clickDel = para.clickDel
  local LongPressTime = para.LongPressTime
  local LongPressListener = para.LongPressListener
  local LongPressEndListner = para.LongPressEndListner
  local isNeedFlag = para.isNeedFlag
  local shapeID = data_getRoleShape(roleTypeId)
  local path = data_getHeadPathByShape(shapeID)
  local bgPath = "views/mainviews/pic_headiconbg.png"
  if noBgFlag == true then
    bgPath = nil
  end
  if clickListener == nil then
    function clickListener(obj, t)
      if g_Click_PET_Head_View ~= nil then
        g_Click_PET_Head_View:removeFromParentAndCleanup(true)
      end
      local size = obj:getSize()
      local worldPos = obj:convertToWorldSpace(ccp(0, 0))
      g_Click_PET_Head_View = CPetDetailView.new(roleTypeId, false, {
        x = worldPos.x,
        y = worldPos.y,
        w = size.width,
        h = size.height,
        dirList = {TipsShow_Up_Dir, TipsShow_Down_Dir}
      })
    end
  end
  if LongPressListener == nil then
    function LongPressListener(obj, t)
      if g_Click_PET_Head_View ~= nil then
        g_Click_PET_Head_View:removeFromParentAndCleanup(true)
      end
      local size = obj:getSize()
      local worldPos = obj:convertToWorldSpace(ccp(0, 0))
      g_Click_PET_Head_View = CPetDetailView.new(roleTypeId, false, {
        x = worldPos.x,
        y = worldPos.y,
        w = size.width,
        h = size.height,
        dirList = {TipsShow_Up_Dir, TipsShow_Down_Dir}
      })
    end
  end
  if LongPressEndListner == nil then
    function LongPressEndListner(obj, t)
      if g_Click_PET_Head_View ~= nil then
        g_Click_PET_Head_View:removeFromParentAndCleanup(true)
        g_Click_PET_Head_View = nil
      end
    end
  end
  local obj = createOneClickObj({
    path = path,
    bgPath = bgPath,
    autoSize = autoSize,
    clickDel = clickDel,
    LongPressTime = LongPressTime,
    clickListener = clickListener,
    LongPressListener = LongPressListener,
    LongPressEndListner = LongPressEndListner,
    clickSoundType = nil,
    grayFlag = nil
  })
  if obj._BgIcon then
    local x, y = obj._BgIcon:getPosition()
    local bgSize = obj._BgIcon:getContentSize()
    local iconSize = obj._Icon:getContentSize()
    obj._Icon:setPosition(ccp(x + bgSize.width / 2 - iconSize.width / 2 + HEAD_OFF_X, y + bgSize.height / 2 - iconSize.height / 2 + HEAD_OFF_Y))
  end
  offx = offx or 0
  offy = offy or 0
  local x, y = obj._Icon:getPosition()
  obj._Icon:setPosition(x + offx, y + offy)
  if obj._BgIcon then
    local x, y = obj._BgIcon:getPosition()
    obj._BgIcon:setPosition(x + offx, y + offy)
  end
  local size = obj:getContentSize()
  obj:setSize(CCSize(size.width + 2 * offx, size.height + 2 * offy))
  if isNeedFlag then
    local img = display.newSprite("views/pic/pic_taskneeditem.png")
    img:setAnchorPoint(ccp(0, 1))
    local size = obj:getContentSize()
    img:setPosition(ccp(5, size.height - 5))
    obj:addNode(img)
    obj._needFlagImg = img
  end
  return obj
end
function createClickMonsterHead(para)
  local roleTypeId = para.roleTypeId
  local isBoss = para.isBoss
  local autoSize = para.autoSize
  local clickListener = para.clickListener
  local noBgFlag = para.noBgFlag
  local offx = para.offx
  local offy = para.offy
  local clickDel = para.clickDel
  local LongPressTime = para.LongPressTime
  local LongPressListener = para.LongPressListener
  local LongPressEndListner = para.LongPressEndListner
  local shapeID = data_getRoleShape(roleTypeId)
  local path = data_getHeadPathByShape(shapeID)
  local bgPath = "views/mainviews/pic_headiconbg.png"
  if isBoss then
    bgPath = "views/mainviews/pic_headiconbg_s.png"
  end
  if noBgFlag == true then
    bgPath = nil
  end
  if clickListener == nil then
    function clickListener(obj, t)
      if g_Click_MONSTER_Head_View ~= nil then
        g_Click_MONSTER_Head_View:removeFromParentAndCleanup(true)
      end
      local size = obj:getSize()
      local worldPos = obj:convertToWorldSpace(ccp(0, 0))
      g_Click_MONSTER_Head_View = CMonsterDetailView.new(roleTypeId, isBoss, false, {
        x = worldPos.x,
        y = worldPos.y,
        w = size.width,
        h = size.height,
        dirList = {TipsShow_Up_Dir, TipsShow_Down_Dir}
      })
    end
  end
  if LongPressListener == nil then
    function LongPressListener(obj, t)
      if g_Click_MONSTER_Head_View ~= nil then
        g_Click_MONSTER_Head_View:removeFromParentAndCleanup(true)
      end
      local size = obj:getSize()
      local worldPos = obj:convertToWorldSpace(ccp(0, 0))
      g_Click_MONSTER_Head_View = CMonsterDetailView.new(roleTypeId, isBoss, false, {
        x = worldPos.x,
        y = worldPos.y,
        w = size.width,
        h = size.height,
        dirList = {TipsShow_Up_Dir, TipsShow_Down_Dir}
      })
    end
  end
  if LongPressEndListner == nil then
    function LongPressEndListner(obj, t)
      if g_Click_MONSTER_Head_View ~= nil then
        g_Click_MONSTER_Head_View:removeFromParentAndCleanup(true)
        g_Click_MONSTER_Head_View = nil
      end
    end
  end
  local obj = createOneClickObj({
    path = path,
    bgPath = bgPath,
    autoSize = autoSize,
    clickDel = clickDel,
    LongPressTime = LongPressTime,
    clickListener = clickListener,
    LongPressListener = LongPressListener,
    LongPressEndListner = LongPressEndListner,
    clickSoundType = nil,
    grayFlag = nil
  })
  if obj._BgIcon then
    local x, y = obj._BgIcon:getPosition()
    local bgSize = obj._BgIcon:getContentSize()
    local iconSize = obj._Icon:getContentSize()
    obj._Icon:setPosition(ccp(x + bgSize.width / 2 - iconSize.width / 2 + HEAD_OFF_X, y + bgSize.height / 2 - iconSize.height / 2 + HEAD_OFF_Y))
  end
  offx = offx or 0
  offy = offy or 0
  local x, y = obj._Icon:getPosition()
  obj._Icon:setPosition(x + offx, y + offy)
  if obj._BgIcon then
    local x, y = obj._BgIcon:getPosition()
    obj._BgIcon:setPosition(x + offx, y + offy)
  end
  local size = obj:getContentSize()
  obj:setSize(CCSize(size.width + 2 * offx, size.height + 2 * offy))
  return obj
end
function createItemIcon(itemShape, autoSize, canUseFlag, canUpgradeFlag, canAddPoint)
  local iconPath = data_getItemPathByShape(itemShape)
  local itemIcon, topRightIcon
  if canUseFlag == nil then
    canUseFlag = true
  end
  if canUseFlag then
    itemIcon = display.newSprite(iconPath)
  else
    itemIcon = display.newGraySprite(iconPath)
    topRightIcon = display.newSprite("xiyou/pic/pic_item_cannotuse.png")
  end
  if canUseFlag then
    if canUpgradeFlag == nil then
      canUpgradeFlag = false
    end
    if canUpgradeFlag then
      topRightIcon = display.newSprite("xiyou/pic/pic_item_canupgrade.png")
    end
  end
  if canAddPoint == true then
    topRightIcon = display.newSprite("xiyou/pic/pic_item_cannotuse.png")
  end
  if autoSize ~= nil then
    local size = itemIcon:getContentSize()
    itemIcon:setScaleX(autoSize.width / size.width)
    itemIcon:setScaleY(autoSize.height / size.height)
  end
  if topRightIcon then
    itemIcon:addChild(topRightIcon)
    local size = itemIcon:getContentSize()
    topRightIcon:setPosition(size.width - 10, size.height - 10)
  end
  return itemIcon
end
function createClickItem(para)
  local itemID = para.itemID
  local autoSize = para.autoSize
  local num = para.num or 0
  local numType = para.numType
  local LongPressTime = para.LongPressTime
  local clickListener = para.clickListener
  local LongPressListener = para.LongPressListener
  local LongPressEndListner = para.LongPressEndListner
  local clickDel = para.clickDel
  local noBgFlag = para.noBgFlag
  local itemName = para.changeName
  local isNeedFlag = para.isNeedFlag
  local bgPath = para.bgPath or "xiyou/item/itembg.png"
  local myItemPath = para.myItemPath
  local itemShape = data_getItemShapeID(itemID)
  local path = data_getItemPathByShape(itemShape)
  if myItemPath then
    path = myItemPath
  end
  if noBgFlag == true then
    bgPath = nil
  end
  if clickListener == nil then
    function clickListener(obj, t)
      if g_Click_Item_View ~= nil then
        g_Click_Item_View:removeFromParentAndCleanup(true)
      end
      local size = obj:getSize()
      local worldPos = obj:convertToWorldSpace(ccp(0, 0))
      g_Click_Item_View = CItemDetailView.new(itemID, false, itemName, {
        x = worldPos.x,
        y = worldPos.y,
        w = size.width,
        h = size.height,
        dirList = {TipsShow_Up_Dir, TipsShow_Down_Dir}
      })
    end
  end
  if LongPressListener == nil then
    function LongPressListener(obj, t)
      if g_Click_Item_View ~= nil then
        g_Click_Item_View:removeFromParentAndCleanup(true)
      end
      local size = obj:getSize()
      local worldPos = obj:convertToWorldSpace(ccp(0, 0))
      g_Click_Item_View = CItemDetailView.new(itemID, false, itemName, {
        x = worldPos.x,
        y = worldPos.y,
        w = size.width,
        h = size.height,
        dirList = {TipsShow_Up_Dir, TipsShow_Down_Dir}
      })
    end
  end
  if LongPressEndListner == nil then
    function LongPressEndListner(obj, t)
      if g_Click_Item_View ~= nil then
        g_Click_Item_View:removeFromParentAndCleanup(true)
        g_Click_Item_View = nil
      end
    end
  end
  local clickObj = createOneClickObj({
    path = path,
    bgPath = bgPath,
    autoSize = autoSize,
    clickDel = clickDel,
    LongPressTime = LongPressTime,
    clickListener = clickListener,
    LongPressListener = LongPressListener,
    LongPressEndListner = LongPressEndListner,
    clickSoundType = nil,
    grayFlag = nil
  })
  if num ~= 0 then
    local numLabel = CCLabelTTF:create(string.format("%s", num), ITEM_NUM_FONT, 22)
    numLabel:setColor(ccc3(255, 255, 255))
    if numType == 1 and g_LocalPlayer then
      local myNum = g_LocalPlayer:GetItemNum(itemID)
      numLabel:setString(string.format("%d/%d", myNum, num))
      if num > myNum then
        numLabel:setColor(ccc3(255, 0, 0))
      else
        numLabel:setColor(ccc3(0, 255, 0))
      end
    end
    numLabel:setAnchorPoint(ccp(1, 0))
    local size = clickObj:getContentSize()
    numLabel:setPosition(ccp(size.width - 5, 5))
    clickObj:addNode(numLabel)
    clickObj._numLabel = numLabel
    AutoLimitObjSize(numLabel, 70)
  end
  if isNeedFlag then
    local img = display.newSprite("views/pic/pic_taskneeditem.png")
    img:setAnchorPoint(ccp(0, 1))
    local size = clickObj:getContentSize()
    img:setPosition(ccp(0, size.height))
    clickObj:addNode(img)
    clickObj._needFlagImg = img
  end
  return clickObj
end
function createClickSkill(para)
  local roleID = para.roleID
  local skillID = para.skillID
  local autoSize = para.autoSize
  local LongPressTime = para.LongPressTime
  local clickListener = para.clickListener
  local LongPressListener = para.LongPressListener
  local LongPressEndListner = para.LongPressEndListner
  local imgFlag = para.imgFlag
  local clickDel = para.clickDel
  local grayFlag = para.grayFlag
  local roleTypeId = para.roleTypeId
  local playerId = para.playerId
  local delBtnFlag = para.delBtnFlag
  local isBaitanPlayer = para.isBaitanPlayer
  local xiulianZhongFlag = para.xlFlag
  if delBtnFlag == nil then
    delBtnFlag = false
  end
  local path = data_getSkillShapePath(skillID)
  if xiulianZhongFlag == true then
    path = "xiyou/skill/skill_unknown.png"
  end
  if imgFlag == false then
    path = nil
  end
  local bgPath
  if clickListener == nil then
    function clickListener(obj, t)
      if g_Click_Skill_View ~= nil then
        g_Click_Skill_View:removeFromParentAndCleanup(true)
      end
      local size = obj:getSize()
      local worldPos = obj:convertToWorldSpace(ccp(0, 0))
      g_Click_Skill_View = CSkillDetailView.new(roleID, skillID, false, {
        x = worldPos.x,
        y = worldPos.y,
        w = size.width,
        h = size.height
      }, roleTypeId, playerId, delBtnFlag, isBaitanPlayer)
    end
  end
  if LongPressListener == nil then
    function LongPressListener(obj, t)
      if g_Click_Skill_View ~= nil then
        g_Click_Skill_View:removeFromParentAndCleanup(true)
      end
      local size = obj:getSize()
      local worldPos = obj:convertToWorldSpace(ccp(0, 0))
      g_Click_Skill_View = CSkillDetailView.new(roleID, skillID, false, {
        x = worldPos.x,
        y = worldPos.y,
        w = size.width,
        h = size.height
      }, roleTypeId, playerId, delBtnFlag, isBaitanPlayer)
    end
  end
  if LongPressEndListner == nil then
    function LongPressEndListner(obj, t)
      if g_Click_Skill_View ~= nil then
        g_Click_Skill_View:removeFromParentAndCleanup(true)
        g_Click_Skill_View = nil
      end
    end
  end
  local jie = data_getSkillStep(skillID)
  return createOneClickObj({
    path = path,
    bgPath = bgPath,
    autoSize = autoSize,
    clickDel = clickDel,
    LongPressTime = LongPressTime,
    clickListener = clickListener,
    LongPressListener = LongPressListener,
    LongPressEndListner = LongPressEndListner,
    clickSoundType = nil,
    grayFlag = grayFlag,
    skillJie = jie
  })
end
function createClickResItem(para)
  local resID = para.resID
  local num = para.num
  local autoSize = para.autoSize
  local clickListener = para.clickListener
  local clickDel = para.clickDel
  local noBgFlag = para.noBgFlag
  local LongPressTime = para.LongPressTime
  local LongPressListener = para.LongPressListener
  local LongPressEndListner = para.LongPressEndListner
  local bgPath = para.bgPath or "xiyou/item/itembg.png"
  local path = data_getResPathByResID(resID)
  if noBgFlag == true then
    bgPath = nil
  end
  local clickObj = createOneClickObj({
    path = path,
    bgPath = bgPath,
    autoSize = autoSize,
    clickDel = clickDel,
    LongPressTime = LongPressTime,
    clickListener = clickListener,
    LongPressListener = LongPressListener,
    LongPressEndListner = LongPressEndListner,
    clickSoundType = nil,
    grayFlag = nil
  })
  if num ~= 0 then
    local numLabel = CCLabelTTF:create(string.format("x%s", num), ITEM_NUM_FONT, 22)
    numLabel:setAnchorPoint(ccp(1, 0))
    local size = clickObj:getContentSize()
    numLabel:setPosition(ccp(size.width - 5, 5))
    numLabel:setColor(ccc3(255, 255, 255))
    clickObj:addNode(numLabel)
    clickObj._numLabel = numLabel
    AutoLimitObjSize(numLabel, 70)
  end
  return clickObj
end
function createClickButton(normalPath, disablePath, clickListener, clickTime, clickSoundType, disabledLongPress, isgrayFlag)
  clickTime = clickTime or 0.1
  if clickSoundType == nil then
    clickSoundType = 1
  end
  local LongPressHandler
  local function LongPressListener(obj, t)
    if LongPressHandler ~= nil then
      scheduler.unscheduleGlobal(LongPressHandler)
    end
    LongPressHandler = scheduler.scheduleGlobal(function()
      if clickListener then
        clickListener()
      end
      if clickSoundType ~= nil and clickSoundType ~= 0 then
        soundManager.playSound(string.format("xiyou/sound/clickbutton_%d.wav", clickSoundType))
      end
    end, clickTime)
  end
  local function LongPressEndListner(obj, t)
    if LongPressHandler ~= nil then
      scheduler.unscheduleGlobal(LongPressHandler)
      LongPressHandler = nil
    end
  end
  local longPressTime = 0.5
  if disabledLongPress == true then
    longPressTime = nil
  end
  local clickObj = createOneClickObj({
    path = normalPath,
    bgPath = nil,
    autoSize = nil,
    clickDel = nil,
    LongPressTime = longPressTime,
    clickListener = clickListener,
    LongPressListener = LongPressListener,
    LongPressEndListner = LongPressEndListner,
    clickSoundType = clickSoundType,
    grayFlag = isgrayFlag
  })
  clickObj._enabled = true
  if disablePath ~= nil then
    local x, y = clickObj._Icon:getPosition()
    local ap = clickObj._Icon:getAnchorPoint()
    local disableState = display.newSprite(disablePath)
    clickObj:addNode(disableState)
    disableState:setPosition(x, y)
    disableState:setAnchorPoint(ccp(ap.x, ap.y))
    disableState:setVisible(false)
    clickObj._DisableState = disableState
  end
  function clickObj:setButtonEnabled(enable)
    if clickObj._enabled == enable then
      return
    end
    clickObj._enabled = enable
    if enable then
      clickObj._Icon:setVisible(true)
      if clickObj._DisableState then
        clickObj._DisableState:setVisible(false)
      end
    elseif clickObj._DisableState then
      clickObj._DisableState:setVisible(true)
      clickObj._Icon:setVisible(false)
    end
    clickObj:setTouchEnabled(enable)
    clickObj:showOldEffect()
  end
  function clickObj:setButtonDisableState(enable)
    if enable then
      clickObj._Icon:setVisible(true)
      if clickObj._DisableState then
        clickObj._DisableState:setVisible(false)
      end
    elseif clickObj._DisableState then
      clickObj._DisableState:setVisible(true)
      clickObj._Icon:setVisible(false)
    end
  end
  function clickObj:stopLongPressClick()
    if LongPressHandler ~= nil then
      scheduler.unscheduleGlobal(LongPressHandler)
      LongPressHandler = nil
    end
  end
  return clickObj
end
function createOneClickObj(para)
  local path = para.path
  local bgPath = para.bgPath
  local autoSize = para.autoSize
  local clickDel = para.clickDel
  local LongPressTime = para.LongPressTime
  local clickListener = para.clickListener
  local LongPressListener = para.LongPressListener
  local LongPressEndListner = para.LongPressEndListner
  local clickSoundType = para.clickSoundType
  local grayFlag = para.grayFlag
  local skillJie = para.skillJie
  if path == nil and bgPath == nil and autoSize == nil then
    return nil
  end
  local icon, bgIcon
  if path ~= nil then
    if grayFlag then
      icon = display.newGraySprite(path)
    else
      icon = display.newSprite(path)
    end
    icon:setAnchorPoint(ccp(0, 0))
  end
  if bgPath ~= nil then
    bgIcon = display.newSprite(bgPath)
    bgIcon:setAnchorPoint(ccp(0, 0))
  end
  if skillJie ~= nil and skillJie > 2 and skillJie <= 5 and icon ~= nil then
    local jieImg = display.newSprite(string.format("views/warui/pic_jie%d.png", skillJie - 2))
    jieImg:setAnchorPoint(ccp(1, 0))
    icon:addChild(jieImg)
    local size = icon:getContentSize()
    jieImg:setPosition(ccp(size.width, -1))
  end
  if autoSize == nil then
    if bgIcon ~= nil then
      autoSize = bgIcon:getContentSize()
    elseif icon ~= nil then
      autoSize = icon:getContentSize()
    end
  end
  local bgSize
  if bgIcon ~= nil then
    bgSize = bgIcon:getContentSize()
  elseif icon ~= nil then
    bgSize = icon:getContentSize()
  end
  local clickObj = Widget:create()
  clickObj:setAnchorPoint(ccp(0, 0))
  clickObj:ignoreContentAdaptWithSize(false)
  clickObj:setSize(autoSize)
  if bgIcon ~= nil then
    bgIcon:setScaleX(autoSize.width / bgSize.width)
    bgIcon:setScaleY(autoSize.height / bgSize.height)
    clickObj:addNode(bgIcon)
    clickObj._BgIcon = bgIcon
  end
  if icon ~= nil then
    local iconSize = icon:getContentSize()
    icon:setScaleX(autoSize.width / bgSize.width)
    icon:setScaleY(autoSize.height / bgSize.height)
    icon:setPosition((1 - iconSize.width / bgSize.width) * autoSize.width / 2, (1 - iconSize.height / bgSize.height) * autoSize.height / 2)
    clickObj:addNode(icon)
    clickObj._Icon = icon
  end
  if LongPressTime == nil or LongPressTime == 0 then
    clickwidget.extendClickFunc(clickObj, clickListener, clickDel, clickSoundType)
  else
    clickwidget.extendLongPressAndClickFunc(clickObj, LongPressTime, clickListener, LongPressListener, LongPressEndListner, clickDel, clickSoundType)
  end
  return clickObj
end
