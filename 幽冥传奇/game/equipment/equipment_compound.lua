EquipmentCompoundPage = EquipmentCompoundPage or BaseClass()


function EquipmentCompoundPage:__init()
	self.view = nil
end	

function EquipmentCompoundPage:__delete()
	self:RemoveEvent()

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
	-- if self.time_event then
	-- 	GlobalEventSystem:UnBind(self.time_event)
	-- 	self.time_event = nil
	-- end

	self.view = nil

	ClientCommonButtonDic[CommonButtonType.EQUIPBOOST_COMPOUND_LIST_VIEW] = nil
end	

--初始化页面接口
function EquipmentCompoundPage:InitPage(view)
	--绑定要操作的元素
	self.btn_index = 1
	self.cur_tree_index = 1
	self.select_index =1
	self.view = view
	self.child_data = {}
	self.tree_data = {}
	self:InitTabber()
	-- self.time_event = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind1(self.BoolShowBtn, self))
	self:CreateTreeList()
	self:CreateChildList()
	self:InitEvent()
end

function EquipmentCompoundPage:InitTabber()
	self.tabbar_1 = ScrollTabbar.New()
	self.tabbar_1.space_interval_V = 10
	self.tabbar_1:SetSpaceInterval(6)
	self.tabbar_1:CreateWithNameList(self.view.node_t_list.scroll_tabbar.node, 7, -20,
		BindTool.Bind1(self.SelectTabCallback, self), Language.Equipment.TabGroup_4, 
		true, ResPath.GetCommon("btn_106_normal"))
end

function EquipmentCompoundPage:SelectTabCallback(index)
	self.btn_index = index
	self:FlushTreeList()
	self.tree_item_list:SelectIndex(1)
	self:FlushChildList()
	self.grid_list:JumpToTop()
	self:CanShowImg()
	--self.grid_list:ChangeToPage(1)
	--self:ChangePageCallBack()
end

function EquipmentCompoundPage:CreateTreeList()
	local ph = self.view.ph_list.ph_tree_list
	self.tree_item_list = ListView.New()
	self.tree_item_list:Create(ph.x, ph.y, ph.w, ph.h, nil, TreeListItem, nil, nil, self.view.ph_list.ph_tree_item)
	self.view.node_t_list["layout_compound"].node:addChild(self.tree_item_list:GetView(), 888)
	self.tree_item_list:SetMargin(10)
	self.tree_item_list:SetItemsInterval(10)
	self.tree_item_list:SelectIndex(1)
	self.tree_item_list:GetView():setAnchorPoint(0, 0)
	self.tree_item_list:SetJumpDirection(ListView.Top)
	self.tree_item_list:SetSelectCallBack(BindTool.Bind1(self.SelectTreeListCallBack, self))
end

function EquipmentCompoundPage:SelectTreeListCallBack(item, index)
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

function EquipmentCompoundPage:CreateChildList()
	if self.grid_list == nil then
		local ph = self.view.ph_list.ph_grid_list
		self.grid_list = GridScroll.New()
		local ui_cfg = self.view.ph_list.ph_grid_item
		local grid_node = self.grid_list:Create(0, 0, ph.w, ph.h, 3, ui_cfg.h+10 , ChildItem, ScrollDir.Vertical, false, self.view.ph_list.ph_grid_item)
		grid_node:setAnchorPoint(0, 0)
		grid_node:setPosition(ph.x, ph.y)
		self.view.node_t_list["layout_compound"].node:addChild(grid_node, 9)
		self.grid_list:SetSelectCallBack(BindTool.Bind1(self.SelectCellCallBack, self))
		--self.grid_list:GetView():addTouchEventListener(BindTool.Bind(self.OnTouchEvent, self))
		ClientCommonButtonDic[CommonButtonType.EQUIPBOOST_COMPOUND_LIST_VIEW] = self.grid_list
	end
	
end

-- function EquipmentCompoundPage:OnTouchEvent(sender, event_type, touch)
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

function EquipmentCompoundPage:SelectCellCallBack()
	--print("33333333333")
end

