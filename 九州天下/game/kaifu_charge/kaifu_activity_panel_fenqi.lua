KaiFuFenQiView = KaiFuFenQiView or BaseClass(BaseRender)

local KaiFuRisingStarTpye = {
	[0] = "mount_jinjie",
	[1] = "wing_jinjie",
	[2] = "halo_jinjie",
	[3] = "meiren_guanghuan",
	[4] = "shenyi_jinjie",
	[5] = "halidom_jinjie",
	[6] = "shengong_jinjie",
}

local KaiFuModelScale = {
	[SYSTEM_TYPE.MOUNT] = {
		rotation = Vector3(0, 45, 0),
		scale = Vector3(0.7, 0.7, 0.7),
	},
	[SYSTEM_TYPE.WING] = {
		rotation = Vector3(0, 0, 0),
		scale = Vector3(1, 1, 1),
	},
	[SYSTEM_TYPE.FIGHT_MOUNT] = {
		rotation = Vector3(0, 0, 0),
		scale = Vector3(0.64, 0.64, 0.64),
	},
	[SYSTEM_TYPE.HALO] = {
		rotation = Vector3(0, 0, 0),
		scale = Vector3(1, 1, 1),
	},
	[SYSTEM_TYPE.FABAO] = {
		rotation = Vector3(0, 0, 0),
		scale = Vector3(1, 1, 1),
	},
	[SYSTEM_TYPE.BEAUTY_HOLO] = {
		rotation = Vector3(0, 0, 0),
		scale = Vector3(1, 1, 1),
	},
	[SYSTEM_TYPE.PIFENG] = {
		rotation = Vector3(0, 180, 0),
		scale = Vector3(1, 1, 1),
	},
	[SYSTEM_TYPE.FAZHEN] = {
		rotation = Vector3(0, 0, 0),
		scale = Vector3(1, 1, 1),
	},
}

-- 升星助力
function KaiFuFenQiView:__init()
	self.ui_config = {"uis/views/kaifuchargeview", "FenQiZhiZhuiContent"}
	self.model = nil
end

function KaiFuFenQiView:__delete()
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

function KaiFuFenQiView:CloseCallBack()
	for i = 1, 10 do
		if self.show_effect and self.show_effect[i] then
			self.show_effect[i]:SetValue(false)
		end
	end
end

function KaiFuFenQiView:LoadCallBack()
	self.is_first_open = true
	self:ListenEvent("OnClickRisingStar", BindTool.Bind(self.OnClickRisingStar, self))
	-- self.received_text = self:FindVariable("ReceivedText")
	self.theme_text = self:FindVariable("ThemeText")
	self.recharge_text = self:FindVariable("RechargeText")
	self.time = self:FindVariable("Time")
	self.act_desc = self:FindVariable("ActivityDesc")

	self.is_show_gift = self:FindVariable("IsShowGift")
	self.is_show_model = self:FindVariable("IsShowModel")
	self.theme_word = self:FindVariable("ThemeWord")
	-- self.has_fetch = self:FindVariable("has_fetch")
	self.show_red_point = self:FindVariable("ShowRiSingRedPoint")
	self.cur_grade = self:FindVariable("CurGrade")
	self.btn_text = self:FindVariable("BtnText")
	self.can_up = self:FindVariable("CanUp")
	self.up_grade = self:FindVariable("UpGrade")


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
	self.timer_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind2(self.Time, self), 1)

	KaiFuChargeCtrl.Instance:SendFenqizhizhuiOperaReq(FENQIZHIZHUI_OPERA_REQ_TYPE.FENQIZHIZHUI_OPERA_REQ_TYPE_INFO)
end

