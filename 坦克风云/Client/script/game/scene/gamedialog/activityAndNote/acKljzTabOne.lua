acKljzTabOne={}

function acKljzTabOne:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    self.layerNum=nil
    self.selectedTabIndex=nil
    self.parentDialog=nil
    self.oldAllSteps = 0    
    self.bgLayer=nil
    self.tv=nil
    self.isTodayFlag=true
    self.isIphone5 = false
    self.netIsTrue = true
    self.touchArr = {}
    self.moduleTb = {}--矩阵精灵tb
    self.moduleHasNumsTb = {}--矩阵精灵idx标识tb
    self.isInModule = false
    self.touchBeginPosNum = {}
    self.movePoint = 0 --移动方向 0 无法判断 1，横向，2竖向
    self.beginX,self.beginY = nil,nil
    self.touchMovOldModule = {}
    self.isCovertHoriModule,self.isCovertVertiModule =false,false
    self.turnPoint = 0 --移动成功后的方向位：0未移动 1向左/上 2向右/下
    self.moduleBgTb = {}
    self.moduleColorTb = {}
    self.bigAwardPosTb = {}

    self.RGBTb = {ccc3(140,69,63),ccc3(60,110,61),ccc3(71,109,165) }--红 绿 蓝
    self.colorTb = {"r","g","b"}
    self.colorAndModuleTb = acKljzVoApi:getModulTb()

    self.conformTb = {}
    self.goCenterIdx = 0
    self.cleanTbPos = {}
    self.downModuleTb = {}
    self.spCenterMTb = {}
    self.spCenterMTb2 = {}
    self.test = 1

    self.getAwardKeyValueTb = {}
    self.getAwardKeyColorTb = {}
    self.awardActionBgTb = {}
    self.awardActionTb = {}
    return nc
end

function acKljzTabOne:init(layerNum,parent,selectedTabIndex,parentDialog)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/acKljzImage.plist")--acKljzShineImage.png
    spriteController:addTexture("public/acKljzImage.png")
    spriteController:addPlist("public/acKljzShineImage.plist")--acKljzShineImage.png
    spriteController:addTexture("public/acKljzShineImage.png")
    spriteController:addPlist("public/yellowFlicker.plist")
    spriteController:addTexture("public/yellowFlicker.png")
    spriteController:addPlist("public/blueFilcker.plist")
    spriteController:addTexture("public/blueFilcker.png")
    spriteController:addPlist("public/purpleFlicker.plist")
    spriteController:addTexture("public/purpleFlicker.png")
    spriteController:addPlist("public/greenFlicker.plist")
    spriteController:addTexture("public/greenFlicker.png")
    spriteController:addPlist("public/acthreeyear_images.plist")
    spriteController:addTexture("public/acthreeyear_images.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    if G_isIphone5() then
        self.isIphone5 = true
    end
    self.layerNum=layerNum
    self.parent = parent
    -- self.selectedTabIndex=selectedTabIndex
    -- self.parentDialog=parentDialog
    self.bgLayer=CCLayer:create()

    local count=math.floor((G_VisibleSizeHeight-160)/80)+2
    for i=1,count do
        local bgSp=CCSprite:createWithSpriteFrameName("threeyear_bg.png")
        bgSp:setAnchorPoint(ccp(0.5,1))
        bgSp:setScaleX((G_VisibleSizeWidth-4)/bgSp:getContentSize().width)
        bgSp:setScaleY(80/bgSp:getContentSize().height)
        bgSp:setPosition(G_VisibleSizeWidth/2,(G_VisibleSizeHeight-160)-(i-1)*bgSp:getContentSize().height)
        self.bgLayer:addChild(bgSp)
        if G_isIphone5()==false and i==count then
            bgSp:setPosition(ccp(bgSp:getPositionX(),bgSp:getPositionY()+20))
        end
    end

    self:initTopDialog()
    self:initMiddleDIalog()
    self:initTableView()

    local function touchDialog( )
        print(" not touch~~~~~~~~~")
    end 

    self.touchDialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
    self.touchDialogBg2:setTouchPriority(-(self.layerNum-1)*20-10)
    local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    self.touchDialogBg2:setContentSize(rect)
    self.touchDialogBg2:setOpacity(0)
    self.touchDialogBg2:setIsSallow(true) -- 点击事件透下去
    self.touchDialogBg2:setPosition(ccp(G_VisibleSizeWidth*5.5,G_VisibleSizeWidth*0.5))
    self.bgLayer:addChild(self.touchDialogBg2,10)
    self.touchDialogBg2:setVisible(true)


    return self.bgLayer
end

function acKljzTabOne:dispose()
    self.layerNum=nil
    self.selectedTabIndex=nil
    self.parentDialog=nil
    self.oldAllSteps = nil    
    self.bgLayer=nil
    self.tv=nil
    self.isTodayFlag = nil
    self.isIphone5 = nil

    self.touchArr = nil
    self.moduleTb = nil--矩阵精灵tb
    self.moduleHasNumsTb = nil--矩阵精灵idx标识tb
    self.isInModule = nil
    self.touchBeginPosNum = nil
    self.movePoint = nil --移动方向 0 无法判断 1，横向，2竖向
    self.beginX,self.beginY = nil,nil
    self.touchMovOldModule = nil
    self.isCovertHoriModule,self.isCovertVertiModule =nil,nil
    self.turnPoint = nil --移动成功后的方向位：0未移动 1向左/上 2向右/下
    self.moduleBgTb = nil
    self.moduleColorTb = nil

    self.RGBTb = nil
    self.colorTb = nil
    self.colorAndModuleTb = nil
    self.goCenterIdx = nil

    self.cleanTbPos =nil
    self.downModuleTb =nil
    self.spCenterMTb =nil
    self.spCenterMTb2 =nil
    self.test = nil

    self.getAwardKeyValueTb =nil
    self.getAwardKeyColorTb =nil
    self.awardActionBgTb = nil
    self.awardActionTb = nil
    spriteController:removePlist("public/acKljzImage.plist")
    spriteController:removeTexture("public/acKljzImage.png")
    spriteController:removePlist("public/acKljzShineImage.plist")
    spriteController:removeTexture("public/acKljzShineImage.png")
    spriteController:removePlist("public/yellowFlicker.plist")
    spriteController:removeTexture("public/yellowFlicker.png")
    spriteController:removePlist("public/purpleFlicker.plist")
    spriteController:removeTexture("public/purpleFlicker.png")
    spriteController:removePlist("public/blueFilcker.plist")
    spriteController:removeTexture("public/blueFilcker.png")
    spriteController:removePlist("public/greenFlicker.plist")
    spriteController:removeTexture("public/greenFlicker.png")
    spriteController:removePlist("public/acthreeyear_images.plist")
    spriteController:removeTexture("public/acthreeyear_images.png")
    self.test = nil
end

function acKljzTabOne:initTopDialog( )
    
    local h = G_VisibleSizeHeight-180
    local h2 = h - 10
    if self.isIphone5 then
        h = h -20
        h2 = h - 4
    end
    local timeStr=acKljzVoApi:getTimer()
    local posxSubWidth = 0
    if G_getCurChoseLanguage() == "fr" then
        posxSubWidth = 40
    end
    local acLabel = GetTTFLabel(getlocal("activityCountdown")..":"..timeStr,25)
    acLabel:setAnchorPoint(ccp(0.5,0.5))
    acLabel:setPosition(ccp(G_VisibleSizeWidth *0.5-posxSubWidth, h))
    self.bgLayer:addChild(acLabel)
    acLabel:setColor(G_ColorYellowPro)
    self.timeLb=acLabel

    local function touchInfo()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tabStr={}
        for i=1,6 do
            table.insert(tabStr,getlocal("activity_kljz_info"..i))
        end
        local titleStr=getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        local textSize = 25
        if G_getCurChoseLanguage() =="ru" then
            textSize = 20 
        end
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,textSize)
    end
    local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touchInfo,1,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,0.5))
    menuItemDesc:setScale(0.8)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-4)
    menuDesc:setPosition(ccp(self.bgLayer:getContentSize().width-35, h2))
    self.bgLayer:addChild(menuDesc,2)
end

function acKljzTabOne:initMiddleDIalog( )
    --"newItemKuang.png",CCRect(15,15,2,2)
    self.MiddleBgHeight = 110
    local MiddleBg=LuaCCScale9Sprite:createWithSpriteFrameName("newItemKuang.png",CCRect(15,15,2,2),function ( ) end)
    MiddleBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,self.MiddleBgHeight))

    MiddleBg:setAnchorPoint(ccp(0.5,1))
    local MiddleBgPosy = self.isIphone5 and G_VisibleSizeHeight-280 or G_VisibleSizeHeight-230
    MiddleBg:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,MiddleBgPosy))
    self.MiddleBg = MiddleBg
    self.bgLayer:addChild(MiddleBg,1)
    local MiddleBgWidth = MiddleBg:getContentSize().width
    local MiddleBgHeight = MiddleBg:getContentSize().height

    local lb=GetTTFLabel(getlocal("activity_kljz_bigAward"),25)
    lb:setAnchorPoint(ccp(0.5,0))
    lb:setPosition(ccp(MiddleBgWidth*0.5,MiddleBgHeight+5))
    MiddleBg:addChild(lb,2)
    local lbWidth = lb:getContentSize().width
    local pointAnTb,pointPosX,addPosX = {0,0},{0,lbWidth},{-15,15}
    for i=1,2 do
        local pointSp=CCSprite:createWithSpriteFrameName("newPointRect.png")
        pointSp:setAnchorPoint(ccp(0.5,0.5))
        pointSp:setPosition(ccp(pointPosX[i] + addPosX[i],lb:getContentSize().height*0.5))
        lb:addChild(pointSp)
        pointSp:setScale(1.5)

        local pointLineSp=CCSprite:createWithSpriteFrameName("newPointLine.png")
        pointLineSp:setAnchorPoint(ccp(0,0.5))
        pointLineSp:setPosition(ccp(pointPosX[i] + addPosX[i]*2,lb:getContentSize().height*0.5))
        lb:addChild(pointLineSp)
        if i==1 then
            pointLineSp:setRotation(180)
        end
    end
    local lightSp=CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
    lightSp:setAnchorPoint(ccp(0.5,0))
    lightSp:setScaleX(2)
    lightSp:setPosition(ccp(MiddleBgWidth*0.5,MiddleBgHeight+2))
    MiddleBg:addChild(lightSp)

    self:initBigAwardBtn()

    self:initAwardAndRecord( )
end

function acKljzTabOne:awardShowCall(tag,readyGet,rewards)
    require "luascript/script/game/scene/gamedialog/activityAndNote/acThrivingSmallDialog"
    local btnNameTb = {"r","g","b"}
    if readyGet == nil or readyGet == false then
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
    end
    
    print("tag====>>>",tag)
    local function stopAcation( )
        self:bigAwardAction(tag,true)
    end 
    local oneBigAwardTb = acKljzVoApi:getOneBigAwardTb(tag)

    local titleStr = getlocal("activity_kljz_bestBadge"..btnNameTb[tag])
    local descStr = getlocal("activity_kljz_syBestDesc",{titleStr})
    local needTb = {"kljz",titleStr,descStr,oneBigAwardTb,readyGet,rewards,stopAcation,tag}
    local bigAwardDia = acThrivingSmallDialog:new(self.layerNum+tag,needTb)
    bigAwardDia:init()
end

