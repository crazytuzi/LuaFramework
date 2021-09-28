CloakHuanHuaView = CloakHuanHuaView or BaseClass(BaseView)

function CloakHuanHuaView:__init()
	self.ui_config = {"uis/views/advanceview_prefab", "CloakHuanHuaView"}
	self.play_audio = true
	self.item_id = 0
	self.index = 1
	self.grade = nil
	self.cloak_special_image = nil
	self.res_id = nil
	self.used_imageid = nil
	-- self.view_layer = UiLayer.Pop
	self.cell_list = {}
	self.prefab_preload_id = 0
end

function CloakHuanHuaView:LoadCallBack()
	self.cloak_display = self:FindObj("CloakDisplay")

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
	self.cloak_name = self:FindVariable("ZuoQiName")
	self.show_upgrade_btn = self:FindVariable("IsShowUpGrade")
	self.show_activate_btn = self:FindVariable("IsShowActivate")
	self.show_use_ima_btn = self:FindVariable("IsShowUseImaButton")
	self.show_use_image = self:FindVariable("IsShowUseImage")
	self.cur_level = self:FindVariable("CurrentLevel")
	self.show_cur_level = self:FindVariable("ShowCurrentLevel")

	self.cloak_model = RoleModel.New()
	self.cloak_model:SetDisplay(self.cloak_display.ui3d_display)

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
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCloakNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCloakCell, self)
end

function CloakHuanHuaView:__delete()
	self.index = 1
	self.grade = nil
	self.item_id = nil
	self.res_id = nil
	self.cloak_special_image = nil
	self.used_imageid = nil
end

function CloakHuanHuaView:ReleaseCallBack()
	if self.cloak_model ~= nil then
		self.cloak_model:DeleteMe()
		self.cloak_model = nil
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
	self.cloak_display = nil
	self.have_pro_num = nil
	self.need_pro_num = nil
	self.button_text = nil
	self.gong_ji = nil
	self.fang_yu = nil
	self.sheng_ming = nil
	self.fight_power = nil
	self.get_tujing_1 = nil
	self.get_tujing_2 = nil
	self.cloak_name = nil
	self.show_upgrade_btn = nil
	self.show_activate_btn = nil
	self.show_use_ima_btn = nil
	self.show_use_image = nil
	self.cur_level = nil
	self.show_cur_level = nil
	self.list_view = nil
	self.upgrade_btn = nil
end

function CloakHuanHuaView:GetCloakNumberOfCells()
	return CloakData.Instance:GetMaxSpecialImage()
end

function CloakHuanHuaView:RefreshCloakCell(cell, cell_index)
	local cloak_special_image = ConfigManager.Instance:GetAutoConfig("cloak_auto").special_img
	local cloak_cell = self.cell_list[cell]
	if cloak_cell == nil then
		cloak_cell = CloakHuanHuaCell.New(cell.gameObject)
		self.cell_list[cell] = cloak_cell
	end
	cloak_cell:SetToggleGroup(self.list_view.toggle_group)
	cloak_cell:SetHighLight(self.index == cell_index + 1)
	local data = {}
	data.head_id = cloak_special_image[cell_index+1].head_id
	data.image_name = cloak_special_image[cell_index+1].image_name
	data.item_id = cloak_special_image[cell_index+1].item_id
	data.index = cell_index+1
	data.is_show = CloakData.Instance:CanHuanhuaUpgrade() == (cell_index + 1)
	cloak_cell:SetData(data)
	cloak_cell:ListenClick(BindTool.Bind(self.OnClickListCell, self, cloak_special_image[cell_index+1], cell_index+1, cloak_cell))
end

function CloakHuanHuaView:OnClickClose()
	self:Close()
	self.res_id = nil
	self.grade = nil
	self.used_imageid = nil
end

function CloakHuanHuaView:OpenCallBack()
	self:Flush("cloakhuanhua")
	self.index = 1
end

--点击激活按钮
function CloakHuanHuaView:OnClickActivate()
	local data_list = ItemData.Instance:GetBagItemDataList()
	local cloak_special_image = ConfigManager.Instance:GetAutoConfig("cloak_auto").special_img
	self.item_id = cloak_special_image[self.index].item_id
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
function CloakHuanHuaView:OnClickUpGrade()
	local attr_cfg = CloakData.Instance:GetSpecialImageUpgradeInfo(self.index)
	if attr_cfg ~= nil then
		if attr_cfg.grade >= CloakData.Instance:GetSpecialImageMaxUpLevelById(attr_cfg.special_img_id) then
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
	CloakHuanHuaCtrl.Instance:CloakSpecialImaUpgrade(self.index)
