--[[
    文件名：SliderTableView
	描述：每次滑动一个Item的距离，支持水平和垂直两种显示方式；可以指定是否选中条目显示在正中间，或条目从上到下显示，或条目从左向右显示。
	创建人：liaoyuangang
	创建时间：2014.03.24

-- 提供的公共成员函数：
    reloadData：刷新列表全部数据
    refreshItem：刷新一条数据
    getSelectItemIndex：获取当前选中条目的Index
    setSelectItemIndex：设置选中的条目的Index
    getContentOffset: 获取当前显示内容的偏移位置
    setContentOffset: 设置当前显示内容的偏移位置
-- ]]

--[[
-- 从 CCClippingRegionNode 继承，以达到只绘制指定区域
-- params 参数
        width: 显示区域的宽度
        height: 显示区域的高度
        isVertical: 是否是垂直Slider
        selectIndex: 选中item的index, 下标从0开始
        selItemOnMiddle:选中Item是否需要显示在中间
        needInertia: 滑动是否需要惯性效果，默认为true
        needRefreshSelectChangedItem: 是否需要刷新选中状态改变的条目，默认为true
        ------回调函数---------
        itemCountOfSlider: 获取item的总数
        itemSizeOfSlider: 获取item的显示大小, 回调参数 (pSender, itemIndex)
        sliderItemAtIndex: 获取item的显示内容, 回调参数 (pSender, itemNode, itemIndex, isSelected)
        selectItemChanged: 选中的Item已改变, 回调参数 (pSender, selectItemIndex)
        onItemClecked: 当前点击Item的回调，回调参数(pSender, onClickItemIndex)
        onTouchBegin: 触摸开始的回调
        onTouchEnd: 触摸结束的回调
--]]
local SliderTableView = class("SliderTableView", function(params)
    return ccui.ScrollView:create()
end)

-- 滑动距离需要的缩放比例
local touchScale = 1.0

--[[
-- params 参数
        width: 显示区域的宽度
        height: 显示区域的高度
        isVertical: 是否是垂直Slider
        selectIndex: 选中item的index, 下标从0开始
        selItemOnMiddle:选中Item是否需要显示在中间
        touchEnabled: 是否可以滑动，默认为true
        needInertia: 滑动是否需要惯性效果
        needRefreshSelectChangedItem: 是否需要刷新选中状态改变的条目，默认为true
        ------回调函数---------
        itemCountOfSlider: 获取item的总数
        itemSizeOfSlider: 获取item的显示大小, 回调参数 (pSender, itemIndex)
        sliderItemAtIndex: 获取item的显示内容, 回调参数 (pSender, itemNode, itemIndex, isSelected)
        selectItemChanged: 处于中间的Item已改变, 回调参数 (pSender, selectItemIndex)
        onItemClecked: 当前点击Item的回调，回调参数(pSender, onClickItemIndex)
        onTouchBegin: 触摸开始的回调, 回调参数(pSender, touch, event)
        onTouchEnd: 触摸结束的回调, 回调参数(pSender, touch, event)
--]]
function SliderTableView:ctor(params)
    -- 创建剪裁层