function acKljzTabOne:initBigAwardBtn( )
    local btnNameTb = {"r","g","b"}
    local function awardShowCall(tag)
        self:awardShowCall(tag)
    end
    
    local middleLeftPosx = self.MiddleBg:getPositionX() - self.MiddleBg:getContentSize().width*0.5
    local middleCenterPosy = self.MiddleBg:getPositionY() - self.MiddleBg:getContentSize().height*0.5

    for i=1,3 do
        local awardShowItem=GetButtonItem(btnNameTb[i].."_4.png",btnNameTb[i].."_4.png",btnNameTb[i].."_4.png",awardShowCall,i)
        self.awardActionTb[i] = awardShowItem
        local awardShowBtn=CCMenu:createWithItem(awardShowItem);
        awardShowBtn:setTouchPriority(-(self.layerNum-1)*20-4);
        awardShowBtn:setPosition(ccp(self.MiddleBg:getContentSize().width*0.25*i,self.MiddleBg:getContentSize().height*0.5))
        self.MiddleBg:addChild(awardShowBtn)

        local awardActionBg = CCSprite:createWithSpriteFrameName("whiteBg2.png")
        awardActionBg:setPosition(ccp(self.MiddleBg:getContentSize().width*0.25*i,self.MiddleBg:getContentSize().height*0.5))
        self.MiddleBg:addChild(awardActionBg)
        self.awardActionBgTb[i] = awardActionBg
        local fadeIn = CCFadeIn:create(0.8)
        local fadeOut = CCFadeOut:create(0.8)
        local seq=CCSequence:createWithTwoActions(fadeOut,fadeIn)
        local repeatForever=CCRepeat:create(seq, 4);--CCRepeatForever:create(seq)
        awardActionBg:runAction(repeatForever)

        self.bigAwardPosTb[i] = ccp(self.MiddleBg:getContentSize().width*0.25*i + middleLeftPosx,middleCenterPosy)
    end
end
function acKljzTabOne:bigAwardIconAndBgAction(nColor)
    local scaleBig = CCScaleTo:create(0.3,1.5)
    local scaleSma = CCScaleTo:create(0.3,1)
    local arr = CCArray:create()
    arr:addObject(scaleBig)
    arr:addObject(scaleSma)
    local seq = CCSequence:create(arr)
    self.awardActionBgTb[nColor]:runAction(seq)

    local scaleBig2 = CCScaleTo:create(0.3,1.5)
    local scaleSma2 = CCScaleTo:create(0.3,1)
    local arr2 = CCArray:create()
    arr2:addObject(scaleBig2)
    arr2:addObject(scaleSma2)
    local seq2 = CCSequence:create(arr2)
    self.awardActionTb[nColor]:runAction(seq2)
end
function acKljzTabOne:bigAwardAction(nColor,isStop)
    if isStop then
        self.awardActionBgTb[nColor]:stopAllActions()
        self.awardActionTb[nColor]:stopAllActions()
        self.awardActionTb[nColor]:setScale(1)
        self.awardActionBgTb[nColor]:setScale(1)
    else
        local fadeIn = CCFadeIn:create(0.8)
        local fadeOut = CCFadeOut:create(0.8)
        local seq=CCSequence:createWithTwoActions(fadeOut,fadeIn)
        local repeatForever=CCRepeatForever:create(seq)
        self.awardActionBgTb[nColor]:runAction(repeatForever)
    end
end

function acKljzTabOne:initAwardAndRecord( )
    local btnPosY = self.MiddleBg:getPositionY() - self.MiddleBgHeight-2
    if self.isIphone5 then
        btnPosY = btnPosY -30
    end
    local strSize22 = 18
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        strSize22 = 25
    end
    --奖励库
    local function rewardPoolHandler()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        --显示奖池
        local poolTitleTb = {"redTitle","greenTitle","blueTitle","activity_kljz_notSy"}
        local poolSonTitleTb = {getlocal("activity_kljz_syDesc",{getlocal(poolTitleTb[1])}),getlocal("activity_kljz_syDesc",{getlocal(poolTitleTb[2])}),getlocal("activity_kljz_syDesc",{getlocal(poolTitleTb[3])}),getlocal("activity_kljz_notSyDesc")}
        local content={}
        local pool=acKljzVoApi:getRewardPool()
        for k,rewardlist in pairs(pool) do
            -- print("k======>>>>>",k)
            local item={}
            item.rewardlist=rewardlist
            
            local addTitle =  k < SizeOfTable(pool) and getlocal("badgeStr") or ""
            item.title={getlocal(poolTitleTb[k])..addTitle,G_ColorYellowPro,strSize22}
            item.subTitle={poolSonTitleTb[k]}
            table.insert(content,item)
        end
        local title={getlocal("award"),nil,30}
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYswjSmallDialog"
        acYswjSmallDialog:showYswjRewardDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-200),CCRect(130,50,1,1),title,content,self.layerNum+1,nil,nil,nil,true)
    end
    local poolBtn=GetButtonItem("propBox3.png","propBox3.png","propBox3.png",rewardPoolHandler,11)
    poolBtn:setScale(0.7)
    poolBtn:setAnchorPoint(ccp(0,1))
    local poolMenu=CCMenu:createWithItem(poolBtn)
    poolMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    local subPosyyy = self.isIphone5 and 3 or 0
    poolMenu:setPosition(ccp(G_VisibleSizeWidth*0.65,btnPosY-subPosyyy))
    self.bgLayer:addChild(poolMenu,1)
    local poolBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    poolBg:setAnchorPoint(ccp(0.5,1))
    poolBg:setContentSize(CCSizeMake(70,30))
    poolBg:setPosition(ccp(poolBtn:getContentSize().width/2,40))
    poolBg:setOpacity(50)
    poolBg:setScale(1/poolBtn:getScale())
    poolBtn:addChild(poolBg)
    local poolLb=GetTTFLabelWrap(getlocal("award"),20,CCSize(130,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    poolLb:setPosition(poolBg:getContentSize().width/2,poolBg:getContentSize().height/2)
    poolLb:setColor(G_ColorYellowPro)
    poolBg:addChild(poolLb)


    local function logHandler()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:logHandler()
    end
    local logBtn=GetButtonItem("bless_record.png","bless_record.png","bless_record.png",logHandler,11)
    logBtn:setScale(0.7)
    logBtn:setAnchorPoint(ccp(1,1))
    local logMenu=CCMenu:createWithItem(logBtn)
    logMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    logMenu:setPosition(ccp(G_VisibleSizeWidth-30,btnPosY-10))
    self.bgLayer:addChild(logMenu,1)
    local logBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    logBg:setAnchorPoint(ccp(0.5,1))
    logBg:setContentSize(CCSizeMake(logBtn:getContentSize().width-10,30))
    logBg:setOpacity(50)
    logBg:setPosition(ccp(logBtn:getContentSize().width/2,40))
    logBg:setScale(1/logBtn:getScale())
    logBtn:addChild(logBg)
    local logLb=GetTTFLabelWrap(getlocal("serverwar_point_record"),20,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    logLb:setPosition(logBg:getContentSize().width/2,logBg:getContentSize().height/2)
    logLb:setColor(G_ColorYellowPro)
    logBg:addChild(logLb)

    local posYAddHeight = 0
    if G_getCurChoseLanguage() =="fr" or G_getCurChoseLanguage() =="en" then
        posYAddHeight = 60
    end
    local stepIcon = CCSprite:createWithSpriteFrameName("pointIcon.png")
    stepIcon:setAnchorPoint(ccp(1,1))
    stepIcon:setPosition(ccp(95,btnPosY-30+posYAddHeight))
    self.bgLayer:addChild(stepIcon,1)
    local allSteps,usedSteps = acKljzVoApi:getAllSteps( )
    if acKljzVoApi:getLastTime( ) == 0 then
        allSteps,usedSteps = 1,1
    end
    self.oldAllSteps = allSteps
    self.allStepStr = GetTTFLabel(getlocal("moveNums",{usedSteps,allSteps}),24)
    self.allStepStr:setAnchorPoint(ccp(0,0.5))
    self.allStepStr:setPosition(ccp(stepIcon:getPositionX()+5,stepIcon:getPositionY() - stepIcon:getContentSize().height*0.5))
    self.bgLayer:addChild(self.allStepStr,1)

    if self.isIphone5 then

    else

    end
end

function acKljzTabOne:logHandler()
    local function showLog()
        local rewardLog=acKljzVoApi:getRewardLog() or {}
        if rewardLog and SizeOfTable(rewardLog)>0 then
            local logList={}
            for k,v in pairs(rewardLog) do
                local num,reward,time,color=v.num,v.reward,v.time,v.color
                local title
                local colorTb = {"redTitle","greenTitle","blueTitle"}
                if num > 0 then
                    num = 1 
                end
                title = {getlocal("activity_kljz_logTitle_"..num)}

                local content={{reward}}
                local log={title=title,content=content,ts=time}
                table.insert(logList,log)
            end
            local logNum=SizeOfTable(logList)
            require "luascript/script/game/scene/gamedialog/activityAndNote/acCjyxSmallDialog"
            acCjyxSmallDialog:showLogDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-300),CCRect(130, 50, 1, 1),{getlocal("activity_customLottery_RewardRecode"),G_ColorWhite},logList,false,self.layerNum+1,nil,true,10,true,true)
        else
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_tccx_no_record"),30)
        end
    end
    acKljzVoApi:socketByCall("active.kljz.getlog",nil,nil,showLog)
end

function acKljzTabOne:tick( )
    local vo=acKljzVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        -- if self then
        --     acKljzVoApi:setModulTb()
        --     self:close()
        --     do return end
        -- end
    else
        local todayFlag=acKljzVoApi:isToday()
        if self.isTodayFlag==true and todayFlag==false then
            self.isTodayFlag=false
            --重置免费次数
            local allSteps,usedSteps =acKljzVoApi:getAllSteps( )
            acKljzVoApi:setAllSteps( allSteps+1 )
        end
    end
    if self.timeLb then
        self.timeLb:setString(getlocal("activityCountdown")..":"..acKljzVoApi:getTimer())
    end
    if acKljzVoApi:getLastTime( ) ~= 0 then
        local allSteps,usedSteps = acKljzVoApi:getAllSteps( )
        if self.oldAllSteps ~= allSteps then
            self.oldAllSteps = allSteps
            self.allStepStr:setString(getlocal("moveNums",{usedSteps,allSteps}))
            self:showBigSmallStepStr()
        else
            self.allStepStr:setString(getlocal("moveNums",{usedSteps,allSteps}))
        end
    end
end

function acKljzTabOne:showBigSmallStepStr( )
    local scaleBig = CCScaleTo:create(0.3,1.5)
    local scaleSma = CCScaleTo:create(0.3,1)
    local arr = CCArray:create()
    arr:addObject(scaleBig)
    arr:addObject(scaleSma)
    local seq = CCSequence:create(arr)
    self.allStepStr:runAction(seq)
end

function acKljzTabOne:initTableView()
    acKljzVoApi:getModulTb()

    self.bottomPosY = 20
    self.bottomPosX = (G_VisibleSizeWidth - 522)*0.5

    if G_getIphoneType() == G_iphoneX then
        self.bottomPosY = 150
    elseif self.isIphone5 then
        self.bottomPosY = 110
        -- self.bottomPosX = (G_VisibleSizeWidth - 522)*0.5
    end

    local tvBg1 = LuaCCScale9Sprite:createWithSpriteFrameName("newSide1.png",CCRect(11,11,1,1),function ( ) end)
    tvBg1:setContentSize(CCSizeMake(534,522))
    tvBg1:setAnchorPoint(ccp(0,0))
    tvBg1:setPosition(ccp(self.bottomPosX,self.bottomPosY))
    self.bgLayer:addChild(tvBg1)

    for i=1,2 do
        local tvBgSide = LuaCCScale9Sprite:createWithSpriteFrameName("newSide2.png",CCRect(7,11,1,1),function ( ) end)
        tvBgSide:setContentSize(CCSizeMake(12,314))
        local cpAn = i == 1 and ccp(0,0.5) or ccp(1,0.5)
        local poss = i == 1 and ccp(16,522*0.5) or ccp(530,522*0.5)
        if i == 1 then
            tvBgSide:setRotation(180)
        end
        tvBgSide:setAnchorPoint(cpAn)
        tvBgSide:setPosition(poss)
        tvBg1:addChild(tvBgSide)
    end

    self.tvWidth,self.tvHeight = 500,500
    self.needPosX,self.needPosY = self.bottomPosX + 17,self.bottomPosY + 11
    local function callback(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callback)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(500,500),nil)
    -- self:tabClick(0,false)
    self.tv:setPosition(ccp(17,11))
    self.coverInTvPosx,self.coverInTvPosy = self.bottomPosX + 17,self.bottomPosY + 11
    tvBg1:addChild(self.tv)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    self.tv:setMaxDisToBottomOrTop(0)
