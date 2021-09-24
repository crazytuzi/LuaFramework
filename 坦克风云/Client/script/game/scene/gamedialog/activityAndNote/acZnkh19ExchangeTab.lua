acZnkh19ExchangeTab = {}

function acZnkh19ExchangeTab:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    
    return nc
end

function acZnkh19ExchangeTab:init(layerNum, parent)
    self.bgLayer = CCLayer:create()
    self.layerNum = layerNum
    self.parent = parent
    
    self:initTableView()
    
    return self.bgLayer
end

function acZnkh19ExchangeTab:initTableView()
    self.rewardTimeFlag = acZnkh19VoApi:isRewardTime()
    
    local exchangeBg = CCNode:create()
    exchangeBg:setAnchorPoint(ccp(0.5, 1))
    exchangeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, 644))
    exchangeBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 142)
    self.bgLayer:addChild(exchangeBg, 2)
    self.exchangeBg = exchangeBg
    
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local function onLoadIcon(fn, exBg)
        if self and self.parent and self.parent.isClosed and self.parent:isClosed() == false then
            exBg:setAnchorPoint(ccp(0.5, 1))
            exBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 142)
            self.bgLayer:addChild(exBg)
        end
    end
    local webImage = LuaCCWebImage:createWithURL(G_downloadUrl("active/acZnkh19_exBg.jpg"), onLoadIcon)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
    local vo = acZnkh19VoApi:getAcVo()
    local rechargeLb = GetTTFLabelWrap(getlocal("znkh19_recharge_rewardtip", {vo.cfg.recharge}), 20, CCSizeMake(290, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
    rechargeLb:setPosition(exchangeBg:getContentSize().width / 2, exchangeBg:getContentSize().height - 80)
    rechargeLb:setColor(G_ColorYellowPro)
    exchangeBg:addChild(rechargeLb)
    
    --滑动切换层
    local scrollLayer = CCLayer:create()
    self.bgLayer:addChild(scrollLayer, 10)
    scrollLayer:setBSwallowsTouches(false)
    scrollLayer:setTouchEnabled(true)
    local function tmpHandler(...)
        return self:touchEvent(...)
    end
    scrollLayer:registerScriptTouchHandler(tmpHandler, false, -(self.layerNum - 1) * 20 - 5, false)
    scrollLayer:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
    
    local rwidth = 80
    local flag, rgn, rn = acZnkh19VoApi:isCanRewardGems()
    local rechargeRewardList = acZnkh19VoApi:getRechargeRewards()
    for k, v in pairs(rechargeRewardList) do
        local function showInfo()
            G_showNewPropInfo(self.layerNum + 1, true, true, nil, v, true)
        end
        local icon, scale = G_getItemIcon(v, 100, false, self.layerNum + 1, showInfo)
        icon:setScale(rwidth / icon:getContentSize().height)
        icon:setPosition(40 + (2 * k - 1) / 2 * rwidth, exchangeBg:getContentSize().height - 150)
        icon:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
        exchangeBg:addChild(icon)
        
        local numLb = GetTTFLabel(FormatNumber(v.num), 18)
        numLb:setAnchorPoint(ccp(1, 0.5))
        local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function ()end)
        numBg:setAnchorPoint(ccp(1, 0))
        numBg:setContentSize(CCSizeMake(numLb:getContentSize().width + 5, numLb:getContentSize().height - 5))
        numBg:setPosition(ccp(icon:getContentSize().width - 3, 7))
        numBg:setOpacity(150)
        icon:addChild(numBg, 2)
        numLb:setPosition(numBg:getContentSize().width - 2, numBg:getContentSize().height / 2)
        numBg:addChild(numLb)
        numBg:setScale(1 / icon:getScale())
    end
    
    --领取按钮
    local priority, pos, btnScale = -(self.layerNum - 1) * 20 - 4, ccp(exchangeBg:getContentSize().width - 80, exchangeBg:getContentSize().height - 170), 0.6
    
    --刷新领取充值奖励按钮状态
    local function refreshGemsRewardStatus()
        local flag, rgn, rn = acZnkh19VoApi:isCanRewardGems()
        if flag == true then
            self.getRewardBtn:setEnabled(true)
            self.getRewardBtn:setVisible(true)
            self.goBtn:setEnabled(false)
            self.goBtn:setVisible(false)
            local rnBg = self.getRewardBtn:getChildByTag(401)
            if rn > 0 then --可领取的充值奖励次数
                if rnBg == nil or tolua.cast(rnBg, "LuaCCScale9Sprite") == nil then
                    local rnLb = GetTTFLabel(rn, 20)
                    local rnBg = LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png", CCRect(17, 17, 1, 1), function () end)
                    rnBg:setContentSize(CCSizeMake(36, 36))
                    rnBg:setScale(1 / self.getRewardBtn:getScale() * 0.8)
                    rnBg:setPosition(self.getRewardBtn:getContentSize().width, self.getRewardBtn:getContentSize().height)
                    self.getRewardBtn:addChild(rnBg)
                    rnLb:setTag(402)
                    rnLb:setPosition(getCenterPoint(rnBg))
                    rnBg:addChild(rnLb)
                else
                    rnBg = tolua.cast(rnBg, "LuaCCScale9Sprite")
                    rnLb = tolua.cast(rnBg:getChildByTag(402), "CCLabelTTF")
                    rnLb:setString(rn)
                end
            else
                if rnBg and tolua.cast(rnBg, "LuaCCScale9Sprite") then
                    rnBg:removeFromParentAndCleanup(true)
                    rnBg = nil
                end
            end
        else
            self.getRewardBtn:setEnabled(false)
            self.getRewardBtn:setVisible(false)
            self.goBtn:setEnabled(true)
            self.goBtn:setVisible(true)
        end
        if acZnkh19VoApi:isRewardTime() == true then --领奖时间不能跳转充值
            self.goBtn:setEnabled(true)
        end
    end
    
    local rgn = acZnkh19VoApi:getRechargeGems() --已充值金币数
    
    --领取充值奖励
    local function getRechargeReward()
        local flag = acZnkh19VoApi:isCanRewardGems()
        if flag == false then
            do return end
        end
        local function rewardedHandler(rewardList)
            if self:isClosed() == true then
                do return end
            end
            refreshGemsRewardStatus()
            self:refreshNumeralTv()
            G_showRewardTip(rewardList)
        end
        acZnkh19VoApi:gemsReward(rewardedHandler)
    end
    self.getRewardBtn = G_createBotton(exchangeBg, pos, {getlocal("daily_scene_get"), 22}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", getRechargeReward, btnScale, priority)
    
    --跳转充值页面
    local function goRecharge()
        activityAndNoteDialog:closeAllDialog()
        vipVoApi:showRechargeDialog(4)
    end
    self.goBtn = G_createBotton(exchangeBg, pos, {getlocal("recharge"), 22}, "creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", goRecharge, btnScale, priority)
    
    refreshGemsRewardStatus()
    
    --已充值金币数
    local rstr = getlocal("activity_baifudali_totalMoney") ..rgn
    local rechargeLb = GetTTFLabelWrap(rstr, 22, CCSizeMake(150, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    rechargeLb:setColor(G_ColorYellowPro)
    rechargeLb:setPosition(pos.x, pos.y + rechargeLb:getContentSize().height / 2 + 30)
    exchangeBg:addChild(rechargeLb)
    
    --金币瓜分奖池
    local rechargeBg = LuaCCSprite:createWithSpriteFrameName("acZnkh2019_rbg.png", function () end)
    rechargeBg:setAnchorPoint(ccp(0.5, 0))
    rechargeBg:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    rechargeBg:setPosition(exchangeBg:getContentSize().width / 2, 210)
    exchangeBg:addChild(rechargeBg, 5)
    local gemsPoolLb = GetTTFLabel(getlocal("znkh19_gempool"), 20)
    gemsPoolLb:setPosition(rechargeBg:getContentSize().width / 2, rechargeBg:getContentSize().height - gemsPoolLb:getContentSize().height / 2 - 30)
    gemsPoolLb:setColor(G_ColorYellowPro)
    rechargeBg:addChild(gemsPoolLb)
    self.rechargeBg = rechargeBg
    
    --奖池金币数
    local gems = acZnkh19VoApi:getTotalGems()
    local gemNumLb = GetTTFLabel(gems, 24)
    gemNumLb:setAnchorPoint(ccp(0, 0.5))
    gemNumLb:setTag(101)
    rechargeBg:addChild(gemNumLb)
    --金币图标
    local gemSp = CCSprite:createWithSpriteFrameName("iconGoldNew3.png")
    gemSp:setAnchorPoint(ccp(0, 0.5))
    gemSp:setScale(0.6)
    gemSp:setTag(102)
    rechargeBg:addChild(gemSp)
    local realWidth = gemNumLb:getContentSize().width + gemSp:getContentSize().width * gemSp:getScale() + 10
    gemNumLb:setPosition((rechargeBg:getContentSize().width - realWidth) / 2, 120)
    gemSp:setPosition(gemNumLb:getPositionX() + gemNumLb:getContentSize().width + 10, gemNumLb:getPositionY())
    
    self.ovalcfg = {
        scale = {1, 0.9, 0.8, 0.7, 0.6, 0.5, 0.5, 0.6, 0.7, 0.8, 0.9, 1},
        zorder = {6, 5, 4, 3, 2, 1, 1, 2, 3, 4, 5, 6},
        pos = {ccp(376, 165), ccp(486, 186), ccp(540, 231), ccp(528, 279), ccp(448, 315), ccp(364, 334), ccp(269, 334), ccp(187, 315), ccp(108, 279), ccp(89, 231), ccp(151, 186), ccp(258, 165)},
    }
    self.rewardIconSpTb = {}
    local pool = acZnkh19VoApi:getExchangePool()
    local kkc, kky, kkwidth, centerPos = 0.35, 240, 80, ccp(317, 80)
    for k = 1, 12 do
        local rs, zorder, pos = self.ovalcfg.scale[k], self.ovalcfg.zorder[k], self.ovalcfg.pos[k]
        local rnode = CCNode:create()
        rnode:setAnchorPoint(ccp(0.5, 0.5))
        rnode:setPosition(pos)
        rnode:setScale(rs)
        rnode:setTag(k)
        exchangeBg:addChild(rnode, zorder)
        local reward = pool[k]
        if reward then
            local function showInfo()
                if self.moveFlag == true then
                    do return end
                end
                local function realShow()
                    acZnkh19VoApi:showRewardExchangeRecordDialog(reward, self.layerNum + 1)
                end
                local rnode = tolua.cast(self.rewardIconSpTb[k], "CCNode")
                local tag = rnode:getTag()
                if tag <= 3 or tag >= 10 then --点击最前面显示的6个则直接显示
                    realShow()
                else
                    local mn, mType = 0, 1 --滚动次数，滚动方向
                    if tag > 6 then --向右滚动
                        mn, mType = 12 - tag, 1
                    else --向左滚动
                        mn, mType = tag - 1, 2
                    end
                    self:scrollMove(mType, 0.1, mn, realShow)
                end
            end
            local rewardIconSp = G_getItemIcon(reward, 100, false, self.layerNum, showInfo)
            rewardIconSp:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
            rewardIconSp:setScale(kkwidth / rewardIconSp:getContentSize().width)
            rewardIconSp:setPosition(getCenterPoint(rnode))
            rnode:addChild(rewardIconSp)
            
            local rtype = string.sub(reward.znkh19_rpos, 1, 1)
            if reward.num > 0 and rtype == "s" then
                local numLb = GetTTFLabel(FormatNumber(reward.num), 20)
                numLb:setAnchorPoint(ccp(1, 0.5))
                local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function ()end)
                numBg:setAnchorPoint(ccp(1, 0))
                numBg:setContentSize(CCSizeMake(numLb:getContentSize().width + 5, numLb:getContentSize().height - 5))
                numBg:setPosition(ccp(rewardIconSp:getContentSize().width - 3, 7))
                numBg:setOpacity(150)
                rewardIconSp:addChild(numBg, 2)
                numLb:setPosition(numBg:getContentSize().width - 2, numBg:getContentSize().height / 2)
                numBg:addChild(numLb)
                numBg:setScaleX(1 / rewardIconSp:getScaleX())
                numBg:setScaleY(1 / rewardIconSp:getScaleY())
            end
            
            local ballSp = CCSprite:createWithSpriteFrameName("acZnkh19_pball.png")
            ballSp:setPosition(getCenterPoint(rnode))
            rnode:addChild(ballSp, 2)
        end
        self.rewardIconSpTb[k] = rnode
    end
    
    local str, font = getlocal("propOwned"), 20
    local ownLb = GetTTFLabelWrap(str, font, CCSizeMake(80, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
    local tempLb = GetTTFLabel(str, font)
    local realWidth = tempLb:getContentSize().width
    if realWidth > ownLb:getContentSize().width then
        realWidth = ownLb:getContentSize().width
    end
    ownLb:setAnchorPoint(ccp(0, 0.5))
    ownLb:setPosition(15, 52)
    exchangeBg:addChild(ownLb)
    
    self.numTvWidth, self.numTvHeight = 50, 55
    local function numeralTvCallBack(...)
        return self:numeralTvEventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(numeralTvCallBack)
    self.numeralTv = LuaCCTableView:createHorizontalWithEventHandler(hd, CCSizeMake(490 - realWidth - 20, self.numTvHeight), nil)
    self.numeralTv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.numeralTv:setPosition(ccp(ownLb:getPositionX() + realWidth + 5, 24))
    self.numeralTv:setMaxDisToBottomOrTop(80)
    exchangeBg:addChild(self.numeralTv)
    
    self.numeralKa = {--当前选择的数字
        {"o0", "o0", 0}, --橙色数字
        {"o0", "o0", 0}, --紫色数字
    }
    
    --赠送数字
    local function giveNumeralHandler()
        acZnkh19VoApi:showGiveNumeralDialog(self.layerNum + 1)
    end
    pos = ccp(exchangeBg:getContentSize().width - 80, 52)
    local giveBtn = G_createBotton(exchangeBg, pos, {getlocal("alien_tech_send"), 22}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", giveNumeralHandler, btnScale, priority)
    
    self.cellWidth, self.cellHeight = G_VisibleSizeWidth - 10, 150
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.cellWidth, G_VisibleSizeHeight - exchangeBg:getContentSize().height - 140 - 30), nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition(ccp(5, 20))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(80)
    
    --兑换记录
    local function showRecords()
        local function realShow()
            acZnkh19VoApi:showExchangeRecordsDialog(self.layerNum + 1)
        end
        acZnkh19VoApi:getLog(2, realShow)
    end
    
    local logBtn = G_createBotton(self.bgLayer, ccp(G_VisibleSizeWidth - 70, G_VisibleSizeHeight - 390), {}, "bless_record.png", "bless_record.png", "bless_record.png", showRecords, 0.7, -(self.layerNum - 1) * 20 - 3, 10)
    local logBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png", CCRect(60, 20, 1, 1), function ()end)
    logBg:setAnchorPoint(ccp(0.5, 1))
    logBg:setContentSize(CCSizeMake(logBtn:getContentSize().width + 10, 40))
    logBg:setPosition(ccp(logBtn:getContentSize().width / 2, 0))
    logBg:setScale(1 / logBtn:getScale())
    logBtn:addChild(logBg)
    local logLb = GetTTFLabelWrap(getlocal("serverwar_point_record"), 22, CCSize(100, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    logLb:setPosition(logBg:getContentSize().width / 2, logBg:getContentSize().height / 2)
    logLb:setColor(G_ColorYellowPro)
    logBg:addChild(logLb)
    
    --兑换规则
    local function showInfoStr()
        local tabStr, textFormatTb = {}, {}
        for k = 1, 8 do
            local args = {}
            local format = {}
            if k == 2 then
                args = {acZnkh19VoApi:getMaxDivideGems()}
                format = {richFlag = true, richColor = {nil, G_ColorGreen, nil}}
            elseif k == 5 then
                format = {richFlag = true, richColor = {nil, G_ColorGreen, nil}}
            elseif k == 7 then
                format = {richFlag = true, richColor = {nil, G_ColorGreen, nil, G_ColorGreen, nil}}
            elseif k == 8 then
                format = {}
                table.insert(tabStr, getlocal("znkh19_exchange_rule"..k, args))
                table.insert(textFormatTb, format)
                
                format = {richFlag = true, richColor = {G_ColorRed}}
                table.insert(tabStr, getlocal("znkh19_exchange_makeup"))
                table.insert(textFormatTb, format)
                
                local vo = acZnkh19VoApi:getAcVo()
                for k, v in pairs(vo.cfg.exchangeS) do
                    local numKey1, numKey2 = tonumber(RemoveFirstChar(v.need[1])), tonumber(RemoveFirstChar(v.need[2]))
                    local cstr, color
                    if numKey1 <= 10 and numKey2 <= 10 then
                        cstr = getlocal("armorMatrix_color_5")
                        color = G_ColorYellowPro
                    elseif numKey1 > 10 and numKey2 > 10 then
                        cstr = getlocal("armorMatrix_color_4")
                        color = G_ColorPurple
                    end
                    numKey1 = numKey1 % 10
                    numKey2 = numKey2 % 10
                    if numKey1 == 0 then
                        numKey1 = 9
                    else
                        numKey1 = numKey1 - 1
                    end
                    if numKey2 == 0 then
                        numKey2 = 9
                    else
                        numKey2 = numKey2 - 1
                    end
                    local str = ""
                    if cstr then
                        str = "        "..numKey1.." + "..numKey2.." ("..cstr..")"
                    else
                        str = "        "..numKey1.." + "..numKey2
                    end
                    local format = {richFlag = true, richColor = {color}}
                    table.insert(tabStr, str)
                    table.insert(textFormatTb, format)
                end
            end
            if k ~= 8 then
                table.insert(tabStr, getlocal("znkh19_exchange_rule"..k, args))
                table.insert(textFormatTb, format)
            end
        end
        local titleStr = getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, titleStr, tabStr, nil, 25, textFormatTb)
    end
    G_createBotton(self.exchangeBg, ccp(G_VisibleSizeWidth - 40, self.exchangeBg:getContentSize().height - 24), {}, "i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon2.png", showInfoStr, 0.7, -(self.layerNum - 1) * 20 - 3)
    
    local function refreshUI()
        self:refresh()
    end
    self.refreshListener = refreshUI
    eventDispatcher:addEventListener("znkh19.refresh", refreshUI)
    
    self.touchArr = {}
    self.minTouchx, self.maxTouchx = 0, G_VisibleSizeWidth
    self.minTouchy, self.maxTouchy = G_VisibleSizeHeight - 142 - 560, G_VisibleSizeHeight - 142 - 280
    self.moveDisX = 100
    self.moveFlag = false
    self.startPos = ccp(0, 0)
end

function acZnkh19ExchangeTab:scrollMove(dir, mt, mn, moveEnd)
    if mn == nil or mn <= 0 then
        do return end
    end
    self.moveFlag = true
    for k, v in pairs(self.rewardIconSpTb) do
        v = tolua.cast(v, "CCNode")
        local op = tonumber(v:getTag())
        local tp = 1
        if dir == 1 then --向右翻滚
            tp = op + 1
            if tp > 12 then
                tp = 1
            end
        elseif dir == 2 then --向左翻滚
            tp = op - 1
            if tp <= 0 then
                tp = 12
            end
        end
        local arr = CCArray:create()
        arr:addObject(CCMoveTo:create(mt, self.ovalcfg.pos[tp]))
        arr:addObject(CCScaleTo:create(mt, self.ovalcfg.scale[tp]))
        local iconAc = CCSpawn:create(arr)
        v:runAction(CCSequence:createWithTwoActions(iconAc, CCCallFunc:create(function ()
            if k == 12 then
                if mn > 1 then
                    mn = mn - 1
                    self:scrollMove(dir, mt, mn, moveEnd)
                else
                    self.moveFlag = false
                    if moveEnd then
                        moveEnd()
                    end
                end
            end
        end)))
        v:setTag(tp)
        self.exchangeBg:reorderChild(v, self.ovalcfg.zorder[tp])
    end
end

function acZnkh19ExchangeTab:rightScroll()
    self:scrollMove(1, 0.3, 1)
end

function acZnkh19ExchangeTab:leftScroll()
    self:scrollMove(2, 0.3, 1)
end

function acZnkh19ExchangeTab:isTouchInArea(x, y)
    if (y >= self.minTouchy and y <= self.maxTouchy) then
        return true
    end
    return false
end

function acZnkh19ExchangeTab:canMove()
    if self.moveFlag == true then
        return false
    end
    return true
end

function acZnkh19ExchangeTab:touchEvent(fn, x, y, touch)
    if self:canMove() == false then
        do return end
    end
    if fn == "began" then
        if self.touchEnable == false then
            return false
        end
        table.insert(self.touchArr, touch)
        if SizeOfTable(self.touchArr) > 1 then
            self.touchArr = {}
            return false
        end
        self.startPos = ccp(x, y)
        return true
    elseif fn == "moved" then
        
    elseif fn == "ended" then
        self.touchArr = {}
        if self:isTouchInArea(self.startPos.x, self.startPos.y) == true and self:isTouchInArea(x, y) == true then
            local moveX = self.startPos.x - x
            if moveX < -self.moveDisX then
                self:rightScroll()
            elseif moveX > self.moveDisX then
                self:leftScroll()
            end
        end
    else
        self.touchArr = {}
    end
end

function acZnkh19ExchangeTab:numeralTvEventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return 20
    elseif fn == "tableCellSizeForIndex" then
        local tmpSize = CCSizeMake(self.numTvWidth, self.numTvHeight)
        return tmpSize
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local key = "o" .. (idx + 1)
        local num = acZnkh19VoApi:getNumeralNum(key)
        local icon = acZnkh19VoApi:getNumeralPropIcon(key, nil, {num, 16})
        icon:setScale(self.numTvHeight / icon:getContentSize().height)
        icon:setPosition(self.numTvWidth / 2, self.numTvHeight / 2)
        cell:addChild(icon)
        
        if num == 0 then
            local shadeBg = CCSprite:createWithSpriteFrameName("acZnkh19_zc.png")
            shadeBg:setPosition(getCenterPoint(icon))
            shadeBg:setOpacity(180)
            icon:addChild(shadeBg, 3)
        else
            acZnkh19VoApi:refreshNumeralPropIcon(icon, num)
        end
        
        return cell
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
        return true
    elseif fn == "ccTouchMoved" then
        self.isMoved = true
    elseif fn == "ccTouchEnded" then
        
    end
end

function acZnkh19ExchangeTab:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return 3
    elseif fn == "tableCellSizeForIndex" then
        local tmpSize = CCSizeMake(self.cellWidth, self.cellHeight)
        return tmpSize
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local bg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function () end)
        bg:setContentSize(CCSizeMake(self.cellWidth - 10, self.cellHeight - 5))
        bg:setPosition(self.cellWidth / 2, self.cellHeight - bg:getContentSize().height / 2)
        cell:addChild(bg)
        local titleBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png", CCRect(105, 16, 1, 1), function () end)
        titleBg:setAnchorPoint(ccp(0, 1))
        titleBg:setPosition(2, self.cellHeight - 8)
        titleBg:setContentSize(CCSizeMake(bg:getContentSize().width - 20, titleBg:getContentSize().height))
        bg:addChild(titleBg)
        
        local kaHeight = 75
        local leftPosX, posY = 20, (self.cellHeight - 42) / 2
        local kaWidth = kaHeight / 86 * 70
        local tilteStr, btnStr, btnFunc, btnEnabled = "", "", nil, true
        if idx == 0 then
            tilteStr = getlocal("znkh19_makeup_numeral")
            print("devide flag == ", acZnkh19VoApi:isDevidedGems())
            if acZnkh19VoApi:isDevidedGems() == 1 then
                btnStr = getlocal("znkh19_hasDivided")
                btnEnabled = false
            else
                btnStr = getlocal("znkh19_divide")
            end
            if acZnkh19VoApi:isRewardTime() == true then --领奖时间不能瓜分
                btnEnabled = false
            end
            local satisfy = true --是否有瓜分资格
            local sltNumerals = self:getSelectNumerals(1)
            local numKeyTb = acZnkh19VoApi:getGemsNeed() --2019数字合集
            local dsort = acZnkh19VoApi:getAcVo().cfg.dsort
            for k, v in pairs(dsort) do
                local key = acZnkh19VoApi:getNumeralKeyFromServer(k)
                local keynum = acZnkh19VoApi:getNumeralNum(v)
                if sltNumerals[v] then
                    keynum = keynum - sltNumerals[v] --减掉兑换选中的数量
                    if keynum < 0 then
                        keynum = 0
                    end
                end
                local icon = acZnkh19VoApi:getNumeralPropIcon(v)
                icon:setScale(kaHeight / icon:getContentSize().height)
                icon:setPosition(leftPosX + (2 * k - 1) * kaWidth / 2 + (k - 1) * 10, posY)
                bg:addChild(icon)
                if keynum == 0 then
                    satisfy = false
                    local shadeBg = CCSprite:createWithSpriteFrameName("acZnkh19_zc.png")
                    shadeBg:setPosition(getCenterPoint(icon))
                    shadeBg:setOpacity(180)
                    icon:addChild(shadeBg, 3)
                else
                    acZnkh19VoApi:refreshNumeralPropIcon(icon, keynum)
                end
            end
            
            --瓜分金币处理
            local function divideGemsHandler()
                print("===divideGemsHandler===")
                if acZnkh19VoApi:isDevidedGems() == 1 then
                    do return end
                end
                if satisfy == false then
                    G_showTipsDialog(getlocal("znkh19_divide_disable"))
                    do return end
                end
                local function devideHandler()
                    self:refreshTv()
                end
                acZnkh19VoApi:devideGems(devideHandler)
            end
            btnFunc = divideGemsHandler
        else --数字组合
            btnStr = getlocal("code_gift")
            local bgname, kacfg = nil, self.numeralKa[idx]
            local exchangeNumBg, exchangeNumLb
            if idx == 1 then --橙色数字组合
                tilteStr = getlocal("znkh19_exchange_reward1")
                bgname = "acZnkh19_yellowka.png"
            else --紫色数字组合
                tilteStr = getlocal("znkh19_exchange_reward2")
                bgname = "acZnkh19_purpleka.png"
            end
            local sx = 80
            local num = kacfg[3]
            local rtb = {}
            for k = 1, 2 do
                local icon
                local nk = kacfg[k]
                --选择数字
                local function selectNumHandler()
                    local function selectCallback(numKey)
                        print("numKey,nk====>>> ", numKey, nk)
                        if numKey ~= nk then
                            self.numeralKa[idx][k] = numKey
                            self.numeralKa[idx][3] = 1
                            self:refreshTv()
                        end
                    end
                    local sltNumerals = self:getSelectNumerals(idx)
                    acZnkh19VoApi:showSelectNumeralDialog(idx, sltNumerals, selectCallback, self.layerNum + 1)
                end
                if nk == "o0" then
                    icon = LuaCCSprite:createWithSpriteFrameName(bgname, selectNumHandler)
                    local addSp = CCSprite:createWithSpriteFrameName("acZnkh19_kaslt.png")
                    addSp:setPosition(icon:getContentSize().width / 2, 53)
                    icon:addChild(addSp)
                    -- 忽隐忽现
                    local fade1 = CCFadeTo:create(1, 55)
                    local fade2 = CCFadeTo:create(1, 255)
                    local seq = CCSequence:createWithTwoActions(fade1, fade2)
                    local repeatEver = CCRepeatForever:create(seq)
                    addSp:runAction(repeatEver)
                    
                    local sltNumerals = self:getSelectNumerals(idx)
                    local numerals = acZnkh19VoApi:getCanSelectNumerals(sltNumerals, idx) --可以选择的数字序列
                    if SizeOfTable(numerals) > 0 then --有可以选择的数字
                        local tipSp = CCSprite:createWithSpriteFrameName("IconTip.png")
                        tipSp:setPosition(icon:getContentSize().width - 5, icon:getContentSize().height - 5)
                        tipSp:setScale(0.6)
                        icon:addChild(tipSp)
                    end
                else
                    icon = acZnkh19VoApi:getNumeralPropIcon(nk, selectNumHandler, {num, 18})
                    rtb[k] = icon
                end
                icon:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                icon:setScale(kaHeight / icon:getContentSize().height)
                icon:setPosition(leftPosX + (2 * k - 1) * kaWidth / 2 + (k - 1) * sx, posY)
                bg:addChild(icon)
                
                acZnkh19VoApi:refreshNumeralPropIcon(icon, num)
            end
            
            local addSp = CCSprite:createWithSpriteFrameName("acZnkh19_add.png")
            addSp:setPosition(leftPosX + kaWidth + sx / 2, posY + 3)
            bg:addChild(addSp)
            
            local equalSp = CCSprite:createWithSpriteFrameName("acZnkh19_equal.png")
            equalSp:setPosition(leftPosX + kaWidth * 2 + 3 * sx / 2, addSp:getPositionY())
            bg:addChild(equalSp)
            
            local numkey1, numkey2 = kacfg[1], kacfg[2]
            local rewardIconSp
            local exReward = acZnkh19VoApi:getExchangeReward(numkey1, numkey2) --兑换的奖励
            if exReward == nil then
                rewardIconSp = CCSprite:createWithSpriteFrameName("acZnkh19_unkownProp.png")
            else
                local function showInfo()
                    G_showNewPropInfo(self.layerNum + 1, true, true, nil, exReward, true)
                end
                rewardIconSp = G_getItemIcon(exReward, 100, false, self.layerNum, showInfo)
                rewardIconSp:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                local rewardNum = num * exReward.num
                local numLb = GetTTFLabel(FormatNumber(rewardNum), 18)
                numLb:setAnchorPoint(ccp(1, 0.5))
                numLb:setTag(22)
                local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function ()end)
                numBg:setAnchorPoint(ccp(1, 0))
                numBg:setContentSize(CCSizeMake(numLb:getContentSize().width + 5, numLb:getContentSize().height - 5))
                numBg:setPosition(ccp(rewardIconSp:getContentSize().width - 2, 2))
                numBg:setOpacity(150)
                numBg:setTag(11)
                rewardIconSp:addChild(numBg, 3)
                numLb:setPosition(ccp(numBg:getContentSize().width - 2, numBg:getContentSize().height / 2))
                numBg:addChild(numLb)
                rewardIconSp:setScale(kaHeight / rewardIconSp:getContentSize().height)
                numBg:setScale(1 / rewardIconSp:getScale())
            end
            rewardIconSp:setScale(kaHeight / rewardIconSp:getContentSize().height)
            rewardIconSp:setPosition(equalSp:getPositionX() + sx / 2 + rewardIconSp:getScale() * rewardIconSp:getContentSize().width / 2, equalSp:getPositionY())
            bg:addChild(rewardIconSp)
            
            if exReward then
                local rewardNum = num * exReward.num
                self:refreshExchangeReward(rewardIconSp, rewardNum)
            end
            
            exchangeNumBg = LuaCCScale9Sprite:createWithSpriteFrameName("proBar_n3.png", CCRect(3, 3, 1, 1), function () end)
            exchangeNumBg:setContentSize(CCSizeMake(40, 25))
            exchangeNumBg:setPosition(bg:getContentSize().width - 70, 80)
            bg:addChild(exchangeNumBg)
            exchangeNumLb = GetTTFLabel(num, 20)
            exchangeNumLb:setPosition(getCenterPoint(exchangeNumBg))
            exchangeNumBg:addChild(exchangeNumLb)
            
            --是否在2019数字组合内
            local function in2019(numkey)
                local numKeyTb = acZnkh19VoApi:getAcVo().cfg.dsort --2019数字合集
                if G_tableContains(numKeyTb, numkey) == true then
                    return true
                end
                return false
            end
            
            --刷新卡片及道具数量
            local function refresh()
                local num = self.numeralKa[idx][3]
                for k, v in pairs(rtb) do
                    acZnkh19VoApi:refreshNumeralPropIcon(v, num)
                end
                if exReward then
                    local rewardNum = num * exReward.num
                    self:refreshExchangeReward(rewardIconSp, rewardNum)
                end
                exchangeNumLb:setString(num)
            end
            
            --判断两个数字卡片是否都选中
            local function isNumeralFull(numkey)
                if numkey == nil or numkey == "o0" then
                    return false
                end
                return true
            end
            
            --增加兑换数量
            local function touchAdd()
                local numkey1, numkey2 = self.numeralKa[idx][1], self.numeralKa[idx][2]
                if isNumeralFull(numkey1) == false or isNumeralFull(numkey2) == false then
                    G_showTipsDialog(getlocal("znkh19_numeral_notfull"))
                    do return end
                end
                local max = 0
                if numkey1 == numkey2 then
                    local keynum = acZnkh19VoApi:getNumeralNum(numkey1)
                    max = math.floor(keynum / 2)
                else
                    local num1, num2 = acZnkh19VoApi:getNumeralNum(numkey1), acZnkh19VoApi:getNumeralNum(numkey2)
                    max = math.min(num1, num2)
                end
                local num = self.numeralKa[idx][3]
                if num >= max then
                    do return end
                end
                self.numeralKa[idx][3] = num + 1
                
                if idx == 1 and (in2019(numkey1) == true or in2019(numkey2) == true) then
                    self:refreshTv() --橙色数字有可能影响瓜分资格，则刷新整个列表
                else
                    refresh() --刷新卡片及道具数量
                end
            end
            
            --减少兑换数量
            local function touchMinus()
                local numkey1, numkey2 = self.numeralKa[idx][1], self.numeralKa[idx][2]
                if isNumeralFull(numkey1) == false or isNumeralFull(numkey2) == false then
                    G_showTipsDialog(getlocal("znkh19_numeral_notfull"))
                    do return end
                end
                
                local num = self.numeralKa[idx][3]
                if num <= 1 then
                    do return end
                end
                self.numeralKa[idx][3] = num - 1
                
                if idx == 1 and (in2019(numkey1) == true or in2019(numkey2) == true) then
                    self:refreshTv() --橙色数字有可能影响瓜分资格，则刷新整个列表
                else
                    refresh() --刷新卡片及道具数量
                end
            end
            
            local addedSp = CCSprite:createWithSpriteFrameName("greenPlus.png")
            addedSp:setPosition(ccp(exchangeNumBg:getPositionX() + exchangeNumBg:getContentSize().width / 2 + addedSp:getContentSize().width / 2, exchangeNumBg:getPositionY()))
            addedSp:setScale(0.8)
            bg:addChild(addedSp, 1)
            
            local rect = CCSizeMake(50, 50)
            local addTouchBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), touchAdd)
            addTouchBg:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
            addTouchBg:setContentSize(rect)
            addTouchBg:setOpacity(0)
            addTouchBg:setPosition(addedSp:getPosition())
            bg:addChild(addTouchBg, 1)
            
            local minusSp = CCSprite:createWithSpriteFrameName("greenMinus.png")
            minusSp:setPosition(ccp(exchangeNumBg:getPositionX() - exchangeNumBg:getContentSize().width / 2 - minusSp:getContentSize().width / 2, exchangeNumBg:getPositionY()))
            minusSp:setScale(0.8)
            bg:addChild(minusSp, 1)
            
            local minusTouchBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), touchMinus)
            minusTouchBg:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
            minusTouchBg:setContentSize(rect)
            minusTouchBg:setOpacity(0)
            minusTouchBg:setPosition(minusSp:getPosition())
            bg:addChild(minusTouchBg, 1)
            
            --数字兑换奖励处理
            local function exchangeHandler()
                local numkey1, numkey2 = self.numeralKa[idx][1], self.numeralKa[idx][2]
                if isNumeralFull(numkey1) == false or isNumeralFull(numkey2) == false then
                    G_showTipsDialog(getlocal("znkh19_numeral_notfull"))
                    do return end
                end
                local num = self.numeralKa[idx][3]
                local function exchangeCallback(reward)
                    self.numeralKa[idx] = {"o0", "o0", 0} --清空选中的数字
                    self:refreshTv()
                    self:refreshNumeralTv()
                    G_showRewardTip({reward}, true)
                    G_showTipsDialog(getlocal("activity_tccx_change_sucess"))
                end
                numkey1 = acZnkh19VoApi:getNumeralKeyForServer(numkey1)
                numkey2 = acZnkh19VoApi:getNumeralKeyForServer(numkey2)
                acZnkh19VoApi:exchangeNumeralReward({numkey1, numkey2}, num, exchangeCallback)
            end
            btnFunc = exchangeHandler
        end
        local titleLb = GetTTFLabelWrap(tilteStr, 20, CCSizeMake(self.cellWidth - 30, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
        titleLb:setAnchorPoint(ccp(0, 0.5))
        titleLb:setPosition(15, titleBg:getContentSize().height / 2)
        titleBg:addChild(titleLb)
        
        local pos, btnScale, priority = ccp(bg:getContentSize().width - 70, 28), 0.6, -(self.layerNum - 1) * 20 - 2
        if idx == 0 then
            pos = ccp(bg:getContentSize().width - 70, posY)
        end
        local btn = G_createBotton(bg, pos, {btnStr, 22}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", btnFunc, btnScale, priority)
        btn:setEnabled(btnEnabled)
        
        return cell
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
        return true
    elseif fn == "ccTouchMoved" then
        self.isMoved = true
    elseif fn == "ccTouchEnded" then
        
    end
end

function acZnkh19ExchangeTab:refreshTv()
    if self.tv then
        local recordPoint = self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
end

function acZnkh19ExchangeTab:refreshNumeralTv()
    if self.numeralTv then
        local recordPoint = self.numeralTv:getRecordPoint()
        self.numeralTv:reloadData()
        self.numeralTv:recoverToRecordPoint(recordPoint)
    end
end

function acZnkh19ExchangeTab:refreshExchangeReward(rewardSp, num)
    if rewardSp == nil or tolua.cast(rewardSp, "LuaCCSprite") == nil then
        do return end
    end
    local numBg = rewardSp:getChildByTag(11)
    if numBg and tolua.cast(numBg, "LuaCCScale9Sprite") then
        local numLb = numBg:getChildByTag(22)
        if numLb and tolua.cast(numLb, "CCLabelTTF") then
            numLb:setString(FormatNumber(num))
            numBg:setContentSize(CCSizeMake(numLb:getContentSize().width + 5, numLb:getContentSize().height - 5))
            numBg:setScale(1 / rewardSp:getScale())
            numLb:setPosition(ccp(numBg:getContentSize().width - 2, numBg:getContentSize().height / 2))
        end
    end
end

--兑换选中的数字组合
function acZnkh19ExchangeTab:getSelectNumerals(idx)
    local sltNumerals = {}
    local numkey1, numkey2, num = self.numeralKa[idx][1], self.numeralKa[idx][2], self.numeralKa[idx][3]
    sltNumerals[numkey1] = (sltNumerals[numkey1] or 0) + num
    sltNumerals[numkey2] = (sltNumerals[numkey2] or 0) + num
    
    return sltNumerals
end

function acZnkh19ExchangeTab:tick()
    local flag = acZnkh19VoApi:isRewardTime()
    if flag == true and self.rewardTimeFlag == false then
        self:refresh()
    end
end

function acZnkh19ExchangeTab:refresh()
    self:refreshNumeralTv()
    self:refreshTv()
    --刷新金币奖池
    if self.rechargeBg and tolua.cast(self.rechargeBg, "CCSprite") then
        local gemNumLb = tolua.cast(self.rechargeBg:getChildByTag(101), "CCLabelTTF")
        local gemSp = tolua.cast(self.rechargeBg:getChildByTag(102), "CCSprite")
        if gemNumLb and gemSp then
            local gems = acZnkh19VoApi:getTotalGems()
            gemNumLb:setString(gems)
            local realWidth = gemNumLb:getContentSize().width + gemSp:getContentSize().width * gemSp:getScale() + 10
            gemNumLb:setPosition((self.rechargeBg:getContentSize().width - realWidth) / 2, 120)
            gemSp:setPosition(gemNumLb:getPositionX() + gemNumLb:getContentSize().width + 10, gemNumLb:getPositionY())
        end
    end
end

function acZnkh19ExchangeTab:updateUI()
    
end

function acZnkh19ExchangeTab:isClosed()
    if self.bgLayer and tolua.cast(self.bgLayer, "CCLayer") then
        return false
    end
    return true
end

function acZnkh19ExchangeTab:dispose()
    if self.refreshListener then
        eventDispatcher:removeEventListener("znkh19.refresh", self.refreshListener)
        self.refreshListener = nil
    end
    self.touchArr = nil
    self.minTouchx, self.maxTouchx = nil, nil
    self.minTouchy, self.maxTouchy = nil, nil
    self.moveDisX = nil
    self.moveFlag = nil
    self.startPos = nil
    self.exchangeBg, self.rechargeBg = nil, nil
    self.ovalcfg = nil
    self.numeralTv, self.tv = nil, nil
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer = nil
    end
    self = nil
end
