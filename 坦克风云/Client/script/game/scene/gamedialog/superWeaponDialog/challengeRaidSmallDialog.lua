challengeRaidSmallDialog=smallDialog:new()

function challengeRaidSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.dialogWidth=550
	nc.dialogHeight=350
	return nc
end

function challengeRaidSmallDialog:init(layerNum,raidCallback)
	self.isTouch=nil
	self.layerNum=layerNum
	self.raidCallback=raidCallback
	self:initBackground()
	self:initContent()
	sceneGame:addChild(self.dialogLayer,self.layerNum)
	return self.dialogLayer
end

function challengeRaidSmallDialog:initBackground()
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

function challengeRaidSmallDialog:initContent()
	local posY=self.dialogHeight-90
	-- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
	local raidToLb=GetTTFLabelWrap(getlocal("super_weapon_challenge_raid_to"),25,CCSizeMake(140,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	-- local raidToLb=GetTTFLabelWrap("啊啊啊啊啊啊啊啊啊",25,CCSizeMake(140,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	raidToLb:setAnchorPoint(ccp(0,0.5))
	raidToLb:setPosition(ccp(30,posY))
	self.bgLayer:addChild(raidToLb,1)
    
    local function callBackTargetHandler(fn,eB,str)
		if tonumber(str)==nil then
			if self.needTimeLb then
				self.needTimeLb:setString(getlocal("super_weapon_challenge_need_time",{G_getCountdownTimeStr(0)}))
			end
			-- local cVo=superWeaponVoApi:getSWChallenge()
   --      	if cVo then
   --      		local maxPos=tonumber(cVo.maxClearPos)
   --      		do return maxPos end
   --      	end
		else
			local cVo=superWeaponVoApi:getSWChallenge()
        	if cVo then
        		local maxPos=tonumber(cVo.maxClearPos)
				if tonumber(str)>=1 and tonumber(str)<=maxPos then
				else
					if tonumber(str)<1 then
						eB:setText(1)
						str=1
						do return str end
					end
					if tonumber(str)>maxPos then
						eB:setText(maxPos)
						str=maxPos
						do return maxPos end
					end
				end
				local num=tonumber(str)
	    		local cdTime=0
	    		local cVo=superWeaponVoApi:getSWChallenge()
	    		local curPos=tonumber(cVo.curClearPos)
	    		if curPos and num>curPos then
	    			cdTime=(num-curPos)*swChallengeCfg.raidTime
	    		end
	    		self.needTimeLb:setString(getlocal("super_weapon_challenge_need_time",{G_getCountdownTimeStr(cdTime)}))
			end
		end
    end

	local cdTime=0
	local cVo=superWeaponVoApi:getSWChallenge()
	local maxPos=0
	if cVo then
		local curPos=tonumber(cVo.curClearPos)
		maxPos=tonumber(cVo.maxClearPos)
		if curPos and maxPos>curPos then
			cdTime=(maxPos-curPos)*swChallengeCfg.raidTime
		end		
	end
    local function tthandler()
    end
    local editTargetBox=LuaCCScale9Sprite:createWithSpriteFrameName("mail_input_bg.png",CCRect(10,10,5,5),tthandler)
    editTargetBox:setContentSize(CCSizeMake(200,50))
    editTargetBox:setIsSallow(false)
    editTargetBox:setTouchPriority(-(self.layerNum-1)*20-4)
    editTargetBox:setPosition(ccp(180+editTargetBox:getContentSize().width/2,posY))
    self.targetBoxLabel=GetTTFLabel(maxPos,25)
    self.targetBoxLabel:setAnchorPoint(ccp(0,0.5))
    self.targetBoxLabel:setPosition(ccp(10,editTargetBox:getContentSize().height/2))
    local customEditBox=customEditBox:new()
    local inputMode
    if G_isIOS()==true then
    	inputMode=CCEditBox.kEditBoxInputModePhoneNumber
    end
    local length=10
    customEditBox:init(editTargetBox,self.targetBoxLabel,"mail_input_bg.png",nil,-(self.layerNum-1)*20-4,length,callBackTargetHandler,nil,inputMode)
    self.bgLayer:addChild(editTargetBox,2)

	posY=posY-90
	self.needTimeLb=GetTTFLabelWrap(getlocal("super_weapon_challenge_need_time",{G_getCountdownTimeStr(cdTime)}),25,CCSizeMake(self.dialogWidth-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	-- self.needTimeLb=GetTTFLabelWrap("啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊",25,CCSizeMake(self.dialogWidth-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	self.needTimeLb:setAnchorPoint(ccp(0,0.5))
	self.needTimeLb:setPosition(ccp(30,posY))
	self.bgLayer:addChild(self.needTimeLb,1)

    --取消
    local function cancleHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local cancleItem=GetButtonItem("BtnGraySmall.png","BtnGraySmall_Down.png","BtnGraySmall_Down.png",cancleHandler,2,getlocal("cancel"),25)
    local cancleMenu=CCMenu:createWithItem(cancleItem);
    cancleMenu:setPosition(ccp(self.dialogWidth-150,70))
    cancleMenu:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(cancleMenu)
    --确定
    local function sureHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        if self.targetBoxLabel then
	        local inputStr=self.targetBoxLabel:getString()
	        if inputStr then
	        	local num=tonumber(inputStr)
	        	if num==nil then
	        		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("super_weapon_challenge_raid_tip_4"),30)
	        		do return end
	        	end
	        	local cVo=superWeaponVoApi:getSWChallenge()
	        	if cVo then
	        		local curPos=tonumber(cVo.curClearPos)
	        		local maxPos=tonumber(cVo.maxClearPos)
	        		if num>maxPos then
	        			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("super_weapon_challenge_raid_tip_2",{maxPos}),30)
	        			do return end
	        		elseif num<=curPos then
	        			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("super_weapon_challenge_raid_tip_3",{curPos}),30)
	        			do return end
	        		else
	        			local function raidChallengeCallback(...)
	        				if self.raidCallback then
	        					self.raidCallback(...)
	        				end
	        				self:close()
	        			end
	        			superWeaponVoApi:raidChallenge(num,raidChallengeCallback)
	        		end
	        	end
	        end
	    end
    end
    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,getlocal("ok"),25)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(150,70))
    sureMenu:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(sureMenu)
end

function challengeRaidSmallDialog:tick()

end

function challengeRaidSmallDialog:dispose()

end