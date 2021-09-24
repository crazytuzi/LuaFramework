acMjzxTabOne={

}

function acMjzxTabOne:new(parent)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    nc.tv            = nil
    nc.bgLayer       = nil
    nc.layerNum      = nil
    nc.parent        = parent
    -- nc.cellHeight =145
    nc.isTodayFlag   = acMjzxVoApi:isToday()
    nc.choseAwardIdx = 1--抽奖 默认为 单抽
    nc.url           = G_downloadUrl("active/acMjzxMiddleBg.jpg") or nil
    nc.actionBgTb2   = {}
    nc.rewardShowTb  = nil
    nc.rewardShowLb  = nil
    nc.rewardShowBg= nil
    nc.newRewardList = {}
    return nc;
end
function acMjzxTabOne:dispose( )
    self.layerNum      = nil
    self.bgLayer       = nil
    self.tv            = nil
    self.choseAwardIdx = nil
    self.parent        = nil
    self.actionBgTb2    = nil
    self.rewardShowTb  = nil
    self.rewardShowLb  = nil
    self.rewardShowBg  = nil
    self.newRewardList = nil
end

function acMjzxTabOne:init(layerNum,parent)
    -- print(" tabOne is init~~~~~~~~")
    acMjzxVoApi:getRewardPool()
    self.activeName = acMjzxVoApi:getActiveName()
    self.bgLayer    = CCLayer:create()
    self.layerNum   = layerNum
    self.parent     = parent
    self.acVo       = acMjzxVoApi:getAcVo()
    self:initUp()
    self:initMiddle()
    self:initDown()
    return self.bgLayer
end

