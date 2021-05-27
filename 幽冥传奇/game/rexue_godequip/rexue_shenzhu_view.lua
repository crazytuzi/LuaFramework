------------------------------------------------------------
-- 热血装备-神铸 配置:GodCastingCfg 神格配置:GodQualityCfg 套装配置:GodCastingConfig
------------------------------------------------------------

local RexueShenzhuView = BaseClass(SubView)

function RexueShenzhuView:__init()
	self.texture_path_list[1] = 'res/xui/rexue.png'
	self.config_tab = {
		{"rexue_god_equip_ui_cfg", 9, {0}},
	}

	self.effect_list = {}
	self.can_shenzhu = false
	self.is_new_per = false
	self.consume_data_list = {}
end

function RexueShenzhuView:__delete()
end

function RexueShenzhuView:ReleaseCallBack()
	self.effect_list = {}
	self.consume_data_list = {}
end

function RexueShenzhuView:LoadCallBack(index, loaded_times)
	self:CreateTabbar()
	self:CreateEquipList()
	self:CreateCells()
	self:CreateNumber()
	self:CreateConsumeList()

	XUI.AddRemingTip(self.node_t_list["btn_shenge"].node)
	self.node_t_list["img_1"].node:setVisible(false) -- 额外效果默认不显示 ("+不掉级")

	-- 按钮监听
	XUI.AddClickEventListener(self.node_t_list["btn_1"].node, BindTool.Bind(self.OnBtn, self))
	XUI.AddClickEventListener(self.node_t_list["btn_shenge"].node, BindTool.Bind(self.OnShenge, self))
	XUI.AddClickEventListener(self.node_t_list["btn_suit"].node, BindTool.Bind(self.OnSuit, self))
	XUI.AddClickEventListener(self.node_t_list["btn_tip"].node, BindTool.Bind(self.OpenShowTips, self))

	-- 数据监听
	local rexuegod_equip_eventproxy = EventProxy.New(ReXueGodEquipData.Instance, self)
	rexuegod_equip_eventproxy:AddEventListener(ReXueGodEquipData.SHENZHU_RESULT, BindTool.Bind(self.OnShenzhuResult, self))
	rexuegod_equip_eventproxy:AddEventListener(ReXueGodEquipData.SHENGE_RESULT, BindTool.Bind(self.OnShengeResult, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
end

--显示索引回调
function RexueShenzhuView:ShowIndexCallBack(index)
	self.tabbar:SetToggleVisible(1, ReXueGodEquipData.ReXueShenzhuIsOpen(1))
	self.tabbar:SetToggleVisible(2, ReXueGodEquipData.ReXueShenzhuIsOpen(2))
	self.tabbar:SetToggleVisible(3, ReXueGodEquipData.ReXueShenzhuIsOpen(3))

	local _type = ReXueGodEquipData.Instance:GetShenzhuType()
	self.tabbar:ChangeToIndex(_type)
	self:TabbarCallBack(_type)

	self:FlushBtnRemind()
end

function RexueShenzhuView:CloseCallBack(index)
	if self.node_t_list["img_1"] then
		self.node_t_list["img_1"].node:setVisible(false)
	end

	ReXueGodEquipData.Instance:SetShenzhuType(1)
	ReXueGodEquipData.Instance:SetShenzhuSelectData()
end

function RexueShenzhuView:OnFlush(index)
	local equip_items = self.equip_list:GetItems()
	for i, v in ipairs(equip_items) do
		v:Flush()
	end

	self:FlushEffectList()
	self:FlushSelectShow()
	self:FlushBtnRemind()
end

----------视图函数----------

function RexueShenzhuView:CreateTabbar()
	local parent = self.node_t_list["layout_shenzhu"].node
	local ph = self.ph_list["ph_tabbar"] or {x = 0, y = 0, w = 10, h = 10} -- 锚点为0,0
	local name_list = Language.ReXueGodEquip.TabGroup4	-- 标题文本
	local is_vertical = false 		-- 按钮-垂直排列
	local path = ResPath.GetCommon("toggle_121")
	local font_size = 25 			-- 标题字体大小
	local is_txt_vertical = false	-- 文本-垂直排列
	local interval = 10 			-- 间隔

	local callback = BindTool.Bind(self.TabbarCallBack, self)   -- 点击回调
	
	local tabbar = Tabbar.New()
	tabbar:SetSpaceInterval(interval)
	tabbar:SetClickItemValidFunc(valid_func)
	tabbar:CreateWithNameList(parent, ph.x, ph.y, callback, name_list, is_vertical, path, font_size, is_txt_vertical)
	self.tabbar = tabbar
	self:AddObj("tabbar")
end

function RexueShenzhuView:CreateEquipList()
	local ph = self.ph_list["ph_equip_list"] or {x = 0, y = 0, w = 1, h = 1,}
	local ph_item = self.ph_list["ph_equip_item"] or {x = 0, y = 0, w = 1, h = 1,}
	local parent = self.node_t_list["layout_shenzhu"].node
	local item_render = self.EquipItem
	local line_dis = ph_item.h + 3
	local direction = ScrollDir.Vertical -- Vertical=1：竖向 Horizontal=2：横向：Both=3：横竖都可以
	
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, line_dis, item_render, direction, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 99)
	grid_scroll:SetSelectCallBack(BindTool.Bind(self.OnEquipCallBack, self))
	self.equip_list = grid_scroll
	self:AddObj("equip_list")
end

function RexueShenzhuView:CreateCells()
	local parent = self.node_t_list["layout_shenzhu"].node
	local ph = self.ph_list["ph_cell_1"] or {x = 0, y = 0, w = 10, h = 10}
	local cell = BaseCell.New()
	cell:SetPosition(ph.x, ph.y)
	parent:addChild(cell:GetView(), 99)
	self.equip = cell
	self:AddObj("equip")
end

function RexueShenzhuView:CreateNumber()
	local parent = self.node_t_list["layout_cur_shenzhu"].node
	local ph = self.ph_list["ph_shenzhu_lv_1"]
	local path = ResPath.GetCommon("num_15_")
	local number_bar = NumberBar.New()
	number_bar:Create(ph.x, ph.y, ph.w, ph.h, path)
	number_bar:SetSpace(-5)
	number_bar:SetGravity(NumberBarGravity.Center)
	parent:addChild(number_bar:GetView(), 99)
	self.shenzhu_lv_1 = number_bar
	self:AddObj("shenzhu_lv_1")

	local parent = self.node_t_list["layout_next_shenzhu"].node
	local ph = self.ph_list["ph_shenzhu_lv_2"]
	local path = ResPath.GetCommon("num_15_")
	local number_bar = NumberBar.New()
	number_bar:Create(ph.x, ph.y, ph.w, ph.h, path)
	number_bar:SetSpace(-5)
	number_bar:SetGravity(NumberBarGravity.Center)
	parent:addChild(number_bar:GetView(), 99)
	self.shenzhu_lv_2 = number_bar
	self:AddObj("shenzhu_lv_2")

	local parent = self.node_t_list["layout_consume"].node
	local ph = self.ph_list["ph_per"]
	local path = ResPath.GetCommon("num_16_")
	local number_bar = NumberBar.New()
	number_bar:Create(ph.x, ph.y, ph.w, ph.h, path)
	number_bar:SetSpace(-5)
	number_bar:SetGravity(NumberBarGravity.Center)
	parent:addChild(number_bar:GetView(), 99)
	self.per = number_bar
	self:AddObj("per")
end

function RexueShenzhuView:CreateConsumeList()
	local ph = self.ph_list["ph_consume_list"] or {x = 0, y = 0, w = 1, h = 1,}
	local ph_item = self.ph_list["ph_consume_item"] or {x = 0, y = 0, w = 1, h = 1,}
	local parent = self.node_t_list["layout_consume"].node
	local item_render = self.ConsumeRender
	local line_dis = ph_item.w
	local direction = ScrollDir.Horizontal -- 滑动方向-横向 -- Vertical=1：竖向 Horizontal=2：横向：Both=3：横竖都可以
	
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, line_dis, item_render, direction, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 99)
	grid_scroll:SetSelectCallBack(BindTool.Bind(self.OnConsume, self))
	self.consume_list = grid_scroll
	self:AddObj("consume_list")
