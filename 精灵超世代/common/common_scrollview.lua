-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      自动意义的scrollview
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
local table_insert = table.insert
local table_remove = table.remove
local table_sort = table.sort
local math_floor = math.floor

CommonScrollViewLayout = class("CommonScrollViewLayout", function()
    return ccui.Layout:create()
end)

--==============================--
--desc:构建一个自动意义滚动容器
--time:2018-07-12 11:11:44
--@parent:
--@pos:
--@dir:
--@start_pos:
--@size:
--@setting:
--@ap:
--@return 
--==============================--
function CommonScrollViewLayout:ctor(parent, pos, dir, start_pos, size, setting, ap)
    self.parent = parent
    self.pos = pos or cc.p(0, 0)
    self.dir = dir or ScrollViewDir.vertical
    self.start_pos = start_pos or ScrollViewStartPos.top
    self.size = size or cc.size(100, 100)
    self.ap = ap or cc.p(0, 0)
    self.total_cache_list = {}                          -- 因为滚动容器可能每次存放不同的对象，因为多标签的时候
    self.item_click_callback = nil
    self.extend = nil                                   -- 扩展参数
    self.cur_item_class = nil                           -- 当前显示的对象
    self.is_radian = false
    self.is_scrolling = false
    self.cur_min_index = 0
    self:analysisSetting(setting)
    self:createRootWnd()
end

function CommonScrollViewLayout:createRootWnd()
    self:setContentSize(self.size)
    if not tolua.isnull(self.parent) then
        self.parent:addChild(self)
    end
    self:setPosition(self.pos)
    self:setAnchorPoint(self.ap)
    
    self.scroll_view = createScrollView(self.size.width, self.size.height, 0, 0, self, self.dir) 
    self.container = self.scroll_view:getInnerContainer() 
    self:registerEvent()
end

--==============================--
--desc:注册事件
--time:2018-07-12 10:33:12
--@return 
--==============================--
function CommonScrollViewLayout:registerEvent()
    if self.need_dynamic == true then
        if self.dir == ScrollViewDir.vertical then
            self.scroll_view:addEventListener(function(sender, eventType)
                if eventType == ccui.ScrollviewEventType.containerMoved then
                    self:checkRectIntersectsRect()
                elseif eventType == ccui.ScrollviewEventType.bounceBottom then
                    if self.scrollToBottom_callback then
                        self.scrollToBottom_callback()
                    end
                end
            end)
        end
    end
end

function CommonScrollViewLayout:setClickEnabled(status)
    self.scroll_view:setTouchEnabled(status)
end

--==============================--
--desc:移动的过程中盘点是否不再可视范围,不再的时候移除掉,放到对象池,并且准备下一次创建
--time:2018-07-20 12:13:25
--@return 
--==============================--
function CommonScrollViewLayout:checkRectIntersectsRect()
    if self.need_dynamic == false then return end

    if self.dir == ScrollViewDir.vertical then
        self:checkOverShowByVertical()
    elseif self.dir == ScrollViewDir.horizontal then
        self:checkOverShowByHorizontal()
    end
end

--==============================--
--desc:竖直方向的监测判断
--time:2018-07-20 03:11:13
--@return 
--==============================--
function CommonScrollViewLayout:checkOverShowByVertical()
    if self.cur_item_class == nil then return end
    if self.data_list == nil or next(self.data_list) == nil then return end
    local cache_type_list = self.total_cache_list[self.cur_item_class]
    if cache_type_list == nil then return end
    local item_list = cache_type_list.item
    local pool_list = cache_type_list.pool
    if item_list == nil then return end

    local container_y = self.container:getPositionY()
    if self.last_pos_y == nil then
        self.last_pos_y = container_y 
    end
    local size = self.container:getContentSize()

    local item = nil
    local container_y_abs = math.abs( container_y )

    --移动的时候监听
    if self.item_move_callback then
        local index = math_floor(container_y_abs/(self.item_height+self.space_y))
        self.item_move_callback(index)
    end
    -- 先移除不在可视的
    for k, item in pairs(item_list) do
        local need_clear = false
        local item_y = item:getPositionY()
        if container_y > 0 then
            if item_y > (self.size.height - container_y + self.item_height) then
                need_clear = true
            end
        else
            if item_y  < (container_y_abs - self.item_height) then
                need_clear = true
            elseif item_y > (container_y_abs + self.size.height + self.item_height) then
                need_clear = true
            end
        end
        if need_clear == true then
            if item.suspendAllActions then
                item:suspendAllActions()
                item:setVisible(false)
            end
            table.insert(pool_list, item)
            item_list[k] = nil
        end
    end
    self:supplementItemList(item_list, self.last_pos_y, container_y)
    self.last_pos_y = container_y 
