--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-06-27 20:31:23
-- @description    : 
		-- 我的家具（家具、方案、图鉴）
---------------------------------
local _controller = HomeworldController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert

HomeworldMyUnit = HomeworldMyUnit or BaseClass()

function HomeworldMyUnit:__init( parent )
	self.parent = parent

	self:createRoorWnd()
    self:registerEvent()

    self.my_all_unit_data = {}
end

function HomeworldMyUnit:createRoorWnd(  )
	local csbPath = PathTool.getTargetCSB("homeworld/homeworld_my_unit")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self.root_wnd:setPosition(cc.p(0, 185))
    self.parent:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")

    self.image_bg = self.container:getChildByName("image_bg")

    self.type_btn_panel = self.container:getChildByName("type_btn_panel")

    local cur_soft_panel = self.container:getChildByName("cur_soft_panel")
    self.comfort_label = cur_soft_panel:getChildByName("comfort_label")

    local grid_num_panel = self.container:getChildByName("grid_num_panel")
    grid_num_panel:getChildByName("grid_num_title"):setString(TI18N("地面可用格子数:"))
    self.grid_num_txt = grid_num_panel:getChildByName("grid_num_txt")

    -- 家具
    self.unit_panel = self.container:getChildByName("unit_panel")
    self.sub_btn_panel = self.unit_panel:getChildByName("sub_btn_panel")
    self.unit_list = self.unit_panel:getChildByName("unit_list")

    -- 方案
    self.plan_panel = self.container:getChildByName("plan_panel")
    self.plan_tips_txt = self.plan_panel:getChildByName("tips_txt")
    self.plan_tips_txt:setString(TI18N("可将你当前的宅室布置保存为方案"))
    self.plan_list = self.plan_panel:getChildByName("plan_list")

    -- 图鉴
    self.book_panel = self.container:getChildByName("book_panel")
    self.book_tips_txt = self.book_panel:getChildByName("tips_txt")
    self.book_tips_txt:setString(TI18N("集齐指定数量的主题家具可获得收集奖励！"))
    self.book_list = self.book_panel:getChildByName("book_list")

    self.clear_btn = self.container:getChildByName("clear_btn")
    self.clear_btn:getChildByName("label"):setString(TI18N("清空装饰"))
    self.save_btn = self.container:getChildByName("save_btn")
    self.save_btn:getChildByName("label"):setString(TI18N("保存"))

    -- 引导需要
    self.save_btn:setName("guide_save_btn")

    self:initTypeBtnList()
end

function HomeworldMyUnit:registerEvent(  )
    -- 清空装饰
    registerButtonEventListener(self.clear_btn, function (  )
        local function fun()
            self:_onClickClearBtn()
        end
        local str = TI18N("确定是否清空所有家具？（墙壁、地板不会被清空）")
        CommonAlert.show(str, TI18N('确定'), fun, TI18N('取消'), nil, CommonAlert.type.rich, nil, nil, nil, true)
    end, true)

    -- 保存
    registerButtonEventListener(self.save_btn, function (  )
        GlobalEvent:getInstance():Fire(HomeworldEvent.Save_My_Home_Data_Event)
    end, true)

    -- 从场景中移除一个家具(进入家园仓库)
    if not self.discharge_unit_event then
        self.discharge_unit_event = GlobalEvent:getInstance():Bind(HomeworldEvent.Discharge_Furniture_Event, function(unit_bid) 
            if not self.cur_show_status then return end
            self:updateCurSoft()
            self:checkNeedUpdateItemNum(unit_bid, 1)
        end)
    end

    -- 场景中增加一个道具
    if not self.add_unit_event then
        self.add_unit_event = GlobalEvent:getInstance():Bind(HomeworldEvent.Add_Furniture_Event, function(unit_bid)
            if not self.cur_show_status then return end
            self:updateCurSoft()
            self:checkNeedUpdateItemNum(unit_bid, 2)
        end)
    end

    -- 背包中家具增加
    if not self.update_add_good_event then
        self.update_add_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS,function(bag_code, data_list)
            if bag_code ~= BackPackConst.Bag_Code.HOME then return end
            if not self.cur_show_status then return end
            self:checkAddMyUnitItem(data_list)
        end)
    end

    -- 背包中删除家具
    if not self.update_delete_good_event then
        self.update_delete_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS,function(bag_code, data_list)
            if bag_code ~= BackPackConst.Bag_Code.HOME then return end
            if not self.cur_show_status then return end
            self:checkDeleteMyUnitItem(data_list)
        end)
    end

    -- 背包中物品数量变化
    if not self.update_modify_good_event then
        self.update_modify_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM,function(bag_code, data_list)
            if bag_code ~= BackPackConst.Bag_Code.HOME then return end
            if not self.cur_show_status then return end
            self:checkUpdateBagItemNum(data_list)
        end)
    end

    -- 红点
    if not self.update_red_status_event then
        self.update_red_status_event = GlobalEvent:getInstance():Bind(HomeworldEvent.Update_Red_Status_Data,function(bid, status)
            if bid == HomeworldConst.Red_Index.Suit then
                self:updateSuitAwardRedStatus()
            end
        end)
    end
