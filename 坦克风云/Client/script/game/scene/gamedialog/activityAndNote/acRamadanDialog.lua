acRamadanDialog=commonDialog:new()

function acRamadanDialog:new()
    local nc={
    	getLbTb={},
    	getBtnTb={},
        url=G_downloadUrl("active/".."acRamadanBg.jpg")
	}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function acRamadanDialog:initTableView()
    local bgPos=ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-90)
    local function onLoadIcon(fn,ramadanBg)
        if self and self.bgLayer then
            ramadanBg:setAnchorPoint(ccp(0.5,1))
            -- ramadanBg:setScaleX((G_VisibleSizeWidth-40)/ramadanBg:getContentSize().width)
            ramadanBg:setScaleY((G_VisibleSizeHeight-108)/ramadanBg:getContentSize().height)
            self.bgLayer:addChild(ramadanBg)
            ramadanBg:setPosition(bgPos)
        end
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local webImage=LuaCCWebImage:createWithURL(self.url,onLoadIcon)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

	self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
	self.panelLineBg:setContentSize(CCSizeMake(618,G_VisibleSize.height-102))
	local function nilFunc()
	end
	local panelKuangSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",CCRect(20,20,10,10),nilFunc)
   	panelKuangSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
   	panelKuangSp:setContentSize(CCSizeMake(618,G_VisibleSize.height-102))
   	self.bgLayer:addChild(panelKuangSp,2)

	local timeLb=GetTTFLabel(acRamadanVoApi:getTimeStr(),25)
	timeLb:setAnchorPoint(ccp(0.5,1))
	timeLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-128))
	timeLb:setColor(G_ColorYellowPro)
	self.bgLayer:addChild(timeLb,3)
	self.timeLb=timeLb
	self:updateAcTime()

  	local function infoHandler(tag,object)
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
        PlayEffect(audioCfg.mouseClick)
        local tabStr={}
		for i=1,3 do
			table.insert(tabStr,getlocal("activity_ramadan_rule_"..i))
		end
		local titleStr=getlocal("activity_baseLeveling_ruleTitle")
	    require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
	    tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,25)
    end

    local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",infoHandler)
    menuItemDesc:setAnchorPoint(ccp(1,1))
    menuItemDesc:setScale(0.8)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
    menuDesc:setPosition(ccp(G_VisibleSizeWidth-40,G_VisibleSizeHeight-110))
    self.bgLayer:addChild(menuDesc,3)

	self:initLayer()
end

