ForgeSuitView = ForgeSuitView or BaseClass(BaseRender)

function ForgeSuitView:__init()
	self.suit_name 		= self:FindVariable("suit_name")
	self.item_num_1 	= self:FindVariable("item_num_1")
	self.item_num_2 	= self:FindVariable("item_num_2")
	self.glow_effect 	= self:FindVariable("glow_effect")
	self.bg_effect 		= self:FindVariable("bg_effect")
	self.is_can_strength = self:FindVariable("is_can_strength")
	self.strength_end 	= self:FindVariable("strength_end")
	self.strength_text 	= self:FindVariable("strength_text")
	self.is_empty 		= self:FindVariable("is_empty")
	self.show_red_point = self:FindVariable("show_red_point")
	self.cs_red_point 	= self:FindVariable("cs_red_point")
	self.ss_red_point 	= self:FindVariable("ss_red_point")
	self.cur_equip_name	= self:FindVariable("equip_name")
	self.ss_btn_img = self:FindVariable("btn_img_path1")
	self.cs_btn_img = self:FindVariable("btn_img_path2")

	self.cs_btn = self:FindObj("CSBtn")
	self.ss_btn = self:FindObj("SSBtn")
	self.cs_text = self:FindObj("CS_Text")
	self.ss_text = self:FindObj("SS_Text")
	self.cs_hl_text = self:FindObj("CS_HL_Text")
	self.ss_hl_text = self:FindObj("SS_HL_Text")

	--鍛造成功特效
	self.forge_effect = self:FindObj("ForgeEffect")
	self.show_forge_effect = self:FindVariable("show_forge_effect")
	self.show_forge_effect:SetValue(false)
	self.is_load_effect = false
	self.effect_obj = nil
	self.is_clisk = false

	self.equip_cell = ItemCell.New()
	self.equip_cell:SetInstanceParent(self:FindObj("CurEquipCell"))
	self.equip_cell:SetDefualtBgState(false)

	self.display = self:FindObj("display")
	self.suit_rock_item2 = self:FindObj("suit_rock_item2")

	--套装属性
	-- self.suit_list = {}
	self.suit_att_content_list = {}
	for i = 1, 3 do
		-- self.suit_list[i] = self:FindObj("suit"..i+1)
		self.suit_att_content_list[i] = SuitAttContent.New(self:FindObj("suit"..i))
	end
	--锻造套装石item
	self.item_cell_list = {}
	for i = 1, 2 do
		local item_cell = self:FindObj("item_"..i)
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(item_cell)
	end

	self:ListenEvent("strength_click", BindTool.Bind(self.StrengthClick, self))
	self:ListenEvent("change_click_ss", BindTool.Bind(self.ChangeClickSS, self))
	self:ListenEvent("change_click_cs", BindTool.Bind(self.ChangeClickCS, self))
	self:ListenEvent("help_click", BindTool.Bind(self.HelpClick, self))

	self:InitScroller()
	self.suit_type = 1  --1:史诗套装，-1:传说套装
	-- self.ss_btn.button.interactable = false
	self.ss_btn_img:SetAsset("uis/views/forgeview/images_atlas", "btn_02_HL")
	self.ss_hl_text:SetActive(true)
	self.select_equip_data = {}
	self.first_open = true  --第一次打开套装界面

	self.timer_quest = nil
	self.btn_red_point_status = false

	self.hujia_suit = {2,4,6}
	self.shiping_suit = {1,2,4}
	local temp_equip_list_data = ForgeData.Instance:ReorderEquipList()

	self:SetScrollerData(self:SortData(temp_equip_list_data))
	self:FristFlushView()
end

