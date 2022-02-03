--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-06-20 14:42:00
-- @description    : 
		-- 宅室商店
---------------------------------
local _controller = HomeworldController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert

HomeworldShopWindow = HomeworldShopWindow or BaseClass(BaseView)

function HomeworldShopWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "homeworld/homeworld_shop_window"

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("homeworld", "homeworld"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("homeworld","homeworld_big_bg_2"), type = ResourcesType.single },
	}

	self.res_object_list = {} -- 资产
	self.show_item_data = {} 	   -- 当前展示的商品数据
	self.furniture_shop_data = {}  -- 家具商城的物品购买数据
	self.pet_shop_data = {} 	   -- 出行商城的物品购买数据
	self.random_shop_data = {}

	self.role_vo = RoleController:getInstance():getRoleVo()
end

function HomeworldShopWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container , 1) 

	local title_icon = main_container:getChildByName("title_icon")
	local title_icon_res = PathTool.getPlistImgForDownLoad("homeworld","homeworld_big_bg_2")
	self.title_load = loadSpriteTextureFromCDN(title_icon, title_icon_res, ResourcesType.single, self.title_load)

	self.close_btn = main_container:getChildByName("close_btn")
	self.close_btn:setName("guide_close_btn")
	self.refresh_btn = main_container:getChildByName("refresh_btn")
	self.refresh_btn:setVisible(false)
	local btn_size = self.refresh_btn:getContentSize()
	self.refresh_btn_label = createRichLabel(26, 1, cc.p(0.5, 0.5), cc.p(btn_size.width/2, btn_size.height/2))
	self.refresh_btn:addChild(self.refresh_btn_label)
	self.btn_rule = main_container:getChildByName("btn_rule")
	self.btn_rule:setVisible(false)
	self.txt_time = main_container:getChildByName("txt_time")
	self.title_time = main_container:getChildByName("title_time"):setString(TI18N("免费刷新:"))

	main_container:getChildByName("win_title"):setString(TI18N("宅室商店"))
	main_container:getChildByName("tips_label"):setString(TI18N("随机商店中有几率出现稀有家具"))

	for i=1,2 do
		local object = {}
		object.res_icon = main_container:getChildByName("res_icon_" .. i)
		object.res_label = main_container:getChildByName("res_label_" .. i)
		_table_insert(self.res_object_list, object)
	end

	local list_panel = main_container:getChildByName("list_panel")
	local scroll_view_size = list_panel:getContentSize()
    local setting = {
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 7,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 7,                   -- y方向的间隔
        item_width = 194,               -- 单元的尺寸width
        item_height = 274,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 3,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewSingleLayout.new(list_panel, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)

    self.item_scrollview:registerScriptHandlerSingle(handler(self,self._createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self._numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self._updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell

	-- 商店类型按钮
	self.shop_btn_panel = main_container:getChildByName("shop_btn_panel")

	-- 子商店类型按钮
	self.shop_sub_panel = main_container:getChildByName("shop_sub_panel")
end

function HomeworldShopWindow:_createNewCell(  )
	local cell = HomeworldShopItem.new()
    return cell
end

function HomeworldShopWindow:_numberOfCells(  )
	if not self.show_item_data then return 0 end
    return #self.show_item_data
end

function HomeworldShopWindow:_updateCellByIndex( cell, index )
	if not self.show_item_data then return end
    cell.index = index
    local cell_data = self.show_item_data[index]
    if not cell_data then return end
    cell:setData(cell_data, self.cur_tab_index)
end

function HomeworldShopWindow:register_event(  )
	-- 退出
    registerButtonEventListener(self.background, function (  )
    	_controller:openHomeworldShopWindow(false)
    end, false, 2)

    -- 退出
    registerButtonEventListener(self.close_btn, function (  )
    	_controller:openHomeworldShopWindow(false)
    end, true, 2)

    -- 规则
    registerButtonEventListener(self.btn_rule, function ( param,sender, event_type )
    	local rule_cfg = Config.HomeData.data_const["shop_refresh_rule"]
    	if rule_cfg then
    		TipsManager:getInstance():showCommonTips(rule_cfg.desc, sender:getTouchBeganPosition())
    	end
    end, true, 1)

    -- 刷新
    registerButtonEventListener(self.refresh_btn, function (  )
    	self:_onClickRefreshBtn()
    end, true, 1)

    -- 家具、出行商店数据返回
    self:addGlobalEvent(MallEvent.Open_View_Event, function ( data )
    	if data.type == MallConst.MallType.FurnitureShop then
    		self.furniture_shop_data = data
    	elseif data.type == MallConst.MallType.HomePetShop then
    		self.pet_shop_data = data
    	end
    	self:updateShopItemList()
    end)

    -- 随机商店返回
    self:addGlobalEvent(MallEvent.Get_Buy_list, function ( data )
    	if data.type == MallConst.MallType.HomeRandomShop then
    		self.random_shop_data = data
    		self:setLessTime( data.refresh_time - GameNet:getInstance():getTime())
    		self:setResetCount(data)
    		self:updateShopItemList()
    	end
    end)

    if not self.role_lev_event and self.role_vo then
        self.role_lev_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
            if key and key == "gold" or key == "home_coin" then 
                self:updateResNum()
            end
        end)
    end
end

function HomeworldShopWindow:_onClickRefreshBtn(  )
	if self.cur_tab_index and self.cur_tab_index == 3 then
		MallController:getInstance():sender13405(MallConst.MallType.HomeRandomShop)
	end
end

--@setting.index 第一级菜单索引
--@setting.sub_index 第二级菜单索引
function HomeworldShopWindow:openRootWnd( setting )
    local setting = setting or {}
    local index = setting.index or 1
    self.select_sub_index = setting.sub_index
    self:initShopTypeBtn(index)

	self:updateResNum()
end

-- 初始化商店类型按钮
function HomeworldShopWindow:initShopTypeBtn( index)
    local index = index or 1
	self.tab_array = {
        {title = TI18N("家具"), index = 1},
        {title = TI18N("出行物品"), index = 2},
        {title = TI18N("随机商店"), index = 3},
    }

    local bgSize = self.shop_btn_panel:getContentSize()
    local scroll_view_size = cc.size(bgSize.width+20, bgSize.height)
    local setting = {
        item_class = CommonTabBtn,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = -5,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 149,               -- 单元的尺寸width
        item_height = 64,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
    }
    self.tab_scrollview = CommonScrollViewLayout.new(self.shop_btn_panel, cc.p(0, -7) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.tab_scrollview:setData(self.tab_array, handler(self, self._onClickTabBtn), nil, {default_index = index, tab_size = cc.size(149, 64),title_offset = cc.p(0,-5)})
    self.tab_scrollview:setClickEnabled(#self.tab_array > 4)
end

-- 更新子类商店类型按钮
function HomeworldShopWindow:updateSubTabBtn( index , default_index)
    local default_index = default_index or 1
	self.cur_tab_index = index
	self.cur_sub_tab_index = nil
	if index == 1 or index == 2 then
		self.sub_tab_array = {
			[1] = {
				{title = TI18N("墙壁"), index = 1},
		        {title = TI18N("地板"), index = 2},
		        {title = TI18N("墙饰"), index = 3},
		        {title = TI18N("家具"), index = 4},
		        {title = TI18N("地毯"), index = 5},
			},
			[2] = {
				{title = TI18N("食物"), index = 1},
		        {title = TI18N("道具"), index = 2},
			},
		}
		if not self.sub_tab_list then
			local panel_size = self.shop_sub_panel:getContentSize()
			self.sub_tab_list = CommonSubBtnList.new(self.shop_sub_panel, cc.p(0.5, 0.5), cc.p(panel_size.width*0.5, panel_size.height*0.5), cc.size(101, 50), handler(self, self._onClickSubTabBtn))
		end
		self.sub_tab_list:setData(self.sub_tab_array[index], default_index)
		self.sub_tab_list:setGuideName("shop_")
		self.shop_sub_panel:setVisible(true)

		self.refresh_btn:setVisible(false)
		self.btn_rule:setVisible(false)
		self.title_time:setVisible(false)
		self.txt_time:setVisible(false)

		if index == 1 then -- 家具商城
			if not self.req_furniture_flag then
				self.req_furniture_flag = true
				MallController:getInstance():sender13401(MallConst.MallType.FurnitureShop)
			end
		else  -- 出行物品
			if not self.req_pet_flag then
				self.req_pet_flag = true
				MallController:getInstance():sender13401(MallConst.MallType.HomePetShop)
			end
		end
	else
		if not self.req_random_flag then
			self.req_random_flag = true
			MallController:getInstance():sender13403(MallConst.MallType.HomeRandomShop)
		else
			self:updateShopItemList()
		end
		self.shop_sub_panel:setVisible(false)
		self.refresh_btn:setVisible(true)
		self.btn_rule:setVisible(true)
		self.title_time:setVisible(true)
		self.txt_time:setVisible(true)
	end
end

-- 刷新时间
function HomeworldShopWindow:updateRandowShopRefreshTime(  )
	
end

-- 点击商店类型（大类）
function HomeworldShopWindow:_onClickTabBtn( tab_btn )
	if self.cur_tab_btn and self.cur_tab_btn.index == tab_btn.index then return end

	if self.cur_tab_btn then
        self.cur_tab_btn:setBtnSelectStatus(false)
    end

    if tab_btn then
        self.cur_tab_btn = tab_btn
        self.cur_tab_btn:setBtnSelectStatus(true)

        if self.select_sub_index then
            self:updateSubTabBtn(tab_btn.index, self.select_sub_index)
            self.select_sub_index = nil
        else
            self:updateSubTabBtn(tab_btn.index)
        end
    end
end

-- 点击商店类型（小类）
function HomeworldShopWindow:_onClickSubTabBtn( index )
	if self.cur_sub_tab_index and self.cur_sub_tab_index == index then return end

	self.cur_sub_tab_index = index

	self:updateShopItemList()
end

-- 刷新商品列表
function HomeworldShopWindow:updateShopItemList( is_keep_pos )
	self.show_item_data = {}

	if self.cur_tab_index == 1 or self.cur_tab_index == 2 then -- 家具/出行
		local config_data = {}
		local srv_data = {}
		if self.cur_tab_index == 1 then
			srv_data = self.furniture_shop_data
			for k,v in pairs(Config.ExchangeData.data_shop_exchage_furniture) do
				if v.item_type == self.cur_sub_tab_index then
					_table_insert(config_data, v)
				end
			end
		else
			srv_data = self.pet_shop_data
			for k,v in pairs(Config.ExchangeData.data_shop_exchage_pet) do
				if v.item_type == self.cur_sub_tab_index then
					_table_insert(config_data, v)
				end
			end
		end
		local list = deepCopy(srv_data.item_list)
        for a, j in pairs(config_data) do
        	if list and next(list or {}) ~= nil then
                for k, v in pairs(list) do --已经买过的限购物品
                    if j.id == v.item_id then
                        if v.ext[1].val then --不管是什么限购 赋值已购买次数就好了。。
                            j.has_buy = v.ext[1].val
                            table.remove(list, k)
                        end
                        break
                    else
                        j.has_buy = 0
                    end
                end
            else
                j.has_buy = 0
            end
            _table_insert(self.show_item_data, j)
        end
        table.sort(self.show_item_data, SortTools.KeyLowerSorter("order"))
	elseif self.cur_tab_index == 3 then -- 随机商城
		self.show_item_data = self.random_shop_data.item_list or {}
	end
	self.item_scrollview:reloadData(nil, nil, is_keep_pos)
end

function HomeworldShopWindow:setLessTime( less_time )
	if tolua.isnull(self.txt_time) then return end
    doStopAllActions(self.txt_time)
    if less_time > 0 then
        self:setTimeFormatString(less_time)
        self.txt_time:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
            if less_time < 0 then
                doStopAllActions(self.txt_time)
            else
                self:setTimeFormatString(less_time)
            end
        end))))
    else
        self:setTimeFormatString(less_time)
    end
