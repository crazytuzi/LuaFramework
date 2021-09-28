ShengongHuanHuaView = ShengongHuanHuaView or BaseClass(BaseView)

function ShengongHuanHuaView:__init()
	self.ui_config = {"uis/views/advanceview_prefab","ShengongHuanHuaView"}
	self.play_audio = true
	self.item_id = 0
	self.index = 1
	self.shengong_special_image = nil
	self.grade = nil
	self.res_id = nil
	self.used_imageid = nil
	-- self.view_layer = UiLayer.Pop
	self.prefab_preload_id = 0
end

function ShengongHuanHuaView:LoadCallBack()
	self.shengong_display = self:FindObj("ShengongDisplay")

	self.have_pro_num = self:FindVariable("ActivateProNum")
	self.need_pro_num = self:FindVariable("ExchangeNeedNum")
	self.button_text = self:FindVariable("ButtonText")

	self.gong_ji = self:FindVariable("GongJi")
	self.fang_yu = self:FindVariable("FangYu")
	self.sheng_ming = self:FindVariable("ShengMing")
	self.ming_zhong = self:FindVariable("MingZhong")
	-- self.zizhi_dan_limit = self:FindVariable("ZiZhiDan")
	self.fight_power = self:FindVariable("FightPower")
	self.get_tujing_1 = self:FindVariable("GetTuJing1")
	self.get_tujing_2 = self:FindVariable("GetTuJing2")
	self.shengong_name = self:FindVariable("ZuoQiName")
	self.show_upgrade_btn = self:FindVariable("IsShowUpGrade")
	self.show_activate_btn = self:FindVariable("IsShowActivate")
	self.show_use_ima_btn = self:FindVariable("IsShowUseImaButton")
	self.show_cancel_button = self:FindVariable("IsShowCancelButton")
	self.cur_level = self:FindVariable("CurrentLevel")
	self.show_cur_level = self:FindVariable("ShowCurrentLevel")

	self.shengong_model = RoleModel.New("goddess_huanhua_panel")
	self.shengong_model:SetDisplay(self.shengong_display.ui3d_display)

	self:ListenEvent("OnClickActivate",BindTool.Bind(self.OnClickActivate, self))
	self:ListenEvent("Close",BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickUpGrade",BindTool.Bind(self.OnClickUpGrade, self))
	self:ListenEvent("OnClickUseIma",BindTool.Bind(self.OnClickUseIma, self))
	self:ListenEvent("OnClickCancelButton",BindTool.Bind(self.OnClickCancelButton, self))

	self.list_view = self:FindObj("ListView")
	self.upgrade_btn = self:FindObj("UpGradeButton")
	self.upgrade_txt = self:FindObj("UpGradeTxt")
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("Item"))

	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetShengongNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshShengongCell, self)
	self.cell_list = {}
end

function ShengongHuanHuaView:ReleaseCallBack()
	if self.shengong_model ~= nil then
		self.shengong_model:DeleteMe()
		self.shengong_model = nil
	end

	if self.item ~= nil then
		self.item:DeleteMe()
		self.item = nil
	end

	if self.cell_list ~= nil then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)

	-- 清理变量和对象
	self.shengong_display = nil
	self.have_pro_num = nil
	self.need_pro_num = nil
	self.button_text = nil
	self.gong_ji = nil
	self.fang_yu = nil
	self.sheng_ming = nil
	self.ming_zhong = nil
	self.fight_power = nil
	self.get_tujing_1 = nil
	self.get_tujing_2 = nil
	self.shengong_name = nil
	self.show_upgrade_btn = nil
	self.show_activate_btn = nil
	self.show_use_ima_btn = nil
	self.show_cancel_button = nil
	self.cur_level = nil
	self.show_cur_level = nil
	self.list_view = nil
	self.upgrade_btn = nil
	self.upgrade_txt = nil
end

function ShengongHuanHuaView:__delete()
	self.index = 1
	self.item_id = nil
	self.shengong_special_image = nil
	self.grade = nil
	self.res_id = nil
	self.used_imageid = nil
end

function ShengongHuanHuaView:GetShengongNumberOfCells()
	return ShengongData.Instance:GetMaxSpecialImage()
end