end

--点击使用当前形象
function CloakHuanHuaView:OnClickUseIma()
	CloakCtrl.Instance:SendUseCloakImage(self.index + GameEnum.MOUNT_SPECIAL_IMA_ID)
end

function CloakHuanHuaView:OnClickListCell(cloak_special_data, index, cloak_cell)
	self.cloak_special_image = cloak_special_data
	cloak_cell:SetHighLight(true)
	if self.index == index then return end
	self.index = index or 1
	self.item_id = cloak_special_data.item_id
	self:SetSpecialImageAttr(cloak_special_data, index)
end

--获取激活坐骑符数量
function CloakHuanHuaView:GetHaveProNum(item_id, need_num)
	local count = ItemData.Instance:GetItemNumInBagById(item_id)
	if count < need_num then
		count = string.format(Language.Mount.ShowRedNum, count)
	end
	self.have_pro_num:SetValue(count)
end

function CloakHuanHuaView:SetSpecialImageAttr(cloak_special_data, index)
	if cloak_special_data == nil then
		return
	end
	local upgrade_cfg = CloakData.Instance:GetSpecialImageUpgradeInfo(cloak_special_data.image_id)
	local image_cfg = CloakData.Instance:GetSpecialImageCfg(index)
	local info_list = CloakData.Instance:GetCloakInfo()
	local active_flag = info_list.active_special_image_flag
	local bit_list = bit:d2b(active_flag)

	local item_cfg = ItemData.Instance:GetItemConfig(image_cfg.item_id)
	self.cloak_name:SetValue("<color="..SOUL_NAME_COLOR[item_cfg and item_cfg.color or 5]..">"..cloak_special_data.image_name.."</color>")

	if self.res_id ~= image_cfg.res_id then

		PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
		local bundle, asset = ResPath.GetPifengModel(image_cfg.res_id)
		local load_list = {{bundle, asset}}
		self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
				local main_role = Scene.Instance:GetMainRole()
				local cfg = self.cloak_model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.CLOAK], CloakData.Instance:GetCloakModelResCfg(), DISPLAY_PANEL.HUAN_HUA)
				if cfg then	
					self.cloak_model:SetTransform(cfg)
				end
				self.cloak_model:SetRoleResid(main_role:GetRoleResId())
				self.cloak_model:SetCloakResid(10002001)
			end)
		self.res_id = image_cfg.res_id
	end

	self.used_imageid = info_list.used_imageid
	local attr = CommonStruct.Attribute()
	local attr_cfg = CloakData.Instance:GetSpecialImageUpgradeInfo(index)
	if attr_cfg ~= nil then
		attr.max_hp =  attr_cfg.maxhp
		attr.gong_ji = attr_cfg.gongji
		attr.fang_yu = attr_cfg.fangyu
		-- attr.ming_zhong =  attr_cfg.mingzhong
		-- attr.shan_bi = attr_cfg.shanbi
		-- attr.bao_ji = attr_cfg.baoji
		-- attr.jian_ren = attr_cfg.jianren
		self.grade = 0 ~= bit_list[32 - index] and attr_cfg.grade or -1
		-- self.zizhi_dan_limit:SetValue(attr_cfg.shuxingdan_count)
		self.cur_level:SetValue(attr_cfg.grade)
		self.need_pro_num:SetValue(upgrade_cfg.stuff_num or 1)
		self:GetHaveProNum(cloak_special_data.item_id, upgrade_cfg.stuff_num)
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

	local data = {item_id = cloak_special_data.item_id, is_bind = 0}
	self.item:SetData(data)

	self:IsShowActivate(self.index)
	self:IsShowUpGrade(self.index)
	self:IsGrayUpgradeButton(self.index)
end

