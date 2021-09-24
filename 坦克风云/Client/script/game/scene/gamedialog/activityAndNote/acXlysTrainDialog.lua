-- @Author hj
-- @Description 训练有素抽奖板子
-- @Date 2018-07-02

acXlysTrainDialog = {} 

function acXlysTrainDialog:new(layer)
	local nc = {
		layerNum = layer,
		progressTb = {},
		colorTb = {ccc3(44,180,54),ccc3(51,97,217),ccc3(114,54,178),ccc3(175,165,34)},
		actionCfg = {},
		fadeBgTb = {},
		actionFlag = 0,
		numTb = {}
	}
	setmetatable(nc,self)
	self.__index = self
	return nc
end

function acXlysTrainDialog:init()

	self.bgLayer=CCLayer:create()

	self.bgLayer1 = CCLayer:create()

	self.bgLayer:addChild(self.bgLayer1)

	-- 抽奖动画遮罩
	local function touchHandler( ... )

		self:refreshData()
		self.bgLayer:stopAllActions()
		self.touchSp:removeAllChildrenWithCleanup(true)
		self.actionFlag = 0
		self.touchSp:setPosition(ccp(9999,0))

		for i=1,4 do
			local flag
			if i == 1 or i == 4 then
				flag = 1
			else
				flag = 0
			end
			local fadeBg = CCSprite:createWithSpriteFrameName("xlysFade.png")
			fadeBg:setVisible(false)
			fadeBg:setPosition(ccp(G_VisibleSizeWidth/2+80*(-1)^flag,(G_VisibleSizeHeight-155)/2+80*(-1)^math.floor(i/3)))
			self.touchSp:addChild(fadeBg)
			self.fadeBgTb[i] = fadeBg
			if i == 2 then
				fadeBg:setRotation(90)
			elseif i == 3 then
				fadeBg:setRotation(180)
			elseif i == 4 then
				fadeBg:setRotation(270)
			end
		end
		for k,v in pairs(self.numTb) do
			if v then
				v:setScale(1)
			end
		end
		if self.rewardShow then
			self.rewardShow()
		end
	end

	local touchSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchHandler)
	touchSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	touchSp:setAnchorPoint(ccp(0.5,0))
	touchSp:setPosition(ccp(9999,0))
	touchSp:setTouchPriority(-(self.layerNum-1)*20-5)
	touchSp:setIsSallow(true)
    touchSp:setOpacity(0)
	self.bgLayer:addChild(touchSp,10)
	self.touchHandler = touchHandler
    self.touchSp = touchSp

	self:doUserHandler()
	return self.bgLayer
end

