acMayDayTab1 ={}

function acMayDayTab1:new()
	local nc = {}
	setmetatable(nc,self)
	self.__index=self
	self.singlePointRotation=0
	self.allLightAreas ={}
	self.bgLayer =nil
	self.runingTime=0
	self.isRuning=false
	self.daiBi =nil
	self.aSpeed= 8
	self.time =0
	self.addSpeed=2
	self.rechargePid=nil
	self.showList=nil
	self.isEnd=false
	self.daibiRewardNum=0
	self.rewardTb={}
	self.yanchi=false
	self.isToday =false
	self.singlePointSp=nil
	self.touchEnd=false
	self.isfree =false
	self.costGoldLb=nil
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/expeditionImage.plist")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
  CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	--CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/kuangnuImage.plist")
	return nc
end

function acMayDayTab1:init(layerNum )
	self.isfree =acMayDayVoApi:canReward()
	self.bgLayer=CCLayer:create()
	self.layerNum = layerNum
	self.isToday =acMayDayVoApi:isToday()
	self:initHead()
	self:initMiddle()
	self:refreshRight()
	return self.bgLayer
end

function acMayDayTab1:initHead(	)


	local function touchDialog()
		
      	self:stop()
    end
    self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
    self.touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-10)
    local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    self.touchDialogBg:setContentSize(rect)
    self.touchDialogBg:setOpacity(0)
    self.touchDialogBg:setIsSallow(false) -- 点击事件透下去
    self.touchDialogBg:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(self.touchDialogBg,1)


	self.daiBi = acMayDayVoApi:getDaiBi()

	local tvBg = CCSprite:createWithSpriteFrameName("SlotMask.png")
    tvBg:setScaleX((self.bgLayer:getContentSize().width-40)/tvBg:getContentSize().width)
    tvBg:setScaleY(560/tvBg:getContentSize().height)
    tvBg:setAnchorPoint(ccp(0.5,1))
    tvBg:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-445)
    --tvBg:setContentSize(CCSizeMake(400,380))
    self.bgLayer:addChild(tvBg)

    local titleStr=getlocal("activity_timeLabel")
    local titleLb=GetTTFLabelWrap(titleStr,35,CCSizeMake(0,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    titleLb:setAnchorPoint(ccp(0.5,1))
    titleLb:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height-170))
    self.bgLayer:addChild(titleLb,1)
    titleLb:setColor(G_ColorGreen)

    local vo=acMayDayVoApi:getAcVo()
    local timeStr=activityVoApi:getActivityTimeStr(vo.st,vo.acEt)
    local timeLb=GetTTFLabelWrap(timeStr,30,CCSizeMake(0,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    timeLb:setAnchorPoint(ccp(0.5,1))
    timeLb:setPosition(ccp(self.bgLayer:getContentSize().width*0.5+20,titleLb:getPositionY()-45))
    self.bgLayer:addChild(timeLb,1)
    timeLb:setColor(G_ColorYellow)

	local function bgClick()
  	end
	self.upLabelSp = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),bgClick)
	self.upLabelSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width*0.7+30, 150))
	self.upLabelSp:setAnchorPoint(ccp(0,1))
	self.upLabelSp:setPosition(ccp(self.bgLayer:getContentSize().width*0.2-10, self.bgLayer:getContentSize().height-260))
	self.bgLayer:addChild(self.upLabelSp)


	 local desTv, desLabel = G_LabelTableView(CCSizeMake(self.upLabelSp:getContentSize().width*(2/3), 120),getlocal("acMayDay_shopDesc1"),25,kCCTextAlignmentLeft)
    self.upLabelSp :addChild(desTv,1)
    desTv:setPosition(ccp(120,10))
    desTv:setAnchorPoint(ccp(0.5,1))
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-6)
    desTv:setMaxDisToBottomOrTop(100)

	if(G_isIphone5())then
		self.girlHeight=230
	else
		self.girlHeight=190
	end
    local girlImg=CCSprite:createWithSpriteFrameName("GuideCharacter.png")
	girlImg:setScale(self.girlHeight/girlImg:getContentSize().height)
	girlImg:setAnchorPoint(ccp(0.5,0.5))
	girlImg:setPosition(ccp(-10,self.upLabelSp:getContentSize().height*0.5))
	self.upLabelSp:addChild(girlImg)

	-- local descLb1=GetTTFLabelWrap(getlocal("acMayDay_shopDesc2"),25,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
 --    --descLb1:setAnchorPoint(ccp(0.5,1))
	-- descLb1:setPosition(ccp(500,self.bgLayer:getContentSize().height-300))
	-- self.bgLayer:addChild(descLb1)


	-- local descLb2=GetTTFLabelWrap(getlocal("acMayDay_shopDesc3"),25,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
 --    --descLb1:setAnchorPoint(ccp(0.5,1))
	-- descLb2:setPosition(ccp(500,self.bgLayer:getContentSize().height-600))
	-- self.bgLayer:addChild(descLb2)
	local strSize =25
	if G_getCurChoseLanguage() =="en" then
		strSize =23
	end
	local descLb1=GetTTFLabelWrap(getlocal("oneTwo"),strSize,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    descLb1:setAnchorPoint(ccp(1,0.5))
    descLb1:setColor(G_ColorYellow)
	descLb1:setPosition(ccp(self.bgLayer:getContentSize().width-25,120))
	self.bgLayer:addChild(descLb1)

	

	self.oneOrMul=1

	local function choose()
		if self.isfree then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("isfree"),30)

			do
				return
			end
		end

		if self.oneOrMul==1 then
			self.chooseSp:setVisible(true)
			self.oneOrMul=2

			local costGold = 0
			if self.singleOrDouble==1 then
				costGold=acMayDayVoApi:getSingleCost(10)
			else
				costGold=acMayDayVoApi:getDoubleCost(10)
			end
			self:changeGold(costGold)
			  if costGold>playerVoApi:getGems() then
			    	self.costGoldLb:setColor(G_ColorRed)
			  else
			  		self.costGoldLb:setColor(G_ColorWhite)
			  end
		else
			self.chooseSp:setVisible(false)
			self.oneOrMul=1
			local costGold = 0
			if self.singleOrDouble==1 then
				costGold=acMayDayVoApi:getSingleCost(1)
			else
				costGold=acMayDayVoApi:getDoubleCost(1)
			end
			self:changeGold(costGold)
			  if costGold>playerVoApi:getGems() then
			    	self.costGoldLb:setColor(G_ColorRed)
			  else
			  		self.costGoldLb:setColor(G_ColorWhite)
			  end
		end
	end
	local checkBox=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",choose)
	checkBox:setTouchPriority(-(self.layerNum-1)*20-4)
	checkBox:setAnchorPoint(ccp(0,0))
	checkBox:setPosition(ccp(30,30))
	self.bgLayer:addChild(checkBox)

	self.chooseSp=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtn.png",choose)
	self.chooseSp:setPosition(getCenterPoint(checkBox))
	checkBox:addChild(self.chooseSp)
	self.chooseSp:setVisible(false)

   local tenSiz = 25
   local tenWidth = 200
   if G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="en" or G_getCurChoseLanguage()=="in" or G_getCurChoseLanguage() =="fr" then
        tenSiz =20
    elseif G_getCurChoseLanguage()=="ru" then
    	tenSiz =22
    	tenWidth =350
   end

	local descLb2=GetTTFLabelWrap(getlocal("ten"),tenSiz,CCSizeMake(tenWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    descLb2:setAnchorPoint(ccp(0,0.5))
    descLb2:setColor(G_ColorYellow)
	descLb2:setPosition(ccp(checkBox:getContentSize().width+5,checkBox:getContentSize().height/2))
	checkBox:addChild(descLb2)


	self.singleOrDouble =acMayDayVoApi:getOneTwo()
	local function choose2( ... )
		-- body

		if self.isfree then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("isfree"),30)

			do
				return
			end
		end

		if self.singleOrDouble==1 then
			self.oneTwoItem1:setVisible(false)
			self.oneTwoItem2:setVisible(true)
			self.addSp2:setVisible(true)
			acMayDayVoApi:setOneTwo(2)
			self.singleOrDouble=acMayDayVoApi:getOneTwo()
			local costGold = 0
			if self.oneOrMul==1 then
				costGold=acMayDayVoApi:getDoubleCost(1)
			else
				costGold=acMayDayVoApi:getDoubleCost(10)
			end
			self:changeGold(costGold)
			  if costGold>playerVoApi:getGems() then
			    	self.costGoldLb:setColor(G_ColorRed)
			  else
			  		self.costGoldLb:setColor(G_ColorWhite)
			  end
		else
			self.oneTwoItem1:setVisible(true)
			self.oneTwoItem2:setVisible(false)
			self.addSp2:setVisible(false)
			acMayDayVoApi:setOneTwo(1)
			self.singleOrDouble=acMayDayVoApi:getOneTwo()
			local costGold = 0
			if self.oneOrMul==1 then
				costGold=acMayDayVoApi:getSingleCost(1)
			else
				costGold=acMayDayVoApi:getSingleCost(10)
			end
			self:changeGold(costGold)
			  if costGold>playerVoApi:getGems() then
			    	self.costGoldLb:setColor(G_ColorRed)
			  else
			  		self.costGoldLb:setColor(G_ColorWhite)
			  end
		end
	end

	local oneTwoItem=LuaCCSprite:createWithSpriteFrameName("acMayDayBtnBg.png",choose2)
	oneTwoItem:setTouchPriority(-(self.layerNum-1)*20-4)
	oneTwoItem:setAnchorPoint(ccp(1,0))
	oneTwoItem:setPosition(ccp(self.bgLayer:getContentSize().width-30,30))
	self.bgLayer:addChild(oneTwoItem)

	self.oneTwoItem1=LuaCCSprite:createWithSpriteFrameName("acMayDayBtn1.png",choose2)
	self.oneTwoItem1:setAnchorPoint(ccp(0,0.5))
	self.oneTwoItem1:setPosition(ccp(0,oneTwoItem:getContentSize().height/2))
	oneTwoItem:addChild(self.oneTwoItem1)
	self.oneTwoItem1:setVisible(true)

	self.oneTwoItem2=LuaCCSprite:createWithSpriteFrameName("acMayDayBtn2.png",choose2)
	self.oneTwoItem2:setAnchorPoint(ccp(1,0.5))
	self.oneTwoItem2:setPosition(ccp(oneTwoItem:getContentSize().width,oneTwoItem:getContentSize().height/2))
	oneTwoItem:addChild(self.oneTwoItem2)
	self.oneTwoItem2:setVisible(false)

end

function acMayDayTab1:changeGold(gold)
	self.costGoldLb:setString(gold)
	--self.goldSp:setPosition(ccp(self.costGoldLb:getContentSize().width+2,self.costGoldLb:getContentSize().height/2))
end


function acMayDayTab1:initMiddle( )
	local function mBgClick()
  	end	
	--local circleBg = LuaCCScale9Sprite:createWithSpriteFrameName("circleBg.png",CCRect(0, 0, 10, 10),mBgClick)
	local circleBg = CCSprite:createWithSpriteFrameName("acMayDayBg.png")
	circleBg:setTag(321)
	--circleBg:setContentSize(CCSizeMake(600,self.bgLayer:getContentSize().height*0.4))
	circleBg:setAnchorPoint(ccp(0.5,1))
	circleBg:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.upLabelSp:getPositionY()-self.upLabelSp:getContentSize().height-50))
	if G_isIphone5() ==true then
		circleBg:setScale(1.5)
	else
		circleBg:setScale(1)
	end
	self.bgLayer:addChild(circleBg,1)
	local costGold = acMayDayVoApi:getSingleCost(1)
	if self.isfree then
		costGold =0
	end
	self.costGoldLb = GetTTFLabel(costGold,23)
    self.costGoldLb:setAnchorPoint(ccp(1,0))
    self.costGoldLb:setPosition(circleBg:getContentSize().width*0.5+5,circleBg:getContentSize().height*0.5-50)
    circleBg:addChild(self.costGoldLb,999)

    self.goldSp = CCSprite:createWithSpriteFrameName("IconGold.png")
    self.goldSp:setScale(0.8)
    self.goldSp:setAnchorPoint(ccp(0,0))
    self.goldSp:setPosition(ccp(self.costGoldLb:getPositionX()+5,self.costGoldLb:getPositionY()))--+self.costGoldLb:getContentSize().height/2))
    circleBg:addChild(self.goldSp,999)

    if self.isfree then
		self:changeGold(0)
	elseif costGold>playerVoApi:getGems() then
    	self.costGoldLb:setColor(G_ColorRed)
  	end




	for i=1,8 do
		local lightArea = CCSprite:createWithSpriteFrameName("acMayDayBgLight.png")
		lightArea:setAnchorPoint(ccp(0.5,0))
		lightArea:setPosition(ccp(circleBg:getContentSize().width*0.5,circleBg:getContentSize().height*0.5))
		lightArea:setRotation((i-1)*45)
		circleBg:addChild(lightArea,1)
		self.allLightAreas[i] =lightArea
		lightArea:setVisible(false)
	end

    local function rechargeCallback(tag,object)
		    if G_checkClickEnable()==false then
		        do
		            return
		        end
		    else
		        base.setWaitTime=G_getCurDeviceMillTime()
		    end

		    

		    if self.isRuning==true then
		    	do return  end
		    end

		    if self.yanchi then
		    	do return  end
		    end

		    local function onShowPowerChange()
	            self.yanchi=false
	        end
	        local callFunc=CCCallFunc:create(onShowPowerChange)
	        local delay=CCDelayTime:create(2)
	        local acArr=CCArray:create()
	        acArr:addObject(delay)
	        acArr:addObject(callFunc)
	        local seq=CCSequence:create(acArr)
	        sceneGame:runAction(seq)

		    PlayEffect(audioCfg.mouseClick)
		    

		    local needGems
		    local isMul = 1
		    if self.singleOrDouble ==1 then
		    	if self.oneOrMul ==2 then
		    		isMul =10
		    	end 
		    	needGems = acMayDayVoApi:getSingleCost(isMul)
		    elseif self.singleOrDouble==2 then
		    	if self.oneOrMul ==2 then
		    		isMul =10
		    	end 
		    	needGems = acMayDayVoApi:getDoubleCost(isMul)
		    end
		     local today = acMayDayVoApi:isToday()
		  if needGems>playerVoApi:getGems() and today==true then
		    GemsNotEnoughDialog(nil,nil,needGems-playerVoApi:getGems(),self.layerNum+1,needGems)
		  else
			 	self.singlePointSp:setEnabled(false)
		    	if self.singleOrDouble ==1 then
		    		if self.isfree==false then
		    			playerVoApi:setValue("gems",playerVoApi:getGems()-needGems)
							  if needGems>playerVoApi:getGems() then
							    	self.costGoldLb:setColor(G_ColorRed)
							  end
		    		end
		    		self.isRuning=true
		    		local function freeCallback(fn,data)
		    			local ret,sData= base:checkServerData(data)
		    			self.startItem:setEnabled(false)
		    			self.singlePoint:setEnabled(false)
		    			if ret ==true then
		    				acMayDayVoApi:setT(base.serverTime)
		    				self:refreshFree()
		    				if sData.data.report then
		    					local report = sData.data.report
		    					local pId,pNum
		    					self.rewardTb=report
		    					self.yanchi=true
								if needGems>playerVoApi:getGems() then
							    	self.costGoldLb:setColor(G_ColorRed)
							  	end
		    					
		    					for k,v in pairs(report) do
		    						
		    						for i,j in pairs(v) do --p7
		    							if i =="mm_m1" then
		    								self.daiBi =self.daiBi+j
		    								--print("self.daiBi1=",self.daiBi,j)
		    								acMayDayVoApi:setDaiBi(self.daiBi)
		    								--print("self.daiBi2=",self.daiBi,j)
		    								self.rechargePid=0
		    								self.daibiRewardNum=j
		    							else
			    							for m,n in pairs(j) do 
			    								if n then
			    									--print("pid,,,,,,pNum",m,n)
			    									pId =m
			    									pNum =n
			    									-- bagVoApi:addBag(pId,pNum)
			    									self.rechargePid=pId
			    								end
			    							end
			    						end
		    						end
		    					end
		    					for m,n in pairs(report) do
		    						local award = acMayDayVoApi:FormatItemBySelf(n)
			    					for k,v in pairs(award) do
										G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
									end
		    					end		
		    				end
		    			end
		    		end 
		    		--self.oneOrMul=acMayDayVoApi:getMul()
			 		socketHelper:mayDay(1,self.oneOrMul,freeCallback)
			 	elseif self.singleOrDouble==2 then
			 		playerVoApi:setValue("gems",playerVoApi:getGems()-needGems)
		    		self.isRuning=true
		    		local function doubleCallback(fn,data)
		    			local ret,sData= base:checkServerData(data)
		    			self.startItem:setEnabled(false)
		    			self.singlePoint:setEnabled(false)
		    			if ret ==true then
		    				acMayDayVoApi:setT(base.serverTime)
		    				if sData.data.report then
		    					local report = sData.data.report
		    					self.rewardTb=report
		    					self.yanchi=true
		    					local pId,pNum
		    					local reward = {}
		    					if needGems>playerVoApi:getGems() then
							    	self.costGoldLb:setColor(G_ColorRed)
							  	end
		    					for k,v in pairs(report) do
		    						
		    						for i,j in pairs(v) do --p7
		    							if i =="mm_m1" then
		    								self.daiBi =self.daiBi+j
		    								--print("self.daiBi1=",self.daiBi,j)
		    								acMayDayVoApi:setDaiBi(self.daiBi)
		    								--print("self.daiBi2=",self.daiBi,j)
		    								self.rechargePid=0
		    								self.daibiRewardNum=j
		    							else
			    							for m,n in pairs(j) do 
			    								if n then
			    									--print("pid2,,,,,,pNum",m,n)
			    									pId =m
			    									pNum =n
			    									-- bagVoApi:addBag(pId,pNum)
			    									self.rechargePid =pId
			    								end
			    							end
			    						end
		    						end
		    					end

		    					for m,n in pairs(report) do
		    						local award = acMayDayVoApi:FormatItemBySelf(n)
			    					for k,v in pairs(award) do
										G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
									end
		    					end
		    					
		    				end
		    			end
		    		end 
		    		--self.oneOrMul=acMayDayVoApi:getMul()
			 		socketHelper:mayDay(2,self.oneOrMul,doubleCallback)
			 	end
		  end
    end
    
    local singlePointStr
    if self.isfree then
    	singlePointStr =getlocal("daily_lotto_tip_2")
    else
    	singlePointStr =getlocal("goStr")
    end
    local strSize2 = 30
    if G_getCurChoseLanguage() =="ru" then
    	strSize2 =25
    end
    self.singlePoint=GetButtonItem("acMayDayBgCener.png","acMayDayCenterDown.png","acMayDayBgCener.png",rechargeCallback,nil,singlePointStr,25,111)
	self.singlePoint:setAnchorPoint(ccp(0.5,0.5))
    local rewardMenu=CCMenu:createWithItem(self.singlePoint)
    rewardMenu:setPosition(ccp(circleBg:getContentSize().width*0.5,circleBg:getContentSize().height*0.5))
	circleBg:addChild(rewardMenu,1)
	self.singlePoint:setEnabled(false)

	self.startItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",rechargeCallback,nil,getlocal("goStr2"),25,111)
	self.startItem:setAnchorPoint(ccp(0.5,0.5))
    local startMenu=CCMenu:createWithItem(self.startItem)
    startMenu:setPosition(ccp(500,self.bgLayer:getContentSize().height-650))
    startMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(startMenu,1)
	startMenu:setVisible(false) --单独按钮隐藏掉

    local selectNn = CCSprite:createWithSpriteFrameName("acMayDayBgCener.png");
    local selectSs = CCSprite:createWithSpriteFrameName("acMayDayCenterDown.png");
    local selectDd = CCSprite:createWithSpriteFrameName("acMayDayBgCener.png");
    self.singlePointSp = CCMenuItemSprite:create(selectNn,selectSs,selectDd);
    self.singlePointSp:registerScriptTapHandler(rechargeCallback)
    local rewardMenu2=CCMenu:createWithItem(self.singlePointSp)
    rewardMenu2:setPosition(ccp(circleBg:getContentSize().width*0.5,circleBg:getContentSize().height*0.5))
    rewardMenu2:setTouchPriority(-(self.layerNum-1)*20-5)
    -- rewardMenu2:setOpacity(0)
    -- rewardMenu2:setIsSallow(false)
	circleBg:addChild(rewardMenu2,2)

	self.getLabel = GetTTFLabel(singlePointStr,strSize2)
	self.getLabel:setPosition(getCenterPoint(self.singlePointSp))
	self.singlePointSp:addChild(self.getLabel)
	--circleBg:addChild(singlePointSp,2)


	self.addSp1 = CCSprite:createWithSpriteFrameName("acMayDayPointer.png")
	self.addSp1:setAnchorPoint(ccp(0.5,0))
	self.addSp1:setPosition(ccp(self.singlePoint:getContentSize().width/2,self.singlePoint:getContentSize().height))
	self.singlePoint:addChild(self.addSp1)

	self.addSp2 = CCSprite:createWithSpriteFrameName("acMayDayPointer.png")
	self.addSp2:setAnchorPoint(ccp(0.5,1))
	self.addSp2:setPosition(ccp(self.singlePoint:getContentSize().width/2,0))
	self.singlePoint:addChild(self.addSp2)
	self.addSp2:setVisible(false)
	self.addSp2:setFlipY(true)


	--base:addNeedRefresh(self)

	local whichBox = {"SpecialBox.png","silverBox.png","CommonBox.png"}
	  local circleList = acMayDayVoApi:getCircleList()
	  local posIdList = {}
	  self.showList= acMayDayVoApi:FormatItemBySelf(circleList,nil,true)
	  if self.showList then
	    for k,v in pairs(self.showList) do
	      posIdList[k]=self.showList[k].posId
	      local posId = posIdList[k]
	      	local picIcon = CCSprite:createWithSpriteFrameName(whichBox[posId])
			picIcon:setAnchorPoint(ccp(0.5,0.5))
			circleBg:addChild(picIcon,1)
			picIcon:setScale(0.5)
	      local icon,iconScale = G_getItemIcon(v,100, true, self.layerNum)
	      if icon ~=nil then
		      icon:setTouchPriority(-(self.layerNum-1)*20-5)
		      icon:setAnchorPoint(ccp(0.5,0.5))
		      icon:setPosition(ccp(picIcon:getContentSize().width*0.5,picIcon:getContentSize().height*0.5))

		      if k==1 then
		      	picIcon:setPosition(circleBg:getContentSize().width*0.5,circleBg:getContentSize().height*0.9)
		      elseif k==2 then
		      	picIcon:setPosition(circleBg:getContentSize().width*0.75,circleBg:getContentSize().height*0.8)
		      elseif k ==3 then
		      	picIcon:setPosition(circleBg:getContentSize().width*0.85,circleBg:getContentSize().height*0.5)
		      elseif k==4 then
		      	picIcon:setPosition(circleBg:getContentSize().width*0.75,circleBg:getContentSize().height*0.2)
		      elseif k==5 then
		      	picIcon:setPosition(circleBg:getContentSize().width*0.5,circleBg:getContentSize().height*0.1)
		      elseif k==6 then
		      	picIcon:setPosition(circleBg:getContentSize().width*0.2,circleBg:getContentSize().height*0.2)
		      elseif k==7 then
		      	picIcon:setPosition(circleBg:getContentSize().width*0.1,circleBg:getContentSize().height*0.5)
		      elseif k==8 then
		      	picIcon:setPosition(circleBg:getContentSize().width*0.2,circleBg:getContentSize().height*0.8)
		      end
		      icon:setVisible(false)
		      picIcon:addChild(icon,1)
		      --G_addRectFlicker(icon,1.4/iconScale,1.4/iconScale)

		      -- local num = GetTTFLabel("x"..v.num,25)
		      -- num:setAnchorPoint(ccp(1,0))
		      -- num:setPosition(icon:getContentSize().width-10,10)
		      -- icon:addChild(num)
		  else
		  end
	    end
	  end
