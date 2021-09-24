acHljbTabOne={}
function acHljbTabOne:new(parent)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.parent    = parent
    nc.bgLayer   = nil
    nc.isIphone5 = G_isIphone5()
    return nc
end
function acHljbTabOne:dispose( )
    self.bgImage = nil
    self.keepItemTime = nil
    self.giftAcSpTb = nil
    self.giftSpTb    = nil
    self.goItem      = nil
    self.isEnoughTip = nil
    self.keepTip     = nil
    self.todayKeepLb = nil
    self.curRateLb   = nil
    self.bgLayer   = nil
    self.parent    = nil
    self.isIphone5 = nil
end
function acHljbTabOne:init(layerNum)
    self.layerNum=layerNum
    self.bgLayer=CCLayer:create()
    
    if acHljbVoApi:isExTime() and acHljbVoApi:getAllKeepNums( ) == 0 then
        acHljbVoApi:clearVo()    
    end

    self:initUpPanel()
    return self.bgLayer
end

function acHljbTabOne:initUpPanel( )
    local topBorder = LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png",CCRect(103,0,2,80),function() end)
    self.bgLayer:addChild(topBorder,1)
    topBorder:setAnchorPoint(ccp(0.5,1))
    topBorder:setContentSize(CCSizeMake(G_VisibleSizeWidth,85))
    topBorder:setPosition(ccp(G_VisibleSizeWidth * 0.5,G_VisibleSizeHeight-160))


    local descStr1=acHljbVoApi:getAcTime( )
    local descStr2=acHljbVoApi:getExTime()
    local addposy = G_isIOS() and 0 or 3
    local moveBgStarStr,timeLb1,timeLb2=G_LabelRollView(CCSizeMake(self.bgLayer:getContentSize().width,46 + addposy),descStr1,25,kCCTextAlignmentCenter,G_ColorGreen,nil,descStr2,G_ColorYellowPro,2,2,2,nil,true)
    self.timeLb1=timeLb1
    self.timeLb2=timeLb2
    moveBgStarStr:setPosition(ccp(0,self.bgLayer:getContentSize().height-moveBgStarStr:getContentSize().height-180))
    self.bgLayer:addChild(moveBgStarStr,999)

    local function showInfo()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        acHljbVoApi:showInfoTipTb(self.layerNum + 1,acHljbVoApi:getTabOneTipTb())
    end
    local infoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon2.png",showInfo,11,nil,nil)
    infoItem:setAnchorPoint(ccp(1,1))
    local infoBtn = CCMenu:createWithItem(infoItem)
    infoBtn:setPosition(ccp(topBorder:getContentSize().width - 10,topBorder:getContentSize().height - 10))
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    topBorder:addChild(infoBtn,3)

    local subHeight = 160
     if G_getIphoneType() == G_iphone4 then
        subHeight = subHeight -40
    end

    local clipper = CCClippingNode:create()
    clipper:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight - subHeight))
    clipper:setAnchorPoint(ccp(0.5, 1))
    clipper:setPosition(G_VisibleSizeWidth * 0.5, G_VisibleSizeHeight - subHeight)
    clipper:setStencil(CCDrawNode:getAPolygon(clipper:getContentSize(), 1, 1))
    self.bgLayer:addChild(clipper)

    local bgImage = CCSprite:createWithSpriteFrameName("acHljbBgImage.png")
    bgImage:setAnchorPoint(ccp(0.5, 1))
    bgImage:setPosition(G_VisibleSizeWidth * 0.5, self:getBgOfTabPosY(self.selectedTabIndex) + 100 - subHeight)
    clipper:addChild(bgImage)
    self.bgImage = bgImage

    local addtipPosy = 10
    local upN,upNum,upNum2 = acHljbVoApi:getActiveData()
    -- local dayAdd,dayAdd2 = acHljbVoApi:getDayRate()
    local upTipLbSize = G_isAsia() and 22 or 14
    local upTipLb,lbHeight = G_getRichTextLabel(getlocal("activity_hljb_upTip", {upNum,upN,upNum2,upN}), {G_ColorWhite,G_ColorYellowPro2,G_ColorWhite,G_ColorYellowPro2}, upTipLbSize, 450, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    upTipLb:setAnchorPoint(ccp(0.5,1))
    upTipLb:setPosition(G_VisibleSizeWidth * 0.5, -5 + addtipPosy)
    topBorder:addChild(upTipLb,2)

    local useTipWidth,useTipHeight = 420 + 4,lbHeight + 4 --upTipLb:getContentSize().height + 4
    useTipHeight = useTipHeight <22 and 28 or useTipHeight
    local upTipLbBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
    upTipLbBg:setContentSize(CCSizeMake(useTipWidth,useTipHeight))
    upTipLbBg:setOpacity(160)
    upTipLbBg:setAnchorPoint(ccp(0.5,1))
    upTipLbBg:setPosition(G_VisibleSizeWidth * 0.5, -3 + addtipPosy)
    topBorder:addChild(upTipLbBg)

    -- local upTipLb2 = G_getRichTextLabel(getlocal("activity_hljb_upTip2", {dayAdd,dayAdd2}), {G_ColorWhite,G_ColorYellowPro2,G_ColorWhite,G_ColorYellowPro2}, 22, 420, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    -- upTipLb2:setAnchorPoint(ccp(0.5,1))
    -- upTipLb2:setPosition(G_VisibleSizeWidth * 0.5, upTipLb:getPositionY() - useTipHeight - 50)
    -- topBorder:addChild(upTipLb2,2)

    -- local useTipWidth2,useTipHeight2 = 420 + 4,upTipLb2:getContentSize().height + 4
    -- useTipHeight2 = useTipHeight2 <22 and 28 or useTipHeight2
    -- local upTipLbBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
    -- upTipLbBg2:setContentSize(CCSizeMake(useTipWidth2,useTipHeight2))
    -- upTipLbBg2:setOpacity(160)
    -- upTipLbBg2:setAnchorPoint(ccp(0.5,1))
    -- upTipLbBg2:setPosition(G_VisibleSizeWidth * 0.5, upTipLb2:getPositionY() + 2)
    -- topBorder:addChild(upTipLbBg2)

    self:rateShow(bgImage)
    self:showLogBtn(topBorder,-2,15)
    self:showKeepAndTakeBtn(bgImage,bgImage:getContentSize().width * 0.5,664)
    self:autoActionShow(bgImage,bgImage:getContentSize().width * 0.5,664)--bgImage:getContentSize().height * 0.5)
end
function acHljbTabOne:rateShow(bgImage)
    local bgWidth,bgHeight = bgImage:getContentSize().width,bgImage:getContentSize().height
    local curRate,baseRate = acHljbVoApi:getCurRecRate( )

    local curRateLb = GetTTFLabelWrap(getlocal("curRateStr",{acHljbVoApi:getAllKeepNums(),curRate}),G_isAsia() and 19 or 15,CCSizeMake(130,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    curRateLb:setColor(G_ColorYellowPro3)
    curRateLb:setPosition(bgWidth * 0.5,bgHeight * 0.395)
    self.curRateLb = curRateLb
    bgImage:addChild(curRateLb)

    local function rateShowCall( )
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        acHljbVoApi:showInfoTipTb(self.layerNum + 1,acHljbVoApi:getRateTip(),{{alignment=kCCTextAlignmentCenter}},getlocal("shuoming"))
    end
    local clickRateBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),rateShowCall)
    clickRateBg:setContentSize(CCSizeMake(140,80))
    clickRateBg:setPosition(bgWidth * 0.5,bgHeight * 0.395)
    clickRateBg:setTouchPriority(-(self.layerNum-1)*20-3)
    clickRateBg:setOpacity(0)
    bgImage:addChild(clickRateBg)
end
function acHljbTabOne:tick( )
    if acHljbVoApi:isExTime() and acHljbVoApi:getAllKeepNums( ) == 0 then
        acHljbVoApi:clearVo( )
    end
    if self.curRateLb then
        local curRate,baseRate = acHljbVoApi:getCurRecRate( )
        self.curRateLb:setString(getlocal("curRateStr",{acHljbVoApi:getAllKeepNums(),curRate}))
    end
    if self.todayKeepLb then
        self.todayKeepLb:setString(getlocal("todayKeepStr",{acHljbVoApi:getCurDayKeepItem(),acHljbVoApi:getCurDayKeepLimit()}))
    end
    if self.keepTip then
        local rechageGoldLimit,rechargedNum,isEnough =  acHljbVoApi:getRechageTipData( )
        rechargedNum = rechargedNum > rechageGoldLimit and rechageGoldLimit or rechargedNum
        self.keepTip:setString(getlocal("todayRechargeWithKeepTipStr",{rechageGoldLimit,rechargedNum,rechageGoldLimit}))
        if self.goItem and self.isEnoughTip then
            if isEnough then
                self.goItem:setVisible(false)
                self.isEnoughTip:setVisible(true)
            else
                self.goItem:setVisible(true)
                self.isEnoughTip:setVisible(false)
            end
        end
    end

    local acVo=acHljbVoApi:getAcVo()
    if(acVo and self.timeLb1 and tolua.cast(self.timeLb1,"CCLabelTTF"))then
        -- G_updateActiveTime(acVo,self.timeLb1,self.timeLb2,true)
        local descStr1=acHljbVoApi:getAcTime( )
        local descStr2=acHljbVoApi:getExTime()
        self.timeLb1:setString(descStr1)
        self.timeLb2:setString(descStr2)
    end

    --liuning修改：充值添加礼物盒
    local function refreshGift()
        self:refresh()
        self:showGiftSp()
    end 
    refreshGift()
end

function acHljbTabOne:showLogBtn(boardBg,logBtnPosy,logBtnPosx)
    local function logHandler()
        print "logHandler~~~~~~~~~~~~~~~~~"
        local function showLog()
            local log=acHljbVoApi:getLog() or {}
            if SizeOfTable(log)>0 then
                local logList={}
                local hljbVo=acHljbVoApi:getAcVo()
                for k,v in pairs(log) do
                    local title
                    --liuning修改

                    --取出
                    if v[4] and v[4] ~= 0 then
                        title = {getlocal("takeItem")..","..getlocal("scoreAdd",{v[4]})}
                    --存入
                    elseif v[1]== hljbVo.dailyLimit and v[4] ~= 0  then
                        title = {getlocal("keepItem")}
                    --赠送并存入
                    else
                        title = {getlocal("keepGive")}
                    end
                    --local title= v[4] and {getlocal("takeItem")..","..getlocal("scoreAdd",{v[4]})} or {getlocal("keepItem")}
                    local reward = FormatItem(v[2],nil,true)[1]
                    reward.num = v[1]
                    local content={{{reward}}}
                    local log={title=title,content=content,ts=v[3]}
                    table.insert(logList,log)
                end
                require "luascript/script/game/scene/gamedialog/activityAndNote/acCjyxSmallDialog"
                acCjyxSmallDialog:showLogDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-300),CCRect(130, 50, 1, 1),{getlocal("serverwar_point_record"),G_ColorWhite},logList,false,self.layerNum+1,nil,true,10,true,true,"hljbLog")
            else
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_tccx_no_record"),30)
            end
        end
        acHljbVoApi:getLogSocket(showLog)
    end
   
    local btnScale,priority = 0.7,-(self.layerNum-1)*20-3
    local logBtn,logMenu = G_createBotton(boardBg,ccp(logBtnPosx,logBtnPosy),nil,"bless_record.png","bless_record.png","bless_record.png",logHandler,btnScale,priority,nil,nil,ccp(0,1))

    local logBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    logBg:setAnchorPoint(ccp(0.5,1))
    logBg:setOpacity(150)
    logBg:setContentSize(CCSizeMake(logBtn:getContentSize().width + 30,40))
    logBg:setPosition(ccp(logBtn:getContentSize().width * 0.5,15))
    logBg:setScale(0.7/logBtn:getScale())

    logBtn:addChild(logBg)
    local strSize4 = G_isAsia() and 24 or 17
    local logLb=GetTTFLabelWrap(getlocal("serverwar_point_record"),strSize4,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)--,"Helvetica-bold")
    logLb:setPosition(logBg:getContentSize().width * 0.5,logBg:getContentSize().height * 0.5)
    logBg:addChild(logLb)
