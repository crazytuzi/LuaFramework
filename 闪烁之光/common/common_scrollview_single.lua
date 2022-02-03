-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @description:
--      自动意义的scrollview 单scrollview..支持左右 或者 上下滚动 
-- <br/>Create: 2018年12月3日
--
-- --------------------------------------------------------------------
local table_insert = table.insert
local table_remove = table.remove
local table_sort = table.sort

--[[使用例子
    --你的数据
    self.cell_data_list = {}

    local size = cc.size(100,100)
    local setting = {
        start_x = 0,                     -- 第一个单元的X起点
        space_x = 0,                     -- x方向的间隔
        start_y = 0,                     -- 第一个单元的Y起点
        space_y = 0,                     -- y方向的间隔
        item_width = 688,                -- 单元的尺寸width
        item_height = 150,               -- 单元的尺寸height
        row = 1,                         -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        delay = 4,                       -- 创建延迟时间
        once_num = 1,                    -- 每次创建的数量
    }
    
    --返回创建你的item
    --@width 是setting.item_width
    --@height 是setting.item_height
    local function createNewCell(width, height)
        return item.new()
    end 
    --返回cell数量
    local function numberOfCells()
        return #self.cell_data_list 
    end 

    --更新cell (拖动的时候.刷新数据时候会执行此方法)
    local function updateCellByIndex(cell, index)
        self.cell_data_list[index]
        --此处理你的对象显示数据
        相当于: 之前的setData(self.cell_data_list[index])
    end
    
    --点击
    local fucntion onCellTouched(cell, index)
        
    end

    self.item_scrollview = CommonScrollViewSingleLayout.new(self.charge_con, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))
    
    self.item_scrollview:registerScriptHandlerSingle(createNewCell, ScrollViewFuncType.CreateNewCell) --创建cell
    self.item_scrollview:registerScriptHandlerSingle(numberOfCells, ScrollViewFuncType.NumberOfCells) --获取数量
    self.item_scrollview:registerScriptHandlerSingle(updateCellByIndex, ScrollViewFuncType.UpdateCellByIndex) --更新cell
    self.item_scrollview:registerScriptHandlerSingle(updateCellByIndex, ScrollViewFuncType.OnCellTouched) --点击cell

    self.item_scrollview:reloadData()
]]--

--ScrollView的方法类型
ScrollViewFuncType = {
    UpdateCellByIndex = 1,        -- 更新cell体
    CreateNewCell  =  2,       -- 创建 新的cell 
    NumberOfCells = 3,      -- 返回 数据的数量
    OnCellTouched = 4,    -- 点击cell回调方法
    -- CellNormalIndex = 5,    -- 不选中中格子显示回调方法
    -- CellSelectIndex = 6     -- 选中中格子显示回调方法
}

CommonScrollViewSingleLayout = class("CommonScrollViewSingleLayout", function()
    return ccui.Layout:create()
end)

--==============================--
--desc:构建一个自动意义滚动容器
--time:2018-07-12 11:11:44
--@parent: 父类
--@pos: 位置
--@size: 大小
--@setting: 各种设置
--@ap:  描点 默认 cc.p(0, 0)
--@dir: 垂直或者水平滚动 类型如:ScrollViewDir.vertical
--@start_pos: 滚动区域开始的位置 默认 ScrollViewStartPos.top 
--@return 
--==============================--

function CommonScrollViewSingleLayout:ctor(parent, pos, dir, start_pos, size, setting, ap)
    self.parent = parent
    self.pos = pos or cc.p(0, 0)
    self.dir = dir or ScrollViewDir.vertical
    self.start_pos = start_pos or ScrollViewStartPos.top
    self.size = size or cc.size(100, 100)
    self.ap = ap or cc.p(0, 0)

      --存放所有格子结构体
    self.cellList = {}
    --缓存Cell所用到的对象
    self.cacheList = {}
    --记录活跃得格子ID
    self.activeCellIdx = {}
    --当前选择物品的索引
    self.selectCellIndex = 1
    --回调方法
    self.handler = {}

    -- 到时间显示的索引
    self.time_show_index = 0

    --是否初始化
    self.is_first_init = true

    self:analysisSetting(setting)
    self:createRootWnd()
