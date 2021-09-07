GuildStationLogic = GuildStationLogic or BaseClass(BaseFbLogic)

function GuildStationLogic:__init()
	self.particle = nil
	self.qizhi_pos = Vector3(293.3, 352, 136)
end

function GuildStationLogic:__delete()
	self:RemoveCountDown()
	if self.qizhi_model then
		self.qizhi_model:Destroy()
		self.qizhi_model:DeleteMe()
		self.qizhi_model = nil
	end
end

function GuildStationLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	GuildCtrl:SendGuildBossReq(GHILD_BOSS_OPER_TYPR.GUILD_BOSS_INFO_REQ)
	ViewManager.Instance:Close(ViewName.Guild)
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_PEACE)
	GlobalTimerQuest:AddDelayTimer(function()
		GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)
		end, 0.1)
	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
	if MainUICtrl.Instance.view then
		MainUICtrl.Instance.view:SetViewState(false)
		-- if MainUICtrl.Instance.view:IsLoaded() then
		-- 	MainUICtrl.Instance.view.MenuIconToggle.isOn = false
		-- 	MainUICtrl.Instance.view:OnClickMenu()
		-- end
	end
	self.count_down = CountDown.Instance:AddCountDown(999999999, 0.2, BindTool.Bind(self.CountDown, self))
	local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.GUILD_BOSS)
	if act_info then
		if act_info.status == ACTIVITY_STATUS.OPEN or act_info.status == ACTIVITY_STATUS.STANDY then
			GuildCtrl.Instance:OpenStationView()
		end
	end

	local totem_level = GuildDataConst.GUILDVO.guild_totem_level
	-- self:ChangeQizhi(totem_level)
end

function GuildStationLogic:Out(old_scene_type, new_scene_type)
	BaseSceneLogic.Out(self, old_scene_type, new_scene_type)
	if MainUICtrl.Instance.view then
		MainUICtrl.Instance.view:SetViewState(true)
	end
	self:RemoveCountDown()
	GuildCtrl.Instance:CloseStationView()
	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end
	if self.qizhi_model then
		self.qizhi_model:Destroy()
		self.qizhi_model:DeleteMe()
		self.qizhi_model = nil
	end
end

function GuildStationLogic:CountDown(callback, elapse_time, total_time)
	if not self.particle then
		self.particle = GameObject.Find("Detail/Controls/fazhen/Particle")
	end
	if self.particle then
		local monster_list = Scene.Instance:GetMonsterList()
		local flag = false
		if next(monster_list) then
			flag = true
		end
		self:PlayEffect(flag)
	end
end

function GuildStationLogic:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function GuildStationLogic:PlayEffect(state)
	if self.particle then
		self.particle:SetActive(state)
	end
end

function GuildStationLogic:ActivityCallBack(activity_type, status, next_time, open_type)
	if activity_type == ACTIVITY_TYPE.GUILD_BOSS then
		if status == ACTIVITY_STATUS.OPEN or status == ACTIVITY_STATUS.STANDY then
			GuildCtrl.Instance:OpenStationView()
		else
			local boss_activity_info = GuildData.Instance:GetBossActivityInfo()
			if boss_activity_info then
				if boss_activity_info.boss_id == 0 then
					GuildCtrl.Instance:CloseStationView()
				end
			end
		end
	end
end

function GuildStationLogic:ChangeQizhi(totem_level)
	-- local res_id = GuildData.Instance:GetQiZhiResId(totem_level)
	-- local asset_bundle, name = ResPath.GetQiZhiModel(res_id)
	-- if self.qizhi_model then
	-- 	self.qizhi_model:Destroy()
	-- 	self.qizhi_model:DeleteMe()
	-- end
	-- if not self.game_root then
	-- 	self.game_root = GameObject.Find("GameRoot/SceneObjLayer")
	-- end
	-- if self.game_root then
	-- 	self.qizhi_model = AsyncLoader.New(self.game_root.transform)
	-- 	local call_back = function(obj)
	-- 	 	obj.transform.localPosition = self.qizhi_pos
	-- 	 	obj.transform:Rotate(0, -320, 0)
	-- 	 	obj.transform.localScale = Vector3(3, 3, 3)
	-- 	end
	-- 	self.qizhi_model:Load(asset_bundle, name, call_back)
	-- end
end