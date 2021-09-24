local tankWarehouseRepairSmalldialog = smallDialog:new()

function tankWarehouseRepairSmalldialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function tankWarehouseRepairSmalldialog:showRepairConfirmDialog(buildVo, layerNum, repairHandler)
    local sd = tankWarehouseRepairSmalldialog:new()
    sd:initRepairConfirmDialog(buildVo, layerNum, repairHandler)
end

function tankWarehouseRepairSmalldialog:initRepairConfirmDialog(buildVo, layerNum, repairHandler)
    self.layerNum = layerNum
    self.isTouch = false
    self.isUseAmi = true
    
    local dialogWidth, dialogHeight = 550, 120
    
    local fontSize = 22
    local buffContentHeight = 0
    local buffLayer = CCNode:create()
    local buffTipLb = GetTTFLabel(getlocal("effect"), fontSize)
    buffTipLb:setAnchorPoint(ccp(0, 1))
    buffTipLb:setPosition(0, -buffContentHeight)
    buffLayer:addChild(buffTipLb)
    
    local rate, pnum, troopsNum = buildingVoApi:getRepairFactoryBuff(buildVo.level + 1)
    local descTb = {getlocal("repair_factory_desc1", {rate * 100}), getlocal("repair_factory_desc2", {pnum}), getlocal("repair_factory_desc3", {troopsNum})}
    for k, v in pairs(descTb) do
        local buffLb, lbHeight = G_getRichTextLabel(v, {nil, G_ColorGreen, nil}, fontSize, dialogWidth - buffTipLb:getContentSize().width - 60, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        buffLb:setAnchorPoint(ccp(0, 1))
        buffLb:setPosition(ccp(buffTipLb:getPositionX() + buffTipLb:getContentSize().width, -buffContentHeight))
        buffLayer:addChild(buffLb)
        
        buffContentHeight = buffContentHeight + lbHeight
    end
    
    dialogHeight = dialogHeight + buffContentHeight + 20
    
    local conditionLb = GetTTFLabel(getlocal("repair_upgrade_condition"), fontSize)
    conditionLb:setAnchorPoint(ccp(0, 1))
    
    local propIconWidth = 60
    local needCommandLv, prop = buildingVoApi:getRepairFactoryUpgradeCondition(buildVo.level + 1)
    
    --指挥中心等级需求
    local conditionLb1, lbHeight1 = G_getRichTextLabel(getlocal("commandcenter_needLv", {needCommandLv}), {nil, G_ColorGreen, nil}, fontSize, dialogWidth - conditionLb:getContentSize().width - 150, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    conditionLb1:setAnchorPoint(ccp(0, 1))
    dialogHeight = dialogHeight + lbHeight1 + propIconWidth + 30
    
    self.bgSize = CCSizeMake(dialogWidth, dialogHeight)
    local dialogBg = G_getNewDialogBg2(self.bgSize, self.layerNum, nil, getlocal("repair_factory")..getlocal("fightLevel", {buildVo.level + 1}), 25, G_ColorWhite, "Helvetica-bold")
    self.dialogLayer = CCLayer:create()
    self.bgLayer = dialogBg
    self:show()
    
    local kuangSp = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png", CCRect(20, 20, 1, 1), function () end)
    kuangSp:setContentSize(CCSizeMake(dialogWidth - 40, dialogHeight - 120))
    kuangSp:setPosition(dialogWidth / 2, 90 + kuangSp:getContentSize().height / 2)
    self.bgLayer:addChild(kuangSp)
    
    buffLayer:setPosition(20, kuangSp:getContentSize().height - 10)
    kuangSp:addChild(buffLayer)
    
    conditionLb:setPosition(20, buffLayer:getPositionY() - buffContentHeight - 10)
    kuangSp:addChild(conditionLb)
    
    conditionLb1:setPosition(conditionLb:getPositionX() + conditionLb:getContentSize().width, conditionLb:getPositionY())
    kuangSp:addChild(conditionLb1)
    
    local stateSp = CCSprite:createWithSpriteFrameName("IconCheck.png")
    stateSp:setAnchorPoint(ccp(0.5, 0.5))
    stateSp:setPosition(kuangSp:getContentSize().width - 70, conditionLb1:getPositionY() - lbHeight1 / 2)
    kuangSp:addChild(stateSp)
    self.stateSp = stateSp
    
    local propIconSp = G_getItemIcon(prop)
    propIconSp:setScale(propIconWidth / propIconSp:getContentSize().width)
    propIconSp:setAnchorPoint(ccp(0, 0.5))
    propIconSp:setPosition(conditionLb1:getPositionX(), conditionLb1:getPositionY() - lbHeight1 - propIconWidth / 2 - 20)
    kuangSp:addChild(propIconSp)

    local propNum = bagVoApi:getItemNumId(prop.id)
    local numLb = GetTTFLabel(getlocal("curProgressStr",{propNum,FormatNumber(prop.num)}), 18)
    numLb:setAnchorPoint(ccp(0, 0.5))
    numLb:setScale(1 / propIconSp:getScale())
    numLb:setPosition(ccp(propIconSp:getContentSize().width + 10 , propIconSp:getContentSize().height * 0.5))
    propIconSp:addChild(numLb, 4)
    local numBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function ()end)
    numBg:setAnchorPoint(ccp(0, 0.5))
    numBg:setContentSize(CCSizeMake(numLb:getContentSize().width * numLb:getScale() + 5, numLb:getContentSize().height * numLb:getScale() - 5))
    numBg:setPosition(ccp(propIconSp:getContentSize().width + 10 , propIconSp:getContentSize().height * 0.5))
    numBg:setOpacity(150)
    propIconSp:addChild(numBg, 3)
    self.propNumLb = numLb
    
    local stateSp2 = CCSprite:createWithSpriteFrameName("IconFault.png")
    stateSp2:setAnchorPoint(ccp(0.5, 0.5))
    stateSp2:setPosition(kuangSp:getContentSize().width - 70, propIconSp:getPositionY())
    kuangSp:addChild(stateSp2)
    self.stateSp2 = stateSp2

    local needPropNum = propNum < prop.num and prop.num - propNum or nil
    local needGems = needPropNum and needPropNum * propCfg[prop.key].gemCost or nil

    local function refresh()
        local upgradeFlag = true
        local commandLv = buildingVoApi:getBuildiingVoByBId(1).level
        local propNum = bagVoApi:getItemNumId(prop.id)
        local stateSpFrame
        if commandLv < needCommandLv then
            upgradeFlag = false
            stateSpFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("IconFault.png")
        else
            stateSpFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("IconCheck.png")
        end
        self.stateSp:setDisplayFrame(stateSpFrame)
        local stateSpFrame2
        if propNum < prop.num then
            -- upgradeFlag = false
            self.propNumLb:setColor(G_ColorRed)
            stateSpFrame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("IconFault.png")
            -- self.addBtn:setEnabled(true)
            -- self.addMenu:setVisible(true)
            -- self.stateSp2:setVisible(false)
        else
            self.propNumLb:setColor(G_ColorWhite)
            stateSpFrame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("IconCheck.png")
            -- self.addBtn:setEnabled(false)
            -- self.addMenu:setVisible(false)
            -- self.stateSp2:setVisible(true)
        end
        self.stateSp2:setDisplayFrame(stateSpFrame2)
        if upgradeFlag == false then
            self.upgradeBtn:setEnabled(false)
        else
            self.upgradeBtn:setEnabled(true)
        end
    end
    
    -- local function buyProp()
    --     local function buyCallBack()
    --         refresh()
    --     end
    --     G_showBatchBuyPropSmallDialog(prop.key, self.layerNum + 1, buyCallBack, nil, 1000, truePrice, "repairFactory.buyprop")
    -- end
    -- self.addBtn, self.addMenu = G_createBotton(kuangSp, ccp(kuangSp:getContentSize().width - 70, propIconSp:getPositionY()), {}, "sYellowAddBtn.png", "sYellowAddBtnDown.png", "sYellowAddBtn.png", buyProp, 0.8, -(self.layerNum - 1) * 20 - 4)
    
    local btnScale, priority, btnPosy = 0.7, -(self.layerNum - 1) * 20 - 3, 45
    local function cancel()
        self:close()
    end
    local cancelBtn, cancelMenu = G_createBotton(self.bgLayer, ccp(dialogWidth / 2 - 120, btnPosy), {getlocal("cancel")}, "newGrayBtn.png", "newGrayBtn_Down.png", "newGrayBtn.png", cancel, btnScale, priority, btnPosy)
    
    local function upgrade()
        if needGems then
            local function sureCallBack( )
                if needGems > playerVoApi:getGems() then
                    GemsNotEnoughDialog(nil,nil,needGems - playerVoApi:getGems(),layerNum+1,needGems)
                    do return end
                end
                if repairHandler then
                    repairHandler(true)
                    self:close()
                end    
            end 
            G_showSureAndCancle(getlocal("emblem_upgrade_no_prop",{needGems}),sureCallBack)
        else
            if repairHandler then
                repairHandler()
                self:close()
            end
        end
    end
    self.upgradeBtn, self.upgradeMenu = G_createBotton(self.bgLayer, ccp(dialogWidth / 2 + 120, btnPosy), {getlocal("upgradeBuild")}, "creatRoleBtn.png", "creatRoleBtn_Down.png", "creatRoleBtn_Down.png", upgrade, btnScale, priority, btnPosy)
    
    refresh()
    
    local function touchDialog()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), touchDialog);
    touchDialogBg:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
    local rect = CCSizeMake(640, G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(0.7 * 255)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg, 1)
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 2)
    self.dialogLayer:setPosition(ccp(0, 0))
    self.dialogLayer:setTouchPriority(-(layerNum - 1) * 20 - 1)
    self:userHandler()
    
    sceneGame:addChild(self.dialogLayer, layerNum)
    
    return self.dialogLayer
end

return tankWarehouseRepairSmalldialog
