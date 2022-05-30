--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-08-21 19:25:06
-- @description    : 
		-- 精灵融合界面
---------------------------------
local _controller = ElfinController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format
local _table_insert = table.insert

ElfinCompoundWindow = ElfinCompoundWindow or BaseClass(BaseView)

function ElfinCompoundWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "elfin/elfin_compound_window"
end

function ElfinCompoundWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	self.container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(self.container, 1)

	self.arrow_sp_1 = self.container:getChildByName("arrow_sp_1")
	self.arrow_sp_1:setVisible(false)
	self.arrow_sp_2 = self.container:getChildByName("arrow_sp_2")
	self.arrow_sp_2:setVisible(false)

	self.btn_close = self.container:getChildByName("btn_close")
	self.change_btn = self.container:getChildByName("change_btn")
	self.change_btn:getChildByName("label"):setString(TI18N("更换"))
	self.compound_btn = self.container:getChildByName("compound_btn")
	self.compound_btn:getChildByName("label"):setString(TI18N("灵合"))

	self.container:getChildByName("win_title"):setString(TI18N("灵合"))
	self.container:getChildByName("com_title"):setString(TI18N("精灵融合"))
	self.container:getChildByName("cost_title"):setString(TI18N("升级消耗"))
	self.container:getChildByName("com_tips"):setString(TI18N("灵合后技能等级提升"))

	self.skill_type_1 = self.container:getChildByName("skill_type_1")
	self.skill_name_1 = self.container:getChildByName("skill_name_1")
	self.skill_type_2 = self.container:getChildByName("skill_type_2")
	self.skill_name_2 = self.container:getChildByName("skill_name_2")
	self.skill_type_2_rt = createRichLabel(22, Config.ColorData.data_new_color4[16], cc.p(0, 0.5), cc.p(370, 465))
	self.skill_name_2_rt = createRichLabel(22, Config.ColorData.data_new_color4[16], cc.p(0, 0.5), cc.p(370, 495))
	self.container:addChild(self.skill_type_2_rt)
	self.container:addChild(self.skill_name_2_rt)

	self.cost_objects = {}
	for i=1,2 do
		local object = {}
		object.item_node = BackPackItem.new(false, true, false, 0.8, nil, true)
		object.item_node:setPosition(cc.p(242+(i-1)*200, 189))
		self.container:addChild(object.item_node)
		object.cost_name = self.container:getChildByName("cost_name_" .. i)
		object.cost_num = self.container:getChildByName("cost_num_" .. i)
		_table_insert(self.cost_objects, object)
	end

	self.cur_skill_desc_scroll = createScrollView(350, 85, 282, 594, self.container, ccui.ScrollViewDir.vertical)
	self.next_skill_desc_scroll = createScrollView(350, 85, 282, 334, self.container, ccui.ScrollViewDir.vertical)
end

function ElfinCompoundWindow:register_event(  )
	registerButtonEventListener(self.btn_close, function (  )
		_controller:openElfinCompoundWindow(false)
	end, true, 2)

	registerButtonEventListener(self.background, function ( )
		_controller:openElfinCompoundWindow(false)
	end, false, 2)

	registerButtonEventListener(self.change_btn, handler(self, self.onClickChangeBtn), true)

	registerButtonEventListener(self.compound_btn, handler(self, self.onClickCompoundBtn), true)
end

function ElfinCompoundWindow:onClickChangeBtn(  )
	if self.elfin_pos then
			local setting = {}
		setting.elfin_pos = self.elfin_pos
		setting.elfin_bid = self.elfin_bid
		_controller:openElfinChooseWindow(true, setting)
		_controller:openElfinCompoundWindow(false)
	end
end

function ElfinCompoundWindow:onClickCompoundBtn(  )
	if self.elfin_bid then
		_controller:sender26508(self.elfin_bid, 1, self.elfin_pos or 0)
	end
end

function ElfinCompoundWindow:openRootWnd( elfin_bid, elfin_pos )
	self.elfin_bid = elfin_bid
	self.elfin_pos = elfin_pos
	self:setData()

	-- 没有精灵的位置，则表示不是从古树界面点击精灵打开，隐藏更换按钮
	if not self.elfin_pos then
		self.change_btn:setVisible(false)
		self.compound_btn:setPositionX(340)
	else
		self.change_btn:setVisible(true)
	end
