acFightRankTab2 = {
    
}

function acFightRankTab2:new(parent)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    
    self.tv = nil
    self.bgLayer = nil
    
    self.layerNum = nil
    self.lowFightLabel = nil
    
    return nc;
    
end

function acFightRankTab2:init(layerNum)
    self.maxRank = acFightRankVoApi:getMaxRank()
    
    self.bgLayer = CCLayer:create()
    self.layerNum = layerNum
    local function click(hd, fn, idx)
    end
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png", CCRect(20, 20, 10, 10), click)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 50, G_VisibleSizeHeight - 300))
    tvBg:ignoreAnchorPointForPosition(false)
    tvBg:setAnchorPoint(ccp(0, 0))
    tvBg:setPosition(ccp(25, 30))
    self.bgLayer:addChild(tvBg)
    
    local lowFight = acFightRankVoApi:getDifferFight() --  玩家与冠军相差的战力
    self.lowFightLabel = GetTTFLabelWrap(getlocal("activity_fightRank_lowFight", {FormatNumber(lowFight)}), 25, CCSizeMake(G_VisibleSizeWidth - 100, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    self.lowFightLabel:setAnchorPoint(ccp(0.5, 0.5))
    self.lowFightLabel:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight - 200)
    self.bgLayer:addChild(self.lowFightLabel, 2)
    
    -- local function touch(tag,object)
    --   self:openInfo()
    -- end
    
    -- local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,nil,nil,0)
    -- menuItemDesc:setScaleX(0.9)
    -- menuItemDesc:setScaleY(0.9)
    -- local menuDesc=CCMenu:createWithItem(menuItemDesc)
    -- menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
    -- menuDesc:setPosition(ccp(G_VisibleSizeWidth - 70, G_VisibleSizeHeight - 200))
    -- self.bgLayer:addChild(menuDesc)
    
    self:initTitles()
    self:initTableView()
    return self.bgLayer
end

-- function acFightRankTab2:getAwardStr(reward)
--   local awardTab = reward
--   local str ="     "
--   if awardTab then
--     for k,v in pairs(awardTab) do
--       if k==SizeOfTable(awardTab) then
--         str = str .. v.name .. " x" .. v.num
--       else
--         str = str .. v.name .. " x" .. v.num .. ",".."\n"
--       end
--     end
--   end
--   return str
-- end

-- function acFightRankTab2:openInfo()
--   local tabStr = {}
--   local tabColor = {}
--   local cfg = activityCfg["fightRank"]
--   local len = SizeOfTable(cfg)
--   local rank
--   local award
--   for i=len,1,-1 do
--     rank = cfg[i].rank
--     award = cfg[i].award
--     table.insert(tabStr,"\n")
--     table.insert(tabColor,G_ColorWhite)

--     table.insert(tabStr,self:getAwardStr(FormatItem(award,true)))
--     table.insert(tabColor,G_ColorYellowPro)
--     if SizeOfTable(rank) > 1 then
--       table.insert(tabStr,getlocal("rankTwo",{rank[1],rank[2]}))
--     else
--       table.insert(tabStr,getlocal("rankOne",{rank[1]}))
--     end
--     table.insert(tabColor,G_ColorWhite)
--   end

--   local td=smallDialog:new()

--   local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,tabColor,getlocal("award"))
--   sceneGame:addChild(dialog,self.layerNum+1)
-- end

function acFightRankTab2:updateLowFightLabel()
    local lowFight = acFightRankVoApi:getDifferFight() --  玩家与冠军相差的战力
    if self.lowFightLabel ~= nil then
        self.lowFightLabel:setString(getlocal("activity_fightRank_lowFight", {FormatNumber(lowFight)}))
    end
end

function acFightRankTab2:initTableView()
    self.maxRank = acFightRankVoApi:getMaxRank()
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(G_VisibleSizeWidth - 50, G_VisibleSizeHeight - 320), nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition(ccp(25, 40))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
end