end

--==============================--
--desc:横方向的监测判断
--time:2018-07-20 03:11:13
--@return 
--==============================--
function CommonScrollViewLayout:checkOverShowByHorizontal()
    if self.cur_item_class == nil then return end
    if self.data_list == nil or next(self.data_list) == nil then return end
    local cache_type_list = self.total_cache_list[self.cur_item_class]
    if cache_type_list == nil then return end
    local item_list = cache_type_list.item
    local pool_list = cache_type_list.pool
    if item_list == nil then return end

    local container_x = self.container:getPositionX()
    if self.last_pos_x == nil then
        self.last_pos_x = container_x 
    end
    local size = self.container:getContentSize()

    local item = nil
    local container_x_abs = math.abs( container_x )
    -- 先移除不在可视的
    for k, item in pairs(item_list) do
        local need_clear = false
        local item_x = item:getPositionX()
        if container_x > 0 then
            if item_x > (self.size.width - container_x + self.item_width) then
                need_clear = true
            end
        else
            if item_x  < (container_x_abs - self.item_width) then
                need_clear = true
            elseif item_x > (container_x_abs + self.size.width + self.item_width) then
                need_clear = true
            end
        end
        if need_clear == true then
            if item.suspendAllActions then
                item:suspendAllActions()
                item:setVisible(false)
            end
            table.insert(pool_list, item)
            item_list[k] = nil
        end
    end
    self:supplementItemList(item_list, self.last_pos_x, container_x)
    self.last_pos_x = container_x 
end

--==============================--
--desc:补充需要创建的
--time:2018-07-20 03:50:02
--@return 
--==============================--
function CommonScrollViewLayout:supplementItemList(item_list, last_y, cur_y)
    if item_list == nil or tableLen(item_list) == 0 then return end
    local cur_table_num = tableLen(item_list)

    if cur_table_num < self.max_sum then
        local min_index = 0
        local max_index = 0
        for k,item in pairs(item_list) do
            if min_index == 0 then
                min_index = item.tmp_index
            end
            if max_index == 0 then
                max_index = item.tmp_index
            end
            if min_index >= item.tmp_index then
                min_index = item.tmp_index 
            end
            if max_index <= item.tmp_index then
                max_index = item.tmp_index 
            end
        end
        if cur_y > last_y then -- 向上,那么就创建到下面
            for i=1,(self.max_sum-cur_table_num) do
                self:createList(self.data_list[max_index+i])
            end
        else
            for i=1,(self.max_sum - cur_table_num) do
                if (min_index -i) > 0 then
                    self:createList(self.data_list[min_index-i])
                end
            end 
        end
    end
end

function CommonScrollViewLayout:setSwallowTouches(status)
    self.scroll_view:setSwallowTouches(status)
end

function CommonScrollViewLayout:setBounceEnabled( status )
    self.scroll_view:setBounceEnabled(status)
end
--==============================--
--desc:滚动容器移动到指定位置
--time:2018-07-12 10:34:41
--@pos:
--@return 
--==============================--
function CommonScrollViewLayout:updateMove(pos)
    local target_pos = self:checkPosition(pos.x, pos.y)
    local move_to = cc.MoveTo:create(0.1, cc.p(target_pos.x, target_pos.y))
    local ease_out = cc.EaseSineOut:create(move_to)
    self.container:runAction(cc.Sequence:create(ease_out))
end

