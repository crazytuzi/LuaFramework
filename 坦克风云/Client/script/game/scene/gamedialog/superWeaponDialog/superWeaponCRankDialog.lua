superWeaponCRankDialog=commonDialog:new()
function superWeaponCRankDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.rankLabel=nil
    self.nameLabel=nil
    self.levelLabel=nil
    self.valueLabel=nil
    self.labelTab={}
    self.cellHeight=72
    return nc
end

--设置对话框里的tableView
function superWeaponCRankDialog:initTableView()
    self.panelLineBg:setAnchorPoint(ccp(0.5,0))
    self.panelLineBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,G_VisibleSize.height-110))
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,25))

    self:doUserHandler()

    superWeaponVoApi:clearCRankData()
    local function getRankCallback()
        local function callBack(...)
            return self:eventHandler(...)
        end
        local hd= LuaEventHandler:createHandler(callBack)
        self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-180),nil)
        self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
        self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
        self.tv:setPosition(ccp(30,50))
        self.bgLayer:addChild(self.tv)
        self.tv:setMaxDisToBottomOrTop(120)
    end
    superWeaponVoApi:getSWChallengeRank(1,getRankCallback)
end

function superWeaponCRankDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local rData=superWeaponVoApi:getCRankData()
        local num=1
        if rData and rData.rankData then
            num=num+SizeOfTable(rData.rankData)
            if rData.isMore==true then
                num=num+1
            end
        end
        return num
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(400,self.cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local rData=superWeaponVoApi:getCRankData()
        local hasMore=false
        local num=1
        if rData then
            if rData.rankData then
                num=num+SizeOfTable(rData.rankData)
            end
            hasMore=rData.isMore
        end
    
        local cell=CCTableViewCell:new()
        cell:autorelease()
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
        local levelStr=""
        local valueStr=""
        if idx==0 then
            selfRank=rData.selfRank
            if selfRank~=nil then
                rankStr=selfRank.rank
                nameStr=selfRank.name
                levelStr=selfRank.level
                valueStr=selfRank.value
            end
        else
            if rData.rankData~=nil then
                rankData=rData.rankData[idx]
                if rankData~=nil then
                    rankStr=rankData.rank
                    nameStr=rankData.name
                    levelStr=rankData.level
                    valueStr=rankData.value
                end
            end
        end
        
        local rankLabel=GetTTFLabel(rankStr,24)
        rankLabel:setPosition(widthSpace,height)
        cell:addChild(rankLabel,2)
        table.insert(self.labelTab,idx,{rankLabel=rankLabel})
        
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

        local nameLabel=GetTTFLabel(nameStr,24)
        nameLabel:setPosition(widthSpace+150,height)
        cell:addChild(nameLabel,2)
        self.labelTab[idx].nameLabel=nameLabel

        local levelLabel=GetTTFLabel(getlocal("fightLevel",{levelStr}),24)
        levelLabel:setPosition(widthSpace+150*2+20,height)
        cell:addChild(levelLabel,2)
        self.labelTab[idx].levelLabel=levelLabel

        if self.selectedTabIndex==1 then
            local valueLabel=GetTTFLabel(valueStr,24)
            valueLabel:setPosition(widthSpace+150*3-15,height)
            cell:addChild(valueLabel,2)
            self.labelTab[idx].valueLabel=valueLabel
            
            local starIcon = CCSprite:createWithSpriteFrameName("StarIcon.png")
            starIcon:setPosition(ccp(widthSpace+150*3+35,height))
            cell:addChild(starIcon,2)
        else
            local valueLabel=GetTTFLabel(FormatNumber(valueStr),24)
            valueLabel:setPosition(widthSpace+150*3,height)
            cell:addChild(valueLabel,2)
            self.labelTab[idx].valueLabel=valueLabel
        end
        --[[
        if idx==0 then
            self:setColor(idx,G_ColorYellow)
        elseif idx==1 then
            self:setColor(idx,G_ColorOrange)
        elseif idx==2 then
            self:setColor(idx,G_ColorPurple)
        elseif idx==3 then
            self:setColor(idx,G_ColorBlue)
        end
        ]]
        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
       
    end
end

function superWeaponCRankDialog:setColor(idx,color)
    self.labelTab[idx].rankLabel:setColor(color)
    self.labelTab[idx].nameLabel:setColor(color)
    self.labelTab[idx].levelLabel:setColor(color)
    self.labelTab[idx].valueLabel:setColor(color)
end

function superWeaponCRankDialog:doUserHandler()
    local height=self.bgLayer:getContentSize().height-110
    local widthSpace=80
    if self.rankLabel==nil then
        self.rankLabel=GetTTFLabel(getlocal("RankScene_rank"),24)
        self.rankLabel:setPosition(widthSpace,height)
        self.bgLayer:addChild(self.rankLabel,1)
    end
    
    if self.nameLabel==nil then
        self.nameLabel=GetTTFLabel(getlocal("RankScene_name"),24)
        self.nameLabel:setPosition(widthSpace+150,height)
        self.bgLayer:addChild(self.nameLabel,1)
    end
    
    if self.levelLabel==nil then
        self.levelLabel=GetTTFLabel(getlocal("RankScene_level"),24)
        self.levelLabel:setPosition(widthSpace+150*2+20,height)
        self.bgLayer:addChild(self.levelLabel,1)
    end
    
    if self.valueLabel==nil then
        self.valueLabel=GetTTFLabel(getlocal("super_weapon_challenge_floors_num"),24)
        self.valueLabel:setPosition(widthSpace+150*3,height)
        self.bgLayer:addChild(self.valueLabel,1)
    end
    -- if self.selectedTabIndex==0 then
    --     self.valueLabel:setString(getlocal("RankScene_power"))
    -- elseif self.selectedTabIndex==1 then
    --     self.valueLabel:setString(getlocal("RankScene_star_num"))
    -- elseif self.selectedTabIndex==2 then
    --     self.valueLabel:setString(getlocal("RankScene_honor"))
    -- end
end


--点击了cell或cell上某个按钮
function superWeaponCRankDialog:cellClick(idx)
    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        local rData=superWeaponVoApi:getCRankData()
        if rData and rData.rankData then
            local hasMore=rData.isMore
            local num=SizeOfTable(rData.rankData)
            if hasMore and tostring(idx)==tostring(tonumber(num)+1) then
                PlayEffect(audioCfg.mouseClick)
                local function getRankCallback(fn,data)
                    local nowRData=superWeaponVoApi:getCRankData()
                    local nextHasMore=nowRData.isMore
                    local nowNum=SizeOfTable(nowRData.rankData)
                    local recordPoint = self.tv:getRecordPoint()
                    self.tv:reloadData()
                    -- self:doUserHandler()
                    if nextHasMore then
                        recordPoint.y=(num-nowNum)*self.cellHeight+recordPoint.y
                    else
                        recordPoint.y=(num-nowNum+1)*self.cellHeight+recordPoint.y
                    end
                    self.tv:recoverToRecordPoint(recordPoint)
                end
                local page=rData.page+1
                superWeaponVoApi:getSWChallengeRank(page,getRankCallback)
            end
        end
    end
end

function superWeaponCRankDialog:dispose()
    self.rankLabel=nil
    self.nameLabel=nil
    self.levelLabel=nil
    self.valueLabel=nil
    self.labelTab=nil
    self.cellHeight=nil
end





