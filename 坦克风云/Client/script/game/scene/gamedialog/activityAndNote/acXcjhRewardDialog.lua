-- @Author hj
-- @Description 新春聚惠兑奖板子
-- @Date 2018-12-24

acXcjhRewardDialog = {}

function acXcjhRewardDialog:new(layer,partent)
	local nc = {
		layerNum = layer,
		partent = partent,
		maxNum = 5,
		rewardTb = {},
		nowticketNumber = {},
		ticketList = {}
	}
	setmetatable(nc,self)
	self.__index = self
	return nc
end

function acXcjhRewardDialog:init()

	self.bgLayer=CCLayer:create()
	self:doUserHandler()
	self:initTableView()
	return self.bgLayer

end

function acXcjhRewardDialog:doUserHandler( ... )

	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	
	local adaSize 
    if G_getIphoneType() == G_iphoneX then 
        adaSize = CCSizeMake(G_VisibleSizeWidth,1090)
    elseif G_getIphoneType() == G_iphone5 then
        adaSize = CCSizeMake(G_VisibleSizeWidth,976)
    else        
        adaSize = CCSizeMake(G_VisibleSizeWidth,800)
    end

    self.ticketList = acXcjhVoApi:getTicketList()
    
	local function onLoadIcon(fn,icon)

		if self and self.bgLayer and  tolua.cast(self.bgLayer,"CCLayer") then

			icon:setAnchorPoint(ccp(0.5,0.5))
			icon:setPosition(ccp(G_VisibleSizeWidth/2,(G_VisibleSizeHeight-155)/2))

			-- 裁切适配区域
			local clipper=CCClippingNode:create()
			clipper:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
			clipper:setAnchorPoint(ccp(0.5,0))
			clipper:setPosition(G_VisibleSizeWidth/2,0)

			local stencil=CCDrawNode:getAPolygon(adaSize,1,1)
			clipper:setStencil(stencil) 
			clipper:addChild(icon)
			self.bgLayer:addChild(clipper)
		end
		if acXcjhVoApi:getVersion(  )==2 then
			local function onLoadIcon(fn,icon)
				if self and self.bgLayer and tolua.cast(self.bgLayer,"CCLayer") then
					icon:setAnchorPoint(ccp(0.5,1))
					icon:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160))
					self.bgLayer:addChild(icon)
				end
			end 
			local webImage=LuaCCWebImage:createWithURL(G_downloadUrl("xcjh/xcjh1_2_v2.png"),onLoadIcon)
		end

	end

	local webImage
	if acXcjhVoApi:getVersion(  )==2 then
		webImage=LuaCCWebImage:createWithURL(G_downloadUrl("xcjh/xcjh1_v2.jpg"),onLoadIcon)
	else
		webImage=LuaCCWebImage:createWithURL(G_downloadUrl("xcjh/xcjh_3.jpg"),onLoadIcon)
	end

	spriteController:addPlist("public/packsImage.plist")
   	spriteController:addTexture("public/packsImage.png")
   	spriteController:addPlist("public/acThfb.plist")
   	spriteController:addTexture("public/acThfb.png")


	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    self.maxNum = acXcjhVoApi:getSpRewardPicNum()
    self.rewardTb = acXcjhVoApi:getReward()

    local activeKuang = LuaCCScale9Sprite:createWithSpriteFrameName("orangeKuang.png",CCRect(15,15,1,1),function()end)
    activeKuang:setContentSize(CCSizeMake(G_VisibleSizeWidth-20,200))
    activeKuang:setAnchorPoint(ccp(0.5,1))
    activeKuang:setPosition(ccp(self.bgLayer:getContentSize().width/2,G_VisibleSizeHeight-160-100))
    if acXcjhVoApi:getVersion()==2 then
    	activeKuang:setOpacity(0)
    end
    self.bgLayer:addChild(activeKuang)

    self:initRewardArea(activeKuang)

    local giftNode = CCNode:create()
	giftNode:setContentSize(CCSizeMake(96*#self.rewardTb+20*(#self.rewardTb-1),100))
	giftNode:setAnchorPoint(ccp(0.5,1))
	giftNode:setPosition(ccp(self.bgLayer:getContentSize().width/2,G_VisibleSizeHeight-160-100-215))
	giftNode:setScale(0.9)
	self.giftNode = giftNode
	self.bgLayer:addChild(giftNode)

	for k,v in pairs(self.rewardTb) do
		
		local index 
	    if v.isSp and v.isSp == 1 then
    		
    		index = 1
    		local tipNode = CCNode:create()
			tipNode:setContentSize(CCSizeMake(100,100))
			tipNode:setAnchorPoint(ccp(0.5,0.5))
			tipNode:setPosition(ccp(40+(96+20)*(index-1),48))
			giftNode:addChild(tipNode)

			local lightBg1 = CCSprite:createWithSpriteFrameName("equipShine.png")
			lightBg1:setPosition(ccp(tipNode:getContentSize().width/2,tipNode:getContentSize().height/2))
	        local rotateBy = CCRotateBy:create(4,360)
	        local reverseBy = rotateBy:reverse()
			lightBg1:runAction(CCRepeatForever:create(reverseBy))
			tipNode:addChild(lightBg1)

	        local lightBg = CCSprite:createWithSpriteFrameName("equipShine.png")
	        lightBg:setPosition(ccp(tipNode:getContentSize().width/2,tipNode:getContentSize().height/2))
	        local rotateBy = CCRotateBy:create(4,360)
	        lightBg:runAction(CCRepeatForever:create(rotateBy))
	        tipNode:addChild(lightBg)

	    else
	    	index = v.id+1
	    end
	   	local titleStr = getlocal("reward_title_"..index)

		--奖励库
	    local function rewardPoolHandler()
	        if G_checkClickEnable()==false then
	            do return end
	        else
	            base.setWaitTime=G_getCurDeviceMillTime()
	        end
	        PlayEffect(audioCfg.mouseClick)

	        --显示奖池
	        require "luascript/script/game/scene/gamedialog/activityAndNote/acThrivingSmallDialog"
	        local rewardTb = FormatItem(self.rewardTb[self.maxNum-index+1].reward,true,true)
	        -- 礼包的价值
	        local value = self.rewardTb[self.maxNum-index+1].value
	        local descStr = getlocal("activity_xcjh_rewardDesc",{self.maxNum+1-index,titleStr})
	        local needTb = {"xcjh",titleStr,descStr,rewardTb,SizeOfTable(rewardTb),value}
	        local bigAwardDia = acThrivingSmallDialog:new(self.layerNum+1,needTb)
	        bigAwardDia:init()
	    end

	    local giftStr = G_getPacksImg(index,self.maxNum-1)
	    local giftSp = LuaCCSprite:createWithSpriteFrameName(giftStr,rewardPoolHandler)
	    giftNode:addChild(giftSp)
	    giftSp:setTouchPriority(-(self.layerNum-1)*20-4)
	   	giftSp:setAnchorPoint(ccp(0,1))
	   	giftSp:setPosition(ccp((96+20)*(index-1),95))	

	   	local strSize = 22
	   	local adaW = 96
	   	if G_isAsia() == false then
	   		strSize = 20
	   		adaW = 130
	   		if G_getCurChoseLanguage() == "de" then
	   			strSize = 15
	   		end
	   	end

	   	local titleLb = GetTTFLabelWrap(titleStr,strSize,CCSizeMake(adaW,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
	   	titleLb:setAnchorPoint(ccp(0.5,1))
	   	giftSp:addChild(titleLb)
	   	titleLb:setPosition(ccp(giftSp:getContentSize().width/2,-5))

	end

	local strSize = 20
    if G_isAsia() == false then
    	strSize = 18
    	if G_getCurChoseLanguage() == "de" then
    		strSize = 15
    	end
    end



	local rewardDescLabel = GetTTFLabelWrap(getlocal("activity_xcjh_rewardPrompt"),strSize,CCSize(450,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    rewardDescLabel:setAnchorPoint(ccp(0.5,0.5))
    rewardDescLabel:setColor(G_ColorYellowPro)

	local levelBg1 = LuaCCScale9Sprite:createWithSpriteFrameName("newBlackFadeBar.png",CCRect(0,0,1,9),function ()end)
	if acXcjhVoApi:getVersion()==1 then
    	levelBg1:setOpacity(255*0.8)
    else
    	levelBg1:setOpacity(255*0.5)
    end
    levelBg1:setContentSize(CCSizeMake(450,40))
    levelBg1:setAnchorPoint(ccp(0.5,1))
    levelBg1:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-162-55))
    levelBg1:addChild(rewardDescLabel)
    rewardDescLabel:setPosition(ccp(levelBg1:getContentSize().width/2,levelBg1:getContentSize().height/2))
    self.bgLayer:addChild(levelBg1)

    local adaH = 0
    if G_getIphoneType() == G_iphone4 then
    	adaH = 60
    end
	local noTicketLabel = GetTTFLabel(getlocal("activity_xcjh_Noticket"),30,true)
	noTicketLabel:setAnchorPoint(ccp(0.5,0.5))
	noTicketLabel:setColor(G_ColorGray)
	noTicketLabel:setPosition(ccp(G_VisibleSizeWidth/2,280-adaH))
	self.noTicketLabel = noTicketLabel
	self.bgLayer:addChild(noTicketLabel,10)
	self:refreshTip()
end

function acXcjhRewardDialog:initTableView( ... )


	local function callBack(...)
        return self:eventHandler(...)
    end
    local function nilFunc( ... )
    end
    local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("acChunjiepansheng_taskListBg_v4.png",CCRect(5,5,1,1),nilFunc)
    tvBg:setOpacity(255*0.8)
    self.bgLayer:addChild(tvBg,2)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20,G_VisibleSizeHeight-160-140-300-20))
    tvBg:setAnchorPoint(ccp(0,0))
    tvBg:setPosition(ccp(10,20))

    local function useHandler( ... )
    	if acXcjhVoApi:isRewardTime() == false then
    		if acXcjhVoApi:isGetRewardTime() == true then
    			smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("activity_xcjh_notRewardTime"), 30)
    		else
    			smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("activity_xcjh_allend"), 30)
    		end
    		do return end
    	else

    		if acXcjhVoApi:getResetPropNum() <= 0 then
    			smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("notenoughprop"), 30)
    			do return end
    		else
    			if acXcjhVoApi:isCanupdate() == false then
					smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("activity_xcjh_noTicketCanupdate"), 30)
					do return end
				end
	    		local function confirmHandler( ... )
					local function callback(fn,data)
						local ret,sData = base:checkServerData(data)
						if ret == true then
							if sData.data and sData.data.xcjh then
								acXcjhVoApi:updateSpecialData(sData.data.xcjh)
	                			self:refreshTv()
	                			self:refreshStatus()
							end
						end
					end
					socketHelper:acXcjhModify(1,1,callback)
				end

				local function secondTipFunc(sbFlag)
		            local keyName = "xcjhModify"
		            local sValue=base.serverTime .. "_" .. sbFlag
		            G_changePopFlag(keyName,sValue)
				end
		        local keyName = "xcjhModify"
		        if G_isPopBoard(keyName) then
		           G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("activity_xcjh_prompt"),true,confirmHandler,secondTipFunc)
		        else
		            confirmHandler()
		        end
    		end
    	end
    end

    G_createBotton(tvBg,ccp(tvBg:getContentSize().width-100,tvBg:getContentSize().height-40),{getlocal("prop_use_type2"),25},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",useHandler,0.7,-(self.layerNum-1)*20-4)

    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-30,G_VisibleSizeHeight-160-140-320-20-50),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    self.tv:setPosition(ccp(15,25))
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)

    local activeTb = {ac={c2=1}}
    local activeProp = FormatItem(activeTb,true)[1]

    local function showNewReward()
    	G_showNewPropInfo(self.layerNum+1,true,true,nil,activeProp,true,nil,nil,nil,true)
    end
    local src = acXcjhVoApi:getActivePropImg("c2")
    icon=LuaCCSprite:createWithSpriteFrameName(src,showNewReward)
   	icon:setScale(0.7)
    icon:setTouchPriority(-(self.layerNum-1)*20-4)
    icon:setPosition(ccp(tvBg:getContentSize().width-220,tvBg:getContentSize().height-40))
    tvBg:addChild(icon)


    local hasLabel = GetTTFLabel(getlocal("super_weapon_rob_fragment_has_num",{acXcjhVoApi:getResetPropNum()}),22,true)
    hasLabel:setAnchorPoint(ccp(1,0.5))
    hasLabel:setPosition(ccp(tvBg:getContentSize().width-270,tvBg:getContentSize().height-40))
    tvBg:addChild(hasLabel)
    self.hasLabel = hasLabel

    if acXcjhVoApi:getResetPropNum() == 0 then
    	hasLabel:setColor(G_ColorRed)
    end

    --设置tableview的遮罩
    local stencilBgUp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
    stencilBgUp:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,590))
    stencilBgUp:setAnchorPoint(ccp(0.5,1))
    stencilBgUp:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight))
    stencilBgUp:setTouchPriority(-(self.layerNum-1)*20-3)
    stencilBgUp:setVisible(false)
    stencilBgUp:setIsSallow(true)
    self.bgLayer:addChild(stencilBgUp,10)

    local stencilBgDown=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
    stencilBgDown:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,25))
    stencilBgDown:setAnchorPoint(ccp(0.5,0))
    stencilBgDown:setPosition(ccp(G_VisibleSizeWidth/2,0))
    stencilBgDown:setTouchPriority(-(self.layerNum-1)*20-3)
    stencilBgDown:setVisible(false)
    stencilBgDown:setIsSallow(true)
    self.bgLayer:addChild(stencilBgDown,10)