end

-- 刷新"神格"按钮红点
function RexueShenzhuView:FlushShengeBtnRemind()
	local shenzhu_slot = self.select_data.shenzhu_slot or 0
	local next_shenge_cfg, next_shenge_lv = ReXueGodEquipData.Instance:GetShengeLevelCfg(shenzhu_slot, nil, true)
	local can_shenge = false
	if next(next_shenge_cfg) then
		local consumes = next_shenge_cfg.consumes or {}
		can_shenge = BagData.CheckConsumesCount(consumes)
	end

	self.node_t_list["btn_shenge"].node:UpdateReimd(can_shenge)
end

-- 刷新选择的装备显示
function RexueShenzhuView:FlushSelectShow()
	local shenzhu_slot = self.select_data.shenzhu_slot or 0
	local cur_cfg, cur_shenzhu_level = ReXueGodEquipData.Instance:GetShenzhuLevelCfg(shenzhu_slot)
	local next_cfg, next_shenzhu_level = ReXueGodEquipData.Instance:GetShenzhuLevelCfg(shenzhu_slot, nil, true)

	-- 神铸成功率
	local per = 0
	local rate = next_cfg.rate
	if type(rate) == "number" then
		per = math.floor(rate / 100)
	end
	self.per:SetNumber(per)
	self.is_new_per = true -- 用于额外消耗的刷新,为ture时,概率只加不减

	-- 神铸消耗
	self.consume_data_list = {}
	local consume = next_cfg.consumes and next_cfg.consumes[1]
	local can_shenzhu = consume ~= nil 
	if can_shenzhu then
		local has_count = BagData.Instance:GetItemNumInBagById(consume.id)
		local consume_count = consume.count or 0
		can_shenzhu = consume.count ~= nil and has_count >= consume_count
		local consume_data = ItemData.InitItemDataByCfg(consume)
		consume_data.index = 1
		table.insert(self.consume_data_list, consume_data)
	end

	-- 神铸增加概率消耗
	local add_rate = next_cfg.addRate
	if add_rate then
		local consume = add_rate.consumes and add_rate.consumes[1]
		if consume then
			local consume_data = ItemData.InitItemDataByCfg(consume)
			consume_data.index = 2
			consume_data.value = add_rate.value
			table.insert(self.consume_data_list, consume_data)
		end
	end

	-- 神铸失败不掉级消耗
	local insure_cost = next_cfg.insureCost
	if insure_cost then
		local consume = insure_cost[1]
		if consume then
			local consume_data = ItemData.InitItemDataByCfg(consume)
			consume_data.index = 3
			table.insert(self.consume_data_list, consume_data)
		end
	end
	self.consume_list:SetDataList(self.consume_data_list)
	self.consume_list:SetCenter()

	local consume_list_items = self.consume_list:GetItems()
	for i, item in ipairs(consume_list_items) do
		self:OnConsume(item)
	end

	-- 是否可以神铸
	local god_quality_lv = next_cfg.godQualityLv
	local cur_shenge_lv = ReXueGodEquipData.Instance:GetShengeLevel(shenzhu_slot)
	-- 神格等级满足
	local shenge_lv_meet = god_quality_lv ~= nil and cur_shenge_lv >= god_quality_lv
	self.can_shenzhu = can_shenzhu and shenge_lv_meet
	self.node_t_list["layout_consume"].node:setVisible(shenge_lv_meet)
	self.node_t_list["lbl_tip"].node:setVisible(not shenge_lv_meet)

	local text = ""
	if not self.can_shenzhu then
		if god_quality_lv ~= nil and cur_shenge_lv < god_quality_lv then
			local shenzhu_slot = self.select_data and self.select_data.shenzhu_slot or 0
			local shenzhu_lv_max = ReXueGodEquipData.Instance:GetShenzhuLevelMax(shenzhu_slot)
			local max_shenzhu_lv = shenzhu_lv_max[cur_shenge_lv + 1] or 0
			text = max_shenzhu_lv == 0 and "" or string.format(Language.ReXueGodEquip.ShenzhuText3, cur_shenge_lv + 1, max_shenzhu_lv)
		elseif god_quality_lv == nil then
			-- "已满级"
			text = Language.Common.MaxLevel
		end
	end
	self.node_t_list["lbl_tip"].node:setString(text)
	self.node_t_list["btn_1"].node:setVisible(god_quality_lv ~= nil)

	-- 下一级神铸属性
	local next_attr = next_cfg.attrs or {}
	local rich_param = {type_str_color = "9c9181", value_str_color = "1ac915"}
	local next_attr_str = RoleData.Instance.FormatAttrContent(next_attr, rich_param)
	next_attr_str = next_attr_str == "" and Language.Common.No or next_attr_str
	local rich = self.node_t_list["rich_next_attr"].node
	RichTextUtil.ParseRichText(rich, next_attr_str, 20, Str2C3b("9c9181"))
	rich:refreshView()

	-- 当前神铸属性
	local cur_attr = cur_cfg.attrs or {}
	local rich_param = {type_str_color = "9c9181", value_str_color = "cdced0"}
	local cur_attr_str = RoleData.Instance.FormatAttrContent(cur_attr, rich_param)
	cur_attr_str = cur_attr_str == "" and Language.Common.No or cur_attr_str
	local rich = self.node_t_list["rich_cur_attr"].node
	RichTextUtil.ParseRichText(rich, cur_attr_str, 20, Str2C3b("9c9181"))
	rich:refreshView()

	-- 当前等级
	local bool = cur_shenzhu_level ~= nil and cur_shenzhu_level > 0
	self.node_t_list["img_not_shenzhu"].node:setVisible(not bool)
	self.node_t_list["layout_cur_shenzhu"].node:setVisible(bool)
	if bool then
		self.shenzhu_lv_1:SetNumber(cur_shenzhu_level)
	end

	-- 下一级
	local bool_2 = next(next_cfg) ~= nil
	self.node_t_list["img_max_shenzhu"].node:setVisible(not bool_2)
	self.node_t_list["layout_next_shenzhu"].node:setVisible(bool_2)
	if bool_2 then
		self.shenzhu_lv_2:SetNumber(next_shenzhu_level)
	end

	self:FlushShengeBtnRemind()
