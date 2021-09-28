MainUIViewPlayer = MainUIViewPlayer or BaseClass(BaseRender)

local EffectType = {
	ADD_GONGJI = 0,
	ADD_FANGYU = 2,
	ADD_BAOJI = 3,
	ADD_EXP = 9001,
	ADD_WORLD_EXP = 9004,
	BLOOD = 1006,
	DIZZY = 1109,
	REDUCE_GONGJI = 1104,
	REDUCE_FANGYU = 1103,
	REDUCE_SPEED = 1106,
	ADD_GONGJI_MARRY = 9007,
}

function MainUIViewPlayer:__init()
	-- 找到要控制的变量
	self.portrait_icon = self:FindVariable("PortraitIcon")
	self.level = self:FindVariable("Level")
	self.fight_power = self:FindVariable("FightPower")
	self.diamond = self:FindVariable("Diamond")
	self.bind_diamond = self:FindVariable("BindDiamond")
	self.attack_mode = self:FindVariable("AttackMode")
	self.show_right_btns = self:FindVariable("ShowPlayerRightBtns")
	self.buff_count = self:FindVariable("BuffCount")
	self.hp_text = self:FindVariable("HpText")
	self.vip_level = self:FindVariable("VipLevel")
	self.temp_vip_des = self:FindVariable("TempVipDes")
	self.show_tempvip_des = self:FindVariable("ShowTempVipDes")
	self.goals_end_time = self:FindVariable("GoalsEndTime")
	self.show_hp_low_effect = self:FindVariable("show_hp_low_effect")
	self.attack_mode_notice = self:FindVariable("AttackModeNotice")
	self.head_frame_res = self:FindVariable("head_frame_res")
	self.pk_light_t = {}
	for i = 0, 4 do
		self.pk_light_t[i] = self:FindVariable("PK_light_" .. i)
	end

	self.hp_bar = self:FindObj("HealthBar")
	self.hp_slider_top = self.hp_bar.transform:Find("HPTop"):GetComponent(typeof(UnityEngine.UI.Slider))
	self.hp_slider_bottom = self.hp_bar.transform:Find("HPBottom"):GetComponent(typeof(UnityEngine.UI.Slider))

	self.portrait_image = self:FindObj("Portrait")
	self.portrait_raw = self:FindObj("RawPortrait")

	-- 监听UI事件
	self:ListenEvent("OpenAddPower",
		BindTool.Bind(self.OpenAddPower, self))
	self:ListenEvent("OnClickBuff",
		BindTool.Bind(self.OnClickBuff, self))
	self:ListenEvent("CloseBuff",
		BindTool.Bind(self.CloseBuff, self))
	self:ListenEvent("OpenModeList",
		BindTool.Bind(self.OpenModeList, self))
	self:ListenEvent("OnClickButtonDaily",
		BindTool.Bind(self.OnClickButtonDaily, self))
	self:ListenEvent("OpenVip",
		BindTool.Bind(self.OpenVip, self))
	self:ListenEvent("OpenHpBag",
		BindTool.Bind(self.OpenHpBag, self))

	-- 属性事件处理
	self.attr_handlers = {
		capability = BindTool.Bind1(self.OnFightPowerChanged, self),
		level = BindTool.Bind1(self.OnLevelChanged, self),
		hp = BindTool.Bind1(self.OnHPChanged, self),
		vip_level = BindTool.Bind1(self.OnVipLevelChanged, self),
		max_hp = BindTool.Bind1(self.OnHPChanged, self),
		gold = BindTool.Bind1(self.OnGoldChanged, self),
		bind_gold = BindTool.Bind1(self.OnBindGoldChanged, self),
	}

	self.player_data_change_callback = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.player_data_change_callback)

	self.head_change = GlobalEventSystem:Bind(
		ObjectEventType.HEAD_CHANGE,
		BindTool.Bind(self.OnHeadChange, self))
	self.frame_change = GlobalEventSystem:Bind(
		ObjectEventType.FRAME_CHANGE,
		BindTool.Bind(self.OnHeadChange, self))
	self.temp_head_change = GlobalEventSystem:Bind(
		ObjectEventType.TEMP_HEAD_CHANGE,
		BindTool.Bind(self.ChangeTempHead, self))
	self.effect_change = GlobalEventSystem:Bind(
		ObjectEventType.FIGHT_EFFECT_CHANGE,
		BindTool.Bind(self.OnFightEffectChange, self))
	self.show_or_hide_other_btn =  GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
        BindTool.Bind(self.SwitchButtonState, self))

	self.virtual_task_change = GlobalEventSystem:Bind(OtherEventType.VIRTUAL_TASK_CHANGE,BindTool.Bind(self.OnPersonGoalChange, self))

	-- 首次刷新数据
	self:OnFightPowerChanged()
	self:OnLevelChanged()
	self:OnHPChanged()
	self:OnVipLevelChanged()
	self:OnGoldChanged()
	self:OnBindGoldChanged()
	self:OnHeadChange()
	local mode = Scene.Instance:GetMainRole().vo.attack_mode
	self:UpdateAttackMode(mode)
	self:UpdateAttackModeNotice()
	self:OnFightEffectChange(true)
