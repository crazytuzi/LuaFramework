acDoubleOneTabOne ={}
function acDoubleOneTabOne:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.isToday           = nil
    self.isbeginS          = true
    self.bgLayer           = nil
    self.layerNum          = nil
    self.tvWidth           = nil
    self.sellBtnTab        = {}
    self.sellBtnTab2       = {}
    self.sellMenu2Tab      = {}
    self.pic2Tab           = {}--:removeFromParentAndCleanup(true)
    self.pic2PosTab        = {}
    self.costNum2Tab       = {}
    self.gold2PicTab       = {}
    self.halfNum2Tab       = {}
    self.gold2Pic2Tab      = {}
    self.downBg            = nil
    self.cellSizeHeight    = nil
    self.touchDialogBg     =  nil
    self.touchDialogBg2    = nil
    self.isbeginSell       = false
    self.tv2               = nil
    self.tv                = nil
    self.clayer            =  nil
    self.cardPosTb         = {}
    self.cardOr            = 100
    self.touchArr          = {}
    self.temSp             =  nil
    self.maskCardBtn2      = nil
    self.maskCardBtn       = nil
    self.countDownTimeDec  = nil
    self.countDownTimeStr  = nil
    self.countDownTimeDec2 = nil
    self.countDownTimeStr2 = nil
    self.countDownNum      = nil
    self.countDownNum2     = nil
    self.unMaskCard2       = nil
    self.unMaskCard        = nil
    self.td                = nil
    self.countPosHeight      = G_VisibleSizeHeight*0.15+25
    self.locPos              = 40
    self.nextShopBtnNeedNum  = 0.32
    self.nextShopBtnNeedNum2 = 0.76
    self.nextShopBgNeedNum   = 0.14
    self.nextShopBgNeedNum2  = 0.57
    if G_isIphone5() then
        self.countPosHeight      = self.countPosHeight+10
        self.locPos              = 35
        self.nextShopBtnNeedNum  = 0.375
        self.nextShopBtnNeedNum2 = 0.795
        self.nextShopBgNeedNum   = 0.2
        self.nextShopBgNeedNum2  = 0.61
    end
    self.upShopDec      =nil
    self.downShopDec    =nil
    self.desBgSp        =nil
    self.desBgSpStr     =nil
    self.desBgSp2       =nil
    self.desBgSpStr2    =nil
    self.groupStr       =nil
    self.groupStr2      =nil
    self.groupStr2Bg    = nil
    self.isHasBuy       = false
    self.version        = 1
    self.upSubHeight    = -30
    self.upNeedLength   = 20
    self.upSubHeight2   = -20
    self.upBgSubHeight3 = 20
    self.touchDialogBasePosY =G_VisibleSizeHeight*0.4
    if G_isIphone5() then
        self.upSubHeight         = 0
        self.upNeedLength        = 0
        self.upSubHeight2        = 0
        self.upBgSubHeight3      = 70
        self.touchDialogBasePosY = G_VisibleSizeHeight*0.42
    end
    self.upBgJpg   =nil
    self.downBgJpg =nil
    return nc;

end

function acDoubleOneTabOne:init(layerNum)
    self.isToday =acDoubleOneVoApi:isToday()
    self.version =acDoubleOneVoApi:getVersion()
    self:socketFirst()
    self.bgLayer=CCLayer:create()
    self.layerNum = layerNum

    self.cellSizeHeight=(G_VisibleSizeHeight-186)*0.5
    self.showIdx2 =6
    self:initTableView()
    return self.bgLayer
end

function acDoubleOneTabOne:socketFirst( )
    if acDoubleOneVoApi:isInTime( ) then

      self.isbeginS=false
      local otherData,shop = acDoubleOneVoApi:returWhiPanicShop( ) --    根据配置 时间  自己计算 进入游戏时当前的抢购商店为第几个
          local isInTime,curTime = acDoubleOneVoApi:isInTime( )
      local function getRawardCallback(fn,data)
        local ret,sData = base:checkServerData(data)
        if ret==true then
            if sData and sData.data and sData.data.new112018 then
                if sData.data.new112018.qg then
                    acDoubleOneVoApi:setPanicedTab(sData.data.new112018.qg )--设置本轮已抢购的tab
                end
                if sData.data.new112018.t then
                    acDoubleOneVoApi:setLastTime(sData.data.new112018.t)--最近一次动作时间戳
                end
                if sData.data.new112018.dgem then
                    acDoubleOneVoApi:setNearScratchGold(sData.data.new112018.dgem )--最近一次挂奖钱数
                end
                if sData.data.new112018.shop then
                    acDoubleOneVoApi:setPanicedShopNums(sData.data.new112018.shop)
                end
                if sData.data.new112018.dg then
                    acDoubleOneVoApi:setScratchTb(sData.data.new112018.dg)--更新刮刮奖 奖池的金币数量
                end

                if sData.data.new112018.bg then
                    acDoubleOneVoApi:setBuyedTb(sData.data.new112018.bg)
                end

                if sData.data.new112018.buyshop then
                    acDoubleOneVoApi:setbuyShopNums(sData.data.new112018.buyshop)
                end


            end

              local function getRawardCallback(fn,data)
                local ret,sData = base:checkServerData(data)
                if ret==true then
                    if sData and sData.data and sData.data.new112018 then
                        if sData.data.new112018.buyshop then
                             acDoubleOneVoApi:setbuyShopNums(sData.data.new112018.buyshop)
                        end
                        if sData.data.new112018.bg then
                            acDoubleOneVoApi:setBuyedTb(sData.data.new112018.bg)
                        end

                        if sData.data.new112018.refshop then
                            acDoubleOneVoApi:setRefShopTb(sData.data.new112018.refshop)
                        elseif sData.data.refshop then
                            acDoubleOneVoApi:setRefShopTb(sData.data.refshop)
                        else
                            acDoubleOneVoApi:getRefShopTbSocket()
                        end
                        --------------------------差 限购5个的返回字段----------------------------！！！！！！
                    end
                end
              end
              socketHelper:doubleOnePanicBuying( getRawardCallback,"getbuyShop",nil,nil,curTime)
            if self.tv then
                self.tv:reloadData()
            end
            
        end
      end
      socketHelper:doubleOnePanicBuying( getRawardCallback,"getshop",shop,nil,curTime)
    else
         acDoubleOneVoApi:getRefShopTbSocket( )
    end
end

