--------------------------------------------
-- @Author  : xhj
-- @Editor  : xhj
-- @Date    : 2020-02-18 17:12:43
-- @description    : 
		-- 精灵许愿界面
---------------------------------
local _controller = ElfinController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format
local _table_insert = table.insert

ElfinWishWindow = ElfinWishWindow or BaseClass(BaseView)

function ElfinWishWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "elfin/elfin_wish_window"
	self.item_list = {}
	self.cur_item_id_list = {}
	self.select_cell_list = {}
	self.elfin_data_list = {}
	self.lucky_sprite_num = 1
	local lucky_sprite_num_cfg = Config.HolidaySpriteLotteryData.data_const["lucky_sprite_num"]
	if lucky_sprite_num_cfg then
		self.lucky_sprite_num = lucky_sprite_num_cfg.val -- 可许愿精灵数量
	end
end

function ElfinWishWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 2)

	container:getChildByName("win_title"):setString(TI18N("精灵许愿"))
	
	self.left_btn = container:getChildByName("left_btn")
	self.left_btn:getChildByName("label"):setString(TI18N("取 消"))
	self.right_btn = container:getChildByName("right_btn")
	self.right_btn:getChildByName("label"):setString(TI18N("确 定"))
	self.close_btn = container:getChildByName("close_btn")
	self.elfin_info_panel = container:getChildByName("elfin_info_panel")
	self.elfin_info_panel:getChildByName("name_txt"):setString(TI18N("许愿池"))
	self.btn_rule = container:getChildByName("btn_rule")
	
	self.item_scrollview = self.elfin_info_panel:getChildByName("item_scrollview")
    self.item_scrollview:setScrollBarEnabled(false)
	self.item_scrollview_size = self.item_scrollview:getContentSize()
	
	self.elfin_list = container:getChildByName("elfin_list")
	local scroll_view_size = self.elfin_list:getContentSize()
    local list_setting = {
        start_x = 0,
        space_x = 24,
        start_y = 5,
        space_y = 10,
        item_width = BackPackItem.Width,
        item_height = BackPackItem.Height,
        row = 0,
        col = 4,
        need_dynamic = true
    }
    self.elfin_list_view = CommonScrollViewSingleLayout.new(self.elfin_list, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, list_setting, cc.p(0, 0)) 

    self.elfin_list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.elfin_list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.elfin_list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    self.elfin_list_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell

    self.choose_tips_txt = createRichLabel(24, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0, 0), cc.p(110, 625),nil,nil,500)
    container:addChild(self.choose_tips_txt)
    self.choose_tips_txt:setString(TI18N("在精灵召唤时，有<div fontcolor=#d95014>更高概率</div>获得许愿池中许愿的精灵（获得橙色精灵总概率不变）"))
end

function ElfinWishWindow:createNewCell(  )
	local cell = ElfinWishItem.new()
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end

function ElfinWishWindow:numberOfCells(  )
	if not self.elfin_data_list then return 0 end
	return #self.elfin_data_list
end

function ElfinWishWindow:updateCellByIndex( cell, index )
	cell.index = index
    local item_vo = self.elfin_data_list[index]
    if item_vo then
		cell:setData(item_vo)
		for k,v in pairs(self.cur_item_id_list) do
			if v and v.id == item_vo.id then
				cell:IsGetStatus(true)
			else
				cell:IsGetStatus(false)
			end
		end
    end
end

function ElfinWishWindow:onCellTouched( cell )
	
	local isSelect = false
	local item_vo = self.elfin_data_list[cell.index]
	for k,v in pairs(self.cur_item_id_list) do
		if v and v.id == item_vo.id then
			if self.select_cell_list[k] then
				self.select_cell_list[k]:IsGetStatus(false)
				self.select_cell_list[k] = nil
			end
			
			self.cur_item_id_list[k] = nil
			isSelect = true
			break
		end
	end
	
	if isSelect == false then
		if #self.cur_item_id_list >= self.lucky_sprite_num then
			if self.cur_item_id_list[1] and self.select_cell_list[1] then
				self.select_cell_list[1]:IsGetStatus(false)
				self.select_cell_list[1] = cell
				self.cur_item_id_list[1] = item_vo
			end
		else
			_table_insert(self.select_cell_list, cell)
			_table_insert(self.cur_item_id_list, item_vo)
		end
		cell:IsGetStatus(true)
	end
	
	self:updateElfinInfo()
	self:updateIconShow()
