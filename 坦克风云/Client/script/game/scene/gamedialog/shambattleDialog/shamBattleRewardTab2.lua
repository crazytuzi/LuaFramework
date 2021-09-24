shamBattleRewardTab2 = {}

function shamBattleRewardTab2:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.bgLayer=nil
	self.layerNum=nil
	self.normalHeight=100
	return nc
end

function shamBattleRewardTab2:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum

    self.rankCfg = arenaVoApi:getRankRewardCfg() or {}
	self:initLayer()
    self:initTableView()
	return self.bgLayer
end

function shamBattleRewardTab2:initLayer()
	local backSprie1=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),function () do return end end)
    backSprie1:setContentSize(CCSizeMake(595,200))
    backSprie1:setAnchorPoint(ccp(0.5,1))
    backSprie1:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-165)
    self.bgLayer:addChild(backSprie1)

    -- 我的排名
    local rankStr = getlocal("shanBattle_myRank",{arenaVoApi:getRanking()})
    local myRankLb = GetTTFLabelWrap(rankStr,30,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    backSprie1:addChild(myRankLb)
    myRankLb:setAnchorPoint(ccp(0.5,1))
    myRankLb:setPosition(backSprie1:getContentSize().width/2, backSprie1:getContentSize().height-10)
    myRankLb:setColor(G_ColorGreen)

    local tb,rankNum= self:getMyRankReward()
    local item = FormatItem(tb)
    local rankStr = self:getNumRank(rankNum)
    if rankNum==SizeOfTable(self.rankCfg) then
        rankStr=getlocal("shamBattle_limitRank",{self.rankCfg[rankNum].range[1]})
    end


    local desLb = GetTTFLabelWrap(getlocal("shanBattle_nowReward",{rankStr}),25,CCSizeMake(500,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    backSprie1:addChild(desLb)
    desLb:setAnchorPoint(ccp(0,1))
    desLb:setPosition(10, backSprie1:getContentSize().height-10-myRankLb:getContentSize().height-10)


    

    for k,v in pairs(item) do
        local iconSp = G_getItemIcon(v,80,true,self.layerNum+1)
        iconSp:setAnchorPoint(ccp(0,0))
        iconSp:setPosition(10+(k-1)*90+150, 15)
        iconSp:setTouchPriority(-(self.layerNum-1)*20-4)
        iconSp:setScale(80/iconSp:getContentSize().width)
        backSprie1:addChild(iconSp)

        local numLb = GetTTFLabel(v.num,25)
        numLb:setAnchorPoint(ccp(1,0))
        numLb:setPosition(ccp(iconSp:getContentSize().width-5,5))
        iconSp:addChild(numLb)
    end

    local backSprie2=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),function () do return end end)
    backSprie2:setContentSize(CCSizeMake(595,self.bgLayer:getContentSize().height-400))
    backSprie2:setAnchorPoint(ccp(0.5,0))
    backSprie2:setPosition(self.bgLayer:getContentSize().width/2,30)
    self.bgLayer:addChild(backSprie2)

    local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20  , 20, 10, 10),function ()end)
    titleBg:setTouchPriority(-(self.layerNum-1)*20-4)
    titleBg:setContentSize(CCSizeMake(backSprie2:getContentSize().width,  50))
    titleBg:setPosition(ccp((G_VisibleSizeWidth-60)/2,backSprie2:getContentSize().height-25))
    backSprie2:addChild(titleBg,4)

    local rankLb = GetTTFLabelWrap(getlocal("award"),25,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleBg:addChild(rankLb)
    rankLb:setAnchorPoint(ccp(0.5,0.5))
    rankLb:setPosition(105, titleBg:getContentSize().height/2)
    rankLb:setColor(G_ColorGreen)

    local rewardLb = GetTTFLabelWrap(getlocal("alliance_scene_rank"),25,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleBg:addChild(rewardLb)
    rewardLb:setAnchorPoint(ccp(0.5,0.5))
    rewardLb:setPosition(385, titleBg:getContentSize().height/2)
    rewardLb:setColor(G_ColorGreen)
    -- alliance_scene_rank

    -- 奖励时间说明
    local timeBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20  , 20, 10, 10),function ()end)
    timeBg:setTouchPriority(-(self.layerNum-1)*20-4)
    timeBg:setContentSize(CCSizeMake(backSprie2:getContentSize().width,  70))
    timeBg:setPosition(ccp((G_VisibleSizeWidth-60)/2,25))
    backSprie2:addChild(timeBg,4)

    local timeDesLb = GetTTFLabelWrap(getlocal("shanBattle_sendTime"),25,CCSizeMake(500,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    timeBg:addChild(timeDesLb)
    timeDesLb:setAnchorPoint(ccp(0,0.5))
    timeDesLb:setPosition(30, timeBg:getContentSize().height/2)
    timeDesLb:setColor(G_ColorRed)
    self.timeDesLb=timeDesLb

    


end

function shamBattleRewardTab2:initTableView()
    
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-40,self.bgLayer:getContentSize().height-100-200-100-30-self.timeDesLb:getContentSize().height-40),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,50+self.timeDesLb:getContentSize().height))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(120)

