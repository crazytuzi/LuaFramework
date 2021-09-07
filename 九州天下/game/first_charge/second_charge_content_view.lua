SecondChargeContentView = SecondChargeContentView or BaseClass(BaseRender)

local asset_table = {"first_charge_title1", "first_charge_title2", "first_charge_title3"}
local res_table = {{"first_charge_2", "first_charge_5", "first_charge_8"},{"first_charge_1", "first_charge_7", "first_charge_6"}}
local show_cfg = {
	{{show_left = {equip_idx = 1, item_id = 0, fight_power = 1200}}, {res_index = 3, res_id_1 = 0, fight_power = 2340}},
	{{show_left = {equip_idx = 0, item_id = 22520, fight_power = 1600}}, {res_index = 3, res_id_1 = 8003001, fight_power = 1200}},
	{{show_left = {equip_idx = 0, item_id = 22501, fight_power = 2400}}, {res_index = 3, res_id_1 = 7012001, fight_power = 3600}}
}
-- 模型的左边角度和右边大小和角度
local model_scale = {
	l_scale = {
				{x = 1, y = 1, z = 1},
				{x = 1, y = 1, z = 1},
				{x = 1, y = 1, z = 1}
			},
	l_rotation = {
				{x = 0, y = 0, z = 0},
				{x = 0, y = 0, z = 0},
				{x = 0, y = 0, z = 0}
			},
	l_camera = {
				[1] = "second_warfare_view_l",
				[2] = "second_warfare_view_baoshi",
				[3] = "second_warfare_view_baoshi",
			},
	r_scale = {
				{x = 1, y = 1, z = 1},
				{x = 1, y = 1, z = 1},
				{x = 0.75, y = 0.75, z = 0.75}
			},
	r_rotation = {
				{x = 0, y = 0, z = 0},
				{x = 0, y = 0, z = 0},
				{x = 0, y = 25, z = 0}
			},
	r_camera = {
			[1] = "second_warfare_view_weapon_#",
			[2] = "second_warfare_view_r_wing",
			[3] = "second_warfare_view_r_mount",
	}
}

function SecondChargeContentView:__init(instance)
	SecondChargeContentView.Instance = self 
	self:ListenEvent("chongzhi_click_1", BindTool.Bind(self.ChongZhiClick1, self))
	-- self:ListenEvent("chongzhi_click_2", BindTool.Bind(self.ChongZhiClick2, self))
	self:ListenEvent("chong_zhi", BindTool.Bind(self.OnChongZhiClick, self))
	self:ListenEvent("reward_click", BindTool.Bind(self.OnRewardClick, self))
	self.show_recharge = self:FindVariable("show_recharge")
	self.show_reward = self:FindVariable("show_reward")
	--self.reward_btn_img = self:FindVariable("reward_btn_img")
	self.btn_1 = self:FindVariable("btn_1")
	self.btn_2 = self:FindVariable("btn_2")
	self.reward_btn = self:FindObj("reward_btn")
	self.reward_text = self:FindObj("reward_text")
	self.display_l = self:FindObj("display_l")
	self.display_r = self:FindObj("display_r")
	self.l_fp = self:FindVariable("L_Fp")
	self.r_fp = self:FindVariable("R_Fp")
	self.item_list = {}
	self.image_list = {}
	self.select_item_info = {}
	self.item_name_list = {}
	self.item_desc_list = {}
	self.btn_name = {}
	self.remind_image_list = {}
	self.select_index = DailyChargeData.Instance:GetShowPushIndex()
	for i=1,3 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("item_" .. i))
		self.image_list[i] = self:FindObj("image_" .. i)
		self.item_name_list[i] = self:FindVariable("item_name_" .. i)
		self.item_desc_list[i] = self:FindVariable("item_desc_" .. i)
		self.btn_name[i] = self:FindVariable("btn_name_" .. i)
		self.remind_image_list[i] = self:FindObj("RemindImage"..i)
	end

	self.desc_img = self:FindVariable("desc_img")
	self.show_item_img = self:FindVariable("show_item_img")
	self.show_role_img = self:FindVariable("show_role_img")

	self.charge_toggle_10 = self:FindObj("charge_toggle_10")

	self.show_left_red_point = self:FindVariable("ShowLeftRedPoint")
	self.show_right_red_point = self:FindVariable("ShowRightRedPoint")
	self.is_toggel1 = self:FindVariable("IsToggle1")

	self.charge_toggle_99 = self:FindObj("charge_toggle_99")

	self:InitModel()
end