end

function HomeworldShopWindow:setTimeFormatString( time )
	if time > 0 then
        self.txt_time:setString(TimeTool.GetTimeFormat(time))
    else
        self.txt_time:setString("00:00:00")
    end
end

function HomeworldShopWindow:setResetCount( data )
    if not data then return end
    local free_count = data.free_count or 0
    local btn_str = TI18N("免费刷新")

    if free_count <= 0 then
        local cost_cfg = Config.ExchangeData.data_shop_exchage_cost["furniture_spend"]
        if cost_cfg then
            local num = cost_cfg.val
            btn_str = string.format(TI18N("<img src=%s scale=0.3 visible=true /><div outline=2,#764519>%s刷新</div>"), PathTool.getItemRes(31), num)
        end
    else
        local asset_cfg = Config.ExchangeData.data_shop_exchage_cost["furniture_refresh_free"] 
        if asset_cfg then
            btn_str = string.format("<div fontsize=24 outline=2,#764519>%s(%s/%s)</div>", TI18N("免费刷新"), free_count, asset_cfg.val)
        end
    end
    self.refresh_btn_label:setString(btn_str)
end

function HomeworldShopWindow:updateResNum(  )
	if not self.role_vo then return end
	for k,object in pairs(self.res_object_list) do
		if object.res_label then
			local val = 0
			if k == 1 then
				val = self.role_vo.home_coin
			elseif k == 2 then
				val = self.role_vo.gold
			end
			object.res_label:setString(MoneyTool.GetMoneyString(val))
		end
	end
end

function HomeworldShopWindow:close_callback(  )
	doStopAllActions(self.txt_time)
	if self.title_load then
		self.title_load:DeleteMe()
		self.title_load = nil
	end
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
		self.item_scrollview = nil
	end
	if self.sub_tab_list then
		self.sub_tab_list:DeleteMe()
		self.sub_tab_list = nil
	end
	if self.tab_scrollview then
		self.tab_scrollview:DeleteMe()
		self.tab_scrollview = nil
	end
	if self.role_lev_event and self.role_vo then
        self.role_vo:UnBind(self.role_lev_event)
        self.role_lev_event = nil
    end
	_controller:openHomeworldShopWindow(false)
end