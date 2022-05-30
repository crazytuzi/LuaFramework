-- --------------------------------------------------------------------
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @description:
--      红包滚动条
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
local table_insert = table.insert
local table_remove = table.remove
local table_sort = table.sort

RedBagListPanel = class("RedBagListPanel", function()
    return ccui.Layout:create()
end)

--[[    @desc:构建函数
    author:{author}
    time:2018-05-05 14:12:49
    --@item_class:存放子对象的类
	--@dir:滑动方向，分水平和垂直 ScrollViewDir.horizontal or ScrollViewDir.vertical
	--@start_dir:开始的位置，分上和下，不分左右，一律从左边开始 ScrollViewStartPos.top or ScrollViewStartPos.bottom
	--@size:
	--@setting: 
    return
]]
function RedBagListPanel:ctor(parent, pos, dir, start_pos, size, setting, ap)
    self.parent = parent
    self.pos = pos or cc.p(0, 0)
    self.dir = dir or ScrollViewDir.vertical
    self.start_pos = start_pos or 0
    self.size = size or cc.size(100, 100)
    self.ap = ap or cc.p(0, 0)

    self.total_cache_list = {}                          -- 因为滚动容器可能每次存放不同的对象，因为多标签的时候
    self.item_click_callback = nil

    self.extend = nil                                   -- 扩展参数

    self.move_over_index = 0

    self.cur_item_class = nil                           -- 当前显示的对象
    self.item_num = 0                                   -- 数据数量
    self.select_item= nil
    self.is_run = false
    self:analysisSetting(setting)
    self.posx_list = {[1]=self.size.width/2,[2]=self.size.width/2+140,[3]=self.size.width/2-140}
    self:createRootWnd()
end

function RedBagListPanel:createRootWnd()
    self:setContentSize(self.size)
    if not tolua.isnull(self.parent) then
        self.parent:addChild(self)
    end
    self:setPosition(self.pos)
    self:setAnchorPoint(self.ap)

    self.container = ccui.Layout:create()
    self.container:setContentSize(self.size)
    self:addChild(self.container)

    self:registerEvent()
end

--[[    @desc:注册移动事件
    author:{author}
    time:2018-05-05 16:24:30
    return
]]
function RedBagListPanel:registerEvent()
    local function onTouchBegin(touch, event)
        self.last_point = nil
        self.is_move = false
        doStopAllActions(self.container)
        if self.cur_item_class == nil then
            return false
        end

        if self.screenSize == nil then
            local pos = self:convertToWorldSpace(cc.p(0, 0))
            self.screenSize = cc.rect(pos.x, pos.y, self.size.width, self.size.height)
        end

        local pos = cc.p(touch:getLocation().x, touch:getLocation().y)
        if not cc.rectContainsPoint(self.screenSize, pos) then
            return false
        end
        return true
    end

    local function onTouchMoved(touch, event)
        self.last_point = touch:getDelta()
        self:moveContainer(self.last_point)
    end

    local function onTouchEnded(touch, event)
        self.is_move = false
        if self.last_point == nil then return end
        -- local target_pos = self:checkPosition(self.last_point.x * 8, self.last_point.y * 8)
        -- local move_to = cc.MoveTo:create(2, cc.p(target_pos.x, target_pos.y))
        -- local ease_out = cc.EaseSineOut:create(move_to)
        -- self.container:runAction(cc.Sequence:create(ease_out))
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegin, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    self.container:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.container)
end


function RedBagListPanel:updateMove()
end

--[[    @desc: 移动
    author:{author}
    time:2018-05-05 14:34:36
    --@pos: 
    return
]]
function RedBagListPanel:moveContainer(pos)
    local target_pos = self:checkPosition(pos.x, pos.y)
    local is_left = pos.x<0
    if math.abs(pos.x) >=5 and self.is_move ~=true then
        self.is_move = true
        self.is_run = true
        local cache_type_list = self.total_cache_list[self.cur_item_class]
        for i=1,self.item_num do
            local item = cache_type_list.item[i]   
            self:setMoveItemPos(item,is_left)
        end
    end
