platWarRewardDialogTab3={}
function platWarRewardDialogTab3:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	self.rankLabel=nil
	self.nameLabel=nil
	self.serverLabel=nil
	self.valueLabel=nil
	self.labelTab={}
	self.cellHeight=80
	self.type=2
	self.noRankLb=nil
	self.rewardBtn=nil
    return nc
end

function platWarRewardDialogTab3:init(layerNum,parent)
	self.layerNum=layerNum
	self.parent=parent
	self.bgLayer=CCLayer:create()
	self:initTableView()
	self:doUserHandler()
	return self.bgLayer
end

function platWarRewardDialogTab3:initTableView()
	local rect = CCRect(0, 0, 50, 50);
	local capInSet = CCRect(20, 20, 10, 10);
	local function cellClick(hd,fn,idx)
	end
	local backSprie1=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
	backSprie1:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.bgLayer:getContentSize().height-245-70))
	backSprie1:ignoreAnchorPointForPosition(false)
	backSprie1:setAnchorPoint(ccp(0,0))
	backSprie1:setPosition(30,110)
	backSprie1:setIsSallow(false)
	backSprie1:setTouchPriority(-(self.layerNum-1)*20-1)
	self.bgLayer:addChild(backSprie1)
	
	
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-70,self.bgLayer:getContentSize().height-240-90),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(35,120))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

    self.noRankLb = GetTTFLabelWrap(getlocal("activity_kuangnuzhishi_noRankList"),30,CCSizeMake(self.bgLayer:getContentSize().width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	self.noRankLb:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2)
	self.bgLayer:addChild(self.noRankLb,5)
	self.noRankLb:setColor(G_ColorYellowPro)
	local rankList=platWarVoApi:getRankList(self.type)
	if rankList and SizeOfTable(rankList)>0 then
		self.noRankLb:setVisible(false)
	end
end

function platWarRewardDialogTab3:eventHandler(handler,fn,idx,cel)
   	if fn=="numberOfCellsInTableView" then
		-- local hasMore=rankVoApi:hasMore(self.selectedTabIndex)
		-- local num=rankVoApi:getRankNum(self.selectedTabIndex)
		-- if hasMore then
		-- 	num=num+1
		-- end
		local rankList=platWarVoApi:getRankList(self.type)
		local num=SizeOfTable(rankList)
		return num
   	elseif fn=="tableCellSizeForIndex" then
		local tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-70,self.cellHeight)
		return tmpSize
   	elseif fn=="tableCellAtIndex" then
		-- local hasMore=rankVoApi:hasMore(self.selectedTabIndex)
		-- local num=rankVoApi:getRankNum(self.selectedTabIndex)
	
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local rect = CCRect(0, 0, 50, 50);
		local capInSet = CCRect(40, 40, 10, 10);
		local capInSetNew=CCRect(20, 20, 10, 10)
		local backSprie
		-- if hasMore and idx==num then
		-- 	local function cellClick(hd,fn,idx)
		-- 		self:cellClick(idx)
		-- 	end
		-- 	backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("ItemBtnMore.png",capInSetNew,cellClick)
		-- 	backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.cellHeight))
		-- 	backSprie:ignoreAnchorPointForPosition(false)
		-- 	backSprie:setAnchorPoint(ccp(0,0))
		-- 	backSprie:setIsSallow(false)
		-- 	backSprie:setTouchPriority(-42)
		-- 	backSprie:setTag(idx)
		-- 	cell:addChild(backSprie,1)
			
		-- 	local moreLabel=GetTTFLabel(getlocal("showMore"),30)
		-- 	moreLabel:setPosition(getCenterPoint(backSprie))
		-- 	backSprie:addChild(moreLabel,2)
			
		-- 	do return cell end
		-- end
		
		local function cellClick1(hd,fn,idx)
		end
		-- if idx==0 then
		-- 	backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png",capInSetNew,cellClick1)
		-- else
		if idx==0 then
			backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank1ItemBg.png",capInSetNew,cellClick1)
		elseif idx==1 then
			backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank2ItemBg.png",capInSetNew,cellClick1)
		elseif idx==2 then
			backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank3ItemBg.png",capInSetNew,cellClick1)
		else
			backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png",capInSet,cellClick1)
		end
		backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-70, self.cellHeight-4))
		backSprie:ignoreAnchorPointForPosition(false)
		backSprie:setAnchorPoint(ccp(0,0))
		backSprie:setIsSallow(false)
		backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		cell:addChild(backSprie,1)
		
		local height=backSprie:getContentSize().height/2
		local widthSpace=50
		local lbSize=25
		
		local rankList=platWarVoApi:getRankList(self.type)
		-- local selfRank
		local rankData=rankList[idx+1]

		local rankStr=""
		local nameStr=""
		local serverStr=""
		local valueStr=""
		-- if idx==0 then
		-- 	selfRank=rankVoApi:getRank(self.selectedTabIndex).selfRank
		-- 	if selfRank~=nil then
		-- 		rankStr=selfRank.rank
		-- 		nameStr=selfRank.name
		-- 		serverStr=selfRank.server
		-- 		valueStr=selfRank.value
		-- 	end
		-- else
		-- 	if rankVoApi:getRank(self.selectedTabIndex).rankData~=nil then
		-- 		rankData=rankVoApi:getRank(self.selectedTabIndex).rankData[idx]
				if rankData~=nil then
					rankStr=rankData.rank
					nameStr=rankData.name
					serverStr=rankData.server
					valueStr=rankData.value
				end
		-- 	end
		-- end

		local rankLabel=GetTTFLabel(rankStr,lbSize)
		rankLabel:setPosition(widthSpace-10,height)
		cell:addChild(rankLabel,2)
		table.insert(self.labelTab,idx,{rankLabel=rankLabel})
		
		local rankSp
		if tonumber(rankStr)==1 then
			rankSp=CCSprite:createWithSpriteFrameName("top1.png")
		elseif tonumber(rankStr)==2 then
			rankSp=CCSprite:createWithSpriteFrameName("top2.png")
		elseif tonumber(rankStr)==3 then
			rankSp=CCSprite:createWithSpriteFrameName("top3.png")
		end
		if rankSp then
	      	rankSp:setPosition(ccp(widthSpace-10,height))
			backSprie:addChild(rankSp,3)
			rankLabel:setVisible(false)
		end

		if rankData.platId then
			local platIcon=platWarVoApi:getPlatIcon(rankData.platId)
			if platIcon then
				platIcon:setPosition(widthSpace+60,height)
				cell:addChild(platIcon,2)
			end
		end
		

		local nameLabel=GetTTFLabel(nameStr,lbSize)
		nameLabel:setPosition(widthSpace+170,height)
		cell:addChild(nameLabel,2)
		self.labelTab[idx].nameLabel=nameLabel

		local serverLabel=GetTTFLabel(serverStr,lbSize)
		serverLabel:setPosition(widthSpace+150*2+35,height)
		cell:addChild(serverLabel,2)
		self.labelTab[idx].serverLabel=serverLabel

		-- if self.selectedTabIndex==1 then
		-- 	local valueLabel=GetTTFLabel(valueStr,lbSize)
		-- 	valueLabel:setPosition(widthSpace+150*3-15,height)
		-- 	cell:addChild(valueLabel,2)
		-- 	self.labelTab[idx].valueLabel=valueLabel
			
		-- 	local starIcon = CCSprite:createWithSpriteFrameName("StarIcon.png")
	 --      	starIcon:setPosition(ccp(widthSpace+150*3+35,height))
		-- 	cell:addChild(starIcon,2)
		-- else
			local valueLabel=GetTTFLabel(FormatNumber(valueStr),lbSize)
			valueLabel:setPosition(widthSpace+150*3+15,height)
			cell:addChild(valueLabel,2)
			self.labelTab[idx].valueLabel=valueLabel
		-- end

		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end

