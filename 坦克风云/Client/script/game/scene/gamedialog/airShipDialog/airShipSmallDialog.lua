airShipSmallDialog = smallDialog:new()

function airShipSmallDialog:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

--飞艇材料的合成和分解面板
--pid：要合成或分解的材料id
--sameTypeProps：跟pid同一类型不同品阶材料的列表
function airShipSmallDialog:showRemakePropDialog(pid, sameTypeProps, layerNum, callback)
    local sd = airShipSmallDialog:new()
    sd:initRemakePropDialog(pid, sameTypeProps, layerNum, callback)
end

function airShipSmallDialog:initRemakePropDialog(pid, sameTypeProps, layerNum, callback)
    self.isTouch, self.isUseAmi, self.layerNum = true, true, layerNum
    
    local function close()
        if self.propsRefreshListener then
            eventDispatcher:removeEventListener("airship.props.refresh", self.propsRefreshListener)
            self.propsRefreshListener = nil
        end
        self.remakeType = nil
        self.remakeTb = nil
        self.costPid = nil
        return self:close()
    end
    
    local size = CCSizeMake(600, 680)
    local dialogBg = G_getNewDialogBg(size, getlocal("airShip_remake_title"), 26, function () end, self.layerNum, true, close, G_ColorYellowPro2)
    self.dialogLayer = CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer = dialogBg
    self.bgSize = size
    self.bgLayer:setContentSize(size)
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 2)
    self.dialogLayer:setTouchPriority(-(layerNum - 1) * 20 - 1)
    self:show()
    
    local pcfg = airShipVoApi:getAirShipCfg().Prop[pid]
    if pcfg.quality == 1 then --如果选中的是白色，默认矫正为绿色的，因为白色不能合成获得，也不能分解得到别的材料
        pid = pcfg.compound[1]
    end
    self.remakeType = 1 --1：合成，2：分解
    self.remakeTb = {pid, pid} --默认选中的材料id
    self.costPid = airShipVoApi:getAirShipCfg().Prop[pid].resolve[1] --默认显示合成，这个值为合成消耗的材料id
    
    if sameTypeProps == nil then --如果没有传一系列材料，自己在这里筛选一下
        sameTypeProps = {}
        for k, v in pairs(airShipVoApi:getAirShipCfg().Prop) do
            if v.group == pcfg.group then
                sameTypeProps[v.quality] = k
            end
        end
    end
    
    local tabTb = {
        {tabText = getlocal("activity_gangtieronglu_compose")},
        {tabText = getlocal("decompose")},
    }
    local function refresh()
        if self and self.tv and tolua.cast(self.tv, "LuaCCTableView") then
            self.tv:reloadData()
        end
        local cost = 0
        local num = airShipVoApi:getPropNumById(self.costPid)
        local pcfg = airShipVoApi:getAirShipCfg().Prop[self.costPid]
        if self.remakeType == 1 then
            cost = pcfg.compound[2]
        else
            cost = 1
        end
        self.maxRemakeNum = math.floor(num / cost) --最多可以合成或分解的次数
        self.slider:setMinimumValue(0)
        self.slider:setMaximumValue(self.maxRemakeNum)
        if self.maxRemakeNum >= 1 then
            self.slider:setValue(1)
        else
            self.slider:setValue(0)
        end
        self.remakeNumLb:setString(math.floor(self.slider:getValue()) .. "/" .. self.maxRemakeNum)
    end
    local function tabClick(idx)
        self.remakeType = idx
        refresh()
    end
    
    self.propsRefreshListener = refresh
    eventDispatcher:addEventListener("airship.props.refresh", self.propsRefreshListener)
    
    local multiTab = G_createMultiTabbed(tabTb, tabClick, "yh_ltzdzHelp_tab.png", "yh_ltzdzHelp_tab_down.png", nil, nil, 10)
    multiTab:setTabTouchPriority(-(self.layerNum - 1) * 20 - 4)
    multiTab:setTabPosition(16, self.bgSize.height - 96 - 50)
    multiTab:setParent(self.bgLayer, 2)
    self.multiTab = multiTab
    
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    tvBg:setContentSize(CCSizeMake(size.width - 32, size.height - 96 - 50 - 35))
    tvBg:setAnchorPoint(ccp(0.5, 0))
    tvBg:setPosition(ccp(size.width / 2, 35))
    self.bgLayer:addChild(tvBg)
    
    local iconWidth, smallIconWidth, iconSpace = 96, 82, 30
    local tvWidth, tvHeight = tvBg:getContentSize().width, tvBg:getContentSize().height
    self.tv = G_createTableView(CCSizeMake(tvWidth, tvHeight), 1, CCSizeMake(tvWidth, tvHeight), function (cell, cellSize, idx, cellNum) --初始化cell内容
        local remakePid = self.remakeTb[self.remakeType] --当前选中的材料id
        
        local infoBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png", CCRect(20, 20, 1, 1), function ()end)
        infoBg:setContentSize(CCSizeMake(tvWidth - 10, 130))
        infoBg:setPosition(tvWidth / 2, tvHeight - 15 - infoBg:getContentSize().height / 2)
        cell:addChild(infoBg)
        
        local remakePropSp = airShipVoApi:getAirShipPropIcon(remakePid)
        remakePropSp:setScale(iconWidth / remakePropSp:getContentSize().width)
        remakePropSp:setPosition(iconWidth / 2 + 10, infoBg:getContentSize().height / 2)
        infoBg:addChild(remakePropSp)
        
        local name, desc = airShipVoApi:getAirShipPropShowInfo(remakePid)
        local nameLb = GetTTFLabelWrap(name, G_getLS(22, 20), CCSizeMake(400, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter, "Helvetica-bold")
        nameLb:setAnchorPoint(ccp(0, 1))
        nameLb:setColor(G_ColorYellowPro)
        nameLb:setPosition(remakePropSp:getPositionX() + iconWidth / 2 + 10, remakePropSp:getPositionY() + iconWidth / 2)
        infoBg:addChild(nameLb)
        local descLb = GetTTFLabelWrap(getlocal(desc), G_getLS(20, 18), CCSizeMake(tvWidth - iconWidth - 20, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
        descLb:setAnchorPoint(ccp(0, 1))
        descLb:setPosition(nameLb:getPositionX(), nameLb:getPositionY() - nameLb:getContentSize().height - 10)
        infoBg:addChild(descLb)
        
        local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png", CCRect(4, 0, 2, 2), function ()end)
        lineSp:setContentSize(CCSizeMake(tvWidth - 30, lineSp:getContentSize().height))
        lineSp:setPosition(tvWidth / 2, infoBg:getPositionY() - infoBg:getContentSize().height / 2 - 10)
        cell:addChild(lineSp)
        
        local titleBg = G_createNewTitle({getlocal("airShip_remake_title"..self.remakeType), 22, G_ColorWhite}, CCSizeMake(300, 0), nil, true, "Helvetica-bold")
        titleBg:setPosition(ccp(size.width / 2, lineSp:getPositionY() - 40))
        cell:addChild(titleBg)
        
        local firstPosX = G_getCenterSx(tvWidth, smallIconWidth, 5, iconSpace)
        for k, v in pairs(sameTypeProps) do
            local function switchProp()
                local pcfg = airShipVoApi:getAirShipCfg().Prop[v]
                if pcfg.quality == 1 then --白色不能被分解，也不能合成获得
                    G_showTipsDialog(getlocal("airShip_remake_disable"..self.remakeType))
                    do return end
                end
                if self.remakeTb[self.remakeType] ~= v then
                    self.remakeTb[self.remakeType] = v
                    refresh()
                end
            end
            local iconSp = airShipVoApi:getAirShipPropIcon(v, nil, switchProp)
            iconSp:setScale(smallIconWidth / iconSp:getContentSize().width)
            iconSp:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
            iconSp:setPosition(firstPosX + (k - 1) * (smallIconWidth + iconSpace), titleBg:getPositionY() - smallIconWidth / 2 - 20)
            cell:addChild(iconSp)
            
            local num = airShipVoApi:getPropNumById(v)
            local numLb = GetTTFLabel(FormatNumber(num), 20)
            numLb:setAnchorPoint(ccp(0.5, 1))
            numLb:setPosition(iconSp:getPositionX(), iconSp:getPositionY() - smallIconWidth / 2)
            cell:addChild(numLb)
            
            if remakePid == v then
                local kuangSp = CCSprite:createWithSpriteFrameName("airship_remakeKuang.png")
                kuangSp:setPosition(iconSp:getPositionX() - smallIconWidth / 2 - iconSpace / 2, iconSp:getPositionY() - 15)
                cell:addChild(kuangSp, 2)
                local arrowSp = CCSprite:createWithSpriteFrameName("airship_remakeArrow.png")
                arrowSp:setPosition(iconSp:getPositionX() - smallIconWidth / 2 - iconSpace / 2, iconSp:getPositionY())
                cell:addChild(arrowSp, 2)
                if self.remakeType == 2 then
                    arrowSp:setFlipX(true)
                end
            end
            
            local needNum = 0
            local pcfg = airShipVoApi:getAirShipCfg().Prop[v]
            if self.remakeType == 1 and pcfg.compound and pcfg.compound[1] == self.remakeTb[self.remakeType] then
                needNum = pcfg.compound[2]
                self.costPid = v
            elseif self.remakeType == 2 and pcfg.resolve and v == self.remakeTb[self.remakeType] then
                needNum = 1 --分解固定消耗1个原有材料
                self.costPid = v
            end
            if needNum > 0 then
                local needLb = GetTTFLabel("/"..tostring(needNum), 20)
                local lbW = numLb:getContentSize().width + needLb:getContentSize().width
                numLb:setAnchorPoint(ccp(0, 1))
                numLb:setPosition(iconSp:getPositionX() - lbW / 2, numLb:getPositionY())
                needLb:setAnchorPoint(ccp(0, 1))
                needLb:setPosition(numLb:getPositionX() + numLb:getContentSize().width, numLb:getPositionY())
                cell:addChild(needLb)
                if needNum > num then
                    numLb:setColor(G_ColorRed)
                end
            end
        end
        
        local btnScale, priority = 0.7, -(self.layerNum - 1) * 20 - 2
        local function remakeConfirm()
            local remakeNum = math.floor(self.slider:getValue())
            if remakeNum <= 0 then
                G_showTipsDialog(getlocal("airShip_remake_err"..self.remakeType))
                do return end
            end
            local function callback()
                G_showTipsDialog(getlocal("airShip_remake_success"..self.remakeType))
            end
            --给后台传pid永远都是合成或分解要消耗的材料id
            airShipVoApi:socketMaterial(callback, self.remakeType, self.costPid, remakeNum)
        end
        local remakeStr, btnPic, btnDownPic = ""
        if self.remakeType == 1 then
            remakeStr = getlocal("activity_gangtieronglu_compose")
            btnPic, btnDownPic = "creatRoleBtn.png", "creatRoleBtn_Down.png"
        else
            remakeStr = getlocal("decompose")
            btnPic, btnDownPic = "newGrayBtn.png", "newGrayBtn_Down.png"
        end
        local remakeBtn = G_createBotton(cell, ccp(tvWidth / 2, 50), {remakeStr, 24}, btnPic, btnDownPic, btnPic, remakeConfirm, btnScale, priority)
    end)
    
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition(ccp((size.width - tvWidth) / 2, 25))
    self.tv:setMaxDisToBottomOrTop(0)
    self.bgLayer:addChild(self.tv, 2)
    
    self.maxRemakeNum = 0
    local remakeNumLb = GetTTFLabel("0/0", 20)
    self.bgLayer:addChild(remakeNumLb, 2)
    self.remakeNumLb = remakeNumLb
    
    local function onSliderHandler(handler, obj)
        local count = math.floor(obj:getValue())
        if count == 0 and self.maxRemakeNum >= 1 then
            self.slider:setValue(1)
        end
        count = math.floor(obj:getValue())
        self.remakeNumLb:setString(count .. "/" .. self.maxRemakeNum)
    end
    local slider = LuaCCControlSlider:create(CCSprite:createWithSpriteFrameName("proBar_n2.png"), CCSprite:createWithSpriteFrameName("proBar_n1.png"), CCSprite:createWithSpriteFrameName("grayBarBtn.png"), onSliderHandler)
    slider:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    slider:setIsSallow(true)
    slider:setPosition(size.width / 2, 140)
    self.bgLayer:addChild(slider)
    self.slider = slider
    
    local minusSp = LuaCCSprite:createWithSpriteFrameName("greenMinus.png", function()
        local count = math.floor(self.slider:getValue())
        if count > 1 then
            self.slider:setValue(count - 1)
        end
    end)
    minusSp:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    minusSp:setAnchorPoint(ccp(1, 0.5))
    minusSp:setPosition(slider:getPositionX() - slider:getContentSize().width / 2 - 20, slider:getPositionY())
    self.bgLayer:addChild(minusSp)
    local plusSp = LuaCCSprite:createWithSpriteFrameName("greenPlus.png", function()
        local count = math.floor(self.slider:getValue())
        if count < self.maxRemakeNum then
            self.slider:setValue(count + 1)
        end
    end)
    plusSp:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
    plusSp:setAnchorPoint(ccp(0, 0.5))
    plusSp:setPosition(slider:getPositionX() + slider:getContentSize().width / 2 + 20, slider:getPositionY())
    self.bgLayer:addChild(plusSp)
    self.remakeNumLb:setPosition(self.slider:getPositionX(), self.slider:getPositionY() + 18 + remakeNumLb:getContentSize().height / 2)
    
    self.multiTab:tabClick(1)
    
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

--零件生产库
function airShipSmallDialog:showPropPoolDialog(layerNum, callback)
    local sd = airShipSmallDialog:new()
    sd:initPropPoolDialog(layerNum, callback)
end

function airShipSmallDialog:initPropPoolDialog(layerNum, callback)
    self.isTouch, self.isUseAmi, self.layerNum = true, true, layerNum
    
    local function close()
        return self:close()
    end
    
    local size = CCSizeMake(600, 660)
    local dialogBg = G_getNewDialogBg(size, getlocal("airShip_entryStr3"), 26, function () end, self.layerNum, true, close)
    self.dialogLayer = CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer = dialogBg
    self.bgSize = size
    self.bgLayer:setContentSize(size)
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 2)
    self.dialogLayer:setTouchPriority(-(layerNum - 1) * 20 - 1)
    self:show()
    
    local pool = FormatItem(airShipVoApi:getAirShipCfg().Pooln, nil, true)
    
    local rw, rspace = 20, 100
    local leftPosX = G_getCenterSx(size.width, rw, 4, rspace)
    
    for k, v in pairs(airShipVoApi:getAirShipCfg().Poolx) do
        local rateSp = CCSprite:createWithSpriteFrameName("airship_quality"..k..".png")
        rateSp:setPosition(leftPosX + (k - 1) * (rw + rspace), size.height - 98)
        self.bgLayer:addChild(rateSp)
        
        local rateLb = GetTTFLabel((v[1] * 100) .. "%", 20)
        rateLb:setAnchorPoint(ccp(0, 0.5))
        rateLb:setPosition(rateSp:getPositionX() + rateSp:getContentSize().width / 2 + 2, rateSp:getPositionY())
        self.bgLayer:addChild(rateLb)
    end
    
    local tipLb = GetTTFLabelWrap(getlocal("airShip_pool_tip"), 20, CCSizeMake(size.width - 30, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    tipLb:setAnchorPoint(ccp(0.5, 1))
    tipLb:setColor(G_ColorYellowPro)
    tipLb:setPosition(size.width / 2, size.height - 128)
    self.bgLayer:addChild(tipLb)
    
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    tvBg:setContentSize(CCSizeMake(size.width - 32, tipLb:getPositionY() - tipLb:getContentSize().height - 30))
    tvBg:setAnchorPoint(ccp(0.5, 0))
    tvBg:setPosition(ccp(size.width / 2, 20))
    self.bgLayer:addChild(tvBg)
    
    local iconWidth, iconSpace = 96, 30
    local tvWidth, tvHeight, cellHeight = tvBg:getContentSize().width, tvBg:getContentSize().height - 10, iconWidth + 20
    local cellNum = math.ceil(#pool / 4)
    
    self.tv = G_createTableView(CCSizeMake(tvWidth, tvHeight), cellNum, CCSizeMake(tvWidth, cellHeight), function (cell, cellSize, idx, cellNum) --初始化cell内容
        local firstPosX = G_getCenterSx(tvWidth, iconWidth, 4, iconSpace)
        for k = 1, 4 do
            local pIdx = idx * 4 + k
            local item = pool[pIdx]
            if item then
                local iconSp = airShipVoApi:getAirShipPropIcon(item.key, nil, function ()
                    G_showNewPropInfo(self.layerNum + 1, true, true, nil, item, true)
                end)
                iconSp:setScale(iconWidth / iconSp:getContentSize().width)
                iconSp:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
                iconSp:setPosition(firstPosX + (k - 1) * (iconWidth + iconSpace), cellHeight / 2)
                cell:addChild(iconSp)
            end
        end
    end)
    
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition(ccp((size.width - tvWidth) / 2, tvBg:getPositionY() + 5))
    self.tv:setMaxDisToBottomOrTop(80)
    self.bgLayer:addChild(self.tv, 2)
    
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

--共振效果总览
function airShipSmallDialog:showResonateOverviewDialog(airshipIdx, layerNum, callback)
    local sd = airShipSmallDialog:new()
    sd:initResonateOverviewDialog(airshipIdx, layerNum, callback)
end

function airShipSmallDialog:initResonateOverviewDialog(airshipIdx, layerNum, callback)
    self.isTouch, self.isUseAmi, self.layerNum = true, true, layerNum
        
    local function close()
        return self:close()
    end
    
    local size = CCSizeMake(600, 750)
    local dialogBg = G_getNewDialogBg(size, getlocal("airShip_resonanceStr"), 26, function () end, self.layerNum, true, close)
    self.dialogLayer = CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer = dialogBg
    self.bgSize = size
    self.bgLayer:setContentSize(size)
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 2)
    self.dialogLayer:setTouchPriority(-(layerNum - 1) * 20 - 1)
    self:show()
    
    local cidx = 0
    local smallFontSize = 20
    local descMaxHeight = 0
    local airship = airShipVoApi:getCurAirShipInfo(airshipIdx)
    local combineEffect = airShipVoApi:getCurAirShipEquipInfo(airship)
    -- print("~~~combineEffect===>", combineEffect[4], combineEffect[2])
    local combineTb = {{combineEffect[4], 4}, {combineEffect[2], 2}}
    local qposTb = {[2] = {{-1, 1}, {1, -1}}, [4] = {{1, 1}, {1, -1}, {-1, 1}, {-1, -1}}}
    for k, v in pairs(combineTb) do
        local kuangSp = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png", CCRect(19, 19, 2, 2), function () end)
        kuangSp:setContentSize(CCSizeMake(255, 180))
        kuangSp:setPosition(size.width / 2 + (2 * k - 3) * (kuangSp:getContentSize().width / 2 + 10), size.height - 95 - kuangSp:getContentSize().height / 2)
        self.bgLayer:addChild(kuangSp)
        
        local rdata = airShipVoApi:getAirShipResonance(v[1], v[2])
        local valueStr, colorTb = "", {}
        if rdata[3] == "antifirst" then
            valueStr, colorTb = tostring(rdata[2]), {nil, G_ColorRed, nil}
        else
            valueStr, colorTb = "+"..rdata[2], {nil, G_ColorGreen, nil}
        end
        local descLb, height = G_getRichTextLabel(rdata[1] .. "<rayimg>"..valueStr .. "<rayimg>", colorTb, smallFontSize, kuangSp:getContentSize().width - 60, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
        descLb:setAnchorPoint(ccp(0.5, 1))
        descLb:setPosition(kuangSp:getPositionX(), kuangSp:getPositionY() - kuangSp:getContentSize().height / 2 - 5)
        self.bgLayer:addChild(descLb)
        
        if height > descMaxHeight then
            descMaxHeight = height
        end
        
        for qn = 1, v[2] do
            local qualitySp
            if v[1] == 0 then --没有该共振效果则置灰
                qualitySp = GraySprite:createWithSpriteFrameName("airship_gz_1.png")
            else
                qualitySp = CCSprite:createWithSpriteFrameName("airship_gz_"..v[1] .. ".png")
            end
            qualitySp:setPosition(kuangSp:getContentSize().width / 2 + qposTb[v[2]][qn][1] * (qualitySp:getContentSize().width / 2 + 8), kuangSp:getContentSize().height / 2 + qposTb[v[2]][qn][2] * (qualitySp:getContentSize().height / 2 + 8))
            kuangSp:addChild(qualitySp)
        end
    end
    
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    tvBg:setContentSize(CCSizeMake(size.width - 30, size.height - 95 - 180 - descMaxHeight - 40))
    tvBg:setAnchorPoint(ccp(0.5, 0))
    tvBg:setPosition(ccp(size.width / 2, 20))
    self.bgLayer:addChild(tvBg)
    
    local tipLb = GetTTFLabelWrap(getlocal("airShip_resonance_tip"), smallFontSize, CCSizeMake(size.width - 30, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    tipLb:setAnchorPoint(ccp(0.5, 1))
    tipLb:setColor(G_ColorRed)
    tipLb:setPosition(tvBg:getContentSize().width / 2, tvBg:getContentSize().height - 10)
    tvBg:addChild(tipLb)
    
    local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png", CCRect(4, 0, 2, 2), function ()end)
    lineSp:setContentSize(CCSizeMake(tvBg:getContentSize().width - 30, lineSp:getContentSize().height))
    lineSp:setPosition(tvBg:getContentSize().width / 2, tipLb:getPositionY() - tipLb:getContentSize().height - 10)
    tvBg:addChild(lineSp)
    
    local overviewLb = GetTTFLabel(getlocal("airShip_resonance_overview"), smallFontSize + 2)
    overviewLb:setAnchorPoint(ccp(0, 1))
    overviewLb:setPosition(20, lineSp:getPositionY() - 10)
    overviewLb:setColor(G_ColorYellowPro2)
    tvBg:addChild(overviewLb)
    
    local tvWidth, tvHeight = tvBg:getContentSize().width, overviewLb:getPositionY() - overviewLb:getContentSize().height - 10
    local iconWidth, iconSpace, descW = 25, 6, tvWidth / 2 - 20
    local cellHeightTb = {}
    local function func_cellSize(idx)
        if cellHeightTb[idx + 1] == nil then
            local qTwoData = airShipVoApi:getAirShipResonance(idx + 1, 2)
            local qFourData = airShipVoApi:getAirShipResonance(idx + 1, 4)
            local qTwoDescLb, qTwoHeight = G_getRichTextLabel(qTwoData[1] .. "+"..qTwoData[2], {}, smallFontSize, descW, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
            local qFourDescLb, qFourHeight = G_getRichTextLabel(qFourData[1] .. "-"..qFourData[2], {}, smallFontSize, descW, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
            cellHeightTb[idx + 1] = qTwoHeight + qFourHeight + 20
        end
        return CCSizeMake(tvWidth, cellHeightTb[idx + 1])
    end
    self.tv = G_createTableView(CCSizeMake(tvWidth, tvHeight), 5, func_cellSize, function (cell, cellSize, idx, cellNum) --初始化cell内容
        local cellHeight = func_cellSize(idx).height
        local posY = cellHeight
        local firstPosX = tvWidth / 2 - 15
        local stb = {2, 4}
        for k, v in pairs(stb) do
            local rdata = airShipVoApi:getAirShipResonance(idx + 1, v)
            local valueStr, colorTb = "", {}
            if rdata[3] == "antifirst" then
                valueStr, colorTb = tostring(rdata[2]), {nil, G_ColorRed, nil}
            else
                valueStr, colorTb = "+"..rdata[2], {nil, G_ColorGreen, nil}
            end
            local descLb, height = G_getRichTextLabel(rdata[1] .. "<rayimg>"..valueStr .. "<rayimg>", colorTb, smallFontSize, descW, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
            descLb:setAnchorPoint(ccp(0, 1))
            descLb:setPosition(tvWidth / 2 + 15, posY)
            cell:addChild(descLb)
            
            for q = 1, v do
                local qualitySp = CCSprite:createWithSpriteFrameName("airship_gz_" .. (idx + 1) .. ".png")
                qualitySp:setScale(25 / qualitySp:getContentSize().width)
                qualitySp:setPosition(firstPosX - (2 * q - 1) * 25 / 2 - (q - 1) * iconSpace, posY - height / 2)
                cell:addChild(qualitySp)
            end
            
            posY = posY - height - 10
        end
    end)
    
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition(ccp((size.width - tvWidth) / 2, tvBg:getPositionY() + 5))
    self.tv:setMaxDisToBottomOrTop(80)
    self.bgLayer:addChild(self.tv, 2)
    
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

--飞艇战术详情
function airShipSmallDialog:showTacticsDialog(airshipIdx, layerNum, callback)
    local sd = airShipSmallDialog:new()
    sd:initTacticsDialog(airshipIdx, layerNum, callback)
end

function airShipSmallDialog:initTacticsDialog(airshipIdx, layerNum, callback)
    self.isTouch, self.isUseAmi, self.layerNum = true, true, layerNum
    
    local function close()
        return self:close()
    end
    
    local size = CCSizeMake(600, 800)
    local dialogBg = G_getNewDialogBg(size, getlocal("airShip_tactics_title"), 26, function () end, self.layerNum, true, close, G_ColorYellowPro2)
    self.dialogLayer = CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer = dialogBg
    self.bgSize = size
    self.bgLayer:setContentSize(size)
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer, 2)
    self.dialogLayer:setTouchPriority(-(layerNum - 1) * 20 - 1)
    self:show()
    
    self.showType = 1 --1：简单模式，2：详细模式
    self.airshipInfo = airShipVoApi:getCurAirShipInfo(airshipIdx)
    self.tvCellHeightTb = {}
    
    local tabTb = {
        {tabText = getlocal("airShip_tactics_tab1")},
        {tabText = getlocal("airShip_tactics_tab2")},
    }
    local function refresh()
        self.tvCellHeightTb = {}
        self.airshipInfo = airShipVoApi:getCurAirShipInfo(airshipIdx)
        if self and self.tv and tolua.cast(self.tv, "LuaCCTableView") then
            self.tv:reloadData()
        end
    end
    local function tabClick(idx)
        self.showType = idx
        refresh()
    end
    
    local multiTab = G_createMultiTabbed(tabTb, tabClick, "yh_ltzdzHelp_tab.png", "yh_ltzdzHelp_tab_down.png", nil, nil, 10)
    multiTab:setTabTouchPriority(-(self.layerNum - 1) * 20 - 4)
    multiTab:setTabPosition(16, self.bgSize.height - 96 - 50)
    multiTab:setParent(self.bgLayer, 2)
    self.multiTab = multiTab
    
    self.multiTab:tabClick(1)
    
    local smFsize = 20
    local tipLb = GetTTFLabelWrap(getlocal("airShip_tactics_tip"), smFsize, CCSizeMake(size.width - 60, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentBottom)
    tipLb:setAnchorPoint(ccp(0, 0))
    tipLb:setColor(G_ColorRed)
    tipLb:setPosition(30, 148)
    self.bgLayer:addChild(tipLb)
    
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function()end)
    tvBg:setContentSize(CCSizeMake(size.width - 32, size.height - 96 - 50 - 98 - tipLb:getContentSize().height - 60))
    tvBg:setAnchorPoint(ccp(0.5, 0))
    tvBg:setPosition(ccp(size.width / 2, tipLb:getPositionY() + tipLb:getContentSize().height + 10))
    self.bgLayer:addChild(tvBg)
    
    local colorTypeTb = {G_ColorWhite, G_ColorGreen, G_ColorBlue, G_ColorPurple, G_ColorOrange}
    
    local airShipCfg = airShipVoApi:getAirShipCfg()
    local tLv = airShipVoApi:getTacticsFloorLvl(self.airshipInfo[2], airShipCfg.airship[airshipIdx].equipId)
    local tnum = SizeOfTable(airShipCfg.serverreward.resetPool) --可以解锁的战术数量
    
    --战术洗练池显示
    local function touchTip()
        local textFormatTb = {{}, {}}
        local airShipCfg = airShipVoApi:getAirShipCfg()
        for idx, tId in pairs(airShipCfg.serverreward.resetPool[tLv]) do
            local pdata = airShipVoApi:getTacticsPropertyById(tId)
            local pstr = pdata.desc.."+"
            local color = {}
            table.insert(color, G_ColorWhite)
            for k, v in pairs(pdata.pv) do
                if k ~= 1 then
                    pstr = pstr.."/"
                end
                pstr = pstr.."<rayimg>" .. airShipVoApi:getPropertyValueStr(pdata.pkey, v) .. "<rayimg>"
                table.insert(color, colorTypeTb[k])
                table.insert(color, G_ColorWhite)
            end
            table.insert(color, G_ColorWhite)
            table.insert(textFormatTb[2], {text = pstr, color = color, r = true})
        end
        local color = nil
        for k = 1, 5 do
            if k == 1 or k == 4 then
                color = {nil, G_ColorGreen, nil, G_ColorGreen, nil}
            elseif k == 2 or k == 5 then
                color = {nil, G_ColorGreen, nil}
            else
                color = nil
            end
            table.insert(textFormatTb[1], {text = getlocal("airShip_tactics_rule"..k), color = color, r = ((color ~= nil) and true or false)})
        end
        local tabTb = {
            {tabText = getlocal("ladder_help_subtitle_1_2")},
            {tabText = getlocal("airShip_tactics_washpool")},
        }
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showMultiTabInfo({text = getlocal("airShip_tactics_info")}, tabTb, textFormatTb, nil, self.layerNum + 1)
    end
    G_addMenuInfo(self.bgLayer, self.layerNum, ccp(self.bgSize.width - 49, self.bgSize.height - 110), {}, nil, nil, 28, touchTip, true)
    
    local lockKey = "airship.tactics.lock@"..playerVoApi:getUid()
    --获取战术上锁数据
    local function getLock()
        local str = CCUserDefault:sharedUserDefault():getStringForKey(lockKey)
        if str and str ~= "" then
            return G_Json.decode(str)
        end
        return nil
    end
    --保存战术上锁数据
    local function saveLock(lock)
        local str = G_Json.encode(lock)
        CCUserDefault:sharedUserDefault():setStringForKey(lockKey, str)
        CCUserDefault:sharedUserDefault():flush()
    end
    
    local lock = getLock() or {0, 0, 0, 0, 0} --战术上锁列表
    
    --刷新洗练战术消耗
    local function refreshPropCost()
        local iconWidth = 50
        local lockNum = 0
        for k, v in pairs(lock) do
            if v == 1 then
                lockNum = lockNum + 1
            end
        end
        local costPid, costNum = airShipVoApi:getTacticsWashCost(tLv, lockNum)
        local num = airShipVoApi:getPropNumById(costPid)
        if self.costSp == nil then
            local costSp = airShipVoApi:getAirShipPropIcon(costPid, nil, function () end)
            costSp:setScale(iconWidth / costSp:getContentSize().width)
            costSp:setAnchorPoint(ccp(0, 0.5))
            costSp:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
            self.bgLayer:addChild(costSp)
            self.costSp = costSp
            local ownLb = GetTTFLabel(FormatNumber(num) .. "/", 18)
            ownLb:setAnchorPoint(ccp(0, 0.5))
            self.bgLayer:addChild(ownLb)
            local costLb = GetTTFLabel(tostring(costNum), 18)
            costLb:setAnchorPoint(ccp(0, 0.5))
            self.bgLayer:addChild(costLb)
            self.ownLb, self.costLb = ownLb, costLb
        end
        self.ownLb:setString(FormatNumber(num) .. "/")
        self.costLb:setString(tostring(costNum))
        if costNum > num then
            self.costLb:setColor(G_ColorRed)
        else
            self.costLb:setColor(G_ColorWhite)
        end
        local realW = iconWidth + self.ownLb:getContentSize().width + self.costLb:getContentSize().width + 5
        self.costSp:setPosition(size.width / 2 - 175 - realW / 2, 115)
        self.ownLb:setPosition(self.costSp:getPositionX() + iconWidth + 5, self.costSp:getPositionY())
        self.costLb:setPosition(self.ownLb:getPositionX() + self.ownLb:getContentSize().width, self.costSp:getPositionY())
    end
    
    refreshPropCost() --初始化洗练消耗
    
    local tIconSize, textSpace = 60, 15
    local tvWidth, tvHeight = tvBg:getContentSize().width, tvBg:getContentSize().height - 10
    local function getTacticsPropertyLb(tId)
        local pstr, colorTb = "", {}
        if self.showType == 1 then
            local pdata = airShipVoApi:getTacticsPropertyById(tId, tLv)
            pstr = pdata.desc.."+<rayimg>" .. airShipVoApi:getPropertyValueStr(pdata.pkey, pdata.pv) .. "<rayimg>"
            colorTb = {nil, colorTypeTb[tLv], nil}
        else
            local pdata = airShipVoApi:getTacticsPropertyById(tId)
            pstr = pdata.desc.."+"
            table.insert(colorTb, G_ColorWhite)
            for k, v in pairs(pdata.pv) do
                if k ~= 1 then
                    pstr = pstr.."/"
                end
                pstr = pstr.."<rayimg>" .. airShipVoApi:getPropertyValueStr(pdata.pkey, v) .. "<rayimg>"
                table.insert(colorTb, colorTypeTb[k])
                table.insert(colorTb, G_ColorWhite)
            end
            table.insert(colorTb, G_ColorWhite)
        end
        local propertyLb, height = G_getRichTextLabel(pstr, colorTb, smFsize, 380, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        propertyLb:setAnchorPoint(ccp(0, 1))
        return propertyLb, height
    end
    local function getCellSize(idx)
        if self.tvCellHeightTb[idx + 1] == nil and self.airshipInfo[3] then
            local height = 0
            local tId = self.airshipInfo[3][idx + 1]
            if tId and tId > 0 then
                local plb, ph = getTacticsPropertyLb(tId)
                if self.airshipInfo[4] then
                    local newtId = self.airshipInfo[4][idx + 1]
                    if newtId and newtId > 0 then --有洗练出来的战术
                        local newplb, newph = getTacticsPropertyLb(newtId)
                        height = height + newph + 10 --10为文字间距
                    end
                end
                height = height + ph + 40 --20为cell上下间距
            else
                local noLb = GetTTFLabelWrap(getlocal("airShip_tactics_nope"), smFsize, CCSizeMake(420, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
                height = noLb:getContentSize().height + 20
            end
            if height < tIconSize + 40 then
                height = tIconSize + 40
            end
            self.tvCellHeightTb[idx + 1] = height
        end
        return CCSizeMake(tvWidth, self.tvCellHeightTb[idx + 1] or 0)
    end
    local leftPosX = 125
    self.tv = G_createTableView(CCSizeMake(tvWidth, tvHeight), tnum, getCellSize, function (cell, cellSize, idx, cellNum) --初始化cell内容
        local ch = getCellSize(idx).height
        
        local tacticsSp = CCSprite:createWithSpriteFrameName("airship_zs_"..tLv..".png")
        tacticsSp:setScale(tIconSize / tacticsSp:getContentSize().width)
        tacticsSp:setPosition(15 + tIconSize / 2, ch / 2)
        cell:addChild(tacticsSp)
        
        local tId
        if self.airshipInfo[3] then
            tId = self.airshipInfo[3][idx + 1]
        end
        if tId == nil or tId <= 0 then --没有此条战术
            local noLb = GetTTFLabelWrap(getlocal("airShip_tactics_nope"), smFsize, CCSizeMake(420, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
            noLb:setAnchorPoint(ccp(0, 0.5))
            noLb:setPosition(leftPosX, ch / 2)
            noLb:setColor(G_ColorRed)
            cell:addChild(noLb)
        else
            local propertyLb, height = getTacticsPropertyLb(tId)
            propertyLb:setPosition(leftPosX, ch / 2 + height / 2)
            cell:addChild(propertyLb)
            if self.airshipInfo[4] then
                local newtId = self.airshipInfo[4][idx + 1]
                if newtId and newtId > 0 then
                    local newPropertyLb, newHeight = getTacticsPropertyLb(newtId)
                    newPropertyLb:setPosition(leftPosX, ch - height - 30)
                    cell:addChild(newPropertyLb)
                    propertyLb:setPosition(leftPosX, ch - 20)
                    local newSp = CCSprite:createWithSpriteFrameName("arpl_newStrTip.png")
                    newSp:setAnchorPoint(ccp(0, 1))
                    newSp:setPosition(78, newPropertyLb:getPositionY() + 6)
                    cell:addChild(newSp)
                end
            end
        end
        
        if tId and tId > 0 and tLv > 1 then --有战术并且战术大于1条时才会显示上锁标识
            local lockSp, unLockSp
            local function lockHandler()
                if lock[idx + 1] == 1 then
                    lock[idx + 1] = 0
                    lockSp:setVisible(false)
                    unLockSp:setVisible(true)
                else
                    lock[idx + 1] = 1
                    lockSp:setVisible(true)
                    unLockSp:setVisible(false)
                end
                refreshPropCost() --刷新洗练消耗
                saveLock(lock)
            end
            lockSp = LuaCCSprite:createWithSpriteFrameName("airship_zslock.png", lockHandler)
            lockSp:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
            lockSp:setPosition(tvWidth - 10 - lockSp:getContentSize().width / 2, ch / 2)
            cell:addChild(lockSp)
            
            unLockSp = CCSprite:createWithSpriteFrameName("airship_zsunlock.png")
            unLockSp:setPosition(lockSp:getPosition())
            cell:addChild(unLockSp, 2)
            if lock[idx + 1] == 1 then
                lockSp:setVisible(true)
                unLockSp:setVisible(false)
            else
                lockSp:setVisible(false)
                unLockSp:setVisible(true)
            end
        else
            lock[idx + 1] = 0 --修正一下上锁数据
        end
        
        local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png", CCRect(4, 0, 2, 2), function ()end)
        lineSp:setContentSize(CCSizeMake(tvWidth - 30, lineSp:getContentSize().height))
        lineSp:setPosition(tvWidth / 2, 2)
        cell:addChild(lineSp)
    end)
    
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition(ccp((size.width - tvWidth) / 2, tvBg:getPositionY() + 5))
    self.tv:setMaxDisToBottomOrTop(80)
    self.bgLayer:addChild(self.tv, 2)
    
    local btnScale, priority, btnPosY = 0.7, -(self.layerNum - 1) * 20 - 4, 56
    --替换战术
    local function exchangeTacticsHandler()
        if self.airshipInfo[4] == nil or next(self.airshipInfo[4]) == nil then --没有要替换的战术
            G_showTipsDialog(getlocal("airShip_tactics_err2"))
            do return end
        end
        local function realExchange()
            local function exchangeCallback()
                G_showTipsDialog(getlocal("airShip_tactics_exchangeSuccess"))
                refresh()
            end
            airShipVoApi:tacticsReplace(exchangeCallback, airshipIdx)
        end
        realExchange()
    end
    local exchangeBtn = G_createBotton(self.bgLayer, ccp(size.width / 2 + 175, btnPosY), {getlocal("airShip_tactics_exchage"), 24}, "newGreenBtn.png", "newGreenBtn_Down.png", "newGreenBtn.png", exchangeTacticsHandler, btnScale, priority)
    
    --洗练战术
    local function washTacticsHandler()
        local lockParam = {} --存储上锁的位置
        for k, v in pairs(lock) do
            if v == 1 then
                table.insert(lockParam, k)
            end
        end
        if #lockParam >= tLv then --所有位置都上锁了，没有要洗练的战术
            G_showTipsDialog(getlocal("airShip_tactics_err1"))
            do return end
        end
        local costPid, costNum, gold = airShipVoApi:getTacticsWashCost(tLv, #lockParam)
        local num = airShipVoApi:getPropNumById(costPid)
        local propNameStr = airShipVoApi:getAirShipPropShowInfo(costPid, isShowQuality)
        local costGold = 0
        if costNum > num then
            costGold = (costNum - num) * gold
        end
        
        local function realWash()
            local function washCallback()
                G_showTipsDialog(getlocal("airShip_tactics_washSuccess"))
                refresh()
                refreshPropCost()
            end
            airShipVoApi:socketSuccinct(washCallback, airshipIdx, lockParam, costGold)
        end
        
        local tipStr, colorTb = "", {nil, G_ColorYellowPro, nil, G_ColorYellowPro, nil}
        if costGold > 0 then
            tipStr = getlocal("airShip_tactics_washTip2", {propNameStr, costGold})
        else
            tipStr = getlocal("airShip_tactics_washTip1", {costNum, propNameStr})
        end
        G_dailyConfirm("airship.tactics.wash", {tipStr, colorTb}, realWash, self.layerNum + 1)
    end
    local washBtn = G_createBotton(self.bgLayer, ccp(size.width / 2 - 175, btnPosY), {getlocal("airShip_tactics_wash"), 24}, "newGreenBtn.png", "newGreenBtn_Down.png", "newGreenBtn.png", washTacticsHandler, btnScale, priority)
    
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