function acMjzxTabOne:initUp( )
    local h = G_VisibleSizeHeight-190
    local h2 = h - 20
    -- local timeStr=acMjzxVoApi:getTimer()
    local posxSubWidth = 0
    if G_getCurChoseLanguage() == "fr" then
        posxSubWidth = 40
    end



    local descStr1=acMjzxVoApi:getTimeStr()
    local descStr2=acMjzxVoApi:getRewardTimeStr()
    local lbRollView,timeLb,rewardLb=G_LabelRollView(CCSizeMake(G_VisibleSizeWidth - 200,35),descStr1,25,kCCTextAlignmentCenter,G_ColorGreen,nil,descStr2,G_ColorYellowPro,2,2,2,nil)
    lbRollView:setPosition(100,G_VisibleSizeHeight - 180 - 25)
    self.bgLayer:addChild(lbRollView,2)
    self.timeLb=timeLb
    self.rTimeLb=rewardLb


    local function touchDialog()
        self.bgLayer:stopAllActions()
    end
    self.tDialogHeight = 80
    self.touchDialog = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
    self.touchDialog:setTouchPriority(-(self.layerNum-1)*20-5)
    self.touchDialog:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-self.tDialogHeight))
    self.touchDialog:setOpacity(0)
    self.touchDialog:setIsSallow(true) -- 点击事件透下去
    self.touchDialog:setPosition(ccp(G_VisibleSizeWidth*1.5,(G_VisibleSizeHeight-self.tDialogHeight)*0.5))
    self.bgLayer:addChild(self.touchDialog,99)


    local function touchInfo()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local tabStr = {}
        for i=1,4 do
            table.insert(tabStr,getlocal("activity_mjzx_tip"..i))
        end
        local titleStr = getlocal("activity_baseLeveling_ruleTitle")
        local textSize = G_getCurChoseLanguage() =="ru" and 20 or 25
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,textSize)
    end
    local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touchInfo,1,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,0.5))
    menuItemDesc:setScale(1)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-4)
    menuDesc:setPosition(ccp(self.bgLayer:getContentSize().width-15, h2))
    self.bgLayer:addChild(menuDesc,2)

    local topBorder = LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png",CCRect(103,0,2,80),function()end)
    topBorder:setContentSize(CCSizeMake(G_VisibleSizeWidth,100))
    topBorder:setAnchorPoint(ccp(0.5,1))
    topBorder:setPosition(G_VisibleSizeWidth * 0.5,G_VisibleSizeHeight -160)
    self.bgLayer:addChild(topBorder)

    local titleBg=CCSprite:createWithSpriteFrameName("believerTitleBg.png")
    titleBg:setPosition(ccp(G_VisibleSizeWidth * 0.5,topBorder:getPositionY() - topBorder:getContentSize().height + 10))
    self.bgLayer:addChild(titleBg)
    local strSize2 = G_isAsia() and 25 or 22
    local titleStr = GetTTFLabel(getlocal("activity_mjzx_tab1_title"),strSize2,"Helvetica-bold")
    titleStr:setPosition(getCenterPoint(titleBg))
    titleStr:setColor(G_ColorYellowPro2)
    titleBg:addChild(titleStr)

    local bigRewardBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)--"greenBlackBg2.png",CCRect(10,10,12,12),function ()end)
    bigRewardBg:setContentSize(CCSizeMake(616,150))
    bigRewardBg:setPosition(ccp(G_VisibleSizeWidth*0.5,titleBg:getPositionY() - titleBg:getContentSize().height * 0.5 - 2))
    bigRewardBg:setAnchorPoint(ccp(0.5,1))
    self.bigRewardBg = bigRewardBg
    self.bgLayer:addChild(bigRewardBg)

    local upRedLine = CCSprite:createWithSpriteFrameName("monthlyBar.png")
    upRedLine:setPosition(ccp(bigRewardBg:getContentSize().width * 0.5,bigRewardBg:getContentSize().height))
    upRedLine:setAnchorPoint(ccp(0.5,1))
    bigRewardBg:addChild(upRedLine)

    local useWidth = bigRewardBg:getContentSize().width--111:icon背景图的宽度
    local heroList = acMjzxVoApi:formatHero()
    for i=1,5 do
        local hBg = CCSprite:createWithSpriteFrameName("mjzxIconBg.png")
        hBg:setPosition(ccp(useWidth*0.195*i - 111*0.6 + 5*i,bigRewardBg:getContentSize().height * 0.5))
        bigRewardBg:addChild(hBg)

        --添加将领点击事件
        local function touchHeroIcon(...)
            PlayEffect(audioCfg.mouseClick)        
            require "luascript/script/game/scene/gamedialog/activityAndNote/acHuoxianmingjiangHeroInfoDialog"

            local hid = heroList[i].name
            local heroProductOrder = heroList[i].quality

            local td = acHuoxianmingjiangHeroInfoDialog:new(hid,heroProductOrder,"mjzx")
            local dialog = td:init("PanelHeaderPopup.png",self.layerNum+1,CCRect(168, 86, 10, 10),CCSizeMake(600,800),getlocal("report_hero_message"))
            sceneGame:addChild(dialog,self.layerNum+1)
            
         end   
        local hid = heroList[i].name
        -- print("hid---->>>>",hid,key,type,quality)
        local heroProductOrder = heroList[i].quality
        local heroIcon = heroVoApi:getHeroIcon(hid,heroProductOrder,false,touchHeroIcon)
        heroIcon:setTouchPriority(-(self.layerNum-1)*20-3)
        heroIcon:setPosition(getCenterPoint(hBg))
        heroIcon:setScale(80/heroIcon:getContentSize().width)
        hBg:addChild(heroIcon,1)

        local strSize5 = G_isAsia() and 20 or 17
        local heroNameStr = GetTTFLabelWrap(heroVoApi:getHeroName(hid),strSize5,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop,"Helvetica-bold")
        heroNameStr:setAnchorPoint(ccp(0.5,1))
        heroNameStr:setColor(G_ColorYellowPro)
        heroNameStr:setPosition(ccp(hBg:getContentSize().width *0.5, 6))
        hBg:addChild(heroNameStr)
    end
end