function ForgeSuitView:__delete()
	if self.EquipModel then
		self.EquipModel:DeleteMe()
		self.EquipModel = nil
	end

	if nil ~= self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil
	end

	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	self.is_load_effect = nil
	if self.effect_obj then
		GameObject.Destroy(self.effect_obj)
		self.effect_obj = nil
	end

	for k, v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}

	for k, v in pairs(self.suit_att_content_list) do
		v:DeleteMe()
	end
	self.suit_att_content_list = {}

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function ForgeSuitView:FristFlushView()
	--获取玩家身上穿的装备列表
	local temp_equip_list_data = ForgeData.Instance:ReorderEquipList()

	self:SetScrollerData(self:SortData(temp_equip_list_data))
	self:InitEquipModel()
	if next(self.select_equip_data) then
		self:FlushModel()
	end

	--没有装备
	if #self.scroller_data == 0 then
		self.is_empty:SetValue(true)
	else
		self.is_empty:SetValue(false)
	end

	self.first_open = true

	self:SetChangeSuitBtnRedPoint()

	if self.suit_type == 1 then
		self.ss_red_point:SetValue(false)
	else
		self.cs_red_point:SetValue(false)
	end

end
--检查该装备是否可锻造
function ForgeSuitView:IsCanStrengthByID(itemId,dataIndex)
	local result = false
	local suit_data_cfg = ForgeData.Instance:GetSuitUpLevelCfgByItemId(itemId)
	local item_cfg = ItemData.Instance:GetItemConfig(itemId)
	local cur_suit_type = ForgeData.Instance:GetCurEquipSuitType(dataIndex)
	if nil == suit_data_cfg then --装备是否属于套装
		result = false
		return result
	else
		if cur_suit_type == 0 then
			if self.suit_type == 1 then
				result = true
				return result
			else
				result =false
				return result
			end
		elseif cur_suit_type == 1 then
			result = true
			return result
		else
			result =false
			return result
		end

	end
end
--对装备数据进行排序  排序方案：1、可操作的放前面2、武器放第一格3、没装备的隐藏
function ForgeSuitView:SortData(temp_equip_list_data)
	local temp_equip_list_data2 = {}   	--用于储存排序后的数据，
	local CanStrengthCount = 0  		--用于记录可以锻造的数量
	--可操作的放前面
	for i=1,#temp_equip_list_data do
		if self:IsCanStrengthByID(temp_equip_list_data[i].item_id,temp_equip_list_data[i].data_index) then  	--是否可锻造
			table.insert(temp_equip_list_data2,CanStrengthCount + 1,temp_equip_list_data[i])
			CanStrengthCount = CanStrengthCount + 1
		else
			table.insert(temp_equip_list_data2,#temp_equip_list_data2+1,temp_equip_list_data[i])
		end
	end
	--武器放第一
	for i=1,#temp_equip_list_data2 do
		if self:IsCanStrengthByID(temp_equip_list_data2[i].item_id,temp_equip_list_data2[i].data_index) then 	--是否可锻造
			if temp_equip_list_data2[i].item_id > 8000 and temp_equip_list_data2[i].item_id < 9000 then
				table.insert(temp_equip_list_data2,1,temp_equip_list_data2[i])
				table.remove(temp_equip_list_data2,i+1)
			end
		else
			if temp_equip_list_data2[i].item_id > 8000 and temp_equip_list_data2[i].item_id < 9000 then
				table.insert(temp_equip_list_data2,CanStrengthCount + 1,temp_equip_list_data2[i])
				table.remove(temp_equip_list_data2,i+1)
			end
		end
	end
	return temp_equip_list_data2
end

function ForgeSuitView:Flush()

end

--设置转换套装按钮的红点状态
function ForgeSuitView:SetChangeSuitBtnRedPoint()
	local ss_btn_red_point_status = ForgeData.Instance:GetChangeSuitBtnRedPointStatus(self.scroller_data, 1)
	local cs_btn_red_point_status = ForgeData.Instance:GetChangeSuitBtnRedPointStatus(self.scroller_data, -1)
	self.ss_red_point:SetValue(ss_btn_red_point_status)
	self.cs_red_point:SetValue(cs_btn_red_point_status)
end

--初始化滚动条
function ForgeSuitView:InitScroller()
	self.cell_list = {}
	self.scroller = self:FindObj("Scroller")
	self.equip_scroller_select_index = 1
	local list_delegate = self.scroller.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
--	list_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.GetCellView, self)
	-- self.list_view_delegate = ListViewDelegate()
	-- PrefabPool.Instance:Load(AssetID("uis/views/forgeview", "SuitEquipCell"), function (prefab)
	-- 	if nil == prefab then
	-- 		print(ToColorStr("prefab为空", TEXT_COLOR.RED))
	-- 		return
	-- 	end
	-- 	self.enhanced_cell_type = prefab:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))
	-- 	self.scroller.scroller.Delegate = self.list_view_delegate
	-- 	self.list_view_delegate.numberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	-- 	self.list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
	-- 	self.list_view_delegate.cellViewDel = BindTool.Bind(self.GetCellView, self)
	-- 	PrefabPool.Instance:Free(prefab)
	-- end)
