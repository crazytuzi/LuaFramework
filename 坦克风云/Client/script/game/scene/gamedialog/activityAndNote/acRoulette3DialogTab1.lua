acRoulette3DialogTab1={}

function acRoulette3DialogTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	
    self.bgLayer=nil
    self.playBtnBg=nil
    self.playBtn=nil
    self.rewardIconList={}
    self.halo=nil           --赌博机的光圈
    self.tickIndex=nil
    self.tickInterval=5     --光圈移动的倒计时
    self.tickConst=5        --tick的间距
    self.haloPos=1          --光圈当前在第几个图标上
    self.layerNum=nil
    self.selectedTabIndex=0
    self.acRoulette3Dialog=nil
    self.rewardList={}
    self.reward=nil
    self.lastTime=nil
    self.touchEnabledSp=nil
    self.diffPoint=nil
    self.cellHeight=nil

    self.haloPos=0
    self.slowStart=false
    self.endIdx=0
    self.count=0

    -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")

    return nc
end

function acRoulette3DialogTab1:init(layerNum,selectedTabIndex,acRoulette3Dialog)
    self.layerNum=layerNum
    self.selectedTabIndex=selectedTabIndex
    self.acRoulette3Dialog=acRoulette3Dialog
    self.bgLayer=CCLayer:create()
    self:initDesc()
    self:initRoulette()
    return self.bgLayer
end

    

--初始化上半部的今日抽奖信息
function acRoulette3DialogTab1:initDesc()
    local vo=acRoulette3VoApi:getAcVo()

    local capInSet = CCRect(20, 20, 10, 10);
    local function bgClick(hd,fn,idx)
    end
    self.titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,bgClick)
    self.titleBg:setContentSize(CCSizeMake(G_VisibleSize.width-60, G_VisibleSize.height-720))
    self.titleBg:setAnchorPoint(ccp(0,1));
    self.titleBg:setPosition(ccp(30,G_VisibleSize.height-85-80))
    self.bgLayer:addChild(self.titleBg,1)

    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSize.width-70,G_VisibleSize.height-730),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv:setPosition(ccp(5,5))
    self.titleBg:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(50)

end



