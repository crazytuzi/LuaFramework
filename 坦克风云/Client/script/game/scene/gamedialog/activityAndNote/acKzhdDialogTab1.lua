acKzhdDialogTab1={}

function acKzhdDialogTab1:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acKzhdDialogTab1:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self:initLayer1()
	return self.bgLayer
end
function acKzhdDialogTab1:initLayer1(  )
	local startH=G_VisibleSize.height-160

	local upBgH=176
	local function touchUp()
	end
	local bgWidth=G_VisibleSize.width-30
	local upBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touchUp)
	upBg:setContentSize(CCSizeMake(bgWidth,upBgH))
    upBg:ignoreAnchorPointForPosition(false)
    upBg:setAnchorPoint(ccp(0.5,1))
    upBg:setTouchPriority(-(self.layerNum-1)*20-1)
	upBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,startH))
    self.bgLayer:addChild(upBg)
    self.upBg=upBg

    self:initUP()

    local downBgH=startH-upBgH-30

    local downBg=LuaCCScale9Sprite:createWithSpriteFrameName("greenBlackBg2.png",CCRect(10,10,12,12),touchUp)
	downBg:setContentSize(CCSizeMake(bgWidth,downBgH))
    downBg:ignoreAnchorPointForPosition(false)
    downBg:setAnchorPoint(ccp(0.5,0))
    downBg:setTouchPriority(-(self.layerNum-1)*20-1)
	downBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,30))
    self.bgLayer:addChild(downBg)
    self.downBg=downBg
    -- downBg:setOpacity(0)

    self:initDown()
end

