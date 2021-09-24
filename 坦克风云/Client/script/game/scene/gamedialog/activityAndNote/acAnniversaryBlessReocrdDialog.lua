acAnniversaryBlessReocrdDialog=commonDialog:new()

function acAnniversaryBlessReocrdDialog:new()
    local nc={}
    nc.tv=nil
    nc.bgLayer=nil
    nc.layerNum=nil
    nc.parent=nil

    nc.cellHeght=80
    nc.hSpace=50
    nc.noRecordLb=nil
    nc.callbackNum=0
    nc.recordList=nil
    nc.recordCount=0
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function acAnniversaryBlessReocrdDialog:initDesc()
    local function touch()
    end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),touch)
    backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-30,G_VisibleSize.height-100))
    backSprie:ignoreAnchorPointForPosition(false)
    backSprie:setAnchorPoint(ccp(0.5,0))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
    backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,15))
    self.bgLayer:addChild(backSprie)

    local headSprie =LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),touch)
    headSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-70,38))
    headSprie:ignoreAnchorPointForPosition(false)
    headSprie:setAnchorPoint(ccp(0.5,1))
    headSprie:setIsSallow(false)
    headSprie:setTouchPriority(-(self.layerNum-1)*20-2)
    headSprie:setPosition(ccp(backSprie:getContentSize().width/2,backSprie:getContentSize().height-2))
    backSprie:addChild(headSprie,1)

    local timeLb=GetTTFLabel(getlocal("alliance_event_time"),22)
    timeLb:setPosition(70,headSprie:getContentSize().height/2)
    timeLb:setAnchorPoint(ccp(0.5,0.5))
    headSprie:addChild(timeLb,2)
    timeLb:setColor(G_ColorGreen2)

    local recordLb=GetTTFLabel(getlocal("serverwar_point_record"),22)
    recordLb:setPosition(360,headSprie:getContentSize().height/2)
    recordLb:setAnchorPoint(ccp(0.5,0.5))
    headSprie:addChild(recordLb,2)
    recordLb:setColor(G_ColorGreen2)

    self.noRecordLb=GetTTFLabelWrap(getlocal("bless_donate_norecord"),30,CCSizeMake(backSprie:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.noRecordLb:setAnchorPoint(ccp(0.5,0.5))
    self.noRecordLb:setPosition(getCenterPoint(backSprie))
    backSprie:addChild(self.noRecordLb,1)
    self.noRecordLb:setColor(G_ColorYellowPro)

    if self.noRecordLb then
        self.recordList=acAnniversaryBlessVoApi:getRecordList()
        self.recordCount=SizeOfTable(self.recordList)
        if (self.recordCount and self.recordCount>0) then
            self.noRecordLb:setVisible(false)
        else
            self.noRecordLb:setVisible(true)
        end
    end

    local tipBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),function () end)
    tipBg:setContentSize(CCSizeMake(backSprie:getContentSize().width,60))
    tipBg:setAnchorPoint(ccp(0.5,0))
    tipBg:setPosition(ccp(backSprie:getContentSize().width/2,5))
    backSprie:addChild(tipBg,2)

    local str=getlocal("allianceWar2_limitNumLog",{50})
    local descLb=GetTTFLabelWrap(str,25,CCSizeMake(G_VisibleSizeWidth-150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    descLb:setAnchorPoint(ccp(0.5,0.5))
    descLb:setPosition(ccp(tipBg:getContentSize().width/2,tipBg:getContentSize().height/2))
    descLb:setColor(G_ColorYellowPro)
    tipBg:addChild(descLb)

    self:doUserHandler()

    local function callBack(...)
        return self:eventHandler(...)
    end
    local tvHeight=backSprie:getContentSize().height-headSprie:getContentSize().height-tipBg:getContentSize().height-10
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-60,tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setAnchorPoint(ccp(0,0))
    self.tv:setPosition(ccp(15,tipBg:getContentSize().height+5))
    self.tv:setMaxDisToBottomOrTop(120)
    backSprie:addChild(self.tv)
end

function acAnniversaryBlessReocrdDialog:initTableView()
    self.panelLineBg:setVisible(false)
    self:initDesc()
end

function acAnniversaryBlessReocrdDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
        return self.recordCount
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-60,self.cellHeght)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local record = self.recordList[idx+1] --{type,name,wordkey,ts}
        local name=""
        local color=G_ColorYellowPro
        local recordStr=""
        local wordName = acAnniversaryBlessVoApi:getWordName(record[3])
        if record[1]==1 then --赠送给别人的记录
            name=record[2]--接收者昵称
            color=G_ColorWhite
            recordStr=getlocal("activity_anniversaryBless_prompt9",{name,wordName})
        else --别人赠送给我
            name=record[2]--赠送者名字
            recordStr=getlocal("activity_anniversaryBless_prompt10",{name,wordName})
        end
        local width=400
        local height=self.cellHeght

        local timeStr=acAnniversaryBlessVoApi:getRecordTimeStr(record[4])
        local timeLabel=GetTTFLabel(timeStr,22)
        timeLabel:setAnchorPoint(ccp(0.5,0.5))
        timeLabel:setPosition(ccp(79,height/2))
        cell:addChild(timeLabel,1)

        local textLabel=GetTTFLabelWrap(recordStr,22,CCSizeMake(width,height),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
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

function acAnniversaryBlessReocrdDialog:doUserHandler()

end

function acAnniversaryBlessReocrdDialog:tick()
end

function acAnniversaryBlessReocrdDialog:refresh()
end

function acAnniversaryBlessReocrdDialog:dispose()
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
    self.cellHeght=nil
	self.hSpace=nil
    self.noRecordLb=nil
    self.callbackNum=0
    self.recordList=nil
    self.recordCount=0
end