end

function RexueShenzhuView:FlushEffectList()
	local shenzhu_slot = self.select_data.shenzhu_slot or 0
	local shenzhu_level = ReXueGodEquipData.Instance:GetShenzhuLevel(shenzhu_slot)
	local count = shenzhu_level == 0 and 0 or math.floor((shenzhu_level - 1) / 20) + 1
	for i = 1, 5 do
		local effect_id = 8 + i
		local effect = self.effect_list[i]
		local grey = count < i
		
		local frame_interval = nil -- 每帧间隔时间
		if nil == effect then
			local parent = self.node_t_list["layout_shenzhu"].node
			local ph = self.ph_list["ph_eff_" .. i] or {x = 0, y = 0, w = 10, h = 10}
			local zorder = nil
			local loops = nil -- 播放数量
			
			effect = RenderUnit.CreateEffect(effect_id, parent, zorder, frame_interval, loops, ph.x + 1, ph.y + 8)
			self.effect_list[i] = effect
		else
			local path, name = ResPath.GetEffectUiAnimPath(effect_id)
			effect:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, frame_interval or FrameTime.Effect, false)
		end
		
		XUI.MakeGrey(effect, grey)
	end
end

-- 播放神铸结果特效
function RexueShenzhuView:PlayResultEffect(effect_id)
	local parent = self.node_t_list["layout_shenzhu"].node
	local ph = self.ph_list["ph_result_eff"] or {x = 0, y = 0, w = 10, h = 10}
	local zorder = nil -- 默认为100
	local remove_on_finished = true -- true为播放完后释放节点
	local on_complete = nil -- 播放结束回调
	local frame_interval = nil -- 每帧间隔时间 默认为FrameTime.Effect

	RenderUnit.PlayEffectOnce(effect_id, parent, zorder, ph.x, ph.y, remove_on_finished, on_complete, frame_interval)
