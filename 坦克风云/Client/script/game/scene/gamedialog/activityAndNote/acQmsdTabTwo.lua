acQmsdTabTwo={

}

function acQmsdTabTwo:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    nc.tv=nil
    nc.bgLayer=nil
    nc.layerNum=layerNum
    nc.cellHeight=145
    nc.cellNums=0
    nc.selfRechargeNums = 0
    nc.isTodayFlag = acQmsdVoApi:isToday()
    return nc;
end
function acQmsdTabTwo:dispose( )
    self.layerNum = nil
    self.bgLayer = nil
    self.tv = nil
    self.cellHeight = nil
    self.cellNums = nil
    self.selfRechargeNums = nil
end

function acQmsdTabTwo:init(parent)
    self.activeName=acQmsdVoApi:getActiveName()
    self.bgLayer=CCLayer:create()
    self.parent=parent

    self.singleNeedGemsTb,self.singleRewardTb = acQmsdVoApi:getSingleRechargeReward( )
    self.cellNums = SizeOfTable(self.singleNeedGemsTb)
    self.selfRechargeNums = acQmsdVoApi:getSingleRechargeNums( )
    self:initUp()
    self:initDown()
    self:initCenter()
    -- self:initTableView()
    return self.bgLayer
end

function acQmsdTabTwo:initUp( )
    local startH=G_VisibleSizeHeight - 160
    -- print("军团个人积分排名~~~~~",allianceVoApi:isHasAlliance())
    local iphone5NeedHeight = G_isIphone5() and 10 or 0
    local upBg = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),function( ) end)
    upBg:setContentSize(CCSizeMake(616,G_VisibleSizeHeight*0.15 + iphone5NeedHeight))
    upBg:setPosition(ccp(G_VisibleSizeWidth*0.5,startH))
    upBg:setAnchorPoint(ccp(0.5,1))
    -- upBg:setOpacity(0)
    upBgWidth = upBg:getContentSize().width
    upBgHeight = upBg:getContentSize().height
    self.upBg = upBg
    self.bgLayer:addChild(upBg)


    local image=CCSprite:createWithSpriteFrameName("goldAndTankBg_1.jpg")
    image:setPosition(getCenterPoint(upBg))
    image:setScaleX(upBgWidth/image:getContentSize().width)
    image:setScaleY(upBgHeight/image:getContentSize().height)
    upBg:addChild(image)

    local image2 = CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")
    image2:setPosition(getCenterPoint(upBg))
    image2:setScaleX(upBgWidth/image2:getContentSize().width)
    image2:setScaleY(upBgHeight/image2:getContentSize().height)
    image2:setOpacity(150)
    upBg:addChild(image2)

    -- local function onLoadImage(fn,image)
    --     if(self.bgLayer and tolua.cast(self.bgLayer,"CCLayer"))then
    --         -- image:setScaleX((upBgWidth - 20)/image:getContentSize().width)
    --         image:setScaleX(upBgWidth/image:getContentSize().width)
    --         image:setScaleY(upBgHeight/image:getContentSize().height)
    --         -- image:setOpacity(130)
    --         image:setAnchorPoint(ccp(0.5,0.5))
    --         image:setPosition(getCenterPoint(upBg))
    --         upBg:addChild(image)
    --     end
    -- end
    -- local webImage=LuaCCWebImage:createWithURL(G_downloadUrl("active/znqd2017/anniversary2017Bg2.png"),onLoadImage)
    local headReward = acQmsdVoApi:getHeadReward( )
    local function showNewPropInfo()
        G_showNewPropInfo(self.layerNum+1,true,true,nil,headReward[1])
        return false
    end
    local headIcon = G_getItemIcon(headReward[1],100,true,self.layerNum+1,showNewPropInfo,self.tv,nil,nil,nil)
    headIcon:setTouchPriority(-(self.layerNum-1)*20-2)
    headIcon:setAnchorPoint(ccp(0,0.5))
    headIcon:setPosition(ccp(10,upBgHeight*0.5))
    upBg:addChild(headIcon,1)
    local lbPosx = headIcon:getPositionX() + headIcon:getContentSize().width + 5

    local addPosy,strSize4,curLan,strSize5 = 25,21,G_getCurChoseLanguage(),21
    if curLan =="cn" or curLan =="ja" or curLan =="ko" or curLan =="tw" then
        addPosy = 5
        strSize4 = 24
        strSize5 = 24
    end

    local upDesc = GetTTFLabelWrap(getlocal("activity_qmsd_title_tab2_upDes"),strSize5,CCSizeMake(upBgWidth - headIcon:getContentSize().width - 40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
    upDesc:setAnchorPoint(ccp(0,1))
    upDesc:setPosition(ccp(lbPosx,headIcon:getPositionY() + headIcon:getContentSize().height*0.5 + addPosy))
    upBg:addChild(upDesc,1)

    local upDesc2,posy2 = nil ,0
    if curLan =="cn" or curLan =="ja" or curLan =="ko" or curLan =="tw" then
       upDesc2 = GetTTFLabel(getlocal("activity_qmsd_title_tab2_upDes2"),strSize4,"Helvetica-bold")
    else
        upDesc2 = GetTTFLabelWrap(getlocal("activity_qmsd_title_tab2_upDes2"),strSize4,CCSizeMake(upBgWidth - headIcon:getContentSize().width - 40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
        posy2 = 5
    end
    upDesc2:setAnchorPoint(ccp(0,1))
    upDesc2:setPosition(ccp(lbPosx,headIcon:getPositionY() - 5 + posy2))
    -- upDesc2:setColor(G_ColorOrange)
    upBg:addChild(upDesc2,1)    
    local strSize4 = 21
    if curLan =="cn" or curLan =="ja" or curLan =="ko" or curLan =="tw" then
        strSize4 = 24
    elseif G_isIOS() == false then
        strSize4 = 19
    end
    local isGetedIcon = acQmsdVoApi:isGetIconFunc()
    local nodata,needGems = acQmsdVoApi:getHeadReward( )
    self.selfRechargeNums = needGems > self.selfRechargeNums and self.selfRechargeNums or needGems
    local todayRechargeStr = GetTTFLabel(getlocal("todayRecharged",{isGetedIcon == 1 and needGems or self.selfRechargeNums,needGems}),strSize4,"Helvetica-bold")
    todayRechargeStr:setAnchorPoint(ccp(0,0.5))
    todayRechargeStr:setPosition(ccp(lbPosx,headIcon:getPositionY() - headIcon:getContentSize().height*0.5))
    upBg:addChild(todayRechargeStr,1)
    self.todayRechargeStr = todayRechargeStr

    local goldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
    goldIcon:setAnchorPoint(ccp(0,0.5))
    goldIcon:setPosition(ccp(todayRechargeStr:getPositionX() + todayRechargeStr:getContentSize().width  + 5,todayRechargeStr:getPositionY()))
    upBg:addChild(goldIcon,1)
    self.goldIcon = goldIcon

    local needPos = ccp(upBg:getContentSize().width*0.85,headIcon:getPositionY() - headIcon:getContentSize().height*0.5)

    if self.selfRechargeNums >= needGems then
        -- local isGetedIcon = acQmsdVoApi:isGetIconFunc()
        local hadReward = GetTTFLabel(getlocal("activity_hadReward"),24,"Helvetica-bold")
        hadReward:setAnchorPoint(ccp(0.5,0.5))
        hadReward:setPosition(needPos)
        upBg:addChild(hadReward,1)
        hadReward:setVisible(false)
        self.hadReward = hadReward
        if isGetedIcon == 1 then--activity_hadReward
            hadReward:setVisible(true)
        else
            self:initGetIconBtn(needPos,upBg)
        end
    else
        local hadStr = "noReached"
        if isGetedIcon == 1 then--activity_hadReward
             hadStr ="activity_hadReward"
        end

        local hadReward = GetTTFLabel(getlocal(hadStr),24,"Helvetica-bold")
        hadReward:setAnchorPoint(ccp(0.5,0.5))
        hadReward:setPosition(needPos)
        upBg:addChild(hadReward,1)
    end    
end
function acQmsdTabTwo:initGetIconBtn(needPos,upBg)--领取头像
    local function rewardTiantang()
        if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            -- self.rMenuItem:setEnabled(false)
            self.rMenuItem:setVisible(false)
            self.hadReward:setVisible(true)

            local function refreshFunc()---------------------------------
                local headReward = acQmsdVoApi:getHeadReward( )
                for k,v in pairs(headReward) do
                    G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                end
                G_showRewardTip(headReward)
            end
            local action = 3
            local cmdStr = "active.qmsd.reward"
            local nodata,needGems = acQmsdVoApi:getHeadReward( )
            acQmsdVoApi:getRechargeRewardSocket(refreshFunc,cmdStr,action,needGems)

        end
    end
    -- "BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png"
    local rMenuItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",rewardTiantang,nil,getlocal("daily_scene_get"),37,99)
    rMenuItem:setScale(0.6)
    self.rMenuItem = rMenuItem
    local rewardBtn=CCMenu:createWithItem(rMenuItem);
    rewardBtn:setTouchPriority(-(self.layerNum-1)*20-2);
    rewardBtn:setPosition(needPos)
    upBg:addChild(rewardBtn,1)
end

function acQmsdTabTwo:initDown(  )
    local btnScale=0.8
    local strSize2=22
    if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ko" then
        strSize2=28
    end

    local function getHandler()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        activityAndNoteDialog:closeAllDialog()
        vipVoApi:showRechargeDialog(self.layerNum)

        -- print("to recharge~~~~~")
    end
    -- 装备获取
    local rechargeItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",getHandler,2,getlocal("new_recharge_recharge_now"),strSize2)
    -- rechargeItem:setScale(0.8)
    local rechargeMenu=CCMenu:createWithItem(rechargeItem);
    rechargeMenu:setTouchPriority(-(self.layerNum-1)*20-2);
    rechargeMenu:setPosition(ccp(G_VisibleSizeWidth*0.5,55))
    self.bgLayer:addChild(rechargeMenu)
    --activity_qmsd_title_tab3_downDes

    local nodata1,nodata2,needGems = acQmsdVoApi:getSingleRechargeReward( )
    local desStr = needGems and getlocal("activity_qmsd_title_tab2_downDes",{needGems}) or getlocal("activity_znqd2017_allReward")
    local downDes = GetTTFLabel(desStr,24)
    downDes:setAnchorPoint(ccp(0.5,0))
    downDes:setPosition(ccp(rechargeItem:getContentSize().width*0.5,80))
    self.downDes = downDes
    rechargeItem:addChild(downDes)
end

function acQmsdTabTwo:initCenter( )
    local middleBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)--"greenBlackBg2.png",CCRect(10,10,12,12),function ()end)
    middleBg:setContentSize(CCSizeMake(616,self.upBg:getPositionY() - self.upBg:getContentSize().height - 150))
    middleBg:setPosition(ccp(G_VisibleSizeWidth*0.5,self.upBg:getPositionY() - self.upBg:getContentSize().height))
    middleBg:setAnchorPoint(ccp(0.5,1))
    self.middleBg = middleBg
    self.bgLayer:addChild(middleBg)

    self.taskTb = acQmsdVoApi:getSingleRechargeNumsState()
    local function callBack(...)
         return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(middleBg:getContentSize().width - 10,middleBg:getContentSize().height - 10),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(5,5))
    middleBg:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
end

function acQmsdTabTwo:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return SizeOfTable(self.singleNeedGemsTb) or 1
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
        backSprie:setOpacity(0)
        backSprie:setPosition(ccp(0,0))
        cell:addChild(backSprie)
        local index,awardState=self.taskTb[idx+1].index,self.taskTb[idx+1].state--1 未达成 2 可领取 3 已领取
        local needGems = self.singleNeedGemsTb[index] or 1000000
        local titleStr = getlocal("activity_ganenjiehuikui_rechargeStr",{needGems})
        local lbStarWidth=20
        if G_getCurChoseLanguage() =="ar" then
            strWidth2 = strWidth2 -100
        end

        local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,16,1,1),function()end)
        titleBg:setContentSize(CCSizeMake(G_VisibleSizeWidth*0.75,titleBg:getContentSize().height))
        titleBg:setAnchorPoint(ccp(0,1))
        titleBg:setPosition(3,backSprie:getContentSize().height-3)
        backSprie:addChild(titleBg)

        local titleLb=GetTTFLabelWrap(titleStr,strSize2,CCSizeMake(strWidth2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        titleLb:setAnchorPoint(ccp(0,0.5))
        titleLb:setColor(G_ColorYellowPro)
        titleLb:setPosition(ccp(lbStarWidth,titleBg:getContentSize().height*0.5))
        titleBg:addChild(titleLb,1)

        -- 奖励描述
        local textWidth = 100
        local desH=(self.cellHeight - titleLb:getContentSize().height-10)*0.5
        if G_getCurChoseLanguage() == "ar" then
            textWidth = 50
        end
        local desLb=GetTTFLabelWrap(getlocal("activity_rechargeDouble_get"),strSize3,CCSizeMake(textWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        desLb:setAnchorPoint(ccp(0,0.5))
        -- desLb:setColor(G_ColorYellowPro)
        desLb:setPosition(ccp(lbStarWidth,desH))
        backSprie:addChild(desLb)

        -- -- 奖励展示
        local rewardItem=FormatItem(self.singleRewardTb[index],nil,true)
        local taskW=0
        for k,v in pairs(rewardItem) do
            local function showNewPropInfo()
                G_showNewPropInfo(self.layerNum+1,true,true,nil,v)
                return false
            end
            local scaleNum = v.key =="p3390" and 60 or 75
            local icon = G_getItemIcon(v,100,true,self.layerNum+1,showNewPropInfo,self.tv,nil,nil,nil)
            icon:setTouchPriority(-(self.layerNum-1)*20-2)
            backSprie:addChild(icon)
            icon:setAnchorPoint(ccp(0,0.5))
            icon:setPosition(k*80+20, desH + (v.key =="p3390" and 5 or 0))
            local scale=scaleNum/icon:getContentSize().width
            icon:setScale(scale)
            taskW=k*100

            local numLabel=GetTTFLabel("x"..FormatNumber(v.num),22)
            numLabel:setAnchorPoint(ccp(1,0))
            local numPos = v.key =="p3390" and ccp(icon:getContentSize().width -2 , -2) or ccp(icon:getContentSize().width-5, 5)
            numLabel:setPosition(numPos)
            numLabel:setScale(1/scale)
            icon:addChild(numLabel,1)

            if v.key =="p3390" then
                local numBg = CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")--LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function() end)
                numBg:setAnchorPoint(ccp(1,0))
                icon:addChild(numBg)
                numBg:setScaleX((numLabel:getContentSize().width-5)/numBg:getContentSize().width)
                numBg:setScaleY((numLabel:getContentSize().height -5)/numBg:getContentSize().height)
                numBg:setPosition(numPos.x+2,numPos.y-2)
            else
                local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function() end)
                numBg:setAnchorPoint(ccp(1,0))
                icon:addChild(numBg)
                numBg:setPosition(icon:getContentSize().width-5, 4)
                numBg:setContentSize(CCSizeMake(numLabel:getContentSize().width+5,numLabel:getContentSize().height+4))
            end
        end

        
        if awardState == 1 then ---------------------未完成 noReached
            local noReachedLb=GetTTFLabel(getlocal("noReached"),23)
            noReachedLb:setPosition(ccp(backSprie:getContentSize().width-75,desH))
            backSprie:addChild(noReachedLb,1)
        elseif awardState == 3 then -- 已完成(已领取)
            local alreadyLb=GetTTFLabel(getlocal("activity_hadReward"),23)
            alreadyLb:setColor(G_ColorWhite)
            alreadyLb:setPosition(ccp(backSprie:getContentSize().width-75,desH))
            backSprie:addChild(alreadyLb,1)
            alreadyLb:setColor(G_ColorGray)
        else -- 可领取
            local function rewardTiantang()
                if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do return end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)

                    local function refreshFunc()---------------------------------
                        self:refresh()
                        for k,v in pairs(rewardItem) do
                            if v.id ~="3390" then
                                G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                            end
                        end
                        G_showRewardTip(rewardItem)
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("receivereward_received_success"),30)
                    end
                    local action,point = 1,needGems
                    local cmdStr = "active.qmsd.reward"
                    acQmsdVoApi:getRechargeRewardSocket(refreshFunc,cmdStr,action,point)
                end
            end
            -- "BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png"
            local rMenuItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",rewardTiantang,nil,getlocal("daily_scene_get"),38,99)
            rMenuItem:setScale(0.6)
            local rewardBtn=CCMenu:createWithItem(rMenuItem);
            rewardBtn:setTouchPriority(-(self.layerNum-1)*20-2);
            rewardBtn:setPosition(ccp(backSprie:getContentSize().width-75,desH))
            backSprie:addChild(rewardBtn)

            titleLb:setColor(G_ColorGreen)
            -- if awardState == 1 then ---------------------未完成 noReached
            --     -- local menuStr = tolua.cast(rMenuItem:getChildByTag(99),"CCLabelTTF")
            --     -- menuStr:setString(getlocal("local_war_incomplete"))
            --     -- rMenuItem:setEnabled(false)
            --     -- titleLb:setColor(G_ColorRed)
            --     local noReachedLb=GetTTFLabel(getlocal("noReached"),23)
            --     noReachedLb:setPosition(ccp(backSprie:getContentSize().width-75,desH))
            --     backSprie:addChild(noReachedLb,1)
            -- end
        end

        local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
        lineSp:setContentSize(CCSizeMake(backSprie:getContentSize().width-10,2))
        lineSp:ignoreAnchorPointForPosition(false)
        lineSp:setAnchorPoint(ccp(0.5,0))
        lineSp:setPosition(backSprie:getContentSize().width/2,2)
        backSprie:addChild(lineSp)

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function acQmsdTabTwo:tick( )
    local todayFlag=acQmsdVoApi:isToday()
    if self.isTodayFlag==true and todayFlag==false then
        self.isTodayFlag=false
        acQmsdVoApi:setSingleRechargeNums()--清楚当天充值金币数
        if self.todayRechargeStr then
            local nodata,needGems = acQmsdVoApi:getHeadReward( )
            self.selfRechargeNums = acQmsdVoApi:getSingleRechargeNums()
            self.selfRechargeNums = needGems > self.selfRechargeNums and self.selfRechargeNums or needGems
            local isGetedIcon = acQmsdVoApi:isGetIconFunc()
            self.todayRechargeStr:setString(getlocal("todayRecharged",{isGetedIcon == 1 and needGems or self.selfRechargeNums,needGems}))
            if self.goldIcon then
                self.goldIcon:setPosition(ccp(self.todayRechargeStr:getPositionX() + self.todayRechargeStr:getContentSize().width  + 5,self.goldIcon:getPositionY()))
            end
        end
        self:refresh()
    end
end

function acQmsdTabTwo:refresh()
    if self.tv then
        self.taskTb = acQmsdVoApi:getSingleRechargeNumsState()
        local recordPoint=self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
end