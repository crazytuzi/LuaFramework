acEatChickenDialogTabTwo={

}

function acEatChickenDialogTabTwo:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    nc.tv=nil
    nc.bgLayer=nil
    nc.layerNum=layerNum
    nc.cellHeight=145
    nc.aScores = {}
    nc.aAwards = {}
    nc.pScores = {}
    nc.pAwards = {}
    nc.singleScores = 0
    return nc;
end
function acEatChickenDialogTabTwo:dispose( )
    self.cellHeight = nil
    self.layerNum = nil
    self.bgLayer = nil
    self.tv = nil
    self.singleScores = nil
    self.aScores = nil
    self.aAwards = nil
    self.pScores = nil
    self.pAwards = nil
end

function acEatChickenDialogTabTwo:init(layerNum,parent)
    self.activeName=acEatChickenVoApi:getActiveName()
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self.aScores,self.aAwards = acEatChickenVoApi:getAllianceScoresAndAward( )
    self.pScores,self.pAwards = acEatChickenVoApi:getPersonScoresAndAward()
    self:initUp()
    -- self:initCenter()
    self:initTableView()
    return self.bgLayer
end

function acEatChickenDialogTabTwo:refresh()
    -- print("tab 222222 refresh~~~~~~~~")
    local legionScores = acEatChickenVoApi:getLegionMembersScores() or 0--拿到军团总积分 是总积分！
    local singleScores = acEatChickenVoApi:getSingleScores()
    if self.legionScoresStr and acEatChickenVoApi:getFirst( ) == 3  then
        self.legionScoresStr:setString(getlocal("legionMembersScores",{legionScores}))
    elseif acEatChickenVoApi:getFirst( ) == 2 then
            self.legionScoresStr:setString(getlocal("activity_qmcj_aRewardNotGet"))
    end
    self.legionScores = legionScores
    self:initOrRefreshProgress(true)

    if self.bottomTitleLb then
        self.bottomTitleLb:setString(getlocal("singleScores",{singleScores}))
    end
    self.singleScores = singleScores
    self.taskTb=acEatChickenVoApi:getPersonAwardState()
    if self.tv then
        local recordPoint=self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
end

function acEatChickenDialogTabTwo:initUp()
    local startH=G_VisibleSizeHeight - 170
    -- print("军团个人积分排名~~~~~",allianceVoApi:isHasAlliance())
    local upBg = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),function( ) end)
    upBg:setContentSize(CCSizeMake(616,G_VisibleSizeHeight*0.2))
    upBg:setPosition(ccp(G_VisibleSizeWidth*0.5,startH))
    upBg:setAnchorPoint(ccp(0.5,1))
    upBg:setOpacity(0)
    self.upBg = upBg
    self.bgLayer:addChild(upBg)
    self:initTv2()
    self.bottomHeight = startH - upBg:getContentSize().height - 30

    local function touchInfo()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        
        if allianceVoApi:isHasAlliance() == false then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_btzx_noJoinAlliance"),30)
            do return end
        end
        local isCanGetAllianceRankList,aRankList = acEatChickenVoApi:isCanGetAllianceRankList()
        if isCanGetAllianceRankList then
            local function getLegionMembersCall()
                local aRankList = acEatChickenVoApi:getAllianceRankList( )
                if aRankList == nil then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dimensionalWar_no_rank_show"),30)
                elseif SizeOfTable(aRankList) == 0 then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage26022"),30)
                else
                    -- print("展示军团个人排名~~~~~11111")
                    self:showAllianceScoresRankDialog(aRankList)
                end
            end
            local action = 4
            acEatChickenVoApi:getIntegralRelatedDataSocket(getLegionMembersCall,action)--获取军团所有成员积分和名字
        else
            -- print("展示军团个人排名~~~~~22222")
            self:showAllianceScoresRankDialog(aRankList)
        end
    end
    local scaleNum = 0.78
    local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touchInfo,1,nil,0)
    menuItemDesc:setAnchorPoint(ccp(0,1))
    menuItemDesc:setScale(scaleNum)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-4)
    local subPosy = G_isIphone5() and 20 or 15
    menuDesc:setPosition(ccp(15,upBg:getContentSize().height - subPosy))
    upBg:addChild(menuDesc)

    local legionScores = acEatChickenVoApi:getLegionMembersScores()--拿到军团总积分 是总积分！
    self.legionScores = legionScores
    local lsStr = acEatChickenVoApi:getFirst( ) == 2 and getlocal("activity_qmcj_aRewardNotGet") or getlocal("legionMembersScores",{legionScores})
    local legionScoresStr=GetTTFLabelWrap(lsStr,22,CCSizeMake(G_VisibleSizeWidth-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    legionScoresStr:setAnchorPoint(ccp(0,0.5))
    legionScoresStr:setPosition(ccp(menuDesc:getPositionX() + menuItemDesc:getContentSize().width*scaleNum + 5,menuDesc:getPositionY() - menuItemDesc:getContentSize().height*0.5* scaleNum))
    upBg:addChild(legionScoresStr)
    self.legionScoresStr=legionScoresStr

    local upBg2 =LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),function( ) end)
    upBg2:setContentSize(CCSizeMake(upBg:getContentSize().width,upBg:getContentSize().height - menuItemDesc:getContentSize().height - 15))
    upBg2:ignoreAnchorPointForPosition(false)
    upBg2:setAnchorPoint(ccp(0.5,0))
    upBg2:setPosition(ccp(upBg:getContentSize().width*0.5,10))
    upBg:addChild(upBg2)
    self.upBg2 = upBg2
    upBg2:setOpacity(0)
    
    self:initOrRefreshProgress()
