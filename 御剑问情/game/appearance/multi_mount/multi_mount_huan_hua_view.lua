MultiMountHuanHuaView = MultiMountHuanHuaView or BaseClass(BaseView)

function MultiMountHuanHuaView:__init()
	self.ui_config = {"uis/views/appearance_prefab","MultiMountHuanHuaView"}
	self.play_audio = true
	self.item_id = 0
	self.index = 1
	self.grade = nil
	self.mount_special_image = nil
	self.res_id = nil
	self.fix_show_time = 10
	self.used_imageid = nil
	self.cell_list = {}
	self.prefab_preload_id = 0
end

function MultiMountHuanHuaView:LoadCallBack()
	self.mount_display = self:FindObj("MountDisplay")

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

	self.mount_name = self:FindVariable("ZuoQiName")
	self.show_upgrade_btn = self:FindVariable("IsShowUpGrade")
	self.show_activate_btn = self:FindVariable("IsShowActivate")
	self.show_use_ima_btn = self:FindVariable("IsShowUseImaButton")
	self.show_use_image = self:FindVariable("IsShowUseImage")
	self.cur_level = self:FindVariable("CurrentLevel")
	self.show_cur_level = self:FindVariable("ShowCurrentLevel")

	self.mount_model = RoleModel.New()
	self.mount_model:SetDisplay(self.mount_display.ui3d_display)

	self:ListenEvent("OnClickActivate",
		BindTool.Bind(self.OnClickActivate, self))
	self:ListenEvent("Close",
		BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickUpGrade",
		BindTool.Bind(self.OnClickUpGrade, self))
	self:ListenEvent("OnClickUseIma",
		BindTool.Bind(self.OnClickUseIma, self))
	self:ListenEvent("OnClickCancleIma",
		BindTool.Bind(self.OnClickCancleIma, self))

	self.list_view = self:FindObj("ListView")
	self.upgrade_btn = self:FindObj("UpGradeButton")
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("Item"))

	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetMountNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshMountCell, self)
end

function MultiMountHuanHuaView:__delete()
	self.index = 1
	self.grade = nil
	self.item_id = nil
	self.mount_special_image = nil
end

function MultiMountHuanHuaView:ReleaseCallBack()
	self:ClearTimerQuest()
	if self.mount_model ~= nil then
		self.mount_model:DeleteMe()
		self.mount_model = nil
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
	self.mount_display = nil
	self.have_pro_num = nil
	self.need_pro_num = nil
	self.button_text = nil
	self.gong_ji = nil
	self.fang_yu = nil
	self.sheng_ming = nil
	self.fight_power = nil
	self.mount_name = nil
	self.show_upgrade_btn = nil
	self.show_activate_btn = nil
	self.show_use_ima_btn = nil
	self.show_use_image = nil
	self.cur_level = nil
	self.show_cur_level = nil
	self.list_view = nil
	self.upgrade_btn = nil
end

function MultiMountHuanHuaView:GetMountNumberOfCells()
	return MultiMountData.Instance:GetMaxSpecialImage()
end

function MultiMountHuanHuaView:RefreshMountCell(cell, cell_index)
	local mount_special_image = MultiMountData.Instance:GetMultiMountHuanhuaCfg()
	local mount_cell = self.cell_list[cell]
	if mount_cell == nil then
		mount_cell = MultiMountHuanHuaCell.New(cell.gameObject)
		self.cell_list[cell] = mount_cell
	end
	mount_cell:SetToggleGroup(self.list_view.toggle_group)
	mount_cell:SetHighLight(self.index == cell_index + 1)
	local data = {}
	data.image_name = mount_special_image[cell_index+1].image_name
	data.item_id = mount_special_image[cell_index+1].item_id
	data.index = cell_index+1
	data.is_show = MultiMountData.Instance:CanHuanhuaUpgrade() == (cell_index + 1)
	mount_cell:SetData(data)
	mount_cell:ListenClick(BindTool.Bind(self.OnClickListCell, self, mount_special_image[cell_index+1], cell_index+1, mount_cell))
end

function MultiMountHuanHuaView:OnClickClose()
	self:Close()
	self.grade = nil
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	self.res_id = nil
	self.used_imageid = nil
end

function MultiMountHuanHuaView:OpenCallBack()
	self:Flush()
	self.index = 1
	self:SetModleRestAni()
end

--点击激活按钮
function MultiMountHuanHuaView:OnClickActivate()
	local data_list = ItemData.Instance:GetBagItemDataList()
	local mount_special_image = MultiMountData.Instance:GetMultiMountHuanhuaCfg()
	self.item_id = mount_special_image[self.index].item_id
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
function MultiMountHuanHuaView:OnClickUpGrade()
	local attr_cfg = MultiMountData.Instance:GetSpecialImageUpgradeInfo(self.index)
	if attr_cfg ~= nil then
		if attr_cfg.grade >= MultiMountData.Instance:GetSpecialImageMaxUpLevelById(attr_cfg.special_img_id) then
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
	MultiMountCtrl.Instance:SendMultiModuleReq(MULTI_MOUNT_REQ_TYPE.MULTI_MOUNT_REQ_TYPE_UPLEVEL_SPECIAL_IMG, self.index)
