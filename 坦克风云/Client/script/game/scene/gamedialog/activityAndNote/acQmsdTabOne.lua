acQmsdTabOne={

}

function acQmsdTabOne:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    nc.tv=nil
    nc.bgLayer=nil
    nc.boxNums =0
    nc.layerNum=layerNum
    nc.isTodayFlag = acQmsdVoApi:isToday()
    nc.boxFixPos=nil
    nc.animatBoxTb={}
    nc.EntrancePosTb={}
    nc.sockTb = {}
    nc.sockBorderLight = nil
    return nc;
end
function acQmsdTabOne:dispose( )
    self.layerNum = nil
    self.bgLayer = nil
    self.tv = nil
    self.boxFixPos = nil
    self.animatBoxTb = nil
    self.EntrancePosTb = nil
    self.sockTb = nil
    self.boxNums = nil
    self.sockBorderLight = nil
end

function acQmsdTabOne:init(parent)
    self.activeName=acQmsdVoApi:getActiveName()
    self.bgLayer=CCLayer:create()
    self.parent=parent

    self.tDialogHeight = 80
    self.touchDialog = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function( ) end);
    self.touchDialog:setTouchPriority(-(self.layerNum-1)*20-99)
    self.touchDialog:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-self.tDialogHeight))
    self.touchDialog:setOpacity(0)
    self.touchDialog:setIsSallow(true) -- 点击事件透下去
    self.touchDialog:setPosition(ccp(G_VisibleSizeWidth*1.5,(G_VisibleSizeHeight-self.tDialogHeight)*0.5))
    self.bgLayer:addChild(self.touchDialog,99)

    self:initUp()
    self:initMiddleUp()
    self:initMiddleDown()
    self:initDown()
    -- self:initTableView()
    return self.bgLayer
end

