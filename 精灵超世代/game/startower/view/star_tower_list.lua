-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @description:
--      自动意义的scrollview 试练塔的
-- <br/>Create: 2019年2月12日
--
-- --------------------------------------------------------------------
local table_insert = table.insert
local table_remove = table.remove
local table_sort = table.sort

local controller = StartowerController:getInstance()


StarTowerList = class("StarTowerList", function()
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

function StarTowerList:ctor(parent, pos, size)
    self.parent = parent
    self.pos = pos or cc.p(0, 0)
    self.dir = ScrollViewDir.vertical
    self.start_pos = ScrollViewStartPos.bottom
    self.size = size or cc.size(100, 100)
    self.ap = cc.p(0.5, 0)

      --存放所有格子结构体
    self.cellList = {}
    --缓存Cell所用到的对象
    self.cacheList = {}
    --记录活跃得格子ID
    self.activeCellIdx = {}
    --当前选择物品的索引
    self.selectCellIndex = 1
    --函数句柄
    self.handler = {}

    self.start_x        = 161             -- 第一个单元的起点X
    self.space_x        = 0             -- 横向间隔空间
    self.start_y        = 250             -- 第一个单元的起点Y
    self.space_y        = 0             -- 竖向间隔空间
    self.item_width     = 392        -- 单元的宽度
    self.item_height    = 153       -- 单元的高度

    self.col            = 1               -- 列数,作用于垂直方向的滚动
    
    --计算一个屏幕最大数量
    self.cacheMaxSize = (math.ceil(self.size.height / (self.item_height + self.space_y)) + 1) * self.col
    
    self:createRootWnd()

    --背景相对塔移动的系数
    self.bg_param = 3
end

function StarTowerList:createRootWnd()
    self:setContentSize(self.size)
    if not tolua.isnull(self.parent) then
        self.parent:addChild(self)
    end
    self:setPosition(self.pos)
    self:setAnchorPoint(self.ap)

    self.scroll_view = createScrollView(self.size.width, self.size.height, 0, 0, self, self.dir) 
    self.scroll_view:setBounceEnabled(false)
    self.scroll_view:setZOrder(2)
    self.container = self.scroll_view:getInnerContainer() 
    self:registerEvent()
end

--==============================--
--desc:注册事件
--time:2018-07-12 10:33:12
--@return 
--==============================--
function StarTowerList:registerEvent()
    self.scroll_view:addEventListener(function(sender, eventType)
        if eventType == ccui.ScrollviewEventType.containerMoved then
            self:checkRectIntersectsRect()
        end
    end)
end

-- 注册回调方法
function StarTowerList:registerScriptHandlerSingle(func, handlerId)
    self.handler[handlerId] = func
end

--获取cell数量
function StarTowerList:numberOfCells()
    if not self.handler[ScrollViewFuncType.NumberOfCells] then return end
    return self.handler[ScrollViewFuncType.NumberOfCells]()
end

--刷新每一个cell 
function StarTowerList:updateCellByIndex(cell, index)
    if not self.handler[ScrollViewFuncType.UpdateCellByIndex] then return end
    self.handler[ScrollViewFuncType.UpdateCellByIndex](cell, index)
end

--创建一个新cell
function StarTowerList:createNewCell()
    if not self.handler[ScrollViewFuncType.CreateNewCell] then return end
    return self.handler[ScrollViewFuncType.CreateNewCell](self.item_width, self.item_height)
end

-- --点击cell --在createNewCell 自行实现
function StarTowerList:onCellTouched(cell, index)
    if not self.handler[ScrollViewFuncType.OnCellTouched] then return end
    self.handler[ScrollViewFuncType.OnCellTouched](cell, index)
end


--设置 scrollview 是否可点
function StarTowerList:setClickEnabled(status)
    self.scroll_view:setTouchEnabled(status)
end
--设置 是否吞噬点击
function StarTowerList:setSwallowTouches(status)
    self.scroll_view:setSwallowTouches(status)
end

--==============================--
--desc:移动的过程中盘点是否不再可视范围,不再的时候移除掉,放到对象池,并且准备下一次创建
--time:2018-07-20 12:13:25
--@return 
--==============================--
function StarTowerList:checkRectIntersectsRect()
    if self.dir == ScrollViewDir.vertical then
        self:checkOverShowByVertical()
    end
end

--==============================--
--desc:竖直方向的监测判断
--time:2018-07-20 03:11:13
--@return 
--==============================--
function StarTowerList:checkOverShowByVertical()
    if not self.cellList then return end

    local container_y = self.container:getPositionY()
    if self.scroll_view_bg then
        local container = self.scroll_view_bg:getContainer()
        if container then
            container:setPositionY(container_y/self.bg_param)
            self.scroll_view_bg:checkOverShowByVerticalBottom()
        end
    end
    --计算 视图的上部分和下部分在self.container 的位置
    local bot = -container_y
    local top = self.size.height + bot
    local col_count = math.ceil(#self.cellList/self.col)
    --下面因为 self.cellList 是一维数组 所以要换成二维来算
    --活跃cell开始行数
    local activeCellStartRow = col_count
    for i= col_count, 1, -1 do
        local index = 1 + (i-1)* self.col
        local cell = self.cellList[index]
        activeCellStartRow = i
        if cell and cell.y <= top then
            break
        end
    end
    --活跃cell结束行数
    local activeCellEndRow = 1
    if bot > 0 then
        for i = activeCellStartRow, 1, -1 do
            local index = 1 + (i-1)* self.col
            local cell = self.cellList[index]
            if cell and cell.y + self.item_height < bot then
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

    self:updateArrowPos(top, bot)
end

--==============================--
--desc:滚动容器移动到指定位置
--time:2018-07-12 10:34:41
--@pos:
--@return 
--==============================--
function StarTowerList:updateMove(pos)
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
function StarTowerList:jumpToMove(pos, time, callback)
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
function StarTowerList:checkPosition(x, y)
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
function StarTowerList:setInnerContainer()
    local number = self:numberOfCells()
    local container_width = self.size.width
    local num = math.ceil(number / self.col)
    local container_height = num * self.item_height + 2 * self.start_y + (num - 1) * self.space_y

    --加上塔顶 
    container_height  = container_height + 453 -- 根据塔顶图片高度决定的    
    --塔底座 在这里 self.start_y 算了

    container_height = math.max(container_height, self.size.height)
    self.container_size = cc.size(container_width, container_height)
    self.scroll_view:setInnerContainerSize(self.container_size)
    if self.start_pos == ScrollViewStartPos.bottom then
        self.scroll_view:jumpToBottom()
    end
end

--刷新当前显示的item数据 (不改变任何位置的)
function StarTowerList:resetCurrentItems()
    for i,v in pairs(self.activeCellIdx) do
        if v then
            self:updateCellAtIndex(i)
        end
    end
end

--根据index 刷新对应索引..如果在显示视图内
function StarTowerList:resetItemByIndex(index)
    -- body
    if self.activeCellIdx[index] then
        self:updateCellAtIndex(index)
    end
end

--获取活跃中的cell对象
function StarTowerList:getActiveCellList()
    local list = {}
    for i,v in pairs(self.activeCellIdx) do
        if v and self.cellList[i] and self.cellList[i].cell then
            table_insert(list, self.cellList[i].cell)
        end
    end
    return list
end

--获取index索引对应cell(不管是否活跃)
function StarTowerList:getCellByIndex(index)
    if  self.cellList[index] and self.cellList[index].cell then
        return self.cellList[i].cell
    end
end

--获取index索引对应cellXY位置(不管是否活跃)
function StarTowerList:getCellXYByIndex(index)
    if  self.cellList[index] and self.cellList[index].cell then
        return self.cellList[i].x, self.cellList[i].y 
    end
end


--==============================--
--desc:设置数据
--select_idnex 从第几个开始
--@setting: 如果有改变的话
--==============================--
function StarTowerList:reloadData(select_index)
    self.cellList = {}
    self.activeCellIdx = {}

    for k, v in ipairs(self.cacheList) do
        --相当于隐藏
        v:setPositionX(-10000)
    end
    --设置容器大小
    -- self:setInnerContainer()

    local number = self:numberOfCells()
    if number == 0 then
        return
    end

    --先初始化中间背景
    -- self:updateBgList()

    for i = 1, number do
        local cell = self:getCacheCellByIndex(i)
        local count = #self.cellList
        local x, y = self:getCellPosition(count + 1)
        local cellData = {cell = cell, x = x, y = y}
        table_insert(self.cellList, cellData)
    end

    if select_index == nil then
        local maxRefreshNum = self.cacheMaxSize - self.col
        local refreshNum = number < maxRefreshNum and number or maxRefreshNum

        for i = 1, refreshNum do
            self:updateCellAtIndex(i)
            self.activeCellIdx[i] = true
        end
    else
        self:selectCellByIndex(select_index)
    end
    --显示人物箭头
    self:showArrow()

    --延迟加个塔底
    delayRun(self,1 / display.DEFAULT_FPS,function ()
        if self.bottom_bg == nil then
            local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_28")
            self.bottom_bg = createImage(self.container, res, self.start_x + self.item_width * 0.5, 52, cc.p(0.5,0), false, 3, false)
        end 
    end)
   
    --加个塔顶
    delayRun(self,2 / display.DEFAULT_FPS,function ()
        if self.top_bg == nil then
            local y = self.cellList[number].y + self.item_height
            local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_29")
            self.top_bg = createImage(self.container, res, self.start_x + self.item_width * 0.5, y, cc.p(0.5,0), false, 3, false)
        end
    end)
end

function StarTowerList:jumpToMoveByY(y)
    if not y then return end
    local pos = self.container_size.height - (y + self.size.height * 0.5 )
    if pos < 0 then
        pos = 0
    end
    local pos_per = pos * 100 / (self.container_size.height - self.size.height)
    if pos_per > 100 then
        pos_per = 100
    end
    if pos_per == 100 then
        self:checkOverShowByVertical()
    end
    self.scroll_view:scrollToPercentVertical(pos_per, 0.5, true)
end
-----------------------中间背景的代码开始-----------------------------------------------------------
function StarTowerList:updateBgList()
    if self.scroll_view_bg == nil then
        local height = self.container_size.height/self.bg_param
        local scroll_view_size = self.size
        local scale = display.getMaxScale()
        local bg_height = 1280 * scale --循环图的高度

        self.bg_max_count = math.ceil(height/bg_height) + 1
        local list_setting = {
            start_x = 0,
            space_x = 0,
            start_y = 0,
            space_y = 0,
            item_width = 720,
            item_height = bg_height,
            row = 0,
            col = 1,
        }
        self.scroll_view_bg = CommonScrollViewSingleLayout.new(self, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.bottom, scroll_view_size, list_setting, cc.p(0, 0)) 
        self.scroll_view_bg.time_show_index = self.bg_max_count + 1
        self.scroll_view_bg:registerScriptHandlerSingle(handler(self,self.createNewCellBg), ScrollViewFuncType.CreateNewCell) --创建cell
        self.scroll_view_bg:registerScriptHandlerSingle(handler(self,self.numberOfCellsBg), ScrollViewFuncType.NumberOfCells) --获取数量
        -- self.scroll_view_bg:registerScriptHandlerSingle(handler(self,self.updateCellByIndexBg), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        -- self.scroll_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
        self.scroll_view_bg:setTouchEnabled(false)

        delayRun(self,3 / display.DEFAULT_FPS,function ()
            if self.scroll_view_bottom_bg == nil then
                local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_27",true)
                local container = self.scroll_view_bg:getContainer()
                self.scroll_view_bottom_bg =  createImage(container, res,self.container_size.width/2, 0, cc.p(0.5,0), false, 1, false)
                self.scroll_view_bottom_bg:setScale(display.getMaxScale())
            end
        end)
    end
    self.scroll_view_bg:reloadData()
end

--创建cell 
function StarTowerList:createNewCellBg()
    local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_36",true)
    local cell =  createImage(nil, res, nil, nil, cc.p(0.5,0.5), false, 0, false)
    cell:setScale(display.getMaxScale())
    return cell
end
--获取数据数量
function StarTowerList:numberOfCellsBg()
    return self.bg_max_count or 0
end
-----------------------中间背景的代码结束-----------------------------------------------------------

--人物箭头
function StarTowerList:showArrow()
    if not self.arrow_btn then
        local res = PathTool.getResFrame("startower","star_tower_1")
        self.arrow_btn = createButton(self.container, "",0,0, nil, res)
        self.arrow_btn:setZOrder(10)
        self.arrow_btn:setAnchorPoint(cc.p(0, 0.5))
        local role_vo = RoleController:getInstance():getRoleVo()
        self.head = PlayerHead.new(PlayerHead.type.circle)
        self.head:setHeadLayerScale(0.6)
        self.head:setPosition(47, 35)
        self.arrow_btn:addChild(self.head,10)
        self.head:setHeadRes(role_vo.face_id, false, LOADTEXT_TYPE, role_vo.face_file, role_vo.face_update_time)
        self.arrow_btn:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                self:moveToArrowNewPosition()
            end
        end)
    end
    self:setNowArrowPos()
end

--移动人物箭头到最新位置
function StarTowerList:moveToArrowNewPosition()
    local index = controller:getModel():getNowTowerId() or 0
    index = index + 1
    local cellData = self.cellList[index]
    if not cellData then return end
    self:jumpToMoveByY(cellData.y)
    self:setNowArrowPos()
end

function StarTowerList:setNowArrowPos()
    if not self.arrow_btn then return end
    local index = controller:getModel():getNowTowerId() or 0
    index = index + 1 
    local number = self:numberOfCells()
    if index > number then
        index = number
    end
    local cellData = self.cellList[index]
    if not cellData then return end
    local x = cellData.x + self.item_width * 0.5 - 5
    local y = cellData.y + self.item_height * 0.5
    self.arrow_height = y
    self.arrow_btn:setPosition(x, y)
end

--箭头逻辑
--@top 当前self.container对应屏幕 的顶部 y位置
--@bot 当前self.container对应屏幕 的底部 y位置
function StarTowerList:updateArrowPos(top, bot)
    if not self.arrow_height then return end

    local top_param = 140
    local bot_param = 245
    if top - top_param <= self.arrow_height then
        self.arrow_btn:setPositionY(top - top_param)
    elseif bot + bot_param >= self.arrow_height then
        self.arrow_btn:setPositionY(bot + bot_param)
    else
        self.arrow_btn:setPositionY(self.arrow_height)
    end
end

--选中index索引对象(如果列表允许 会排序在开始第一位)
function StarTowerList:selectCellByIndex(index)
    --一屏幕显示的最大数量
    local maxRefreshNum = self.cacheMaxSize - self.col
    local number = self:numberOfCells()
    if number < maxRefreshNum then
        --不够显示一屏幕
        for i = 1, number do
            self:updateCellAtIndex(i)
            self.activeCellIdx[i] = true
        end
    else
        local container_y
        if index <= 1 then
            container_y = 0
        else
            container_y = self.cellList[index].y + self.item_height - self.size.height * 0.5 
        end
        if container_y < 0 then
            container_y = 0
        end
        self.container:setPositionY(- container_y)
        self:checkOverShowByVertical()
    end

    -- if index > 0 and index <= self:numberOfCells() then
    --     local cell = self:getCacheCellByIndex(index)
    --     cell.index = index
    --     self.cellList[index].cell = cell
    --     self:onCellTouched(cell, index)
    -- end 
end

--获取index 对应的位置 由于一开始不创建item  
--@return 是[index]对象所在的中点
function StarTowerList:getCellPosition(index)
    local anchor_point = cc.p(0.5,0)
    local _x = self.start_x + self.item_width * anchor_point.x +(self.item_width + self.space_x) *((index - 1) % self.col)
    local _y = self.start_y + self.item_height * anchor_point.y +(math.floor((index - 1) / self.col)) *(self.item_height + self.space_y)
    return _x, _y
end

--获得格子下标对应的缓存itemCell
function StarTowerList:getCacheCellByIndex(index)
    local cacheIndex = (index - 1) % self.cacheMaxSize + 1
    if not self.cacheList[cacheIndex] then
        local newCell = self:createNewCell()
        if newCell then
            newCell:setAnchorPoint(cc.p(0.5, 0))
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
function StarTowerList:updateCellAtIndex(index)
    if not self.cellList[index] then return end

    local cellData = self.cellList[index]
    cellData.cell:setPosition(cellData.x, cellData.y)
    self:updateCellByIndex(cellData.cell, index)
end

function StarTowerList:getMaxSize()
    return self.container_size
end

function StarTowerList:getContainer()
    return self.container
end

--==============================--
--desc:移除对象
--time:2018-07-12 10:49:17
--@return 
--==============================--
function StarTowerList:DeleteMe()
    doStopAllActions(self)
    doStopAllActions(self.container)
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

