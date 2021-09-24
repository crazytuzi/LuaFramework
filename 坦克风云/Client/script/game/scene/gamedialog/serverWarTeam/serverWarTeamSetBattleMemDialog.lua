serverWarTeamSetBattleMemDialog=commonDialog:new()

function serverWarTeamSetBattleMemDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.applyBtn=nil
    self.setMemBtn=nil
    self.battleMemList={}
    self.leftTimeLb=nil
    self.allianceRole=0

    self.memNum=0

    return nc
end

function serverWarTeamSetBattleMemDialog:initTableView()
    local selfAlliance=allianceVoApi:getSelfAlliance()
    if selfAlliance then
        self.allianceRole=selfAlliance.role
    end
    self.memNum=serverWarTeamVoApi:getAllianceMemNum()
    -- self.battleMemList=G_clone(serverWarTeamVoApi:getMemList())
    self.battleMemList={}
    local memList=serverWarTeamVoApi:getMemList()
    if memList then
        for k,v in pairs(memList) do
            table.insert(self.battleMemList,tonumber(v))
        end
    end

    self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40, G_VisibleSizeHeight - 110))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 25))


    local heightSpace=-75
    local capInSet=CCRect(20, 20, 10, 10)
    local function touch()
    end
    local aNameBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",capInSet,touch)
    aNameBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50,70))
    aNameBg:ignoreAnchorPointForPosition(false)
    aNameBg:setAnchorPoint(ccp(0.5,1))
    aNameBg:setIsSallow(false)
    aNameBg:setTouchPriority(-(self.layerNum-1)*20-1)
    aNameBg:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-165-heightSpace)
    self.bgLayer:addChild(aNameBg,1)

    local battleNum=SizeOfTable(self.battleMemList)
    local maxNum=serverWarTeamVoApi:getNumberOfBattle()
    self.battleNumLb=GetTTFLabelWrap(getlocal("alliance_war_battle_num",{battleNum,maxNum}),25,CCSizeMake(aNameBg:getContentSize().width/2,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.battleNumLb:setAnchorPoint(ccp(0.5,0.5))
    self.battleNumLb:setPosition(ccp(aNameBg:getContentSize().width/2,aNameBg:getContentSize().height/2))
    -- self.battleNumLb:setColor(G_ColorGreen)
    aNameBg:addChild(self.battleNumLb)

    local bSpace=115
    local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,touch)
    backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, self.bgLayer:getContentSize().height-aNameBg:getContentSize().height-170-30-heightSpace-bSpace))
    backSprie:ignoreAnchorPointForPosition(false)
    backSprie:setAnchorPoint(ccp(0.5,0))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
    backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,30+bSpace))
    self.bgLayer:addChild(backSprie,1)


    local lbSize=22
    local lbHeight=backSprie:getContentSize().height-25
    local xSpace=0
    local rankLb=GetTTFLabel(getlocal("alliance_list_scene_rank"),lbSize)
    rankLb:setAnchorPoint(ccp(0.5,0.5))
    rankLb:setPosition(ccp(45-xSpace,lbHeight))
    rankLb:setColor(G_ColorGreen)
    backSprie:addChild(rankLb)
    
    local memberLb=GetTTFLabel(getlocal("alliance_scene_member_list"),lbSize)
    memberLb:setAnchorPoint(ccp(0.5,0.5))
    memberLb:setPosition(ccp(153-xSpace,lbHeight))
    memberLb:setColor(G_ColorGreen)
    backSprie:addChild(memberLb)

    
    local dutyLb=GetTTFLabel(getlocal("alliance_scene_member_duty"),lbSize)
    dutyLb:setAnchorPoint(ccp(0.5,0.5))
    dutyLb:setPosition(ccp(268-xSpace,lbHeight))
    dutyLb:setColor(G_ColorGreen)
    backSprie:addChild(dutyLb)

    local levelLb=GetTTFLabel(getlocal("RankScene_level"),lbSize)
    levelLb:setAnchorPoint(ccp(0.5,0.5))
    levelLb:setPosition(ccp(343-xSpace,lbHeight))
    levelLb:setColor(G_ColorGreen)
    backSprie:addChild(levelLb)
    
    local attackLb=GetTTFLabelWrap(getlocal("showAttackRank"),lbSize,CCSizeMake(80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    attackLb:setAnchorPoint(ccp(0.5,0.5))
    attackLb:setPosition(ccp(428-xSpace,lbHeight))
    attackLb:setColor(G_ColorGreen)
    backSprie:addChild(attackLb)
    
    local operatorLb=GetTTFLabel(getlocal("alliance_list_scene_operator"),lbSize)
    operatorLb:setAnchorPoint(ccp(0.5,0.5))
    operatorLb:setPosition(ccp(528-xSpace,lbHeight))
    operatorLb:setColor(G_ColorGreen)
    backSprie:addChild(operatorLb)


    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-50,backSprie:getContentSize().height-55),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(25,35+bSpace))
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)



    local function commitHandler(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        
        local function applyCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                serverWarTeamVoApi:setIsApply(1)

                if sData.data and sData.data.teams then
                    serverWarTeamVoApi:formatMemList(sData.data.teams)
                end
                local memList=serverWarTeamVoApi:getMemList()
                if memList then
                    self.battleMemList={}
                    for k,v in pairs(memList) do
                        table.insert(self.battleMemList,tonumber(v))
                    end
                end

                self:tick(true)

                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwarteam_signup_success"),30)

                local selfAlliance=allianceVoApi:getSelfAlliance()
                if selfAlliance then
                    local aid=selfAlliance.aid
                    local isApply=serverWarTeamVoApi:getIsApply()
                    local params={isApply,memList}
                    chatVoApi:sendUpdateMessage(13,params,aid+1)
                end
            end
        end
        socketHelper:acrossApply(2,applyCallback)
    end
    self.applyBtn = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",commitHandler,nil,getlocal("serverwarteam_apply"),28)
    -- self.applyBtn:setScale(0.6)
    local applyMenu=CCMenu:createWithItem(self.applyBtn)
    applyMenu:setPosition(ccp(G_VisibleSizeWidth/2,30+self.applyBtn:getContentSize().height/2))
    applyMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(applyMenu)


    local function setMemSureHandler(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        
        local function setCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                local lastTime=sData.ts
                serverWarTeamVoApi:setLastSetMemTime(lastTime)
                local isChange=false
                if sData.data and sData.data.teams then
                    self.battleMemList=sData.data.teams
                    isChange=true
                end
                serverWarTeamVoApi:formatMemList(self.battleMemList)
                local memList=serverWarTeamVoApi:getMemList()
                if memList then
                    self.battleMemList={}
                    for k,v in pairs(memList) do
                        table.insert(self.battleMemList,tonumber(v))
                    end
                end
                self:tick(true)
                if isChange==true then
                    smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("serverwarteam_battle_mem_change"),nil,self.layerNum+1)
                else
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwarteam_setting_member_success"),30)
                end
                local selfAlliance=allianceVoApi:getSelfAlliance()
                if selfAlliance then
                    local aid=selfAlliance.aid
                    local params={lastTime,memList}
                    chatVoApi:sendUpdateMessage(10,params,aid+1)
                end
            end
        end
        socketHelper:acrossSetteams(self.battleMemList,setCallback)
    end

    local function setMemHandler(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local menNum=SizeOfTable(self.battleMemList)
        local maxNum=serverWarTeamVoApi:getNumberOfBattle()
        if menNum>maxNum then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("alliance_war_battle_full"),nil,self.layerNum+1)
            do return end
        end
        -- if menNum<=0 then
        --     smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("serverwarteam_empty_sign_up"),nil,self.layerNum+1)
        --     do return end
        -- end

        local descStr=""
        if menNum==0 then 
            descStr=getlocal("serverwarteam_empty_sign_up")
        elseif menNum>0 and menNum<maxNum then
            descStr=getlocal("serverwarteam_not_full_sign_up").."\n"..getlocal("serverwarteam_sign_up_note",{math.ceil(serverWarTeamCfg.setTroopsLimit/60)})
        elseif menNum==maxNum then
            descStr=getlocal("serverwarteam_full_sign_up").."\n"..getlocal("serverwarteam_sign_up_note",{math.ceil(serverWarTeamCfg.setTroopsLimit/60)})
        end
        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),setMemSureHandler,getlocal("dialog_title_prompt"),descStr,nil,self.layerNum+1)
    end
    local strSize2 = 20
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =24
    end
    self.setMemBtn = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",setMemHandler,nil,getlocal("serverwarteam_set_mem"),strSize2)
    local setMemMenu=CCMenu:createWithItem(self.setMemBtn)
    setMemMenu:setPosition(ccp(G_VisibleSizeWidth/2,30+self.applyBtn:getContentSize().height/2))
    setMemMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(setMemMenu)


    self.leftTimeLb=GetTTFLabel("0",25)
    self.leftTimeLb:setAnchorPoint(ccp(0.5,0))
    self.leftTimeLb:setPosition(ccp(G_VisibleSizeWidth/2,110))
    self.bgLayer:addChild(self.leftTimeLb,3)
    self.leftTimeLb:setColor(G_ColorYellowPro)
    self.leftTimeLb:setVisible(false)

    self:tick(true)

    if serverWarTeamVoApi:getIsMemChange()==1 then
        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("serverwarteam_battle_mem_change"),nil,self.layerNum+1)
        serverWarTeamVoApi:setIsMemChange(-1)
    end
