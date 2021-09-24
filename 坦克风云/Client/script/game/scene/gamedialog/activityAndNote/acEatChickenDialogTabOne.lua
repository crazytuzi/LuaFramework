acEatChickenDialogTabOne={

}

function acEatChickenDialogTabOne:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    nc.tv=nil
    nc.bgLayer=nil
    nc.layerNum=nil
    nc.cellHeight=145
    nc.isTodayFlag = acEatChickenVoApi:isToday()
    nc.choseAwardIdx = 1--抽奖 默认为 单抽
    nc.url= G_downloadUrl("active/".."acQmcjBg_1.jpg") or nil
    nc.top5PlayerNameTb = {}
    nc.top5PlayerNameBgTb = {}
    return nc;
end
function acEatChickenDialogTabOne:dispose( )
    self.cellHeight = nil
    self.layerNum = nil
    self.bgLayer = nil
    self.tv = nil
    self.choseAwardIdx = nil
    self.isAnimation = nil
    self.top5PlayerNameTb = nil
    self.top5PlayerNameBgTb = nil
end

function acEatChickenDialogTabOne:init(layerNum,parent)
    -- print(" tabOne is init~~~~~~~~")
    self.activeName=acEatChickenVoApi:getActiveName()
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self:initUp()
    self:initMiddle()
    self:initDown()
    -- self:initBtn()
    -- self:initCenter()
    -- self:initTableView()
    return self.bgLayer
end

