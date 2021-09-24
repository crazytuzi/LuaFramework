acQmsdTabThree={

}

function acQmsdTabThree:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    nc.tv=nil
    nc.bgLayer=nil
    nc.layerNum=layerNum
    nc.allRecharegeNums = 0
    nc.cellHeight=145
    return nc;
end
function acQmsdTabThree:dispose( )
    self.layerNum = nil
    self.bgLayer = nil
    self.tv = nil
    self.allRecharegeNums = nil
    self.cellHeight = nil
end

function acQmsdTabThree:init(parent)
    self.activeName=acQmsdVoApi:getActiveName()
    self.bgLayer=CCLayer:create()
    self.parent=parent

    self.gemsTb,self.allSerRewardTb = acQmsdVoApi:getAllRechargeReward( )

    self:initUp()
    self:initDown()
    self:initCenter()
    -- self:initTableView()
    return self.bgLayer
end

function acQmsdTabThree:refresh( )
    local allRecharegeNums = acQmsdVoApi:getAllRechargeNums()
    self.allRecharegeNums = allRecharegeNums < 1000 and string.format("%03d", allRecharegeNums) or allRecharegeNums
    if self.allRecharegeNumsStr then
        self.allRecharegeNumsStr:setString(self.allRecharegeNums)

        local nodata1,nodata2,needGems = acQmsdVoApi:getAllRechargeReward( )
        local desStr = needGems and getlocal("activity_qmsd_title_tab3_downDes",{needGems}) or getlocal("activity_znqd2017_allReward")
        self.downDes:setString(desStr)

    end
    if self.tv then
        self.taskTb = acQmsdVoApi:getAllRechargeNumsState()
        local recordPoint=self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
end

function acQmsdTabThree:tick( )
    if acQmsdVoApi:getAllRechargeNums() > tonumber(self.allRecharegeNums) then
        self:refresh()
    end
end

