alienTechDialogSubTab31={}
function alienTechDialogSubTab31:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function alienTechDialogSubTab31:init(layerNum)
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()
	self:initTableView()
	base:addNeedRefresh(self)
	return self.bgLayer
end

function alienTechDialogSubTab31:initTableView()
	local function callBack(...)
		return self:eventHandler3(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight-260),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(25,50)
	self.bgLayer:addChild(self.tv,1)
	self.tv:setMaxDisToBottomOrTop(100)
end

function alienTechDialogSubTab31:eventHandler3(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		local resourceCfg=alienTechCfg.resource
		return SizeOfTable(resourceCfg)
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
    	if G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage() =="in" or G_getCurChoseLanguage() =="tu" or G_getCurChoseLanguage() =="ru" then
			self.cellHight =280
		else
			self.cellHight =180
		end
		tmpSize=CCSizeMake(G_VisibleSizeWidth-30,self.cellHight)
		return tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20,20,10,10),function ()end)
		backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,self.cellHight-5))
		backSprie:ignoreAnchorPointForPosition(false)
		backSprie:setAnchorPoint(ccp(0,0))
		backSprie:setIsSallow(false)
		backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		backSprie:setPosition(ccp(5,0))

		local resourceCfg=alienTechCfg.resource
		local rid="r"..(idx+1)
		local cfg=resourceCfg[rid]
		local iconStr=cfg.icon
		local nameStr=cfg.name
		local descStr=cfg.desc
		local num=alienTechVoApi:getAlienResByType(rid) or 0

		local icon=CCSprite:createWithSpriteFrameName(iconStr)
		icon:setScale(100/icon:getContentSize().height)
		icon:setAnchorPoint(ccp(0.5,0))
		icon:setPosition(ccp(95,50))
		backSprie:addChild(icon)

		local numLb=GetTTFLabel(getlocal("propInfoNum",{FormatNumber(num)}),20)
		numLb:setAnchorPoint(ccp(0.5,0))
		numLb:setPosition(ccp(95,10))
		backSprie:addChild(numLb)
		cell:addChild(backSprie,1)

		local nameLb=GetTTFLabel(getlocal(nameStr),24,true)
		nameLb:setAnchorPoint(ccp(0,1))
		nameLb:setPosition(ccp(190,backSprie:getContentSize().height-10))
		nameLb:setColor(G_ColorGreen)
		backSprie:addChild(nameLb)

		local descLb=GetTTFLabelWrap(getlocal(descStr),20,CCSizeMake(G_VisibleSizeWidth-70-203,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		descLb:setAnchorPoint(ccp(0,0.5))
		descLb:setPosition(ccp(190,(nameLb:getPositionY()-nameLb:getContentSize().height)/2))
		backSprie:addChild(descLb)
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	end
end

function alienTechDialogSubTab31:tick()
	if alienTechVoApi:getResFlag()==0 then
		if self.tv then
			self.tv:reloadData()
		end
		alienTechVoApi:setResFlag(1)
	end
end

function alienTechDialogSubTab31:dispose()
	base:removeFromNeedRefresh(self)
	self.bgLayer:removeFromParentAndCleanup(true)
	self.tv=nil
	self.layerNum=nil
	self.bgLayer=nil
end