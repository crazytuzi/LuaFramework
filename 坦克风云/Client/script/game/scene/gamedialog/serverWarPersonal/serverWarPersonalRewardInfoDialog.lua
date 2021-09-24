serverWarPersonalRewardInfoDialog=commonDialog:new()

function serverWarPersonalRewardInfoDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.cellHeght1=320
	self.cellHeght2=200

	return nc
end

function serverWarPersonalRewardInfoDialog:getDataByType()
	
end

function serverWarPersonalRewardInfoDialog:initTableView()
	self.panelLineBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-30,self.bgLayer:getContentSize().height-105))
	self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-30))

	local myRank=serverWarPersonalVoApi:getMyRank()
	local rewardPoint=serverWarPersonalVoApi:getRewardPoint()
	if myRank and myRank>0 and rewardPoint and rewardPoint>0 then
		local function callBack(...)
			return self:eventHandler(...)
		end
		local hd= LuaEventHandler:createHandler(callBack)
		self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-40,self.bgLayer:getContentSize().height-230),nil)
		self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
		self.tv:setAnchorPoint(ccp(0,0))
		self.tv:setPosition(ccp(20,140))
		self.tv:setMaxDisToBottomOrTop(120)
		self.bgLayer:addChild(self.tv)

		-- local hasReward=serverWarPersonalVoApi:getIsRewardRank()
		-- if hasReward==true then
			local rewardBg
			local capInSet = CCRect(20, 20, 10, 10)
			local function touch()
			end
			local rewardBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,touch)
		    rewardBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-30,110))
		    rewardBg:ignoreAnchorPointForPosition(false)
		    rewardBg:setAnchorPoint(ccp(0.5,0))
		    rewardBg:setIsSallow(false)
		    rewardBg:setTouchPriority(-(self.layerNum-1)*20-1)
			rewardBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,25))
			self.bgLayer:addChild(rewardBg,2)


			local myRankStr=getlocal("serverwar_my_rank",{myRank})
			-- myRankStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
			local myRankLb=GetTTFLabelWrap(myRankStr,22,CCSizeMake(rewardBg:getContentSize().width-180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			myRankLb:setAnchorPoint(ccp(0,0.5))
			myRankLb:setPosition(ccp(10,rewardBg:getContentSize().height/2+25))
			rewardBg:addChild(myRankLb,1)

			local rewardPointStr=getlocal("serverwar_can_reward",{rewardPoint})
			-- rewardPointStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
			local rewardPointLb=GetTTFLabelWrap(rewardPointStr,22,CCSizeMake(rewardBg:getContentSize().width-180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			rewardPointLb:setAnchorPoint(ccp(0,0.5))
			rewardPointLb:setPosition(ccp(10,rewardBg:getContentSize().height/2-25))
			rewardBg:addChild(rewardPointLb,1)

			local function rewardHandler(tag,object)
				if G_checkClickEnable()==false then
		            do
		                return
		            end
		        else
		            base.setWaitTime=G_getCurDeviceMillTime()
		        end
		        local function rewardCallback()
			        serverWarPersonalVoApi:setIsRewardRank(true)
			        self.rewardBtn:setEnabled(false)
			        local lb=tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF")
			        if lb then
			       		lb:setString(getlocal("activity_hadReward"))
			       	end
			       	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwar_reward_point",{rewardPoint}),30)
			    end
		       	serverWarPersonalVoApi:rewardRank(rewardCallback)
			end
			local scale=0.8
			self.rewardBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",rewardHandler,nil,getlocal("activity_continueRecharge_reward"),25,11)
			self.rewardBtn:setScale(scale)
			local rewardMenu=CCMenu:createWithItem(self.rewardBtn)
			rewardMenu:setPosition(ccp(rewardBg:getContentSize().width-self.rewardBtn:getContentSize().width/2*scale-20,rewardBg:getContentSize().height/2))
			rewardMenu:setTouchPriority(-(self.layerNum-1)*20-4)
			rewardBg:addChild(rewardMenu)

			local isReward=serverWarPersonalVoApi:getIsRewardRank()
			if isReward==true then
				self.rewardBtn:setEnabled(false)
				local lb=tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF")
		        if lb then
		       		lb:setString(getlocal("activity_hadReward"))
		       	end
			end
		-- end
	else
		local function callBack(...)
			return self:eventHandler(...)
		end
		local hd= LuaEventHandler:createHandler(callBack)
		self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-40,self.bgLayer:getContentSize().height-130),nil)
		self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
		self.tv:setAnchorPoint(ccp(0,0))
		self.tv:setPosition(ccp(20,40))
		self.tv:setMaxDisToBottomOrTop(120)
		self.bgLayer:addChild(self.tv)
	end
end

function serverWarPersonalRewardInfoDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		local rankRewardCfg=serverWarPersonalVoApi:getRankRewardCfg()
		local num=SizeOfTable(rankRewardCfg)
		return num
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		local isHasServerReward=serverWarPersonalVoApi:isHasServerReward(idx+1)
		if isHasServerReward==true then
			tmpSize = CCSizeMake(G_VisibleSizeWidth-40,self.cellHeght1)
		else
			tmpSize = CCSizeMake(G_VisibleSizeWidth-40,self.cellHeght2)
		end
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local isHasServerReward=serverWarPersonalVoApi:isHasServerReward(idx+1)
		local rankRewardCfg=serverWarPersonalVoApi:getRankRewardCfg()
		local severRewardCfg=serverWarPersonalVoApi:getSeverRewardCfg()
		local rCfg=rankRewardCfg[idx+1]
		local sCfg=severRewardCfg[idx+1]

		local point
		local range
		local pic
		local titleStr=""
		local dayNum=0
		local rewardTb={}
		if rCfg then
			point=rCfg.point or 0
			range=rCfg.range
			if rCfg.icon then
				pic=rCfg.icon
			end
			if rCfg.title then
				titleStr=getlocal(rCfg.title)
			end
			if rCfg.lastTime and rCfg.lastTime[1] then
				dayNum=tonumber(rCfg.lastTime[1])
			end
		end
		if sCfg and sCfg.reward then
			rewardTb=FormatItem(sCfg.reward)
		end

		local cellWidth=G_VisibleSizeWidth-40
		local cellHeight
		if isHasServerReward==true then
			cellHeight=self.cellHeght1
		else
			cellHeight=self.cellHeght2
		end
		local capInSet = CCRect(20, 20, 10, 10)
		local function touch()
		end
		local headBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",capInSet,touch)
        headBg:setContentSize(CCSizeMake(cellWidth,50))
        headBg:ignoreAnchorPointForPosition(false)
        headBg:setAnchorPoint(ccp(0.5,1))
        headBg:setIsSallow(false)
        headBg:setTouchPriority(-(self.layerNum-1)*20-2)
		headBg:setPosition(ccp(cellWidth/2,cellHeight))
		cell:addChild(headBg,1)

		local rankList=serverWarPersonalVoApi:getRankList()
		local rankVo=rankList[idx+1]

		local serverName=""
		local playerName=""
		if rankVo then
			serverName=rankVo.server or ""
			playerName=rankVo.name or ""
		end
		local rankStr=""
		local playerStr=getlocal("serverwar_server_player",{serverName,playerName})
		if idx>=0 and idx<=2 then
			if idx==0 then
				rankStr=getlocal("serverwar_first_reward")
			elseif idx==1 then
				rankStr=getlocal("serverwar_second_reward")
			elseif idx==2 then
				rankStr=getlocal("serverwar_third_reward")
			end
			if rankVo and SizeOfTable(rankVo)>0 then
				rankStr=rankStr..playerStr
			end
		else
			if range and range[1] then
				local minRank=range[1]
				if range[2] then
					local maxRank=range[2]
					if minRank==maxRank then
						rankStr=getlocal("serverwar_rank_reward",{minRank})
					else
						rankStr=getlocal("serverwar_rank_reward",{minRank.."-"..maxRank})
					end
				else
					rankStr=getlocal("serverwar_rank_reward",{minRank})
				end
			end
		end
		-- rankStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
		local rankLb=GetTTFLabelWrap(rankStr,22,CCSizeMake(cellWidth-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		rankLb:setAnchorPoint(ccp(0,0.5))
		rankLb:setPosition(ccp(10,headBg:getContentSize().height/2))
		headBg:addChild(rankLb,1)
		rankLb:setColor(G_ColorYellowPro)


		local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,touch)
		backSprie:setContentSize(CCSizeMake(cellWidth-10,cellHeight-headBg:getContentSize().height))
		backSprie:ignoreAnchorPointForPosition(false)
        backSprie:setAnchorPoint(ccp(0.5,1))
        backSprie:setIsSallow(false)
        backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
		backSprie:setPosition(ccp(cellWidth/2,cellHeight-headBg:getContentSize().height))
		cell:addChild(backSprie,1)


		if isHasServerReward==true then
			local desc1=getlocal("serverwar_reward_desc1",{titleStr})..getlocal("serverwar_day_num",{dayNum})
			-- if idx==1 then
			-- 	desc1="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
			-- end
			local descLb1=GetTTFLabelWrap(desc1,22,CCSizeMake(cellWidth-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			descLb1:setAnchorPoint(ccp(0,0.5))
			descLb1:setPosition(ccp(20,backSprie:getContentSize().height-35))
			backSprie:addChild(descLb1,1)

			if pic then
				local function clickHandler()
			    end
			    local rankIcon=LuaCCSprite:createWithSpriteFrameName(pic,clickHandler)
			    local rankScale=0.8
			    rankIcon:setScale(rankScale)
			    rankIcon:setTouchPriority(-(self.layerNum-1)*20-2)
			    rankIcon:setAnchorPoint(ccp(0.5,0.5))
				local tempLb=GetTTFLabel(desc1,22)
				if tempLb:getContentSize().width>=(cellWidth-100) then
					rankIcon:setPosition(ccp(cellWidth-50,backSprie:getContentSize().height-35))
				else
					rankIcon:setPosition(ccp(tempLb:getContentSize().width+rankIcon:getContentSize().width/2*rankScale+25,backSprie:getContentSize().height-35))
				end
			    backSprie:addChild(rankIcon,1)
			end

			local desc2=getlocal("serverwar_reward_desc2",{point})
			-- desc2="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
			local descLb2=GetTTFLabelWrap(desc2,22,CCSizeMake(cellWidth-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			descLb2:setAnchorPoint(ccp(0,0.5))
			descLb2:setPosition(ccp(20,backSprie:getContentSize().height-85))
			backSprie:addChild(descLb2,1)

			local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	        lineSp:setAnchorPoint(ccp(0.5,0.5))
	        lineSp:setScale(0.95)
	        lineSp:setPosition(ccp(cellWidth/2,backSprie:getContentSize().height-115))
	        backSprie:addChild(lineSp)

	        local rewardStr=getlocal("serverwar_server_reward",{getlocal("serverwar_rank_"..(idx+1))})
	        -- rewardStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
			local rewardLb=GetTTFLabelWrap(rewardStr,22,CCSizeMake(cellWidth-50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			rewardLb:setAnchorPoint(ccp(0,0.5))
			rewardLb:setPosition(ccp(20,125))
			backSprie:addChild(rewardLb,1)

			if rewardTb and SizeOfTable(rewardTb)>0 then
				local iconSize=80
				for k,v in pairs(rewardTb) do
					local icon,scale=G_getItemIcon(v,iconSize,false,self.layerNum)
					icon:setTouchPriority(-(self.layerNum-1)*20-2)
					icon:setPosition(iconSize/2*scale+30+(iconSize+20)*(k-1),iconSize/2+15)
					backSprie:addChild(icon,1)

					local numStr="x"..FormatNumber(v.num)
					local numLb=GetTTFLabel(numStr,25)
					numLb:setAnchorPoint(ccp(1,0))
					numLb:setPosition(ccp(icon:getContentSize().width-5,5))
					icon:addChild(numLb,1)
				end
			end 
		else
			local desc2=getlocal("serverwar_reward_desc2",{point})
			-- desc2="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
			local descLb2=GetTTFLabelWrap(desc2,22,CCSizeMake(cellWidth-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			descLb2:setAnchorPoint(ccp(0,0.5))
			descLb2:setPosition(ccp(20,backSprie:getContentSize().height/2))
			backSprie:addChild(descLb2,1)
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

function serverWarPersonalRewardInfoDialog:dispose()
	
end