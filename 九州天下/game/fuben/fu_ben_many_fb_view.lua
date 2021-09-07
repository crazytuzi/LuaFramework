ManyFbView = ManyFbView or BaseClass(BaseView)

local MAX_MEMBER = 4
local RANDOM_REWARD_COUNT = 3

function ManyFbView:__init()
	self.ui_config = {"uis/views/fubenview","ManyFBView"}
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
end

function ManyFbView:__delete()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

function ManyFbView:LoadCallBack()
	self.total_monster = self:FindVariable("TotalMonster")
	self.total_boss = self:FindVariable("TotalBoss")
	self.kill_monster = self:FindVariable("KillMonster")
	self.kill_boss = self:FindVariable("KillBoss")
	self.monster_name = self:FindVariable("MonsterName")
	self.boss_name = self:FindVariable("BossName")
	self.show_panel = self:FindVariable("ShowPanel")
	self.value = self:FindVariable("Value")

	self.member_info = {}
	for i = 1, MAX_MEMBER do
		self.member_info[i] = {}
		self.member_info[i].name = self:FindVariable("Name" .. i)
		self.member_info[i].damage = self:FindVariable("Damage" .. i)
	end

	self.random_item = {}
	for i = 1, RANDOM_REWARD_COUNT do
		self.random_item[i] = {}
		self.random_item[i].obj = self:FindObj("ItemCellRandom" .. i)
		self.random_item[i].cell = ItemCell.New()
		self.random_item[i].cell:SetInstanceParent(self.random_item[i].obj)
	end

	local layer = FuBenData.Instance:GetRoomInfo() or 0
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
end

function ManyFbView:ReleaseCallBack()
	for i = 1, RANDOM_REWARD_COUNT do
		if self.random_item[i].cell then
			self.random_item[i].cell:DeleteMe()
			self.random_item[i].cell = nil
		end
	end
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	-- 清理变量和对象
	self.total_monster = nil
	self.total_boss = nil
	self.kill_monster = nil
	self.kill_boss = nil
	self.monster_name = nil
	self.boss_name = nil
	self.show_panel = nil
	self.value = nil
	self.member_info = nil
	self.random_item = nil
end

function ManyFbView:OpenCallBack()
	local layer = FuBenData.Instance:GetRoomInfo()
	local config = FuBenData.Instance:GetShowConfigByLayer(layer)
	if config then
		local times = FuBenData.Instance:GetManyFBCount() or 0
		local max_conut = FuBenData.Instance:GetManyFbTotalCount() or 0
		if times >= max_conut then
			self.no_drop = true
			local mojing = FuBenData.Instance:GetMoJingByLayer(layer) or 0
			self.random_item[1].cell:SetData({item_id = ResPath.CurrencyToIconId.shengwang or 0, num = mojing, is_bind = 0})
			self.random_item[1].cell:SetInteractable(true)
			for i = 2, RANDOM_REWARD_COUNT do
				self.random_item[i].obj:SetActive(false)
			end
		else
			self.no_drop = false
			for i = 1, RANDOM_REWARD_COUNT do
				local item = config.probability_falling[i - 1]
				if item and item.item_id > 0 then
					self.random_item[i].cell:SetData(item)
					self.random_item[i].cell:SetInteractable(true)
				else
					self.random_item[i].cell:SetData()
					self.random_item[i].cell:SetInteractable(false)
				end
			end
		end
	end

	local fb_config = FuBenData.Instance:GetConfigByLayer(layer)
	if fb_config then
		local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
		if monster_cfg then
			self.monster_name:SetValue(monster_cfg[fb_config.monster_id].name)
			self.boss_name:SetValue(monster_cfg[fb_config.boss_id].name)
			self.total_monster:SetValue(fb_config.monster_num)
			self.total_boss:SetValue(fb_config.boss_num)
		end
	end

	local num = ScoietyData.Instance:GetTeamNum() or 0
	local value = FuBenData.Instance:GetManyFbValueByNum(num) or 0
	self.value:SetValue(value)

	-- self:SetCountDown()
end

function ManyFbView:CloseCallBack()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	self:RemoveDelayTime()
end

function ManyFbView:SwitchButtonState(enable)
	self.show_panel:SetValue(enable)
end

function ManyFbView:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function ManyFbView:OnFlush()
	local info = FuBenData.Instance:GetManyFbInfo()
	if info then
		local user_count = info.user_count
		local user_info = info.user_info
		table.sort(user_info, function(a, b) return a.dps > b.dps end)
		for i = 1, MAX_MEMBER do
			if i <= user_count then
				self.member_info[i].name:SetValue(user_info[i].user_name or "")
				local dps = CommonDataManager.ConverMoney(user_info[i].dps) or 0
				self.member_info[i].damage:SetValue(dps)
			else
				self.member_info[i].name:SetValue("")
				self.member_info[i].damage:SetValue(0)
			end
		end
	end

	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
	if fb_scene_info and next(fb_scene_info) then
		self.kill_monster:SetValue(fb_scene_info.kill_allmonster_num - fb_scene_info.kill_boss_num)
		self.kill_boss:SetValue(fb_scene_info.kill_boss_num)
	end

	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo() or {}
	if fb_scene_info and next(fb_scene_info) then
		if fb_scene_info.is_finish == 1 and fb_scene_info.is_pass == 1 then
			self:RemoveDelayTime()
			self.delay_time = GlobalTimerQuest:AddDelayTimer(function() FuBenCtrl.Instance:SendExitFBReq() end, 15)
			if self.no_drop then
				self:ShowVectorView()
			end
		end
	end
end

function ManyFbView:ShowVectorView()
	local layer = FuBenData.Instance:GetRoomInfo() or 0
	local data_list = FuBenData.Instance:GetFbPickItemInfo() or {}
	local mojing = FuBenData.Instance:GetMoJingByLayer(layer)
	table.insert(data_list, {item_id = ResPath.CurrencyToIconId.shengwang or 0, num = mojing, is_bind = 0})
	ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "finish", {data = data_list})
end