--==============================--
--desc:跳转指定位置
--time:2018-07-12 11:07:44
--@pos:
--@time:
--@callback:
--@return 
--==============================--
function CommonScrollViewLayout:jumpToMove(pos, time, callback)
	local target_pos = self:checkPosition(pos.x, pos.y)
	time = time or 1
	local move_to = cc.MoveTo:create(time, cc.p(target_pos.x, target_pos.y))
	self.container:runAction(cc.Sequence:create(move_to, cc.CallFunc:create(function()
		if callback then
			callback()
		end
	end)))
end 

function CommonScrollViewLayout:getCurContainerPosY()
    if self.container and not tolua.isnull(self.container) then
        return self.container:getPositionY()
    end
end

function CommonScrollViewLayout:getCurContainerPosX()
    if self.container and not tolua.isnull(self.container) then
        return self.container:getPositionX()
    end
end


--==============================--
--desc:监测目标点位置
--time:2018-07-12 10:36:48
--@x:
--@y:
--@return 
--==============================--
function CommonScrollViewLayout:checkPosition(x, y)
    local _x, _y = self.container:getPositionX(), self.container:getPositionY()
    if self.dir == ScrollViewDir.horizontal then
        _x = _x + x
    elseif self.dir == ScrollViewDir.vertical then
        _y = _y + y
    end
    if _x > 0 then
        _x = 0
    elseif _x < (self.size.width - self.container_size.width) then
        _x = self.size.width - self.container_size.width
    end

    if _y > 0 then
        _y = 0
    elseif _y < (self.size.height - self.container_size.height) then
        _y = self.size.height - self.container_size.height
    end
    return cc.p(_x, _y)
end

--==============================--
--desc:设置滚动容器的大小
--time:2018-07-20 06:53:40
--@return 
--==============================--
function CommonScrollViewLayout:setInnerContainer()
    local size = #self.data_list
    local container_width = self.size.width
    local container_height = self.size.height
    local num = 0
    if self.dir == ScrollViewDir.horizontal then  -- 水平
        num = math.ceil(size / self.row)
        container_width = num * self.item_width + 2 * self.start_x + (num - 1) * self.space_x
    else
        num = math.ceil(size / self.col)
        if not self.is_change then
            container_height = num * self.item_height + 2 * self.start_y + (num - 1) * self.space_y
        else
            container_height = num * self.item_height + 2 * self.start_y + num * self.space_y
        end
    end
    container_width = math.max(container_width, self.size.width)
    container_height = math.max(container_height, self.size.height)
    self.container_size = cc.size(container_width, container_height)
    self.scroll_view:setInnerContainerSize(self.container_size)

    if self.start_pos == ScrollViewStartPos.top then
        self.scroll_view:jumpToTop()
    elseif self.start_pos == ScrollViewStartPos.bottom then
        self.scroll_view:jumpToBottom()
    end
end

function CommonScrollViewLayout:setStart_x(x)
    self.start_x = x
end
--背包里面的英雄碎片需要进度条显示
function CommonScrollViewLayout:setSpace(y, is_change)
    self.space_y = y
    self.is_change = is_change
end

