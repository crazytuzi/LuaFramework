localWarFeatRankDialog={}

function localWarFeatRankDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.bgLayer=nil
    self.layerNum=nil
    self.tv1=nil
    self.tv2=nil
    self.cellHeight=72
    self.selectedTabIndex=0
    self.page={1,1}
    self.noRankLb=nil

    return nc
end

function localWarFeatRankDialog:init(layerNum)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self:resetTab()
    self:doUserHandler()

    self.noRankLb=GetTTFLabelWrap(getlocal("local_war_feat_no_rank"),30,CCSizeMake(self.bgLayer:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.noRankLb:setAnchorPoint(ccp(0.5,0.5))
    self.noRankLb:setColor(G_ColorYellowPro)
    self.noRankLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2))
    self.bgLayer:addChild(self.noRankLb)
    self.noRankLb:setVisible(false)

    local function callback()
        self:initTableView1()
        self:refresh()
    end
    localWarVoApi:updateRankList(1,1,callback)
    return self.bgLayer
end


--设置或修改每个Tab页签
function localWarFeatRankDialog:resetTab()
    self.allTabs={getlocal("world_war_all"),getlocal("local_war_alliance_feat_own")}
    self:initTab(self.allTabs)
    local index=0
    self.selectedTabIndex=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v
         if index==0 then
            tabBtnItem:setPosition(100,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-165)
         elseif index==1 then
            tabBtnItem:setPosition(248,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-165)
         -- elseif index==2 then
         --    tabBtnItem:setPosition(394,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-165)
         -- elseif index==3 then
         --    tabBtnItem:setPosition(540,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-165)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
end

function localWarFeatRankDialog:initTab(tabTb)
   local tabBtn=CCMenu:create()
   local tabIndex=0
   local tabBtnItem;
   if tabTb~=nil then
       for k,v in pairs(tabTb) do

           tabBtnItem = CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
           
           tabBtnItem:setAnchorPoint(CCPointMake(0.5,0.5))

           local function tabClick(idx)
               return self:tabClick(idx)
           end
           tabBtnItem:registerScriptTapHandler(tabClick)
           
           local lb=GetTTFLabel(v,24)
           lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width/2,tabBtnItem:getContentSize().height/2))
           tabBtnItem:addChild(lb)
           lb:setTag(31)
           
           
            local numHeight=25
            local iconWidth=36
            local iconHeight=36
            local newsNumLabel = GetTTFLabel("0",numHeight)
            newsNumLabel:setPosition(ccp(newsNumLabel:getContentSize().width/2+5,iconHeight/2))
            newsNumLabel:setTag(11)
            local capInSet1 = CCRect(17, 17, 1, 1)
            local function touchClick()
            end
            local newsIcon =LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",capInSet1,touchClick)
            if newsNumLabel:getContentSize().width+10>iconWidth then
                iconWidth=newsNumLabel:getContentSize().width+10
            end
            newsIcon:setContentSize(CCSizeMake(iconWidth,iconHeight))
            newsIcon:ignoreAnchorPointForPosition(false)
            newsIcon:setAnchorPoint(CCPointMake(1,0.5))
            newsIcon:setPosition(ccp(tabBtnItem:getContentSize().width-2+15,tabBtnItem:getContentSize().height))
            newsIcon:addChild(newsNumLabel,1)
            newsIcon:setTag(10)
            newsIcon:setVisible(false)
            tabBtnItem:addChild(newsIcon,2)
           
           --local lockSp=CCSprite:createWithSpriteFrameName("LockIconCheckPoint.png")
           local lockSp=CCSprite:createWithSpriteFrameName("LockIcon.png")
           lockSp:setAnchorPoint(CCPointMake(0,0.5))
           lockSp:setPosition(ccp(10,tabBtnItem:getContentSize().height/2))
           lockSp:setScaleX(0.7)
           lockSp:setScaleY(0.7)
           tabBtnItem:addChild(lockSp,3)
           lockSp:setTag(30)
           lockSp:setVisible(false)
            
           self.allTabs[k]=tabBtnItem
           tabBtn:addChild(tabBtnItem)
           tabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
           tabBtnItem:setTag(tabIndex)

           tabIndex=tabIndex+1
       end
   end
   tabBtn:setPosition(0,0)
   self.bgLayer:addChild(tabBtn,2)
