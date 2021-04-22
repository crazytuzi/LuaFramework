--[[
说明
    实现原理：
        通过 回调函数 renderItemCallBack 获取 listview 的 item 信息(大小 标记（用于多种widget支持）)
        回收超过边界的node节点 通过getItemFromCache 函数 获取已回收的节点重复利用（注意 重复利用是 item里面的一些状态需要重置）

    local cfg = {
        renderItemCallBack = function( list, index, info )
            local isCacheNode = true
            local item = list:getItemFromCache()
            if not item then
                item = QUIWidgetChooseServerItem.new()
                
                isCacheNode = false
            end
            -- 渲染代码
            item:setInfo()
            --回传的参数
            info.item = item
            info.size = item:getContentSize()

            --注册controll btn 事件  index 索引 btnChooseServer ccbowner名字  _onTriggerChoose 点击回调函数 也可以用 function end
            list:registerBtnHandler(index,"btnChooseServer", "_onTriggerChoose" )
            --或者可以自定义回调函数  list:registerClickHandler

            return isCacheNode
        end,
        multiItems = 2,
        spaceY = 3,
        spaceX = 4,
        totalNumber = #self._loginHistory,
    }
    -- self._ccbOwner.historyListParent --layer
    self._loginHistoryList = QListView.new(self._ccbOwner.historyListParent,cfg)
    
    --其他 常用 可选参数
    headIndex  3  listview 最顶上 指定到相对应的index item 
    tailIndex  10 以index = 10 在 listview 底部
    isVertical true 垂直滑动 false 水平滑动
    enableShadow 控制阴影（topShadow bottomShadow leftShadow rightShadow 自定义阴影） 
    ignoreCanDrag 当items的整体高度小于widgets高度 可以滑动
    scrollEndCallBack 滑动到底部 回调函数
    scrollBeginCallBack 滑动到头部 回调函数
    scrollMogveinggCallback 滑动过程中 回调函数
    curOffset 滑动区域 底部留空 
    curOriginOffset 滑动区域 头部留空
    spaceY y方向间距
    spaceX x方向间距
    autoCenter 当不能滑动时 并且ignoreCanDrag = false时 自动居中 水平模式下生效
    scrollDelegate 滚动代理 
    contentOffsetX or 0  --content x偏移量
    contentOffsetY or 0  --content y偏移量


    -- 常用函数
    function QListView:getCurTouchIndex(  ) --获取当前触摸到得index
    function QListView:getItemByIndex( index )  --获取指定索引的 item
    function QListView:reload( param )   --reload数据 
    function QListView:refreshData( )  -- 刷新数据 必须保证 数据的值 不会影响 item 大小  没变 否则 可能已发 bug
    function QListView:startScrollToIndex( index, isTail,speed, callback) -- 滚动到指定索引  index 指定的索引   isTail index结尾 还是开头   speed 滚动速度 默认 20
    function QListView:startScrollToPosScheduler(distance,time,isRollBack, callback, isCanNotTouchStop)  --滚动一段距离 distance 滚动距离  time 滚动时间  isRollBack 是否是回滚 callback 回调 isCanNotTouchStop 是否可以触摸中断
    
    -- 触摸的相关函数 
    --注册 必须是 control button 对象  详细可以参考 QUIDialogActivityPanel 里面有类似实现
    --index item索引   
    --touchNodeName control button 对象 ccbOwner名字 
    --clickHandler 回调函数
    --priority 优先级
    function QListView:registerBtnHandler(index, touchNodeName, clickHandler,priority) 

    --注册自定义函数
    --index item索引   详细可以参考 QUIDialogActivityTurntableRank 里面有类似实现
    --touchNodeName 当没有指定touchNode 时 回去获取item._ccbOwner[touchNodeName] 做为触摸事件触发者  当为item._ccbOwner[touchNodeName] 为nil 时 item 对象为事件触发者
    -- doPressInHandler 按下的回调函数
    -- doCancelPressInHandler 取消按下回调函数
    -- doClickInHandler click事件
    -- doLongPressInHandler 长按事件 
    -- priority 触摸优先级
    -- touchNode 自定义触摸node
    function QListView:registerClickHandler( index, touchNodeName, doPressInHandler, doCancelPressInHandler, doClickInHandler, doLongPressInHandler,priority,touchNode)

    --注册itembox tips显示 详细可以参考 QUIWidgetActivityExchange 里面有类似实现
    -- itemBoxIndex 在item 里面的标号
    -- itemBox 对象
    -- priority 触摸优先级
    -- customHander 自定义触发函数
    function QListView:registerItemBoxPrompt( index, itemBoxIndex,itemBox,priority, customHander)

    --注册touch 事件函数 显示 详细可以参考 QUIWidgetActivityExchange 里面有类似实现
    function QListView:registerTouchHandler( index, touchHandler )

    -- 关于多种widget的支持
    -- renderItemCallBack 回调函数中使用  从缓存中 获取node
    需要在renderItemCallBack 里面提供 tag info.tag = xxx 然后在getItemFromCache（tag）
    function QListView:getItemFromCache( tag )
    详细可以参考 QUIWidgetSocietyUnionLog 里面有类似实现
        

]]

local QListView = class("QListView",function(layer)
    -- body
    return layer
    
end)

local QVerticalListViewImp = {}
local QHorizontalListViewImp = {}

QListView.GESTURE_V = 0
QListView.GESTURE_H = 1

function QListView:ctor( layer,options )
    -- print("QListView ctor xxxxx1111")
    if not options then
        -- print("options is nil")
        options = {}
        -- return
    end
    local isSwallow = options.isSwallow 
    self._renderItemCallBack = options.renderItemCallBack
    self._isVertical = options.isVertical 
    self._cacheCond = options.cacheCond or 0.5
    self._headIndex = options.headIndex          --当前视口的起始索引
    self._tailIndex = options.tailIndex         --当前视口的结束索引
    self._maxItemNum = options.maxItemNum
    self._multiItems = options.multiItems or 1   -- 一行有2个或者多个
    self._totalNumber = options.totalNumber or 0
    -- self._scrollToIndexCallBack = options.scrollToIndexCallBack
    self._enableShadow = options.enableShadow
    self._topShadow = options.topShadow
    self._bottomShadow = options.bottomShadow 
    self._leftShadow = options.leftShadow
    self._rightShadow = options.rightShadow
    self._shadowIsNode = options.shadowIsNode or false
   

    self._spaceY = options.spaceY or 0
    self._spaceX = options.spaceX or 0
    self._curOffset =  options.curOffset or 0
    self._curOriginOffset = options.curOriginOffset or 0
    self._enableScrollBar = options.enableScrollBar 
    self._scrollBarParentNode = options.scrollBarParentNode 
    self._scrollBar = options.scrollBar
    self._scrollBarPos =  options.scrollBarPos or ccp(0,0)
    self._ignoreCanDrag = options.ignoreCanDrag
    self._autoCenter = options.autoCenter
    self._autoCenterOffset = options.autoCenterOffset
    self._scrollDelegate = options.scrollDelegate
    self._endRate = options.endRate or 0.2
    self._headIndexPosOffset = options.headIndexPosOffset or 0  --只支持 垂直 水平的暂时没有添加该功能
    self._contentOffsetX = options.contentOffsetX or 0  --content x偏移量
    self._contentOffsetY = options.contentOffsetY or 0  --content y偏移量

    self._scrollEndCallBack = options.scrollEndCallBack
    self._scrollBeginCallBack = options.scrollBeginCallBack
    self._scrollMogveinggCallback = options.scrollMogveinggCallback

    self._shadowSize = 8 -- 如果上下滑動，則為高度。如果是左右滑動，則為寬度
   
    if self._isVertical == nil then
        self._isVertical = true
    end

    if self._enableShadow == nil then
        self._enableShadow = false
    end

    if self._enableScrollBar == nil then
        self._enableScrollBar = false
    end

    if isSwallow == nil then
        isSwallow = true
    end
    --当要设置 起始index 或者 结束index 时 cacheCond >1 否则当 index 等于最后一个的时候  可能导致不能滑动
    -- if (self._headIndex or self._tailIndex) and self._cacheCond < 1 then
    --     self._cacheCond = 1
    -- end

    if self._maxItemNum and self._totalNumber and self._maxItemNum < self._totalNumber then
        printInfo("----error  self._maxItemNum < self._totalNumber ")
        self._totalNumber = self._maxItemNum
    end
    self._baseStartIndex =  options.baseStartIndex or 1
    self._baseEndIndex = self._baseStartIndex + self._totalNumber -1
    if self._multiItems ~=1 and self._baseStartIndex % self._multiItems ~= 1 then
        self._baseStartIndex = self._baseStartIndex - (self._baseStartIndex -1)%self._multiItems + self._multiItem
        -- return
    end

    -- self._startIndex = nil       --当前视口 加上 缓存高度或则宽度的索引  
    -- self._endIndex = nil
    self._cacheNodes = {}
    self._itemsInfo = {}
    self._touchInfos = {}
    self._touchHandlers = {}
    self._touchPriority = {}
    self._startIndex = 1
    self._endIndex = 1

    if self._isVertical then
        self._curOffset = self._curOffset - self._spaceY
        self._listViewImp = QVerticalListViewImp
    else
        self._curOffset = self._curOffset - self._spaceX
        self._listViewImp = QHorizontalListViewImp
    end

    -- body
    local size = self:getContentSize()
    self._width = size.width
    self._height = size.height
    local pos 
    if tolua.cast(self,"CCLayer") then
        -- print("--------------CCLayer---")
       pos = self:convertToWorldSpace(ccp(0,0))
    else
       pos = self:convertToWorldSpaceAR(ccp(0,0))
    end
    self._rect = CCRectMake(0,0,self._width,self._height)
    self._touchBoundingBox = CCRectMake(pos.x,pos.y,self._width,self._height)
    -- print(string.format("rect x %d  y %d  width %d  height %d",pos.x,pos.y,self._width,self._height))
  
    --创建剪裁节点
    self._stencilLayer = CCLayerColor:create(ccc4(0, 0, 0, 150), self._width, self._height)
    local ccclippingNode = CCClippingNode:create(self._stencilLayer)
    self:addChild(ccclippingNode)
    -- ccclippingNode:setStencil(stencilLayer)
    self._baseRootNode = CCNode:create()
    ccclippingNode:addChild(self._baseRootNode)
    self._content = CCNode:create()
    self._content:setTouchCaptureEnabled(false)
    self._baseRootNode:addChild(self._content)
   
     -- 注册事件
    self._touchLayer = CCLayer:create()
    self:addChild(self._touchLayer)
    self._touchLayer:setCascadeBoundingBox(self._touchBoundingBox)
    self._touchLayer:setTouchEnabled(true)
    self._touchLayer:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self._touchLayer:setTouchSwallowEnabled(isSwallow)
    self._touchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QListView.onTouch))
    --
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, QListView.onFrame))
    self:scheduleUpdate()

    self._listViewImp.initListView(self)
end
--[[
    对外接口

]]

function QListView:resetTouchRect()
    local size = self:getContentSize()
    self._width = size.width
    self._height = size.height
    self._rect = CCRectMake(0,0,self._width,self._height)
    local pos 
    if tolua.cast(self,"CCLayer") then
        -- print("--------------CCLayer---")
       pos = self:convertToWorldSpace(ccp(0,0))
    else
       pos = self:convertToWorldSpaceAR(ccp(0,0))
    end
    self._touchBoundingBox = CCRectMake(pos.x,pos.y,self._width,self._height)
    self._touchLayer:setCascadeBoundingBox(self._touchBoundingBox)
    self._stencilLayer:setContentSize(size)


    if self._shadowIsNode then
        return
    end

    if self._isVertical then
        if self._topShadow ~= nil then
            self._topShadow:setAnchorPoint(ccp(1, 0))
            self._topShadow:setRotation(180)
            self._topShadow:setPosition(ccp(0, self._height))
            self._topShadow:setPreferredSize(CCSize(self._width, self._shadowSize))
        end
        if self._bottomShadow then
            self._bottomShadow:setAnchorPoint(ccp(0, 0))
            self._bottomShadow:setRotation(0)
            self._bottomShadow:setPosition(ccp(0, 0))
            self._bottomShadow:setPreferredSize(CCSize(self._width, self._shadowSize))
        end
    else
        if self._leftShadow ~= nil then
            self._leftShadow:setAnchorPoint(ccp(1, 0))
            self._leftShadow:setRotation(90)
            self._leftShadow:setPosition(ccp(0, 0))
            self._leftShadow:setPreferredSize(CCSize(self._shadowSize, self._height))
        end
        if self._rightShadow then
            self._rightShadow:setAnchorPoint(ccp(0, 0))
            self._rightShadow:setRotation(-90)
            self._rightShadow:setPosition(ccp(self._width, 0))
            self._rightShadow:setPreferredSize(CCSize(self._shadowSize, self._height))
        end
    end
end
--清空所有items

function QListView:clear( isCleanUp )
    -- body
    
    self:removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)
    self:unscheduleUpdate()

    self._listViewImp.clearAllItems(self,isCleanUp)
end

function QListView:setScollDelegate( callback )
    -- body
    self._scrollDelegate = callback
end

