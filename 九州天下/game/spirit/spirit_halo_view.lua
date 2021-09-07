SpiritHaloView = SpiritHaloView or BaseClass(BaseRender)

function SpiritHaloView:__init(instance)
	self:ListenEvent("OnClickJinjie", BindTool.Bind(self.OnClickJinjie, self))
	self:ListenEvent("OnClickAutoJinjie", BindTool.Bind(self.OnClickAutoJinjie, self))
	self:ListenEvent("OnClickGetWay", BindTool.Bind(self.OnClickGetWay, self))
	self:ListenEvent("OnClickLookImage", BindTool.Bind(self.OnClickLookImage, self))
	self:ListenEvent("OnClickUseButton", BindTool.Bind(self.OnClickUseButton, self))

	-- self.display1 = self:FindObj("Display1")
	-- self.display2 = self:FindObj("Display2")

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("Item"))
	self.star_btn = self:FindObj("StartButton")
	self.auto_btn = self:FindObj("AutoButton")
	self.auto_toggle = self:FindObj("AutoToggle").toggle

	self.cur_gongji = self:FindVariable("CurGongji")
	self.cur_fangyu = self:FindVariable("CurFangyu")
	self.cur_maxhp = self:FindVariable("CurMaxhp")
	self.cur_bless = self:FindVariable("CurBless")
	self.radio = self:FindVariable("Radio")
	self.cur_grade = self:FindVariable("CurGrade")
	self.cur_grade_bg = self:FindVariable("Quality")
	self.cur_fight_power = self:FindVariable("CurFightPower")
	self.auto_btn_text = self:FindVariable("AutoBtnText")
	self.prop_name = self:FindVariable("PropName")
	self.bag_prop_num = self:FindVariable("BagPropNum")
	self.need_num = self:FindVariable("NeedNum")

	self.next_gongji = self:FindVariable("NextGongji")
	self.next_fangyu = self:FindVariable("NextFangyu")
	self.next_maxhp = self:FindVariable("NextMaxhp")
	self.next_fight_power = self:FindVariable("NextFightPower")
	self.next_grade = self:FindVariable("NextGrade")
	self.next_grade_bg = self:FindVariable("NextQuality")

	self.show_next_effect = self:FindVariable("ShowNextEffect")
	self.show_max_level_tip = self:FindVariable("ShowMaxLevelTip")
	self.show_bless_tip = self:FindVariable("ShowBlessTip")
	self.show_use_btn = self:FindVariable("ShowUseButton")
	self.show_use_image = self:FindVariable("ShowUseImage")
	self.show_huanhua_red_point = self:FindVariable("ShowHuanhuaRedPoint")

	self.is_auto = false
	self.is_can_auto = true
	self.jinjie_next_time = 0
	self.is_first_open = true
	self.cur_temp_grade = nil
	self.res_id = 0

	-- self.model_1 = RoleModel.New()
	-- self.model_1:SetDisplay(self.display1.ui3d_display)

	-- self.model_2 = RoleModel.New()
	-- self.model_2:SetDisplay(self.display2.ui3d_display)

	self.time_quest = {}
	-- self.show_stars_list = {}
	-- for i = 1, 10 do
	-- 	self.show_stars_list[i] = self:FindVariable("ShowStar"..i)
	-- end
end

function SpiritHaloView:__delete()
	self.is_auto = nil
	self.is_can_auto = nil
	self.jinjie_next_time = nil
	self.is_first_open = nil
	self.cur_temp_grade = nil
	self.res_id = nil
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	-- if self.model_1 then
	-- 	self.model_1:DeleteMe()
	-- 	self.model_1 = nil
	-- end

	-- if self.model_2 then
	-- 	self.model_2:DeleteMe()
	-- 	self.model_2 = nil
	-- end
	for k,v in pairs(self.time_quest) do
		GlobalTimerQuest:CancelQuest(v)
	end
	self.time_quest = {}
end

function SpiritHaloView:OpenCallBack()
	self.is_first_open = true
	-- if self.item_data_event == nil then
	-- 	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	-- 	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	-- end
end

function SpiritHaloView:CloseCallBack()
	self.res_id = 0
	for k,v in pairs(self.time_quest) do
		GlobalTimerQuest:CancelQuest(v)
	end
	-- if self.item_data_event ~= nil then
	-- 	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
	-- 	self.item_data_event = nil
	-- end
	self.time_quest = {}
	self.is_first_open = true
end

function SpiritHaloView:SetUppGradeOptResult(result)
	self.is_can_auto = true
	if 0 == result then
		self.is_auto = false
		self:SetAdvanceButtonState()
	elseif 1 == result then
		self:AutoUpGradeOnce()
	end
end

