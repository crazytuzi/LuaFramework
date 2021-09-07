MagicContentView = MagicContentView or BaseClass(BaseRender)

-- 常量定义
local BAG_MAX_GRID_NUM = 40
local BAG_ROW = 2
local BAG_COLUMN = 5

function MagicContentView:__init(instance)
	MagicContentView.Instance 		= self

	self.recycle_view 				= self:FindObj("recycle_view")
	self.bag_list_view 				= self:FindObj("PackListView")
	self.weapon_stage_now 			= self:FindObj("weapon_stage_now")

	self.chip_level 				= self:FindVariable("chip_level")
	self.chip_fight_power 			= self:FindVariable("chip_fight_power")
	self.chip_progress 				= self:FindVariable("chip_progress")
	self.level_up_exp 				= self:FindVariable("level_up_exp")
	self.exp_slider 				= self:FindVariable("exp_slider")

	self.magic_name_now 			= self:FindVariable("magic_name_now")
	self.magic_name_will 			= self:FindVariable("magic_name_will")
	self.fight_power_now 			= self:FindVariable("fight_power_now")
	self.fight_power_will 			= self:FindVariable("fight_power_will")
	self.level_now 					= self:FindVariable("level_now")
	self.level_will 				= self:FindVariable("level_will")

	self.melt_att_1 				= self:FindVariable("melt_att_1")
	self.melt_att_2 				= self:FindVariable("melt_att_2")
	self.melt_att_3 				= self:FindVariable("melt_att_3")
	self.melt_att_4 				= self:FindVariable("melt_att_4")
	self.melt_name_1 				= self:FindVariable("melt_name_1")
	self.melt_name_2 				= self:FindVariable("melt_name_2")
	self.melt_name_3 				= self:FindVariable("melt_name_3")
	self.melt_name_4 				= self:FindVariable("melt_name_4")
	self.is_max 					= self:FindVariable("is_max")

	self.all_weapon_level_list 		= MagicWeaponData.Instance:GetAllWeaponLevelList() or {}
	self.weapon_level 				= self.all_weapon_level_list[1] or 0
	self.weapon_name 				= ""
	self.weapon_fight_power 		= MagicWeaponData.Instance:GetEquipCapacity(0, self.weapon_level)
	self.index = 1

	local list_delegate 			= self.bag_list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel 	= BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel 	= BindTool.Bind(self.BagRefreshCell, self)
	self.magic_cells = {}

	self:ListenEvent("magic_weapon1", BindTool.Bind(self.MagicWeapon1OnClick, self))
	self:ListenEvent("magic_weapon2", BindTool.Bind(self.MagicWeapon2OnClick, self))
	self:ListenEvent("magic_weapon3", BindTool.Bind(self.MagicWeapon3OnClick, self))
	self:ListenEvent("magic_weapon4", BindTool.Bind(self.MagicWeapon4OnClick, self))
	self:ListenEvent("magic_weapon5", BindTool.Bind(self.MagicWeapon5OnClick, self))
	self:ListenEvent("magic_weapon6", BindTool.Bind(self.MagicWeapon6OnClick, self))
	self:ListenEvent("level_up", BindTool.Bind( self.LevelUpOnClick, self))
	self:ListenEvent("smelt", BindTool.Bind( self.SmeltOnClick, self))
	self:ListenEvent("back", BindTool.Bind(self.CallBackOnClick, self))
	self:ListenEvent("ghost_smelt", BindTool.Bind(self.GhostSmeltOnClick, self))
	self:ListenEvent("click_help",BindTool.Bind(self.HelpOnClick, self))

	self.flush_bag_view = GlobalEventSystem:Bind(OtherEventType.FLUSH_MAGIC_BAG, BindTool.Bind(self.FlushBagView, self))

	self.dis_modle_list = {}
	--魔器位置列表
	self.magic_weapon_pos_list = {}
	self.magic_weapon_display_list = {}
	for i = 1, 8 do
		local display = self:FindObj("model"..i)
		local dis_modle = RoleModel.New()
		dis_modle:SetDisplay(display.ui3d_display)
		self.dis_modle_list[i] = dis_modle
		self.magic_weapon_display_list[i] = display

		local pos = display.rect.localPosition
		table.insert(self.magic_weapon_pos_list, pos)
	end

	self.magic_name_list = {}
	self.magic_level_list = {}
	for i = 1, 6 do
		local item_id = MagicWeaponData.Instance:GetWeaponCfgById(i).item_id
		local magic_cfg = ItemData.Instance:GetItemConfig(item_id)
		local magic_name = self:FindVariable("magic_name"..i)
		magic_name:SetValue(magic_cfg.name)
		self.magic_name_list[i] = magic_cfg.name
		local level = self:FindVariable("level_"..i)
		self.magic_level_list[i] = level
	end

	self.chip_item_list = {}
	for i = 1, 3 do
		local item_cell = ItemCell.New(self:FindObj("item_" .. i))
		self.chip_item_list[i] = item_cell

		local item_callback = function ()
			item_cell:ShowHighLight(false)
		end

		local click_func = function ()
			if item_cell.data ~= nil then
				item_cell:ShowHighLight(true)
				TipsCtrl.Instance:OpenItem(item_cell.data,nil ,nil, item_callback)
			end
		end

		item_cell:ListenClick(click_func, i)
	end

	self.move_end = true
