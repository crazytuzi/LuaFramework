worldWarDialogSubTab14={}

function worldWarDialogSubTab14:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.selectedTabIndex=0
	self.bgLayer1=nil
    self.bgLayer2=nil
    self.bgLayer3=nil
    self.bgLayer4=nil

	self.cellHeight=72
	self.noRankLb=nil

	return nc
end

function worldWarDialogSubTab14:getRankList(type)
	return worldWarVoApi:getRankList(type)
end

function worldWarDialogSubTab14:init(layerNum)
	self.layerNum=layerNum
	local status=worldWarVoApi:checkStatus()
	local dType=1
	if status>=40 then
		dType=2
	end
	local bType=1
	local signStatus=worldWarVoApi:getSignStatus()
	if signStatus and signStatus==2 then
		bType=2
	end
	if dType==1 and bType==1 then 		--积分大师
		self.selectedTabIndex=0
	elseif dType==1 and bType==2 then 	--积分精英
		self.selectedTabIndex=1
	elseif dType==2 and bType==1 then 	--淘汰大师
		self.selectedTabIndex=2
	elseif dType==2 and bType==2 then 	--淘汰精英
		self.selectedTabIndex=3
	end
	self.bgLayer=CCLayer:create()
	self:resetTab()
	return self.bgLayer
end

function worldWarDialogSubTab14:initTab(tabTb)
   local tabBtn=CCMenu:create()
   local tabIndex=0
   local tabBtnItem;
   if tabTb~=nil then
       for k,v in pairs(tabTb) do
           tabBtnItem = CCMenuItemImage:create("switch-on.png", "switch-on.png","ww_switch-off.png")
           
           tabBtnItem:setAnchorPoint(CCPointMake(0.5,0.5))

           local function tabClick(idx)
               return self:tabClick(idx)
           end
           tabBtnItem:registerScriptTapHandler(tabClick)

           local lb=GetTTFLabelWrap(v,20,CCSizeMake(tabBtnItem:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
           lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width/2,tabBtnItem:getContentSize().height/2))
           tabBtnItem:addChild(lb)
		   lb:setTag(31)
		   
		   
	   		local numHeight=25
			local iconWidth=36
			local iconHeight=36
	   		local newsNumLabel = GetTTFLabel("0",numHeight)
	   		newsNumLabel:setPosition(ccp(newsNumLabel:getContentSize().width/2+5,iconHeight/2))
	   		newsNumLabel:setTag(11)
	   	    local capInSet1 = CCRect(17, 17, 1, 1)
	   	    local function touchClick()
	   	    end
	        local newsIcon =LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",capInSet1,touchClick)
			if newsNumLabel:getContentSize().width+10>iconWidth then
				iconWidth=newsNumLabel:getContentSize().width+10
			end
	        newsIcon:setContentSize(CCSizeMake(iconWidth,iconHeight))
	   		newsIcon:ignoreAnchorPointForPosition(false)
	   		newsIcon:setAnchorPoint(CCPointMake(1,0.5))
	        newsIcon:setPosition(ccp(tabBtnItem:getContentSize().width-2,tabBtnItem:getContentSize().height-30))
	        newsIcon:addChild(newsNumLabel,1)
			newsIcon:setTag(10)
	   		newsIcon:setVisible(false)
		    tabBtnItem:addChild(newsIcon)
		   
		   --local lockSp=CCSprite:createWithSpriteFrameName("LockIconCheckPoint.png")
           local lockSp=CCSprite:createWithSpriteFrameName("LockIcon.png")
		   lockSp:setAnchorPoint(CCPointMake(0,0.5))
		   lockSp:setPosition(ccp(10,tabBtnItem:getContentSize().height/2))
		   lockSp:setScaleX(0.7)
		   lockSp:setScaleY(0.7)
		   tabBtnItem:addChild(lockSp,3)
		   lockSp:setTag(30)
		   lockSp:setVisible(false)
			
           self.allTabs[k]=tabBtnItem
           tabBtn:addChild(tabBtnItem)
           tabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
           tabBtnItem:setTag(tabIndex)
           tabIndex=tabIndex+1
       end
   end
   tabBtn:setPosition(0,0)
   self.bgLayer:addChild(tabBtn,1)


	local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function () end)
	backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,100))
	backSprie:ignoreAnchorPointForPosition(false)
	backSprie:setAnchorPoint(ccp(0.5,0.5))
	backSprie:setIsSallow(false)
	backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
	backSprie:setPosition(ccp(G_VisibleSizeWidth/2,68))
	self.bgLayer:addChild(backSprie)
end

