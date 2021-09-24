acMjcsTab1={
}

function acMjcsTab1:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.layerNum=layerNum
    self.state = 0 

    return nc;
end

function acMjcsTab1:init( parent )
	self.bgLayer=CCLayer:create()
    self.parent=parent

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
	local webImage=LuaCCWebImage:createWithURL(G_downloadUrl("active/acMjcsBg.jpg"),onLoadIcon)
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

	local node = CCNode:create()
	node:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeWidth*(390/640)))
	node:setAnchorPoint(ccp(0.5,1))
	node:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160))
	self.bgLayer:addChild(node,2)

	--活动时间
 	local acTimeLb=GetTTFLabel(acMjcsVoApi:getTimeStr(),22,true)
	acTimeLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-185))
	acTimeLb:setColor(G_ColorYellowPro)
	self.bgLayer:addChild(acTimeLb)
	self.acTimeLb=acTimeLb

	--I里的信息
	local payRewardList,diamond,count = acMjcsVoApi:payRewardList()
	local loginDay = acMjcsVoApi:loginDay()
    local function touchTip()
		local tabStr={getlocal("activity_mjcs_tab1_info1"),getlocal("activity_mjcs_tab1_info2",{(acMjcsVoApi:loginReward(loginDay))[1].name}),getlocal("activity_mjcs_tab1_info3",{diamond,payRewardList[1].name,count}),getlocal("activity_mjcs_tab1_info4")}
		require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
		tipShowSmallDialog:showStrInfo(self.layerNum+5,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr)
	end
	G_addMenuInfo(self.bgLayer,self.layerNum+1,ccp(G_VisibleSizeWidth - 40,G_VisibleSizeHeight-185),{},nil,0.7,28,touchTip,true)

	--左边放大按钮
	local function left()
		if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
		acMjcsVoApi:showHeroInfo("h81",self.layerNum+1)
    end
	local amplifyBtn1=GetButtonItem("amplifyButton.png","amplifyButton_down.png","amplifyButton.png",left,nil,nil,nil)
    amplifyBtn1:setOpacity(255*0.8)
    local amplifyMenu1=CCMenu:createWithItem(amplifyBtn1)
    amplifyMenu1:setTouchPriority(-(self.layerNum-1)*20-5)
    amplifyMenu1:setPosition(ccp(G_VisibleSizeWidth/4-10,node:getContentSize().height/3*2+20))
    node:addChild(amplifyMenu1)

    --右边放大按钮
    local function right()
    	if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
		acMjcsVoApi:showHeroInfo("h82",self.layerNum+1)
    end
    local amplifyBtn2=GetButtonItem("amplifyButton.png","amplifyButton_down.png","amplifyButton.png",right,nil,nil,nil)
    amplifyBtn2:setScale(0.8)
    amplifyBtn2:setOpacity(255*0.8)
    local amplifyMenu2=CCMenu:createWithItem(amplifyBtn2)
    amplifyMenu2:setTouchPriority(-(self.layerNum-1)*20-5)
    amplifyMenu2:setPosition(ccp(G_VisibleSizeWidth/4*3-10,node:getContentSize().height/3*2+20))
    node:addChild(amplifyMenu2)

    self:initUp()

    --分割金属条
    local metalPartitionBar = CCSprite:createWithSpriteFrameName("metalPartitionBar.png")
    metalPartitionBar:setAnchorPoint(ccp(0.5,1))
    metalPartitionBar:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-550))
    self.bgLayer:addChild(metalPartitionBar)

    --滑动条
    self.cellNum = math.ceil(acMjcsVoApi:shopSellNum()/3)
	self.cellHeight = 251
	self.tvWidth = G_VisibleSizeWidth - 60
	self.tvHeight = metalPartitionBar:getPositionY() - metalPartitionBar:getContentSize().height -30
	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	local pos = ccp(30,20)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(pos)
    self.bgLayer:addChild(self.tv)

    --以下代码处理上下遮挡层
    local function forbidClick()
    end
    local capInSet = CCRect(20, 20, 10, 10);
    self.topforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
    self.topforbidSp:setTouchPriority(-(self.layerNum-1)*20-4)
    self.topforbidSp:setAnchorPoint(ccp(0,0))
    local topY
    local topHeight
    if(self.tv~=nil)then
        local tvX,tvY=self.tv:getPosition()
        topY=tvY+self.tv:getViewSize().height
        topHeight=G_VisibleSizeHeight-topY
    else
        topHeight=0
        topY=0
    end
    self.topforbidSp:setContentSize(CCSize(G_VisibleSizeWidth,topHeight-80))
    self.topforbidSp:setPosition(0,topY)
    self.bgLayer:addChild(self.topforbidSp)

    self:resetForbidLayer()
    self.topforbidSp:setVisible(false)

	return self.bgLayer
