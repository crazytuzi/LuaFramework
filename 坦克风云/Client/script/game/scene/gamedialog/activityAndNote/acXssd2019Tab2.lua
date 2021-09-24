acXssd2019Tab2={
}

function acXssd2019Tab2:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.layerNum=layerNum
    self.state = 0 

    return nc;
end

function acXssd2019Tab2:init( parent )
	self.bgLayer=CCLayer:create()
    self.parent=parent

    self.overDayEventListener = function()
        self:initUp()
        self:initMiddle()
        self:initDown()
    end
    if eventDispatcher:hasEventHandler("overADay", self.overDayEventListener) == false then
		eventDispatcher:addEventListener("overADay", self.overDayEventListener)
 	end

 	local titleBg1=LuaCCScale9Sprite:createWithSpriteFrameName("newRankTitleBg.png",CCRect(4,4,1,1),function () end)
 	titleBg1:setContentSize(CCSizeMake(G_VisibleSizeWidth,50))
 	titleBg1:setAnchorPoint(ccp(0,1))
 	titleBg1:setPosition(ccp(0,G_VisibleSizeHeight-160))
 	self.bgLayer:addChild(titleBg1)


 	local titleLb1 = GetTTFLabel(getlocal("activity_xssd2019_tab2"),25,true)
 	titleLb1:setAnchorPoint(ccp(0.5,0.5))
 	titleLb1:setPosition(ccp(G_VisibleSizeWidth/2,titleBg1:getContentSize().height/2))
 	titleLb1:setColor(G_ColorYellowPro)
 	titleBg1:addChild(titleLb1)

 	--I里的信息
    local function touchTip()
		local tabStr={getlocal("activity_xssd2019_tab2_info1"),getlocal("activity_xssd2019_tab2_info2"),getlocal("activity_xssd2019_tab2_info3"),getlocal("activity_xssd2019_tab2_info4"),getlocal("activity_xssd2019_tab2_info5",{acXssd2019VoApi:enterLevel(),acXssd2019VoApi:redEnvelopeLimit()}),getlocal("activity_xssd2019_tab2_info6",{acXssd2019VoApi:getProbability()})}
		require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
		tipShowSmallDialog:showStrInfo(self.layerNum+5,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr)
	end
	G_addMenuInfo(self.bgLayer,self.layerNum+1,ccp(G_VisibleSizeWidth - 30,G_VisibleSizeHeight-185),{},nil,0.7,28,touchTip,true)

	--活动时间
 	local acTimeLb=GetTTFLabel(acXssd2019VoApi:getTimeStr1(),21,true)
	acTimeLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-225))
	-- acTimeLb:setColor(G_ColorYellowPro)
	self.bgLayer:addChild(acTimeLb)
	self.acTimeLb=acTimeLb

	self:initUp()
    self:initMiddle()
 	self:initDown()

	return self.bgLayer
end

function acXssd2019Tab2:initUp( ... )
	if self.node1 then
		self.node1:removeFromParentAndCleanup(true)
		self.node1=nil
	end
	self.node1 = CCNode:create()
	self.bgLayer:addChild(self.node1,2)

	local topBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),function ()end)
    topBg:setAnchorPoint(ccp(0,1))
    topBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20,120))
    topBg:setAnchorPoint(ccp(0.5,1))
    topBg:setPosition(ccp(G_VisibleSizeWidth/2,self.acTimeLb:getPositionY()-20))
    self.node1:addChild(topBg)

    local secretCardNum = acXssd2019VoApi:secretCardNum(  )
    local externalCard
    local gap = 10
    for i=1,acXssd2019VoApi:secretNumCfg() do
    	if i<=secretCardNum then
    		externalCard = CCSprite:createWithSpriteFrameName("xssd2019Card_"..i..".png")
    	else
    		externalCard = CCSprite:createWithSpriteFrameName("xssd2019Card.png")
    	end
    	externalCard:setAnchorPoint(ccp(0,0))
		externalCard:setPosition(ccp(10+(externalCard:getContentSize().width+gap)*(i-1) , 0))
		topBg:addChild(externalCard)

		if i>secretCardNum then
			local lock = CCSprite:createWithSpriteFrameName("xssd2019_lock.png")
    		lock:setAnchorPoint(ccp(1,0))
    		lock:setPosition(ccp(externalCard:getContentSize().width-6,7))
			externalCard:addChild(lock)
		end
    end

    local nomalSecretCardTb = acXssd2019VoApi:nomalSecretCardTb(  )
    local nomalCard
    for i=1,4 do
    	if acXssd2019VoApi:haveCard( i ) then
    		nomalCard = CCSprite:createWithSpriteFrameName("xssd2019NomalCard_"..i..".png")
    	else
    		nomalCard = CCSprite:createWithSpriteFrameName("xssd2019_"..i..".png")
    	end
    	nomalCard:setAnchorPoint(ccp(0,0))
		nomalCard:setPosition(ccp(30+externalCard:getContentSize().width*3+gap+(nomalCard:getContentSize().width+gap)*(i-1) , 0))
		topBg:addChild(nomalCard)

		if not acXssd2019VoApi:haveCard( i ) then
			local lock = CCSprite:createWithSpriteFrameName("xssd2019_lock.png")
    		lock:setAnchorPoint(ccp(1,0))
    		lock:setPosition(ccp(externalCard:getContentSize().width-6,7))
			nomalCard:addChild(lock)
		end
    end
