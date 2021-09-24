acKhzrDialog=commonDialog:new()

function acKhzrDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.adaH = 0
	if G_getIphoneType() == G_iphoneX then
		self.adaH = 100
	end
	local function addPlist()
		spriteController:addPlist("public/acSuperShopImage.plist")
		spriteController:addTexture("public/acSuperShopImage.png")
		spriteController:addPlist("public/acKhzrImage.plist")
		spriteController:addTexture("public/acKhzrImage.png")
		spriteController:addPlist("public/acDouble11_NewImage.plist")
		spriteController:addTexture("public/acDouble11_NewImage.png")
	end
	G_addResource8888(addPlist)
    spriteController:addPlist("public/packsImage.plist")
    spriteController:addTexture("public/packsImage.png")
    spriteController:addPlist("public/purpleFlicker.plist")
    spriteController:addTexture("public/purpleFlicker.png")
    spriteController:addPlist("public/blueFilcker.plist")
    spriteController:addTexture("public/blueFilcker.png")
    spriteController:addPlist("public/yellowFlicker.plist")
    spriteController:addTexture("public/yellowFlicker.png")
	return nc
end
function acKhzrDialog:dispose()
	spriteController:removePlist("public/acSuperShopImage.plist")
	spriteController:removeTexture("public/acSuperShopImage.png")
	spriteController:removePlist("public/acDouble11_NewImage.plist")
	spriteController:removeTexture("public/acDouble11_NewImage.png")
    spriteController:removePlist("public/packsImage.plist")
    spriteController:removeTexture("public/packsImage.png")
    spriteController:removePlist("public/purpleFlicker.plist")
    spriteController:removeTexture("public/purpleFlicker.png")
    spriteController:removePlist("public/blueFilcker.plist")
    spriteController:removeTexture("public/blueFilcker.png")
    spriteController:removePlist("public/yellowFlicker.plist")
    spriteController:removeTexture("public/yellowFlicker.png")
    spriteController:removePlist("public/acKhzrImage.plist")
	spriteController:removeTexture("public/acKhzrImage.png")
end
function acKhzrDialog:initTableView()
	self.panelLineBg:setVisible(false)
	if acKhzrVoApi:isToday()==false then
    	acKhzrVoApi:clearData(true)
    	if self.tv then
    		self.tv:reloadData()
    	end
    end
end

function acKhzrDialog:doUserHandler()
	print("in function acKhzrDialog:doUserHandler()~~~~~~\n\n")
	self:initUpDia()
	self:initDownDia()
end

