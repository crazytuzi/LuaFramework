KaiFuRisingStarView = KaiFuRisingStarView or BaseClass(BaseRender)

local KaiFuRisingStarTpye = {
	[0] = "mount_jinjie", -- 坐骑
	[1] = "wing_jinjie",  -- 羽翼系统
	[2] = "fight_mount", -- 法印系统
	[3] = "halo_jinjie", -- 天罡系统
	[4] = "halidom_jinjie",  --法宝（圣物）
	[5] = "meiren_guanghuan", -- 芳华系统
	[6] = "shenyi_jinjie",  -- 披风系统
}

local KAI_FU_RI_SING_MODEL_TYPE = {
	MOUNT = 0,
	WING = 1,
	FIGHT_MOUNT = 2,
 	HALO = 3,
 	FABAO = 4,
 	BEAUTY_HOLO = 5,
 	PIFENG = 6,
 	FAZHEN = 7,
}

local KaiFuModelScale = {
	[KAI_FU_RI_SING_MODEL_TYPE.MOUNT] = {
		rotation = Vector3(0, 45, 0),
		scale = Vector3(0.7, 0.7, 0.7),
	},
	[KAI_FU_RI_SING_MODEL_TYPE.WING] = {
		rotation = Vector3(0, 0, 0),
		scale = Vector3(1, 1, 1),
	},
	[KAI_FU_RI_SING_MODEL_TYPE.FIGHT_MOUNT] = {
		rotation = Vector3(0, 0, 0),
		scale = Vector3(0.64, 0.64, 0.64),
	},
	[KAI_FU_RI_SING_MODEL_TYPE.HALO] = {
		rotation = Vector3(0, 0, 0),
		scale = Vector3(1, 1, 1),
	},
	[KAI_FU_RI_SING_MODEL_TYPE.FABAO] = {
		rotation = Vector3(0, 0, 0),
		scale = Vector3(1, 1, 1),
	},
	[KAI_FU_RI_SING_MODEL_TYPE.BEAUTY_HOLO] = {
		rotation = Vector3(0, 0, 0),
		scale = Vector3(1, 1, 1),
	},
	[KAI_FU_RI_SING_MODEL_TYPE.PIFENG] = {
		rotation = Vector3(0, 180, 0),
		scale = Vector3(1, 1, 1),
	},
	[KAI_FU_RI_SING_MODEL_TYPE.FAZHEN] = {
		rotation = Vector3(0, 0, 0),
		scale = Vector3(1, 1, 1),
	},
}

-- 升星助力
function KaiFuRisingStarView:__init()
	self.ui_config = {"uis/views/kaifuchargeview","RisingStarContent"}
	self.model = nil
end

function KaiFuRisingStarView:__delete()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end
	self.show_effect = {}
end

function KaiFuRisingStarView:CloseCallBack()
	for i = 1, 10 do
		if self.show_effect and self.show_effect[i] then
			self.show_effect[i]:SetValue(false)
		end
	end
end

function KaiFuRisingStarView:LoadCallBack()
	self.is_first_open = true
	self:ListenEvent("OnClickRisingStar", BindTool.Bind(self.OnClickRisingStar, self))
	-- self.received_text = self:FindVariable("ReceivedText")
	self.theme_text = self:FindVariable("ThemeText")
	self.recharge_text = self:FindVariable("RechargeText")
	self.time = self:FindVariable("Time")
	self.act_desc = self:FindVariable("ActivityDesc")
	self.new_tips_text = self:FindVariable("NewTipsText")

	self.is_show_gift = self:FindVariable("IsShowGift")
	self.is_show_model = self:FindVariable("IsShowModel")
	self.theme_word = self:FindVariable("ThemeWord")
	-- self.has_fetch = self:FindVariable("has_fetch")
	self.show_red_point = self:FindVariable("ShowRiSingRedPoint")


	self:ListenEvent("OnBtnTips", BindTool.Bind(self.OnBtnTipsHandler, self))

	self.model_display = self:FindObj("ModelDisplay")
	if self.model_display then
		self.model = RoleModel.New("rising_star_view")
		self.model:SetDisplay(self.model_display.ui3d_display)
	end

	self.star_lists = {}
	self.show_effect = {}
	for i = 1, 10 do
		self.star_lists[i] = {}
		self.star_lists[i].value = self:FindVariable("Star"..i)
		-- self.star_lists[i].anim = self:FindObj("Star" .. i).animator
		-- self.star_lists[i].anim:ListenEvent("AniFinish", BindTool.Bind(self.AniFinish, self, i))
		self.show_effect[i] = self:FindVariable("ShowEffect"..i)
	end

	self:ClearTimer()
	self.timer_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind2(self.Time,self),1)

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.KaiFuRiSingBtnRedPoint)
end