--==============================--
--desc:设置数据
--time:2018-07-12 10:37:05
--@data_list:table结构,且必须是有序的,必须,必须,不能是key value
--@click_callback:
--@setting:
--@extend:
--@return 
--==============================--
function CommonScrollViewLayout:setData(data_list, click_callback, setting, extend)
    if setting then
        self:analysisSetting(setting)
    end
    self:clearCacheList()
    if data_list == nil or next(data_list) == nil then return end
    -- 打一个下表戳
    for i,v in ipairs(data_list) do
        v._index = i
    end

    -- if self.container_size then
    --     local minY = self.size.height - self.container_size.height
    --     local h = - minY
    --     local y = self.container:getPositionY()
    --     self.percent = ((y - minY) * 100)/h
    -- end

    self.item_click_callback = click_callback
    self.data_list = data_list
    self.extend = extend
    self.cur_item_class = self.item_class

    -- 设置内部滚动容器的尺寸
    self:setInnerContainer()

    local index = 1
    local once_num = self.once_num or 1
    local data = nil
    -- 如果需要动态创建的话
    local size = #self.data_list
    if self.need_dynamic == true then
        size = self.max_sum
    end

    -- 判断这边是否已经创建过的,如果创建过的就不需要分帧创建了,直接add吧
    if self.cur_item_class and self.total_cache_list[self.cur_item_class] and self.total_cache_list[self.cur_item_class].pool then
        for i=1,size do
            local data = self.data_list[i]
            if data ~= nil then
                self:createList(data)
            end
            if i >= size then
                if self.end_callback then
                    self:end_callback()
                end
            end
        end
    else
        if self.time_ticket == nil and next(self.data_list or {}) ~= nil then
            self.time_ticket = GlobalTimeTicket:getInstance():add(function()
                if tolua.isnull(self.container) then return end
                if self.data_list == nil then
                    if self.end_callback then
                        self:end_callback()
                    end
                    self:clearTimeTicket()
                else
                    for i = index, index + once_num - 1 do
                        data = self.data_list[i]
                        if data ~= nil then
                            self:createList(data)
                        end
                    end
                    index = index + once_num
                    if index > size then
                        if self.end_callback then
                            self:end_callback()
                        end
                        self:clearTimeTicket()
                    end
                end
            end, self.delay / display.DEFAULT_FPS)
        end
    end
end

function CommonScrollViewLayout:clearTimeTicket()
	if self.time_ticket ~= nil then
		GlobalTimeTicket:getInstance():remove(self.time_ticket)
		self.time_ticket = nil
	end
end 

--==============================--
--desc:重设滚动区域大小
--time:2018-07-12 10:43:29
--@size:
--@return 
--==============================--
function CommonScrollViewLayout:resetSize(size)
    if size == nil then return end
    if size.width == self.size.width and size.height == self.size.height then return end
    self.size = size
    self:setContentSize(size)
    self.scroll_view:setContentSize(size)
    self:calculationMaxSum()
end

--==============================--
--desc:清除缓存对象已经停掉计时器
--time:2018-06-11 07:55:29
--@return 
--==============================--
function CommonScrollViewLayout:clearCacheList()
    self:clearTimeTicket()
    if self.cur_item_class ~= nil then
        local cache_type_list = self.total_cache_list[self.cur_item_class] or {}
        if cache_type_list ~= nil and next(cache_type_list) ~= nil then
            for i, item in pairs(cache_type_list.item) do
                if item.suspendAllActions then
                    item:suspendAllActions()
                end
                --item:setVisible(false)
                table_insert(cache_type_list.pool, item)
            end
            for k,item in pairs(cache_type_list.pool) do
                item:setVisible(false)
            end
        end
        cache_type_list.item = {}
    end
    self.cur_item_class = nil
end

function CommonScrollViewLayout:addEndCallBack(call_back)
    self.end_callback = call_back
end

function CommonScrollViewLayout:addScrollToBottomCallBack( call_back )
    self.scrollToBottom_callback = call_back
end

function CommonScrollViewLayout:addScrollMoveCallBack( call_back )
    self.item_move_callback = call_back
end
--==============================--
--desc:创建具体的单位
--time:2018-07-12 10:43:59
--@data:
--@return 
--==============================--
function CommonScrollViewLayout:createList(data)
    if data == nil then return end
    if self.cur_item_class == nil then return end
    if self.total_cache_list[self.cur_item_class] == nil then
        self.total_cache_list[self.cur_item_class] = {}
    end
    local cache_type_list = self.total_cache_list[self.cur_item_class]
    if cache_type_list.item == nil then cache_type_list.item = {} end
    if cache_type_list.pool == nil then cache_type_list.pool = {} end

    if cache_type_list.item[data._index] ~= nil then return end

    local item = nil
    if next(cache_type_list.pool) == nil then
        item = self.item_class.new()
        item:setScale(self.scale)
        self.scroll_view:addChild(item)
    else
        item = table_remove(cache_type_list.pool, 1)
        item:setVisible(true)
    end

    -- 临时使用
    item.tmp_index = data._index
    cache_type_list.item[data._index] = item

    -- 扩展参数
    if self.extend ~= nil and item.setExtendData then
        item:setExtendData(self.extend)
    end
    
    self:setItemPosition(item, data._index)
    if self.item_click_callback ~= nil then
        if item.addCallBack then
            item:addCallBack(self.item_click_callback)
        end
    end
    item:setData(data,self.is_hide_effect)

    self.cur_item_index = data._index
