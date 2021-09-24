-- @Author hj
-- @Description 新春聚惠抽奖
-- @Date 2018-12-24

acXcjhZcjbDialog = {}

function acXcjhZcjbDialog:new(layer,partent)
	local nc = {
		layerNum = layer,
		partent = partent,
		rewardNode = {},
		actionFlag = 0,
		rewardPos = {},
		rewardTb = {}
	}
	setmetatable(nc,self)
	self.__index = self
	return nc
end

function acXcjhZcjbDialog:init()
	self.bgLayer=CCLayer:create()
	self:doUserHandler()
	self:initTableView()
	return self.bgLayer
end

function acXcjhZcjbDialog:doUserHandler( ... )

	if self.partent and self.partent.bgLayer then
		local rewardLayer = CCLayer:create()
		rewardLayer:setTag(1016)
		self.partent.bgLayer:addChild(rewardLayer,4)
		self.rewardLayer = rewardLayer
	end


    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	
	local function onLoadIcon(fn,icon)
		if self and self.bgLayer and  tolua.cast(self.bgLayer,"CCLayer") and icon then
			
			if acXcjhVoApi:getVersion(  )==2 then
				icon:setAnchorPoint(ccp(0.5,1))
				icon:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160))
			else
				icon:setAnchorPoint(ccp(0.5,0))
				icon:setPosition(ccp(G_VisibleSizeWidth/2,0))
			end
			if G_getIphoneType() == G_iphone4 then
				-- 裁切适配区域
				local clipper=CCClippingNode:create()
				clipper:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
				clipper:setAnchorPoint(ccp(0.5,0))
				clipper:setPosition(G_VisibleSizeWidth/2,0)

				local stencil=CCDrawNode:getAPolygon(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-162),1,1)
				clipper:setStencil(stencil) 
				clipper:addChild(icon)
				self.bgLayer:addChild(clipper)
			else
				self.bgLayer:addChild(icon)	
			end

			local function onLoadIcon(fn,icon)
				if self and self.bgLayer and tolua.cast(self.bgLayer,"CCLayer") then
					icon:setAnchorPoint(ccp(0.5,1))
					if acXcjhVoApi:getVersion(  )==2 then
						icon:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160))
						icon:setScaleY(2.4)
						if G_getIphoneType() == G_iphone4 then
							icon:setScaleY(1.8)
						end
					else
						icon:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-162))
					end
					self.bgLayer:addChild(icon)
				end
			end 
			local webImage
			if acXcjhVoApi:getVersion(  )==2 then
				webImage=LuaCCWebImage:createWithURL(G_downloadUrl("xcjh/xcjh1_2_v2.png"),onLoadIcon)
			else
				webImage=LuaCCWebImage:createWithURL(G_downloadUrl("xcjh/xcjh1_1.jpg"),onLoadIcon)
			end
		end
	end
	local webImage
	if acXcjhVoApi:getVersion(  )==2 then
		webImage=LuaCCWebImage:createWithURL(G_downloadUrl("xcjh/xcjh1_v2.jpg"),onLoadIcon)
	else
		webImage=LuaCCWebImage:createWithURL(G_downloadUrl("xcjh/xcjh1_2.jpg"),onLoadIcon)
	end
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)


    self:initRewardArea()

    -- 抽奖奖励
    local function singelReward()
    	if self.actionFlag == 1 then
    		do return end
    	else
    		self:getReward(1)
    	end
    end

	local freeBtn,freeMenu = G_createBotton(self.bgLayer,ccp(9999,0),{getlocal("daily_lotto_tip_2"),24},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",singelReward,0.8,-(self.layerNum-1)*20-2,2)
	self.freeBtn = freeBtn
	self.freeMenu = freeMenu

	local singleBtn,singleMenu = G_createBotton(self.bgLayer,ccp(9999,0),{getlocal("emblem_getBtnLbHexie",{1}),24},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",singelReward,0.8,-(self.layerNum-1)*20-2,2)
	self.singleBtn = singleBtn
	self.singleMenu = singleMenu

	local costLb=GetTTFLabel(tostring(acXcjhVoApi:getSingleCost()),24)
	costLb:setAnchorPoint(ccp(0,0.5))
	-- costLb:setColor(G_ColorYellowPro)
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
		if self.actionFlag == 1 then
    		do return end
    	else
    		self:getReward(5)
    	end
	end

	local multiBtn,multiMenu = G_createBotton(self.bgLayer,ccp(9999,0),{getlocal("emblem_getBtnLbHexie",{5}),24},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",multiReward,0.8,-(self.layerNum-1)*20-2,2)
	self.multiBtn = multiBtn
	self.multiMenu = multiMenu

	local costLb=GetTTFLabel(tostring(acXcjhVoApi:getMultiCost()),24)
	costLb:setAnchorPoint(ccp(0,0.5))
	-- costLb:setColor(G_ColorYellowPro)
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


	local function recordCallback( ... )
		local function showLog(rewardLog)
            if #rewardLog == 0 then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_tccx_no_record"),30)
            else
                local logNum=SizeOfTable(rewardLog)
                require "luascript/script/game/scene/gamedialog/activityAndNote/acCjyxSmallDialog"
            	acCjyxSmallDialog:showLogDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-300),CCRect(130, 50, 1, 1),{getlocal("activity_gangtieronglu_record_title"),G_ColorWhite},rewardLog,false,self.layerNum+1,nil,true,10,true,true)
        	end
		end
  		acXcjhVoApi:getLog(showLog)				
	end

	local logBtn = G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth-98,205),nil,"bless_record.png","bless_record.png","bless_record.png",recordCallback,0.8,-(self.layerNum-1)*20-2,2)
	local logBg=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackFadeBar.png",CCRect(0,0,1,9),function ()end)
    logBg:setAnchorPoint(ccp(0.5,1))
    logBg:setContentSize(CCSizeMake(logBtn:getContentSize().width+10,30))
    logBg:setPosition(ccp(logBtn:getContentSize().width/2,0))
    logBg:setOpacity(255*0.6)
    logBtn:addChild(logBg)
    local logLb=GetTTFLabelWrap(getlocal("serverwar_point_record"),25,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    logLb:setPosition(logBg:getContentSize().width/2,logBg:getContentSize().height/2)
    logBg:addChild(logLb)


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
        local rewardTb = FormatItem(acXcjhVoApi:getRewardPool(),true,true)
        local titleStr = getlocal("award")
        local descStr
        if acXcjhVoApi:getVersion()==1 then
        	descStr = getlocal("activity_xcjh_awardTip")
        else
        	descStr = getlocal("activity_xcjh_awardTip_v2")
        end
        local needTb = {"xcjh",titleStr,descStr,rewardTb,SizeOfTable(rewardTb)}
        local bigAwardDia = acThrivingSmallDialog:new(self.layerNum+1,needTb)
        bigAwardDia:init()
    end
    local poolBtn=GetButtonItem("taskBox5.png","taskBox5.png","taskBox5.png",rewardPoolHandler,11)
    poolBtn:setScale(0.8)
    local poolMenu=CCMenu:createWithItem(poolBtn)
    poolMenu:setTouchPriority(-(self.layerNum-1)*20-2)
    poolMenu:setPosition(ccp(98,210))
    self.bgLayer:addChild(poolMenu,1)
    local poolBg=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackFadeBar.png",CCRect(0,0,1,9),function ()end)
    poolBg:setAnchorPoint(ccp(0.5,1))
    poolBg:setOpacity(255*0.6)
    poolBg:setContentSize(CCSizeMake(poolBtn:getContentSize().width+10,30))
    poolBg:setPosition(ccp(poolBtn:getContentSize().width/2,0))
    poolBtn:addChild(poolBg)
    local poolLb=GetTTFLabelWrap(getlocal("award"),25,CCSize(130,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    poolLb:setPosition(poolBg:getContentSize().width/2,poolBg:getContentSize().height/2)
    poolBg:addChild(poolLb)

    local strSize = 20
    if G_isAsia() == false then
    	strSize = 18
    end

    local fiveLabel
    if acXcjhVoApi:getVersion()==1 then
    	fiveLabel = GetTTFLabelWrap(getlocal("activity_xcjh_fiveReward"),strSize,CCSize(450,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    else
    	fiveLabel = GetTTFLabelWrap(getlocal("activity_xcjh_fiveReward_v2"),strSize,CCSize(450,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    end
    fiveLabel:setAnchorPoint(ccp(0.5,0.5))
    fiveLabel:setColor(G_ColorYellowPro)

    local circleSp
    if acXcjhVoApi:getVersion()==2 then

    else
	    circleSp = CCSprite:createWithSpriteFrameName("ring.png")
		circleSp:setAnchorPoint(ccp(0.5,0.5))
		circleSp:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160-100)
		-- self.circleSp = circleSp
		if G_getIphoneType() == G_iphone4 then
			circleSp:setScale(0.75)
		end
		self.bgLayer:addChild(circleSp)

		
	end

	local levelBg1 = LuaCCScale9Sprite:createWithSpriteFrameName("newBlackFadeBar.png",CCRect(0,0,1,9),function ()end)
	if acXcjhVoApi:getVersion()==1 then
    	levelBg1:setOpacity(255*0.8)
    else
    	levelBg1:setOpacity(255*0.5)
    end
    levelBg1:setContentSize(CCSizeMake(450,40))
    levelBg1:setAnchorPoint(ccp(0.5,1))
    levelBg1:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-162-55))
    levelBg1:addChild(fiveLabel)
    fiveLabel:setPosition(ccp(levelBg1:getContentSize().width/2,levelBg1:getContentSize().height/2))
    self.bgLayer:addChild(levelBg1,2)

	local hxReward=acXcjhVoApi:getHexieReward()
	if hxReward and hxReward.name then
	    local rewardLabel = GetTTFLabelWrap(getlocal("activity_fyss_lotteryDesc",{hxReward.name}),strSize,CCSize(350,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
	    -- local levelBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("newBlackFadeBar.png",CCRect(0,0,1,9),function ()end)
	    -- levelBg2:setOpacity(255*0.4)
	    -- levelBg2:setContentSize(CCSizeMake(rewardLabel:getContentSize().width+10,rewardLabel:getContentSize().height))
	    -- levelBg2:setAnchorPoint(ccp(0.5,0.5))
	    -- levelBg2:setPosition(ccp(G_VisibleSizeWidth/2,185))
	    -- levelBg2:addChild(rewardLabel)
	    rewardLabel:setAnchorPoint(ccp(0.5,0.5))
	    rewardLabel:setColor(G_ColorYellowPro)
	    rewardLabel:setPosition(ccp(G_VisibleSizeWidth/2,195))
	    self.bgLayer:addChild(rewardLabel,2)
	end




	-- 触摸停止动画
   	local function touchHandler( ... )

   		if self.actionFlag == 1 then

   			local randomArr = self.randomArr

			self.actionFlag = 0
			self.rewardLayer:stopAllActions()
			self.rewardLayer:removeAllChildrenWithCleanup(true)
			self.rewardNode = {}
			self:initRewardArea()

	    	local acArr = CCArray:create()
	    	local function show( ... )
	    		for k,v in pairs(randomArr) do
					if self.rewardNode[v] and self.rewardNode[v]:getChildByTag(1016) then
						self.rewardNode[v]:getChildByTag(1016):setVisible(false)
						local icon,scale=G_getItemIcon(self.rewardTb[k+1],80,false,self.layerNum+1,nil,nil,nil,nil,nil,nil,true)
						icon:setAnchorPoint(ccp(0.5,0.5))
						if acXcjhVoApi:getVersion()==1 then
			    			icon:setPosition(ccp(49.5,self.rewardNode[v]:getContentSize().height-130+50))
			    		else
			    			icon:setPosition(ccp(49.5,self.rewardNode[v]:getContentSize().height-130+80))
			    			icon:setScale(75/icon:getContentSize().width)
			    		end
			    		self.rewardNode[v]:addChild(icon,1)
					end
				end
			end

			local callFunc = CCCallFunc:create(show)
			local delay = CCDelayTime:create(1)

			local function endCallback( ... )

				self.touchSp:setPosition(9999,0)
				-- self.circleSp:setVisible(true)
				self:rewardShow()
				self.rewardLayer:stopAllActions()
				self.rewardLayer:removeAllChildrenWithCleanup(true)
				self.rewardNode = {}
				self:initRewardArea()
			end

			local endCall = CCCallFunc:create(endCallback)
			acArr:addObject(callFunc)
			acArr:addObject(delay)
			acArr:addObject(endCall)

			local  seq = CCSequence:create(acArr)
			self.rewardBg:runAction(seq)
		end

   	end

	local touchSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchHandler)
	touchSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-160))
	touchSp:setAnchorPoint(ccp(0.5,0))
	touchSp:setPosition(ccp(9999,0))
	touchSp:setTouchPriority(-(self.layerNum-1)*20-5)
	self.bgLayer:addChild(touchSp)
	touchSp:setIsSallow(true)
    touchSp:setVisible(false)
    self.touchSp = touchSp

end 

function acXcjhZcjbDialog:getReward(num)

	if acXcjhVoApi:isGetRewardTime() == false then
		smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("activity_xcjh_notEngage"), 30)
		do return end
	end

	if self.actionFlag == 1 then
		do return end
	end

	local cost

	local isFree = acXcjhVoApi:getFirstFree()

	if isFree == 0 then
		cost = 0
	elseif num == 1 then
		cost = acXcjhVoApi:getSingleCost()
	else
		cost = acXcjhVoApi:getMultiCost()
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
	    		if ret == true then

	    			local time = base.serverTime
    				if sData.data and sData.data.xcjh then
	    				if sData.data.xcjh.t then
	    					time = sData.data.xcjh.t
	    				end
	    				acXcjhVoApi:updateSpecialData(sData.data.xcjh)
		    			playerVoApi:setGems(playerVoApi:getGems()-cost)
	    				self:refreshBtn()
	    			end

		    		if sData.data and sData.data.reward then

		    			local realNum = #sData.data.reward
		    			self.rewardTb = {}
		    			self.randomArr = {}

		    			local hxReward = acXcjhVoApi:getHexieReward()
			    		hxReward.num = hxReward.num * realNum
	    				table.insert(self.rewardTb,hxReward)

	    				for k,v in pairs(sData.data.reward) do
	    					local reward = FormatItem(v,nil,true)[1]
	    					table.insert(self.rewardTb,reward)
						end


						for k,v in pairs(self.rewardTb) do
        					G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
    					end

		    			local randomArr = acXcjhVoApi:getRandom(realNum)
		    			
		    			self.randomArr = randomArr
						if self.actionFlag == 0 then
							self:runCircleAction(1,randomArr)
						end

		    		end
		    		acXcjhVoApi:insertLog({getlocal("activity_xcjh_logtip",{num})},{{self.rewardTb}},time)
	    		end
			end
			socketHelper:acXcjhGetReward(num,isFree,callback)
		end

		if cost == 0 then
			confirmHandler()
		else
			local function secondTipFunc(sbFlag)
	            local keyName = "xcjh"
	            local sValue=base.serverTime .. "_" .. sbFlag
	            G_changePopFlag(keyName,sValue)
			end
	        local keyName = "xcjh"
	        if G_isPopBoard(keyName) then
	           G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{cost}),true,confirmHandler,secondTipFunc)
	        else
	            confirmHandler()
	        end
		end 
	end
