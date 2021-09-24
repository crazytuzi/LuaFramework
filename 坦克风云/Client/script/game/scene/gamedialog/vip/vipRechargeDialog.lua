--require "luascript/script/componet/commonDialog"
--vipRechargeDialog=commonDialog:new()
vipRechargeDialog = smallDialog:new()

function vipRechargeDialog:new(isShowMCard)
    local nc = smallDialog:new()
    setmetatable(nc, self)
    self.__index = self
    nc.isShowMCard = isShowMCard
    nc.panelLineBg = nil
    nc.closeBtn = nil
    nc.vipRechargeLabel = nil
    nc.firstRechargeLabel = nil
    nc.tv = nil
    nc.layerNum = nil
    nc.gems = 0
    
    nc.selectIndex = 2
    nc.vipExp = -1
    nc.vipDescLabel = nil
    nc.gotoVipBtn = nil
    nc.rechargeBtn = nil
    nc.isFirstRecharge = false
    nc.topforbidSp = nil --顶端遮挡层
    nc.bottomforbidSp = nil --底部遮挡层
    nc.vipLevel = nil
    nc.heightSpace = 240
    nc.rewardMonthlyBtn = nil
    nc.leftDays = nil
    nc.goldIcon = nil
    nc.iconPicTb = nil
    nc.indexSort = nil
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/iconGoldImage.plist")
    spriteController:addPlist("public/acNewYearsEva.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acItemBg.plist")
    nc.moneyName = GetMoneyName()
    
    return nc
end

function vipRechargeDialog:init(bgSrc, isfullScreen, size, fullRect, inRect, tabTb, subTabTb, closeBtnSrc, title, needRefresh, layerNum)
    --[[
            local function connectHandler(...)
              print("登录成功！！1！！！！")
              local function  callback()
              
              
              end
              socketHelper2:sendRequest("{}",callback,"user.cb",false)
              --socketHelper2:disConnect()
              --base:cancleWait()
              --base:cancleNetWait()
        end
        socketHelper2:socketConnect("192.168.8.204",3008,connectHandler)
    ]]
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    if G_checkUseAuditUI() == true then --审核版本部分图替换
        spriteController:addPlist("public/vr_rechargeImagesAudit.plist")
        spriteController:addTexture("public/vr_rechargeImagesAudit.png")
    end
    spriteController:addPlist("public/vr_rechargeImages.plist")
    spriteController:addTexture("public/vr_rechargeImages.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
    isfullScreen = true
    if isfullScreen then
        size = CCSizeMake(640, G_VisibleSize.height)
    else
        size = CCSizeMake(600 + 30, 900)
    end
    
    --德国movga支付分语言特殊处理，调用底层获取语言
    if((G_curPlatName() == "11" and G_Version >= 11) or (G_curPlatName() == "androidsevenga" and G_Version >= 16))then
        local tmpTb = {}
        tmpTb["action"] = "customAction"
        tmpTb["parms"] = {}
        tmpTb["parms"]["value"] = "getCurrency"
        local cjson = G_Json.encode(tmpTb)
        self.moneyName = G_accessCPlusFunction(cjson)
        if(self.moneyName ~= "EUR" and self.moneyName ~= "CHF")then
            self.moneyName = "EUR"
        end
    else
        self.moneyName = GetMoneyName()
    end
    
    self.indexSort = playerCfg.recharge.indexSort
    local storeCfg = G_getPlatStoreCfg()
    if(storeCfg.indexSort)then
        self.indexSort = storeCfg.indexSort
    end
    if platCfg.platCfgStoreCfg3[G_curPlatName()] then --充值档位特殊化配置
        local storeCfg = platCfg.platCfgStoreCfg3[G_curPlatName()]["ramadan"]
        if storeCfg then
            activityVoApi:requireByType("ramadan")
            if acRamadanVoApi and acRamadanVoApi:isUseNewStoreCfg() == true then --阿拉伯斋月活动处理
                if G_curPlatName() == "21" then
                    self.indexSort = {"6", "5", "7", "4", "3", "2", "1"}
                    self.iconPicTb = {"iconGoldNew6.png", "iconGoldNew5.png", "iconGoldNew7.png", "iconGoldNew4.png", "iconGoldNew3.png", "iconGoldNew2.png", "iconGoldNew1.png"}
                else
                    self.indexSort = {"8", "6", "5", "7", "4", "3", "2", "1"}
                    self.iconPicTb = {"iconGoldNew8.png", "iconGoldNew6.png", "iconGoldNew5.png", "iconGoldNew7.png", "iconGoldNew4.png", "iconGoldNew3.png", "iconGoldNew2.png", "iconGoldNew1.png"}
                end
            end
        end
    end
    --飞流app新包有11档充值，需要特殊处理
    if(G_curPlatName() == "51" or G_curPlatName() == "0")then
        self.iconPicTb = {"iconGoldNew8.png", "iconGoldNew6.png", "iconGoldNew5.png", "iconGoldNew5.png", "iconGoldNew7.png", "iconGoldNew4.png", "iconGoldNew3.png", "iconGoldNew2.png", "iconGoldNew1.png", "iconGoldNew1.png", "iconGoldNew1.png"}
    end
    
    self.isTouch = false
    self.isUseAmi = true
    if layerNum then
        self.layerNum = layerNum
    else
        self.layerNum = 4
    end
    local rect = size
    local function touchHander()
        
    end
    
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc, inRect, touchHander)
    self.dialogLayer = CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer = dialogBg
    self.bgSize = size
    self.bgLayer:setContentSize(size)
    self:show()
    
    self.cellWidth, self.cellHeight = self.bgLayer:getContentSize().width - 10, 136
    
    local function touchDialog()
        
    end
    
    self.dialogLayer:addChild(self.bgLayer, 1);
    self.dialogLayer:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    
    -- self.panelLineBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png", inRect, touchHander)
    -- self.bgLayer:addChild(self.panelLineBg)
    -- if isfullScreen then
    --     self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width / 2, self.bgLayer:getContentSize().height / 2 - 35))
    --     self.panelLineBg:setContentSize(CCSizeMake(620, G_VisibleSize.height - 100))
    -- else
    --     self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width / 2, self.bgLayer:getContentSize().height / 2 - 35))
    --     self.panelLineBg:setContentSize(CCSizeMake(610, 800))
    -- end
    -- self.panelLineBg:setVisible(false)
    
    self.panelShadeBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png", CCRect(30, 2, 2, 10), function ()end)
    self.panelShadeBg:setAnchorPoint(ccp(0.5, 1))
    self.panelShadeBg:setContentSize(size)
    self.panelShadeBg:setPosition(size.width / 2, size.height - 82)
    self.bgLayer:addChild(self.panelShadeBg)
    
    local function close()
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png", "closeBtn_Down.png", "closeBtn_Down.png", close, nil, nil, nil);
    closeBtnItem:setPosition(0, 0)
    closeBtnItem:setAnchorPoint(CCPointMake(0, 0))
    
    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.closeBtn:setPosition(ccp(rect.width - closeBtnItem:getContentSize().width, rect.height - closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn)
    
    local titleLb = GetTTFLabel(title, 32, true)
    titleLb:setAnchorPoint(ccp(0.5, 0.5))
    titleLb:setPosition(ccp(size.width / 2, size.height - 41))
    dialogBg:addChild(titleLb)
    
    -- local buygems=playerVoApi:getBuygems()
    -- if buygems==0 then
    -- self.isFirstRecharge=true
    -- elseif buygems>0 then
    -- self.isFirstRecharge=false
    -- end
    
    local hotSellCfg = playerCfg.recharge.hotSell
    self.selectIndex = tonumber(hotSellCfg[1])
    
    self.vipLevel = playerVoApi:getVipLevel()
    self.leftDays = vipVoApi:getMonthlyCardLeftDays()
    self:initTableView()
    self:doUserHandler()
    
    --以下代码处理上下遮挡层
    local function forbidClick()
        
    end
    local capInSet1 = CCRect(20, 20, 10, 10);
    self.topforbidSp = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", capInSet1, forbidClick)
    self.topforbidSp:setTouchPriority(-(layerNum - 1) * 20 - 3)
    self.topforbidSp:setAnchorPoint(ccp(0, 0))
    self.bottomforbidSp = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", capInSet1, forbidClick)
    self.bottomforbidSp:setTouchPriority(-(layerNum - 1) * 20 - 3)
    self.bottomforbidSp:setAnchorPoint(ccp(0, 0))
    local tvX, tvY = self.tv:getPosition()
    local topY = tvY + self.tv:getViewSize().height
    local topHeight = self.bgSize.height - topY
    self.topforbidSp:setContentSize(CCSize(rect.width, topHeight))
    self.topforbidSp:setPosition(0, topY)
    self.bgLayer:addChild(self.topforbidSp)
    
    self.bgLayer:addChild(self.bottomforbidSp)
    self:resetForbidLayer()
    self.topforbidSp:setVisible(false)
    self.bottomforbidSp:setVisible(false)
    --以上代码处理上下遮挡层
    
    --以下添加移动的图片
    --    self.list={}
    --    local bgWidth,bgHeight=612,218
    --    for i=1,5 do
    --        local adBg=CCSprite:create("public/superWeapon/weaponBg.jpg")
    -- adBg:setScaleX(bgWidth/adBg:getContentSize().width)
    -- adBg:setScaleY(bgHeight/adBg:getContentSize().height)
    -- -- adBg:setContentSize(CCSize(612,218))
    -- -- adBg:setAnchorPoint(ccp(0.5,1))
    -- adBg:setPosition(ccp(rect.width/2,rect.height-90-bgHeight/2))
    -- self.bgLayer:addChild(adBg,1)
    --        self.list[i]=adBg
    --    end
    -- self.tankLayer=pageDialog:new()
    --    local page=1
    --    local isShowBg=false
    --    local isShowPageBtn=false
    --    local function onPage(topage)
    
    --    end
    --    local tankHeight=256
    --    local posY=G_VisibleSizeHeight - 250 - tankHeight/2
    --    local leftBtnPos=nil--ccp(40,posY)
    --    local rightBtnPos=nil--ccp(self.bgLayer:getContentSize().width-40,posY)
    --    local adBg1=self.list[1]
    --    local touchRect={x=adBg1:getPositionX(),y=adBg1:getPositionY(),width=bgWidth,height=bgHeight}
    --    self.tankLayer:create("panelItemBg.png",CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight),CCRect(20, 20, 10, 10),self.bgLayer,ccp(0,0),self.layerNum,page,self.list,isShowBg,isShowPageBtn,onPage,leftBtnPos,rightBtnPos,nil,-(self.layerNum-1)*20-4,touchRect)
    
    --    local maskSpHeight=self.bgLayer:getContentSize().height-133
    --    for k=1,5 do
    --        local leftMaskSp=CCSprite:createWithSpriteFrameName("maskBgLeftUse.png")
    --        leftMaskSp:setAnchorPoint(ccp(0,0))
    --        -- leftMaskSp:setPosition(0,pos.y+25)
    --        leftMaskSp:setPosition(0,45)
    --        leftMaskSp:setScaleY(maskSpHeight/leftMaskSp:getContentSize().height)
    --        leftMaskSp:setScaleX(11/leftMaskSp:getContentSize().width)
    --        self.bgLayer:addChild(leftMaskSp,6)
    
    --        local rightMaskSp=CCSprite:createWithSpriteFrameName("maskBgLeftUse.png")
    --        -- rightMaskSp:setRotation(180)
    --        rightMaskSp:setFlipX(true)
    --        rightMaskSp:setAnchorPoint(ccp(1,0))
    --        -- rightMaskSp:setPosition(self.bgLayer:getContentSize().width-rightMaskSp:getContentSize().width,pos.y+25)
    --        rightMaskSp:setPosition(self.bgLayer:getContentSize().width,45)
    --        rightMaskSp:setScaleY(maskSpHeight/rightMaskSp:getContentSize().height)
    --        rightMaskSp:setScaleX(11/rightMaskSp:getContentSize().width)
    --        self.bgLayer:addChild(rightMaskSp,6)
    --    end
    
    self:initAdBg()
    
    local function touchLuaSpr()
        
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc, inRect, touchLuaSpr);
    touchDialogBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    local rect = CCSizeMake(640, G_VisibleSize.height)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(0)
    touchDialogBg:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(touchDialogBg, 1);
    
    base:addNeedRefresh(self)
    self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    
    if G_curPlatName() == "androidlongzhong" or G_curPlatName() == "efunandroid360" or G_curPlatName() == "androidom2" or G_curPlatName() == "androidlongzhong2" then
        
        do
            return nil
        end
    end
    
    if G_getPlatAppID() == 10315 or G_getPlatAppID() == 10215 or G_getPlatAppID() == 10615 or G_getPlatAppID() == 11815 or G_getPlatAppID() == 1028 then
        local url = "http://tank-android-01.raysns.com/tankheroclient/clickpage.php?uid=" .. (playerVoApi:getUid() == nil and 0 or playerVoApi:getUid()) .. "&appid="..G_getPlatAppID() .. "&tm="..base.serverTime.."&tp=page"
        HttpRequestHelper:sendAsynHttpRequest(url, "")
        print("发送了*****", url)
        
    end
    
    local function onPayment(event, data)
        self:onPaymentCallback(event, data)
    end
    self.paymentListener = onPayment
    eventDispatcher:addEventListener("user.pay", onPayment)
    
    if G_isApplyVersion() == true then
        G_setShaderProgramAllChildren(self.dialogLayer, function(ccNode)
            CCShader:setShaderProgram(ccNode, "kShader_ApplyVersion")
        end)
    end
    G_statisticsAuditRecord(AuditOp.RECHARGEUI) --记录进入充值页面
    return self.dialogLayer
end

function vipRechargeDialog:onPaymentCallback(event, data)
    if self and self.bgLayer then
        self:refreshUI()
    end
    local cardCfg = vipVoApi:getMonthlyCardCfg()
    if(cardCfg == nil)then
        do return end
    end
    if(data and data.num and data.num == cardCfg.goldFirst)then
        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("vip_monthlyCard_buySuccess", {vipVoApi:getMonthlyCardLeftDays(), cardCfg.goldContinue, cardCfg.goldFirst}), nil, 20)
    end
end

function vipRechargeDialog:refreshUI()
    if self and self.tv then
        -- print("~~~~~~~~~~~~~~~~")
        self:initAdBg()
        local recordPoint = self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
    if G_isApplyVersion() == true then
        G_setShaderProgramAllChildren(self.dialogLayer, function(ccNode)
            CCShader:setShaderProgram(ccNode, "kShader_ApplyVersion")
        end)
    end