function acEatChickenDialogTabOne:initUp( )
    local h = G_VisibleSizeHeight-190
    local h2 = h - 10
    local timeStr=acEatChickenVoApi:getTimer()
    local posxSubWidth = 0
    if G_getCurChoseLanguage() == "fr" then
        posxSubWidth = 40
    end
    local acLabel = GetTTFLabel(timeStr,25)
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
        for i=1,9 do
            table.insert(tabStr,getlocal("activity_qmcj_tip"..i))
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

    local topDesc = GetTTFLabelWrap(getlocal("activity_qmcj_titleDes"),24,CCSizeMake(G_VisibleSizeWidth*0.8,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    topDesc:setPosition(ccp(G_VisibleSizeWidth*0.1,G_VisibleSizeHeight - 250))
    topDesc:setAnchorPoint(ccp(0,0.5))
    self.bgLayer:addChild(topDesc)
end
function acEatChickenDialogTabOne:initMiddle( )
    local middleBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)--"greenBlackBg2.png",CCRect(10,10,12,12),function ()end)
    middleBg:setContentSize(CCSizeMake(616,150))
    middleBg:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight - 300))
    middleBg:setAnchorPoint(ccp(0.5,1))
    self.middleBg = middleBg
    self.bgLayer:addChild(middleBg)

    local function recordHandler()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)--serverwar_get_point        
        local function rewardRecordShow()
            local lotteryLog,logNum = acEatChickenVoApi:getLotteryLog()
            if lotteryLog and logNum > 0 then
                local logList={}
                for k,v in pairs(lotteryLog) do
                    local num,reward,time,scores=v.num,v.reward,v.time,v.scores
                    local title = {getlocal("activity_qmcj_RewardStr2",{num,SizeOfTable(reward),scores})}
                    -- local title={getlocal("buyAndScoreRecord",{num,scores})}
                    local content={{reward}}
                    local log={title=title,content=content,ts=time}
                    table.insert(logList,log)
                end
                local logNum=SizeOfTable(logList)
                require "luascript/script/game/scene/gamedialog/activityAndNote/acCjyxSmallDialog"
                acCjyxSmallDialog:showLogDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-300),CCRect(130, 50, 1, 1),{getlocal("activity_customLottery_RewardRecode"),G_ColorWhite},logList,false,self.layerNum+1,nil,true,10,true,true,"qmcj")
            end
            if logNum == 0 then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_tccx_no_record"),30)
                do return end
            end
        end
        acEatChickenVoApi:rewardRecord(rewardRecordShow)
    end
    local recordBtn=GetButtonItem("bless_record.png","bless_record.png","bless_record.png",recordHandler,11)
    recordBtn:setScale(0.9)
    recordBtn:setAnchorPoint(ccp(0.5,0.5))
    local menu=CCMenu:createWithItem(recordBtn)
    menu:setTouchPriority(-(self.layerNum-1)*20-4)
    menu:setPosition(ccp(middleBg:getContentSize().width-40,55))
    middleBg:addChild(menu)



    self.rewardShowTb,self.rewardNums = acEatChickenVoApi:getRewardToShow( )

    if SizeOfTable( self.rewardShowTb ) > 4 then

        local function callBack(...)
            return self:eventHandlerM(...)
        end
        local hd= LuaEventHandler:createHandler(callBack)
        self.tvM=LuaCCTableView:createHorizontalWithEventHandler(hd,CCSizeMake(525,110),nil)
        self.tvM:setAnchorPoint(ccp(0,0))
        self.tvM:setPosition(ccp(5,5))
        self.tvM:setTableViewTouchPriority(-(self.layerNum-1)*20-6)
        self.tvM:setMaxDisToBottomOrTop(0)
        middleBg:addChild(self.tvM,1)
    else
        local needWidth = {-10,10}
        local anChorTb = {1,0}
        for idx=1,SizeOfTable(self.rewardShowTb) do
            local singleReward = self.rewardShowTb[idx]
            local function showNewPropInfo()
                G_showNewPropInfo(self.layerNum+1,true,true,nil,singleReward)
                return false
            end
            local sp,scale=G_getItemIcon(singleReward,100,true,self.layerNum,showNewPropInfo)
            sp:setAnchorPoint(ccp(anChorTb[idx],0.5))
            sp:setPosition(ccp(middleBg:getContentSize().width*0.5 +needWidth[idx] ,50))
            sp:setTouchPriority(-(self.layerNum-1)*20-2)
            middleBg:addChild(sp)
            sp:setScale(0.8)
            if singleReward and singleReward.type=="h" and singleReward.eType=="h" then
            else
                local lb=GetTTFLabel("x"..FormatNumber(singleReward.num),25)
                lb:setAnchorPoint(ccp(1,0))
                lb:setPosition(ccp(sp:getContentSize().width-5,5))
                sp:addChild(lb)
                lb:setScale(1/scale)
            end
            if idx  == 1 then
                G_addRectFlicker2(sp,1.1,1.1,3,"y",nil,55)
            else
                G_addRectFlicker2(sp,1.1,1.1,1,"b",nil,55)
            end
        end

    end
    local strSize2 = 28
    local strWidth = GetTTFLabel(getlocal("activity_mineExploreG_rewardShow"),strSize2):getContentSize().width
    if strWidth > 200 then
        strWidth = 200
    end
    local middleBgPosx = middleBg:getContentSize().width*0.5
    local usePosy = middleBg:getContentSize().height - 30
    local bigAwardStr=GetTTFLabelWrap(getlocal("activity_mineExploreG_rewardShow"),28,CCSize(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    bigAwardStr:setPosition(ccp(middleBgPosx,usePosy))
    self.bigAwardStr=bigAwardStr
    middleBg:addChild(bigAwardStr,99)

    local pointLineAncP = {ccp(1,0.5),ccp(0,0.5)}
    local pointLinePosXxxNeed = {middleBgPosx - strWidth*0.5 - 30,middleBgPosx + strWidth*0.5 + 30}
    for i=1,2 do
        local pointLine = CCSprite:createWithSpriteFrameName("greenPointAndLine.png")
        pointLine:setAnchorPoint(pointLineAncP[i])
        pointLine:setPosition(ccp(pointLinePosXxxNeed[i],usePosy))
        middleBg:addChild(pointLine)
        if i ==1 then
          pointLine:setFlipX(true)
        end
    end

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
    local bgSp1=CCSprite:createWithSpriteFrameName("semicircleGreen.png")---
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    bgSp1:setPosition(ccp(middleBg:getContentSize().width*0.5,100));
    bgSp1:setAnchorPoint(ccp(0.5,0))
    bgSp1:setScaleX(560/bgSp1:getContentSize().width)
    bgSp1:setScaleY(50/bgSp1:getContentSize().height)
    middleBg:addChild(bgSp1)

end

function acEatChickenDialogTabOne:eventHandlerM(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return self.rewardNums
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(105,105)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local singleReward = self.rewardShowTb[idx+1]
        local function showNewPropInfo()
            G_showNewPropInfo(self.layerNum+1,true,true,nil,singleReward)
            return false
        end
        local sp,scale=G_getItemIcon(singleReward,100,true,self.layerNum,showNewPropInfo)
        sp:setAnchorPoint(ccp(0,0))
        sp:setPosition(ccp(5,5))
        sp:setTouchPriority(-(self.layerNum-1)*20-2)
        cell:addChild(sp)
        sp:setScale(0.8)
        if singleReward and singleReward.type=="h" and singleReward.eType=="h" then
        else
            local lb=GetTTFLabel("x"..FormatNumber(singleReward.num),25)
            lb:setAnchorPoint(ccp(1,0))
            lb:setPosition(ccp(sp:getContentSize().width-5,5))
            sp:addChild(lb)
            lb:setScale(1/scale)
        end

        return cell
    end
end

function acEatChickenDialogTabOne:initDown( )
    local addHeight = 20
    local downBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)--"greenBlackBg2.png",CCRect(10,10,12,12),function ()end)
    downBg:setContentSize(CCSizeMake(616,self.middleBg:getPositionY() - self.middleBg:getContentSize().height - addHeight))
    downBg:setPosition(ccp(G_VisibleSizeWidth*0.5,addHeight))
    downBg:setAnchorPoint(ccp(0.5,0))
    self.downBg = downBg
    self.bgLayer:addChild(downBg)

    self.downCellWidth,self.downCellHeight = 612,self.middleBg:getPositionY() - self.middleBg:getContentSize().height - addHeight-4
    local function callBack(...)
        return self:eventHandlerD(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tvD=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.downCellWidth,self.downCellHeight),nil)
    self.tvD:setAnchorPoint(ccp(0,0))
    self.tvD:setPosition(ccp(2,2))
    self.tvD:setTableViewTouchPriority(-(self.layerNum-1)*20-6)
    self.tvD:setMaxDisToBottomOrTop(0)
    downBg:addChild(self.tvD,1)
