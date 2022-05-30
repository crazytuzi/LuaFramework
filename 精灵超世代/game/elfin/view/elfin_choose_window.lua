--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-08-21 10:12:43
-- @description    : 
		-- 精灵选择界面
---------------------------------
local _controller = ElfinController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format
local _table_insert = table.insert

ElfinChooseWindow = ElfinChooseWindow or BaseClass(BaseView)

function ElfinChooseWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "elfin/elfin_choose_window"
end

function ElfinChooseWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 1)

	container:getChildByName("win_title"):setString(TI18N("精灵选择"))

	self.choose_btn = container:getChildByName("choose_btn")
	self.choose_btn:getChildByName("label"):setString(TI18N("选择"))
	self.close_btn = container:getChildByName("close_btn")

	self.no_choose_tips = container:getChildByName("no_choose_tips")
	self.no_choose_tips:setString(TI18N("请先选择精灵哦~"))
	self.elfin_info_panel = container:getChildByName("elfin_info_panel")
	--self.skill_name_txt = self.elfin_info_panel:getChildByName("skill_name_txt")
	self.skill_name_rich_text = createRichLabel(22, Config.ColorData.data_new_color4[16], cc.p(0, 0.5), cc.p(340, 172))
	self.elfin_info_panel:addChild(self.skill_name_rich_text)
	--self.skill_type_txt = self.elfin_info_panel:getChildByName("skill_type_txt")
	self.skill_type_rich_text = createRichLabel(22, Config.ColorData.data_new_color4[16], cc.p(0, 0.5), cc.p(340, 143))
	self.elfin_info_panel:addChild(self.skill_type_rich_text)
	self.skill_desc_scroll = createScrollView(350, 65, 238, 20, self.elfin_info_panel, ccui.ScrollViewDir.vertical)
	self.elfin_info_panel:getChildByName("score_title"):setString(TI18N("评分："))
	self.power_label = CommonNum.new(1, self.elfin_info_panel, 1, - 2, cc.p(0, 0))
    self.power_label:setPosition(cc.p(400, 115))
    self.power_label:setNum(0)
	self.power_label:setScale(0.7)
	
	self.elfin_list = container:getChildByName("elfin_list")
	local scroll_view_size = self.elfin_list:getContentSize()
    local list_setting = {
        start_x = 0,
        space_x = 33,
        start_y = 0,
        space_y = -20,
        item_width = BackPackItem.Width,
        item_height = BackPackItem.Height+50,
        row = 0,
        col = 4,
        need_dynamic = true
    }
    self.elfin_list_view = CommonScrollViewSingleLayout.new(self.elfin_list, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, list_setting, cc.p(0, 0)) 

    self.elfin_list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.elfin_list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.elfin_list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    self.elfin_list_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell

    self.choose_tips_txt = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(0, 0), cc.p(50, 715),0 ,0, 580)
    container:addChild(self.choose_tips_txt)
    self.choose_tips_txt:setString(_string_format(TI18N("重复选中可取消选择、<div fontcolor=#d63636>卸下</div>精灵")))
end

function ElfinChooseWindow:createNewCell(  )
	local cell = ElfinChooseItem.new()
	cell:setScale(0.9)
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end

function ElfinChooseWindow:numberOfCells(  )
	if not self.elfin_data_list then return 0 end
	return #self.elfin_data_list
end

function ElfinChooseWindow:updateCellByIndex( cell, index )
	cell.index = index
    local item_vo = self.elfin_data_list[index]
    if item_vo then
    	cell:setData(item_vo)
    	cell:showItemQualityName(true)
    	if self.cur_item_data and self.cur_item_data.base_id == item_vo.base_id then
    		cell:IsGetStatus(true)
    	else
    		cell:IsGetStatus(false)
    	end
    	if self.elfin_bid then
    		local elfin_cfg = Config.SpriteData.data_elfin_data(item_vo.base_id)
    		local cur_elfin_cfg = Config.SpriteData.data_elfin_data(self.elfin_bid)
    		local is_higher = false
    		if cur_elfin_cfg and elfin_cfg then
    			if elfin_cfg.sprite_type == cur_elfin_cfg.sprite_type and elfin_cfg.step > cur_elfin_cfg.step then
					is_higher = true
				end
    		end
    		addRedPointToNodeByStatus(cell, is_higher)
    	else
    		addRedPointToNodeByStatus(cell, false)
    	end
    end
end

function ElfinChooseWindow:onCellTouched( cell )
	if self.select_cell then
		self.select_cell:IsGetStatus(false)
	end
	local item_vo = self.elfin_data_list[cell.index]
	if self.cur_item_data and self.cur_item_data.base_id == item_vo.base_id then -- 点击选中的则取消选中
		self.select_cell = nil
		self.cur_item_data = nil
	else
		cell:IsGetStatus(true)
		self.select_cell = cell
		self.cur_item_data = item_vo
	end
	self:updateElfinInfo()
end