function acQmsdTabOne:initUp( )
    local startH=G_VisibleSizeHeight - 160
    -- print("军团个人积分排名~~~~~",allianceVoApi:isHasAlliance())
    local iphone5NeedHeight = G_isIphone5() and 10 or 0
    local upBg = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),function( ) end)
    upBg:setContentSize(CCSizeMake(616,G_VisibleSizeHeight*0.15 + iphone5NeedHeight))
    upBg:setPosition(ccp(G_VisibleSizeWidth*0.5,startH))
    upBg:setAnchorPoint(ccp(0.5,1))
    upBg:setOpacity(0)
    self.upBg = upBg
    self.bgLayer:addChild(upBg)

    local image = CCSprite:createWithSpriteFrameName("acQmsdUpBg_1.png")
    image:setScaleX(upBg:getContentSize().width/image:getContentSize().width)
    image:setScaleY(upBg:getContentSize().height/image:getContentSize().height)
    -- image:setOpacity(130)
    image:setAnchorPoint(ccp(0.5,0.5))
    image:setPosition(getCenterPoint(upBg))
    upBg:addChild(image)


    local h = G_isIphone5() and G_VisibleSizeHeight-200 or G_VisibleSizeHeight-190
    local h2 = h - 10
    local timeStr=acQmsdVoApi:getTimer()
    local posxSubWidth = 0
    if G_getCurChoseLanguage() == "fr" then
        posxSubWidth = 40
    end
    local strSize3,curLan = 22,G_getCurChoseLanguage()
    if curLan =="cn" or curLan =="ja" or curLan =="ko" or curLan =="tw" then
        strSize3 = 25
    end
    local acLabel = GetTTFLabel(timeStr,strSize3)
    acLabel:setAnchorPoint(ccp(0.5,0.5))
    acLabel:setPosition(ccp(G_VisibleSizeWidth *0.5-posxSubWidth, h))
    self.bgLayer:addChild(acLabel)
    acLabel:setColor(G_ColorYellowPro)
    self.timeLb=acLabel

    local topDes = GetTTFLabelWrap(getlocal("activity_qmsd_title_tab1_upDes"),24,CCSizeMake(G_VisibleSizeWidth - 60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    topDes:setAnchorPoint(ccp(0.5,0.5))
    topDes:setPosition(ccp(upBg:getContentSize().width*0.5,upBg:getContentSize().height*0.3 + iphone5NeedHeight*0.5))
    upBg:addChild(topDes,1)

    local topDesBg = CCSprite:createWithSpriteFrameName("allianceHeaderBg.png") --LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),function () end)
    topDesBg:setAnchorPoint(ccp(0.5,0.5))
    topDesBg:setOpacity(150)
    topDesBg:setPosition(ccp(upBg:getContentSize().width*0.5,upBg:getContentSize().height*0.3 + iphone5NeedHeight*0.5))
    topDesBg:setScaleX(topDes:getContentSize().width/topDesBg:getContentSize().width)
    topDesBg:setScaleY(topDes:getContentSize().height/topDesBg:getContentSize().height)
    upBg:addChild(topDesBg)

    for i=1,2 do
        local posY = i ==1 and topDes:getPositionY()+topDes:getContentSize().height*0.5+3 or topDes:getPositionY()-topDes:getContentSize().height*0.5-3
        local yellowLine = CCSprite:createWithSpriteFrameName("yellowLightPoint.png")
        yellowLine:setAnchorPoint(ccp(0.5,0.5))
        yellowLine:setScaleX(G_VisibleSizeWidth*0.55/yellowLine:getContentSize().width)
        yellowLine:setScaleY(1.2)
        yellowLine:setPosition(ccp(upBg:getContentSize().width*0.5,posY))
        upBg:addChild(yellowLine)      

        local addPosX = i == 1 and 40 or -50
        local yellowStar = CCSprite:createWithSpriteFrameName("yellowLightPointBg.png")
        yellowStar:setAnchorPoint(ccp(0.5,0.5))
        yellowStar:setPosition(yellowLine:getPositionX()+addPosX,yellowLine:getPositionY())
        yellowStar:setScaleY(0.9)
        upBg:addChild(yellowStar)
    end

    local function touchInfo()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tabStr={}
        for i=1,5 do
            table.insert(tabStr,getlocal("activity_qmsd_title_tab1_tip"..i))
        end
        local titleStr=getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        local textSize = 25
        if G_getCurChoseLanguage() =="ru" then
            textSize = 22
        end
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,textSize)
    end
    local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touchInfo,1,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,0.5))
    menuItemDesc:setScale(0.8)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-2)
    menuDesc:setPosition(ccp(self.bgLayer:getContentSize().width-35, h2))
    self.bgLayer:addChild(menuDesc,2)
end
function acQmsdTabOne:initMiddleUp( )
    self.middleSubHeight = 15
    local upPos = self.upBg:getPositionY() - self.upBg:getContentSize().height
    local bgHeight = (G_isIphone5() and 120 or 80) - self.middleSubHeight
    local middleUpBg = LuaCCScale9Sprite:createWithSpriteFrameName("goldLineBg.png",CCRect(12, 43, 1, 1),function( ) end)
    middleUpBg:setContentSize(CCSizeMake(600,bgHeight))
    middleUpBg:setOpacity(0)
    middleUpBg:setPosition(ccp(G_VisibleSizeWidth*0.5,upPos - self.middleSubHeight))
    middleUpBg:setAnchorPoint(ccp(0.5,1))
    self.middleUpBg = middleUpBg
    self.bgLayer:addChild(middleUpBg,2)