end

function ElfinCompoundWindow:setData(  )
	if not self.elfin_bid then return end

	local com_cfg = Config.SpriteData.data_elfin_com[self.elfin_bid]
	if not com_cfg then return end

	local next_elfin_bid = com_cfg.award
	local cur_elfin_item_cfg = Config.ItemData.data_get_data(self.elfin_bid)
	local cur_elfin_cfg = Config.SpriteData.data_elfin_data(self.elfin_bid)
	local next_elfin_item_cfg = Config.ItemData.data_get_data(next_elfin_bid)
	local next_elfin_cfg = Config.SpriteData.data_elfin_data(next_elfin_bid)
	if not cur_elfin_item_cfg or not cur_elfin_cfg or not next_elfin_item_cfg or not next_elfin_cfg then return end

	-- 融合前的精灵
	if not self.cur_elfin_item then
		self.cur_elfin_item = BackPackItem.new(true, false)
		self.cur_elfin_item:setPosition(cc.p(130, 710))
		self.cur_elfin_item:setScale(0.9)
		self.container:addChild(self.cur_elfin_item)
	end
	self.cur_elfin_item:setData(cur_elfin_item_cfg)
	self.cur_elfin_item:showItemQualityName(true)

	if not self.cur_elfin_skill then
		self.cur_elfin_skill = SkillItem.new(false, false, false, 0.7)
		self.cur_elfin_skill:setPosition(cc.p(320, 726))
		self.container:addChild(self.cur_elfin_skill)
	end
	if cur_elfin_cfg.skill then
		local skill_cfg = Config.SkillData.data_get_skill(cur_elfin_cfg.skill)
		if skill_cfg then
			self.cur_elfin_skill:setData(skill_cfg)
			self.skill_name_1:setString(_string_format("%s Lv.%d", skill_cfg.name, skill_cfg.level))
			if skill_cfg.type == "active_skill" then 
		        self.skill_type_1:setString(TI18N("类型：主动技能"))
		    else 
		        self.skill_type_1:setString(TI18N("类型：被动技能")) 
		    end
		    -- 描述
		    if not self.cur_skill_desc_txt then
		    	self.cur_skill_desc_txt = createRichLabel(18, cc.c4b(154,109,77,255), cc.p(0, 1), cc.p(0, 0), 5, nil, 350)
		    	self.cur_skill_desc_scroll:addChild(self.cur_skill_desc_txt)
		    end
		    self.cur_skill_desc_txt:setString(skill_cfg.des)
		    local desc_size = self.cur_skill_desc_txt:getSize()
		    local max_height = math.max(desc_size.height, 85)
		    self.cur_skill_desc_txt:setPositionY(max_height)
    		self.cur_skill_desc_scroll:setInnerContainerSize(cc.size(self.cur_skill_desc_scroll:getContentSize().width, max_height))
    		self.cur_skill_desc_scroll:setTouchEnabled(desc_size.height > 85)
    		self.arrow_sp_1:setVisible(desc_size.height > 85)
		end
	end

	-- 融合后的精灵
	if not self.next_elfin_item then
		self.next_elfin_item = BackPackItem.new(true, false)
		self.next_elfin_item:setPosition(cc.p(130, 448))
		self.next_elfin_item:setScale(0.9)
		self.container:addChild(self.next_elfin_item)
	end
	self.next_elfin_item:setData(next_elfin_item_cfg)
	self.next_elfin_item:showItemQualityName(true)

	if not self.next_elfin_skill then
		self.next_elfin_skill = SkillItem.new(false, false, false, 0.7)
		self.next_elfin_skill:setPosition(cc.p(320, 466))
		self.container:addChild(self.next_elfin_skill)
	end
	if next_elfin_cfg.skill then
		local skill_cfg = Config.SkillData.data_get_skill(next_elfin_cfg.skill)
		if skill_cfg then
			self.next_elfin_skill:setData(skill_cfg)
			--self.skill_name_2:setString(_string_format("%s Lv.%d", skill_cfg.name, skill_cfg.level))
			self.skill_name_2_rt:setString(_string_format("%s <div fontcolor=#0e7709>Lv.%d</div>", skill_cfg.name, skill_cfg.level))
			if skill_cfg.type == "active_skill" then 
		        --self.skill_type_2:setString(TI18N("类型：主动技能"))
				self.skill_type_2_rt:setString(TI18N("类型： <div fontcolor=#0e7709>类型：主动技能</div>"))
		    else 
		        --self.skill_type_2:setString(TI18N("类型：被动技能"))
			self.skill_type_2_rt:setString(TI18N("类型： <div fontcolor=#0e7709>类型：被动技能</div>"))
			end
			-- 描述
		    if not self.next_skill_desc_txt then
		    	self.next_skill_desc_txt = createRichLabel(18, cc.c4b(154,109,77,255), cc.p(0, 1), cc.p(0, 0), 5, nil, 350)
		    	self.next_skill_desc_scroll:addChild(self.next_skill_desc_txt)
		    end
		    self.next_skill_desc_txt:setString(skill_cfg.des)
		    local desc_size = self.next_skill_desc_txt:getSize()
		    local max_height = math.max(desc_size.height, 85)
		    self.next_skill_desc_txt:setPositionY(max_height)
    		self.next_skill_desc_scroll:setInnerContainerSize(cc.size(self.next_skill_desc_scroll:getContentSize().width, max_height))
    		self.next_skill_desc_scroll:setTouchEnabled(desc_size.height > 85)
    		self.arrow_sp_2:setVisible(desc_size.height > 85)
		end
	end

	-- 消耗
	local is_can_com = true
	for i,v in ipairs(com_cfg.expend) do
		local item_bid = v[1]
		local item_num = v[2]
		local item_cfg = Config.ItemData.data_get_data(item_bid)
		local object = self.cost_objects[i]
		if item_cfg and object then
			object.item_node:setData(item_cfg)
			object.cost_name:setString(item_cfg.name)
			local have_num = BackpackController:getInstance():getModel():getItemNumByBid(item_bid)
			-- 没有self.elfin_pos则为背包界面打开灵合，此时，精灵本体不能计算在消耗数量上，需减1
			if not self.elfin_pos and item_bid == self.elfin_bid then
				have_num = have_num -1
			end
            object.cost_num:setString(_string_format("%s/%s", MoneyTool.GetMoneyString(have_num, false), MoneyTool.GetMoneyString(item_num, false)))
            if have_num < item_num then
            	is_can_com = false
                object.cost_num:setTextColor(Config.ColorData.data_new_color4[11])
            else
                object.cost_num:setTextColor(Config.ColorData.data_new_color4[12])
            end
		end
	end

	if self.elfin_pos and is_can_com then
		addRedPointToNodeByStatus(self.compound_btn, true, 10 ,10)
	else
		addRedPointToNodeByStatus(self.compound_btn, false)
	end

	if self.elfin_pos then
		-- 是否有同类型更高阶的精灵
		local is_higher = false
		local all_elfin_data = BackpackController:getInstance():getModel():getAllBackPackArray(BackPackConst.item_tab_type.ELFIN) or {}
		for k,v in pairs(all_elfin_data) do
			local elfin_cfg = Config.SpriteData.data_elfin_data(v.base_id)
			if elfin_cfg then
				if elfin_cfg.sprite_type == cur_elfin_cfg.sprite_type and elfin_cfg.step > cur_elfin_cfg.step then
					is_higher = true
					break
				end
			end
		end
		addRedPointToNodeByStatus(self.change_btn, is_higher, 10, 10)
	else
		addRedPointToNodeByStatus(self.change_btn, false)
	end
end

function ElfinCompoundWindow:close_callback(  )
	if self.cur_elfin_item then
		self.cur_elfin_item:DeleteMe()
		self.cur_elfin_item = nil
	end
	if self.cur_elfin_skill then
		self.cur_elfin_skill:DeleteMe()
		self.cur_elfin_skill = nil
	end
	if self.next_elfin_item then
		self.next_elfin_item:DeleteMe()
		self.next_elfin_item = nil
	end
	if self.next_elfin_skill then
		self.next_elfin_skill:DeleteMe()
		self.next_elfin_skill = nil
	end
	for k,object in pairs(self.cost_objects) do
		if object.item_node then
			object.item_node:DeleteMe()
			object.item_node = nil
		end
	end
	_controller:openElfinCompoundWindow(false)
end