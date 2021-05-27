EquipmentGodEquipPage = EquipmentGodEquipPage or BaseClass()


function EquipmentGodEquipPage:__init()
	self.view = nil
end	

function EquipmentGodEquipPage:__delete()
	self:RemoveEvent()
	if self.tabbar_equip then
		self.tabbar_equip:DeleteMe()
		self.tabbar_equip = nil 
	end

	if self.shengzhuang_list then
		self.shengzhuang_list:DeleteMe()
		self.shengzhuang_list = nil 
	end

	if self.priview_cell_1 then
		self.priview_cell_1:DeleteMe()
		self.priview_cell_1 = nil 
	end

	if self.target_cell_1 then
		self.target_cell_1:DeleteMe()
		self.target_cell_1 = nil 
	end

	if self.soures_cell_1 then
		self.soures_cell_1:DeleteMe()
		self.soures_cell_1 = nil 
	end

	if self.tabbar_1 then
		self.tabbar_1:DeleteMe()
		self.tabbar_1 = nil 
	end

	if self.tree_item_list then
		self.tree_item_list:DeleteMe()
		self.tree_item_list = nil 
	end

	if self.grid_list then
		self.grid_list:DeleteMe()
		self.grid_list = nil 
	end

	if self.play_effect ~= nil then
		self.play_effect:setStop()
		self.play_effect = nil 
	end
	if self.number_circle then
		self.number_circle:DeleteMe()
		self.number_circle = nil
	end
	if self.tabbar_t then
		self.tabbar_t:DeleteMe()
		self.tabbar_t = nil 
	end
	-- if self.itemdata_change_callback then
	-- 	ItemData.Instance:UnNotifyDataChangeCallBack(self.itemdata_change_callback)
	-- 	self.itemdata_change_callback = nil 
	-- end
	if self.roledata_change_callback then
		RoleData.Instance:UnNotifyAttrChange(self.roledata_change_callback)
		self.roledata_change_callback = nil 
	end

	if self.compound_result_evt then
		GlobalEventSystem:UnBind(self.compound_result_evt)
		self.compound_result_evt = nil
	end
	
	self.view = nil
end	

--初始化页面接口
function EquipmentGodEquipPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self.equip_index = 1
	self.tabbar_type = 1
	self.select_equip_index = 0
	self:InitTabbar()
	self:InitTabbarType()
	self:CreateCell()
	self:CreateList()
	self:InitEvent()

	--圣装合成
	-- self.btn_index = 1
	-- self.cur_tree_index = 1
	-- self.select_index =1
	-- self.view = view
	-- self.child_data = {}
	-- self.tree_data = {}
	-- self:InitTabber()
	-- -- self.time_event = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind1(self.BoolShowBtn, self))
	-- self:CreateTreeList()
	-- self:CreateChildList()
	-- self:InitEvent()
end	

function EquipmentGodEquipPage:InitTabbar()
	if self.tabbar_equip == nil then
		self.tabbar_equip = Tabbar.New()
		self.tabbar_equip:CreateWithNameList(self.view.node_t_list.layout_shengzhuang.node, 9, 559,
			BindTool.Bind1(self.SelectEquipCallback, self), 
			Language.Equipment.TabGroup_1, false, ResPath.GetCommon("toggle_104_normal"), nil, Str2C3b("fff999"), Str2C3b("bdaa93"))
		self.tabbar_equip:SetSpaceInterval(5)
	end
end

function EquipmentGodEquipPage:InitTabbarType()
	if self.tabbar_t == nil then
		self.tabbar_t = Tabbar.New()
		self.tabbar_t:CreateWithNameList(self.view.node_t_list.layout_shengzhuang.node, 742, 559,
			BindTool.Bind1(self.SelectTabbarTypeCallback, self), 
			{}, false, ResPath.GetCommon("toggle_104_normal"), nil, Str2C3b("fff999"), Str2C3b("bdaa93"))
		self.tabbar_t:SetSpaceInterval(5)
	end
end

function EquipmentGodEquipPage:SelectTabbarTypeCallback(index)
	self.tabbar_type = index
	self:Flushlayout()
	if self.tabbar_type == 1 then
		self:FlushData()
	else
		self:FlushAllEquipmentView()
	end
end

function EquipmentGodEquipPage:Flushlayout()
	-- self.view.node_t_list.layout_god.node:setVisible(self.tabbar_type == 1)
	self.view.node_t_list.layout_up_compound.node:setVisible(false)
end

function EquipmentGodEquipPage:SelectEquipCallback(index)
	self.equip_index = index
	self:FlushData()
end

