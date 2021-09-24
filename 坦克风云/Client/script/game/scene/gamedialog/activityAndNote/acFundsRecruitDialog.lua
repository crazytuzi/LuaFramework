acFundsRecruitDialog=commonDialog:new()

function acFundsRecruitDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.layerNum=layerNum

    self.cellHeight=nil
    self.normalHeight=170
    return nc
end

function acFundsRecruitDialog:initTableView()
    if G_isIphone5() then
        self.normalHeight=210
    end
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
    self.panelLineBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,G_VisibleSize.height-95))
    local vo = acFundsRecruitVoApi:getAcVo()
    if allianceVoApi:isHasAlliance()==true then
        if vo.ls==nil or (vo.ls~=nil and (G_getWeeTs(base.serverTime)>vo.ls["lg"][3])) then
            local function updateCallback(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    vo:updateFundsRecruitData(sData.data)
                    self:initTableView1()
                end
            end 
            socketHelper:activeFundsRecruit("updateTime",updateCallback)
        else
            self:initTableView1()
        end
    else
        self:initTableView2()
    end
end

function acFundsRecruitDialog:initTableView1()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-40,G_VisibleSizeHeight-490),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,5))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(120)

    local characterSp
    if platCfg.platCfgChangeGuideUI[G_curPlatName()] then
        characterSp = CCSprite:create("public/guide.png")
    else
        characterSp = CCSprite:createWithSpriteFrameName("GuideCharacter.png") --姑娘
    end
    characterSp:setAnchorPoint(ccp(0,0))
    characterSp:setPosition(ccp(10,self.normalHeight*3+20))
    self.bgLayer:addChild(characterSp,5)
    
    local function touch()
    end
    local capInSet = CCRect(20, 20, 10, 10)
    self.descBg =LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",capInSet,touch)
    self.descBg:setContentSize(CCSizeMake(420,220))
    self.descBg:setAnchorPoint(ccp(0,1))
    self.descBg:setPosition(ccp(220-40,self.bgLayer:getContentSize().height-240))
    self.bgLayer:addChild(self.descBg,1)
    local function descCallBack(...)
       return self:eventHandler1(...)
    end
    local deschd= LuaEventHandler:createHandler(descCallBack)
    self.tv1=LuaCCTableView:createWithEventHandler(deschd,CCSizeMake(350,200),nil)
    self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv1:setPosition(ccp(75,10))
    self.descBg:addChild(self.tv1,1)
    self.tv1:setMaxDisToBottomOrTop(50)
    
    local function touch()
        local td=smallDialog:new()
        local str1=getlocal("activity_fundsRecruit_desc1");
        local str2=getlocal("activity_fundsRecruit_desc2");
        local str3=getlocal("activity_fundsRecruit_desc3");
        tabStr={" ",str3,str2,str1," "}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28)
        sceneGame:addChild(dialog,self.layerNum+1)
    end

    local menuItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,11,nil,nil)
    local menu = CCMenu:createWithItem(menuItem);
    menu:setPosition(ccp(580,self.bgLayer:getContentSize().height-140));
    menu:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(menu,5);
    
    local actTime=GetTTFLabel(getlocal("activity_timeLabel"),30)
    actTime:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-105))
    self.bgLayer:addChild(actTime,5);
    actTime:setColor(G_ColorGreen)

    local acVo = acFundsRecruitVoApi:getAcVo()
    if acVo ~= nil then
        local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
        local timeLabel=GetTTFLabel(timeStr,26)
        --timeLabel:setAnchorPoint(ccp(0,0))
        timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height-140))
        self.bgLayer:addChild(timeLabel)
    end
end