function KaiFuRisingStarView:OnFlush(param_list)
	local rising_star_info = KaiFuChargeData.Instance:GetShengxingzhuliInfo()

	local rising_star_cfg = KaiFuChargeData.Instance:GetRisingStarCfg()

	local cur_type = rising_star_info.func_type
	local cur_level = rising_star_info.func_level

	local bundle, asset = ResPath.GetRisingTypeNameImage(cur_type)
	self.theme_word:SetAsset(bundle, asset)

	if 0 == rising_star_info.is_max_level then 		-- 系统没达到最高级
		local function get_power(cur_cfg)
			local tab = {
				maxhp = cur_cfg and cur_cfg.maxhp or 0,
				gongji = cur_cfg and cur_cfg.gongji or 0,
				fangyu = cur_cfg and cur_cfg.fangyu or 0,
				mingzhong = cur_cfg and cur_cfg.mingzhong or 0,
				shanbi = cur_cfg and cur_cfg.shanbi or 0,
				baoji = cur_cfg and cur_cfg.baoji or 0,
				jianren = cur_cfg and cur_cfg.jianren or 0,
			}
			return CommonDataManager.GetCapabilityCalculation(tab)
		end

		local cur_level_cfg = KaiFuChargeData.Instance:GetSystemConfigByType(cur_type, cur_level)
		local next_level_cfg = KaiFuChargeData.Instance:GetSystemConfigByType(cur_type, cur_level + 1)

		local cur_power = get_power(cur_level_cfg)
		local next_power = get_power(next_level_cfg)
		local add_power = next_power - cur_power
		local str = string.format(Language.RisingStar.ThemeText, rising_star_cfg.need_chongzhi, Language.RisingStar.AppearanceName[cur_type], next_level_cfg.gradename, next_level_cfg.show_grade,add_power)
		self.theme_text:SetValue(str)

		self.is_show_model:SetValue(true)
		local image_list = KaiFuChargeData.Instance:GetImageListByImageId(cur_type, next_level_cfg.image_id)
		if image_list then
			self:SetCurrentModel(cur_type, image_list.res_id)
		end
		self.is_show_gift:SetValue(false)

	else
		local cur_level_cfg = KaiFuChargeData.Instance:GetSystemConfigByType(cur_type, cur_level)

		if next(cur_level_cfg) then
			self.theme_text:SetValue(Language.RisingStar.Grisliness)
			self.is_show_gift:SetValue(true)
			local item_id = rising_star_cfg.reward_item.item_id
			self.is_show_model:SetValue(false)
		end

		local image_list = KaiFuChargeData.Instance:GetImageListByImageId(cur_type, cur_level_cfg.image_id)
		self:SetCurrentModel(cur_type, image_list.res_id)
	end
	-- 星星
	local index = cur_level % 10
	for i = 1, 10 do
		self.star_lists[i].value:SetValue(false)
		-- 判断功能是否开启
		if self.star_lists[i] then
			if OpenFunData.Instance:CheckIsHide(KaiFuRisingStarTpye[cur_type]) then
				self.star_lists[i].value:SetValue(index == 0 or index >= i)
			else
				self.star_lists[i].value:SetValue(false)
			end
		end
	end

	local need_num = 0
	if rising_star_info.fetch_stall >= 1 then
		local max_stall = rising_star_info.max_stall
		local fetch_stall = rising_star_info.fetch_stall
		if fetch_stall < max_stall then
			need_num = 0
		else
			need_num = KaiFuChargeData.Instance:GetNeedChongzhiByStage(max_stall + 1) - rising_star_info.chognzhi_today
		end
	else
		need_num = rising_star_cfg.need_chongzhi - rising_star_info.chognzhi_today
	end
	local day_num = TimeCtrl.Instance:GetCurOpenServerDay()
	need_num = need_num <= 0 and 0 or need_num
	if need_num == 0 then
		self.recharge_text:SetValue(string.format(Language.RisingStar.RechargeText_2, rising_star_info.chognzhi_today))
	else
		self.recharge_text:SetValue(string.format(Language.RisingStar.RechargeText, rising_star_info.chognzhi_today, need_num <= 0 and 0 or need_num))
	end
	if day_num > 7 then
		self.new_tips_text:SetValue(Language.RisingStar.NewTipsText2)
	else
		self.new_tips_text:SetValue(Language.RisingStar.NewTipsText1)
	end
	if day_num > 7 and rising_star_info.fetch_stall >= 1 then
		self.recharge_text:SetValue(string.format(Language.RisingStar.RechargeText_3, rising_star_info.chognzhi_today))
	end
	if 0 ~= rising_star_info.is_max_level then
		self.recharge_text:SetValue(Language.RisingStar.TipTallText)
	end