end

function acKljzTabOne:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return 1
  elseif fn=="tableCellSizeForIndex" then
     return  CCSizeMake(500,500)
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()

    self.clayer=CCLayer:create()
    self.clayer:setPosition(ccp(0,0))
    self.clayer:setAnchorPoint(ccp(0,0))
    cell:addChild(self.clayer)
    self.clayer:setTouchEnabled(true)
    local function tmpHandler(...)
        return self:touchEvent(...)
    end
    self.clayer:registerScriptTouchHandler(tmpHandler,false,-(self.layerNum-1)*20-4,false)
    self.clayer:setContentSize(CCSizeMake(500,500))
    self:addTestModule()

    cell:autorelease()
    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
  end
end

function acKljzTabOne:touchEvent( fn,x,y,touch )
    
    if fn=="began" then
                self.touchArr[touch]=touch
                local allSteps,usedSteps = acKljzVoApi:getAllSteps( )
                if SizeOfTable(self.touchArr)>1 then
                    
                else
                    local curPos=CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
                    self.isInModule,self.touchBeginPosNum = self:detectionPos(x,y)
                    -- print("isInModule=======>>>>>",self.isInModule)
                    if self.isInModule then

                        if usedSteps <= 0 then
                            self.isInModule = false
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_kljz_notMov"),30)
                        else
                            self.beginX,self.beginY = x,y
                            self.willHeighting = true
                            --初次点击未确定方向，保留当前横竖行第一个位置的module用于movEnd时判断是否移动或是移动到初次位置
                            local horiModule,vertiModule = self.moduleTb[1][self.touchBeginPosNum[2]],self.moduleTb[self.touchBeginPosNum[1]][1]
                            self.touchMovOldModule = {horiModule,vertiModule}
                        end
                    end
                end

        return 1
    elseif fn=="moved" then
            if self.isInModule == false then
                do return end
            end
            local curPos=CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
            if self.movePoint == 0 then
                self.movePoint = self:detectionMovePoint(x,y)
            end
            if self.movePoint == 1 and self.beginX then
                self.curNeedPosx = x - self.beginX
                for i=1,self.horiNums do
                    self.moduleTb[i][self.touchBeginPosNum[2]]:setPositionX(self.moduleTb[i][self.touchBeginPosNum[2]]:getPositionX() + self.curNeedPosx)
                end
                self:refreshWithHoriMove(self.curNeedPosx)
                self.beginX = x
            elseif self.movePoint == 2 and self.beginY then
                self.curNeedPosy = y - self.beginY
                for j=1,self.vertiNums do
                    self.moduleTb[self.touchBeginPosNum[1]][j]:setPositionY(self.moduleTb[self.touchBeginPosNum[1]][j]:getPositionY() + self.curNeedPosy)
                end
                self:refreshWithVertiMove(self.curNeedPosy)
                self.beginY = y
            end
    elseif fn=="ended" then

        if self.movePoint == 1 then
            if self.touchDialogBg2 then
                self.touchDialogBg2:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.5 - 80))
            end
            self:horiMoveEnd(self.curNeedPosx)
        elseif self.movePoint == 2 then
            if self.touchDialogBg2 then
                self.touchDialogBg2:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.5 - 80))
            end
            self:vertiMoveEnd(self.curNeedPosy)
        elseif self.movePoint == 0 and self.touchBeginPosNum[1] and self.touchBeginPosNum[2] then
            local moduleIcon = self.moduleTb[self.touchBeginPosNum[1]][self.touchBeginPosNum[2]]:getChildByTag(111)
            moduleIcon:setPosition(getCenterPoint(self.moduleTb[self.touchBeginPosNum[1]][self.touchBeginPosNum[2]]))
        end
        self.isCovertHoriModule,self.isCovertVertiModule = false,false
        self.isInModule ,self.touchBeginPosNum ,self.movePoint = false,{},0
        self.touchArr[touch]=nil
    else
        print("touchEvent-----what's this?~~~~~~~")

        self.touchArr=nil
        self.touchArr={}
    end
end

function acKljzTabOne:addTestModule( )
    local iconBg=CCSprite:createWithSpriteFrameName("mdBg.png")
    local moduleWidth,moduleHeight = iconBg:getContentSize().width,iconBg:getContentSize().height--模块大小
    local horiNums,vertiNums = 5,5--tv容纳的模块个数
    local horiLastNums,vertiLastNums = self.tvWidth%moduleWidth,self.tvHeight%moduleHeight--tv容纳模块个数后剩余的空间大小
    local horiSingleLastNums,vertiSingleLastNums = math.floor(horiLastNums/horiNums),math.floor(vertiLastNums/vertiNums)--模块单个需要的剩余空间大小
    self.halfHoriNums,self.halftVertiNums = math.floor(horiNums/2),math.floor(vertiNums/2)--横排一半个数，竖排一半个数：用于算法优化使用
    self.horiNums,self.vertiNums,self.moduleWidth,self.moduleHeight,self.horiSingleLastNums,self.vertiSingleLastNums = horiNums,vertiNums,moduleWidth,moduleHeight,horiSingleLastNums,vertiSingleLastNums
    -- print("moduleWidth,moduleHeight=====>>>",moduleWidth,moduleHeight)
    -- print("horiNums,vertiNums===========>>>",horiNums,vertiNums)
    -- print("horiSingleLastNums,vertiSingleLastNums===>>>",horiSingleLastNums,vertiSingleLastNums)
    
    for i=1,horiNums do
        self.moduleTb[i] = {}
        self.moduleHasNumsTb[i] = {}
        self.moduleBgTb[i] = {}
        self.moduleColorTb[i] = {}
        for j=1,vertiNums do
            local nColor,nModule = self.colorAndModuleTb[(i-1) * horiNums +j][1],self.colorAndModuleTb[(i-1) * horiNums +j][2]

            local moduleBg = CCSprite:createWithSpriteFrameName("mdBg.png")
            moduleBg:setAnchorPoint(ccp(0,0))
            moduleBg:setPosition(ccp(0,0))
            moduleBg:setColor(self.RGBTb[nColor])
            moduleBg:setPosition(ccp((i-1)*moduleWidth+horiSingleLastNums*i-horiSingleLastNums*0.5,(j-1)*moduleHeight+vertiSingleLastNums*j-vertiSingleLastNums*0.5))
            self.clayer:addChild(moduleBg)
            self.moduleBgTb[i][j] = moduleBg

            local iconBg=CCSprite:createWithSpriteFrameName("mdBg.png")
            iconBg:setAnchorPoint(ccp(0,0))
            iconBg:setOpacity(0)
            iconBg:setPosition(ccp((i-1)*moduleWidth+horiSingleLastNums*i-horiSingleLastNums*0.5,(j-1)*moduleHeight+vertiSingleLastNums*j-vertiSingleLastNums*0.5))
            self.clayer:addChild(iconBg,2)
            self.moduleTb[i][j] = iconBg

            -- print("self.colorTb[nColor]=====nModule======>>>>>",self.colorTb[nColor],nModule,(i-1) * horiNums +j)
            local moduleIcon = CCSprite:createWithSpriteFrameName(self.colorTb[nColor].."_"..nModule..".png")
            moduleIcon:setPosition(getCenterPoint(iconBg))
            moduleIcon:setTag(111)
            iconBg:addChild(moduleIcon)

            local moduleWhitePic = CCSprite:createWithSpriteFrameName("whiteBg_"..nModule..".png")
            moduleWhitePic:setPosition(getCenterPoint(iconBg))
            moduleWhitePic:setTag(112)
            iconBg:addChild(moduleWhitePic)
            moduleWhitePic:setOpacity(0)


            self.moduleHasNumsTb[i][j] = nModule
            self.moduleColorTb[i][j] = nColor
        end
    end
end

function acKljzTabOne:detectionPos(beginX,beginY)--确定是否点击在模块内，如果是 返回点击的具体模块
    local xx,yy = self.moduleTb[self.halfHoriNums][self.halftVertiNums]:getPositionX(),self.moduleTb[self.halfHoriNums][self.halftVertiNums]:getPositionY()
    local inMouduleIdxX,inMouduleIdxY = 0,0
    if beginX - self.needPosX < xx then
        for i=1,self.halfHoriNums do
            local testPosx = self.moduleTb[i][1]:getPositionX() + self.needPosX
            if beginX >= testPosx and beginX <= testPosx + self.moduleTb[i][1]:getContentSize().width then
                inMouduleIdxX = i
            end
        end
    else
        for i=self.halfHoriNums,self.horiNums do
            local testPosx = self.moduleTb[i][1]:getPositionX() + self.needPosX
            if beginX >= testPosx and beginX <= testPosx + self.moduleTb[i][1]:getContentSize().width then
                inMouduleIdxX = i
            end 
        end
    end

    if beginY - self.needPosY < yy then
        for i=1,self.halftVertiNums do
            local testPosy = self.moduleTb[1][i]:getPositionY() + self.needPosY
            if beginY >= testPosy and beginY <= testPosy + self.moduleTb[1][i]:getContentSize().height then
                inMouduleIdxY = i
            end
        end
    else
         for i=self.halftVertiNums,self.vertiNums do
            local testPosy = self.moduleTb[1][i]:getPositionY() + self.needPosY
            if beginY >= testPosy and beginY <= testPosy + self.moduleTb[1][i]:getContentSize().height then
                inMouduleIdxY = i
            end
        end
    end
    if inMouduleIdxX > 0 and inMouduleIdxY > 0 then
        local moduleIcon = self.moduleTb[inMouduleIdxX][inMouduleIdxY]:getChildByTag(111)
        moduleIcon:setPositionY(moduleIcon:getPositionY() + 20)

        return true,{inMouduleIdxX,inMouduleIdxY}
    else
        return false
    end
end

