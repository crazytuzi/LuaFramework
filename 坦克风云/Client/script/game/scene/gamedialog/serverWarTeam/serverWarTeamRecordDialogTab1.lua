serverWarTeamRecordDialogTab1={

}

function serverWarTeamRecordDialogTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    self.tv=nil;
    self.tv2=nil;

    self.bgLayer=nil;
    self.layerNum=nil;
    self.allTabs={};
    
    -- self.bgLayer1=nil;
    -- self.bgLayer2=nil;

    self.selectedTabIndex=0;
    self.parentDialog=nil;

    self.cellHeightTab={}
    -- self.cellHeightTab2={}

    self.canSand=true
    self.noRecordLb=nil

    self.roundIndex=nil
    self.battleID=nil
    self.isBattle=nil
    self.page=1

    return nc;

end

function serverWarTeamRecordDialogTab1:init(layerNum,parentDialog,roundIndex,battleID,isBattle)
    self.layerNum=layerNum
    self.parentDialog=parentDialog
    self.roundIndex=roundIndex
    self.battleID=battleID
    self.isBattle=isBattle
    self.bgLayer=CCLayer:create()
    
    self:initTabLayer();

    return self.bgLayer
end

function serverWarTeamRecordDialogTab1:initTabLayer()
    -- self:resetTab()

    local rect = CCRect(0, 0, 50, 50);
    local capInSet = CCRect(20, 20, 10, 10);
    local function click(hd,fn,idx)
    end
    self.tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,click)
    self.tvBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-345+15+30))
    self.tvBg:ignoreAnchorPointForPosition(false)
    self.tvBg:setAnchorPoint(ccp(0.5,0))
    --self.tvBg:setIsSallow(false)
    --self.tvBg:setTouchPriority(-(self.layerNum-1)*20-2)
    self.tvBg:setPosition(ccp(G_VisibleSizeWidth/2,100-70))
    self.bgLayer:addChild(self.tvBg)

    self.noRecordLb=GetTTFLabelWrap(getlocal("alliance_war_no_record"),30,CCSizeMake(self.tvBg:getContentSize().width-50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.noRecordLb:setAnchorPoint(ccp(0.5,0.5))
    self.noRecordLb:setPosition(ccp(self.tvBg:getContentSize().width/2,self.tvBg:getContentSize().height/2+30))
    self.tvBg:addChild(self.noRecordLb)
    self.noRecordLb:setColor(G_ColorGray)
    self.noRecordLb:setVisible(false)

    local function getRecordTabHandler()
        if self then
            -- if self.parentDialog then
            --     self.parentDialog:updateDestroyNum()
            -- end
            self:initTableView()
            -- serverWarTeamVoApi:setRFlag(1)
        end
    end
    serverWarTeamVoApi:getRecordTabByPage(self.roundIndex,self.battleID,self.page,getRecordTabHandler,nil,self.isBattle)

end

function serverWarTeamRecordDialogTab1:initTableView()
    if self.tv then
        self.cellHeightTab={}
        self.tv:reloadData()
    else
        local function callBack(...)
           return self:eventHandler(...)
        end
        local hd= LuaEventHandler:createHandler(callBack)
        local height=0;
        self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-345+5+30),nil)
        -- self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
        self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
        self.tv:setPosition(ccp(25,100-65))
        self.bgLayer:addChild(self.tv)
        self.tv:setMaxDisToBottomOrTop(120)
    end
    self:doUserHandler()
    -- serverWarTeamVoApi:setHasNew(false)
end

