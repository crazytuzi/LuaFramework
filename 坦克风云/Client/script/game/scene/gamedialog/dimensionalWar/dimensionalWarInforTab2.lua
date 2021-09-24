dimensionalWarInforTab2={}

function dimensionalWarInforTab2:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    -- self.cellHeght1=320
    -- self.cellHeght2=200
    self.cellHeght=200
    self.curIndex=1

    return nc
end

function dimensionalWarInforTab2:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self:initTableView()
    return self.bgLayer
end

function dimensionalWarInforTab2:initTableView()
    local backBgHeight=150
    local function touch1()
    end
    local capInSet = CCRect(65, 25, 1, 1);
    local backBg=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",capInSet,touch1)
    backBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,backBgHeight))
    backBg:ignoreAnchorPointForPosition(false)
    backBg:setAnchorPoint(ccp(0.5,1))
    backBg:setIsSallow(true)
    backBg:setTouchPriority(-(self.layerNum-1)*20-1)
    backBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-160))
    self.bgLayer:addChild(backBg,1)

    local iiSize=100
    local icon=CCSprite:createWithSpriteFrameName("RegionalWarRankIcon.png")
    icon:setPosition(30+iiSize/2,backBgHeight/2)
    icon:setScale(1.2)
    backBg:addChild(icon)

    local descLbHeight=0
    local descStr=getlocal("dimensionalWar_rank_reward_desc")
    local rewardDescLb1=GetTTFLabelWrap(descStr,25,CCSizeMake(backBg:getContentSize().width-180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    rewardDescLb1:setAnchorPoint(ccp(0,0.5))
    rewardDescLb1:setPosition(ccp(150,backBg:getContentSize().height/2))
    backBg:addChild(rewardDescLb1,1)
    descLbHeight=descLbHeight+rewardDescLb1:getContentSize().height+30
    
    -- local function updateRankListCallback()
        local function callBack(...)
            return self:eventHandler(...)
        end
        local hd= LuaEventHandler:createHandler(callBack)
        self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-40,self.bgLayer:getContentSize().height-130-80-backBg:getContentSize().height),nil)
        self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
        self.tv:setAnchorPoint(ccp(0,0))
        self.tv:setPosition(ccp(20,40))
        self.tv:setMaxDisToBottomOrTop(120)
        self.bgLayer:addChild(self.tv)
    -- end
    -- localWarVoApi:updateRankList(1,1,updateRankListCallback)
end