function acMjzxTabOne:initMiddle()
    self:initMiddleBg()

    local middleBg2 = CCSprite:createWithSpriteFrameName("acMjzxHeroBg.png")
    middleBg2:setAnchorPoint(ccp(0.5,1))
    middleBg2:setPosition(ccp(G_VisibleSizeWidth * 0.5,self.bigRewardBg:getPositionY() - self.bigRewardBg:getContentSize().height - 30))
    self.bgLayer:addChild(middleBg2,1)
    self.middleBg2 = middleBg2
    local middleBg3 = CCSprite:createWithSpriteFrameName("acMjzxHeroBg.png")
    middleBg3:setAnchorPoint(ccp(0.5,1))
    middleBg3:setPosition(ccp(G_VisibleSizeWidth * 0.5,self.bigRewardBg:getPositionY() - self.bigRewardBg:getContentSize().height - 30))
    self.bgLayer:addChild(middleBg3,1)
    self.actionBg = middleBg3
    self.actionBg:setOpacity(0)
    local curScreen,scaleValueY = G_getIphoneType(),1
    if curScreen == G_iphone5 then
        scaleValueY = 1.2
    elseif curScreen == G_iphoneX then
        scaleValueY = 1.3
    end
    middleBg2:setScale(scaleValueY)
    middleBg3:setScale(scaleValueY)

    
    self:initAwardAndRecord()

end

function acMjzxTabOne:initDown( )
    self:initBtn()
end

function acMjzxTabOne:initMiddleBg( )
    local curScreen,scaleValueY,bottonPosy = G_getIphoneType(),1,10
    local needPosy = self.bigRewardBg:getPositionY() - self.bigRewardBg:getContentSize().height
    if curScreen == G_iphone5 then
        scaleValueY = 1.2
        bottonPosy = 15
    elseif curScreen == G_iphoneX then
        scaleValueY = 1.3
        bottonPosy = 18
    end

    local function onLoadIcon(fn,icon)
        if(self.bgLayer and tolua.cast(self.bgLayer,"CCNode"))then
            icon:setAnchorPoint(ccp(0.5,1))
            self.bgLayer:addChild(icon)
            icon:setPosition(ccp(G_VisibleSizeWidth * 0.5,needPosy - 2))
            icon:setScaleY(scaleValueY)
        end
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local webImage=LuaCCWebImage:createWithURL(self.url,onLoadIcon)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    local strSize4 = G_isAsia() and 22 or 20
    local buyTip = GetTTFLabelWrap(getlocal("activity_mjzx_buyTip"),strSize4,CCSizeMake(G_VisibleSizeWidth - 10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop,"Helvetica-bold")
    buyTip:setAnchorPoint(ccp(0.5,1))
    buyTip:setPosition(ccp(G_VisibleSizeWidth * 0.5,needPosy - 378 * scaleValueY - bottonPosy))
    self.bgLayer:addChild(buyTip,1)

    local bottomLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)--modifiersLine2
    bottomLine:setContentSize(CCSizeMake(G_VisibleSizeWidth - 10,bottomLine:getContentSize().height))
    bottomLine:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,buyTip:getPositionY() - buyTip:getContentSize().height - bottonPosy))
    bottomLine:setAnchorPoint(ccp(0.5,0.5))
    self.bgLayer:addChild(bottomLine,1)
end