end

function MagicContentView:__delete()
	for _, v in pairs(self.dis_modle_list) do
		v:DeleteMe()
	end
	self.dis_modle_list = {}

	if self.magic_cells ~= nil then
		for k, v in pairs(self.magic_cells) do
			v:DeleteMe()
		end
	end

	if self.flush_bag_view ~= nil then
		GlobalEventSystem:UnBind(self.flush_bag_view)
		self.flush_bag_view = nil
	end
	self.magic_cells = nil
end

function MagicContentView:OpenCallBack()
	self:MagicWeapon1OnClick()
	for k, v in pairs(self.dis_modle_list) do
		v:SetMainAsset(ResPath.GetSpiritModel(10001001))
	end
	self:FlushBagView()
end

function MagicContentView:GetBagListView()
	return self.bag_list_view
end

function MagicContentView:HelpOnClick()
	local tips_id = 50 -- 魔器帮助
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function MagicContentView:BagGetNumberOfCells()
	return BAG_MAX_GRID_NUM / BAG_ROW
end

function MagicContentView:BagRefreshCell(cell, data_index)
	local group = self.magic_cells[cell]
	if group == nil  then
		group = MagicBagGroup.New(cell.gameObject)
		self.magic_cells[cell] = group
	end
	group:SetToggleGroup(self.bag_list_view.toggle_group)
	local page = math.floor(data_index / BAG_COLUMN)
	local column = data_index - page * BAG_COLUMN
	local grid_count = BAG_COLUMN * BAG_ROW
	for i = 1, 2 do
		local index = (i - 1) * BAG_COLUMN + column + (page * grid_count)
		local data = MagicWeaponData.Instance:GetMagicWeaponCellData(index+1)
		data.locked = false
		if data.index == nil then
			data.index = index
		end

		group:SetData(i, data)
		group:ShowHighLight(i, not data.locked)
		group:SetHighLight(i, (self.cur_bag_index == index and nil ~= data.item_id))
		group:ListenClick(i, BindTool.Bind(self.HandleBagOnClick, self, data, group, i, index))
		group:SetInteractable(i, nil ~= data.item_id)
	end
end

function MagicContentView:FlushBagView()
	self.bag_list_view.scroller:RefreshActiveCellViews()
	-- if nil == self.bag_list_view.scroller.isActiveAndEnabled then
	-- 	return
	-- end
	-- if self.bag_list_view.scroller.isActiveAndEnabled then
	-- 	self.bag_list_view.scroller:RefreshActiveCellViews()
	-- end
end

function MagicContentView:ResetModelPos()
	for i=1,6 do
		local position = self.magic_weapon_pos_list[i]
		self.magic_weapon_display_list[i].rect:SetLocalPosition(position.x, position.y, 0)
		self.magic_weapon_display_list[i].rect:SetLocalScale(1.5, 1.5, 1.5)
	end
end

