ShengongHuanHuaView = ShengongHuanHuaView or BaseClass(BaseView)

function ShengongHuanHuaView:__init()
	self.ui_config = {"uis/views/advanceview","MountHuanHuaView"}
	self.play_audio = true
	self.item_id = 0
	self.index = 1
	self.grade = nil
	self.shengong_special_image = nil
	self.res_id = nil
	self.used_imageid = nil

	self:SetMaskBg()
	-- self.view_layer = UiLayer.Pop
	self.all_num = 0
	self.all_data = {}

end

function ShengongHuanHuaView:LoadCallBack()
	self.shengong_display = self:FindObj("ShengongDisplay")
	self.shengong_display:SetActive(true)
	self.have_pro_num = self:FindVariable("ActivateProNum")
	self.need_pro_num = self:FindVariable("ExchangeNeedNum")
	self.button_text = self:FindVariable("ButtonText")
	self.gong_ji = self:FindVariable("GongJi")
	self.fang_yu = self:FindVariable("FangYu")
	self.sheng_ming = self:FindVariable("ShengMing")
	self.ming_zhong = self:FindVariable("MingZhong")
	-- self.zizhi_dan_limit = self:FindVariable("ZiZhiDan")
	self.fight_power = self:FindVariable("FightPower")
	self.up_power = self:FindVariable("UpCap")
	self.is_show_power_up_label = self:FindVariable("IsShowPowerUpLabel")
	self.get_tujing_1 = self:FindVariable("GetTuJing1")
	self.get_tujing_2 = self:FindVariable("GetTuJing2")
	self.shengong_name = self:FindVariable("ZuoQiName")
	self.show_upgrade_btn = self:FindVariable("IsShowUpGrade")
	self.show_activate_btn = self:FindVariable("IsShowActivate")
	self.show_use_ima_btn = self:FindVariable("IsShowUseImaButton")
	self.show_use_image = self:FindVariable("IsShowUseImage")
	self.cur_level = self:FindVariable("CurrentLevel")
	self.show_cur_level = self:FindVariable("ShowCurrentLevel")
	self.title_name = self:FindVariable("TitleName")
	self.title_name:SetValue(Language.HuanHua.ZuJi)
	self.list_view = self:FindObj("ListView")
	self.upgrade_btn = self:FindObj("UpGradeButton")
	self.title_icon = self:FindVariable("Title_Icon")			--幻化标题图标

	self.show_btn_left = self:FindVariable("ShowBtnLeft")
	self.show_btn_right = self:FindVariable("ShowBtnRight")
	--self.name_res = self:FindVariable("NameRes")
	self.name_obj = self:FindObj("NameObj")
	self:ListenEvent("OnClickBtnLeft",
		BindTool.Bind(self.OnClickChange, self, -1))

	self:ListenEvent("OnClickBtnRight",
		BindTool.Bind(self.OnClickChange, self, 1))

	self.left_display = self:FindObj("ShengongDisplay")
	local ui_foot = self:FindObj("UI_Foot")
	local foot_camera = self:FindObj("FootCamera")
	self.foot_parent = {}
	for i = 1, 3 do
		self.foot_parent[i] = self:FindObj("Foot_" .. i)
	end
	local camera = foot_camera:GetComponent(typeof(UnityEngine.Camera))
	local random_num = math.random(100, 9999)
	if not IsNil(camera) then
		-- self.left_display.ui3d_display:Display(ui_foot.gameObject, camera)
		self.left_display.ui3d_display:DisplayPerspectiveWithOffset(ui_foot.gameObject, Vector3(random_num, random_num, random_num), Vector3(0, 8, 1.2), Vector3(90, 0, 0))
	end

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("Item"))
	self.shengong_model = RoleModel.New()
	self:ListenEvent("OnClickActivate",
		BindTool.Bind(self.OnClickActivate, self))
	self:ListenEvent("Close",
		BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickUpGrade",
		BindTool.Bind(self.OnClickUpGrade, self))
	self:ListenEvent("OnClickUseIma",
		BindTool.Bind(self.OnClickUseIma, self))

	self.all_num, self.all_data = ShengongData.Instance:GetShowSpecialInfo()

	if self.data_listen == nil then
		self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
		PlayerData.Instance:ListenerAttrChange(self.data_listen)
	end

	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetShengongNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshShengongCell, self)
	self.cell_list = {}
end

function ShengongHuanHuaView:__delete()
	self.index = 1
	self.shengong_special_image = nil
	self.grade = nil
end

