alienTechDialogSubTab32={}
function alienTechDialogSubTab32:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.fData=nil
	self.sendAllBtn=nil
	self.acceptAllBtn=nil
	return nc
end

function alienTechDialogSubTab32:init(layerNum,parent)
	self.layerNum=layerNum
	self.parent=parent
	self.bgLayer=CCLayer:create()
	if allianceVoApi:isHasAlliance()==true then
		self:refreshData()
	else
		self:initNoAlliance()
	end
	return self.bgLayer
end

function alienTechDialogSubTab32:refreshData()
	local function callback()
		if(self and self.bgLayer)then
			self:initTableView()
			self:refresh()
		end
	end
	alienTechVoApi:initFriend(callback)
end

function alienTechDialogSubTab32:initNoAlliance()
	local lb=GetTTFLabel(getlocal("backstage4005"),24)
	lb:setColor(G_ColorGray)
	lb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.bgLayer:addChild(lb)
end

function alienTechDialogSubTab32:initFData()
	self.fData=allianceMemberVoApi:getMemberTab()
	for k,v in pairs(self.fData) do
		if(tonumber(v.uid)==tonumber(playerVoApi:getUid()))then
			table.remove(self.fData,k)
			break
		end
	end
end

function alienTechDialogSubTab32:initTableView()
	self:initFData()
	base:addNeedRefresh(self)
	local function onRefresh(event,data)
		self:initFData()
		local recordPoint=self.tv:getRecordPoint()
		self.tv:reloadData()
		self.tv:recoverToRecordPoint(recordPoint)
	end
	self.refreshListener=onRefresh
	eventDispatcher:addEventListener("alien.gift.refresh",self.refreshListener)
	self.cellHeight =60
	self.tvWidth=G_VisibleSizeWidth - 40

	local titleName=GetTTFLabel(getlocal("RankScene_name"),24)
	titleName:setColor(G_ColorGreen)
	titleName:setPosition(ccp(self.tvWidth/8 + 20,G_VisibleSizeHeight - 230))
	self.bgLayer:addChild(titleName)
	local titleLv=GetTTFLabel(getlocal("RankScene_level"),24)
	titleLv:setColor(G_ColorGreen)
	titleLv:setPosition(ccp(self.tvWidth*3/8 + 20,G_VisibleSizeHeight - 230))
	self.bgLayer:addChild(titleLv)
	local titleOperate=GetTTFLabel(getlocal("alliance_list_scene_operator"),24)
	titleOperate:setColor(G_ColorGreen)
	titleOperate:setPosition(ccp(self.tvWidth*3/4 + 20,G_VisibleSizeHeight - 230))
	self.bgLayer:addChild(titleOperate)

	local function callback(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,G_VisibleSizeHeight - 410),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(ccp(20,150))
	self.bgLayer:addChild(self.tv,1)
	self.tv:setMaxDisToBottomOrTop(100)

	self.acceptNumLb=GetTTFLabel(getlocal("alien_tech_todayHasAccept",{SizeOfTable(alienTechVoApi:getGiftAccept()),alienTechCfg.rewardlimit}),24)
	self.acceptNumLb:setPosition(ccp(G_VisibleSizeWidth/2,125))
	self.bgLayer:addChild(self.acceptNumLb)

	local function onSendAll()
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

		self:sendAll()
	end
	self.sendAllBtn = GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",onSendAll,nil,getlocal("alien_tech_sendAll"),24/0.8,101)
	self.sendAllBtn:setScale(0.8)
	local btnLb = self.sendAllBtn:getChildByTag(101)
	if btnLb then
		btnLb = tolua.cast(btnLb,"CCLabelTTF")
		btnLb:setFontName("Helvetica-bold")
	end
	local sendAllMenu=CCMenu:createWithItem(self.sendAllBtn)
	sendAllMenu:setPosition(ccp(200,70))
	sendAllMenu:setTouchPriority((-(self.layerNum-1)*20-2))
	self.bgLayer:addChild(sendAllMenu)

    G_addNumTip(self.sendAllBtn,ccp(self.sendAllBtn:getContentSize().width+5,self.sendAllBtn:getContentSize().height-15))
    
	local function onAcceptAll()
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

		self:acceptAll()
	end
	self.acceptAllBtn = GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",onAcceptAll,nil,getlocal("alien_tech_acceptAll"),24/0.8,101)
	self.acceptAllBtn:setScale(0.8)
	local btnLb = self.acceptAllBtn:getChildByTag(101)
	if btnLb then
		btnLb = tolua.cast(btnLb,"CCLabelTTF")
		btnLb:setFontName("Helvetica-bold")
	end
	local acceptAllMenu=CCMenu:createWithItem(self.acceptAllBtn)
	acceptAllMenu:setPosition(ccp(400,70))
	acceptAllMenu:setTouchPriority((-(self.layerNum-1)*20-2))
	self.bgLayer:addChild(acceptAllMenu)

    G_addNumTip(self.acceptAllBtn,ccp(self.acceptAllBtn:getContentSize().width+5,self.acceptAllBtn:getContentSize().height-15))

	if self.sendAllBtn then
		local uidTb=alienTechVoApi:sendAllUidTb()
		local count=SizeOfTable(uidTb)
		if uidTb and count>0 then
			self.sendAllBtn:setEnabled(true)
			G_refreshNumTip(self.sendAllBtn,true,count)
		else
			self.sendAllBtn:setEnabled(false)
			G_refreshNumTip(self.sendAllBtn,false)
		end
	end
	if self.acceptAllBtn then
		local uidTb=alienTechVoApi:acceptAllUidTb()
		local count=0
		if uidTb then
			count=SizeOfTable(uidTb)
		end
		if alienTechVoApi:isAcceptNumMax()==false and count>0 then
			self.acceptAllBtn:setEnabled(true)
			G_refreshNumTip(self.acceptAllBtn,true,count)

		else
			self.acceptAllBtn:setEnabled(false)
			G_refreshNumTip(self.acceptAllBtn,false)

		end
	end

	local function showInfo()
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

		local tabStr={"\n",getlocal("alien_tech_giftInfo3"),"\n",getlocal("alien_tech_giftInfo2"),"\n",getlocal("alien_tech_giftInfo1"),"\n"}
		local tabColor={nil,G_ColorYellowPro,nil,G_ColorYellowPro,nil,G_ColorYellowPro,nil}
		local td=smallDialog:new()
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
		sceneGame:addChild(dialog,self.layerNum+1) 
	end
	local infoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",showInfo,11,nil,nil)
	infoItem:setScale(0.9)
	local infoBtn = CCMenu:createWithItem(infoItem)
	infoBtn:setPosition(ccp(550,70))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	self.bgLayer:addChild(infoBtn)