end

function shamBattleRewardTab2:eventHandler(handler,fn,idx,cel)
	 if fn=="numberOfCellsInTableView" then	 	
        return SizeOfTable(self.rankCfg)
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-40,self.normalHeight)
		return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease() 

        local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
        lineSp:setAnchorPoint(ccp(0,0));
        lineSp:setPosition(ccp(0,-5));
        cell:addChild(lineSp,1)
        
        local width1 = 100
        local width2 = 200
        local height1 = self.normalHeight/2
        if idx<3 then
            local rankSp=CCSprite:createWithSpriteFrameName("top" .. idx+1 .. ".png")
            cell:addChild(rankSp)
            rankSp:setAnchorPoint(ccp(0.5,0.5))
            rankSp:setPosition(width1, height1)
        else
            local numRankStr = self:getNumRank(idx+1)
            local rankStr = getlocal("rankOne",{numRankStr})
            if SizeOfTable(self.rankCfg) == idx+1 then
                rankStr=getlocal("shamBattle_limitRank",{self.rankCfg[idx+1].range[1]})
            end
            local rankLb = GetTTFLabelWrap(rankStr,25,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            cell:addChild(rankLb)
            rankLb:setPosition(width1, height1)
            rankLb:setColor(G_ColorYellowPro)
        end

        -- local tb = {r={r4=1000,r3=1000,r2=1000,r1=1000}}
        local tb = self.rankCfg[idx+1].reward
        for k,v in pairs(tb) do
            print(k,v)
        end

        local item = FormatItem(tb)
        for k,v in pairs(item) do
            -- local function touchItemInfo()
            --     if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
            --         if G_checkClickEnable()==false then
            --             do
            --                 return
            --             end
            --         else
            --             base.setWaitTime=G_getCurDeviceMillTime()
            --         end
            --         print("++++++++++++领奖")


            --     end
            -- end
            local icon,scale=G_getItemIcon(v,80,true,self.layerNum+1)
            icon:setAnchorPoint(ccp(0,0.5))
            icon:setTouchPriority(-(self.layerNum-1)*20-2)
            icon:setPosition(width2+(k-1)*100,height1)
            cell:addChild(icon)

            local numLb = GetTTFLabel(v.num,25)
            numLb:setAnchorPoint(ccp(1,0))
            numLb:setPosition(ccp(icon:getContentSize().width-5,5))
            icon:addChild(numLb)
        end
        -- local function touch()
        -- end
        -- local capInSet = CCRect(20, 20, 10, 10)
        -- local backsprite =LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",capInSet,touch)
        -- backsprite:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-140,self.normalHeight-5))
        -- backsprite:setAnchorPoint(ccp(0,0))
        -- backsprite:setPosition(ccp(85,5))
        -- cell:addChild(backsprite,1)

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
       
    end
end

function shamBattleRewardTab2:getMyRankReward()
   local numRank = SizeOfTable(self.rankCfg)
   local rank = arenaVoApi:getRanking()
   
   for i=numRank,1,-1 do
        local rangeTb = self.rankCfg[i].range
        if rank>=rangeTb[1] then
            return self.rankCfg[i].reward,i
        end
   end
   return self.rankCfg[numRank].reward,numRank
end

function shamBattleRewardTab2:getNumRank(idx)
    local rangeTb = self.rankCfg[idx].range
    if rangeTb[1]==rangeTb[2] then
        return rangeTb[1]
    end
    return (rangeTb[1] .. "-" .. rangeTb[2])
end


function shamBattleRewardTab2:dispose()
    self.bgLayer=nil
    self.layerNum=nil
    self.tv=nil
end