end

function acXcjhZcjbDialog:initRewardArea( ... )
	
	-- 16*16的抽奖区域
	local function nilFunc( ... )
    end
    local rewardBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),nilFunc)
    self.rewardLayer:addChild(rewardBg,3)
    rewardBg:setAnchorPoint(ccp(0.5,1))
    rewardBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-164,G_VisibleSizeHeight-160-90-30-120-130))
    rewardBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160-90-50))
    rewardBg:setOpacity(0)
    self.rewardBg = rewardBg

    if acXcjhVoApi:getVersion()==2 then

    else
	    local forbidSp = CCSprite:createWithSpriteFrameName("xcjh_forbid.png")
	    forbidSp:setAnchorPoint(ccp(0.5,1))
	    forbidSp:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-165-98))
	    self.rewardLayer:addChild(forbidSp,2)
	end


	if self.rewardBg and tolua.cast(self.rewardBg,"LuaCCScale9Sprite") then
		
		for i=1,4 do
			for j=1,4 do
				local scale = 1
				if G_getIphoneType() == G_iphone4  then
					scale = 0.75
				end
				local rewardNode = CCNode:create()
				rewardNode:setContentSize(CCSizeMake(104,self.rewardBg:getContentSize().height/4))
				rewardNode:setAnchorPoint(ccp(0,1))
				if acXcjhVoApi:getVersion()==1 then
					rewardNode:setPosition(ccp((j-1)*124,self.rewardBg:getContentSize().height/4*(4-i+1)))
				else
					rewardNode:setPosition(ccp((j-1)*124,self.rewardBg:getContentSize().height/4*(4-i+1)+20))
				end
				self.rewardNode[(i-1)*4+j] = rewardNode
				rewardNode:setScale(scale)
				self.rewardBg:addChild(rewardNode)

				self.rewardPos[(i-1)*4+j] = ccp(52+(j-1)*124+82,G_VisibleSizeHeight-self.rewardBg:getContentSize().height/4*(i-1)-300-62)

				if acXcjhVoApi:getVersion()==2 then
					local nationalDayBall = CCSprite:createWithSpriteFrameName("nationalDayBall.png")
					nationalDayBall:setAnchorPoint(ccp(0,1))
					nationalDayBall:setPosition(ccp(0,rewardNode:getContentSize().height))
					nationalDayBall:setTag(1016)
					rewardNode:addChild(nationalDayBall,1)

					local num = (i-1)*4+j
					local str 
					if num < 10 then
						str = "0"..num
					else
						str = tostring(num)
					end
					local textLabel = GetTTFLabel(str,35,true)
					textLabel:setAnchorPoint(ccp(0.5,0.5))
					textLabel:setPosition(ccp(nationalDayBall:getContentSize().width/2,nationalDayBall:getPositionY()/5*3))
					if G_getIphoneType() == G_iphone4 then
						textLabel:setPosition(ccp(nationalDayBall:getContentSize().width/2,nationalDayBall:getPositionY()/5*3+25))
					end
					textLabel:setColor(G_ColorBrown)
					textLabel:setTag(1017)
					nationalDayBall:addChild(textLabel)
				else
					local calendarUp = CCSprite:createWithSpriteFrameName("calendarUp.png")
					calendarUp:setAnchorPoint(ccp(0,1))
					calendarUp:setPosition(ccp(0,rewardNode:getContentSize().height))
					rewardNode:addChild(calendarUp,1)

					local calendarDown = CCSprite:createWithSpriteFrameName("calendarDown.png")
					calendarDown:setAnchorPoint(ccp(0,1))
					calendarDown:setPosition(ccp(0,rewardNode:getContentSize().height-calendarUp:getContentSize().height))
					calendarDown:setTag(1016)
					rewardNode:addChild(calendarDown,2)

					local num = (i-1)*4+j
					local str 
					if num < 10 then
						str = "0"..num
					else
						str = tostring(num)
					end
					local textLabel = GetTTFLabel(str,35,true)
					textLabel:setAnchorPoint(ccp(0.5,0.5))
					textLabel:setPosition(getCenterPoint(calendarDown))
					textLabel:setColor(G_ColorBrown)
					textLabel:setTag(1017)
					calendarDown:addChild(textLabel)

					local nail = CCSprite:createWithSpriteFrameName("nail.png")
					nail:setAnchorPoint(ccp(0.5,0.5))
					nail:setPosition(calendarUp:getContentSize().width/2,calendarUp:getContentSize().height/2)
					calendarUp:addChild(nail,2)
				end

			end
		end

	end

