--演习页面
exerManeuverDialog = {}

function exerManeuverDialog:new(layerNum)
    local nc = {
        layerNum = layerNum,
        period = 1, --当前显示的是大战那一阶段
        showDia = nil, --当前显示的页面
    }
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function exerManeuverDialog:getTitleStr(period)
    if period <= 5 then
        return getlocal("exerwar_pvpRound", {period})
    elseif period == 6 then
        return getlocal("exerwar_serverPvp")
    else
        return getlocal("exerwar_finals_serverPvp")
    end
end

function exerManeuverDialog:getSubTitleStr(period)
    local str, color = "", nil
    local status, et, round = exerWarVoApi:getWarStatus()
    if period <= 5 then --服内pvp
        if status >= 20 then
            str = getlocal("exerwar_roundOver")
        elseif round then
            if round > period then --本轮已结束
                str = getlocal("exerwar_roundOver")
                -- color = G_ColorRed
            elseif round < period then
                str = getlocal("exerwar_roundUnopen")
                -- color = G_ColorGray
            else
                if status == 11 then --设置部队阶段
                    local leftTime = et - base.serverTime
                    if leftTime >= 0 then
                        str = getlocal("fleetCard") .. ":"..GetTimeStr(leftTime)
                    end
                elseif status == 12 then --战斗中
                    local leftTime = et - base.serverTime
                    if leftTime >= 0 then
                        str = getlocal("exerwar_fighting") .. ":"..GetTimeStr(leftTime)
                    end
                elseif status == 13 then --战斗结束查看战报中
                    str = getlocal("exerwar_roundOver")
                    -- color = G_ColorRed
                end
            end
        end
    elseif period == 6 then --跨服pvp初赛
        if status < 20 then --为开启
            str = getlocal("exerwar_roundUnopen")
            -- color = G_ColorGray
        elseif status >= 30 then --本轮已结束
            str = getlocal("exerwar_roundOver")
            -- color = G_ColorRed
        else
            if status == 21 then --设置部队报名中
                local leftTime = et - base.serverTime
                if leftTime >= 0 then
                    str = getlocal("fleetCard") .. ":"..GetTimeStr(leftTime)
                end
            elseif status == 22 then --生成参赛名单
                local leftTime = et - base.serverTime
                if leftTime >= 0 then
                    str = getlocal("exerwar_createbBattleList") .. ":"..GetTimeStr(leftTime)
                end
            elseif status == 23 then --战斗中
                local leftTime = et - base.serverTime
                if leftTime >= 0 then
                    str = getlocal("exerwar_fighting") .. ":"..GetTimeStr(leftTime)
                end
            else --战斗结束查看战报中
                str = getlocal("exerwar_roundOver")
                -- color = G_ColorRed
            end
        end
    elseif period == 7 then --跨服pvp决赛
        local ts, value = exerWarVoApi:getFinalTimeStatus()
        if ts and value then
            if ts == 0 and value == 0 then --已结束
                str = getlocal("exerwar_roundOver")
                -- color = G_ColorRed
            else
                if value == 1 then --决赛
                    str = getlocal("championshipWar_championTime") .. ":" .. GetTimeStr(ts)
                else --x强
                    str = getlocal("championshipWar_rankTime", {value}) .. ":" .. GetTimeStr(ts)
                end
            end
        else --未开启
            str = getlocal("exerwar_roundUnopen")
            -- color = G_ColorGray
        end
    end
    return str, color
end

