acMidAutumnRank={}

function acMidAutumnRank:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    self.tv=nil
    self.bgLayer=nil
    
    self.layerNum=nil
    self.parent=nil
    self.noRankLb=nil
    self.rankList=nil
    self.cellNum=0
    self.isEnd=false
    self.blessPointLb=nil
    
    return nc
end

function acMidAutumnRank:init(layerNum,parent)
    local strSize2 = 22
    local subHeight = 308
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        strSize2 =25
        subHeight = 320
    end
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self.rankList=acMidAutumnVoApi:getRankList()
    self.cellNum=SizeOfTable(self.rankList) + 1
    self.isEnd=acMidAutumnVoApi:acIsStop()

    self:tick()
    self:initTitleAndBtn()
    self:initTableView()

    local function click(hd,fn,idx)
    end
    local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),click)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight-465))
    tvBg:ignoreAnchorPointForPosition(false)
    tvBg:setAnchorPoint(ccp(0,0))
    tvBg:setPosition(ccp(25,35))
    self.bgLayer:addChild(tvBg)

    self.noRankLb=GetTTFLabelWrap(getlocal("activity_fightRanknew_no_rank"),25,CCSizeMake(self.bgLayer:getContentSize().width-80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.noRankLb:setAnchorPoint(ccp(0.5,0.5))
    self.noRankLb:setPosition(tvBg:getContentSize().width/2,tvBg:getContentSize().height/2)
    tvBg:addChild(self.noRankLb,1)
    self.noRankLb:setColor(G_ColorGray)

    local blessPointStr=getlocal("bless_point").."："..acMidAutumnVoApi:getBlessPoint()
    local blessPointLb=GetTTFLabelWrap(blessPointStr,strSize2,CCSize(G_VisibleSizeWidth*0.4,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    blessPointLb:setAnchorPoint(ccp(0,0))
    blessPointLb:setPosition(40,tvBg:getPositionY()+tvBg:getContentSize().height+60)
    self.bgLayer:addChild(blessPointLb)
    self.blessPointLb=blessPointLb

    local promptLb=GetTTFLabelWrap(getlocal("rankin_prompt",{acMidAutumnVoApi:getRankLimit()}),strSize2,CCSize(G_VisibleSizeWidth-50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    promptLb:setAnchorPoint(ccp(0,0))
    promptLb:setPosition(40,blessPointLb:getPositionY() - 40)
    promptLb:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(promptLb)

    self:refreshMyRank()
    
    return self.bgLayer
end

function acMidAutumnRank:initTableView()
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight-520),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(25,45))
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)
end

function acMidAutumnRank:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(G_VisibleSizeWidth-50,76)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local cellWidth=G_VisibleSizeWidth-50
        local cellHeight=76
        local rank
        local rankStr
        local name
        local value
        local rankData
        if idx == 0 then
            rank,rankStr=acMidAutumnVoApi:getRankShowIndex()
            name=playerVoApi:getPlayerName()
            value=acMidAutumnVoApi:getBlessPoint()
        else
            rankData = self.rankList[idx]
        end
        if rankData then
            rank=idx
            name=rankData[2] or ""
            value=rankData[3] or 0
        end
        
        

        if rank and name and value then
            local height=40
            local w=(G_VisibleSizeWidth-60)/3
            local function getX(index)
                return -5+w*index+w/2
            end
            local capInSet = CCRect(40, 40, 10, 10);
            local capInSetNew=CCRect(20, 20, 10, 10)
            local widthSpace=50
            local backSprie

            local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png", CCRect(4, 4, 1, 1), function () end)
            backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-58,76))
            backSprie:setPosition(ccp(cellWidth/2,cellHeight/2))
            cell:addChild(backSprie)
            backSprie:setOpacity(idx % 2 * 255)
            local height=backSprie:getContentSize().height/2

            if tonumber(rank) >= 1 and tonumber(rank) <= 3 then
                local signSp = CCSprite:createWithSpriteFrameName("top_" .. rank .. ".png")
                signSp:setPosition(ccp(cellWidth / 2, cellHeight / 2 + 4))
                signSp:setScaleY((cellHeight-10)/signSp:getContentSize().height)
                signSp:setScaleX((cellWidth-10)/signSp:getContentSize().width)
                cell:addChild(signSp, 1)

                local rankSp=CCSprite:createWithSpriteFrameName("top" .. rank .. ".png")
                rankSp:setAnchorPoint(ccp(0.5,0.5))
                rankSp:setScale(0.7)
                rankSp:setPosition(ccp(getX(0),height))
                cell:addChild(rankSp,3)
            else
                local rankLabel
                if idx == 0 then
                    -- 第一条是自己
                    rankLabel=GetTTFLabel(rankStr,25)
                else
                    -- 默认
                    rankLabel=GetTTFLabel(rank,25)
                end
                rankLabel:setAnchorPoint(ccp(0.5,0.5))
                rankLabel:setPosition(getX(0),height)
                cell:addChild(rankLabel,2)
            end
          
            local playerNameLabel=GetTTFLabelWrap(name,25,CCSizeMake(175,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            playerNameLabel:setAnchorPoint(ccp(0.5,0.5))
            playerNameLabel:setPosition(getX(1),height)
            cell:addChild(playerNameLabel,2)
            
            local valueLabel=GetTTFLabel(FormatNumber(value),25)
            valueLabel:setAnchorPoint(ccp(0.5,0.5))
            valueLabel:setPosition(getX(2),height)
            cell:addChild(valueLabel,2)
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

function acMidAutumnRank:tick()
    local isEnd=acMidAutumnVoApi:acIsStop()
    if isEnd~=self.isEnd and isEnd==true then
        self.isEnd=isEnd
        local canReward=acMidAutumnVoApi:canRankReward()
        if canReward==true then
        end
    end
end

--用户处理特殊需求,没有可以不写此方法
function acMidAutumnRank:initTitleAndBtn()
    local rect=CCRect(0, 0, 50, 50)
    local function touch(hd,fn,idx)

    end
    local height=455
    local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("ltzdzNameBg.png",CCRect(4, 4, 1, 1),touch)
    backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-56,38))
    backSprie:ignoreAnchorPointForPosition(false)
    backSprie:setAnchorPoint(ccp(0.5,0.5))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
    backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-height))
    self.bgLayer:addChild(backSprie,1)

    local w=(G_VisibleSizeWidth-60)/3
    local function getX(index)
        return 20+w*index+w/2-35
    end

    local height=G_VisibleSizeHeight-305
    local lbSize=18
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        lbSize = 22
    end
    local widthSpace=80
    local color=G_ColorYellowPro2
    local rankLabel=GetTTFLabel(getlocal("alliance_scene_rank_title"),lbSize)
    rankLabel:setPosition(getX(0),backSprie:getContentSize().height/2)
    backSprie:addChild(rankLabel,1)
    rankLabel:setColor(color)
  
    local playerNameLabel=GetTTFLabel(getlocal("playerName"),lbSize)
    playerNameLabel:setPosition(getX(1),backSprie:getContentSize().height/2)
    backSprie:addChild(playerNameLabel,1)
    playerNameLabel:setColor(color)
    
    local valueLabel=GetTTFLabel(getlocal("bless_point"),lbSize)
    valueLabel:setPosition(getX(2),backSprie:getContentSize().height/2)
    backSprie:addChild(valueLabel,1)
    valueLabel:setColor(color)

    local rewardLb=GetTTFLabel(getlocal("award"),lbSize)
    rewardLb:setPosition(getX(3),backSprie:getContentSize().height/2)
    backSprie:addChild(rewardLb,1)
    rewardLb:setColor(color)
end

function acMidAutumnRank:refresh()
end

function acMidAutumnRank:refreshMyRank()
end

function acMidAutumnRank:updateUI()
    if self then
        self:refresh()
        if self.tv then
            self.rankList=acMidAutumnVoApi:getRankList()
            self.cellNum=SizeOfTable(self.rankList) + 1
            self.tv:reloadData()
        end
        if self.noRankLb then
            local rankList=acMidAutumnVoApi:getRankList()
            if rankList and SizeOfTable(rankList)>0 then
                self.noRankLb:setVisible(false)
            else
                self.noRankLb:setVisible(true)
            end
        end
        if self.blessPointLb then
            local blessPointStr=getlocal("bless_point").."："..acMidAutumnVoApi:getBlessPoint()
            self.blessPointLb:setString(blessPointStr)
            self:refreshMyRank()
        end
    end
end

function acMidAutumnRank:dispose()
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
    self.tv=nil
    self.layerNum=nil
    self.parent=nil
    self.noRankLb=nil
    self.rankList=nil
    self.cellNum=0
    self.blessPointLb=nil
    self=nil
end