end

function alienTechDialogSubTab32:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return SizeOfTable(self.fData)
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(G_VisibleSizeWidth-30,self.cellHeight)
		return tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local lineSP = CCSprite:createWithSpriteFrameName("LineCross.png");
		lineSP:setAnchorPoint(ccp(0.5,0.5))
		lineSP:setScaleX(self.tvWidth/lineSP:getContentSize().width)
		lineSP:setScaleY(1.2)
		lineSP:setPosition(ccp(self.tvWidth/2,self.cellHeight))
		cell:addChild(lineSP,2)

		local friendData=self.fData[idx+1]

		local nameLb = GetTTFLabel(friendData.name,24)
		nameLb:setPosition(self.tvWidth/8,self.cellHeight/2)
		cell:addChild(nameLb)

		local lvLb = GetTTFLabel(friendData.level,24)
		lvLb:setPosition(self.tvWidth*3/8,self.cellHeight/2)
		cell:addChild(lvLb)

		local posX1=369
		if(alienTechVoApi:checkHasSend(friendData.uid)==true)then
			local sendLb=GetTTFLabel(getlocal("alien_tech_alreadySend"),24)
			sendLb:setPosition(ccp(posX1,self.cellHeight/2))
			cell:addChild(sendLb)
		else
			local function onSend(tag,object)
				if self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
					if G_checkClickEnable()==false then
			            do
			                return
			            end
			        else
			            base.setWaitTime=G_getCurDeviceMillTime()
			        end
			        PlayEffect(audioCfg.mouseClick)

					self:send(tag)
				end
			end
			local sendItem = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onSend,idx+1,getlocal("alien_tech_send"),24/0.6,101)
			sendItem:setScale(0.6)
			local btnLb = sendItem:getChildByTag(101)
			if btnLb then
				btnLb = tolua.cast(btnLb,"CCLabelTTF")
				btnLb:setFontName("Helvetica-bold")
			end
			local sendBtn=CCMenu:createWithItem(sendItem)
			sendBtn:setPosition(ccp(posX1,self.cellHeight/2))
			sendBtn:setTouchPriority((-(self.layerNum-1)*20-2))
			cell:addChild(sendBtn)
		end


		local posX2=531
		if(alienTechVoApi:checkHasAccept(friendData.uid)==true)then
			local acceptLb=GetTTFLabel(getlocal("alien_tech_alreadyAccept"),24)
			acceptLb:setPosition(ccp(posX2,self.cellHeight/2))
			cell:addChild(acceptLb)
		else
			local function onAccept(tag,object)
				if self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
					if G_checkClickEnable()==false then
			            do
			                return
			            end
			        else
			            base.setWaitTime=G_getCurDeviceMillTime()
			        end
			        PlayEffect(audioCfg.mouseClick)

					self:accept(tag)
				end
			end
			local acceptItem = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onAccept,idx+1,getlocal("daily_scene_get"),24/0.6,101)
			if(alienTechVoApi:checkHasGift(friendData.uid)==false) or  (alienTechVoApi:isAcceptNumMax()==true)then
				acceptItem:setEnabled(false)
			end
			acceptItem:setScale(0.6)
			local btnLb = acceptItem:getChildByTag(101)
			if btnLb then
				btnLb = tolua.cast(btnLb,"CCLabelTTF")
				btnLb:setFontName("Helvetica-bold")
			end
			local acceptBtn=CCMenu:createWithItem(acceptItem)
			acceptBtn:setPosition(ccp(posX2,self.cellHeight/2))
			acceptBtn:setTouchPriority((-(self.layerNum-1)*20-2))
			cell:addChild(acceptBtn)
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

