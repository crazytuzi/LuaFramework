WingHuanHuaView = WingHuanHuaView or BaseClass(BaseView)

function WingHuanHuaView:__init()
	self.ui_config = {"uis/views/advanceview","MountHuanHuaView"}
	self.play_audio = true
	self.item_id = 0
	self.index = 1
	self.grade = nil
	self.wing_special_image = nil
	self.res_id = nil
	self.used_imageid = nil
	-- self.view_layer = UiLayer.Pop
	self.cell_list = {}
	self:SetMaskBg()

	self.all_num = 0
	self.all_data = {}

end

function WingHuanHuaView:LoadCallBack()
	self.wing_display = self:FindObj("WingDisplay")
	self.wing_display:SetActive(true)
	self.title_name = self:FindVariable("TitleName")
	self.title_name:SetValue(Language.HuanHua.Wing)

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
	self.up_power = self:FindVariable("UpCap")
	self.is_show_power_up_label = self:FindVariable("IsShowPowerUpLabel")
	self.get_tujing_1 = self:FindVariable("GetTuJing1")
	self.get_tujing_2 = self:FindVariable("GetTuJing2")
	self.wing_name = self:FindVariable("ZuoQiName")
	self.show_upgrade_btn = self:FindVariable("IsShowUpGrade")
	self.show_activate_btn = self:FindVariable("IsShowActivate")
	self.show_use_ima_btn = self:FindVariable("IsShowUseImaButton")
	self.show_use_image = self:FindVariable("IsShowUseImage")
	self.cur_level = self:FindVariable("CurrentLevel")
	self.show_cur_level = self:FindVariable("ShowCurrentLevel")
	self.title_icon = self:FindVariable("Title_Icon")			--幻化标题图标

	self.show_btn_left = self:FindVariable("ShowBtnLeft")
	self.show_btn_right = self:FindVariable("ShowBtnRight")
	--self.name_res = self:FindVariable("NameRes")
	self.name_obj = self:FindObj("NameObj")
	self:ListenEvent("OnClickBtnLeft",
		BindTool.Bind(self.OnClickChange, self, -1))

	self:ListenEvent("OnClickBtnRight",
		BindTool.Bind(self.OnClickChange, self, 1))

	self.wing_model = RoleModel.New("wing_huanhua_panel", 300)
	self.wing_model:SetDisplay(self.wing_display.ui3d_display)

	self:ListenEvent("OnClickActivate",
		BindTool.Bind(self.OnClickActivate, self))
	self:ListenEvent("Close",
		BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickUpGrade",
		BindTool.Bind(self.OnClickUpGrade, self))
	self:ListenEvent("OnClickUseIma",
		BindTool.Bind(self.OnClickUseIma, self))

	self.all_num, self.all_data = WingData.Instance:GetShowSpecialInfo()

	self.list_view = self:FindObj("ListView")
	self.upgrade_btn = self:FindObj("UpGradeButton")
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("Item"))

	if self.data_listen == nil then
		self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
		PlayerData.Instance:ListenerAttrChange(self.data_listen)
	end

	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetWingNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshWingCell, self)
end

function WingHuanHuaView:__delete()
	self.index = 1
	self.grade = nil
	self.item_id = nil
	self.res_id = nil
	self.wing_special_image = nil
	self.used_imageid = nil
end

function WingHuanHuaView:ReleaseCallBack()
	if self.wing_model ~= nil then
		self.wing_model:DeleteMe()
		self.wing_model = nil
	end

	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end	

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	if self.item ~= nil then
		self.item:DeleteMe()
		self.item = nil
	end

	self.wing_display = nil
	self.have_pro_num = nil
	self.need_pro_num = nil
	self.button_text = nil
	self.gong_ji = nil
	self.fang_yu = nil
	self.sheng_ming = nil
	self.fight_power = nil
	self.up_power = nil
	self.is_show_power_up_label =nil
	self.get_tujing_1 = nil
	self.get_tujing_2 = nil
	self.wing_name = nil
	self.show_upgrade_btn = nil
	self.show_activate_btn = nil
	self.show_use_ima_btn = nil
	self.show_use_image = nil
	self.cur_level = nil
	self.show_cur_level = nil
	self.list_view = nil
	self.upgrade_btn = nil
	self.title_name = nil
	self.title_icon = nil
	self.show_btn_left = nil
	self.show_btn_right = nil
	--self.name_res = nil
	self.name_obj = nil
end