end

function MainUIViewPlayer:__delete()
	PlayerData.Instance:UnlistenerAttrChange(self.player_data_change_callback)

	if self.head_change ~= nil then
		GlobalEventSystem:UnBind(self.head_change)
		self.head_change = nil
	end

	if self.temp_head_change ~= nil then
		GlobalEventSystem:UnBind(self.temp_head_change)
		self.temp_head_change = nil
	end

	if self.effect_change ~= nil then
		GlobalEventSystem:UnBind(self.effect_change)
		self.effect_change = nil
	end

	if self.effec_change ~= nil then
		GlobalEventSystem:UnBind(self.effec_change)
		self.effec_change = nil
	end
	if self.show_or_hide_other_btn ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_btn)
		self.show_or_hide_other_btn = nil
	end
	if self.virtual_task_change ~= nil then
		GlobalEventSystem:UnBind(self.virtual_task_change)
		self.virtual_task_change = nil
	end

	if self.frame_change then
		GlobalEventSystem:UnBind(self.frame_change)
		self.frame_change = nil
	end
	self:StopTempVipCountDown()
end

function MainUIViewPlayer:OpenToFlush()
	self:CalTime()
end

function MainUIViewPlayer:OpenCallBack()
	self:CalTime()
end

function MainUIViewPlayer:CloseCallBack()
	if self.timer_quest then
	   GlobalTimerQuest:CancelQuest(self.timer_quest)
	   self.timer_quest = nil
	end
end

function MainUIViewPlayer:UpdateAttackMode(mode)
	if mode == GameEnum.ATTACK_MODE_PEACE then
		self.attack_mode:SetValue(0)
	elseif mode == GameEnum.ATTACK_MODE_TEAM then
		self.attack_mode:SetValue(1)
	elseif mode == GameEnum.ATTACK_MODE_GUILD then
		self.attack_mode:SetValue(2)
	elseif mode == GameEnum.ATTACK_MODE_ALL then
		self.attack_mode:SetValue(3)
	elseif mode == GameEnum.ATTACK_MODE_NAMECOLOR then
		self.attack_mode:SetValue(4)
	end
	for k,v in pairs(self.pk_light_t) do
		v:SetValue(mode == k)
	end
end

function MainUIViewPlayer:UpdateAttackModeNotice()
	-- local str = ""
	-- local forbid_pk = Scene.Instance:GetSceneForbidPk()
	-- if forbid_pk then
	-- 	str = Language.Fight.SceneForbidPk
	-- else
	-- 	local switch = Scene.Instance:IsCanChangeAttackMode()
	-- 	if not switch then
	-- 		str = Language.Fight.CannotChangeMode
	-- 	end
	-- end
	-- self.attack_mode_notice:SetValue(str)
end