function exerManeuverDialog:initTitle(period, effectDir)
    local function createTitle(tempPeriod, callback)
        if tempPeriod < 1 or tempPeriod > 7 then
            return
        end
        local titleBg
        if tempPeriod > exerWarVoApi:getWarPeroid() then
            titleBg = GraySprite:createWithSpriteFrameName("exer_titleRedBg.png")
            local titleClickSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()
                local ts = G_formatActiveDate(exerWarVoApi:getOpenSurplusTime(tempPeriod))
                G_showTipsDialog(getlocal("exerwar_openSurplusTimeText", {self:getTitleStr(tempPeriod), ts}))
            end)
            titleClickSp:setContentSize(titleBg:getContentSize())
            titleClickSp:setOpacity(0)
            titleClickSp:setPosition(titleBg:getContentSize().width / 2, titleBg:getContentSize().height / 2)
            titleClickSp:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
            titleBg:addChild(titleClickSp)
        else
            titleBg = LuaCCSprite:createWithSpriteFrameName("exer_titleRedBg.png", callback)
            if tempPeriod ~= period then
                titleBg:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
            end
        end
        if tempPeriod == period then
            local titleLb = GetTTFLabel(self:getTitleStr(tempPeriod), 20, true)
            titleLb:setAnchorPoint(ccp(0.5, 1))
            titleLb:setPosition(titleBg:getContentSize().width / 2, titleBg:getContentSize().height - 5)
            titleLb:setColor(G_ColorYellowPro)
            titleLb:setTag(1)
            titleBg:addChild(titleLb)
            local str, color = self:getSubTitleStr(tempPeriod)
            local subTitleLb = GetTTFLabel(str, 18)
            subTitleLb:setAnchorPoint(ccp(0.5, 1))
            subTitleLb:setPosition(titleLb:getPositionX(), titleLb:getPositionY() - titleLb:getContentSize().height - 2)
            if color then
                subTitleLb:setColor(color)
            end
            subTitleLb:setTag(2)
            titleBg:addChild(subTitleLb)
        else
            local titleLb = GetTTFLabel(self:getTitleStr(tempPeriod), 35, true)
            titleLb:setAnchorPoint(ccp(0.5, 0.5))
            titleLb:setPosition(titleBg:getContentSize().width / 2, titleBg:getContentSize().height / 2)
            titleLb:setTag(1)
            titleBg:addChild(titleLb)
        end
        return titleBg
    end
    local curTitleBg = createTitle(period, function()end)
    local titleBgLine = tolua.cast(self.bgLayer:getChildByTag(-100), "CCSprite")
    if titleBgLine == nil then
        titleBgLine = CCSprite:createWithSpriteFrameName("exer_lightYellowBg.png")
        titleBgLine:setScaleX((G_VisibleSizeWidth * 2) / titleBgLine:getContentSize().width)
        titleBgLine:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 85 - curTitleBg:getContentSize().height / 2)
        titleBgLine:setTag(-100)
        self.bgLayer:addChild(titleBgLine)
    end
    for i = 1, 4 do
        local tempSp = tolua.cast(self.bgLayer:getChildByTag(titleBgLine:getTag() - i), "CCSprite")
        if tempSp then
            tempSp:removeFromParentAndCleanup(true)
            tempSp = nil
        end
    end
    self.curTitleBg = nil
    local bgTag = titleBgLine:getTag() - 1
    curTitleBg:setPosition(G_VisibleSizeWidth / 2, titleBgLine:getPositionY())
    curTitleBg:setTag(bgTag)
    self.bgLayer:addChild(curTitleBg)
    if effectDir == -1 or effectDir == 1 then
        local titleLb = tolua.cast(curTitleBg:getChildByTag(1), "CCLabelTTF")
        if titleLb then
            titleLb:setOpacity(50)
            titleLb:runAction(CCFadeTo:create(0.6, 255))
        end
        local subTitleLb = tolua.cast(curTitleBg:getChildByTag(2), "CCLabelTTF")
        if subTitleLb then
            subTitleLb:setOpacity(50)
            subTitleLb:runAction(CCFadeTo:create(0.6, 255))
        end
    end
    local prevTitleBg, nextTitleBg
    local titleBgScale, titleBgSpaceX = 0.5, 20
    local function switchTitleTab(direction)
        if self.showDia and type(self.showDia.isCanClose) == "function" and self.showDia:isCanClose() == false then
            smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), function()
                self.showDia.closeFlag = nil
                switchTitleTab(direction)
            end, getlocal("dialog_title_prompt"), getlocal("exerwar_troopsChangeTipsText"), nil, self.layerNum + 1, nil, nil, function()end)
            do return end
        end
        if self.titleIsAction == true then
            do return end
        end
        self.titleIsAction = true
        local speed = 0.3
        if prevTitleBg then
            if direction == 1 then
                prevTitleBg:runAction(CCMoveTo:create(speed, ccp(prevTitleBg:getPositionX() - (curTitleBg:getPositionX() - prevTitleBg:getPositionX()), prevTitleBg:getPositionY())))
            else
                local arry = CCArray:create()
                arry:addObject(CCMoveTo:create(speed, ccp(curTitleBg:getPosition())))
                arry:addObject(CCScaleTo:create(speed, 1))
                prevTitleBg:runAction(CCSpawn:create(arry))
            end
            local titleLb = tolua.cast(prevTitleBg:getChildByTag(1), "CCLabelTTF")
            if titleLb then
                local arry = CCArray:create()
                arry:addObject(CCFadeTo:create(speed, 0))
                arry:addObject(CCScaleTo:create(speed, 20 / 35))
                titleLb:runAction(CCSpawn:create(arry))
            end
        end
        if nextTitleBg then
            if direction == -1 then
                nextTitleBg:runAction(CCMoveTo:create(speed, ccp(nextTitleBg:getPositionX() + (nextTitleBg:getPositionX() - curTitleBg:getPositionX()), nextTitleBg:getPositionY())))
            else
                local arry = CCArray:create()
                arry:addObject(CCMoveTo:create(speed, ccp(curTitleBg:getPosition())))
                arry:addObject(CCScaleTo:create(speed, 1))
                nextTitleBg:runAction(CCSpawn:create(arry))
            end
            local titleLb = tolua.cast(nextTitleBg:getChildByTag(1), "CCLabelTTF")
            if titleLb then
                local arry = CCArray:create()
                arry:addObject(CCFadeTo:create(speed, 0))
                arry:addObject(CCScaleTo:create(speed, 20 / 35))
                titleLb:runAction(CCSpawn:create(arry))
            end
        end
        local dirFlag = (-1) * direction
        local movePos = ccp(curTitleBg:getPositionX() + dirFlag * (curTitleBg:getContentSize().width / 2) + dirFlag * titleBgSpaceX + dirFlag * (curTitleBg:getContentSize().width * 0.5 / 2), curTitleBg:getPositionY())
        local arry = CCArray:create()
        arry:addObject(CCMoveTo:create(speed, movePos))
        arry:addObject(CCScaleTo:create(speed, titleBgScale))
        curTitleBg:runAction(CCSequence:createWithTwoActions(CCSpawn:create(arry), CCCallFunc:create(function()
            self.period = self.period + direction
            self:initTitle(self.period, direction)
            self:switchPage()
            self.titleIsAction = nil
        end)))
        local tempTitleBg = createTitle(period + direction * 2, function()end)
        if tempTitleBg then
            bgTag = bgTag - 1
            tempTitleBg:setScale(titleBgScale)
            if direction == -1 and prevTitleBg then
                tempTitleBg:setPositionX(prevTitleBg:getPositionX() - prevTitleBg:getContentSize().width * prevTitleBg:getScale() / 2 - titleBgSpaceX - tempTitleBg:getContentSize().width * tempTitleBg:getScale() / 2)
            elseif direction == 1 and nextTitleBg then
                tempTitleBg:setPositionX(nextTitleBg:getPositionX() + nextTitleBg:getContentSize().width * nextTitleBg:getScale() / 2 + titleBgSpaceX + tempTitleBg:getContentSize().width * tempTitleBg:getScale() / 2)
            end
            tempTitleBg:setPositionY(curTitleBg:getPositionY())
            tempTitleBg:setTag(bgTag)
            self.bgLayer:addChild(tempTitleBg)
            local moveToPosX
            if direction == 1 and nextTitleBg then
                moveToPosX = nextTitleBg:getPositionX()
            elseif direction == -1 and prevTitleBg then
                moveToPosX = prevTitleBg:getPositionX()
            end
            if moveToPosX then
                tempTitleBg:runAction(CCMoveTo:create(speed, ccp(moveToPosX, tempTitleBg:getPositionY())))
            end
        end
    end
    prevTitleBg = createTitle(period - 1, function() switchTitleTab(-1) end)
    if prevTitleBg then
        bgTag = bgTag - 1
        prevTitleBg:setScale(titleBgScale)
        prevTitleBg:setPosition(curTitleBg:getPositionX() - curTitleBg:getContentSize().width / 2 - titleBgSpaceX - prevTitleBg:getContentSize().width * prevTitleBg:getScale() / 2, curTitleBg:getPositionY())
        prevTitleBg:setTag(bgTag)
        self.bgLayer:addChild(prevTitleBg)
        if effectDir == 1 then
            local titleLb = tolua.cast(prevTitleBg:getChildByTag(1), "CCLabelTTF")
            if titleLb then
                titleLb:setOpacity(50)
                titleLb:runAction(CCFadeTo:create(0.6, 255))
            end
        end
    end
    nextTitleBg = createTitle(period + 1, function() switchTitleTab(1) end)
    if nextTitleBg then
        bgTag = bgTag - 1
        nextTitleBg:setScale(titleBgScale)
        nextTitleBg:setPosition(curTitleBg:getPositionX() + curTitleBg:getContentSize().width / 2 + titleBgSpaceX + nextTitleBg:getContentSize().width * nextTitleBg:getScale() / 2, curTitleBg:getPositionY())
        nextTitleBg:setTag(bgTag)
        self.bgLayer:addChild(nextTitleBg)
        if effectDir == -1 then
            local titleLb = tolua.cast(nextTitleBg:getChildByTag(1), "CCLabelTTF")
            if titleLb then
                titleLb:setOpacity(50)
                titleLb:runAction(CCFadeTo:create(0.6, 255))
            end
        end
    end
    self.curTitleBg = curTitleBg