end

function acEatChickenDialogTabOne:eventHandlerD(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.downCellWidth,self.downCellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local function onLoadIcon(fn,icon)
            icon:setAnchorPoint(ccp(0,0))
            icon:setScaleY(self.downCellHeight/icon:getContentSize().height)
            icon:setScaleX(self.downCellWidth/icon:getContentSize().width)
            cell:addChild(icon)
            icon:setPosition(ccp(0,0))
        end
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        local webImage=LuaCCWebImage:createWithURL(self.url,onLoadIcon)
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        
        local bufDialog = LuaCCScale9Sprite:createWithSpriteFrameName("fleet_slot_mini_bg.png",CCRect(70, 43, 1, 1),function ( )end)
        bufDialog:setAnchorPoint(ccp(0,0.5))
        bufDialog:setContentSize(CCSizeMake(250,230))
        bufDialog:setPosition(ccp(0,self.downCellHeight*0.7))
        self.bufDialog = bufDialog
        cell:addChild(bufDialog,10)


        self:initBtn(cell)--acEatChickenVoApi:setEatingChoseNums(curEatingNums)
        self.movPoint = 1
        local movWidht,movTo = self.bufDialog:getContentSize().width,nil
        local function bufDialogMovCall( )
            -- print("self.movPoint====>>>>>",self.movPoint)
            if self.bufDialog then
                if G_checkClickEnable()==false then
                    do return end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)--serverwar_get_point       
                if self.movPoint == 1 then
                    movTo = CCMoveTo:create(0.1,ccp(-movWidht+6,self.downCellHeight*0.7))
                    self.movPoint = 2
                    self.flagSp4:setVisible(true)
                    self.flagSp5:setVisible(false)
                else
                    movTo = CCMoveTo:create(0.1,ccp(0,self.downCellHeight*0.7))
                    self.movPoint = 1
                    self.flagSp4:setVisible(false)
                    self.flagSp5:setVisible(true)
                end
                -- self.flagSp4:setRotation(180)
                self.bufDialog:runAction(movTo)
            end
        end 
        local bufMovBtn=GetButtonItem("fleet_slot_left_btn.png","fleet_slot_left_btn_down.png","fleet_slot_left_btn.png",bufDialogMovCall,11)

        local flagSp4 = CCSprite:createWithSpriteFrameName("fleet_slot_left_flag.png")
        flagSp4:setPosition(ccp(bufMovBtn:getContentSize().width*0.5,bufMovBtn:getContentSize().height*0.5))
        flagSp4:setRotation(180)
        flagSp4:setScale(0.85)
        self.flagSp4 = flagSp4
        bufMovBtn:addChild(flagSp4,1)
        flagSp4:setVisible(false)

        local flagSp5 = CCSprite:createWithSpriteFrameName("fleet_slot_left_flag.png")
        flagSp5:setPosition(ccp(bufMovBtn:getContentSize().width*0.5,bufMovBtn:getContentSize().height*0.5))
        -- flagSp5:setRotation(180)
        flagSp5:setScale(0.85)
        self.flagSp5 = flagSp5
        bufMovBtn:addChild(flagSp5,1)


        bufMovBtn:setAnchorPoint(ccp(0,1))
        local menu=CCMenu:createWithItem(bufMovBtn)
        menu:setTouchPriority(-(self.layerNum-1)*20-2)
        menu:setPosition(ccp(bufDialog:getContentSize().width-5,bufDialog:getContentSize().height*0.83))
        bufDialog:addChild(menu)

        self:initTankShow(cell)
        self:initBufDataInDialog(bufDialog)
        return cell
    end