function MainUIViewPlayer:OpenAddPower()
	ViewManager.Instance:Open(ViewName.HelperView)
end

function MainUIViewPlayer:OnClickBuff()
	local main_role_all_effect_list = FightData.Instance:GetMainRoleShowEffect()
	if  #main_role_all_effect_list <= 0 then return end
	if ViewManager.Instance:IsOpen(ViewName.BuffPandectTips) then
		ViewManager.Instance:Close(ViewName.BuffPandectTips)
	else
		ViewManager.Instance:Open(ViewName.BuffPandectTips)
	end
end

function MainUIViewPlayer:CloseBuff()
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, false)
end

function MainUIViewPlayer:OpenModeList()
	local forbid_pk = Scene.Instance:GetSceneForbidPk()
	local switch = Scene.Instance:IsCanChangeAttackMode()

	if forbid_pk or not switch then
		ViewManager.Instance:Close(ViewName.AttackMode)
		local str = forbid_pk and Language.Fight.SceneForbidPk or Language.Fight.CannotChangeMode
		SysMsgCtrl.Instance:ErrorRemind(str)
		return
	end

	ViewManager.Instance:Open(ViewName.AttackMode)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, true)
	GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_DAFUHAO_INFO, false, true)
end

--VIP
function MainUIViewPlayer:OpenVip()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.VIP)
	ViewManager.Instance:Open(ViewName.VipView)
end

-- 血包
function MainUIViewPlayer:OpenHpBag()
	HpBagData.Instance:SetIsShowRepdt(false)
	RemindManager.Instance:Fire(RemindName.HpBag)
	ViewManager.Instance:Open(ViewName.HpBag)
end

function MainUIViewPlayer:PlayerDataChangeCallback(attr_name, value, old_value)
	local handler = self.attr_handlers[attr_name]
	if handler ~= nil then
		handler()
	end
end


function MainUIViewPlayer:OnFightPowerChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.fight_power:SetValue(vo.capability)
end

function MainUIViewPlayer:OnLevelChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local lv, zhuan = PlayerData.GetLevelAndRebirth(vo.level)
	self.level:SetValue(string.format(Language.Mainui.Level, lv, zhuan))
end

function MainUIViewPlayer:OnHPChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self:SetHpPercent(vo.hp / vo.max_hp)
	self.hp_text:SetValue(CommonDataManager.ConverMoney(vo.hp) .. "/" .. CommonDataManager.ConverMoney(vo.max_hp))
	local limit_hp = vo.max_hp * 0.2
	self.show_hp_low_effect:SetValue(vo.hp <= limit_hp)
	HpBagData.Instance:SetIsShowRepdt(true)
	RemindManager.Instance:Fire(RemindName.HpBag)
end

function MainUIViewPlayer:OnVipLevelChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.vip_level:SetValue(vo.vip_level)
end

function MainUIViewPlayer:OnGoldChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local count = vo.gold
	if count > 99999 and count <= 99999999 then
		count = count / 10000
		count = math.floor(count)
		count = count .. Language.Common.Wan
	elseif count > 99999999 then
		count = count / 100000000
		count = math.floor(count)
		count = count .. Language.Common.Yi
	end
	self.diamond:SetValue(count)
end

function MainUIViewPlayer:OnBindGoldChanged()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local count = vo.bind_gold
	if count > 99999 and count <= 99999999 then
		count = count / 10000
		count = math.floor(count)
		count = count .. Language.Common.Wan
	elseif count > 99999999 then
		count = count / 100000000
		count = math.floor(count)
		count = count .. Language.Common.Yi
	end
	self.bind_diamond:SetValue(count)
end

-- 设置目标血条
function MainUIViewPlayer:SetHpPercent(percent)
	self.hp_slider_top.value = percent
	self.hp_slider_bottom:DOValue(percent, 0.8, false)
end

