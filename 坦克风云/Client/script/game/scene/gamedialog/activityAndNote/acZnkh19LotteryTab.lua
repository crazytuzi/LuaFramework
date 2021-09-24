acZnkh19LotteryTab = {}

function acZnkh19LotteryTab:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    
    return nc
end

function acZnkh19LotteryTab:init(layerNum, parent)
    self.bgLayer = CCLayer:create()
    self.layerNum = layerNum
    self.parent = parent
    
    self:initTableView()
    
    return self.bgLayer
end

function acZnkh19LotteryTab:initTableView()
    self.freeFlag = acZnkh19VoApi:isFreeLottery()
    self.rewardTimeFlag = acZnkh19VoApi:isRewardTime()
    
    local lotteryBg = CCNode:create()
    lotteryBg:setAnchorPoint(ccp(0.5, 1))
    lotteryBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, 712))
    lotteryBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 142)
    self.bgLayer:addChild(lotteryBg, 2)
    self.lotteryBg = lotteryBg
    
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/acZnkh2019_anim1.plist")
    spriteController:addTexture("public/acZnkh2019_anim1.png")
    spriteController:addPlist("public/acZnkh2019_anim2.plist")
    spriteController:addTexture("public/acZnkh2019_anim2.png")
    local function onLoadIcon(fn, ltryBg)
        if self and self.parent and self.parent.isClosed and self.parent:isClosed() == false then
            ltryBg:setAnchorPoint(ccp(0.5, 1))
            ltryBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 142)
            self.bgLayer:addChild(ltryBg)
        end
    end
    local webImage = LuaCCWebImage:createWithURL(G_downloadUrl("active/acZnkh19_ltryBg.jpg"), onLoadIcon)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
    local tipBg = LuaCCScale9Sprite:createWithSpriteFrameName("acZnkh19_wzbg.png", CCRect(48, 48, 1, 1), function () end)
    tipBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 120, 100))
    tipBg:setPosition(G_VisibleSizeWidth / 2, lotteryBg:getContentSize().height - tipBg:getContentSize().height / 2 - 55)
    lotteryBg:addChild(tipBg)
    
    local dsort = acZnkh19VoApi:getAcVo().cfg.dsort
    local key = acZnkh19VoApi:getNumeralKeyFromServer(dsort[1])
    key = tonumber(tonumber(RemoveFirstChar(key)))
    local cstr = ""
    if key > 10 then
        cstr = getlocal("armorMatrix_color_4")
    else
        cstr = getlocal("armorMatrix_color_5")
    end
    local tipLb, lbHeight = G_getRichTextLabel(getlocal("znkh19_lottery_tip", {cstr}), {nil, G_ColorYellowPro, nil, G_ColorYellowPro, nil}, 22, tipBg:getContentSize().width - 40, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    tipLb:setAnchorPoint(ccp(0.5, 1))
    tipLb:setPosition(tipBg:getContentSize().width / 2, tipBg:getContentSize().height / 2 + lbHeight / 2)
    tipBg:addChild(tipLb)
    
    self.lotteryBg = lotteryBg
    
    local function showRecords()
        local function realShow()
            local logs = acZnkh19VoApi:getLotteryLog()
            if logs and SizeOfTable(logs) > 0 then
                local logList = {}
                for k, v in pairs(logs) do
                    local title = {getlocal("activity_qxtw_buy", {v[1]})}
                    
                    local rewardList = {}
                    for k, r in pairs(v[2]) do
                        local reward = FormatItem(r, nil, true)[1]
                        table.insert(rewardList, reward)
                    end
                    local hxReward = acZnkh19VoApi:getHxReward()
                    if hxReward then --插入和谐版奖励
                        hxReward.num = hxReward.num * (v[1] or 1)
                        table.insert(rewardList, 1, hxReward)
                    end
                    local content = {{rewardList}}
                    
                    local log = {title = title, content = content, ts = v[3]}
                    table.insert(logList, log)
                end
                require "luascript/script/game/scene/gamedialog/activityAndNote/acCjyxSmallDialog"
                acCjyxSmallDialog:showLogDialog("TankInforPanel.png", CCSizeMake(550, G_VisibleSizeHeight - 300), CCRect(130, 50, 1, 1), {getlocal("activity_customLottery_RewardRecode"), G_ColorWhite}, logList, false, self.layerNum + 1, nil, true, 10, true, true, "znkh2019")
            else
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("activity_tccx_no_record"), 30)
            end
        end
        acZnkh19VoApi:getLog(1, realShow)
    end
    
    local logBtn = G_createBotton(self.bgLayer, ccp(60, G_VisibleSizeHeight - 340), {}, "bless_record.png", "bless_record.png", "bless_record.png", showRecords, 0.7, -(self.layerNum - 1) * 20 - 3, 1)
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
    
    --抽奖奖池展示
    self.lightSpTb, self.iconTb, self.ballSpTb = {}, {}, {}
    self.animLightSpTb, self.animLightNodeTb = {}, {} --播放抽奖动画时存储的光柱动画对象
    self.ridx = {}
    self.rpos = {ccp(320, 360), ccp(320, 228), ccp(132, 262), ccp(500, 262), ccp(130, 406), ccp(498, 406), ccp(320, 484)}
    self.rzorder = {3, 4, 4, 4, 3, 3, 2}
    local rwidth = 80
    self.rpool = acZnkh19VoApi:getLotteryPool()
    for k, v in pairs(self.rpool) do
        local function showInfo()
            G_showNewPropInfo(self.layerNum + 1, true, true, nil, v, true)
        end
        local icon = G_getItemIcon(v, 100, false, self.layerNum + 1, showInfo)
        icon:setScale(rwidth / icon:getContentSize().height)
        icon:setPosition(self.rpos[k])
        icon:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
        lotteryBg:addChild(icon, self.rzorder[k])
        
        local numLb = GetTTFLabel(FormatNumber(v.num), 18)
        numLb:setAnchorPoint(ccp(1, 0))
        numLb:setScale(1 / icon:getScale())
        numLb:setPosition(ccp(icon:getContentSize().width - 5, 2))
        icon:addChild(numLb, 4)
        local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function ()end)
        numBg:setAnchorPoint(ccp(1, 0))
        numBg:setContentSize(CCSizeMake(numLb:getContentSize().width * numLb:getScale() + 5, numLb:getContentSize().height * numLb:getScale() - 5))
        numBg:setPosition(ccp(icon:getContentSize().width - 5, numLb:getPositionY()))
        numBg:setOpacity(150)
        icon:addChild(numBg, 3)
        
        local ballSp = CCSprite:createWithSpriteFrameName("acZnkh19_pball.png")
        ballSp:setPosition(self.rpos[k])
        lotteryBg:addChild(ballSp, self.rzorder[k])
        
        local idxKey = self:getridxKey(v)
        self.ridx[idxKey] = k --记录奖励位置索引
        
        self.iconTb[k] = icon
        self.ballSpTb[k] = ballSp
    end
    
    self:playCustomDisplayAnim()
    
    self:initLotteryBtns()
    
    local posy = 220
    local descLb = GetTTFLabelWrap(getlocal("znkh19_lottery_desc"), 20, CCSizeMake(G_VisibleSizeWidth - 60, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    descLb:setAnchorPoint(ccp(0.5, 1))
    descLb:setColor(G_ColorYellowPro)
    descLb:setPosition(G_VisibleSizeWidth / 2, posy)
    self.bgLayer:addChild(descLb, 1)
    
    --抽奖规则
    local function showInfoStr()
        local tabStr = {}
        for k = 1, 4 do
            table.insert(tabStr, getlocal("znkh19_lottery_rule"..k))
        end
        local titleStr = getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, titleStr, tabStr, nil, 25)
    end
    G_createBotton(self.lotteryBg, ccp(G_VisibleSizeWidth - 40, self.lotteryBg:getContentSize().height - 24), {}, "i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon2.png", showInfoStr, 0.7, -(self.layerNum - 1) * 20 - 3)
end

function acZnkh19LotteryTab:initLotteryBtns()
    local btnPosY = 80
    if G_isIOS() == false then
        btnPosY = 60
    end
    --单次购买
    local function oneLotteryHandler()
        self:lotteryHandler(1)
    end
    
    --多次购买
    local function multiLotteryHandler()
        self:lotteryHandler(5)
    end
    
    self.freeBtn = self:createLotteryBtn(0, ccp(G_VisibleSizeWidth / 2 - 150, btnPosY), oneLotteryHandler)
    self.oLotteryBtn = self:createLotteryBtn(1, ccp(G_VisibleSizeWidth / 2 - 150, btnPosY), oneLotteryHandler)
    self.mLotteryBtn = self:createLotteryBtn(2, ccp(G_VisibleSizeWidth / 2 + 150, btnPosY), multiLotteryHandler)
    
    self:refreshLotteryBtn()
end

function acZnkh19LotteryTab:createLotteryBtn(btype, pos, callback)
    local btnStr
    local btnPic, selectPic, disablePic
    local btnScale, priority = 0.7, -(self.layerNum - 1) * 20 - 5
    local oCost, mCost = acZnkh19VoApi:getLotteryCost()
    local cost = 0
    if btype == 0 then
        btnStr = getlocal("daily_lotto_tip_2")
        btnPic, selectPic, disablePic = "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png"
    else
        if btype == 1 then
            btnStr = getlocal("activity_qxtw_buy", {1})
            cost = oCost
        else
            btnStr = getlocal("activity_qxtw_buy", {5})
            cost = mCost
        end
        btnPic, selectPic, disablePic = "creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png"
    end
    local btn = G_createBotton(self.bgLayer, pos, {btnStr}, btnPic, selectPic, disablePic, callback, btnScale, priority)
    if btype ~= 0 then
        local costLb = GetTTFLabel(tostring(cost), 22)
        costLb:setAnchorPoint(ccp(0, 0.5))
        -- costLb:setColor(G_ColorYellowPro)
        costLb:setScale(1 / btnScale)
        btn:addChild(costLb)
        local costSp = CCSprite:createWithSpriteFrameName("IconGold.png")
        costSp:setAnchorPoint(ccp(0, 0.5))
        costSp:setScale(1 / btnScale)
        btn:addChild(costSp)
        local lbWidth = costLb:getContentSize().width * costLb:getScale() + costSp:getContentSize().width * costSp:getScale() + 10
        costLb:setPosition(ccp(btn:getContentSize().width / 2 - lbWidth / 2, btn:getContentSize().height + 20))
        costSp:setPosition(ccp(costLb:getPositionX() + costLb:getContentSize().width * costLb:getScale() + 10, costLb:getPositionY()))
    end
    
    return btn
end

function acZnkh19LotteryTab:lotteryHandler(num)
    local oCost, mCost = acZnkh19VoApi:getLotteryCost()
    local free = acZnkh19VoApi:isFreeLottery()
    local cost = 0
    if num == 5 then
        if free == 1 then --有免费次数未使用
            G_showTipsDialog(getlocal("backstage2036"))
            do return end
        end
        free, cost = 0, mCost
    else
        if free == 0 then
            cost = oCost
        end
    end
    local gems = playerVoApi:getGems()
    if gems < cost then
        GemsNotEnoughDialog(nil, nil, cost - gems, self.layerNum + 1, cost)
        do return end
    end
    local function realLottery()
        local function lotteryFinishHandler(rewardList)
            self.freeFlag = acZnkh19VoApi:isFreeLottery()
            local function refreshLottery()
                self:showReward(rewardList)
                self:refreshLotteryBtn()
            end
            self:playLotteryAnim(num, G_clone(rewardList), refreshLottery)
        end
        acZnkh19VoApi:znkhLottery(free, num, cost, lotteryFinishHandler)
    end
    if free == 1 then --免费的直接抽
        realLottery()
    else --非免费的增加二次确认
        G_dailyConfirm("znkh19.lottery", getlocal("second_tip_des", {cost}), realLottery, self.layerNum + 1)
    end
end

function acZnkh19LotteryTab:showReward(rewardList, wordStr)
    local titleStr = getlocal("activity_wheelFortune4_reward")
    local function showTip()
        G_showRewardTip(rewardList, true)
    end
    require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
    rewardShowSmallDialog:showNewReward(self.layerNum + 1, true, true, rewardList, showTip, titleStr)
end

function acZnkh19LotteryTab:refreshLotteryBtn()
    if self.freeBtn and self.oLotteryBtn and self.mLotteryBtn then
        local free = acZnkh19VoApi:isFreeLottery()
        if free == 1 then
            self.oLotteryBtn:setVisible(false)
            self.oLotteryBtn:setEnabled(false)
            self.freeBtn:setVisible(true)
            self.freeBtn:setEnabled(true)
        else
            self.oLotteryBtn:setVisible(true)
            self.oLotteryBtn:setEnabled(true)
            self.freeBtn:setVisible(false)
            self.freeBtn:setEnabled(false)
        end
        local flag = acZnkh19VoApi:isRewardTime()
        if flag == true then
            self.oLotteryBtn:setEnabled(false)
            self.freeBtn:setEnabled(false)
            self.mLotteryBtn:setEnabled(false)
        end
    end
end

function acZnkh19LotteryTab:playCustomDisplayAnim()
    if self.lightSpTb == nil then
        do return end
    end
    local rwidth = 80
    local mt, ms = 1, 10
    for k, v in pairs(self.iconTb) do
        local ballSp, icon = tolua.cast(self.ballSpTb[k], "CCSprite"), tolua.cast(v, "CCSprite")
        if ballSp and icon then
            --播放闪光动画
            local lightSp = CCSprite:createWithSpriteFrameName("zn19_rlight1.png")
            lightSp:setPosition(self.rpos[k].x, self.rpos[k].y - 40)
            lightSp:setOpacity(0)
            self.lotteryBg:addChild(lightSp, self.rzorder[k])
            G_playFrame(lightSp, {frmn = 10, frname = "zn19_rlight", perdelay = 0.15, forever = {0, 0}, blendType = 1})
            local arr = CCArray:create()
            arr:addObject(CCDelayTime:create((k - 1) * 2.2))
            arr:addObject(CCFadeIn:create(0.4))
            arr:addObject(CCDelayTime:create(1))
            arr:addObject(CCFadeOut:create(0.8))
            arr:addObject(CCDelayTime:create((7 - k) * 2.2))
            local seq = CCSequence:create(arr)
            lightSp:runAction(CCRepeatForever:create(seq))
            self.lightSpTb[k] = lightSp
            
            ballSp:setOpacity(255)
            icon:setVisible(true)
            icon:setOpacity(255)
            icon:setScale(rwidth / icon:getContentSize().width)
            
            ballSp:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCMoveBy:create(mt, ccp(0, ms)), CCMoveBy:create(mt, ccp(0, -ms)))))
            icon:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCMoveBy:create(mt, ccp(0, ms)), CCMoveBy:create(mt, ccp(0, -ms)))))
        end
    end
    for k, v in pairs(self.animLightSpTb) do
        v = tolua.cast(v, "CCSprite")
        if v then
            v:removeFromParentAndCleanup(true)
            v = nil
        end
    end
    self.animLightSpTb = {}
    for k, v in pairs(self.animLightNodeTb) do
        v = tolua.cast(v, "CCNode")
        if v then
            v:stopAllActions()
            v:removeFromParentAndCleanup(true)
            v = nil
        end
    end
    self.animLightNodeTb = {}