end

-- 刷新tabbar红点提示
function RexueShenzhuView:FlushBtnRemind()
	local remind_num = RemindManager.Instance:GetRemindGroup(ViewDef.MainGodEquipView.RexueShenzhu.remind_group_name)
	if remind_num > 0 then
		local shenzhu_slot_list = ReXueGodEquipData.Instance:GetReXueShenzhuSlotList()
		local equip_list = EquipData.Instance:GetEquipData() or {}
		for _type, slot_list in ipairs(shenzhu_slot_list) do
			local bool = false

			-- 是否开放
			if ReXueGodEquipData.ReXueShenzhuIsOpen(_type) then
				for equip_slot, shenzhu_slot in pairs(slot_list) do
					-- 是否穿戴装备
					if equip_list[equip_slot] then
						-- 是否可神格
						local next_shenge_cfg, next_shenge_lv = ReXueGodEquipData.Instance:GetShengeLevelCfg(shenzhu_slot, nil, true)
						if next(next_shenge_cfg) then
							local consumes = next_shenge_cfg.consumes or {}
							bool = BagData.CheckConsumesCount(consumes)
							if bool then break end
						end

						-- 是否可神铸
						local next_shenzhu_cfg = ReXueGodEquipData.Instance:GetShenzhuLevelCfg(shenzhu_slot, nil, true)
						local god_quality_lv = next_shenzhu_cfg.godQualityLv or 99
						if next(next_shenzhu_cfg) and next_shenge_lv > god_quality_lv then
							local consumes = next_shenzhu_cfg.consumes or {}
							bool = BagData.CheckConsumesCount(consumes)
							if bool then break end
						end
					end
				end
			end

			self.tabbar:SetRemindByIndex(_type, bool)
		end
	end