end


function RedBagListPanel:jumpToMove(pos, time, callback)
    local target_pos = self:checkPosition(pos.x, pos.y)
    time = time or 1
    local move_to = cc.MoveTo:create(time, cc.p(target_pos.x, target_pos.y))

    self.container:runAction(cc.Sequence:create(move_to, cc.CallFunc:create(function()
        if callback then
            callback()
        end
    end)))
end

--[[    @desc: 
    author:{author}
    time:2018-05-05 15:55:27
    --@x:
	--@y: 
    return
]]
function RedBagListPanel:checkPosition(x, y)
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


--[[    @desc: 设置滚动组件需要显示的参数
    author:{author}
    time:2018-05-07 12:11:06
    --@data_list:
	--@click_callback:
	--@setting: 同一个滚动组件，每次可能需要显示不同样式的时候，这里做修改
    --@extend:扩展参数，有一些单元可能需要，比如说如果是物品那边的话，可能就不需要再播放动作了
    return
]]
function RedBagListPanel:setData(data_list, click_callback, setting, extend)
    if setting then
        self:analysisSetting(setting)
    end
    self:clearCacheList()
    self.item_click_callback = click_callback
    self.data_list = data_list
    self.extend = extend

    local size = #data_list
    self.item_num = size
    local container_width = self.size.width
    local container_height = self.size.height
    local num = 0
    if self.dir == ScrollViewDir.horizontal then  -- 水平
        num = math.ceil(size / self.row)
        container_width = num * self.item_width + 2 * self.start_x + (num - 1) * self.space_x
    else
        num = math.ceil(size / self.col)
        container_height = num * self.item_height + 2 * self.start_y + (num - 1) * self.space_y
    end
    container_width = math.max(container_width, self.size.width)
    container_height = math.max(container_height, self.size.height)
    self.container_size = cc.size(container_width, container_height)
    self.container:setContentSize(self.container_size)
    if self.start_pos >0 then
        local height = math.max(0-container_height*self.start_pos+35,self.size.height - self.container_size.height)
        self.container:setPosition(cc.p(0, height))
    elseif self.start_pos == 0 then
        self.container:setPosition(cc.p(0, 0))
    end
    -- 储存一下当前需要的单元类
    self.cur_item_class = self.item_class

    local index = 1
    local once_num = self.once_num or 1
    local data = nil
    if self.time_ticket == nil and next(self.data_list or {}) ~= nil then
        self.time_ticket = GlobalTimeTicket:getInstance():add(function()
            for i = index, index + once_num - 1 do
                if self.data_list and not tolua.isnull(self.container)  then
                    data = self.data_list[i]
                    if data ~= nil then
                        if data._index == nil then
                            data._index = i
                        end
                        self:createList(data)
                    end
                end
            end
            index = index + once_num
            if index > size then
                if self.end_callback then
                    self:end_callback()
                end
                self:clearTimeTicket()      -- 停掉计时器
            end
        end, self.delay / display.DEFAULT_FPS)
    end
end


function RedBagListPanel:clearTimeTicket()
    if self.time_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.time_ticket)
        self.time_ticket = nil
    end
end

--==============================--
--desc:清除缓存对象已经停掉计时器
--time:2018-06-11 07:55:29
--@return 
--==============================--
function RedBagListPanel:clearCacheList()
    self:clearTimeTicket()
    doStopAllActions(self.container)
    if self.cur_item_class ~= nil then
        local cache_type_list = self.total_cache_list[self.cur_item_class] or {}      -- 取出这个单元的缓存数据，
        if cache_type_list ~= nil and next(cache_type_list) ~= nil then
            for i, item in ipairs(cache_type_list.item) do
                item:setVisible(false)
                table_insert(cache_type_list.pool, item)
            end
        end
        cache_type_list.item = {}
    end
    self.cur_item_class = nil
