MarriageHaloContent = MarriageHaloContent or BaseClass(BaseRender)

local AttrList = {
	"maxhp",
	"gongji",
	"fangyu",
	"mingzhong",
	"shanbi",
	"baoji",
	"jianren",
}
function MarriageHaloContent:__init()
	self.select_index = 1
	self.is_auto_buy_stone = 0
	self.last_level = 9999
	self.last_exp = 9999
	MarriageHaloContent.Instance = self

end

function MarriageHaloContent:__delete()
	if self.my_model then
		self.my_model:DeleteMe()
		self.my_model = nil
	end

	if self.lover_model then
		self.lover_model:DeleteMe()
		self.lover_model = nil
	end

	if self.effect_model then
		self.effect_model:DeleteMe()
		self.effect_model = nil
	end

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	for _, v in pairs(self.attr_cell_list) do
		v:DeleteMe()
	end
	self.attr_cell_list = {}

	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	if self.pro_value_delay then
		GlobalTimerQuest:CancelQuest(self.pro_value_delay)
		self.pro_value_delay = nil
	end
	self.my_level = nil
	self.lover_level = nil
	self.halo_effect = nil
	self.is_active = nil
	self.is_select = nil
	self.show_leftbtn = nil
	self.show_rightbtn = nil
	self.my_name = nil
	self.lover_name = nil
	self.lover_name = nil
	self.mysex_res = nil
	self.loversex_res = nil
	self.halo_name = nil
	self.fight_power = nil
	self.cost_des = nil
	self.pro_des = nil
	self.pro_value = nil
	self.is_max = nil
	self.active_des = nil
	self.is_marry = nil
	self.can_upgrade = nil
	self.notmarry_imgres = nil
	self.list_view = nil
	self.my_model = nil
	self.lover_model = nil
	self.effect_model = nil
end

function MarriageHaloContent:LoadCallBack()
	local my_display = self:FindObj("MyDisplay")
	self.my_model = RoleModel.New("marry_halo_view",600)
	self.my_model:SetDisplay(my_display.ui3d_display)

	local lover_display = self:FindObj("LoverDisPlay")
	self.lover_model = RoleModel.New("marry_halo_view",600)
	self.lover_model:SetDisplay(lover_display.ui3d_display)

	local model_display = self:FindObj("ModelDisPlay")
	self.effect_model = RoleModel.New("marry_halo_effect_view",600)
	self.effect_model:SetDisplay(model_display.ui3d_display)
		--属性列表
	self.attr_cell_list = {}
	for K, v in ipairs(AttrList) do
		local cell = MarryHaloAttrCell.New(self:FindObj("Attr" .. K))
		self.attr_cell_list[v] = cell
	end

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))

	self.list_data = {}
	self.cell_list = {}
	self.list_view = self:FindObj("ListView")
	self.list_view_width = self.list_view.rect.rect.width
	local scroller_delegate = self.list_view.list_simple_delegate
	self.cell_width = scroller_delegate:GetCellViewSize(self.list_view.scroller, 0)			--单个cell的大小（根据排列顺序对应高度或宽度）
	self.list_spacing = self.list_view.scroller.spacing										--间距
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.list_view.scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChanged, self))

	self.my_level = self:FindVariable("MyLevel")
	self.lover_level = self:FindVariable("LoverLevel")
	self.halo_effect = self:FindVariable("HaloEffect")						--光环特效
	self.is_active = self:FindVariable("IsActive")
	self.is_select = self:FindVariable("IsSelect")
	self.show_leftbtn = self:FindVariable("ShowLeftBtn")
	self.show_rightbtn = self:FindVariable("ShowRightBtn")
	self.my_name = self:FindVariable("MyName")
	self.lover_name = self:FindVariable("LoverName")
	self.lover_name = self:FindVariable("LoverName")
	self.mysex_res = self:FindVariable("MySexRes")							--我的性别资源
	self.loversex_res = self:FindVariable("LoverSexRes")					--伴侣的性别资源
	self.halo_name = self:FindVariable("HaloName")
	self.fight_power = self:FindVariable("FightPower")						--战斗力
	self.cost_des = self:FindVariable("CostDes")							--消耗描述
	self.pro_des = self:FindVariable("ProDes")								--进度条描述
	self.pro_value = self:FindVariable("ProValue")							--进度
	self.is_max = self:FindVariable("IsMax")								--是否已满级
	self.active_des = self:FindVariable("ActiveDes")						--激活描述
	self.is_marry = self:FindVariable("IsMarry")							--是否已结婚
	self.can_upgrade = self:FindVariable("CanUpGrade")						--是否可升级
	self.notmarry_imgres = self:FindVariable("NotMarryImgRes")				--没结婚剪影

	self.show_red = self:FindVariable("show_redpoint")

	self:ListenEvent("ClickSelect", BindTool.Bind(self.ClickSelect, self))
	self:ListenEvent("ClickLeft", BindTool.Bind(self.ClickLeft, self))
	self:ListenEvent("ClickRight", BindTool.Bind(self.ClickRight, self))
	self:ListenEvent("ClickHelp", BindTool.Bind(self.ClickHelp, self))
	self:ListenEvent("ClickLevelUp", BindTool.Bind(self.ClickLevelUp, self))

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
	self:OnFlush()
