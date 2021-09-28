local ArenaScrollView = class("ArenaScrollView")
local ArenaScrollViewItem = require("app.scenes.arena.ArenaScrollViewItem")

local ITEM_HEIGHT = 190

function ArenaScrollView:ctor(_scrollview,listData,layer)
    --是否第一次进入,用于刷新
    self._isFirstTime = true
    
    self._lisData = self:_cloneTable(listData)
    self._scrollview = _scrollview
    self._layer = layer
    self._height = _scrollview:getContentSize().height
    if listData == nil then
        self._dataLength = 10
    else
        self._dataLength = #listData < 10 and 10 or #listData
    end
    self._startY = 0
    self._itemViewList = {}
    self._innerContainer = self._scrollview:getInnerContainer()
    self._currentIndex = 1 
    self:initChilds()
    self._layer:registerScrollViewEvent(_scrollview:getName(),handler(self,self.onScrollViewEvent))
end

function ArenaScrollView:getCellCount()
    local count = self:getShowCellCount()
    return count + 2
end



function ArenaScrollView:initChilds()
    local count = self:getShowCellCount()
    local size = self._scrollview:getContentSize()
    self._scrollview:setInnerContainerSize(CCSize(size.width,(self._dataLength+1)*ITEM_HEIGHT))
    local posY = self._innerContainer:getPositionY()
    local index = 1
    --从顶部开始加,坑啊
    local innerContainerTopLeftY = self._innerContainer:getContentSize().height
    for i=1,self:getCellCount() do 
        -- local isLeft = (index%2==0)
        local isLeft = index
        local child = ArenaScrollViewItem.new(isLeft,self._layer)
        index = index + 1 
        table.insert(self._itemViewList,child)
        child:setPosition(ccp(0,innerContainerTopLeftY - (i-2)*ITEM_HEIGHT))
        self._scrollview:addChild(child)
    end

end