function EquipmentGodEquipPage:FlushRedPoint()
	if self.tabbar_t == nil then
		return 
	end
	self.tabbar_t:SetRemindByIndex(2, RemindManager.Instance:GetRemind(RemindName.EquipmentCompound) > 0)
end


function EquipmentGodEquipPage:CreateCell()
	if self.priview_cell_1 == nil then
		local ph = self.view.ph_list.ph_gold_cell_1
		self.priview_cell_1 = BaseCell.New()
		self.priview_cell_1:SetPosition(ph.x+8, ph.y+10)
		self.priview_cell_1:GetView():setAnchorPoint(0, 0)
		self.priview_cell_1:SetCellBg(ResPath.GetEquipment("cell_1_bg"))
		self.view.node_t_list.layout_god.layout_godequip_uplevel.node:addChild(self.priview_cell_1:GetView(), 100)
	end

	if self.soures_cell_1 == nil then
		local ph = self.view.ph_list.ph_gold_cell_2
		self.soures_cell_1 = BaseCell.New()
		self.soures_cell_1:SetPosition(ph.x, ph.y)
		self.soures_cell_1:GetView():setAnchorPoint(0, 0)
		self.view.node_t_list.layout_god.layout_godequip_uplevel.node:addChild(self.soures_cell_1:GetView(), 100)
	end

	if self.target_cell_1 == nil then
		local ph = self.view.ph_list.ph_gold_cell_3
		self.target_cell_1 = TargetCell.New()
		self.target_cell_1:SetPosition(ph.x, ph.y)
		self.target_cell_1:GetView():setAnchorPoint(0, 0)
		self.view.node_t_list.layout_god.layout_godequip_uplevel.node:addChild(self.target_cell_1:GetView(), 100)
	end
end

function EquipmentGodEquipPage:CreateList()
	if self.shengzhuang_list == nil then
		local ph = self.view.ph_list.ph_godequip_list
		self.shengzhuang_list = ListView.New()
		self.shengzhuang_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ShengZhuangItem, nil, nil, self.view.ph_list.ph_godequip_item)
		self.view.node_t_list.layout_god.node:addChild(self.shengzhuang_list:GetView(), 999)
		self.shengzhuang_list:SetMargin(5)
		self.shengzhuang_list:SetItemsInterval(5)
		self.shengzhuang_list:SelectIndex(1)
		self.shengzhuang_list:GetView():setAnchorPoint(0, 0)
		self.shengzhuang_list:SetJumpDirection(ListView.Top)
		self.shengzhuang_list:SetSelectCallBack(BindTool.Bind1(self.SelectShengZhuangCallBack, self))
	end
end

function EquipmentGodEquipPage:SelectShengZhuangCallBack(item, index)
	if item == nil or item:GetData() == nil then return end
	self.select_equip_data = item:GetData()
	self.select_equip_index = item:GetIndex()
	self:FlushListData(self.select_equip_data)
end

function EquipmentGodEquipPage:FlushData()
	if self.equip_index == 1 then
		self.equip_data = EquipmentData.Instance:GetShenShangGodEquip()
		self.shengzhuang_list:SetDataList(self.equip_data)
		self:FlushRigthtView(self.equip_data)
	elseif self.equip_index == 2 then
		self.equip_data = EquipmentData.Instance:GetBagEquipData()
		self.shengzhuang_list:SetDataList(self.equip_data)
		self:FlushRigthtView(self.equip_data)
	elseif self.equip_index == 3 then
		self.equip_data = EquipmentData.Instance:GetHeroEquipData()
		self.shengzhuang_list:SetDataList(self.equip_data)
		self:FlushRigthtView(self.equip_data)
	end
end