end

--顶部和底部的遮挡层
function vipRechargeDialog:resetForbidLayer()
    local tvX, tvY = self.tv:getPosition()
    self.bottomforbidSp:setContentSize(CCSizeMake(self.bgSize.width, tvY))
end

--设置对话框里的tableView
function vipRechargeDialog:initTableView()
    self.adHeight, self.vrInfoBgHeight = 262, 80 --广告图的高度
    if G_isIOS() ~= true and G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() == "de" then
        self.vrInfoBgHeight = 100
    end
    
    local function callBack(...)
        return self:eventHandler(...)
    end
    local tvHight = G_VisibleSizeHeight - self.adHeight - self.vrInfoBgHeight - 82 - 90 - 25
    if G_curPlatName() == "androiduc" or G_curPlatName() == "androidmuzhiwan" then
        tvHight = tvHight - 50
        local goldChargeLabel = GetTTFLabel(getlocal("chargeToGold", {1, 8}), 40)
        goldChargeLabel:setPosition(ccp(self.bgLayer:getContentSize().width / 2, 120))
        self.bgLayer:addChild(goldChargeLabel, 1)
    elseif G_curPlatName() == "5" or G_curPlatName() == "45" or G_curPlatName() == "58" then
        tvHight = tvHight - 50
        local goldChargeLabel = GetTTFLabel("ID："..playerVoApi:getUid(), 40)
        goldChargeLabel:setPosition(ccp(self.bgLayer:getContentSize().width / 2, 120))
        self.bgLayer:addChild(goldChargeLabel, 1)
        -- else
        -- tvHight = self.bgLayer:getContentSize().height - 290
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.cellWidth, tvHight), nil)
    self.bgLayer:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    -- self.tv:setAnchorPoint(ccp(0.5,1))
    self.tv:setPosition(ccp((G_VisibleSizeWidth - self.cellWidth) / 2, 100))
    
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(110)
end