end


-- 物品不足，购买成功后刷新物品数量
function MarriageHaloContent:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	self:FlushRight()
end

--列表滑动时
function MarriageHaloContent:OnValueChanged(position)
	local x = position.x
	self.show_leftbtn:SetValue(x > 0)
	self.show_rightbtn:SetValue(x < 1)
end

function MarriageHaloContent:GetNumberOfCells()
	return #self.list_data
end

function MarriageHaloContent:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local icon_cell = self.cell_list[cell]
	if nil == icon_cell then
		icon_cell = MarryHaloIconCell.New(cell.gameObject)
		icon_cell:SetToggleGroup(self.list_view.toggle_group)
		icon_cell:SetClickCallBack(BindTool.Bind(self.IconCellClick, self))
		self.cell_list[cell] = icon_cell
	end

	if self.select_index == data_index then
		icon_cell:SetToggleIsOn(true)
	else
		icon_cell:SetToggleIsOn(false)
	end

	icon_cell:SetIndex(data_index)
	icon_cell:SetData(self.list_data[data_index])
end

function MarriageHaloContent:IconCellClick(cell)
	if nil == cell then return end
	cell:SetToggleIsOn(true)
	local data = cell:GetData()
	if nil == data then return end

	local index = cell:GetIndex()
	if index == self.select_index then
		return
	end
	self.select_index = index

	--刷新模型
	self:FlushEffectModel()

	self:FlushLeftContent()
	self:FlushRight(true)
end

function MarriageHaloContent:FlushMyModel()
	if self.my_model then
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local role_vo = {}
		role_vo.prof = main_role_vo.prof
		role_vo.sex = main_role_vo.sex
		role_vo.appearance = {}
		local model_data =  MarriageData.Instance:GetModelCfgById(role_vo.prof)
		role_vo.appearance.fashion_wuqi = model_data.weapon_model
		role_vo.appearance.fashion_body = model_data.role_model
		self.my_model:SetModelResInfo(role_vo, true)
	end
end

function MarriageHaloContent:FlushLoverModel()
	if self.lover_model then
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		if main_role_vo.lover_uid > 0 then
			local lover_vo = {}
			lover_vo.prof = MarriageData.Instance:GetLoverProf()
			lover_vo.sex = main_role_vo.sex == 0 and 1 or 0
			lover_vo.appearance = {}
			local model_data =  MarriageData.Instance:GetModelCfgById(lover_vo.prof)
			lover_vo.appearance.fashion_wuqi = model_data.weapon_model
			lover_vo.appearance.fashion_body = model_data.role_model
			self.lover_model:SetModelResInfo(lover_vo, true)
		end
	end
end