end

function acMayDayTab1:refreshRight( )
	    if self.isfree then
			self:changeGold(0)
		end
	
		if self.singleOrDouble==2 and self.isfree== false then
			self.oneTwoItem1:setVisible(false)
			self.oneTwoItem2:setVisible(true)
			self.addSp2:setVisible(true)
			acMayDayVoApi:setOneTwo(2)
			self.singleOrDouble=acMayDayVoApi:getOneTwo()

			local costGold = 0
			if self.oneOrMul==1 then
				costGold=acMayDayVoApi:getDoubleCost(1)
			else
				costGold=acMayDayVoApi:getDoubleCost(10)
			end
			self:changeGold(costGold)
			  if costGold>playerVoApi:getGems() then
			    	self.costGoldLb:setColor(G_ColorRed)
			  end
		else
			self.oneTwoItem1:setVisible(true)
			self.oneTwoItem2:setVisible(false)
			self.addSp2:setVisible(false)
			acMayDayVoApi:setOneTwo(1)
			self.singleOrDouble=acMayDayVoApi:getOneTwo()

			local costGold = 0
			if self.oneOrMul==1 then
				costGold=acMayDayVoApi:getSingleCost(1)
			else
				costGold=acMayDayVoApi:getSingleCost(10)
			end
			if self.isfree ==false then
				self:changeGold(costGold)
			end
			  if costGold>playerVoApi:getGems() then
			    	self.costGoldLb:setColor(G_ColorRed)
			  end
		end