end

function acXcjhRewardDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return #self.ticketList
    elseif fn=="tableCellSizeForIndex" then
        return  CCSizeMake(G_VisibleSizeWidth-30,160)
    elseif fn=="tableCellAtIndex" then
    	local cell=CCTableViewCell:new()
        cell:autorelease()
        self:initCell(idx+1,cell)
        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function acXcjhRewardDialog:initRewardArea(activeKuang)

	local pointBg
	if acXcjhVoApi:getVersion(  )==2 then
		pointBg=CCSprite:createWithSpriteFrameName("acXcjh_caidai_v2.png")
	else
		pointBg=LuaCCScale9Sprite:createWithSpriteFrameName("acChunjiepansheng_caidai_v4.png",CCRect(43,34,2,2),function() end)
		pointBg:setContentSize(CCSizeMake(300,pointBg:getContentSize().height))
	end
	pointBg:setAnchorPoint(ccp(0.5,1))
	pointBg:setPosition(ccp(activeKuang:getContentSize().width/2,activeKuang:getContentSize().height-5))
	activeKuang:addChild(pointBg)

	local specialRewardLb
	if acXcjhVoApi:getVersion()==2 then
		local str = getlocal("activity_xcjh_specialReward")
		specialRewardLb=GetTTFLabelWrap(str,30,CCSizeMake(pointBg:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
		specialRewardLb:setAnchorPoint(ccp(0.5,0.5))
    	specialRewardLb:setPosition(getCenterPoint(pointBg))
		G_addShadow(pointBg,specialRewardLb,str,30,false,0,2)
	else
		specialRewardLb=GetTTFLabelWrap(getlocal("activity_xcjh_specialReward"),25,CCSizeMake(pointBg:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
		specialRewardLb:setAnchorPoint(ccp(0.5,0.5))
    	specialRewardLb:setPosition(getCenterPoint(pointBg))
	end
	specialRewardLb:setColor(G_ColorYellowPro2)
	pointBg:addChild(specialRewardLb)

	local rewardNode = CCNode:create()
	rewardNode:setContentSize(CCSizeMake(104*self.maxNum+10*(self.maxNum-1),125))
	rewardNode:setAnchorPoint(ccp(0.5,0))
	rewardNode:setPosition(ccp(activeKuang:getContentSize().width/2,3))
	self.rewardNode = rewardNode
	activeKuang:addChild(rewardNode)

	self:refreshHero()

end



function acXcjhRewardDialog:initCell(index,cell)

	local tickeData = self.ticketList[index]
	local status = tickeData[1]
	local ticketTb = tickeData[2]
	cell:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,160))

	local juanZhouSp
	if acXcjhVoApi:getVersion()==2 then
		juanZhouSp = LuaCCScale9Sprite:createWithSpriteFrameName("juanzhou_v2.png",CCRect(5,17,1,1),function()end)
		juanZhouSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,140))
	else
		juanZhouSp = LuaCCScale9Sprite:createWithSpriteFrameName("juanzhou.png",CCRect(60,36,1,1),function()end)
		juanZhouSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,160))
	end
	juanZhouSp:setAnchorPoint(ccp(0.5,0.5))
	juanZhouSp:setPosition(ccp(cell:getContentSize().width/2,cell:getContentSize().height/2))
	cell:addChild(juanZhouSp)


	local rewardNode = CCNode:create()
	rewardNode:setContentSize(CCSizeMake(90*self.maxNum,125))
	rewardNode:setAnchorPoint(ccp(0,0.5))
	rewardNode:setPosition(ccp(15,juanZhouSp:getContentSize().height/2))
	juanZhouSp:addChild(rewardNode)

	for i=1,self.maxNum do
		if acXcjhVoApi:getVersion()==2 then
			local heroStr = acXcjhVoApi:getTicketImgByNumber(ticketTb[i])
			local heroSp
			if acXcjhVoApi:getVersion()==1 then
				heroSp = CCSprite:createWithSpriteFrameName(heroStr)
				heroSp:setScale(80/heroSp:getContentSize().width)
				heroSp:setPosition(ccp(90*(i-1),52))
			else
				heroSp = acXcjhVoApi:tankSkinAddBg( heroStr,80 )
				heroSp:setPosition(ccp(90*(i-1)+50,70))
			end
			-- local function showTip1()
			-- 	G_showNewPropInfo(self.layerNum+1,true,true,nil,heroStr) 
		 --    end
			-- local heroSp = G_getItemIcon(heroStr,nil,false,100,showTip1,nil,nil,nil,nil,nil,true)
			juanZhouSp:addChild(heroSp)
			
			
			if acXcjhVoApi:hasRewardNum(ticketTb[i]) == true then
				local blendFunc=ccBlendFunc:new()--混合模式为 ONE ONE
				blendFunc.src=GL_ONE
				blendFunc.dst=GL_ONE

				local effectSp = CCSprite:createWithSpriteFrameName("xcjhChose320.png")
				effectSp:setAnchorPoint(ccp(0.5,0.5))
				if acXcjhVoApi:getVersion()==1 then
					effectSp:setPosition(ccp(90*(i-1),52))
				else
					effectSp:setPosition(ccp(90*(i-1)+50,70))
				end
				effectSp:setBlendFunc(blendFunc)
				juanZhouSp:addChild(effectSp)

				local pzArr = CCArray:create()

				for kk=1,9 do
			        local effect="xcjhChose32"..kk..".png"
			        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(effect)
			        if frame then
			        	pzArr:addObject(frame)
			    	end
			    end
			    local animation=CCAnimation:createWithSpriteFrames(pzArr)
			    animation:setDelayPerUnit(0.083)
			    local animate=CCAnimate:create(animation)
			    local repeatForever=CCRepeatForever:create(animate)

				effectSp:runAction(repeatForever)
			end
		else
			local calendarUp = CCSprite:createWithSpriteFrameName("calendarUp.png")
			calendarUp:setAnchorPoint(ccp(0,0.5))
			calendarUp:setPosition(ccp(90*(i-1),108))
			rewardNode:addChild(calendarUp,1)
			calendarUp:setScale(0.9)

			local calendarDown = CCSprite:createWithSpriteFrameName("calendarDown.png")
			calendarDown:setAnchorPoint(ccp(0,0.5))
			calendarDown:setPosition(ccp(90*(i-1),52))
			rewardNode:addChild(calendarDown,2)
			calendarDown:setScale(0.9)

			local nail = CCSprite:createWithSpriteFrameName("nail.png")
			nail:setAnchorPoint(ccp(0.5,0.5))
			nail:setPosition(calendarUp:getContentSize().width/2,calendarUp:getContentSize().height/2)
			calendarUp:addChild(nail,2)

			local heroStr = acXcjhVoApi:getTicketImgByNumber(ticketTb[i])
			local heroSp = CCSprite:createWithSpriteFrameName(heroStr)
			heroSp:setScale(61/heroSp:getContentSize().width)
			calendarDown:addChild(heroSp)
			heroSp:setPosition(ccp(calendarDown:getContentSize().width/2,calendarDown:getContentSize().height/2))
			
			if acXcjhVoApi:hasRewardNum(ticketTb[i]) == true then
				local blendFunc=ccBlendFunc:new()--混合模式为 ONE ONE
				blendFunc.src=GL_ONE
				blendFunc.dst=GL_ONE

				local effectSp = CCSprite:createWithSpriteFrameName("xcjhChose320.png")
				effectSp:setAnchorPoint(ccp(0.5,0.5))
				effectSp:setPosition(ccp(calendarDown:getContentSize().width/2,calendarDown:getContentSize().height/2))
				effectSp:setBlendFunc(blendFunc)
				-- effectSp:setScaleX(60/effectSp:getContentSize().width)
				-- effectSp:setScaleY(60/effectSp:getContentSize().height)
				calendarDown:addChild(effectSp)

				local pzArr = CCArray:create()

				for kk=1,9 do
			        local effect="xcjhChose32"..kk..".png"
			        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(effect)
			        if frame then
			        	pzArr:addObject(frame)
			    	end
			    end
			    local animation=CCAnimation:createWithSpriteFrames(pzArr)
			    animation:setDelayPerUnit(0.083)
			    local animate=CCAnimate:create(animation)
			    local repeatForever=CCRepeatForever:create(animate)

				effectSp:runAction(repeatForever)
			end
		end
	end

	local rewardKuang 
	if acXcjhVoApi:getVersion()==2 then
		rewardKuang = LuaCCScale9Sprite:createWithSpriteFrameName("orangeKuang.png",CCRect(15,15,1,1),function()end)
	else
		rewardKuang = LuaCCScale9Sprite:createWithSpriteFrameName("ticketKuang.png",CCRect(26,26,1,1),function()end)
	end
	rewardKuang:setContentSize(CCSizeMake(115,115))
	juanZhouSp:addChild(rewardKuang)
	rewardKuang:setAnchorPoint(ccp(1,0.5))
	rewardKuang:setPosition(ccp(juanZhouSp:getContentSize().width-15,juanZhouSp:getContentSize().height/2))

	local color
	local statusStr
	local adaH = 0
	local quality = acXcjhVoApi:checkStatus(ticketTb)
	if status == 0 then
		-- 判断是否是最终大奖
		if quality == self.maxNum+1 then
			statusStr = getlocal("activity_xcjh_notReward")
			color = G_ColorWhite
			adaH = 40
		else
			local giftStr = G_getPacksImg(quality,self.maxNum-1)
		    local giftSp = CCSprite:createWithSpriteFrameName(giftStr) 
		    giftSp:setScale(0.8)
		    giftSp:setAnchorPoint(ccp(0.5,0))
		   	giftSp:setPosition(rewardKuang:getContentSize().width/2,25)
		   	rewardKuang:addChild(giftSp)
		   	statusStr = getlocal("activity_xcjh_canUpdate")
			color = G_ColorGreen
			if status == 0	and quality == 1 then
		   		giftSp:setPosition(rewardKuang:getContentSize().width/2,15)
			end
		end

		if quality > 1 and quality < self.maxNum+1 then
			local resetTickSp = CCSprite:createWithSpriteFrameName(acXcjhVoApi:getActivePropImg("c2"))
			resetTickSp:setAnchorPoint(ccp(1,1))
			rewardKuang:addChild(resetTickSp)
			resetTickSp:setScale(50/resetTickSp:getContentSize().width)
			resetTickSp:setPosition(ccp(rewardKuang:getContentSize().width+5,rewardKuang:getContentSize().height))

			local function modifyHandler( ... )
				if acXcjhVoApi:isRewardTime() == false then
					if acXcjhVoApi:isGetRewardTime() == true then
		    			smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("activity_xcjh_notRewardTime"), 30)
		    		else
		    			smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("activity_xcjh_allend"), 30)
		    		end
		    		do return end
				else

					if acXcjhVoApi:getResetPropNum() > 0 then
						if acXcjhVoApi:isCanupdate() == false then
							smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("activity_xcjh_noTicketCanupdate"), 30)
							do return end
						end
						local function confirmHandler( ... )
							local function callback(fn,data)
								local ret,sData = base:checkServerData(data)
		    					if ret == true then
		    						if sData.data and sData.data.xcjh then
										acXcjhVoApi:updateSpecialData(sData.data.xcjh)
	                        			self:refreshTv()
	                        			self:refreshStatus()
		    						end
		    					end
							end
							socketHelper:acXcjhModify(index,0,callback)
						end

						local function secondTipFunc(sbFlag)
				            local keyName = "xcjhModify"
				            local sValue=base.serverTime .. "_" .. sbFlag
				            G_changePopFlag(keyName,sValue)
						end
				        local keyName = "xcjhModify"
				        if G_isPopBoard(keyName) then
				           G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("activity_xcjh_prompt"),true,confirmHandler,secondTipFunc)
				        else
				            confirmHandler()
				        end
				    else
				    	smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("notenoughprop"), 30)
			    	end
				end
			end 

			local touchSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1),modifyHandler)
			touchSp:setContentSize(CCSizeMake(100,100))
			touchSp:setAnchorPoint(ccp(1,1))
			touchSp:setPosition(ccp(rewardKuang:getContentSize().width,rewardKuang:getContentSize().height))
			touchSp:setVisible(false)
			touchSp:setTouchPriority(-(self.layerNum-1)*20-2)
			rewardKuang:addChild(touchSp)
		end
	else 
		local quality = acXcjhVoApi:checkStatus(ticketTb)
		color = G_ColorWhite
		statusStr = getlocal("activity_xcjh_alreadyUpdate")	
		local giftStr = G_getPacksImg(quality,self.maxNum-1)
	    local giftSp = CCSprite:createWithSpriteFrameName(giftStr) 
	    giftSp:setScale(0.8)
	    giftSp:setAnchorPoint(ccp(0.5,0))
	   	giftSp:setPosition(rewardKuang:getContentSize().width/2,25)
	   	rewardKuang:addChild(giftSp)
	end

	if status == 0	and quality == 1 then

	else
		local statusLabel = GetTTFLabel(statusStr,20,true)
		statusLabel:setAnchorPoint(ccp(0.5,0))
		statusLabel:setColor(color)
		statusLabel:setPosition(ccp(rewardKuang:getContentSize().width/2,5+adaH))
		rewardKuang:addChild(statusLabel)
	end