function MarriageHaloContent:FlushRoleContent()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()

	--设置我的信息
	local level = main_role_vo.level
	local lv, zhuan = PlayerData.GetLevelAndRebirth(level)
	local level_des = string.format(Language.Common.LevelFormat, lv, zhuan)
	self.my_level:SetValue(level_des)
	self.my_name:SetValue(main_role_vo.name)
	local bundle, asset = ResPath.GetSexRes(main_role_vo.sex)
	self.mysex_res:SetAsset(bundle, asset)

	--设置伴侣的信息
	local lover_level_des = ""
	if main_role_vo.lover_uid > 0 then
		lv, zhuan = PlayerData.GetLevelAndRebirth(MarriageData.Instance:GetLoverLevel())
		lover_level_des = string.format(Language.Common.LevelFormat, lv, zhuan)
		local lover_sex = main_role_vo.sex == 1 and 0 or 1
		bundle, asset = ResPath.GetSexRes(lover_sex)
		self.loversex_res:SetAsset(bundle, asset)
		self:FlushLoverModel()
	else
		self.loversex_res:ResetAsset()
		local id = main_role_vo.sex == 1 and 1 or 2
		-- self.notmarry_imgres:SetAsset(ResPath.GetMarryRawImage(id))
	end
	self.lover_level:SetValue(lover_level_des)
	self.lover_name:SetValue(main_role_vo.lover_name)
	self.is_marry:SetValue(main_role_vo.lover_uid > 0)
end

function MarriageHaloContent:ClickSelect()
	MarriageCtrl.Instance:SendUpgradeSpirit(QINGYUAN_COUPLE_HALO_REQ_TYPE.QINGYUAN_COUPLE_REQ_TYPE_USE ,self.select_index - 1)
end

function MarriageHaloContent:ClickLeft()
	self.list_view.scroll_rect.horizontalNormalizedPosition = 0
end

function MarriageHaloContent:ClickRight()
	self.list_view.scroll_rect.horizontalNormalizedPosition = 1
end

function MarriageHaloContent:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(225)
end

function MarriageHaloContent:ClickLevelUp()
	local halo_type = self.select_index - 1
	local halo_level = MarriageData.Instance:GetHaloLevelByType(halo_type)
	local halo_info = MarriageData.Instance:GetHaloInfo(halo_type, halo_level)

	local sex = GameVoManager.Instance:GetMainRoleVo().sex
	local item_id = sex == 1 and halo_info.stuff_id or halo_info.stuff_id_woman
	local have_num = ItemData.Instance:GetItemNumInBagById(item_id)

	local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
		MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
		self.is_auto_buy_stone = is_buy_quick and 1 or 0
	end

	if have_num <= 0 and self.is_auto_buy_stone <= 0 then
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
		if item_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(item_id)
			return
		end

		-- if item_cfg.bind_gold == 0 then
		-- 	TipsCtrl.Instance:ShowCommonBuyView(item_id, 2)
		-- 	return
		-- end
		TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, 1)
	else
		MarriageCtrl.Instance:SendUpgradeSpirit(QINGYUAN_COUPLE_HALO_REQ_TYPE.QINGYUAN_COUPLE_REQ_TYPE_UP_LEVEL ,self.select_index - 1,self.is_auto_buy_stone)
	end
end

-- 获取背包是否有材料
function MarriageHaloContent:IsShowItemNumber(index)
	local halo_type = 1
	local halo_level = MarriageData.Instance:GetHaloLevelByType(halo_type)
	local halo_info = MarriageData.Instance:GetHaloInfo(halo_type, halo_level)
	if halo_info == nil then
		return
	end
	local sex = GameVoManager.Instance:GetMainRoleVo().sex
	local item_id = sex == 1 and halo_info.stuff_id or halo_info.stuff_id_woman
	local have_num = ItemData.Instance:GetItemNumInBagById(item_id)
	return have_num > 0
end

function MarriageHaloContent:OnFlush()
	local flag = self:IsShowItemNumber()
	self.show_red:SetValue(flag)
	self:FlushMyModel()
	self:FlushRoleContent()
end

function MarriageHaloContent:FlushListView(is_init)
	self.list_data = MarriageData.Instance:GetCoupleHaloLevelList()
	if is_init then
		local max_width = (self.cell_width + self.list_spacing) * (#self.list_data) - self.list_spacing
		local not_see_width = math.max(max_width - self.list_view_width, 0)
		local bili = 0
		if not_see_width > 0 then
			bili = math.min(((self.cell_width + self.list_spacing) * (self.select_index - 1)) / not_see_width, 1)
		end
		self.list_view.scroller:ReloadData(bili)
	else
		self.list_view.scroller:RefreshActiveCellViews()
	end
end

function MarriageHaloContent:FlushEffectModel()
	if nil == self.effect_model then return end
	local halo_info = MarriageData.Instance:GetHaloInfo(self.select_index - 1, 1)
	if nil ~= halo_info then
		local bundle, asset = ResPath.GetCoupleHaloRes(halo_info.res_id)
		self.effect_model:SetMainAsset(bundle, asset)
		self.effect_model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.COUPLE_HALO], halo_info.res_id, DISPLAY_PANEL.CHUJUN_GIFT_LEFT)
	end