end
function acQmsdTabOne:initMiddleUp2(middleDownBgWidth,middleDownBgHeight,middleDownBg)
    local needHeight = G_isIphone5() and 6 or 24
    self.middleSubHeight = 15 + needHeight - 7
    local upPos = self.upBg:getPositionY() - self.upBg:getContentSize().height
    local bgHeight = (G_isIphone5() and 120 or 80) - self.middleSubHeight + needHeight*2
    local middleUpBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("goldLineBg.png",CCRect(12, 43, 1, 1),function( ) end)
    middleUpBg2:setContentSize(CCSizeMake(616,bgHeight))
    middleUpBg2:setPosition(ccp(middleDownBgWidth*0.5,middleDownBgHeight - self.middleSubHeight))
    middleUpBg2:setAnchorPoint(ccp(0.5,0))
    -- middleUpBg2:setOpacity(0)
    self.middleUpBg2 = middleUpBg2
    middleDownBg:addChild(middleUpBg2,2)

    local chrisBox = CCSprite:createWithSpriteFrameName("ChristmasGiftBox1.png") --LuaCCScale9Sprite:createWithSpriteFrameName("ChristmasGiftBox1.png",CCRect(10, 10, 1, 1),function ()end)
    chrisBox:setAnchorPoint(ccp(0,0.5))
    chrisBox:setPosition(ccp(25,bgHeight*0.5))
    middleUpBg2:addChild(chrisBox)

    self.boxFixPos = ccp(middleDownBgWidth * 0.5 - (middleUpBg2:getContentSize().width*0.5 - chrisBox:getPositionX() - chrisBox:getContentSize().width*0.5),middleDownBgHeight + middleUpBg2:getContentSize().height*0.5 - self.middleSubHeight)

    for i=1,5 do
        local animatBox = CCSprite:createWithSpriteFrameName("ChristmasGiftBox1.png")
        animatBox:setPosition(self.boxFixPos)
        middleDownBg:addChild(animatBox,88)
        self.animatBoxTb[i] = animatBox
    end


    local boxNums = acQmsdVoApi:getChrisBoxes()
    self.boxNums = boxNums
    local chrisBoxStr = GetTTFLabel(getlocal("activity_qmsd_chrisBoxes",{boxNums}),24)
    chrisBoxStr:setAnchorPoint(ccp(0,0.5))
    chrisBoxStr:setPosition(ccp(chrisBox:getPositionX() + chrisBox:getContentSize().width + 10 , bgHeight*0.5))
    middleUpBg2:addChild(chrisBoxStr)
    if boxNums == 0 then
        chrisBoxStr:setColor(G_ColorRed)
    end
    self.chrisBoxStr = chrisBoxStr

    ------------------------------------------------------------------购买 次数------------------------------------------------------------------
    local function rewardTiantang()
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            
            self:getBoxesNums()
    end
    -- "BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png"
    local rMenuItem=GetButtonItem("sYellowAddBtn.png","sYellowAddBtn.png","sYellowAddBtn.png",rewardTiantang,nil,nil,35,99)
    rMenuItem:setScale(0.8)
    rMenuItem:setAnchorPoint(ccp(0,0.5))
    local buyBoxBtn=CCMenu:createWithItem(rMenuItem);
    buyBoxBtn:setTouchPriority(-(self.layerNum-1)*20-2);
    buyBoxBtn:setPosition(ccp(chrisBoxStr:getPositionX() + chrisBoxStr:getContentSize().width + 10,bgHeight*0.5))
    middleUpBg2:addChild(buyBoxBtn)
    self.buyBoxBtn = buyBoxBtn

    ------------------------------------------------------------------领奖记录-----------------------------------------------------------------

    local function recordHandler()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)--serverwar_get_point        
        local function rewardRecordShow()
            local lotteryLog,logNum = acQmsdVoApi:getLotteryLog()
            if lotteryLog and logNum > 0 then
                local logList={}
                for k,v in pairs(lotteryLog) do
                    local num,reward,time,scores=v.num,v.reward,v.time,v.scores
                    local title = {getlocal("activity_qmsd_DispatchStr2",{num})}
                    -- local title={getlocal("buyAndScoreRecord",{num,scores})}
                    local content={{reward}}
                    local log={title=title,content=content,ts=time}
                    table.insert(logList,log)
                end
                local logNum=SizeOfTable(logList)
                require "luascript/script/game/scene/gamedialog/activityAndNote/acCjyxSmallDialog"
                acCjyxSmallDialog:showLogDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-300),CCRect(130, 50, 1, 1),{getlocal("activity_customLottery_RewardRecode"),G_ColorWhite},logList,false,self.layerNum+1,nil,true,10,true,true)
            end
            if logNum == 0 then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_tccx_no_record"),30)
                do return end
            end
        end--getlog
        local cmdStr = "active.qmsd.getlog"
        acQmsdVoApi:getRechargeRewardSocket(rewardRecordShow,cmdStr)
    end
    local recordBtn=GetButtonItem("bless_record.png","bless_record.png","bless_record.png",recordHandler,11)
    recordBtn:setScale( G_isIphone5() and 0.9 or 0.6)
    recordBtn:setAnchorPoint(ccp(0.5,0.5))
    local menu=CCMenu:createWithItem(recordBtn)
    menu:setTouchPriority(-(self.layerNum-1)*20-4)
    menu:setPosition(ccp(middleUpBg2:getContentSize().width-55,bgHeight*0.5))
    middleUpBg2:addChild(menu)


    local cloud1 = CCSprite:createWithSpriteFrameName("snowBg_1.png")
    cloud1:setAnchorPoint(ccp(0,0.5))
    cloud1:setPosition(ccp(-5,bgHeight))
    middleUpBg2:addChild(cloud1,99999)

    local cloud2 = CCSprite:createWithSpriteFrameName("snowBg_2.png")
    cloud2:setAnchorPoint(ccp(1,1))
    cloud2:setPosition(ccp(middleUpBg2:getContentSize().width + 10,bgHeight + 10))
    middleUpBg2:addChild(cloud2,99999)
