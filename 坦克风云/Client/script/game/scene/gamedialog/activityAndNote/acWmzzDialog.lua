acWmzzDialog = commonDialog:new()

function acWmzzDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.isToday=true
    nc.cellHight=170
    nc.zheZhaoTb={}
    nc.numLbTb={}
    nc.state=0
    spriteController:addPlist("public/acWmzzImage.plist")
    spriteController:addTexture("public/acWmzzImage.png")
    spriteController:addPlist("public/acOpenyearImage.plist")
    spriteController:addTexture("public/acOpenyearImage.png")
    spriteController:addPlist("serverWar/serverWar.plist")
    spriteController:addTexture("serverWar/serverWar.pvr.ccz")
    self.secondDialog=nil
    return nc
end

function acWmzzDialog:resetTab()
    local acVo = acWmzzVoApi:getAcVo()
    if activityVoApi:isStart(acVo)==true then
        if not G_isToday(acVo.lastTime) then
            acWmzzVoApi:refreshClear()
        end
    end
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
	self.panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-100))
end

function acWmzzDialog:initTableView( )
end

function acWmzzDialog:doUserHandler()
    -- 屏蔽层
    local function touchDialog()
        if self.state == 2 then
            PlayEffect(audioCfg.mouseClick)
            self.state=3 
        end
    end
    self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
    self.touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-10)
    local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    self.touchDialogBg:setContentSize(rect)
    self.touchDialogBg:setOpacity(0)
    self.touchDialogBg:setVisible(false)
    self.touchDialogBg:setAnchorPoint(ccp(0,0))
    self.touchDialogBg:setIsSallow(true) -- 点击事件透下去
    self.touchDialogBg:setPosition(1000000,1000000)
    self.bgLayer:addChild(self.touchDialogBg,1)

    -- 蓝底背景
    local function addBlueBg()
        local blueBg=CCSprite:create("public/superWeapon/weaponBg.jpg")
        blueBg:setAnchorPoint(ccp(0.5,0))
        -- blueBg:setScaleX(600/blueBg:getContentSize().width)
        blueBg:setScaleY((G_VisibleSizeHeight-110)/blueBg:getContentSize().height)
        blueBg:setPosition(G_VisibleSizeWidth/2,20)
        blueBg:setOpacity(200)
        -- blueBg:setAnchorPoint(ccp(0,0))
        -- blueBg:setPosition(ccp(0,0))
        self.bgLayer:addChild(blueBg)
    end
    G_addResource8888(addBlueBg)

    local ip5H=5
    local ip5H2=3
    if(G_isIphone5())then
        ip5H=10
        ip5H2=20
    end

    local starH=G_VisibleSizeHeight-90-ip5H
    -- 活动时间
    local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),28)
    acLabel:setAnchorPoint(ccp(0.5,1))
    acLabel:setPosition(ccp(G_VisibleSizeWidth/2, starH))
    self.bgLayer:addChild(acLabel,5)
    acLabel:setColor(G_ColorYellowPro)

    local timeH=starH-35-ip5H
    local acVo = acWmzzVoApi:getAcVo()
    local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    local messageLabel=GetTTFLabel(timeStr,25)
    messageLabel:setAnchorPoint(ccp(0.5,1))
    messageLabel:setPosition(ccp(G_VisibleSizeWidth/2, timeH))
    self.bgLayer:addChild(messageLabel,5)
    self.messageLabel=messageLabel
    G_updateActiveTime(acVo,messageLabel)

    local function touchTip()
        local tabStr={}
        tabStr={getlocal("activity_wmzz_tip1"),getlocal("activity_wmzz_tip2"),getlocal("activity_wmzz_tip3"),getlocal("activity_wmzz_tip4")}
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr)
    end

    local pos=ccp(self.bgLayer:getContentSize().width-70,starH-40)
    G_addMenuInfo(self.bgLayer,self.layerNum,pos,tabStr,nil,nil,nil,touchTip)

    local desH=timeH-35-ip5H
    -- local acDesLb=GetTTFLabelWrap(getlocal("activity_wmzz_des"),25,CCSizeMake(G_VisibleSizeWidth-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    -- acDesLb:setAnchorPoint(ccp(0,1))
    -- self.bgLayer:addChild(acDesLb,1)
    -- acDesLb:setPosition(50,desH)

    local desTv, desLabel = G_LabelTableView(CCSizeMake(G_VisibleSizeWidth-100, 60),getlocal("activity_wmzz_des"),25,kCCTextAlignmentLeft)
    self.bgLayer:addChild(desTv)
    desTv:setPosition(ccp(50,desH-60))
    desTv:setAnchorPoint(ccp(0,0))
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    desTv:setMaxDisToBottomOrTop(100)

    local lineH=desH-60-10-ip5H
    local lineSp=CCSprite:createWithSpriteFrameName("openyear_line.png")
    self.bgLayer:addChild(lineSp)
    lineSp:setPosition(G_VisibleSizeWidth/2,lineH)
    lineSp:setScaleX((self.bgLayer:getContentSize().width*0.8)/lineSp:getContentSize().width)
    local subWidth,posX2 = 230,50
    if G_getCurChoseLanguage() =="ar" then
        subWidth,posX2 = 200,10
    end
    local composeH=lineH-40-ip5H2
    local composeDes=GetTTFLabelWrap(getlocal("activity_wmzz_zz_des"),25,CCSizeMake(G_VisibleSizeWidth-subWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    composeDes:setAnchorPoint(ccp(0,0.5))
    self.bgLayer:addChild(composeDes,1)
    composeDes:setPosition(posX2,composeH)
    self.composeDes=composeDes

    local function touchCompose()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)


        local function refreshFunc()
            if self and self.bgLayer then
                local cfg=acWmzzVoApi:getCfg()
                local reward={o={{}}}
                reward.o[1][cfg.tankId]=self.composeNum
                local formatReward=FormatItem(reward)
                G_showRewardTip(formatReward,true)

                self:refreshZheZhao()

                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_wmzz_compose_success"),30)
            end
        end
        acWmzzVoApi:socketWmzz(refreshFunc,2,nil,nil,nil)
    end
    local composeItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",touchCompose,nil,getlocal("compose"),25/0.8)
    composeItem:setScale(0.8)
    self.composeItem=composeItem
    local composeBtn=CCMenu:createWithItem(composeItem);
    composeBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    composeBtn:setPosition(ccp(G_VisibleSizeWidth-100,composeH))
    self.bgLayer:addChild(composeBtn)

    self.startCenterH=composeH-40-ip5H2

    self:initCenter()
    self:initBottom()
end

function acWmzzDialog:initCenter()
    local function sbCallback()
    end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),sbCallback)
    backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth, self.startCenterH-130))
    self.bgLayer:addChild(backSprie)
    backSprie:setAnchorPoint(ccp(0.5,1))
    backSprie:setPosition(G_VisibleSizeWidth/2,self.startCenterH)
    backSprie:setOpacity(0)

    -- 背景 线上现在
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local url=G_downloadUrl("active/" .. "acWmzz_bg.jpg")
    local function onLoadIcon(fn,icon)
        if self and self.bgLayer then
            icon:setAnchorPoint(ccp(0.5,1))
            backSprie:addChild(icon)
            icon:setPosition(backSprie:getContentSize().width/2,backSprie:getContentSize().height-15)

            local lineSp=CCSprite:createWithSpriteFrameName("openyear_line.png")
            icon:addChild(lineSp)
            lineSp:setPosition(icon:getContentSize().width/2,0)
            lineSp:setScaleX((self.bgLayer:getContentSize().width*0.8)/lineSp:getContentSize().width)
        end
    end
    local webImage=LuaCCWebImage:createWithURL(url,onLoadIcon)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    local bsSize=backSprie:getContentSize()
    -- 滑竿
    local titleSp1=CCSprite:createWithSpriteFrameName("acWmzz_1.png")
    titleSp1:setPosition(bsSize.width/2-titleSp1:getContentSize().width/2,bsSize.height-titleSp1:getContentSize().height/2)
    backSprie:addChild(titleSp1,3)

    local titleSp2=CCSprite:createWithSpriteFrameName("acWmzz_1.png")
    titleSp2:setPosition(bsSize.width/2+titleSp2:getContentSize().width/2,bsSize.height-titleSp2:getContentSize().height/2)
    backSprie:addChild(titleSp2,3)
    titleSp2:setFlipX(true)

    -- joint关节
    local joint1=CCSprite:createWithSpriteFrameName("acWmzz_joint1.png")
    backSprie:addChild(joint1,2)
    joint1:setPosition(40,bsSize.height-30)
    joint1:setOpacity(0)
    self.joint1=joint1

    local joint2=CCSprite:createWithSpriteFrameName("acWmzz_joint2.png")
    joint1:addChild(joint2)
    joint2:setAnchorPoint(ccp(25.5/joint2:getContentSize().width,176.5/joint2:getContentSize().height))
    joint2:setPosition(joint1:getContentSize().width/2,joint1:getContentSize().height/2-15)
    -- joint2:setRotation(-90)
    self.joint2=joint2

    local sbJoint1=CCSprite:createWithSpriteFrameName("acWmzz_joint1.png")
    joint1:addChild(sbJoint1)
    sbJoint1:setPosition(getCenterPoint(joint1))

    local joint3=CCSprite:createWithSpriteFrameName("acWmzz_joint3.png")
    joint2:addChild(joint3)
    joint3:setAnchorPoint(ccp(16.5/joint3:getContentSize().width,98.5/joint3:getContentSize().height))
    joint3:setPosition(25,9.5)
    -- joint3:setRotation(0)
    -- joint3:setRotation(180)
    self.joint3=joint3
    self:resertJoint()


    -- 详细信息
    local function touchInfo()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        tankInfoDialog:create(self.bgLayer,acWmzzVoApi:getComposeTankID(),self.layerNum+1)
    end
    -- local infoSp=LuaCCSprite:createWithSpriteFrameName("acWmzz_8.png",touchInfo)
    -- backSprie:addChild(infoSp,1)
    -- infoSp:setTouchPriority(-(self.layerNum-1)*20-4)
    -- infoSp:setPosition(bsSize.width-60,bsSize.height-120)

    local infoItem = GetButtonItem("object_info_btn.png","object_info_btnDown.png","object_info_btn.png",touchInfo,nil,nil,0)
    -- actionTouchFir:setAnchorPoint(ccp(1,0))
    local infoBtn = CCMenu:createWithItem(infoItem)
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    infoBtn:setPosition(ccp(bsSize.width-60,bsSize.height-120))
    backSprie:addChild(infoBtn,1)

    -- 战报
    local function touchAction(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        acWmzzVoApi:showBattle()
    end 
    local actionTouchFir = GetButtonItem("cameraBtn.png","cameraBtn_down.png","cameraBtn.png",touchAction,nil,nil,0)
    -- actionTouchFir:setAnchorPoint(ccp(1,0))
    local actionTouchFirMenu = CCMenu:createWithItem(actionTouchFir)
    actionTouchFirMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    actionTouchFirMenu:setPosition(ccp(bsSize.width-60,bsSize.height-280))
    backSprie:addChild(actionTouchFirMenu,1)

    -- 底座
    local dizuoSp=CCSprite:createWithSpriteFrameName("acWmzz_6.png")
    dizuoSp:setPosition(bsSize.width/2-10,bsSize.height-243)
    backSprie:addChild(dizuoSp,1)


    -- sbKuang上 添加 黑色遮罩 本身透明
    local sbKuangSp=LuaCCScale9Sprite:createWithSpriteFrameName("acWmzz_2.png",CCRect(36, 36, 1, 1),sbCallback)
    dizuoSp:addChild(sbKuangSp,2)
    sbKuangSp:setContentSize(CCSizeMake(421,313))
    sbKuangSp:setPosition(dizuoSp:getContentSize().width/2+10,dizuoSp:getContentSize().height/2+15)
    sbKuangSp:setOpacity(0)

    -- kuang上 添加线 数字
    local kuangSp=LuaCCScale9Sprite:createWithSpriteFrameName("acWmzz_2.png",CCRect(36, 36, 1, 1),sbCallback)
    kuangSp:setContentSize(sbKuangSp:getContentSize())
    sbKuangSp:addChild(kuangSp)
    kuangSp:setPosition(getCenterPoint(sbKuangSp))

    local kuangSize=kuangSp:getContentSize()

    -- 四条线
    local lineWidth=kuangSize.width-10
    local lineHeight=kuangSize.height-10
    local lineSp1=CCSprite:createWithSpriteFrameName("acWmzz_5.png")
    lineSp1:setPosition(kuangSize.width/2,kuangSize.height/3*2)
    kuangSp:addChild(lineSp1,2)
    lineSp1:setScaleX(lineWidth/lineSp1:getContentSize().width)

    local lineSp2=CCSprite:createWithSpriteFrameName("acWmzz_5.png")
    lineSp2:setPosition(kuangSize.width/2,kuangSize.height/3)
    kuangSp:addChild(lineSp2,2)
    lineSp2:setScaleX(lineWidth/lineSp2:getContentSize().width)

    local lineSp3=CCSprite:createWithSpriteFrameName("acWmzz_5.png")
    lineSp3:setPosition(kuangSize.width/3,kuangSize.height/2)
    kuangSp:addChild(lineSp3,2)
    lineSp3:setRotation(90)
    lineSp3:setScaleX(lineHeight/lineSp3:getContentSize().width)

    local lineSp4=CCSprite:createWithSpriteFrameName("acWmzz_5.png")
    lineSp4:setPosition(kuangSize.width/3*2,kuangSize.height/2)
    kuangSp:addChild(lineSp4,2)
    lineSp4:setRotation(90)
    lineSp4:setScaleX(lineHeight/lineSp4:getContentSize().width)

    -- 两个斜角
    local xiejiaoSp1=CCSprite:createWithSpriteFrameName("acWmzz_3.png")
    kuangSp:addChild(xiejiaoSp1)
    xiejiaoSp1:setAnchorPoint(ccp(0,1))
    xiejiaoSp1:setPosition(-2,kuangSize.height+2)

    local xiejiaoSp2=CCSprite:createWithSpriteFrameName("acWmzz_3.png")
    kuangSp:addChild(xiejiaoSp2)
    xiejiaoSp2:setAnchorPoint(ccp(0,1))
    xiejiaoSp2:setPosition(kuangSize.width+1,-1)
    xiejiaoSp2:setRotation(180)

    -- 遮罩
    -- local everyW=kuangSize.width/6
    -- local everyH=kuangSize.height/6
    -- local posTb={
    --     {pos=ccp(everyW,everyH*5)},
    --     {pos=ccp(everyW*3,everyH*5)},
    --     {pos=ccp(everyW*5,everyH*5)},
    --     {pos=ccp(everyW,everyH*3)},
    --     {pos=ccp(everyW*3,everyH*3)},
    --     {pos=ccp(everyW*5,everyH*3)},
    --     {pos=ccp(everyW,everyH*1)},
    --     {pos=ccp(everyW*3,everyH*1)},
    --     {pos=ccp(everyW*5,everyH*1)},
    -- }

    local startX=3+138/2
    local startY=kuangSize.height-3-102/2
    local posTb={
        {pos=ccp(startX,startY)},
        {pos=ccp(startX+138,startY)},
        {pos=ccp(startX+138*2,startY)},
        {pos=ccp(startX,startY-102)},
        {pos=ccp(startX+138,startY-102)},
        {pos=ccp(startX+138*2,startY-102)},
        {pos=ccp(startX,startY-102*2)},
        {pos=ccp(startX+138,startY-102*2)},
        {pos=ccp(startX+138*2,startY-102*2)},
    }

    for k,v in pairs(posTb) do
        local function touchZheZhao()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            local fragT=acWmzzVoApi:getFragT()
            if fragT["f" .. k] and fragT["f" .. k]>0 then
                local tabStr={}
                tabStr={getlocal("activity_wmzz_frag_des")}
                require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
                tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_wmzz_frag",{k}),tabStr)
                return
            end
            PlayEffect(audioCfg.mouseClick)

            local gems=playerVoApi:getGems()
            local needCost=acWmzzVoApi:getCostByType(3)
            if needCost>gems then
                local function onSure()
                    activityAndNoteDialog:closeAllDialog()
                end
                GemsNotEnoughDialog(nil,nil,needCost-gems,self.layerNum+1,needCost,onSure)
                return
            end
            local function realBuyFragment()
                local function refreshFunc()
                    playerVoApi:setGems(playerVoApi:getGems()-needCost)
                    if self and self.bgLayer then
                        self:refreshZheZhao()
                        local acArr=CCArray:create()
                        local scaleTo1=CCScaleTo:create(0.1,1.5)
                        local scaleTo2=CCScaleTo:create(0.1,1)
                        acArr:addObject(scaleTo1)
                        acArr:addObject(scaleTo2)
                        local seq=CCSequence:create(acArr)
                        self.numLbTb[k]:runAction(seq)
                    end
                end
                acWmzzVoApi:socketWmzz(refreshFunc,3,nil,nil,"f" .. k)
                self.secondDialog=nil
            end
            local cfg=acWmzzVoApi:getCfg()
            -- smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),realBuyFragment,getlocal("dialog_title_prompt"),getlocal("activity_stormrocket_buyFragment",{acWmzzVoApi:getCostByType(3),cfg.buyPartNum}),nil,self.layerNum+1)

            self.secondDialog=G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("activity_stormrocket_buyFragment",{acWmzzVoApi:getCostByType(3),cfg.buyPartNum}),false,realBuyFragment,nil)

            
        end
        local zheZhaoSp
        if k==1 or k==3 or k==7 or k==9 then
            zheZhaoSp=LuaCCSprite:createWithSpriteFrameName("acWmzz_4.png",touchZheZhao)
            if k==3 then
                zheZhaoSp:setFlipY(true)
            elseif k==7 then
                zheZhaoSp:setFlipX(true)
            elseif k==1 then
                zheZhaoSp:setFlipX(true)
                zheZhaoSp:setFlipY(true)
            end
        else
            zheZhaoSp = LuaCCScale9Sprite:createWithSpriteFrameName("acWmzz_9.png",CCRect(2, 2, 1, 1),touchZheZhao)
            zheZhaoSp:setContentSize(CCSizeMake(138,102))
        end
        zheZhaoSp:setTouchPriority(-(self.layerNum-1)*20-4)
        zheZhaoSp:setPosition(v.pos)
        sbKuangSp:addChild(zheZhaoSp)
        self.zheZhaoTb[k]=zheZhaoSp

        local numLb=GetTTFLabel("",25)
        kuangSp:addChild(numLb)
        numLb:setAnchorPoint(ccp(1,0))
        numLb:setPosition(v.pos.x+65,v.pos.y-50)
        self.numLbTb[k]=numLb
    end
    self:refreshZheZhao()

    local startY=50
    -- if (not G_isIphone5()) then
    --     startY=75
    -- end
    local subW=200
    local iconWidth=90
    local leftW=20
    local tankId=acWmzzVoApi:getComposeTankID()
    local typeStr = "pro_ship_attacktype_"..tankCfg[tankId].attackNum
    local attackTypeSp = CCSprite:createWithSpriteFrameName(typeStr..".png");
    attackTypeSp:setAnchorPoint(ccp(0.5,0.5));
    attackTypeSp:setPosition(ccp(bsSize.width/2-subW-leftW,startY))
    attackTypeSp:setScale(77/attackTypeSp:getContentSize().height)
    backSprie:addChild(attackTypeSp,2)
    local subPosX,subWidth2 = 0 ,120
    if G_getCurChoseLanguage() =="ar" then
        subPosX,subWidth2 = 10,100
    end
    local attTypeLb=GetTTFLabelWrap(getlocal(typeStr),22,CCSizeMake(subWidth2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    attTypeLb:setAnchorPoint(ccp(0,0.5))
    attTypeLb:setPosition(ccp(bsSize.width/2-subW+iconWidth/2-leftW-subPosX,startY))
    backSprie:addChild(attTypeLb,2)

    local attackSp = CCSprite:createWithSpriteFrameName("pro_ship_attack.png");
    attackSp:setAnchorPoint(ccp(0.5,0.5));
    attackSp:setPosition(ccp(bsSize.width/2-leftW,startY))
    attackSp:setScale(77/attackSp:getContentSize().height)
    backSprie:addChild(attackSp,2)

    
    local attLb=GetTTFLabel(tankCfg[tankId].attack,22)
    attLb:setAnchorPoint(ccp(0,0.5))
    attLb:setPosition(ccp(bsSize.width/2+iconWidth/2-leftW,startY))
    backSprie:addChild(attLb)

    local lifeSp = CCSprite:createWithSpriteFrameName("pro_ship_life.png");
    lifeSp:setAnchorPoint(ccp(0.5,0.5))
    lifeSp:setPosition(ccp(bsSize.width/2+subW-leftW,startY))
    lifeSp:setScale(77/lifeSp:getContentSize().height)
    backSprie:addChild(lifeSp,2)

    local lifeLb=GetTTFLabel(tankCfg[tankId].life,22)
    lifeLb:setAnchorPoint(ccp(0,0.5))
    lifeLb:setPosition(ccp(bsSize.width/2+subW+iconWidth/2-leftW,startY))
    backSprie:addChild(lifeLb)

    if (G_isIphone5()) then
        infoBtn:setPosition(bsSize.width/2-150,startY+130)
        actionTouchFirMenu:setPosition(bsSize.width/2+150,startY+130)
    end

end

function acWmzzDialog:initBottom()
    local btnLbStrSize=25
    local subAddH=0
    local function touchBuy(tag)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local needCost=0
        local free=0
        if tag==1 then
            local flag=acWmzzVoApi:isDailyFree()
            if flag==1 then
                needCost=acWmzzVoApi:getCostByType(1)
            else
                free=1
            end
        else
            needCost=acWmzzVoApi:getCostByType(2)
        end
        local gems=playerVoApi:getGems()
        if needCost>gems then
            local function onSure()
                activityAndNoteDialog:closeAllDialog()
            end
            GemsNotEnoughDialog(nil,nil,needCost-gems,self.layerNum+1,needCost,onSure)
            return
        end
        local function refreshFunc(reward,iscrit)
            playerVoApi:setGems(playerVoApi:getGems()-needCost)
            if self and self.bgLayer then
                self:refreshCostLb()
                self.touchDialogBg:setPosition(0,0)
                self.reward=reward
                self.iscrit=iscrit
                if tag~=1 then
                    self.state=2
                else
                    self.state=0
                end
                self:runaction(reward,iscrit)
            end
        end
        local function sureClick()
            acWmzzVoApi:socketWmzz(refreshFunc,1,free,tag,nil)
            self.secondDialog=nil
        end
        local function secondTipFunc(sbFlag)
            local keyName=acWmzzVoApi:getActiveName()
            local sValue=base.serverTime .. "_" .. sbFlag
            G_changePopFlag(keyName,sValue)
        end
        if needCost>0 then
            local keyName=acWmzzVoApi:getActiveName()
            if G_isPopBoard(keyName) then
                self.secondDialog=G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{needCost}),true,sureClick,secondTipFunc)
            else
                sureClick()
            end
            
        else
            sureClick()
        end
    end

    local function callback1()
        touchBuy(1)
    end
    local function callback2()
        touchBuy(10)
    end
    local menuPosY=60
    -- if(G_isIphone5())then
    --     menuPosY=75
    -- end
    local btnScale=0.8
    local menuItem={}
    menuItem[1]=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",callback1,nil,getlocal("activity_wmzz_btn",{1}),btnLbStrSize/btnScale)
    menuItem[2]=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",callback2,nil,getlocal("activity_wmzz_btn",{10}),btnLbStrSize/btnScale)
    self.menuItem1=menuItem[1]
    self.menuItem1:setScale(btnScale)
    self.menuItem2=menuItem[2]
    self.menuItem2:setScale(btnScale)
    local btnMenu = CCMenu:create()
    btnMenu:addChild(menuItem[1])
    btnMenu:addChild(menuItem[2])
    btnMenu:alignItemsHorizontallyWithPadding(160)
    self.bgLayer:addChild(btnMenu)
    btnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    btnMenu:setBSwallowsTouches(true)
    btnMenu:setPositionY(menuPosY+subAddH)

    local freeItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",callback1,nil,getlocal("activity_wmzz_btn",{1}),btnLbStrSize/btnScale)
    local freeBtn=CCMenu:createWithItem(freeItem)
    freeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    self.freeItem=freeItem
    freeItem:setScale(btnScale)
    freeBtn:setPosition(G_VisibleSizeWidth/2-80-freeItem:getContentSize().width*(freeItem:getScale())/2,menuPosY)
    self.bgLayer:addChild(freeBtn)
    freeBtn:setPositionY(menuPosY+subAddH)

    local costLbPosY=90
    self.costLb={}
    for i=1,2 do
        local costNum=acWmzzVoApi:getCostByType(i)
        local costLb=GetTTFLabel(costNum .. "  ",25/btnScale)
        costLb:setAnchorPoint(ccp(0,0.5))
        menuItem[i]:addChild(costLb)
        self.costLb[i]=costLb

        if i==1 then
            local freeLb = GetTTFLabel(getlocal("daily_lotto_tip_2"), 25/btnScale)
            freeLb:setPosition(ccp(menuItem[i]:getContentSize().width/2, costLbPosY))
            freeLb:setColor(G_ColorGreen)
            freeItem:addChild(freeLb)
            self.freeLb=freeLb
        end

        local goldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
        goldIcon:setAnchorPoint(ccp(0,0.5))
        goldIcon:setPosition(costLb:getContentSize().width,costLb:getContentSize().height/2)
        costLb:addChild(goldIcon,1)
        goldIcon:setScale(1/btnScale)

        costLb:setPosition(menuItem[i]:getContentSize().width/2-(costLb:getContentSize().width+goldIcon:getContentSize().width)/2,costLbPosY)
    end
    self:refreshCostLb()