function acFundsRecruitDialog:initTableView2()
    local function callBack(...)
       return self:eventHandler2(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-40,G_VisibleSizeHeight-500),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(15,95))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(120)


    local function descCallBack(...)
       return self:eventHandler3(...)
    end
    local descHd= LuaEventHandler:createHandler(descCallBack)
    self.tv1=LuaCCTableView:createWithEventHandler(descHd,CCSizeMake(self.bgLayer:getContentSize().width-150,200),nil)
    self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv1:setPosition(ccp(25,G_VisibleSizeHeight-360))
    self.bgLayer:addChild(self.tv1,1)
    self.tv1:setMaxDisToBottomOrTop(40)

    local acVo = acFundsRecruitVoApi:getAcVo()
    if acVo ~= nil then
        local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
        local timeLabel=GetTTFLabel(timeStr,26)
        --timeLabel:setAnchorPoint(ccp(0,0))
        timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height-120))
        self.bgLayer:addChild(timeLabel)
    end

    local function touch()
        local td=smallDialog:new()
        local str1=getlocal("activity_fundsRecruit_desc1");
        local str2=getlocal("activity_fundsRecruit_desc2");
        local str3=getlocal("activity_fundsRecruit_desc3");
        tabStr={" ",str3,str2,str1," "}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28)
        sceneGame:addChild(dialog,self.layerNum+1)
    end

    local menuItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,11,nil,nil)
    local menu = CCMenu:createWithItem(menuItem);
    menu:setPosition(ccp(580,self.bgLayer:getContentSize().height-140));
    menu:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(menu,5);

    local function joinHandler( ... )
        if G_checkClickEnable()==false then
                        do
                            return
                        end
                    end
        if allianceVoApi:isHasAlliance()==true then
            PlayEffect(audioCfg.mouseClick)
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("backstage8001"),nil,5)
            self:close()
            do
                return
            end
        end 
        if base.isAllianceSwitch==0 then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("alliance_willOpen"),nil,5)
            do
                return
            end
        end 

        local buildVo=buildingVoApi:getBuildingVoByBtype(15)[1]--军团建筑
        if buildVo == nil or buildVo.status > 0  then
            -- 军团等级不足
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("activity_fbReward_lvLowTip"),nil,self.layerNum + 1)
            do
                return
            end
        end
        activityAndNoteDialog:gotoAlliance(false)
    end

    local joinAllianceBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",joinHandler,nil,getlocal("alliance_email_title3"),25)
    local joinMenu = CCMenu:createWithItem(joinAllianceBtn)
    joinMenu:setAnchorPoint(ccp(0.5,0))
    joinMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,55))
    joinMenu:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(joinMenu,1)


end