end
function acEatChickenDialogTabOne:initBufDataInDialog(bufDia)--"Helvetica-bold"
    middlePosx = bufDia:getContentSize().width*0.5

    local bufTitle = GetTTFLabelWrap(getlocal("activity_qmcj_bufTitle"),28,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    bufTitle:setPosition(ccp(middlePosx-5,bufDia:getContentSize().height*0.8))
    bufDia:addChild(bufTitle)

    local function bufShowCall()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        require "luascript/script/game/scene/gamedialog/activityAndNote/acThrivingSmallDialog"
        local needTb = {"qmcj",getlocal("activity_qmcj_bufTitle")}
        local awardDia = acThrivingSmallDialog:new(self.layerNum+1,needTb)
        awardDia:init()
    end
    local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",bufShowCall,1,nil,0)
    menuItemDesc:setAnchorPoint(ccp(0,1))
    menuItemDesc:setScale(0.7)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-2)
    menuDesc:setPosition(ccp(15,bufDia:getContentSize().height - 30))
    bufDia:addChild(menuDesc,2)

    local desBg = CCSprite:createWithSpriteFrameName("fleet_slot_cell_bg.png")
    desBg:setAnchorPoint(ccp(0.5,1))
    desBg:setPosition(ccp(middlePosx-3,bufDia:getContentSize().height*0.68))
    desBg:setScaleX(230/desBg:getContentSize().width)
    desBg:setScaleY(bufDia:getContentSize().height*0.6/desBg:getContentSize().height)
    bufDia:addChild(desBg)

    self.bufdes={"activity_qmcj_bufTab1","activity_qmcj_bufTab2","activity_qmcj_bufTab3"}
    self.needBufData={acEatChickenVoApi:getSixKillProbability()*100,acEatChickenVoApi:getBigAwardProbability()*100,acEatChickenVoApi:getawardLowerLimitRobability()}
    local sclaTb = {0.6,0.4,0.2}
    self.bufStrTb={}
    local strSize3 = 16
    if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
        strSize3 = 20
    end
    for i=1,3 do
        local bufStr = GetTTFLabelWrap(getlocal(self.bufdes[i],{self.needBufData[i]}),strSize3,CCSizeMake(240,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        bufStr:setPosition(ccp(middlePosx - 5,bufDia:getContentSize().height*sclaTb[i])) --- (i-1)*35))
        bufDia:addChild(bufStr)
        bufStr:setColor(G_ColorGreen)
        self.bufStrTb[i] = bufStr
    end

end