function ShengongHuanHuaView:ReleaseCallBack()
	if self.data_listen ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end	

	self.title_name = nil
	self.res_id = nil
	self.used_imageid = nil
	self.list_view = nil
	self.upgrade_btn = nil
	self.shengong_display = nil
	self.have_pro_num = nil
	self.need_pro_num =nil
	self.button_text = nil
	self.gong_ji = nil
	self.fang_yu = nil
	self.sheng_ming = nil
	self.ming_zhong = nil
	self.fight_power = nil
	self.up_power = nil
	self.is_show_power_up_label =nil
	self.get_tujing_1 = nil
	self.get_tujing_2 = nil
	self.shengong_name = nil
	self.show_upgrade_btn = nil
	self.show_activate_btn = nil
	self.show_use_ima_btn = nil
	self.show_use_image = nil
	self.cur_level = nil
	self.show_cur_level = nil
	self.list_view = nil
	self.upgrade_btn = nil
	self.title_icon = nil
	self.show_btn_left = nil
	self.show_btn_right = nil
	self.left_display = nil
	--self.name_res = nil
	self.name_obj = nil
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
end

function ShengongHuanHuaView:FlushData()
	--self.all_num, self.all_data = ShengongData.Instance:GetShowSpecialInfo()
	self:Flush("shengonghuanhua", {need_flush = true})
end

function ShengongHuanHuaView:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "level" and self:IsOpen() then
		self:FlushData()
	end
end

function ShengongHuanHuaView:GetShengongNumberOfCells()
	--return ShengongData.Instance:GetShowSpecialInfo()
	return self.all_num
end

function ShengongHuanHuaView:RefreshShengongCell(cell, cell_index)
	--local shengong_special_image = ShengongData.Instance:GetSpecialImageCfg(cell_index + 1)
	--local _, shengong_special_image = ShengongData.Instance:GetShowSpecialInfo()
	local shengong_cell = self.cell_list[cell]
	if shengong_cell == nil then
		shengong_cell = ShengongHuanHuaCell.New(cell.gameObject)
		self.cell_list[cell] = shengong_cell
	end
	shengong_cell:SetToggleGroup(self.list_view.toggle_group)
	shengong_cell:SetHighLight(self.index == cell_index + 1)
	local data = {}
	if self.all_data[cell_index + 1] ~= nil then
		data.head_id = self.all_data[cell_index + 1].head_id
		data.image_name = self.all_data[cell_index + 1].image_name
		data.item_id = self.all_data[cell_index + 1].item_id
		data.index = cell_index+1
		local image_id = self.all_data[cell_index + 1].image_id
		data.is_show = ShengongData.Instance:CanHuanhuaUpgrade()[image_id] ~= nil
	end

	shengong_cell:SetData(data)
	shengong_cell:ListenClick(BindTool.Bind(self.OnClickListCell, self, self.all_data[cell_index+1], cell_index+1, shengong_cell))
end

function ShengongHuanHuaView:OnClickChange(change_value)
	if change_value ~= nil then
		--local mount_special_image = ShengongData.Instance:GetSpecialImagesCfg()
		--local max = #mount_special_image
		local max = self.all_num
		local change_index = self.index
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

function ShengongHuanHuaView:OnClickClose()
	self:Close()
	self.grade = nil
	self.res_id = nil
	self.used_imageid = nil
end

function ShengongHuanHuaView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	if item_id ~= nil and ShengongData.Instance:CheckIsHuanHuaItem(item_id) then
		local now_num = ShengongData.Instance:GetShowSpecialInfo()
		if self.all_num ~= now_num then
			self:Flush("shengonghuanhua", {need_flush = true})
		end
	end
end

function ShengongHuanHuaView:CloseCallBack()
	self:CancelTheQuest()

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end	
end

function ShengongHuanHuaView:OpenCallBack()
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
	self:Flush("shengonghuanhua")
	self.index = 1
end

--点击激活按钮
function ShengongHuanHuaView:OnClickActivate()
	if self.all_data[self.index] == nil then
		return
	end

	local data_list = ItemData.Instance:GetBagItemDataList()
	--local _, shengong_special_image = ShengongData.Instance:GetShowSpecialInfo()
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
function ShengongHuanHuaView:OnClickUpGrade()
	if self.all_data[self.index] == nil then
		return
	end

	local attr_cfg = ShengongData.Instance:GetSpecialImageUpgradeInfo(self.all_data[self.index].image_id)
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
	ShengongHuanHuaCtrl.Instance:ShengongSpecialImaUpgrade(self.all_data[self.index].image_id)
end

--点击使用当前形象
function ShengongHuanHuaView:OnClickUseIma()
	if self.all_data[self.index] == nil then
		return
	end
	ShengongCtrl.Instance:SendUseShengongImage(self.all_data[self.index].image_id + GameEnum.MOUNT_SPECIAL_IMA_ID)
end

