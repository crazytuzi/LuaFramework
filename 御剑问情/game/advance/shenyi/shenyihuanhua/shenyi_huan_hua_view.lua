ShenyiHuanHuaView = ShenyiHuanHuaView or BaseClass(BaseView)
local FIX_SHOW_TIME = 8
function ShenyiHuanHuaView:__init()
	self.ui_config = {"uis/views/advanceview_prefab","ShenyiHuanHuaView"}
	self.play_audio = true
	self.item_id = 0
	self.index = 1
	self.grade = nil
	self.shenyi_special_image = nil
	self.res_id = nil
	self.used_imageid = nil
	self.prefab_preload_id = 0
end

function ShenyiHuanHuaView:LoadCallBack()
	self.shenyi_display = self:FindObj("ShenyiDisplay")

	self.have_pro_num = self:FindVariable("ActivateProNum")
	self.need_pro_num = self:FindVariable("ExchangeNeedNum")
	self.button_text = self:FindVariable("ButtonText")

	self.gong_ji = self:FindVariable("GongJi")
	self.fang_yu = self:FindVariable("FangYu")
	self.sheng_ming = self:FindVariable("ShengMing")

	self.fight_power = self:FindVariable("FightPower")
	self.get_tujing_1 = self:FindVariable("GetTuJing1")
	self.get_tujing_2 = self:FindVariable("GetTuJing2")
	self.shenyi_name = self:FindVariable("ZuoQiName")
	self.show_upgrade_btn = self:FindVariable("IsShowUpGrade")
	self.show_activate_btn = self:FindVariable("IsShowActivate")
	self.show_use_ima_btn = self:FindVariable("IsShowUseImaButton")
	self.show_cancel_btn = self:FindVariable("IsShowCancelButton")
	self.cur_level = self:FindVariable("CurrentLevel")
	self.show_cur_level = self:FindVariable("ShowCurrentLevel")

	self.shenyi_model = RoleModel.New("goddess_huanhua_panel")
	self.shenyi_model:SetDisplay(self.shenyi_display.ui3d_display)

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
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetShenyiNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshShenyiCell, self)
	self.cell_list = {}
end

function ShenyiHuanHuaView:ReleaseCallBack()
	if self.shenyi_model ~= nil then
		self.shenyi_model:DeleteMe()
		self.shenyi_model = nil
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
	self.shenyi_display = nil
	self.have_pro_num = nil
	self.need_pro_num = nil
	self.button_text = nil
	self.gong_ji = nil
	self.fang_yu = nil
	self.sheng_ming = nil
	self.fight_power = nil
	self.get_tujing_1 = nil
	self.get_tujing_2 = nil
	self.shenyi_name = nil
	self.show_upgrade_btn = nil
	self.show_activate_btn = nil
	self.show_use_ima_btn = nil
	self.show_cancel_btn = nil
	self.cur_level = nil
	self.show_cur_level = nil
	self.list_view = nil
	self.upgrade_btn = nil
	self.upgrade_txt = nil
end

function ShenyiHuanHuaView:__delete()
	self.index = 1
	self.grade = nil
	self.item_id = nil
	self.shenyi_special_image = nil
	self.res_id = nil
	self.used_imageid = nil
end

function ShenyiHuanHuaView:CloseCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	if self.time_quest_2 then
		GlobalTimerQuest:CancelQuest(self.time_quest_2)
		self.time_quest_2 = nil
	end
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function ShenyiHuanHuaView:GetShenyiNumberOfCells()
	return ShenyiData.Instance:GetMaxSpecialImage()
end

function ShenyiHuanHuaView:RefreshShenyiCell(cell, cell_index)
	local shenyi_special_image = ShenyiData.Instance:GetSpecialImageList()
	local shenyi_cell = self.cell_list[cell]
	if shenyi_cell == nil then
		shenyi_cell = ShenyiHuanHuaCell.New(cell.gameObject)
		self.cell_list[cell] = shenyi_cell
	end
	shenyi_cell:SetToggleGroup(self.list_view.toggle_group)
	shenyi_cell:SetHighLight(self.index == cell_index + 1)
	local data = {}
	data.head_id = shenyi_special_image[cell_index+1].head_id
	data.image_name = shenyi_special_image[cell_index+1].image_name
	data.item_id = shenyi_special_image[cell_index+1].item_id
	data.index = cell_index+1
	data.is_show = ShenyiData.Instance:CanHuanhuaUpgrade()[shenyi_special_image[cell_index + 1].image_id] ~= nil
	shenyi_cell:SetData(data)
	shenyi_cell:ListenClick(BindTool.Bind(self.OnClickListCell, self, shenyi_special_image[cell_index+1], cell_index+1, shenyi_cell))