function ShengongHuanHuaView:RefreshShengongCell(cell, cell_index)
	local shengong_special_image = ShengongData.Instance:GetSpecialImageCfgByIndex(cell_index + 1)
	local shengong_cell = self.cell_list[cell]
	if shengong_cell == nil then
		shengong_cell = ShengongHuanHuaCell.New(cell.gameObject)
		self.cell_list[cell] = shengong_cell
	end
	shengong_cell:SetToggleGroup(self.list_view.toggle_group)
	shengong_cell:SetHighLight(self.index == cell_index + 1)
	local data = {}
	data.head_id = shengong_special_image.head_id
	data.image_name = shengong_special_image.image_name
	data.item_id = shengong_special_image.item_id
	data.index = cell_index + 1
	data.is_show = ShengongData.Instance:CanHuanhuaUpgrade()[shengong_special_image.image_id] ~= nil
	shengong_cell:SetData(data)
	shengong_cell:ListenClick(BindTool.Bind(self.OnClickListCell, self, shengong_special_image, cell_index+1, shengong_cell))
end

function ShengongHuanHuaView:OnClickClose()
	self:Close()
	self.grade = nil
	self.res_id = nil
	self.used_imageid = nil
end

function ShengongHuanHuaView:CloseCallBack()
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
	end
end

function ShengongHuanHuaView:OpenCallBack()
	self:Flush("shengonghuanhua")
	self.index = 1
end

--点击激活按钮
function ShengongHuanHuaView:OnClickActivate()
	local data_list = ItemData.Instance:GetBagItemDataList()
	local shengong_special_image = ShengongData.Instance:GetSpecialImageCfgByIndex(self.index)
	self.item_id = shengong_special_image.item_id
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
function ShengongHuanHuaView:OnClickUpGrade()
	local shengong_special_image = ShengongData.Instance:GetSpecialImageCfgByIndex(self.index)
	local attr_cfg = ShengongData.Instance:GetSpecialImageUpgradeInfo(shengong_special_image.image_id)
	if attr_cfg ~= nil then
		if attr_cfg.grade >= ShengongData.Instance:GetSpecialImageMaxUpLevelById(attr_cfg.special_img_id) then
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
	ShengongHuanHuaCtrl.Instance:ShengongSpecialImaUpgrade(shengong_special_image.image_id)
end

--点击使用当前形象
function ShengongHuanHuaView:OnClickUseIma()
	local shengong_img = ShengongData.Instance:GetSpecialImageCfgByIndex(self.index)
	ShengongCtrl.Instance:SendUseShengongImage(shengong_img.image_id + GameEnum.MOUNT_SPECIAL_IMA_ID)
end
--取消使用当前形象
function ShengongHuanHuaView:OnClickCancelButton()
	print_log("Can",self.index + GameEnum.MOUNT_SPECIAL_IMA_ID)
	local pro1 = self.index + GameEnum.MOUNT_SPECIAL_IMA_ID
	local shengong_img = ShengongData.Instance:GetSpecialImageCfgByIndex(self.index)
	ShengongCtrl.SendUnUseShengongImage(shengong_img.image_id + GameEnum.MOUNT_SPECIAL_IMA_ID)
	local shengong_data = ShengongData.Instance
	self.cur_select_grade = shengong_data:GetShengongInfo().grade
	local grade_cfg = shengong_data:GetShengongGradeCfg(self.cur_select_grade)
	if not grade_cfg then return end
	ShengongCtrl.Instance:SendUseShengongImage(grade_cfg.image_id)
end
function ShengongHuanHuaView:OnClickListCell(shengong_special_data, index, shengong_cell)
	self.shengong_special_image = shengong_special_data
	shengong_cell:SetHighLight(true)
	if self.index == index then return end
	self.index = index or 1
	self.item_id = shengong_special_data.item_id
	self:SetSpecialImageAttr(shengong_special_data, index)
end

--获取激活坐骑符数量
function ShengongHuanHuaView:GetHaveProNum(item_id, need_num)
	local count = ItemData.Instance:GetItemNumInBagById(item_id)
	if count < need_num then
		count = string.format(Language.Mount.ShowRedNum, count)
	else
	    count = string.format(Language.Mount.ShowGreenNum, count)
	end
	self.have_pro_num:SetValue(count)
end