end

function HomeworldMyUnit:checkNeedUpdateItemNum( unit_bid, _type )
    if not self.unit_scrollview then return end
    local is_have = false
    for k,vo in pairs(self.my_all_unit_data) do
        if vo.base_id == unit_bid then
            is_have = true
            _type = _type or 1
            if _type == 1 then
                vo.have_num = vo.have_num + 1
            else
                vo.have_num = vo.have_num - 1
                if vo.have_num <= 0 then
                    vo.have_num = 0
                end
            end
        end
    end
    if is_have then
        self.unit_scrollview:resetCurrentItems()
    end
end

-- 背包中家具数量变化（仅仅是数量变化，不是新增或者删除）
function HomeworldMyUnit:checkUpdateBagItemNum( data_list )
    if not self.unit_scrollview then return end
    local is_have = false
    for k,vo in pairs(data_list) do 
        for _,v in pairs(self.my_all_unit_data) do
            if v.base_id == vo.base_id then
                local diff_num = vo.quantity - v.bag_num
                v.bag_num = vo.quantity
                v.have_num = v.have_num + diff_num
                is_have = true
                break
            end
        end
    end
    if is_have then
        self.unit_scrollview:resetCurrentItems()
    end
end

-- 清空家具
function HomeworldMyUnit:_onClickClearBtn(  )
    GlobalEvent:getInstance():Fire(HomeworldEvent.Clear_All_Furniture_Event)
    self.my_all_unit_data = {}
    -- 背包中的家具
    local all_unit = BackpackController:getInstance():getModel():getBagItemList(BackPackConst.Bag_Code.HOME)
    for k,v in pairs(all_unit) do
        _table_insert(self.my_all_unit_data, deepCopy(v))
    end
    for k,vo in pairs(self.my_all_unit_data) do
        vo.bag_num = vo.quantity or 0   -- 背包中的实际数据
        vo.have_num = vo.quantity or 0  -- ui显示上的数据
    end

    -- 其他楼层中场景中的家具
    local other_storey_unit_list = _model:getOtherStoreyFurnitureData()
    for k,v in pairs(other_storey_unit_list) do
        local is_have = false
        for _,vo in pairs(self.my_all_unit_data) do
            if vo.base_id == v.bid then
                is_have = true
                break
            end
        end
        if not is_have then
            local data = {}
            data.base_id = v.bid
            data.bag_num = 0
            data.have_num = 0
            local good_vo = GoodsVo.New()
            good_vo:initAttrData(data)
            _table_insert(self.my_all_unit_data, good_vo)
        end
    end

    -- 场景中的家具都放入仓库
    local scene_unit_list = _model:getMyHomeFurnitureData()
    for k,v in pairs(scene_unit_list) do
        local is_have = false
        for _,vo in pairs(self.my_all_unit_data) do
            if vo.base_id == v.bid then
                vo.have_num = vo.have_num + 1
                is_have = true
                break
            end
        end
        if not is_have then
            local data = {}
            data.base_id = v.bid
            data.bag_num = 0
            data.have_num = 1
            local good_vo = GoodsVo.New()
            good_vo:initAttrData(data)
            _table_insert(self.my_all_unit_data, good_vo)
        end
    end

    -- 场景中的墙壁
    local wall_bid = _model:getMyHomeWallId()
    if wall_bid and wall_bid ~= 0 then
        local is_have = false
        for _,vo in pairs(self.my_all_unit_data) do
            if vo.base_id == wall_bid then
                is_have = true
                break
            end
        end
        if not is_have then
            local data = {}
            data.base_id = wall_bid
            data.bag_num = 0
            data.have_num = 0
            local good_vo = GoodsVo.New()
            good_vo:initAttrData(data)
            _table_insert(self.my_all_unit_data, good_vo)
        end
    end
    -- 场景中的地板
    local floor_bid = _model:getMyHomeFloorId()
    if floor_bid and floor_bid ~= 0 then
        local is_have = false
        for _,vo in pairs(self.my_all_unit_data) do
            if vo.base_id == floor_bid then
                is_have = true
                break
            end
        end
        if not is_have then
            local data = {}
            data.base_id = floor_bid
            data.bag_num = 0
            data.have_num = 0
            local good_vo = GoodsVo.New()
            good_vo:initAttrData(data)
            _table_insert(self.my_all_unit_data, good_vo)
        end
    end

    self:updateMyUnitShowData()
    self.unit_scrollview:reloadData(nil, nil, true)