function EquipmentGodEquipPage:InitEvent()
	self.view.node_t_list.layout_god.layout_godequip_uplevel.btn_clear_cell.node:setLocalZOrder(998)
	self.view.node_t_list.layout_god.layout_godequip_uplevel.btn_clear_cell.node:addClickEventListener(BindTool.Bind(self.ClearEquipCell, self))
	self.view.node_t_list.layout_god.layout_godequip_uplevel.btn_godequip_upLevel.node:addClickEventListener(BindTool.Bind(self.UpGodEquipLevel, self))
	self.view.node_t_list.layout_god.layout_godequip_uplevel.btn_desc_tip.node:addClickEventListener(BindTool.Bind(self.OpenGodEuipTip, self))
	self.itemdata_change_callback = BindTool.Bind1(self.ItemDataChangeCallback,self)			--监听人物属性数据变化
	self.equipmentdata_change_callback = BindTool.Bind1(self.EquipmentDataChangeCallback,self)	--监听装备数据变化
	ItemData.Instance:NotifyDataChangeCallBack(self.itemdata_change_callback)
	EquipData.Instance:NotifyDataChangeCallBack(self.equipmentdata_change_callback)
	self.hero_equip_change_evt = GlobalEventSystem:Bind(HeroDataEvent.HERO_EQUIP_CHANGE,BindTool.Bind1(self.OnHeroGodEquipDataChange, self))

	self.view.node_t_list["btn_xoumpond_desc"].node:addClickEventListener(BindTool.Bind(self.OpenShouMing, self))
	-- self.itemdata_change_callback = BindTool.Bind1(self.ItemDataChangeCallback, self)           -- 监听物品数据变化
	-- ItemData.Instance:NotifyDataChangeCallBack(self.itemdata_change_callback)

	-- self.roledata_change_callback = BindTool.Bind1(self.RoleDataChangeCallback, self)           -- 监听物品数据变化
	-- RoleData.Instance:NotifyAttrChange(self.roledata_change_callback)
	-- local ph = self.view.ph_list.ph_effect
	-- self.img_down = XUI.CreateImageView(ph.x+10, ph.y, ResPath.GetCommon("btn_down"),true)
	-- self.view.node_t_list["layout_up_compound"].node:addChild(self.img_down, 200)
	-- CommonAction.ShowJumpAction(self.img_down)
	-- self.img_down:setScale(0.8)
	-- XUI.AddClickEventListener(self.img_down, BindTool.Bind(self.ChangeToIndex, self), true)
	-- self.compound_result_evt = GlobalEventSystem:Bind(EquipmentEvent.EQUIP_COMPOUND_RESULT_BACK, BindTool.Bind(self.OnCompoundResultBack, self))
	-- local ph = self.view.ph_list.ph_number
	-- self.number_circle = self:CreateNumBar(ph.x-10, ph.y-25, 48, 62)
	-- self.view.node_t_list.comment5.node:addChild(self.number_circle:GetView(), 101)
	-- self.number_circle:SetGravity(NumberBarGravity.Center)
	-- self.number_circle:SetNumber(0)
	-- self.view.node_t_list.comment5.node:setLocalZOrder(998)
end

function EquipmentGodEquipPage:RemoveEvent()
	if self.itemdata_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.itemdata_change_callback)
		self.itemdata_change_callback = nil 
	end
	if self.equipmentdata_change_callback then
		EquipData.Instance:UnNotifyDataChangeCallBack(self.equipmentdata_change_callback)
		self.equipmentdata_change_callback = nil 
	end

	if self.hero_equip_change_evt then
		GlobalEventSystem:UnBind(self.hero_equip_change_evt)
		self.hero_equip_change_evt = nil
	end
end

function EquipmentGodEquipPage:OnHeroGodEquipDataChange()
	self.view:Flush(TabIndex.equipment_god_equip)
end

function EquipmentGodEquipPage:ItemDataChangeCallback()

	if self.tabbar_type == 1 then
		self.view:Flush(TabIndex.equipment_god_equip)
	else
		self:FlushCoumpondData()
	end
end

function EquipmentGodEquipPage:EquipmentDataChangeCallback()
	self.view:Flush(TabIndex.equipment_god_equip)
end

function EquipmentGodEquipPage:UpdateData(data)
	self:Flushlayout()
	if self.tabbar_type == 1 then
		local data_2 = EquipmentData.Instance:GetHeroEquipData()
		local data_1 = EquipmentData.Instance:GetShenShangGodEquip()
		if data_1[1] == nil then 
			local data = EquipmentData.Instance:GetBagEquipData()
			if data[1] ~= nil then
				self.tabbar_equip:SelectIndex(2)
			else
				self.tabbar_equip:SelectIndex(1)
			end
		else
			self.tabbar_equip:SelectIndex(1)
		end
		self:FlushData()
		local caozuo_type, caozuo_result = EquipmentData.Instance:GetCaoZuoTypeAndResult()
		if caozuo_type == 1 and caozuo_result == 1 then
			self:ClearEquipCell()
		end
	else
		self:FlushAllEquipmentView()
	end
end

function EquipmentGodEquipPage:FlushAllEquipmentView()
	-- self:SetVisibleToggle()
	-- self:FlushTreeList()
	-- self.tree_item_list:SelectIndex(1)
	-- self:FlushChildList()
	-- self:FlushRemind()
	-- --self:ChangePageCallBack()
	-- self:BoolShowData()
end