function acXlysTrainDialog:doUserHandler( ... )

	local adaSize 
	if G_getIphoneType() == G_iphoneX then 
		adaSize = CCSizeMake(G_VisibleSizeWidth,1090)
	elseif G_getIphoneType() == G_iphone5 then
		adaSize = CCSizeMake(G_VisibleSizeWidth,976)
	else		
		adaSize = CCSizeMake(G_VisibleSizeWidth,800)
	end

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	
	local function onLoadIcon(fn,icon)
		if self and self.bgLayer1 and  tolua.cast(self.bgLayer1,"CCLayer") then

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
			self.bgLayer1:addChild(clipper)
		end
	end
	local webImage=LuaCCWebImage:createWithURL(G_downloadUrl("active/xlysBig.jpg"),onLoadIcon)
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

	local function nilFunc( ... )
		-- body
	end
	--顶框
	local topBorder = LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png",CCRect(103,0,2,80),nilFunc)
	self.bgLayer:addChild(topBorder)
	topBorder:setAnchorPoint(ccp(0.5,1))
	topBorder:setContentSize(CCSizeMake(G_VisibleSizeWidth,85))
	topBorder:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160))
	
	
	--倒计时 
	local timeLb = GetTTFLabel(acXlysVoApi:getAcTimeStr(),25)
	timeLb:setAnchorPoint(ccp(0.5,1))
	timeLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-170))
	self.timeLb = timeLb
	timeLb:setColor(G_ColorYellowPro)
	self.bgLayer:addChild(timeLb)


	local strSize = 25
	if G_getCurChoseLanguage() == "ko" or G_isAsia() == false then
		strSize = 17
	end
	local adaH = 0
	if G_getIphoneType() == G_iphone4 then
		adaH = 20
	end

	local descLb = GetTTFLabel(getlocal("activity_xlys_desc"),strSize,true)
	descLb:setAnchorPoint(ccp(0.5,1))
	descLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160-topBorder:getContentSize().height+adaH))
	self.bgLayer:addChild(descLb)

	local rewardDescBg=CCSprite:createWithSpriteFrameName("greenBg1.png")
	rewardDescBg:setAnchorPoint(ccp(0.5,1))
	rewardDescBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 160-topBorder:getContentSize().height-descLb:getContentSize().height-30+adaH/2*5)
	self.bgLayer:addChild(rewardDescBg)

	local colorTb = {nil,G_ColorYellowPro,nil}
	local rewardDescLb,rewardDescLbHeight = G_getRichTextLabel(getlocal("activity_xlys_rewardDesc"),colorTb,strSize,520,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	rewardDescLb:setAnchorPoint(ccp(0.5,1))
	rewardDescLb:setPosition(ccp(rewardDescBg:getContentSize().width/2,rewardDescBg:getContentSize().height/2+rewardDescLbHeight/2))
	rewardDescBg:addChild(rewardDescLb)

	local function touchInfo()
    local tabStr={}
    for i=1,5 do
    	table.insert(tabStr,getlocal("activity_xlys_tip"..i))
    end
    local titleStr=getlocal("activity_baseLeveling_ruleTitle")
    require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
    local textSize = 25
    	tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,textSize)
	end 

	local tipButton = G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth-50,G_VisibleSizeHeight-160-30),nil,"i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touchInfo,0.8,-(self.layerNum-1)*20-4)

	
	local rewardBoxBg = CCSprite:createWithSpriteFrameName("xlysLightBg.png")
	rewardBoxBg:setPosition(ccp(G_VisibleSizeWidth/2,(G_VisibleSizeHeight-155)/2))
	self.bgLayer:addChild(rewardBoxBg)

	local function finalRewardShow( ... )
		if G_checkClickEnable()==false then
            do
                return
            end
    	else
        	base.setWaitTime=G_getCurDeviceMillTime()
    	end
		PlayEffect(audioCfg.mouseClick)
       	local content={}
        local item={}
		item.rewardlist = FormatItem(acXlysVoApi:getFinalReward(),true,true)
		item.title={getlocal("activity_xlys_finalRewardDesc"),nil,nil}
        table.insert(content,item)
        local titleTb={getlocal("award"),nil,30}
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYswjSmallDialog"
        acYswjSmallDialog:showYswjRewardDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-200),CCRect(130,50,1,1),titleTb,content,self.layerNum+1,nil,nil,nil,true,nil,"xlys")	
	end
	local rewardBoxSp = LuaCCSprite:createWithSpriteFrameName("xlysBox.png",finalRewardShow)
	rewardBoxSp:setTouchPriority(-(self.layerNum-1)*20-2)
	rewardBoxSp:setPosition(ccp(G_VisibleSizeWidth/2,(G_VisibleSizeHeight-155)/2))
	self.bgLayer:addChild(rewardBoxSp)

	for i=1,4 do
		local picStr,itemName = acXlysVoApi:getAreaPicAndName(i)
		local flag 
		if i == 1 or i == 4 then
			flag = 1
		else
			flag = 0
		end

		local function rewardShow( ... )
			if G_checkClickEnable()==false then
            	do return end
        	else
            	base.setWaitTime=G_getCurDeviceMillTime()
        	end
        	local content={}
            for index=1,2 do
                local item={}
                if index == 1 then
                	item.rewardlist = FormatItem(acXlysVoApi:getPartReward(i),true,true)
                	item.title={getlocal("activity_xlys_partRewardDesc",{getlocal("activity_xlys_item"..i)}),nil,nil}
            	else
            		item.rewardlist = FormatItem(acXlysVoApi:getReward(),true,true)
                	item.title={getlocal("activity_xlys_getRewardDesc",{getlocal("activity_xlys_item"..i)}),nil,nil}
            	end
                table.insert(content,item)
            end
            local titleTb={getlocal("award"),nil,30}
            require "luascript/script/game/scene/gamedialog/activityAndNote/acYswjSmallDialog"
            acYswjSmallDialog:showYswjRewardDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-200),CCRect(130,50,1,1),titleTb,content,self.layerNum+1,nil,nil,nil,true,nil,"xlys")	
    	end

		local itemSp = LuaCCSprite:createWithSpriteFrameName(picStr,rewardShow)
		itemSp:setTouchPriority(-(self.layerNum-1)*20-2)
		itemSp:setPosition(ccp(G_VisibleSizeWidth/2+245*(-1)^flag,(G_VisibleSizeHeight-155)/2+160*(-1)^math.floor(i/3)))
		self.bgLayer:addChild(itemSp)

		local nameLb = GetTTFLabel(itemName,20,true)
		nameLb:setAnchorPoint(ccp(0.5,0.5))
		nameLb:setPosition(ccp(G_VisibleSizeWidth/2+245*(-1)^flag,(G_VisibleSizeHeight-155)/2+160*(-1)^math.floor(i/3)-80))
		nameLb:setColor(G_ColorYellowPro)
		self.bgLayer:addChild(nameLb)
		self.numTb[i] = nameLb

		local timerSp = CCSprite:createWithSpriteFrameName("xlysBar.png")
		timerSp:setColor(self.colorTb[i])

		local progressBg = CCSprite:createWithSpriteFrameName("xlyskuang"..tostring(i)..".png")
		local lineSp = CCSprite:createWithSpriteFrameName("xlysLine.png")
		local fadeBg = CCSprite:createWithSpriteFrameName("xlysFade.png")
		fadeBg:setVisible(false)
		fadeBg:setPosition(ccp(G_VisibleSizeWidth/2+80*(-1)^flag,(G_VisibleSizeHeight-155)/2+80*(-1)^math.floor(i/3)))
		self.touchSp:addChild(fadeBg)
		self.fadeBgTb[i] = fadeBg

		local progressTimer = CCProgressTimer:create(timerSp)
		progressTimer:setAnchorPoint(ccp(0.5,0.5))
		progressTimer:setType(kCCProgressTimerTypeRadial)
		progressTimer:setReverseProgress(false) 
		progressTimer:setMidpoint(ccp(0.5,0.5))
		progressTimer:setPercentage(math.ceil(acXlysVoApi:getPercentage(i)*25))
		self.progressTb[i] = progressTimer
		
		if i == 1 then
			progressTimer:setRotation(270)
		elseif i == 2 then
			lineSp:setFlipX(true)
			progressBg:setRotation(90)
			fadeBg:setRotation(90)
		elseif i == 3 then
			lineSp:setRotation(180)
			progressBg:setRotation(180)
			fadeBg:setRotation(180)
			progressTimer:setRotation(90)
		elseif i == 4 then
			lineSp:setFlipY(true)
			progressBg:setRotation(270)
			fadeBg:setRotation(270)
			progressTimer:setRotation(180)
		end

		lineSp:setPosition(ccp(G_VisibleSizeWidth/2+140*(-1)^flag,(G_VisibleSizeHeight-155)/2+145*(-1)^math.floor(i/3)))
		progressBg:setPosition(ccp(G_VisibleSizeWidth/2+82*(-1)^flag,(G_VisibleSizeHeight-155)/2+82*(-1)^math.floor(i/3)))
		progressTimer:setPosition(ccp(G_VisibleSizeWidth/2,(G_VisibleSizeHeight-155)/2))
		
		self.bgLayer:addChild(lineSp)
		self.bgLayer:addChild(progressBg)
		self.bgLayer:addChild(progressTimer)

		local midPos = ccp(G_VisibleSizeWidth/2+140*(-1)^flag,(G_VisibleSizeHeight-155)/2+145*(-1)^math.floor(i/3))
		table.insert(self.actionCfg,midPos)
	end

	local function recordCallback( ... )
		local function showLog(rewardLog)
            if #rewardLog == 0 then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_tccx_no_record"),30)
            else
    			local logList={}
                for k,v in pairs(rewardLog) do
                    local num,reward,time=v.num,v.rewardlist,v.time
                    local title
                    if num == 1 or num == 5 then
                    	title = {getlocal("activity_xlys_logtip",{num})}
                    elseif num == 3 then
                    	title = {getlocal("activity_xlys_finalRewardLogtip")}
                    elseif num > 10 then
                    	title = {getlocal("activity_xlys_partRewardLogtip",{getlocal("activity_xlys_item"..tostring(num-10))})}
                    end
                    local content={{reward}}
                    local log={title=title,content=content,ts=time}
                    table.insert(logList,log)
                end
                local logNum=SizeOfTable(logList)
                require "luascript/script/game/scene/gamedialog/activityAndNote/acCjyxSmallDialog"
            	acCjyxSmallDialog:showLogDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-300),CCRect(130, 50, 1, 1),{getlocal("activity_gangtieronglu_record_title"),G_ColorWhite},logList,false,self.layerNum+1,nil,true,10,true,true)
        	end
		end
  		acXlysVoApi:getLog(showLog)				
	end

	local logBtn = G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth/2,(G_VisibleSizeHeight-155)/2-270+adaH*4),nil,"bless_record.png","bless_record.png","bless_record.png",recordCallback,0.8,-(self.layerNum-1)*20-2)
	local logBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    logBg:setAnchorPoint(ccp(0.5,1))
    logBg:setContentSize(CCSizeMake(logBtn:getContentSize().width+10,40))
    logBg:setPosition(ccp(logBtn:getContentSize().width/2,0))
    logBg:setScale(1/logBtn:getScale())
    logBg:setOpacity(0)
    logBtn:addChild(logBg)
    local logLb=GetTTFLabelWrap(getlocal("serverwar_point_record"),strSize,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    logLb:setPosition(logBg:getContentSize().width/2,logBg:getContentSize().height/2)
    logBg:addChild(logLb)

    local strSize = 18
    if G_isAsia() == false then
    	strSize = 15
    end

	local rewardLb = GetTTFLabelWrap(getlocal("activity_xlys_buyPrompt"),strSize,CCSize(600,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    rewardLb:setAnchorPoint(ccp(0.5,1))
    rewardLb:setPosition(ccp(G_VisibleSizeWidth/2,(G_VisibleSizeHeight-155)/2-350+adaH/2*9))
    self.bgLayer:addChild(rewardLb,2)
    local rewardLbBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    rewardLbBg:setAnchorPoint(ccp(0.5,1))
    rewardLbBg:setContentSize(CCSizeMake(rewardLb:getContentSize().width+10,30))
    rewardLbBg:setPosition(ccp(G_VisibleSizeWidth/2,(G_VisibleSizeHeight-155)/2-350+adaH/2*9))
    rewardLbBg:setOpacity(100)
    self.bgLayer:addChild(rewardLbBg)

    -- 抽奖奖励
    local function singelReward()
    	self:getReward(1)
    end

	local freeBtn = G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth/4,50),{getlocal("daily_lotto_tip_2"),24},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",singelReward,0.8,-(self.layerNum-1)*20-2)
	freeBtn:setVisible(false)
	self.freeBtn = freeBtn


	local singleBtn = G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth/4,50),{getlocal("emblem_getBtnLbHexie",{1}),24},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",singelReward,0.8,-(self.layerNum-1)*20-2)
	singleBtn:setVisible(false)
	self.singleBtn = singleBtn

	local costLb=GetTTFLabel(tostring(acXlysVoApi:getSingleCost()),24)
	costLb:setAnchorPoint(ccp(0,0.5))
	costLb:setColor(G_ColorYellowPro)
	costLb:setScale(1/0.8)
	costLb:setTag(1016)
	singleBtn:addChild(costLb)
	local costSp=CCSprite:createWithSpriteFrameName("IconGold.png")
	costSp:setAnchorPoint(ccp(0,0.5))
	costSp:setScale(1/0.8)
	singleBtn:addChild(costSp)
	local lbWidth=costLb:getContentSize().width+costSp:getContentSize().width+10
	costLb:setPosition(singleBtn:getContentSize().width/2-lbWidth/2,singleBtn:getContentSize().height+costLb:getContentSize().height/2+10)
	costSp:setPosition(costLb:getPositionX()+costLb:getContentSize().width+10,costLb:getPositionY())

	local function multiReward()
		self:getReward(5)
	end
	local multiBtn = G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth/4*3,50),{getlocal("emblem_getBtnLbHexie",{5}),24},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",multiReward,0.8,-(self.layerNum-1)*20-2)
	multiBtn:setVisible(false)
	self.multiBtn = multiBtn

	local costLb=GetTTFLabel(tostring(acXlysVoApi:getMultiCost()),24)
	costLb:setAnchorPoint(ccp(0,0.5))
	costLb:setColor(G_ColorYellowPro)
	costLb:setTag(1017)
	costLb:setScale(1/0.8)
	multiBtn:addChild(costLb)

	local costSp=CCSprite:createWithSpriteFrameName("IconGold.png")
	costSp:setAnchorPoint(ccp(0,0.5))
	costSp:setScale(1/0.8)
	multiBtn:addChild(costSp)

	local lbWidth=costLb:getContentSize().width+costSp:getContentSize().width+10
	costLb:setPosition(multiBtn:getContentSize().width/2-lbWidth/2,multiBtn:getContentSize().height+costLb:getContentSize().height/2+10)
	costSp:setPosition(costLb:getPositionX()+costLb:getContentSize().width+10,costLb:getPositionY())
	self:refreshBtn()

