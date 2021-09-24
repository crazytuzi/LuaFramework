acMjzxDialog=commonDialog:new()

function acMjzxDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum=layerNum

    self.tab1 = nil
    self.tab2 = nil
    self.layerTab1=nil
    self.layerTab2=nil

    self.baseAcSp = nil
    self.actionBgTb2 = {}
    self.awardBgTb = {}
    local function addPlist()
        print("here????????addPlist~~~~~~~~~~~")
        spriteController:addPlist("public/acMjzxImage.plist")--acMjzx2Image
        spriteController:addTexture("public/acMjzxImage.png")
        spriteController:addPlist("public/acMjzx2Image.plist")--acMjzx2Image
        spriteController:addTexture("public/acMjzx2Image.png")
        spriteController:addPlist("public/taskYouhua.plist")
        spriteController:addTexture("public/taskYouhua.png")
        -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/platWar/platWarImage.plist")

    end
    G_addResource8888(addPlist)
    -- spriteController:addPlist("public/acDouble11New_addImage.plist")
    -- spriteController:addTexture("public/acDouble11New_addImage.png")
    return nc
end

function acMjzxDialog:resetTab()
    
    self.panelLineBg:setVisible(false)
    G_addCommonGradient(self.bgLayer,G_VisibleSizeHeight - 158)

    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v
         if index==0 then
          tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==1 then
          tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end 

         index=index+1
    end
    self:tabClick(0)
end
--设置对话框里的tableView
function acMjzxDialog:initTableView()
end

