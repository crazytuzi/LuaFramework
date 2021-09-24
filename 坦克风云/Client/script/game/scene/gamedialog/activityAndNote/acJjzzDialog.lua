require "luascript/script/game/scene/gamedialog/activityAndNote/acJjzzSelectDialog"

acJjzzDialog = commonDialog:new()

function acJjzzDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    
    self.bgLayer = nil
    self.layerNum = nil
    return nc
end

function acJjzzDialog:initTableView()
    spriteController:addPlist("public/acjjzz.plist")
    spriteController:addTexture("public/acjjzz.png")
    self.url = G_downloadUrl("active/" .. "ac_jjzz_bkg.jpg") or nil
    local function realSwitchSubTab(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true and sData.data.jjzz then
            acJjzzVoApi:updata(sData.data.jjzz)
            
            self:initTitle()
            self:updateUI()
        end
    end
    socketHelper:jjzz_refresh(realSwitchSubTab)
end

function acJjzzDialog:initTitle()
    local vo = acJjzzVoApi:getAcVo()
    
    local titleW = G_VisibleSizeWidth - 40
    local titleH = G_is5x(150, 130)
    local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png", CCRect(19, 19, 2, 2), function () end)
    backSprie:setAnchorPoint(ccp(0, 1))
    backSprie:setContentSize(CCSizeMake(titleW, titleH))
    backSprie:setPosition(ccp(20, G_VisibleSizeHeight - 90))
    self.bgLayer:addChild(backSprie, 2)
    
    local timeTime = GetTTFLabel(getlocal("activity_timeLabel"), 24)
    timeTime:setAnchorPoint(ccp(0.5, 1))
    timeTime:setColor(G_ColorYellowPro)
    timeTime:setPosition(ccp(titleW * 0.5, titleH - 10))
    backSprie:addChild(timeTime, 3)
    if vo then
        local timeLb = GetTTFLabel(acJjzzVoApi:getTimeStr(), 24)
        timeLb:setAnchorPoint(ccp(0.5, 1))
        timeLb:setPosition(timeTime:getPositionX(), titleH - 35)
        backSprie:addChild(timeLb, 3)
        timeLb:setColor(G_ColorYellow)
        self.timeLb = timeLb
        self:updateAcTime()
    end
    
    local desLabel = G_LabelTableView(CCSizeMake(titleW - 20, 60), getlocal("activity_jjzz_desc"), 22, kCCTextAlignmentLeft)
    desLabel:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 11)
    desLabel:setMaxDisToBottomOrTop(70)
    desLabel:setAnchorPoint(ccp(0, 0))
    desLabel:setPosition(ccp(10, 5))
    backSprie:addChild(desLabel, 5)
    
    local function touch(tag, object)
        local tabStr = {}
        for i = 1, 3 do
            table.insert(tabStr, getlocal("activity_jjzz_info"..i))
        end
        local titleStr = getlocal("activity_baseLeveling_ruleTitle")
        local textSize = G_getCurChoseLanguage() == "ru" and 20 or 25
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, titleStr, tabStr, nil, textSize)
    end
    local menuItemDesc = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", touch, nil, nil, 0)
    menuItemDesc:setScale(0.8)
    menuItemDesc:setAnchorPoint(ccp(0.5, 0.5))
    local menuDesc = CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
    menuDesc:setPosition(ccp(titleW - 50, titleH - 35))
    backSprie:addChild(menuDesc, 1)
    
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight), nil)
    self.tv:setAnchorPoint(ccp(0, 0))
    self.tv:setPosition(0, 0)
    -- self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    -- self.tv:setMaxDisToBottomOrTop(80)
    self.bgLayer:addChild(self.tv, 1)
end

function acJjzzDialog:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return 1
    elseif fn == "tableCellSizeForIndex" then
        local tmpSize = CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight)
        return tmpSize
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
        backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
        backSprie:setAnchorPoint(ccp(0, 0));
        backSprie:setPosition(0, 0)
        backSprie:setOpacity(120)
        cell:addChild(backSprie)
        
        self:initTop(cell)
        self:initMid(cell)
        self:initBtn(cell)
        
        return cell
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
        return true
    elseif fn == "ccTouchMoved" then
        self.isMoved = true
    elseif fn == "ccTouchEnded" then
    end
