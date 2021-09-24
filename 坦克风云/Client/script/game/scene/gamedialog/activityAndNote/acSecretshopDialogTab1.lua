acSecretshopDialogTab1={}

function acSecretshopDialogTab1:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.cellHight=170
	return nc
end

function acSecretshopDialogTab1:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self:initLayer1()
	return self.bgLayer
end
function acSecretshopDialogTab1:initLayer1(  )
	local startH=G_VisibleSize.height-170
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
	upBg:setOpacity(0)
    self.bgLayer:addChild(upBg)
    self.upBg=upBg

    self:initUP()

    local downBgH=startH-upBgH-30

    local downBg=LuaCCScale9Sprite:createWithSpriteFrameName("greenBlackBg2.png",CCRect(10,10,12,12),touchUp)
	downBg:setContentSize(CCSizeMake(bgWidth,downBgH))
    downBg:ignoreAnchorPointForPosition(false)
    downBg:setAnchorPoint(ccp(0.5,0))
    downBg:setTouchPriority(-(self.layerNum-1)*20-1)
	downBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,10))
    self.bgLayer:addChild(downBg)
    self.downBg=downBg
    -- downBg:setOpacity(0)

    self:initDown()
	
end

function acSecretshopDialogTab1:initUP()
	-- CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
 --    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	local function onLoadIcon(fn,icon)
		if(self and self.upBg and tolua.cast(self.upBg,"LuaCCScale9Sprite")) then
			-- icon:setScale(0.98)
			icon:setPosition(getCenterPoint(self.upBg))
			self.upBg:addChild(icon,1)
		end
	end
	local webImage=LuaCCWebImage:createWithURL(G_downloadUrl("active/acSecretshop_bg.jpg"),onLoadIcon)
	-- CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
 --    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    local function touchTip()
        local tabStr={getlocal("activity_secretshop_tip11"),getlocal("activity_secretshop_tip12")}

        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr)
    end
	local pos=ccp(self.upBg:getContentSize().width-40,self.upBg:getContentSize().height-40)
	local tabStr={}
	G_addMenuInfo(self.upBg,self.layerNum,pos,tabStr,nil,nil,28,touchTip,true)

	local h = self.upBg:getContentSize().height-8
	local acLabel = GetTTFLabel(getlocal("activityCountdown"),24)
	acLabel:setAnchorPoint(ccp(0.5,1))
	acLabel:setPosition(ccp(self.upBg:getContentSize().width/2, h))
	self.upBg:addChild(acLabel,2)
	acLabel:setColor(G_ColorYellowPro)

	h = h-30
	local timeStr=acSecretshopVoApi:getTimer()
	local messageLabel=GetTTFLabel(timeStr,24)
	messageLabel:setAnchorPoint(ccp(0.5,1))
	messageLabel:setColor(G_ColorYellowPro)
	messageLabel:setPosition(ccp(self.upBg:getContentSize().width/2, h))
	self.upBg:addChild(messageLabel,2)
	self.timeLb=messageLabel

	h = self.upBg:getContentSize().height/2-25
	local strSize2 = 22
	local desLb=GetTTFLabelWrap(getlocal("activity_secretshop_des1"),strSize2,CCSizeMake(self.upBg:getContentSize().width-200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	desLb:setAnchorPoint(ccp(0,0.5))
	desLb:setPosition(100, h)
	self.upBg:addChild(desLb,2)
end

function acSecretshopDialogTab1:initDown()
	self.shopList=acSecretshopVoApi:getShopList() or {}
	self.shopNum=SizeOfTable(self.shopList)
	local function callback(...)
		return self:eventHandler(...)
	end
	local tvH=self.downBg:getContentSize().height-10
	local hd=LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.downBg:getContentSize().width,tvH),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(0,5)
	self.downBg:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(80)

	local function forbidClick()
	end
	local upforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),forbidClick)
	self.downBg:addChild(upforbidSp)
	upforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	upforbidSp:setAnchorPoint(ccp(0.5,0))
	upforbidSp:setPosition(G_VisibleSizeWidth/2,5+tvH)
	-- 下
	local downforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),forbidClick)
	self.downBg:addChild(downforbidSp)
	downforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
	downforbidSp:setAnchorPoint(ccp(0.5,1))
	downforbidSp:setPosition(G_VisibleSizeWidth/2,5)
	upforbidSp:setTouchPriority(-(self.layerNum-1)*20-3)
	downforbidSp:setTouchPriority(-(self.layerNum-1)*20-3)
	upforbidSp:setVisible(false)
	downforbidSp:setVisible(false)