end

function acXssd2019Tab2:initMiddle( ... )
	if self.node2 then
		self.node2:removeFromParentAndCleanup(true)
		self.node2=nil
	end
	self.node2 = CCNode:create()
	self.bgLayer:addChild(self.node2,2)

	local downSpire = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
	downSpire:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,320))
	downSpire:setAnchorPoint(ccp(0.5,1))
	downSpire:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-370))
	self.node2:addChild(downSpire)

	local fontSize1 = 14
	local fontSize2 = 20
	if G_isAsia() then
		fontSize1 = 24
		fontSize2 = 24
	end

	local titleBg = G_createNewTitle({getlocal("activity_xssd2019_title6"), fontSize2, G_ColorYellowPro}, CCSizeMake(400, 0), nil, nil, "Helvetica-bold")
    titleBg:setPosition(ccp(downSpire:getContentSize().width/2,280))
    downSpire:addChild(titleBg,1)


    local secretExternalCfg = acXssd2019VoApi:secretExternalCfg(  )

    local showNum = acXssd2019VoApi:canNomalShow( )
    local secretRewardCfg = acXssd2019VoApi:secretRewardCfg( showNum )

    local cardNum = acXssd2019VoApi:cardNum( )
    local allSecretNumCfg = acXssd2019VoApi:allSecretNumCfg(  )
    local cellHeight = 140
    local rewardTb = {}
    
    if rewardTb then
    	for i=1,2 do
    		if i == 1 then
		    	rewardTb = secretExternalCfg
		    else
		    	rewardTb = secretRewardCfg
		    end
    		local tbTitleImage = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png", CCRect(105, 16, 1, 1), function()end)
		    tbTitleImage:setContentSize(CCSizeMake(downSpire:getContentSize().width-30, tbTitleImage:getContentSize().height))
		    tbTitleImage:setAnchorPoint(ccp(0,1))
		    tbTitleImage:setPosition(ccp(10,downSpire:getContentSize().height-titleBg:getContentSize().height-25 - cellHeight*(i-1)))
		    downSpire:addChild(tbTitleImage)

		    local titleLb = G_getRichTextLabel(getlocal("activity_xssd2019_secretTaskDes_"..i,{showNum,showNum,allSecretNumCfg}),{G_ColorWhite,G_ColorGreen,G_ColorWhite,G_ColorGreen,G_ColorWhite},fontSize1,tbTitleImage:getContentSize().width,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		    titleLb:setAnchorPoint(ccp(0,1))
		    local gap2 = 6
		    if G_isAsia() then
		    	gap2 = 0
		    end
		    titleLb:setPosition(ccp(15,tbTitleImage:getContentSize().height-gap2))
		    
		    tbTitleImage:addChild(titleLb)

		    for k,v in pairs(rewardTb) do
		    	local function showTip()
	                G_showNewPropInfo(self.layerNum+1,true,true,nil,v) 
	            end

	            local iconSp = G_getItemIcon(v,nil,false,100,showTip,nil,nil,nil,nil,nil,true)
	            local scale = 70/iconSp:getContentSize().width
	            iconSp:setAnchorPoint(ccp(0,1))
	            iconSp:setScale(scale)
	            local iconSize=iconSp:getContentSize().width*scale
	            iconSp:setPosition(ccp(50+(iconSize+40)*(k-1),tbTitleImage:getPositionY()-45))
	            iconSp:setTouchPriority(-(self.layerNum-1)*20-2)
	            downSpire:addChild(iconSp,6)

	            local numLb=GetTTFLabel("x"..FormatNumber(v.num),20/scale)
	            numLb:setAnchorPoint(ccp(1,0))
	            numLb:setPosition(ccp(iconSp:getContentSize().width-5,5))
	            iconSp:addChild(numLb,4)
	            local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
	            numBg:setAnchorPoint(ccp(1,0))
	            numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-2))
	            numBg:setPosition(ccp(iconSp:getContentSize().width-5,5))
	            numBg:setOpacity(150)
	            iconSp:addChild(numBg,3) 

	            local function lotteryHandler( ... )
	                if G_checkClickEnable()==false then
	                    do
	                        return
	                    end
	                else
	                    base.setWaitTime=G_getCurDeviceMillTime()
	                end
	                local function refreshFunc(reward)
	                    if not self.parent:isClosed() then
	                        self:initMiddle()
	                        self.parent:setIconTipVisibleByIdx(acXssd2019VoApi:tab2Reward(),2)
	                        self.parent:setIconTipVisibleByIdx(acXssd2019VoApi:tab3Reward(),3)
	                        if self.parent.acTab3 then
		                        self.parent.acTab3:initMiddle()
								self.parent.acTab3:initDown()
							end
							if self.parent.acTab1 then
		                        self.parent.acTab1:initMiddle()
							end

	                        -- 此处加弹板
	                        if reward then
	                            G_showRewardTip(reward, true)
	                        end
	                    end
	                end
	                local tid
	                if i == 1 then
	                	tid = 0
	                else
	                	tid = showNum
	                end
	                acXssd2019VoApi:socketXssd2019Decipher(tid,refreshFunc)
		        end

		        local state
		        if i == 1 then
		            state = acXssd2019VoApi:hasExternalReward()
		        else
		        	state = acXssd2019VoApi:hasNomalReward( )

		        	local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
			        lineSp:setContentSize(CCSizeMake(downSpire:getContentSize().width-25, 4))
			        lineSp:ignoreAnchorPointForPosition(false)
			        lineSp:setAnchorPoint(ccp(0.5, 0))
			        lineSp:setPosition(tbTitleImage:getContentSize().width / 2+5,tbTitleImage:getContentSize().height + 1)
			        tbTitleImage:addChild(lineSp)
		        end

		        if state == 3 then
			        local hasReward = GetTTFLabel(getlocal("activity_wanshengjiedazuozhan_complete"),fontSize1,true)
			        hasReward:setAnchorPoint(ccp(1,0.5))
			        hasReward:setColor(ccc3(168,168,168))
			        hasReward:setPosition(ccp(downSpire:getContentSize().width-60,50 + cellHeight*(2-i)))
			        downSpire:addChild(hasReward)
			    elseif state == 4 then
			    	local over = GetTTFLabel(getlocal("activity_heartOfIron_over"),fontSize1,true)
			        over:setAnchorPoint(ccp(1,0.5))
			        over:setColor(ccc3(168,168,168))
			        over:setPosition(ccp(downSpire:getContentSize().width-60,50 + cellHeight*(2-i)))
			        downSpire:addChild(over)
			    elseif state == 2 then
			    	local lotteryBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",lotteryHandler,nil,getlocal("daily_scene_get"),30,11)
			        lotteryBtn:setScale(0.7)
			        local lotteryMenu=CCMenu:createWithItem(lotteryBtn)
			        lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-2)
			        lotteryMenu:setAnchorPoint(ccp(0,1))
			        lotteryMenu:setPosition(ccp(downSpire:getContentSize().width-100,50 + cellHeight*(2-i)))
			        downSpire:addChild(lotteryMenu)
			    else
			        local notReward = GetTTFLabel(getlocal("noReached"),fontSize1,true)
			        notReward:setAnchorPoint(ccp(1,0.5))
			        notReward:setColor(ccc3(168,168,168))
			        notReward:setPosition(ccp(downSpire:getContentSize().width-60,50 + cellHeight*(2-i)))
			        downSpire:addChild(notReward)
			    end
	    	end
    	end
	    
	end