--reload数据
function QListView:reload( param )
    -- body
    self:clear(param.isCleanUp)
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, QListView.onFrame))
    self:scheduleUpdate()

    self._headIndex = param.headIndex or self._headIndex        --当前视口的起始索引
    self._tailIndex = param.tailIndex or self._tailIndex        --当前视口的结束索引
    self._totalNumber = param.totalNumber or self._totalNumber
    self._isVertical = param.isVertical == nil and self._isVertical or param.isVertical
    self._maxItemNum = param.maxItemNum or self._maxItemNum
    self._renderItemCallBack = param.renderItemCallBack or self._renderItemCallBack
    self._multiItems = param.multiItems or self._multiItems    -- 一行有2个或者多个
    self._curOffset = param.curOffset or self._curOffset
    self._curOriginOffset = param.curOriginOffset or self._curOriginOffset
    self._spaceY = param.spaceY or self._spaceY
    self._spaceX = param.spaceX or self._spaceX
    self._headIndexPosOffset = param.headIndexPosOffset or self._headIndexPosOffset
   
    if self._maxItemNum and self._totalNumber and self._maxItemNum < self._totalNumber then
        print("----error  self._maxItemNum < self._totalNumber ")
        self._totalNumber = self._maxItemNum
    end

    self._baseStartIndex =  param.baseStartIndex or 1
    self._baseEndIndex = self._baseStartIndex + self._totalNumber -1
    if self._multiItems ~=1 and self._baseStartIndex % self._multiItems ~= 1 then
        print("error  self._baseStartIndex % self._multiItems must equal 1")
        self._baseStartIndex = self._baseStartIndex - (self._baseStartIndex -1)%self._multiItems + self._multiItem
    end

    if self._isVertical then
        if param._curOffset then
            self._curOffset = self._curOffset - self._spaceY
        end
        self._listViewImp = QVerticalListViewImp
    else
        if param._curOffset then
            self._curOffset = self._curOffset - self._spaceX
        end
        
        self._listViewImp = QHorizontalListViewImp
    end

    self._content:setPosition(ccp(0,0))

    self._listViewImp.initListView(self)
end

-- 刷新数据  --必须保证 数据的值 不会影响 item 大小  没变 否则 可能已发 bug
function QListView:refreshData( )
    -- body
    self._listViewImp.stopSpeedScheduler(self)
    self:stopLongPressScheduler()
    self:stopScrollToPosScheduler()
    self:stopScrollToIndex()

    self:clearAllClickHandler()
    self:clearAllTouchHandler()
    self._curTouchIndex = nil
    self._curTouchNodeName = nil
    self._startScrollToIndex = nil
    for i = self._startIndex,self._endIndex do
        self:refreshItem(i)
    end
    self._listViewImp.onScroll(self)

end

-- renderItemCallBack 回调函数中使用  从缓存中 获取node
function QListView:getItemFromCache( tag )
    -- body
    tag = tag or "default"
    if self._cacheNodes[tag] and #self._cacheNodes[tag] > 0 then
        local item = self._cacheNodes[tag][1]
        table.remove(self._cacheNodes[tag],1)
        return item
    end
end
--滚动到指定索引  index 指定的索引   isTail index结尾 还是开头   speed 滚动速度 默认 20
function QListView:startScrollToIndex( index, isTail,speed, callback, scrollToIndexPosOffset)
    -- body
    if index > self._baseEndIndex or index < self._baseStartIndex then
        print("error index  must <= self._baseEndIndex and must >= self._baseStartIndex index ",index, "  self._baseEndIndex ",self._baseEndIndex," self._baseStartIndex ",self._baseStartIndex)
        return
    end
    self._scrollToIndexTargetIndex = index - (index -1)%self._multiItems
    self._scrollToIndexIsTail = isTail
    self._scrollToIndexSpeed = speed or 20
    self._scrollToIndexTargetPos = nil
    self._scrollToIndexPosOffset = scrollToIndexPosOffset or 0
    self._startScrollToIndex = true
    self._scrollToIndexCallBack = callback
end

function QListView:stopScrollToIndex( )
    -- body
    self._scrollToIndexTargetIndex = nil
    self._scrollToIndexIsTail = nil
    self._scrollToIndexSpeed = nil
    self._scrollToIndexTargetPos = nil
    self._startScrollToIndex = nil
    self._scrollToIndexPosOffset = nil
    if self._scrollToIndexCallBack then
        self._scrollToIndexCallBack()
        self._scrollToIndexCallBack = nil
    end
end

--获取指定索引的 item
function QListView:getItemByIndex( index )
    if index >= self._startIndex and index <= self._endIndex then
        return self._itemsInfo[index].item,index
    end
    return nil
end

-- 预先增加 高度  一般不要直接修改
function QListView:getRect( )
    -- body
    return self._rect
end

--屏蔽触摸事件
function QListView:setShieldTouch( trueOrFalse )
    -- body
    self._shieldTouch = trueOrFalse
end

--设置是否可以 触摸移动
function QListView:setCanNotTouchMove( trueOrFalse )
    -- body
    self._canNotTouchMove = trueOrFalse
end

function QListView:getCanDrag()
    if self._isVertical then
        return self._canDragY
    else
        return self._canDragX
    end
end

function QListView:getIsExceedRect()
    if self._isVertical then
        return self._curHeight > self._height
    else
        return self._curWidth >= self._width
    end
end
function QListView:getItemPosToTopDistance( index )
    -- body
    local itemInfo = self._itemsInfo[index]
    if itemInfo then
        if self._isVertical then    
            return math.abs(itemInfo.pos.y - self._baseRootY) - self._dragY
        end 
    end
    return 0
end

--[[
    内部函数 
]]
function QListView:onTouch(event)
    if event.name == "began" then
        self._touchBeganRet = self._listViewImp.onTouchBegin(self, event.x, event.y)
        return self._touchBeganRet
    elseif event.name == "moved" then
        self._listViewImp.onTouchMove(self, event.x, event.y)
    elseif event.name == "ended" then
        self._listViewImp.onTouchEnd(self, event.x, event.y)
        self._touchBeganRet = nil
    end
end

function QListView:onFrame( dt )
    -- body

    -- print("--------------------_onFrame---------------")
    self._listViewImp.scrollToIndexOnFrame(self,dt)
    self._listViewImp.getSpeedOnFrame(self, dt)
    self._listViewImp.scrollToPosOnFrame(self, dt)
    self:longPressOnFrame(dt)

end

function QListView:setBaseNodePosX( dragx )
    -- body
    self._baseRootNode:setPositionX(dragx)
    if self._scrollDelegate then
        self._scrollDelegate(dragx, 0)  
    end
end

function QListView:setBaseNodePosY( dragy )
    -- body
    self._baseRootNode:setPositionY(dragy)
    if self._scrollDelegate then
        self._scrollDelegate(0, dragy)  
    end
end

function QListView:addItemToCache( index, info )
    -- body
    local item = info.item
    local tag = info.tag or "default"
    if not self._cacheNodes[tag] then
        self._cacheNodes[tag] = {}
    end
    item:setVisible(false)
    self:unRegisterTouchHandler(index)
    self:unRegisterClickHandler(index)
    table.insert(self._cacheNodes[tag],item)
end

function QListView:renderItem( index, info )
    -- body
    local isCacheNode, zorder = self._renderItemCallBack(self,index,info)

    if not info.item  or not info.size then
        print("error  info is empty")
        return 
    end
    local item = info.item
    if not isCacheNode then
        item:setVisible(false)
        self._content:addChild(item)
    -- else
    --     item:setVisible(true)
    end

    if zorder then
        item:setZOrder(zorder)
    end
    info.size.height = info.size.height + self._spaceY
    info.size.width = info.size.width + self._spaceX
    
    return item
end


function QListView:refreshItem( index )
    -- body
    local info = self._itemsInfo[index]
    if not info then
        return
    end
    self:addItemToCache(index, info)
    self:renderItem(index,info)
    info.item:setPosition(info.pos)
end

function QListView:addItem( isAutoScroll )
    -- body
    self._listViewImp.addItem(self,isAutoScroll)
end


function QListView:getCurGesture(  )
    -- body
    return self._curGesture
end

------------------------触摸点击逻辑---------------
function QListView.isTouchInside( node, x, y)
    local  parent = node:getParent()
    if parent then
        local point = parent:convertToNodeSpace(ccp(x,y))
        local rt = node:boundingBox()
        return rt:containsPoint(point);
    else
        print("error can not find parent")
    end
    return false
end

function QListView.isTouchNodeVisible( node )
    -- body
    if node:isVisible() then
        local parent = node:getParent()
        if parent then
            return QListView.isTouchNodeVisible(parent)
        else
            return true
        end
    end
end
---
function QListView.doBtnPressIn( x, y, touchNodeNode, list, showBtnHighlightColor)
    local ret = false
    if QListView.isTouchNodeVisible(touchNodeNode) and  QListView.isTouchInside(touchNodeNode, x, y) then
        if touchNodeNode.isEnabled and touchNodeNode:isEnabled() and touchNodeNode.setHighlighted then
            touchNodeNode:setHighlighted(true)
        end
        if showBtnHighlightColor then
            touchNodeNode:setColor(ccc3(210, 210, 210))
        end
        ret = true
    end
    return ret
end

function QListView.doBtnCancelPressIn( x , y, touchNodeNode, list, showBtnHighlightColor)
    if showBtnHighlightColor then
        touchNodeNode:setColor(ccc3(255, 255, 255))
    end
    if touchNodeNode.isEnabled and touchNodeNode:isEnabled() and touchNodeNode.setHighlighted then
        touchNodeNode:setHighlighted(false)
    end
end


function QListView.doItemBoxPressIn( x, y, touchNodeNode, list )
    -- body
    local ret = false
    if touchNodeNode and touchNodeNode._ccbOwner and touchNodeNode._ccbOwner.sprite_back then
        local node = tolua.cast(touchNodeNode._ccbOwner.sprite_back, "CCSprite")
        if node then
            if QListView.isTouchInside(node, x, y) then
                ret = true
            end
        end
    end
    
    return ret
end

function QListView.doItemBoxClickIn( x, y, touchNodeNode, list )
    -- body
    if touchNodeNode then
        app.tip:itemTip(touchNodeNode._itemType, touchNodeNode._itemID)
    end
end
-- local function doIconPromptTipsLongPressIn( x , y, touchNodeNode, list )
--     -- body
--     local touchIndex = list:getCurTouchIndex()
--     local item = list:getItemByIndex(touchIndex)
--     if item and type(item.___itemBoxs) == "table" then
--         for _,v in pairs(item.___itemBoxs) do
--             local node = tolua.cast(v._ccbOwner.sprite_back, "CCSprite")
--             if node then
--                 if isTouchInside(node, x, y) then
--                     item.___touchItemBox = v 
--                     QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetItemsBox.EVENT_BEGAIN , eventTarget = v, itemID=v._itemID, itemType = v._itemType})
--                     return true
--                 end
--             end
--         end
--     end
--     return false
-- end
-- local function doCancelIconPromptTipsLongPressIn( x , y, touchNodeNode, list )
--     -- body
--     local touchIndex = list:getCurTouchIndex()
--     local item = list:getItemByIndex(touchIndex)
--     if item and item.___touchItemBox then
        
--         QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetItemsBox.EVENT_END , eventTarget = item.___touchItemBox})
--         item.___touchItemBox = nil
--     end
-- end


function QListView:startLongPressScheduler(  )
    -- body
    self._longPressTime = 0
end


function QListView:stopLongPressScheduler(  )
    -- body
    self._longPressTime = nil
end

function QListView:longPressOnFrame(dt)
    -- body
    if self._longPressTime then
        self._longPressTime = self._longPressTime + dt
        if self._longPressTime > 0.4 then
            if self._lastPressX and self._lastPressY then
                self:doLongPressIn(self._lastPressX, self._lastPressY)
                self:stopLongPressScheduler()
            end
        end
    end
end


function QListView:calculateTouchIndex( x, y )
    -- body
    local pos = self._content:convertToNodeSpace(ccp(x,y))
    for i = self._startIndex,self._endIndex do
        local info = self._itemsInfo[i]

        --判断点击index
        local offsetX, offsetY = 0, 0
        if info.offsetPos then
            offsetX, offsetY = info.offsetPos.x, info.offsetPos.y
        end
        offsetX = offsetX + self._contentOffsetX
        offsetY = offsetY + self._contentOffsetY
        if pos.x > (info.pos.x - offsetX) and pos.x <= (info.pos.x - offsetX) + info.size.width and pos.y < (info.pos.y - offsetY) and pos.y >= (info.pos.y - offsetY) - info.size.height then
            print("cur touch index ", i)
            self._curTouchIndex = i
            break;
        end
    end
end

function QListView:resetTouchIndex()
    -- body
   self._curTouchIndex = nil
end

function QListView:doTouchBegin( x,y )
    -- body
    if not self._curTouchIndex  then
        return 
    end
    local touchHandler = self._touchHandlers[self._curTouchIndex]
    if type(touchHandler) == "function" then
        touchHandler({name = "began", x = x, y = y})
    elseif type(touchHandler) == "string" then
        local item  = self._itemsInfo[self._curTouchIndex].item
        if item then
            item[touchHandler](item, {name = "began", x = x, y = y})
        end
    end
end


