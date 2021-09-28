HaloHuanHuaView = HaloHuanHuaView or BaseClass(BaseView)

function HaloHuanHuaView:__init()
	self.ui_config = {"uis/views/advanceview_prefab","HaloHuanHuaView"}
	self.play_audio = true
	self.item_id = 0
	self.index = 1
	self.grade = nil
	self.halo_special_image = nil
	self.res_id = nil
	self.used_imageid = nil
	-- self.view_layer = UiLayer.Pop
	self.cell_list = {}
	self.prefab_preload_id = 0
	self.temp_halo_data = {}
end

function HaloHuanHuaView:LoadCallBack()
	self.expense_cfg = MountData.Instance:GetExpenseCfg()
	self.halo_display = self:FindObj("HaloDisplay")

	self.have_pro_num = self:FindVariable("ActivateProNum")
	self.need_pro_num = self:FindVariable("ExchangeNeedNum")
	self.button_text = self:FindVariable("ButtonText")

	self.gong_ji = self:FindVariable("GongJi")
	self.fang_yu = self:FindVariable("FangYu")
	self.sheng_ming = self:FindVariable("ShengMing")
	-- self.ming_zhong = self:FindVariable("MingZhong")
	-- self.shan_bi = self:FindVariable("ShanBi")
	-- self.bao_ji = self:FindVariable("BaoJi")
	-- self.jian_ren = self:FindVariable("JianRen")
	-- self.zizhi_dan_limit = self:FindVariable("ZiZhiDan")
	self.fight_power = self:FindVariable("FightPower")
	self.get_tujing_1 = self:FindVariable("GetTuJing1")
	self.get_tujing_2 = self:FindVariable("GetTuJing2")
	self.halo_name = self:FindVariable("ZuoQiName")
	self.show_upgrade_btn = self:FindVariable("IsShowUpGrade")
	self.show_activate_btn = self:FindVariable("IsShowActivate")
	self.show_use_ima_btn = self:FindVariable("IsShowUseImaButton")
	self.show_use_image = self:FindVariable("IsShowUseImage")
	self.cur_level = self:FindVariable("CurrentLevel")
	self.show_cur_level = self:FindVariable("ShowCurrentLevel")

	self.halo_model = RoleModel.New("halo_huanhu_panel")
	self.halo_model:SetDisplay(self.halo_display.ui3d_display)

	self:ListenEvent("OnClickActivate",
		BindTool.Bind(self.OnClickActivate, self))
	self:ListenEvent("Close",
		BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickUpGrade",
		BindTool.Bind(self.OnClickUpGrade, self))
	self:ListenEvent("OnClickUseIma",
		BindTool.Bind(self.OnClickUseIma, self))

	self.list_view = self:FindObj("ListView")
	self.upgrade_btn = self:FindObj("UpGradeButton")
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("Item"))

	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetHaloNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshHaloCell, self)
end

function HaloHuanHuaView:__delete()
	self.index = 1
	self.grade = nil
	self.item_id = nil
	self.res_id = nil
	self.halo_special_image = nil
	self.used_imageid = nil
end

function HaloHuanHuaView:ReleaseCallBack()
	if self.halo_model ~= nil then
		self.halo_model:DeleteMe()
		self.halo_model = nil
	end

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.item ~= nil then
		self.item:DeleteMe()
		self.item = nil
	end

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)

	-- 清理变量和对象
	self.halo_display = nil
	self.have_pro_num = nil
	self.need_pro_num = nil
	self.button_text = nil
	self.gong_ji = nil
	self.fang_yu = nil
	self.sheng_ming = nil
	self.fight_power = nil
	self.get_tujing_1 = nil
	self.get_tujing_2 = nil
	self.halo_name = nil
	self.show_upgrade_btn = nil
	self.show_activate_btn = nil
	self.show_use_ima_btn = nil
	self.show_use_image = nil
	self.cur_level = nil
	self.show_cur_level = nil
	self.list_view = nil
	self.upgrade_btn = nil
end

function HaloHuanHuaView:GetHaloNumberOfCells()
	return #self.temp_halo_data
end

function HaloHuanHuaView:RefreshHaloCell(cell, cell_index)
	local halo_cell = self.cell_list[cell]
	if halo_cell == nil then
		halo_cell = HaloHuanHuaCell.New(cell.gameObject)
		self.cell_list[cell] = halo_cell
	end

	halo_cell:SetToggleGroup(self.list_view.toggle_group)
	local data = {}
	data.head_id = self.temp_halo_data[cell_index+1].head_id
	data.image_name = self.temp_halo_data[cell_index+1].image_name
	data.item_id = self.temp_halo_data[cell_index+1].item_id
	data.index = self.temp_halo_data[cell_index+1].image_id
	data.is_show = HaloData.Instance:CanHuanhuaUpgrade()[data.index] ~= nil
	halo_cell:SetData(data)
	halo_cell:SetHighLight(self.index == data.index)
	halo_cell:ListenClick(BindTool.Bind(self.OnClickListCell, self, self.temp_halo_data[cell_index+1], data.index, halo_cell))
