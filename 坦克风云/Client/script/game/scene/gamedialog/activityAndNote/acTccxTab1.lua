acTccxTab1={

}

function acTccxTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    nc.bgLayer=nil
    nc.layerNum=nil
    nc.touchLayer=nil
    self.secondDialog=nil
    return nc;
end

function acTccxTab1:init(layerNum,parent)
    self.activeName=acTccxVoApi:getActiveName()
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent

    local acVo=acTccxVoApi:getAcVo(self.activeName)
    local function initFunc()
        self:initUp()
        self:initCenter()
    end
    if acVo.rd then
        initFunc()
    else
        local cmd="active.tuichenchuxin.refresh"
        acTccxVoApi:socketTccx2017(initFunc,cmd)
    end
    
    return self.bgLayer
end

function acTccxTab1:initUp()
    local lbH=self.bgLayer:getContentSize().height-185
    if G_isIphone5()==true then
        lbH=self.bgLayer:getContentSize().height-185-15
    end

    local actTime=GetTTFLabel(getlocal("activity_timeLabel"),25)
    actTime:setPosition(ccp(self.bgLayer:getContentSize().width/2,lbH))
    self.bgLayer:addChild(actTime,5)
    actTime:setColor(G_ColorYellowPro)

    lbH=lbH-35
    local acVo = acTccxVoApi:getAcVo()
    local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    local timeLabel=GetTTFLabel(timeStr,25)
    timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2, lbH))
    self.bgLayer:addChild(timeLabel)
    timeLabel:setColor(G_ColorYellowPro)
    self.timeLabel=timeLabel
    G_updateActiveTime(acVo,self.timeLabel)

    lbH=lbH-40
    if G_isIphone5()==true then
        lbH=lbH-20
    end
    local acDesLb=GetTTFLabelWrap(getlocal("activity_tccx_des"),25,CCSizeMake(self.bgLayer:getContentSize().width-250,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    acDesLb:setAnchorPoint(ccp(0.5,0.5))
    self.bgLayer:addChild(acDesLb)
    acDesLb:setPosition(self.bgLayer:getContentSize().width/2,lbH)
end

function acTccxTab1:initCenter()
    local acVo=acTccxVoApi:getAcVo()
    local acCfg=acTccxVoApi:getActiveCfg()
    if acVo==nil or acCfg==nil then
        do return end
    end
    local costGems=acCfg.cost1
    local discount=acCfg.cost2 or {}
    local totalCount=SizeOfTable(discount)
    local count=acTccxVoApi:getCount() or 0 
    local allCostGems=acTccxVoApi:getAllCost()
    local bigReward=acTccxVoApi:getBigReward() or {}

    local function nilFunc( ... )
    end
    local bgWidth,bgHeight=self.bgLayer:getContentSize().width-60,self.bgLayer:getContentSize().height-325
    if G_isIphone5()==true then
        bgHeight=bgHeight-60
    end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20, 20, 1, 1),nilFunc)
    backSprie:setContentSize(CCSizeMake(bgWidth,bgHeight))
    backSprie:setAnchorPoint(ccp(0.5,0))
    backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
    backSprie:setPosition(ccp(G_VisibleSizeWidth/2,35))
    self.bgLayer:addChild(backSprie)

    local titleBgHeight=50
    local posY=bgHeight-titleBgHeight/2-5
    local titleLb=GetTTFLabel(getlocal("activity_tccx_tab1_title"),30)
    local  titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelTitleBg.png",CCRect(84, 25, 1, 1),nilFunc)
    titleBg:setContentSize(CCSizeMake(math.max(titleLb:getContentSize().width,400),titleBgHeight))
    titleBg:setPosition(ccp(bgWidth/2,posY))
    backSprie:addChild(titleBg)
    titleLb:setPosition(getCenterPoint(titleBg))
    titleBg:addChild(titleLb,1)


    posY=posY-titleBgHeight/2-65
    if G_isIphone5()==true then
        posY=posY-15
    end
    self.bigIconTb={}
    local showNum=SizeOfTable(bigReward)
    local showXTb=G_getIconSequencePosx(2,160,bgWidth/2,showNum)
    for k,v in pairs(bigReward) do
        local function showNewPropInfo()
            G_showNewPropInfo(self.layerNum+1,true,true,nil,v)
            return false
        end
        local icon=G_getItemIcon(v,100,true,self.layerNum,showNewPropInfo)
        icon:setTouchPriority(-(self.layerNum-1)*20-5)
        icon:setPosition(ccp(showXTb[k],posY))
        backSprie:addChild(icon,1)
        local numLb=GetTTFLabel("x"..v.num,25)
        numLb:setAnchorPoint(ccp(1,0))
        numLb:setPosition(ccp(icon:getContentSize().width-5,5))
        numLb:setColor(G_ColorYellowPro)
        icon:addChild(numLb,1)
        numLb:setTag(11)
        table.insert(self.bigIconTb,icon)
    end

    posY=posY-65
    local contentBgWidth,contentBgHeight=bgWidth-10,posY-120
    if G_isIphone5()==true then
        posY=posY-10
        contentBgHeight=posY-120-25
    end
    local contentBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),function ()end)
    contentBg:setContentSize(CCSizeMake(contentBgWidth,contentBgHeight))
    contentBg:setAnchorPoint(ccp(0.5,1))
    contentBg:setPosition(ccp(bgWidth/2,posY))
    backSprie:addChild(contentBg,1)
    self.contentBg=contentBg
    local bgSp=CCSprite:create("public/hero/heroequip/equipBigBg.jpg")
    bgSp:setAnchorPoint(ccp(0.5,1))
    bgSp:setPosition(ccp(bgWidth/2,posY))
    bgSp:setScaleX((contentBgWidth-0)/bgSp:getContentSize().width)
    bgSp:setScaleY((contentBgHeight-0)/bgSp:getContentSize().height)
    backSprie:addChild(bgSp)
    local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
        pointSp1:setPosition(ccp(5,contentBg:getContentSize().height/2))
        contentBg:addChild(pointSp1)
    local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
    pointSp2:setPosition(ccp(contentBg:getContentSize().width-5,contentBg:getContentSize().height/2))
    contentBg:addChild(pointSp2)


    local lbPosy=contentBgHeight-40
    if G_isIphone5()==true then
        lbPosy=lbPosy-10
    end
    local descStr=getlocal("activity_tccx_tab1_desc",{costGems})
    local tmpLb=GetTTFLabel(descStr,25)
    local descLb=GetTTFLabelWrap(descStr,25,CCSizeMake(contentBgWidth-180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    descLb:setAnchorPoint(ccp(0,0.5))
    descLb:setPosition(ccp(30,lbPosy))
    contentBg:addChild(descLb,1)
    descLb:setColor(G_ColorYellowPro)
    self.descLb=descLb
    local goldSp1=CCSprite:createWithSpriteFrameName("IconGold.png")
    goldSp1:setPosition(ccp(30+math.min(tmpLb:getContentSize().width,contentBgWidth-180)+20,lbPosy))
    contentBg:addChild(goldSp1,1)
    self.goldSp=goldSp1

    local strSize2 = 22
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() =="tw" then
        strSize2 = 25
    end

    local function recordHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local function showRewardLog()
            local rewardLog=acTccxVoApi:getRewardLog() or {}
            if rewardLog and SizeOfTable(rewardLog)>0 then
                local logList={}
                for k,v in pairs(rewardLog) do
                    local type,reward,time,point=v.type,v.reward,v.time,v.point
                    local title={getlocal("activity_tccx_log_title"..type,{point})}
                    local content={{reward}}
                    local log={title=title,content=content,ts=time}
                    table.insert(logList,log)
                end
                local logNum=SizeOfTable(logList)
                require "luascript/script/game/scene/gamedialog/activityAndNote/acCjyxSmallDialog"
                acCjyxSmallDialog:showLogDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-300),CCRect(130, 50, 1, 1),{getlocal("activity_customLottery_RewardRecode"),G_ColorWhite},logList,false,self.layerNum+1,nil,true,10,false,true)
            else
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_tccx_no_record"),30)
            end
        end
        local rewardLog=acTccxVoApi:getRewardLog()
        if rewardLog then
            showRewardLog()
        else
            local function refreshFunc( ... )
                showRewardLog()
            end
            local cmd="active.tuichenchuxin.getlog"
            acTccxVoApi:socketTccx2017(refreshFunc,cmd)
        end
    end
    local recordBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),recordHandler)
    recordBg:setAnchorPoint(ccp(1,0.5))
    recordBg:setContentSize(CCSizeMake(150,60))
    recordBg:setPosition(ccp(contentBg:getContentSize().width-5,lbPosy))
    recordBg:setTouchPriority(-(self.layerNum-1)*20-4)
    recordBg:setOpacity(0)
    contentBg:addChild(recordBg)
    local spScale=0.6
    local recordSp=CCSprite:createWithSpriteFrameName("hero_infoBtn.png")
    recordSp:setPosition(ccp(10+recordSp:getContentSize().width*spScale/2,recordBg:getContentSize().height/2))
    recordSp:setScale(spScale)
    recordBg:addChild(recordSp,1)
    local lbWidth=recordBg:getContentSize().width-10-recordSp:getContentSize().width*spScale
    local recordLb=GetTTFLabelWrap(getlocal("serverwar_point_record"),strSize2,CCSize(lbWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    recordLb:setPosition(recordBg:getContentSize().width-lbWidth/2-3,recordBg:getContentSize().height/2)
    recordBg:addChild(recordLb,1)

    self.iconBgTb={}
    self:resetAllIcon()

    local btnPx,btnPy=150,40
    if G_isIphone5()==true then
        btnPy=btnPy+15
    end
    local function resetHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local function refreshFunc()
            if self and self.bgLayer then
                self:resetAction(true)
            end
        end
        local cmd="active.tuichenchuxin.refresh"
        acTccxVoApi:socketTccx2017(refreshFunc,cmd)
    end
    local resetItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",resetHandler,nil,getlocal("super_weapon_challenge_free_reset"),25/0.8)
    resetItem:setScale(0.8)
    local resetMenu=CCMenu:createWithItem(resetItem)
    resetMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    resetMenu:setPosition(ccp(btnPx,btnPy))
    backSprie:addChild(resetMenu,1)
    self.resetBtn=resetItem

    local function rewardAllHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local allCost=acTccxVoApi:getAllCost()
        local gems=playerVoApi:getGems() or 0

        if allCost>gems then
            local function onSure()
                activityAndNoteDialog:closeAllDialog()
            end
            GemsNotEnoughDialog(nil,nil,allCost-gems,self.layerNum+1,allCost,onSure)
            return
        end
        
        --全部开启
        local oldShow=acTccxVoApi:getShowReward()
        local function refreshFunc(reward,pointTb,tipReward)
            if allCost and allCost>0 then
                playerVoApi:setGems(playerVoApi:getGems() - allCost)
            end
            if oldShow and self.iconBgTb and reward then
                local index=0
                local showIdx=0
                for k,v in pairs(oldShow) do
                    if v and type(v)=="number" and v==0 then
                        showIdx=showIdx+1
                        if reward[showIdx] then
                            self:addTouchLayer()
                            local award=reward[showIdx]
                            local function actionEndHandler()
                                index=index+1
                                if index==showIdx then
                                    if self and self.bgLayer then
                                        local function showEndHandler( ... )
                                            if self and self.bgLayer then
                                                self:resetAction()
                                            end
                                            if tipReward then
                                                G_showRewardTip(tipReward)
                                            end
                                        end
                                        self:showRewardDialog(reward,pointTb,showEndHandler)
                                    end
                                end
                            end
                            local delayTime=0.25*(showIdx-1)
                            self:flipCard(1,k,award,actionEndHandler,delayTime)
                        end
                    end
                end
            end
        end
        local function sureClick()
            local cmd="active.tuichenchuxin.reward"
            acTccxVoApi:socketTccx2017(refreshFunc,cmd)
            self.secondDialog=nil
        end
        local function secondTipFunc(sbFlag)
            local keyName=acTccxVoApi:getActiveName()
            local sValue=base.serverTime .. "_" .. sbFlag
            G_changePopFlag(keyName,sValue)
        end
        if allCost and allCost>0 then
            local keyName=acTccxVoApi:getActiveName()
            if G_isPopBoard(keyName) then
                self.secondDialog=G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{allCost}),true,sureClick,secondTipFunc)
            else
                sureClick()
            end
            
        else
            sureClick()
        end
        
    end
    local rewardAllItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",rewardAllHandler,nil,getlocal("activity_tccx_btn1"),25/0.8)
    rewardAllItem:setScale(0.8)
    local rewardAllMenu=CCMenu:createWithItem(rewardAllItem)
    rewardAllMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    rewardAllMenu:setPosition(ccp(bgWidth-btnPx,btnPy))
    backSprie:addChild(rewardAllMenu,1)
    self.rewardAllBtn=rewardAllItem

    btnPy=btnPy+50
    self.allCostLb=GetTTFLabel(allCostGems,25)
    self.allCostLb:setAnchorPoint(ccp(0.5,0.5))
    self.allCostLb:setPosition(ccp(bgWidth-btnPx-25,btnPy))
    backSprie:addChild(self.allCostLb,1)
    self.allCostLb:setColor(G_ColorYellowPro)
    local goldSp=CCSprite:createWithSpriteFrameName("IconGold.png")
    goldSp:setPosition(ccp(bgWidth-btnPx+45,btnPy))
    backSprie:addChild(goldSp,1)

    self:refresh()
