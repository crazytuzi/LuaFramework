acJtxlhSmallDialog = smallDialog:new()

function acJtxlhSmallDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function acJtxlhSmallDialog:showRewardDialog(title, size, reward, layerNum, confirmCallback)
    local sd = acJtxlhSmallDialog:new()
    sd:initRewardDialog(title, size, reward, layerNum, confirmCallback)
end

-- isXiushi:是否有顶部的修饰
function acJtxlhSmallDialog:initRewardDialog(title, size, reward, layerNum, confirmCallback)
    self.layerNum = layerNum
    self.reward = reward or {}
    
    self.cellHeight = 120
    self.dialogWidth = 550
    self.dialogHeight = 160
    self.isTouch = false
    self.isUseAmi = true
    
    self.cellNum = SizeOfTable(self.reward)
    local tvContentHeight = self.cellNum * self.cellHeight
    local maxTvHeight = 580
    self.tvWidth, self.tvHeight = self.dialogWidth - 30, maxTvHeight
    if tvContentHeight < self.tvHeight then
        self.tvHeight = tvContentHeight
    end
    self.dialogHeight = self.dialogHeight + self.tvHeight + 20
    
    self.bgSize = size or CCSizeMake(self.dialogWidth, self.dialogHeight)
    local function nilFunc()
    end
    local dialogBg = G_getNewDialogBg2(self.bgSize, self.layerNum, nil, title[1] or "", title[2] or 25, title[3] or G_ColorWhite, title[4])
    dialogBg:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    
    self.dialogLayer = CCLayer:create()
    self.bgLayer = dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.dialogLayer:addChild(self.bgLayer, 1)
    self.dialogLayer:setTouchPriority(-(self.layerNum - 1) * 20 - 1)
    self.dialogLayer:setBSwallowsTouches(true)
    
    local descBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), nilFunc)
    descBg:setContentSize(CCSizeMake(self.bgSize.width - 30, self.tvHeight + 20))
    descBg:setAnchorPoint(ccp(0.5, 0))
    descBg:setPosition(self.bgSize.width / 2, self.bgSize.height - 40 - descBg:getContentSize().height)
    self.bgLayer:addChild(descBg)
    
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.tvWidth, self.tvHeight), nil)
    self.tv:setPosition((self.bgSize.width - self.tvWidth) / 2, descBg:getPositionY() + 10)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 5)
    self.bgLayer:addChild(self.tv, 1)
    if tvContentHeight > self.tvHeight then
        self.tv:setMaxDisToBottomOrTop(100)
    else
        self.tv:setMaxDisToBottomOrTop(0)
    end
    
    --确定
    local function sureHandler()
        if(confirmCallback)then
            confirmCallback()
        end
        self:close()
    end
    G_createBotton(self.bgLayer, ccp(self.bgSize.width / 2, 60), {getlocal("confirm")}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", sureHandler, 0.8, -(self.layerNum - 1) * 20 - 5)
    
    local function touchLuaSpr()
        if self and self.tv and self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
            if self.isTouch and self.isTouch == true then
                self:close()
            end
        end
    end
    
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), touchLuaSpr)
    touchDialogBg:setTouchPriority(-(self.layerNum - 1) * 20)
    local rect = CCSizeMake(640, G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(ccp(0, 0))
    self.dialogLayer:addChild(touchDialogBg)
    
    self:show()
    
    sceneGame:addChild(self.dialogLayer, self.layerNum)
    self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    self:addForbidSp(self.bgLayer, self.bgSize, self.layerNum, nil, true, true)
    
    return self.dialogLayer
end

function acJtxlhSmallDialog:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return self.cellNum
    elseif fn == "tableCellSizeForIndex" then
        local tmpSize
        tmpSize = CCSizeMake(self.tvWidth, self.cellHeight)
        return tmpSize
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local iconWidth = 90
        local leftPosX = iconWidth + 50
        local item = self.reward[idx + 1]
        local function showNewPropInfo()
            G_showNewPropInfo(self.layerNum + 1, true, true, nil, item, true)
            return false
        end
        local icon = G_getItemIcon(item, 100, false, self.layerNum + 1, showNewPropInfo, self.tv)
        icon:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
        icon:setScale(iconWidth / icon:getContentSize().width)
        cell:addChild(icon)
        icon:setAnchorPoint(ccp(0, 0.5))
        icon:setPosition(30, self.cellHeight / 2)
        
        if (idx + 1) ~= self.cellNum then
            local function nilFunc()
            end
            local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png", CCRect(4, 0, 2, 2), nilFunc)
            lineSp:setContentSize(CCSizeMake(self.tvWidth - 20, 2))
            lineSp:setPosition(self.tvWidth / 2, 0)
            cell:addChild(lineSp)
        end
        
        local nameStr = item.name
        local nameLb = GetTTFLabelWrap(nameStr, 24, CCSizeMake(250, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
        nameLb:setAnchorPoint(ccp(0, 0.5))
        nameLb:setColor(G_ColorYellowPro)
        nameLb:setPosition(ccp(leftPosX, self.cellHeight / 4 * 3))
        cell:addChild(nameLb, 1)
        
        local numStr = item.num
        local numLb = GetTTFLabelWrap(getlocal("propInfoNum", {numStr}), 22, CCSizeMake(250, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
        numLb:setAnchorPoint(ccp(0, 0.5))
        numLb:setPosition(ccp(leftPosX, self.cellHeight / 4))
        cell:addChild(numLb, 1)
        
        if item.type == "al" then
            local attrFontWidth = 270
            local flagAttr
            local eType = string.sub(item.key, 1, 2)
            if eType == "if" then
                flagAttr = allianceVoApi:getShowFlagAttr(2, item.key, true)
            else
                eType = string.sub(item.key, 1, 1)
                if eType == "i" then --军团旗帜图标
                    flagAttr = allianceVoApi:getShowFlagAttr(1, item.key, true)
                end
            end
            if flagAttr then
                local tempNameLb = GetTTFLabel(nameStr, 24)
                local realWidth = tempNameLb:getContentSize().width
                if realWidth > nameLb:getContentSize().width then
                    realWidth = nameLb:getContentSize().width
                end
                local attrLb, ttrLbHeight = G_getRichTextLabel(flagAttr, {nil, G_ColorGreen, nil}, 24, attrFontWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                attrLb:setAnchorPoint(ccp(0, 1))
                attrLb:setPosition(nameLb:getPositionX() + realWidth + 10, nameLb:getPositionY() + ttrLbHeight / 2)
                cell:addChild(attrLb)
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

function acJtxlhSmallDialog:dispose()
    
end
