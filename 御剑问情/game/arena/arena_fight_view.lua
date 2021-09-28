ArenaFightView = ArenaFightView or BaseClass(BaseRender)

function ArenaFightView:__init(instance)
	if instance == nil then
		return
	end
	self.count = self:FindVariable("Time")
	self.show_reminding = self:FindVariable("ShowReminding")
	self.rest_time = self:FindVariable("RestTime")

	self.role_info_self = self:FindObj("RoleInfo")
	self.role_info_target = self:FindObj("RoleInfo2")

	self.hp_slider_top_self = self.role_info_self:GetComponent(typeof(UINameTable)):Find("HPTop"):GetComponent(typeof(UnityEngine.UI.Slider))
	self.hp_slider_bottom_self = self.role_info_self:GetComponent(typeof(UINameTable)):Find("HPBottom"):GetComponent(typeof(UnityEngine.UI.Slider))
	self.hp_slider_top_target = self.role_info_target:GetComponent(typeof(UINameTable)):Find("HPTop"):GetComponent(typeof(UnityEngine.UI.Slider))
	self.hp_slider_bottom_target = self.role_info_target:GetComponent(typeof(UINameTable)):Find("HPBottom"):GetComponent(typeof(UnityEngine.UI.Slider))

	self.my_nowhp = self.role_info_self:GetComponent(typeof(UIVariableTable)):FindVariable("NowHp")
	self.my_totalhp = self.role_info_self:GetComponent(typeof(UIVariableTable)):FindVariable("TotalHp")
	self.target_nowhp = self.role_info_target:GetComponent(typeof(UIVariableTable)):FindVariable("EnemyNowHp")
	self.target_totalhp = self.role_info_target:GetComponent(typeof(UIVariableTable)):FindVariable("EnemyTotalHp")

	self.portrait_self = self:FindObj("portraitSelf")
	self.portrait_target = self:FindObj("portraitTarget")
	self.portrait_raw_self = self:FindObj("portraitRawSelf")
	self.portrait_raw_target = self:FindObj("portraitRawTarget")

	self.level_self = self.role_info_self:GetComponent(typeof(UIVariableTable)):FindVariable("Level")
	self.name_self = self.role_info_self:GetComponent(typeof(UIVariableTable)):FindVariable("Name")
	self.icon_self = self.role_info_self:GetComponent(typeof(UIVariableTable)):FindVariable("Icon")
	self.capability_self=self.role_info_self:GetComponent(typeof(UIVariableTable)):FindVariable("Capability")

	self.level_target = self.role_info_target:GetComponent(typeof(UIVariableTable)):FindVariable("Level")
	self.name_target = self.role_info_target:GetComponent(typeof(UIVariableTable)):FindVariable("Name")
	self.icon_target = self.role_info_target:GetComponent(typeof(UIVariableTable)):FindVariable("Icon")
	self.capability_target=self.role_info_target:GetComponent(typeof(UIVariableTable)):FindVariable("Capability")

	self.target_obj = nil

	self.listen_hp = BindTool.Bind(self.PlayerDataChangeCallback, self)

	self.rest_time:SetValue("")

	PlayerData.Instance:ListenerAttrChange(self.listen_hp)
end

function ArenaFightView:__delete()
	self:RemoveCountDown()
	if self.listen_hp then
		PlayerData.Instance:UnlistenerAttrChange(self.listen_hp)
		self.listen_hp = nil
	end

	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end

	self.my_nowhp = nil
	self.my_totalhp = nil
	self.target_nowhp = nil
	self.target_totalhp = nil
end

function ArenaFightView:CloseCallBack()
	self:RemoveCountDown()
	self.rest_time:SetValue("")
end

function ArenaFightView:OpenCallBack()
	local main_role = Scene.Instance:GetMainRole()
	main_role:RotateTo(-90)
end

function ArenaFightView:StartCountDown()
	if self.count_down then
		return
	end
	self:HeadChangeSelf()
	self:FlushBaseInfo()
	self.count:SetValue(3)
	self.show_reminding:SetValue(true)
	self.count_down = CountDown.Instance:AddCountDown(3, 1, BindTool.Bind(self.CountDown, self, self.count))
end

function ArenaFightView:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function ArenaFightView:CountDown(time_obj, elapse_time, total_time)
	local time = math.ceil(total_time - elapse_time)
	if time <= 0 then
		self:RemoveCountDown()
		time = 0
		-- GlobalTimerQuest:AddDelayTimer(function ()
		-- 	ArenaCtrl.Instance:SetCanMove(true)
		-- end, 1)
	end
	time_obj:SetValue(time)
