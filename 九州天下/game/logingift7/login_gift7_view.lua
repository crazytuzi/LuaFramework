SevenLoginGiftView = SevenLoginGiftView or BaseClass(BaseView)

local GODDESS_TOGGLE_INDEX = 4		-- 女神标签

local model_scale = {
	[1] = {x = 0.5, y = 0.5, z = 0.5},
	[2] = {x = 0.75, y = 0.75, z = 0.75},
	[3] = {x = 0.85, y = 0.85, z = 0.85},
	[4] = {x = 1, y = 1, z = 1},
	[5] = {x = 1, y = 1, z = 1},
	[6] = {x = 2, y = 2, z = 2},
	[7] = {x = 0.5, y = 0.5, z = 0.5},

}

function SevenLoginGiftView:__init()
	self.ui_config = {"uis/views/7logingift","7LoginGift"}
	self.full_screen = false
	self.play_audio = true
	self:SetMaskBg()
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.item_list = {}
	self.login_bt_list = {}
end

function SevenLoginGiftView:__delete()

end

function SevenLoginGiftView:ReleaseCallBack()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.SevenLoginGiftView)
	end

	for i=1,6 do
		if self.item_list[i] ~= nil then
			self.item_list[i]:DeleteMe()
			self.item_list[i] = nil
		end
	end

	for i=1,7 do
		if self.login_bt_list[i] ~= nil then
			self.login_bt_list[i]:DeleteMe()
			self.login_bt_list[i] = nil
		end

		if nil ~= self["model" .. i] then
			self["model" .. i]:DeleteMe()
			self["model" .. i] = nil
		end
	end

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.foot_display then
		self.foot_display = nil
	end

	if self.foot_display_up then
		self.foot_display_up = nil
	end

	for i = 1, 3 do
		self.foot_parent[i] = nil
		self.foot_parent_up[i] = nil
	end

	self.show_foot_camera = nil

	if self.model_beauty then
		self.model_beauty:DeleteMe()
		self.model_beauty = nil
	end

	if nil ~= self.obj_model then
		self.obj_model = nil
	end

	if nil ~= self.stone_model then
		self.stone_model:DeleteMe()
		self.stone_model = nil
	end

	-- 清理变量和对象
	self.login_daycount = nil
	self.show_bottom_bg = nil
	self.get_num = nil
	self.receive_name = nil
	self.is_model = nil
	self.display_image = nil
	self.word_bg = nil
	self.word_item_desc = nil
	self.show_block = nil
	self.show_item_eff = nil
	self.model_bg_effect = nil
	self.show_partical_eff = nil
	self.show_normal_display = nil
	self.show_reward_effect = nil

	self.day_gitf_list = nil
	self.login_bt_list = nil
	self.gift_event = nil
	self.icon_list = nil
	for i=1,7 do
		self["display" .. i] = nil
		self["desc" .. i] = nil
	end

	self.receive_bt_obj = nil
	self.receive_text = nil
	self.receive_bt = nil
	self.display = nil
	self.display_beauty = nil 
	self.stone_display = nil
	self.reward_btn = nil
	self.btn_close = nil
	self.equip_bg_effect_obj = nil
	self.show_reward_effect = nil
	self.rotate_speed = nil
	self.is_show_image = nil
	self.gift_reward_imgage = nil
	self.gift_top_imgage = nil
	self.top_show_image = nil
	self.is_can_get = nil

	Runner.Instance:RemoveRunObj(self)
end

