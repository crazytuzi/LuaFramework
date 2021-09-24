airShipWarehouse = commonDialog:new()

function airShipWarehouse:new(layerNum)
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    self.layerNum = layerNum
    
    self.dialogWidth = G_VisibleSizeWidth
    self.dialogHeight = G_VisibleSizeHeight
    self.realHeight = self.dialogHeight - 80
    
    return nc
end

function airShipWarehouse:doUserHandler()
    self:initPropList()
end

function airShipWarehouse:initPropList()
    local asPropCfg = airShipVoApi:getAirShipCfg().Prop
    self.props = {} --飞艇绑定材料，按飞艇类型和材料类型来分组
    for k, v in pairs(asPropCfg) do
        self.props[v.type] = self.props[v.type] or {}
        local num = airShipVoApi:getPropNumById(k)
        if (num > 0 and v.type ~= 99) or v.type == 99 then
            table.insert(self.props[v.type], k)
        end
    end
    for k, v in pairs(self.props) do
        local function sort(a, b)
            local aw = asPropCfg[a].group * 10 + asPropCfg[a].quality
            local bw = asPropCfg[b].group * 10 + asPropCfg[b].quality
            if aw < bw then
                return true
            end
            return false
        end
        table.sort(v, sort)
    end
end

function airShipWarehouse:initTableView()
    self.panelLineBg:setVisible(false)
    self.panelShadeBg:setVisible(true)
    
    self.isize = 96 --材料图标尺寸
    
    local remouldTitleSp = CCSprite:createWithSpriteFrameName("believerTitleBg.png")
    remouldTitleSp:setAnchorPoint(ccp(0.5, 1))
    remouldTitleSp:setPosition(G_VisibleSizeWidth * 0.5, G_VisibleSizeHeight - 82)
    self.bgLayer:addChild(remouldTitleSp)
    local remouldTitleLb = GetTTFLabel(getlocal("airShip_wash_prop"), 22, true)
    remouldTitleLb:setColor(G_ColorYellowPro)
    remouldTitleLb:setPosition(getCenterPoint(remouldTitleSp))
    remouldTitleSp:addChild(remouldTitleLb)

    local propTitleSp = CCSprite:createWithSpriteFrameName("believerTitleBg.png")
    propTitleSp:setAnchorPoint(ccp(0.5, 1))
    propTitleSp:setPosition(G_VisibleSizeWidth * 0.5, G_VisibleSizeHeight - 248)
    self.bgLayer:addChild(propTitleSp)
    local propTitleLb = GetTTFLabel(getlocal("airShip_remould_title"), 22, true)
    propTitleLb:setColor(G_ColorYellowPro)
    propTitleLb:setPosition(getCenterPoint(propTitleSp))
    propTitleSp:addChild(propTitleLb)
    
    self.numLbTb = {}
    local itemSpace = 20
    local firstPosX = G_getCenterSx(G_VisibleSizeWidth, self.isize, 5, itemSpace)
    for k, pid in pairs(self.props[99]) do
        --材料图标
        local iconSp = airShipVoApi:getAirShipPropIcon(pid, nil, function ()
            --显示材料分解合成页面
            local plist = G_clone(airShipVoApi:getAirShipCfg().mirror[99])
            airShipVoApi:showRemakePropDialog(pid, plist, self.layerNum + 1)
        end)
        iconSp:setScale(self.isize / iconSp:getContentSize().width)
        iconSp:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
        iconSp:setPosition(firstPosX + (2 * k - 1) * self.isize / 2 + (k - 1) * itemSpace - self.isize / 2, remouldTitleSp:getPositionY() - remouldTitleSp:getContentSize().height - self.isize / 2 - 10)
        self.bgLayer:addChild(iconSp)
        
        --材料数量
        local num = airShipVoApi:getPropNumById(pid)
        local numLb = GetTTFLabel(FormatNumber(num), 20)
        numLb:setAnchorPoint(ccp(1, 0))
        numLb:setPosition(iconSp:getContentSize().width - 6, 5)
        iconSp:addChild(numLb)
        if num <= 0 then
            numLb:setColor(G_ColorRed)
        end
        self.numLbTb[pid] = numLb
    end
    
    self.tvWidth, self.tvHeight, self.perHeight = G_VisibleSizeWidth - 40, G_VisibleSizeHeight - 510, self.isize + 10
    self.csIdx, self.lsIdx = 1, 0 --默认显示1号飞艇材料
    self.cellNum = math.ceil((#self.props[self.csIdx]) / 5)
    
    local function getCellSize(idx)
        return CCSizeMake(self.tvWidth, self.perHeight)
    end
    
    self.tv = G_createTableView(CCSizeMake(self.tvWidth, self.tvHeight), function () --cell的个数
        return self.cellNum or 0
    end, getCellSize, function (cell, cellSize, idx, cellNum) --初始化cell内容
        local propList = self.props[self.csIdx]
        local itemSpace = 20
        local firstPosX, height = G_getCenterSx(self.tvWidth, self.isize, 5, itemSpace), getCellSize(idx).height
        for k = 1, 5 do
            local pid = propList[idx * 5 + k]
            if pid == nil then
                do break end
            end
            --材料图标
            local iconSp = airShipVoApi:getAirShipPropIcon(pid, nil, function ()
                --显示材料分解合成页面
                local plist = {}
                local asPropCfg = airShipVoApi:getAirShipCfg().Prop
                local mirror = airShipVoApi:getAirShipCfg().mirror[self.csIdx]
                for k, v in pairs(mirror) do --筛选出同一类型的材料
                    if asPropCfg[pid].group == asPropCfg[v].group then
                        table.insert(plist, v)
                    end
                end
                local function sort(a, b)
                    if asPropCfg[a].quality < asPropCfg[b].quality then
                        return true
                    end
                    return false
                end
                table.sort(plist, sort)
                airShipVoApi:showRemakePropDialog(pid, plist, self.layerNum + 1)
            end)
            iconSp:setScale(self.isize / iconSp:getContentSize().width)
            iconSp:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
            iconSp:setPosition(firstPosX + (2 * k - 1) * self.isize / 2 + (k - 1) * itemSpace - self.isize / 2, height / 2)
            cell:addChild(iconSp)
            
            --材料数量
            local num = airShipVoApi:getPropNumById(pid)
            local numLb = GetTTFLabel(FormatNumber(num), 20)
            numLb:setAnchorPoint(ccp(1, 0))
            numLb:setPosition(iconSp:getContentSize().width - 6, 5)
            iconSp:addChild(numLb)
        end
    end)
    
    self.tv:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 3)
    self.tv:setPosition(ccp((G_VisibleSizeWidth - self.tvWidth) / 2, 200))
    self.tv:setMaxDisToBottomOrTop(70)
    self.bgLayer:addChild(self.tv, 2)
    
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function () end)
    tvBg:setAnchorPoint(ccp(0.5, 0))
    tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40, self.tvHeight + 10))
    tvBg:setPosition(G_VisibleSizeWidth / 2, self.tv:getPositionY() - 5)
    self.bgLayer:addChild(tvBg)
    
    self.nullTipLb = GetTTFLabelWrap(getlocal("airShip_prop_null"), 20, CCSizeMake(G_VisibleSizeWidth - 60, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    self.nullTipLb:setPosition(getCenterPoint(tvBg))
    self.nullTipLb:setColor(G_ColorGray)
    tvBg:addChild(self.nullTipLb)
    if self.cellNum > 0 then
        self.nullTipLb:setVisible(false)
    end
    
    self:initWareHouseTab()
    
    local function refresh(event, data)
        self:initPropList()
        self:refreshPropsListView()
        
        if self and self.numLbTb then
            if data.props and type(data.props) == "table" then
                for k, v in pairs(data.props) do
                    if self.numLbTb[k] and tolua.cast(self.numLbTb[k], "CCLabelTTF") then
                        local numLb = tolua.cast(self.numLbTb[k], "CCLabelTTF")
                        numLb:setString(FormatNumber(tonumber(v)))
                        if tonumber(v) > 0 then
                            numLb:setColor(G_ColorWhite)
                        else
                            numLb:setColor(G_ColorRed)
                        end
                    end
                end
            end
        end
    end
    
    self.warehouseRefreshListener = refresh
    eventDispatcher:addEventListener("airship.props.refresh", self.warehouseRefreshListener)
end

function airShipWarehouse:refreshPropsListView()
    print("self.csIdx====>", self.csIdx)
    self.cellNum = math.ceil((#self.props[self.csIdx]) / 5)
    if self.cellNum > 0 then
        self.nullTipLb:setVisible(false)
    else
        self.nullTipLb:setVisible(true)
    end
    if self.tv then
        self.tv:reloadData()
    end
end

function airShipWarehouse:initWareHouseTab()
    local slideArea = CCRect(35, 8, G_VisibleSizeWidth - 70, 150)
    local item_scaleTb = {0.4, 0.6, 0.75, 1, 0.75, 0.6, 0.4}
    local item_posTb = {ccp(slideArea.size.width / 2 - 315, 90), ccp(slideArea.size.width / 2 - 230, 90), ccp(slideArea.size.width / 2 - 130, 90), ccp(0.5 * slideArea.size.width, 90), ccp(slideArea.size.width / 2 + 130, 90), ccp(slideArea.size.width / 2 + 230, 90), ccp(slideArea.size.width / 2 + 315, 90)}
    local item_tintTb = {math.floor(255 * 0.2), math.floor(255 * 0.4), math.floor(255 * 0.7), 255, math.floor(255 * 0.7), math.floor(255 * 0.4), math.floor(255 * 0.2)}
    local function createItem(idx, ischeck)
        local scrollItem, airshipSp
        if ischeck == true then --被选中
            scrollItem = CCSprite:createWithSpriteFrameName("arpl_selBg2.png")
        else
            scrollItem = CCSprite:createWithSpriteFrameName("arpl_selBg1.png")
        end
        airshipSp = CCSprite:createWithSpriteFrameName("arpl_ship"..idx.."_1.png")
        airshipSp:setScale(0.3)
        airshipSp:setPosition(getCenterPoint(scrollItem))
        scrollItem:addChild(airshipSp)
        return scrollItem
    end
    local pageList = {6, 7, 1, 2, 3} --初始页码序列
    local function createScrollItemCallback(itemIdx, ischeck)
        return createItem(itemIdx, ischeck)
    end
    local function showProps(idx)
        self.csIdx = tonumber(idx)
        
        if self.pageObj and self.pageObj.refreshItem then
            self.pageObj:refreshItem(idx, true)
        end
        -- print("self.csIdx === >", self.csIdx)
        if self.csIdx ~= self.lsIdx then
            self:refreshPropsListView()
            self.lsIdx = self.csIdx
        end
    end
    local function turnPageCallback(idx)
        if self.pageObj and self.pageObj.refreshItem then
            self.pageObj:refreshItem(idx, false)
        end
    end
    require "luascript/script/componet/ScrollPage"
    local controller = {pos = item_posTb, scale = item_scaleTb, tint = item_tintTb, mt = 0.3, slideArea = slideArea, createScrollItemCallback = createScrollItemCallback, callback = showProps, turnPageCallback = turnPageCallback}
    self.pageObj = ScrollPage:create(pageList, 7, controller, self.layerNum)
    self.pageObj.bgLayer:setPosition(0, 0)
    self.bgLayer:addChild(self.pageObj.bgLayer)
end

function airShipWarehouse:dispose()
    if self.warehouseRefreshListener then
        eventDispatcher:removeEventListener("airship.props.refresh", self.warehouseRefreshListener)
        self.warehouseRefreshListener = nil
    end
    if self.pageObj then
        self.pageObj:dispose()
        self.pageObj = nil
    end
end