end

function HomeworldMyUnit:checkAddMyUnitItem( data_list )
    if not self.unit_scrollview then return end
    local need_reload = false
    for k,vo in pairs(data_list) do
        local is_have = false 
        for _,v in pairs(self.my_all_unit_data) do
            if v.base_id == vo.base_id then
                v.bag_num = v.bag_num + 1
                v.have_num = v.have_num + 1
                is_have = true
                break
            end
        end
        if not is_have then
            local data = deepCopy(vo)
            data.bag_num = data.quantity or 0   -- 背包中的实际数据
            data.have_num = data.quantity or 0  -- ui显示上的数据
            _table_insert(self.my_all_unit_data, data)
            need_reload = true
        end 
    end
    if need_reload then
        self:updateMyUnitShowData()
        self.unit_scrollview:reloadData(nil, nil, true)
    else
        self.unit_scrollview:resetCurrentItems()
    end
end

function HomeworldMyUnit:checkDeleteMyUnitItem( data_list )
    local need_reload = false
    for k,vo in pairs(data_list) do
        for i=#self.my_all_unit_data,1,-1 do
            local u_data = self.my_all_unit_data[i]
            if u_data.base_id == vo.base_id then
                u_data.have_num = u_data.have_num - u_data.bag_num
                u_data.bag_num = 0
                -- 如果总数为0，并且当前场景中也没有该家具，则清掉
                if u_data.have_num == 0 and not _controller:checkCurHomeIsHaveUnitByBid(u_data.base_id) then
                    table.remove(self.my_all_unit_data, i)
                end
                need_reload = true
                break
            end
        end
    end
    if need_reload then
        self:updateMyUnitShowData()
        self.unit_scrollview:reloadData(nil, nil, true)
    end
end

function HomeworldMyUnit:open(  )
    self:updateCurSoft()
    if not self.unit_scrollview then return end

    self:initAllUnitData()
    self:updateMyUnitShowData()
    self.unit_scrollview:reloadData(nil, nil, true)
end