end


function localWarFeatRankDialog:doUserHandler()
    local height=self.bgLayer:getContentSize().height-230
    local widthSpace=80
    local lbTb={
        {getlocal("RankScene_rank"),25,ccp(0.5,0.5),ccp(widthSpace,height),self.bgLayer,1,G_ColorGreen},
        {getlocal("RankScene_name"),25,ccp(0.5,0.5),ccp(widthSpace+150,height),self.bgLayer,1,G_ColorGreen},
        {getlocal("RankScene_power"),25,ccp(0.5,0.5),ccp(widthSpace+150*2+20,height),self.bgLayer,1,G_ColorGreen},
        {getlocal("local_war_alliance_feat"),25,ccp(0.5,0.5),ccp(widthSpace+150*3,height),self.bgLayer,1,G_ColorGreen},
        {getlocal("local_war_alliance_rank_desc"),22,ccp(0,0.5),ccp(40,60),self.bgLayer,1,G_ColorRed,CCSize(self.bgLayer:getContentSize().width-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
    }
    for k,v in pairs(lbTb) do
        GetAllTTFLabel(v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11])
    end

    local function rewardTip(...)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tabStr={"\n",getlocal("local_war_feat_desc_2"),getlocal("local_war_feat_desc",{localWarCfg.winRate,localWarCfg.loseRate,localWarCfg.winAllianceRate,localWarCfg.occupyRate}),"\n"}
        local tabColor={nil,G_ColorRed,G_ColorYellowPro,nil}
        local td=smallDialog:new()
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
        sceneGame:addChild(dialog,self.layerNum+1) 
    end
    local descItem=GetButtonItem("SlotInfor.png","SlotInfor.png","SlotInfor.png",rewardTip,3,nil,0)
    descItem:setAnchorPoint(ccp(0.5,0.5))
    local descMenu=CCMenu:createWithItem(descItem)
    descMenu:setTouchPriority(-(self.layerNum-1)*20-5)
    descMenu:setPosition(ccp(self.bgLayer:getContentSize().width-80,60))
    self.bgLayer:addChild(descMenu)
end

function localWarFeatRankDialog:initTableView1()
    local function callBack(...)
        return self:eventHandler1(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv1=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight-355),nil)
    self.bgLayer:addChild(self.tv1)
    self.tv1:setAnchorPoint(ccp(0,0))
    self.tv1:setPosition(ccp(30,105))
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv1:setMaxDisToBottomOrTop(80)
end
function localWarFeatRankDialog:initTableView2()
    local function callBack(...)
        return self:eventHandler2(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv2=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight-355),nil)
    self.bgLayer:addChild(self.tv2)
    self.tv2:setAnchorPoint(ccp(0,0))
    self.tv2:setPosition(ccp(30,105))
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv2:setMaxDisToBottomOrTop(80)
end

