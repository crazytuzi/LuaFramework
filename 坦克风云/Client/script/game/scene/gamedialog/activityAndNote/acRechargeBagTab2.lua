acRechargeBagTab2={}

function acRechargeBagTab2:new()
    local nc={}

    nc.tv=nil
    nc.bgLayer=nil  
    nc.layerNum=nil
    nc.parent=nil
    nc.noRankLb=nil
    nc.rewardBtn=nil
    nc.generosityLb=nil

    setmetatable(nc,self)
    self.__index=self

    return nc;
end

function acRechargeBagTab2:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    local function click(hd,fn,idx)
    end

    local desBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),click)
    desBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,100))
    desBg:ignoreAnchorPointForPosition(false)
    desBg:setAnchorPoint(ccp(0,1))
    desBg:setPosition(ccp(25,G_VisibleSizeHeight-170))
    self.bgLayer:addChild(desBg)

    local generosityLb = GetTTFLabelWrap(getlocal("current_generosity",{acRechargeBagVoApi:getGenerosity()}),25,CCSizeMake(self.bgLayer:getContentSize().width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    generosityLb:setAnchorPoint(ccp(0,0))
    generosityLb:setPosition(10,desBg:getContentSize().height/2+5)
    desBg:addChild(generosityLb,1)
    generosityLb:setColor(G_ColorGreen)
    self.generosityLb=generosityLb


    local fontSize=20
    local needHeight = 10
    local needWidth2 = 40
    local needWidth = 20
    if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="ko" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="tw" then
        fontSize=25
        needHeight =0
        needWidth =0
    end
    local desLb = GetTTFLabelWrap(getlocal("activity_rechargebag_rule6",{acRechargeBagVoApi:getNeedPoint()}),fontSize,CCSizeMake(self.bgLayer:getContentSize().width-80-needWidth2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    desLb:setAnchorPoint(ccp(0,1))
    desLb:setPosition(10,desBg:getContentSize().height/2-5+needHeight)
    desBg:addChild(desLb,1)
    desLb:setColor(G_ColorYellowPro)

    local function touch()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:openInfo()
    end
    local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon2.png",touch,nil,nil,0)
    menuItemDesc:setScale(0.8)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
    menuDesc:setPosition(ccp(desBg:getContentSize().width-menuItemDesc:getContentSize().width/2,desBg:getContentSize().height/2))
    desBg:addChild(menuDesc)

    local tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),click)
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight-380))
    tvBg:ignoreAnchorPointForPosition(false)
    tvBg:setAnchorPoint(ccp(0,0))
    tvBg:setPosition(ccp(25,110))
    self.bgLayer:addChild(tvBg)

    self.noRankLb = GetTTFLabelWrap(getlocal("activity_fightRanknew_no_rank"),25,CCSizeMake(self.bgLayer:getContentSize().width-80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.noRankLb:setAnchorPoint(ccp(0.5,0.5))
    self.noRankLb:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2)
    self.bgLayer:addChild(self.noRankLb,1)
    self.noRankLb:setColor(G_ColorGray)

    local height=self.bgLayer:getContentSize().height-300
    local widthSpace=80
    local rankLabel=GetTTFLabel(getlocal("RankScene_rank"),25)
    rankLabel:setPosition(widthSpace,height)
    self.bgLayer:addChild(rankLabel,1)

    local nameLabel=GetTTFLabel(getlocal("RankScene_name"),25)
    nameLabel:setPosition(widthSpace+225,height)
    self.bgLayer:addChild(nameLabel,1)

    local valueLabel=GetTTFLabel(getlocal("generosity_value"),fontSize)
    valueLabel:setPosition(widthSpace+225*2-needWidth,height)
    self.bgLayer:addChild(valueLabel,1)

    local function rewardHandler(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        
        local function callback()
            if self.rewardBtn then
                self.rewardBtn:setEnabled(false)
                tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("activity_hadReward"))
            end
        end
        acRechargeBagVoApi:rechargeBagRequest("rankreward",nil,callback)
    end
    self.rewardBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",rewardHandler,nil,getlocal("newGiftsReward"),25,11)
    local rewardMenu=CCMenu:createWithItem(self.rewardBtn)
    rewardMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,67))
    rewardMenu:setTouchPriority(-(self.layerNum-1)*20-4) 
    self.bgLayer:addChild(rewardMenu,1)
    local canReward,status=acRechargeBagVoApi:canRankReward()
    if canReward==true then
    else
        if self.rewardBtn then
            self.rewardBtn:setEnabled(false)
            if status==2 then
                tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("activity_hadReward"))
            end
        end
    end
    self:tick()

    self:doUserHandler()
    self:initTableView()
    
    return self.bgLayer
end