end

function ShenyiHuanHuaView:OnClickClose()
	self:Close()
	self.grade = nil
	self.res_id = nil
	self.used_imageid = nil
end

function ShenyiHuanHuaView:OpenCallBack()
	self:Flush("shenyihuanhua")
	self.index = 1
end

--点击激活按钮
function ShenyiHuanHuaView:OnClickActivate()
	local data_list = ItemData.Instance:GetBagItemDataList()
	local shenyi_special_image = ShenyiData.Instance:GetSpecialImageCfgByIndex(self.index)
	self.item_id = shenyi_special_image.item_id
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
end

--点击升级按钮
function ShenyiHuanHuaView:OnClickUpGrade()
	local shenyi_special_image = ShenyiData.Instance:GetSpecialImageCfgByIndex(self.index)
	local attr_cfg = ShenyiData.Instance:GetSpecialImageUpgradeInfo(shenyi_special_image.image_id)
	if attr_cfg ~= nil then
		if attr_cfg.grade >= ShenyiData.Instance:GetSpecialImageMaxUpLevelById(attr_cfg.special_img_id) then
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
	ShenyiHuanHuaCtrl.Instance:ShenyiSpecialImaUpgrade(shenyi_special_image.image_id)
end

--点击使用当前形象
function ShenyiHuanHuaView:OnClickUseIma()
	local shenyi_special_image = ShenyiData.Instance:GetSpecialImageCfgByIndex(self.index)
	ShenyiCtrl.Instance:SendUseShenyiImage(shenyi_special_image.image_id + GameEnum.MOUNT_SPECIAL_IMA_ID)
	print_log("On",shenyi_special_image.image_id + GameEnum.MOUNT_SPECIAL_IMA_ID)
end
--取消使用当前形象
function ShenyiHuanHuaView:OnClickCancelButton()
	local shenyi_special_image = ShenyiData.Instance:GetSpecialImageCfgByIndex(self.index)
	print_log("Can",shenyi_special_image.image_id + GameEnum.MOUNT_SPECIAL_IMA_ID)
	local pro1 = shenyi_special_image.image_id + GameEnum.MOUNT_SPECIAL_IMA_ID
	ShenyiCtrl.SendUnUseShenyiImage(pro1)
	local shenyi_data = ShenyiData.Instance
	self.cur_select_grade = shenyi_data:GetShenyiInfo().grade
	local grade_cfg = shenyi_data:GetShenyiGradeCfg(self.cur_select_grade)
	if not grade_cfg then return end
	ShenyiCtrl.Instance:SendUseShenyiImage(grade_cfg.image_id)
end

function ShenyiHuanHuaView:OnClickListCell(shenyi_special_data, index, shenyi_cell)
	self.shenyi_special_image = shenyi_special_data
	shenyi_cell:SetHighLight(true)
	if self.index == index then return end
	self.index = index or 1
	self.item_id = shenyi_special_data.item_id
	self:SetSpecialImageAttr(shenyi_special_data, index)
end

--获取激活神翼符数量
function ShenyiHuanHuaView:GetHaveProNum(item_id, need_num)
	local count = ItemData.Instance:GetItemNumInBagById(item_id)
	if count < need_num then
		count = string.format(Language.Mount.ShowRedNum, count)
	else
		count = string.format(Language.Mount.ShowGreenNum, count)
	end
	self.have_pro_num:SetValue(count)
end

