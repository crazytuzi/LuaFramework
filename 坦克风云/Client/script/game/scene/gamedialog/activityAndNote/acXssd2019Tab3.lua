acXssd2019Tab3={
}

function acXssd2019Tab3:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.layerNum=layerNum
    self.state = 0 
    self.rewardNode1 = {}
    self.rewardNode2 = {}
    self.rewardPos = {}
    self.randomArr1 = {}

    return nc;
end

function acXssd2019Tab3:init( parent )
	self.bgLayer=CCLayer:create()
    self.parent=parent

    self.overDayEventListener = function()
        self:initMiddle()
        self:initDown()
        if self.parent.acTab2 then
            self.parent.acTab2:initUp()
            self.parent.acTab2:initMiddle()
            if self.parent.acTab2.tv then
                local recordPoint = self.parent.acTab2.tv:getRecordPoint()
                self.parent.acTab2.tv:reloadData()
                self.parent.acTab2.tv:recoverToRecordPoint(recordPoint)
            end
        end
        if self.parent.acTab1 then
            self.parent.acTab1:initUp()
            self.parent.acTab1:initMiddle()
            if self.parent.acTab1.tv then
                local recordPoint = self.parent.acTab1.tv:getRecordPoint()
                self.parent.acTab1.tv:reloadData()
                self.parent.acTab1.tv:recoverToRecordPoint(recordPoint)
            end
        end
    end
    if eventDispatcher:hasEventHandler("overADay", self.overDayEventListener) == false then
		eventDispatcher:addEventListener("overADay", self.overDayEventListener)
 	end
    local layerBg = LuaCCScale9Sprite:createWithSpriteFrameName("xssd2019Tab3_bg.png",CCRect(3,3,1,1),function() end)
    layerBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-160))
    layerBg:setAnchorPoint(ccp(0,0))
    layerBg:setPosition(ccp(0,0))
    self.bgLayer:addChild(layerBg)

    --背景图
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	local function onLoadIcon(fn,icon)
		if self and self.bgLayer and tolua.cast(self.bgLayer,"CCLayer") then
			icon:setAnchorPoint(ccp(0.5,1))
			icon:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160))
			self.bgLayer:addChild(icon)
		end
	end
	local webImage=LuaCCWebImage:createWithURL(G_downloadUrl("active/xssd2019Tab2_Bg.jpg"),onLoadIcon)
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

	-- 活动时间
	local acTimeLb = GetTTFLabel(acXssd2019VoApi:getTimeStr3( ),21)
	acTimeLb:setAnchorPoint(ccp(0.5,1))
	acTimeLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160-10))
	self.bgLayer:addChild(acTimeLb)
	self.acTimeLb=acTimeLb

    local externalRewardTb2 = acXssd2019VoApi:externalRewardTb2()
    local item = externalRewardTb2[1]

 	--I里的信息
    local function touchTip()
	local tabStr={getlocal("activity_xssd2019_tab3_info1",{acXssd2019VoApi:lotteryLimitNum( )}),getlocal("activity_xssd2019_tab3_info2",{acXssd2019VoApi:specialLimit(),item.time}),getlocal("activity_xssd2019_tab3_info3")}
		require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
		tipShowSmallDialog:showStrInfo(self.layerNum+5,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr)
	end
	G_addMenuInfo(self.bgLayer,self.layerNum+1,ccp(G_VisibleSizeWidth - 30,G_VisibleSizeHeight-185),{},nil,0.7,28,touchTip,true)

	--文字
	local fontsize1 = 20
	if G_isAsia() then
		fontsize1 = 25
	end
	local titleLb1 = GetTTFLabel(getlocal("activity_xssd2019_title4"),fontsize1,true)
 	titleLb1:setAnchorPoint(ccp(0.5,0.5))
 	titleLb1:setPosition(ccp(G_VisibleSizeWidth/2,acTimeLb:getPositionY()-50))
 	titleLb1:setColor(G_ColorYellowPro)
 	self.bgLayer:addChild(titleLb1)

    self:initUp()
    self:initMiddle( )
 	self:initDown( )

    local function touchDialog()
        -- print("touchDialog~~~~now~~~~~~",self.isStop)
        if self.isStop then
            do return end
        end

        self:useInTouchShowReward()
    end
    self.tDialogHeight = 80
    self.touchDialog = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
    self.touchDialog:setTouchPriority(-(self.layerNum-1)*20-99)
    self.touchDialog:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-self.tDialogHeight))
    self.touchDialog:setOpacity(0)
    self.touchDialog:setIsSallow(true) -- 点击事件透下去
    self.touchDialog:setPosition(ccp(G_VisibleSizeWidth*1.5,(G_VisibleSizeHeight-self.tDialogHeight)*0.5))
    self.bgLayer:addChild(self.touchDialog,99)

	return self.bgLayer