function ShengongHuanHuaView:OnClickListCell(shengong_special_data, index, shengong_cell)
	self.shengong_special_image = shengong_special_data
	shengong_cell:SetHighLight(true)
	if self.index == index then return end
	self.index = index or 1
	self.item_id = shengong_special_data.item_id
	self:SetSpecialImageAttr(shengong_special_data, shengong_special_data.image_id)

	local mount_special_image = ShengongData.Instance:GetSpecialImagesCfg()
	-- if self.show_btn_left ~= nil then
	-- 	self.show_btn_left:SetValue(change_index > 1)
	-- end

	-- if self.show_btn_right ~= nil then
	-- 	self.show_btn_right:SetValue(change_index < #mount_special_image)
	-- end	
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
	local image_cfg = ShengongData.Instance:GetSpecialImageCfg(index)
	local info_list = ShengongData.Instance:GetShengongInfo()
	local active_flag = info_list.active_special_image_flag
	local bit_list = bit:d2b(active_flag)

	local item_cfg = ItemData.Instance:GetItemConfig(image_cfg.item_id)
	local change_name_list = Split(shengong_special_data.image_name, "-")
	local change_name = (#change_name_list >= 2) and (change_name_list[1] .. " - " .. change_name_list[2]) or shengong_special_data.image_name
	--self.shengong_name:SetValue("<color=" .. SOUL_NAME_COLOR[item_cfg and item_cfg.color or 5] .. ">" .. change_name .. "</color>")
	if self.name_obj ~= nil then
		local bundle, asset = ResPath.GetAdvanceEquipIcon("hh_foot_" .. (image_cfg.title_res or 1))
		self.name_obj:GetComponent(typeof(UnityEngine.UI.Image)):LoadSprite(bundle, asset, function()
			self.name_obj:GetComponent(typeof(UnityEngine.UI.Image)):SetNativeSize()
		end)
	end	

	if self.res_id == nil or self.res_id ~= shengong_special_data.res_id then
		-- self.shengong_model:SetDisplay(self.shengong_display.ui3d_display)
		-- self.shengong_model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.SHENGONG], image_cfg.res_id, DISPLAY_PANEL.HUAN_HUA)
		-- self.shengong_model:SetMainAsset("effects2/prefab/ui_prefab", "Foot_UI_" .. image_cfg.res_id)
		self.res_id = shengong_special_data.res_id
		self:Set3DModel(shengong_special_data.res_id)
	end

	local attr = CommonStruct.Attribute()
	local attr_cfg = ShengongData.Instance:GetSpecialImageUpgradeInfo(index)
	if attr_cfg ~= nil then
		attr.max_hp =  attr_cfg.maxhp
		attr.gong_ji = attr_cfg.gongji
		attr.fang_yu = attr_cfg.fangyu
		attr.ming_zhong =  attr_cfg.mingzhong
		attr.shan_bi = attr_cfg.shanbi
		attr.bao_ji = attr_cfg.baoji
		self.grade = 0 ~= bit_list[32 - index] and attr_cfg.grade or -1
		-- self.zizhi_dan_limit:SetValue(attr_cfg.shuxingdan_count)
		self.cur_level:SetValue(attr_cfg.grade)
		self.need_pro_num:SetValue(upgrade_cfg.stuff_num or 1)
		self:GetHaveProNum(shengong_special_data.item_id, upgrade_cfg.stuff_num)
	end

	local attr2 = CommonStruct.Attribute()
	local next_cfg = ShengongData.Instance:GetSpecialImageUpgradeInfo(index, nil, true)
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

	local data = {item_id = shengong_special_data.item_id, is_bind = 0}
	self.item:SetData(data)
	self:IsShowActivate(self.all_data[self.index].image_id)
	self:IsShowUpGrade(self.all_data[self.index].image_id)
	self:IsGrayUpgradeButton(self.index)
end


function ShengongHuanHuaView:Set3DModel(image_id)
	self:CancelTheQuest()
	for i = 1, 3 do
		local bundle, asset = ResPath.GetFootEffec("Foot_" .. image_id)
		PrefabPool.Instance:Load(AssetID(bundle, asset), function (prefab)
			if nil == prefab then
				return
			end
			if self.foot_parent[i] then
				local parent_transform = self.foot_parent[i].transform
				for j = 0, parent_transform.childCount - 1 do
					GameObject.Destroy(parent_transform:GetChild(j).gameObject)
				end
				local obj = GameObject.Instantiate(prefab)
				local obj_transform = obj.transform
				obj_transform:SetParent(parent_transform, false)
				PrefabPool.Instance:Free(prefab)
			end
		end)
	end
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
function ShengongHuanHuaView:IsShowUpGrade(image_id)
	if image_id == nil then
		return
	end
	local special_img_up = ShengongData.Instance:GetSpecialImageUpgradeCfg()
	local info_list = ShengongData.Instance:GetShengongInfo()
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
function ShengongHuanHuaView:IsGrayUpgradeButton(index)
	if index == nil or index < 0 then return end
	--local shengong_special_image = ShengongData.Instance:GetSpecialImageCfg(index)
	--local _, shengong_special_image = ShengongData.Instance:GetShowSpecialInfo()
	local upgrade_cfg = ShengongData.Instance:GetSpecialImageUpgradeInfo(self.all_data[index].image_id)
	if upgrade_cfg.grade < ShengongData.Instance:GetSpecialImageMaxUpLevelById(self.all_data[index].image_id) then
		self.upgrade_btn.button.interactable = true
		self.button_text:SetValue(Language.Common.UpGrade)
	else
		self.upgrade_btn.button.interactable = false
		self.button_text:SetValue(Language.Common.YiManJi)
	end