function KaiFuFenQiView:OnFlush(param_list)
	local rising_star_info = KaiFuChargeData.Instance:GetFenQiInfo()

	local rising_star_cfg = KaiFuChargeData.Instance:GetFenQiCfg()
	local cur_type = rising_star_info.func_type - 1
	local cur_level = rising_star_info.func_grade
	if cur_level < 1 then
		cur_level = 1
	end

	local cur_level_cfg = KaiFuChargeData.Instance:GetSystemConfigByType(cur_type, cur_level)
	local next_level_cfg = KaiFuChargeData.Instance:GetSystemConfigByType(cur_type, rising_star_cfg.to_level)
	local bundle, asset = ResPath.GetRisingTypeNameImage(cur_type)
	self.theme_word:SetAsset(bundle, asset)
	if not next(cur_level_cfg) or not next(next_level_cfg) then return end

	if next_level_cfg and next_level_cfg.show_grade then
		self.up_grade:SetAsset(ResPath.GetKaiFuChargeImage("fenqi_" .. next_level_cfg.show_grade))
	end

	if 0 == rising_star_info.func_is_max_grade then				-- 系统没达到最高级
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

		-- local cur_level_cfg = KaiFuChargeData.Instance:GetSystemConfigByType(cur_type, cur_level)
		-- local next_level_cfg = KaiFuChargeData.Instance:GetSystemConfigByType(cur_type, rising_star_cfg.to_level)

		local cur_power = get_power(cur_level_cfg)
		local next_power = get_power(next_level_cfg)
		local add_power = next_power - cur_power
		local str = string.format(Language.FenQi.ThemeText, rising_star_cfg.need_chongzhi, Language.FenQi.AppearanceName[cur_type], next_level_cfg.gradename, add_power)
		self.theme_text:SetValue(str)

		self.is_show_model:SetValue(true)
		local image_list = KaiFuChargeData.Instance:GetImageListByImageId(cur_type, cur_level_cfg.image_id)
		if image_list then
			self:SetCurrentModel(cur_type, image_list.res_id)
		end
		self.is_show_gift:SetValue(false)
	else
		-- local cur_level_cfg = KaiFuChargeData.Instance:GetSystemConfigByType(cur_type, cur_level)

		if cur_level_cfg then
			self.theme_text:SetValue(Language.FenQi.Grisliness)
			self.is_show_gift:SetValue(true)
			-- local item_id = rising_star_cfg.reward_item.item_id
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
			if OpenFunData.Instance:CheckIsHide(KaiFuRisingStarTpye[cur_type] or "") then
				self.star_lists[i].value:SetValue(index == 0 or index >= i)
			else
				self.star_lists[i].value:SetValue(false)
			end
		end
	end

	local need_num = 0
	if rising_star_info.is_fetch == 0 then
		need_num = rising_star_cfg.need_chongzhi - rising_star_info.today_chongzhi_num
	end
	need_num = need_num <= 0 and 0 or need_num

	local star_num = next_level_cfg.grade and next_level_cfg.grade % 10 or 0
	star_num = star_num == 0 and 10 or star_num
	local star_daxie = CommonDataManager.GetDaXie(star_num)
	local star_str = string.format(Language.FenQi.StarNum, star_daxie)

	if rising_star_info.is_fetch ~= 0 then
		self.recharge_text:SetValue(Language.FenQi.AlreadyReceived)
		self.btn_text:SetValue(Language.FenQi.Received)
		self.show_red_point:SetValue(false and rising_star_info.func_is_max_grade == 0)
		self.can_up:SetValue(false)
	elseif need_num == 0 then
		self.recharge_text:SetValue(string.format(Language.FenQi.RechargeText_2, rising_star_info.today_chongzhi_num, next_level_cfg.gradename .. star_str))
		self.btn_text:SetValue(Language.FenQi.Receive)
		self.can_up:SetValue(true)
		self.show_red_point:SetValue(true and rising_star_info.func_is_max_grade == 0)
	else
		self.recharge_text:SetValue(string.format(Language.FenQi.RechargeText, rising_star_info.today_chongzhi_num, need_num <= 0 and 0 or need_num, next_level_cfg.gradename .. star_str))
		self.btn_text:SetValue(Language.FenQi.Receive)
		self.can_up:SetValue(true)
		self.show_red_point:SetValue(false and rising_star_info.func_is_max_grade == 0)
	end

	if 0 ~= rising_star_info.func_is_max_grade then
		self.recharge_text:SetValue(Language.FenQi.TipTallText)
	end

	self.cur_grade:SetValue(cur_level_cfg.gradename)
end

function KaiFuFenQiView:AniFinish(index)
	self.star_lists[index].anim:SetBool("action", false)
end

function KaiFuFenQiView:FlushStar()
	local rising_star_info = KaiFuChargeData.Instance:GetFenQiInfo()
	local cur_level = rising_star_info.func_grade
	local index = cur_level % 10
	if cur_level > 0 and index == 0 then
		index = 10
	end
	-- if self.star_lists and self.star_lists[index] then
	--  self.star_lists[index].anim:SetBool("action", true)
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