function acDoubleOneTabOne:initTableView( )
    local strSize2,strSize4 = 22,22
    local strSize3          = 22
    local timePosW          = 260
    local timeDecPosW       = 0--80
    if G_isAsia() then
        strSize2    = 28
        strSize4    = 24
        strSize3    = 25
        timePosW    = 190
        timeDecPosW = 0
    end
    local function click(hd,fn,idx) end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local bigBg =CCSprite:create("public/superWeapon/weaponBg.jpg")
    self.upBgJpg =CCSprite:create("public/superWeapon/weaponBg.jpg")
    self.downBgJpg =CCSprite:create("public/superWeapon/weaponBg.jpg")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
        bigBg:setScaleX((G_VisibleSizeWidth-42)/bigBg:getContentSize().width) 
        bigBg:setScaleY((G_VisibleSizeHeight-194)/bigBg:getContentSize().height)
        bigBg:ignoreAnchorPointForPosition(false)
        bigBg:setOpacity(150)
        bigBg:setAnchorPoint(ccp(0.5,0.5))
        bigBg:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.5-62))
        self.bgLayer:addChild(bigBg)

    local headMask  =CCSprite:createWithSpriteFrameName("greenMask.png")
    local subHeightMask = 156
    headMask:setScaleX(G_VisibleSizeWidth/headMask:getContentSize().width)

    headMask:setScaleY(60/headMask:getContentSize().height)
    headMask:setAnchorPoint(ccp(0.5,1))
    headMask:setPosition(ccp(G_VisibleSizeWidth*0.5,self.bgLayer:getContentSize().height-subHeightMask))
    self.bgLayer:addChild(headMask)

    local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),strSize3)
    acLabel:setAnchorPoint(ccp(0,1))
    acLabel:setPosition(ccp(70,self.bgLayer:getContentSize().height-165))
    acLabel:setColor(G_ColorYellow)
    self.bgLayer:addChild(acLabel,2)

    local acVo = acDoubleOneVoApi:getAcVo()
    local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    local messageLabel=GetTTFLabel(timeStr,strSize2)
    messageLabel:setAnchorPoint(ccp(0,1))
    messageLabel:setPosition(ccp(timePosW, acLabel:getPositionY()))
    self.bgLayer:addChild(messageLabel)
    self.timeLb=messageLabel
    self:updateAcTime()

    local maskSpHeight=self.bgLayer:getContentSize().height-133
    for k=1,3 do
        local leftMaskSp=CCSprite:createWithSpriteFrameName("maskBgLeftUse.png")
        leftMaskSp:setAnchorPoint(ccp(0,0))
        leftMaskSp:setPosition(0,38)
        leftMaskSp:setScaleY(maskSpHeight/leftMaskSp:getContentSize().height)
        self.bgLayer:addChild(leftMaskSp,6)

        local rightMaskSp=CCSprite:createWithSpriteFrameName("maskBgLeftUse.png")
        rightMaskSp:setFlipX(true)
        rightMaskSp:setAnchorPoint(ccp(0,0))
        rightMaskSp:setPosition(self.bgLayer:getContentSize().width-rightMaskSp:getContentSize().width,38)
        rightMaskSp:setScaleY(maskSpHeight/rightMaskSp:getContentSize().height)
        self.bgLayer:addChild(rightMaskSp,6)
    end
    local addPosx22 = 0
    -- groupSelfImage1 = "goldenTitleBg.png"
    -- groupSelfImage2 = "goldenTitleBg.png"
    groupSelfImage1 = "greenTitleBg.png"
    groupSelfImage2 = "greenTitleBg.png"


    local groupSelf = CCSprite:createWithSpriteFrameName(groupSelfImage1)
    local scaleY = 46/groupSelf:getContentSize().height
    groupSelf:setScaleY(scaleY)
    groupSelf:setScaleX(1)
    local needPosy2 = 45
    groupSelf:setPosition(ccp(G_VisibleSizeWidth*0.5+addPosx22,acLabel:getPositionY()-needPosy2))
    groupSelf:ignoreAnchorPointForPosition(false)
    groupSelf:setAnchorPoint(ccp(0.5,1))
    self.bgLayer:addChild(groupSelf,90)

    local adaStr = 27
    if G_getCurChoseLanguage() == "ru" then
        adaStr = 18
    end
    self.groupStr = GetTTFLabel("",adaStr)
    self.groupStr:setAnchorPoint(ccp(0.5,0.5))
    self.groupStr:setPosition(ccp(G_VisibleSizeWidth*0.5,groupSelf:getPositionY()-groupSelf:getContentSize().height*0.5*scaleY))
    self.groupStr:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(self.groupStr,90)

    local groupSelf2 = CCSprite:createWithSpriteFrameName(groupSelfImage2)
    groupSelf2:setScaleY(46/groupSelf:getContentSize().height)
    groupSelf2:setScaleX(1)
    groupSelf2:setPosition(ccp(G_VisibleSizeWidth*0.5+addPosx22,G_VisibleSizeHeight*0.4+self.upSubHeight+self.upSubHeight2))
    groupSelf2:ignoreAnchorPointForPosition(false)
    groupSelf2:setAnchorPoint(ccp(0.5,1))
    self.bgLayer:addChild(groupSelf2,90)

    self.groupStr2 = GetTTFLabel("",adaStr)
    self.groupStr2:setAnchorPoint(ccp(0.5,0.5))
    self.groupStr2:setPosition(ccp(G_VisibleSizeWidth*0.5,groupSelf2:getPositionY()-groupSelf2:getContentSize().height*0.5*scaleY))
    self.groupStr2:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(self.groupStr2,90)

    local function touch33(...)
        self:openInfo()
    end
    local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touch33,1,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,1))
    menuItemDesc:setScale(0.75)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-15)
    menuDesc:setPosition(ccp(G_VisibleSizeWidth-25,acLabel:getPositionY()+5))
    self.bgLayer:addChild(menuDesc,55)

    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createHorizontalWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth*0.84,self.cellSizeHeight),nil)
    self.tv:setAnchorPoint(ccp(0,0))
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-6)
    self.tv:setPosition(ccp(G_VisibleSizeWidth*0.08,G_VisibleSizeHeight*0.4+self.upSubHeight))
    self.tv:setMaxDisToBottomOrTop(120)
    self.bgLayer:addChild(self.tv)


    local function touchDialog(tag,object)
        -- print("啊啊 啊啊啊啊啊啊啊 ~~~~~~~~")
    end
    local function touchCard( tag,object )
        print("tag====>>>>",tag)
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        PlayEffect(audioCfg.mouseClick)
        if acDoubleOneVoApi:isInTime() ==false then
            -- print("no in time ~~~~~")
            do return end
        end

        if tag ==1111 then
            if self.expireStr:getString() == "" then
                self.expireStr:setString(getlocal("expireDesc"))
            end
        end

        if tag ==11 then
            if self.maskCardBtn2 then
                self:getScratchGold()
            end
        end
    end 

    local maskBg1 = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
    maskBg1:setTouchPriority(-(self.layerNum-1)*20-10)
    local rect=CCSizeMake(G_VisibleSizeWidth-42,G_VisibleSizeHeight*0.4)
    maskBg1:setContentSize(rect)
    maskBg1:setOpacity(0)
    maskBg1:setAnchorPoint(ccp(1,0))
    maskBg1:setIsSallow(true) -- 点击事件透下去
    maskBg1:setPosition(ccp(G_VisibleSizeWidth*0.1,G_VisibleSizeHeight*0.4))
    self.bgLayer:addChild(maskBg1,10)
    maskBg1:setVisible(true)

    local maskBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
    maskBg2:setTouchPriority(-(self.layerNum-1)*20-10)
    local rect=CCSizeMake(G_VisibleSizeWidth-42,G_VisibleSizeHeight*0.4)
    maskBg2:setContentSize(rect)
    maskBg2:setOpacity(0)
    maskBg2:setAnchorPoint(ccp(0,0))
    maskBg2:setIsSallow(true) -- 点击事件透下去
    maskBg2:setPosition(ccp(G_VisibleSizeWidth*0.9,G_VisibleSizeHeight*0.4))
    self.bgLayer:addChild(maskBg2,10)
    maskBg2:setVisible(true)

    local subHeight = -5
    if G_isIphone5() then
        subHeight =12
    end

    local needLength2 = self.cellSizeHeight+subHeight

    self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
    self.touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-10)
    local rect=CCSizeMake(G_VisibleSizeWidth-42,needLength2)---
    self.touchDialogBg:setContentSize(rect)
    self.touchDialogBg:setOpacity(0)
    self.touchDialogBg:setAnchorPoint(ccp(0,0))
    self.touchDialogBg:setIsSallow(true) -- 点击事件透下去
    self.touchDialogBg:setPosition(ccp(1000,self.touchDialogBasePosY+self.upSubHeight))---
    self.bgLayer:addChild(self.touchDialogBg,10)
    self.touchDialogBg:setVisible(true)

    self.touchDialogBgPosCenterY = self.touchDialogBg:getContentSize().height*0.5+self.touchDialogBg:getPositionY()
    
    self.countDownTimeDec = GetTTFLabel(getlocal("activity_double11_countdownStr"),strSize4)
    self.countDownTimeDec:setAnchorPoint(ccp(0.5,0.5))
    self.countDownTimeDec:setPosition(ccp(G_VisibleSizeWidth*0.5,self.touchDialogBg:getPositionY()+80))
    self.countDownTimeDec:setColor(G_ColorRed)
    self.bgLayer:addChild(self.countDownTimeDec,10)

    local min,sec = acDoubleOneVoApi:getCountdown( )
    self.countDownTimeStr = GetTTFLabel(getlocal("activity_double11_countdown",{min,sec}),strSize2)
    self.countDownTimeStr:setAnchorPoint(ccp(0.5,0.5))
    self.countDownTimeStr:setPosition(ccp(G_VisibleSizeWidth*0.5,self.touchDialogBg:getPositionY()+40))
    self.bgLayer:addChild(self.countDownTimeStr,10)

    self.upShopDec=GetTTFLabel(getlocal("activity_double11_buyBegin"),28)
    self.upShopDec:setAnchorPoint(ccp(0.5,0.5))
    self.upShopDec:setPosition(ccp(G_VisibleSizeWidth*0.5,self.touchDialogBg:getPositionY()+self.touchDialogBg:getContentSize().height*0.5+30))
    self.upShopDec:setColor(G_ColorRed)
    self.bgLayer:addChild(self.upShopDec,10)
    
    local bgNeedWidth = self.touchDialogBg:getContentSize().width
    local bgNeedHeight = self.touchDialogBg:getContentSize().height-self.upBgSubHeight3
    local bgNeedPosH = -10
    local boderSubPosH = 5
    self.upBgJpg:setScaleX(bgNeedWidth/self.upBgJpg:getContentSize().width)
    self.upBgJpg:setScaleY(bgNeedHeight/self.upBgJpg:getContentSize().height)
    self.upBgJpg:ignoreAnchorPointForPosition(false)
    self.upBgJpg:setAnchorPoint(ccp(0.5,0))
    self.upBgJpg:setPosition(ccp(self.touchDialogBg:getContentSize().width*0.5,bgNeedPosH))
    self.touchDialogBg:addChild(self.upBgJpg)

    local goldSp = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50,50,1,1),touchDialog)--"goldSpr.png",CCRect(15, 15, 5, 5)--equipBg_gray3.png
    goldSp:setContentSize(CCSizeMake(bgNeedWidth,bgNeedHeight))
    goldSp:setAnchorPoint(ccp(0.5,0))
    goldSp:setPosition(ccp(self.touchDialogBg:getContentSize().width*0.5,bgNeedPosH))---
    self.touchDialogBg:addChild(goldSp,1)

    local upBoderLayer =CCSprite:createWithSpriteFrameName("brown_fade1.png")
    upBoderLayer:setScaleX((bgNeedWidth-10)/upBoderLayer:getContentSize().width)
    upBoderLayer:setScaleY(80/upBoderLayer:getContentSize().height)
    upBoderLayer:setRotation(180)
    upBoderLayer:setOpacity(150)
    upBoderLayer:setAnchorPoint(ccp(0.5,1))
    upBoderLayer:setPosition(ccp(self.touchDialogBg:getContentSize().width*0.5,goldSp:getContentSize().height-boderSubPosH-upBoderLayer:getContentSize().height*(80/upBoderLayer:getContentSize().height)))
    goldSp:addChild(upBoderLayer)

    local addHeight2 = 5
    local goldLineSprite=CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
    goldLineSprite:setAnchorPoint(ccp(0.5,1))
    goldLineSprite:setPosition(ccp(bgNeedWidth*0.5,goldSp:getContentSize().height-boderSubPosH + addHeight2))
    goldSp:addChild(goldLineSprite,1)

    self:showPagebtn(1,G_VisibleSizeHeight*0.4+self.upSubHeight+self.upSubHeight2+needLength2*0.5)

    self.desBgSp = CCSprite:createWithSpriteFrameName("orangeMask.png")
    local scaleH = 40/self.desBgSp:getContentSize().height
    local scaleW = 350/goldSp:getContentSize().width
    self.desBgSp:setScaleY(40/self.desBgSp:getContentSize().height)
    self.desBgSp:setScaleX(350/goldSp:getContentSize().width)
    self.desBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5,self.touchDialogBg:getContentSize().height+self.touchDialogBg:getPositionY()-45-self.upNeedLength))
    self.desBgSp:ignoreAnchorPointForPosition(false)
    self.desBgSp:setVisible(false)
    self.desBgSp:setAnchorPoint(ccp(0.5,1))
    self.bgLayer:addChild(self.desBgSp,10)

    self.desBgSpStr = GetTTFLabel("",strSize2)
    self.desBgSpStr:setAnchorPoint(ccp(0.5,0.5))
    self.desBgSpStr:setPosition(ccp(self.desBgSp:getContentSize().width*0.5,self.desBgSp:getContentSize().height*0.5))
    self.desBgSpStr:setColor(G_ColorYellow)
    self.desBgSpStr:setScaleX(1/scaleW)
    self.desBgSpStr:setScaleY(1/scaleH)
    self.desBgSp:addChild(self.desBgSpStr)--self.touchDialogBg2:getContentSize().height*0.55+self.touchDialogBg2:getPositionY()

    self.unMaskCard = CCSprite:createWithSpriteFrameName("unMaskCard.png")
    self.unMaskCard:setAnchorPoint(ccp(0.5,0.5))
    self.unMaskCard:setPosition(ccp(self.touchDialogBg:getContentSize().width*0.5,self.touchDialogBg:getContentSize().height*0.5))
    self.touchDialogBg:addChild(self.unMaskCard,1)

    self.maskCardBtn=GetButtonItem("maskCard.png","maskCard.png","maskCard.png",touchCard,1111)--------------假数据 用配置里的数据 
    self.maskCardBtn:setAnchorPoint(ccp(0.5,0.5))

    if self.expireStr then
        self.expireStr:removeFromParentAndCleanup(true)
        self.expireStr = nil
    end
    self.expireStr = GetTTFLabel("",strSize2)--expireDesc
    self.expireStr:setPosition(getCenterPoint(self.maskCardBtn))
    self.expireStr:setColor(G_ColorRed)
    self.maskCardBtn:addChild(self.expireStr)


    local maskCardMenu1=CCMenu:createWithItem(self.maskCardBtn)
    maskCardMenu1:setAnchorPoint(ccp(0.5,0.5))
    maskCardMenu1:setPosition(ccp(self.touchDialogBg:getContentSize().width*0.5,self.touchDialogBg:getContentSize().height*0.5))
    maskCardMenu1:setTouchPriority(-(self.layerNum-1)*20-11)
    self.touchDialogBg:addChild(maskCardMenu1,1)

    self.touchDialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
    self.touchDialogBg2:setTouchPriority(-(self.layerNum-1)*20-10)
    local rect=CCSizeMake(G_VisibleSizeWidth-42,G_VisibleSizeHeight*0.4-70+self.upSubHeight+self.upSubHeight2)
    self.touchDialogBg2:setContentSize(rect)
    self.touchDialogBg2:setOpacity(0)
    self.touchDialogBg2:setAnchorPoint(ccp(0,0))
    self.touchDialogBg2:setIsSallow(true) -- 点击事件透下去
    self.touchDialogBg2:setPosition(ccp(21,30))
    self.bgLayer:addChild(self.touchDialogBg2,10)
    self.touchDialogBg2:setVisible(true)

    self.desBgSp2 = CCSprite:createWithSpriteFrameName("orangeMask.png")
    local scaleH2 = 40/self.desBgSp2:getContentSize().height
    local scaleW2= 350/goldSp:getContentSize().width
    self.desBgSp2:setScaleY(40/self.desBgSp2:getContentSize().height)
    self.desBgSp2:setScaleX(350/goldSp:getContentSize().width)
    self.desBgSp2:setPosition(ccp(G_VisibleSizeWidth*0.5,self.touchDialogBg2:getContentSize().height+self.touchDialogBg2:getPositionY()-60))
    self.desBgSp2:ignoreAnchorPointForPosition(false)
    self.desBgSp2:setAnchorPoint(ccp(0.5,1))
    self.bgLayer:addChild(self.desBgSp2,10)
    self.desBgSp2:setVisible(false)

    self.desBgSpStr2 = GetTTFLabel("",strSize2)
    self.desBgSpStr2:setAnchorPoint(ccp(0.5,0.5))
    self.desBgSpStr2:setPosition(ccp(self.desBgSp2:getContentSize().width*0.5,self.desBgSp2:getContentSize().height*0.5))
    self.desBgSpStr2:setColor(G_ColorYellow)
    self.desBgSpStr2:setScaleY(1/scaleH2)
    self.desBgSpStr2:setScaleX(1/scaleW2)
    self.desBgSp2:addChild(self.desBgSpStr2)

    self.countDownTimeDec2 = GetTTFLabel(getlocal("activity_double11_countdownStr"),strSize4)
    self.countDownTimeDec2:setAnchorPoint(ccp(0.5,0.5))
    self.countDownTimeDec2:setPosition(ccp(G_VisibleSizeWidth*0.5+timeDecPosW,self.touchDialogBg2:getPositionY()+80))
    self.countDownTimeDec2:setColor(G_ColorRed)
    self.bgLayer:addChild(self.countDownTimeDec2,10)

    local min,sec = acDoubleOneVoApi:getCountdown( )
    self.countDownTimeStr2 = GetTTFLabel(getlocal("activity_double11_countdown",{min,sec}),strSize2)
    self.countDownTimeStr2:setAnchorPoint(ccp(0.5,0.5))
    self.countDownTimeStr2:setPosition(ccp(G_VisibleSizeWidth*0.5+timeDecPosW,self.touchDialogBg2:getPositionY()+40))
    self.bgLayer:addChild(self.countDownTimeStr2,10)

    
    local bgNeedWidth2 = self.touchDialogBg2:getContentSize().width
    local bgNeedHeight2 = self.touchDialogBg2:getContentSize().height-20
    local bgNeedPosH2 = 5
    self.downBgJpg:setScaleX(bgNeedWidth2/self.downBgJpg:getContentSize().width)
    self.downBgJpg:setScaleY(bgNeedHeight2/self.downBgJpg:getContentSize().height)
    self.downBgJpg:ignoreAnchorPointForPosition(false)
    self.downBgJpg:setAnchorPoint(ccp(0.5,0))
    self.downBgJpg:setPosition(ccp(self.touchDialogBg:getContentSize().width*0.5,bgNeedPosH2))
    self.touchDialogBg2:addChild(self.downBgJpg)

    local goldSp2 =LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50,50,1,1),touchDialog) 
    local oldGoldSp2Height = goldSp2:getContentSize().height
    goldSp2:setContentSize(CCSizeMake(bgNeedWidth2,bgNeedHeight2))
    goldSp2:setAnchorPoint(ccp(0.5,0))
    goldSp2:setPosition(ccp(self.touchDialogBg2:getContentSize().width*0.5,bgNeedPosH2))
    self.touchDialogBg2:addChild(goldSp2,1)

    local upBoderLayer2 =CCSprite:createWithSpriteFrameName("brown_fade1.png")
    upBoderLayer2:setScaleX((bgNeedWidth-10)/upBoderLayer2:getContentSize().width)
    upBoderLayer2:setScaleY(80/upBoderLayer2:getContentSize().height)
    upBoderLayer2:setRotation(180)
    upBoderLayer2:setOpacity(150)
    upBoderLayer2:setAnchorPoint(ccp(0.5,1))
    upBoderLayer2:setPosition(ccp(self.touchDialogBg2:getContentSize().width*0.5,goldSp2:getContentSize().height-boderSubPosH-upBoderLayer2:getContentSize().height*(80/upBoderLayer2:getContentSize().height)))
    goldSp2:addChild(upBoderLayer2)

    local addHeight = 5
    local goldLineSprite2=CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
    goldLineSprite2:setAnchorPoint(ccp(0.5,1))
    goldLineSprite2:setPosition(ccp(bgNeedWidth*0.5,goldSp2:getContentSize().height-boderSubPosH + addHeight))
    goldSp2:addChild(goldLineSprite2,1)

    self.unMaskCard2 = CCSprite:createWithSpriteFrameName("unMaskCard.png")
    self.unMaskCard2:setAnchorPoint(ccp(0.5,0.5))
    self.unMaskCard2:setPosition(ccp(self.touchDialogBg2:getContentSize().width*0.5,self.touchDialogBg2:getContentSize().height*0.55))
    self.touchDialogBg2:addChild(self.unMaskCard2,1)
    
    self.countPosHeight =self.touchDialogBg2:getContentSize().height*0.55+self.touchDialogBg2:getPositionY()
    self.countDownNum2 = GetTTFLabelWrap("",25,CCSizeMake(250,0),kCCVerticalTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.countDownNum2:setAnchorPoint(ccp(0.5,0.5))
    self.countDownNum2:setPosition(ccp(G_VisibleSizeWidth*0.5,self.countPosHeight))
    self.countDownNum2:setColor(G_ColorYellow)
    self.bgLayer:addChild(self.countDownNum2,13)

    self.maskCardBtn2=GetButtonItem("maskCard.png","maskCard.png","maskCard.png",touchCard,11)--------------假数据 用配置里的数据 
    self.maskCardBtn2:setAnchorPoint(ccp(0.5,0.5))
    -- maskCardBtn:setScale(0.85)
    -- maskCardBtn:setScaleX(1)
    local maskCardMenu=CCMenu:createWithItem(self.maskCardBtn2)
    maskCardMenu:setAnchorPoint(ccp(0.5,0.5))
    maskCardMenu:setPosition(ccp(self.touchDialogBg2:getContentSize().width*0.5,self.touchDialogBg2:getContentSize().height*0.55))
    maskCardMenu:setTouchPriority(-(self.layerNum-1)*20-11)
    self.touchDialogBg2:addChild(maskCardMenu,1)


        local function showNextShopCall( )
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
            end
            PlayEffect(audioCfg.mouseClick)

            local isInTime,curTimeHour,curTimeMin = acDoubleOneVoApi:isInTime( )
            local nearScratchGoldTb = acDoubleOneVoApi:getNearScratchGold()
            -- print("curTimeHour------>",curTimeHour)
            if self.showNextShopBg then
                self:removeNextShowShopTvAndData()
            else
                local nextShopHeightNeedScale = G_isIphone5() and 0.5 or 0.68
                self.showNextShopBg = LuaCCScale9Sprite:createWithSpriteFrameName("greenBorder_1.png",CCRect(14,119,1,1),function( ) end)
                self.showNextShopBg:setContentSize(CCSizeMake(self.touchDialogBg2:getContentSize().width*0.94,self.touchDialogBg2:getContentSize().height*nextShopHeightNeedScale))
                self.showNextShopBg:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight* ((isInTime == false or curTimeMin > 54) and self.nextShopBgNeedNum2 or self.nextShopBgNeedNum)))
                self.showNextShopBg:setIsSallow(true)
                self.showNextShopBg:setTouchPriority(-(self.layerNum-1)*20-12)
                self.bgLayer:addChild(self.showNextShopBg,14)

                self:initNextShowShopTableView(self.showNextShopBg)
            end
        end 
        local isInTime,curTimeHour,curTimeMin = acDoubleOneVoApi:isInTime( )
        self.nextShopBtn = CCSprite:createWithSpriteFrameName("freshIcon.png")
        local btnTouchPic = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),showNextShopCall)
        btnTouchPic:setPosition(ccp(btnTouchPic:getContentSize().width*0.5,0))
        local needShopBtnWidth = btnTouchPic:getContentSize().height
        btnTouchPic:setContentSize(CCSizeMake(needShopBtnWidth * 2,needShopBtnWidth * 2))
        btnTouchPic:setIsSallow(false)
        btnTouchPic:setOpacity(0)
        btnTouchPic:setTouchPriority(-(self.layerNum-1)*20-12)
        self.nextShopBtn:addChild(btnTouchPic)
        self.bgLayer:addChild(self.nextShopBtn,12)

        self.nextShopBtn_2 = CCSprite:createWithSpriteFrameName("freshIcon_un.png")
        self.nextShopBtn_2:setPosition(ccp(G_VisibleSizeWidth - 70,G_VisibleSizeHeight * self.nextShopBtnNeedNum))
        self.bgLayer:addChild(self.nextShopBtn_2,12)
        if isInTime and curTimeMin < 55 then
            self.nextShopBtn_2:setVisible(false)
            self.nextShopBtn:setPosition(ccp(G_VisibleSizeWidth - 70,G_VisibleSizeHeight * self.nextShopBtnNeedNum))
        elseif (isInTime == false or curTimeMin > 54) then
            self.nextShopBtn:setPosition(ccp(G_VisibleSizeWidth - 70,G_VisibleSizeHeight * self.nextShopBtnNeedNum2))
        end