function ShengongHuanHuaView:SetSpecialImageAttr(shengong_special_data, index)
	if shengong_special_data == nil then
		return
	end
	local upgrade_cfg = ShengongData.Instance:GetSpecialImageUpgradeInfo(shengong_special_data.image_id)
	local image_cfg = ShengongData.Instance:GetSpecialImageCfgByIndex(index)
	local info_list = ShengongData.Instance:GetShengongInfo()
	local active_flag = info_list.active_special_image_flag
	local active_flag2 = info_list.active_special_image_flag2
	local bit_list = bit:d2b(active_flag2)
	local bit_list2 = bit:d2b(active_flag)
	for i,v in ipairs(bit_list2) do
		table.insert(bit_list, v)
	end

	local item_cfg = ItemData.Instance:GetItemConfig(image_cfg.item_id)
	self.shengong_name:SetValue("<color="..SOUL_NAME_COLOR[item_cfg and item_cfg.color or 5]..">"..shengong_special_data.image_name.."</color>")
	-- self.shengong_name:SetValue(shengong_special_data.image_name)

	if self.res_id ~= shengong_special_data.res_id then
		local info = {}
		info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
		info.weapon_res_id = shengong_special_data.res_id or -1
		self.res_id = shengong_special_data.res_id
		self:SetModel(info)
	end

	self.used_imageid = info_list.used_imageid
	local attr = CommonStruct.Attribute()
	local attr_cfg = ShengongData.Instance:GetSpecialImageUpgradeInfo(shengong_special_data.image_id)
	if attr_cfg ~= nil then
		attr.max_hp =  attr_cfg.maxhp
		attr.gong_ji = attr_cfg.gongji
		attr.fang_yu = attr_cfg.fangyu
		attr.ming_zhong =  attr_cfg.mingzhong
		attr.shan_bi = attr_cfg.shanbi
		attr.bao_ji = attr_cfg.baoji
		self.grade = 0 ~= bit_list[64 - shengong_special_data.image_id] and attr_cfg.grade or -1
		-- self.zizhi_dan_limit:SetValue(attr_cfg.shuxingdan_count)
		local level_str = "<color="..SOUL_NAME_COLOR[item_cfg and item_cfg.color or 5]..">".. "Lv." .. attr_cfg.grade .. "</color>"
		self.cur_level:SetValue(level_str)
		self.need_pro_num:SetValue(upgrade_cfg.stuff_num or 1)
		self:GetHaveProNum(shengong_special_data.item_id, upgrade_cfg.stuff_num)
	end

	local capability = CommonDataManager.GetCapability(attr)
	self.fight_power:SetValue(capability)
	self.sheng_ming:SetValue(attr.max_hp)
	self.gong_ji:SetValue(attr.gong_ji)
	self.fang_yu:SetValue(attr.fang_yu)

	local data = {item_id = shengong_special_data.item_id, is_bind = 0}
	self.item:SetData(data)
	self:IsShowActivate(shengong_special_data.image_id)
	self:IsShowUpGrade(shengong_special_data.image_id)
	self:IsGrayUpgradeButton(self.index)
end

function ShengongHuanHuaView:GetIndex()
	return self.index
end

--设置激活按钮显示和隐藏
function ShengongHuanHuaView:IsShowActivate(image_id)
	if image_id == nil then
		return
	end
	local info_list = ShengongData.Instance:GetShengongInfo()
	local active_flag = info_list.active_special_image_flag
	local active_flag2 = info_list.active_special_image_flag2
	local bit_list = bit:d2b(active_flag2)
	local bit_list2 = bit:d2b(active_flag)
	for i,v in ipairs(bit_list2) do
		table.insert(bit_list, v)
	end
	self.show_activate_btn:SetValue(0 == bit_list[64 - image_id]) --把64位转换成table,返回1，表示激活
	self.show_use_ima_btn:SetValue(0 ~= bit_list[64 - image_id])
	self.show_cancel_button:SetValue(0 ~= bit_list[64 - image_id])
	self.show_cur_level:SetValue(0 ~= bit_list[64 - image_id])
	if info_list.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
		self.show_use_ima_btn:SetValue(image_id ~= (info_list.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID)
													and 0 ~= bit_list[64 - image_id])
		self.show_cancel_button:SetValue(image_id == (info_list.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID)
													and 0 ~= bit_list[64 - image_id])
	else
		self.show_use_ima_btn:SetValue(0 ~= bit_list[64 - image_id])
		self.show_cancel_button:SetValue(false)
	end
end