end

function acWmzzDialog:refreshCostLb()
    if self.freeLb then
        if acWmzzVoApi:isDailyFree()==0 then
            self.freeLb:setVisible(true)
            self.costLb[1]:setVisible(false)
            self.freeItem:setVisible(true)
            self.freeItem:setEnabled(true)
            self.menuItem1:setVisible(false)
            self.menuItem1:setEnabled(false)
            self.menuItem2:setEnabled(false)
        else
            self.freeLb:setVisible(false)
            self.costLb[1]:setVisible(true)
            self.freeItem:setVisible(false)
            self.freeItem:setEnabled(false)
            self.menuItem1:setVisible(true)
            self.menuItem1:setEnabled(true)
            self.menuItem2:setEnabled(true)
        end
        -- 设置颜色
        local cost1=acWmzzVoApi:getCostByType(1)
        local cost2=acWmzzVoApi:getCostByType(2)
        local gems=playerVoApi:getGems() or 0
        if cost1>gems then
            self.costLb[1]:setColor(G_ColorRed)
        else
            self.costLb[1]:setColor(G_ColorWhite)
        end
        if cost2>gems then
            self.costLb[2]:setColor(G_ColorRed)
        else
            self.costLb[2]:setColor(G_ColorWhite)
        end
    end
end
function acWmzzDialog:refreshZheZhao()
    local fragT=acWmzzVoApi:getFragT()
    local flag=true
    local miniNum=fragT.f1 or 0
    for k,v in pairs(self.zheZhaoTb) do
        local num=fragT["f" .. k] or 0
        self.numLbTb[k]:setString("x" .. num)
        if num<miniNum then
            miniNum=num
        end
        if num>0 then
            v:setVisible(false)
        else
            v:setVisible(true)
            flag=false
        end
    end
    self.composeItem:setEnabled(flag)
    local cfg=acWmzzVoApi:getCfg()
    local tankId=tonumber(cfg.tankId) or tonumber(RemoveFirstChar(cfg.tankId))
    local name=getlocal(tankCfg[tankId].name)

    self.composeNum=math.floor(miniNum/cfg.partToTank)
    self.composeDes:setString(getlocal("activity_wmzz_zz_des",{self.composeNum,name}))
