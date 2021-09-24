planeSkillInfoSmallDialog=smallDialog:new()

function planeSkillInfoSmallDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    return nc
end

-- 传id  或者 （rewardMid,level） 其中一个就行
-- rewardMid,level  前台奖励格式不知道id 传 rewardMid,level
function planeSkillInfoSmallDialog:init(sid,layerNum,isShowBtn,planeVo,pos,activeFlag)
    self.layerNum=layerNum
    self.nameFontSize=25
    self.infoFontSize=22
    local scfg,gcfg=planeVoApi:getSkillCfgById(sid)

    local function touchHandler()
    
    end
    local dialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("newSmallPanelBg.png",CCRect(170,80,22,10),touchHandler)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    local bgWidth,bgHeight=550,350
    if isShowBtn==true then
        bgWidth,bgHeight=550,410
    end
    self.bgSize=CCSizeMake(bgWidth,bgHeight)
    self.bgLayer:setContentSize(self.bgSize)
    self:show()

    local titleBg=CCSprite:createWithSpriteFrameName("newTitleBg.png")
    titleBg:setAnchorPoint(ccp(0.5,1))
    titleBg:setPosition(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height)
    dialogBg:addChild(titleBg)
    local titleLb=GetTTFLabelWrap(getlocal("skill_detail_title"),28,CCSizeMake(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb:setPosition(getCenterPoint(titleBg))
    titleBg:addChild(titleLb)

    local function touchDialog()
      
    end
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    -- self:userHandler()
    
    if isShowBtn==true then
        local function close()
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            return self:close()
        end
        local closeBtnItem = GetButtonItem("newCloseBtn.png","newCloseBtn_Down.png","newCloseBtn.png",close,nil,nil,nil);
        closeBtnItem:setPosition(ccp(0,0))
        closeBtnItem:setAnchorPoint(CCPointMake(0,0))
         
        self.closeBtn = CCMenu:createWithItem(closeBtnItem)
        self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
        self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width-4,self.bgSize.height-closeBtnItem:getContentSize().height-4))
        self.bgLayer:addChild(self.closeBtn,2)
    end

    self.skillInfoH=200
    local function nilFunc()
    end
    local skillBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),nilFunc)
    skillBg:setAnchorPoint(ccp(0.5,1))
    skillBg:setContentSize(CCSizeMake(self.bgSize.width-30,self.skillInfoH))
    skillBg:setPosition(self.bgSize.width/2,self.bgSize.height-100)
    self.bgLayer:addChild(skillBg)

    local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
    pointSp1:setPosition(ccp(2,skillBg:getContentSize().height/2))
    skillBg:addChild(pointSp1)
    local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
    pointSp2:setPosition(ccp(skillBg:getContentSize().width-2,skillBg:getContentSize().height/2))
    skillBg:addChild(pointSp2)
    local lightSp=CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
    lightSp:setAnchorPoint(ccp(0.5,0))
    lightSp:setScaleX(2)
    lightSp:setPosition(skillBg:getContentSize().width/2,skillBg:getContentSize().height-2)
    skillBg:addChild(lightSp)

    local attrValue, isUseRichText
    if pos == 5 then --战机改装中新增的5号位技能槽
        local isUnlockSlot, unlockAttrValue, unlockSkillId = planeRefitVoApi:isUnlockPlaneSkillSlot(planeVo.pid)
        if isUnlockSlot == true then
            attrValue = unlockAttrValue
            isUseRichText = true
        end
    end
    local nameStr,descStr,typeStr,privilegeStr=planeVoApi:getSkillInfoById(sid, nil, isUseRichText, attrValue)
    local nameLb=GetTTFLabelWrap(nameStr,self.nameFontSize,CCSizeMake(320,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
    nameLb:setAnchorPoint(ccp(0.5,0.5))
    nameLb:setColor(G_ColorYellowPro)
    nameLb:setPosition(self.bgSize.width/2,self.bgSize.height-100+nameLb:getContentSize().height/2)
    self.bgLayer:addChild(nameLb)
    local nameLb2=GetTTFLabel(nameStr,self.nameFontSize)
    local realNameW=nameLb2:getContentSize().width
    if realNameW>nameLb:getContentSize().width then
        realNameW=nameLb:getContentSize().width
    end
    for i=1,2 do
        local pointSp=CCSprite:createWithSpriteFrameName("newPointRect.png")
        local anchorX=1
        local posX=self.bgSize.width/2-(realNameW/2+20)
        local pointX=-7
        if i==2 then
            anchorX=0
            posX=self.bgSize.width/2+(realNameW/2+20)
            pointX=15
        end
        pointSp:setAnchorPoint(ccp(anchorX,0.5))
        pointSp:setPosition(posX,nameLb:getPositionY())
        self.bgLayer:addChild(pointSp)

        local pointLineSp=CCSprite:createWithSpriteFrameName("newPointLine.png")
        pointLineSp:setAnchorPoint(ccp(0,0.5))
        pointLineSp:setPosition(pointX,pointSp:getContentSize().height/2)
        pointSp:addChild(pointLineSp)
        if i==1 then
            pointLineSp:setRotation(180)
        end
    end

    local function clickHandler( ... )
    end
    local iconSp=planeVoApi:getSkillIcon(sid,100,clickHandler)
    iconSp:setPosition(ccp(70,skillBg:getContentSize().height/2+15))
    skillBg:addChild(iconSp,1)
    -- 装备强度
    local scfg,gcfg=planeVoApi:getSkillCfgById(sid)
    local strong=gcfg.skillStrength or 0
    if attrValue then
        strong = math.floor(strong * attrValue)
    end
    local strongLb=GetTTFLabelWrap(getlocal("skill_power",{strong}),self.infoFontSize,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    strongLb:setAnchorPoint(ccp(0.5,1))
    strongLb:setColor(G_ColorYellowPro)
    strongLb:setPosition(ccp(iconSp:getPositionX(),iconSp:getPositionY()-iconSp:getContentSize().height/2-10))
    skillBg:addChild(strongLb)

    local leftPosX=150
    local typeLb=GetTTFLabelWrap(typeStr,self.infoFontSize,CCSizeMake(320,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    typeLb:setAnchorPoint(ccp(0,1))
    typeLb:setPosition(leftPosX,self.skillInfoH-30)
    skillBg:addChild(typeLb)
    local py=typeLb:getPositionY()-typeLb:getContentSize().height
    local tvHeight=skillBg:getContentSize().height-typeLb:getContentSize().height-30
    if privilegeStr then
        py=py-5
        local privilegeLb=GetTTFLabelWrap(privilegeStr,self.infoFontSize,CCSizeMake(320,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        privilegeLb:setAnchorPoint(ccp(0,1))
        privilegeLb:setPosition(leftPosX,py)
        skillBg:addChild(privilegeLb)
        py=py-privilegeLb:getContentSize().height
        tvHeight=tvHeight-privilegeLb:getContentSize().height-5
    end
    py=py-10
    local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png",CCRect(26,0,2,6),nilFunc)
    lineSp:setContentSize(CCSizeMake(320,6))
    lineSp:setAnchorPoint(ccp(0,0.5))
    lineSp:setPosition(leftPosX,py)
    skillBg:addChild(lineSp,1)
    py=py-13
    tvHeight=tvHeight-32
    local descLb,cellHeight
    if isUseRichText then
        descLb, descLbHeight = G_getRichTextLabel(descStr, {nil, G_ColorYellowPro, nil}, self.infoFontSize, 330, kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
        descLb:setAnchorPoint(ccp(0, 0.5))
        cellHeight = descLbHeight
    else
        descLb=GetTTFLabelWrap(descStr,self.infoFontSize,CCSizeMake(330,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        cellHeight=descLb:getContentSize().height
    end
    local tvWidth=350
    local function eventHandler(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return 1
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize
            tmpSize=CCSizeMake(tvWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            if isUseRichText then
                local descLb, descLbHeight = G_getRichTextLabel(descStr, {nil, G_ColorYellowPro, nil}, self.infoFontSize, 330, kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
                descLb:setAnchorPoint(ccp(0, 0.5))
                descLb:setPosition(0, cellHeight)
                cell:addChild(descLb)
            else
                local descLb=GetTTFLabelWrap(descStr,self.infoFontSize,CCSizeMake(350,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                descLb:setAnchorPoint(ccp(0,1))
                descLb:setPosition(0,cellHeight)
                cell:addChild(descLb)
            end

            return cell
        elseif fn=="ccTouchBegan" then
            self.isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            self.isMoved=true
        elseif fn=="ccTouchEnded"  then
        end
    end
    local function callBack(...)
        return eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth,tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(leftPosX,py-tvHeight))
    if cellHeight>tvHeight then
        self.tv:setMaxDisToBottomOrTop(80)
    else
        self.tv:setMaxDisToBottomOrTop(0)
    end
    skillBg:addChild(self.tv)

    if isShowBtn==true then
        local posy=60
        local btnScale=0.8
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

            -- local isFull=planeVoApi:bagIsOver(1)
            -- if isFull==true then
            --     local function onConfirm()
            --         self:close()
            --         planeVoApi:showBagDialog(self.layerNum)
            --     end
            --     smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("armorMatrix_bag_full"),nil,self.layerNum+1)
            --     do return end
            -- end

            local function skillRemoveCallback( ... )
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_takeoff_success"),30)
            end
            if activeFlag==nil then
                activeFlag=false
            end
            if planeVo and pos and activeFlag~=nil then
                local equipFlag,sid=planeVo:isSkillSlotEquiped(pos,activeFlag)
                planeVoApi:skillEquipOrRemoveRequest(2,planeVo,pos,sid,activeFlag,skillRemoveCallback)
            end
            self:close()
        end
        local removeItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",onRemove,nil,getlocal("accessory_unware"),25/btnScale)
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
            if planeVo then
                planeVoApi:showSelectDialog(planeVo,pos,activeFlag,self.layerNum+1)
            end
            self:close()
        end
        local changeItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",onChange,nil,getlocal("armorMatrix_change"),25/btnScale)
        changeItem:setScale(btnScale)
        local changeMenu=CCMenu:createWithItem(changeItem)
        changeMenu:setTouchPriority(-(layerNum-1)*20-4)
        changeMenu:setAnchorPoint(ccp(0.5,0.5))
        changeMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,posy))
        self.bgLayer:addChild(changeMenu,1)
        local betterFlag=planeVoApi:hasBetterEquip(planeVo.pid,sid,activeFlag)
        if betterFlag==true then
            local newsTip=LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",CCRect(17,17,1,1),function ()end)
            newsTip:setScale(0.8)
            newsTip:setPosition(ccp(changeItem:getContentSize().width-15,changeItem:getContentSize().height-15))
            changeItem:addChild(newsTip,9)
        end

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

            -- local upgradeLevel,_,_=planeVoApi:canUpgradeMaxlevel(id)
            -- if not upgradeLevel then
            --     smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("armorMatrix_upgrade_max"),30)
            --     return
            -- end
            local isMax
            local maxLv
            local scfg,gcfg=planeVoApi:getSkillCfgById(sid)
            if(gcfg and gcfg.color==4)then
                maxLv=playerVoApi:getMaxLvByKey("pskillUpgrade4Lv")
            else
                maxLv=playerVoApi:getMaxLvByKey("pskillUpgrade5Lv")
            end
            if(maxLv and maxLv>0 and gcfg and gcfg.lv and gcfg.lv>=maxLv)then
                isMax=true
            else
                isMax=false
            end
            if isMax and isMax==true then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage12108"),30)   
                do return end
            end
            local upgradeFlag=planeVoApi:isSkillCanUpgrade(sid)
            if upgradeFlag==false then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("plane_skill_upgrade_diable"),30)   
                do return end
            end
            planeVoApi:showUpgradeDialog(sid,self.layerNum+1,planeVo,pos,activeFlag)
            self:close()
        end
        local upgradeItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",onUpgrade,nil,getlocal("upgradeBuild"),25/btnScale)
        upgradeItem:setScale(btnScale)
        local upgradeMenu=CCMenu:createWithItem(upgradeItem)
        upgradeMenu:setTouchPriority(-(layerNum-1)*20-4)
        upgradeMenu:setAnchorPoint(ccp(0.5,0.5))
        upgradeMenu:setPosition(ccp(self.bgLayer:getContentSize().width-100,posy))
        self.bgLayer:addChild(upgradeMenu,1)
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
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)
    
    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end