end


function acXlysTrainDialog:refreshBtn( ... )
	if self.freeBtn and self.singleBtn and self.multiBtn then
		local isNotEnd=activityVoApi:isStart(acXlysVoApi:getAcVo())
		if isNotEnd then
			if acXlysVoApi:getFirstFree() == 0 then
				self.freeBtn:setVisible(true)
				self.singleBtn:setVisible(false)
				self.multiBtn:setVisible(true)
				self.multiBtn:setEnabled(false)
			else
				self.freeBtn:setVisible(false)
				self.singleBtn:setVisible(true)
				self.multiBtn:setVisible(true)
				self.multiBtn:setEnabled(true)
			end
			local singleCostLabel= tolua.cast(self.singleBtn:getChildByTag(1016),"CCLabelTTF")
			if singleCostLabel and playerVoApi:getGems() < acXlysVoApi:getSingleCost() then
				singleCostLabel:setColor(G_ColorRed)
			else
				singleCostLabel:setColor(G_ColorYellowPro)
			end
			local mutliCostLabel= tolua.cast(self.multiBtn:getChildByTag(1017),"CCLabelTTF")
			if mutliCostLabel and playerVoApi:getGems() < acXlysVoApi:getMultiCost() then
				mutliCostLabel:setColor(G_ColorRed)
			else
				mutliCostLabel:setColor(G_ColorYellowPro)
			end
		else
			self.freeBtn:setEnabled(false)
			self.singleBtn:setEnabled(false)
			self.multiBtn:setEnabled(false)
		end
	end