end


function RedBagListPanel:addEndCallBack(call_back)
    self.end_callback = call_back
end
--[[    @desc: 创建具体单位
    author:{author}
    time:2018-05-05 16:49:51
    --@data: 
    return
]]
function RedBagListPanel:createList(data)
    if self.cur_item_class == nil then return end
    if self.total_cache_list[self.cur_item_class] == nil then
        self.total_cache_list[self.cur_item_class] = {}
    end
    local cache_type_list = self.total_cache_list[self.cur_item_class]

    if cache_type_list.item == nil then
        cache_type_list.item = {}
    end
    if cache_type_list.pool == nil then
        cache_type_list.pool = {}
    end

    local item = nil
    if next(cache_type_list.pool) == nil then
        item = self.item_class.new(true, true, cc.size(self.item_width, self.item_height))
        if item.setSwallowTouches then
            item:setSwallowTouches(false)
        end
        item:setScale(self.scale)
        self.container:addChild(item)
    else
        item = table_remove(cache_type_list.pool, 1)
    end
    table_insert(cache_type_list.item, item)
    local cur_item_index = #cache_type_list.item
    item.item_index = cur_item_index
    -- 扩展参数
    if self.extend ~= nil and item.setExtendData then
        item:setExtendData(self.extend)
    end
    item:setVisible(true)
    self:setItemPosition(item)
    if self.item_click_callback ~= nil then
        if item.addCallBack then
            item:addCallBack(self.item_click_callback)
        end
    end
    item:setData(data)
end

--[[    @desc:获取当前全部的现实对象
    author:{author}
    time:2018-05-14 21:54:39
    return
]]
function RedBagListPanel:getItemList()
    if self.cur_item_class == nil then return end
    local cache_type_list = self.total_cache_list[self.cur_item_class]
    return cache_type_list.item
end

--[[    @desc:设置创建单位的坐标
    author:{author}
    time:2018-05-05 16:53:53
    --@item: 
    return
]]
function RedBagListPanel:setItemPosition(item)
    local cache_type_list = self.total_cache_list[self.cur_item_class]
    if cache_type_list == nil or cache_type_list.item == nil then return end

    local cur_item_index = #cache_type_list.item
    local anchor_point = item:getAnchorPoint()
    local _x, _y = 0, 0
    local create_index = 0
    if self.dir == ScrollViewDir.horizontal then
        _x = self.posx_list[cur_item_index]
        _y = self.container_size.height - (self.start_y + self.item_height * (1 - anchor_point.y) + ((cur_item_index - 1) % self.row) * (self.item_height + self.space_y))
    end
    item:setPosition(_x, _y)
    if cur_item_index ==1 then 
        item:setLocalZOrder(10)
        item:showBlackBg(false)
        item:setScale(1.05)
        self.select_item = item
    else
        item:setLocalZOrder(1)
        item:showBlackBg(true)
        item:setScale(0.85)
    end