function EquipmentGodEquipPage:FlushRigthtView(data)
	self.select_data = data[self.select_equip_index] 
	if self.select_equip_data ~= nil  and data[self.select_equip_index] ~= nil then
		if self.select_data ~= nil then
			self:FlushListData(self.select_data)
		else
			if self.soures_cell_1:GetData() ~= nil then
				self.soures_cell_1:ClearData()
			end
			if self.target_cell_1:GetData() ~= nil then
				self.target_cell_1:ClearData()
			end
			if self.priview_cell_1:GetData() ~= nil then
				self.priview_cell_1:ClearData()
			end
			self.view.node_t_list.layout_god.layout_godequip_uplevel.btn_clear_cell.node:setVisible(false)
		end
	else
		if self.soures_cell_1:GetData() ~= nil then
			self.soures_cell_1:ClearData()
		end
		if self.target_cell_1:GetData() ~= nil then
			self.target_cell_1:ClearData()
		end
		if self.priview_cell_1:GetData() ~= nil then
			self.priview_cell_1:ClearData()
		end
		self.view.node_t_list.layout_god.layout_godequip_uplevel.btn_clear_cell.node:setVisible(false)
	end
end

function EquipmentGodEquipPage:FlushListData(data)
	self.soures_cell_1:SetData(data)
	local cfg = EquipmentData.GetConfigDataById(data.item_id) 
	if cfg ~= nil then
		local consume_data  = {item_id = cfg.consumes[1].id, num = 1, is_bind = 0}
		local had_item = ItemData.Instance:GetItemNumInBagById(cfg.consumes[1].id) 
		local txt = ""
		local color = COLOR3B.WHITE
		if had_item >= cfg.consumes[1].count then
			color = COLOR3B.WHITE
			txt = string.format(Language.Equipment.Text_desc, had_item, cfg.consumes[1].count or 0)
		else
			color = COLOR3B.RED
			txt = string.format(Language.Equipment.Text_desc, had_item, cfg.consumes[1].count or 0)
		end
		self.target_cell_1:SetData(consume_data)
		self.target_cell_1:SetRightBottomText(txt, color)
		local priview_data = {item_id = cfg.newEquipId, num = 1, is_bind = 0, strengthen_level = data.strengthen_level,
		infuse_level = data.infuse_level, property_1 = data.property_1, property_2 = data.property_2, property_3 = data.property_3 }
		self.priview_cell_1:SetData(priview_data)
	end
	if self.target_cell_1:GetData() == nil then
		self.view.node_t_list.layout_god.layout_godequip_uplevel.btn_clear_cell.node:setVisible(false)
	else
		self.view.node_t_list.layout_god.layout_godequip_uplevel.btn_clear_cell.node:setVisible(true)
	end
end

function EquipmentGodEquipPage:OpenGodEuipTip()
	DescTip.Instance:SetContent(Language.Equipment.ShengZhuangContent, Language.Equipment.ShengZhuangTitle)
end

function EquipmentGodEquipPage:ClearEquipCell()
	if self.soures_cell_1:GetData() ~= nil then
		self.soures_cell_1:ClearData()
	end
	if self.target_cell_1:GetData() ~= nil then
		self.target_cell_1:ClearData()
	end
	if self.priview_cell_1:GetData() ~= nil then
		self.priview_cell_1:ClearData()
	end
	self.view.node_t_list.layout_god.layout_godequip_uplevel.btn_clear_cell.node:setVisible(false)
end

function EquipmentGodEquipPage:UpGodEquipLevel()
	local data = self.soures_cell_1:GetData()
	if data ~= nil then
		EquipmentCtrl.Instance:SendUpLevelEquip(data.series)
	else
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Equipment.Input_Desc_1)
	end
	AudioManager.Instance:PlayClickBtnSoundEffect()
end


----------------=================合成==============--------------


function EquipmentGodEquipPage:InitTabber()
	self.tabbar_1 = ScrollTabbar.New()
	self.tabbar_1.space_interval_V = 10
	self.tabbar_1:SetSpaceInterval(6)
	self.tabbar_1:CreateWithNameList(self.view.node_t_list.scroll_tabbar.node, 7, -20,
		BindTool.Bind1(self.SelectTabCallback, self), Language.Equipment.TabGroup_9, 
		true, ResPath.GetCommon("btn_106_normal"))
end

function EquipmentGodEquipPage:SelectTabCallback(index)
	self.btn_index = index
	self:FlushTreeList()
	self.tree_item_list:SelectIndex(1)
	self:FlushChildList()
	self.grid_list:JumpToTop()
	self:CanShowImg()
	--self.grid_list:ChangeToPage(1)
	--self:ChangePageCallBack()
end