end

--点击使用当前形象
function MultiMountHuanHuaView:OnClickUseIma()
	MultiMountCtrl.Instance:SendMultiModuleReq(MULTI_MOUNT_REQ_TYPE.MULTI_MOUNT_REQ_TYPE_USE_SPECIAL_IMG, self.index)
end

--点击取消当前形象
function MultiMountHuanHuaView:OnClickCancleIma()
	MultiMountCtrl.Instance:SendMultiModuleReq(MULTI_MOUNT_REQ_TYPE.MULTI_MOUNT_REQ_TYPE_USE_SPECIAL_IMG, 0)
end

function MultiMountHuanHuaView:OnClickListCell(mount_special_data, index, mount_cell)
	self.mount_special_image = mount_special_data
	mount_cell:SetHighLight(true)
	if self.index == index then return end
	self.index = index or 1
	self.item_id = mount_special_data.item_id
	self:SetSpecialImageAttr(mount_special_data, index)
end

--获取激活坐骑符数量
function MultiMountHuanHuaView:GetHaveProNum(item_id, need_num)
	local count = ItemData.Instance:GetItemNumInBagById(item_id)
	if count < need_num then
		count = string.format(Language.Mount.ShowRedNum, count)
	end
	self.have_pro_num:SetValue(count)
end

function MultiMountHuanHuaView:SetModleRestAni()
	self.timer = self.fix_show_time
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	if not self.time_quest then
		self.time_quest = GlobalTimerQuest:AddRunQuest(function()
			self.timer = self.timer - UnityEngine.Time.deltaTime
			if self.timer <= 0 then
				if self.mount_model then
					local part = self.mount_model.draw_obj:GetPart(SceneObjPart.Main)
					if part then
						part:SetTrigger(ANIMATOR_PARAM.REST)
					end
				end
				self.timer = self.fix_show_time
			end
		end, 0)
	end
end

function MultiMountHuanHuaView:ClearTimerQuest()
	if self.delay_timer_quest then
		GlobalTimerQuest:CancelQuest(self.delay_timer_quest)
		self.delay_timer_quest = nil
	end	
end

function MultiMountHuanHuaView:SetSpecialImageAttr(mount_special_data, index)
	if mount_special_data == nil then
		return
	end
	local upgrade_cfg = MultiMountData.Instance:GetSpecialImageUpgradeInfo(mount_special_data.image_id)
	if nil == upgrade_cfg then return end
	local image_cfg = MultiMountData.Instance:GetMultiMountHuanhuaCfgByIndex(mount_special_data.image_id)
	if nil == image_cfg then return end
	local item_cfg = ItemData.Instance:GetItemConfig(image_cfg.item_id)
	self.mount_name:SetValue("<color="..APPEARANCE_NAME_COLOR[item_cfg and item_cfg.color or 5]..">"..mount_special_data.image_name.."</color>")
	if self.res_id ~= image_cfg.res_id then

		PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
		local bundle, asset = ResPath.GetMountModel(image_cfg.res_id)
		local load_list = {{bundle, asset}}
		self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
				self.mount_model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.MOUNT], image_cfg.res_id, DISPLAY_PANEL.HUAN_HUA)
				self.mount_model:SetMainAsset(ResPath.GetMountModel(image_cfg.res_id))
			end)
		local cfg = self.mount_model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.MOUNT], image_cfg.res_id, DISPLAY_PANEL.HUAN_HUA)
		if cfg then
			self:ClearTimerQuest()
			self.delay_timer_quest = GlobalTimerQuest:AddDelayTimer(function()
				self.mount_model.draw_obj.root.transform.localPosition = cfg.position
				self.mount_model.draw_obj.root.transform.localRotation = Quaternion.Euler(cfg.rotation.x, cfg.rotation.y, cfg.rotation.z)
				self.mount_model.draw_obj.root.transform.localScale = cfg.scale
				end, 0.1)
		end
		local part = self.mount_model.draw_obj:GetPart(SceneObjPart.Main)
		if part then
			part:SetTrigger(ANIMATOR_PARAM.REST)
		end
		self.res_id = image_cfg.res_id
	end
	local attr = CommonStruct.Attribute()
	local attr_cfg = MultiMountData.Instance:GetSpecialImageUpgradeInfo(mount_special_data.image_id)
	if attr_cfg ~= nil then
		attr.max_hp =  attr_cfg.maxhp
		attr.gong_ji = attr_cfg.gongji
		attr.fang_yu = attr_cfg.fangyu
		-- attr.ming_zhong =  attr_cfg.mingzhong
		-- attr.shan_bi = attr_cfg.shanbi
		-- attr.bao_ji = attr_cfg.baoji
		-- attr.jian_ren = attr_cfg.jianren
		self.grade = MultiMountData.Instance:IsMultiMountImageActive(mount_special_data.image_id) and attr_cfg.grade or -1
		-- self.zizhi_dan_limit:SetValue(attr_cfg.shuxingdan_count)
		self.cur_level:SetValue(attr_cfg.grade)
		self.need_pro_num:SetValue(upgrade_cfg.stuff_num or 1)
		self:GetHaveProNum(mount_special_data.item_id, upgrade_cfg.stuff_num)
	end

	self.used_imageid = MultiMountData.Instance:GetMultiMountHuanhuaId()

	local capability = CommonDataManager.GetCapability(attr)
	self.fight_power:SetValue(capability)
	self.sheng_ming:SetValue(attr.max_hp)
	self.gong_ji:SetValue(attr.gong_ji)
	self.fang_yu:SetValue(attr.fang_yu)
	-- self.ming_zhong:SetValue(attr.ming_zhong)
	-- self.shan_bi:SetValue(attr.shan_bi)
	-- self.bao_ji:SetValue(attr.bao_ji)
	-- self.jian_ren:SetValue(attr.jian_ren)

	local data = {item_id = mount_special_data.item_id, is_bind = 0}
	self.item:SetData(data)
	self:IsGrayUpgradeButton(self.index)
	self:IsShowActivate(self.index)
	self:IsShowUpGrade(self.index)