function SecondChargeContentView:__delete()
	if self.model_l then
		self.model_l:DeleteMe()
		self.model_l = nil
	end

	if self.model_r then
		self.model_r:DeleteMe()
		self.model_r = nil
	end

	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	self.btn_name = {}
end

function SecondChargeContentView:InitModel()
	local reward_cfg =DailyChargeData.Instance:GetFirstRewardByWeek()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	--left_model
	self.model_l = RoleModel.New("second_warfare_view_l")
	self.model_l:SetDisplay(self.display_l.ui3d_display)
	
	--right_model
	self.model_r = RoleModel.New("second_warfare_view_r", 500)
	self.model_r:SetDisplay(self.display_r.ui3d_display)

	self:SetModelRes()
end

function SecondChargeContentView:SetModelRes()
	self.model_r:SetWingResid(0)
	self.model_r:SetMountResid(0)
	self.model_l:ResetRotation()
	self.model_r:ResetRotation()
	local show_config = DailyChargeData.Instance:GetFirstChargeShowCfg(self.select_index - 1)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local left_cfg = show_cfg[self.select_index][1]
	local need_string = left_cfg.show_left.equip_idx ~= 0 and left_cfg.show_left.equip_idx or left_cfg.show_left.item_id 
	local right_cfg = show_cfg[self.select_index][2]
	local res_index = right_cfg.res_index
	local fashion_cfg = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").cfg
	local role_res_id = 0
	for k,v in pairs(fashion_cfg) do
		if res_index == v.index and v["resouce" .. main_role_vo.prof .. main_role_vo.sex] then
			role_res_id = v["resouce" .. main_role_vo.prof .. main_role_vo.sex]
		end
	end
	-- self.model_r:SetMainAsset(ResPath.GetRoleModel(role_res_id))

	local job_cfgs = ConfigManager.Instance:GetAutoConfig("rolezhuansheng_auto").job
	local role_job = job_cfgs[main_role_vo.prof]
	if role_job ~= nil then
		local weapon_res_id = role_job["right_red_weapon" .. main_role_vo.sex]
		local weapon2_res_id = role_job["left_red_weapon" .. main_role_vo.sex]
		-- self.model_r:SetWeaponResid(weapon_res_id)
		-- self.model_r:SetWeapon2Resid(weapon2_res_id)
	end
	self.l_fp:SetValue(left_cfg.show_left.fight_power)
	self.r_fp:SetValue(right_cfg.fight_power)

	if left_cfg.show_left.equip_idx ~= 0 then
		local num_str = string.format("%02d", need_string)
		local weapon_show_id = "100" .. main_role_vo.prof .. num_str
		local bundle, asset = ResPath.GetWeaponShowModel(weapon_show_id)
		-- self.model_l:SetMainAsset(bundle, asset, function ()
		-- 	local part = self.model_l.draw_obj:GetPart(SceneObjPart.Main)
		-- 	part:SetTrigger("action")
		-- end)
		-- self.model_l:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.WEAPON], weapon_show_id, DISPLAY_PANEL.FIRST_CHARGE)
	
		-- local item_info_list = DailyChargeData.Instance:GetThreeRechargeReward()
		-- local chongzhi_state = DailyChargeData.Instance:GetThreechargeNeedRecharge(self.select_index)
		-- local gifts_info = DailyChargeData.Instance:GetThreeChongZhiReward(chongzhi_state).first_reward_item
		-- if item_info_list and item_info_list[1] then
		-- 	local gift_id = gifts_info and gifts_info.item_id or 0
		-- 	local data = CommonStruct.ItemDataWrapper()
		-- 	data.item_id = item_info_list[1].item_id
		-- 	data.param = CommonStruct.ItemParamData()
		-- 	data.param.xianpin_type_list = ForgeData.Instance:GetEquipXianpinAttr(data.item_id, gift_id)
		-- 	self.l_fp:SetValue(EquipData.Instance:GetEquipLegendFightPowerByData(data,
		-- 	false, true, nil))
		-- end
		
		-- local item_info_list = DailyChargeData.Instance:GetFirstGiftInfoList(CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10)
		-- if item_info_list and item_info_list[1] then
		-- 	local gift_id = gifts_info and gifts_info.item_id or 0
		-- 	local data = CommonStruct.ItemDataWrapper()
		-- 	data.item_id = item_info_list[1].item_id
		-- 	data.param = CommonStruct.ItemParamData()
		-- 	data.param.xianpin_type_list = ForgeData.Instance:GetEquipXianpinAttr(data.item_id, gift_id)
		-- 	self.l_fp:SetValue(EquipData.Instance:GetEquipLegendFightPowerByData(data,
		-- 	false, true, nil))
		-- end
		self.display_l.raw_image.raycastTarget = false
		self.display_r.raw_image.raycastTarget = false
	elseif left_cfg.show_left.item_res ~= 0 then
		local res_id = DailyChargeData.Instance:GetWingResId(need_string)
		local bundle, asset = ResPath.GetWingModel(res_id)
		if res_id == nil then
			res_id = DailyChargeData.Instance:GetMountResId(need_string)
			bundle, asset = ResPath.GetMountModel(res_id)
		end
		-- self.model_l:SetMainAsset(bundle, asset)
		
		local res_id_1 = right_cfg.res_id_1
		local is_wing = DailyChargeData.Instance:GetISWingByResId(res_id_1)
		-- if is_wing then
		-- 	self.model_r:SetWingResid(res_id_1)
		-- else
		-- 	self.model_r:SetWingResid(show_cfg[self.select_index - 1][2].res_id_1)
		-- 	self.model_r:SetMountResid(res_id_1)
		-- end

		-- self.model_l:SetTransform(pos_cfg[self.select_index][1])
		self.display_l.raw_image.raycastTarget = true
		self.display_r.raw_image.raycastTarget = true
	end

	local tab1 = model_scale.l_scale[self.select_index]
	local tab2 = model_scale.l_rotation[self.select_index]
	local l_camera = model_scale.l_camera[self.select_index]
	if l_camera then
		self.model_l:SetDisplayPositionAndRotation(l_camera)
	end
	self.model_l:SetMainAsset(show_config.path_1, show_config.model_id_1)
	self.model_l:SetModelScale(Vector3(tab1.x, tab1.y, tab1.z))
	self.model_l:SetRotation(Vector3(tab2.x, tab2.y, tab2.z))

	local right_path = show_config.path_2
	local right_name = show_config.model_id_2
	if string.find(right_path, "#") then
		right_path = string.gsub(right_path, "#", main_role_vo.prof)
	end
	if string.find(right_name, "#") then
		right_name = string.gsub(right_name, "#", main_role_vo.prof)
	end

	local tab3 = model_scale.r_scale[self.select_index]
	local tab4 = model_scale.r_rotation[self.select_index]
	local r_camera = model_scale.r_camera[self.select_index]
	if r_camera and string.find(r_camera, "#") then
		r_camera = string.gsub(r_camera, "#", main_role_vo.prof)
	end
	if r_camera then
		self.model_r:SetDisplayPositionAndRotation(r_camera)
	end

	local item_cfg = ItemData.Instance:GetItemConfig(show_config.first_reward_item.item_id)

	if item_cfg.is_display_role == DISPLAY_TYPE.WING then
		self.model_r:SetLayer(1, 1.0)
	else
		self.model_r:SetLayer(1, 0)
	end

	self.model_r:SetMainAsset(right_path, right_name)
	self.model_r:SetModelScale(Vector3(tab3.x, tab3.y, tab3.z))
	self.model_r:SetRotation(Vector3(tab4.x, tab4.y, tab4.z))
	
	self.desc_img:SetAsset("uis/views/firstchargeview/images/nopack_atlas", asset_table[self.select_index])
	self.show_item_img:SetAsset("uis/views/firstchargeview/images_atlas", res_table[1][self.select_index])
	self.show_role_img:SetAsset("uis/views/firstchargeview/images_atlas", res_table[2][self.select_index])
	self.is_toggel1:SetValue(self.select_index == 1)
