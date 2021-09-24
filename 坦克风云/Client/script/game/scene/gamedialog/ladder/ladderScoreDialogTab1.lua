ladderScoreDialogTab1={}
function ladderScoreDialogTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    self.personScoreDetailList={}--个人天梯积分详情
    self.allianceScoreDetailList={}--军团天梯积分详情
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/platWar/platWarImage.plist")
    spriteController:addPlist("serverWar/serverWar.plist")
    spriteController:addTexture("serverWar/serverWar.pvr.ccz")
    return nc
end


function ladderScoreDialogTab1:init(layerNum,tabType)
    self.tabType=tabType--1是个人天梯吧，2是军团天梯榜
    self.layerNum=layerNum
    self.bgLayer=CCLayer:create()
    self:refreshDialog()
    return self.bgLayer
end

function ladderScoreDialogTab1:refreshDialog()
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



function ladderScoreDialogTab1:initMaskSp()
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
                                ladderVoApi.lastRequestTime3=base.serverTime
                            else
                                ladderVoApi.lastRequestTime4=base.serverTime
                            end
                        end
                        self:refreshDialog()
                    end
                end
                socketHelper:getLadderLog(self.tabType,callbackHandler)
            end
        end
    end
end

function ladderScoreDialogTab1:refreshData()
    self:getData()

end


