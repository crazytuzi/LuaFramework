allianceWarTab2Dialog={

}

function allianceWarTab2Dialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.layerNum=layerNum
    self.bgLayer=nil
    self.parentDialog=nil
   
    return nc
end



function allianceWarTab2Dialog:init(layerNum,parentDialog)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parentDialog=parentDialog

    local selfAlliance=allianceVoApi:getSelfAlliance()
    if selfAlliance then
        local aid=selfAlliance.aid
        local function allianceGetqueueCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                allianceWarVoApi:clearMemList()
                allianceWarVoApi:formatMemList(sData.data)
                self:initTabLayer()
            end
        end
        socketHelper:allianceGetqueue(aid,allianceGetqueueCallback)
    end
    return self.bgLayer
end

function allianceWarTab2Dialog:initTabLayer()
    local heightSpace=78
    local capInSet=CCRect(20, 20, 10, 10)
    local function touch()
    end
    local aNameBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",capInSet,touch)
    aNameBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50,140))
    aNameBg:ignoreAnchorPointForPosition(false)
    aNameBg:setAnchorPoint(ccp(0.5,1))
    aNameBg:setIsSallow(false)
    aNameBg:setTouchPriority(-(self.layerNum-1)*20-1)
    aNameBg:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-165-heightSpace)
    self.bgLayer:addChild(aNameBg,1)

    local selfAlliance=allianceVoApi:getSelfAlliance()
    local battleNum,readyNum=allianceWarVoApi:getBattleMemNum()

    -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    -- self.aNameLb=GetTTFLabelWrap(str,25,CCSizeMake(aNameBg:getContentSize().width-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    local aNameStr
    if allianceWarRecordVoApi:isRed()==true then
        aNameStr=getlocal("alliance_war_red",{selfAlliance.name})
    else
        aNameStr=getlocal("alliance_war_blue",{selfAlliance.name})
    end
    self.aNameLb=GetTTFLabelWrap(aNameStr,25,CCSizeMake(aNameBg:getContentSize().width-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.aNameLb:setAnchorPoint(ccp(0.5,0.5))
    self.aNameLb:setPosition(ccp(aNameBg:getContentSize().width/2,aNameBg:getContentSize().height-40))
    -- self.aNameLb:setColor(G_ColorGreen)
    aNameBg:addChild(self.aNameLb)

    local maxNum=allianceWarCfg.numberOfBattle
    -- local battleNumBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",capInSet,touch)
    -- battleNumBg:setContentSize(CCSizeMake((self.bgLayer:getContentSize().width-52)/2, 65))
    -- battleNumBg:ignoreAnchorPointForPosition(false)
    -- battleNumBg:setAnchorPoint(ccp(1,1))
    -- battleNumBg:setIsSallow(false)
    -- battleNumBg:setTouchPriority(-(self.layerNum-1)*20-1)
    -- battleNumBg:setPosition(self.bgLayer:getContentSize().width/2-2,self.bgLayer:getContentSize().height-aNameBg:getContentSize().height-168-heightSpace)
    -- self.bgLayer:addChild(battleNumBg,1)

    -- str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    -- self.battleNumLb=GetTTFLabelWrap(str,25,CCSizeMake(aNameBg:getContentSize().width/2,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.battleNumLb=GetTTFLabelWrap(getlocal("alliance_war_battle_num",{battleNum,maxNum}),25,CCSizeMake(aNameBg:getContentSize().width/2,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.battleNumLb:setAnchorPoint(ccp(0.5,0.5))
    self.battleNumLb:setPosition(ccp(aNameBg:getContentSize().width/4,40))
    -- self.battleNumLb:setColor(G_ColorGreen)
    aNameBg:addChild(self.battleNumLb)

    -- local standbyNumBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",capInSet,touch)
    -- standbyNumBg:setContentSize(CCSizeMake((self.bgLayer:getContentSize().width-52)/2, 65))
    -- standbyNumBg:ignoreAnchorPointForPosition(false)
    -- standbyNumBg:setAnchorPoint(ccp(0,1))
    -- standbyNumBg:setIsSallow(false)
    -- standbyNumBg:setTouchPriority(-(self.layerNum-1)*20-1)
    -- standbyNumBg:setPosition(self.bgLayer:getContentSize().width/2+2,self.bgLayer:getContentSize().height-aNameBg:getContentSize().height-168-heightSpace)
    -- self.bgLayer:addChild(standbyNumBg,1)

    -- self.standbyNumLb=GetTTFLabelWrap(str,25,CCSizeMake(aNameBg:getContentSize().width/2,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter) 
    self.standbyNumLb=GetTTFLabelWrap(getlocal("alliance_war_standby_num",{readyNum}),25,CCSizeMake(aNameBg:getContentSize().width/2,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)   
    self.standbyNumLb:setAnchorPoint(ccp(0.5,0.5))
    self.standbyNumLb:setPosition(ccp(aNameBg:getContentSize().width/4*3,40))
    -- self.standbyNumLb:setColor(G_ColorGreen)
    aNameBg:addChild(self.standbyNumLb)


    local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,touch)
    backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, self.bgLayer:getContentSize().height-aNameBg:getContentSize().height-170-30-heightSpace))
    backSprie:ignoreAnchorPointForPosition(false)
    backSprie:setAnchorPoint(ccp(0.5,0))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
    backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,30))
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
    self.tv:setPosition(ccp(0,5))
    backSprie:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

end

function allianceWarTab2Dialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local memList=allianceWarVoApi:getMemList()
        return SizeOfTable(memList)
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-50,70)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local memList=allianceWarVoApi:getMemList()
        local member=memList[idx+1]
        local memuid=member.uid
        local isBattle=member.isBattle

        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd,fn,idx)
            --return self:cellClick(idx)
        end
       
        if memuid==playerVoApi:getUid() then
            local bgSp=CCSprite:createWithSpriteFrameName("groupSelf.png");
            --bgSp:setAnchorPoint(ccp(0,0));
            bgSp:setPosition(ccp(310,35));
            bgSp:setScaleY(70/bgSp:getContentSize().height)
            bgSp:setScaleX(1000/bgSp:getContentSize().width)
            cell:addChild(bgSp)
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
            if self.tv:getIsScrolled()==true then
                do
                    return
                end
            end
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end

            local selfAlliance=allianceVoApi:getSelfAlliance()
            local memList=allianceWarVoApi:getMemList()
            local memberTab=memList[idx+1]
            local memuid=memberTab.uid
            local isBattle=memberTab.isBattle
            local index=memberTab.index

            local q=index
            local type=1
            if isBattle==1 then
                type=2
                q=index
            else
                type=1
                q=allianceWarVoApi:getLeftIndex()
            end
            local function updatequeueCallback(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    if self==nil or self.tv==nil then
                        do return end
                    end

                    -- 修改上下阵数据
                    if isBattle==1 then
                        allianceWarVoApi:setBattleMem(memuid,0)
                    else
                        allianceWarVoApi:setBattleMem(memuid,1,q)
                    end

                    self:doUserHandler()
                elseif sData.ret==-8045 or sData.ret==-8046 then
                    local selfAlliance=allianceVoApi:getSelfAlliance()
                    if selfAlliance then
                        local aid=selfAlliance.aid
                        local function allianceGetqueueCallback(fn,data)
                            local ret,sData=base:checkServerData(data)
                            if ret==true then
                                allianceWarVoApi:clearMemList()
                                allianceWarVoApi:formatMemList(sData.data)
                                self:doUserHandler()
                            end
                        end
                        socketHelper:allianceGetqueue(aid,allianceGetqueueCallback)
                    end
                end
            end
            if selfAlliance and tonumber(selfAlliance.role)<=0 then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_war_no_competence"),30)
                do return end
            end
            if allianceWarVoApi:checkIsInHold(memuid)==true then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_war_occupying"),30)
                do return end
            end
            if type==1 and q==nil then
                -- smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("alliance_war_battle_full"),nil,self.layerNum+1)
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_war_battle_full"),30)
                do return end
            end
            if selfAlliance and selfAlliance.aid and tonumber(selfAlliance.role)>0 and memuid then
                socketHelper:allianceUpdatequeue(selfAlliance.aid,memuid,type,q,updatequeueCallback)
            end
        
        end
        local checkItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",checkMember,idx+1,getlocal("alliance_war_battle_btn"),28,idx+1001)
        checkItem:setScale(0.6)
        local checkMenu=CCMenu:createWithItem(checkItem);
        checkMenu:setPosition(ccp(G_VisibleSizeWidth-checkItem:getContentSize().width/2-30,lbHeight))
        checkMenu:setTouchPriority(-(self.layerNum-1)*20-2);
        cell:addChild(checkMenu)
        local selfAlliance=allianceVoApi:getSelfAlliance()
        if selfAlliance and tonumber(selfAlliance.role)<=0 then
            checkItem:setEnabled(false)
        end
        if isBattle==1 then
            tolua.cast(checkItem:getChildByTag(idx+1001),"CCLabelTTF"):setString(getlocal("alliance_war_standby_btn"))
        else
            tolua.cast(checkItem:getChildByTag(idx+1001),"CCLabelTTF"):setString(getlocal("alliance_war_battle_btn"))
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

function allianceWarTab2Dialog:tick()
    local flag=allianceWarVoApi:getMemFlag()
    if flag==0 then
        self:doUserHandler()
        allianceWarVoApi:setMemFlag(1)
    end
end

--用户处理特殊需求,没有可以不写此方法
function allianceWarTab2Dialog:doUserHandler()
    if self then
        if self.tv then
            local recordPoint = self.tv:getRecordPoint()
            self.tv:reloadData()
            if recordPoint.y<=0 then
                self.tv:recoverToRecordPoint(recordPoint)
            end
        end
        local maxNum=allianceWarCfg.numberOfBattle
        local battleNum,readyNum=allianceWarVoApi:getBattleMemNum()
        if self.battleNumLb then
            self.battleNumLb:setString(getlocal("alliance_war_battle_num",{battleNum,maxNum}))
        end
        if self.standbyNumLb then
            self.standbyNumLb:setString(getlocal("alliance_war_standby_num",{readyNum}))
        end
    end
end

function allianceWarTab2Dialog:dispose()
    heroVoApi:clearTroops()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil;
    self.layerNum=nil;
    
end