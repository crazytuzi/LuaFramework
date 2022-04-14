require('game.race.RequireRace')
RaceController = RaceController or class("RaceController",BaseController)

function RaceController:ctor()
	RaceController.Instance = self

	self.race_model = RaceModel:GetInstance()
	self.race_model_events = {}

	self.global_events = {}

    self:AddEvents()
    
	self:RegisterAllProtocal()
end

function RaceController:dctor()
	GlobalEvent:RemoveTabListener(self.global_events)
	self.global_events = {}

	self.race_model:RemoveTabListener(self.race_model_events)
	self.race_model_events = {}

end

function RaceController:GetInstance()
	if not RaceController.Instance then
		RaceController.new()
	end
	return RaceController.Instance
end

function RaceController:RegisterAllProtocal(  )
	-- protobuff的模块名字，用到pb一定要写
	self.pb_module_name = "pb_1203_dunge_pb"
	self:RegisterProtocal(proto.DUNGE_MATCH_START, self.HandleMatchStart)
	self:RegisterProtocal(proto.DUNGE_MATCH_STOP, self.HandleMatchStop)
	self:RegisterProtocal(proto.DUNGE_MATCH_SUCC, self.HandleMatchSucc)
end

function RaceController:AddEvents()
	--打开机甲竞速活动提示界面
	local function call_back()

		--机甲竞速活动提示界面 匹配开始界面 匹配成功界面 存在时 不打开
		if lua_panelMgr:GetPanel(RaceTipPanel) or lua_panelMgr:GetPanel(RaceMatchStartPanel) or lua_panelMgr:GetPanel(RaceMatchSuccPanel) then
			return
		end

		--在机甲竞速场景中时 不打开
		local  scene_data = SceneManager:GetInstance():GetSceneInfo()
		if self.race_model:IsRaceScene(scene_data.scene) then
			return
		end

		local panel = lua_panelMgr:GetPanelOrCreate(RaceTipPanel)
		local data = {}
		panel:Open()
		panel:SetData(data)
	end
	GlobalEvent:AddListener(RaceEvent.OpenRaceTipPanel, call_back)


	local function call_back(scene_id)
		local config = Config.db_scene[scene_id]
		if config.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_RACE then
			--进入机甲竞速场景
			--logError("进入机甲竞速场景")
			local panel = lua_panelMgr:GetPanelOrCreate(RaceMainPanel)
			local data = {}
			panel:Open()
			panel:SetData(data)
		else
			--未进入机甲竞速场景 且需要再来一次时 请求开始匹配
			if self.race_model.is_replay then
				--logError("再来一次")
				self.race_model.is_replay = false

				RaceController.GetInstance():RequestMatchStart(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_RACE,0)
			end
		end
	end
	GlobalEvent:AddListener(EventName.ChangeSceneEnd, call_back);


	--机甲竞速活动开启
	local function call_back(flag, act_id, stime)
		if act_id ~= 11111 then
			return
		end
		if flag then
			--活动开启
			if stime then
				if lua_panelMgr:GetPanel(RaceTipPanel) then
					return
				end

				if self.race_model.is_matching then
					return
				end

				local panel = lua_panelMgr:GetPanelOrCreate(RaceTipPanel)
				local data = {}
				panel:Open()
				panel:SetData(data)
			else
	
			end
		end
	end
	GlobalEvent:AddListener(ActivityEvent.ChangeActivity, call_back)

	--任务开始的匹配
	local function call_back(task_id)
		self.race_model.task_id = task_id
		RaceController.GetInstance():RequestMatchStart(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_RACE,self.race_model.task_id)
	end
	GlobalEvent:AddListener(RaceEvent.StartRaceTask, call_back)
end

--请求开始匹配
function RaceController:RequestMatchStart(stype,task_id)

	--防止重复请求匹配
	if self.race_model.is_matching then
		return
	end

	--在机甲竞速场景中 不允许请求开始匹配
	local  scene_data = SceneManager:GetInstance():GetSceneInfo()
	if self.race_model:IsRaceScene(scene_data.scene) then
		return
	end

	self.race_model.is_matching = true

	local pb = self:GetPbObject("m_dunge_match_start_tos")
	pb.stype = stype
	pb.task_id = task_id 
	self:WriteMsg(proto.DUNGE_MATCH_START,pb)
	--logError("请求开始匹配，stype:" .. stype)
end

--处理开始匹配
function RaceController:HandleMatchStart()

	if lua_panelMgr:GetPanel(RaceMatchStartPanel) then
		return
	end

	local data = self:ReadMsg("m_dunge_match_start_toc")
	local stype = data.stype
	--logError("处理开始匹配，stype:" .. stype)

--[[ 	if not self.race_model.task_id then
		local panel = lua_panelMgr:GetPanelOrCreate(RaceMatchStartPanel)
		local data = {}
		panel:Open()
		panel:SetData(data)
	end ]]

	local panel = lua_panelMgr:GetPanelOrCreate(RaceMatchStartPanel)
	local data = {}
	panel:Open()
	panel:SetData(data)

end

--请求停止匹配
function RaceController:RequestMatchStop(stype)
	local pb = self:GetPbObject("m_dunge_match_stop_tos")
	pb.stype = stype
	self:WriteMsg(proto.DUNGE_MATCH_STOP,pb)
	--logError("请求停止匹配，stype:" .. stype)

	self.race_model.is_matching = false
end

--处理停止匹配
function RaceController:HandleMatchStop()
	local data = self:ReadMsg("m_dunge_match_stop_toc")
	local stype = data.stype
	--logError("处理停止匹配，stype:" .. stype)
end

--处理匹配成功
function RaceController:HandleMatchSucc()

	--在机甲竞速场景中 不允许处理匹配成功
	local  scene_data = SceneManager:GetInstance():GetSceneInfo()
	if self.race_model:IsRaceScene(scene_data.scene) then
		return
	end
	

	local data = self:ReadMsg("m_dunge_match_succ_toc")
	local roles = data.roles
	local main_role_data =  RoleInfoModel.GetInstance():GetMainRoleData()
	
	local random_num = Mathf.Random(1,3)
	table.insert( roles, random_num, main_role_data )

	self.race_model.race_roles = roles
	self.race_model.is_matching = false

	self.race_model:Brocast(RaceEvent.MatchSucc)

	--[[ if self.race_model.task_id then
		--是任务 直接进副本
		local param = {}
		param.task_id = self.race_model.task_id
		DungeonCtrl:GetInstance():RequestEnterDungeon(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_RACE, nil, nil, nil, nil,param)
	end ]]
	--logError("匹配成功")
end

--请求上报玩家结果
function RaceController:RequestReportResult(is_finish,rank,time)
	local pb = self:GetPbObject("m_dunge_race_result_tos")
	pb.is_finish = is_finish
	pb.rank = rank
	pb.time = time
	self:WriteMsg(proto.DUNGE_RACE_RESULT,pb)

	--logError("上报竞速结果，rank:"..rank..",time:"..time)
end