function platWarRewardDialogTab3:doUserHandler()
	local height=self.bgLayer:getContentSize().height-185
	local widthSpace=80
	if self.rankLabel==nil then
		self.rankLabel=GetTTFLabel(getlocal("RankScene_rank"),25)
		self.rankLabel:setPosition(widthSpace-5,height)
		self.bgLayer:addChild(self.rankLabel,1)
	end
	
	if self.nameLabel==nil then
		self.nameLabel=GetTTFLabel(getlocal("RankScene_name"),25)
		self.nameLabel:setPosition(widthSpace+170,height)
		self.bgLayer:addChild(self.nameLabel,1)
	end
	
	if self.serverLabel==nil then
		self.serverLabel=GetTTFLabel(getlocal("serverwar_server_name"),25)
		self.serverLabel:setPosition(widthSpace+150*2+40,height)
		self.bgLayer:addChild(self.serverLabel,1)
	end
	
	if self.valueLabel==nil then
		self.valueLabel=GetTTFLabel(getlocal("plat_war_donate_point"),25)
		self.valueLabel:setPosition(widthSpace+150*3+20,height)
		self.bgLayer:addChild(self.valueLabel,1)
	end
	-- if self.selectedTabIndex==0 then
	-- 	self.valueLabel:setString(getlocal("RankScene_power"))
	-- elseif self.selectedTabIndex==1 then
	-- 	self.valueLabel:setString(getlocal("RankScene_star_num"))
	-- elseif self.selectedTabIndex==2 then
	-- 	self.valueLabel:setString(getlocal("RankScene_honor"))
	-- end

	self:setColor(G_ColorGreen)


	local lbHeight=68
	local lbWidth=320
	-- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
	if self.myPointLb==nil then
		self.myPointLb=GetTTFLabelWrap(getlocal("plat_war_my_point",{platWarVoApi:getMyPoint(self.type)}),20,CCSizeMake(lbWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		-- self.myPointLb=GetTTFLabelWrap(str,20,CCSizeMake(lbWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		self.myPointLb:setPosition(190,lbHeight+22)
		self.bgLayer:addChild(self.myPointLb,1)
		self.myPointLb:setColor(G_ColorYellowPro)
	end

	if self.myRankLb==nil then
		local myRank=platWarVoApi:getMyRank(self.type)
		if myRank==0 then
			if platWarCfg and platWarCfg.pointRank and platWarCfg.pointRank.maxNum then
				myRank=platWarCfg.pointRank.maxNum.."+"
			end
		end
		self.myRankLb=GetTTFLabelWrap(getlocal("plat_war_my_rank",{myRank}),20,CCSizeMake(lbWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		-- self.myRankLb=GetTTFLabelWrap(str,20,CCSizeMake(lbWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		self.myRankLb:setPosition(190,lbHeight-22)
		self.bgLayer:addChild(self.myRankLb,1)
		self.myRankLb:setColor(G_ColorYellowPro)
	end

	local function touchInfo()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if (battleScene and battleScene.isBattleing==true) then
            do return end
        end
        PlayEffect(audioCfg.mouseClick)

        platWarVoApi:showRewardDetailSmallDialog(self.type,self.layerNum+1)
    end
    local menuItem = GetButtonItem("SlotInfor.png","SlotInfor.png","SlotInfor.png",touchInfo,11,nil,nil)
    local menu = CCMenu:createWithItem(menuItem)
    menu:setPosition(ccp(self.bgLayer:getContentSize().width-240,lbHeight))
    menu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(menu,3)


   	local function rewardHandler()
   		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        local function rankRewardCallback()
        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("receivereward_received_success"),30)
        	if self.rewardBtn then
        		self.rewardBtn:setEnabled(false)
        		tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("activity_hadReward"))
        	end
        end
    	local isCanReward=platWarVoApi:isCanRewardRank(self.type)
    	if isCanReward==0 then
    		local myRank=platWarVoApi:getMyRank(self.type)
    		if myRank and myRank>0 then
	    		platWarVoApi:rankReward(self.type,myRank,rankRewardCallback)
	    	end
    	end
    end
    local rewardStr=getlocal("newGiftsReward")
    local isCanReward=platWarVoApi:isCanRewardRank(self.type)
    if isCanReward==2 then
    	rewardStr=getlocal("activity_hadReward")
    end
    self.rewardBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",rewardHandler,nil,rewardStr,25,11)
    local rewardMenu=CCMenu:createWithItem(self.rewardBtn)
    rewardMenu:setPosition(ccp(self.bgLayer:getContentSize().width-110,lbHeight))
    rewardMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(rewardMenu,2)
    if isCanReward==0 then
    else
    	self.rewardBtn:setEnabled(false)
    end
end

function platWarRewardDialogTab3:setColor(color)
	self.rankLabel:setColor(color)
	self.nameLabel:setColor(color)
	self.serverLabel:setColor(color)
	self.valueLabel:setColor(color)
end

function platWarRewardDialogTab3:cellClick(idx)
  --   if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
		-- local rData=rankVoApi:getRank(self.selectedTabIndex)
	 --    local hasMore=rankVoApi:hasMore(self.selectedTabIndex)
	 --    local num=rankVoApi:getRankNum(self.selectedTabIndex)
		-- if hasMore and tostring(idx)==tostring(num) then
		-- 	PlayEffect(audioCfg.mouseClick)
		-- 	local function rankingHandler(fn,data)
		-- 		if base:checkServerData(data)==true then
		-- 			--local nowNum=rankVoApi:getMore(self.selectedTabIndex)
		-- 			local nowNum=rankVoApi:getRankNum(self.selectedTabIndex)
		-- 			local nextHasMore=rankVoApi:hasMore(self.selectedTabIndex)
		-- 			local recordPoint = self.tv:getRecordPoint()
		-- 			self.tv:reloadData()
		-- 			if nextHasMore then
		-- 				recordPoint.y=(num-nowNum)*self.cellHeight+recordPoint.y
		-- 			else
		-- 				recordPoint.y=(num-nowNum+1)*self.cellHeight+recordPoint.y
		-- 			end
		-- 			self.tv:recoverToRecordPoint(recordPoint)
		-- 		end
		-- 	end
		-- 	local page=rData.page+1
		-- 	socketHelper:ranking(self.selectedTabIndex+1,page,rankingHandler)
		-- end
  --   end
end

function platWarRewardDialogTab3:tick()
	if self then
		if self.myPointLb then
			self.myPointLb:setString(getlocal("plat_war_my_point",{platWarVoApi:getMyPoint(self.type)}))
		end
		if self.myRankLb then
			local myRank=platWarVoApi:getMyRank(self.type)
			if myRank==0 then
				if platWarCfg and platWarCfg.pointRank and platWarCfg.pointRank.maxNum then
					myRank=platWarCfg.pointRank.maxNum.."+"
				end
			end
			self.myRankLb:setString(getlocal("plat_war_my_rank",{myRank}))
		end
	end
end

function platWarRewardDialogTab3:dispose()
	self.rewardBtn=nil
	self.rankLabel=nil
	self.nameLabel=nil
	self.serverLabel=nil
	self.valueLabel=nil
	self.labelTab=nil
	self.cellHeight=nil
	self.noRankLb=nil
	self=nil
end





