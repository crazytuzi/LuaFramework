arenaDialogTab1={

}

function arenaDialogTab1:new(parent)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.leftBtn=nil
    self.expandIdx={}
    self.parent=parent
    self.bgLayer=nil;
    self.normalHeight=74
    self.itemTb={}
   
    return nc
end

function arenaDialogTab1:init(layerNum,parent)
    self.layerNum=layerNum;
    self.bgLayer=CCLayer:create();
    self:initTabLayer()
    self.parent=parent

    
    
    return self.bgLayer
end

function arenaDialogTab1:initTabLayer()
    
    self.straightTimesLb = GetTTFLabel(getlocal("arena_straightTimes",{arenaVoApi:getArenaVo().victory}),30);
    self.straightTimesLb:setAnchorPoint(ccp(0,0.5));
    self.straightTimesLb:setPosition(ccp(50,G_VisibleSize.height-220));
    self.bgLayer:addChild(self.straightTimesLb,2);

    -- local function touchInfo()
    --     local td=smallDialog:new()
    --     local str1 = getlocal("arena_ExercisesDes1")
    --     local str2 = getlocal("arena_ExercisesDes2")
    --     local str3 = getlocal("arena_ExercisesDes3")
    --     local str4 = getlocal("arena_ExercisesDes4")
    --     local str5 = getlocal("arena_ExercisesDes5")
    --     local tabStr = {" ",str5,str4,str3,str2,str1," "}
    --     local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28)
    --     sceneGame:addChild(dialog,self.layerNum+1)
    -- end

    -- local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touchInfo,11,nil,nil)
    -- local infoMenu = CCMenu:createWithItem(infoItem);
    -- infoMenu:setPosition(ccp(380,G_VisibleSize.height-220));
    -- infoMenu:setTouchPriority(-(self.layerNum-1)*20-3);
    -- self.bgLayer:addChild(infoMenu,2);

    local function fightRecord()
        local td=reportListDialog:new()
        local tbArr={}
        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("arena_fightRecord"),true,self.layerNum+1)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
    self.fightRecordItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnCancleSmall.png",fightRecord,nil,getlocal("arena_fightRecord"),25)
    local fightRecordMenu=CCMenu:createWithItem(self.fightRecordItem);
    fightRecordMenu:setPosition(ccp(520,G_VisibleSize.height-220))
    fightRecordMenu:setTouchPriority((-(self.layerNum-1)*20-4));
    self.bgLayer:addChild(fightRecordMenu)


    local numHeight=25
    local iconWidth=36
    local iconHeight=36
    local unreadNum=arenaReportVoApi:getUnreadNum()
    local newsNumLabel = GetTTFLabel(unreadNum or 0,numHeight)
    newsNumLabel:setPosition(ccp(newsNumLabel:getContentSize().width/2+5,iconHeight/2))
    newsNumLabel:setTag(11)
    --newsNumLabel:setColor(G_ColorRed) 
    local capInSet1 = CCRect(17, 17, 1, 1)
    local function touchClick()
    end
    local newsIcon =LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",capInSet1,touchClick)
    if newsNumLabel:getContentSize().width+10>iconWidth then
        iconWidth=newsNumLabel:getContentSize().width+10
    end
    newsIcon:setContentSize(CCSizeMake(iconWidth,iconHeight))
    newsIcon:ignoreAnchorPointForPosition(false)
    newsIcon:setAnchorPoint(CCPointMake(1,0.5))
    newsIcon:setPosition(ccp(self.fightRecordItem:getContentSize().width,self.fightRecordItem:getContentSize().height-15))
    newsIcon:addChild(newsNumLabel,1)
    newsIcon:setTag(10)
    newsNumLabel:setPosition(getCenterPoint(newsIcon))
    newsIcon:setVisible(false)
    self.fightRecordItem:addChild(newsIcon)
    if unreadNum and unreadNum>0 then
        newsIcon:setVisible(true)
    end


    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
    lineSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,G_VisibleSize.height-270));
    self.bgLayer:addChild(lineSp,1)

    local hi=G_VisibleSize.height-290
    local tlbSize=26
    local tLb1 = GetTTFLabel(getlocal("alliance_scene_rank"),tlbSize);
    tLb1:setPosition(ccp(80,hi));
    self.bgLayer:addChild(tLb1,2);

    local tLb2 = GetTTFLabel(getlocal("alliance_scene_button_info_name"),tlbSize);
    tLb2:setPosition(ccp(195,hi));
    self.bgLayer:addChild(tLb2,2);

    local tLb3 = GetTTFLabel(getlocal("RankScene_level"),tlbSize);
    tLb3:setPosition(ccp(315,hi));
    self.bgLayer:addChild(tLb3,2);

    local tLb4 = GetTTFLabel(getlocal("arena_rankReward"),tlbSize);
    tLb4:setAnchorPoint(ccp(0,0.5));
    tLb4:setPosition(ccp(360,hi));
    self.bgLayer:addChild(tLb4,2);

    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
    lineSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,G_VisibleSize.height-320));
    self.bgLayer:addChild(lineSp,1)

    local textSize = 25
    if G_curPlatName()=="androidzhongshouyouru" or G_curPlatName()=="12" or G_curPlatName()=="testServer" or G_getCurChoseLanguage() =="vi" then
        textSize = 18
    end

    self.prevRankingLb = GetTTFLabel(getlocal("arena_prevRanking",{arenaVoApi:getArenaVo().ranked}),textSize);
    self.prevRankingLb:setAnchorPoint(ccp(0,0.5));
    self.prevRankingLb:setPosition(ccp(50,100));
    self.bgLayer:addChild(self.prevRankingLb,2);

    local rTimeStr = G_getTimeStr(arenaVoApi:getRewardTime())
    self.rewardLb = GetTTFLabel(getlocal("arena_nextAward",{rTimeStr}),textSize);
    self.rewardLb:setAnchorPoint(ccp(0,0.5));
    self.rewardLb:setPosition(ccp(50,60));
    self.bgLayer:addChild(self.rewardLb,2);

    -- local function touchInfo2()
    --     local td=smallDialog:new()
    --     local str1 = getlocal("allianceWarDesc1")
    --     local str2 = getlocal("allianceWarDesc2")
    --     local str3 = getlocal("allianceWarDesc3")
    --     local str4 = getlocal("allianceWarDesc4")
    --     local tabStr = {" ",str4,str3,str2,str1," "}
    --     local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28)
    --     sceneGame:addChild(dialog,self.layerNum+1)
    -- end

    -- local infoItem2 = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touchInfo,11,nil,nil)
    -- local infoMenu2 = CCMenu:createWithItem(infoItem2);
    -- infoMenu2:setPosition(ccp(380,80));
    -- infoMenu2:setTouchPriority(-(self.layerNum-1)*20-3);
    -- self.bgLayer:addChild(infoMenu2,2);

    local function reward()
        arenaSmallDialog:create(self.layerNum+1)
    end
    self.rewardItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnCancleSmall.png",reward,nil,getlocal("newGiftsReward"),25)
    local rewardMenu=CCMenu:createWithItem(self.rewardItem);
    rewardMenu:setPosition(ccp(520,80))
    rewardMenu:setTouchPriority((-(self.layerNum-1)*20-4));
    self.bgLayer:addChild(rewardMenu)

    if arenaVoApi:isCanReward()==false then
        self.rewardItem:setEnabled(false)
    end

    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
    lineSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,130));
    self.bgLayer:addChild(lineSp,1)

    self.numExercisesLb = GetTTFLabel(getlocal("arena_numExercises",{arenaVoApi:getArenaVo().attack_count}),textSize);
    self.numExercisesLb:setAnchorPoint(ccp(0,0.5));
    self.numExercisesLb:setPosition(ccp(50,200));
    self.bgLayer:addChild(self.numExercisesLb,2);

    self.numLeftLb = GetTTFLabel(getlocal("arena_numLeft",{arenaVoApi:getArenaVo().attack_num-arenaVoApi:getArenaVo().attack_count}),textSize);
    self.numLeftLb:setAnchorPoint(ccp(0,0.5));
    self.numLeftLb:setPosition(ccp(50,160));
    self.bgLayer:addChild(self.numLeftLb,2);

    local function addnum()

        if bagVoApi:getItemNumId(292)>0 then

            local function buyNum()
                local function callback(fn,data)
                    if base:checkServerData(data)==true then
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("arena_propSuccess"),30)
                        bagVoApi:useItemNumId(292,1)
                    end
                end

                socketHelper:militaryBuy(2,callback)
            end
            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyNum,getlocal("dialog_title_prompt"),getlocal("arena_buyFightNumByP292",{arenaCfg.buyChallengingTimesGold}),nil,self.layerNum+1)
        else
            local gem=playerVoApi:getGems()-arenaCfg.buyChallengingTimesGold
            if gem<0 then
                local function jumpGemDlg()
                    vipVoApi:showRechargeDialog(self.layerNum+1)
                end
                smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),jumpGemDlg,getlocal("dialog_title_prompt"),getlocal("alliance_createAllianceNoGem"),nil,self.layerNum+1)

                do
                    return
                end

            end

            local function buyNum()
                local function callback(fn,data)
                    if base:checkServerData(data)==true then
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("arena_buyFightNumSuccess"),30)
                        local gem=playerVoApi:getGems()-arenaCfg.buyChallengingTimesGold
                        playerVoApi:setGems(gem)
                    end
                end

                socketHelper:militaryBuy(2,callback)
            end
            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyNum,getlocal("dialog_title_prompt"),getlocal("arena_buyFightNum",{arenaCfg.buyChallengingTimesGold}),nil,self.layerNum+1)
        end
        
    end
    local addnumItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnCancleSmall.png",addnum,nil,getlocal("arena_numAdd"),25)
    self.addnumMenu=CCMenu:createWithItem(addnumItem);
    self.addnumMenu:setPosition(ccp(520,180))
    self.addnumMenu:setTouchPriority((-(self.layerNum-1)*20-4));
    self.bgLayer:addChild(self.addnumMenu)


    local function accelerate()
        local function accelerateNum()
            local cdTime=arenaVoApi:getCDTime()
            local costGold=arenaCfg.getGoldByTime(cdTime)
            local function accelerateCallback(fn,data)
                if base:checkServerData(data)==true then
                    local gem=playerVoApi:getGems()-costGold
                    playerVoApi:setGems(gem)
                end
            end

            socketHelper:militaryBuy(1,accelerateCallback)
        end
        local cdTime=arenaVoApi:getCDTime()
        local costGold=arenaCfg.getGoldByTime(cdTime)

        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),accelerateNum,getlocal("dialog_title_prompt"),getlocal("arena_buyAccelerate",{costGold}),nil,self.layerNum+1)
        
    end
    local accelerateItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnCancleSmall.png",accelerate,nil,getlocal("accelerateBuild"),25)
    self.accelerateMenu=CCMenu:createWithItem(accelerateItem);
    self.accelerateMenu:setPosition(ccp(520,180))
    self.accelerateMenu:setTouchPriority((-(self.layerNum-1)*20-4));
    self.bgLayer:addChild(self.accelerateMenu)

    local cdSize =0
    local cdPos =0
    if G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() =="en" then
        cdSize= 5
        cdPos =30
    end
    self.cdLb = GetTTFLabel(getlocal("acCD"),textSize-cdSize);
    self.cdLb:setAnchorPoint(ccp(0.5,0.5));
    self.cdLb:setPosition(ccp(350+cdPos,200));
    self.bgLayer:addChild(self.cdLb,2);

    local cdTime=arenaVoApi:getCDTime()
    local timestr=G_getTimeStr(cdTime,1)
    self.cdTimeLb = GetTTFLabel(timestr,textSize);
    self.cdTimeLb:setAnchorPoint(ccp(0.5,0.5));
    self.cdTimeLb:setPosition(ccp(350+cdPos,160));
    self.bgLayer:addChild(self.cdTimeLb,2);
    

    self:judgeCd()

    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
    lineSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,230));
    self.bgLayer:addChild(lineSp,1)
    self:initTableView()