end

function acXcjhZcjbDialog:refreshBtn( ... )

	if self.freeMenu and self.singleMenu and self.multiMenu then
		local isNotEnd=activityVoApi:isStart(acXcjhVoApi:getAcVo())
		if isNotEnd == true then
			if acXcjhVoApi:isGetRewardTime() == true then
				if acXcjhVoApi:getFirstFree() == 0 then
					self.freeMenu:setPosition(ccp(G_VisibleSizeWidth/4,50))
					self.singleMenu:setPosition(ccp(9999,0))
					self.multiMenu:setPosition(ccp(G_VisibleSizeWidth*3/4,50))
					self.multiBtn:setEnabled(false)
				else
					self.freeMenu:setPosition(ccp(9999,50))
					self.singleMenu:setPosition(ccp(G_VisibleSizeWidth/4,50))
					self.multiMenu:setPosition(ccp(G_VisibleSizeWidth*3/4,50))
					self.multiBtn:setEnabled(true)
				end
				local singleCostLabel= tolua.cast(self.singleBtn:getChildByTag(1016),"CCLabelTTF")
				if singleCostLabel and playerVoApi:getGems() < acXcjhVoApi:getSingleCost() then
					singleCostLabel:setColor(G_ColorRed)
				end
				local mutliCostLabel= tolua.cast(self.multiBtn:getChildByTag(1017),"CCLabelTTF")
				if mutliCostLabel and playerVoApi:getGems() < acXcjhVoApi:getMultiCost() then
					mutliCostLabel:setColor(G_ColorRed)
				end
			else
				self.freeMenu:setPosition(ccp(9999,50))
				self.singleMenu:setPosition(ccp(G_VisibleSizeWidth/4,50))
				self.multiMenu:setPosition(ccp(G_VisibleSizeWidth*3/4,50))
				self.multiBtn:setEnabled(true)
			end
		else
			self.freeBtn:setEnabled(false)
			self.singleBtn:setEnabled(false)
			self.multiBtn:setEnabled(false)
		end
	end