end

function acMayDayTab1:refreshFree()
	self.isfree =acMayDayVoApi:canReward()

	if self.isfree then
		self:changeGold(0)
	else
		if self.oneOrMul==2 then
			local costGold = 0
			if self.singleOrDouble==1 then
				costGold=acMayDayVoApi:getSingleCost(10)
			else
				costGold=acMayDayVoApi:getDoubleCost(10)
			end
			self:changeGold(costGold)

		else
			local costGold = 0
			if self.singleOrDouble==1 then
				costGold=acMayDayVoApi:getSingleCost(1)
			else
				costGold=acMayDayVoApi:getDoubleCost(1)
			end
			self:changeGold(costGold)
		end
	end

	if self.isfree then
    	singlePointStr =getlocal("daily_lotto_tip_2")
    else
    	singlePointStr =getlocal("goStr")
    end
    -- self.singlePoint=GetButtonItem("acMayDayBgCener.png","acMayDayBgCener.png","acMayDayBgCener.png",rechargeCallback,nil,singlePointStr,25,111)
    local lb = self.singlePoint:getChildByTag(111)
    lb=tolua.cast(lb,"CCLabelTTF")
    lb:setString(singlePointStr)
    self.getLabel:setString(singlePointStr)
    
end

function acMayDayTab1:fastTick( )
		
		if self.isRuning ==true then
			self.time=self.time+1
			self.singlePointRotation = self.singlePointRotation+self.aSpeed
			self.singlePoint=tolua.cast(self.singlePoint,"CCNode")
			self.singlePoint:setRotation(self.singlePointRotation)
			--print("self.singlePointRotation",self.singlePointRotation)
			if self.time>=200 and self.time%100 ==0 and self.isEnd==false then
				self.aSpeed =self.aSpeed-self.addSpeed
				--print("self.aSpeed",self.aSpeed)
				if self.aSpeed<self.addSpeed then
					--print("OK了")
					self.aSpeed =1
					self.isEnd=true
				end
			end
			if self.singlePointRotation>360 then
				self.singlePointRotation =self.singlePointRotation%360
			end
			self:chooseArea()
			if self.isEnd and  math.abs(self.singlePointRotation-self:getRotateByEnd())==5 then
				--print("self.rechargePid=",self.rechargePid)
				self:stop()
			end
		end
		if self.touchEnd ==true then
			self.isRuning=false
			if self.singlePointRotation< (self:getPointArea()-1)*45-25 or self.singlePointRotation> (self:getPointArea()-1)*45+25 then
				self.singlePointRotation = self.singlePointRotation+10
				self.singlePoint=tolua.cast(self.singlePoint,"CCNode")
				self.singlePoint:setRotation(self.singlePointRotation)			
				if self.singlePointRotation>360 then
					self.singlePointRotation =self.singlePointRotation%360
				end
				self:chooseArea()
			else
				self.touchEnd =false
				self:stop()
			end
		end