-- 头像更换
function MainUIViewPlayer:OnHeadChange()
	if not ViewManager.Instance:IsOpen(ViewName.Main) or not MainUICtrl.Instance:IsLoaded() then
		return
	end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	CommonDataManager.SetAvatar(vo.role_id, self.portrait_raw, self.portrait_image, self.portrait_icon, vo.sex, vo.prof, true)
	CommonDataManager.SetAvatarFrame(vo.role_id, self.head_frame_res)
end

function MainUIViewPlayer:ChangeTempHead(path)
	if nil == path then
		return
	end

	self.portrait_raw.raw_image:LoadSprite(path, function()
		self.portrait_image.gameObject:SetActive(false)
		self.portrait_raw.gameObject:SetActive(true)
	end)
end

function MainUIViewPlayer:OnFightEffectChange(is_main_role)
	if is_main_role then
		local main_role_all_effect_list = FightData.Instance:GetMainRoleShowEffect()
		self.buff_count:SetValue(#main_role_all_effect_list)
	end
end

function MainUIViewPlayer:OnClickButtonDaily()
	ViewManager.Instance:Open(ViewName.BaoJu, TabIndex.baoju_zhibao_active)
end

function MainUIViewPlayer:ShowRightBtns(value)
	self.show_right_btns:SetValue(value)
end

function MainUIViewPlayer:SwitchButtonState()
	ViewManager.Instance:Close(ViewName.AttackMode)
end

function MainUIViewPlayer:ShowTempVip(enable)
	self.show_tempvip_des:SetValue(enable)
end

function MainUIViewPlayer:SetTempVipDes(des)
	self.temp_vip_des:SetValue(des)
end

function MainUIViewPlayer:StopTempVipCountDown()
	if self.temp_vip_count_down then
		CountDown.Instance:RemoveCountDown(self.temp_vip_count_down)
		self.temp_vip_count_down = nil
	end
end

function MainUIViewPlayer:StarTempVipCountDown(time)
	local function timer_func(elapse_time, total_time)
		if elapse_time >= total_time then
			self:StopTempVipCountDown()
			return
		end
		local server_time = TimeCtrl.Instance:GetServerTime()
		local temp_vip_end_time = VipData.Instance:GetTempVipEndTime()
		local diff_time_str = TimeUtil.FormatSecond(temp_vip_end_time - server_time, 2)
		local des = string.format(Language.Vip.TempVipDes, diff_time_str)
		self:SetTempVipDes(des)
	end
	self:StopTempVipCountDown()
	self.temp_vip_count_down = CountDown.Instance:AddCountDown(time, 1, timer_func)
end

function MainUIViewPlayer:FlushTempVip()
	--刷新临时vip
	self:StopTempVipCountDown()
	local is_in_temp_vip = VipData.Instance:GetIsInTempVip()
	self:ShowTempVip(is_in_temp_vip)
	if is_in_temp_vip then
		local server_time = TimeCtrl.Instance:GetServerTime()
		local temp_vip_end_time = VipData.Instance:GetTempVipEndTime()
		local diff_time_str = TimeUtil.FormatSecond(temp_vip_end_time - server_time, 2)
		local des = string.format(Language.Vip.TempVipDes, diff_time_str)
		self:SetTempVipDes(des)
		self:StarTempVipCountDown(temp_vip_end_time - server_time)
	end
end

function MainUIViewPlayer:CalTime()
	if self.timer_quest then
	   GlobalTimerQuest:CancelQuest(self.timer_quest)
	   self.timer_quest = nil
	end
	self.timer_quest = GlobalTimerQuest:AddRunQuest(function()
		self:FlushGoalsIcon()
	end, 1)
end

function MainUIViewPlayer:FlushGoalsIcon()
	local _, str = CollectiveGoalsData.Instance:GetNextTime()
	self.goals_end_time:SetValue(str)
	local server_open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local day = 4 - server_open_day
	if day < 0 or not OpenFunData.Instance:CheckIsHide("CollectGoals") then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.goals_end_time:SetValue("")
	end
end

function MainUIViewPlayer:OnPersonGoalChange(value, flag)
	if flag then
		self:FlushGoalsIcon()
	end
end