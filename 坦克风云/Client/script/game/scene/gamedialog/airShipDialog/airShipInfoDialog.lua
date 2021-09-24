airShipInfoDialog = commonDialog:new()

function airShipInfoDialog:new(layerNum, parent)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.layerNum = layerNum
    
    self.dialogWidth = G_VisibleSizeWidth
    self.dialogHeight = G_VisibleSizeHeight
    self.realHeight = self.dialogHeight - 80
    self.parent = parent
    G_addResource8888(function()
    end)
    
    self.curAirShipId = airShipVoApi:getCurShowAirShip()
    self.shipBtnIdxTb = {} -- 飞艇按钮当前位置的 index
    self.shipSliderBgTb = {}
    self.shipSelTb = {}
    self.shipBtnPos = {}
    self.shipBtnLbTb = {}
    self.tShipEquipBtnTb = {}--运输船装置按钮表
    self.bShipEquipBtnTb = {}--战斗船装置按钮表
    self.tipSpTb = {}
    self.selectAirShipSpTb = {}
    self.airShipSpTb = {}
    self.bShipEquipBtnTb2 = {}
    self.tShipEquipBtnTb2 = {}
    self.bShipEquipIconTb = {}
    self.tShipEquipIconTb = {}
    self.gzQualitySpTb = {}
    self.btnQualitySpTb = {}
    self.equipRedTipTb, self.btnRedTipTb = {}, {}
    return nc
end

function airShipInfoDialog:dispose()
    if self.propsRefreshListener then
        eventDispatcher:removeEventListener("airship.props.refresh", self.propsRefreshListener)
        self.propsRefreshListener = nil
    end
    if self.strengthRefreshListener then
        eventDispatcher:removeEventListener("airship.strength.refresh", self.strengthRefreshListener)
        self.strengthRefreshListener = nil
    end
    spriteController:removePlist("public/airShipImage3.plist")
    spriteController:removeTexture("public/airShipImage3.png")

    spriteController:removePlist("public/airShipImage6.plist")
    spriteController:removeTexture("public/airShipImage6.png")
    spriteController:removePlist("public/airShipImage7.plist")
    spriteController:removeTexture("public/airShipImage7.png")

    if self.parent and self.parent.closeCallBack then
        self.parent.closeCallBack()
    end
    self.parent = nil
    self.bgLayer:stopAllActions()
    self.shipBtnPos = nil
    self.shipSliderBgTb = nil
    self.shipSelTb = nil
    self.shipBtnIdxTb = nil
    self.shipBtnLbTb = nil
    self.tShipEquipBtnTb = nil
    self.bShipEquipBtnTb = nil
    self.editingNameStr = nil
    self.tipSpTb = nil
    self.selectAirShipSpTb = nil
    self.airShipSpTb = nil
    self.bShipEquipBtnTb2 = nil
    self.tShipEquipBtnTb2 = nil
    self.lockAirShipTb = nil
    self.gzQualitySpTb = nil
    self.btnQualitySpTb = nil
    self.activationEquipBtn = nil
    self.bShipEquipIconTb = nil
    self.tShipEquipIconTb = nil
    if self.pageObj then
        self.pageObj:dispose()
    end
end