end

function acXcjhRewardDialog:refreshStatus( ... )
	if self.hasLabel and tolua.cast(self.hasLabel,"CCLabelTTF") then
		self.hasLabel:setString(getlocal("super_weapon_rob_fragment_has_num",{acXcjhVoApi:getResetPropNum()}))
		if acXcjhVoApi:getResetPropNum() == 0 then
    		self.hasLabel:setColor(G_ColorRed)
    	end
	end
	self:refreshTip()
end


function acXcjhRewardDialog:isGetBigReward(last,now)
	-- 改出特等奖需要发公告
	local paramTab = {}
	paramTab.functionStr="xcjh"
	paramTab.addStr="goTo_see_see"
	paramTab.colorStr="w,y,w"
    local playerName = playerVoApi:getPlayerName() 
    local elblemName = getlocal("reward_title_1")
	local message = {key="activity_xcjh_getSystemMessage",param={playerName,elblemName}}
	chatVoApi:sendSystemMessage(message,paramTab)
end

function acXcjhRewardDialog:refreshTip( ... )
	if self.noTicketLabel and tolua.cast(self.noTicketLabel,"CCLabelTTF") then
		self.ticketList = acXcjhVoApi:getTicketList()
		if #self.ticketList >0 then
			self.noTicketLabel:setPosition(ccp(9999,0))
		else
			local adaH = 0
		    if G_getIphoneType() == G_iphone4 then
		    	adaH = 60
		    end
			self.noTicketLabel:setPosition(ccp(G_VisibleSizeWidth/2,280-adaH))
		end
	end
