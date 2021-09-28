FirstChargeContentView = FirstChargeContentView or BaseClass(BaseRender)

function FirstChargeContentView:__init(instance)
	FirstChargeContentView.Instance = self
	self:ListenEvent("chongzhi_click_1", BindTool.Bind(self.ChongZhiClick1, self))
	self:ListenEvent("chongzhi_click_2", BindTool.Bind(self.ChongZhiClick2, self))
	self:ListenEvent("chong_zhi", BindTool.Bind(self.OnChongZhiClick, self))
	self:ListenEvent("reward_click", BindTool.Bind(self.OnRewardClick, self))
	self.show_recharge = self:FindVariable("show_recharge")
	self.show_reward = self:FindVariable("show_reward")
	self.reward_btn_img = self:FindVariable("reward_btn_img")
	self.reward_text_change = self:FindVariable("reward_text_change")
	self.been_gray = self:FindVariable("been_gray")
	self.btn_1 = self:FindVariable("btn_1")
	self.btn_2 = self:FindVariable("btn_2")
	self.reward_btn = self:FindObj("reward_btn")
	self.display_l = self:FindObj("display_l")
	self.display_r = self:FindObj("display_r")
	self.l_fp = self:FindVariable("L_Fp")
	self.r_fp = self:FindVariable("R_Fp")
	self.item_list = {}
	self.image_list = {}
	self.select_item_info = {}
	self.item_name_list = {}
	self.item_desc_list = {}
	for i=1,3 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("item_" .. i))
		-- for j=1,8 do
		-- 	local handler = function()
		-- 		local close_call_back = function()
		-- 			self:CancelHighLight()
		-- 		end
		-- 		self.item_list[j]:ShowHighLight(true)
		-- 		TipsCtrl.Instance:OpenItem(self.item_list[j]:GetData(), nil, nil, close_call_back)
		-- 	end
		-- 	self.item_list[j] = ItemCell.New(self:FindObj("item_" .. j))
		-- 	self.item_list[j]:ListenClick(handler)
		-- end
		self.image_list[i] = self:FindObj("image_" .. i)
		self.item_name_list[i] = self:FindVariable("item_name_" .. i)
		self.item_desc_list[i] = self:FindVariable("item_desc_" .. i)
	end
	self.charge_toggle_10 = self:FindObj("charge_toggle_10")

	self.show_left_red_point = self:FindVariable("ShowLeftRedPoint")
	self.show_right_red_point = self:FindVariable("ShowRightRedPoint")

	self.charge_toggle_99 = self:FindObj("charge_toggle_99")

	self:InitModel()
end

function FirstChargeContentView:__delete()
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
	self.reward_text_change = nil
	self.been_gray = nil
end