end

function acZnkh19LotteryTab:stopCustomDisplayAnim()
    if self.lightSpTb == nil then
        do return end
    end
    for k, v in pairs(self.iconTb) do
        local ballSp, icon, lightSp = tolua.cast(self.ballSpTb[k], "CCSprite"), tolua.cast(v, "CCSprite"), tolua.cast(self.lightSpTb[k], "CCSprite")
        if ballSp and icon and lightSp then
            lightSp:stopAllActions()
            lightSp:removeFromParentAndCleanup(true)
            lightSp = nil
            ballSp:stopAllActions()
            icon:stopAllActions()
            ballSp:setPosition(self.rpos[k])
            icon:setPosition(self.rpos[k])
        end
    end
    self.lightSpTb = {}
end

--播放抽奖动画
function acZnkh19LotteryTab:playLotteryAnim(lotteryNum, rewardList, animEnd)
    if self.lotteryAnimLayer then
        do return end
    end
    
    self.animFlag = true --抽奖动画标识
    
    self:stopCustomDisplayAnim() --播放抽奖动画前先不显示正常轮播的动画
    
    local function touchLayer() --点击可跳过动画
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        self:removeLotteryAnim() --移除动画层
        self:playCustomDisplayAnim()
        if self.animFlag == true then
            if animEnd then
                animEnd()
            end
        end
    end
    local lotteryAnimLayer = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(3, 3, 4, 4), touchLayer)
    lotteryAnimLayer:setAnchorPoint(ccp(0.5, 0))
    lotteryAnimLayer:setOpacity(0)
    lotteryAnimLayer:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    lotteryAnimLayer:setPosition(G_VisibleSizeWidth / 2, 0)
    lotteryAnimLayer:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
    self.bgLayer:addChild(lotteryAnimLayer, 5)
    self.lotteryAnimLayer = lotteryAnimLayer
    
    local rshowBg = CCNode:create()
    rshowBg:setAnchorPoint(ccp(0.5, 1))
    rshowBg:setContentSize(CCSizeMake(self.lotteryBg:getContentSize().width, self.lotteryBg:getContentSize().height))
    rshowBg:setPosition(self.lotteryBg:getPosition())
    self.lotteryAnimLayer:addChild(rshowBg)
    
    local rtb = {1, 2, 3, 4, 5, 6, 7} --奖励位置列表
    local a_postb = {}
    for k = 1, 7 do
        local n = math.random(1, #rtb)
        table.insert(a_postb, rtb[n])
        table.remove(rtb, n)
    end
    
    local r_postb = {} --得奖的位置列表
    
    local rwd = {}
    table.remove(rewardList, 1) --移除掉和谐奖励
    for k, v in pairs(rewardList) do
        if v.type == "ac" and v.eType == "o" then
            if r_postb[1] == nil then
                r_postb[1] = {}
            end
            table.insert(r_postb[1], v)
        else
            local ridKey = self:getridxKey(v)
            local idx = self.ridx[ridKey]
            if rwd[idx] == nil then
                rwd[idx] = {v, 1}
            else
                rwd[idx][2] = rwd[idx][2] + 1
            end
        end
    end
    for k, v in pairs(rwd) do
        local ridKey = self:getridxKey(v[1])
        local idx = self.ridx[ridKey]
        if r_postb[idx] == nil then
            r_postb[idx] = {}
        end
        v[1].num = v[1].num * v[2]
        table.insert(r_postb[idx], v[1])
    end
    local ft1, ft2, fdelay = 0.14, 0.45, 1
    
    --播放奖励展示动画
    local function playRewardDisplayAnim(bpos)
        local iconSp = tolua.cast(self.iconTb[bpos], "CCSprite")
        iconSp:setVisible(false)
        local rs = iconSp:getScale()
        local ix, iy = iconSp:getPosition()
        
        local rnode = CCNode:create()
        rnode:setAnchorPoint(ccp(0.5, 0.5))
        rnode:setPosition(iconSp:getPosition())
        rnode:setContentSize(CCSizeMake(iconSp:getContentSize().width, iconSp:getContentSize().height))
        rshowBg:addChild(rnode, 2)
        
        --播放爆炸动画
        local boomSp = CCSprite:createWithSpriteFrameName("zn19_boom1.png")
        boomSp:setPosition(iconSp:getPosition())
        rshowBg:addChild(boomSp, 4)
        G_playFrame(boomSp, {frmn = 17, frname = "zn19_boom", perdelay = 0.05, forever = {-1, 0}, blendType = 1})
        
        self.lotteryAnimLayer:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.05), CCCallFunc:create(function ()
            local ballSp = tolua.cast(self.ballSpTb[bpos], "CCSprite")
            ballSp:setOpacity(0) --隐藏光球
            
            --再次播放光柱动画
            local lightSp = CCSprite:createWithSpriteFrameName("zn19_rlight1.png")
            lightSp:setPosition(self.rpos[bpos].x, self.rpos[bpos].y - 40)
            self.lotteryBg:addChild(lightSp, self.rzorder[bpos])
            G_playFrame(lightSp, {frmn = 10, frname = "zn19_rlight", perdelay = 0.15, forever = {0, 0}, blendType = 1})
            self.animLightSpTb[bpos] = lightSp
            
            local iconLightSp1 = CCSprite:createWithSpriteFrameName("zn19_iconlight1.png") --高亮1
            local iconLightSp2 = CCSprite:createWithSpriteFrameName("zn19_iconlight2.png") --高亮2
            iconLightSp1:setPosition(getCenterPoint(rnode))
            iconLightSp2:setPosition(getCenterPoint(rnode))
            rnode:addChild(iconLightSp1, 6)
            rnode:addChild(iconLightSp2, 5)
            G_setBlendFunc(iconLightSp1, GL_ONE, GL_ONE)
            G_setBlendFunc(iconLightSp2, GL_ONE, GL_ONE)
            
            iconLightSp1:runAction(CCFadeOut:create(0.33))
            iconLightSp2:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.33), CCFadeOut:create(0.33)))
            
            --外发光
            local outLightSp = CCSprite:createWithSpriteFrameName("zn19_iconoutlight.png")
            outLightSp:setPosition(getCenterPoint(rnode))
            rnode:addChild(outLightSp, 2)
            G_setBlendFunc(outLightSp, GL_ONE, GL_ONE)
            
            --背横光
            local backLightSp = CCSprite:createWithSpriteFrameName("zn19_rbacklight.png")
            backLightSp:setPosition(getCenterPoint(rnode))
            rnode:addChild(backLightSp, 1)
            local seq = CCSequence:createWithTwoActions(CCScaleTo:create(1.7 / 2, 1.2), CCScaleTo:create(1.7 / 2, 1))
            backLightSp:runAction(CCRepeatForever:create(seq))
            G_setBlendFunc(backLightSp, GL_ONE, GL_ONE)
            
            local function flipReward()
                for k, v in pairs(r_postb[bpos]) do
                    local rewardIconSp = G_getItemIcon(v)
                    rewardIconSp:setPosition(getCenterPoint(rnode))
                    rewardIconSp:setVisible(false)
                    rewardIconSp:setScale(rs)
                    rnode:addChild(rewardIconSp, k + 5)
                    local numLb = GetTTFLabel(FormatNumber(v.num), 18)
                    numLb:setAnchorPoint(ccp(1, 0))
                    numLb:setScale(1 / rewardIconSp:getScale())
                    numLb:setPosition(ccp(rewardIconSp:getContentSize().width - 5, 2))
                    rewardIconSp:addChild(numLb, 4)
                    local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function ()end)
                    numBg:setAnchorPoint(ccp(1, 0))
                    numBg:setContentSize(CCSizeMake(numLb:getContentSize().width * numLb:getScale() + 5, numLb:getContentSize().height * numLb:getScale() - 5))
                    numBg:setPosition(ccp(rewardIconSp:getContentSize().width - 5, numLb:getPositionY()))
                    numBg:setOpacity(150)
                    rewardIconSp:addChild(numBg, 3)
                    
                    local arr = CCArray:create()
                    arr:addObject(CCDelayTime:create((k - 1) * fdelay))
                    arr:addObject(CCCallFunc:create(function ()
                        rewardIconSp:setVisible(true)
                    end))
                    arr:addObject(CCScaleTo:create(ft1, -0.1, 1))
                    arr:addObject(CCScaleTo:create(ft2, 1, 1))
                    rnode:runAction(CCSequence:create(arr))
                end
            end
            rnode:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.2), CCCallFunc:create(function ()
                flipReward()
            end)))
            
            for k = 1, 2 do
                --放射光
                local laserSp = CCSprite:createWithSpriteFrameName("zn19_iconbacklight.png")
                laserSp:setPosition(ix, iy)
                rshowBg:addChild(laserSp)
                G_setBlendFunc(laserSp, GL_ONE, GL_ONE)
                if k == 1 then
                    laserSp:runAction(CCRepeatForever:create(CCRotateBy:create(18, 360)))
                else
                    laserSp:runAction(CCRepeatForever:create(CCRotateBy:create(18, -360)))
                    laserSp:setScale(0.8)
                end
            end
        end))) --爆炸序列第二帧时执行道具翻转一系列的动作
    end
    
    --播放抽奖过程
    local an = #a_postb
    for k, rpos in pairs(a_postb) do
        local function playPosAnim()
            local ballSp = tolua.cast(self.ballSpTb[rpos], "CCSprite")
            ballSp:runAction(CCFadeTo:create(0.3, 0.4 * 255))
            
            --球光晕动画
            local haloSp = CCSprite:createWithSpriteFrameName("zn19_balllight.png")
            haloSp:setPosition(ballSp:getPosition())
            haloSp:setOpacity(0)
            rshowBg:addChild(haloSp)
            G_setBlendFunc(haloSp, GL_ONE, GL_ONE)
            haloSp:runAction(CCSequence:createWithTwoActions(CCFadeIn:create(0.05), CCFadeOut:create(0.5)))
            
            --光柱动画
            local lightSp1 = CCSprite:createWithSpriteFrameName("zn19_rlight1.png")
            local lightSp2 = CCSprite:createWithSpriteFrameName("zn19_rlight1.png")
            
            local lightNode = CCNode:create()
            lightNode:setAnchorPoint(ccp(0.5, 0.5))
            lightNode:setContentSize(CCSizeMake(lightSp1:getContentSize().width, lightSp1:getContentSize().height))
            lightNode:setPosition(ballSp:getPositionX(), ballSp:getPositionY() - 40)
            self.lotteryBg:addChild(lightNode, self.rzorder[k])
            table.insert(self.animLightNodeTb, lightNode)
            
            lightSp1:setPosition(getCenterPoint(lightNode))
            lightNode:addChild(lightSp1)
            lightSp2:setPosition(getCenterPoint(lightNode))
            lightNode:addChild(lightSp2)
            --因光柱亮度不够，在这里播放两次序列帧
            G_playFrame(lightSp1, {frmn = 10, frname = "zn19_rlight", perdelay = 0.15, forever = {0, 0}, blendType = 1})
            G_playFrame(lightSp2, {frmn = 10, frname = "zn19_rlight", perdelay = 0.15, forever = {0, 0}, blendType = 1})
            
            local function playEnd()
                lightNode:stopAllActions()
                lightNode:removeFromParentAndCleanup(true)
                lightNode = nil
                self.animLightNodeTb[k] = nil
                if k == an then
                    local mn = 0
                    for rk, rv in pairs(r_postb) do
                        playRewardDisplayAnim(rk)
                        
                        local cnum = SizeOfTable(rv)
                        if cnum > mn then
                            mn = cnum
                        end
                    end
                    local dt = ft1 + ft2 + (mn - 1) * fdelay + 1
                    self.lotteryAnimLayer:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(dt), CCCallFunc:create(function ()
                        self.animFlag = false
                        self:removeLotteryAnim() --移除动画层
                        self:playCustomDisplayAnim()
                        if animEnd then
                            animEnd()
                        end
                    end)))
                end
            end
            lightSp1:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.1), CCFadeOut:create(0.25))) --透明度100% 持续0.1秒，0.25秒后淡入
            lightSp2:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.1), CCFadeOut:create(0.25))) --透明度100% 持续0.1秒，0.25秒后淡入
            lightNode:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.35), CCCallFunc:create(playEnd)))
        end
        self.lotteryAnimLayer:runAction(CCSequence:createWithTwoActions(CCDelayTime:create((k - 1) * 0.13), CCCallFunc:create(playPosAnim)))
    end