function dimensionalWarInforTab2:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local rankRewardCfg=userWarCfg.rankReward
        local num=SizeOfTable(rankRewardCfg)
        return num
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize = CCSizeMake(G_VisibleSizeWidth-40,self.cellHeght)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local rCfg=userWarCfg.rankReward[idx+1]

        local range
        local pic
        local titleStr=""
        local dayNum=0
        local rewardTb={}
        if rCfg then
            range=rCfg.range
            if rCfg.icon then
                pic=rCfg.icon
            end
            -- if rCfg.title then
            --     titleStr=getlocal(rCfg.title)
            -- end
            -- if rCfg.lastTime and rCfg.lastTime[1] then
            --     dayNum=tonumber(rCfg.lastTime[1])
            -- end

            if rCfg.reward then
                rewardTb=FormatItem(rCfg.reward)
            end
        end
        if sCfg and sCfg.reward then
            rewardTb=FormatItem(sCfg.reward)
        end

        local cellWidth=G_VisibleSizeWidth-40
        local cellHeight=self.cellHeght
        -- if isHasServerReward==true then
        --  cellHeight=self.cellHeght1
        -- else
        --  cellHeight=self.cellHeght2
        -- end
        local scaleY=0.65
        local capInSet = CCRect(20, 20, 10, 10)
        local function touch()
        end
        -- local headBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",capInSet,touch)
        -- headBg:setContentSize(CCSizeMake(cellWidth,50))
        -- headBg:ignoreAnchorPointForPosition(false)
        -- headBg:setAnchorPoint(ccp(0.5,1))
        -- headBg:setIsSallow(false)
        -- headBg:setTouchPriority(-(self.layerNum-1)*20-2)
        -- headBg:setPosition(ccp(cellWidth/2,cellHeight))
        -- cell:addChild(headBg,1)
        local headBg=CCSprite:createWithSpriteFrameName("SuccessPanelSmall.png")
        headBg:setAnchorPoint(ccp(0.5,1))
        headBg:setPosition(cellWidth/2,cellHeight)
        headBg:setScaleY(scaleY)
        cell:addChild(headBg,1)

        local rankIcon
        local rankScale=0.8
        if pic then
            rankIcon=CCSprite:createWithSpriteFrameName(pic)
            -- rankIcon:setScale(rankScale)
            rankIcon:setAnchorPoint(ccp(0.5,0.5))
            rankIcon:setPosition(ccp(50,headBg:getContentSize().height/2))
            headBg:addChild(rankIcon,1)
            rankIcon:setScaleY(1/scaleY)
        end

        -- local rankList=localWarVoApi:getFeatRank(1)
        -- local rankVo=rankList[idx+1]

        -- local playerName=""
        -- if rankVo then
        --     playerName=rankVo.name or ""
        -- end
        local rankStr=""
        -- local playerStr=getlocal("local_war_feat_rank_name",{playerName})
        -- if idx>=0 and idx<=2 then
        --     if idx==0 then
        --         rankStr=getlocal("serverwar_first_reward")
        --     elseif idx==1 then
        --         rankStr=getlocal("serverwar_second_reward")
        --     elseif idx==2 then
        --         rankStr=getlocal("serverwar_third_reward")
        --     end
        --     if rankVo and SizeOfTable(rankVo)>0 then
        --         rankStr=rankStr..playerStr
        --     end
        -- else
            if range and range[1] then
                local minRank=range[1]
                if range[2] then
                    local maxRank=range[2]
                    if minRank==maxRank then
                        rankStr=getlocal("dimensionalWar_survive",{minRank})
                    else
                        rankStr=getlocal("dimensionalWar_survive",{minRank.."-"..maxRank})
                    end
                else
                    rankStr=getlocal("dimensionalWar_survive",{minRank})
                end
            end
        -- end
        -- rankStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
        local rankLb=GetTTFLabelWrap(rankStr,25,CCSizeMake(cellWidth-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        rankLb:setAnchorPoint(ccp(0.5,0.5))
        -- rankLb:setPosition(ccp(10,headBg:getContentSize().height/2))
        rankLb:setPosition(getCenterPoint(headBg))
        headBg:addChild(rankLb,1)
        rankLb:setScaleY(1/scaleY)
        rankLb:setColor(G_ColorYellowPro)
        -- if rankIcon then
        --     rankLb:setPosition(ccp(rankIcon:getContentSize().width*rankScale+10,headBg:getContentSize().height/2))
        -- end

        -- local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,touch)
        -- backSprie:setContentSize(CCSizeMake(cellWidth-10,cellHeight-headBg:getContentSize().height*scaleY))
        -- backSprie:ignoreAnchorPointForPosition(false)
        -- backSprie:setAnchorPoint(ccp(0.5,1))
        -- backSprie:setIsSallow(false)
        -- backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
        -- backSprie:setPosition(ccp(cellWidth/2,cellHeight-headBg:getContentSize().height*scaleY))
        -- cell:addChild(backSprie,1)

        local backHeight=cellHeight-headBg:getContentSize().height*scaleY
        if rewardTb and SizeOfTable(rewardTb)>0 then
            local iconSize=100
            for k,v in pairs(rewardTb) do
                local function callback11()
                    if self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                        return true
                    end
                end
                local icon,scale=G_getItemIcon(v,iconSize,true,self.layerNum,callback11)
                icon:setTouchPriority(-(self.layerNum-1)*20-2)
                icon:setPosition(iconSize/2+50+(iconSize+20)*(k-1),backHeight/2)
                cell:addChild(icon,1)

                local numStr="x"..FormatNumber(v.num)
                local numLb=GetTTFLabel(numStr,25)
                numLb:setAnchorPoint(ccp(1,0))
                numLb:setPosition(ccp(icon:getContentSize().width-5,5))
                numLb:setScale(1/scale)
                icon:addChild(numLb,1)
            end
        end 

        -- local desc2=getlocal("serverwar_reward_desc2",{point})
        -- -- desc2="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
        -- local descLb2=GetTTFLabelWrap(desc2,22,CCSizeMake(cellWidth-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        -- descLb2:setAnchorPoint(ccp(0,0.5))
        -- descLb2:setPosition(ccp(20,backSprie:getContentSize().height/2))
        -- backSprie:addChild(descLb2,1)

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
    end
end

function dimensionalWarInforTab2:tick()

end

function dimensionalWarInforTab2:dispose()
    self.bgLayer=nil
    self.layerNum=nil
    -- self.cellHeght1=nil
    -- self.cellHeght2=nil
    self.cellHeght=nil
    self.curIndex=nil
end