function SevenLoginGiftView:LoadCallBack()
	self.login_daycount = self:FindVariable("login_daycount")
	self.show_bottom_bg = self:FindVariable("Show_Bottom_Bg")
	self.get_num = self:FindVariable("get_num")
	self.receive_name = self:FindVariable("receive_name")
	self.is_model = self:FindVariable("is_model")
	self.display_image = self:FindVariable("display_image")
	self.word_bg = self:FindVariable("word_bg")
	self.word_item_desc = self:FindVariable("word_item_desc")
	self.show_block = self:FindVariable("show_block")
	self.show_item_eff = self:FindVariable("ShowEffect")
	self.model_bg_effect = self:FindObj("EffectModel")
	self.show_partical_eff = self:FindVariable("show_partical_eff")
	self.show_normal_display = self:FindVariable("show_normal_display")
	self.show_reward_effect = self:FindVariable("show_reward_effect")
	self.gift_reward_imgage = self:FindVariable("GiftRewardImgage")
	self.is_show_image = self:FindVariable("IsShowImage")
	self.gift_top_imgage = self:FindVariable("GiftTopImgage")
	self.top_show_image = self:FindVariable("TopShowImage")
	self.is_can_get = self:FindVariable("is_can_get")

	self:ListenEvent("Close", BindTool.Bind(self.CloseView,self))
	self:ListenEvent("ReceiveAward", BindTool.Bind(self.ReceiveAward,self))

	for i=1,7 do
		self:ListenEvent("Event_"..i, BindTool.Bind2(self.ToggleEvent,self,i))
	end

	self.item_list = {}
	for i=1,6 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("item_"..i))
	end

	self.can_reward = 0
	self.cur_chosen_gift = 0
	self.gift_event = {}
	self.login_bt_list = {}
	self.day_gitf_list = {}
	self.icon_list = {}
	for i=1,7 do
		self.day_gitf_list[i] = self:FindVariable("day_gitf0"..i)
		self.login_bt_list[i] = LoginButtonItem.New(self:FindObj("GiftEvent"..i))
		self.gift_event[i] = self:FindObj("GiftEvent"..i)
		--self.icon_list[i] = self:FindVariable("icon_" .. i)

		self["display" .. i] = self:FindObj("Display" .. i)
		if i == 2 then
			self["model" .. i] = RoleModel.New()
		else
			self["model" .. i] = RoleModel.New("seven_day_model")
		end
		self["model" .. i]:SetDisplay(self["display" .. i].ui3d_display)
		self["desc" .. i] = self:FindVariable("desc_" .. i)
	end

	self.receive_bt_obj = self:FindObj("ReceiveBt")
	self.receive_text = self:FindObj("ReceiveText")
	-- self.bt_text = self:FindVariable("RecieveBtText")
	self.receive_bt = self:FindVariable("ReceiveButton")

	self.display = self:FindObj("Display")
	self.model = RoleModel.New("seven_day_login_view",1000)
	self.model:SetDisplay(self.display.ui3d_display)

	self.display_beauty = self:FindObj("DisplaBeauty")
	self.model_beauty = RoleModel.New()
	self.model_beauty:SetDisplay(self.display_beauty.ui3d_display)

	self.stone_display = self:FindObj("DisplayStone")
	self.stone_model = RoleModel.New()
	self.stone_model:SetDisplay(self.stone_display.ui3d_display)

	--需要引导的按钮
	self.reward_btn = self:FindObj("RewardBtn")
	self.btn_close = self:FindObj("BtnClose")

	local ui_foot = self:FindObj("UI_Foot")
	local foot_camera = self:FindObj("FootCamera")
	self.foot_display = self:FindObj("foot_display")
	self.foot_parent = {}
	for i = 1, 3 do
		self.foot_parent[i] = self:FindObj("Foot_" .. i)
	end
	local camera = foot_camera:GetComponent(typeof(UnityEngine.Camera))
	self.foot_display.ui3d_display:Display(ui_foot.gameObject, camera)
	if not IsNil(camera) then
		camera.transform.localPosition = Vector3(67.87, 5.3, -664.5)
		ui_foot.gameObject.transform.localPosition = Vector3(66.5, -1, -665.9)
	end

	local ui_foot_up = self:FindObj("UI_FootUp")
	local foot_camera_up = self:FindObj("FootCameraUp")
	self.foot_display_up = self:FindObj("foot_display_Up")
	self.foot_parent_up = {}
	for i = 1, 3 do
		self.foot_parent_up[i] = self:FindObj("FootUp_" .. i)
	end
	local camera_up = foot_camera_up:GetComponent(typeof(UnityEngine.Camera))
	self.foot_display_up.ui3d_display:Display(ui_foot_up.gameObject, camera_up)
	--if not IsNil(camera_up) then
		camera_up.transform.localPosition = Vector3(66.91, 2.06, -666.19)
		ui_foot_up.gameObject.transform.localPosition = Vector3(66.5, -1, -665.9)
	--end
	self.show_foot_camera = self:FindVariable("show_foot_camera")
	--功能引导注册
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.SevenLoginGiftView, BindTool.Bind(self.GetUiCallBack, self))
end