function FirstChargeContentView:InitModel()
	local reward_cfg =DailyChargeData.Instance:GetFirstRewardByWeek()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	--left_model
	self.model_l = RoleModel.New("super_artical_charge_panel")
	self.model_l:SetDisplay(self.display_l.ui3d_display)
	local num_str = string.format("%02d", reward_cfg.wepon_index)
	local weapon_show_id = "100" .. main_role_vo.prof .. num_str
	local bundle, asset = ResPath.GetWeaponShowModel(weapon_show_id)
	self.model_l:SetMainAsset( bundle, asset, function ()
		local part = self.model_l.draw_obj:GetPart(SceneObjPart.Main)
		part:SetTrigger("action")
	end)

	--right_model
	self.model_r = RoleModel.New("super_charge_panel")
	self.model_r:SetDisplay(self.display_r.ui3d_display)

	local fashion_cfg = ConfigManager.Instance:GetAutoConfig("shizhuangcfg_auto").cfg
	local res_id = 0
	for k,v in pairs(fashion_cfg) do
		if reward_cfg.fashion_index == v.index and v["resouce" .. main_role_vo.prof .. main_role_vo.sex] then
			res_id = v["resouce" .. main_role_vo.prof .. main_role_vo.sex]
		end
	end
	self.model_r:SetMainAsset(ResPath.GetRoleModel(res_id))
	local job_cfgs = ConfigManager.Instance:GetAutoConfig("rolezhuansheng_auto").job
	local role_job = job_cfgs[main_role_vo.prof]
	if role_job ~= nil then
		local weapon_res_id = role_job["right_red_weapon" .. main_role_vo.sex]
		local weapon2_res_id = role_job["left_red_weapon" .. main_role_vo.sex]
		self.model_r:SetWeaponResid(weapon_res_id)
		self.model_r:SetWeapon2Resid(weapon2_res_id)
	end

	local item_info_list = DailyChargeData.Instance:GetFirstGiftInfoList(CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10)
	if item_info_list and item_info_list[1] then
		local gifts_info = DailyChargeData.Instance:GetChongZhiReward(CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10).first_reward_item
		local gift_id = gifts_info and gifts_info.item_id or 0
		local data = CommonStruct.ItemDataWrapper()
		data.item_id = item_info_list[1].item_id
		data.param = CommonStruct.ItemParamData()
		data.param.xianpin_type_list = ForgeData.Instance:GetEquipXianpinAttr(data.item_id, gift_id)
		self.l_fp:SetValue(EquipData.Instance:GetEquipLegendFightPowerByData(data,
		false, true, nil))
	end
	-- item_info_list = DailyChargeData.Instance:GetFirstGiftInfoList(CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99)
	-- if item_info_list and item_info_list[1] then
		self.r_fp:SetValue(2500)
	-- end
end

function FirstChargeContentView:OpenCallBack()
	-- local Chongzhi10State = DailyChargeData.Instance:GetFirstChongzhi10State()
	-- local Chongzhi99State = DailyChargeData.Instance:GetFirstChongzhi99State()
	-- if not Chongzhi10State and Chongzhi99State then
		-- self.charge_toggle_99.toggle.isOn = true
	-- 	self.chongzhi_state = CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99
	-- self:OnFlushRewardBtn(CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99)
		-- self:ChongZhiClick2(true)
	-- else
		-- self.charge_toggle_10.toggle.isOn = true
	-- 	self.chongzhi_state = CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10
	-- self:OnFlushRewardBtn(CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10)
		self:ChongZhiClick1(true)
	-- end
	-- self:SetBtnText()

	self:FlushRedPoints()
end

function FirstChargeContentView:SetBtnText()
	local reward_cfg = DailyChargeData.Instance:GetDailyChongzhiRewardAuto()
	self.btn_1:SetValue(reward_cfg[1].need_total_chongzhi)
	self.btn_2:SetValue(reward_cfg[2].need_total_chongzhi)
end

function FirstChargeContentView:ChongZhiClick1(is_click)
	if is_click then
		self:FlushChongzhiItem(CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10)
		-- self.chongzhi_state = CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10
		self:OnFlushRewardBtn(CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10)
		self:FlushItemDesc(1)
	end
end

function FirstChargeContentView:ChongZhiClick2(is_click)
	-- if is_click then
	-- 	self:FlushChongzhiItem(CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99)
	-- 	self.chongzhi_state = CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99
	-- 	self:OnFlushRewardBtn(CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99)
	-- 	self:FlushItemDesc(2)
	-- end
end

function FirstChargeContentView:OnChongZhiClick()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
	DailyChargeCtrl.Instance:GetView():OnCloseClick()
end

function FirstChargeContentView:OnFlush()
	self:FlushRedPoints()
	self:OnFlushRewardBtn(CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10)
end

function FirstChargeContentView:OnRewardClick()
	local bags_grid_num = ItemData.Instance:GetEmptyNum()
	if bags_grid_num > 0 then
		self.reward_btn.button.interactable = false
		self.reward_btn_img:SetAsset("uis/images_atlas", "btn_06")
		self.reward_text_change:SetValue(Language.FirstCharge.ButtonText2)
		RechargeCtrl.Instance:SendChongzhiFetchReward(CHONGZHI_REWARD_TYPE.CHONGZHI_REWARD_TYPE_FIRST, DailyChargeData.Instance:GetRewardSeq(CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10), 0)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
	end
