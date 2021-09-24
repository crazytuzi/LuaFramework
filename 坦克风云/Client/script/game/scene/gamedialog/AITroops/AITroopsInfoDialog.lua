AITroopsInfoDialog = smallDialog:new()

function AITroopsInfoDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

--isCheck：是否是查看生产池里面AI部队的信息
function AITroopsInfoDialog:showTroopsInfoDialog(troopsVo, isCheck, layerNum)
    local sd = AITroopsInfoDialog:new()
    sd:initTroopsInfoDialog(troopsVo, isCheck, layerNum)
end

function AITroopsInfoDialog:initTroopsInfoDialog(troopsVo, isCheck, layerNum)
    G_addResource8888(function()
        spriteController:addPlist("public/aiTroopsImage/aitroops_images2.plist")
        spriteController:addTexture("public/aiTroopsImage/aitroops_images2.png")
    end)
    self.layerNum = layerNum
    self.troopsVo = troopsVo
    self.isCheck = isCheck
    local dialogBgWidth, dialogBgHeight = 550, 66
    self.tvWidth, self.tvHeight = dialogBgWidth - 40, 550
    
    self.skillNum = #self.troopsVo:getTroopsSkillList()
    self.skillIconSize, self.skillNameFontSize, self.skillDescFontSize, self.descFontWidth = 80, 22, 20, self.tvWidth - 120
    self.cellHeightTb = {}
    
    local itemBgSize = CCSizeMake(dialogBgWidth - 40, 120)
    local totalCellHeight = 0
    for k = 1, self.skillNum do
        totalCellHeight = totalCellHeight + self:getCellHeight(k)
    end
    dialogBgHeight = dialogBgHeight + itemBgSize.height + 30 + 30
    
    if totalCellHeight < self.tvHeight then
        self.tvHeight = totalCellHeight
    end
    dialogBgHeight = dialogBgHeight + self.tvHeight
    
    self.bgSize = CCSizeMake(dialogBgWidth, dialogBgHeight)
    
    local function close()
        self:close()
    end
    
    local dialogBg = G_getNewDialogBg(self.bgSize, getlocal("fleet_slot_title"), 28, nil, self.layerNum, true, close)
    self.bgLayer = dialogBg
    
    self.dialogLayer = CCLayer:create()
    self:show()
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 2)
    self.dialogLayer:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    self.dialogLayer:setBSwallowsTouches(true)
    
    self.aiTroopCfg = AITroopsVoApi:getModelCfg()
    local itemBg = LuaCCScale9Sprite:createWithSpriteFrameName("newItemKuang.png", CCRect(15, 15, 2, 2), function () end)
    itemBg:setAnchorPoint(ccp(0.5, 1))
    itemBg:setContentSize(itemBgSize)
    itemBg:setPosition(self.bgSize.width / 2, self.bgSize.height - 70)
    self.bgLayer:addChild(itemBg)
    
    --部队图标
    local iconSize = 100
    local troopsIcon = AITroopsVoApi:getAITroopsSimpleIcon(self.troopsVo.id, nil, self.troopsVo.grade)
    troopsIcon:setScale(iconSize / troopsIcon:getContentSize().width)
    troopsIcon:setPosition(10 + iconSize * 0.5, itemBgSize.height * 0.5)
    itemBg:addChild(troopsIcon)
    --部队名称
    local nameFontSize, smallFontSize = 22, 20
    local nameStr, color = AITroopsVoApi:getAITroopsNameStr(self.troopsVo.id)
    local nameLb = GetTTFLabel(nameStr, nameFontSize, true)
    nameLb:setAnchorPoint(ccp(0, 1))
    nameLb:setColor(color)
    nameLb:setPosition(troopsIcon:getPositionX() + iconSize * 0.5 + 10, troopsIcon:getPositionY() + iconSize * 0.5)
    itemBg:addChild(nameLb)
    --部队等级
    local levelLb = GetTTFLabel(getlocal("fightLevel", {self.troopsVo.lv}), nameFontSize)
    levelLb:setAnchorPoint(ccp(0, 1))
    levelLb:setPosition(nameLb:getPositionX() + nameLb:getContentSize().width + 15, nameLb:getPositionY())
    itemBg:addChild(levelLb)
    --部队强度
    local strength = self.troopsVo:getTroopsStrength()
    local strengthLb = GetTTFLabel(getlocal("emblem_infoStrong", {strength}), smallFontSize)
    strengthLb:setAnchorPoint(ccp(0, 1))
    strengthLb:setPosition(nameLb:getPositionX(), nameLb:getPositionY() - nameLb:getContentSize().height - 10)
    itemBg:addChild(strengthLb)
    
    --部队当前等级经验进度
    local progressWidth, progressHeight = 250, 30
    local pos = ccp(nameLb:getPositionX(), strengthLb:getPositionY() - strengthLb:getContentSize().height - progressHeight * 0.5 - 10)
    local expProgressSp = AddProgramTimer(itemBg, pos, 9, 12, "", "TeamTravelBarBg.png", "TeamTravelBar.png", 11, nil, nil, nil, nil, nameFontSize)
    local expProgressBg = tolua.cast(itemBg:getChildByTag(11), "CCSprite")
    local lbPer = tolua.cast(expProgressSp:getChildByTag(12), "CCLabelTTF")
    local scaleX = progressWidth / expProgressSp:getContentSize().width
    local scaleY = progressHeight / expProgressSp:getContentSize().height
    expProgressSp:setAnchorPoint(ccp(0, 0.5))
    expProgressBg:setAnchorPoint(ccp(0, 0.5))
    expProgressSp:setScaleX(scaleX)
    expProgressSp:setScaleY(scaleY)
    expProgressBg:setScaleX(scaleX)
    expProgressBg:setScaleY(scaleY)
    lbPer:setScaleX(1 / scaleX)
    lbPer:setScaleY(1 / scaleY)
    
    local maxLv = AITroopsVoApi:getTroopsMaxLvById(self.troopsVo.id)
    if self.troopsVo.lv >= maxLv then
        expProgressSp:setPercentage(100)
        lbPer:setString(getlocal("alliance_lvmax"))
    else
        local nextExp = AITroopsVoApi:getTroopsUpgradeExpById(self.troopsVo.id, self.troopsVo.lv)
        local per = math.floor(self.troopsVo.exp / nextExp * 100)
        expProgressSp:setPercentage(per)
        lbPer:setString(self.troopsVo.exp.."/"..nextExp)
    end
    
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function () end)
    tvBg:setContentSize(CCSizeMake(self.tvWidth, self.tvHeight + 4))
    tvBg:setAnchorPoint(ccp(0.5, 1))
    tvBg:setPosition(self.bgSize.width / 2, itemBg:getPositionY() - itemBgSize.height - 10)
    self.bgLayer:addChild(tvBg)

    if AITroopsVoApi:getLimitTroops(self.troopsVo.id) then
        local str = AITroopsVoApi:getLimitDes(self.troopsVo.id)
        local limitDes = GetTTFLabelWrap(str,20,CCSizeMake(self.tvWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
        limitDes:setAnchorPoint(ccp(0,1))
        limitDes:setPosition(10, self.tvHeight-10)
        tvBg:addChild(limitDes)
        self.tvHeight=self.tvHeight-limitDes:getContentSize().height-50

        local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
        lineSp:setContentSize(CCSizeMake((self.tvWidth - 9), 4))
        lineSp:ignoreAnchorPointForPosition(false)
        lineSp:setAnchorPoint(ccp(0.5, 0))
        lineSp:setPosition(self.tvWidth / 2,self.tvHeight+10)
        tvBg:addChild(lineSp)
    end
    
    local function callBack(...)
        return self:eventHandler(...)
    end
    
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.tvWidth, self.tvHeight), nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition((self.bgSize.width - self.tvWidth) / 2, tvBg:getPositionY() - tvBg:getContentSize().height + 2)
    self.tv:setMaxDisToBottomOrTop(80)
    self.bgLayer:addChild(self.tv)
    
    local function touchLuaSpr()
        
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), touchLuaSpr)
    touchDialogBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    local rect = CCSizeMake(640, G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(250)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg, 1)
    self.dialogLayer:setPosition(ccp(0, 0))
    
    sceneGame:addChild(self.dialogLayer, self.layerNum)