function QListView:doTouchMove( x, y )
    -- body
    if not self._curTouchIndex then
        return 
    end
    local touchHandler = self._touchHandlers[self._curTouchIndex]
    if type(touchHandler) == "function" then
        touchHandler({name = "moved", x = x, y = y})
    elseif type(touchHandler) == "string" then
        local item  = self._itemsInfo[self._curTouchIndex].item
        if item then
            item[touchHandler](item, {name = "moved", x = x, y = y})
        end
    end

end

function QListView:doTouchEnd( x, y )
    -- body
    if not self._curTouchIndex then
        return 
    end
    local touchHandler = self._touchHandlers[self._curTouchIndex]

    if type(touchHandler) == "function" then
        touchHandler({name = "ended", x = x, y = y})
    elseif type(touchHandler) == "string" then
        local item  = self._itemsInfo[self._curTouchIndex].item
        if item then
            item[touchHandler](item, {name = "ended", x = x, y = y})
        end
    end
end

function QListView:doPressIn(x,y)
    -- body
    if not self._curTouchIndex then
        return 
    end

    local touchInfo = self._touchInfos[self._curTouchIndex]
    if not touchInfo then 
        return 
    end
    
    local ret = false
    for k, event in pairs(self._touchPriority) do
        local v = touchInfo[event.eventName]
        if v then
            local touchHandler = v.doPressIn
            local showBtnHighlightColor = v.showBtnHighlightColor
            if type(touchHandler) == "function" then
                ret = touchHandler(x, y, v.touchNodeNode, self, showBtnHighlightColor)
            elseif type(touchHandler) == "string" then
                local item  = self._itemsInfo[self._curTouchIndex].item
                ret = item[touchHandler](item,x, y, v.touchNodeNode, self, showBtnHighlightColor)
            end
            if ret then

                self._curTouchNodeName = v.touchNodeName
                -- print("self._curTouchNodeName ",self._curTouchNodeName)
                return ret
            end
        end
    end
    return ret
end

function QListView:doLongPressIn(x,y)
    -- body
    if not self._curTouchIndex then
        return 
    end
    local touchInfo = self._touchInfos[self._curTouchIndex]
    if not touchInfo then 
        return 
    end
    local ret = false
    for k, event in pairs(self._touchPriority) do
        local v = touchInfo[event.eventName]
        if v then
            local touchHandler = v.doLongPressIn
            if type(touchHandler) == "function" then
                ret = touchHandler(x, y, v.touchNodeNode, self)
            elseif type(touchHandler) == "string" then
                local item  = self._itemsInfo[self._curTouchIndex].item
                ret = item[touchHandler](item,x, y, v.touchNodeNode, self)
            end
            if ret then
                     print("self._curTouchNodeName 111", self._curTouchNodeName)

                self._curTouchNodeName = v.touchNodeName
                return ret
            end
        end
    end
    return ret
end

function QListView:doClickIn(x,y)
    -- body
    if self._curTouchIndex ~= nil and self._curTouchNodeName ~= nil then
        local touchIndex = self._touchInfos[self._curTouchIndex]
        if not touchIndex then
            return
        end
        local touchInfo = touchIndex[self._curTouchNodeName]
        if not touchInfo then
            return
        end
        local item  = self._itemsInfo[self._curTouchIndex].item
        local touchHandler = touchInfo.doClickIn
        if type(touchHandler) == "function" then
            if touchHandler then
                touchHandler(x, y, touchInfo.touchNodeNode, self)
            end
        elseif type(touchHandler) == "string" then
            item[touchHandler](item,x, y, touchInfo.touchNodeNode, self)
        end
    end
    self._curTouchNodeName = nil
end


function QListView:doCancelPressIn(x,y)
    if self._curTouchIndex ~= nil and self._curTouchNodeName ~= nil  then
        local touchIndex = self._touchInfos[self._curTouchIndex]
        if not touchIndex then
            return
        end
        local touchInfo = touchIndex[self._curTouchNodeName]
        if not touchInfo then
            return
        end
        local item  = self._itemsInfo[self._curTouchIndex].item
        local touchHandler = touchInfo.doCancelPressIn
        local showBtnHighlightColor = touchInfo.showBtnHighlightColor
        if type(touchHandler) == "function" then
            if touchHandler then
                touchHandler(x, y, touchInfo.touchNodeNode, self, showBtnHighlightColor)
            end
        elseif type(touchHandler) == "string" then
            item[touchHandler](item,x, y, touchInfo.touchNodeNode, self, showBtnHighlightColor)
        end
    end

end

function QListView:insertClickEvent( eventName, priority )
    -- body
    local index = 1
    for k, v in pairs(self._touchPriority) do
        if v.eventPriority > priority then
            break
        end
        index = index + 1
    end
    table.insert(self._touchPriority, index, {eventPriority = priority, eventName = eventName})
end

function QListView:removeClickEvent( eventName, priority )
    -- body
    for k, v in pairs(self._touchPriority) do
        if v.eventName == eventName then
            table.remove(self._touchPriority, k)
            break
        end
    end
end


function QListView:registerItemBoxPrompt( index, itemBoxIndex,itemBox,priority, customHander, isLongPress)
    -- body
    local clickInHander = customHander or QListView.doItemBoxClickIn
    if isLongPress then
        self:registerClickHandler(index, "ItemBoxPrompt"..itemBoxIndex, QListView.doItemBoxPressIn, nil, nil, clickInHander, priority, itemBox)
    else
        self:registerClickHandler(index, "ItemBoxPrompt"..itemBoxIndex, QListView.doItemBoxPressIn, nil, clickInHander, nil, priority, itemBox)
    end
end