function acKljzTabOne:detectionMovePoint(x,y)--确定移动方向：横排还是竖排
    --需要
    if SizeOfTable(self.touchBeginPosNum) > 0 then
        local xxx = x - self.beginX
        local yyy = y - self.beginY
        local isHoriOrVert = 0
        if math.abs(xxx) > 25 or math.abs(yyy) > 25 then
            isHoriOrVert = math.abs(xxx) > math.abs(yyy) and 1 or 2
        end
        if self.willHeighting and isHoriOrVert > 0 then
            if isHoriOrVert == 1 then
                for i=1,self.horiNums do
                    if self.touchBeginPosNum[1] ~= i then
                        local moduleIcon = self.moduleTb[i][self.touchBeginPosNum[2]]:getChildByTag(111)
                        moduleIcon:setPositionY(moduleIcon:getPositionY() + 20)
                    end
                end
            elseif isHoriOrVert == 2 then
                for j=1,self.vertiNums do
                    if self.touchBeginPosNum[2] ~= j then
                        local moduleIcon = self.moduleTb[self.touchBeginPosNum[1]][j]:getChildByTag(111)
                        moduleIcon:setPositionY(moduleIcon:getPositionY() + 20)
                    end
                end
            end
            self.willHeighting = false
        end
        return isHoriOrVert
    end
end

function acKljzTabOne:horiMoveEnd(curNeedPosx)
        if self.moduleTb[self.horiNums][self.touchBeginPosNum[2]]:getPositionX() < self.tvWidth + 35 - self.moduleWidth*2 and self.isCovertHoriModule then
            self.moduleTb[1][self.touchBeginPosNum[2]]:setPositionX(self.moduleTb[self.horiNums][self.touchBeginPosNum[2]]:getPositionX() + self.moduleWidth + 3)
            local newModule = self.moduleTb[1][self.touchBeginPosNum[2]]
            local newPos = self.moduleHasNumsTb[1][self.touchBeginPosNum[2]]
            local newCol = self.moduleColorTb[1][self.touchBeginPosNum[2]]
            local oldModule,oldPos,oldCol = nil,nil,nil

            local newModuleBg = self.moduleBgTb[1][self.touchBeginPosNum[2]]
            local oldModuleBg = nil
            for i=self.horiNums,1,-1 do
                oldModule = self.moduleTb[i][self.touchBeginPosNum[2]]
                oldPos = self.moduleHasNumsTb[i][self.touchBeginPosNum[2]]
                oldCol = self.moduleColorTb[i][self.touchBeginPosNum[2]]
                oldModuleBg = self.moduleBgTb[i][self.touchBeginPosNum[2]]

                self.moduleTb[i][self.touchBeginPosNum[2]] = newModule
                self.moduleBgTb[i][self.touchBeginPosNum[2]] = newModuleBg
                self.moduleHasNumsTb[i][self.touchBeginPosNum[2]] = newPos
                self.moduleColorTb[i][self.touchBeginPosNum[2]] = newCol

                newModuleBg = oldModuleBg
                newModule = oldModule
                newPos = oldPos
                newCol = oldCol
            end
        end

        for i=1,self.horiNums do
            local posX = (i-1)*self.moduleWidth+self.horiSingleLastNums*i - self.horiSingleLastNums*0.5
            self.moduleBgTb[i][self.touchBeginPosNum[2]]:setPositionX(posX)
            self.moduleTb[i][self.touchBeginPosNum[2]]:setPositionX(posX)

            local moduleIcon = self.moduleTb[i][self.touchBeginPosNum[2]]:getChildByTag(111)
            moduleIcon:setPosition(getCenterPoint(self.moduleTb[i][self.touchBeginPosNum[2]]))
        end
        if self.isCovertHoriModule then
            print("ready to mergeModuleInHori~~~~~")
            self:mergeModuleInHori()
        else
            if self.touchDialogBg2 then
                self.touchDialogBg2:setPosition(ccp(G_VisibleSizeWidth*5.5,G_VisibleSizeHeight*0.5))
            end
        end
end
function acKljzTabOne:refreshWithHoriMove(curNeedPosx)
    self.isCovertHoriModule = true
    if curNeedPosx > 0 and self.moduleTb[self.horiNums][self.touchBeginPosNum[2]]:getPositionX() + self.moduleWidth > self.tvWidth + 50 then
        --最后面那个icon挪到最前面
        self.moduleTb[self.horiNums][self.touchBeginPosNum[2]]:setPositionX(self.moduleTb[1][self.touchBeginPosNum[2]]:getPositionX() - self.moduleWidth - self.horiSingleLastNums)
        local newModule = self.moduleTb[self.horiNums][self.touchBeginPosNum[2]]
        local newPos = self.moduleHasNumsTb[self.horiNums][self.touchBeginPosNum[2]]
        local newCol = self.moduleColorTb[self.horiNums][self.touchBeginPosNum[2]]
        local oldModule,oldPos,oldCol = nil,nil,nil

        local newModuleBg = self.moduleBgTb[self.horiNums][self.touchBeginPosNum[2]]
        local oldModuleBg = nil
        for i=1,self.horiNums do
            oldModule = self.moduleTb[i][self.touchBeginPosNum[2]]
            oldPos = self.moduleHasNumsTb[i][self.touchBeginPosNum[2]]
            oldCol = self.moduleColorTb[i][self.touchBeginPosNum[2]]
            oldModuleBg = self.moduleBgTb[i][self.touchBeginPosNum[2]]

            self.moduleTb[i][self.touchBeginPosNum[2]] = newModule
            self.moduleBgTb[i][self.touchBeginPosNum[2]] = newModuleBg
            self.moduleHasNumsTb[i][self.touchBeginPosNum[2]] = newPos
            self.moduleColorTb[i][self.touchBeginPosNum[2]] = newCol

            newModuleBg = oldModuleBg
            newModule = oldModule
            newPos = oldPos
            newCol = oldCol
        end
        for i=1,self.horiNums do
            self.moduleBgTb[i][self.touchBeginPosNum[2]]:setPositionX((i-1)*self.moduleWidth+self.horiSingleLastNums*i - self.horiSingleLastNums*0.5)
        end
    elseif curNeedPosx < 0 and self.moduleTb[1][self.touchBeginPosNum[2]]:getPositionX() < -50 then
        self.moduleTb[1][self.touchBeginPosNum[2]]:setPositionX(self.moduleTb[self.horiNums][self.touchBeginPosNum[2]]:getPositionX() + self.moduleWidth + self.horiSingleLastNums)
        local newModule = self.moduleTb[1][self.touchBeginPosNum[2]]
        local newPos = self.moduleHasNumsTb[1][self.touchBeginPosNum[2]]
        local newCol = self.moduleColorTb[1][self.touchBeginPosNum[2]]
        local oldModule,oldPos,oldCol = nil,nil,nil

        local newModuleBg = self.moduleBgTb[1][self.touchBeginPosNum[2]]
        local oldModuleBg = nil
        for i=self.horiNums,1,-1 do
            oldModule = self.moduleTb[i][self.touchBeginPosNum[2]]
            oldPos = self.moduleHasNumsTb[i][self.touchBeginPosNum[2]]
            oldCol = self.moduleColorTb[i][self.touchBeginPosNum[2]]
            oldModuleBg = self.moduleBgTb[i][self.touchBeginPosNum[2]]

            self.moduleTb[i][self.touchBeginPosNum[2]] = newModule
            self.moduleBgTb[i][self.touchBeginPosNum[2]] = newModuleBg
            self.moduleHasNumsTb[i][self.touchBeginPosNum[2]] = newPos
            self.moduleColorTb[i][self.touchBeginPosNum[2]] = newCol

            newModuleBg = oldModuleBg
            newModule = oldModule
            newPos = oldPos
            newCol = oldCol
        end
        for i=1,self.horiNums do
            self.moduleBgTb[i][self.touchBeginPosNum[2]]:setPositionX((i-1)*self.moduleWidth+self.horiSingleLastNums*i - self.horiSingleLastNums*0.5)
        end
    end
end
function acKljzTabOne:vertiMoveEnd(curNeedPosy)
        if self.moduleTb[self.touchBeginPosNum[1]][self.vertiNums]:getPositionY() < self.tvHeight + 35 - self.moduleHeight*2 and self.isCovertVertiModule then
            self.moduleTb[self.touchBeginPosNum[1]][1]:setPositionY(self.moduleTb[self.touchBeginPosNum[1]][self.vertiNums]:getPositionY() + self.moduleHeight + 10)
            local newModule = self.moduleTb[self.touchBeginPosNum[1]][1]
            local newPos = self.moduleHasNumsTb[self.touchBeginPosNum[1]][1]
            local newCol = self.moduleColorTb[self.touchBeginPosNum[1]][1]
            local oldModule,oldPos,oldCol = nil,nil,nil

            local newModuleBg = self.moduleBgTb[self.touchBeginPosNum[1]][1]
            local oldModuleBg = nil
            for j=self.vertiNums,1,-1 do
                oldModule = self.moduleTb[self.touchBeginPosNum[1]][j]
                oldPos = self.moduleHasNumsTb[self.touchBeginPosNum[1]][j]
                oldCol = self.moduleColorTb[self.touchBeginPosNum[1]][j]
                oldModuleBg = self.moduleBgTb[self.touchBeginPosNum[1]][j]

                self.moduleTb[self.touchBeginPosNum[1]][j] = newModule
                self.moduleBgTb[self.touchBeginPosNum[1]][j] = newModuleBg
                self.moduleHasNumsTb[self.touchBeginPosNum[1]][j] = newPos
                self.moduleColorTb[self.touchBeginPosNum[1]][j] = newCol

                newModuleBg = oldModuleBg
                newModule = oldModule
                newPos = oldPos
                newCol = oldCol
            end
        end
        for j=1,self.vertiNums do
            local posY = (j-1)*self.moduleHeight+self.vertiSingleLastNums*j - self.vertiSingleLastNums*0.5
            self.moduleBgTb[self.touchBeginPosNum[1]][j]:setPositionY(posY)
            self.moduleTb[self.touchBeginPosNum[1]][j]:setPositionY(posY)

            local moduleIcon = self.moduleTb[self.touchBeginPosNum[1]][j]:getChildByTag(111)
            moduleIcon:setPosition(getCenterPoint(self.moduleTb[self.touchBeginPosNum[1]][j]))
        end
        if self.isCovertVertiModule then
            self:mergeModuleInVerti()
        else
            if self.touchDialogBg2 then
                self.touchDialogBg2:setPosition(ccp(G_VisibleSizeWidth*5.5,G_VisibleSizeHeight*0.5))
            end
        end