end

function SecondChargeContentView:OpenCallBack()
	local chongzhi_state = 0
	self.select_index = DailyChargeData.Instance:GetShowPushIndex()
	self:ChongZhiClick1(true)
	self:FlushRedPoints()
	for i=1,3 do
		chongzhi_state = DailyChargeData.Instance:GetThreechargeNeedRecharge(i)
		local index = i > 1 and 2 or 1
		self.btn_name[i]:SetValue(index == 1 and Language.FirstCharge.BtnName[1] or string.format(Language.FirstCharge.BtnName[2], chongzhi_state))
	end
end

function SecondChargeContentView:SetBtnText()
	local reward_cfg = DailyChargeData.Instance:GetDailyChongzhiRewardAuto()
	self.btn_1:SetValue(reward_cfg[1].need_total_chongzhi)
	self.btn_2:SetValue(reward_cfg[2].need_total_chongzhi)
end

function SecondChargeContentView:ChongZhiClick1(is_click)
	if is_click then
		local chongzhi_state = DailyChargeData.Instance:GetThreechargeNeedRecharge(self.select_index)
		self:FlushChongzhiItem(chongzhi_state)
		self:OnFlushRewardBtn(chongzhi_state)
		self:FlushItemDesc(self.select_index)
	end
end

function SecondChargeContentView:ChongZhiClick2(is_click)
	-- if is_click then
	-- 	self:FlushChongzhiItem(chongzhi_state)
	-- 	self.chongzhi_state = chongzhi_state
	-- 	self:OnFlushRewardBtn(chongzhi_state)
	-- 	self:FlushItemDesc(2)
	-- end