function EquipmentGodEquipPage:CreateTreeList()
	local ph = self.view.ph_list.ph_tree_list
	self.tree_item_list = ListView.New()
	self.tree_item_list:Create(ph.x, ph.y, ph.w, ph.h, nil, TreeListItem, nil, nil, self.view.ph_list.ph_tree_item)
	self.view.node_t_list["layout_up_compound"].node:addChild(self.tree_item_list:GetView(), 888)
	self.tree_item_list:SetMargin(10)
	self.tree_item_list:SetItemsInterval(10)
	self.tree_item_list:SelectIndex(1)
	self.tree_item_list:GetView():setAnchorPoint(0, 0)
	self.tree_item_list:SetJumpDirection(ListView.Top)
	self.tree_item_list:SetSelectCallBack(BindTool.Bind1(self.SelectTreeListCallBack, self))
end

function EquipmentGodEquipPage:SelectTreeListCallBack(item, index)
	if item == nil or item:GetData() == nil then return end
	self.select_index = index
	self.select_data = item:GetData()
	self.cur_tree_index = self.select_data.current_item_index
	self:FlushTreeList()
	self:FlushChildList()
	self.grid_list:JumpToTop()
	self:CanShowImg()
	--self.grid_list:ChangeToPage(1)
	--self:ChangePageCallBack()
	self:BoolShowData()
end

function EquipmentGodEquipPage:CreateChildList()
	if self.grid_list == nil then
		local ph = self.view.ph_list.ph_grid_list
		self.grid_list = GridScroll.New()
		local ui_cfg = self.view.ph_list.ph_grid_item
		local grid_node = self.grid_list:Create(0, 0, ph.w, ph.h, 3, ui_cfg.h+10 , ChildItem, ScrollDir.Vertical, false, self.view.ph_list.ph_grid_item)
		grid_node:setAnchorPoint(0, 0)
		grid_node:setPosition(ph.x, ph.y)
		self.view.node_t_list["layout_up_compound"].node:addChild(grid_node, 9)
		self.grid_list:SetSelectCallBack(BindTool.Bind1(self.SelectCellCallBack, self))
		--self.grid_list:GetView():addTouchEventListener(BindTool.Bind(self.OnTouchEvent, self))
		ClientCommonButtonDic[CommonButtonType.EQUIPBOOST_COMPOUND_LIST_VIEW] = self.grid_list
	end
	
end

-- function EquipmentGodEquipPage:OnTouchEvent(sender, event_type, touch)
-- 	if event_type == XuiTouchEventType.Began then
-- 		--print("XuiTouchEventType.Began", event_type)
-- 	elseif event_type == XuiTouchEventType.Moved then
-- 		--print("XuiTouchEventType.Moved", event_type)
-- 	elseif event_type == XuiTouchEventType.Ended then
-- 		--print("XuiTouchEventType.Ended", event_type)
-- 	else	
-- 		--print("XuiTouchEventType", event_type)
-- 	end	
-- end

function EquipmentGodEquipPage:SelectCellCallBack()
	--print("33333333333")
end

-- --初始化事件
-- function EquipmentGodEquipPage:InitEvent()

-- end

function EquipmentGodEquipPage:ChangeToIndex()
	-- local cur_page = self.grid_list:GetCurPageIndex()
	-- local max_page = math.ceil((#self.child_data + 1)/6)
	-- if cur_page < max_page then
	-- 	local page  = cur_page + 1
	-- 	--self.grid_list:ChangeToPage(page)
	-- end
	local data = self.grid_list:GetDataList()
	if #data >= 6 then
		self.grid_list:SetOneItemCanSee(6)
	end
	--if self.
end

function EquipmentGodEquipPage:OpenShouMing()
	DescTip.Instance:SetContent(Language.Equipment.TiTle_Compound_Content, Language.Equipment.TiTle_Compound)
end

-- --移除事件
-- function EquipmentGodEquipPage:RemoveEvent()
	
-- end

-- function EquipmentGodEquipPage:UpdateData(data)
	
-- end

-- 合成结果返回
function EquipmentGodEquipPage:OnCompoundResultBack(result)
	if result == 1 then
		local ph = self.view.ph_list.ph_compound_effec
		self:PlayCompoundSuccEffect(48, ph.x, ph.y)
	end
end

function EquipmentGodEquipPage:PlayCompoundSuccEffect(effct_id, x, y)
	if self.play_effect == nil then
		self.play_effect = AnimateSprite:create()
		self.view.node_t_list.layout_up_compound.node:addChild(self.play_effect,999)
		self.play_effect:setScale(2)
	end	
	self.play_effect:setPosition(x or 480, y or 510)
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effct_id)
	self.play_effect:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)
end

