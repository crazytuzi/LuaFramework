allianceHelpTab3={}

function allianceHelpTab3:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
	self.parent=nil

	self.cellHeght=80
	self.hSpace=50
    self.noRecordLb=nil
    self.callbackNum=0
    self.curIndex=3
	
    return nc
end

function allianceHelpTab3:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
	self.parent=parent
	self:initDesc()
	self:initTableView()
    return self.bgLayer
end

function allianceHelpTab3:initDesc()
	-- local str=getlocal("serverwar_shop_desc3")
	-- local descLb=GetTTFLabelWrap(str,25,CCSizeMake(G_VisibleSizeWidth-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	-- descLb:setAnchorPoint(ccp(0,0.5))
	-- descLb:setPosition(ccp(30,G_VisibleSizeHeight-225-self.hSpace-20))
	-- descLb:setColor(G_ColorYellowPro)
	-- self.bgLayer:addChild(descLb)


    local function touch()
    end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),touch)
    backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40, self.bgLayer:getContentSize().height-150-self.hSpace))
    backSprie:ignoreAnchorPointForPosition(false)
    backSprie:setAnchorPoint(ccp(0.5,0))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
    backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,28))
    self.bgLayer:addChild(backSprie)

    local headSprie =LuaCCScale9Sprite:createWithSpriteFrameName("ltzdzNameBg.png",CCRect(4, 4, 1, 1),function () end)
    headSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40, 38))
    headSprie:ignoreAnchorPointForPosition(false)
    headSprie:setAnchorPoint(ccp(0.5,1))
    headSprie:setIsSallow(false)
    headSprie:setTouchPriority(-(self.layerNum-1)*20-2)
    headSprie:setPosition(ccp(backSprie:getContentSize().width/2,backSprie:getContentSize().height-2))
    backSprie:addChild(headSprie,1)

    local timeLb=GetTTFLabel(getlocal("alliance_event_time"),22,true)
    timeLb:setPosition(75,headSprie:getContentSize().height/2)
    timeLb:setAnchorPoint(ccp(0.5,0.5))
    headSprie:addChild(timeLb,2)
    timeLb:setColor(G_ColorYellowPro2)

    local recordLb=GetTTFLabel(getlocal("serverwar_point_record"),22,true)
    recordLb:setPosition(355,headSprie:getContentSize().height/2)
    recordLb:setAnchorPoint(ccp(0.5,0.5))
    headSprie:addChild(recordLb,2)
    recordLb:setColor(G_ColorYellowPro2)

    self.noRecordLb=GetTTFLabelWrap(getlocal("plat_war_no_report"),30,CCSizeMake(backSprie:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    self.noRecordLb:setAnchorPoint(ccp(0.5,0.5))
    self.noRecordLb:setPosition(getCenterPoint(backSprie))
    backSprie:addChild(self.noRecordLb,1)
    self.noRecordLb:setColor(G_ColorGray)
    self.noRecordLb:setVisible(false)

    self:doUserHandler()
end

function allianceHelpTab3:initTableView()
	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-40,self.bgLayer:getContentSize().height-200-self.hSpace),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setAnchorPoint(ccp(0,0))
	self.tv:setPosition(ccp(20,33))
	self.tv:setMaxDisToBottomOrTop(120)
	self.bgLayer:addChild(self.tv)
end

function allianceHelpTab3:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
        -- local pointDetail=serverWarPersonalVoApi:getPointDetail()
        -- local num=SizeOfTable(pointDetail)
        -- -- local isHasMore=serverWarPersonalVoApi:isHasMore()
        -- -- if isHasMore then
        -- --     num=num+1
        -- -- end
        local num=SizeOfTable(allianceHelpVoApi:getList(self.curIndex))
        return num
    elseif fn=="tableCellSizeForIndex" then
        -- local pointDetail=serverWarPersonalVoApi:getPointDetail()
        -- local isHasMore=serverWarPersonalVoApi:isHasMore()
        local tmpSize
        tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-40,self.cellHeght)
        -- if isHasMore then
        --     local num=SizeOfTable(pointDetail)
        --     if idx==num then
        --         tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-60,80)
        --     end
        -- end
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,self.cellHeght))

        local grayBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png",CCRect(4,4,1,1),function ()end)
        grayBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,cell:getContentSize().height))
        grayBgSp:setAnchorPoint(ccp(0.5,1))
        grayBgSp:setPosition(ccp(cell:getContentSize().width/2,cell:getContentSize().height))
        cell:addChild(grayBgSp) 

        if (idx+1)%2 == 1 then
          grayBgSp:setOpacity(0)
        end
        -- local pointDetail=serverWarPersonalVoApi:getPointDetail()
        -- local num=SizeOfTable(pointDetail)
        -- if num<=0 then
        --     do return end
        -- end
        -- local isHasMore=serverWarPersonalVoApi:isHasMore()
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd,fn,idx)
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                PlayEffect(audioCfg.mouseClick)
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end

                -- local function GeteventsCallback(fn,data)
                --     local ret,sData=base:checkServerData(data)
                --     if ret==true then
                --         if sData and sData.data and sData.data.alliance and sData.data.alliance.events then
                --             local addHeight=serverWarPersonalVoApi:formatData(sData.data.alliance.events)
                --             local newHasMore=serverWarPersonalVoApi:isHasMore()
                --             if serverWarPersonalVoApi:getPage()>=1 then
                --                 local recordPoint = self.tv:getRecordPoint()
                --                 recordPoint.y=recordPoint.y-addHeight
                --                 if newHasMore==false then
                --                     recordPoint.y=recordPoint.y+80
                --                 end
                --                 self.tv:reloadData()
                --                 self.tv:recoverToRecordPoint(recordPoint)
                --             else
                --                 self.tv:reloadData()
                --             end
                --         end
                --     end
                -- end
                -- local page=serverWarPersonalVoApi:getPage()
                -- socketHelper:allianceGetevents(page,GeteventsCallback)
            end
        end
        local backSprie
        -- if isHasMore and idx==num then
        --     backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("ItemBtnMore.png",capInSet,cellClick)
        --     backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-70, 80))
        --     backSprie:ignoreAnchorPointForPosition(false);
        --     backSprie:setAnchorPoint(ccp(0.5,0.5));
        --     backSprie:setTag(idx)
        --     backSprie:setIsSallow(false)
        --     backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        --     backSprie:setPosition(ccp((self.bgLayer:getContentSize().width-70)/2,backSprie:getContentSize().height/2))
        --     -- cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, 80))
        --     cell:addChild(backSprie,1)
            
        --     local moreLabel=GetTTFLabel(getlocal("showMore"),22)
        --     moreLabel:setPosition(getCenterPoint(backSprie))
        --     backSprie:addChild(moreLabel,2)
            
        --     do return cell end
        -- end

        local list=allianceHelpVoApi:getList(self.curIndex)
        local vo=list[idx+1]
        if vo==nil then
            do return end
        end
        local width=400
        local height=self.cellHeght
        local message=vo.message
        local color=vo.color
        local time=vo.time
        
        local timeStr=G_getDataTimeStr(time)
        local timeLabel=GetTTFLabel(timeStr,22,true)
        timeLabel:setAnchorPoint(ccp(0.5,0.5))
        timeLabel:setPosition(ccp(79,height/2))
        grayBgSp:addChild(timeLabel,1)

        local textLabel=GetTTFLabelWrap(message,22,CCSizeMake(width,height),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
        textLabel:setAnchorPoint(ccp(0.5,0.5))
        textLabel:setPosition(ccp(370,height/2))
        grayBgSp:addChild(textLabel,1)

        timeLabel:setColor(color)
        textLabel:setColor(color)

        -- local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
        -- lineSp:setAnchorPoint(ccp(0.5,0.5))
        -- lineSp:setScale(0.95)
        -- lineSp:setPosition(ccp(self.bgLayer:getContentSize().width/2-30,0))
        -- grayBgSp:addChild(lineSp)

        return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	end
end

function allianceHelpTab3:doUserHandler()
    if self.noRecordLb then
        local list=allianceHelpVoApi:getList(self.curIndex)
        local num=SizeOfTable(list)
        if num==0 then
            self.noRecordLb:setVisible(true)
        else
            self.noRecordLb:setVisible(false)
        end
    end
end

function allianceHelpTab3:tick()
	local flag=allianceHelpVoApi:getFlag(self.curIndex)
    -- local detailExpireTime=serverWarPersonalVoApi:getDetailExpireTime()
    -- if (self.callbackNum<3 and ((detailExpireTime and detailExpireTime>0 and base.serverTime>=detailExpireTime) or flag==-1)) then
    if self.callbackNum<3 and flag==-1 then
        local function callback()
            self:doUserHandler()
            if self and self.tv then
                self.tv:reloadData()
            end
            self.callbackNum=0
        end
        allianceHelpVoApi:formatData(self.curIndex,callback)
        self.callbackNum=self.callbackNum+1
    elseif flag==0 then
        self:doUserHandler()
        if self and self.tv then
            self.tv:reloadData()
        end
        allianceHelpVoApi:setFlag(self.curIndex,1)
    end
end

function allianceHelpTab3:refresh()

end

function allianceHelpTab3:dispose()
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
    self.cellHeght=nil
	self.hSpace=nil
    self.noRecordLb=nil
    self.callbackNum=0
    self.curIndex=3
end






