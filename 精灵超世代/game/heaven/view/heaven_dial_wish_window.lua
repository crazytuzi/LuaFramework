--------------------------------------------
-- @Author  : xhj
-- @Editor  : xhj
-- @Date    : 2020-02-29 17:12:43
-- @description    : 
		-- 神装心愿
---------------------------------
local _controller = HeavenController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format
local _table_insert = table.insert

HeavenDialWishWindow = HeavenDialWishWindow or BaseClass(BaseView)

function HeavenDialWishWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "heaven/heaven_dial_wish_window"
	
	self.cur_item_id_list = {}--当前选中神装信息
	self.select_cell_list = {}--选择列表选中的神装
	self.heaven_data_list = {}
	self.cur_hero_item_list = {} -- 当前宝可梦的神装item
	self.tab_list = {}
	self.cur_tab_index = 1  -- 当前选中的tab按钮

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("heavendial", "heavendial"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("heavendial","heavendial_bg"), type = ResourcesType.single},
	}

end

function HeavenDialWishWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local container = self.root_wnd:getChildByName("container")

	container:getChildByName("win_title"):setString(TI18N("心愿单"))
	
    self:playEnterAnimatianByObj(container, 1)  
	self.right_btn = container:getChildByName("right_btn")
	self.right_btn:getChildByName("label"):setString(TI18N("确 定"))
	self.close_btn = container:getChildByName("close_btn")
	self.elfin_info_panel = container:getChildByName("elfin_info_panel")
	container:getChildByName("tips_lab"):setString(TI18N("选择心仪的神装许愿，祈祷获取概率会大幅提升！"))
	
	local tab_container = container:getChildByName("tab_container")
    for i=1,4 do
        local object = {}
        local tab_btn = tab_container:getChildByName("tab_btn_"..i)
		tab_btn:setScale(0.95)
        if tab_btn then
            tab_btn:loadTextures(PathTool.getResFrame("common","common_2010"), PathTool.getResFrame("common","common_2010"), "", LOADTEXT_TYPE_PLIST)
            local title = tab_btn:getChildByName("title")
            if i == 1 then
                title:setString(TI18N("耳环"))
            elseif i == 2 then
                title:setString(TI18N("项链"))
            elseif i == 3 then
                title:setString(TI18N("戒指"))
			elseif i == 4 then
				title:setString(TI18N("手镯"))
            end
            local tips = tab_btn:getChildByName("tips")
            object.tab_btn = tab_btn
            object.label = title
            object.label:setTextColor(Config.ColorData.data_new_color4[6])
            object.index = HeroConst.HolyequipmentPosList[i]
            object.tips = tips
            self.tab_list[object.index] = object
        end
    end
	
	self.elfin_list = container:getChildByName("elfin_list")
	local scroll_view_size = self.elfin_list:getContentSize()
    local list_setting = {
        start_x = 18,
        space_x = 32,
        start_y = 10,
        space_y = 10,
        item_width = BackPackItem.Width*0.9,
        item_height = (BackPackItem.Height+50)*0.9,
        row = 0,
        col = 4,
        need_dynamic = true
    }
    self.elfin_list_view = CommonScrollViewSingleLayout.new(self.elfin_list, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, list_setting, cc.p(0, 0)) 

    self.elfin_list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.elfin_list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.elfin_list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    self.elfin_list_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell

	-- 神装item
    local start_x = 80
	for i,holy_pos in pairs(HeavenConst.Dial_Wish_Pos) do
        local holy_item = self.cur_hero_item_list[i]
		if not holy_item then
			local item = self.elfin_info_panel:getChildByName("heaven"..holy_pos)
			holy_item = DialWishItem.new()
			holy_item:setScale(0.7)
			holy_item:addCallBack(function() self:selectHolyByIndex(holy_item,holy_pos) end)
			holy_item:createSpriteMask()
			holy_item.panel = item
            item:addChild(holy_item)
            self.cur_hero_item_list[holy_pos] = holy_item
        end
        holy_item:setPosition(cc.p(57.5,80))
	end

end

