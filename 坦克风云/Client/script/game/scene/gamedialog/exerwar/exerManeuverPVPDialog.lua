exerManeuverPVPDialog = {}

function exerManeuverPVPDialog:new(layerNum, period)
	local nc = {}
	setmetatable(nc, self)
	self.__index = self
	self.layerNum = layerNum
	self.period = period
    G_addResource8888(function()
        spriteController:addPlist("public/youhuaUI4.plist")
        spriteController:addTexture("public/youhuaUI4.png")
    end)
    spriteController:addPlist("serverWar/serverWar.plist")
	return nc
end

function exerManeuverPVPDialog:initTableView()
	self.bgLayer = CCLayer:create()
    self:tick()
end

function exerManeuverPVPDialog:showUI(tag)
    if type(self.curShowUITag) == "number" then
        local uiNode = tolua.cast(self.bgLayer:getChildByTag(self.curShowUITag), "CCNode")
        if uiNode then
            uiNode:removeFromParentAndCleanup(true)
            uiNode = nil
        end
    end
    if tag == 100 then
        self:settingsTroopsUI(tag)
    elseif tag == 101 then
        self:fightingUI(tag)
    elseif tag == 102 then
        self:reportListUI(tag)
    end
    self.curShowUITag = tag
end

function exerManeuverPVPDialog:isCanClose()
    if self.closeFlag == true and self.curShowUITag == 100 and self.troopsLayerObj and self.tempLineupsData then
        return exerWarVoApi:checkSameTroops(self.troopsLayerObj:getLineupsData(), self.tempLineupsData)
    end
    return true
end

