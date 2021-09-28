SecondChargeContentView = SecondChargeContentView or BaseClass(BaseRender)
-- 首充界面子界面
function SecondChargeContentView:__init(instance)
	SecondChargeContentView.Instance = self
	self:ListenEvent("chong_zhi", BindTool.Bind(self.OnChongZhiClick, self))
	self:ListenEvent("reward_click", BindTool.Bind(self.OnRewardClick, self))
	self.show_recharge = self:FindVariable("show_recharge")
	self.show_reward = self:FindVariable("show_reward")
	self.reward_btn_img = self:FindVariable("reward_btn_img")
	self.btn_1 = self:FindVariable("btn_1")
	self.btn_2 = self:FindVariable("btn_2")
	self.reward_btn = self:FindObj("reward_btn")
	self.display_l = self:FindObj("display_l")
	self.display_r = self:FindObj("display_r")
	self.l_fp = self:FindVariable("L_Fp")
	self.r_fp = self:FindVariable("R_Fp")
	self.been_gray = self:FindVariable("been_gray")
	self.can_move = self:FindVariable("can_move")
	self.item_list = {}
	self.image_list = {}
	self.red_point_list = {}
	self.select_item_info = {}
	self.item_name_list = {}
	self.item_desc_list = {}
	self.btn_name = {}
	self.point_list = {}
	self.select_index = 1
	for i=1,3 do
		self.red_point_list[i] = self:FindVariable("red_point_" .. i)
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("item_" .. i))
		self.item_list[i]:SetIconNativeSize()
		self.image_list[i] = self:FindObj("image_" .. i)
		self.item_name_list[i] = self:FindVariable("item_name_" .. i)
		self.item_desc_list[i] = self:FindVariable("item_desc_" .. i)
		self.btn_name[i] = self:FindVariable("btn_" .. i)
		self.point_list[i] = self:FindVariable("red_point_" .. i)
	end

	-- self.charge_toggle_10 = self:FindObj("charge_toggle_10")

	self.show_left_red_point = self:FindVariable("ShowLeftRedPoint")
	self.show_right_red_point = self:FindVariable("ShowRightRedPoint")

	-- self.charge_toggle_99 = self:FindObj("charge_toggle_99")

	self.model_l = RoleModel.New("super_weapon_charge_panel")
	self.model_l:SetDisplay(self.display_l.ui3d_display)

	self.model_r = RoleModel.New("super_charge_panel")
	self.model_r:SetDisplay(self.display_r.ui3d_display)

	self.left_desc = self:FindVariable("left_desc")
	self.right_desc = self:FindVariable("right_desc")
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
	self.left_desc = nil
	self.right_desc = nil
	self.can_move = nil
end

function SecondChargeContentView:SetBtnText()
	local reward_cfg = DailyChargeData.Instance:GetDailyChongzhiRewardAuto()
	self.btn_1:SetValue(reward_cfg[1].need_total_chongzhi)
	self.btn_2:SetValue(reward_cfg[2].need_total_chongzhi)
end

function SecondChargeContentView:OnChongZhiClick()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
	DailyChargeCtrl.Instance:GetView():OnCloseClick()
end

function SecondChargeContentView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		self.select_index = k
	end
	local chongzhi_state = 0

	for i=1,3 do
		chongzhi_state = DailyChargeData.Instance:GetThreechargeNeedRecharge(i)
		local index = i > 1 and 2 or 1
		self.btn_name[i]:SetValue(index == 1 and Language.FirstCharge.BtnName[1] or string.format(Language.FirstCharge.BtnName[2], chongzhi_state))
		local flag = DailyChargeData.Instance:GetFirstChongzhiState(i)
		self.red_point_list[i]:SetValue(flag)
		self.item_list[i]:SetIconNativeSize()
	end
	local chongzhi_state = DailyChargeData.Instance:GetThreechargeNeedRecharge(self.select_index)
	self.chongzhi_state = chongzhi_state
	self:FlushRedPoints()
	self:FlushChongzhiItem(chongzhi_state)
	self:OnFlushRewardBtn()
	self:FlushItemDesc(self.select_index)
	self:SetModelRes()
	self:FlushPoints()

	if self.select_index == 1 then
		bundle1,asset1 = ResPath.GetFirstChargeImage(self.select_index, "_l")
		bundle2,asset2 = ResPath.GetFirstChargeImage(self.select_index, "_r")
	else
		bundle1,asset1 = ResPath.GetFirstChargeImage(self.select_index)
		bundle2,asset2 = ResPath.GetFirstChargeImage(self.select_index)
	end
	self.left_desc:SetAsset(bundle1,asset1)
	self.right_desc:SetAsset(bundle2,asset2)

