acPeijianhuzengSelectFriendDialog = commonDialog:new()

function acPeijianhuzengSelectFriendDialog:new(layerNum,pid)
	local nc = {}
	setmetatable(nc, self)
	self.__index = self
	self.pid=pid
	self.cellHeight=72
	return nc
end	

function acPeijianhuzengSelectFriendDialog:resetTab()
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))   
end	

function acPeijianhuzengSelectFriendDialog:initTableView()
	self.friendTb = friendMailVoApi:getFriendTb()

	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-290),nil)
	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(ccp(30,100))
	self.bgLayer:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(120)

	self.noLb=GetTTFLabel(getlocal("noFriends"),32)
	self.noLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2))
	self.noLb:setColor(G_ColorGray)
	self.bgLayer:addChild(self.noLb,5)
	self.noLb:setVisible(false)
	if #self.friendTb==0 then
		self.noLb:setVisible(true)
	end

	if self.pid==3306 then
		local maxNumLb=GetTTFLabelWrap(getlocal("send_gift_max_num"),25,CCSizeMake(self.bgLayer:getContentSize().width-80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		-- local maxNumLb=GetTTFLabelWrap("啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊",25,CCSizeMake(self.bgLayer:getContentSize().width-80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		maxNumLb:setPosition(self.bgLayer:getContentSize().width/2,58)
		self.bgLayer:addChild(maxNumLb,3)
	end
end

function acPeijianhuzengSelectFriendDialog:eventHandler(handler,fn,idx,cel)
	 if fn=="numberOfCellsInTableView" then
	   
	   return #self.friendTb

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize=CCSizeMake(400,self.cellHeight)
       return  tmpSize
   elseif fn=="tableCellAtIndex" then
	
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local rect = CCRect(0, 0, 50, 50);
		local capInSet = CCRect(40, 40, 10, 10);
		local capInSetNew=CCRect(20, 20, 10, 10)
		local backSprie
		local function nilFunc()
		end
		
		backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png",capInSet,nilFunc)
		backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.cellHeight-4))
		backSprie:ignoreAnchorPointForPosition(false)
		backSprie:setAnchorPoint(ccp(0,0))
		backSprie:setIsSallow(false)
		backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		cell:addChild(backSprie,1)
		
		local height=backSprie:getContentSize().height/2
		local widthSpace=50
		
		local selfRank
		local rankData
		
		local fUid=self.friendTb[idx+1].uid
		local nameStr=self.friendTb[idx+1].nickname
		local levelStr=self.friendTb[idx+1].level
		local valueStr=self.friendTb[idx+1].fc
		local rankStr = playerVoApi:getRankIconName(tonumber(self.friendTb[idx+1].rank))
		local mIcon=CCSprite:createWithSpriteFrameName(rankStr)
        mIcon:setScale(65/mIcon:getContentSize().width)
        mIcon:setAnchorPoint(ccp(0,0.5))
        mIcon:setPosition(ccp(15,36))
        cell:addChild(mIcon,5)
		
		local nameLabel=GetTTFLabel(nameStr,30)
		nameLabel:setPosition(widthSpace+150,height)
		cell:addChild(nameLabel,2)

		local levelLabel=GetTTFLabel(getlocal("fightLevel",{levelStr}),30)
		levelLabel:setPosition(widthSpace+150*2+20,height)
		cell:addChild(levelLabel,2)

		local function touchSelectItem()
			if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
			    if G_checkClickEnable()==false then
			        do
			            return
			        end
			    else
			        base.setWaitTime=G_getCurDeviceMillTime()
			    end
			    PlayEffect(audioCfg.mouseClick)
			    if self.pid and self.pid==3306 then
			    	local itemNum=bagVoApi:getItemNumId(self.pid) or 0
			    	if itemNum and itemNum>0 then
				    	local function sendRedPacketsHander()
				    		if fUid then
				    			local function friendsSendCallback(fn,data)
									local ret,sData=base:checkServerData(data)
				                	if ret==true then
				                		eventDispatcher:dispatchEvent("prop.dialog.useProp",{})
			                		    local vo=activityVoApi:getActivityVo("rechargebag")
									    local acRechargeBagVoApi=activityVoApi:getVoApiByType("rechargebag")
									    if vo and activityVoApi:isStart(vo)==true then
									        if acRechargeBagVoApi and acRechargeBagVoApi.setFlag then
									        	acRechargeBagVoApi:setFlag(1,0)
									        end
									    end
										smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_send_success"),30)
							    		self:close()
							    	end
							    end
							    socketHelper:friendsSend(fUid,self.pid,friendsSendCallback)
							end
						end
				    	local textStr=getlocal("send_red_packets",{nameStr})
				    	allianceSmallDialog:showOKDialog(sendRedPacketsHander,textStr,self.layerNum+1)
				    else
				    	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("notenoughprop"),30)
				    end
			    else
				    accessoryVoApi:showSelectAccessoryDialog(self.layerNum,self.friendTb[idx+1])
				end
			end
		end
		local selectItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",touchSelectItem,nil,getlocal("dailyAnswer_tab1_btn"),25)
       selectItem:setAnchorPoint(ccp(0.5,0.5))
       selectItem:setScale(0.8)
       local selectBtn=CCMenu:createWithItem(selectItem);
       selectBtn:setTouchPriority(-(self.layerNum-1)*20-2);
       selectBtn:setPosition(ccp(widthSpace+150*3,height))
       cell:addChild(selectBtn,2)
		-- local valueLabel=GetTTFLabel(FormatNumber(tonumber(valueStr)),30)
		-- valueLabel:setPosition(widthSpace+150*3,height)
		-- cell:addChild(valueLabel,2)

		return cell
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

function acPeijianhuzengSelectFriendDialog:doUserHandler()
	local height=self.bgLayer:getContentSize().height-145
	local widthSpace=80
	if self.rankLabel==nil then
		self.rankLabel=GetTTFLabel(getlocal("help2_t1_t3"),25)
		self.rankLabel:setPosition(widthSpace,height)
		self.bgLayer:addChild(self.rankLabel,1)
	end
	
	if self.nameLabel==nil then
		self.nameLabel=GetTTFLabel(getlocal("RankScene_name"),25)
		self.nameLabel:setPosition(widthSpace+150,height)
		self.bgLayer:addChild(self.nameLabel,1)
	end
	
	if self.levelLabel==nil then
		self.levelLabel=GetTTFLabel(getlocal("RankScene_level"),25)
		self.levelLabel:setPosition(widthSpace+150*2+20,height)
		self.bgLayer:addChild(self.levelLabel,1)
	end

	local flag=friendMailVoApi:getFlag()
	if flag==-1 then
		local function callbackList(fn,data)
			local ret,sData=base:checkServerData(data)
			if ret==true then
				self.friendTb=friendMailVoApi:getFriendTb()
				if #self.friendTb==0 then
					self.noLb:setVisible(true)
				else
					self.noLb:setVisible(false)
				end
          		self.tv:reloadData()
			end
		end
		socketHelper:friendsList(callbackList)
	end
end

function acPeijianhuzengSelectFriendDialog:dispose()
	self.friendTb=nil
	self.noLb=nil
	self.rankLabel=nil
	self.nameLabel=nil
	self.levelLabel=nil
	self.cellHeight=nil


end