end

function KaiFuRisingStarView:AniFinish(index)
	self.star_lists[index].anim:SetBool("action", false)
end


-- 红点回调
function KaiFuRisingStarView:RemindChangeCallBack(remind_name, num)
	if RemindName.KaiFuRiSingBtnRedPoint == remind_name then
		self.show_red_point:SetValue(num > 0)
	end
end


function KaiFuRisingStarView:FlushStar()
	local rising_star_info = KaiFuChargeData.Instance:GetShengxingzhuliInfo()
	local cur_level = rising_star_info.func_level
	local index = cur_level % 10
	if cur_level > 0 and index == 0 then
		index = 10
	end
	-- if self.star_lists and self.star_lists[index] then
	-- 	self.star_lists[index].anim:SetBool("action", true)
	-- end
	for i = 1, 10 do
		if self.show_effect and self.show_effect[i] then
			self.show_effect[i]:SetValue(false)
		end
	end
	if self.show_effect and self.show_effect[index] then
		self.show_effect[index]:SetValue(true)
	end
end

function KaiFuRisingStarView:SetCurrentModel(system_type, res_id)
	local main_role = Scene.Instance:GetMainRole()
	local weapon_res_id = main_role:GetWeaponResId()
	self.is_show_model:SetValue(true)
	if self.model then
		self.model:SetDisplayPositionAndRotation("rising_star_view")
		if KAI_FU_RI_SING_MODEL_TYPE.MOUNT == system_type then								-- 0坐骑
			self.model:SetMainAsset(ResPath.GetMountModel(res_id))
		elseif KAI_FU_RI_SING_MODEL_TYPE.WING == system_type then								-- 1羽翼
			self.model:SetRoleResid(main_role:GetRoleResId())
			self.model:SetWeaponResid(main_role:GetWeaponResId())
			self.model:SetWingResid(res_id)
		elseif KAI_FU_RI_SING_MODEL_TYPE.FIGHT_MOUNT == system_type then 						-- 2法阵
			self.model:SetDisplayPositionAndRotation("rising_star_view_fazhen")
			self.model:SetMainAsset(ResPath.GetFightMountModel(res_id))
		elseif KAI_FU_RI_SING_MODEL_TYPE.HALO == system_type then  							-- 3光环
			self.model:SetRoleResid(main_role:GetRoleResId())
			self.model:SetWeaponResid(main_role:GetWeaponResId())
			self.model:SetHaloResid(res_id)
		elseif KAI_FU_RI_SING_MODEL_TYPE.FABAO == system_type then 							-- 4法宝
			self.model:SetRoleResid(main_role:GetRoleResId())
			self.model:SetWeaponResid(main_role:GetWeaponResId())
			self.model:SetZhiBaoResid(res_id)
		elseif KAI_FU_RI_SING_MODEL_TYPE.BEAUTY_HOLO == system_type then 						-- 5美人光环
			local bundle, asset = ResPath.GetGoddessNotLModel(11101)
			self.model:SetMainAsset(bundle, asset)
			self.model:SetHaloResid(res_id, true)
		elseif KAI_FU_RI_SING_MODEL_TYPE.PIFENG == system_type then							-- 6披风
			self.model:SetRoleResid(main_role:GetRoleResId())
			self.model:SetWeaponResid(main_role:GetWeaponResId())
			self.model:SetMantleResid(res_id)
		-- elseif KAI_FU_RI_SING_MODEL_TYPE.FAZHEN == system_type then
		-- 	local cfg = self.model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.FAZHEN], res_id, DISPLAY_PANEL.RISING)
		-- 	self.model:SetTransform(cfg)
		-- 	local main_role = Scene.Instance:GetMainRole()
		-- 	self.model:SetRoleResid(main_role:GetRoleResId())
		-- 	self.model:SetMantleResid(res_id)
		end
		self.model:SetTransform(KaiFuModelScale[system_type])
	end