end

function acJjzzDialog:initTop(cell)
    if self.url then
        local function onLoadIcon(fn, bg)
            if self and self:isClosed() == false and bg then
                bg:setAnchorPoint(ccp(0.5, 1))
                bg:setPosition(ccp(G_VisibleSizeWidth * 0.5, G_VisibleSizeHeight - 100))
                self.bgLayer:addChild(bg)
            end
        end
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        local webImage = LuaCCWebImage:createWithURL(self.url, onLoadIcon)
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    end
    
    local bkgSp = CCNode:create()
    bkgSp:setContentSize(CCSizeMake(591, 400))
    bkgSp:setAnchorPoint(ccp(0.5, 1))
    bkgSp:setPosition(ccp(G_VisibleSizeWidth * 0.5, G_VisibleSizeHeight - 100))
    cell:addChild(bkgSp, 1)
    
    local selBkg = LuaCCScale9Sprite:createWithSpriteFrameName("ac_jjzz_title_bkg.png", CCRect(19, 19, 2, 2), function()end)
    selBkg:setContentSize(CCSizeMake(G_getLS(154, 250), 42))
    selBkg:setAnchorPoint(ccp(0, 1))
    selBkg:setPosition(0, bkgSp:getContentSize().height - 140)
    bkgSp:addChild(selBkg)
    
    local selLb = GetTTFLabel(getlocal("activity_jjzz_lb2"), G_getLS(22, 18))
    selLb:setAnchorPoint(ccp(0, 0.5))
    selLb:setPosition(25, selBkg:getContentSize().height * 0.5)
    selBkg:addChild(selLb)
    
    local vo = acJjzzVoApi:getAcVo()
    local cfg = vo.acCfg
    local heroCfg = cfg.heroList[vo.key[1]][vo.key[2]]
    local heroItem = FormatItem(heroCfg.hname)[1]
    
    local function clkFun()
        local function sureFun(k1, k2)
            if k1 and k2 then
                local function getRawardCallback(fn, data)
                    local ret, sData = base:checkServerData(data)
                    if ret == true then
                        if sData and sData.data and sData.data.jjzz then
                            acJjzzVoApi:updata(sData.data.jjzz)
                        end
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("activity_jjzz_lb6"), 30)
                        self:updateUI()
                    end
                end
                socketHelper:jjzz_change(k1, k2, getRawardCallback)
            end
        end
        local td = acJjzzSelectDialog:new()
        local heroTb = cfg.heroList
        td:init(self.layerNum + 1, sureFun, heroTb)
    end
    local heroIcon = G_getItemIcon(heroItem, 135, false, self.layerNum + 1, clkFun)
    heroIcon:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
    heroIcon:setAnchorPoint(ccp(0.5, 0.5))
    heroIcon:setPosition(bkgSp:getContentSize().width * 0.5, 135)
    bkgSp:addChild(heroIcon)
    
    local clkBkg = LuaCCScale9Sprite:createWithSpriteFrameName("ac_jjzz_lb_bkg.png", CCRect(72, 15, 1, 1), clkFun)
    clkBkg:setContentSize(CCSizeMake(G_getLS(150, 230), 35))
    clkBkg:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
    clkBkg:setAnchorPoint(ccp(0.5, 0.5))
    clkBkg:setPosition(heroIcon:getPositionX(), heroIcon:getPositionY() - 110)
    bkgSp:addChild(clkBkg)
    
    local clkLb = GetTTFLabel(getlocal("activity_jjzz_lb1"), G_getLS(22, 18))
    clkLb:setAnchorPoint(ccp(0.5, 0.5))
    clkLb:setPosition(clkBkg:getContentSize().width * 0.5, clkBkg:getContentSize().height * 0.5)
    clkBkg:addChild(clkLb)
    
    local function rewardRecordsHandler()
        self:recordHandler()
    end
    local recordBtn = GetButtonItem("bless_record.png", "bless_record.png", "bless_record.png", rewardRecordsHandler, 11, nil, nil)
    recordBtn:setScale(0.8)
    local recordMenu = CCMenu:createWithItem(recordBtn)
    recordMenu:setAnchorPoint(ccp(1, 0))
    recordMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
    recordMenu:setPosition(bkgSp:getContentSize().width - 50, 70)
    bkgSp:addChild(recordMenu)
    local recordLb = GetTTFLabelWrap(getlocal("serverwar_point_record"), G_getLS(22, 18), CCSize(100, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    recordLb:setAnchorPoint(ccp(0.5, 1))
    recordLb:setPosition(recordBtn:getContentSize().width * recordBtn:getScale() * 0.5, 8)
    recordLb:setScale(1 / recordBtn:getScale())
    recordBtn:addChild(recordLb)
end

function acJjzzDialog:recordHandler()
    local function callback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData.data.report == nil or #sData.data.report == 0 then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("ac_bjbz_no_history"), 30)
                do return end
            end
            
            local record = {}
            if sData.data.report then
                for k, v in pairs(sData.data.report) do
                    local num = 1
                    if v[2] > 1 then
                        num = acJjzzVoApi:getMultiNum()
                    end
                    local desc = getlocal("activity_jjzz_btn", {num})
                    if v[3] and v[3][1] then
                        local reward = FormatItem(v[3][1])
                        local hexieReward = acJjzzVoApi:getHexieReward()
                        if hexieReward then
                            hexieReward.num = hexieReward.num * num
                            table.insert(reward, 1, hexieReward)
                        end
                        local colorTb = {nil, G_ColorYellowPro, nil}
                        table.insert(record, {award = reward, time = v[1], desc = desc, colorTb = colorTb})
                    end
                end
            end
            local function sortFunc(a, b)
                if a and b and a.time and b.time then
                    return tonumber(a.time) > tonumber(b.time)
                end
            end
            table.sort(record, sortFunc)
            local recordCount = SizeOfTable(record)
            if recordCount == 0 then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("activity_huoxianmingjiang_log_tip0"), 30)
                do return end
            end
            local function confirmHandler()
            end
            require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"
            acMingjiangpeiyangSmallDialog:showRewardsRecordDialog("TankInforPanel.png", CCSizeMake(550, G_VisibleSizeHeight - 300), CCRect(130, 50, 1, 1), getlocal("activity_customLottery_RewardRecode"), record, false, self.layerNum + 1, confirmHandler, true, 10, nil, nil, nil, nil, nil, true)
        end
    end
    socketHelper:jjzz_getReportLog(callback)
end

function acJjzzDialog:initMid(cell)
    local vo = acJjzzVoApi:getAcVo()
    local cfg = vo.acCfg
    local heroCfg = cfg.heroList[vo.key[1]][vo.key[2]]
    local heroItem = FormatItem(heroCfg.hname)[1]
    
    local midBkg1 = LuaCCScale9Sprite:createWithSpriteFrameName("emTroop_panelBg.png", CCRect(54, 54, 2, 2), function()end)
    midBkg1:setContentSize(CCSizeMake(580, G_is5x(220, 140)))
    midBkg1:setAnchorPoint(ccp(0, 1))
    midBkg1:setPosition(30, G_VisibleSizeHeight - 500)
    cell:addChild(midBkg1)
    
    local titleLb1 = GetTTFLabel(getlocal("activity_jjzz_lb3"), G_is5x(G_getLS(25, 18), 18))
    titleLb1:setAnchorPoint(ccp(0.5, 1))
    titleLb1:setPosition(midBkg1:getContentSize().width * 0.5, midBkg1:getContentSize().height - 15)
    midBkg1:addChild(titleLb1)
    
    local itemW1 = G_is5x(100, 60)
    local midW1 = 60
    local len1 = #cfg.chooseCount
    local sx = G_getCenterSx(midBkg1:getContentSize().width, itemW1, len1, midW1)
    for i = 1, len1 do
        local heroIcon = G_getItemIcon(heroItem, itemW1, true, self.layerNum + 1)
        heroIcon:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
        heroIcon:setAnchorPoint(ccp(0.5, 0))
        heroIcon:setPosition(sx + (i - 1) * (itemW1 + midW1), G_is5x(55, 35))
        midBkg1:addChild(heroIcon)
        
        local numLb = GetTTFLabel("x"..cfg.chooseCount[i], G_getLS(25, 22))
        numLb:setAnchorPoint(ccp(0.5, 1))
        numLb:setPosition(heroIcon:getPositionX(), heroIcon:getPositionY() - 5)
        midBkg1:addChild(numLb)
    end
    
    local midBkg2 = LuaCCScale9Sprite:createWithSpriteFrameName("emTroop_panelBg.png", CCRect(54, 54, 2, 2), function()end)
    midBkg2:setContentSize(CCSizeMake(580, G_is5x(150, 110)))
    midBkg2:setAnchorPoint(ccp(0, 1))
    midBkg2:setPosition(midBkg1:getPositionX(), midBkg1:getPositionY() - midBkg1:getContentSize().height - 10)
    cell:addChild(midBkg2)
    
    local titleLb2 = GetTTFLabel(getlocal("activity_jjzz_lb4"), G_is5x(G_getLS(25, 18), 18))
    titleLb2:setAnchorPoint(ccp(0.5, 1))
    titleLb2:setPosition(midBkg2:getContentSize().width * 0.5, midBkg2:getContentSize().height - 5)
    midBkg2:addChild(titleLb2)
    
    local itemW2 = G_is5x(80, 60)
    local midW2 = 10
    local itemTb = FormatItem(cfg.pool, true, true)
    local len2 = #itemTb
    local sx2 = G_getCenterSx(midBkg2:getContentSize().width, itemW2, len2, midW2)
    for i = 1, len2 do
        local heroIcon = G_getItemIcon(itemTb[i], 100, true, self.layerNum + 1, nil, nil, nil, nil, nil, true)
        heroIcon:setScale(itemW2 / heroIcon:getContentSize().width)
        heroIcon:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
        heroIcon:setAnchorPoint(ccp(0.5, 0))
        heroIcon:setPosition(sx2 + (i - 1) * (itemW2 + midW2), 15)
        midBkg2:addChild(heroIcon)
        
        -- local numLb=GetTTFLabel("x"..itemTb[i].num,G_getLS(25,22))
        -- numLb:setAnchorPoint(ccp(0.5,1))
        -- numLb:setPosition(heroIcon:getPositionX(),heroIcon:getPositionY()-5)
        -- midBkg1:addChild(numLb)
    end
end

function acJjzzDialog:initBtn(cell)
    local vo = acJjzzVoApi:getAcVo()
    local cfg = vo.acCfg
    local function btnClick(tag, object)
        if G_checkClickEnable() == false then
            do
                return
            end
        else
            base.setWaitTime = G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        PlayEffect(audioCfg.mouseClick)
        
        local cost1, cost2 = acJjzzVoApi:getCost()
        local cost = tag == 1 and cost1 or cost2
        if cost > playerVoApi:getGems() then
            GemsNotEnoughDialog(nil, nil, cost - playerVoApi:getGems(), self.layerNum + 1, cost, nil)
            return
        end
        
        local function realLottery()
            local function getRawardCallback(fn, data)
                local ret, sData = base:checkServerData(data)
                if ret == true then
                    if sData and sData.data and sData.data.jjzz then
                        acJjzzVoApi:updata(sData.data.jjzz)
                    end
                    
                    local playerGem = playerVoApi:getGems()
                    playerVoApi:setGems(playerGem - cost)
                    
                    if sData.data.jjzz.r then
                        local rewardList = FormatItem(sData.data.jjzz.r)
                        local hexieReward = acJjzzVoApi:getHexieReward()
                        if hexieReward then
                            if tag ~= 1 then
                                hexieReward.num = hexieReward.num * cfg.count
                            end
                            table.insert(rewardList, 1, hexieReward)
                        end
                        G_takeReward(rewardList, sData.data)
                        G_showRewardTip(rewardList, true)
                    end
                    
                    self:updateUI()
                end
            end
            
            socketHelper:jjzz_lottery(tag == 1 and 1 or cfg.count, getRawardCallback)
        end
        G_dailyConfirm("acjjzz.lottery", getlocal("second_tip_des", {cost}), realLottery, self.layerNum + 1)
    end
    
    local btnY = G_is5x(80, 60)
    local btnScale = G_is5x(1, 0.7)
    local btnItem1 = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", btnClick, 1, getlocal("activity_jjzz_btn", {1}), 25)
    btnItem1:setAnchorPoint(ccp(0.5, 0))
    btnItem1:setScale(btnScale)
    self.btnItem1 = btnItem1
    local btn1 = CCMenu:createWithItem(btnItem1);
    btn1:setTouchPriority(-(self.layerNum - 1) * 20 - 4);
    btn1:setPosition(ccp(G_VisibleSizeWidth / 2 - 150, btnY))
    cell:addChild(btn1)
    
    local cost1, cost2 = acJjzzVoApi:getCost()
    local goldIconAddH = 18
    local goldIcon1 = CCSprite:createWithSpriteFrameName("IconGold.png")
    goldIcon1:setAnchorPoint(ccp(0, 0.5))
    goldIcon1:setPosition(btnItem1:getContentSize().width / 2 + 10, btnItem1:getContentSize().height + goldIconAddH)
    btnItem1:addChild(goldIcon1)
    
    local costLb1 = GetTTFLabel(cost1, 25)
    costLb1:setAnchorPoint(ccp(1, 0.5))
    costLb1:setPosition(ccp(btnItem1:getContentSize().width / 2, btnItem1:getContentSize().height + goldIconAddH))
    btnItem1:addChild(costLb1)
    self.costLb1 = costLb1
    
    local btnItem2 = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn_Down.png", btnClick, 2, getlocal("activity_jjzz_btn", {acJjzzVoApi:getMultiNum()}), 25)
    btnItem2:setAnchorPoint(ccp(0.5, 0))
    btnItem2:setScale(btnScale)
    self.btnItem2 = btnItem2
    local btn2 = CCMenu:createWithItem(btnItem2);
    btn2:setTouchPriority(-(self.layerNum - 1) * 20 - 4);
    btn2:setPosition(ccp(G_VisibleSizeWidth / 2 + 150, btnY))
    cell:addChild(btn2)
    
    if cfg.buyLimit - vo.times < cfg.count then
        btnItem2:setEnabled(false)
    end
    if cfg.buyLimit - vo.times < 1 then
        btnItem1:setEnabled(false)
    end
    
    local goldIcon2 = CCSprite:createWithSpriteFrameName("IconGold.png")
    goldIcon2:setAnchorPoint(ccp(0, 0.5))
    goldIcon2:setPosition(btnItem2:getContentSize().width / 2 + 15, btnItem2:getContentSize().height + goldIconAddH)
    btnItem2:addChild(goldIcon2)
    
    local costLb2 = GetTTFLabel(cost2, 25)
    costLb2:setAnchorPoint(ccp(1, 0.5))
    costLb2:setPosition(ccp(btnItem2:getContentSize().width / 2 + 5, btnItem2:getContentSize().height + goldIconAddH))
    btnItem2:addChild(costLb2)
    self.costLb2 = costLb2
    
    local recordLb = GetTTFLabelWrap(getlocal("activity_jjzz_lb5", {cfg.buyLimit - vo.times, cfg.buyLimit}), G_is5x(G_getLS(25, 20), 18), CCSize(580, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    recordLb:setAnchorPoint(ccp(0.5, 0))
    recordLb:setPosition(G_VisibleSizeWidth * 0.5, 35)
    cell:addChild(recordLb)
    
    local hxReward = acJjzzVoApi:getHexieReward()
    if hxReward then
        local promptLb = GetTTFLabelWrap(getlocal("activity_jjzz_hexiePro", {hxReward.name}), 20, CCSize(G_VisibleSizeWidth - 60, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
        promptLb:setAnchorPoint(ccp(0.5, 0))
        promptLb:setPosition(G_VisibleSizeWidth / 2, btnY + G_is5x(120, 90))
        promptLb:setColor(G_ColorYellowPro)
        cell:addChild(promptLb)
    end
end

function acJjzzDialog:updateAcTime()
    local acVo = acJjzzVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb, "CCLabelTTF") then
        self.timeLb:setString(acJjzzVoApi:getTimeStr())
    end
end

function acJjzzDialog:tick()
    if acJjzzVoApi:isEnd() == true then
        self:close()
        do return end
    end
    self:updateAcTime()
end

function acJjzzDialog:updateUI()
    local vo = acJjzzVoApi:getAcVo()
    if self.tv then
        local recordPoint = self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
end

function acJjzzDialog:dispose()
    spriteController:removePlist("public/acjjzz.plist")
    spriteController:removeTexture("public/acjjzz.png")
end