end

function exerManeuverDialog:initTableView()
    self.bgLayer = CCLayer:create()

    self.period, self.warStatus = exerWarVoApi:getWarPeroid()

    self:initTitle(self.period)

    self:switchPage()

    local function onClickInfoBtn(tag, obj)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        exerWarVoApi:showScoreDetailSmallDialog(self.layerNum + 1)
    end
    local infoBtn = GetButtonItem("exer_query.png", "exer_query.png", "exer_query.png", onClickInfoBtn)
    local infoMenu = CCMenu:createWithItem(infoBtn)
    infoMenu:setTouchPriority( - (self.layerNum - 1) * 20 - 4)
    infoMenu:setPosition(ccp(0, 0))
    infoBtn:setAnchorPoint(ccp(1, 0.5))
    local infoBtnScale
    local infoBtnPosY
    if G_getIphoneType() == G_iphone5 then
        infoBtnScale = 0.8
        infoBtnPosY = 125
    elseif G_getIphoneType() == G_iphoneX then
        infoBtnScale = 1
        infoBtnPosY = 135
    else --默认是 G_iphone4
        infoBtnScale = 0.5
        infoBtnPosY = 110
    end
    infoBtn:setScale(infoBtnScale)
    infoBtn:setPosition(G_VisibleSizeWidth - 20, infoBtnPosY)
    self.bgLayer:addChild(infoMenu)
    local rankScoreLb = GetTTFLabel(getlocal("exerwar_rankScoreText", {exerWarVoApi:getRankScore()}), 20)
    rankScoreLb:setAnchorPoint(ccp(0, 0.5))
    rankScoreLb:setPosition(20, infoBtn:getPositionY())
    self.bgLayer:addChild(rankScoreLb)
    local totalScoreLb = GetTTFLabel(getlocal("exerwar_totalScoreText", {exerWarVoApi:getTotalScore()}), 20)
    totalScoreLb:setAnchorPoint(ccp(1, 0.5))
    totalScoreLb:setPosition(infoBtn:getPositionX() - infoBtn:getContentSize().width * infoBtn:getScale() - 15, infoBtn:getPositionY())
    self.bgLayer:addChild(totalScoreLb)
