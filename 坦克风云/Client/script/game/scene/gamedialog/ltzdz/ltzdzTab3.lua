ltzdzTab3={
    selectedTabIndex=0,
    oldSelectedTabIndex=0,
    tabTb={},
}
function ltzdzTab3:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.layerNum=layerNum
    return nc
end

function ltzdzTab3:init()
    self.qualifyingFlag=ltzdzVoApi:isQualifying() --是否在定级赛中
	self.bgLayer=CCLayer:create()

    local priority=-(self.layerNum-1)*20-8
    local tbArr={getlocal("ltzdz_segment"),getlocal("ltzdz_killStr1"),getlocal("ltzdz_killStr2"),getlocal("alienMines_Occupied")}
    local tabBtn=CCMenu:create()
    tabBtn:setTouchPriority(priority)
    for k,v in pairs(tbArr) do
        local function tabClick(idx)
            return self:tabClick(idx)
        end
        local tabItem=CCMenuItemImage:create("rankTab.png", "rankTab_Down.png","rankTab_Down.png")
        tabItem:setAnchorPoint(CCPointMake(0.5,0.5))
        local tabWidth=tabItem:getContentSize().width
        local tabHeight=tabItem:getContentSize().height
        local pos=ccp(20+tabWidth/2,G_VisibleSizeHeight-170-tabHeight/2-(k-1)*(tabHeight+10))
        tabItem:setPosition(pos)
        tabItem:registerScriptTapHandler(tabClick)
        local lb=GetTTFLabelWrap(v,24,CCSizeMake(tabItem:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        lb:setPosition(CCPointMake(tabItem:getContentSize().width/2,tabItem:getContentSize().height/2))
        lb:setTag(31)
        if k~=self.selectedTabIndex then
            lb:setColor(G_TabLBColorGreen)
        end
        tabItem:addChild(lb)
        tabBtn:addChild(tabItem)
        tabItem:setTag(k)
        self.tabTb[k]=tabItem
    end
    tabBtn:setPosition(0,0)
    self.bgLayer:addChild(tabBtn)
    self:tabClick(1)

    local rankBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
    rankBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-140,G_VisibleSizeHeight-200))
    rankBgSp:setAnchorPoint(ccp(0,1))
    rankBgSp:setPosition(120,G_VisibleSizeHeight-170)
    self.bgLayer:addChild(rankBgSp)

    local tvWidth,tvHeight=rankBgSp:getContentSize().width,rankBgSp:getContentSize().height
    self.cellWidth,self.cellHeight=tvWidth,102
    local function callBack(...)
         return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth,tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(120,G_VisibleSizeHeight-170-tvHeight))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(120)


	return self.bgLayer
end

function ltzdzTab3:tabClick(idx)
    self.oldSelectedTabIndex=self.selectedTabIndex    
    for k,v in pairs(self.tabTb) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            local btnLabel=tolua.cast(v:getChildByTag(31),"CCLabelTTF")
            btnLabel:setColor(G_ColorWhite)
        else
            v:setEnabled(true)
            local btnLabel=tolua.cast(v:getChildByTag(31),"CCLabelTTF")
            btnLabel:setColor(G_TabLBColorGreen)
        end
    end
    self:switchTab(idx)
end

function ltzdzTab3:switchTab(idx)
    if self.selectedTabIndex~=self.oldSelectedTabIndex then
        local function realSwitch()
            self:refresh(idx)
        end
        ltzdzVoApi:formatRankList(idx,realSwitch)
    end
end