end

--滚动条格子数量
function ForgeSuitView:GetNumberOfCells()
	if self.scroller_data then
		return #self.scroller_data
	else
		return 0
	end
end

--滚动条格子大小
function ForgeSuitView:GetCellSize()
	return 110
end

--滚动条刷新
function ForgeSuitView:GetCellView(cell, data_index)

	-- local cell = scroller:GetCellView(self.enhanced_cell_type)
	data_index = data_index + 1
	local scroller_cell = self.cell_list[cell]
	if nil == scroller_cell then
		self.cell_list[cell] = EquiCell.New(cell.gameObject)
		scroller_cell = self.cell_list[cell]
		scroller_cell.mother_view = self
		scroller_cell.root_node.toggle.group = self.scroller.toggle_group
	end
	self.scroller_data[data_index].cell_index = data_index
	scroller_cell:SedIndex(data_index)
	scroller_cell:SetData(self.scroller_data[data_index])
	-- return cell
end


--刷新所有装备格子信息
function ForgeSuitView:FlushEquiCell()
	for k,v in pairs(self.cell_list) do
		v:OnFlush()
	end
end

--设置装备列表的数据
function ForgeSuitView:SetScrollerData(data)
	self.scroller_data = data
end

--点击装备栏cell
function ForgeSuitView:SetSelectEquipData(data)
	local equip_list_data = EquipData.Instance:GetDataList()
	self.select_equip_data = data
	self.select_equip_item_id = data.item_id
	self:FlushAllAttContent()
	self:FlushModel()
	self:FlushEffect()
	self:FlushSuitRockItem()
	self:SetStrengthStatus()
	self.show_red_point:SetValue(self.btn_red_point_status)
end

--锻造成功之后回调
function ForgeSuitView:StrengthEndCallBack()
	self:FlushAllAttContent()
	self:FlushSuitRockItem()
	self:SetStrengthStatus()
	self:FlushEquiCell()
	self:OnAfterForgeEffect()
	self.show_red_point:SetValue(false)
	self:SetChangeSuitBtnRedPoint()
end

--设置锻造成功特效
function ForgeSuitView:OnAfterForgeEffect()
	TipsCtrl.Instance:OpenEffectView("effects2/prefab/ui_x/ui_chenggongtongyong_prefab", "UI_ChengGongTongYong", 1.5)
end

--设置锻造按钮的显示隐藏 ,can_strength:能否锻造，status:锻造是否完成
function ForgeSuitView:SetStrengthStatus()

	local can_strength = true
	local status = false
	local cur_suit_type = ForgeData.Instance:GetCurEquipSuitType(self.select_equip_data.data_index)
	local suit_data_cfg = ForgeData.Instance:GetSuitUpLevelCfgByItemId(self.select_equip_item_id)
	if nil ~= suit_data_cfg then
		can_strength = true
	else
		can_strength = false
		self.strength_end:SetValue(true)
		if self.suit_type == 1 then
			self.strength_text:SetValue(Language.Forge.CanNotForgeSS)
		else
			self.strength_text:SetValue(Language.Forge.CanNotForgeCS)
		end
		return
	end

	if self.suit_type == 1 then --史诗界面
		if cur_suit_type == 0 then
			status = false
		elseif cur_suit_type == 1 then
			status = true
			self.strength_text:SetValue(Language.Forge.CanForgeCS)
		elseif cur_suit_type == 2 then
			status = true
			self.strength_text:SetValue(Language.Forge.ForgeEnd)
		end
	else 						--传说界面
		if cur_suit_type == 0 then
			status = true
			self.strength_text:SetValue(Language.Forge.CanNotForgeCS)
		elseif cur_suit_type == 1 then
			status = false
			self.strength_text:SetValue(Language.Forge.CanForgeCS)
		elseif cur_suit_type == 2 then
			status = true
			self.strength_text:SetValue(Language.Forge.ForgeEnd)
		end
	end

	self.strength_end:SetValue(status)