end
function acKljzTabOne:refreshWithVertiMove(curNeedPosy)
    self.isCovertVertiModule = true
    if curNeedPosy > 0 and self.moduleTb[self.touchBeginPosNum[1]][self.vertiNums]:getPositionY() + self.moduleHeight > self.tvHeight+50 then
        self.moduleTb[self.touchBeginPosNum[1]][self.vertiNums]:setPositionY(self.moduleTb[self.touchBeginPosNum[1]][1]:getPositionY() - self.moduleHeight - self.vertiSingleLastNums)
        local newModule = self.moduleTb[self.touchBeginPosNum[1]][self.vertiNums]
        local newPos = self.moduleHasNumsTb[self.touchBeginPosNum[1]][self.vertiNums]
        local newCol = self.moduleColorTb[self.touchBeginPosNum[1]][self.vertiNums]
        local oldModule,oldPos,oldCol = nil,nil,nil

        local newModuleBg = self.moduleBgTb[self.touchBeginPosNum[1]][self.vertiNums]
        local oldModuleBg = nil
        for i=1,self.vertiNums do
            oldModule = self.moduleTb[self.touchBeginPosNum[1]][i]
            oldPos = self.moduleHasNumsTb[self.touchBeginPosNum[1]][i]
            oldCol = self.moduleColorTb[self.touchBeginPosNum[1]][i]
            oldModuleBg = self.moduleBgTb[self.touchBeginPosNum[1]][i]

            self.moduleTb[self.touchBeginPosNum[1]][i] = newModule
            self.moduleBgTb[self.touchBeginPosNum[1]][i] = newModuleBg
            self.moduleHasNumsTb[self.touchBeginPosNum[1]][i] = newPos
            self.moduleColorTb[self.touchBeginPosNum[1]][i] = newCol

            newModuleBg = oldModuleBg
            newModule = oldModule
            newPos = oldPos
            newCol = oldCol
        end
        for j=1,self.vertiNums do
            self.moduleBgTb[self.touchBeginPosNum[1]][j]:setPositionY((j-1)*self.moduleHeight+self.vertiSingleLastNums*j - self.vertiSingleLastNums*0.5)
        end
    elseif curNeedPosy < 0 and self.moduleTb[self.touchBeginPosNum[1]][1]:getPositionY() < -50 then
        self.moduleTb[self.touchBeginPosNum[1]][1]:setPositionY(self.moduleTb[self.touchBeginPosNum[1]][self.vertiNums]:getPositionY() + self.moduleHeight + self.vertiSingleLastNums)
        local newModule = self.moduleTb[self.touchBeginPosNum[1]][1]
        local newPos = self.moduleHasNumsTb[self.touchBeginPosNum[1]][1]
        local newCol = self.moduleColorTb[self.touchBeginPosNum[1]][1]
        local oldModule,oldPos,oldCol = nil,nil,nil

        local newModuleBg = self.moduleBgTb[self.touchBeginPosNum[1]][1]
        local oldModuleBg = nil
        for i=self.vertiNums,1,-1 do
            oldModule = self.moduleTb[self.touchBeginPosNum[1]][i]
            oldPos = self.moduleHasNumsTb[self.touchBeginPosNum[1]][i]
            oldCol = self.moduleColorTb[self.touchBeginPosNum[1]][i]
            oldModuleBg = self.moduleBgTb[self.touchBeginPosNum[1]][i]

            self.moduleTb[self.touchBeginPosNum[1]][i] = newModule
            self.moduleBgTb[self.touchBeginPosNum[1]][i] = newModuleBg
            self.moduleHasNumsTb[self.touchBeginPosNum[1]][i] = newPos
            self.moduleColorTb[self.touchBeginPosNum[1]][i] = newCol

            newModuleBg = oldModuleBg
            newModule = oldModule
            newPos = oldPos
            newCol = oldCol
        end
        for j=1,self.vertiNums do
            self.moduleBgTb[self.touchBeginPosNum[1]][j]:setPositionY((j-1)*self.moduleHeight+self.vertiSingleLastNums*j - self.vertiSingleLastNums*0.5)
        end
    end
end

function acKljzTabOne:mergeModuleInHori( )
        self.cleanTbPos = {}
        self.conformTb = {}
        self.goCenterIdx = 0
        if self.touchMovOldModule[1] == self.moduleTb[1][self.touchBeginPosNum[2]] then--模块相同 表示未移动或是移动回原位
            if self.touchDialogBg2 then
                self.touchDialogBg2:setPosition(ccp(G_VisibleSizeWidth*5.5,G_VisibleSizeHeight*0.5))
            end
            do return end
        end
        local positingXIdx,positingYIdx = self.touchBeginPosNum[1],self.touchBeginPosNum[2]--定位横向移动模块的纵向原始坐标位置，用于判断该模块上下是否有可消除模块的使用，
        -- print("in mergeModuleInHori~~~~~~~~",positingXIdx,positingYIdx)
        self:howManyModuleToClean(1,positingXIdx,positingYIdx)
end
function acKljzTabOne:mergeModuleInVerti( )
        self.cleanTbPos = {}
        self.conformTb = {}
        self.goCenterIdx = 0
        self.downModuleTb = {}
        if self.touchMovOldModule[2] == self.moduleTb[self.touchBeginPosNum[1]][1] then--模块相同 表示未移动或是移动回原位
            if self.touchDialogBg2 then
                self.touchDialogBg2:setPosition(ccp(G_VisibleSizeWidth*5.5,G_VisibleSizeHeight*0.5))
            end
            -- print("is same~~~~~~")
            do return end
        end
        local positingXIdx,positingYIdx = self.touchBeginPosNum[1],self.touchBeginPosNum[2]--定位横向移动模块的纵向原始坐标位置，用于判断该模块上下是否有可消除模块的使用，
        -- print("in mergeModuleInVerti~~~~~~~~",positingXIdx,positingYIdx)
        self:howManyModuleToClean(2,positingXIdx,positingYIdx)
end