function alienTechDialogSubTab32:sendAll()
	local function callback()
		self:refresh()
	end
	alienTechVoApi:sendAllGift(callback)
end

function alienTechDialogSubTab32:send(index)
	local function callback()
		self:refresh()
	end
	local uid=self.fData[index].uid
	alienTechVoApi:sendGift(uid,callback)
end

function alienTechDialogSubTab32:acceptAll()
	local function callback(rewardStr)
		self:refresh()
		if rewardStr and rewardStr~="" then
			smallDialog:showTableViewSure("PanelHeaderPopup.png",CCSizeMake(600,600),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),rewardStr,true,self.layerNum+1,nil,true)
		end
	end
	alienTechVoApi:acceptAllGift(callback)
end

function alienTechDialogSubTab32:accept(index)
	local function callback()
		self:refresh()
	end
	local uid=self.fData[index].uid
	alienTechVoApi:acceptGift(uid,callback)
end

function alienTechDialogSubTab32:tick()
	if(alienTechVoApi:checkGiftExpired())then
		local function callback()
			self:refresh()
		end
		alienTechVoApi:initFriend(callback)
	end
end

function alienTechDialogSubTab32:refresh()
	self:initFData()
	local recordPoint=self.tv:getRecordPoint()
	self.tv:reloadData()
	self.tv:recoverToRecordPoint(recordPoint)
	if self.sendAllBtn then
		local uidTb=alienTechVoApi:sendAllUidTb()
		local count=SizeOfTable(uidTb)
		if uidTb and count>0 then
			self.sendAllBtn:setEnabled(true)
			G_refreshNumTip(self.sendAllBtn,true,count)
		else
			self.sendAllBtn:setEnabled(false)
			G_refreshNumTip(self.sendAllBtn,false)
		end
	end
	if self.acceptAllBtn then
		local uidTb=alienTechVoApi:acceptAllUidTb()
		local count=0
		if uidTb then
			count=SizeOfTable(uidTb)
		end
		if alienTechVoApi:isAcceptNumMax()==false and count>0 then
			self.acceptAllBtn:setEnabled(true)
			G_refreshNumTip(self.acceptAllBtn,true,count)
		else
			self.acceptAllBtn:setEnabled(false)
			G_refreshNumTip(self.acceptAllBtn,false)
		end
	end
	self.acceptNumLb:setString(getlocal("alien_tech_todayHasAccept",{SizeOfTable(alienTechVoApi:getGiftAccept()),alienTechCfg.rewardlimit}))
	if self.parent and self.parent.doUserHandler then
		self.parent:doUserHandler()
	end
end

function alienTechDialogSubTab32:dispose()
	self.fData={}
	self.sendAllBtn=nil
	self.acceptAllBtn=nil
	self.bgLayer:removeFromParentAndCleanup(true)
	eventDispatcher:removeEventListener("alien.gift.refresh",self.refreshListener)
	base:removeFromNeedRefresh(self)
end