end

--设置锻造按钮红点状态
function ForgeSuitView:SetRedPointStatus(rock1_is_enough, rock2_is_enough)
	self.btn_red_point_status = false
	if self.suit_type == 1 then
		if rock1_is_enough then
			self.btn_red_point_status = true
		end
	else
		if rock1_is_enough and rock2_is_enough then
			self.btn_red_point_status = true
		end
	end
	return self.btn_red_point_status
end

--套装石是否足够
-- function ForgeSuitView:GetItemNumIsEnough(cur_num, need_num)
-- 	if tonumber(cur_num) >= tonumber(need_num) then
-- 		return true
-- 	else
-- 		return false
-- 	end
-- end

--刷新套装石itemcell
function ForgeSuitView:FlushSuitRockItem()
	local strength_data_cfg = ForgeData.Instance:GetSuitUpLevelCfgByItemId(self.select_equip_item_id)
	local cur_num_1 = 0 --当前拥有的套装石数量
	local cur_num_2 = 0 --当前拥有的套装石数量
	local item_num_value_1 = ""
	local item_num_value_2 = ""
	local data_1 = {}
	local data_2 = {}

	if nil == strength_data_cfg then
		return
	end

	--获取背包中对应套装石数量
	if self.suit_type == 1 then
		cur_num_1 = ForgeData.Instance:GetBagSuitRockNum(strength_data_cfg.need_stuff_id_ss)
		data_1.item_id = strength_data_cfg.need_stuff_id_ss
	else
		cur_num_1 = ForgeData.Instance:GetBagSuitRockNum(strength_data_cfg.need_stuff_id_cq1)
		data_1.item_id = strength_data_cfg.need_stuff_id_cq1
	end

	local rock1_is_enough = ForgeData.Instance:GetItemNumIsEnough(cur_num_1, strength_data_cfg.need_stuff_count_ss)
	local rock2_is_enough = nil
	--设置当前套装石数量颜色
	cur_num_1 = self:SetTextNumColor(cur_num_1, strength_data_cfg.need_stuff_count_ss)
	item_num_value_1 = cur_num_1.." / "..strength_data_cfg.need_stuff_count_ss
	self.item_cell_list[1]:SetData(data_1)
	self.item_num_1:SetValue(item_num_value_1)


	--史诗套装只需一种套装石，所以隐藏第二个套装石item
	self.suit_rock_item2:SetActive(self.suit_type == -1)
	if self.suit_type == -1 then
		cur_num_2 = ForgeData.Instance:GetBagSuitRockNum(strength_data_cfg.need_stuff_id_cq2)
		rock2_is_enough = ForgeData.Instance:GetItemNumIsEnough(cur_num_2, strength_data_cfg.need_stuff_count_cq2)
		data_2.item_id = strength_data_cfg.need_stuff_id_cq2
		--设置当前套装石数量颜色
		cur_num_2 = self:SetTextNumColor(cur_num_2, strength_data_cfg.need_stuff_count_cq2)
		item_num_value_2 = cur_num_2.." / "..strength_data_cfg.need_stuff_count_cq2
		self.item_cell_list[2]:SetData(data_2)
		self.item_num_2:SetValue(item_num_value_2)
	end
	self:SetRedPointStatus(rock1_is_enough, rock2_is_enough)

end

--设置numtext颜色
function ForgeSuitView:SetTextNumColor(cur_num, need_num)
	if cur_num < need_num then
		cur_num = ToColorStr(cur_num, TEXT_COLOR.RED)
	else
		cur_num = ToColorStr(cur_num, TEXT_COLOR.BLUE_SPECIAL)
	end

	return cur_num
end