end

function serverWarTeamSetBattleMemDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local memNum=self.memNum
        return memNum
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-50,70)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local memList=serverWarTeamVoApi:getAllianceMemList(self.battleMemList)
        local member=memList[idx+1]
        local memuid=tonumber(member.uid)
        local isBattle=member.isBattle
        local joinTime=member.joinTime

        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd,fn,idx)
            --return self:cellClick(idx)
        end

        -- if idx==0 then
        --     local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
        --     lineSp:setAnchorPoint(ccp(0,0.5));
        --     lineSp:setPosition(ccp(0,70));
        --     cell:addChild(lineSp,1)
        -- end

        -- self.memberCellTb[idx+1]=cell
        local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
        lineSp:setAnchorPoint(ccp(0,0.5));
        lineSp:setPosition(ccp(0,0));
        cell:addChild(lineSp,1)

        local lbSize=25
        local lbHeight=35
        local lbWidth=30
        local lbColor=G_ColorWhite
        -- local loginTime=tonumber(self.tableMemberTb1[idx+1].logined_at)
        -- if  tonumber(base.serverTime)-loginTime>24*60*60*7 then
        --     lbColor=G_ColorGray
        -- end

        local rankLb=GetTTFLabel(idx+1,lbSize)
        rankLb:setPosition(ccp(72-lbWidth,lbHeight))
        cell:addChild(rankLb)
        rankLb:setColor(lbColor)

        
        local memberLb=GetTTFLabel(member.name,lbSize)
        memberLb:setPosition(ccp(183-lbWidth,lbHeight))
        cell:addChild(memberLb)
        memberLb:setColor(lbColor)
        
        local roleSp=nil
        local roleNum=tonumber(member.role)
        if roleNum==0 then
            roleSp=CCSprite:createWithSpriteFrameName("soldierIcon.png");
        elseif roleNum==1 then
            roleSp=CCSprite:createWithSpriteFrameName("deputyHead.png");
        elseif roleNum==2 then
            roleSp=CCSprite:createWithSpriteFrameName("positiveHead.png");
        end
        roleSp:setPosition(ccp(300-lbWidth,lbHeight))
        cell:addChild(roleSp)
        roleSp:setTag(101)

        local levelLb=GetTTFLabel(member.level,lbSize)
        levelLb:setPosition(ccp(372-lbWidth,lbHeight))
        cell:addChild(levelLb)
        levelLb:setTag(102)
        levelLb:setColor(lbColor)
        
        local attackLb=GetTTFLabel(FormatNumber(member.fight),lbSize)
        attackLb:setPosition(ccp(458-lbWidth,lbHeight))
        cell:addChild(attackLb)
        attackLb:setTag(103)
        attackLb:setColor(lbColor)
        
        local function checkMember(tag,object)
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)

                local memList=serverWarTeamVoApi:getAllianceMemList(self.battleMemList)
                local member=memList[idx+1]
                local memuid=tonumber(member.uid)
                local isBattle=member.isBattle
                local joinTime=member.joinTime
                if allianceVoApi:isHasAlliance()==true then
                else
                    do return end
                end

                if isBattle==1 then
                    for k,v in pairs(self.battleMemList) do
                        if tonumber(v)==tonumber(memuid) then
                            table.remove(self.battleMemList,k)
                        end
                    end
                else
                    local menNum=SizeOfTable(self.battleMemList)
                    local maxNum=serverWarTeamVoApi:getNumberOfBattle()
                    if menNum>=maxNum then
                        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("alliance_war_battle_full"),nil,self.layerNum+1)
                        do return end
                    end
                    if serverWarTeamVoApi:canJoinServerWarTeam(joinTime)==false then
                        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("serverwarteam_cannot_go_battle"),nil,self.layerNum+1)
                        do return end
                    end
                    local isHas=false
                    for k,v in pairs(self.battleMemList) do
                        if tonumber(v)==tonumber(memuid) then
                            isHas=true
                        end
                    end
                    if isHas==false then
                        table.insert(self.battleMemList,memuid)
                    end
                end

                self:doUserHandler()

            end
        end
        local checkItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",checkMember,idx+1,getlocal("alliance_war_battle_btn"),28,idx+1001)
        checkItem:setScale(0.6)
        local checkMenu=CCMenu:createWithItem(checkItem);
        checkMenu:setPosition(ccp(G_VisibleSizeWidth-checkItem:getContentSize().width/2-30,lbHeight))
        checkMenu:setTouchPriority(-(self.layerNum-1)*20-2);
        cell:addChild(checkMenu)

        if isBattle==1 then
            tolua.cast(checkItem:getChildByTag(idx+1001),"CCLabelTTF"):setString(getlocal("alliance_war_standby_btn"))
        else
            tolua.cast(checkItem:getChildByTag(idx+1001),"CCLabelTTF"):setString(getlocal("alliance_war_battle_btn"))
        end

        local memNum=SizeOfTable(self.battleMemList)
        if memNum>=serverWarTeamVoApi:getNumberOfBattle() then
            if isBattle~=1 then
                checkItem:setEnabled(false)
            end
        end
        if serverWarTeamVoApi:canSetOrApply()~=2 then
            checkItem:setEnabled(false)
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

