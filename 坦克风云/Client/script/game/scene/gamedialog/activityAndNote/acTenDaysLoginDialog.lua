acTenDaysLoginDialog=commonDialog:new()

function acTenDaysLoginDialog:new()
	local nc=commonDialog:new()
	setmetatable(nc,self)
	self.__index=self
	self.loginDay=1
	-- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
	return nc
end

--设置对话框里的tableView
function acTenDaysLoginDialog:initTableView()
	self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
	self.panelLineBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,G_VisibleSize.height-95))
	
	local loginDescLabel=GetTTFLabelWrap(getlocal("activity_tendayslogin_subTitle"),30,CCSizeMake(self.bgLayer:getContentSize().width-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	loginDescLabel:setAnchorPoint(ccp(0,0.5))
	loginDescLabel:setPosition(ccp(20,self.bgLayer:getContentSize().height-125))
	self.bgLayer:addChild(loginDescLabel)
	loginDescLabel:setColor(G_ColorYellowPro)
	self.loginDay=acTenDaysLoginVoApi:getLoginDay()
	
	local function callBack(...)
	   return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-30,self.bgLayer:getContentSize().height-180),nil)
	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(ccp(19,20))
	self.bgLayer:addChild(self.tv,1)
	self.tv:setMaxDisToBottomOrTop(140)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acTenDaysLoginDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return acTenDaysLoginVoApi:getNewGiftsNum()
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-30,150)
		return tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		
		local sprieBg=CCSprite:createWithSpriteFrameName("7daysBg.png")
		sprieBg:setAnchorPoint(ccp(0,0))
		sprieBg:setPosition(ccp(0,10))
		cell:addChild(sprieBg)
		local numLabel=GetTTFLabel(getlocal("signDayNum",{idx+1}),25)
		numLabel:setAnchorPoint(ccp(0.5,0.5))
		numLabel:setPosition(ccp(50,sprieBg:getContentSize().height-25))
		sprieBg:addChild(numLabel,1)
		numLabel:setColor(G_ColorGreen)
		
		local data = acTenDaysLoginVoApi:getNewGiftsVo(idx+1)
		local award=data.award
		
		local function showInfoHandler(hd,fn,idx)
			if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
				local item=award[idx]
				if item then
					propInfoDialog:create(sceneGame,item,self.layerNum+1)
				end
			end
		end
		for k,v in pairs(award) do
			local icon
			local pic=v.pic
			local iconScaleX=1
			local iconScaleY=1
			if v.type=="p" and v.equipId then
				local eType=string.sub(v.equipId,1,1)
				if eType=="a" then
					icon = accessoryVoApi:getAccessoryIcon(v.equipId,80,100,showInfoHandler)
				elseif eType=="f" then
					icon = accessoryVoApi:getFragmentIcon(v.equipId,80,100,showInfoHandler)
				else
					icon = LuaCCSprite:createWithSpriteFrameName(pic,showInfoHandler)
				end
			elseif pic then
				icon = LuaCCSprite:createWithSpriteFrameName(pic,showInfoHandler)
			end
			if icon:getContentSize().width>100 then
				iconScaleX=0.78*100/150
				iconScaleY=0.78*100/150
			else
				iconScaleX=0.78
				iconScaleY=0.78
			end
			icon:setScaleX(iconScaleX)
			icon:setScaleY(iconScaleY)
				--end
			icon:ignoreAnchorPointForPosition(false)
			icon:setAnchorPoint(ccp(0,0))
		  	icon:setPosition(ccp(10+(k-1)*85,12))
			icon:setIsSallow(false)
			icon:setTouchPriority(-(self.layerNum-1)*20-2)
			sprieBg:addChild(icon,1)
			icon:setTag(k)
		
			if tostring(v.name)~=getlocal("honor") then
				local numLabel=GetTTFLabel("x"..v.num,25)
				numLabel:setAnchorPoint(ccp(1,0))
				numLabel:setPosition(icon:getContentSize().width-10,0)
				icon:addChild(numLabel,1)
				numLabel:setScaleX(1/iconScaleX)
				numLabel:setScaleY(1/iconScaleY)
			end
		end
		
		local loginDay=acTenDaysLoginVoApi:getLoginDay()
		if data.num<=0 and loginDay>=(idx+1) then
			local function rewardHandler(tag,object)
				PlayEffect(audioCfg.mouseClick)
				if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
					local function newuserawardCallback(fn,data)
						if self==nil or self.tv==nil then
							do return end
						end
						local recordPoint = self.tv:getRecordPoint()
						self.tv:reloadData()
						self.tv:recoverToRecordPoint(recordPoint)
						local awardStr=acTenDaysLoginVoApi:getAwardStr(idx+1)
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),awardStr,28)
					end
					acTenDaysLoginVoApi:getReward(idx+1,newuserawardCallback)
				end
			end
			local menuItemAward=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",rewardHandler,idx+1,getlocal("newGiftsReward"),25)
			menuItemAward:setScaleX(0.8)
			menuItemAward:setScaleY(0.8)
			local menuAward=CCMenu:createWithItem(menuItemAward)
			menuAward:setAnchorPoint(ccp(0.5,0.5))
			menuAward:setPosition(ccp(self.bgLayer:getContentSize().width-120,sprieBg:getContentSize().height/2))
			menuAward:setTouchPriority(-(self.layerNum-1)*20-2)
			sprieBg:addChild(menuAward,1)
		
			local lightSp = CCSprite:createWithSpriteFrameName("7daysLight.png")
			lightSp:setPosition(getCenterPoint(sprieBg))
			sprieBg:addChild(lightSp)
		end
		
		if data.num<=0 and loginDay==idx then
			local nextLabel=GetTTFLabelWrap(getlocal("newGiftsNextReward"),25,CCSizeMake(125,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
			nextLabel:setPosition(ccp(self.bgLayer:getContentSize().width-121,sprieBg:getContentSize().height/2))
			sprieBg:addChild(nextLabel,1)
		end
		
		if data.num>0 then
			local rightIcon=CCSprite:createWithSpriteFrameName("7daysCheckmark.png")
			rightIcon:setAnchorPoint(ccp(0.5,0.5))
			rightIcon:setPosition(ccp(self.bgLayer:getContentSize().width-120,sprieBg:getContentSize().height/2))
			sprieBg:addChild(rightIcon,1)
		end
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	   
	end
		
end

function acTenDaysLoginDialog:tick()
	if self.loginDay~=acTenDaysLoginVoApi:getLoginDay() then
		self.loginDay=acTenDaysLoginVoApi:getLoginDay()
		local recordPoint = self.tv:getRecordPoint()
		self.tv:reloadData()
		self.tv:recoverToRecordPoint(recordPoint)
	end
end

--用户处理特殊需求,没有可以不写此方法
function acTenDaysLoginDialog:doUserHandler()

end

function acTenDaysLoginDialog:dispose()
	self.loginDay=nil
	-- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/accessoryImage.plist")
  	-- CCTextureCache:sharedTextureCache():removeTextureForKeyForce("public/accessoryImage.pvr.ccz")
end