function acKhzrDialog:initUpDia()
	local topTitleNeedH = 80
	local startH=G_VisibleSize.height-topTitleNeedH

	local upBgH=176
	local function touchUp()
	end
	local bgWidth=G_VisibleSize.width-30
	self.bgWidth = bgWidth
	local upBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touchUp)
	upBg:setContentSize(CCSizeMake(bgWidth,upBgH))
    upBg:ignoreAnchorPointForPosition(false)
    upBg:setAnchorPoint(ccp(0.5,1))
    upBg:setTouchPriority(-(self.layerNum-1)*20-1)
	upBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,startH))
    self.bgLayer:addChild(upBg)
    self.upBg=upBg

	local function onLoadIcon(fn,icon)
		if(self and self.upBg and tolua.cast(self.upBg,"LuaCCScale9Sprite")) then
			-- icon:setScale(0.98)
			icon:setPosition(getCenterPoint(self.upBg))
			self.upBg:addChild(icon,1)
		end
	end
	local webImage=LuaCCWebImage:createWithURL(G_downloadUrl("active/kzhdBg.png"),onLoadIcon)

	local function touchTip()
        local tabStr={getlocal("activity_khzr_tip1"),getlocal("activity_khzr_tip2")}

        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr)
    end
	local pos=ccp(self.upBg:getContentSize().width-50,self.upBg:getContentSize().height-50)
	local tabStr={}
	G_addMenuInfo(self.upBg,self.layerNum,pos,tabStr,nil,nil,28,touchTip,true)

	local h = self.upBg:getContentSize().height/2+60
	local acLabel = GetTTFLabel(getlocal("activityCountdown"),23)
	acLabel:setAnchorPoint(ccp(0.5,1))
	acLabel:setPosition(ccp(self.upBg:getContentSize().width/2, h))
	self.upBg:addChild(acLabel,2)
	acLabel:setColor(G_ColorYellowPro)

	h = h-30
	local timeStr=acKhzrVoApi:getTimer()
	local messageLabel=GetTTFLabel(timeStr,23)
	messageLabel:setAnchorPoint(ccp(0.5,1))
	messageLabel:setColor(G_ColorYellowPro)
	messageLabel:setPosition(ccp(self.upBg:getContentSize().width/2, h))
	self.upBg:addChild(messageLabel,2)
	self.timeLb=messageLabel

	h = h-40
	local strSize2 = 22
	local strSize3 = 22
	if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
		strSize2 = 24
		strSize3 = 28
	end
	local descStr = acKhzrVoApi:getVersion() == 1 and getlocal("activity_khzr_desc") or getlocal("activity_khzr_desc_v2")
	local desLb=GetTTFLabelWrap(descStr,strSize2,CCSizeMake(self.upBg:getContentSize().width-4,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	desLb:setAnchorPoint(ccp(0.5,1))
	desLb:setPosition(self.upBg:getContentSize().width/2, h)
	self.upBg:addChild(desLb,2)

	-- strSize3 = G_getCurChoseLanguage() =="ru"  and 22 or 28--activity_pjgx_special_bag
	local titleTb={getlocal("activity_pjgx_special_bag"),strSize3,G_ColorWhite}--sample_prop_name_1321

	local titleLbSize=CCSizeMake(300,0)
	local titleBg,titleL,subHeight=G_createNewTitle(titleTb,titleLbSize,nil,true)
	self.upBg:addChild(titleBg)
	titleBg:setPosition(self.upBg:getContentSize().width*0.5,0 - subHeight-5)

	self.upHeight = subHeight + upBgH + topTitleNeedH
end
function acKhzrDialog:initDownDia( )
	self.downBgHeight = G_VisibleSize.height - self.upHeight-5
	local downBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),function ( ) end)
	downBg:setContentSize(CCSizeMake(self.bgWidth,self.downBgHeight))
    downBg:ignoreAnchorPointForPosition(false)
    downBg:setOpacity(0)
    downBg:setAnchorPoint(ccp(0.5,0))
    downBg:setTouchPriority(-(self.layerNum-1)*20-1)
	downBg:setPosition(ccp(G_VisibleSize.width*0.5,5))
	self.bgLayer:addChild(downBg)
	local function eventHandler(handler,fn,idx,cel)
		if fn=="numberOfCellsInTableView" then
			return 1
		elseif fn=="tableCellSizeForIndex" then
			return CCSizeMake(self.bgWidth,self.downBgHeight)
		elseif fn=="tableCellAtIndex" then
			local cell=CCTableViewCell:new()
			cell:autorelease()
			local cellBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),function ( ) end)
			cellBg:setContentSize(CCSizeMake(self.bgWidth,self.downBgHeight))
		    cellBg:ignoreAnchorPointForPosition(false)
		    cellBg:setOpacity(0)
		    cellBg:setAnchorPoint(ccp(0,0))
		    cellBg:setTouchPriority(-(self.layerNum-1)*20-1)
			cellBg:setPosition(ccp(0,0))
			cell:addChild(cellBg)

			self:initDownWithPacks(cellBg)
			return cell
		elseif fn=="ccTouchBegan" then
			return true
		elseif fn=="ccTouchMoved" then
		elseif fn=="ccTouchEnded"  then
		end
	end
	local hd=LuaEventHandler:createHandler(eventHandler)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgWidth,self.downBgHeight),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
	self.tv:setPosition(0,0)
	downBg:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(0)
end