end

function acSecretshopDialogTab1:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return self.shopNum
	elseif fn=="tableCellSizeForIndex" then
		return  CCSizeMake(610,self.cellHight)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local cellWidth=610
		local id="i" .. idx+1
		local valueTb=self.shopList[id]
		local rewardList=acSecretshopVoApi:getRefreshListById(id) or valueTb.r
		local limitNum=valueTb.limittime
		local isfresh=valueTb.isfresh
		local buyNum=acSecretshopVoApi:getBuyNum(id)


		local titleBgFileName="panelSubTitleBg.png"
		local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName(titleBgFileName,CCRect(105,16,1,1),function()end)
		titleBg:setContentSize(CCSizeMake(cellWidth-25,titleBg:getContentSize().height))
		titleBg:setAnchorPoint(ccp(0,1))
		titleBg:setPosition(3,self.cellHight-3)
		cell:addChild(titleBg)

		local titleStr=getlocal("packs_name_" .. 6-idx) .. "<rayimg>" .. " (" .. buyNum .. "/" ..  limitNum .. ")"
		local colorTb={G_ColorYellowPro,G_ColorWhite}
		if buyNum>=limitNum then
			colorTb={G_ColorYellowPro,G_ColorRed}
		end
		local titleLb,lbHeight=G_getRichTextLabel(titleStr,colorTb,24,titleBg:getContentSize().width-60,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		titleLb:setAnchorPoint(ccp(0,1))
		titleLb:setPosition(30,titleBg:getContentSize().height/2+lbHeight/2)
		titleBg:addChild(titleLb,1)

		local giftPosX=60
		local giftPosY=(self.cellHight-40)/2

		local rewardStartPosX=180

		local rewardTb=FormatItem(rewardList,nil,true)
		local reardSpTb={}
		for k,v in pairs(rewardTb) do
			local function showNewPropInfo()
	            G_showNewPropInfo(self.layerNum+1,true,true,nil,v)
	            return false
	        end
	        -- print("v",v.name,v.pic)
			local rewardSp=G_getItemIcon(v,100,true,self.layerNum + 1,showNewPropInfo,self.tv)
			rewardSp:setScale(80/rewardSp:getContentSize().width)
			cell:addChild(rewardSp)
			rewardSp:setPosition(rewardStartPosX+(k-1)*90,giftPosY)
			rewardSp:setTouchPriority(-(self.layerNum-1)*20-2)

			local numLb=GetTTFLabel("x"..FormatNumber(v.num),22)
			numLb:setAnchorPoint(ccp(1,0))
			numLb:setPosition(rewardSp:getContentSize().width - 10,10)
			rewardSp:addChild(numLb)
			numLb:setScale(1/rewardSp:getScale())
			reardSpTb[k]=rewardSp
		end

		if isfresh==1 then
			-- 光特效
			local guangSp1 = CCSprite:createWithSpriteFrameName("equipShine.png")
	        cell:addChild(guangSp1)
	        guangSp1:setPosition(giftPosX,giftPosY)
	        local rotateBy = CCRotateBy:create(5,360)
	        guangSp1:runAction(CCRepeatForever:create(rotateBy))

	        local guangSp2 = CCSprite:createWithSpriteFrameName("equipShine.png")
	        cell:addChild(guangSp2)
	        guangSp2:setPosition(giftPosX,giftPosY)
	        local reverseBy = rotateBy:reverse()
	        guangSp2:runAction(CCRepeatForever:create(reverseBy))
	    end

       local refIcon
		local function touchGift()
			if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
			    if G_checkClickEnable()==false then
			        do
			            return
			        end
			    else
			        base.setWaitTime=G_getCurDeviceMillTime()
			    end
			    if isfresh==1 then
			    	PlayEffect(audioCfg.mouseClick)
			   --  	if refIcon then
			   --  		local scaleBig = CCScaleTo:create(0.1,1.2)
						-- local scaleSmall = CCScaleTo:create(0.1,1)
						-- local seq = CCSequence:createWithTwoActions(scaleBig,scaleSmall)
						-- refIcon:runAction(seq)
			   --  	end
			    	if buyNum>=limitNum then
			    		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_secretshop_refresh_tip"),30)
			    		do return end
			    	end
			    	local refreshNum = acSecretshopVoApi:getRefreshNumById(id)
			    	local freetimes=acSecretshopVoApi:getRefreshTimes()
			    	local refreshCost
			    	if refreshNum<freetimes then
			    		refreshCost=0
			    	else
			    		refreshCost=acSecretshopVoApi:getRefreshCost()
			    	end


			    	local function pCallback()
			    		local gems=playerVoApi:getGems() or 0
			            if refreshCost>gems then
			                local function onSure()
			                    activityAndNoteDialog:closeAllDialog()
			                end
			                GemsNotEnoughDialog(nil,nil,refreshCost-gems,self.layerNum+1,refreshCost,onSure)
			                return
			            end
			    		local function refreshFunc()
			    			playerVoApi:setGems(playerVoApi:getGems() - refreshCost)
			    			local newRewardList=acSecretshopVoApi:getRefreshListById(id)
			    			local newRewardTb=FormatItem(newRewardList,nil,true)
			    			-- rewardTb
			    			for k,v in pairs(newRewardTb) do
			    				if v.key==rewardTb[k].key and v.type==rewardTb[k].type and v.num==rewardTb[k].num then
			    				else
			    					self:fireAc(reardSpTb[k],v,cell,k,reardSpTb)
			    				end
			    			end
			    			rewardList=newRewardTb
			    			rewardTb=newRewardTb
			    		end
			    		
			    		local function sureClick()
			                acSecretshopVoApi:socketGift(1,id,refreshFunc)
			            end
			            local function secondTipFunc(sbFlag)
			                local keyName=acSecretshopVoApi:getActiveName()
			                local sValue=base.serverTime .. "_" .. sbFlag
			                G_changePopFlag(keyName,sValue)
			            end
			            if refreshCost and refreshCost>0 then
			                local keyName=acSecretshopVoApi:getActiveName()
			                if G_isPopBoard(keyName) then
			                    self.secondDialog=G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{refreshCost}),true,sureClick,secondTipFunc)
			                else
			                    sureClick()
			                end
			            else
			                sureClick()
			            end
			    	end
			    	acSecretshopVoApi:showRefreshSmalldialog(self.layerNum+1,true,true,pCallback,getlocal("dialog_title_prompt"),getlocal("activity_secretshop_refresh_des",{getlocal("packs_name_" .. 6-idx)}),refreshCost,nil)
			    end
			    
			end
		end
		local giftBag=LuaCCSprite:createWithSpriteFrameName("packs" .. 6-idx .. ".png",touchGift)
		cell:addChild(giftBag)
		giftBag:setPosition(giftPosX+3,giftPosY)
		giftBag:setTouchPriority(-(self.layerNum-1)*20-2)

		if isfresh==1 then
			refIcon = CCSprite:createWithSpriteFrameName("refreshIcon.png")
			refIcon:setAnchorPoint(ccp(1,0))
			refIcon:setPosition(ccp(giftBag:getContentSize().width-3,3))
			giftBag:addChild(refIcon)
			refIcon:setScale(0.8)
			if buyNum<limitNum then
				local moveTime=0.3
				local scaleTo1=CCScaleTo:create(moveTime,1)
				local scaleTo2=CCScaleTo:create(moveTime,0.8)
				local scaleTo1=CCScaleTo:create(moveTime,1)
				local scaleTo2=CCScaleTo:create(moveTime,0.8)
				local delay=CCDelayTime:create(moveTime*2)
				local acArr=CCArray:create()
				acArr:addObject(scaleTo1)
				acArr:addObject(scaleTo2)
				acArr:addObject(scaleTo1)
				acArr:addObject(scaleTo2)
				acArr:addObject(delay)
				local seq=CCSequence:create(acArr)
				local repeatForever=CCRepeatForever:create(seq)
				refIcon:runAction(repeatForever)
			end
		end
		

		local costNum=valueTb.bn
		local disCostNum=valueTb.p
		local function touchBuyFunc()
			if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
			    if G_checkClickEnable()==false then
			        do
			            return
			        end
			    else
			        base.setWaitTime=G_getCurDeviceMillTime()
			    end
			    PlayEffect(audioCfg.mouseClick)
			    if buyNum>=limitNum then
		    		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_secretshop_buy_limit"),30)
		    		do return end
		    	end

		    	local gems=playerVoApi:getGems() or 0
	            if costNum>gems then
	                local function onSure()
	                    activityAndNoteDialog:closeAllDialog()
	                end
	                GemsNotEnoughDialog(nil,nil,costNum-gems,self.layerNum+1,costNum,onSure)
	                return
	            end

			    local function refreshFunc()
			    	playerVoApi:setGems(playerVoApi:getGems() - costNum)
			    	if idx==0 then
			    		local paramTab={}
						paramTab.functionStr=acSecretshopVoApi:getActiveName()
						paramTab.addStr="i_also_want"
						local message={key="activity_secretshop_chat_message",param={playerVoApi:getPlayerName(),getlocal("activity_secretshop_title"),getlocal("packs_name_" .. 6-idx)}}
						chatVoApi:sendSystemMessage(message,paramTab)
			    	end
			    	local rewardTb=acSecretshopVoApi:getRefreshListById(id) or valueTb.r
			    	local rewardItem = FormatItem(rewardTb,nil,true)
			    	for k,v in pairs(rewardItem) do
			    		G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
			    	end
			    	local function endCallback()
			    		G_showRewardTip(rewardItem,true,nil,true)
				    end
			        local titleStr=getlocal("activity_wheelFortune4_reward")
			        require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
			        rewardShowSmallDialog:showNewReward(self.layerNum+1,true,true,rewardItem,endCallback,titleStr)
			    	local recordPoint=self.tv:getRecordPoint()
					self.tv:reloadData()
					self.tv:recoverToRecordPoint(recordPoint)
			    end
		    	
		    	local function sureClick()
	                acSecretshopVoApi:socketGift(2,id,refreshFunc)
	            end
	            local function secondTipFunc(sbFlag)
	                local keyName=acSecretshopVoApi:getActiveName()
	                local sValue=base.serverTime .. "_" .. sbFlag
	                G_changePopFlag(keyName,sValue)
	            end
	            if costNum and costNum>0 then
	                local keyName=acSecretshopVoApi:getActiveName()
	                if G_isPopBoard(keyName) then
	                    self.secondDialog=G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{costNum}),true,sureClick,secondTipFunc)
	                else
	                    sureClick()
	                end
	            else
	                sureClick()
	            end
			end
		end
		local scale=140/207
		local menuPosY=giftPosY-20
		local buyMenuItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",touchBuyFunc,1,getlocal("buy"),24/scale)
		buyMenuItem:setScale(scale)
		local buyBtn = CCMenu:createWithItem(buyMenuItem)
		cell:addChild(buyBtn,1)
		buyBtn:setTouchPriority(-(self.layerNum-1)*20-2)
		buyBtn:setBSwallowsTouches(true)
		buyBtn:setPosition(cellWidth-80,menuPosY)
		-- setFontName

		
		local costLb1=GetTTFLabel(costNum,22/scale)
		buyMenuItem:addChild(costLb1)
		costLb1:setPositionY(menuPosY+50)
		local iconGold1=CCSprite:createWithSpriteFrameName("IconGold.png")
		iconGold1:setScale(1/scale*0.8)
		buyMenuItem:addChild(iconGold1)
		iconGold1:setPositionY(menuPosY+50)
		G_setchildPosX(buyMenuItem,costLb1,iconGold1)

		
		local costLb2=GetTTFLabel(disCostNum,22/scale)
		buyMenuItem:addChild(costLb2)
		costLb2:setPositionY(menuPosY+85)
		costLb2:setColor(G_ColorRed)
		local iconGold2=CCSprite:createWithSpriteFrameName("IconGold.png")
		iconGold2:setScale(1/scale*0.8)
		buyMenuItem:addChild(iconGold2)
		iconGold2:setPositionY(menuPosY+85)
		G_setchildPosX(buyMenuItem,costLb2,iconGold2)

		local lineWhite=CCSprite:createWithSpriteFrameName("white_line.png")
		lineWhite:setColor(G_ColorRed)
		lineWhite:setScaleX((costLb2:getContentSize().width + iconGold2:getContentSize().width + 10)/lineWhite:getContentSize().width)
		lineWhite:setPosition(buyMenuItem:getContentSize().width/2,menuPosY+85)
		buyMenuItem:addChild(lineWhite)

		return cell
	elseif fn=="ccTouchBegan" then
		return true
	elseif fn=="ccTouchMoved" then
	elseif fn=="ccTouchEnded"  then
	end