--设置激活按钮显示和隐藏
function CloakHuanHuaView:IsShowActivate(image_id)
	if image_id == nil then
		return
	end
	local info_list = CloakData.Instance:GetCloakInfo()
	local active_flag = info_list.active_special_image_flag
	local bit_list = bit:d2b(active_flag)
	self.show_activate_btn:SetValue(0 == bit_list[32 - image_id]) --把32位转换成table,返回1，表示激活
	self.show_use_ima_btn:SetValue(0 ~= bit_list[32 - image_id])
	self.show_use_image:SetValue(0 ~= bit_list[32 - image_id])
	self.show_cur_level:SetValue(0 ~= bit_list[32 - image_id])
	if info_list.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
		self.show_use_ima_btn:SetValue(image_id ~= (info_list.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID)
													and 0 ~= bit_list[32 - image_id])
		self.show_use_image:SetValue(image_id == (info_list.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID)
													and 0 ~= bit_list[32 - image_id])
	else
		self.show_use_ima_btn:SetValue(0 ~= bit_list[32 - image_id])
		self.show_use_image:SetValue(false)
	end
end

--设置升级按钮显示和隐藏
function CloakHuanHuaView:IsShowUpGrade(image_id)
	if image_id == nil then
		return
	end
	local special_img_up = CloakData.Instance:GetSpecialImageUpgradeCfg()
	local info_list = CloakData.Instance:GetCloakInfo()
	local active_flag = info_list.active_special_image_flag
	local bit_list = bit:d2b(active_flag)
	for k, v in pairs(special_img_up) do
		if v.special_img_id == image_id then
			self.show_upgrade_btn:SetValue(0 ~= bit_list[32 - image_id])
			break
		else
			self.show_upgrade_btn:SetValue(false)
		end
	end
end

--升级按钮是否置灰
function CloakHuanHuaView:IsGrayUpgradeButton(index)
	if index == nil or index < 0 then return end
	local cloak_special_image = ConfigManager.Instance:GetAutoConfig("cloak_auto").special_img
	local upgrade_cfg = CloakData.Instance:GetSpecialImageUpgradeInfo(cloak_special_image[index].image_id)
	if upgrade_cfg.grade < CloakData.Instance:GetSpecialImageMaxUpLevelById(cloak_special_image[index].image_id) then --GameEnum.MAX_UPGRADE_LIMIT
		self.upgrade_btn.button.interactable = true
		self.button_text:SetValue(Language.Common.UpGrade)
	else
		self.upgrade_btn.button.interactable = false
		self.button_text:SetValue(Language.Common.YiManJi)
	end
end

function CloakHuanHuaView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "cloakhuanhua" then
			print("cloakhuanhua刷新了")
			local cloak_special_image = ConfigManager.Instance:GetAutoConfig("cloak_auto").special_img
			local upgrade_cfg = CloakData.Instance:GetSpecialImageUpgradeInfo(cloak_special_image[self.index].image_id)
			local info_list = CloakData.Instance:GetCloakInfo()
			local active_flag = info_list.active_special_image_flag
			local bit_list = bit:d2b(active_flag)
			if not self.grade or (self.grade < upgrade_cfg.grade and 0 ~= bit_list[32 - self.index]) or (self.used_imageid ~= info_list.used_imageid) then
				self:GetHaveProNum(self.item_id, upgrade_cfg.stuff_num)
				self:IsShowActivate(self.index)
				self:IsShowUpGrade(self.index)
				self:SetSpecialImageAttr(cloak_special_image[self.index], self.index)
				self:IsGrayUpgradeButton(self.index)
				self.list_view.scroller:RefreshActiveCellViews()
			end
		end
	end
end

CloakHuanHuaCell = CloakHuanHuaCell or BaseClass(BaseRender)

function CloakHuanHuaCell:__init()
	self.icon = self:FindVariable("Icon")
	self.name = self:FindVariable("Name")
	self.show_red_ponit = self:FindVariable("ShowRedPoint")
end

function CloakHuanHuaCell:SetData(data)
	if data == nil then
		return
	end
	local bundle, asset = ResPath.GetItemIcon(data.item_id)
	self.icon:SetAsset(bundle, asset)
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if item_cfg == nil then return end
	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">".. data.image_name .."</color>"
	self.name:SetValue(name_str)
	self.show_red_ponit:SetValue(data.is_show)
end

function CloakHuanHuaCell:ListenClick(handler)
	self:ClearEvent("Click")
	self:ListenEvent("Click", handler)
end

function CloakHuanHuaCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function CloakHuanHuaCell:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end
