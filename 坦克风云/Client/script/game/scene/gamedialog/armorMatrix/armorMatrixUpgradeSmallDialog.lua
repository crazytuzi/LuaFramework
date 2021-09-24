armorMatrixUpgradeSmallDialog=smallDialog:new()

function armorMatrixUpgradeSmallDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.btnScale1=160/205

    return nc
end

function armorMatrixUpgradeSmallDialog:init(id,tankPos,layerNum,isShowBtn)

    self.layerNum=layerNum
    self.tankPos=tankPos
    self.id=id
    local mid,level=armorMatrixVoApi:getMidAndLevelById(id)
    local cfg=armorMatrixVoApi:getCfgByMid(mid)


    local function touchHandler()
    
    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),touchHandler)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg

    local bgWidth,bgHeight=550,635
    -- if isShowBtn==true then
    --     bgWidth,bgHeight=550,450
    -- end
    self.bgSize=CCSizeMake(bgWidth,bgHeight)
    self.bgLayer:setContentSize(self.bgSize)
    self:show()


    local function touchDialog()
      
    end
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    -- self:userHandler()

    -- title 背景
    local titleBgSp=CCSprite:createWithSpriteFrameName("groupSelf.png")
    titleBgSp:setAnchorPoint(ccp(0.5,1))
    titleBgSp:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-20));
    titleBgSp:setScaleY(60/titleBgSp:getContentSize().height)
    titleBgSp:setScaleX(800/titleBgSp:getContentSize().width)
    self.bgLayer:addChild(titleBgSp)
    titleBgSp:setOpacity(0)

    -- title lb
    local nameStr=getlocal(cfg.name)
    local nameLb=GetTTFLabelWrap(nameStr,35,CCSizeMake(self.bgSize.width-160,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.bgLayer:addChild(nameLb)
    nameLb:setPosition(self.bgSize.width/2,self.bgSize.height-50)
    local color=armorMatrixVoApi:getColorByQuality(cfg.quality)
    nameLb:setColor(color)

    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    closeBtnItem:setPosition(ccp(0,0))
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))
     
    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,2)

    local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSprite:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgSize.height-85))
    self.bgLayer:addChild(lineSprite,1)
    lineSprite:setScaleX((self.bgSize.width-60)/lineSprite:getContentSize().width)

    local startH=self.bgSize.height-100
    local function touchIconFunc()
    end
    local iconSp=armorMatrixVoApi:getArmorMatrixIcon(mid,100,90,touchIconFunc,level)
    -- CCSprite:createWithSpriteFrameName("equipBg_blue.png")
    self.bgLayer:addChild(iconSp)
    iconSp:setAnchorPoint(ccp(0,0.5))
    iconSp:setPosition(30,startH-60)
    local scale=120/iconSp:getContentSize().width
    self.scale=scale
    iconSp:setScale(scale)
    self.iconSp=iconSp

    local lb=tolua.cast(iconSp:getChildByTag(2001),"CCLabelTTF")
    if(lb)then
        lb:setScale(1/scale)
    end
    local lvBg=tolua.cast(iconSp:getChildByTag(2002),"CCSprite")
    if(lvBg)then
        lvBg:setScaleX((iconSp:getContentSize().width-20)/lvBg:getContentSize().width*1/scale)
        lvBg:setScaleY(lb:getContentSize().height/lvBg:getContentSize().height*1/scale)
    end

    local lineSp=CCSprite:createWithSpriteFrameName("amPointLine.png")
    -- lineSp:setRotation(180)
    lineSp:setScaleX(1/scale*350/lineSp:getContentSize().width)
    iconSp:addChild(lineSp)
    lineSp:setAnchorPoint(ccp(0,0.5))
    lineSp:setPosition(120,iconSp:getContentSize().height/2)
    lineSp:setScaleY(1/scale)

    local attrStr,value=armorMatrixVoApi:getAttrAndValue(mid,level)
    local iconDesLb1=GetTTFLabel(attrStr,25)
    -- GetTTFLabelWrap(attrStr .. "+" .. value,25,CCSizeMake(self.bgSize.width-160,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
    iconDesLb1:setAnchorPoint(ccp(0,0.5))
    iconDesLb1:setPosition(120,iconSp:getContentSize().height/2+30)
    iconSp:addChild(iconDesLb1)
    iconDesLb1:setScale(1/scale)

    local valueLb=GetTTFLabel("+"..value.."%",25)
    valueLb:setAnchorPoint(ccp(0,0.5))
    valueLb:setPosition(ccp(iconDesLb1:getContentSize().width+10,iconDesLb1:getContentSize().height/2))
    iconDesLb1:addChild(valueLb,1)
    valueLb:setColor(G_ColorYellowPro)
    valueLb:setTag(10)
    self.iconDesLb1=iconDesLb1

    local iconDesLb2=GetTTFLabelWrap(getlocal("armorMatrix_deploy_des",{self.tankPos}),25,CCSizeMake(self.bgSize.width-220,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    iconDesLb2:setAnchorPoint(ccp(0,0.5))
    iconDesLb2:setPosition(120,iconSp:getContentSize().height/2-30)
    iconSp:addChild(iconDesLb2)
    iconDesLb2:setScale(1/scale)

    startH=startH-130

    local desBgH=100
    local function click(hd,fn,idx)
    end
    local desBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50,50,1,1),click)
    desBgSp:setContentSize(CCSizeMake(self.bgSize.width-60,desBgH))
    desBgSp:ignoreAnchorPointForPosition(false)
    desBgSp:setAnchorPoint(ccp(0.5,1))
    desBgSp:setPosition(ccp(self.bgSize.width/2,startH))
    self.bgLayer:addChild(desBgSp)

    -- cfg
    local descStr=armorMatrixVoApi:getDescByMid(mid,level)
    local desLb=GetTTFLabelWrap(descStr,25,CCSizeMake(desBgSp:getContentSize().width-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    desBgSp:addChild(desLb)
    desLb:setAnchorPoint(ccp(0,0.5))
    desLb:setPosition(15,desBgSp:getContentSize().height/2)

    startH=startH-desBgH-10

    local lineSp2=CCSprite:createWithSpriteFrameName("LineCross.png")
    self.bgLayer:addChild(lineSp2)
    -- lineSp2:setAnchorPoint(ccp(0,0.5))
    lineSp2:setPosition(self.bgSize.width/2,startH)
    lineSp2:setScaleX((bgWidth-60)/lineSp2:getContentSize().width)

    startH=startH

    local expBgH=90
    local function click(hd,fn,idx)
        if G_checkClickEnable()==false then
            do
                return
            end
        end

        local function fadeFunc()
            local function goBag()
                self:close()
                armorMatrixVoApi:showBagDialog(layerNum)
            end
            local function goRecruit()
                self:close()
                armorMatrixVoApi:showRecruitDialog(layerNum)
            end
            local infoTb={{title=getlocal("armorMatrix_exp_way1"),des=getlocal("armorMatrix_exp_way1_des"),callback=goBag,picFalg=2},{title=getlocal("armorMatrix_exp_way2"),des=getlocal("armorMatrix_exp_way2_des"),callback=goRecruit,picFalg=1}}

            armorMatrixVoApi:showGetExpDialog(layerNum+1,getlocal("armorMatrix_get_exp_way"),infoTb,true)
        end
        local fadeIn=CCFadeIn:create(0.2)
        local fadeOut=CCFadeOut:create(0.2)
        local callFunc=CCCallFuncN:create(fadeFunc)
        local acArr=CCArray:create()
        acArr:addObject(fadeIn)
        acArr:addObject(fadeOut)
        acArr:addObject(callFunc)
        local seq=CCSequence:create(acArr)
        self.expBgSp:runAction(seq)
    end
    local expBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png",CCRect(20, 20, 10, 10),click)
    expBgSp:setContentSize(CCSizeMake(self.bgSize.width-10,expBgH))
    expBgSp:ignoreAnchorPointForPosition(false)
    expBgSp:setAnchorPoint(ccp(0.5,0.5))
    expBgSp:setPosition(ccp(self.bgSize.width/2,startH-expBgH/2))
    self.bgLayer:addChild(expBgSp)
    expBgSp:setTouchPriority(-(layerNum-1)*20-2)
    expBgSp:setOpacity(0)
    self.expBgSp=expBgSp


    local expIcon=CCSprite:createWithSpriteFrameName("armorMatrixExp.png")
    expBgSp:addChild(expIcon)
    expIcon:setAnchorPoint(ccp(0,0.5))
    expIcon:setPosition(30,expBgSp:getContentSize().height/2)
    -- expIcon:setScale(0.5)

    local armorMatrixInfo=armorMatrixVoApi:getArmorMatrixInfo()
    local expLb=GetTTFLabelWrap(getlocal("ownedXp",{armorMatrixInfo.exp or 0}),25,CCSizeMake(expBgSp:getContentSize().width-240,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    expBgSp:addChild(expLb)
    expLb:setAnchorPoint(ccp(0,0.5))
    expLb:setPosition(130,expBgSp:getContentSize().height/2)
    self.expLb=expLb

    local function goAddExp()
        -- if G_checkClickEnable()==false then
        --     do return end
        -- else
        --     base.setWaitTime=G_getCurDeviceMillTime()
        -- end

        -- local function goBag()
        --     self:close()
        --     armorMatrixVoApi:showBagDialog(layerNum)
        -- end
        -- local function goRecruit()
        --     self:close()
        --     armorMatrixVoApi:showRecruitDialog(layerNum)
        -- end
        -- local infoTb={{title=getlocal("armorMatrix_exp_way1"),des=getlocal("armorMatrix_exp_way1_des"),callback=goBag,picFalg=2},{title=getlocal("armorMatrix_exp_way2"),des=getlocal("armorMatrix_exp_way2_des"),callback=goRecruit,picFalg=1}}

        -- armorMatrixVoApi:showGetExpDialog(layerNum+1,getlocal("armorMatrix_get_exp_way"),infoTb,true)
    end
    local addSp = LuaCCSprite:createWithSpriteFrameName("ProduceTankIconMore.png",goAddExp)
    addSp:setScale(1.5)
    addSp:setPosition(expBgSp:getContentSize().width-80,expBgSp:getContentSize().height/2)
    addSp:setTouchPriority(-(layerNum-1)*20-2)
    expBgSp:addChild(addSp)

    -- expBgH=60

    startH=startH-expBgH

    local lineSp3=CCSprite:createWithSpriteFrameName("LineCross.png")
    self.bgLayer:addChild(lineSp3)
    -- lineSp3:setAnchorPoint(ccp(0,0.5))
    lineSp3:setPosition(self.bgSize.width/2,startH)
    lineSp3:setScaleX((bgWidth-60)/lineSp3:getContentSize().width)

    startH=startH-20
    local strSize2 = 18
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        strSize2 =25
    end
    local wayLb=GetTTFLabelWrap(getlocal("armorMatrix_exp_get_des"),strSize2,CCSizeMake(self.bgSize.width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    -- wayLb:setAnchorPoint(ccp(0,0))
    wayLb:setPosition(self.bgSize.width/2,startH-wayLb:getContentSize().height/2)
    self.bgLayer:addChild(wayLb)
    
    local upgradeLevel,oneExp,totalExp=armorMatrixVoApi:canUpgradeMaxlevel(id)
    if not upgradeLevel then
        do return end
    end
    self.upgradeLevel=upgradeLevel
    self.oneExp=oneExp
    self.totalExp=totalExp

    -- hero_upgrade_x
    local menuPosY=70
    self.menuPosY=menuPosY
    menuItemTb={}
    local function upgradeFunc(tag)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local oldNum=playerVoApi:getPlayerPower()

        local function refreshCalback()

            local newNum=playerVoApi:getPlayerPower()
            G_showNumberChange(oldNum,newNum) -- 战斗力变化提示

            self.upgradeLevel,self.oneExp,self.totalExp=armorMatrixVoApi:canUpgradeMaxlevel(id)
            local mid,level=armorMatrixVoApi:getMidAndLevelById(id)

            local lb=tolua.cast(iconSp:getChildByTag(2001),"CCLabelTTF")
            if(lb)then
                lb:setString(getlocal("fightLevel",{level}))
            end
            local attrStr,value=armorMatrixVoApi:getAttrAndValue(mid,level)
            local valueLb=tolua.cast(self.iconDesLb1:getChildByTag(10),"CCLabelTTF")
            if valueLb then
                valueLb:setString("+"..value.."%")
            end
            

            self:refreshBtn()
            self:runUpgradeAc()

            -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("emblem_upgrade_success"),28)
           
        end
        local level=1
        if tag==1 then
            level=1
        else
            level=self.upgradeLevel
        end
        armorMatrixVoApi:armorUpgrade(id,level,refreshCalback)

        if otherGuideMgr.isGuiding and otherGuideMgr.curStep==30 then
            otherGuideMgr:toNextStep()
        end
    end
    local oneItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",upgradeFunc,1,getlocal("hero_upgrade_x",{1}),24/self.btnScale1)
    oneItem:setScale(self.btnScale1)
    local oneMenu=CCMenu:createWithItem(oneItem)
    oneMenu:setTouchPriority(-(layerNum-1)*20-4)
    self.bgLayer:addChild(oneMenu,1)
    oneMenu:setPosition(self.bgSize.width/2,menuPosY)
    menuItemTb[1]=oneItem
    self.oneMenu=oneMenu

    local childH=oneItem:getContentSize().height+25
    local expIcon1=CCSprite:createWithSpriteFrameName("armorMatrixExp.png")
    oneItem:addChild(expIcon1)
    expIcon1:setPositionY(childH)
    expIcon1:setAnchorPoint(ccp(0.5,0.5))
    expIcon1:setTag(21)
    -- expIcon1:setScale(0.5)
    expIcon1:setScale(0.5/self.btnScale1)

    local iconLb1=GetTTFLabel(oneExp,24/self.btnScale1)
    oneItem:addChild(iconLb1)
    iconLb1:setPositionY(childH)
    iconLb1:setAnchorPoint(ccp(0.5,0.5))
    iconLb1:setTag(22)
    self:setChildPosX(oneItem)


    if upgradeLevel==0 then
        oneItem:setEnabled(false)
    elseif upgradeLevel>1 then
        oneMenu:setPosition(self.bgSize.width/2-120,menuPosY)

        local xItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",upgradeFunc,2,getlocal("hero_upgrade_x",{upgradeLevel}),24/self.btnScale1,11)
        xItem:setScale(self.btnScale1)
        local xMenu=CCMenu:createWithItem(xItem)
        xMenu:setTouchPriority(-(layerNum-1)*20-4)
        self.bgLayer:addChild(xMenu,1)
        xMenu:setPosition(self.bgSize.width/2+120,menuPosY)
        menuItemTb[2]=xItem

        local expIcon2=CCSprite:createWithSpriteFrameName("armorMatrixExp.png")
        xItem:addChild(expIcon2)
        expIcon2:setPositionY(childH)
        expIcon2:setAnchorPoint(ccp(0.5,0.5))
        expIcon2:setTag(21)
        -- expIcon2:setScale(0.5)
        expIcon2:setScale(0.5/self.btnScale1)

        local iconLb2=GetTTFLabel(totalExp,24/self.btnScale1)
        xItem:addChild(iconLb2)
        iconLb2:setPositionY(childH)
        iconLb2:setAnchorPoint(ccp(0.5,0.5))
        iconLb2:setTag(22)
        self:setChildPosX(xItem)
        self.xMenu=xMenu
    end
    self.menuItemTb=menuItemTb


    local function touchLuaSpr()
        -- if self.isTouch~=nil then
        --     PlayEffect(audioCfg.mouseClick)
        --     self:close()
        -- end
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    --touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg,1)
    
    sceneGame:addChild(self.dialogLayer,layerNum)
    --self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:setPosition(ccp(0,0))

    if otherGuideMgr.isGuiding and otherGuideMgr.curStep==29 then
        otherGuideMgr:setGuideStepField(30,oneItem)
    end

    return self.dialogLayer
end

function armorMatrixUpgradeSmallDialog:refreshBtn()
    -- self.upgradeLevel,self.oneExp,self.totalExp
    local armorMatrixInfo=armorMatrixVoApi:getArmorMatrixInfo()
    self.expLb:setString(getlocal("ownedXp",{armorMatrixInfo.exp or 0}))

    if not self.upgradeLevel then -- 满级处理
        local posY=self.oneMenu:getPositionY()
        -- self.bgSize.width/2
        self.oneMenu:removeFromParentAndCleanup(true)
        if self.xMenu then
            self.xMenu:removeFromParentAndCleanup(true)
        end
        local maxLb=GetTTFLabelWrap(getlocal("armorMatrix_upgrade_max"),25,CCSizeMake(self.bgSize.width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        self.bgLayer:addChild(maxLb,2)
        maxLb:setPosition(self.bgSize.width/2,posY)
        maxLb:setColor(G_ColorYellowPro)
        return
    end
    if self.upgradeLevel<=1 then
        self.oneMenu:setPosition(self.bgSize.width/2,self.menuPosY)
        if self.upgradeLevel==0 then
            self.menuItemTb[1]:setEnabled(false)
        end
        if self.menuItemTb[2] then
            self.menuItemTb[2]:setEnabled(false)
            self.menuItemTb[2]:setVisible(false)
        end
    end
    if self.menuItemTb[1] then
        local costLb=tolua.cast(self.menuItemTb[1]:getChildByTag(22),"CCLabelTTF")
        if(costLb)then
            costLb:setString(self.oneExp)
        end
        self:setChildPosX(self.menuItemTb[1])
    end
    if self.menuItemTb[2] then
        local lb=tolua.cast(self.menuItemTb[2]:getChildByTag(11),"CCLabelTTF")
        if(lb)then
            lb:setString(getlocal("hero_upgrade_x",{self.upgradeLevel}))
        end
        local costLb=tolua.cast(self.menuItemTb[2]:getChildByTag(22),"CCLabelTTF")
        if(costLb)then
            costLb:setString(self.totalExp)
        end

        self:setChildPosX(self.menuItemTb[2])
    end
    
    
end

function armorMatrixUpgradeSmallDialog:runUpgradeAc()
    local iconSize=self.iconSp:getContentSize()
    local equipLine1 = CCParticleSystemQuad:create("public/hero/equipLine.plist")
    equipLine1:setPosition(ccp(iconSize.width/2,10))
    self.iconSp:addChild(equipLine1,3)
    local function removeLine1( ... )
        if equipLine1 then
            equipLine1:stopAllActions()
            equipLine1:removeFromParentAndCleanup(true)
            equipLine1=nil
            self.isPlaying=false
        end
    end
    local mvTo1=CCMoveTo:create(0.35,ccp(iconSize.width/2,100))
    local fc1= CCCallFunc:create(removeLine1)
    local carray1=CCArray:create()
    carray1:addObject(mvTo1)
    carray1:addObject(fc1)
    local seq1 = CCSequence:create(carray1)
    equipLine1:runAction(seq1)


    local equipStar1 = CCParticleSystemQuad:create("public/hero/equipStar.plist")
    equipStar1:setPosition(ccp(iconSize.width/2,10))
    self.iconSp:addChild(equipStar1,3)
    equipStar1:setAutoRemoveOnFinish(true) 

    local function removeLine2( ... )
        if equipStar1 then
            equipStar1:stopAllActions()
            equipStar1:removeFromParentAndCleanup(true)
            equipStar1=nil
            
        end
    end
    local mvTo2=CCMoveTo:create(0.5,ccp(iconSize.width/2,100))
    local fc2= CCCallFunc:create(removeLine2)
    local carray2=CCArray:create()
    carray2:addObject(mvTo2)
    carray2:addObject(fc2)
    local seq2 = CCSequence:create(carray2)
    equipStar1:runAction(seq2)

    -- self.iconDesLb1
    local scaleTo1 = CCScaleTo:create(0.15,1/self.scale*2)
    local scaleTo2 = CCScaleTo:create(0.15,1/self.scale*1)
    local carray=CCArray:create()
    carray:addObject(scaleTo1)
    carray:addObject(scaleTo2)
    local seq=CCSequence:create(carray)
    self.iconDesLb1:runAction(seq)
end

function armorMatrixUpgradeSmallDialog:setChildPosX(parent)
    local child1=parent:getChildByTag(21)
    local child2=parent:getChildByTag(22)
    local pwidth=parent:getContentSize().width/2
    local width1=child1:getContentSize().width*child1:getScaleX()
    local width2=child2:getContentSize().width*child2:getScaleX()
    child1:setPositionX(pwidth-width2/2)
    child2:setPositionX(pwidth+width1/2)
end

function armorMatrixUpgradeSmallDialog:dispose()
    self.upgradeLevel=nil
    self.oneExp=nil
    self.totalExp=nil
    self.menuItemTb=nil
end