------ 
------
    self.downBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),click)
    self.downBg:setTouchPriority(-(self.layerNum-1)*20-1)
    local rect=CCSizeMake(G_VisibleSizeWidth*0.8*2,G_VisibleSizeHeight*0.4)
    self.downBg:setContentSize(rect)
    self.downBg:setOpacity(0)
    self.downBg:setAnchorPoint(ccp(0,0))
    self.downBg:setPosition(ccp(G_VisibleSizeWidth*0.1,20))
    self.bgLayer:addChild(self.downBg)

    self:initDownDialog(self.downBg)
   
    local otherData,shopIdx = acDoubleOneVoApi:returWhiPanicShop()
    local otherData,shopIdx2 = acDoubleOneVoApi:returWhiPanicShop(true)
    local otherData,shopIdx3 = acDoubleOneVoApi:returWhiPanicShop(false)
    local isInTime,curTimeHour,curTimeMin = acDoubleOneVoApi:isInTime( )
    if isInTime then
        self.upShopDec:setVisible(false)
        if tonumber(curTimeMin)> 54 then
            self.touchDialogBg:setVisible(true)
            self.desBgSp:setVisible(false)
            -- self.touchDialogBg:setPosition(ccp(21,G_VisibleSizeHeight*0.4))
            self.touchDialogBg:setPosition(ccp(21,self.touchDialogBasePosY+self.upSubHeight))
            self.desBgSpStr:setString(getlocal("activity_double11_shopName_"..shopIdx2))
            self.desBgSpStr2:setString(getlocal("activity_double11_shopName_"..shopIdx3))
            self.groupStr:setString(getlocal("activity_double11_shopName_"..shopIdx2))
            self.groupStr2:setString(getlocal("activity_double11_shopName_"..shopIdx3))
            if self.groupStr2Bg then
                local scalex,scaley= (self.groupStr2:getContentSize().width+140)/self.groupStr2Bg:getContentSize().width,(self.groupStr2:getContentSize().height+4)/self.groupStr2Bg:getContentSize().height
                self.groupStr2Bg:setScaleX(scalex)
                self.groupStr2Bg:setScaleY(scaley)
            end
            local nearScratchGoldTb = acDoubleOneVoApi:getNearScratchGold()
            -- print("curTimeHour------>",curTimeHour)
            if nearScratchGoldTb and nearScratchGoldTb["t"..curTimeHour] then
                self.unMaskCard:setVisible(true)
                if nearScratchGoldTb["t"..curTimeHour] >0 then
                    self.countDownNum2:setString(getlocal("activity_double11_scratchGoldStr",{nearScratchGoldTb["t"..curTimeHour]}))
                else
                    self.countDownNum2:setString(getlocal("activity_double11_scratchBlank"))
                end
                self.countDownNum2:setPosition(ccp(G_VisibleSizeWidth*0.5,self.touchDialogBgPosCenterY))--G_VisibleSizeHeight*0.6-self.locPos))
                self.maskCardBtn:setVisible(false)

            else
                self.maskCardBtn:setVisible(true)
            end
            self.maskCardBtn2:setVisible(false)
            if self.isHasBuy ==true then
                acDoubleOneVoApi:setPanicedTab(nil )
                self.isHasBuy =false
            end

            if self.showNextShopBg then
                self.showNextShopBg:setPositionY(G_VisibleSizeHeight * self.nextShopBgNeedNum2)
            end
        else
            self.touchDialogBg:setVisible(false)
            self.desBgSp:setVisible(false)
            self.countDownTimeDec:setVisible(false)
            self.countDownTimeStr:setVisible(false)
            self.touchDialogBg:setPosition(ccp(1000,self.touchDialogBasePosY+self.upSubHeight))

            self.unMaskCard:setVisible(false)
            self.maskCardBtn:setVisible(false)
            if self.expireStr:getString() ~= "" then
                self.expireStr:setString("")
            end

            self.desBgSpStr2:setString(getlocal("activity_double11_shopName_"..shopIdx2))
            self.groupStr:setString(getlocal("activity_double11_shopName_"..shopIdx))
            self.groupStr2:setString(getlocal("activity_double11_shopName_"..shopIdx2))
            if self.groupStr2Bg then
                local scalex,scaley= (self.groupStr2:getContentSize().width+140)/self.groupStr2Bg:getContentSize().width,(self.groupStr2:getContentSize().height+4)/self.groupStr2Bg:getContentSize().height
                self.groupStr2Bg:setScaleX(scalex)
                self.groupStr2Bg:setScaleY(scaley)
            end
            local nearScratchGoldTb = acDoubleOneVoApi:getNearScratchGold()
            -- print("curTimeHour------>",curTimeHour)
            if nearScratchGoldTb and nearScratchGoldTb["t"..curTimeHour] then
                self.unMaskCard2:setVisible(true)
                if nearScratchGoldTb["t"..curTimeHour] >0 then
                    self.countDownNum2:setString(getlocal("activity_double11_scratchGoldStr",{nearScratchGoldTb["t"..curTimeHour]}))
                else
                    self.countDownNum2:setString(getlocal("activity_double11_scratchBlank"))
                end
                self.countDownNum2:setPosition(ccp(G_VisibleSizeWidth*0.5,self.countPosHeight))
                self.maskCardBtn2:setVisible(false)
            else
                self.countDownNum2:setVisible(false)
            end
            if self.isHasBuy ==false then
                self.isHasBuy =true
            end

            if self.showNextShopBg then
                self.showNextShopBg:setPositionY(G_VisibleSizeHeight*  self.nextShopBgNeedNum)
            end
        end
        self:tick()
    else
        self.groupStr:setString(getlocal("activity_double11_shopName_1"))
        self.groupStr2:setString(getlocal("activity_double11_shopName_2"))
        if self.groupStr2Bg then
            local scalex,scaley= (self.groupStr2:getContentSize().width+140)/self.groupStr2Bg:getContentSize().width,(self.groupStr2:getContentSize().height+4)/self.groupStr2Bg:getContentSize().height
            self.groupStr2Bg:setScaleX(scalex)
            self.groupStr2Bg:setScaleY(scaley)
        end
        self.touchDialogBg:setVisible(true)
        self.desBgSp:setVisible(false)
        self.desBgSpStr:setString(getlocal("activity_double11_shopName_1"))
        self.touchDialogBg:setPosition(ccp(21,self.touchDialogBasePosY+self.upSubHeight))
        self.upShopDec:setVisible(true)
        self.touchDialogBg2:setVisible(true)
        self.desBgSp2:setVisible(false)
        self.desBgSpStr2:setString(getlocal("activity_double11_shopName_2"))
        self.countDownNum2:setPosition(ccp(G_VisibleSizeWidth*0.5,self.countPosHeight))
        self.countDownNum2:setVisible(false)
        self.maskCardBtn:setVisible(false)
        self.maskCardBtn2:setVisible(false)
        self.unMaskCard:setVisible(false)
        self.unMaskCard2:setVisible(false)
        local stEdPanicTimeTb = acDoubleOneVoApi:getStEdTime()
        local zeroTime=G_getWeeTs(base.serverTime)
        local hour=math.floor((base.serverTime - zeroTime)/3600)
        if hour < stEdPanicTimeTb[1] then
            self.countDownTimeStr:setString(acDoubleOneVoApi:getScratchBeginOutTime())
            self.countDownTimeStr2:setString(acDoubleOneVoApi:getScratchBeginOutTime(true))
        elseif hour > stEdPanicTimeTb[2] then
            self.countDownTimeStr:setString(acDoubleOneVoApi:getScratchEndOutTime())
            self.countDownTimeStr2:setString(acDoubleOneVoApi:getScratchEndOutTime(true))
        end

        if self.showNextShopBg then
            self.showNextShopBg:setPositionY(G_VisibleSizeHeight * self.nextShopBgNeedNum2)
        end
    end