end

--==============================--
--desc:设置配置文件
--@setting: 要求规定setting的所有变量 都应该在这里定义出来
--@return 
--==============================--
function CommonScrollViewSingleLayout:analysisSetting(setting)
    self.setting        = setting or {}
    self.start_x        = self.setting.start_x or 0             -- 第一个单元的起点X
    self.end_x          = self.setting.end_x or self.start_x    -- 最后一个单元结束X间隔 如果是nil 默认 和 start_x一致
    self.start_y        = self.setting.start_y or 0             -- 第一个单元的起点Y
    self.end_y          = self.setting.end_y or self.start_y    -- 最后一个单元结束Y间隔 如果是nil 默认 和 start_y一致
    self.space_x        = self.setting.space_x or 3             -- 横向间隔空间
    self.space_y        = self.setting.space_y or 3             -- 竖向间隔空间
    self.item_width     = self.setting.item_width or 115        -- 单元的宽度
    self.item_height    = self.setting.item_height or 115       -- 单元的高度

    self.row            = self.setting.row or 5                 -- 行数,作用于水平方向的滚动
    self.col            = self.setting.col or 5                 -- 列数,作用于垂直方向的滚动
    self.delay          = 1 --self.setting.delay or 4               -- 创建延迟时间 强制改为1 
    self.once_num       = self.setting.once_num or 1            -- 每次创建的数量
    self.need_dynamic   = true  -- 默认是无限的
    self.checkovercallback = self.setting.checkovercallback     --滑动回调函数
    self.is_auto_scroll = setting.is_auto_scroll or false       --是否自动判断是否能滚动..个数小于一屏大小时候scroll 不能滚动

    --位置列表 
    self.position_data_list = self.setting.position_data_list

    --固定容器大小 如果有值.将不运算容器大小
    self.container_width = setting.container_width
    self.container_height = setting.container_height

    self.inner_hight_offset = setting.inner_hight_offset or 0 -- 内容高度偏移值（仅对纵向有效）

    --横向的只支持一行的..
    if self.dir == ScrollViewDir.horizontal then
        self.row  = 1
    end
    self:calculationMaxSum()
end

function CommonScrollViewSingleLayout:updateSetting(setting)
    if not setting then return end
    for k,v in pairs(setting) do
        self[k] = v
    end
end

--==============================--
--desc:计算一下一屏最多创建的个数
--time:2018-07-20 10:26:34
--@return 
--==============================--
function CommonScrollViewSingleLayout:calculationMaxSum()
    local max_sum
    if self.dir == ScrollViewDir.horizontal then 
        max_sum = (math.ceil(self.size.width / (self.item_width + self.space_x)) + 1) * self.row
    else
        max_sum = (math.ceil(self.size.height / (self.item_height + self.space_y)) + 1) * self.col
    end
    self.cacheMaxSize = max_sum
end

function CommonScrollViewSingleLayout:createRootWnd()
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
function CommonScrollViewSingleLayout:registerEvent()
    if self.need_dynamic == true then
        self.scroll_view:addEventListener(function(sender, eventType)
            if eventType == ccui.ScrollviewEventType.containerMoved then
                self:checkRectIntersectsRect()
                if self.checkovercallback then
                    self.checkovercallback()
                end
            end
        end)
    end
end

-- 注册回调方法
function CommonScrollViewSingleLayout:registerScriptHandlerSingle(func, handlerId)
    self.handler[handlerId] = func
end

--获取cell数量
function CommonScrollViewSingleLayout:numberOfCells()
    if not self.handler[ScrollViewFuncType.NumberOfCells] then return end
    return self.handler[ScrollViewFuncType.NumberOfCells]()
end

