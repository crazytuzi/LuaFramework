dimensionalWarInforSubTab11 = {}

function dimensionalWarInforSubTab11:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.bgLayer=nil
    self.layerNum=nil
    self.cellheight1=70
    return nc
end

function dimensionalWarInforSubTab11:init(layerNum)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self:initLayer()
    return self.bgLayer
end

function dimensionalWarInforSubTab11:initLayer()
    local hi=G_VisibleSize.height-305+120-10-35
    local tlbSize=26
    if G_getCurChoseLanguage() =="ru" then
        tlbSize =23
    end
    local tLb1 = GetTTFLabel(getlocal("alliance_scene_rank"),tlbSize);
    tLb1:setAnchorPoint(ccp(0,0.5));
    tLb1:setPosition(ccp(70,hi));
    self.bgLayer:addChild(tLb1,2);
    tLb1:setColor(G_ColorGreen)

    local tLb2 = GetTTFLabel(getlocal("alliance_scene_button_info_name"),tlbSize);
    tLb2:setAnchorPoint(ccp(0,0.5));
    tLb2:setPosition(ccp(210,hi));
    self.bgLayer:addChild(tLb2,2);
    tLb2:setColor(G_ColorGreen)

    -- local tLb3 = GetTTFLabel(getlocal("city_info_power"),tlbSize);
    local tLb3 = GetTTFLabel(getlocal("serverwar_point"),tlbSize);
    tLb3:setAnchorPoint(ccp(0,0.5));
    tLb3:setPosition(ccp(375,hi));
    self.bgLayer:addChild(tLb3,2);
    tLb3:setColor(G_ColorGreen)

    -- local tLb4 = GetTTFLabel(getlocal("serverwar_point"),tlbSize);
    local tLb4 = GetTTFLabelWrap(getlocal("dimensionalWar_survive_round"),tlbSize,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter);
    tLb4:setAnchorPoint(ccp(0.5,0.5));
    tLb4:setPosition(ccp(540,hi));
    self.bgLayer:addChild(tLb4,2);
    tLb4:setColor(G_ColorGreen)

    -- local backSprie2=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 1, 1),function () do return end end)
    local backSprie2=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20, 20, 1, 1),function()end)
    backSprie2:setContentSize(CCSizeMake(590,self.bgLayer:getContentSize().height-355))
    backSprie2:setAnchorPoint(ccp(0.5,0))
    backSprie2:setPosition(self.bgLayer:getContentSize().width/2,100)
    self.bgLayer:addChild(backSprie2)

    local desLb = GetTTFLabelWrap(getlocal("dimensionalWar_rank_desc"),25,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    desLb:setAnchorPoint(ccp(0,0.5))
    desLb:setPosition(CCPointMake(40,65))
    desLb:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(desLb)

    local function touchInfoItem(idx)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tabStr={"\n",getlocal("dimensionalWar_alive_desc5"),"\n",getlocal("dimensionalWar_alive_desc4"),"\n",getlocal("dimensionalWar_alive_desc3"),"\n",getlocal("dimensionalWar_alive_desc2"),"\n",getlocal("dimensionalWar_alive_desc1"),"\n"}
        local tabColor={nil,G_ColorWhite,nil,G_ColorWhite,nil,G_ColorWhite,nil,G_ColorWhite,nil,G_ColorYellowPro,nil}
        local tabAlignment={nil,nil,nil,nil,nil,nil,nil,nil,nil,kCCTextAlignmentCenter,nil}
        local td=smallDialog:new()
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor,nil,nil,nil,tabAlignment)
        sceneGame:addChild(dialog,self.layerNum+1) 
    end
    -- local infoItem = GetButtonItem("SlotInfor.png","SlotInfor.png","SlotInfor.png",touchInfoItem,11,nil,nil)
    local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touchInfoItem,11,nil,nil)
    infoItem:setScale(0.8)
    local infoMenu=CCMenu:createWithItem(infoItem)
    infoMenu:setPosition(ccp(560,65))
    infoMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(infoMenu)

    self.noRankLb=GetTTFLabelWrap(getlocal("dimensionalWar_rank_show"),30,CCSizeMake(self.bgLayer:getContentSize().width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.noRankLb:setAnchorPoint(ccp(0.5,0.5))
    self.noRankLb:setColor(G_ColorYellowPro)
    self.noRankLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2))
    self.bgLayer:addChild(self.noRankLb)
    self.noRankLb:setVisible(false)

    self.rankList=self:getRankList()
    if dimensionalWarVoApi:getStatus()>=20 then
        if SizeOfTable(self.rankList)==0 then
            self.noRankLb:setString(getlocal("dimensionalWar_no_rank_show"))
            self.noRankLb:setVisible(true)
        else
            self:initTableView()
        end
    else
        self.noRankLb:setString(getlocal("dimensionalWar_rank_show"))
        self.noRankLb:setVisible(true)
    end
