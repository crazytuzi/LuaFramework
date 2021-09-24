dimensionalWarShopTab2={}

function dimensionalWarShopTab2:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
    self.parent=nil

    self.cellHeght=80
    self.hSpace=0
    self.noRecordLb=nil
    self.callbackNum=0
    
    return nc
end

function dimensionalWarShopTab2:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self:initDesc()
    self:initTableView()
    return self.bgLayer
end

function dimensionalWarShopTab2:initDesc()
    local str=getlocal("local_war_report_max_num",{userWarCfg.militaryrank})
    local descLb=GetTTFLabelWrap(str,25,CCSizeMake(G_VisibleSizeWidth-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    descLb:setAnchorPoint(ccp(0,0.5))
    descLb:setPosition(ccp(30,60))
    descLb:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(descLb)


    local function touch()
    end
    -- local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),touch)
    local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20, 20, 1, 1),function()end)
    backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.bgLayer:getContentSize().height-325-self.hSpace+50))
    backSprie:ignoreAnchorPointForPosition(false)
    backSprie:setAnchorPoint(ccp(0.5,0))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
    backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,100))
    self.bgLayer:addChild(backSprie)

    local headSprie =LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),touch)
    headSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-70, 38))
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

    self.noRecordLb=GetTTFLabelWrap(getlocal("serverwar_point_no_record"),30,CCSizeMake(backSprie:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.noRecordLb:setAnchorPoint(ccp(0.5,0.5))
    self.noRecordLb:setPosition(getCenterPoint(backSprie))
    backSprie:addChild(self.noRecordLb,1)
    self.noRecordLb:setColor(G_ColorYellowPro)
    -- local pointDetail=dimensionalWarVoApi:getPointDetail()
    -- local num=SizeOfTable(pointDetail)
    -- local addPoint=dimensionalWarVoApi:getDonatePoint()
    -- if (addPoint and addPoint>0) or (num and num>0) then
    --     self.noRecordLb:setVisible(false)
    -- end

    self:doUserHandler()
end

function dimensionalWarShopTab2:initTableView()
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-60,self.bgLayer:getContentSize().height-290-self.hSpace-35),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setAnchorPoint(ccp(0,0))
    self.tv:setPosition(ccp(30,35+70))
    self.tv:setMaxDisToBottomOrTop(120)
    self.bgLayer:addChild(self.tv)
end

function dimensionalWarShopTab2:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local pointDetail=dimensionalWarVoApi:getPointDetail()
        local num=SizeOfTable(pointDetail)
        -- local addPoint=dimensionalWarVoApi:getDonatePoint()
        -- if addPoint and addPoint>0 then
        --     num=num+1
        -- end
        return num
    elseif fn=="tableCellSizeForIndex" then
        local pointDetail=dimensionalWarVoApi:getPointDetail()
        local tmpSize
        tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-60,self.cellHeght)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        -- local addPoint=dimensionalWarVoApi:getDonatePoint()
        local width=400-10
        local height=self.cellHeght
        local message=""
        local color=G_ColorWhite
        local time=0
        local round=0
        local type
        -- if addPoint and addPoint>0 and idx==0 then
        --     message=getlocal("plat_war_point_record_desc_0",{dimensionalWarVoApi:getDonatePoint()})
        --     color=G_ColorGreen
        --     time=base.serverTime
        -- else
            local index
            if addPoint and addPoint>0 then
                index=idx
            else
                index=idx+1
            end
            local pointDetail=dimensionalWarVoApi:getPointDetail()
            if pointDetail then
                local vo=pointDetail[index]
                if vo==nil then
                    do return end
                end
                message=vo.message
                color=vo.color
                time=vo.time
                type=vo.type
                round=vo.round
            end
        -- end

        local timeStr=""
        if type==1 then
            timeStr=G_getDataTimeStr(time)
        else
            timeStr=G_getDataTimeStr(time,nil,true).." "..getlocal("dimensionalWar_round",{round})
        end
        local timeLabel=GetTTFLabel(timeStr,22)
        timeLabel:setAnchorPoint(ccp(0,0.5))
        timeLabel:setPosition(ccp(10,height/2))
        cell:addChild(timeLabel,1)

        local textLabel=GetTTFLabelWrap(message,22,CCSizeMake(width,height),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        textLabel:setAnchorPoint(ccp(0.5,0.5))
        textLabel:setPosition(ccp(370+10,height/2))
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

function dimensionalWarShopTab2:doUserHandler()
    if self.noRecordLb then
        local pointDetail=dimensionalWarVoApi:getPointDetail()
        local num=SizeOfTable(pointDetail)
        -- local addPoint=dimensionalWarVoApi:getDonatePoint()
        -- if (addPoint and addPoint>0) or (num and num>0) then
        if (num and num>0) then
            self.noRecordLb:setVisible(false)
        else
            self.noRecordLb:setVisible(true)
        end
    end
end

function dimensionalWarShopTab2:tick()
    local flag=dimensionalWarVoApi:getPointDetailFlag()
    if self.callbackNum<3 and flag==-1 then
        local function callback()
            self:doUserHandler()
            if self and self.tv then
                self.tv:reloadData()
            end
            dimensionalWarVoApi:setPointDetailFlag(1)
            self.callbackNum=0
        end
        dimensionalWarVoApi:formatPointDetail(callback)
        self.callbackNum=self.callbackNum+1
    elseif flag==0 then
        self:doUserHandler()
        if self and self.tv then
            self.tv:reloadData()
        end
        dimensionalWarVoApi:setPointDetailFlag(1)
    end
end

function dimensionalWarShopTab2:refresh()

end

function dimensionalWarShopTab2:dispose()
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
    self.cellHeght=nil
    self.hSpace=nil
    self.noRecordLb=nil
    self.callbackNum=0
end