function EquipmentGodEquipPage:SetVisibleToggle()
	local open_days = OtherData.Instance:GetOpenServerDays()
	local combineday = OtherData.Instance:GetCombindDays()
	for i = 1, #Language.Equipment.TabGroup_9 do
		local index = BTNINDEX[i]
		local data = EquipSynthesisConfigEx[index][1]
		local lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
		local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
		if i == 2 then 
			lv = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
			circle = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
		end
		local bool = false
		if data.combineday > 0 then
			if combineday >= data.combineday or open_days >= data.openday then
				if lv >= data.level[2] and circle >= data.level[1] then
					bool = true
				end
			end
		else
			if open_days >= data.openday then
				if lv >= data.level[2] and circle >= data.level[1] then
					bool = true
				end
			end
		end
		if i == 2 then
			self.tabbar_1:SetToggleVisible(i, ZhanjiangData.Instance:GetAttr("hero_id") > 0 and bool)
		else
			self.tabbar_1:SetToggleVisible(i, bool)
		end
	end
end

function EquipmentGodEquipPage:RoleDataChangeCallback(key,value)
	if key == OBJ_ATTR.ACTOR_CIRCLE then
		self:BoolShowData()
	end
end

-- function EquipmentGodEquipPage:ItemDataChangeCallback()
	
-- end

function EquipmentGodEquipPage:FlushCoumpondData()
	self:FlushTreeList()
	self:FlushChildList()
	self:FlushRemind()	
	local list_data = self.tree_item_list:GetData()
	local cur_data = list_data[self.select_index]
	if cur_data.compose_num == 0 then
		self.tree_item_list:SelectIndex(1)
	else
		self.cur_tree_index = cur_data.current_item_index
		self:FlushChildList()
	end
end

function EquipmentGodEquipPage:BoolShowData()
	local child_data = self.grid_list:GetDataList()
	local cur_data = child_data[1]
	local lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	if self.btn_index == 2 then 
		lv = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
		circle = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	end
	local bool = false
	if cur_data and cur_data.consume_level[1] ~= 0 then
		if circle >= cur_data.consume_level[1] then
			bool = false
		else
			bool = true
		end
	else
		bool = false
	end
	self.img_down:setTouchEnabled(not bool)
	self.grid_list:GetView():setEnabled(not bool)
	self.view.node_t_list.comment5.node:setVisible(bool)
	self.view.node_t_list["btn_xoumpond_desc"].node:setTouchEnabled(not bool)
	if bool then
		self.number_circle:SetNumber(cur_data.consume_level[1])
	end
end

function EquipmentGodEquipPage:CreateNumBar(x, y, w, h)
	local number_bar = NumberBar.New()
	number_bar:SetRootPath(ResPath.GetBablePath("num_"))
	number_bar:SetPosition(x, y)
	number_bar:SetContentSize(w, h)
	number_bar:SetSpace(-2)
	return number_bar
end

function EquipmentGodEquipPage:FlushEquipment()
	-- body
end

function EquipmentGodEquipPage:FlushRemind()
	for i = 1, #Language.Equipment.TabGroup_9 do
		local index = BTNINDEX[i]
		local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		local lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
		local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
		if i == 2  then 
			prof = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
			lv = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
			circle = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
		end
		local num = EquipmentData.Instance:GetComposeTreeData(index, lv, circle, prof)
		self.tabbar_1:SetRemindByIndex(i, num > 0)
	end
end

function EquipmentGodEquipPage:FlushTreeList()
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local index = BTNINDEX[self.btn_index]
	if self.btn_index == 2  then 
		prof = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		lv = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
		circle = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	end
	local data = EquipmentData.Instance:GetCompoundTreeCfg(index, lv, circle, prof)
	self.tree_item_list:SetDataList(data)
end

function EquipmentGodEquipPage:FlushChildList()
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local bool_hero = 0
	local index = BTNINDEX[self.btn_index] 
	if self.btn_index == 2   then 
		prof = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		lv = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
		circle = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
		bool_hero = 1
	end
	local data = EquipmentData.Instance:GetChildCanCompose(index,self.cur_tree_index, lv, circle, prof, bool_hero)
	self.grid_list:SetDataList(data)
end

function EquipmentGodEquipPage:CanShowImg()
	local data = self.grid_list:GetDataList()
	local num = #data
	if num <= 6 then
		self.img_down:setVisible(false)
	else
		-- if self.grid_list:GetIndex() < 6 then
		-- 	self.img_down:setVisible(true)
		-- else
		self.img_down:setVisible(false)
		--end
	end
end

TreeListItem = TreeListItem or BaseClass(BaseRender)
function TreeListItem:__init()
	
end

function TreeListItem:__delete()
end

function TreeListItem:CreateChild()
	BaseRender.CreateChild(self)
end