end




function acDoubleOneTabOne:eventHandler( handler,fn,idx,cel )
if fn=="numberOfCellsInTableView" then
    return 1
  elseif fn=="tableCellSizeForIndex" then
    local larNums   = acDoubleOneVoApi:getShowDiaAllNums(2)
    local needWidth = G_VisibleSizeWidth * 0.33 * larNums
    return  CCSizeMake(needWidth,G_VisibleSizeHeight*0.4)-- -100
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()

    local function click( )
    end     
    local cellBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),click)
    cellBg:setTouchPriority(-(self.layerNum-1)*20-1)
    local rect=CCSizeMake(G_VisibleSizeWidth*0.8*2,G_VisibleSizeHeight*0.7)
    cellBg:setContentSize(rect)
    cellBg:setOpacity(0)
    cellBg:setAnchorPoint(ccp(0,0.5))
    cellBg:setPosition(ccp(0,0))
    cell:addChild(cellBg)

    self:pushRes(cellBg)
    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
  end
end

function acDoubleOneTabOne:pushRes(inBglayer)
    local strSize2 = 16
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =24
    elseif G_getCurChoseLanguage() =="ru" then
        strSize2 =13
    end
    local function touch(tag,object)
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        PlayEffect(audioCfg.mouseClick)
        -- print("here----tv----->")
        if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
            if tag >10 and tag <30 then
                local idx = tag -10

                local isInTime,curTime = acDoubleOneVoApi:isInTime( )
                local panicedTb = acDoubleOneVoApi:getPanicedTab( )
                local showShopEnd = nil
                if isInTime then
                    showShopEnd =panicedTb["t"..curTime]
                end
                if showShopEnd and SizeOfTable(showShopEnd)>0 then
                    for k,v in pairs(showShopEnd) do
                        if v =="i"..idx then
                            do return end
                        end
                    end
                end
                local costNum,halfNum,lastNum,rewardData,initRewardTb = acDoubleOneVoApi:getPanicShopTbData(idx,2)

                local otherData,upTime = acDoubleOneVoApi:isInTime( )
                if acDoubleOneVoApi:isInTime( ) then
                    local function panicBack( ... )
                        self:panicBack(idx,rewardData,costNum,halfNum,lastNum,upTime,initRewardTb)
                    end 
                    self.td=sellShowSureDialog:new()
                    self.td:init(panicBack,nil,false,costNum,halfNum,false,nil,sceneGame,rewardData[1],self.layerNum+1,nil,nil,nil,nil,nil,nil,nil,true)
                end
            end
        end
    end

        -- cardUpbg ="doudble11BtnV4_1.png"
        -- cardDownBg ="doudble11BtnV4_2.png"
    local cardUpbg   ="superShopBg1.png"
    local cardDownBg ="superShopBg1_down.png"

    local isInTime,curTime = acDoubleOneVoApi:isInTime( )
    local panicedTb        = acDoubleOneVoApi:getPanicedTab( )
    local showShopEnd      = panicedTb["t"..curTime]
    if isInTime ==false then
        acDoubleOneVoApi:setPanicedShopNums(nil)
        acDoubleOneVoApi:setPanicedTab(nil )
        acDoubleOneVoApi:setScratchTimeTb(nil)
    end
    local picStr  = "Icon_BG.png"
    local picNums = 10
    local costNum = "1000"--------------假数据 用配置里的数据 
    local halfNum = "100"
    local larNums,resNums,otherData,panicShopIdx = acDoubleOneVoApi:getShowDiaAllNums(2)--拿到最单行显示的最大个数
    local btnNeedHeightPos = 0.8
    local picShowPos       = G_VisibleSizeWidth*0.8
    local needSubHeight_1  = 30
    local needSubHeight_2  = 30

    local cardPosHeight = G_VisibleSizeHeight*0.8 - needSubHeight_1
    local needSubHeight = cardPosHeight*0.2 + needSubHeight_2
    -- local m = 0
    -- local n = 10

    local defulPosx = 20
    
    local shamShowTb = gDoubleOnerTb[panicShopIdx]
    local indexUse = 0
    -- print("resNums====>>>",resNums,panicShopIdx)
    local m = 0
    local n = 10
    for j=1,larNums do
        local jj = 1
        for i=1,2 do
            indexUse = indexUse + 1
            -- if self.version >= 5 then
                m=shamShowTb[indexUse] or j
                n =10+m
            -- else
            -- print("m=====>>>>",m)
            --     m=m+1
            --     n =n+1
            -- end
            jj=i-1
            if  indexUse <= resNums then--j*2 < resNums and m < resNums then
                local needWidth    = defulPosx+picShowPos*0.12*j+picShowPos*0.25*(j-1)
                local rewardData   = nil
                local strHeightPos = nil
                local picScale     = nil
                costNum,halfNum,lastNum,rewardData = acDoubleOneVoApi:getPanicShopTbData(m,2)
                if rewardData and SizeOfTable(rewardData)>0 then
                    picStr  = rewardData[1].pic
                    picNums = rewardData[1].num
                end
                local sellBtn=GetButtonItem(cardUpbg,cardDownBg,cardUpbg,touch,n)--------------假数据 用配置里的数据 
                sellBtn:setAnchorPoint(ccp(0.5,0.5))
                sellBtn:setScale(0.85)
                -- sellBtn:setScaleX(1)
                
                local sellMenu=CCMenu:createWithItem(sellBtn)
                sellMenu:setAnchorPoint(ccp(0.5,0.5))
                sellMenu:setPosition(ccp(needWidth,cardPosHeight*btnNeedHeightPos-needSubHeight*jj))
                sellMenu:setTouchPriority(-(self.layerNum-1)*20-3)
                inBglayer:addChild(sellMenu,1)
                table.insert(self.sellBtnTab,sellBtn)

                local pic = picStr--CCSprite:createWithSpriteFrameName(picStr)--------------假数据 用配置里的数据 
                pic:setAnchorPoint(ccp(0.5,0.5))
                pic:setPosition(ccp(sellMenu:getPositionX(),sellMenu:getPositionY()+28))
                inBglayer:addChild(pic,1)
                pic:setScale(85/pic:getContentSize().width)
                strHeightPos     = sellMenu:getPositionY()-25 --pic:getPositionY()-pic:getContentSize().height*0.5-5
                local picMiddle  = sellMenu:getPositionX()
                local picNumsStr = GetTTFLabel("x"..picNums,22)
                picNumsStr:setAnchorPoint(ccp(1,0))
                picNumsStr:setPosition(ccp(pic:getPositionX()+40,pic:getPositionY()-40))
                inBglayer:addChild(picNumsStr,2)

                local strBg = CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")
                strBg:setAnchorPoint(ccp(1,0))
                strBg:setOpacity(150)
                strBg:setScaleX((picNumsStr:getContentSize().width+5)/strBg:getContentSize().width)
                strBg:setScaleY((picNumsStr:getContentSize().height-3)/strBg:getContentSize().height)
                strBg:setPosition(ccp(pic:getPositionX()+40,pic:getPositionY()-40))
                inBglayer:addChild(strBg,1)

                local retimeBg =CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")----
                retimeBg:setScaleX((sellBtn:getContentSize().width-24)/retimeBg:getContentSize().width)
                retimeBg:setScaleY((sellBtn:getContentSize().height*0.85-4)/retimeBg:getContentSize().height)
                -- retimeBg:setOpacity(5)
                retimeBg:ignoreAnchorPointForPosition(false)
                retimeBg:setAnchorPoint(ccp(0.5,0.5))
                retimeBg:setPosition(ccp(sellMenu:getPositionX(),sellMenu:getPositionY()))
                inBglayer:addChild(retimeBg,2)
                retimeBg:setVisible(false)

                local panicedOver=GetTTFLabelWrap(getlocal("hasBuy"),strSize2,CCSizeMake(80,0),kCCVerticalTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                panicedOver:setPosition(ccp(sellMenu:getPositionX(),sellMenu:getPositionY()))
                panicedOver:setAnchorPoint(ccp(0.5,0.5));
                inBglayer:addChild(panicedOver,2)
                panicedOver:setColor(G_ColorGreen)
                panicedOver:setVisible(false)

                if showShopEnd and SizeOfTable(showShopEnd)>0 then
                    for k,v in pairs(showShopEnd) do
                        if v =="i"..m then
                            retimeBg:setVisible(true)
                            panicedOver:setVisible(true)
                        end
                    end
                end

                 local numSubWidth = 0
                 local numSubWidth2 = 0
                if costNum >9999 then
                    numSubWidth =-17

                elseif costNum>999 then
                    numSubWidth =-10
                end
                if halfNum > 1000 then
                    numSubWidth2 =-8
                elseif halfNum<10 and halfNum >-1 then
                    numSubWidth2 =10
                elseif (halfNum>99 and halfNum<1000) or halfNum <0 then
                    numSubWidth2 = -7
                end

                local costStr = GetTTFLabel(costNum,19)
                costStr:setAnchorPoint(ccp(0,0.5))
                costStr:setPosition(ccp(pic:getPositionX()-35,strHeightPos+5))
                inBglayer:addChild(costStr,1)
                costStr:setColor(G_ColorRed)

                local goldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
                goldIcon:setScale(0.8)
                goldIcon:setAnchorPoint(ccp(0,1))
                goldIcon:setPosition(ccp(costStr:getPositionX()+costStr:getContentSize().width+numSubWidth+20,strHeightPos+10))
                inBglayer:addChild(goldIcon,1)

                local rline = CCSprite:createWithSpriteFrameName("redline.jpg")
                rline:setAnchorPoint(ccp(0,0.5))
                rline:setScaleX(costStr:getContentSize().width / rline:getContentSize().width)
                rline:setPosition(ccp(pic:getPositionX()-35,strHeightPos+5))
                inBglayer:addChild(rline,1)

                local costStr2 = GetTTFLabel(halfNum,19)
                costStr2:setAnchorPoint(ccp(0,0.5))
                costStr2:setPosition(ccp(pic:getPositionX()-35,strHeightPos-10))
                inBglayer:addChild(costStr2,1)

                local panicNumsTb = acDoubleOneVoApi:getPanicedShopNums( )
                
                if panicNumsTb and SizeOfTable(panicNumsTb)>0 and panicNumsTb["i"..m] then 
                    lastNum = lastNum - tonumber(panicNumsTb["i"..m])
                    if lastNum <0 then
                        lastNum =0
                    end
                end

                local lastNumsStr = GetTTFLabel(getlocal("activity_double11_lastNums",{lastNum}),strSize2-2)
                lastNumsStr:setAnchorPoint(ccp(0.5,0))
                lastNumsStr:setPosition(ccp(pic:getPositionX(),strHeightPos-45))
                inBglayer:addChild(lastNumsStr,1)

                    lastNumsStr:setPositionY(strHeightPos- 25)

                    goldIcon:setAnchorPoint(ccp(1,0.5))
                    goldIcon:setPosition(ccp(picMiddle+10,strHeightPos-40))
                    costStr:setAnchorPoint(ccp(1,0.5))
                    costStr:setPosition(ccp(goldIcon:getPositionX() - goldIcon:getContentSize().width*0.8, strHeightPos-40))
                    rline:setAnchorPoint(ccp(1,0.5))
                    rline:setPosition(ccp(goldIcon:getPositionX() - goldIcon:getContentSize().width*0.8, strHeightPos-40))
                    costStr2:setPosition(ccp(picMiddle+10,goldIcon:getPositionY()))

                    local goldIcon2 = CCSprite:createWithSpriteFrameName("IconGold.png")
                    goldIcon2:setScale(0.8)
                    goldIcon2:setAnchorPoint(ccp(0,0.5))
                    goldIcon2:setPosition(ccp(costStr2:getPositionX()+costStr2:getContentSize().width,strHeightPos-40))
                    inBglayer:addChild(goldIcon2,1)

                local saleNum = string.format("%.2f",(costNum-halfNum)/costNum)*100
                local sellIcon = CCSprite:createWithSpriteFrameName("saleRedBg.png")
                sellIcon:setPosition(ccp(sellMenu:getPositionX()+43,sellMenu:getPositionY()+62))
                sellIcon:ignoreAnchorPointForPosition(false)
                sellIcon:setAnchorPoint(ccp(0.5,0.5))
                sellIcon:setRotation(0)
                inBglayer:addChild(sellIcon,2)

                local saleNumStr = GetTTFLabel("-"..saleNum.."%",18)
                saleNumStr:setAnchorPoint(ccp(0.5,0.5))
                saleNumStr:setPosition(getCenterPoint(sellIcon))
                saleNumStr:setRotation(10)
                sellIcon:addChild(saleNumStr)
            end
        end
    end
end

function acDoubleOneTabOne:panicBack(idx,rewardData,costNum,halfNum,lastNum,upTime,initRewardTb)
    if playerVo.gems<halfNum then
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("notEnoughGem",{getlocal("notEnoughGem")}),30)
        do return end
    end
    local panicNumsTb = acDoubleOneVoApi:getPanicedShopNums( )
    if panicNumsTb and SizeOfTable(panicNumsTb)>0 and panicNumsTb["i"..idx]>=lastNum then
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_double11_buyEndNums",{getlocal("activity_double11_buyEndNums")}),30)
        do return end
    end
    local isInTime,curTime = acDoubleOneVoApi:isInTime( )
    if upTime ~=curTime then
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_double11_buyEndNums"),30)
        local recordPoint = self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
        do return end
    end
    local otherData,shop = acDoubleOneVoApi:returWhiPanicShop( )      --    根据配置 时间  自己计算 进入游戏时当前的抢购商店为第几个
    local function getRawardCallback(fn,data)
        local ret,sData = base:checkServerData(data)
        if ret==true then
            -- print("yes~~~~~")
            if sData.data and sData.data.new112018 then
                local gems = playerVoApi:getGems()
                playerVoApi:setGems(gems-halfNum)
                if sData.data.new112018.qg then
                    local qg = sData.data.new112018.qg
                    acDoubleOneVoApi:setPanicedTab(qg )
                    local rewarName = nil
                    for k,v in pairs(qg) do--G_showRewardTip
                        if k == "t"..curTime then
                            for k,v in pairs(rewardData) do
                                rewarName =v.name
                                if v.type =="p" and v.key == "p601" then
                                else
                                    G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                                end
                            end
                        end
                    end
                    G_showRewardTip(initRewardTb,true)
                    local showTitle = getlocal("activity_new112018_title")

                    local shwoMessage = getlocal("activity_double11_showAllBody",{playerVoApi:getPlayerName(),showTitle,rewarName})
                    if rewarName ~=nil then
                        chatVoApi:sendSystemMessage(shwoMessage)
                    end
                end
                if sData.data.new112018.dgem then
                    acDoubleOneVoApi:setNearScratchGold(sData.data.new112018.dgem )--最近一次挂奖钱数
                end
                if sData.data.new112018.shop then
                    acDoubleOneVoApi:setPanicedShopNums(sData.data.new112018.shop)
                end
                if sData.data.new112018.dg then
                    acDoubleOneVoApi:setScratchTb(sData.data.new112018.dg)--更新刮刮奖 奖池的金币数量
                end
                if sData.data.new112018.buyshop then
                    acDoubleOneVoApi:setbuyShopNums(sData.data.new112018.buyshop)
                end
            end
            local recordPoint = self.tv:getRecordPoint()
            self.tv:reloadData()
            self.tv:recoverToRecordPoint(recordPoint)
        else
            if sData.data and sData.data.new112018 then
                local gems = playerVoApi:getGems()
                playerVoApi:setGems(gems-halfNum)
                if sData.data.new112018.qg then
                    local qg = sData.data.new112018.qg
                    acDoubleOneVoApi:setPanicedTab(qg )
                end
                if sData.data.new112018.dgem then
                    acDoubleOneVoApi:setNearScratchGold(sData.data.new112018.dgem )--最近一次挂奖钱数
                end
                if sData.data.new112018.shop then
                    acDoubleOneVoApi:setPanicedShopNums(sData.data.new112018.shop)
                end
                if sData.data.new112018.dg then
                    acDoubleOneVoApi:setScratchTb(sData.data.new112018.dg)--更新刮刮奖 奖池的金币数量
                end
                if sData.data.new112018.buyshop then
                    acDoubleOneVoApi:setbuyShopNums(sData.data.new112018.buyshop)
                end
            end
            local recordPoint = self.tv:getRecordPoint()
            self.tv:reloadData()
            self.tv:recoverToRecordPoint(recordPoint)
        end
    end
    socketHelper:doubleOnePanicBuying( getRawardCallback,"grab",shop,'i'..idx,curTime ) --curTime: 用于后端校验当前购买时间是否相等

 end 