function ltzdzTab3:refresh(idx)
    require "luascript/script/game/gamemodel/ltzdz/ltzdzFightApi"
    self.myRank=1000
    local myUid=playerVoApi:getUid()
    self.ranklist=ltzdzVoApi:getRankListByType(idx)
    for k,v in pairs(self.ranklist) do
        if tonumber(v.uid)==tonumber(myUid) then --排行榜内有自己
            self.myUser=v
            self.myRank=k
            do break end
        end
    end
    local myInfo=ltzdzVoApi.clancrossinfo
    local zid=base.curZoneID
    local nickname=playerVoApi:getPlayerName()
    if self.myUser==nil then
        self.myUser={uid=myUid,zid=zid,nickname=nickname}
    end
    local rpoint=(myInfo.rpoint or 0)
    local defeat=(myInfo.defeat or 0)
    local killnum=(myInfo.killnum or 0)
    local citynum=(myInfo.citynum or 0)
    self.myUser.rpoint=self.myUser.rpoint or rpoint
    self.myUser.defeat=self.myUser.defeat or defeat
    self.myUser.killnum=self.myUser.killnum or killnum
    self.myUser.citynum=self.myUser.citynum or citynum

    self.cellNum=SizeOfTable(self.ranklist)+1
    if self.tv then
        self.tv:reloadData()
    end
end