end

function acTccxTab1:addIcon(parent,reward)
    local cardSp
    if reward and type(reward)=="table" then
        local item=reward
        local function showNewPropInfo()
            G_showNewPropInfo(self.layerNum+1,true,true,nil,item)
            return false
        end
        cardSp=G_getItemIcon(item,100,true,self.layerNum,showNewPropInfo)
        cardSp:setPosition(getCenterPoint(parent))
        cardSp:setTouchPriority(-(self.layerNum-1)*20-5)
        parent:addChild(cardSp,1)
        cardSp:setTag(110)
        local numLb=GetTTFLabel(item.num,25)
        numLb:setAnchorPoint(ccp(1,0))
        numLb:setPosition(ccp(cardSp:getContentSize().width-5,5))
        cardSp:addChild(numLb,2)
        local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
        numBg:setAnchorPoint(ccp(1,0))
        numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
        numBg:setPosition(ccp(cardSp:getContentSize().width-5,5))
        numBg:setOpacity(150)
        cardSp:addChild(numBg,1)
    else
        local cardSp=CCSprite:createWithSpriteFrameName("acTccxCard.png")
        cardSp:setPosition(getCenterPoint(parent))
        parent:addChild(cardSp,1)
        cardSp:setTag(109)
    end
    return cardSp