function localWarFeatRankDialog:eventHandler1(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local featRank=localWarVoApi:getFeatRank(self.selectedTabIndex+1)
        local num=SizeOfTable(featRank)
        if num>0 then
            num=num+1
        end
        local hasMore=localWarVoApi:getHasMoreRankNum(self.selectedTabIndex+1)
        if hasMore then
            num=num+1
        end
        return num
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(G_VisibleSizeWidth-60,self.cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local featRank=localWarVoApi:getFeatRank(self.selectedTabIndex+1)
        local num=SizeOfTable(featRank)+1
        if num>1 then
            local hasMore=localWarVoApi:getHasMoreRankNum(self.selectedTabIndex+1)
            local rect = CCRect(0, 0, 50, 50);
            local capInSet = CCRect(40, 40, 10, 10);
            local capInSetNew=CCRect(20, 20, 10, 10)
            local backSprie
            if hasMore and idx==num then
                local function cellClick(hd,fn,idx)
                    self:cellClick(idx)
                end
                backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("ItemBtnMore.png",capInSetNew,cellClick)
                backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.cellHeight))
                backSprie:ignoreAnchorPointForPosition(false)
                backSprie:setAnchorPoint(ccp(0,0))
                backSprie:setIsSallow(false)
                backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
                backSprie:setTag(idx)
                cell:addChild(backSprie,1)
                
                local moreLabel=GetTTFLabel(getlocal("showMore"),30)
                moreLabel:setPosition(getCenterPoint(backSprie))
                backSprie:addChild(moreLabel,2)
                
                do return cell end
            end
            
            local function cellClick1(hd,fn,idx)
            end
            if idx==0 then
                backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png",capInSetNew,cellClick1)
            elseif idx==1 then
                backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank1ItemBg.png",capInSetNew,cellClick1)
            elseif idx==2 then
                backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank2ItemBg.png",capInSetNew,cellClick1)
            elseif idx==3 then
                backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank3ItemBg.png",capInSetNew,cellClick1)
            else
                backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png",capInSet,cellClick1)
            end
            backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.cellHeight-4))
            backSprie:ignoreAnchorPointForPosition(false)
            backSprie:setAnchorPoint(ccp(0,0))
            backSprie:setIsSallow(false)
            backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
            cell:addChild(backSprie,1)
            
            local height=backSprie:getContentSize().height/2
            local widthSpace=50
            
            local selfRank
            local rankData

            local rankStr=""
            local nameStr=""
            local powerStr=0
            local valueStr=0
            if idx==0 then
                selfRank=localWarVoApi:getMyFeatRankData(self.selectedTabIndex+1)
                rankStr=getlocal("alliance_info_content")
                nameStr=playerVoApi:getPlayerName()
                powerStr=playerVoApi:getPlayerPower()
                if selfRank~=nil then
                    if selfRank.rank and selfRank.rank>0 then
                        rankStr=selfRank.rank
                    end
                    nameStr=selfRank.name
                    powerStr=selfRank.power
                    valueStr=selfRank.point
                end
                -- rankStr="100+"
                -- nameStr=playerVoApi:getPlayerName()
                -- powerStr=playerVoApi:getPlayerPower()
                -- valueStr=1000
            else
                if featRank and featRank[idx] then
                    rankData=featRank[idx]
                    if rankData~=nil then
                        rankStr=rankData.rank
                        nameStr=rankData.name
                        powerStr=rankData.power
                        valueStr=rankData.point
                    end
                end
                -- rankStr=idx
                -- nameStr="name"..idx
                -- powerStr=1000+idx
                -- valueStr=10000+idx
            end
            
            local rankLabel=GetTTFLabel(rankStr,30)
            rankLabel:setPosition(widthSpace,height)
            cell:addChild(rankLabel,2)
            -- table.insert(self.labelTab,idx,{rankLabel=rankLabel})
            
            local rankSp
            if tonumber(rankStr)==1 then
                rankSp=CCSprite:createWithSpriteFrameName("top1.png")
            elseif tonumber(rankStr)==2 then
                rankSp=CCSprite:createWithSpriteFrameName("top2.png")
            elseif tonumber(rankStr)==3 then
                rankSp=CCSprite:createWithSpriteFrameName("top3.png")
            end
            if rankSp then
                rankSp:setPosition(ccp(widthSpace,height))
                backSprie:addChild(rankSp,3)
                rankLabel:setVisible(false)
            end

            local nameLabel=GetTTFLabel(nameStr,30)
            nameLabel:setPosition(widthSpace+150,height)
            cell:addChild(nameLabel,2)
            -- self.labelTab[idx].nameLabel=nameLabel

            local powerLabel=GetTTFLabel(FormatNumber(powerStr),30)
            powerLabel:setPosition(widthSpace+150*2+20,height)
            cell:addChild(powerLabel,2)
            -- self.labelTab[idx].powerLabel=powerLabel

            local valueLabel=GetTTFLabel(FormatNumber(valueStr),30)
            valueLabel:setPosition(widthSpace+150*3,height)
            cell:addChild(valueLabel,2)
            -- self.labelTab[idx].valueLabel=valueLabel
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