function serverWarTeamSetBattleMemDialog:tick(isUpdate)
    if self then
        local selfAlliance=allianceVoApi:getSelfAlliance()
        if selfAlliance then
            if self.allianceRole~=selfAlliance.role then
                self.allianceRole=selfAlliance.role
                isUpdate=true
            end
        end
        local flag=serverWarTeamVoApi:getMemFlag()
        if flag==0 or isUpdate==true then
            if flag==0 then
                self.battleMemList={}
                local memList=serverWarTeamVoApi:getMemList()
                if memList then
                    for k,v in pairs(memList) do
                        table.insert(self.battleMemList,tonumber(v))
                    end
                end
                serverWarTeamVoApi:setMemFlag(1)
            end
            self:doUserHandler()
        end

        if self.setMemBtn and self.applyBtn then
            local state=serverWarTeamVoApi:canSetOrApply()
            if state==3 then
                self.setMemBtn:setEnabled(false)
                self.setMemBtn:setVisible(true)
                self.applyBtn:setEnabled(false)
                self.applyBtn:setVisible(false)
            elseif state==2 then
                self.setMemBtn:setEnabled(true)
                self.setMemBtn:setVisible(true)
                self.applyBtn:setEnabled(false)
                self.applyBtn:setVisible(false)

                local lastTime=serverWarTeamVoApi:getLastSetMemTime()
                local leftTime=serverWarTeamCfg.settingBattleMemLimit-(base.serverTime-lastTime)
                if leftTime>0 then
                    if self.setMemBtn and self.setMemBtn:isEnabled()==true then
                        self.setMemBtn:setEnabled(false)
                    end
                    if self.leftTimeLb then
                        self.leftTimeLb:setVisible(true)
                        self.leftTimeLb:setString(GetTimeForItemStr(leftTime))
                    end
                else
                    if self.leftTimeLb then
                        self.leftTimeLb:setVisible(false)
                    end
                end
            elseif state==1 then
                self.setMemBtn:setEnabled(false)
                self.setMemBtn:setVisible(false)
                self.applyBtn:setEnabled(true)
                self.applyBtn:setVisible(true)
            else
                self.setMemBtn:setEnabled(false)
                self.setMemBtn:setVisible(false)
                self.applyBtn:setEnabled(false)
                self.applyBtn:setVisible(false)
            end
        end

    end
end

--用户处理特殊需求,没有可以不写此方法
function serverWarTeamSetBattleMemDialog:doUserHandler()
    if self then
        if self.tv then
            self.memNum=serverWarTeamVoApi:getAllianceMemNum()
            local recordPoint = self.tv:getRecordPoint()
            self.tv:reloadData()
            if recordPoint.y<=0 then
                self.tv:recoverToRecordPoint(recordPoint)
            end
        end

        local maxNum=serverWarTeamVoApi:getNumberOfBattle()
        local battleNum=SizeOfTable(self.battleMemList)
        if self.battleNumLb then
            self.battleNumLb:setString(getlocal("alliance_war_battle_num",{battleNum,maxNum}))
        end
    end
end

function serverWarTeamSetBattleMemDialog:dispose()
    self.leftTimeLb=nil
    self.applyBtn=nil
    self.setMemBtn=nil
    self.battleMemList=nil
    self.battleMemList={}
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.layerNum=nil
    self.allianceRole=0
    self.memNum=0
end