end

function acTccxTab1:showRewardDialog(reward,pointTb,callback)
    if reward then
        local addPoint=0
        local addStrTb
        if pointTb and SizeOfTable(pointTb)>0 then
            addStrTb={}
            for k,v in pairs(pointTb) do
                addPoint=addPoint+(v or 0)
                table.insert(addStrTb,getlocal("activity_nljj_score",{v or 0}))
            end
        end
        local function showEndHandler( ... )
            if callback then
                callback()
            end
        end
        local titleStr=getlocal("activity_wheelFortune4_reward")
        local titleStr2=getlocal("activity_tccx_total_score") .. getlocal("activity_nljj_score",{addPoint})
        require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
        rewardShowSmallDialog:showNewReward(self.layerNum+1,true,true,reward,showEndHandler,titleStr,titleStr2,addStrTb)
    end
end

function acTccxTab1:resetAction(isShowTips)
    if self and self.bgLayer and self.iconBgTb then
        local index=0
        for k,v in pairs(self.iconBgTb) do
            local function actionEndHandler()
                if index<=0 then
                    self:resetAllIcon()
                    self:removeTouchLayer()
                    self:refresh()
                    if isShowTips==true then
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("expeditionRestartSuccess"),30)
                    end
                end
                index=index+1
            end
            self:flipCard(2,k,nil,actionEndHandler)
        end
    end