-- 初始化所有家具数据 is_clear:是否为清空家具
function HomeworldMyUnit:initAllUnitData(  )
    self.my_all_unit_data = {}
    -- 背包中的家具
    local all_unit = BackpackController:getInstance():getModel():getBagItemList(BackPackConst.Bag_Code.HOME)
    for k,v in pairs(all_unit) do
        _table_insert(self.my_all_unit_data, deepCopy(v))
    end
    for k,vo in pairs(self.my_all_unit_data) do
        vo.bag_num = vo.quantity or 0   -- 背包中的实际数据
        vo.have_num = vo.quantity or 0  -- ui显示上的数据
    end

    -- 本楼场景中有，但背包中没有的家具
    local scene_unit_list = _model:getMyHomeFurnitureData()
    for k,v in pairs(scene_unit_list) do
        local bag_num = BackpackController:getInstance():getModel():getItemNumByBid(v.bid, BackPackConst.Bag_Code.HOME)
        if bag_num <= 0 then
            local is_have = false
            for _,vo in pairs(self.my_all_unit_data) do
                if vo.base_id == v.bid then
                    is_have = true
                    break
                end
            end
            if not is_have then
                local data = {}
                data.base_id = v.bid
                data.bag_num = 0
                data.have_num = 0
                local good_vo = GoodsVo.New()
                good_vo:initAttrData(data)
                _table_insert(self.my_all_unit_data, good_vo)
            end
        end
    end
    -- 其他楼层中场景中的家具
    local other_storey_unit_list = _model:getOtherStoreyFurnitureData()
    for k,v in pairs(other_storey_unit_list) do
        local is_have = false
        for _,vo in pairs(self.my_all_unit_data) do
            if vo.base_id == v.bid then
                is_have = true
                break
            end
        end
        if not is_have then
            local data = {}
            data.base_id = v.bid
            data.bag_num = 0
            data.have_num = 0
            local good_vo = GoodsVo.New()
            good_vo:initAttrData(data)
            _table_insert(self.my_all_unit_data, good_vo)
        end
    end

    -- 场景中的墙壁
    local wall_bid = _model:getMyHomeWallId()
    if wall_bid and wall_bid ~= 0 then
        local is_have = false
        for _,vo in pairs(self.my_all_unit_data) do
            if vo.base_id == wall_bid then
                is_have = true
                break
            end
        end
        if not is_have then
            local data = {}
            data.base_id = wall_bid
            data.bag_num = 0
            data.have_num = 0
            local good_vo = GoodsVo.New()
            good_vo:initAttrData(data)
            _table_insert(self.my_all_unit_data, good_vo)
        end
    end
    -- 场景中的地板
    local floor_bid = _model:getMyHomeFloorId()
    if floor_bid and floor_bid ~= 0 then
        local is_have = false
        for _,vo in pairs(self.my_all_unit_data) do
            if vo.base_id == floor_bid then
                is_have = true
                break
            end
        end
        if not is_have then
            local data = {}
            data.base_id = floor_bid
            data.bag_num = 0
            data.have_num = 0
            local good_vo = GoodsVo.New()
            good_vo:initAttrData(data)
            _table_insert(self.my_all_unit_data, good_vo)
        end
    end
end

