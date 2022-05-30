--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-08-13 21:47:27
-- @description    : 
		-- 选择物品（精灵）
---------------------------------
local _controller = ElfinController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format
local _table_insert = table.insert

ElfinSelectItemWindow = ElfinSelectItemWindow or BaseClass(BaseView)

function ElfinSelectItemWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "elfin/elfin_select_item_window"

	self.cur_view_type = ElfinConst.Select_Type.Egg
	self.all_item_data = {}
	self.buy_state = 0 -- 0:该道具不能购买 1:该道具可以购买但无购买次数 2:该道具可以购买
	self.max_buy_num = 0 -- 最大可购买次数
end

function ElfinSelectItemWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container, 2)

	self.select_btn = main_container:getChildByName("select_btn")
	-- 引导需要
	self.select_btn:setName("guide_select_btn")
	self.select_btn_label = self.select_btn:getChildByName("label")
	self.add_btn = main_container:getChildByName("add_btn")
	self.add_btn_label = self.add_btn:getChildByName("label")
	self.add_btn_label:setString(TI18N("补充"))
	self.add_btn:setVisible(false)

	self.win_title = main_container:getChildByName("win_title")
	self.label_select_num = main_container:getChildByName("label_select_num")
	self.label_select_num:setString(_string_format(TI18N("已选择:0/1")))
	self.label_tip_1 = main_container:getChildByName("label_tip_1")
	self.label_tip_1:setString("")

	self.label_tip_2 = createRichLabel(20, cc.c4b(120, 80, 70, 255), cc.p(1, 0.5), cc.p(640, 138), nil, nil, 600)
	main_container:addChild(self.label_tip_2)

	self.lay_scrollview = main_container:getChildByName("lay_scrollview")
	local scroll_view_size = self.lay_scrollview:getContentSize()
    local list_setting = {
        start_x = 18,
        space_x = 15,
        start_y = 0,
        space_y = 15,
        item_width = BackPackItem.Width*0.9,
        item_height = 135,
        row = 0,
        col = 5,
        need_dynamic = true
    }
    self.list_view = CommonScrollViewSingleLayout.new(self.lay_scrollview, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, list_setting, cc.p(0, 0)) 

    self.list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    self.list_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
end

function ElfinSelectItemWindow:createNewCell(  )
	local cell = BackPackItem.new(false, true, false, 0.9)
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end

function ElfinSelectItemWindow:numberOfCells(  )
	if self.all_item_data then
		return #self.all_item_data + 1
	else
		return 1
	end
end

function ElfinSelectItemWindow:updateCellByIndex( cell, index )
	cell.index = index
	local item_cfg = self.all_item_data[index]
    if item_cfg then
    	cell:showAddIcon(false)
    	cell:setData(item_cfg)
    	cell:showItemQualityName(true)
    	local have_num = BackpackController:getInstance():getModel():getItemNumByBid(item_cfg.id)
    	cell:setNeedNum(1, have_num)
    	if self.cur_item_cfg and self.cur_item_cfg.id == item_cfg.id then
    		cell:IsGetStatus(true)
    	else
    		cell:IsGetStatus(false)
		end
		local cell_root = nil
		if cell.getRoot then
			cell_root = cell:getRoot()
		end
		if cell_root and item_cfg.id == 10602 then--奇紫蛋增加合成按钮
			if cell.hc_btn == nil then
				cell.hc_btn = createButton(cell_root,TI18N("合成"), 620, 580, cc.size(105, 45), PathTool.getResFrame("common", "common_1125"), 20, Config.ColorData.data_new_color4[1])
				cell.hc_btn:setPosition(cell_root:getContentSize().width / 2, -70)
				cell.hc_btn:enableOutline(Config.ColorData.data_new_color4[16], 1)
				cell.hc_btn:addTouchEventListener(function(sender, event_type)
					if event_type == ccui.TouchEventType.ended then
						ElfinController:getInstance():openElfinEggSyntheticPanel(true,10601)--打开水灵蛋合成界面
					end
				end)
			end
			cell.hc_btn:setVisible(true)
		elseif cell.hc_btn then
			cell.hc_btn:setVisible(false)
		end
    else
    	--空表示最后的加号
    	cell:setNeedNum(0)
    	cell:setData(nil) 
        cell:showAddIcon(true)
    end