function acMjzxDialog:stopAwardAction( )

    for i=1,3 do
        if not self.actionBgTb2[i] then
            local actionBlackBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(5, 5, 1, 1),function () end)
            actionBlackBg:setOpacity(i == 3 and 0 or 255)
            actionBlackBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
            actionBlackBg:setPosition(getCenterPoint(self.bgLayer))
            self.bgLayer:addChild(actionBlackBg,90)    
            self.actionBgTb2[i] = actionBlackBg
        else
            if i ~= 3 then
                self.actionBgTb2[i]:stopAllActions()
            end
            self.actionBgTb2[i]:setOpacity(i < 3 and 255 or 0)
        end
    end
    if self.rewardList then
        local rewardNum = SizeOfTable(self.rewardList)

        if not self.rewardShowTb then self.rewardShowTb = {} end
        if not self.rewardShowTb[1] then
            print("self.rewardList[1].name...self.rewardList[1].num===>>>",self.rewardList[1].name.."x"..self.rewardList[1].num)
            local hexieLb = GetTTFLabel(getlocal("equip_getReward",self.rewardList[1].name.."x"..self.rewardList[1].num),25,"Helvetica-bold")
            hexieLb:setAnchorPoint(ccp(0.5,1))
            hexieLb:setPosition(ccp(G_VisibleSizeWidth * 0.5,G_VisibleSizeHeight - 100))
            self.bgLayer:addChild(hexieLb,99)
            self.rewardShowTb[1] = hexieLb
        else
            self.rewardShowTb[1]:setVisible(true)
        end


        local xScale,iconSize = {0.21,0.5,0.79,0.3,0.7},100
        for i=2,rewardNum do
            if not self.rewardShowTb[i] then
                local hid = self.rewardList[i].name
                local function callback( )
                    G_showNewPropInfo(self.layerNum+1,true,nil,nil,self.rewardList[i],nil,nil,nil)
                end 
                local heroIcon,scale = G_getItemIcon(self.rewardList[i],iconSize,false,self.layerNum+1,callback,nil)
                heroIcon:setTouchPriority(-(self.layerNum-1)*20-6)
                heroIcon:setPosition(G_VisibleSizeWidth * xScale[i-1],G_VisibleSizeHeight * (i<5 and 0.65 or 0.38))
                heroIcon:setScale(scale/heroIcon:getContentSize().width)
                heroIcon:setVisible(true)
                self.bgLayer:addChild(heroIcon,99)
                self.rewardShowTb[i] = heroIcon
                local strSize7 = G_isAsia() and 23 or 20

                local heroNameStr = GetTTFLabelWrap(hid.."x"..self.rewardList[i].num,strSize7/scale,CCSizeMake(rewardNum == 2 and 450 or 280,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop,"Helvetica-bold")
                heroNameStr:setAnchorPoint(ccp(0.5,1))
                heroNameStr:setPosition(ccp(heroIcon:getContentSize().width * 0.5 * scale,-15))
                heroIcon:addChild(heroNameStr,99)

                local addPoint = GetTTFLabel(getlocal("scoreAdd",{ptTb[i-1] or 0}),strSize7/scale)
                addPoint:setPosition(ccp(heroNameStr:getContentSize().width * 0.5, -5))
                addPoint:setAnchorPoint(ccp(0.5,1))
                heroNameStr:addChild(addPoint)

                if self.rewardList[i].isIronCross then
                    local ironCrossTip = GetTTFLabel(getlocal("coverIronCross").."x"..self.rewardList[i].num,strSize7/scale-8)
                    ironCrossTip:setPosition(ccp(addPoint:getContentSize().width * 0.5, -5))
                    ironCrossTip:setAnchorPoint(ccp(0.5,1))
                    addPoint:addChild(ironCrossTip)
                end
            else
                self.rewardShowTb[i]:stopAllActions()
                self.rewardShowTb[i]:setScale(100/self.rewardShowTb[i]:getContentSize().width)
                self.rewardShowTb[i]:setVisible(true)
            end
            if self.rewardShowBgTb[i] then
                self.rewardShowBgTb[i]:stopAllActions()
                self.rewardShowBgTb[i]:removeFromParentAndCleanup(true)
                self.rewardShowBgTb[i] = nil
            end

            if self.awardBgTb[i * 2] == nil and self.rewardList[i].isNeedBigAwardBg then
                local xScale,iconSize = {0.21,0.5,0.79,0.3,0.7},100
                for j=1,2 do
                  local realLight = CCSprite:createWithSpriteFrameName("equipShine.png")
                  realLight:setAnchorPoint(ccp(0.5,0.5))
                  realLight:setScale(1.4)
                  realLight:setPosition(G_VisibleSizeWidth * xScale[i-1],G_VisibleSizeHeight * (i<5 and 0.65 or 0.38))
                  self.bgLayer:addChild(realLight,95)  
                  local roteSize = j ==1 and 360 or -360
                  local rotate1=CCRotateBy:create(4, roteSize)
                  local repeatForever = CCRepeatForever:create(rotate1)
                  realLight:runAction(repeatForever)
                  self.awardBgTb[i * 2+j-1] = realLight
                end
            end
        end
        if rewardNum == 2 then
            self.rewardShowTb[2]:setPosition(getCenterPoint(self.bgLayer))
            if self.awardBgTb and SizeOfTable(self.awardBgTb) == 2 then
                for k,v in pairs(self.awardBgTb) do
                    self.awardBgTb[k]:setPosition(getCenterPoint(self.bgLayer))
                end
            end
        end

    end

    if not self.actionCloseMenu then
        local function closeHandle( )
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            self:endActionLayer()
        end 

        local btnScale=0.8
        local closeBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",closeHandle,11,getlocal("fight_close"),24/btnScale)
        closeBtn:setScale(btnScale)
        closeBtn:setAnchorPoint(ccp(0.5,0))
        local menu=CCMenu:createWithItem(closeBtn)
        menu:setTouchPriority(-(self.layerNum-1)*20-55)
        menu:setPosition(ccp(G_VisibleSizeWidth * 0.5, 60))
        self.actionCloseMenu = menu
        self.bgLayer:addChild(menu,99) 
    else
        self.actionCloseMenu:stopAllActions()
        self.actionCloseMenu:setVisible(true)
    end

    if self.baseAcSp then 
        self.baseAcSp:stopAllActions()
        self.baseAcSp:removeFromParentAndCleanup(true)
        self.baseAcSp = nil
    end
    if self.vertclSp then 
        self.vertclSp:stopAllActions()
        self.vertclSp:removeFromParentAndCleanup(true)
        self.vertclSp = nil
    end
    if self.HorStreamer then
        self.HorStreamer:stopAllActions()
        self.HorStreamer:removeFromParentAndCleanup(true)
        self.HorStreamer = nil
    end
    if self.flashSp then
        self.flashSp:stopAllActions()
        self.flashSp:removeFromParentAndCleanup(true)
        self.flashSp = nil
    end
end
function acMjzxDialog:endActionLayer( )
    for k,v in pairs(self.awardBgTb) do
        if self.awardBgTb[k] then self.awardBgTb[k]:removeFromParentAndCleanup(true) end
    end
    self.awardBgTb = {}


    self.touchDia:setPosition(ccp(G_VisibleSizeWidth*2.5,G_VisibleSizeHeight * 0.5))
    if self.baseAcSp then 
        self.baseAcSp:removeFromParentAndCleanup(true)
        self.baseAcSp = nil
    end
    if self.vertclSp then 
        self.vertclSp:removeFromParentAndCleanup(true)
        self.vertclSp = nil
    end
    if self.HorStreamer then
        self.HorStreamer:removeFromParentAndCleanup(true)
        self.HorStreamer = nil
    end
    if self.flashSp then
        self.flashSp:removeFromParentAndCleanup(true)
        self.flashSp = nil
    end

    for i=1,3 do
        if self.actionBgTb2[i] then
            self.actionBgTb2[i]:removeFromParentAndCleanup(true)
        end
    end
    local rewardNum = SizeOfTable(self.rewardList)
    for i=1,rewardNum do
        if self.rewardShowTb[i] then
            self.rewardShowTb[i]:removeFromParentAndCleanup(true)
        end
        if self.rewardShowBgTb[i] then
            self.rewardShowBgTb[i]:removeFromParentAndCleanup(true)
        end
    end
    if self.actionCloseMenu then
        self.actionCloseMenu:removeFromParentAndCleanup(true)
    end
    self.actionBgTb2,self.rewardShowTb,self.rewardShowBgTb,self.actionCloseMenu = {},{},{},nil
    

    if self and self.tab1 and self.tab1.touchDialog then
        self.tab1.touchDialog:setPosition(ccp(G_VisibleSizeWidth*2.5,(G_VisibleSizeHeight-self.tDialogHeight)*0.5))
    end

    G_showRewardTip(self.rewardList,true)
    self.rewardList = {}
end

function acMjzxDialog:runAwardAction(rewardList,ptTb,point)
    self.rewardList = rewardList
    self.touchDia:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight * 0.5))
    local ipNow = G_getIphoneType()
    local hScale = 0.2
    if ipNow == G_iphone5 or ipNow == G_iphoneX then
        hScale = 0.25
    end
    
    local baseAcSp = CCSprite:createWithSpriteFrameName("baseAc_1.png")
    baseAcSp:setPosition(ccp(G_VisibleSizeWidth * 0.5,G_VisibleSizeHeight * hScale - 10))
    self.bgLayer:addChild(baseAcSp,99)
    baseAcSp:setVisible(false)
    self.baseAcSp = baseAcSp

    local HorStreamer = CCSprite:createWithSpriteFrameName("HorStreamer_1.png")
    HorStreamer:setPosition(ccp(G_VisibleSizeWidth * 0.5,G_VisibleSizeHeight *0.5))
    self.bgLayer:addChild(HorStreamer,99)
    HorStreamer:setVisible(false)
    self.HorStreamer = HorStreamer

    local vertclSp = CCSprite:createWithSpriteFrameName("vertcShine_1.png")
    vertclSp:setPosition(ccp(G_VisibleSizeWidth * 0.5,G_VisibleSizeHeight * hScale))
    vertclSp:setAnchorPoint(ccp(0.5,0))
    self.bgLayer:addChild(vertclSp,99)
    vertclSp:setVisible(false)
    self.vertclSp = vertclSp



    for i=1,3 do
        if not self.actionBgTb2[i] then
            local actionBlackBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(5, 5, 1, 1),function () end)
            actionBlackBg:setOpacity(0)
            actionBlackBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
            actionBlackBg:setPosition(getCenterPoint(self.bgLayer))
            self.bgLayer:addChild(actionBlackBg,90)    
            self.actionBgTb2[i] = actionBlackBg
        end
    end

    -- local blueBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(5, 5, 1, 1),function () end)
    -- blueBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight* 0.45))
    -- blueBg:setPosition(getCenterPoint(self.actionBgTb2[2]))
    -- self.actionBgTb2[2]:addChild(blueBg,90) 

    local flashSp = CCSprite:createWithSpriteFrameName("flashSun.png")
    flashSp:setPosition(getCenterPoint(self.bgLayer))
    flashSp:setScale(3)
    flashSp:setVisible(false)
    self.flashSp = flashSp
    self.bgLayer:addChild(flashSp,91)

    local rewardNum = SizeOfTable(rewardList)
    if not self.rewardShowTb then self.rewardShowTb = {} end
    if not self.rewardShowBgTb then self.rewardShowBgTb = {} end
    if not self.rewardShowTb[1] then
        local hexieLb = GetTTFLabel(getlocal("equip_getReward",{rewardList[1].name.."x"..rewardList[1].num}),25,"Helvetica-bold")
        hexieLb:setAnchorPoint(ccp(0.5,1))
        hexieLb:setPosition(ccp(G_VisibleSizeWidth * 0.5,G_VisibleSizeHeight - 100))
        self.bgLayer:addChild(hexieLb,99)
        hexieLb:setVisible(false)
        self.rewardShowTb[1] = hexieLb
    end

    local xScale,iconSize = {0.21,0.5,0.79,0.3,0.7},100
    for i=2,rewardNum do
        local hid = rewardList[i].name
        -- print("hid---->>>>",hid,i)
        local function callback( )
            G_showNewPropInfo(self.layerNum+1,true,nil,nil,self.rewardList[i],nil,nil,nil)
        end 
        local heroIcon,scale = G_getItemIcon(rewardList[i],iconSize,false,self.layerNum+1,callback,nil)
        heroIcon:setTouchPriority(-(self.layerNum-1)*20-6)
        heroIcon:setPosition(G_VisibleSizeWidth * xScale[i-1],G_VisibleSizeHeight * (i<5 and 0.65 or 0.38))
        heroIcon:setScale(scale/heroIcon:getContentSize().width)
        heroIcon:setVisible(false)
        self.bgLayer:addChild(heroIcon,99)
        self.rewardShowTb[i] = heroIcon
        
        local strSize7 = G_isAsia() and 23 or 20
        local heroNameStr = GetTTFLabelWrap(hid.."x"..rewardList[i].num,strSize7/scale,CCSizeMake(rewardNum == 2 and 450 or 280,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop,"Helvetica-bold")
        heroNameStr:setAnchorPoint(ccp(0.5,1))
        heroNameStr:setPosition(ccp(heroIcon:getContentSize().width * 0.5,-15/scale))
        heroIcon:addChild(heroNameStr,99)

        local addPoint = GetTTFLabel(getlocal("scoreAdd",{ptTb[i-1] or 0}),strSize7/scale)
        addPoint:setPosition(ccp(heroNameStr:getContentSize().width * 0.5, -5))
        addPoint:setAnchorPoint(ccp(0.5,1))
        heroNameStr:addChild(addPoint)

        if rewardList[i].isIronCross then
            local ironCrossTip = GetTTFLabel(getlocal("coverIronCross").."x"..self.rewardList[i].num,strSize7/scale-8)
            ironCrossTip:setPosition(ccp(addPoint:getContentSize().width * 0.5, -5))
            ironCrossTip:setAnchorPoint(ccp(0.5,1))
            addPoint:addChild(ironCrossTip)
        end
        if rewardNum == 2 then
            local horiSun = CCSprite:createWithSpriteFrameName("horiSun_1.png")
            horiSun:setPosition(getCenterPoint(self.bgLayer))
            self.bgLayer:addChild(horiSun,98)
            horiSun:setVisible(false)
            self.rewardShowBgTb[i] = horiSun
        else
            local sVertclSun = CCSprite:createWithSpriteFrameName("sVertclSun_1.png")
            sVertclSun:setPosition(heroIcon:getPositionX(),heroIcon:getPositionY())
            self.bgLayer:addChild(sVertclSun,99)
            sVertclSun:setVisible(false)
            self.rewardShowBgTb[i] = sVertclSun
        end
    end
    if rewardNum == 2 then
        self.rewardShowTb[2]:setPosition(getCenterPoint(self.bgLayer))
        if self.awardBgTb and SizeOfTable(self.awardBgTb) == 2 then
            for k,v in pairs(self.awardBgTb) do
                self.awardBgTb[k]:setPosition(getCenterPoint(self.bgLayer))
            end
        end
    end

    if not self.actionCloseMenu then
        local function closeHandle( )
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            self:endActionLayer()
        end 
        local btnScale=0.8
        local closeBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",closeHandle,11,getlocal("fight_close"),24/btnScale)
        closeBtn:setScale(btnScale)
        closeBtn:setAnchorPoint(ccp(0.5,0))
        local menu=CCMenu:createWithItem(closeBtn)
        menu:setTouchPriority(-(self.layerNum-1)*20-55)
        menu:setPosition(ccp(G_VisibleSizeWidth * 0.5, 60))
        self.actionCloseMenu = menu
        self.bgLayer:addChild(menu,99) 
        self.actionCloseMenu:setVisible(false)
    end

    

---跑起来~~~~~~~
    local t1,t2 = 0.1,0.6
    local function baseAcEnd()
        self.baseAcSp:removeFromParentAndCleanup(true)
        self.baseAcSp = nil
        -- baseAcSp:setVisible(false)
    end
    local baseAcCall=CCCallFuncN:create(baseAcEnd)
    local function baseAcShow( )
        baseAcSp:setVisible(true)
    end
    local baseAcShowCall=CCCallFuncN:create(baseAcShow)
    local baseAcArr = CCArray:create()
    for kk=1,12 do
        local nameStr="baseAc_"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        baseAcArr:addObject(frame)
     end
     local baseAnimation=CCAnimation:createWithSpriteFrames(baseAcArr)
     baseAnimation:setDelayPerUnit(0.08)
     local baseAc=CCAnimate:create(baseAnimation)

     local baseArr=CCArray:create()
     local delayT1 = CCDelayTime:create(t1)
     baseArr:addObject(delayT1)
     baseArr:addObject(baseAcShowCall)
     baseArr:addObject(baseAc)
     baseArr:addObject(baseAcCall)
     local baseAcSeq = CCSequence:create(baseArr)
     baseAcSp:runAction(baseAcSeq)
    
    local vertcAcArr = CCArray:create()
    for ii=1,6 do
        local nameStr="vertcShine_"..ii..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        -- frame:setAnchorPoint(ccp(0.5,0))
        vertcAcArr:addObject(frame)
    end
    local vertcAnimation=CCAnimation:createWithSpriteFrames(vertcAcArr)
    vertcAnimation:setDelayPerUnit(0.08)
    local vertcAc=CCAnimate:create(vertcAnimation)

    local function baseAcEnd2()
        if self.vertclSp then
            self.vertclSp:removeFromParentAndCleanup(true)
            self.vertclSp = nil
        end
    end
    local baseAcCall2=CCCallFuncN:create(baseAcEnd2)
    local function baseAcShow2( )
        vertclSp:setVisible(true)
    end
    local baseAcShowCall2=CCCallFuncN:create(baseAcShow2)
     local vertcArr=CCArray:create()
     local delayT1 = CCDelayTime:create(t2)
     vertcArr:addObject(delayT1)
     vertcArr:addObject(baseAcShowCall2)
     vertcArr:addObject(vertcAc)
     vertcArr:addObject(baseAcCall2)
     local seq2 = CCSequence:create(vertcArr)
     vertclSp:runAction(seq2)

    local HorStreamerAcArr = CCArray:create()
    for ii=1,8 do
        local nameStr="HorStreamer_"..ii..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        -- frame:setAnchorPoint(ccp(0.5,0))
        HorStreamerAcArr:addObject(frame)
    end
    local HorStreamerAcArrAnimation=CCAnimation:createWithSpriteFrames(HorStreamerAcArr)
    HorStreamerAcArrAnimation:setDelayPerUnit(0.08)
    local HorStreamerAc=CCAnimate:create(HorStreamerAcArrAnimation)

    local function baseAcEnd3()
        self.HorStreamer:removeFromParentAndCleanup(true)
        self.HorStreamer = nil
    end
    local baseAcCall3=CCCallFuncN:create(baseAcEnd3)
    local function baseAcShow3( )
        HorStreamer:setVisible(true)
    end
    local baseAcShowCall3=CCCallFuncN:create(baseAcShow3)
    local HorStreamerArr=CCArray:create()
    local delayT3 = CCDelayTime:create(t2+0.1)
    HorStreamerArr:addObject(delayT3)
    HorStreamerArr:addObject(baseAcShowCall3)
    HorStreamerArr:addObject(HorStreamerAc)
    HorStreamerArr:addObject(baseAcCall3)
    local seq3 = CCSequence:create(HorStreamerArr)
    HorStreamer:runAction(seq3)

    local fadeInTime = 0.5
    for i=1,2 do
        local fadeIn = CCFadeIn:create(fadeInTime)
        local delayT = CCDelayTime:create(t2 + 0.3)
        local arr = CCArray:create()
        arr:addObject(delayT)
        arr:addObject(fadeIn)
        local seq = CCSequence:create(arr)
        self.actionBgTb2[i]:runAction(seq)
    end

    
    local function flashShow( )
        flashSp:setVisible(true)
    end 
    local flashShowCall = CCCallFuncN:create(flashShow)
    local flashDelayT = CCDelayTime:create(t2 + 0.7)
    local scaleIn = CCScaleTo:create(0.3,0.2)
    local function flashEnd()
        self.flashSp:removeFromParentAndCleanup(true)
        self.flashSp = nil
    end
    local flashCall=CCCallFuncN:create(flashEnd)
    local flashArr = CCArray:create()
    flashArr:addObject(flashDelayT)
    flashArr:addObject(flashShowCall)
    flashArr:addObject(scaleIn)
    flashArr:addObject(flashCall)
    local flashSeq = CCSequence:create(flashArr)
    flashSp:runAction(flashSeq)

    for i=2,rewardNum do
        local rewardDelayT = CCDelayTime:create(t2 + 0.8  + (i-1) * 0.16)
        local function showCall() 
            self.rewardShowTb[1]:setVisible(true)
            self.rewardShowTb[i]:setVisible(true) 
        end
        local showFun = CCCallFuncN:create(showCall)
        local scaleTo1=CCScaleTo:create(0.3,iconSize/self.rewardShowTb[i]:getContentSize().width * 1.2)
        local scaleTo2=CCScaleTo:create(0,iconSize/self.rewardShowTb[i]:getContentSize().width)
        local heroShowArr = CCArray:create()
        heroShowArr:addObject(rewardDelayT)
        heroShowArr:addObject(showFun)
        heroShowArr:addObject(scaleTo1)
        heroShowArr:addObject(scaleTo2)

        local function showAwardBgCall()
            if self.rewardList[i].isNeedBigAwardBg then
                local xScale,iconSize = {0.21,0.5,0.79,0.3,0.7},100
                for j=1,2 do
                  local realLight = CCSprite:createWithSpriteFrameName("equipShine.png")
                  realLight:setAnchorPoint(ccp(0.5,0.5))
                  realLight:setScale(1.4)
                  realLight:setPosition(G_VisibleSizeWidth * xScale[i-1],G_VisibleSizeHeight * (i<5 and 0.65 or 0.38))
                  self.bgLayer:addChild(realLight,95)  
                  local roteSize = j ==1 and 360 or -360
                  local rotate1=CCRotateBy:create(4, roteSize)
                  local repeatForever = CCRepeatForever:create(rotate1)
                  realLight:runAction(repeatForever)
                  self.awardBgTb[i * 2+j-1] = realLight
                end
                print("rewardNum======>>>>",rewardNum)
                if rewardNum == 2 then
                    for k,v in pairs(self.awardBgTb) do
                        self.awardBgTb[k]:setPosition(getCenterPoint(self.bgLayer))
                    end
                end
            end
        end
        local awardBgCall = CCCallFuncN:create(showAwardBgCall)
        heroShowArr:addObject(awardBgCall)
        local heroSeq = CCSequence:create(heroShowArr)
        self.rewardShowTb[i]:runAction(heroSeq)

        local bgArr = CCArray:create()
        if rewardNum == 2 then
            local horiDelayT = CCDelayTime:create(t2 + 0.8  + (i-1) * 0.16)
            local horiSunArr=CCArray:create()
            for kk=1,6 do
              local nameStr="horiSun_"..kk..".png"
              local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
              horiSunArr:addObject(frame)
            end
            local animation=CCAnimation:createWithSpriteFrames(horiSunArr)
            animation:setDelayPerUnit(0.05)
            local horianimate=CCAnimate:create(animation)
            local function horiSunShowCall() self.rewardShowBgTb[i]:setVisible(true) end
            local horiSunCall = CCCallFuncN:create(horiSunShowCall)
            local function horiSunRemove() 
                self.rewardShowBgTb[i]:removeFromParentAndCleanup(true) 
                self.rewardShowBgTb[i] = nil
            end
            local horiSunCall2 = CCCallFuncN:create(horiSunRemove)
            -- local horiSunRunArr = CCArray:create()
            bgArr:addObject(horiDelayT)
            bgArr:addObject(horiSunCall)
            bgArr:addObject(horianimate)
            bgArr:addObject(horiSunCall2)
            -- local horiSeq = CCSequence:create(horiSunRunArr)
            -- self.rewardShowBgTb[i]:runAction(horiSeq)
        else
            local sVertcDelayT = CCDelayTime:create(t2 + 0.75  + (i-1) * 0.16)
            local sVertcSunArr=CCArray:create()
            for kk=1,5 do
              local nameStr="sVertclSun_"..kk..".png"
              local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
              sVertcSunArr:addObject(frame)
            end
            local animation=CCAnimation:createWithSpriteFrames(sVertcSunArr)
            animation:setDelayPerUnit(0.06)
            local sVertcanimate=CCAnimate:create(animation)
            local function sVertcSunShowCall() self.rewardShowBgTb[i]:setVisible(true) end
            local sVertcSunCall = CCCallFuncN:create(sVertcSunShowCall)
            local function sVertcSunRemove() 
                self.rewardShowBgTb[i]:removeFromParentAndCleanup(true) 
                self.rewardShowBgTb[i] = nil
            end
            local sVertcSunCall2 = CCCallFuncN:create(sVertcSunRemove)
            -- local sVertcSunRunArr = CCArray:create()
            bgArr:addObject(sVertcDelayT)
            bgArr:addObject(sVertcSunCall)
            bgArr:addObject(sVertcanimate)
            bgArr:addObject(sVertcSunCall2)
            -- local sVertcSeq = CCSequence:create(sVertcSunRunArr)
            -- self.rewardShowBgTb[i]:runAction(sVertcSeq)
        end
        local bgSeq = CCSequence:create(bgArr)
        self.rewardShowBgTb[i]:runAction(bgSeq)
    end

    local closeDeleyT = CCDelayTime:create(t2 + 0.85)
    local function showClose() self.actionCloseMenu:setVisible(true) end
    local showCloseCall = CCCallFuncN:create(showClose)
    local closeArr = CCArray:create()
    closeArr:addObject(closeDeleyT)
    closeArr:addObject(showCloseCall)
    local closeSeq = CCSequence:create(closeArr)
    self.actionCloseMenu:runAction(closeSeq)
end

-- function acMjzxDialog:runAwardAction( )
    
-- end

--点击tab页签 idx:索引
function acMjzxDialog:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)

    for k,v in pairs(self.allTabs) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx           
        else
            v:setEnabled(true)
        end
    end
    self:switchTab(idx+1)