function TreeListItem:OnFlush()
	if self.data == nil then return end
	local txt = self.data.name
	self.node_tree.img_flag.node:setVisible(self.data.compose_num >0)
	RichTextUtil.ParseRichText(self.node_tree.txt_equip_name_2.node, txt)
	XUI.RichTextSetCenter(self.node_tree.txt_equip_name_2.node)
end


function TreeListItem:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2 + 2, size.width, size.height+5, ResPath.GetCommon("select_effect_1"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.select_effect, 999)
end

ChildItem = ChildItem or BaseClass(BaseRender)
function ChildItem:__init()
	
end

function ChildItem:__delete()
	if self.cell ~= nil then
		self.cell:DeleteMe()
		self.cell = nil 
	end
	if self.alert_window then
		self.alert_window:DeleteMe()
		self.alert_window = nil
	end
end

function ChildItem:CreateChild()
	BaseRender.CreateChild(self)
	if self.cell == nil then
		local ph = self.ph_list.ph_cell
		self.cell = BaseCell.New()
		self.cell:SetPosition(ph.x, ph.y)
		self.cell:GetView():setAnchorPoint(0, 0)
		self.view:addChild(self.cell:GetView(), 100)
		self.cell:GetView():setTouchEnabled(true)
		XUI.AddClickEventListener(self.cell:GetView(), BindTool.Bind(self.OpenEquipTip, self), false)
	end
	self.node_tree.btn_coumond.node:addClickEventListener(BindTool.Bind(self.Coumpond, self))
end

function ChildItem:OpenEquipTip()
	local forview = nil
	if self.data.bool_hero == 1 then
		forview = EquipTip.FROM_HERO_COMPARE
	end
	TipsCtrl.Instance:OpenItem(self.data.item, forview)
end

function ChildItem:OnFlush()
	if self.data == nil then return end
	self.cell:SetData(self.data.item)
	local config = ItemData.Instance:GetItemConfig(self.data.item.item_id)
	self.node_tree.txt_target_name.node:setString(config.name)
	local color = Str2C3b(GuideColorCfg[config.bgquality]or"ffffff")
	self.node_tree.txt_target_name.node:setColor(color)
	local item_color = COLOR3B.WHITE
	if self.data.desc ~= nil then
		item_color = COLOR3B.WHITE
		self.node_tree.txt_equip_name.node:setString(self.data.desc)
	else
		local config = ItemData.Instance:GetItemConfig(self.data.consume.item_id)
		local name = config.name 
		self.node_tree.txt_equip_name.node:setString(name)
		item_color = Str2C3b(GuideColorCfg[config.bgquality]or"ffffff")
	end
	self.node_tree.txt_equip_name.node:setColor(item_color)
	local consume_count = self.data.consume.num or 0
	local item_num = 0
	if type(self.data.consume.item_id) == "table" then
		for k,v in pairs(self.data.consume.item_id) do
			item_num = item_num + ItemData.Instance:GetItemNumInBagById(v, nil)
		end
	else
		item_num = ItemData.Instance:GetItemNumInBagById(self.data.consume.item_id, nil)
	end
	local color = COLOR3B.RED
	if item_num >= consume_count then
		color = COLOR3B.GREEN
	end
	local is_can_compose = 0

	local had_txt = item_num .."/"..consume_count
	self.node_tree.txt_had.node:setString(had_txt)
	self.node_tree.txt_had.node:setColor(color)
	local consume_money = 0 
	local had_money = 0
	local path = ResPath.GetCommon("icon_money")
	if self.data.gold ~= nil then
		local money_type = self.data.gold.type
		path = RoleData.GetMoneyTypeIconByAwarType(money_type)
		self.node_tree.img_bg_1.node:loadTexture(path)
	   	consume_money = self.data.gold.count
	   	had_money = RoleData.Instance:GetMoneyNumByAWardType(money_type)
	end
	self.node_tree.txt_money.node:setString(consume_money)
	local is_can_compose = false 
	if item_num >= consume_count and had_money >= consume_money then
		is_can_compose = true
	end
	local show_up_flag = false
	if self.data.bool_hero == 0 then 
		if EquipData.Instance:GetIsBetterEquip(self.data.item, nil, false) then
			show_up_flag = true
		end
	elseif self.data.bool_hero == 1 then
		local is_better = ZhanjiangData.Instance:GetIsBetterEquip(self.data.item, nil, false)
		if is_better then
			show_up_flag = true
		end
	end
	self.cell:SetUpFlagIconVisible(show_up_flag and is_can_compose)
end