end

function ArenaFightView:StartFight()
	self.show_reminding:SetValue(false)
	self:RemoveCountDown()
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	local time = math.floor(ArenaData.Instance:GetFightTime() - TimeCtrl.Instance:GetServerTime())
	self.rest_time:SetValue(time)
	self.count_down = CountDown.Instance:AddCountDown(time, 1, BindTool.Bind(self.CountDown, self, self.rest_time))
end

function ArenaFightView:FlushBaseInfo()
	local target_info = self:GetTargetObj()
	if target_info then
		local level = PlayerData.GetLevelString(target_info.vo.level)
		local _capability=ArenaData.Instance:GetOtherRoleCapability(target_info.vo.role_id)
		self.level_target:SetValue(level)
		self.name_target:SetValue(target_info.vo.name)
		self.capability_target:SetValue(_capability)
	else
		local target_vo = ArenaData.Instance:GetTargetInfo()
		if target_vo then
			local level = PlayerData.GetLevelString(target_vo.level)
			self.level_target:SetValue(level)
			self.name_target:SetValue(target_vo.name)
			self.capability_target:SetValue(target_vo.capability)
			self:HeadChangeTarget(target_vo)
			self.target_nowhp:SetValue(CommonDataManager.ConverMoney(target_vo.hp))
			self.target_totalhp:SetValue(CommonDataManager.ConverMoney(target_vo.max_hp))
			self:SetHpPercent(target_vo.hp / target_vo.max_hp, false)
		end
	end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local level = PlayerData.GetLevelString(vo.level)
	self.level_self:SetValue(level)
	self.name_self:SetValue(vo.name)
	self.capability_self:SetValue(vo.capability)
	--self.icon_self

	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.my_nowhp:SetValue(CommonDataManager.ConverMoney(vo.hp))
	self.my_totalhp:SetValue(CommonDataManager.ConverMoney(vo.max_hp))
	self:SetHpPercent(vo.hp / vo.max_hp, true)

	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	if self.target_obj then
		self.target_obj = nil
	end
	self:TimerCallback()
	self.timer_quest = GlobalTimerQuest:AddRunQuest(function() self:TimerCallback() end, 0.3)
end


function ArenaFightView:PlayerDataChangeCallback(attr_name, value, old_value)

	if attr_name == "hp" then
		local vo = GameVoManager.Instance:GetMainRoleVo()

		self.my_nowhp:SetValue(CommonDataManager.ConverMoney(vo.hp))
		self.my_totalhp:SetValue(CommonDataManager.ConverMoney(vo.max_hp))
		self:SetHpPercent(vo.hp / vo.max_hp, true)
	end
end

-- 目标血量改变
function ArenaFightView:TimerCallback()
	if not self.target_obj then
		self.target_obj = self:GetTargetObj()
	end
	if self.target_obj then
		local target_hp = self.target_obj:GetAttr("hp")
		self.target_nowhp:SetValue(CommonDataManager.ConverMoney(target_hp))
		self.target_totalhp:SetValue(CommonDataManager.ConverMoney(self.target_obj:GetAttr("max_hp")))
		self:SetHpPercent(target_hp / self.target_obj:GetAttr("max_hp"), false)
	end
end

function ArenaFightView:SetCapability()

end

-- 设置目标血条
function ArenaFightView:SetHpPercent(percent, is_self)
	if is_self then
		self.hp_slider_top_self.value = percent
		self.hp_slider_bottom_self:DOValue(percent, 0.8, false)
	else
		self.hp_slider_top_target.value = percent
		self.hp_slider_bottom_target:DOValue(percent, 0.8, false)
	end
end

-- 得到目标obj
function ArenaFightView:GetTargetObj()
	local obj_list = Scene.Instance:GetObjList()
	if obj_list then
		for k,v in pairs(obj_list) do
			if v:IsRole() and not v:IsMainRole() then
				local vo = v:GetVo()
				self:HeadChangeTarget(vo)
				return v
			end
		end
	end
end

-- 头像更换
function ArenaFightView:HeadChangeSelf()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	CommonDataManager.SetAvatar(vo.role_id, self.portrait_raw_self, self.portrait_self, self.icon_self, vo.sex, vo.prof, true)
end

-- 对手头像更换
function ArenaFightView:HeadChangeTarget(vo)
	local bundle, asset = ResPath.GetRoleHeadBig(vo.prof, vo.sex)
	self.icon_target:SetAsset(bundle, asset)
end