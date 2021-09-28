KaiFuRisingStarView = KaiFuRisingStarView or BaseClass(BaseView)
local DISPLAYNAME = {
	[11005] = "shengxingzhuli_special_panel1",
	[7025100] = "shengxingzhuli_mount_special_1",
	[7005001] = "shengxingzhuli_mount_special_1",
	[7109001] = "fight_mount_panel_special_1",
	[7106001] = "fight_mount_panel_special_2",
	[7112001] = "fight_mount_panel_special_3",
}

local KaiFuRisingStarTpye = {
	[0] = "mount_jinjie",
	[1] = "wing_jinjie",
	[2] = "foot_jinjie",
	[3] = "halo_jinjie",
	[4] = "fight_mount",
	[5] = "shengong_jinjie",
	[6] = "shenyi_jinjie",
}

-- 升星助力
function KaiFuRisingStarView:__init()
	self.ui_config = {"uis/views/risingstarview_prefab","KaiFuRisingStarView"}
	self.full_screen = false
	self.play_audio = true
	self.model = nil
	self.cur_type = -1
	self.res_id = -1
	self.mainui_open = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpen, self))
end

function KaiFuRisingStarView:__delete()
	if self.mainui_open then
		GlobalEventSystem:UnBind(self.mainui_open)
		self.mainui_open = nil
	end
end

function KaiFuRisingStarView:ReleaseCallBack()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	self.model_display = nil

	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end

	self.glod = nil
	self.xing = nil
	self.can_up_num = nil
	self.time = nil
	self.jie = nil
	self.Star = {}
	self.is_max = nil
	self.red_point = nil
end

function KaiFuRisingStarView:MainuiOpen()
	KaifuActivityCtrl.Instance:SendShengxingzhuliIReq()
end

function KaiFuRisingStarView:CloseCallBack()
	self.cur_type = -1
	self.res_id = -1
end

function KaiFuRisingStarView:OpenCallBack()
	self.cur_type = -1
	self.res_id = -1
	KaifuActivityCtrl.Instance:SendShengxingzhuliIReq()

	RemindManager.Instance:SetTodayDoFlag(RemindName.RisingStar)
end

function KaiFuRisingStarView:LoadCallBack()
	self.glod = self:FindVariable("glod")
	self.xing = self:FindVariable("xing")
	self.can_up_num = self:FindVariable("num")
	self.time = self:FindVariable("time")
	self.jie = self:FindVariable("jie")
	self.is_max = self:FindVariable("is_max")
	self.red_point = self:FindVariable("red_point")
	self.Star = {}
	for i=1,10 do
		self.Star[i] = self:FindVariable("Star" .. i)
	end

	self.stars_hide_list = {}
	for i=1,10 do
		self.stars_hide_list[i] = {
		hide_star = self:FindVariable("HideStar"..i)
	}
	end

	self:ListenEvent("Close", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickChognZhi", BindTool.Bind(self.OnClickChognZhi, self))
	self:ListenEvent("OnClickShengXing", BindTool.Bind(self.OnClickShengXing, self))

	self.model_display = self:FindObj("Display")
	if self.model_display then
		self.model = RoleModel.New("shengxingzhuli_panel")
		self.model:SetDisplay(self.model_display.ui3d_display)
	end
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	self.timer_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind2(self.UpTime, self), 1)
	self:OnFlush()
end

function KaiFuRisingStarView:OnFlush(param_list)
	local rising_star_info = KaifuActivityData.Instance:GetShengxingzhuliInfo()

	local cur_type = rising_star_info.func_type
	local cur_level = rising_star_info.func_level


	local grade = math.floor(cur_level / 10)

	local rising_star_cfg = KaifuActivityData.Instance:GetRisingStarCfg()
	local stall = rising_star_info.stall
	local chognzhi_today = rising_star_info.chognzhi_today
	local is_get_reward_today = rising_star_info.is_get_reward_today
	local next_recharge = KaifuActivityData.Instance:GetNeedChongzhiByStage(stall + 1) - chognzhi_today

	self.glod:SetValue(next_recharge)
	self.can_up_num:SetValue(stall - is_get_reward_today)
	local res_id, grade, star_level, is_max = KaifuActivityData.Instance:GetSystemConfigByType(cur_type, cur_level)
	self.jie:SetValue(grade)

	--星星升级
	if star_level == 0 then
		for i,v in ipairs(self.stars_hide_list) do
			v.hide_star:SetValue(false)
		end
	else
		for i = 1,star_level do
			self.stars_hide_list[i].hide_star:SetValue(true)
		end
		for i = star_level + 1,10 do
			self.stars_hide_list[i].hide_star:SetValue(false)
		end
	end

	self.is_max:SetValue(is_max)

	self.red_point:SetValue(not is_max and (stall - is_get_reward_today) > 0)

	if self.cur_type ~= cur_type or self.res_id ~= res_id then
		self:SetCurrentModel(cur_type, res_id)
	end