end

function HaloHuanHuaView:OnClickClose()
	self:Close()
	self.res_id = nil
	self.grade = nil
	self.used_imageid = nil
end

function HaloHuanHuaView:OpenCallBack()
	self.temp_halo_data = HaloData.Instance:GetHuanHuaHaloCfg()
	if next(self.temp_halo_data) then
		self.index = self.temp_halo_data[1].image_id
	else
		self.index = 1
	end

	self:Flush("halohuanhua")
end

--点击激活按钮
function HaloHuanHuaView:OnClickActivate()
	local data_list = ItemData.Instance:GetBagItemDataList()
	local halo_special_image = ConfigManager.Instance:GetAutoConfig("halo_auto").special_img
	self.item_id = halo_special_image[self.index] and halo_special_image[self.index].item_id or 0
	for k, v in pairs(data_list) do
		if v.item_id == self.item_id then
			PackageCtrl.Instance:SendUseItem(v.index, 1, v.sub_type, 0)
			return
		end
	end
	local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[self.item_id]
	if item_cfg == nil then
		TipsCtrl.Instance:ShowItemGetWayView(self.item_id)
		return
	end

	if item_cfg.bind_gold == 0 then
		TipsCtrl.Instance:ShowShopView(self.item_id, 2)
		return
	end

	local func = function(item_id, item_num, is_bind, is_use)
		MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
	end

	TipsCtrl.Instance:ShowCommonBuyView(func, self.item_id, nil, 1)
	return
	-- TipsCtrl.Instance:ShowSystemMsg(Language.Card.CanNotUpTips)
end

--点击升级按钮
function HaloHuanHuaView:OnClickUpGrade()
	local attr_cfg = HaloData.Instance:GetSpecialImageUpgradeInfo(self.index)
	if attr_cfg ~= nil then
		if attr_cfg.grade >= HaloData.Instance:GetSpecialImageMaxUpLevelById(attr_cfg.special_img_id) then
			return
		end
		if ItemData.Instance:GetItemNumInBagById(attr_cfg.stuff_id) < attr_cfg.stuff_num then
			local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[attr_cfg.stuff_id]
			if item_cfg == nil then
				TipsCtrl.Instance:ShowItemGetWayView(attr_cfg.stuff_id)
				return
			end

			if item_cfg.bind_gold == 0 then
				TipsCtrl.Instance:ShowShopView(attr_cfg.stuff_id, 2)
				return
			end

			local func = function(stuff_id, item_num, is_bind, is_use)
				MarketCtrl.Instance:SendShopBuy(stuff_id, item_num, is_bind, is_use)
			end

			TipsCtrl.Instance:ShowCommonBuyView(func, attr_cfg.stuff_id, nil, attr_cfg.stuff_num)
			return
		end
	end
	HaloHuanHuaCtrl.Instance:HaloSpecialImaUpgrade(self.index)
end

--点击使用当前形象
function HaloHuanHuaView:OnClickUseIma()
	HaloCtrl.Instance:SendUseHaloImage(self.index + GameEnum.MOUNT_SPECIAL_IMA_ID)
end

function HaloHuanHuaView:OnClickListCell(halo_special_data, index, halo_cell)
	self.halo_special_image = halo_special_data
	halo_cell:SetHighLight(true)
	if self.index == index then return end
	self.index = index or 1
	self.item_id = halo_special_data.item_id
	self:SetSpecialImageAttr(halo_special_data, index)
end

--获取激活坐骑符数量
function HaloHuanHuaView:GetHaveProNum(item_id, need_num)
	local count = ItemData.Instance:GetItemNumInBagById(item_id)
	if count < need_num then
		count = string.format(Language.Mount.ShowRedNum, count)
	end
	self.have_pro_num:SetValue(count)
end

