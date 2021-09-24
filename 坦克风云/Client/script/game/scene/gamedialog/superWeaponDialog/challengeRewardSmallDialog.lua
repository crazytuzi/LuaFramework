challengeRewardSmallDialog=smallDialog:new()

function challengeRewardSmallDialog:new(swId,type)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.swId=swId
	nc.type=type
	nc.dialogWidth=550
	nc.dialogHeight=400
	return nc
end

function challengeRewardSmallDialog:init(layerNum)
	self.isTouch=nil
	self.layerNum=layerNum
	self:initBackground()
	self:initContent()
	sceneGame:addChild(self.dialogLayer,self.layerNum)
	return self.dialogLayer
end

function challengeRewardSmallDialog:initBackground()
	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),nilFunc)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(self.bgSize)
	self:show()
	self.bgLayer:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)
	local function close()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
	local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
	closeBtnItem:setPosition(0,0)
	closeBtnItem:setAnchorPoint(CCPointMake(0,0))
	self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	self.closeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	self.closeBtn:setPosition(ccp(self.dialogWidth-closeBtnItem:getContentSize().width,self.dialogHeight-closeBtnItem:getContentSize().height))
	dialogBg:addChild(self.closeBtn)
	
	-- local titleStr=getlocal("playerInfo")
	-- local titleLb=GetTTFLabel(titleStr,30)
	-- titleLb:setAnchorPoint(ccp(0.5,0.5))
	-- titleLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-titleLb:getContentSize().height-5))
	-- dialogBg:addChild(titleLb,1)
    
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
	local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.dialogLayer:addChild(touchDialogBg)
end

function challengeRewardSmallDialog:initContent()
	local posY=self.dialogHeight-70
	-- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
	local descStr=""
	if self.type==1 then
		descStr=getlocal("super_weapon_challenge_info_desc")
	elseif self.type==2 then
		descStr=getlocal("super_weapon_challenge_reward_desc",{self.swId})
	end
	local descLb=GetTTFLabelWrap(descStr,25,CCSizeMake(self.dialogWidth-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	descLb:setAnchorPoint(ccp(0,0.5))
	descLb:setPosition(ccp(50,posY))
	self.bgLayer:addChild(descLb,1)

	posY=posY-100
	if self.swId and superWeaponCfg and swChallengeCfg.list and swChallengeCfg.list[self.swId] and swChallengeCfg.list[self.swId].clientReward and swChallengeCfg.list[self.swId].clientReward.rand then
		local rewardCfg=swChallengeCfg.list[self.swId].clientReward.rand
		local rewardTb=FormatItem(rewardCfg)
		if rewardTb and SizeOfTable(rewardTb)>0 then
			local num=SizeOfTable(rewardTb)
			local wSpace=50
			local iconSize=100
			for k,v in pairs(rewardTb) do
				if v then
					local icon,iconScale=G_getItemIcon(v,iconSize,true,self.layerNum)
					local px
					if (num%2)==1 then
						px=self.dialogWidth/2-(iconSize+wSpace)*(math.floor(num/2))+(iconSize+wSpace)*(k-1)
					else
						px=self.dialogWidth/2-(iconSize+wSpace)/2-(iconSize+wSpace)*(math.floor(num/2)-1)+(iconSize+wSpace)*(k-1)
					end
					icon:setPosition(ccp(px,posY))
					self.bgLayer:addChild(icon,1)
					local numLb=GetTTFLabel("x"..v.num,25)
        			numLb:setAnchorPoint(ccp(1,0))
        			numLb:setPosition(ccp(icon:getContentSize().width-5,5))
        			icon:addChild(numLb,1)
        			numLb:setScale(1/iconScale)
        			local nameLb=GetTTFLabelWrap(v.name,25,CCSizeMake(iconSize+20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        			-- local nameLb=GetTTFLabelWrap("啊啊啊啊啊啊啊",25,CCSizeMake(iconSize+20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        			nameLb:setAnchorPoint(ccp(0.5,0.5))
        			nameLb:setPosition(ccp(px,posY-iconSize/2-30))
        			self.bgLayer:addChild(nameLb,1)
				end
			end
		end
	end
	
    local function sureHandler()
    	if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,getlocal("confirm"),25)
    local sureMenu=CCMenu:createWithItem(sureItem)
    sureMenu:setPosition(ccp(self.dialogWidth/2,70))
    sureMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(sureMenu,1)

end

function challengeRewardSmallDialog:dispose()

end