function localWarFeatRankDialog:eventHandler2(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local featRank=localWarVoApi:getFeatRank(self.selectedTabIndex+1)
        local num=SizeOfTable(featRank)
        if num>0 then
            num=num+1
        end
        local hasMore=localWarVoApi:getHasMoreRankNum(self.selectedTabIndex+1)
        if hasMore then
            num=num+1
        end
        return num
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(G_VisibleSizeWidth-60,self.cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local featRank=localWarVoApi:getFeatRank(self.selectedTabIndex+1)
        local num=SizeOfTable(featRank)+1
        if num>1 then
            local hasMore=localWarVoApi:getHasMoreRankNum(self.selectedTabIndex+1)
            local rect = CCRect(0, 0, 50, 50);
            local capInSet = CCRect(40, 40, 10, 10);
            local capInSetNew=CCRect(20, 20, 10, 10)
            local backSprie
            if hasMore and idx==num then
                local function cellClick(hd,fn,idx)
                    self:cellClick(idx)
                end
                backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("ItemBtnMore.png",capInSetNew,cellClick)
                backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.cellHeight))
                backSprie:ignoreAnchorPointForPosition(false)
                backSprie:setAnchorPoint(ccp(0,0))
                backSprie:setIsSallow(false)
                backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
                backSprie:setTag(idx)
                cell:addChild(backSprie,1)
                
                local moreLabel=GetTTFLabel(getlocal("showMore"),30)
                moreLabel:setPosition(getCenterPoint(backSprie))
                backSprie:addChild(moreLabel,2)
                
                do return cell end
            end
            
            local function cellClick1(hd,fn,idx)
            end
            if idx==0 then
                backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png",capInSetNew,cellClick1)
            elseif idx==1 then
                backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank1ItemBg.png",capInSetNew,cellClick1)
            elseif idx==2 then
                backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank2ItemBg.png",capInSetNew,cellClick1)
            elseif idx==3 then
                backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank3ItemBg.png",capInSetNew,cellClick1)
            else
                backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png",capInSet,cellClick1)
            end
            backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.cellHeight-4))
            backSprie:ignoreAnchorPointForPosition(false)
            backSprie:setAnchorPoint(ccp(0,0))
            backSprie:setIsSallow(false)
            backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
            cell:addChild(backSprie,1)
            
            local height=backSprie:getContentSize().height/2
            local widthSpace=50
            
            local selfRank
            local rankData

            local rankStr=""
            local nameStr=""
            local powerStr=0
            local valueStr=0
            if idx==0 then
                selfRank=localWarVoApi:getMyFeatRankData(self.selectedTabIndex+1)
                rankStr=getlocal("alliance_info_content")
                nameStr=playerVoApi:getPlayerName()
                powerStr=playerVoApi:getPlayerPower()
                if selfRank~=nil then
                    if selfRank.rank and selfRank.rank>0 then
                        rankStr=selfRank.rank
                    end
                    nameStr=selfRank.name
                    powerStr=selfRank.power
                    valueStr=selfRank.point
                end
                -- rankStr="100+"
                -- nameStr=playerVoApi:getPlayerName()
                -- powerStr=playerVoApi:getPlayerPower()
                -- valueStr=1000
            else
                if featRank and featRank[idx] then
                    rankData=featRank[idx]
                    if rankData~=nil then
                        rankStr=rankData.rank
                        nameStr=rankData.name
                        powerStr=rankData.power
                        valueStr=rankData.point
                    end
                end
                -- rankStr=idx
                -- nameStr="name"..idx
                -- powerStr=1000+idx
                -- valueStr=10000+idx
            end
            
            local rankLabel=GetTTFLabel(rankStr,30)
            rankLabel:setPosition(widthSpace,height)
            cell:addChild(rankLabel,2)
            -- table.insert(self.labelTab,idx,{rankLabel=rankLabel})
            
            local rankSp
            if tonumber(rankStr)==1 then
                rankSp=CCSprite:createWithSpriteFrameName("top1.png")
            elseif tonumber(rankStr)==2 then
                rankSp=CCSprite:createWithSpriteFrameName("top2.png")
            elseif tonumber(rankStr)==3 then
                rankSp=CCSprite:createWithSpriteFrameName("top3.png")
            end
            if rankSp then
                rankSp:setPosition(ccp(widthSpace,height))
                backSprie:addChild(rankSp,3)
                rankLabel:setVisible(false)
            end

            local nameLabel=GetTTFLabel(nameStr,30)
            nameLabel:setPosition(widthSpace+150,height)
            cell:addChild(nameLabel,2)
            -- self.labelTab[idx].nameLabel=nameLabel

            local powerLabel=GetTTFLabel(FormatNumber(powerStr),30)
            powerLabel:setPosition(widthSpace+150*2+20,height)
            cell:addChild(powerLabel,2)
            -- self.labelTab[idx].powerLabel=powerLabel

            local valueLabel=GetTTFLabel(FormatNumber(valueStr),30)
            valueLabel:setPosition(widthSpace+150*3,height)
            cell:addChild(valueLabel,2)
            -- self.labelTab[idx].valueLabel=valueLabel
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