end

function acSecretshopDialogTab1:fireAc(parent,rewardItem,cell,index,reardSpTb)
	local bgFireSp1 = CCSprite:createWithSpriteFrameName("bgFire_1.png")
	bgFireSp1:setScale(1/parent:getScale()*0.75)
	bgFireSp1:setPosition(parent:getContentSize().width/2,parent:getContentSize().height/2-10)
	parent:addChild(bgFireSp1)
	-- bgFireSp1:setScale(0.98)

	local pzArr=CCArray:create()
	for kk=1,20 do
		local nameStr="bgFire_"..kk..".png"
		local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
		pzArr:addObject(frame)
	end
	local animation=CCAnimation:createWithSpriteFrames(pzArr)
	animation:setDelayPerUnit(0.05)
	local animate=CCAnimate:create(animation)
	bgFireSp1:runAction(animate)

	local function visibleCallback()
		local function showNewPropInfo()
		    G_showNewPropInfo(self.layerNum+1,true,true,nil,rewardItem)
		    return false
		end
		local rewardSp=G_getItemIcon(rewardItem,100,true,self.layerNum + 1,showNewPropInfo,self.tv)
		rewardSp:setScale(80/rewardSp:getContentSize().width)
		cell:addChild(rewardSp)
		rewardSp:setPosition(parent:getPosition())
		rewardSp:setTouchPriority(-(self.layerNum-1)*20-2)

		local numLb=GetTTFLabel("x"..FormatNumber(rewardItem.num),22)
		numLb:setAnchorPoint(ccp(1,0))
		numLb:setPosition(rewardSp:getContentSize().width - 10,10)
		rewardSp:addChild(numLb)
		numLb:setScale(1/rewardSp:getScale())
		reardSpTb[index]=rewardSp

		-- parent:setVisible(false)
	end
	local function animationVisCall()
		parent:removeFromParentAndCleanup(true)
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

function acSecretshopDialogTab1:tick()
	if self.timeLb then
    	self.timeLb:setString(acSecretshopVoApi:getTimer())
    end
end

function acSecretshopDialogTab1:refresh()
	if self.tv then
		local recordPoint=self.tv:getRecordPoint()
		self.tv:reloadData()
		self.tv:recoverToRecordPoint(recordPoint)
	end
end


function acSecretshopDialogTab1:fastTick()
	
end

function acSecretshopDialogTab1:updateAcTime()
end

function acSecretshopDialogTab1:dispose()
	self.upBg=nil
end