function acFundsRecruitDialog:eventHandler1(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        local descLabel=GetTTFLabelWrap(getlocal("activity_fundsRecruit_tab1_desc2"),25,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        if self.cellHeight==nil then
            self.cellHeight=descLabel:getContentSize().height+25
        end 
        if self.cellHeight <200 then
            self.cellHeight = 200
        end
        tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-40,self.cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        
        local descLabel=GetTTFLabelWrap(getlocal("activity_fundsRecruit_tab1_desc2"),25,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        if self.cellHeight==nil then
            self.cellHeight=descLabel:getContentSize().height+25
        end 
        if self.cellHeight <200 then
            self.cellHeight = 200
        end
        descLabel:setAnchorPoint(ccp(0,0.5))
        descLabel:setPosition(ccp(0,self.cellHeight/2))
        cell:addChild(descLabel,1)
        descLabel:setColor(G_ColorGreen)

    
        return cell

    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function acFundsRecruitDialog:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return 3
  elseif fn=="tableCellSizeForIndex" then
    local tmpSize
       tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-30,self.normalHeight)
    return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()

    cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40, self.normalHeight))
        
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd,fn,idx)
        
        end
        local txtSize = 25
        if G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="in" or G_getCurChoseLanguage()=="en" or G_getCurChoseLanguage()=="ru" or G_getCurChoseLanguage()=="pt" then
            txtSize = 20
        end
        local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,cellClick)
        headerSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40, self.normalHeight-4))
        headerSprie:ignoreAnchorPointForPosition(false);
        headerSprie:setAnchorPoint(ccp(0,0));
        headerSprie:setTag(1000+idx)
        headerSprie:setIsSallow(false)
        headerSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        headerSprie:setPosition(ccp(0,cell:getContentSize().height-headerSprie:getContentSize().height));
        cell:addChild(headerSprie)
        local iconName
        local titleName
        local descStr
        local rewardStr
        local needNum

        local function rewardHandler( ... )
            -- body
            if G_checkClickEnable()==false then
                        do
                            return
                        end
                    end
            if allianceVoApi:isHasAlliance()==false then
                PlayEffect(audioCfg.mouseClick)
                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("noAlliance"),nil,self.layerNum+1)
                self:close()
                do 
                    return
                end
            end
            if idx==0 then
                if acFundsRecruitVoApi:isGotOnlineRewards()==false then
                    local function rewardCallback(fn,data)
                        local ret,sData=base:checkServerData(data)
                        if ret==true then
                            local point = allianceVoApi:getSelfAlliance().point+acFundsRecruitVoApi:getAlliancePointRewardCfg(idx+1)
                            local updateData={point=point}
                            allianceVoApi:formatSelfAllianceData(updateData)
                            local rewardStr = getlocal("daily_lotto_tip_10")..getlocal("alliance_funds").."x"..acFundsRecruitVoApi:getAlliancePointRewardCfg(idx+1)

                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),rewardStr,28)
                            acFundsRecruitVoApi:updateData(sData.data)
                            self.tv:reloadData()
                        end
                    end 
                    socketHelper:activeFundsRecruit("login",rewardCallback)
                end

            elseif idx==1 then
                if acFundsRecruitVoApi:getResourceDonateCount()<acFundsRecruitVoApi:getAllianceDonateNumCfg() then
                    PlayEffect(audioCfg.mouseClick)
                    activityAndNoteDialog:closeAllDialog()
                    local td=allianceSkillDialog:new(self.layerNum+1)
                    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("alliance_technology"),true,self.layerNum+1)
                    sceneGame:addChild(dialog,3)
                    do 
                        return
                    end
                end

                if acFundsRecruitVoApi:iscanGetResourceDonateRewards() then
                    local function rewardCallback(fn,data)
                        local ret,sData=base:checkServerData(data)
                        if ret==true then
                            local point = allianceVoApi:getSelfAlliance().point+acFundsRecruitVoApi:getAlliancePointRewardCfg(idx+1)
                            local updateData={point=point}
                            allianceVoApi:formatSelfAllianceData(updateData)
                            local rewardStr = getlocal("daily_lotto_tip_10")..getlocal("alliance_funds").."x"..acFundsRecruitVoApi:getAlliancePointRewardCfg(idx+1)

                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),rewardStr,28)
                            
                            acFundsRecruitVoApi:updateData(sData.data)
                            self.tv:reloadData()
                        end
                        
                    end 
                    socketHelper:activeFundsRecruit("goods",rewardCallback)
                end
            elseif idx==2 then
                if acFundsRecruitVoApi:getGoldDonateCount()<acFundsRecruitVoApi:getGoldsDonateNumCfg() then
                    PlayEffect(audioCfg.mouseClick)
                    activityAndNoteDialog:closeAllDialog()
                    local td=allianceSkillDialog:new(self.layerNum+1)
                    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("alliance_technology"),true,self.layerNum+1)
                    sceneGame:addChild(dialog,3)
                    
                    do 
                        return
                    end
                end
                if acFundsRecruitVoApi:iscanGetGoldDonateRewards() then
                    local function rewardCallback(fn,data)
                        local ret,sData=base:checkServerData(data)
                        if ret==true then
                            local point = allianceVoApi:getSelfAlliance().point+acFundsRecruitVoApi:getAlliancePointRewardCfg(idx+1)
                            local updateData={point=point}
                            allianceVoApi:formatSelfAllianceData(updateData)
                            local rewardStr = getlocal("daily_lotto_tip_10")..getlocal("alliance_funds").."x"..acFundsRecruitVoApi:getAlliancePointRewardCfg(idx+1)

                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),rewardStr,28)
                            
                            acFundsRecruitVoApi:updateData(sData.data)
                            self.tv:reloadData()

                        end
                        
                    end 
                    socketHelper:activeFundsRecruit("gems",rewardCallback)
                end

            end
        end 

        local rewardBtn
        if idx==0 then
            iconName="item_baoxiang_04.png"
            titleName="activity_fundsRecruit_title1"
            needNum="("..getlocal("scheduleChapter",{getlocal("activity_fundsRecruit_time",{acFundsRecruitVoApi:getAllianceOnline()}),getlocal("activity_fundsRecruit_time",{acFundsRecruitVoApi:getOnlineTimeCfg()})})..")"
            descStr=getlocal("activity_fundsRecruit_onlineTime",{acFundsRecruitVoApi:getOnlineTimeCfg()/60})
            rewardStr=getlocal("activity_fundsRecruit_rewardAlliancePoint",{acFundsRecruitVoApi:getAlliancePointRewardCfg(1)})

            if acFundsRecruitVoApi:isGotOnlineRewards() ==true then
                rewardBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",rewardHandler,nil,getlocal("activity_hadReward"),25)
                rewardBtn:setEnabled(false)
            else
                rewardBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",rewardHandler,nil,getlocal("daily_scene_get"),25)
            end

        elseif idx==1 then

            iconName="item_baoxiang_07.png"
            titleName="activity_fundsRecruit_title2"
            needNum="("..getlocal("scheduleChapter",{acFundsRecruitVoApi:getResourceDonateCount(),acFundsRecruitVoApi:getAllianceDonateNumCfg()})..")"
            descStr=getlocal("activity_fundsRecruit_resourceDonateNum",{acFundsRecruitVoApi:getAllianceDonateNumCfg()})
            rewardStr=getlocal("activity_fundsRecruit_rewardAlliancePoint",{acFundsRecruitVoApi:getAlliancePointRewardCfg(2)})
            if acFundsRecruitVoApi:isGotResourceDonateRewards() ==true then
                    rewardBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",rewardHandler,nil,getlocal("activity_hadReward"),25)
                    rewardBtn:setEnabled(false)
            else
                if acFundsRecruitVoApi:getResourceDonateCount()<acFundsRecruitVoApi:getAllianceDonateNumCfg() then
                    rewardBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",rewardHandler,nil,getlocal("activity_heartOfIron_goto"),25)
                else
                    rewardBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",rewardHandler,nil,getlocal("daily_scene_get"),25)
                end
            end
        elseif idx==2 then
            iconName="item_baoxiang_05.png"
            titleName="activity_fundsRecruit_title3"
            needNum="("..getlocal("scheduleChapter",{acFundsRecruitVoApi:getGoldDonateCount(),acFundsRecruitVoApi:getGoldsDonateNumCfg()})..")"
            descStr=getlocal("activity_fundsRecruit_goldsDonateNum",{acFundsRecruitVoApi:getGoldsDonateNumCfg()})
            rewardStr=getlocal("activity_fundsRecruit_rewardAlliancePoint",{acFundsRecruitVoApi:getAlliancePointRewardCfg(3)})
           if acFundsRecruitVoApi:isGotGoldDonateRewards() ==true then
                    rewardBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",rewardHandler,nil,getlocal("activity_hadReward"),25)
                    rewardBtn:setEnabled(false)
            else
                if acFundsRecruitVoApi:getGoldDonateCount()<acFundsRecruitVoApi:getGoldsDonateNumCfg() then
                    rewardBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",rewardHandler,nil,getlocal("activity_heartOfIron_goto"),25)
                else
                    rewardBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",rewardHandler,nil,getlocal("daily_scene_get"),25)
                end
            end
        end


        local rewardMenu=CCMenu:createWithItem(rewardBtn)
        rewardMenu:setAnchorPoint(ccp(0.5,0.5))
        rewardMenu:setPosition(ccp(headerSprie:getContentSize().width - 90,headerSprie:getContentSize().height/2-15))
        rewardMenu:setTouchPriority(-(self.layerNum-1)*20-4)
        rewardMenu:setVisible(true)
        if idx==0 then
            if acFundsRecruitVoApi:isGotOnlineRewards()==false and acFundsRecruitVoApi:getAllianceOnline()<acFundsRecruitVoApi:getOnlineTimeCfg() then
                rewardMenu:setVisible(false)
            end
        end
        headerSprie:addChild(rewardMenu)

        local mIcon=CCSprite:createWithSpriteFrameName(iconName)
        mIcon:setAnchorPoint(ccp(0,0.5));
        mIcon:setPosition(ccp(20,headerSprie:getContentSize().height/2-15))
        headerSprie:addChild(mIcon)
           
        local titleLb=GetTTFLabel(getlocal(titleName),30)
        titleLb:setAnchorPoint(ccp(0,0.5));
        titleLb:setPosition(ccp(20,mIcon:getPositionY()+mIcon:getContentSize().height/2+30))
        headerSprie:addChild(titleLb,5);
        titleLb:setColor(G_ColorGreen)

        local needLb=GetTTFLabel(needNum,30)
        needLb:setAnchorPoint(ccp(0,0.5));
        needLb:setPosition(ccp(20+titleLb:getContentSize().width,mIcon:getPositionY()+mIcon:getContentSize().height/2+30))
        headerSprie:addChild(needLb,5);

        local descLabel=GetTTFLabelWrap(descStr,25,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        descLabel:setAnchorPoint(ccp(0,0.5));--
        descLabel:setPosition(ccp(mIcon:getPositionX()+mIcon:getContentSize().width+20,headerSprie:getContentSize().height/2+20))
        headerSprie:addChild(descLabel,5)

        local rewardLabel=GetTTFLabelWrap(rewardStr,25,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        rewardLabel:setAnchorPoint(ccp(0,0.5));
        rewardLabel:setPosition(ccp(mIcon:getPositionX()+mIcon:getContentSize().width+20,40))--
        rewardLabel:setColor(G_ColorYellow)
        headerSprie:addChild(rewardLabel,5)

    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
   
  end
end


function acFundsRecruitDialog:eventHandler2(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 4
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-40,120)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local function cellClick(hd,fn,idx)
            
        end
        local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
        backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, 120 - 4))
        backSprie:setAnchorPoint(ccp(0,0))
        backSprie:setPosition(ccp(10,4))
        cell:addChild(backSprie,1)
        local function iconClick( ... )
            
        end
        local iconName
        if idx==0 then
            iconName="Icon_ke_yan_zhong_xin.png"
        elseif idx==1 then
            iconName="mainBtnCheckpoint_Down.png"
        elseif idx==2 then
            iconName="mainBtnFireware.png"
        elseif idx==3 then
            iconName="Icon_novicePacks.png"
        end
        local iconSp
        if idx==1 or idx==2 then
             iconSp =CCSprite:createWithSpriteFrameName("Icon_BG.png")
             iconSp:setAnchorPoint(ccp(0,0.5))
             iconSp:setScale(100/78)
             iconSp:setPosition(ccp(20,backSprie:getContentSize().height/2))
             backSprie:addChild(iconSp,1)

             local mIcon2=CCSprite:createWithSpriteFrameName(iconName)
             mIcon2:setScale(78/100)
             mIcon2:setPosition(ccp(iconSp:getContentSize().width/2,iconSp:getContentSize().height/2))
             iconSp:addChild(mIcon2,2)
       else
            iconSp=CCSprite:createWithSpriteFrameName(iconName)
            iconSp:setAnchorPoint(ccp(0,0.5))
            iconSp:setPosition(20,backSprie:getContentSize().height/2)
            backSprie:addChild(iconSp,1)
        end
        local desc= GetTTFLabelWrap(getlocal("activity_fundsRecruit_allianceDesc"..(idx+1)),25,CCSizeMake(backSprie:getContentSize().width-140,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        desc:setAnchorPoint(ccp(0,0.5))
        desc:setPosition(ccp(130,backSprie:getContentSize().height/2))
        desc:setColor(G_ColorYellow)
        backSprie:addChild(desc,1)

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function acFundsRecruitDialog:eventHandler3(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 3
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        local descLabel=GetTTFLabelWrap(getlocal("activity_fundsRecruit_tab1_desc"..(idx+1)),25,CCSizeMake(self.bgLayer:getContentSize().width-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        if self.cellHeight==nil then
            self.cellHeight=descLabel:getContentSize().height+10
        end 
        tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-40,self.cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        
        local descLabel=GetTTFLabelWrap(getlocal("activity_fundsRecruit_tab1_desc"..(idx+1)),25,CCSizeMake(self.bgLayer:getContentSize().width-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        if self.cellHeight==nil then
            self.cellHeight=descLabel:getContentSize().height+10
        end 
        descLabel:setAnchorPoint(ccp(0,1))
        descLabel:setPosition(ccp(0,self.cellHeight))
        cell:addChild(descLabel,1)
        descLabel:setColor(G_ColorYellow)

    
        return cell

    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function acFundsRecruitDialog:tick()

    local time = acFundsRecruitVoApi:getAllianceOnline()
    if self.ongLineTime==nil then
        self.ongLineTime = time
    end
    if time~=self.ongLineTime and self.tv~=nil then
        print("acFundsRecruitDialog_reloadData")
        self.ongLineTime = time
        self.tv:reloadData()
    end
        
end

function acFundsRecruitDialog:dispose()
    self.normalHeight=nil
    self.cellHeight=nil
    self.bgLayer=nil
    self.layerNum=nil
    

end

