alienTechDialogSubTab34={}
function alienTechDialogSubTab34:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.cellHight={}
	return nc
end

function alienTechDialogSubTab34:init(layerNum)
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()
	self:initTableView()
	return self.bgLayer
end

function alienTechDialogSubTab34:initTableView()
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

function alienTechDialogSubTab34:getCellHeight(index)
	-- if self.cellHight==nil or self.cellHight==0 then
	if self.cellHight[index]==nil then
		self.cellHight[index]=10
		-- for i=1,8 do
		 	local titleLb=GetAllTTFLabel(getlocal("alien_tech_faq_title_"..index),24,ccp(0,1),ccp(10,0),nil,1,G_ColorGreen,CCSize(G_VisibleSizeWidth-60-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
		 	local descLb=GetAllTTFLabel(getlocal("alien_tech_faq_desc_"..index),20,ccp(0,1),ccp(10,0),nil,1,G_ColorWhite,CCSize(G_VisibleSizeWidth-60-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		 	self.cellHight[index]=self.cellHight[index]+titleLb:getContentSize().height+10+descLb:getContentSize().height+20
		-- end
		self.cellHight[index]=self.cellHight[index]+10
	end
	return self.cellHight[index]
end

function alienTechDialogSubTab34:eventHandler3(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return 8
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize=CCSizeMake(G_VisibleSizeWidth-30,self:getCellHeight(idx+1))
		return tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local cellHeight=self:getCellHeight(idx+1)

		local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20,20,10,10),function ()end)
		backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,cellHeight-5))
		backSprie:ignoreAnchorPointForPosition(false)
		backSprie:setAnchorPoint(ccp(0,0))
		backSprie:setIsSallow(false)
		backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		backSprie:setPosition(ccp(5,0))
		cell:addChild(backSprie,1)
		backSprie:setOpacity(0)

		local bgWidth=backSprie:getContentSize().width
		local bgHeight=backSprie:getContentSize().height
		local lbPosY=bgHeight-10
		-- for i=1,8 do
		 	local titleLb=GetAllTTFLabel(getlocal("alien_tech_faq_title_"..(idx+1)),24,ccp(0,1),ccp(10,lbPosY),backSprie,1,G_ColorGreen,CCSize(bgWidth-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
		 	lbPosY=lbPosY-titleLb:getContentSize().height-10
		 	local descLb=GetAllTTFLabel(getlocal("alien_tech_faq_desc_"..(idx+1)),20,ccp(0,1),ccp(10,lbPosY),backSprie,1,G_ColorWhite,CCSize(bgWidth-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		 	lbPosY=lbPosY-descLb:getContentSize().height-20
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

function alienTechDialogSubTab34:tick()

end

function alienTechDialogSubTab34:dispose()
	self.bgLayer:removeFromParentAndCleanup(true)
	self.cellHight={}
	self.tv=nil
	self.layerNum=nil
	self.bgLayer=nil
end