--刷新所有套装属性显示
function ForgeSuitView:FlushAllAttContent()
	--获取套装cfg
	local suit_uplevel_cfg = ForgeData.Instance:GetSuitUpLevelCfgByItemId(self.select_equip_item_id)
	--无法锻造的装备隐藏属性
	if nil == suit_uplevel_cfg then
		self.is_can_strength:SetValue(false)
		return
	end
	self.is_can_strength:SetValue(true)
	local suit_name = ForgeData.Instance:GetSuitName(suit_uplevel_cfg.suit_id,self.suit_type)
	self.suit_name:SetValue(suit_name)
	local temp_suittype = 1
	if self.suit_type == -1 then
		temp_suittype = 2
	end
	local cur_suit_num = ForgeData.Instance:GetSuitNumByItemId(self.select_equip_item_id, temp_suittype)
	for i = 1, 3 do
		local suit_num = 1
		if suit_uplevel_cfg.suit_id >= 5134 then
			suit_num = self.shiping_suit[i]
		else
			suit_num = self.hujia_suit[i]
		end
		local suit_data_cfg = ForgeData.Instance:GetSuitAttCfg(suit_uplevel_cfg.suit_id, suit_num, self.suit_type)
		self.suit_att_content_list[i]:SetData(suit_data_cfg, cur_suit_num)
	end
end

--初始化模型
function ForgeSuitView:InitEquipModel()
	if not self.EquipModel then
		self.EquipModel = RoleModel.New()
		self.EquipModel:SetDisplay(self.display.ui3d_display)
	end
	self.EquipModel:SetVisible(false)
end

--刷新模型
function ForgeSuitView:FlushModel()
	if next(self.select_equip_data) then
		if nil == self.select_equip_data.data_index then
			self.select_equip_data.data_index = 0
		end
		local res_id = "000" .. self.select_equip_data.data_index + 1
		local bubble, asset = ResPath.GetForgeEquipModel(res_id)
		self.EquipModel:SetVisible(true)
		self.EquipModel:SetMainAsset(bubble, asset)
		self:FlushFlyAniModel()
		self.equip_cell:SetData(self.select_equip_data)
		self.equip_cell:SetDefualtBgState(false)
		self.cur_equip_name:SetValue(ItemData.Instance:GetItemConfig(self.select_equip_data.item_id).name)
	end
end

--模型出场动作
function ForgeSuitView:FlushFlyAniModel()
	if self.tweener then
		self.tweener:Pause()
	end
	self.display.rect:SetLocalScale(0, 0, 0)
	local target_scale = Vector3(1, 1, 1)
	self.tweener = self.display.rect:DOScale(target_scale, 0.5)
end

--刷新特效
function ForgeSuitView:FlushEffect()
	local item_cfg = ItemData.Instance:GetItemConfig(self.select_equip_item_id)
	-- local glow_bundle, glow_asset = ResPath.GetForgeEquipGlowEffect(item_cfg.color)
	-- local bg_bundle, bg_asset = ResPath.GetForgeEquipBgEffect(item_cfg.color)
	-- self.glow_effect:SetAsset(glow_bundle, glow_asset)
	-- self.bg_effect:SetAsset(bg_bundle, bg_asset)
end

--锻造
function ForgeSuitView:StrengthClick()
	ForgeCtrl.Instance:SendSuitStrengthReq(
		FORGE.EQUIPMENT_SUIT_OPERATE_TYPE.EQUIPMENT_SUIT_OPERATE_TYPE_EQUIP_UP,
		self.select_equip_data.data_index)
end

--切换史诗套装
function ForgeSuitView:ChangeClickSS()
	-- self.ss_btn.button.interactable = false
	-- self.cs_btn.button.interactable = true
	self.ss_btn_img:SetAsset("uis/views/forgeview/images_atlas", "btn_02_HL")
	self.cs_btn_img:SetAsset("uis/images_atlas", "btn_02")
	self.cs_hl_text:SetActive(false)
	self.ss_hl_text:SetActive(true)
	self.cs_text:SetActive(true)
	self.ss_text:SetActive(false)
	self.is_can_strength:SetValue(true)
	self.suit_type = 1
	local temp_equip_list_data = ForgeData.Instance:ReorderEquipList()
	self:SetScrollerData(self:SortData(temp_equip_list_data))
	self:FlushEquiCell()
	self:FlushSuitRockItem()
	self:SetSelectEquipData(self.scroller_data[1])
	self:FlushAllAttContent()
	self:SetStrengthStatus()
	self:SetChangeSuitBtnRedPoint()
	self.ss_red_point:SetValue(false)
	self.is_clisk = true
	for i=1,3 do
		self.suit_att_content_list[i]:Flush()
	end
	self.scroller.scroller:ReloadData(0)