end

function acTccxTab1:resetAllIcon()
    if self and self.contentBg then
        if self.iconBgTb and SizeOfTable(self.iconBgTb)>0 then
            for k,v in pairs(self.iconBgTb) do
                if v and v.removeFromParentAndCleanup then
                    v:removeFromParentAndCleanup(true)
                end
                v=nil
            end
        end
        self.iconBgTb={}
        local contentBgWidth,contentBgHeight=self.contentBg:getContentSize().width,self.contentBg:getContentSize().height
        local spacex,spacey=135,130
        if G_getIphoneType() ==  G_iphoneX then
            spacey = spacey + 50 
        elseif G_isIphone5()==true then
            spacey=spacey+15
        end
        local pxTb=G_getIconSequencePosx(2,spacex,contentBgWidth/2,4)
        local showReward=acTccxVoApi:getShowReward() or {}
        for i=1,8 do
            local function turnCard(object,fn,tag)
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)

                local acVo=acTccxVoApi:getAcVo()
                if acVo and acVo.openR then
                    local openReward=acVo.openR
                    for k,v in pairs(openReward) do
                        if v==i then
                            do return end
                        end
                    end
                end

                if self and self.iconBgTb and self.iconBgTb[i] then
                    local sp=self.iconBgTb[i]
                    if sp then
                        local scale1 = CCScaleTo:create(0.1,0.8)
                        local scale2 = CCScaleTo:create(0.1,1)
                        local seqArr = CCArray:create()
                        seqArr:addObject(scale1)
                        seqArr:addObject(scale2)
                        local seq_action = CCSequence:create(seqArr)
                        sp:runAction(seq_action)
                    end
                end

                local acCfg=acTccxVoApi:getActiveCfg()
                if acCfg==nil then
                    do return end
                end
                local allCost=acCfg.cost1
                local gems=playerVoApi:getGems() or 0
                local free=acTccxVoApi:getIsFree()
                if free==true then
                    allCost=0
                else
                    if allCost>gems then
                        local function onSure()
                            activityAndNoteDialog:closeAllDialog()
                        end
                        GemsNotEnoughDialog(nil,nil,allCost-gems,self.layerNum+1,allCost,onSure)
                        return
                    end
                end

                local count=acTccxVoApi:getCount() or 0
                local function refreshFunc(reward,pointTb,tipReward)
                    if allCost and allCost>0 then
                        playerVoApi:setGems(playerVoApi:getGems() - allCost)
                    end
                    if reward and reward[1] then
                        local award=reward[1]
                        local function actionEndHandler()
                            self:refresh()
                            local function showEndHandler( ... )
                                local acCfg=acTccxVoApi:getActiveCfg()
                                local discount=acCfg.cost2 or {}
                                local totalCount=SizeOfTable(discount)
                                if totalCount==count+1 then
                                    if self and self.bgLayer then
                                        self:resetAction()
                                    end
                                else
                                    self:removeTouchLayer()
                                end
                                if tipReward then
                                    G_showRewardTip(tipReward)
                                end
                            end
                            self:showRewardDialog(reward,pointTb,showEndHandler)
                        end
                        self:flipCard(1,i,award,actionEndHandler)
                    end
                end
                local function sureClick()
                    local tid=i
                    local cmd="active.tuichenchuxin.reward"
                    acTccxVoApi:socketTccx2017(refreshFunc,cmd,tid,free)
                    self.secondDialog=nil
                end
                local function secondTipFunc(sbFlag)
                    local keyName=acTccxVoApi:getActiveName()
                    local sValue=base.serverTime .. "_" .. sbFlag
                    G_changePopFlag(keyName,sValue)
                end
                if allCost and allCost>0 then
                    local keyName=acTccxVoApi:getActiveName()
                    if G_isPopBoard(keyName) then
                        self.secondDialog=G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{allCost}),true,sureClick,secondTipFunc)
                    else
                        sureClick()
                    end
                    
                else
                    sureClick()
                end

                
            end
            local distanceY=60
            if G_isIphone5()==true then
                distanceY=distanceY+20
            end
            local px,py=pxTb[((i-1)%4)+1],contentBgHeight-distanceY-spacey/2-spacey*(math.floor((i-1)/4))
            local iconBg=LuaCCScale9Sprite:createWithSpriteFrameName("alienTechBg2.png", CCRect(10, 10, 80, 80),turnCard)
            iconBg:setTouchPriority(-(self.layerNum-1)*20-4)
            iconBg:setContentSize(CCSizeMake(110,110))
            iconBg:setPosition(ccp(px,py))
            iconBg:setTag(i)
            self.contentBg:addChild(iconBg,1)
            table.insert(self.iconBgTb,iconBg)
            
            self:addIcon(iconBg,showReward[i])
        end
    end
