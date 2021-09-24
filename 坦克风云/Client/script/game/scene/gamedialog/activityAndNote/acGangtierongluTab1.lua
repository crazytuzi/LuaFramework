acGangtierongluTab1 = {}

function acGangtierongluTab1:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
    self.state = 0 
    self.tag=1
	return nc
end


function acGangtierongluTab1:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self:initLayer()
	return self.bgLayer
end

function acGangtierongluTab1:initLayer()

    local function touchDialog()

        if self.state == 2 then
            PlayEffect(audioCfg.mouseClick)
            self.state = 3
        end
    end
    self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
    self.touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-10)
    local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    self.touchDialogBg:setContentSize(rect)
    self.touchDialogBg:setOpacity(0)
    self.touchDialogBg:setIsSallow(false) -- 点击事件透下去
    self.touchDialogBg:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(self.touchDialogBg,1)
    -- 上半边
    self.exchange=acGangtierongluVoApi:getExchange()
    local function nilFunc()
    end
    local backSprie1 =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),nilFunc)
    
    backSprie1:ignoreAnchorPointForPosition(false);
    backSprie1:setAnchorPoint(ccp(0.5,1));
    backSprie1:setIsSallow(false)
    backSprie1:setTouchPriority(-(self.layerNum-1)*20-2)
    
    self.bgLayer:addChild(backSprie1)

    if(G_isIphone5())then
        backSprie1:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, 180))
        backSprie1:setPosition(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height-240)
    else
        backSprie1:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, 130))
        backSprie1:setPosition(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height-230)
    end

    local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),25)
    -- acLabel:setAnchorPoint(ccp(0,1))
    acLabel:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(acLabel,1)
    acLabel:setPosition(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height-180)

    local acVo = acGangtierongluVoApi:getAcVo()
    local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    local messageLabel=GetTTFLabel(timeStr,25)
    -- messageLabel:setAnchorPoint(ccp(0,0.5))
    messageLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height-205))
    self.bgLayer:addChild(messageLabel,3)
    self.timeLb=messageLabel
    self:updateAcTime()

    local function touchInfo()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        PlayEffect(audioCfg.mouseClick)
        local td=smallDialog:new()
        local version = acGangtierongluVoApi:getVersion()
        local str3=""
        if version==nil or version==1 then
            str3=getlocal("activity_gangtieronglu_tab1_tip3")
        else
            str3=getlocal("activity_gangtieronglu_tab1_tip3_" .. version)
        end

        local tabStr = {"\n",str3,getlocal("activity_gangtieronglu_tab1_tip2"), getlocal("activity_gangtieronglu_tab1_tip1"),"\n"}
        local tabColor={nil,nil,nil,nil,nil}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,tabColor)
        sceneGame:addChild(dialog,self.layerNum+1)

    end
    local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon2.png",touchInfo,1,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,1))
    menuItemDesc:setScale(0.8)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
    menuDesc:setPosition(ccp(self.bgLayer:getContentSize().width-40, self.bgLayer:getContentSize().height-165))
    self.bgLayer:addChild(menuDesc,2)


    local desTv, desLabel
    if(G_isIphone5())then
        desTv, desLabel=G_LabelTableView(CCSizeMake(backSprie1:getContentSize().width*0.93, 130),getlocal("activity_gangtieronglu_des"),25,kCCTextAlignmentLeft)
    else
        desTv, desLabel=G_LabelTableView(CCSizeMake(backSprie1:getContentSize().width*0.93, 100),getlocal("activity_gangtieronglu_des"),25,kCCTextAlignmentLeft)
    end
     
    backSprie1:addChild(desTv)
    desTv:setAnchorPoint(ccp(0,1))
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    desTv:setPosition(ccp(23,30))
    desTv:setMaxDisToBottomOrTop(80)

    if(G_isIphone5())then
       desTv:setPosition(ccp(23,30))
    else
        desTv:setPosition(ccp(23,10))
    end

    

    -- 下半边
    local backSprie2 =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),nilFunc)
    backSprie2:ignoreAnchorPointForPosition(false);
    backSprie2:setAnchorPoint(ccp(0.5,0));
    backSprie2:setIsSallow(false)
    backSprie2:setTouchPriority(-(self.layerNum-1)*20-2)
    
    self.bgLayer:addChild(backSprie2)
    if G_getIphoneType() == G_iphoneX then
        backSprie2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.bgLayer:getContentSize().height-645))
        backSprie2:setPosition(self.bgLayer:getContentSize().width/2, 220) 
    elseif(G_isIphone5())then
        backSprie2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.bgLayer:getContentSize().height-565))
        backSprie2:setPosition(self.bgLayer:getContentSize().width/2, 140)
    else
        backSprie2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.bgLayer:getContentSize().height-465))
        backSprie2:setPosition(self.bgLayer:getContentSize().width/2, 100)
    end

    local function nilFunc()
    end
    local desBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),nilFunc)
    desBg:setContentSize(CCSizeMake(570, 60))
    desBg:setAnchorPoint(ccp(0.5,1))
    desBg:setPosition(ccp(backSprie2:getContentSize().width/2, backSprie2:getContentSize().height-10))
    backSprie2:addChild(desBg,4)

    local desLb = GetTTFLabelWrap(getlocal("activity_gangtieronglu_desLb",{0}),25,CCSizeMake(500,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    desBg:addChild(desLb)
    desLb:setAnchorPoint(ccp(0,0.5))
    desLb:setPosition(20, desBg:getContentSize().height/2)
    
    desLb:setVisible(false)
    self.desLb=desLb


    local bgSp = CCSprite:createWithSpriteFrameName("acGangtierongluBg.png")
    backSprie2:addChild(bgSp)
    bgSp:setScale(0.95)
    bgSp:setPosition(backSprie2:getContentSize().width/2, backSprie2:getContentSize().height/2-13)
    self.bgSp=bgSp

    if(G_isIphone5())then
        bgSp:setPosition(backSprie2:getContentSize().width/2, backSprie2:getContentSize().height/2-13)
    else
        bgSp:setPosition(backSprie2:getContentSize().width/2, backSprie2:getContentSize().height/2-40)
    end

    local function touchSelectTank()

        require "luascript/script/game/scene/gamedialog/warDialog/selectTankDialog"
        local function callBack(id,num)
            self.id=id
            self.num=num

            local totalnum = self.exchange["a" .. self.id].num*self.num
            self.desLb:setString(getlocal("activity_gangtieronglu_desLb",{FormatNumber(totalnum)}))
            self.desLb:setVisible(true)
            self.iconBg:setVisible(false)
            local orderId=GetTankOrderByTankId(tonumber(self.id))
            local tankStr="t"..orderId.."_1.png"
          
            if  self.tankSp then
                self.tankSp:removeFromParentAndCleanup(true)
                self.tankSp=nil
            end
            -- local tankSp = CCSprite:createWithSpriteFrameName(tankStr)
            local tankSp=LuaCCSprite:createWithSpriteFrameName(tankStr,touchSelectTank)
            tankSp:setTouchPriority(-(self.layerNum-1)*20-3)
            local x,y = self.iconBg:getPosition()
            tankSp:setPosition(x-30,y-50)
            self.bgSp:addChild(tankSp,3)
            tankSp:setScale(1.5)
            self.tankSp=tankSp

            local tankBarrel="t"..orderId.."_1_1.png"  --炮管 第6层
            local tankBarrelSP=CCSprite:createWithSpriteFrameName(tankBarrel)
            if tankBarrelSP then
                tankBarrelSP:setPosition(ccp(tankSp:getContentSize().width*0.5,tankSp:getContentSize().height*0.5))
                tankBarrelSP:setAnchorPoint(ccp(0.5,0.5))
                tankSp:addChild(tankBarrelSP)
            end
        end
        local tankData=acGangtierongluVoApi:getTankData()
        selectTankDialog:showSelectTankDialog(nil,self.layerNum+1,callBack,tankData,100000000000,true)
    end
    local iconBg = GetBgIcon("Icon_BG.png",touchSelectTank)
    bgSp:addChild(iconBg,3)
    -- iconBg:setAnchorPoint(ccp(1,1))
    -- iconBg:setScale(1/1.6)
    iconBg:setTouchPriority(-(self.layerNum-1)*20-2)
    iconBg:setPosition(bgSp:getContentSize().width-80, bgSp:getContentSize().height-80)
    iconBg:setScale(1.2)
    self.iconBg=iconBg

    local moreSp = CCSprite:createWithSpriteFrameName("ProduceTankIconMore.png")
    iconBg:addChild(moreSp)
    moreSp:setScale(2)
    moreSp:setPosition(iconBg:getContentSize().width/2+1, iconBg:getContentSize().height/2-3)

    -- ProduceTankIconMore
    -- acGangtierongluBg


    -- 按钮
    local function touchItem(tag)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self.tag=tag
        if tag==2 then -- 熔炼
            if self.id==nil then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_gangtieronglu_tip1"),30)
                return
            end
            local function callback(fn,data)
                local ret,sData = base:checkServerData(data)
                if ret==true then
                    if sData and sData.data and sData.data.gangtieronglu then
                        acGangtierongluVoApi:updateSpecialData(sData.data.gangtieronglu)
                        self:startPalyAnimation()
                    end
                end
            end
            socketHelper:acGangtierongluTotal(1,"a" .. self.id,self.num,nil,callback)
        else -- 合成
            local r4 = playerVoApi:getR4()
            local cost =  acGangtierongluVoApi:getCost()
            if r4<cost then
                 smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_gangtieronglu_tip2",{FormatNumber(cost)}),30)
                return
            end
            local function compose()
                local function callback(fn,data)
                    local ret,sData = base:checkServerData(data)
                    if ret==true then
                        if sData and sData.data and sData.data.gangtieronglu then
                            acGangtierongluVoApi:updateSpecialData(sData.data.gangtieronglu)
                        end
                        if sData and sData.data and sData.data.reward then
                            local reward =  sData.data.reward
                            local itemTb = FormatItem(sData.data.reward)
                            self.itemTb=itemTb
                            if  self.tankSp then
                                self.tankSp:removeFromParentAndCleanup(true)
                                self.tankSp=nil
                            end
                            self.desLb:setVisible(false)
                            self.iconBg:setVisible(true)
                            for k,v in pairs(itemTb) do
                                G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                            end
                           
                        end
                         self:startPalyAnimation()
                    end
                end
                socketHelper:acGangtierongluTotal(2,nil,nil,nil,callback)
            end
            local hecheStr=""
            local version = acGangtierongluVoApi:getVersion()
            if version==nil or version==1 then
                hecheStr=getlocal("activity_gangtieronglu_tip3",{FormatNumber(cost)})
            else
                hecheStr=getlocal("activity_gangtieronglu_tip3_" .. version,{FormatNumber(cost)})
            end
            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),compose,getlocal("dialog_title_prompt"),hecheStr,nil,self.layerNum+1)
        end
    end

    ------------------------------------------合成,熔炼纪录添加----------------------------------------
    --@author hj
    local function recordsHandler( ... )
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        
        acGangtierongluVoApi:showLog(self.layerNum+1)
    end

    local recordBtn=GetButtonItem("bless_record.png","bless_record.png","bless_record.png",recordsHandler,11,nil,nil)
    recordBtn:setScale(0.8)
    local recordMenu=CCMenu:createWithItem(recordBtn)
    recordMenu:setAnchorPoint(ccp(1,0))
    recordMenu:setPosition(ccp(backSprie2:getContentSize().width-60,80))
    recordMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    backSprie2:addChild(recordMenu)

    local recordLb=GetTTFLabelWrap(getlocal("serverwar_point_record"),22,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    recordLb:setAnchorPoint(ccp(0.5,1))
    recordLb:setScale(1/recordBtn:getScale())
    recordLb:setPosition(recordBtn:getContentSize().width*recordBtn:getScale()/2,-5)
    recordBtn:addChild(recordLb)
    ------------------------------------------------------------------------------------------------


    local hechengItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",touchItem,2,getlocal("activity_gangtieronglu_compose"),25)
    hechengItem:setAnchorPoint(ccp(0.5,0.5))
    
    hechengItem:setTag(1)
    local hechengBtn=CCMenu:createWithItem(hechengItem);
    hechengBtn:setTouchPriority(-(self.layerNum-1)*20-2);
    
    self.bgLayer:addChild(hechengBtn)

     local ronglianItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",touchItem,2,getlocal("activity_gangtieronglu_tab1"),25)
    ronglianItem:setAnchorPoint(ccp(0.5,0.5))
    
    ronglianItem:setTag(2)
    local ronglianBtn=CCMenu:createWithItem(ronglianItem);
    ronglianBtn:setTouchPriority(-(self.layerNum-1)*20-2);
    
    self.bgLayer:addChild(ronglianBtn)

    if G_getIphoneType() == G_iphoneX then
        ronglianBtn:setPosition(ccp(self.bgLayer:getContentSize().width/2+130,110))
        hechengBtn:setPosition(ccp(self.bgLayer:getContentSize().width/2-130,110))
    elseif(G_isIphone5())then
        ronglianBtn:setPosition(ccp(self.bgLayer:getContentSize().width/2+130,80))
        hechengBtn:setPosition(ccp(self.bgLayer:getContentSize().width/2-130,80))
    else
        hechengItem:setScale(0.8)
        ronglianItem:setScale(0.8)
        ronglianBtn:setPosition(ccp(self.bgLayer:getContentSize().width/2+100,60))
        hechengBtn:setPosition(ccp(self.bgLayer:getContentSize().width/2-100,60))
    end

    
	
end

function acGangtierongluTab1:runaction()
    -- self.tankSp
    local moveTo = CCMoveTo:create(1.5,CCPointMake(self.bgSp:getContentSize().width/2-10,self.bgSp:getContentSize().height/2-20))
    local function callback1()
        self:addFrameAction()
    end
    local callFunc1=CCCallFunc:create(callback1)
    local delay=CCDelayTime:create(2)
    local delay2=CCDelayTime:create(2.2)
    local delay3=CCDelayTime:create(0.4)

    local function callback2()
       self:stopPlayAnimation()
    end
    local callback2=CCCallFunc:create(callback2)

    local callFunc3
    if self.tag==2 then
        local function callback3()
            local scaleTo =  CCScaleTo:create(0.7, 0.0001)
            self.tankSp:runAction(scaleTo)
        end
        callFunc3=CCCallFunc:create(callback3)
    else
        local function callback3()
           local pic = self.itemTb[1].pic
           local daojuSp = CCSprite:createWithSpriteFrameName(pic)
           daojuSp:setPosition(self.bgSp:getContentSize().width/2-10,self.bgSp:getContentSize().height/2+10)
           self.bgSp:addChild(daojuSp)
           daojuSp:setScale(0.0001)
           self.daojuSp=daojuSp

           local hScale = 100/daojuSp:getContentSize().width
           local scaleTo =  CCScaleTo:create(0.5, hScale)
            self.daojuSp:runAction(scaleTo)


        end
        callFunc3=CCCallFunc:create(callback3)
    end

    -- CCSpawn *Spawn=CCSpawn::create(RotateTo,MoveRight,Scale,NULL)

    if self.tag==2 then
        local acArr=CCArray:create()
        acArr:addObject(moveTo)
        acArr:addObject(delay3)
        acArr:addObject(callFunc1)
        acArr:addObject(delay)
        acArr:addObject(callFunc3)
        acArr:addObject(delay2)
        acArr:addObject(callback2)
        local seq=CCSequence:create(acArr)
        self.tankSp:runAction(seq)
    else
        local acArr=CCArray:create()
        acArr:addObject(callFunc1)
        acArr:addObject(delay)
        acArr:addObject(callFunc3)
        acArr:addObject(delay2)
        acArr:addObject(callback2)
        local seq=CCSequence:create(acArr)
        self.bgLayer:runAction(seq)
    end

   

    

    
end

function acGangtierongluTab1:endaction()
    -- self:addParticleAction()
    if  self.tankSp then
        self.tankSp:stopAllActions()
        self.tankSp:removeFromParentAndCleanup(true)
        self.tankSp=nil
    end

    if  self.daojuSp then
        self.daojuSp:stopAllActions()
        self.daojuSp:removeFromParentAndCleanup(true)
        self.daojuSp=nil
    end

    if self.frameSp then
        self.frameSp:stopAllActions()
        self.frameSp:removeFromParentAndCleanup(true)
        self.frameSp=nil
    end

    self.bgLayer:stopAllActions()

    self.desLb:setVisible(false)
    if self.tag==2 then
        local num = self.exchange["a" .. self.id].num*self.num
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_gangtieronglu_tip4",{num}),30)
        -- playerVoApi:setValue("r4",playerVo["r4"]+tonumber(num))
        -- self.id=nil
        -- self.num=nil
    else
        -- local cost =  acGangtierongluVoApi:getCost()
        -- playerVoApi:setValue("r4",playerVo["r4"]-tonumber(cost))
        G_showRewardTip(self.itemTb,true)
    end
    self.id=nil
    self.num=nil
   
end

function acGangtierongluTab1:addFrameAction()
    local pzFrameName="hechengLight1.png"
    local frameSp=CCSprite:createWithSpriteFrameName(pzFrameName)
    local pzArr=CCArray:create()
    for kk=1,14 do
        local nameStr="hechengLight"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        pzArr:addObject(frame)
    end
    local animation=CCAnimation:createWithSpriteFrames(pzArr)
    animation:setDelayPerUnit(0.3)
    local animate=CCAnimate:create(animation)
    self.bgSp:addChild(frameSp,4)
    frameSp:setPosition(self.bgSp:getContentSize().width/2-20, self.bgSp:getContentSize().height/2+9)
    frameSp:runAction(animate)
    frameSp:setScale(2)
    self.frameSp=frameSp
end

function acGangtierongluTab1:addParticleAction()
    local display = CCParticleSystemQuad:create("public/Bomb.plist")
    display.positionType=kCCPositionTypeFree
    display:setPosition(self.bgSp:getContentSize().width/2,self.bgSp:getContentSize().height/2)
    self.bgSp:addChild(display)
end

function acGangtierongluTab1:startPalyAnimation()
    self.state = 2
    self.touchDialogBg:setIsSallow(true) -- 点击事件透下去
    self:runaction()
end

function acGangtierongluTab1:stopPlayAnimation()
    self.state = 0
    self.iconBg:setVisible(true)
    self.touchDialogBg:setIsSallow(false) -- 点击事件透下去
    self:endaction()
end

function acGangtierongluTab1:tick()
    self:updateAcTime()
end

function acGangtierongluTab1:updateAcTime()
    local acVo=acGangtierongluVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acGangtierongluTab1:fastTick()
    if self.state == 3 then
        self:stopPlayAnimation()
    end
end



function acGangtierongluTab1:dispose()
    self.bgLayer=nil
    self.layerNum=nil
    self.id=nil
    self.num=nil
    self.exchange=nil
    self.touchDialogBg=nil
    self.bgSp=nil
    self.tag=nil
    self.desLb=nil
    self.itemTb=nil
end