--点击了cell或cell上某个按钮
function localWarFeatRankDialog:cellClick(idx)
    local tableView
    if self.selectedTabIndex+1==1 then
        tableView=self.tv1
    else
        tableView=self.tv2
    end
    if tableView and tableView:getScrollEnable()==true and tableView:getIsScrolled()==false then
        local rData=localWarVoApi:getFeatRank(self.selectedTabIndex+1)
        local hasMore=localWarVoApi:getHasMoreRankNum(self.selectedTabIndex+1)
        local num=SizeOfTable(rData)+1
        if hasMore and tostring(idx)==tostring(num) then
            PlayEffect(audioCfg.mouseClick)
            local function rankingHandler()
                local nowRData=localWarVoApi:getFeatRank(self.selectedTabIndex+1)
                local nowNum=SizeOfTable(nowRData)+1
                local nextHasMore=localWarVoApi:getHasMoreRankNum(self.selectedTabIndex+1)
                local recordPoint = tableView:getRecordPoint()
                tableView:reloadData()
                if nextHasMore then
                    recordPoint.y=(num-nowNum)*self.cellHeight+recordPoint.y
                else
                    recordPoint.y=(num-nowNum+1)*self.cellHeight+recordPoint.y
                end
                tableView:recoverToRecordPoint(recordPoint)
                self.page[self.selectedTabIndex+1]=self.page[self.selectedTabIndex+1]+1
            end
            local page=self.page[self.selectedTabIndex+1]+1
            localWarVoApi:updateRankList(self.selectedTabIndex+1,page,rankingHandler)
        end
    end
end

function localWarFeatRankDialog:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)
    for k,v in pairs(self.allTabs) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
        else
            v:setEnabled(true)
        end
    end

    if idx==1 then
        if self.tv2==nil then
            local function callback()
                self:initTableView2()
                self.tv2:setVisible(true)
                self.tv2:setPosition(ccp(30,105))
                self:refresh()
            end
            localWarVoApi:updateRankList(2,1,callback)
        else
            self.tv2:setVisible(true)
            self.tv2:setPosition(ccp(30,105))
        end
        if self.tv1 then
            self.tv1:setVisible(false)
            self.tv1:setPosition(ccp(30,10000))
        end
    else
        if self.tv1 then
            self.tv1:setVisible(true)
            self.tv1:setPosition(ccp(30,105))
        end
        if self.tv2 then
            self.tv2:setVisible(false)
            self.tv2:setPosition(ccp(30,10000))
        end
    end
    self:refresh()
end

function localWarFeatRankDialog:refresh()
    if self and self.noRankLb then
        local featRank=localWarVoApi:getFeatRank(self.selectedTabIndex+1)
        if featRank and SizeOfTable(featRank)>0 then
            self.noRankLb:setVisible(false)
        else
            self.noRankLb:setVisible(true)
        end
    end
end

function localWarFeatRankDialog:tick()
   
end

function localWarFeatRankDialog:dispose()
    self.bgLayer=nil
    self.layerNum=nil
    self.tv1=nil
    self.tv2=nil
    self.selectedTabIndex=0
    self.page={1,1}
    self.noRankLb=nil
end