end

function acHljbTabOne:getBgOfTabPosY(tabIndex)
    local offset = 0
    if tabIndex == 0 then
        if G_getIphoneType() == G_iphone5 then
            offset = - 140
        elseif G_getIphoneType() == G_iphoneX then
            offset = - 200
        else --默认是 G_iphone4
            offset = - 40
        end
    elseif tabIndex == 1 then
        offset = 170
    elseif tabIndex == 2 then
        offset = 230
    end
    return G_VisibleSizeHeight + offset
end

function acHljbTabOne:showKeepAndTakeBtn(parent,parentWidth,parentHeight)
    local btnPosy = 120
    local blueBgAddPosy = 70
    -- print("G_getIphoneType()--->>",G_getIphoneType())
    if G_getIphoneType() == G_iphone4 then
        btnPosy = 80
        blueBgAddPosy = 25
    end
    local function keepItemCall()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if acHljbVoApi:isExTime() then
            acHljbVoApi:showbtnTip(getlocal("activity_hljb_acTimeEnd"))
            do return end
        end
        local curDoingType = acHljbVoApi:getCurDayDoingTip( )
        if curDoingType then
            acHljbVoApi:showbtnTip(curDoingType)
            do return end
        end

        local function socketSuccCall( )
            local function actionOverCall( )
                self:refresh()
                self:showGiftSp()    
            end
            self:runKeepAction(actionOverCall,parent,parentWidth,parentHeight)
        end 

        require "luascript/script/game/scene/gamedialog/activityAndNote/acThrivingSmallDialog"
        local titleStr = getlocal("keep")
        local curT = acHljbVoApi:getCurDay( )
        local needTb = {"hljbKeep",titleStr,socketSuccCall,nil,curT}
        local sd = acThrivingSmallDialog:new(self.layerNum+1,needTb)
        sd:init()
        -- self:runKeepAction(nil,parent,parentWidth,parentHeight)--测试使用
    end
    local keepItemItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",keepItemCall,nil,getlocal("keep"),34)
    keepItemItem:setAnchorPoint(ccp(0.5,1))
    keepItemItem:setScale(0.8)
    local keepItemBtn=CCMenu:createWithItem(keepItemItem)
    keepItemBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    keepItemBtn:setPosition(G_VisibleSizeWidth*0.74,btnPosy)
    self.bgLayer:addChild(keepItemBtn,9)


    local todayKeepLb = GetTTFLabel(getlocal("todayKeepStr",{acHljbVoApi:getCurDayKeepItem(),acHljbVoApi:getCurDayKeepLimit()}),22,true)
    todayKeepLb:setAnchorPoint(ccp(0.5,0))
    todayKeepLb:setPosition(keepItemBtn:getPositionX(),keepItemBtn:getPositionY() + 5)
    self.bgLayer:addChild(todayKeepLb,10)
    self.todayKeepLb = todayKeepLb


    local function takeCall()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)--activity_hljb_acTimeEnd
        if acHljbVoApi:isExTime() then
            acHljbVoApi:showbtnTip(getlocal("activity_hljb_acTimeEnd"))
            do return end
        end
        local curDoingType = acHljbVoApi:getCurDayDoingTip(true)
        if curDoingType then
            acHljbVoApi:showbtnTip(curDoingType)
            do return end
        end

        local function socketSuccCall( )
                self:refresh()
                self:showGiftSp()    
        end 

        require "luascript/script/game/scene/gamedialog/activityAndNote/acThrivingSmallDialog"
        local titleStr = getlocal("take")
        local curT = acHljbVoApi:getCurDay( )
        local needTb = {"hljbTake",titleStr,socketSuccCall,getlocal("activity_hljb_takeUpTip"),curT}
        local sd = acThrivingSmallDialog:new(self.layerNum+1,needTb)
        sd:init()
    end
    local takeItem=GetButtonItem("newGrayBtn.png","newGrayBtn_Down.png","newGrayBtn_Down.png",takeCall,nil,getlocal("take"),34)
    takeItem:setAnchorPoint(ccp(0.5,1))
    takeItem:setScale(0.8)
    local takeBtn=CCMenu:createWithItem(takeItem)
    takeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    takeBtn:setPosition(G_VisibleSizeWidth*0.26,btnPosy)
    self.bgLayer:addChild(takeBtn,9)


    local lightBlueBg = LuaCCScale9Sprite:createWithSpriteFrameName("lightBlueBg.png",CCRect(82,36,1,1),function ()end)
    lightBlueBg:setContentSize(CCSizeMake(G_VisibleSizeWidth * 0.9,140))
    lightBlueBg:setAnchorPoint(ccp(0.5,0))
    lightBlueBg:setPosition(G_VisibleSizeWidth * 0.5,btnPosy + blueBgAddPosy + 5)
    self.bgLayer:addChild(lightBlueBg,9)

    local rechageGoldLimit,rechargedNum,isEnough =  acHljbVoApi:getRechageTipData( )
    rechargedNum = rechargedNum > rechageGoldLimit and rechageGoldLimit or rechargedNum
    local keepTip = GetTTFLabelWrap(getlocal("todayRechargeWithKeepTipStr",{rechageGoldLimit,rechargedNum,rechageGoldLimit}),G_isAsia() and 22 or 19,CCSize(G_VisibleSizeWidth * 0.88,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    keepTip:setPosition(lightBlueBg:getContentSize().width * 0.5,lightBlueBg:getContentSize().height - keepTip:getContentSize().height * 0.5 - 15)
    --keepTip:setColor(G_ColorYellowPro2)
    keepTip:setColor(ccc3(255,255,255))
    self.keepTip = keepTip
    lightBlueBg:addChild(keepTip)

    local blueLine = CCSprite:createWithSpriteFrameName("lineWhite.png")
    blueLine:setPosition(lightBlueBg:getContentSize().width * 0.5 , lightBlueBg:getContentSize().height - keepTip:getContentSize().height - 25)
    blueLine:setScaleX(lightBlueBg:getContentSize().width * 0.9 / blueLine:getContentSize().width)
    blueLine:setColor(ccc3(144,237,252))
    lightBlueBg:addChild(blueLine)

    local addLimit,addRate = acHljbVoApi:getRechagedKeepNumAndRate( )
    local addLimitLb = GetTTFLabel(getlocal("keepLimitUpTip",{addLimit}),G_isAsia() and 21 or 18,true)
    addLimitLb:setAnchorPoint(ccp(0,0.5))
    addLimitLb:setPosition(25,lightBlueBg:getContentSize().height * 0.54-10)
    addLimitLb:setColor(G_ColorYellowPro2)
    lightBlueBg:addChild(addLimitLb)

    local addRateLb = GetTTFLabel(getlocal("rebateTip",{addRate}),G_isAsia() and 21 or 18,true)
    addRateLb:setAnchorPoint(ccp(0,0.5))
    addRateLb:setPosition(25,lightBlueBg:getContentSize().height * 0.54 - 35)
    addRateLb:setColor(G_ColorYellowPro2)
    lightBlueBg:addChild(addRateLb)

    local function goTiantang()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if acHljbVoApi:isExTime() then
            acHljbVoApi:showbtnTip(getlocal("activity_hljb_acTimeEnd"))
            do return end
        end
        activityAndNoteDialog:closeAllDialog()
        vipVoApi:showRechargeDialog(self.layerNum+1)
    end
    local goItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",goTiantang,nil,getlocal("activity_continueRecharge_dayRecharge"),28)
    goItem:setScale(0.7)
    self.goItem = goItem
    local goBtn=CCMenu:createWithItem(goItem);
    goBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    goItem:setAnchorPoint(ccp(1,0))
    goBtn:setPosition(lightBlueBg:getContentSize().width - 10,25)
    lightBlueBg:addChild(goBtn)

    local isEnoughTip = GetTTFLabel(getlocal("taskCompleted"),22,true)
    isEnoughTip:setColor(G_ColorRed)
    isEnoughTip:setPosition(lightBlueBg:getContentSize().width - 10 - goItem:getContentSize().height ,50)
    lightBlueBg:addChild(isEnoughTip)
    self.isEnoughTip = isEnoughTip
    if isEnough then
        self.goItem:setVisible(false)
    else
        self.isEnoughTip:setVisible(false)
    end
end

function acHljbTabOne:refresh( )
    
end

function acHljbTabOne:autoActionShow(parent,parentWidth,parentHeight)
    --循环光效1--"BlackBg.png"
    local blendFunc=ccBlendFunc:new()--混合模式为 ONE ONE
    blendFunc.src=GL_ONE
    blendFunc.dst=GL_ONE
    local c1BgSp=CCSprite:createWithSpriteFrameName("BlackBg.png")
    c1BgSp:setScaleX(1.8)
    c1BgSp:setScaleY(0.2)
    c1BgSp:setOpacity(0)
    c1BgSp:setPosition(parentWidth,parentHeight + 150)
    parent:addChild(c1BgSp)

    local upChassis = CCSprite:createWithSpriteFrameName("acHljbBorderLight3.png")
    upChassis:setFlipY(true)
    upChassis:setPosition(getCenterPoint(c1BgSp))
    upChassis:setBlendFunc(blendFunc)
    c1BgSp:addChild(upChassis)

    local c2BgSp=CCSprite:createWithSpriteFrameName("BlackBg.png")
    c2BgSp:setScaleX(1.9)
    c2BgSp:setScaleY(0.38)
    c2BgSp:setOpacity(0)
    c2BgSp:setPosition(parentWidth,parentHeight - 140)
    parent:addChild(c2BgSp)

    local downChassis = CCSprite:createWithSpriteFrameName("acHljbBorderLight3.png")
    downChassis:setBlendFunc(blendFunc)
    downChassis:setPosition(getCenterPoint(c2BgSp))
    c2BgSp:addChild(downChassis)

    local rotate1 = CCRotateTo:create(3.5,180)
    local rotate12 = CCRotateTo:create(3.5,360)
    local rseq1=CCSequence:createWithTwoActions(rotate1,rotate12)
    local rotate1Repeat=CCRepeatForever:create(rseq1)
    upChassis:runAction(rotate1Repeat)

    local rotate2 = CCRotateTo:create(3.5,-180)
    local rotate22 = CCRotateTo:create(3.5,-360)
    local rseq2=CCSequence:createWithTwoActions(rotate2,rotate22)
    local rotate2Repeat=CCRepeatForever:create(rseq2)
    downChassis:runAction(rotate2Repeat)

    --循环光效2
    local leftHalo = CCSprite:createWithSpriteFrameName("acHljbBorderLight2.png")
    leftHalo:setAnchorPoint(ccp(1,0.5))
    leftHalo:setBlendFunc(blendFunc)
    leftHalo:setPosition(parentWidth,parentHeight)
    parent:addChild(leftHalo)

    local rightHalo = CCSprite:createWithSpriteFrameName("acHljbBorderLight2.png")
    rightHalo:setAnchorPoint(ccp(0,0.5))
    rightHalo:setBlendFunc(blendFunc)
    rightHalo:setFlipX(true)
    rightHalo:setPosition(parentWidth,parentHeight)
    parent:addChild(rightHalo)

    local scaleTo1=CCScaleTo:create(3,0.9)
    local scaleRe1 = CCScaleTo:create(3,1.1)
    local fadeIn1 = CCFadeTo:create(3,255)
    local fadeOut1 = CCFadeTo:create(3,105)

    local seq1=CCSequence:createWithTwoActions(fadeOut1,fadeIn1)
    local repeatForever1=CCRepeatForever:create(seq1)
    local seq12=CCSequence:createWithTwoActions(scaleTo1,scaleRe1)
    local repeatForever12=CCRepeatForever:create(seq12)

    leftHalo:runAction(repeatForever1)
    leftHalo:runAction(repeatForever12)


    local scaleTo2=CCScaleTo:create(3,0.9)
    local scaleRe2 = CCScaleTo:create(3,1.1)
    local fadeIn2 = CCFadeTo:create(3,255)
    local fadeOUt2 = CCFadeTo:create(3,105)

    local seq2=CCSequence:createWithTwoActions(fadeOUt2,fadeIn2)
    local repeatForever2=CCRepeatForever:create(seq2)
    local seq22=CCSequence:createWithTwoActions(scaleTo2,scaleRe2)
    local repeatForever22=CCRepeatForever:create(seq22)

    rightHalo:runAction(repeatForever2)
    rightHalo:runAction(repeatForever22)

    --循环光效3

    local boomSp2 = CCSprite:createWithSpriteFrameName("acHljbBoom1.png")
    boomSp2:setAnchorPoint(ccp(0.5,0))
    boomSp2:setBlendFunc(blendFunc)
    boomSp2:setPosition(parentWidth,parentHeight - 140)
    parent:addChild(boomSp2)

    local boomArr2=CCArray:create()
    for kk=1,15 do
      local nameStr="acHljbBoom"..kk..".png"
      local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
      boomArr2:addObject(frame)
    end
    local animationboom2=CCAnimation:createWithSpriteFrames(boomArr2)
    animationboom2:setDelayPerUnit(0.07)
    local animateboom2=CCAnimate:create(animationboom2)
    local repeatForeverboom2=CCRepeatForever:create(animateboom2)
    boomSp2:runAction(repeatForeverboom2)   

    local boomSp1 = CCSprite:createWithSpriteFrameName("acHljbBoom1.png")
    boomSp1:setAnchorPoint(ccp(0.5,1))
    boomSp1:setFlipY(true)
    boomSp1:setFlipX(true)
    boomSp1:setBlendFunc(blendFunc)
    boomSp1:setPosition(parentWidth,parentHeight + 155)
    parent:addChild(boomSp1)

    local boomArr1=CCArray:create()
    for kk=1,15 do
      local nameStr="acHljbBoom"..kk..".png"
      local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
      boomArr1:addObject(frame)
    end
    local animationboom1=CCAnimation:createWithSpriteFrames(boomArr1)
    animationboom1:setDelayPerUnit(0.09)
    local animateboom1=CCAnimate:create(animationboom1)
    local repeatForeverboom1=CCRepeatForever:create(animateboom1)
    boomSp1:runAction(repeatForeverboom1)   

    --贴图 1
    local borderLight1 = CCSprite:createWithSpriteFrameName("acHljbBorderLight1.png")
    borderLight1:setBlendFunc(blendFunc)
    borderLight1:setPosition(parentWidth,parentHeight)
    parent:addChild(borderLight1,1)

    --贴图2
    local border1Sp = CCSprite:createWithSpriteFrameName("acHljbBorder1.png")
    border1Sp:setAnchorPoint(ccp(0.5,1))
    border1Sp:setPosition(parentWidth,parentHeight + 175)
    parent:addChild(border1Sp,2)

    local border2Sp = CCSprite:createWithSpriteFrameName("acHljbBorder2.png")
    border2Sp:setAnchorPoint(ccp(0.5,0))
    border2Sp:setPosition(parentWidth-5,parentHeight - 200)
    parent:addChild(border2Sp,2)

    -- 礼物 sp

    self.giftSpTb = {}
    self.giftAcSpTb = {}
    for i=1,3 do
        local giftSp = CCSprite:createWithSpriteFrameName("acHljbGift"..i..".png")
        giftSp:setAnchorPoint(ccp(0.5,0))
        giftSp:setPosition(parentWidth + 5,parentHeight - 180)
        parent:addChild(giftSp)
        self.giftSpTb[i] = giftSp

        local giftAcSp = CCSprite:createWithSpriteFrameName("acHljbGift"..i..".png")
        giftAcSp:setAnchorPoint(ccp(0.5,0))
        giftAcSp:setBlendFunc(blendFunc)
        giftAcSp:setPosition(parentWidth + 5,parentHeight - 180)
        giftAcSp:setOpacity(0)
        parent:addChild(giftAcSp)
        self.giftAcSpTb[i] = giftAcSp
    end
    self:showGiftSp()
end

function acHljbTabOne:showGiftSp()
    self.keepItemTime = acHljbVoApi:getKeepItemAllDays( )
    -- print("self.keepItemTime---->>>",self.keepItemTime)
    if self.giftSpTb then
        for k,v in pairs(self.giftSpTb) do
            v:setOpacity(0)
        end
        if acHljbVoApi:isExTime() and acHljbVoApi:getAllKeepNums( ) == 0 then
            do return end
        end

        if self.keepItemTime > 0 or acHljbVoApi:getAllKeepNums( ) > 0 then
            if self.keepItemTime < 3 and self.giftSpTb[1] then
                self.giftSpTb[1]:setOpacity(255)
            elseif self.keepItemTime < 5 and self.giftSpTb[2] then
                self.giftSpTb[2]:setOpacity(255)
            elseif self.keepItemTime >= 5 and self.giftSpTb[3] then
                self.giftSpTb[3]:setOpacity(255)
            end
        end
    end
end

function acHljbTabOne:runKeepAction(actionOverCall,parent,parentWidth,parentHeight)
    self.keepItemTime = acHljbVoApi:getKeepItemAllDays( )
    local blendFunc=ccBlendFunc:new()--混合模式为 ONE ONE
    blendFunc.src=GL_ONE
    blendFunc.dst=GL_ONE

    if self.keepItemTime > 0 or acHljbVoApi:getAllKeepNums() > 0 then
        local delayT = 0
        local fadeInT = 0.07
        local fadeOutT = 0.75
        local acSp1,acSp2 = nil,nil
        if self.keepItemTime < 3 and self.giftSpTb[1] and self.giftAcSpTb[1] then
            delayT = 0
            acSp1 = self.giftSpTb[1]
            acSp2 = self.giftAcSpTb[1]
        elseif self.keepItemTime < 5 and self.giftSpTb[2] and self.giftAcSpTb[2] then
            delayT = 0.09
            acSp1 = self.giftSpTb[2]
            acSp2 = self.giftAcSpTb[2]
        elseif self.keepItemTime >=5 and self.giftSpTb[3] and self.giftAcSpTb[3] then
            delayT = 0.21
            fadeInT = 0.14
            acSp1 = self.giftSpTb[3]
            acSp2 = self.giftAcSpTb[3]
        end
        if self.keepItemTime == 0 and acHljbVoApi:getAllKeepNums() > 0 then
            delayT = 0
            acSp1 = self.giftSpTb[1]
            acSp2 = self.giftAcSpTb[1]
        end

        local det1 = CCDelayTime:create(delayT)
        local fadeIn = CCFadeIn:create(fadeInT)
        local acSp1Seq = CCSequence:createWithTwoActions(det1,fadeIn)  
        acSp1:runAction(acSp1Seq)


        local det2 = CCDelayTime:create(delayT)
        local fadeIn = CCFadeIn:create(fadeInT)
        local fadeOut = CCFadeOut:create(fadeOutT)
        local acSp2Arr = CCArray:create()
        acSp2Arr:addObject(det2)
        acSp2Arr:addObject(fadeIn)
        acSp2Arr:addObject(fadeOut)
        local acSp2Seq = CCSequence:create(acSp2Arr)
        acSp2:runAction(acSp2Seq)
    end

    local refreshSp2 = CCSprite:createWithSpriteFrameName("acHljbBorderLight4.png")
    refreshSp2:setScale(2)
    refreshSp2:setOpacity(0)
    refreshSp2:setPosition(parentWidth,parentHeight)
    refreshSp2:setBlendFunc(blendFunc)
    parent:addChild(refreshSp2)

    local fadeIn = CCFadeIn:create(0.23)
    local fadeOUt = CCFadeOut:create(1)
    local refeshSe2 = CCSequence:createWithTwoActions(fadeIn,fadeOUt)  
    refreshSp2:runAction(refeshSe2)


    local refreshSp = CCSprite:createWithSpriteFrameName("acHljbRef1.png")
    refreshSp:setBlendFunc(blendFunc)
    refreshSp:setAnchorPoint(ccp(0.5,0))
    refreshSp:setPosition(parentWidth + 5,parentHeight - 245)
    parent:addChild(refreshSp)
    local refreshArr=CCArray:create()
    for kk=1,9 do
      local nameStr="acHljbRef"..kk..".png"
      local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
      refreshArr:addObject(frame)
    end
    local animationRefresh=CCAnimation:createWithSpriteFrames(refreshArr)
    animationRefresh:setDelayPerUnit(0.03)
    local animateRefresh=CCAnimate:create(animationRefresh)
    local function refreshOverCall( ... )
            refreshSp:stopAllActions()
            refreshSp:removeFromParentAndCleanup(true)
    end
    local refOverFun=CCCallFunc:create(refreshOverCall)
    local refeshSeq = CCSequence:createWithTwoActions(animateRefresh,refOverFun)  
    refreshSp:runAction(refeshSeq)


end