-- 点击装备
function HeavenDialWishWindow:selectHolyByIndex( holy_item,holy_pos )
	if holy_item.is_ui_select == true then
		if holy_item.equip_vo then
			local item_vo = holy_item.equip_vo
			for k,v in pairs(self.cur_item_id_list) do
				if v and v.lucky_holy_eqm == item_vo.group_id then
					for i,j in pairs(self.select_cell_list) do
						local select_data = j:getData()
						if item_vo and select_data and item_vo.group_id == select_data.group_id then
							local item = self.select_cell_list[i]
							self.select_cell_list[i]:IsGetStatus(false)
							self.select_cell_list[i] = nil
							break
						end
					end
					self.cur_item_id_list[k].lucky_holy_eqm = nil
					break
				end
			end
			self:updateCurHeroHolyItemList()
		end
		return 
	end
	if self.cur_hero_item then
		self.cur_hero_item.is_ui_select = false
		self.cur_hero_item:setMaskVisible(false)
	end
	holy_item.is_ui_select = true
	holy_item:setMaskVisible(true)
    self.cur_hero_item = holy_item
	self.pos = holy_pos
	
	local item_type = BackPackConst.item_type.GOD_EARRING
	if holy_item.equip_vo then
		item_type = holy_item.equip_vo.type
	end
	self:changeSelectedTab(item_type)
end

--更新神装item显示
function HeavenDialWishWindow:updateCurHeroHolyItemList()
	if self.select_cell_list then
		local cell_list = {}
		for k,v in pairs(self.select_cell_list) do
			if v then
				cell_list[k] = v
			end
		end
		self.select_cell_list = cell_list
	end
	
	local item_id_list = self.cur_item_id_list or {}
	local temp_list = {}
	for k,v in pairs(item_id_list) do
		if v then
			_table_insert(temp_list, v)
		end
	end
	self.cur_item_id_list = temp_list

	for i,holy_pos in pairs(HeavenConst.Dial_Wish_Pos) do
		local equip_vo = nil
		for k,v in pairs(self.cur_item_id_list) do
			if v.pos == holy_pos then
				local cur_elfin_cfg = Config.HolyEqmLotteryData.data_wish_show[v.lucky_holy_eqm]
				if cur_elfin_cfg then
					equip_vo = cur_elfin_cfg
				end
				break
			end
		end
        
        local holy_item = self.cur_hero_item_list[holy_pos]
		if equip_vo then
            holy_item:setData(equip_vo,true,true)
			holy_item.equip_vo = equip_vo
			holy_item:showAddIcon(false)
		else
            holy_item:setData(nil,nil,true)
			holy_item.equip_vo = nil
			holy_item:showAddIcon(true)
        end
        holy_item.is_ui_select = false
        if self.pos and holy_pos == self.pos then
            holy_item.is_ui_select = true
            self.cur_hero_item = holy_item
        end
        
        holy_item:setMaskVisible(holy_item.is_ui_select)
    end
end

function HeavenDialWishWindow:createNewCell(  )
	local cell = DialWishItem.new()
	cell:setScale(0.9)
	cell:addCallBack(function() self:onCellTouched(cell) end)
	cell:addLongTimeTouchCallback(function() self:onCellLongTimeTouched(cell) end)
	
    return cell
end

function HeavenDialWishWindow:numberOfCells(  )
	if not self.heaven_data_list then return 0 end
	return #self.heaven_data_list
end

function HeavenDialWishWindow:updateCellByIndex( cell, index )
	cell.index = index
    local item_vo = self.heaven_data_list[index]
    if item_vo then
		cell:setData(item_vo,true)
		cell:IsGetStatus(false)
		for k,v in pairs(self.cur_item_id_list) do
			if v and v.lucky_holy_eqm == item_vo.group_id then
				cell:IsGetStatus(true)
				self.select_cell_list[v.pos] = cell
				break
			end
		end
    end
end

function HeavenDialWishWindow:onCellLongTimeTouched( cell )
	local item_vo = self.heaven_data_list[cell.index]
	if item_vo then
		item_vo.open_type = 1
		TipsManager:getInstance():showGoodsTips(item_vo)
	end
	
end