function SpiritHaloView:OnClickJinjie()
	local halo_info = SpiritData.Instance:GetSpiritHaloInfo()
	local grade_cfg = SpiritData.Instance:GetSpiritHaloGradeCfg()[halo_info.grade]

	if not grade_cfg then return end

	local auto_buy = self.auto_toggle.isOn and 1 or 0
	local bag_num = ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff_id)
	if bag_num < grade_cfg.upgrade_stuff_count and 0 == auto_buy then
		self.is_auto = false
		self.is_can_auto = true
		local shop_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[grade_cfg.upgrade_stuff_id]
		if shop_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(grade_cfg.upgrade_stuff_id)
			return
		end

		-- if shop_cfg.bind_gold == 0 then
		-- 	TipsCtrl.Instance:ShowShopView(grade_cfg.upgrade_stuff_id, 2)
		-- 	return
		-- end

		local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			if is_buy_quick then
				self.auto_toggle.isOn = true
			end
		end

		TipsCtrl.Instance:ShowCommonBuyView(func, grade_cfg.upgrade_stuff_id, nil,
			(grade_cfg.upgrade_stuff_count - ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff_id)))
		self:SetAdvanceButtonState()
		return
	end

	SpiritCtrl.Instance:SendSpiritHaloUpStar(auto_buy)
	self.jinjie_next_time = Status.NowTime + 0.1
end

function SpiritHaloView:AutoUpGradeOnce()
	local halo_info = SpiritData.Instance:GetSpiritHaloInfo()
	local jinjie_next_time = 0
	if nil ~= self.upgrade_timer_quest then
		if self.jinjie_next_time >= Status.NowTime then
			jinjie_next_time = self.jinjie_next_time - Status.NowTime
		end
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	end

	if halo_info.grade > 0 and halo_info.grade < SpiritData.Instance:GetMaxSpiritHaloGrade() then
		if self.is_auto then
			self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.OnClickJinjie, self), jinjie_next_time)
		end
	end
end

function SpiritHaloView:OnClickAutoJinjie()
	local halo_info = SpiritData.Instance:GetSpiritHaloInfo()
	if not halo_info or not halo_info.grade or halo_info.grade <= 0 then
		 return
	end

	if not self.is_can_auto then
		return
	end

	local function ok_callback()
		self.is_can_auto = false
		self.is_auto = self.is_auto == false
		self:OnClickJinjie()
		self:SetAdvanceButtonState()
	end

	local function canel_callback()
		self:SetAdvanceButtonState()
	end

	if not self.is_auto then
		TipsCtrl.Instance:ShowCommonAutoView("auto_spirit_halo_up", Language.Mount.AutoUpDes, ok_callback, canel_callback, true)
	else
		ok_callback()
	end
end

function SpiritHaloView:OnClickGetWay()
	ViewManager.Instance:Open(ViewName.Treasure)
end

function SpiritHaloView:OnClickLookImage()
	-- SpiritCtrl.Instance:ShowSpiritImageListView(TabIndex.spirit_halo)
	ViewManager.Instance:Open(ViewName.SpiritHaloHuanHuaView)
end

function SpiritHaloView:OnClickUseButton()
	if not self.cur_temp_grade then return end

	local grade_cfg = SpiritData.Instance:GetSpiritHaloGradeCfg()[self.cur_temp_grade]
	if not grade_cfg then return end

	SpiritCtrl.Instance:SendSpiritHaloUseImage(grade_cfg.image_id)
end

function SpiritHaloView:SetModleRestAni(model, index)
	local timer = 8
	if not self.time_quest[index] then
		self.time_quest[index] = GlobalTimerQuest:AddRunQuest(function()
			timer = timer - UnityEngine.Time.deltaTime
			if timer <= 0 then
				if model then
					model:SetTrigger("rest")
				end
				timer = 8
			end
		end, 0)
	end
end

-- 物品不足，购买成功后刷新物品数量
function SpiritHaloView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	local halo_info = SpiritData.Instance:GetSpiritHaloInfo()
	local grade_cfg = SpiritData.Instance:GetSpiritHaloGradeCfg()[halo_info.grade]
	if not grade_cfg then return end

	local bag_num = string.format(Language.Mount.ShowGreenNum, ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff_id))
	if ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff_id) < grade_cfg.upgrade_stuff_count then
		bag_num = string.format(Language.Mount.ShowRedNum, ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff_id))
	end
	self.bag_prop_num:SetValue(bag_num)
end