end


function SecondChargeContentView:FlushRedPoints()
	local Chongzhi99State = DailyChargeData.Instance:GetFirstChongzhi99State()
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

function SecondChargeContentView:FlushPoints()
	for i = 1, 3 do
		local active_flag, fetch_flag = DailyChargeData.Instance:GetThreeRechargeFlag(i)
		if fetch_flag == 1 or active_flag == 0 then
			self.point_list[i]:SetValue(false)
		else
			self.point_list[i]:SetValue(true)
		end
	end
end

function SecondChargeContentView:FlushChongzhiItem(chongzhi_state)
	local item_info_list = DailyChargeData.Instance:GetThreeRechargeReward(self.select_index)
	local gifts_info = DailyChargeData.Instance:GetThreeChongZhiReward(chongzhi_state).first_reward_item
	for i=1,3 do
		if item_info_list[i] then
			self.item_list[i]:SetGiftItemId(gifts_info.item_id)
			self.item_list[i]:SetData(item_info_list[i])
			self.item_list[i]:SetIconNativeSize()
			self.image_list[i]:SetActive(true)
		else
			self.image_list[i]:SetActive(false)
			self.item_list[i]:SetIconNativeSize()
		end
	end
end

function SecondChargeContentView:OnFlushRewardBtn()
	local active_flag, fetch_flag = DailyChargeData.Instance:GetThreeRechargeFlag(self.select_index)
	self.show_recharge:SetValue(active_flag ~= 1)
	self.show_reward:SetValue(active_flag == 1)
	local flag = active_flag == 1 and fetch_flag ~= 1
	self.reward_btn.button.interactable = flag
	self.been_gray:SetValue(flag)

	if fetch_flag == 1 then
		self.point_list[self.select_index]:SetValue(false)
	else
		self.point_list[self.select_index]:SetValue(true)
	end

end

function SecondChargeContentView:OnRewardClick()
	local bags_grid_num = ItemData.Instance:GetEmptyNum()
	if bags_grid_num > 0 then
		self.reward_btn.button.interactable = false
		self.been_gray:SetValue(false)
		self.point_list[self.select_index]:SetValue(false)
		self.reward_btn_img:SetAsset("uis/images_atlas", "Button_7Login01")
		RechargeCtrl.Instance:SendChongzhiFetchReward(CHONGZHI_REWARD_TYPE.CHONGZHI_REWARD_TYPE_FIRST, self.select_index - 1, 0)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
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