function HeavenDialWishWindow:onCellTouched( cell )
	if self.is_play_item_action then return end
	local isSelect = false
	local item_vo = self.heaven_data_list[cell.index]
	
	for k,v in pairs(self.cur_item_id_list) do
		if v and v.lucky_holy_eqm == item_vo.group_id then
			for i,j in pairs(self.select_cell_list) do
				local select_data = j:getData()
				if item_vo and select_data and item_vo.group_id == select_data.group_id then
					local item = self.select_cell_list[i]
					self.select_cell_list[i]:IsGetStatus(false)
					
					--结束位置 
					local world_pos = item:convertToWorldSpace(cc.p(BackPackItem.Width * 0.5, BackPackItem.Height * 0.5))    
					local end_pos = self.elfin_info_panel:convertToNodeSpace(world_pos) 
					local x, y = 0,0
					if self.cur_hero_item_list[v.pos] and self.cur_hero_item_list[v.pos].panel then
						x, y =  self.cur_hero_item_list[v.pos].panel:getPosition()
					end
					self:showMoveEffect(cc.p(x,y), end_pos, item_vo)
					self.select_cell_list[i] = nil
					break
				end
			end
			self.cur_item_id_list[k].lucky_holy_eqm = nil
			isSelect = true
			break
		end
	end
	
	if isSelect == false then
		for k,v in pairs(self.cur_item_id_list) do
			if v.pos == self.pos then
				if self.select_cell_list[self.pos] then
					self.select_cell_list[self.pos]:IsGetStatus(false)
					self.select_cell_list[self.pos] = nil
				end
				v.lucky_holy_eqm = item_vo.group_id
				self.select_cell_list[self.pos] = cell
				break
			end
		end
		local world_pos = cell:convertToWorldSpace(cc.p(BackPackItem.Width * 0.5, BackPackItem.Height * 0.5))    
		local start_pos = self.elfin_info_panel:convertToNodeSpace(world_pos) 
		local x, y = 0,0
		if self.cur_hero_item_list[self.pos] and self.cur_hero_item_list[self.pos].panel then
			x, y =  self.cur_hero_item_list[self.pos].panel:getPosition()
		end
        self:showMoveEffect(start_pos, cc.p(x,y), item_vo, function()
            self:updateCurHeroHolyItemList()
        end)
		cell:IsGetStatus(true)
	else
		self:updateCurHeroHolyItemList()
	end
end


--显示移动效果
--@start_pos 开始位置 
--@end_pos 结束位置
function HeavenDialWishWindow:showMoveEffect(start_pos, end_pos, equip_vo, callback)
    self.is_play_item_action = true
    if self.move_item == nil then
		self.move_item = DialWishItem.new()
		self.move_item:setScale(0.7)
        self.elfin_info_panel:addChild(self.move_item, 1)
    end
    self.move_item:setData(equip_vo)
    self.move_item:setPosition(start_pos)
    local action1 = cc.MoveTo:create(0.2, end_pos)
    local callfunc = cc.CallFunc:create(function()
        if self.move_item then
            self.move_item:setPosition(-10000, 0)
        end
        self.is_play_item_action = false
        if callback then
            callback()
        end
    end)
    self.move_item:runAction(cc.Sequence:create(action1,callfunc))
end

function HeavenDialWishWindow:register_event(  )
	-- tab 按钮
	for k, object in pairs(self.tab_list) do
		if object.tab_btn then
			object.tab_btn:addTouchEventListener(function(sender, event_type)
				if event_type == ccui.TouchEventType.ended and not self.is_show_egg_effect then
					playTabButtonSound()
					self:changeSelectedTab(object.index)
				end
			end)
		end
	end
	
	registerButtonEventListener(self.right_btn, handler(self, self.onClickChooseBtn), true)

	registerButtonEventListener(self.close_btn, function (  )
		self:onClickCloseBtn()
	end, true, 2)

	
	registerButtonEventListener(self.background, function ( )
		self:onClickCloseBtn()
	end, false, 2)
end

function HeavenDialWishWindow:onClickCloseBtn(  )
	_controller:openHeavenDialWishWindow(false)
end

function HeavenDialWishWindow:onClickChooseBtn(  )
	if not self.dial_data then
		return
	end
	local temp_list = {}
	for k,v in pairs(self.cur_item_id_list) do
		if v then
			local holy_eqm = v.lucky_holy_eqm
			if holy_eqm == nil  then
				holy_eqm = 0
			end
			_table_insert(temp_list, {pos = v.pos,lucky_holy_eqm = holy_eqm})	
		end
	end
	
	_controller:sender25230(self.dial_data.group_id,temp_list)
	self:onClickCloseBtn()
end

function HeavenDialWishWindow:changeSelectedTab( index )
	if self.cur_tab_index and self.cur_tab_index == index then return end
    if self.tab_object then
        self.tab_object.tab_btn:loadTextures(PathTool.getResFrame("common","common_2010"), PathTool.getResFrame("common","common_2010"), "", LOADTEXT_TYPE_PLIST)
        self.tab_object.label:setTextColor(Config.ColorData.data_new_color4[6])
		self.tab_object.label:disableEffect(cc.LabelEffect.SHADOW)
        self.tab_object = nil
	end
	
    self.tab_object = self.tab_list[index]
    if self.tab_object then
        self.tab_object.tab_btn:loadTextures(PathTool.getResFrame("common","common_2009"), PathTool.getResFrame("common","common_2009"), "", LOADTEXT_TYPE_PLIST)
        self.tab_object.label:setTextColor(Config.ColorData.data_new_color4[1])
		self.tab_object.label:enableShadow(Config.ColorData.data_new_color4[2],cc.size(0, -2),2)
    end

    self.cur_tab_index = index

	local conf_id = Config.HolyEqmLotteryData.data_wish_id[index]
	
	if conf_id then
		self.heaven_data_list = {}
		local have_cfg_list = {}
		for k,v in pairs(conf_id) do
			local cur_elfin_cfg = Config.HolyEqmLotteryData.data_wish_show[v.group_id]
			if cur_elfin_cfg then
				_table_insert(have_cfg_list, cur_elfin_cfg)
			end
		end	
		self.heaven_data_list = have_cfg_list
		self.select_cell_list = {}
		self.elfin_list_view:reloadData()
	end