end

function acXssd2019Tab3:initUp( ... )
    if self.node1 then
        self.node1:removeFromParentAndCleanup(true)
        self.node1=nil
    end
    self.node1 = CCNode:create()
    self.bgLayer:addChild(self.node1,2)

    local cellwidth = 125
    local externalRewardTb = acXssd2019VoApi:externalRewardTb( )
    local tableViewMoveNum = acXssd2019VoApi:tableViewMoveNum(   )
    -- print("tableViewMoveNum======",tableViewMoveNum)

    local rewardTvaSize = CCSizeMake(G_VisibleSizeWidth, 170)
    self.rewardTv = G_createTableView(rewardTvaSize, SizeOfTable(externalRewardTb)+1,CCSizeMake(cellwidth, rewardTvaSize.height), function(...)
        self:eventHandler(...)
    end, true)
    self.rewardTv:setTableViewTouchPriority(-(self.layerNum-1)*20-6)
    self.rewardTv:setPosition(0, self.acTimeLb:getPositionY()-50 - rewardTvaSize.height - 45)
    self.node1:addChild(self.rewardTv, 5)
    self:refreshTv(self.rewardTv,ccp(-cellwidth*tableViewMoveNum,0))
    -- print("self.tv:getRecordPoint()===",self.rewardTv:getRecordPoint().x,self.rewardTv:getRecordPoint().y)
end

function acXssd2019Tab3:refreshTv(tv,newPos)
    local tableView = tolua.cast(tv,"LuaCCTableView")
    if tableView then
        -- local recordPoint=tableView:getRecordPoint()
        tableView:reloadData()
        tableView:recoverToRecordPoint(newPos)
    end
end