--    local tempNode = ccui.Scale9Sprite:create("sc_2.png")
--    tempNode:setAnchorPoint(cc.p(0, 0))
--    tempNode:setContentSize(cc.size(params.width, params.height))
--    self.clippNode = cc.ClippingNode:create(tempNode)
--    self.clippNode:setPosition(cc.p(0, 0))
--    self:addChild(self.clippNode)

    self.itemCountOfSlider = params.itemCountOfSlider
    self.itemSizeOfSlider = params.itemSizeOfSlider
    self.sliderItemAtIndex = params.sliderItemAtIndex
    self.selectItemChanged = params.selectItemChanged
    self.onItemClecked = params.onItemClecked
    self.onTouchBegin = params.onTouchBegin
    self.onTouchEnd = params.onTouchEnd
    self.mTouchEnabled = params.touchEnabled or true

    self.mItemCount = 0
    self.mWidth = params.width
    self.mHeight = params.height
    self.mIsVertical = params.isVertical
    -- 先判断params.selectIndex是否为nil，再判断是否大于等于0
    self.mSelectIndex = params.selectIndex and params.selectIndex >= 0 and (params.selectIndex + 1) or 1
    self.mSelItemOnMiddle = params.selItemOnMiddle
    self.mNeedInertia = params.needInertia ~= false
    self.mNeedRefreshSelectChangedItem = params.needRefreshSelectChangedItem ~= false

    -- 获取列表每屏显示的最大item数
    self.mViewBeginIndex = 0
    self.mViewEndIndex = 0
    self.mTouchEnd = true
    self.mItemInfos = {}
    self.mDelayCreatePreItemTime = 0  -- 延迟加载条目的计时

    self:setContentSize(cc.size(self.mWidth, self.mHeight))
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setIgnoreAnchorPointForPosition(false)

    -- 列表item的容器控件
    self.mContainerNode = ccui.Layout:create()
    self.mContainerNode:setContentSize(cc.size(self.mWidth, self.mHeight))
    self.mContainerNode:setPosition(cc.p(0, self.mHeight))
    self:addChild(self.mContainerNode)
    --
    self:setOnTouch()

    self:registerScriptHandler(function(event)
        if "enter" == event then
            -- Todo
        elseif "exit" == event then
            if self.mRefreshHandle then
                local tempScheduler = cc.Director:getInstance():getScheduler()
                local tempHandle = self.mRefreshHandle
                self.mRefreshHandle = nil
                tempScheduler:unscheduleScriptEntry(tempHandle)
            end
        elseif "enterTransitionFinish" == event then
            self:reloadData()

            self.mDelayCreatePreItemTime = 0
            --- 与加载定时器
            if not self.mRefreshHandle then
                local tempScheduler = cc.Director:getInstance():getScheduler()
                self.mRefreshHandle = tempScheduler:scheduleScriptFunc(function(delay)
                    self.mDelayCreatePreItemTime = self.mDelayCreatePreItemTime + delay
                    if self.mDelayCreatePreItemTime > 0.5 then
                        self.mDelayCreatePreItemTime = 0
                        self:createPreViewItem()
                    end
                end, 0.1, false)
            end
        elseif "exitTransitionStart" == event then
            -- Todo
        elseif "cleanup" == event then
            -- Todo
        end
    end)
end

-- 刷新列表中Item的信息
function SliderTableView:refreshItemInfo()
    self.mItemCount = self.itemCountOfSlider()
    -- 先删除原来的Item信息
    for index, item in pairs(self.mItemInfos) do
        if item.itemNode then
            item.itemNode:removeFromParent()
            item.itemNode = nil
        end
    end
    self.mItemInfos = {}
    if self.mItemCount == 0 then
        return
    end
    -- 重新计算列表中Item的位置和大小, 位置以AnchorPoint为（0, 0）向右下角延伸
    local tempWidth, tempHeight = self.itemSizeOfSlider(self, 0)
    local tempPosX, tempPosY = self.mWidth / 2, -self.mHeight / 2
    if self.mIsVertical then
        tempPosY =  -tempHeight / 2
    else
        tempPosX = tempWidth / 2
    end
    -- tempItem.pos: 记录在AnchorPoint为（0, 0）处的坐标
    -- tempItem.middlePos: 记录在AnchorPoint为（0.5, 0.5）处的坐标
    -- tempItem.endPos: 记录在AnchorPoint为（1, 1）处的坐标
    for index = 1, self.mItemCount do
        local tempItem = {}
        tempItem.width, tempItem.height = self.itemSizeOfSlider(self, index - 1)

        if index == 1 then
            tempItem.pos = cc.p(tempPosX - tempItem.width / 2, tempPosY - tempItem.height / 2)

            if self.mIsVertical then
                tempPosX = tempPosX - tempItem.width / 2
                tempPosY = tempPosY - tempItem.height / 2
            else
                tempPosX = tempPosX + tempItem.width / 2
                tempPosY = tempPosY - tempItem.height / 2
            end
        else
            if self.mIsVertical then
                tempItem.pos = cc.p(tempPosX, tempPosY - tempItem.height)
                tempPosY = tempPosY - tempItem.height
            else
                tempItem.pos = cc.p(tempPosX, tempPosY)
                tempPosX = tempPosX + tempItem.width
            end
        end

        tempItem.itemNode = nil
        table.insert(self.mItemInfos, tempItem)
    end