end

function ElfinSelectItemWindow:onCellTouched( cell )
	local item_cfg = cell:getData()
	if not item_cfg or next(item_cfg) == nil then
		local item_config
		if self.cur_view_type == ElfinConst.Select_Type.Egg then
			local egg_buy_cfg = Config.SpriteData.data_const["egg_buy_price"]
			if egg_buy_cfg and egg_buy_cfg.val[1] then
				item_config = Config.ItemData.data_get_data(egg_buy_cfg.val[1])
			end
		elseif self.cur_view_type == ElfinConst.Select_Type.Item then
			local egg_buy_cfg = Config.SpriteData.data_const["prop_buy_price"]
			if egg_buy_cfg and egg_buy_cfg.val[1] then
				item_config = Config.ItemData.data_get_data(egg_buy_cfg.val[1])
			end
		end
        if item_config then
            BackpackController:getInstance():openTipsOnlySource(true, item_config)
        end
	else
		if self.cur_item_cfg and self.cur_item_cfg.id == item_cfg.id then
			if self.select_cell then
				self.select_cell:IsGetStatus(false)
			end
			self.cur_item_cfg = nil
			self.label_select_num:setString(_string_format(TI18N("已选择:0/1")))
			self.label_tip_1:setString("")
			self.label_tip_2:setString("")
			self.add_btn:setVisible(false)
		else
			if self.select_cell then
				self.select_cell:IsGetStatus(false)
			end
			cell:IsGetStatus(true)
			self.select_cell = cell
			self.label_select_num:setString(_string_format(TI18N("已选择:1/1")))
			self.cur_item_cfg = deepCopy(item_cfg)
			self:updateSelectItemInfo()
		end
	end
end

function ElfinSelectItemWindow:updateSelectItemInfo(  )
	if not self.cur_item_cfg then return end

	self.buy_state = 0
	self.max_buy_num = 0
	if self.cur_view_type == ElfinConst.Select_Type.Egg then
		local egg_cfg = Config.SpriteData.data_hatch_egg[self.cur_item_cfg.id]
		if egg_cfg then
			local hatch_rate = Config.SpriteData.data_const["hatch_rate"]
			if hatch_rate then
				local temptiem = TimeTool.GetTimeFormatDayIIIIII(egg_cfg.need_piont*hatch_rate.val)
				self.label_tip_1:setString(_string_format(TI18N("孵化时间: %s"), temptiem))
			end
			
			self.add_btn_label:setString(TI18N("购买"))
			self.label_tip_2:setString(egg_cfg.desc)

			if egg_cfg.can_buy == 1 then
				local has_buy_num = _model:getElfinBuyCountByBid(self.cur_item_cfg.id)
				self.max_buy_num = egg_cfg.limit_num - has_buy_num
				if self.max_buy_num > 0 then
					self.buy_state = 2
				else
					self.buy_state = 1
				end
			end
		end
	elseif self.cur_view_type == ElfinConst.Select_Type.Item then
		local smash_item_cfg = Config.SpriteData.data_smash_item[self.cur_item_cfg.id]
		if smash_item_cfg then
			self.label_tip_1:setString(_string_format(TI18N("减少孵化点:%d点"), smash_item_cfg.del_piont))
			self.label_tip_2:setString(smash_item_cfg.desc)

			if smash_item_cfg.can_buy == 1 then
				local has_buy_num = _model:getElfinBuyCountByBid(self.cur_item_cfg.id)
				self.max_buy_num = smash_item_cfg.limit_num - has_buy_num
				if self.max_buy_num > 0 then
					self.buy_state = 2
				else
					self.buy_state = 1
				end
			end
		end
	end

	self.add_btn:setVisible(self.buy_state ~= 0)