function acXssd2019Tab3:eventHandler(cell, cellSize, idx, cellNum)
    local fontsize2 = 16
    local width = (G_VisibleSizeWidth)/5+10
    if G_isAsia() then
        fontsize2 = 20
    end

    local rewardTb = {}
    local item = {}

    if (idx+1) == cellNum then
        local externalRewardTb2 = acXssd2019VoApi:externalRewardTb2()
        item = externalRewardTb2[1]
        rewardTb = FormatItem(item.reward,nil,true)

    else
        local externalRewardTb = acXssd2019VoApi:externalRewardTb( )
        if externalRewardTb then 
            item = externalRewardTb[idx+1]
            if item then
                -- rewardTb = FormatItem(acXssd2019VoApi:externalReward(idx+1))
                rewardTb = FormatItem(item.reward,nil,true)
            end
        end
        
    end
 
    if rewardTb then
        for x,y in pairs(rewardTb) do
            local iconSize=80
            local function showTip()
                G_showNewPropInfo(self.layerNum+1,true,true,nil,y) 
            end

            local iconSp = G_getItemIcon(y,nil,false,100,showTip,nil,nil,nil,nil,nil,true)
            local scale = iconSize/iconSp:getContentSize().width
            iconSp:setAnchorPoint(ccp(0.5,1))
            iconSp:setScale(scale)
            iconSp:setPosition(ccp(cellSize.width / 2+10, cellSize.height))
            iconSp:setTouchPriority(-(self.layerNum-1)*20-2)
            cell:addChild(iconSp,6)

            local numLb=GetTTFLabel("x"..FormatNumber(y.num),20/scale)
            numLb:setAnchorPoint(ccp(1,0))
            numLb:setPosition(ccp(iconSp:getContentSize().width-5,5))
            iconSp:addChild(numLb,4)
            local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
            numBg:setAnchorPoint(ccp(1,0))
            numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-2))
            numBg:setPosition(ccp(iconSp:getContentSize().width-5,5))
            numBg:setOpacity(150)
            iconSp:addChild(numBg,3) 

            local alreadyNum = acXssd2019VoApi:lotterylreadyNum()
            local rewardDes
            if (idx+1) == cellNum then
                rewardDes = G_getRichTextLabel(getlocal("activity_xssd2019_lotteryDes4",{item.time}),{G_ColorWhite,G_ColorYellowPro,G_ColorWhite},fontsize2,width,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
            else
                if alreadyNum>=item.time then
                    rewardDes = G_getRichTextLabel(getlocal("activity_vipAction_had"),{G_ColorGreen},fontsize2,width,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
                else
                    rewardDes = G_getRichTextLabel(getlocal("activity_xssd2019_lotteryDes1",{item.time}),{G_ColorWhite,G_ColorYellowPro,G_ColorWhite},fontsize2,width,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
                end
            end
            -- local rewardDes = GetTTFLabelWrap(getlocal("activity_xssd2019_lotteryDes",{item.time}),fontsize2,CCSizeMake(width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
            rewardDes:setAnchorPoint(ccp(0.5,1))
            rewardDes:setPosition(ccp(iconSp:getContentSize().width/2,-10))
            iconSp:addChild(rewardDes)
        end
    end
end

function acXssd2019Tab3:initMiddle( ... )
    if self.node2 then
        self.node2:removeFromParentAndCleanup(true)
        self.node2=nil
    end
    self.node2 = CCNode:create()
    self.bgLayer:addChild(self.node2,2)

    local fontsizeMiddle = 20
    if G_isAsia() then
        fontsizeMiddle = 20
    end
    local alreadyNum = acXssd2019VoApi:lotterylreadyNum()
    local lotteryDes = GetTTFLabel(getlocal("activity_xssd2019_lotteryDes3",{alreadyNum}),fontsizeMiddle,true)
    lotteryDes:setAnchorPoint(ccp(0.5,1))
    lotteryDes:setColor(G_ColorGreen)
    -- lotteryDes:setPosition(ccp(G_VisibleSizeWidth-30,G_VisibleSizeHeight-400))
    -- lotteryDes:setPosition(ccp(20,self.acTimeLb:getPositionY()))
    lotteryDes:setPosition(ccp(G_VisibleSizeWidth/2,self.acTimeLb:getPositionY()-235))
    self.node2:addChild(lotteryDes,5)

	for i=1,3 do
        for j=1,3 do
            local scaleX = 1
            local scaleY = 1
            local gap = 8
            if G_getIphoneType() == G_iphone4  then
                scaleX = 0.7
                scaleY = 0.6
            end
            
            local grayBg = CCSprite:createWithSpriteFrameName("xssd2019Tab3_boxBg2.png")
            grayBg:setAnchorPoint(ccp(0.5,0.5))
            grayBg:setScaleX(scaleX)
            grayBg:setScaleY(scaleY)
            grayBg:setPosition(ccp(G_VisibleSizeWidth/6*((j-1)*2+1) , G_VisibleSizeHeight-530-(i-1)*(grayBg:getContentSize().height*scaleY+gap)-grayBg:getContentSize().height*scaleY/2))
            -- grayBg:setOpacity(0)
            self.node2:addChild(grayBg,2)

            local height = grayBg:getContentSize().height
            self.rewardNode1[(i-1)*3+j] = grayBg
            self.rewardPos[(i-1)*3+j] = ccp(grayBg:getPositionX() , grayBg:getPositionY())

            local boxClose = CCSprite:createWithSpriteFrameName("xssd2019Tab3_boxClose.png")
            boxClose:setAnchorPoint(ccp(0.5,0.5))
            boxClose:setPosition(ccp(grayBg:getPositionX() , grayBg:getPositionY()+20*scaleY))
            boxClose:setScaleX(scaleX)
            boxClose:setScaleY(scaleY)
            boxClose:setTag(1018)
            self.node2:addChild(boxClose,4)

            self.rewardNode2[(i-1)*3+j] = boxClose

        end
    end
end

function acXssd2019Tab3:refreshFunc( reward )
    self.touchDialog:setPosition(ccp(G_VisibleSizeWidth*0.5,(G_VisibleSizeHeight-self.tDialogHeight)*0.5))
    self.newReward = reward
    local randomArr = randomArr
    if not randomArr then
        randomArr = acXssd2019VoApi:getRandom(5)
    end
    local num = 1
    local handler
    handler =  function( v )
        if v then
            if num~=#randomArr then
                self:randomAction( self.rewardNode1[v], "xssd2019Tab3_boxBg1.png","xssd2019Tab3_boxBg2.png",function() handler(randomArr[num]) end)
            else
                self.isStop = true
                self:randomAction( self.rewardNode1[v], "xssd2019Tab3_boxBg1.png")
                self:randomAction( self.rewardNode2[v], "xssd2019Tab3_boxOpen.png")

                local function callback( ... )
                    -- body
                end
                acXssd2019VoApi:boxFlicker(self.rewardNode2[v],callback)
                acXssd2019VoApi:frameFlicker(self.rewardNode1[v],function() self:rewardShow(reward) end)
                -- acXssd2019VoApi:
            end
        end
        num = num + 1
    end
    handler(randomArr[num])
end

function acXssd2019Tab3:useInTouchShowReward( )
    if not self.isStop and self.newReward then
        for k,v in pairs(self.rewardNode1) do
            v:stopAllActions()
            v:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("xssd2019Tab3_boxBg2.png"))
        end
        self:rewardShow(self.newReward)
    end
end

function acXssd2019Tab3:randomAction( node ,str1,str2,callback)

    local function callback1(  )
        node:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(str1))
    end
    local function callback2(  )
        if str2 then
            node:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(str2))
        end
    end

    local delay=CCDelayTime:create(0.1)
    local callback1 = CCCallFunc:create(callback1)
    local callback2 = CCCallFunc:create(callback2)
    local acArr=CCArray:create()
    acArr:addObject(callback1)
    acArr:addObject(delay)
    if str2 then
        acArr:addObject(callback2)
        acArr:addObject(delay)
    end
    if callback then
        acArr:addObject(CCCallFunc:create(callback))
    end
    local seq=CCSequence:create(acArr)
    node:runAction(seq)
end

function acXssd2019Tab3:rewardShow( reward )
    self.touchDialog:setPosition(ccp(G_VisibleSizeWidth*1.5,(G_VisibleSizeHeight-self.tDialogHeight)*0.5))
    if not self.parent:isClosed() then
        self:initUp()
        self:initMiddle()
        self:initDown()
        self.parent:setIconTipVisibleByIdx(acXssd2019VoApi:tab1Reward(),1)
        self.parent:setIconTipVisibleByIdx(acXssd2019VoApi:tab2Reward(),2)
        self.parent:setIconTipVisibleByIdx(acXssd2019VoApi:tab3Reward(),3)
        if self.parent.acTab2 then
            self.parent.acTab2:initUp()
            self.parent.acTab2:initMiddle()
            if self.parent.acTab2.tv then
                local recordPoint = self.parent.acTab2.tv:getRecordPoint()
                self.parent.acTab2.tv:reloadData()
                self.parent.acTab2.tv:recoverToRecordPoint(recordPoint)
            end
        end
        if self.parent.acTab1 then
            self.parent.acTab1:initUp()
            self.parent.acTab1:initMiddle()
            if self.parent.acTab1.tv then
                local recordPoint = self.parent.acTab1.tv:getRecordPoint()
                self.parent.acTab1.tv:reloadData()
                self.parent.acTab1.tv:recoverToRecordPoint(recordPoint)
            end
        end
        -- 此处加弹板
        if reward then
            local function showEndHandler( ... )
                G_showRewardTip(reward,true)
                self.newReward = nil
            end 
            local titleStr=getlocal("activity_wheelFortune4_reward")
            require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
            rewardShowSmallDialog:showNewReward(self.layerNum+1,true,true,reward,showEndHandler,titleStr,nil,nil,nil,"xssd2019")
        end
    end
end

function acXssd2019Tab3:initDown( ... )
	if self.node3 then
		self.node3:removeFromParentAndCleanup(true)
		self.node3=nil
	end
	self.node3 = CCNode:create()
	self.bgLayer:addChild(self.node3,2)

	local stateLeft = acXssd2019VoApi:howToPayLeft(  )
	local stateRight = acXssd2019VoApi:howToPayRight(  )
	local lotterynum=acXssd2019VoApi:lotteryCount( )
	local goldLotteryNum = acXssd2019VoApi:goldLotteryNum()
	local goldLotteryNumCfg = acXssd2019VoApi:goldLotteryNumCfg()
	local lotteryCostTb = acXssd2019VoApi:lotteryCost()  --（前者为奖章数，后者为金币数）

	local function lotteryHandler1( ... )
        self.isStop = false
		PlayEffect(audioCfg.mouseClick)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
        	base.setWaitTime=G_getCurDeviceMillTime()
		end

        local num=1
        local pt=stateLeft
        -- 抽奖逻辑
        if stateLeft == 1 or stateLeft == 2 then
            acXssd2019VoApi:socketXssd2019Lottery(num,pt,function( reward ) self:refreshFunc( reward ) end)
        else
        	G_showTipsDialog(getlocal("noEnoughProperty",{getlocal("activity_xssd2019_coinName")}))
        end
	end

	local function lotteryHandler2( ... )
        self.isStop = false
		PlayEffect(audioCfg.mouseClick)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
        	base.setWaitTime=G_getCurDeviceMillTime()
		end

        local num=lotterynum
        local pt=stateRight
        -- 抽奖逻辑
        if stateRight == 1 or stateRight == 2 then
            acXssd2019VoApi:socketXssd2019Lottery(num,pt,function( reward ) self:refreshFunc( reward ) end)
        else
        	G_showTipsDialog(getlocal("noEnoughProperty",{getlocal("activity_xssd2019_coinName")}))
        end
	end

	local fontsize3 = 22
	if G_isAsia() then
		fontsize3 = 26
	end
	
	local lotteryBtn1=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",lotteryHandler1,nil,getlocal("activity_qxtw_buy",{1}),fontsize3,11)
    lotteryBtn1:setScale(0.7)
    lotteryMenu1=CCMenu:createWithItem(lotteryBtn1)
    lotteryMenu1:setTouchPriority(-(self.layerNum-1)*20-5)
    lotteryMenu1:setAnchorPoint(ccp(0,0))
    lotteryMenu1:setPosition(ccp(110,70))
    self.node3:addChild(lotteryMenu1)
    lotteryBtn1:setEnabled(not(stateLeft ==3 or stateLeft == 4 or stateLeft == 5))

	local lotteryBtn2=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",lotteryHandler2,nil,getlocal("activity_qxtw_buy",{lotterynum}),fontsize3,11)
    lotteryBtn2:setScale(0.7)
    lotteryMenu2=CCMenu:createWithItem(lotteryBtn2)
    lotteryMenu2:setTouchPriority(-(self.layerNum-1)*20-5)
    lotteryMenu2:setAnchorPoint(ccp(0,0))
    lotteryMenu2:setPosition(ccp(G_VisibleSizeWidth - 110,70))
    self.node3:addChild(lotteryMenu2)
    lotteryBtn2:setEnabled(not(stateRight ==3 or stateRight == 4 or stateRight == 5))

    if stateLeft ==1 or stateLeft == 3 or stateLeft==4 or stateLeft==5 then
        
    	local numLb1 = GetTTFLabel(lotteryCostTb[1],30,true)
    	numLb1:setAnchorPoint(ccp(0.5,0))
    	numLb1:setPosition(ccp(lotteryBtn1:getContentSize().width/2+5,lotteryBtn1:getPositionY()+lotteryBtn1:getContentSize().height+10))
    	lotteryBtn1:addChild(numLb1)

		local icon1 = CCSprite:createWithSpriteFrameName("xssd2019_rewardIcon.png")
		icon1:setScale(45/icon1:getContentSize().width)
		icon1:setAnchorPoint(ccp(1,0))
		icon1:setPosition(ccp(-10,0))
		numLb1:addChild(icon1)
	elseif stateLeft == 2 then
		local numLb1 = GetTTFLabel(lotteryCostTb[2],30,true)
    	numLb1:setAnchorPoint(ccp(0.5,0))
    	numLb1:setPosition(ccp(lotteryBtn1:getContentSize().width/2+5,lotteryBtn1:getPositionY()+lotteryBtn1:getContentSize().height+10))
    	lotteryBtn1:addChild(numLb1)

		local icon1 = CCSprite:createWithSpriteFrameName("IconGold.png")
		icon1:setScale(45/icon1:getContentSize().width)
		icon1:setAnchorPoint(ccp(1,0))
		icon1:setPosition(ccp(-10,0))
		numLb1:addChild(icon1)
	end

	if stateRight ==1 or stateRight == 3 or stateRight==4 or stateRight == 5 then
    	local numLb2 = GetTTFLabel(lotteryCostTb[1]*lotterynum,30,true)
    	numLb2:setAnchorPoint(ccp(0.5,0))
    	numLb2:setPosition(ccp(lotteryBtn2:getContentSize().width/2+5,lotteryBtn2:getPositionY()+lotteryBtn2:getContentSize().height+10))
    	lotteryBtn2:addChild(numLb2)

		local icon2 = CCSprite:createWithSpriteFrameName("xssd2019_rewardIcon.png")
		icon2:setScale(45/icon2:getContentSize().width)
		icon2:setAnchorPoint(ccp(1,0))
		icon2:setPosition(ccp(-10,0))
		numLb2:addChild(icon2)
	elseif stateRight == 2 then
		local numLb2 = GetTTFLabel(lotteryCostTb[2]*lotterynum,30,true)
    	numLb2:setAnchorPoint(ccp(0.5,0))
    	numLb2:setPosition(ccp(lotteryBtn2:getContentSize().width/2+5,lotteryBtn2:getPositionY()+lotteryBtn2:getContentSize().height+10))
    	lotteryBtn2:addChild(numLb2)

		local icon2 = CCSprite:createWithSpriteFrameName("IconGold.png")
		icon2:setScale(45/icon2:getContentSize().width)
		icon2:setAnchorPoint(ccp(1,0))
		icon2:setPosition(ccp(-10,0))
		numLb2:addChild(icon2)
	end

	local fontsize4 = 16
	if G_isAsia() then
		fontsize4 = 20
	end

	-- local lotteryDes2 = GetTTFLabel(getlocal("activity_xssd2019_lotteryDes2"),fontsize4)
    local lotteryDes2 = GetTTFLabelWrap(getlocal("activity_xssd2019_lotteryDes2"),fontsize4,CCSizeMake(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	lotteryDes2:setAnchorPoint(ccp(0.5,0))
	lotteryDes2:setColor(ccc3(255,221,189))
	lotteryDes2:setPosition(ccp(G_VisibleSizeWidth/2,80))
	self.node3:addChild(lotteryDes2)

    local lastNum = goldLotteryNumCfg-goldLotteryNum
    if lastNum <0 then
        lastNum = 0
    end
	local lotteryLimit = GetTTFLabel((lastNum),fontsize4)
	lotteryLimit:setColor(ccc3(255,221,189))
	lotteryLimit:setAnchorPoint(ccp(0.5,1))
	lotteryLimit:setPosition(ccp(lotteryDes2:getContentSize().width/2,-10))
	lotteryDes2:addChild(lotteryLimit)
    self.lotteryLimit = lotteryLimit

    local buyDes = GetTTFLabel(getlocal("znkh19_lottery_desc"),fontsize4)
    buyDes:setAnchorPoint(ccp(0.5,0))
    buyDes:setPosition(ccp(G_VisibleSizeWidth/2,10))
    self.node3:addChild(buyDes)


	local fontSize5 = 20
	if G_isAsia() then
		fontSize5 = 24
	end
	local fightRecordFontSize = 13
    if G_isAsia() then
        fightRecordFontSize = 20
    end

	local titleBg = G_createNewTitle({getlocal("activity_xssd2019_title5"), fontSize5, G_ColorYellowPro}, CCSizeMake(400, 0), nil, nil, "Helvetica-bold")
    titleBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-480))
    self.node3:addChild(titleBg,1)

    local metalNum = GetTTFLabel(getlocal("serverwar_reward_desc1",{acXssd2019VoApi:petalNum( )}),fightRecordFontSize)
    metalNum:setAnchorPoint(ccp(0.5,1))
    metalNum:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-490))
    self.node3:addChild(metalNum,1)

	--记录按钮
	local btnScale = 0.8
	local function fightRecord()
        acXssd2019VoApi:socketXssd2019GetLog( self.layerNum )
    end
    local fightRecordItem = GetButtonItem("bless_record.png", "bless_record.png", "bless_record.png", fightRecord, nil, nil, 24 / btnScale, 101)
    fightRecordItem:setScale(0.7)

    local fightRecordBtn = CCMenu:createWithItem(fightRecordItem)
    fightRecordBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    fightRecordBtn:setAnchorPoint(ccp(1, 0.5))
    fightRecordBtn:setPosition(ccp(50, G_VisibleSizeHeight-460))
    self.node3:addChild(fightRecordBtn, 5)

    local fightRecordTitle = GetTTFLabel(getlocal("serverwar_point_record"),fightRecordFontSize)
    fightRecordTitle:setAnchorPoint(ccp(0.5,0.5))
    fightRecordTitle:setPosition(ccp(fightRecordBtn:getPositionX(), fightRecordBtn:getPositionY()-fightRecordItem:getContentSize().height/2))
    self.node3:addChild(fightRecordTitle)

    --奖池按钮
    local btnScale = 0.8
	local function prizePool()
        PlayEffect(audioCfg.mouseClick)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        local titleStr = getlocal("prizePool")
        local nomalPoolTb = acXssd2019VoApi:nomalPoolTb(  )
		require "luascript/script/game/scene/gamedialog/activityAndNote/acChunjiepanshengSmallDialog"
        local sd=acChunjiepanshengSmallDialog:new()
        sd:init(true,true,self.layerNum+1,titleStr,nil,CCSizeMake(500,570),CCRect(130, 50, 1, 1),nomalPoolTb,nil,nil,nil,true,"xssd2019")
        do return end
    end
    local prizePoolItem = GetButtonItem("xssd2019Tab3_boxClose.png", "xssd2019Tab3_boxClose.png", "xssd2019Tab3_boxClose.png", prizePool, nil, nil, 24 / btnScale, 101)
    prizePoolItem:setScale(0.5)
    
    local prizePoolBtn = CCMenu:createWithItem(prizePoolItem)
    prizePoolBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    prizePoolBtn:setAnchorPoint(ccp(1, 0.5))
    prizePoolBtn:setPosition(ccp(G_VisibleSizeWidth-50, G_VisibleSizeHeight-456))
    self.node3:addChild(prizePoolBtn, 5)

    local prizePoolTitle = GetTTFLabel(getlocal("prizePool"),fightRecordFontSize)
    prizePoolTitle:setAnchorPoint(ccp(0.5,0.5))
    prizePoolTitle:setPosition(ccp(prizePoolBtn:getPositionX()-5, fightRecordTitle:getPositionY()))
    self.node3:addChild(prizePoolTitle)

