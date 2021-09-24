acHryxTabTwo={}
function acHryxTabTwo:new(parent)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.parent    = parent
	nc.bgLayer   = nil
	nc.isIphone5 = G_isIphone5()

	nc.showLayerTop  = nil                                                                        
	nc.showLayerBg   = nil                                                                           
	nc.timeLb        = nil                                                                                          
	nc.rechargeLb    = nil                                                                              
	nc.buyItemButton = nil                                                                     
	nc.buyLb         = nil                                                                                             
	nc.buyCostIcon   = nil                                                                           
	nc.stateLb       = nil                                                                                       
	nc.lockSp        = nil                                                                                          
	nc.buyState      = 0 -- 0未解锁不可购买，1已购买，2解锁可购买，3充值不足
	nc.showTopY      = G_VisibleSizeHeight - 160
	nc.showTopHeight = 400

	return nc
end
function acHryxTabTwo:dispose( )
	if self.circelAc then
		self.circelAc:stop()
	end
	if self.magnifierSp then
		self.magnifierSp:stopAllActions()
		self.magnifierSp = nil
	end
	if self.buildingAc then
		self.buildingAc:stopAllActions()
		self.buildingAc = nil
	end
	self.bgLayer   = nil
	self.parent    = nil
	self.isIphone5 = nil

	self.showLayerTop  = nil
	self.showLayerBg   = nil
	self.timeLb        = nil
	self.rechargeLb    = nil
	self.buyItemButton = nil
	self.buyLb         = nil
	self.buyCostIcon   = nil
	self.stateLb       = nil
	self.lockSp        = nil
	self.buyState      = 0
	self.shopList      = nil
	self.shopKeyList   = nil
end
function acHryxTabTwo:init(layerNum)
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()
	
	self.shopListCellSize = CCSizeMake(616, 122)
	self.shopList         = acHryxVoApi:getShoplist()
	self.shopKeyList      = acHryxVoApi:getShoplistSortKey()

	self:initTopShow()
	self:initTableView()
	return self.bgLayer
end

function acHryxTabTwo:initTopShow( )
	local showTopY = self.showTopY
    local showTopWidth = G_VisibleSizeWidth
    local showTopHeight = self.showTopHeight
    -- 上边显示Layer
    self.showLayerTop = CCLayer:create()
    self.showLayerTop:ignoreAnchorPointForPosition(false)
    self.showLayerTop:setAnchorPoint(ccp(0.5, 1))
    self.showLayerTop:setContentSize(CCSize(showTopWidth, showTopHeight))
    self.showLayerTop:setPosition(ccp(showTopWidth / 2, showTopY))
    self.bgLayer:addChild(self.showLayerTop)

    -- 背景
    self.showLayerBg = CCLayer:create()
    self.showLayerBg:setPosition(ccp(showTopWidth / 2, showTopHeight / 2))
    self.showLayerTop:addChild(self.showLayerBg)
    -- 网络下载的图
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
    local function onLoadIcon(fn,icon)
        if self and self.showLayerBg and tolua.cast(self.showLayerBg, "CCLayer") then
            icon:setAnchorPoint(ccp(0.5,0.5))
            icon:setPosition(ccp(0, 0))--self.showLayerBg:getContentSize().height))
            self.showLayerBg:addChild(icon)
        end
    end
    local webImage = LuaCCWebImage:createWithURL(G_downloadUrl("active/acHryxImage_tab2.jpg"), onLoadIcon)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    -- 梯形底
    local bgShade = LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png", CCRect(103, 0, 2, 80), function () end)
    bgShade:setContentSize(CCSizeMake(showTopWidth, 80))
    bgShade:setAnchorPoint(ccp(0.5, 1))
    bgShade:setPosition(showTopWidth / 2, showTopHeight)
    self.showLayerTop:addChild(bgShade)

    local function touch(tag, object)
        PlayEffect(audioCfg.mouseClick)
        -- 说明按钮详细
        local tabStr = {}
        local tabColor = {}
        local tabAlignment = {}
        tabStr = {"\n", getlocal("activity_hryx_tab2_tip4"),"\n", getlocal("activity_hryx_tab2_tip3"), "\n", getlocal("activity_hryx_tab2_tip2",{acHryxVoApi:getNeedPlayerLv()}), "\n", getlocal("activity_hryx_tab2_tip1"), "\n"}
        tabColor = {nil, nil, nil, nil, nil, nil}
        tabAlignment = {nil, nil, nil, nil, nil, nil}
        local td=smallDialog:new()
        local dialog=td:init("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10),
            nil, true, true, self.layerNum + 1, tabStr, 25, tabColor, nil, nil, nil, tabAlignment)
        sceneGame:addChild(dialog, self.layerNum + 1)
    end

    local menuItemDesc = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", touch)
    menuItemDesc:setAnchorPoint(ccp(0.5, 0.5))
    local menuDesc = CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
    menuDesc:setPosition(ccp(showTopWidth - 40, showTopHeight - 40))
    self.showLayerTop:addChild(menuDesc)

    local timeLb = GetTTFLabel("", 25)
    timeLb:setAnchorPoint(ccp(0.5, 0))
    timeLb:setPosition(ccp(showTopWidth / 2, showTopHeight - 40))
    -- timeLb:setColor(G_ColorGreen)

    local buildingPic = acHryxVoApi:getCurPicName(2)
    self:showBuildingFunction(buildingPic,self.showLayerTop,ccp(20,15),ccp(0,0),0.7)

    self.showLayerTop:addChild(timeLb)
    self.timeLb = timeLb

    self:updateShowTop(true)
    self:tick()
