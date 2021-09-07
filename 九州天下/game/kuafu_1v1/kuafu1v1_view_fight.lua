KuaFu1v1ViewFight = KuaFu1v1ViewFight or BaseClass(BaseRender)

function KuaFu1v1ViewFight:__init()
	self.count = self:FindVariable("Time")
	self.show_reminding = self:FindVariable("ShowReminding")
	self.rest_time = self:FindVariable("RestTime")
	self.show_time = self:FindVariable("ShowTime")


	self.role_info_self = self:FindObj("RoleInfo")
	self.role_info_target = self:FindObj("RoleInfo2")

	self.hp_slider_top_self = self.role_info_self:GetComponent(typeof(UINameTable)):Find("HPTop"):GetComponent(typeof(UnityEngine.UI.Slider))
	self.hp_slider_bottom_self = self.role_info_self:GetComponent(typeof(UINameTable)):Find("HPBottom"):GetComponent(typeof(UnityEngine.UI.Slider))
	self.hp_slider_top_target = self.role_info_target:GetComponent(typeof(UINameTable)):Find("HPTop"):GetComponent(typeof(UnityEngine.UI.Slider))
	self.hp_slider_bottom_target = self.role_info_target:GetComponent(typeof(UINameTable)):Find("HPBottom"):GetComponent(typeof(UnityEngine.UI.Slider))

	self.portrait_self = self:FindObj("portraitSelf")
	self.portrait_target = self:FindObj("portraitTarget")
	self.portrait_raw_self = self:FindObj("portraitRawSelf")
	self.portrait_raw_target = self:FindObj("portraitRawTarget")
	self.show_por = self:FindVariable("ShowPor")

	self.level_self = self.role_info_self:GetComponent(typeof(UIVariableTable)):FindVariable("Level")
	self.name_self = self.role_info_self:GetComponent(typeof(UIVariableTable)):FindVariable("Name")
	self.icon_self = self.role_info_self:GetComponent(typeof(UIVariableTable)):FindVariable("Icon")
	
	self.my_hp = self.role_info_self:GetComponent(typeof(UIVariableTable)):FindVariable("my_hp")
	self.target_hp = self.role_info_target:GetComponent(typeof(UIVariableTable)):FindVariable("target_hp")

	self.level_target = self.role_info_target:GetComponent(typeof(UIVariableTable)):FindVariable("Level")
	self.name_target = self.role_info_target:GetComponent(typeof(UIVariableTable)):FindVariable("Name")
	self.icon_target = self.role_info_target:GetComponent(typeof(UIVariableTable)):FindVariable("Icon")

	self.my_head = self:FindVariable("MyHead")
	self.tar_head = self:FindVariable("TarHead")

	self.target_obj = nil

	self.listen_hp = BindTool.Bind(self.PlayerDataChangeCallback, self)

	self.rest_time:SetValue("")
	self.show_time:SetValue(false)

	PlayerData.Instance:ListenerAttrChange(self.listen_hp)
end

function KuaFu1v1ViewFight:__delete()
	self:RemoveCountDown()
	if self.listen_hp then
		PlayerData.Instance:UnlistenerAttrChange(self.listen_hp)
		self.listen_hp = nil
	end

	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function KuaFu1v1ViewFight:StartCountDown()
	if self.count_down then
		return
	end
	self:HeadChangeSelf()
	self:FlushBaseInfo()
	self.count:SetValue(3)
	self.show_reminding:SetValue(true)
	self.count_down = CountDown.Instance:AddCountDown(3, 1, BindTool.Bind(self.CountDown, self, self.count))
end

function KuaFu1v1ViewFight:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function KuaFu1v1ViewFight:CountDown(time_obj, elapse_time, total_time)
	local time = math.ceil(total_time - elapse_time)
	if time <= 0 then
		self:RemoveCountDown()
		time = 0
		KuaFu1v1Ctrl.Instance:SendCross1v1FightReadyReq()

		if callback then
			callback()
		end
	end
	time_obj:SetValue(time)
end

function KuaFu1v1ViewFight:StartFight()
	self.show_reminding:SetValue(false)
	self:RemoveCountDown()
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	local time = KuaFu1v1Data.Instance:GetFightTime()

	self.rest_time:SetValue(time)
	self.show_time:SetValue(true)
	self.count_down = CountDown.Instance:AddCountDown(time, 1, BindTool.Bind(self.CountDown, self, self.rest_time))
