acJjzzSelectDialog = smallDialog:new()

function acJjzzSelectDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    
    nc.heroIconTb = {}
    return nc
end

function acJjzzSelectDialog:init(layerNum, callback, heroTb)
    self.layerNum = layerNum
    self.isTouch = false
    self.isUseAmi = true
    self.callback = callback
    
    self.bgSize = CCSizeMake(580, 600)
    local dialogBg = G_getNewDialogBg2(self.bgSize, layerNum, function ()end, getlocal("activity_jjzz_lb7"), 28, nil, "Helvetica-bold")
    self.dialogLayer = CCLayer:create()
    dialogBg:setTouchPriority(-(layerNum - 1) * 20 - 2)
    self.dialogLayer:setBSwallowsTouches(true);
    self.bgLayer = dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self:show()
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    
    -- 背景遮罩
    local function touchLuaSpr()
        self:close()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum - 1) * 20 - 1)
    local rect = CCSizeMake(640, G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg, 1);
    sceneGame:addChild(self.dialogLayer, layerNum)
    self.dialogLayer:setPosition(ccp(0, 0))
    self.dialogLayer:addChild(self.bgLayer, 2);
    self.dialogLayer:setTouchPriority(-(layerNum - 1) * 20 - 1)
    
    local visibleSizeHeight = self.bgLayer:getContentSize().height - 40
    local visibleSizeWidth = self.bgLayer:getContentSize().width
    
    local vo = acJjzzVoApi:getAcVo()
    local cfg = vo.acCfg
    self.tvW = self.bgSize.width - 10
    self.tvH = 0
    
    for k, v in pairs(cfg.heroList) do
        self.tvH = self.tvH + 150 + (math.ceil(#v / 3) * 180)
    end
    
    local itemBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function () end)
    itemBg:setContentSize(CCSizeMake(self.tvW, self.bgSize.height - 116))
    itemBg:setAnchorPoint(ccp(0.5, 0))
    itemBg:setPosition(self.bgSize.width / 2, 80)
    self.bgLayer:addChild(itemBg)
    
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tv = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(self.tvW, self.bgSize.height - 140), nil)
    self.tv:setAnchorPoint(ccp(0, 0))
    self.tv:setPosition(0, 90)
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setMaxDisToBottomOrTop(80)
    self.bgLayer:addChild(self.tv)
    
    local function sureFun()
        if self.callback then
            self.callback(self.k1, self.k2)
        end
        self:close()
    end
    local btnItem2 = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", sureFun, 2, getlocal("confirm"), 25)
    btnItem2:setScale(0.8)
    btnItem2:setAnchorPoint(ccp(0.5, 0))
    self.sureBtn = btnItem2
    local btn2 = CCMenu:createWithItem(btnItem2);
    btn2:setTouchPriority(-(self.layerNum - 1) * 20 - 22);
    btn2:setPosition(ccp(self.bgSize.width * 0.5, 10))
    self.bgLayer:addChild(btn2)
    
end

function acJjzzSelectDialog:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
        return 1
    elseif fn == "tableCellSizeForIndex" then
        return CCSizeMake(self.tvW, self.tvH)
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local vo = acJjzzVoApi:getAcVo()
        local cfg = vo.acCfg
        
        local minH = 0
        local ixs = 0
        for k, v in pairs(cfg.heroList) do
            local bgH = 150 + (math.ceil(#v / 3) * 180)
            local itemBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function () end)
            itemBg:setContentSize(CCSizeMake(self.tvW - 20, bgH))
            itemBg:setAnchorPoint(ccp(0, 1))
            itemBg:setOpacity(0)
            itemBg:setPosition(10, self.tvH - minH)
            cell:addChild(itemBg)
            minH = minH + bgH
            
            local titleBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png", CCRect(105, 16, 1, 1), function ()end)
            titleBg:setAnchorPoint(ccp(0, 1))
            titleBg:setPosition(0, itemBg:getContentSize().height - 5)
            titleBg:setContentSize(CCSizeMake(self.tvW - 80, titleBg:getContentSize().height))
            itemBg:addChild(titleBg)
            
            local descLb = GetTTFLabelWrap(getlocal("activity_jjzz_lb" .. (7 + k), {v[1].cost1}), G_getLS(25, 20), CCSizeMake(self.tvW - 40, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
            descLb:setAnchorPoint(ccp(0, 0.5))
            descLb:setPosition(10, titleBg:getContentSize().height * 0.5)
            titleBg:addChild(descLb)
            
            
            local itemW1 = 100
            local midW1 = 80
            local len1 = #v
            for i = 1, len1 do
                ixs = ixs + i
                local sx = 50 + ((i - 1) % 3) * (itemW1 + midW1)
                local sy = bgH - 160 - 200 * (math.ceil(i / 3) - 1)

                local function clkFun(hd, fn, idx)
                    if self.tv and self.tv:getScrollEnable() == true and self.tv:getIsScrolled() == false then
                        self.k1 = k
                        self.k2 = i
                        -- 重置所有
                        if self.heroIconTb then
                            for k, v in pairs(self.heroIconTb) do
                                local selectBorderSp = tolua.cast(v:getChildByTag(1103), "CCSprite")
                                if selectBorderSp then
                                    if k == idx then
                                        selectBorderSp:setVisible(true)
                                    else
                                        selectBorderSp:setVisible(false)
                                    end
                                end
                            end
                        end
                        
                    end
                end

                local heroItem = FormatItem(v[i].hname)[1]
                local heroIcon = G_getItemIcon(heroItem, 100, false, self.layerNum + 1, clkFun)
                heroIcon:setScale(itemW1 / heroIcon:getContentSize().width)
                heroIcon:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                heroIcon:setAnchorPoint(ccp(0, 0))
                heroIcon:setPosition(sx, sy)
                heroIcon:setTag(ixs)
                itemBg:addChild(heroIcon)
                self.heroIconTb[ixs] = heroIcon
                
                local selectBorderSp = CCSprite:createWithSpriteFrameName("TeamTankSelected.png")
                selectBorderSp:setPosition(getCenterPoint(heroIcon))
                selectBorderSp:setTag(1103)
                selectBorderSp:setVisible(false)
                local selScale = (20 + heroIcon:getContentSize().width) / selectBorderSp:getContentSize().width
                selectBorderSp:setScale(selScale)
                heroIcon:addChild(selectBorderSp)
                
                local nameLb = GetTTFLabelWrap(heroItem.name, G_getLS(22, 18), CCSizeMake(130, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
                nameLb:setAnchorPoint(ccp(0.5, 1))
                nameLb:setPosition(sx + itemW1 * 0.5, heroIcon:getPositionY() - 10)
                itemBg:addChild(nameLb)
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

function acJjzzSelectDialog:dispose()
    self.heroIconTb = nil
end
