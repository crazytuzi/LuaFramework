acFyssDialog=commonDialog:new()

function acFyssDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.layerNum=layerNum

	self.layerTab1=nil
	self.layerTab2=nil
	self.tab1=nil
	self.tab2=nil

	spriteController:addPlist("public/blueFilcker.plist")
	spriteController:addPlist("public/greenFlicker.plist")
	spriteController:addPlist("public/purpleFlicker.plist")
	spriteController:addPlist("public/yellowFlicker.plist")

    return nc
end

function acFyssDialog:resetTab()
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local blueBg=CCSprite:create("public/superWeapon/weaponBg.jpg")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    blueBg:setScaleX((self.bgLayer:getContentSize().width-40)/blueBg:getContentSize().width)
    blueBg:setScaleY((G_VisibleSizeHeight-160)/blueBg:getContentSize().height)
    blueBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160-blueBg:getContentSize().height*blueBg:getScaleY()/2)
    self.bgLayer:addChild(blueBg)

	self.panelLineBg:setVisible(false)
	local topBorder=CCSprite:createWithSpriteFrameName("newTopBorder.png")
	topBorder:setScaleX(G_VisibleSizeWidth/topBorder:getContentSize().width)
	topBorder:setAnchorPoint(ccp(0,1))
	topBorder:setPosition(0,G_VisibleSizeHeight - 158)
	self.bgLayer:addChild(topBorder)
	local index=0
	for k,v in pairs(self.allTabs) do
		 local  tabBtnItem=v
		 if index==0 then
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
		else
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
		 end
		 if index==self.selectedTabIndex then
			 tabBtnItem:setEnabled(false)
		 end
		 index=index+1
	end
	self.selectedTabIndex=0
end

