acYueduHeroTwoDialog = commonDialog:new()

function acYueduHeroTwoDialog:new()
	local nc = {}
	setmetatable(nc, self)
	self.__index = self
	if acYueduHeroTwoVoApi and acYueduHeroTwoVoApi:getVersion()==1 then
		self.colorTab = {G_ColorGreen,G_ColorYellowPro} 
	elseif  acYueduHeroTwoVoApi and (acYueduHeroTwoVoApi:getVersion()==2 or acYueduHeroTwoVoApi:getVersion()==3) then
		self.colorTab = {G_ColorWhite,G_ColorGreen}
	else
		self.colorTab = nil
	end
	return nc
end	

function acYueduHeroTwoDialog:resetTab()
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))   
end	

function acYueduHeroTwoDialog:initTableView()
	local function callback( ... )
	end

	local hd= LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,400),nil)
	self:tabClick(0,false)
end

function acYueduHeroTwoDialog:doUserHandler()
	spriteController:addPlist("public/bgFireImage.plist")
    spriteController:addTexture("public/bgFireImage.png")
    self.panelLineBg:setOpacity(0)
	local backSprie0
	local backSprie0Size=CCSizeMake(G_VisibleSizeWidth-16,G_VisibleSizeHeight-100)
	if acYueduHeroTwoVoApi and (acYueduHeroTwoVoApi:getVersion()==2 or acYueduHeroTwoVoApi:getVersion()==3) then
		CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
		spriteController:addPlist("public/activePicUseInNewGuid.plist")
	    spriteController:addTexture("public/activePicUseInNewGuid.png")
	    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

		backSprie0=CCNode:create()
		local function onLoadImage(fn,sprite)
			if self and backSprie0 and tolua.cast(backSprie0,"CCNode") then
				sprite:setAnchorPoint(ccp(0.5,1))
	            sprite:setPosition(backSprie0Size.width/2,backSprie0Size.height)
	            backSprie0:addChild(sprite)
	            -- if G_getIphoneType()==G_iphone5 then
	            -- 	sprite:setScaleY(1.03)
	            -- elseif G_getIphoneType()==G_iphoneX then
	            -- 	sprite:setScaleY(1.02)
	            -- end
			end
		end
		LuaCCWebImage:createWithURL(G_downloadUrl("active/acYdjl2_topBg_v2.jpg"),onLoadImage)
	else
		backSprie0 =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),function ()end)
	end
    backSprie0:setContentSize(backSprie0Size)
    backSprie0:setAnchorPoint(ccp(0.5,0))
    backSprie0:setPosition(ccp(G_VisibleSizeWidth*0.5,14))
    self.bgLayer:addChild(backSprie0)

    self.adaH = 0
    if G_getIphoneType() == G_iphoneX then
    	self.adaH = 60
    end
    local addPosYIn5_1 = 0
    self.addPosYIn5_2 = 0
    if G_isIphone5() then
    	addPosYIn5_1 = 10
    	self.addPosYIn5_2 = 30
    end

	local pointLineAncP = {ccp(1,0.5),ccp(0,0.5)}
    local pointLinePosWscal = {0.35,0.65}

    self.rewardIconTb = {}
    
	self.reward1 = acYueduHeroTwoVoApi:getRewardById(1)
	self.reward2 = acYueduHeroTwoVoApi:getRewardById(2)

	-- 时间和item
	local h = G_VisibleSizeHeight-100
	
	if acYueduHeroTwoVoApi and (acYueduHeroTwoVoApi:getVersion()==2 or acYueduHeroTwoVoApi:getVersion()==3) then
		local timeBg=LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png",CCRect(103,0,2,80),function()end)
		timeBg:setContentSize(CCSizeMake(616,timeBg:getContentSize().height))
		timeBg:setAnchorPoint(ccp(0.5,1))
		timeBg:setPosition(backSprie0:getContentSize().width/2,backSprie0:getContentSize().height)
		backSprie0:addChild(timeBg,1)

		local acTimeLb=GetTTFLabel(acYueduHeroTwoVoApi:getTimeStr(),24)
		acTimeLb:setPosition((timeBg:getContentSize().width-80)/2+15,timeBg:getContentSize().height/2+17)
		timeBg:addChild(acTimeLb)
		self.timeLb=acTimeLb
	else
		local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),25)
		acLabel:setAnchorPoint(ccp(0.5,1))
		acLabel:setPosition(ccp(G_VisibleSizeWidth*0.5,h-10))--(G_VisibleSizeWidth - 20)/2, h))
		self.bgLayer:addChild(acLabel)
		acLabel:setColor(G_ColorYellowPro)

		h = h-30

		local acVo = acYueduHeroTwoVoApi:getAcVo()
		local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
		local messageLabel=GetTTFLabel(timeStr,25)
		messageLabel:setAnchorPoint(ccp(0.5,1))
		messageLabel:setColor(G_ColorYellowPro)
		messageLabel:setPosition(ccp(G_VisibleSizeWidth*0.5,h-15))--G_VisibleSizeWidth - 20)/2, h))
		self.bgLayer:addChild(messageLabel)
		self.timeLb=messageLabel
	end
	self:updateAcTime()

	local desStr = GetTTFLabelWrap(getlocal("activity_acYueduTwoHero_Des"),23,CCSizeMake(G_VisibleSizeWidth*0.9,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	desStr:setPosition(ccp(G_VisibleSizeWidth*0.5,h-80-self.adaH/3))
	self.bgLayer:addChild(desStr,1)
	-- desStr:setColor(G_ColorYellowPro)

	local function touchInfo()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		local tabStr={}
		for i=1,2 do
			table.insert(tabStr,getlocal("activity_acYueduHero_tip"..i))
		end
		local titleStr=getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        local textSize = 25
        if G_getCurChoseLanguage() =="ru" then
	        textSize = 20 
	    end
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,textSize)
	end

	local menuItemDesc
	if acYueduHeroTwoVoApi and (acYueduHeroTwoVoApi:getVersion()==2 or acYueduHeroTwoVoApi:getVersion()==3) then
		desStr:setAnchorPoint(ccp(0.5,1))
		desStr:setPositionY(h-230+desStr:getContentSize().height+3)

		local desLabelBg=CCSprite:createWithSpriteFrameName("blackGradualChange.png")
		desLabelBg:setAnchorPoint(ccp(0.5,0.5))
		local nScaleX=(desStr:getContentSize().width+6)/desLabelBg:getContentSize().width
		desLabelBg:setScaleX(nScaleX)
		desLabelBg:setScaleY((desStr:getContentSize().height+6)/desLabelBg:getContentSize().height)
		desLabelBg:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,desStr:getPositionY()-desStr:getContentSize().height*0.5))
		self.bgLayer:addChild(desLabelBg)

		menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touchInfo,1,nil,0)
	else
		menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touchInfo,1,nil,0)
		menuItemDesc:setScale(0.8)
	end
	menuItemDesc:setAnchorPoint(ccp(1,0.5))
	local menuDesc=CCMenu:createWithItem(menuItemDesc)
	menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
	menuDesc:setPosition(ccp(self.bgLayer:getContentSize().width-25, h-15))
	self.bgLayer:addChild(menuDesc,2)

	if acYueduHeroTwoVoApi and (acYueduHeroTwoVoApi:getVersion()==2 or acYueduHeroTwoVoApi:getVersion()==3) then
		menuDesc:setPositionY(h-25)
	else
		if G_isIphone5() ==false then
			h = h-35
		else
			h = h-30
		end
	end

	local height = (G_VisibleSizeHeight-210)/2
	local function touch()
    end
    local capInSet = CCRect(20, 20, 10, 10)
    local bWidth,bHeight
    if G_getIphoneType() == G_iphoneX then
    	bHeight=height - 80 - 100
    else
    	bHeight=height - 80
    end
    local backSprie1
	if acYueduHeroTwoVoApi and (acYueduHeroTwoVoApi:getVersion()==2 or acYueduHeroTwoVoApi:getVersion()==3) then
		bWidth=616
		backSprie1=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),touch)
	else
		bWidth=600
		backSprie1 =LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),touch)--"rewardPanelBg3.png",CCRect(19,19,2,2)
	end
	local backSize=CCSizeMake(bWidth,bHeight)
    backSprie1:setContentSize(backSize)
    backSprie1:setAnchorPoint(ccp(0.5,1))
    backSprie1:setPosition(ccp(self.bgLayer:getContentSize().width/2,h-130-self.adaH))
    self.backSprie1 = backSprie1
    self.bgLayer:addChild(backSprie1)

    if acYueduHeroTwoVoApi and (acYueduHeroTwoVoApi:getVersion()==2 or acYueduHeroTwoVoApi:getVersion()==3) then
    	backSprie1:setPositionY(h-280)
    	if G_getIphoneType() == G_iphone4 then
    		backSprie1:setPositionY(h-245)
    	end
    	local topSp=CCSprite:createWithSpriteFrameName("monthlyBar.png")
    	topSp:setAnchorPoint(ccp(0.5,1))
    	topSp:setPosition(backSprie1:getContentSize().width/2,backSprie1:getContentSize().height+5)
    	backSprie1:addChild(topSp)
    else
	    local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
	    pointSp1:setPosition(ccp(2,backSprie1:getContentSize().height/2))
	    backSprie1:addChild(pointSp1)
	    local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
	    pointSp2:setPosition(ccp(backSprie1:getContentSize().width-2,backSprie1:getContentSize().height/2))
	    backSprie1:addChild(pointSp2)

		CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	  	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
	    local bgSp1=CCSprite:createWithSpriteFrameName("semicircleGreen.png")---
	    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	  	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
		bgSp1:setPosition(ccp(backSprie1:getContentSize().width/2,backSprie1:getContentSize().height+1));
		bgSp1:setAnchorPoint(ccp(0.5,0))
		-- bgSp1:setScaleY(60/bgSp1:getContentSize().height)
		bgSp1:setScaleX(400/bgSp1:getContentSize().width)
		backSprie1:addChild(bgSp1)
	end

	local str1=getlocal("activity_acYueduHero_subtitle1")
	local title1
	if acYueduHeroTwoVoApi and (acYueduHeroTwoVoApi:getVersion()==2 or acYueduHeroTwoVoApi:getVersion()==3) then
		local titleBg=CCSprite:createWithSpriteFrameName("believerTitleBg.png")
		titleBg:setPosition(backSprie1:getContentSize().width/2,backSprie1:getContentSize().height-titleBg:getContentSize().height/2-15)
		backSprie1:addChild(titleBg)
		title1 = GetTTFLabel(str1,22,true)
	else
		title1 = GetTTFLabel(str1,30)
	end
	backSprie1:addChild(title1)
	title1:setColor(G_ColorYellowPro)
	title1:setPosition(backSprie1:getContentSize().width*0.5,backSprie1:getContentSize().height+5+title1:getContentSize().height*0.5)
	self.title1 = title1
	local _lineSpPosY=0
	if acYueduHeroTwoVoApi and (acYueduHeroTwoVoApi:getVersion()==2 or acYueduHeroTwoVoApi:getVersion()==3) then
		title1:setPositionY(backSprie1:getContentSize().height-title1:getContentSize().height/2-25)
	else
		local bgSpWidth1 = backSprie1:getContentSize().width
		for i=1,2 do
	        local pointLine = CCSprite:createWithSpriteFrameName("greenPointAndLine.png")
	        pointLine:setAnchorPoint(pointLineAncP[i])
	        pointLine:setPosition(ccp(bgSpWidth1*pointLinePosWscal[i],title1:getPositionY()))
	        backSprie1:addChild(pointLine)
	        if i ==1 then
	          pointLine:setFlipX(true)
	        end
	    end

		local conditionStr1=getlocal("activity_cuikulaxiu_gotoBtn")
		local conditionLb1 = GetTTFLabel(conditionStr1,28)
		conditionLb1:setAnchorPoint(ccp(0,1))
		backSprie1:addChild(conditionLb1)
		conditionLb1:setPosition(10, backSprie1:getContentSize().height-15-addPosYIn5_1)
		conditionLb1:setColor(G_ColorGreen)
		_lineSpPosY = conditionLb1:getPositionY() - conditionLb1:getContentSize().height - 15
	end

	--LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)--new_cutline
	local lineSp1 = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine3.png",CCRect(2,1,1,1),function ()end)
	lineSp1:setAnchorPoint(ccp(0.5,0.5));
	lineSp1:setPosition(backSprie1:getContentSize().width*0.5,_lineSpPosY)--LineCross
	-- lineSp1:setContentSize
	lineSp1:setScaleX((self.bgLayer:getContentSize().width-60)/lineSp1:getContentSize().width)
	self.lineSp1 = lineSp1
	backSprie1:addChild(lineSp1)

	local _fontSize=25
	if acYueduHeroTwoVoApi and (acYueduHeroTwoVoApi:getVersion()==2 or acYueduHeroTwoVoApi:getVersion()==3) then
		_fontSize=20
		local rpCoinSp=CCSprite:createWithSpriteFrameName("rpCoin.png")
		rpCoinSp:setScale(88/rpCoinSp:getContentSize().height)
		rpCoinSp:setPosition(180,title1:getPositionY()-30-rpCoinSp:getContentSize().height*rpCoinSp:getScale()/2)
		backSprie1:addChild(rpCoinSp)
		if G_getIphoneType()==G_iphone5 then
			rpCoinSp:setPositionY(rpCoinSp:getPositionY()-20)
			lineSp1:setPositionY(rpCoinSp:getPositionY()-rpCoinSp:getContentSize().height*rpCoinSp:getScale()/2-20)
		else
			lineSp1:setPositionY(rpCoinSp:getPositionY()-rpCoinSp:getContentSize().height*rpCoinSp:getScale()/2)
		end
	end
	-- 通过副文本的方式添加颜色
	local alreadyStr1 =getlocal("activity_acYueduHero_already1",{acYueduHeroTwoVoApi:getRecord(1),acYueduHeroTwoVoApi:getCost(1)})
	local numstr = acYueduHeroTwoVoApi:getRecord(1) .. "/" .. acYueduHeroTwoVoApi:getCost(1)
	local allStr1 = alreadyStr1.."<rayimg>"..numstr
	local alreadyLb1=G_getRichTextLabel(allStr1,self.colorTab,25,250,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	alreadyLb1:setAnchorPoint(ccp(0,0.5))
	self.backSprie1:addChild(alreadyLb1)
	alreadyLb1:setPosition(20,lineSp1:getPositionY() - 50)
	if acYueduHeroTwoVoApi and (acYueduHeroTwoVoApi:getVersion()==2 or acYueduHeroTwoVoApi:getVersion()==3) then
		if G_getIphoneType()==G_iphone5 then
			alreadyLb1:setPosition(250,title1:getPositionY()-85)
		else
			alreadyLb1:setPosition(250,title1:getPositionY()-55)
		end
		
	end
	self.alreadyLb1 = alreadyLb1
	local function touchItem(tag)
		if G_checkClickEnable()==false then
		    do
		        return
		    end
		else
		    base.setWaitTime=G_getCurDeviceMillTime()
		end
		local flag=acYueduHeroTwoVoApi:getFlagByTag(tag)
		if flag ==1 then--"rewardPanelBg3.png",CCRect(19,19,2,2)
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_acYueduHero_noget"),30)
			return
		elseif flag==2 then
		else
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_acYueduHero_alreadyGet"),30)
			return
		end
		local function callback(fn,data)
			local ret,sData = base:checkServerData(data)
			if ret==true then

				acYueduHeroTwoVoApi:setFlag(tag,1)				
				local rewardM 
				if tag==1 then
					rewardM = acYueduHeroTwoVoApi:getRewardById(1)
				else
					rewardM = acYueduHeroTwoVoApi:getRewardById(2)
				end
				for k,v in pairs(rewardM) do
					if v.type=="h" then
					 	heroVoApi:addSoul(v.key,v.num)
				 	else
				 		 G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
					end
					 
				end
				G_showRewardTip(rewardM,true)
				self:checkVisible()

			end

		end
		socketHelper:acYueduHeroLingjiangTwo(tag,"active.ydjl2.reward",callback)

	end
	local lingquItem1=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touchItem,1,getlocal("daily_scene_get"),33)
	lingquItem1:setAnchorPoint(ccp(0.5,0.5))
	lingquItem1:setScale(0.6)
	if acYueduHeroTwoVoApi and (acYueduHeroTwoVoApi:getVersion()==2 or acYueduHeroTwoVoApi:getVersion()==3) then
	else
		if G_isIphone5() then
			lingquItem1:setScale(0.7)
			lingquItem1:setPositionX(lingquItem1:getPositionX()-15)
		end
	end
	local lingquBtn1=CCMenu:createWithItem(lingquItem1);
	lingquBtn1:setTouchPriority(-(self.layerNum-1)*20-4);
	if acYueduHeroTwoVoApi and (acYueduHeroTwoVoApi:getVersion()==2 or acYueduHeroTwoVoApi:getVersion()==3) then
		lingquBtn1:setPosition(ccp(530,25+100*0.5+self.addPosYIn5_2))
	else
		lingquBtn1:setPosition(ccp(530,alreadyLb1:getPositionY()))
	end
	backSprie1:addChild(lingquBtn1)
	self.lingquItem1=lingquItem1

	local aLingquLb1 = GetTTFLabel(getlocal("activity_hadReward"),25)
	backSprie1:addChild(aLingquLb1)
	if acYueduHeroTwoVoApi and (acYueduHeroTwoVoApi:getVersion()==2 or acYueduHeroTwoVoApi:getVersion()==3) then
		aLingquLb1:setPosition(lingquBtn1:getPosition())
	else
		aLingquLb1:setPosition(ccp(500,alreadyLb1:getPositionY()))
	end
	aLingquLb1:setColor(G_ColorGreen)
	self.aLingquLb1=aLingquLb1

	local _iconStartX=100
	local _iconSpaceX=190
	if acYueduHeroTwoVoApi and (acYueduHeroTwoVoApi:getVersion()==2 or acYueduHeroTwoVoApi:getVersion()==3) then
		local rewardLb=GetTTFLabelWrap(getlocal("donateReward"),20,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		rewardLb:setAnchorPoint(ccp(0,0.5))
		rewardLb:setPosition(5,25+100*0.5+self.addPosYIn5_2)
		backSprie1:addChild(rewardLb)
		_iconStartX=150
		_iconSpaceX=120
	end
	
	local num1 = SizeOfTable(self.reward1)
	for i=1,num1 do
		local item = self.reward1[i]
		local function callback()
			if i == 1 then
				local function refreshCall( )
					  -- print("refreshCall~~~~~~~~~~~")
					  local function callbackR(fn,data)
							local ret,sData = base:checkServerData(data)
							if ret==true then
								if sData and sData.data and sData.data.ydjl2 then

									local refData = sData.data.ydjl2
									acYueduHeroTwoVoApi:setIsRef(refData.r)--刷新 更换
									acYueduHeroTwoVoApi:setCurRewardTb(refData.rd)--刷新 当前使用的奖励库

									self:Animating(1,backSprie1)
								end
						  	end
				  	  end
				  	  socketHelper:acYueduHeroLingjiangTwo(1,"active.ydjl2.refreward",callbackR)
				end 
				local refreshLimit=tonumber(acYueduHeroTwoVoApi:getRefreshTb()[1]) or 1
				local sureStr,isRef,isReceievd = getlocal("armorMatrix_change"),acYueduHeroTwoVoApi:getIsRef(1),acYueduHeroTwoVoApi:getFlagByTag(1)
				local refStr,isCanRef = getlocal("change_num",{(refreshLimit-tonumber(isRef)).."/"..refreshLimit}),true
				-- print("checkNum-----isRef---11111-->",checkNum,isRef)
				if isReceievd == 3 then
					refStr  = getlocal("activity_acYueduTwoHero_receivedStr")
					isCanRef = false
					isRef = refreshLimit
				else
					if tonumber(isRef)>=refreshLimit then
						isCanRef = false
					end
				end
				local specialUse = {ydjl2={[1]=refStr,[2]=refreshCall,[3]=isRef,[4]=isCanRef,[5]=refreshLimit},hasAni=false,useBgSp=2,useBgSpSize={},useSureOrCancleBtn=6,sureBtnStr=sureStr,cancleBtnStr=""}
				local function closeFun( )
				end 
				self.propInfoDia = G_showNewPropInfo(self.layerNum+1,true,nil,closeFun,item,nil,nil,nil,specialUse)
			else
				G_showNewPropInfo(self.layerNum+1,true,nil,nil,item,nil,nil,nil)
			end
		end
		local icon,scale=G_getItemIcon(item,100,false,self.layerNum,callback,nil)
		backSprie1:addChild(icon)
		icon:setTouchPriority(-(self.layerNum-1)*20-4)
		icon:setPosition(ccp(_iconStartX+(i-1)*_iconSpaceX,25+icon:getContentSize().height*scale*0.5+self.addPosYIn5_2))
		

		local numLb = GetTTFLabel("x" .. item.num,24)
		numLb:setAnchorPoint(ccp(1,0))
		icon:addChild(numLb)
		numLb:setPosition(icon:getContentSize().width-10, 5)
		numLb:setScale(1/scale)

		if i == 1 then
			self.rewardIconTb[1] = icon
			self.bgFireSp1 = CCSprite:createWithSpriteFrameName("bgFire_1.png")
			self.bgFireSp1:setPosition(ccp(icon:getPositionX(),icon:getPositionY() - 20 ))
			self.bgFireSp1:setVisible(false)
			backSprie1:addChild(self.bgFireSp1,99)
		  
		  	local isReceievd = acYueduHeroTwoVoApi:getFlagByTag(1)
			local refreshLimit = tonumber(acYueduHeroTwoVoApi:getRefreshTb()[1]) or 1
			local isRef = acYueduHeroTwoVoApi:getIsRef(1)
			if tonumber(isRef)<refreshLimit and isReceievd~=3 then
			  	local refIcon = CCSprite:createWithSpriteFrameName("refreshIcon.png")
			  	refIcon:setAnchorPoint(ccp(1,1))
			  	refIcon:setPosition(ccp(icon:getContentSize().width-8,icon:getContentSize().height-8))
			  	icon:addChild(refIcon)
			end
		end
	end

	-- 下面
    local backSprie2
    if acYueduHeroTwoVoApi and (acYueduHeroTwoVoApi:getVersion()==2 or acYueduHeroTwoVoApi:getVersion()==3) then
    	backSprie2=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),touch)
    else
    	backSprie2 =LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),touch)  
    end
    backSprie2:setContentSize(backSize)
    backSprie2:setAnchorPoint(ccp(0.5,0))
    backSprie2:setPosition(ccp(self.bgLayer:getContentSize().width/2,30+self.adaH))
    self.backSprie2 = backSprie2
    self.bgLayer:addChild(backSprie2)

    if acYueduHeroTwoVoApi and (acYueduHeroTwoVoApi:getVersion()==2 or acYueduHeroTwoVoApi:getVersion()==3) then
    	local topSp=CCSprite:createWithSpriteFrameName("monthlyBar.png")
    	topSp:setAnchorPoint(ccp(0.5,1))
    	topSp:setPosition(backSprie2:getContentSize().width/2,backSprie2:getContentSize().height+5)
    	backSprie2:addChild(topSp)
   	else
	    local pointSp3=CCSprite:createWithSpriteFrameName("pointThree.png")
	    pointSp3:setPosition(ccp(2,backSprie2:getContentSize().height/2))
	    backSprie2:addChild(pointSp3)
	    local pointSp4=CCSprite:createWithSpriteFrameName("pointThree.png")
	    pointSp4:setPosition(ccp(backSprie2:getContentSize().width-2,backSprie2:getContentSize().height/2))
	    backSprie2:addChild(pointSp4)

	    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	  	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
	    local bgSp2=CCSprite:createWithSpriteFrameName("semicircleGreen.png")
	    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	  	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
		bgSp2:setPosition(ccp(backSprie2:getContentSize().width/2,backSprie2:getContentSize().height+1));
		bgSp2:setAnchorPoint(ccp(0.5,0))
		-- bgSp2:setScaleY(60/bgSp2:getContentSize().height)
		bgSp2:setScaleX(400/bgSp2:getContentSize().width)
		backSprie2:addChild(bgSp2)
	end

	local str2=getlocal("activity_acYueduHero_subtitle2")
	local title2
	if acYueduHeroTwoVoApi and (acYueduHeroTwoVoApi:getVersion()==2 or acYueduHeroTwoVoApi:getVersion()==3) then
		local titleBg=CCSprite:createWithSpriteFrameName("believerTitleBg.png")
		titleBg:setPosition(backSprie2:getContentSize().width/2,backSprie2:getContentSize().height-titleBg:getContentSize().height/2-15)
		backSprie2:addChild(titleBg)
		title2 = GetTTFLabel(str2,22,true)
	else
		title2 = GetTTFLabel(str2,30)
	end
	title2:setColor(G_ColorYellowPro)
	backSprie2:addChild(title2)
	title2:setPosition(backSprie2:getContentSize().width*0.5,backSprie2:getContentSize().height+5+title2:getContentSize().height*0.5)
	self.title2 = title2
	local _lineSp2PosY=0
	if acYueduHeroTwoVoApi and (acYueduHeroTwoVoApi:getVersion()==2 or acYueduHeroTwoVoApi:getVersion()==3) then
		title2:setPositionY(backSprie2:getContentSize().height-title2:getContentSize().height/2-25)
	else
		local bgSpWidth2 = backSprie2:getContentSize().width
		for i=1,2 do
	        local pointLine = CCSprite:createWithSpriteFrameName("greenPointAndLine.png")
	        pointLine:setAnchorPoint(pointLineAncP[i])
	        pointLine:setPosition(ccp(bgSpWidth2*pointLinePosWscal[i],title2:getPositionY()))
	        backSprie2:addChild(pointLine)
	        if i ==1 then
	          pointLine:setFlipX(true)
	        end
	    end

		local lbSize2 = 25
		if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
			lbSize2 =28
		end 
		local conditionStr2=getlocal("activity_vipAction_tab2")
		local conditionLb2 = GetTTFLabel(conditionStr2,lbSize2)
		conditionLb2:setAnchorPoint(ccp(0,1))
		backSprie2:addChild(conditionLb2)
		conditionLb2:setPosition(10, backSprie2:getContentSize().height-15-addPosYIn5_1)
		conditionLb2:setColor(G_ColorGreen)
		_lineSp2PosY=conditionLb2:getPositionY() - conditionLb2:getContentSize().height - 15
	end

	local lineSp2 = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine3.png",CCRect(2,1,1,1),function ()end)
	lineSp2:setAnchorPoint(ccp(0.5,0.5));
	lineSp2:setPosition(backSprie2:getContentSize().width*0.5,_lineSp2PosY)
	lineSp2:setScaleX((self.bgLayer:getContentSize().width-60)/lineSp2:getContentSize().width)
	self.lineSp2 = lineSp2
	backSprie2:addChild(lineSp2)

	if acYueduHeroTwoVoApi and (acYueduHeroTwoVoApi:getVersion()==2 or acYueduHeroTwoVoApi:getVersion()==3) then
		_fontSize=20
		local goldNewSp=CCSprite:createWithSpriteFrameName("iconGoldNew3.png")
		goldNewSp:setScale(88/goldNewSp:getContentSize().height)
		goldNewSp:setPosition(180,title2:getPositionY()-30-goldNewSp:getContentSize().height*goldNewSp:getScale()/2)
		backSprie2:addChild(goldNewSp)
		if G_getIphoneType()==G_iphone5 then
			goldNewSp:setPositionY(goldNewSp:getPositionY()-20)
			lineSp2:setPositionY(goldNewSp:getPositionY()-goldNewSp:getContentSize().height*goldNewSp:getScale()/2-20)
		else
			lineSp2:setPositionY(goldNewSp:getPositionY()-goldNewSp:getContentSize().height*goldNewSp:getScale()/2)
		end
	end

	local alreadyStr2= getlocal("activity_acYueduHero_already2",{acYueduHeroTwoVoApi:getRecord(2),acYueduHeroTwoVoApi:getCost(2)})
	local numstr2 = acYueduHeroTwoVoApi:getRecord(2) .. "/" .. acYueduHeroTwoVoApi:getCost(2)
	local allStr2 = alreadyStr2.."<rayimg>"..numstr2
	local alreadyLb2=G_getRichTextLabel(allStr2,self.colorTab,25,250,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	alreadyLb2:setAnchorPoint(ccp(0,0.5))
	backSprie2:addChild(alreadyLb2)
	alreadyLb2:setPosition(20,self.lineSp2:getPositionY() - 50)
	if acYueduHeroTwoVoApi and (acYueduHeroTwoVoApi:getVersion()==2 or acYueduHeroTwoVoApi:getVersion()==3) then
		if G_getIphoneType()==G_iphone5 then
			alreadyLb2:setPosition(250,title2:getPositionY()-85)
		else
			alreadyLb2:setPosition(250,title2:getPositionY()-55)
		end
	end
	self.alreadyLb2 = alreadyLb2
	local lingquItem2=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touchItem,2,getlocal("daily_scene_get"),33)
	lingquItem2:setAnchorPoint(ccp(0.5,0.5))
	lingquItem2:setScale(0.6)
	if acYueduHeroTwoVoApi and (acYueduHeroTwoVoApi:getVersion()==2 or acYueduHeroTwoVoApi:getVersion()==3) then
	else
		if G_isIphone5() then
			lingquItem2:setScale(0.7)
			lingquItem2:setPositionX(lingquItem2:getPositionX()-15)
		end
	end
	local lingquBtn2=CCMenu:createWithItem(lingquItem2);
	lingquBtn2:setTouchPriority(-(self.layerNum-1)*20-4);
	if acYueduHeroTwoVoApi and (acYueduHeroTwoVoApi:getVersion()==2 or acYueduHeroTwoVoApi:getVersion()==3) then
		lingquBtn2:setPosition(ccp(530,25+100*0.5+self.addPosYIn5_2))
	else
		lingquBtn2:setPosition(ccp(530,alreadyLb2:getPositionY()))
	end
	backSprie2:addChild(lingquBtn2)
	self.lingquItem2=lingquItem2

	local aLingquLb2 = GetTTFLabel(getlocal("activity_hadReward"),25)
	backSprie2:addChild(aLingquLb2)
	if acYueduHeroTwoVoApi and (acYueduHeroTwoVoApi:getVersion()==2 or acYueduHeroTwoVoApi:getVersion()==3) then
		aLingquLb2:setPosition(lingquBtn2:getPosition())
	else
		aLingquLb2:setPosition(ccp(500,alreadyLb2:getPositionY()))
	end
	aLingquLb2:setColor(G_ColorGreen)
	self.aLingquLb2=aLingquLb2

	_iconSpaceX=200
	if acYueduHeroTwoVoApi and (acYueduHeroTwoVoApi:getVersion()==2 or acYueduHeroTwoVoApi:getVersion()==3) then
		local rewardLb=GetTTFLabelWrap(getlocal("donateReward"),20,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		rewardLb:setAnchorPoint(ccp(0,0.5))
		rewardLb:setPosition(5,25+100*0.5+self.addPosYIn5_2)
		backSprie2:addChild(rewardLb)
		_iconSpaceX=120
	end
	local num2 = SizeOfTable(self.reward2)
	for i=1,num2 do
		local item = self.reward2[i]
		local function callback()
			if i == 1 then
				local function refreshCall( )
					  -- print("refreshCall~~~~~~~~~~~")
					  local function callbackR(fn,data)
							local ret,sData = base:checkServerData(data)
							if ret==true then
								if sData and sData.data and sData.data.ydjl2 then
									local refData = sData.data.ydjl2
									acYueduHeroTwoVoApi:setIsRef(refData.r)--刷新 更换
									acYueduHeroTwoVoApi:setCurRewardTb(refData.rd)--刷新 当前使用的奖励库

									self:Animating(2,backSprie2)
								end
						  	end
				  	  end
				  	  socketHelper:acYueduHeroLingjiangTwo(2,"active.ydjl2.refreward",callbackR)
					  
				end 
				local refreshLimit=tonumber(acYueduHeroTwoVoApi:getRefreshTb()[2])
				local sureStr,isRef,isReceievd = getlocal("armorMatrix_change"),acYueduHeroTwoVoApi:getIsRef(2),acYueduHeroTwoVoApi:getFlagByTag(2)
				local refStr,isCanRef = getlocal("change_num",{(refreshLimit-tonumber(isRef)).."/"..refreshLimit}),true
				-- print("checkNum-----isRef---222222-->",checkNum,isRef)
				if isReceievd == 3 then
					refStr  = getlocal("activity_acYueduTwoHero_receivedStr")
					isCanRef = false
					isRef = refreshLimit
				else
					if tonumber(isRef)>=refreshLimit then
						isCanRef = false
					end
				end
				print("refStr")
				local specialUse = {ydjl2={[1]=refStr,[2]=refreshCall,[3]=isRef,[4]=isCanRef,[5]=refreshLimit},hasAni=false,useBgSp=2,useBgSpSize={},useSureOrCancleBtn=6,sureBtnStr=sureStr,cancleBtnStr=""}
				local function closeFun( )
				end  
				self.propInfoDia = G_showNewPropInfo(self.layerNum+1,true,nil,closeFun,item,nil,nil,nil,specialUse)
			else
				G_showNewPropInfo(self.layerNum+1,true,nil,nil,item,nil,nil,nil)
			end
		end
		local icon,scale=G_getItemIcon(item,100,false,self.layerNum,callback,nil)
		backSprie2:addChild(icon)
		icon:setTouchPriority(-(self.layerNum-1)*20-4)
		icon:setPosition(_iconStartX+(i-1)*_iconSpaceX, icon:getContentSize().height*0.5*scale+25+self.addPosYIn5_2)
		

		local numLb = GetTTFLabel("x" .. item.num,24)
		numLb:setAnchorPoint(ccp(1,0))
		icon:addChild(numLb)
		numLb:setPosition(icon:getContentSize().width-10, 5)
		numLb:setScale(1/scale)

		if i == 1 then
		  	self.rewardIconTb[2] = icon
		 	self.bgFireSp2 = CCSprite:createWithSpriteFrameName("bgFire_1.png")
		 	self.bgFireSp2:setPosition(ccp(icon:getPositionX(),icon:getPositionY() - 20 ))
		  	backSprie2:addChild(self.bgFireSp2,99)
		  	self.bgFireSp2:setVisible(false)
		  
		  	local isReceievd = acYueduHeroTwoVoApi:getFlagByTag(2)
			local refreshLimit = tonumber(acYueduHeroTwoVoApi:getRefreshTb()[2]) or 1
			local isRef = acYueduHeroTwoVoApi:getIsRef(2)
			if tonumber(isRef)<refreshLimit and isReceievd~=3 then
				local refIcon = CCSprite:createWithSpriteFrameName("refreshIcon.png")
			  	refIcon:setAnchorPoint(ccp(1,1))
			  	refIcon:setPosition(ccp(icon:getContentSize().width-8,icon:getContentSize().height-8))
			  	icon:addChild(refIcon)
			end
		end
	end

	local istoday = acYueduHeroTwoVoApi:isToday()
	if istoday==false then
		self:refreshApi()
    	self:refreshDialog()
	else
		self:checkVisible()
	end

end

function acYueduHeroTwoDialog:checkVisible()
	local flag1 = acYueduHeroTwoVoApi:getFlagByTag(1)
	local flag2 = acYueduHeroTwoVoApi:getFlagByTag(2)

	if self.aLingquLb1 and self.lingquItem1 then
		if flag1==3 then
			self.aLingquLb1:setVisible(true)
			self.lingquItem1:setVisible(false)
			self.lingquItem1:setEnabled(false)
		else
			self.aLingquLb1:setVisible(false)
			self.lingquItem1:setVisible(true)
			self.lingquItem1:setEnabled(true)
		end
	end
	
	if self.aLingquLb2 and self.lingquItem2 then	
		if flag2==3 then
			self.aLingquLb2:setVisible(true)
			self.lingquItem2:setVisible(false)
			self.lingquItem2:setEnabled(false)
		else
			self.aLingquLb2:setVisible(false)
			self.lingquItem2:setVisible(true)
			self.lingquItem2:setEnabled(true)
		end
	end
end


function acYueduHeroTwoDialog:refreshApi()
	acYueduHeroTwoVoApi:setLastTime(base.serverTime)
	-- print("in refreshApi dialog~~~~~~~~~~~~~")
	acYueduHeroTwoVoApi:setRecord(1,0)
	acYueduHeroTwoVoApi:setRecord(2,0)
	acYueduHeroTwoVoApi:setFlag(1,0)
	acYueduHeroTwoVoApi:setFlag(2,0)

	acYueduHeroTwoVoApi:setIsRef()
end

function acYueduHeroTwoDialog:refreshDialog()
	local arrGroup 
    local colorarr 
	if self.alreadyLb1 then
		self.alreadyLb1:removeFromParentAndCleanup(true)
		local alreadyStr1 =getlocal("activity_acYueduHero_already1",{acYueduHeroTwoVoApi:getRecord(1),acYueduHeroTwoVoApi:getCost(1)})
		local numstr = acYueduHeroTwoVoApi:getRecord(1) .. "/" .. acYueduHeroTwoVoApi:getCost(1)
		local allStr1 = alreadyStr1.."<rayimg>"..numstr
		local alreadyLb1=G_getRichTextLabel(allStr1,self.colorTab,25,250,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		alreadyLb1:setAnchorPoint(ccp(0,0.5))
		self.backSprie1:addChild(alreadyLb1,1000)
		alreadyLb1:setPosition(20,self.lineSp1:getPositionY() - 50)
		if acYueduHeroTwoVoApi and (acYueduHeroTwoVoApi:getVersion()==2 or acYueduHeroTwoVoApi:getVersion()==3) then
			if G_getIphoneType()==G_iphone5 then
				alreadyLb1:setPosition(250,self.title1:getPositionY()-85)
			else
				alreadyLb1:setPosition(250,self.title1:getPositionY()-55)
			end
		
		end
		-- arrGroup,colorarr = acYueduHeroTwoDialog:getFreshCCArray(1)	
        -- self.alreadyLb1:setString(arrGroup,colorarr,25,kCCTextAlignmentLeft)
     --    if G_getCurChoseLanguage() == "ar" then
     --    	self.alreadyLb1:setString(arrGroup,colorarr,25,kCCTextAlignmentRight)
   		-- end
   		alreadyLb1 = self.alreadyLb1
	end
	if self.alreadyLb2 then
		self.alreadyLb2:removeFromParentAndCleanup(true)
		-- arrGroup,colorarr = acYueduHeroTwoDialog:getFreshCCArray(2)	
		-- self.alreadyLb2:setString(arrGroup,colorarr,25,kCCTextAlignmentLeft)
		-- if G_getCurChoseLanguage() == "ar" then
  --       	self.alreadyLb1:setString(arrGroup,colorarr,25,kCCTextAlignmentRight)
  --  		end
  		local alreadyStr2= getlocal("activity_acYueduHero_already2",{acYueduHeroTwoVoApi:getRecord(2),acYueduHeroTwoVoApi:getCost(2)})
		local numstr2 = acYueduHeroTwoVoApi:getRecord(2) .. "/" .. acYueduHeroTwoVoApi:getCost(2)
		local allStr2 = alreadyStr2.."<rayimg>"..numstr2
		local alreadyLb2=G_getRichTextLabel(allStr2,self.colorTab,25,250,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		alreadyLb2:setAnchorPoint(ccp(0,0.5))
		self.backSprie2:addChild(alreadyLb2)
		alreadyLb2:setPosition(20,self.lineSp2:getPositionY() - 50)
		if acYueduHeroTwoVoApi and (acYueduHeroTwoVoApi:getVersion()==2 or acYueduHeroTwoVoApi:getVersion()==3) then
			if G_getIphoneType()==G_iphone5 then
				alreadyLb2:setPosition(250,self.title2:getPositionY()-85)
			else
				alreadyLb2:setPosition(250,self.title2:getPositionY()-55)
			end
		end
		self.alreadyLb2 = alreadyLb2
	end
	self:checkVisible()
end

function acYueduHeroTwoDialog:updateAcTime()
	if acYueduHeroTwoVoApi and (acYueduHeroTwoVoApi:getVersion()==2 or acYueduHeroTwoVoApi:getVersion()==3) then
		if self and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
			self.timeLb:setString(acYueduHeroTwoVoApi:getTimeStr())
		end
	else
	    local acVo=acYueduHeroTwoVoApi:getAcVo()
	    if acVo and self.timeLb then
	        G_updateActiveTime(acVo,self.timeLb)
	    end
	end
end

function acYueduHeroTwoDialog:tick()
    local vo=acYueduHeroTwoVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end
    local istoday = acYueduHeroTwoVoApi:isToday()
    if istoday then
    else
    	self:refreshApi()
    	self:refreshDialog()
    	if self.propInfoDia then--跨天强制关闭将领刷新面板
    		self.propInfoDia:close()
    	end
    end
    self:updateAcTime()
end


function acYueduHeroTwoDialog:Animating(checkNum,backSprie)
	local function chanRewardBtn( )
		if self.rewardIconTb[checkNum] then
			self.rewardIconTb[checkNum]:removeFromParentAndCleanup(true)
		end
		local item = acYueduHeroTwoVoApi:getRewardById(checkNum)[1]
		local function callback()
				local function refreshCall( )
					  -- print("refreshCall~~~~~~~~~~~")
					  local function callbackR(fn,data)
							local ret,sData = base:checkServerData(data)
							if ret==true then
								if sData and sData.data and sData.data.ydjl2 then
									local refData = sData.data.ydjl2
									acYueduHeroTwoVoApi:setIsRef(refData.r)--刷新 更换
									acYueduHeroTwoVoApi:setCurRewardTb(refData.rd)--刷新 当前使用的奖励库

									self:Animating(checkNum)
								end
						  	end
				  	  end
				  	  socketHelper:acYueduHeroLingjiangTwo(checkNum,"active.ydjl2.refreward",callbackR)
					  
				end 
				local refreshLimit = tonumber(acYueduHeroTwoVoApi:getRefreshTb()[checkNum]) or 1
				local sureStr,isRef,isReceievd = getlocal("armorMatrix_change"),acYueduHeroTwoVoApi:getIsRef(checkNum),acYueduHeroTwoVoApi:getFlagByTag(checkNum)
				-- print("checkNum-----isRef----->",checkNum,isRef)
				local refStr,isCanRef = getlocal("change_num",{(refreshLimit-tonumber(isRef)).."/"..refreshLimit}),true
				if isReceievd == 3 then
					refStr  = getlocal("activity_acYueduTwoHero_receivedStr")
					isCanRef = false
					isRef = refreshLimit
				else
					if tonumber(isRef)>=refreshLimit then
						isCanRef = false
					end
				end
				local specialUse = {ydjl2={[1]=refStr,[2]=refreshCall,[3]=isRef,[4]=isCanRef,[5]=refreshLimit},hasAni=false,useBgSp=2,useBgSpSize={},useSureOrCancleBtn=6,sureBtnStr=sureStr,cancleBtnStr=""}
				local function closeFun( )
				end  
				self.propInfoDia = G_showNewPropInfo(self.layerNum+1,true,nil,closeFun,item,nil,nil,nil,specialUse)
		end
		local icon,scale=G_getItemIcon(item,100,false,self.layerNum,callback,nil)
		-- backSprie:addChild(icon)
		if checkNum==1 then
			self.backSprie1:addChild(icon)
		else
			self.backSprie2:addChild(icon)
		end
		icon:setTouchPriority(-(self.layerNum-1)*20-4)
		if acYueduHeroTwoVoApi and (acYueduHeroTwoVoApi:getVersion()==2 or acYueduHeroTwoVoApi:getVersion()==3) then
			icon:setPosition(150, icon:getContentSize().height*0.5*scale+25+self.addPosYIn5_2)
		else
			icon:setPosition(100, icon:getContentSize().height*0.5*scale+25+self.addPosYIn5_2)
		end
		self.rewardIconTb[checkNum] = icon

		local numLb = GetTTFLabel("x" .. item.num,24)
		numLb:setAnchorPoint(ccp(1,0))
		icon:addChild(numLb)
		numLb:setPosition(icon:getContentSize().width-10, 5)
		numLb:setScale(1/scale)
	end 



	if checkNum ==1 then
		  if self.bgFireSp1 then
		  	  local pzArr=CCArray:create()
			  for kk=1,20 do
			      local nameStr="bgFire_"..kk..".png"
			      local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
			      pzArr:addObject(frame)
			  end
			  local animation=CCAnimation:createWithSpriteFrames(pzArr)
			  animation:setDelayPerUnit(0.05)
			  local animate=CCAnimate:create(animation)
			  self.bgFireSp1:setVisible(true)
	          self.bgFireSp1:runAction(animate)
	      end

	else
		  if self.bgFireSp2 then
		  	  local pzArr=CCArray:create()
			  for kk=1,20 do
			      local nameStr="bgFire_"..kk..".png"
			      local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
			      pzArr:addObject(frame)
			  end
			  local animation=CCAnimation:createWithSpriteFrames(pzArr)
			  animation:setDelayPerUnit(0.05)
			  local animate=CCAnimate:create(animation)
			  self.bgFireSp2:setVisible(true)
	          self.bgFireSp2:runAction(animate)
	      end

	end

	local function visibleCallback( )
       chanRewardBtn()
    end 
    local function animationVisCall( )
    	if checkNum==1 then
    		if self.bgFireSp1 then
    			self.bgFireSp1:removeFromParentAndCleanup(true)
    			self.bgFireSp1=nil
			end
		else
			if self.bgFireSp2 then
				self.bgFireSp2:removeFromParentAndCleanup(true)
				self.bgFireSp2=nil
			end
    	end
    	local icon = self.rewardIconTb[checkNum]
    	if icon and tolua.cast(icon,"CCSprite") then
    		local isReceievd = acYueduHeroTwoVoApi:getFlagByTag(checkNum)
	    	local refreshLimit = tonumber(acYueduHeroTwoVoApi:getRefreshTb()[checkNum]) or 1
			local isRef = acYueduHeroTwoVoApi:getIsRef(checkNum)
			if tonumber(isRef)<refreshLimit and isReceievd~=3 then
				local bgFireSp = CCSprite:createWithSpriteFrameName("bgFire_1.png")
				bgFireSp:setPosition(ccp(icon:getPositionX(),icon:getPositionY() - 20 ))
				bgFireSp:setVisible(false)
				if checkNum==1 then
					self.bgFireSp1=bgFireSp
					self.backSprie1:addChild(bgFireSp,99)
				else
					self.bgFireSp2=bgFireSp
					self.backSprie2:addChild(bgFireSp,99)
				end

				local refIcon = CCSprite:createWithSpriteFrameName("refreshIcon.png")
				refIcon:setAnchorPoint(ccp(1,1))
				refIcon:setPosition(ccp(icon:getContentSize().width-8,icon:getContentSize().height-8))
				icon:addChild(refIcon)
			end
    	end
    	-- if checkNum ==1 then
    	-- 	self.bgFireSp1:setVisible(false)
    	-- else
    	-- 	self.bgFireSp2:setVisible(false)
    	-- end
    end 
    local visCall = CCCallFunc:create(visibleCallback)
    local visCall2 = CCCallFunc:create(animationVisCall)
    local delayTime = CCDelayTime:create(0.6)
    local delayTime2 = CCDelayTime:create(0.4)
    local arr = CCArray:create()
    arr:addObject(delayTime)
    arr:addObject(visCall)
    arr:addObject(delayTime2)
    arr:addObject(visCall2)
    local seq = CCSequence:create(arr)
    self.bgLayer:runAction(seq)
end
--副文本刷新
-- function acYueduHeroTwoDialog:getFreshCCArray(textID)
-- 	local arrGroup = CCArray:create()
--     local colorarr = CCArray:create()
--     local alreadyStr = nil
--     local numstr = nil
--     local allStr = nil
-- 	if textID and textID == 1 then
-- 		alreadyStr = getlocal("activity_acYueduHero_already1",{acYueduHeroTwoVoApi:getRecord(1),acYueduHeroTwoVoApi:getCost(1)})
-- 		numstr = acYueduHeroTwoVoApi:getRecord(1) .. "/" .. acYueduHeroTwoVoApi:getCost(1)
-- 		allStr = alreadyStr.."<rayimg>"..numstr
-- 	local alreadyStr1 =getlocal("activity_acYueduHero_already1",{acYueduHeroTwoVoApi:getRecord(1),acYueduHeroTwoVoApi:getCost(1)})
-- 	local numstr = acYueduHeroTwoVoApi:getRecord(1) .. "/" .. acYueduHeroTwoVoApi:getCost(1)
-- 	local allStr1 = alreadyStr1.."<rayimg>"..numstr
-- 	end
-- 	if textID and textID == 2  then
-- 		local alreadyStr=getlocal("activity_acYueduHero_already2",{acYueduHeroTwoVoApi:getRecord(2),acYueduHeroTwoVoApi:getCost(2)})
-- 		local numstr = acYueduHeroTwoVoApi:getRecord(2) .. "/" .. acYueduHeroTwoVoApi:getCost(2)
-- 		local allStr = alreadyStr.."<rayimg>"..numstr	
-- 	end
-- 	arrGroup,colorarr = G_formatRichMsg(allStr,self.colorTab)
--     return arrGroup,colorarr
-- end
function acYueduHeroTwoDialog:dispose()
	spriteController:removePlist("public/bgFireImage.plist")
    spriteController:removeTexture("public/bgFireImage.png")
	self.alreadyLb1=nil
	self.alreadyLb2=nil
	self.aLingquLb2=nil
	self.aLingquLb1=nil
	self.lingquItem1=nil
	self.lingquItem2=nil
	self.numLb1=nil
	self.numLb2=nil
	self.timeLb=nil
	self.propInfoDia =nil
	self.rewardIconTb = nil
	self.addPosYIn5_2 = nil
	spriteController:removePlist("public/activePicUseInNewGuid.plist")
	spriteController:removeTexture("public/activePicUseInNewGuid.png")
end