end

function AITroopsInfoDialog:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return self.skillNum
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(self.tvWidth, self:getCellHeight(idx + 1))
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local cellWidth, cellHeight = self.tvWidth, self:getCellHeight(idx + 1)
        local skillPos = idx + 1
        local skill = self.troopsVo:getSkillByPos(skillPos)
        if skill then
            local nameBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png", CCRect(105, 16, 1, 1), function()end)
            nameBg:setAnchorPoint(ccp(0, 1))
            nameBg:setContentSize(CCSizeMake(cellWidth - 10, nameBg:getContentSize().height))
            nameBg:setPosition(10, cellHeight - 8)
            cell:addChild(nameBg)
            
            local nameStr, desc, colorTb = AITroopsVoApi:getSkillNameAndDesc(skill.sid, skill.lv)
            --技能名称
            local nameLb = GetTTFLabel(nameStr, self.skillNameFontSize, true)
            nameLb:setAnchorPoint(ccp(0, 0.5))
            nameLb:setColor(G_ColorYellowPro)
            nameLb:setPosition(15, nameBg:getContentSize().height / 2)
            nameBg:addChild(nameLb)
            --当前等级
            local levelLb = GetTTFLabel(getlocal("fightLevel", {skill.lv}), self.skillNameFontSize, true)
            levelLb:setAnchorPoint(ccp(0, 0.5))
            levelLb:setPosition(nameLb:getPositionX() + nameLb:getContentSize().width + 15, nameLb:getPositionY())
            nameBg:addChild(levelLb)
            --技能icon
            local skillIconSp = AITroopsVoApi:getSkillIcon(skill.sid)
            skillIconSp:setScale(self.skillIconSize / skillIconSp:getContentSize().width)
            skillIconSp:setPosition(15 + self.skillIconSize * 0.5, (cellHeight - 40) * 0.5)
            cell:addChild(skillIconSp)
            
            local descPosX = 110
            
            if idx == 2 and self.isCheck == true then
                local tipLb = GetTTFLabelWrap(getlocal("aitroops_active_skill_acquire"), self.skillDescFontSize, CCSizeMake(self.descFontWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
                tipLb:setAnchorPoint(ccp(0, 0.5))
                tipLb:setColor(G_ColorRed)
                tipLb:setPosition(descPosX, (cellHeight - 40) / 2)
                cell:addChild(tipLb)
                
                local function skillWashInfo()
                    AITroopsVoApi:showSkillWashInfoDialog(self.troopsVo.id, 2, self.layerNum + 1)
                end
                G_addMenuInfo(cell, self.layerNum, ccp(cellWidth - 50, (cellHeight - 40) / 2), nil, nil, 1, nil, skillWashInfo, true, 4)
            else
                local unlockFlag = true
                if self.troopsVo.grade < skillPos then--该技能未解锁
                    unlockFlag = false
                end
                
                if unlockFlag == false then --该技能未解锁
                    local unlockLb, lbHeight = G_getRichTextLabel(getlocal("aitroops_skill_unlocklimit", {skillPos}), {nil, G_ColorRed, nil}, self.skillDescFontSize, self.descFontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
                    unlockLb:setAnchorPoint(ccp(0, 0.5))
                    unlockLb:setPosition(descPosX, (cellHeight - 40) / 2)
                    cell:addChild(unlockLb)
                else
                    --技能描述
                    local descLb, descHeight = G_getRichTextLabel(desc, colorTb, self.skillDescFontSize, self.descFontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                    descLb:setAnchorPoint(ccp(0, 1))
                    descLb:setPosition(descPosX, cellHeight - 50)
                    cell:addChild(descLb)
                end
            end
            
            if skillPos ~= self.skillNum then
                local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png", CCRect(2, 0, 1, 2), function()end)
                lineSp:setAnchorPoint(ccp(0.5, 0))
                lineSp:setContentSize(CCSizeMake(cellWidth - 18, lineSp:getContentSize().height))
                lineSp:setRotation(180)
                lineSp:setPosition(cellWidth / 2, lineSp:getContentSize().height / 2)
                cell:addChild(lineSp)
            end
        end
        
        return cell
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
        return true
    elseif fn == "ccTouchMoved" then
        self.isMoved = true
    elseif fn == "ccTouchEnded" then
        
    end
end

function AITroopsInfoDialog:getCellHeight(idx)
    if self.cellHeightTb[idx] == nil then
        local height = 40
        
        local showHeight = 0
        if idx == 3 and self.isCheck == true then
            local tipLb = GetTTFLabelWrap(getlocal("aitroops_active_skill_acquire"), self.skillDescFontSize, CCSizeMake(self.descFontWidth, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
            showHeight = tipLb:getContentSize().height
        else
            if self.troopsVo.grade < idx then --该技能未解锁
                local unlockLb, lbHeight = G_getRichTextLabel(getlocal("aitroops_skill_unlocklimit", {idx}), {nil, G_ColorRed, nil}, self.skillDescFontSize, self.descFontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
                showHeight = lbHeight
            else
                local skill = self.troopsVo:getSkillByPos(idx)
                local nameStr, desc, colorTb = AITroopsVoApi:getSkillNameAndDesc(skill.sid, skill.lv)
                local descLb, descHeight = G_getRichTextLabel(desc, colorTb, self.skillDescFontSize, self.descFontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                showHeight = descHeight
            end
        end
        if showHeight < self.skillIconSize then
            showHeight = self.skillIconSize
        end
        height = height + showHeight + 20
        self.cellHeightTb[idx] = height
    end
    return self.cellHeightTb[idx]
end

function AITroopsInfoDialog:dispose()
    self.cellHeightTb = nil
    self.tvWidth, self.tvHeight = nil, nil
    self.skillNum = nil
    self.skillNameFontSize, self.skillDescFontSize = nil, nil
    self.descFontWidth = nil
    spriteController:removePlist("public/aiTroopsImage/aitroops_images2.plist")
    spriteController:removeTexture("public/aiTroopsImage/aitroops_images2.png")
end