function acRamadanDialog:initLayer()
	local bigWidth=G_VisibleSizeWidth-60
	local smallWidth=(G_VisibleSizeWidth-70)/2
	local kuangHeight=300
	local addH=0
	if G_isIphone5()==true then
		addH=30
	end
	local recharge1,recharge2=acRamadanVoApi:getRechargeCfg()
	local posCfg={ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-210),ccp(30+smallWidth/2,G_VisibleSizeHeight-520-addH),ccp(G_VisibleSizeWidth-smallWidth/2-30,G_VisibleSizeHeight-520-addH)}
	local sizeCfg={CCSizeMake(bigWidth,kuangHeight+addH),CCSizeMake(smallWidth,kuangHeight+addH),CCSizeMake(smallWidth,kuangHeight+addH)}
	local rechargeStrCfg={getlocal("activity_ramadan_recharge1",{recharge1,recharge2}),getlocal("activity_ramadan_recharge2",{recharge1}),getlocal("activity_ramadan_recharge2",{recharge2})}
	local rewards=acRamadanVoApi:getRewards() --各礼包的奖励数据
	local rdata=acRamadanVoApi:getRewardsState() --礼包领取的数据
	for i=1,3 do
		local size=sizeCfg[i] or CCSizeMake(0,0)
		local pos=posCfg[i]
		if G_isIphone5()==false and i==1 then
			size.height=size.height-20
			pos.y=pos.y-20
		elseif G_isIphone5()==true then
			pos.y=pos.y-60
		end
	    local capInSet=CCRect(20,20,10,10)
	   	local rewardBg=G_createItemKuang(size)
	   	rewardBg:setAnchorPoint(ccp(0.5,1))
		rewardBg:setPosition(pos)
		self.bgLayer:addChild(rewardBg,3)

		local function nilFunc()
		end
	 	local promptBg=CCSprite:createWithSpriteFrameName("groupSelf.png")
		local rechargeLb=GetTTFLabelWrap(rechargeStrCfg[i],25,CCSizeMake(size.width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		local textH=36
		if rechargeLb:getContentSize().height>textH then
			textH=rechargeLb:getContentSize().height
		end
		promptBg:setScaleX((size.width+100)/promptBg:getContentSize().width)
		promptBg:setScaleY((textH+20)/promptBg:getContentSize().height)
		promptBg:setAnchorPoint(ccp(0.5,1))
		promptBg:setPosition(size.width/2+20,size.height)
		rewardBg:addChild(promptBg)
		rechargeLb:setAnchorPoint(ccp(0.5,0.5))
		rechargeLb:setPosition(size.width/2,promptBg:getPositionY()-promptBg:getContentSize().height*promptBg:getScaleY()/2)
		rewardBg:addChild(rechargeLb)

		local reward=rewards[i]
		local getNum=rdata[i]
		if reward then
			local function showPropInfo()
                G_showNewPropInfo(self.layerNum+1,true,true,nil,reward)
            end
			local iconSize=100
			local icon=G_getItemIcon(reward,iconSize,false,self.layerNum+1,showPropInfo)
			if i==1 then
				local propIcon=tolua.cast(icon:getChildByTag(99),"CCSprite")
				if propIcon then
					propIcon:setScale(85/propIcon:getContentSize().width)
				end
			end
			icon:setTouchPriority(-(self.layerNum-1)*20-4)
			icon:setAnchorPoint(ccp(0.5,0.5))
			local posY=size.height/2+10
			if G_isIphone5()==false and i==1 then
				posY=posY+5
			end
			icon:setPosition(size.width/2,posY)
			rewardBg:addChild(icon)

			local getLbStr=getlocal("limitBuy2",{1})
			local getLb=GetTTFLabelWrap(getLbStr,25,CCSizeMake(size.width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			getLb:setAnchorPoint(ccp(0.5,1))
			local spaceY=0
			if G_isIphone5()==true then
				spaceY=10
			end
			getLb:setPosition(size.width/2,icon:getPositionY()-iconSize/2-5-spaceY)
			rewardBg:addChild(getLb)
			self.getLbTb[i]=getLb
		end

		local function getHandler()
			if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
	        PlayEffect(audioCfg.mouseClick)
	        local function rewardHandler(fn,data)
        		local ret,sData=base:checkServerData(data)
		        if ret==true then
		            if sData and sData.data and sData.data.ramadan then
		            	acRamadanVoApi:updateData(sData.data.ramadan)
		            	self:refreshRewardItem(i)
		            	if reward then
		            		if getNum and getNum>0 then
		            			reward.num=reward.num*getNum
	                        	G_addPlayerAward(reward.type,reward.key,reward.id,reward.num)
		            		end
		            	end
		            	local rewardlist={reward}
		            	local function showEndHandler()
		            		G_showRewardTip(rewardlist,true)
		            	end
		            	local titleStr=getlocal("activity_wheelFortune4_reward")
				        require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
				        rewardShowSmallDialog:showNewReward(self.layerNum+1,true,true,rewardlist,showEndHandler,titleStr)
		            end
		        end
	        end
	        socketHelper:getRamadanRewardRequest(i,rewardHandler)
		end
		local btnScale=0.8
		local btnText=""
		if getNum and getNum==0 then
			btnText=getlocal("activity_hadReward")
		else
			btnText=getlocal("daily_scene_get")
		end
        local getItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",getHandler,nil,btnText,25/btnScale,1001)
        getItem:setScale(btnScale)
        local getMenu=CCMenu:createWithItem(getItem)
        getMenu:setTouchPriority(-(self.layerNum-1)*20-4)
        getMenu:setAnchorPoint(ccp(0.5,0.5))
        getMenu:setPosition(ccp(rewardBg:getContentSize().width/2,40))
        rewardBg:addChild(getMenu)
        if getNum==nil or getNum<=0 then
        	getItem:setEnabled(false)
        end
        self.getBtnTb[i]=getItem
	end
	local function rechargeHandler()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
        PlayEffect(audioCfg.mouseClick)
        vipVoApi:showRechargeDialog(self.layerNum+1)
        self:close()
	end
    local rechargeItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",rechargeHandler,nil,getlocal("recharge"),28)
    local rechageMenu=CCMenu:createWithItem(rechargeItem)
    rechageMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    rechageMenu:setAnchorPoint(ccp(0.5,0.5))
    local menuPosY=80
    if G_isIphone5()==true then
    	menuPosY=110
    end
    rechageMenu:setPosition(ccp(G_VisibleSizeWidth/2,menuPosY))
    self.bgLayer:addChild(rechageMenu,3)

    local goldAddH=0
    if G_isIphone5()==true then
    	goldAddH=-40
    end
	local recharge=acRamadanVoApi:getRecharge()
	local rechargeStr=getlocal("activity_peijianhuzeng_aleadyCost")..recharge
	local goldLb=GetTTFLabelWrap(rechargeStr,25,CCSizeMake(G_VisibleSizeWidth-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	goldLb:setAnchorPoint(ccp(0,0.5))
	goldLb:setColor(G_ColorYellowPro)
	goldLb:setPosition(40,G_VisibleSizeHeight-210+goldAddH)
	self.bgLayer:addChild(goldLb,5)
	local goldLb2=GetTTFLabel(rechargeStr,25)
	local realW=goldLb2:getContentSize().width
	if realW>goldLb:getContentSize().width then
		realW=goldLb:getContentSize().width
	end
	local goldSp=CCSprite:createWithSpriteFrameName("IconGold.png")
	goldSp:setAnchorPoint(ccp(0,0.5))
	goldSp:setPosition(goldLb:getPositionX()+realW+10,goldLb:getPositionY())
	self.bgLayer:addChild(goldSp,5)
end

function acRamadanDialog:refreshRewardItem(idx)
	local getBtn=self.getBtnTb[idx]
	local getLb=self.getLbTb[idx]
	if getBtn and getLb then
		getBtn=tolua.cast(getBtn,"CCMenuItemSprite")
		getLb=tolua.cast(getLb,"CCLabelTTF")
		local rdata=acRamadanVoApi:getRewardsState() --礼包领取的数据	
		if getBtn and getLb then
			local r=rdata[idx]
			if r and r>0 then
				getBtn:setEnabled(true)
			else
				getBtn:setEnabled(false)
				if r and r==0 then
					local btnText=tolua.cast(getBtn:getChildByTag(1001),"CCLabelTTF")
					if btnText then
						btnText:setString(getlocal("activity_hadReward"))
					end
				end
			end
		end
	end
end

function acRamadanDialog:updateAcTime()
    local acVo=acRamadanVoApi:getAcVo()
    if acVo and self.timeLb then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acRamadanDialog:tick()
	local endFlag=acRamadanVoApi:isEnd()
	if endFlag==true then
		self:close()
		do return end
	end
    if self then
      self:updateAcTime()
    end
end

function acRamadanDialog:dispose()
	self.getLbTb={}
	self.getBtnTb={}
end