end

----------end----------

-- "装备种类"按钮点击回调
function RexueShenzhuView:TabbarCallBack(_type)
	ReXueGodEquipData.Instance:SetShenzhuType(_type)

	local path = ResPath.GetReXuePath("shenzhu_btn_1" .. _type)
	self.node_t_list["btn_suit"].node:loadTextures(path)

	local equip_data_list = ReXueGodEquipData.Instance:GetReXueShenzhuEquipList(_type)
	self.equip_list:SetDataList(equip_data_list)
	self.equip_list:JumpToTop()

	self.equip_list:SelectItemByIndex(1)
end

-- 选择装备回调
function RexueShenzhuView:OnEquipCallBack(item)
	self.select_data = item:GetData()
	ReXueGodEquipData.Instance:SetShenzhuSelectData(self.select_data)

	self.equip:SetData(self.select_data.equip)

	local consume_list_items = self.consume_list:GetItems()
	for i, item in ipairs(consume_list_items) do
		item.hook = false
	end

	self:FlushEffectList()
	self:FlushSelectShow()
end

-- 神铸升级结果
function RexueShenzhuView:OnShenzhuResult(shenzhu_slot, shenzhu_lv, result)
	if not self:IsOpen() then return end

	self:Flush()

	if result then
		self:PlayResultEffect(15)
	else
		self:PlayResultEffect(16)
	end
end