function airShipInfoDialog:initTableView()
    self.panelLineBg:setVisible(false)
    self.panelShadeBg:setVisible(true)
    self.panelTopLine:setVisible(true)
    self.topShadeBg:setVisible(false)
    self.panelTopLine:setPositionY(G_VisibleSizeHeight - 80)
    self.panelShadeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    
    --arpl_blackFillingBg
    local fillingBg = LuaCCScale9Sprite:createWithSpriteFrameName("arpl_blackFillingBg.png", CCRect(2, 2, 1, 1), function() end)
    fillingBg:setContentSize(CCSizeMake(self.dialogWidth, self.realHeight))
    fillingBg:setAnchorPoint(ccp(0.5, 1))
    fillingBg:setPosition(self.dialogWidth * 0.5, self.realHeight)
    self.bgLayer:addChild(fillingBg)
    
    local lockBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function() end)
    lockBgSp:setContentSize(CCSizeMake(self.dialogWidth, self.realHeight - 150))
    lockBgSp:setAnchorPoint(ccp(0.5, 1))
    lockBgSp:setPosition(self.dialogWidth * 0.5, self.realHeight)
    lockBgSp:setTouchPriority(-(self.layerNum - 1) * 20 - 100)
    lockBgSp:setOpacity(255 * 0.8)
    lockBgSp:setIsSallow(true)
    self.lockBgSp = lockBgSp
    self.bgLayer:addChild(lockBgSp, 100)
    local lockTipLb = GetTTFLabelWrap(getlocal("airShip_unlock_tip"), 25, CCSizeMake(G_VisibleSizeWidth - 40, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    lockTipLb:setColor(G_ColorRed)
    lockTipLb:setPosition(getCenterPoint(lockBgSp))
    lockBgSp:addChild(lockTipLb)
    self.lockTipLb = lockTipLb
    
    local isUnlock = airShipVoApi:isUnlockCurAirShip(self.curAirShipId)
    if isUnlock then
        lockBgSp:setVisible(false)
        lockBgSp:setPosition(9999, 9999)
    end
    
    --对进面板默认选中的飞艇做解锁红点提示的处理
    if airShipVoApi:isUnlockCurAirShip(self.curAirShipId) == true and airShipVoApi:getTip(1) == 1 then
        airShipVoApi:saveTip(1, {aid = self.curAirShipId, tipv = 0})
    end
    
    self:initUp()
    
    self:initAirShipInfo()
    
    self:initSlideBtn()
    
    self:initAirShip()
    
    local function propsRefresh(event, data)
        if self == nil or self.bgLayer == nil or tolua.cast(self.bgLayer, "LuaCCScale9Sprite") == nil then
            do return end
        end
        if self.isOpenBattlePanel ~= true then --当前打开的不是战斗属性面板而是装置激活改造面板，则需要刷新消耗的道具数量
            self:refreshData("asEquip")
            if data and data.cmd == "material" then --在该页面合成或者分解零件后需要刷新红点提示
                self:refreshData("equipRedTip") --刷新装置红点提示
                self:refreshSlideBtn({aid = self.curAirShipId}) --刷新飞艇解锁状态提示
            end
        end
    end
    
    self.propsRefreshListener = propsRefresh
    eventDispatcher:addEventListener("airship.props.refresh", self.propsRefreshListener)
    
    local function strengthRefresh(event, data)
        if self == nil or self.bgLayer == nil or tolua.cast(self.bgLayer, "LuaCCScale9Sprite") == nil then
            do return end
        end
        self:refreshSlideBtn(data) --刷新飞艇解锁状态
        if self.parent and self.parent.refreshAirShipTip then
            self.parent:refreshAirShipTip()
        end
    end
    
    self.strengthRefreshListener = strengthRefresh
    eventDispatcher:addEventListener("airship.strength.refresh", self.strengthRefreshListener)
    if self.curAirShipId ~= 1 then
        otherGuideMgr:endGuideStep(90)
    else
        if otherGuideMgr.isGuiding then
            otherGuideMgr:setGuideStepField(96, self.tShipEquipBtnTb[1], true, nil, {panlePos = ccp(10, G_VisibleSizeHeight - 700), mx = 40, my = 10})
            
        end
    end
end

function airShipInfoDialog:initUp()
    local upBg = CCSprite:createWithSpriteFrameName("arpl_devicePanelUpBg.png")
    local upBgWidth = upBg:getContentSize().width
    local upBgHeight = upBg:getContentSize().height
    upBg:setAnchorPoint(ccp(0.5, 1))
    upBg:setPosition(self.dialogWidth * 0.5, self.realHeight)
    self.bgLayer:addChild(upBg, 1)
    self.upBg = upBg
    self.upBgWidth = upBgWidth
    self.upBgHeight = upBgHeight
    
    self.middleTopPosy = self.realHeight - upBgHeight
    local usePosY2 = self.realHeight - upBgHeight * 0.5
    
    local upBg2 = CCSprite:createWithSpriteFrameName("arpl_deviceUpAcPic.png")
    upBg2:setPosition(self.dialogWidth * 0.5, usePosY2)
    self.bgLayer:addChild(upBg2)
    local upBgRotate = CCRotateBy:create(20, 360)
    local repeatUpBgRotate = CCRepeatForever:create(upBgRotate)
    upBg2:runAction(repeatUpBgRotate)
    
    self:initDeviceBtn()
    self:initShipName()
end
function airShipInfoDialog:initShipName()
    local editTargetBox = LuaCCScale9Sprite:createWithSpriteFrameName("arpl_nameBg.png", CCRect(11, 11, 1, 1), function ()
        
    end)
    editTargetBox:setContentSize(CCSizeMake(260, 44))
    editTargetBox:setAnchorPoint(ccp(0.5, 1))
    editTargetBox:setPosition(self.upBgWidth * 0.5, self.upBgHeight - 3)
    editTargetBox:setIsSallow(false)
    editTargetBox:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    
    self.upBg:addChild(editTargetBox)
    self.targetBoxLabel = GetTTFLabel("", 24)
    self.targetBoxLabel:setAnchorPoint(ccp(0.5, 0.5))
    self.targetBoxLabel:setPosition(ccp(130, editTargetBox:getContentSize().height * 0.5))
    
    local customEditBox = customEditBox:new()
    local function callBackTargetHandler(fn, eB, str)
        if str == nil then
            do return end
        end
        self.editingNameStr = str
    end
    local function checkRenameHandler()
        if airShipVoApi:isCanRename(self.curAirShipId, nil, false) == false then --不满足重命名条件
            return true
        end
        self.editingNameStr = airShipVoApi:getAirshipNameById(self.curAirShipId, true)
        self.targetBoxLabel:setString(self.editingNameStr)
        self.nameEditBox:setText(self.editingNameStr)
        return false
    end
    local function nameInputEndHandler()
        if airShipVoApi:isCanRename(self.curAirShipId, self.editingNameStr) == false then --不满足重命名条件
            self:resetAirshipNameShow()
            return true
        end
        
        local nameStr, postfix = airShipVoApi:splitAirshipNameById(self.curAirShipId)
        nameStr = self.editingNameStr..postfix
        self.targetBoxLabel:setString(nameStr)
        self.nameEditBox:setText(nameStr)

        return false
    end
    self.nameEditBox = customEditBox:init(editTargetBox, self.targetBoxLabel, "arpl_nameBg.png", nil, -(self.layerNum - 1) * 20 - 3, 8, callBackTargetHandler, nil, nil, nil, checkRenameHandler, nil, nil, nameInputEndHandler, nil, true)
    
    self:resetAirshipNameShow()
    
    local function setCurAirShipShowHandl()
        airShipVoApi:setCurShowAirShip(self.curAirShipId)
        
        eventDispatcher:dispatchEvent("baseBuilding.build.refresh", {btype = 18})
    end
    local shipIcon = G_createBotton(self.upBg, ccp(self.upBgWidth * 0.5 - 155, self.upBgHeight - 3 - 22), nil, "airship_changeBtn.png", "airship_changeBtn_down.png", "airship_changeBtn.png", setCurAirShipShowHandl, 1, -(self.layerNum - 1) * 20 - 3)
    
    local btnScale, priority = 1, -(self.layerNum - 1) * 20 - 3
    local btnPos = ccp(self.upBgWidth * 0.5 + 135, self.upBgHeight - 3 - 22)
    local function shipRenameHandl()
        local function renameSucessHandl()
            G_showTipsDialog(getlocal("airShip_sucRenameTip"))
            self:resetAirshipNameShow() --设置成功后刷新名称
        end
        local flag = airShipVoApi:socketShipRename(renameSucessHandl, self.curAirShipId, self.editingNameStr)
        if flag == false then --此次输入名称失败，重置为原来的名称
            self:resetAirshipNameShow()
        end
    end
    local renameBtn = G_createBotton(self.upBg, btnPos, nil, "arpl_chgNameBtn1.png", "arpl_chgNameBtn2.png", "arpl_chgNameBtn2.png", shipRenameHandl, btnScale, priority, nil)
    renameBtn:setAnchorPoint(ccp(0, 0.5))
end

--重置飞艇的名称
function airShipInfoDialog:resetAirshipNameShow()
    if self.targetBoxLabel and self.nameEditBox then
        local nameStr = airShipVoApi:getAirshipNameById(self.curAirShipId)
        self.targetBoxLabel:setString(nameStr)
        self.nameEditBox:setText(nameStr)
        self.editingNameStr = nameStr
    end
end

function airShipInfoDialog:reuseBtnAnimate(isNew, movPosx)
    local yellowLightSp = CCSprite:createWithSpriteFrameName("arpl_equipBtnYellowOpenStatus.png")
    local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
    blendFunc.src = GL_ONE
    blendFunc.dst = GL_ONE
    yellowLightSp:setBlendFunc(blendFunc)
    
    yellowLightSp:setOpacity(0)
    local posx = movPosx > 0 and 133 * 0.5 + 82 or 9 + 133 * 0.5
    local posy = 30 + 46 * 0.5
    yellowLightSp:setPosition(posx, posy)
    if movPosx < 0 then
        yellowLightSp:setFlipX(true)
    end
    
    local yFadeIn = CCFadeIn:create(0.03)
    local yFadeOut = CCFadeOut:create(0.17)
    local function removeyellowSp()
        yellowLightSp:removeFromParentAndCleanup(true)
        yellowLightSp = nil
    end
    local yCallFun = CCCallFunc:create(removeyellowSp)
    local yArr = CCArray:create()
    yArr:addObject(yFadeIn)
    yArr:addObject(yFadeOut)
    yArr:addObject(yCallFun)
    local ySeq = CCSequence:create(yArr)
    
    local yBtnDeT = CCDelayTime:create(0.03)
    local yBtnFadeIn = CCFadeIn:create(0.04)
    local yBtnFadeOut = CCFadeOut:create(0.04)
    local yBtnArr = CCArray:create()
    yBtnArr:addObject(yBtnDeT)
    if isNew then
        yBtnArr:addObject(yBtnFadeIn)
    else
        yBtnArr:addObject(yBtnFadeOut)
    end
    local yBtnSeq = CCSequence:create(yBtnArr)
    
    local yIconArr = CCArray:create()
    yIconArr:addObject(CCDelayTime:create(0.03))
    if isNew then
        yIconArr:addObject(CCFadeIn:create(0.04))
    else
        yIconArr:addObject(CCFadeOut:create(0.04))
    end
    local yIconSeq = CCSequence:create(yIconArr)
    
    local yellowTipSp = CCSprite:createWithSpriteFrameName("arpl_clickYellowTip_1.png")
    local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
    blendFunc.src = GL_ONE
    blendFunc.dst = GL_ONE
    yellowTipSp:setBlendFunc(blendFunc)
    
    yellowTipSp:setPosition(posx, posy)
    yellowTipSp:setTag(11)
    
    local tipDet = CCDelayTime:create(0.42)
    local function repeatCall()
        local tipArr = CCArray:create()
        for kk = 1, 12 do
            local nameStr = "arpl_clickYellowTip_"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            tipArr:addObject(frame)
        end
        local tipAnimation = CCAnimation:createWithSpriteFrames(tipArr)
        tipAnimation:setDelayPerUnit(0.1)
        local animate = CCAnimate:create(tipAnimation)
        
        local det = CCDelayTime:create(3)
        local rArr = CCArray:create()
        rArr:addObject(animate)
        rArr:addObject(det)
        local rSeq = CCSequence:create(rArr)
        local rRepeat = CCRepeatForever:create(rSeq)
        yellowTipSp:runAction(rRepeat)
    end
    local rFuncc = CCCallFunc:create(repeatCall)
    local yArr = CCArray:create()
    yArr:addObject(tipDet)
    yArr:addObject(rFuncc)
    local yTipSeq = CCSequence:create(yArr)
    ------
    local yellowAnimtSp = CCSprite:createWithSpriteFrameName("arpl_equipBtnAnimt_1.png")
    local blendFunc = ccBlendFunc:new()--混合模式为 ONE ONE
    blendFunc.src = GL_ONE
    blendFunc.dst = GL_ONE
    yellowAnimtSp:setBlendFunc(blendFunc)
    
    -- yellowAnimtSp:setOpacity(0)
    yellowAnimtSp:setPosition(posx, posy)
    yellowAnimtSp:setTag(12)
    
    local aniDet = CCDelayTime:create(0.42)
    local function animateRepeatCall()
        local animtArr = CCArray:create()
        for kk = 1, 15 do
            local nameStr = "arpl_equipBtnAnimt_"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            animtArr:addObject(frame)
        end
        local btnAnimation = CCAnimation:createWithSpriteFrames(animtArr)
        btnAnimation:setDelayPerUnit(0.1)
        local animate = CCAnimate:create(btnAnimation)
        
        local spawnArr = CCArray:create()
        spawnArr:addObject(animate)
        local btnSpawn = CCSpawn:create(spawnArr)
        local btnRepeat = CCRepeatForever:create(btnSpawn)
        yellowAnimtSp:runAction(btnRepeat)
    end
    local yAniCall = CCCallFunc:create(animateRepeatCall)
    local aniArr = CCArray:create()
    aniArr:addObject(aniDet)
    aniArr:addObject(yAniCall)
    local aniSeq = CCSequence:create(aniArr)
    
    return yellowLightSp, ySeq, yBtnSeq, yIconSeq, yellowTipSp, yTipSeq, yellowAnimtSp, aniSeq
end

function airShipInfoDialog:changeDeviceBtnAnimate(isChangeBtn, newIdx, isCloseBtn)
    local isBattleShip = self.curAirShipId > 1 and true or false
    -- print("isCloseBtn====>>>",isCloseBtn)
    if isChangeBtn then
        local detT = CCDelayTime:create(0.1)
        local function unClickBgMovHandl()
            self.unClickUpbgSp:setPositionY(self.upBgHeight * 5.5)
        end
        local unClickBgCall = CCCallFunc:create(unClickBgMovHandl)
        -- print("isChangeBtn----newidx----isCloseBtn-----self.oldDeviceBtnIndex===>>>",isChangeBtn,newIdx,isCloseBtn,self.oldDeviceBtnIndex)
        if self.oldDeviceBtnIndex and (isCloseBtn or isCloseBtn == nil) then
            local oldIdx = self.oldDeviceBtnIndex
            local bIndexType = isBattleShip and 4 or 3
            local movPosx = oldIdx < bIndexType and - 70 or 70
            local movRun = CCMoveBy:create(0.4, ccp(movPosx, 0))
            local EaseOut = CCEaseElasticOut:create(movRun)
            
            local btnArr = CCArray:create()
            btnArr:addObject(EaseOut)
            if isCloseBtn or isCloseBtn == nil then
                btnArr:addObject(detT)
                btnArr:addObject(unClickBgCall)
            end
            local btnSeq = CCSequence:create(btnArr)
            if isBattleShip then
                local yellowTipSp = tolua.cast(self.bShipEquipBtnTb2[oldIdx]:getChildByTag(11), "CCSprite")
                if yellowTipSp then
                    yellowTipSp:stopAllActions()
                    yellowTipSp:removeFromParentAndCleanup(true)
                end
                local yellowAnimtSp = tolua.cast(self.bShipEquipBtnTb2[oldIdx]:getChildByTag(12), "CCSprite")
                if yellowAnimtSp then
                    yellowAnimtSp:stopAllActions()
                    yellowAnimtSp:removeFromParentAndCleanup(true)
                end
                self.bShipEquipBtnTb2[oldIdx]:stopAllActions()
                
                self.bShipEquipBtnTb[oldIdx]:runAction(btnSeq)
                self.bShipEquipBtnTb2[oldIdx]:setOpacity(0)
                self.bShipEquipIconTb[oldIdx]:stopAllActions()
                self.bShipEquipIconTb[oldIdx]:setOpacity(0)
            else
                local yellowTipSp = tolua.cast(self.tShipEquipBtnTb2[oldIdx]:getChildByTag(11), "CCSprite")
                if yellowTipSp then
                    yellowTipSp:stopAllActions()
                    yellowTipSp:removeFromParentAndCleanup(true)
                end
                local yellowAnimtSp = tolua.cast(self.tShipEquipBtnTb2[oldIdx]:getChildByTag(12), "CCSprite")
                if yellowAnimtSp then
                    yellowAnimtSp:stopAllActions()
                    yellowAnimtSp:removeFromParentAndCleanup(true)
                end
                self.tShipEquipBtnTb2[oldIdx]:stopAllActions()
                
                self.tShipEquipBtnTb[oldIdx]:runAction(btnSeq)
                self.tShipEquipBtnTb2[oldIdx]:setOpacity(0)
                self.tShipEquipIconTb[oldIdx]:stopAllActions()
                self.tShipEquipIconTb[oldIdx]:setOpacity(0)
            end
        end
        
        if isCloseBtn then
            do return end
        end
        
        if newIdx then
            local bIndexType = isBattleShip and 4 or 3
            local movPosx = newIdx < bIndexType and 70 or - 70
            local movRun = CCMoveBy:create(0.4, ccp(movPosx, 0))
            local EaseOut = CCEaseElasticOut:create(movRun)
            local btnArr = CCArray:create()
            btnArr:addObject(EaseOut)
            btnArr:addObject(detT)
            btnArr:addObject(unClickBgCall)
            local btnSeq = CCSequence:create(btnArr)
            if isBattleShip then
                self.bShipEquipBtnTb[newIdx]:runAction(btnSeq)
            else
                self.tShipEquipBtnTb[newIdx]:runAction(btnSeq)
            end
            
            local yellowLightSp, ySeq, yBtnSeq, yIconSeq, yellowTipSp, yTipSeq, yellowAnimtSp, aniSeq = self:reuseBtnAnimate(true, movPosx)
            yellowLightSp:runAction(ySeq)
            if isBattleShip then
                self.bShipEquipBtnTb2[newIdx]:addChild(yellowLightSp)
                self.bShipEquipBtnTb2[newIdx]:runAction(yBtnSeq)
                self.bShipEquipIconTb[newIdx]:runAction(yIconSeq)
                
                self.bShipEquipBtnTb2[newIdx]:addChild(yellowTipSp)
                yellowTipSp:runAction(yTipSeq)
                
                self.bShipEquipBtnTb2[newIdx]:addChild(yellowAnimtSp)
                yellowAnimtSp:runAction(aniSeq)
            else
                self.tShipEquipBtnTb2[newIdx]:addChild(yellowLightSp)
                self.tShipEquipBtnTb2[newIdx]:runAction(yBtnSeq)
                self.tShipEquipIconTb[newIdx]:runAction(yIconSeq)
                
                self.tShipEquipBtnTb2[newIdx]:addChild(yellowTipSp)
                yellowTipSp:runAction(yTipSeq)
                
                self.tShipEquipBtnTb2[newIdx]:addChild(yellowAnimtSp)
                yellowAnimtSp:runAction(aniSeq)
            end
            
        end
    else--切换飞艇 目前暂无动画
    end
end

function airShipInfoDialog:initDeviceBtn()
    local width, height = self.upBgWidth, self.upBgHeight
    local deviceBtnPos = {ccp(-70, height * 0.75), ccp(-70, height * 0.5), ccp(-70, height * 0.25), ccp(width + 70, height * 0.75), ccp(width + 70, height * 0.5), ccp(width + 70, height * 0.25)}
    self.deviceBtnPos = deviceBtnPos
    local function clickhandl(hd, fn, index)
        if G_checkClickEnable() == false then
            do return end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self.unClickUpbgSp:setPositionY(self.upBgHeight * 0.5)
        if not self.oldDeviceBtnIndex then
            self:changeDeviceBtnAnimate(true, index)
            self.oldDeviceBtnIndex = index
        elseif self.oldDeviceBtnIndex ~= index and not self.isOpenBattlePanel then
            self:changeDeviceBtnAnimate(true, index)
            self.oldDeviceBtnIndex = index
            self:refreshData("asEquip")
            do return end
        else
            local isCloseBtn = not self.isOpenBattlePanel
            self:changeDeviceBtnAnimate(true, index, isCloseBtn)
            self.oldDeviceBtnIndex = index
        end
        
        self:changeBattlePanelStatus("open")
        
        if self.curAirShipId == 1 and otherGuideMgr.isGuiding == true and otherGuideMgr.curStep == 96 then --引导激活生产装置
            otherGuideMgr:setGuideStepField(97, self.activationEquipBtn, false, nil, {panlePos = ccp(10, G_VisibleSizeHeight - 700)})
            otherGuideMgr:toNextStep()
        end
    end
    for i = 1, 6 do
        local deviceBtn = LuaCCSprite:createWithSpriteFrameName((i > 3) and "arpl_rdeviceBtn.png" or "arpl_ldeviceBtn.png", clickhandl)
        deviceBtn:setTag(i)
        deviceBtn:setPosition(deviceBtnPos[i])
        deviceBtn:setAnchorPoint(i < 4 and ccp(0, 0.5) or ccp(1, 0.5))
        deviceBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
        self.bShipEquipBtnTb[i] = deviceBtn
        self.upBg:addChild(deviceBtn, 5)
        
        local iconNormalSp = CCSprite:createWithSpriteFrameName("arpl_deviceicon_"..i.."_1.png")
        iconNormalSp:setPosition((i > 3) and 39.5 or deviceBtn:getContentSize().width - 39.5, deviceBtn:getContentSize().height - 38.5)
        deviceBtn:addChild(iconNormalSp)
        
        local deviceBtn2 = CCSprite:createWithSpriteFrameName((i > 3) and "arpl_rdeviceBtn_down.png" or "arpl_ldeviceBtn_down.png")
        deviceBtn2:setPosition(getCenterPoint(deviceBtn))
        deviceBtn:addChild(deviceBtn2)
        deviceBtn2:setOpacity(0)
        self.bShipEquipBtnTb2[i] = deviceBtn2
        
        local iconDownSp = CCSprite:createWithSpriteFrameName("arpl_deviceicon_"..i.."_2.png")
        iconDownSp:setPosition((i > 3) and 39.5 or deviceBtn2:getContentSize().width - 39.5, deviceBtn2:getContentSize().height - 38.5)
        iconDownSp:setTag(101)
        iconDownSp:setOpacity(0)
        deviceBtn2:addChild(iconDownSp)
        self.bShipEquipIconTb[i] = iconDownSp
        
        local devicebtnLb = GetTTFLabelWrap(getlocal("airShip_device2_"..i), G_isAsia() and 22 or 15, CCSizeMake(G_isAsia() and 74 or 82, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        devicebtnLb:setPosition( G_isAsia() and ( i < 4 and 132 or 95 ) or (i < 4 and 130 or 97), 52)
        deviceBtn:addChild(devicebtnLb, 10)
        
        if i < 5 then
            local deviceBtn = LuaCCSprite:createWithSpriteFrameName((i > 2) and "arpl_rdeviceBtn.png" or "arpl_ldeviceBtn.png", clickhandl)
            deviceBtn:setTag(i)
            deviceBtn:setPosition(deviceBtnPos[i])
            deviceBtn:setAnchorPoint(i < 3 and ccp(0, 0.5) or ccp(1, 0.5))
            deviceBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
            self.tShipEquipBtnTb[i] = deviceBtn
            self.upBg:addChild(deviceBtn, 5)
            
            local iconNormalSp = CCSprite:createWithSpriteFrameName("arpl_serviceicon_"..i.."_1.png")
            iconNormalSp:setPosition((i > 2) and 39.5 or deviceBtn:getContentSize().width - 39.5, deviceBtn:getContentSize().height - 38.5)
            deviceBtn:addChild(iconNormalSp)
            
            local deviceBtn2 = CCSprite:createWithSpriteFrameName((i > 2) and "arpl_rdeviceBtn_down.png" or "arpl_ldeviceBtn_down.png")
            deviceBtn2:setPosition(getCenterPoint(deviceBtn))
            deviceBtn:addChild(deviceBtn2)
            deviceBtn2:setOpacity(0)
            self.tShipEquipBtnTb2[i] = deviceBtn2
            
            local iconDownSp = CCSprite:createWithSpriteFrameName("arpl_serviceicon_"..i.."_2.png")
            iconDownSp:setPosition((i > 2) and 39.5 or deviceBtn2:getContentSize().width - 39.5, deviceBtn2:getContentSize().height - 38.5)
            iconDownSp:setTag(101)
            iconDownSp:setOpacity(0)
            deviceBtn2:addChild(iconDownSp)
            self.tShipEquipIconTb[i] = iconDownSp
            
            if i > 1 and i < 4 then
                deviceBtn:setPosition(deviceBtnPos[i + 1])
            elseif i == 4 then
                deviceBtn:setPosition(deviceBtnPos[6])
            end
            
            local devicebtnLb = GetTTFLabelWrap(getlocal("airShip_device1_"..i), G_isAsia() and 22 or 15, CCSizeMake(G_isAsia() and 74 or 82, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
            devicebtnLb:setPosition(G_isAsia() and ( i < 3 and 132 or 95 ) or (i < 3 and 130 or 97), 52)
            deviceBtn:addChild(devicebtnLb, 10)
        end
    end
    self:unClickBtnPanel()
    self:refreshData("equipBtn")
    self:refreshData("equipRedTip") --刷新装置按钮红点
    
    -----共振 入口
    local function resonanceClickHandl()
        require "luascript/script/game/scene/gamedialog/airShipDialog/airShipSmallDialog"
        airShipSmallDialog:showResonateOverviewDialog(self.curAirShipId, self.layerNum + 1)
    end
    local btnScale, priority = 1, -(self.layerNum - 1) * 20 - 3
    local rBtn = G_createBotton(self.upBg, ccp(width * 0.5, height - 65), nil, "arpl_lightBlueBtn1.png", "arpl_lightBlueBtn2.png", "arpl_lightBlueBtn1.png", resonanceClickHandl, btnScale, priority, nil)
    local btnLb = GetTTFLabel(getlocal("airShip_resonance"), G_isAsia() and 22 or 17 )--CCSizeMake(70, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    btnLb:setPosition(getCenterPoint(rBtn))
    if btnLb:getContentSize().width > 57 then btnLb:setScale(57 / btnLb:getContentSize().width) end
    rBtn:addChild(btnLb,10)
    self.rBtn = rBtn
    
    ----战术入口
    local function tacticClickHandl()
        local airShipCfg = airShipVoApi:getAirShipCfg()
        local airshipInfo = airShipVoApi:getCurAirShipInfo(self.curAirShipId) or {}
        local tLv = airShipVoApi:getTacticsFloorLvl(airshipInfo[2] or {}, airShipCfg.airship[self.curAirShipId].equipId)
        if tLv == nil or tLv <= 0 then --没有解锁战术
            G_showTipsDialog(getlocal("airShip_tactics_allnope"))
            do return end
        end
        require "luascript/script/game/scene/gamedialog/airShipDialog/airShipSmallDialog"
        airShipSmallDialog:showTacticsDialog(self.curAirShipId, self.layerNum + 1)
    end
    local tBtn = G_createBotton(self.upBg, ccp(width * 0.5, 62 + 22), nil, "arpl_lightBlueBtn1.png", "arpl_lightBlueBtn2.png", "arpl_lightBlueBtn1.png", tacticClickHandl, btnScale, priority, nil)
    self.tBtn = tBtn
    --airShip_tacticsCur
    
    self:refreshData("tactic")
    self:refreshData("showTwoBtn")
    self:refreshData("equipVar")
end
function airShipInfoDialog:initOrRefreshAirShipEquipPanel()
    if self.asEquipPanel then
        self.asEquipPanel:stopAllActions()
        self.asEquipPanel:removeFromParentAndCleanup(true)
        self.asEquipPanel = nil
        self.deviceBgSp = nil
    end
    self.equipKeyTb = {}
    local curAirShipId, curEquipIndex = self.curAirShipId, self.oldDeviceBtnIndex
    local asEqPnlHeigt = self.middleTopPosy - self.middleButtomPosy
    local asEqPnlWidth = self.dialogWidth
    local asEquipPanel = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function() end)
    asEquipPanel:setContentSize(CCSizeMake(asEqPnlWidth, asEqPnlHeigt))
    asEquipPanel:setAnchorPoint(ccp(0.5, 1))
    asEquipPanel:setOpacity(0)
    asEquipPanel:setPosition(asEqPnlWidth * 0.5, self.middleTopPosy)
    self.bgLayer:addChild(asEquipPanel, 2)
    self.asEquipPanel = asEquipPanel
    
    local downBgSp = CCSprite:createWithSpriteFrameName("arpl_devicePanelDownBg.png")
    downBgSp:setAnchorPoint(ccp(0.5, 1))
    downBgSp:setScaleX(asEqPnlWidth / downBgSp:getContentSize().width)
    downBgSp:setScaleY(asEqPnlHeigt / downBgSp:getContentSize().height)
    downBgSp:setPosition(asEqPnlWidth * 0.5, asEquipPanel:getContentSize().height)
    asEquipPanel:addChild(downBgSp)
    
    local eqTitleBg = CCSprite:createWithSpriteFrameName("believerTitleBg.png")
    eqTitleBg:setAnchorPoint(ccp(0.5, 1))
    eqTitleBg:setPosition(asEqPnlWidth * 0.5, asEqPnlHeigt)
    asEquipPanel:addChild(eqTitleBg)
    -- print("curAirShipId===curEquipIndex=====>>>",curAirShipId,curEquipIndex)
    local isUpgrade, equipPartsTb, curEquip, nextEquip = airShipVoApi:getCurAirShipEquipPartsTbWithIdx(curAirShipId, curEquipIndex)
    local titleStr, equipIconStr = airShipVoApi:getCurAirShipEquipName(curAirShipId, curEquipIndex)
    
    local eqTitleLb = GetTTFLabelWrap(titleStr, G_isAsia() and 22 or 18, CCSizeMake(340, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    eqTitleLb:setPosition(getCenterPoint(eqTitleBg))
    eqTitleBg:addChild(eqTitleLb)

    if airShipVoApi:getMyPhoneType( ) == 1 then
        eqTitleBg:setScale(0.64)
        eqTitleLb:setScale(1.2)
    end
    
    local deviceBgSp = CCSprite:createWithSpriteFrameName("arpl_deviceBg.png")
    deviceBgSp:setPosition(asEqPnlWidth * 0.5, asEqPnlHeigt * 0.5)
    asEquipPanel:addChild(deviceBgSp)
    self.deviceBgSp = deviceBgSp
    
    if self.curAirShipId ~= 1 then
        --飞艇属性生效类型(大小通用，坦克，歼击车，自行火炮，火箭车生效)
        local verType = kCCVerticalTextAlignmentTop
        local strSize2 = G_getLS(22,18)
        local sizeWidth = 520
        -- if airShipVoApi:getMyPhoneType() == 1 then
        --     verType = kCCVerticalTextAlignmentCenter
        --     strSize2 = G_getLS(17,15)
        --     sizeWidth = 220
        -- end
        local typeNameTb = {[1] = getlocal("tanke"), [2] = getlocal("jianjiche"), [4] = getlocal("zixinghuopao"), [8] = getlocal("huojianche"), [15] = getlocal("custom_planeSkill")}
        local asTypeStr = typeNameTb[airShipVoApi:getAirShipCfg().airship[self.curAirShipId].target]..getlocal("airShip_take_effect")
        local asTypeLb = GetTTFLabelWrap(asTypeStr, strSize2, CCSizeMake(sizeWidth, 0), kCCTextAlignmentCenter, verType)
        asTypeLb:setAnchorPoint(ccp(0.5, 1))
        asTypeLb:setPosition(asEqPnlWidth * 0.5, asEqPnlHeigt - eqTitleBg:getContentSize().height - 20)
        asEquipPanel:addChild(asTypeLb)

        if airShipVoApi:getMyPhoneType( ) == 1 then
            asTypeLb:setVisible(false)
            -- asTypeLb:setPositionY(eqTitleBg:getPositionY() - eqTitleBg:getContentSize().height * 0.5 * 0.64)
            -- asTypeLb:setPositionX(asEqPnlWidth * 0.16)
        -- else
        --     asTypeLb:setAnchorPoint(ccp(0.5, 1))
        end
    end
    local subPosy = airShipVoApi:getMyPhoneType() == 1 and -7 or 0
    local iconPosTb = {}
    if self.iconPosTb then
        iconPosTb = self.iconPosTb
    else
        iconPosTb = {ccp(asEqPnlWidth * 0.12, asEqPnlHeigt * 0.49), ccp(asEqPnlWidth * 0.265, asEqPnlHeigt * 0.31 + subPosy), ccp(asEqPnlWidth * 0.88, asEqPnlHeigt * 0.49), ccp(asEqPnlWidth * 0.732, asEqPnlHeigt * 0.31 + subPosy)}
        self.iconPosTb = iconPosTb
    end
    
    local function partsClickHandl(hd, fn, idx)
        -- print("idx====>>>",idx,self.equipKeyTb[idx])
        airShipVoApi:showRemakePropDialog(self.equipKeyTb[idx], nil, self.layerNum + 1)
    end
    
    for i = 1, 4 do
        local partsTb = equipPartsTb[i]
        -- print("partsTb=====>>>>",partsTb.key)
        local partsIcon = G_getItemIcon(partsTb, 100, nil, self.layerNum + 1, partsClickHandl)
        partsIcon:setPosition(iconPosTb[i])
        partsIcon:setTag(i)
        partsIcon:setScale(65 / partsIcon:getContentSize().width)
        partsIcon:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
        asEquipPanel:addChild(partsIcon)
        self.equipKeyTb[i] = partsTb.key
        
        if nextEquip then
            local curHasNum, costNum = partsTb.curHasNum, partsTb.num
            if curHasNum >= costNum then
                local numLb = GetTTFLabel(getlocal("oneKeyDonateFormat", {curHasNum, costNum}), 20)
                numLb:setAnchorPoint(ccp(0.5, 1))
                numLb:setPosition(partsIcon:getContentSize().width * 0.5, -2)
                numLb:setColor(G_ColorGreen)
                partsIcon:addChild(numLb)
            elseif curHasNum < costNum then
                local numLb, lbHeight = G_getRichTextLabel(getlocal("airShip_Progress1", {curHasNum, costNum}), {G_ColorWhite, G_ColorRed, G_ColorWhite}, 20, 150, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
                numLb:setAnchorPoint(ccp(0.5, 1))
                numLb:setPosition(partsIcon:getContentSize().width * 0.5, -2)
                partsIcon:addChild(numLb)
            end
        end
    end
    
    local btnStr = getlocal("activation")
    if nextEquip == nil then
        btnStr = getlocal("decorateMax")
    elseif curEquip then
        btnStr = getlocal("smelt")
    end
    local btnScale, priority ,btnPosY= 0.7, -(self.layerNum - 1) * 20 - 3, 60
    local btnStrSize2 = 25
    local newPosy,newSize = nil,19
    if airShipVoApi:getMyPhoneType( ) == 1 then
        btnScale = 0.42
        btnPosY = 35
        btnStrSize2 = 18
        newPosy = 8
        newSize = 15
    end

    if not nextEquip and not G_isAsia() then
        btnStrSize2 = 13
    end
    
    local function activationEquipHanedl()
        local airShipCfg = airShipVoApi:getAirShipCfg()
        local airShipInfo = airShipVoApi:getCurAirShipInfo(self.curAirShipId)
        local oldtLv = airShipVoApi:getTacticsFloorLvl(airShipInfo[2], airShipCfg.airship[self.curAirShipId].equipId)
        local oldcEffect = airShipVoApi:getCurAirShipEquipInfo(airShipInfo)
        local function activationEndHandl()
            local function animateEndCallBack()
                    self:refreshData("asEquip")
                    self:refreshData("tactic")
                    self:refreshData("equipVar", {equipIdx = self.oldDeviceBtnIndex}) --刷新装置品质
                    self:refreshData("equipRedTip") --刷新装置按钮红点
                    
                    if otherGuideMgr.isGuiding == true and otherGuideMgr.curStep == 97 then
                        otherGuideMgr:toNextStep()
                    end
                    
                    if self.curAirShipId == 1 then --运输艇没有战术和共振。故不需要做下面的处理
                        do return end
                    end
                    
                    local airShipInfo = airShipVoApi:getCurAirShipInfo(self.curAirShipId)
                    local stactLvl = airShipVoApi:getTacticsFloorLvl(airShipInfo[2], airShipCfg.airship[self.curAirShipId].equipId)
                    local combineEffect = airShipVoApi:getCurAirShipEquipInfo(airShipInfo)
                    
                    local tipArr = {}
                    if (oldcEffect[2] ~= combineEffect[2]) or (oldcEffect[4] ~= combineEffect[4]) then --共振发生变化
                        table.insert(tipArr, getlocal("airShip_resonance_changeTip"))
                    end
                    if stactLvl ~= oldtLv then --战术发生变化
                        table.insert(tipArr, getlocal("airShip_tactics_changeTip"))
                    end
                    local arr = CCArray:create()
                    for k, str in pairs(tipArr) do
                        if k ~= 1 then
                            arr:addObject(CCDelayTime:create(1.5))
                        end
                        arr:addObject(CCCallFunc:create(function ()
                            G_showTipsDialog(str)
                        end))
                    end
                    if arr:count() > 0 then
                        sceneGame:runAction(CCSequence:create(arr))
                    end
            end
            self:showEquipPartsUpdateSuccess(animateEndCallBack)
        end
        -- print("ready to activation Equip--->>>>", self.curAirShipId, self.oldDeviceBtnIndex)
        airShipVoApi:socketProduce(activationEndHandl, self.curAirShipId, self.oldDeviceBtnIndex)
    end
    local activationEquipBtn, activationEquipMenu = G_createBotton(asEquipPanel, ccp(asEqPnlWidth * 0.5, btnPosY), {btnStr, btnStrSize2}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", activationEquipHanedl, btnScale, priority, nil)
    activationEquipBtn:setEnabled(isUpgrade)
    self.activationEquipBtn = activationEquipBtn
    
    local flag = airShipVoApi:getTip(2, {aid = self.curAirShipId, equipIdx = self.oldDeviceBtnIndex})
    if flag > 0 then --该装置可以激活或改造
        local redTipSp = CCSprite:createWithSpriteFrameName("NumBg.png")
        redTipSp:setPosition(activationEquipBtn:getContentSize().width, activationEquipBtn:getContentSize().height)
        redTipSp:setTag(999)
        redTipSp:setScale(0.6)
        activationEquipBtn:addChild(redTipSp)
    end
    
    if self.curAirShipId == 1 then---运输飞艇
        if not curEquip then--激活
            local buffData = G_getAttributeInfoByType(nextEquip.attType)
            
            local buffLb = GetTTFLabel(getlocal(buffData.name), newSize)
            buffLb:setPosition(asEqPnlWidth * 0.5, newPosy or asEqPnlHeigt - 75)
            asEquipPanel:addChild(buffLb, 10)
            
            local buffNumLb = GetTTFLabel("+"..nextEquip.att * 100 .. "%", newSize)
            buffNumLb:setAnchorPoint(ccp(0, 0.5))
            buffNumLb:setColor(G_ColorGreen)
            buffNumLb:setPosition(buffLb:getContentSize().width + 2, buffLb:getContentSize().height * 0.5)
            buffLb:addChild(buffNumLb)
            
            local jhTipSp = CCSprite:createWithSpriteFrameName("arpl_newStrTip.png")
            jhTipSp:setAnchorPoint(ccp(1, 0.5))
            jhTipSp:setPosition(-4, buffLb:getContentSize().height * 0.5)
            buffLb:addChild(jhTipSp)
            
        elseif curEquip and nextEquip then--arpl_yellowLightArrow
            local curBuffData = G_getAttributeInfoByType(curEquip.attType)
            local nextBuffData = G_getAttributeInfoByType(nextEquip.attType)
            local addPosx1,addPosx2 = 0,0
            if not G_isAsia() then
                newSize =newSize - 6
                addPosx1 = 35
                addPosx2 = -35
            end
            local upTipSp = CCSprite:createWithSpriteFrameName("arpl_yellowLightArrow.png")
            upTipSp:setPosition(asEqPnlWidth * 0.5, newPosy or asEqPnlHeigt - 75)
            asEquipPanel:addChild(upTipSp, 10)
            
            local curBuffLb = GetTTFLabel(getlocal(curBuffData.name), newSize)
            curBuffLb:setPosition(-80 + addPosx1, 25)
            curBuffLb:setAnchorPoint(ccp(1, 0.5))
            upTipSp:addChild(curBuffLb, 10)
            
            local buffNumLb = GetTTFLabel("+"..curEquip.att * 100 .. "%", newSize)
            buffNumLb:setAnchorPoint(ccp(0, 0.5))
            buffNumLb:setColor(G_ColorGreen)
            buffNumLb:setPosition(curBuffLb:getContentSize().width + 2, curBuffLb:getContentSize().height * 0.5)
            curBuffLb:addChild(buffNumLb)
            
            local nextBuffLb = GetTTFLabel(getlocal(nextBuffData.name), newSize)
            nextBuffLb:setPosition(upTipSp:getContentSize().width + 45 + addPosx2, 25)
            nextBuffLb:setAnchorPoint(ccp(0, 0.5))
            upTipSp:addChild(nextBuffLb, 10)
            
            local buffNumLb = GetTTFLabel("+"..nextEquip.att * 100 .. "%", newSize)
            buffNumLb:setAnchorPoint(ccp(0, 0.5))
            buffNumLb:setColor(G_ColorGreen)
            buffNumLb:setPosition(nextBuffLb:getContentSize().width + 2, nextBuffLb:getContentSize().height * 0.5)
            nextBuffLb:addChild(buffNumLb)
            
        else--品阶满级
            local buffData = G_getAttributeInfoByType(curEquip.attType)
            
            local buffLb = GetTTFLabel(getlocal(buffData.name), newSize)
            buffLb:setPosition(asEqPnlWidth * 0.48, newPosy or asEqPnlHeigt - 75)
            asEquipPanel:addChild(buffLb, 10)
            
            local buffNumLb = GetTTFLabel("+"..curEquip.att * 100 .. "%", newSize)
            buffNumLb:setAnchorPoint(ccp(0, 0.5))
            buffNumLb:setColor(G_ColorGreen)
            buffNumLb:setPosition(buffLb:getContentSize().width + 2, buffLb:getContentSize().height * 0.5)
            buffLb:addChild(buffNumLb)
            
        end
    else---战斗飞艇
        if not curEquip then
            local nextBuffData = G_getAttributeInfoByType(nextEquip.attType)
            
            local buffLb = GetTTFLabel(getlocal(nextBuffData.name), newSize)
            buffLb:setPosition(asEqPnlWidth * 0.5, newPosy or 110)
            asEquipPanel:addChild(buffLb, 10)
            
            local nextBuffNumLb = GetTTFLabel("+"..nextEquip.att * 100 .. "%", newSize)
            nextBuffNumLb:setAnchorPoint(ccp(0, 0.5))
            -- nextBuffNumLb:setColor(G_ColorGreen)
            nextBuffNumLb:setPosition(buffLb:getContentSize().width + 2, buffLb:getContentSize().height * 0.5)
            buffLb:addChild(nextBuffNumLb)
            
            local jhTipSp = CCSprite:createWithSpriteFrameName("arpl_newStrTip.png")
            jhTipSp:setAnchorPoint(ccp(1, 0.5))
            jhTipSp:setPosition(-4, buffLb:getContentSize().height * 0.5)
            buffLb:addChild(jhTipSp)
            
        elseif curEquip and nextEquip then
            local buffData = G_getAttributeInfoByType(curEquip.attType)
            local nextBuffData = G_getAttributeInfoByType(nextEquip.attType)
            
            local buffLb = GetTTFLabel(getlocal(buffData.name) .. "+"..curEquip.att * 100 .. "%", newSize)
            buffLb:setAnchorPoint(ccp(0, 0.5))
            -- buffLb:setColor(G_ColorGreen)
            asEquipPanel:addChild(buffLb, 10)
            
            local nextBuffNumLb = GetTTFLabel(" ↑+" .. (nextEquip.att - curEquip.att) * 100 .. "%", newSize)
            nextBuffNumLb:setAnchorPoint(ccp(0, 0.5))
            nextBuffNumLb:setColor(G_ColorGreen)
            asEquipPanel:addChild(nextBuffNumLb)
            local realW = buffLb:getContentSize().width + nextBuffNumLb:getContentSize().width
            buffLb:setPosition((asEqPnlWidth - realW) * 0.5, newPosy or 110)
            nextBuffNumLb:setPosition(buffLb:getPositionX() + buffLb:getContentSize().width + 2, buffLb:getPositionY())
        else
            local buffData = G_getAttributeInfoByType(curEquip.attType)
            
            local buffLb = GetTTFLabel(getlocal(buffData.name) .. "+"..curEquip.att * 100 .. "%", newSize)
            buffLb:setPosition(asEqPnlWidth * 0.5, newPosy or 110)
            buffLb:setColor(G_ColorGreen)
            asEquipPanel:addChild(buffLb, 10)
        end
    end
    -- print("equipIconStr=====>>>",equipIconStr)
    local equipIconSp = CCSprite:createWithSpriteFrameName(equipIconStr)
    -- equipIconSp:setAnchorPoint(ccp(0.5,0))
    equipIconSp:setPosition(getCenterPoint(asEquipPanel))
    asEquipPanel:addChild(equipIconSp, 5)
end

function airShipInfoDialog:showEquipPartsUpdateSuccess(callback)
    if self.asEquipPanel then
        if self.iconPosTb and next(self.iconPosTb) then
            for k,v in pairs(self.iconPosTb) do
                local borderSp = CCSprite:createWithSpriteFrameName("iconLightBorder.png")
                local blendFunc=ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src=GL_ONE
                blendFunc.dst=GL_ONE
                borderSp:setBlendFunc(blendFunc)

                borderSp:setPosition(v)
                borderSp:setOpacity(0)
                borderSp:setScale(85 / 100)

                local fadeIn1 = CCFadeIn:create(0.07)
                local fadeOut1 = CCFadeOut:create(0.07)
                local fadeIn2 = CCFadeIn:create(0.1)
                local fadeOut2 = CCFadeOut:create(0.56)
                local fadeArr = CCArray:create()
                local function removeHandl()
                    borderSp:removeFromParentAndCleanup(true)
                    borderSp = nil
                end
                local removeCall = CCCallFunc:create(removeHandl)
                fadeArr:addObject(fadeIn1)
                fadeArr:addObject(fadeOut1)
                fadeArr:addObject(fadeIn2)
                fadeArr:addObject(fadeOut2)
                fadeArr:addObject(removeCall)
                local fadeSeq = CCSequence:create(fadeArr)
                self.asEquipPanel:addChild(borderSp,5)
                borderSp:runAction(fadeSeq)
            end
        end

        if self.deviceBgSp then
            for i=1,2 do
                local lightFlowSp = CCSprite:createWithSpriteFrameName("lightFlow_1.png")
                local blendFunc=ccBlendFunc:new()--混合模式为 ONE ONE
                blendFunc.src=GL_ONE
                blendFunc.dst=GL_ONE
                lightFlowSp:setBlendFunc(blendFunc)

                if i == 2 then
                    lightFlowSp:setFlipX(true)
                end
                lightFlowSp:setPosition(i == 1 and ccp(82.5,120) or ccp(344.5,120) )

                local det2 = CCDelayTime:create(0.1)
                local lfaArr=CCArray:create()
                for kk=1,14 do
                      local nameStr="lightFlow_"..kk..".png"
                      local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                      lfaArr:addObject(frame)
                end
                local animation=CCAnimation:createWithSpriteFrames(lfaArr)
                animation:setDelayPerUnit(0.038)
                local animate=CCAnimate:create(animation)
                local function removeHandl()
                    lightFlowSp:removeFromParentAndCleanup(true)
                    lightFlowSp = nil
                end
                local removeCall = CCCallFunc:create(removeHandl)

                local lfArr= CCArray:create()
                lfArr:addObject(det2)
                lfArr:addObject(animate)
                lfArr:addObject(removeCall)
                local lfSeq = CCSequence:create(lfArr)
                self.deviceBgSp:addChild(lightFlowSp)
                lightFlowSp:runAction(lfSeq)
            end

            local greenBurstSp = CCSprite:createWithSpriteFrameName("greenBurst_1.png")
            greenBurstSp:setScale(1.2)
            greenBurstSp:setVisible(false)
            local blendFunc=ccBlendFunc:new()--混合模式为 ONE ONE
            blendFunc.src=GL_ONE
            blendFunc.dst=GL_ONE
            greenBurstSp:setBlendFunc(blendFunc)

            greenBurstSp:setPosition(ccp(self.deviceBgSp:getPosition()))
            greenBurstSp:setPositionY(greenBurstSp:getPositionY() + 6)

            local det3 = CCDelayTime:create(0.4)
            local function showhandl()
                greenBurstSp:setVisible(true)
            end
            local showCalll = CCCallFunc:create(showhandl)
            local graArr=CCArray:create()
            for kk=1,19 do
                  local nameStr="greenBurst_"..kk..".png"
                  local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                  graArr:addObject(frame)
            end
            local animation=CCAnimation:createWithSpriteFrames(graArr)
            animation:setDelayPerUnit(0.038)
            local animate=CCAnimate:create(animation)

            local function removeHandl()
                greenBurstSp:removeFromParentAndCleanup(true)
                greenBurstSp = nil
                if callback then
                    callback()
                end
            end
            local removeCall = CCCallFunc:create(removeHandl)

            local gbArr= CCArray:create()
            gbArr:addObject(det3)
            gbArr:addObject(showCalll)
            gbArr:addObject(animate)
            gbArr:addObject(removeCall)
            local gbSeq = CCSequence:create(gbArr)

            self.asEquipPanel:addChild(greenBurstSp,5)
            greenBurstSp:runAction(gbSeq)
        end
    end
end

function airShipInfoDialog:initAirShipInfo()
    self.middleButtomPosy = 150
    
    for i = 1, 2 do
        local bottomSp = CCSprite:createWithSpriteFrameName("arpl_infoBg.png")
        bottomSp:setPosition(self.dialogWidth * 0.5, self.middleButtomPosy)
        if i == 1 then
            bottomSp:setAnchorPoint(ccp(1, 1))
        else
            bottomSp:setAnchorPoint(ccp(0, 1))
            bottomSp:setFlipX(true)
        end
        self.bgLayer:addChild(bottomSp, 20)
    end
    
    local airShipBattlePanelMask = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function() end)
    airShipBattlePanelMask:setContentSize(CCSizeMake(self.dialogWidth, self.realHeight))
    airShipBattlePanelMask:setAnchorPoint(ccp(0.5, 1))
    airShipBattlePanelMask:setPosition(self.dialogWidth * 0.5, self.middleTopPosy - 5)
    airShipBattlePanelMask:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
    airShipBattlePanelMask:setIsSallow(true)
    self.bgLayer:addChild(airShipBattlePanelMask, 10)
    self.airShipBattlePanelMask = airShipBattlePanelMask
    
    local airShipBattlePanel = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function() end)
    airShipBattlePanel:setContentSize(CCSizeMake(self.dialogWidth - 20, self.realHeight - 10))
    airShipBattlePanel:setAnchorPoint(ccp(0.5, 1))
    airShipBattlePanel:setPosition(self.dialogWidth * 0.5, self.middleTopPosy - 5)
    if airShipVoApi:getMyPhoneType() == 1 then
        self.infoPanelWidth = airShipBattlePanel:getContentSize().width
        self.infoPanelHeight = airShipBattlePanel:getContentSize().height - 50
    else
        
        self.infoPanelWidth = airShipBattlePanel:getContentSize().width
        self.infoPanelHeight = airShipBattlePanel:getContentSize().height
    end
    self.bgLayer:addChild(airShipBattlePanel, 10)
    self.airShipBattlePanel = airShipBattlePanel
    
    
    self.isExpandBattlePanel = false --是否展开
    self.isOpenBattlePanel = true
    local function clickBattlePanelHandl()
        if self.curAirShipId == 1 then
            self:refreshData("info")
            do return end
        end
        self:changeBattlePanelStatus("expand")
    end
    
    local titleBgWidth = self.dialogWidth - 30
    
    local clickPanelBtn = LuaCCScale9Sprite:createWithSpriteFrameName("arpl_titleBg1.png", CCRect(21, 21, 2, 2), clickBattlePanelHandl)
    clickPanelBtn:setContentSize(CCSizeMake(self.dialogWidth - 30, 45))
    clickPanelBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
    clickPanelBtn:setPosition((self.dialogWidth - 20) * 0.5, airShipBattlePanel:getContentSize().height - 5)
    clickPanelBtn:setAnchorPoint(ccp(0.5, 1))
    airShipBattlePanel:addChild(clickPanelBtn,1)
    
    local infoTitleLb = GetTTFLabel(getlocal("airShip_addProperty"), 21, true)
    infoTitleLb:setPosition(titleBgWidth * 0.5, 22.5)
    clickPanelBtn:addChild(infoTitleLb)
    self.infoTitleLb = infoTitleLb
    
    local clickTipLb = GetTTFLabel(getlocal("airShip_infoClickTip1"), 17)
    clickTipLb:setPosition(titleBgWidth * 0.5, -25)
    clickTipLb:setColor(G_ColorYellowPro)
    clickPanelBtn:addChild(clickTipLb)
    self.clickTipLb = clickTipLb
    
    local clickTipSp1 = CCSprite:createWithSpriteFrameName("arpl_yellowArrow1.png")
    clickTipSp1:setAnchorPoint(ccp(0.5, 1))
    clickTipSp1:setPosition(titleBgWidth * 0.5, 20)
    clickPanelBtn:addChild(clickTipSp1)
    self.clickTipSp1 = clickTipSp1
    
    local clickTipSp2 = CCSprite:createWithSpriteFrameName("arpl_yellowArrow2.png")
    clickTipSp2:setAnchorPoint(ccp(0.5, 1))
    clickTipSp2:setPosition(titleBgWidth * 0.5, 20)
    clickPanelBtn:addChild(clickTipSp2)
    self.clickTipSp2 = clickTipSp2
    
    local infoTitleTipLb = GetTTFLabel(getlocal("airShip_infoTip1"), 22, true)
    infoTitleTipLb:setPosition(titleBgWidth * 0.5, 22.5)
    clickPanelBtn:addChild(infoTitleTipLb)
    self.infoTitleTipLb = infoTitleTipLb -- 只用与运输艇
    
    if self.curAirShipId == 1 then
        infoTitleTipLb:setVisible(true)
        infoTitleLb:setVisible(false)
        clickTipLb:setVisible(false)
        clickTipSp1:setVisible(false)
        clickTipSp2:setVisible(false)
    else
        infoTitleTipLb:setVisible(false)
        infoTitleLb:setVisible(true)
        clickTipLb:setVisible(true)
        clickTipSp1:setVisible(true)
        clickTipSp2:setVisible(false)
    end    
    
    if airShipVoApi:getMyPhoneType() == 1 then
        self:initInfoTableView()
    else
        self.lineSpUsePosy = self.infoPanelHeight - 394
        local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function () end)
        lineSp:setContentSize(CCSizeMake(self.infoPanelWidth - 18, lineSp:getContentSize().height))
        lineSp:setRotation(180)
        lineSp:setPosition(self.infoPanelWidth * 0.5, self.lineSpUsePosy)
        self.airShipBattlePanel:addChild(lineSp)
        self.infoPanelLineSp = lineSp
        
        self.lineSpUsePosy2 = self.infoPanelHeight - 750
        local lineSp2 = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function () end)
        lineSp2:setContentSize(CCSizeMake(self.infoPanelWidth - 18, lineSp2:getContentSize().height))
        lineSp2:setRotation(180)
        lineSp2:setPosition(self.infoPanelWidth * 0.5, self.lineSpUsePosy2)
        self.airShipBattlePanel:addChild(lineSp2)

        self:airShipBattlePanelDataShow()
    end
end

function airShipInfoDialog:initInfoTableView( )
    local cellAddPosy = 300
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return 1
        elseif fn=="tableCellSizeForIndex" then
            return  CCSizeMake(self.infoPanelWidth,self.infoPanelHeight + cellAddPosy)
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            if self.airShipBattlePanel2 then
                self.airShipBattlePanel2:removeFromParentAndCleanup(true)
                self.airShipBattlePanel2 = nil
                self.airshipInfo1Tb = nil
                self.airShipInfoNPanel = nil
                self.tacticAcDescLb = nil
                self.shipStrengthLb = nil
            end

            local airShipBattlePanel2 = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function() end)
            airShipBattlePanel2:setContentSize(CCSizeMake(self.infoPanelWidth, self.infoPanelHeight))
            airShipBattlePanel2:setOpacity(0)
            airShipBattlePanel2:setAnchorPoint(ccp(0.5, 0))
            airShipBattlePanel2:setPosition(self.infoPanelWidth * 0.5, cellAddPosy)
            cell:addChild(airShipBattlePanel2)
            self.airShipBattlePanel2 = airShipBattlePanel2

            self.lineSpUsePosy = self.infoPanelHeight - 394
            local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function () end)
            lineSp:setContentSize(CCSizeMake(self.infoPanelWidth - 18, lineSp:getContentSize().height))
            lineSp:setRotation(180)
            lineSp:setPosition(self.infoPanelWidth * 0.5, self.lineSpUsePosy)
            self.airShipBattlePanel2:addChild(lineSp)
            self.infoPanelLineSp = lineSp
            
            self.lineSpUsePosy2 = self.infoPanelHeight - 750
            local lineSp2 = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function () end)
            lineSp2:setContentSize(CCSizeMake(self.infoPanelWidth - 18, lineSp2:getContentSize().height))
            lineSp2:setRotation(180)
            lineSp2:setPosition(self.infoPanelWidth * 0.5, self.lineSpUsePosy2)
            self.airShipBattlePanel2:addChild(lineSp2)

            self:airShipBattlePanelDataShow()
            return cell
        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)
    local tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.infoPanelWidth,self.infoPanelHeight),nil)
    tableView:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    tableView:setPosition(ccp(0,0))
    self.airShipBattlePanel:addChild(tableView)
    tableView:setMaxDisToBottomOrTop(500)
    self.infoTv = tableView