function serverWarTeamRecordDialogTab1:getCellHeight(index)
    if self.cellHeightTab[index]==nil then
        local lbSize=22
        local lbWidth=self.bgLayer:getContentSize().width-70
        local lbHeight=30+40

        local record=serverWarTeamVoApi:getRecordByIndex(self.roundIndex,self.battleID,index)
        if record==nil or SizeOfTable(record)==0 then
            do return 0 end
        end

        local descStr,color=serverWarTeamVoApi:getBattleDesc(record)
        local recordDescLb=GetTTFLabelWrap(descStr,lbSize,CCSizeMake(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)

        local cellHeight=recordDescLb:getContentSize().height+lbHeight

        self.cellHeightTab[index]=cellHeight
    end

    return self.cellHeightTab[index]
end

function serverWarTeamRecordDialogTab1:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then   
        local num=serverWarTeamVoApi:getRecordNum(self.roundIndex,self.battleID,self.page)
        local hasMore=serverWarTeamVoApi:hasMore(self.roundIndex,self.battleID,self.page)
        if hasMore then
            num=num+1
        end
        -- print("num",num)
        return num
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-50,100)
        local num=serverWarTeamVoApi:getRecordNum(self.roundIndex,self.battleID,self.page)
        local hasMore=serverWarTeamVoApi:hasMore(self.roundIndex,self.battleID,self.page)
        if hasMore and idx+1==num+1 then
            tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-50,100)
        else
            tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-50,self:getCellHeight(idx+1))
        end
        return tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local index=idx+1
        local num=serverWarTeamVoApi:getRecordNum(self.roundIndex,self.battleID,self.page)        

        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd,fn,idx)
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)

                local function getRecordTabHandler()
                    if self then
                        self.page=self.page+1
                        -- if self.parentDialog then
                        --     self.parentDialog:updateDestroyNum()
                        -- end
                        self:refreshTableView()
                    end
                end
                serverWarTeamVoApi:getRecordTabByPage(self.roundIndex,self.battleID,self.page+1,getRecordTabHandler)
            end
        end

        local hasMore=serverWarTeamVoApi:hasMore(self.roundIndex,self.battleID,self.page)
        local backSprie
        if hasMore and index==num+1 then
            backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("ItemBtnMore.png",capInSet,cellClick)
            backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, 100-5))
            backSprie:ignoreAnchorPointForPosition(false)
            backSprie:setAnchorPoint(ccp(0,0))
            backSprie:setPosition(0,5)
            backSprie:setIsSallow(false)
            backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
            backSprie:setTag(index)
            cell:addChild(backSprie,1)
            
            local moreLabel=GetTTFLabel(getlocal("showMoreTen"),30)
            moreLabel:setPosition(getCenterPoint(backSprie))
            backSprie:addChild(moreLabel,2)
            do return cell end
        end

        local record=serverWarTeamVoApi:getRecordByIndex(self.roundIndex,self.battleID,index)
        if record==nil or SizeOfTable(record)==0 then
            do return cell end
        end

        local cellHeight=self:getCellHeight(index)

        local lbSize=22
        local lbWidth=self.bgLayer:getContentSize().width-70
        local lbX=5
        local lbHeight=20
        local lbSpace=5

        local function cellClick1(hd,fn,idx)
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                
                --播放战斗动画
                if record and record.report and type(record.report)=="table" and SizeOfTable(record.report)>0 then
                    if serverWarTeamOutScene and serverWarTeamOutScene.setVisible then
                        serverWarTeamOutScene:setVisible(false)
                    end
                    local serverWarTeam=1
                    local data={data={report=record.report},isReport=true,serverWarTeam=serverWarTeam}
                    battleScene:initData(data)
                end
            end
        end
        backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),cellClick1)
        backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50,cellHeight))
        backSprie:ignoreAnchorPointForPosition(false)
        backSprie:setAnchorPoint(ccp(0,0))
        backSprie:setPosition(0,5)
        backSprie:setIsSallow(false)
        backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        cell:addChild(backSprie)
        -- backSprie:setOpacity(0)

        local headBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(30,0,60,36),function ()end)
        headBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50,40))
        headBg:setAnchorPoint(ccp(0.5,1))
        headBg:setPosition(ccp((self.bgLayer:getContentSize().width-50)/2,cellHeight))
        cell:addChild(headBg)

        local nameBg=CCSprite:createWithSpriteFrameName("platWarNameBg1.png")
        nameBg:setAnchorPoint(ccp(0,1))
        nameBg:setPosition(ccp(0,cellHeight))
        cell:addChild(nameBg)

        local timeStr=G_getDataTimeStr(record.time)
        local areaIndex=record.placeIndex
        local areaName=serverWarTeamVoApi:getAreaNameByIndex(areaIndex)
        local timeLb=GetTTFLabel(timeStr,lbSize)
        timeLb:setPosition(ccp(self.bgLayer:getContentSize().width-120,cellHeight-20))
        cell:addChild(timeLb,1)
        local areaNameLb=GetTTFLabelWrap(areaName,lbSize,CCSizeMake(nameBg:getContentSize().width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        areaNameLb:setAnchorPoint(ccp(0,0.5))
        areaNameLb:setPosition(ccp(10,nameBg:getContentSize().height/2+5))
        nameBg:addChild(areaNameLb,1)

        local descStr,color=serverWarTeamVoApi:getBattleDesc(record)
        local recordDescLb=GetTTFLabelWrap(descStr,lbSize,CCSizeMake(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        recordDescLb:setAnchorPoint(ccp(0,1))
        recordDescLb:setPosition(ccp(lbX+5,cellHeight-10-40))
        cell:addChild(recordDescLb,1)
        recordDescLb:setColor(color)

        -- local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
        -- lineSp:setAnchorPoint(ccp(0.5,0.5))
        -- lineSp:setScaleX(G_VisibleSizeWidth/lineSp:getContentSize().width)
        -- lineSp:setPosition(ccp(lbWidth/2,10))
        -- cell:addChild(lineSp,2)


        return cell;
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
     
    elseif fn=="ccScrollEnable" then
        if newGuidMgr:isNewGuiding()==true then
            return 0
        else
            return 1
        end
    end

end

function serverWarTeamRecordDialogTab1:refreshTableView()
    if self and self.tv then
        local recordPoint = self.tv:getRecordPoint()
        local oldHeight=0
        if self.cellHeightTab and SizeOfTable(self.cellHeightTab)>0 then
            for k,v in pairs(self.cellHeightTab) do
                oldHeight=oldHeight+v
            end
        end
        self.cellHeightTab={}
        self.tv:reloadData()
        local newHeight=0
        if self.cellHeightTab and SizeOfTable(self.cellHeightTab)>0 then
            for k,v in pairs(self.cellHeightTab) do
                newHeight=newHeight+v
            end
        end
        local diffHeight=newHeight-oldHeight
        local hasMore=serverWarTeamVoApi:hasMore(self.roundIndex,self.battleID,self.page)
        if hasMore then
            self.tv:recoverToRecordPoint(ccp(recordPoint.x,recordPoint.y-diffHeight))
        else
            self.tv:recoverToRecordPoint(ccp(recordPoint.x,recordPoint.y-diffHeight+100))
        end
    end
end

function serverWarTeamRecordDialogTab1:tick()
    -- if self then
    --     local rFlag=serverWarTeamVoApi:getRFlag()
    --     if rFlag==0 then
    --         self:refreshTableView()
    --         self:doUserHandler()
    --         serverWarTeamVoApi:setRFlag(1)
    --     end
    -- end
end


--用户处理特殊需求,没有可以不写此方法
function serverWarTeamRecordDialogTab1:doUserHandler()
    if self and self.noRecordLb then
        local num=serverWarTeamVoApi:getRecordNum(self.roundIndex,self.battleID,self.page)
        if num and num>0 then
            self.noRecordLb:setVisible(false)
        else
            self.noRecordLb:setVisible(true)
        end
    end
end

function serverWarTeamRecordDialogTab1:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    
    self.tv=nil
    -- self.tv2=nil
    self.layerNum=nil
    self.allTabs=nil
    self.cellHeightTab=nil
    self.canSand=nil
    self.noRecordLb=nil

    -- self.bgLayer1=nil
    -- self.bgLayer2=nil
    self.selectedTabIndex=nil
    self.bgLayer=nil

    self.roundIndex=nil
    self.battleID=nil
    self.isBattle=nil
    self.page=1

end