--设置对话框里的tableView
function ladderScoreDialogTab1:initTableView()
    self:getData()
    local topBgH = 140
    local topBgW = self.bgLayer:getContentSize().width-60
    local topY = self.bgLayer:getContentSize().height-232
    local tvH = topY-topBgH/2-50-30
    local tvY = 40+30
    self:initTop(topBgW,topBgH,topY)
    self:initRankList(topBgW,tvH,tvY)

    local descStr = getlocal("ladderRank_desc3")
    local descLb=GetTTFLabelWrap(descStr,22,CCSizeMake(topBgW,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    descLb:setPosition(ccp(30,45))
    descLb:setAnchorPoint(ccp(0,0.5))
    self.containerSp:addChild(descLb)
end

-- 初始化顶部区域
function ladderScoreDialogTab1:initTop(topBgW,topBgH,topY)
    
    local function togBgHandler( ... )
    end
    local topBg = LuaCCScale9Sprite:createWithSpriteFrameName("TrialSquadBox.png",CCRect(28, 30, 1, 1),togBgHandler)
    topBg:setContentSize(CCSizeMake(topBgW,topBgH))
    self.containerSp:addChild(topBg)
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

    local showWarIdList = ladderVoApi.showWarIdList
    local lbPosArr={}
    if SizeOfTable(showWarIdList)>2 then
        lbPosArr={{x=20,y=topBgH-80},{x=topBgW/2,y=topBgH-80},{x=20,y=topBgH-110},{x=topBgW/2,y=topBgH-110}}
    else
        lbPosArr={{x=20,y=topBgH-95},{x=topBgW/2,y=topBgH-95}}
    end
    local index = 1
    -- for k,v in pairs(showWarIdList) do
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
    
end


-- 初始化排行榜列表
function ladderScoreDialogTab1:initRankList(topBgW,tvH,tvY)
    
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(topBgW,tvH),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,tvY))
    self.containerSp:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(10)
    local listNum = #self.personScoreDetailList
    if self.tabType==2 then
        listNum = #self.allianceScoreDetailList
    end
    if listNum<=0 then
        local noDataDescLb=GetTTFLabelWrap(getlocal("ladder_hof_desc1"),30,CCSizeMake(topBgW,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        noDataDescLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-80))
        self.containerSp:addChild(noDataDescLb)
        noDataDescLb:setColor(G_ColorGray)
    end
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function ladderScoreDialogTab1:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local listNum = #self.personScoreDetailList
        if self.tabType==2 then
            listNum = #self.allianceScoreDetailList
        end
        return listNum
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-40,180)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local cellW = self.bgLayer:getContentSize().width-40
        local cellH = 165
        local lbX = 110
        local gapH=30
        local ladderList=self.personScoreDetailList
        if self.tabType==2 then
            ladderList = self.allianceScoreDetailList
        end
        if ladderList and ladderList[idx+1] then
            local itemVO = ladderList[idx+1]
            local itemBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function ()end)
            itemBgSp:setContentSize(CCSizeMake(cellW,cellH))
            itemBgSp:setPosition(ccp(cellW/2,cellH/2))
            cell:addChild(itemBgSp)

            local timeLb=GetTTFLabelWrap(G_getDataTimeStr(itemVO.st),25,CCSizeMake(220,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
            timeLb:setPosition(ccp(cellW-20,cellH-20))
            timeLb:setAnchorPoint(ccp(1,0.5))
            cell:addChild(timeLb,2)
            if itemVO.rtype==1 then
            -- if itemVO.rtype==1 and idx%2==0 then                
                local timeBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),function ()end)
                timeBg:setContentSize(CCSizeMake(300,35))
                timeBg:setScaleX((cellW-20)/timeBg:getContentSize().width)
                timeBg:setPosition(ccp((cellW)/2,itemBgSp:getContentSize().height-timeBg:getContentSize().height/2))
                cell:addChild(timeBg)

                local platNameBg1=CCSprite:createWithSpriteFrameName("platWarNameBg1.png")
                platNameBg1:setAnchorPoint(ccp(0,0.5))
                platNameBg1:setPosition(ccp(0,cellH-15))
                cell:addChild(platNameBg1,2)

                local subTitleLb=GetTTFLabelWrap(ladderVoApi:getWarNameById(itemVO.r),25,CCSizeMake(220,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                subTitleLb:setPosition(ccp(platNameBg1:getContentSize().width/2-5,platNameBg1:getContentSize().height/2+3))
                platNameBg1:addChild(subTitleLb)

                local servernameLb1=GetTTFLabelWrap(GetServerNameByID(itemVO.sid1),25,CCSizeMake(220,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                servernameLb1:setPosition(ccp(lbX,cellH-50))
                cell:addChild(servernameLb1,3)
                servernameLb1:setColor(G_ColorYellow)

                local servernameLb2=GetTTFLabelWrap(GetServerNameByID(itemVO.sid2),25,CCSizeMake(220,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                servernameLb2:setPosition(ccp(cellW-lbX,cellH-50))
                cell:addChild(servernameLb2,3)
                

                local nameLb1=GetTTFLabelWrap(itemVO.name1,25,CCSizeMake(220,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                nameLb1:setPosition(ccp(lbX,cellH-50-gapH))
                cell:addChild(nameLb1,3)
                nameLb1:setColor(G_ColorYellow)
                
                local name2
                if itemVO.name2==nil then
                    name2=getlocal("world_war_battle_empty")
                else
                    name2=itemVO.name2
                end
                local nameLb2=GetTTFLabelWrap(name2,25,CCSizeMake(220,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                nameLb2:setPosition(ccp(cellW-lbX,cellH-50-gapH))
                cell:addChild(nameLb2,3)

                local scoreLb1=GetTTFLabelWrap(itemVO.score1,25,CCSizeMake(220,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                scoreLb1:setPosition(ccp(lbX,cellH-80-gapH))
                cell:addChild(scoreLb1,3)
                scoreLb1:setColor(G_ColorYellow)
                local scoreLb2=GetTTFLabelWrap(itemVO.score2,25,CCSizeMake(220,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                scoreLb2:setPosition(ccp(cellW-lbX,cellH-80-gapH))
                cell:addChild(scoreLb2,3)
                local addScroeStr1 = "("..tonumber(itemVO.addscore1)..")"
                if itemVO.addscore1>0 then
                    addScroeStr1 = "(+"..tonumber(itemVO.addscore1)..")"
                end
                local addScoreLb1=GetTTFLabelWrap(addScroeStr1,25,CCSizeMake(220,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                addScoreLb1:setPosition(ccp(lbX,cellH-110-gapH))
                cell:addChild(addScoreLb1,3)
                if itemVO.addscore1>0 then
                    addScoreLb1:setColor(G_ColorGreen)
                else
                    addScoreLb1:setColor(G_ColorRed)
                end

                local addScroeStr2 = "("..tonumber(itemVO.addscore2)..")"
                if itemVO.addscore2>0 then
                    addScroeStr2 = "(+"..tonumber(itemVO.addscore2)..")"
                end
                local addScoreLb2=GetTTFLabelWrap(addScroeStr2,25,CCSizeMake(220,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                addScoreLb2:setPosition(ccp(cellW-lbX,cellH-110-gapH))
                cell:addChild(addScoreLb2,3)
                if itemVO.addscore2>0 then
                    addScoreLb2:setColor(G_ColorGreen)
                else
                    addScoreLb2:setColor(G_ColorRed)
                end

                local resultPic=""
                if tonumber(itemVO.addscore1)>tonumber(itemVO.addscore2) then
                    -- 我赢了
                    resultPic="winnerMedal.png"
                    if itemVO.r==5 then
                        servernameLb2:setVisible(false)
                        addScoreLb2:setVisible(false)
                        nameLb2:setString(getlocal("ladder_enemy_average"))
                    end
                else
                    resultPic="loserMedal.png"
                    if itemVO.r==5 and itemVO.nb==1 then
                        servernameLb2:setVisible(false)
                        addScoreLb2:setVisible(false)
                        scoreLb2:setVisible(false)
                        nameLb2:setString(getlocal("world_war_battle_empty"))
                    end
                end
                local resultIcon=CCSprite:createWithSpriteFrameName(resultPic)
                resultIcon:setPosition(ccp(cellW/2,cellH-80-gapH))
                cell:addChild(resultIcon)
            else
                local platNameBg1=CCSprite:createWithSpriteFrameName("platWarNameBg2.png")
                platNameBg1:setAnchorPoint(ccp(0,0.5))
                platNameBg1:setPosition(ccp(0,cellH-15))
                cell:addChild(platNameBg1,2)

                local subTitleLb=GetTTFLabelWrap(ladderVoApi:getWarNameById(itemVO.r),25,CCSizeMake(220,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                subTitleLb:setPosition(ccp(platNameBg1:getContentSize().width/2-5,platNameBg1:getContentSize().height/2+3))
                platNameBg1:addChild(subTitleLb)

                local descSp=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),function() end)
                descSp:setContentSize(CCSizeMake(cellW-20,cellH-40))
                descSp:setPosition(ccp(cellW/2,5+(cellH-40)/2))
                itemBgSp:addChild(descSp)

                local rankStr=getlocal("serverwar_rank_"..itemVO.rank)
                --军团跨服战特殊处理，34名合并为并列第三，5到8名合并为并列第四
                if(tonumber(itemVO.rtype)==2 and tonumber(itemVO.r)==2)then
                    if(tonumber(itemVO.rank)==3 or tonumber(itemVO.rank)==4)then
                        rankStr=getlocal("rankOne",{3})
                    elseif(tonumber(itemVO.rank)<=8 and tonumber(itemVO.rank)>2)then
                        rankStr=getlocal("rankOne",{4})
                    else
                        rankStr=getlocal("rankOne",{itemVO.rank})
                    end
                else
                    if tonumber(itemVO.rank)>3 then
                        rankStr=getlocal("rankOne",{itemVO.rank})
                    end
                end
                local contentStr1 = ""
                if self.tabType==1 then
                    if itemVO.rtype==2 then
                        contentStr1=getlocal("ladder_score_desc1",{ladderVoApi:getWarNameById(itemVO.r),rankStr,itemVO.addscore1})
                    else
                        contentStr1=getlocal("ladder_score_desc3",{ladderVoApi:getWarNameById(itemVO.r),itemVO.addscore1})
                    end
                else
                    contentStr1=getlocal("ladder_score_desc2",{itemVO.username,ladderVoApi:getWarNameById(itemVO.r),rankStr,itemVO.addscore1})
                end
                local contentLb1=GetTTFLabelWrap(contentStr1,23,CCSizeMake(cellW-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                contentLb1:setPosition(ccp((cellW-20)/2,cellH-100))
                descSp:addChild(contentLb1,3)
            end
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

function ladderScoreDialogTab1:getData()
    self.personScoreDetailList=ladderVoApi:getPersonScoreDetailList()
    self.allianceScoreDetailList=ladderVoApi:getAllianceScoreDetailList()
end

function ladderScoreDialogTab1:tick()
    self:initMaskSp()
end

function ladderScoreDialogTab1:dispose()
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/platWar/platWarImage.plist")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/platWar/platWarImage.png")
    spriteController:removePlist("serverWar/serverWar.plist")
    spriteController:removeTexture("serverWar/serverWar.pvr.ccz")
    self.bgLayer:removeFromParentAndCleanup(true)
end