function ShenyiHuanHuaView:SetSpecialImageAttr(shenyi_special_data, index)
	if shenyi_special_data == nil then
		return
	end
	local upgrade_cfg = ShenyiData.Instance:GetSpecialImageUpgradeInfo(shenyi_special_data.image_id)
	local image_cfg = ShenyiData.Instance:GetSpecialImageCfgByIndex(index)
	local info_list = ShenyiData.Instance:GetShenyiInfo()
	local active_flag = info_list.active_special_image_flag
	local active_flag2 = info_list.active_special_image_flag2
	local bit_list = bit:d2b(active_flag2)
	local bit_list2 = bit:d2b(active_flag)
	for i,v in ipairs(bit_list2) do
		table.insert(bit_list, v)
	end

	local item_cfg = ItemData.Instance:GetItemConfig(image_cfg.item_id)
	self.shenyi_name:SetValue("<color="..SOUL_NAME_COLOR[item_cfg and item_cfg.color or 5]..">"..shenyi_special_data.image_name.."</color>")
	-- self.shenyi_name:SetValue(shenyi_special_data.image_name)

	if self.res_id ~= image_cfg.res_id then
		local info = {}
		info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
		info.wing_res_id = tonumber(image_cfg.res_id)

		self:SetModel(info)
		-- local cfg = self.shenyi_model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.SHENYI], image_cfg.res_id, DISPLAY_PANEL.HUAN_HUA)
		-- if cfg then
		-- 	GlobalTimerQuest:AddDelayTimer(function()
		-- 		self.shenyi_model.draw_obj.root.transform.localPosition = cfg.position
		-- 		self.shenyi_model.draw_obj.root.transform.localRotation = Quaternion.Euler(cfg.rotation.x, cfg.rotation.y, cfg.rotation.z)
		-- 		self.shenyi_model.draw_obj.root.transform.localScale = cfg.scale
		-- 		end, 0.1)
		-- end
		self.res_id = image_cfg.res_id
	end

	self.used_imageid = info_list.used_imageid
	local attr = CommonStruct.Attribute()
	local attr_cfg = ShenyiData.Instance:GetSpecialImageUpgradeInfo(shenyi_special_data.image_id)
	if attr_cfg ~= nil then
		attr.max_hp =  attr_cfg.maxhp
		attr.gong_ji = attr_cfg.gongji
		attr.fang_yu = attr_cfg.fangyu
		attr.ming_zhong =  attr_cfg.mingzhong
		attr.shan_bi = attr_cfg.shanbi
		attr.bao_ji = attr_cfg.baoji
		attr.jian_ren = attr_cfg.jianren
		self.grade = 0 ~= bit_list[64 - shenyi_special_data.image_id] and attr_cfg.grade or -1
		local level_str = "<color="..SOUL_NAME_COLOR[item_cfg and item_cfg.color or 5]..">".. "Lv." .. attr_cfg.grade .. "</color>"
		self.cur_level:SetValue(level_str)
		self.need_pro_num:SetValue(upgrade_cfg.stuff_num or 1)
		self:GetHaveProNum(shenyi_special_data.item_id, upgrade_cfg.stuff_num)
	end

	local capability = CommonDataManager.GetCapability(attr)
	self.fight_power:SetValue(capability)
	self.sheng_ming:SetValue(attr.max_hp)
	self.gong_ji:SetValue(attr.gong_ji)
	self.fang_yu:SetValue(attr.fang_yu)
	local data = {item_id = shenyi_special_data.item_id, is_bind = 0}
	self.item:SetData(data)

	self:IsShowActivate(image_cfg.image_id)
	self:IsShowUpGrade(image_cfg.image_id)
	self:IsGrayUpgradeButton(self.index)
end

--设置激活按钮显示和隐藏
function ShenyiHuanHuaView:IsShowActivate(image_id)
	if image_id == nil then
		return
	end
	local info_list = ShenyiData.Instance:GetShenyiInfo()
	local active_flag = info_list.active_special_image_flag
	local active_flag2 = info_list.active_special_image_flag2
	local bit_list = bit:d2b(active_flag2)
	local bit_list2 = bit:d2b(active_flag)
	for i,v in ipairs(bit_list2) do
		table.insert(bit_list, v)
	end
	self.show_activate_btn:SetValue(0 == bit_list[64 - image_id]) --把64位转换成table,返回1，表示激活
	self.show_use_ima_btn:SetValue(0 ~= bit_list[64 - image_id])
	self.show_cancel_btn:SetValue(0 ~= bit_list[64 - image_id])
	self.show_cur_level:SetValue(0 ~= bit_list[64 - image_id])
	if info_list.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
		self.show_use_ima_btn:SetValue(image_id ~= (info_list.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID)
													and 0 ~= bit_list[64 - image_id])
		self.show_cancel_btn:SetValue(image_id == (info_list.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID)
													and 0 ~= bit_list[64 - image_id])
	else
		self.show_use_ima_btn:SetValue(0 ~= bit_list[64 - image_id])
		self.show_cancel_btn:SetValue(false)
	end
end

--设置升级按钮显示和隐藏
function ShenyiHuanHuaView:IsShowUpGrade(image_id)
	if image_id == nil then
		return
	end
	local special_img_up = ShenyiData.Instance:GetSpecialImageUpgradeCfg()
	local info_list = ShenyiData.Instance:GetShenyiInfo()
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
function ShenyiHuanHuaView:IsGrayUpgradeButton(index)
	if index == nil or index < 0 then return end
	local shenyi_special_image = ConfigManager.Instance:GetAutoConfig("shenyi_auto").special_img
	local upgrade_cfg = ShenyiData.Instance:GetSpecialImageUpgradeInfo(shenyi_special_image[index].image_id)
	if upgrade_cfg.grade < ShenyiData.Instance:GetSpecialImageMaxUpLevelById(shenyi_special_image[index].image_id) then
		self.upgrade_btn.button.interactable = true
		self.upgrade_txt.grayscale.GrayScale = 0
		self.button_text:SetValue(Language.Common.UpGrade)
	else
		self.upgrade_btn.button.interactable = false
		self.upgrade_txt.grayscale.GrayScale = 255
		self.button_text:SetValue(Language.Common.YiManJi)
	end