function acEatChickenDialogTabOne:initBtn(cell)

    local function choseEatingIdxCall(object,name,tag)
        for i=1,2 do
            if  self.choseBtnTb[i] then
                if tag == i then
                    self.choseBtnTb[i]:setVisible(true)
                    local choseIdx = i ==1 and 1 or 5
                    acEatChickenVoApi:setEatingChoseNums(choseIdx)
                else
                    self.choseBtnTb[i]:setVisible(false)
                end    
            end
        end
    end 

    self.choseBtnTb = {}
    self.btnNameBgTb = {}
    local strSize4 = 18
    if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" then
        strSize4 = 24
    end
    local curUseWidth = 180
    for i=1,2 do
        local btnBg = CCSprite:createWithSpriteFrameName("gCheckBg.png")
        local idxStr = i ==1 and 1 or 5
        local posyy = i ==1 and 0.52 or 0.38
        local eatingChickenStr = GetTTFLabelWrap(getlocal("activity_qmcj_eatingChickenIdx",{idxStr}),strSize4,CCSizeMake(curUseWidth - btnBg:getContentSize().width - 10 -15,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        local btnNameBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),choseEatingIdxCall)
        btnNameBg:setContentSize(CCSizeMake(curUseWidth,40))
        btnNameBg:setTouchPriority(-(self.layerNum-1)*20-3)
        btnNameBg:setOpacity(150)
        btnNameBg:setTag(i)
        btnNameBg:setAnchorPoint(ccp(0,0.5))
        if eatingChickenStr:getContentSize().height > btnNameBg:getContentSize().height then
            btnNameBg:setContentSize(CCSizeMake(curUseWidth ,eatingChickenStr:getContentSize().height + 4))
        end
        btnBg:setAnchorPoint(ccp(0,0.5))
        btnBg:setPosition(ccp(10,btnNameBg:getContentSize().height*0.5))
        btnNameBg:addChild(btnBg)

        eatingChickenStr:setAnchorPoint(ccp(0,0.5))
        eatingChickenStr:setPosition(ccp(10 + btnBg:getContentSize().width +15,btnNameBg:getContentSize().height*0.5))
        btnNameBg:addChild(eatingChickenStr)

        btnNameBg:setPosition(ccp(self.downCellWidth - btnNameBg:getContentSize().width,self.downCellHeight*posyy))
        cell:addChild(btnNameBg,1)
        self.btnNameBgTb[i] = btnNameBg

        local btnChose = CCSprite:createWithSpriteFrameName("gChecked.png")
        btnChose:setPosition(getCenterPoint(btnBg))
        btnBg:addChild(btnChose)
        self.choseBtnTb[i] = btnChose

        if i == 1 then
            acEatChickenVoApi:setEatingChoseNums(1)
            self.choseBtnTb[i]:setVisible(true)
        else
            self.choseBtnTb[i]:setVisible(false)
        end

        if self.isTodayFlag ==false or acEatChickenVoApi:getFirstFree() == 0 then
            self.btnNameBgTb[i]:setVisible(false)
        end

        local goldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
        goldIcon:setAnchorPoint(ccp(0,0))
        goldIcon:setPosition(ccp(btnNameBg:getContentSize().width*0.48,btnNameBg:getContentSize().height*0.5 + 18))
        btnNameBg:addChild(goldIcon)

        local goldNum = GetTTFLabel(acEatChickenVoApi:getCost(i),24)
        goldNum:setAnchorPoint(ccp(0,0))
        goldNum:setPosition(ccp(btnNameBg:getContentSize().width*0.25,btnNameBg:getContentSize().height*0.5 + 18))
        btnNameBg:addChild(goldNum)
    end

    local function rewardCallBack()
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            local choseEatNums = acEatChickenVoApi:getEatingChoseNums()
            local needCost = (acEatChickenVoApi:isToday() and acEatChickenVoApi:getFirstFree() ~=0) and acEatChickenVoApi:getCost(choseEatNums) or 0

            if playerVoApi:getGems()<needCost then
                GemsNotEnoughDialog(nil,nil,needCost-playerVoApi:getGems(),self.layerNum+1,needCost)
                do return end
            end

            local function realLottery( )
                local function refreshFunc(rewardTb)
                    if needCost and tonumber(needCost)>0 then
                        playerVoApi:setValue("gems",playerVoApi:getGems()-tonumber(needCost))
                    end
                    if acEatChickenVoApi:isToday() then
                        self.freeItem:setVisible(false)
                        self.freeItem:setEnabled(false)
                        self.rMenuItem:setVisible(true)
                        self.rMenuItem:setEnabled(true)

                        for i=1,2 do
                            if self.btnNameBgTb[i] then
                                self.btnNameBgTb[i]:setVisible(true)
                            end
                        end
                    else
                        self.rMenuItem:setVisible(false)
                        self.rMenuItem:setEnabled(false)
                        self.freeItem:setVisible(true)
                        self.freeItem:setEnabled(true)
                        for i=1,2 do
                            if self.btnNameBgTb[i] then
                                self.btnNameBgTb[i]:setVisible(false)
                            end
                        end
                    end

                    local showTb,showIconTb = {},{}
                    for m,n in pairs(rewardTb) do
                        local rewardItem=FormatItem(n,nil,true)
                        table.insert(showTb,rewardItem[1])
                        for k,v in pairs(rewardItem) do
                            G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                        end
                    end                
                    local function showReward()
                        -- print("in showReward~~~~~~~")
                        
                        -- G_showRewardTip(showTb)
                        local newS,oldS = acEatChickenVoApi:getNewAndOldScores( )
                        -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("curGetScores",{newS-oldS}),30)
                        --curGetScores
                        local addStrTb = nil
                        local titleStr=getlocal("activity_wheelFortune4_reward")--activity_qmcj_RewardStr
                        local titleStr2=getlocal("activity_qmcj_RewardStr",{choseEatNums,SizeOfTable(showTb),newS-oldS})
                        local choseEatNums = acEatChickenVoApi:getEatingChoseNums()
                        require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
                        rewardShowSmallDialog:showNewReward(self.layerNum+1,true,true,showTb,function () end,titleStr,titleStr2,addStrTb,nil,"qmcj")
                    end 
                    if self.isAnimation  then
                        showReward()
                    else
                        acEatChickenBattleScene:initData({},showReward,nil,self.layerNum,showTb)
                    end
                end
                local action = 1
                local choseEatNums = acEatChickenVoApi:getEatingChoseNums()
                self.choseAwardIdx =  acEatChickenVoApi:isToday() and nil or choseEatNums
                local freeNeed = acEatChickenVoApi:getFirstFree() == 0  and 0 or nil
                acEatChickenVoApi:rewwardSock(refreshFunc,action,self.choseAwardIdx,freeNeed)
            end


            local function sureClick()
            -- print("cost---sureClick-->",needCost)
                realLottery()
            end
            local function secondTipFunc(sbFlag)
                local keyName=acEatChickenVoApi:getActiveName()
                local sValue=base.serverTime .. "_" .. sbFlag
                G_changePopFlag(keyName,sValue)
            end
            if needCost and needCost>0 then
                local keyName=acEatChickenVoApi:getActiveName()
                if G_isPopBoard(keyName) then
                    self.secondDialog=G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{needCost}),true,sureClick,secondTipFunc)
                else
                    sureClick()
                end
            else
                sureClick()
            end

    end
    -- "BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png"
    local btnStr = getlocal("daily_lotto_tip_2")
    local freeItem=GetButtonItem("qmcjNbtn_1.png","qmcjNbtn_2.png","qmcjNbtn_2.png",rewardCallBack,nil,btnStr,35,99)
    freeItem:setScale(0.7)
    local freeStr = freeItem:getChildByTag(99)
    freeStr:setPosition(ccp(freeStr:getPositionX() + 280,freeStr:getPositionY()-5))
    freeStr:setColor(G_ColorGreen)
    self.freeItem = freeItem
    local freeBtn=CCMenu:createWithItem(freeItem);
    freeBtn:setTouchPriority(-(self.layerNum-1)*20-2);
    freeBtn:setPosition(ccp(self.downCellWidth*0.5,self.downCellHeight*0.5+10))
    cell:addChild(freeBtn,1)

    local rMenuItem=GetButtonItem("qmcjNbtn_1.png","qmcjNbtn_2.png","qmcjNbtn_2.png",rewardCallBack,nil,nil,35,98)
    rMenuItem:setScale(0.7)
    self.rMenuItem = rMenuItem
    local rewardBtn=CCMenu:createWithItem(rMenuItem);
    rewardBtn:setTouchPriority(-(self.layerNum-1)*20-2);
    rewardBtn:setPosition(ccp(self.downCellWidth*0.5,self.downCellHeight*0.5+10))
    cell:addChild(rewardBtn,1)

    G_addFlicker(cell,2.3,2.3,ccp(self.downCellWidth*0.5,self.downCellHeight*0.5+10))
    if self.isTodayFlag and acEatChickenVoApi:getFirstFree() ~= 0 then
        freeItem:setVisible(false)
        freeItem:setEnabled(false)
    else
        rMenuItem:setVisible(false)
        rMenuItem:setEnabled(false)
    end

    local tipBg = CCSprite:createWithSpriteFrameName("allianceHeaderBg.png") --LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),function () end)
    tipBg:setAnchorPoint(ccp(0.5,1))
    tipBg:setOpacity(150)
    tipBg:setPosition(ccp(self.downCellWidth*0.5,freeBtn:getPositionY() - freeItem:getContentSize().height*0.7*0.5 + 4))
    cell:addChild(tipBg,1)

    rewardTipStr = GetTTFLabel(getlocal("SkipAnimation"),23)
    tipBg:setScaleX((rewardTipStr:getContentSize().width + 8)/tipBg:getContentSize().width)
    tipBg:setScaleY((rewardTipStr:getContentSize().height +8)/tipBg:getContentSize().height)
    cell:addChild(rewardTipStr,1)
    rewardTipStr:setPosition(ccp(self.downCellWidth*0.5,tipBg:getPositionY() - tipBg:getContentSize().height*0.5 + 2))
    
    local function onClickCheckBox( )
        if self.checkBoxFrameChecked then
            if self.isAnimation then
                self.isAnimation = false
                self.checkBoxFrameChecked:setVisible(false)
            else
                self.isAnimation = true
                self.checkBoxFrameChecked:setVisible(true)
            end
        end
    end 
    local checkBoxFrameUnchecked=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",onClickCheckBox)
    checkBoxFrameUnchecked:setTouchPriority(-(self.layerNum-1)*20-4)
    checkBoxFrameUnchecked:setScale(0.7)
    checkBoxFrameUnchecked:setAnchorPoint(ccp(1,0.5))
    checkBoxFrameUnchecked:setPosition(ccp(tipBg:getPositionX() - tipBg:getContentSize().width*0.5 + 12,tipBg:getPositionY() - tipBg:getContentSize().height*0.5))
    cell:addChild(checkBoxFrameUnchecked,99)
    self.checkBoxFrameChecked=CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
    -- checkBoxFrameChecked:setScale(1.2)
    self.checkBoxFrameChecked:setPosition(getCenterPoint(checkBoxFrameUnchecked))
    checkBoxFrameUnchecked:addChild(self.checkBoxFrameChecked)
    self.checkBoxFrameChecked:setVisible(false)
    self.isAnimation = false