function acDoubleOneTabOne:initDownDialog(inBglayer)

    local strSize2 = G_isAsia() and 20 or 18

    local function touch(tag,object) end

    local isInTime,curTime = acDoubleOneVoApi:isInTime( )
    local panicedTb   = acDoubleOneVoApi:getPanicedTab( )
    local showShopEnd = panicedTb["t"..curTime]
    local cardUpbg    = "cardUpBg.png"
    local cardDownBg  = "cardDownBg.png"

    local picStr   = "Icon_BG.png"
    local picNums  = 10
    local costNum  = "1000"--------------假数据 用配置里的数据 
    local halfNum  = "100"
    local lastNums = 100
    local larNums,resNums  = acDoubleOneVoApi:getShowDiaAllNums(2)--拿到最单行显示的最大个数
    local btnNeedHeightPos = 0.8
    local picShowPos       = G_VisibleSizeWidth*0.8
    larNums = 3------
    local cardPosHeight = G_VisibleSizeHeight*0.4-70
    local needSubHeight = cardPosHeight*0.45+20
    local m = 0
    local n = 10
    for j=1,larNums do
        local jj = 1
        for i=1,2 do
            m=m+1
            n =n+1
            jj=i-1
            if  m < 7 then--j*2 < resNums and m < resNums then
                local needWidth   = 5+picShowPos*0.12*j+picShowPos*0.25*(j-1)+G_VisibleSizeWidth
                local rewardData  = nil
                local strHeightPos=nil
                local picScale = nil
                costNum,halfNum,lastNums,rewardData = acDoubleOneVoApi:getPanicShopTbData(m,2,true)
                if rewardData and SizeOfTable(rewardData)>0 then
                    picStr =rewardData[1].pic
                    picNums =rewardData[1].num
                end
                local sellBtn=GetButtonItem(cardUpbg,cardDownBg,cardUpbg,touch,n)--------------假数据 用配置里的数据 
                sellBtn:setAnchorPoint(ccp(0.5,0.5))
                sellBtn:setScale(0.85)
                sellBtn:setScaleX(1)
                local sellMenu=CCMenu:createWithItem(sellBtn)
                sellMenu:setAnchorPoint(ccp(0.5,0.5))
                sellMenu:setPosition(ccp(needWidth,cardPosHeight*btnNeedHeightPos-needSubHeight*jj))
                sellMenu:setTouchPriority(-(self.layerNum-1)*20-3)
                inBglayer:addChild(sellMenu,1)
                table.insert(self.sellBtnTab2,sellBtn)
                table.insert(self.sellMenu2Tab,sellMenu)
                

                pic = picStr--CCSprite:createWithSpriteFrameName(picStr)--------------假数据 用配置里的数据 
                pic:setAnchorPoint(ccp(0.5,0.5))
                pic:setPosition(ccp(sellMenu:getPositionX(),sellMenu:getPositionY()+28))
                inBglayer:addChild(pic,1)
                table.insert(self.pic2PosTab,pic:getPosition())
                table.insert(self.pic2Tab,pic)
                pic:setScale(90/pic:getContentSize().width)
                strHeightPos = sellMenu:getPositionY()-25 --pic:getPositionY()-pic:getContentSize().height*0.5-5

                local picNumsStr = GetTTFLabel("x"..picNums,25)
                picNumsStr:setAnchorPoint(ccp(1,0))
                picNumsStr:setPosition(ccp(pic:getPositionX()+40,pic:getPositionY()-40))
                inBglayer:addChild(picNumsStr,1)

                 local numSubWidth = 0
                 local numSubWidth2 = 0
                if costNum >9999 then
                    numSubWidth =-17

                elseif costNum>999 then
                    numSubWidth =-10
                end
                if halfNum > 1000 then
                    numSubWidth2 =-8
                elseif halfNum<10 and halfNum >-1 then
                    numSubWidth2 =10
                elseif (halfNum>99 and halfNum<1000) or halfNum <0 then
                    numSubWidth2 = -7
                end

                local costStr = GetTTFLabel(costNum,20)
                costStr:setPosition(ccp(pic:getPositionX()-35,strHeightPos))
                inBglayer:addChild(costStr,1)
                costStr:setColor(G_ColorRed)
                table.insert(self.costNum2Tab,costStr)

                local goldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
                goldIcon:setScale(0.8)
                goldIcon:setPosition(ccp(costStr:getPositionX()+costStr:getContentSize().width+numSubWidth,strHeightPos))
                inBglayer:addChild(goldIcon,1)
                table.insert(self.gold2PicTab,goldIcon)

                local rline = CCSprite:createWithSpriteFrameName("redline.jpg")
                rline:setScaleX(costStr:getContentSize().width / rline:getContentSize().width)
                rline:setPosition(ccp(pic:getPositionX()-35,strHeightPos))
                inBglayer:addChild(rline,1)

                local costStr2 = GetTTFLabel(halfNum,20)
                costStr2:setPosition(ccp(goldIcon:getPositionX()+25,strHeightPos))
                inBglayer:addChild(costStr2,1)
                table.insert(self.halfNum2Tab,costStr2)

                local goldIcon2 = CCSprite:createWithSpriteFrameName("IconGold.png")
                goldIcon2:setScale(0.8)
                goldIcon2:setPosition(ccp(costStr2:getPositionX()+costStr2:getContentSize().width+numSubWidth2,strHeightPos))
                inBglayer:addChild(goldIcon2,1)
                table.insert(self.gold2Pic2Tab,goldIcon2)

                local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
                lineSp:setAnchorPoint(ccp(0.5,0.5))
                lineSp:setScaleX(pic:getContentSize().width/lineSp:getContentSize().width)
                lineSp:setPosition(ccp(pic:getPositionX(),strHeightPos-20))
                inBglayer:addChild(lineSp,1)

                local lastNumsStr = GetTTFLabel(getlocal("activity_double11_lastNums",{lastNums}),strSize2)
                lastNumsStr:setPosition(ccp(pic:getPositionX(),strHeightPos-35))
                inBglayer:addChild(lastNumsStr,1)
            end
        end
    end