end

--设置激活按钮显示和隐藏
function MultiMountHuanHuaView:IsShowActivate(image_id)
	if image_id == nil then
		return
	end

	local is_act = MultiMountData.Instance:IsMultiMountImageActive(image_id)
	local used_imageid = MultiMountData.Instance:GetMultiMountHuanhuaId()

	self.show_activate_btn:SetValue(not is_act) --把32位转换成table,返回1，表示激活
	self.show_use_ima_btn:SetValue(is_act)
	self.show_use_image:SetValue(is_act)
	self.show_cur_level:SetValue(is_act)
	if is_act then
		self.show_use_ima_btn:SetValue(image_id ~= used_imageid)
		self.show_use_image:SetValue(image_id == used_imageid)
	end
end

--设置升级按钮显示和隐藏
function MultiMountHuanHuaView:IsShowUpGrade(image_id)
	if image_id == nil then
		return
	end
	local is_act = MultiMountData.Instance:IsMultiMountImageActive(image_id)
	self.show_upgrade_btn:SetValue(is_act)
end

--升级按钮是否置灰
function MultiMountHuanHuaView:IsGrayUpgradeButton(index)
	if index == nil or index < 0 then return end
	local mount_special_image = MultiMountData.Instance:GetMultiMountHuanhuaCfg()
	local upgrade_cfg = MultiMountData.Instance:GetSpecialImageUpgradeInfo(mount_special_image[index].image_id)
	if upgrade_cfg and upgrade_cfg.grade < MultiMountData.Instance:GetSpecialImageMaxUpLevelById(mount_special_image[index].image_id) then
		self.upgrade_btn.button.interactable = true
		self.button_text:SetValue(Language.Common.UpGrade)
	else
		self.upgrade_btn.button.interactable = false
		self.button_text:SetValue(Language.Common.YiManJi)
	end
end

function MultiMountHuanHuaView:OnFlush(param_list)
	local mount_special_image = MultiMountData.Instance:GetMultiMountHuanhuaCfg()
	local upgrade_cfg = MultiMountData.Instance:GetSpecialImageUpgradeInfo(mount_special_image[self.index].image_id)
	if nil == upgrade_cfg then return end
	local is_act = MultiMountData.Instance:IsMultiMountImageActive(image_id)
	local used_imageid = MultiMountData.Instance:GetMultiMountHuanhuaId()
	if not self.grade or (self.grade < upgrade_cfg.grade and is_act) or (self.used_imageid ~= used_imageid) then
		self:GetHaveProNum(self.item_id, upgrade_cfg.stuff_num)
		self:IsShowActivate(self.index)
		self:IsShowUpGrade(self.index)
		self:SetSpecialImageAttr(mount_special_image[self.index], self.index)
		self:IsGrayUpgradeButton(self.index)
		self.list_view.scroller:RefreshActiveCellViews()
	end
end

MultiMountHuanHuaCell = MultiMountHuanHuaCell or BaseClass(BaseRender)

function MultiMountHuanHuaCell:__init()
	self.icon = self:FindVariable("Icon")
	self.name = self:FindVariable("Name")
	self.show_red_ponit = self:FindVariable("ShowRedPoint")
end

function MultiMountHuanHuaCell:SetData(data)
	if data == nil then
		return
	end
	local bundle, asset = ResPath.GetItemIcon(data.item_id)
	self.icon:SetAsset(bundle, asset)

	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if item_cfg == nil then return end
	local name_str = "<color="..APPEARANCE_NAME_COLOR[item_cfg.color]..">".. data.image_name .."</color>"
	self.name:SetValue(name_str)
	self.show_red_ponit:SetValue(data.is_show)
end

function MultiMountHuanHuaCell:ListenClick(handler)
	self:ClearEvent("Click")
	self:ListenEvent("Click", handler)
end

function MultiMountHuanHuaCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function MultiMountHuanHuaCell:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end