function worldWarDialogSubTab14:resetTab()
	self.allTabs={}
	for i=1,4 do
		table.insert(self.allTabs,getlocal("world_war_rank_sub_title_"..i))
	end
    self:initTab(self.allTabs)
    local index=0
    for k,v in pairs(self.allTabs) do
         local tabBtnItem=v
         local posY=68
         if index==0 then
            tabBtnItem:setPosition(100,posY)
         elseif index==1 then
            tabBtnItem:setPosition(248,posY)
         elseif index==2 then
            tabBtnItem:setPosition(394,posY)
         elseif index==3 then
            tabBtnItem:setPosition(540,posY)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         tabBtnItem:setScale(0.8)
         index=index+1
    end
    self:switchTab(self.selectedTabIndex+1)
end

function worldWarDialogSubTab14:initTabLayer(type)
	self["bgLayer"..type]=CCLayer:create()
    self.bgLayer:addChild(self["bgLayer"..type],2)

	local valueLabelSiz = 20
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
		valueLabelSiz =25
    end

	local function callBack(handler,fn,idx,cel)
		return self:eventHandler(handler,fn,idx,cel,type)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self["tv"..type]=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight-240-50-100),nil)
	self["tv"..type]:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self["tv"..type]:setPosition(ccp(30,30+100))
	self["tv"..type]:setMaxDisToBottomOrTop(60)
	self["bgLayer"..type]:addChild(self["tv"..type])

	local height=self.bgLayer:getContentSize().height-175-60
	local widthSpace=80
	local rankLabel=GetTTFLabel(getlocal("RankScene_rank"),25)
	rankLabel:setPosition(widthSpace,height)
	self["bgLayer"..type]:addChild(rankLabel,1)
	
	local nameLabel=GetTTFLabel(getlocal("RankScene_name"),25)
	nameLabel:setPosition(widthSpace+150-30,height)
	self["bgLayer"..type]:addChild(nameLabel,1)
	
	local serverLabel=GetTTFLabel(getlocal("serverwar_server_name"),25)
	serverLabel:setPosition(widthSpace+150*2+20,height)
	self["bgLayer"..type]:addChild(serverLabel,1)
	
	if type==1 or type==2 then
		local valueLabel=GetTTFLabel(getlocal("world_war_rank_point"),valueLabelSiz)
		valueLabel:setPosition(widthSpace+150*3+10,height)
		self["bgLayer"..type]:addChild(valueLabel,1)
	else
		local valueLabel=GetTTFLabel(getlocal("RankScene_power"),25)
		valueLabel:setPosition(widthSpace+150*3+10,height)
		self["bgLayer"..type]:addChild(valueLabel,1)
	end

	local index=math.ceil((self.selectedTabIndex+1)/2)
	local str=getlocal("world_war_no_rank"..index)
	local noRankLb=GetTTFLabelWrap(str,30,CCSizeMake(self.bgLayer:getContentSize().width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    noRankLb:setPosition(getCenterPoint(self["bgLayer"..type]))
    noRankLb:setTag(1101)
    self["bgLayer"..type]:addChild(noRankLb,1)
    noRankLb:setColor(G_ColorYellowPro)

	local rankList=self:getRankList(type)
	if rankList and SizeOfTable(rankList)>0 then
		noRankLb:setVisible(false)
	end
end

function worldWarDialogSubTab14:eventHandler(handler,fn,idx,cel,type)
	if fn=="numberOfCellsInTableView" then
		local rankList=self:getRankList(self.selectedTabIndex+1)
	   	local num=SizeOfTable(rankList)
	   	return num
   elseif fn=="tableCellSizeForIndex" then
		local tmpSize=CCSizeMake(400,self.cellHeight)
		return  tmpSize
   elseif fn=="tableCellAtIndex" then
		local rankList=self:getRankList(self.selectedTabIndex+1)
	   	local num=SizeOfTable(rankList)

		local cell=CCTableViewCell:new()
		cell:autorelease()

		local rect = CCRect(0, 0, 50, 50);
		local capInSet = CCRect(40, 40, 10, 10);
		local capInSetNew=CCRect(20, 20, 10, 10)
		local backSprie
		local function cellClick1(hd,fn,idx)
		end
		if idx==0 then
			backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank1ItemBg.png",capInSetNew,cellClick1)
		elseif idx==1 then
			backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank2ItemBg.png",capInSetNew,cellClick1)
		elseif idx==2 then
			backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank3ItemBg.png",capInSetNew,cellClick1)
		else
			backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png",capInSet,cellClick1)
		end
		backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.cellHeight-4))
		backSprie:ignoreAnchorPointForPosition(false)
		backSprie:setAnchorPoint(ccp(0,0))
		backSprie:setIsSallow(false)
		backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		cell:addChild(backSprie,1)
		
		local height=backSprie:getContentSize().height/2
		local widthSpace=50
		local lbSize=25
		
		local rankVo=rankList[idx+1] or {}
		local rankStr=""
		local nameStr=""
		local serverStr=""
		local valueStr=""
		if rankVo then
			rankStr=rankVo.rank
			nameStr=rankVo.name or ""
			serverStr=rankVo.server or ""
			if self.selectedTabIndex==0 or self.selectedTabIndex==1 then
				valueStr=rankVo.value or 0
			else
				valueStr=FormatNumber(rankVo.value or 0)
			end
		end

		local rankLabel=GetTTFLabel(rankStr,lbSize)
		rankLabel:setPosition(widthSpace,height)
		cell:addChild(rankLabel,2)
		
		local rankSp
		if tonumber(rankStr)==1 then
			rankSp=CCSprite:createWithSpriteFrameName("top1.png")
		elseif tonumber(rankStr)==2 then
			rankSp=CCSprite:createWithSpriteFrameName("top2.png")
		elseif tonumber(rankStr)==3 then
			rankSp=CCSprite:createWithSpriteFrameName("top3.png")
		end
		if rankSp then
	      	rankSp:setPosition(ccp(widthSpace,height))
			backSprie:addChild(rankSp,3)
			rankLabel:setVisible(false)
		end

		local nameLabel=GetTTFLabel(nameStr,lbSize)
		nameLabel:setPosition(widthSpace+150-30,height)
		cell:addChild(nameLabel,2)

		local serverLabel=GetTTFLabel(serverStr,lbSize)
		serverLabel:setPosition(widthSpace+150*2+20,height)
		cell:addChild(serverLabel,2)

		local valueLabel=GetTTFLabel(valueStr,lbSize)
		valueLabel:setPosition(widthSpace+150*3+10,height)
		cell:addChild(valueLabel,2)

		return cell
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