end

--==============================--
--desc:设置当前对象的位置,根据数据的临时_index去确定
--time:2018-07-20 02:26:25
--@item:
--@index:
--@return 
--==============================--
function CommonScrollViewLayout:setItemPosition(item, index)
	local cur_item_index = index
	local anchor_point = item:getAnchorPoint()
	local _x, _y = 0, 0
	if self.dir == ScrollViewDir.horizontal then
		_x = self.start_x + self.item_width * anchor_point.x +(self.item_width + self.space_x) *(math.floor((cur_item_index - 1) / self.row))
		_y = self.container_size.height -(self.start_y + self.item_height *(1 - anchor_point.y) +((cur_item_index - 1) % self.row) *(self.item_height + self.space_y))
	else
		if self.start_pos == ScrollViewStartPos.top then
			_x = self.start_x + self.item_width * anchor_point.x +(self.item_width + self.space_x) *((cur_item_index - 1) % self.col)
			_y = self.container_size.height -(self.start_y + self.item_height *(1 - anchor_point.y) +(math.floor((cur_item_index - 1) / self.col)) *(self.item_height + self.space_y))
		else
			_x = self.start_x + self.item_width * anchor_point.x +(self.item_width + self.space_x) *((cur_item_index - 1) % self.col)
			_y = self.start_y + self.item_height * anchor_point.y +(math.floor((cur_item_index - 1) / self.col)) *(self.item_height + self.space_y)
		end
	end
	item:setPosition(_x, _y)
end

--==============================--
--desc:获取已创建的全部对象
--time:2018-07-12 10:44:18
--@return 
--==============================--
function CommonScrollViewLayout:getItemList()
    if self.cur_item_class == nil then return end
    local cache_type_list = self.total_cache_list[self.cur_item_class]
    if cache_type_list and next(cache_type_list or {}) == nil then
        return  {}
    end
    local item_list = {}
    if cache_type_list and cache_type_list.item then
        for k,v in pairs(cache_type_list.item) do
            table_insert(item_list, v)
        end
    end
    return  item_list
end

--==============================--
--desc:私有,外部不要调用
--time:2018-07-20 04:10:27
--@return 
--==============================--
function CommonScrollViewLayout:getTempItemList()
    if self.cur_item_class == nil then return end
    local cache_type_list = self.total_cache_list[self.cur_item_class]
    if cache_type_list then
        return cache_type_list.item, cache_type_list.pool
    end
end

--用于增减的时候操作,需要传去最新的List
function CommonScrollViewLayout:resetAddPosition(list, sort_fun)
    if list == nil or next(list) == nil then return end
    -- 对数据重新做一次处理
    if sort_fun ~= nil then
        table_sort(list, sort_fun)
    end
    for i,v in ipairs(list) do
        v._index = i
    end
    self.data_list = list
    local item_list, item_pool = self:getTempItemList()
    if item_list == nil or next(item_list) == nil then return end 
    for k, item in pairs(item_list) do
        if item.suspendAllActions then
            item:suspendAllActions()
        end
        if item.tmp_index then
            local data = list[item.tmp_index]
            if data and item.setData then
                item:setData(data)
                item:setVisible(true)
                item.tmp_index = data._index
            else
                item:setVisible(false)
                if item_pool then
                    table_insert(item_pool, item)
                end
                item_list[k] = nil
            end
        end
    end
end