--刷新每一个cell 
function CommonScrollViewSingleLayout:updateCellByIndex(cell, index)
    if not self.handler[ScrollViewFuncType.UpdateCellByIndex] then return end
    self.handler[ScrollViewFuncType.UpdateCellByIndex](cell, index)
end

--创建一个新cell
function CommonScrollViewSingleLayout:createNewCell()
    if not self.handler[ScrollViewFuncType.CreateNewCell] then return end
    return self.handler[ScrollViewFuncType.CreateNewCell](self.item_width, self.item_height)
end

-- --点击cell --在createNewCell 自行实现
function CommonScrollViewSingleLayout:onCellTouched(cell, index)
    if not self.handler[ScrollViewFuncType.OnCellTouched] then return end
    self.handler[ScrollViewFuncType.OnCellTouched](cell, index)
end


--设置 scrollview 是否可点
function CommonScrollViewSingleLayout:setClickEnabled(status)
    self.scroll_view:setTouchEnabled(status)
end
--设置 是否吞噬点击
function CommonScrollViewSingleLayout:setSwallowTouches(status)
    self.scroll_view:setSwallowTouches(status)
end

function CommonScrollViewSingleLayout:setBounceEnabled( status )
    self.scroll_view:setBounceEnabled(status)
end

--==============================--
--desc:移动的过程中盘点是否不再可视范围,不再的时候移除掉,放到对象池,并且准备下一次创建
--time:2018-07-20 12:13:25
--@return 
--==============================--
function CommonScrollViewSingleLayout:checkRectIntersectsRect()
    if self.dir == ScrollViewDir.vertical then
        if self.start_pos == ScrollViewStartPos.top then
            self:checkOverShowByVertical()
        else
            -- 支持ScrollViewStartPos.bottom的了 --by lwc
            self:checkOverShowByVerticalBottom()
        end
    elseif self.dir == ScrollViewDir.horizontal then
        self:checkOverShowByHorizontal()
    end
end

