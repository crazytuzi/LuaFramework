FootHuanHuaView = FootHuanHuaView or BaseClass(BaseView)

function FootHuanHuaView:__init()
	self.ui_config = {"uis/views/advanceview_prefab","FootHuanHuaView"}
	self.play_audio = true
	self.item_id = 0
	self.index = 1
	self.grade = nil
	self.foot_special_image = nil
	self.res_id = nil
	self.used_imageid = nil
	-- self.view_layer = UiLayer.Pop
	self.cell_list = {}
	self.prefab_preload_id = 0
end

function FootHuanHuaView:LoadCallBack()
	self.expense_cfg = MountData.Instance:GetExpenseCfg()
	self.foot_display = self:FindObj("FootDisplay")

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
	self.foot_name = self:FindVariable("ZuoQiName")
	self.show_upgrade_btn = self:FindVariable("IsShowUpGrade")
	self.show_activate_btn = self:FindVariable("IsShowActivate")
	self.show_use_ima_btn = self:FindVariable("IsShowUseImaButton")
	self.show_use_image = self:FindVariable("IsShowUseImage")
	self.cur_level = self:FindVariable("CurrentLevel")
	self.show_cur_level = self:FindVariable("ShowCurrentLevel")

	self.foot_model = RoleModel.New("foot_huanhua_panel")
	self.foot_model:SetDisplay(self.foot_display.ui3d_display)

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
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetFootNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshFootCell, self)
end

function FootHuanHuaView:__delete()
	self.index = 1
	self.grade = nil
	self.item_id = nil
	self.res_id = nil
	self.foot_special_image = nil
	self.used_imageid = nil
end

function FootHuanHuaView:ReleaseCallBack()
	if self.foot_model ~= nil then
		self.foot_model:DeleteMe()
		self.foot_model = nil
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
	self.foot_display = nil
	self.have_pro_num = nil
	self.need_pro_num = nil
	self.button_text = nil
	self.gong_ji = nil
	self.fang_yu = nil
	self.sheng_ming = nil
	self.fight_power = nil
	self.get_tujing_1 = nil
	self.get_tujing_2 = nil
	self.foot_name = nil
	self.show_upgrade_btn = nil
	self.show_activate_btn = nil
	self.show_use_ima_btn = nil
	self.show_use_image = nil
	self.cur_level = nil
	self.show_cur_level = nil
	self.list_view = nil
	self.upgrade_btn = nil
end

function FootHuanHuaView:GetFootNumberOfCells()
	local temp_table = FootData.Instance:GetHuanHuaFootCfg()
	return #temp_table
end

function FootHuanHuaView:RefreshFootCell(cell, cell_index)
	local foot_special_image = FootData.Instance:GetHuanHuaFootCfg()
	local foot_cell = self.cell_list[cell]
	if foot_cell == nil then
		foot_cell = FootHuanHuaCell.New(cell.gameObject)
		self.cell_list[cell] = foot_cell
	end
	foot_cell:SetToggleGroup(self.list_view.toggle_group)
	local data = {}
	data.head_id = foot_special_image[cell_index+1].head_id
	data.image_name = foot_special_image[cell_index+1].image_name
	data.item_id = foot_special_image[cell_index+1].item_id
	data.index = foot_special_image[cell_index+1].image_id
	data.is_show = FootData.Instance:CanHuanhuaUpgrade() == (data.index)
	foot_cell:SetData(data)
	foot_cell:SetHighLight(self.index == data.index)
	foot_cell:ListenClick(BindTool.Bind(self.OnClickListCell, self, foot_special_image[cell_index+1], data.index, foot_cell))
end

function FootHuanHuaView:OnClickClose()
	self:Close()
	self.res_id = nil
	self.grade = nil
	self.used_imageid = nil
end

function FootHuanHuaView:OpenCallBack()
	self:Flush("foothuanhua")
	self.index = 1
end

--点击激活按钮
function FootHuanHuaView:OnClickActivate()
	local data_list = ItemData.Instance:GetBagItemDataList()
	local foot_special_image = ConfigManager.Instance:GetAutoConfig("footprint_auto").special_img
	self.item_id = foot_special_image[self.index].item_id
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
function FootHuanHuaView:OnClickUpGrade()
	local attr_cfg = FootData.Instance:GetSpecialImageUpgradeInfo(self.index)
	if attr_cfg ~= nil then
		if attr_cfg.grade >= FootData.Instance:GetSpecialImageMaxUpLevelById(attr_cfg.special_img_id) then
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
	FootHuanHuaCtrl.Instance:FootSpecialImaUpgrade(self.index)
end

--点击使用当前形象
function FootHuanHuaView:OnClickUseIma()
	FootCtrl.Instance:SendUseFootImage(self.index + GameEnum.MOUNT_SPECIAL_IMA_ID)
end

function FootHuanHuaView:OnClickListCell(foot_special_data, index, foot_cell)
	self.foot_special_image = foot_special_data
	foot_cell:SetHighLight(true)
	if self.index == index then return end
	self.index = index or 1
	self.item_id = foot_special_data.item_id
	self:SetSpecialImageAttr(foot_special_data, index)
end

