serverWarLocalAgainstRankTab3 = {}

function serverWarLocalAgainstRankTab3:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.bgLayer=nil
    self.layerNum=nil
    self.cellHeight=72
    self.selectedTabIndex=1  --当前选中的tab
    self.oldSelectedTabIndex=1 --上一次选中的tab
    self.allTabs={}
    self.allPerson={}
    self.ownPerson={}
    self.selfInfo={}
    
    return nc
end

function serverWarLocalAgainstRankTab3:init(layerNum)

    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.allPerson=G_clone(serverWarLocalVoApi:getAllPerson())
    self:initLayer()
    return self.bgLayer
end

function serverWarLocalAgainstRankTab3:initLayer()

     local tabHeight = self.bgLayer:getContentSize().height-190
      --  普通坦克和精英坦克的页签
    local function touchItem(idx)
        self.oldSelectedTabIndex=self.selectedTabIndex
        self:tabClickColor(idx)
        return self:tabClick(idx)
    end
    local oneItem = CCMenuItemImage:create("yh_ltzdzHelp_tab.png", "yh_ltzdzHelp_tab_down.png","yh_ltzdzHelp_tab_down.png")
    oneItem:setTag(1)
    oneItem:registerScriptTapHandler(touchItem)
    oneItem:setEnabled(false)
    self.allTabs[1]=oneItem
    local oneMenu=CCMenu:createWithItem(oneItem)
    oneMenu:setPosition(ccp(30+oneItem:getContentSize().width/2,tabHeight))
    oneMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(oneMenu,2)

    local onelb=GetTTFLabelWrap(getlocal("local_war_alliance_feat_all"),22,CCSizeMake(oneItem:getContentSize().width-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    onelb:setPosition(CCPointMake(oneItem:getContentSize().width/2,oneItem:getContentSize().height/2))
    oneItem:addChild(onelb,1)


    local twoItem=CCMenuItemImage:create("yh_ltzdzHelp_tab.png", "yh_ltzdzHelp_tab_down.png","yh_ltzdzHelp_tab_down.png")
    twoItem:setTag(2)
    twoItem:registerScriptTapHandler(touchItem)
    self.allTabs[2]=twoItem
    local twoMenu=CCMenu:createWithItem(twoItem)
    twoMenu:setPosition(ccp(30+twoItem:getContentSize().width/2*3+4,tabHeight))
    twoMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(twoMenu,2)

    local twolb=GetTTFLabelWrap(getlocal("local_war_alliance_feat_own"),22,CCSizeMake(twoItem:getContentSize().width-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    twolb:setPosition(CCPointMake(twoItem:getContentSize().width/2,twoItem:getContentSize().height/2))
    twoItem:addChild(twolb,1)

    local tabLine=LuaCCScale9Sprite:createWithSpriteFrameName("yh_ltzdzHelp_tabLine.png",CCRect(4,3,1,1),function()end)
    tabLine:setContentSize(CCSizeMake(G_VisibleSizeWidth,tabLine:getContentSize().height))
    tabLine:setAnchorPoint(ccp(0.5,1))
    tabLine:setPosition(G_VisibleSizeWidth/2,tabHeight-twoItem:getContentSize().height/2)
    self.bgLayer:addChild(tabLine,1)

    local hi=self.bgLayer:getContentSize().height-240
    local tlbSize=26
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

    local tLb3 = GetTTFLabel(getlocal("city_info_power"),tlbSize);
    tLb3:setAnchorPoint(ccp(0,0.5));
    tLb3:setPosition(ccp(375,hi));
    self.bgLayer:addChild(tLb3,2);
    tLb3:setColor(G_ColorGreen)

    local tLb4 = GetTTFLabel(getlocal("local_war_alliance_feat"),tlbSize);
    tLb4:setAnchorPoint(ccp(0.5,0.5));
    tLb4:setPosition(ccp(540,hi));
    self.bgLayer:addChild(tLb4,2);
    tLb4:setColor(G_ColorGreen)


    local backSprie2=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function () do return end end)
    backSprie2:setContentSize(CCSizeMake(590,self.bgLayer:getContentSize().height-90-40-120-100-40))
    backSprie2:setAnchorPoint(ccp(0.5,0))
    backSprie2:setPosition(self.bgLayer:getContentSize().width/2,30+100)
    self.bgLayer:addChild(backSprie2)

    local desLb = GetTTFLabelWrap(getlocal("serverWarLocal_personalRank_des"),25,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    desLb:setAnchorPoint(ccp(0,0.5))
    desLb:setPosition(CCPointMake(40,80))
    desLb:setColor(G_ColorRed)
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

        local tabStr={getlocal("serverWarLocal_personalRank_tip1"),getlocal("serverWarLocal_personalRank_tip2")}
        local tabColor={G_ColorWhite,G_ColorRed}
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr,tabColor)
    end
    local infoItem = GetButtonItem("SlotInfor.png","SlotInfor.png","SlotInfor.png",touchInfoItem,11,nil,nil)
    local infoMenu=CCMenu:createWithItem(infoItem)
    infoMenu:setPosition(ccp(560,80))
    infoMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(infoMenu)

    self.noRankLb1=GetTTFLabelWrap(getlocal("serverWarLocal_noData"),30,CCSizeMake(self.bgLayer:getContentSize().width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.noRankLb1:setAnchorPoint(ccp(0.5,0.5))
    self.noRankLb1:setColor(G_ColorYellowPro)
    self.noRankLb1:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2))
    self.bgLayer:addChild(self.noRankLb1)
    self.noRankLb1:setVisible(false)

    self.noRankLb2=GetTTFLabelWrap(getlocal("serverWarLocal_noData"),30,CCSizeMake(self.bgLayer:getContentSize().width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.noRankLb2:setAnchorPoint(ccp(0.5,0.5))
    self.noRankLb2:setColor(G_ColorYellowPro)
    self.noRankLb2:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2))
    self.bgLayer:addChild(self.noRankLb2)
    self.noRankLb2:setVisible(false)

    self:tabClick(1)
end

function serverWarLocalAgainstRankTab3:initTableView1()
    local function callBack1(...)
      return self:eventHandler1(...)
    end
    local hd1= LuaEventHandler:createHandler(callBack1)
    local height=0;
    self.tv1=LuaCCTableView:createWithEventHandler(hd1,CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-380+120-15-130),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv1:setPosition(ccp(30,40+100))
    self.bgLayer:addChild(self.tv1,3)
    self.tv1:setMaxDisToBottomOrTop(120)
end

function serverWarLocalAgainstRankTab3:initTableView2()
    local function callBack1(...)
      return self:eventHandler2(...)
    end
    local hd1= LuaEventHandler:createHandler(callBack1)
    local height=0;
    self.tv2=LuaCCTableView:createWithEventHandler(hd1,CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-380+120-15-130),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv2:setPosition(ccp(30,40+100))
    self.bgLayer:addChild(self.tv2,3)
    self.tv2:setMaxDisToBottomOrTop(120)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function serverWarLocalAgainstRankTab3:eventHandler1(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local featRank=self.allPerson.person or {}
        local num=SizeOfTable(featRank)
        if num>0 then
            num=num+1
        end
        local count=self.allPerson.count or 0
        if count>SizeOfTable(featRank) then
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

        local featRank=self.allPerson.person or {}
        local num=SizeOfTable(featRank)+1
        local count = self.allPerson.count
        if num>1 then
            local rect = CCRect(0, 0, 50, 50);
            local capInSet = CCRect(40, 40, 10, 10);
            local capInSetNew=CCRect(20, 20, 10, 10)
            local backSprie
            if count>SizeOfTable(featRank) and idx==num then
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
                selfRank=self.allPerson.myRank
                rankStr=getlocal("alliance_info_content")
                nameStr=playerVoApi:getPlayerName()
                powerStr=playerVoApi:getPlayerPower()
                if selfRank~=nil then
                    if selfRank.rank and tonumber(selfRank.rank)>0 then
                        rankStr=selfRank.rank
                        nameStr=selfRank.nickname 
                        powerStr=selfRank.fc
                        valueStr=selfRank.donate
                    end
                   
                end

            else
                if featRank and featRank[idx] then
                    rankData=featRank[idx]
                    if rankData~=nil then
                        rankStr=rankData.rank
                        nameStr=rankData.nickname
                        powerStr=rankData.fc
                        valueStr=rankData.donate
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
       
   elseif fn=="ccScrollEnable" then
            return 1
    end

end

function serverWarLocalAgainstRankTab3:eventHandler2(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local featRank=self.ownPerson.person or {}
        local num=SizeOfTable(featRank)
        if num>0 then
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

        local featRank=self.ownPerson.person or {}
        local num=SizeOfTable(featRank)+1
        local count = self.allPerson.count or 0
        if num>1 then
            local rect = CCRect(0, 0, 50, 50);
            local capInSet = CCRect(40, 40, 10, 10);
            local capInSetNew=CCRect(20, 20, 10, 10)
            local backSprie
            
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
                selfRank=self.selfInfo
                rankStr=getlocal("alliance_info_content")
                nameStr=playerVoApi:getPlayerName()
                powerStr=playerVoApi:getPlayerPower()
                if selfRank~=nil then
                    if selfRank.rank and tonumber(selfRank.rank)>0 then
                        rankStr=selfRank.rank
                        nameStr=selfRank.nickname
                        powerStr=selfRank.fc
                        valueStr=selfRank.donate
                    end
                    
                end
            else
                if featRank and featRank[idx] then
                    rankData=featRank[idx]
                    if rankData~=nil then
                        rankStr=idx
                        nameStr=rankData.nickname
                        powerStr=rankData.fc
                        valueStr=rankData.donate
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
       
   elseif fn=="ccScrollEnable" then
            return 1
    end

end

function serverWarLocalAgainstRankTab3:cellClick(idx)
    local page = math.floor(idx/20) + 1
    local function callback()
        self:refresh(self.selectedTabIndex)
    end
    serverWarLocalVoApi:getPersonalList(page,callback,nil,false)
end



function serverWarLocalAgainstRankTab3:tabClickColor(idx)
    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
         else
            v:setEnabled(true)
         end
    end
end

function serverWarLocalAgainstRankTab3:tabClick(idx)
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
        if self.tv1==nil then
           self:initTableView1()
           self:refreshNolable(1)
        end
        if  self.tv1 then
            self.tv1:setPosition(ccp(30,40+100))
            self.tv1:setVisible(true)
            self:refreshNolable(1)
        end
        if  self.tv2 then
            self.tv2:setPosition(ccp(999333,0))
            self.tv2:setVisible(false)
        end
    elseif(idx==2)then
        if self.tv2==nil then
            local function callback()
                self:refreshSelfData()
                self:initTableView2()
                self:refreshNolable(2)
            end
           local ownPerson=G_clone(serverWarLocalVoApi:getOwnPerson())
           local person=ownPerson.person or {}
           local ownPersonalListFlag=serverWarLocalVoApi:getOwnPersonalListFlag()
           if SizeOfTable(person)==0 and ownPersonalListFlag[1]==0 then
                serverWarLocalVoApi:getOwnPersonList(callback)
           elseif SizeOfTable(person)==0 and ownPersonalListFlag[2]==0  then
                serverWarLocalVoApi:getOwnPersonList(callback)
           else
                callback()
           end
           
        end
        if  self.tv2 then
            self.tv2:setPosition(ccp(30,40+100))
            self.tv2:setVisible(true)
            self:refreshNolable(2)
        end
        if  self.tv1 then
            self.tv1:setPosition(ccp(999333,0))
            self.tv1:setVisible(false)
        end

    end

end

function serverWarLocalAgainstRankTab3:refresh(flag)
    -- if  flag==1 then
    --     self.allPerson=serverWarLocalVoApi:getAllPerson()
    --     local recordPoint = self.tv1:getRecordPoint()
    --     self.tv1:reloadData()
    --     self.tv1:recoverToRecordPoint(recordPoint)
    -- end
    if flag==1 then
        local num=SizeOfTable(self.allPerson.person or {})
        local count=self.allPerson.count or 0
        local hasMore=false
        if count>num then
            hasMore=true
        end
        self.allPerson=G_clone(serverWarLocalVoApi:getAllPerson())
        local nextHasMore=false
        local newNum=SizeOfTable(self.allPerson.person or {})
        local newCount=self.allPerson.count or 0
        if newCount>newNum then
            nextHasMore=true
        end
        local diffNum=newNum-num
        if nextHasMore then
            diffNum=diffNum+1
        end
        local recordPoint = self.tv1:getRecordPoint()
        self.tv1:reloadData()
        recordPoint.y=-(diffNum-1)*self.cellHeight+recordPoint.y
        self.tv1:recoverToRecordPoint(recordPoint)
    end
    if  flag==2 then
        self:refreshSelfData()
        local recordPoint = self.tv2:getRecordPoint()
        self.tv2:reloadData()
        self.tv2:recoverToRecordPoint(recordPoint)
    end
    self:refreshNolable(flag)
end

function serverWarLocalAgainstRankTab3:refreshSelfData()
    self.ownPerson=G_clone(serverWarLocalVoApi:getOwnPerson())
    local selfUid = playerVoApi:getUid()
    for k,v in pairs(self.ownPerson.person) do
        if tonumber(selfUid) == tonumber(v.uid) then
            self.selfInfo=G_clone(v)
            self.selfInfo.rank=k
        end
    end
end

function serverWarLocalAgainstRankTab3:tick()
    local personalListFlag=serverWarLocalVoApi:getPersonalListFlag()
    if serverWarLocalVoApi:checkStatus()==30 and personalListFlag[2]==0 then
        self:updateList()
        return
    end
    if (serverWarLocalVoApi:checkStatus()>=20 and serverWarLocalVoApi:checkStatus()<30) and serverWarLocalVoApi:isEndOfoneBattle() and personalListFlag[1]==0 then
        self:updateList()
        return
    end

    -- local ts = self.allPerson.ts 
    -- if ts and base.serverTime>ts and serverWarLocalVoApi:checkStatus()==21 then
    --     self:updateList()
    -- end
end

function serverWarLocalAgainstRankTab3:updateList()

    if self.tv1 then
        local function callback()
            self:refresh(1)
        end
        serverWarLocalVoApi:getPersonalList(1,callback)

    end

    if self.tv2 then
        local function callback()
            self:refresh(2)
        end
        serverWarLocalVoApi:getOwnPersonList(callback)

    end
end

function serverWarLocalAgainstRankTab3:refreshNolable(tab)
    if tab==1 then
        if self.allPerson.person and SizeOfTable(self.allPerson.person)==0 then
            self.noRankLb1:setVisible(true)
        else
            self.noRankLb1:setVisible(false)
        end
        self.noRankLb2:setVisible(false)
    else
        if self.ownPerson.person and SizeOfTable(self.ownPerson.person)==0 then
            self.noRankLb2:setVisible(true)
        else
            self.noRankLb2:setVisible(false)
        end
        self.noRankLb1:setVisible(false)
    end
end

function serverWarLocalAgainstRankTab3:dispose()
    self.bgLayer=nil
    self.layerNum=nil
    self.tv1=nil
    self.tv2=nil
    self.cellHeight=nil
    self.selectedTabIndex=nil --当前选中的tab
    self.oldSelectedTabIndex=nil --上一次选中的tab
    self.allTabs=nil
end