function acRoulette3DialogTab1:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        if self.cellHeight==nil then
            self.cellHeight=self:getCellHeight()
        end
        tmpSize=CCSizeMake(G_VisibleSize.width-70,self.cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local vo=acRoulette3VoApi:getAcVo()
        if self.cellHeight==nil then
            self.cellHeight=self:getCellHeight()
        end



        local lbWitdh=self.titleBg:getContentSize().width

   local timeSize = 25
   local reTimeSize = 23
   local timeShowWidth = 0
   local rewardHeightloc =0
   if G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="en" or G_getCurChoseLanguage()=="in" or G_getCurChoseLanguage() =="fr" then
        timeSize =23
        timeShowWidth =30
    elseif G_getCurChoseLanguage()=="ru" then
        timeSize =21
        timeShowWidth =30
        rewardHeightloc =-15
    elseif G_getCurChoseLanguage() =="ja"  then
        timeSize =19
        reTimeSize =21
        timeShowWidth =30
   end

        local timeTime=GetTTFLabel(getlocal("activity_timeLabel"),timeSize)
        timeTime:setAnchorPoint(ccp(0,1))
        timeTime:setColor(G_ColorGreen)
        timeTime:setPosition(ccp(lbWitdh*0.2-50,self.cellHeight-20))
        cell:addChild(timeTime,2)

        local timeLb=GetTTFLabelWrap(acRoulette3VoApi:getTimeStr(),reTimeSize,CCSizeMake(lbWitdh-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        timeLb:setAnchorPoint(ccp(0.5,1))
        timeLb:setPosition(ccp(lbWitdh*0.6+timeShowWidth,self.cellHeight-20))
        cell:addChild(timeLb,2)

        local rewardTimeTitle = GetTTFLabel(getlocal("recRewardTime"),timeSize)
        rewardTimeTitle:setAnchorPoint(ccp(0,1))
        rewardTimeTitle:setPosition(ccp(lbWitdh*0.2-50,self.cellHeight-45))
        cell:addChild(rewardTimeTitle)
        rewardTimeTitle:setColor(G_ColorYellowPro)

        local rechargeTimeLabel = GetTTFLabelWrap(acRoulette3VoApi:getRewardTimeStr(),reTimeSize,CCSizeMake(G_VisibleSize.width-70-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        rechargeTimeLabel:setAnchorPoint(ccp(0.5,1))
        rechargeTimeLabel:setPosition(ccp(lbWitdh*0.6+timeShowWidth,self.cellHeight-45))
        cell:addChild(rechargeTimeLabel)
        self.descLb2=rechargeTimeLabel

        local ruleLabel = GetTTFLabelWrap(getlocal("activity_ruleLabel"),25,CCSizeMake(lbWitdh-20, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        ruleLabel:setAnchorPoint(ccp(0,0.5))
        ruleLabel:setPosition(ccp(10,self.cellHeight-timeTime:getContentSize().height-timeLb:getContentSize().height-35))
        cell:addChild(ruleLabel,2)
        ruleLabel:setColor(G_ColorGreen)



        local rouletteCfg=acRoulette3VoApi:getRouletteCfg()
        local descStr=getlocal("activity_wheelFortune3_tip_1",{rouletteCfg.lotteryConsume})
        self.descLb2=GetTTFLabelWrap(descStr,22,CCSizeMake(G_VisibleSizeWidth-80,self.cellHeight),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        self.descLb2:setAnchorPoint(ccp(0,1));

        self.descLb2:setPosition(ccp(10,self.cellHeight-timeTime:getContentSize().height-timeLb:getContentSize().height-ruleLabel:getContentSize().height/2-40));
        cell:addChild(self.descLb2,2);


        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function acRoulette3DialogTab1:getCellHeight()

    local lbWitdh=self.titleBg:getContentSize().width
    local timeTime=GetTTFLabelWrap(getlocal("activity_timeLabel"),25,CCSizeMake(lbWitdh-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    local timeLb=GetTTFLabelWrap(acRoulette3VoApi:getTimeStr(),22,CCSizeMake(lbWitdh-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    local ruleLabel = GetTTFLabelWrap(getlocal("activity_ruleLabel"),25,CCSizeMake(lbWitdh-20, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    local rouletteCfg=acRoulette3VoApi:getRouletteCfg()
    local descStr=getlocal("activity_wheelFortune3_tip_1",{rouletteCfg.lotteryConsume})

    local descLb2=GetTTFLabelWrap(descStr,22,CCSizeMake(lbWitdh-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    local cellHeight=timeTime:getContentSize().height+timeLb:getContentSize().height+ruleLabel:getContentSize().height+descLb2:getContentSize().height+100
    return cellHeight
end

--初始化赌博机
function acRoulette3DialogTab1:initRoulette()
    local rouletteCfg=acRoulette3VoApi:getRouletteCfg()
    local rewardData=rouletteCfg
    local rewardPool=FormatItem(rewardData.pool,nil,true) or {}
    local oneConsume=rewardData.lotteryConsume_1x
    local tenConsume=rewardData.lotteryConsume_10x

    local capInSet = CCRect(65, 25, 1, 1);
    local function bgClick(hd,fn,idx)
    end
    local btnBg=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",capInSet,bgClick)

    local iconWidth=122
    local iconHeight=136

    btnBg:setContentSize(CCSizeMake(iconWidth*2.5,160-20))
    btnBg:setAnchorPoint(ccp(0.5,0))
    btnBg:setPosition(ccp(G_VisibleSize.width/2,250+30))
    btnBg:setTouchPriority(0)
    self.bgLayer:addChild(btnBg)
    self.playBtnBg=btnBg

    local acVo=acRoulette3VoApi:getAcVo()
    local point=acVo.totalPoint or 0

    local leftChips=GetTTFLabelWrap(getlocal("activity_wheelFortune3_mypoint"),28,CCSizeMake(btnBg:getContentSize().width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    leftChips:setAnchorPoint(ccp(0.5,0.5));
    leftChips:setPosition(ccp(btnBg:getContentSize().width/2,(btnBg:getContentSize().height-50)/2+50));
    btnBg:addChild(leftChips,2);

    self.chipNumLb=GetTTFLabel(point,30)
    self.chipNumLb:setAnchorPoint(ccp(0.5,0));
    self.chipNumLb:setPosition(ccp(btnBg:getContentSize().width/2,20));
    btnBg:addChild(self.chipNumLb,2);
    self.chipNumLb:setColor(G_ColorYellowPro)


    self.tenCost=GetTTFLabel(tenConsume,30)
    self.tenCost:setAnchorPoint(ccp(0.5,0.5));
    self.tenCost:setPosition(ccp(btnBg:getContentSize().width/2-110,0-25))
    btnBg:addChild(self.tenCost,2)
    self.tenCost:setColor(G_ColorYellowPro)

    self.gemIcon1 = CCSprite:createWithSpriteFrameName("IconGold.png")
    local iconSize=36
    self.gemIcon1:setScale(iconSize/self.gemIcon1:getContentSize().width)
    self.gemIcon1:setAnchorPoint(ccp(0.5,0.5))
    self.gemIcon1:setPosition(ccp(btnBg:getContentSize().width/2-50,0-25))
    btnBg:addChild(self.gemIcon1,2)

    self.oneCost=GetTTFLabel(oneConsume,30)
    self.oneCost:setAnchorPoint(ccp(0.5,0.5));
    self.oneCost:setPosition(ccp(btnBg:getContentSize().width/2+55,0-25))
    btnBg:addChild(self.oneCost,2)
    self.oneCost:setColor(G_ColorYellowPro)

    self.gemIcon2 = CCSprite:createWithSpriteFrameName("IconGold.png")
    self.gemIcon2:setScale(iconSize/self.gemIcon2:getContentSize().width)
    self.gemIcon2:setAnchorPoint(ccp(0.5,0.5))
    self.gemIcon2:setPosition(ccp(btnBg:getContentSize().width/2+125,0-25))
    btnBg:addChild(self.gemIcon2,2)


    local function touch()
    end
    self.touchEnabledSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch)
    self.touchEnabledSp:setAnchorPoint(ccp(0,0))
    self.touchEnabledSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
    self.touchEnabledSp:setIsSallow(true)
    self.touchEnabledSp:setTouchPriority(-(self.layerNum-1)*20-7)
    -- sceneGame:addChild(self.touchEnabledSp,self.layerNum)
    self.bgLayer:addChild(self.touchEnabledSp,self.layerNum)
    self.touchEnabledSp:setOpacity(0)
    self.touchEnabledSp:setPosition(ccp(10000,0))
    self.touchEnabledSp:setVisible(false)

    local function onPlay()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end

        if (acRoulette3VoApi:isFree())==true then
        else
            local rouletteCfg=acRoulette3VoApi:getRouletteCfg()
            local oneCost=rouletteCfg.lotteryConsume_1x
            local tenCost=rouletteCfg.lotteryConsume_10x
            if playerVoApi:getGems()<oneCost then
                GemsNotEnoughDialog(nil,nil,oneCost-playerVoApi:getGems(),self.layerNum+1,oneCost)
                do return end
            end
        end
        -- end
        local function wheelfortuneCallback(fn,data)
            self.touchEnabledSp:setVisible(true)
            self.touchEnabledSp:setPosition(ccp(0,0))
            if self.acRoulette3Dialog then
                self.acRoulette3Dialog.canClickTab=false
            end
            local ret,sData=base:checkServerData(data)
            if ret==true then
                local rouletteCfg=acRoulette3VoApi:getRouletteCfg()
                local oneCost=rouletteCfg.lotteryConsume_1x
                local tenCost=rouletteCfg.lotteryConsume_10x

                if (acRoulette3VoApi:isFree())==true then
                else
                    if playerVoApi:getGems()>=oneCost then
                        playerVoApi:setGems(playerVoApi:getGems()-oneCost)
                    end
                end

                if self and self.bgLayer then
                    if sData and sData.data and sData.data.wheelFortune3 and sData.data.wheelFortune3.active then
                        local vo=acRoulette3VoApi:getAcVo()
                        local oldPoint=vo.totalPoint

                        local updateData=sData.data.wheelFortune3.active
                        acRoulette3VoApi:updateData(updateData)
                        -- end

                        local newVo=acRoulette3VoApi:getAcVo()
                        local newPoint=newVo.totalPoint

                        self.diffPoint=newPoint-oldPoint
                        if self.diffPoint<0 then
                            self.diffPoint=0
                        end
                    end
                    self.playBtn:setEnabled(false)
                    self.freeBtn:setEnabled(false)
                    self.playTenBtn:setEnabled(false)
                    if sData and sData.data and sData.data.wheelFortune3 and sData.data.wheelFortune3.reward then
                        self.reward=FormatItem(sData.data.wheelFortune3.reward) or {}
                        for k,v in pairs(self.reward) do
                            G_addPlayerAward(v.type,v.key,v.id,tonumber(v.num),nil,true)
                        end
                        self:play()

                    end
                end
            else
                if self and self.touchEnabledSp then
                    self.touchEnabledSp:setVisible(false)
                    self.touchEnabledSp:setPosition(ccp(10000,0))
                end
                if self.acRoulette3Dialog then
                    self.acRoulette3Dialog.canClickTab=true
                end
            end
        end

        socketHelper:activeWheelfortune3(1,wheelfortuneCallback)

    end
    local textSize = 25
    if platCfg.platCfgBMImage[G_curPlatName()]~=nil or G_curPlatName()=="androidzhongshouyouru" or G_curPlatName()=="12" then
        textSize=20
    end
    self.playBtn = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",onPlay,nil,getlocal("activity_wheelFortune_reward_btn"),textSize)
    self.playBtn:setAnchorPoint(ccp(0.5,0))
    local playBtnMenu=CCMenu:createWithItem(self.playBtn)
    playBtnMenu:setAnchorPoint(ccp(0.5,0))
    playBtnMenu:setPosition(ccp(btnBg:getContentSize().width/2+87,0-self.playBtn:getContentSize().height-50))
    playBtnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    btnBg:addChild(playBtnMenu,2)
    self.playBtn:setVisible(false)
    self.playBtn:setEnabled(false)

    self.freeBtn = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onPlay,nil,getlocal("daily_lotto_tip_2"),textSize)
    self.freeBtn:setAnchorPoint(ccp(0.5,0))
    local freeBtnMenu=CCMenu:createWithItem(self.freeBtn)
    freeBtnMenu:setAnchorPoint(ccp(0.5,0))
    freeBtnMenu:setPosition(ccp(btnBg:getContentSize().width/2+87,0-self.playBtn:getContentSize().height-50))
    freeBtnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    btnBg:addChild(freeBtnMenu,2)
    self.freeBtn:setVisible(false)
    self.freeBtn:setEnabled(false)

    if acRoulette3VoApi:isFree()==true then
        self.freeBtn:setVisible(true)
        self.freeBtn:setEnabled(true)
        self.oneCost:setVisible(false)
        self.gemIcon2:setVisible(false)
    else
        self.playBtn:setVisible(true)
        self.playBtn:setEnabled(true)
        self.oneCost:setVisible(true)
        self.gemIcon2:setVisible(true)
    end

    if acRoulette3VoApi:acIsStop() then
        self.playBtn:setEnabled(false)
        self.freeBtn:setEnabled(false)
    end

    local function onTenPlay()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end

        if (acRoulette3VoApi:isFree())==true then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_wheelFortune3_has_free"),30)
            do return end
        end

        local rouletteCfg=acRoulette3VoApi:getRouletteCfg()
        local oneCost=rouletteCfg.lotteryConsume_1x
        local tenCost=rouletteCfg.lotteryConsume_10x

        if playerVoApi:getGems()<tenCost then
            GemsNotEnoughDialog(nil,nil,tenCost-playerVoApi:getGems(),self.layerNum+1,tenCost)
            do return end
        end

        local function wheelfortuneCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then

                if playerVoApi:getGems()>=tenCost then
                    playerVoApi:setGems(playerVoApi:getGems()-tenCost)
                end

                if self and self.bgLayer then
                    if sData and sData.data and sData.data.wheelFortune3 and sData.data.wheelFortune3.active then
                        local updateData=sData.data.wheelFortune3.active
                        acRoulette3VoApi:updateData(updateData)
                    end

                    if sData and sData.data and sData.data.wheelFortune3 and sData.data.wheelFortune3.report then
                        local report=sData.data.wheelFortune3.report or {}
                        local cfg=acRoulette3VoApi:getRouletteCfg()
                        local content={}
                        for k,v in pairs(report) do
                            local awardTb=FormatItem(v[1],nil,true) or {}
                            for m,n in pairs(awardTb) do
                                local award=n or {}
                                local index=acRoulette3VoApi:getIndexByNameAndType(award.name,award.type,tonumber(award.num))
                                if index and index>0 then
                                    table.insert(content,{award=award,point=v[2],index=index})
                                end
                                G_addPlayerAward(award.type,award.key,award.id,award.num,nil,true)
                            end
                        end
                        if content and SizeOfTable(content)>0 then
                            local function confirmHandler(awardIdx)
                                if awardIdx and awardIdx>0 and awardIdx then
                                    if self.rewardIconList[awardIdx] then
                                        self:showFlicker(self.rewardIconList[awardIdx])
                                    end
                                else
                                    self:hideFlicker()
                                end
                            end
                            smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_equipSearch_total"),content,nil,true,self.layerNum+1,confirmHandler,true,true)
                        end
                    end

                    if self.acRoulette3Dialog then
                        self.acRoulette3Dialog:refresh()
                    end
                end
            end
        end
        socketHelper:activeWheelfortune3(5,wheelfortuneCallback)
    end

    self.playTenBtn = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",onTenPlay,nil,getlocal("ten_roulette_btn"),textSize)
    self.playTenBtn:setAnchorPoint(ccp(0.5,0))
    local playTenBtnMenu=CCMenu:createWithItem(self.playTenBtn)
    playTenBtnMenu:setAnchorPoint(ccp(0.5,0))
    playTenBtnMenu:setPosition(ccp(btnBg:getContentSize().width/2-90,0-self.playBtn:getContentSize().height-50))
    playTenBtnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    btnBg:addChild(playTenBtnMenu,2)

    if acRoulette3VoApi:acIsStop() then
        self.playTenBtn:setEnabled(false)
    end

    local wSpace=30
    local hSpace=-10
    local xSpace=30*3
    local ySpace=30*3+20
    -- for i=1,12 do
    for k,v in pairs(rewardPool) do
        local i=k
        if v then
            -- local iconBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,bgClick)
            -- iconBg:setContentSize(CCSizeMake(iconWidth,iconHeight))
            -- iconBg:setAnchorPoint(ccp(0,0))
            -- self.bgLayer:addChild(iconBg)
            local icon=self:initRewardIcon(iconBg,i,v)
            -- self.rewardIconList[i]=iconBg
            self.rewardIconList[i]=icon
            self.rewardList[i]=v
            if(i<5)then
                icon:setPosition(ccp((iconWidth+wSpace)*(i-1)+xSpace,(iconHeight+hSpace)*3+hSpace+ySpace))
            elseif(i==5)then
                icon:setPosition(ccp((iconWidth+wSpace)*3+xSpace,(iconHeight+hSpace)*2+hSpace+ySpace))
            elseif(i==6)then
                icon:setPosition(ccp((iconWidth+wSpace)*3+xSpace,iconHeight+hSpace*2+ySpace))
            elseif(i<11)then
                icon:setPosition(ccp((iconWidth+wSpace)*(10-i)+xSpace,hSpace*1+ySpace))
            elseif(i==11)then
                icon:setPosition(ccp(xSpace,iconHeight+hSpace*2+ySpace))
            elseif(i==12)then
                icon:setPosition(ccp(xSpace,(iconHeight+hSpace)*2+hSpace+ySpace))
            end

        end
    end
    local function nilFunc()
    end
    self.halo=LuaCCScale9Sprite:createWithSpriteFrameName("guide_res.png",CCRect(28,28,2,2),nilFunc)
    self.halo:setContentSize(CCSizeMake(100+8,100+8))
    self.halo:setAnchorPoint(ccp(0.5,0.5))
    self.halo:setTouchPriority(0)
    self.halo:setVisible(false)
    local tx,ty=self.rewardIconList[1]:getPosition()
    self.halo:setPosition(tx,ty)
    self.bgLayer:addChild(self.halo,3)
end

function acRoulette3DialogTab1:showFlicker(icon)
    if newGuidMgr:isNewGuiding() then
        do return end
    end
    if self and self.bgLayer and icon then
        local iconSize=100
        local px,py=icon:getPosition()
        -- px=px-4
        -- py=py+2
        if self.flicker==nil then
            local pzFrameName="RotatingEffect1.png"
            self.flicker=CCSprite:createWithSpriteFrameName(pzFrameName)
            local m_iconScaleX=(iconSize+8)/self.flicker:getContentSize().width
            local m_iconScaleY=(iconSize+8)/self.flicker:getContentSize().height
            local pzArr=CCArray:create()
            for kk=1,20 do
                local nameStr="RotatingEffect"..kk..".png"
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                pzArr:addObject(frame)
            end
            local animation=CCAnimation:createWithSpriteFrames(pzArr)
            animation:setDelayPerUnit(0.1)
            local animate=CCAnimate:create(animation)
            self.flicker:setAnchorPoint(ccp(0.5,0.5))
            self.flicker:setScaleX(m_iconScaleX)
            self.flicker:setScaleY(m_iconScaleY)
            self.flicker:setPosition(ccp(px,py))
            self.bgLayer:addChild(self.flicker,5)
            local repeatForever=CCRepeatForever:create(animate)
            self.flicker:runAction(repeatForever)
        else
            self.flicker:setPosition(ccp(px,py))
            if self.flicker:isVisible()==false then
                self.flicker:setVisible(true)
                local pzArr=CCArray:create()
                for kk=1,20 do
                    local nameStr="RotatingEffect"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    pzArr:addObject(frame)
                end
                local animation=CCAnimation:createWithSpriteFrames(pzArr)
                animation:setDelayPerUnit(0.1)
                local animate=CCAnimate:create(animation)
                local repeatForever=CCRepeatForever:create(animate)
                self.flicker:runAction(repeatForever)
            end
        end
    end
end
function acRoulette3DialogTab1:hideFlicker()
    if self and self.flicker then
        self.flicker:stopAllActions()
        self.flicker:setVisible(false)
    end
end

function acRoulette3DialogTab1:initRewardIcon(iconBg,i,item)
    -- local bgSize=iconBg:getContentSize();   

    local function showInfoHandler(hd,fn,idx)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if item and item.key and item.name and item.num then
            local strParam={}
            local cfg=acRoulette3VoApi:getRouletteCfg()
            -- local formatKey
            -- if item.type=="e" then
            --     formatKey="accessory_"..item.key
            -- elseif item.type=="p" then
            --     formatKey="props_"..item.key
            -- elseif item.type=="o" then
            --     formatKey="troops_"..item.key
            -- else
            --     formatKey="userinfo_"..item.key
            -- end
            -- if cfg and cfg.res4point and cfg.res4point[formatKey] then
            --     local rangeArr=cfg.res4point[formatKey][3]
            --     if rangeArr and SizeOfTable(rangeArr)>0 then
            --         local minPoint=tonumber(rangeArr[1]) or 0
            --         local maxPoint=tonumber(rangeArr[SizeOfTable(rangeArr)]) or 0
            --         strParam={minPoint,maxPoint}
            --     end
            -- end
            if cfg and cfg.res4point and item.index and cfg.res4point[item.index] then
                local rangeArr=cfg.res4point[item.index]
                if rangeArr and SizeOfTable(rangeArr)>0 then
                    local minPoint=tonumber(rangeArr[1]) or 0
                    local maxPoint=tonumber(rangeArr[SizeOfTable(rangeArr)]) or 0
                    strParam={minPoint,maxPoint}
                end
            end
            local addDesc=getlocal("activity_wheelFortune_point_range",strParam)
            
            local isHasDesc=true
            for i=1,4 do
                if item.key=="r"..i then
                    item.desc=addDesc
                    isHasDesc=false
                end
            end

            local isAddBg=false
            if item.key=="energy" then
                isAddBg=true
            end
            if isHasDesc==true then
                propInfoDialog:create(sceneGame,item,self.layerNum+1,nil,isAddBg,addDesc)
            else
                propInfoDialog:create(sceneGame,item,self.layerNum+1,true,isAddBg,nil,G_ColorYellow)
            end
        end
    end
    local icon
    local v=item
    if v.type=="e" then
        if v.eType=="a" then
            icon=accessoryVoApi:getAccessoryIcon(v.id,60,80,showInfoHandler)
        elseif v.eType=="f" then
            icon=accessoryVoApi:getFragmentIcon(v.id,60,80,showInfoHandler)
            -- iconScaleX=0.8
            -- iconScaleY=0.8
        elseif v.eType=="p" then
            icon=GetBgIcon(item.pic,showInfoHandler,nil,80,80)
        end
    elseif v.type=="p" and v.equipId then
        local eType=string.sub(v.equipId,1,1)
        if eType=="a" then
            icon=accessoryVoApi:getAccessoryIcon(v.equipId,60,80,showInfoHandler)
        elseif eType=="f" then
            icon=accessoryVoApi:getFragmentIcon(v.equipId,60,80,showInfoHandler)
        else
            icon=GetBgIcon(item.pic,showInfoHandler,nil,80,80)
        end
    else
        if item.key=="energy" then
            icon = GetBgIcon(item.pic,showInfoHandler)
        else
            icon = LuaCCSprite:createWithSpriteFrameName(item.pic,showInfoHandler)
        end
    end
    local scale=100/icon:getContentSize().width
    icon:setAnchorPoint(ccp(0.5,0.5))
    -- icon:setPosition(ccp(bgSize.width/2,bgSize.height-icon:getContentSize().height/2*scale-5))
    icon:setIsSallow(false)
    icon:setTouchPriority(-(self.layerNum-1)*20-4)
    icon:setTag(123+i)
    icon:setScale(scale)

    if item.type=="p" and (item.key=="p36" or item.key=="p30") then

    else
        local nameLb=GetTTFLabel("x"..item.num,22)
        nameLb:setAnchorPoint(ccp(1,0))
        nameLb:setPosition(ccp(icon:getContentSize().width-10,5))
        nameLb:setScale(1/scale)
        icon:addChild(nameLb)
    end

    -- iconBg:addChild(icon)
    self.bgLayer:addChild(icon,1)
    return icon
end

function acRoulette3DialogTab1:play()
    self.tickIndex=0
    self.tickInterval=3
    self.tickConst=3
    self.intervalNum=3 --fasttick间隔 3帧一次

    self.haloPos=0
    self.slowStart=false
    
    self.endIdx=0
    for k,v in pairs(self.rewardList) do
        if self.rewardList and v and v.type==self.reward[1].type and v.key==self.reward[1].key and v.num==self.reward[1].num then
            self.endIdx=k
        end
    end

    self.slowTime=4

    if self.endIdx>0 then
        self.count=12*self.tickConst --转1圈之后开始减速
        if self.endIdx>self.slowTime then
            self.slowStartIndex=self.endIdx-self.slowTime
        else
            self.count=self.count-((self.slowTime-1)*self.tickConst)
            self.slowStartIndex=self.endIdx-self.slowTime+12
        end
        --base:addNeedRefresh(self)
    else
        self:refresh()
    end

end

function acRoulette3DialogTab1:fastTick()
    if self.tickIndex ~=nil then
        self.tickIndex=self.tickIndex+1
        self.tickInterval=self.tickInterval-1
        if(self.tickInterval<=0)then
            self.tickInterval=self.tickConst
            self.haloPos=self.haloPos+1
            if(self.haloPos>12)then
                self.haloPos=self.haloPos-12
                -- self.haloPos=1
            end
            local tx,ty=self.rewardIconList[self.haloPos]:getPosition()
            self.halo:setPosition(tx,ty)
            if self.halo:isVisible()==false then
                self.halo:setVisible(true)
            end

            if (self.tickIndex>=self.count) then 
                if(self.haloPos==self.slowStartIndex)then
                    self.slowStart=true
                end
                if (self.slowStart) then

                        if (self.tickConst<self.tickConst*3) then
                            self.tickConst=self.tickConst+self.tickConst
                        elseif self.tickConst<self.intervalNum*4 then
                            self.tickConst=self.tickConst+self.tickConst*2
                        end
                end
                if self.endIdx>0 and (self.haloPos==self.endIdx) and self.tickIndex~=self.count then
                    local function playEnd()
                        self.tickIndex =nil
                        --base:removeFromNeedRefresh(self)
                        self:playEndEffect()
                    end
                    local delay=CCDelayTime:create(0.5)
                    local callFunc=CCCallFuncN:create(playEnd)
                    
                    local acArr=CCArray:create()
                    acArr:addObject(delay)
                    acArr:addObject(callFunc)
                    local seq=CCSequence:create(acArr)
                    self.bgLayer:runAction(seq)

                    
                end
            end


        end
    end
end

function  acRoulette3DialogTab1:playEndEffect()

    local bgSize=self.rewardIconList[self.haloPos]:getContentSize()
    local item=self.rewardList[self.haloPos]
    
    self.rewardIconBg = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
    self.rewardIconBg:setAnchorPoint(ccp(0.5,0.5))
    local tx,ty=self.rewardIconList[self.haloPos]:getPosition()
    -- tx=tx+bgSize.width/2
    -- ty=ty+bgSize.height/2
    self.rewardIconBg:setPosition(tx,ty)


    local rewardIcon=self.rewardIconList[self.haloPos]:getChildByTag(123+self.haloPos)
    -- self.rewardIconList[self.haloPos]:removeChild(rewardIcon,true)
    if item.key=="energy" then
        rewardIcon = GetBgIcon(item.pic)
    else
        rewardIcon = CCSprite:createWithSpriteFrameName(item.pic)
    end
    rewardIcon:setAnchorPoint(ccp(0.5,0.5))
    rewardIcon:setPosition(ccp(self.rewardIconBg:getContentSize().width/2,self.rewardIconBg:getContentSize().height/2))
    self.rewardIconBg:addChild(rewardIcon)
    self.bgLayer:addChild(self.rewardIconBg,4)
    local scale=100/rewardIcon:getContentSize().width
    rewardIcon:setScale(scale)

    if self.maskSp==nil then
        local function tmpFunc()
        end
        self.maskSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),tmpFunc)
        self.maskSp:setOpacity(255)
        local size=CCSizeMake(G_VisibleSize.width-60,500)
        self.maskSp:setContentSize(size)
        self.maskSp:setAnchorPoint(ccp(0.5,0.5))
        self.maskSp:setPosition(ccp(G_VisibleSize.width/2,290))
        self.maskSp:setIsSallow(true)
        self.maskSp:setTouchPriority(-(self.layerNum-1)*20-5)
        self.bgLayer:addChild(self.maskSp,3)
    else
        self.maskSp:setVisible(true)
        self.maskSp:setPosition(ccp(G_VisibleSize.width/2,290))
    end

    if self.confirmBtn==nil then
        local function hideMask()
            if self then
                -- self.bgLayer:removeChild(self.rewardIconBg,true)
                self.rewardIconBg:removeFromParentAndCleanup(true)
                self.rewardIconBg=nil

                if self.maskSp then
                    self.maskSp:setPosition(ccp(10000,0))
                    self.maskSp:setVisible(false)
                end
                if self.confirmBtn then
                    self.confirmBtn:setEnabled(false)
                    self.confirmBtn:setVisible(false)
                end
                if self.halo then
                    self.halo:setVisible(false)
                end
                if self.nameLb then
                    self.nameLb:setVisible(false)
                end
                if self.itemDescLb then
                    self.itemDescLb:setVisible(false)
                end
            end
        end
        self.confirmBtn=GetButtonItem("BigBtnBlue.png","BigBtnBlue_Down.png","BigBtnBlue_Down.png",hideMask,4,getlocal("confirm"),25)
        self.confirmBtn:setAnchorPoint(ccp(0.5,0.5))
        local boxSpMenu3=CCMenu:createWithItem(self.confirmBtn)
        boxSpMenu3:setPosition(ccp(self.maskSp:getContentSize().width/2,self.maskSp:getContentSize().height/2-160))
        boxSpMenu3:setTouchPriority(-(self.layerNum-1)*20-6)
        self.maskSp:addChild(boxSpMenu3,2)

        self.confirmBtn:setEnabled(false)
        self.confirmBtn:setVisible(false)
    else
        self.confirmBtn:setEnabled(false)
        self.confirmBtn:setVisible(false)
    end

    local pointStr=getlocal("activity_wheelFortune_subTitle_3").." x"..self.diffPoint
    if self.nameLb==nil then
        -- self.nameLb=GetTTFLabelWrap(item.name,22,CCSizeMake(G_VisibleSizeWidth-180,300),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        self.nameLb=GetTTFLabel(item.name.." x"..item.num..","..pointStr,25)
        self.nameLb:setAnchorPoint(ccp(0.5,1))
        self.nameLb:setPosition(ccp(self.maskSp:getContentSize().width/2,self.maskSp:getContentSize().height/2+60))
        self.maskSp:addChild(self.nameLb,2)
        self.nameLb:setVisible(false)
    else
        self.nameLb:setString(item.name.." x"..item.num..","..pointStr)
        self.nameLb:setVisible(false)
    end

    -- if self.pointLb==nil then
    --     self.pointLb=GetTTFLabelWrap(pointStr,22,CCSizeMake(G_VisibleSizeWidth-180,300),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    --     -- self.itemDescLb=GetTTFLabel(item.name,22)
    --     self.pointLb:setAnchorPoint(ccp(0.5,1))
    --     self.pointLb:setPosition(ccp(self.maskSp:getContentSize().width/2,self.maskSp:getContentSize().height/2+40))
    --     self.maskSp:addChild(self.pointLb,2)
    --     self.pointLb:setVisible(false)
    -- else
    --     self.pointLb:setString(pointStr)
    --     self.pointLb:setVisible(false)
    -- end

    local isShowDesc=true
    for i=1,4 do
        if item.key=="r"..i then
            isShowDesc=false
        end
    end
    if isShowDesc==true then
        if self.itemDescLb==nil then
            self.itemDescLb=GetTTFLabelWrap(getlocal(item.desc),22,CCSizeMake(G_VisibleSizeWidth-180,300),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
            self.itemDescLb:setAnchorPoint(ccp(0.5,1))
            self.itemDescLb:setPosition(ccp(self.maskSp:getContentSize().width/2,self.maskSp:getContentSize().height/2+20))
            self.maskSp:addChild(self.itemDescLb,2)
            self.itemDescLb:setVisible(false)
        else
            self.itemDescLb:setString(getlocal(item.desc))
            self.itemDescLb:setVisible(false)
        end
    else
        if self.itemDescLb then
            self.itemDescLb:setVisible(false)
        end
    end

    local function playEndCallback()
        local str=G_showRewardTip(self.reward,false)
        if self.diffPoint and self.diffPoint>0 then
            str=str..","..getlocal("activity_wheelFortune_subTitle_3").." x"..self.diffPoint
        end
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,28)

        if self and self.acRoulette3Dialog then
            self.acRoulette3Dialog:refresh()
        end

        if self.playTenBtn then
            self.playTenBtn:setEnabled(true)
        end

        if self.confirmBtn then
            self.confirmBtn:setEnabled(true)
            self.confirmBtn:setVisible(true)
        end
        
        if self.touchEnabledSp then
            self.touchEnabledSp:setVisible(false)
            self.touchEnabledSp:setPosition(ccp(10000,0))
        end
        if self.acRoulette3Dialog then
            self.acRoulette3Dialog.canClickTab=true
        end

        if self.nameLb then
            self.nameLb:setVisible(true)
        end
        if isShowDesc==true then
            if self.itemDescLb then
                self.itemDescLb:setVisible(true)
            end
        end
    end

    local delay1=CCDelayTime:create(0.3)
    local scale1=CCScaleTo:create(0.4,150/rewardIcon:getContentSize().width/scale)
    local scale2=CCScaleTo:create(0.4,100/rewardIcon:getContentSize().width/scale)
    -- local tx,ty=self.playBtnBg:getPosition()
    local tx,ty=self.maskSp:getPosition()
    local mvTo=CCMoveTo:create(0.3,ccp(tx,ty+150))
    local scale3=CCScaleTo:create(0.1,200/rewardIcon:getContentSize().width/scale)
    local scale4=CCScaleTo:create(0.2,120/rewardIcon:getContentSize().width/scale)
    local delay2=CCDelayTime:create(0.2)
    local callFunc=CCCallFuncN:create(playEndCallback)
    
    local acArr=CCArray:create()
    acArr:addObject(delay1)
    -- acArr:addObject(scale1)
    -- acArr:addObject(scale2)
    acArr:addObject(mvTo)
    acArr:addObject(scale3)
    acArr:addObject(scale4)
    acArr:addObject(delay2)
    acArr:addObject(callFunc)
    local seq=CCSequence:create(acArr)
    self.rewardIconBg:runAction(seq)
end


function acRoulette3DialogTab1:tick()
end

function acRoulette3DialogTab1:subtick()
end

function acRoulette3DialogTab1:refresh()
    if self and self.bgLayer then
        local acVo=acRoulette3VoApi:getAcVo()
        local point=acVo.totalPoint or 0
        if self.chipNumLb and point then
            self.chipNumLb:setString(point)
        end

        if (acRoulette3VoApi:isFree())==true then
            if self.playBtn then
                self.playBtn:setVisible(false)
                self.playBtn:setEnabled(false)
            end
            if self.freeBtn then
                self.freeBtn:setVisible(true)
                self.freeBtn:setEnabled(true)
            end
            if self.oneCost then
                self.oneCost:setVisible(false)
            end
            if self.gemIcon2 then
                self.gemIcon2:setVisible(false)
            end
        else
            if self.playBtn then
                self.playBtn:setVisible(true)
                self.playBtn:setEnabled(true)
            end
            if self.freeBtn then
                self.freeBtn:setVisible(false)
                self.freeBtn:setEnabled(false)
            end
            if self.oneCost then
                self.oneCost:setVisible(true)
            end
            if self.gemIcon2 then
                self.gemIcon2:setVisible(true)
            end
        end

        -- if self.playBtn and (acRoulette3VoApi:checkCanPlay())==true then
        --     self.playBtn:setEnabled(true)
        -- else
        --     self.playBtn:setEnabled(false)
        -- end

        -- if self.playTenBtn and (acRoulette3VoApi:checkCanTenPlay())==true then
        --     self.playTenBtn:setEnabled(true)
        -- else
        --     self.playTenBtn:setEnabled(false)
        -- end

        if acRoulette3VoApi:acIsStop() then
            if self.playBtn then
                self.playBtn:setEnabled(false)
            end
            if self.freeBtn then
                self.freeBtn:setEnabled(false)
            end
            if self.playTenBtn then
                self.playTenBtn:setEnabled(false)
            end
        end

        if self.cellHeight==nil then
            self.cellHeight=self:getCellHeight()
        end
        local vo=acRoulette3VoApi:getAcVo()
        if self.titleBg then
            if self.numLb and vo and vo.consume then
                self.numLb:setString(vo.consume or 0)
            end
            if self.gemIcon and self.descLb and self.numLb then
                local scale=1.5
                self.gemIcon:setPosition(ccp(15+self.descLb:getContentSize().width+self.numLb:getContentSize().width+self.gemIcon:getContentSize().width/2*scale,self.cellHeight-20))
            end
            if self.descLb1 then
                local usedNum=acRoulette3VoApi:getUsedNum()
                if usedNum then
                    self.descLb1:setString(getlocal("activity_wheelFortune_reward_count",{usedNum}))
                end
            end
        end

    end
    
end

function acRoulette3DialogTab1:dispose()
    --base:removeFromNeedRefresh(self)
    if self.touchEnabledSp then
        self.touchEnabledSp:removeFromParentAndCleanup(true)
        self.touchEnabledSp=nil
    end
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
    self.selectedTabIndex=nil
    self.rewardList=nil
    self.reward=nil
    self.lastTime=nil
    self.diffPoint=nil
    self.cellHeight=nil
    self.halo=nil
    self.tickIndex=nil
    self.tickInterval=nil
    self.tickConst=nil
    self.haloPos=nil   
    self.haloPos=nil
    self.slowStart=false
    self.endIdx=nil
    self.count=nil
    self=nil
end