end

function acXssd2019Tab3:tick( ... )
	if tolua.cast(self.acTimeLb,"CCLabelTTF") then
    	self.acTimeLb:setString(acXssd2019VoApi:getTimeStr3())
    end

    -- if acXssd2019VoApi:refreshFunc( tag ) then
 --    if acMjcsVoApi:checkIsToday() then
 --    	acMjcsVoApi:loginDaySpan()
 --    	self:initUp()
 --    end
end

function acXssd2019Tab3:refresh( )--跨天使用
    acXssd2019VoApi:setGoldLotteryNumToZero( )--清零
    local goldLotteryNum = acXssd2019VoApi:goldLotteryNum()
    local goldLotteryNumCfg = acXssd2019VoApi:goldLotteryNumCfg()
    local lastNum = goldLotteryNumCfg-goldLotteryNum
    if lastNum <0 then
        lastNum = 0
    end
    if self.lotteryLimit then
        self.lotteryLimit:setString(lastNum)
    end
end

function acXssd2019Tab3:dispose( )
	if self.overDayEventListener then
        eventDispatcher:removeEventListener("overADay", self.overDayEventListener)
    end
    self.overDayEventListener=nil
    self.lotteryLimit = nil
    -- base:removeFromNeedRefresh(self) --停止刷新
    -- self.layerNum = nil
    self.bgLayer = nil
    self.node1 = nil
    self.node2 = nil
    self.node3 = nil
    self.rewardTv = nil
end