end


function acMayDayTab1:stop()
	--print("stop....")
	if self.rechargePid then
		if self.touchEnd ==false and self.singlePointRotation< (self:getPointArea()-1)*45-25 or self.singlePointRotation> (self:getPointArea()-1)*45+25 then
			self.touchEnd =true
		end
		if self.touchEnd ==false then
			acMayDayVoApi:showTips(self.rewardTb)
			self.startItem:setEnabled(true)
			self.singlePoint:setEnabled(false)
			self.singlePoint=tolua.cast(self.singlePoint,"CCNode")
			self.isRuning=false
			self.singlePoint:setRotation(self:getRotateByEnd())--将箭头直接指向
			self.singlePointRotation=self:getRotateByEnd()
			self:chooseArea()
			self.isEnd=false
			self.aSpeed=8
			self.time=0
			self.rechargePid=nil
			self.rewardTb={}
			self.daibiRewardNum=0
			self.singlePointSp:setEnabled(true)

		end
	end

end

function acMayDayTab1:pointEndByTouch( )
	
end

function acMayDayTab1:getRotateByEnd()
	return (self:getPointArea()-1)*45
end

function acMayDayTab1:getPointArea()
	--G_dayin(self.showList)
	if self.rechargePid then
		for k,v in pairs(self.showList) do
			--print("判断",self.showList[k].key)
			if self.rechargePid ==self.showList[k].key then
				return v.index
			elseif self.rechargePid==0 and v.type=="mm" then
				if (self.daibiRewardNum==v.num and self.oneOrMul ==1)or (self.oneOrMul==2 and self.daibiRewardNum/10==v.num) then
					--G_dayin()
					return v.index
				end
			end
		end
	end
	return 1
