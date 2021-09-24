allianceWar2BuffDialog=commonDialog:new()

function allianceWar2BuffDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.cellHeight=150
	self.isEnd=false
	-- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("allianceWar/warMap.plist")
	return nc
end

function allianceWar2BuffDialog:resetTab()
	self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSizeHeight - 110))
	self.panelLineBg:setAnchorPoint(ccp(0.5,0))
	self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,20))
end

function allianceWar2BuffDialog:initTableView( ... )
	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 60,G_VisibleSizeHeight - 130),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setAnchorPoint(ccp(0,0))
	self.tv:setPosition(ccp(30,30))
	self.tv:setMaxDisToBottomOrTop(30)
	self.bgLayer:addChild(self.tv)

	local gems=playerVoApi:getGems()
	local fundsLb=GetTTFLabelWrap(getlocal("allianceWar2_leftFunds",{gems}),25,CCSizeMake(G_VisibleSizeWidth - 100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	fundsLb:setAnchorPoint(ccp(0,0.5))
	fundsLb:setPosition(50,60)
	fundsLb:setColor(G_ColorYellowPro)
	self.bgLayer:addChild(fundsLb)
	self.fundsLb=fundsLb
	
end

function allianceWar2BuffDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return SizeOfTable(allianceWar2Cfg.buffSkill)
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize=CCSizeMake(G_VisibleSizeWidth - 60,self.cellHeight)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local function onBuyBuff(tag,object)
			if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
			    if G_checkClickEnable()==false then
			        do
			            return
			        end
			    else
			        base.setWaitTime=G_getCurDeviceMillTime()
			    end
			    if(tag and tag>0)then
					-- self:showBuyBuffConfirm("b"..tag,tag)
					if allianceWar2VoApi:isHasSetFleet()==false then
						smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("allianceWar2_bufferTip"),nil,self.layerNum+1,nil)
						return
					end
					local function callback()
						self:refreshTv()
					end
					allianceWar2BidDialog:createWithBuffId(tag,self.layerNum+1,callback)
				end
			end
			
		end
		local cellBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),onBuyBuff)
		cellBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,self.cellHeight-5))
		cellBg:setAnchorPoint(ccp(0.5,0))
		cellBg:setPosition(ccp((G_VisibleSizeWidth - 60)/2,3))
		cell:addChild(cellBg)
		local buffID="b"..(idx + 1)
		local icon=CCSprite:createWithSpriteFrameName(allianceWar2Cfg.buffSkill[buffID]["icon"])
		icon:setPosition(ccp(60,cellBg:getContentSize().height/2))
		cellBg:addChild(icon)
		local cfg=allianceWar2Cfg.buffSkill[buffID]
		local nameLb=GetTTFLabel(getlocal("buff"..idx+1 .. "Name"),25)
		nameLb:setColor(G_ColorGreen)
		nameLb:setAnchorPoint(ccp(0,0.5))
		nameLb:setPosition(ccp(120,cellBg:getContentSize().height/4*3))
		cellBg:addChild(nameLb)
		-- local lv,effect
		-- if(serverWarLocalFightVoApi:getBuffList()[buffID])then
		-- 	lv=serverWarLocalFightVoApi:getBuffList()[buffID]
		-- 	effect=cfg.per*lv
		-- else
		-- 	lv=0
		-- 	effect=0
		-- end
		-- local effectStr
		-- if(buffID=="b1" or buffID=="b3" or buffID=="b4")then
		-- 	effectStr=G_keepNumber(effect*100,0).."%%"
		-- else
		-- 	effectStr=effect
		-- end
		-- 
		local buffLv=tonumber(allianceWar2VoApi:getBattlefieldUser()[buffID])
		local lvLb=GetTTFLabel(buffLv.."/"..cfg.maxLv,25)
		lvLb:setAnchorPoint(ccp(0,0.5))
		lvLb:setPosition(ccp(120 + nameLb:getContentSize().width + 10,cellBg:getContentSize().height/4*3))
		cellBg:addChild(lvLb)

		local descLb=GetTTFLabelWrap(getlocal(allianceWar2Cfg.buffSkill[buffID]["des"]),22,CCSizeMake(280,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		descLb:setAnchorPoint(ccp(0,0.5))
		descLb:setPosition(120,cellBg:getContentSize().height/4+6)
		cellBg:addChild(descLb)

		local btnDes=getlocal("upgradeBuild")
		if(buffLv>=cfg.maxLv)then
			btnDes=getlocal("alliance_lvmax")
		end
		local buyItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onBuyBuff,idx + 1,btnDes,25)
		buyItem:setScale(0.9)
		local buyBtn=CCMenu:createWithItem(buyItem)
		buyBtn:setTouchPriority(-(self.layerNum-1)*20-2)
		buyBtn:setPosition(490,cellBg:getContentSize().height/2)
		cellBg:addChild(buyBtn)
		if(buffLv>=cfg.maxLv)then
			buyItem:setEnabled(false)
		end
		local isEnd=allianceWar2VoApi:getIsEnd()
		if isEnd then
			buyItem:setEnabled(false)
		end
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	elseif fn=="ccScrollEnable" then
	end
end

function allianceWar2BuffDialog:tick()
	if self.isEnd then
		return
	end
	if allianceWar2VoApi:getIsEnd() then
		self.isEnd=allianceWar2VoApi:getIsEnd()
		self:refreshTv()
	end
end



function allianceWar2BuffDialog:refreshTv()
	if self.tv then
		local recordPoint=self.tv:getRecordPoint()
		self.tv:reloadData()
		self.tv:recoverToRecordPoint(recordPoint)
	end
	if self.fundsLb then
		local gems=playerVoApi:getGems()
		self.fundsLb:setString(getlocal("allianceWar2_leftFunds",{gems}))
	end
	
end

function allianceWar2BuffDialog:dispose()
	self.fundsLb=nil
	self.tv=nil
	-- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("allianceWar/warMap.plist")
	-- CCTextureCache:sharedTextureCache():removeTextureForKey("allianceWar/warMap.plist")
end