function WingHuanHuaView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	if item_id ~= nil and WingData.Instance:CheckIsHuanHuaItem(item_id) then
		local now_num = WingData.Instance:GetShowSpecialInfo()
		if self.all_num ~= now_num then
			self:Flush("winghuanhua", {need_flush = true})
		end
	end
end

function WingHuanHuaView:CloseCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end	
end

function WingHuanHuaView:FlushData()
	--self.all_num, self.all_data = WingData.Instance:GetShowSpecialInfo()
	self:Flush("winghuanhua", {need_flush = true})
end

function WingHuanHuaView:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "level" and self:IsOpen() then
		self:FlushData()
	end
end

function WingHuanHuaView:GetWingNumberOfCells()
	--return WingData.Instance:GetShowSpecialInfo()
	return self.all_num
end

function WingHuanHuaView:RefreshWingCell(cell, cell_index)
	--local wing_special_image = ConfigManager.Instance:GetAutoConfig("wing_auto").special_img
	--local _, wing_special_image = WingData.Instance:GetShowSpecialInfo()
	local wing_cell = self.cell_list[cell]
	if wing_cell == nil then
		wing_cell = WingHuanHuaCell.New(cell.gameObject)
		self.cell_list[cell] = wing_cell
	end
	wing_cell:SetToggleGroup(self.list_view.toggle_group)
	wing_cell:SetHighLight(self.index == cell_index + 1)
	local data = {}
	if self.all_data[cell_index+1] ~= nil then
		data.head_id = self.all_data[cell_index+1].head_id
		data.image_name = self.all_data[cell_index+1].image_name
		data.item_id = self.all_data[cell_index+1].item_id
		data.index = cell_index+1
		local image_id = self.all_data[cell_index + 1].image_id
		data.is_show = WingData.Instance:CanHuanhuaUpgrade()[image_id] ~= nil
	end

	wing_cell:SetData(data)
	wing_cell:ListenClick(BindTool.Bind(self.OnClickListCell, self, self.all_data[cell_index+1], cell_index+1, wing_cell))
end

function WingHuanHuaView:OnClickChange(change_value)
	if change_value ~= nil then
		local mount_special_image = ConfigManager.Instance:GetAutoConfig("wing_auto").special_img
		--local max = #mount_special_image
		--local change_index = self.index
		local max = self.all_num
		change_index = change_index + change_value
		change_index = change_index < 1 and 1 or change_index
		change_index = change_index > max and max or change_index

		if self.list_view ~= nil then
			self.list_view.scroller:JumpToDataIndex(change_index - 1)
			for k,v in pairs(self.cell_list) do
				if v ~= nil and v.index == change_index then
					self:OnClickListCell(mount_special_image[change_index], change_index, v)
				end
			end
		end
	end
end

function WingHuanHuaView:OnClickClose()
	self:Close()
	self.res_id = nil
	self.grade = nil
	self.used_imageid = nil
end

function WingHuanHuaView:OpenCallBack()
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
	self:Flush("winghuanhua")
	self.index = 1
end

--点击激活按钮
function WingHuanHuaView:OnClickActivate()
	if self.all_data[self.index] == nil then
		return
	end

	local data_list = ItemData.Instance:GetBagItemDataList()
	--local wing_special_image = ConfigManager.Instance:GetAutoConfig("wing_auto").special_img
	--local _, wing_special_image = WingData.Instance:GetShowSpecialInfo()
	self.item_id = self.all_data[self.index].item_id
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

	-- if item_cfg.bind_gold == 0 then
	-- 	TipsCtrl.Instance:ShowShopView(self.item_id, 2)
	-- 	return
	-- end

	local func = function(item_id, item_num, is_bind, is_use)
		MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
	end

	TipsCtrl.Instance:ShowCommonBuyView(func, self.item_id, nil, 1)
	return
	-- TipsCtrl.Instance:ShowSystemMsg(Language.Card.CanNotUpTips)
end

