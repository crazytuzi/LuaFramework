serverWarPersonalDialogSubTab13={}

function serverWarPersonalDialogSubTab13:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.cellHeight=72
	self.noRankLb=nil

	return nc
end

function serverWarPersonalDialogSubTab13:init(layerNum)
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()
	self:initTableView()
	return self.bgLayer
end

function serverWarPersonalDialogSubTab13:initTableView()
	local rankList=serverWarPersonalVoApi:getRankList()
	if rankList and SizeOfTable(rankList)>0 then
		local function callBack(...)
			return self:eventHandler(...)
		end
		local hd= LuaEventHandler:createHandler(callBack)
		local tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight-240-50),nil)
		tableView:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
		tableView:setPosition(ccp(30,30))
		tableView:setMaxDisToBottomOrTop(60)
		self.bgLayer:addChild(tableView)

		local height=self.bgLayer:getContentSize().height-175-60
		local widthSpace=80
		local rankLabel=GetTTFLabel(getlocal("RankScene_rank"),25)
		rankLabel:setPosition(widthSpace,height)
		self.bgLayer:addChild(rankLabel,1)
		
		local nameLabel=GetTTFLabel(getlocal("RankScene_name"),25)
		nameLabel:setPosition(widthSpace+150-30,height)
		self.bgLayer:addChild(nameLabel,1)
		
		local serverLabel=GetTTFLabel(getlocal("serverwar_server_name"),25)
		serverLabel:setPosition(widthSpace+150*2+20,height)
		self.bgLayer:addChild(serverLabel,1)
		
		local valueLabel=GetTTFLabel(getlocal("RankScene_power"),25)
		valueLabel:setPosition(widthSpace+150*3+10,height)
		self.bgLayer:addChild(valueLabel,1)
	else
		local function callBack(...)
			
		end
		local hd= LuaEventHandler:createHandler(callBack)
		local tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight-240-50),nil)

		local noRankLb=GetTTFLabelWrap(getlocal("serverwar_no_rank"),30,CCSizeMake(self.bgLayer:getContentSize().width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	    noRankLb:setPosition(getCenterPoint(self.bgLayer))
	    self.bgLayer:addChild(noRankLb,1)
	    noRankLb:setColor(G_ColorYellowPro)
	end
end

function serverWarPersonalDialogSubTab13:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		local rankList=serverWarPersonalVoApi:getRankList()
	   	local num=SizeOfTable(rankList)
	   	return num
   elseif fn=="tableCellSizeForIndex" then
		local tmpSize=CCSizeMake(400,self.cellHeight)
		return  tmpSize
   elseif fn=="tableCellAtIndex" then
		local rankList=serverWarPersonalVoApi:getRankList()
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
			valueStr=rankVo.value or 0
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

		local valueLabel=GetTTFLabel(FormatNumber(valueStr),lbSize)
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