end

function ShenyiHuanHuaView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "shenyihuanhua" then
			local shenyi_special_image = ShenyiData.Instance:GetSpecialImageCfgByIndex(self.index)
			local upgrade_cfg = ShenyiData.Instance:GetSpecialImageUpgradeInfo(shenyi_special_image.image_id)
			local info_list = ShenyiData.Instance:GetShenyiInfo()
			local active_flag = info_list.active_special_image_flag
			local active_flag2 = info_list.active_special_image_flag2
			local bit_list = bit:d2b(active_flag2)
			local bit_list2 = bit:d2b(active_flag)
			for i,v in ipairs(bit_list2) do
				table.insert(bit_list, v)
			end
			if not self.grade or (self.grade < upgrade_cfg.grade and 0 ~= bit_list[64 - shenyi_special_image.image_id]) or (self.used_imageid ~= info_list.used_imageid) then
				self:GetHaveProNum(self.item_id, upgrade_cfg.stuff_num)
				self:IsShowActivate(shenyi_special_image.image_id)
				self:IsShowUpGrade(shenyi_special_image.image_id)
				self:SetSpecialImageAttr(shenyi_special_image, self.index)
				self:IsGrayUpgradeButton(self.index)
				self.list_view.scroller:RefreshActiveCellViews()
			end
		end
	end
end

function ShenyiHuanHuaView:SetModel(info)
	local asset, bundle = ResPath.GetGoddessWingModel(info.wing_res_id)

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
	local load_list = {{asset, bundle}}
	self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
			self.shenyi_model:ResetRotation()
			self.shenyi_model:SetGoddessModelResInfo(info)
			local resid = GoddessData.Instance:GetShowXiannvResId()
			-- self.shenyi_model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.XIAN_NV], resid, DISPLAY_PANEL.HUAN_HUA)
		end)
	self:CalToShowAnim(true)
end

function ShenyiHuanHuaView:CalToShowAnim(is_change_tab)
	self:PlayAnim(is_change_tab)
end

function ShenyiHuanHuaView:PlayAnim(is_change_tab)
	local count = 1
	self.shenyi_model:SetTrigger(GoddessData.Instance:GetShowTriggerName(count))
end

ShenyiHuanHuaCell = ShenyiHuanHuaCell or BaseClass(BaseRender)

function ShenyiHuanHuaCell:__init()
	self.name = self:FindVariable("Name")
	self.is_use = self:FindVariable("IsUse")
	self.show_red_ponit = self:FindVariable("ShowRedPoint")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.is_own = self:FindVariable("IsOwn")
	self.is_used = self:FindVariable("IsUse")
end

function ShenyiHuanHuaCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ShenyiHuanHuaCell:SetData(data)
	if data == nil then
		return
	end
	self.item_cell:SetData(data)
	self.index = data.index
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if item_cfg == nil then return end
	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">".. data.image_name .."</color>"
	self.name:SetValue(name_str)
	self.show_red_ponit:SetValue(data.is_show)
	self:ShowUseIcon()
	local special_img = ShenyiData.Instance:GetSpecialImageCfgByIndex(data.index)
	self:ShowLabel(special_img.image_id)
end

function ShenyiHuanHuaCell:ShowUseIcon()
	local info_list = ShenyiData.Instance:GetShenyiInfo()
	local active_flag = info_list.active_special_image_flag
	local active_flag2 = info_list.active_special_image_flag2
	local bit_list = bit:d2b(active_flag2)
	local bit_list2 = bit:d2b(active_flag)
	for i,v in ipairs(bit_list2) do
		table.insert(bit_list, v)
	end
	local flag = info_list.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID
	if self.index == flag and 0 ~= bit_list[64 - self.index] then
		is_use = true
	else
		is_use = false
	end
	self.is_use:SetValue(is_use)
end

function ShenyiHuanHuaCell:ListenClick(handler)
	self:ClearEvent("Click")
	self:ListenEvent("Click", handler)
end

function ShenyiHuanHuaCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function ShenyiHuanHuaCell:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end

function ShenyiHuanHuaCell:ShowLabel(image_id)
	if image_id == nil then
		return
	end

	local info_list = ShenyiData.Instance:GetShenyiInfo()
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