function acKhzrDialog:initDownWithPacks(curBgDia)
	local listStartH=curBgDia:getContentSize().height-180
    local listCenterW=curBgDia:getContentSize().width*0.5
    local jiangeW=200
    local jiangeH=235

    if(G_isIphone5())then
		listStartH=listStartH-50
		jiangeH=270
	end

	local ng,curStalls = acKhzrVoApi:getNgAndStalls()--后台给，curStalls：当前第几档
	local selfSpendGems = acKhzrVoApi:getSelfSpendGold( )
	-------\\\\\\middle//////-------
	local subHeight555 = G_isIphone5() and 20 or 0
	local spendGemsStr = GetTTFLabel(getlocal("curRechargeGems"),22)
	spendGemsStr:setAnchorPoint(ccp(0,0.5))
	spendGemsStr:setPosition(ccp(10,curBgDia:getContentSize().height-24 - subHeight555*0.5-self.adaH/2))
	curBgDia:addChild(spendGemsStr)
	local spendGemsGoldStr = GetTTFLabel(selfSpendGems,22)
	spendGemsGoldStr:setAnchorPoint(ccp(0,0.5))
	spendGemsGoldStr:setPosition(ccp(spendGemsStr:getContentSize().width+spendGemsStr:getPositionX(),spendGemsStr:getPositionY()))
	curBgDia:addChild(spendGemsGoldStr)
	local iconGold=CCSprite:createWithSpriteFrameName("IconGold.png")
	iconGold:setAnchorPoint(ccp(0,0.5))
	iconGold:setPosition(ccp(spendGemsGoldStr:getContentSize().width+2+spendGemsGoldStr:getPositionX(),spendGemsGoldStr:getPositionY()))
	curBgDia:addChild(iconGold)


	local barBg = CCSprite:createWithSpriteFrameName("segBarBg.png")
	barBg:setAnchorPoint(ccp(0,0.5))
	barBg:setPosition(ccp(60,curBgDia:getContentSize().height-90-subHeight555-self.adaH/2))
	curBgDia:addChild(barBg)

	for i=1,4 do
		local pgBarSP1 = CCSprite:createWithSpriteFrameName("sProgressbar_"..i..".png")
		local pgBarSP = CCProgressTimer:create(pgBarSP1)
		pgBarSP:setAnchorPoint(ccp(0,0.5))
		pgBarSP:setMidpoint(ccp(0,0.5))
		pgBarSP:setType(kCCProgressTimerTypeBar)
        pgBarSP:setBarChangeRate(ccp(1, 0))
		pgBarSP:setPosition(ccp(15+(i-1)*115,barBg:getContentSize().height*0.5))
		barBg:addChild(pgBarSP)
		-- pgBarSP:setPercentage(20)

		if selfSpendGems >ng[i+1] then
			pgBarSP:setPercentage(100)
		else
			local curStallsNeedGold = ng[i+1] - ng[i]
			local curStallsSpendGold = selfSpendGems  - ng[i]
			local zb = math.ceil(curStallsSpendGold/curStallsNeedGold*100)
			pgBarSP:setPercentage(zb)
		end

		local function showDiaCall(object,name,tag)
			local needGold = ng[tag+1]
			local tabStr={getlocal("activity_khzr_ruleDesce",{needGold}),"\n"}

	        require "luascript/script/game/scene/gamedialog/activityAndNote/acKhzrSmallTipDia"
	        acKhzrSmallTipDia:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr,nil,21,tag+1)
		end
		local tipShow = CCSprite:createWithSpriteFrameName("sTip_"..i..".png")
		tipShow:setAnchorPoint(ccp(0.5,0))		
		tipShow:setPosition(ccp(15+i*115,barBg:getContentSize().height))
		tipShow:setTag(i)
		barBg:addChild(tipShow)

		local grayBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),showDiaCall)
		grayBgSp:setTouchPriority(-(self.layerNum-1)*20-4)
		grayBgSp:setOpacity(0)
		grayBgSp:setContentSize(CCSizeMake(50,50))
		grayBgSp:setTag(i)
		grayBgSp:setPosition(getCenterPoint(tipShow))
		tipShow:addChild(grayBgSp)

		local needGold = GetTTFLabel(ng[i+1],20)
		needGold:setAnchorPoint(ccp(1,1))
		needGold:setPosition(ccp(15+i*115,0))
		barBg:addChild(needGold)
		local iconGold=CCSprite:createWithSpriteFrameName("IconGold.png")
		iconGold:setAnchorPoint(ccp(0,0.5))
		iconGold:setPosition(ccp(needGold:getContentSize().width,needGold:getContentSize().height*0.5))
		needGold:addChild(iconGold)

	end
		local strSize3 = 21
		if G_getCurChoseLanguage() =="fr" then
			strSize3 = 18
		end
		local middleDesc = GetTTFLabel(getlocal("activity_khzr_buyDesc2"),strSize3)
		middleDesc:setAnchorPoint(ccp(0.5,0.5))
		middleDesc:setPosition(ccp(curBgDia:getContentSize().width*0.5,curBgDia:getContentSize().height-160-subHeight555*1.5-self.adaH/2))
		middleDesc:setColor(G_ColorYellowPro)
		curBgDia:addChild(middleDesc)
	-------\\\\\\middle//////-------
    local shop=acKhzrVoApi:getShop()
    local canBuyTimesTb = acKhzrVoApi:getCanBuyTimesTb( )
    self.listItemTb={}

    -- print("getSelfSpendGold====>>>>",acKhzrVoApi:getSelfSpendGold())

    for i=1,2 do
    	for j=1,3 do
    		local tag=(i-1)*3 + j
    		local shopCfg=shop["i" .. tag]
    		local buyedTiems = canBuyTimesTb["i"..tag] or 0
    		local function touchListItem()
				if G_checkClickEnable()==false then
					do return end
				else
					base.setWaitTime=G_getCurDeviceMillTime()
				end
				local giftId=tag
				PlayEffect(audioCfg.mouseClick)
				self.smallDialog=acKhzrVoApi:showGiftBuyDialog(self.layerNum+1,true,true,nil,giftId,shop,self)
			end
			local menuSpName="superShopBg1.png"
			local menuSp1=CCSprite:createWithSpriteFrameName(menuSpName)
			local menuSp2=CCSprite:createWithSpriteFrameName(menuSpName)
			local menuSp3=GraySprite:createWithSpriteFrameName(menuSpName)
			local upSp=CCSprite:createWithSpriteFrameName("superShopBg_down.png")
			menuSp2:addChild(upSp)
			upSp:setPosition(getCenterPoint(menuSp2))
			local listItem=CCMenuItemSprite:create(menuSp1,menuSp2,menuSp3)
			listItem:registerScriptTapHandler(touchListItem)
			listItem:setTag(tag)
			listItem:setAnchorPoint(ccp(0.5,1))
			self.listItemTb[tag]=listItem
			local listMenu = CCMenu:createWithItem(listItem)
			listMenu:setTouchPriority(-(self.layerNum-1)*20-2)
			listMenu:setPosition(listCenterW+(j-2)*jiangeW,listStartH-(i-1)*jiangeH-self.adaH)
			curBgDia:addChild(listMenu)

			local r=shopCfg.r
			local rewardItem=FormatItem(r)[1]

			local icon=CCSprite:createWithSpriteFrameName("packs" .. tag .. ".png")
			icon:setPosition(listItem:getContentSize().width/2,138)
			listItem:addChild(icon)

			if tag==6 then
				self:addLightBlinker(icon,1)
				self:addLightBlinker(icon,2)
			end

			local bgName = curStalls < 5 and "saleBg_"..curStalls..".png" or "saleRedBg.png"
			local redBg=CCSprite:createWithSpriteFrameName(bgName)
			redBg:setPosition(listItem:getContentSize().width-25,listItem:getContentSize().height-30)
			redBg:setRotation(20)
			listItem:addChild(redBg)


			local curSpendGold = shopCfg.g[curStalls]
			local discount= math.ceil((shopCfg.p - curSpendGold)/shopCfg.p*100)
			local discountLb=GetTTFLabel("-"..discount.."%",20)
			discountLb:setPosition(redBg:getContentSize().width/2,redBg:getContentSize().height/2)
			redBg:addChild(discountLb)

			local strSize3 = 20
			if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
				strSize3 = 22
			elseif G_getCurChoseLanguage() =="fr" then
				strSize3 = 17
			end
			local numLb=GetTTFLabel(getlocal("packs_name_" .. tag),strSize3)
			numLb:setColor(G_ColorYellowPro)
			numLb:setPosition(listItem:getContentSize().width/2,63)
			listItem:addChild(numLb)

			local iconGold=CCSprite:createWithSpriteFrameName("IconGold.png")
			iconGold:setAnchorPoint(ccp(0,0.5))
			iconGold:setPosition(10,20)
			listItem:addChild(iconGold)
			local originPriceLb=GetTTFLabel(shopCfg.p,22)
			originPriceLb:setColor(G_ColorRed)
			originPriceLb:setAnchorPoint(ccp(0,0.5))
			originPriceLb:setPosition(15 + iconGold:getContentSize().width,20)
			listItem:addChild(originPriceLb)
			local lineWhite=CCSprite:createWithSpriteFrameName("white_line.png")
			lineWhite:setColor(G_ColorRed)
			lineWhite:setScaleX((originPriceLb:getContentSize().width + 10)/lineWhite:getContentSize().width)
			lineWhite:setPosition(originPriceLb:getPositionX() + originPriceLb:getContentSize().width/2,17)
			listItem:addChild(lineWhite)
			local priceStr=curSpendGold
			local colorP=G_ColorWhite
			local priceSteSize = 22

			local priceLb=GetTTFLabel(priceStr,priceSteSize)
			priceLb:setAnchorPoint(ccp(1,0.5))
			priceLb:setPosition(listItem:getContentSize().width - 10,20)
			listItem:addChild(priceLb)
			priceLb:setColor(colorP)

			--menuSp2
			local wordBg2 = CCSprite:createWithSpriteFrameName("wordBg2.png")
			wordBg2:setAnchorPoint(ccp(0.5,1))
			wordBg2:setPosition(ccp(menuSp2:getContentSize().width*0.5,-2))
			menuSp2:addChild(wordBg2)

			local showBugTimes2 = buyedTiems.."/"..shopCfg.t
			local wordShow2 = GetTTFLabel(getlocal("canBuy").." "..showBugTimes2,19)
			wordShow2:setPosition(getCenterPoint(wordBg2))
			if buyedTiems == shopCfg.t then
				wordShow2:setColor(G_ColorRed)
			end
			wordBg2:addChild(wordShow2)

			local wordBg = CCSprite:createWithSpriteFrameName("wordBg.png")
			wordBg:setAnchorPoint(ccp(0.5,1))
			wordBg:setPosition(ccp(menuSp1:getContentSize().width*0.5,-2))
			menuSp1:addChild(wordBg)

			local showBugTimes = buyedTiems.."/"..shopCfg.t
			local wordShow = GetTTFLabel(getlocal("canBuy").." "..showBugTimes,19)
			wordShow:setPosition(getCenterPoint(wordBg))
			if buyedTiems == shopCfg.t then
				wordShow:setColor(G_ColorRed)

				local function showTip()
				end
				blackBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),showTip)
				blackBg:setTouchPriority(-(self.layerNum-1)*20-3)
				blackBg:setContentSize(listItem:getContentSize())
				blackBg:setAnchorPoint(ccp(0,0))
				blackBg:setPosition(0,0)
				blackBg:setOpacity(100)
				listItem:addChild(blackBg,2)

				buyLb=GetTTFLabelWrap(getlocal("hasBuy"),22,CCSizeMake(listItem:getContentSize().width-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
				listItem:addChild(buyLb,4)
				buyLb:setPosition(listItem:getContentSize().width/2,138)
				buyLb:setColor(G_ColorRed)

				lbBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg_black.png")
				listItem:addChild(lbBg,3)
				lbBg:setPosition(listItem:getContentSize().width/2,138)
			end
			wordBg:addChild(wordShow)
    	end
    end
end

function acKhzrDialog:addLightBlinker(parent,flag)
    if parent==nil then
        return
    end

    local posCfg
    if flag==1 then
    	posCfg={ccp(42.5, 56),ccp(4, 70.5)}
    else
    	posCfg={ccp(49, 85.5),ccp(75.5, 71.5)}
    end

    local lightSp=CCSprite:createWithSpriteFrameName("gold_whitelight.png")
    lightSp:setPosition(posCfg[1])
    lightSp:setScale(2)
    lightSp:setOpacity(0)
    parent:addChild(lightSp)
    local arr=CCArray:create()
    local fadeIn=CCFadeIn:create(0.4)
    local fadeOut=CCFadeOut:create(0.4)
    local function resetPos()
       local idx=math.random(1,2)
       local pos=posCfg[idx]
       lightSp:setPosition(pos)
    end
    local callFunc=CCCallFunc:create(resetPos)
    local time=1
    local delay=CCDelayTime:create(time)

    if flag==2 then
    	local delay2=CCDelayTime:create(0.5)
    	arr:addObject(delay2)
    end

    arr:addObject(fadeIn)
    arr:addObject(fadeOut)
    arr:addObject(callFunc)
    -- arr:addObject(delay)

    if flag==1 then
    	local delay=CCDelayTime:create(0.9)
    	arr:addObject(delay)
    else
    	local delay=CCDelayTime:create(0.4)
    	arr:addObject(delay)
    end

    
    local seq=CCSequence:create(arr)
    local repeatForever=CCRepeatForever:create(seq)
    lightSp:runAction(repeatForever)
end

function acKhzrDialog:refresh( )
	-- print("in refresh~~~~~~")
	if self.tv then
		-- print("ready reloadData~~~~~~~~")
		self.tv:reloadData()
	end
end

function acKhzrDialog:tick()
	local vo=acKhzrVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
        	if self.smallDialog then
        		if self.smallDialog.secondDialog and self.smallDialog.secondDialog.close then
        			self.smallDialog.secondDialog:close()
        		end
        		self.smallDialog:close()
        	end
            self:close()
            do return end
        end
    end
    if acKhzrVoApi:isToday()==false then
    	-- print("is not today~~~~")
    	acKhzrVoApi:clearData(true)
    	if self.tv then
    		self.tv:reloadData()
    	end
    end

    if self.timeLb then
    	self.timeLb:setString(acKhzrVoApi:getTimer())
    end
end