function acKzhdDialogTab1:initUP()
	local function onLoadIcon(fn,icon)
		if(self and self.upBg and tolua.cast(self.upBg,"LuaCCScale9Sprite")) then
			-- icon:setScale(0.98)
			icon:setPosition(getCenterPoint(self.upBg))
			self.upBg:addChild(icon,1)
		end
	end
	local webImage=LuaCCWebImage:createWithURL(G_downloadUrl("active/kzhdBg.png"),onLoadIcon)

	local function touchTip()
        local tabStr={getlocal("activity_kzhd_tip1"),getlocal("activity_kzhd_tip2"),getlocal("activity_kzhd_tip3")}

        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr)
    end
	local pos=ccp(self.upBg:getContentSize().width-50,self.upBg:getContentSize().height-50)
	local tabStr={}
	G_addMenuInfo(self.upBg,self.layerNum,pos,tabStr,nil,nil,28,touchTip,true)

	local h = self.upBg:getContentSize().height/2+60
	local acLabel = GetTTFLabel(getlocal("activityCountdown"),25)
	acLabel:setAnchorPoint(ccp(0.5,1))
	acLabel:setPosition(ccp(self.upBg:getContentSize().width/2, h))
	self.upBg:addChild(acLabel,2)
	acLabel:setColor(G_ColorYellowPro)

	h = h-30
	local timeStr=acKzhdVoApi:getTimer()
	local messageLabel=GetTTFLabel(timeStr,25)
	messageLabel:setAnchorPoint(ccp(0.5,1))
	messageLabel:setColor(G_ColorYellowPro)
	messageLabel:setPosition(ccp(self.upBg:getContentSize().width/2, h))
	self.upBg:addChild(messageLabel,2)
	self.timeLb=messageLabel

	h = h-40
	local strSize2 = 22
	if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
		strSize2 = 25
	end
	local desLb=GetTTFLabelWrap(getlocal("activity_kzhd_des1"),strSize2,CCSizeMake(self.upBg:getContentSize().width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	desLb:setAnchorPoint(ccp(0.5,1))
	desLb:setPosition(self.upBg:getContentSize().width/2, h)
	self.upBg:addChild(desLb,2)

end

function acKzhdDialogTab1:initDown()
	-- local bgSp=CCSprite:createWithSpriteFrameName("groupSelf.png")
	-- bgSp:setPosition(ccp(self.downBg:getContentSize().width/2+25,self.downBg:getContentSize().height-29))
	-- bgSp:setScaleY(45/bgSp:getContentSize().height)
	-- bgSp:setScaleX(800/bgSp:getContentSize().width)
	-- self.downBg:addChild(bgSp)

	-- local titleLb=GetTTFLabelWrap(getlocal("sample_prop_name_1321"),25,CCSizeMake(self.downBg:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	-- titleLb:setPosition(self.downBg:getContentSize().width/2,self.downBg:getContentSize().height-29)
	-- self.downBg:addChild(titleLb,1)


	local strSize2 = G_getCurChoseLanguage() =="ru"  and 22 or 28
	local titleTb={getlocal("sample_prop_name_1321"),strSize2,G_ColorWhite}

	local titleLbSize=CCSizeMake(300,0)
	local titleBg,titleL=G_createNewTitle(titleTb,titleLbSize)
	self.downBg:addChild(titleBg)
	titleBg:setPosition(self.downBg:getContentSize().width/2,self.downBg:getContentSize().height-29-15)

	local listStartH=self.downBg:getContentSize().height-80-40

    local listCenterW=self.downBg:getContentSize().width/2
    local jiangeW=200
    local jiangeH=235

    if(G_isIphone5())then
		listStartH=listStartH-50
		jiangeH=270
	end

    local shop=acKzhdVoApi:getShop()

    self.listItemTb={}

    for i=1,2 do
    	for j=1,3 do
    		local tag=(i-1)*3 + j
    		local shopCfg=shop["i" .. tag]
    		local function touchListItem()
				if G_checkClickEnable()==false then
					do return end
				else
					base.setWaitTime=G_getCurDeviceMillTime()
				end
				local giftId=tag
				PlayEffect(audioCfg.mouseClick)
				self.smallDialog=acKzhdVoApi:showGiftBuyDialog(self.layerNum+1,true,true,nil,giftId,shop,self)
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
			listMenu:setPosition(listCenterW+(j-2)*jiangeW,listStartH-(i-1)*jiangeH)
			self.downBg:addChild(listMenu)

			local r=shopCfg.r
			local rewardItem=FormatItem(r)[1]

			-- local icon=G_getItemIcon(rewardItem,100,false,self.layerNum + 1,nil,nil,nil,nil,nil,nil,true)
			local icon=CCSprite:createWithSpriteFrameName("packs" .. tag .. ".png")
			icon:setPosition(listItem:getContentSize().width/2,138)
			listItem:addChild(icon)

			if tag==6 then
				self:addLightBlinker(icon,1)
				self:addLightBlinker(icon,2)
			end
			-- local numLb=GetTTFLabel("×"..rewardItem.num,23)
			-- numLb:setAnchorPoint(ccp(1,0))
			-- numLb:setPosition(listItem:getContentSize().width/2 + 45,93)
			-- listItem:addChild(numLb)
			local redBg=CCSprite:createWithSpriteFrameName("saleRedBg.png")
			redBg:setPosition(listItem:getContentSize().width-25,listItem:getContentSize().height-30)
			redBg:setRotation(20)
			listItem:addChild(redBg)

			local discount=shopCfg.bn
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
			local priceStr=shopCfg.g
			local colorP=G_ColorWhite
			local priceSteSize = 22
			if priceStr==0 then
				priceStr=getlocal("daily_lotto_tip_2")
				colorP=G_ColorGreen
				priceSteSize = 16
				if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
					priceSteSize = 22
				end
			end
			local priceLb=GetTTFLabel(priceStr,priceSteSize)
			priceLb:setAnchorPoint(ccp(1,0.5))
			priceLb:setPosition(listItem:getContentSize().width - 10,20)
			listItem:addChild(priceLb)
			priceLb:setColor(colorP)
    	end
    end

    self:refresh()
end

function acKzhdDialogTab1:addLightBlinker(parent,flag)
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

function acKzhdDialogTab1:addDesLb1()
	if self.desLb1 then
		self.desLb1:removeFromParentAndCleanup(true)
	end

    local desLb
    local colorTb
    local leftNum=acKzhdVoApi:getLeftNum()

    local desLb=getlocal("activity_kzhd_des2",{leftNum})
    if leftNum==0 then
    	desLb=getlocal("activity_kzhd_des3")
    	colorTb={G_ColorWhite}
    else
    	desLb=getlocal("activity_kzhd_des2",{leftNum})
    	colorTb={G_ColorWhite,G_ColorYellowPro,G_ColorWhite}
    end


	self.desLb1,self.lbHeight=G_getRichTextLabel(desLb,colorTb,24,self.downBg:getContentSize().width-60,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    self.desLb1:setAnchorPoint(ccp(0.5,1))
    self.desLb1:setPosition(ccp(self.downBg:getContentSize().width/2,self.downBg:getContentSize().height+self.lbHeight/2-80))
    self.downBg:addChild(self.desLb1,2)

    if(G_isIphone5())then
		self.desLb1:setPosition(ccp(self.downBg:getContentSize().width/2,self.downBg:getContentSize().height+self.lbHeight/2-80-30))
	end

    


end

function acKzhdDialogTab1:alreadyBuyAdd(listItem,tag,flag)
	local blackBg=tolua.cast(listItem:getChildByTag(100+tag),"LuaCCScale9Sprite")
	local buyLb=tolua.cast(listItem:getChildByTag(200+tag),"CCLabelTTF")
	local lbBg=tolua.cast(listItem:getChildByTag(400+tag),"CCSprite")

	if flag==true then
		if blackBg==nil then
			local function showTip()
			end
			blackBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),showTip)
			blackBg:setTouchPriority(-(self.layerNum-1)*20-3)
			blackBg:setContentSize(listItem:getContentSize())
			blackBg:setAnchorPoint(ccp(0,0))
			blackBg:setPosition(0,0)
			blackBg:setOpacity(100)
			listItem:addChild(blackBg,2)
			blackBg:setTag(100+tag)
		end
		if buyLb==nil then
			buyLb=GetTTFLabelWrap(getlocal("hasBuy"),22,CCSizeMake(listItem:getContentSize().width-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			listItem:addChild(buyLb,4)
			buyLb:setPosition(listItem:getContentSize().width/2,138)
			buyLb:setColor(G_ColorRed)
			buyLb:setTag(200+tag)

			lbBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg_black.png")
			listItem:addChild(lbBg,3)
			lbBg:setPosition(listItem:getContentSize().width/2,138)
			lbBg:setTag(400+tag)
			
		end
	else
		if blackBg then
			blackBg:removeFromParentAndCleanup(true)
		end
		if buyLb then
			buyLb:removeFromParentAndCleanup(true)
		end
		if lbBg then
			lbBg:removeFromParentAndCleanup(true)
		end

	end
end

function acKzhdDialogTab1:refreshLock(listItem,tag,flag)
	local lockSp=tolua.cast(listItem:getChildByTag(300+tag),"CCSprite")
	if flag then
		if lockSp then
			lockSp:removeFromParentAndCleanup(true)
		end
	else
		if lockSp==nil then
			lockSp=CCSprite:createWithSpriteFrameName("LockIcon.png")
			lockSp:setPosition(ccp(30,listItem:getContentSize().height-30))
			lockSp:setScale(0.5)
			listItem:addChild(lockSp,3)
			lockSp:setTag(300+tag)
		end

	end
end


function acKzhdDialogTab1:tick()
	if self.timeLb then
    	self.timeLb:setString(acKzhdVoApi:getTimer())
    end
end

function acKzhdDialogTab1:refresh(isKuatian)
	local shop=acKzhdVoApi:getShop()
	local buyId=acKzhdVoApi:getBuyId()
	if self.listItemTb then
		for k,v in pairs(self.listItemTb) do
			local shopCfg=shop["i" .. k]
			local preid=shopCfg.preid
			if preid and preid~="" then
				local flag2=false --前面的是否购买
				if k<=buyId then
					flag2=true
				elseif k-buyId==1 then
					flag2=true
				end
				self:refreshLock(v,k,flag2)
			end

			local flag=false -- 是否购买
			if k<=buyId then
				flag=true
			end
			self:alreadyBuyAdd(v,k,flag)

		end
	end
	self:addDesLb1()
	if isKuatian then
		if self.smallDialog and self.smallDialog.close then
			self.smallDialog:close()
			self.smallDialog=nil
		end
	end
end


function acKzhdDialogTab1:fastTick()
	
end

function acKzhdDialogTab1:updateAcTime()
end

function acKzhdDialogTab1:dispose()
	if self.smallDialog and self.smallDialog.close then
		self.smallDialog:close()
		self.smallDialog=nil
	end

	self.upBg=nil
	self.downBg=nil
	self.listItemTb=nil

end



