local believerExchangeTroopRecordDialog=commonDialog:new()

function believerExchangeTroopRecordDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    nc.recordList=nil
    nc.recordNum=0

    return nc
end

function believerExchangeTroopRecordDialog:initDesc()
    self.panelLineBg:setVisible(false)
    self.panelTopLine:setVisible(true)
    self.panelTopLine:setPositionY(G_VisibleSizeHeight-82)

    local fontSize=25
    if G_getCurChoseLanguage()~="cn" and G_getCurChoseLanguage()~="tw" then
        fontSize=22
    end

    local function touch()
    end
    local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),touch)
    backSprie:setContentSize(CCSizeMake(616, self.bgLayer:getContentSize().height-123))
    backSprie:setAnchorPoint(ccp(0.5,0))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
    backSprie:setPosition(ccp(G_VisibleSizeWidth/2,28))
    self.bgLayer:addChild(backSprie)

    local headSprie=LuaCCScale9Sprite:createWithSpriteFrameName("newRankTitleBg.png",CCRect(4,4,1,1),touch)
    headSprie:setContentSize(CCSizeMake(612, 40))
    headSprie:ignoreAnchorPointForPosition(false)
    headSprie:setAnchorPoint(ccp(0.5,1))
    headSprie:setIsSallow(false)
    headSprie:setTouchPriority(-(self.layerNum-1)*20-2)
    headSprie:setPosition(ccp(backSprie:getContentSize().width/2,backSprie:getContentSize().height-2))
    backSprie:addChild(headSprie,1)

    local timeLb=GetTTFLabel(getlocal("alliance_event_time"),fontSize)
    timeLb:setPosition(95,headSprie:getContentSize().height/2)
    timeLb:setAnchorPoint(ccp(0.5,0.5))
    headSprie:addChild(timeLb,2)
    timeLb:setColor(G_ColorBlue)

    local recordLb=GetTTFLabel(getlocal("serverwar_point_record"),fontSize)
    recordLb:setPosition(390,headSprie:getContentSize().height/2)
    recordLb:setAnchorPoint(ccp(0.5,0.5))
    headSprie:addChild(recordLb,2)
    recordLb:setColor(G_ColorBlue)

    local noRecordLb=GetTTFLabelWrap(getlocal("serverwar_point_no_record"),30,CCSizeMake(backSprie:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    noRecordLb:setAnchorPoint(ccp(0.5,0.5))
    noRecordLb:setPosition(getCenterPoint(backSprie))
    backSprie:addChild(noRecordLb,1)
    noRecordLb:setColor(G_ColorYellowPro)
    noRecordLb:setVisible(false)

    --取得记录数据
    local recordData=believerVoApi:getTroopsExchangeRecordList()
    self.recordList,self.cellHeightTb={},{}
    local fontWidth=340
    -- 遍历记录，每一行的高度
    for k,v in pairs(recordData) do
        local recordType=v[1]
        local recordStr,height="",20
        for kk,vv in pairs(v[2]) do
            if recordType==0 then --手动兑换的
                local tankId=tonumber(RemoveFirstChar(vv[1]))
                local tankName=getlocal(tankCfg[tankId].name)
                recordStr=recordStr..getlocal("believer_troop_exchange_record_use",{vv[2],tankName,vv[3],tankName}).."\n"
            else --系统赠送的
                local tankId=tonumber(RemoveFirstChar(kk))
                local tankName=getlocal(tankCfg[tankId].name)
                recordStr=recordStr..tankName.."x"..vv.."\n"
            end
        end
        local recordLb=GetTTFLabelWrap(recordStr,fontSize-2,CCSizeMake(fontWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        height=height+recordLb:getContentSize().height
        if recordType==1 then --系统赠送的
            local lb=GetTTFLabelWrap(getlocal("believer_troop_exchange_record_give"),fontSize,CCSizeMake(fontWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            height=height+lb:getContentSize().height+5
        end
        self.cellHeightTb[k]=height
        table.insert(self.recordList,{v[1],recordStr,G_getDataTimeStr(v[3],true)})
    end
    -- 统计行数
    self.recordNum=SizeOfTable(self.recordList)
    if self.recordNum==0 then
        noRecordLb:setVisible(true)
    else
        noRecordLb:setVisible(false)
    end
end

function believerExchangeTroopRecordDialog:doUserHandler()
    self:initDesc()
end

function believerExchangeTroopRecordDialog:initTableView()
    self.tvWidth,self.tvHeight=616,G_VisibleSizeHeight-170
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setAnchorPoint(ccp(0,0))
    self.tv:setPosition((G_VisibleSizeWidth-self.tvWidth)/2,30)
    self.tv:setMaxDisToBottomOrTop(120)
    self.bgLayer:addChild(self.tv)
end

function believerExchangeTroopRecordDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return self.recordNum
    elseif fn=="tableCellSizeForIndex" then
        return CCSizeMake(self.tvWidth,self.cellHeightTb[idx+1])
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local record=self.recordList[idx+1]
        if record==nil then
            do return cell end
        end
        local recordType,recordStr,recordTimeStr=record[1],record[2],record[3]
        local cellWidth,cellHeight=self.tvWidth,self.cellHeightTb[idx+1]

        local fontWidth,fontSize=340,25
        if G_getCurChoseLanguage()~="cn" and G_getCurChoseLanguage()~="tw" then
            fontSize=22
        end
        local timeLb=GetTTFLabelWrap(recordTimeStr,fontSize,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        timeLb:setAnchorPoint(ccp(0,1))
        timeLb:setPosition(ccp(10,cellHeight-15))
        cell:addChild(timeLb,1)

        local posX,posY=0,cellHeight-15
        if recordType==1 then --系统赠送
            local titleLb=GetTTFLabelWrap(getlocal("believer_troop_exchange_record_give"),fontSize,CCSizeMake(fontWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            titleLb:setAnchorPoint(ccp(0.5,1))
            titleLb:setPosition(ccp(400,posY))
            cell:addChild(titleLb,1)
            posY=posY-titleLb:getContentSize().height-5
        end

        local recordLb=GetTTFLabelWrap(recordStr,fontSize-2,CCSizeMake(fontWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        recordLb:setAnchorPoint(ccp(0.5,1))
        recordLb:setPosition(ccp(400+posX,posY))
        if recordType==1 then
            recordLb:setColor(G_ColorYellowPro)
        else
            recordLb:setColor(G_ColorBlue)
        end
        cell:addChild(recordLb,1)

        local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function ()end)
        lineSp:setContentSize(CCSizeMake(cellWidth-10,2))
        lineSp:setRotation(180)
        lineSp:setPosition(cellWidth/2,1)
        cell:addChild(lineSp,1)

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
    end
end

function believerExchangeTroopRecordDialog:tick()
end

function believerExchangeTroopRecordDialog:refresh()
end

function believerExchangeTroopRecordDialog:dispose()
    self.recordList=nil
    self.recordNum=nil
    self=nil
end

return believerExchangeTroopRecordDialog