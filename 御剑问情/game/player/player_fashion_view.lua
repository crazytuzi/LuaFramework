------------------------------------------------------------
--人物时装View
------------------------------------------------------------
PlayerFashionView = PlayerFashionView or BaseClass(BaseRender)

function PlayerFashionView:__init()
	self:InitScroller()

	self.scroller_select_number = 0
	self.scroller_select_type = SHIZHUANG_TYPE.BODY

	--绑定toggle按钮
	self.btn_clothes = self:FindObj("Btn-Clothes")
	self.btn_clothes.toggle:AddValueChangedListener(BindTool.Bind(self.ChangePage, self, SHIZHUANG_TYPE.BODY))
	self.btn_weapon = self:FindObj("Btn-Weapon")
	self.btn_weapon.toggle:AddValueChangedListener(BindTool.Bind(self.ChangePage, self, SHIZHUANG_TYPE.WUQI))

	--总属性按钮
	self:ListenEvent("ShowAttrTips", BindTool.Bind(self.ShowAttrTips, self))
	self:ListenEvent("DressClick", BindTool.Bind(self.DressClick, self))
	self:ListenEvent("UnLoadClick", BindTool.Bind(self.OnUnLoadClick, self))
	self:ListenEvent("OnClickJinjie", BindTool.Bind(self.OnClickJinjie, self))

	--按钮
	self.is_active = self:FindVariable("IsActive")
	self.is_can_dress = self:FindVariable("IsDressed")

	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.temp_vo = {prof = vo.prof, sex = vo.sex, appearance = {}, wuqi_color = vo.wuqi_color}
	for k,v in pairs(vo.appearance) do
		self.temp_vo.appearance[k] = v
	end
	self.temp_vo.appearance.halo_used_imageid = 0
	self.temp_vo.appearance.wing_used_imageid = 0

	self.select_fashion = {}
	-- self.apperance_change = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_APPERANCE_CHANGE, BindTool.Bind(self.FlushApperance, self))

	self.show_jinjie_red_point = self:FindVariable("ShowJinjieRedPoint")
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.PlayerFashion)

	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)

	self.prefab_preload_id = 0
end

function PlayerFashionView:__delete()
	if self.apperance_change then
		GlobalEventSystem:UnBind(self.apperance_change)
		self.apperance_change = nil
	end
	if FashionCtrl.Instance ~= nil then
		FashionCtrl.Instance:UnNotifyWhenFashionChange(self.flush_callback)
		self.flush_callback = nil
	end

	RemindManager.Instance:UnBind(self.remind_change)

	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
end

function PlayerFashionView:CloseCallBack()
	self.res_id = nil
	self.weapon_id = nil
	self.cur_cfg_list = {}

	if FashionCtrl.Instance ~= nil then
		FashionCtrl.Instance:UnNotifyWhenFashionChange(self.flush_callback)
		self.flush_callback = nil
	end
end

function PlayerFashionView:OnClickJinjie()
	ViewManager.Instance:Open(ViewName.PlayerFashionHuanhua, TabIndex.fashion_clothe_jinjie)
end

--初始化滚动条
function PlayerFashionView:InitScroller()
	self.scroller_data = FashionData.Instance:GetAllFashionConfigByType(SHIZHUANG_TYPE.BODY)
	self.cell_list = {}
	self.scroller = self:FindObj("Scroller")

	self.list_view_delegate = ListViewDelegate()
	PrefabPool.Instance:Load(AssetID("uis/views/player_prefab", "FashionItem"), function (prefab)
		if nil == prefab then
			return
		end

		local enhanced_cell_type = prefab:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))
		self.enhanced_cell_type = enhanced_cell_type
		self.scroller.scroller.Delegate = self.list_view_delegate

		self.list_view_delegate.numberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
		self.list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
		self.list_view_delegate.cellViewDel = BindTool.Bind(self.GetCellView, self)

		PrefabPool.Instance:Free(prefab)
	end)
end

--滚动条数量
function PlayerFashionView:GetNumberOfCells()
	return #self.scroller_data
end

--滚动条大小
function PlayerFashionView:GetCellSize()
	return 152
end

--滚动条刷新
function PlayerFashionView:GetCellView(scroller, data_index, cell_index)
	local cell_view = scroller:GetCellView(self.enhanced_cell_type)
	data_index = data_index + 1
	local cell = self.cell_list[cell_view]
	if cell == nil then
		self.cell_list[cell_view] = PlayerFashionCell.New(cell_view.gameObject)
		cell = self.cell_list[cell_view]
		cell.fashion_view = self
		cell.root_node.toggle.group = self.scroller.toggle_group
	end
	cell:SetData(self.scroller_data[data_index])
	return cell_view