--点击升级按钮
function WingHuanHuaView:OnClickUpGrade()
	if self.all_data[self.index] == nil then
		return
	end

	local attr_cfg = WingData.Instance:GetSpecialImageUpgradeInfo(self.all_data[self.index].image_id)
	if attr_cfg ~= nil then
		if attr_cfg.grade >= WingData.Instance:GetSpecialImageMaxUpLevelById(attr_cfg.special_img_id) then
			return
		end
		if ItemData.Instance:GetItemNumInBagById(attr_cfg.stuff_id) < attr_cfg.stuff_num then
			local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[attr_cfg.stuff_id]
			if item_cfg == nil then
				TipsCtrl.Instance:ShowItemGetWayView(attr_cfg.stuff_id)
				return
			end

			-- if item_cfg.bind_gold == 0 then
			-- 	TipsCtrl.Instance:ShowShopView(attr_cfg.stuff_id, 2)
			-- 	return
			-- end

			local func = function(stuff_id, item_num, is_bind, is_use)
				MarketCtrl.Instance:SendShopBuy(stuff_id, item_num, is_bind, is_use)
			end

			TipsCtrl.Instance:ShowCommonBuyView(func, attr_cfg.stuff_id, nil, attr_cfg.stuff_num)
			return
		end
	end
	WingHuanHuaCtrl.Instance:WingSpecialImaUpgrade(self.all_data[self.index].image_id)
end

--点击使用当前形象
function WingHuanHuaView:OnClickUseIma()
	if self.all_data[self.index] == nil then
		return
	end
	WingCtrl.Instance:SendUseWingImage(self.all_data[self.index].image_id + GameEnum.MOUNT_SPECIAL_IMA_ID)
end

function WingHuanHuaView:OnClickListCell(wing_special_data, index, wing_cell)
	self.wing_special_image = wing_special_data
	wing_cell:SetHighLight(true)
	if self.index == index then return end
	self.index = index or 1
	self.item_id = wing_special_data.item_id
	self:SetSpecialImageAttr(wing_special_data, wing_special_data.image_id)

	local mount_special_image = ConfigManager.Instance:GetAutoConfig("wing_auto").special_img
	-- if self.show_btn_left ~= nil then
	-- 	self.show_btn_left:SetValue(change_index > 1)
	-- end

	-- if self.show_btn_right ~= nil then
	-- 	self.show_btn_right:SetValue(change_index < #mount_special_image)
	-- end	
end

--获取激活坐骑符数量
function WingHuanHuaView:GetHaveProNum(item_id, need_num)
	local count = ItemData.Instance:GetItemNumInBagById(item_id)
	-- if count < need_num then
	-- 	count = string.format(Language.Mount.ShowRedNum, count)
	-- end

	if count < need_num then
		count = string.format(Language.Mount.ShowRedNum, count)
	else
		count = string.format(Language.Mount.ShowGreenNum, count)
	end
	self.have_pro_num:SetValue(count)
end

function WingHuanHuaView:SetSpecialImageAttr(wing_special_data, index)
	if wing_special_data == nil then
		return
	end
	local upgrade_cfg = WingData.Instance:GetSpecialImageUpgradeInfo(wing_special_data.image_id)
	local image_cfg = WingData.Instance:GetSpecialImageCfg(index)
	local info_list = WingData.Instance:GetWingInfo()
	-- local active_flag = info_list.active_special_image_flag
	local bit_list = info_list.active_special_image_list

	local item_cfg = ItemData.Instance:GetItemConfig(image_cfg.item_id)
	local change_name_list = Split(wing_special_data.image_name, "-")
	local change_name = (#change_name_list >= 2) and (change_name_list[1] .. " - " .. change_name_list[2]) or wing_special_data.image_name
	--self.wing_name:SetValue("<color=" .. SOUL_NAME_COLOR[item_cfg and item_cfg.color or 5] .. ">" .. change_name .. "</color>")
	if self.name_obj ~= nil then
		local bundle, asset = ResPath.GetAdvanceEquipIcon("hh_wing_" .. (image_cfg.title_res or 1))
		self.name_obj:GetComponent(typeof(UnityEngine.UI.Image)):LoadSprite(bundle, asset, function()
			self.name_obj:GetComponent(typeof(UnityEngine.UI.Image)):SetNativeSize()
		end)
	end

	if self.res_id ~= image_cfg.res_id then
		-- local cfg = self.wing_model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.ROLE_WING], WingData.Instance:GetWingModelResCfg(), DISPLAY_PANEL.HUAN_HUA)
		-- self.wing_model:SetTransform(cfg)
		self.wing_model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.WING], image_cfg.res_id, DISPLAY_PANEL.HUAN_HUA)
		local bundle, asset = ResPath.GetWingModel(image_cfg.res_id)	
		self.wing_model:SetMainAsset(bundle, asset)
		self.wing_model:SetLayer(1, 1.0)
		self.res_id = image_cfg.res_id
	end

	self.used_imageid = info_list.used_imageid
	local attr = CommonStruct.Attribute()
	local attr_cfg = WingData.Instance:GetSpecialImageUpgradeInfo(index)
	if attr_cfg ~= nil then
		attr.max_hp =  attr_cfg.maxhp
		attr.gong_ji = attr_cfg.gongji
		attr.fang_yu = attr_cfg.fangyu
		-- attr.ming_zhong =  attr_cfg.mingzhong
		-- attr.shan_bi = attr_cfg.shanbi
		-- attr.bao_ji = attr_cfg.baoji
		-- attr.jian_ren = attr_cfg.jianren
		self.grade = 0 ~= bit_list[index] and attr_cfg.grade or -1
		-- self.zizhi_dan_limit:SetValue(attr_cfg.shuxingdan_count)
		self.cur_level:SetValue(attr_cfg.grade)
		self.need_pro_num:SetValue(upgrade_cfg.stuff_num or 1)
		self:GetHaveProNum(wing_special_data.item_id, upgrade_cfg.stuff_num)
	end

	local attr2 = CommonStruct.Attribute()
	local next_cfg = WingData.Instance:GetSpecialImageUpgradeInfo(index, nil, true)
	if next_cfg ~= nil then
		attr2.max_hp =  self.grade ~= -1 and next_cfg.maxhp - attr_cfg.maxhp or next_cfg.maxhp
		attr2.gong_ji = self.grade ~= -1 and next_cfg.gongji - attr_cfg.gongji or next_cfg.gongji
		attr2.fang_yu = self.grade ~= -1 and next_cfg.fangyu - attr_cfg.fangyu or next_cfg.fangyu
	end

	local capability = CommonDataManager.GetCapabilityCalculation(attr)
	local capability2 = CommonDataManager.GetCapabilityCalculation(attr2)
	self.fight_power:SetValue(capability)
	self.up_power:SetValue(capability2)
	self.is_show_power_up_label:SetValue(self.grade ~= -1)
	self.sheng_ming:SetValue(attr.max_hp)
	self.gong_ji:SetValue(attr.gong_ji)
	self.fang_yu:SetValue(attr.fang_yu)
	-- self.ming_zhong:SetValue(attr.ming_zhong)
	-- self.shan_bi:SetValue(attr.shan_bi)
	-- self.bao_ji:SetValue(attr.bao_ji)
	-- self.jian_ren:SetValue(attr.jian_ren)

	local data = {item_id = wing_special_data.item_id, is_bind = 0}
	self.item:SetData(data)

	self:IsShowActivate(self.all_data[self.index].image_id)
	self:IsShowUpGrade(self.all_data[self.index].image_id)
	self:IsGrayUpgradeButton(self.index)