end

function acEatChickenDialogTabOne:initTankShow(cell )
    local tankId2 = {10008,10038,10008,10018,10028,10018}
    local subPosY,addPosX =  G_isIphone5() and 20 or -20, -20
    local addPosX2 = G_isIphone5() and -20 or 0
    local tank2Pos = {ccp(90.5 + addPosX, 169.5 + subPosY),ccp(241.5 + addPosX, 169.5 + subPosY),ccp(391.5 + addPosX, 169.5 + subPosY),ccp(168.5 + addPosX + addPosX2, 78.5 + subPosY),ccp(319.5 + addPosX + addPosX2, 78.5 + subPosY),ccp(469.5 + addPosX + addPosX2, 78.5 + subPosY)}
    local npcPosTb2 = {ccp(87.5 + addPosX, 121.5 + subPosY),ccp(242.5 + addPosX, 121.5 + subPosY),ccp(383 + addPosX, 121 + subPosY),ccp(162.5 + addPosX + addPosX2, 33.5 + subPosY),ccp(317.5 + addPosX + addPosX2, 33.5 + subPosY),ccp(458 + addPosX + addPosX2, 33.5 + subPosY)}
    local bfCount = {[10008]=5,  [10018]=5,  [10028]=5,  [10038]=0}
    local nodata,playerNameTb = acEatChickenVoApi:getAllianceRankList( )
    for k,v in pairs(tankId2) do
        spriteController:addPlist("ship/newTank/t"..v.."newTank.plist")
        spriteController:addTexture("ship/newTank/t"..v.."newTank.png")

        local container=CCNode:create()
        local tankFrameName="t"..v.."_2"..".png"
        local tankSp = CCSprite:createWithSpriteFrameName(tankFrameName)
        container:setPosition(tank2Pos[k])
        cell:addChild(container,1)
        container:setScale(0.65)
        container:addChild(tankSp,5) --坦克本身

        if bfCount[v] > 0 then
            local tankBarrel="t"..v.."_2".."_1.png"  --炮管 第6层
            local tankBarrelSP=CCSprite:createWithSpriteFrameName(tankBarrel)
            container:addChild(tankBarrelSP,6) --炮管
        end
        local npcName = ""
        if playerNameTb and playerNameTb[k] and allianceVoApi:isHasAlliance() then
            npcName = GetTTFLabel(playerNameTb[k].name,22)
        else
            if k == 2 then
                npcName = GetTTFLabel(getlocal("you"),22)--playerVoApi:getPlayerName(),22)
            else
                npcName = GetTTFLabel("",22)--playerVoApi:getPlayerName(),22)
            end
        end
        npcName:setPosition(npcPosTb2[k])
        cell:addChild(npcName,2)
        self.top5PlayerNameTb[k] = npcName

        if npcName then
            local nameBg = CCSprite:createWithSpriteFrameName("allianceHeaderBg.png")
            local curUseWidth,curUseHeight = npcName:getContentSize().width +6,npcName:getContentSize().height + 4
            nameBg:setScaleX(curUseWidth/nameBg:getContentSize().width)
            nameBg:setScaleY(curUseHeight/nameBg:getContentSize().height)
            nameBg:setOpacity(150)
            cell:addChild(nameBg,1)
            nameBg:setPosition(npcPosTb2[k])
            self.top5PlayerNameBgTb[k] = nameBg
            if npcName:getString() =="" then
                nameBg:setVisible(false)
            end
        end
        if k == 2 and npcName then
            npcName:setColor(G_ColorGreen)
        end
    end

    -------
    local tankId1 = {10074,20055,10075,10084,20155,20125}
    local subPosY2,subPosX2 = G_isIphone5() and 100 or -20,40
    local npcPosTb = {ccp(171.5 - subPosX2, 493.5 + subPosY2),ccp(326.5 - subPosX2, 493.5 + subPosY2),ccp(467 - subPosX2, 493 + subPosY2),ccp(246.5 - subPosX2, 412.5 + subPosY2),ccp(418.5 - subPosX2, 412.5 + subPosY2),ccp(563 - subPosX2, 412.5 + subPosY2)}
    
    local tank1Pos = {ccp(255 - subPosX2, 362.5 + subPosY2),ccp(405 - subPosX2, 362.5 + subPosY2),ccp(555 - subPosX2, 362.5 + subPosY2),ccp(176 - subPosX2, 449.5 + subPosY2),ccp(326 - subPosX2, 449.5 + subPosY2),ccp(476 - subPosX2, 449.5 + subPosY2)}
    local bfCount = {[10074]=5,  [20055]=5,  [10075]=5,  [10084]=0, [20155]=0, [20125]=4}
    for k,v in pairs(tankId1) do
        spriteController:addPlist("ship/newTank/t"..v.."newTank.plist")
        spriteController:addTexture("ship/newTank/t"..v.."newTank.png")

        local container=CCNode:create()
        local tankFrameName="t"..v.."_1"..".png"
        local tankSp = CCSprite:createWithSpriteFrameName(tankFrameName)
        container:setPosition(tank1Pos[k])
        cell:addChild(container,1)
        container:setScale(0.6)
        container:addChild(tankSp,5) --坦克本身

        if bfCount[v] > 0 then
            local tankBarrel="t"..v.."_1".."_1.png"  --炮管 第6层
            local tankBarrelSP=CCSprite:createWithSpriteFrameName(tankBarrel)
            container:addChild(tankBarrelSP,6) --炮管
        end

        local npcName = GetTTFLabel(getlocal("activity_qmcj_npc"..k),22)
        npcName:setPosition(npcPosTb[k])
        cell:addChild(npcName,2)

        if npcName then
            local nameBg = CCSprite:createWithSpriteFrameName("allianceHeaderBg.png")
            local curUseWidth,curUseHeight = npcName:getContentSize().width +6,npcName:getContentSize().height + 4
            nameBg:setScaleX(curUseWidth/nameBg:getContentSize().width)
            nameBg:setScaleY(curUseHeight/nameBg:getContentSize().height)
            nameBg:setOpacity(150)
            cell:addChild(nameBg,1)
            nameBg:setPosition(npcPosTb[k])
        end
    end