end

function MarriageHaloContent:FlushLeftContent(is_init)
	local used_halo_type = MarriageData.Instance:GetEquipCoupleHaloType()
	local halo_type = self.select_index - 1

	--判断是否选择
	self.is_select:SetValue(used_halo_type == halo_type)

	--判断是否激活
	local halo_level = MarriageData.Instance:GetHaloLevelByType(halo_type)
	local active_level = MarriageData.Instance:GetActiveHaloLevel(halo_type)
	self.is_active:SetValue(halo_level >= active_level)
end

function MarriageHaloContent:FlushLeft(is_init)
	self:FlushListView(is_init)
	self:FlushLeftContent(is_init)
end

function MarriageHaloContent:FlushRight(is_init)
	local halo_type = self.select_index - 1
	local halo_level = MarriageData.Instance:GetHaloLevelByType(halo_type)
	local halo_info = MarriageData.Instance:GetHaloInfo(halo_type, halo_level)
	if halo_info == nil then
		return
	end

	--设置光环名字展示
	local name_des = string.format("Lv.%s %s", halo_level, halo_info.halo_name)
	self.halo_name:SetValue(name_des)

	--设置消耗显示
	local sex = GameVoManager.Instance:GetMainRoleVo().sex
	local item_id = sex == 1 and halo_info.stuff_id or halo_info.stuff_id_woman
	local have_num = ItemData.Instance:GetItemNumInBagById(item_id)
	local cost_num = 1
	local cost_color = TEXT_COLOR.GREEN
	if have_num < cost_num then
		cost_color = TEXT_COLOR.RED
	end
	local cost_des = string.format(Language.Common.CostNumDes, cost_color, have_num, cost_num)
	self.cost_des:SetValue(cost_des)
	self.item_cell:SetData({item_id = item_id, is_bind = 0})

	--设置进度条展示
	local now_exp = MarriageData.Instance:GetHaloExpByType(halo_type)
	local max_exp = halo_info.stuff_count
	self.pro_des:SetValue(string.format("%s/%s", now_exp, max_exp))
	local pro_value = now_exp / max_exp
	if self.last_level ~= halo_level or self.last_exp ~= now_exp then
		if is_init then
			self.pro_value:InitValue(pro_value)
		else
			if pro_value == 0 then
				self.pro_value:SetValue(1)
				if self.pro_value_delay == nil then
					self.pro_value_delay = GlobalTimerQuest:AddDelayTimer(function ()
						self.pro_value:SetValue(pro_value)
						GlobalTimerQuest:CancelQuest(self.pro_value_delay)
						self.pro_value_delay = nil
					end, 0)
				end
			else
				self.pro_value:SetValue(pro_value)
			end
		end
	end
	self.last_level = halo_level
	self.last_exp = now_exp
	
	--设置激活描述
	local is_active_image = halo_info.is_active_image
	local active_str = Language.Marriage.ActiveHaloDes
	local active_color = TEXT_COLOR.GREEN
	--先判断是否有前置光环条件
	local pre_halo_level = halo_info.pre_halo_level
	local above_level_enough = true
	if pre_halo_level > 0 then
		local above_halo_type = halo_type - 1
		local above_halo_level = MarriageData.Instance:GetHaloLevelByType(above_halo_type)
		if above_halo_level < pre_halo_level then
			above_level_enough = false
			local above_halo_info = MarriageData.Instance:GetHaloInfo(above_halo_type, 1)
			if nil ~= above_halo_info then
				active_str = string.format(Language.Marriage.AboveHaloActiveDes, above_halo_info.halo_name, pre_halo_level)
				active_color = TEXT_COLOR.RED
			end
		end
	end
	self.can_upgrade:SetValue(above_level_enough)
	if above_level_enough and is_active_image == 0 then
		local active_level = MarriageData.Instance:GetActiveHaloLevel(halo_type)
		active_str = string.format(Language.Marriage.NotActiveHaloDes, active_level)
		active_color = TEXT_COLOR.RED
	end

	local active_des = ToColorStr(active_str, active_color)
	self.active_des:SetValue(active_des)

	--设置属性描述
	for k, v in pairs(self.attr_cell_list) do
		local value = halo_info[k] or 0
		v:SetData({key = k, value = value})
	end

	--设置战斗力
	local capability = CommonDataManager.GetCapabilityCalculation(halo_info)
	self.fight_power:SetValue(capability)

	--判断是否已满级
	local next_halo_info = MarriageData.Instance:GetHaloInfo(halo_type, halo_level + 1)
	if next_halo_info == nil then
		self.is_max:SetValue(true)
		self.cost_des:SetValue("-/-")
		self.pro_des:SetValue("-/-")
		self.pro_value:InitValue(1)
	else
		self.is_max:SetValue(false)
	end