end



function acXcjhRewardDialog:refreshTv( ... )

	if self.tv then		
		-- local data = CCUserDefault:sharedUserDefault():getStringForKey(playerVoApi:getUid().."@".."xcjh")
		local past = acXcjhVoApi:getSpecialRewardNum(self.ticketList)
		self.ticketList = acXcjhVoApi:getTicketList()
		local now = acXcjhVoApi:getSpecialRewardNum(self.ticketList)
		-- print("hjtest",acXcjhVoApi:isSpeRewardTime(),acXcjhVoApi:isRewardTime(),past,now,data)
		if acXcjhVoApi:isSpeRewardTime()==true and acXcjhVoApi:isRewardTime() == false and now and now ~= 0 then
			local logdata = CCUserDefault:sharedUserDefault():getStringForKey(playerVoApi:getUid().."@".."xcjh")
			if logdata == "" or not logdata then
				self:isGetBigReward()
				local key = playerVoApi:getUid().."@".."xcjh" 
				local value = 1
				CCUserDefault:sharedUserDefault():setStringForKey(key,value)
                CCUserDefault:sharedUserDefault():flush()
			end
		end
		if acXcjhVoApi:isRewardTime() == true and past < now then
			self:isGetBigReward()
		end
		self.tv:reloadData()
	end