function KaiFuFenQiView:SetCurrentModel(system_type, res_id)
	local main_role = Scene.Instance:GetMainRole()
	local weapon_res_id = main_role:GetWeaponResId()
	self.is_show_model:SetValue(true)
	if self.model then
		self.model:SetDisplayPositionAndRotation("rising_star_view")
		if SYSTEM_TYPE.MOUNT == system_type then						 -- 0坐骑
			self.model:SetMainAsset(ResPath.GetMountModel(res_id))
		elseif SYSTEM_TYPE.WING == system_type then						-- 1羽翼
			self.model:SetRoleResid(main_role:GetRoleResId())
			self.model:SetWeaponResid(main_role:GetWeaponResId())
			self.model:SetWingResid(res_id)
		elseif SYSTEM_TYPE.FIGHT_MOUNT == system_type then						-- 2法阵
			self.model:SetDisplayPositionAndRotation("rising_star_view_fazhen")
			self.model:SetMainAsset(ResPath.GetFightMountModel(res_id))
		elseif SYSTEM_TYPE.HALO == system_type then								-- 3光环
			self.model:SetRoleResid(main_role:GetRoleResId())
			self.model:SetWeaponResid(main_role:GetWeaponResId())
			self.model:SetHaloResid(res_id)
		elseif SYSTEM_TYPE.FABAO == system_type then								-- 4法宝
			self.model:SetRoleResid(main_role:GetRoleResId())
			self.model:SetWeaponResid(main_role:GetWeaponResId())
			self.model:SetZhiBaoResid(res_id)
		elseif SYSTEM_TYPE.BEAUTY_HOLO == system_type then								-- 5美人光环
			local bundle, asset = ResPath.GetGoddessNotLModel(11101)
			self.model:SetMainAsset(bundle, asset)
			self.model:SetHaloResid(res_id, true)
		elseif SYSTEM_TYPE.PIFENG == system_type then								-- 6披风
			self.model:SetRoleResid(main_role:GetRoleResId())
			self.model:SetWeaponResid(main_role:GetWeaponResId())
			self.model:SetMantleResid(res_id)
		-- elseif SYSTEM_TYPE.FAZHEN == system_type then
		--  local cfg = self.model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.FAZHEN], res_id, DISPLAY_PANEL.RISING)
		--  self.model:SetTransform(cfg)
		--  local main_role = Scene.Instance:GetMainRole()
		--  self.model:SetRoleResid(main_role:GetRoleResId())
		--  self.model:SetMantleResid(res_id)
		end
		self.model:SetTransform(KaiFuModelScale[system_type])
	end
end

-- 领取按钮
function KaiFuFenQiView:OnClickRisingStar()
	local rising_star_cfg = KaiFuChargeData.Instance:GetFenQiCfg()
	local rising_star_info = KaiFuChargeData.Instance:GetFenQiInfo()
	if rising_star_info.func_grade > 0 then			-- 系统开启了
		if 0 == rising_star_info.func_is_max_grade then				-- 系统没达到最高级
			local rising_star_cfg = KaiFuChargeData.Instance:GetFenQiCfg()
			if rising_star_info.today_chongzhi_num >= rising_star_cfg.need_chongzhi then
				if rising_star_info.func_grade >= rising_star_cfg.to_level then
					-- 弹出不同提示
					if rising_star_cfg.compensate_type == 2 then
						SysMsgCtrl.Instance:ErrorRemind(Language.FenQi.TipRising_2)
					else
						SysMsgCtrl.Instance:ErrorRemind(Language.FenQi.TipRising_1)
					end
				end
				KaiFuChargeCtrl.Instance:SendFenqizhizhuiOperaReq(FENQIZHIZHUI_OPERA_REQ_TYPE.FENQIZHIZHUI_OPERA_REQ_TYPE_FETCH_REWARD, rising_star_info.func_type)
			else
				local sure_func = function()
					MainUICtrl.Instance:OpenRecharge()
				end
				-- TipsCtrl.Instance:ShowCommonTip(sure_func, nil, Language.FenQi.NoEnoughMoney, nil, nil, nil, nil, nil, nil, nil, nil, true)
				-- TipsCtrl.Instance:SetCommonTipYesText(Language.FenQi.Go)
				VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
				ViewManager.Instance:Open(ViewName.VipView)
			end
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.FenQi.TipClickText)
		end
	else								--系统未开启
		local sure_func = function()
			MainUICtrl.Instance:GetView():GetTaskView():AutoExecuteTask()
			KaiFuChargeCtrl.Instance:GetView():OnCloseClick()
		end
		TipsCtrl.Instance:ShowCommonTip(sure_func, nil, Language.FenQi.NoActiveMount, nil, nil, nil, nil, nil, nil, nil, nil, true)
		TipsCtrl.Instance:SetCommonTipYesText(Language.FenQi.Go)
	end
end

function KaiFuFenQiView:ClearTimer()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function KaiFuFenQiView:Time()
	-- 剩余时间
	local server_time = TimeCtrl.Instance:GetServerTime()
	local server_time2 = TimeUtil.NowDayTimeEnd(server_time)
	local time = server_time2 - server_time
	local str = TimeUtil.FormatSecond(time)
	self.time:SetValue(str)
end

function KaiFuFenQiView:OnBtnTipsHandler()
	TipsCtrl.Instance:ShowHelpTipView(240)
end