-- 神格升级结果
function RexueShenzhuView:OnShengeResult(shenzhu_slot, shenge_lv)
	if not self:IsOpen() then return end
	
	self:Flush()
end

function RexueShenzhuView:OnBagItemChange(event)
	if not self:IsOpen() then return end

	local shenzhu_consume_id = ReXueGodEquipData.Instance:GetShenzhuLevelConsumeId()
	local bool = false
	for i, v in pairs(event.GetChangeDataList()) do
		if v.change_type == ITEM_CHANGE_TYPE.LIST then
			bool = true
			break
		else
			local item_id = v.data and v.data.item_id
			if shenzhu_consume_id[item_id] then
				bool = true
				break
			end
		end
	end
	
	if bool then
		self:Flush()
	end
end

-- "?"号按钮点击回调
function RexueShenzhuView:OpenShowTips()
	local _type = ReXueGodEquipData.Instance:GetShenzhuType() or 0
	local content = Language.DescTip.RexueShenzhuContent and Language.DescTip.RexueShenzhuContent[_type] or ""
	local title = Language.DescTip.RexueShenzhuTitle and Language.DescTip.RexueShenzhuTitle[_type] or ""
	DescTip.Instance:SetContent(content, title)
end

-- "神格"按钮点击回调
function RexueShenzhuView:OnShenge()
	ViewManager.Instance:OpenViewByDef(ViewDef.RexueShenge)
end

-- "神铸"按钮点击回调
function RexueShenzhuView:OnBtn()
	local shenzhu_slot = self.select_data.shenzhu_slot or 0
	if self.can_shenzhu then
		local index_1 = 0
		local index_2 = 0
		local consume_list_items = self.consume_list:GetItems()
		for i, item in ipairs(consume_list_items) do
			local data = item:GetData()
			if data.index == 2 then -- 增加概率
				index_1 = item.hook and 1 or 0
			elseif data.index == 3 then -- 失败不掉级
				index_2 = item.hook and 1 or 0
			end
		end
		ReXueGodEquipCtrl.ReqRexueShenzhu(shenzhu_slot, index_1, index_2)
	else
		local next_cfg, next_shenzhu_level = ReXueGodEquipData.Instance:GetShenzhuLevelCfg(shenzhu_slot, nil, true)
		local str = ""
		if next_cfg then
			local god_quality_lv = next_cfg.godQualityLv or 99
			local cur_shenge_lv = ReXueGodEquipData.Instance:GetShengeLevel(shenzhu_slot)
			if cur_shenge_lv >= god_quality_lv then
				str = Language.Common.StuffNotEnought
			else
				str = string.format(Language.ReXueGodEquip.ShenzhuText2, god_quality_lv)
			end
		else
			str = Language.Common.MaxLevel
		end
		SystemHint.Instance:FloatingTopRightText(str)
	end
end

function RexueShenzhuView:OnSuit()
	local _type = ReXueGodEquipData.Instance:GetShenzhuType() or 0
	EquipmentCtrl.Instance:OpenSuitAttr(_type + 5)
end

-- 消耗"打勾"点击回调 (只能在 self.consume_list:SetDataList 后调用)
function RexueShenzhuView:OnConsume(item)
	local data = item:GetData()
	if data.index == 2 then -- 增加成功概率
		local cur_per = self.per:GetData()
		local add_per = math.floor(item.hook and data.value / 100 or - (data.value / 100))
		add_per = self.is_new_per and math.max(add_per, 0) or add_per -- self.is_new_per = ture时,概率只加不减
		local new_per = cur_per + add_per
		self.per:SetNumber(new_per)

		self.is_new_per = false
	elseif data.index == 3 then -- 失败不掉级
		self.node_t_list["img_1"].node:setVisible(item.hook)
	end
end

--------------------

----------------------------------------
-- EquipItem
----------------------------------------
RexueShenzhuView.EquipItem = BaseClass(BaseRender)
local EquipItem = RexueShenzhuView.EquipItem
function EquipItem:__init()
	self.effect_list = {}