end
function acMayDayTab1:chooseArea()
	local lightNum = nil
	if self.singlePointRotation>360-22.5 or self.singlePointRotation<22.5 then
		self.allLightAreas[1]:setVisible(true)
		if self.singleOrDouble==2 then
			self.allLightAreas[5]:setVisible(true)
		end
		lightNum =1
	elseif self.singlePointRotation	>22.5 and self.singlePointRotation<67.5 then
		self.allLightAreas[2]:setVisible(true)
		if self.singleOrDouble==2 then
			self.allLightAreas[6]:setVisible(true)
		end
		lightNum =2
	elseif self.singlePointRotation >67.5 and self.singlePointRotation<112.5 then
		lightNum =3
		self.allLightAreas[3]:setVisible(true)
		if self.singleOrDouble==2 then
			self.allLightAreas[7]:setVisible(true)
		end
	elseif self.singlePointRotation >112.5 and self.singlePointRotation<157.5 then
		lightNum =4
		self.allLightAreas[4]:setVisible(true)
		if self.singleOrDouble==2 then
			self.allLightAreas[8]:setVisible(true)
		end
	elseif self.singlePointRotation >157.5 and self.singlePointRotation<202.5 then
		lightNum=5
		self.allLightAreas[5]:setVisible(true)
		if self.singleOrDouble==2 then
			self.allLightAreas[1]:setVisible(true)
		end
	elseif self.singlePointRotation >202.5 and self.singlePointRotation<247.5 then
		lightNum=6
		self.allLightAreas[6]:setVisible(true)
		if self.singleOrDouble==2 then
			self.allLightAreas[2]:setVisible(true)
		end
	elseif self.singlePointRotation >247.5 and self.singlePointRotation<292.5 then
		lightNum=7
		self.allLightAreas[7]:setVisible(true)
		if self.singleOrDouble==2 then
			self.allLightAreas[3]:setVisible(true)
		end
	elseif self.singlePointRotation>292.5 and self.singlePointRotation<337.5 then
		lightNum=8
		self.allLightAreas[8]:setVisible(true)
		if self.singleOrDouble==2 then
			self.allLightAreas[4]:setVisible(true)
		end
	end
	if lightNum ~=nil then
		for i=1,8 do
			if self.singleOrDouble==1 then
				if i~=lightNum then
					self.allLightAreas[i]:setVisible(false)
				end
			else
				local lightNum2 = 1
				if lightNum<=4 then
					lightNum2 = lightNum+4
				else
					lightNum2 = lightNum-4
				end

				if i~=lightNum and i~=lightNum2 then
					self.allLightAreas[i]:setVisible(false)
				end

			end
			
		end
	end