function ChildItem:Coumpond()
	if type(self.data.consume.item_id) == "table" then
		local series = {}
		local equip = EquipmentData.Instance:SortEquipmentCompondData()
		for i1, v1 in ipairs(equip) do
			for i, v in ipairs(self.data.consume.item_id) do
				if v == v1.item_id then
					if (#series+1) <= self.data.consume.num  then
						table.insert(series, v1.series)
					end
				end
			end
		end
		local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		if self.data.bool_hero == 1  then 
			prof = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		end
		local bool_show_alert = false
		for k1, v1 in pairs(series) do
			local bool_condition_1 = false
			local bool_condition_2 = false
			local data = ItemData.Instance:GetItemInBagBySeries(v1)
			if data ~= nil then
				local config = ItemData.Instance:GetItemConfig(data.item_id)
				if config.type == ItemData.ItemType.itWeapon or config.type == ItemData.ItemType.itDress then
					bool_condition_1 = true
				end
				for k2,v2 in pairs(config.conds) do

					if v2.cond == ItemData.UseCondition.ucJob then
						if prof == v2.value then
							bool_condition_2 = true
						end
					end
				end
				if bool_condition_1 and bool_condition_2 then
					bool_show_alert = true
					break
				end
			end
		end
		if bool_show_alert then
			if nil == self.alert_window then
				self.alert_window = Alert.New()
			end
			self.alert_window:SetLableString(Language.Equipment.Compoud_desc)
			self.alert_window:SetOkFunc(function()
					EquipmentCtrl.Instance:SendComposeEquipGemReq(self.data.current_index, self.data.current_type, self.data.current_item_index, self.data.item.item_id, self.data.bool_hero, series)
				end)
			self.alert_window:Open()	
		else
			EquipmentCtrl.Instance:SendComposeEquipGemReq(self.data.current_index, self.data.current_type, self.data.current_item_index, self.data.item.item_id, self.data.bool_hero, {})
		end
	else
		EquipmentCtrl.Instance:SendComposeEquipGemReq(self.data.current_index, self.data.current_type, self.data.current_item_index, self.data.item.item_id, self.data.bool_hero, {})
	end
	AudioManager.Instance:PlayClickBtnSoundEffect()

end

function ChildItem:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("img9_173"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.select_effect, 999)
end

function ChildItem:GetGuideView()
	return self.node_tree.btn_coumond.node
end


TargetCell = TargetCell or BaseClass(BaseCell)
function TargetCell:__init()
end	

function TargetCell:__delete()
end

function TargetCell:SetRightBottomText(text, color)
	color = color or COLOR3B.WHITE
	if nil == self.right_bottom_text then
		if text == 0 then return end
		self.right_bottom_text = XUI.CreateText(BaseCell.SIZE + 15, 5, BaseCell.SIZE - 8, 20, 
		cc.TEXT_ALIGNMENT_CENTER, text, nil, 18, color)
		self.right_bottom_text:setAnchorPoint(1, 0)
		XUI.EnableShadow(self.right_bottom_text, nil, cc.size(2, -2))
		self.view:addChild(self.right_bottom_text, 200, 10)
	else
		self.right_bottom_text:setString(text)
		self.right_bottom_text:setColor(color)
		self.right_bottom_text:setVisible(self.rightbottom_text_isvisible)
		self.right_bottom_text:setVisible(text ~= 0)
	end
	if self.img == nil then
		self.img = XUI.CreateImageView(BaseCell.SIZE/2, 15, ResPath.GetCommon("bg_154"), true)
		self.view:addChild(self.img, 100)
	end
end

ShengZhuangItem = ShengZhuangItem or BaseClass(BaseRender)
function ShengZhuangItem:__init()
	
end

function ShengZhuangItem:__delete()
	if self.equip_cell ~= nil then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil 
	end
end

function ShengZhuangItem:CreateChild()
	BaseRender.CreateChild(self)
	if self.equip_cell == nil then
		local ph = self.ph_list.ph_item_cell
		self.equip_cell = GodEquipCell.New()
		self.equip_cell:SetPosition(ph.x, ph.y)
		self.equip_cell:GetView():setAnchorPoint(0, 0)
		self.view:addChild(self.equip_cell:GetView(), 100)
	end
end

function ShengZhuangItem:OnFlush()
	if self.data == nil then return end
	if self.data.item_id == nil then return end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end
	self.node_tree["txt_equip_name"].node:setString(item_cfg.name)
	if item_cfg.color ~= nil then
		local color = string.format("%06x", item_cfg.color)
		self.node_tree["txt_equip_name"].node:setColor(Str2C3b(color))
	end
	self.equip_cell:SetData(self.data)
end

GodEquipCell = GodEquipCell or BaseClass(BaseCell)
function GodEquipCell:__init()
end	

function GodEquipCell:__delete()
end

function GodEquipCell:InitEvent()
end	