--==============================--
--desc:对当前创建对象做排序,同时对缓存数据做排序
--time:2018-07-12 10:44:58
--@sort_fun:
--@return 
--==============================--
function CommonScrollViewLayout:resetPosition(sort_fun,is_clear)
    if self.data_list == nil or next(self.data_list) == nil then return end
    -- 对数据重新做一次处理
    if sort_fun ~= nil then
        table_sort(self.data_list, sort_fun)
    end
    for i,v in ipairs(self.data_list) do
        v._index = i
    end
    local item_list, item_pool = self:getTempItemList()
    if item_list == nil or next(item_list) == nil then return end 
    for k, item in pairs(item_list) do
        if item.suspendAllActions then
            item:suspendAllActions()
        end
        if item.tmp_index then
            local data = self.data_list[item.tmp_index]
            if data and item.setData then
                item:setData(data)
                item:setVisible(true)
                item.tmp_index = data._index
            end
        end
    end
end

--==============================--
--desc:解析数据
--time:2018-07-12 10:49:27
--@setting:
--@return 
--==============================--
function CommonScrollViewLayout:analysisSetting(setting)
    self.setting        = setting or {}
    self.item_class     = self.setting.item_class
    self.start_x        = self.setting.start_x or 0             -- 第一个单元的起点X
    self.space_x        = self.setting.space_x or 3             -- 横向间隔空间
    self.start_y        = self.setting.start_y or 0             -- 第一个单元的起点Y
    self.space_y        = self.setting.space_y or 3             -- 竖向间隔空间
    self.item_width     = self.setting.item_width or 115        -- 单元的宽度
    self.item_height    = self.setting.item_height or 115       -- 单元的高度
    self.is_radian      = self.setting.is_radian or false       -- 是否要弧度
    self.row            = self.setting.row or 5                 -- 行数,作用于水平方向的滚动
    self.col            = self.setting.col or 5                 -- 列数,作用于垂直方向的滚动
    self.delay          = self.setting.delay or 1               -- 创建延迟时间
    self.once_num       = self.setting.once_num or 1            -- 每次创建的数量
    self.scale          = self.setting.scale or 1               -- 缩放值
    self.need_dynamic   = self.setting.need_dynamic or false    -- 是否需要动态创建的 
    self.is_hide_effect = self.setting.is_hide_effect or false
    self:calculationMaxSum()
end

--==============================--
--desc:计算一下一屏最多创建的个数
--time:2018-07-20 10:26:34
--@return 
--==============================--
function CommonScrollViewLayout:calculationMaxSum()
    local max_sum
    if self.dir == ScrollViewDir.horizontal then 
        max_sum = (math.ceil(self.size.width / (self.item_width + self.space_x)) + 2) * self.row
    else
        max_sum = (math.ceil(self.size.height / (self.item_height + self.space_y)) + 2) * self.col
    end
    self.max_sum = max_sum
end

function CommonScrollViewLayout:getMaxSize()
    return self.container_size
end

function CommonScrollViewLayout:getContainer()
    return self.container
end

function CommonScrollViewLayout:scrollToPercentVertical( percent, time )
    self.scroll_view:scrollToPercentVertical(percent, time, true)
end

function CommonScrollViewLayout:scrollToPercentHorizontal( percent, time )
    self.scroll_view:scrollToPercentHorizontal(percent, time, true)
end

--==============================--
--desc:移除对象
--time:2018-07-12 10:49:17
--@return 
--==============================--
function CommonScrollViewLayout:DeleteMe()
    doStopAllActions(self.container)
    self:clearTimeTicket()
    for k, v in pairs(self.total_cache_list) do
        for i, list in pairs(v) do
            for i, item in pairs(list) do
                if item.DeleteMe then
                    item:DeleteMe()
                end
            end
        end
    end
    self.total_cache_list = nil

    self:removeAllChildren()
    self:removeFromParent()
end

CommonScrollItem = class("CommonScrollItem", function()
    return ccui.Layout:create()
end)
function CommonScrollItem:ctor()
end
function CommonScrollItem:setData(data)
end
function CommonScrollItem:addCallBack(call_back)
end
function CommonScrollItem:clearInfo()
    self:removeFromParent()
end
function CommonScrollItem:suspendAllActions()
end
function CommonScrollItem:DeleteMe()
    self:removeAllChildren()
    self:removeFromParent()
end