function acQmsdTabThree:initUp( )
    local startH=G_VisibleSizeHeight - 160
    local iphone5NeedHeight = G_isIphone5() and 10 or 0
    local upBg = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),function( ) end)
    upBg:setContentSize(CCSizeMake(616,G_VisibleSizeHeight*0.15 + iphone5NeedHeight))
    upBg:setPosition(ccp(G_VisibleSizeWidth*0.5,startH))
    upBg:setAnchorPoint(ccp(0.5,1))
    -- upBg:setOpacity(0)
    self.upBg = upBg
    self.bgLayer:addChild(upBg)

    local function onLoadIcon(fn,icon)
        if(self and self.upBg and tolua.cast(self.upBg,"LuaCCScale9Sprite")) then
            -- icon:setScale(0.98)
            icon:setScaleX(upBg:getContentSize().width/icon:getContentSize().width)
            icon:setScaleY(upBg:getContentSize().height/icon:getContentSize().height)
            icon:setPosition(getCenterPoint(self.upBg))
            self.upBg:addChild(icon)
        end
    end
    local webImage=LuaCCWebImage:createWithURL(G_downloadUrl("active/kzhdBg.png"),onLoadIcon)

    local addedUpStr=GetTTFLabel(getlocal("addedUp"),24,"Helvetica-bold")
    addedUpStr:setAnchorPoint(ccp(0,1))
    addedUpStr:setPosition(ccp(5,upBg:getContentSize().height - 10))
    upBg:addChild(addedUpStr,1)

    local allRecharegeNums = acQmsdVoApi:getAllRechargeNums()
    self.allRecharegeNums = allRecharegeNums < 1000 and string.format("%03d", allRecharegeNums) or allRecharegeNums
    local allRecharegeNumsStr=GetBMLabel(self.allRecharegeNums,G_GoldFontSrc,35)
    allRecharegeNumsStr:setScale(1.5)
    allRecharegeNumsStr:setPosition(getCenterPoint(upBg))
    upBg:addChild(allRecharegeNumsStr,2)
    self.allRecharegeNumsStr = allRecharegeNumsStr

    local upDes=GetTTFLabelWrap(getlocal("activity_qmsd_title_tab3_upDes"),24,CCSizeMake(upBg:getContentSize().width - 20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    upDes:setAnchorPoint(ccp(0.5,0.5))
    upDes:setPosition(ccp(upBg:getContentSize().width*0.5,35 + (G_isIphone5() and 0 or -10)))
    upBg:addChild(upDes,1)
end

function acQmsdTabThree:initDown(  )
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
    local rechargeItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",getHandler,2,getlocal("iNeedToRecharge"),strSize2)
    -- rechargeItem:setScale(0.8)
    local rechargeMenu=CCMenu:createWithItem(rechargeItem);
    rechargeMenu:setTouchPriority(-(self.layerNum-1)*20-2);
    rechargeMenu:setPosition(ccp(G_VisibleSizeWidth*0.5,55))
    self.bgLayer:addChild(rechargeMenu)
    --activity_qmsd_title_tab3_downDes
    local posy3 = -5
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() =="tw" then
        posy3 = 0
    end
    local nodata1,nodata2,needGems = acQmsdVoApi:getAllRechargeReward( )
    local desStr = needGems and getlocal("activity_qmsd_title_tab3_downDes",{needGems}) or getlocal("activity_znqd2017_allReward")
    local downDes = GetTTFLabelWrap(desStr,24,CCSizeMake(self.bgLayer:getContentSize().width - 20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")--GetTTFLabel(desStr,24)
    downDes:setAnchorPoint(ccp(0.5,0))
    downDes:setPosition(ccp(rechargeItem:getContentSize().width*0.5,80 + posy3))
    self.downDes = downDes
    rechargeItem:addChild(downDes)
end

function acQmsdTabThree:initCenter( )
    local middleBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)--"greenBlackBg2.png",CCRect(10,10,12,12),function ()end)
    middleBg:setContentSize(CCSizeMake(616,self.upBg:getPositionY() - self.upBg:getContentSize().height - 150))
    middleBg:setPosition(ccp(G_VisibleSizeWidth*0.5,self.upBg:getPositionY() - self.upBg:getContentSize().height))
    middleBg:setAnchorPoint(ccp(0.5,1))
    self.middleBg = middleBg
    self.bgLayer:addChild(middleBg)

    self.taskTb = acQmsdVoApi:getAllRechargeNumsState()
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

function acQmsdTabThree:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return SizeOfTable(self.gemsTb) or 1
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
        backSprie:setOpacity(0)
        backSprie:setAnchorPoint(ccp(0,0))
        backSprie:setPosition(ccp(0,0))
        cell:addChild(backSprie)
        local index,awardState=self.taskTb[idx+1].index,self.taskTb[idx+1].state--1 未达成 2 可领取 3 已领取
        local needGems = self.gemsTb[index] or 1000000
        local titleStr = getlocal("allServersAddedUpRechared",{needGems})
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
        local desH=(self.cellHeight - titleLb:getContentSize().height-10)*0.5
        local desLb=GetTTFLabelWrap(getlocal("activity_rechargeDouble_get"),strSize3,CCSizeMake(100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        desLb:setAnchorPoint(ccp(0,0.5))
        -- desLb:setColor(G_ColorYellowPro)
        desLb:setPosition(ccp(lbStarWidth,desH))
        backSprie:addChild(desLb)

        -- -- 奖励展示
        local rewardItem=FormatItem(self.allSerRewardTb[index],nil,true)
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

            local numBg = CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")--LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function() end)
            numBg:setAnchorPoint(ccp(1,0))
            icon:addChild(numBg)
            numBg:setScaleX((numLabel:getContentSize().width-5)/numBg:getContentSize().width)
            numBg:setScaleY((numLabel:getContentSize().height -5)/numBg:getContentSize().height)
            numBg:setPosition(numPos.x+2,numPos.y-2)

            -- numBg:setContentSize(CCSizeMake(numLabel:getContentSize().width,numLabel:getContentSize().height))
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

                    local function refreshFunc()
                        self:refresh()
                        for k,v in pairs(rewardItem) do
                            if v.id ~="3390" then
                                G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                            end
                        end
                        G_showRewardTip(rewardItem)
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("receivereward_received_success"),30)
                    end
                    local action,point = 2,needGems
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