end

function acMjcsTab1:resetForbidLayer()
   if(self.tv~=nil)then
     local tvX,tvY=self.tv:getPosition()
   else
     -- 如果没有self.tv 将遮罩移出屏幕外防止干扰
     if self.topforbidSp then
        self.topforbidSp:setPosition(ccp(9999,0))
     end
   end
end

function acMjcsTab1:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
	    return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        return CCSizeMake(self.tvWidth,self.cellHeight)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
		
		for i=1,3 do
			--奖励的单个列表
	        --前两个背景图不一样
	        if idx==0 and i<3 then
				tbBgName = "acMjcsRewardBg_yellow.png"
			else
				tbBgName = "acMjcsRewardBg_green.png"
			end
			local tbBg = CCSprite:createWithSpriteFrameName(tbBgName)
			--取余（列），确定每个元素位置
			local remainder = i%3
			local bgHeight = self.cellHeight-10
			if remainder==1 then
				tbBg:setAnchorPoint(ccp(0,1))
				tbBg:setPosition(ccp(0,self.cellHeight))
			elseif remainder==2 then
				tbBg:setAnchorPoint(ccp(0.5,1))
				tbBg:setPosition(ccp(self.tvWidth/2,self.cellHeight))
			else
				tbBg:setAnchorPoint(ccp(1,1))
				tbBg:setPosition(ccp(self.tvWidth,self.cellHeight))
			end
			cell:addChild(tbBg)

			local fontSize =19
		    if not G_isAsia() then
		    	fontSize=16
		    end
		    if  not G_isIOS() then
		    	fontSize=16
		    end

		    --购买限制
		    local thisNum = idx*3+i
		    local title
		    if acMjcsVoApi:shopIsFinish( thisNum ) then
		    	title=G_getRichTextLabel(acMjcsVoApi:limitedPurchaseQuantityDes(thisNum),{G_ColorWhite,G_ColorGreen,G_ColorWhite},fontSize,160,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
		    else
		    	title=G_getRichTextLabel(acMjcsVoApi:limitedPurchaseQuantityDes(thisNum),{G_ColorWhite,G_ColorRed,G_ColorWhite},fontSize,160,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
		    end
			title:setAnchorPoint(ccp(0.5,1))
			title:setPosition(ccp(tbBg:getContentSize().width/2,tbBg:getContentSize().height-10))
			tbBg:addChild(title)

			local shopSellList,commodityCost,commodityCount = acMjcsVoApi:shopSell(thisNum)
	    	local function showTip()
        		G_showNewPropInfo(self.layerNum+1,true,true,nil,shopSellList[1]) 
            end
			local iconSp = G_getItemIcon(shopSellList[1],nil,false,100,showTip,nil,nil,nil,nil,nil,true)
            iconSp:setAnchorPoint(ccp(0.5,1))
            local scale
            if idx==0 and i<3 then
				scale=0.5
			else
				scale=0.75
			end
			iconSp:setScale(scale)
            iconSp:setPosition(ccp(tbBg:getContentSize().width/2,180))
            iconSp:setTouchPriority(-(self.layerNum-1)*20-2)
            tbBg:addChild(iconSp)

            local numLb=GetTTFLabel("x"..FormatNumber(shopSellList[1].num),20/scale)
            numLb:setAnchorPoint(ccp(1,0))
            numLb:setPosition(ccp(iconSp:getContentSize().width-5,5))
            iconSp:addChild(numLb,4)
            local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
            numBg:setAnchorPoint(ccp(1,0))
            numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-2))
            numBg:setPosition(ccp(iconSp:getContentSize().width-5,5))
            numBg:setOpacity(150)
            iconSp:addChild(numBg,3)

            local costDes = GetTTFLabel(commodityCost,22,true)
            costDes:setAnchorPoint(ccp(0.5,1))
            costDes:setPosition(ccp(tbBg:getContentSize().width/2-10,95))
            tbBg:addChild(costDes)
            if playerVoApi:getGems() >= commodityCost then
		    	costDes:setColor(G_ColorWhite)
			else
				costDes:setColor(G_ColorRed)
			end

            local goldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
			goldIcon:setAnchorPoint(ccp(0,1))
			goldIcon:setPosition(ccp(costDes:getPositionX()+costDes:getContentSize().width/2+2,98))
			tbBg:addChild(goldIcon)

			local purchaseNum=acMjcsVoApi:purchaseQuantity( thisNum )

			local function secondConfirm(num )
				local shopNum = num
				local function secondTipFunc(sbFlag)
					local keyName = "active.mjcs"
	                local sValue=base.serverTime .. "_" .. sbFlag
	                G_changePopFlag(keyName,sValue)
	                
	            end

	            local function confirmHandler( num )
	            	if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
		                local function refreshFunc(reward)
		                    local recordPoint = self.tv:getRecordPoint()
		                    self.tv:reloadData()
		                    self.tv:recoverToRecordPoint(recordPoint)
		                    -- 此处加弹板
		                    if reward then
		                        G_showRewardTip(reward, true)
		                    end
		                end
		                -- 兑换逻辑
		                acMjcsVoApi:socketMjcsBuy(refreshFunc,thisNum,shopNum)
		                playerVoApi:setGems(playerVoApi:getGems()-commodityCost*shopNum)
            		end
	            end
	            local keyName = "active.mjcs"
	            if G_isPopBoard(keyName) then
                	G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{num*commodityCost}),true,confirmHandler,secondTipFunc)
					do return end
				else
					confirmHandler( num )
				end
			end

            local function showBuyDialog()
        		if playerVoApi:getGems() < commodityCost then
					GemsNotEnoughDialog(nil,nil,commodityCost-playerVoApi:getGems(),self.layerNum+1,commodityCost)
				else
        			local str = shopSellList[1].type..shopSellList[1].id
        			shopVoApi:showBatchBuyPropSmallDialog("p1",self.layerNum+1,secondConfirm,getlocal("activity_thfb_small_buy"),commodityCount-purchaseNum,commodityCost,nil,true,shopSellList[1])
        		end
            end
			local lotteryBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",showBuyDialog,nil,getlocal("activity_thfb_small_buy"),30,11)
		    lotteryBtn:setScale(0.6)
		    local lotteryMenu=CCMenu:createWithItem(lotteryBtn)
		    lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-2)
		    lotteryMenu:setAnchorPoint(ccp(0.5,1))
		    lotteryMenu:setPosition(ccp(tbBg:getContentSize().width/2,35))
		    tbBg:addChild(lotteryMenu)

		    lotteryBtn:setEnabled(acMjcsVoApi:shopIsFinish( thisNum ))

		end
     	return cell
    end