end

function acWmzzDialog:resertJoint()
    self.joint2:stopAllActions()
    self.joint3:stopAllActions()
    self.joint3:removeAllChildrenWithCleanup(true)

    self.joint2:setRotation(-90)
    self.joint3:setRotation(180)
end

function acWmzzDialog:runaction(reward,iscrit)
    local indexTb={}
    for k,v in pairs(reward) do
        local index=tonumber(k) or tonumber(RemoveFirstChar(k))
        table.insert(indexTb,index)
    end
    local NmoveY=self.joint1:getPositionY()
    local fragT=acWmzzVoApi:getFragT()

    local function recurse(index,recurseNum)
        -- 移动,上旋转，下旋转
        local acArr=CCArray:create()
        local targetPos
        local targetR1
        local targetR2
        if index==1 then
            targetPos=ccp(40,NmoveY)
            targetR1=-90
            targetR2=90
        elseif index==2 then
            targetPos=ccp(150,NmoveY)
            targetR1=-90
            targetR2=90
        elseif index==3 then
            targetPos=ccp(290,NmoveY)
            targetR1=-90
            targetR2=90
        elseif index==4 then
            targetPos=ccp(50,NmoveY)
            targetR1=-60
            targetR2=60
        elseif index==5 then
            targetPos=ccp(170,NmoveY)
            targetR1=-60
            targetR2=60
        elseif index==6 then
            targetPos=ccp(310,NmoveY)
            targetR1=-60
            targetR2=60
        elseif index==7 then
            targetPos=ccp(140,NmoveY)
            targetR1=-15
            targetR2=15
        elseif index==8 then
            targetPos=ccp(280,NmoveY)
            targetR1=-15
            targetR2=15
        elseif index==9 then
            targetPos=ccp(420,NmoveY)
            targetR1=-15
            targetR2=15
        end
        
        local yuanX=self.joint1:getPositionX()
        local time1=math.abs(yuanX-targetPos.x)/400

        local yuanR1=self.joint2:getRotation()
        local time2=math.abs(yuanR1-targetR1)/300

        local yuanR2=self.joint3:getRotation()
        local time3=math.abs(yuanR2-targetR2)/300

        local function callback1()
            local moveTo=CCMoveTo:create(time1,targetPos)
            self.joint1:runAction(moveTo)
        end
        local function callback2()
            local rotateTo1=CCRotateTo:create(time2, targetR1)
            self.joint2:runAction(rotateTo1)
        end
        local function callback3()
            local rotateTo2=CCRotateTo:create(time3, targetR2)
            self.joint3:runAction(rotateTo2)
        end
        local function callback4()

            -- 火花
            local pzFrameName="VSTop1.png" --动画
            local vsPzSp=CCSprite:createWithSpriteFrameName(pzFrameName)
            vsPzSp:setScale(2)
            self.joint3:addChild(vsPzSp)
            vsPzSp:setPosition(self.joint3:getContentSize().width/2,-5)

            local pzArr=CCArray:create()
            for kk=1,6 do
                local nameStr="VSTop"..kk..".png"
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                pzArr:addObject(frame)
            end
            local animation=CCAnimation:createWithSpriteFrames(pzArr)
            animation:setDelayPerUnit(0.05)
            local animate=CCAnimate:create(animation)
            local function sbRemove()
                vsPzSp:removeFromParentAndCleanup(true)
            end
            local function Remove()
                -- vsPzSp:removeFromParentAndCleanup(true)

                -- local num=fragT["f" .. index] or 0
                -- self.numLbTb[index]:setString("x" .. num)
                self.zheZhaoTb[index]:setVisible(false)

                -- local function scaleAc()
                local subArray=CCArray:create()

                local function subCallback1()
                    local blink = CCBlink:create(0.6,2)
                    self.zheZhaoTb[index]:runAction(blink)
                end
                local subCallFunc1=CCCallFunc:create(subCallback1)
                subArray:addObject(subCallFunc1)
                local subdelay1=CCDelayTime:create(0.6)
                subArray:addObject(subdelay1)

                local num=1
                -- if iscrit then
                --     local cfg=acWmzzVoApi:getCfg()
                --     local vipMulti=cfg.vipMulti
                --     local vip=playerVoApi:getVipLevel() or 0
                --     num=vipMulti[vip] or vipMulti[#vipMulti]
                -- end
                for i=1,num do
                    local function sbScaleFunc()
                        local num=fragT["f" .. index] or 0
                        self.numLbTb[index]:setString("x" .. num)
                    end
                    local sbScaleCallback=CCCallFunc:create(sbScaleFunc)
                    local scaleTo1=CCScaleTo:create(0.1,1.5)
                    local scaleTo2=CCScaleTo:create(0.1,1)
                    subArray:addObject(scaleTo1)
                    subArray:addObject(sbScaleCallback)
                    subArray:addObject(scaleTo2)
                end 
                
                    -- return subArray
                -- end

                local function subCallback2()
                    if recurseNum~=#indexTb then
                        recurse(indexTb[recurseNum+1],recurseNum+1)
                    else
                        -- self:refreshZheZhao()
                        -- self.bgLayer:stopAllActions()
                        -- self:resertJoint()
                        self:endAction()
                    end
                end
                if recurseNum==#indexTb then
                    local subdelay=CCDelayTime:create(0.3)
                    subArray:addObject(subdelay)
                end
                local subCallFunc2=CCCallFunc:create(subCallback2)
                subArray:addObject(subCallFunc2)

                local seq = CCSequence:create(subArray)
                self.numLbTb[index]:runAction(seq)
            end
            local  sbRe=CCCallFuncN:create(sbRemove)
            local  pzSeq=CCSequence:createWithTwoActions(animate,sbRe)
            vsPzSp:runAction(pzSeq)
            local  animEnd=CCCallFuncN:create(Remove)
            vsPzSp:runAction(animEnd)

            
        end
        local delay1=CCDelayTime:create(time1)
        local delay2=CCDelayTime:create(time2)
        local delay3=CCDelayTime:create(time3)

        local callFunc1=CCCallFunc:create(callback1)
        local callFunc2=CCCallFunc:create(callback2)
        local callFunc3=CCCallFunc:create(callback3)
        local callFunc4=CCCallFunc:create(callback4)
        acArr:addObject(callFunc1)
        acArr:addObject(delay1)
        acArr:addObject(callFunc2)
        acArr:addObject(delay2)
        acArr:addObject(callFunc3)
        acArr:addObject(delay3)
        acArr:addObject(callFunc4)
        local seq=CCSequence:create(acArr)
        self.bgLayer:runAction(seq)
    end
    recurse(indexTb[1],1)
end

function acWmzzDialog:endAction()
    self.joint1:stopAllActions()
    self.joint2:stopAllActions()
    self.joint3:stopAllActions()

    for k,v in pairs(self.zheZhaoTb) do
        v:stopAllActions()
    end
    for k,v in pairs(self.numLbTb) do
        v:stopAllActions()
    end

    self.touchDialogBg:setPosition(100000,100000)
    self.state=0
    self:refreshZheZhao()
    -- self:scaleAction()
    self.bgLayer:stopAllActions()
    self:resertJoint()

    local tabStr={getlocal("daily_lotto_tip_10")}
    for k,v in pairs(self.reward) do
        table.insert(tabStr,"[ " .. getlocal("activity_wmzz_frag",{RemoveFirstChar(k)}) .. " ]" .. " x" .. v)
    end
    require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
    tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("BossBattle_lookReward"),tabStr)
    -- self.reward=nil
    -- self.iscrit=nil