end
--移动操作
function RedBagListPanel:setMoveItemPos(item,is_left)
    local cache_type_list = self.total_cache_list[self.cur_item_class]
    if cache_type_list == nil or cache_type_list.item == nil then return end
    if not item then return end

    local cur_item_index = item.item_index or 0
    if is_left == true then
        
        if cur_item_index <=1 then 
            cur_item_index = self.item_num
            
        else
            cur_item_index = cur_item_index-1
        end
    else
        
        if cur_item_index >=self.item_num then 
            cur_item_index = 1
        else
            cur_item_index = cur_item_index+1
            
        end
    end
    item.item_index = cur_item_index
    local anchor_point = item:getAnchorPoint()
    local _x, _y = 0, 0
    if self.dir == ScrollViewDir.horizontal then
        _x = self.posx_list[cur_item_index]
        _y = self.container_size.height - (self.start_y + self.item_height * (1 - anchor_point.y) + ((cur_item_index - 1) % self.row) * (self.item_height + self.space_y))
    end
    doStopAllActions(item)
    local scale = 1
    if cur_item_index ==1 then 
        item:setLocalZOrder(10)
        item:showBlackBg(false)
        scale = 1.05
        self.select_item = item
    else
        item:showBlackBg(true)
        item:setLocalZOrder(1)
        scale = 0.85
    end
    local move_to = cc.MoveTo:create(0.3, cc.p(_x, _y))
    local scale_to = cc.ScaleTo:create(0.3, scale)
    item:runAction(cc.Sequence:create(scale_to))
    item:runAction(cc.Sequence:create(move_to,cc.CallFunc:create(function()
        self.is_run = false
        if self.end_callback then 
            self:end_callback()
        end
    end)))
    -- item:setPosition(_x, _y)
end
--外部按钮左移动一个
function RedBagListPanel:runLeftPostion()
    if self.is_run == true then return end
    local cache_type_list = self.total_cache_list[self.cur_item_class]
    self.is_run = true
    for i=1,self.item_num do
        local item = cache_type_list.item[i]   
        self:setMoveItemPos(item,true)
    end
end
--外部按钮右移动一个
function RedBagListPanel:runRightPostion()
    if self.is_run == true then return end
    self.is_run = true
    local cache_type_list = self.total_cache_list[self.cur_item_class]
    for i=1,self.item_num do
        local item = cache_type_list.item[i]   
        self:setMoveItemPos(item,false)
    end
end
function RedBagListPanel:getSelectItem()
    return self.select_item
end

function RedBagListPanel:setSelectItem(item)
    if item then
        self.select_item = item 
    end
end

--[[    @desc: 解析设置数据
    author:{author}
    time:2018-05-07 11:58:40
    --@setting: 
    return
]]
function RedBagListPanel:analysisSetting(setting)
    self.setting = setting or {}
    self.item_class = self.setting.item_class
    self.start_x = self.setting.start_x or 0 -- 第一个单元的起点X
    self.space_x = self.setting.space_x or 3 -- 横向间隔空间
    self.start_y = self.setting.start_y or 0 -- 第一个单元的起点Y
    self.space_y = self.setting.space_y or 3 -- 竖向间隔空间
    self.item_width = self.setting.item_width or 115 -- 单元的宽度
    self.item_height = self.setting.item_height or 115 -- 单元的高度
    self.is_radian = self.setting.is_radian or false  --是否要弧度
    self.row = self.setting.row or 5 -- 行数,作用于水平方向的滚动
    self.col = self.setting.col or 5 -- 列数,作用于垂直方向的滚动
    self.delay = self.setting.delay or 2    -- 创建延迟时间
    self.once_num = self.setting.once_num or 1  -- 每次创建的数量
    self.scale = self.setting.scale or 1 --缩放值
end


function RedBagListPanel:scrollToPos(pos_rate)
    pos_rate = pos_rate or 1
    doStopAllActions(self.container)
    local height = math.max(0-self.container_size.height*pos_rate+35,self.size.height - self.container_size.height)
    height = math.min(0,height)
    
    local move_to = cc.MoveTo:create(0.6, cc.p(0,height ))
    self.container:runAction(cc.Sequence:create(move_to))
end
function RedBagListPanel:getMaxSize()
    return self.container_size
end

function RedBagListPanel:getContainer()
    return self.container
end
function RedBagListPanel:DeleteMe()
    self:clearTimeTicket()
    doStopAllActions(self.container)
    for k, v in pairs(self.total_cache_list) do
        for i, list in pairs(v) do
            for i, item in ipairs(list) do
                if item.DeleteMe then
                    item:DeleteMe()
                end
            end
        end
    end
    self.total_cache_list = nil
    if self.head then 
        self.head:DeleteMe()
        self.head = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end