end

function KuaFu1v1ViewFight:FlushBaseInfo()
	local target_info = KuaFu1v1Data.Instance:GetMatchResult()
	if target_info then
		local level = PlayerData.GetLevelString(target_info.level)
		self.level_target:SetValue(level)
		self.name_target:SetValue(target_info.oppo_name .. "_s" .. target_info.oppo_sever_id)
		--self.icon_target
	end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local level = PlayerData.GetLevelString(vo.level)
	self.level_self:SetValue(level)
	self.name_self:SetValue(vo.name)
	--self.icon_self

	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.my_hp:SetValue(string.format(Language.Common.HpBiLi, CommonDataManager.ConverMoney(vo.hp), CommonDataManager.ConverMoney(vo.max_hp)))
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


function KuaFu1v1ViewFight:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "hp" then
		local vo = GameVoManager.Instance:GetMainRoleVo()
		self.my_hp:SetValue(string.format(Language.Common.HpBiLi, CommonDataManager.ConverMoney(vo.hp), CommonDataManager.ConverMoney(vo.max_hp)))
		self:SetHpPercent(vo.hp / vo.max_hp, true)
	end
end

-- 目标血量改变
function KuaFu1v1ViewFight:TimerCallback()
	if not self.target_obj then
		self.target_obj = self:GetTargetObj()
	end
	if self.target_obj then
		local target_hp1 = self.target_obj:GetAttr("hp")
		local target_hp2 = self.target_obj:GetAttr("max_hp")
		self.target_hp:SetValue(string.format(Language.Common.HpBiLi, CommonDataManager.ConverMoney(target_hp1), CommonDataManager.ConverMoney(target_hp2)))
		self:SetHpPercent(target_hp1 / target_hp2, false)
	end
end

-- 设置目标血条
function KuaFu1v1ViewFight:SetHpPercent(percent, is_self)
	if is_self then
		self.hp_slider_top_self.value = percent
		self.hp_slider_bottom_self:DOValue(percent, 0.8, false)
	else
		self.hp_slider_top_target.value = percent
		self.hp_slider_bottom_target:DOValue(percent, 0.8, false)
	end
end

-- 得到目标obj
function KuaFu1v1ViewFight:GetTargetObj()
	local target_info = KuaFu1v1Data.Instance:GetMatchResult()
	if target_info then
		local role_id = target_info.role_id
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
end

function KuaFu1v1ViewFight:ClearInfo()

end

-- 头像更换
function KuaFu1v1ViewFight:HeadChangeSelf()
	local vo = GameVoManager.Instance:GetMainRoleVo()

	CommonDataManager.NewSetAvatar(vo.role_id, self.show_por, self.my_head, self.portrait_raw_self, vo.sex, vo.prof, true)
end

-- 对手头像更换
function KuaFu1v1ViewFight:HeadChangeTarget(vo)
	local bundle, asset = ResPath.GetRoleHeadBig(vo.prof, vo.sex)
	self.tar_head:SetAsset(bundle, asset)
	-- if not vo then return end
	-- -- AvatarManager.Instance:SetAvatarKey(vo.role_id, vo.avatar_key_big, vo.avatar_key_small)
	-- local avatar_path_big = AvatarManager.Instance:GetAvatarKey(vo.role_id, true)

	-- if AvatarManager.Instance:isDefaultImg(vo.role_id) == 0 or avatar_path_big == 0 then
	-- 	self.portrait_raw_target.gameObject:SetActive(false)
	-- 	self.portrait_target.gameObject:SetActive(true)
	-- 	local bundle, asset = AvatarManager.GetDefAvatar(PlayerData.Instance:GetRoleBaseProf(vo.prof), true)
	-- 	self.icon_target:SetAsset(bundle, asset)
	-- 	return
	-- end

	-- local callback = function (path)
	-- 	self.avatar_path_big = path or AvatarManager.GetFilePath(vo.role_id, true)
	-- 	self.portrait_raw_target.raw_image:LoadSprite(self.avatar_path_big, function()
	-- 		self.portrait_raw_target.gameObject:SetActive(true)
	-- 		self.portrait_target.gameObject:SetActive(false)
	-- 	end)
	-- end
	-- AvatarManager.Instance:GetAvatar(vo.role_id, true, callback)
end