end

function acXssd2019Tab2:initDown( ... )

	local downSpire = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
	downSpire:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,G_VisibleSizeHeight-700))
	downSpire:setAnchorPoint(ccp(0.5,0))
	downSpire:setPosition(ccp(G_VisibleSizeWidth/2,0))
	self.bgLayer:addChild(downSpire)

	local fontSize1 = 20
	if G_isAsia() then
		fontSize1 = 24
	end

	local titleBg = G_createNewTitle({getlocal("activity_xssd2019_title7"), fontSize1, G_ColorYellowPro}, CCSizeMake(400, 0), nil, nil, "Helvetica-bold")
    titleBg:setPosition(ccp(downSpire:getContentSize().width/2,G_VisibleSizeHeight-750))
    downSpire:addChild(titleBg,1)


    self.cellNum = acXssd2019VoApi:secretTaskNum(  )+1
    self.cellHeight = 150
    self.tvWidth = downSpire:getContentSize().width-10
    self.tvHeight = downSpire:getContentSize().height - 70

    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    
    local pos = ccp(20,0)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(pos)
    self.bgLayer:addChild(self.tv)

end

function acXssd2019Tab2:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
	    return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        return CCSizeMake(self.tvWidth,self.cellHeight)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
		
        local secretTaskKey,secretTaskNum
        if (idx+1) ==  self.cellNum then

        else
        	secretTaskKey,secretTaskNum = acXssd2019VoApi:secretTaskCfg( idx+1 )
        end

        local bg = LuaCCScale9Sprite:createWithSpriteFrameName("littleBg_xssd2019.png",CCRect(5,5,1,1),function() end)
        bg:setContentSize(CCSizeMake(self.tvWidth,self.cellHeight-60))
        bg:setAnchorPoint(ccp(0,0))
        bg:setPosition(ccp(0,20))
        cell:addChild(bg)

        local nomalCard
        if (idx+1) ==  self.cellNum then
        	nomalCard = CCSprite:createWithSpriteFrameName("xssd2019Card.png")
        else
	        if acXssd2019VoApi:haveCard( idx+1 ) then
	    		nomalCard = CCSprite:createWithSpriteFrameName("xssd2019NomalCard_"..(idx+1)..".png")
	    	else
	    		nomalCard = CCSprite:createWithSpriteFrameName("xssd2019_"..(idx+1)..".png")
	    	end
	    end
        nomalCard:setAnchorPoint(ccp(0,0))
        nomalCard:setPosition(ccp(15,10))
        bg:addChild(nomalCard)

        local fontSize3,fontSize4 = 15,18
        if G_isAsia() then
        	fontSize3 = 24
        	fontSize4 = 22
        end

        local taskState
        if (idx+1) ==  self.cellNum then
        	taskState = acXssd2019VoApi:haveAllsecretCard()
        else
        	taskState =acXssd2019VoApi:alreadySolution( idx+1 )
        end

        local des
        if (idx+1) ==  self.cellNum then
        	-- des = GetTTFLabel(getlocal("activity_xssd2019_secretTaskDownDes_3"),fontSize3)
        	des =  GetTTFLabelWrap(getlocal("activity_xssd2019_secretTaskDownDes_3"),fontSize3,CCSizeMake(bg:getContentSize().width-nomalCard:getPositionX()-nomalCard:getContentSize().width-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        	des:setAnchorPoint(ccp(0,0.5))
	        des:setPosition(ccp(nomalCard:getPositionX()+nomalCard:getContentSize().width+20,bg:getContentSize().height/2+20))
	        bg:addChild(des)

	        local des1 = GetTTFLabel(getlocal("activity_xssd2019_secretTaskDownDes_4"),fontSize3)
        	des1:setAnchorPoint(ccp(0,0.5))
	        des1:setPosition(ccp(nomalCard:getPositionX()+nomalCard:getContentSize().width+20,bg:getContentSize().height/2-25))
	        bg:addChild(des1)

	        if acXssd2019VoApi:getSecretState( ) > 0 and (not taskState) then
	        	local todayLimit = GetTTFLabel(getlocal("todayIsLimitStr"),fontSize4)
		    	todayLimit:setAnchorPoint(ccp(1,0))
		    	todayLimit:setPosition(ccp(self.tvWidth-5,bg:getPositionY()+bg:getContentSize().height+2))
		    	todayLimit:setColor(G_ColorYellowPro)
		    	cell:addChild(todayLimit)
	        end
        else
        	des = GetTTFLabel(acXssd2019VoApi:nomalRewardDes( idx+1 ),fontSize3)
        	des:setAnchorPoint(ccp(0,0.5))
	        des:setPosition(ccp(nomalCard:getPositionX()+nomalCard:getContentSize().width+20,bg:getContentSize().height/2))
	        bg:addChild(des)
        end

        if taskState then
	        local alreadySolution = GetTTFLabel(getlocal("activity_xssd2019_situation1"),fontSize4)
	    	alreadySolution:setAnchorPoint(ccp(1,0))
	    	alreadySolution:setPosition(ccp(self.tvWidth-5,bg:getPositionY()+bg:getContentSize().height+2))
	    	alreadySolution:setColor(G_ColorYellowPro)
	    	cell:addChild(alreadySolution)
	    end
	    return cell
    end
end

function acXssd2019Tab2:tick( ... )
	if tolua.cast(self.acTimeLb,"CCLabelTTF") then
    	self.acTimeLb:setString(acXssd2019VoApi:getTimeStr1())
    end
end

function acXssd2019Tab2:refresh( )
	acXssd2019VoApi:setSecretStateToZero( )
	if self.tv then
		local recordPoint = self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
	end
end

function acXssd2019Tab2:dispose( )
	if self.overDayEventListener then
        eventDispatcher:removeEventListener("overADay", self.overDayEventListener)
    end
    self.overDayEventListener=nil
    base:removeFromNeedRefresh(self) --停止刷新
    -- self.layerNum = nil
    self.bgLayer = nil
    self.node1 = nil
    self.node2 = nil
    self.tv = nil

end