function ltzdzTab3:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
        return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
		tmpSize=CCSizeMake(self.cellWidth,self.cellHeight)
		return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local itemWidth=self.cellWidth-6
        local itemHeight=self.cellHeight-2
        local nameFontSize=20
        local rank=1000
        local user
        if idx==0 then
            user=self.myUser
            rank=self.myRank
        else
            user=self.ranklist[idx]
            rank=idx
        end
        local isMyself=false
        local rankBg
        local myUid=playerVoApi:getUid()
        if tonumber(myUid)==tonumber(user.uid) then
            rankBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfBg.png",CCRect(5,5,1,1),function ()end)
            isMyself=true
        else
            rankBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankOtherBg.png",CCRect(5,5,1,1),function ()end)
        end
        rankBg:setContentSize(CCSizeMake(itemWidth,itemHeight))
        rankBg:setPosition(self.cellWidth/2,self.cellHeight/2)
        cell:addChild(rankBg)

        if rank<=3 then
            local rankSp=CCSprite:createWithSpriteFrameName("top"..rank..".png")
            rankSp:setScale(60/rankSp:getContentSize().width)
            rankSp:setPosition(35,itemHeight/2)
            rankBg:addChild(rankSp)
        else
            local rankStr=""
            if rank>100 then
                rankStr="100+"
            else
                rankStr=tostring(rank)
            end
            local rankLb=GetTTFLabelWrap(rankStr,nameFontSize,CCSizeMake(60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            rankLb:setPosition(35,itemHeight/2)
            rankBg:addChild(rankLb)
        end

        local nameLb=GetTTFLabelWrap(user.nickname,nameFontSize,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        nameLb:setAnchorPoint(ccp(0,0.5))
        nameLb:setPosition(70,itemHeight-nameLb:getContentSize().height/2-15)
        rankBg:addChild(nameLb)

        local serverLb=GetTTFLabelWrap(GetServerNameByID(user.zid),nameFontSize,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        serverLb:setAnchorPoint(ccp(0,0.5))
        serverLb:setPosition(70,serverLb:getContentSize().height/2+15)
        rankBg:addChild(serverLb)

        local kuangWidth,kuangHeight=230,itemHeight-20
        local kuangSp=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20,20,1,1),function ()end)
        kuangSp:setContentSize(CCSizeMake(kuangWidth,kuangHeight))
        kuangSp:setPosition(itemWidth-kuangWidth/2-10,itemHeight/2)
        rankBg:addChild(kuangSp)

        local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine4.png",CCRect(3,0,1,1),function ()end)
        lineSp:setContentSize(CCSizeMake(itemWidth,2))
        lineSp:setPosition(self.cellWidth/2,0)
        cell:addChild(lineSp)

        if isMyself==true and self.qualifyingFlag==true and self.selectedTabIndex==1 then
            local segLb=GetTTFLabelWrap(getlocal("ltzdz_qualifying"),nameFontSize,CCSizeMake(kuangWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            segLb:setPosition(getCenterPoint(kuangSp))
            kuangSp:addChild(segLb)
            do return cell end
        end

        if self.selectedTabIndex==1 then
            local seg,smallSeg,totalSeg=ltzdzVoApi:getSegByLevel(user.rpoint)
            local segName=ltzdzVoApi:getSegName(seg,smallSeg)
            local segSp=ltzdzVoApi:getSegIcon(seg,smallSeg,nil,3)
            segSp:setAnchorPoint(ccp(0,0.5))
            segSp:setPosition(5,kuangHeight/2+8)
            local segWidth=90
            segSp:setScale(segWidth/segSp:getContentSize().width)
            kuangSp:addChild(segSp)

            local segNameLb=GetTTFLabelWrap(segName,nameFontSize,CCSizeMake(kuangWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            segNameLb:setAnchorPoint(ccp(0,0.5))
            segNameLb:setPosition(segWidth+20,kuangHeight-segNameLb:getContentSize().height/2-10)
            kuangSp:addChild(segNameLb)

            local promptLb=GetTTFLabel(getlocal("ltzdz_rpoint"),nameFontSize)
            promptLb:setAnchorPoint(ccp(0,0.5))
            promptLb:setPosition(segWidth+20,promptLb:getContentSize().height/2+10)
            kuangSp:addChild(promptLb)

            local rpointLb=GetTTFLabelWrap(user.rpoint,nameFontSize,CCSizeMake(kuangWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            rpointLb:setAnchorPoint(ccp(0,0.5))
            rpointLb:setPosition(promptLb:getPositionX()+promptLb:getContentSize().width,promptLb:getPositionY())
            kuangSp:addChild(rpointLb)
        elseif self.selectedTabIndex>=2 then
            if isMyself==true and self.qualifyingFlag==true then
            else
                local segWidth=80
                local seg,smallSeg,totalSeg=ltzdzVoApi:getSegByLevel(user.rpoint)
                local segName=ltzdzVoApi:getSegName(seg,smallSeg,nil,1)
                local segSp=ltzdzVoApi:getSegIcon(seg,smallSeg,nil,1)
                segSp:setAnchorPoint(ccp(0,0.5))
                segSp:setScale(segWidth/segSp:getContentSize().width)
                segSp:setPosition(170,nameLb:getPositionX())
                rankBg:addChild(segSp)
            end

            local promptStr=""
            local valueStr=""
            if self.selectedTabIndex==2 then
                promptStr=getlocal("ltzdz_season_kill")
                valueStr="<rayimg>"..(user.killnum or 0).."<rayimg>"..getlocal("fleetInfoTitle2")
            elseif self.selectedTabIndex==3 then
                promptStr=getlocal("ltzdz_season_defeat")
                valueStr="<rayimg>"..(user.defeat or 0).."<rayimg>"..getlocal("acHongchangyuebingPlayer")
            elseif self.selectedTabIndex==4 then
                promptStr=getlocal("ltzdz_season_occupy")
                valueStr="<rayimg>"..(user.citynum or 0).."<rayimg>"..getlocal("world_ground_name_6")
            end
            local promptLb=GetTTFLabelWrap(promptStr,nameFontSize,CCSizeMake(kuangWidth-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            promptLb:setPosition(kuangWidth/2,kuangHeight-promptLb:getContentSize().height/2-10)
            kuangSp:addChild(promptLb)
            local colorTab={nil,G_ColorGreen,nil}
            local valueLb,lbHeight=G_getRichTextLabel(valueStr,colorTab,nameFontSize,kuangWidth-10,kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            valueLb:setPosition(kuangWidth/2,lbHeight+10)
            kuangSp:addChild(valueLb)
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

function ltzdzTab3:updateUI()
    self:refresh(self.selectedTabIndex)
end

function ltzdzTab3:tick()
end

function ltzdzTab3:dispose()
    self.layerNum=nil
    self.ranklist={}
    self.cellNum=0
    self.qualifyingFlag=false
    self.tabTb={}
    if self.bgLayer then
	    self.bgLayer:removeFromParentAndCleanup(true)
	end
    self.bgLayer=nil
end