end

function ElfinSelectItemWindow:checkUpdateSelectItemInfo( item_bid )
	if self.cur_item_cfg and self.cur_item_cfg.id == item_bid then
		self:updateSelectItemInfo()
	end
end

function ElfinSelectItemWindow:register_event(  )
	registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn), false, 2)

	registerButtonEventListener(self.select_btn, handler(self, self.onClickSelectBtn), true)

	registerButtonEventListener(self.add_btn, handler(self, self.onClickAddBtn), true)

	-- 购买道具成功
	self:addGlobalEvent(ElfinEvent.Buy_Elfin_Item_Success_Event, function(item_bid)
		self.list_view:reloadData()
		self:checkUpdateSelectItemInfo(item_bid)
    end)

    -- 物品数量变化
    self:addGlobalEvent(BackpackEvent.ADD_GOODS, function(bag_code, item_list)
    	if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
		self:checkNeedUpdateItemNum(item_list)
    end)
    self:addGlobalEvent(BackpackEvent.DELETE_GOODS, function(bag_code, item_list)
    	if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
		self:checkNeedUpdateItemNum(item_list)
    end)
    self:addGlobalEvent(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code, item_list)
    	if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
		self:checkNeedUpdateItemNum(item_list)
    end)
end

function ElfinSelectItemWindow:checkNeedUpdateItemNum( item_list )
	if item_list == nil or next(item_list) == nil then return end
	local is_have = false
    for k, v in pairs(item_list) do
        if v.config then
            for _,cfg in pairs(self.all_item_data) do
            	if v.config.id == cfg.id then
            		is_have = true
            		break
            	end
            end
        end
        if is_have then
        	break
        end
    end
    if is_have then
    	self.list_view:reloadData()
    end
end

function ElfinSelectItemWindow:onClickCloseBtn(  )
	_controller:openElfSelectItemWindow(false)
end

function ElfinSelectItemWindow:onClickSelectBtn(  )
	if self.cur_item_cfg and self.hatch_id then
		local have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.cur_item_cfg.id)
		if have_num <= 0 then
			if self.cur_item_cfg.id == ElfinConst.Bule_Egg_Bid then
				local egg_cfg = Config.SpriteData.data_hatch_egg[self.cur_item_cfg.id]
				if egg_cfg and egg_cfg.price and egg_cfg.price[1] then
					local cost_bid = egg_cfg.price[1][1]
					local cost_num = egg_cfg.price[1][2]
					local function call_back()
			            _controller:sender26507(1, self.cur_item_cfg.id, 1, self.hatch_id)
			        end
			        local iconsrc = PathTool.getItemRes(Config.ItemData.data_get_data(cost_bid).icon)
			        local str = string.format("是否花费<img src='%s' scale=0.3 />%s购买%s，并开始孵化？", iconsrc, MoneyTool.GetMoneyString(cost_num), self.cur_item_cfg.name)
			        CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich,nil,nil,24)
		       	else
		       		message(TI18N("所选道具数量不足"))
				end
			else
				message(TI18N("所选道具数量不足"))
			end
			return
		end
		if self.cur_view_type == ElfinConst.Select_Type.Item then -- 请求加速孵化
			GlobalEvent:getInstance():Fire(ElfinEvent.Open_Elfin_Smash_Panel_Event, self.cur_item_cfg.id)
		elseif self.cur_view_type == ElfinConst.Select_Type.Egg then -- 请求开始孵化
			_controller:sender26503(self.hatch_id, self.cur_item_cfg.id)
		end
		_controller:openElfSelectItemWindow(false)
	else
		message(TI18N("请至少选择一种物品"))
	end