function acFightRankTab2:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        if acFightRankVoApi.isMore == true then
            return SizeOfTable(acFightRankVoApi.rankList) + 2
        end
        return SizeOfTable(acFightRankVoApi.rankList) + 1
    elseif fn == "tableCellSizeForIndex" then
        local tmpSize = CCSizeMake(G_VisibleSizeWidth - 50, 76)
        return tmpSize
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local hasMore = acFightRankVoApi.isMore
        local num = acFightRankVoApi:getRankNum()
        local capInSetNew = CCRect(20, 20, 10, 10)
        local backSprie
        if hasMore and idx == num then
            -- 显示后XX名
            local function cellClick(hd, fn, idx)
                self:cellClick(idx)
            end
            backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("ItemBtnMore.png", capInSetNew, cellClick)
            backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width - 60, 72))
            backSprie:ignoreAnchorPointForPosition(false)
            backSprie:setAnchorPoint(ccp(0, 0))
            backSprie:setIsSallow(false)
            backSprie:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
            backSprie:setTag(idx)
            cell:addChild(backSprie, 1)
            
            local moreLabel = GetTTFLabel(getlocal("showMore"), 30)
            moreLabel:setPosition(getCenterPoint(backSprie))
            backSprie:addChild(moreLabel, 2)
            
            do
                return cell
            end
        end
        
        local acVo = acFightRankVoApi:getAcVo()
        if acVo then
            local backSprie
            local capInSetNew = CCRect(20, 20, 10, 10)
            local capInSet = CCRect(40, 40, 10, 10)
            local function cellClick1(hd, fn, idx)
            end
            if idx == 0 then
                backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png", capInSetNew, cellClick1)
            elseif idx == 1 then
                backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("rank1ItemBg.png", capInSetNew, cellClick1)
            elseif idx == 2 then
                backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("rank2ItemBg.png", capInSetNew, cellClick1)
            elseif idx == 3 then
                backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("rank3ItemBg.png", capInSetNew, cellClick1)
            else
                backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png", capInSet, cellClick1)
            end
            backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth - 70, 72))
            backSprie:ignoreAnchorPointForPosition(false)
            backSprie:setAnchorPoint(ccp(0, 0))
            backSprie:setIsSallow(false)
            backSprie:setPosition(ccp(10, 0))
            backSprie:setTouchPriority(-42)
            cell:addChild(backSprie, 1)
            local height = 40
            local w = (G_VisibleSizeWidth - 60) / 4
            local function getX(index)
                return 5 + w * index + w / 2
            end
            local allianceVo
            if idx == 0 then
                if acFightRankVoApi.selfList ~= nil and SizeOfTable(acFightRankVoApi.selfList) > 0 then
                    allianceVo = acFightRankVoApi.selfList
                else
                    local playerPower = playerVoApi:getPlayerPower()
                    local playerN = playerVoApi:getPlayerName()
                    local selfAlliance = allianceVoApi:getSelfAlliance()
                    if selfAlliance ~= nil then
                        allianceVo = {0, playerN, 0, playerPower, selfAlliance.name}
                    else
                        allianceVo = {0, playerN, 0, playerPower, getlocal("noAlliance")}
                    end
                end
            else
                allianceVo = acFightRankVoApi.rankList[idx]
            end
            
            if allianceVo ~= nil then
                local rankStr = 0
                local playerName = "" --玩家名字
                local valueStr = 0 -- 战斗力
                local nameStr = "" -- 军团名字
                if allianceVo then
                    rankStr = allianceVo[3]
                    playerName = allianceVo[2]
                    valueStr = tonumber(allianceVo[4])
                    if allianceVo[5] ~= nil then
                        nameStr = allianceVo[5]
                    else
                        nameStr = getlocal("noAlliance")
                    end
                    local uid = allianceVo[1]
                    if tonumber(uid) == tonumber(playerVoApi:getUid()) then
                        playerName = playerVoApi:getPlayerName()
                    end
                end
                
                local rankSp
                if tonumber(rankStr) == 1 then
                    rankSp = CCSprite:createWithSpriteFrameName("top1.png")
                elseif tonumber(rankStr) == 2 then
                    rankSp = CCSprite:createWithSpriteFrameName("top2.png")
                elseif tonumber(rankStr) == 3 then
                    rankSp = CCSprite:createWithSpriteFrameName("top3.png")
                elseif tonumber(rankStr) == 0 then
                    rankStr = getlocal("activity_fbReward_rankLow", {self.maxRank})
                end
                if rankSp then
                    rankSp:setAnchorPoint(ccp(0.5, 0.5))
                    rankSp:setPosition(ccp(getX(0), height))
                    cell:addChild(rankSp, 3)
                else
                    local rankLabel = GetTTFLabel(rankStr, 25)
                    rankLabel:setAnchorPoint(ccp(0.5, 0.5))
                    rankLabel:setPosition(getX(0), height)
                    cell:addChild(rankLabel, 2)
                end
                
                local playerNameLabel = GetTTFLabelWrap(playerName, 25, CCSizeMake(175, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
                playerNameLabel:setAnchorPoint(ccp(0.5, 0.5))
                playerNameLabel:setPosition(getX(1), height)
                cell:addChild(playerNameLabel, 2)
                
                local valueLabel = GetTTFLabel(FormatNumber(valueStr), 25)
                valueLabel:setAnchorPoint(ccp(0.5, 0.5))
                valueLabel:setPosition(getX(2), height)
                cell:addChild(valueLabel, 2)
                
                local nameLabel = GetTTFLabelWrap(nameStr, 25, CCSizeMake(125, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
                nameLabel:setAnchorPoint(ccp(0.5, 0.5))
                nameLabel:setPosition(getX(3), height)
                cell:addChild(nameLabel, 2)
            end
        end
        
        return cell
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
        return true
    elseif fn == "ccTouchMoved" then
        self.isMoved = true
    elseif fn == "ccTouchEnded" then
        
    end
end

--点击了cell或cell上某个按钮
function acFightRankTab2:cellClick(idx)
    if self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
        local hasMore = acFightRankVoApi.isMore
        local num = acFightRankVoApi:getRankNum()
        
        if hasMore and tostring(idx) == tostring(num) and idx < self.maxRank then
            PlayEffect(audioCfg.mouseClick)
            
            local function rankingHandler(fn, data)
                local ret, sData = base:checkServerData(data)
                if ret == true then
                    if sData ~= nil then
                        acFightRankVoApi:updateRankList(sData, false)
                        local nowNum = acFightRankVoApi:getRankNum()
                        local nextHasMore = acFightRankVoApi.isMore
                        
                        local recordPoint = self.tv:getRecordPoint()
                        self.tv:reloadData()
                        if nextHasMore then
                            recordPoint.y = (num - nowNum) * 76 + recordPoint.y
                        else
                            recordPoint.y = (num - nowNum + 1) * 76 + recordPoint.y
                        end
                        self.tv:recoverToRecordPoint(recordPoint)
                    end
                end
            end
            local perNum = 20
            local startIndex = idx
            local endIndex = startIndex + perNum - 1
            if endIndex >= self.maxRank then
                endIndex = self.maxRank
            end
            socketHelper:getFightRankList(startIndex, endIndex, rankingHandler)
        end
        
    end
end

function acFightRankTab2:tick()
    
end

--用户处理特殊需求,没有可以不写此方法
function acFightRankTab2:initTitles()
    
    local w = (G_VisibleSizeWidth - 40) / 4
    local function getX(index)
        return 20 + w * index + w / 2
    end
    
    local height = G_VisibleSizeHeight - 250
    local lbSize = 22
    local widthSpace = 80
    local color = G_ColorGreen
    local rankLabel = GetTTFLabel(getlocal("alliance_scene_rank_title"), lbSize)
    rankLabel:setPosition(getX(0), height)
    self.bgLayer:addChild(rankLabel, 1)
    rankLabel:setColor(color)
    
    local playerNameLabel = GetTTFLabel(getlocal("playerName"), lbSize)
    playerNameLabel:setPosition(getX(1), height)
    self.bgLayer:addChild(playerNameLabel, 1)
    playerNameLabel:setColor(color)
    
    local valueLabel = GetTTFLabel(getlocal("alliance_scene_alliance_power_title"), lbSize)
    valueLabel:setPosition(getX(2), height)
    self.bgLayer:addChild(valueLabel, 1)
    valueLabel:setColor(color)
    
    local nameLabel = GetTTFLabel(getlocal("alliance_scene_alliance_name_title"), lbSize)
    nameLabel:setPosition(getX(3), height)
    self.bgLayer:addChild(nameLabel, 1)
    nameLabel:setColor(color)
    
end

function acFightRankTab2:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer = nil
    self.lowFightLabel = nil
    self.tv = nil
    self.layerNum = nil
    self.maxRank = nil
    self = nil
end
