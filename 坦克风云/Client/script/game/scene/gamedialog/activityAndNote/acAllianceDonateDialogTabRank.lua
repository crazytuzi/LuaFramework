acAllianceDonateDialogTabRank={}

function acAllianceDonateDialogTabRank:new(parent)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.parent=parent
	self.cellHeight=80
	self.tvWidth=G_VisibleSizeWidth-60
	self.tvHeight=G_VisibleSizeHeight-155-70
	self.unitWith=self.tvWidth/20
	return nc
end

function acAllianceDonateDialogTabRank:init(layerNum)
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()
	self:initWithData()
	return self.bgLayer
end

function acAllianceDonateDialogTabRank:initWithData()
	self.list=acAllianceDonateVoApi:getRankList()

	local rankLb=GetTTFLabel(getlocal("rank"),25)
	rankLb:setPosition(ccp(30+self.unitWith*2,G_VisibleSizeHeight-190))
	rankLb:setColor(G_ColorGreen)
	self.bgLayer:addChild(rankLb)

	local nameLb=GetTTFLabel(getlocal("alliance_list_scene_name"),25)
	nameLb:setPosition(ccp(30+self.unitWith*7,G_VisibleSizeHeight-190))
	nameLb:setColor(G_ColorGreen)
	self.bgLayer:addChild(nameLb)

	local numLb=GetTTFLabel(getlocal("alliance_scene_member_num"),25)
	numLb:setPosition(ccp(30+self.unitWith*12,G_VisibleSizeHeight-190))
	numLb:setColor(G_ColorGreen)
	self.bgLayer:addChild(numLb)

	local donateLb=GetTTFLabelWrap(getlocal("alliance_donateAll"),25,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	donateLb:setPosition(ccp(30+self.unitWith*17,G_VisibleSizeHeight-190))
	donateLb:setColor(G_ColorGreen)
	self.bgLayer:addChild(donateLb)

	local function eventHandler( ... )
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(eventHandler)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
	self.tv:setAnchorPoint(ccp(0,0))
	self.tv:setPosition(ccp(30,10))
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	self.tv:setMaxDisToBottomOrTop(100)
	self.bgLayer:addChild(self.tv)
end

function acAllianceDonateDialogTabRank:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return #self.list
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(G_VisibleSizeWidth-60,self.cellHeight)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local cellData=self.list[idx+1]
		local selfAlliance=allianceVoApi:getSelfAlliance()
		local backSprie
		local function nilFunc()
		end
		if(idx==0)then
			backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png",CCRect(20, 20, 10, 10),nilFunc)
		else
    	    if(cellData.rank>3)then
	            backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png",CCRect(20, 20, 10, 10),nilFunc)
        	else
    	        backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank"..cellData.rank.."ItemBg.png",CCRect(20, 20, 10, 10),nilFunc)
	        end
		end
		backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,self.cellHeight-4))
		backSprie:setAnchorPoint(ccp(0,0.5))
		backSprie:setPosition(ccp(0,self.cellHeight/2))
		cell:addChild(backSprie)
		local rankSign
		if(type(cellData.rank)=="string" or cellData.rank>3)then
			rankSign=GetTTFLabel(cellData.rank,25)
		else
			rankSign=CCSprite:createWithSpriteFrameName("top"..tostring(cellData.rank)..".png")
			rankSign:setScale(0.7)
		end
		rankSign:setPosition(ccp(self.unitWith*2,self.cellHeight/2))
		cell:addChild(rankSign,2)

		local nameLb=GetTTFLabel(cellData.name,25)
		nameLb:setPosition(ccp(self.unitWith*7,self.cellHeight/2))
		cell:addChild(nameLb,2)

		local numLb=GetTTFLabel(cellData.num,25)
		numLb:setPosition(ccp(self.unitWith*12,self.cellHeight/2))
		cell:addChild(numLb)

		local donateLb=GetTTFLabel(cellData.donate,25)
		donateLb:setPosition(ccp(self.unitWith*17,self.cellHeight/2))
		cell:addChild(donateLb)

		local lineSP =CCSprite:createWithSpriteFrameName("LineCross.png");
		lineSP:setAnchorPoint(ccp(0.5,0))
		lineSP:setScaleX((G_VisibleSizeWidth-60)/lineSP:getContentSize().width)
		lineSP:setPosition(ccp((G_VisibleSizeWidth-60)/2,0))
		cell:addChild(lineSP,1)
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end