function acRechargeBagTab2:openInfo()
    local sd=smallDialog:new()
    local strTab={}
    local colorTab={}
    local tabAlignment={}
    local rewards=acRechargeBagVoApi:getRankReward()
    for k,v in pairs(rewards) do
        local rank=v[1]
        local reward=FormatItem(v[2],false,true)
        local str=""
        for k,v in pairs(reward) do
            if k==SizeOfTable(reward) then
                str = str .. v.name .. " x" .. v.num
            else
                str = str .. v.name .. " x" .. v.num .. ","
            end
        end
        if rank[1]==rank[2] then
            str=getlocal("rank_reward_str",{rank[1],str})
        else
            str=getlocal("rank_reward_str",{rank[1].."~"..rank[2],str})
        end
        table.insert(strTab,1,str)
        table.insert(colorTab,1,G_ColorWhite)
        table.insert(tabAlignment,1,kCCTextAlignmentLeft)
    end
    table.insert(strTab,1," ")
    table.insert(colorTab,1,G_ColorWhite)
    table.insert(tabAlignment,1,kCCTextAlignmentLeft)
    local ruleStr=getlocal("activityDescription")
    local ruleStr1=getlocal("activity_rechargebag_rank_rule1",{acRechargeBagVoApi:getNeedRank()})
    local ruleStr2=getlocal("activity_rechargebag_rank_rule2")
    local ruleStr3=getlocal("activity_rechargebag_rank_rule3")
    local ruleStr4=getlocal("activity_rechargebag_rank_rule4")

    local strTab2={" ",ruleStr4," ",ruleStr3,ruleStr2,ruleStr1," ",ruleStr," "}
    for k,v in pairs(strTab2) do
        table.insert(strTab,v)
        if tostring(v)==tostring(ruleStr) or tostring(v)==tostring(ruleStr4) then
            table.insert(colorTab,G_ColorYellowPro)
            table.insert(tabAlignment,kCCTextAlignmentCenter)
        else
            table.insert(colorTab,G_ColorWhite)
            table.insert(tabAlignment,kCCTextAlignmentLeft)
        end     
    end
    local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,strTab,25,colorTab,nil,nil,nil,tabAlignment)
    sceneGame:addChild(dialogLayer,self.layerNum+1)
    dialogLayer:setPosition(ccp(0,0))
end

function acRechargeBagTab2:doUserHandler()

end

function acRechargeBagTab2:initTableView()
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight-440),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(25,120))
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)
end

function acRechargeBagTab2:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local rankList=acRechargeBagVoApi:getRankList()
        local rankCount=SizeOfTable(rankList)
        if rankCount>0 then
            rankCount=rankCount+1
        end
        return rankCount
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize = CCSizeMake(G_VisibleSizeWidth-50,76)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local rank
        local name
        local value
        if idx==0 then
            local selfRank=acRechargeBagVoApi:getSelfRank()
            rank=selfRank.rank
            name=selfRank.name
            value=selfRank.value
        else
            local rankList=acRechargeBagVoApi:getRankList()
            rankData=rankList[idx]
            if rankData then
                rank=idx
                name=rankData[2] or ""
                value=rankData[3] or 0
            end
        end
        
        if rank and name and value then
            local capInSet = CCRect(40, 40, 10, 10);
            local capInSetNew=CCRect(20, 20, 10, 10)
            local widthSpace=50
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
            backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50,76))
            backSprie:ignoreAnchorPointForPosition(false)
            backSprie:setAnchorPoint(ccp(0,0))
            backSprie:setIsSallow(false)
            backSprie:setTouchPriority(-42)
            cell:addChild(backSprie,1)

            local height=backSprie:getContentSize().height/2
            local rankSp
            if tonumber(rank)==1 then
                rankSp=CCSprite:createWithSpriteFrameName("top1.png")
            elseif tonumber(rank)==2 then
                rankSp=CCSprite:createWithSpriteFrameName("top2.png")
            elseif tonumber(rank)==3 then
                rankSp=CCSprite:createWithSpriteFrameName("top3.png")
            end
            if rankSp then
                rankSp:setAnchorPoint(ccp(0.5,0.5))
                rankSp:setPosition(ccp(widthSpace,height))
                backSprie:addChild(rankSp,3)
            else
                local rankLabel=GetTTFLabel(tostring(rank),25)
                rankLabel:setAnchorPoint(ccp(0.5,0.5))
                rankLabel:setPosition(widthSpace,height)
                backSprie:addChild(rankLabel,2)
            end

            local nameLabel=GetTTFLabel(name,30)
            nameLabel:setPosition(widthSpace+225,height)
            backSprie:addChild(nameLabel,2)

            local valueLabel=GetTTFLabel(FormatNumber(value),30)
            valueLabel:setPosition(widthSpace+225*2,height)
            backSprie:addChild(valueLabel,2)
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

function acRechargeBagTab2:tick()
    if acRechargeBagVoApi:getFlag(2)==0 then
        self:updateUI()
        acRechargeBagVoApi:setFlag(2,1)
    end
end

function acRechargeBagTab2:refresh()
    if self.rewardBtn then
        local canReward,status=acRechargeBagVoApi:canRankReward()
        if canReward==true then
            self.rewardBtn:setEnabled(true)
            tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("newGiftsReward"))
        else
            self.rewardBtn:setEnabled(false)
            if status==2 then
                tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("activity_hadReward"))
            end
        end
    end

    if self.generosityLb then
        self.generosityLb:setString(getlocal("current_generosity",{acRechargeBagVoApi:getGenerosity()}))
    end
    if self.noRankLb then
        local rankList=acRechargeBagVoApi:getRankList()
        if rankList and SizeOfTable(rankList)>0 then
            self.noRankLb:setVisible(false)
        else
            self.noRankLb:setVisible(true)
        end
    end
end

function acRechargeBagTab2:updateUI()
    if self then
        self:refresh()
        if self.tv then
            self.tv:reloadData()
        end
    end
end

function acRechargeBagTab2:dispose()
    self.tv=nil
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil  
    self.layerNum=nil
    self.parent=nil
    self.noRankLb=nil
    self.rewardBtn=nil
    self.generosityLb=nil
    self=nil
end