--设置升级按钮显示和隐藏
function ShengongHuanHuaView:IsShowUpGrade(image_id)
	if image_id == nil then
		return
	end
	local special_img_up = ShengongData.Instance:GetSpecialImageUpgradeCfg()
	local info_list = ShengongData.Instance:GetShengongInfo()
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
function ShengongHuanHuaView:IsGrayUpgradeButton(index)
	if index == nil or index < 0 then return end
	local shengong_special_image = ShengongData.Instance:GetSpecialImageCfgByIndex(index)
	if nil == shengong_special_image then return end

	local upgrade_cfg = ShengongData.Instance:GetSpecialImageUpgradeInfo(shengong_special_image.image_id)
	if nil == upgrade_cfg then return end

	if upgrade_cfg.grade < ShengongData.Instance:GetSpecialImageMaxUpLevelById(shengong_special_image.image_id) then
		self.upgrade_btn.button.interactable = true
		self.upgrade_txt.grayscale.GrayScale = 0
		self.button_text:SetValue(Language.Common.UpGrade)
	else
		self.upgrade_btn.button.interactable = false
		self.upgrade_txt.grayscale.GrayScale = 255
		self.button_text:SetValue(Language.Common.YiManJi)
	end
end

function ShengongHuanHuaView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "shengonghuanhua" then
			local shengong_special_image = ShengongData.Instance:GetSpecialImageCfgByIndex(self.index)
			local upgrade_cfg = ShengongData.Instance:GetSpecialImageUpgradeInfo(shengong_special_image.image_id)
			local info_list = ShengongData.Instance:GetShengongInfo()
			local active_flag = info_list.active_special_image_flag
			local active_flag2 = info_list.active_special_image_flag2
			local bit_list = bit:d2b(active_flag2)
			local bit_list2 = bit:d2b(active_flag)
			for i,v in ipairs(bit_list2) do
				table.insert(bit_list, v)
			end
			if not self.grade or (self.grade < upgrade_cfg.grade and 0 ~= bit_list[64 - shengong_special_image.image_id]) or (self.used_imageid ~= info_list.used_imageid) then
				self:GetHaveProNum(self.item_id, upgrade_cfg.stuff_num)
				self:IsShowActivate(shengong_special_image.image_id)
				self:IsShowUpGrade(shengong_special_image.image_id)
				self:SetSpecialImageAttr(shengong_special_image, self.index)
				self:IsGrayUpgradeButton(self.index)
				self.list_view.scroller:RefreshActiveCellViews()
			end
		end
	end
end

function ShengongHuanHuaView:SetModel(info)
	local asset, bundle = ResPath.GetGoddessWeaponModel(info.weapon_res_id)

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local load_list = {{asset, bundle}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
			self.shengong_model:ResetRotation()
			self.shengong_model:SetGoddessModelResInfo(info)
			local resid = GoddessData.Instance:GetShowXiannvResId()
			-- self.shengong_model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.XIAN_NV], resid, DISPLAY_PANEL.HUAN_HUA)
		end)

	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
	end
end

function ShengongHuanHuaView:CancelTheQuest()
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
	end
end

function ShengongHuanHuaView:CalToShowAnim()
	local count = 1
	self.shengong_model:SetTrigger(GoddessData.Instance:GetShowTriggerName(count))
end
------------------------

ShengongHuanHuaCell = ShengongHuanHuaCell or BaseClass(BaseRender)

function ShengongHuanHuaCell:__init()
	self.name = self:FindVariable("Name")
	self.is_use = self:FindVariable("IsUse")
	self.show_red_ponit = self:FindVariable("ShowRedPoint")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.is_own = self:FindVariable("IsOwn")
	self.is_used = self:FindVariable("IsUse")
end

function ShengongHuanHuaCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ShengongHuanHuaCell:SetData(data)
	if data == nil then
		return
	end
	self.item_cell:SetData(data)

	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if item_cfg == nil then return end
	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">".. data.image_name .."</color>"
	self.name:SetValue(name_str)
	self.show_red_ponit:SetValue(data.is_show)


	--设置是否显示“已幻化”标签
	local using_image = ShengongData.Instance:GetShengongInfo().used_imageid
	if using_image >= 1000 and using_image - 1000 == data.index then
		self.is_use:SetValue(true)
	else
		self.is_use:SetValue(false)
	end
	local shengong_special_image = ShengongData.Instance:GetSpecialImageCfgByIndex(data.index)
	self:ShowLabel(shengong_special_image.image_id)
end

function ShengongHuanHuaCell:ListenClick(handler)
	self:ClearEvent("Click")
	self:ListenEvent("Click", handler)
end

function ShengongHuanHuaCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function ShengongHuanHuaCell:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end

function ShengongHuanHuaCell:ShowLabel(image_id)
	if image_id == nil then
		return
	end

	local info_list = ShengongData.Instance:GetShengongInfo()
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