end

function FirstChargeContentView:FlushChongzhiItem(chongzhi_state)
	local item_info_list = DailyChargeData.Instance:GetFirstGiftInfoList(chongzhi_state)
	local gifts_info = DailyChargeData.Instance:GetChongZhiReward(chongzhi_state).first_reward_item
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

function FirstChargeContentView:FlushRedPoints()
	local Chongzhi10State = DailyChargeData.Instance:GetFirstChongzhi10State()
	-- local Chongzhi99State = DailyChargeData.Instance:GetFirstChongzhi99State()
	local history_recharge = DailyChargeData.Instance:GetChongZhiInfo().history_recharge or 0

	if Chongzhi10State then
		if history_recharge < CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10 then
			self.show_left_red_point:SetValue(false)
		else
			self.show_left_red_point:SetValue(true)
		end
	else
		self.show_left_red_point:SetValue(false)
	end

	-- if Chongzhi99State then
	-- 	if history_recharge < CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99 then
	-- 		self.show_right_red_point:SetValue(false)
	-- 	else
	-- 		self.show_right_red_point:SetValue(true)
	-- 	end
	-- else
	-- 	self.show_right_red_point:SetValue(false)
	-- end
end

function FirstChargeContentView:OnFlushRewardBtn(money)
	local Chongzhi10State = DailyChargeData.Instance:GetFirstChongzhi10State()
	-- local Chongzhi99State = DailyChargeData.Instance:GetFirstChongzhi99State()
	local history_recharge = DailyChargeData.Instance:GetChongZhiInfo().history_recharge or 0

	self.reward_btn.button.interactable = true
	self.reward_btn_img:SetAsset("uis/images_atlas", "btn_06")
	if money == CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10 then
		if Chongzhi10State then
			if history_recharge < CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10 then
				self.show_recharge:SetValue(true)
				self.show_reward:SetValue(false)
				-- self.show_left_red_point:SetValue(false)
			else
				self.show_recharge:SetValue(false)
				-- self.show_left_red_point:SetValue(true)
				self.show_reward:SetValue(true)
			end
		else
			self.show_recharge:SetValue(false)
			self.show_reward:SetValue(true)
			self.reward_btn.button.interactable = false
			-- self.show_left_red_point:SetValue(false)
			self.been_gray:SetValue(false)
			self.reward_text_change:SetValue(Language.FirstCharge.ButtonText)
		end
	-- elseif money == CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99 then
	-- 	if Chongzhi99State then
	-- 		if history_recharge < CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99 then
	-- 			self.show_recharge:SetValue(true)
	-- 			self.show_reward:SetValue(false)
	-- 			-- self.show_right_red_point:SetValue(false)
	-- 		else
	-- 			self.show_recharge:SetValue(false)
	-- 			self.show_reward:SetValue(true)
	-- 			-- self.show_right_red_point:SetValue(true)
	-- 		end
	-- 	else
	-- 		self.show_recharge:SetValue(false)
	-- 		self.show_reward:SetValue(true)
	-- 		self.reward_btn.button.interactable = false
	-- 		-- self.show_right_red_point:SetValue(false)
	-- 		self.reward_btn_img:SetAsset("uis/images_atlas", "Button_7Login01")
	-- 	end
	end
end

function FirstChargeContentView:CancelHighLight()
	for k,v in pairs(self.item_list) do
		v:ShowHighLight(false)
	end
end

function FirstChargeContentView:FlushItemDesc(index)
	for i = 1, 3 do
		self.item_name_list[i]:SetValue(Language.FirstCharge.ItemName[i][index])
		self.item_desc_list[i]:SetValue(Language.FirstCharge.ItemDesc[i][index])
	end
end