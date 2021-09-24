acZnkh2017Tab2 ={}
function acZnkh2017Tab2:new(layerNum,parent)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.layerNum=layerNum
    nc.cellHeight=185
    nc.parent=parent
    return nc
end

function acZnkh2017Tab2:init()
	self.bgLayer=CCLayer:create()
    self:initHead()
    self:addTV()
	return self.bgLayer
end

function acZnkh2017Tab2:initHead()
    local startH=self.bgLayer:getContentSize().height-175
    local activeScoreLb=GetTTFLabelWrap(getlocal("activity_znkh2017_tab2_des1"),25,CCSizeMake(G_VisibleSizeWidth-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    activeScoreLb:setAnchorPoint(ccp(0,1))
    activeScoreLb:setPosition(40,startH)
    self.bgLayer:addChild(activeScoreLb)
    self.activeScoreLb=activeScoreLb

    local posY=startH-130
    self.posY=posY

    self:initOrRefreshProgress()

    local desLbH=posY-50
    local desLb=GetTTFLabelWrap(getlocal("activity_znkh2017_tab2_des2"),25,CCSizeMake(G_VisibleSizeWidth-80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.bgLayer:addChild(desLb)
    desLb:setPosition(G_VisibleSizeWidth/2,desLbH)
end

function acZnkh2017Tab2:initOrRefreshProgress(flag)
    local posY=self.posY
    if flag then
        local timerSpriteLv=self.bgLayer:getChildByTag(11)
        if timerSpriteLv then
            timerSpriteLv:removeFromParentAndCleanup(true)
        end
        local timerSpriteBg=self.bgLayer:getChildByTag(13)
        if timerSpriteBg then
            timerSpriteBg:removeFromParentAndCleanup(true)
        end
    end
    local cfg=acZnkh2017VoApi:getActiveCfg()
    local needPoint=cfg.needPoint
    local pointPrize=cfg.pointPrize

    local acPoint=acZnkh2017VoApi:getPoint()
    local percentStr=""
    local centerWidth=G_VisibleSizeWidth/2

    self.activeScoreLb:setString(getlocal("activity_znkh2017_tab2_des1",{acPoint}))

    local barWidth=500
    local per=G_getPercentage(acPoint,needPoint)
    AddProgramTimer(self.bgLayer,ccp(centerWidth-15,posY),11,12,percentStr,"platWarProgressBg.png","taskBlueBar.png",13,1,1)
    local timerSpriteLv=self.bgLayer:getChildByTag(11)
    timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
    timerSpriteLv:setPercentage(per)
    local timerSpriteBg=self.bgLayer:getChildByTag(13)
    timerSpriteBg=tolua.cast(timerSpriteBg,"CCSprite")
    -- local scalex=barWidth/timerSpriteBg:getContentSize().width
    -- timerSpriteBg:setScaleX(scalex)
    -- timerSpriteLv:setScaleX(scalex)

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
    acPointLb:setScale(0.4)

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
        numLb:setScale(0.3)

        -- flag 1 未达成 2 可领取 3 已领取
        local flag=acZnkh2017VoApi:getLuckState(k)

        local function clickBoxHandler( ... )
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            local titleStr=getlocal("activity_openyear_baoxiang" .. k)
            if flag~=2 then
                local reward={pointPrize[k]}
                -- activity_openyear_baoxiang1
                local titleColor
                if k==1 then
                    titleColor=G_ColorWhite
                elseif k==2 then
                    titleColor=G_ColorGreen
                elseif k==3 then
                    titleColor=G_ColorBlue
                elseif k==4 then
                    titleColor=G_ColorPurple
                elseif k==5 then
                    titleColor=G_ColorOrange
                end
                local desStr=getlocal("activity_openyear_allreward_des")
                acZnkh2017VoApi:showRewardKu(titleStr,self.layerNum,reward,desStr,titleColor)
                return
            end

            local function refreshFunc(rewardlist)
                self:initOrRefreshProgress(true)
                -- if k==4 or k==5 then
                --     local desStr
                --     if k==4 then
                --         desStr="activity_openyear_chatMessage1"
                --     elseif k==5 then
                --         desStr="activity_openyear_chatMessage2"
                --     end
                --     local paramTab={}
                --     paramTab.functionStr="openyear"
                --     paramTab.addStr="i_also_want"
                --     local message={key=desStr,param={playerVoApi:getPlayerName(),getlocal("activity_openyear_title"),v,titleStr}}
                --     chatVoApi:sendSystemMessage(message,paramTab)
                -- end

                -- 此处加弹板
                local rewardItem=FormatItem(pointPrize[k],nil,true)
                for k,v in pairs(rewardItem) do
                    G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                end
                acZnkh2017VoApi:showRewardDialog(rewardItem,self.layerNum)
            end
            local action=3
            local tid=k
            acZnkh2017VoApi:socketZnkh2017(refreshFunc,3,nil,tid)

        end

        local boxScale=0.7
        local boxSp=LuaCCSprite:createWithSpriteFrameName("taskBox"..k..".png",clickBoxHandler)
        boxSp:setTouchPriority(-(self.layerNum-1)*20-2)
        boxSp:setPosition(everyWidth*k,totalHeight+45)
        timerSpriteLv:addChild(boxSp,3)
        boxSp:setScale(boxScale)

        
        if flag==2 then
            local lightSp = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
            lightSp:setPosition(everyWidth*k,totalHeight+45)
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
            -- lbBg:setContentSize(CCSizeMake(150,40))
            lbBg:setScaleX(150/lbBg:getContentSize().width)
            lbBg:setPosition(everyWidth*k,totalHeight+45)
            timerSpriteLv:addChild(lbBg,4)
            lbBg:setScale(0.7)
            local hasRewardLb=GetTTFLabel(getlocal("activity_hadReward"),22)
            hasRewardLb:setPosition(everyWidth*k,totalHeight+45)
            timerSpriteLv:addChild(hasRewardLb,5)
        end
    end
end

function acZnkh2017Tab2:addTV()
    local function nilFunc()
    end
    local bottomBg = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),nilFunc)
    bottomBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,G_VisibleSizeHeight-415))
    bottomBg:setPosition(ccp(G_VisibleSizeWidth/2,30))
    bottomBg:setAnchorPoint(ccp(0.5,0))
    self.bgLayer:addChild(bottomBg)

    local bottomSize=bottomBg:getContentSize()

    local smallTitleLb1=GetTTFLabel(getlocal("activity_ganenjiehuikui_eveTask"),25)
    smallTitleLb1:setColor(G_ColorYellowPro)
    smallTitleLb1:setAnchorPoint(ccp(0.5,0.5))
    smallTitleLb1:setPosition(ccp(bottomSize.width/2,bottomSize.height - 20 - smallTitleLb1:getContentSize().height/2))
    bottomBg:addChild(smallTitleLb1,1)

    local  titleBg1=LuaCCScale9Sprite:createWithSpriteFrameName("panelTitleBg.png",CCRect(84, 25, 1, 1),nilFunc)
    bottomBg:addChild(titleBg1)
    titleBg1:setPosition(bottomSize.width/2,bottomSize.height - 20 - smallTitleLb1:getContentSize().height/2)
    titleBg1:setContentSize(CCSizeMake(smallTitleLb1:getContentSize().width+150,math.max(smallTitleLb1:getContentSize().height,50)))

    self.taskTb=acZnkh2017VoApi:getCurrentTaskState()
    self.cellNum=SizeOfTable(self.taskTb)
	local function callBack(...)
         return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-60,bottomSize.height-75),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(40,40))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
