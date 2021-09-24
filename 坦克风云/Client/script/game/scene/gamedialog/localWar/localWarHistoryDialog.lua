localWarHistoryDialog=commonDialog:new()

function localWarHistoryDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	self.cellHeight=180
    return nc
end

--设置对话框里的tableView
function localWarHistoryDialog:initTableView()
	self.panelLineBg:setAnchorPoint(ccp(0.5,0))
	self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20,G_VisibleSizeHeight-100))
	self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,20))
	
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-30,self.bgLayer:getContentSize().height-130),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(15,40))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

    local list=localWarVoApi:getCityLogList()
    if list and SizeOfTable(list)==0 then
    	local noReportLb=GetTTFLabelWrap(getlocal("local_war_history_no_report"),30,CCSizeMake(self.bgLayer:getContentSize().width-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	    noReportLb:setAnchorPoint(ccp(0.5,0.5))
		noReportLb:setColor(G_ColorYellowPro)
		noReportLb:setPosition(getCenterPoint(self.bgLayer))
		self.bgLayer:addChild(noReportLb,1)
    end
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function localWarHistoryDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
    	local list=localWarVoApi:getCityLogList()
	    return SizeOfTable(list)
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-20,self.cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local rect = CCRect(0, 0, 50, 50);
		local capInSet = CCRect(40, 40, 10, 10);
		local capInSetNew=CCRect(20, 20, 10, 10)
		local backSprie
		local function cellClick1(hd,fn,idx)
		end
		local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),cellClick1)
		backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-30, self.cellHeight-4))
		backSprie:ignoreAnchorPointForPosition(false)
		backSprie:setAnchorPoint(ccp(0,0))
		backSprie:setIsSallow(false)
		backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		cell:addChild(backSprie,1)

		local cellWidth=self.bgLayer:getContentSize().width-20
		local cellHeight=self.cellHeight
		local list=localWarVoApi:getCityLogList()
		local cityInfo=list[idx+1]
		local index=cityInfo.index or 0
		local time=cityInfo.date or 0
		local hisTime=G_getDataTimeStr(time,true,true)
		local allianceName=cityInfo.aname or ""
		local playerName=cityInfo.commander or ""
		local playerPic=cityInfo.pic or 1
		-- local personPhotoName="photo"..playerPic..".png"
		-- local photoSp=GetBgIcon(personPhotoName)
        local personPhotoName=playerVoApi:getPersonPhotoName(playerPic)
        local photoSp=playerVoApi:GetPlayerBgIcon(personPhotoName)
		photoSp:setScale(1.3)
		photoSp:setAnchorPoint(ccp(0.5,0.5))
		photoSp:setPosition(ccp(70,backSprie:getContentSize().height/2))
		-- local bg=CCSprite:createWithSpriteFrameName("heroHeadBG.png")
		-- bg:setPosition(getCenterPoint(photoSp))
		-- photoSp:addChild(bg,2)
		backSprie:addChild(photoSp,2)
		
		
		local lbPosX=130
		local lbTab={
			{getlocal("local_war_history_king",{index,hisTime}),25,ccp(0,0.5),ccp(lbPosX,cellHeight-40),cell,1,G_ColorYellowPro,CCSize(cellWidth-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
			{getlocal("local_war_history_alliance",{allianceName}),23,ccp(0,0.5),ccp(lbPosX,85),cell,1,G_ColorWhite,CCSize(cellWidth-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
			{getlocal("local_war_history_name",{playerName}),23,ccp(0,0.5),ccp(lbPosX,35),cell,1,G_ColorWhite,CCSize(cellWidth-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
		}
		for k,v in pairs(lbTab) do
			local key,size,anchorPoint,position,parent,zOrder,color,dimensions,hAlignment,vAlignment=v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10]
			GetAllTTFLabel(key,size,anchorPoint,position,parent,zOrder,color,dimensions,hAlignment,vAlignment)
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

function localWarHistoryDialog:dispose()
	self.cellHeight=nil
end