end

function acMjcsTab1:initUp( ... )
	if self.node then
		self.node:removeFromParentAndCleanup(true)
		self.node=nil
	end
	self.node = CCNode:create()
	self.node:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeWidth*(390/640)))
	self.node:setAnchorPoint(ccp(0.5,1))
	self.node:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160))
	self.bgLayer:addChild(self.node,2)

	local payRewardList,diamond,count = acMjcsVoApi:payRewardList()
	--左边每充值……
    local width = G_VisibleSizeWidth/3+50
    local fontSize =18
    if not G_isAsia() then
    	fontSize=16
    end

    local receiptsNum,surplusNum = acMjcsVoApi:payRewardNum()
    local str = getlocal("activity_mjcs_tab1_des1",{diamond,surplusNum})
	local messageLabel
	if acMjcsVoApi:ifCanReceive()==1 then
		messageLabel=G_getRichTextLabel(str,{G_ColorWhite,G_ColorRed,G_ColorWhite},fontSize,width,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	else
		messageLabel=G_getRichTextLabel(str,{G_ColorWhite,G_ColorGreen,G_ColorWhite},fontSize,width,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	end
	messageLabel:setAnchorPoint(ccp(0.5,1))
	messageLabel:setPosition(ccp(width/2,220))
	self.node:addChild(messageLabel)
	local scale=0.65
	
	local heroIcon1
    for i,v in ipairs(payRewardList) do
    	local function showTip1()
			G_showNewPropInfo(self.layerNum+1,true,true,nil,v) 
	    end
		heroIcon1= G_getItemIcon(v,nil,false,100,showTip1,nil,nil,nil,nil,nil,true)
		heroIcon1:setTouchPriority(-(self.layerNum-1)*20-5)
		heroIcon1:setIsSallow(false)
		local numLb1=GetTTFLabel("x"..FormatNumber(v.num),20/scale)
	    numLb1:setAnchorPoint(ccp(1,0))
	    numLb1:setPosition(ccp(heroIcon1:getContentSize().width-5,5))
	    heroIcon1:addChild(numLb1,4)
	    local numBg1=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
	    numBg1:setAnchorPoint(ccp(1,0))
	    numBg1:setContentSize(CCSizeMake(numLb1:getContentSize().width*numLb1:getScale()+5,numLb1:getContentSize().height*numLb1:getScale()-2))
	    numBg1:setPosition(ccp(heroIcon1:getContentSize().width-5,5))
	    numBg1:setOpacity(150)
	    heroIcon1:addChild(numBg1,3)
    end
     
    heroIcon1:setScale(scale)
    heroIcon1:setAnchorPoint(ccp(0.5,0))
    heroIcon1:setPosition(ccp(width/2,80))
    self.node:addChild(heroIcon1)

    local fontSizeRecharge = 20
    if not G_isAsia() then
    	fontSizeRecharge = 16
    end
	local haveRecharge = GetTTFLabel(getlocal("activity_mjcs_tab1_des2",{acMjcsVoApi:haveRecharge()}),fontSizeRecharge,false)
	haveRecharge:setAnchorPoint(ccp(0.5,1))
	haveRecharge:setPosition(ccp(width/2,76))
	haveRecharge:setColor(G_ColorYellowPro)
	self.node:addChild(haveRecharge)

	local function lotteryHandler1( ... )
        PlayEffect(audioCfg.mouseClick)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end

        local function refreshFunc(reward)
        	if not self.parent:isClosed() then
	            self:initUp()
	            self.parent:setIconTipVisibleByIdx(acMjcsVoApi:tab1Reward(),1)

	            -- 此处加弹板
	            if reward then
	                G_showRewardTip(reward, true)
	            end
	        end
        end
        -- 兑换逻辑
        local judge = acMjcsVoApi:ifCanReceive( )
        if judge==2 then
            local action="pay"
            local tid=1
            acMjcsVoApi:socketMjcsTask(action,refreshFunc,tid)
        elseif judge==0 then
        	G_showTipsDialog(getlocal("activity_mjcs_alert"))
        end
	end
	local btnFontSize = 36
	if not G_isAsia() then
		btnFontSize = 30
	end
	local lotteryBtn1=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",lotteryHandler1,nil,getlocal("daily_scene_get"),btnFontSize,11)
    lotteryBtn1:setScale(0.6)
    local lotteryMenu1=CCMenu:createWithItem(lotteryBtn1)
    lotteryMenu1:setTouchPriority(-(self.layerNum-1)*20-5)
    lotteryMenu1:setAnchorPoint(ccp(0.5,1))
    lotteryMenu1:setPosition(ccp(width/2,27))
    self.node:addChild(lotteryMenu1)

    local hasReward1 = GetTTFLabel(getlocal("getItOver"),fontSize)
    hasReward1:setAnchorPoint(ccp(0.5,1))
    hasReward1:setPosition(ccp(width/2,45))
    hasReward1:setColor(ccc3(168,168,168))
    self.node:addChild(hasReward1)

    local canReceiveNum = acMjcsVoApi:canReceiveNum()
    if acMjcsVoApi:ifCanReceive( )==0 then
    	hasReward1:setVisible(false)
    elseif acMjcsVoApi:ifCanReceive( )==2 then
        hasReward1:setVisible(false)
        G_addNumTip(lotteryBtn1,ccp(lotteryBtn1:getContentSize().width-2,lotteryBtn1:getContentSize().height-2),true,canReceiveNum,0.9)
    else 
        lotteryMenu1:setVisible(false)
    end
 	--右边登录奖励
 	local realloginDay=acMjcsVoApi:loginDay( )
 	local loginReward=acMjcsVoApi:loginReward(realloginDay)
 	if acMjcsVoApi:ifTomorrowLoginReward() then
	 	if acMjcsVoApi:ifLoginTodayReward() then
	 	else
	 		realloginDay=acMjcsVoApi:loginDay( )+1
	 		loginReward=acMjcsVoApi:loginReward(realloginDay)
	 	end
	end

 	local loginDay = GetTTFLabelWrap(getlocal("activity_mjcs_tab1_des3",{realloginDay}),fontSize,CCSizeMake(width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
 	loginDay:setAnchorPoint(ccp(0.5,1))
 	loginDay:setPosition(ccp(G_VisibleSizeWidth-width/2,messageLabel:getPositionY()))
 	self.node:addChild(loginDay)

 	local heroIcon2
 	for i,v in ipairs(loginReward) do
    	local function showTip2()
			G_showNewPropInfo(self.layerNum+1,true,true,nil,v) 
	    end
		heroIcon2= G_getItemIcon(v,nil,false,100,showTip2,nil,nil,nil,nil,nil,true)
		heroIcon2:setTouchPriority(-(self.layerNum-1)*20-5)
		heroIcon2:setScale(scale)
	    heroIcon2:setAnchorPoint(ccp(0.5,0))
	    heroIcon2:setPosition(ccp(G_VisibleSizeWidth-width/2,heroIcon1:getPositionY()))
	    self.node:addChild(heroIcon2)
		local numLb2=GetTTFLabel("x"..FormatNumber(v.num),20/scale)
	    numLb2:setAnchorPoint(ccp(1,0))
	    numLb2:setPosition(ccp(heroIcon2:getContentSize().width-5,5))
	    heroIcon2:addChild(numLb2,4)
	    local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
	    numBg:setAnchorPoint(ccp(1,0))
	    numBg:setContentSize(CCSizeMake(numLb2:getContentSize().width*numLb2:getScale()+5,numLb2:getContentSize().height*numLb2:getScale()-2))
	    numBg:setPosition(ccp(heroIcon2:getContentSize().width-5,5))
	    numBg:setOpacity(150)
	    heroIcon2:addChild(numBg,3)
    end

    local function lotteryHandler2( ... )
		PlayEffect(audioCfg.mouseClick)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end

        local function refreshFunc(reward)
        	if not self.parent:isClosed() then
	            self:initUp()
	            self.parent:setIconTipVisibleByIdx(acMjcsVoApi:tab1Reward(),1)
	            -- 此处加弹板
	            if reward then
	                G_showRewardTip(reward, true)
	            end
	        end
        end
        -- 兑换逻辑
        if acMjcsVoApi:ifLoginTodayReward( ) then
            local action="login"
            local tid=1
            acMjcsVoApi:socketMjcsTask(action,refreshFunc,tid)
        else
        	G_showTipsDialog(getlocal("activity_mjcs_alert"))
        end
	end
	local lotteryBtn2=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",lotteryHandler2,nil,getlocal("daily_scene_get"),btnFontSize,11)
    lotteryBtn2:setScale(0.6)
    lotteryMenu2=CCMenu:createWithItem(lotteryBtn2)
    lotteryMenu2:setTouchPriority(-(self.layerNum-1)*20-5)
    lotteryMenu2:setAnchorPoint(ccp(0.5,1))
    lotteryMenu2:setPosition(ccp(G_VisibleSizeWidth-width/2,lotteryMenu1:getPositionY()))
    self.node:addChild(lotteryMenu2)
    --已领完
    local hasReward2 = GetTTFLabel(getlocal("getItOver"),fontSize)
    hasReward2:setAnchorPoint(ccp(0.5,1))
    hasReward2:setPosition(ccp(G_VisibleSizeWidth-width/2,45))
    hasReward2:setColor(ccc3(168,168,168))
    self.node:addChild(hasReward2)
    --明日可领
    local tomorrowCan = GetTTFLabel(getlocal("activity_mjcs_tab1_des5"),fontSize)
    tomorrowCan:setAnchorPoint(ccp(0.5,1))
    tomorrowCan:setPosition(ccp(G_VisibleSizeWidth-width/2,45))
    tomorrowCan:setColor(ccc3(168,168,168))
    self.node:addChild(tomorrowCan)

    if acMjcsVoApi:ifLoginTodayReward() then
    	G_addNumTip(lotteryBtn2,ccp(lotteryBtn2:getContentSize().width-2,lotteryBtn2:getContentSize().height-2),true,1,0.9)
	 	hasReward2:setVisible(false)
	 	tomorrowCan:setVisible(false)
	else
    	if acMjcsVoApi:ifTomorrowLoginReward() then
	 		lotteryMenu2:setVisible(false)
	 		hasReward2:setVisible(false)
	 	else
	 		lotteryMenu2:setVisible(false)
			tomorrowCan:setVisible(false)
		end
	end
end

function acMjcsTab1:tick( ... )
	if tolua.cast(self.acTimeLb,"CCLabelTTF") then
    	self.acTimeLb:setString(acMjcsVoApi:getTimeStr())
    end
    if acMjcsVoApi:checkIsToday() then
    	acMjcsVoApi:loginDaySpan()
    	self:initUp()
    end
end

function acMjcsTab1:dispose( )
    self.layerNum = nil
    self.bgLayer = nil
    self.tv = nil
end