function vipRechargeDialog:initFirstRecharge()
    local firstRechargeBg = CCSprite:createWithSpriteFrameName("ActivityBg.png")
    
    local titleLable = GetTTFLabel(getlocal("firstRechargeReward"), 28)
    titleLable:setPosition(ccp(firstRechargeBg:getContentSize().width / 2, firstRechargeBg:getContentSize().height - 20))
    firstRechargeBg:addChild(titleLable, 1)
    local firstGift = playerCfg.recharge.firstChargeGift
    local giftData = FormatItem(firstGift, true, true)
    local tempHeight = 0
    for k, v in pairs(giftData) do
        if v and v.name then
            local awidth = k * (130 + 15) - 37 - 27
            local aheight = 0
            if G_getCurChoseLanguage() == "cn" or G_getCurChoseLanguage() == "tw" then
                aheight = 35
            else
                aheight = 65
            end
            local function showInfoHandler()
                if G_checkClickEnable() == false then
                    do
                        return
                    end
                else
                    base.setWaitTime = G_getCurDeviceMillTime()
                end
                if v and v.name and v.pic and v.num and v.desc then
                    if v.key == "gems" or v.key == "gem" then
                    else
                        propInfoDialog:create(sceneGame, v, self.layerNum + 1)
                    end
                end
            end
            local icon = G_getItemIcon(v, 80, true, self.layerNum + 1)
            icon:setAnchorPoint(ccp(0.5, 0))
            icon:setPosition(ccp(awidth, aheight + 40))
            firstRechargeBg:addChild(icon, 1)
            if icon:getContentSize().width > 100 then
                icon:setScaleX(100 / 150)
                icon:setScaleY(100 / 150)
            end
            icon:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
            
            local nameLable = GetTTFLabelWrap(v.name.." x"..v.num, 25, CCSizeMake(150, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
            if k == 1 then
                nameLable = GetTTFLabelWrap(getlocal("doubleGems"), 25, CCSizeMake(150, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
            end
            nameLable:setAnchorPoint(ccp(0.5, 1))
            nameLable:setPosition(ccp(awidth, aheight + 40))
            firstRechargeBg:addChild(nameLable, 1)
            
            if v.key == "gems" or v.key == "gem" or (v.type == "p" and (v.key == "p235" or v.key == "p4519")) then
                G_addRectFlicker(icon, 1.4, 1.4)
            end
            
            nameLable:setColor(G_ColorYellowPro)
            if tempHeight < aheight + 35 + nameLable:getContentSize().height then
                tempHeight = aheight + 35 + nameLable:getContentSize().height
            end
        end
    end
    return firstRechargeBg
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function vipRechargeDialog:eventHandler(handler, fn, idx, cel)
    local strSize2 = 16
    local strSize3 = 20
    local strAnPos = ccp(1, 0.5)
    if G_getCurChoseLanguage() == "fr" then
        strSize3 = 14
    elseif G_getCurChoseLanguage() == "cn" or G_getCurChoseLanguage() == "tw" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() == "ja" then
        strSize2 = 20
        strSize3 = 25
        strAnPos = ccp(0.5, 0.5)
    end
    
    if fn == "numberOfCellsInTableView" then
        local sortCfg = self.indexSort
        if self.isShowMCard == true then
            return SizeOfTable(sortCfg) + 1
        else
            return SizeOfTable(sortCfg)
        end
    elseif fn == "tableCellSizeForIndex" then
        local tmpSize = CCSizeMake(self.cellWidth, self.cellHeight)
        -- if self.isFirstRecharge==true then
        -- if idx==0 then
        -- tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-20,275+120)
        -- end
        -- end
        return tmpSize
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        -- if self.isFirstRecharge==true then
        -- if idx==0 then
        -- local firstRechargeBg=self:initFirstRecharge()
        -- firstRechargeBg:setAnchorPoint(ccp(0,0))
        -- firstRechargeBg:setPosition(ccp(10,130))
        -- cell:addChild(firstRechargeBg,1)
        -- end
        -- end
        local cellHeight = self.cellHeight - 6
        local itemWidth = 610
        if self.isShowMCard == true and idx == 0 then
            local leftDays = vipVoApi:getMonthlyCardLeftDays()
            local index = idx
            local xSpace = 0
            local rect = CCRect(0, 0, 50, 50)
            local capInSet = CCRect(20, 20, 10, 10)
            local function cellClick1(hd, fn, index1)
                if self.tv and self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
                    PlayEffect(audioCfg.mouseClick)
                    self.selectIndex = tonumber(index1) - 1001
                    local recordPoint = self.tv:getRecordPoint()
                    self.tv:reloadData()
                    self.tv:recoverToRecordPoint(recordPoint)
                    if G_isApplyVersion() == true then
                        G_setShaderProgramAllChildren(self.tv, function(ccNode)
                            CCShader:setShaderProgram(ccNode, "kShader_ApplyVersion")
                        end)
                    end
                end
            end
            
            local vipRechargeSprie
            --       if self.selectIndex==index then
            -- vipRechargeSprie=LuaCCScale9Sprite:createWithSpriteFrameName("acItemBg2.png",CCRect(50,50,1,1),cellClick1)
            -- else
            -- vipRechargeSprie=LuaCCScale9Sprite:createWithSpriteFrameName("acItemBg1.png",CCRect(50,50,1,1),cellClick1)
            -- end
            if self.selectIndex == index then
                -- vipRechargeSprie=LuaCCScale9Sprite:createWithSpriteFrameName("monthlyBg_Down.png",CCRect(50, 50, 1, 1),cellClick1)
                vipRechargeSprie = LuaCCSprite:createWithSpriteFrameName("vrMonthlySelected.png", cellClick1)
            else
                -- vipRechargeSprie=LuaCCScale9Sprite:createWithSpriteFrameName("monthlyBg.png",CCRect(50, 50, 1, 1),cellClick1)
                vipRechargeSprie = LuaCCSprite:createWithSpriteFrameName("vrunSelect.png", cellClick1)
            end
            -- vipRechargeSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-30, 120))
            -- vipRechargeSprie:ignoreAnchorPointForPosition(false)
            -- vipRechargeSprie:setAnchorPoint(ccp(0,0))
            vipRechargeSprie:setPosition(self.cellWidth / 2, self.cellHeight / 2)
            vipRechargeSprie:setIsSallow(false)
            vipRechargeSprie:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
            vipRechargeSprie:setTag(1001 + index)
            cell:addChild(vipRechargeSprie)
            
            -- local barSp = CCSprite:createWithSpriteFrameName("monthlyBar.png")
            -- barSp:setAnchorPoint(ccp(0.5, 1))
            -- barSp:setPosition(ccp(vipRechargeSprie:getContentSize().width / 2, vipRechargeSprie:getContentSize().height - 5))
            -- vipRechargeSprie:addChild(barSp, 1)
            -- barSp:setScale(1.1)
            
            --local vipRechargeSprie=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
            -- local checkBg = CCSprite:createWithSpriteFrameName("rechargeSelectBtnBg.png")
            -- checkBg:setAnchorPoint(ccp(0,0.5))
            -- checkBg:setPosition(ccp(25+xSpace+5-10,cellHeight/2))
            -- vipRechargeSprie:addChild(checkBg,1)
            
            local numSpacey = 10
            local numScale = 0.7
            local cardCfg = vipVoApi:getMonthlyCardCfg()
            
            -- local gemIcon=CCSprite:create("public/monthlyCard.png")
            local gemIcon = CCSprite:createWithSpriteFrameName("monthlyCardIcon.png")
            -- gemIcon:setScale(80/gemIcon:getContentSize().width)
            -- gemIcon:setPosition(ccp(120,G_VisibleSizeHeight - 250))
            -- self.bgLayer:addChild(gemIcon)
            gemIcon:setPosition(ccp(80, cellHeight / 2))
            gemIcon:setAnchorPoint(ccp(0.5, 0.5))
            --gemIcon:setPosition(ccp(320,cellHeight/2))
            vipRechargeSprie:addChild(gemIcon, 1)
            
            local buyGemsNum = GetBMLabel(cardCfg.goldFirst.."+"..cardCfg.goldContinue, G_vrgoldnumber, 30)
            buyGemsNum:setAnchorPoint(ccp(0, 0.5))
            vipRechargeSprie:addChild(buyGemsNum, 1)
            buyGemsNum:setScale(numScale)
            buyGemsNum:setPosition(ccp(140, cellHeight - buyGemsNum:getContentSize().height / 2 - 30))
            
            local xSpSpace = 0.6
            local days = cardCfg["effectiveDays"]
            -- local xSp = CCSprite:createWithSpriteFrameName("xSign.png")
            -- xSp:setAnchorPoint(ccp(0, 0.5))
            -- xSp:setPosition(ccp(buyGemsNum:getPositionX() + buyGemsNum:getContentSize().width * numScale, cellHeight / 2 - 5 + numSpacey))
            -- xSp:setScale(xSpSpace)
            -- vipRechargeSprie:addChild(xSp, 1)
            local daysLb = GetBMLabel("x"..days, G_vrorangenumber, 30)
            daysLb:setAnchorPoint(ccp(0, 0.5))
            daysLb:setScale(0.6)
            daysLb:setPosition(ccp(buyGemsNum:getPositionX() + buyGemsNum:getContentSize().width * numScale, buyGemsNum:getPositionY() - buyGemsNum:getContentSize().height * numScale / 2 + daysLb:getContentSize().height * daysLb:getScale() / 2))
            vipRechargeSprie:addChild(daysLb, 1)
            -- local daysLb
            -- if G_getCurChoseLanguage() == "cn" or G_getCurChoseLanguage() == "tw" then
            --     daysLb = GetTTFLabel(getlocal("signRewardDay", {days}), 30)
            -- else
            --     daysLb = GetTTFLabel(getlocal("signRewardDay", {days}), 22)
            -- end
            -- daysLb:setAnchorPoint(ccp(0, 0.5))
            -- daysLb:setPosition(ccp(xSp:getPositionX() + xSp:getContentSize().width * xSpSpace, cellHeight / 2 - 5 + numSpacey))
            -- daysLb:setColor(G_ColorYellowPro)
            -- vipRechargeSprie:addChild(daysLb, 1)
            
            -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
            local leftDayLb = GetTTFLabel(getlocal("vip_monthlyCard_left_days", {leftDays or 0}), 18)
            leftDayLb:setAnchorPoint(ccp(0, 0.5))
            leftDayLb:setPosition(ccp(140, 10 + leftDayLb:getContentSize().height / 2))
            vipRechargeSprie:addChild(leftDayLb, 1)
            
            local mcDescLb = GetTTFLabelWrap(getlocal("vip_monthlyCard_not_recharge_active"), strSize2, CCSizeMake(390, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
            mcDescLb:setAnchorPoint(ccp(0, 0.5))
            mcDescLb:setPosition(ccp(140, 10 + leftDayLb:getContentSize().height + mcDescLb:getContentSize().height / 2))
            vipRechargeSprie:addChild(mcDescLb, 1)
            
            local tmpStoreCfg = G_getPlatStoreCfg()
            local mType = tmpStoreCfg["moneyType"][self.moneyName]
            local mPrice = cardCfg["money"][self.moneyName]
            local priceStr = getlocal("buyGemsPrice", {mType, mPrice})
            if G_curPlatName() == "13" or G_curPlatName() == "androidzsykonaver" or G_curPlatName() == "androidzsykoolleh" or G_curPlatName() == "androidzsykotstore" or G_curPlatName() == "androidzhongshouyouko" or G_isKakao() or G_curPlatName() == "59" or G_curPlatName() == "androidcmge" then
                priceStr = getlocal("buyGemsPrice", {mPrice, mType})
            end
            local buyGemsPrice = GetTTFLabel(priceStr, 25)
            buyGemsPrice:setAnchorPoint(ccp(1, 0.5))
            buyGemsPrice:setPosition(ccp(self.bgLayer:getContentSize().width - 60 + xSpace, cellHeight / 2))
            vipRechargeSprie:addChild(buyGemsPrice, 1)
            buyGemsPrice:setColor(G_ColorGreen)
            
            local VipNeedGoldCFG, nowRechargeGold, playerGetedGold
            nowRechargeGold = tonumber(cardCfg.goldFirst)--tonumber(tmpStoreCfg["gold"][index+1])
            playerGetedGold = tonumber(playerVoApi:getBuygems())
            VipNeedGoldCFG = Split(G_getPlatVipCfg(), ",")
            local vipIdx = 1 --vip等级计数
            for k, v in pairs(VipNeedGoldCFG) do
                local num = tonumber(v)
                if nowRechargeGold + playerGetedGold < num then
                    vipIdx = vipIdx - 1
                    break
                end
                vipIdx = vipIdx + 1
            end
            local maxVip = tonumber(playerVoApi:getMaxLvByKey("maxVip"))
            print("vip:", vipIdx, maxVip)
            if vipIdx > 0 and vipIdx <= maxVip and vipIdx > playerVoApi:getVipLevel() then
                local nextVipIcon = CCSprite:createWithSpriteFrameName("Vip"..vipIdx..".png")
                nextVipIcon:setAnchorPoint(ccp(1, 0.5))
                nextVipIcon:setPosition(ccp(vipRechargeSprie:getContentSize().width - 6, vipRechargeSprie:getContentSize().height - 27))
                vipRechargeSprie:addChild(nextVipIcon, 50)
                nextVipIcon:setScale(0.8)
                
                local vipUpIcon = CCSprite:createWithSpriteFrameName("vrUpArrow.png")
                vipUpIcon:setAnchorPoint(ccp(1, 0.5))
                vipUpIcon:setPosition(ccp(vipRechargeSprie:getContentSize().width - nextVipIcon:getContentSize().width * 0.8 - 5, nextVipIcon:getPositionY()))
                vipRechargeSprie:addChild(vipUpIcon, 50)
                -- vipUpIcon:setRotation(15)
                --vipUpIcon:setScale(0.7)
            end
            
            if leftDays and leftDays > 0 then
                -- local buyGemsNum=GetBMLabel(cardCfg.goldContinue,G_GoldFontSrc,30)
                -- buyGemsNum:setAnchorPoint(ccp(0,0.5))
                -- -- buyGemsNum:setPosition(ccp(95,cellHeight/2-5))
                -- vipRechargeSprie:addChild(buyGemsNum,1)
                -- buyGemsNum:setScale(numScale)
                -- buyGemsNum:setPosition(ccp(190+xSpace+10,cellHeight/2-5+numSpacey))
                local function rewardMonthlyHandler()
                    if G_checkClickEnable() == false then
                        do return end
                    end
                    PlayEffect(audioCfg.mouseClick)
                    local function callBack()
                        if self.rewardMonthlyBtn then
                            self.rewardMonthlyBtn:setEnabled(false)
                            G_removeFlicker(self.rewardMonthlyBtn)
                            local lb = tolua.cast(self.rewardMonthlyBtn:getChildByTag(101), "CCLabelTTF")
                            if(lb)then
                                lb:setString(getlocal("activity_hadReward"))
                            end
                        end
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("active_lottery_reward_tank", {getlocal("gem"), "x"..cardCfg.goldContinue}), 28)
                    end
                    vipVoApi:getMonthlyCardReward(callBack)
                end
                local btnScale = 0.6
                local canRewardMonthly = vipVoApi:checkCanGetMonthlyCardReward()
                if canRewardMonthly == true then
                    self.rewardMonthlyBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn_down.png", rewardMonthlyHandler, nil, getlocal("daily_scene_get"), 22 / btnScale, 101)
                else
                    self.rewardMonthlyBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn_down.png", rewardMonthlyHandler, nil, getlocal("activity_hadReward"), 22 / btnScale, 101)
                end
                self.rewardMonthlyBtn:setScale(btnScale)
                local rewardMonthlyMenu = CCMenu:createWithItem(self.rewardMonthlyBtn)
                rewardMonthlyMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
                rewardMonthlyMenu:setPosition(ccp(self.bgLayer:getContentSize().width - 123, cellHeight / 2 - 40))
                vipRechargeSprie:addChild(rewardMonthlyMenu, 1)
                if canRewardMonthly == true then
                    local scaleX, scaleY = (self.rewardMonthlyBtn:getContentSize().width + 20) / 80, (self.rewardMonthlyBtn:getContentSize().height + 10) / 80
                    G_addRectFlicker(self.rewardMonthlyBtn, scaleX, scaleY)
                else
                    self.rewardMonthlyBtn:setEnabled(false)
                end
            else
                --军需卡规则
                local function monthCardRule()
                    local cardCfg = vipVoApi:getMonthlyCardCfg()
                    local tabStr = {getlocal("monthlyCard_rule")}
                    local textFormatTb = {{}}
                    for k = 1, 5 do
                        local args, format = {}, {}
                        if k == 1 then
                            args, format = {cardCfg.goldFirst}, {richFlag = true, richColor = {nil, G_ColorGreen, nil}}
                        elseif k == 2 then
                            args, format = {cardCfg.goldContinue, cardCfg.effectiveDays}, {richFlag = true, richColor = {nil, G_ColorGreen, nil, G_ColorGreen, nil}}
                        elseif k == 5 then
                            args, format = {2 * cardCfg.effectiveDays}, {richFlag = true, richColor = {nil, G_ColorGreen, nil}}
                        end
                        table.insert(tabStr, getlocal("monthlyCard_rule"..k, args))
                        table.insert(textFormatTb, format)
                    end
                    local titleStr = getlocal("activity_baseLeveling_ruleTitle")
                    require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
                    tipShowSmallDialog:showStrInfo(self.layerNum + 1, true, true, nil, titleStr, tabStr, nil, 25, textFormatTb)
                end
                G_createBotton(vipRechargeSprie, ccp(self.bgLayer:getContentSize().width - 123, cellHeight / 2 - 40), {getlocal("vip_monthlyCard"), 22}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", monthCardRule, 0.6, -(self.layerNum - 1) * 20 - 3)
            end
            
            if self.selectIndex == index then
                -- local checkIcon = CCSprite:createWithSpriteFrameName("rechargeSelectBtn.png")
                -- --checkIcon:setAnchorPoint(ccp(0,0.5))
                -- checkIcon:setPosition(getCenterPoint(checkBg))
                -- checkBg:addChild(checkIcon,1)
                if buyGemsPrice then
                    buyGemsPrice:setColor(G_ColorWhite)
                end
            end
        else
            local index = idx
            if self.isShowMCard == true then
                index = idx - 1
            end
            local rect = CCRect(0, 0, 50, 50)
            local capInSet = CCRect(20, 20, 10, 10)
            local function cellClick(hd, fn, index1)
                if self.tv and self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
                    PlayEffect(audioCfg.mouseClick)
                    self.selectIndex = tonumber(index1) - 1000
                    local recordPoint = self.tv:getRecordPoint()
                    self.tv:reloadData()
                    self.tv:recoverToRecordPoint(recordPoint)
                    if G_isApplyVersion() == true then
                        G_setShaderProgramAllChildren(self.tv, function(ccNode)
                            CCShader:setShaderProgram(ccNode, "kShader_ApplyVersion")
                        end)
                    end
                end
            end
            
            local vipRechargeSprie
            if self.selectIndex == (index + 1) then
                -- vipRechargeSprie=LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBgSelect.png",CCRect(20, 20, 10, 10),cellClick)
                vipRechargeSprie = LuaCCSprite:createWithSpriteFrameName("vrSelected.png", cellClick)
            else
                -- vipRechargeSprie=LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",CCRect(20, 20, 10, 10),cellClick)
                vipRechargeSprie = LuaCCSprite:createWithSpriteFrameName("vrunSelect.png", cellClick)
            end
            -- vipRechargeSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40, 110))
            -- vipRechargeSprie:ignoreAnchorPointForPosition(false)
            -- vipRechargeSprie:setAnchorPoint(ccp(0,0))
            vipRechargeSprie:setPosition(self.cellWidth / 2, self.cellHeight / 2)
            vipRechargeSprie:setIsSallow(false)
            vipRechargeSprie:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
            vipRechargeSprie:setTag(1001 + index)
            cell:addChild(vipRechargeSprie)
            
            --local vipRechargeSprie=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
            -- local checkBg = CCSprite:createWithSpriteFrameName("rechargeSelectBtnBg.png")
            -- checkBg:setAnchorPoint(ccp(0, 0.5))
            -- checkBg:setPosition(ccp(25 - 10, cellHeight / 2))
            -- vipRechargeSprie:addChild(checkBg, 1)
            local tmpStoreCfg = G_getPlatStoreCfg()
            
            local mType = tmpStoreCfg["moneyType"][self.moneyName]
            local mPrice = tmpStoreCfg["money"][self.moneyName][index + 1]
            local priceStr = getlocal("buyGemsPrice", {mType, mPrice})
            if G_curPlatName() == "13" or G_curPlatName() == "androidzsykonaver" or G_curPlatName() == "androidzsykoolleh" or G_curPlatName() == "androidzsykotstore" or G_curPlatName() == "androidzhongshouyouko" or G_isKakao() or G_curPlatName() == "59" or G_curPlatName() == "androidcmge" then
                priceStr = getlocal("buyGemsPrice", {mPrice, mType})
            end
            local buyGemsPrice = GetTTFLabel(priceStr, 24)
            buyGemsPrice:setAnchorPoint(ccp(1, 0.5))
            buyGemsPrice:setPosition(ccp(self.bgLayer:getContentSize().width - 60, cellHeight / 2))
            vipRechargeSprie:addChild(buyGemsPrice, 1)
            buyGemsPrice:setColor(G_ColorGreen)
            
            local buyGemsNumber = tmpStoreCfg["gold"][index + 1]
            local isShowDouble = false
            if acFirstRechargeVoApi then
                isShowDouble = acFirstRechargeVoApi:isShowFirstDouble(buyGemsNumber)
            end
            --local buyGemsDiscount
            if isShowDouble == false and tmpStoreCfg["goldPreferential"][index + 1] ~= "" then
                local buyGemsDiscount = GetTTFLabel(getlocal("buyGemsDiscount", {tmpStoreCfg["goldPreferential"][index + 1]}), 28)
                buyGemsDiscount:setAnchorPoint(ccp(1, 1))
                buyGemsDiscount:setPosition(ccp(self.bgLayer:getContentSize().width - 60, 35))
                buyGemsDiscount:setColor(G_ColorYellowPro)
                if platCfg.platCfgStoreShowDisCount[G_curPlatName()] == nil then
                    vipRechargeSprie:addChild(buyGemsDiscount, 1)
                end
            end
            
            if self.selectIndex == (index + 1) then
                -- local checkIcon = CCSprite:createWithSpriteFrameName("rechargeSelectBtn.png")
                -- --checkIcon:setAnchorPoint(ccp(0,0.5))
                -- checkIcon:setPosition(getCenterPoint(checkBg))
                -- checkBg:addChild(checkIcon, 1)
                buyGemsPrice:setColor(G_ColorWhite)
                if buyGemsDiscount ~= nil then
                    buyGemsDiscount:setColor(G_ColorWhite)
                end
            end
            
            -- if(G_curPlatName()=="0" or G_curPlatName()=="androidfltencent" or G_curPlatName()=="androidtencentyxb")then
            if(G_curPlatName() == "androidfltencent" or G_curPlatName() == "androidtencentyxb")then
                if(tonumber(buyGemsNumber) > mPrice * 10)then
                    local extraNum = tonumber(buyGemsNumber) - mPrice * 10
                    if(isShowDouble)then
                        extraNum = extraNum * 2
                    end
                    buyGemsNumber = mPrice * 10
                    local songLb = GetTTFLabel("送", 23)
                    songLb:setAnchorPoint(ccp(0, 0.5))
                    songLb:setPosition(ccp(G_VisibleSizeWidth - 170, cellHeight / 2 - 30))
                    vipRechargeSprie:addChild(songLb, 1)
                    songLb:setColor(G_ColorYellowPro)
                    
                    local buyGemsNum2 = GetBMLabel(extraNum, G_vrgoldnumber, 20)
                    buyGemsNum2:setAnchorPoint(ccp(0, 0.5))
                    buyGemsNum2:setPosition(ccp(songLb:getPositionX() + songLb:getContentSize().width + 5, cellHeight / 2 - 30))
                    buyGemsNum2:setScale(0.5)
                    vipRechargeSprie:addChild(buyGemsNum2, 1)
                end
            end
            local buyGemsNum = GetBMLabel(buyGemsNumber, G_vrgoldnumber, 30)
            buyGemsNum:setAnchorPoint(ccp(0, 0.5))
            -- buyGemsNum:setPosition(ccp(95,cellHeight/2-5))
            vipRechargeSprie:addChild(buyGemsNum, 1)
            
            local gemIcon
            -- if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
            -- local sortCfg=self.indexSort
            --       local curIdx = sortCfg[index+1]
            -- local imageStrName="iconGold"..curIdx..".png"
            --       gemIcon= CCSprite:createWithSpriteFrameName(imageStrName)
            --       -- gemIcon:setPosition(ccp(320,cellHeight/2))
            --       gemIcon:setPosition(ccp(150,cellHeight/2))
            --       buyGemsNum:setPosition(ccp(220,cellHeight/2-5))
            -- else
            -- gemIcon = CCSprite:createWithSpriteFrameName("GoldImage.png")
            local sortCfg = self.indexSort
            local curIdx = sortCfg[index + 1]
            local imageStrName
            if self.iconPicTb then
                imageStrName = self.iconPicTb[index + 1]
            else
                imageStrName = "iconGoldNew"..curIdx..".png"
            end
            gemIcon = CCSprite:createWithSpriteFrameName(imageStrName)
            -- local iconPosWidth = 280
            -- if G_getCurChoseLanguage() =="vi" then
            -- iconPosWidth =320
            -- end
            -- gemIcon:setPosition(ccp(iconPosWidth,cellHeight/2))
            if gemIcon then
                gemIcon:setPosition(ccp(80, vipRechargeSprie:getContentSize().height / 2))
                gemIcon:setAnchorPoint(ccp(0.5, 0.5))
                vipRechargeSprie:addChild(gemIcon, 1)
            end
            buyGemsNum:setPosition(ccp(140, cellHeight / 2 - 20))
            -- end
            
            --gemIcon:setScaleX(0.78)
            --gemIcon:setScaleY(0.75)
            --gemIcon:setPosition(ccp(320,cellHeight/2))
            
            --local buyGemsNum=GetTTFLabel(getlocal("buyGemsNum",{getlocal("buyGoldNum"..(idx+1))}),28)
            
            -- if  G_curPlatName()=="androidtencentyxb" or G_curPlatName()=="androidewan" then
            -- local scale = 0.6
            
            -- local str = tmpStoreCfg["gold"][idx+1]
            -- if idx>4 then
            -- str = tmpStoreCfg["gold"][idx+1]
            -- else
            -- str = mPrice*10
            -- end
            
            -- local buyGemsNum=GetBMLabel(str,G_GoldFontSrc,20)
            --        buyGemsNum:setAnchorPoint(ccp(0,0.5))
            --        buyGemsNum:setPosition(ccp(95,cellHeight/2-5))
            --        vipRechargeSprie:addChild(buyGemsNum,1)
            --        buyGemsNum:setScale(scale)
            
            --        if idx<=1 then
            
            --         local songLb=GetTTFLabel("送",33)
            --         songLb:setAnchorPoint(ccp(0,0.5))
            --         songLb:setPosition(ccp(buyGemsNum:getPositionX()+buyGemsNum:getContentSize().width*scale+5,cellHeight/2-5))
            --         vipRechargeSprie:addChild(songLb,1)
            -- songLb:setColor(G_ColorYellowPro)
            
            -- local buyGemsNum2=GetBMLabel(tmpStoreCfg["gold"][idx+1]-mPrice*10,G_GoldFontSrc,20)
            --         buyGemsNum2:setAnchorPoint(ccp(0,0.5))
            --         buyGemsNum2:setPosition(ccp(songLb:getPositionX()+songLb:getContentSize().width+5,cellHeight/2-5))
            --         buyGemsNum2:setScale(scale)
            --         vipRechargeSprie:addChild(buyGemsNum2,1)
            --         gemIcon:setPosition(ccp(360,cellHeight/2))
            --     else
            --     gemIcon:setPosition(ccp(200,cellHeight/2))
            
            --        end
            -- else
            -- local buyGemsNum=GetBMLabel(tmpStoreCfg["gold"][idx+1],G_GoldFontSrc,30)
            --        buyGemsNum:setAnchorPoint(ccp(0,0.5))
            --        buyGemsNum:setPosition(ccp(95,cellHeight/2-5))
            --        vipRechargeSprie:addChild(buyGemsNum,1)
            -- end
            
            --[[
local goldNumLabel=GetBMLabel(getlocal("buyGemsNum",{getlocal("buyGoldNum"..(idx+1))}),G_GoldFontSrc,30)
goldNumLabel:setAnchorPoint(ccp(0,1))
goldNumLabel:setPosition(ccp(tabBtnItem:getContentSize().width,tabBtnItem:getContentSize().height))
--goldNumLabel:setVisible(false)
goldNumLabel:setTag(11)
tabBtnItem:addChild(goldNumLabel)
        ]]
            
            -- print("buyGemsNumber",buyGemsNumber)
            -- print("isShowDouble",isShowDouble)
            local strSubPosX = 100
            if G_getCurChoseLanguage() == "cn" or G_getCurChoseLanguage() == "tw" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() == "ja" then
                strSubPosX = 0
            end
            local bgScale = 1
            if isShowDouble == true then
                -- local dNumSp = CCSprite:createWithSpriteFrameName("double_num.png")
                -- dNumSp:setAnchorPoint(ccp(0, 0.5))
                -- dNumSp:setPosition(ccp(buyGemsNum:getPositionX() + buyGemsNum:getContentSize().width - 5, cellHeight / 2 - 15))
                -- vipRechargeSprie:addChild(dNumSp, 1)
                local dNumSp = GetBMLabel("x2", G_vrorangenumber, 30)
                dNumSp:setAnchorPoint(ccp(0, 0))
                dNumSp:setPosition(ccp(buyGemsNum:getPositionX() + buyGemsNum:getContentSize().width, buyGemsNum:getPositionY() - buyGemsNum:getContentSize().height / 2))
                vipRechargeSprie:addChild(dNumSp, 1)
                
                local redBg = CCSprite:createWithSpriteFrameName("vrItemRedCornerPic.png") --CCSprite:createWithSpriteFrameName("BgHot.png")
                redBg:setAnchorPoint(ccp(1, 1))
                redBg:setPosition(ccp(itemWidth + 5, cellHeight - 2))
                redBg:setScale(bgScale)
                vipRechargeSprie:addChild(redBg)
                
                local dsPos = ccp(redBg:getContentSize().width * 0.66, redBg:getContentSize().height * 0.5)
                if G_getCurChoseLanguage() == "cn" or G_getCurChoseLanguage() == "tw" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() == "ja" then
                    dsPos = getCenterPoint(redBg)
                end
                local doubleStr = GetTTFLabel(getlocal("first_recharge_double"), 24, true)
                doubleStr:setPosition(dsPos)
                doubleStr:setAnchorPoint(strAnPos)
                doubleStr:setScale(1 / bgScale)
                redBg:addChild(doubleStr, 1)
            else
                local hotSellCfg = playerCfg.recharge.hotSell
                local bestSellCfg = playerCfg.recharge.bestSell
                if(G_curPlatName() ~= "14" and G_curPlatName() ~= "androidkunlun1mobile" and G_curPlatName() ~= "androidkunlun" and G_curPlatName() ~= "androidkunlunz" and G_curPlatName() ~= "32" and G_curPlatName() ~= "androidklfy" and G_curPlatName() ~= "59" and G_curPlatName() ~= "androidcmge") then
                    for k, v in pairs(hotSellCfg) do
                        if tostring(index + 1) == tostring(v) then
                            local hotIcon = CCSprite:createWithSpriteFrameName("vrItemRedCornerPic.png") --CCSprite:createWithSpriteFrameName("BgHot.png")
                            hotIcon:setAnchorPoint(ccp(1, 1))
                            hotIcon:setPosition(ccp(itemWidth + 5, cellHeight - 2))
                            hotIcon:setScale(bgScale)
                            vipRechargeSprie:addChild(hotIcon)
                            
                            local hotStr = GetTTFLabel(getlocal("hotSell"), 25)
                            hotStr:setPosition(getCenterPoint(hotIcon))
                            hotStr:setScale(1 / bgScale)
                            hotIcon:addChild(hotStr, 1)
                        end
                    end
                end
                if(G_curPlatName() ~= "14" and G_curPlatName() ~= "androidkunlun1mobile" and G_curPlatName() ~= "androidkunlun" and G_curPlatName() ~= "androidkunlunz" and G_curPlatName() ~= "32" and G_curPlatName() ~= "androidklfy" and G_curPlatName() ~= "59" and G_curPlatName() ~= "androidcmge") then
                    for k, v in pairs(bestSellCfg) do
                        if tostring(index + 1) == tostring(v) then
                            local cheapIcon = CCSprite:createWithSpriteFrameName("vrItemPurpleCornerPic.png") --CCSprite:createWithSpriteFrameName("BgCheap.png")
                            cheapIcon:setAnchorPoint(ccp(1, 1))
                            cheapIcon:setPosition(ccp(itemWidth + 5, cellHeight - 2))
                            cheapIcon:setScale(bgScale)
                            vipRechargeSprie:addChild(cheapIcon)
                            
                            local cheapStr = GetTTFLabel(getlocal("bestSell"), 25)
                            cheapStr:setPosition(getCenterPoint(cheapIcon))
                            cheapStr:setScale(1 / bgScale)
                            cheapIcon:addChild(cheapStr, 1)
                        end
                    end
                end
                if G_curPlatName() == "androidwostore" and (index == 4 or index == 5) then
                    local hotIcon = CCSprite:createWithSpriteFrameName("vrItemRedCornerPic.png") --CCSprite:createWithSpriteFrameName("BgHot.png")
                    hotIcon:setAnchorPoint(ccp(1, 1))
                    hotIcon:setPosition(ccp(itemWidth + 5, cellHeight - 2))
                    vipRechargeSprie:addChild(hotIcon)
                    local hotStr = GetTTFLabel("话费一键支付", 25)
                    hotStr:setPosition(getCenterPoint(hotIcon))
                    hotIcon:addChild(hotStr, 1)
                    
                end
            end
            
            local VipNeedGoldCFG, nowRechargeGold, playerGetedGold
            nowRechargeGold = tonumber(tmpStoreCfg["gold"][index + 1])
            playerGetedGold = tonumber(playerVoApi:getBuygems())
            VipNeedGoldCFG = Split(G_getPlatVipCfg(), ",")
            local vipIdx = 1 --vip等级计数
            for k, v in pairs(VipNeedGoldCFG) do
                local num = tonumber(v)
                if nowRechargeGold + playerGetedGold < num then
                    vipIdx = vipIdx - 1
                    break
                end
                vipIdx = vipIdx + 1
            end
            local maxVip = tonumber(playerVoApi:getMaxLvByKey("maxVip"))
            print("vip:", vipIdx, maxVip)
            if vipIdx > 0 and vipIdx <= maxVip and vipIdx > playerVoApi:getVipLevel() then
                local nextVipIcon = CCSprite:createWithSpriteFrameName("Vip"..vipIdx..".png")
                nextVipIcon:setAnchorPoint(ccp(1, 0.5))
                nextVipIcon:setPosition(ccp(vipRechargeSprie:getContentSize().width - 6, vipRechargeSprie:getContentSize().height - 27))
                vipRechargeSprie:addChild(nextVipIcon, 50)
                nextVipIcon:setScale(0.8)
                
                local vipUpIcon = CCSprite:createWithSpriteFrameName("vrUpArrow.png")
                vipUpIcon:setAnchorPoint(ccp(1, 0.5))
                vipUpIcon:setPosition(ccp(vipRechargeSprie:getContentSize().width - nextVipIcon:getContentSize().width * 0.8 - 5, nextVipIcon:getPositionY()))
                vipRechargeSprie:addChild(vipUpIcon, 50)
                -- vipUpIcon:setRotation(15)
                --vipUpIcon:setScale(0.7)
                
            end
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

function vipRechargeDialog:initAdBg()
    if self and self.adSp then
        self.adSp:removeFromParentAndCleanup(true)
        self.adSp = nil
    end
    if acFirstRechargeVoApi == nil or acFirstRechargeVoApi:isOpen() == false or (acFirstRechargeVoApi and acFirstRechargeVoApi:isHadReward() == true) then
        local function rechargeHandler(...)
            if G_checkClickEnable() == false then
                do
                    return
                end
            end
            local tmpStoreCfg = G_getPlatStoreCfg()
            local hotSellCfg = playerCfg.recharge.hotSell
            if hotSellCfg and hotSellCfg[1] then
                local selectIndex = tonumber(hotSellCfg[1])
                self:realRechargeHandler(nil, nil, selectIndex)
            end
        end
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        self.adSp = LuaCCSprite:createWithFileName("public/rechaegeAd1.jpg", rechargeHandler)
        self.adSp:setPosition(ccp(G_VisibleSize.width / 2, G_VisibleSize.height - 82 - self.adSp:getContentSize().height / 2))
        self.adSp:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
        self.bgLayer:addChild(self.adSp)
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        
        local hotFlagBg = CCSprite:createWithSpriteFrameName("vrHot.png") --CCSprite:createWithSpriteFrameName("hotFlagBg.png")
        hotFlagBg:setPosition(ccp(210, 200))
        self.adSp:addChild(hotFlagBg, 1)
        local hotLb = GetTTFLabel(getlocal("new_recharge_hot_desc"), 30)
        hotLb:setPosition(getCenterPoint(hotFlagBg))
        hotFlagBg:addChild(hotLb, 1)
        hotLb:setRotation(-10)
        
        local tmpStoreCfg = G_getPlatStoreCfg()
        local hotSellCfg = playerCfg.recharge.hotSell
        
        if hotSellCfg and hotSellCfg[1] then
            local hotIndex = tonumber(hotSellCfg[1])
            local sortCfg = self.indexSort
            local curIdx = tonumber(sortCfg[hotIndex])
            local gemIcon
            if(self.iconPicTb)then
                gemIcon = CCSprite:createWithSpriteFrameName(self.iconPicTb[hotIndex])
            else
                gemIcon = CCSprite:createWithSpriteFrameName("iconGoldNew"..curIdx..".png")
            end
            gemIcon:setPosition(ccp(100, 140))
            gemIcon:setScale(1.4)
            self.adSp:addChild(gemIcon, 1)
            
            local buyGemsNumber = tmpStoreCfg["gold"][tonumber(hotSellCfg[1])]
            local buyGemsNum = GetBMLabel(buyGemsNumber, G_vrgoldnumber, 30)
            buyGemsNum:setAnchorPoint(ccp(0, 0.5))
            buyGemsNum:setPosition(ccp(180, 120))
            self.adSp:addChild(buyGemsNum, 1)
            
            local firstDescLb = GetTTFLabelWrap(getlocal("new_recharge_recharge_hot_sell"), 25, CCSizeMake(350, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
            firstDescLb:setAnchorPoint(ccp(0, 0.5))
            firstDescLb:setPosition(ccp(40, 70))
            self.adSp:addChild(firstDescLb, 1)
            firstDescLb:setColor(G_ColorYellowPro)
            
            local isShowDouble = false
            if acFirstRechargeVoApi then
                isShowDouble = acFirstRechargeVoApi:isShowFirstDouble(buyGemsNumber)
            end
            if isShowDouble == true then
                local dNumSp = GetBMLabel("x2", G_vrorangenumber, 30)--CCSprite:createWithSpriteFrameName("double_num.png")
                dNumSp:setAnchorPoint(ccp(0, 0.5))
                dNumSp:setPosition(ccp(buyGemsNum:getPositionX() + buyGemsNum:getContentSize().width - 5, buyGemsNum:getPositionY() - 5))
                self.adSp:addChild(dNumSp, 1)
                
                firstDescLb:setString(getlocal("new_recharge_first_double"))
            end
        end
        
        local scale = 0.7
        local rechargeBtn = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn_Down.png", rechargeHandler, nil, getlocal("new_recharge_recharge_now"), 26, 100);
        rechargeBtn:setScale(scale)
        local rechargeBtnMenu = CCMenu:createWithItem(rechargeBtn)
        rechargeBtnMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
        rechargeBtnMenu:setPosition(ccp(self.adSp:getContentSize().width - rechargeBtn:getContentSize().width / 2 * scale - 25, 35))
        self.adSp:addChild(rechargeBtnMenu, 1)
        local lb = rechargeBtn:getChildByTag(100)
        if lb then
            lb = tolua.cast(lb, "CCLabelTTF")
            lb:setFontName("Helvetica-bold")
        end
        local flag, status = healthyApi:getHealthyRechargeStatus()
        if flag == false and status == 0 then
            rechargeBtn:setEnabled(false)
        end
    else
        local strSize = 28
        local strWidht2 = 250
        if G_getCurChoseLanguage() == "cn" or G_getCurChoseLanguage() == "tw" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() == "ja" then
            strSize = 35
            strWidht2 = 350
        end
        -- local function gotoAcFirstRecharge( ... )
        -- if G_checkClickEnable()==false then
        --            do
        --                return
        --            end
        --        end
        -- if acFirstRechargeVoApi and acFirstRechargeVoApi:isHadReward()==false then
        -- local vo=acFirstRechargeVoApi:getAcVo()
        -- if vo then
        --             local openDialog = acFirstRechargeDialog:new()
        --             openDialog:initVo(vo)
        --             local acTitle = getlocal("activity")
        --             local vd = openDialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,acTitle,true,self.layerNum+1);
        --             sceneGame:addChild(vd,self.layerNum+1)
        --             self:close()
        --         end
        --        end
        -- end
        local function rechargeHandler2(...)
            if G_checkClickEnable() == false then
                do
                    return
                end
            end
            if acFirstRechargeVoApi then
                local isReward = acFirstRechargeVoApi:canReward()
                if isReward == true then
                else
                    if self.selectIndex and self.selectIndex == 0 then
                        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("new_recharge_not_first_recharge_active"), nil, self.layerNum + 1)
                    else
                        self:realRechargeHandler()
                    end
                end
            end
        end
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        local adPic = "public/rechaegeAd2.jpg"
        if G_checkUseAuditUI() == true then
            adPic = "public/rechaegeAd2_audit.jpg"
        end
        self.adSp = LuaCCSprite:createWithFileName(adPic, rechargeHandler2)
        self.adSp:setPosition(ccp(G_VisibleSize.width / 2, G_VisibleSize.height - 82 - self.adSp:getContentSize().height / 2))
        self.adSp:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
        self.bgLayer:addChild(self.adSp)
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        
        local lbx = self.adSp:getContentSize().width / 2
        local firstLb = GetTTFLabelWrap(getlocal("firstRechargeReward"), 24, CCSizeMake(200, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
        local tempLb = GetTTFLabel(getlocal("firstRechargeReward"), 24, true)
        local realWidth = tempLb:getContentSize().width
        if realWidth > firstLb:getContentSize().width then
            realWidth = firstLb:getContentSize().width
        end
        local minTitleWidth = 80
        if realWidth < minTitleWidth then
            realWidth = minTitleWidth
        end
        realWidth = realWidth + 16
        for k = 1, 2 do
            local titleFlySp = CCSprite:createWithSpriteFrameName("vfirstrTitleFly.png")
            titleFlySp:setPosition(self.adSp:getContentSize().width / 2 + (2 * k - 3) * (realWidth / 2 + titleFlySp:getContentSize().width / 2), self.adSp:getContentSize().height - 45)
            if k == 2 then
                titleFlySp:setFlipX(true)
            end
            self.adSp:addChild(titleFlySp)
        end
        firstLb:setPosition(ccp(lbx, self.adSp:getContentSize().height - 45))
        firstLb:setColor(G_ColorYellowPro)
        self.adSp:addChild(firstLb, 1)
        
        local firstGift = playerCfg.recharge.firstChargeGift
        local giftData = FormatItem(firstGift, true, true)
        -- if acFirstRechargeVoApi and base.newRechargeSwitch==1 then
        -- for k,v in pairs(giftData) do
        -- if v.key=="gem" or v.key=="gems" then
        -- table.remove(giftData,k)
        -- end
        -- end
        -- end
        local isReward, isShowDouble = false, false
        local isHadRewardGems = false
        if acFirstRechargeVoApi then
            isReward, isShowDouble = acFirstRechargeVoApi:canReward()
            isHadRewardGems = acFirstRechargeVoApi:isHadRewardGems()
        end
        if base.newRechargeSwitch == 1 then
            if isReward == false or (isReward == true and isShowDouble == false) then
                for k, v in pairs(giftData) do
                    if v.key == "gem" or v.key == "gems" then
                        table.remove(giftData, k)
                    end
                end
            end
        elseif base.newRechargeSwitch == 0 then
            if isHadRewardGems == true then
                for k, v in pairs(giftData) do
                    if v.key == "gem" or v.key == "gems" then
                        table.remove(giftData, k)
                    end
                end
            end
        end
        
        local rewardleftPosX, iconBgWidth, iconWidth = 125, 103, 70
        local tempHeight = 0
        for k, v in pairs(giftData) do
            if v and v.name then
                local awidth = rewardleftPosX + (2 * k - 1) * (iconBgWidth / 2 - 2)
                local aheight = self.adSp:getContentSize().height / 2
                local function showInfoHandler()
                    if v and v.name and v.pic then
                        if v.key == "gems" or v.key == "gem" then
                            local replaceNumStr = getlocal("doubleGems")
                            local hideNum = false
                            propInfoDialog:create(sceneGame, v, self.layerNum + 1, nil, nil, nil, nil, nil, nil, hideNum, nil, nil, replaceNumStr)
                            return false
                        else
                            -- propInfoDialog:create(sceneGame,v,self.layerNum+1)
                        end
                    end
                    return true
                end
                local icon, scale
                if v.key == "gems" or v.key == "gem" then
                    icon, scale = G_getItemIcon(v, 100, false, self.layerNum)
                else
                    icon, scale = G_getItemIcon(v, 100, true, self.layerNum)
                end
                -- scale = scale or 1
                if icon then
                    local rewardBg = CCSprite:createWithSpriteFrameName("vfirstrBg.png")
                    rewardBg:setPosition(awidth, aheight)
                    self.adSp:addChild(rewardBg)
                    icon:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
                    icon:setIsSallow(true)
                    icon:setScale(iconWidth / icon:getContentSize().width)
                    icon:setPosition(getCenterPoint(rewardBg))
                    rewardBg:addChild(icon, 1)
                    
                    if v.key == "gems" or v.key == "gem" then
                    else
                        local numLb = GetTTFLabel("x"..FormatNumber(v.num), 23)
                        numLb:setAnchorPoint(ccp(1, 0))
                        numLb:setScale(1 / scale)
                        numLb:setPosition(ccp(icon:getContentSize().width - 5, 0))
                        icon:addChild(numLb, 4)
                    end
                    
                    if v.key == "gem" or v.key == "gems" or (v.type == "p" and (v.key == "p235" or v.key == "p4519")) then
                        G_addRectFlicker(icon, 1.4, 1.4)
                    end
                end
            end
        end
        
        -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
        -- local descLb=GetTTFLabelWrap(str,20,CCSizeMake(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        local descLb = GetTTFLabelWrap(getlocal("new_recharge_recharge_any_desc"), 20, CCSizeMake(strWidht2, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
        descLb:setAnchorPoint(ccp(0, 0.5))
        descLb:setPosition(ccp(lbx - 85 - 70 / 2, 35))
        self.adSp:addChild(descLb, 1)
        
        -- local rect = CCRect(0, 0, 50, 50)
        -- local capInSet = CCRect(59, 17, 2, 2)
        -- local function touch(hd, fn, idx)
        -- end
        -- local descLbBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png", capInSet, touch)
        -- descLbBg:setContentSize(CCSizeMake(280, 36))
        -- descLbBg:ignoreAnchorPointForPosition(false)
        -- descLbBg:setAnchorPoint(ccp(0.5, 0.5))
        -- descLbBg:setIsSallow(false)
        -- descLbBg:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
        -- descLbBg:setPosition(ccp(lbx, 35))
        -- descLbBg:setOpacity(100)
        -- self.adSp:addChild(descLbBg)
        
        local scale = 0.7
        if acFirstRechargeVoApi and isReward == true then
            local isReward, isShowDouble, isCanReward = acFirstRechargeVoApi:canReward()
            local function rewardHandler(...)
                local function getRewardSuccess(fn, data)
                    -- local isReward,isShowDouble=false,false
                    -- if acFirstRechargeVoApi then
                    --     isReward,isShowDouble=acFirstRechargeVoApi:canReward()
                    -- end
                    -- local isRewardDouble=true
                    -- if base.newRechargeSwitch==1 then
                    --     if isReward==false or (isReward==true and isShowDouble==false) then
                    --         isRewardDouble=false
                    --     end
                    -- end
                    local acVo = G_clone(acFirstRechargeVoApi:getAcVo())
                    local ret, sData = base:checkServerData(data)
                    if ret == true then
                        PlayEffect(audioCfg.mouseClick)
                        local awardTab = FormatItem(acVo.reward, true, true)
                        -- 添加奖励
                        for k, v in pairs(awardTab) do
                            -- print("数值是",k,v.key,v.num)
                            if v.key == "gem" or v.key == "gems" then
                                if (acVo.c >= acVo.v and (acVo.r == nil or acVo.r == 0)) then
                                    awardTab[k].num = tonumber(acVo.c)
                                else
                                    awardTab[k].num = 0
                                end
                            end
                            G_addPlayerAward(v.type, v.key, v.id, tonumber(v.num))
                        end
                        
                        if sData.data and sData.data.useractive then
                            activityVoApi:updateVoByType(sData.data.useractive)
                        end
                        eventDispatcher:dispatchEvent("activity.firstRechargeComplete")
                        eventDispatcher:dispatchEvent("activity.firstRechargeComplete2")
                        if awardTab then
                            for k, v in pairs(awardTab) do
                                if v and v.num <= 0 then
                                    table.remove(awardTab, k)
                                end
                            end
                        end
                        smallDialog:showRewardDialog("TankInforPanel.png", CCSizeMake(500, 600), CCRect(0, 0, 400, 350), CCRect(130, 50, 1, 1), true, self.layerNum + 1, {getlocal("activity_getReward")}, 25, awardTab)
                        self:refreshUI()
                    end
                end
                socketHelper:activityFinished("firstRecharge", getRewardSuccess)
            end
            local rewardBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn_down.png", rewardHandler, nil, getlocal("newGiftsReward"), 26, 100);
            rewardBtn:setScale(scale)
            local lb = rewardBtn:getChildByTag(100)
            if lb then
                lb = tolua.cast(lb, "CCLabelTTF")
                lb:setFontName("Helvetica-bold")
            end
            local rewardBtnMenu = CCMenu:createWithItem(rewardBtn)
            rewardBtnMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
            rewardBtnMenu:setPosition(ccp(self.adSp:getContentSize().width - rewardBtn:getContentSize().width / 2 * scale - 25, 35))
            self.adSp:addChild(rewardBtnMenu, 1)
            if isCanReward == false then
                rewardBtn:setEnabled(false)
            end
        else
            
            local rechargeBtn = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn_Down.png", rechargeHandler2, nil, getlocal("new_recharge_recharge_now"), 26, 100);
            rechargeBtn:setScale(scale)
            local lb = rechargeBtn:getChildByTag(100)
            if lb then
                lb = tolua.cast(lb, "CCLabelTTF")
                lb:setFontName("Helvetica-bold")
            end
            local rechargeBtnMenu = CCMenu:createWithItem(rechargeBtn)
            rechargeBtnMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
            rechargeBtnMenu:setPosition(ccp(self.adSp:getContentSize().width - rechargeBtn:getContentSize().width / 2 * scale - 25, 35))
            self.adSp:addChild(rechargeBtnMenu, 1)
            local flag, status = healthyApi:getHealthyRechargeStatus()
            if flag == false and status == 0 then
                rechargeBtn:setEnabled(false)
            end
        end
    end
end

--用户处理特殊需求,没有可以不写此方法
function vipRechargeDialog:doUserHandler()
    local descBg = LuaCCScale9Sprite:createWithSpriteFrameName("vrInfoBg.png", CCRect(39, 39, 2, 2), function ()end)
    descBg:setContentSize(CCSizeMake(612, self.vrInfoBgHeight))
    descBg:setPosition(ccp(self.bgLayer:getContentSize().width / 2, G_VisibleSizeHeight - self.adHeight - self.vrInfoBgHeight / 2 - 92))
    self.bgLayer:addChild(descBg)
    self.vrInfoBgSp = descBg
    
    local function gotoVip(tag, object)
        if G_checkClickEnable() == false then
            do
                return
            end
        end
        if newGuidMgr:isNewGuiding() then
            do return end
        end
        -- require "luascript/script/game/scene/gamedialog/vipDialog"
        -- local vd1 = vipDialog:new();
        -- local vd = vd1:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("vipTitle"),true,self.layerNum+1);
        -- sceneGame:addChild(vd,self.layerNum+1);
        vipVoApi:openVipDialog(self.layerNum + 1)
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local textSize = 25
    if platCfg.platCfgBMImage[G_curPlatName()] ~= nil then
        textSize = 20
    end
    local btnScale = 0.7
    self.gotoVipBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", gotoVip, nil, getlocal("gotoVip"), 26, 100);
    self.gotoVipBtn:setScale(btnScale)
    local lb = self.gotoVipBtn:getChildByTag(100)
    if lb then
        lb = tolua.cast(lb, "CCLabelTTF")
        lb:setFontName("Helvetica-bold")
    end
    -- self.gotoVipBtn:setPosition(1,0)
    -- self.gotoVipBtn:setAnchorPoint(CCPointMake(0,0))
    local gotoVipBtnMenu = CCMenu:createWithItem(self.gotoVipBtn)
    gotoVipBtnMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    gotoVipBtnMenu:setPosition(ccp(descBg:getContentSize().width - self.gotoVipBtn:getContentSize().width * btnScale / 2 - 10, descBg:getContentSize().height / 2))
    descBg:addChild(gotoVipBtnMenu)
    
    local function rechargeHandler(tag, object)
        if G_checkClickEnable() == false then
            do
                return
            end
        end
        self:realRechargeHandler(tag, object)
    end
    
    if G_curPlatName() == "qihoo" then
        self.rechargeBtn = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", rechargeHandler, nil, getlocal("recharge"), 24, 100);
    else
        self.rechargeBtn = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", rechargeHandler, nil, getlocal("recharge"), 24, 100);
    end
    local lb = self.rechargeBtn:getChildByTag(100)
    if lb then
        lb = tolua.cast(lb, "CCLabelTTF")
        lb:setFontName("Helvetica-bold")
    end
    local flag, status, rlimit = healthyApi:getHealthyRechargeStatus()
    if flag == false and status == 0 then --游客或不满8周岁的玩家不提供充值服务
        self.rechargeBtn:setEnabled(false)
    end
    --self.rechargeBtn:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.rechargeBtn:getContentSize().height/2+20))
    local rechargeBtnMenu = CCMenu:createWithItem(self.rechargeBtn)
    rechargeBtnMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    rechargeBtnMenu:setPosition(ccp(self.bgLayer:getContentSize().width / 2, self.rechargeBtn:getContentSize().height / 2 + 20))
    
    local thirdRechargeBtn, thirdRechargeBtnMenu
    if((G_curPlatName() == "androidzhongshouyouru" and playerVoApi:getPlayerLevel() >= 10 and G_Version >= 2) or vipVoApi:checkThirdPayExists() == true)then --俄罗斯安卓 或 有第三方支付权限
        rechargeBtnMenu:setPosition(ccp(self.bgLayer:getContentSize().width / 4, self.rechargeBtn:getContentSize().height / 2 + 20))
        local function thirdRecharge(tag, object)
            if(G_curPlatName() == "androidzhongshouyouru")then
                rechargeHandler(tag, object)
            else
                self:thirdRechargeHandler()
            end
        end
        thirdRechargeBtn = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", thirdRecharge, 333, getlocal("otherMethodForRecharge"), 24, 100);
        thirdRechargeBtnMenu = CCMenu:createWithItem(thirdRechargeBtn)
        thirdRechargeBtnMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
        thirdRechargeBtnMenu:setPosition(ccp(self.bgLayer:getContentSize().width * 3 / 4, self.rechargeBtn:getContentSize().height / 2 + 20))
        self.bgLayer:addChild(thirdRechargeBtnMenu)
        local lb = thirdRechargeBtn:getChildByTag(100)
        if lb then
            lb = tolua.cast(lb, "CCLabelTTF")
            lb:setFontName("Helvetica-bold")
        end
    end
    -- if G_curPlatName() == "androidsevenga" or G_curPlatName() == "11" or G_curPlatName() == "0" then
    --     local btnScale, priority = 0.7, -(self.layerNum - 1) * 20 - 4
    --     --德国新增Paypal支付
    --     local function paypal()
    --         self:thirdRechargeHandler(1)
    --     end
    --     local paypalBtn, paypalMenu = G_createBotton(self.bgLayer, ccp(G_VisibleSizeWidth / 2, self.rechargeBtn:getContentSize().height / 2 + 20), {getlocal("paypal"), 24}, "creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", paypal, 1, priority)
    --     paypalBtn:setScale(btnScale)
    --     self.rechargeBtn:setScale(btnScale)
    --     if thirdRechargeBtn and thirdRechargeBtnMenu then
    --         rechargeBtnMenu:setPositionX(G_VisibleSizeWidth / 2 - 180)
    --         thirdRechargeBtn:setScale(btnScale)
    --         thirdRechargeBtnMenu:setPositionX(G_VisibleSizeWidth / 2 + 180)
    --     else
    --         paypalMenu:setPositionX(G_VisibleSizeWidth * 3 / 4)
    --         rechargeBtnMenu:setPositionX(G_VisibleSizeWidth / 4)
    --     end
    -- end
    if G_curPlatName() == "efunandroiddny" and G_Version >= 2 then --东南亚
        local thetmpTb = {}
        thetmpTb["action"] = "getChannel"
        local thecjson = G_Json.encode(thetmpTb)
        local thechannelid = G_accessCPlusFunction(thecjson)
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/dnyBtn.plist")
        
        if thechannelid == "19" then
            
            self.rechargeBtn = GetButtonItem("dnyBtn.png", "dnyBtn.png", "dnyBtn.png", rechargeHandler, nil, "Pay by MOLPoints", 28);
            --self.rechargeBtn:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.rechargeBtn:getContentSize().height/2+20))
            rechargeBtnMenu = CCMenu:createWithItem(self.rechargeBtn)
            rechargeBtnMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
            
            rechargeBtnMenu:setPosition(ccp(self.bgLayer:getContentSize().width / 4, self.rechargeBtn:getContentSize().height / 2 + 20))
            local thirdRechargeBtn = GetButtonItem("dnyBtn.png", "dnyBtn.png", "dnyBtn.png", rechargeHandler, 333, "Redeem MOLPoints Card($0.99=60 Gold)", 28);
            self.tv:setPosition(ccp(999999, 666666))
            
            local y1 = 250
            local y2 = 350
            --          if self.isFirstRecharge==true then
            -- local firstRechargeBg=self:initFirstRecharge()
            -- firstRechargeBg:setPosition(ccp(G_VisibleSize.width/2,G_VisibleSize.height-350))
            -- self.bgLayer:addChild(firstRechargeBg,1)
            -- y1 = 550
            --          y2 = 650
            -- end
            
            local thirdRechargeBtnMenu = CCMenu:createWithItem(thirdRechargeBtn)
            thirdRechargeBtnMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
            thirdRechargeBtnMenu:setPosition(ccp(self.bgLayer:getContentSize().width * 3 / 4, self.rechargeBtn:getContentSize().height / 2 + 20))
            self.bgLayer:addChild(thirdRechargeBtnMenu)
            
            rechargeBtnMenu:setPosition(ccp(self.bgLayer:getContentSize().width / 2, self.bgLayer:getContentSize().height - y1))
            thirdRechargeBtnMenu:setPosition(ccp(self.bgLayer:getContentSize().width / 2, self.bgLayer:getContentSize().height - y2))
            
        elseif thechannelid == "2" or thechannelid == "14" or thechannelid == "15" then
            rechargeBtnMenu:setPosition(ccp(self.bgLayer:getContentSize().width / 4, self.rechargeBtn:getContentSize().height / 2 + 20))
            local thirdRechargeBtn = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn_Down.png", rechargeHandler, 333, getlocal("otherMethodForRecharge"), 28);
            
            local thirdRechargeBtnMenu = CCMenu:createWithItem(thirdRechargeBtn)
            thirdRechargeBtnMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
            thirdRechargeBtnMenu:setPosition(ccp(self.bgLayer:getContentSize().width * 3 / 4, self.rechargeBtn:getContentSize().height / 2 + 20))
            self.bgLayer:addChild(thirdRechargeBtnMenu)
        end
    end
    
    self.bgLayer:addChild(rechargeBtnMenu)
    
    --    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
    -- lineSp:setScale(self.bgLayer:getContentSize().width/lineSp:getContentSize().width)
    -- lineSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-205-self.heightSpace))
    -- self.bgLayer:addChild(lineSp,1)
    
    self:tick()