--==============================--
--desc:竖直方向的监测判断
--time:2018-07-20 03:11:13
--@return 
--==============================--
function CommonScrollViewSingleLayout:checkOverShowByVertical()
    if not self.cellList then return end
    local container_y = self.container:getPositionY()
    --计算 视图的上部分和下部分在self.container 的位置
    local bot = -container_y
    local top = self.size.height + bot
    local col_count = math.ceil(#self.cellList/self.col)
    --下面因为 self.cellList 是一维数组 所以要换成二维来算
    --活跃cell开始行数
    local activeCellStartRow = 1
    for i=1, col_count do
        local index = 1 + (i-1)* self.col
        local cell = self.cellList[index]
        activeCellStartRow = i
        if cell and cell.y - self.item_height * 0.5 <= top then
            break
        end
    end
    --活跃cell结束行数
    local activeCellEndRow = col_count
    if bot > 0 then
        for i = activeCellStartRow, col_count do
            local index = 1 + (i-1)* self.col
            local cell = self.cellList[index]
            if cell and cell.y + self.item_height * 0.5 < bot then
                activeCellEndRow = i - 1
                break
            end
        end
    end
    -- print("保留--> top --> :"..top .." self.col:"..self.col)
    -- print("保留--> bot --> :"..bot )
    -- print("保留--> 开始行: "..activeCellStartRow.."结束行: "..activeCellEndRow)
    local max_count = self:numberOfCells()
    for i=1, col_count do
        if i >= activeCellStartRow and i <= activeCellEndRow then
            for k=1, self.col do
                local index = (i-1) * self.col + k
                if not self.activeCellIdx[index] then
                    if index <= max_count then
                        self:updateCellAtIndex(index)
                        self.activeCellIdx[index] = true
                    end
                end    
            end
        else
            for k=1, self.col do
                local index = (i-1) * self.col + k
                if index <= max_count then
                    self.activeCellIdx[index] = false
                end
            end
        end
    end
end
--==============================--
--desc:竖直方向的监测判断
--time:2018-07-20 03:11:13
--@return 
--==============================--
function CommonScrollViewSingleLayout:checkOverShowByVerticalBottom()
    if not self.cellList then return end
    local container_y = self.container:getPositionY()
    --计算 视图的上部分和下部分在self.container 的位置
    local bot = -container_y
    local top = self.size.height + bot
    local col_count = math.ceil(#self.cellList/self.col)
    --下面因为 self.cellList 是一维数组 所以要换成二维来算
    --活跃cell开始行数
    local activeCellStartRow = col_count
    for i=col_count, 1,-1 do
        local index = 1 + (i-1)* self.col
        local cell = self.cellList[index]
        activeCellStartRow = i
        if cell and cell.y - self.item_height * 0.5 <= top then
            break
        end
    end
    --活跃cell结束行数
    local activeCellEndRow = 1
    if bot > 0 then
        for i = activeCellStartRow, 1, -1 do
            local index = 1 + (i-1)* self.col
            local cell = self.cellList[index]
            if cell and cell.y + self.item_height * 0.5 < bot then
                activeCellEndRow = i + 1
                break
            end
        end
    end
    -- print("保留--> top --> :"..top .." self.col:"..self.col)
    -- print("保留--> bot --> :"..bot )
    -- print("保留--> 开始行: "..activeCellStartRow.."结束行: "..activeCellEndRow)
    local max_count = self:numberOfCells()
    for i=1, col_count do
        if i <= activeCellStartRow and i >= activeCellEndRow then
            for k=1, self.col do
                local index = (i-1) * self.col + k
                if not self.activeCellIdx[index] then
                    if index <= max_count then
                        self:updateCellAtIndex(index)
                        self.activeCellIdx[index] = true
                    end
                end    
            end
        else
            for k=1, self.col do
                local index = (i-1) * self.col + k
                if index <= max_count then
                    self.activeCellIdx[index] = false
                end
            end
        end
    end
end

function CommonScrollViewSingleLayout:checkOverShowByHorizontal()
    if not self.cellList then return end
    
    local container_x = self.container:getPositionX()
    --计算 视图的左部分和右部分在self.container 的位置
    local top = -container_x 
    local bot = top + self.size.width

    local row_count = #self.cellList
    --横向的只支持一行
    --活跃cell开始行数
    local activeCellStartRow = 1
    if top > 0 then
        for index=1, row_count do
            local cell = self.cellList[index]
            activeCellStartRow = index
            if cell and cell.x + self.item_width * 0.5 >= top then
                break
            end
        end
    end
    --活跃cell结束行数
    local activeCellEndRow = row_count
    for index = activeCellStartRow, row_count do
        local cell = self.cellList[index]
        if cell and cell.x - self.item_width * 0.5 > bot then
            activeCellEndRow = index - 1
            break
        end
    end
    -- print("保留--> top --> :"..top .." self.row:"..self.row)
    -- print("保留--> bot --> :"..bot )
    -- print("保留--> 开始行: "..activeCellStartRow.."结束行: "..activeCellEndRow)
    local max_count = self:numberOfCells()
    for index=1, row_count do
        if index >= activeCellStartRow and index <= activeCellEndRow then
            if not self.activeCellIdx[index] then
                if index <= max_count then
                    self:updateCellAtIndex(index)
                    self.activeCellIdx[index] = true
                end
            end 
        else
            if index <= max_count then
                self.activeCellIdx[index] = false
            end
        end
    end
end


--==============================--
--desc:滚动容器移动到指定位置
--time:2018-07-12 10:34:41
--@pos:
--@return 
--==============================--
function CommonScrollViewSingleLayout:updateMove(pos)
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
function CommonScrollViewSingleLayout:jumpToMove(pos, time, callback)
    local target_pos = self:checkPosition(pos.x, pos.y)
    time = time or 1
    local move_to = cc.MoveTo:create(time, cc.p(target_pos.x, target_pos.y))
    self.container:runAction(cc.Sequence:create(move_to, cc.CallFunc:create(function()
        if callback then
            callback()
        end
    end)))
end 

--==============================--
--desc:监测目标点位置
--time:2018-07-12 10:36:48
--@x:
--@y:
--@return 
--==============================--
function CommonScrollViewSingleLayout:checkPosition(x, y)
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

--获取当前容器的y位置
function CommonScrollViewSingleLayout:getCurContainerPosY()
    if self.container and not tolua.isnull(self.container) then
        return self.container:getPositionY()
    end
end
--获取当前容器的x位置
function CommonScrollViewSingleLayout:getCurContainerPosX()
    if self.container and not tolua.isnull(self.container) then
        return self.container:getPositionX()
    end
end

--==============================--
--desc:设置滚动容器的大小
--time:2018-07-20 06:53:40
--@return 
--==============================--
function CommonScrollViewSingleLayout:setInnerContainer()
    local number = self:numberOfCells()
    local container_width = self.container_width or self.size.width
    local container_height = self.container_height or self.size.height
    if self.dir == ScrollViewDir.horizontal then  -- 水平
        if self.container_width == nil then
            local num = math.ceil(number / self.row)
            container_width = num * self.item_width + self.end_x + self.start_x + (num - 1) * self.space_x
        end
    else
        if self.container_height == nil then
            local num = math.ceil(number / self.col)
            container_height = num * self.item_height + self.end_y + self.start_y + (num - 1) * self.space_y + self.inner_hight_offset
        end
    end
    container_width = math.max(container_width, self.size.width)
    container_height = math.max(container_height, self.size.height)
    self.container_size = cc.size(container_width, container_height)
    --记录在当前的contariner位置..因为在 setInnerContainerSize 方法会被重置
    self.cur_container_x, self.cur_container_y = self.container:getPosition()
    
    self.scroll_view:setInnerContainerSize(self.container_size)
    if self.start_pos == ScrollViewStartPos.top then
        self.scroll_view:jumpToTop()
    elseif self.start_pos == ScrollViewStartPos.bottom then
        self.scroll_view:jumpToBottom()
    end
end

--刷新当前显示的item数据 (不改变任何位置的,前提数据数量没有改变如果有改变用 reload)
function CommonScrollViewSingleLayout:resetCurrentItems()
    for i,v in pairs(self.activeCellIdx) do
        if v then
            self:updateCellAtIndex(i)
        end
    end
end

--根据index 刷新对应索引..如果在显示视图内
function CommonScrollViewSingleLayout:resetItemByIndex(index)
    -- body
    if self.activeCellIdx[index] then
        self:updateCellAtIndex(index)
    end
end

--获取活跃中的cell对象
function CommonScrollViewSingleLayout:getActiveCellList()
    local list = {}
    for i,v in pairs(self.activeCellIdx) do
        if v and self.cellList[i] and self.cellList[i].cell then
            table_insert(list, self.cellList[i].cell)
        end
    end
    return list
end

--获取index索引对应cell(不管是否活跃)
function CommonScrollViewSingleLayout:getCellByIndex(index)
    if  self.cellList[index] and self.cellList[index].cell then
        return self.cellList[index].cell
    end
end

--获取index索引对应cellXY位置(不管是否活跃)
function CommonScrollViewSingleLayout:getCellXYByIndex(index)
    if  self.cellList[index] then
        return self.cellList[index].x, self.cellList[index].y 
    end
end

--获取index索引对应cellXY位置(不活跃会返回空)
function CommonScrollViewSingleLayout:getActiveCellByIndex(index)
    if self.activeCellIdx[index] and self.cellList[index] then
        return self.cellList[index].cell
    end
end
--获取当前容器所在显示窗口的x y位置
function CommonScrollViewSingleLayout:getContainerXY()
    if self.container then
        local x, y = self.container:getPosition()
        return x, y
    end
end

--获取当前容器所在显示窗口的x y位置
function CommonScrollViewSingleLayout:setContainerXY(x, y)
    if self.container then
        if x and y then
            self.container:setPosition(x,y)
        else
            if x then
                self.container:setPositionX(x) 
            end
            if y then 
                self.container:setPositionY(y)  
            end    
        end
    end
end

--根据索引判断是否活跃中
function CommonScrollViewSingleLayout:isActiveByIndex(index)
    if self.activeCellIdx[index] then
        return true
    end
    return false
end
--移动到以选中idenx的位置作为在中间 显示 目前只支持y 方向的
function CommonScrollViewSingleLayout:jumpToMoveByIndex(index)

    if not self.cellList[index] then return end
    local y = self.cellList[index].y or 0
    local pos = self.container_size.height - (y + self.size.height * 0.5 )
    if pos < 0 then
        pos = 0
    end
    local pos_per = pos * 100 / (self.container_size.height - self.size.height)
    if pos_per > 100 then
        pos_per = 100
    end
    if pos_per == 100 then
        if self.start_pos == ScrollViewStartPos.top then
            self:checkOverShowByVertical()
        else
            self:checkOverShowByVerticalBottom()
        end
    end
    self.scroll_view:scrollToPercentVertical(pos_per, 0.8, true)
end


--==============================--
--desc:设置数据
--select_idnex 从第几个开始
--@setting: 如果有改变的话
--@is_keep_position 是否保持原来位置 --item数量有变化情况. 无变化请用resetCurrentItems
--==============================--
function CommonScrollViewSingleLayout:reloadData(select_index, setting, is_keep_position)
    if setting then
        self:updateSetting(setting)
    end
    local old_width , old_height = 0, 0
    if self.container_size then
        old_width = self.container_size.width
        old_height = self.container_size.height
    end
    self.cellList = {}
    self.activeCellIdx = {}

    for k, v in ipairs(self.cacheList) do
        --相当于隐藏
        v:setPositionX(-10000)
    end
    --设置容器大小
    self:setInnerContainer()

    local number = self:numberOfCells()
    if number == 0 then
        return
    end

    for i = 1, number do
        local cell = nil 
        if i <= self.time_show_index then
            cell = self:getCacheCellByIndex(i)
        end
        local count = #self.cellList
        local x, y
        if self.position_data_list then
            local pos = self.position_data_list[count + 1]
            if pos then
                x, y = pos.x, pos.y
            else
                x, y = self:getCellPosition(count + 1)    
            end
        else
            x, y = self:getCellPosition(count + 1)
        end
        local cellData = {cell = cell, x = x, y = y}
        table_insert(self.cellList, cellData)
    end
    
    if self.is_first_init then
        self:startTimeTicket()
    else
        --如果时间显示索引小于总数 应该显示继续当前定时器 让下面的能显示出来
        if self.time_show_index <= number then
            self:startTimeTicket()
        end
    end

    if is_keep_position then
        --是否保持当前显示位置
        local cur_container_x =  self.cur_container_x or 0
        local cur_container_y =  self.cur_container_y or 0
        if self.dir == ScrollViewDir.vertical then --竖方向
            if self.start_pos == ScrollViewStartPos.top then
                local temp_height = self.container_size.height - old_height
                cur_container_y = cur_container_y -  temp_height
            end
            if cur_container_y > 0 then
                cur_container_y = 0
            elseif cur_container_y < (self.size.height - self.container_size.height) then
                cur_container_y = self.size.height - self.container_size.height
            end
        elseif self.dir == ScrollViewDir.horizontal then --横方向
            if cur_container_x > 0 then
                cur_container_x = 0
            elseif cur_container_x < (self.size.width - self.container_size.width) then
                cur_container_x = self.size.width - self.container_size.width
            end
        end
        self.container:setPosition(cur_container_x, cur_container_y)
        self:checkRectIntersectsRect()
    else
        if select_index == nil then
            local maxRefreshNum 
            if self.dir == ScrollViewDir.horizontal then  -- 水平
                maxRefreshNum = self.cacheMaxSize - self.row
            else
                maxRefreshNum = self.cacheMaxSize - self.col
            end
            local refreshNum = number < maxRefreshNum and number or maxRefreshNum

            for i = 1, refreshNum do
                if i <= self.time_show_index then
                    self:updateCellAtIndex(i)
                end
                self.activeCellIdx[i] = true
            end
        else
            self:selectCellByIndex(select_index)
        end
    end
    if self.is_auto_scroll then
        local cur_max_count = self.cacheMaxSize
        
        if self.dir == ScrollViewDir.horizontal then 
            cur_max_count = cur_max_count - 2 * self.row
        else
            cur_max_count = cur_max_count - 2 * self.col
        end
        if number <= cur_max_count then
            self:setClickEnabled(false)
        else
            self:setClickEnabled(true)
        end
    end
end

--选中index索引对象(如果列表允许 会排序在开始第一位)
function CommonScrollViewSingleLayout:selectCellByIndex(index)
    local index = index or 1
    if self.cellList[index] == nil then
        index = 1
    end
    if self.cellList[index] == nil then  return end
    --一屏幕显示的最大数量
    local maxRefreshNum 
    if self.dir == ScrollViewDir.horizontal then  -- 水平
        maxRefreshNum = self.cacheMaxSize - self.row
    else
        maxRefreshNum = self.cacheMaxSize - self.col
    end
    local number = self:numberOfCells()
    if number < maxRefreshNum then
        --不够显示一屏幕
        if self.time_show_index == 0 then
            self.time_show_index = index
        end
        for i = 1, number do
            if i <= self.time_show_index then
                self:updateCellAtIndex(i)
            end
            self.activeCellIdx[i] = true
        end
    else
        --列表允许 情况
        if self.dir == ScrollViewDir.horizontal then  -- 水平
            --容器x方向位置
            local container_x
            if index == 1 then
                container_x =  0
            else
                container_x =  -(self.cellList[index].x - (self.item_width + self.space_x) * 0.5 )
            end
            --容器x方向最大位置
            local max_contariner_x = -(self.container_size.width - self.size.width)

            --这两个值都是负数
            if container_x < max_contariner_x then
                container_x = max_contariner_x
            end
            local show_index = math.floor(math.abs(container_x) / self.item_width) + 1
            if self.time_show_index < show_index then
                self.time_show_index = show_index
            end
            self.container:setPositionX(container_x)
            self:checkRectIntersectsRect()
        else -- 垂直
            local container_y
            if index == 1 then
                container_y = (self.start_y + self.cellList[index].y + self.item_height * 0.5) - self.size.height 
            else
                container_y = (self.cellList[index].y + (self.item_height + self.space_y) * 0.5) - self.size.height 
            end
            if container_y < 0 then
                container_y = 0
            end
            local index_1 = math.floor( (self.container_size.height - (container_y + self.size.height)) / self.item_height) + 1
            local show_index = (index_1 - 1) * self.col + 1
            if self.time_show_index < show_index then
                self.time_show_index = show_index
            end
            self.container:setPositionY(- container_y)
            self:checkRectIntersectsRect()
        end
    end

    if index > 0 and index <= self:numberOfCells() then
        local cell = self:getCacheCellByIndex(index)
        cell.index = index
        self.cellList[index].cell = cell
        self:onCellTouched(cell, index)
    end 
end

function CommonScrollViewSingleLayout:setOnCellTouched(index)
    local cell = self:getCacheCellByIndex(index)
    cell.index = index
    self.cellList[index].cell = cell
    self:onCellTouched(cell, index)
end

function CommonScrollViewSingleLayout:startTimeTicket()
     if self.time_ticket == nil then
        if #self.cellList == 0 then
            return
        end
        --到时间显示的索引
        local once_num = self.once_num or 1
        local _callback = function()
            if tolua.isnull(self.container) then return end
            local count = self.time_show_index + once_num
            local index = self.time_show_index + 1
            if index == 0 then
                index = 1
            end
            local size = #self.cellList

            self.time_show_index = self.time_show_index + once_num
            for i = index, count do
                if i > size then
                    --超过总数了
                    break
                end
                local cellData = self.cellList[i]
                if cellData and cellData.cell == nil then
                    cellData.cell = self:getCacheCellByIndex(i)
                end
                if self.activeCellIdx[i] then
                    self:updateCellAtIndex(i)
                end
            end
            
            if self.time_show_index >= size then
                self:clearTimeTicket()
                self.is_first_init = false
            end
        end

        self.time_ticket = GlobalTimeTicket:getInstance():add(_callback, self.delay / display.DEFAULT_FPS)
    end
end

function CommonScrollViewSingleLayout:clearTimeTicket()
    if self.time_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.time_ticket)
        self.time_ticket = nil
    end
end 


--获取index 对应的位置 由于一开始不创建item  
--@return 是[index]对象所在的中点
function CommonScrollViewSingleLayout:getCellPosition(index)
    local cur_item_index = index
    local anchor_point = cc.p(0.5,0.5)
    local _x, _y = 0, 0
    if self.dir == ScrollViewDir.horizontal then
        _x = self.start_x + self.item_width * anchor_point.x +(self.item_width + self.space_x) *(math.floor((index - 1) / self.row))
        _y = self.container_size.height -(self.start_y + self.item_height *(1 - anchor_point.y) +((index - 1) % self.row) *(self.item_height + self.space_y))
    else
        if self.start_pos == ScrollViewStartPos.top then
            _x = self.start_x + self.item_width * anchor_point.x + (self.item_width + self.space_x) *((index - 1) % self.col)
            _y = self.container_size.height -(self.start_y + self.item_height *(1 - anchor_point.y) +(math.floor((index - 1) / self.col)) *(self.item_height + self.space_y))
        else
            _x = self.start_x + self.item_width * anchor_point.x +(self.item_width + self.space_x) *((index - 1) % self.col)
            _y = self.start_y + self.item_height * anchor_point.y +(math.floor((index - 1) / self.col)) *(self.item_height + self.space_y)
        end
    end
    return _x, _y
end

--获得格子下标对应的缓存itemCell
function CommonScrollViewSingleLayout:getCacheCellByIndex(index)
    local cacheIndex = (index - 1) % self.cacheMaxSize + 1
    if not self.cacheList[cacheIndex] then
        local newCell = self:createNewCell()
        if newCell then
            newCell:setAnchorPoint(cc.p(0.5, 0.5))
            newCell:setPositionX(-10000)--隐藏
            self.cacheList[cacheIndex] = newCell
            self.scroll_view:addChild(newCell)
        end
        return newCell
    else
        return self.cacheList[cacheIndex]
    end
end

--更新格子，并记为活跃
function CommonScrollViewSingleLayout:updateCellAtIndex(index)
    if index > self.time_show_index then
        return
    end
    if not self.cellList[index] then return end
    local cellData = self.cellList[index]
    if cellData.cell == nil then
        cellData.cell = self:getCacheCellByIndex(index)
    end
    cellData.cell:setPosition(cellData.x, cellData.y)
    self:updateCellByIndex(cellData.cell, index)
end




function CommonScrollViewSingleLayout:clearTimeTicket()
    if self.time_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.time_ticket)
        self.time_ticket = nil
    end
end 

function CommonScrollViewSingleLayout:getMaxSize()
    return self.container_size
end

function CommonScrollViewSingleLayout:getContainer()
    return self.container
end

function CommonScrollViewSingleLayout:scrollToPercentVertical( percent, time )
    self.scroll_view:scrollToPercentVertical(percent, time, true)
end

--==============================--
--desc:移除对象
--time:2018-07-12 10:49:17
--@return 
--==============================--
function CommonScrollViewSingleLayout:DeleteMe()
    doStopAllActions(self.container)
    self:clearTimeTicket()

    for k, item in ipairs(self.cacheList) do
        if item.DeleteMe then
            item:DeleteMe()
        end
    end
    self.cellList = nil
    self.activeCellIdx = nil
    self.cacheList = nil

    self:removeAllChildren()
    self:removeFromParent()
end

