armorMatrixInfoSmallDialog=smallDialog:new()

function armorMatrixInfoSmallDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.btnScale1=140/205

    spriteController:addPlist("public/armorMatrixEffect.plist")
    spriteController:addTexture("public/armorMatrixEffect.png")
    
    return nc
end

-- 传id  或者 （rewardMid,level） 其中一个就行
-- rewardMid,level  前台奖励格式不知道id 传 rewardMid,level
function armorMatrixInfoSmallDialog:init(id,layerNum,isShowBtn,rewardMid,level,isNewUI)
    self.layerNum=layerNum

    local tankPos,index=armorMatrixVoApi:getEquipedPos(id)
    local mid,lv
    if id then
        mid,lv=armorMatrixVoApi:getMidAndLevelById(id)
    else
        mid=rewardMid
        lv=level
    end
    

    local cfg=armorMatrixVoApi:getCfgByMid(mid)
    if tankPos==nil or index==nil then
        isShowBtn=false
    end

    local function touchHandler()
    
    end
    local dialogBg
    if isNewUI then
        dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg1.png",CCRect(30, 30, 1, 1),touchHandler)
    else
        dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),touchHandler)
    end
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg

    local bgWidth,bgHeight=550,320
    if isShowBtn==true then
        bgWidth,bgHeight=550,380
    end
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

    if isNewUI then
        local lineSp1=CCSprite:createWithSpriteFrameName("rewardPanelLine.png")
        lineSp1:setAnchorPoint(ccp(0.5,1))
        lineSp1:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height))
        self.bgLayer:addChild(lineSp1)
        local lineSp2=CCSprite:createWithSpriteFrameName("rewardPanelLine.png")
        lineSp2:setAnchorPoint(ccp(0.5,0))
        lineSp2:setPosition(ccp(self.bgLayer:getContentSize().width/2,lineSp2:getContentSize().height))
        self.bgLayer:addChild(lineSp2)
        lineSp2:setRotation(180)

        local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
        pointSp1:setPosition(ccp(5,self.bgLayer:getContentSize().height/2))
        self.bgLayer:addChild(pointSp1)
        local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
        pointSp2:setPosition(ccp(self.bgLayer:getContentSize().width-5,self.bgLayer:getContentSize().height/2))
        self.bgLayer:addChild(pointSp2)
    end
    
    if isShowBtn==true then
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
    end


    local posy=self.bgLayer:getContentSize().height-50
    local titleLb = GetTTFLabel(getlocal(cfg.name),35)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,posy-5))
    self.bgLayer:addChild(titleLb,1)
    local color=armorMatrixVoApi:getColorByQuality(cfg.quality)
    titleLb:setColor(color)
    -- local titleBg=CCSprite:createWithSpriteFrameName("groupSelf.png")
    -- titleBg:setPosition(ccp(self.bgLayer:getContentSize().width/2+20,posy-5))
    -- titleBg:setScaleY((titleLb:getContentSize().height+20)/titleBg:getContentSize().height)
    -- titleBg:setScaleX(self.bgSize.width/titleBg:getContentSize().width)
    -- self.bgLayer:addChild(titleBg)

    posy=posy-40
    local lineSprite
    if isNewUI then
        lineSprite = LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png",CCRect(27,3,1,1),function ()end)
        lineSprite:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,lineSprite:getContentSize().height))
    else
        lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
    end
    lineSprite:setPosition(ccp(self.bgLayer:getContentSize().width/2,posy))
    self.bgLayer:addChild(lineSprite,1)
    lineSprite:setScaleX((self.bgSize.width-100)/lineSprite:getContentSize().width)


    posy=posy-100
    -- local iconSp=CCSprite:createWithSpriteFrameName("pro_ship_attack.png")
    local function clickHandler( ... )
    end
    local iconSp=armorMatrixVoApi:getArmorMatrixIcon(mid,130,150,clickHandler,lv)
    -- iconSp:setScale(150/iconSp:getContentSize().width)
    iconSp:setPosition(ccp(100,posy))
    self.bgLayer:addChild(iconSp,1)
    armorMatrixVoApi:addLightEffect(iconSp, mid)
    local bg=tolua.cast(iconSp:getChildByTag(2002),"CCSprite")
    local lb=tolua.cast(iconSp:getChildByTag(2001),"CCLabelTTF")
    local lbScale=0.8
    if bg then
        bg:setScaleX((lb:getContentSize().width*lbScale+30)/bg:getContentSize().width)
        bg:setScaleY((lb:getContentSize().height*lbScale+5)/bg:getContentSize().height)
        bg:setPositionY(bg:getPositionY()-2)
    end
    if lb then
        lb:setScale(lbScale)
    end
    

    local attrStr,value=armorMatrixVoApi:getAttrAndValue(mid,lv)
    local attrLb=GetTTFLabel(attrStr,25)
    attrLb:setAnchorPoint(ccp(0,0.5))
    attrLb:setPosition(ccp(140+50,posy+65-5))
    self.bgLayer:addChild(attrLb,1)
    local valueLb=GetTTFLabel("+"..value.."%",25)
    valueLb:setAnchorPoint(ccp(0,0.5))
    valueLb:setPosition(ccp(attrLb:getPositionX()+attrLb:getContentSize().width+10,posy+65-5))
    self.bgLayer:addChild(valueLb,1)
    valueLb:setColor(G_ColorYellowPro)

    local lineSp
    if isNewUI then
        lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png",CCRect(27,3,1,1),function ()end)
        lineSp:setContentSize(CCSizeMake(300,lineSp:getContentSize().height))
    else
        lineSp=CCSprite:createWithSpriteFrameName("amPointLine.png")
    end
    -- local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("heroRecruitLine.png",CCRect(73, 4, 1, 1),function ()end)
    -- lineSp:setRotation(180)
    -- lineSp:setScaleX(350/lineSp:getContentSize().width)
    -- lineSp:setContentSize(CCSizeMake(350,lineSp:getContentSize().height))
    lineSp:setAnchorPoint(ccp(0,0.5))
    lineSp:setPosition(ccp(140+50,posy+35-15))
    self.bgLayer:addChild(lineSp,1)

    local upgradeLevel,_,_=id and armorMatrixVoApi:canUpgradeMaxlevel(id) or nil
    local descStr
    if id and (not upgradeLevel) then
        if cfg.quality==4 then
            descStr=getlocal("armorMatrix_fullLevel_canBreakThrough")
        else
            descStr=getlocal("armorMatrix_full_level")
        end
    else
        descStr=armorMatrixVoApi:getDescByMid(mid,lv)
    end
    local descLb=GetTTFLabelWrap(descStr,25,CCSizeMake(330,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    descLb:setAnchorPoint(ccp(0,0.5))
    descLb:setPosition(ccp(140+50,posy-35))
    self.bgLayer:addChild(descLb,1)


    if isShowBtn==true then
        local posy=60
        local btnScale=self.btnScale1
        --卸下按钮
        local function onRemove()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            local isFull=armorMatrixVoApi:bagIsOver(1)
            if isFull==true then
                local function onConfirm()
                    self:close()
                    armorMatrixVoApi:showBagDialog(self.layerNum)
                end
                smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("armorMatrix_bag_full"),nil,self.layerNum+1)
                do return end
            end

            local function armorRemoveCallback( ... )
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_takeoff_success"),30)
            end
            local mid=armorMatrixVoApi:getEquipedData(tankPos,index)
            if mid then
                local cfg=armorMatrixVoApi:getCfgByMid(mid)
                if cfg and cfg.part then
                    local line,id,pos=tankPos,nil,cfg.part
                    armorMatrixVoApi:armorUsedAndRemove(line,id,pos,armorRemoveCallback)
                end
            end
            self:close()
        end
        local strSize2 = 35
        if G_getCurChoseLanguage() =="de" then
            strSize2 = 28
        end
        local removeItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onRemove,nil,getlocal("accessory_unware"),strSize2)
        removeItem:setScale(btnScale)
        local removeMenu=CCMenu:createWithItem(removeItem)
        removeMenu:setTouchPriority(-(layerNum-1)*20-4)
        removeMenu:setAnchorPoint(ccp(0.5,0.5))
        removeMenu:setPosition(ccp(100,posy))
        self.bgLayer:addChild(removeMenu,1)
        
        --更换按钮
        local function onChange()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            armorMatrixVoApi:showSelectDialog(tankPos,index,layerNum)
            self:close()
        end
        local changeItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onChange,nil,getlocal("armorMatrix_change"),24/btnScale)
        changeItem:setScale(btnScale)
        local changeMenu=CCMenu:createWithItem(changeItem)
        changeMenu:setTouchPriority(-(layerNum-1)*20-4)
        changeMenu:setAnchorPoint(ccp(0.5,0.5))
        changeMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,posy))
        self.bgLayer:addChild(changeMenu,1)
        if tankPos and index then
            local armors=armorMatrixVoApi:hasBetterTb(tankPos)
            if armors and armors[index] and armors[index]==1 then
                local newsTip=LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",CCRect(17, 17, 1, 1),function ()end)
                newsTip:setScale(0.8)
                newsTip:setPosition(ccp(changeItem:getContentSize().width-15,changeItem:getContentSize().height-15))
                changeItem:addChild(newsTip,9)
            end
        end

        local isCanBreakThrough = armorMatrixVoApi:isCanBreakThrough(id)
        --升级按钮
        local function onUpgrade()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            if isCanBreakThrough == true then
                armorMatrixVoApi:showBreakThroughSmallDialog(id,tankPos,layerNum+1)
                self:close()
            else
                local upgradeLevel,_,_=armorMatrixVoApi:canUpgradeMaxlevel(id)
                if not upgradeLevel then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("armorMatrix_upgrade_max"),30)
                    return
                end
                if cfg.quality==5 then
                    armorMatrixVoApi:showBreakThroughSmallDialog(id,tankPos,layerNum+1,true)
                else
                    armorMatrixVoApi:showUpgradeSmallDialog(id,tankPos,layerNum+1,isShowBtn)
                end
                self:close()

                if otherGuideMgr.isGuiding and otherGuideMgr.curStep==29 then
                    otherGuideMgr:toNextStep()
                end
            end
        end
        local itemStr = getlocal("upgradeBuild")
        if isCanBreakThrough == true then
            itemStr = getlocal("breakthrough")
        end
        local upgradeItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",onUpgrade,nil,itemStr,24/btnScale)
        upgradeItem:setScale(btnScale)
        local upgradeMenu=CCMenu:createWithItem(upgradeItem)
        upgradeMenu:setTouchPriority(-(layerNum-1)*20-4)
        upgradeMenu:setAnchorPoint(ccp(0.5,0.5))
        upgradeMenu:setPosition(ccp(self.bgLayer:getContentSize().width-100,posy))
        self.bgLayer:addChild(upgradeMenu,1)
        --如果是橙色矩阵，不能卸下，不能更换
        if cfg.quality==5 then
            removeItem:setEnabled(false)
            removeItem:setVisible(false)
            changeItem:setEnabled(false)
            changeItem:setVisible(false)
            upgradeMenu:setPositionX(self.bgSize.width / 2)
        end

        if otherGuideMgr.isGuiding and otherGuideMgr.curStep==28 then
            otherGuideMgr:setGuideStepField(29,upgradeItem)
        end        
    end


    local function touchLuaSpr()
        if isShowBtn==true then
        else
            PlayEffect(audioCfg.mouseClick)
            self:close()
        end
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    if isNewUI then
    else
        touchDialogBg:setOpacity(180)
    end
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    --touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg,1)

    --点击屏幕继续
    if isNewUI then
        local clickLbPosy=-80
        local tmpLb=GetTTFLabel(getlocal("click_screen_continue"),25)
        local clickLb=GetTTFLabelWrap(getlocal("click_screen_continue"),25,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        clickLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,clickLbPosy))
        self.bgLayer:addChild(clickLb)
        local arrowPosx1,arrowPosx2
        local realWidth,maxWidth=tmpLb:getContentSize().width,clickLb:getContentSize().width
        if realWidth>maxWidth then
            arrowPosx1=self.bgLayer:getContentSize().width/2-maxWidth/2
            arrowPosx2=self.bgLayer:getContentSize().width/2+maxWidth/2
        else
            arrowPosx1=self.bgLayer:getContentSize().width/2-realWidth/2
            arrowPosx2=self.bgLayer:getContentSize().width/2+realWidth/2
        end
        local smallArrowSp1=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
        smallArrowSp1:setPosition(ccp(arrowPosx1-15,clickLbPosy))
        self.bgLayer:addChild(smallArrowSp1)
        local smallArrowSp2=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
        smallArrowSp2:setPosition(ccp(arrowPosx1-25,clickLbPosy))
        self.bgLayer:addChild(smallArrowSp2)
        smallArrowSp2:setOpacity(100)
        local smallArrowSp3=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
        smallArrowSp3:setPosition(ccp(arrowPosx2+15,clickLbPosy))
        self.bgLayer:addChild(smallArrowSp3)
        smallArrowSp3:setRotation(180)
        local smallArrowSp4=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
        smallArrowSp4:setPosition(ccp(arrowPosx2+25,clickLbPosy))
        self.bgLayer:addChild(smallArrowSp4)
        smallArrowSp4:setOpacity(100)
        smallArrowSp4:setRotation(180)

        local space=20
        smallArrowSp1:runAction(G_actionArrow(1,space))
        smallArrowSp2:runAction(G_actionArrow(1,space))
        smallArrowSp3:runAction(G_actionArrow(-1,space))
        smallArrowSp4:runAction(G_actionArrow(-1,space))
    end
    
    sceneGame:addChild(self.dialogLayer,layerNum)
    --self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end

function armorMatrixInfoSmallDialog:dispose()
    self = nil
    spriteController:removePlist("public/armorMatrixEffect.plist")
    spriteController:removeTexture("public/armorMatrixEffect.png")
end
