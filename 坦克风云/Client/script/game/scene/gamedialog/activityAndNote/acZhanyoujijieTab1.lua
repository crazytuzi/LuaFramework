acZhanyoujijieTab1={}

function acZhanyoujijieTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    -- nc.isToday=true
    nc.codeLabel=nil
    nc.inviteCode=nil
    nc.codeBox1=nil
    nc.codeBox=nil
    nc.rewardTv=nil
    nc.listTv=nil
    nc.contentBg=nil
    nc.noBindLb=nil
    nc.bindItem=nil
    return nc
end

function acZhanyoujijieTab1:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self:initHead()
    self:initContent()
    return self.bgLayer
end

function acZhanyoujijieTab1:initHead()
    local strSize2 = 20
    local addPosY = 15
    if G_isIOS() then
        addPosY =0
    end
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
        strSize2 =23
        addPosY =0
    end
    local posy=G_VisibleSizeHeight-180
    -- local characterSp
    -- if platCfg.platCfgChangeGuideUI[G_curPlatName()] then
    --     characterSp = CCSprite:create("public/guide.png")
    -- else
    --     characterSp = CCSprite:createWithSpriteFrameName("GuideCharacter.png")
    -- end
    -- characterSp:setAnchorPoint(ccp(0,1))
    -- characterSp:setPosition(ccp(25,posy))
    -- characterSp:setScale(0.6)
    -- self.bgLayer:addChild(characterSp,5)

    -- 活动时间
    posy=posy+5
    local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),25)
    acLabel:setAnchorPoint(ccp(0.5,1))
    acLabel:setPosition(ccp(G_VisibleSizeWidth/2,posy))
    self.bgLayer:addChild(acLabel,5)
    acLabel:setColor(G_ColorGreen)

    local function showInfo()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local acCfg=acZhanyoujijieVoApi:getAcCfg()
        if acCfg then
            local tabStr={"\n",getlocal("activity_zhanyoujijie_tip1",{acCfg.limitLv,acCfg.limitDay,acCfg.limitNum1,acCfg.limitNum2}),"\n"}
            local tabColor={nil,G_ColorYellowPro,nil}
            local td=smallDialog:new()
            local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
            sceneGame:addChild(dialog,self.layerNum+1)
        end
    end
    local itemScale=1
    local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
    infoItem:setScale(itemScale)
    local infoBtn = CCMenu:createWithItem(infoItem)
    infoBtn:setPosition(ccp(G_VisibleSizeWidth-80,posy-infoItem:getContentSize().height*itemScale/2+10))
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(infoBtn,5)

    posy=posy-acLabel:getContentSize().height-10
    local acVo = acZhanyoujijieVoApi:getAcVo()
    local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.et)
    local timeLabel=GetTTFLabel(timeStr,25)
    timeLabel:setAnchorPoint(ccp(0.5,1))
    timeLabel:setPosition(ccp(G_VisibleSizeWidth/2,posy))
    self.bgLayer:addChild(timeLabel,5)

    posy=posy-timeLabel:getContentSize().height-10
    local str=getlocal("activity_zhanyoujijie_desc1")
    -- str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    local descLb=GetTTFLabelWrap(str,strSize2,CCSizeMake(420,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    descLb:setAnchorPoint(ccp(0.5,1))
    descLb:setPosition(ccp(G_VisibleSizeWidth/2,posy+addPosY))
    self.bgLayer:addChild(descLb,5)
end

function acZhanyoujijieTab1:initContent()
    local strSize2 = 20
    local strSize3 = 16
    local strSize4 = 18
    local btnScale = 0.63
    local btnLbSubSize = 10
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
        strSize2 =25
        strSize3 =25
        strSize4 =25
        btnScale = 0.6
        btnLbSubSize =0
    end
    local isAfk
    local acVo=acZhanyoujijieVoApi:getAcVo()
    if acVo then
        isAfk=acVo.isAfk
    end
    local acCfg=acZhanyoujijieVoApi:getAcCfg()
    if acVo==nil or acCfg==nil then
        do return end
    end

    local count=math.floor((G_VisibleSizeHeight-160)/80)
    for i=1,count do
        local bgSp=CCSprite:createWithSpriteFrameName("threeyear_bg.png")
        bgSp:setAnchorPoint(ccp(0.5,1))
        bgSp:setScaleX((G_VisibleSizeWidth-50)/bgSp:getContentSize().width)
        bgSp:setScaleY(80/bgSp:getContentSize().height)
        bgSp:setPosition(G_VisibleSizeWidth/2,(G_VisibleSizeHeight-160)-(i-1)*bgSp:getContentSize().height)
        self.bgLayer:addChild(bgSp)
        if G_isIphone5()==false and i==count then
            bgSp:setPosition(ccp(bgSp:getPositionX(),bgSp:getPositionY()+20))
        end
    end

    local contentBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20,20,1,1),function ( ... )end)
    -- local contentBg=LuaCCScale9Sprite:createWithSpriteFrameName("TrialSquadBox.png",CCRect(20,20,10,10),function ( ... )end)
    contentBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight-360))
    contentBg:setAnchorPoint(ccp(0,0))
    contentBg:setPosition(25,35)
    self.bgLayer:addChild(contentBg,1)
    self.contentBg=contentBg
    
    local bgWidth,bgHeight=contentBg:getContentSize().width,contentBg:getContentSize().height
    local posx,posy=bgWidth/2,bgHeight-5
    if acZhanyoujijieVoApi:isLevelLimit()==true then
        contentBg:setOpacity(0)
        -- local count=math.floor((G_VisibleSizeHeight-160)/80)
        -- for i=1,count do
        --     local bgSp=CCSprite:createWithSpriteFrameName("threeyear_bg.png")
        --     bgSp:setAnchorPoint(ccp(0.5,1))
        --     bgSp:setScaleX((G_VisibleSizeWidth-50)/bgSp:getContentSize().width)
        --     bgSp:setScaleY(80/bgSp:getContentSize().height)
        --     bgSp:setPosition(G_VisibleSizeWidth/2,(G_VisibleSizeHeight-160)-(i-1)*bgSp:getContentSize().height)
        --     self.bgLayer:addChild(bgSp)
        --     if G_isIphone5()==false and i==count then
        --         bgSp:setPosition(ccp(bgSp:getPositionX(),bgSp:getPositionY()+20))
        --     end
        -- end
        local tankSp=CCSprite:createWithSpriteFrameName("threeyear_icon.png")
        tankSp:setAnchorPoint(ccp(0.5,0.5))
        tankSp:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2-60))
        self.bgLayer:addChild(tankSp,1)

        local levelLimitLb=GetTTFLabelWrap(getlocal("activity_zhanyoujijie_level_limit",{acCfg.limitLv}),25,CCSizeMake(bgWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        levelLimitLb:setAnchorPoint(ccp(0.5,0.5))
        levelLimitLb:setPosition(ccp(bgWidth/2,160))
        contentBg:addChild(levelLimitLb,2)
        levelLimitLb:setColor(G_ColorRed)

        local function gotoHandler()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()   
            end
            PlayEffect(audioCfg.mouseClick)

            activityAndNoteDialog:closeAllDialog()
            local td=playerVoApi:showPlayerDialog(1,self.layerNum+1)
            td:tabClick(2)
        end
        local levelUpItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",gotoHandler,nil,getlocal("activity_zhanyoujijie_level_up"),25)
        -- levelUpItem:setScale(0.7)
        local levelUpMenu=CCMenu:createWithItem(levelUpItem)
        levelUpMenu:setTouchPriority(-(self.layerNum-1)*20-4)
        levelUpMenu:setPosition(bgWidth/2,80)
        contentBg:addChild(levelUpMenu,2)
        G_addRectFlicker(levelUpItem,2.2,1)
        do return end
    end

    if isAfk==nil then
        do return end
    end
    local colorBg=CCSprite:createWithSpriteFrameName("acChunjianpansheng_redLine.png")
    colorBg:setScaleX(contentBg:getContentSize().width/colorBg:getContentSize().width)
    colorBg:setScaleY(contentBg:getContentSize().height/colorBg:getContentSize().height)
    colorBg:setPosition(getCenterPoint(contentBg))
    contentBg:addChild(colorBg)
    
    local playerList=acVo.bindPlayers or {}
    local title1,title2,reward
    if isAfk==2 then
        title1,title2,reward=getlocal("activity_zhanyoujijie_st_11"),getlocal("activity_zhanyoujijie_st_21"),acCfg["prize"..isAfk].reward
    else
        title1,title2,reward=getlocal("activity_zhanyoujijie_st_12"),getlocal("activity_zhanyoujijie_st_22"),acCfg["prize"..isAfk].reward
    end

    local titleBgWidth,titleBgHeight=contentBg:getContentSize().width-80,50
    local titleBg1=CCSprite:createWithSpriteFrameName("orangeMask.png")
    local scalex,scaley=titleBgWidth/titleBg1:getContentSize().width,titleBgHeight/titleBg1:getContentSize().height
    titleBg1:setAnchorPoint(ccp(0.5,1))
    titleBg1:setPosition(ccp(posx,posy))
    titleBg1:setScaleX(scalex)
    titleBg1:setScaleY(scaley)
    contentBg:addChild(titleBg1,1)
    local lineSp1=CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine3.png")
    lineSp1:setScaleX(titleBgWidth/lineSp1:getContentSize().width)
    lineSp1:setPosition(ccp(titleBg1:getContentSize().width/2,titleBg1:getContentSize().height))
    titleBg1:addChild(lineSp1)
    local lineSp2=CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine3.png")
    lineSp2:setScaleX(titleBgWidth/lineSp2:getContentSize().width)
    lineSp2:setPosition(ccp(titleBg1:getContentSize().width/2,0))
    titleBg1:addChild(lineSp2)
    local titleLb1=GetTTFLabelWrap(title1,25,CCSizeMake(bgWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb1:setAnchorPoint(ccp(0.5,0.5))
    titleLb1:setPosition(getCenterPoint(titleBg1))
    titleLb1:setScaleX(1/scalex)
    titleLb1:setScaleY(1/scaley)
    titleBg1:addChild(titleLb1)

    posy=posy-titleBgHeight-10
    local rewardBg=LuaCCScale9Sprite:createWithSpriteFrameName("acChunjiepansheng_orangeBg3.png",CCRect(20,20,20,20),function ( ... )end)
    rewardBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-230,150-20))
    rewardBg:setAnchorPoint(ccp(0,1))
    rewardBg:setPosition(20,posy)
    contentBg:addChild(rewardBg,1)
    local cellWidth,cellHeight=110,rewardBg:getContentSize().height
    local rewardTb=FormatItem(reward,false,true)
    local isMoved
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return SizeOfTable(rewardTb)
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local item=rewardTb[idx+1]
            if item then
                local icon=G_getItemIcon(item,80,true,self.layerNum,nil,self.rewardTv)
                icon:setPosition(ccp(cellWidth/2,cellHeight/2+15))
                icon:setTouchPriority(-(self.layerNum-1)*20-2)
                cell:addChild(icon,1)
                local num=item.num
                if item.type=="u" and acVo.returnLv and tonumber(acVo.returnLv)>0 then
                    num=num*tonumber(acVo.returnLv)
                end
                local numLb=GetTTFLabel("x"..FormatNumber(num),25)
                numLb:setAnchorPoint(ccp(0.5,0.5))
                numLb:setPosition(ccp(cellWidth/2,cellHeight/2-40))
                cell:addChild(numLb,1)
            end

            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)
    self.rewardTv=LuaCCTableView:createHorizontalWithEventHandler(hd,CCSizeMake(rewardBg:getContentSize().width-10,rewardBg:getContentSize().height),nil)
    self.rewardTv:setPosition(ccp(5,0))
    self.rewardTv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    rewardBg:addChild(self.rewardTv,2)
    self.rewardTv:setMaxDisToBottomOrTop(120)

    local btnPosx=bgWidth-80
    local hasRewardLb=GetAllTTFLabel(getlocal("activity_hadReward"),25,ccp(0.5,0.5),ccp(btnPosx,posy-rewardBg:getContentSize().height/2),contentBg,2,G_ColorWhite,CCSize(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    if acVo.isRewardReturn and acVo.isRewardReturn>0 then
    else
        local function rewardHandler( ... )
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            local acVo=acZhanyoujijieVoApi:getAcVo()
            if acVo.isRewardReturn and acVo.isRewardReturn>0 then
            else
                local function loginRewardCallback(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        if sData.data and sData.data.zhanyoujijie then
                            acZhanyoujijieVoApi:updateData(sData.data.zhanyoujijie)
                            
                            local prize=acCfg["prize"..isAfk]
                            if prize and prize.reward then
                                local award=FormatItem(prize.reward,false,true) or {}
                                for k,v in pairs(award) do
                                    if v.type=="u" and acVo.returnLv and tonumber(acVo.returnLv)>0 then
                                        v.num=v.num*tonumber(acVo.returnLv)
                                    end
                                    G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                                end
                                G_showRewardTip(award,true)
                            end
                            if self.rewardItem then
                                self.rewardItem:setVisible(false)
                                self.rewardItem:setEnabled(false)
                            end
                            if hasRewardLb then
                                hasRewardLb:setVisible(true)
                            end
                        end
                    end
                end
                socketHelper:activeZhanyoujijieLoginReward(loginRewardCallback)
            end
        end
        local iScale=0.8
        self.rewardItem = GetButtonItem("TaskBtnGet.png","TaskBtnGet_Down.png","TaskBtnGet_Down.png",rewardHandler,12,nil,nil)
        self.rewardItem:setScale(iScale)
        local rewardmenu = CCMenu:createWithItem(self.rewardItem)
        rewardmenu:setPosition(ccp(btnPosx,posy-rewardBg:getContentSize().height/2))
        rewardmenu:setTouchPriority(-(self.layerNum-1)*20-4)
        contentBg:addChild(rewardmenu,2)
        hasRewardLb:setVisible(false)
    end

    posy=posy-rewardBg:getContentSize().height-10
    local titleBg2=CCSprite:createWithSpriteFrameName("orangeMask.png")
    local scalex2,scaley2=titleBgWidth/titleBg2:getContentSize().width,titleBgHeight/titleBg2:getContentSize().height
    titleBg2:setAnchorPoint(ccp(0.5,1))
    titleBg2:setPosition(ccp(posx,posy))
    titleBg2:setScaleX(scalex2)
    titleBg2:setScaleY(scaley2)
    contentBg:addChild(titleBg2,1)
    local lineSp3=CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine3.png")
    lineSp3:setScaleX(titleBgWidth/lineSp3:getContentSize().width)
    lineSp3:setPosition(ccp(titleBg2:getContentSize().width/2,titleBg2:getContentSize().height))
    titleBg2:addChild(lineSp3)
    local lineSp4=CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine3.png")
    lineSp4:setScaleX(titleBgWidth/lineSp4:getContentSize().width)
    lineSp4:setPosition(ccp(titleBg2:getContentSize().width/2,0))
    titleBg2:addChild(lineSp4)
    local titleLb2=GetTTFLabelWrap(title2,strSize2,CCSizeMake(bgWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb2:setAnchorPoint(ccp(0.5,0.5))
    titleLb2:setPosition(getCenterPoint(titleBg2))
    titleLb2:setScaleX(1/scalex2)
    titleLb2:setScaleY(1/scaley2)
    titleBg2:addChild(titleLb2)

    posy=posy-100
    if isAfk==2 then
        local inviteBg=LuaCCScale9Sprite:createWithSpriteFrameName("acChunjiepansheng_orangeBg3.png",CCRect(20,20,1,1),function ( ... )end)
        inviteBg:setContentSize(CCSizeMake(bgWidth-40,80))
        inviteBg:setAnchorPoint(ccp(0.5,0.5))
        inviteBg:setPosition(ccp(bgWidth/2,posy))
        contentBg:addChild(inviteBg)

        local inviteCodeBg=LuaCCScale9Sprite:createWithSpriteFrameName("olympic_collect.png",CCRect(10,10,10,10),function ( ... )end)
        inviteCodeBg:setContentSize(CCSizeMake(180,50))
        inviteCodeBg:setAnchorPoint(ccp(0.5,0.5))
        inviteCodeBg:setPosition(bgWidth/2,posy)
        contentBg:addChild(inviteCodeBg,2)
        local codeLb=GetTTFLabel(acVo.code,25)
        codeLb:setPosition(getCenterPoint(inviteCodeBg))
        inviteCodeBg:addChild(codeLb)
        local inviteCodeLb=GetTTFLabelWrap(getlocal("activity_zhanyoujijie_invite_code"),strSize4,CCSizeMake(bgWidth/2-inviteCodeBg:getContentSize().width/2-20,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
        inviteCodeLb:setAnchorPoint(ccp(1,0.5))
        inviteCodeLb:setPosition(ccp(bgWidth/2-inviteCodeBg:getContentSize().width/2-10,posy))
        contentBg:addChild(inviteCodeLb,2)
        
        local function onShare()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            if acVo.bindPlayers and SizeOfTable(acVo.bindPlayers)>=acCfg.limitNum1 then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_zhanyoujijie_share_fail2"),28)
                do return end
            end
            local lastTime=acZhanyoujijieVoApi:getLastChatTime()
            if base.serverTime-lastTime>=60 then
                local message=getlocal("activity_zhanyoujijie_invite_chat",{acVo.code})
                if G_curPlatName()=="androidkunlun" or G_curPlatName()=="14" or G_curPlatName()=="androidkunlunz" or G_curPlatName()=="0" then
                    local function sendFeedHandler( ... )
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_zhanyoujijie_share_success"),28)
                        acZhanyoujijieVoApi:setLastChatTime(base.serverTime)
                    end
                    G_sendFeed(1,sendFeedHandler,message)
                else
                    local channelType=1    
                    local sender=playerVoApi:getUid()
                    local senderName=playerVoApi:getPlayerName()
                    local level=playerVoApi:getPlayerLevel()
                    local rank=playerVoApi:getRank()
                    local allianceName
                    local allianceRole
                    if allianceVoApi:isHasAlliance() then
                        local allianceVo=allianceVoApi:getSelfAlliance()
                        allianceName=allianceVo.name
                        allianceRole=allianceVo.role
                    end
                    local params={subType=1,contentType=2,message=message,level=level,rank=rank,power=playerVoApi:getPlayerPower(),uid=playerVoApi:getUid(),name=playerVoApi:getPlayerName(),pic=playerVoApi:getPic(),ts=base.serverTime,allianceName=allianceName,allianceRole=allianceRole,vip=playerVoApi:getVipLevel(),wr=playerVoApi:getServerWarRank(),st=playerVoApi:getServerWarRankStartTime(),title=playerVoApi:getTitle()}
                    chatVoApi:sendChatMessage(channelType,sender,senderName,0,"",params)
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_zhanyoujijie_share_success"),28)
                    acZhanyoujijieVoApi:setLastChatTime(base.serverTime)
                end
            else
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_zhanyoujijie_share_fail1"),28)
            end
        end
        local shareItem=GetButtonItem("anniversarySend.png","anniversarySendDown.png","anniversarySendDown.png",onShare)
        local shareBtn=CCMenu:createWithItem(shareItem)
        shareBtn:setTouchPriority(-(self.layerNum-1)*20-4)
        shareBtn:setPosition(btnPosx,posy)
        contentBg:addChild(shareBtn,2)
    else
        local bindBg=LuaCCScale9Sprite:createWithSpriteFrameName("acChunjiepansheng_orangeBg3.png",CCRect(20,20,1,1),function ( ... )end)
        bindBg:setContentSize(CCSizeMake(bgWidth-40,80))
        bindBg:setAnchorPoint(ccp(0.5,0.5))
        bindBg:setPosition(ccp(bgWidth/2,posy))
        contentBg:addChild(bindBg)

        -- local function callBackCodeHandler(fn,eB,str,type)
        --     if str==nil then
        --         str=""
        --     end
        --     self.inviteCode=str
        -- end
        local function callBackCodeHandler(fn,eB,str,type)
            if type==0 then
                self.codeBox1:setVisible(false)
            elseif type==1 then  --检测文本内容变化
                if str=="" then
                    self.codeLabel:setString(getlocal("activity_zhanyoujijie_input_invite_code"))
                    self.codeLabel:setColor(G_ColorGray)
                    self.inviteCode=""
                    do
                        return
                    end
                end
                self.inviteCode=str
                self.codeLabel:setString(str)
                -- self.codeLabel:setVisible(false)
                -- self.codeBox1:setVisible(false)
            elseif type==2 then --检测文本输入结束
                eB:setVisible(false)
                -- self.codeLabel:setVisible(true)
                if self.codeLabel:getString()==getlocal("activity_zhanyoujijie_input_invite_code") then
                    self.codeLabel:setColor(G_ColorGray)
                else
                    self.codeLabel:setColor(G_ColorWhite)
                end
                self.codeBox1:setVisible(true)
            end
        end


        local function tthandler()
        end
        self.codeBox1=LuaCCScale9Sprite:createWithSpriteFrameName("threeyear_numbg.png",CCRect(19,19,1,1),tthandler)
        self.codeBox1:setContentSize(CCSizeMake(300,50))
        -- self.codeBox1:setIsSallow(false)
        -- self.codeBox1:setTouchPriority(-(self.layerNum-1)*20-4)
        -- -- self.codeBox1:setAnchorPoint(ccp(0,0))
        self.codeBox1:setPosition(ccp(bgWidth/2,posy))

        self.codeLabel=GetTTFLabel(getlocal("activity_zhanyoujijie_input_invite_code"),strSize2)
        self.codeLabel:setAnchorPoint(ccp(0.5,0.5))
        -- self.codeLabel:setPosition(ccp(10,self.codeBox1:getContentSize().height/2))
        -- self.codeLabel:setPosition(ccp(bgWidth/2,posy))
        self.codeLabel:setPosition(getCenterPoint(self.codeBox1))
        -- self.codeLa/bel:setColor(G_ColorPurple)
        self.codeLabel:setColor(G_ColorGray)
        self.codeBox1:addChild(self.codeLabel,2)
        contentBg:addChild(self.codeBox1,2)
        
        -- local editBox=customEditBox:new()
        -- local length=20
        -- local inputMode
        -- if G_isIOS()==true then
        --     inputMode=CCEditBox.kEditBoxInputModePhoneNumber
        -- else
        --     inputMode=CCEditBox.kEditBoxInputModeAny
        -- end
        -- local editReciverBox,reciverText=editBox:init(self.codeBox,self.codeLabel,"threeyear_numbg.png",nil,-(self.layerNum-1)*20-4,length,callBackCodeHandler,nil,inputMode)
        local codeBox2=LuaCCScale9Sprite:createWithSpriteFrameName("threeyear_numbg.png",CCRect(10,10,10,10),tthandler)
        self.codeBox=CCEditBox:createForLua(CCSize(300,50),codeBox2,nil,nil,callBackCodeHandler)
        -- if G_isIOS()==true then
        --     self.codeBox:setInputMode(CCEditBox.kEditBoxInputModePhoneNumber)
        -- else
        --     self.codeBox:setInputMode(CCEditBox.kEditBoxInputModeAny)
        -- end
        self.codeBox:setInputMode(CCEditBox.kEditBoxInputModeSingleLine)
        self.codeBox:setVisible(false)
        self.codeBox:setMaxLength(15)
        self.codeBox:setPosition(ccp(bgWidth/2,posy))
        self.codeBox:setFont(self.codeLabel.getFontName(self.codeLabel),self.codeLabel.getFontSize(self.codeLabel)/2+2)
        contentBg:addChild(self.codeBox,3)
        -- self.editReciverBox:setFontColor(G_ColorPurple)

        local function tthandler3()
            PlayEffect(audioCfg.mouseClick)
            self.codeBox:setVisible(true)
        end
        local touchBg=LuaCCScale9Sprite:createWithSpriteFrameName("olympic_collect.png",CCRect(10,10,10,10),tthandler3)
        -- local touchBg=LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg.png",CCRect(10,10,5,5),tthandler3)
        touchBg:setPosition(ccp(bgWidth/2,posy))
        touchBg:setContentSize(CCSize(300,50))
        touchBg:setTouchPriority(-(self.layerNum-1)*20-4)
        touchBg:setOpacity(0)
        contentBg:addChild(touchBg,1)

        local function onBind()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            print("self.inviteCode",self.inviteCode)
            if self.inviteCode and self.inviteCode~="" then
                local function bindCallback(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        if sData.data and sData.data.zhanyoujijie then
                            acZhanyoujijieVoApi:updateData(sData.data.zhanyoujijie)
                            self:initListTv()
                            if self.listTv then
                                self.listTv:reloadData()
                            end
                            if self.bindItem then
                                local acVo=acZhanyoujijieVoApi:getAcVo()
                                if acVo and acVo.bindPlayers and SizeOfTable(acVo.bindPlayers)>=acCfg.limitNum2 then
                                    self.bindItem:setEnabled(false)
                                    local lb=tolua.cast(self.bindItem:getChildByTag(101),"CCLabelTTF")
                                    if lb then
                                        lb:setString(getlocal("activity_zhanyoujijie_has_bind"))
                                    end
                                end
                            end
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_zhanyoujijie_bind_success"),28)
                        end
                    end
                end
                local inviteCode=self.inviteCode
                socketHelper:activeZhanyoujijieBind(inviteCode,bindCallback)
            else
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_zhanyoujijie_input_invite_code"),28)
            end
        end
        local itemScale=btnScale
        local lbSize=22*1/itemScale
        self.bindItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onBind,nil,getlocal("activity_zhanyoujijie_bind_btn"),lbSize-btnLbSubSize,101)
        self.bindItem:setScale(itemScale)
        local bindMenu=CCMenu:createWithItem(self.bindItem)
        bindMenu:setTouchPriority(-(self.layerNum-1)*20-4)
        bindMenu:setPosition(btnPosx,posy)
        contentBg:addChild(bindMenu,2)
        if acVo.bindPlayers and SizeOfTable(acVo.bindPlayers)>=acCfg.limitNum2 then
            self.bindItem:setEnabled(false)
            local lb=tolua.cast(self.bindItem:getChildByTag(101),"CCLabelTTF")
            if lb then
                lb:setString(getlocal("activity_zhanyoujijie_has_bind"))
            end
        end
    end

    posy=posy-65
    local lbTb={
        {getlocal("activity_zhanyoujijie_st_21"),strSize3,ccp(0.5,0.5),ccp(120,posy),contentBg,2,G_ColorWhite,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
        {getlocal("RankScene_level"),strSize3,ccp(0.5,0.5),ccp(250,posy),contentBg,2,G_ColorWhite,CCSize(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
        {getlocal("activity_zhanyoujijie_bind_time"),strSize3,ccp(0.5,0.5),ccp(380,posy),contentBg,2,G_ColorWhite,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
        {getlocal("award"),strSize3,ccp(0.5,0.5),ccp(510,posy),contentBg,2,G_ColorWhite,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
    }
    for k,v in pairs(lbTb) do
        GetAllTTFLabel(v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11])
    end

    local lineSp0=CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine3.png")
    lineSp0:setScaleX((bgWidth-100)/lineSp0:getContentSize().width)
    lineSp0:setPosition(ccp(bgWidth/2,posy-30))
    contentBg:addChild(lineSp0,2)
    
    local playerList2=acVo.bindPlayers or {}
    if playerList2 and SizeOfTable(playerList2)>0 then
        self:initListTv()
    else
        self.noBindLb=GetTTFLabelWrap(getlocal("activity_zhanyoujijie_no_bind2"),25,CCSizeMake(bgWidth-80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        self.noBindLb:setAnchorPoint(ccp(0.5,0.5))
        self.noBindLb:setPosition(ccp(bgWidth/2,(posy-20)/2))
        contentBg:addChild(self.noBindLb,2)
    end
end

function acZhanyoujijieTab1:initListTv()
    if self.noBindLb then
        self.noBindLb:setVisible(true)
        local acVo=acZhanyoujijieVoApi:getAcVo()
        if acVo and acVo.bindPlayers then
            local playerList=acVo.bindPlayers or {}
            if playerList and SizeOfTable(playerList)>0 then
                self.noBindLb:setVisible(false)
            end
        end
    end
    if self.contentBg and self.listTv==nil then
        local cellWidth1,cellHeight1=self.contentBg:getContentSize().width,80
        local isMoved
        local function tvCallBack1(handler,fn,idx,cel)
            if fn=="numberOfCellsInTableView" then
                local acVo=acZhanyoujijieVoApi:getAcVo()
                local playerList=acVo.bindPlayers or {}
                return SizeOfTable(playerList)
            elseif fn=="tableCellSizeForIndex" then
                local tmpSize=CCSizeMake(cellWidth1,cellHeight1)
                return tmpSize
            elseif fn=="tableCellAtIndex" then
                local cell=CCTableViewCell:new()
                cell:autorelease()

                -- local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
                local lineSp=CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine3.png")
                lineSp:setScaleX((cellWidth1-100)/lineSp:getContentSize().width)
                lineSp:setPosition(ccp(cellWidth1/2,2))
                cell:addChild(lineSp)

                local acVo=acZhanyoujijieVoApi:getAcVo()
                local playerList=acVo.bindPlayers or {}
                local playerData=playerList[idx+1]
                if playerData then
                    local uid=playerData.uid
                    local time=playerData.time or 0
                    local hasRewardNum=playerData.hasRewardNum or 0
                    local isReward=playerData.isReward or 0
                    local name=playerData.name or ""
                    local level=playerData.level or 0
                    local levelStr="Lv."..level
                    local lbTb1={
                        {name,25,ccp(0.5,0.5),ccp(120,cellHeight1/2+4),cell,2,G_ColorWhite},
                        {levelStr,25,ccp(0.5,0.5),ccp(250,cellHeight1/2+4),cell,2,G_ColorWhite},
                        {G_getDateStr(time),25,ccp(0.5,0.5),ccp(380,cellHeight1/2+4),cell,2,G_ColorWhite},
                    }
                    for k,v in pairs(lbTb1) do
                        GetAllTTFLabel(v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11])
                    end

                    local function giftHandler( ... )
                        if self.listTv and self.listTv:getScrollEnable()==true and self.listTv:getIsScrolled()==false then
                            if G_checkClickEnable()==false then
                                do
                                    return
                                end
                            else
                                base.setWaitTime=G_getCurDeviceMillTime()
                            end
                            PlayEffect(audioCfg.mouseClick)

                            local function bindRewardCallback(fn,data)
                                local ret,sData=base:checkServerData(data)
                                if ret==true then
                                    if sData.data and sData.data.zhanyoujijie then
                                        acZhanyoujijieVoApi:updateData(sData.data.zhanyoujijie)
                                        self:initListTv()
                                        if self.listTv then
                                            self.listTv:reloadData()
                                        end

                                        local acVo=acZhanyoujijieVoApi:getAcVo()
                                        local acCfg=acZhanyoujijieVoApi:getAcCfg()
                                        if acVo and acVo.isAfk and acCfg and acCfg["bindPrize"..acVo.isAfk] then
                                            local bindPrize=acCfg["bindPrize"..acVo.isAfk]
                                            if bindPrize and bindPrize.reward then
                                                local award=FormatItem(bindPrize.reward,false,true) or {}
                                                for k,v in pairs(award) do
                                                    G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                                                end
                                                G_showRewardTip(award,true)
                                            end
                                        end
                                    end
                                end
                            end
                            socketHelper:activeZhanyoujijieBindReward(uid,bindRewardCallback)
                        end
                    end
                    if isReward and isReward==1 then
                        GetAllTTFLabel(getlocal("activity_hadReward"),25,ccp(0.5,0.5),ccp(510,cellHeight1/2),cell,2,G_ColorWhite,CCSize(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                    else
                        local giftSp=LuaCCSprite:createWithSpriteFrameName("SeniorBox.png",giftHandler)
                        giftSp:setScale(0.5)
                        giftSp:setPosition(ccp(510,cellHeight1/2))
                        giftSp:setTouchPriority(-(self.layerNum-1)*20-2)
                        cell:addChild(giftSp,2)
                        giftSp:setRotation(-15)
                        local rotateBy1 = CCRotateBy:create(0.25,30)
                        local rotateBy2 = CCRotateBy:create(0.25,-30)
                        local seq=CCSequence:createWithTwoActions(rotateBy1,rotateBy2)
                        giftSp:runAction(CCRepeatForever:create(seq))
                    end
                end

                return cell
            elseif fn=="ccTouchBegan" then
                isMoved=false
                return true
            elseif fn=="ccTouchMoved" then
                isMoved=true
            elseif fn=="ccTouchEnded"  then

            end
        end
        local hd=LuaEventHandler:createHandler(tvCallBack1)
        self.listTv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth1,self.contentBg:getContentSize().height-410),nil)
        self.listTv:setPosition(ccp(0,5))
        self.listTv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
        self.contentBg:addChild(self.listTv,2)
        self.listTv:setMaxDisToBottomOrTop(80)
    end
end

function acZhanyoujijieTab1:tick()
    if acZhanyoujijieVoApi:getBdListFlag()==1 then
        acZhanyoujijieVoApi:setBdListFlag(0)
        if self then
            self:initListTv()
            if self.listTv then
                self.listTv:reloadData()
            end
        end
    end
end

function acZhanyoujijieTab1:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.layerNum=nil
    self.codeLabel=nil
    self.inviteCode=nil
    self.codeBox1=nil
    self.codeBox=nil
    self.rewardTv=nil
    self.listTv=nil
    self.contentBg=nil
    self.noBindLb=nil
    self.bindItem=nil
end