end

-- 获取显示的开始条目和结束条目的index
function SliderTableView:refrishViewIndex(containerNewPos)
    self.mViewBeginIndex = 0
    self.mViewEndIndex = 0
    local containerRect = cc.rect(0, 0, self.mWidth, self.mHeight)
    local beginPos = containerNewPos or cc.p(self.mContainerNode:getPosition())
    local function getItemRectInView(item)
        return cc.rect(beginPos.x + item.pos.x + 1, beginPos.y + item.pos.y + 1, item.width - 2, item.height - 2)
    end

    local function compareRect(item)
        local itemRect = getItemRectInView(item)
        if cc.rectIntersectsRect(itemRect, containerRect) then
            return 0
        else
            if containerRect.x > itemRect.x + itemRect.width or itemRect.y > containerRect.y + containerRect.height then
                return -1
            else
                return 1
            end
        end
    end
    -- 先用二分法找到一个在显示区域内的条目，然后从该条向两边查找起始条目
    local foundIndex = 0
    local left, right = 1, #self.mItemInfos
    local mid = math.floor((left + right) / 2)
    while (left <= right) do
        local compRet = compareRect(self.mItemInfos[mid])
        if compRet < 0 then
            left = mid + 1
        elseif compRet > 0 then
            right = mid - 1
        else
            foundIndex = mid
            break
        end
        if left == right then
            if compareRect(self.mItemInfos[left]) == 0 then
                foundIndex = left
            end
            break
        end
        mid = math.floor((left + right) / 2)
    end
    if foundIndex > 0 then
        for index = foundIndex, 1, -1 do
            local tempItem = self.mItemInfos[index]
            local tempRect = getItemRectInView(tempItem)
            if cc.rectIntersectsRect(tempRect, containerRect) then
                self.mViewBeginIndex = index
            else
                break
            end
        end
        for index = foundIndex, #self.mItemInfos do
            local tempItem = self.mItemInfos[index]
            local tempRect = getItemRectInView(tempItem)
            if cc.rectIntersectsRect(tempRect, containerRect) then
                self.mViewEndIndex = index
            else
                break
            end
        end
    end

    if self.mViewBeginIndex > self.mViewEndIndex then
        self.mViewEndIndex = self.mViewBeginIndex
    end
end

--- 设置显示Item的内容
--[[
-- 参数
    containerNewPos: 容器控件最新的位置
    refreshOldItem: 是否需要刷新原来的记录
 ]]