end

function dimensionalWarInforSubTab11:initTableView()
   
    local function callBack1(...)
        return self:eventHandler1(...)
    end
    local hd1= LuaEventHandler:createHandler(callBack1)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd1,CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-380),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,110))
    self.bgLayer:addChild(self.tv,3)
    self.tv:setMaxDisToBottomOrTop(120)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function dimensionalWarInforSubTab11:eventHandler1(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local num=SizeOfTable(self.rankList)
        return num+1
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(600,self.cellheight1)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local name=""
        local power=0
        local point=0
        local round=0
        local rank=0
        if idx==0 then
            name=playerVoApi:getPlayerName()
            power=playerVoApi:getPlayerPower()
            point=dimensionalWarVoApi.point1 or 0
            round=dimensionalWarVoApi.round1 or 0
            rank=dimensionalWarVoApi:getSelfRank(1) or 0
        else
            rankData=self.rankList[idx]
            -- local fid = tonumber(Split(self.rankList[idx+1][1],"-")[1])
            -- local nameStr = GetServerNameByID(fid) .. "-" .. self.rankList[idx+1][2]
            if rankData then
                name = rankData.name or ""
                power = rankData.power or 0
                point = rankData.point or 0
                round = rankData.round or 0
            end
            rank=idx
        end

        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local capInSetNew=CCRect(20, 20, 10, 10)
        local function cellClick(hd,fn,idx)
        end
        local backSprie
        if idx==0 then
            backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png",capInSetNew,cellClick)
        elseif idx==1 then
            backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank1ItemBg.png",capInSetNew,cellClick)
        elseif idx==2 then
            backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank2ItemBg.png",capInSetNew,cellClick)
        elseif idx==3 then
            backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank3ItemBg.png",capInSetNew,cellClick)
        else
            backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png",capInSet,cellClick)
        end
        backSprie:setContentSize(CCSizeMake(580, self.cellheight1-4))
        backSprie:ignoreAnchorPointForPosition(false)
        backSprie:setAnchorPoint(ccp(0,0.5))
        backSprie:setPosition(ccp(0,self.cellheight1/2))
        backSprie:setIsSallow(false)
        backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        cell:addChild(backSprie)


        -- local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
        -- lineSp:setAnchorPoint(ccp(0,0));
        -- lineSp:setPosition(ccp(0,0));
        -- cell:addChild(lineSp,1)

        local tlbSize=25
        if rank>0 and rank<=3 then
            local rankSp =CCSprite:createWithSpriteFrameName("top" .. rank .. ".png")
            rankSp:setPosition(ccp(60,self.cellheight1/2));
            cell:addChild(rankSp,2)
        else
            if G_getCurChoseLanguage() =="ru" then
                tlbSize =22
            end
            if idx==0 and rank<=0 then
                rank=getlocal("dimensionalWar_out_of_rank")
            end
            local tLb1 = GetTTFLabelWrap(rank,tlbSize,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter);
            tLb1:setPosition(ccp(65,self.cellheight1/2));
            cell:addChild(tLb1,2);
        end


        local tLb2 = GetTTFLabelWrap(name,tlbSize,CCSizeMake(175,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        tLb2:setPosition(ccp(210,self.cellheight1/2));
        cell:addChild(tLb2,2);

        -- local fightNum=FormatNumber(power)
        local pointNum=FormatNumber(point)
        local tLb3 = GetTTFLabel(pointNum,tlbSize);
        tLb3:setPosition(ccp(370,self.cellheight1/2));
        cell:addChild(tLb3,2);

        local roundNum=round
        local tLb4 = GetTTFLabel(roundNum,tlbSize);
        tLb4:setPosition(ccp(510,self.cellheight1/2));
        cell:addChild(tLb4,2);


        return cell;

    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
       
    elseif fn=="ccScrollEnable" then
        return 1
    end

end

function dimensionalWarInforSubTab11:getRankList()
    local rankList=dimensionalWarVoApi:getRankList(1)
    return rankList
end

function dimensionalWarInforSubTab11:tick()
end


function dimensionalWarInforSubTab11:refresh()
end

function dimensionalWarInforSubTab11:dispose()
    self.bgLayer=nil
    self.layerNum=nil
    self.tv=nil
    self.cellheight1=nil
end

