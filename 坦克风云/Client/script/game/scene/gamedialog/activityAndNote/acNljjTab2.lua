acNljjTab2={
}

function acNljjTab2:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.bgLayer=nil
    self.layerNum=layerNum
    self.state = 0 

    return nc;
end

function acNljjTab2:init()
    self.bgLayer=CCLayer:create()

    local tipKey,tipKeyInteger = acNljjVoApi:getTipKey()
    if acNljjVoApi:acIsStop() and tipKeyInteger ~= 2 then
        if acNljjVoApi:isReaward() == false then
            acNljjVoApi:afterExchange()
        end
    end

    self:initUI()
    self:initTableView()
    return self.bgLayer
end


function acNljjTab2:initUI()
    local startH=G_VisibleSize.height-175
    local needPosY = 10
    local strSize2 = 20
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
        needPosY =-5
        strSize2 =22
    end

    self.descLb1=GetTTFLabelWrap(getlocal("activity_nljj_haveSld",{acNljjVoApi:getPoint()}),25,CCSizeMake(G_VisibleSize.width-160,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
    self.descLb1:setAnchorPoint(ccp(0,0))

    self.descLb2=GetTTFLabelWrap(getlocal("activity_nljj_limitSld",{acNljjVoApi:getRankLimit()}),25,CCSizeMake(G_VisibleSize.width-160,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    self.descLb2:setAnchorPoint(ccp(0,1))

    local titleBgH=self.descLb1:getContentSize().height+self.descLb2:getContentSize().height+30
    local function bgClick(hd,fn,idx)
    end
    local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),bgClick)
    titleBg:setContentSize(CCSizeMake(G_VisibleSize.width-60, titleBgH))
    titleBg:setAnchorPoint(ccp(0.5,1));
    titleBg:setPosition(ccp(G_VisibleSize.width/2,startH))
    self.bgLayer:addChild(titleBg,1)

    self.descLb1:setPosition(ccp(15,titleBg:getContentSize().height/2+5))
    titleBg:addChild(self.descLb1,2)
    self.descLb1:setColor(G_ColorGreen)

    self.descLb2:setPosition(ccp(15,titleBg:getContentSize().height/2+needPosY));
    titleBg:addChild(self.descLb2,2);
    self.descLb2:setColor(G_ColorYellow)

    local tabStr={getlocal("activity_nljj_info24"),getlocal("activity_nljj_info23"),getlocal("activity_nljj_info22"),getlocal("activity_nljj_info21",{10})," "}
    local colorTab={}

    local rewards=acNljjVoApi:getRankReward()
    for k,v in pairs(rewards) do
        local rank=v[1]
        local reward=FormatItem(v[2],false,true)
        local rewardCount=SizeOfTable(reward)
        local str=""
        for k,v in pairs(reward) do
            if k==rewardCount then
                str=str..v.name.." x"..v.num
            else
                str=str..v.name.." x"..v.num..","
            end
        end
        if rank[1]==rank[2] then
            str=getlocal("rank_reward_str",{rank[1],str})
        else
            str=getlocal("rank_reward_str",{rank[1].."~"..rank[2],str})
        end
        table.insert(tabStr,1,str)
    end
    table.insert(tabStr,1,"")

    local pos=ccp(titleBg:getContentSize().width-80,titleBg:getContentSize().height/2)
    local strSize3 = 23
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() =="tw" then
        strSize3 = 28
    end
    G_addMenuInfo(titleBg,self.layerNum,pos,tabStr,colorTab,nil,strSize3)

    local function getRewardFunc()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end

        local function refreshFunc(rewardlist)
            acNljjVoApi:showRewardDialog(rewardlist,self.layerNum+1)
            self:refreshBtn()
            acNljjVoApi:afterExchange()
        end

        -- local joinTime=allianceVoApi:getJoinTime()
        -- if joinTime>=startT then
        --     smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage1979"),30)
        --     do return end
        -- end

        local cmd="active.nengliangjiejing.rankreward"
        local rank=acNljjVoApi:getMyrank()
        acNljjVoApi:socketNljj(cmd,nil,rank,refreshFunc)
    end
    local lbStr
    -- if allianceVoApi:isHasAlliance() then
    --     lbStr=getlocal("daily_scene_get")
    -- else
        lbStr=getlocal("daily_scene_get")
    -- end

    local rewardItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",getRewardFunc,nil,lbStr,25,11)
    local rewardBtn=CCMenu:createWithItem(rewardItem);
    rewardBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    rewardBtn:setPosition(ccp(G_VisibleSizeWidth/2,70))
    self.bgLayer:addChild(rewardBtn)
    self.rewardItem=rewardItem
    self.rewardItem:setEnabled(false)

    self:refreshBtn()


    local height=startH-titleBgH-20
    local widthSpace=80

    local rankLabel=GetTTFLabel(getlocal("RankScene_rank"),22)
    rankLabel:setPosition(widthSpace,height)
    self.bgLayer:addChild(rankLabel,2)
    rankLabel:setColor(G_ColorGreen)
    
    local nameLabel=GetTTFLabel(getlocal("RankScene_name"),22)
    nameLabel:setPosition(widthSpace+120,height)
    self.bgLayer:addChild(nameLabel,2)
    nameLabel:setColor(G_ColorGreen)
    
    local levelLabel=GetTTFLabel(getlocal("RankScene_level"),22)
    levelLabel:setPosition(widthSpace+120*2+20,height)
    self.bgLayer:addChild(levelLabel,2)
    levelLabel:setColor(G_ColorGreen)

    local powerLabel=GetTTFLabel(getlocal("RankScene_power"),22)
    powerLabel:setPosition(widthSpace+120*3+10,height)
    self.bgLayer:addChild(powerLabel,2)
    powerLabel:setColor(G_ColorGreen)

    local pointLabel=GetTTFLabelWrap(getlocal("activity_nljj_sld"),strSize2,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    pointLabel:setPosition(widthSpace+120*4,height)
    self.bgLayer:addChild(pointLabel,2)
    pointLabel:setColor(G_ColorGreen)

    self.tvHeight=height-20-120
end

function acNljjTab2:refreshBtn()
    local state=acNljjVoApi:getRankRewardState()
    if self.rewardItem then
        local lbStr
        if state==1 then
            lbStr=getlocal("activity_hadReward")
        else
            -- if allianceVoApi:isHasAlliance() then
            --     lbStr=getlocal("daily_scene_get")
            -- else
            lbStr=getlocal("daily_scene_get")
            -- end
        end
        local lb=tolua.cast(self.rewardItem:getChildByTag(11),"CCLabelTTF")
        lb:setString(lbStr)
    end

    if acNljjVoApi:acIsStop() then
        local myRank=acNljjVoApi:getMyrank()
        if myRank and myRank>0 and myRank<=10 then
            if state==1 then
                self.rewardItem:setEnabled(false)
            else
                self.rewardItem:setEnabled(true)
            end
        end
    else
        self.rewardItem:setEnabled(false)
    end
end

function acNljjTab2:initTableView()
    self.normalHeight=84

    self.rankList=acNljjVoApi:getRankList()
    self.cellNum=SizeOfTable(self.rankList)+1

    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-60,self.tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,120))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(80)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acNljjTab2:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local num=self.cellNum
        return num
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-70,self.normalHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local function cellClick1(hd,fn,idx)
        end
        local capInSet = CCRect(20, 20, 10, 10)
        if idx==0 then
            backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png",capInSet,cellClick1)
        elseif idx==1 then
            backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank1ItemBg.png",capInSet,cellClick1)
        elseif idx==2 then
            backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank2ItemBg.png",capInSet,cellClick1)
        elseif idx==3 then
            backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank3ItemBg.png",capInSet,cellClick1)
        else
            backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png",capInSet,cellClick1)
        end
        backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.normalHeight-4))
        backSprie:ignoreAnchorPointForPosition(false)
        backSprie:setAnchorPoint(ccp(0,0))
        backSprie:setIsSallow(false)
        cell:addChild(backSprie)

        local rData
        local rank
        local name
        local level
        local power
        local point
        
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd,fn,idx)
        end

        if idx==0 then
            rank=acNljjVoApi:getMyrank()
            name=playerVoApi:getPlayerName()
            level=playerVoApi:getPlayerLevel()
            power=playerVoApi:getPlayerPower()
            point=acNljjVoApi:getPoint()

        else
            rData=self.rankList[idx] or {}
            rank=idx
            name=rData[2] or ""
            level=rData[4] or 0
            power=rData[5] or 0
            point=rData[3] or 0
        end

        local lbSize=25
        local lbHeight=(self.normalHeight-4)/2
        local lbWidth=50

        if rank==nil then
            rank="10+"
        end
        local rankLb=GetTTFLabel(rank,lbSize)
        rankLb:setPosition(ccp(lbWidth,lbHeight))
        cell:addChild(rankLb)
        rankLb:setColor(G_ColorYellow)

        local rankSp
        if tonumber(rank)==1 then
            rankSp=CCSprite:createWithSpriteFrameName("top1.png")
        elseif tonumber(rank)==2 then
            rankSp=CCSprite:createWithSpriteFrameName("top2.png")
        elseif tonumber(rank)==3 then
            rankSp=CCSprite:createWithSpriteFrameName("top3.png")
        end
        if rankSp then
            rankSp:setPosition(ccp(lbWidth,lbHeight))
            cell:addChild(rankSp,2)
            rankLb:setVisible(false)
        end

        local nameLb=GetTTFLabel(name,lbSize)
        nameLb:setPosition(ccp(lbWidth+120,lbHeight))
        cell:addChild(nameLb)

        local levelLb=GetTTFLabel(level,lbSize)
        levelLb:setPosition(ccp(lbWidth+120*2+20,lbHeight))
        cell:addChild(levelLb)
        
        local powerLb=GetTTFLabel(FormatNumber(power),lbSize)
        powerLb:setPosition(ccp(lbWidth+120*3+10,lbHeight))
        cell:addChild(powerLb)

        local pointLb=GetTTFLabel(point,lbSize)
        pointLb:setPosition(ccp(lbWidth+120*4,lbHeight))
        cell:addChild(pointLb)
        pointLb:setColor(G_ColorYellow)

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end


function acNljjTab2:refresh()
    if self.descLb1 then
        self.descLb1:setString(getlocal("activity_nljj_haveSld",{acNljjVoApi:getPoint()}))
    end
    if self.tv then
        self.rankList=acNljjVoApi:getRankList()
        self.cellNum=SizeOfTable(self.rankList)+1

        local recordPoint=self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
end


function acNljjTab2:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.layerNum=nil
    self.state = 0 
end