end

function acEatChickenDialogTabTwo:initTv2()
    if self.upBg then
        local function callBack(...)
            return self:eventHandler2(...)
        end
        local hd= LuaEventHandler:createHandler(callBack)
        self.tv2=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.upBg:getContentSize().width,self.upBg:getContentSize().height-10),nil)
        self.upBg:setTouchPriority(-(self.layerNum-1)*20-1)
        self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
        self.tv2:setPosition(ccp(0,5))
        self.upBg:addChild(self.tv2)
        self.tv2:setMaxDisToBottomOrTop(0)
    end
end

function acEatChickenDialogTabTwo:initOrRefreshProgress(flag)

    local boxAddPosY,boxScale,sPoint,nPoint = 35,0.55,0.3,0.25
    local addPosY = 35
    if G_isIphone5() then
        boxAddPosY,boxScale,sPoint,nPoint = 40,0.65,0.4,0.3
        addPosY = 45
    end

    local posY=self.posY
    if flag then
        local timerSpriteLv=self.upBg2:getChildByTag(11)
        if timerSpriteLv then
            timerSpriteLv:removeFromParentAndCleanup(true)
        end
        local timerSpriteBg=self.upBg2:getChildByTag(13)
        if timerSpriteBg then
            timerSpriteBg:removeFromParentAndCleanup(true)
        end
    end
    local needPoint= self.aScores
    local pointPrize=self.aAwards

    local acPoint=acEatChickenVoApi:getLegionMembersScores() or 0
    acPoint = type(acPoint)=="table" and 0 or acPoint
    local percentStr=""
    local centerWidth,centerHeight=self.upBg2:getContentSize().width*0.5,self.upBg2:getContentSize().height*0.5

    local barWidth=500
    -- print("tonumber(acPoint),needPoint===>>>>",tonumber(acPoint),needPoint)
    local per=G_getPercentage(tonumber(acPoint),needPoint)
    AddProgramTimer(self.upBg2,ccp(centerWidth-10,centerHeight*0.6),11,12,percentStr,"platWarProgressBg.png","taskBlueBar.png",13,1,1)
    local timerSpriteLv=self.upBg2:getChildByTag(11)
    timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
    timerSpriteLv:setPercentage(per)
    local timerSpriteBg=self.upBg2:getChildByTag(13)
    timerSpriteBg=tolua.cast(timerSpriteBg,"CCSprite")

    local totalWidth=timerSpriteBg:getContentSize().width
    local totalHeight=timerSpriteBg:getContentSize().height
    local everyWidth=totalWidth/SizeOfTable(needPoint)

    -- 当前值
    local acSp=CCSprite:createWithSpriteFrameName("taskActiveSp.png")
    acSp:setPosition(ccp(0,totalHeight/2))
    timerSpriteLv:addChild(acSp,2)

    local acPointLb=GetBMLabel(acPoint,G_GoldFontSrc,10)
    acPointLb:setPosition(ccp(acSp:getContentSize().width/2,acSp:getContentSize().height/2-2))
    acSp:addChild(acPointLb,2)
    acPointLb:setScale(sPoint)

    

    for k,v in pairs(needPoint) do
        local acSp1=CCSprite:createWithSpriteFrameName("taskActiveSp1.png")
        acSp1:setPosition(ccp(everyWidth*k,totalHeight/2))
        timerSpriteLv:addChild(acSp1,1)
        acSp1:setScale(1.2)
        local acSp2=CCSprite:createWithSpriteFrameName("taskActiveSp2.png")
        acSp2:setPosition(ccp(everyWidth*k,totalHeight/2))
        timerSpriteLv:addChild(acSp2,1)
        acSp2:setScale(1.2)
        if acPoint>=v then
            acSp2:setVisible(true)
        else
            acSp2:setVisible(false)
        end
        local numLb=GetBMLabel(v,G_GoldFontSrc,10)
        numLb:setPosition(ccp(everyWidth*k,totalHeight/2))
        timerSpriteLv:addChild(numLb,3)
        numLb:setScale(nPoint)

        -- flag 1 未达成 2 可领取 3 已领取
        local flag= acEatChickenVoApi:getAllianceScoresState(k) 

        local function clickBoxHandler( ... )
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            local titleColorTb = {G_ColorWhite,G_ColorGreen,G_ColorBlue,G_ColorPurple,G_ColorOrange}
            local titleStr=getlocal("activity_openyear_baoxiang" .. k)
            if flag~=2 then--军团奖励小板子展示-------------------------
                local reward={pointPrize[k]}
                local desStr=getlocal("activity_openyear_allreward_des")
                acEatChickenVoApi:showRewardKu(titleStr,self.layerNum,reward,desStr,titleColorTb[k])
                return
            end
            -------------------------军团领奖并且刷新
            if acEatChickenVoApi:getFirst() == 2 then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_qmcj_aRewardNotGet"),30)
                do return end
            end
            local function refreshFunc()
                self:initOrRefreshProgress(true)
                if k==5 then
                    local desStr
                    desStr="activity_pjgx_chatMessage1"
                    local paramTab={}
                    paramTab.functionStr="qmcj"
                    paramTab.addStr="i_also_want"
                    local message={key=desStr,param={playerVoApi:getPlayerName(),getlocal("activity_qmcj_title"),titleStr}}
                    chatVoApi:sendSystemMessage(message,paramTab)
                end

                -- 此处加弹板
                local rewardItem=FormatItem(pointPrize[k],nil,true)
                for k,v in pairs(rewardItem) do
                    G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                end
                G_showRewardTip(rewardItem)
                if acEatChickenVoApi:getFlag() == 1 then
                    acEatChickenVoApi:setFlag(0) 
                    smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("activity_qmcj_flagStr"),nil,8)
                end
            end
            local action,apoint=2,v
            acEatChickenVoApi:getIntegralRelatedDataSocket(refreshFunc,action,apoint)

        end

        
        local boxSp=LuaCCSprite:createWithSpriteFrameName("taskBox"..k..".png",clickBoxHandler)
        boxSp:setTouchPriority(-(self.layerNum-1)*20-4)
        boxSp:setPosition(everyWidth*k,totalHeight+boxAddPosY)
        timerSpriteLv:addChild(boxSp,3)
        boxSp:setScale(boxScale)

        
        if flag==2 then
            local lightSp = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
            lightSp:setPosition(everyWidth*k,totalHeight+addPosY)
            timerSpriteLv:addChild(lightSp)
            lightSp:setScale(0.5)

            local time = 0.1--0.07
            local rotate1=CCRotateTo:create(time, 30)
            local rotate2=CCRotateTo:create(time, -30)
            local rotate3=CCRotateTo:create(time, 20)
            local rotate4=CCRotateTo:create(time, -20)
            local rotate5=CCRotateTo:create(time, 0)
            local delay=CCDelayTime:create(1)
            local acArr=CCArray:create()
            acArr:addObject(rotate1)
            acArr:addObject(rotate2)
            acArr:addObject(rotate3)
            acArr:addObject(rotate4)
            acArr:addObject(rotate5)
            acArr:addObject(delay)
            local seq=CCSequence:create(acArr)
            local repeatForever=CCRepeatForever:create(seq)
            boxSp:runAction(repeatForever)
        elseif flag==3 then
            local lbBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),function ()end)
            lbBg:setScaleX(150/lbBg:getContentSize().width)
            lbBg:setPosition(everyWidth*k,totalHeight+addPosY)
            timerSpriteLv:addChild(lbBg,4)
            lbBg:setScale(0.7)
            local hasRewardLb=GetTTFLabel(getlocal("activity_hadReward"),20)
            hasRewardLb:setPosition(everyWidth*k,totalHeight+addPosY)
            timerSpriteLv:addChild(hasRewardLb,5)
        end
    end