end

--移除抽奖动画
function acZnkh19LotteryTab:removeLotteryAnim()
    if self.lotteryAnimLayer then
        self.lotteryAnimLayer:stopAllActions()
        self.lotteryAnimLayer:removeFromParentAndCleanup(true)
        self.lotteryAnimLayer = nil
    end
end

function acZnkh19LotteryTab:getridxKey(reward)
    return reward.type .. "_" .. reward.key .. "_" .. reward.num
end

function acZnkh19LotteryTab:tick()
    if acZnkh19VoApi:isEnd() == true then
        do return end
    end
    local free = acZnkh19VoApi:isFreeLottery()
    if self.freeFlag ~= free and free == 1 then --刷新免费抽奖
        self:refreshLotteryBtn()
        self.freeFlag = free
    end
    local flag = acZnkh19VoApi:isRewardTime()
    if self.rewardTimeFlag == false and flag == true then
        self:refreshLotteryBtn()
    end
end

function acZnkh19LotteryTab:updateUI()
    
end

function acZnkh19LotteryTab:dispose()
    self:removeLotteryAnim()
    spriteController:removePlist("public/acZnkh2019_anim1.plist")
    spriteController:removeTexture("public/acZnkh2019_anim1.png")
    spriteController:removePlist("public/acZnkh2019_anim2.plist")
    spriteController:removeTexture("public/acZnkh2019_anim2.png")
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer = nil
    end
    self.animLightNodeTb = nil
    self.animLightSpTb = nil
    self.rpool = nil
    self.lotteryAnimLayer = nil
    self.lotteryBg = nil
    self.lightSpTb = nil
    self.ridx = nil
    self.rzorder = nil
    self = nil
end