end

function acMjzxDialog:switchTab(type)
    if not self.touchDia then
        local function touchCall()
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            self:stopAwardAction()
            -- self:showBlackAction(self.newRewardList,true,true)
        end
        self.tDialogHeight = 80
        self.touchDia = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchCall);
        self.touchDia:setTouchPriority(-(self.layerNum-1)*20-5)
        self.touchDia:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
        self.touchDia:setOpacity(0)
        self.touchDia:setIsSallow(true) -- 点击事件透下去
        self.touchDia:setPosition(ccp(G_VisibleSizeWidth*2.5,G_VisibleSizeHeight * 0.5))
        self.bgLayer:addChild(self.touchDia,99)
    end
    if type==nil then
        type=1
    end

    local function showTab( )
        if self["tab"..type]==nil then
            local tab
            if(type==1)then
                tab=acMjzxTabOne:new(self)
            else
                tab=acMjzxTabTwo:new(self)
            end
            self["tab"..type]=tab
            self["layerTab"..type]=tab:init(self.layerNum,self)
            self.bgLayer:addChild(self["layerTab"..type])
        end
        for i=1,2 do
            if(i==type)then
                if(self["layerTab"..i]~=nil)then
                    self["layerTab"..i]:setPosition(ccp(0,0))
                    self["layerTab"..i]:setVisible(true)
                end
            else
                if(self["layerTab"..i]~=nil)then
                    self["layerTab"..i]:setPosition(ccp(999333,0))
                    self["layerTab"..i]:setVisible(false)
                end
            end
        end
    end 

    if type== 2 then
        local function getRanklist(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if sData and sData.data and sData.data.rankList  then
                    acMjzxVoApi:setPlayerList(sData.data.rankList)
                    showTab()
                    self:refresh(2)
                end
                
            end

        end
        socketHelper:acMjzxRequest("list",{action=2},getRanklist)
    else
        showTab()
    end
end

function acMjzxDialog:refresh(tab)
    if tab ==2 then
        if self.tab2 then
            self.tab2:refresh()
        end
    end
end

function acMjzxDialog:tick()
    local acVo = acMjzxVoApi:getAcVo()
    if activityVoApi:isStart(acVo)==true then
        if self and self.tab1 and self.tab1.tick then
            self.tab1:tick()
        end
        -- if self and self.tab2 and self.tab2.tick then
        --     self.tab2:tick()
        -- end
    else
        self:close()
    end
end

function acMjzxDialog:doUserHandler()

end

function acMjzxDialog:dispose()
    self.baseAcSp = nil
    self.actionBgTb2 = nil
    self.awardBgTb = nil

    if self.tab1 and self.tab1.dispose then
        self.tab1:dispose()
    end
    if self.tab2 and self.tab2.dispose then
        self.tab1:dispose()
    end
    self.layerTab1=nil
    self.layerTab2=nil
    self.tab1=nil
    self.tab2=nil
    self.layerNum = nil

    spriteController:removePlist("public/acMjzxImage.plist")
    spriteController:removeTexture("public/acMjzxImage.png")
    spriteController:removePlist("public/acMjzx2Image.plist")
    spriteController:removeTexture("public/acMjzx2Image.png")
    spriteController:removePlist("public/taskYouhua.plist")
    spriteController:removeTexture("public/taskYouhua.png")
end