end
function acQmsdTabOne:initMiddleDown( )
    local subHeight = G_isIphone5() and 180 or 150
    local middleDownBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)--"greenBlackBg2.png",CCRect(10,10,12,12),function ()end)
    middleDownBg:setContentSize(CCSizeMake(616,self.middleUpBg:getPositionY() - self.middleUpBg:getContentSize().height - subHeight + self.middleSubHeight))
    middleDownBg:setPosition(ccp(G_VisibleSizeWidth*0.5,self.middleUpBg:getPositionY() - self.middleUpBg:getContentSize().height + self.middleSubHeight))
    middleDownBg:setAnchorPoint(ccp(0.5,1))
    self.middleDownBg = middleDownBg
    self.bgLayer:addChild(middleDownBg)
    local middleDownBgWidth,middleDownBgHeight = middleDownBg:getContentSize().width,middleDownBg:getContentSize().height
    self.middleDownBgHeight = middleDownBgHeight
    self:initMiddleUp2(middleDownBgWidth,middleDownBgHeight,middleDownBg)

    local function onLoadIcon(fn,icon)
            -- icon:setScale(0.98)
            icon:setScaleX(middleDownBgWidth/icon:getContentSize().width)
            icon:setScaleY((self.middleUpBg:getContentSize().height + middleDownBgHeight )/icon:getContentSize().height)
            icon:setPosition(ccp(middleDownBgWidth*0.5,(self.middleUpBg:getContentSize().height + middleDownBgHeight ) * 0.5))
            middleDownBg:addChild(icon)
    end
    local webImage=LuaCCWebImage:createWithURL(G_downloadUrl("active/acQmsdBg_1.jpg"),onLoadIcon)


    local posxScale = {0.09,0.28,0.5,0.75,0.93}
    local posyScale = {0.83,0.53,0.87,0.58,0.88}

    local function showRewardCall(object,name,tag)
        local idx = tag
        if tag == 3 then
            idx = 5
        elseif tag > 3 then
            idx = tag - 1
        end
        -- print("tag===idx====>>>",tag,idx)
        local rewardTb = acQmsdVoApi:getRewardToShow()
        self:awardShowCall(idx,rewardTb[idx])
    end 
    for i=1,5 do--tag,object
        local chrisRewardIcon=LuaCCSprite:createWithSpriteFrameName("wazi_"..i..".png",showRewardCall)
        chrisRewardIcon:setAnchorPoint(ccp(0.5,1))
        chrisRewardIcon:setPosition(ccp(middleDownBgWidth*posxScale[i],middleDownBgHeight*posyScale[i]))
        chrisRewardIcon:setTouchPriority(-(self.layerNum-1)*20-2)
        chrisRewardIcon:setTag(i)
        middleDownBg:addChild(chrisRewardIcon,99)

        self.EntrancePosTb[i] = ccp(middleDownBgWidth*posxScale[i],middleDownBgHeight*posyScale[i]-10)

        if i == 3 then
            local sockBorderLight = CCSprite:createWithSpriteFrameName("sockBorderLight.png")
            sockBorderLight:setAnchorPoint(ccp(0.5,1))
            sockBorderLight:setPosition(ccp(middleDownBgWidth*posxScale[i],middleDownBgHeight*posyScale[i] + 8))
            middleDownBg:addChild(sockBorderLight,98)
            sockBorderLight:setOpacity(0)
            self.sockBorderLight = sockBorderLight
        end

        local sock = CCSprite:createWithSpriteFrameName("sock_"..i..".png")
        sock:setPosition(ccp(chrisRewardIcon:getContentSize().width*0.5 - 5,chrisRewardIcon:getContentSize().height - ( i == 3 and 25 or 10)))
        sock:setScale( i == 3 and 0.9 or 0.6)
        chrisRewardIcon:addChild(sock)
        sock:setVisible(false)
        self.sockTb[i] = sock
    end

    local middleDownDes = GetTTFLabelWrap(getlocal("activity_qmsd_title_tab1_MiddleDes",{getlocal("sample_prop_name_1348")}),24,CCSizeMake(middleDownBgWidth - 40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    middleDownDes:setPosition(ccp(middleDownBgWidth*0.5,80))
    middleDownBg:addChild(middleDownDes,1)

    local middleDownDes2 = GetTTFLabelWrap(getlocal("activity_qmsd_title_tab1_MiddleDes2"),G_isAsia() and 24 or 20,CCSizeMake(middleDownBgWidth - 40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom,"Helvetica-bold")

    middleDownDes2:setPosition(ccp(middleDownBgWidth*0.5,40))
    middleDownDes2:setColor(G_ColorYellowPro2)
    middleDownBg:addChild(middleDownDes2,1)
end

function acQmsdTabOne:awardShowCall(idx,rewardTb)
    local strSize22 = 18
    if G_isAsia() then
        strSize22 = 23
    end
        require "luascript/script/game/scene/gamedialog/activityAndNote/acThrivingSmallDialog"
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
     --显示奖池
        local function stopAcation( )
            self:bigAwardAction(tag,true)
        end 
        local titleStr = getlocal("award")
        local descStr = getlocal("activity_qmsd_rewardDes")
        local needTb = {"qmsd",titleStr,descStr,rewardTb,SizeOfTable(rewardTb)}
        local bigAwardDia = acThrivingSmallDialog:new(self.layerNum+1,needTb)
        bigAwardDia:init()
end

function acQmsdTabOne:initDown( )
    local cost1,cost2=1,5
    local btnPosY = G_isIphone5() and 65 or 45
    local function freeLotteryHandler()
        self:lotteryHandler(nil,true)
    end
    local function lotteryHandler()
        self:lotteryHandler(cost1)
    end
    self.freeBtn=self:getLotteryBtn(ccp(G_VisibleSizeWidth/2-130,btnPosY),freeLotteryHandler)
    self.lotteryBtn=self:getLotteryBtn(ccp(G_VisibleSizeWidth/2-130,btnPosY),lotteryHandler,cost1)

    local function multiLotteryHandler()
        self:lotteryHandler(cost2)
    end
    self.multiLotteryBtn=self:getLotteryBtn(ccp(G_VisibleSizeWidth/2+130,btnPosY),multiLotteryHandler,cost2,true)

    local strPosy = btnPosY + 53
    for i=1,2 do
        local btnStr = GetTTFLabel(getlocal("plat_war_donate_need_num"),23)
        btnStr:setPosition(ccp(G_VisibleSizeWidth*0.5 + (i == 1 and -130 or 130) - 40,strPosy))
        self.bgLayer:addChild(btnStr)

        local chrisBox = CCSprite:createWithSpriteFrameName("ChristmasGiftBox1.png") 
        chrisBox:setAnchorPoint(ccp(0,0.5))
        chrisBox:setScale(0.8)
        chrisBox:setPosition(ccp(btnStr:getContentSize().width*0.5 + btnStr:getPositionX(),strPosy + 5))
        self.bgLayer:addChild(chrisBox)

        local needBoxStr = GetTTFLabel("x"..(i==1 and cost1 or cost2),23)
        needBoxStr:setAnchorPoint(ccp(0,0.5))
        needBoxStr:setPosition(ccp(chrisBox:getContentSize().width*0.5 + 18 + chrisBox:getPositionX(),strPosy))
        self.bgLayer:addChild(needBoxStr)

        if i == 1 then
            self.btnStr = btnStr
            self.chrisBox = chrisBox
            self.needBoxStr = needBoxStr
        end
    end

    self.freeStr = GetTTFLabel(getlocal("daily_lotto_tip_2"),24)
    self.freeStr:setPosition(ccp(G_VisibleSizeWidth*0.5-130,strPosy))
    self.freeStr:setColor(G_ColorGreen)
    self.bgLayer:addChild(self.freeStr)

    self:refreshLotteryBtn()
end

function acQmsdTabOne:getLotteryBtn(pos,callback,cost,isMul)
    local btnZorder,btnFontSize=2,25
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() =="tw" then

    else
        -- if G_isIOS() == false then
            btnFontSize = 20
        -- end
    end
    local function lotteryHandler()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if callback then
            callback()
        end
    end
    local lotteryBtn
    local btnScale=0.8
    if cost and tonumber(cost)>0 then
        local btnStr=""
        btnStr=getlocal("activity_qmsd_DispatchStr",{cost})
        lotteryBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",lotteryHandler,nil,btnStr,btnFontSize/btnScale,11)
    else--daily_lotto_tip_2
        lotteryBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",lotteryHandler,nil,getlocal("activity_qmsd_DispatchStr",{1}),btnFontSize/btnScale,11)
    end
    lotteryBtn:setScale(btnScale)
    local lotteryMenu=CCMenu:createWithItem(lotteryBtn)
    lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    lotteryMenu:setPosition(pos)
    self.bgLayer:addChild(lotteryMenu,btnZorder)

    return lotteryBtn
end

function acQmsdTabOne:lotteryHandler(num,isfree)
    if isfree == nil and num > acQmsdVoApi:getChrisBoxes() then
        self:getBoxesNums("activity_qmsd_notEnoughNums")
        -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_qmsd_notEnoughNums"),30)
        do return end
    end

    local function refreshFunc(rewardTb,enterOrderTb)
        for i=1,5 do
            self.sockTb[i]:setVisible(false)
            self.sockTb[i]:stopAllActions()
        end
        self:refreshLotteryBtn()
        if self.chrisBoxStr then
            self.chrisBoxStr:setString(getlocal("activity_qmsd_chrisBoxes",{acQmsdVoApi:getChrisBoxes()}))
            self.chrisBoxStr:setColor(G_ColorWhite)
            if self.buyBoxBtn then
                self.buyBoxBtn:setPositionX(self.chrisBoxStr:getPositionX() + self.chrisBoxStr:getContentSize().width  + 10)
            end
        end
        if rewardTb then
            local showTb,showIconTb = {},{}
            for m,n in pairs(rewardTb) do
                local rewardItem=FormatItem(n,nil,true)
                table.insert(showTb,rewardItem[1])
                for k,v in pairs(rewardItem) do
                    G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                    if propCfg[v.key] and propCfg[v.key].composeGetProp then
                        local sysMsg = getlocal("activity_pjjnh_chatSystemMessage", {playerVoApi:getPlayerName(),getlocal("activity_qmsd_title"),v.name})
                        local paramTab={}
                        paramTab.functionStr="qmsd"
                        paramTab.addStr="goTo_see_see"
                        chatVoApi:sendSystemMessage(sysMsg,paramTab)
                    end
                end
            end

            local addStrTb = nil
            local titleStr=getlocal("activity_wheelFortune4_reward")--activity_qmcj_RewardStr
            require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
            rewardShowSmallDialog:showNewReward(self.layerNum+1,true,true,showTb,function () end,titleStr,nil,addStrTb,nil,"qmsd")
        end
        self.touchDialog:setPosition(ccp(G_VisibleSizeWidth*1.5,(G_VisibleSizeHeight-self.tDialogHeight)*0.5))
    end

    local function actionCall(rewardTb,enterOrderTb)
        self.touchDialog:setPosition(ccp(G_VisibleSizeWidth*0.5,(G_VisibleSizeHeight-self.tDialogHeight)*0.5))
        local rewardNums = SizeOfTable(enterOrderTb)
        for i=1,rewardNums do
            local idx = enterOrderTb[i]
            if idx == 5 then
                idx = 3
            elseif idx > 2 then
                idx = idx + 1
            end
            local delyT = CCDelayTime:create(0.3 * (i-1))
            local JumpTo = CCJumpTo:create(0.3,self.EntrancePosTb[idx],120,1)
            local function noVisCall( )
               self.animatBoxTb[i]:setVisible(false)
               self.animatBoxTb[i]:setPosition(self.boxFixPos)
               self.animatBoxTb[i]:setVisible(true)
            end 
            local visCall = CCCallFunc:create(noVisCall)
            local arr = CCArray:create()
            arr:addObject(delyT)
            arr:addObject(JumpTo)
            arr:addObject(visCall)
            local seq = CCSequence:create(arr)
            self.animatBoxTb[i]:runAction(seq)
        end

        for i=1,rewardNums do
            local idx = enterOrderTb[i]
            if idx == 5 then
                idx = 3
            elseif idx > 2 then
                idx = idx + 1
            end

            if idx == 3 and self.sockBorderLight then
                local delyT = CCDelayTime:create(0.25 * (i-1))
                local fadeIn = CCFadeIn:create(1)
                -- local fadeOut = CCFadeOut:create(1)
                -- local fadeIn2 = CCFadeIn:create(0.5)
                -- local fadeOut2 = CCFadeOut:create(0.5)
                local arr = CCArray:create()
                arr:addObject(delyT)
                arr:addObject(fadeIn)
                -- arr:addObject(fadeOut)
                -- arr:addObject(fadeIn2)
                -- arr:addObject(fadeOut2)
                local seq = CCSequence:create(arr)
                self.sockBorderLight:runAction(seq)


            end

            local delyT = CCDelayTime:create(0.3 * (i-1))
            local function shineCallBack( )
                 self.sockTb[idx]:setVisible(true)
                 local pzArr=CCArray:create()
                 for kk=1,20 do
                     local nameStr="sock_"..kk..".png"
                     local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                     pzArr:addObject(frame)
                 end
                 local animation=CCAnimation:createWithSpriteFrames(pzArr)
                 animation:setDelayPerUnit(0.05)
                 local animate=CCAnimate:create(animation)
                 local repeatForever1=CCRepeatForever:create(animate)
                 self.sockTb[idx]:runAction(repeatForever1)  
            end 
            local shineCall = CCCallFunc:create(shineCallBack)
            local arr = CCArray:create()
            arr:addObject(delyT)
            arr:addObject(shineCall)
            local seq = CCSequence:create(arr)
            self.sockTb[idx]:runAction(seq)
        end


        local delyT = CCDelayTime:create(0.3 * (rewardNums + 1))
        local function showAwardCall( )
            refreshFunc(rewardTb)
        end
        local showCall = CCCallFunc:create(showAwardCall)
        local arr = CCArray:create()
        arr:addObject(delyT)
        arr:addObject(showCall)
        local seq = CCSequence:create(arr)
        self.bgLayer:runAction(seq)
    end

    local cmdStr = "active.qmsd.draw"
    acQmsdVoApi:getRechargeRewardSocket(actionCall,cmdStr,nil,nil,num,isfree and 0 or 1)

end
function acQmsdTabOne:refreshLotteryBtn()
    if self.freeBtn and self.lotteryBtn and self.multiLotteryBtn then

             local freeFlag=acQmsdVoApi:getFirstFree()
            if freeFlag==0 or acQmsdVoApi:isToday() == false then
                acQmsdVoApi:setFirstFree(0)
                self.lotteryBtn:setVisible(false)
                self.freeBtn:setVisible(true)
                self.multiLotteryBtn:setEnabled(false)

                self.freeStr:setVisible(true)
                self.btnStr:setVisible(false)
                self.chrisBox:setVisible(false)
                self.needBoxStr:setVisible(false)
            else
                self.freeBtn:setVisible(false)
                self.lotteryBtn:setVisible(true)
                self.multiLotteryBtn:setEnabled(true)

                self.freeStr:setVisible(false)
                self.btnStr:setVisible(true)
                self.chrisBox:setVisible(true)
                self.needBoxStr:setVisible(true)
            end

    end
end

function acQmsdTabOne:getBoxesNums(newStr)
    local needCost = acQmsdVoApi:getNeedGems( )
    local function realLottery( )
            
        local function refreshFunc()
            playerVoApi:setValue("gems",playerVoApi:getGems()-tonumber(needCost))
            acQmsdVoApi:addHeXieReward( )
            if self.chrisBoxStr then
                self.chrisBoxStr:setString(getlocal("activity_qmsd_chrisBoxes",{acQmsdVoApi:getChrisBoxes()}))
                self.chrisBoxStr:setColor(G_ColorWhite)
                if self.buyBoxBtn then
                    self.buyBoxBtn:setPositionX(self.chrisBoxStr:getPositionX() + self.chrisBoxStr:getContentSize().width + 10)
                end
            end
        end
        local cmdStr = "active.qmsd.buy"
        acQmsdVoApi:getRechargeRewardSocket(refreshFunc,cmdStr,nil,nil,1)
    end
    
    local function sureClick()
        -- print("cost---sureClick-->",needCost)
        if playerVoApi:getGems()<needCost then
            GemsNotEnoughDialog(nil,nil,needCost-playerVoApi:getGems(),self.layerNum+1,needCost)
            do return end
        end
        realLottery()
    end
    local str = newStr or "activity_qmsd_buyChirsBoxes"
    G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal(str,{needCost,getlocal("sample_prop_name_1348")}),nil,sureClick,nil)
end

function acQmsdTabOne:tick( )
    if self and self.timeLb then
      self.timeLb:setString(acQmsdVoApi:getTimer( ))
    end
    local todayFlag = acQmsdVoApi:isToday()
    if self.isTodayFlag==true and todayFlag==false and acQmsdVoApi:getFirstFree() ~= 0 then
        self.isTodayFlag=false
        acQmsdVoApi:setFirstFree(0)
        self.lotteryBtn:setVisible(false)
        self.freeBtn:setVisible(true)
        self.multiLotteryBtn:setEnabled(false)

        self.freeStr:setVisible(true)
        self.btnStr:setVisible(false)
        self.chrisBox:setVisible(false)
        self.needBoxStr:setVisible(false)

    end
    if self.boxNums < acQmsdVoApi:getChrisBoxes() then
        self.boxNums = acQmsdVoApi:getChrisBoxes()
        self.chrisBoxStr:setString(getlocal("activity_qmsd_chrisBoxes",{self.boxNums}))
        self.chrisBoxStr:setColor(G_ColorWhite)
        if self.buyBoxBtn then
            self.buyBoxBtn:setPositionX(self.chrisBoxStr:getPositionX() + self.chrisBoxStr:getContentSize().width + 10)
        end
    end
end