end


function acMayDayTab1:tick( )
	if self.isRuning ==true then
		self.runingTime = self.runingTime+1
	end


  local today = acMayDayVoApi:isToday()
  local singlePointStr =""
  if today==true  then
  	-- singlePointStr=getlocal("goStr")
  	-- 	 local lb = self.singlePoint:getChildByTag(111)
   --  lb=tolua.cast(lb,"CCLabelTTF")
   --  lb:setString(singlePointStr)
    --self:changeGold(0)
  else
  	--if self.isEnd ==true then
  		self:stop()		
	  	self.isfree =acMayDayVoApi:canReward()
	  	singlePointStr =getlocal("daily_lotto_tip_2")
	  	local lb = self.singlePoint:getChildByTag(111)
	    lb=tolua.cast(lb,"CCLabelTTF")
	    lb:setString(singlePointStr)
	    self.getLabel:setString(singlePointStr)
	    --local costGold=acMayDayVoApi:getSingleCost(1)
	    self:changeGold(0)
	    self.costGoldLb:setColor(G_ColorWhite)
		self.oneTwoItem1:setVisible(true)
		self.oneTwoItem2:setVisible(false)
		self.chooseSp:setVisible(false)
		acMayDayVoApi:setOneTwo(1)
		self.addSp2:setVisible(false)
		self.rewardTb ={}
		self.singleOrDouble =1
		self.oneOrMul=1
  	--end
  end
end

function acMayDayTab1:dispose( )
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/expeditionImage.plist")
	-- dmj注释0701，因为startgame.lua中已经加载过了，再释放会报错
	--CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/kuangnuImage.plist")
	self.singlePointSp=nil
	acMayDayVoApi:setOneTwo(1)
	base:removeFromNeedRefresh(self)
	self.bgLayer:removeFromParentAndCleanup(true)
	self.singlePointRotation=nil
	self.singlePoint=nil
	self.allLightAreas =nil
	self.bgLayer =nil
	self.singleOrDouble=nil
	self.touchEnd=nil

end