end

function acEatChickenDialogTabOne:refreshTop5PlayerName( )
    local nodata,playerNameTb = acEatChickenVoApi:getAllianceRankList( )
    if playerNameTb and SizeOfTable(playerNameTb) > 0 then
        for i=1,6 do
            if self.top5PlayerNameTb and self.top5PlayerNameTb[i] and playerNameTb[i] and playerNameTb[i].name then
                self.top5PlayerNameTb[i]:setString(playerNameTb[i].name)
                self.top5PlayerNameBgTb[i]:setVisible(true)
            end
        end
    end
end
function acEatChickenDialogTabOne:tick( )
    local isEnd=activityVoApi:isStart(acVo)
    if isEnd==false then
        local todayFlag=acEatChickenVoApi:isToday()
        if self.isTodayFlag==true and todayFlag==false and acEatChickenVoApi:getFirstFree() ~= 0 then
            self.isTodayFlag=false
            acEatChickenVoApi:setFirstFree(0)
            --重置免费次数
            if self.rMenuItem and self.freeItem then
                self.rMenuItem:setVisible(false)
                self.rMenuItem:setEnabled(false)
                self.freeItem:setVisible(true)
                self.freeItem:setEnabled(true)
                for i=1,2 do
                    if self.btnNameBgTb[i] then
                        self.btnNameBgTb[i]:setVisible(false)
                    end
                end
            end
        end
        if self and self.timeLb then
          self.timeLb:setString(acEatChickenVoApi:getTimer( ))
        end

        if acEatChickenVoApi:getUpDataState1() then
            acEatChickenVoApi:setUpDataState1(false)
            if self.bufdes and self.needBufData then
                for i=1,3 do
                    if self.bufStrTb[i] then
                        self.bufStrTb[i]:setString(getlocal(self.bufdes[i],{self.needBufData[i]}))
                    end
                end
            end
        end
    end
end