function ElfinChooseWindow:updateElfinInfo(  )
	if not self.cur_item_data then -- 没选中任何一个精灵
		self.elfin_info_panel:setVisible(false)
		self.no_choose_tips:setVisible(true)
		return
	end

	local elfin_cfg = Config.SpriteData.data_elfin_data(self.cur_item_data.base_id)
	if not elfin_cfg then return end

	-- 精灵图标
	if not self.elfin_item then
		self.elfin_item = ElfinChooseItem.new()
		self.elfin_item:setScale(0.9)
		self.elfin_item:setPosition(cc.p(95, 100))
		self.elfin_info_panel:addChild(self.elfin_item)
	end
	self.elfin_item:setData(self.cur_item_data)
	self.elfin_item:showItemQualityName(true)

	-- 技能图标
	if not self.skill_item then
		self.skill_item = SkillItem.new(false, true, true, 0.8)
		self.skill_item:setPosition(cc.p(285, 136))
		self.elfin_info_panel:addChild(self.skill_item)
	end

	self.power_label:setNum(elfin_cfg.power)
	if elfin_cfg.skill then
		local skill_cfg = Config.SkillData.data_get_skill(elfin_cfg.skill)
		if skill_cfg then
			self.skill_item:setData(skill_cfg)
			--self.skill_name_txt:setString(_string_format("%s <div fontcolor=#0e7709>Lv.%d</div>", skill_cfg.name, skill_cfg.level))
			self.skill_name_rich_text:setString(_string_format("%s <div fontcolor=#0e7709>Lv.%d</div>", skill_cfg.name, skill_cfg.level))
			if skill_cfg.type == "active_skill" then 
		        --self.skill_type_txt:setString(_string_format(TI18N("类型：<div fontcolor=#0e7709>主动技能</div>")))
				self.skill_type_rich_text:setString(_string_format(TI18N("类型：<div fontcolor=#0e7709>主动技能</div>")))
		    else 
		        --self.skill_type_txt:setString(_string_format(TI18N("类型：<div fontcolor=#0e7709>被动技能</div>")))
				self.skill_type_rich_text:setString(_string_format(TI18N("类型：<div fontcolor=#0e7709>被动技能</div>")))
		    end
		    -- 描述
		    if not self.skill_desc_txt then
		    	self.skill_desc_txt = createRichLabel(18, Config.ColorData.data_new_color4[16], cc.p(0, 1), cc.p(0, 0), nil, nil, 350)
		    	self.skill_desc_scroll:addChild(self.skill_desc_txt)
		    end
		    self.skill_desc_txt:setString(skill_cfg.des)
		    local desc_size = self.skill_desc_txt:getSize()
		    local max_height = math.max(desc_size.height, 70)
		    self.skill_desc_txt:setPositionY(max_height)
    		self.skill_desc_scroll:setInnerContainerSize(cc.size(self.skill_desc_scroll:getContentSize().width, max_height))
    		self.skill_desc_scroll:setTouchEnabled(desc_size.height > 70)
		end
	end

	self.elfin_info_panel:setVisible(true)
	self.no_choose_tips:setVisible(false)
end

function ElfinChooseWindow:register_event(  )
	registerButtonEventListener(self.choose_btn, handler(self, self.onClickChooseBtn), true)

	registerButtonEventListener(self.close_btn, function (  )
		_controller:openElfinChooseWindow(false)
	end, true, 2)

	registerButtonEventListener(self.background, function ( )
		_controller:openElfinChooseWindow(false)
	end, false, 2)
end

function ElfinChooseWindow:onClickChooseBtn(  )
	if not self.elfin_pos then return end
	if next(self.elfin_data_list) == nil then
		message(TI18N("没有可选择的精灵"))
		return
	end
	if not self.cur_item_data then
		_controller:sender26513(self.elfin_pos, 0)
	elseif not self.elfin_bid or self.elfin_bid ~= self.cur_item_data.base_id then
		_controller:sender26513(self.elfin_pos, self.cur_item_data.base_id)
	end
	_controller:openElfinChooseWindow(false)
end