local Model_Type = { ["Weapon"] = 1, ["Wing"] = 2, ["Mount"] = 3}
function SecondChargeContentView:SetModelRes()
	self:ResetModel()
	local  main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local data = DailyChargeData.Instance:GetThreeChongZhiReward(self.chongzhi_state)
	local fashion_cfg = FashionData.Instance:GetClothingConfig(data.index)
	local role_res_id = fashion_cfg["resouce" .. main_role_vo.prof .. main_role_vo.sex]
	if role_res_id ~= nil then
		local bundle, asset = ResPath.GetRoleModel(role_res_id)
		self.model_r:SetMainAsset(bundle,asset)
	end
	local weapon_list = DailyChargeData.Instance:GetThreeRechargeAuto()[1]
	self.model_r:SetWeaponResid(weapon_list["model" .. main_role_vo.prof])
	if data.type == Model_Type.Weapon then
		-- 设置左边的模型
		local weapon_show_id = "100" .. main_role_vo.prof .. "02"
		local bundle, asset = ResPath.GetWeaponShowModel(tonumber(weapon_show_id),"100" .. main_role_vo.prof .. "01")
		self.model_l:SetPanelName("super_weapon_charge_panel")
		self.model_r:SetPanelName("super_charge_panel")
		self.model_l:SetMainAsset(bundle, asset, function ()
			local part = self.model_l.draw_obj:GetPart(SceneObjPart.Main)
			part:SetTrigger("action")
		end)
		local item_info_list = DailyChargeData.Instance:GetFirstGiftInfoList(CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10)
		local gifts_info = data.first_reward_item
		if item_info_list and item_info_list[1] then
			local gift_id = gifts_info and gifts_info.item_id or 0
			local data = CommonStruct.ItemDataWrapper()
			data.item_id = item_info_list[1].item_id
			data.param = CommonStruct.ItemParamData()
			data.param.xianpin_type_list = ForgeData.Instance:GetEquipXianpinAttr(data.item_id, gift_id)
			local fight_power = EquipData.Instance:GetEquipLegendFightPowerByData(data,false, true, nil)
			self.l_fp:SetValue(fight_power)
		end

		if item_info_list and item_info_list[2] then
			for k, v in pairs(FashionData.Instance:GetFashionCfgs()) do
				if v.active_stuff_id == item_info_list[2].item_id then
					local data = FashionData.Instance:GetFashionUpgradeCfg(v.index, v.part_type, false, 1)
					fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(data))
					self.r_fp:SetValue(fight_power)
				end
			end
		end
		-- 设置右边的模型
		self.can_move:SetValue(false)
	elseif data.type == Model_Type.Wing then
		local show_id = data["model" .. main_role_vo.prof]
		local bundle, asset = ResPath.GetWingModel(show_id)
		self.model_l:SetPanelName("super_artical_wing_panel")
		self.model_r:SetPanelName("super_person_wing_panel")
		self.model_l:SetMainAsset(bundle, asset)
		self.model_r:SetWingResid(show_id)
		self.can_move:SetValue(true)

		local fight_power = 0
		local item_info_list = DailyChargeData.Instance:GetThreeRechargeReward(self.select_index)
		for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_info_list[1].item_id then
				cfg = WingData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
		self.l_fp:SetValue(fight_power)
		self.r_fp:SetValue(fight_power)
	elseif data.type == Model_Type.Mount then
		local show_id = data["model" .. main_role_vo.prof]
		local bundle, asset = ResPath.GetMountModel(show_id)
		self.model_l:SetPanelName("super_mount_charge_panel")
		self.model_r:SetPanelName("super_person_mount_panel")
		self.model_l:SetMainAsset(bundle, asset)
		self.model_r:SetMountResid(show_id)
		-- 策划说那第二个奖励的翅膀显示
		local chongzhi_state = DailyChargeData.Instance:GetThreechargeNeedRecharge(2)
		local data = DailyChargeData.Instance:GetThreeChongZhiReward(chongzhi_state)
		local show_id = data["model" .. main_role_vo.prof]
		self.model_r:SetWingResid(show_id)
		self.can_move:SetValue(true)

		local fight_power = 0
		local item_info_list = DailyChargeData.Instance:GetThreeRechargeReward(self.select_index)
		for k, v in pairs(MountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_info_list[1].item_id then
				cfg = MountData.Instance:GetSpecialImageUpgradeInfo(v.image_id, 1)
				fight_power = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetAttributteByClass(cfg))
				break
			end
		end
		self.l_fp:SetValue(fight_power)
		self.r_fp:SetValue(fight_power)
	end
end

function SecondChargeContentView:ResetModel()
	self.model_r:SetWingResid(0)
	self.model_r:SetMountResid(0)
	self.model_l:ResetRotation()
	self.model_r:ResetRotation()
end