----注册 触摸事件 注意 这个注册触摸事件需要放到info 赋值之后
function QListView:registerBtnHandler(index, touchNodeName, clickHandler, priority, showBtnHighlightColor, touchNode)
    -- print("index  ",index,"  ",#self._itemsInfo)
    -- printTable(self._itemsInfo)
    local item = self._itemsInfo[index].item
    local touchInfo = {}

    touchInfo.touchNodeName = touchNodeName

    if touchNode then
        touchInfo.touchNodeNode = touchNode
    elseif item._ccbOwner or touchNodeName ~= "self" then
        touchInfo.touchNodeNode = item._ccbOwner[touchNodeName]
    end

    if not touchInfo.touchNodeNode then
         touchInfo.touchNodeNode = item
    end
    
    touchInfo.doPressIn = QListView.doBtnPressIn;
    touchInfo.doCancelPressIn = QListView.doBtnCancelPressIn;
    touchInfo.doClickIn = clickHandler
    touchInfo.showBtnHighlightColor = showBtnHighlightColor

    if not self._touchInfos[index] then
        self._touchInfos[index] = {}
    end
    self._touchInfos[index][touchNodeName] = touchInfo
    self:insertClickEvent(touchNodeName, priority or 0)
end
--注册 触摸事件
function QListView:registerClickHandler( index, touchNodeName, doPressInHandler, doCancelPressInHandler, doClickInHandler, doLongPressInHandler,priority,touchNode)
    -- body
    local item = self._itemsInfo[index].item
    local touchInfo = {}
    touchInfo.touchNodeName = touchNodeName

    if touchNode then
        touchInfo.touchNodeNode = touchNode
    elseif item._ccbOwner or touchNodeName ~= "self" then
        touchInfo.touchNodeNode = item._ccbOwner[touchNodeName]
    end

    if not touchInfo.touchNodeNode then
         touchInfo.touchNodeNode = item
    end

    touchInfo.doPressIn = doPressInHandler;
    touchInfo.doCancelPressIn = doCancelPressInHandler;
    touchInfo.doClickIn = doClickInHandler
    touchInfo.doLongPressIn = doLongPressInHandler

    if not self._touchInfos[index] then
        self._touchInfos[index] = {}
    end
    self._touchInfos[index][touchNodeName] = touchInfo
    self:insertClickEvent(touchNodeName, priority or 0)
end


function QListView:registerTouchHandler( index, touchHandler )
    -- body
    self._touchHandlers[index] = touchHandler
end

function QListView:unRegisterTouchHandler( index)
    -- body
    self._touchHandlers[index] = nil
end

--注册 icon 长按出详情 ___itemBoxs  
-- function QListView:registerIconPromptTipsHandler( index)
--     -- body
--     local item = self._itemsInfo[index].item
--     if type(item.___itemBoxs) ~= "table" then
--         return 
--     end

--     local touchInfo = {}
--     local touchNodeName = "___IconPromptTips"
--     touchInfo.touchNodeName = touchNodeName
--     touchInfo.touchNodeNode = item

--     touchInfo.doCancelPressIn = doCancelIconPromptTipsLongPressIn 
--     touchInfo.doLongPressIn = doIconPromptTipsLongPressIn

--     if not self._touchInfos then
--         self._touchInfos = {}
--     end
--     if not self._touchInfos[index] then
--         self._touchInfos[index] = {}
--     end
--     self._touchInfos[index][touchNodeName] = touchInfo
-- end


function QListView:unRegisterClickHandler( index, touchNodeName)
    -- body
    if not touchNodeName then
        self._touchInfos[index] = nil
        return 
    end

    if self._touchInfos[index] and self._touchInfos[index][touchNodeName] then
        self._touchInfos[index][touchNodeName] = nil
    end

    self:removeClickEvent(touchNodeName)
end

function QListView:clearAllClickHandler( index )
    -- body
    self._touchInfos = {}
    self._touchPriority = {}
end

function QListView:clearAllTouchHandler( ... )
    -- body
    self._touchHandlers = {}
end

function QListView:getCurTouchIndex(  )
    -- body
    return self._curTouchIndex
end

function QListView:getCurStartIndex(  )
    -- body
    return self._startIndex
end

function QListView:getCurEndIndex(  )
    -- body
    return self._endIndex
end

--滚动一段距离 distance 滚动距离  time 滚动时间  isRollBack 是否是回滚 callback 回调 isCanNotTouchStop 是否可以触摸中断
function QListView:startScrollToPosScheduler(distance,time,isRollBack, callback, isCanNotTouchStop)
    -- body
    self._targetDistance = distance
    self._isRollBack = isRollBack
    self._scrollTime = 0
    self._startScrollToPos = true
    self._lastPercent = 0
    self._scrollToPosTotalTime = time
    self._scrollToPosCallback = callback
    self._scrollToPosCanNotTouchStop = isCanNotTouchStop
end

function QListView:stopScrollToPosScheduler(notRunCallback)
    -- body
    self._targetDistance = nil
    self._isRollBack = nil
    self._scrollTime = 0
    self._startScrollToPos = nil
    self._lastPercent = nil
    self._scrollToPosTotalTime = 0
    self._scrollToPosCanNotTouchStop = nil
    self._listViewImp.scrollBarFadeOut(self)
    
    if not notRunCallback and self._scrollToPosCallback then
        self._scrollToPosCallback()
    end
    self._scrollToPosCallback = nil
end



--[[
    垂直滚动
]]


function QVerticalListViewImp:initListView(  )
    -- body
    self._dragY = 0
    self._lastDragY = 0
    -- self._dChangeBaseRootY = 0
    self._curHeight = 0
    self._canDragY = false
    self._baseRootY = 0
    self._cacheLimit = self._height * self._cacheCond
    local upHeight = 0
    local downHeight = 0
    
    local limit1,limit2
    local index
    local tailIndex = self._tailIndex 

    if tailIndex then

        if tailIndex > self._baseEndIndex then
            tailIndex = self._baseEndIndex
        end

        limit1 = self._height + self._cacheLimit 
        limit2 = self._cacheLimit
        index = tailIndex + self._multiItems

    else
        limit1 = self._cacheLimit + self._headIndexPosOffset
        limit2 = self._height + self._cacheLimit
        index = self._headIndex
        if not index or index < self._baseStartIndex then
            index = self._baseStartIndex
        end

        if index > self._baseEndIndex then
            index = self._baseStartIndex
        end
    end

    if self._multiItems ~= 1 then
        index = index - (index -1)%self._multiItems
    end
    -- print("----index   ",index)
    if self._totalNumber ~= 0 then
        for i = index - self._multiItems, self._baseStartIndex, -self._multiItems  do
            local tempHeight = 0
            local width = 0
            for k = 0,self._multiItems -1,1 do
                local tempIndex = i+k
                if tempIndex > self._totalNumber then
                    break
                end
                local info = {}
                self._itemsInfo[tempIndex] = info

                local item = self:renderItem(tempIndex,info)
                local posx = width + self._contentOffsetX
                local posy = upHeight + info.size.height + self._contentOffsetY

                tempHeight = math.max(info.size.height,tempHeight)
                width = width + info.size.width

                local offsetX = 0
                local offsetY = 0
                if info.offsetPos then
                    offsetX = info.offsetPos.x
                    offsetY = info.offsetPos.y
                end
                info.pos = ccp(posx + offsetX, posy + offsetY)
                item:setPosition(info.pos)
            end
            limit1 = limit1 - tempHeight
            upHeight = upHeight + tempHeight        
            if limit1 <= 0 then
                self._startIndex = i
                break;
            end
        end
    end

    if limit1 > 0 then
        self._startIndex = self._baseStartIndex
    end

    for i = index,self._baseEndIndex, self._multiItems do
        local tempHeight = 0
        local width = 0
        for k = 0,self._multiItems -1,1 do
            local tempIndex = i+k
            if tempIndex > self._baseEndIndex then
                break
            end

            local info = {}
            self._itemsInfo[tempIndex] = info

            local item = self:renderItem(tempIndex,info)
            local posx = width + self._contentOffsetX
            local posy = -downHeight + self._contentOffsetY

            tempHeight = math.max(info.size.height,tempHeight)
            width = width + info.size.width

            local offsetX = 0
            local offsetY = 0
            if info.offsetPos then
                offsetX = info.offsetPos.x
                offsetY = info.offsetPos.y
            end
            info.pos = ccp(posx + offsetX, posy + offsetY)

            item:setPosition(info.pos)
        end
        limit2 = limit2 - tempHeight
        downHeight = downHeight + tempHeight

        if limit2 <= 0 then
            self._endIndex = i + self._multiItems - 1
            if self._endIndex > self._baseEndIndex then
                self._endIndex = self._baseEndIndex
            end
            break;
        end
    end
    if limit2 > 0 then
        self._endIndex = self._baseEndIndex
    end
 
    if self._startIndex == self._baseStartIndex then
        upHeight = upHeight + self._curOriginOffset
    end

    if self._endIndex == self._baseEndIndex then
        downHeight = downHeight + self._curOffset
    end

    self._baseRootY = upHeight
    self._curHeight = upHeight + downHeight

    --
    if not tailIndex then
        if upHeight >= self._headIndexPosOffset then
            upHeight = upHeight - self._headIndexPosOffset
            downHeight = downHeight + self._headIndexPosOffset
        else
            upHeight = self._headIndexPosOffset
            downHeight = downHeight + upHeight - self._headIndexPosOffset
        end
    end

    if tailIndex then
        if upHeight > self._height then
            self._dragY = upHeight - self._height
        end
    else
        if downHeight < self._height  then
            if self._height - downHeight < upHeight  then
                -- and self._startIndex ~= self._baseStartIndex
                self._dragY = self._curHeight - self._height
            end
        else
            if self._startIndex == self._baseStartIndex then
                self._dragY = upHeight - self._curOriginOffset
            else
                self._dragY = upHeight
            end
           
        end
    end

    if self._curHeight > self._height or self._ignoreCanDrag then
        self._canDragY = true
    end
    
    self:setBaseNodePosY(self._dragY)
    self._content:setPositionY(self._height - self._baseRootY)

    if self._enableShadow and not self._topShadow and not self._bottomShadow then
        self._listViewImp.initShadow(self)
    end
    self._listViewImp.showShadow(self)

    if self._enableScrollBar then
        self._listViewImp.initScrollBar(self)
    end

    self._listViewImp.setItemVisible(self)
    
end

function QVerticalListViewImp:initShadow(  )
    -- self._topShadow = CCLayerGradient:create(ccc4(58, 22, 0, 255), ccc4(0, 0, 0, 0), ccp(0, -1))
    self._topShadow = CCScale9Sprite:create("ui/update_common/sp_list_uodown.png")
    self._topShadow:setAnchorPoint(ccp(1, 0))
    self._topShadow:setRotation(180)
    self._topShadow:setPosition(ccp(0, self._height))
    self._topShadow:setPreferredSize(CCSize(self._width, self._shadowSize))

    -- self._bottomShadow = CCLayerGradient:create(ccc4(58, 22, 0, 255), ccc4(0, 0, 0, 0), ccp(0, 1))
    self._bottomShadow = CCScale9Sprite:create("ui/update_common/sp_list_uodown.png")
    self._bottomShadow:setAnchorPoint(ccp(0, 0))
    self._bottomShadow:setRotation(0)
    self._bottomShadow:setPosition(ccp(0, 0))
    self._bottomShadow:setPreferredSize(CCSize(self._width, self._shadowSize))

    self:addChild(self._topShadow)
    self:addChild(self._bottomShadow)
end
function QVerticalListViewImp:showShadow(  )
    -- body
    if self._enableShadow then
        if self._canDragY then
            if self._dragY > 0 then
                if not self._isRollBack then
                    self._topShadow:setVisible(true)
                end
            else
                self._topShadow:setVisible(false)
            end

            if self._dragY < self._curHeight - self._height then
                if not self._isRollBack then
                    self._bottomShadow:setVisible(true)
                end
            else
                self._bottomShadow:setVisible(false)
            end
        else
            self._topShadow:setVisible(false)
            self._bottomShadow:setVisible(false)
        end
    end
end

--滑动条  --注意 self._scrollBarBg  是 self._scrollBar 的父节点
function QVerticalListViewImp:initScrollBar(  )
    -- body
    self._scrollBarIsFadeIn = false
    self._scrollBarIsFadeOut = false
    if not self._scrollBarParentNode and not self._scrollBar then
        local parentNode = CCNode:create()
        local scrollBarBg,scrollBar
    
        scrollBarBg = CCScale9Sprite:create("ui/common/xialatiao_hei.png") 
        scrollBar = CCScale9Sprite:create("ui/common/gundong.png")


        parentNode:addChild(scrollBarBg)
        parentNode:addChild(scrollBar)

        scrollBarBg:setContentSize(CCSizeMake(5,self._height))
        scrollBarBg:setAnchorPoint(0,0)

        scrollBar:setAnchorPoint(0,1)

        parentNode:setPosition(self._scrollBarPos)
        parentNode:setCascadeOpacityEnabled(true)
        self:addChild(parentNode)

        self._scrollBarBg = scrollBarBg
        self._scrollBar = scrollBar
        self._scrollBarParentNode = parentNode
    end

    local rt = self._scrollBar:boundingBox()
    self._scrollBarHeight = rt.size.height
    self._scrollBarBaseScaleY = self._scrollBar:getScaleY()
    if angle == 90 or angle == 270 then
        self._scrollBarScaleReverse = true
    end
    self._scrollBarParentNode:setOpacity(0)
end

function QVerticalListViewImp:scrollBarFadeIn(  )
    -- body
    if self._enableScrollBar and self._canDragY then
        if self._scrollBarParentNode:getOpacity() ~= 255 and self._scrollBarIsFadeIn == false then
            self._scrollBar:setScaleY(1)
            if self._scrollBarIsFadeOut then
                self._scrollBarParentNode:stopAllActions()
                self._scrollBarIsFadeOut = false
            end
            self._scrollBarIsFadeIn = true
            local fade = CCFadeIn:create(0.5)
            local func = CCCallFunc:create(function()
                self._scrollBarIsFadeIn = false
            end)
            local s1 = CCSequence:createWithTwoActions(fade , func)
            self._scrollBarParentNode:runAction(s1)
        end
        if self._dragY < 0 then
            self._scrollBar:setPositionY(self._height)
            if self._scrollBarScaleReverse then
                self._scrollBar:setScaleX((1 - math.abs(self._dragY/self._height)) * self._scrollBarBaseScaleY)
            else
                self._scrollBar:setScaleY((1 - math.abs(self._dragY/self._height)) * self._scrollBarBaseScaleY)
            end
        elseif self._dragY > self._curHeight - self._height then
            local scaleY = 1 - math.abs((self._dragY - self._curHeight + self._height)/self._height)
            if self._scrollBarScaleReverse then
                self._scrollBar:setScaleX(scaleY * self._scrollBarBaseScaleY)
            else
                self._scrollBar:setScaleY(scaleY * self._scrollBarBaseScaleY)
            end
            self._scrollBar:setPositionY(self._scrollBarHeight * scaleY) 
        else
            self._scrollBar:setPosition(ccp(0,self._height - (self._height - self._scrollBarHeight) * (math.abs(self._dragY/(self._curHeight - self._height)))))
        end
    end
end


function QVerticalListViewImp:scrollBarFadeOut(  )
    -- body
    -- print(self._scrollBarParentNode:getOpacity(),self._scrollBarIsFadeIn,self._scrollBarIsFadeOut )
    if self._enableScrollBar and self._scrollBarIsFadeOut == false then
        if self._scrollBarIsFadeIn then
            self._scrollBarParentNode:stopAllActions()
            self._scrollBarIsFadeIn = false
        end
        self._scrollBarIsFadeOut = true
        local fade = CCFadeOut:create(0.5)
        local func = CCCallFunc:create(function()
            self._scrollBarIsFadeOut = false
        end)
        local s1 = CCSequence:createWithTwoActions(fade , func)
        self._scrollBarParentNode:runAction(s1)
    end
end


function QVerticalListViewImp:startSpeedScheduler(  )
    -- body
    self._speedScheduler = true
    self._speedY = 0
    self._speedCountY = 0
    self._lastDragY = self._dragY
end

function QVerticalListViewImp:stopSpeedScheduler(  )
    -- body
    self._speedScheduler = nil
    self._lastDragY = nil
    self._speedCountY = nil
 
end

function QVerticalListViewImp:getSpeedOnFrame( dt )
    -- body
    if self._speedScheduler then
        local dy = self._dragY - self._lastDragY 
        if self._dChangeBaseRootY then
            dy = dy - self._dChangeBaseRootY
            self._dChangeBaseRootY = nil
        end
        local speedY = dy/dt
        if math.abs(speedY) < 1000 then
            self._speedCountY = self._speedCountY + 1
        else
            self._speedCountY = 0
        end
        if self._speedCountY > 12 then
            self._speedY = 0
        else
            self._speedY = (self._speedY + speedY)/2
        end
        self._lastDragY = self._dragY
    end
end


function QVerticalListViewImp:scrollToPosOnFrame(dt)
    -- body
    if self._startScrollToPos then
        --CCEaseBackOut
        local tempPercent,percent,dPercent
        self._scrollTime = self._scrollTime + dt
        local ft = self._scrollTime/self._scrollToPosTotalTime > 1 and 1 or self._scrollTime/self._scrollToPosTotalTime
        if self._isRollBack then
            local tempPercent = ft - 1
            percent = tempPercent*tempPercent*((1.70158 + 1)*tempPercent + 1.70158) + 1
        else
            tempPercent = ft
            percent = tempPercent > 1 and 1 or 1 - math.pow(2, -10 * tempPercent)
        end
        dPercent = percent - self._lastPercent
        self._lastPercent = percent
        local dy = self._targetDistance * dPercent

        if dy > 0 then
            self._isUp = true
            if dy > self._height then
                dy = self._height
            end
        else
            self._isUp = false
            if dy < -self._height then
                dy = -self._height
            end
        end
        self._dragY = self._dragY + dy
        self:setBaseNodePosY(self._dragY)
        self._listViewImp.onScroll(self)

        if not self._isRollBack then
            if self._dragY < 0 then
                self:startScrollToPosScheduler(0 - self._dragY,0.3,true)
            elseif self._dragY > self._curHeight - self._height  then
                self:startScrollToPosScheduler(self._curHeight - self._height - self._dragY, 0.3, true)
               
            elseif self._scrollTime >= self._scrollToPosTotalTime then
                self:stopScrollToPosScheduler()
            end
        else
            if self._scrollTime >= self._scrollToPosTotalTime then
                self:stopScrollToPosScheduler()
            end
        end

    end
end



function QVerticalListViewImp:setItemVisible(  )
    local viewTop = - self._dragY
    local viewBottom = -(self._dragY + self._height)

    for i = self._startIndex, self._endIndex, self._multiItems do
        local info = self._itemsInfo[i]
        if info.pos.y - info.size.height - self._baseRootY > viewTop or info.pos.y - self._baseRootY < viewBottom then

            for k = 0,self._multiItems - 1,1 do
                local tempIndex = i + k
                if tempIndex > self._endIndex then
                    break;
                end
                local tempInfo = self._itemsInfo[i + k]
                tempInfo.item:setVisible(false)
            end
        else
            for k = 0,self._multiItems - 1,1 do
                local tempIndex = i + k
                if tempIndex > self._endIndex then
                    break;
                end
                local tempInfo = self._itemsInfo[i + k]
               tempInfo.item:setVisible(true)
            end 
        end
    end
end






function QVerticalListViewImp:onScroll(  )
    -- body
    -- return 
    self._listViewImp.showShadow(self)
    self._listViewImp.scrollBarFadeIn(self)
    -- print("------1 ------count  ",self._content:getChildrenCount())

    local top = - (self._dragY - self._cacheLimit)
    local bottom = -(self._dragY + self._cacheLimit + self._height)
    -- print("top  ",top,"bottom ",bottom)
    -- print("self._startIndex  ",self._startIndex,"self._endIndex ",self._endIndex)
    --向上滑动
    if self._isUp then
        if self._endIndex == self._baseEndIndex then
            self._listViewImp.setItemVisible(self)
            return
        end
        for i = self._startIndex,self._endIndex,self._multiItems do
            local info = self._itemsInfo[i]
            if info then
                local nextItemY = info.pos.y - info.size.height
                  -- print("top   ",top, "nextItemY " ,nextItemY)
                --超过上边界 回收掉
                if top < nextItemY - self._baseRootY then
                    -- print("recycle 1 index ",i)
                    self:addItemToCache(i, info)
                    for k = 1,self._multiItems -1 do
                        local tempIndex = i + k
                        if tempIndex > self._endIndex then
                            break
                        end
                        local tempInfo = self._itemsInfo[tempIndex]
                        -- print("recycle  1 index ",tempIndex)
                        self:addItemToCache(tempIndex, tempInfo)
                    end
                else
                    self._startIndex = i
                    break
                end
            else
                print (">>> onScroll 1 err info is nil  index ",i)
                --info 为空 表示尚未有该index的信息
            end
        end
        -- local endIndex = math.ceil(self._baseEndIndex / self._multiItems) * self._multiItems
         --  渲染新的节点 
        local endIndex = self._endIndex - (self._endIndex-1) % self._multiItems

        for i = endIndex, self._baseEndIndex, self._multiItems do
        -- print("i   ",i,"self._baseEndIndex   ",self._baseEndIndex)
            local preInfo = self._itemsInfo[i]
            if preInfo then
                local nextItemY = preInfo.pos.y - preInfo.size.height 
                if nextItemY - self._baseRootY > bottom and i < self._baseEndIndex then
                    --渲染新的节点
                    local tempWidth = 0
                    for k = 0, self._multiItems-1 do
                        local tempIndex = i + self._multiItems + k
                        if tempIndex > self._baseEndIndex then
                            break;
                        end
                        -- print("create 1 index ",tempIndex)
                        local info = self._itemsInfo[tempIndex]
                        if not info then
                            info = {}
                            self._itemsInfo[tempIndex] = info
                        end
                      
                        local item = self:renderItem(tempIndex,info)
                        tempWidth = tempWidth + self._contentOffsetX
                        nextItemY = nextItemY + self._contentOffsetY

                        local offsetX = 0
                        local offsetY = 0
                        if info.offsetPos then
                            offsetX = info.offsetPos.x
                            offsetY = info.offsetPos.y
                        end
                        info.pos = ccp(tempWidth + offsetX, nextItemY)
                        tempWidth = tempWidth + info.size.width
                     
                        item:setPosition(info.pos)
                    end
                    
                else
                    self._endIndex = i + self._multiItems - 1
                    if self._endIndex > self._baseEndIndex then
                        self._endIndex = self._baseEndIndex
                    end
                    
                    --判断是否需要增加listview的高度
                    if self._curHeight < math.abs(nextItemY - self._baseRootY) then
                        if self._endIndex == self._baseEndIndex then
                            self._curHeight = math.abs(nextItemY - self._baseRootY) + self._curOffset
                        else
                            self._curHeight = math.abs(nextItemY - self._baseRootY)
                        end
                       
                        -- if self._curHeight > self._height then
                        --     self._canDragY = true
                        -- end
                        -- self.draglist:initListHeight(self.curHeight,false)
                    end
                    break;
                end
            else
                print (">>> onScroll 2 err info is nil  index ",i)
                --info 为空 表示尚未有该index的信息
            end
        end
    else
        if self._startIndex == self._baseStartIndex then
            self._listViewImp.setItemVisible(self)
            return
        end
        local endIndex = self._endIndex - (self._endIndex-1) % self._multiItems
        for i = endIndex , self._startIndex,-self._multiItems do
            local info = self._itemsInfo[i]
            if info then
                --负数比较
                if info.pos.y - self._baseRootY < bottom then
                    --超过下边界 回收掉
                    -- print("recycle 2 index ",i)
                    self:addItemToCache(i, info)
                    for k = 1,self._multiItems-1 do
                        if i + k <= self._baseEndIndex then
                            local tempInfo = self._itemsInfo[i + k]
                            -- print("recycle 2 index ",i - k)
                            self:addItemToCache(i + k, tempInfo)
                        end
                    end
                else
                    self._endIndex = i + self._multiItems - 1
                    if self._endIndex > self._baseEndIndex then
                        self._endIndex = self._baseEndIndex
                    end
                    break;
                end
            else
                print (">>> onScroll 3 err info is nil  index ",i)
                --info 为空 表示尚未有该index的信息
            end
        end

        for i = self._startIndex,self._baseStartIndex,-self._multiItems do
            local preInfo = self._itemsInfo[i]
            if preInfo then
                if top > preInfo.pos.y - self._baseRootY and i > self._baseStartIndex then
                    local tempWidth = 0
                    for k = self._multiItems,1, -1 do
                        local tempIndex = i - k
                        if tempIndex < self._baseStartIndex then
                            -- print("error  tempIndex < self._baseStartIndex")
                            break;
                        end
                        -- print("create 2 index ",tempIndex)
                        local info = self._itemsInfo[tempIndex]
                        if not info then
                            info = {}
                            self._itemsInfo[tempIndex] = info
                        end
                      
                        local item = self:renderItem(tempIndex,info)
                        local offsetX = 0
                        local offsetY = 0
                        if info.offsetPos then
                            offsetX = info.offsetPos.x
                            offsetY = info.offsetPos.y
                        end
                        info.pos = ccp(tempWidth + self._contentOffsetX + offsetX, preInfo.pos.y + info.size.height + self._contentOffsetY)
                        tempWidth = tempWidth + info.size.width
                        item:setPosition(info.pos)
                    end
                  
                else
                    self._startIndex = i
                    if preInfo.pos.y > self._baseRootY then
                        local dty= preInfo.pos.y - self._baseRootY
                        if self._startIndex == self._baseStartIndex then
                            self._baseRootY = preInfo.pos.y + self._curOriginOffset
                            dty = dty + self._curOriginOffset
                        else
                            self._baseRootY = preInfo.pos.y
                        end

                        self._curHeight = self._curHeight + dty
                        
                        -- print("----------rrrr-------------")
                        self._dragY = self._dragY + dty
                        self._content:setPositionY(self._height - self._baseRootY)
                        self:setBaseNodePosY(self._dragY)
                        --记录一次改变 _baseRootY  避免计算速度时 错误
                        self._dChangeBaseRootY = dty
                    end
                    break
                end
            else
                print (">>> onScroll 4 err info is nil  index ",i)
            end
        end
           
    end
    self._listViewImp.setItemVisible(self)
end



function QVerticalListViewImp:checkNeedScroll(  )
    if self._canDragY then
        if self._dragY < 0 or self._curHeight <= self._height then
            self:startScrollToPosScheduler(0 - self._dragY,0.3,true)
            if self._scrollBeginCallBack then
                self._scrollBeginCallBack()
            end
        elseif self._dragY > self._curHeight - self._height then
            self:startScrollToPosScheduler(self._curHeight - self._height - self._dragY,0.3,true)
            if self._scrollEndCallBack then
                self._scrollEndCallBack()
            end
        elseif self._speedY and self._speedY ~= 0 then
            if self._scrollMogveinggCallback then
                self._scrollMogveinggCallback(self._isUp,self._dragY)
            end
            local distance = self._speedY / 4
            self:startScrollToPosScheduler(distance,2)
        else
            if self._scrollMogveinggCallback then
                self._scrollMogveinggCallback(self._isUp,self._dragY)
            end
            self._listViewImp.scrollBarFadeOut(self)
        end
    end
end


function QVerticalListViewImp:checkCanTouch( )
    -- body
    if self._shieldTouch then
        return false
    end
    if self._startScrollToIndex then
        return false
    end

    if self._scrollToPosCanNotTouchStop then
        return false
    end



    return true
end




function QVerticalListViewImp:onTouchBegin(x, y)
   
   -- print("QVerticalListViewImp:onTouchBegin  -----")

    if not self._rect:containsPoint(self:convertToNodeSpace(ccp(x,y))) then
        return false
    end

    self._dragMode = false
    self._curGesture = nil 

    self._canTouch = self._listViewImp.checkCanTouch(self)
    if not self._canTouch then
        return
    end

    self:stopScrollToPosScheduler()
    
    self:calculateTouchIndex(x,y)

    self:doTouchBegin(x, y)
    self:doPressIn(x, y)
    
    self._listViewImp.startSpeedScheduler(self)
    self._lastPressX = x
    self._lastPressY = y
    self._firstPressPosX = x
    self._firstPressPosY = y

    self:startLongPressScheduler()


    return true
end



function QVerticalListViewImp:onTouchMove(x, y)
    if not self._canTouch or not self._touchBeganRet then
        return
    end

    local dx = x - self._lastPressX
    local dy = y - self._lastPressY
    -- local now = q.time()
    -- print("dx ",dx,"dy ",dy,"dt ",now - self._lastTime)
    -- self._lastTime = now

    if not self._dragMode then
        local x2 = (x - self._firstPressPosX) * (x - self._firstPressPosX)
        local y2 =  (y - self._firstPressPosY) * (y - self._firstPressPosY)

        local dis = math.sqrt( x2 + y2 )
        if dis > 10 then
            if x2 >= y2 then
                self._curGesture = QListView.GESTURE_H
            else
                self._curGesture = QListView.GESTURE_V
            end
            self:doCancelPressIn(x,y)
            self._curTouchNodeName = nil
            self:stopLongPressScheduler()
        end
        if dis > 10 and self._canDragY and not self._dragMode then
            self._dragMode = true
        end
    end

    self:doTouchMove(x, y)

    if self._canNotTouchMove then
        return
    end

    if self._dragMode then
        --阴影显示逻辑
        local coefficient = 1
        if self._dragY > self._curHeight - self._height then
            coefficient = self._endRate * ( 1 - ( self._dragY - (self._curHeight - self._height) ) / self._height )
        elseif self._dragY < 0 then
            coefficient = self._endRate * ( 1 - (- self._dragY) / self._height )
        end

        dy = dy * coefficient
        self._dragY = self._dragY + dy
        -- print("dy  ",dy,"self._dragY ",self._dragY, "coefficient ",coefficient , "self._curHeight ",self._curHeight, "self._height ",self._height)

        --xurui: self._endRate == 0 时，滑动到边界之后不允许再滑动
        if self._endRate == 0 then
            if self._dragY >= self._curHeight - self._height then
                self._dragY = self._curHeight - self._height
            elseif self._dragY <= 0 then
                self._dragY = 0
            end
        end
        self:setBaseNodePosY(self._dragY)
        if dy > 0 then
            self._isUp = true 
        else
            self._isUp = false 
        end
        self._listViewImp.onScroll(self)
    end
    self._lastPressX = x
    self._lastPressY = y
end

function QVerticalListViewImp:onTouchEnd(x, y)
    if not self._canTouch or not self._touchBeganRet then
        return
    end
    self:doTouchEnd(x, y)
    self:doCancelPressIn(x,y)
    self:doClickIn(x,y)
    self._dragMode = false
    self._curGesture = nil
    self._listViewImp.stopSpeedScheduler(self)
    self._listViewImp.checkNeedScroll(self)
    self:stopLongPressScheduler()
    self:resetTouchIndex()
end

function QVerticalListViewImp:clearAllItems( isCleanUp )
    -- body
    self._listViewImp.stopSpeedScheduler(self)
    self:stopLongPressScheduler()
    self:stopScrollToPosScheduler()
    self:stopScrollToIndex()

    -- print("1111------- self._startIndex ",self._startIndex,"self._endIndex ",self._endIndex)
    
    if isCleanUp then
        self._content:removeAllChildren()
        self._cacheNodes = {}
    else
        for i = self._startIndex,self._endIndex do
            local info = self._itemsInfo[i]
            self:addItemToCache(i, info)
        end
    end
    self._canDragY = false
    self._curHeight = 0
    self._baseStartIndex = 1
    self._baseEndIndex = 0
    self._totalNumber = 0
    self._startIndex = self._baseStartIndex
    self._endIndex = self._baseEndIndex
    self._dragY = 0
    self._itemsInfo = {}
    self:clearAllClickHandler()
    self:clearAllTouchHandler()
    self._curTouchIndex = nil
    self._curTouchNodeName = nil
    self:setBaseNodePosY(self._dragY)
    self._startScrollToIndex = nil
end
-- 改动了一些东西  这个函数不可靠  年久失修  有需求 在改
-- function QVerticalListViewImp:addItem( isAutoScroll )
--     -- body
--     -- local x,y = self.draglist:getListPos()
--     -- self._dragY = self._baseRootNode:getPositionY()
--     local tempBaseEndIndex = self._baseEndIndex
--     if self._maxItemNum then
--         if self._totalNumber + 1 > self._maxItemNum then
--             --删除 self._multiItems 个
--             local info = self._itemsInfo[self._baseStartIndex]
--             if info then
               
--                 self._curHeight = self._curHeight - info.size.height
--                 -- self.draglist:initListHeight(self.curHeight,false)
--                 self._baseRootY = self._baseRootY - info.size.height
--                 self._content:setPositionY(self._height - self._baseRootY)
               
--                 --回收节点
--                 if self._startIndex == self._baseStartIndex then
--                     self:addItemToCache(self._baseStartIndex, info)
--                     for k = 1,self._multiItems -1,1 do
--                         local tempInfo = self._itemsInfo[self._startIndex + k]
--                         if tempInfo then
--                             self:addItemToCache(self._startIndex + k, tempInfo)
--                         end
--                     end
--                     self._startIndex = self._startIndex + self._multiItems
--                 end

--             end
            
--             self._baseStartIndex = self._baseStartIndex + self._multiItems
--             self._baseEndIndex = self._baseEndIndex + 1
--             self._totalNumber = self._totalNumber + 1 - self._multiItems
--         else
--             self._totalNumber = self._totalNumber + 1
--             self._baseEndIndex = self._baseEndIndex + 1
--         end
--     else
--         self._totalNumber = self._totalNumber + 1
--         self._baseEndIndex = self._baseStartIndex + self._totalNumber - 1
--     end
--     --需要创建
--     -- print("-----  self._endIndex  ",self._endIndex,"tempBaseEndIndex  ",tempBaseEndIndex,"self._baseEndIndex  ",self._baseEndIndex)
--     if self._endIndex == tempBaseEndIndex then 
--         if self._endIndex == self._baseStartIndex -1 then
--             info = {}
--             self._itemsInfo[self._baseStartIndex] = info
--             local item = self:renderItem(self._baseStartIndex,info)
--             info.pos = ccp(0,0)
--             item:setPosition(info.pos)
--             self._curHeight = info.size.height - self._curOffset
--             self._endIndex = self._baseStartIndex

--         else
--             local endIndex = self._endIndex - (self._endIndex-1) % self._multiItems
--             local top = - (self._dragY - self._cacheLimit)
--             local bottom = -(self._dragY + self._cacheLimit + self._height)
--         -- print("-----  endIndex  ",endIndex,"self._baseEndIndex  ",self._baseEndIndex)

--             local tempHeight = self._itemsInfo[endIndex].pos.y
--             for i = endIndex, self._baseEndIndex, self._multiItems do
--                 local tempWidth = 0
--                 local nodeHeight = 0

--                 if tempHeight > bottom then
--                     for k= 0,self._multiItems -1 ,1 do
--                         local tempIndex = i + k
--                         local tempInfo = self._itemsInfo[tempIndex]
--                         if not tempInfo then
--                             tempInfo = {}
--                             self._itemsInfo[tempIndex] = tempInfo
--                             local item = self:renderItem(tempIndex,tempInfo)
--                             tempInfo.pos = ccp(tempWidth,tempHeight)
--                             item:setPosition(tempInfo.pos)
--                             -- self._curHeight = tempInfo.size.height - self._curOffset
--                         else
--                             tempWidth = tempWidth + tempInfo.size.width
--                         end
--                         if tempIndex == self._baseEndIndex then
--                             -- print("tempIndex  ",tempIndex)
--                             self._endIndex = tempIndex 
--                             if self._curHeight < math.abs(tempHeight - self._baseRootY) - self._curOffset then
--                                 self._curHeight = math.abs(tempHeight - self._baseRootY) - self._curOffset
--                             end
--                             break
--                         end
--                         nodeHeight = math.max(tempInfo.size.height,nodeHeight)
--                     end
--                     tempHeight = tempHeight - nodeHeight
--                 else
--                     self._endIndex = i - 1

--                     if self._endIndex > self._baseEndIndex then
--                         self._endIndex = self._baseEndIndex
--                     end
--                      -- print("---1  --- self._endIndex  ",self._endIndex,"self._baseEndIndex  ",self._baseEndIndex)
--                     if self._curHeight < math.abs(tempHeight - self._baseRootY) - self._curOffset then
--                         self._curHeight = math.abs(tempHeight - self._baseRootY) - self._curOffset 
--                     end

--                 end
                
--             end
--         end
--     end
    
--     self._isUp = true
--     self._listViewImp.onScroll(self)
   
--     if self._curHeight > self._height or self._ignoreCanDrag then
--         self._canDragY = true
--     end

--     if isAutoScroll then
--         self:startScrollToIndex(self._baseEndIndex, true)
--     end
-- end

function QVerticalListViewImp:scrollToIndexOnFrame( dt )
    -- body
    if self._startScrollToIndex then
        -- local speed = self._scrollToIndexSpeed
        -- self._dragY = self._baseRootNode:getPositionY()
        local dy = self._scrollToIndexSpeed
        local index = self._scrollToIndexTargetIndex
        -- print("-------------index  ",index,"self._startIndex  ",self._startIndex,"self._endIndex  ",self._endIndex)
        if  index >= self._startIndex and index <= self._endIndex then
            local info = self._itemsInfo[index]
            local y = info.pos.y - self._baseRootY 
            if self._scrollToIndexIsTail then 
                self._scrollToIndexTargetPos = (self._height + y - info.size.height)*-1
                if y > - self._height then
                    self._scrollToIndexTargetPos = 0
                end
            else
                self._scrollToIndexTargetPos = (y)*-1
                if y < self._height - self._curHeight then
                    self._scrollToIndexTargetPos = self._curHeight - self._height
                end
            end

            self._scrollToIndexTargetPos = self._scrollToIndexTargetPos + self._scrollToIndexPosOffset

            -- print("-------------self._scrollToIndexTargetPos  ",self._scrollToIndexTargetPos,"self._dragY  ",self._dragY)
            if self._scrollToIndexTargetPos - self._dragY > 0 then
                self._isUp = true
            elseif self._scrollToIndexTargetPos - self._dragY < 0 then
                self._isUp = false
            else
                -- print("-----return")
                self:stopScrollToIndex()
                self._listViewImp.scrollBarFadeOut(self)
                
                return
            end
        else
            if index > self._endIndex then
                self._isUp = true
            else
                self._isUp = false
            end

        end

        if self._scrollToIndexTargetPos ~= nil then
            -- zxs 保留偏移量
            local det = self._scrollToIndexTargetPos - self._dragY + self._curOriginOffset
            if  math.abs(det) < dy  then
                dy = math.abs(det)
            end
        end
        -- zxs 为0时无需移动
        if dy == 0 then
            self:stopScrollToIndex()
            return
        end
       -- print("--------------2------------------")
        if self._isUp then
            self._dragY = self._dragY + dy
        else
            self._dragY = self._dragY - dy
        end
        self:setBaseNodePosY(self._dragY)
        self._listViewImp.onScroll(self)
    end
end

--[[
    水平滚动
]]

function QHorizontalListViewImp:initListView(  )
    -- body
    -- print("self._baseEndIndex  ",self._baseEndIndex)
    self._dragX = 0
    self._lastDragX = 0
    -- self._dChangeBaseRootY = 0
    self._curWidth = 0
    self._canDragX = false
    self._baseRootX = 0
    self._cacheLimit = self._width * self._cacheCond
    local leftWidth = 0
    local rightWidth = 0
    
    local limit1,limit2
    local index 
    local tailIndex = self._tailIndex

    if tailIndex then

        if tailIndex > self._baseEndIndex then
            tailIndex = self._baseEndIndex
        end

        limit1 = self._width + self._cacheLimit + self._headIndexPosOffset
        limit2 = self._cacheLimit
        index = tailIndex + self._multiItems

    else
        limit1 = self._cacheLimit
        limit2 = self._width + self._cacheLimit
        index = self._headIndex
        if not index or index < self._baseStartIndex then
            index = self._baseStartIndex
        end

        if index > self._baseEndIndex then
            index = self._baseStartIndex
        end
    end

    if self._multiItems ~= 1 then
        index = index - (index -1)%self._multiItems
    end

  
    if self._totalNumber ~= 0 then
        for i = index - self._multiItems, self._baseStartIndex, -self._multiItems  do
            local tempWidth = 0
            local height = 0
            for k = 0,self._multiItems -1,1 do
                local tempIndex = i+k
                if tempIndex > self._totalNumber then
                    break
                end
                local info = {}
                self._itemsInfo[tempIndex] = info

                local item = self:renderItem(tempIndex,info)
                local posx = -leftWidth - info.size.width + self._contentOffsetX
                local posy = height + self._contentOffsetY

                tempWidth = math.max(info.size.width,tempWidth)
                height = height - info.size.height

                local offsetX = 0
                local offsetY = 0
                if info.offsetPos then
                    offsetX = info.offsetPos.x
                    offsetY = info.offsetPos.y
                end
                info.pos = ccp(posx + offsetX, posy + offsetY)
                -- print("posx,posy  1",posx,"   ",posy)
                item:setPosition(info.pos)
            end
            limit1 = limit1 - tempWidth
            leftWidth = leftWidth + tempWidth        
            if limit1 <= 0 then
                self._startIndex = i
                break;
            end
        end
    end

    if limit1 > 0 then
        self._startIndex = self._baseStartIndex
    end

    for i = index, self._baseEndIndex, self._multiItems do
        local tempWidth = 0
        local height = 0
        for k = 0,self._multiItems -1,1 do
            local tempIndex = i+k
            if tempIndex > self._baseEndIndex then
                break
            end

            local info = {}
            self._itemsInfo[tempIndex] = info

            local item = self:renderItem(tempIndex,info)
            local posx = rightWidth + self._contentOffsetX
            local posy = height + self._contentOffsetY

            tempWidth = math.max(info.size.width,tempWidth)
            height = height - info.size.height

            local offsetX = 0
            local offsetY = 0
            if info.offsetPos then
                offsetX = info.offsetPos.x
                offsetY = info.offsetPos.y
            end
            info.pos = ccp(posx + offsetX, posy + offsetY)
            -- print("posx,posy  2 ",posx,"   ",posy)

            item:setPosition(info.pos)
        end
        limit2 = limit2 - tempWidth
        rightWidth = rightWidth + tempWidth

        if limit2 <= 0 then
            self._endIndex = i + self._multiItems - 1
            if self._endIndex > self._baseEndIndex then
                self._endIndex = self._baseEndIndex
            end
            break;
        end
    end
    if limit2 > 0 then
        self._endIndex = self._baseEndIndex
    end

    if self._startIndex == self._baseStartIndex then
        leftWidth = leftWidth + self._curOriginOffset
    end

    if self._endIndex == self._baseEndIndex then
        rightWidth = rightWidth + self._curOffset
    end
    self._baseRootX = -leftWidth
    self._curWidth = leftWidth + rightWidth

    --
    if not tailIndex then
        if leftWidth >= self._headIndexPosOffset then
            leftWidth = leftWidth - self._headIndexPosOffset
            rightWidth = rightWidth + self._headIndexPosOffset
        else
            leftWidth = self._headIndexPosOffset
            rightWidth = rightWidth + leftWidth - self._headIndexPosOffset
        end
    end
    
    if tailIndex then
        if leftWidth > self._width then
            self._dragX = self._width - leftWidth
        end
    else
        if rightWidth < self._width then
            -- and self._startIndex ~= self._baseStartIndex
            if self._width - rightWidth < leftWidth  then
                self._dragX = self._width - self._curWidth
            end
        else
            if self._startIndex == self._baseStartIndex then
                self._dragX = -(leftWidth - self._curOriginOffset)
            else
                self._dragX = -leftWidth
            end
            
        end
    end
    -- print("self._dragX  ",self._dragX,"self._curWidth ",self._curWidth, "self._baseRootX  ",self._baseRootX,leftWidth,rightWidth, self._width)
    if self._curWidth >= self._width or self._ignoreCanDrag then
        self._canDragX = true
    end

    if self._autoCenter and self._curWidth < self._width and not self._ignoreCanDrag then
        local offset = self._autoCenterOffset or 0
        self._dragX = (self._width - self._curWidth)/2 + offset
    end

    self._baseRootNode:setPosition(ccp(self._dragX,self._height))
    self._content:setPositionX(-self._baseRootX)

    if self._enableShadow and not self._leftShadow and not self._rightShadow then
        self._listViewImp.initShadow(self)
    end
    self._listViewImp.showShadow(self)

    if self._enableScrollBar then
        self._listViewImp.initScrollBar(self)
    end

    self._listViewImp.setItemVisible(self)
end

function QHorizontalListViewImp:initShadow(  )
    -- self._leftShadow = CCLayerGradient:create(ccc4(58, 22, 0, 255), ccc4(0, 0, 0, 0), ccp(1, 0))
    self._leftShadow = CCScale9Sprite:create("ui/update_common/sp_list_uodown.png")
    self._leftShadow:setAnchorPoint(ccp(1, 0))
    self._leftShadow:setRotation(90)
    self._leftShadow:setPosition(ccp(0, 0))
    self._leftShadow:setPreferredSize(CCSize(self._height, self._shadowSize))

    -- self._rightShadow = CCLayerGradient:create(ccc4(58, 22, 0, 255), ccc4(0, 0, 0, 0), ccp(-1, 0))
    self._rightShadow = CCScale9Sprite:create("ui/update_common/sp_list_uodown.png")
    self._rightShadow:setAnchorPoint(ccp(0, 0))
    self._rightShadow:setRotation(-90)
    self._rightShadow:setPosition(ccp(self._width, 0))
    self._rightShadow:setPreferredSize(CCSize(self._height, self._shadowSize))

    self:addChild(self._leftShadow)
    self:addChild(self._rightShadow)

end
function QHorizontalListViewImp:showShadow(  )
    -- body
    if self._enableShadow then
        if self._canDragX then
            if self._dragX < 0 then
                if not self._isRollBack then
                    self._leftShadow:setVisible(true)
                end
            else
                self._leftShadow:setVisible(false)
            end
            if self._dragX > self._width - self._curWidth then
                if not self._isRollBack then
                    self._rightShadow:setVisible(true)
                end
            else
                self._rightShadow:setVisible(false)
            end
        else
            self._leftShadow:setVisible(false)
            self._rightShadow:setVisible(false)
        end
    end
end

function QHorizontalListViewImp:initScrollBar(  )

    self._scrollBarIsFadeIn = false
    self._scrollBarIsFadeOut = false
    if not self._scrollBarParentNode and not self._scrollBar then
        local parentNode = CCNode:create()
        local scrollBarBg,scrollBar

        scrollBarBg = CCScale9Sprite:create("ui/common/xialatiao_hei.png") 
        scrollBar = CCScale9Sprite:create("ui/common/gundong.png")
        parentNode:addChild(scrollBarBg)
        parentNode:addChild(scrollBar)
        scrollBarBg:setRotation(90)
        scrollBarBg:setAnchorPoint(1,0)
        scrollBarBg:setContentSize(CCSizeMake(5,self._width))

        scrollBar:setAnchorPoint(1,0)
        scrollBar:setRotation(90)

        parentNode:setPosition(self._scrollBarPos)
        parentNode:setCascadeOpacityEnabled(true)
        self:addChild(parentNode)

        self._scrollBarBg = scrollBarBg
        self._scrollBar = scrollBar
        self._scrollBarParentNode = parentNode
    end

    local rt = self._scrollBar:boundingBox()
    self._scrollBarWidth = rt.size.width
    self._scrollBarBaseScaleX = self._scrollBar:getScaleX()
    local angle = self._scrollBar:getRotation()
    if angle == 90 or angle == 270 then
        self._scrollBarScaleReverse = true
    end
    self._scrollBarParentNode:setOpacity(0)
end

function QHorizontalListViewImp:scrollBarFadeIn(  )
    -- body
    if self._enableScrollBar and self._canDragX then
        if self._scrollBarParentNode:getOpacity() ~= 255 and self._scrollBarIsFadeIn == false then
            self._scrollBar:setScaleY(1)
            if self._scrollBarIsFadeOut then
                self._scrollBarParentNode:stopAllActions()
                self._scrollBarIsFadeOut = false
            end
            self._scrollBarIsFadeIn = true
            local fade = CCFadeIn:create(0.5)
            local func = CCCallFunc:create(function()
                self._scrollBarIsFadeIn = false
            end)
            local s1 = CCSequence:createWithTwoActions(fade , func)
            self._scrollBarParentNode:runAction(s1)
        end
        if self._dragX > 0 then
            self._scrollBar:setPositionX(0)
            if self._scrollBarScaleReverse then
                self._scrollBar:setScaleY((1 - math.abs(self._dragX/self._width)) * self._scrollBarBaseScaleX)
            else
                self._scrollBar:setScaleX((1 - math.abs(self._dragX/self._width)) * self._scrollBarBaseScaleX)
            end
        elseif self._dragX < self._width - self._curWidth then
            local scaleX = 1 - math.abs((self._dragX - self._width + self._curWidth)/self._width)
            if self._scrollBarScaleReverse then
                self._scrollBar:setScaleY(scaleX * self._scrollBarBaseScaleX)
            else
                self._scrollBar:setScaleX(scaleX * self._scrollBarBaseScaleX)
            end
            self._scrollBar:setPositionX(self._width - self._scrollBarWidth * scaleX) 
        else
            self._scrollBar:setPositionX((self._width - self._scrollBarWidth) * (math.abs(self._dragX/(self._width - self._curWidth))))
        end
    end
end


function QHorizontalListViewImp:scrollBarFadeOut(  )
    -- body

    if self._enableScrollBar and self._scrollBarIsFadeOut == false then
        if self._scrollBarIsFadeIn then
            self._scrollBarParentNode:stopAllActions()
            self._scrollBarIsFadeIn = false
        end
        self._scrollBarIsFadeOut = true
        local fade = CCFadeOut:create(0.5)
        local func = CCCallFunc:create(function()
            self._scrollBarIsFadeOut = false
        end)
        local s1 = CCSequence:createWithTwoActions(fade , func)
        self._scrollBarParentNode:runAction(s1)
    end
end

function QHorizontalListViewImp:startSpeedScheduler(  )
    -- body
    self._speedScheduler = true
    self._speedX = 0
    self._speedCountX = 0
    self._lastDragX = self._dragX
end

function QHorizontalListViewImp:stopSpeedScheduler(  )
    -- body
    self._speedScheduler = nil
    self._lastDragX = nil
    self._speedCountX = nil
end

function QHorizontalListViewImp:getSpeedOnFrame( dt )
    -- body
    if self._speedScheduler then
        local dx = self._dragX - self._lastDragX 
        if self._dChangeBaseRootX then
            dx = dx - self._dChangeBaseRootX
            self._dChangeBaseRootX = nil
        end
        local speedX = dx/dt
        if math.abs(speedX) < 1000 then
            self._speedCountX = self._speedCountX + 1
        else
            self._speedCountX = 0
        end
        if self._speedCountX > 12 then
            self._speedX = 0
        else
            self._speedX = (self._speedX + speedX)/2
        end
        self._lastDragX = self._dragX
    end
end



function QHorizontalListViewImp:scrollToPosOnFrame(dt)
    -- body
    if self._startScrollToPos then
        --CCEaseBackOut
        local tempPercent,percent,dPercent
        self._scrollTime = self._scrollTime + dt

        local ft = self._scrollTime/self._scrollToPosTotalTime > 1 and 1 or self._scrollTime/self._scrollToPosTotalTime
        if self._isRollBack then
            local tempPercent = ft - 1
            percent = tempPercent*tempPercent*((1.70158 + 1)*tempPercent + 1.70158) + 1

        else
            percent = ft >= 1 and 1 or 1 - math.pow(2, -10 * ft)
        end
        dPercent = percent - self._lastPercent
        self._lastPercent = percent
        local dx = self._targetDistance * dPercent
       
        if dx < 0 then
            self._isLeft = true
            if dx < -self._width then
                dx = -self._width
            end
        else
            self._isLeft = false
            if dx > self._width then
                dx = self._width
            end
        end
        self._dragX = self._dragX + dx

        self:setBaseNodePosX(self._dragX)
        self._listViewImp.onScroll(self)
        if not self._isRollBack then
            if self._dragX > 0  then
                self:startScrollToPosScheduler(0 - self._dragX,0.3,true)
            elseif self._dragX < self._width - self._curWidth then
                self:startScrollToPosScheduler(self._width - self._curWidth - self._dragX ,0.3,true)
               
            elseif self._scrollTime >= self._scrollToPosTotalTime then
                self:stopScrollToPosScheduler()
            end
        else
            if self._scrollTime >= self._scrollToPosTotalTime then
                self:stopScrollToPosScheduler()
            end
        end

    end
end

function QHorizontalListViewImp:setItemVisible(  )
    local viewLeft = - self._dragX
    local viewRight = -self._dragX + self._width
    for i = self._startIndex, self._endIndex, self._multiItems do
        local info = self._itemsInfo[i]
        if info.pos.x + info.size.width - self._baseRootX < viewLeft or info.pos.x  - self._baseRootX > viewRight then
            for k = 0,self._multiItems - 1,1 do
                local tempIndex = i + k
                if tempIndex > self._endIndex then
                    break;
                end
                local tempInfo = self._itemsInfo[i + k]
                tempInfo.item:setVisible(false)
            end
        else
            for k = 0,self._multiItems - 1,1 do
                local tempIndex = i + k
                if tempIndex > self._endIndex then
                    break;
                end
                local tempInfo = self._itemsInfo[i + k]
               tempInfo.item:setVisible(true)
            end 
        end
    end
end


function QHorizontalListViewImp:onScroll(  )
    -- body
    self._listViewImp.showShadow(self)
    self._listViewImp.scrollBarFadeIn(self)

    local left = -self._cacheLimit - self._dragX
    local right = -self._dragX + self._cacheLimit + self._width
    -- print("left  ",left,"right ",right, "self._isLeft  ",self._isLeft)
    -- print("self._startIndex  ",self._startIndex,"self._endIndex ",self._endIndex,"self._dragX  ",self._dragX)
    --向上滑动
    if self._isLeft then

        if self._endIndex == self._baseEndIndex then
            self._listViewImp.setItemVisible(self)
            return
        end

        for i = self._startIndex,self._endIndex,self._multiItems do
            local info = self._itemsInfo[i]
            if info then
                local nextItemX = info.pos.x + info.size.width
                  -- print("left   ",left, "nextItemX " ,nextItemX,"nextItemX - self._baseRootX ",nextItemX - self._baseRootX)
                --超过上边界 回收掉
                if left > nextItemX - self._baseRootX then
                    -- print("recycle 1 index ",i)
                    self:addItemToCache(i, info)
                    for k = 1,self._multiItems -1 do
                        local tempIndex = i + k
                        if tempIndex > self._endIndex then
                            break
                        end
                        local tempInfo = self._itemsInfo[tempIndex]
                        -- print("recycle  1 index ",tempIndex)
                        self:addItemToCache(tempIndex, tempInfo)
                    end
                else
                    self._startIndex = i
                    break
                end
            else
                print (">>> onScroll 1 err info is nil  index ",i)
                --info 为空 表示尚未有该index的信息
            end
        end
        -- local endIndex = math.ceil(self._baseEndIndex / self._multiItems) * self._multiItems
         --  渲染新的节点 
        local endIndex = self._endIndex - (self._endIndex-1) % self._multiItems

        for i = endIndex, self._baseEndIndex, self._multiItems do
        -- print("i   ",i,"self._baseEndIndex   ",self._baseEndIndex)
            local preInfo = self._itemsInfo[i]
            if preInfo then
                local nextItemX = preInfo.pos.x + preInfo.size.width 
                if nextItemX - self._baseRootX < right and i < self._baseEndIndex then
                    --渲染新的节点
                    local tempHeight = 0
                    for k = 0, self._multiItems-1 do
                        local tempIndex = i + self._multiItems + k
                        if tempIndex > self._baseEndIndex then
                            break;
                        end
                        -- print("create 1 index ",tempIndex)
                        local info = self._itemsInfo[tempIndex]
                        if not info then
                            info = {}
                            self._itemsInfo[tempIndex] = info
                        end
                      
                        local item = self:renderItem(tempIndex,info)
                        local offsetX = 0
                        local offsetY = 0
                        if info.offsetPos then
                            offsetX = info.offsetPos.x
                            offsetY = info.offsetPos.y
                        end
                        info.pos = ccp(nextItemX + self._contentOffsetX, tempHeight + self._contentOffsetY + offsetY)
                        tempHeight = tempHeight - info.size.height
                     
                        item:setPosition(info.pos)
                    end
                    
                else
                    self._endIndex = i + self._multiItems - 1
                    if self._endIndex > self._baseEndIndex then
                        self._endIndex = self._baseEndIndex
                    end
                    
                    --判断是否需要增加listview的高度
                    if self._curWidth < math.abs(nextItemX - self._baseRootX)then

                        if self._endIndex == self._baseEndIndex then
                            self._curWidth = math.abs(nextItemX - self._baseRootX) + self._curOffset
                        else
                            self._curWidth = math.abs(nextItemX - self._baseRootX)
                        end
                       
                    end
                    break;
                end
            else
                print (">>> onScroll 2 err info is nil  index ",i)
                --info 为空 表示尚未有该index的信息
            end
        end
    else
        if self._startIndex == self._baseStartIndex then
            self._listViewImp.setItemVisible(self)
            return
        end
        
        local endIndex = self._endIndex - (self._endIndex-1) % self._multiItems
        for i = endIndex , self._startIndex,-self._multiItems do
            local info = self._itemsInfo[i]
            if info then
                --负数比较
                if info.pos.x - self._baseRootX > right then
                    --超过下边界 回收掉
                    -- print("recycle 2 index ",i)
                    self:addItemToCache(i, info)
                    for k = 1,self._multiItems-1 do
                        if i + k <= self._baseEndIndex then
                            local tempInfo = self._itemsInfo[i + k]
                            -- print("recycle 2 index ",i - k)
                            self:addItemToCache(i + k, tempInfo)
                        end
                    end
                else
                    self._endIndex = i + self._multiItems - 1
                    if self._endIndex > self._baseEndIndex then
                        self._endIndex = self._baseEndIndex
                    end
                    break;
                end
            else
                print (">>> onScroll 3 err info is nil  index ",i)
                --info 为空 表示尚未有该index的信息
            end
        end

        for i = self._startIndex,self._baseStartIndex,-self._multiItems do
            local preInfo = self._itemsInfo[i]
            if preInfo then
                if left < preInfo.pos.x - self._baseRootX and i > self._baseStartIndex then
                    local tempHeight = 0
                    for k = self._multiItems,1, -1 do
                        local tempIndex = i - k
                        if tempIndex < self._baseStartIndex then
                            -- print("error  tempIndex < self._baseStartIndex")
                            break;
                        end
                        -- print("create 2 index ",tempIndex)
                        local info = self._itemsInfo[tempIndex]
                        if not info then
                            info = {}
                            self._itemsInfo[tempIndex] = info
                        end
                      
                        local item = self:renderItem(tempIndex,info)
                        local offsetX = 0
                        local offsetY = 0
                        if info.offsetPos then
                            offsetX = info.offsetPos.x
                            offsetY = info.offsetPos.y
                        end
                        info.pos = ccp(preInfo.pos.x - info.size.width + self._contentOffsetX, tempHeight + self._contentOffsetY + offsetY)
                        -- print("preInfo.pos.x - info.size.width  ",preInfo.pos.x - info.size.width)
                        tempHeight = tempHeight - info.size.height
                        item:setPosition(info.pos)
                    end
                  
                else
                    self._startIndex = i
                    if preInfo.pos.x < self._baseRootX then
                        local dtx= self._baseRootX - preInfo.pos.x
                        if self._startIndex == self._baseStartIndex then
                            self._baseRootX = preInfo.pos.x - self._curOriginOffset
                            dtx = dtx + self._curOriginOffset
                        else
                            self._baseRootX = preInfo.pos.x
                        end
                        self._curWidth = self._curWidth + dtx   
                        self._dragX = self._dragX - dtx
                        self._content:setPositionX(-self._baseRootX)
                        self:setBaseNodePosX(self._dragX)
                        --记录一次改变 _baseRootX  避免计算速度时 错误
                        self._dChangeBaseRootY = -dtx
                    end
                    break
                end
            else
                print (">>> onScroll 4 err info is nil  index ",i)
            end
        end
           
    end
    self._listViewImp.setItemVisible(self)
end



function QHorizontalListViewImp:checkNeedScroll(  )
   
    if self._canDragX then
        if self._dragX > 0 or self._width >= self._curWidth then
            self:startScrollToPosScheduler(0 - self._dragX,0.3,true)
            if self._scrollBeginCallBack then
                self._scrollBeginCallBack()
            end
        elseif self._dragX < self._width - self._curWidth then
            self:startScrollToPosScheduler(self._width - self._curWidth - self._dragX,0.3,true)
            if self._scrollEndCallBack then
                self._scrollEndCallBack()
            end
        elseif self._speedX and self._speedX ~= 0 then
            if self._scrollMogveinggCallback then
                self._scrollMogveinggCallback(self._isLeft,self._dragX)
            end            
            local distance = self._speedX / 4
            self:startScrollToPosScheduler(distance,2)
        else
            if self._scrollMogveinggCallback then
                self._scrollMogveinggCallback(self._isLeft,self._dragX)
            end
            self._listViewImp.scrollBarFadeOut(self)
        end
    end
end


function QHorizontalListViewImp:checkCanTouch( )
    -- body
    if self._shieldTouch then
        return false
    end
    if self._startScrollToIndex then
        return false
    end
    if self._scrollToPosCanNotTouchStop then
        return false
    end

    return true
end


function QHorizontalListViewImp:onTouchBegin(x, y)
    if not self._rect:containsPoint(self:convertToNodeSpace(ccp(x,y))) then
        return false
    end
    self._dragMode = false
    self._curGesture = nil
    -- self._dragX = self._baseRootNode:getPositionX()

    self._canTouch = self._listViewImp.checkCanTouch(self)
    if not self._canTouch then
        return
    end
      
   
    self:stopScrollToPosScheduler()

    self:calculateTouchIndex(x,y)
    self:doTouchBegin(x, y)
    self:doPressIn(x,y)

    self._listViewImp.startSpeedScheduler(self)
    self._lastPressX = x
    self._lastPressY = y
    self._firstPressPosX = x
    self._firstPressPosY = y
    self:startLongPressScheduler()
    
    return true
end



function QHorizontalListViewImp:onTouchMove(x, y)
    if not self._canTouch or not self._touchBeganRet then
        return
    end

    local dx = x - self._lastPressX
    local dy = y - self._lastPressY
    -- local now = q.time()
    -- print("dx ",dx,"dx ",dx,"dt ",now - self._lastTime)
    -- self._lastTime = now
    
    if not self._dragMode then
        local x2 = (x - self._firstPressPosX) * (x - self._firstPressPosX)
        local y2 = (y - self._firstPressPosY) * (y - self._firstPressPosY)

        local dis = math.sqrt( x2 + y2 )
        if dis > 10 then
            if x2 >= y2 then
                self._curGesture = QListView.GESTURE_H
            else
                self._curGesture = QListView.GESTURE_V
            end
            self:doCancelPressIn(x,y)
            self._curTouchNodeName = nil
            self:stopLongPressScheduler()
        end
        if dis > 10 and self._canDragX and not self._dragMode then
            self._dragMode = true
        end
    end

    self:doTouchMove(x, y)
    
    if self._canNotTouchMove then
        return
    end
    if self._dragMode then
        --阴影显示逻辑
        local coefficient = 1
        if self._dragX < self._width - self._curWidth then
            coefficient = self._endRate * ( 1 - ( (self._width - self._curWidth) - self._dragX ) / self._width )
        elseif self._dragX > 0 then
            coefficient = self._endRate * ( 1 - (self._dragX) / self._width )
        end
        -- print("self._dragX ",self._dragX, "coefficient ",coefficient , "self._curWidth ",self._curWidth, "self._width ",self._width)
        dx = dx * coefficient
        self._dragX = self._dragX + dx
        
        --xurui: self._endRate == 0 时，滑动到边界之后不允许再滑动
        if self._endRate == 0 then
            if self._dragX >= self._width - self._curWidth then
                self._dragX = self._width - self._curWidth
            elseif self._dragX <= 0 then
                self._dragX = 0
            end
        end
        
        self:setBaseNodePosX(self._dragX)
        if dx < 0 then
            self._isLeft = true 
        else
            self._isLeft = false 
        end
        self._listViewImp.onScroll(self)
    end
    self._lastPressX = x
    self._lastPressY = y
end

function QHorizontalListViewImp:onTouchEnd(x, y)

    if not self._canTouch or not self._touchBeganRet then
        return
    end
    self:doTouchEnd(x, y)
    self:doCancelPressIn(x,y)
    self:doClickIn(x,y)
   
    self._dragMode = false
    self._curGesture = nil
    self._listViewImp.stopSpeedScheduler(self)
    self._listViewImp.checkNeedScroll(self)
    self:stopLongPressScheduler()
    self:resetTouchIndex()
end

function QHorizontalListViewImp:clearAllItems( isCleanUp )
    -- body
    self._listViewImp.stopSpeedScheduler(self)
    self:stopLongPressScheduler()
    self:stopScrollToPosScheduler()
    self:stopScrollToIndex()
    -- print("1111------- self._startIndex ",self._startIndex,"self._endIndex ",self._endIndex)
    if isCleanUp then
        self._content:removeAllChildren()
        self._cacheNodes = {}
    else
        for i = self._startIndex,self._endIndex do
            local info = self._itemsInfo[i]
            self:addItemToCache(i, info)
        end
    end
    self._canDragX = false
    self._curWidth = 0
    self._baseStartIndex = 1
    self._baseEndIndex = 0
    self._totalNumber = 0
    self._startIndex = self._baseStartIndex
    self._endIndex = self._baseEndIndex
    self._dragX = 0
    self._itemsInfo = {}
    self:clearAllClickHandler()
    self:clearAllTouchHandler()
    self._curTouchIndex = nil
    self._curTouchNodeName = nil
    self:setBaseNodePosX(self._dragX)
    self._startScrollToIndex = nil
end
---- 改动了一些东西  这个函数不可靠  年久失修  有需求 在改
-- function QHorizontalListViewImp:addItem( isAutoScroll )
--     -- body
--     -- local x,y = self.draglist:getListPos()
--     -- self._dragX = self._baseRootNode:getPositionX()
--     local tempBaseEndIndex = self._baseEndIndex
--     if self._maxItemNum then
--         if self._totalNumber + 1 > self._maxItemNum then
--             --删除 self._multiItems 个
--             local info = self._itemsInfo[self._baseStartIndex]
--             if info then
               
--                 self._curWidth = self._curWidth - info.size.width
--                 -- self.draglist:initListHeight(self.curHeight,false)
--                 self._baseRootX = self._baseRootX + info.size.width
--                 self._content:setPositionX( -self._baseRootX)
               
--                 --回收节点
--                 if self._startIndex == self._baseStartIndex then
--                     self:addItemToCache(self._baseStartIndex, info)
--                     for k = 1,self._multiItems -1,1 do
--                         local tempInfo = self._itemsInfo[self._startIndex + k]
--                         if tempInfo then
--                             self:addItemToCache(self._startIndex + k, tempInfo)
--                         end
--                     end
--                     self._startIndex = self._startIndex + self._multiItems
--                 end

--             end
            
--             self._baseStartIndex = self._baseStartIndex + self._multiItems
--             self._baseEndIndex = self._baseEndIndex + 1
--             self._totalNumber = self._totalNumber + 1 - self._multiItems
--         else
--             self._totalNumber = self._totalNumber + 1
--             self._baseEndIndex = self._baseEndIndex + 1
--         end
--     else
--         self._totalNumber = self._totalNumber + 1
--         self._baseEndIndex = self._baseStartIndex + self._totalNumber - 1
--     end
--     --需要创建
--     -- print("-----  self._endIndex  ",self._endIndex,"tempBaseEndIndex  ",tempBaseEndIndex,"self._baseEndIndex  ",self._baseEndIndex)
--     if self._endIndex == tempBaseEndIndex then 
--         if self._endIndex == self._baseStartIndex -1 then
--             info = {}
--             self._itemsInfo[self._baseStartIndex] = info
--             local item = self:renderItem(self._baseStartIndex,info)
--             info.pos = ccp(0,0)
--             item:setPosition(info.pos)
--             self._curWidth = info.size.width - self._curOffset
--             self._endIndex = self._baseStartIndex

--         else
--             local endIndex = self._endIndex - (self._endIndex-1) % self._multiItems
--             local left = -self._cacheLimit - self._dragX
--             local right = -self._dragX + self._cacheLimit + self._width
--         -- print("-----  endIndex  ",endIndex,"self._baseEndIndex  ",self._baseEndIndex)

--             local tempWidth = self._itemsInfo[endIndex].pos.x
--             for i = endIndex, self._baseEndIndex, self._multiItems do
--                 local tempHeight = 0
--                 local nodeWidth = 0

--                 if tempWidth < right then
--                     for k= 0,self._multiItems -1 ,1 do
--                         local tempIndex = i + k
--                         local tempInfo = self._itemsInfo[tempIndex]
--                         if not tempInfo then
--                             tempInfo = {}
--                             self._itemsInfo[tempIndex] = tempInfo
--                             local item = self:renderItem(tempIndex,tempInfo)
--                             tempInfo.pos = ccp(tempWidth,tempHeight)
--                             item:setPosition(tempInfo.pos)
                          
--                         else
--                             tempHeight = tempHeight - tempInfo.size.height
--                         end
--                         if tempIndex == self._baseEndIndex then
--                             -- print("tempIndex  ",tempIndex)
--                             self._endIndex = tempIndex 
--                             if self._curWidth < math.abs(tempWidth - self._baseRootX) - self._curOffset then
--                                 self._curWidth = math.abs(tempWidth - self._baseRootX) - self._curOffset
--                             end
--                             break
--                         end
--                         nodeWidth = math.max(tempInfo.size.width,nodeWidth)
--                     end
--                     tempHeight = tempWidth + nodeWidth
--                 else
--                     self._endIndex = i - 1

--                     if self._endIndex > self._baseEndIndex then
--                         self._endIndex = self._baseEndIndex
--                     end
--                      -- print("---1  --- self._endIndex  ",self._endIndex,"self._baseEndIndex  ",self._baseEndIndex)
--                     if self._curWidth < math.abs(tempHeight - self._baseRootX) - self._curOffset then
--                         self._curWidth = math.abs(tempHeight - self._baseRootX) - self._curOffset 
--                     end

--                 end
                
--             end
--         end
--     end
    
--     self._isLeft = true
--     self._listViewImp.onScroll(self)
   
--     if self._curWidth > self._width then
--         self._canDragX = true
--     end

--     if isAutoScroll then
--         self:startScrollToIndex(self._baseEndIndex, true)
--     end
-- end

function QHorizontalListViewImp:scrollToIndexOnFrame( dt )
    -- body
    if self._startScrollToIndex then
        -- local speed = self._scrollToIndexSpeed
        -- self._dragX = self._baseRootNode:getPositionX()
        local dx = self._scrollToIndexSpeed
        local index = self._scrollToIndexTargetIndex
        if  index >= self._startIndex and index <= self._endIndex then
            local info = self._itemsInfo[index]
            local x = info.pos.x - self._baseRootX
            if self._scrollToIndexIsTail then 
                self._scrollToIndexTargetPos = (x  + info.size.width - self._width)*-1
                if x + info.size.width < self._width then
                    self._scrollToIndexTargetPos = 0
                end
            else
                self._scrollToIndexTargetPos = -x
                if x > self._curWidth - self._width then
                    self._scrollToIndexTargetPos = self._width - self._curWidth 
                end
            end
            
            self._scrollToIndexTargetPos = self._scrollToIndexTargetPos + self._scrollToIndexPosOffset

            if self._scrollToIndexTargetPos - self._dragX < 0 then
                self._isLeft = true
            elseif self._scrollToIndexTargetPos - self._dragX > 0 then
                self._isLeft = false
            else
                -- print("-----return")
                self:stopScrollToIndex()
                self._listViewImp.scrollBarFadeOut(self)
                return
            end
        else
            if index > self._endIndex then
                self._isLeft = true
            else
                self._isLeft = false
            end

        end

        if self._scrollToIndexTargetPos ~= nil then
            local det = self._scrollToIndexTargetPos - self._dragX + self._curOriginOffset
            if  math.abs(det) < dx  then
                dx = math.abs(det)
            end
        end
        if dx == 0 then
            self:stopScrollToIndex()
            return
        end

        if self._isLeft then
            self._dragX = self._dragX - dx
        else
            self._dragX = self._dragX + dx
        end
        -- print("-------------index  ",index,"self._startIndex  ",self._startIndex,"self._endIndex  ",self._endIndex,"  self._dragX  ",self._dragX,"dx  ",dx)

        self:setBaseNodePosX(self._dragX)
        self._listViewImp.onScroll(self)
    end
end



return QListView