end

function SecondChargeContentView:OnChongZhiClick()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
	ViewManager.Instance:Close(ViewName.DailyChargeView)
end

function SecondChargeContentView:OnFlush()
	self.select_index = DailyChargeData.Instance:GetShowPushIndex()
	self:FlushRedPoints()

	local chongzhi_state = DailyChargeData.Instance:GetThreechargeNeedRecharge(self.select_index)
	self:FlushChongzhiItem(chongzhi_state)
	self:OnFlushRewardBtn()
	self:FlushItemDesc(self.select_index)
	self:SetModelRes()
	for i=1,3 do
		local active_flag, fetch_flag = DailyChargeData.Instance:GetThreeRechargeFlag(i)
		self.remind_image_list[i]:SetActive(active_flag == 1 and fetch_flag ~= 1)
	end
end

function SecondChargeContentView:OnRewardClick()
	local bags_grid_num = ItemData.Instance:GetEmptyNum()
	if bags_grid_num > 0 then
		self.reward_btn.button.interactable = false
		self.reward_text.button.interactable = false
		-- self.reward_btn_img:SetAsset("uis/images", "Button_7Login01")
		RechargeCtrl.Instance:SendChongzhiFetchReward(CHONGZHI_REWARD_TYPE.CHONGZHI_REWARD_TYPE_FIRST, self.select_index - 1, 0)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
	end
end

function SecondChargeContentView:FlushChongzhiItem(chongzhi_state)
	local item_info_list = DailyChargeData.Instance:GetThreeRechargeReward()
	local gifts_info = DailyChargeData.Instance:GetThreeChongZhiReward(chongzhi_state).first_reward_item
	for i=1,3 do
		if item_info_list[i] then
			self.item_list[i]:SetGiftItemId(gifts_info.item_id)
			self.item_list[i]:SetData(item_info_list[i])
			self.image_list[i]:SetActive(true)
		else
			self.image_list[i]:SetActive(false)
		end
	end
end

function SecondChargeContentView:FlushRedPoints()
	local Chongzhi99State = DailyChargeData.Instance:GetFirstChongzhi99State()
	-- local Chongzhi99State = DailyChargeData.Instance:GetFirstChongzhi99State()
	local history_recharge = DailyChargeData.Instance:GetChongZhiInfo().history_recharge or 0

	if Chongzhi99State then
		if history_recharge < CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10 then
			self.show_left_red_point:SetValue(false)
		else
			self.show_left_red_point:SetValue(true)
		end
	else
		self.show_left_red_point:SetValue(false)
	end
end

function SecondChargeContentView:OnFlushRewardBtn()
	self.reward_btn.button.interactable = true
    self.reward_text.button.interactable = true
	-- self.reward_btn_img:SetAsset("uis/images", "Button_7Login")
	local active_flag, fetch_flag = DailyChargeData.Instance:GetThreeRechargeFlag(self.select_index)
	if active_flag == 1 and fetch_flag == 1 then
		self.show_recharge:SetValue(false)
		self.show_reward:SetValue(true)
		self.reward_btn.button.interactable = false
    	self.reward_text.button.interactable = false
		-- self.reward_btn_img:SetAsset("uis/images", "Button_7Login01")
	elseif active_flag == 1 and fetch_flag ~= 1 then
		self.show_recharge:SetValue(false)
		self.show_reward:SetValue(true)
	else
		self.show_recharge:SetValue(true)
		self.show_reward:SetValue(false)
	end
end

function SecondChargeContentView:CancelHighLight()
	for k,v in pairs(self.item_list) do
		v:ShowHighLight(false)
	end
end

function SecondChargeContentView:FlushItemDesc(index)
	for i = 1, 3 do
		self.item_name_list[i]:SetValue(Language.FirstCharge.ItemName[i][index])
		self.item_desc_list[i]:SetValue(Language.FirstCharge.ItemDesc[i][index])
	end
end