end

function ElfinSelectItemWindow:onClickAddBtn(  )
	-- 蛋疼，需求又改回去了，代码先保留吧
	--[[if self.buy_state == 0 or not self.cur_item_cfg then return end
	if self.buy_state == 1 then
		-- 购买次数用完，则弹出来源界面
        BackpackController:getInstance():openTipsOnlySource(true, self.cur_item_cfg)
	else--]]
		if self.cur_view_type == ElfinConst.Select_Type.Item then
			local smash_item_cfg = Config.SpriteData.data_smash_item[self.cur_item_cfg.id]
			if smash_item_cfg.price and smash_item_cfg.price[1] then
				local setting = {}
				setting.view_type = ArenaConst.view_type.elfin
		    	setting.item_bid = self.cur_item_cfg.id
		    	setting.item_price = smash_item_cfg.price[1][2]
		    	setting.cost_item_id = smash_item_cfg.price[1][1]
		    	setting.extra_data = 2
		    	setting.max_buy_num = self.max_buy_num
		    	setting.tips_str = _string_format(TI18N("(可购买%d个)"), self.max_buy_num)
				ArenaController:getInstance():openArenaLoopChallengeBuy(true, setting)
			end
		elseif self.cur_view_type == ElfinConst.Select_Type.Egg then
			local egg_item_cfg = Config.SpriteData.data_hatch_egg[self.cur_item_cfg.id]
			if egg_item_cfg.price and egg_item_cfg.price[1] then
				local setting = {}
				setting.view_type = ArenaConst.view_type.elfin
		    	setting.item_bid = self.cur_item_cfg.id
		    	setting.item_price = egg_item_cfg.price[1][2]
		    	setting.cost_item_id = egg_item_cfg.price[1][1]
		    	setting.extra_data = 1
		    	setting.max_buy_num = self.max_buy_num
		    	setting.tips_str = _string_format(TI18N("(可购买%d个)"), self.max_buy_num)
				ArenaController:getInstance():openArenaLoopChallengeBuy(true, setting)
			end
		end
	--end
end

function ElfinSelectItemWindow:openRootWnd( setting )
	setting = setting or {}

	self.cur_view_type = setting.view_type or ElfinConst.Select_Type.Egg
	self.hatch_id = setting.hatch_id

	self:setData()
end

function ElfinSelectItemWindow:setData(  )
	self.all_item_data = {}
	if self.cur_view_type == ElfinConst.Select_Type.Egg then
		self.win_title:setString(TI18N("选择孵化蛋"))
		self.select_btn_label:setString(TI18N("开始孵化"))
		
		for k,v in pairs(Config.SpriteData.data_hatch_egg) do
			local item_cfg = Config.ItemData.data_get_data(v.item_bid)
			if item_cfg then
				_table_insert(self.all_item_data, item_cfg)
			end
		end
	elseif self.cur_view_type == ElfinConst.Select_Type.Item then
		self.win_title:setString(TI18N("选择孵化道具"))
		self.select_btn_label:setString(TI18N("使用"))
		
		for k,v in pairs(Config.SpriteData.data_smash_item) do
			local item_cfg = Config.ItemData.data_get_data(v.item_bid)
			if item_cfg then
				_table_insert(self.all_item_data, item_cfg)
			end
		end
	end
	
	table.sort(self.all_item_data, SortTools.KeyLowerSorter("id"))

	local default_index = 1
	for i,v in ipairs(self.all_item_data) do
		local have_num = BackpackController:getInstance():getModel():getItemNumByBid(v.id)
		if have_num > 0 then
			default_index = i
		end
	end
	self.list_view:reloadData(default_index)
end

function ElfinSelectItemWindow:close_callback(  )
	if self.list_view then
		self.list_view:DeleteMe()
		self.list_view = nil
	end

	_controller:openElfSelectItemWindow(false)
end