end

function exerManeuverDialog:switchPage()
    if self.showDia then
        if tolua.cast(self.showDia.bgLayer, "CCLayer") then
            self.showDia.bgLayer:removeFromParentAndCleanup(true)
            self.showDia.bgLayer = nil
        end
        if self.showDia.dispose then
            self.showDia:dispose()
        end
        self.showDia = nil
    end
    if self.period <= 5 then --服内pvp的页面（每轮根据本轮处于哪个阶段显示不同的页面）
        require "luascript/script/game/scene/gamedialog/exerwar/exerManeuverPVPDialog"
        self.showDia = exerManeuverPVPDialog:new(self.layerNum, self.period)
    elseif self.period == 6 then --跨服pvp初赛页面
        require "luascript/script/game/scene/gamedialog/exerwar/exerWarFirstPVPDialog"
        self.showDia = exerWarFirstPVPDialog:new(self.layerNum, self.period)
    elseif self.period == 7 then --跨服pvp决赛页面
        require "luascript/script/game/scene/gamedialog/exerwar/exerWarFinalDialog"
        self.showDia = exerWarFinalDialog:new(self.layerNum, self.period)
    end
    if self.showDia then
        if self.showDia.initTableView then
            self.showDia:initTableView()
        end
        if self.showDia.bgLayer then
            self.bgLayer:addChild(self.showDia.bgLayer)
        end
    end
end

function exerManeuverDialog:tick()
    if tolua.cast(self.curTitleBg, "CCSprite") then
        -- local titleLb = tolua.cast(self.curTitleBg:getChildByTag(1), "CCLabelTTF")
        local subTitleLb = tolua.cast(self.curTitleBg:getChildByTag(2), "CCLabelTTF")
        if subTitleLb then
            local str, color = self:getSubTitleStr(self.period)
            subTitleLb:setString(str)
            if color then
                subTitleLb:setColor(color)
            end
            -- if titleLb then
            --     subTitleLb:setPosition(titleLb:getPositionX(), titleLb:getPositionY() - titleLb:getContentSize().height - 2)
            -- end
        end
    end
    
    if self.showDia then
        if self.showDia.tick then
            self.showDia:tick()
        end
    end
end

function exerManeuverDialog:dispose()
    if self.showDia then
        if self.showDia.dispose then
            self.showDia:dispose()
        end
        self.showDia = nil
    end
    if self.bgLayer and tolua.cast(self.bgLayer, "CCLayer") then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer = nil
    end
    self = nil
end