function SevenLoginGiftView:SetFootModle(image_id, is_up)
	--if image_id >= COMMON_CONSTS.SPECIAL_IMAGE_OFFSET then
	--	image_cfg = ShengongData.Instance:GetSpecialImageCfg(image_id - COMMON_CONSTS.SPECIAL_IMAGE_OFFSET)
	--else
	--	image_cfg = ShengongData.Instance:GetShengongImageCfg(image_id)
	--end

	--if image_cfg and image_cfg.res_id then
		for i = 1, 3 do
			local bundle, asset = ResPath.GetFootEffec(image_id)
			PrefabPool.Instance:Load(AssetID(bundle, asset), function (prefab)
				if nil == prefab then
					return
				end
				local parent_transform
				if is_up then
					if self.foot_parent_up[i] then
						parent_transform = self.foot_parent_up[i].transform
					end
				else
					if self.foot_parent[i] then
						parent_transform = self.foot_parent[i].transform
					end
				end

				if parent_transform then
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
	--end
end

function SevenLoginGiftView:SetModelDisplay(bundle, asset, display_type, model_type)
	Runner.Instance:RemoveRunObj(self)
	local tarGet = self.display.gameObject:GetComponent(typeof(UnityEngine.UI.RawImage))
	if tarGet then 
		tarGet.raycastTarget = true
	end
	self.model:ClearModel()
	self.show_foot_camera:SetValue(model_type == 99)
	self.obj_model = self.model.draw_obj.root.transform
	self.is_show_image:SetValue(false)
	self.model_type_asset = DISPLAY_TYPE.WEAPON

	if model_type == 99 then
		self:SetFootModle(asset)
	else
		if self.cur_chosen_gift == 1 then
			--self.obj_model = self.model.draw_obj.root.transform
			tarGet.raycastTarget = false
			--local prof = GameVoManager.Instance:GetMainRoleVo().prof
			--self.rotate_speed = prof == 4 and 150 or -50 
			self.rotate_speed = 100 
			Runner.Instance:AddRunObj(self, 16)
		elseif self.cur_chosen_gift == 2 then
		elseif self.cur_chosen_gift == 4 then
			self.is_show_image:SetValue(true)
			self.gift_reward_imgage:SetAsset(bundle,asset)
			return
		elseif self.cur_chosen_gift == 6 then
			self.rotate_speed = 100
			Runner.Instance:AddRunObj(self, 16)

		elseif self.cur_chosen_gift == 7 then
			self.rotate_speed = 50
			Runner.Instance:AddRunObj(self, 16)
		end

		self.model:SetDisplayPositionAndRotation("seven_Login_gift_"..self.cur_chosen_gift)
		local vect3_scale = model_scale[self.cur_chosen_gift]
		self.model:SetModelScale(Vector3(vect3_scale.x, vect3_scale.y, vect3_scale.z))
		self.model:SetMainAsset(bundle,asset)
	end
	--if display_type == 1 then
	--	self.is_model:SetValue(false)
	--	Runner.Instance:RemoveRunObj(self)
	--	self.display_image:SetAsset(bundle,asset)
	--elseif display_type == 0 then
	--	self.is_model:SetValue(true)
	
		--if model_type == DISPLAY_TYPE.HALO then
		--	local main_role = Scene.Instance:GetMainRole()
		--	self.model:SetRoleResid(main_role:GetRoleResId())
		--	self.model:SetHaloResid(asset)
		--elseif model_type == DISPLAY_TYPE.XIAN_NV then
		--	self.model_beauty:SetMainAsset(bundle,asset)
		--	self.model_beauty:SetTrigger("show_idle_1")
		--	self.model_beauty:SetModelScale(Vector3(0.8,0.8,0.8))
		--elseif model_type == DISPLAY_TYPE.MOUNT then
		--	self.model:SetMainAsset(bundle,asset)
		--	self.model:SetTrigger("rest")
		--elseif model_type == DISPLAY_TYPE.WING then
		--	self.model:SetMainAsset(bundle,asset)
		--elseif model_type == DISPLAY_TYPE.WEAPON then
				-- local gift_data = SevenLoginGiftData.Instance:GetDataByDay(7)
				-- local prof = GameVoManager.Instance:GetMainRoleVo().prof
				-- local bundle = gift_data[prof == 1 and "path" or "path_"..prof]
				-- local asset = gift_data[prof == 1 and "show_item" or "show_item_"..prof]
			-- self.model:SetMainAsset(bundle,asset)
			-- self.model_type_asset = DISPLAY_TYPE.WEAPON
		--elseif model_type == DISPLAY_TYPE.GATHER then
			-- self.model:SetMainAsset(bundle,asset)
			-- 	self.model_type_asset = DISPLAY_TYPE.GATHER
		--elseif model_type == 0 then
		--	if self.cur_chosen_gift == 6 then
		--		self.stone_model:SetMainAsset(bundle, asset)
		--	else
				--self.model:SetMainAsset(bundle,asset)
		--	end
		--end
				--tarGet.raycastTarget = true

		--local tarGet = self.display.gameObject:GetComponent(typeof(UnityEngine.UI.RawImage))
		-- if model_type == DISPLAY_TYPE.WEAPON or model_type == DISPLAY_TYPE.GATHER and asset == 5108 then
		-- 		self.obj_model = self.model.draw_obj.root.transform
		-- 		tarGet.raycastTarget = false
		-- 		Runner.Instance:AddRunObj(self, 16)
		-- 		self.rotate_speed = -70
		-- 		if model_type == DISPLAY_TYPE.WEAPON then
		-- 			local prof = GameVoManager.Instance:GetMainRoleVo().prof
		-- 			self.rotate_speed = prof == 4 and 150 or -70 
		-- 		end
		-- else
		-- 		Runner.Instance:RemoveRunObj(self)
		-- 		tarGet.raycastTarget = true
		-- end
	--	self.model:ResetRotation()
	--end

	--self.show_normal_display:SetValue(self.cur_chosen_gift == 6)
end

function SevenLoginGiftView:Update()
	if self.obj_model == nil then return end
		if self.model_type_asset == DISPLAY_TYPE.WEAPON then
			self.obj_model.localRotation = self.obj_model.localRotation * Quaternion.Euler(0,self.rotate_speed * UnityEngine.Time.deltaTime, 0)
		end
end

function SevenLoginGiftView:OpenCallBack()
	self.cur_chosen_gift = SevenLoginGiftData.Instance:GetGiftInfo().account_total_login_daycount
	if self.cur_chosen_gift > 7 then
		self.cur_chosen_gift = 7
	end

	-- 从女神面板跳转过来
	if self:GetShowIndex() == TabIndex.seven_login_goddess then
		self.cur_chosen_gift = GODDESS_TOGGLE_INDEX
	end
	self.temp_day = self.cur_chosen_gift
	self.temp_day_for = self.cur_chosen_gift
	for i=1,self.cur_chosen_gift do
		self:FlushRewardState(i)
	end

	for i = 1, 7 do
		if SevenLoginGiftData.Instance:GetLoginRewardFlag(i) then
			self.can_reward = i 
			break
		end
	end

	if nil ~= self.gift_event[self.can_reward] then
		self.gift_event[self.can_reward].toggle.isOn = true
	end

	self.login_daycount:SetValue(self.cur_chosen_gift)
	self.get_num:SetValue(SevenLoginGiftData.Instance:GetGiftRewardByDay(self.cur_chosen_gift))
	local gift_data = SevenLoginGiftData.Instance:GetDataByDay(self.cur_chosen_gift)
	local bundle = gift_data.path
	local asset = gift_data.show_item

	self.show_partical_eff:SetValue(true)

	-- if self.cur_chosen_gift == 7 then
	-- 	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	-- 	local num_str = string.format("%02d", gift_data.show_item)
	-- 	bundle, asset = ResPath.GetWeaponShowModel("100" .. main_role_vo.prof .. num_str)
	-- end

	self:SetModelDisplay(bundle, asset, gift_data.tu, gift_data.show_model)

	local login_day_list = SevenLoginGiftData.Instance:GetLoginDayList()
	local logingift7_cfg = SevenLoginGiftData.Instance:GetGiftRewardCfg()
	local data = {}
	for i=1,7 do
		data = SevenLoginGiftData.Instance:GetDataByDay(i)
		self.day_gitf_list[i]:SetValue(data.reward_text)
		if login_day_list[i] == 1 then
			self.login_bt_list[i]:ShowRedPoint(true)
		else
			self.login_bt_list[i]:ShowRedPoint(false)
		end

		local bundle, asset = ResPath.GetSevenDayGift(data.day_picture)
		self["desc" .. i]:SetValue(data.reward_text)
		local cfg = {}
		local gift_data = SevenLoginGiftData.Instance:GetDataByDay(i)
	end

	local reward_list = SevenLoginGiftData.Instance:GetRewardList(self.cur_chosen_gift)
	local gift_item_id = SevenLoginGiftData.Instance:GetDataByDay(self.cur_chosen_gift).reward_item.item_id
	for i=1,6 do
		if reward_list[i] then
			if i == 1 then
				self.item_list[i]:SetActivityEffect()
			end
			--self.item_list[i]:SetGiftItemId(gift_item_id)
			self.item_list[i]:SetData(reward_list[i])
			self.item_list[i]:SetParentActive(true)
			if i == 1 then
				self.item_list[i]:IsDestoryActivityEffect(false)
				self.item_list[i]:SetActivityEffect()
			else
				self.item_list[i]:IsDestoryActivityEffect(true)
				self.item_list[i]:SetActivityEffect()
			end
		else
			self.item_list[i]:SetParentActive(false)
		end
	end

	if self:CurDayIsReceive(self.cur_chosen_gift) then
		self:SetToggleNextOn()
	else
		self.gift_event[self.cur_chosen_gift].toggle.isOn = true
	end

	self.receive_name:SetValue(SevenLoginGiftData.Instance:GetDataByDay(self.cur_chosen_gift).show_dec1)

	local bundle, asset = ResPath.GetSevenDayGift("word_" .. self.cur_chosen_gift)
	self.word_bg:SetAsset(bundle, asset)

	local bundle, asset = ResPath.GetSevenDayGift("word_desc_" .. self.cur_chosen_gift)
	self.word_item_desc:SetAsset(bundle, asset)
	
	local bundle, asset = ResPath.GetSevenDayGift("ImageBottom" .. self.cur_chosen_gift)
	self.show_bottom_bg:SetAsset(bundle, asset)

	if gift_data.can_spin then
		self.show_block:SetValue(gift_data.can_spin == 0)
	end

	self.show_item_eff:SetValue(self.cur_chosen_gift ~= 6)

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()

	for i = 1, 7 do
		local gift_data = SevenLoginGiftData.Instance:GetDataByDay(i)
		local bundle = gift_data.path
		local asset = gift_data.show_item
		local is_ignore_cfg = false
		local scale = gift_data.scale
		if i == 4 then
			self.gift_top_imgage:SetAsset(bundle,asset)
			self.top_show_image:SetValue(true)
		elseif i == 5 then
			self:SetFootModle(asset,true)
		else
			self["model" .. i]:SetMainAsset(bundle,asset)
			self["model" .. i]:SetDisplayPositionAndRotation("seven_Login_gift_"..i)
			local vect3_scale = model_scale[i]
			self["model" .. i]:SetModelScale(Vector3(vect3_scale.x, vect3_scale.y, vect3_scale.z))
		end

		-- if gift_data.show_model == DISPLAY_TYPE.HALO then
		-- 	local main_role = Scene.Instance:GetMainRole()
		-- 	self["model" .. i]:SetRoleResid(main_role:GetRoleResId())
		-- 	self["model" .. i]:SetHaloResid(asset)
		-- elseif gift_data.show_model == DISPLAY_TYPE.XIAN_NV then
		-- 	self["model" .. i]:SetMainAsset(bundle,asset)
		-- 	self["model" .. i]:SetTrigger("show_idle_1")
		-- 	self["model" .. i]:SetModelScale(Vector3(0.7,0.7,0.7))

		-- elseif gift_data.show_model == DISPLAY_TYPE.MOUNT then
		-- 	self["model" .. i]:SetMainAsset(bundle,asset)
		-- 	self["model" .. i]:SetTrigger("rest")
		-- elseif gift_data.show_model == DISPLAY_TYPE.WING then
		-- 	self["model" .. i]:SetMainAsset(bundle,asset)
		-- elseif gift_data.show_model == DISPLAY_TYPE.WEAPON then
		-- 		local prof = GameVoManager.Instance:GetMainRoleVo().prof
		-- 		 	bundle = gift_data[prof == 1 and "path" or "path_"..prof]
		-- 		 	asset = gift_data[prof == 1 and "show_item" or "show_item_"..prof]
		-- 	self["model" .. i]:SetMainAsset(bundle, asset)

		-- elseif gift_data.show_model == DISPLAY_TYPE.GATHER then
		-- 	self["model" .. i]:SetMainAsset(bundle,asset)
		-- else
		--	self["model" .. i]:SetMainAsset(bundle,asset)
		--end
	end

	PrefabPool.Instance:Load(AssetID("effects2/prefab/ui/ui_tongyongbaoju_1_prefab", "UI_tongyongbaoju_1"), function(prefab)
		if prefab then
			if self.model_bg_effect == nil then
				return
			end
			if self.equip_bg_effect_obj  ~= nil then
				GameObject.Destroy(self.equip_bg_effect_obj)
				self.equip_bg_effect_obj = nil
			end
			local obj = GameObject.Instantiate(prefab)
			local transform = obj.transform
			transform:SetParent(self.model_bg_effect.transform, false)
			transform.localScale = Vector3(3, 3, 3)
			self.equip_bg_effect_obj = obj.gameObject
			self.color = 0
			PrefabPool.Instance:Free(prefab)
		end
	end)
end

function SevenLoginGiftView:CloseCallBack()
	self.cur_chosen_gift = 1
end

function SevenLoginGiftView:CloseView()
	self:Close()
end

function SevenLoginGiftView:FlushRewardState(fecth_day)
	local reward_id = fecth_day
	if reward_id == 0 then
		reward_id = 1
	end

	if self:CurDayIsReceive(reward_id) then
		self.receive_bt_obj.button.interactable = false 
		self.receive_text.button.interactable = false 

		self.show_reward_effect:SetValue(false)
		self.is_can_get:SetValue(false)
		self.receive_bt:SetAsset("uis/views/7logingift_images", "Button_7Login01")
		if fecth_day > 0 then
			self.login_bt_list[fecth_day]:ShowGotGift(true)
			self.login_bt_list[fecth_day]:ShowRedPoint(false)
		end
		-- 设置已领取的值为2
		SevenLoginGiftData.Instance:SetLoginDay(reward_id,2)
	else
		self.receive_bt_obj.button.interactable = true
		self.receive_text.button.interactable = true 

		self.show_reward_effect:SetValue(true)
		self.is_can_get:SetValue(true)
		self.receive_bt:SetAsset("uis/views/7logingift_images", "Button_7Login")
		if fecth_day > self.temp_day_for then
			self.receive_bt_obj.button.interactable = false
			self.receive_text.button.interactable = false 
			self.show_reward_effect:SetValue(false)
			self.is_can_get:SetValue(true)
		end
	end
end

function SevenLoginGiftView:ReceiveAward()
	if not self:CurDayIsReceive(self.cur_chosen_gift) then
		self.temp_day = self.cur_chosen_gift
		SevenLoginGiftCtrl.Instance:SendSevenDayLoginRewardReq(self.cur_chosen_gift)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.LoginDayNotFull)
	end