end

-- 光圈动作
function acXcjhZcjbDialog:runCircleAction(seq,randomArr)

	self.actionFlag = 1
	self.touchSp:setPosition(ccp(G_VisibleSizeWidth/2,0))
	-- self.circleSp:setVisible(false)
	local index = randomArr[seq]

	local blendFunc=ccBlendFunc:new()--混合模式为 ONE ONE
	blendFunc.src=GL_ONE
	blendFunc.dst=GL_ONE


	if acXcjhVoApi:getVersion()==2 then
		local darts = CCSprite:createWithSpriteFrameName("xcjhDarts_v2.png")
		-- darts:setScale(200/darts:getContentSize().height)
		darts:setAnchorPoint(ccp(0.5,1))
		darts:setPosition(ccp(self.rewardPos[index].x,0))
		darts:setScale(1.1)
		self.rewardLayer:addChild(darts,1)
		if G_getIphoneType() == G_iphone4 then
			darts:setScale(0.9)
		end

		-- 移动的动作
		local function callback( ... )
			darts:removeFromParentAndCleanup(true)
			
			local ball = CCSprite:createWithSpriteFrameName("qiqiu_bz0001.png")
			ball:setAnchorPoint(ccp(0.5,0))
			ball:setPosition(ccp(self.rewardPos[index].x-2,self.rewardPos[index].y-95))
			if G_getIphoneType() == G_iphone4 then
				ball:setScale(0.7)
				ball:setPosition(ccp(self.rewardPos[index].x-14,self.rewardPos[index].y-45))
			end
			self.rewardLayer:addChild(ball,5)
			self:showReward(seq,randomArr)
	   		
			local function callFuncBall( ... )
				ball:removeFromParentAndCleanup(true)
			end
		G_playFrame(ball,{frmn=18,frname="qiqiu_bz000",perdelay=0.05,blendType=1,callback=callFuncBall})
		end

		local function nextCallBack()
	   		if randomArr[seq+1] then
	   			self:runCircleAction(seq+1,randomArr)
	   		end
	   	end

		local acArr = CCArray:create()

		local move1=CCMoveTo:create(0.05,CCPointMake(self.rewardPos[index].x-10,0))

		local move2=CCMoveTo:create(0.30,ccp(self.rewardPos[index].x-10,self.rewardPos[index].y+20))
		if G_getIphoneType() == G_iphone4 then
			move2=CCMoveTo:create(0.35,ccp(self.rewardPos[index].x-10,self.rewardPos[index].y+30))
		end

		local scaleToBig =  CCScaleTo:create(0,1,1.5)
	    local scaleToNormal =  CCScaleTo:create(0.25,0.2,0.4)
	    local delay=CCDelayTime:create(0.1)
	    local callFuncNext = CCCallFunc:create(nextCallBack)
	    local callFunc = CCCallFunc:create(callback)
	    local fadeOut=CCTintTo:create(0.05,255,97,0)

	    local acArr=CCArray:create()
	    acArr:addObject(move1)
	    acArr:addObject(scaleToBig)
	    acArr:addObject(callFuncNext)
	    acArr:addObject(scaleToNormal)
	    acArr:addObject(move2)
	    acArr:addObject(fadeOut)
	    -- acArr:addObject(delay)
	    acArr:addObject(callFunc)

	   	local seq=CCSequence:create(acArr)
	   	darts:runAction(seq)
	   	-- darts:removeFromParentAndCleanup(true)

		
	else
		local circleSp = CCSprite:createWithSpriteFrameName("ring.png")
		circleSp:setAnchorPoint(ccp(0.5,0.5))
		circleSp:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160-100)
		self.rewardLayer:addChild(circleSp,1)
		circleSp:setBlendFunc(blendFunc)

		if G_getIphoneType() == G_iphone4 then
			circleSp:setScale(0.75)
		end

		-- 移动的动作
		local acArr1 = CCArray:create()

		local move1=CCMoveBy:create(0.1,CCPointMake(0,-25))

		local move2=CCMoveTo:create(0.2,self.rewardPos[index])
		if G_getIphoneType() == G_iphone4 then
			move2=CCMoveTo:create(0.2,ccp(self.rewardPos[index].x-20,self.rewardPos[index].y+10))
		end
		local function reorder( ... )
			self.rewardLayer:reorderChild(circleSp,4)
		end 
		local callFuncReorder = CCCallFunc:create(reorder)


		local bezierCfg=ccBezierConfig()
	    bezierCfg.controlPoint_1=ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-40)
		bezierCfg.controlPoint_2=ccp(self.rewardPos[index].x,G_VisibleSizeHeight-30)
	    bezierCfg.endPosition=ccp(self.rewardPos[index].x,G_VisibleSizeHeight-40)
	   	local bezierEffect=CCBezierTo:create(0.4,bezierCfg)

	   	acArr1:addObject(move1)
	   	acArr1:addObject(bezierEffect)
	   	acArr1:addObject(callFuncReorder)
	   	acArr1:addObject(move2)

	   	local seq1=CCSequence:create(acArr1)

	   	-- 转圈的动作
	   	local acArr2 = CCArray:create()


	   	local function nextCallBack()
	   		if randomArr[seq+1] then
	   			self:runCircleAction(seq+1,randomArr)
	   		end
	   	end

	   	local delay1 = CCDelayTime:create(0.1)
	   	local scale1 = CCScaleTo:create(0.03,1,0.7)
	   	local scale2 = CCScaleTo:create(0.07,1,-1)
	   	local scale3 = CCScaleTo:create(0.03,1,-0.7)
	   	local scale4 = CCScaleTo:create(0.07,1,1)
	   	local callFuncNext = CCCallFunc:create(nextCallBack)
	   	local scale5 = CCScaleTo:create(0.03,1,0.7)
	   	local scale6 = CCScaleTo:create(0.07,1,-1)
	   	local scale7 = CCScaleTo:create(0.03,1,-0.7)
	   	local scale8 = CCScaleTo:create(0.07,1,1)
	   	local scale13 = CCScaleTo:create(0.03,1,0.7)
	   	local scale14 = CCScaleTo:create(0.07,1,-1)
	   	local scale15 = CCScaleTo:create(0.03,1,-0.7)
	   	local scale16 = CCScaleTo:create(0.07,1,1)

	   	acArr2:addObject(delay1)
	   	acArr2:addObject(scale1)
	   	acArr2:addObject(scale2)
	   	acArr2:addObject(scale3)
	   	acArr2:addObject(scale4)
	   	acArr2:addObject(callFuncNext)
	   	acArr2:addObject(scale5)
	   	acArr2:addObject(scale6)
	   	acArr2:addObject(scale7)
	   	acArr2:addObject(scale8)
	   	acArr2:addObject(scale13)
	   	acArr2:addObject(scale14)
	   	acArr2:addObject(scale15)
	   	acArr2:addObject(scale16)

	   	local seq2=CCSequence:create(acArr2)

	   	local acArr3 = CCArray:create()
	   	acArr3:addObject(seq1)
	   	acArr3:addObject(seq2)

	   	local spawn = CCSpawn:create(acArr3)


	   	local function callBack( ... )

			local guang1 = CCSprite:createWithSpriteFrameName("xcjh_guang01.png")
			guang1:setAnchorPoint(ccp(0.5,0.5))
			guang1:setPosition(self.rewardPos[index])
			self.rewardLayer:addChild(guang1,4)
			guang1:setBlendFunc(blendFunc)

			local guang2 = CCSprite:createWithSpriteFrameName("xcjh_guang02.png")
			guang2:setAnchorPoint(ccp(0.5,0.5))
			guang2:setPosition(self.rewardPos[index])
			self.rewardLayer:addChild(guang2,4)
			guang2:setBlendFunc(blendFunc)


	   		local acArr1 = CCArray:create()
	   		local acArr2 = CCArray:create()
	   		local acArr3 = CCArray:create()


	   		local scale1 = CCScaleTo:create(0.2,1.6)
	   		local scale2 = CCScaleTo:create(0.2,2)
	   		local scale3 = CCScaleTo:create(0.2,1.3)
			
			local fade1 = CCFadeTo:create(0.2,0)
			local fade2 = CCFadeTo:create(0.2,0)
			local fade3 = CCFadeTo:create(0.2,0)

			acArr1:addObject(scale1)
			acArr1:addObject(fade1)

			acArr2:addObject(scale2)
			acArr2:addObject(fade2)

			acArr3:addObject(scale3)
			acArr3:addObject(fade3)


			local spawn1=CCSpawn:create(acArr1)
			local spawn2=CCSpawn:create(acArr2)
			local spawn3=CCSpawn:create(acArr3)

			local function callback( ... )
				self:showReward(seq,randomArr)
				circleSp:removeFromParentAndCleanup(true)
				guang1:removeFromParentAndCleanup(true)
				guang2:removeFromParentAndCleanup(true)
			end
			local callFunc = CCCallFunc:create(callback)

			local seq=CCSequence:createWithTwoActions(spawn3,callFunc)
			guang1:runAction(spawn1)
			guang2:runAction(spawn2)
			circleSp:runAction(seq)

		end 

		local callFunc = CCCallFunc:create(callBack)

		local seq = CCSequence:createWithTwoActions(spawn,callFunc)

		circleSp:runAction(seq)   	
	end