function ArenaScrollView:update(listData,myIndex)
    self._lisData = self:_cloneTable(listData)

    self._dataLength = #listData < 10 and 10 or #listData
    self._scrollview:setInnerContainerSize(CCSize(self._scrollview:getContentSize().width,(self._dataLength+1)*ITEM_HEIGHT))
    local innerContainerTopLeftY = self._innerContainer:getContentSize().height
    if self._isFirstTime == true then    ----第一次进入
        self._isFirstTime = false
        --小于第8名的时候,尾部不止2人
        if myIndex <8 then
            local size = CCDirector:sharedDirector():getWinSize()
            
            local myPosY = self._height - ITEM_HEIGHT*(myIndex+1)
            if myPosY >= 0 then
                self._currentIndex = self._currentIndex - 2
             end

            for i,v in ipairs(self._itemViewList) do
                v:updateItem(v:isLeft(),self._lisData[i-1+self._currentIndex-1],i)
                v:setPosition(ccp(0,innerContainerTopLeftY - (i+self._currentIndex)*ITEM_HEIGHT))
            end
            self._innerContainer:setPosition(ccp(0,self._height - innerContainerTopLeftY))
            if myPosY < 0 then
                self:scrollToIndex(myIndex)
            else
                self:setScrollEnable(true)
            end
        else
            self._currentIndex = myIndex - self:getShowCellCount() + 1
            --[[
                差值 * ITEM_HEIGHT
            ]]
            self._innerContainer:setPosition(ccp(0,(myIndex-#self._lisData)*ITEM_HEIGHT))
            for i,v in ipairs(self._itemViewList) do
                v:updateItem(v:isLeft(),self._lisData[i+self._currentIndex-1-1],0)
                v:setPosition(ccp(0,innerContainerTopLeftY - (i+self._currentIndex)*ITEM_HEIGHT))
            end
            self:setScrollEnable(true)
        end
        self._layer:playAnimation()
        -- self:setScrollEnable(true)
    else
        local showCount = self:getShowCellCount()
        if myIndex < 10 then
            --判断是否需要滑动,有时候在屏幕内则不需要滑动
            if myIndex < showCount - 1 then
                -- self._currentIndex = 
                --从第一个开始刷
                for i,v in ipairs(self._itemViewList) do
                    v:updateItem(v:isLeft(),self._lisData[i-1+self._currentIndex-1],i)
                    v:setPosition(ccp(0,innerContainerTopLeftY - (i+self._currentIndex)*ITEM_HEIGHT))
                end
                self._innerContainer:setPosition(ccp(0,self._height - innerContainerTopLeftY))
            else
                --差值
                local diff = self._dataLength - myIndex
                for i,v in ipairs(self._itemViewList) do
                    v:updateItem(v:isLeft(),self._lisData[myIndex- showCount + i-1] ,i)
                    --往下滑
                    v:setPosition(ccp(0,(#self._itemViewList-i+diff-1-1)*ITEM_HEIGHT))
                end
                -- for i,v in ipairs(self._itemViewList) do
                -- end
                --底部要保留一个
                self._currentIndex = myIndex - self:getShowCellCount()+1
                self._innerContainer:setPosition(ccp(0,-(diff)*ITEM_HEIGHT))
            end 
        else
            --新手引导时
            if self:_isLast() then
                local bottomView = self._itemViewList[#self._itemViewList]
                table.remove(self._itemViewList,#self._itemViewList)
                table.insert(self._itemViewList,1,bottomView)

                for i,v in ipairs(self._itemViewList) do
                    local updateIndex = myIndex - showCount + i-1
                    v:updateItem(v:isLeft(),self._lisData[updateIndex-1] ,0)
                    v:setPosition(ccp(0,(#self._itemViewList-i-1+1-1)*ITEM_HEIGHT))
                end
                self._currentIndex = myIndex - self:getShowCellCount()
                self._innerContainer:setPosition(ccp(0,0))

            else
                for i,v in ipairs(self._itemViewList) do
                    local updateIndex = myIndex - showCount + i-1
                    v:updateItem(v:isLeft(),self._lisData[updateIndex] , i)
                    v:setPosition(ccp(0,(#self._itemViewList-i-1+2-1)*ITEM_HEIGHT))
                end
                self._currentIndex = myIndex - self:getShowCellCount()+1
                self._innerContainer:setPosition(ccp(0,-ITEM_HEIGHT*2))
            end
            --这个不需要自己去控制
        end
    end

    self:addTimer()

    self:_showKnightDialog()
end

--[[
    判断自己是否为最后一名
]]
function ArenaScrollView:_isLast()
    local user = self._lisData[#self._lisData]
    return user ~= nil and user.user_id == G_Me.userData.id
end

function ArenaScrollView:_cloneTable(_t)
    if _t == nil or type(_t) ~= "table" then
        return nil
    end
    local t = {}
    for i,v in ipairs(_t) do
        table.insert(t,clone(v))
    end
    return t
end


--刷新顶部的
function ArenaScrollView:updateTop()

    local isLeft = self._itemViewList[2]:isLeft()
    local lastZOrder = self._itemViewList[2]:getZOrder()
    local start = self:getShowStart()
    self._itemViewList[1]:updateItem(isLeft-1,self._lisData[start-1],lastZOrder-1)
end

--刷新底部的
function ArenaScrollView:updateBottom()
    local isLeft = self._itemViewList[#self._itemViewList-1]:isLeft()
    local lastZOrder = self._itemViewList[#self._itemViewList-1]:getZOrder()
    local _end = self:getShowEnd()
    if self._lisData ~= nil and self._lisData[_end] ~= nil then
        self._itemViewList[#self._itemViewList]:updateItem(isLeft+1,self._lisData[_end],lastZOrder+1)
    end
end

function ArenaScrollView:getShowCellCount()
    if self._scrollview == nil then return 0 end
    local height = self._scrollview:getContentSize().height
    return math.ceil(height/ITEM_HEIGHT)
end

--第一个
function ArenaScrollView:getShowStart()
    return self._currentIndex
end

--最后一个
function ArenaScrollView:getShowEnd()
    return self._currentIndex + #self._itemViewList - 1 - 1
end

function ArenaScrollView:getLastPosY()
    local last = self._itemViewList[#self._itemViewList]
    return last:convertToWorldSpace(ccp(0,0)).y
end

function ArenaScrollView:getFirstPosY()
    local first = self._itemViewList[1]
    return first:convertToWorldSpace(ccp(0,0)).y
end

function ArenaScrollView:onScrollViewEvent(widget,_type)
    local posY = self._scrollview:getInnerContainer():getPositionY()
    if _type == SCROLLVIEW_EVENT_SCROLL_TO_TOP then
    elseif _type == SCROLLVIEW_EVENT_SCROLL_TO_BOTTOM then
    elseif _type == SCROLLVIEW_EVENT_SCROLLING then
    	if self._startY - posY < 0 then
            --网上滑了
            self:checkWillScrollToBottom()
    	else
            self:checkWillScrollToTop()
    	end
    	self._startY = posY
    elseif _type == SCROLLVIEW_EVENT_SCROLL_STOP then
    	if self._autoScroll == true then
            self:getKnightRectForNewGuide()
            self._autoScroll = false
            if not self._isFirstTime == true then
                G_HandlersManager.arenaHandler:sendGetArenaInfo()
            else
                self._isFirstTime = false
                self._layer:playAnimation()
            end
            self:setScrollEnable(true)
    	end

    end

end

function ArenaScrollView:setScrollEnable(enable)
    if self and self._layer then
        self._layer:setTouchEnabled(enable)
    end
end

--检查是否滑到顶部了,大概还差20个像素的时候就开始load了
function ArenaScrollView:checkWillScrollToTop()
    local firstPosY = self:getFirstPosY()
    if firstPosY <= self._height - 130 then
        self._currentIndex = self._currentIndex - 1
        local bottomView = self._itemViewList[#self._itemViewList]
        table.remove(self._itemViewList,#self._itemViewList)
        table.insert(self._itemViewList,1,bottomView)
        local point = self._innerContainer:convertToNodeSpace(ccp(0,firstPosY+ITEM_HEIGHT))
        bottomView:setPosition(point)
        self:updateTop()
    end
end

function ArenaScrollView:checkWillScrollToBottom()
    local lastPosY = self:getLastPosY()
    -- if lastPosY >= -ITEM_HEIGHT + 130 then
    if lastPosY >= -ITEM_HEIGHT + 30 then
        self._currentIndex = self._currentIndex + 1
        local top = self._itemViewList[1]
        table.remove(self._itemViewList,1)
        table.insert(self._itemViewList,top)
        local point = self._innerContainer:convertToNodeSpace(ccp(0,lastPosY-ITEM_HEIGHT))
        top:setPosition(point)
        self:updateBottom()
    end
end

function ArenaScrollView:getInnerContainerPositionY()
    return self._innerContainer:getPositionY()
end

function ArenaScrollView:setInnerContainerPositionY(posY)
    if posY == nil or type(posY) ~= "number" then
        posY = 0
    end
    self._innerContainer:setPosition(ccp(0,posY))
end

function ArenaScrollView:scrollToIndex(_index)
    self._autoScroll = true
    self:setScrollEnable(false)
    local innerContainerTopLeftY = self._innerContainer:getContentSize().height
    local scrollAreaHeight = innerContainerTopLeftY - self._height
    local myPosY = ITEM_HEIGHT*(_index+1) - self._height
    local point = self._innerContainer:convertToWorldSpace(ccp(0,myPosY))

    -- local scrollTime = point.y/self._height * 1
    local scrollTime = 2
    local percent = myPosY/scrollAreaHeight
    local currentPercent = self:_getCurrentScrollPercent()
    local diffPercert = math.abs(percent-currentPercent)
    -- self._scrollview:scrollToPercentVertical(percent*100,scrollTime>1 and 1 or scrollTime,false)
    self._scrollview:scrollToPercentVertical(percent*100,diffPercert*scrollTime > 1 and 1 or diffPercert*scrollTime,false)
end

--获取当前scrollview的滑动百分比
function ArenaScrollView:_getCurrentScrollPercent()
    local posY = self._innerContainer:getPositionY()
    local innerContainerTopLeftY = self._innerContainer:getContentSize().height
    local scrollAreaHeight = innerContainerTopLeftY - self._height
    return math.abs(1-posY/scrollAreaHeight)
end

function ArenaScrollView:destory( ... )
    for i,v in ipairs(self._itemViewList) do
        if v ~= nil then
            self._scrollview:removeChild(v)
        end
    end
end

--播放特效
function ArenaScrollView:playEffect(_index01,_index02)
    self:setScrollEnable(false)
    --名次交换
    if self._lisData[_index01] ~= nil and self._lisData[_index02] ~= nil then
        local rank = self._lisData[_index01].rank
        self._lisData[_index01].rank = self._lisData[_index02].rank
        self._lisData[_index02].rank = rank
    else
        return
    end

    if self._itemViewList[_index01-self._currentIndex+2] ~= nil then
        self._itemViewList[_index01-self._currentIndex+2]:playEffect(self._lisData[_index02],self._lisData[_index01])
    end
    
    if self._itemViewList[_index02-self._currentIndex+2] ~= nil then
        self._itemViewList[_index02-self._currentIndex+2]:playEffect(self._lisData[_index01],self._lisData[_index02])
    end
end

-- 播放挑战失败特效
function ArenaScrollView:playLoseEffect( _index01,_index02 )
    -- self:setScrollEnable(false)
    -- if self._itemViewList[_index01-self._currentIndex+2] ~= nil then
    --     self._itemViewList[_index01-self._currentIndex+2]:playLoseEffect(self._lisData[_index02],self._lisData[_index01])
    -- end
    
    if self._itemViewList[_index02-self._currentIndex+2] ~= nil then
        self._itemViewList[_index02-self._currentIndex+2]:playLoseEffect(self._lisData[_index01],self._lisData[_index02])
    end
end

--[[
    获取特定的本地名次武将的 矩形,
    用于新手引导，不可能会出现前10名的情形
    故可以默认从最后一名开始算
]]

function ArenaScrollView:getKnightRectForNewGuide()
    -- if self._lisData == nil or #self._lisData == 0 or self._itemViewList == nil or #self._itemViewList == 0 then
    --     return CCRectMake(0,0,0,0)
    -- end
    -- local item = self._itemViewList[#self._itemViewList-1]
    -- if item == nil then
    --     return CCRectMake(0,0,0,0)
    -- end
    -- return item:getKnightRect()
    for i,v in ipairs(self._itemViewList)do
        if v:isMe() then
            --上一个
            if i == 1 then
                return CCRectMake(0,0,0,0)
            end
            local item = self._itemViewList[i-1]
            return item:getKnightRect()
        end 
    end
    return CCRectMake(0,0,0,0)
    -- return CCRectMake(0,298,200,200)
end

-- 展示垃圾话
-- 1. 获取当前处于可见的玩家
-- 2. 从中随机选一个展示对话
-- 3. 3秒后隐藏对话，再走1
function ArenaScrollView:_showKnightDialog( ... )
    math.randomseed(os.time())
    local index = math.random(3, #self._itemViewList - 1)
    item = self._itemViewList[index]

    if item and item:getUser() == nil then
        return
    end

    -- 避免同一个人连续出现气泡
    if self._preItem and self._preItem:getUser() == item:getUser() then
        -- self._preItem:hideTrashTalkDialog()
        return
    end 

    local myRank = self._layer:getMyRank()
    -- local userRank = rankList[index]
    local userRank = item:getUser().rank

    self._trashDialogRank = userRank

    if self._preItem then
        self._preItem:hideTrashTalkDialog()
    end

    if userRank ~= myRank then
        item:showTrashTalkDialog(userRank < myRank)
    end

    self._preItem = item

end

function ArenaScrollView:getTrashDialogRank( ... )
    return self._trashDialogRank
end

function ArenaScrollView:addTimer( ... )
    if self._timer == nil then
        self._timer = G_GlobalFunc.addTimer(6, function()
            if self and self._trashDialogRank then
                self:_showKnightDialog()
            end
        end)
    end
end

function ArenaScrollView:removeTimer( ... )
    if self._timer then
        GlobalFunc.removeTimer(self._timer)
        self._timer = nil
    end
end

return ArenaScrollView