function acKljzTabOne:howManyModuleToClean(isPoint,positingXIdx,positingYIdx,downUseFind)--isPoint:横向 1 纵向 2----downUseFind:用于落体后遍历检测使用
    local loopNums = isPoint ==1 and self.horiNums or self.vertiNums
    -- local useNum = self.moduleHasNumsTb[positingXIdx][positingYIdx]
    -- local useColor = self.moduleColorTb[positingXIdx][positingYIdx]
    local isSanme,curSameIdx = false,1

    local loopIdx,curPositIdx = 1,1
    if isPoint == 1 then--横向滑动

        while(loopIdx <= loopNums) do
            local sameMovModuleTb,sameFixModuleTb = {},{}
            -- print("and here???----->>>>",loopIdx)
            while(loopIdx <= loopNums) do--判断当前横排顺序sameNum 
                loopIdx = loopIdx +1 
                if self.moduleHasNumsTb[loopIdx] and self.moduleHasNumsTb[loopIdx][positingYIdx] == self.moduleHasNumsTb[curPositIdx][positingYIdx] and self.moduleColorTb[loopIdx][positingYIdx] == self.moduleColorTb[curPositIdx][positingYIdx] then
                    curSameIdx = curSameIdx + 1
                else
                    do break end --退出循环
                end
            end

            if curSameIdx > 2 then--如果sameNum > 2 那么在开始当前的纵向选择
                local willRoundPosX = nil
                for i=1,curSameIdx do
                    local selfPosX = curPositIdx - 1 + i--上面横向遍历相同module，用于当前循环判断上线是否有相同使用(包括最初坐标点)
                    sameMovModuleTb[i] = {selfPosX,positingYIdx,positingYIdx}


                    -------纵向向上遍历
                    local curFixUpSameIdx = 0
                    if positingYIdx+1 <= self.vertiNums then
                        for j=positingYIdx+1,self.vertiNums do
                            if self.moduleHasNumsTb[selfPosX][j] == self.moduleHasNumsTb[curPositIdx][positingYIdx] and self.moduleColorTb[selfPosX][j] == self.moduleColorTb[curPositIdx][positingYIdx] then
                                curFixUpSameIdx = curFixUpSameIdx+1
                            else
                                do break end
                            end
                        end
                    end
                    -------纵向向下遍历
                    local curFixDownSameIdx = 0
                    if positingYIdx-1 >=1 then
                        for j=positingYIdx-1,1,-1 do
                            if self.moduleHasNumsTb[selfPosX][j] == self.moduleHasNumsTb[curPositIdx][positingYIdx] and self.moduleColorTb[selfPosX][j] == self.moduleColorTb[curPositIdx][positingYIdx] then
                                curFixDownSameIdx = curFixDownSameIdx+1
                            else
                                do break end
                            end
                        end             
                    end
                    -------纵向 向上 或 向下 的个数 正好是2 那么加上原始点的Module 达到消除的3个
                    if curFixUpSameIdx + curFixDownSameIdx >= 2 then
                        willRoundPosX = selfPosX
                        if curFixUpSameIdx > 0 then
                            for j=1,curFixUpSameIdx do
                                local selfPosY = positingYIdx + j
                                table.insert(sameFixModuleTb,{selfPosX,selfPosY,positingYIdx})
                            end
                        end
                        if curFixDownSameIdx > 0 then
                            for j=1,curFixDownSameIdx do
                                local selfPosY = positingYIdx - j
                                table.insert(sameFixModuleTb,{selfPosX,selfPosY,positingYIdx})
                            end
                        end
                    end
                end
                -- print("curPositIdx-----(curSameIdx/2)------>>>>>",curPositIdx,(curSameIdx/2),math.floor(curPositIdx + (curSameIdx/2)))
                willRoundPosX = willRoundPosX or math.floor((curSameIdx/2)) + curPositIdx
                for k,v in pairs(sameMovModuleTb) do
                    if v[1] == willRoundPosX then
                        table.remove(sameMovModuleTb,k)
                    end
                end
                -- print("curFixUpSameIdx + curFixDownSameIdx=====1111=>>>>>",curFixUpSameIdx,curFixDownSameIdx,curFixUpSameIdx + curFixDownSameIdx)
                self:conformCleanModuleTb(isPoint,willRoundPosX,sameMovModuleTb,sameFixModuleTb)
                curPositIdx = curPositIdx + curSameIdx  -- 因为curSameIdx 包含 curPositIdx 的位置点 所以需要 -1
                loopIdx = curPositIdx
                curSameIdx = 1
            else
                -------纵向向上遍历
                local curFixUpSameIdx = 0
                if positingYIdx+1 <= self.vertiNums then
                    for j=positingYIdx+1,self.vertiNums do
                        if self.moduleHasNumsTb[curPositIdx][j] == self.moduleHasNumsTb[curPositIdx][positingYIdx] and self.moduleColorTb[curPositIdx][j] == self.moduleColorTb[curPositIdx][positingYIdx] then
                            curFixUpSameIdx = curFixUpSameIdx+1
                        else
                            do break end
                        end
                    end
                end
                -------纵向向下遍历
                local curFixDownSameIdx = 0
                if positingYIdx-1 >=1 then
                    for j=positingYIdx-1,1,-1 do

                        if self.moduleHasNumsTb[curPositIdx][j] == self.moduleHasNumsTb[curPositIdx][positingYIdx] and self.moduleColorTb[curPositIdx][j] == self.moduleColorTb[curPositIdx][positingYIdx] then
                            curFixDownSameIdx = curFixDownSameIdx+1
                        else
                            do break end
                        end
                    end
                end
                -------纵向 向上 或 向下 的个数 正好是2 那么加上原始点的Module 达到消除的3个
                -- print("curFixUpSameIdx + curFixDownSameIdx======2222=>>>>>",curFixUpSameIdx,curFixDownSameIdx,curFixUpSameIdx + curFixDownSameIdx)
                if curFixUpSameIdx + curFixDownSameIdx >= 2 then
                    willRoundPosX = curPositIdx
                    if curFixUpSameIdx > 0 then
                        for j=1,curFixUpSameIdx do
                            local selfPosY = positingYIdx + j
                            table.insert(sameFixModuleTb,{curPositIdx,selfPosY,positingYIdx})
                        end
                    end
                    if curFixDownSameIdx > 0 then
                        for j=1,curFixDownSameIdx do
                            local selfPosY = positingYIdx - j
                            table.insert(sameFixModuleTb,{curPositIdx,selfPosY,positingYIdx})
                        end
                    end
                    self:conformCleanModuleTb(isPoint,willRoundPosX,sameMovModuleTb,sameFixModuleTb)
                end
                curPositIdx = curPositIdx + 1 
                loopIdx = curPositIdx
                curSameIdx = 1
            end
        end
        -- print("self.conformTb num ====>>>>",SizeOfTable(self.conformTb))
        self:readyGoFlyToCeneter(1)
    elseif isPoint == 2 then --纵向滑动
        while(loopIdx <= loopNums) do
            local sameMovModuleTb,sameFixModuleTb = {},{}
            -- print("and here???----->>>>",loopIdx)
            while(loopIdx <= loopNums) do--判断当前横排顺序sameNum 
                loopIdx = loopIdx +1 
                if self.moduleHasNumsTb[positingXIdx] and self.moduleHasNumsTb[positingXIdx][loopIdx] == self.moduleHasNumsTb[positingXIdx][curPositIdx] and self.moduleColorTb[positingXIdx][loopIdx] == self.moduleColorTb[positingXIdx][curPositIdx] then
                    curSameIdx = curSameIdx + 1
                else
                    do break end --退出循环
                end
            end
            -- print("curSameIdx-------->>>>>>",curSameIdx)
            if curSameIdx > 2 then
                local willRoundPosY = nil--如果纵向有可消除module 那么替换初始curPositIdx    
                for i=1,curSameIdx do
                    local selfPosY = curPositIdx - 1 + i--上面横向遍历相同module，用于当前循环判断上线是否有相同使用(包括最初坐标点)
                    sameMovModuleTb[i] = {positingXIdx,selfPosY,positingXIdx}


                    -------横向向右遍历
                    local curFixUpSameIdx = 0
                    if positingXIdx+1 <= self.horiNums then
                        for i=positingXIdx+1,self.horiNums do
                            if self.moduleHasNumsTb[i][selfPosY] == self.moduleHasNumsTb[positingXIdx][curPositIdx] and self.moduleColorTb[i][selfPosY] == self.moduleColorTb[positingXIdx][curPositIdx] then
                                curFixUpSameIdx = curFixUpSameIdx+1
                            else
                                do break end
                            end
                        end
                    end
                    -------横向向左遍历
                    local curFixDownSameIdx = 0
                    if positingXIdx-1 >=1 then
                        for i=positingXIdx-1,1,-1 do
                            if self.moduleHasNumsTb[i][selfPosY] == self.moduleHasNumsTb[positingXIdx][curPositIdx] and self.moduleColorTb[i][selfPosY] == self.moduleColorTb[positingXIdx][curPositIdx] then
                                curFixDownSameIdx = curFixDownSameIdx+1
                            else
                                do break end
                            end
                        end             
                    end
                    -------横向 向左 向右 的个数 正好是2 那么加上原始点的Module 达到消除的3个
                    -- print("curFixUpSameIdx + curFixDownSameIdx=====2222=>>>>>",curFixUpSameIdx,curFixDownSameIdx,curFixUpSameIdx + curFixDownSameIdx)
                    if curFixUpSameIdx + curFixDownSameIdx >= 2 then
                        willRoundPosY = selfPosY
                        if downUseFind then
                            if self.spCenterMTb[willRoundPosY] == nil then
                                self.spCenterMTb[willRoundPosY] = positingXIdx
                                -- if self.spCenterMTb[willRoundPosY][positingXIdx] ==nil then
                                --     self.spCenterMTb[willRoundPosY][positingXIdx] = true
                                -- end
                            end 
                            -- table.insert(self.spCenterMTb,{positingXIdx,willRoundPosY})
                        end
                        
                        if curFixUpSameIdx > 0 then
                            for i=1,curFixUpSameIdx do
                                local selfPosX = positingXIdx + i
                                table.insert(sameFixModuleTb,{selfPosX,selfPosY,positingXIdx})
                            end
                        end
                        if curFixDownSameIdx > 0 then
                            for i=1,curFixDownSameIdx do
                                local selfPosX = positingXIdx - i
                                table.insert(sameFixModuleTb,{selfPosX,selfPosY,positingXIdx})
                            end
                        end
                    end
                    
                end
                -- print("curPositIdx-----(curSameIdx/2)------>>>>>",curPositIdx,(curSameIdx/2),math.floor(curPositIdx + (curSameIdx/2)))
                willRoundPosY = willRoundPosY or curPositIdx + math.floor((curSameIdx/2))
                for k,v in pairs(sameMovModuleTb) do
                    if v[2] == willRoundPosY then
                        table.remove(sameMovModuleTb,k)
                    end
                end                 
                self:conformCleanModuleTb(isPoint,willRoundPosY,sameMovModuleTb,sameFixModuleTb)

                curPositIdx = curPositIdx + curSameIdx  -- 因为curSameIdx 包含 curPositIdx 的位置点 所以需要 -1
                loopIdx = curPositIdx
                curSameIdx = 1
            else
                -------横向向右遍历
                local curFixUpSameIdx = 0
                if positingXIdx+1 <= self.horiNums then
                    for i=positingXIdx+1,self.horiNums do
                        if self.moduleHasNumsTb[i][curPositIdx] == self.moduleHasNumsTb[positingXIdx][curPositIdx] and self.moduleColorTb[i][curPositIdx] == self.moduleColorTb[positingXIdx][curPositIdx] then
                            curFixUpSameIdx = curFixUpSameIdx+1
                        else
                            do break end
                        end
                    end
                end
                -------横向向左遍历
                local curFixDownSameIdx = 0
                if positingXIdx-1 >=1 then
                    for i=positingXIdx-1,1,-1 do
                        if self.moduleHasNumsTb[i][curPositIdx] == self.moduleHasNumsTb[positingXIdx][curPositIdx] and self.moduleColorTb[i][curPositIdx] == self.moduleColorTb[positingXIdx][curPositIdx] then
                            curFixDownSameIdx = curFixDownSameIdx+1
                        else
                            do break end
                        end
                    end             
                end
                -------横向 向左 向右 的个数 正好是2 那么加上原始点的Module 达到消除的3个
                -- print("curFixUpSameIdx + curFixDownSameIdx------->>>>>",curFixUpSameIdx , curFixDownSameIdx)
                if curFixUpSameIdx + curFixDownSameIdx >= 2 then
                    willRoundPosY = curPositIdx
                    if downUseFind then
                        if self.spCenterMTb2[willRoundPosY] == nil then
                            self.spCenterMTb2[willRoundPosY] = positingXIdx
                            -- if self.spCenterMTb2[willRoundPosY][positingXIdx] ==nil then
                            --     self.spCenterMTb2[willRoundPosY][positingXIdx] = true
                            -- end
                        end 
                        -- table.insert(self.spCenterMTb2,{positingXIdx,willRoundPosY})
                    end
                    if curFixUpSameIdx > 0 then
                        for i=1,curFixUpSameIdx do
                            local selfPosX = positingXIdx + i
                            table.insert(sameFixModuleTb,{selfPosX,curPositIdx,positingXIdx})
                        end
                    end
                    if curFixDownSameIdx > 0 then
                        for i=1,curFixDownSameIdx do
                            local selfPosX = positingXIdx - i
                            table.insert(sameFixModuleTb,{selfPosX,curPositIdx,positingXIdx})
                        end
                    end
                   
                    self:conformCleanModuleTb(isPoint,willRoundPosY,sameMovModuleTb,sameFixModuleTb)
                    
                end
                curPositIdx = curPositIdx + 1 
                loopIdx = curPositIdx
                curSameIdx = 1
            end
        end

        if downUseFind ==nil then
            self:readyGoFlyToCeneter(2)
        end
    end

end
function acKljzTabOne:readyGoFlyToCeneter(isPoint)
    print("in readyGoFlyToCeneter --point----->>>>",isPoint)
    if SizeOfTable(self.conformTb) > 0 then --有消除位置，>0
        local idx = 0
        -- local parPosx,parPosy = nil,nil,
        for k,v in pairs(self.conformTb) do

            for m,n in pairs(v) do
                idx = idx +1
                -- self:flyToCenterModule(k,n[1],n[2],n[3],idx,isPoint)
                local whitePic = self.moduleTb[n[1]][n[2]]:getChildByTag(112)--白光动画
                local function shineCall()
                    self:flyToCenterModule(k,n[1],n[2],n[3],idx,isPoint)
                end
                local func = CCCallFuncN:create(shineCall)
                local fadeIn = CCFadeIn:create(0.3)
                local arr = CCArray:create()
                arr:addObject(fadeIn)
                arr:addObject(func)
                local seq = CCSequence:create(arr)
                whitePic:runAction(seq)--白光动画
            end

            local fireArr=CCArray:create()
            for kk=1,24 do
                local nameStr="shine"..kk..".png"
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                fireArr:addObject(frame)
            end
            local animation=CCAnimation:createWithSpriteFrames(fireArr)
            animation:setDelayPerUnit(0.03)
            local ani =CCAnimate:create(animation)
            local fadeIn = CCFadeIn:create(0.3)
            local arr = CCArray:create()
            local whitePic = nil
            if isPoint == nil or isPoint == 1 then
                whitePic = tolua.cast(self.moduleTb[k][self.conformTb[k][1][3]]:getChildByTag(112),"CCSprite")--白光动画
            elseif isPoint == 2 then
                whitePic = tolua.cast(self.moduleTb[self.conformTb[k][1][3]][k]:getChildByTag(112),"CCSprite")--白光动画
            end

            arr:addObject(fadeIn)
            arr:addObject(ani)
            local seq = CCSequence:create(arr)
            whitePic:setOpacity(255)
            whitePic:runAction(seq)
        end
    else

        local function touchDiaMov( )
            print("move touchDialogBg2~~~~~~~~~~~~~~")   
            local function freshCall( )             
                for i=1,self.horiNums do
                    for j=1,self.vertiNums do
                        self.colorAndModuleTb[(i-1) * self.horiNums +j][1] = self.moduleColorTb[i][j]
                        self.colorAndModuleTb[(i-1) * self.horiNums +j][2] = self.moduleHasNumsTb[i][j]
                    end
                end
                acKljzVoApi:setModulTb(self.colorAndModuleTb)
                self.netIsTrue = true
                self.getAwardKeyValueTb = {}
                self.getAwardKeyColorTb = {}
                self.touchDialogBg2:setPosition(ccp(G_VisibleSizeWidth*5.5,G_VisibleSizeHeight*0.5))
            end 
            local function awardShowCall(tag,readyGet,rewards)
                print("ready goto awardShowCall~~~~~~")
                self:awardShowCall(tag,readyGet,rewards)
            end 
            if SizeOfTable(self.getAwardKeyValueTb) == 0 then
                table.insert(self.getAwardKeyValueTb,0)
                table.insert(self.getAwardKeyColorTb,0)
            end
            acKljzVoApi:socketByCall("active.kljz.reward",self.getAwardKeyColorTb,self.getAwardKeyValueTb,awardShowCall,freshCall)
        end 
        local func = CCCallFuncN:create(touchDiaMov)
        local delayTime = CCDelayTime:create(0.4)
        local arr = CCArray:create()
        arr:addObject(delayTime)
        arr:addObject(func)
        local seq = CCSequence:create(arr)
        self.bgLayer:runAction(seq)
    end
end

function acKljzTabOne:conformCleanModuleTb(isPoint,willRoundPos,sameMovModuleTb,sameFixModuleTb)--落体后的检测不能使用这个
    print("willRoundPos----->>>>",willRoundPos)

        self.conformTb[willRoundPos] = self.conformTb[willRoundPos] or {}

        for k,v in pairs(sameMovModuleTb) do
            self.goCenterIdx = self.goCenterIdx + 1
            table.insert(self.conformTb[willRoundPos],v)
        end
        for k,v in pairs(sameFixModuleTb) do
            self.goCenterIdx = self.goCenterIdx + 1
            table.insert(self.conformTb[willRoundPos],v)
        end
end

