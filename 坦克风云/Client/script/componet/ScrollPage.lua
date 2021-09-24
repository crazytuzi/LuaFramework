ScrollPage = {}
function ScrollPage:new()
    local nc = {
    }
    setmetatable(nc, self)
    self.__index = self
    return nc
end

--pageTb：显示的滑动元素的页码序列
--maxPage：最大页码
function ScrollPage:create(pageTb, maxPage, scrollController, layerNum)
    local sp = ScrollPage:new()
    sp:init(pageTb, maxPage, scrollController, layerNum)
    return sp
end

function ScrollPage:init(pageTb, maxPage, scrollController, layerNum)
    self.bgLayer = CCLayer:create()
    self.bgLayer:setTouchEnabled(true)
    
    self.slideArea = scrollController.slideArea or CCRect(0, 0, G_VisibleSizeWidth, G_VisibleSizeHeight) --滑动区域
    
    --添加裁剪区域
    local clipper = CCClippingNode:create()
    clipper:setContentSize(CCSizeMake(self.slideArea.size.width, self.slideArea.size.height))
    clipper:setAnchorPoint(ccp(0, 0))
    clipper:setPosition(self.slideArea:getMinX(), self.slideArea:getMinY())
    local stencil = CCDrawNode:getAPolygon(CCSizeMake(self.slideArea.size.width, self.slideArea.size.height), 1, 1)
    clipper:setStencil(stencil)
    self.bgLayer:addChild(clipper)
    self.clipperAreaSp = clipper
    
    self.layerNum = layerNum
    
    local priority = scrollController.priority or (-(self.layerNum - 1) * 20 - 5)
    self.item_posTb = scrollController.pos or {} --滑动元素的位置（包括在显示区域外的左右两边的位置）
    self.item_scaleTb = scrollController.scale or {} --滑动元素所在位置的缩放比例（包括在显示区域外的左右两边的缩放比例）
    self.item_tintTb = scrollController.tint or {} --滑动元素的色彩值配置，作为加遮罩使用
    self.createScrollItemCallback = scrollController.createScrollItemCallback --创建滑动元素的回调
    self.callback = scrollController.callback --点击每个滑动元素的回调
    self.touchBeganCallback = scrollController.touchBeganCallback --触摸开始的回调
    self.touchEndedCallback = scrollController.touchEndedCallback --触摸结束的回调
    self.touchMovedCallback = scrollController.touchMovedCallback --触摸移动的回调
    self.turnPageCallback = scrollController.turnPageCallback --开始翻页回调
    
    self.mt, self.sr = (scrollController.mt or 0.3), 1 --滑动时间,滑动加速倍率
    self.priority = priority
    
    self.pageNum = #pageTb --显示的滑动元素个数
    self.page = pageTb[math.ceil(self.pageNum / 2)]--当前页码
    self.maxPage = maxPage
    self.pageList = {} --显示的滑动元素列表
    for k, v in pairs(pageTb) do
        local scrollItem = self:createItem(v, {pos = self.item_posTb[k + 1], scale = self.item_scaleTb[k + 1], tint = self.item_tintTb[k + 1]}, (v == self.page) and true or false)
        table.insert(self.pageList, scrollItem)
    end
    
    self.touchArr = {} --触摸点
    self.isMoving, self.isAniming = false, false --是否在滑动中,是否在滑动元素切换中
    
    local function touchEvent(...)
        if self.isAniming == false then
            return self:touchEvent(...)
        end
    end
    self.bgLayer:registerScriptTouchHandler(touchEvent, false, priority, false)
    self.bgLayer:setTouchPriority(priority)
    
    self.touchEnable = true
    self.isMoved = false
end

--触摸位置是否在设定的滑动区域内
function ScrollPage:isInSlideArea(x, y)
    -- print("~slideArea====>", self.slideArea:getMinX(), self.slideArea:getMaxX(), self.slideArea:getMinY(), self.slideArea:getMaxY())
    if x > self.slideArea:getMinX() and x < self.slideArea:getMaxX() and y > self.slideArea:getMinY() and y < self.slideArea:getMaxY() then
        -- print("~~~is in slide area!!!", x, y)
        return true
    end
    return false
end

function ScrollPage:touchEvent(fn, x, y, touch)
    if fn == "began" then
        if SizeOfTable(self.touchArr) >= 1 or self.isAniming == true then
            -- print("~~~touch forbid!!!")
            return 0
        end
        
        if self.slideArea then
            if self:isInSlideArea(x, y) == false then
                -- print("~~~touch forbid!!!")
                return 0
            end
        end
        
        self.isMoved = false
        self.touchArr[touch] = touch
        
        self.startPos = ccp(x, y)
        -- print("~~~self.startPos", self.startPos.x, self.startPos.y)
        return 1
    elseif fn == "moved" then
        self.isMoving = true
    elseif fn == "ended" then
        self.touchArr = {}
        local moveDis = self.startPos.x - x
        if moveDis < -100 then
            self:turnPage(1, true)
        elseif moveDis > 100 then
            self:turnPage(1, false)
        end
        self.isMoving = false
    else
        self.touchArr = nil
        self.touchArr = {}
        self.isMoving = false
    end