end

--设置激活按钮显示和隐藏
function WingHuanHuaView:IsShowActivate(image_id)
	if image_id == nil then
		return
	end
	local info_list = WingData.Instance:GetWingInfo()
	-- local active_flag = info_list.active_special_image_flag
	local bit_list = info_list.active_special_image_list
	self.show_activate_btn:SetValue(0 == bit_list[image_id]) --把32位转换成table,返回1，表示激活
	self.show_use_ima_btn:SetValue(0 ~= bit_list[image_id])
	self.show_use_image:SetValue(0 ~= bit_list[image_id])
	self.show_cur_level:SetValue(0 ~= bit_list[image_id])
	if info_list.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
		self.show_use_ima_btn:SetValue(image_id ~= (info_list.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID)
													and 0 ~= bit_list[image_id])
		self.show_use_image:SetValue(image_id == (info_list.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID)
													and 0 ~= bit_list[image_id])
	else
		self.show_use_ima_btn:SetValue(0 ~= bit_list[image_id])
		self.show_use_image:SetValue(false)
	end
end

--设置升级按钮显示和隐藏
function WingHuanHuaView:IsShowUpGrade(image_id)
	if image_id == nil then
		return
	end
	local special_img_up = WingData.Instance:GetSpecialImageUpgradeCfg()
	local info_list = WingData.Instance:GetWingInfo()
	-- local active_flag = info_list.active_special_image_flag
	local bit_list = info_list.active_special_image_list
	for k, v in pairs(special_img_up) do
		if v.special_img_id == image_id then
			self.show_upgrade_btn:SetValue(0 ~= bit_list[image_id])
			break
		else
			self.show_upgrade_btn:SetValue(false)
		end
	end
end