-- 初始化Tab按钮列表
function HomeworldMyUnit:initTypeBtnList(  )
	self.tab_array = {
        {title = TI18N("装饰"), index = 1},
        --{title = TI18N("方案"), index = 2},
        {title = TI18N("图鉴"), index = 3},
    }

    local bgSize = self.type_btn_panel:getContentSize()
    local scroll_view_size = cc.size(bgSize.width, bgSize.height)
    local setting = {
        item_class = CommonTabBtn,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = -5,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 149,               -- 单元的尺寸width
        item_height = 61,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
    }
    self.tab_scrollview = CommonScrollViewLayout.new(self.type_btn_panel, cc.p(0, 0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.tab_scrollview:setData(self.tab_array, handler(self, self._onClickTabBtn), nil, {default_index = 1, tab_size = cc.size(149, 61), red_offset = cc.p(7, -4), red_scale = 0.7,title_offset = cc.p(0,-5)})
    self.tab_scrollview:setClickEnabled(#self.tab_array > 4)
    self.tab_scrollview:addEndCallBack(function (  )
        self.tab_btn_list = self.tab_scrollview:getItemList()
        self:updateSuitAwardRedStatus()
    end)
end

-- 点击Tab按钮
function HomeworldMyUnit:_onClickTabBtn( tab_btn )
	if self.cur_tab_btn then
        self.cur_tab_btn:setBtnSelectStatus(false)
    end

    if tab_btn then
        self.cur_tab_btn = tab_btn
        self.cur_tab_btn:setBtnSelectStatus(true)

        self:updateSubTabBtn(tab_btn.index)
    end
end

function HomeworldMyUnit:updateSubTabBtn( index )
	if index == 1 then -- 装饰
		self.image_bg:setContentSize(cc.size(669, 184))
		if not self._init_unit then
			self._init_unit = true
			self:initUnitPanel()
		end
	elseif index == 2 then -- 方案
		self.image_bg:setContentSize(cc.size(669, 208))
		if not self._init_plan then
			self._init_plan = true
			self:initPlanPanel()
		end
	elseif index == 3 then -- 图鉴
		self.image_bg:setContentSize(cc.size(669, 208))
		if not self._init_book then
			self._init_book = true
			self:initBookPanel()
		end
	end
	self.unit_panel:setVisible(index == 1)
	self.plan_panel:setVisible(index == 2)
	self.book_panel:setVisible(index == 3)
end

-- 初始化家具
function HomeworldMyUnit:initUnitPanel(  )
	local bgSize = self.unit_list:getContentSize()
    local scroll_view_size = cc.size(bgSize.width, bgSize.height)
    local setting = {
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 5,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 155,               -- 单元的尺寸width
        item_height = 172,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.unit_scrollview = CommonScrollViewSingleLayout.new(self.unit_list, cc.p(0, 0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.unit_scrollview:setSwallowTouches(true)

    self.unit_scrollview:registerScriptHandlerSingle(handler(self,self._createNewCellUnit), ScrollViewFuncType.CreateNewCell) --创建cell
    self.unit_scrollview:registerScriptHandlerSingle(handler(self,self._numberOfCellsUnit), ScrollViewFuncType.NumberOfCells) --获取数量
    self.unit_scrollview:registerScriptHandlerSingle(handler(self,self._updateCellByIndexUnit), ScrollViewFuncType.UpdateCellByIndex) --更新cell

    self:initAllUnitData()

    self.sub_tab_array = {
        {title = TI18N("墙壁"), index = 1},
        {title = TI18N("地板"), index = 2},
        {title = TI18N("墙饰"), index = 3},
        {title = TI18N("家具"), index = 4},
        {title = TI18N("地毯"), index = 5},
    }
    if not self.sub_tab_scrollview then
        local panel_size = self.sub_btn_panel:getContentSize()
        self.sub_tab_scrollview = CommonSubBtnList.new(self.sub_btn_panel, cc.p(0.5, 0.5), cc.p(panel_size.width*0.5, panel_size.height*0.5), cc.size(101, 50), handler(self, self._onClickSubTabBtn))
    end
    self.sub_tab_scrollview:setData(self.sub_tab_array, 1)
    self.sub_tab_scrollview:setGuideName("my_unit_")
end

function HomeworldMyUnit:_createNewCellUnit(  )
	local cell = HomeworldMyUnitItem.new()
    cell:addCallBack(handler(self, self._onClickMyUnitCallback))
    return cell
end

function HomeworldMyUnit:_numberOfCellsUnit(  )
	if not self.show_unit_data then return 0 end
    return #self.show_unit_data
end

function HomeworldMyUnit:_updateCellByIndexUnit( cell, index )
	if not self.show_unit_data then return end
    cell.index = index
    local cell_data = self.show_unit_data[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function HomeworldMyUnit:_onClickMyUnitCallback( unit_bid )
    for k,v in pairs(self.my_all_unit_data) do
        if v.base_id == unit_bid then
            v.quantity = v.quantity - 1
            is_have = true
            break
        end
    end    
    -- 通知家园场景添加一个家具
    GlobalEvent:getInstance():Fire(HomeworldEvent.Add_One_Furniture_Event, unit_bid)
end

function HomeworldMyUnit:_onClickSubTabBtn( index )
    if self.cur_myunit_index and self.cur_myunit_index == index then return end
    self.cur_myunit_index = index

    self:updateMyUnitShowData()
    self.unit_scrollview:reloadData()
end

function HomeworldMyUnit:updateMyUnitShowData(  )
    if not self.cur_myunit_index then return end

    local unit_type
    if self.cur_myunit_index == 1 then -- 墙壁
        unit_type = HomeworldConst.Unit_Type.Wall
    elseif self.cur_myunit_index == 2 then -- 地板
        unit_type = HomeworldConst.Unit_Type.Floor
    elseif self.cur_myunit_index == 3 then -- 墙饰
        unit_type = HomeworldConst.Unit_Type.WallAcc
    elseif self.cur_myunit_index == 4 then -- 家具
        unit_type = HomeworldConst.Unit_Type.Furniture
    elseif self.cur_myunit_index == 5 then -- 地毯
        unit_type = HomeworldConst.Unit_Type.Carpet
    end
    if unit_type and self.my_all_unit_data then
        self.show_unit_data = {}
        for k,v in pairs(self.my_all_unit_data) do
            if v.unit_type == unit_type then
                _table_insert(self.show_unit_data, v)
            end
        end
        table.sort(self.show_unit_data, SortTools.KeyLowerSorter("bid"))
    end
end

-- 初始化方案
function HomeworldMyUnit:initPlanPanel(  )
	local bgSize = self.plan_list:getContentSize()
    local scroll_view_size = cc.size(bgSize.width, bgSize.height)
    local setting = {
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 5,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 155,               -- 单元的尺寸width
        item_height = 196,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.plan_scrollview = CommonScrollViewSingleLayout.new(self.plan_list, cc.p(0, 0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.plan_scrollview:setSwallowTouches(true)

    self.plan_scrollview:registerScriptHandlerSingle(handler(self,self._createNewCellPlan), ScrollViewFuncType.CreateNewCell) --创建cell
    self.plan_scrollview:registerScriptHandlerSingle(handler(self,self._numberOfCellsPlan), ScrollViewFuncType.NumberOfCells) --获取数量
    self.plan_scrollview:registerScriptHandlerSingle(handler(self,self._updateCellByIndexPlan), ScrollViewFuncType.UpdateCellByIndex) --更新cell

    -- test
    self.my_plan_data = {}
    for i=1,10 do
    	local test_aa = {}
    	table.insert(self.my_plan_data, test_aa)
    end

    self.plan_scrollview:reloadData()
end

function HomeworldMyUnit:_createNewCellPlan(  )
	local cell = HomeworldMyPlanItem.new(2)
    --cell:addCallBack(handler(self, self._onClickShareBtn))
    return cell
end

function HomeworldMyUnit:_numberOfCellsPlan(  )
	if not self.my_plan_data then return 0 end
    return #self.my_plan_data
end

function HomeworldMyUnit:_updateCellByIndexPlan( cell, index )
	if not self.my_plan_data then return end
    cell.index = index
    local cell_data = self.my_plan_data[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

-- 初始化图鉴
function HomeworldMyUnit:initBookPanel(  )
	local bgSize = self.book_list:getContentSize()
    local scroll_view_size = cc.size(bgSize.width, bgSize.height)
    local setting = {
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 5,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 155,               -- 单元的尺寸width
        item_height = 196,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.book_scrollview = CommonScrollViewSingleLayout.new(self.book_list, cc.p(0, 0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.book_scrollview:setSwallowTouches(true)

    self.book_scrollview:registerScriptHandlerSingle(handler(self,self._createNewCellBook), ScrollViewFuncType.CreateNewCell) --创建cell
    self.book_scrollview:registerScriptHandlerSingle(handler(self,self._numberOfCellsBook), ScrollViewFuncType.NumberOfCells) --获取数量
    self.book_scrollview:registerScriptHandlerSingle(handler(self,self._updateCellByIndexBook), ScrollViewFuncType.UpdateCellByIndex) --更新cell

    self.my_book_data = {}
    for k,cfg in pairs(Config.HomeData.data_suit) do
        _table_insert(self.my_book_data, cfg)
    end
    table.sort(self.my_book_data, SortTools.KeyLowerSorter("set_id"))
    self.book_scrollview:reloadData()
end

function HomeworldMyUnit:_createNewCellBook(  )
    local cell = HomeworldMyPlanItem.new(1)
    return cell
end

function HomeworldMyUnit:_numberOfCellsBook(  )
    if not self.my_book_data then return 0 end
    return #self.my_book_data
end

function HomeworldMyUnit:_updateCellByIndexBook( cell, index )
    if not self.my_book_data then return end
    cell.index = index
    local cell_data = self.my_book_data[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function HomeworldMyUnit:setVisible( status )
    self.cur_show_status = status
	self.root_wnd:setVisible(status)
end

-- 更新当前舒适度、格子数
function HomeworldMyUnit:updateCurSoft(  )
    local cur_soft_val = _controller:getCurHomeSoftVal()
    local comfort_limit_cfg = Config.HomeData.data_const["comfort_limit"]
    if comfort_limit_cfg then
        self.comfort_label:setString(cur_soft_val .. "/" .. comfort_limit_cfg.val)
    else
        self.comfort_label:setString(cur_soft_val)
    end

    local cur_grid_num = _controller:getCurOccupyGridNum()
    local max_num_cfg = Config.HomeData.data_const["floor_effective_area_limit"]
    if max_num_cfg then
        self.grid_num_txt:setString(cur_grid_num .. "/" .. max_num_cfg.val)
    else
        self.grid_num_txt:setString(cur_grid_num)
    end
end

-- 更新套装红点显示
function HomeworldMyUnit:updateSuitAwardRedStatus(  )
    if not self.tab_btn_list then return end
    for k,tab_btn in pairs(self.tab_btn_list) do
        if tab_btn:getIndex() == 3 then
            local red_status = _model:getRedStatusById(HomeworldConst.Red_Index.Suit)
            tab_btn:setRedStatus(red_status)
            break
        end
    end
end

function HomeworldMyUnit:__delete(  )
    if self.tab_scrollview then
    	self.tab_scrollview:DeleteMe()
    	self.tab_scrollview = nil
    end
    if self.sub_tab_scrollview then
    	self.sub_tab_scrollview:DeleteMe()
    	self.sub_tab_scrollview = nil
    end
    if self.unit_scrollview then
    	self.unit_scrollview:DeleteMe()
    	self.unit_scrollview = nil
    end
    if self.plan_scrollview then
        self.plan_scrollview:DeleteMe()
        self.plan_scrollview = nil
    end
    if self.book_scrollview then
        self.book_scrollview:DeleteMe()
        self.book_scrollview = nil
    end
    if self.discharge_unit_event then
        GlobalEvent:getInstance():UnBind(self.discharge_unit_event)
        self.discharge_unit_event = nil
    end
    if self.add_unit_event then
        GlobalEvent:getInstance():UnBind(self.add_unit_event)
        self.add_unit_event = nil
    end
    if self.update_add_good_event then
        GlobalEvent:getInstance():UnBind(self.update_add_good_event)
        self.update_add_good_event = nil
    end
    if self.update_delete_good_event then
        GlobalEvent:getInstance():UnBind(self.update_delete_good_event)
        self.update_delete_good_event = nil
    end
    if self.update_modify_good_event then
        GlobalEvent:getInstance():UnBind(self.update_modify_good_event)
        self.update_modify_good_event = nil
    end
    if self.update_red_status_event then
        GlobalEvent:getInstance():UnBind(self.update_red_status_event)
        self.update_red_status_event = nil
    end
end