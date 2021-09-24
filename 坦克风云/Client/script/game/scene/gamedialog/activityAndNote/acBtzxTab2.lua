acBtzxTab2={
}

function acBtzxTab2:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.tv=nil
    self.bgLayer=nil
    self.layerNum=layerNum

    return nc
end

function acBtzxTab2:init()
    self.bgLayer=CCLayer:create()

    self:initUI()
    self:initTableView()
    return self.bgLayer
end


function acBtzxTab2:initUI()

    -- 活动 时间 描述
    local lbH=self.bgLayer:getContentSize().height-185

    local actTime=GetTTFLabel(getlocal("recRewardTime"),30)
    actTime:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-185))
    self.bgLayer:addChild(actTime,5)
    actTime:setColor(G_ColorYellowPro)

    local startT,endT=acBtzxVoApi:getRewardTime()
    lbH=lbH-35
    local timeStr=activityVoApi:getActivityTimeStr(startT,endT)
    local timeLabel=GetTTFLabel(timeStr,25)
    timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height-220))
    self.bgLayer:addChild(timeLabel,1)
    self.timeLabel = timeLabel
    lbH=lbH-35-10

    local cfg=acBtzxVoApi:getCfg()
    local startW=40
    local limitLb=GetTTFLabelWrap(getlocal("activity_btzx_limit_info",{FormatNumber(cfg.rankLimit)}),25,CCSize(G_VisibleSizeWidth-startW*2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    limitLb:setAnchorPoint(ccp(0,1))
    limitLb:setPosition(startW,lbH)
    self.bgLayer:addChild(limitLb,2)
    limitLb:setColor(G_ColorRed)

    local desBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg_black.png")
    desBg:setAnchorPoint(ccp(0.5,1))
    desBg:setPosition(ccp(G_VisibleSizeWidth/2,lbH+15))
    self.bgLayer:addChild(desBg)
    desBg:setScaleX(580/desBg:getContentSize().width)
    desBg:setOpacity(180)
    

    lbH=lbH-limitLb:getContentSize().height-10

    local myRank=acBtzxVoApi:getMyRank()
    local rb=acBtzxVoApi:getMyRb() or 0

    local startW=40
    local selfLb=GetTTFLabelWrap(getlocal("ladderRank_alliancescore"),25,CCSize(180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    selfLb:setAnchorPoint(ccp(0,0.5))
    selfLb:setPosition(startW,lbH-selfLb:getContentSize().height/2)
    self.bgLayer:addChild(selfLb,2)

    if allianceVoApi:isHasAlliance() then
        startW=startW+selfLb:getContentSize().width+10
        local gjLb=GetTTFLabelWrap(getlocal("activity_btzx_alliance_gj",{FormatNumber(rb)}),25,CCSize(180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        gjLb:setAnchorPoint(ccp(0,0.5))
        gjLb:setPosition(startW,lbH-selfLb:getContentSize().height/2)
        self.bgLayer:addChild(gjLb,2)
        self.gjLb=gjLb

        local rankStr=myRank
        if myRank==0 then
            rankStr=getlocal("dimensionalWar_out_of_rank")
        end
        startW=startW+gjLb:getContentSize().width+10
        local rankLb=GetTTFLabelWrap(getlocal("shanBattle_rank",{rankStr}),25,CCSize(180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        rankLb:setAnchorPoint(ccp(0,0.5))
        rankLb:setPosition(startW,lbH-selfLb:getContentSize().height/2)
        self.bgLayer:addChild(rankLb,2)
        self.rankLb=rankLb
    else
        startW=(G_VisibleSizeWidth-selfLb:getContentSize().width-startW)/2+startW
        local joinAllianceLb=GetTTFLabelWrap(getlocal("activity_btzx_noJoinAlliance"),25,CCSize(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        joinAllianceLb:setAnchorPoint(ccp(0,0.5))
        joinAllianceLb:setPosition(startW,lbH-selfLb:getContentSize().height/2)
        self.bgLayer:addChild(joinAllianceLb,2)
        joinAllianceLb:setColor(G_ColorRed)
    end
    

    desBg:setScaleY((limitLb:getContentSize().height+10+selfLb:getContentSize().height+30)/desBg:getContentSize().height)




    local function getRewardFunc()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if allianceVoApi:isHasAlliance() then
            local function refreshFunc(rewardlist)
                acBtzxVoApi:showRewardDialog(rewardlist,self.layerNum+1)
                self:refreshBtn()
            end
            local joinTime=allianceVoApi:getJoinTime()
            if joinTime>=startT then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage1979"),30)
                do return end
            end

            local cmd="active.baituanzhengxiong.rankreward"
            local rank=acBtzxVoApi:getMyRank()
            acBtzxVoApi:socketReward(cmd,rank,refreshFunc)
        else
            --军团
            local dlayerNum=3
            activityAndNoteDialog:closeAllDialog()
            local bid=1
            local bType=7
            local buildVo=buildingVoApi:getBuildiingVoByBId(bid)
            if buildVo and buildVo.level<5 then --指挥中心5级开放军团
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("port_scene_building_tip_6"),30)
                do return end
            end
            require "luascript/script/game/scene/gamedialog/allianceDialog/allianceDialog"
            local td=allianceDialog:new(1,dlayerNum)
            G_AllianceDialogTb[1]=td
            local tbArr={getlocal("alliance_list_scene_list"),getlocal("alliance_list_scene_create")}
            local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("alliance_list_scene_name"),true,dlayerNum)
            sceneGame:addChild(dialog,dlayerNum)
        end
    end
    local lbStr
    if allianceVoApi:isHasAlliance() then
        lbStr=getlocal("daily_scene_get")
    else
        lbStr=getlocal("help5_t1_t2")
    end

    local rewardItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",getRewardFunc,nil,lbStr,25,11)
    local rewardBtn=CCMenu:createWithItem(rewardItem);
    rewardBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    rewardBtn:setPosition(ccp(G_VisibleSizeWidth/2,70))
    self.bgLayer:addChild(rewardBtn)
    self.rewardItem=rewardItem
    self.rewardItem:setEnabled(false)

    local lineSp1=CCSprite:createWithSpriteFrameName("LineCross.png")
    self.bgLayer:addChild(lineSp1)
    lineSp1:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-388)

    local lineSp2=CCSprite:createWithSpriteFrameName("LineCross.png")
    self.bgLayer:addChild(lineSp2)
    lineSp2:setPosition(G_VisibleSizeWidth/2,120)

    self:refreshBtn()
    

    self.tvPosH=120
    self.tvVisibleH=lbH-10-self.tvPosH-selfLb:getContentSize().height-10
end

function acBtzxTab2:refreshBtn()
    local state=acBtzxVoApi:getRewardState()
    if self.rewardItem then
        local lbStr
        if state==1 then
            lbStr=getlocal("activity_hadReward")
        else
            if allianceVoApi:isHasAlliance() then
                lbStr=getlocal("daily_scene_get")
            else
                lbStr=getlocal("help5_t1_t2")
            end
        end
        local lb=tolua.cast(self.rewardItem:getChildByTag(11),"CCLabelTTF")
        lb:setString(lbStr)
    end

    if acBtzxVoApi:acIsStop() then
        local myRank=acBtzxVoApi:getMyRank()
        if myRank>0 and myRank<=10 then
            if state==1 then
                self.rewardItem:setEnabled(false)
            else
                self.rewardItem:setEnabled(true)
            end
        end
    else
        self.rewardItem:setEnabled(false)
    end
    if not allianceVoApi:isHasAlliance() then
        self.rewardItem:setEnabled(true)
        if state==1 then
            self.rewardItem:setEnabled(false)
        end
    end
end

function acBtzxTab2:initTableView()

    self.cellHeight=150
    self.cellHeight2=100

    self.rankList=acBtzxVoApi:getRankList()
    self.cellNum=SizeOfTable(self.rankList)
    if self.cellNum==0 then
        self.noAllianceLb=GetTTFLabelWrap(getlocal("activity_btzx_noAlliance"),30,CCSize(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        self.noAllianceLb:setAnchorPoint(ccp(0.5,0.5))
        self.noAllianceLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2-50)
        self.bgLayer:addChild(self.noAllianceLb,2)
        self.noAllianceLb:setColor(G_ColorRed)
    end

    local function callBack(...)
         return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-50,self.tvVisibleH),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(25,self.tvPosH))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
end

function acBtzxTab2:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        if idx<3 then
            tmpSize=CCSizeMake(G_VisibleSizeWidth-50,self.cellHeight)
        else
            tmpSize=CCSizeMake(G_VisibleSizeWidth-50,self.cellHeight2)
        end
        
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local rect = CCRect(0, 0, 50, 50)
        local capInSet = CCRect(20, 20, 10, 10)
        local cellHeight
        if idx<3 then
            cellHeight=self.cellHeight-30
        else
            cellHeight=self.cellHeight2
        end
        local function cellClick(hd,fn,idx)
        end
        local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
        backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,cellHeight))
        backSprie:ignoreAnchorPointForPosition(false)
        backSprie:setAnchorPoint(ccp(0,0))
        backSprie:setIsSallow(false)
        backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
        backSprie:setPosition(ccp(0,0))
        cell:addChild(backSprie,1)

        local bsSize=backSprie:getContentSize()
        if idx<3 then
            local hotSp1=CCSprite:createWithSpriteFrameName("acBtzx_lbBg" .. idx+1 .. ".png")
            hotSp1:setAnchorPoint(ccp(0,0.5))
            hotSp1:setPosition(ccp(0,bsSize.height))
            backSprie:addChild(hotSp1)

            local nameLb=GetTTFLabel(self.rankList[idx+1][3],25)
            nameLb:setAnchorPoint(ccp(0,0.5))
            nameLb:setPosition(ccp(70,hotSp1:getContentSize().height/2+5))
            hotSp1:addChild(nameLb)

            local rankSp=CCSprite:createWithSpriteFrameName("top" .. idx+1 .. ".png")
            hotSp1:addChild(rankSp)
            rankSp:setAnchorPoint(ccp(0,1))
            rankSp:setPosition(ccp(-10,hotSp1:getContentSize().height+10))
            if idx==2 then
                rankSp:setPosition(ccp(-10,hotSp1:getContentSize().height+20))
            end

            local centerWidth=(bsSize.width-hotSp1:getContentSize().width)/2+hotSp1:getContentSize().width
            local titleRewardLb=GetTTFLabelWrap(getlocal("activity_btzx_reward_des"),25,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            backSprie:addChild(titleRewardLb,2)
            titleRewardLb:setPosition(centerWidth,bsSize.height)

            local blueBg=CCSprite:createWithSpriteFrameName("awBlueBg.png")
            blueBg:setPosition(centerWidth,bsSize.height)
            backSprie:addChild(blueBg)
            blueBg:setScale(0.6)

            local centerH=(bsSize.height-hotSp1:getContentSize().height/2)/2

            local allianceLb=GetTTFLabelWrap(getlocal("activity_btzx_alliance_gj",{FormatNumber(self.rankList[idx+1][2])}),25,CCSizeMake(180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            allianceLb:setAnchorPoint(ccp(0,0.5))
            backSprie:addChild(allianceLb)
            allianceLb:setPosition(20,centerH)

            centerH=centerH+10
            local startW=200
            local cfg=acBtzxVoApi:getCfg()
            if cfg and cfg.rankReward and cfg.rankReward[idx+1][2] then
                local rewardItem=FormatItem(cfg.rankReward[idx+1][2],nil,true)
                for k,v in pairs(rewardItem) do
                    local icon = G_getItemIcon(v,100,true,self.layerNum+1,nil,self.tv,nil,nil,nil)
                    icon:setTouchPriority(-(self.layerNum-1)*20-2)
                    backSprie:addChild(icon)
                    icon:setAnchorPoint(ccp(0,0.5))
                    icon:setPosition(startW+(k-1)*90, centerH)
                    G_addRectFlicker(icon,1.3,1.3)

                    local scale=90/icon:getContentSize().width
                    icon:setScale(scale)

                    local numLabel=GetTTFLabel(FormatNumber(v.num),22)
                    numLabel:setAnchorPoint(ccp(1,0))
                    numLabel:setPosition(icon:getContentSize().width-5, 5)
                    numLabel:setScale(1/scale)
                    icon:addChild(numLabel,1)

                end
            end
        else
            local rankNum=GetTTFLabel(idx+1,25)
            backSprie:addChild(rankNum)
            rankNum:setAnchorPoint(ccp(0,0.5))
            rankNum:setPosition(20,bsSize.height/2)

            local nameLb=GetTTFLabel(self.rankList[idx+1][3],25)
            nameLb:setAnchorPoint(ccp(0,0.5))
            nameLb:setPosition(ccp(100,bsSize.height/2))
            backSprie:addChild(nameLb)

            local allianceLb=GetTTFLabelWrap(getlocal("activity_btzx_alliance_gj",{self.rankList[idx+1][2]}),25,CCSizeMake(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            allianceLb:setAnchorPoint(ccp(0,0.5))
            backSprie:addChild(allianceLb)
            allianceLb:setPosition(280,bsSize.height/2)

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

function acBtzxTab2:refresh()
    if self.gjLb and self.rankLb then
        local myRank=acBtzxVoApi:getMyRank()
        local rb=acBtzxVoApi:getMyRb() or 0
        self.gjLb:setString(getlocal("activity_btzx_alliance_gj",{FormatNumber(rb)}))
        local rankStr=myRank
        if myRank==0 then
            rankStr=getlocal("dimensionalWar_out_of_rank")
        end
        self.rankLb:setString(getlocal("shanBattle_rank",{rankStr}))
    end
    if self.tv then
        self.rankList=acBtzxVoApi:getRankList()
        self.cellNum=SizeOfTable(self.rankList)
        local recordPoint=self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
     
end
function acBtzxTab2:updateAcTime()
    local acVo=acBtzxVoApi:getAcVo()
    if acVo and self.timeLabel and tolua.cast(self.timeLabel,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLabel)
    end
end
function acBtzxTab2:tick()
    self:updateAcTime()
end

function acBtzxTab2:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.tv=nil
    self.layerNum=nil
end
