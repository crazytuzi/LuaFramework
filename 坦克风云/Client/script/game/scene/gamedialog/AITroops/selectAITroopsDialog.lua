selectAITroopsDialog = smallDialog:new()

function selectAITroopsDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

--battleType:各个战斗的类型，战斗的唯一标识 layerNum:层数 callBack:确定按钮回调
--cid:领土争夺战要用
function selectAITroopsDialog:showSelectAITroopsDialog(battleType, layerNum, callBack, cid)
    local sd = selectAITroopsDialog:new()
    sd:initSelectAITroopsDialog(battleType, layerNum, callBack, cid)
end

function selectAITroopsDialog:initSelectAITroopsDialog(battleType, layerNum, callBack, cid)
    local function addRes()
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        spriteController:addPlist("public/emblem/emblemImage.plist")
        spriteController:addTexture("public/emblem/emblemImage.png")
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        spriteController:addPlist("public/aiTroopsImage/aitroops_images2.plist")
        spriteController:addTexture("public/aiTroopsImage/aitroops_images2.png")
    end
    G_addResource8888(addRes)
    self.isTouch, self.isUseAmi, self.layerNum = true, true, layerNum
    self.dialogWidth, self.dialogHeight = 500, 700
    self.selectedId = nil
    self.troopsList = AITroopsFleetVoApi:getCanUseAITroopsList(battleType, cid)
    local troopsNum = SizeOfTable(self.troopsList)
    self.cellNum = math.ceil(troopsNum / 2)
    local function close()
        spriteController:removePlist("public/aiTroopsImage/aitroops_images2.plist")
        spriteController:removeTexture("public/aiTroopsImage/aitroops_images2.png")
        return self:close()
    end
    
    self.bgSize = CCSizeMake(self.dialogWidth, self.dialogHeight)
    local dialogBg = G_getNewDialogBg(self.bgSize, getlocal("select_aitroops_title"), 30, nil, layerNum, true, close)
    self.dialogLayer = CCLayer:create()
    self.bgLayer = dialogBg
    self.bgLayer:setIsSallow(false)
    self:show()
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 2);
    self.dialogLayer:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
    self.dialogLayer:setBSwallowsTouches(true);
    
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function () end)
    touchDialogBg:setTouchPriority(-(layerNum - 1) * 20 - 1)
    local rect = CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg)
    
    local forbidLayerUp = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", CCRect(20, 20, 10, 10), function () end)
    forbidLayerUp:setTouchPriority(((-(self.layerNum - 1) * 20 - 4)))
    forbidLayerUp:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight / 2 - self.dialogHeight / 2 + 70))
    forbidLayerUp:setAnchorPoint(ccp(0, 1))
    forbidLayerUp:setPosition(0, G_VisibleSizeHeight)
    self.dialogLayer:addChild(forbidLayerUp, 5)
    forbidLayerUp:setVisible(false)
    local forbidLayerDown = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png", CCRect(20, 20, 10, 10), function () end)
    forbidLayerDown:setTouchPriority(((-(self.layerNum - 1) * 20 - 4)))
    forbidLayerDown:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight / 2 - self.dialogHeight / 2 + 110))
    forbidLayerDown:setAnchorPoint(ccp(0, 0))
    forbidLayerDown:setPosition(0, 0)
    self.dialogLayer:addChild(forbidLayerDown, 5)
    forbidLayerDown:setVisible(false)
    
    local mLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png", CCRect(34, 1, 1, 1), function ()end)
    mLine:setPosition(ccp(5, 120))
    mLine:setContentSize(CCSizeMake(self.dialogWidth - 10, mLine:getContentSize().height))
    mLine:setAnchorPoint(ccp(0, 0.5))
    dialogBg:addChild(mLine)
    
    self.tvWidth, self.tvHeight = self.dialogWidth - 50, self.dialogHeight - 185
    self.cellHeight = 300
    self.haveSelectAITroopsTb = AITroopsFleetVoApi:getAITroopsTb()

    local function callback(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callback)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.tvWidth, self.tvHeight), nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition(ccp((self.bgSize.width - self.tvWidth) / 2, 115))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(80)
    
    if(troopsNum == 0)then
        local noTroopsLb = GetTTFLabelWrap(getlocal("aitroops_select_null"), 25, CCSizeMake(self.dialogWidth - 60, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        noTroopsLb:setPosition(self.dialogWidth / 2, self.tv:getPositionY() + self.tvHeight / 2)
        self.bgLayer:addChild(noTroopsLb)
    end
    
    local btnScale, priority = 0.8, -(self.layerNum - 1) * 20 - 5
    local function onConfirm()
        if(self.selectedId == nil)then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("aitroops_select_null2"), 30)
            do return end
        end
        if(callBack)then
            callBack(self.selectedId)
        end
        close()
    end
    G_createBotton(self.bgLayer, ccp(self.dialogWidth - 150, 60), {getlocal("confirm"), 25}, "newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onConfirm, btnScale, priority)
    G_createBotton(self.bgLayer, ccp(150, 60), {getlocal("cancel"), 25}, "newGrayBtn.png", "newGrayBtn_Down.png", "newGrayBtn.png", close, btnScale, priority)
    
    sceneGame:addChild(self.dialogLayer, layerNum)
    self.dialogLayer:setPosition(ccp(0, 0))
    return self.dialogLayer
end

function selectAITroopsDialog:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return self.cellNum
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(self.tvWidth, self.cellHeight)
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        local startIndex = idx * 2
        local bgWidth = self.tvWidth / 2
        for k = 1, 2 do
            local troopsVo = self.troopsList[startIndex + k]         
            if(troopsVo)then
                local atid = troopsVo.id
                local limitTb = AITroopsVoApi:getLimitTroopsCfg( atid )
                local troopsIcon
                local conflictTb = AITroopsVoApi:troopsConflict( limitTb, self.haveSelectAITroopsTb)
                local sizeOfConflictTable = SizeOfTable(conflictTb)

                local function onSelected()
                    if sizeOfConflictTable==0 then
                        if self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
                            if(self.selectedSp)then
                                self.selectedSp:removeFromParentAndCleanup(true)
                                self.selectedSp = nil
                            end
                            if self.selectedId ~= atid then
                                self.selectedId = atid
                                self.selectedSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(3, 3, 4, 4), function (...)end)
                                self.selectedSp:setTag(999)
                                self.selectedSp:setContentSize(troopsIcon:getContentSize())
                                self.selectedSp:setOpacity(120)
                                self.selectedSp:setPosition(getCenterPoint(troopsIcon))
                                local icon = CCSprite:createWithSpriteFrameName("7daysCheckmark.png")
                                icon:setPosition(getCenterPoint(self.selectedSp))
                                self.selectedSp:addChild(icon)
                                troopsIcon:addChild(self.selectedSp, 10)
                            else
                                self.selectedId = nil
                            end
                        end
                    end
                end
                troopsIcon = AITroopsVoApi:getAITroopsIcon(atid, nil, onSelected)
                troopsIcon:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                troopsIcon:setPosition(ccp(bgWidth / 2 + (k - 1) * bgWidth, self.cellHeight - troopsIcon:getContentSize().height / 2))
                cell:addChild(troopsIcon)
   
                if sizeOfConflictTable~=0 then
                    local cannotUseTroopsIcon = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(3, 3, 4, 4), function (...)end)
                    cannotUseTroopsIcon:setContentSize(troopsIcon:getContentSize())
                    cannotUseTroopsIcon:setOpacity(120)
                    cannotUseTroopsIcon:setPosition(getCenterPoint(troopsIcon))
                    troopsIcon:addChild(cannotUseTroopsIcon,500)

                    local lbBg=CCSprite:createWithSpriteFrameName("emblemUnlockBg.png")
                    lbBg:setPosition(getCenterPoint(troopsIcon))
                    troopsIcon:addChild(lbBg,500)

                    local fontSize
                    if G_isAsia() then
                        fontSize= 20
                    else
                        fontSize=16
                        lbBg:setScaleY(2)
                    end
                    local str = AITroopsVoApi:getLimitDes(nil,conflictTb)
                    local limitDes = GetTTFLabelWrap(str,fontSize,CCSizeMake(troopsIcon:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
                    limitDes:setPosition(getCenterPoint(troopsIcon))
                    troopsIcon:addChild(limitDes,999)

                end
                
                local function showInfo()
                    if self.selectedId == atid then
                        do return end
                    end
                    AITroopsVoApi:showTroopsInfoDialog(troopsVo, false, self.layerNum + 1)
                end
                local pos = ccp(troopsIcon:getContentSize().width - 57 * 0.5, troopsIcon:getContentSize().height - 57 * 0.5 - 60)
                G_addMenuInfo(troopsIcon, self.layerNum, pos, nil, nil, 0.7, nil, showInfo, true, 3)
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


function selectAITroopsDialog:dispose()
    self.dialogWidth, self.dialogHeight = nil, nil
    self.troopsList = nil, nil
    self.cellNum = nil
    self.tvWidth, self.tvHeight = nil, nil
    self.selectedSp = nil
    self.selectedId = nil
end