end

function ScrollPage:turnPage(jump, isLeft)
    if self.turnPageCallback then
        self.turnPageCallback(self.page)
    end
    if isLeft == true then
        self:leftPage(jump)
    else
        self:rightPage(jump)
    end
end

function ScrollPage:touchItem(hd, fn, tag)
    if self.isMoving == true or self.isAniming == true then
        -- print("~~~is moving so touch forbid!!!", self.isMoving, self.isAniming)
        do return end
    end
    local posIdx = self:getPosIdxByPage(tonumber(tag))
    if posIdx == math.ceil(self.pageNum / 2) then --如果点击的是当前页，则直接调用触摸回调
        -- print("~~~it's on this page!!!", self.page, posIdx)
        if self.callback and type(self.callback) == "function" then
            self.callback(tag)
        end
        do return end
    end
    local jump = posIdx - math.ceil(self.pageNum / 2) --算出需要跳的页数进行跳页处理
    self.sr = (math.abs(jump) >= 1) and math.abs(jump) or 1 --跳页的话移动加速的加速倍率
    print("self.mt,self.sr====>", self.mt, self.sr)
    if jump > 0 then
        self:turnPage(jump, false)
    elseif jump < 0 then
        self:turnPage(math.abs(jump), true)
    end
end

function ScrollPage:getPosIdxByPage(pageIdx)
    if pageIdx == self.page then
        return math.ceil(self.pageNum / 2)
    end
    for k, v in pairs(self.pageList) do
        if v and tolua.cast(v, "CCSprite") then
            if tonumber(v:getTag()) == pageIdx then
                return k
            end
        end
    end
    return 0
end

--创建滑动后即将显示的滑动元素
--itemIdx：item所在页码
--icfg：item显示属性配置
--ischeck：是否是被选中页码（也就是中间位置的页码）的标识
function ScrollPage:createItem(itemIdx, icfg, ischeck)
    -- print("itemIdx=====?", itemIdx)
    local function touchHandler(hd, fn, tag)
        self:touchItem(hd, fn, tag)
    end
    local itemSp = LuaCCSprite:createWithSpriteFrameName("rankKuang.png", touchHandler)
    local scrollItem = self.createScrollItemCallback(itemIdx, ischeck)
    itemSp:setContentSize(CCSizeMake(scrollItem:getContentSize().width, scrollItem:getContentSize().height))
    scrollItem:setPosition(getCenterPoint(itemSp))
    itemSp:setTag(itemIdx)
    itemSp:addChild(scrollItem)
    itemSp:setPosition(icfg.pos)
    itemSp:setScale(icfg.scale)
    itemSp:setTouchPriority(self.priority + 1)
    itemSp:setOpacity(0)
    self.clipperAreaSp:addChild(itemSp)
    
    if icfg.tint then
        self:playTint(itemSp, icfg.tint, false)
    end
    
    return itemSp
end

--刷新指定页码的显示对象
function ScrollPage:refreshItem(itemIdx, ischeck)
    local posIdx = self:getPosIdxByPage(itemIdx)
    if posIdx <= 0 or posIdx > self.pageNum then
        do return end
    end
    local scrollItem = self.pageList[posIdx]
    if scrollItem == nil or tolua.cast(scrollItem, "CCSprite") == nil then
        do return end
    end
    local icfg = {pos = self.item_posTb[posIdx + 1], scale = self.item_scaleTb[posIdx + 1], tint = self.item_tintTb[posIdx + 1]}
    local item = self:createItem(itemIdx, icfg, ischeck)
    self.pageList[posIdx] = item
    if scrollItem then
        scrollItem:removeFromParentAndCleanup(true)
        scrollItem = nil
        -- print("~~~remove old scroll item!!!", itemIdx, posIdx)
    end
end

--获取指定页码的item
function ScrollPage:getItem(page)
    for k, v in pairs(self.pageList) do
        if v and tolua.cast(v, "CCSprite") then
            if v:getTag() == page then
                return v
            end
        end
    end
    return nil
end

function ScrollPage:getCurPage()
    return self.page
end

--执行非选中页的遮罩动画
function ScrollPage:playTint(scrollItem, cv, isAnim)
    G_playSpriteTint(scrollItem, self.mt / self.sr, ccc3(cv, cv, cv), isAnim, false)
end