function SliderTableView:setViewItem(containerNewPos)
    self:refrishViewIndex(containerNewPos)
    if self.mViewBeginIndex < 1 or self.mViewEndIndex > #self.mItemInfos then
        print("SliderTableView:setViewItem invalid view index, so return", self.mViewBeginIndex, self.mViewEndIndex, #self.mItemInfos)
        return
    end

    for index = self.mViewBeginIndex, self.mViewEndIndex do
        local tempNode = self:getItemNode(index - 1)
        if tempNode:getChildrenCount() == 0 then
            self.sliderItemAtIndex(self, tempNode, index - 1, index == self.mSelectIndex)
        end
    end
end

--- 设置与加载Item的内容
function SliderTableView:setPreViewItem()
    if self.mViewBeginIndex < 1 or self.mViewEndIndex > #self.mItemInfos then
        print("SliderTableView:setPreViewItem invalid view index, so return", self.mViewBeginIndex, self.mViewEndIndex, #self.mItemInfos)
        return
    end

    if self.mTouchEnd then  -- 与加载一些页面，保证滑动时流畅
        self.mPreIndexList = {}

        local preLoadCount = math.ceil((self.mViewEndIndex - self.mViewBeginIndex + 1) * 1.5)
        local tempBegin = math.max(self.mViewBeginIndex - preLoadCount, 1)
        local tempEnd = math.min(self.mViewBeginIndex - 1, #self.mItemInfos)
        for index = tempBegin, tempEnd do
            table.insert(self.mPreIndexList, index)
        end
        tempBegin = math.max(self.mViewEndIndex + 1, 1)
        tempEnd = math.min(self.mViewEndIndex + preLoadCount, #self.mItemInfos)
        for index = tempBegin, tempEnd do
            table.insert(self.mPreIndexList, index)
        end

        -- 排序，优先创建离显示条目近的条目
        table.sort(self.mPreIndexList, function(item1, item2)
            local item1Abs = item1 < self.mViewBeginIndex and (self.mViewBeginIndex - item1) or (item1 - self.mViewEndIndex)
            local item2Abs = item2 < self.mViewBeginIndex and (self.mViewBeginIndex - item2) or (item2 - self.mViewEndIndex)

            return item1Abs < item2Abs
        end)
        self.mDelayCreatePreItemTime = 0
    end
end

--- 创建预加载条目
function SliderTableView:createPreViewItem()
    if self.mIsCreating then
        return
    end
    self.mIsCreating = true

    if self.mTouchEnd and self.mPreIndexList then
        local createCount = self.mViewEndIndex - self.mViewBeginIndex + 1
        local listCount = #self.mPreIndexList
        for i = 1, listCount do  -- 每个周期创建一屏显示内容
            if #self.mPreIndexList == 0 or createCount < 1 then
                break
            end
            local tempIndex = self.mPreIndexList[1]
            table.remove(self.mPreIndexList, 1)

            if tempIndex > 0 and tempIndex <= #self.mItemInfos then
                local tempNode = self:getItemNode(tempIndex - 1)
                local tempCount = tempNode:getChildrenCount()
                if tempCount == 0 then
                    createCount = createCount - 1
                    self.sliderItemAtIndex(self, tempNode, tempIndex - 1, tempIndex == self.mSelectIndex)
                end
            end
        end
    end
    self.mIsCreating = false
end

--- 设置容器控件的位置
--[[
-- 参数
    newPos: 容器控件的新位置
    needAction: 设置容器控件位置时是否需要action
    needCheckPos: 是否需要检测位置是否在显示范围内
 ]]
function SliderTableView:setContainerPos(newPos, needAction, needCheckPos, speed)
    if #self.mItemInfos == 0 then
        self.mContainerNode:setPosition(newPos)
        return
    end

    self.mContainerNode:stopAllActions()
    if needAction then
        if needCheckPos then
            local checkPos = self:checkNewPos(newPos)
            self:setViewItem(newPos)
            local array = nil
            if speed and speed ~= 0 then
                array = {
                    cc.EaseIn:create(cc.EaseQuadraticActionOut:create(cc.MoveTo:create(math.abs(speed * 0.006), newPos)), 0.5),
                    cc.CallFunc:create(function()
                        self:setViewItem(checkPos)
                    end),
                    cc.EaseIn:create(cc.MoveTo:create(0.3, checkPos), 0.5),
                    cc.CallFunc:create(function()
                        self:setPreViewItem()
                    end),
                }
            else
                array = {
                    cc.EaseIn:create(cc.MoveTo:create(0.3, newPos), 0.5),
                    cc.CallFunc:create(function()
                        self:setViewItem(checkPos)
                    end),
                    cc.EaseIn:create(cc.MoveTo:create(0.3, checkPos), 0.5),
                    cc.CallFunc:create(function()
                        self:setPreViewItem()
                    end),
                }
            end
            self.mContainerNode:runAction(cc.Sequence:create(array))
        else
            local moveAction
            if speed and speed ~= 0 then
                moveAction = cc.EaseIn:create(cc.EaseQuadraticActionOut:create(cc.MoveTo:create(math.abs(speed * 0.006), newPos)), 0.5)
            else
                moveAction = cc.EaseIn:create(cc.MoveTo:create(0.3, newPos), 0.5)
            end
            local array = {
                moveAction,
                cc.CallFunc:create(function()
                    self:setPreViewItem()
                end),
            }
            self.mContainerNode:runAction(cc.Sequence:create(array))
        end
    else
        if needCheckPos then
            local checkPos = self:checkNewPos(newPos)
            self:setViewItem(checkPos)
            self.mContainerNode:setPosition(checkPos)
        else
            self:setViewItem(newPos)
            self.mContainerNode:setPosition(newPos)
        end
        self:setPreViewItem()
    end
end

--- 检测容器控件的坐标，并返回正确的坐标
function SliderTableView:checkNewPos(pos)
    if #self.mItemInfos == 0 then
        -- 刷新列表中Item的信息
        self:refreshItemInfo()
        if #self.mItemInfos == 0 then
            print("SliderTableView:checkNewPos self.mItemInfos is empty, so return")
            return
        end
    end

    local retPos = pos
    if self.mSelItemOnMiddle then
        if #self.mItemInfos > 0 then
            if self.mSelectIndex < 1 then
                self.mSelectIndex = 1
            elseif self.mSelectIndex > #self.mItemInfos then
                self.mSelectIndex = #self.mItemInfos
            end

            local tempItem = self.mItemInfos[self.mSelectIndex]
            if self.mIsVertical then
                retPos.x = 0
                retPos.y = math.abs(tempItem.pos.y) - tempItem.height / 2 + self.mHeight / 2
            else
                retPos.x = -tempItem.pos.x + self.mWidth / 2 - tempItem.width / 2
                retPos.y = self.mHeight
            end
        end
    else
        local lastItem = self.mItemInfos[#self.mItemInfos]
        if self.mIsVertical then
            retPos.x = 0
            if retPos.y < self.mHeight or (math.abs(lastItem.pos.y) < self.mHeight) then
                retPos.y = self.mHeight
            elseif retPos.y > -lastItem.pos.y then
                retPos.y = -lastItem.pos.y
            end
        else
            if retPos.x > 0 or (lastItem.pos.x + lastItem.width < self.mWidth) then
                retPos.x = 0
            elseif retPos.x < -lastItem.pos.x + self.mWidth - lastItem.width then
                retPos.x = -lastItem.pos.x + self.mWidth - lastItem.width
            end
            retPos.y = self.mHeight
        end
    end
    return retPos
end

--- 更具滑动距离，设置当前选中的条目(当选中条目需要显示在中间时调用)
function SliderTableView:calculateSelectIndex(moveX, moveY)
    if #self.mItemInfos == 0 or not self.mSelItemOnMiddle  then
        print("不能滑动！！！")
        return
    end
    local oldSelectIndex = self.mSelectIndex
    if self.mSelectIndex < 1 then
        self.mSelectIndex = 1
    elseif self.mSelectIndex > #self.mItemInfos then
        self.mSelectIndex = #self.mItemInfos
    end

    -- 切换选择条目大滑动临界值
    local chgSelectWidth = math.min(math.max(self.mWidth / 6, 20), 100)
    if self.mIsVertical then
        local absDiff = math.abs(moveY)
        if moveY > 0 then  -- 向上滑动，显示的index越来越大
            for index = self.mSelectIndex, #self.mItemInfos - 1 do
                if absDiff < chgSelectWidth then
                    break
                end
                self.mSelectIndex = index + 1
                absDiff = absDiff - self.mItemInfos[index].height
            end
        else    -- 向下滑动，显示的index越来越小
            for index = self.mSelectIndex, 2, -1 do
                if absDiff < chgSelectWidth then
                    break
                end
                self.mSelectIndex = index - 1
                absDiff = absDiff - self.mItemInfos[index].height
            end
        end
    else
        print("左右滑动")
        local absDiff = math.abs(moveX)
        if moveX > 0 then -- 向右滑动，显示的index越来越小
            for index = self.mSelectIndex, 2, -1 do
                if absDiff < chgSelectWidth then
                    break
                end
                self.mSelectIndex = index - 1
                absDiff = absDiff - self.mItemInfos[index].width
            end
        else -- 向左滑动，显示的index越来越大
            for index = self.mSelectIndex, #self.mItemInfos - 1 do
                if absDiff < chgSelectWidth then
                    break
                end
                self.mSelectIndex = index + 1
                absDiff = absDiff - self.mItemInfos[index].width
            end
        end
    end
    if oldSelectIndex ~= self.mSelectIndex and self.selectItemChanged then
        local tempNode = self:getItemNode(self.mSelectIndex - 1)
        if tempNode:getChildrenCount() == 0 then
            self.sliderItemAtIndex(self, tempNode, self.mSelectIndex - 1, true)
        end
        self.selectItemChanged(self, self.mSelectIndex - 1)
    end
end

-- 获取当前被点击Item的Index
function SliderTableView:getTouchItemIndex(currPos)
    local tempPosX, tempPosY = self.mContainerNode:getPosition()
    local ret = 0

    for index = self.mViewBeginIndex, self.mViewEndIndex do
        local tempItem = self.mItemInfos[index]
        if tempItem then
            local tempRect = cc.rect(tempPosX + tempItem.pos.x, tempPosY + tempItem.pos.y, tempItem.width, tempItem.height)
            if (cc.rectContainsPoint(tempRect, currPos)) then
                ret = index
                break
            end
        end
    end
    return ret
end

-- 设置触控事件
function SliderTableView:setOnTouch()
    -- 创建触摸层
    local touchNode = cc.Layer:create()
    touchNode:setContentSize(cc.size(self.mWidth, self.mHeight))
    touchNode:setPosition(cc.p(0, 0))
    self:addChild(touchNode)

    --
    local start = {x = 0, y = 0 }
    local prev = {x = 0, y = 0 }
    local function touchBegin(touch, event)
        if (self.mItemCount <= 0 or not self.mTouchEnabled) then
            return false
        end
        --
        local currPos = touch:getLocation()
        local tempScaleX, tempScaleY = self:getScaleX(), self:getScaleY()
        local nodePos = self:convertToNodeSpace(currPos);
        local tempRect = cc.rect(0, 0, self.mWidth * tempScaleX, self.mHeight * tempScaleY)
        if (not cc.rectContainsPoint(tempRect, nodePos)) then
            return false
        end

        start.x, start.y = currPos.x, currPos.y
        prev.x, prev.y = currPos.x, currPos.y
        self.mTouchEnd = false

        if self.onTouchBegin then
            self.onTouchBegin(self, touch, event)
        end

        return true
    end
    local posXVec = {}
    local function touchMoved(touch, event)
        local tempPosX, tempPosY = self.mContainerNode:getPosition()
        -- 先检测是否以滑出了边界
        local lastItem = self.mItemInfos[#self.mItemInfos]
        if self.mIsVertical then
            if tempPosY < (self.mHeight - 100) or tempPosY > (100 -lastItem.pos.y) then
                return
            end
        else
            if tempPosX > 100 or tempPosX < -lastItem.pos.x + self.mWidth - lastItem.width - 100 then
                return
            end
        end

        local currPos = touch:getLocation()
        local diffX = not self.mIsVertical and (currPos.x - prev.x) or 0
        local diffY = self.mIsVertical and (currPos.y - prev.y) or 0
        prev.x, prev.y = currPos.x, currPos.y
        self:setContainerPos(cc.p(tempPosX + diffX * touchScale, tempPosY + diffY * touchScale), false, false)

        if #posXVec == 0 then
            table.insert(posXVec, cc.p(self.mContainerNode:getPosition()))
            table.insert(posXVec, cc.p(self.mContainerNode:getPosition()))
        else
            table.remove(posXVec, 1)
            table.insert(posXVec, cc.p(self.mContainerNode:getPosition()))
        end
    end
    local function touchEnd(touch, event)
        self.mTouchEnd = true
        if self.mNeedInertia then
            posXVec[1] = posXVec[1] or cc.p(self.mContainerNode:getPosition())
            posXVec[2] = cc.p(self.mContainerNode:getPosition())
        else
            posXVec[1] = cc.p(self.mContainerNode:getPosition())
            posXVec[2] = cc.p(self.mContainerNode:getPosition())
        end

        local diffX, diffY = 0, 0
        local speed = cc.p(0, 0)
        local currPos = touch:getLocation()
        if self.mIsVertical then
            diffY = currPos.y - start.y
            speed = cc.p(0, posXVec[2].y - posXVec[1].y)
        else
            diffX = currPos.x - start.x
            speed = cc.p(posXVec[2].x - posXVec[1].x, 0)
        end
        posXVec = {}

        local extralScale = 0.3

        self:calculateSelectIndex(diffX + speed.x * 6, diffY + speed.y * 6)
        local tempPosX, tempPosY = self.mContainerNode:getPosition()
        local tempSpeed = math.max(self.mIsVertical and speed.y or speed.x, 50)
        self:setContainerPos(cc.p(tempPosX + speed.x * 6, tempPosY + speed.y * 6), true, true, tempSpeed)
        if self.onItemClecked then
            local distance = math.sqrt(math.pow(currPos.x - start.x, 2) + math.pow(currPos.y - start.y, 2))
            if distance < 20 then
                -- 获取当前被点击Item的Index
                local tempIndex = self:getTouchItemIndex(self:convertToNodeSpace(currPos))
                print("被点击的条目 index  ", tempIndex)
                if tempIndex > 0 then
                    self.onItemClecked(self, tempIndex - 1)
                end
            end
        end

        if self.onTouchEnd then
            self.onTouchEnd(self, touch, event)
        end
    end

    local tempListener = cc.EventListenerTouchOneByOne:create()
    tempListener:setSwallowTouches(false)
    tempListener:registerScriptHandler(touchBegin, cc.Handler.EVENT_TOUCH_BEGAN )
    tempListener:registerScriptHandler(touchMoved, cc.Handler.EVENT_TOUCH_MOVED )
    tempListener:registerScriptHandler(touchEnd, cc.Handler.EVENT_TOUCH_ENDED )

    local eventDispatcher = touchNode:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(tempListener, touchNode)
end

--- ======================= 公共接口 ===========================
--- 重新加载
function SliderTableView:reloadData()
    print("SliderTableView:reloadData")
    -- 刷新列表中Item的信息
    self:refreshItemInfo()
    if #self.mItemInfos == 0 then
        print("SliderTableView:reloadData self.mItemInfos is empty, so return")
        return
    end
    -- 设置显示Item的内容
    self.mContainerNode:stopAllActions()
    self:setContainerPos(cc.p(self.mContainerNode:getPosition()), false, true)

--    local checkPos = self:checkNewPos(cc.p(self.mContainerNode:getPosition()))
--    self:setViewItem(checkPos)
--    self.mContainerNode:setPosition(checkPos)
end

--- 刷新某条记录
function SliderTableView:refreshItem(itemIndex)
    print("SliderTableView:refreshItem index:", itemIndex)
    if itemIndex < 0 or itemIndex >= #self.mItemInfos then
        return
    end
    local tempNode = self:getItemNode(itemIndex)
    if not tempNode then
        return
    end
    if tempNode:getChildrenCount() > 0 then
        tempNode:removeAllChildren()
    end

    local tempIndex = itemIndex + 1
    if tempIndex >= self.mViewBeginIndex and tempIndex <= self.mViewEndIndex then
        self.sliderItemAtIndex(self, tempNode, itemIndex, tempIndex == self.mSelectIndex)
    else
        if not self.mPreIndexList then
            self.mPreIndexList = {}
        end
        table.insert(self.mPreIndexList, tempIndex)
        self.mDelayCreatePreItemTime = 0
    end
end

--- 获取选中纪录的Index
function SliderTableView:getSelectItemIndex()
    return self.mSelectIndex - 1
end

--- 设置选中纪录的Index
function SliderTableView:setSelectItemIndex(index, needAction)
    local oldSelectIndex = self.mSelectIndex
    self.mSelectIndex = index + 1
    if self.mSelItemOnMiddle then
        -- 设置显示Item的内容
        print("====设置在中间====")
        self:setContainerPos(cc.p(self.mContainerNode:getPosition()), needAction, true)
    end

    if oldSelectIndex ~= self.mSelectIndex then
        -- 刷新原来选中条目的状态
        if oldSelectIndex > 0 and oldSelectIndex <= #self.mItemInfos then
            print("====刷新原来====")
            local tempNode = self:getItemNode(oldSelectIndex - 1)
            if tempNode:getChildrenCount() ~= 0 and self.mNeedRefreshSelectChangedItem then
                self:refreshItem(oldSelectIndex - 1)
            end
        end

        -- 刷新当前选中条目的状态
        if self.mSelectIndex > 0 and self.mSelectIndex <= #self.mItemInfos then
            print("====刷新当前====")
            local tempNode = self:getItemNode(self.mSelectIndex - 1)
            if tempNode:getChildrenCount() ~= 0 and self.mNeedRefreshSelectChangedItem then
                tempNode:removeAllChildren()
                self.sliderItemAtIndex(self, tempNode, self.mSelectIndex - 1, true)
            end
        end
    end

    if self.selectItemChanged then
        self.selectItemChanged(self, index)
    end
end

--- 获取当前显示内容的偏移位置
function SliderTableView:getContentOffset()
    local tempPosX, tempPosY = self.mContainerNode:getPosition()
    return cc.p(tempPosX, tempPosY)
end

--- 设置当前显示内容的偏移位置
function SliderTableView:setContentOffset(offset)
    self:setContainerPos(offset, false, true)
end

--- 设置当前显示内容为第一条
function SliderTableView:minContainerOffset()
    self:setContainerPos(cc.p(0, self.mHeight), false, true)
end

--- 获取当前选择条目的node
--[[
-- 参数
    itemIndex：条目的index，下标从 0 开始
 ]]
function SliderTableView:getItemNode(itemIndex)
    local tempIndex = itemIndex + 1
    if tempIndex < 1 or tempIndex > #self.mItemInfos then
        print("SliderTableView:getItemNode invalid itemIndex:", itemIndex)
        return
    end
    local itemInfo = self.mItemInfos[tempIndex]
    local tempNode = itemInfo.itemNode
    if not tempNode then
        tempNode = ccui.Layout:create()
        tempNode:setPosition(itemInfo.pos)
        tempNode:setContentSize(cc.p(itemInfo.width, itemInfo.height))
        self.mContainerNode:addChild(tempNode)
        itemInfo.itemNode = tempNode
    else
        tempNode:setPosition(itemInfo.pos)
    end
    return tempNode
end

---
function SliderTableView:setTouchEnabled(enabled)
    self.mTouchEnabled = enabled
end

return SliderTableView