end

function PlayerFashionView:OpenCallBack()
	self.res_id = nil
	self.weapon_id = nil
	self.cur_cfg_list = {}
	self.scroller_data = FashionData.Instance:GetAllFashionConfigByType(SHIZHUANG_TYPE.BODY)
	if self.scroller_select_type == SHIZHUANG_TYPE.BODY then
		self.scroller_select_number = GameVoManager.Instance:GetMainRoleVo().appearance.fashion_body
	else
		self.scroller_select_number = GameVoManager.Instance:GetMainRoleVo().appearance.fashion_wuqi
	end
 	self.scroller.scroller:ReloadData(0)
	self:ClearTempVo()
	-- 绑定刷新函数
	self.flush_callback = BindTool.Bind(self.FlushFashion, self)
	FashionCtrl.Instance:NotifyWhenFashionChange(self.flush_callback)

	self.btn_clothes.toggle.isOn = true
end


--总属性面板
function PlayerFashionView:ShowAttrTips()
	local data = FashionData.Instance:GetFashionTotalAttribute()
	TipsCtrl.Instance:ShowFashionAttrView(data["gong_ji"],data["fang_yu"],data["max_hp"],data.power, Language.Player.FashionAttrName);
end

--数据改变时刷新
function PlayerFashionView:FlushFashion()
	if self.scroller_select_type == SHIZHUANG_TYPE.BODY then
		self.scroller_select_number = GameVoManager.Instance:GetMainRoleVo().appearance.fashion_body
	else
		self.scroller_select_number = GameVoManager.Instance:GetMainRoleVo().appearance.fashion_wuqi
	end
	self.scroller_data = FashionData.Instance:GetAllFashionConfigByType(self.scroller_select_type)
	self.scroller.scroller:ReloadData(0)
	self:FlushApperance()
	if self.cur_choosen_data ~= nil then
		self:FLushButtonState(self.cur_choosen_data)
	end
end

--按下穿戴
function PlayerFashionView:DressClick()
	if self.select_fashion[SHIZHUANG_TYPE.BODY] then
		FashionCtrl.Instance:SendShizhuangUseReq(SHIZHUANG_TYPE.BODY, self.select_fashion[SHIZHUANG_TYPE.BODY])
	elseif self.scroller_select_type == SHIZHUANG_TYPE.BODY then
		TipsCtrl.Instance:ShowSystemMsg(Language.Role.PleaseSelectFashion)
	end
	if self.select_fashion[SHIZHUANG_TYPE.WUQI] then
		FashionCtrl.Instance:SendShizhuangUseReq(SHIZHUANG_TYPE.WUQI, self.select_fashion[SHIZHUANG_TYPE.WUQI])
	elseif self.scroller_select_type == SHIZHUANG_TYPE.WUQI then
		TipsCtrl.Instance:ShowSystemMsg(Language.Role.PleaseSelectWeapon)
	end
end

--按下卸下
function PlayerFashionView:OnUnLoadClick()
	FashionCtrl.Instance:SendShizhuangUseReq(self.scroller_select_type, 0)
	self.select_fashion[self.scroller_select_type] = nil
end

-- 根据Toggle按钮改变时装页面
function PlayerFashionView:ChangePage(select_type,isOn)
	if isOn then
		self.scroller_select_type = select_type
		if select_type == SHIZHUANG_TYPE.BODY then
			self.scroller_select_number = GameVoManager.Instance:GetMainRoleVo().appearance.fashion_body
		else
			self.scroller_select_number = GameVoManager.Instance:GetMainRoleVo().appearance.fashion_wuqi
		end
		self.scroller_data = FashionData.Instance:GetAllFashionConfigByType(select_type)
		if self.scroller.scroller.isActiveAndEnabled then
			self.scroller.scroller:ReloadData(0)
		end
	end
end

function PlayerFashionView:ClearTempVo()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.temp_vo = {prof = vo.prof, sex = vo.sex, appearance = {}, wuqi_color = vo.wuqi_color}
	for k,v in pairs(vo.appearance) do
		self.temp_vo.appearance[k] = v
	end
	self.temp_vo.appearance.halo_used_imageid = 0
	self.temp_vo.appearance.wing_used_imageid = 0
	self.select_fashion = {}
end

-- 时装滚动条格子被点选时
function PlayerFashionView:OnListCellSelect(data)
	self.cur_choosen_data = data
	self.scroller_select_number = data.index
	local is_active = FashionData.Instance:CheckIsActive(data.part_type, data.index)
	local is_dressed = FashionData.Instance:CheckIsDressed(data.part_type, data.index)
	self.is_active:SetValue(is_active)
	self.is_can_dress:SetValue(is_dressed)
	self:PreView(data)