end

function acHryxTabTwo:initTableView()
	local tvH = self.showTopY - self.showTopHeight - 35
    local function eventHandler( ... )
        return self:eventHandler( ... )
    end
    local hdSize = CCSizeMake(G_VisibleSizeWidth - 50, tvH)
    local hd = LuaEventHandler:createHandler(eventHandler)
    self.tv = LuaCCTableView:createWithEventHandler(hd, hdSize, nil)
    self.tv:setPosition(ccp(25, 20))
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 4)
    self.bgLayer:addChild(self.tv, 2)
    self.tv:setMaxDisToBottomOrTop(120)

    local tableViewBox = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function () end)
    tableViewBox:setContentSize(CCSizeMake(616, hdSize.height + 4))
    tableViewBox:setAnchorPoint(ccp(0.5, 0))
    tableViewBox:setPosition(ccp(G_VisibleSizeWidth / 2, self.tv:getPositionY() - 2))
    self.bgLayer:addChild(tableViewBox)
end

function acHryxTabTwo:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
         return SizeOfTable(self.shopList)
    elseif fn == "tableCellSizeForIndex" then
        return  self.shopListCellSize
    elseif fn == "tableCellAtIndex" then
        local index = self.shopKeyList[idx + 1]
        return self:showShopListCellUI(idx + 1, index)
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
        return true
    elseif fn == "ccTouchMoved" then
        self.isMoved = true
    elseif fn == "ccTouchEnded"  then
    end
end