end

function acWmzzDialog:scaleAction()
    local num=1
    if self.iscrit then
        local cfg=acWmzzVoApi:getCfg()
        local vipMulti=cfg.vipMulti
        local vip=playerVoApi:getVipLevel() or 0
        num=vipMulti[vip] or vipMulti[#vipMulti]
    end

    local fragT=acWmzzVoApi:getFragT()

    local function scaleAc(fp,index)
        local acArr=CCArray:create()
        for i=1,num do
            local function setNumFunc()
                local fgNum=fragT[fp]-self.reward[fp]+self.reward[fp]/num*i
                self.numLbTb[index]:setString("x" .. fgNum)
            end
            local callFunc=CCCallFunc:create(setNumFunc)
            acArr:addObject(callFunc)
            local scaleTo1=CCScaleTo:create(0.2,1.5)
            local scaleTo2=CCScaleTo:create(0.2,1)
            acArr:addObject(scaleTo1)
            acArr:addObject(scaleTo2)
            local delay=CCDelayTime:create(0.05)
            acArr:addObject(delay)

        end 
        return acArr
    end

    for k,v in pairs(self.reward) do
        local index=tonumber(k) or tonumber(RemoveFirstChar(k))
        local seq = CCSequence:create(scaleAc(k,index))
        self.numLbTb[index]:runAction(seq)
    end
    
    
end

function acWmzzDialog:tick()
    local acVo = acWmzzVoApi:getAcVo()
    if activityVoApi:isStart(acVo)==true then
        if not G_isToday(acVo.lastTime) then
            acWmzzVoApi:refreshClear()
            self:refreshCostLb()
        end
        if self.messageLabel then
            if acVo then
                G_updateActiveTime(acVo,self.messageLabel)
            end
        end
    else
        self:close()
        do return end
    end
end

function acWmzzDialog:fastTick()
    if self.state==3 then
        self:endAction()
    end      
end

function acWmzzDialog:dispose()
    spriteController:removePlist("public/acWmzzImage.plist")
    spriteController:removeTexture("public/acWmzzImage.png")
    spriteController:removePlist("public/acOpenyearImage.plist")
    spriteController:removeTexture("public/acOpenyearImage.png")
    spriteController:removePlist("serverWar/serverWar.plist")
    spriteController:removeTexture("serverWar/serverWar.pvr.ccz")
    if self.secondDialog then
        self.secondDialog:close()
    end
end