end

function acDoubleOneTabOne:tick( )
    self:updateAcTime()
      local istoday = acDoubleOneVoApi:isToday()
      if istoday ~= self.isToday then
            acDoubleOneVoApi:setScratchTimeTb(nil)
            acDoubleOneVoApi:setPanicedShopNums(nil)
            acDoubleOneVoApi:setPanicedTab(nil)
            acDoubleOneVoApi:setScratchTimeTb(nil)
            acDoubleOneVoApi:setLastScratchGold(nil)
            acDoubleOneVoApi:setNearScratchGold(nil)
            self.isToday = istoday
            acDoubleOneVoApi:updateLastTime()
            if self.tv then
                self.tv:reloadData()
            end
      end

    local isInTime,curTimeHour,curTimeMin = acDoubleOneVoApi:isInTime( )
    local otherData,shopIdx  = acDoubleOneVoApi:returWhiPanicShop()
    local otherData,shopIdx2 = acDoubleOneVoApi:returWhiPanicShop(true)
    local otherData,shopIdx3 = acDoubleOneVoApi:returWhiPanicShop(false)

    if isInTime and curTimeMin < 55 then
        if self.nextShopBtn_2 then
            self.nextShopBtn_2:setVisible(false)
        end
        if self.nextShopBtn then
            self.nextShopBtn:setPositionY(G_VisibleSizeHeight*self.nextShopBtnNeedNum)
        end
    elseif (isInTime == false or curTimeMin > 54) then
        if self.nextShopBtn_2 then
            self.nextShopBtn_2:setVisible(true)
        end
        if self.nextShopBtn then
            self.nextShopBtn:setPositionY(G_VisibleSizeHeight*self.nextShopBtnNeedNum2)
        end
    end

    if isInTime then
        if self.isbeginS ==true then
            self:socketFirst()
        end
        self.upShopDec:setVisible(false)
        if tonumber(curTimeMin)> 54 then
            if self.td  then
                self.td:close()
                self.td =nil
            end
            self.touchDialogBg:setVisible(true)
            self.desBgSp:setVisible(false)
            self.touchDialogBg:setPosition(ccp(21,self.touchDialogBasePosY+self.upSubHeight))
            self.countDownTimeDec:setVisible(true)
            self.countDownTimeStr:setVisible(true)

            self.desBgSpStr:setString(getlocal("activity_double11_shopName_"..shopIdx2))
            self.desBgSpStr2:setString(getlocal("activity_double11_shopName_"..shopIdx3))
            self.groupStr:setString(getlocal("activity_double11_shopName_"..shopIdx2))
            self.groupStr2:setString(getlocal("activity_double11_shopName_"..shopIdx3))
            if self.groupStr2Bg then
                local scalex,scaley= (self.groupStr2:getContentSize().width+140)/self.groupStr2Bg:getContentSize().width,(self.groupStr2:getContentSize().height+4)/self.groupStr2Bg:getContentSize().height
                self.groupStr2Bg:setScaleX(scalex)
                self.groupStr2Bg:setScaleY(scaley)
            end

            if acDoubleOneVoApi:isLastTim( ) then
                self.countDownNum2:setString(getlocal("activity_double11_buyEnd"))
                self.countDownNum2:setFontSize(28)
                self.countDownNum2:setColor(G_ColorYellow)
                self.countDownNum2:setPosition(ccp(G_VisibleSizeWidth*0.5,self.countPosHeight+30))

                self.countDownNum2:setVisible(true)
                self.desBgSpStr2:setVisible(false)
                self.groupStr2:setVisible(false)
                if self.groupStr2Bg then
                    self.groupStr2Bg:setVisible(false)
                end
                self.countDownTimeStr2:setVisible(false)
                self.countDownTimeDec2:setVisible(false)
                self.unMaskCard2:setVisible(false)
                self.unMaskCard:setVisible(false)
                self.maskCardBtn2:setVisible(false)
                self.maskCardBtn:setVisible(false)
            else

                self.maskCardBtn2:setVisible(false)
                acDoubleOneVoApi:setPanicedShopNums(nil)
                self.isbeginSell = true

                local curScra = nil
                local scratchTimeTb = acDoubleOneVoApi:getScratchTimeTb()
                local nearScratchGoldTb = acDoubleOneVoApi:getNearScratchGold()
                if scratchTimeTb and SizeOfTable(scratchTimeTb)>0 then
                    for k,v in pairs(scratchTimeTb) do
                        if curTimeHour ==v then
                            curScra =true
                        end
                    end
                end
                if curScra then
                    self.unMaskCard2:setVisible(true)

                        if nearScratchGoldTb and SizeOfTable(nearScratchGoldTb)>0 and nearScratchGoldTb["t"..curTimeHour] and nearScratchGoldTb["t"..curTimeHour] >0 then
                            self.countDownNum2:setString(getlocal("activity_double11_scratchGoldStr",{nearScratchGoldTb["t"..curTimeHour]}))
                            self.countDownNum2:setPosition(ccp(G_VisibleSizeWidth*0.5,self.touchDialogBgPosCenterY))--G_VisibleSizeHeight*0.6-self.locPos))
                            self.maskCardBtn:setVisible(false)
                            self.unMaskCard:setVisible(true)

                        end
                    self.countDownNum2:setVisible(true)
                    self.maskCardBtn2:setVisible(false)
                else
                    self.maskCardBtn:setVisible(true)
                    self.countDownNum2:setVisible(false)
                end
            end

            if self.showNextShopBg then
                self.showNextShopBg:setPositionY(G_VisibleSizeHeight*  self.nextShopBgNeedNum2)
            end

        else
            if self.showNextShopBg then
                self.showNextShopBg:setPositionY(G_VisibleSizeHeight*  self.nextShopBgNeedNum)
            end

            self.touchDialogBg:setVisible(false)
            self.desBgSp:setVisible(false)
            self.countDownTimeDec:setVisible(false)
            self.countDownTimeStr:setVisible(false)
            self.touchDialogBg:setPosition(ccp(1000,self.touchDialogBasePosY+self.upSubHeight))

            self.desBgSpStr:setString(getlocal("activity_double11_shopName_"..shopIdx))
            self.desBgSpStr2:setString(getlocal("activity_double11_shopName_"..shopIdx2))
            self.groupStr:setString(getlocal("activity_double11_shopName_"..shopIdx))
            self.groupStr2:setString(getlocal("activity_double11_shopName_"..shopIdx2))
            if self.groupStr2Bg then
                local scalex,scaley= (self.groupStr2:getContentSize().width+140)/self.groupStr2Bg:getContentSize().width,(self.groupStr2:getContentSize().height+4)/self.groupStr2Bg:getContentSize().height
                self.groupStr2Bg:setScaleX(scalex)
                self.groupStr2Bg:setScaleY(scaley)
            end
            local nearScratchGoldTb = acDoubleOneVoApi:getNearScratchGold()--getLastScratchGold
            local scratchTimeTb = acDoubleOneVoApi:getScratchTimeTb()
            self.countDownNum2:setPosition(ccp(G_VisibleSizeWidth*0.5,self.countPosHeight))

            local curScra = nil
            if scratchTimeTb and SizeOfTable(scratchTimeTb)>0 then
                for k,v in pairs(scratchTimeTb) do
                    if curTimeHour ==v then
                        curScra =true
                    end
                end
            end
            if curScra then
                self.unMaskCard2:setVisible(true)
                    if nearScratchGoldTb and SizeOfTable(nearScratchGoldTb)>0 and nearScratchGoldTb["t"..curTimeHour] and nearScratchGoldTb["t"..curTimeHour] >0 then
                        self.countDownNum2:setString(getlocal("activity_double11_scratchGoldStr",{nearScratchGoldTb["t"..curTimeHour]}))
                    end
                self.countDownNum2:setVisible(true)
                self.maskCardBtn2:setVisible(false)
            else
                self.maskCardBtn2:setVisible(true)
                self.countDownNum2:setVisible(false)
            end
            if self.isbeginSell==true then
                self.isbeginSell=false
                acDoubleOneVoApi:setPanicedTab(nil )
                self.tv:reloadData()
                self:refreshDownDia()
            end
        end

        local min,sec =acDoubleOneVoApi:getCountdown()
        self.countDownTimeStr:setString(getlocal("activity_double11_countdown",{min,sec}))
        self.countDownTimeStr2:setString(getlocal("activity_double11_countdown",{min,sec}))
        if min <=4 and min >=0 then
            self.maskCardBtn2:setVisible(false)
            self.unMaskCard2:setVisible(false)
        else --判断 如果挂过奖 怎么怎么样
        end
    else
        self.groupStr:setString(getlocal("activity_double11_shopName_1"))
        self.groupStr2:setString(getlocal("activity_double11_shopName_2"))
        if self.groupStr2Bg then
            local scalex,scaley= (self.groupStr2:getContentSize().width+140)/self.groupStr2Bg:getContentSize().width,(self.groupStr2:getContentSize().height+4)/self.groupStr2Bg:getContentSize().height
            self.groupStr2Bg:setScaleX(scalex)
            self.groupStr2Bg:setScaleY(scaley)
        end
        self.touchDialogBg:setVisible(true)
        self.desBgSp:setVisible(false)
        self.desBgSpStr:setString(getlocal("activity_double11_shopName_1"))
        -- self.touchDialogBg:setPosition(ccp(21,G_VisibleSizeHeight*0.4))
        self.touchDialogBg:setPosition(ccp(21,self.touchDialogBasePosY+self.upSubHeight))
        self.upShopDec:setVisible(true)
        self.touchDialogBg2:setVisible(true)
        self.desBgSp2:setVisible(false)
        self.desBgSpStr2:setString(getlocal("activity_double11_shopName_2"))
        self.maskCardBtn:setVisible(false)
        self.maskCardBtn2:setVisible(false)
        self.unMaskCard:setVisible(false)
        self.unMaskCard2:setVisible(false)
        self.countDownNum2:setPosition(ccp(G_VisibleSizeWidth*0.5,self.countPosHeight))
        self.countDownNum2:setVisible(false)

        local stEdPanicTimeTb = acDoubleOneVoApi:getStEdTime()
        local zeroTime=G_getWeeTs(base.serverTime)
        local hour=math.floor((base.serverTime - zeroTime)/3600)

        if hour <stEdPanicTimeTb[1] then
            self.countDownTimeStr:setString(acDoubleOneVoApi:getScratchBeginOutTime())
            self.countDownTimeStr2:setString(acDoubleOneVoApi:getScratchBeginOutTime(true))
        elseif hour >stEdPanicTimeTb[2] then
            self.countDownTimeStr:setString(acDoubleOneVoApi:getScratchEndOutTime())
            self.countDownTimeStr2:setString(acDoubleOneVoApi:getScratchEndOutTime(true))
        end

        if self.showNextShopBg then
            self.showNextShopBg:setPositionY(G_VisibleSizeHeight*  self.nextShopBgNeedNum2)
        end
    end
    
      