function acHryxTabTwo:showShopListCellUI(index, idx)
	local showListCfg = self.shopList[idx]
	local rewardData  = showListCfg.reward
	local btnState    = 0 -- 0可购买，1金币不足，2次数达到上限
	local sid         = idx
	local ownGems     = playerVoApi:getGems()
	local price       = acHryxVoApi:getPriceDis(idx)
	local limitNum    = acHryxVoApi:getRd(idx) 
	local limitMax    = showListCfg.bn

    local cell = CCTableViewCell:new()
    cell:autorelease()
    local cellWidth = self.shopListCellSize.width
    local cellHeight = self.shopListCellSize.height

    if index ~= SizeOfTable(self.shopList) then
        local cellLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 1, 1, 1), function () end)
        cellLine:setContentSize(CCSizeMake(cellWidth - 10, cellLine:getContentSize().height))
        cellLine:setPosition(ccp(cellWidth / 2 - 5, 3))
        cell:addChild(cellLine)
    end

    local itemData = nil
    local itemName = ""
    local itemNum = 0
    local strSize = 22
    local adaH = 0
    if G_isAsia() == false then
        strSize = 20
    end
    local reward = FormatItem(rewardData,false,true) or {}
    if reward and next(reward) then
        local v = reward[1]
        itemData = v
        local icon, scale = G_getItemIcon(v, 100, true, self.layerNum + 1, nil, self.tv)
        icon:setPosition(ccp(50, cellHeight / 2))
        icon:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
        cell:addChild(icon, 1)

        local numLabel = GetTTFLabel("x" .. FormatNumber(v.num), strSize)
        numLabel:setAnchorPoint(ccp(1, 0))
        numLabel:setPosition(icon:getContentSize().width - 5, 5)
        numLabel:setScale(1 / scale)
        icon:addChild(numLabel, 1)

        local nameLb = GetTTFLabelWrap(getlocal("activity_wxgx_name", {v.name, limitNum, limitMax}),strSize,CCSizeMake(350,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
        if nameLb:getContentSize().height > 30 then
            adaH = 12
        end
        nameLb:setAnchorPoint(ccp(0, 1))
        nameLb:setPosition(ccp(icon:getPositionX() + 55, cellHeight - 24+adaH))
        nameLb:setScale(1 / scale)
        nameLb:setColor(G_ColorGreen)
        icon:addChild(nameLb)
        local descLb = GetTTFLabelWrap(getlocal(v.desc), (strSize-4) / scale, CCSizeMake(cellWidth - 280, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
        descLb:setPosition(icon:getPositionX() + 55, 78)
        descLb:setAnchorPoint(ccp(0, 1))
        cell:addChild(descLb, 2)

        itemName = v.name
        itemNum = v.num
    end

    local function onBuyCallBack(tag, object)
        if self.tv:getIsScrolled() == true then
            do return end
        end
        PlayEffect(audioCfg.mouseClick)

        if acHryxVoApi:isRewardTime() then
        	G_showTipsDialog(getlocal("activityIsOver"))
        	do return end
        end
            
        if limitNum >= limitMax then
            -- 达到上限
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350),
                CCRect(168, 86, 10, 10), getlocal("activity_wxgx_limitTips"), 30)
            return
        end

        -- 检测金币
        if ownGems < price then
            GemsNotEnoughDialog(nil, nil, price - playerVoApi:getGems(), self.layerNum + 1, price)
            return
        end

        local function sureCallBack(num)
        	local shopNum = num
            if acHryxVoApi:isEnd() == true then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10),
                    getlocal("acOver"), 28)
                return
            end
			local function secondTipFunc(sbFlag)
				local keyName = "active.hryx"
	            local sValue=base.serverTime .. "_" .. sbFlag
	            G_changePopFlag(keyName,sValue)
	            
	        end
	        local function confirmHandler()
		            local function callBack(fn, data)
		                local ret, sData = base:checkServerData(data)
		                if ret == true then
		                    local rewardlist = {}
		                    if reward and next(reward) then
		                        local addItem = reward[1]
		                        addItem.num = addItem.num * shopNum
		                        G_addPlayerAward(addItem.type, addItem.key, addItem.id, addItem.num, nil, true)
		                        table.insert(rewardlist, addItem)
		                    end
		                    acHryxVoApi:updateData(sData.data.hryx)
		                    playerVoApi:setGems(playerVoApi:getGems() - price * shopNum)
		                    self:refresh()

		                    require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
		                    local function showEndHandler()
		                        if itemData then
		                            local awardItem = {
		                                type=itemData.type,
		                                key=itemData.key,
		                                pic=itemData.pic,
		                                name=itemData.name,
		                                num=itemData.num,
		                                desc=itemData.desc,
		                                id=itemData.id,
		                                bgname=itemData.bgname
		                            }
		                            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10),
		                                "", 28, nil, nil, {awardItem})
		                        end
		                    end
		                    rewardShowSmallDialog:showNewReward(self.layerNum + 1, true, true, rewardlist,
		                        showEndHandler, getlocal("but_get"), nil, nil, nil, "")
		                end
		            end
		            socketHelper:acHryxBuyshop(callBack, sid,shopNum)
	        end
	        local keyName = "active.hryx"
	        if G_isPopBoard(keyName) then
	        	G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{num*price}),true,confirmHandler,secondTipFunc)
				do return end
			else
				confirmHandler()
			end
        end
        shopVoApi:showBatchBuyPropSmallDialog(itemData.key,self.layerNum+1,sureCallBack,getlocal("activity_thfb_small_buy"),limitMax - limitNum,price,nil,true,itemData)
    end

    local btnScale = 0.7
    local btnPosx = cellWidth - 100
    local str = getlocal("buy")
    local buyItemButton = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png",
        onBuyCallBack, 102, str, 24 / btnScale, 100)
    buyItemButton:setScale(btnScale)
    local okBtn = CCMenu:createWithItem(buyItemButton)
    okBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
    okBtn:setAnchorPoint(ccp(1, 0.5))
    okBtn:setPosition(ccp(btnPosx, 36))
    cell:addChild(okBtn)

    -- 原始价格
    local lbPosx = btnPosx - 15
    local goldIconPosx = btnPosx + 30
    local realLbPosy = cellHeight - 20
    local realLb = GetTTFLabel(acHryxVoApi:getPrice(idx), 20)
    realLb:setAnchorPoint(ccp(0.5, 0.5))
    realLb:setPosition(ccp(lbPosx, realLbPosy))
    cell:addChild(realLb)
    local realCost = CCSprite:createWithSpriteFrameName("IconGold.png")
    realCost:setAnchorPoint(ccp(0.5, 0.5))
    realCost:setPosition(ccp(goldIconPosx, realLbPosy))
    cell:addChild(realCost)
    local redLine = CCSprite:createWithSpriteFrameName("redline.jpg")
    redLine:setAnchorPoint(ccp(0.5, 0.5))
    redLine:setScaleX(100 / redLine:getContentSize().width)
    redLine:setPosition(ccp(btnPosx, realLbPosy))
    cell:addChild(redLine, 1)
    -- 打折价格
    local disPosy = cellHeight / 2 + 16
    local dazheLb = GetTTFLabel(price, 20)
    dazheLb:setAnchorPoint(ccp(0.5, 0.5))
    dazheLb:setPosition(ccp(lbPosx, disPosy))

    if ownGems >= price or limitNum >= limitMax then
        dazheLb:setColor(G_ColorYellowPro)
        btnState = 0
    else
        dazheLb:setColor(G_ColorRed)
        btnState = 1
    end
    cell:addChild(dazheLb)
    local dazheCost = CCSprite:createWithSpriteFrameName("IconGold.png")
    dazheCost:setAnchorPoint(ccp(0.5, 0.5))
    dazheCost:setPosition(ccp(goldIconPosx, disPosy))
    cell:addChild(dazheCost)

    return cell