function worldWarDialogSubTab14:tabClick(idx)

    PlayEffect(audioCfg.mouseClick)

    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
         else
            v:setEnabled(true)
         end
    end
    
    self:switchTab(self.selectedTabIndex+1)
    
    -- self:tick()
end

function worldWarDialogSubTab14:switchTab(type)
    if type==nil then
        type=1
    end
    for i=1,4 do
        if(i==type)then
        	if(self["bgLayer"..i]==nil)then
        		local function formatRankListHandler()
        			self:initTabLayer(i)
				end
				worldWarVoApi:formatRankList(i,formatRankListHandler)
        	end
            if(self["bgLayer"..i]~=nil)then
                self["bgLayer"..i]:setPosition(ccp(0,0))
                self["bgLayer"..i]:setVisible(true)
            end
        else
            if(self["bgLayer"..i]~=nil)then
                self["bgLayer"..i]:setPosition(ccp(999333,0))
                self["bgLayer"..i]:setVisible(false)
            end
        end
    end
end

function worldWarDialogSubTab14:tick()
	local rankExpireTime=worldWarVoApi:getRankExpireTime(self.selectedTabIndex+1)
	-- print("base.serverTime~~~~~~rank:",base.serverTime)
	-- print("rankExpireTime~~~~~~rank:",rankExpireTime)
	if rankExpireTime and base.serverTime>rankExpireTime then
		local function formatRankListHandler(isSuccess)
			if isSuccess==true then
				if self["bgLayer"..self.selectedTabIndex+1] then
					if self["tv"..self.selectedTabIndex+1] then
						self["tv"..self.selectedTabIndex+1]:reloadData()
					end
					local rankList=self:getRankList(self.selectedTabIndex+1)
					if rankList and SizeOfTable(rankList)>0 then
						local lb=tolua.cast(self["bgLayer"..self.selectedTabIndex+1]:getChildByTag(1101),"CCLabelTTF")
						if lb then
							lb:setVisible(false)
						end
					end
				end
			end
		end
		worldWarVoApi:formatRankList(self.selectedTabIndex+1,formatRankListHandler)
	end
end

function worldWarDialogSubTab14:dispose()
	-- base:removeFromNeedRefresh(self)
	self.bgLayer:removeFromParentAndCleanup(true)
    for i=1,4 do
    	self["bgLayer"..i]=nil
    end
    for i=1,4 do
    	self["tv"..i]=nil
    end
    self.selectedTabIndex=0
	self.tv=nil
	self.layerNum=nil
	self.bgLayer=nil
	self.noRankLb=nil
end