end

function ShengongHuanHuaView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "shengonghuanhua" then
			local need_change = false
			local old_id = nil
			if self.all_data ~= nil and self.all_data[self.index] then
				old_id = self.all_data[self.index].image_id
			end
			self.all_num, self.all_data = ShengongData.Instance:GetShowSpecialInfo()
			local image_id = self.all_data[self.index]
			if old_id ~= nil and old_id ~= image_id then
				need_change = true
			end
			self.title_icon:SetAsset("uis/views/advanceview_images","icon_shengonghuanhua")
			--local shengong_special_image = ShengongData.Instance:GetSpecialImageCfg(self.index)
			--local _, shengong_special_image = ShengongData.Instance:GetShowSpecialInfo()
			if self.all_data ~= nil and self.index ~= nil and self.all_data[self.index] == nil then
				self.index = 1
			end
			if v.need_flush then
				self.list_view.scroller:ReloadData(0)
			else
				self.list_view.scroller:RefreshActiveCellViews()
			end
			local upgrade_cfg = ShengongData.Instance:GetSpecialImageUpgradeInfo(self.all_data[self.index].image_id)
			local info_list = ShengongData.Instance:GetShengongInfo()
			local active_flag = info_list.active_special_image_flag
			local bit_list = bit:d2b(active_flag)
			if  self.all_data[self.index] ~= nil and self.grade and (self.grade <= upgrade_cfg.grade and 0 ~= bit_list[32 - self.all_data[self.index].image_id]) or (self.used_imageid ~= info_list.used_imageid) or need_change then
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
			-- 	self.show_btn_right:SetValue(self.index < #ShengongData.Instance:GetSpecialImagesCfg())
			-- end
		end
	end
end


function ShengongHuanHuaView:SetModel(info)
	-- self.shengong_model:ResetRotation()
	-- self.shengong_model:SetGoddessModelResInfo(info)
	-- self.shengong_model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.SHENGONG], 001001, DISPLAY_PANEL.HUAN_HUA)
	self:CancelTheQuest()
end

function ShengongHuanHuaView:CancelTheQuest()
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function ShengongHuanHuaView:CalToShowAnim()
	self.timer = FIX_SHOW_TIME
	self:CancelTheQuest()
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		self.timer = self.timer - UnityEngine.Time.deltaTime
		if self.timer <= 0 then
			self.shengong_model:SetTrigger("attack1")
			self.timer = FIX_SHOW_TIME
		end
	end, 0)
end
------------------------

ShengongHuanHuaCell = ShengongHuanHuaCell or BaseClass(BaseCell)

function ShengongHuanHuaCell:__init()
	-- self.icon = self:FindVariable("Icon")
	self.name = self:FindVariable("Name")
	self.name_hl = self:FindVariable("Name_HL")
	self.show_red_ponit = self:FindVariable("ShowRedPoint")
	self.is_possess_img = self:FindVariable("Is_Possess")
	self.index = 0	
end

function ShengongHuanHuaCell:OnFlush()
	if self.data == nil or next(self.data) == nil then
		return
	end
	-- local bundle, asset = ResPath.GetItemIcon(self.data.item_id)
	-- self.icon:SetAsset(bundle, asset)

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then return end
	--local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">".. self.data.image_name .."</color>"
	local name_str = self.data.image_name
	self.name:SetValue(name_str)
	self.name_hl:SetValue(self.data.image_name)
	self.show_red_ponit:SetValue(self.data.is_show)
	self.index = self.data.index

	local info_list = ShengongData.Instance:GetShengongInfo()
	local active_flag = info_list.active_special_image_flag
	local bit_list = bit:d2b(active_flag)
	local _, special_data = ShengongData.Instance:GetShowSpecialInfo()
	local image_id = special_data[self.index].image_id
	self.is_possess_img:SetValue(bit_list[32 - image_id] == 1)
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