end

function KaiFuRisingStarView:SetCurrentModel(system_type, res_id)
	self.cur_type = system_type
	self.res_id = res_id
	if self.model then
		self.model:ClearModel()
		if SYSTEM_TYPE.MOUNT == system_type then								-- 坐骑
			local bundle, asset = ResPath.GetMountModel(res_id)
			self.model:SetPanelName(self:SetSpecialModle(asset,0))
			self.model:SetMainAsset(bundle , asset)
		elseif SYSTEM_TYPE.WING == system_type then								-- 羽翼
			local main_role = Scene.Instance:GetMainRole()
			self.model:SetPanelName(self:SetSpecialModle(res_id,2))
			self.model:SetRoleResid(main_role:GetRoleResId())
			self.model:SetWingResid(res_id)
		elseif SYSTEM_TYPE.FIGHT_MOUNT == system_type then 						-- 战骑
			self.model:SetPanelName(self:SetSpecialModle(res_id,4))
			self.model:SetMainAsset(ResPath.GetFightMountModel(res_id))
			self.model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.FIGHT_MOUNT], res_id, DISPLAY_PANEL.RIRINGSTAR)
		elseif SYSTEM_TYPE.HALO == system_type then  							-- 光环
			local main_role = Scene.Instance:GetMainRole()
			self.model:SetPanelName(self:SetSpecialModle(res_id,1))
			self.model:SetRoleResid(main_role:GetRoleResId())
			self.model:SetHaloResid(res_id)
		elseif SYSTEM_TYPE.FOOT == system_type then 							-- 足迹
			local main_role = Scene.Instance:GetMainRole()
			self.model:SetPanelName(self:SetSpecialModle(res_id,5))
			self.model:SetRoleResid(main_role:GetRoleResId())
			self.model:SetFootResid(res_id)
			self.model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
		elseif SYSTEM_TYPE.SHEN_GONG == system_type then 						-- 神弓
			local info = {}
			self.model:SetPanelName(self:SetSpecialModle(res_id,3))
			self.model:SetMainAsset(ResPath.GetGoddessWeaponModel(res_id))
			info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
			info.weapon_res_id = res_id
			self.model:SetGoddessModelResInfo(info)
		elseif SYSTEM_TYPE.SHEN_YI == system_type then							-- 神翼
			local info = {}
			self.model:SetPanelName(self:SetSpecialModle(res_id,3))
			info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
			info.wing_res_id = res_id
			self.model:SetGoddessModelResInfo(info)
		end
    end
end

function KaiFuRisingStarView:OnClickClose()
	self:Close()
end

function KaiFuRisingStarView:OnClickChognZhi()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function KaiFuRisingStarView:OnClickShengXing()
	--升星
	local function ok_callback()
		KaifuActivityCtrl.Instance:SendShengxingzhuliRewardReq()
	end
	local cur_level = KaifuActivityData.Instance:GetShengxingzhuliInfo().func_level
	local grade = math.floor(cur_level / 10)
	--不足三阶
	if grade < 3 then
		TipsCtrl.Instance:ShowCommonAutoView("shengxing", Language.Common.RisingStarDescription,ok_callback)
	else
		KaifuActivityCtrl.Instance:SendShengxingzhuliRewardReq()
	end
end

function KaiFuRisingStarView:UpTime()
	local server_time = TimeCtrl.Instance:GetServerTime()
	local server_time2 = TimeUtil.NowDayTimeEnd(server_time)
	local time = server_time2 - server_time
	local str = TimeUtil.FormatSecond(time)
	self.time:SetValue(str)
end

function KaiFuRisingStarView:SetSpecialModle(modle_id,type)
	local display_name = "shengxingzhuli_panel"
	if type == 0 then
		display_name = "shengxingzhuli_mount_panel"
	elseif type == 1 then
		display_name = "shengxingzhuli_panel2"
	elseif type == 2 then
		display_name = "shengxingzhuli_wing_panel"
	elseif type == 3 then
		display_name = "shengxingzhuli_panel3"
	elseif type == 4 then
		display_name = "shengxingzhuli_panel1"
	elseif type == 5 then
		display_name = "shengxingzhuli_panel4"
	end
	local id = tonumber(modle_id)
	for k,v in pairs(DISPLAYNAME) do
		if id == k then
			display_name = v
			return display_name
		end
	end
	return display_name
end