end
--切换传说套装
function ForgeSuitView:ChangeClickCS()
	-- self.ss_btn.button.interactable = true
	-- self.cs_btn.button.interactable = false
	self.ss_btn_img:SetAsset("uis/images_atlas", "btn_02")
	self.cs_btn_img:SetAsset("uis/views/forgeview/images_atlas", "btn_02_HL")
	self.cs_hl_text:SetActive(true)
	self.ss_hl_text:SetActive(false)
	self.cs_text:SetActive(false)
	self.ss_text:SetActive(true)
	self.is_can_strength:SetValue(true)
	self.suit_type = -1
	local temp_equip_list_data = ForgeData.Instance:ReorderEquipList()
	self:SetScrollerData(self:SortData(temp_equip_list_data))
	self:FlushEquiCell()
	self:FlushSuitRockItem()
	self:SetSelectEquipData(self.scroller_data[1])
	self:SetStrengthStatus()
	self:FlushAllAttContent()
	self:SetChangeSuitBtnRedPoint()
	self.cs_red_point:SetValue(false)
	self.is_clisk = true
	for i=1,3 do
		self.suit_att_content_list[i]:Flush()
	end
	--OnToggleValueChange
	-- local cell = scroller:GetCellView(self.enhanced_cell_type)
	-- self.cell_list[cell]:OnToggleValueChange(true)
	self.scroller.scroller:ReloadData(0)
end

function ForgeSuitView:ChangeBool()
	self.is_clisk = false
end

function ForgeSuitView:GetBool()
	return self.is_clisk
end

--帮助
function ForgeSuitView:HelpClick()
	local tips_id = 148    -- 套装tips
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end


----------装备列表cell--------
EquiCell = EquiCell or BaseClass(BaseCell)

function EquiCell:__init()
	self.data = {}
	self.name = self:FindVariable("Name")
	self.can_strength = self:FindVariable("IsCanStrength") --是否能锻造（设置隐藏锻造属性）
	self.sui_num = self:FindVariable("SuitNum")
	self.is_show_num = self:FindVariable("IsShowNum")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.red_point_status = false
	self.index = 0
	self.root_node.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleValueChange, self))
end

function EquiCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	self.mother_view = nil
end

function EquiCell:SedIndex(index)
	self.index = index
end

function EquiCell:GetIndex()
	return self.index
end


function EquiCell:SetData(data)
	if not next(data) or nil == data.item_id then
		return
	end
	self.data = data
	self:OnFlush()
end