end

function acXcjhRewardDialog:refreshHero( ... )

	if self.rewardNode and tolua.cast(self.rewardNode,"CCNode") then

		self.rewardNode:removeAllChildrenWithCleanup(true)
		self.nowticketNumber =  acXcjhVoApi:getTiketNumber()
		for i=1,self.maxNum do

			local calendarDown
			if acXcjhVoApi:getVersion()==2 then
				calendarDown = CCSprite:createWithSpriteFrameName("nationalDayBall.png")
				calendarDown:setAnchorPoint(ccp(0.5,0))
				calendarDown:setPosition(ccp(64+104*(i-1),5))
				calendarDown:setTag(1016)
				calendarDown:setScale(0.9)
				self.rewardNode:addChild(calendarDown,2)
			else
				local calendarUp = CCSprite:createWithSpriteFrameName("calendarUp.png")
				calendarUp:setAnchorPoint(ccp(0.5,1))
				calendarUp:setPosition(ccp(52+114*(i-1),117))
				calendarUp:setScale(0.9)
				self.rewardNode:addChild(calendarUp,1)

				calendarDown = CCSprite:createWithSpriteFrameName("calendarDown.png")
				calendarDown:setAnchorPoint(ccp(0.5,0))
				calendarDown:setPosition(ccp(54+114*(i-1),5))
				calendarDown:setTag(1016)
				calendarDown:setScale(0.9)
				self.rewardNode:addChild(calendarDown,2)

				local nail = CCSprite:createWithSpriteFrameName("nail.png")
				nail:setAnchorPoint(ccp(0.5,0.5))
				nail:setPosition(calendarUp:getContentSize().width/2,calendarUp:getContentSize().height/2)
				calendarUp:addChild(nail,2)
			end

			if self.nowticketNumber[i] then
				local heroStr = acXcjhVoApi:getTicketImgByNumber(self.nowticketNumber[i])
				local heroSp
				if acXcjhVoApi:getVersion()==1 then
					heroSp = CCSprite:createWithSpriteFrameName(heroStr)
					heroSp:setScale(61/heroSp:getContentSize().width)
					heroSp:setPosition(ccp(calendarDown:getContentSize().width/2,calendarDown:getContentSize().height/2))
				else
					heroSp = acXcjhVoApi:tankSkinAddBg( heroStr,86 )
					calendarDown:setOpacity(0)
					heroSp:setPosition(ccp(calendarDown:getContentSize().width/2,calendarDown:getContentSize().height/2+10))
				end
				
				calendarDown:addChild(heroSp,2)

			else
				local textLabel = GetTTFLabel("?",40,true)
				textLabel:setAnchorPoint(ccp(0.5,0.5))
				if acXcjhVoApi:getVersion()==2 then
					textLabel:setPosition(ccp(calendarDown:getContentSize().width/2,calendarDown:getContentSize().height/3*2))
				else
					textLabel:setPosition(getCenterPoint(calendarDown))
				end
				textLabel:setColor(G_ColorBrown)
				calendarDown:addChild(textLabel)
			end

		end

	end
end

function acXcjhRewardDialog:dispose( ... )
	spriteController:removePlist("public/packsImage.plist")
   	spriteController:removeTexture("public/packsImage.png")
   	spriteController:removePlist("public/acThfb.plist")
   	spriteController:removeTexture("public/acThfb.png")
end