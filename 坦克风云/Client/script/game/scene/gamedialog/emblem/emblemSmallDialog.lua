emblemSmallDialog = smallDialog:new()

function emblemSmallDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function emblemSmallDialog:showAdvanceSelectDialog(emblemPool, layerNum, callback)
    local sm = emblemSmallDialog:new()
    sm:initAdvanceSelectDialog(emblemPool, layerNum, callback)
end

function emblemSmallDialog:initAdvanceSelectDialog(emblemPool, layerNum, callback)
    self.layerNum = layerNum
    self.callback = callback

    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local dialogBg = G_getNewDialogBg(CCSizeMake(600, 750), getlocal("emblem_select"), 30, function () end, layerNum, true, close)
    self.dialogLayer = CCLayer:create()
    
    self.bgLayer = dialogBg
    self.bgLayer:setIsSallow(false)
    self:show()
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 2);
    self.dialogLayer:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
    self.dialogLayer:setBSwallowsTouches(true);
    
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/emblem/emblemImage.plist")
    spriteController:addTexture("public/emblem/emblemImage.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
    local mLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png", CCRect(34, 1, 1, 1), function ()end)
    mLine:setPosition(ccp(5, 120))
    mLine:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width - 10, mLine:getContentSize().height))
    mLine:setAnchorPoint(ccp(0, 0.5))
    dialogBg:addChild(mLine)
    
    self.selectId = nil
    self.selectedSp = nil
    
    local bgWidth = 150
    local firstPosX = G_getCenterSx(560, bgWidth, 3, 20)
    local tvWidth, tvHeight, cellHeight = self.bgLayer:getContentSize().width - 40, self.bgLayer:getContentSize().height - 185, 190
    local cellNum = math.ceil(SizeOfTable(emblemPool) / 3)
    self.tv = G_createTableView(CCSizeMake(tvWidth, tvHeight), cellNum, CCSizeMake(tvWidth, cellHeight), function (cell, cellSize, idx, cellNum) --初始化cell
        local sIdx = idx * 3
        for k = 1, 3 do
            local eid = emblemPool[sIdx + k]
            if eid == nil then
                do break end
            end
            local emblemIcon
            local function onSelected()
                if self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
                    if(self.selectedSp)then
                        self.selectedSp:removeFromParentAndCleanup(true)
                        self.selectedSp = nil
                    end
                    if self.selectId ~= eid then
                        self.selectId = eid
                        self.selectedSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(3, 3, 4, 4), function (...)end)
                        self.selectedSp:setTag(999)
                        self.selectedSp:setContentSize(CCSizeMake(190, 238))
                        self.selectedSp:setOpacity(120)
                        self.selectedSp:setPosition(95, 119)
                        local icon = CCSprite:createWithSpriteFrameName("7daysCheckmark.png")
                        icon:setPosition(getCenterPoint(self.selectedSp))
                        self.selectedSp:addChild(icon)
                        emblemIcon:addChild(self.selectedSp)
                    else
                        self.selectId = nil
                    end
                end
            end
            emblemIcon = emblemVoApi:getEquipIcon(eid, onSelected, sIdx + k, nil, emblemListCfg.equipListCfg[eid].qiangdu)
            emblemIcon:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
            emblemIcon:setScale(bgWidth / emblemIcon:getContentSize().width)
            emblemIcon:setAnchorPoint(ccp(0.5, 0))
            emblemIcon:setPosition(firstPosX + (k - 1) * (bgWidth + 20), 0)
            local function showInfo()
                local selectedSp = emblemIcon:getChildByTag(999)
                if(selectedSp)then
                    do return end
                end
                local cfg = emblemVoApi:getEquipCfgById(eid)
                local vo = emblemVo:new(cfg)
                vo:initWithData(eid,0)
                emblemVoApi:showInfoDialog(vo, self.layerNum + 1)
            end
            local infoBtn = LuaCCSprite:createWithSpriteFrameName("i_sq_Icon1.png", showInfo)--BtnInfor
            infoBtn:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
            infoBtn:setScale(1)
            infoBtn:setPosition(ccp(emblemIcon:getContentSize().width - 30, emblemIcon:getContentSize().height - 30))
            emblemIcon:addChild(infoBtn)
            cell:addChild(emblemIcon)
        end
    end)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition(ccp(25, 115))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(80)
    
    local function onConfirm()
        if(self.selectId == nil)then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("emblem_set_troops_prompt"), 30)
            do return end
        end
        if(self.callback)then
            self.callback(self.selectId)
        end
        self:close()
    end
    local confirmItem = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", onConfirm, nil, getlocal("confirm"), 25)
    confirmItem:setScale(0.8)
    local confirmBtn = CCMenu:createWithItem(confirmItem)
    confirmBtn:setTouchPriority(((-(self.layerNum - 1) * 20 - 5)))
    confirmBtn:setPosition(self.bgLayer:getContentSize().width - 150, 60)
    self.bgLayer:addChild(confirmBtn)
    local cancelItem = GetButtonItem("newGrayBtn.png", "newGrayBtn_Down.png", "newGrayBtn.png", close, nil, getlocal("cancel"), 25)
    cancelItem:setScale(0.8)
    local cancelBtn = CCMenu:createWithItem(cancelItem)
    cancelBtn:setTouchPriority(((-(self.layerNum - 1) * 20 - 5)))
    cancelBtn:setPosition(150, 60)
    self.bgLayer:addChild(cancelBtn)
    
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function () end)
    touchDialogBg:setTouchPriority(-(layerNum - 1) * 20 - 1)
    local rect = CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg)
    
    sceneGame:addChild(self.dialogLayer, layerNum)
    self.dialogLayer:setPosition(ccp(0, 0))
    return self.dialogLayer
end