function EquiCell:OnFlush()

	if self.mother_view:GetBool() and self.data.cell_index == 1 then
		self:OnToggleValueChange(true)
		self.mother_view:ChangeBool()
	end

	local suit_data_cfg = ForgeData.Instance:GetSuitUpLevelCfgByItemId(self.data.item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	local cur_suit_type = ForgeData.Instance:GetCurEquipSuitType(self.data.data_index)
	self.item_cell:SetData(self.data)
	self.item_cell:SetShowUpArrow(false)
	if nil == suit_data_cfg then --装备是否属于套装
		self.name:SetValue(item_cfg.name)
		if item_cfg.order < 5 then
			self.can_strength:SetValue(Language.Forge.LevelLimit)
		elseif item_cfg.color < 4 then
			self.can_strength:SetValue(Language.Forge.ColorLimit)
		else
			self.can_strength:SetValue(Language.Forge.CanNotFogrge)
		end
		-- if item_cfg.sub_type == GameEnum.EQUIP_TYPE_XIANGLIAN or item_cfg.sub_type == GameEnum.EQUIP_TYPE_HUSHOU or
		-- 	item_cfg.sub_type == GameEnum.EQUIP_TYPE_JIEZHI then
		-- 	self.can_strength:SetValue(ToColorStr(Language.Forge.SpecialLimit, TEXT_COLOR.RED))
		-- end
		self.is_show_num:SetValue(false)
	else
		local temp_suittype = 1 --服务端的标记(0普通,1史诗,2传说)
		if self.mother_view.suit_type == 1 then --史诗
			temp_suittype = 1
		elseif self.mother_view.suit_type == -1 then --传说
			temp_suittype = 2
		end

		local suit_num = ForgeData.Instance:GetSuitNumByItemId(self.data.item_id, temp_suittype)

		self.is_show_num:SetValue(true)
		if cur_suit_type == 0 then
			self.name:SetValue(item_cfg.name)
			if self.mother_view.suit_type == 1 then
				self.can_strength:SetValue(Language.Forge.CanForgeSS)
			else
				self.can_strength:SetValue(Language.Forge.CanNotFogrge)
				self.is_show_num:SetValue(false)
			end
		elseif cur_suit_type == 1 then
			local suit_name = ForgeData.Instance:GetSuitName(suit_data_cfg.suit_id,1)
			self.name:SetValue(suit_name)
			self.can_strength:SetValue(Language.Forge.CanForgeCS)
		else
			local suit_name = ForgeData.Instance:GetSuitName(suit_data_cfg.suit_id,-1)
			self.name:SetValue(suit_name)
			self.can_strength:SetValue(Language.Forge.ForgeEnd)
		end

		local suit_text = suit_num.." <color='#001828FF'>/ "..suit_data_cfg.total_equip_count.."</color>"
		self.sui_num:SetValue(suit_text)
	end

	if self.mother_view.equip_scroller_select_index == self.data.cell_index then
		self.root_node.toggle.isOn = false
		self.root_node.toggle.isOn = true
	else
		self.root_node.toggle.isOn = false
	end

	local strength_data_cfg = ForgeData.Instance:GetSuitUpLevelCfgByItemId(self.data.item_id)
	if nil ~= strength_data_cfg then
		local cur_num_1, cur_num_2 = ForgeData.Instance:GetCurSuitRockNum(self.data.item_id, self.mother_view.suit_type)
		local rock1_is_enough = ForgeData.Instance:GetItemNumIsEnough(cur_num_1, strength_data_cfg.need_stuff_count_ss)
		local rock2_is_enough = ForgeData.Instance:GetItemNumIsEnough(cur_num_2, strength_data_cfg.need_stuff_count_cq2)
		self.red_point_status = ForgeData.Instance:SetRedPointStatus(rock1_is_enough, rock2_is_enough,self.data.data_index, self.mother_view.suit_type)
		self.show_red_point:SetValue(self.red_point_status)
	else
		self.red_point_status = false
		self.show_red_point:SetValue(false)
	end
end

function EquiCell:OnToggleValueChange(is_on)
	if is_on then
		if self.mother_view.equip_scroller_select_index == self.data.cell_index and not self.mother_view.first_open then
			return
		end
		self.mother_view.first_open = false
		self.mother_view.equip_scroller_select_index = self.data.cell_index
		self.mother_view:SetSelectEquipData(self.data)
		self.show_red_point:SetValue(self.red_point_status)
	end
end

function EquiCell:SetToggleValue(is_on)
	self.root_node.toggle.isOn = is_on
end

----------属性content---------
SuitAttContent = SuitAttContent or BaseClass(BaseCell)

function SuitAttContent:__init()
	self.data = {}
	self.qixue 	= self:FindVariable("qixue")
	self.gongji = self:FindVariable("gongji")
	self.fangyu = self:FindVariable("fangyu")
	self.shanbi = self:FindVariable("shanbi")
	self.baoji 	= self:FindVariable("baoji")
	self.suit_id = self:FindVariable("suit_id")
	self.bind_gray = self:FindVariable("bind_gray")
	self.qixue_percent = self:FindVariable("qixue_percent")
	self.gongji_percent = self:FindVariable("gongji_percent")
	self.fangyu_percent = self:FindVariable("fangyu_percent")
	self.mingzhong_percent = self:FindVariable("mingzhong_percent")
	self.shanbi_percent = self:FindVariable("shanbi_percent")
	self.baoji_percent = self:FindVariable("baoji_percent")
	self.kangbao_percent = self:FindVariable("kangbao_percent")
	self.color = self:FindVariable("color")

	self.qixue_obj = self:FindObj("qixue_obj")
	self.gongji_obj = self:FindObj("gongji_obj")
	self.fangyu_obj = self:FindObj("fangyu_obj")
	self.shanbi_obj = self:FindObj("shanbi_obj")
	self.baoji_obj = self:FindObj("baoji_obj")
	self.qixue_pc_obj = self:FindObj("qixue_pc_obj")
	self.gongji_pc_obj = self:FindObj("gongji_pc_obj")
	self.fangyu_pc_obj = self:FindObj("fangyu_pc_obj")
	self.mingzhong_pc_obj = self:FindObj("mingzhong_pc_obj")
	self.shanbi_pc_obj = self:FindObj("shanbi_pc_obj")
	self.baoji_pc_obj = self:FindObj("baoji_pc_obj")
	self.kangbao_pc_obj = self:FindObj("kangbao_pc_obj")
end

function SuitAttContent:SetData(data, cur_suit_num)
	self:SetActive(false)
	if nil == data then
		return
	end
	self.cur_suit_num = cur_suit_num
	self.data = data
	self:Flush()
end

function SuitAttContent:Flush()
	self:SetActive(true)
	--设置数据
	self.qixue:SetValue(self.data.maxhp)
	self.gongji:SetValue(self.data.gongji)
	self.fangyu:SetValue(self.data.fangyu)
	self.shanbi:SetValue(self.data.shanbi)
	self.baoji:SetValue(self.data.jianren) --暴击力

	if not next(self.data) then
		return
	end
	self.qixue_percent:SetValue((self.data.maxhp_attr or 0) / 100)
	self.gongji_percent:SetValue((self.data.gongji_attr or 0) / 100)
	self.fangyu_percent:SetValue((self.data.fangyu_attr or 0) / 100)
	self.mingzhong_percent:SetValue((self.data.mingzhong_attr or 0) / 100)
	self.shanbi_percent:SetValue((self.data.shanbi_attr or 0) / 100)
	self.baoji_percent:SetValue((self.data.baoji_attr or 0) / 100)
	self.kangbao_percent:SetValue((self.data.jianren_attr or 0) / 100)

	local suit_type = Language.Forge.HuJia
	if self.data.suit_id >= 5134 then
		suit_type = Language.Forge.SHIPIN
	end

	local equip_count = string.format("【%d件】",self.data.equip_count)
	local switch = false
	if self.cur_suit_num < self.data.equip_count then
		--红
		equip_count = equip_count
		switch = false
		self.color:SetValue("#001828")
	else
		equip_count = equip_count
		self.color:SetValue("#0000F1")
		switch = true
	end

	self.suit_id:SetValue(equip_count)
	self.bind_gray:SetValue(switch)
	--数值为0则隐藏
	self.qixue_obj:SetActive(self.data.maxhp ~= 0)
	self.gongji_obj:SetActive(self.data.gongji ~= 0)
	self.fangyu_obj:SetActive(self.data.fangyu ~= 0)
	self.shanbi_obj:SetActive(self.data.shanbi ~= 0)
	self.baoji_obj:SetActive(self.data.jianren ~= 0)

	self.qixue_pc_obj:SetActive(self.data.maxhp_attr ~= 0)
	self.gongji_pc_obj:SetActive(self.data.gongji_attr ~= 0)
	self.fangyu_pc_obj:SetActive(self.data.fangyu_attr ~= 0)
	self.mingzhong_pc_obj:SetActive(self.data.mingzhong_attr ~= 0)
	self.shanbi_pc_obj:SetActive(self.data.shanbi_attr ~= 0)
	self.baoji_pc_obj:SetActive(self.data.baoji_attr ~= 0)
	self.kangbao_pc_obj:SetActive(self.data.jianren_attr ~= 0)
end