end

function ElfinWishWindow:updateElfinInfo(  )
	if not self.cur_item_id_list or #self.cur_item_id_list<=0 then -- 没选中任何一个精灵
		self.item_scrollview:setVisible(false)
		return
	end

	local cell_list = {}
	for k,v in pairs(self.select_cell_list) do
		if v then
			_table_insert(cell_list, v)
		end
	end
	self.select_cell_list = cell_list

	
	local temp_list = {}
	for k,v in pairs(self.cur_item_id_list) do
		if v then
			_table_insert(temp_list, v)
		end
	end
	self.cur_item_id_list = temp_list


	local data_list = {}
    for i,v in ipairs(temp_list) do
        _table_insert(data_list, {v.id, 1})
	end
	
	local setting = {}
	setting.max_count = 4
	setting.is_center = true
	self.item_list = commonShowSingleRowItemList(self.item_scrollview, self.item_list, data_list, setting)
	

	self.item_scrollview:setVisible(true)
end

function ElfinWishWindow:register_event(  )
	registerButtonEventListener(self.left_btn, function (  )
		if self.elfin_bid_list == nil or next(self.elfin_bid_list) == nil then
			self:showCommonAlert(true)
			return
		end
		self:onClickCloseBtn()
	end, true)
	
	registerButtonEventListener(self.right_btn, handler(self, self.onClickChooseBtn), true)

	registerButtonEventListener(self.close_btn, function (  )
		if self.elfin_bid_list == nil or next(self.elfin_bid_list) == nil then
			self:showCommonAlert(true)
			return
		end
		self:onClickCloseBtn()
	end, true, 2)

	registerButtonEventListener(self.btn_rule, function (  )
		if self.summon_data then
			local action_cfg = Config.HolidaySpriteLotteryData.data_action[self.summon_data.camp_id]
			if action_cfg and action_cfg.group_id then
				local conf = Config.HolidaySpriteLotteryData.data_summon[action_cfg.group_id]
				if conf then
					TimesummonController:getInstance():openTimeSummonAwardView(true, conf.group_id, self.summon_data,TimesummonConst.ActonInfoType.ElfinType2)
				end
			end
		end
	end, true, 1)
	
	registerButtonEventListener(self.background, function ( )
		if self.elfin_bid_list == nil or next(self.elfin_bid_list) == nil then
			self:showCommonAlert(true)
			return
		end
		self:onClickCloseBtn()
	end, false, 2)
end

function ElfinWishWindow:onClickCloseBtn(  )
	_controller:openElfinWishWindow(false)
end

function ElfinWishWindow:onClickChooseBtn(  )
	if next(self.elfin_data_list) == nil then
		message(TI18N("没有可选择的精灵"))
		return
	end

	local temp_list = {}
	if next(self.cur_item_id_list) == nil then
		self:showCommonAlert(false)
	else
		for k,v in pairs(self.cur_item_id_list) do
			if v then
				_table_insert(temp_list, {lucky_sprites_bid = v.id})	
			end
		end
		_controller:send26554(temp_list)
		self:onClickCloseBtn()
	end
end

function ElfinWishWindow:showCommonAlert( is_close )
	local str = TI18N('许愿池尚未加入精灵，现在召唤仍有概率获得橙色品质英雄，是否退出？')
	if is_close == true then
		local function fun()
			self:onClickCloseBtn()
		end
		CommonAlert.show(str, TI18N('确定'), fun, TI18N('取消'), nil, CommonAlert.type.rich, nil, nil, nil, true)
	else
		-- str = TI18N('许愿池尚未加入精灵，现在召唤仍有概率获得橙色品质英雄，是否卸下？')
		local function fun()
			_controller:send26554({})
			self:onClickCloseBtn()
		end
		CommonAlert.show(str, TI18N('确定'), fun, TI18N('取消'), nil, CommonAlert.type.rich, nil, nil, nil, true)
	end