function MagicContentView:FlushFlyAni(index)
	local cur_pos = self.magic_weapon_display_list[index].rect.localPosition
	if cur_pos.x == 0 and cur_pos.y == 0 then
		return
	end

	if not self.move_end then
		return
	end
	self.move_end = false
	if self.tweener then
		self.tweener:Pause()
	end

	self:ResetModelPos()

	local position = self.magic_weapon_pos_list[index]

	local target_pos = {x = 0, y = 0, z = 0}
	local target_scale = Vector3(2, 2, 2)
	self.tweener = self.magic_weapon_display_list[index].rect:DOAnchorPos(target_pos, 0.3, false)
	self.tweener = self.magic_weapon_display_list[index].rect:DOScale(target_scale, 0.3)
	self.tweener:OnComplete(BindTool.Bind(self.OnMoveEnd, self))

end

function MagicContentView:OnMoveEnd()
	self.move_end = true
end

--点击格子事件
function MagicContentView:HandleBagOnClick(data, group, group_index, data_index)
	local page = math.ceil((data.index + 1) / BAG_COLUMN)
	if data.locked then
		print("格子已锁")
		return
	end
	self.cur_bag_index = data_index
	group:SetHighLight(group_index, self.cur_bag_index == index)
	-- 弹出面板
	local item_cfg1, big_type1 = ItemData.Instance:GetItemConfig(data.item_id)
	local callback = function (index)
		if nil ~= index and index <= 6 then
			self:FlushMagicWeaponInfo(index)
			self:FlushFlyAni(index)
		end
		self:FlushBagView()
		group:SetHighLight(group_index, false)

	end
	if nil ~= item_cfg1 then
		group:SetHighLight(group_index, true)
		TipsCtrl.Instance:OpenItem(data,TipsFormDef.FROM_BAG,nil,callback)
	end
end

function MagicContentView:FlushMagicWeaponInfo(index)
	self.index 				= index
	self.weapon_level 		= MagicWeaponData.Instance:GetAllWeaponLevelList()[index-1] or 0
	self.weapon_name 		= self.magic_name_list[index]

	self:FlushModelView()

	self:FlushLeftModelInfo()
end

--获取当前点击的魔器信息
function MagicContentView:MagicWeapon1OnClick()
	self:FlushMagicWeaponInfo(1)
	self:FlushFlyAni(1)
end
function MagicContentView:MagicWeapon2OnClick()
	self:FlushMagicWeaponInfo(2)
	self:FlushFlyAni(2)
end
function MagicContentView:MagicWeapon3OnClick()
	self:FlushMagicWeaponInfo(3)
	self:FlushFlyAni(3)
end
function MagicContentView:MagicWeapon4OnClick()
	self:FlushMagicWeaponInfo(4)
	self:FlushFlyAni(4)
end
function MagicContentView:MagicWeapon5OnClick()
	self:FlushMagicWeaponInfo(5)
	self:FlushFlyAni(5)
end
function MagicContentView:MagicWeapon6OnClick()
	self:FlushMagicWeaponInfo(6)
	self:FlushFlyAni(6)
end

function MagicContentView:FlushLeftModelInfo()
	local weapon_level_info = MagicWeaponData.Instance:GetAllWeaponLevelList()
	for i = 1, 6 do
		self.magic_level_list[i]:SetValue(weapon_level_info[i - 1])
	end
end

function MagicContentView:FlushModelView()
	--名字刷新
	self.magic_name_now:SetValue( self.weapon_name)
	self.magic_name_will:SetValue( self.weapon_name)
	--等级刷新
	self.level_now:SetValue( self.weapon_level)
	self.level_will:SetValue( self.weapon_level + 1)

	--模型刷新

	--战力刷新
	local is_not_max_level = self.weapon_level < GameEnum.EQUIP_MAX_LEVEL
	self.is_max:SetValue(not is_not_max_level)
	local capacity_now = MagicWeaponData.Instance:GetEquipCapacity(self.index-1, self.weapon_level)
	if is_not_max_level then
		local capacity_will = MagicWeaponData.Instance:GetEquipCapacity(self.index-1, self.weapon_level + 1)
		self.fight_power_now:SetValue( capacity_now)
		self.fight_power_will:SetValue( capacity_will)
		self.weapon_stage_now.rect:SetLocalPosition(-155, 0, 0)
	else
	--移动展示模型到中间
		self.fight_power_now:SetValue( capacity_now)
		self.weapon_stage_now.rect:SetLocalPosition(0, 0, 0)
	end