end

--type 1打开 2关闭，idx 位置
function acTccxTab1:flipCard(type,idx,award,callback,delayTime)
    if self and self.bgLayer and self.iconBgTb then
        local bg=self.iconBgTb[idx]
        if bg then
            bg:stopAllActions()
            bg:setScale(1)
            if type==1 and award then
                local sp=bg:getChildByTag(109)
                if sp then
                    local function callback1( ... )
                        -- local sp=bg:getChildByTag(109)
                        sp=tolua.cast(sp,"CCSprite")
                        if sp then
                            -- sp=tolua.cast(sp,"CCSprite")
                            sp:removeFromParentAndCleanup(true)
                            sp=nil
                            local function showNewPropInfo()
                                G_showNewPropInfo(self.layerNum+1,true,true,nil,award)
                                return false
                            end
                            sp=G_getItemIcon(award,100,true,self.layerNum,showNewPropInfo)
                            sp:setTouchPriority(-(self.layerNum-1)*20-5)
                            sp:setPosition(getCenterPoint(bg))
                            sp:setFlipX(true)
                            sp:setTag(110)
                            bg:addChild(sp,1)
                            local itemIcon=sp:getChildByTag(99)
                            if itemIcon and itemIcon.setFlipX then
                                itemIcon:setFlipX(true)
                            end
                            local numLb=GetTTFLabel(award.num,25)
                            numLb:setAnchorPoint(ccp(0,0))
                            numLb:setPosition(ccp(5,5))
                            sp:addChild(numLb,2)
                            numLb:setFlipX(true)
                            local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
                            numBg:setAnchorPoint(ccp(0,0))
                            numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
                            numBg:setPosition(ccp(5,5))
                            numBg:setOpacity(150)
                            sp:addChild(numBg,1)
                        end
                    end
                    local function resetdataCallback( ... )
                        if callback then
                            callback()
                        end
                    end
                    local action = self:turnarount1(((idx-1)%4)+1,callback1,resetdataCallback,delayTime)
                    bg:runAction(action)
                    self:addTouchLayer()
                end
            elseif type==2 then
                local sp=bg:getChildByTag(110)
                if sp then
                    local function callback1( ... )
                        -- local sp=bg:getChildByTag(110)
                        sp=tolua.cast(sp,"CCSprite")
                        if sp then
                            -- sp=tolua.cast(sp,"CCSprite")
                            sp:removeFromParentAndCleanup(true)
                            sp=nil
                            sp=CCSprite:createWithSpriteFrameName("acTccxCard.png")
                            sp:setPosition(getCenterPoint(bg))
                            sp:setFlipX(true)
                            sp:setTag(109)
                            bg:addChild(sp,1)
                        end
                    end
                    local function resetdataCallback( ... )
                        if callback then
                            callback()
                        end
                    end
                    local action = self:turnarount2(((idx-1)%4)+1,callback1,resetdataCallback,delayTime)
                    bg:runAction(action)
                    self:addTouchLayer()
                end
            end
        end
    end