function SpiritHaloView:SetHaloInfo()
	local halo_info = SpiritData.Instance:GetSpiritHaloInfo()
	local max_grade = SpiritData.Instance:GetMaxSpiritHaloGrade()
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local image_cfg = SpiritData.Instance:GetSpiritHaloImageCfg()
	if not halo_info.grade or halo_info.grade <= 0 or not spirit_info or not image_cfg then
		return
	end

	if not self.cur_temp_grade then
		self.cur_temp_grade = halo_info.grade
	elseif self.cur_temp_grade < halo_info.grade then
		self.is_auto = false
		self.cur_temp_grade = halo_info.grade
	end

	local grade_cfg = SpiritData.Instance:GetSpiritHaloGradeCfg()[halo_info.grade]
	local next_grade_cfg = SpiritData.Instance:GetSpiritHaloGradeCfg()[halo_info.grade + 1]
	self.cur_bless:SetValue(halo_info.grade_bless_val.."/"..grade_cfg.bless_val_limit)
	if self.is_first_open then
		self.radio:InitValue(halo_info.grade_bless_val / grade_cfg.bless_val_limit)
	else
		self.radio:SetValue(halo_info.grade_bless_val / grade_cfg.bless_val_limit)
	end

	local spirit_cfg = nil
	if spirit_info.use_jingling_id and spirit_info.use_jingling_id > 0 then
		spirit_cfg = SpiritData.Instance:GetSpiritResIdByItemId(spirit_info.use_jingling_id)
	elseif spirit_info.jingling_list and next(spirit_info.jingling_list) then
		for k, v in pairs(spirit_info.jingling_list) do
			spirit_cfg = SpiritData.Instance:GetSpiritResIdByItemId(v.item_id)
			break
		end
	else
		local item_id = 15016
		spirit_cfg = SpiritData.Instance:GetSpiritResIdByItemId(item_id)
	end
	if not next_grade_cfg then
		local call_back = function(model, root)
			UIScene.name_list = {[1] = {"Pingtai04", true, 1}}
			UIScene:SetPingTaiActive()
			if self.time_quest[2] then
				GlobalTimerQuest:CancelQuest(self.time_quest[2])
				self.time_quest[2] = nil
			end
			UIScene:DeleteModel(2)
		end
		if UIScene.is_loading then
			UIScene:SetUISceneLoadCallBack(call_back)
		else
			call_back()
		end
	end
	if self.res_id ~= image_cfg[grade_cfg.image_id].res_id and spirit_cfg then
		local bundle_main, asset_main = ResPath.GetSpiritModel(spirit_cfg.res_id)
		local bundle_cur, asset_cur = ResPath.GetHaloModel(image_cfg[grade_cfg.image_id].res_id)
		local bundle_list_1 = {[SceneObjPart.Main] = bundle_main, [SceneObjPart.Halo] = bundle_cur}
		local asset_list_1 = {[SceneObjPart.Main] = asset_main, [SceneObjPart.Halo] = asset_cur}
		UIScene:ModelBundle(bundle_list_1, asset_list_1, 1)
		local call_back = function(model, root)
			local cfg = model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.SPIRIT], spirit_cfg.res_id)
			if root then
				if cfg then
					root.transform.localPosition = cfg.position
					root.transform.localRotation = Quaternion.Euler(cfg.rotation.x, cfg.rotation.y, cfg.rotation.z)
					root.transform.localScale = cfg.scale
				else
					root.transform.localPosition = Vector3(0, 0, 0)
					root.transform.localRotation = Quaternion.Euler(0, 0, 0)
					root.transform.localScale = Vector3(1, 1, 1)
				end
			end
			self:SetModleRestAni(model, 1)
		end
		UIScene:SetModelLoadCallBack(call_back, 1)
		if next_grade_cfg then
			local bundle_next, asset_next = ResPath.GetHaloModel(image_cfg[next_grade_cfg.image_id].res_id)
			local bundle_list_2 = {[SceneObjPart.Main] = bundle_main, [SceneObjPart.Halo] = bundle_next}
			local asset_list_2 = {[SceneObjPart.Main] = asset_main, [SceneObjPart.Halo] = asset_next}
			UIScene:ModelBundle(bundle_list_2, asset_list_2, 2)
			local call_back = function(model, root)
				local cfg = model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.SPIRIT], spirit_cfg.res_id)
				if root then
					if cfg then
						root.transform.localPosition = cfg.position
						root.transform.localRotation = Quaternion.Euler(cfg.rotation.x, cfg.rotation.y, cfg.rotation.z)
						root.transform.localScale = cfg.scale
					else
						root.transform.localPosition = Vector3(0, 0, 0)
						root.transform.localRotation = Quaternion.Euler(0, 0, 0)
						root.transform.localScale = Vector3(1, 1, 1)
					end
				end
				self:SetModleRestAni(model, 2)
			end
			UIScene:SetModelLoadCallBack(call_back, 2)
		end

		self.res_id = image_cfg[grade_cfg.image_id].res_id
	end

	local attr_list = SpiritData.Instance:SpiritHaloAttrSum()
	self.cur_gongji:SetValue(attr_list.gongji)
	self.cur_fangyu:SetValue(attr_list.fangyu)
	self.cur_maxhp:SetValue(attr_list.maxhp)

	local capability = CommonDataManager.GetCapability(attr_list)
	self.cur_fight_power:SetValue(capability)

	self.show_next_effect:SetValue(halo_info.grade < max_grade)
	self.show_max_level_tip:SetValue(halo_info.grade >= max_grade)
	self.show_bless_tip:SetValue(halo_info.grade < max_grade)
	self.show_use_image:SetValue(halo_info.used_imageid == grade_cfg.image_id)
	self.show_use_btn:SetValue(halo_info.used_imageid ~= grade_cfg.image_id)
	self.show_huanhua_red_point:SetValue(nil ~= next(SpiritData.Instance:ShowHaloHuanhuaRedPoint()))

	if halo_info.grade < max_grade then
		local next_attr_list = SpiritData.Instance:SpiritHaloAttrSum(halo_info.grade + 1)
		local next_grade_cfg = SpiritData.Instance:GetSpiritHaloGradeCfg()[halo_info.grade + 1]
		self.next_gongji:SetValue(next_attr_list.gongji)
		self.next_fangyu:SetValue(next_attr_list.fangyu)
		self.next_maxhp:SetValue(next_attr_list.maxhp)
		self.next_grade:SetValue(next_grade_cfg.gradename)
		local next_capability = CommonDataManager.GetCapability(next_attr_list, true, attr_list)
		self.next_fight_power:SetValue(next_capability)
		self:SetGradeQualityAndName(halo_info.grade, halo_info.grade + 1)
	end

	local data = {item_id = grade_cfg.upgrade_stuff_id, num = ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff_id)}
	self.item_cell:SetData(data)
	local item_cfg = ItemData.Instance:GetItemConfig(grade_cfg.upgrade_stuff_id)
	if item_cfg then
		self.prop_name:SetValue(item_cfg.name)
		local bag_num = string.format(Language.Mount.ShowGreenNum, data.num)
		if data.num < grade_cfg.upgrade_stuff_count then
			bag_num = string.format(Language.Mount.ShowRedNum, data.num)
		end
		self.bag_prop_num:SetValue(bag_num)
		self.need_num:SetValue(grade_cfg.upgrade_stuff_count)
	end
	self:SetGradeQualityAndName(halo_info.grade)
	self:SetAdvanceButtonState()
	self.is_first_open = false