function acFyssDialog:initTableView()
	-- 烟花
    local fireH=self.bgLayer:getContentSize().height-280
    local fireW=150
    for i=1,2 do
        local fireSp=CCSprite:createWithSpriteFrameName("openyear_fire.png")
        self.bgLayer:addChild(fireSp)
        local widht=fireW
        if i==2 then
            widht=G_VisibleSizeWidth-fireW
        else
            fireSp:setFlipX(true)
        end
        fireSp:setPosition(widht,fireH)
    end

	local fontSize = 21
    if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
        fontSize = 24
    elseif G_getCurChoseLanguage() =="fr" then
    	fontSize = 19
    end
	--[[
	local acVo=acFyssVoApi:getAcVo()
	local timeStr = getlocal("activity_timeLabel")
	local rewardTimeStr = getlocal("recRewardTime")
	if G_isGlobalServer()==true then
		timeStr = getlocal("activityCountdown")
		rewardTimeStr = "领奖倒计时"
	end
	local timeLb1=GetTTFLabel(timeStr,fontSize)
	timeLb1:setColor(G_ColorGreen)
	timeLb1:setAnchorPoint(ccp(1,0.5))
	timeLb1:setPosition(G_VisibleSizeWidth/2-100,G_VisibleSizeHeight - 195)
	self.bgLayer:addChild(timeLb1)
	local timeLb=GetTTFLabel(activityVoApi:getActivityTimeStr(acVo.st, acVo.acEt),fontSize)
	timeLb:setAnchorPoint(ccp(0,0.5))
	timeLb:setPosition(ccp(timeLb1:getPositionX()+20,timeLb1:getPositionY()))
	self.bgLayer:addChild(timeLb)
	self.timeLb=timeLb
	local rTimeLb1=GetTTFLabel(rewardTimeStr,fontSize)
	rTimeLb1:setColor(G_ColorGreen)
	rTimeLb1:setAnchorPoint(ccp(1,0.5))
	rTimeLb1:setPosition(timeLb1:getPositionX(),timeLb1:getPositionY()-timeLb1:getContentSize().height-5)
	self.bgLayer:addChild(rTimeLb1)
	local rTimeLb=GetTTFLabel(activityVoApi:getActivityRewardTimeStr(acVo.acEt-86400,0,86400,true),fontSize)
	rTimeLb:setAnchorPoint(ccp(0,0.5))
	rTimeLb:setPosition(ccp(rTimeLb1:getPositionX()+20,rTimeLb1:getPositionY()))
	self.bgLayer:addChild(rTimeLb)
	self.rTimeLb=rTimeLb
	self:updateAcTime()
	--]]

	local descBg=LuaCCScale9Sprite:createWithSpriteFrameName("acFyss_ltterBg.png",CCRect(0,0,1,1),function()end)
	descBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,190))
	descBg:setAnchorPoint(ccp(0.5,1))
	descBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 170)
	self.bgLayer:addChild(descBg)

	local descStr1=acFyssVoApi:getTimeStr()
    local descStr2=acFyssVoApi:getRewardTimeStr()
	local lbRollView,timeLb,rewardLb=G_LabelRollView(CCSizeMake(G_VisibleSizeWidth-60,50),descStr1,fontSize,kCCTextAlignmentCenter,G_ColorGreen,nil,descStr2,G_ColorYellowPro,2,2,2,nil)
	lbRollView:setPosition(30,G_VisibleSizeHeight - 195 - 50)
	self.bgLayer:addChild(lbRollView)
	self.timeLb=timeLb
	self.rTimeLb=rewardLb

	local function showInfo()
		if G_checkClickEnable()==false then
			do return end
		else
		    base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		
		local tabStr
		if self.selectedTabIndex==0 then
			-- tabStr = {getlocal("activity_fyss_tab1Info",{acFyssVoApi:getMaxbonus(),acFyssVoApi:getGiveUpLevel()})}
			tabStr = {
				getlocal("activity_fyss_tab1Info1",{acFyssVoApi:getMaxbonus()}),
				getlocal("activity_fyss_tab1Info2"),
				getlocal("activity_fyss_tab1Info3"),
				getlocal("activity_fyss_tab1Info4",{acFyssVoApi:getGiveUpLevel()}),
				getlocal("activity_fyss_tab1Info5"),
				getlocal("activity_fyss_tab1Info6"),
			}
		else
			tabStr = {getlocal("activity_fyss_tab2Info",{acFyssVoApi:getMaxFreeLotteryNum()})}
		end
		local titleStr=getlocal("activity_baseLeveling_ruleTitle")
		require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
		tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,25)
	end
	local infoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",showInfo,11,nil,nil)
	infoItem:setScale(0.8)
	local infoBtn = CCMenu:createWithItem(infoItem)
	infoBtn:setPosition(ccp(G_VisibleSizeWidth - 50,G_VisibleSizeHeight - 210))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-5)
	self.bgLayer:addChild(infoBtn)

	local descSt = getlocal("activity_fyss_desc")
	if acFyssVoApi:getVersion()~=1 and acFyssVoApi:getVersion()~=3 then
		descSt = getlocal("activity_fyss_desc_2")
	end
	local acDescLb=GetTTFLabelWrap(descSt,fontSize,CCSizeMake(G_VisibleSizeWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	acDescLb:setAnchorPoint(ccp(0.5,1))
	-- acDescLb:setPosition(G_VisibleSizeWidth/2,rTimeLb1:getPositionY()-rTimeLb1:getContentSize().height/2-5)
	acDescLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 255)
	self.bgLayer:addChild(acDescLb)

	if acFyssVoApi:isToday()==false and acFyssVoApi:isRewardTime()==false then
        acFyssVoApi:setUseFreeLotterNum(0)
    end
    if acFyssVoApi:isFreeLottery() and acFyssVoApi:isRewardTime()==false then
        self:tabClick(1)
    else
        self:tabClick(0)
    end
end

function acFyssDialog:updateAcTime()
    -- local acVo=acFyssVoApi:getAcVo()
    -- if acVo then
    	if self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
    		self.timeLb:setString(acFyssVoApi:getTimeStr())
        end
        if self.rTimeLb and tolua.cast(self.rTimeLb,"CCLabelTTF") then
        	self.rTimeLb:setString(acFyssVoApi:getRewardTimeStr())
        end
    -- end
end

function acFyssDialog:tabClick(idx)
	for k,v in pairs(self.allTabs) do
		if v:getTag()==idx then
			v:setEnabled(false)
			self.selectedTabIndex=idx
		else
			v:setEnabled(true)
		end
	end
	self:switchTab(idx+1)
end

function acFyssDialog:switchTab(type)
	if type==nil then
		type=1
	end
	local function showTab( )
		if self["tab"..type]==nil then
	   		local tab
	   		if(type==1)then
	   			tab=acFyssTabOne:new()
	   		else
	   			tab=acFyssTabTwo:new()
	   		end
		   	self["tab"..type]=tab
		   	self["layerTab"..type]=tab:init(self.layerNum, type==2 and self.tab1 or nil)
		   	self.bgLayer:addChild(self["layerTab"..type])
	   	end
		for i=1,2 do
			if(i==type)then
				if(self["layerTab"..i]~=nil)then
					self["layerTab"..i]:setPosition(ccp(0,0))
					self["layerTab"..i]:setVisible(true)
					if self["tab"..i].clayer then
						self["tab"..i].clayer:setTouchEnabled(true)
					end
				end
			else
				if(self["layerTab"..i]~=nil)then
					self["layerTab"..i]:setPosition(ccp(999333,0))
					self["layerTab"..i]:setVisible(false)
					if self["tab"..i].clayer then
						self["tab"..i].clayer:setTouchEnabled(false)
					end
				end
			end
		end
	end 
	showTab( )
end

function acFyssDialog:doUserHandler()

end

function acFyssDialog:tick()
	local vo=acFyssVoApi:getAcVo()
	if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    else
    	self:updateAcTime()
		if self and self.tab1 and self.tab1.tick then
			self.tab1:tick()
		end
		if self and self.tab2 and self.tab2.tick then
			self.tab2:tick()
		end
	end
end

function acFyssDialog:dispose()
	if self.tab1 and self.tab1.dispose then
		self.tab1:dispose()
	end
	if self.tab2 and self.tab2.dispose then
		self.tab2:dispose()
	end
    self.layerTab1=nil
	self.layerTab2=nil
	self.tab1=nil
	self.tab2=nil

	spriteController:removePlist("public/blueFilcker.plist")
	spriteController:removeTexture("public/blueFilcker.png")
	spriteController:removePlist("public/greenFlicker.plist")
	spriteController:removeTexture("public/greenFlicker.png")
	spriteController:removePlist("public/purpleFlicker.plist")
	spriteController:removeTexture("public/purpleFlicker.png")
	spriteController:removePlist("public/yellowFlicker.plist")
	spriteController:removeTexture("public/yellowFlicker.png")
end