function HaloHuanHuaView:SetSpecialImageAttr(halo_special_data, index)
	if halo_special_data == nil then
		return
	end
	local upgrade_cfg = HaloData.Instance:GetSpecialImageUpgradeInfo(halo_special_data.image_id)
	local image_cfg = HaloData.Instance:GetHuanHuaHaloCfgByIndex(index)
	local info_list = HaloData.Instance:GetHaloInfo()
	local active_flag = info_list.active_special_image_flag
	local active_flag2 = info_list.active_special_image_flag2
	local bit_list = bit:d2b(active_flag2)
	local bit_list2 = bit:d2b(active_flag)
	for i,v in ipairs(bit_list2) do
		table.insert(bit_list, v)
	end

	local item_cfg = ItemData.Instance:GetItemConfig(image_cfg.item_id)
	local color = self.expense_cfg[image_cfg.item_id].color
	self.halo_name:SetValue("<color="..Common_Five_Rank_Color[color]..">"..halo_special_data.image_name.."</color>")

	if self.res_id ~= image_cfg.res_id then

		PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
		local bundle, asset = ResPath.GetHaloModel(image_cfg.res_id)
		local load_list = {{bundle, asset}}
		self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
				local main_role = Scene.Instance:GetMainRole()
				-- local cfg = self.halo_model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.ROLE_WING], HaloData.Instance:GetHaloModelResCfg(), DISPLAY_PANEL.HUAN_HUA)
				-- self.halo_model:SetTransform(cfg)
				-- self.halo_model:SetRoleResid(main_role:GetRoleResId())
				-- self.halo_model:SetHaloResid(image_cfg.res_id)
				-- self.halo_model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.ROLE_WING], image_cfg.res_id, DISPLAY_PANEL.HUAN_HUA)
				self.halo_model:SetRoleResid(main_role:GetRoleResId())
				self.halo_model:SetHaloResid(image_cfg.res_id)
			end)
		self.res_id = image_cfg.res_id
	end

	self.used_imageid = info_list.used_imageid
	local attr = CommonStruct.Attribute()
	local attr_cfg = HaloData.Instance:GetSpecialImageUpgradeInfo(index)
	if attr_cfg ~= nil then
		attr.max_hp =  attr_cfg.maxhp
		attr.gong_ji = attr_cfg.gongji
		attr.fang_yu = attr_cfg.fangyu
		-- attr.ming_zhong =  attr_cfg.mingzhong
		-- attr.shan_bi = attr_cfg.shanbi
		-- attr.bao_ji = attr_cfg.baoji
		-- attr.jian_ren = attr_cfg.jianren
		self.grade = 0 ~= bit_list[64 - index] and attr_cfg.grade or -1
		-- self.zizhi_dan_limit:SetValue(attr_cfg.shuxingdan_count)
		local str = string.format(Language.Mount.HuanHuaLevel, Common_Five_Rank_Color[color], attr_cfg.grade)
		self.cur_level:SetValue(str)
		self.need_pro_num:SetValue(upgrade_cfg.stuff_num or 1)
		self:GetHaveProNum(halo_special_data.item_id, upgrade_cfg.stuff_num)
	end

	local capability = CommonDataManager.GetCapability(attr)
	self.fight_power:SetValue(capability)
	self.sheng_ming:SetValue(attr.max_hp)
	self.gong_ji:SetValue(attr.gong_ji)
	self.fang_yu:SetValue(attr.fang_yu)
	-- self.ming_zhong:SetValue(attr.ming_zhong)
	-- self.shan_bi:SetValue(attr.shan_bi)
	-- self.bao_ji:SetValue(attr.bao_ji)
	-- self.jian_ren:SetValue(attr.jian_ren)

	local data = {item_id = halo_special_data.item_id, is_bind = 0}
	self.item:SetData(data)

	self:IsShowActivate(self.index)
	self:IsShowUpGrade(self.index)
	self:IsGrayUpgradeButton(self.index)
end

--设置激活按钮显示和隐藏
function HaloHuanHuaView:IsShowActivate(image_id)
	if image_id == nil then
		return
	end
	local info_list = HaloData.Instance:GetHaloInfo()
	local active_flag = info_list.active_special_image_flag
	local active_flag2 = info_list.active_special_image_flag2
	local bit_list = bit:d2b(active_flag2)
	local bit_list2 = bit:d2b(active_flag)
	for i,v in ipairs(bit_list2) do
		table.insert(bit_list, v)
	end
	self.show_activate_btn:SetValue(0 == bit_list[64 - image_id]) --把64位转换成table,返回1，表示激活
	self.show_use_ima_btn:SetValue(0 ~= bit_list[64 - image_id])
	self.show_use_image:SetValue(0 ~= bit_list[64 - image_id])
	self.show_cur_level:SetValue(0 ~= bit_list[64 - image_id])
	if info_list.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
		self.show_use_ima_btn:SetValue(image_id ~= (info_list.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID)
													and 0 ~= bit_list[64 - image_id])
		self.show_use_image:SetValue(image_id == (info_list.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID)
													and 0 ~= bit_list[64 - image_id])
	else
		self.show_use_ima_btn:SetValue(0 ~= bit_list[64 - image_id])
		self.show_use_image:SetValue(false)
	end
end