end

function PlayerFashionView:FLushButtonState(data)
	self.cur_choosen_data = data
	

	local is_active = FashionData.Instance:CheckIsActive(data.part_type, data.index)
	local is_dressed = FashionData.Instance:CheckIsDressed(data.part_type, data.index)
	if self.scroller_select_number == 0 then
		is_active = false
	end
	self.is_active:SetValue(is_active)
	self.is_can_dress:SetValue(is_dressed)
end

-- 预览
function PlayerFashionView:PreView(data)
	if data.part_type == SHIZHUANG_TYPE.WUQI then
		self.temp_vo.appearance.fashion_wuqi = data.index
	elseif data.part_type == SHIZHUANG_TYPE.BODY then
		self.temp_vo.appearance.fashion_body = data.index
	end
	local cfg = data
	local weapon_res_id = self.weapon_id or 0
	local res_id = self.res_id or 0
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	local main_role = Scene.Instance:GetMainRole()

	if data.part_type == SHIZHUANG_TYPE.WUQI then
		if res_id == 0 then
			res_id = main_role:GetRoleResId()
		end
		weapon_res_id = cfg["resouce"..game_vo.prof..game_vo.sex]
		local temp = Split(weapon_res_id, ",")
		weapon_res_id = temp[1]
		weapon2_res_id = temp[2]
	elseif data.part_type == SHIZHUANG_TYPE.BODY then
		res_id = cfg["resouce"..game_vo.prof..game_vo.sex]
		if weapon_res_id == 0 then
			weapon_res_id = main_role:GetWeaponResId()
		end
	end

	--if self.res_id ~= res_id or self.weapon_id ~= weapon_res_id then

		PlayerCtrl.Instance:FlushFashionRes(res_id, weapon_res_id)
	--end

	self.res_id = res_id
	self.weapon_id = weapon_res_id

	local weaponn_res_id, weapon2_res_id, role_res_id = self:GetResIds()
	local bundle_1, asset_1 = ResPath.GetWeaponModel(weaponn_res_id)
	local bundle_2, asset_2 = ResPath.GetRoleModel(role_res_id)
	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local load_list = {{bundle_1, asset_1}, {bundle_2, asset_2}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
			UIScene:SetRoleModelResInfo(self.temp_vo, 1, false, true, true)
		end)

	self.select_fashion[data.part_type] = data.index
end

function PlayerFashionView:FlushApperance()
	self:ClearTempVo()

	local weapon_res_id, weapon2_res_id, role_res_id = self:GetResIds()
	local bundle_1, asset_1 = ResPath.GetWeaponModel(weapon_res_id)
	local bundle_2, asset_2 = ResPath.GetRoleModel(role_res_id)

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local load_list = {{bundle_1, asset_1}, {bundle_2, asset_2}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
			UIScene:SetRoleModelResInfo(self.temp_vo, 1, false, true, true)
		end)
end

function PlayerFashionView:RetButton()
	self.is_active:SetValue(false)
	self.is_can_dress:SetValue(false)
end

function PlayerFashionView:RemindChangeCallBack(remind_name, num)
	self.show_jinjie_red_point:SetValue(num > 0)
end

function PlayerFashionView:GetResIds()
	local appearance = self.temp_vo.appearance
	local prof = self.temp_vo.prof
	local sex = self.temp_vo.sex
	local weapon_res_id, weapon2_res_id, role_res_id = 0, 0, 0
	if appearance ~= nil then
		if appearance.fashion_wuqi ~= 0 then
			local wuqi_cfg = FashionData.Instance:GetFashionConfig(SHIZHUANG_TYPE.WUQI, appearance.fashion_wuqi)
			if wuqi_cfg and not ignore_weapon then
				local cfg = wuqi_cfg["resouce" .. prof .. sex]
				if type(cfg) == "string" then
					local temp_table = Split(cfg, ",")
					if temp_table then
						weapon_res_id = temp_table[1]
						weapon2_res_id = temp_table[2]
					end
				elseif type(cfg) == "number" then
					weapon_res_id = cfg
				end
			end
		end

		if appearance.fashion_body ~= 0 then
			local clothing_cfg = FashionData.Instance:GetFashionConfig(SHIZHUANG_TYPE.BODY, appearance.fashion_wuqi)
			if clothing_cfg then
				local res_id = clothing_cfg["resouce" .. prof .. sex]
				role_res_id = res_id
			end
		end
	end
	-- 最后查找职业表
	local job_cfgs = ConfigManager.Instance:GetAutoConfig("rolezhuansheng_auto").job
	local role_job = job_cfgs[prof]
	if role_job ~= nil then
		if role_res_id == 0 then
			role_res_id = role_job["model" .. sex]
		end
		if not ignore_find then
			if weapon_res_id == 0 then
				weapon_res_id = role_job["right_weapon" .. sex]
			end

			if weapon2_res_id == 0 then
				weapon2_res_id = role_job["left_weapon" .. sex]
			end
		end
	else
		if role_res_id == 0 then
			role_res_id = 1001001
		end
		if not ignore_find then
			if weapon_res_id == 0 then
				weapon_res_id = 900100101
			end
		end
	end

	return weapon_res_id, weapon2_res_id, role_res_id