function ScrollPage:leftPage(jump)
    jump = jump - 1
    
    local newPage = self.page - 1
    if newPage < 1 then
        newPage = self.maxPage
    end
    
    self.isAniming = true
    
    local leftIdx = self.page - math.ceil(self.pageNum / 2) --左边缓存区的页码（即将要显示的滑动元素所在页面）
    if leftIdx < 1 then
        leftIdx = self.maxPage + leftIdx
    end
    self.page = newPage
    
    local icfg = {pos = self.item_posTb[1], scale = self.item_scaleTb[1], tint = self.item_tintTb[1]}
    local leftItem = self:createItem(leftIdx, icfg) --创建即将显示的滑动元素
    table.insert(self.pageList, 1, leftItem)
    
    for k, v in pairs(self.pageList) do
        local itemSp = tolua.cast(v, "LuaCCSprite")
        if itemSp then
            local arr = CCArray:create()
            local moveTo = CCMoveTo:create(self.mt / self.sr, self.item_posTb[k + 1])
            local scaleTo = CCScaleTo:create(self.mt / self.sr, self.item_scaleTb[k + 1])
            arr:addObject(moveTo)
            arr:addObject(scaleTo)
            local targetTint = self.item_tintTb[k + 1]
            if targetTint then
                self:playTint(itemSp, targetTint, true)
            end
            local swpanAc = CCSpawn:create(arr)
            itemSp:runAction(CCSequence:createWithTwoActions(swpanAc, CCCallFunc:create(function ()
                if k == self.pageNum + 1 then
                    local rightItem = tolua.cast(self.pageList[self.pageNum + 1], "CCNode")
                    if rightItem then
                        rightItem:removeFromParentAndCleanup(true)
                        rightItem = nil
                        -- print("~~~move out screen item!!!")
                    end
                    table.remove(self.pageList, self.pageNum + 1)
                    if jump > 0 then
                        self:leftPage(jump)
                    else
                        -- print("~~~~left move end!!!")
                        self.isAniming = false
                        if self.callback then
                            self.callback(self.page, true)
                        end
                    end
                end
            end)))
        end
    end
end

function ScrollPage:rightPage(jump)
    jump = jump - 1
    
    local newPage = self.page + 1
    if newPage > self.maxPage then
        newPage = 1
    end
    self.isAniming = true
    
    local rightIdx = self.page + math.ceil(self.pageNum / 2) --右边缓存区的页码（即将要显示的滑动元素所在页面）
    if rightIdx > self.maxPage then
        rightIdx = rightIdx - self.maxPage
    end
    self.page = newPage
    
    local icfg = {pos = self.item_posTb[self.pageNum + 2], scale = self.item_scaleTb[self.pageNum + 2], tint = self.item_tintTb[self.pageNum + 2]}
    local rightItem = self:createItem(rightIdx, icfg) --创建即将显示的滑动元素
    
    table.insert(self.pageList, rightItem)
    for k, v in pairs(self.pageList) do
        local itemSp = tolua.cast(v, "LuaCCSprite")
        if itemSp then
            local arr = CCArray:create()
            local moveTo = CCMoveTo:create(self.mt / self.sr, self.item_posTb[k])
            local scaleTo = CCScaleTo:create(self.mt / self.sr, self.item_scaleTb[k])
            arr:addObject(moveTo)
            arr:addObject(scaleTo)
            local targetTint = self.item_tintTb[k]
            if targetTint then
                self:playTint(itemSp, targetTint, true)
            end
            local swpanAc = CCSpawn:create(arr)
            itemSp:runAction(CCSequence:createWithTwoActions(swpanAc, CCCallFunc:create(function ()
                if k == self.pageNum + 1 then
                    local leftItem = tolua.cast(self.pageList[1], "CCNode")
                    if leftItem then
                        leftItem:removeFromParentAndCleanup(true)
                        leftItem = nil
                        -- print("~~~move out screen item!!!")
                    end
                    table.remove(self.pageList, 1)
                    if jump > 0 then
                        self:rightPage(jump)
                    else
                        -- print("~~~~right move end!!!")
                        self.isAniming = false
                        if self.callback then
                            self.callback(self.page, false)
                        end
                    end
                end
            end)))
        end
    end
end

function ScrollPage:dispose()
    self.priority = nil
    self.item_posTb = nil
    self.item_scaleTb = nil
    self.item_tintTb = nil
    self.createScrollItemCallback = nil
    self.callback = nil
    self.touchBeganCallback = nil
    self.touchEndedCallback = nil
    self.touchMovedCallback = nil
    self.turnPageCallback = nil
    self.mt, self.sr = nil, nil
    
    self.pageNum = nil
    self.page = nil
    self.maxPage = nil
    self.pageList = nil
    self.touchArr = nil
    self.isMoving, self.isAniming = nil, nil
    self.bgLayer = nil
    self = nil
end