function ElfinChooseWindow:openRootWnd( setting )
	self.elfin_pos = setting.elfin_pos
	self.elfin_bid = setting.elfin_bid
	local elfin_type
	if self.elfin_bid then
		local elfin_cfg = Config.SpriteData.data_elfin_data(self.elfin_bid)
		if elfin_cfg then
			elfin_type = elfin_cfg.sprite_type
		end
	end

	self.elfin_data_list = {}
	local all_elfin_data = BackpackController:getInstance():getModel():getAllBackPackArray(BackPackConst.item_tab_type.ELFIN) or {}
	local elfin_bid_list = _model:getElfinTreeElfinList()
	if elfin_bid_list and next(elfin_bid_list) ~= nil then -- 筛选掉同类型的精灵
		local have_type_list = {}
		for k,v in pairs(elfin_bid_list) do
			local cur_elfin_cfg = Config.SpriteData.data_elfin_data(v.item_bid)
			if cur_elfin_cfg then
				_table_insert(have_type_list, cur_elfin_cfg.sprite_type)
			end
		end
		local function checkIsSameElfinType( e_type )
			local is_same = false
			for _,v in pairs(have_type_list) do
				if v == e_type and (not elfin_type or elfin_type ~= e_type) then
					is_same = true
					break
				end
			end
			return is_same
		end
		for i,v in ipairs(all_elfin_data) do
			local elfin_cfg = Config.SpriteData.data_elfin_data(v.base_id)
			if elfin_cfg and not checkIsSameElfinType(elfin_cfg.sprite_type) then
				_table_insert(self.elfin_data_list, deepCopy(v))
			end
		end
	else
		self.elfin_data_list = all_elfin_data
	end

	-- 如果是从古树位置上某一个精灵打开界面，那么这个精灵也要显示在列表中
	if self.elfin_bid then
		local is_have = false
		for k,v in pairs(self.elfin_data_list) do
			if v.base_id == self.elfin_bid then
				v.quantity = v.quantity + 1
				is_have = true
				break
			end
		end
		if not is_have then
			local goodvo = GoodsVo.New(self.elfin_bid)
			goodvo.quantity = 1
			_table_insert(self.elfin_data_list, goodvo)
		end
	end

	if next(self.elfin_data_list) == nil then
		self.elfin_info_panel:setVisible(false)
		self.no_choose_tips:setVisible(true)
		commonShowEmptyIcon(self.elfin_list, true, {text = TI18N("一个精灵都没有噢，快去孵化获取吧~"), font_size = 22})
	else
		local function sort_func( objA, objB )
			if objA.base_id == self.elfin_bid and objB.base_id ~= self.elfin_bid then
				return true
			elseif objA.base_id ~= self.elfin_bid and objB.base_id == self.elfin_bid then
				return false
			elseif objA.quality ~= objB.quality then
				return objA.quality > objB.quality
			elseif objA.eqm_jie ~= objB.eqm_jie then
				return objA.eqm_jie > objB.eqm_jie
			else
				return objA.base_id < objB.base_id
			end
		end
		table.sort(self.elfin_data_list, sort_func)
		self.elfin_list_view:reloadData(1)
		commonShowEmptyIcon(self.elfin_list, false)
	end
end

function ElfinChooseWindow:close_callback(  )
	if self.power_label then
        self.power_label:DeleteMe()
        self.power_label = nil
    end
	if self.elfin_list_view then
		self.elfin_list_view:DeleteMe()
		self.elfin_list_view = nil
	end
	if self.elfin_item then
		self.elfin_item:DeleteMe()
		self.elfin_item = nil
	end
	if self.skill_item then
		self.skill_item:DeleteMe()
		self.skill_item = nil
	end
	_controller:openElfinChooseWindow(false)
end


--------------------------@ item
ElfinChooseItem = class("ElfinChooseItem", function()
    return ccui.Widget:create()
end)

function ElfinChooseItem:ctor()
	self:configUI()
end

function ElfinChooseItem:configUI(  )
	self.size = cc.size(BackPackItem.Width, BackPackItem.Height+50)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

    self.item_node = BackPackItem.new(false, true, false)
    self.item_node:setPosition(cc.p(self.size.width*0.5, self.size.height-BackPackItem.Height*0.5))
    self:addChild(self.item_node)
end

function ElfinChooseItem:addCallBack( callback )
	if self.item_node then
		self.item_node:addCallBack(callback)
	end
end

function ElfinChooseItem:setData( data )
	if self.item_node then
		self.item_node:setData(data)
	end
end

function ElfinChooseItem:showItemQualityName( status )
	if self.item_node then
		if status == true then
			if not self.item_node.quality_name_bg then
				local res = nil--PathTool.getResFrame("common","common_90010")
				self.item_node.quality_name_bg = createImage(self.item_node.main_container, res, self.item_node.size.width*0.5, -5, cc.p(0.5, 1), true, nil, true)
				self.item_node.quality_name_bg:setContentSize(cc.size(128, 37))
				self.item_node.quality_name_txt = createLabel(20, 1, nil, 128*0.5, 37*0.5, "", self.item_node.quality_name_bg, nil, cc.p(0.5, 0.5))
			end
			if self.item_node.item_config then
				self.item_node.quality_name_txt:setString(self.item_node.item_config.name)
				self.item_node.quality_name_txt:setTextColor(BackPackConst.getWhiteQualityColorC4B(self.item_node.item_config.quality))
			end
		elseif self.item_node.quality_name_bg then
			self.item_node.quality_name_bg:setVisible(false)
		end
	end
end

function ElfinChooseItem:IsGetStatus( status )
	if self.item_node then
		self.item_node:IsGetStatus(status)
	end
end

function ElfinChooseItem:DeleteMe(  )
	if self.item_node then
		self.item_node:DeleteMe()
		self.item_node = nil
	end
end