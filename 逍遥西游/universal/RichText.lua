CRichText = class("CRichText", function()
  return Widget:create()
end)
CRichText_AlignType_Left = 0
CRichText_AlignType_Center = 1
CRichText_AlignType_Right = 2
CRichText_AlignType_RightLeft = 3
CRichText_MessageType_Item = 1
CRichText_MessageType_Pet = 2
CRichText_MessageType_MakeTeam = 3
CRichText_MessageType_Skill = 4
CRichText_MessageType_BpVote = 5
CRichText_MessageType_WatchWar = 6
CRichText_MessageType_ToNPC = 7
CHANNEL_TEAM = 1
CHANNEL_WOLRD = 2
CHANNEL_SYS = 3
CHANNEL_HELP = 4
CHANNEL_EXTRA_TEAM = 5
CHANNEL_COMMON = 6
CHANNEL_BP_MSG = 7
CHANNEL_BP_TIP = 8
CHANNEL_FRIEND = 9
CHANNEL_KUAI_XUN = 10
CHANNEL_XINXI = 11
CHANNEL_ZHUBO = 12
CHANNEL_LOCAL = 13
CHANNEL_LOCALSYS = 14
CHANNEL_LaBa = 15
CRichText_MessageNPC_MarryTree = 1
CRichText_MessageNPC_HunChe = 2
function CRichText:ctor(para)
  para = para or {}
  self:setNodeEventEnabled(true)
  self.m_IconList = {
    "IS",
    "ISG",
    "IBSB",
    "IBSG",
    "IBSY",
    "IBSR",
    "IBSP",
    "IH",
    "IRP"
  }
  self.m_RichTextW = para.width or 300
  self.m_VerticalSpace = para.verticalSpace or 0
  self.m_EmptyLineH = para.emptyLineH or 20
  self.m_ClickTextHandler = para.clickTextHandler or nil
  self.m_CurTextColor = para.color or ccc3(255, 255, 255)
  self.m_CurTextSize = para.fontSize or 22
  self.m_CurTextFont = para.font or KANG_TTF_FONT
  self.m_AlignType = para.align or CRichText_AlignType_Left
  self.m_EmoteEmpty = para.emoteEmpty or 5
  self.m_MaxLineNum = para.maxLineNum
  self.m_NoMoreText = para.noMoreText or ".."
  self.m_CanNotAddFlag = false
  self.m_PosNode = Widget:create()
  self:addChild(self.m_PosNode)
  self:setAnchorPoint(ccp(0, 0))
  self.m_RichTextH = 0
  self.m_RealTextWith = 0
  self:_setRichTextSize(self.m_RichTextW, self.m_RichTextH)
  self.m_EndLineW = 0
  self.m_EndPosY = 0
  self.m_LineNum = 0
  self.m_ObjList = {}
end
function CRichText:onCleanup()
end
function CRichText:_setRichTextSize(width, height)
  self:ignoreContentAdaptWithSize(false)
  self:setSize(CCSize(width, height))
  self:setContentSize(CCSize(width, height))
  self.m_PosNode:setPosition(ccp(0, height))