end

function vipRechargeDialog:realRechargeHandler(tag, object, selectIdx)
    G_statisticsAuditRecord(AuditOp.RECHARGE) --点击充值按钮
    if (G_curPlatName() == "21" and G_Version == 22) then --阿拉伯平台ios版本G_Version==22的包不允许充值
        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("arab_recharge_unavailable"), nil, 8)
        do return end
    end
    local selectIndex
    if selectIdx then
        selectIndex = selectIdx
    else
        selectIndex = self.selectIndex
    end
    if selectIndex and selectIndex == 0 then
        PlayEffect(audioCfg.mouseClick)
        vipVoApi:buyMonthlyCard(self.layerNum)
        do return end
    end
    
    if G_getPlatAppID() == 10315 or G_getPlatAppID() == 10215 or G_getPlatAppID() == 10615 or G_getPlatAppID() == 11815 or G_getPlatAppID() == 1028 then
        local url = "http://tank-android-01.raysns.com/tankheroclient/clickpage.php?uid=" .. (playerVoApi:getUid() == nil and 0 or playerVoApi:getUid()) .. "&appid="..G_getPlatAppID() .. "&tm="..base.serverTime.."&tp=btn"
        HttpRequestHelper:sendAsynHttpRequest(url, "")
        
    end
    
    local curPlatformName = G_curPlatName()
    
    -- if curPlatformName=="androidkunlun" then
    --    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("betaNoRecharge"),28)
    
    --     do
    --         return
    --     end
    -- end
    
    if base.isPayOpen == 0 then
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("betaNoRecharge"), 28)
        
        do
            return
        end
        
    end
    
    local tmpStoreCfg = G_getPlatStoreCfg()
    global.rechargeFailedNoticed = false --如果充值失败了是否要弹出失败面板 false:弹出  true:不弹
    local sortCfg = self.indexSort
    if sortCfg[selectIndex] then
        --统计充值
        local mPrice = tmpStoreCfg["money"][self.moneyName][selectIndex]
        local flag, status, rlimit = healthyApi:getHealthyRechargeStatus(mPrice)
        if flag == false then
            local str = getlocal("healthy_recharge_tip"..status, {rlimit})
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("healthy_tip"), str, nil, 8)
            do return end
        end
        local moneyName
        if((G_curPlatName() == "11" and G_Version >= 11) or (G_curPlatName() == "androidsevenga" and G_Version >= 16))then
            moneyName = self.moneyName
        end
        if G_judgeEncryption(selectIndex, mPrice, moneyName) == true then
            do return end
        end
        statisticsHelper:recharge("orderId", tonumber(mPrice), tonumber(sortCfg[selectIndex]), "appStore")
        CCUserDefault:sharedUserDefault():setStringForKey("UserOrderInfo", mPrice..","..sortCfg[selectIndex])
        CCUserDefault:sharedUserDefault():flush()
        
        if PlatformManage ~= nil then --判断是否存在PlatformManage类
            if G_isIOS() then
                if(base.webpageRecharge == 1)then
                    local tmpTb = {}
                    tmpTb["action"] = "openUrl"
                    tmpTb["parms"] = {}
                    local platID = G_getUserPlatID()
                    if G_curPlatName() ~= "51" then
                        local index = string.find(platID, "_")
                        if(index)then
                            platID = string.sub(platID, index + 1)
                        else
                            platID = nil
                        end
                    end
              
                    local url = "http://"..base.serverUserIp
                    if(G_curPlatName() == "androidsevenga" or G_curPlatName() == "11")then
                        local mPrice = tostring(tmpStoreCfg["money"][self.moneyName][tonumber(selectIndex)])
                        local goldNum = tmpStoreCfg["gold"][tonumber(selectIndex)]
                        local orderID = playerVoApi:getUid() .. "_"..base.curZoneID.."_ios_"..playerVoApi:getPlayerLevel() .. "_"..playerVoApi:getVipLevel() .. "_"..base.serverTime.."_"..platID.."_"..sortCfg[selectIndex] .. "_0_"..mPrice
                        local productID = "tksvg_gold_"..tostring(tonumber(sortCfg[selectIndex]) + 10)
                        url = url.."/tank_rayapi/index.php/tank_rayapi/iosmovga3thpayBegin?game_server_id="..base.curZoneID.."&game_user_id="..playerVoApi:getUid() .. "&game_user_name="..playerVoApi:getPlayerName() .. "&mobile=1&country="..string.upper(G_country) .. "&currency="..self.moneyName.."&amount="..mPrice.."&game_coin_amout="..goldNum.."&product_id="..productID.."&platform_user_id="..platID.."&game_orderid="..orderID
                    else
                        local zoneID
                        if(base.curOldZoneID and base.curOldZoneID ~= 0 and base.curOldZoneID ~= "0" and base.curOldZoneID ~= "")then
                            zoneID = base.curOldZoneID
                        else
                            zoneID = base.curZoneID
                        end
                        -- url = url.."/tank_rayapi/index.php/iapppayweb?game_user_id="..playerVoApi:getUid() .. "&zoneid="..zoneID.."&itemid="..sortCfg[selectIndex] .. "&channel="..G_curPlatName() .. "&os=ios"
                        -- if(platID)then
                        --     url = url.."&platform_user_id="..platID
                        -- end
                        --由于爱贝被查，该支付废弃，暂时接入雷神天津那边的微信支付宝网页支付
                        url = "http://gd-weiduan-sdk02.leishenhuyu.com/rsdk-base-server/pay/create_order/1010001000/h5rgame-1010001001/v1"
                        local productId = sortCfg[selectIndex]
                        local productName = HttpRequestHelper:URLEncode(getlocal("tk_gold_"..productId.."_desc"))
                        local mPrice = tostring(tmpStoreCfg["money"][self.moneyName][tonumber(selectIndex)])
                        local goldNum = tmpStoreCfg["gold"][tonumber(selectIndex)]
                        local channelId = G_curPlatName() .. "___"..G_getServerPlatId() --渠道名和平台名，G_getServerPlatId是sdk那边区分域名用
                        -- if G_getServerPlatId()=="fl_yueyu" then --越狱平台老包因为“|”问题有些包打不开链接
                        --     -- productName = goldNum.."gold"
                        --     channelId = G_curPlatName().."___"..G_getServerPlatId()
                        -- end
                        if tonumber(playerVoApi:getUid()) == 1000000487 and tonumber(base.curZoneID) == 1000 then --测试账号
                            mPrice = 1.00
                        end
                        local params = "product_id="..productId.."&game_server_id="..zoneID.."&product_count=1" .. "&product_name="..productName.."&platform_user_id=" .. (platID or "") .. "&game_user_id="..playerVoApi:getUid() .. "&private_data="..channelId.."&cost="..mPrice.."&coin_num="..goldNum.."&os=h5&product_type=gold" .. "&wares_id=1&nonce_str="..tostring(G_getCurDeviceMillTime())
                        url = url .. "?" .. params
                    end
                    tmpTb["parms"]["url"] = url
                    local cjson = G_Json.encode(tmpTb)
                    G_accessCPlusFunction(cjson)
                    
                elseif curPlatformName == "0" or curPlatformName == "2" or curPlatformName == "5" or curPlatformName == "45" or curPlatformName == "48" or curPlatformName == "58" or curPlatformName == "60" then --为0 是appstore平台支付 2:yeahmobi
                    if(base.isPay1Open == 1)then
                        local productName = getlocal("tk_gold_"..sortCfg[selectIndex] .. "_desc")
                        local mPrice = tonumber(tmpStoreCfg["money"][self.moneyName][tonumber(selectIndex)])
                        local platLanTb = platCfg.platCfgStoreDesc[G_curPlatName()]
                        if platLanTb ~= nil then
                            productName = getlocal("daily_award_tip_3", {localCfg["gold"][selectIndex]})
                        end
                        
                        local buy_ext1 = ""
                        local buy_ext2 = ""
                        local buy_ext3 = ""
                        
                        local itemId = "tk_gold_"..sortCfg[selectIndex]
                        local tmpTb = {}
                        tmpTb["action"] = "3thpay"
                        tmpTb["parms"] = {}
                        tmpTb["parms"]["itemIndex"] = sortCfg[selectIndex]
                        tmpTb["parms"]["itemid"] = itemId
                        tmpTb["parms"]["name"] = productName
                        tmpTb["parms"]["desc"] = ""
                        tmpTb["parms"]["price"] = mPrice
                        tmpTb["parms"]["count"] = 1
                        tmpTb["parms"]["pic"] = ""
                        tmpTb["parms"]["zoneid"] = tostring(base.curZoneID)
                        tmpTb["parms"]["currency"] = self.moneyName
                        tmpTb["parms"]["ext1"] = buy_ext1
                        tmpTb["parms"]["ext2"] = buy_ext2
                        tmpTb["parms"]["ext3"] = buy_ext3
                        local cjson = G_Json.encode(tmpTb)
                        G_accessCPlusFunction(cjson)
                    else
                        AppStorePayment:shared():buyItemByType(tonumber(sortCfg[selectIndex]))
                    end
                elseif base.isPay1Open == 1 and (curPlatformName == "41" or curPlatformName == "20" or curPlatformName == "50" or curPlatformName == "31" or curPlatformName == "62") then
                    local productName = getlocal("tk_gold_"..sortCfg[selectIndex] .. "_desc")
                    local mPrice = tonumber(tmpStoreCfg["money"][self.moneyName][tonumber(selectIndex)])
                    local platLanTb = platCfg.platCfgStoreDesc[G_curPlatName()]
                    if platLanTb ~= nil then
                        productName = getlocal("daily_award_tip_3", {localCfg["gold"][selectIndex]})
                    end
                    
                    local buy_ext1 = ""
                    local buy_ext2 = ""
                    local buy_ext3 = ""
                    
                    local itemId = "tk_gold_"..sortCfg[selectIndex]
                    local tmpTb = {}
                    tmpTb["action"] = "3thpay"
                    tmpTb["parms"] = {}
                    tmpTb["parms"]["itemIndex"] = sortCfg[selectIndex]
                    tmpTb["parms"]["itemid"] = itemId
                    tmpTb["parms"]["name"] = productName
                    tmpTb["parms"]["desc"] = ""
                    tmpTb["parms"]["price"] = mPrice
                    tmpTb["parms"]["count"] = 1
                    tmpTb["parms"]["pic"] = ""
                    tmpTb["parms"]["zoneid"] = tostring(base.curZoneID)
                    tmpTb["parms"]["currency"] = self.moneyName
                    tmpTb["parms"]["ext1"] = buy_ext1
                    tmpTb["parms"]["ext2"] = buy_ext2
                    tmpTb["parms"]["ext3"] = buy_ext3
                    local cjson = G_Json.encode(tmpTb)
                    G_accessCPlusFunction(cjson)
                    
                elseif curPlatformName == "1" or curPlatformName == "42" then --为1 是快用平台支付
                    if base.platformUserId ~= nil then
                        local guidStr = Split(base.platformUserId, "_")[2]
                        local itemId = tostring(sortCfg[selectIndex])
                        local itemDesc = getlocal("tk_gold_"..itemId.."_desc")
                        local gameUid = tostring(playerVoApi:getUid())
                        local mPrice = tonumber(tmpStoreCfg["money"][self.moneyName][tonumber(selectIndex)])
                        local tmpTb = {}
                        tmpTb["action"] = "buyItemByNewKY"
                        tmpTb["parms"] = {}
                        tmpTb["parms"]["fee"] = tostring(mPrice)
                        tmpTb["parms"]["subject"] = itemDesc
                        tmpTb["parms"]["itemid"] = itemId
                        local cjson = G_Json.encode(tmpTb)
                        G_accessCPlusFunction(cjson)
                    end
                elseif curPlatformName == "3" or curPlatformName == "4" then --3 是EFUNios平台支付
                    PlatformManage:shared():buyItemByType(tonumber(sortCfg[selectIndex]))
                elseif curPlatformName == "6" then --91
                    local itemId = "tk_gold_"..sortCfg[selectIndex]
                    local platLanTb = platCfg.platCfgStoreDesc[G_curPlatName()]
                    local productName = getlocal("tk_gold_"..sortCfg[selectIndex] .. "_desc")
                    if platLanTb ~= nil then
                        productName = getlocal("daily_award_tip_3", {G_getPlatStoreCfg()["gold"][selectIndex]})
                    end
                    
                    local mPrice = tonumber(tmpStoreCfg["money"][self.moneyName][tonumber(selectIndex)])
                    
                    local tmpTb = {}
                    tmpTb["action"] = "buyItemByProductId91"
                    tmpTb["parms"] = {}
                    tmpTb["parms"]["productId"] = itemId
                    tmpTb["parms"]["productName"] = productName
                    tmpTb["parms"]["price"] = mPrice
                    local cjson = G_Json.encode(tmpTb)
                    G_accessCPlusFunction(cjson)
                elseif curPlatformName == "7" then --pp
                    local productName = getlocal("tk_gold_"..sortCfg[selectIndex] .. "_desc")
                    local mPrice = tonumber(tmpStoreCfg["money"][self.moneyName][tonumber(selectIndex)])
                    local platLanTb = platCfg.platCfgStoreDesc[G_curPlatName()]
                    if platLanTb ~= nil then
                        productName = getlocal("daily_award_tip_3", {localCfg["gold"][selectIndex]})
                    end
                    
                    local tmpTb = {}
                    tmpTb["action"] = "buyItemByPricePP"
                    tmpTb["parms"] = {}
                    tmpTb["parms"]["price"] = mPrice
                    tmpTb["parms"]["billTitle"] = productName
                    tmpTb["parms"]["itemId"] = tostring(sortCfg[selectIndex])
                    tmpTb["parms"]["zoneid"] = base.curOldZoneID
                    
                    local cjson = G_Json.encode(tmpTb)
                    G_accessCPlusFunction(cjson)
                elseif curPlatformName == "8" or curPlatformName == "70" then --TBT
                    local productName = getlocal("tk_gold_"..sortCfg[selectIndex] .. "_desc")
                    local mPrice = tonumber(tmpStoreCfg["money"][self.moneyName][tonumber(selectIndex)])
                    local platLanTb = platCfg.platCfgStoreDesc[G_curPlatName()]
                    if platLanTb ~= nil then
                        productName = getlocal("daily_award_tip_3", {localCfg["gold"][selectIndex]})
                    end
                    local tmpTb = {}
                    tmpTb["action"] = "buyItemByPriceTBT"
                    tmpTb["parms"] = {}
                    tmpTb["parms"]["price"] = mPrice
                    tmpTb["parms"]["desc"] = productName
                    tmpTb["parms"]["itemId"] = tostring(sortCfg[selectIndex])
                    
                    local cjson = G_Json.encode(tmpTb)
                    G_accessCPlusFunction(cjson)
                elseif curPlatformName == "9" or curPlatformName == "10" then --飞流越狱
                    local productName = getlocal("tk_gold_"..sortCfg[selectIndex] .. "_desc")
                    local platLanTb = platCfg.platCfgStoreDesc[G_curPlatName()]
                    if platLanTb ~= nil then
                        productName = getlocal("daily_award_tip_3", {localCfg["gold"][selectIndex]})
                    end
                    local mPrice = tonumber(tmpStoreCfg["money"][self.moneyName][tonumber(selectIndex)])
                    local tmpTb = {}
                    tmpTb["action"] = "buyItemByPriceFeiliu"
                    tmpTb["parms"] = {}
                    tmpTb["parms"]["price"] = mPrice * 100 --飞流是以分为单位 所以*100
                    tmpTb["parms"]["desc"] = productName
                    tmpTb["parms"]["itemId"] = tostring(sortCfg[selectIndex])
                    
                    local cjson = G_Json.encode(tmpTb)
                    G_accessCPlusFunction(cjson)
                elseif curPlatformName == "66" then --fl-app新渠道包提审用appstore支付，之后会切换为网页支付
                    AppStorePayment:shared():buyItemByType(tonumber(sortCfg[selectIndex]))
                else
                    if platCfg.platSureBuy[G_curPlatName()] ~= nil then
                        
                        local function callBack()
                            deviceHelper:luaPrint("ios common buy start");
                            
                            local productName = getlocal("tk_gold_"..sortCfg[selectIndex] .. "_desc")
                            local mPrice = tonumber(tmpStoreCfg["money"][self.moneyName][tonumber(selectIndex)])
                            local platLanTb = platCfg.platCfgStoreDesc[G_curPlatName()]
                            if platLanTb ~= nil then
                                productName = getlocal("daily_award_tip_3", {localCfg["gold"][selectIndex]})
                            end
                            
                            local buy_ext1 = ""
                            local buy_ext2 = ""
                            local buy_ext3 = ""
                            
                            local itemId = "tk_gold_"..sortCfg[selectIndex]
                            
                            local tmpTb = {}
                            tmpTb["action"] = "buyItemByTypeForIOS"
                            tmpTb["parms"] = {}
                            tmpTb["parms"]["itemIndex"] = sortCfg[selectIndex]
                            tmpTb["parms"]["itemid"] = itemId
                            tmpTb["parms"]["name"] = productName
                            tmpTb["parms"]["desc"] = ""
                            tmpTb["parms"]["price"] = mPrice
                            tmpTb["parms"]["count"] = 1
                            tmpTb["parms"]["pic"] = ""
                            if(base.serverPlatID == "fl_yueyu")then
                                tmpTb["parms"]["zoneid"] = tostring(base.curOldZoneID)
                            else
                                tmpTb["parms"]["zoneid"] = tostring(base.curZoneID)
                            end
                            tmpTb["parms"]["currency"] = self.moneyName
                            tmpTb["parms"]["ext1"] = buy_ext1
                            tmpTb["parms"]["ext2"] = buy_ext2
                            tmpTb["parms"]["ext3"] = buy_ext3
                            
                            local cjson = G_Json.encode(tmpTb)
                            deviceHelper:luaPrint("ios common buy parms:"..cjson);
                            
                            G_accessCPlusFunction(cjson)
                            
                            deviceHelper:luaPrint("ios common buy end");
                        end
                        
                        local mType = tmpStoreCfg["moneyType"][self.moneyName]
                        local mPrice = tmpStoreCfg["money"][self.moneyName][tonumber(selectIndex)]
                        local moneyStr = getlocal("buyGemsPrice", {mType, mPrice})
                        if G_curPlatName() == "13" or G_curPlatName() == "androidzsykonaver" or G_curPlatName() == "androidzsykoolleh" or G_curPlatName() == "androidzsykotstore" or G_curPlatName() == "androidzhongshouyouko" or G_isKakao() or G_curPlatName() == "59" or G_curPlatName() == "androidcmge" then
                            moneyStr = getlocal("buyGemsPrice", {mPrice, mType})
                        end
                        
                        --local mPrice=tonumber(tmpStoreCfg["money"][self.moneyName][tonumber(selectIndex)])
                        --local moneyStr=mPrice..self.moneyName
                        
                        local goldNum = tmpStoreCfg["gold"][tonumber(selectIndex)]
                        smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), callBack, getlocal("dialog_title_prompt"), getlocal("sureBuy", {moneyStr, goldNum}), nil, self.layerNum + 1)
                        
                    else
                        
                        deviceHelper:luaPrint("ios common buy start");
                        
                        local productName = getlocal("tk_gold_"..sortCfg[selectIndex] .. "_desc")
                        local mPrice = tonumber(tmpStoreCfg["money"][self.moneyName][tonumber(selectIndex)])
                        local platLanTb = platCfg.platCfgStoreDesc[G_curPlatName()]
                        if platLanTb ~= nil then
                            productName = getlocal("daily_award_tip_3", {localCfg["gold"][selectIndex]})
                        end
                        
                        local buy_ext1 = ""
                        local buy_ext2 = ""
                        local buy_ext3 = ""
                        local itemId
                        if(G_curPlatName() == "66")then
                            itemId = "hj_gold_"..sortCfg[selectIndex]
                        else
                            itemId = "tk_gold_"..sortCfg[selectIndex]
                        end
                        local tmpTb = {}
                        tmpTb["action"] = "buyItemByTypeForIOS"
                        tmpTb["parms"] = {}
                        tmpTb["parms"]["itemIndex"] = sortCfg[selectIndex]
                        tmpTb["parms"]["itemid"] = itemId
                        tmpTb["parms"]["name"] = productName
                        tmpTb["parms"]["desc"] = ""
                        tmpTb["parms"]["price"] = mPrice
                        tmpTb["parms"]["count"] = 1
                        tmpTb["parms"]["pic"] = ""
                        if(base.serverPlatID == "fl_yueyu")then
                            tmpTb["parms"]["zoneid"] = tostring(base.curOldZoneID)
                        else
                            tmpTb["parms"]["zoneid"] = tostring(base.curZoneID)
                        end
                        tmpTb["parms"]["currency"] = self.moneyName
                        tmpTb["parms"]["ext1"] = buy_ext1
                        tmpTb["parms"]["ext2"] = buy_ext2
                        tmpTb["parms"]["ext3"] = buy_ext3
                        
                        local cjson = G_Json.encode(tmpTb)
                        deviceHelper:luaPrint("ios common buy parms:"..cjson);
                        
                        G_accessCPlusFunction(cjson)
                        
                        deviceHelper:luaPrint("ios common buy end");
                    end
                end
                
            else
                if(base.webpageRecharge == 1)then
                    local tmpTb = {}
                    tmpTb["action"] = "openUrl"
                    tmpTb["parms"] = {}
                    local platID = G_getUserPlatID()
                    local index = string.find(platID, "_")
                    if(index)then
                        platID = string.sub(platID, index + 1)
                    else
                        platID = nil
                    end
                    local url = "http://"..base.serverUserIp
                    if(G_curPlatName() == "androidsevenga" or G_curPlatName() == "11")then
                        local mPrice = tostring(tmpStoreCfg["money"][self.moneyName][tonumber(selectIndex)])
                        local goldNum = tmpStoreCfg["gold"][tonumber(selectIndex)]
                        local orderID = playerVoApi:getUid() .. "_"..base.curZoneID.."_ios_"..playerVoApi:getPlayerLevel() .. "_"..playerVoApi:getVipLevel() .. "_"..base.serverTime.."_"..platID.."_"..sortCfg[selectIndex] .. "_0_"..mPrice
                        local productID = "tk_gold_"..tostring(tonumber(sortCfg[selectIndex]) + 10)
                        url = url.."/tank_rayapi/index.php/tank_rayapi/androidmovga3thpayBegin?game_server_id="..base.curZoneID.."&game_user_id="..playerVoApi:getUid() .. "&game_user_name="..playerVoApi:getPlayerName() .. "&mobile=1&country="..string.upper(G_country) .. "&currency="..self.moneyName.."&amount="..mPrice.."&game_coin_amout="..goldNum.."&product_id="..productID.."&platform_user_id="..platID.."&game_orderid="..orderID
                    else
                        local zoneID
                        if(base.curOldZoneID and base.curOldZoneID ~= 0 and base.curOldZoneID ~= "0" and base.curOldZoneID ~= "")then
                            zoneID = base.curOldZoneID
                        else
                            zoneID = base.curZoneID
                        end
                        -- url = url.."/tank_rayapi/index.php/iapppayweb?game_user_id="..playerVoApi:getUid() .. "&zoneid="..zoneID.."&itemid="..sortCfg[selectIndex] .. "&channel="..G_curPlatName() .. "&os=ios"
                        -- if(platID)then
                        --     url = url.."&platform_user_id="..platID
                        -- end
                        --由于爱贝被查，该支付废弃，暂时接入雷神天津那边的微信支付宝网页支付
                        url = "http://gd-weiduan-sdk02.leishenhuyu.com/rsdk-base-server/pay/create_order/1010001000/h5rgame-1010001001/v1"
                        local productId = sortCfg[selectIndex]
                        local productName = HttpRequestHelper:URLEncode(getlocal("tk_gold_"..productId.."_desc"))
                        local mPrice = tostring(tmpStoreCfg["money"][self.moneyName][tonumber(selectIndex)])
                        local goldNum = tmpStoreCfg["gold"][tonumber(selectIndex)]
                        local channelId = G_curPlatName() .. "___"..G_getServerPlatId() --渠道名和平台名，G_getServerPlatId是sdk那边区分域名用
                        local params = "product_id="..productId.."&game_server_id="..zoneID.."&product_count=1" .. "&product_name="..productName.."&platform_user_id=" .. (platID or "") .. "&game_user_id="..playerVoApi:getUid() .. "&private_data="..channelId.."&cost="..mPrice.."&coin_num="..goldNum.."&os=h5&product_type=gold" .. "&wares_id=1&nonce_str="..tostring(G_getCurDeviceMillTime())
                        url = url .. "?" .. params
                    end
                    tmpTb["parms"]["url"] = url
                    local cjson = G_Json.encode(tmpTb)
                    G_accessCPlusFunction(cjson)
                elseif platCfg.platSureBuy[G_curPlatName()] ~= nil then
                    
                    local function callBack()
                        local ext1 = ""
                        if curPlatformName == "efunandroidtw" or curPlatformName == "efunandroiddny" then
                            local shopItemArr = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"}
                            ext1 = "pay"..shopItemArr[tonumber(sortCfg[selectIndex])]
                        end
                        local itemId = "tk_gold_"..sortCfg[selectIndex]
                        local itemDesc = getlocal(itemId.."_desc")
                        local mPrice = tmpStoreCfg["money"][self.moneyName][tonumber(selectIndex)]
                        
                        local platLanTb = platCfg.platCfgStoreDesc[G_curPlatName()]
                        if platLanTb ~= nil then
                            itemDesc = getlocal("daily_award_tip_3", {G_getPlatStoreCfg()["gold"][selectIndex]})
                        end
                        
                        local theGoldNum = tmpStoreCfg["gold"][selectIndex]
                        ext2 = theGoldNum
                        if tag == 333 then --俄罗斯安卓第三方支付按钮
                            if curPlatformName == "efunandroiddny" then
                                ext2 = "1"
                            else
                                ext1 = "1"
                            end
                            
                        end
                        
                        AppStorePayment:shared():buyItemByTypeForAndroid(itemId, itemDesc, "", mPrice, 1, "", base.curZoneID, ext1, ext2);
                    end
                    
                    local mType = tmpStoreCfg["moneyType"][self.moneyName]
                    local mPrice = tmpStoreCfg["money"][self.moneyName][tonumber(selectIndex)]
                    local moneyStr = getlocal("buyGemsPrice", {mType, mPrice})
                    if G_curPlatName() == "13" or G_curPlatName() == "androidzsykonaver" or G_curPlatName() == "androidzsykoolleh" or G_curPlatName() == "androidzsykotstore" or G_curPlatName() == "androidzhongshouyouko" or G_isKakao() or G_curPlatName() == "59" or G_curPlatName() == "androidcmge" then
                        moneyStr = getlocal("buyGemsPrice", {mPrice, mType})
                    end
                    --local mPrice=tonumber(tmpStoreCfg["money"][self.moneyName][tonumber(selectIndex)])
                    --local moneyStr=mPrice..self.moneyName
                    
                    local goldNum = tmpStoreCfg["gold"][tonumber(selectIndex)]
                    smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), callBack, getlocal("dialog_title_prompt"), getlocal("sureBuy", {moneyStr, goldNum}), nil, self.layerNum + 1)
                    
                else
                    
                    local ext1 = ""
                    if curPlatformName == "efunandroidtw" or curPlatformName == "efunandroiddny" then
                        local shopItemArr = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"}
                        ext1 = "pay"..shopItemArr[tonumber(sortCfg[selectIndex])]
                    end
                    local itemId = "tk_gold_"..sortCfg[selectIndex]
                    local itemDesc = getlocal(itemId.."_desc")
                    local mPrice = tmpStoreCfg["money"][self.moneyName][tonumber(selectIndex)]
                    
                    local platLanTb = platCfg.platCfgStoreDesc[G_curPlatName()]
                    if platLanTb ~= nil then
                        itemDesc = getlocal("daily_award_tip_3", {G_getPlatStoreCfg()["gold"][selectIndex]})
                    end
                    
                    local theGoldNum = tmpStoreCfg["gold"][selectIndex]
                    local ext2 = theGoldNum
                    if tag == 333 then --俄罗斯安卓第三方支付按钮
                        if curPlatformName == "efunandroiddny" then
                            ext2 = "1"
                        else
                            ext1 = "1"
                        end
                        
                    end
                    local curZid = G_mappingZoneid()
                    
                    --if  curPlatformName=="androidnjyidong2" then
                    if base.curOldZoneID ~= nil and base.curOldZoneID ~= 0 and base.curOldZoneID ~= "0" then
                        curZid = base.curOldZoneID
                        if G_curPlatName() == "qihoo" or G_curPlatName() == "androidqihoohjdg" then
                            if tonumber(base.curZoneID) >= 220 and tonumber(base.curZoneID) < 1000 then
                                do
                                    curZid = tostring(tonumber(base.curOldZoneID) - 94)
                                end
                            end
                            if tonumber(base.curZoneID) == 1000 or tonumber(base.curZoneID) == 997 or tonumber(base.curZoneID) == 998 then
                                curZid = base.curOldZoneID
                            end
                        end
                    end
                    --end
                    AppStorePayment:shared():buyItemByTypeForAndroid(itemId, itemDesc, "", mPrice, 1, "", curZid, ext1, ext2);
                    
                end
                
            end
        else
            AppStorePayment:shared():buyItemByType(tonumber(sortCfg[selectIndex]))
        end
        
        PlayEffect(audioCfg.mouseClick)
    end
