platWarReportDialogTab1={}

function platWarReportDialogTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
	self.parent=nil

	self.cellHeight=80
	self.hSpace=50
    self.noRecordLb=nil
    self.callbackNum=0
    self.canClick=false
	
    return nc
end

function platWarReportDialogTab1:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
	self.parent=parent
	self:initDesc()
	self:initTableView()
    return self.bgLayer
end

function platWarReportDialogTab1:initDesc()
    local function touch()
    end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),touch)
    backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.bgLayer:getContentSize().height-155-self.hSpace))
    backSprie:ignoreAnchorPointForPosition(false)
    backSprie:setAnchorPoint(ccp(0.5,0))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
    backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,28))
    self.bgLayer:addChild(backSprie)

    local headSprie =LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),touch)
    headSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-70, 45))
    headSprie:ignoreAnchorPointForPosition(false)
    headSprie:setAnchorPoint(ccp(0.5,1))
    headSprie:setIsSallow(false)
    headSprie:setTouchPriority(-(self.layerNum-1)*20-2)
    headSprie:setPosition(ccp(backSprie:getContentSize().width/2,backSprie:getContentSize().height-2))
    backSprie:addChild(headSprie,1)

    local timeLb=GetTTFLabel(getlocal("alliance_event_time"),22)
    timeLb:setPosition(75,headSprie:getContentSize().height/2)
    timeLb:setAnchorPoint(ccp(0.5,0.5))
    headSprie:addChild(timeLb,2)
    timeLb:setColor(G_ColorGreen2)

    local recordLb=GetTTFLabel(getlocal("serverwar_point_record"),22)
    recordLb:setPosition(360,headSprie:getContentSize().height/2)
    recordLb:setAnchorPoint(ccp(0.5,0.5))
    headSprie:addChild(recordLb,2)
    recordLb:setColor(G_ColorGreen2)

    self.noRecordLb=GetTTFLabelWrap(getlocal("plat_war_no_report"),30,CCSizeMake(backSprie:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.noRecordLb:setAnchorPoint(ccp(0.5,0.5))
    self.noRecordLb:setPosition(getCenterPoint(backSprie))
    backSprie:addChild(self.noRecordLb,1)
    self.noRecordLb:setColor(G_ColorYellowPro)
    self.noRecordLb:setVisible(false)

    self:doUserHandler()
end

function platWarReportDialogTab1:initTableView()
	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-60,self.bgLayer:getContentSize().height-120-self.hSpace-45-50),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setAnchorPoint(ccp(0,0))
	self.tv:setPosition(ccp(30,35))
	self.tv:setMaxDisToBottomOrTop(120)
	self.bgLayer:addChild(self.tv)
end

function platWarReportDialogTab1:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
        local hasMore=platWarVoApi:getEventHasMore()
        local num=platWarVoApi:getEventNum()
        if hasMore==true then
            num=num+1
        end
        return num
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        local cellHeight
        local hasMore=platWarVoApi:getEventHasMore()
        local num=platWarVoApi:getEventNum()
        if hasMore and idx==num then
            cellHeight=80
        else
            -- local eventList=platWarVoApi:getEventList()
            -- local vo=eventList[idx+1]
            -- cellHeight=vo.height
            cellHeight=self.cellHeight
        end
        tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-60,cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local hasMore=platWarVoApi:getEventHasMore()
        local num=platWarVoApi:getEventNum()
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick()
            self:cellClick(idx)
        end
        local background
        if hasMore and idx==num then
            background=LuaCCScale9Sprite:createWithSpriteFrameName("ItemBtnMore.png",capInSet,cellClick)
            background:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,80))
            background:ignoreAnchorPointForPosition(false)
            background:setAnchorPoint(ccp(0,0))
            background:setTag(idx)
            background:setIsSallow(false)
            background:setTouchPriority(-(self.layerNum-1)*20-2)
            background:setPosition(ccp(0,0))
            cell:addChild(background,1)
            
            local moreLabel=GetTTFLabel(getlocal("showMore"),30)
            moreLabel:setPosition(getCenterPoint(background))
            background:addChild(moreLabel,2)
            
            return cell
        end

        local eventList=platWarVoApi:getEventList()
        local vo=eventList[idx+1]
        if vo==nil then
            do return end
        end
        local width=vo.width
        -- local height=vo.height
        local height=self.cellHeight
        local message=vo.message
        -- message="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
        local color=vo.color
        local time=vo.time

        local timeStr=platWarVoApi:getTimeStr(time)
        local timeLabel=GetTTFLabel(timeStr,22)
        timeLabel:setAnchorPoint(ccp(0.5,0.5))
        timeLabel:setPosition(ccp(79,height/2))
        cell:addChild(timeLabel,1)

        local textLabel=GetTTFLabelWrap(message,22,CCSizeMake(width,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        textLabel:setAnchorPoint(ccp(0.5,0.5))
        textLabel:setPosition(ccp(370,height/2))
        cell:addChild(textLabel,1)

        timeLabel:setColor(color)
        textLabel:setColor(color)

        local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
        lineSp:setAnchorPoint(ccp(0.5,0.5))
        lineSp:setScale(0.95)
        lineSp:setPosition(ccp(self.bgLayer:getContentSize().width/2-30,0))
        cell:addChild(lineSp)

        return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	end
end

function platWarReportDialogTab1:cellClick(idx)
    if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local num=platWarVoApi:getEventNum()
        local hasMore=platWarVoApi:getEventHasMore()
        local nextHasMore=false
        if hasMore and tostring(idx)==tostring(num) then
            local function eventListCallback()
                self.canClick=true
                local newNum=platWarVoApi:getEventNum()
                local diffNum=newNum-num
                local nextHasMore=platWarVoApi:getEventHasMore()
                if nextHasMore then
                    diffNum=diffNum+1
                end
                local recordPoint = self.tv:getRecordPoint()
                self.tv:reloadData()
                recordPoint.y=-(diffNum-1)*self.cellHeight+recordPoint.y
                self.tv:recoverToRecordPoint(recordPoint)
                self.canClick=false
            end
            if self.canClick==false then
                platWarVoApi:formatEventList(eventListCallback,true)
            end
        end
    end
end

function platWarReportDialogTab1:doUserHandler()
    if self.noRecordLb then
        local pointDetail=platWarVoApi:getEventList()
        local num=SizeOfTable(pointDetail)
        if num==0 then
            self.noRecordLb:setVisible(true)
        else
            self.noRecordLb:setVisible(false)
        end
    end
end

function platWarReportDialogTab1:tick()

end

function platWarReportDialogTab1:refresh()

end

function platWarReportDialogTab1:dispose()
    self.canClick=nil
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
    self.cellHeight=nil
	self.hSpace=nil
    self.noRecordLb=nil
    self.callbackNum=0
end