function acMjzxTabOne:initAwardAndRecord( )
    
    local btnPosY = self.bigRewardBg:getPositionY() - self.bigRewardBg:getContentSize().height - 20
    if G_getIphoneType() == G_iphoneX then
        btnPosY = btnPosY - 10
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

        require "luascript/script/game/scene/gamedialog/activityAndNote/acThrivingSmallDialog"
        local rewardTb = acMjzxVoApi:getRewardPool()
        local function stopAcation( )
            self:bigAwardAction(tag,true)
        end 
        local titleStr = getlocal("award")
        local descStr = getlocal("activity_mjzx_awardTip")
        local needTb = {"mjzx",titleStr,descStr,rewardTb,SizeOfTable(rewardTb)}
        local bigAwardDia = acThrivingSmallDialog:new(self.layerNum+1,needTb)
        bigAwardDia:init()
    end
    local poolBtn=GetButtonItem("taskBox5.png","taskBox5.png","taskBox5.png",rewardPoolHandler,11)
    poolBtn:setScale(0.8)
    poolBtn:setAnchorPoint(ccp(0,1))
    local poolMenu=CCMenu:createWithItem(poolBtn)
    poolMenu:setTouchPriority(-(self.layerNum-1)*20-3)
    poolMenu:setPosition(ccp(40,btnPosY + 10))
    self.bgLayer:addChild(poolMenu,1)
    local poolBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    poolBg:setAnchorPoint(ccp(0.5,1))
    poolBg:setContentSize(CCSizeMake(80,40))
    poolBg:setPosition(ccp(poolBtn:getContentSize().width/2,5))
    poolBg:setScale(1/poolBtn:getScale())
    poolBtn:addChild(poolBg)
    local poolLb=GetTTFLabelWrap(getlocal("award"),22,CCSize(130,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    poolLb:setPosition(poolBg:getContentSize().width/2,poolBg:getContentSize().height/2)
    -- poolLb:setColor(G_ColorYellowPro)
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
    logBtn:setAnchorPoint(ccp(1,1))
    logBtn:setScale(0.8)
    local logMenu=CCMenu:createWithItem(logBtn)
    logMenu:setTouchPriority(-(self.layerNum-1)*20-3)
    logMenu:setPosition(ccp(G_VisibleSizeWidth-30,btnPosY))
    self.bgLayer:addChild(logMenu,1)
    local logBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    logBg:setAnchorPoint(ccp(0.5,1))
    logBg:setContentSize(CCSizeMake(logBtn:getContentSize().width+10,40))
    logBg:setPosition(ccp(logBtn:getContentSize().width/2,0))
    logBg:setScale(1/logBtn:getScale())
    logBtn:addChild(logBg)
    local logLb=GetTTFLabelWrap(getlocal("serverwar_point_record"),22,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    logLb:setPosition(logBg:getContentSize().width/2,logBg:getContentSize().height/2)
    -- logLb:setColor(G_ColorYellowPro)
    logBg:addChild(logLb)
end

function acMjzxTabOne:logHandler()
    print("show record~~~~~")
    local function showLog()
        local rewardLog=acMjzxVoApi:getRewardLog() or {}
        if rewardLog and SizeOfTable(rewardLog)>0 then
            local logList={}
            for k,v in pairs(rewardLog) do
                local num,reward,time,point=v.num,v.reward,v.time,v.point
                local title = {getlocal("activity_jsss_hx_logt",{num,point})}

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
    local rewardLog=acMjzxVoApi:getRewardLog()
    if rewardLog then
        showLog()
    else
        acMjzxVoApi:acMjzxRequest("getlog",{},showLog)
    end
end
-----------------b t n-----------------
function acMjzxTabOne:initBtn( )
    local curScreen,btnPosY = G_getIphoneType(),40
    local cost1,cost2=acMjzxVoApi:getLotteryCost()
    if curScreen == G_iphone5 or curScreen == G_iphoneX then
        btnPosY = 90
    end
    local function lotteryHandler()
        self:lotteryHandler()
    end
    self.freeBtn=self:getLotteryBtn(1,ccp(G_VisibleSizeWidth/2-120,btnPosY),lotteryHandler)
    self.lotteryBtn=self:getLotteryBtn(1,ccp(G_VisibleSizeWidth/2-120,btnPosY),lotteryHandler,cost1)

    local function multiLotteryHandler()
        self:lotteryHandler(true)
    end
    local num=acMjzxVoApi:getMultiNum()
    self.multiLotteryBtn=self:getLotteryBtn(num,ccp(G_VisibleSizeWidth/2+120,btnPosY),multiLotteryHandler,cost2,true)
    self:refreshLotteryBtn()
    self:tick()
end
function acMjzxTabOne:getLotteryBtn(num,pos,callback,cost,isMul)
    local btnZorder,btnFontSize=2,25
    local curScreen,strPosY = G_getIphoneType(),8
    if curScreen == G_iphone5 or curScreen == G_iphoneX then
        strPosY = 15
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
        local btnStr=getlocal("activity_qxtw_buy",{num})
        lotteryBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",lotteryHandler,nil,btnStr,btnFontSize/btnScale,11)
        local costLb=GetTTFLabel(tostring(cost),25)
        costLb:setAnchorPoint(ccp(0,0.5))
        -- costLb:setColor(G_ColorYellowPro)
        costLb:setScale(1/btnScale)
        lotteryBtn:addChild(costLb)
        local costSp=CCSprite:createWithSpriteFrameName("IconGold.png")
        costSp:setAnchorPoint(ccp(0,0.5))
        costSp:setScale(1/btnScale)
        lotteryBtn:addChild(costSp)
        local lbWidth=costLb:getContentSize().width+costSp:getContentSize().width+10
        costLb:setPosition(lotteryBtn:getContentSize().width/2-lbWidth/2,lotteryBtn:getContentSize().height+costLb:getContentSize().height/2+strPosY)
        costSp:setPosition(costLb:getPositionX()+costLb:getContentSize().width+10,costLb:getPositionY())
    else
        lotteryBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",lotteryHandler,nil,getlocal("daily_lotto_tip_2"),btnFontSize/btnScale,11)
    end
    lotteryBtn:setScale(btnScale)
    local lotteryMenu=CCMenu:createWithItem(lotteryBtn)
    lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-3)
    lotteryMenu:setPosition(pos)
    self.bgLayer:addChild(lotteryMenu,btnZorder)

    return lotteryBtn
end

function acMjzxTabOne:actionBegin(rewardlist,pt,point)
    local function shineCall()
        -- self.parent:runAwardAction(rewardlist,pt,point)
    end
    local endCall = CCCallFuncN:create(shineCall)
    local fadeIn = CCFadeIn:create(0.1)
    local fadeOut = CCFadeOut:create(0.1)
    -- local fadeIn2 = CCFadeIn:create(0.1)
    -- local fadeOut2 = CCFadeOut:create(0.1)
    local arr = CCArray:create()
    arr:addObject(fadeIn)
    -- arr:addObject(fadeOut)
    -- arr:addObject(fadeIn2)
    arr:addObject(endCall)
    arr:addObject(fadeOut)
    local seq = CCSequence:create(arr)
    self.actionBg:runAction(seq)
end

function acMjzxTabOne:lotteryHandler(multiFlag)
    local multiFlag=multiFlag or false
    local function realLottery(num,cost)
        local function callback(pt,point,rewardlist,hxReward)
            if cost and tonumber(cost)>0 then
                playerVoApi:setValue("gems",playerVoApi:getGems()-tonumber(cost))
            end
            if rewardlist and type(rewardlist)=="table" then
                
                if hxReward then
                    table.insert(rewardlist,1,hxReward)
                end
                self.newRewardList = rewardlist

                if self.parent and self.parent.runAwardAction then
                    self:actionBegin(rewardlist,pt,point)
                    self.parent:runAwardAction(rewardlist,pt,point)
                    self.parent.touchDia:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight * 0.5))

                    -- self.parent:runAwardAction(rewardlist,pt,point)
                end
            end
            self.isTodayFlag = acMjzxVoApi:isToday()
            self:refreshLotteryBtn()
        end
        local freeNeed = acMjzxVoApi:getFirstFree()
        -- print("num----free----->",num,freeNeed)

        acMjzxVoApi:acMjzxRequest("buy",{num=num,free=freeNeed},callback)
    end

    local cost1,cost2=acMjzxVoApi:getLotteryCost()
    local cost,num=0,1
    if acMjzxVoApi:isToday()==false then
        acMjzxVoApi:resetFreeLottery()
    end
    local freeNeed = acMjzxVoApi:getFirstFree()
    if cost1 and cost2 then
        if multiFlag==false and freeNeed==1 then
            cost=cost1
        elseif multiFlag==true then
            cost=cost2
            num=acMjzxVoApi:getMultiNum()
        end
    end
    if playerVoApi:getGems()<cost then
        GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost)
        do return end
    else
        local function sureClick()
            -- print("cost---sureClick-->",cost)
            realLottery(num,cost)
        end
        local function secondTipFunc(sbFlag)
            local keyName=acMjzxVoApi:getActiveName()
            local sValue=base.serverTime .. "_" .. sbFlag
            G_changePopFlag(keyName,sValue)
        end
        if cost and cost>0 then
            local keyName=acMjzxVoApi:getActiveName()
            if G_isPopBoard(keyName) then
                self.secondDialog=G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{cost}),true,sureClick,secondTipFunc)
            else
                sureClick()
            end
        else
            sureClick()
        end
    end