end

function acXcjhZcjbDialog:showReward(seq,randomArr)

	local index = randomArr[seq]

	self:resetReward(randomArr,seq)

	if self.rewardNode and  self.rewardNode[index] and tolua.cast(self.rewardNode[index],"CCNode") then


		local removeSp = self.rewardNode[index]:getChildByTag(1016)
   		
   		local acArr = CCArray:create()

		local fade = CCFadeOut:create(0.2)
		local rotate = CCRotateTo:create(0.2, 20)

		local function callback( ... )
			if (#randomArr >1 and seq == #randomArr) or (#randomArr == 1) then
				-- self.circleSp:setVisible(true)
				self.rewardLayer:removeAllChildrenWithCleanup(true)
				self.actionFlag = 0
				self.touchSp:setPosition(9999,0)
				self.rewardNode = {}
				self:rewardShow()
				self:initRewardArea()
			end
		end

		local callFunc = CCCallFunc:create(callback)
		local delay = CCDelayTime:create(1)

		acArr:addObject(rotate)
   		acArr:addObject(fade)
   		acArr:addObject(delay)
   		acArr:addObject(callFunc)

		local seq=CCSequence:create(acArr)

		local textLabel = removeSp:getChildByTag(1017)
		if textLabel and tolua.cast(textLabel,"CCLabelTTF") then
			local fade1 = CCFadeOut:create(0.4)
			textLabel:runAction(fade1)
		end

		removeSp:runAction(seq)
	end
end


function acXcjhZcjbDialog:resetReward(randomArr,seq)

	if self.rewardTb and #self.rewardTb>1 then

		local icon,scale=G_getItemIcon(self.rewardTb[seq+1],80,false,self.layerNum+1,nil,nil,nil,nil,nil,nil,true)
	    if self.rewardNode[randomArr[seq]] then
	    	icon:setAnchorPoint(ccp(0.5,0.5))
	    	if acXcjhVoApi:getVersion()==1 then
	    		icon:setPosition(ccp(49.5,self.rewardNode[randomArr[seq]]:getContentSize().height-130+50))
	    	else
	    		icon:setPosition(ccp(49.5,self.rewardNode[randomArr[seq]]:getContentSize().height-130+80))
	    		icon:setScale(75/icon:getContentSize().width)
	    	end
	    	self.rewardNode[randomArr[seq]]:addChild(icon,1)
	    end
	end

end

function acXcjhZcjbDialog:rewardShow( ... )

    local function showEndHandler( ... )
        G_showRewardTip(self.rewardTb,true)
    end 
    local titleStr=getlocal("activity_wheelFortune4_reward")
    require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
    rewardShowSmallDialog:showNewReward(self.layerNum+1,true,true,self.rewardTb,showEndHandler,titleStr,nil,nil,nil,"smbd")
end

function acXcjhZcjbDialog:initTableView( ... )
	-- body
end

function acXcjhZcjbDialog:dispose( ... )
	-- body
end