end

-- 领取按钮
function KaiFuRisingStarView:OnClickRisingStar()
	local rising_star_info = KaiFuChargeData.Instance:GetShengxingzhuliInfo()

	if rising_star_info.func_level > 0 then 	-- 系统开启了
		if 0 == rising_star_info.is_max_level then 		-- 系统没达到最高级
			local rising_star_cfg = KaiFuChargeData.Instance:GetRisingStarCfg()
			if rising_star_info.chognzhi_today >= rising_star_cfg.need_chongzhi then
				if rising_star_info.func_level < 21 then
					SysMsgCtrl.Instance:ErrorRemind(Language.RisingStar.TipRising)
				else
					KaiFuChargeCtrl.Instance:SendShengxingzhuliRewardReq()
				end
			else
				local sure_func = function()
					MainUICtrl.Instance:OpenRecharge()
				end
				-- TipsCtrl.Instance:ShowCommonTip(sure_func, nil, Language.RisingStar.NoEnoughMoney, nil, nil, nil, nil, nil, nil, nil, nil, true)
				-- TipsCtrl.Instance:SetCommonTipYesText(Language.RisingStar.Go)
				VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
				ViewManager.Instance:Open(ViewName.VipView)
			end
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.RisingStar.TipClickText)
		end
	else										-- 系统未开启
		local sure_func = function()
			MainUICtrl.Instance:GetView():GetTaskView():AutoExecuteTask()
			KaiFuChargeCtrl.Instance:GetView():OnCloseClick()
		end
		TipsCtrl.Instance:ShowCommonTip(sure_func, nil, Language.RisingStar.NoActiveMount, nil, nil, nil, nil, nil, nil, nil, nil, true)
		TipsCtrl.Instance:SetCommonTipYesText(Language.RisingStar.Go)
	end
end

function KaiFuRisingStarView:ClearTimer()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function KaiFuRisingStarView:Time()
	-- 剩余时间
	local server_time = TimeCtrl.Instance:GetServerTime()
	local server_time2 = TimeUtil.NowDayTimeEnd(server_time)
	local time = server_time2 - server_time
	local str = TimeUtil.FormatSecond(time)
	self.time:SetValue(str)
end

function KaiFuRisingStarView:OnBtnTipsHandler()
	TipsCtrl.Instance:ShowHelpTipView(239)
end