end

function acTccxTab1:turnarount1(index,callback,resetdataCallback,delayTime)    --打开动画
    local arr = {-105,-95,-85,-75}
    local action = CCOrbitCamera:create(0.25,1,0,0,arr[index],0,0)
    local seqArr = CCArray:create()
    if delayTime and delayTime>0 then
        local delay=CCDelayTime:create(delayTime)
        seqArr:addObject(delay)
    end
    seqArr:addObject(action)
    seqArr:addObject(CCCallFunc:create(callback))
    local action2 = CCOrbitCamera:create(0.25,1,0,arr[index],-(180+arr[index]),0,0)
    seqArr:addObject(action2)
    local delay2=CCDelayTime:create(0.5)
    seqArr:addObject(delay2)
    seqArr:addObject(CCCallFunc:create(resetdataCallback))
    local seq_action = CCSequence:create(seqArr)
    return seq_action
end

function acTccxTab1:turnarount2(index,callback,callback2,delayTime)    --打开又关闭
    local arr = {105,95,85,75}
    local action = CCOrbitCamera:create(0.25,1,0,-180,180-arr[index],0,0)
    local seqArr = CCArray:create()
    if delayTime and delayTime>0 then
        local delay=CCDelayTime:create(delayTime)
        seqArr:addObject(delay)
    end
    seqArr:addObject(action)
    seqArr:addObject(CCCallFunc:create(callback))
    local action2 = CCOrbitCamera:create(0.25,1,0,180-arr[index],arr[index],0,0)
    seqArr:addObject(action2)
    seqArr:addObject(CCCallFunc:create(callback2))
    local seq_action = CCSequence:create(seqArr)
    return seq_action