end

function airShipInfoDialog:airShipBattlePanelDataShow()
    local properTyTb = airShipVoApi:getCurAirShipProperty(self.curAirShipId)

    local parent = self.airShipBattlePanel2 or self.airShipBattlePanel

    local addPosy = self.airShipBattlePanel2 and 50 or 0

    if self.curAirShipId == 1 then
        local bgPic = "equipBg_gray.png"
        local bgnameTb = {"equipBg_gray.png", "equipBg_green.png", "equipBg_blue.png", "equipBg_purple.png", "equipBg_orange.png"}
        local airShipInfo = airShipVoApi:getCurAirShipInfo(self.curAirShipId)
        if not self.airshipInfo1Tb then
            local iconWidth = 50
            self.airshipInfo1Tb = {}
            for i = 1, 4 do
                self.airshipInfo1Tb[i] = {}
                
                iconPosy = self.infoPanelHeight - 85 - (i - 1) * 75 + addPosy
                iconPosx = self.infoPanelWidth * 0.34
                bgPic = (airShipInfo and airShipInfo[2] and airShipInfo[2]["as"..i]) and bgnameTb[airShipInfo[2]["as"..i]] or "equipBg_gray.png"
                
                local iconBg = CCSprite:createWithSpriteFrameName(bgPic)
                iconBg:setScale(iconWidth / iconBg:getContentSize().width)
                iconBg:setPosition(iconPosx, iconPosy)
                parent:addChild(iconBg)
                
                local infoIcon = CCSprite:createWithSpriteFrameName("arpl_asEquipIcon1_"..i..".png")
                infoIcon:setPosition(getCenterPoint(iconBg))
                infoIcon:setScale(iconBg:getContentSize().width / infoIcon:getContentSize().width)
                iconBg:addChild(infoIcon)
                self.airshipInfo1Tb[i].infoIcon = iconBg
                
                local shipEquipName = GetTTFLabel(getlocal("airShip_shipInfo1_"..i), 19)
                shipEquipName:setAnchorPoint(ccp(0.5, 1))
                shipEquipName:setPosition(iconPosx, iconPosy - 26)
                parent:addChild(shipEquipName)
                self.airshipInfo1Tb[i].shipEquipName = shipEquipName
                
                local shipEquipAdd = GetTTFLabelWrap(getlocal("airShip_shipInfoDec1_"..i, {(properTyTb[i] or 0) * 100}), 20, CCSizeMake(350, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
                shipEquipAdd:setAnchorPoint(ccp(0, 0.5))
                shipEquipAdd:setPosition(iconPosx + 60, iconPosy)
                parent:addChild(shipEquipAdd)
                self.airshipInfo1Tb[i].shipEquipAdd = shipEquipAdd
            end
        else
            for i = 1, 4 do
                local infoIcon = tolua.cast(self.airshipInfo1Tb[i].infoIcon, "CCSprite")
                if infoIcon == nil then
                    do break end
                end
                bgPic = (airShipInfo and airShipInfo[2] and airShipInfo[2]["as"..i]) and bgnameTb[airShipInfo[2]["as"..i]] or "equipBg_gray.png"
                local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(bgPic)
                infoIcon:setDisplayFrame(spriteFrame)
                infoIcon:setVisible(true)
                self.airshipInfo1Tb[i].shipEquipName:setVisible(true)
                self.airshipInfo1Tb[i].shipEquipAdd:setVisible(true)
                self.airshipInfo1Tb[i].shipEquipAdd:setString(getlocal("airShip_shipInfoDec1_"..i, {(properTyTb[i] or 0) * 100}))
            end
        end
        self.infoPanelLineSp:setVisible(false)
        if self.airShipInfoNPanel then
            self.airShipInfoNPanel:setVisible(false)
        end
    else
        local stactLvl = airShipVoApi:getCurAirShipTacticsData(self.curAirShipId)
        local tacticStrTb, tacticNum = airShipVoApi:getCurAirShipTacticsLbTb(self.curAirShipId)
        local resonanceStrTb, resonanceData = airShipVoApi:getCurAirShipResonanceLb(self.curAirShipId)
        local prptKeyTb = {"dmg", "accuracy", "anticrit", "hp", "evade", "crit"}
        if not self.airShipInfoNPanel then
            local airShipInfoNPanel = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function() end)
            airShipInfoNPanel:setContentSize(CCSizeMake(self.infoPanelWidth - 10, self.infoPanelHeight + addPosy))
            airShipInfoNPanel:setAnchorPoint(ccp(0.5, 1))
            airShipInfoNPanel:setOpacity(0)
            airShipInfoNPanel:setPosition(self.infoPanelWidth * 0.5, self.infoPanelHeight + addPosy - 45)
            parent:addChild(airShipInfoNPanel)
            self.airShipInfoNPanel = airShipInfoNPanel
            local infoNPanelHeight = airShipInfoNPanel:getContentSize().height
            self.airshiInfoNTb = {}
            
            local prptyLbSize = 24
            local prptName = {getlocal("emblem_attUp_dmg"), getlocal("emblem_attUp_accuracy"), getlocal("emblem_attUp_anticrit"), getlocal("emblem_attUp_hp"), getlocal("emblem_attUp_evade"), getlocal("emblem_attUp_crit")}
            for i = 1, 6 do
                local prptNameLb = GetTTFLabel(prptName[i] .. "：", prptyLbSize, true)
                prptNameLb:setAnchorPoint(ccp(1, 0.5))
                local posx = i < 4 and self.infoPanelWidth * 0.27 or self.infoPanelWidth * 0.75
                local posy = i < 4 and infoNPanelHeight - 75 - (i - 1) * 90 or infoNPanelHeight - 75 - (i - 4) * 90
                prptNameLb:setPosition(posx, posy)
                airShipInfoNPanel:addChild(prptNameLb)
                
                local prptValue = properTyTb[prptKeyTb[i]] or 0
                local prptValueLb = GetTTFLabel("+"..airShipVoApi:getPropertyValueStr(prptKeyTb[i], prptValue), prptyLbSize, 24)
                prptValueLb:setAnchorPoint(ccp(0, 0.5))
                prptValueLb:setPosition(posx, posy)
                prptValueLb:setColor(prptValue == 0 and G_ColorGray or G_ColorGreen)
                airShipInfoNPanel:addChild(prptValueLb)
                self.airshiInfoNTb[i] = prptValueLb
            end
            
            local tStartPosy = self.lineSpUsePosy + 45 - 10
            local tacticAcDescLb = GetTTFLabel(getlocal("airShip_tacticsActving", {tacticNum, 5}), 19)
            tacticAcDescLb:setAnchorPoint(ccp(0, 1))
            tacticAcDescLb:setPosition(5, tStartPosy)
            self.airShipInfoNPanel:addChild(tacticAcDescLb)
            self.tacticAcDescLb = tacticAcDescLb
            
            self.tacticLbTb = {}
            for i = 1, 5 do
                self.tacticLbTb[i] = {}
                tacticPosy = tStartPosy - 60 - (i - 1) * 60
                local tacticIcon, tacticStr, color = nil, "", G_ColorWhite
                if i <= tacticNum then
                    tacticIcon = CCSprite:createWithSpriteFrameName("airship_zs_"..stactLvl..".png")
                    tacticStr = tacticStrTb[i]
                else
                    tacticIcon = GraySprite:createWithSpriteFrameName("airship_zs_1.png")
                    tacticStr = getlocal("airShip_tactics_nope")
                    color = G_ColorRed
                end
                tacticIcon:setScale(50 / tacticIcon:getContentSize().width)
                tacticIcon:setAnchorPoint(ccp(0, 0.5))
                tacticIcon:setPosition(100, tacticPosy)
                self.airShipInfoNPanel:addChild(tacticIcon)
                self.tacticLbTb[i].tacticIcon = tacticIcon
                
                local tacticLb = GetTTFLabel(tacticStr, 20)
                tacticLb:setAnchorPoint(ccp(0, 0.5))
                tacticLb:setPosition(160, tacticPosy)
                tacticLb:setColor(color)
                self.tacticLbTb[i].tacticLb = tacticLb
                self.airShipInfoNPanel:addChild(tacticLb)
            end
            
            local reStartPosy = self.lineSpUsePosy2 + 45 - 10
            local resonanceLb = GetTTFLabel(getlocal("airShip_resonanceStr"), 19)
            resonanceLb:setAnchorPoint(ccp(0, 0.5))
            resonanceLb:setPosition(5, reStartPosy)
            self.airShipInfoNPanel:addChild(resonanceLb)
            
            local iconWidth, firstPosX = 35, self.airShipInfoNPanel:getContentSize().width / 2 - 20
            self.resonanceLbTb = {}
            self.resonanceIconTb = {}
            for i = 1, 2 do
                self.resonanceIconTb[i] = {}
                resonancePosy = reStartPosy - 45 - (i - 1) * 50
                local qualtyLv = resonanceData[i].qualtyLv
                for j = 1, resonanceData[i].rIdx do
                    local qualtySp
                    if qualtyLv > 0 then
                        qualitySp = CCSprite:createWithSpriteFrameName("airship_gz_"..qualtyLv .. ".png")
                    else --没有该共振效果则置灰
                        qualitySp = GraySprite:createWithSpriteFrameName("airship_gz_1.png")
                    end
                    qualitySp:setAnchorPoint(ccp(0, 0.5))
                    -- qualitySp:setPosition(100 + (j - 1) * iconWidth,resonancePosy)
                    qualitySp:setPosition(firstPosX - (2 * j - 1) * iconWidth / 2 - (j - 1) * 20, resonancePosy)
                    qualitySp:setScale(iconWidth / qualitySp:getContentSize().width)
                    self.airShipInfoNPanel:addChild(qualitySp)
                    self.resonanceIconTb[i][j] = qualitySp
                end
                local resonanceLb = GetTTFLabelWrap(resonanceStrTb[i], G_isAsia() and 20 or 17,CCSizeMake(G_VisibleSizeWidth * 0.46, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
                resonanceLb:setAnchorPoint(ccp(0, 0.5))
                resonanceLb:setPosition(self.airShipInfoNPanel:getContentSize().width / 2 + 15, resonancePosy)
                self.airShipInfoNPanel:addChild(resonanceLb)
                self.resonanceLbTb[i] = resonanceLb
            end
        else
            self.airShipInfoNPanel:setVisible(true)
            for i = 1, 6 do
                local prptValue = properTyTb[prptKeyTb[i]] or 0
                self.airshiInfoNTb[i]:setColor(prptValue == 0 and G_ColorGray or G_ColorGreen)
                self.airshiInfoNTb[i]:setString("+"..airShipVoApi:getPropertyValueStr(prptKeyTb[i], prptValue))
            end
            self.tacticAcDescLb:setString(getlocal("airShip_tacticsActving", {tacticNum, 5}))
            for i = 1, 5 do
                local tacticIcon, tacticLb = tolua.cast(self.tacticLbTb[i].tacticIcon, "CCSprite"), tolua.cast(self.tacticLbTb[i].tacticLb, "CCLabelTTF")
                local tpos, scale = ccp(tacticIcon:getPosition()), tacticIcon:getScale()
                tacticIcon:removeFromParentAndCleanup(true)
                tacticIcon, self.tacticLbTb[i].tacticIcon = nil, nil
                tacticStr, color = "", G_ColorWhite
                if i <= tacticNum then
                    tacticIcon = CCSprite:createWithSpriteFrameName("airship_zs_"..stactLvl..".png")
                    tacticStr = tacticStrTb[i]
                else
                    tacticIcon = GraySprite:createWithSpriteFrameName("airship_zs_1.png")
                    tacticStr = getlocal("airShip_tactics_nope")
                    color = G_ColorRed
                end
                tacticIcon:setAnchorPoint(ccp(0, 0.5))
                tacticIcon:setScale(scale)
                tacticIcon:setPosition(tpos)
                self.airShipInfoNPanel:addChild(tacticIcon)
                
                tacticLb:setString(tacticStr)
                tacticLb:setColor(color)
                self.tacticLbTb[i].tacticIcon = tacticIcon
            end
            for i = 1, 2 do
                local qualtyLv = resonanceData[i].qualtyLv
                for j = 1, resonanceData[i].rIdx do
                    local qualitySp = tolua.cast(self.resonanceIconTb[i][j], "CCSprite")
                    local qpos, scale = ccp(qualitySp:getPosition()), qualitySp:getScale()
                    qualitySp:removeFromParentAndCleanup(true)
                    qualitySp, self.resonanceIconTb[i][j] = nil, nil
                    if qualtyLv > 0 then
                        qualitySp = CCSprite:createWithSpriteFrameName("airship_gz_"..qualtyLv .. ".png")
                    else --没有该共振效果则置灰
                        qualitySp = GraySprite:createWithSpriteFrameName("airship_gz_1.png")
                    end
                    qualitySp:setAnchorPoint(ccp(0, 0.5))
                    qualitySp:setPosition(qpos)
                    qualitySp:setScale(scale)
                    self.airShipInfoNPanel:addChild(qualitySp)
                    self.resonanceIconTb[i][j] = qualitySp
                end
                local resonanceLb = tolua.cast(self.resonanceLbTb[i], "CCLabelTTF")
                resonanceLb:setString(resonanceStrTb[i])
            end
        end
        
        self.infoPanelLineSp:setVisible(true)
        if self.airshipInfo1Tb and next(self.airshipInfo1Tb) then
            for i = 1, 4 do
                self.airshipInfo1Tb[i].infoIcon:setVisible(false)
                self.airshipInfo1Tb[i].shipEquipName:setVisible(false)
                self.airshipInfo1Tb[i].shipEquipAdd:setVisible(false)
            end
        end
    end
    
    local curAirShipStrength = airShipVoApi:getStrength(self.curAirShipId)
    if not self.shipStrengthLb then
        local shipStrengthLb = GetTTFLabelWrap(getlocal("airShip_strength") .. ":"..curAirShipStrength, 20, CCSizeMake(self.infoPanelWidth - 10, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentBottom)
        shipStrengthLb:setAnchorPoint(ccp(0.5, 0))
        shipStrengthLb:setColor(G_ColorYellowPro)
        shipStrengthLb:setPosition(self.infoPanelWidth * 0.5, self.infoPanelHeight + addPosy - 390)
        parent:addChild(shipStrengthLb)
        self.shipStrengthLb = shipStrengthLb
    else
        self.shipStrengthLb:setString(getlocal("airShip_strength") .. ":"..curAirShipStrength)
    end
end

function airShipInfoDialog:changeBattlePanelStatus(status, isChangeShip, isLeft)
    self:refreshData("info")
    if status == "open" then
        if self and self.airShipBattlePanel then
            if isChangeShip then
                self:changeDeviceBtnAnimate()
                self.airShipBattlePanelMask:setPositionY(self.middleTopPosy)
                self.airShipBattlePanel:setPositionY(self.middleTopPosy - 5)
                self.isOpenBattlePanel = true
                self.oldDeviceBtnIndex = nil
                self:refreshData("equipBtn")
                self:refreshData("tactic")
                self:refreshData("shipName")
                self:refreshData("unlockShip")
                self:refreshData("showTwoBtn")
                self:refreshData("equipVar")
                self:changeAirShip(isLeft)
            elseif self.isOpenBattlePanel then
                self.airShipBattlePanelMask:setPositionY(self.middleButtomPosy - 200)
                self.airShipBattlePanel:setPositionY(self.middleButtomPosy - 200)
                self.isOpenBattlePanel = false
            else
                self.airShipBattlePanelMask:setPositionY(self.middleTopPosy)
                self.airShipBattlePanel:setPositionY(self.middleTopPosy - 5)
                self.isOpenBattlePanel = true
            end
            if self.isOpenBattlePanel then
                if self.asEquipPanel then
                    self.asEquipPanel:stopAllActions()
                    self.asEquipPanel:removeFromParentAndCleanup(true)
                    self.asEquipPanel = nil
                end
            else
                self:refreshData("asEquip")
            end
        end
        -- print("self.curAirShipId=====>>>>",self.curAirShipId)
        if self.curAirShipId == 1 then
            self.infoTitleTipLb:setVisible(true)
            self.infoTitleLb:setVisible(false)
            self.clickTipLb:setVisible(false)
            self.clickTipSp1:setVisible(false)
            self.clickTipSp2:setVisible(false)
        else
            self.infoTitleTipLb:setVisible(false)
            self.infoTitleLb:setVisible(true)
            self.clickTipLb:setVisible(true)
            self.clickTipSp1:setVisible(true)
            self.clickTipSp2:setVisible(false)
            if isChangeShip then
                self.isExpandBattlePanel = false
                self.clickTipLb:setString(getlocal("airShip_infoClickTip1"))
            end
        end
    elseif status == "expand" then
        if self and self.airShipBattlePanel then
            if self.isExpandBattlePanel then
                local moveTo = CCMoveTo:create(0.3, ccp(self.airShipBattlePanel:getPositionX(), self.middleTopPosy - 5))
                self.airShipBattlePanel:runAction(CCSequence:createWithTwoActions(moveTo, CCCallFunc:create(function ()
                    self.isExpandBattlePanel = false
                end)))
                self.airShipBattlePanelMask:runAction(CCMoveTo:create(0.3, ccp(self.airShipBattlePanelMask:getPositionX(), self.middleTopPosy)))
                -- self.airShipBattlePanelMask:setPositionY(self.middleTopPosy)
                -- self.airShipBattlePanel:setPositionY(self.middleTopPosy - 5)
                -- self.isExpandBattlePanel = false
                self.clickTipLb:setString(getlocal("airShip_infoClickTip1"))
                self.clickTipSp1:setVisible(true)
                self.clickTipSp2:setVisible(false)
            else
                local moveTo = CCMoveTo:create(0.3, ccp(self.airShipBattlePanel:getPositionX(), self.realHeight))
                self.airShipBattlePanel:runAction(CCSequence:createWithTwoActions(moveTo, CCCallFunc:create(function ()
                    self.isExpandBattlePanel = true
                end)))
                self.airShipBattlePanelMask:runAction(CCMoveTo:create(0.3, ccp(self.airShipBattlePanelMask:getPositionX(), self.realHeight)))
                -- self.airShipBattlePanelMask:setPositionY(self.realHeight)
                -- self.airShipBattlePanel:setPositionY(self.realHeight)
                -- self.isExpandBattlePanel = true
                self.clickTipLb:setString(getlocal("airShip_infoClickTip2"))
                self.clickTipSp2:setVisible(true)
                self.clickTipSp1:setVisible(false)
            end
        end
    end
end

function airShipInfoDialog:initSlideBtn()
    self.lockAirShipTb = {} --未解锁的飞艇列表
    local airShipCfg = airShipVoApi:getAirShipCfg()
    for k, v in pairs(airShipCfg.airship) do
        self.lockAirShipTb[k] = airShipVoApi:isUnlockCurAirShip(k)
    end
    
    local btnPosY = 80
    local slideArea = CCRect(35, 8, G_VisibleSizeWidth - 70, 150)
    local item_scaleTb = {0.4, 0.6, 0.75, 1, 0.75, 0.6, 0.4}
    local item_posTb = {ccp(slideArea.size.width / 2 - 315, btnPosY), ccp(slideArea.size.width / 2 - 230, btnPosY), ccp(slideArea.size.width / 2 - 130, btnPosY), ccp(0.5 * slideArea.size.width, btnPosY), ccp(slideArea.size.width / 2 + 130, btnPosY), ccp(slideArea.size.width / 2 + 230, btnPosY), ccp(slideArea.size.width / 2 + 315, btnPosY)}
    local item_tintTb = {math.floor(255 * 0.2), math.floor(255 * 0.4), math.floor(255 * 0.7), 255, math.floor(255 * 0.7), math.floor(255 * 0.4), math.floor(255 * 0.2)}
    local function createItem(idx, ischeck)
        local scrollItem
        if ischeck == true then --被选中
            scrollItem = CCSprite:createWithSpriteFrameName("arpl_selBg2.png")
        else
            scrollItem = CCSprite:createWithSpriteFrameName("arpl_selBg1.png")
        end
        local airshipSp = CCSprite:createWithSpriteFrameName("arpl_ship"..idx.."_1.png")
        airshipSp:setScale(0.3)
        airshipSp:setPosition(getCenterPoint(scrollItem))
        scrollItem:addChild(airshipSp)
        
        if self.lockAirShipTb[idx] == false then --飞艇未解锁
            local lockSp = CCSprite:createWithSpriteFrameName("airship_zslock.png")
            lockSp:setScale(1.5)
            lockSp:setPosition(getCenterPoint(scrollItem))
            scrollItem:addChild(lockSp, 2)
        else
            local flag = airShipVoApi:getTip(1, {aid = idx})
            if flag == 0 then
                flag = airShipVoApi:getTip(2, {aid = idx})
            end
            if flag == 1 then --该飞艇可以解锁或者有可以激活改造的装置，显示红点提示
                local tipSp = CCSprite:createWithSpriteFrameName("NumBg.png")
                tipSp:setScale(0.6)
                tipSp:setPosition(scrollItem:getContentSize().width, scrollItem:getContentSize().height)
                scrollItem:addChild(tipSp)
            end
        end
        return scrollItem
    end
    local pageList = {} --初始页码序列
    for k = 1, 5 do
        local page = self.curAirShipId + (k - 3)
        if page > 7 then
            page = page - 7
        elseif page <= 0 then
            page = page + 7
        end
        table.insert(pageList, page)
    end
    local function createScrollItemCallback(itemIdx, ischeck)
        return createItem(itemIdx, ischeck)
    end
    local function showAirShip(idx, isLeft)
        --点击当前页则不做处理
        if self.curAirShipId == idx then
            do return end
        end
        self.lastCurAirShipId = self.curAirShipId
        self.curAirShipId = tonumber(idx)
        
        if airShipVoApi:isUnlockCurAirShip(self.curAirShipId) == true and airShipVoApi:getTip(1) == 1 then
            airShipVoApi:saveTip(1, {aid = self.curAirShipId, tipv = 0}) --已解锁的飞艇点击过则红点取消
        end
        
        if self.pageObj and self.pageObj.refreshItem then
            self.pageObj:refreshItem(idx, true)
        end
        
        self:changeBattlePanelStatus("open", true, isLeft)
        self:refreshData("equipRedTip")
    end
    
    local function turnPageCallback(idx)
        if self.pageObj and self.pageObj.refreshItem then
            self.pageObj:refreshItem(idx, false)
        end
    end
    require "luascript/script/componet/ScrollPage"
    local controller = {pos = item_posTb, scale = item_scaleTb, tint = item_tintTb, mt = 0.3, slideArea = slideArea, createScrollItemCallback = createScrollItemCallback, callback = showAirShip, turnPageCallback = turnPageCallback}
    self.pageObj = ScrollPage:create(pageList, 7, controller, self.layerNum)
    self.pageObj.bgLayer:setPosition(0, 0)
    self.bgLayer:addChild(self.pageObj.bgLayer, 25)
end

--刷新飞艇解锁状态
function airShipInfoDialog:refreshSlideBtn(data)
    local airship = airShipVoApi:getAirShipCfg().airship
    for k, v in pairs(airship) do
        local isUnlock = airShipVoApi:isUnlockCurAirShip(k)
        if isUnlock ~= self.lockAirShipTb[k] or (data and k == data.aid) then
            self.lockAirShipTb[k] = isUnlock
            if self.curAirShipId == k then
                self.pageObj:refreshItem(k, false)
            else
                self.pageObj:refreshItem(k, true)
            end
        end
    end
end

function airShipInfoDialog:changeAirShip(isLeft)
    local oldMovPos, newMovPos = self.upBgWidth * 1.5, self.upBgWidth * 0.5
    local posx = isLeft and self.upBgWidth * (-1.5) or self.upBgWidth * 1.5
    local posy = self.upBgHeight * 0.5
    
    self:initAirShip(ccp(posx, posy))
    
    if isLeft then
        oldMovPos = self.upBgWidth * 1.5
    else
        oldMovPos = self.upBgWidth * (-1.5)
    end
    local oldMov = CCMoveTo:create(0.5, ccp(oldMovPos, posy))
    local function oldShipRemovHandl()
        self:removeAirShip()
    end
    local removFuncc = CCCallFunc:create(oldShipRemovHandl)
    local rmArr = CCArray:create()
    rmArr:addObject(oldMov)
    rmArr:addObject(removFuncc)
    local rmSeq = CCSequence:create(rmArr)
    self.airShipSpTb[self.lastCurAirShipId]:runAction(rmSeq)
    
    local newMov = CCMoveTo:create(0.5, ccp(newMovPos, posy))
    self.airShipSpTb[self.curAirShipId]:runAction(newMov)
end

function airShipInfoDialog:initAirShip(newPos)
    if self.airShipSpTb[self.curAirShipId] then
        self.airShipSpTb[self.curAirShipId]:stopAllActions()
        self.airShipSpTb[self.curAirShipId]:removeFromParentAndCleanup(true)
        self.airShipSpTb[self.curAirShipId] = nil
    end
    
    local airShipSp = G_showAirShip(self.curAirShipId)
    self.airShipSpTb[self.curAirShipId] = airShipSp
    airShipSp:setScale(0.7)
    airShipSp:setPosition(newPos or ccp(self.upBgWidth * 0.5, self.upBgHeight * 0.5))
    self.upBg:addChild(airShipSp)
    
    local movBy1 = CCMoveBy:create(1.5, ccp(0, 5))
    local movBy2 = movBy1:reverse()
    local movArr = CCArray:create()
    movArr:addObject(movBy1)
    movArr:addObject(movBy2)
    local movSeq = CCSequence:create(movArr)
    local movRepeat = CCRepeatForever:create(movSeq)
    airShipSp:runAction(movRepeat)
end
function airShipInfoDialog:removeAirShip()
    if self.lastCurAirShipId and self.airShipSpTb[self.lastCurAirShipId] then
        self.airShipSpTb[self.lastCurAirShipId]:stopAllActions()
        self.airShipSpTb[self.lastCurAirShipId]:removeFromParentAndCleanup(true)
        self.airShipSpTb[self.lastCurAirShipId] = nil
    end
end

function airShipInfoDialog:refreshData(key, params)
    if key == "info" then
        if self.infoTv then
            local recordPoint = self.infoTv:getRecordPoint()
              recordPoint.y = -300
              self.infoTv:reloadData()
              self.infoTv:recoverToRecordPoint(recordPoint)
        else
            self:airShipBattlePanelDataShow()
        end
        
    elseif key == "asEquip" then
        self:initOrRefreshAirShipEquipPanel()
    elseif key == "equipBtn" then
        local isTshow = false--运输厅是否显示
        local isBshow = true--战斗挺是否显示
        if self.curAirShipId == 1 then
            isTshow = true
            isBshow = false
        end
        for i = 1, 6 do
            local deviceBtn, deviceBtn2, equipIconSp
            if i < 5 then
                deviceBtn, deviceBtn2, equipIconSp = tolua.cast(self.tShipEquipBtnTb[i], "CCSprite"), tolua.cast(self.tShipEquipBtnTb2[i], "CCSprite"), tolua.cast(self.tShipEquipIconTb[i], "CCSprite")
                deviceBtn:setVisible(isTshow)
                local addPosx = 0
                if not isTshow then
                    addPosx = i < 3 and - 180 or 180
                end
                if i > 1 and i < 4 then
                    deviceBtn:setPositionX(self.deviceBtnPos[i + 1].x + addPosx)
                elseif i == 4 then
                    deviceBtn:setPositionX(self.deviceBtnPos[6].x + addPosx)
                else
                    deviceBtn:setPositionX(self.deviceBtnPos[1].x + addPosx)
                end
                deviceBtn2:stopAllActions()
                deviceBtn2:setOpacity(0)
                equipIconSp:stopAllActions()
                equipIconSp:setOpacity(0)
                
                local yellowTipSp = tolua.cast(deviceBtn2:getChildByTag(11), "CCSprite")
                if yellowTipSp then
                    yellowTipSp:stopAllActions()
                    yellowTipSp:removeFromParentAndCleanup(true)
                end
                local yellowAnimtSp = tolua.cast(deviceBtn2:getChildByTag(12), "CCSprite")
                if yellowAnimtSp then
                    yellowAnimtSp:stopAllActions()
                    yellowAnimtSp:removeFromParentAndCleanup(true)
                end
            end
            deviceBtn, deviceBtn2, equipIconSp = tolua.cast(self.bShipEquipBtnTb[i], "CCSprite"), tolua.cast(self.bShipEquipBtnTb2[i], "CCSprite"), tolua.cast(self.bShipEquipIconTb[i], "CCSprite")
            deviceBtn:setVisible(isBshow)
            if self.curAirShipId == 1 and (i == 2 or i == 5) then
                deviceBtn:setVisible(isBshow)
            end
            local bShipBtnPosx = self.deviceBtnPos[i].x
            if not isBshow then
                if i == 2 or i == 5 then
                    bShipBtnPosx = i == 2 and bShipBtnPosx - 180 or bShipBtnPosx + 180
                elseif i < 4 then
                    bShipBtnPosx = bShipBtnPosx - 180
                else
                    bShipBtnPosx = bShipBtnPosx + 180
                end
            end
            deviceBtn:setPositionX(bShipBtnPosx)
            deviceBtn2:stopAllActions()
            deviceBtn2:setOpacity(0)
            equipIconSp:stopAllActions()
            equipIconSp:setOpacity(0)
            
            local yellowTipSp = tolua.cast(deviceBtn2:getChildByTag(11), "CCSprite")
            if yellowTipSp then
                yellowTipSp:stopAllActions()
                yellowTipSp:removeFromParentAndCleanup(true)
            end
            local yellowAnimtSp = tolua.cast(deviceBtn2:getChildByTag(12), "CCSprite")
            if yellowAnimtSp then
                yellowAnimtSp:stopAllActions()
                yellowAnimtSp:removeFromParentAndCleanup(true)
            end
        end
        self.unClickUpbgSp:setPositionY(self.upBgHeight * 5.5)
    elseif key == "tactic" then
        if self.tBtn then
            if self.tBtnLb then
                self.tBtnLb:removeFromParentAndCleanup(true)
                self.tBtnLb = nil
            end
            local curTacticLv, tacticTb = airShipVoApi:getCurAirShipTacticsData(self.curAirShipId)
            local curTacticNum = curTacticLv and tacticTb and SizeOfTable(tacticTb) or 0
            local btnLb = G_getRichTextLabel(getlocal("airShip_tacticsCur", {curTacticNum}), {G_ColorWhite, G_ColorGreen, G_ColorWhite}, 18, 116, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
            btnLb:setAnchorPoint(ccp(0.5, 1))
            btnLb:setPosition(65, 34)
            self.tBtnLb = btnLb
            self.tBtn:addChild(btnLb)
        end
    elseif key == "shipName" then
        self:resetAirshipNameShow()
    elseif key == "unlockShip" then
        local isUnlock, airShipInfo = airShipVoApi:isUnlockCurAirShip(self.curAirShipId)
        local shipNum = SizeOfTable(airShipVoApi:getAirShipCfg().airship)
        local isAllHasUnlockOne, canUnlockTb = airShipVoApi:getCanBeUnLockAirShip()
        if self.lockBgSp and self.lockTipLb then
            if isUnlock then
                self.lockBgSp:setVisible(false)
                self.lockBgSp:setPosition(9999, 9999)
            else
                self.lockBgSp:setVisible(true)
                self.lockBgSp:setPosition(self.dialogWidth * 0.5, self.realHeight)
                local strength = airShipVoApi:getTotalStrength()
                local unlockStrength = airShipVoApi:getAirShipCfg().airship[self.curAirShipId].lock
                self.lockTipLb:setString(getlocal("airShip_unlock_tip", {strength, unlockStrength}))
            end
        end
    elseif key == "showTwoBtn" then--运输艇不显示 共振 战术
        local isCan = self.curAirShipId > 1 and true or false
        self.rBtn:setVisible(isCan)
        self.rBtn:setEnabled(isCan)
        self.tBtn:setVisible(isCan)
        self.tBtn:setEnabled(isCan)
    elseif key == "equipVar" then --装置数据发生变化
        local airShipInfo = airShipVoApi:getCurAirShipInfo(self.curAirShipId)
        if airShipInfo == nil then
            do return end
        end
        -- local qualityColorTb = {ccc3(255,255,255),ccc3(87,205,59),ccc3(26,118,232),ccc3(120,55,218),ccc3(231,112,33)}
        local equipList = airShipVoApi:getAirShipCfg().airship[self.curAirShipId].equipId
        local function refreshEquipQuality(equipIdx)
            local quality = (airShipInfo and airShipInfo[2] and airShipInfo[2][equipList[equipIdx]]) and airShipInfo[2][equipList[equipIdx]] or 0
            local deviceBtn
            if self.curAirShipId ~= 1 then
                local posx, posy
                local gzQualitySp = tolua.cast(self.gzQualitySpTb[equipIdx], "CCSprite")
                if gzQualitySp then
                    posx, posy = gzQualitySp:getPositionX(), gzQualitySp:getPositionY()
                    gzQualitySp:removeFromParentAndCleanup(true)
                    self.gzQualitySpTb[equipIdx] = nil
                else
                    posx = G_getCenterSx(self.rBtn:getContentSize().width, 18, 2, 58) + math.floor((equipIdx - 1) / 3) * (58 + 18)
                    posy = self.rBtn:getContentSize().height - G_getCenterSx(self.rBtn:getContentSize().height, 3, 3, 5) - ((equipIdx % 3 == 0 and 3 or equipIdx % 3) - 1) * (5 + 3)
                end
                if quality > 0 then
                    gzQualitySp = CCSprite:createWithSpriteFrameName("airship_gzqa_"..quality..".png")
                else
                    gzQualitySp = GraySprite:createWithSpriteFrameName("airship_gzqa_1.png")
                end
                gzQualitySp:setPosition(posx, posy)
                self.rBtn:addChild(gzQualitySp)
                self.gzQualitySpTb[equipIdx] = gzQualitySp
                
                deviceBtn = tolua.cast(self.bShipEquipBtnTb[equipIdx], "CCSprite")
            else
                deviceBtn = tolua.cast(self.tShipEquipBtnTb[equipIdx], "CCSprite")
            end
            if deviceBtn then
                local deviceQualitySp = tolua.cast(self.btnQualitySpTb[equipIdx], "CCSprite")--按钮品质图
                if deviceQualitySp then
                    deviceQualitySp:removeFromParentAndCleanup(true)
                    self.btnQualitySpTb[equipIdx] = nil
                end
                if quality > 0 then
                    deviceQualitySp = CCSprite:createWithSpriteFrameName("arpl_dbquality_"..quality..".png")
                else
                    deviceQualitySp = GraySprite:createWithSpriteFrameName("arpl_dbquality_1.png")
                end
                deviceQualitySp:setPosition(getCenterPoint(deviceBtn))
                deviceBtn:addChild(deviceQualitySp, 3)
                if (self.curAirShipId == 1 and equipIdx > 2) or (self.curAirShipId ~= 1 and equipIdx > 3) then
                    deviceQualitySp:setFlipX(true)
                end
                self.btnQualitySpTb[equipIdx] = deviceQualitySp
            end
        end
        if params == nil then --刷新全部装置品质显示
            local posx, posy = 0, 0
            for k, v in pairs(equipList) do
                refreshEquipQuality(k)
            end
        elseif params.equipIdx then --刷新指定装置品质显示
            refreshEquipQuality(params.equipIdx)
        end
    elseif key == "equipRedTip" then --装置红点刷新
        local airship = airShipVoApi:getAirShipCfg().airship
        for k, v in pairs(airship[self.curAirShipId].equipId) do
            local deviceBtn
            if self.curAirShipId == 1 then
                deviceBtn = tolua.cast(self.tShipEquipBtnTb[k], "CCSprite")
            else
                deviceBtn = tolua.cast(self.bShipEquipBtnTb[k], "CCSprite")
            end
            if deviceBtn then
                self:refreshEquipRedTip(deviceBtn, self.curAirShipId, k)
            end
        end
        if self.curAirShipId and self.oldDeviceBtnIndex then
            --激活按钮上的红点
            if self.activationEquipBtn and tolua.cast(self.activationEquipBtn, "CCMenuItemSprite") then
                local flag = airShipVoApi:getTip(2, {aid = self.curAirShipId, equipIdx = self.oldDeviceBtnIndex})
                local btnRedTipSp = tolua.cast(self.activationEquipBtn:getChildByTag(999), "CCSprite")
                if btnRedTipSp then
                    if flag > 0 then
                        btnRedTipSp:setVisible(true)
                    else
                        btnRedTipSp:setVisible(false)
                    end
                end
            end
        end
    end
end

--刷新装置红点提示
function airShipInfoDialog:refreshEquipRedTip(deviceBtn, aid, equipIdx)
    if deviceBtn == nil then
        do return end
    end
    local flag = airShipVoApi:getTip(2, {aid = aid, equipIdx = equipIdx})
    local redTipSp = tolua.cast(deviceBtn:getChildByTag(999), "CCSprite")
    if flag > 0 then --该装置可以激活或改造
        if redTipSp then
            redTipSp:setVisible(true)
        else
            redTipSp = CCSprite:createWithSpriteFrameName("NumBg.png")
            redTipSp:setTag(999)
            redTipSp:setScale(0.6)
            redTipSp:setPosition(((aid == 1 and equipIdx > 2) or (aid ~= 1 and equipIdx > 3)) and 0 or deviceBtn:getContentSize().width, deviceBtn:getContentSize().height - 12)
            deviceBtn:addChild(redTipSp, 11)
        end
    else
        if redTipSp then
            redTipSp:setVisible(false)
        end
    end
end

function airShipInfoDialog:unClickBtnPanel()
    for i = 1, 2 do
        local maskSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function() end)
        maskSp:setContentSize(CCSizeMake(30, self.upBgHeight))
        maskSp:setOpacity(0)
        maskSp:setPosition(i == 1 and 0 or self.upBgWidth, self.upBgHeight * 0.5)
        maskSp:setTouchPriority(-(self.layerNum - 1) * 20 - 100)
        maskSp:setIsSallow(true)
        
        self.upBg:addChild(maskSp, 80)
    end
    
    local unClickUpbgSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function() end)
    unClickUpbgSp:setContentSize(CCSizeMake(self.upBgWidth, self.upBgHeight))
    unClickUpbgSp:setOpacity(0)
    unClickUpbgSp:setPosition(self.upBgWidth * 0.5, self.upBgHeight * 5.5)
    unClickUpbgSp:setTouchPriority(-(self.layerNum - 1) * 20 - 100)
    unClickUpbgSp:setIsSallow(true)
    self.upBg:addChild(unClickUpbgSp, 80)
    self.unClickUpbgSp = unClickUpbgSp
end