--升级按钮是否置灰
function WingHuanHuaView:IsGrayUpgradeButton(index)
	if index == nil or index < 0 then return end
	--local wing_special_image = ConfigManager.Instance:GetAutoConfig("wing_auto").special_img
	--local _, wing_special_image = WingData.Instance:GetShowSpecialInfo()
	local upgrade_cfg = WingData.Instance:GetSpecialImageUpgradeInfo(self.all_data[index].image_id)
	if upgrade_cfg.grade < WingData.Instance:GetSpecialImageMaxUpLevelById(self.all_data[index].image_id) then --GameEnum.MAX_UPGRADE_LIMIT
		self.upgrade_btn.button.interactable = true
		self.button_text:SetValue(Language.Common.UpGrade)
	else
		self.upgrade_btn.button.interactable = false
		self.button_text:SetValue(Language.Common.YiManJi)
	end
end

function WingHuanHuaView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "winghuanhua" then
			local need_change = false
			local old_id = nil
			if self.all_data ~= nil and self.all_data[self.index] then
				old_id = self.all_data[self.index].image_id
			end
			self.all_num, self.all_data = WingData.Instance:GetShowSpecialInfo()
			local image_id = self.all_data[self.index]
			if old_id ~= nil and old_id ~= image_id then
				need_change = true
			end
			self.title_icon:SetAsset("uis/views/advanceview_images", "icon_winghuanhua")
			--local wing_special_image = ConfigManager.Instance:GetAutoConfig("wing_auto").special_img
			--local wing_special_image = WingData.Instance:GetShowSpecialInfo()
			if self.all_data ~= nil and self.index ~= nil and self.all_data[self.index] == nil then
				self.index = 1
			end
			if v.need_flush then
				self.list_view.scroller:ReloadData(0)
			else
				self.list_view.scroller:RefreshActiveCellViews()
			end
			local upgrade_cfg = WingData.Instance:GetSpecialImageUpgradeInfo(self.all_data[self.index].image_id)
			local info_list = WingData.Instance:GetWingInfo()
			-- local active_flag = info_list.active_special_image_flag
			local bit_list = info_list.active_special_image_list
			if  self.all_data[self.index] ~= nil and self.grade and (self.grade <= upgrade_cfg.grade and 0 ~= bit_list[self.all_data[self.index].image_id]) or (self.used_imageid ~= info_list.used_imageid) or need_change then
				self:GetHaveProNum(self.item_id, upgrade_cfg.stuff_num)
				self:IsShowActivate(self.all_data[self.index].image_id)
				self:IsShowUpGrade(self.all_data[self.index].image_id)
				self:SetSpecialImageAttr(self.all_data[self.index], self.all_data[self.index].image_id)
				self:IsGrayUpgradeButton(self.index)
				-- self.list_view.scroller:RefreshActiveCellViews()
			end

			-- if self.show_btn_left ~= nil then
			-- 	self.show_btn_left:SetValue(self.index > 1)
			-- end

			-- if self.show_btn_right ~= nil then
			-- 	self.show_btn_right:SetValue(self.index < #wing_special_image)
			-- end
		end
	end
end

WingHuanHuaCell = WingHuanHuaCell or BaseClass(BaseCell)

function WingHuanHuaCell:__init()
	self.icon = self:FindVariable("Icon")
	self.name = self:FindVariable("Name")
	self.name_hl = self:FindVariable("Name_HL")
	self.show_red_ponit = self:FindVariable("ShowRedPoint")
	self.is_possess_img = self:FindVariable("Is_Possess")
	self.index = 0
end

function WingHuanHuaCell:OnFlush()
	if self.data == nil or next(self.data) == nil then
		return
	end
	local bundle, asset = ResPath.GetItemIcon(self.data.item_id)
	self.icon:SetAsset(bundle, asset)
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then return end
	--local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">".. self.data.image_name .."</color>"
	local name_str = self.data.image_name
	self.name:SetValue(name_str)
	self.name_hl:SetValue(self.data.image_name)
	self.show_red_ponit:SetValue(self.data.is_show)
	self.index = self.data.index

	local info_list = WingData.Instance:GetWingInfo()
	-- local active_flag = info_list.active_special_image_flag
	local bit_list = info_list.active_special_image_list
	local _, special_data = WingData.Instance:GetShowSpecialInfo()
	local image_id = special_data[self.index].image_id
	self.is_possess_img:SetValue(bit_list[image_id] == 1)
end

function WingHuanHuaCell:ListenClick(handler)
	self:ClearEvent("Click")
	self:ListenEvent("Click", handler)
end

function WingHuanHuaCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function WingHuanHuaCell:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end