end
function CRichText:_newLine()
  if self.m_MaxLineNum ~= nil and self.m_MaxLineNum <= self.m_LineNum then
    if self.m_CanNotAddFlag == false then
      self:_addMoreText(self.m_NoMoreText)
    end
    self.m_CanNotAddFlag = true
    return
  end
  local lastLineObj = self.m_ObjList[self.m_LineNum]
  local lastPosY = 0
  if lastLineObj then
    lastPosY = lastLineObj.posY
  end
  local maxH = self.m_EmptyLineH
  local posY = lastPosY - self.m_VerticalSpace - maxH
  local lineObj = {
    posX = 0,
    posY = posY,
    sizeW = 0,
    sizeH = 0,
    maxH = maxH,
    objs = {}
  }
  self.m_EndLineW = 0
  self.m_EndPosY = self.m_EndPosY - self.m_VerticalSpace - maxH
  self.m_LineNum = self.m_LineNum + 1
  self.m_ObjList[#self.m_ObjList + 1] = lineObj
  self:_setRichTextSize(self.m_RichTextW, -self.m_EndPosY)
end
function CRichText:_addMoreText(textStr)
  obj = CCLabelTTF:create(textStr, self.m_CurTextFont, self.m_CurTextSize, CCSize(0, 0), ui.TEXT_ALIGN_LEFT, ui.TEXT_VALIGN_CENTER)
  obj:setColor(self.m_CurTextColor)
  obj:setAnchorPoint(ccp(0, 0))
  local size = obj:getContentSize()
  local curLineObj = self.m_ObjList[self.m_LineNum]
  local delH = 0
  local delW = 0
  if curLineObj.maxH < size.height then
    delH = size.height - curLineObj.maxH
    curLineObj.maxH = size.height
    self.m_EndPosY = self.m_EndPosY - delH
    self:_setRichTextSize(self.m_RichTextW, -self.m_EndPosY)
  end
  curLineObj.sizeW = curLineObj.sizeW + size.width
  if self.m_AlignType == CRichText_AlignType_Left then
    delW = 0
  elseif self.m_AlignType == CRichText_AlignType_Center then
    delW = -size.width / 2
  elseif self.m_AlignType == CRichText_AlignType_Right or self.m_AlignType == CRichText_AlignType_RightLeft then
    delW = -size.width
  end
  for _, tempObj in pairs(curLineObj.objs) do
    local x, y = tempObj:getPosition()
    tempObj:setPosition(ccp(x + delW, y - delH))
  end
  local ObjX = self.m_EndLineW
  local ObjY = self.m_EndPosY
  if self.m_AlignType == CRichText_AlignType_Left then
    ObjX = self.m_EndLineW
  elseif self.m_AlignType == CRichText_AlignType_Center then
    ObjX = (self.m_RichTextW - self.m_EndLineW - size.width) / 2 + self.m_EndLineW
  elseif self.m_AlignType == CRichText_AlignType_Right or self.m_AlignType == CRichText_AlignType_RightLeft then
    ObjX = self.m_RichTextW - size.width
  end
  if isWidget then
    obj:setPosition(ccp(ObjX, ObjY))
    self.m_PosNode:addChild(obj)
  else
    obj:setPosition(ObjX, ObjY)
    self.m_PosNode:addNode(obj)
  end
  self.m_EndLineW = self.m_EndLineW + size.width
  curLineObj.objs[#curLineObj.objs + 1] = obj
  if self.m_EndLineW > self.m_RealTextWith then
    self.m_RealTextWith = self.m_EndLineW
  end
end
function CRichText:_addOneObj(obj, ignoreSizeFlag, isWidget, size, offXY, mid)
  if size == nil then
    size = obj:getContentSize()
  end
  if self.m_LineNum == 0 then
    self:_newLine()
  end
  if self.m_EndLineW >= self.m_RichTextW and ignoreSizeFlag == true then
    self:_newLine()
  end
  if self.m_RichTextW - self.m_EndLineW < size.width and ignoreSizeFlag == false then
    self:_newLine()
  end
  if self.m_CanNotAddFlag == true then
    return
  end
  local curLineObj = self.m_ObjList[self.m_LineNum]
  local delH = 0
  local delW = 0
  if curLineObj.maxH < size.height then
    delH = size.height - curLineObj.maxH
    curLineObj.maxH = size.height
    self.m_EndPosY = self.m_EndPosY - delH
    self:_setRichTextSize(self.m_RichTextW, -self.m_EndPosY)
  end
  curLineObj.sizeW = curLineObj.sizeW + size.width
  if self.m_AlignType == CRichText_AlignType_Left then
    delW = 0
  elseif self.m_AlignType == CRichText_AlignType_Center then
    delW = -size.width / 2
  elseif self.m_AlignType == CRichText_AlignType_Right or self.m_AlignType == CRichText_AlignType_RightLeft then
    delW = -size.width
  end
  for _, tempObj in pairs(curLineObj.objs) do
    local x, y = tempObj:getPosition()
    tempObj:setPosition(ccp(x + delW, y - delH))
  end
  local ObjX = self.m_EndLineW
  local ObjY = self.m_EndPosY
  if self.m_AlignType == CRichText_AlignType_Left then
    ObjX = self.m_EndLineW
  elseif self.m_AlignType == CRichText_AlignType_Center then
    ObjX = (self.m_RichTextW - self.m_EndLineW - size.width) / 2 + self.m_EndLineW
  elseif self.m_AlignType == CRichText_AlignType_Right or self.m_AlignType == CRichText_AlignType_RightLeft then
    ObjX = self.m_RichTextW - size.width
  end
  if offXY == nil then
    offXY = ccp(0, 0)
  end
  if mid == true then
    ObjY = self.m_EndPosY + curLineObj.maxH / 2
  end
  if isWidget then
    obj:setPosition(ccp(ObjX + offXY.x, ObjY + offXY.y))
    self.m_PosNode:addChild(obj)
  else
    obj:setPosition(ObjX + offXY.x, ObjY + offXY.y)
    self.m_PosNode:addNode(obj)
  end
  self.m_EndLineW = self.m_EndLineW + size.width
  curLineObj.objs[#curLineObj.objs + 1] = obj
  if self.m_EndLineW > self.m_RealTextWith then
    self.m_RealTextWith = self.m_EndLineW
  end
end
function CRichText:_addOneEmpty(w)
  if self.m_EndLineW > self.m_RichTextW then
    return
  end
  if self.m_LineNum == 0 then
    self:_newLine()
  end
  local curLineObj = self.m_ObjList[self.m_LineNum]
  local delH = 0
  local delW = 0
  curLineObj.sizeW = curLineObj.sizeW + w
  if self.m_AlignType == CRichText_AlignType_Left then
    delW = 0
  elseif self.m_AlignType == CRichText_AlignType_Center then
    delW = -w / 2
  elseif self.m_AlignType == CRichText_AlignType_Right or self.m_AlignType == CRichText_AlignType_RightLeft then
    delW = -w
  end
  for _, tempObj in pairs(curLineObj.objs) do
    local x, y = tempObj:getPosition()
    tempObj:setPosition(ccp(x + delW, y - delH))
  end
  self.m_EndLineW = self.m_EndLineW + w
  if self.m_EndLineW > self.m_RealTextWith then
    self.m_RealTextWith = self.m_EndLineW
  end
end
function CRichText:_addOneEmote(emoteID)
  if emoteID ~= nil and emoteID > 0 then
    local eff
    if emoteID <= Define_EmotionSY then
      local plistpath = string.format("xiyou/emote/emote%d.plist", emoteID)
      local times = -1
      eff = CreateSeqAnimation(plistpath, times, cblistener, autoDestroy, false)
    else
      local ePath = string.format("xiyou/emote/em%d.png", emoteID)
      eff = display.newSprite(ePath)
    end
    if eff then
      self:_addOneEmpty(self.m_EmoteEmpty)
      self:addOneNode({obj = eff})
      self:_addOneEmpty(self.m_EmoteEmpty)
    end
  end
end
function CRichText:_addOneResIcon(resID, iconH)
  local sizeH = iconH
  if sizeH == 0 then
    sizeH = self.m_CurTextSize + 6
  end
  local icon = display.newSprite(data_getResPathByResIDForRichText(resID))
  local iconSize = icon:getContentSize()
  local scale = sizeH / iconSize.height
  icon:setScale(scale)
  local mSize = CCSize(iconSize.width * scale, sizeH)
  self:addOneNode({obj = icon, size = mSize})
end
function CRichText:_addOneItemIcon(itemID, iconH)
  local sizeH = iconH
  if sizeH == 0 then
    sizeH = self.m_CurTextSize + 10
  end
  local shapeID = data_getItemShapeID(itemID)
  local icon = display.newSprite(data_getItemPathByShape(shapeID))
  local iconSize = icon:getContentSize()
  local scale = sizeH / iconSize.height
  icon:setScale(scale)
  local mSize = CCSize(iconSize.width * scale, sizeH)
  self:addOneNode({obj = icon, size = mSize})
end
function CRichText:_addOneIcon(name, iconH)
  local sizeH = iconH
  if sizeH == 0 then
    sizeH = self.m_CurTextSize + 6
  end
  local anchorPoint
  local bsWide = 12
  local redPointSize = 10
  local qhPointSize = 10
  if name == "IS" then
    icon = display.newSprite("views/fb/star.png")
  elseif name == "ISG" then
    icon = display.newSprite("views/fb/starGray.png")
  elseif name == "IBSB" then
    icon = display.newSprite("views/pic/pic_bs_blue.png")
    anchorPoint = ccp(0, -(sizeH - qhPointSize) / (qhPointSize * 2))
    sizeH = qhPointSize
  elseif name == "IBSG" then
    icon = display.newSprite("views/pic/pic_bs_green.png")
    anchorPoint = ccp(0, -(sizeH - qhPointSize) / (qhPointSize * 2))
    sizeH = qhPointSize
  elseif name == "IBSY" then
    icon = display.newSprite("views/pic/pic_bs_yellow.png")
    anchorPoint = ccp(0, -(sizeH - qhPointSize) / (qhPointSize * 2))
    sizeH = qhPointSize
  elseif name == "IBSR" then
    icon = display.newSprite("views/pic/pic_bs_red.png")
    anchorPoint = ccp(0, -(sizeH - qhPointSize) / (qhPointSize * 2))
    sizeH = qhPointSize
  elseif name == "IBSP" then
    icon = display.newSprite("views/pic/pic_bs_purl.png")
    anchorPoint = ccp(0, -(sizeH - qhPointSize) / (qhPointSize * 2))
    sizeH = qhPointSize
  elseif name == "IH" then
    icon = display.newSprite("views/pic/pic_holebg.png")
    anchorPoint = ccp(0, -(sizeH - qhPointSize) / (qhPointSize * 2))
    sizeH = qhPointSize
  elseif name == "IRP" then
    icon = display.newSprite("views/pic/pic_newtip.png")
    anchorPoint = ccp(0, -(sizeH - redPointSize) / (redPointSize * 2))
    sizeH = redPointSize
  end
  if icon ~= nil then
    local iconSize = icon:getContentSize()
    local scale = sizeH / iconSize.height
    icon:setScale(scale)
    local mSize
    if name == "IBSB" or name == "IBSG" or name == "IBSY" or name == "IBSR" or name == "IBSP" or name == "IH" then
      mSize = CCSize(iconSize.width * scale + 4, sizeH)
    else
      mSize = CCSize(iconSize.width * scale, sizeH)
    end
    self:addOneNode({
      obj = icon,
      size = mSize,
      anchorPoint = anchorPoint
    })
  end
end
function CRichText:_addChannel(channel)
  local path, midFlag, ap, offXY
  if channel == CHANNEL_TEAM then
    path = "views/pic/channel_team.png"
  elseif channel == CHANNEL_WOLRD then
    path = "views/pic/channel_world.png"
  elseif channel == CHANNEL_SYS then
    path = "views/pic/channel_sys.png"
  elseif channel == CHANNEL_HELP then
    path = "views/pic/channel_help.png"
  elseif channel == CHANNEL_BP_MSG or channel == CHANNEL_BP_TIP then
    path = "views/pic/channel_bangpai.png"
  elseif channel == CHANNEL_KUAI_XUN then
    path = "views/pic/channel_kuaixun.png"
  elseif channel == CHANNEL_XINXI then
    path = "views/pic/channel_xinxi.png"
  elseif channel == CHANNEL_COMMON then
    path = "views/pic/channel_common.png"
    midFlag = true
    ap = ccp(0, 0.5)
    offXY = ccp(5, 0)
  elseif channel == CHANNEL_ZHUBO then
    path = "views/pic/channel_zhubo.png"
  elseif channel == CHANNEL_LOCAL or channel == CHANNEL_LOCALSYS then
    path = "views/pic/channel_local.png"
  end
  if path ~= nil then
    local icon = display.newSprite(path)
    self:addOneNode({
      obj = icon,
      isWidget = false,
      ap = ap,
      mid = midFlag,
      offXY = offXY
    })
  end
end
function CRichText:_addAnalyseText(settingStr, text)
  if settingStr == "" then
    self:addOneText({textStr = text})
    return
  end
  local inputStrFlag = true
  local tempStr = ""
  local tempNum = 0
  local paraDict = {}
  for i = 1, string.len(settingStr) do
    local char = string.sub(settingStr, i, i)
    if char == ":" or char == "：" then
      inputStrFlag = false
    elseif char == "," or char == "，" then
      inputStrFlag = true
      if tempStr ~= "" then
        paraDict[tempStr] = tempNum
        tempStr = ""
        tempNum = 0
      end
    elseif inputStrFlag == true then
      tempStr = tempStr .. char
    elseif inputStrFlag == false and char >= "0" and char <= "9" then
      tempNum = tempNum * 10 + char
    end
  end
  if tempStr ~= "" then
    paraDict[tempStr] = tempNum
  end
  local textColor
  if paraDict.CI ~= nil then
    local itemId = paraDict.CI
    local itemPj = data_getItemPinjie(itemId)
    textColor = NameColor_Item[itemPj] or NameColor_Item[0]
  end
  local ColorValue = {
    R = ccc3(255, 0, 0),
    G = ccc3(0, 255, 0),
    B = ccc3(0, 0, 255),
    Y = ccc3(255, 255, 0),
    O = ccc3(255, 128, 0),
    W = ccc3(255, 255, 255),
    K = ccc3(247, 247, 115),
    CLH = ccc3(79, 181, 24),
    CQH = ccc3(80, 204, 255),
    CBA = ccc3(255, 196, 98),
    CWA = VIEW_DEF_WARNING_COLOR,
    CTP = ccc3(94, 211, 207),
    CZ0 = NameColor_MainHero[0],
    CZ1 = NameColor_MainHero[1],
    CZ2 = NameColor_MainHero[2],
    CZ3 = NameColor_MainHero[3],
    CZ4 = NameColor_MainHero[4]
  }
  if textColor == nil then
    for cName, color in pairs(ColorValue) do
      if paraDict[cName] == 0 then
        textColor = color
        break
      end
    end
  end
  if textColor == nil then
    local r = paraDict.r or 0
    local g = paraDict.g or 0
    local b = paraDict.b or 0
    textColor = ccc3(r, g, b)
  end
  local textSize = paraDict.F
  local textFont
  local TextFontValue = {
    [1] = "Arial",
    [2] = KANG_TTF_FONT
  }
  if paraDict.T then
    textFont = TextFontValue[paraDict.T]
  end
  local clickHandler
  if self.m_ClickTextHandler then
    do
      local msgId = paraDict.M
      local playerId = paraDict.MP
      local itemId = paraDict.MI
      local itemTypeId = paraDict.MT
      local petId = paraDict.MM
      local teamId = paraDict.MD
      local warId = paraDict.MW
      local npcId = paraDict.MN
      if msgId ~= nil then
        function clickHandler()
          self.m_ClickTextHandler(self, msgId, {
            playerId = playerId,
            itemId = itemId,
            itemTypeId = itemTypeId,
            petId = petId,
            teamId = teamId,
            warId = warId,
            npcId = npcId
          })
        end
      end
    end
  end
  local emote = paraDict.E
  self:_addOneEmote(emote)
  local spText = ""
  if paraDict.N1 ~= nil then
    local player = g_DataMgr:getPlayer()
    local roleIns = player:getObjById(player:getMainHeroId())
    if roleIns ~= nil then
      spText = roleIns:getProperty(PROPERTY_NAME)
    end
  elseif paraDict.N2 ~= nil then
    local player = g_DataMgr:getPlayer()
    local roleIns = player:getObjById(player:getMainHeroId())
    if roleIns ~= nil then
      local gender = roleIns:getProperty(PROPERTY_GENDER)
      local race = roleIns:getProperty(PROPERTY_RACE)
      local npcId = Shimen_NPCId[race][gender]
      _, spText = data_getRoleShapeAndName(npcId)
    end
  elseif paraDict.N3 ~= nil then
    do
      local npcId = paraDict.N3
      _, spText = data_getRoleShapeAndName(npcId)
      function clickHandler()
        SendMessage(MsgID_Richtext_GotoNPC, npcId)
        g_MapMgr:AutoRouteToNpc(npcId)
      end
    end
  elseif paraDict.N4 ~= nil then
    do
      local teleporterId = paraDict.N4
      if data_WorldMapTeleporter[teleporterId] then
        spText = data_WorldMapTeleporter[teleporterId].name
        function clickHandler()
          SendMessage(MsgID_Richtext_GotoTelP, teleporterId)
          g_MapMgr:LoadMapWithWorldMapTeleporter(teleporterId)
        end
      end
    end
  elseif paraDict.N5 ~= nil then
    local itemId = paraDict.N5
    local itemPj = data_getItemPinjie(itemId)
    textColor = NameColor_Item[itemPj] or NameColor_Item[0]
    spText = data_getItemName(itemId)
  elseif paraDict.N6 ~= nil then
    local fubenId = paraDict.N6
    spText = data_getFubenName(fubenId)
  end
  if spText ~= "" then
    self:addOneText({
      textStr = spText,
      textSize = textSize,
      textColor = textColor,
      textFont = textFont,
      clickHandler = clickHandler
    })
  end
  for _, resId in pairs(RESTYPELIST) do
    local iconName = string.format("IR%d", resId)
    if paraDict[iconName] ~= nil then
      self:_addOneResIcon(resId, paraDict[iconName])
    end
  end
  if paraDict.Channel ~= nil then
    self:_addChannel(paraDict.Channel)
  end
  for paraName, value in pairs(paraDict) do
    if string.sub(paraName, 1, 2) == "II" then
      local itemId = tonumber(string.sub(paraName, 3))
      self:_addOneItemIcon(itemId, value)
    end
  end
  for _, name in ipairs(self.m_IconList) do
    if paraDict[name] ~= nil then
      self:_addOneIcon(name, paraDict[name])
    end
  end
  self:addOneText({
    textStr = text,
    textSize = textSize,
    textColor = textColor,
    textFont = textFont,
    clickHandler = clickHandler
  })
end
function CRichText:getRichTextSize()
  return self:getSize()
end
function CRichText:getRealRichTextSize()
  local size = self:getSize()
  return CCSize(self.m_RealTextWith, size.height)
end
function CRichText:getLineNum()
  return self.m_LineNum
end
function CRichText:newLine()
  self:_newLine()
end
function CRichText:clearAll()
  for lineNum, lineData in pairs(self.m_ObjList) do
    local lineObjList = lineData.objs or {}
    for _, obj in pairs(lineObjList) do
      obj:removeFromParent()
    end
  end
  self.m_RealTextWith = 0
  self.m_EndLineW = 0
  self.m_EndPosY = 0
  self.m_LineNum = 0
  self.m_ObjList = {}
  self.m_RichTextH = 0
  self:_setRichTextSize(self.m_RichTextW, self.m_RichTextH)
end
function CRichText:addOneText(para)
  local textStr = para.textStr or ""
  if textStr == "" then
    return
  end
  local str, restStr = separateUTF8String(textStr, 50)
  local newPara = DeepCopyTable(para)
  newPara.textStr = str
  self:_RealAddOneText(newPara)
  if restStr ~= "" then
    local restPara = DeepCopyTable(para)
    restPara.textStr = restStr
    self:addOneText(restPara)
  end
end
function CRichText:_RealAddOneText(para)
  para = para or {}
  local textStr = para.textStr or ""
  local textSize = para.textSize or self.m_CurTextSize
  local textColor = para.textColor or self.m_CurTextColor
  local textFont = para.textFont or self.m_CurTextFont
  local clickHandler = para.clickHandler or nil
  local ignoreSizeFlag = para.ignoreSizeFlag or false
  self.m_AlignType = para.align or self.m_AlignType
  if textStr == "" then
    return
  end
  local newLinePos = string.find(textStr, "\n")
  if newLinePos ~= nil then
    local ls = string.sub(textStr, 1, newLinePos - 1) or ""
    local lsPara = DeepCopyTable(para)
    lsPara.textStr = ls
    self:addOneText(lsPara)
    self:_newLine()
    local rs = string.sub(textStr, newLinePos + 1) or ""
    local rsPara = DeepCopyTable(para)
    rsPara.textStr = rs
    self:addOneText(rsPara)
    return
  end
  local tempObj = CCLabelTTF:create(textStr, textFont, textSize, CCSize(0, 0), ui.TEXT_ALIGN_LEFT, ui.TEXT_VALIGN_CENTER)
  local restW = self.m_RichTextW - self.m_EndLineW
  if clickHandler ~= nil then
    if restW < tempObj:getContentSize().width and self.m_EndLineW ~= 0 then
      self:_newLine()
    end
    tempObj:setColor(textColor)
    tempObj:setAnchorPoint(ccp(0, 0))
    local size = tempObj:getContentSize()
    local newObj = clickwidget.createOneClickWidget(size.width, size.height, 0, 0, clickHandler, 10)
    newObj:addNode(tempObj)
    self:_addOneObj(newObj, true, true)
    return
  else
    if restW <= 0 then
      self:_newLine()
      restW = self.m_RichTextW
    end
    local ls, rs
    if restW >= tempObj:getContentSize().width then
      ls = textStr
      rs = ""
    else
      local n = GetRichTextUTF8Len(textStr, textFont) * restW / tempObj:getContentSize().width
      if restW == self.m_RichTextW then
        n = 2.1
      end
      ls, rs = SeparateRichTextUTF8Len(textStr, n, textFont)
    end
    if ls == "" then
      self:_newLine()
      restW = self.m_RichTextW
      local n = GetRichTextUTF8Len(textStr, textFont) * restW / tempObj:getContentSize().width
      if restW == self.m_RichTextW then
        n = 2.1
      end
      ls, rs = SeparateRichTextUTF8Len(textStr, n, textFont)
    end
    local obj = CCLabelTTF:create(ls, textFont, textSize, CCSize(0, 0), ui.TEXT_ALIGN_LEFT, ui.TEXT_VALIGN_CENTER)
    obj:setColor(textColor)
    obj:setAnchorPoint(ccp(0, 0))
    if clickHandler ~= nil then
      local size = obj:getContentSize()
      local newObj = clickwidget.createOneClickWidget(size.width, size.height, 0, 0, clickHandler, 10)
      newObj:addNode(obj)
      self:_addOneObj(newObj, true, true)
    else
      self:_addOneObj(obj, true, false)
    end
    if rs == "" then
      return
    end
    if para.align == CRichText_AlignType_RightLeft then
      para.align = CRichText_AlignType_Left
    end
    para.textStr = rs
    self:addOneText(para)
  end
end
function CRichText:addRichTextEmpty(w)
  self:_addOneEmpty(w)
end
function CRichText:addOneImg(para)
  para = para or {}
  local path = para.path or ""
  local ignoreSizeFlag = para.ignoreSizeFlag or false
  local clickHandler = para.clickHandler or nil
  local size = para.size or nil
  if path == "" then
    printLog("CRichText", "error插入空的图片,无视")
    return
  end
  local obj = display.newSprite(path)
  obj:setAnchorPoint(ccp(0, 0))
  if clickHandler ~= nil then
    local size = obj:getContentSize()
    local newObj = clickwidget.createOneClickWidget(size.width, size.height, 0, 0, clickHandler, 10)
    newObj:addNode(obj)
    self:_addOneObj(newObj, ignoreSizeFlag, true, size)
  else
    self:_addOneObj(obj, ignoreSizeFlag, false, size)
  end
end
function CRichText:addOneNode(para)
  para = para or {}
  local obj = para.obj or nil
  local ignoreSizeFlag = para.ignoreSizeFlag or false
  local isWidget = para.isWidget or false
  local size = para.size or nil
  local anchorPoint = para.anchorPoint
  local offXY = para.offXY
  local ap = para.ap or ccp(0, 0)
  local mid = para.mid
  if obj == nil then
    printLog("CRichText", "error插入空的节点,无视")
    return
  end
  if not isWidget then
    obj:setAnchorPoint(ap)
  end
  if anchorPoint then
    obj:setAnchorPoint(anchorPoint)
  end
  self:_addOneObj(obj, ignoreSizeFlag, isWidget, size, offXY, mid)
end
function CRichText:addRichText(text)
  text = string.gsub(text, "&lt;", "<")
  text = string.gsub(text, "&gt;", ">")
  text = string.gsub(text, "\t", string.rep(" ", 8))
  local startNum, endNum, s1, s2, s3 = text:find("(.-)#<(.-)>(.-)#")
  if startNum == nil then
    self:addOneText({textStr = text})
  else
    local newStr = string.sub(text, endNum + 1) or ""
    self:addOneText({textStr = s1})
    self:_addAnalyseText(s2, s3)
    self:addRichText(newStr)
  end
end
function CRichText:SetDefaultColor(color)
  self.m_CurTextColor = color
end
function CRichText:FadeIn(dt)
  for lineNum, lineData in pairs(self.m_ObjList) do
    local lineObjList = lineData.objs or {}
    for _, obj in pairs(lineObjList) do
      obj:runAction(CCFadeIn:create(dt))
    end
  end
end
function CRichText:FadeOut(dt)
  for lineNum, lineData in pairs(self.m_ObjList) do
    local lineObjList = lineData.objs or {}
    for _, obj in pairs(lineObjList) do
      obj:runAction(CCFadeOut:create(dt))
    end
  end
end
return CRichText