end

function acZnkh2017Tab2:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then	 	
        return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
		tmpSize=CCSizeMake(G_VisibleSizeWidth-80,self.cellHeight)
		return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local function nilFunc()
        end
        local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),nilFunc)
        backSprie:setContentSize(CCSizeMake(
        G_VisibleSizeWidth-80,self.cellHeight))
        backSprie:ignoreAnchorPointForPosition(false)
        backSprie:setAnchorPoint(ccp(0,0))
        backSprie:setPosition(ccp(0,0))
        cell:addChild(backSprie)

        local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
        pointSp1:setPosition(ccp(5,backSprie:getContentSize().height/2))
        backSprie:addChild(pointSp1)
        local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
        pointSp2:setPosition(ccp(backSprie:getContentSize().width-5,backSprie:getContentSize().height/2))
        backSprie:addChild(pointSp2)

        local valueTb=self.taskTb[idx+1].value
        local typeStr=valueTb[1][1]
        local index=self.taskTb[idx+1].index

        local titleStr
        titleStr=getlocal("activity_chunjiepansheng_" .. typeStr .. "_title",{self.taskTb[idx+1].haveNum,valueTb[1][2]})

        local lbStarWidth=20
        local titleLb=GetTTFLabelWrap(titleStr,25,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        titleLb:setAnchorPoint(ccp(0,1))
        titleLb:setColor(G_ColorYellowPro)
        titleLb:setPosition(ccp(lbStarWidth,backSprie:getContentSize().height-15))
        backSprie:addChild(titleLb,1)

        -- 奖励描述
        local desH=(self.cellHeight - titleLb:getContentSize().height-30)/2
        local desLb=GetTTFLabelWrap(getlocal("activity_rechargeDouble_get"),22,CCSizeMake(100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        desLb:setAnchorPoint(ccp(0,0.5))
        -- desLb:setColor(G_ColorYellowPro)
        desLb:setPosition(ccp(lbStarWidth,desH))
        backSprie:addChild(desLb)

        -- 奖励展示
        local rewardItem=FormatItem(valueTb[3],nil,true)
        local taskW=0
        for k,v in pairs(rewardItem) do
            local icon = G_getItemIcon(v,100,true,self.layerNum+1,nil,self.tv,nil,nil,nil)
            icon:setTouchPriority(-(self.layerNum-1)*20-2)
            backSprie:addChild(icon)
            icon:setAnchorPoint(ccp(0,0.5))
            icon:setPosition(k*90+20, desH)
            local scale=80/icon:getContentSize().width
            icon:setScale(scale)
            taskW=k*100


            local numLabel=GetTTFLabel("x"..FormatNumber(v.num),22)
            numLabel:setAnchorPoint(ccp(1,0))
            numLabel:setPosition(icon:getContentSize().width-5, 5)
            numLabel:setScale(1/scale)
            icon:addChild(numLabel,1)
        end

        
        if index>10000 then -- 已完成(已领取)
            local alreadyLb=GetTTFLabel(getlocal("activity_hadReward"),25)
            alreadyLb:setColor(G_ColorWhite)
            alreadyLb:setPosition(ccp(backSprie:getContentSize().width-90,backSprie:getContentSize().height/2))
            backSprie:addChild(alreadyLb,1)
            alreadyLb:setColor(G_ColorGray)
        elseif index>1000 then -- 未完成
            local function goTiantang()
                if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)
                    if typeStr=="gt" then
                        self.parent:tabClick(2)
                        return
                    end
                    G_goToDialog2(typeStr,4,true)
                end

            end
            local goItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",goTiantang,nil,getlocal("activity_heartOfIron_goto"),25)
            -- goItem:setScale(0.8)
            local goBtn=CCMenu:createWithItem(goItem);
            goBtn:setTouchPriority(-(self.layerNum-1)*20-2);
            goBtn:setPosition(ccp(backSprie:getContentSize().width-95,backSprie:getContentSize().height/2))
            backSprie:addChild(goBtn)
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

                    local action="taskreward"
                    local tid=index%10

                    local function refreshFunc()
                        self:initOrRefreshProgress(true)
                        self:refresh()
                        -- 此处加弹板
                        for k,v in pairs(rewardItem) do
                            G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                        end
                        acZnkh2017VoApi:showRewardDialog(rewardItem,self.layerNum)
                    end
                    local day=acZnkh2017VoApi:getTheDayOfActive()
                    acZnkh2017VoApi:socketZnkh2017(refreshFunc,4,day,tid,nil,typeStr)

                end
            end
            -- "BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png"
            local rMenuItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",rewardTiantang,nil,getlocal("daily_scene_get"),25)
            -- rMenuItem:setScale(0.8)
            local rewardBtn=CCMenu:createWithItem(rMenuItem);
            rewardBtn:setTouchPriority(-(self.layerNum-1)*20-2);
            rewardBtn:setPosition(ccp(backSprie:getContentSize().width-95,backSprie:getContentSize().height/2))
            backSprie:addChild(rewardBtn)
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

function acZnkh2017Tab2:updateUI()
    self:refresh()
end

function acZnkh2017Tab2:refresh()
	if self.tv then
        self.taskTb=acZnkh2017VoApi:getCurrentTaskState()
		local recordPoint=self.tv:getRecordPoint()
		self.tv:reloadData()
		self.tv:recoverToRecordPoint(recordPoint)
	end
end

function acZnkh2017Tab2:tick()
end

function acZnkh2017Tab2:dispose( )
    self.layerNum=nil
end