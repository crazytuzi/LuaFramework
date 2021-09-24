ladderRankDialogTab1={}
function ladderRankDialogTab1:new(tabType)
    local nc={}
    setmetatable(nc,self)
    
    self.tabType=tabType--1是个人天梯吧，2是军团天梯榜
    self.personLadderList={}--个人天梯排行榜数据
    self.allianceLadderList={}--军团天梯排行榜数据
    self.__index=self
    return nc
end


function ladderRankDialogTab1:init(layerNum)
    self.layerNum=layerNum
    self.bgLayer=CCLayer:create()
    self:refreshDialog()
    return self.bgLayer
end

function ladderRankDialogTab1:refreshDialog()
    if self.containerSp then
        self.containerSp:removeFromParentAndCleanup(true)
        self.containerSp=nil
    end
    self.containerSp=CCSprite:create()
    self.containerSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width,self.bgLayer:getContentSize().height))
    self.containerSp:setAnchorPoint(ccp(0.5,0.5))
    self.containerSp:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(self.containerSp)

    self:initTableView()
end

--设置对话框里的tableView
function ladderRankDialogTab1:initTableView()
    self:getData()
    local topBgH = 140
    local topBgW = self.bgLayer:getContentSize().width-38
    local topY = self.bgLayer:getContentSize().height-232
    local cupH = 242
    local cupY = topY-cupH/2-topBgH/2
    local tvH = cupY-cupH/2-120
    local tvY = cupY-cupH/2-tvH-50
    self:initTop(topBgW,topBgH,topY)
    self:initCup(topBgW,cupH,topBgH,cupY)
    self:initRankList(topBgW,tvH,tvY)

    local descStr = getlocal("ladderRank_desc2")
    local descLb=GetTTFLabelWrap(descStr,22,CCSizeMake(topBgW,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    descLb:setPosition(ccp(40,45))
    descLb:setAnchorPoint(ccp(0,0.5))
    self.containerSp:addChild(descLb)


    self:initMaskSp()
end

function ladderRankDialogTab1:initMaskSp()
    local isShow,leftTime=ladderVoApi:ifCountingScore()
    if self.maskSp==nil and isShow==true then
        local function tmpFunc()
        end
        local maskSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,2,2),tmpFunc)
        maskSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,self.bgLayer:getContentSize().height-156))
        self.containerSp:addChild(maskSp,7)
        maskSp:setAnchorPoint(ccp(0.5,0))
        maskSp:setOpacity(130)
        maskSp:setPosition(ccp((self.bgLayer:getContentSize().width)/2,0))
        self.maskSp=maskSp
        maskSp:setTouchPriority(-(self.layerNum-1)*20-4)
        local blackBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),tmpFunc)
        blackBgSp:setContentSize(CCSizeMake(self.maskSp:getContentSize().width-100,200))
        maskSp:addChild(blackBgSp)
        blackBgSp:setPosition(ccp((maskSp:getContentSize().width)/2,self.bgLayer:getContentSize().height/2+50))

        local descLb=GetTTFLabelWrap(getlocal("ladder_count_desc"),28,CCSizeMake(blackBgSp:getContentSize().width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        descLb:setPosition(ccp(blackBgSp:getContentSize().width/2,blackBgSp:getContentSize().height/2+20))
        blackBgSp:addChild(descLb)
        local timeLb=GetTTFLabelWrap(getlocal("costTime1",{G_getTimeStr(leftTime)}),28,CCSizeMake(blackBgSp:getContentSize().width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        timeLb:setPosition(ccp(blackBgSp:getContentSize().width/2,descLb:getPositionY()-descLb:getContentSize().height-5))
        blackBgSp:addChild(timeLb)
        self.timeLb=timeLb
        blackBgSp:setVisible(false)
        local function callBack( ... )
            blackBgSp:setVisible(true)
        end
        local delay=CCDelayTime:create(0.2)
        local callFunc=CCCallFunc:create(callBack)
        local scaleTo1=CCScaleTo:create(0.1, 1.3);
        local scaleTo2=CCScaleTo:create(0.07, 1);

        local acArr=CCArray:create()
        acArr:addObject(delay)
        acArr:addObject(callFunc)
        acArr:addObject(scaleTo1)
        acArr:addObject(scaleTo2)
        local seq=CCSequence:create(acArr)
        blackBgSp:runAction(seq)
        
    else
        if isShow==true then
            if self.maskSp then
                self.maskSp:setVisible(true)
            end
            if self.timeLb then
                self.timeLb:setString(getlocal("costTime1",{G_getTimeStr(leftTime)}))
            end
        else
            if self.maskSp then
                self.maskSp:setVisible(false)
                self.maskSp=nil
                local function callbackHandler(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        if sData and sData.data and sData.data.ladder then
                            if self.tabType==1 then
                                ladderVoApi.lastRequestTime1=base.serverTime
                            else
                                ladderVoApi.lastRequestTime2=base.serverTime
                            end
                        end
                        self:refreshDialog()
                    end
                end
                socketHelper:getLadderRank(self.tabType,callbackHandler)
            end
        end
    end
end

function ladderRankDialogTab1:refreshData()
    self:getData()

end

-- 初始化顶部区域
function ladderRankDialogTab1:initTop(topBgW,topBgH,topY)
    
    local function togBgHandler( ... )
    end
    local topBg = LuaCCScale9Sprite:createWithSpriteFrameName("TrialSquadBox.png",CCRect(28, 30, 1, 1),togBgHandler)
    topBg:setContentSize(CCSizeMake(topBgW,topBgH))
    self.containerSp:addChild(topBg,2)
    topBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,topY))

    local totalScore,score1,score2,score3,score4,myRank = ladderVoApi:getMyselfInfo()
    local myTotalScoreNameLb=GetTTFLabel(getlocal("ladderRank_myscore"),28)
    if self.tabType==2 then
        myTotalScoreNameLb=GetTTFLabel(getlocal("ladderRank_alliancescore"),28)
        totalScore,score1,score2,score3,score4,myRank = ladderVoApi:getMyAllianceInfo()
    end
    myTotalScoreNameLb:setPosition(ccp(20,topBgH-40))
    topBg:addChild(myTotalScoreNameLb)
    myTotalScoreNameLb:setAnchorPoint(ccp(0,0.5))
    local myTotalScoreLb=GetTTFLabel(totalScore.."",28)
    myTotalScoreLb:setPosition(ccp(myTotalScoreNameLb:getPositionX()+myTotalScoreNameLb:getContentSize().width,topBgH-40))
    topBg:addChild(myTotalScoreLb)
    myTotalScoreLb:setAnchorPoint(ccp(0,0.5))
    myTotalScoreLb:setColor(G_ColorYellow)


    local myRankLb=GetTTFLabel("："..myRank,28)
    myRankLb:setPosition(ccp(topBgW-20,topBgH-40))
    topBg:addChild(myRankLb)
    myRankLb:setAnchorPoint(ccp(1,0.5))
    myRankLb:setColor(G_ColorYellow)
    local myRankNameLb=GetTTFLabel(getlocal("alliance_scene_rank"),28)
    myRankNameLb:setPosition(ccp(topBgW-20-myRankLb:getContentSize().width,topBgH-40))
    topBg:addChild(myRankNameLb)
    myRankNameLb:setAnchorPoint(ccp(1,0.5))
    

    local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setAnchorPoint(ccp(0.5,0.5))
    lineSp:setPosition(ccp(topBgW/2,topBgH-60))
    topBg:addChild(lineSp)
    lineSp:setScaleX((topBgW-20)/lineSp:getContentSize().width)

    local showWarIdList = ladderVoApi.showWarIdList
    local lbPosArr={}
    if SizeOfTable(showWarIdList)>2 then
        lbPosArr={{x=20,y=topBgH-80},{x=topBgW/2,y=topBgH-80},{x=20,y=topBgH-110},{x=topBgW/2,y=topBgH-110}}
    else
        lbPosArr={{x=20,y=topBgH-95},{x=topBgW/2,y=topBgH-95}}
    end
    local index = 1
    for i=1,5 do
        if showWarIdList[tostring(i)] then
            local scoreStr = ""
            if self.tabType==1 then
                scoreStr = ladderVoApi:getWarNameById(i).."："..ladderVoApi:getMyselfInfoBySid(i)
            else
                scoreStr = ladderVoApi:getWarNameById(i).."："..ladderVoApi:getMyAllianceInfoBySid(i)
            end
            local score1Lb=GetTTFLabelWrap(scoreStr,23,CCSizeMake(topBgW/2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            score1Lb:setPosition(ccp(lbPosArr[index].x,lbPosArr[index].y))
            topBg:addChild(score1Lb)
            score1Lb:setAnchorPoint(ccp(0,0.5))
            index=index+1
        end
    end

    local function clickHandler( ... )
        ladderVoApi:openScoreDialog(self.tabType,self.layerNum+1)
    end
    local searchBtn=GetButtonItem("mainBtnTask.png","mainBtnTask_Down.png","mainBtnTask_Down.png",clickHandler,101,nil,nil)
    searchBtn:setAnchorPoint(ccp(0.5,0.5))
    searchBtn:setScale(0.8)
    local searchBtnMenu=CCMenu:createWithItem(searchBtn)
    searchBtnMenu:setPosition(ccp(topBgW-searchBtn:getContentSize().width/2-10,topBgH-100))
    searchBtnMenu:setTouchPriority(-(self.layerNum-1)*20-2)
    topBg:addChild(searchBtnMenu,2)
end

-- 初始化奖杯区域
function ladderRankDialogTab1:initCup(cupW,cupH,topBgH,cupY)
    local function bgtouch( ... )
        
    end
    local capInSet = CCRect(20, 20, 10, 10)
    local cupBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,bgtouch)
    cupBg:setContentSize(CCSizeMake(cupW-4,cupH))
    cupBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,cupY))
    self.containerSp:addChild(cupBg)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
    local ladderRewardBg=CCSprite:create("public/ladder/ladder_reward_bg.jpg")
    ladderRewardBg:setPosition(ccp((self.bgLayer:getContentSize().width)/2,cupY))
    ladderRewardBg:setScaleX((cupW-6)/ladderRewardBg:getContentSize().width)
    self.containerSp:addChild(ladderRewardBg)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    local subTitleBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 1, 1),bgtouch)
    subTitleBg:setContentSize(CCSizeMake(cupW-20,40))
    subTitleBg:setPosition(ccp((cupW-6)/2,0))
    subTitleBg:setAnchorPoint(ccp(0.5,0))
    ladderRewardBg:addChild(subTitleBg)

    local ladderList=self.personLadderList
    if self.tabType==2 then
        ladderList=self.allianceLadderList
    end
    local servername1,name1,score1 = "",getlocal("ladderRank_noRank"),""
    local servername2,name2,score2 = "",getlocal("ladderRank_noRank"),""
    local servername3,name3,score3 = "",getlocal("ladderRank_noRank"),""
    local posX1,posY1=cupW/2,cupH-15
    local posX2,posY2=cupW/4-18,cupH-30
    local posX3,posY3=cupW/4*3+18,cupH-50
    local expiration_timeStr,isShowRank = ladderVoApi:getLadderEndTime()
    local expiration_time = getlocal("ladderRank_expiration_time",{expiration_timeStr})
    if expiration_timeStr==0 then
        expiration_time=getlocal("ladder_season_endtime")
    end
    for i=1,3 do
        if ladderList and ladderList[i] then
            if i==1 then
                servername1,name1,score1=ladderList[i].servername,ladderList[i].name,ladderList[i].score
            elseif i==2 then
                servername2,name2,score2=ladderList[i].servername,ladderList[i].name,ladderList[i].score
            elseif i==3 then
                servername3,name3,score3=ladderList[i].servername,ladderList[i].name,ladderList[i].score
            end
        end    
    end
    local lbTab={
        {servername1,23,ccp(0.5,0.5),ccp(posX1,posY1),ladderRewardBg,3,G_ColorWhite,CCSize(250,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
        {name1,23,ccp(0.5,0.5),ccp(posX1,posY1-30),ladderRewardBg,3,G_ColorWhite,CCSize(250,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
        {score1,23,ccp(0.5,0.5),ccp(posX1,posY1-60),ladderRewardBg,3,G_ColorWhite,CCSize(250,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
        {servername2,23,ccp(0.5,0.5),ccp(posX2,posY2),ladderRewardBg,3,G_ColorWhite,CCSize(250,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
        {name2,23,ccp(0.5,0.5),ccp(posX2,posY2-30),ladderRewardBg,3,G_ColorWhite,CCSize(250,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
        {score2,23,ccp(0.5,0.5),ccp(posX2,posY2-60),ladderRewardBg,3,G_ColorWhite,CCSize(250,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
        {servername3,23,ccp(0.5,0.5),ccp(posX3,posY3),ladderRewardBg,3,G_ColorWhite,CCSize(250,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
        {name3,23,ccp(0.5,0.5),ccp(posX3,posY3-30),ladderRewardBg,3,G_ColorWhite,CCSize(250,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
        {score3,23,ccp(0.5,0.5),ccp(posX3,posY3-60),ladderRewardBg,3,G_ColorWhite,CCSize(250,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
        {expiration_time,23,ccp(0.5,0.5),ccp(posX1,22),ladderRewardBg,3,G_ColorRed,CCSize(cupW,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
        {getlocal("alliance_scene_rank"),23,ccp(0.5,0.5),ccp(70,cupY-cupH/2-25),self.containerSp,3,G_ColorGreen2,CCSize(cupW,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
        {getlocal("serverwar_server_name"),23,ccp(0.5,0.5),ccp(220,cupY-cupH/2-25),self.containerSp,3,G_ColorGreen2,CCSize(cupW,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
        {getlocal("RankScene_name"),23,ccp(0.5,0.5),ccp(420,cupY-cupH/2-25),self.containerSp,3,G_ColorGreen2,CCSize(cupW,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
        {getlocal("ladderRank_score"),23,ccp(0.5,0.5),ccp(560,cupY-cupH/2-25),self.containerSp,3,G_ColorGreen2,CCSize(cupW,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
        
    }
    for k,v in pairs(lbTab) do
        local key,size,anchorPoint,position,parent,zOrder,color,dimensions,hAlignment,vAlignment=v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10]
        local lb=GetAllTTFLabel(key,size,anchorPoint,position,parent,zOrder,color,dimensions,hAlignment,vAlignment)
    end
end

-- 初始化排行榜列表
function ladderRankDialogTab1:initRankList(topBgW,tvH,tvY)
    local function touchHander( ... )
        
    end
    local descBg = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),touchHander)
    descBg:setContentSize(CCSizeMake(topBgW-10,tvH+55))
    descBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,65))
    descBg:setAnchorPoint(ccp(0.5,0))
    self.containerSp:addChild(descBg)

    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(topBgW,tvH),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(10,tvY))
    self.containerSp:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(10)

    local listNum = #self.personLadderList
    if self.tabType==2 then
        listNum = #self.allianceLadderList
    end
    if listNum<=0 then
        local noDataDescLb=GetTTFLabelWrap(getlocal("ladder_hof_desc1"),30,CCSizeMake(topBgW-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        noDataDescLb:setPosition(ccp((topBgW-10)/2,(tvH+55)/2))
        descBg:addChild(noDataDescLb)
        noDataDescLb:setColor(G_ColorGray)
    end
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function ladderRankDialogTab1:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local listNum = #self.personLadderList
        if self.tabType==2 then
            listNum = #self.allianceLadderList
        end
        if listNum>3 then
            listNum=listNum-3
        end
        return listNum
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-40,60)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local ladderList=self.personLadderList
        if self.tabType==2 then
            ladderList = self.allianceLadderList
        end
        if #ladderList>3 and ladderList[idx+4] then
            local itemVO = ladderList[idx+4]
            local lbY = 40

            local rankLb=GetTTFLabelWrap(itemVO.rank.."",25,CCSizeMake(50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            rankLb:setPosition(ccp(60,lbY))
            cell:addChild(rankLb)

            local serverNameLb=GetTTFLabelWrap(itemVO.servername,25,CCSizeMake(250,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            serverNameLb:setPosition(ccp(200,lbY))
            cell:addChild(serverNameLb)

            local nameLb=GetTTFLabelWrap(itemVO.name,25,CCSizeMake(250,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            nameLb:setPosition(ccp(405,lbY))
            cell:addChild(nameLb)

            local scoreLb=GetTTFLabelWrap(itemVO.score.."",25,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            scoreLb:setPosition(ccp(550,lbY))
            cell:addChild(scoreLb)

            local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
            lineSp:setPosition(ccp(self.bgLayer:getContentSize().width/2-20,10))
            cell:addChild(lineSp)
        end

        return cell

    elseif fn=="ccTouchBegan" then
           self.isMoved=false
           return true
    elseif fn=="ccTouchMoved" then
           self.isMoved=true
    elseif fn=="ccTouchEnded"  then
           
    elseif fn=="ccScrollEnable" then
        if newGuidMgr:isNewGuiding()==true then
            return 0
        else
            return 1
        end
    end
end

function ladderRankDialogTab1:getData()
    self.personLadderList=ladderVoApi:getPersonLadderList()
    self.allianceLadderList=ladderVoApi:getAllianceLadderList()
end

function ladderRankDialogTab1:tick()
    self:initMaskSp()
end

function ladderRankDialogTab1:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
end