function acKljzTabOne:flyToCenterModule(cM,xM,yM,cMY,goIdx,isPoint)
    local centerMoudulePos = cMY
    local posx,posy = self.moduleTb[cM][centerMoudulePos]:getPosition()
    if isPoint and isPoint == 2 then
        posx,posy = self.moduleTb[centerMoudulePos][cM]:getPosition()
    end
    local moveto = CCMoveTo:create(0.3,ccp(posx,posy))
    local delayTime = CCDelayTime:create(0.2)
    
    local arr = CCArray:create()
    arr:addObject(delayTime)
    arr:addObject(moveto)
    -- print("self.goCenterIdx == goIdx",self.goCenterIdx , goIdx)
    if self.goCenterIdx == goIdx then
        local function goCenterEnd( ... )
            print("is over?????/")
            self:formatModuleTb(isPoint)    
        end 
        local ffunc=CCCallFuncN:create(goCenterEnd)
        arr:addObject(ffunc)
    end
    local seq = CCSequence:create(arr)
    self.moduleTb[xM][yM]:runAction(seq)
end
function acKljzTabOne:formatModuleTb(isPoint)--isPoint只是用于判断是否为纵向移动

    for k,v in pairs(self.conformTb) do--清除合并 相关的数据
        for m,n in pairs(v) do
            local posx,posy = self.moduleBgTb[n[1]][n[2]]:getPosition()
            self.cleanTbPos[n[1]] = self.cleanTbPos[n[1]] or {}
            self.cleanTbPos[n[1]][n[2]] = ccp(posx,posy)
            -- print("n[1]---n[2]--->>",n[1],n[2],posx,posy,ccp(posx,posy),self.cleanTbPos[n[1]][n[2]])
            if self.moduleTb[n[1]][n[2]] then
                self.moduleTb[n[1]][n[2]]:removeFromParentAndCleanup(true)
                self.moduleTb[n[1]][n[2]] = nil
            end
            if self.moduleHasNumsTb[n[1]][n[2]] then
                self.moduleHasNumsTb[n[1]][n[2]] = nil
            end
            if self.moduleColorTb[n[1]][n[2]] then
                self.moduleColorTb[n[1]][n[2]] = nil
            end

            local function callback( ... )
                if self.moduleBgTb[n[1]][n[2]] then
                    self.moduleBgTb[n[1]][n[2]]:removeFromParentAndCleanup(true)
                    self.moduleBgTb[n[1]][n[2]] = nil
                end
            end 

            local fadeout = CCFadeOut:create(0.2)
            local delayTime = CCDelayTime:create(0.1)
            local fadeoutCall = CCCallFuncN:create(callback)
            local arr = CCArray:create()
            arr:addObject(delayTime)
            arr:addObject(fadeout)
            arr:addObject(fadeoutCall)
            local seq = CCSequence:create(arr)
            if self.moduleBgTb[n[1]][n[2]] then
                self.moduleBgTb[n[1]][n[2]]:runAction(seq)
            end
        end
        if isPoint then
            local chosePosX,chosePosY = (isPoint and isPoint == 2) and v[1][3] or k,(isPoint and isPoint == 2) and k or v[1][3]
            if  self.moduleHasNumsTb[chosePosX][chosePosY] + 1 == 4 then                

                local function callback( ... )
                    local nColor = self.moduleColorTb[chosePosX][chosePosY]
                    local nModule = self.moduleHasNumsTb[chosePosX][chosePosY] + 1
                    local posx,posy = self.moduleBgTb[chosePosX][chosePosY]:getPosition()
                    self.cleanTbPos[chosePosX] = self.cleanTbPos[chosePosX] or {}
                    self.cleanTbPos[chosePosX][chosePosY] = ccp(posx,posy)
                    local nColor = self.moduleColorTb[chosePosX][chosePosY]
                    local bigAwardIcon = CCSprite:createWithSpriteFrameName(self.colorTb[nColor].."_4.png")
                    bigAwardIcon:setPosition(ccp(posx + self.coverInTvPosx +bigAwardIcon:getContentSize().width*0.5, posy + self.coverInTvPosy + bigAwardIcon:getContentSize().height*0.5))
                    self.bgLayer:addChild(bigAwardIcon,11)

                    local moveto = CCMoveTo:create(0.3,self.bigAwardPosTb[nColor])--飞到对应颜色的大奖上
                    local function showBigAwardDia()

                        table.insert(self.getAwardKeyValueTb,nModule-1)
                        table.insert(self.getAwardKeyColorTb,nColor)
                        self:bigAwardIconAndBgAction(nColor)
                        self:bigAwardAction(nColor)
                        
                        bigAwardIcon:removeFromParentAndCleanup(true)
                    end
                    local func = CCCallFuncN:create(showBigAwardDia)
                    local arr = CCArray:create()
                    arr:addObject(moveto)
                    arr:addObject(func)
                    local seq = CCSequence:create(arr)
                    bigAwardIcon:runAction(seq)

                    if self.moduleTb[chosePosX][chosePosY] then
                        self.moduleTb[chosePosX][chosePosY]:removeFromParentAndCleanup(true)
                        self.moduleTb[chosePosX][chosePosY] = nil
                    end
                    if self.moduleHasNumsTb[chosePosX][chosePosY] then
                        self.moduleHasNumsTb[chosePosX][chosePosY] = nil
                    end
                    if self.moduleColorTb[chosePosX][chosePosY] then
                        self.moduleColorTb[chosePosX][chosePosY] = nil
                    end
                    if self.moduleBgTb[chosePosX][chosePosY] then
                        self.moduleBgTb[chosePosX][chosePosY]:removeFromParentAndCleanup(true)
                        self.moduleBgTb[chosePosX][chosePosY] = nil
                    end
                end 

                local fadeout = CCFadeOut:create(0.2)
                local delayTime = CCDelayTime:create(0.2)
                local fadeoutCall = CCCallFuncN:create(callback)
                local arr = CCArray:create()
                arr:addObject(delayTime)
                arr:addObject(fadeout)
                arr:addObject(fadeoutCall)
                local seq = CCSequence:create(arr)
                self.moduleBgTb[chosePosX][chosePosY]:runAction(seq)
            end
        end
    end
    local conformNums,cIdx = SizeOfTable(self.conformTb),0
    local vvIdx = 0

    for k,v in pairs(self.conformTb) do-- 只针对---》》》》》》升级合并module的动画
        -- print("isPoint---->",isPoint,k,SizeOfTable(v))
        -- print("v --1--2--3----->>>>",v[1][1],v[1][2],v[1][3])
        local chosePosX,chosePosY = (isPoint and isPoint == 2) and v[1][3] or k,(isPoint and isPoint == 2) and k or v[1][3]

        cIdx = cIdx + 1
        local function refreshModuleCall(...)
            if self.moduleTb[chosePosX][chosePosY] then
                self.moduleHasNumsTb[chosePosX][chosePosY] = self.moduleHasNumsTb[chosePosX][chosePosY] + 1
                local nColor = self.moduleColorTb[chosePosX][chosePosY]
                local nModule = self.moduleHasNumsTb[chosePosX][chosePosY]
                -- print(self.colorTb[nColor].."_"..nModule..".png")
                -- print("chosePosX----chosePosY----->>>>",chosePosX,chosePosY)
                local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(self.colorTb[nColor].."_"..nModule..".png")
                if frame then
                    tolua.cast(self.moduleTb[chosePosX][chosePosY]:getChildByTag(111),"CCSprite"):setDisplayFrame(frame)
                end
                local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("whiteBg_"..nModule..".png")
                local whiteBg = tolua.cast(self.moduleTb[chosePosX][chosePosY]:getChildByTag(112),"CCSprite")
                if frame then
                    whiteBg:setDisplayFrame(frame)
                    whiteBg:setOpacity(0)
                end

                -- acKljzVoApi:socketByCall("active.kljz.reward",nColor,nModule - 1)--普通奖励请求接口
                table.insert(self.getAwardKeyValueTb,nModule-1)
                table.insert(self.getAwardKeyColorTb,nColor)

                local downIdx = 1

                local function downF( )
                    -- print("in downF~~~~~~~~",v[1][3] , downIdx,v[1][3] - downIdx)
                    if chosePosY - downIdx > 0 and self.moduleTb[chosePosX][chosePosY - downIdx] == nil then--判断下面位置为空
                        if chosePosY - (downIdx+1) > 0 and self.moduleTb[chosePosX][chosePosY - (downIdx+1)] == nil then
                            downIdx = downIdx + 1
                            downF()
                        else
                            local newYy = chosePosY - downIdx
                            
                            local posx,posy = self.moduleBgTb[chosePosX][chosePosY]:getPosition()--将即将换位置的（升级后）module旧pos保存下来
                            self.cleanTbPos[chosePosX][chosePosY] = ccp(posx,posy)

                            self.moduleBgTb[chosePosX][newYy] = self.moduleBgTb[chosePosX][chosePosY]--背景
                            self.moduleTb[chosePosX][newYy] = self.moduleTb[chosePosX][chosePosY]--ModuleIcon和底图
                            self.moduleHasNumsTb[chosePosX][newYy] = self.moduleHasNumsTb[chosePosX][chosePosY]--icon标识
                            self.moduleColorTb[chosePosX][newYy] = self.moduleColorTb[chosePosX][chosePosY]--icon颜色标识

                            self.moduleBgTb[chosePosX][chosePosY],self.moduleTb[chosePosX][chosePosY],self.moduleHasNumsTb[chosePosX][chosePosY],self.moduleColorTb[chosePosX][chosePosY] = nil,nil,nil,nil--旧数据全部干掉
                            local movTo = CCMoveTo:create(0.3,self.cleanTbPos[chosePosX][newYy])
                            local movTo2 = CCMoveTo:create(0.3,self.cleanTbPos[chosePosX][newYy])
                            local delayTime = CCDelayTime:create(0.1)
                            local delayTime2 = CCDelayTime:create(0.1)
                            local arr = CCArray:create()
                            local arr2 = CCArray:create()
                            arr:addObject(delayTime)
                            arr:addObject(movTo)
                            arr2:addObject(delayTime2)
                            arr2:addObject(movTo2)

                            local seq = CCSequence:create(arr)
                            local seq2 = CCSequence:create(arr2)
                            self.moduleTb[chosePosX][newYy]:runAction(seq)
                            self.moduleBgTb[chosePosX][newYy]:runAction(seq2)
                        end
                    else--判断下面位置为不空
                        -- print("下面不空的时候~~~~~~",conformNums , cIdx)
                    end
                end 

                if nModule == 4 then--大奖飘出动画，同时消除自身module 和相关数据
                    -- print("nModule------>>>>>",nModule)
                else
                    downF()
                end
            end
        end
        local delayTime = CCDelayTime:create(0.4)

           

        local rfCall = CCCallFuncN:create(refreshModuleCall)
        local delayTime2 = CCDelayTime:create(0.4)
        local arr = CCArray:create()
        arr:addObject(delayTime)
        arr:addObject(rfCall)
        arr:addObject(delayTime2)
        -- print("conformNums----cIdx------>>>>>",conformNums,cIdx)
        if conformNums == cIdx then
            local function refreshModuleAllData( ... )
                print("is refreshModuleAllData?????/",conformNums , cIdx )
                self:refreshAndDownAllModuleTb(isPoint)
            end 
            local ffunc=CCCallFuncN:create(refreshModuleAllData)
            arr:addObject(ffunc)
        end
        local seq = CCSequence:create(arr)

        self.bgLayer:runAction(seq)
    end