end

function MarriageHaloContent:InitView()
	--初始化的时候默认选中已装备的光环
	local equip_halo_type = MarriageData.Instance:GetEquipCoupleHaloType()
	self.select_index = equip_halo_type > 0 and equip_halo_type + 1 or 1

	self:FlushLeft(true)
	self:FlushLoverModel()
	self:FlushRight(true)
	self:FlushEffectModel()
end

function MarriageHaloContent:FlushView()
	self:FlushLeft()
	self:FlushRight()
end

----------------------------MarryHaloIconCell-----------------------------
MarryHaloIconCell = MarryHaloIconCell or BaseClass(BaseCell)
function MarryHaloIconCell:__init()
	self.res = self:FindVariable("Res")
	self.show_redpoint = self:FindVariable("ShowRedPoint")
	self.name = self:FindVariable("Name")
	self.is_active = self:FindVariable("IsActive")
	self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))
end

function MarryHaloIconCell:__delete()

end

function MarryHaloIconCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function MarryHaloIconCell:SetToggleIsOn(is_on)
	self.root_node.toggle.isOn = is_on
end

function MarryHaloIconCell:OnFlush()
	if self.data == nil then
		return
	end

	local level = self.data
	local halo_type = self.index - 1
	local halo_info = MarriageData.Instance:GetHaloInfo(halo_type, level)
	if nil ~= halo_info then
		local res_id = halo_info.res_id
		self.res:SetAsset(ResPath.GetMarryImage("FQGH_0" .. res_id))

		self.name:SetValue(halo_info.halo_name)
		self.is_active:SetValue(halo_info.is_active_image == 1)
		
		--判断是否该显示红点
		local is_show = false
		local sex = GameVoManager.Instance:GetMainRoleVo().sex
		local item_id = sex == 1 and halo_info.stuff_id or halo_info.stuff_id_woman
		if ItemData.Instance:GetItemNumInBagById(item_id) > 0 then
			--先判断是否满级
			local next_halo_info = MarriageData.Instance:GetHaloInfo(halo_type, level + 1)
			if nil ~= next_halo_info then				--判断是否存在下一级光环属性
				--前置光环是否达到等级
				local pre_halo_level = halo_info.pre_halo_level
				if pre_halo_level > 0 then
					local above_halo_type = halo_type - 1
					local above_halo_level = MarriageData.Instance:GetHaloLevelByType(above_halo_type)
					if above_halo_level >= pre_halo_level then
						is_show = true
					end
				else
					is_show = true
				end
			end
		end
		self.show_redpoint:SetValue(is_show)
	end
end

----------------------------MarryHaloAttrCell-----------------------------
MarryHaloAttrCell = MarryHaloAttrCell or BaseClass(BaseCell)
function MarryHaloAttrCell:__init()
	-- self.attr_icon = self:FindVariable("AttrIcon")
	self.attr_des = self:FindVariable("AttrDes")
end

function MarryHaloAttrCell:__delete()

end

function MarryHaloAttrCell:OnFlush()
	if self.data == nil then
		return
	end

	-- self.attr_icon:SetAsset(ResPath.GetBaseAttrIcon(self.data.key))

	local attr_name = Language.Common.AttrNameNoUnderline[self.data.key] or ""
	local attr_des = attr_name .. ":" .. ToColorStr(self.data.value, TEXT_COLOR.GREEN)
	self.attr_des:SetValue(attr_des)
end