end
function acDoubleOneTabOne:refreshDownDia( )
    local function touch(tag,object)
    end
    local isInTime,curTime = acDoubleOneVoApi:isInTime( )
    local panicedTb   = acDoubleOneVoApi:getPanicedTab( )
    local showShopEnd = panicedTb["t"..curTime]
    local picStr      = "Icon_BG.png"
    local picNums     = 10
    local costNum     = "1000"--------------假数据 用配置里的数据 
    local halfNum     = "100"
    local lastNums    = 100
    local larNums,resNums  = acDoubleOneVoApi:getShowDiaAllNums(2)--拿到最单行显示的最大个数
    local btnNeedHeightPos = 0.8
    local picShowPos    = G_VisibleSizeWidth*0.8
    larNums=3------
    local cardPosHeight = G_VisibleSizeHeight*0.4-70
    local needSubHeight = cardPosHeight*0.45+20
    local m = 0
    local n = 10
    for j=1,larNums do
        local jj = 1
        for i=1,2 do
            m=m+1
            n =n+1
            jj=i-1
            if  m < 7 then--j*2 < resNums and m < resNums then
                local needWidth   = 5+picShowPos*0.12*j+picShowPos*0.25*(j-1)
                local rewardData  = nil
                local strHeightPos=nil
                local picScale = nil
                costNum,halfNum,lastNum,rewardData = acDoubleOneVoApi:getPanicShopTbData(m,2,true)
                -- print("self.sellID ==1----->",costNum,halfNum,lastNum,rewardData)
                if rewardData and SizeOfTable(rewardData)>0 then
                    picStr =rewardData[1].pic
                    picNums =rewardData[1].num
                end
                local sellBtn=self.sellBtnTab[m]--------------假数据 用配置里的数据 
                local sellMenu=self.sellMenu2Tab[m]
                -- print("m~~~~~~~",m)
                if self.pic2Tab[m] then
                    self.pic2Tab[m]:removeFromParentAndCleanup(true)
                end
                self.pic2Tab[m] =picStr--CCSprite:createWithSpriteFrameName(picStr)--------------假数据 用配置里的数据 
                self.pic2Tab[m]:setAnchorPoint(ccp(0.5,0.5))
                self.pic2Tab[m]:setPosition(ccp(sellMenu:getPositionX(),sellMenu:getPositionY()+28))
                self.downBg:addChild(self.pic2Tab[m],1)
                self.pic2Tab[m]:setScale(90/self.pic2Tab[m]:getContentSize().width)
                strHeightPos = sellMenu:getPositionY()-25 --pic:getPositionY()-pic:getContentSize().height*0.5-5
                if G_isIphone5() then
                    self.pic2Tab[m]:setScale(0.7)
                end
            
                 local numSubWidth = 0
                 local numSubWidth2 = 0
                if costNum >9999 then
                    numSubWidth =-17
                elseif costNum>999 then
                    numSubWidth =-10
                end
                if halfNum > 1000 then
                    numSubWidth2 =-8
                elseif halfNum<10 and halfNum >-1 then
                    numSubWidth2 =10
                elseif (halfNum>99 and halfNum<1000) or halfNum <0 then
                    numSubWidth2 = -7
                end

                self.costNum2Tab[m]:setString(costNum)
                self.costNum2Tab[m]:setPosition(ccp(self.pic2Tab[m]:getPositionX()-35,strHeightPos))

                self.gold2PicTab[m]:setPosition(ccp(self.costNum2Tab[m]:getPositionX()+self.costNum2Tab[m]:getContentSize().width+numSubWidth,strHeightPos))

                self.halfNum2Tab[m]:setString(halfNum)
                self.halfNum2Tab[m]:setPosition(ccp(self.gold2PicTab[m]:getPositionX()+25,strHeightPos))
                self.gold2Pic2Tab[m]:setPosition(ccp(self.halfNum2Tab[m]:getPositionX()+self.halfNum2Tab[m]:getContentSize().width+numSubWidth2,strHeightPos))
            end
        end
    end
end

function acDoubleOneTabOne:openInfo()
  local td=smallDialog:new()
  local openTimeTb=acDoubleOneVoApi:getStEdTime( )
  local tabTitle_1 = "activity_new112018_tab1"
  local tabTitle_2 = "activity_new112018_tab2"

    local tabStr = {
            getlocal("activity_double11_tip1",{getlocal(tabTitle_1)}),
            getlocal("activity_double11_tip2",{openTimeTb[1],openTimeTb[2],getlocal(tabTitle_1)}),
            getlocal("activity_double11_tip3",{getlocal(tabTitle_1)}),
            getlocal("activity_double11_tip4"),
            getlocal("activity_double11_tip5",{getlocal(tabTitle_1)}),
            getlocal("activity_double11_tip6",{getlocal(tabTitle_2)}),
            getlocal("activity_double11_tip7",{getlocal(tabTitle_1)}),
            getlocal("activity_new112018_tip1"),
            getlocal("activity_new112018_tip2"),
        }
    local titleStr=getlocal("ladder_help_subtitle_1_2")
    require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
    tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,25)
end

function acDoubleOneTabOne:showPagebtn(whiIdx,nePosY)
        local pointPic = "leftBtnGreen.png" --"ArrowYellow.png"
        local function leftPageHandler() end
        local scale = 1
        local posYy = nil
        if nePosY then
            posYy = nePosY
        else
            if whiIdx ==1 then
                posYy = G_VisibleSizeHeight*0.6-30
            else
                posYy = G_VisibleSizeHeight*0.2
            end
        end
        local leftBtnPos=ccp(40,posYy)
        local rightBtnPos=ccp(G_VisibleSizeWidth-40,posYy)
        self.leftBtn=GetButtonItem(pointPic,pointPic,pointPic,leftPageHandler,11,nil,nil)
        self.leftBtn:setScale(scale)

        local leftMenu=CCMenu:createWithItem(self.leftBtn)
        leftMenu:setAnchorPoint(ccp(0.5,0.5))
        self.bgLayer:addChild(leftMenu,1)
        if(leftBtnPos~=nil)then
            leftMenu:setPosition(leftBtnPos)
        else
            leftMenu:setPosition(ccp(px,py+size.height/2))
        end

        local posX,posY=leftMenu:getPosition()
        local posX2=posX+20

        local mvTo=CCMoveTo:create(0.5,ccp(posX,posY))
        local fadeIn=CCFadeIn:create(0.5)
        local carray=CCArray:create()
        carray:addObject(mvTo)
        carray:addObject(fadeIn)
        local spawn=CCSpawn:create(carray)

        local mvTo2=CCMoveTo:create(0.5,ccp(posX2,posY))
        local fadeOut=CCFadeOut:create(0.5)
        local carray2=CCArray:create()
        carray2:addObject(mvTo2)
        carray2:addObject(fadeOut)
        local spawn2=CCSpawn:create(carray2)

        local seq=CCSequence:createWithTwoActions(spawn2,spawn)
        leftMenu:runAction(CCRepeatForever:create(seq))

        local function rightPageHandler()
        end
        self.rightBtn=GetButtonItem(pointPic,pointPic,pointPic,rightPageHandler,11,nil,nil)
        self.rightBtn:setScale(scale)
        self.rightBtn:setRotation(180)

        local rightMenu=CCMenu:createWithItem(self.rightBtn)
        rightMenu:setAnchorPoint(ccp(0.5,0.5))
        self.bgLayer:addChild(rightMenu,1)
        if(rightBtnPos~=nil)then
            rightMenu:setPosition(rightBtnPos)
        else
            rightMenu:setPosition(ccp(px+size.width,py+size.height/2))
        end

        local posX,posY=rightMenu:getPosition()
        local posX2=posX-20

        local mvTo=CCMoveTo:create(0.5,ccp(posX,posY))
        local fadeIn=CCFadeIn:create(0.5)
        local carray=CCArray:create()
        carray:addObject(mvTo)
        carray:addObject(fadeIn)
        local spawn=CCSpawn:create(carray)

        local mvTo2=CCMoveTo:create(0.5,ccp(posX2,posY))
        local fadeOut=CCFadeOut:create(0.5)
        local carray2=CCArray:create()
        carray2:addObject(mvTo2)
        carray2:addObject(fadeOut)
        local spawn2=CCSpawn:create(carray2)

        local seq=CCSequence:createWithTwoActions(spawn2,spawn)
        rightMenu:runAction(CCRepeatForever:create(seq))