end

function EquipItem:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end

	if self.shenzhu_lv then
		self.shenzhu_lv:DeleteMe()
		self.shenzhu_lv = nil
	end


	self.effect_list = {}
end

function EquipItem:CreateChild()
	BaseRender.CreateChild(self)

	local parent = self.view
	local ph = self.ph_list["ph_cell"] or {x = 0, y = 0, w = 10, h = 10}
	local cell = BaseCell.New()
	cell:SetPosition(ph.x, ph.y)
	parent:addChild(cell:GetView(), 2)
	self.cell = cell
end

function EquipItem:OnFlush()
	self:FlushEffect()

	local equip = self.data and self.data.equip
	if nil == equip then
		self.cell:SetData()

		self.node_tree["lbl_equip_name"].node:setString("")

		if self.view.UpdateReimd then
			self.view:UpdateReimd(false)
		end

	else
		local item_data = {item_id = equip.item_id or 0, is_bind = equip.is_bind, num = equip.num}
		self.cell:SetData(item_data)

		local shenge_level = ReXueGodEquipData.Instance:GetShengeLevel(self.data.shenzhu_slot)
		local suffix = ""
		if shenge_level and shenge_level > 0 then
			suffix = Language.Tip.ShenzhuName[shenge_level]
		end

		local item_id = equip.item_id
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		local color = Str2C3b(string.sub(string.format("%06x", item_cfg.color), 1, 6))
		self.node_tree["lbl_equip_name"].node:setString(item_cfg.name .. suffix)
		self.node_tree["lbl_equip_name"].node:setColor(color)
		self:FlushReimd()
	end

	self:FlushShengeLv()
end

function EquipItem:FlushShengeLv()
	local shenzhulevel = ReXueGodEquipData.Instance:GetShenzhuLevel(self.data.shenzhu_slot)
	if self.data.equip and shenzhulevel > 0 then
		if nil == self.shenzhu_lv then
			local parent = self.view
			local ph = self.ph_list["ph_shenzhu_lv"]
			local path = ResPath.GetCommon("num_15_")
			local number_bar = NumberBar.New()
			number_bar:Create(ph.x, ph.y, ph.w, ph.h, path)
			number_bar:SetSpace(-5)
			number_bar:SetGravity(NumberBarGravity.Right)
			parent:addChild(number_bar:GetView(), 99)
			self.shenzhu_lv = number_bar
		end

		self.shenzhu_lv:GetView():setVisible(true)
		self.node_tree["img_lv"].node:setVisible(true)
		self.shenzhu_lv:SetNumber(shenzhulevel)
	else
		self.node_tree["img_lv"].node:setVisible(false)
		if self.shenzhu_lv then
			self.shenzhu_lv:GetView():setVisible(false)
		end
	end
end

function EquipItem:FlushEffect()
	local shenzhu_slot = self.data.shenzhu_slot or 0
	local shenzhu_level = ReXueGodEquipData.Instance:GetShenzhuLevel(shenzhu_slot)
	local count = shenzhu_level == 0 and 0 or math.floor((shenzhu_level - 1) / 20) + 1
	for i = 1, 5 do
		local effect_id = 8 + i
		local effect = self.effect_list[i]
		local grey = count < i
		
		local frame_interval = nil -- 每帧间隔时间
		if nil == effect then
			local parent = self.view
			local ph = self.ph_list["ph_eff"] or {x = 0, y = 0, w = 10, h = 10}
			local zorder = 1
			local loops = nil -- 播放数量
			
			local x = ph.x + i * (ph.w / 5)
			effect = RenderUnit.CreateEffect(effect_id, parent, zorder, frame_interval, loops, x - 25, ph.y + 15)
			effect:setScale(0.8)
			self.effect_list[i] = effect
		else
			local path, name = ResPath.GetEffectUiAnimPath(effect_id)
			effect:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, frame_interval or FrameTime.Effect, false)
		end
		
		XUI.MakeGrey(effect, grey)
	end