end

function acEatChickenDialogTabTwo:initTableView()

    local bottomBg = LuaCCScale9Sprite:createWithSpriteFrameName("greenBlackBg2.png",CCRect(10,10,12,12),function ()end)
    bottomBg:setContentSize(CCSizeMake(616,self.bottomHeight))
    bottomBg:setPosition(ccp((G_VisibleSizeWidth - 616)*0.5,30))
    bottomBg:setAnchorPoint(ccp(0,0))
    self.bgLayer:addChild(bottomBg)

    local singleScores = acEatChickenVoApi:getSingleScores()
    self.singleScores = singleScores
    local bottomTitleLb=GetTTFLabel(getlocal("singleScores",{singleScores}),22)
    bottomTitleLb:setAnchorPoint(ccp(0,1))
    bottomTitleLb:setPosition(ccp(10,bottomBg:getContentSize().height - 15))
    self.bottomTitleLb = bottomTitleLb
    bottomBg:addChild(bottomTitleLb,1)

    self.taskTb = acEatChickenVoApi:getPersonAwardState()
    local function callBack(...)
         return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(bottomBg:getContentSize().width - 10,bottomBg:getContentSize().height - 50),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(10,5))
    bottomBg:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
end

function acEatChickenDialogTabTwo:eventHandler(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
        return SizeOfTable(self.pScores) or 1
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(G_VisibleSizeWidth-45,145)--self.cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local strSize2,strSize3,strWidth2 = 21,19,G_VisibleSizeWidth-100
        if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() =="tw" then
            strSize2,strSize3,strWidth2 = 22,20,G_VisibleSizeWidth-90
        end

        local function nilFunc()
        end
        local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),nilFunc)
        backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-45,145))--self.cellHeight))
        backSprie:ignoreAnchorPointForPosition(false)
        backSprie:setAnchorPoint(ccp(0,0))
        backSprie:setPosition(ccp(0,0))
        cell:addChild(backSprie)
        local index,awardState=self.taskTb[idx+1].index,self.taskTb[idx+1].state--1 未达成 2 可领取 3 已领取
        local needScores = self.pScores[index] or 1000000
        local titleStr = getlocal("singleNeedScores",{self.singleScores,needScores})
        local lbStarWidth=20
        if G_getCurChoseLanguage() =="ar" then
            strWidth2 = strWidth2 -100
        end
        local titleLb=GetTTFLabelWrap(titleStr,strSize2,CCSizeMake(strWidth2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        titleLb:setAnchorPoint(ccp(0,1))
        titleLb:setColor(G_ColorYellowPro)
        titleLb:setPosition(ccp(lbStarWidth,backSprie:getContentSize().height-15))
        backSprie:addChild(titleLb,1)

        -- 奖励描述
        local desH=(self.cellHeight - titleLb:getContentSize().height-10)*0.5
        local desLb=GetTTFLabelWrap(getlocal("activity_rechargeDouble_get"),strSize3,CCSizeMake(100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        desLb:setAnchorPoint(ccp(0,0.5))
        -- desLb:setColor(G_ColorYellowPro)
        desLb:setPosition(ccp(lbStarWidth,desH))
        backSprie:addChild(desLb)

        -- -- 奖励展示
        local rewardItem=FormatItem(self.pAwards[index],nil,true)
        local taskW=0
        for k,v in pairs(rewardItem) do
            local function showNewPropInfo()
                G_showNewPropInfo(self.layerNum+1,true,true,nil,v)
                return false
            end
            local icon = G_getItemIcon(v,100,true,self.layerNum+1,showNewPropInfo,self.tv,nil,nil,nil)
            icon:setTouchPriority(-(self.layerNum-1)*20-2)
            backSprie:addChild(icon)
            icon:setAnchorPoint(ccp(0,0.5))
            icon:setPosition(k*80+20, desH)
            local scale=75/icon:getContentSize().width
            icon:setScale(scale)
            taskW=k*100


            local numLabel=GetTTFLabel("x"..FormatNumber(v.num),22)
            numLabel:setAnchorPoint(ccp(1,0))
            numLabel:setPosition(icon:getContentSize().width-5, 5)
            numLabel:setScale(1/scale)
            icon:addChild(numLabel,1)
        end

        
        if awardState == 3 then -- 已完成(已领取)
            local alreadyLb=GetTTFLabel(getlocal("activity_hadReward"),23)
            alreadyLb:setColor(G_ColorWhite)
            alreadyLb:setPosition(ccp(backSprie:getContentSize().width-75,desH))
            backSprie:addChild(alreadyLb,1)
            alreadyLb:setColor(G_ColorGray)
        else -- 可领取
            local function rewardTiantang()
                if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)

                    local function refreshFunc()
                        self:refresh()
                        for k,v in pairs(rewardItem) do
                            G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                        end
                        G_showRewardTip(rewardItem)
                    end
                    local action,point = 3,needScores
                    acEatChickenVoApi:getIntegralRelatedDataSocket(refreshFunc,action,nil,point)

                end
            end
            -- "BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png"
            local rMenuItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",rewardTiantang,nil,getlocal("daily_scene_get"),25/0.8,99)
            rMenuItem:setScale(0.6)
            local rewardBtn=CCMenu:createWithItem(rMenuItem);
            rewardBtn:setTouchPriority(-(self.layerNum-1)*20-2);
            rewardBtn:setPosition(ccp(backSprie:getContentSize().width-75,desH))
            backSprie:addChild(rewardBtn)

            titleLb:setColor(G_ColorGreen)
            if awardState == 1 then ---------------------未完成
                local menuStr = tolua.cast(rMenuItem:getChildByTag(99),"CCLabelTTF")
                menuStr:setString(getlocal("local_war_incomplete"))
                rMenuItem:setEnabled(false)
                titleLb:setColor(G_ColorRed)
            end
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


function acEatChickenDialogTabTwo:tick( )
    if acEatChickenVoApi:getUpDataState() then
        acEatChickenVoApi:setUpDataState(false)
        self:refresh()
    end
    if self.legionScores and acEatChickenVoApi:getLegionMembersScores() and self.legionScores < acEatChickenVoApi:getLegionMembersScores() then
        if self.legionScoresStr and acEatChickenVoApi:getFirst( ) == 3 then
            local legionScores = acEatChickenVoApi:getLegionMembersScores()
            self.legionScores = legionScores
            self.legionScoresStr:setString(getlocal("legionMembersScores",{legionScores}))
        elseif acEatChickenVoApi:getFirst( ) == 2 then
            self.legionScoresStr:setString(getlocal("activity_qmcj_aRewardNotGet"))
        end
    end

end

function acEatChickenDialogTabTwo:showAllianceScoresRankDialog(aRankList)
    require "luascript/script/game/scene/gamedialog/activityAndNote/publicRankListDialog"
    ----titleShowNeed = {rankTitleTb,rowTb,pointTb,widthTb}
    local rankTitleTb,rowTb,pointTb,widthTb = {"alliance_scene_rank","acHongchangyuebingPlayer","serverwar_point"},{0.15,0.5,0.85},{0.5,0.5,0.5},{150,300,150}
    local titleShowNeed = {rankTitleTb,rowTb,pointTb,widthTb}
    publicRankListDialog:showRankListDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-300),CCRect(130, 50, 1, 1),{getlocal("personRankListInAlliance"),G_ColorWhite},aRankList,false,self.layerNum+1,nil,true,true,true,titleShowNeed)
end


function acEatChickenDialogTabTwo:eventHandler2(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        if self.upBg==nil then
            do return end
        end
        local tmpSize
        tmpSize=CCSizeMake(self.upBg:getContentSize().width,self.upBg:getContentSize().height-10)
        return tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        if self.upBg==nil then
            do return cell end
        end

        local bgWidth=self.upBg:getContentSize().width
        local bgHeight=self.upBg:getContentSize().height-10
        local pox1,poy1=60,bgHeight/2-8
        local barWidth=450
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        local backBg=CCSprite:create("public/emblem/emblemBlackBg.jpg")
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

        backBg:setPosition(ccp(bgWidth/2,bgHeight/2-30))
        cell:addChild(backBg)
        return cell
    end
end