end

function acXlysTrainDialog:getReward(num)

	if self.actionFlag == 1 then
		do return end
	end

	local isFree = acXlysVoApi:getFirstFree()
	local cost

	if isFree == 0 then
		cost = 0
	elseif num == 1 then
		cost = acXlysVoApi:getSingleCost()
	else
		cost = acXlysVoApi:getMultiCost()
	end

	if num then
		local function confirmHandler( ... )
			if playerVoApi:getGems() < cost then
				local function closeCallback( ... )
					activityAndNoteDialog:closeAllDialog()
				end
		        GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost,closeCallback,nil)
				do return end
			end
			local function callback(fn,data)
	    		local ret,sData = base:checkServerData(data)
	    		if ret==true then
	    			local time
	    			local displayRewardTb = {}
	    			local actionTb = {}
					local rewardTb = nil
					local partRewardTb = nil
		    		local partNum = nil
		    		local allRewardTb = nil
					
	    			if sData.data and sData.data.xlys then
	    				if sData.data.xlys.t then
	    					time = sData.data.xlys.t
	    				end
	    				acXlysVoApi:updateSpecialData(sData.data.xlys)
		    			playerVoApi:setGems(playerVoApi:getGems()-cost)
	    				self:refreshBtn()
		    		end

		    		if sData.data and sData.data.reward then
					    local content = {}
					    -- 训练所得奖励
					    rewardTb = {}
	                    local hxReward = acXlysVoApi:getHexieReward()
			    		hxReward.num = hxReward.num *num
	    				table.insert(displayRewardTb,hxReward)
	    				table.insert(rewardTb,hxReward)
	    				for k,v in pairs(sData.data.reward) do
	    					for kk,vv in pairs(v) do
	    						table.insert(actionTb,tonumber(RemoveFirstChar(kk)))
	    						local reward = FormatItem(vv[1],nil,true)[1]
	    						local rewardDesc = getlocal("activity_xlys_rewardDisplay",{getlocal("activity_xlys_item"..RemoveFirstChar(kk)),vv[2]})
	    						reward.pointDesc = rewardDesc
	    						table.insert(rewardTb,reward)
	    						table.insert(displayRewardTb,reward)
	    					end
						end
		    			item = {}
		    			item.title = getlocal("activity_xlys_logtip",{num})
		    			item.reward = rewardTb
			    		table.insert(content,item)
		    			acXlysVoApi:insertLog(num,rewardTb,time)

			    		-- 训练完成单个项目所得奖励
			    		if sData.data and sData.data.part and #sData.data.part>0 then
			    			for i=1,#sData.data.part do
				    			partRewardTb = {}
				    			for k,v in pairs(sData.data.part[i]) do
				    				partNum = tonumber(RemoveFirstChar(k))+10
				    				local tempReward = FormatItem(v,nil,true)
				    				for k,v in pairs(tempReward) do
				    					table.insert(partRewardTb,v)
				    					table.insert(displayRewardTb,v)
				    				end
								end
				    			local item = {}
				    			item.title = getlocal("activity_xlys_partRewardLogtip",{getlocal("activity_xlys_item"..tostring(partNum-10))})
				    			item.reward = partRewardTb
				    			table.insert(content,item)
				    			if partRewardTb and partNum then
		    						acXlysVoApi:insertLog(partNum,partRewardTb,time)
		    					end
			    			end
			    		end
			    		
			    		-- 全部训练项目奖励
			    		if sData.data and sData.data.allRe and SizeOfTable(sData.data.allRe)>0 then
						
							local item = {}
			    			allRewardTb = {}
			    			allNum = 3
		    				local reward = FormatItem(sData.data.allRe,nil,true)[1]	
		    				table.insert(allRewardTb,reward)
				    		table.insert(displayRewardTb,reward)
			    			item.title = getlocal("activity_xlys_finalRewardLogtip")
			    			item.reward = allRewardTb
			    			table.insert(content,item)
							-- 橙色军徽发送公告
	                		local paramTab = {}
							paramTab.functionStr="xlys"
							paramTab.addStr="goTo_see_see"
							paramTab.colorStr="w,y,w"
					        local playerName = playerVoApi:getPlayerName() 
					        local elblemName = getlocal("emblem_name_"..reward.key)
							local message = {key="activity_xlys_getSystemMessage",param={playerName,elblemName}}
							chatVoApi:sendSystemMessage(message,paramTab) 
			    		end
			    		
			    		if allRewardTb and allNum then
			    			acXlysVoApi:insertLog(allNum,allRewardTb,time)
			    		end
			    		
			    		local function rewardShow( ... )
							self.actionFlag = 0
				    		for k,v in pairs(displayRewardTb) do
		                        G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
		        			end
							local function showEndHandler( ... )
								G_showRewardTip(displayRewardTb,true)
		                    end 
		                    local titleStr=getlocal("activity_wheelFortune4_reward")
		                    require "luascript/script/game/scene/gamedialog/rewardMultiShowSmallDialog"
		                    rewardMultiShowSmallDialog:showNewReward(self.layerNum+1,true,true,content,showEndHandler,titleStr)
			    		end 
			    		self.rewardShow = rewardShow
			    		for k,v in pairs(actionTb) do
			    			if k == #actionTb then
			    				self:runSigleAction(v,rewardShow)
			    			else
			    				self:runSigleAction(v)
			    			end
			    		end
		    		end
		    		
	    		end
		    end
			socketHelper:acXlysTrain(num,isFree,callback)
		end

		if cost == 0 then
			confirmHandler()
		else
			local function secondTipFunc(sbFlag)
	            local keyName = "xlys"
	            local sValue=base.serverTime .. "_" .. sbFlag
	            G_changePopFlag(keyName,sValue)
			end
	        local keyName = "xlys"
	        if G_isPopBoard(keyName) then
	           G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{cost}),true,confirmHandler,secondTipFunc)
	        else
	            confirmHandler()
	        end
		end 	
	end