--设置升级按钮显示和隐藏
function HaloHuanHuaView:IsShowUpGrade(image_id)
	if image_id == nil then
		return
	end
	local special_img_up = HaloData.Instance:GetSpecialImageUpgradeCfg()
	local info_list = HaloData.Instance:GetHaloInfo()
	local active_flag = info_list.active_special_image_flag
	local active_flag2 = info_list.active_special_image_flag2
	local bit_list = bit:d2b(active_flag2)
	local bit_list2 = bit:d2b(active_flag)
	for i,v in ipairs(bit_list2) do
		table.insert(bit_list, v)
	end
	for k, v in pairs(special_img_up) do
		if v.special_img_id == image_id then
			self.show_upgrade_btn:SetValue(0 ~= bit_list[64 - image_id])
			break
		else
			self.show_upgrade_btn:SetValue(false)
		end
	end
end

--升级按钮是否置灰
function HaloHuanHuaView:IsGrayUpgradeButton(index)
	if index == nil or index < 0 then return end
	local halo_special_image = ConfigManager.Instance:GetAutoConfig("halo_auto").special_img
	local upgrade_cfg = HaloData.Instance:GetSpecialImageUpgradeInfo(halo_special_image[index].image_id)
	if upgrade_cfg.grade < HaloData.Instance:GetSpecialImageMaxUpLevelById(halo_special_image[index].image_id) then --GameEnum.MAX_UPGRADE_LIMIT
		self.upgrade_btn.button.interactable = true
		self.button_text:SetValue(Language.Common.UpGrade)
	else
		self.upgrade_btn.button.interactable = false
		self.button_text:SetValue(Language.Common.YiManJi)
	end
end

function HaloHuanHuaView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "halohuanhua" then
			print("halohuanhua刷新了")
			local halo_special_image = ConfigManager.Instance:GetAutoConfig("halo_auto").special_img
			local upgrade_cfg = HaloData.Instance:GetSpecialImageUpgradeInfo(halo_special_image[self.index].image_id)
			local info_list = HaloData.Instance:GetHaloInfo()
			local active_flag = info_list.active_special_image_flag
			local active_flag2 = info_list.active_special_image_flag2
			local bit_list = bit:d2b(active_flag2)
			local bit_list2 = bit:d2b(active_flag)
			for i,v in ipairs(bit_list2) do
				table.insert(bit_list, v)
			end
			if not self.grade or (self.grade < upgrade_cfg.grade and 0 ~= bit_list[64 - self.index]) or (self.used_imageid ~= info_list.used_imageid) then
				self:GetHaveProNum(self.item_id, upgrade_cfg.stuff_num)
				self:IsShowActivate(self.index)
				self:IsShowUpGrade(self.index)
				self:SetSpecialImageAttr(halo_special_image[self.index], self.index)
				self:IsGrayUpgradeButton(self.index)
				self.list_view.scroller:RefreshActiveCellViews()
	      	end
		end
	end
end

HaloHuanHuaCell = HaloHuanHuaCell or BaseClass(BaseRender)

function HaloHuanHuaCell:__init()
	self.name = self:FindVariable("Name")
	self.show_red_ponit = self:FindVariable("ShowRedPoint")
	self.is_used = self:FindVariable("IsUse")
	self.is_own = self:FindVariable("IsOwn")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
end

function HaloHuanHuaCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function HaloHuanHuaCell:SetData(data)
	if data == nil then
		return
	end
	self.item_cell:SetData(data)
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if item_cfg == nil then return end
	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">".. data.image_name .."</color>"
	self.name:SetValue(name_str)
	self.show_red_ponit:SetValue(data.is_show)
	self:ShowLabel(data.index)
end

function HaloHuanHuaCell:ListenClick(handler)
	self:ClearEvent("Click")
	self:ListenEvent("Click", handler)
end

function HaloHuanHuaCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function HaloHuanHuaCell:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end

function HaloHuanHuaCell:ShowLabel(image_id)
	if image_id == nil then
		return
	end

	local info_list = HaloData.Instance:GetHaloInfo()
	local active_flag = info_list.active_special_image_flag
	local active_flag2 = info_list.active_special_image_flag2
	local bit_list = bit:d2b(active_flag2)
	local bit_list2 = bit:d2b(active_flag)
	for i,v in ipairs(bit_list2) do
		table.insert(bit_list, v)
	end
	self.is_own:SetValue(0 ~= bit_list[64 - image_id])
	self.is_used:SetValue(0 ~= bit_list[64 - image_id])
	if info_list.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
		self.is_own:SetValue(image_id ~= (info_list.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID)
													and 0 ~= bit_list[64 - image_id])
		self.is_used:SetValue(image_id == (info_list.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID)
													and 0 ~= bit_list[64 - image_id])
	else
		self.is_own:SetValue(0 ~= bit_list[64 - image_id])
		self.is_used:SetValue(false)
	end
end