--获取激活坐骑符数量
function FootHuanHuaView:GetHaveProNum(item_id, need_num)
	local count = ItemData.Instance:GetItemNumInBagById(item_id)
	if count < need_num then
		count = string.format(Language.Mount.ShowRedNum, count)
	end
	self.have_pro_num:SetValue(count)
end

function FootHuanHuaView:SetSpecialImageAttr(foot_special_data, index)
	if foot_special_data == nil then
		return
	end
	local temp_table = FootData.Instance:GetHuanHuaFootCfg()
	local upgrade_cfg = FootData.Instance:GetSpecialImageUpgradeInfo(foot_special_data.image_id)
	local image_cfg = FootData.Instance:GetHuanHuaFootCfgByIndex(index)
	local info_list = FootData.Instance:GetFootInfo()
	local active_flag = info_list.active_special_image_flag
	local active_flag2 = info_list.active_special_image_flag2
	local bit_list = bit:d2b(active_flag2)
	local bit_list2 = bit:d2b(active_flag)
	for i,v in ipairs(bit_list2) do
		table.insert(bit_list, v)
	end

	local item_cfg = ItemData.Instance:GetItemConfig(image_cfg.item_id)
	local color = self.expense_cfg[image_cfg.item_id].color
	self.foot_name:SetValue("<color="..Common_Five_Rank_Color[color]..">"..foot_special_data.image_name.."</color>")

	if self.res_id ~= image_cfg.res_id then

		PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
		local bundle, asset = ResPath.GetFootModel(1)
		local load_list = {{bundle, asset}}
		self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
				local main_role = Scene.Instance:GetMainRole()
				-- local cfg = self.foot_model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.ROLE_WING], FootData.Instance:GetFootModelResCfg(), DISPLAY_PANEL.HUAN_HUA)
				-- self.foot_model:SetTransform(cfg)
				self.foot_model:SetRoleResid(main_role:GetRoleResId())
				self.foot_model:SetFootResid(image_cfg.res_id)
				self.foot_model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
			end)
		self.res_id = image_cfg.res_id
	end

	self.used_imageid = info_list.used_imageid
	local attr = CommonStruct.Attribute()
	local attr_cfg = FootData.Instance:GetSpecialImageUpgradeInfo(index)
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
		self:GetHaveProNum(foot_special_data.item_id, upgrade_cfg.stuff_num)
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

	local data = {item_id = foot_special_data.item_id, is_bind = 0}
	self.item:SetData(data)

	self:IsShowActivate(self.index)
	self:IsShowUpGrade(self.index)
	self:IsGrayUpgradeButton(self.index)
end

--设置激活按钮显示和隐藏
function FootHuanHuaView:IsShowActivate(image_id)
	if image_id == nil then
		return
	end
	local info_list = FootData.Instance:GetFootInfo()
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
function FootHuanHuaView:IsShowUpGrade(image_id)
	if image_id == nil then
		return
	end
	local special_img_up = FootData.Instance:GetSpecialImageUpgradeCfg()
	local info_list = FootData.Instance:GetFootInfo()
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
function FootHuanHuaView:IsGrayUpgradeButton(index)
	if index == nil or index < 0 then return end
	local foot_special_image = ConfigManager.Instance:GetAutoConfig("footprint_auto").special_img
	local upgrade_cfg = FootData.Instance:GetSpecialImageUpgradeInfo(foot_special_image[index].image_id)
	if upgrade_cfg.grade < FootData.Instance:GetSpecialImageMaxUpLevelById(foot_special_image[index].image_id) then --GameEnum.MAX_UPGRADE_LIMIT
		self.upgrade_btn.button.interactable = true
		self.button_text:SetValue(Language.Common.UpGrade)
	else
		self.upgrade_btn.button.interactable = false
		self.button_text:SetValue(Language.Common.YiManJi)
	end
end

function FootHuanHuaView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "foothuanhua" then
			print("foothuanhua刷新了")
			local foot_special_image = ConfigManager.Instance:GetAutoConfig("footprint_auto").special_img
			local upgrade_cfg = FootData.Instance:GetSpecialImageUpgradeInfo(foot_special_image[self.index].image_id)
			local info_list = FootData.Instance:GetFootInfo()
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
				self:SetSpecialImageAttr(foot_special_image[self.index], self.index)
				self:IsGrayUpgradeButton(self.index)
				self.list_view.scroller:RefreshActiveCellViews()
			end
		end
	end
end

FootHuanHuaCell = FootHuanHuaCell or BaseClass(BaseRender)

function FootHuanHuaCell:__init()
	self.name = self:FindVariable("Name")
	self.show_red_ponit = self:FindVariable("ShowRedPoint")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.is_own = self:FindVariable("IsOwn")
	self.is_used = self:FindVariable("IsUse")
end

function FootHuanHuaCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function FootHuanHuaCell:SetData(data)
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

function FootHuanHuaCell:ListenClick(handler)
	self:ClearEvent("Click")
	self:ListenEvent("Click", handler)
end

function FootHuanHuaCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function FootHuanHuaCell:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end

function FootHuanHuaCell:ShowLabel(image_id)
	if image_id == nil then
		return
	end

	local info_list = FootData.Instance:GetFootInfo()
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