end

-- 刷新抽奖结束后的面板数据
function acXlysTrainDialog:refreshData( ... )
	if self.numTb then
		for k,v in pairs(self.numTb) do
			local picStr,itemName = acXlysVoApi:getAreaPicAndName(k)
			v:setString(itemName)
		end
	end
	if self.progressTb then
		for k,v in pairs(self.progressTb) do
			v:setPercentage(math.ceil(acXlysVoApi:getPercentage(k)*25))
		end
	end
end


function acXlysTrainDialog:runSigleAction(id,rewardShow)

	self.actionFlag = 1
	self.touchSp:setPosition(ccp(G_VisibleSizeWidth/2,0))

	local flag 
	if id == 1 or id == 4 then
		flag = 1
	else
		flag = 0
	end

	local pic 

    if id == 1 or id == 3 then
    	pic = "xlysYellowLine.png"
    else
    	pic = "xlysYellowLine1.png"
    end

    local acArr = CCArray:create()

    local yellowLight=CCParticleSystemQuad:create("public/YELLOWrect.plist")
    yellowLight.positionType=kCCPositionTypeFree
    yellowLight:setPosition(ccp(G_VisibleSizeWidth/2+245*(-1)^flag,(G_VisibleSizeHeight-155)/2+160*(-1)^math.floor(id/3)))
    yellowLight:setScale(1.5)
    self.touchSp:addChild(yellowLight)

	local light=CCParticleSystemQuad:create("public/pointlight.plist")
    light.positionType=kCCPositionTypeFree
    light:setVisible(false)
    self.touchSp:addChild(light)

    local progressArr = CCArray:create()
    local function delayBack( ... )
    	light:setVisible(true)
    end
	local delay=CCDelayTime:create(0.5)
	local delayFunc = CCCallFunc:create(delayBack)

	acArr:addObject(delay)
	acArr:addObject(delayFunc)
 
    local lineSp = CCSprite:createWithSpriteFrameName(pic)
    local lineProgress = CCProgressTimer:create(lineSp)
	lineProgress:setAnchorPoint(ccp(0.5,0.5))
	lineProgress:setType(kCCProgressTimerTypeBar)
	lineProgress:setBarChangeRate(ccp(1, 0))
	lineProgress:setPosition(ccp(G_VisibleSizeWidth/2+140*(-1)^flag,(G_VisibleSizeHeight-155)/2+145*(-1)^math.floor(id/3)))
	self.touchSp:addChild(lineProgress)

	if id == 1 then
	 	lineProgress:setMidpoint(ccp(0, 0.5))
	elseif id == 2 then
	 	lineProgress:setMidpoint(ccp(1, 0.5))
	elseif id == 3 then
	 	lineProgress:setMidpoint(ccp(0, 0.5))
	 	lineProgress:setRotation(180)
	else
	 	lineProgress:setMidpoint(ccp(1, 0.5))
	 	lineProgress:setRotation(180)
	end

	local progressTo = CCProgressTo:create(1, 100)
	progressArr:addObject(delay)
	progressArr:addObject(progressTo)
	local progressSeq = CCSequence:create(progressArr)
	lineProgress:runAction(progressSeq)

    local midPos = self.actionCfg[id]

    if midPos then
    	local move1
    	local move2
    	if id == 1 then
    		light:setPosition(ccp(midPos.x-36,midPos.y+15))
			move1=CCMoveBy:create(0.5,ccp(36,0))
			move2=CCMoveBy:create(0.5,ccp(40,-35))
    	elseif id == 2 then
    		light:setPosition(ccp(midPos.x+36,midPos.y+15))
			move1=CCMoveBy:create(0.5,ccp(-36,0))
			move2=CCMoveBy:create(0.5,ccp(-40,-35))
    	elseif id == 3 then
    		light:setPosition(ccp(midPos.x+36,midPos.y-15))
			move1=CCMoveBy:create(0.5,ccp(-36,0))
			move2=CCMoveBy:create(0.5,ccp(-40,35))
    	else
    		light:setPosition(ccp(midPos.x-36,midPos.y-15))
			move1=CCMoveBy:create(0.5,ccp(36,0))
			move2=CCMoveBy:create(0.5,ccp(40,35))
    	end
    	acArr:addObject(move1)
    	acArr:addObject(move2)
    end	

    local function playEnd()

        self:refreshData()

    	if light then
	    	light:removeFromParentAndCleanup(true)
			light = nil
		end

		if yellowLight then
			yellowLight:removeFromParentAndCleanup(true)
			yellowLight = nil
		end

		if self.numTb[id] then
			local numArr = CCArray:create()
			local scaleToBig =  CCScaleTo:create(0.25,1.3)
			local scaleToSmall =  CCScaleTo:create(0.25,1)
			numArr:addObject(scaleToBig)
			numArr:addObject(scaleToSmall)
			local seq = CCSequence:create(numArr)
			self.numTb[id]:runAction(seq)
		end

    	self.fadeBgTb[id]:setVisible(true)
        local acArr = CCArray:create()
  		local fadeTo = CCFadeTo:create(0.25, 55)
    	local fadeBack = CCFadeTo:create(0.25, 255)
    	acArr:addObject(fadeTo)
    	acArr:addObject(fadeBack)
        local seq = CCSequence:create(acArr)
        local function callBack( ... )
			self.fadeBgTb[id]:setVisible(false)
			if lineProgress then
				lineProgress:removeFromParentAndCleanup(true)
				lineProgress = nil
			end
			if rewardShow then
				self.touchSp:setPosition(ccp(9999,0))
				rewardShow()
			end	
		end 
		local callFunc = CCCallFunc:create(callBack)
		local allac = CCSequence:createWithTwoActions(seq,callFunc)
		self.fadeBgTb[id]:runAction(allac)
    end
    local callFunc=CCCallFuncN:create(playEnd)
    acArr:addObject(callFunc)
   	local seq=CCSequence:create(acArr)
   	light:runAction(seq)
end

function acXlysTrainDialog:tick( ... )
	if self.timeLb then
		self.timeLb:setString(acXlysVoApi:getAcTimeStr())
	end
	if acXlysVoApi:isToday() == false then
		self:refreshBtn()
	end
end


function acXlysTrainDialog:dispose( ... )
	self.layerNum = nil
	self.bgLayer1 = nil
	self.bgLayer = nil
end