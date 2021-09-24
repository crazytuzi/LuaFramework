AITroopsSkillSmallDialog = smallDialog:new()

function AITroopsSkillSmallDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

--继承提升页面
--id：部队id，skillPos：部队上的第几个技能
function AITroopsSkillSmallDialog:showUpgradeDialog(id, skillPos, layerNum)
    local sd = AITroopsSkillSmallDialog:new()
    sd:initUpgradeDialg(id, skillPos, layerNum)
end

function AITroopsSkillSmallDialog:initUpgradeDialg(id, skillPos, layerNum)
    local function addRes()
        spriteController:addPlist("public/aiTroopsImage/aitroops_effect1.plist")
        spriteController:addTexture("public/aiTroopsImage/aitroops_effect1.png")
        spriteController:addPlist("public/aiTroopsImage/aitroops_effect2.plist")
        spriteController:addTexture("public/aiTroopsImage/aitroops_effect2.png")
    end
    G_addResource8888(addRes)
    
    self.isTouch, self.isUseAmi, self.layerNum = true, true, layerNum
    self.troopsVo = AITroopsVoApi:getTroopsById(id)
    self.skill = self.troopsVo:getSkillByPos(skillPos)
    
    local function close()
        spriteController:removePlist("public/aiTroopsImage/aitroops_effect1.plist")
        spriteController:removeTexture("public/aiTroopsImage/aitroops_effect1.png")
        spriteController:removePlist("public/aiTroopsImage/aitroops_effect2.plist")
        spriteController:removeTexture("public/aiTroopsImage/aitroops_effect2.png")
        if self.overTodayListener then
            eventDispatcher:removeEventListener("aitroops.over.today", self.overTodayListener)
            self.overTodayListener = nil
        end
        return self:close()
    end
    
    local dialogBgWidth, dialogBgHeight = 550, 220
    local skillIconSize = 80
    dialogBgHeight = dialogBgHeight + skillIconSize + 40 --上下20间距
    
    local tvHeight = 220
    local cellWidth, cellHeight, scrollFlag = dialogBgWidth - 30, 0, false
    local nameFontSize, descFontSize, descFontWidth = 22, 20, cellWidth - 30
    
    cellHeight = cellHeight + 2 * 32
    
    local sid, lv = self.skill.sid, self.skill.lv
    self.lastLv = lv
    local maxLv, nextExp, needTroopLv = AITroopsVoApi:getSkillInfo(sid, lv)
    local nameStr, desc, colorTb = AITroopsVoApi:getSkillNameAndDesc(sid, lv)
    local descLb, lbHeight = G_getRichTextLabel(desc, colorTb, descFontSize, descFontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    cellHeight = cellHeight + lbHeight + 30
    if lv >= maxLv then --已达最大等级
        descLb = GetTTFLabelWrap(getlocal("allianceSkillLevelMax"), descFontSize, CCSize(descFontWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        cellHeight = cellHeight + descLb:getContentSize().height + 30
    else --下一等级
        nameStr, desc, colorTb = AITroopsVoApi:getSkillNameAndDesc(sid, lv + 1)
        descLb, lbHeight = G_getRichTextLabel(desc, colorTb, descFontSize, descFontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        cellHeight = cellHeight + lbHeight + 30
    end
    
    if cellHeight < tvHeight then
        tvHeight = cellHeight
        scrollFlag = false
    end
    dialogBgHeight = dialogBgHeight + tvHeight + 20
    
    local expBarWidth, expBarHeight = 350, 30 --经验条的宽度和高度
    
    dialogBgHeight = dialogBgHeight + expBarHeight + 70
    
    self.bgSize = CCSizeMake(dialogBgWidth, dialogBgHeight)
    
    local dialogBg = G_getNewDialogBg(self.bgSize, getlocal("heroSkillUpdate"), 28, nil, self.layerNum, true, close)
    self.bgLayer = dialogBg
    
    self.dialogLayer = CCLayer:create()
    self:show()
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 2)
    self.dialogLayer:setTouchPriority(-(layerNum - 1) * 20 - 1)
    self.dialogLayer:setBSwallowsTouches(true)
    
    local contentSize = CCSizeMake(cellWidth, dialogBgHeight - 220)
    local contentBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function () end)
    contentBg:setContentSize(contentSize)
    contentBg:setAnchorPoint(ccp(0.5, 1))
    contentBg:setPosition(dialogBgWidth / 2, dialogBgHeight - 80)
    self.bgLayer:addChild(contentBg)
    
    --技能图标
    local skillIconSp = AITroopsVoApi:getSkillIcon(sid)
    skillIconSp:setAnchorPoint(ccp(0, 0.5))
    skillIconSp:setScale(skillIconSize / skillIconSp:getContentSize().width)
    skillIconSp:setPosition(15, contentSize.height - skillIconSize * 0.5 - 20)
    contentBg:addChild(skillIconSp)
    --技能名称
    local nameLb = GetTTFLabelWrap(nameStr, nameFontSize, CCSizeMake(contentSize.width - 140, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    nameLb:setAnchorPoint(ccp(0, 1))
    nameLb:setPosition(skillIconSp:getPositionX() + skillIconSize + 10, skillIconSp:getPositionY() + skillIconSize * 0.5 - 8)
    contentBg:addChild(nameLb)
    --技能等级上限
    local levelLimitLb = GetTTFLabelWrap(getlocal("skillLvLimit") .. ": " .. maxLv, nameFontSize, CCSizeMake(contentSize.width - 140, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    levelLimitLb:setAnchorPoint(ccp(0, 1))
    levelLimitLb:setPosition(nameLb:getPositionX(), nameLb:getPositionY() - nameLb:getContentSize().height - 10)
    contentBg:addChild(levelLimitLb)
    
    local lockScale = 0.5
    
    local function refresh()
        self.troopsVo = AITroopsVoApi:getTroopsById(id)
        self.skill = self.troopsVo:getSkillByPos(skillPos)
        local maxLv, nextExp, needTroopLv = AITroopsVoApi:getSkillInfo(self.skill.sid, self.skill.lv)
        self.lastSkillExp, self.lastNextExp = self.skill.exp, nextExp
        if self.skill.lv >= maxLv then
            self.expProgressSp:setPercentage(100)
            if self.expProgressLb then
                self.expProgressLb:setString(getlocal("alliance_lvmax"))
            end
            if self.unlockSp then
                self.unlockSp:setVisible(false)
            end
        else
            if self.expProgressSp and tolua.cast(self.expProgressSp:getChildByTag(12), "CCLabelTTF") then
                local per = math.floor(self.skill.exp / nextExp * 100)
                self.expProgressSp:setPercentage(per)
                if self.expProgressLb then
                    self.expProgressLb:setString(self.skill.exp .. "/" .. nextExp)
                end
            end
            
            maxLv, nextExp, needTroopLv = AITroopsVoApi:getSkillInfo(self.skill.sid, self.skill.lv + 1)
            if self.unlockSp then
                if self.troopsVo.lv < needTroopLv then --升级到下一级有部队等级限制
                    self.unlockSp:setVisible(true)
                    self.unlockSp:setScale(lockScale)
                else
                    self.unlockSp:setVisible(false)
                end
            end
        end
        if self.lastLv ~= self.skill.lv then --技能等级发生了变化则刷新技能描述相关
            if self.curLvLb then
                self.curLvLb:setString(getlocal("fightLevel", {self.skill.lv}))
            end
            if self.descTv then
                self.descTv:reloadData()
            end
            --技能等级发生变化影响部队战斗力则需要通知刷新
            eventDispatcher:dispatchEvent("aitroops.list.refresh", {atid = self.troopsVo.id})
            eventDispatcher:dispatchEvent("aitroops.detail.refresh", {rtype = 3})
        else
            eventDispatcher:dispatchEvent("aitroops.detail.refresh", {rtype = 2})
        end
        if self.propOwnLb and self.fragmentOwnLb and self.fragmentUpgradeItem and self.propUpgradeItem then
            local propCost = AITroopsVoApi:getTroopsSkillUpgradeCost(1) --经验道具消耗
            local fragmentCost = AITroopsVoApi:getTroopsSkillUpgradeCost(2) --碎片消耗
            local propOwn = AITroopsVoApi:getPropNumById("p1")
            local fragmentOwn = AITroopsVoApi:getTroopsFragment(self.troopsVo.id)
            
            local fontWidth, fontSize = 150, 22
            if self.propUpgradeLb then
                self.propUpgradeLb:removeFromParentAndCleanup(true)
                self.propUpgradeLb = nil
            end
            if self.fragmentUpgradeLb then
                self.fragmentUpgradeLb:removeFromParentAndCleanup(true)
                self.fragmentUpgradeLb = nil
            end
            local propUpgradeLb, propUpgradeLbHeight = G_getRichTextLabel(getlocal("aitroops_skillupgrade_btnStr", {propCost}), {nil, G_ColorYellowPro, nil}, fontSize, fontWidth, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
            propUpgradeLb:setAnchorPoint(ccp(0.5,1))
            propUpgradeLb:setPosition(self.propUpgradeItem:getContentSize().width / 2, self.propUpgradeItem:getContentSize().height / 2 + propUpgradeLbHeight / 2 + 3)
            propUpgradeLb:setScale(1 / self.propUpgradeItem:getScale())
            self.propUpgradeItem:addChild(propUpgradeLb)
            self.propUpgradeLb = propUpgradeLb
            
            local fragmentUpgradeLb, fragmentUpgradeLbHeight = G_getRichTextLabel(getlocal("aitroops_skillupgrade_btnStr", {fragmentCost}), {nil, G_ColorYellowPro, nil}, fontSize, fontWidth, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
            fragmentUpgradeLb:setAnchorPoint(ccp(0.5,1))
            fragmentUpgradeLb:setPosition(self.fragmentUpgradeItem:getContentSize().width / 2, self.fragmentUpgradeItem:getContentSize().height / 2 + fragmentUpgradeLbHeight / 2 + 3)
            fragmentUpgradeLb:setScale(1 / self.fragmentUpgradeItem:getScale())
            self.fragmentUpgradeItem:addChild(fragmentUpgradeLb)
            self.fragmentUpgradeLb = fragmentUpgradeLb
            
            self.propOwnLb:setString(getlocal("propOwned") .. FormatNumber(propOwn))
            self.fragmentOwnLb:setString(getlocal("propOwned") .. FormatNumber(fragmentOwn))
            if propCost > propOwn then
                self.propOwnLb:setColor(G_ColorRed)
            else
                self.propOwnLb:setColor(G_ColorWhite)
            end
            if fragmentCost > fragmentOwn then
                self.fragmentOwnLb:setColor(G_ColorRed)
            else
                self.fragmentOwnLb:setColor(G_ColorWhite)
            end
        end
        self.lastLv = self.skill.lv
    end
    
    local tvPosY = skillIconSp:getPositionY() - skillIconSize * 0.5 - tvHeight - 20
    
    local isMoved = false
    local function tvCallBack(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            return 1
        elseif fn == "tableCellSizeForIndex" then
            local tmpSize = CCSizeMake(cellWidth, cellHeight)
            return tmpSize
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            
            --当前效果
            local curLbBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png", CCRect(105, 16, 1, 1), function()end)
            curLbBg:setAnchorPoint(ccp(0, 1))
            curLbBg:setContentSize(CCSizeMake(cellWidth - 10, curLbBg:getContentSize().height))
            curLbBg:setPosition(10, cellHeight)
            cell:addChild(curLbBg)
            local curEffectLb = GetTTFLabel(getlocal("currentEffectStr"), nameFontSize, true)
            curEffectLb:setAnchorPoint(ccp(0, 0.5))
            curEffectLb:setPosition(10, curLbBg:getContentSize().height / 2)
            curEffectLb:setColor(G_ColorYellowPro)
            curLbBg:addChild(curEffectLb)
            --当前技能描述
            local nameStr, desc, colorTb = AITroopsVoApi:getSkillNameAndDesc(self.skill.sid, self.skill.lv)
            local descLb, lbHeight = G_getRichTextLabel(desc, colorTb, descFontSize, descFontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
            descLb:setAnchorPoint(ccp(0, 1))
            descLb:setPosition(curLbBg:getPositionX() + 10, curLbBg:getPositionY() - curLbBg:getContentSize().height - 15)
            cell:addChild(descLb)
            
            --下一等级效果
            local nextLbBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png", CCRect(105, 16, 1, 1), function()end)
            nextLbBg:setAnchorPoint(ccp(0, 1))
            nextLbBg:setContentSize(CCSizeMake(cellWidth - 10, nextLbBg:getContentSize().height))
            nextLbBg:setPosition(10, descLb:getPositionY() - lbHeight - 15)
            cell:addChild(nextLbBg)
            local nextEffectLb = GetTTFLabel(getlocal("nextLevelStr"), nameFontSize, true)
            nextEffectLb:setAnchorPoint(ccp(0, 0.5))
            nextEffectLb:setPosition(10, nextLbBg:getContentSize().height / 2)
            nextEffectLb:setColor(G_ColorYellowPro)
            nextLbBg:addChild(nextEffectLb)
            
            if self.skill.lv >= maxLv then --已达最大等级
                local maxTipLb = GetTTFLabelWrap(getlocal("allianceSkillLevelMax"), descFontSize, CCSize(descFontWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                maxTipLb:setAnchorPoint(ccp(0, 1))
                maxTipLb:setPosition(nextLbBg:getPositionX() + 10, nextLbBg:getPositionY() - nextLbBg:getContentSize().height - 15)
                cell:addChild(maxTipLb)
            else
                --下一等级技能描述
                nameStr, desc, colorTb = AITroopsVoApi:getSkillNameAndDesc(self.skill.sid, self.skill.lv + 1)
                local nextDescLb, nextDescLbHeight = G_getRichTextLabel(desc, colorTb, descFontSize, descFontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                nextDescLb:setAnchorPoint(ccp(0, 1))
                nextDescLb:setPosition(nextLbBg:getPositionX() + 10, nextLbBg:getPositionY() - nextLbBg:getContentSize().height - 15)
                cell:addChild(nextDescLb)
            end
            
            return cell
        elseif fn == "ccTouchBegan" then
            isMoved = false
            return true
        elseif fn == "ccTouchMoved" then
            isMoved = true
        elseif fn == "ccTouchEnded" then
            
        end
    end
    local hd = LuaEventHandler:createHandler(tvCallBack)
    self.descTv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(cellWidth, tvHeight), nil)
    self.descTv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.descTv:setPosition(ccp(0, tvPosY))
    contentBg:addChild(self.descTv)
    if scrollFlag == true then
        self.descTv:setMaxDisToBottomOrTop(120)
    else
        self.descTv:setMaxDisToBottomOrTop(0)
    end
    
    --分割线
    local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
    lineSp:setAnchorPoint(ccp(0.5, 0))
    lineSp:setContentSize(CCSizeMake(contentSize.width - 18, lineSp:getContentSize().height))
    lineSp:setRotation(180)
    lineSp:setPosition(contentSize.width / 2, tvPosY - 2)
    contentBg:addChild(lineSp)
    
    local curLvLb = GetTTFLabel(getlocal("fightLevel", {self.skill.lv}), nameFontSize)
    curLvLb:setAnchorPoint(ccp(1, 0.5))
    curLvLb:setPosition(contentSize.width / 2 - expBarWidth / 2 - 5, tvPosY - curLvLb:getContentSize().height / 2 - 60)
    contentBg:addChild(curLvLb)
    self.curLvLb = curLvLb
    
    local pos = ccp(contentSize.width / 2, curLvLb:getPositionY())
    local expProgressSp = AddProgramTimer(contentBg, pos, 9, 12, "", "TeamTravelBarBg.png", "TeamTravelBar.png", 11, nil, nil, nil, nil, nameFontSize)
    local expProgressBg = tolua.cast(contentBg:getChildByTag(11), "CCSprite")
    local scaleX = expBarWidth / expProgressSp:getContentSize().width
    local scaleY = expBarHeight / expProgressSp:getContentSize().height
    expProgressSp:setAnchorPoint(ccp(0.5, 0.5))
    expProgressBg:setAnchorPoint(ccp(0.5, 0.5))
    expProgressSp:setScaleX(scaleX)
    expProgressSp:setScaleY(scaleY)
    expProgressBg:setScaleX(scaleX)
    expProgressBg:setScaleY(scaleY)
    self.expProgressSp = expProgressSp
    local expProgressLb = GetTTFLabelWrap("", nameFontSize, CCSize(expBarWidth, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    expProgressLb:setPosition(expProgressSp:getPositionX(), expProgressSp:getPositionY())
    contentBg:addChild(expProgressLb, 4)
    self.expProgressLb = expProgressLb
    
    local function checkLvTip()
        if self.unlockSp == nil or self.unlockSp:isVisible() == false then
            do return end
        end
        local function realTip()
            local maxLv, nextExp, needTroopLv = AITroopsVoApi:getSkillInfo(self.skill.sid, self.skill.lv + 1)
            if self.troopsVo.lv < needTroopLv then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("aitroops_skillupgrade_tip2", {needTroopLv}), 28)
            end
        end
        G_touchedItem(self.unlockSp, realTip, lockScale * 0.8)
    end
    local unlockSp = LuaCCSprite:createWithSpriteFrameName("aitroops_lock.png", checkLvTip)
    unlockSp:setAnchorPoint(ccp(0.5, 0.5))
    unlockSp:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    unlockSp:setScale(lockScale)
    unlockSp:setPosition(expProgressSp:getPositionX() + expBarWidth / 2 - 5, curLvLb:getPositionY())
    contentBg:addChild(unlockSp, 5)
    self.unlockSp = unlockSp
    
    local function removeUpgradeEffect(callback)
        if self.actionLayer then
            self.actionLayer:removeFromParentAndCleanup(true)
            self.actionLayer = nil
        end
        if self.progressScheduler then
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.progressScheduler)
            self.progressScheduler = nil
        end
        if self.actionFlag == true then
            if callback then
                callback()
            end
        end
        self.actionFlag = false
    end
    
    local function playUpgradeEffect(expRate, callback)
        if self.actionLayer == nil then
            local actionLayer = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function () end)
            actionLayer:setContentSize(contentSize)
            actionLayer:setOpacity(0)
            actionLayer:setAnchorPoint(ccp(0.5, 1))
            actionLayer:setPosition(contentBg:getPosition())
            self.bgLayer:addChild(actionLayer, 5)
            self.actionLayer = actionLayer
        end
        
        self.actionFlag = true
        local troopsVo = AITroopsVoApi:getTroopsById(id)
        local skill = troopsVo:getSkillByPos(skillPos)
        local sid = skill.sid
        local totalAddExp = AITroopsVoApi:getSkillAddExpByRate(expRate)
        local exp, needExp = self.lastSkillExp, self.lastNextExp
        local realAddExp = 0
        for k = self.lastLv, skill.lv do
            local sMaxLv, sNextExp = AITroopsVoApi:getSkillInfo(sid, k)
            if k == self.lastLv then
                local leftExp = sNextExp - self.lastSkillExp
                if leftExp >= totalAddExp then
                    realAddExp = realAddExp + totalAddExp
                else
                    realAddExp = realAddExp + leftExp
                end
            else
                realAddExp = realAddExp + sNextExp
            end
        end
        if realAddExp > totalAddExp then
            realAddExp = totalAddExp
        end
        
        local ft = 0.03
        local totalTime, timeSpeed, fastTickFlag = 0, 0.4, true
        local expRateShowHeight = 50
        if tonumber(expRate) > 1 then
            expRateShowHeight = 80
        end
        local function progressAction()
            if tonumber(expRate) > 1 then --经验翻倍的话，展示以下特效
                local progressAcSp = CCSprite:createWithSpriteFrameName("aitskill_upgrade_pro1.png")
                local proFrameArr = CCArray:create()
                for k = 1, 6 do
                    local nameStr = "aitskill_upgrade_pro" .. k .. ".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    proFrameArr:addObject(frame)
                end
                local proAni = CCAnimation:createWithSpriteFrames(proFrameArr)
                proAni:setDelayPerUnit(ft)
                local proAnimate = CCAnimate:create(proAni)
                progressAcSp:setAnchorPoint(ccp(0.5, 0.5))
                progressAcSp:setScale(1.25)
                progressAcSp:setPosition(self.expProgressSp:getPositionX(), self.expProgressSp:getPositionY())
                self.actionLayer:addChild(progressAcSp, 3)
                
                local blendFunc = ccBlendFunc:new()
                blendFunc.src = GL_ONE
                blendFunc.dst = GL_ONE
                progressAcSp:setBlendFunc(blendFunc)
                
                local acArr = CCArray:create()
                acArr:addObject(proAnimate)
                local function aniEnd()
                    progressAcSp:removeFromParentAndCleanup(true)
                    progressAcSp = nil
                end
                acArr:addObject(CCCallFunc:create(aniEnd))
                local seq = CCSequence:create(acArr)
                progressAcSp:runAction(seq)
                
                if self.expProgressLb then
                    local acArr = CCArray:create()
                    local scaleTo1 = CCScaleTo:create(3 * ft, 3)
                    local scaleTo2 = CCScaleTo:create(3 * ft, 1)
                    acArr:addObject(scaleTo1)
                    acArr:addObject(scaleTo2)
                    local seq = CCSequence:create(acArr)
                    self.expProgressLb:runAction(seq)
                end
            else
                local progressAcSp = CCSprite:createWithSpriteFrameName("aitskill_upgrade_pro.png")
                progressAcSp:setPosition(self.expProgressSp:getPosition())
                progressAcSp:setScaleX((expBarWidth + 50) / progressAcSp:getContentSize().width)
                progressAcSp:setScaleY((expBarHeight + 50) / progressAcSp:getContentSize().height)
                progressAcSp:setOpacity(0)
                self.actionLayer:addChild(progressAcSp)
                local acArr = CCArray:create()
                local fadeTo1 = CCFadeTo:create(timeSpeed, 255)
                local fadeTo2 = CCFadeTo:create(0.2, 0)
                acArr:addObject(fadeTo1)
                acArr:addObject(fadeTo2)
                local function progressAcEnd()
                    if progressAcSp then
                        progressAcSp:removeFromParentAndCleanup(true)
                        progressAcSp = nil
                    end
                end
                acArr:addObject(CCCallFunc:create(progressAcEnd))
                local seq = CCSequence:create(acArr)
                progressAcSp:runAction(seq)
            end
        end
        
        local skillIconAcSp = CCSprite:createWithSpriteFrameName("aisicon_up_effect1.png")
        local siconFrameArr = CCArray:create()
        for k = 1, 14 do
            local nameStr = "aisicon_up_effect" .. k .. ".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            siconFrameArr:addObject(frame)
        end
        local siconAni = CCAnimation:createWithSpriteFrames(siconFrameArr)
        siconAni:setDelayPerUnit(0.03)
        local siconAnimate = CCAnimate:create(siconAni)
        skillIconAcSp:setAnchorPoint(ccp(0.5, 0.5))
        skillIconAcSp:setScale(1.25)
        skillIconAcSp:setPosition(skillIconSp:getPositionX() + skillIconSize / 2, skillIconSp:getPositionY())
        self.actionLayer:addChild(skillIconAcSp, 3)
        
        local blendFunc = ccBlendFunc:new()
        blendFunc.src = GL_ONE
        blendFunc.dst = GL_ONE
        skillIconAcSp:setBlendFunc(blendFunc)
        
        local acArr = CCArray:create()
        acArr:addObject(siconAnimate)
        local function siconAniEnd()
            skillIconAcSp:removeFromParentAndCleanup(true)
            skillIconAcSp = nil
        end
        acArr:addObject(CCCallFunc:create(siconAniEnd))
        local seq = CCSequence:create(acArr)
        skillIconAcSp:runAction(seq)
        
        local curAddExp, lastAddExp, showLv = 0, 0, self.lastLv
        local function progressFastTick(dt)
            if fastTickFlag == true then
                totalTime = totalTime + dt
                if totalTime > timeSpeed then
                    totalTime = timeSpeed
                end
                lastAddExp = curAddExp
                curAddExp = math.floor(realAddExp * totalTime / timeSpeed)
                local expValue = curAddExp - lastAddExp
                exp = exp + expValue
                if exp >= needExp then
                    showLv = showLv + 1
                    if showLv > skill.lv then
                        showLv = skill.lv
                        exp = needExp
                    else
                        exp = exp - needExp --当前显示等级溢出的经验积累到下一等级显示
                        local maxLv, nextExp, needTroopLv = AITroopsVoApi:getSkillInfo(skill.sid, showLv)
                        needExp = nextExp
                    end
                    if self.curLvLb then
                        self.curLvLb:setString(getlocal("fightLevel", {showLv}))
                    end
                end
                if self.expProgressLb and self.expProgressSp then
                    if showLv >= maxLv then
                        self.expProgressLb:setString(getlocal("alliance_lvmax"))
                        self.expProgressSp:setPercentage(100)
                    else
                        self.expProgressLb:setString(exp .. "/" .. needExp)
                        local per = math.floor(exp / needExp * 100)
                        self.expProgressSp:setPercentage(per)
                    end
                end
                if curAddExp >= realAddExp then --进度条变化结束
                    fastTickFlag = false
                    if tonumber(expRate) > 1 then
                        progressAction()
                    end
                    if self.progressScheduler then
                        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.progressScheduler)
                        self.progressScheduler = nil
                    end
                end
            end
        end
        self.progressScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(progressFastTick, 0, false)
        if tonumber(expRate) == 1 then --如果经验没有翻倍的话，则进度条特效一开始就播放
            progressAction()
        end
        
        --增加的经验显示特效
        local addExpLb = GetTTFLabel("Exp+" .. totalAddExp, nameFontSize, true)
        addExpLb:setPosition(self.expProgressLb:getPosition())
        addExpLb:setOpacity(20)
        addExpLb:setScale(0.5)
        addExpLb:setColor(G_ColorBlue)
        self.actionLayer:addChild(addExpLb, 5)
        
        local targetPosY = addExpLb:getPositionY() + 40
        local addExpAcArr = CCArray:create()
        local expLbFadeTo = CCFadeTo:create(timeSpeed, 255)
        local expLbScaleTo = CCScaleTo:create(timeSpeed, 1.2)
        local expMoveTo1 = CCMoveTo:create(timeSpeed, ccp(addExpLb:getPositionX(), targetPosY - 20))
        local expLbSpawnArr = CCArray:create()
        expLbSpawnArr:addObject(expLbFadeTo)
        expLbSpawnArr:addObject(expLbScaleTo)
        expLbSpawnArr:addObject(expMoveTo1)
        local expLbSpawnAc = CCSpawn:create(expLbSpawnArr)
        addExpAcArr:addObject(expLbSpawnAc) --先渐现放大
        local expMoveTo2 = CCMoveTo:create(3 * ft, ccp(addExpLb:getPositionX(), targetPosY))
        addExpAcArr:addObject(expMoveTo2)
        addExpAcArr:addObject(CCDelayTime:create(0.5))
        local function addExpLbActionEnd() --这个动作视为整个动画结束
            removeUpgradeEffect(callback)
        end
        addExpAcArr:addObject(CCCallFunc:create(addExpLbActionEnd))
        local expLbSeq = CCSequence:create(addExpAcArr)
        addExpLb:runAction(expLbSeq)
        
        --增加经验的背景显示
        local addExpShowBg = CCSprite:createWithSpriteFrameName("newblackFade.png")
        addExpShowBg:setScaleX(200 / addExpShowBg:getContentSize().width)
        addExpShowBg:setScaleY(expRateShowHeight / addExpShowBg:getContentSize().height)
        addExpShowBg:setAnchorPoint(ccp(0.5, 0))
        addExpShowBg:setOpacity(0)
        addExpShowBg:setPosition(contentSize.width / 2, self.expProgressLb:getPositionY() + 15)
        self.actionLayer:addChild(addExpShowBg, 3)
        addExpShowBg:runAction(CCFadeTo:create(timeSpeed / 2, 200))
        
        if tonumber(expRate) > 1 then --如果翻倍的话显示翻倍比例特效
            local expRateLb = GetTTFLabel("x" .. expRate, 40, true)
            expRateLb:setPosition(addExpShowBg:getPositionX(), addExpShowBg:getPositionY() + expRateShowHeight - expRateLb:getContentSize().height / 2 - 5)
            expRateLb:setScale(0)
            expRateLb:setColor(G_ColorYellowPro)
            self.actionLayer:addChild(expRateLb, 5)
            expRateLb:runAction(CCScaleTo:create(timeSpeed / 2, 1))
        end
    end
    
    local btnScale, priority, propSize, btnPosY = 0.8, -(self.layerNum - 1) * 20 - 4, 60, 80
    local function upgrade(upgradeType)
        local battleFlag = AITroopsFleetVoApi:getIsBattled(self.troopsVo.id)
        if battleFlag == true then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("aitroops_used_tip"), 28)
            do return end
        end
        removeUpgradeEffect(refresh) --移除上次升级的效果
        local flag, rv1, rv2 = AITroopsVoApi:checkSkillUpgrade(self.skill, self.troopsVo, upgradeType)
        if flag ~= 1 then --不可升级
            local tipStr = ""
            if flag == 2 then --已达满级
                tipStr = getlocal("allianceSkillLevelMax")
            elseif flag == 3 then --部队等级不够（rv1为所需的部队等级）
                tipStr = getlocal("aitroops_skillupgrade_tip1", {rv1})
            elseif flag == 4 then --升级消耗不够
                tipStr = getlocal("aitroops_troop_upgrade_tip1")
            elseif flag == 5 then --经验已满但不是等级限制不能升级
                tipStr = getlocal("aitroops_skillupgrade_tip2", {rv1})
            end
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tipStr, 28)
            do return end
        end
        local function handler(arg)
            local expRate = 1
            if arg and arg.expRate then
                expRate = arg.expRate
            end
            playUpgradeEffect(expRate, refresh)
        end
        AITroopsVoApi:AITroopsSkillUpgrade(self.troopsVo.id, skillPos, upgradeType, handler)
    end
    --以经验道具方式提升
    local function propUpgrade()
        upgrade(1)
    end
    self.propUpgradeItem, self.propUpgradeMenu = G_createBotton(self.bgLayer, ccp(180, btnPosY), {}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", propUpgrade, btnScale, priority)
    
    --以部队碎片方式提升
    local function fragmentUpgrade()
        upgrade(2)
    end
    self.fragmentUpgradeItem, self.fragmentUpgradeMenu = G_createBotton(self.bgLayer, ccp(440, btnPosY), {}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", fragmentUpgrade, btnScale, priority)
    
    local propId = "p1"
    local fragmentId = AITroopsVoApi:getFragmentIdByTroopsId(id)
    local cost = {at = {{[propId] = 0, index = 1}, {[fragmentId] = 0, index = 2}}}
    local costItem = FormatItem(cost, nil, true)
    
    --经验道具显示
    local propSp = G_getItemIcon(costItem[1], 100)
    propSp:setScale(propSize / propSp:getContentSize().width)
    propSp:setPosition(60, btnPosY)
    self.bgLayer:addChild(propSp)
    local propOwnLb = GetTTFLabel("", 20)
    propOwnLb:setAnchorPoint(ccp(0, 1))
    propOwnLb:setPosition(propSp:getPositionX() - propSize * 0.5, propSp:getPositionY() - propSize * 0.5 - 10)
    self.bgLayer:addChild(propOwnLb)
    self.propOwnLb = propOwnLb
    
    --碎片显示
    local fragmentSp = G_getItemIcon(costItem[2], 100)
    fragmentSp:setScale(propSize / fragmentSp:getContentSize().width)
    fragmentSp:setPosition(320, btnPosY)
    self.bgLayer:addChild(fragmentSp)
    local fragmentOwnLb = GetTTFLabel("", 20)
    fragmentOwnLb:setAnchorPoint(ccp(0, 1))
    fragmentOwnLb:setPosition(fragmentSp:getPositionX() - propSize * 0.5, fragmentSp:getPositionY() - propSize * 0.5 - 10)
    self.bgLayer:addChild(fragmentOwnLb)
    self.fragmentOwnLb = fragmentOwnLb
    
    refresh()
    
    local function overTodayRefresh(event, data)
        --跨天刷新技能升级消耗和按钮状态
        refresh()
    end
    self.overTodayListener = overTodayRefresh
    eventDispatcher:addEventListener("aitroops.over.today", overTodayRefresh)
    
    local function touchLuaSpr()
        
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), touchLuaSpr)
    touchDialogBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    local rect = CCSizeMake(640, G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255 * 0.7)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg, 1)
    self.dialogLayer:setPosition(ccp(0, 0))
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

--技能替换页面
function AITroopsSkillSmallDialog:showExchangeDialog(id, skillPos, layerNum)
    local sd = AITroopsSkillSmallDialog:new()
    sd:initExchangeDialog(id, skillPos, layerNum)
end

function AITroopsSkillSmallDialog:initExchangeDialog(id, skillPos, layerNum)
    self.isTouch, self.isUseAmi, self.layerNum = true, true, layerNum
    self.troopsVo = AITroopsVoApi:getTroopsById(id)
    self.skill = self.troopsVo:getSkillByPos(skillPos)
    
    local function close()
        return self:close()
    end
    
    local dialogBgWidth, dialogBgHeight = 550, 220
    local skillIconSize, titleSize = 80, 60
    dialogBgHeight = dialogBgHeight + 2 * (titleSize + 40)
    
    local nameFontSize, descFontSize, descFontWidth, nameFontWidth, titleFontSize = 22, 20, dialogBgWidth - 60, dialogBgWidth - skillIconSize - 100, 24
    
    local sid, lv = self.skill.sid, self.skill.lv
    self.nextSid = self.skill.nextSid
    self.lastSid = self.nextSid
    
    local nameStr, desc, colorTb = AITroopsVoApi:getSkillNameAndDesc(sid, lv)
    --技能名称
    local nameLb = GetTTFLabelWrap(nameStr, nameFontSize, CCSizeMake(nameFontWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop, "Helvetica-bold")
    --技能等级
    local levelLb = GetTTFLabelWrap(getlocal("world_war_level", {getlocal("fightLevel", {lv})}), nameFontSize, CCSizeMake(nameFontWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    --技能描述
    local descLb, lbHeight = G_getRichTextLabel(desc, colorTb, descFontSize, descFontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    
    -- local csHeight = nameLb:getContentSize().height + levelLb:getContentSize().height + lbHeight + 30 --名称，等级和描述占用空间
    local csHeight = skillIconSize + lbHeight + 30 --图标和技能描述占用空间
    dialogBgHeight = dialogBgHeight + csHeight
    
    local rsHeight = skillIconSize + 100
    -- if self.nextSid == nil then --如果当前还没有刷新出来可替换的技能，则留出空间给刷新出来的技能显示
    --     rsHeight = csHeight
    -- else
    --     -- local nameStr, desc, colorTb = AITroopsVoApi:getSkillNameAndDesc(self.nextSid, 1)
    --     -- local rsNameLb = GetTTFLabelWrap(nameStr, nameFontSize, CCSizeMake(nameFontWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop, "Helvetica-bold")
    --     -- local rsLevelLb = GetTTFLabelWrap(getlocal("world_war_level", {getlocal("fightLevel", {1})}), nameFontSize, CCSizeMake(nameFontWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    --     local rsDescLb, rsLbHeight = G_getRichTextLabel(desc, colorTb, descFontSize, descFontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    --     -- rsHeight = rsHeight + rsNameLb:getContentSize().height + rsLevelLb:getContentSize().height + rsLbHeight + 30 --刷新出来的技能名称，等级和描述占用空间
    --     rsHeight = skillIconSize + rsLbHeight + 30 --图标和技能描述占用空间
    -- end
    
    dialogBgHeight = dialogBgHeight + rsHeight + 20
    self.bgSize = CCSizeMake(dialogBgWidth, dialogBgHeight)
    
    local dialogBg = G_getNewDialogBg(self.bgSize, getlocal("aitroops_skillexchange_title"), 28, nil, self.layerNum, true, close)
    self.bgLayer = dialogBg
    
    self.dialogLayer = CCLayer:create()
    self:show()
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 2)
    self.dialogLayer:setTouchPriority(-(layerNum - 1) * 20 - 1)
    self.dialogLayer:setBSwallowsTouches(true)
    
    local contentSize = CCSizeMake(dialogBgWidth - 30, dialogBgHeight - 210)
    local contentBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function () end)
    contentBg:setContentSize(contentSize)
    contentBg:setAnchorPoint(ccp(0.5, 1))
    contentBg:setPosition(dialogBgWidth / 2, dialogBgHeight - 80)
    self.bgLayer:addChild(contentBg)
    
    local csTitleBg = G_createNewTitle({getlocal("currentEffectStr"), titleFontSize, G_ColorYellowPro}, CCSizeMake(contentSize.width - 60, 0), nil, nil, "Helvetica-bold")
    csTitleBg:setPosition(contentSize.width / 2, contentSize.height - 60)
    contentBg:addChild(csTitleBg)
    --技能图标
    local csIconSp = AITroopsVoApi:getSkillIcon(sid)
    csIconSp:setAnchorPoint(ccp(0, 0.5))
    csIconSp:setScale(skillIconSize / csIconSp:getContentSize().width)
    csIconSp:setPosition(15, csTitleBg:getPositionY() - skillIconSize * 0.5 - 20)
    contentBg:addChild(csIconSp)
    
    nameLb:setAnchorPoint(ccp(0, 1))
    nameLb:setPosition(csIconSp:getPositionX() + skillIconSize + 10, csIconSp:getPositionY() + skillIconSize * 0.5 - 8)
    contentBg:addChild(nameLb)
    
    levelLb:setAnchorPoint(ccp(0, 1))
    levelLb:setPosition(nameLb:getPositionX(), nameLb:getPositionY() - nameLb:getContentSize().height - 10)
    contentBg:addChild(levelLb)
    
    --当前技能效果描述
    descLb:setAnchorPoint(ccp(0, 1))
    -- descLb:setPosition(nameLb:getPositionX(), levelLb:getPositionY() - levelLb:getContentSize().height - 10)
    descLb:setPosition(csIconSp:getPositionX(), csIconSp:getPositionY() - skillIconSize / 2 - 10)
    contentBg:addChild(descLb)
    
    local rsTitleBg = G_createNewTitle({getlocal("aitroops_exchange_skill"), titleFontSize, G_ColorYellowPro}, CCSizeMake(contentSize.width - 60, 0), nil, nil, "Helvetica-bold")
    rsTitleBg:setPosition(contentSize.width / 2, descLb:getPositionY() - lbHeight - 10 - 60)
    contentBg:addChild(rsTitleBg)
    
    local rsPosY = rsTitleBg:getPositionY() - skillIconSize * 0.5 - 20
    
    if self.nextSid == nil then
        local norsTipLb = GetTTFLabelWrap(getlocal("aitroops_no_exchange_skill"), nameFontSize, CCSizeMake(contentSize.width - 30, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        norsTipLb:setPosition(contentSize.width / 2, rsTitleBg:getPositionY() - rsHeight / 2 - 30)
        norsTipLb:setColor(G_ColorGray2)
        contentBg:addChild(norsTipLb)
        self.norsTipLb = norsTipLb
    end
    
    local function showInfo()
        AITroopsVoApi:showSkillWashInfoDialog(id, 1, self.layerNum + 1)
    end
    G_addMenuInfo(contentBg, self.layerNum, ccp(contentSize.width - 70, csIconSp:getPositionY()), nil, nil, 1, nil, showInfo, true, 4)
    
    self.rsIconSp, self.rsNameLb, self.rsLevelLb, self.rsDescTv = nil, nil, nil, nil
    local rsDescTvHeight = 80
    local rsDescCellHeight = 0
    local function refresh(flag)
        if self.propOwnLb and self.refreshItem then
            local propCost = AITroopsVoApi:getSkillRefreshCost() --经验道具消耗
            local propOwn = AITroopsVoApi:getPropNumById("p1")
            
            local fontWidth, fontSize = 150, 22
            if self.refreshLb then
                self.refreshLb:removeFromParentAndCleanup(true)
                self.refreshLb = nil
            end
            local refreshLb, refreshLbHeight = G_getRichTextLabel(getlocal("aitroops_skillrefresh_btnStr", {propCost}), {nil, G_ColorYellowPro, nil}, fontSize, fontWidth, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
            refreshLb:setAnchorPoint(ccp(0.5,1))
            refreshLb:setPosition(self.refreshItem:getContentSize().width / 2, self.refreshItem:getContentSize().height / 2 + refreshLbHeight / 2 + 3)
            refreshLb:setScale(1 / self.refreshItem:getScale())
            self.refreshItem:addChild(refreshLb)
            self.refreshLb = refreshLb
            
            self.propOwnLb:setString(getlocal("propOwned") .. FormatNumber(propOwn))
            if propCost > propOwn then
                self.propOwnLb:setColor(G_ColorRed)
            else
                self.propOwnLb:setColor(G_ColorWhite)
            end
        end
        
        self.troopsVo = AITroopsVoApi:getTroopsById(id)
        self.skill = self.troopsVo:getSkillByPos(skillPos)
        self.nextSid = self.skill.nextSid
        if self.nextSid == nil then
            do return end
        end
        if self.lastSid ~= self.nextSid or flag == true then
            self.newSkillNameStr, self.newSkillDesc, self.newShowColorTb = AITroopsVoApi:getSkillNameAndDesc(self.nextSid, 1)
            local rsDescLb, rsLbHeight = G_getRichTextLabel(self.newSkillDesc, self.newShowColorTb, descFontSize, descFontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
            if self.rsIconSp == nil then
                --技能图标
                local rsIconSp = AITroopsVoApi:getSkillIcon(self.nextSid)
                rsIconSp:setAnchorPoint(ccp(0, 0.5))
                rsIconSp:setScale(skillIconSize / rsIconSp:getContentSize().width)
                rsIconSp:setPosition(15, rsPosY)
                contentBg:addChild(rsIconSp)
                self.rsIconSp = rsIconSp
                --技能名称
                local rsNameLb = GetTTFLabelWrap(self.newSkillNameStr, nameFontSize, CCSizeMake(nameFontWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop, "Helvetica-bold")
                rsNameLb:setAnchorPoint(ccp(0, 1))
                rsNameLb:setPosition(rsIconSp:getPositionX() + skillIconSize + 10, rsIconSp:getPositionY() + skillIconSize * 0.5 - 8)
                contentBg:addChild(rsNameLb)
                self.rsNameLb = rsNameLb
                --技能等级
                local rsLevelLb = GetTTFLabelWrap(getlocal("world_war_level", {getlocal("fightLevel", {1})}), nameFontSize, CCSizeMake(nameFontWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                rsLevelLb:setAnchorPoint(ccp(0, 1))
                rsLevelLb:setPosition(rsNameLb:getPositionX(), rsNameLb:getPositionY() - rsNameLb:getContentSize().height - 10)
                contentBg:addChild(rsLevelLb)
                self.rsLevelLb = rsLevelLb
                
                local rsDescCellHeight = rsLbHeight
                -- local tvPosY = rsLevelLb:getPositionY() - rsLevelLb:getContentSize().height - rsDescTvHeight - 10
                local tvPosY = rsIconSp:getPositionY() - skillIconSize / 2 - rsDescTvHeight - 10
                
                local isMoved = false
                local function tvCallBack(handler, fn, idx, cel)
                    if fn == "numberOfCellsInTableView" then
                        return 1
                    elseif fn == "tableCellSizeForIndex" then
                        local tmpSize = CCSizeMake(contentSize.width, rsDescCellHeight)
                        return tmpSize
                    elseif fn == "tableCellAtIndex" then
                        local cell = CCTableViewCell:new()
                        cell:autorelease()
                        
                        local descLb, lbHeight = G_getRichTextLabel(self.newSkillDesc, self.newShowColorTb, descFontSize, descFontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                        descLb:setAnchorPoint(ccp(0, 1))
                        descLb:setPosition(self.rsIconSp:getPositionX(), rsDescCellHeight)
                        cell:addChild(descLb)
                        
                        return cell
                    elseif fn == "ccTouchBegan" then
                        isMoved = false
                        return true
                    elseif fn == "ccTouchMoved" then
                        isMoved = true
                    elseif fn == "ccTouchEnded" then
                    end
                end
                local hd = LuaEventHandler:createHandler(tvCallBack)
                self.rsDescTv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(contentSize.width, rsDescTvHeight), nil)
                self.rsDescTv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
                self.rsDescTv:setPosition(ccp(0, tvPosY))
                contentBg:addChild(self.rsDescTv)
                self.rsDescTv:setMaxDisToBottomOrTop(0)
            else
                local rsIconSp = AITroopsVoApi:getSkillIcon(self.nextSid)
                rsIconSp:setAnchorPoint(ccp(0, 0.5))
                rsIconSp:setScale(skillIconSize / rsIconSp:getContentSize().width)
                rsIconSp:setPosition(self.rsIconSp:getPositionX(), self.rsIconSp:getPositionY())
                contentBg:addChild(rsIconSp)
                self.rsIconSp:removeFromParentAndCleanup(true)
                self.rsIconSp = rsIconSp
                if self.rsNameLb and self.rsLevelLb and self.rsDescTv then
                    self.rsNameLb:setString(self.newSkillNameStr)
                    self.rsLevelLb:setString(getlocal("world_war_level", {getlocal("fightLevel", {1})}))
                    if rsLbHeight > rsDescTvHeight then
                        self.rsDescTv:setMaxDisToBottomOrTop(80)
                    else
                        self.rsDescTv:setMaxDisToBottomOrTop(0)
                    end
                    rsDescCellHeight = rsLbHeight + 10
                    self.rsDescTv:reloadData()
                end
            end
            self.lastSid = self.nextSid
            eventDispatcher:dispatchEvent("aitroops.detail.refresh", {rtype = 3})
            if self.norsTipLb then
                self.norsTipLb:setVisible(false)
            end
        end
    end
    
    local btnScale, priority, propSize, btnPosY, offsetX = 0.8, -(self.layerNum - 1) * 20 - 4, 60, 80, 160
    --替换技能
    local function exchange()
        local battleFlag = AITroopsFleetVoApi:getIsBattled(self.troopsVo.id)
        if battleFlag == true then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("aitroops_used_tip"), 28)
            do return end
        end
        if self.nextSid == nil then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("aitroops_no_exchange_skill"), 28)
            do return end
        end
        local function realExchange()
            local function handler()
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("hero_honor_change_success"), 28)
                close()
            end
            AITroopsVoApi:AITroopsSkillExchange(self.troopsVo.id, handler)
        end
        -- local desInfo = {25, G_ColorYellowPro, kCCTextAlignmentCenter}
        -- local expReturn = AITroopsVoApi:getExchangeSkillReturnExpPropNum(self.skill.lv)
        -- local addStrTb = {{getlocal("aitroops_skillexchange_tip", {expReturn}), G_ColorRed, 25, kCCTextAlignmentLeft, 20}}
        -- G_showSecondConfirm(self.layerNum + 1, true, true, getlocal("hero_honor_change"), getlocal("aitroops_skillexchange_confirm"), false, realExchange, nil, nil, desInfo, addStrTb)
        AITroopsVoApi:showSkillExchangeConfirmDialog(self.skill, realExchange, self.layerNum + 1)
    end
    self.exchangeItem, self.exchangeMenu = G_createBotton(self.bgLayer, ccp(self.bgSize.width / 2 - offsetX, btnPosY), {getlocal("hero_honor_change"), 22}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", exchange, btnScale, priority)
    
    --刷新可替换技能
    local function refreshSkill()
        local battleFlag = AITroopsFleetVoApi:getIsBattled(self.troopsVo.id)
        if battleFlag == true then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("aitroops_used_tip"), 28)
            do return end
        end
        local propCost = AITroopsVoApi:getSkillRefreshCost() --经验道具消耗
        local propOwn = AITroopsVoApi:getPropNumById("p1")
        if propCost > propOwn then --经验道具不足
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("aitroops_expprop_less"), 28)
            do return end
        end
        local function handler()
            refresh()
        end
        AITroopsVoApi:AITroopsSkillRefresh(self.troopsVo.id, handler)
    end
    self.refreshItem, self.refreshMenu = G_createBotton(self.bgLayer, ccp(self.bgSize.width / 2 + offsetX, btnPosY), {}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", refreshSkill, btnScale, priority)
    
    local propId = "p1"
    local cost = {at = {p1 = 0}}
    local costItem = FormatItem(cost, nil, true)
    
    --经验道具显示
    local propSp = G_getItemIcon(costItem[1], 100)
    propSp:setScale(propSize / propSp:getContentSize().width)
    propSp:setPosition(self.bgSize.width / 2 + propSize * 0.5 + 10, btnPosY)
    self.bgLayer:addChild(propSp)
    local propOwnLb = GetTTFLabel("", 20)
    propOwnLb:setAnchorPoint(ccp(0, 1))
    propOwnLb:setPosition(propSp:getPositionX() - propSize * 0.5, propSp:getPositionY() - propSize * 0.5 - 10)
    self.bgLayer:addChild(propOwnLb)
    self.propOwnLb = propOwnLb
    
    refresh(true)
    
    local function touchLuaSpr()
        
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), touchLuaSpr)
    touchDialogBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    local rect = CCSizeMake(640, G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255 * 0.7)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg, 1)
    self.dialogLayer:setPosition(ccp(0, 0))
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

--id：部队id
function AITroopsSkillSmallDialog:showSkillWashInfoDialog(id, titleStr, showType, layerNum)
    local sd = AITroopsSkillSmallDialog:new()
    sd:initSkillWashInfoDialog(id, titleStr, showType, layerNum)
end

function AITroopsSkillSmallDialog:initSkillWashInfoDialog(id, titleStr, showType, layerNum)
    self.layerNum = layerNum
    self.isUseAmi = true
    
    self.dialogLayer = CCLayer:create()
    
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(2, 2, 2, 2), function()end)
    touchDialogBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchDialogBg:setOpacity(255 * 0.7)
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(touchDialogBg)
    
    local function closeDialog()
        if G_checkClickEnable() == false then
            do
                return
            end
        else
            base.setWaitTime = G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    self.bgSize = CCSizeMake(550, 600)
    local dialogBg, titleBg, titleLb, closeBtnItem, closeBtn = G_getNewDialogBg(self.bgSize, titleStr, 32, nil, self.layerNum, true, closeDialog, nil)
    self.bgLayer = dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5, 0.5))
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    self.dialogLayer:addChild(self.bgLayer, 2)
    
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    tvBg:setContentSize(CCSizeMake(self.bgSize.width - 40, self.bgSize.height - 160))
    tvBg:setAnchorPoint(ccp(0.5, 1))
    tvBg:setPosition(self.bgSize.width / 2, self.bgSize.height - 85)
    self.bgLayer:addChild(tvBg)
    
    local tipLb = GetTTFLabelWrap(getlocal("aitroops_skillWashInfo_tip"), 20, CCSizeMake(tvBg:getContentSize().width - 10, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    tipLb:setAnchorPoint(ccp(0.5, 1))
    tipLb:setColor(G_ColorRed)
    tipLb:setPosition(self.bgSize.width / 2, tvBg:getPositionY() - tvBg:getContentSize().height - 10)
    self.bgLayer:addChild(tipLb)
    
    local descTb = AITroopsVoApi:getSkillWashInfoDesc(id, showType)
    local tvSize = CCSizeMake(tvBg:getContentSize().width, tvBg:getContentSize().height - 6)
    local cellW, cellNum = tvSize.width, 0
    local cellHeightTb = {}
    for k, v in pairs(descTb) do
        local descLb, descHeight = G_getRichTextLabel(v[1], v[2], 22, cellW - 50, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        table.insert(cellHeightTb, descHeight + 20)
        cellNum = cellNum + 1
    end
    
    local function tvCallBack(handler, fn, index, cel)
        if fn == "numberOfCellsInTableView" then
            return cellNum
        elseif fn == "tableCellSizeForIndex" then
            return CCSizeMake(cellW, cellHeightTb[index + 1])
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            local cellH = cellHeightTb[index + 1]
            
            if (index + 1) % 2 == 0 then
                local cellBg = LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png", CCRect(4, 4, 1, 1), function()end)
                cellBg:setContentSize(CCSizeMake(cellW, cellH))
                cellBg:setPosition(cellW / 2, cellH / 2)
                cell:addChild(cellBg)
            end
            local orderNumLb = GetTTFLabel(tostring(index + 1), 22)
            orderNumLb:setPosition(25, cellH / 2)
            cell:addChild(orderNumLb)
            local descLb, descHeight = G_getRichTextLabel(descTb[index + 1][1], descTb[index + 1][2], 22, cellW - 50, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
            descLb:setAnchorPoint(ccp(0, 1))
            descLb:setPosition(50, cellH - (cellH - descHeight) / 2)
            cell:addChild(descLb)
            
            return cell
        elseif fn == "ccTouchBegan" then
            return true
        elseif fn == "ccTouchMoved" then
        elseif fn == "ccTouchEnded" then
        end
    end
    local hd = LuaEventHandler:createHandler(tvCallBack)
    local tv = LuaCCTableView:createWithEventHandler(hd, tvSize, nil)
    tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 4)
    tv:setMaxDisToBottomOrTop(0)
    tv:setPosition(0, 3)
    tvBg:addChild(tv)
    
    self:show()
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

function AITroopsSkillSmallDialog:dispose()
    self.fragmentUpgradeItem, self.fragmentUpgradeMenu = nil, nil
    self.propUpgradeItem, self.propUpgradeMenu = nil, nil
    self.refreshItem, self.refreshMenu = nil, nil
    self.exchangeItem, self.exchangeMenu = nil, nil
    self.layerNum = nil
    self.propOwnLb = nil
    self.fragmentOwnLb = nil
    self.nextSid, self.lastSid = nil, nil
    self.lastLv = nil
    self.expProgressSp, self.expProgressLb = nil, nil
    self.skill = nil
    self.troopsVo = nil
    self.rsIconSp, self.rsNameLb, self.rsLevelLb, self.rsDescTv = nil, nil, nil, nil
    self.norsTipLb = nil
    self.lastSkillExp, self.lastNextExp = nil, nil, nil
    if self.actionLayer then
        self.actionLayer:removeFromParentAndCleanup(true)
        self.actionLayer = nil
    end
    self.actionFlag = nil
    if self.progressScheduler then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.progressScheduler)
        self.progressScheduler = nil
    end
end
