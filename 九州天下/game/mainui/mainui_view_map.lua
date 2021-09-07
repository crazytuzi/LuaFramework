MainUIViewMap = MainUIViewMap or BaseClass(BaseRender)

function MainUIViewMap:__init()
	-- 获取变量
	self.ping = self:FindVariable("Ping")
	self.battery = self:FindVariable("Battery")
	self.time = self:FindVariable("Time")
	self.map_name = self:FindVariable("MapName")
	self.pos_x = self:FindVariable("PosX")
	self.pos_y = self:FindVariable("PosY")

	-- 监听系统事件.
	self.scene_loading_quit_handle = GlobalEventSystem:Bind(
		SceneEventType.SCENE_LOADING_STATE_QUIT,
		BindTool.Bind1(self.OnSceneLoaded, self))
	
	self.main_role_pos_change_handle = GlobalEventSystem:Bind(
		ObjectEventType.MAIN_ROLE_POS_CHANGE,
		BindTool.Bind1(self.OnMainRolePosChange, self))

	-- 初始化
	self:OnSceneLoaded()
	local main_role = Scene.Instance:GetMainRole()
	self:OnMainRolePosChange(main_role:GetLogicPos())

	self.time_quest = GlobalTimerQuest:AddTimesTimer(
		BindTool.Bind2(self.OnUpdateTime, self), 5, 999999999)
end

function MainUIViewMap:__delete()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	GlobalEventSystem:UnBind(self.scene_loading_quit_handle)
	GlobalEventSystem:UnBind(self.main_role_pos_change_handle)
end

function MainUIViewMap:OnSceneLoaded()
	local map_name = Scene.Instance:GetSceneName()
	self.map_name:SetValue(map_name)
end

function MainUIViewMap:OnMainRolePosChange(x, y)
	self.pos_x:SetValue(x)
	self.pos_y:SetValue(y)
end

function MainUIViewMap:OnUpdateTime()
	local time_text = os.date("%H:%M")
	self.time:SetValue(time_text)
	local delay_time = math.floor(TimeCtrl.Instance:GetDelayTime() * 1000)
	local color = "00ff00"
	if delay_time >= 300 then
		color = "ff0000"
	elseif delay_time >= 100 then
		color = "ffff00"
	end
	if delay_time  > 500 then
		delay_time = "≥500"
	end
	self.ping:SetValue("<color=#" .. color .. ">" .. delay_time .. "ms</color>")

	if UnityEngine.SystemInfo.batteryLevel >= 0 then
		self.battery:SetValue(UnityEngine.SystemInfo.batteryLevel)
	end
end