end

function SpiritHaloView:SetGradeQualityAndName(grade, next_grade)
	grade = grade or SpiritData.Instance:GetSpiritHaloInfo().grade
	local grade_cfg = SpiritData.Instance:GetSpiritHaloGradeCfg()[grade]
	local next_grade_cfg = SpiritData.Instance:GetSpiritHaloGradeCfg()[next_grade]
	local max_grade = SpiritData.Instance:GetMaxSpiritHaloGrade()
	if nil == grade or nil == grade_cfg then return end
	local bundle, asset = nil, nil
	if math.floor(grade / 3 + 1) >= 5 then
		 bundle, asset = ResPath.GetSpiritHaloGradeQualityBG(5)
	else
		 bundle, asset = ResPath.GetSpiritHaloGradeQualityBG(math.floor(grade / 3 + 1))
	end
	self.cur_grade_bg:SetAsset(bundle, asset)
	self.cur_grade:SetValue(grade_cfg.gradename)
	if next_grade and next_grade <= max_grade then
		local n_bundle, n_asset = nil, nil
		if math.floor(grade / 3 + 1) >= 5 then
			 n_bundle, n_asset = ResPath.GetSpiritHaloGradeQualityBG(5)
		else
			 n_bundle, n_asset = ResPath.GetSpiritHaloGradeQualityBG(math.floor(grade / 3 + 1))
		end
		self.next_grade_bg:SetAsset(n_bundle, n_asset)
		self.next_grade:SetValue(next_grade_cfg.gradename)
	end
end

function SpiritHaloView:SetAdvanceButtonState()
	local halo_info = SpiritData.Instance:GetSpiritHaloInfo()
	local max_grade = SpiritData.Instance:GetMaxSpiritHaloGrade()
	if not halo_info or not halo_info.grade or halo_info.grade <= 0
		or halo_info.grade >= max_grade then
		self.auto_btn_text:SetValue(Language.Common.ZiDongJinJie)
		self.star_btn.button.interactable = false
		self.auto_btn.button.interactable = false
		return
	end
	if self.is_auto then
		self.auto_btn_text:SetValue(Language.Common.Stop)
		self.star_btn.button.interactable = false
		self.auto_btn.button.interactable = true
	else
		self.auto_btn_text:SetValue(Language.Common.ZiDongJinJie)
		self.star_btn.button.interactable = true
		self.auto_btn.button.interactable = true
	end
end

function SpiritHaloView:Flush()
	self:SetHaloInfo()
end