end


function HeavenDialWishWindow:setData( data )
	if not data  then
		return
	end
	self.dial_data = data
	self.elfin_bid_list = {}
	
	for i=1,4 do
		local lucky_holy_eqm = nil
		for k,v in pairs(data.lucky_holy_eqm) do
			if v.pos == i then
				lucky_holy_eqm = v.lucky_holy_eqm
				break
			end
		end
		_table_insert(self.elfin_bid_list, {pos = i,lucky_holy_eqm = lucky_holy_eqm})
	end
	
	
	self.cur_item_id_list = self.elfin_bid_list
	self:updateCurHeroHolyItemList()
	self:changeSelectedTab(BackPackConst.item_type.GOD_EARRING)
end

function HeavenDialWishWindow:openRootWnd(pos,data)
	self.pos = pos or 1
	self:setData(data)
end

function HeavenDialWishWindow:close_callback(  )
	if self.elfin_list_view then
		self.elfin_list_view:DeleteMe()
		self.elfin_list_view = nil
	end

	if self.move_item then
        self.move_item:stopAllActions()
        if self.move_item.DeleteMe then
            self.move_item:DeleteMe()
        end
        self.move_item = nil
    end

	if self.cur_hero_item_list then
		for k,v in pairs(self.cur_hero_item_list) do
			if v.DeleteMe then
				v:DeleteMe()
			end
		end
		self.cur_hero_item_list = nil
	end
	_controller:openHeavenDialWishWindow(false)
end


--------------------------@ item
DialWishItem = class("DialWishItem", function()
    return ccui.Widget:create()
end)

function DialWishItem:ctor()
	self:configUI()
end

function DialWishItem:configUI(  )
	self.size = cc.size(BackPackItem.Width, BackPackItem.Height+50)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

    self.item_node = BackPackItem.new(false, true, false)
    self.item_node:setPosition(cc.p(self.size.width*0.5, self.size.height-BackPackItem.Height*0.5))
    self:addChild(self.item_node)
end

function DialWishItem:addCallBack( callback )
	if self.item_node then
		self.item_node:addCallBack(callback)
	end
end

--添加长时间点击的回调
function DialWishItem:addLongTimeTouchCallback(callback)
	if self.item_node then
		self.item_node:addLongTimeTouchCallback(callback)
	end
end

function DialWishItem:createSpriteMask(  )
	if self.item_node then
		self.item_node:createSpriteMask()
	end
end

function DialWishItem:setMaskVisible(bool)
	if self.item_node then
		self.item_node:setMaskVisible(bool)
	end
end

function DialWishItem:showAddIcon(bool)
	if self.item_node then
		self.item_node:showAddIcon(bool)
	end
end

function DialWishItem:setData( data,isShowName ,isTopIcon)
	self.data = data
	if self.item_node then
		if isTopIcon then
			self.item_node:setBackgroundOpacity(0)
		end
		if data then
			local icon_res = PathTool.getItemRes(data.icon)
			self.item_node:setItemIcon(icon_res)
			self.item_node:setSelfBackground(data.quality)
			if isShowName then
				if isTopIcon then
					self.item_node:setGoodsName(data.name,cc.p(holy_item.Width/2,-36),22,Config.ColorData.data_new_color4[1])
				else
					self.item_node:setGoodsName(data.name,cc.p(holy_item.Width/2,-36),18,Config.ColorData.data_new_color4[6])
				end
			end
		else
			if isTopIcon then
				self.item_node:setGoodsName(TI18N("心愿水晶"),cc.p(holy_item.Width/2,-36),22,Config.ColorData.data_new_color4[1])
			else
				self.item_node:setGoodsName("")
			end
			self.item_node.item_icon:setVisible(false)
			self.item_node:setSelfBackground(BackPackConst.quality.white)
		end
	end
end


function DialWishItem:getData()
	return self.data
end

function DialWishItem:IsGetStatus( status )
	if self.item_node then
		self.item_node:IsGetStatus(status)
	end
end

function DialWishItem:DeleteMe(  )
	if self.item_node then
		self.item_node:DeleteMe()
		self.item_node = nil
	end
end