end

function SevenLoginGiftView:ToggleEvent(index)
	if index == self.cur_chosen_gift then return end
	if index ~= GODDESS_TOGGLE_INDEX then
		self:ShowIndex()
	end
	self.receive_name:SetValue(SevenLoginGiftData.Instance:GetDataByDay(index).show_dec1)
	self.cur_chosen_gift = index
	local reward_list = SevenLoginGiftData.Instance:GetRewardList(index)
	local gift_item_id = SevenLoginGiftData.Instance:GetDataByDay(self.cur_chosen_gift).reward_item.item_id
	for i=1,6 do
		if reward_list[i] then
			--self.item_list[i]:SetGiftItemId(gift_item_id)
			self.item_list[i]:SetData(reward_list[i])
			self.item_list[i]:SetParentActive(true)
		else
			self.item_list[i]:SetParentActive(false)
		end
	end
	local gift_data = SevenLoginGiftData.Instance:GetDataByDay(self.cur_chosen_gift)
	local bundle = gift_data.path
	local asset = gift_data.show_item
	-- if index == 7 then
	-- 	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	-- 	local num_str = string.format("%02d", gift_data.show_item)
	-- 	bundle, asset = ResPath.GetWeaponShowModel("100" .. main_role_vo.prof .. num_str)
	-- end
	self:SetModelDisplay(bundle, asset, gift_data.tu, gift_data.show_model)
	self:FlushRewardState(index)
	self.login_daycount:SetValue(index)
	self.get_num:SetValue(SevenLoginGiftData.Instance:GetGiftRewardByDay(index))

	local bundle, asset = ResPath.GetSevenDayGift("word_" .. index)
	self.word_bg:SetAsset(bundle, asset)

	local bundle, asset = ResPath.GetSevenDayGift("word_desc_" .. index)
	self.word_item_desc:SetAsset(bundle, asset)

	local bundle, asset = ResPath.GetSevenDayGift("ImageBottom" .. index)
	self.show_bottom_bg:SetAsset(bundle, asset)

	--是否可旋转
	if gift_data.can_spin then
		self.show_block:SetValue(gift_data.can_spin == 0)
	end

	self.show_item_eff:SetValue(index ~= 6)
	self.show_partical_eff:SetValue(true)
