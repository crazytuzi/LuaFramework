serverWarLocalRewardTab3={}

function serverWarLocalRewardTab3:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
    self.parent=nil

    self.cellHeght=80
    self.hSpace=20
    self.noRecordLb=nil
    self.callbackNum=0
    self.descLb=nil
    
    return nc
end

function serverWarLocalRewardTab3:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self:initDesc()
    self:initTableView()
    return self.bgLayer
end

function serverWarLocalRewardTab3:initDesc()
    local myFeatDescLb=GetTTFLabel(getlocal("serverwar_my_point"),28)
    myFeatDescLb:setColor(G_ColorGreen)
    myFeatDescLb:setAnchorPoint(ccp(0,0.5))
    myFeatDescLb:setPosition(ccp(30,G_VisibleSizeHeight-180-self.hSpace))
    self.bgLayer:addChild(myFeatDescLb)
    self.myFeatLb=GetTTFLabel(serverWarLocalVoApi:getPoint(),28)
    self.myFeatLb:setAnchorPoint(ccp(0,0.5))
    self.myFeatLb:setPosition(ccp(40+myFeatDescLb:getContentSize().width,G_VisibleSizeHeight-180-self.hSpace))
    self.bgLayer:addChild(self.myFeatLb)

    local endTime=serverWarLocalVoApi.endTime
    local cdTime=endTime-base.serverTime
    if cdTime<0 then
        cdTime=0
    end
    local str=getlocal("serverWarLocal_shop_desc",{G_getTimeStr(cdTime)})
    -- local str=getlocal("serverWarLocal_shop_desc",{serverWarLocalCfg.shoppingtime})
    local dvWidth,dvHeight=G_VisibleSizeWidth-60,90
    local desTv,desLabel=G_LabelTableView(CCSizeMake(dvWidth,dvHeight),str,25,kCCTextAlignmentLeft,G_ColorYellowPro)
    desTv:setAnchorPoint(ccp(0,0))
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    desTv:setPosition(ccp(30,myFeatDescLb:getPositionY()-myFeatDescLb:getContentSize().height/2-90))
    self.bgLayer:addChild(desTv)
    self.descLb=desLabel

    -- local function showInfo()
    --     if G_checkClickEnable()==false then
    --         do
    --             return
    --         end
    --     else
    --         base.setWaitTime=G_getCurDeviceMillTime()
    --     end
    --     local tabStr={"\n",getlocal("plat_war_shop_tip_4"),"\n",getlocal("plat_war_shop_tip_3",{platWarCfg.shoppingtime}),"\n",getlocal("plat_war_shop_tip_2"),"\n",getlocal("plat_war_shop_tip_1"),"\n"};
    --     local tabColor={nil,G_ColorRed,nil,G_ColorYellow,nil,G_ColorYellow,nil,G_ColorYellow,nil}
    --     PlayEffect(audioCfg.mouseClick)
    --     local td=smallDialog:new()
    --     local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
    --     sceneGame:addChild(dialog,self.layerNum+1)
    -- end
    -- local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
    -- local infoBtn = CCMenu:createWithItem(infoItem);
    -- infoBtn:setPosition(ccp(G_VisibleSizeWidth-80,G_VisibleSizeHeight-210-self.hSpace-30))
    -- infoBtn:setTouchPriority(-(self.layerNum-1)*20-3)
    -- self.bgLayer:addChild(infoBtn)



    -- local str=getlocal("serverwar_shop_desc3")
    -- local descLb=GetTTFLabelWrap(str,25,CCSizeMake(G_VisibleSizeWidth-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    -- descLb:setAnchorPoint(ccp(0,0.5))
    -- descLb:setPosition(ccp(30,G_VisibleSizeHeight-225-self.hSpace-20))
    -- descLb:setColor(G_ColorYellowPro)
    -- self.bgLayer:addChild(descLb)


    local function touch()
    end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),touch)
    backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40, self.bgLayer:getContentSize().height-320-self.hSpace))
    backSprie:ignoreAnchorPointForPosition(false)
    backSprie:setAnchorPoint(ccp(0.5,0))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
    backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,28))
    self.bgLayer:addChild(backSprie)

    local headSprie =LuaCCScale9Sprite:createWithSpriteFrameName("newRankTitleBg.png",CCRect(4,4,1,1),touch)
    headSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40, 38))
    headSprie:ignoreAnchorPointForPosition(false)
    headSprie:setAnchorPoint(ccp(0.5,1))
    headSprie:setIsSallow(false)
    headSprie:setTouchPriority(-(self.layerNum-1)*20-2)
    headSprie:setPosition(ccp(backSprie:getContentSize().width/2,backSprie:getContentSize().height-2))
    backSprie:addChild(headSprie,1)

    local timeLb=GetTTFLabel(getlocal("alliance_event_time"),22)
    timeLb:setPosition(110,headSprie:getContentSize().height/2)
    timeLb:setAnchorPoint(ccp(0.5,0.5))
    headSprie:addChild(timeLb,2)
    -- timeLb:setColor(G_ColorGreen2)

    local recordLb=GetTTFLabel(getlocal("serverwar_point_record"),22)
    recordLb:setPosition(390,headSprie:getContentSize().height/2)
    recordLb:setAnchorPoint(ccp(0.5,0.5))
    headSprie:addChild(recordLb,2)
    -- recordLb:setColor(G_ColorGreen2)

    self.noRecordLb=GetTTFLabelWrap(getlocal("serverwar_point_no_record"),30,CCSizeMake(backSprie:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.noRecordLb:setAnchorPoint(ccp(0.5,0.5))
    self.noRecordLb:setPosition(getCenterPoint(backSprie))
    backSprie:addChild(self.noRecordLb,1)
    self.noRecordLb:setColor(G_ColorYellowPro)
    self.noRecordLb:setVisible(false)

    self:doUserHandler()
end

function serverWarLocalRewardTab3:initTableView()
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-40,self.bgLayer:getContentSize().height-290-self.hSpace-35-45),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setAnchorPoint(ccp(0,0))
    self.tv:setPosition(ccp(20,30))
    self.tv:setMaxDisToBottomOrTop(120)
    self.bgLayer:addChild(self.tv)
end

function serverWarLocalRewardTab3:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local pointDetail=serverWarLocalVoApi:getPointDetail()
        local num=SizeOfTable(pointDetail)
        -- local isHasMore=serverWarLocalVoApi:isHasMore()
        -- if isHasMore then
        --     num=num+1
        -- end
        return num
    elseif fn=="tableCellSizeForIndex" then
        local pointDetail=serverWarLocalVoApi:getPointDetail()
        -- local isHasMore=serverWarLocalVoApi:isHasMore()
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

        local cellWidth,cellHeight=self.bgLayer:getContentSize().width-40,self.cellHeght
        local pointDetail=serverWarLocalVoApi:getPointDetail()
        local num=SizeOfTable(pointDetail)
        if num<=0 then
            do return end
        end
        -- local isHasMore=serverWarLocalVoApi:isHasMore()
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
                --             local addHeight=serverWarLocalVoApi:formatData(sData.data.alliance.events)
                --             local newHasMore=serverWarLocalVoApi:isHasMore()
                --             if serverWarLocalVoApi:getPage()>=1 then
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
                -- local page=serverWarLocalVoApi:getPage()
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

        local pointDetail=serverWarLocalVoApi:getPointDetail()
        local vo=pointDetail[idx+1]
        if vo==nil then
            do return end
        end
        local width=400
        local height=self.cellHeght
        local message=vo.message
        local color=vo.color
        local time=vo.time

        local timeStr=serverWarLocalVoApi:getTimeStr(time)
        local timeLabel=GetTTFLabel(timeStr,22)
        timeLabel:setAnchorPoint(ccp(0.5,0.5))
        timeLabel:setPosition(ccp(79,height/2))
        cell:addChild(timeLabel,1)

        local textLabel=GetTTFLabelWrap(message,22,CCSizeMake(width,height),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        textLabel:setAnchorPoint(ccp(0.5,0.5))
        textLabel:setPosition(ccp(370,height/2))
        cell:addChild(textLabel,1)

        timeLabel:setColor(color)
        textLabel:setColor(color)

        local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function ()end)
        lineSp:setContentSize(CCSizeMake(cellWidth-2,2))
        lineSp:setRotation(180)
        lineSp:setPosition(cellWidth/2,lineSp:getContentSize().height/2)
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

function serverWarLocalRewardTab3:doUserHandler()
    if self.noRecordLb then
        local pointDetail=serverWarLocalVoApi:getPointDetail()
        local num=SizeOfTable(pointDetail)
        if num==0 then
            self.noRecordLb:setVisible(true)
        else
            self.noRecordLb:setVisible(false)
        end
    end
end

function serverWarLocalRewardTab3:tick()
    local flag=serverWarLocalVoApi:getPointDetailFlag()
    -- local detailExpireTime=serverWarLocalVoApi:getDetailExpireTime()
    -- if (self.callbackNum<3 and ((detailExpireTime and detailExpireTime>0 and base.serverTime>=detailExpireTime) or flag==-1)) then
    if (self.callbackNum<3 and flag==-1) then
        local function callback()
            self:doUserHandler()
            if self and self.tv then
                self.tv:reloadData()
            end
            self.callbackNum=0
        end
        serverWarLocalVoApi:setPointDetailFlag(-1)
        serverWarLocalVoApi:formatPointDetail(callback)
        self.callbackNum=self.callbackNum+1
    elseif flag==0 then
        self:doUserHandler()
        if self and self.tv then
            self.tv:reloadData()
        end
        serverWarLocalVoApi:setPointDetailFlag(1)
    end
    if self and self.myFeatLb then
        self.myFeatLb:setString(serverWarLocalVoApi:getPoint())
    end
    if self.descLb then
        local endTime=serverWarLocalVoApi.endTime
        local cdTime=endTime-base.serverTime
        if cdTime<0 then
            cdTime=0
        end
        local str=getlocal("serverWarLocal_shop_desc",{G_getTimeStr(cdTime)})
        self.descLb:setString(str)
    end
end

function serverWarLocalRewardTab3:refresh()

end

function serverWarLocalRewardTab3:dispose()
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
    self.cellHeght=nil
    self.hSpace=nil
    self.noRecordLb=nil
    self.callbackNum=0
    self.descLb=nil
end