function exerManeuverPVPDialog:settingsTroopsUI(tag)
	local stBg = tolua.cast(self.bgLayer:getChildByTag(tag), "CCLayer")
	if stBg then
		stBg:removeFromParentAndCleanup(true)
		stBg = nil
	end
    local stBgOffsetH, stBgPosY, tLayerPosY
    if G_getIphoneType() == G_iphone5 then
        stBgOffsetH = 330
        stBgPosY = 160
        tLayerPosY = 90
    elseif G_getIphoneType() == G_iphoneX then
        stBgOffsetH = 350
        stBgPosY = 180
        tLayerPosY = 120
    else --默认是 G_iphone4
        stBgOffsetH = 290
        stBgPosY = 135
        tLayerPosY = 60
    end
	local settingsTroopsBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    settingsTroopsBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30, G_VisibleSizeHeight - stBgOffsetH))
    settingsTroopsBg:setAnchorPoint(ccp(0.5, 0))
    settingsTroopsBg:setPosition(G_VisibleSizeWidth / 2, stBgPosY)
	settingsTroopsBg:setTag(tag)
	self.bgLayer:addChild(settingsTroopsBg)

	local troopsLayerObj = exerWarVoApi:createTroopsLayer(self.layerNum, exerWarVoApi:getBaseTroopsNum())
	local troopsLayer = troopsLayerObj.bgLayer
	troopsLayer:setPosition((settingsTroopsBg:getContentSize().width - troopsLayer:getContentSize().width) / 2, tLayerPosY)
	troopsLayerObj:setLineupsData(exerWarVoApi:getTroopsData())
	settingsTroopsBg:addChild(troopsLayer, 1)
    local canUseTroopsData = exerWarVoApi:getCanUseTroops()
    troopsLayerObj:setCanUseTroops(canUseTroopsData)
    self.troopsLayerObj = troopsLayerObj
    self.tempLineupsData = G_clone(troopsLayerObj:getLineupsData())
    self.closeFlag = true

	local function onClickHandler(tag, obj)
		if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if tag == 10 then
        	print("cjl ------>>>> 可用部队")
            if canUseTroopsData then
                exerWarVoApi:showAllTroopsSmallDialog(self.layerNum + 1, canUseTroopsData)
            else
                G_showTipsDialog(getlocal("exerwar_notHaveCanUseTroopsText"))
            end
        elseif tag == 11 then
        	print("cjl ------>>>> 保存部队")
            local saveData = troopsLayerObj:getLineupsData()
            local flag, status = exerWarVoApi:isTroopsFull(saveData, self.period)
            if flag == false then --不可保存部队
                if status then
                    G_showTipsDialog(getlocal("exerwar_saveTroopsErr" .. status))
                else
                    G_showTipsDialog(getlocal("exerwar_saveTroopsErr"))
                end
                do return end
            end
            if exerWarVoApi:checkSameTroops(saveData, self.tempLineupsData) == true then --部队信息未发生变化
                G_showTipsDialog(getlocal("arrange_nochange_troops_tip"))
                do return end
            end
        	exerWarVoApi:saveLineups(function()
        		print("cjl ------>>>> 保存部队成功！~")
                G_showTipsDialog(getlocal("save_success"))
                self.tempLineupsData = G_clone(saveData)
        	end, { saveData })
        elseif tag == 12 then
        	print("cjl ------>>>> 随机部队")
        	local lineupsData = exerWarVoApi:randomLineups()
        	troopsLayerObj:setLineupsData(lineupsData)
            G_showTipsDialog(getlocal("exerwar_randomTroopsSuccessText"))
        end
	end
	local btnScale, btnFontSize = 0.7, 24
	local canUseBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickHandler, 10, getlocal("exerwar_canUseTroopsText"), btnFontSize / btnScale)
	local saveBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickHandler, 11, getlocal("collect_border_save"), btnFontSize / btnScale)
	local randomBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickHandler, 12, getlocal("exerwar_randomTroopsText"), btnFontSize / btnScale)
    local menuArr = CCArray:create()
    menuArr:addObject(canUseBtn)
    menuArr:addObject(saveBtn)
    menuArr:addObject(randomBtn)
    local btnMenu = CCMenu:createWithArray(menuArr)
    btnMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    btnMenu:setPosition(ccp(0, 0))
    settingsTroopsBg:addChild(btnMenu)
    canUseBtn:setScale(btnScale)
    saveBtn:setScale(btnScale)
    randomBtn:setScale(btnScale)
    local offsetBtnPosY
    if G_getIphoneType() == G_iphone5 then
        offsetBtnPosY = 15
    elseif G_getIphoneType() == G_iphoneX then
        offsetBtnPosY = 30
    else --默认是 G_iphone4
        offsetBtnPosY = 5
    end
    local btnSpaceW, btnPosY = 55, saveBtn:getContentSize().height * btnScale / 2 + offsetBtnPosY
    saveBtn:setPosition(settingsTroopsBg:getContentSize().width / 2, btnPosY)
    canUseBtn:setPosition(saveBtn:getPositionX() - saveBtn:getContentSize().width * btnScale - btnSpaceW, btnPosY)
    randomBtn:setPosition(saveBtn:getPositionX() + saveBtn:getContentSize().width * btnScale + btnSpaceW, btnPosY)

    local offsetThemeLbPosY
    if G_getIphoneType() == G_iphone5 then
        offsetThemeLbPosY = 22
    elseif G_getIphoneType() == G_iphoneX then
        offsetThemeLbPosY = 27
    else --默认是 G_iphone4
        offsetThemeLbPosY = 10
    end
    local themeStr = getlocal("exerwar_maneuverTheme") .. exerWarVoApi:getManeuverThemeTitle()
    local themeLb = GetTTFLabelWrap(themeStr, 22, CCSizeMake(settingsTroopsBg:getContentSize().width - 6, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
    themeLb:setAnchorPoint(ccp(0.5, 0.5))
    themeLb:setPosition(settingsTroopsBg:getContentSize().width / 2, settingsTroopsBg:getContentSize().height - 3 - themeLb:getContentSize().height / 2 - offsetThemeLbPosY)
    themeLb:setColor(G_ColorYellowPro)
    settingsTroopsBg:addChild(themeLb)
end

function exerManeuverPVPDialog:fightingUI(tag)
    local bgSp = tolua.cast(self.bgLayer:getChildByTag(tag), "CCSprite")
    if bgSp then
        bgSp:removeFromParentAndCleanup(true)
        bgSp = nil
    end
    local bgSpOffsetH, bgSpPosY
    if G_getIphoneType() == G_iphone5 then
        bgSpOffsetH = 330
        bgSpPosY = 160
    elseif G_getIphoneType() == G_iphoneX then
        bgSpOffsetH = 350
        bgSpPosY = 180
    else --默认是 G_iphone4
        bgSpOffsetH = 290
        bgSpPosY = 135
    end
    local bgSp = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    bgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30, G_VisibleSizeHeight - bgSpOffsetH))
    bgSp:setAnchorPoint(ccp(0.5, 0))
    bgSp:setPosition(G_VisibleSizeWidth / 2, bgSpPosY)
    bgSp:setTag(tag)
    self.bgLayer:addChild(bgSp)
    local label = GetTTFLabelWrap(getlocal("exerwar_fighting"), 24, CCSizeMake(bgSp:getContentSize().width - 6, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    label:setPosition(bgSp:getContentSize().width / 2, bgSp:getContentSize().height / 2)
    label:setColor(G_ColorYellowPro)
    bgSp:addChild(label)
end

function exerManeuverPVPDialog:reportListUI(tag)
    local tvBg = tolua.cast(self.bgLayer:getChildByTag(tag), "CCSprite")
    if tvBg then
        tvBg:removeFromParentAndCleanup(true)
        tvBg = nil
    end
    local list, bestlist
    local listSize, bestlistSize = 0, 0
    local reortData = exerWarVoApi:getReportList(self.period)
    if reortData then
        if reortData.list then
            list = reortData.list
            listSize = SizeOfTable(list or {})
        end
        if reortData.bestlist then
            bestlist = reortData.bestlist
            bestlistSize = SizeOfTable(bestlist or {})
        end
    end
    local tvBgOffsetH, tvBgPosY
    if G_getIphoneType() == G_iphone5 then
        tvBgOffsetH = 330
        tvBgPosY = 160
    elseif G_getIphoneType() == G_iphoneX then
        tvBgOffsetH = 350
        tvBgPosY = 180
    else --默认是 G_iphone4
        tvBgOffsetH = 290
        tvBgPosY = 135
    end
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30, G_VisibleSizeHeight - tvBgOffsetH))
    tvBg:setAnchorPoint(ccp(0.5, 0))
    tvBg:setPosition(G_VisibleSizeWidth / 2, tvBgPosY)
    tvBg:setTag(tag)
    self.bgLayer:addChild(tvBg)

    local themeStr = getlocal("exerwar_maneuverTheme") .. exerWarVoApi:getManeuverThemeTitle(self.period)
    local themeLb = GetTTFLabelWrap(themeStr, 22, CCSizeMake(tvBg:getContentSize().width - 6, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop, "Helvetica-bold")
    themeLb:setAnchorPoint(ccp(0.5, 1))
    themeLb:setPosition(tvBg:getContentSize().width / 2, tvBg:getContentSize().height - 3 - 10)
    themeLb:setColor(G_ColorYellowPro)
    tvBg:addChild(themeLb)
    local tvSize = CCSizeMake(tvBg:getContentSize().width - 6, themeLb:getPositionY() - themeLb:getContentSize().height - 10 - 3)

    local isSelfBest
    if list and bestlist and listSize > 0 and bestlistSize > 0 then
        isSelfBest = true
        for k, v in pairs(bestlist) do
            if tonumber(playerVoApi:getUid()) ~= tonumber(v[2]) then
                isSelfBest = false
            end
        end
        if isSelfBest == true then
            bestlistSize = 0
        end
    end


    local bestPlayerName = ""
    local myTotalScore = 0
    local bestTotalScore = 0
    if list and listSize > 0 then
        for k, v in pairs(list) do
            myTotalScore = myTotalScore + tonumber(v[10])
        end
    end
    if bestlist and bestlistSize > 0 then
        for k, v in pairs(bestlist) do
            bestPlayerName = v[3]
            bestTotalScore = bestTotalScore + tonumber(v[10])
        end
        if bestPlayerName ~= "" then
            bestPlayerName = bestPlayerName .. getlocal("exerwar_bestTotalScoreText", {bestTotalScore})
        end
    end
    if bestTotalScore == 0 then
        bestPlayerName = ""
    end
    local tv
    local function tvCallBack(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            return 2 + (listSize == 0 and 1 or listSize) + (bestlistSize == 0 and 1 or bestlistSize)
        elseif fn == "tableCellSizeForIndex" then
            local cellHeight = 130
            if (idx == 1 and listSize == 0) or (idx == ((listSize == 0) and 3 or (listSize + 2)) and bestlistSize == 0) then
                cellHeight = 85
            elseif idx == 0 or idx == listSize + 1 or (listSize == 0 and idx == (listSize + 2)) then
                cellHeight = 80
            end
            return CCSizeMake(tvBg:getContentSize().width - 6, cellHeight)
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            local cellWidth = tvBg:getContentSize().width - 6
            local cellHeight = 130
            if (idx == 1 and listSize == 0) or (idx == ((listSize == 0) and 3 or (listSize + 2)) and bestlistSize == 0) then
                cellHeight = 85
                local str, color = getlocal("exerwar_notDataText2"), G_ColorGray
                if idx == 1 and listSize == 0 then
                    str = getlocal("exerwar_notDataText1")
                elseif isSelfBest == true and bestlistSize == 0 then
                    str, color = getlocal("exerwar_bestOfSelfText"), G_ColorWhite
                end
                local notLb = GetTTFLabelWrap(str, 24, CCSizeMake(cellWidth - 10, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
                notLb:setAnchorPoint(ccp(0.5, 0.5))
                notLb:setPosition(cellWidth / 2, cellHeight / 2)
                notLb:setColor(color)
                cell:addChild(notLb)
            elseif idx == 0 or idx == listSize + 1 or (listSize == 0 and idx == (listSize + 2)) then
                cellHeight = 80
                local tipsStr = getlocal("exerwar_bestText")
                local subTipsStr, subTipsStrColor = bestPlayerName, {nil}
                if idx == 0 then
                    tipsStr = getlocal("exerwar_maneuverEndText")
                    if myTotalScore == 0 then
                        subTipsStr = ""
                    else
                        local gradeStr
                        if bestTotalScore == 0 then
                            gradeStr = getlocal("exerwar_maneuverGradeText1")
                            subTipsStrColor = {nil, G_ColorOrange, nil}
                        else
                            local value = myTotalScore / bestTotalScore
                            if value >= 1 then
                                gradeStr = getlocal("exerwar_maneuverGradeText1")
                                subTipsStrColor = {nil, G_ColorOrange, nil}
                            elseif value < 1 and value >= 0.9 then
                                gradeStr = getlocal("exerwar_maneuverGradeText2")
                                subTipsStrColor = {nil, G_ColorPurple, nil}
                            elseif value < 0.9 and value >= 0.8 then
                                gradeStr = getlocal("exerwar_maneuverGradeText3")
                                subTipsStrColor = {nil, G_ColorBlue, nil}
                            else
                                gradeStr = getlocal("exerwar_maneuverGradeText4") 
                                subTipsStrColor = {nil, G_ColorGreen, nil}
                            end
                        end
                        subTipsStr = getlocal("exerwar_maneuverCurTotalScoreText", {myTotalScore, gradeStr})
                    end
                end
                local titleW = cellWidth - 50
                if G_getCurChoseLanguage() == "en" then
                    titleW = cellWidth - 180
                end
                local titleBg, titleLb, titleLbHeight = G_createNewTitle({tipsStr, 24, G_ColorYellowPro}, CCSizeMake(titleW, 0), nil, true, "Helvetica-bold")
                titleBg:setAnchorPoint(ccp(0.5, 0))
                titleBg:setPosition(cellWidth / 2, cellHeight - titleLbHeight - 10)
                cell:addChild(titleBg)
                if subTipsStr == "" then
                    titleBg:setPositionY((cellHeight - titleLbHeight) / 2)
                else
                    local sutTitleLb, sutTitleLbHeight = G_getRichTextLabel(subTipsStr, subTipsStrColor, 22, cellWidth - 20, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
                    sutTitleLb:setAnchorPoint(ccp(0.5, 1))
                    sutTitleLb:setPosition(cellWidth / 2, titleBg:getPositionY() - 5)
                    cell:addChild(sutTitleLb)
                end
            else
                local data
                if idx <= listSize then
                    data = list[idx]
                else
                    data = bestlist[idx - listSize - ((listSize == 0) and 2 or 1)]
                end
                if data then
                    local id = data[1]
                    -- local aName = data[3]
                    local rate = data[5]
                    -- local dName = data[7]
                    local isVictory = (data[9] == 1)
                    local score = data[10]
                    local fontSize = 22
                    local bgWidth, bgHeight = cellWidth / 2 - 35, cellHeight - 10

                    local resultBgL = CCSprite:createWithSpriteFrameName("ltzdzCampBg" .. (isVictory and 1 or 2) .. ".png")
                    resultBgL:setFlipX(true)
                    resultBgL:setFlipY(isVictory)
                    resultBgL:setScaleX(bgWidth / resultBgL:getContentSize().width)
                    resultBgL:setScaleY(bgHeight / resultBgL:getContentSize().height)
                    resultBgL:setPosition(cellWidth / 2 - bgWidth / 2 - 20, cellHeight / 2)
                    -- resultBgL:setOpacity(255 * 0.3)
                    cell:addChild(resultBgL)
                    local resultBgR = CCSprite:createWithSpriteFrameName("ltzdzCampBg" .. (isVictory and 1 or 2) .. ".png")
                    resultBgR:setFlipY(isVictory)
                    resultBgR:setScaleX(bgWidth / resultBgR:getContentSize().width)
                    resultBgR:setScaleY(bgHeight / resultBgR:getContentSize().height)
                    resultBgR:setPosition(cellWidth / 2 + bgWidth / 2 + 20, cellHeight / 2)
                    -- resultBgR:setOpacity(255 * 0.3)
                    cell:addChild(resultBgR)

                    local statusSp = CCSprite:createWithSpriteFrameName(isVictory and "winnerMedal.png" or "loserMedal.png")
                    statusSp:setAnchorPoint(ccp(0.5, 0))
                    statusSp:setPosition(resultBgL:getPositionX() - bgWidth / 2 + statusSp:getContentSize().width / 2 + 25, resultBgL:getPositionY() - bgHeight / 2 + 5)
                    cell:addChild(statusSp)
                    local statusLb = GetTTFLabel(getlocal(isVictory and "fight_content_result_win" or "fight_content_result_defeat"), fontSize)
                    statusLb:setColor(isVictory and G_ColorGreen or G_ColorRed)
                    statusLb:setAnchorPoint(ccp(0.5, 1))
                    statusLb:setPosition(statusSp:getPositionX(), resultBgL:getPositionY() + bgHeight / 2 - 5)
                    cell:addChild(statusLb)

                    local rateLb = GetTTFLabel(getlocal("exerwar_killRateText"), fontSize)
                    local rateValueLb = GetTTFLabel(G_GetPreciseDecimal(rate * 100, 1) .. "%", fontSize)
                    rateLb:setAnchorPoint(ccp(1, 0))
                    rateValueLb:setAnchorPoint(ccp(1, 0))
                    rateValueLb:setPosition(resultBgR:getPositionX() + bgWidth / 2 - 25, cellHeight / 2 + 5)
                    rateLb:setPosition(rateValueLb:getPositionX() - rateValueLb:getContentSize().width, rateValueLb:getPositionY())
                    rateValueLb:setColor(G_ColorYellowPro)
                    cell:addChild(rateLb)
                    cell:addChild(rateValueLb)
                    local scoreLb = GetTTFLabel(getlocal("exerwar_getScoreText"), fontSize)
                    local scoreValueLb = GetTTFLabel(tostring(score), fontSize)
                    scoreLb:setAnchorPoint(ccp(1, 1))
                    scoreValueLb:setAnchorPoint(ccp(1, 1))
                    scoreValueLb:setPosition(rateValueLb:getPositionX(), cellHeight / 2 - 5)
                    scoreLb:setPosition(scoreValueLb:getPositionX() - scoreValueLb:getContentSize().width, scoreValueLb:getPositionY())
                    scoreValueLb:setColor(G_ColorYellowPro)
                    cell:addChild(scoreLb)
                    cell:addChild(scoreValueLb)

                    local function onClickCamera(tag, obj)
                        if G_checkClickEnable() == false then
                            do return end
                        else
                            base.setWaitTime = G_getCurDeviceMillTime()
                        end
                        PlayEffect(audioCfg.mouseClick)
                        if tv and tv:getIsScrolled() == true then
                            do return end
                        end
                        exerWarVoApi:showReportDetail(self.layerNum + 1, self.period, id, nil, getlocal("exerwar_maneuverSelectText"))
                    end
                    local cameraBtn = GetButtonItem("cameraBtn.png", "cameraBtn_down.png", "cameraBtn.png", onClickCamera)
                    local cameraMenu = CCMenu:createWithItem(cameraBtn)
                    cameraMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
                    cameraMenu:setPosition(0, 0)
                    cameraBtn:setPosition(cellWidth / 2, cellHeight / 2)
                    cell:addChild(cameraMenu)
                end
            end
            return cell
        elseif fn == "ccTouchBegan" then
            return true
        elseif fn == "ccTouchMoved" then
        elseif fn == "ccTouchEnded" then
        end
    end
    --[[
    local tv
    local function tvCallBack(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            return 2 + (listSize == 0 and 1 or listSize) + (bestlistSize == 0 and 1 or bestlistSize)
        elseif fn == "tableCellSizeForIndex" then
            local cellHeight = 175
            if (idx == 1 and listSize == 0) or (idx == ((listSize == 0) and 3 or (listSize + 2)) and bestlistSize == 0) then
                cellHeight = 85
            elseif idx == 0 or idx == listSize + 1 or (listSize == 0 and idx == (listSize + 2)) then
                cellHeight = 65
            end
            return CCSizeMake(tvBg:getContentSize().width - 6, cellHeight)
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            local cellWidth = tvBg:getContentSize().width - 6
            local cellHeight = 175
            if (idx == 1 and listSize == 0) or (idx == ((listSize == 0) and 3 or (listSize + 2)) and bestlistSize == 0) then
                cellHeight = 85
                local str, color = getlocal("exerwar_notDataText2"), G_ColorGray
                if idx == 1 and listSize == 0 then
                    str = getlocal("exerwar_notDataText1")
                elseif isSelfBest == true and bestlistSize == 0 then
                    str, color = getlocal("exerwar_bestOfSelfText"), G_ColorWhite
                end
                local notLb = GetTTFLabelWrap(str, 24, CCSizeMake(cellWidth - 10, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
                notLb:setAnchorPoint(ccp(0.5, 0.5))
                notLb:setPosition(cellWidth / 2, cellHeight / 2)
                notLb:setColor(color)
                cell:addChild(notLb)
            elseif idx == 0 or idx == listSize + 1 or (listSize == 0 and idx == (listSize + 2)) then
                cellHeight = 65
                local tipsStr = getlocal("exerwar_bestText")
                if idx == 0 then
                    tipsStr = getlocal("exerwar_maneuverEndText")
                end
                local titleW = cellWidth - 50
                if G_getCurChoseLanguage() == "en" then
                    titleW = cellWidth - 180
                end
                local titleBg, titleLb, titleLbHeight = G_createNewTitle({tipsStr, 24, G_ColorYellowPro}, CCSizeMake(titleW, 0), nil, true, "Helvetica-bold")
                titleBg:setPosition(cellWidth / 2, (cellHeight - titleLbHeight) / 2)
                cell:addChild(titleBg)
            else
                local data
                if idx <= listSize then
                    data = list[idx]
                else
                    data = bestlist[idx - listSize - ((listSize == 0) and 2 or 1)]
                end
                if data then
                    local id = data[1]
                    local aName = data[3]
                    local rate = data[5]
                    local dName = data[7]
                    local isVictory = data[9]
                    local score = data[10]
                    local attBg, defBg
                    local attStatusLb, defStatusLb
                    local attStatusSp, defStatusSp
                    local fontSize = 22
                    if isVictory == 1 then
                        attBg = CCSprite:createWithSpriteFrameName("ltzdzCampBg1.png")
                        attBg:setRotation(180)
                        defBg = CCSprite:createWithSpriteFrameName("ltzdzCampBg2.png")
                        attStatusLb = GetTTFLabel(getlocal("fight_content_result_win"), fontSize)
                        defStatusLb = GetTTFLabel(getlocal("fight_content_result_defeat"), fontSize)
                        attStatusLb:setColor(G_ColorGreen)
                        defStatusLb:setColor(G_ColorRed)
                        attStatusSp = CCSprite:createWithSpriteFrameName("winnerMedal.png")
                        defStatusSp = CCSprite:createWithSpriteFrameName("loserMedal.png")
                    else
                        attBg = CCSprite:createWithSpriteFrameName("ltzdzCampBg2.png")
                        attBg:setFlipX(true)
                        defBg = CCSprite:createWithSpriteFrameName("ltzdzCampBg1.png")
                        defBg:setFlipY(true)
                        attStatusLb = GetTTFLabel(getlocal("fight_content_result_defeat"), fontSize)
                        defStatusLb = GetTTFLabel(getlocal("fight_content_result_win"), fontSize)
                        attStatusLb:setColor(G_ColorRed)
                        defStatusLb:setColor(G_ColorGreen)
                        attStatusSp = CCSprite:createWithSpriteFrameName("loserMedal.png")
                        defStatusSp = CCSprite:createWithSpriteFrameName("winnerMedal.png")
                    end
                    local bgWidth, bgHeight = cellWidth / 2 - 35, cellHeight - 60
                    local bgPosY = cellHeight / 2
                    attBg:setScaleX(bgWidth / attBg:getContentSize().width)
                    attBg:setScaleY(bgHeight / attBg:getContentSize().height)
                    defBg:setScaleX(bgWidth / defBg:getContentSize().width)
                    defBg:setScaleY(bgHeight / defBg:getContentSize().height)
                    attBg:setPosition(cellWidth / 2 - bgWidth / 2 - 20, bgPosY)
                    defBg:setPosition(cellWidth / 2 + bgWidth / 2 + 20, bgPosY)
                    cell:addChild(attBg)
                    cell:addChild(defBg)
                    attStatusLb:setAnchorPoint(ccp(0.5, 1))
                    attStatusLb:setPosition(attBg:getPositionX(), attBg:getPositionY() + bgHeight / 2 - 5)
                    cell:addChild(attStatusLb)
                    defStatusLb:setAnchorPoint(ccp(0.5, 1))
                    defStatusLb:setPosition(defBg:getPositionX(), defBg:getPositionY() + bgHeight / 2 - 5)
                    cell:addChild(defStatusLb)
                    attStatusSp:setAnchorPoint(ccp(0.5, 0))
                    attStatusSp:setPosition(attBg:getPositionX(), attBg:getPositionY() - bgHeight / 2)
                    cell:addChild(attStatusSp)
                    defStatusSp:setAnchorPoint(ccp(0.5, 0))
                    defStatusSp:setPosition(defBg:getPositionX(), defBg:getPositionY() - bgHeight / 2)
                    cell:addChild(defStatusSp)

                    local vsSp = CCSprite:createWithSpriteFrameName("VS.png")
                    vsSp:setAnchorPoint(ccp(0.5, 0))
                    vsSp:setScale(0.3)
                    vsSp:setPosition(cellWidth / 2, attBg:getPositionY() + bgHeight / 2)
                    cell:addChild(vsSp)

                    local attNameLb = GetTTFLabel(aName, fontSize)
                    attNameLb:setAnchorPoint(ccp(0.5, 0))
                    attNameLb:setPosition(attBg:getPositionX(), attBg:getPositionY() + bgHeight / 2)
                    cell:addChild(attNameLb)
                    local defNameLb = GetTTFLabel(dName, fontSize)
                    defNameLb:setAnchorPoint(ccp(0.5, 0))
                    defNameLb:setPosition(defBg:getPositionX(), defBg:getPositionY() + bgHeight / 2)
                    cell:addChild(defNameLb)
                    local lbStr = getlocal("believer_kill_rate", {G_GetPreciseDecimal(rate * 100, 1)})
                    lbStr = lbStr .. "            "
                    lbStr = lbStr .. getlocal("believer_get_score", {score})
                    local rateAndScoreLb, rateAndScoreLbHeight = G_getRichTextLabel(lbStr, {nil, G_ColorGreen, nil, G_ColorGreen, nil}, fontSize, cellWidth - 70, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                    rateAndScoreLb:setAnchorPoint(ccp(0, 1))
                    rateAndScoreLb:setPosition(attBg:getPositionX() - bgWidth / 2, attBg:getPositionY() - bgHeight / 2)
                    cell:addChild(rateAndScoreLb)
                    -- local rateLb, rateLbHeight = G_getRichTextLabel(getlocal("believer_kill_rate", {G_GetPreciseDecimal(rate * 100, 1)}), {nil, G_ColorGreen, nil}, fontSize, bgWidth, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
                    -- rateLb:setAnchorPoint(ccp(0.5, 1))
                    -- rateLb:setPosition(attBg:getPositionX(), attBg:getPositionY() - bgHeight / 2)
                    -- cell:addChild(rateLb)
                    -- local scoreLb, scoreLbHeight = G_getRichTextLabel(getlocal("believer_get_score", {score}), {nil, G_ColorGreen, nil}, fontSize, bgWidth, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
                    -- scoreLb:setAnchorPoint(ccp(0.5, 1))
                    -- scoreLb:setPosition(defBg:getPositionX(), defBg:getPositionY() - bgHeight / 2)
                    -- cell:addChild(scoreLb)

                    local function onClickCamera(tag, obj)
                        if G_checkClickEnable() == false then
                            do return end
                        else
                            base.setWaitTime = G_getCurDeviceMillTime()
                        end
                        PlayEffect(audioCfg.mouseClick)
                        if tv and tv:getIsScrolled() == true then
                            do return end
                        end
                        exerWarVoApi:showReportDetail(self.layerNum + 1, self.period, id, nil, getlocal("exerwar_maneuverSelectText"))
                    end
                    local cameraBtn = GetButtonItem("cameraBtn.png", "cameraBtn_down.png", "cameraBtn.png", onClickCamera)
                    local cameraMenu = CCMenu:createWithItem(cameraBtn)
                    cameraMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 2)
                    cameraMenu:setPosition(0, 0)
                    cameraBtn:setPosition(cellWidth / 2, bgPosY)
                    cell:addChild(cameraMenu)
                end
            end
            return cell
        elseif fn == "ccTouchBegan" then
            return true
        elseif fn == "ccTouchMoved" then
        elseif fn == "ccTouchEnded" then
        end
    end
    --]]
    local hd = LuaEventHandler:createHandler(function(...) return tvCallBack(...) end)
    tv = LuaCCTableView:createWithEventHandler(hd, tvSize, nil)
    tv:setTableViewTouchPriority( - (self.layerNum - 1) * 20 - 3)
    tv:setPosition(ccp(3, 3))
    tvBg:addChild(tv)
end

function exerManeuverPVPDialog:tick()
	local showTag
    local status, et, round = exerWarVoApi:getWarStatus()
    if status >= 20 then --本轮已结束
        showTag = 102
    elseif round then
        if round > self.period then --本轮已结束
            showTag = 102
        elseif round < self.period then --本轮未开启
        else
            if status == 11 then --设置部队阶段
                showTag = 100
            elseif status == 12 then --战斗中
                showTag = 101
            elseif status == 13 then --战斗结束查看战报中
                showTag = 102
            end
        end
    end
    if showTag then
        if self.curShowUITag ~= showTag then
            self:showUI(showTag)
        end
    end
end

function exerManeuverPVPDialog:dispose()
	self = nil
    spriteController:removePlist("public/youhuaUI4.plist")
    spriteController:removeTexture("public/youhuaUI4.png")
    spriteController:removePlist("serverWar/serverWar.plist")
    spriteController:removeTexture("serverWar/serverWar.pvr.ccz")
end