worldAirShipTabTwo = {}

function worldAirShipTabTwo:new(parentLayer)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.parentLayer = parentLayer
    if parentLayer then
        self.layerNum = parentLayer.layerNum
    end
    return nc
end

function worldAirShipTabTwo:init()
    self.bgLayer = CCLayer:create()
    local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                self.todayBossType = sData.data.shipboss
                if sData.data.shiprank then
                    self:refreshRank(sData.data.shiprank)
                end
            end
        end
    end
    socketHelper:airShipSocket(socketCallback, "getrank")
    self:initUI()
    return self.bgLayer
end

function worldAirShipTabTwo:initUI()
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 20, G_VisibleSizeHeight - 350))
    tvBg:setAnchorPoint(ccp(0.5, 1))
    tvBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 160)
    self.bgLayer:addChild(tvBg)
    
    local function onLoadWebImage(fn, webImage)
        if self and tolua.cast(tvBg, "CCSprite") then
            webImage:setAnchorPoint(ccp(0.5, 1))
            webImage:setPosition(ccp(tvBg:getContentSize().width / 2, tvBg:getContentSize().height - 4))
            tvBg:addChild(webImage)
        end
    end
    G_addResource8888(function()
        LuaCCWebImage:createWithURL(G_downloadUrl("airShip/airShip_damageRankBg.jpg"), onLoadWebImage)
    end)
    
    local function showInfo()
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local asCfg = airShipVoApi:getAirShipCfg()
        local textFormatTb = {}
        local tabStr = {}
        for i = 1, 4 do
            local strParam
            if i == 2 then
                strParam = {FormatNumber(airShipVoApi:getRankMinDamage())}
            elseif i == 3 then
                strParam = {asCfg.bTime / 3600}
            end
            table.insert(tabStr, getlocal("airShip_worldBossTabTwo_i_desc" .. i, strParam))
            textFormatTb[i] = {
                alignment = kCCTextAlignmentLeft,
                richFlag = true,
                richColor = {nil, G_ColorYellowPro, nil},
                ws = 10
            }
        end
        if self.todayBossType then
            for k, v in pairs(asCfg.Rank) do
                local rewardStr = ""
                local rewardTb = airShipVoApi:getLastDayBossTypeAward(k, self.todayBossType)
                if rewardTb then
                    local rewardTbSize = #rewardTb
                    for kk, vv in pairs(rewardTb) do
                        rewardStr = rewardStr .. vv.name .. "x" .. vv.num
                        if kk ~= rewardTbSize then
                            rewardStr = rewardStr .. "，"
                        end
                    end
                end
                local str
                if v.rank[1] == v.rank[2] then
                    str = getlocal("rank_reward_str", {v.rank[1], rewardStr})
                elseif v.rank[1] < v.rank[2] then
                    str = getlocal("rank_reward_str", {v.rank[1] .. "~" .. v.rank[2], rewardStr})
                else
                    str = getlocal("airShip_rankLaterText", {v.rank[1]}) .. rewardStr
                end
                table.insert(tabStr, str)
            end
        end
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, getlocal("activity_baseLeveling_ruleTitle"), tabStr, nil, 25, textFormatTb)
    end
    local infoBtn = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", showInfo)
    infoBtn:setAnchorPoint(ccp(1, 1))
    infoBtn:setScale(0.7)
    local infoMenu = CCMenu:createWithItem(infoBtn)
    infoMenu:setPosition(ccp(tvBg:getContentSize().width - 15, tvBg:getContentSize().height - 20))
    infoMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    tvBg:addChild(infoMenu, 1)
    
    local topTipsLb = GetTTFLabelWrap(getlocal("airShip_todayRankTopTipsText"), 22, CCSizeMake(tvBg:getContentSize().width - infoBtn:getContentSize().width * infoBtn:getScale() - 45, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    topTipsLb:setAnchorPoint(ccp(0, 0.5))
    topTipsLb:setPosition(ccp(15, infoMenu:getPositionY() - infoBtn:getContentSize().height * infoBtn:getScale() / 2))
    tvBg:addChild(topTipsLb, 1)
    
    local rewardLastIdx = 0 --最低排行榜奖励的名次临界值
    local rcfg = airShipVoApi:getAirShipCfg().Rank
    rewardLastIdx = rcfg[#rcfg].rank[1] - 1
    
    local tvSize = CCSizeMake(tvBg:getContentSize().width - 6, infoMenu:getPositionY() - infoBtn:getContentSize().height * infoBtn:getScale() - 23)
    local tv = G_createTableView(tvSize, function() return SizeOfTable(self.todayRank) end, CCSizeMake(tvSize.width, 50), function(cell, cellSize, idx, cellNum)
        local data = self.todayRank[idx + 1]
        if data == nil then
            do return end
        end
        local uid = data[1]
        local name = data[2]
        local pic = data[3]
        local fhid = data[4]
        local damage = data[5]
        local timer = data[6]
        local iconWidth = cellSize.height - 10
        local picName = playerVoApi:getPersonPhotoName(pic)
        local playerIcon = playerVoApi:GetPlayerBgIcon(picName, nil, nil, nil, iconWidth, fhid)
        playerIcon:setAnchorPoint(ccp(0, 0.5))
        playerIcon:setPosition(ccp(15, cellSize.height / 2))
        cell:addChild(playerIcon)
        local infoBg = CCSprite:createWithSpriteFrameName((idx == 0) and "rankList_cellBg_1.png" or "rankList_cellBg_2.png")
        infoBg:setAnchorPoint(ccp(0, 0.5))
        infoBg:setPosition(ccp(playerIcon:getPositionX() + iconWidth + 10, cellSize.height / 2))
        cell:addChild(infoBg)
        local infoTb = {
            {getlocal("rankOne", {(idx >= 10) and rewardLastIdx or (idx + 1)}), 0.1},
            {name, 0.38},
            {getlocal("airShip_totalDamageText") .. FormatNumber(damage or 0), 0.78},
        }
        for k, v in pairs(infoTb) do
            local label = GetTTFLabel(v[1], G_isAsia() and 22 or 16)
            label:setPosition(infoBg:getContentSize().width * v[2], infoBg:getContentSize().height / 2)
            infoBg:addChild(label)
        end
    end)
    tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    tv:setPosition(3, 3)
    tvBg:addChild(tv, 2)
    self.tv = tv
    
    local bottomBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png", CCRect(19, 19, 2, 2), function()end)
    bottomBg:setContentSize(CCSizeMake(tvBg:getContentSize().width, 110))
    bottomBg:setAnchorPoint(ccp(0.5, 1))
    bottomBg:setPosition(ccp(G_VisibleSizeWidth / 2, tvBg:getPositionY() - tvBg:getContentSize().height - 10))
    self.bgLayer:addChild(bottomBg)
    
    local function onClickRefresh(tag, obj)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local function socketCallback(fn, data)
            local ret, sData = base:checkServerData(data)
            if ret == true then
                if sData and sData.data and sData.data.shiprank then
                    self:refreshRank(sData.data.shiprank)
                end
            end
        end
        socketHelper:airShipSocket(socketCallback, "getrank")
    end
    local refreshBtnScale = 0.7
    local refreshBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onClickRefresh, nil, getlocal("dailyTaskFlush"), 24 / refreshBtnScale)
    refreshBtn:setScale(refreshBtnScale)
    refreshBtn:setAnchorPoint(ccp(1, 0.5))
    refreshBtn:setPosition(ccp(bottomBg:getContentSize().width - 15, bottomBg:getContentSize().height / 2))
    local btnMenu = CCMenu:createWithItem(refreshBtn)
    btnMenu:setPosition(ccp(0, 0))
    btnMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    bottomBg:addChild(btnMenu)
    local myRankLb = GetTTFLabel(getlocal("plat_war_my_rank", {getlocal("dimensionalWar_out_of_rank")}), 22)
    local damageLb = GetTTFLabel(getlocal("airShip_totalDamageText") .. "0", 22)
    myRankLb:setAnchorPoint(ccp(0, 0))
    damageLb:setAnchorPoint(ccp(0, 1))
    myRankLb:setPosition(ccp(15, refreshBtn:getPositionY() + 1))
    damageLb:setPosition(ccp(myRankLb:getPositionX(), refreshBtn:getPositionY() - 1))
    bottomBg:addChild(myRankLb)
    bottomBg:addChild(damageLb)
    if self.myRankData then
        if self.myRankData[1] then
            local rankStr = ""
            if tonumber(self.myRankData[1]) <= 0 then
                rankStr = getlocal("dimensionalWar_out_of_rank")
            elseif tonumber(self.myRankData[1]) > 100 then
                rankStr = "100+"
            else
                rankStr = tostring(self.myRankData[1])
            end
            myRankLb:setString(getlocal("plat_war_my_rank", {rankStr}))
        end
        if self.myRankData[2] then
            damageLb:setString(getlocal("airShip_totalDamageText") .. FormatNumber(tonumber(self.myRankData[2]) or 0))
        end
    end
    self.myRankLb = myRankLb
    self.damageLb = damageLb
    
    local bottomTipsLb = GetTTFLabelWrap(getlocal("airShip_rankDamageTipsText", {FormatNumber(airShipVoApi:getRankMinDamage())}), 20, CCSizeMake(G_VisibleSizeWidth - 40, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    bottomTipsLb:setAnchorPoint(ccp(0.5, 1))
    bottomTipsLb:setPosition(ccp(G_VisibleSizeWidth / 2, bottomBg:getPositionY() - bottomBg:getContentSize().height - 10))
    bottomTipsLb:setColor(G_ColorRed)
    self.bgLayer:addChild(bottomTipsLb)
end

function worldAirShipTabTwo:refreshRank(rankData)
    if self and rankData then
        self.todayRank = rankData[1]
        self.myRankData = rankData[3]
        
        if self.tv then
            self.tv:reloadData()
        end
        
        self:refreshMyRank()
    end
end

function worldAirShipTabTwo:refreshMyRank()
    local atkAirshipBossTs = (self.myRankData == nil or self.myRankData[3] == nil or self.myRankData[3] == 0) and base.serverTime or self.myRankData[3]
    local isToday = G_isToday(atkAirshipBossTs)
    if isToday == false then
        self.myRankData = {0, 0, base.serverTime}
    end
    if self.myRankData then
        local myRankLb = tolua.cast(self.myRankLb, "CCLabelTTF")
        local damageLb = tolua.cast(self.damageLb, "CCLabelTTF")
        if self.myRankData[1] and myRankLb then
            local rankStr = ""
            if tonumber(self.myRankData[1]) <= 0 then
                rankStr = getlocal("dimensionalWar_out_of_rank")
            elseif tonumber(self.myRankData[1]) > 100 then
                rankStr = "100+"
            else
                rankStr = tostring(self.myRankData[1])
            end
            myRankLb:setString(getlocal("plat_war_my_rank", {rankStr}))
        end
        if self.myRankData[2] and damageLb then
            damageLb:setString(getlocal("airShip_totalDamageText") .. FormatNumber(tonumber(self.myRankData[2]) or 0))
        end
    end
end

function worldAirShipTabTwo:tick()
    if self.myRankData then
        local atkAirshipBossTs = (self.myRankData == nil or self.myRankData[3] == nil or self.myRankData[3] == 0) and base.serverTime or self.myRankData[3]
        local isToday = G_isToday(atkAirshipBossTs)
        if isToday == false then
            self.myRankData = {0, 0, base.serverTime}
            self:refreshMyRank()
        end
    end
end

function worldAirShipTabTwo:dispose()
    self = nil
end
