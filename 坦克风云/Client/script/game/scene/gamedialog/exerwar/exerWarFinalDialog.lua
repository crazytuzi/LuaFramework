exerWarFinalDialog = {}

function exerWarFinalDialog:new(layerNum, period)
	local nc = {}
	setmetatable(nc, self)
	self.__index = self
	self.layerNum = layerNum
    self.period = period
    spriteController:addPlist("public/newButton180711.plist")
    spriteController:addTexture("public/newButton180711.png")
    spriteController:addPlist("public/championshipWar/championshipImage.plist")
    spriteController:addTexture("public/championshipWar/championshipImage.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acItemBg.plist")
    G_addResource8888(function()
        spriteController:addPlist("public/championshipWar/championshipImage2.plist")
        spriteController:addTexture("public/championshipWar/championshipImage2.png")
    end)
	return nc
end

function exerWarFinalDialog:initTableView()
	self.bgLayer = CCLayer:create()

    self:tick()
    exerWarVoApi:getFinalData(function(data)
        self.finalData = data
        if self.tv then
            self.tv:reloadData()
        end
    end)

	local tvOffsetH, tvPosY
	if G_getIphoneType() == G_iphone5 then
        tvOffsetH = 325
        tvPosY = 160
    elseif G_getIphoneType() == G_iphoneX then
        tvOffsetH = 350
        tvPosY = 200
    else --默认是 G_iphone4
        tvOffsetH = 290
        tvPosY = 135
    end
    local tempSp = CCSprite:createWithSpriteFrameName("csi_borderBg.png")
    self.nameBorderHeight = tempSp:getContentSize().height
    local tvSize = CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight - tvOffsetH)
    self.tv = G_createTableView(tvSize, 1, CCSizeMake(tvSize.width, 880), function(...) self:tvCallBack(...) end)
    self.tv:setPosition(0, tvPosY)
    self.tv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
    self.tv:setMaxDisToBottomOrTop(0)
    self.bgLayer:addChild(self.tv)
end