end

function SevenLoginGiftView:OnFlush()
	self:FlushRewardState(self.temp_day)
	self:FlushMainUIShow()
	self:SetToggleNextOn()
end

function SevenLoginGiftView:IsShowRedpt()
	local  login_day_list = SevenLoginGiftData.Instance:GetLoginDayList()
	for i=1,7 do
		if login_day_list[i] == 1 then
			return true
		end
	end

	return false
end

function SevenLoginGiftView:IsReceiveAll()
	local  login_day_list = SevenLoginGiftData.Instance:GetLoginDayList()
	for i=1,7 do
		if login_day_list[i] ~= 2 then
			return
		end
	end
	SevenLoginGiftData.Instance:SetIsAllReceive(true)
end

function SevenLoginGiftView:SetToggleNextOn()
	local login_day_list = SevenLoginGiftData.Instance:GetLoginDayList()

	local now_show_index = self:GetShowIndex()
	if nil ~= now_show_index and now_show_index == TabIndex.seven_login_goddess then
		self.gift_event[GODDESS_TOGGLE_INDEX].toggle.isOn = true
		self:ToggleEvent(GODDESS_TOGGLE_INDEX)
		return
	end

	for i=1,7 do
		if SevenLoginGiftData.Instance:IsCanReceive(i) then
			self.gift_event[i].toggle.isOn = true
			self:ToggleEvent(i)
			return
		end
	end
end

function SevenLoginGiftView:FlushMainUIShow()
	-- 判断是否显示红点
	GlobalEventSystem:Fire(MainUIEventType.CHANGE_RED_POINT, MainUIData.RemindingName.Seven_Login_Redpt, self:IsShowRedpt())

	-- 判断是否领取全部奖励
	self:IsReceiveAll()
end

function SevenLoginGiftView:CurDayIsReceive(day)
	local cur_day = day
	local is_reward = SevenLoginGiftData.Instance:GetLoginRewardFlag(cur_day)
	return is_reward
end

function SevenLoginGiftView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end

---------------------------------------------------------------------------- 每日奖励按钮类
LoginButtonItem = LoginButtonItem or BaseClass(BaseCell)

function LoginButtonItem:__init()
	self.got_gift = self:FindObj("GotGift")
	self.red_point = self:FindObj("RedPoint")
end

function LoginButtonItem:ShowGotGift(is_show)
	self.got_gift:SetActive(is_show)
end

function LoginButtonItem:ShowRedPoint(is_show)
	self.red_point:SetActive(is_show)
end