end

function vipRechargeDialog:thirdRechargeHandler()
    if(G_curPlatName() == "0" or G_curPlatName() == "androidsevenga" or G_curPlatName() == "11")then
        require "luascript/script/game/scene/gamedialog/vip/vipThirdPayDialog"
        local vrd = vipThirdPayDialog:new()
        local vd = vrd:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), {}, nil, nil, getlocal("buyGemsTiTle"), false, self.layerNum + 1)
        if vd ~= nil then
            sceneGame:addChild(vd, self.layerNum + 1)
        end
    end
end

function vipRechargeDialog:tick()
    if self.gems ~= playerVoApi:getGems() and self.vrInfoBgSp then
        self.gems = playerVoApi:getGems()
        -- local vipRechargeStr = getlocal("have")..playerVoApi:getGems().."  "..getlocal("curVipLevel",{playerVoApi:getVipLevel()})
        local vipRechargeStr = playerVoApi:getGems() .. "   "..getlocal("curVipLevel", {playerVoApi:getVipLevel()})
        if self.vipRechargeLabel == nil then
            local iconScale = 1
            if self and self.goldIcon then
                self.goldIcon:removeFromParentAndCleanup(true)
            end
            self.goldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
            self.goldIcon:setAnchorPoint(ccp(0, 0.5))
            self.goldIcon:setPosition(ccp(10, self.vrInfoBgHeight - self.goldIcon:getContentSize().height / 2 * iconScale - 5))
            self.goldIcon:setScale(iconScale)
            self.vrInfoBgSp:addChild(self.goldIcon)
            
            -- self.vipRechargeLabel=GetTTFLabelWrap(vipRechargeStr,25,CCSizeMake(25*20, 30*6),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            self.vipRechargeLabel = GetTTFLabel(vipRechargeStr, 20)
            self.vipRechargeLabel:setAnchorPoint(ccp(0, 0.5))
            self.vipRechargeLabel:setPosition(ccp(10 + self.goldIcon:getContentSize().width * iconScale, self.goldIcon:getPositionY()))
            self.vrInfoBgSp:addChild(self.vipRechargeLabel)
        else
            self.vipRechargeLabel:setString(vipRechargeStr)
        end
    end
    
    local buygems = playerVoApi:getBuygems()
    local vipExp = playerVoApi:getVipExp()
    if self.vipExp ~= vipExp and self.vrInfoBgSp then
        self.vipExp = vipExp
        local vipLevel = playerVoApi:getVipLevel()
        local vipLevelCfg = Split(playerCfg.vipLevel, ",")
        local gem4vipCfg = Split(playerCfg.gem4vip, ",")
        local vipStr = ""
        if tostring(vipLevel) == tostring(playerVoApi:getMaxLvByKey("maxVip")) then
            vipStr = getlocal("richMan")
        else
            local nextVip = vipLevel + 1
            local nextGem = gem4vipCfg[nextVip]
            local needGem = nextGem - self.vipExp
            --vipStr = getlocal("currentVip",{vipLevel})
            
            vipStr = vipStr..getlocal("nextVip", {needGem, nextVip})
            
        end
        if self.vipDescLabel == nil then
            local fontSize = 20
            if G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() == "de" then
                fontSize = 18
            end
            self.vipDescLabel = GetTTFLabelWrap(vipStr, fontSize, CCSizeMake(self.vrInfoBgSp:getContentSize().width - 170, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
            self.vipDescLabel:setAnchorPoint(ccp(0, 0.5))
            self.vipDescLabel:setPosition(ccp(16, 5 + self.vipDescLabel:getContentSize().height / 2))
            self.vrInfoBgSp:addChild(self.vipDescLabel, 1)
        else
            self.vipDescLabel:setString(vipStr)
        end
    end
    local gem4vipCfg = Split(playerCfg.gem4vip, ",")
    local nextVip = playerVoApi:getVipLevel() + 1
    local nextGem = gem4vipCfg[nextVip]
    if(nextGem)then
        local needGem = nextGem - self.vipExp
        if needGem < 0 and playerVoApi:getVipLevel() < playerVoApi:getMaxLvByKey("maxVip") then
            local function callback(fn, data)
                local ret, sData = base:checkServerData(data)
                if ret == true then
                    local nextVip = playerVoApi:getVipLevel() + 1
                    local nextGem = gem4vipCfg[nextVip]
                    local needGem = nextGem - self.vipExp
                    local vipStr = ""
                    vipStr = vipStr..getlocal("nextVip", {needGem, nextVip})
                    if tostring(playerVoApi:getVipLevel()) == tostring(playerVoApi:getMaxLvByKey("maxVip")) then
                        vipStr = getlocal("richMan")
                    end
                    if self.vipDescLabel then
                        self.vipDescLabel:setString(vipStr)
                    end
                    if self.vipRechargeLabel then
                        local vipRechargeStr = getlocal("have")..playerVoApi:getGems() .. "  "..getlocal("curVipLevel", {playerVoApi:getVipLevel()})
                        self.vipRechargeLabel:setString(vipRechargeStr)
                    end
                    
                end
            end
            socketHelper:userefvip(callback)
        end
    end
    
    if self.vipLevel and self.vipLevel ~= playerVoApi:getVipLevel() then
        self.vipLevel = playerVoApi:getVipLevel()
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("vipLevelUp", {playerVoApi:getVipLevel()}), 28)
    end
    
    if(base.monthlyCardOpen == 1 and vipVoApi:getMonthlyCardCfg())then
        local leftDays = vipVoApi:getMonthlyCardLeftDays()
        if self.leftDays ~= leftDays then
            self.leftDays = leftDays
            if self and self.tv then
                local recordPoint = self.tv:getRecordPoint()
                self.tv:reloadData()
                self.tv:recoverToRecordPoint(recordPoint)
            end
        end
    end
    
    -- if buygems==0 and self.isFirstRecharge==false then
    -- if self.tv~=nil then
    -- self.isFirstRecharge=true
    -- self.tv:reloadData()
    -- end
    -- elseif buygems>0 and self.isFirstRecharge==true then
    -- if self.tv~=nil then
    -- self.isFirstRecharge=false
    -- self.tv:reloadData()
    -- end
    -- end
end

function vipRechargeDialog:dispose()
    eventDispatcher:removeEventListener("user.pay", self.paymentListener)
    self.isShowMCard = nil
    self.panelLineBg = nil
    self.closeBtn = nil
    self.vipRechargeLabel = nil
    self.firstRechargeLabel = nil
    self.tv = nil
    self.layerNum = nil
    self.gems = nil
    self.selectIndex = nil
    self.vipExp = nil
    self.vipDescLabel = nil
    self.gotoVipBtn = nil
    self.rechargeBtn = nil
    self.isFirstRecharge = nil
    self.topforbidSp = nil
    self.bottomforbidSp = nil
    self.vipLevel = nil
    self.rewardMonthlyBtn = nil
    self.leftDays = nil
    self.goldIcon = nil
    self.iconPicTb = nil
    self.vrInfoBgSp = nil
    self.vrInfoBgHeight = nil
    self.adHeight = nil
    self = nil
    spriteController:removePlist("public/acNewYearsEva.plist")
    spriteController:removePlist("public/vr_rechargeImages.plist")
    spriteController:removeTexture("public/vr_rechargeImages.png")
    if G_checkUseAuditUI() == true then --审核版本部分图替换
        spriteController:removePlist("public/vr_rechargeImagesAudit.plist")
        spriteController:removeTexture("public/vr_rechargeImagesAudit.png")
    end
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acItemBg.plist")
end