function exerWarFinalDialog:tvCallBack(cell, cellSize, idx, cellNum)
    if self.finalData == nil then
        do return end
    end
    local cellWidth, cellHeight = cellSize.width, cellSize.height

    local clipLayer = CCClippingNode:create() --裁切层
    clipLayer:setContentSize(CCSizeMake(cellWidth, cellHeight))
    clipLayer:setAnchorPoint(ccp(0.5, 0.5))
    clipLayer:setPosition(cellWidth / 2, cellHeight / 2)
    self.clipLayer = clipLayer
    stencilLayer = CCNode:create()
    stencilLayer:setContentSize(CCSizeMake(cellWidth, cellHeight))
    stencilLayer:setAnchorPoint(ccp(0.5, 0.5))
    stencilLayer:setPosition(getCenterPoint(clipLayer))
    clipLayer:setStencil(stencilLayer)
    cell:addChild(clipLayer, 2)
    self.stencilLayer = stencilLayer

    local roundTb = { { 1, 5, 3, 7, 2, 6, 4, 8 }, { 1, 3, 2, 4 }, { 1, 2 }, { 1 } } --轮数配置，后端交互使用
    local borderW = { 112, 150, 192, 192 }
    local characterTb = {8, 10, 12, 12}
    local firstPosX = { 5, 5, 64, 224 }
    local firstPosY = { cellHeight - 10, 10 }
    local spaceX = { 160, 160, 320, 0 }
    local spaceY = 60
    local group = { 8, 4, 2, 1, 0 }
    local fontSize = 20

    local groupIndex = -1
    for k, v in pairs(group) do
        if self.battleStatus == v then
            groupIndex = k
            break
        end
    end

    local iSize = SizeOfTable(self.finalData)
    for i = 1, iSize do
        local jSize = SizeOfTable(self.finalData[i])
        for j = 1, jSize do
            local xIndex, posYIndex, tempFlag = j, 1, -1
            if i ~= 4 and j > jSize / 2 then
                xIndex = j - jSize / 2
                posYIndex = 2
                tempFlag = 1
            end
            local round = roundTb[i][j]
            local tempData = self.finalData[i][round]
            -- local tempData = self.finalData[i][j]
            local binfo = {}
            if tempData[1] == 0 and tempData[2] == "" then
                binfo[1] = nil
            else
                binfo[1] = { tempData[1], tempData[2] }
            end
            if tempData[3] == 0 and tempData[4] == "" then
                binfo[2] = nil
            else
                binfo[2] = { tempData[3], tempData[4] }
            end

            local tempNameBorderSp
            for k = 1, 2 do
                local borderPic = "csi_borderBg.png"
                if i >= groupIndex or binfo[k] == nil or (binfo[1] and binfo[2] and ((k == 1 and tempData[5] == tempData[3]) or (k == 2 and tempData[5] == tempData[1]))) then
                    borderPic = "csi_borderGrayBg.png"
                end
                local nameBorderSp = LuaCCScale9Sprite:createWithSpriteFrameName(borderPic, CCRect(16, 20, 2, 2), function()
                    if i < groupIndex then
                        if binfo[1] == nil and binfo[2] == nil then --双方轮空不处理
                            do return end
                        end
                        if binfo[1] and binfo[2] then
                            exerWarVoApi:showReportListSmallDialog(self.layerNum + 1, self.period, i .. "-" .. round, i == 4)
                        else
                            G_showTipsDialog(getlocal("exerwar_finalNextTipsText"))
                            do return end
                        end
                    end
                    do return end
                end)
                nameBorderSp:setContentSize(CCSizeMake(borderW[i], self.nameBorderHeight))
                nameBorderSp:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                cell:addChild(nameBorderSp)
                nameBorderSp:setAnchorPoint(ccp(0, 0.5))
                local x, y = 0, 0
                if i == 1 then
                    x = firstPosX[i] + (xIndex - 1) * spaceX[i]
                    y = firstPosY[posYIndex] + tempFlag * self.nameBorderHeight / 2
                    if k == 2 then
                        y = y + tempFlag * (self.nameBorderHeight + 10)
                    end
                elseif i == 2 or i == 3 then
                    x = firstPosX[i] + ((xIndex == 1 and (k * xIndex) or (k + xIndex)) - 1) * spaceX[i]
                    y = firstPosY[posYIndex] + tempFlag * (2 * self.nameBorderHeight + 10 + (i - 1) * spaceY + (i - 2) * self.nameBorderHeight + self.nameBorderHeight / 2)
                elseif i == 4 then
                    x = firstPosX[i]
                    if k == 2 then
                        posYIndex = 2
                        tempFlag = 1
                    end
                    y = firstPosY[posYIndex] + tempFlag * (2 * self.nameBorderHeight + 10 + (i - 1) * spaceY + (i - 2) * self.nameBorderHeight + self.nameBorderHeight / 2)
                end
                nameBorderSp:setPosition(x, y)
                if i == 4 then
                    if tempNameBorderSp == nil then
                        tempNameBorderSp = {}
                    end
                    tempNameBorderSp[k] = nameBorderSp
                end
                
                local nameStr, isShowScore
                if i - 1 >= groupIndex then
                    if i - 1 == groupIndex then
                        nameStr = getlocal("championshipWar_settlementing")
                        self:playSettlementAni(nameBorderSp)
                    else
                        nameStr = getlocal("championshipWar_hold")
                    end
                else
                    if binfo[k] then
                        local tempInfo = Split(binfo[k][1], "-")
                        local serverId = tonumber(tempInfo[1])
                        local uid = tonumber(tempInfo[2])
                        if base.curZoneID == serverId and playerVoApi:getUid() == uid then
                            local tipSp = CCSprite:createWithSpriteFrameName("csi_hexagonBg.png")
                            tipSp:setScale(0.3)
                            tipSp:setPosition(nameBorderSp:getContentSize().width - tipSp:getContentSize().width * tipSp:getScale() / 2 - 5, nameBorderSp:getContentSize().height - 10)
                            nameBorderSp:addChild(tipSp, 2)
                        end
                        nameStr = binfo[k][2]
                        if i < groupIndex then
                            isShowScore = true
                        end
                    else
                        nameStr = getlocal("championshipWar_nullaid")
                    end
                end
                if nameStr then
                    nameStr = G_getShortStr(nameStr, characterTb[i])
                    local nameLb = GetTTFLabelWrap(nameStr, fontSize, CCSizeMake(borderW[i], 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
                    nameLb:setAnchorPoint(ccp(0, 0.5))
                    nameLb:setPosition(10, self.nameBorderHeight / 2)
                    nameBorderSp:addChild(nameLb)
                end

                if isShowScore == true and tempData[6] then
                    local scoreLb = GetTTFLabel((k == 1) and tempData[6] or (3 - tempData[6]), fontSize)
                    if i == 1 then
                        scoreLb:setPosition(nameBorderSp:getPositionX() + borderW[i] + 10, nameBorderSp:getPositionY() + scoreLb:getContentSize().height / 2 + ((tempFlag == 1) and 9 or 5))
                    elseif i == 4 then
                        scoreLb:setPosition(nameBorderSp:getPositionX() - 28, nameBorderSp:getPositionY() - tempFlag * (scoreLb:getContentSize().height / 2 + 5))
                    else
                        scoreLb:setPosition(nameBorderSp:getPositionX() + borderW[i] / 2 + ((k == 1) and -20 or 10), nameBorderSp:getPositionY() + tempFlag * (self.nameBorderHeight / 2 + spaceY / 2 - 8))
                    end
                    cell:addChild(scoreLb, 1)
                end
            end

            --画线
            if i == 4 and tempNameBorderSp then
                local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("csi_battleline" .. i .. ".png", CCRect(1, 8, 1, 2), function()end)
                local lineHeight = math.abs(tempNameBorderSp[1]:getPositionY() - tempNameBorderSp[2]:getPositionY())
                lineSp:setContentSize(CCSizeMake(34, lineHeight + 7))
                lineSp:setAnchorPoint(ccp(1, 0.5))
                lineSp:setPosition(tempNameBorderSp[2]:getPositionX() - 10, tempNameBorderSp[2]:getPositionY() + lineHeight / 2)
                cell:addChild(lineSp)
                if i == groupIndex then
                    local finalTipLb = GetTTFLabel(getlocal("championshipWar_settlementing"), fontSize)
                    finalTipLb:setAnchorPoint(ccp(0, 0.5))
                    finalTipLb:setPosition(tempNameBorderSp[2]:getPositionX() + 10, lineSp:getPositionY())
                    cell:addChild(finalTipLb)
                end
                if i + 1 == groupIndex then --显示总冠军图标
                    local winIndex
                    if tempData[5] == tempData[1] then
                        winIndex = 1
                    elseif tempData[5] == tempData[3] then
                        winIndex = 2
                    end
                    if winIndex then
                        local firstSp = CCSprite:createWithSpriteFrameName("csi_champion.png")
                        firstSp:setAnchorPoint(ccp(0, 0.5))
                        firstSp:setPosition(tempNameBorderSp[winIndex]:getPositionX() + borderW[i] + 20, tempNameBorderSp[winIndex]:getPositionY())
                        cell:addChild(firstSp)
                    end
                end
            else
                local linePic, lineSpFlipX = "csi_battleline" .. i .. ".png", false
                if i < groupIndex then
                    if binfo[1] and binfo[2] then
                        if tempData[5] == tempData[1] then
                            linePic = "csi_battleline" .. i .. "_1.png"
                        elseif tempData[5] == tempData[3] then
                            if i ~= 1 then
                                linePic = "csi_battleline" .. i .. "_1.png"
                                lineSpFlipX = true
                            else
                                linePic = "csi_battleline" .. i .. "_2.png"
                            end
                        end
                    else
                        if binfo[1] then
                            linePic = "csi_battleline" .. i .. "_1.png"
                        elseif binfo[2] then
                            if i ~= 1 then
                                linePic = "csi_battleline" .. i .. "_1.png"
                                lineSpFlipX = true
                            else
                                linePic = "csi_battleline" .. i .. "_2.png"
                            end
                        end
                    end
                end
                local lineSp = CCSprite:createWithSpriteFrameName(linePic)
                if lineSp then
                    if i == 1 then
                        lineSp:setAnchorPoint(ccp(1, 0.5))
                        lineSp:setPosition(firstPosX[i] + xIndex * spaceX[i] - 12, firstPosY[posYIndex] + tempFlag * 85)
                    elseif i == 2 or i == 3 then
                        local x = firstPosX[i] + 2 * xIndex * spaceX[i] - spaceX[i] - (i == 3 and borderW[i] / 2 - 25 or 10)
                        local y = firstPosY[posYIndex] + tempFlag * (2 * self.nameBorderHeight + 10 + (i - 1) * spaceY + (i - 2) * self.nameBorderHeight + self.nameBorderHeight / 2)
                        lineSp:setPosition(x, y + tempFlag * (self.nameBorderHeight / 2 + lineSp:getContentSize().height / 2))
                    end
                    lineSp:setFlipX(lineSpFlipX)
                    if posYIndex == 2 then
                        lineSp:setFlipY(true)
                    end
                    cell:addChild(lineSp)
                end
            end

        end
    end
end

--结算中的特殊效果显示
function exerWarFinalDialog:playSettlementAni(itemSp)
    if itemSp == nil or self.stencilLayer == nil or self.clipLayer == nil then
        do return end
    end
    local opacity, lightWidth, lightHeight = 50, 50, 6
    local itemSize = itemSp:getContentSize()
    local upStencilSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function () end)
    upStencilSp:setPosition(itemSp:getPositionX(), itemSp:getPositionY() + itemSize.height / 2)
    upStencilSp:setAnchorPoint(ccp(0, 1))
    upStencilSp:setContentSize(CCSizeMake(itemSize.width - 20, lightHeight))
    self.stencilLayer:addChild(upStencilSp)
    
    local downStencilSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function () end)
    downStencilSp:setPosition(itemSp:getPositionX() + 8, itemSp:getPositionY() - itemSize.height / 2)
    downStencilSp:setAnchorPoint(ccp(0, 0))
    downStencilSp:setContentSize(CCSizeMake(itemSize.width - 8, lightHeight))
    self.stencilLayer:addChild(downStencilSp)
    
    local anchor = {ccp(1, 1), ccp(1, 0)}
    local stencil = {upStencilSp, downStencilSp}
    for k = 1, 2 do
        local lightSp = CCSprite:createWithSpriteFrameName("acItemlight.png")
        local stencilSp = stencil[k]
        local beginPos = ccp(itemSp:getPositionX(), stencilSp:getPositionY())
        local targetPos = ccp(itemSp:getPositionX() + itemSp:getContentSize().width + lightWidth, beginPos.y)
        lightSp:setAnchorPoint(anchor[k])
        lightSp:setOpacity(opacity)
        lightSp:setScaleX(lightWidth / lightSp:getContentSize().width)
        lightSp:setScaleY(lightHeight / lightSp:getContentSize().height)
        self.clipLayer:addChild(lightSp, 2)
        lightSp:setPosition(beginPos)
        
        local mt = (targetPos.x - beginPos.x) / 250
        local moveTo = CCMoveTo:create(mt, targetPos)
        local fadeTo1 = CCFadeTo:create(mt / 2, 255)
        local fadeTo2 = CCFadeTo:create(mt / 2, opacity)
        local fadeSeq = CCSequence:createWithTwoActions(fadeTo1, fadeTo2)
        local spawnArr = CCArray:create()
        spawnArr:addObject(moveTo)
        spawnArr:addObject(fadeSeq)
        local spawnAc = CCSpawn:create(spawnArr)
        local function moveEnd()
            lightSp:setPosition(beginPos)
            lightSp:setOpacity(opacity)
        end
        local acArr = CCArray:create()
        acArr:addObject(spawnAc)
        acArr:addObject(CCCallFunc:create(moveEnd))
        local delay = CCDelayTime:create(0.5)
        acArr:addObject(delay)
        local seq = CCSequence:create(acArr)
        lightSp:runAction(CCRepeatForever:create(seq))
    end
end

function exerWarFinalDialog:tick()
    local ts, value = exerWarVoApi:getFinalTimeStatus()
    if ts and value then
        if self.battleStatus ~= value then
            self.battleStatus = value
            if self.tv then
                self.tv:reloadData()
            end
        end
        if ts == 0 and value == 0 then --已结束
        else
            if value == 1 then --距决赛
            else --距x强
            end
        end
    else --未开启
    end
end

function exerWarFinalDialog:dispose()
	self = nil
    spriteController:removePlist("public/newButton180711.plist")
    spriteController:removeTexture("public/newButton180711.png")
    spriteController:removePlist("public/championshipWar/championshipImage.plist")
    spriteController:removeTexture("public/championshipWar/championshipImage.png")
    spriteController:removePlist("public/championshipWar/championshipImage2.plist")
    spriteController:removeTexture("public/championshipWar/championshipImage2.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acItemBg.plist")
end