end

function arenaDialogTab1:judgeCd()
    if arenaVoApi:getCDTime()<=0 then
        self.cdLb:setVisible(false)
        self.cdTimeLb:setVisible(false)
        self.accelerateMenu:setVisible(false)
        self.addnumMenu:setVisible(true)

        if arenaVoApi:getArenaVo().attack_num-arenaVoApi:getArenaVo().attack_count<=0 then
            for k,v in pairs(self.itemTb) do
                v=tolua.cast(v,"CCMenuItem")
                v:setEnabled(false)
            end
        else
            for k,v in pairs(self.itemTb) do
                v=tolua.cast(v,"CCMenuItem")
                v:setEnabled(true)
            end
        end
        

    elseif arenaVoApi:getCDTime()>0 then
        self.cdLb:setVisible(true)
        self.cdTimeLb:setVisible(true)
        self.accelerateMenu:setVisible(true)
        local cdTime=arenaVoApi:getCDTime()
        local timestr=G_getTimeStr(cdTime,1)
        self.cdTimeLb:setString(timestr)
        self.addnumMenu:setVisible(false)
        for k,v in pairs(self.itemTb) do
            v=tolua.cast(v,"CCMenuItem")
            v:setEnabled(false)
        end
        

    end

end

function arenaDialogTab1:initTableView()
    self.attacklist=arenaVoApi:getAttacklist()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-40,self.bgLayer:getContentSize().height-550),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setAnchorPoint(ccp(0,0))
    self.tv:setPosition(ccp(30,230))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

    

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function arenaDialogTab1:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return SizeOfTable(self.attacklist)

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
       tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-40,self.normalHeight)

       return  tmpSize
   elseif fn=="tableCellAtIndex" then
       
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
        lineSp:setAnchorPoint(ccp(0,0.5));
        lineSp:setPosition(ccp(0,0));
        cell:addChild(lineSp,1)
        local size=25

        local lb1 = GetTTFLabel(self.attacklist[idx+1][1],size);
        lb1:setPosition(ccp(44,self.normalHeight/2));
        cell:addChild(lb1,2);

        local nameStr = self.attacklist[idx+1][3]
        if self.attacklist[idx+1][2]<=450 then
            nameStr=arenaVoApi:getNpcNameById(self.attacklist[idx+1][2])
        end

        local lb2 = GetTTFLabelWrap(nameStr,size,CCSizeMake(175,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        lb2:setPosition(ccp(165,self.normalHeight/2));
        cell:addChild(lb2,2);

        local lb3 = GetTTFLabel(self.attacklist[idx+1][4],size);
        lb3:setPosition(ccp(288,self.normalHeight/2));
        cell:addChild(lb3,2);

        local rewardNum = arenaCfg.getrewardcount(self.attacklist[idx+1][1])

        local reward=FormatItem(arenaCfg.rankRewardItemId)[1]
        reward.num=rewardNum
    
        local icon=G_getItemIcon(reward,50,true,self.layerNum+3,nil)
        icon:setPosition(ccp(375,self.normalHeight/2));
        icon:setTouchPriority(-(self.layerNum-1)*20-2)
        cell:addChild(icon,2);

        local lb4 = GetTTFLabel("×"..rewardNum,22);
        lb4:setPosition(ccp(icon:getPositionX()+icon:getContentSize().width*0.5+10,self.normalHeight/2));
        cell:addChild(lb4,2);


        local function fight()
            if G_checkClickEnable()==false then
                do
                    return
                end
            end
            if self.tv:getIsScrolled()==true then
                do
                    return
                end
            end

            if self:judgeTroops()==false then

                do
                    return
                end
            end

            local function callback(fn,data)
                local cresult,retTb=base:checkServerData(data)
                if cresult==true then
                    if retTb.data.reward~=nil then
                        local award=FormatItem(retTb.data.reward) or {}
                        for k,v in pairs(award) do
                            G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                        end
                    end
                    local reporttb=retTb.data.report
                    if retTb.data~=nil and reporttb~=nil and SizeOfTable(reporttb)>0 then
                        local dateTb={}
                        local dateTb1={}
                        dateTb.data=dateTb1
                        dateTb.data.report=reporttb
                        dateTb.isFuben=true
                        battleScene:initData(dateTb)
                        if dateTb.data.report.w~=nil and dateTb.data.report.w==1 then
                            local tarvictory = retTb.data.tarvictory
                            if tarvictory>=10 then

                                local message={key="arena_fightNumDesc8",param={dateTb.data.report.p[2][1],dateTb.data.report.p[1][1],tarvictory}}
                                chatVoApi:sendSystemMessage(message)   
                            end
                        end
                    else
                        local name=self.attacklist[idx+1][3]
                        local function onSure()
                            eventDispatcher:dispatchEvent("battle.close",{win=true})
                        end
                        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("arena_fightSurprise",{name}),nil,self.layerNum+1,nil,onSure)
          
                    end
                    
                    local function getcallback(fn,data)
                        if base:checkServerData(data)==true then
                            if self.attacklist[idx+1][1]==1 and arenaVoApi:getArenaVo().ranking==1 then
                                local name=self.attacklist[idx+1][3]
                                if tonumber(name)~=nil then
                                    name=arenaVoApi:getNpcNameById(tonumber(name))
                                end
                                local message={key="arena_fightNumDesc7",param={playerVoApi:getPlayerName(),name}}
                                chatVoApi:sendSystemMessage(message)
                            end
                            self.attacklist=arenaVoApi:getAttacklist()
                            self.itemTb={}
                            self.tv:reloadData()
                            for k,v in pairs(arenaCfg.noticeStreak) do
                                if arenaVoApi:getArenaVo().victory>arenaCfg.noticeStreak[4] then
                                    local num=arenaVoApi:getArenaVo().victory
                                    if num%100==0 then
                                        local message={key="arena_fightNumDesc6",param={playerVoApi:getPlayerName(),arenaVoApi:getArenaVo().victory}}
                                        chatVoApi:sendSystemMessage(message)
                                        break
                                    end
                                else
                                    if arenaVoApi:getArenaVo().victory==v then
                                        local keyFight="arena_fightNumDesc"..k
                                        local message={key=keyFight,param={playerVoApi:getPlayerName(),arenaVoApi:getArenaVo().victory}}
                                        chatVoApi:sendSystemMessage(message)
                                        break
                                    end
                                end
                            end
                            
                        end
                    end
                    socketHelper:militaryGet(getcallback)
                end
            end
            socketHelper:militaryBattle(self.attacklist[idx+1][1],callback)

        end

        local fightItem = GetButtonItem("IconAttackBtn.png","IconAttackBtn_Down.png","IconAttackBtn.png",fight,11,nil,nil)
        
        if self.attacklist[idx+1][3]==playerVoApi:getPlayerName() then
            fightItem:setEnabled(false)
            fightItem:setVisible(false)
        else
            self.itemTb[idx+1]=fightItem
        end
        local fightMenu = CCMenu:createWithItem(fightItem);
        fightMenu:setPosition(ccp(530,self.normalHeight/2));
        fightMenu:setTouchPriority(-(self.layerNum-1)*20-2);
        fightItem:setScale(0.9)
        cell:addChild(fightMenu,2);



        return cell

   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end



function arenaDialogTab1:tick()
    self.numExercisesLb=tolua.cast(self.numExercisesLb,"CCLabelTTF")
    self.numExercisesLb:setString(getlocal("arena_numExercises",{arenaVoApi:getArenaVo().attack_count}))
    self.numLeftLb=tolua.cast(self.numLeftLb,"CCLabelTTF")
    self.numLeftLb:setString(getlocal("arena_numLeft",{arenaVoApi:getArenaVo().attack_num-arenaVoApi:getArenaVo().attack_count}))
    self.straightTimesLb=tolua.cast(self.straightTimesLb,"CCLabelTTF")
    self.straightTimesLb:setString(getlocal("arena_straightTimes",{arenaVoApi:getArenaVo().victory}))
    self.rewardLb=tolua.cast(self.rewardLb,"CCLabelTTF")
    local rTimeStr = G_getTimeStr(arenaVoApi:getRewardTime())
    self.rewardLb:setString(getlocal("arena_nextAward",{rTimeStr}))
    self.prevRankingLb = tolua.cast(self.prevRankingLb,"CCLabelTTF")
    self.prevRankingLb:setString(getlocal("arena_prevRanking",{arenaVoApi:getArenaVo().ranked}))

    if arenaVoApi:getRewardTime()==0 then
        local function getcallback(fn,data)
            if base:checkServerData(data)==true then
                self.attacklist=arenaVoApi:getAttacklist()
                self.tv:reloadData()
            end
        end
        socketHelper:militaryGet(getcallback)
    end

    self:judgeCd()
    if arenaVoApi:isCanReward()==false then
        self.rewardItem:setEnabled(false)
    else
        self.rewardItem:setEnabled(true)
    end


    if self.fightRecordItem then
        local unreadNum=arenaReportVoApi:getUnreadNum()
        local temTabBtnItem=tolua.cast(self.fightRecordItem,"CCNode")
        local tipSp=temTabBtnItem:getChildByTag(10)
        if tipSp~=nil then
            if unreadNum and unreadNum>0 then
                tipSp:setVisible(true)
                local tipNumLabel=tolua.cast(tipSp:getChildByTag(11),"CCLabelTTF")
                tipNumLabel:setString(unreadNum)
                local iconWidth=36
                if tipNumLabel:getContentSize().width+10>iconWidth then
                    iconWidth=tipNumLabel:getContentSize().width+10
                end
                tipSp:setContentSize(CCSizeMake(iconWidth,36))
                tipNumLabel:setPosition(getCenterPoint(tipSp))
            else
                tipSp:setVisible(false)
            end
        end
    end

end

function arenaDialogTab1:judgeTroops()
    local isEableAttack=true
    local num=0;
    for k,v in pairs(tankVoApi:getTanksTbByType(5)) do
        if SizeOfTable(v)==0 then
            num=num+1;
        end
    end
    if num==6 then
        isEableAttack=false
    end
    if isEableAttack==false then

        local function setTroops()
            self.parent:tabClick(1)
        end 
        
        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),setTroops,getlocal("dialog_title_prompt"),getlocal("backstage10001"),nil,self.layerNum+1)
    end


    return isEableAttack
end

--用户处理特殊需求,没有可以不写此方法
function arenaDialogTab1:doUserHandler()

end

function arenaDialogTab1:dispose()
    
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil;
    self.layerNum=nil;
    
end