end


function acTccxTab1:refresh()
    if self and self.bgLayer then
        local acVo=acTccxVoApi:getAcVo()
        local acCfg=acTccxVoApi:getActiveCfg()
        if acVo==nil or acCfg==nil then
            do return end
        end
        local costGems=acCfg.cost1
        local discount=acCfg.cost2 or {}
        local totalCount=SizeOfTable(discount)
        local count=acTccxVoApi:getCount() or 0 
        local allCostGems=acTccxVoApi:getAllCost()
        local free=acTccxVoApi:getIsFree()
        if self.descLb then
            local descStr
            if free==true then
                descStr=getlocal("activity_tccx_tab1_desc",{getlocal("activity_equipSearch_free_btn")})
            else
                descStr=getlocal("activity_tccx_tab1_desc",{costGems})
            end
            self.descLb:setString(descStr)
        end
        if self.goldSp then
            if free==true then
                self.goldSp:setVisible(false)
            else
                self.goldSp:setVisible(true)
            end
        end
        if self.resetBtn then
            if count and count>0 then
                self.resetBtn:setEnabled(true)
            else
                self.resetBtn:setEnabled(false)
            end
        end
        if self.rewardAllBtn then
            if count>=totalCount or free==true then
                self.rewardAllBtn:setEnabled(false)
            else
                self.rewardAllBtn:setEnabled(true)
            end
        end
        if self.allCostLb then
            self.allCostLb:setString(allCostGems)
        end
        if self.bigIconTb then
            local bigReward=acTccxVoApi:getBigReward() or {}
            for k,v in pairs(bigReward) do
                local icon=self.bigIconTb[k]
                if icon and v.num then
                    local lb=icon:getChildByTag(11)
                    if lb then
                        lb=tolua.cast(lb,"CCLabelTTF")
                        lb:setString("x"..v.num)
                        lb:setPosition(ccp(icon:getContentSize().width-5,5))
                    end
                end
            end
        end
    end
end

function acTccxTab1:addTouchLayer()
    if self.touchLayer==nil then
        self.touchLayer=CCLayer:create()
        self.touchLayer:setTouchEnabled(true)
        self.touchLayer:setBSwallowsTouches(true)
        self.touchLayer:setTouchPriority(-(self.layerNum-1)*20-9)
        self.touchLayer:setContentSize(G_VisibleSize)
        self.bgLayer:addChild(self.touchLayer)
    end
end
function acTccxTab1:removeTouchLayer()
    if self.touchLayer then
        self.touchLayer:removeFromParentAndCleanup(true)
    end
    self.touchLayer=nil
end

function acTccxTab1:tick()
    if self.timeLabel and tolua.cast(self.timeLabel,"CCLabelTTF") then
        local acVo=acTccxVoApi:getAcVo()
        if acVo then
            G_updateActiveTime(acVo,self.timeLabel)
        end
    end
end

function acTccxTab1:dispose()
    if self.secondDialog then
        self.secondDialog:close()
    end
    self.descLb=nil
    self.goldSp=nil
    self.resetBtn=nil
    self.rewardAllBtn=nil
    self.allCostLb=nil
    self.bigIconTb=nil
    self:removeTouchLayer()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.layerNum=nil
    self.timeLabel=nil
end