end
-----------------e n d-----------------
function acMjzxTabOne:refreshLotteryBtn()
    if self.freeBtn and self.lotteryBtn and self.multiLotteryBtn then
        if acMjzxVoApi:isEnd() ==false and acMjzxVoApi:acIsStop() ==false then
             local freeNeed = acMjzxVoApi:getFirstFree()
             -- print("freeNeed------>",freeNeed,self.isTodayFlag)
            if freeNeed==0 or self.isTodayFlag == false then--免费 0
                self.lotteryBtn:setVisible(false)
                self.freeBtn:setVisible(true)
                self.multiLotteryBtn:setEnabled(false)
                if freeNeed == 1 then
                    acMjzxVoApi:setFirstFree(0)
                end
            else
                self.freeBtn:setVisible(false)
                self.lotteryBtn:setVisible(true)
                self.multiLotteryBtn:setEnabled(true)
            end
        else
            self.lotteryBtn:setEnabled(false)
            self.freeBtn:setEnabled(false)
            self.lotteryBtn:setVisible(true)
            self.freeBtn:setVisible(false)
            self.multiLotteryBtn:setEnabled(false)
        end
        if  self.againTip then
            self.againTip:removeFromParentAndCleanup(true)
        end
        local againNum,againStr,nowColor = acMjzxVoApi:getAgainNum(),nil,G_ColorWhite
        if againNum > 1 then
            againStr = "activity_mjzx_rewardAgain"
        else
            nowColor = G_ColorYellowPro
            againStr = "activity_mjzx_rewardAgainEnd"
        end

        local strSize3 = G_isAsia() and 20 or 19
        local colorTab={nowColor,G_ColorYellowPro,nowColor}
        local againStr=getlocal(againStr,{acMjzxVoApi:getAgainNum()})
        local againTip = G_getRichTextLabel(againStr,colorTab,strSize3,G_VisibleSizeWidth,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop,0,true)
        self.againTip = againTip
        self.againTip:setAnchorPoint(ccp(0.5,1))
        self.againTip:setPosition(ccp(self.middleBg2:getContentSize().width *0.5,-20))
        self.middleBg2:addChild(self.againTip)

        local curScreen= G_getIphoneType()
        if curScreen == G_iphone5 then
            self.againTip:setScale(0.9)
        elseif curScreen == G_iphoneX then
            self.againTip:setScale(0.9)
        end
    end
end

function acMjzxTabOne:tick()
    local isEnd=acMjzxVoApi:isEnd()
    if isEnd==false then
        local todayFlag=acMjzxVoApi:isToday()
        -- print("here????????",todayFlag)
        if self.isTodayFlag==true and todayFlag==false and acMjzxVoApi:getFirstFree() ~= 0  then
            self.isTodayFlag=false
            acMjzxVoApi:setFirstFree(0)
            --重置免费次数
            acMjzxVoApi:resetFreeLottery()
            self:refreshLotteryBtn()
        end
    else
        self.lotteryBtn:setEnabled(false)
        self.freeBtn:setEnabled(false)
        self.lotteryBtn:setVisible(true)
        self.freeBtn:setVisible(false)
        self.multiLotteryBtn:setEnabled(false)
    end
    self:updateAcTime()
end

function acMjzxTabOne:updateAcTime()
        if self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
            self.timeLb:setString(acMjzxVoApi:getTimeStr())
        end
        if self.rTimeLb and tolua.cast(self.rTimeLb,"CCLabelTTF") then
            self.rTimeLb:setString(acMjzxVoApi:getRewardTimeStr())
        end
end






