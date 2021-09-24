alienMinesTroopsTab2={

}

function alienMinesTroopsTab2:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
    return nc
end

function alienMinesTroopsTab2:init(layerNum)
 	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	return self.bgLayer
end

function alienMinesTroopsTab2:initTableView()

 --    local function callBack(...)
	-- 	return self:eventHandler(...)
	-- end
	-- local hd= LuaEventHandler:createHandler(callBack)
 -- 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-630),nil)
	-- self.tv:setAnchorPoint(ccp(0,0))
	-- self.tv:setPosition(ccp(10,100))
	-- self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	-- self.tv:setMaxDisToBottomOrTop(80)
	-- self.bgLayer:addChild(self.tv)
end

function alienMinesTroopsTab2:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return 4
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-40,150)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease() 

		local rect = CCRect(0, 0, 50, 50);
		local capInSet = CCRect(20, 20, 10, 10);
		local function cellClick(hd,fn,idx)
		end
		local hei=150-4
	   
		local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
		backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-60, hei))
		backSprie:ignoreAnchorPointForPosition(false);
		backSprie:setAnchorPoint(ccp(0,0));
		backSprie:setIsSallow(false)
		backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		backSprie:setPosition(ccp(20,2))
		cell:addChild(backSprie)
		
	   return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end

function alienMinesTroopsTab2:tick()

end

function alienMinesTroopsTab2:dispose()
	self.bgLayer=nil
	self.layerNum=nil
	self.tv=nil
end