end

function acHryxTabTwo:tick()
    if acHryxVoApi:isEnd() == true then
        self:close()
        do return end
    end

    local acVo = acHryxVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb, "CCLabelTTF") then
        self.timeLb:setString(acHryxVoApi:getTimeStr())
    end
end

function acHryxTabTwo:refresh()
    if self.tv then
        self.shopKeyList = acHryxVoApi:getShoplistSortKey()
        self.tv:reloadData()
    end
end

function acHryxTabTwo:updateShowTop(isInit)
    local unlockId = acHryxVoApi:getAcVo().exteriorId

    if self.rechargeLb then
        self.rechargeLb:removeFromParentAndCleanup(true)
    end
    if self.topTip then
    	self.topTip:removeFromParentAndCleanup(true)
    end

    local recharge1 = acHryxVoApi:getV()
    local recharge2 = acHryxVoApi:getAcVo().recharge
    if buildDecorateVoApi:judgeHas(unlockId) and buildDecorateVoApi:isExperience(unlockId) == false then
        recharge1 = recharge2
    else
        if recharge1 >= recharge2 then
            recharge1 = recharge2
        end
    end
    local strSize2,strSize3 = 22,20
    if not G_isAsia() or ( G_getCurChoseLanguage() == "ja" or G_getCurChoseLanguage() == "ko" ) then
        strSize2 = 17
        strSize3 = 17
    end
    local rechargeStr = getlocal("activity_wxgx_info1",{recharge1, recharge2})
    local colorTab = {G_ColorWhite, G_ColorYellowPro2, G_ColorWhite}
    local rechargeLb, lbHeight = G_getRichTextLabel(rechargeStr, colorTab,strSize2, G_VisibleSizeWidth - 150, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    rechargeLb:setAnchorPoint(ccp(0.5, 1))
    rechargeLb:setPosition(ccp(G_VisibleSizeWidth / 2, self.showTopHeight - 65))
    self.showLayerTop:addChild(rechargeLb, 1)
    self.rechargeLb = rechargeLb

    local topTip = GetTTFLabelWrap(getlocal("activity_hryx_tab1_topTip"),strSize3,CCSizeMake(G_VisibleSizeWidth - 100, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop,"Helvetica-bold")
    topTip:setAnchorPoint(ccp(0.5,1))
    topTip:setPosition(G_VisibleSizeWidth / 2, self.showTopHeight - 100)
    self.showLayerTop:addChild(topTip,1)
    topTip:setColor(G_ColorYellowPro)
    self.topTip = topTip

    if not G_isAsia() then
        topTip:setPositionY(topTip:getPositionY() - 10)
    end

    if isInit == true then
        -- 装备配置
        local decorateCfg = exteriorCfg.exteriorLit[unlockId]
        local decorateLv = #decorateCfg.value[1]

        -- 属性背景
        local attrBg = CCSprite:createWithSpriteFrameName("amHeaderBg.png")
        attrBg:setAnchorPoint(ccp(1, 0.5))
        attrBg:setPosition(ccp(G_VisibleSizeWidth, rechargeLb:getPositionY() - 135))
        attrBg:setOpacity(100)
        attrBg:setScaleX(7)
        attrBg:setScaleY(4)
        attrBg:setFlipX(true)
        self.showLayerTop:addChild(attrBg)

        local attrLb = GetTTFLabel(getlocal("activity_wxgx_info2"), 24, true)
        attrLb:setAnchorPoint(ccp(0, 1))
        attrLb:setPosition(ccp(rechargeLb:getPositionX() - 50, rechargeLb:getPositionY() - 80))
        self.showLayerTop:addChild(attrLb)

        local strSize = 22
        local supX = 0
        if G_isAsia() == false or G_getCurChoseLanguage() == "ko" then
            strSize = 15
            supX = 40
        end
        for i,v in ipairs(decorateCfg.attType) do
            local value = decorateCfg.value[i][decorateLv]
            local attstr = value < 1 and tostring(value * 100) .. "%" or value
            attstr = getlocal("decorateAttr" .. v) .. " + " .. attstr
            local nameLb = GetTTFLabel(attstr, strSize)
            nameLb:setAnchorPoint(ccp(0, 1))
            nameLb:setPosition(ccp(attrLb:getPositionX() + 40 - supX, attrLb:getPositionY() - 40 - (i - 1) * 40))
            nameLb:setColor(G_ColorGreen)
            self.showLayerTop:addChild(nameLb)
        end

        local function onBuyCallBack(tag, object)
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            --activityIsOver
            if acHryxVoApi:isRewardTime() then
            	G_showTipsDialog(getlocal("activityIsOver"))
            	do return end
            end

            if self.buyState == 3 then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10),
                    getlocal("activity_wxgx_tips2"), 30)
                return
            end

            -- 检测金币
            if playerVoApi:getGems() < acHryxVoApi:getAcVo().exteriorCost then
                GemsNotEnoughDialog(nil, nil, acHryxVoApi:getAcVo().exteriorCost - playerVoApi:getGems(), self.layerNum + 1, acHryxVoApi:getAcVo().exteriorCost)
                return
            end

            local function sureCallBack()
                if acHryxVoApi:isEnd() == true then
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10),
                        getlocal("acOver"), 28)
                    return
                end

                local function callBack(fn, data)
                    local ret, sData = base:checkServerData(data)
                    if ret == true then
                        playerVoApi:setGems(playerVoApi:getGems() - acHryxVoApi:getAcVo().exteriorCost)
                        buildDecorateVoApi:unlockSkin(unlockId)
                        self:updateShowTop()

                        local paramTab = {}
                        paramTab.functionStr = "hryx"
                        paramTab.addStr = "goTo_see_see"
                        paramTab.colorStr = "w"
                        local playerName = playerVoApi:getPlayerName()
                        local message = {key = "activity_hryx_notice_tip", param = {playerName}}
                        chatVoApi:sendSystemMessage(message, paramTab)
                    end
                end

                socketHelper:acHryxBuyexter(callBack)
            end

            local title = getlocal("dialog_title_prompt")
            local content = getlocal("activity_wxgx_tips4", {acHryxVoApi:getAcVo().exteriorCost})
            local tipDialog = smallDialog:new()
            tipDialog:initSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350),
                CCRect(168, 86, 10, 10), sureCallBack, title, content, nil, self.layerNum + 1)
        end

        local btnScale = 0.7
        local buyItemButton = GetButtonItem("creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn.png", onBuyCallBack, 102, getlocal("buy"), 24 / btnScale, 100)
        buyItemButton:setScale(btnScale)
        local okBtn = CCMenu:createWithItem(buyItemButton)
        okBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
        okBtn:setAnchorPoint(ccp(0.5, 0.5))
        okBtn:setPosition(ccp(G_VisibleSizeWidth / 2 + 130, 50))
        self.showLayerTop:addChild(okBtn)

        -- 价格
        local buyPriceWidth = 0
        local lbPosx = okBtn:getPositionX() + 2
        local disPosy = okBtn:getPositionY() + 42
        local buyLb = GetTTFLabel(acHryxVoApi:getAcVo().exteriorCost, 20)
        buyLb:setAnchorPoint(ccp(0, 0.5))
        self.showLayerTop:addChild(buyLb)
        local buyCostIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
        buyCostIcon:setAnchorPoint(ccp(1, 0.5))
        self.showLayerTop:addChild(buyCostIcon)
        -- 修正位置
        buyPriceWidth = buyLb:getContentSize().width + 15 + buyCostIcon:getContentSize().width
        buyLb:setPosition(ccp(lbPosx - buyPriceWidth / 2, disPosy))
        buyCostIcon:setPosition(ccp(lbPosx + buyPriceWidth / 2, disPosy))

        self.buyItemButton = buyItemButton
        self.buyLb = buyLb
        self.buyCostIcon = buyCostIcon

        local strSize = 24
        local stateLb = GetTTFLabelWrap("", strSize, CCSizeMake(300, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        stateLb:setAnchorPoint(ccp(0.5, 0.5))
        stateLb:setPosition(ccp(okBtn:getPositionX(), okBtn:getPositionY()))
        self.showLayerTop:addChild(stateLb)
        self.stateLb = stateLb

        -- local buildIconSp = CCSprite:createWithSpriteFrameName(decorateCfg.decorateSp)
        -- buildIconSp:setPosition(ccp(140, 130))
        -- buildIconSp:setScale(1.2)
        -- self.showLayerTop:addChild(buildIconSp)

        -- local lockSp = CCSprite:createWithSpriteFrameName("LockIconCheckPoint.png")
        -- lockSp:setPosition(ccp(buildIconSp:getPositionX(), buildIconSp:getPositionY()))
        -- self.showLayerTop:addChild(lockSp)
        -- self.lockSp = lockSp
    end

    if buildDecorateVoApi:judgeHas(unlockId) and buildDecorateVoApi:isExperience(unlockId) == false then
        -- 已拥有
        self.buyItemButton:setVisible(false)
        self.buyLb:setVisible(false)
        self.buyCostIcon:setVisible(false)
        self.stateLb:setVisible(true)

        self.stateLb:setColor(G_ColorYellow)
        self.stateLb:setString(getlocal("activity_wxgx_tips3"))

        self.buyState = 1
    else
        -- 未解锁
        local playerLv = playerVoApi:getPlayerLevel()
        if playerLv < acHryxVoApi:getAcVo().unlockNeedPlayerlv then
            -- 指挥官等级不足
            self.buyItemButton:setVisible(false)
            self.buyLb:setVisible(false)
            self.buyCostIcon:setVisible(false)

            self.stateLb:setVisible(true)

            self.stateLb:setColor(G_ColorRed)
            self.stateLb:setString(getlocal("activity_wxgx_tips1", {acHryxVoApi:getAcVo().unlockNeedPlayerlv}))

            self.buyState = 0
        else
            self.buyItemButton:setVisible(true)
            self.buyLb:setVisible(true)
            self.buyCostIcon:setVisible(true)
            self.stateLb:setVisible(false)

            if recharge1 >= recharge2 then
                self.buyState = 2
            else
                self.buyState = 3
            end
        end
    end

    -- self.lockSp:setVisible((self.buyState == 0))
end

function acHryxTabTwo:showBuildingFunction(buildingPic,parent,pos,aPos,scaleSize)
	local buildingSp = G_buildingAction2(buildingPic,parent,pos,aPos,scaleSize)
	self.buildingAc = buildingSp
	local buildingSpWidth = buildingSp:getContentSize().width
	--放大镜
	local magnifierNode=CCNode:create()
	magnifierNode:setPosition(buildingSpWidth - 120,50)
	magnifierNode:setTag(1016)
	parent:addChild(magnifierNode)
	local nodeWidth,nodeHeight = magnifierNode:getContentSize().width ,magnifierNode:getContentSize().height

	local circelCenter=getCenterPoint(magnifierNode)
	local radius,rt,rtimes=10,2,2
	local magnifierSp=LuaCCSprite:createWithSpriteFrameName("ydcz_magnifier.png",function() end)
	self.magnifierSp = magnifierSp
	magnifierSp:setScale(0.6)
	magnifierSp:setTouchPriority(-(self.layerNum-1)*20-4)
	magnifierSp:setPosition(circelCenter)
	magnifierNode:addChild(magnifierSp)

	local acArr=CCArray:create()
	local moveTo=CCMoveTo:create(0.5,ccp(nodeWidth * 0.5,radius))
	local function rotateBy()
		if magnifierSp and circelCenter then
			G_requireLua("componet/CircleBy")
			self.circelAc=CircleBy:create(magnifierSp,rt,circelCenter,radius,rtimes)
		end
	end
	local function removeRotateBy()
		if self.circelAc and self.circelAc.stop then
			self.circelAc:stop()
		end
	end
	local moveTo2=CCMoveTo:create(0.5,ccp(nodeWidth * 0.5,nodeHeight * 0.5))
	local delay=CCDelayTime:create(1)
	acArr:addObject(moveTo)
	acArr:addObject(CCCallFunc:create(rotateBy))
	acArr:addObject(CCDelayTime:create(rt))
	acArr:addObject(CCCallFunc:create(removeRotateBy))
	acArr:addObject(moveTo2)
	acArr:addObject(delay)
	local seq=CCSequence:create(acArr)
	magnifierSp:runAction(CCRepeatForever:create(seq))

	local function touchHandle( )
		if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

    	require "luascript/script/game/scene/gamedialog/activityAndNote/acThrivingSmallDialog"
        local titleStr = getlocal("buildingReadyToShow")
        local needTb = {"hryx",titleStr,2}
        local sd = acThrivingSmallDialog:new(self.layerNum+1,needTb)
        sd:init()
	end 
	local touchSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchHandle)
	touchSp:setContentSize(CCSizeMake(buildingSpWidth * 0.8,buildingSp:getContentSize().height))
	touchSp:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
	touchSp:setAnchorPoint(ccp(0,0))
	touchSp:setPosition(0,0)
	touchSp:setOpacity(0)
	parent:addChild(touchSp)
end