end

--升级
function MagicContentView:LevelUpOnClick()
	local weapon_info = MagicWeaponData.Instance:GetWeaponInfoById(self.index)
	if nil ~= weapon_info and weapon_info.num > 0 then
		--升一级，并消耗一个魔器
		-- MagicWeaponCtrl.Instance:SendMagicLevelUpReq(SHENZHOU_WEAPON_REQ_TYPE.SHENZHOU_WEAPON_REQ_TYPE_UPGRADE_WEAPON, self.index, 0, 0)
		PackageCtrl.Instance:SendUseItem(weapon_info.index, 1)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Exchange.NotEnoughItem)
	end
end

--熔炼
function MagicContentView:SmeltOnClick()
	self.recycle_view:SetActive(true)
	self:FlushRecycleView()
end

function MagicContentView:FlushRecycleView()
	local melt_level = MagicWeaponData.Instance:GetMetlLevel()
	local melt_level_cfg = MagicWeaponData.Instance:GetMeltLevelCfgByLevel(melt_level)
	--设置熔炼属性
	self.melt_att_1:SetValue(melt_level_cfg.maxhp)
	self.melt_att_2:SetValue(melt_level_cfg.gongji)
	self.melt_att_3:SetValue(melt_level_cfg.fangyu)
	self.melt_att_4:SetValue(melt_level_cfg.fujiashanghai)
	self.melt_name_1:SetValue(Language.Common.AttrName.max_hp)
	self.melt_name_2:SetValue(Language.Common.AttrName.gong_ji)
	self.melt_name_3:SetValue(Language.Common.AttrName.fang_yu)
	self.melt_name_4:SetValue(Language.Common.AttrName.per_pofang)

	--设置熔炼item
	for i = 1, 3 do
		local weapon_info = MagicWeaponData.Instance:GetWeaponInfoById(i + 6)
		local total_num = MagicWeaponData.Instance:GetWeaponTotalNumById(i + 6)
		if nil ~= weapon_info then
			weapon_info.num = total_num
			weapon_info.bind = true
		end
		self.chip_item_list[i]:SetData(weapon_info)
	end

	--设置熔炼进度
	local capacity = MagicWeaponData.Instance:GetMeltCapacity(melt_level)
	local upgrade_need_exp = melt_level_cfg.upgrade_need_exp
	local melt_exp = MagicWeaponData.Instance:GetMeltExp()
	self.chip_level:SetValue(melt_level)
	self.chip_fight_power:SetValue(capacity)
	self.chip_progress:SetValue(melt_exp)
	self.level_up_exp:SetValue(upgrade_need_exp)
	local slider_persent = melt_exp/upgrade_need_exp
	if slider_persent > 1 then
		slider_persent = slider_persent - 1
	end
	self.exp_slider:SetValue(slider_persent)
end

function MagicContentView:CallBackOnClick()
	self.recycle_view:SetActive(false)
end

--一键熔炼
function MagicContentView:GhostSmeltOnClick()
	MagicWeaponCtrl.Instance:SendMagicLevelUpReq(SHENZHOU_WEAPON_REQ_TYPE.SHENZHOU_WEAPON_REQ_TYPE_ONE_KEY_RECYCLE)
end

--------------------------------------------
-- 背包格子
MagicBagGroup = MagicBagGroup or BaseClass(BaseRender)

function MagicBagGroup:__init(instance)
	self.cells = {}
	for i = 1, 2 do
		self.cells[i] = ItemCell.New(self:FindObj("Item"..i))
	end
end

function MagicBagGroup:SetData(i, data)
	self.cells[i]:SetData(data)
end

function MagicBagGroup:ListenClick(i, handler)
	self.cells[i]:ListenClick(handler)
end

function MagicBagGroup:SetToggleGroup(toggle_group)
	self.cells[1]:SetToggleGroup(toggle_group)
	self.cells[2]:SetToggleGroup(toggle_group)
end

function MagicBagGroup:SetHighLight(i, enable)
	self.cells[i]:SetHighLight(enable)
end

function MagicBagGroup:ShowHighLight(i, enable)
	self.cells[i]:ShowHighLight(enable)
end

function MagicBagGroup:SetInteractable(i, enable)
	self.cells[i]:SetInteractable(enable)
end