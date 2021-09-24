alienMinesRankTab1={

}

function alienMinesRankTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
    self.cellHeight=72
    return nc
end

function alienMinesRankTab1:init(layerNum)
 	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.data = alienMinesVoApi:getPersonalList()
	-- 初始化标签
	self:initTitleLb()

	self:initTableView()

	return self.bgLayer
end

function alienMinesRankTab1:initTitleLb()
	local height=self.bgLayer:getContentSize().height-175
	local widthSpace=80

	local rankLabel=GetTTFLabel(getlocal("RankScene_rank"),25)
	rankLabel:setPosition(widthSpace,height)
	self.bgLayer:addChild(rankLabel,1)

	local nameLabel=GetTTFLabel(getlocal("RankScene_name"),25)
	nameLabel:setPosition(widthSpace+150,height)
	self.bgLayer:addChild(nameLabel,1)

	local levelLabel=GetTTFLabel(getlocal("RankScene_level"),25)
	levelLabel:setPosition(widthSpace+150*2,height)
	self.bgLayer:addChild(levelLabel,1)

	local valueLabel=GetTTFLabel(getlocal("alienMines_alienScore"),25)
	valueLabel:setPosition(widthSpace+145*3,height)
	self.bgLayer:addChild(valueLabel,1)

	local limitLb = GetTTFLabelWrap(getlocal("alienMines_res_limit",{alienMineCfg.userRanking.needpoint}),25,CCSizeMake(self.bgLayer:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    limitLb:setAnchorPoint(ccp(0.5,0))
	limitLb:setColor(G_ColorRed)
	limitLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,40))
	self.bgLayer:addChild(limitLb,1)
	self.limitLb=limitLb
end

function alienMinesRankTab1:initTableView()
    local function callBack(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-250-self.limitLb:getContentSize().height),nil)
	self.tv:setAnchorPoint(ccp(0,0))
	self.tv:setPosition(ccp(10,40+self.limitLb:getContentSize().height+10))
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setMaxDisToBottomOrTop(80)
	self.bgLayer:addChild(self.tv)
end

function alienMinesRankTab1:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return SizeOfTable(self.data)+1
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize=CCSizeMake(400,self.cellHeight)
        return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease() 

		local cell=CCTableViewCell:new()
		cell:autorelease()
		local rect = CCRect(0, 0, 50, 50);
		local capInSet = CCRect(40, 40, 10, 10);
		local capInSetNew=CCRect(20, 20, 10, 10)
		local backSprie

		local function cellClick1(hd,fn,idx)
		end
		if idx==0 then
			backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png",capInSetNew,cellClick1)
		elseif idx==1 then
			backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank1ItemBg.png",capInSetNew,cellClick1)
		elseif idx==2 then
			backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank2ItemBg.png",capInSetNew,cellClick1)
		elseif idx==3 then
			backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank3ItemBg.png",capInSetNew,cellClick1)
		else
			backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png",capInSet,cellClick1)
		end
		backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.cellHeight-4))
		backSprie:ignoreAnchorPointForPosition(false)
		backSprie:setAnchorPoint(ccp(0,0))
		backSprie:setIsSallow(false)
		backSprie:setPosition(ccp(20,2))
		backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		cell:addChild(backSprie,1)

		local height=backSprie:getContentSize().height/2
		local widthSpace=50
		
		local selfRank
		local rankData
		
		local rankStr=""
		local nameStr=""
		local levelStr=""
		local valueStr=""

		if idx==0 then
			selfRank=alienMinesVoApi:getSelfList()
			if selfRank~=nil then
				rankStr=selfRank[4]
				nameStr=selfRank[2]
				levelStr=selfRank[3]
				valueStr=selfRank[5]
			end
		else
			rankData= alienMinesVoApi:getPersonalList()
			if rankData~=nil then
				rankStr=rankData[idx][4]
				nameStr=rankData[idx][2]
				levelStr=rankData[idx][3]
				valueStr=rankData[idx][5]
			end
		end

		local rankLabel=GetTTFLabel(rankStr,25)
		rankLabel:setPosition(widthSpace+15,height)
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

		local nameLabel=GetTTFLabel(nameStr,25)
		nameLabel:setPosition(widthSpace+150,height)
		cell:addChild(nameLabel,2)

		local levelLabel=GetTTFLabel(getlocal("fightLevel",{levelStr}),25)
		levelLabel:setPosition(widthSpace+150*2+20,height)
		cell:addChild(levelLabel,2)

		local valueLabel=GetTTFLabel(valueStr,25)
		valueLabel:setPosition(widthSpace+150*3-15,height)
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

function alienMinesRankTab1:tick()
	if alienMinesVoApi:checkIsActive4()==true and alienMinesVoApi:getRefreshRankTime()~=-1 then
		alienMinesVoApi:setRefreshRankTime(-1)
		local function callback(fn,data)
			local ret,sData = base:checkServerData(data)
            if ret==true then
                alienMinesVoApi:setPersonalList(sData.data.ranking)
                alienMinesVoApi:setMcount(sData.data.mcount)
          		self.data = alienMinesVoApi:getPersonalList()
          		self.tv:reloadData()
            end
            
		end
		socketHelper:alienMinesGetRank(1,callback)
	end
end

function alienMinesRankTab1:dispose()
	self.bgLayer=nil
	self.layerNum=nil
	self.tv=nil
	self.limitLb=0
	self.data=nil
end