end

function acKljzTabOne:refreshAndDownAllModuleTb( isPoint )
    print(" in refreshAndDownAllModuleTb~~~~~")
    self.useIdx = 1
    for k,v in pairs(self.conformTb) do
        local chosePos = (isPoint and isPoint == 2) and k or v[1][2]
        self.useIdx = chosePos > self.useIdx and chosePos or self.useIdx
    end
    for i=1,self.horiNums do
        for j=1,self.vertiNums do
            local addPosY = 1
            local addT = 0.1
            local function traversalFun( )
                if self.moduleTb[i][j] == nil then
                    if j + addPosY <= self.vertiNums then--寻找下一个modul是否有
                        if self.moduleTb[i][j+addPosY] == nil then
                            addPosY = addPosY + 1
                        else 
                            self.moduleBgTb[i][j] = self.moduleBgTb[i][j + addPosY]--背景
                            self.moduleTb[i][j] = self.moduleTb[i][j + addPosY]--ModuleIcon和底图
                            self.moduleHasNumsTb[i][j] = self.moduleHasNumsTb[i][j + addPosY]--icon标识
                            self.moduleColorTb[i][j] = self.moduleColorTb[i][j + addPosY]--icon颜色标识

                            self.moduleBgTb[i][j + addPosY],self.moduleTb[i][j + addPosY],self.moduleHasNumsTb[i][j + addPosY],self.moduleColorTb[i][j + addPosY]=nil,nil,nil,nil
                            -- print("iii----jjj----.>>>>>",i,j)
                            self:downAction(i,j,addT,nil,isPoint)
                            addT = addT +0.1
                        end
                        traversalFun()
                    else--如超界 创建新Module 和 相关数据
                        local nModule = 1
                        local nColor = math.random(1,3)
                        
                        -- nColor = 1;nModule = 1

                        local moduleBg = CCSprite:createWithSpriteFrameName("mdBg.png")
                        moduleBg:setAnchorPoint(ccp(0,0))
                        moduleBg:setPosition(ccp(0,0))
                        moduleBg:setColor(self.RGBTb[nColor])
                        --(j-1)*self.moduleHeight+self.vertiSingleLastNums*j-self.vertiSingleLastNums*0.5+
                        moduleBg:setPosition(ccp((i-1)*self.moduleWidth+self.horiSingleLastNums*i-self.horiSingleLastNums*0.5,500))
                        self.clayer:addChild(moduleBg)
                        self.moduleBgTb[i][j] = moduleBg

                        local iconBg=CCSprite:createWithSpriteFrameName("mdBg.png")
                        iconBg:setAnchorPoint(ccp(0,0))
                        iconBg:setOpacity(0)
                        iconBg:setPosition(ccp((i-1)*self.moduleWidth+self.horiSingleLastNums*i-self.horiSingleLastNums*0.5,500))
                        self.clayer:addChild(iconBg,2)
                        self.moduleTb[i][j] = iconBg

                        local moduleIcon = CCSprite:createWithSpriteFrameName(self.colorTb[nColor].."_"..nModule..".png")
                        moduleIcon:setPosition(getCenterPoint(iconBg))
                        moduleIcon:setTag(111)
                        iconBg:addChild(moduleIcon)

                        local moduleWhitePic = CCSprite:createWithSpriteFrameName("whiteBg_"..nModule..".png")
                        moduleWhitePic:setPosition(getCenterPoint(iconBg))
                        moduleWhitePic:setTag(112)
                        iconBg:addChild(moduleWhitePic)
                        moduleWhitePic:setOpacity(0)

                        self.moduleHasNumsTb[i][j] = nModule
                        self.moduleColorTb[i][j] = nColor
                        -- print("i-----j----->>>",i,j)
                        self:downAction(i,j,addT,useIdx,isPoint)
                        addT = addT +0.1
                    end
                end
            end 
            traversalFun( )
        end
    end
end

function acKljzTabOne:downAction(i,j,addT,useIdx,isPoint)
    self.downModuleTb[i] = j
    local toHere = ccp((i-1)*self.moduleWidth+self.horiSingleLastNums*i-self.horiSingleLastNums*0.5,(j-1)*self.moduleHeight+self.vertiSingleLastNums*j-self.vertiSingleLastNums*0.5)
    local movTo = CCMoveTo:create(0.1,toHere)
    local movTo2 = CCMoveTo:create(0.1,toHere)
    local delayTime = CCDelayTime:create(addT)
    local delayTime2 = CCDelayTime:create(addT)
    local delayTime3 = CCDelayTime:create(addT)
    local delayTime4 = CCDelayTime:create(addT)
    local arr = CCArray:create()
    local arr2 = CCArray:create()
    arr:addObject(delayTime)
    arr:addObject(movTo)
    arr2:addObject(delayTime2)
    arr2:addObject(movTo2)
    -- print("j-----self.useIdx---->>>>",j,self.useIdx)
     if j == self.useIdx then
        self.useIdx = nil
        local function cleanMiddleUseData( ... )
            -- print("cleanMiddleUseData~~~~~&&~~~~beginTrversalDownModule~~~~~~~~~~~",isPoint)
            if isPoint ==nil or isPoint ==1 then--ispoint:2 pox:v[1][3]
                for k,v in pairs(self.conformTb) do
                    if self.downModuleTb[k] ==nil then
                        self.downModuleTb[k] =v[1][3]
                    -- else
                    --     print("k---self.downModuleTb[k]---->>",k,self.downModuleTb[k])
                    --     print("v[1][3]---->>>",v[1][3])
                    end
                end
            elseif isPoint ==2 then
                for k,v in pairs(self.conformTb) do
                    if self.downModuleTb[v[1][3]] ==nil then
                        self.downModuleTb[v[1][3]] =k
                    -- else
                    --     print("v[1][3]---self.downModuleTb[v[1][3]]---->>",v[1][3],self.downModuleTb[v[1][3]])
                    --     print("kkk---->>>",k)
                    end
                end
            end
            -- print("downModuleTb~~~~~~~~~~~~~IIIIIIIII----------")
            -- for k,v in pairs(self.downModuleTb) do
            --     print(k,v)
            -- end
            -- print("downModuleTb~~~~~~~~~~~~~IIIIIIIII-----------")
            self:beginTrversalDownModule()
        end 
        local ffunc=CCCallFuncN:create(cleanMiddleUseData)
        arr:addObject(ffunc)
    end
    arr:addObject(delayTime3)
    arr2:addObject(delayTime4)
    local seq = CCSequence:create(arr)
    local seq2 = CCSequence:create(arr2)
    self.moduleTb[i][j]:runAction(seq)
    self.moduleBgTb[i][j]:runAction(seq2)
end
function acKljzTabOne:beginTrversalDownModule()
    self.cleanTbPos = {}
    self.conformTb = {}
    self.goCenterIdx = 0
    for k,v in pairs(self.downModuleTb) do
        -- print("in self.downModuleTb--->k-->v---->>",k,v)
        self:howManyModuleToClean(2,k,v,true)    
    end
    self.downModuleTb = {}
    self:downUseInConformcleanModuleTb()
end

function acKljzTabOne:downUseInConformcleanModuleTb( )
    print("in downUseInConformcleanModuleTb~~~~~~~")

    for k,v in pairs(self.spCenterMTb) do--k :Y  v :X
        --v = {x坐标}
        if self.conformTb[k] then
            -- local isHas = false
            for m,n in pairs(self.conformTb[k]) do
                -- print("k--v-->>",k,v)
                -- print("n[2]----n[1]---->>",n[2],n[1])
                if k == n[2] and v ==n[1] then
                    table.remove(self.conformTb[k],m)
                    self.goCenterIdx = self.goCenterIdx - 1 
                    if self.conformTb[k][m] and self.conformTb[k][m][3] and v ~= self.conformTb[k][m][3] then
                        self.conformTb[k][m][3] = v
                    end
                elseif v ~= n[3] then
                    -- print("v ~-n[3]------>>>>>",v,n[3])
                    self.conformTb[k][m][3] = v
                end
            end

            if self.spCenterMTb2[k] then
                -- print(" yes sp2 has !!!!!!")
                table.remove(self.spCenterMTb2,k)
                self.spCenterMTb2[k] = nil
            end
        end
        
    end

    local cfTb = {}
    for k,v in pairs(self.conformTb) do
        for m,n in pairs(self.conformTb) do
            if m ~= k and cfTb[k] == nil then
                for kk,vv in pairs(v) do
                    for mm,nn in pairs(n) do
                        if k == nn[2] and vv[3] == nn[1] then
                            self.goCenterIdx = self.goCenterIdx - 1 
                            table.remove(n,mm)
                            cfTb[m] = k
                        end
                    end
                end
            end
        end
    end

    for k,v in pairs(self.conformTb) do
        if cfTb[k] then
            local newPos = cfTb[k]
            -- print("newPos----kkk---->>>",newPos,k)
            for m,n in pairs(v) do
                if newPos == v[2] and v[1] == v[3] then
                    -- print(" is has??????????")
                else
                    table.insert(self.conformTb[newPos],n)
                end
            end
            -- print("v[3]---->>>",v[1][3])
            -- print("k------>>>>",k)
            -- print("self.conformTb[newPos][1][3]----->>>>",self.conformTb[newPos][1][3])
            table.insert(self.conformTb[newPos],{v[1][3],k,self.conformTb[newPos][1][3]})
        end
    end
    for k,v in pairs(cfTb) do
        table.remove(self.conformTb,k)
        self.conformTb[k] = nil
    end

    -- print("self.goCenterIdx-----11111>>>>",self.goCenterIdx)
    for k,v in pairs(self.spCenterMTb2) do
        if self.conformTb[k] then
            -- local isHas = false
            for m,n in pairs(self.conformTb[k]) do
                -- print("k--v---222>>",k,v)
                -- print("n[2]----n[1]----2222>>",n[2],n[1])
                if k == n[2] and v ==n[1] then
                    -- isHas = true
                    table.remove(self.conformTb[k],m)
                    self.goCenterIdx = self.goCenterIdx - 1 
                    if self.conformTb[k][m] and self.conformTb[k][m][3] and v ~= self.conformTb[k][m][3] then
                        self.conformTb[k][m][3] = v
                    end
                elseif v ~= n[3] then
                    -- print("v ~-n[3]------>2222>>>>",v,n[3])
                    n[3] = v
                end
            end
        end
    end
    -- print("self.goCenterIdx-----22222>>>>",self.goCenterIdx)

    for k,v in pairs(self.conformTb) do
        for m,n in pairs(v) do
            if k == n[2] and n[1] == n[3] then
                table.remove(v,m)
                self.goCenterIdx = self.goCenterIdx - 1 
            end
            -- print(string.format("kkkk:%s--m:%s---n[1]:%s--n[2]:%s--n[3]:%s",k,m,n[1],n[2],n[3]))
        end
    end
    -- print("=================================================")
    for k,v in pairs(self.conformTb) do
        for m,n in pairs(v) do
            for i,j in pairs(v) do
                if m ~= i then
                    if n[1] == j[1] and n[2] == j[2] and n[3] == j[3] then
                        table.remove(v,i)
                        self.goCenterIdx = self.goCenterIdx - 1
                    end
                end
            end
        end
    end

    self.spCenterMTb,self.spCenterMTb2 = {},{}
    print("go ----->>>>readyGoFlyToCeneter",self.test)
    -- if self.test < 5 then
        self:readyGoFlyToCeneter(2)
        -- self.test = self.test + 1
    -- end
end



