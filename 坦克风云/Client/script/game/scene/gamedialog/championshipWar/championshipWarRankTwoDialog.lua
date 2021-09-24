championshipWarRankTwoDialog = {}

function championshipWarRankTwoDialog:new(listData, layerNum)
    local nc = {
        listData = listData,
        layerNum = layerNum,
        cellHeight = 70
    }
    setmetatable(nc, self)
    self.__index = self
    local function addPlist()
        spriteController:addPlist("public/youhuaUI4.plist")
        spriteController:addTexture("public/youhuaUI4.png")
    end
    G_addResource8888(addPlist)
    return nc
end

function championshipWarRankTwoDialog:init()
    self.bgLayer = CCLayer:create()
    self:initUI()
    return self.bgLayer
end

function championshipWarRankTwoDialog:initUI()
    local fontSize = 24
    local function onTouchInfo()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tabStr = {}
        local textFormatTb = {}
        local warCfg = championshipWarVoApi:getWarCfg()
        for k, v in pairs(warCfg.stageNumBuff) do
            table.insert(tabStr, getlocal("championshipWar_rank_rule1", {v.stageNum, v.first}))
            table.insert(textFormatTb, {richFlag = true, richColor = {nil, G_ColorYellowPro, nil, G_ColorYellowPro, nil}})
        end
        local titleStr = getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, titleStr, tabStr, nil, 25, textFormatTb)
    end
    local infoBtn = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", onTouchInfo)
    local infoMenu = CCMenu:createWithItem(infoBtn)
    infoMenu:setPosition(ccp(G_VisibleSizeWidth - 25 - infoBtn:getContentSize().width / 2, G_VisibleSizeHeight - 175 - infoBtn:getContentSize().height / 2))
    infoMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(infoMenu)
    local maxStageNum, maxFirst = championshipWarVoApi:getAllianceStageNum(), championshipWarVoApi:getFirst()
    local str = getlocal("championshipWar_checkpointRank_desc", {maxStageNum, maxFirst})
    local color = {nil, G_ColorYellowPro, nil, G_ColorYellowPro}
    local lbW = G_VisibleSizeWidth - infoBtn:getContentSize().width - 60
    local descLb, lbHeight = G_getRichTextLabel(str, color, fontSize, lbW, kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
    descLb:setAnchorPoint(ccp(0, 0.5))
    descLb:setPosition(25, infoMenu:getPositionY() + lbHeight / 2)

    if G_getCurChoseLanguage() == "ar" then
        descLb:setPositionY(descLb:getPositionY() - 30)
    end

    self.bgLayer:addChild(descLb)
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png", CCRect(19, 19, 2, 2), function()end)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30, G_VisibleSizeHeight - 320))
    tvBg:setAnchorPoint(ccp(0.5, 1))
    tvBg:setPosition(G_VisibleSizeWidth / 2, infoMenu:getPositionY() - infoBtn:getContentSize().height / 2 - 20)
    self.bgLayer:addChild(tvBg)
    local lb1 = GetTTFLabel(getlocal("rank"), fontSize)
    local lb2 = GetTTFLabel(getlocal("RankScene_name"), fontSize)
    local lb3 = GetTTFLabel(getlocal("championshipWar_checkpointRank_starNum"), fontSize)
    lb1:setPosition(tvBg:getContentSize().width * 0.1, tvBg:getContentSize().height - 30)
    lb2:setPosition(tvBg:getContentSize().width * 0.4, tvBg:getContentSize().height - 30)
    lb3:setPosition(tvBg:getContentSize().width * 0.8, tvBg:getContentSize().height - 30)
    lb1:setColor(G_ColorGreen)
    lb2:setColor(G_ColorGreen)
    lb3:setColor(G_ColorGreen)
    tvBg:addChild(lb1)
    tvBg:addChild(lb2)
    tvBg:addChild(lb3)
    
    self.cellNum = self.listData and SizeOfTable(self.listData) or 0
    local function tvCallBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(tvCallBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(tvBg:getContentSize().width, tvBg:getContentSize().height - 60 - 3), nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setMaxDisToBottomOrTop(100)
    self.tv:setPosition(0, 3)
    tvBg:addChild(self.tv)
    
    local timeLb = GetTTFLabelWrap(getlocal("championshipWar_checkpointRank_refreshRate"), fontSize, CCSizeMake(G_VisibleSizeWidth - 50, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    timeLb:setAnchorPoint(ccp(0.5, 1))
    timeLb:setPosition(G_VisibleSizeWidth / 2, tvBg:getPositionY() - tvBg:getContentSize().height - 10)
    self.bgLayer:addChild(timeLb)
    
    if self.cellNum == 0 then
        local noDataLb = GetTTFLabelWrap(getlocal("serverWarLocal_noData"), fontSize, CCSizeMake(tvBg:getContentSize().width - 10, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        noDataLb:setPosition(tvBg:getContentSize().width / 2, tvBg:getContentSize().height / 2)
        noDataLb:setColor(G_ColorYellowPro)
        tvBg:addChild(noDataLb)
    end
end

function championshipWarRankTwoDialog:eventHandler(handler, fn, index, cel)
    if fn == "numberOfCellsInTableView" then
        return self.cellNum
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(G_VisibleSizeWidth - 30, self.cellHeight)
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        local cellW, cellH = G_VisibleSizeWidth - 30, self.cellHeight
        
        local bgSp
        if index == 0 then
            bgSp = LuaCCScale9Sprite:createWithSpriteFrameName("rank1ItemBg.png", CCRect(20, 20, 10, 10), function()end)
        elseif index == 1 then
            bgSp = LuaCCScale9Sprite:createWithSpriteFrameName("rank2ItemBg.png", CCRect(20, 20, 10, 10), function()end)
        elseif index == 2 then
            bgSp = LuaCCScale9Sprite:createWithSpriteFrameName("rank3ItemBg.png", CCRect(20, 20, 10, 10), function()end)
        else
            bgSp = LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png", CCRect(40, 40, 10, 10), function()end)
        end
        bgSp:setContentSize(CCSizeMake(cellW - 10, cellH - 5))
        bgSp:setAnchorPoint(ccp(0.5, 1))
        bgSp:setPosition(cellW / 2, cellH)
        cell:addChild(bgSp)
        local data = self.listData[index + 1]
        local name = data[2] or ""
        local checkpointNum = data[3] or 0
        local starNum = data[4] or 0
        local rankLb = GetTTFLabel(tostring(index + 1), 24)
        local nameLb = GetTTFLabel(name, 24)
        local starLb = GetTTFLabel(getlocal("championshipWar_scoreDesc", {checkpointNum, starNum}), 24)
        rankLb:setPosition(bgSp:getContentSize().width * 0.1, bgSp:getContentSize().height / 2)
        nameLb:setPosition(bgSp:getContentSize().width * 0.4, bgSp:getContentSize().height / 2)
        starLb:setPosition(bgSp:getContentSize().width * 0.8, bgSp:getContentSize().height / 2)
        bgSp:addChild(rankLb)
        bgSp:addChild(nameLb)
        bgSp:addChild(starLb)
        local starSp = CCSprite:createWithSpriteFrameName("avt_star.png")
        starSp:setScale((starLb:getContentSize().height + 10) / starSp:getContentSize().height)
        starSp:setPosition(starLb:getPositionX() + starLb:getContentSize().width / 2 + starSp:getContentSize().width * starSp:getScale() / 2, starLb:getPositionY())
        bgSp:addChild(starSp)
        
        return cell
    elseif fn == "ccTouchBegan" then
        return true
    elseif fn == "ccTouchMoved" then
    elseif fn == "ccTouchEnded" then
    end
end

function championshipWarRankTwoDialog:dispose()
    self = nil
    spriteController:removePlist("public/youhuaUI4.plist")
    spriteController:removeTexture("public/youhuaUI4.png")
end
