--------------------------------------------
-- @Author  :
-- @Editor  : lwc
-- @Date    : 2018-11-24 14:42:13
-- @description    : 
		-- 阵营详细
---------------------------------
BattleCampView = BattleCampView or BaseClass(BaseView)

local controller = BattleController:getInstance()
local _table_insert = table.insert
local _string_format = string.format

function BattleCampView:__init()
    self.is_full_screen = false
	self.win_type = WinType.Tips   
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.layout_name = "battle/battle_camp_view"
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("battlecamp", "battlecamp"), type = ResourcesType.plist},
	}
end

function BattleCampView:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
	self.main_container = main_container
	self:playEnterAnimatianByObj(main_container, 2)
	self.main_size = main_container:getContentSize()

	local title_label_1 = main_container:getChildByName("title_label_1")
	title_label_1:setString(TI18N("种族克制"))
	local title_label_2 = main_container:getChildByName("title_label_2")
	title_label_2:setString(TI18N("种族克制效果:"))
	local attr_label_1 = main_container:getChildByName("attr_label_1")
	attr_label_1:setString(TI18N("伤害+25%"))
	local attr_label_2 = main_container:getChildByName("attr_label_2")
	attr_label_2:setString(TI18N("命中+20%"))

	local list_panel = main_container:getChildByName("list_panel")
	local bgSize = list_panel:getContentSize()
	local scroll_view_size = cc.size(bgSize.width, bgSize.height)
    local setting = {
        -- item_class = BattleCampItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 5,                   -- y方向的间隔
        item_width = 568,               -- 单元的尺寸width
        item_height = 198,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }

    self.camp_scrollview = CommonScrollViewSingleLayout.new(list_panel, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    -- self.camp_scrollview:setSwallowTouches(false)
    self.camp_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.camp_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.camp_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function BattleCampView:createNewCell(width, height)
    local cell = BattleCampItem.new(width, height)
    -- cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function BattleCampView:numberOfCells()
    return #self.show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function BattleCampView:updateCellByIndex(cell, index)
    cell.index = index
    local data = self.show_list[index]
    cell:setData(data, index)
end

function BattleCampView:openRootWnd( form_id_list )
	self.form_id_list = form_id_list or {}
	self.form_pos_info = {}
	for k,form_id in pairs(self.form_id_list) do
		local form_cfg = Config.CombatHaloData.data_halo[form_id]
		if form_cfg then
			for _,v in pairs(form_cfg.pos_info) do
				local camp_type = v[1]
				local camp_num = v[2]
				if not self.form_pos_info[camp_type] then
					self.form_pos_info[camp_type] = camp_num
				else
					self.form_pos_info[camp_type] = self.form_pos_info[camp_type] + camp_num
				end
			end
		end
	end
	self:updateAllAttrText()
	self:refreshCampList()
end

-- 全部加成提示
function BattleCampView:updateAllAttrText(  )
	if not self.all_attr_txt then
		self.all_attr_txt = createRichLabel(22, cc.c4b(61,80,120,255), cc.p(0.5, 0.5), cc.p(self.main_size.width*0.5, 435), nil, nil, self.main_size.width)
		self.main_container:addChild(self.all_attr_txt)
	end
	local attr_list = {}
	for k,form_id in pairs(self.form_id_list) do
		local form_cfg = Config.CombatHaloData.data_halo[form_id]
		if form_cfg and form_cfg.attrs and next(form_cfg.attrs) ~= nil then
			for _,v in pairs(form_cfg.attrs) do
				local is_have = false
				for _,attr in pairs(attr_list) do
					if attr[1] == v[1] then
						is_have = true
						attr[2] = attr[2] + v[2]
						break
					end
				end
				if not is_have then
					_table_insert(attr_list, deepCopy(v))
				end
			end
		end
	end
	if next(attr_list) == nil then
		self.all_attr_txt:setString(TI18N("未激活阵营光环"))
	else
		local attr_str = ""
		for i,v in ipairs(attr_list) do
			local attr_key = v[1]
			local attr_val = v[2]/1000
    		local attr_name = Config.AttrData.data_key_to_name[attr_key]
    		if attr_name then
    			local is_per = PartnerCalculate.isShowPerByStr(attr_key)
	            if is_per == true then
	                attr_val = (attr_val*100).."%"
	            end
	            if i == 1 then
	            	attr_str = attr_str .. _string_format("%s<div fontcolor=#0E7709>+%s</div>", attr_name, attr_val)
	            else
	            	attr_str = attr_str .. _string_format("  %s<div fontcolor=#0E7709>+%s</div>", attr_name, attr_val)
	            end
    		end
		end
		self.all_attr_txt:setString(TI18N("总加成效果:") .. attr_str)
	end
end

function BattleCampView:checkIsActivateCamp( pos_info )
	local is_activate = false
	if pos_info and next(pos_info) ~= nil then
		is_activate = true
		for _,v in pairs(pos_info) do
			local camp_type = v[1]
			local camp_num = v[2]
			local have_num = 0
			for _type,num in pairs(self.form_pos_info) do
				if _type == camp_type then
					have_num = num
					break
				end
			end
			if camp_num > have_num then
				is_activate = false
				break
			end
		end
	end
	return is_activate
end

function BattleCampView:refreshCampList(  )
	local camp_show_config = Config.CombatHaloData.data_halo_show
	if camp_show_config then
		local camp_data = {}
		local all_activate_id = 6  --记录id 6是 融合之力的
		local is_all_activate = false --记录是否激活了 id 6的
		for id,v in pairs(camp_show_config) do
			local data = deepCopy(v)
			local show_cfg = {}
			show_cfg.id = id
			show_cfg.is_activate = false
			for _,cfg in pairs(data) do
				cfg.is_activate = self:checkIsActivateCamp(cfg.pos_info)
				if cfg.is_activate then
					show_cfg.is_activate = true
					if show_cfg.id == all_activate_id then
						is_all_activate = true
					end
				end
				if not show_cfg.name then
					show_cfg.name = cfg.name
				end
				if not show_cfg.icon then
					show_cfg.icon = cfg.icon
				end
			end
			show_cfg.attr_data = data
			table.insert(camp_data, show_cfg)
		end
		--是否已经触发了融合之力的
		if is_all_activate then
			for i,v in ipairs(camp_data) do
				if v.id ~= all_activate_id then --那么除了融合之力的 其他都不能激活
					v.is_activate = false
				end
			end
		end
		local function SortFunc( objA, objB )
			if objA.is_activate and not objB.is_activate then
				return true
			elseif not objA.is_activate and objB.is_activate then
				return false
			else
				return objA.id < objB.id
			end
		end
		table.sort(camp_data, SortFunc)
		self.show_list = camp_data
		-- self.camp_scrollview:setData(camp_data)
		self.camp_scrollview:reloadData()
	end
end

function BattleCampView:register_event(  )
	registerButtonEventListener(self.background, handler(self, self._onClickBtnClose), false, 2)

	-- 战斗结束时关闭界面
	self:addGlobalEvent(SceneEvent.EXIT_FIGHT, function (  )
		controller:openBattleCampView(false)
	end)
end

function BattleCampView:_onClickBtnClose(  )
	controller:openBattleCampView(false)
end

function BattleCampView:close_callback(  )
	if self.camp_scrollview then
		self.camp_scrollview:DeleteMe()
		self.camp_scrollview = nil
	end
	controller:openBattleCampView(false)
end


--------------------------@ item
BattleCampItem = class("BattleCampItem", function()
    return ccui.Widget:create()
end)

function BattleCampItem:ctor(width, height)
	self:configUI(width, height)
	self:register_event()
end

function BattleCampItem:configUI(width, height)
	self.size = cc.size(width, height)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("battle/battle_camp_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("main_container")
    self.container = container

    self.cur_bg = container:getChildByName("cur_bg")
    self.cur_bg:setVisible(false)
    self.form_icon = container:getChildByName("form_icon")
    self.name = container:getChildByName("name")
    self.line = container:getChildByName("line")
    self.sp_activate = container:getChildByName("sp_activate")
    self.sp_activate:setVisible(false)

    self.attr_label = createRichLabel(18, 1, cc.p(0, 0.5), cc.p(130, 89), 5, nil, 430)
    self.container:addChild(self.attr_label)
end

function BattleCampItem:setData( data, index )
	if data then
		-- 是否激活
		if data.is_activate == true then
			self.cur_bg:setVisible(true)
			self.sp_activate:setVisible(true)
			setChildUnEnabled(false, self.form_icon)
		else
			self.cur_bg:setVisible(false)
			self.sp_activate:setVisible(false)
			setChildUnEnabled(true, self.form_icon)
		end

		-- 名称
		self.name:setString(data.name)

		-- if data.id == 4 or data.id == 5 then
		-- 	self.name:setPositionY(145)
		-- else
		-- 	self.name:setPositionY(140)
		-- end

		-- 图标
		local form_res = PathTool.getCampGroupIcon(data.icon)
		self.form_icon_load = loadImageTextureFromCDN(self.form_icon, form_res, ResourcesType.single, self.form_icon_load)

		-- 底线
		-- self.line:setVisible(index ~= Config.CombatHaloData.data_halo_show_length)
		if data.id == 6 then
			if self.tip_label == nil then
				self.tip_label = createRichLabel(18, Config.ColorData.data_new_color4[6], cc.p(0.5, 0.5), cc.p(self.size.width * 0.5, 25), 5, nil, self.size.width)
				self.container:addChild(self.tip_label)
				self.tip_label:setString(_string_format(TI18N("（本光环触发时，不同时触发<div fontcolor=#0e7709>辉光之力</div>和<div fontcolor=#0e7709>深黯之力</div>）")))
			else
				self.tip_label:setVisible(true)
			end
		else
			if self.tip_label then
				self.tip_label:setVisible(false)
			end
		end

		-- 属性
		local desc_str = ""
		local index_flag = 0
		for i,v in ipairs(data.attr_data) do
			if v.is_activate and data.is_activate then
				index_flag = i
			end
		end
		for i,v in ipairs(data.attr_data) do
			local str = v.desc
			for _,attr in ipairs(v.attrs) do
				local attr_key = attr[1]
				local attr_val = attr[2]/1000
        		local attr_name = Config.AttrData.data_key_to_name[attr_key]
        		if attr_name then
        			local is_per = PartnerCalculate.isShowPerByStr(attr_key)
		            if is_per == true then
		                attr_val = (attr_val*100).."%"
		            end
		            if i == index_flag then
		            	str = str .. _string_format("    %s<div fontcolor=#0E7709>+%s</div>", attr_name, attr_val) --
		            else
		            	str = str .. _string_format("    %s+%s", attr_name, attr_val)
		            end
        		end
			end
			if i == index_flag then
				str = _string_format("<div fontcolor=#1051FF>%s</div>", str)
			else
				str = _string_format("<div fontcolor=#3D5078>%s</div>", str)
			end
			desc_str = desc_str .. str .. "\n"
		end
		self.attr_label:setString(desc_str)

	end
end

function BattleCampItem:register_event(  )
end

function BattleCampItem:DeleteMe(  )
	if self.form_icon_load then
		self.form_icon_load:DeleteMe()
		self.form_icon_load = nil
	end
	self:removeAllChildren()
	self:removeFromParent()
end