end

function acDoubleOneTabOne:getScratchGold()
    local scratchTb         = acDoubleOneVoApi:getScratchTb( )--action  =hang刮刮乐 shop=1  是第几个抢购的刮刮乐
    local otherData,shopNum = acDoubleOneVoApi:returWhiPanicShop(true)
    local isInTime,curTime  = acDoubleOneVoApi:isInTime( )
    local function getRawardCallback(fn,data)
        local ret,sData = base:checkServerData(data)
        if ret==true then
            if sData.data and sData.data.new112018 then
                if sData.data.dgems then
                    if self and self.maskCardBtn2 then
                        self.maskCardBtn2:setVisible(false)
                    end
                    local lastGold = sData.data.dgems
                    acDoubleOneVoApi:setLastScratchGold(lastGold)
                    local num = tonumber(sData.data.dgems)
                    if num >0 then
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_double11_scratchGoldTip1",{num,getlocal("activity_double11_shopName_"..shopNum)}),30)
                    else
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_double11_scratchGoldTip2"),30)
                    end
                end

                if sData.data.new112018.dgem then
                    acDoubleOneVoApi:setNearScratchGold(sData.data.new112018.dgem )--最近一次挂奖钱数
                end 
                if sData.data.new112018.gg then
                    acDoubleOneVoApi:setScratchTimeTb(sData.data.new112018.gg )--挂奖所有小时时间
                end 

                if sData.data.new112018.dg then
                    acDoubleOneVoApi:setScratchTb(sData.data.new112018.dg)--更新刮刮奖 奖池的金币数量
                end

            end
        end

    end
    socketHelper:doubleOnePanicBuying( getRawardCallback,"hang",shopNum,nil,curTime )
end

function acDoubleOneTabOne:updateAcTime()
    local acVo=acDoubleOneVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLb)
    end
end
function acDoubleOneTabOne:removeNextShowShopTvAndData()
    self.nextTv2:removeFromParentAndCleanup(true)
    self.showNextShopBg:removeFromParentAndCleanup(true)
    self.nextTv2,self.NextShowShopTvWidth,self.NextShowShopTvHeight = nil , nil , nil
    self.showNextShopBg,self.nextShowTb = nil,nil
end
function acDoubleOneTabOne:initNextShowShopTableView(showNextShopBg)
    local isInTime,curTimeHour,curTimeMin = acDoubleOneVoApi:isInTime( )
    local tvWidth,tvHeight = showNextShopBg:getContentSize().width - 12,showNextShopBg:getContentSize().height
    self.nextShowTb = isInTime and acDoubleOneVoApi:returWhiPanicShop(true) or acDoubleOneVoApi:returWhiPanicShop()
    self.NextShowShopTvWidth,self.NextShowShopTvHeight = tvWidth - 16,tvHeight - 4
    -- print("SizeOfTable(self.nextShowTb)====>>>>",SizeOfTable(self.nextShowTb))

    local nextShopDesc = GetTTFLabelWrap(getlocal("activity_double11_nextShopDesc"),24,CCSizeMake(tvWidth - 20,0),kCCVerticalTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    nextShopDesc:setPosition(ccp(tvWidth*0.5 + 6,tvHeight + (G_isIphone5() and 25 or 20)))
    showNextShopBg:addChild(nextShopDesc)
    nextShopDesc:setColor(G_ColorYellowPro)

    local function callBack(...)
        return self:nextShowShopEventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.nextTv2=LuaCCTableView:createHorizontalWithEventHandler(hd,CCSizeMake(tvWidth - 4,tvHeight - 4),nil)
    self.nextTv2:setTableViewTouchPriority(-(self.layerNum-1)*20-12)
    self.nextTv2:setPosition(ccp(8,2))
    showNextShopBg:addChild(self.nextTv2)
end
function acDoubleOneTabOne:nextShowShopEventHandler( handler,fn,idx,cel )
    local strSize2 = G_isAsia() and 20 or 18

    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then-- 180 背景图 宽度
        return  CCSizeMake(SizeOfTable(self.nextShowTb) * 140,self.NextShowShopTvHeight)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local cellBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function () end)
        cellBg:setTouchPriority(-(self.layerNum-1)*20-1)
        cellBg:setContentSize(CCSizeMake(SizeOfTable(self.nextShowTb) * 140,self.NextShowShopTvHeight))
        cellBg:setOpacity(0)
        -- cellBg:setIsSallow(true)
        cellBg:setAnchorPoint(ccp(0,0))
        cellBg:setPosition(ccp(2,2))
        cell:addChild(cellBg)

        local function touch(tag,object)
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
            end
            PlayEffect(audioCfg.mouseClick)
            -- print("here----tv----->")
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if tag >10 and tag <30 then
                    local idx = tag -10
                end
            end
        end
        for idx=1,SizeOfTable(self.nextShowTb) do
            local cardUpbg   = "greenSellBg.png"
            local cardDownBg = "greenSellBg.png"

            local panicShop = self.nextShowTb["i"..idx]
            local rewardTb  = FormatItem(panicShop["r"])
            -- rewardTb[1].pic = G_getItemIcon(rewardTb[1],100,false)
            local picNums = rewardTb[1].num
            local costNum,halfNum,lastNums = panicShop["p"],panicShop["g"],panicShop["bn"]

            local numSubWidth  = 0
            local numSubWidth2 = 0
            if costNum >9999 then
                numSubWidth =-17
            elseif costNum>999 then
                numSubWidth =-10
            end
            if halfNum > 1000 then
                numSubWidth2 =-8
            elseif halfNum<10 and halfNum >-1 then
                numSubWidth2 =10
            elseif (halfNum>99 and halfNum<1000) or halfNum <0 then
                numSubWidth2 = -7
            end

            local scaleNum =0.85 --G_isIphone5() and 0.85 or 0.5
            local sellBtn=GetButtonItem(cardUpbg,cardDownBg,cardUpbg,touch,10 + idx)--------------假数据 用配置里的数据 
            sellBtn:setAnchorPoint(ccp(0,0.5))
            sellBtn:setScale(scaleNum)
            local sellBtnWidth = sellBtn:getContentSize().width * 0.85
            local sellMenu=CCMenu:createWithItem(sellBtn)
            sellMenu:setPosition(ccp(5 + sellBtn:getContentSize().width * scaleNum * (idx -1) + (idx -1) * 10,self.NextShowShopTvHeight * 0.5))
            sellMenu:setTouchPriority(-(self.layerNum-1)*20-2)
            cellBg:addChild(sellMenu,1)

            local function showNewPropInfo()
                local useTb = {doubleUse="new112018",costNum=costNum,halfNum=halfNum}
                G_showNewPropInfo(self.layerNum+1,true,true,nil,rewardTb[1],nil,nil,nil,useTb)
                return false
            end
            local pic = G_getItemIcon(rewardTb[1],100,true,self.layerNum,showNewPropInfo)--rewardTb[1].pic
            pic:setTouchPriority(-(self.layerNum-1)*20-12)
            pic:setIsSallow(false)
            pic:setPosition(ccp(sellMenu:getPositionX() + sellBtnWidth*0.5,sellMenu:getPositionY()+20))
            cellBg:addChild(pic,1)
            pic:setScale(90/pic:getContentSize().width)
            strHeightPos = sellMenu:getPositionY()-35 

            local picNumsStr = GetTTFLabel("x"..picNums,25)
            picNumsStr:setAnchorPoint(ccp(1,0))
            picNumsStr:setPosition(ccp(pic:getPositionX()+40,pic:getPositionY()-40))
            cellBg:addChild(picNumsStr,1)

            local lastNumsStr = GetTTFLabel(getlocal("hasNum",{lastNums}),strSize2)
            lastNumsStr:setPosition(ccp(pic:getPositionX(),strHeightPos-20))
            cellBg:addChild(lastNumsStr,1)

            local saleNum = string.format("%.2f",(costNum-halfNum)/costNum)*100
            local sellIcon = CCSprite:createWithSpriteFrameName("saleRedBg.png")
            sellIcon:setPosition(ccp(sellMenu:getPositionX()+43 + sellBtnWidth*0.5,sellMenu:getPositionY()+50))
            sellIcon:ignoreAnchorPointForPosition(false)
            sellIcon:setAnchorPoint(ccp(0.5,0.5))
            sellIcon:setRotation(0)
            cellBg:addChild(sellIcon,2)

            local saleNumStr = GetTTFLabel("-"..saleNum.."%",18)
            saleNumStr:setAnchorPoint(ccp(0.5,0.5))
            saleNumStr:setPosition(getCenterPoint(sellIcon))
            saleNumStr:setRotation(10)
            sellIcon:addChild(saleNumStr)
        end
        

        return cell
    end

end

function acDoubleOneTabOne:dispose( )
    self.tvWidth           =nil
    self.layerNum          =nil
    self.bgLayer           =nil
    self.tv                =nil
    self.tv2               =nil
    self.sellBtnTab        ={}
    self.sellBtnTab2       ={}
    self.sellMenu2Tab      ={}
    self.cellSizeHeight    =nil
    self.touchDialogBg     =nil
    self.isbeginSell       =nil
    self.pic2Tab           ={}--:removeFromParentAndCleanup(true)
    self.costNum2Tab       ={}
    self.gold2PicTab       ={}
    self.halfNum2Tab       ={}
    self.gold2Pic2Tab      ={}
    self.downBg            =nil
    self.touchDialogBg2    =nil
    self.clayer            =nil
    self.cardPosTb         ={}
    self.cardOr            =nil
    self.touchArr          ={}
    self.temSp             =nil
    self.maskCardBtn2      =nil
    self.countDownTimeDec  =nil
    self.countDownTimeStr  =nil
    self.countDownTimeStr2 =nil
    self.countDownTimeDec2 =nil
    self.unMaskCard2       =nil
    self.unMaskCard        =nil
    self.countDownNum      =nil
    self.countDownNum2     =nil
    self.maskCardBtn       =nil
    self.countPosHeight    =nil
    self.upShopDec         =nil
    self.downShopDec       =nil
    self.desBgSp           =nil
    self.desBgSpStr        =nil
    self.desBgSp2          =nil
    self.desBgSpStr2       =nil
    self.groupStr          =nil
    self.groupStr2         =nil
    self.groupStr2Bg       =nil
    self.isHasBuy          =nil
    self.isbeginS          =nil
    self.td                =nil
    self.version           =nil

    self.upBgJpg  =nil
    self.downBgJpg=nil

    self.nextTv2,self.NextShowShopTvWidth,self.NextShowShopTvHeight = nil , nil , nil
    self.showNextShopBg,self.nextShowTb = nil,nil
end