end

function ElfinWishWindow:setData( data )
	if not data  then
		return
	end
	self.summon_data = data
	self.elfin_bid_list = {}
	
	for k,v in pairs(data.lucky_ids) do
		if v.lucky_sprites_bid then
			_table_insert(self.elfin_bid_list, v.lucky_sprites_bid)
		end
	end

	self.elfin_data_list = {}
	local all_elfin_data = {}
	local lucky_sprite_ids_cfg = Config.HolidaySpriteLotteryData.data_const["lucky_sprite_ids"]
	if lucky_sprite_ids_cfg then
		all_elfin_data = lucky_sprite_ids_cfg.val
	end
	
	local have_cfg_list = {}
	if all_elfin_data and next(all_elfin_data) ~= nil then 
		for k,v in pairs(all_elfin_data) do
			local cur_elfin_cfg = Config.ItemData.data_get_data(v)
			if cur_elfin_cfg then
				_table_insert(have_cfg_list, cur_elfin_cfg)
			end
		end	
	end
	self.elfin_data_list = have_cfg_list


	if next(self.elfin_data_list) == nil then
		self.item_scrollview:setVisible(false)
	else
		local function sort_func( objA, objB )
			for k,v in pairs(self.elfin_bid_list) do
				if objA.id == v and objB.id ~= v then
					return true
				elseif objA.id ~= v and objB.id == v then
					return false
				end
			end
			if objA.quality ~= objB.quality then
				return objA.quality > objB.quality
			elseif objA.eqm_jie ~= objB.eqm_jie then
				return objA.eqm_jie > objB.eqm_jie
			else
				return objA.id < objB.id
			end
		end
		table.sort(self.elfin_data_list, sort_func)

		if #self.elfin_bid_list>0 then
			self.elfin_list_view:reloadData(1)
		else
			self.elfin_list_view:reloadData()
		end
		self:updateIconShow()
		commonShowEmptyIcon(self.elfin_list, false)
	end
end

function ElfinWishWindow:updateIconShow(  )
	if self.cur_item_id_list and #self.cur_item_id_list>0 then
		if self.item_node then
			self.item_node:setVisible(false)
		end
	else
		if self.item_node then
			self.item_node:setVisible(true)
		else
			self.item_node = BackPackItem.new(false, true, false)
			self.item_node:setPosition(cc.p(588*0.5, 176*0.5-20))
			self.elfin_info_panel:addChild(self.item_node)
			self.item_node:setData()
			self.item_node:showFlagByRes(true, PathTool.getResFrame("elfin", "elfin_1045"), 38, 94)
		end
	end
end
function ElfinWishWindow:openRootWnd(data)
	
	self:setData(data)

	
end

function ElfinWishWindow:close_callback(  )
	if self.elfin_list_view then
		self.elfin_list_view:DeleteMe()
		self.elfin_list_view = nil
	end
	if self.item_node then
		self.item_node:DeleteMe()
		self.item_node = nil
	end

	if self.item_list then
        for i,v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end
	_controller:openElfinWishWindow(false)
end


--------------------------@ item
ElfinWishItem = class("ElfinWishItem", function()
    return ccui.Widget:create()
end)

function ElfinWishItem:ctor()
	self:configUI()
end

function ElfinWishItem:configUI(  )
	self.size = cc.size(BackPackItem.Width, BackPackItem.Height)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

    self.item_node = BackPackItem.new(false, true, false)
    self.item_node:setPosition(cc.p(self.size.width*0.5, self.size.height-BackPackItem.Height*0.5))
    self:addChild(self.item_node)
end

function ElfinWishItem:addCallBack( callback )
	if self.item_node then
		self.item_node:addCallBack(callback)
	end
end

function ElfinWishItem:setData( data )
	if self.item_node then
		self.item_node:setData(data)
	end
end


function ElfinWishItem:IsGetStatus( status )
	if self.item_node then
		self.item_node:IsGetStatus(status)
	end
end

function ElfinWishItem:DeleteMe(  )
	if self.item_node then
		self.item_node:DeleteMe()
		self.item_node = nil
	end
end