end

function PlayerFashionView:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "wuqi_color" then
		if self.temp_vo.appearance.fashion_wuqi <= 0 and (nil == self.select_fashion[SHIZHUANG_TYPE.WUQI] or self.select_fashion[SHIZHUANG_TYPE.WUQI] <= 0) then
			self.temp_vo.wuqi_color = value
			local weapon_res_id, weapon2_res_id, role_res_id = self:GetResIds()
			local bundle_1, asset_1 = ResPath.GetWeaponModel(weapon_res_id)
			local bundle_2, asset_2 = ResPath.GetRoleModel(role_res_id)

			PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
			local load_list = {{bundle_1, asset_1}, {bundle_2, asset_2}}
			self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
					UIScene:SetRoleModelResInfo(self.temp_vo, 1, false, true, true)
				end)
		end
	end
end

----------------------------------------------------------------------------
--PlayerFashionCell 		时装滚动条格子
----------------------------------------------------------------------------

PlayerFashionCell = PlayerFashionCell or BaseClass(BaseCell)

function PlayerFashionCell:__init()
	self.fashion_name = self:FindVariable("FashionName")
	self.state = self:FindVariable("State")
	self.power = self:FindVariable("Power")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("BaseCell"))
	self.level = self:FindVariable("Level")
	self.least_time = self:FindVariable("LeastTime")
	self.attr_name_list = {}
	for i = 1, 3 do
		self.attr_name_list[i] = self:FindVariable("AttrName"..i)
	end

	self.attr_list = {}
	for i = 1, 3 do
		self.attr_list[i] = self:FindVariable("Attr"..i)
	end
	self.root_node.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleAcitve,self))
end

function PlayerFashionCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function PlayerFashionCell:OnFlush()
	local base_cfg = FashionData.Instance:GetFashionConfig(self.data.part_type, self.data.index)
	if nil == base_cfg then
		return
	end

	self.fashion_name:SetValue(base_cfg.name)
	local upgrade_info = FashionData.Instance:GetFashionUpgradeInfo()
	local level = upgrade_info[self.data.part_type] and upgrade_info[self.data.part_type].level_list[self.data.index] or 0
	self.level:SetValue(level)
	local item_id = self.data.active_stuff_id
	self.item_cell:SetData({item_id = item_id})

	--0未激活、1已激活、2穿戴中
	local is_dressed = FashionData.Instance:CheckIsDressed(self.data.part_type, self.data.index)
	local is_active = FashionData.Instance:CheckIsActive(self.data.part_type, self.data.index)
	if is_active then
		if is_dressed then
			self.state:SetValue(2)
		else
			self.state:SetValue(1)
		end
	else
		self.state:SetValue(0)
	end
	local grade_power = CommonDataManager.GetCapabilityCalculation(self.data)
	self.power:SetValue(grade_power)

	local count = 1
	local attrs = CommonDataManager.GetAttributteByClass(self.data)
	for k,v in pairs(attrs) do
		if v > 0 then
			self.attr_name_list[count]:SetValue(CommonDataManager.GetAttrName(k)..":")
			self.attr_list[count]:SetValue(v)
			count = count + 1
		end
	end
	if count <= #self.attr_list then
		for i=count,#self.attr_list do
			self.attr_name_list[i]:SetValue("")
			self.attr_list[i]:SetValue("")
		end
	end
	if self.fashion_view.scroller_select_number == self.data.index then
		self.root_node.toggle.isOn = false
		self.root_node.toggle.isOn = true
	else
		self.root_node.toggle.isOn = false
	end
	local time_cfg = FashionData.Instance:GetTimeCfg(self.data.index,self.data.part_type)
	if self.data.index == 10 and time_cfg ~= "" then
		self.least_time:SetValue(string.format(Language.Common.LeastTime2,time_cfg))
	else
		self.least_time:SetValue("")
	end
end

function PlayerFashionCell:OnToggleAcitve(isOn)
	if isOn then
		self.fashion_view:OnListCellSelect(self.data)
	else
		self.fashion_view:RetButton()
	end
end