end

function EquipItem:FlushReimd()
	local bool = false
	local shenzhu_slot = self.data.shenzhu_slot or 0

	-- 是否可神格
	local next_shenge_cfg, next_shenge_lv = ReXueGodEquipData.Instance:GetShengeLevelCfg(shenzhu_slot, nil, true)
	if next(next_shenge_cfg) then
		local consumes = next_shenge_cfg.consumes or {}
		bool = BagData.CheckConsumesCount(consumes)
	end

	if not bool then
		-- 是否可神铸
		local next_shenzhu_cfg = ReXueGodEquipData.Instance:GetShenzhuLevelCfg(shenzhu_slot, nil, true)
		local god_quality_lv = next_shenzhu_cfg.godQualityLv or 99
		if next(next_shenzhu_cfg) and next_shenge_lv > god_quality_lv then
			local consumes = next_shenzhu_cfg.consumes or {}
			bool = BagData.CheckConsumesCount(consumes)
		end
	end

	if bool and not self.view.UpdateReimd then
		local size = self.view:getContentSize()
		local x = size.width - 19
		local y = size.height - 19
		local z_order = 1000
		XUI.AddRemingTip(self.view, nil, nil, x, y, z_order)
	end

	if self.view.UpdateReimd then
		self.view:UpdateReimd(bool)
	end
end

----------------------------------------
-- 神铸消耗渲染
----------------------------------------
RexueShenzhuView.ConsumeRender = BaseClass(BaseRender)
local ConsumeRender = RexueShenzhuView.ConsumeRender
function ConsumeRender:__init()
	self.cell = nil
	self.hook = false
end

function ConsumeRender:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function ConsumeRender:CreateChild()
	BaseRender.CreateChild(self)

	local parent = self.view
	local ph = self.ph_list["ph_cell"] or {x = 0, y = 0, w = 10, h = 10}
	local cell = BaseCell.New()
	-- cell:SetIsShowTips(false)
	cell:SetPosition(ph.x, ph.y)
	parent:addChild(cell:GetView(), 0)
	self.cell = cell

	self.node_tree["layout_select"].node:setVisible(false)
	self.node_tree["layout_select"]["img_hook"].node:setVisible(false)
	XUI.AddClickEventListener(self.node_tree["layout_select"].node, BindTool.Bind(self.OnHook, self))
end

function ConsumeRender:OnFlush()
	if nil == self.data then return end
	self.cell:SetData(self.data)

	local has_count = BagData.Instance:GetItemNumInBagById(self.data.item_id)
	local consume_count = self.data.num or 0
	self.can_hook = self.data.num ~= nil and has_count >= consume_count
	local color = self.can_hook and COLOR3B.GREEN or COLOR3B.RED
	local text = has_count .. "/" .. consume_count
	self.cell:SetData(self.data)
	self.cell:SetRightBottomText(text, color)

	self.hook = self.hook and self.can_hook -- 校准

	if self.data.index ~= 1 then
		self.node_tree["layout_select"].node:setVisible(true)
	else
		self.node_tree["layout_select"].node:setVisible(false)
	end

	self:FlushSelect()
end

function ConsumeRender:FlushSelect()
	self.node_tree["layout_select"]["img_hook"].node:setVisible(self.hook)
	self.cell:MakeGray(not self.hook and self.data.index ~= 1)
end

function ConsumeRender:OnHook()
	if self.can_hook then
		self.hook = not self.hook
		self:FlushSelect()

		self.click_callback(self)
	else
		-- 例: "所需材料不足，无法勾选"
		local str = Language.ReXueGodEquip.ShenzhuText1
		SystemHint.Instance:FloatingTopRightText(str)
	end
end

function ConsumeRender:CreateSelectEffect()
	return
end

-- 接口重写 屏蔽渲染点击触控
function ConsumeRender:AddClickEventListener(callback)
	self.click_callback = callback
end

return RexueShenzhuView