-- function EquipmentCompoundPage:ChangePageCallBack()
-- 	if self.grid_list then
-- 		local cur_page =self.grid_list:GetCurPageIndex()
-- 		local max_page = math.ceil((#self.child_data + 1)/6)
-- 		self.img_down:setVisible(cur_page < max_page)
-- 	else	
-- 		self.img_down:setVisible(false)
-- 	end
-- end

-- function EquipmentCompoundPage:SelectChildListCallBack(item, index)
-- 	if item == nil or item:GetData() == nil then return end
-- 	self.cur_child_index = index
-- 	self:FlushTreeList()
-- 	self:FlushChildList()
-- end

--初始化事件
function EquipmentCompoundPage:InitEvent()
	self.view.node_t_list["btn_xoumpond_desc"].node:addClickEventListener(BindTool.Bind(self.OpenShouMing, self))
	self.itemdata_change_callback = BindTool.Bind1(self.ItemDataChangeCallback, self)           -- 监听物品数据变化
	ItemData.Instance:NotifyDataChangeCallBack(self.itemdata_change_callback)

	self.roledata_change_callback = BindTool.Bind1(self.RoleDataChangeCallback, self)           -- 监听物品数据变化
	RoleData.Instance:NotifyAttrChange(self.roledata_change_callback)
	local ph = self.view.ph_list.ph_effect
	self.img_down = XUI.CreateImageView(ph.x+10, ph.y, ResPath.GetCommon("btn_down"),true)
	self.view.node_t_list["layout_compound"].node:addChild(self.img_down, 200)
	CommonAction.ShowJumpAction(self.img_down)
	self.img_down:setScale(0.8)
	XUI.AddClickEventListener(self.img_down, BindTool.Bind(self.ChangeToIndex, self), true)
	self.compound_result_evt = GlobalEventSystem:Bind(EquipmentEvent.EQUIP_COMPOUND_RESULT_BACK, BindTool.Bind(self.OnCompoundResultBack, self))
	local ph = self.view.ph_list.ph_number
	self.number_circle = self:CreateNumBar(ph.x-10, ph.y-25, 48, 62)
	self.view.node_t_list.comment5.node:addChild(self.number_circle:GetView(), 101)
	self.number_circle:SetGravity(NumberBarGravity.Center)
	self.number_circle:SetNumber(0)
	self.view.node_t_list.comment5.node:setLocalZOrder(998)
end

function EquipmentCompoundPage:ChangeToIndex()
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

function EquipmentCompoundPage:OpenShouMing()
	DescTip.Instance:SetContent(Language.Equipment.TiTle_Compound_Content, Language.Equipment.TiTle_Compound)
end

--移除事件
function EquipmentCompoundPage:RemoveEvent()
	if self.itemdata_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.itemdata_change_callback)
		self.itemdata_change_callback = nil 
	end
	if self.roledata_change_callback then
		RoleData.Instance:UnNotifyAttrChange(self.roledata_change_callback)
		self.roledata_change_callback = nil 
	end

	if self.compound_result_evt then
		GlobalEventSystem:UnBind(self.compound_result_evt)
		self.compound_result_evt = nil
	end
end

function EquipmentCompoundPage:UpdateData(data)
	self:SetVisibleToggle()
	self:FlushTreeList()
	self.tree_item_list:SelectIndex(1)
	self:FlushChildList()
	self:FlushRemind()
	--self:ChangePageCallBack()
	self:BoolShowData()
end

-- 合成结果返回
function EquipmentCompoundPage:OnCompoundResultBack(result)
	if result == 1 then
		local ph = self.view.ph_list.ph_compound_effec
		self:PlayCompoundSuccEffect(48, ph.x, ph.y)
	end
end

function EquipmentCompoundPage:PlayCompoundSuccEffect(effct_id, x, y)
	if self.play_effect == nil then
		self.play_effect = AnimateSprite:create()
		self.view.node_t_list.layout_compound.node:addChild(self.play_effect,999)
		self.play_effect:setScale(2)
	end	
	self.play_effect:setPosition(x or 480, y or 510)
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effct_id)
	self.play_effect:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)
end

function EquipmentCompoundPage:SetVisibleToggle()
	local open_days = OtherData.Instance:GetOpenServerDays()
	local combineday = OtherData.Instance:GetCombindDays()
	for i = 1, #Language.Equipment.TabGroup_4 do
		local index = BTNINDEX[i]
		local data = EquipSynthesisConfigEx[index][1]
		-- print("3333333333",EquipSynthesisConfigEx[index][1])
		local lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
		local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
		if i == 2  then 
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
		if i == 2  then
			self.tabbar_1:SetToggleVisible(i, ZhanjiangData.Instance:GetAttr("hero_id") > 0 and bool)
		else
			self.tabbar_1:SetToggleVisible(i, bool)
		end
	end
	if not self.tabbar_1:GetToggleVis(1) then
		self.tabbar_1:SelectIndex(#Language.Equipment.TabGroup_4)
	end
end

function EquipmentCompoundPage:RoleDataChangeCallback(key,value)
	if key == OBJ_ATTR.ACTOR_CIRCLE then
		self:BoolShowData()
	end
end

function EquipmentCompoundPage:ItemDataChangeCallback()
	self:FlushData()
end

function EquipmentCompoundPage:FlushData()
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

function EquipmentCompoundPage:BoolShowData()
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

function EquipmentCompoundPage:CreateNumBar(x, y, w, h)
	local number_bar = NumberBar.New()
	number_bar:SetRootPath(ResPath.GetBablePath("num_"))
	number_bar:SetPosition(x, y)
	number_bar:SetContentSize(w, h)
	number_bar:SetSpace(-2)
	return number_bar
end

function EquipmentCompoundPage:FlushEquipment()
	-- body
end

function EquipmentCompoundPage:FlushRemind()
	for i = 1, #Language.Equipment.TabGroup_4 do
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

function EquipmentCompoundPage:FlushTreeList()
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
	-- self.tree_data = data
	self.tree_item_list:SetDataList(data)
end

function EquipmentCompoundPage:FlushChildList()
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local bool_hero = 0
	local index = BTNINDEX[self.btn_index] 
	if self.btn_index == 2  then 
		prof = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		lv = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
		circle = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
		bool_hero = 1
	end
	local data = EquipmentData.Instance:GetChildCanCompose(index,self.cur_tree_index, lv, circle, prof, bool_hero)
	self.grid_list:SetDataList(data)
end

function EquipmentCompoundPage:CanShowImg()
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

-- function ChildItem:CompareGuideData(data)
-- 	if self.index == data then
-- 		return true
-- 	end
-- 	return false
-- end






