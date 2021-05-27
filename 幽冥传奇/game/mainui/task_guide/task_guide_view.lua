---------------------------
--左侧任务引导 
--管理如主线任务 精英任务等 显示任务状态数据概略
--1 特效提示任务完成
--2 点击任务 以提示或进行任务


local DigShowRender = require("scripts/game/mainui/task_guide/dig_show_render")
local BossSceneRender = require("scripts/game/mainui/task_guide/boss_scene_render")
require("scripts/game/mainui/task_guide/rexue_boss_guide")

local list_hide_x = - 160
local list_show_x = 198

MainuiSmallParts = MainuiSmallParts or BaseClass()
local TaskGuideSize = cc.size(252, 200)
local RenderWidth = 80

local remind_group_list = SetBag{
	RemindGroupName.CaiLiaoFBView,
	RemindGroupName.ShiLianView,
	RemindGroupName.TasksView,
	RemindGroupName.ShenDingView,
}

local cond_list = SetBag{
	ViewDef.Dungeon.v_open_cond,
	-- ViewDef.ShiLian.v_open_cond,
	ViewDef.Tasks.v_open_cond,
	ViewDef.ShenDing.v_open_cond,
	"CondId19",
}

local TASK_GUIDE_TYPE = {
	MIAN = 1, 				--主线
	CHUMO = 2, 				--除魔
	GUILD = 3, 				--行会悬赏
	TIANSHU = 4, 			--天书
	ZSTASK = 5, 			--钻石任务
	LEVEL = 6, 				--经验副本（等级）
	MULTIPLAYER = 7, 		--多人副本（装备）
	MATERIAL = 8, 			--材料副本（材料）
	BOOMERANG = 9, 			--押镖
	DIGORE = 10, 			--挖矿（强化）
	DAILY = 11, 				--日常
	TRIAL = 12, 			--闯关
	FORTUNE = 13, 			--运势
}

local OTHER_TASK_ID = 999 --支线任务，非主线任务 用于判断是否可传送到npc
local task_guide_cfg = {
	{title_str = "", desc_str = "", task_type = TASK_GUIDE_TYPE.MIAN, state = 9},
	{title_str = "每日除魔", desc_str = "点击前往除魔", task_type = TASK_GUIDE_TYPE.CHUMO, task_id = OTHER_TASK_ID, npc = {id = 83, scene_id = 2, x = 65, y = 129,}, open_cond = "CondId60", state = 0},
	{title_str = "行会悬赏", desc_str = "点击前往行会悬赏", task_type = TASK_GUIDE_TYPE.GUILD, task_id = OTHER_TASK_ID, view_link = ViewDef.Guild.OfferView, open_cond = "CondId20", state = 0},
	{title_str = "天书任务", desc_str = "点击前往接受", task_type = TASK_GUIDE_TYPE.TIANSHU, task_id = OTHER_TASK_ID, npc = {id = 249, scene_id = 2, x = 77, y = 122,}, open_cond = "CondId28", state = 0},
	{title_str = "神装", desc_str = "", task_type = TASK_GUIDE_TYPE.ZSTASK, view_link = ViewDef.ZsTaskView, open_cond = "CondId27", state = 0},
	{title_str = "", desc_str = "", task_type = TASK_GUIDE_TYPE.LEVEL, task_id = OTHER_TASK_ID, npc = {id = 80, scene_id = 2, x = 129, y = 71,}, open_cond = "CondId69", state = 0},
	{title_str = "多人副本", desc_str = "点击前往多人副本", task_type = TASK_GUIDE_TYPE.MULTIPLAYER, task_id = OTHER_TASK_ID, npc = {id = 115, scene_id = 2, x = 126, y = 114,}, open_cond = "CondId134", state = 0},
	{title_str = "", desc_str = "", task_type = TASK_GUIDE_TYPE.MATERIAL, task_id = OTHER_TASK_ID, npc = {id = 80, scene_id = 2, x = 129, y = 71,}, open_cond = "CondId68", state = 0},
	{title_str = "护送镖车", desc_str = "点击前往押镖", task_type = TASK_GUIDE_TYPE.BOOMERANG, task_id = OTHER_TASK_ID, npc = {id = 101, scene_id = 2, x = 176, y = 117,}, open_cond = "CondId102", state = 0},
	{title_str = "", desc_str = "", task_type = TASK_GUIDE_TYPE.DIGORE, view_link = ViewDef.Experiment.DigOre, open_cond = "CondId66", state = 0},
	{title_str = "日常活跃", desc_str = "打开日常活跃面板", task_type = TASK_GUIDE_TYPE.DAILY, view_link = ViewDef.Activity.Active, open_cond = ViewDef.Activity.Active.v_open_cond, state = 0},
	{title_str = "试炼闯关", desc_str = "打开练功房面板", task_type = TASK_GUIDE_TYPE.TRIAL, view_link = ViewDef.Experiment.Trial, open_cond = "CondId66", state = 0},
	{title_str = "运势BOSS", desc_str = "打开激战BOSS面板", task_type = TASK_GUIDE_TYPE.FORTUNE, view_link = ViewDef.NewlyBossView.Rare.FortureBoss, open_cond = "CondId78", state = 0},
}

function MainuiSmallParts:DeleteFuncBarList()
	if self.task_listview then
		self.task_listview:DeleteMe()
		self.task_listview = nil
	end

	if self.team_listview then
		self.team_listview:DeleteMe()
		self.team_listview = nil
	end

	if nil ~= self.scene_change then
		GlobalEventSystem:UnBind(self.scene_change)
		self.scene_change = nil
	end
	
	self.task_ui_node_list = {}
	self.task_ui_ph_list = {}
	self.arrow_root = nil
end

function MainuiSmallParts:InitFuncBarList()
	self.task_list_is_top = true
	self.task_list_is_top_main = true
	self.task_guild_top = true
	self.list_btn = true
	self.top_y = 0
	local left_top = self.main_view:GetPartLayout(MainuiView.LAYOUT_PART.LEFT_TOP)
	
	local ui_config = ConfigManager.Instance:GetUiConfig("main_ui_cfg")
	for k, v in pairs(ui_config) do
		if v.n == "layout_task" then
			self.ui_cfg = v
			break
		end
	end

	-- self.ui_cfg.x = 75
	-- self.ui_cfg.y = 575
	self.task_ui_node_list = {}
	self.task_ui_ph_list = {}
	left_top:TextureLayout():addChild(XUI.GeneratorUI(self.ui_cfg, nil, nil, self.task_ui_node_list, nil, self.task_ui_ph_list).node, 999, 999)
	self.task_ui_node_list.layout_show_btn.node:setVisible(false)

	--任务列表
	local ph = self.task_ui_ph_list.ph_task_view
	self.task_listview = ListView.New()
	self.task_listview:Create(ph.x, ph.y, ph.w, ph.h, nil, MainuiSmallPartsItemReander)
	self.task_listview:SetMargin(2)
	self.task_listview:SetSelectCallBack(BindTool.Bind(self.OnClickTask, self))
	-- self.task_listview:GetView():setAnchorPoint(0, 1)
	self.task_listview:SetJumpDirection(ListView.Top)
	self.task_listview:GetView():addScrollEventListener(BindTool.Bind(self.ScrollHandler, self))
	self.task_ui_node_list.layout_task.node:addChild(self.task_listview:GetView(), 1)
	-- self.task_listview:SetDataList({task_guide_cfg[1]})

	--主队列表
	self.team_listview = ListView.New()
	self.team_listview:Create(ph.x, ph.y, ph.w, ph.h, nil, MainuiTeamItemReander)
	self.team_listview:SetMargin(1)
	-- self.team_listview:GetView():setAnchorPoint(0, 1)
	self.team_listview:GetView():setVisible(false)
	self.task_ui_node_list.layout_task.node:addChild(self.team_listview:GetView(), 1)

	-- 变化位置的按钮
	XUI.AddClickEventListener(self.task_ui_node_list.btn_arrow.node, BindTool.Bind(self.OnClickFuncBarArrow, self))
	XUI.AddClickEventListener(self.task_ui_node_list.btn_arrow_2.node, BindTool.Bind(self.OnClickFuncBarArrow, self))

	--按钮
	self.task_ui_node_list.btn_task.node:setHittedScale(1.03)
	XUI.AddClickEventListener(self.task_ui_node_list.btn_task.node, function ()
		self:FlushListShow(false)
		self:FlushBossScene(false)
	end, true)
	
	self.task_ui_node_list.btn_team.node:setHittedScale(1.03)
	XUI.AddClickEventListener(self.task_ui_node_list.btn_team.node, function ()
		self:FlushListShow(true)
		self:FlushBossScene(false)

		self.task_ui_node_list.layout_boss_list.node:setVisible(false)
		self.task_listview:GetView():setVisible(false)
		
		self:OnTeamChange()
	end, true)

	self.task_ui_node_list.layout_scene_btn.btn_task1.node:setHittedScale(1.03)
	XUI.AddClickEventListener(self.task_ui_node_list.layout_scene_btn.btn_task1.node, function ()
		self:FlushListShow(false)
		self:FlushBossScene(false)
	end, true)
	
	self.task_ui_node_list.layout_scene_btn.btn_scene.node:setHittedScale(1.03)
	XUI.AddClickEventListener(self.task_ui_node_list.layout_scene_btn.btn_scene.node, function ()
		self:FlushListShow(false)
		self:FlushBossScene(true)
	end, true)

	self:FlushListShow(false)

	self:ResignEvent()
end

function MainuiSmallParts:GetMainTaskRender()
	return self.task_listview:GetItemAt(1):GetView()
end

-- boss场景栏刷新
function MainuiSmallParts:FlushBossScene(is_show)
	local is_in_dig_scene = Scene.Instance:GetSceneId() == DigOreSceneId
	if is_in_dig_scene then return end
	self.task_listview:GetView():setVisible(not is_show)
	self.task_ui_node_list.layout_boss_list.node:setVisible(is_show)

	if self.boss_list_render then
		self.boss_list_render:DeleteMe()
		NodeCleaner.Instance:AddNode(self.boss_list_render:GetView())
		self.boss_list_render = nil
	end

	if is_show then
		self.boss_list_render = BossSceneRender.New()
		self.boss_list_render:SetUiConfig(self.task_ui_ph_list.ph_boss_item, true)
		self.boss_list_render:SetData(nil)
		self.task_ui_node_list.layout_boss_list.node:addChild(self.boss_list_render:GetView())
	end
end

-- 任务栏刷新
function MainuiSmallParts:FlushListShow(is_show_team)
	local is_in_dig_scene = Scene.Instance:GetSceneId() == DigOreSceneId

	self.task_ui_node_list.layout_boss_list.node:setVisible(false)
	self.task_listview:GetView():setVisible(not (is_in_dig_scene and not is_show_team))
	self.task_ui_node_list.layout_dig_scene.node:setVisible(is_in_dig_scene and not is_show_team)
	if not is_in_dig_scene and self.dig_show_render then
		self.dig_show_render:DeleteMe()
		NodeCleaner.Instance:AddNode(self.dig_show_render:GetView())
		self.dig_show_render = nil
	elseif is_in_dig_scene and nil == self.dig_show_render then
		self.dig_show_render = DigShowRender.New()
		self.dig_show_render:SetUiConfig(self.task_ui_ph_list.ph_dig_item, true)
		self.dig_show_render:SetData(ExperimentData.Instance:GetBaseInfo())
		self.task_ui_node_list.layout_dig_scene.node:addChild(self.dig_show_render:GetView())
	end

	self.team_listview:GetView():setVisible(is_show_team)

	self.task_ui_node_list.img_task.node:loadTexture(is_show_team and ResPath.GetMainui("txt_task_2") or ResPath.GetMainui("txt_task_1"))
	self.task_ui_node_list.btn_task.node:loadTexture(is_show_team and ResPath.GetMainui("btn_task_unselect") or ResPath.GetMainui("btn_task_select"))
	
	self.task_ui_node_list.img_team.node:loadTexture(is_show_team and ResPath.GetMainui("txt_team_1") or ResPath.GetMainui("txt_team_2"))
	self.task_ui_node_list.btn_team.node:loadTexture(is_show_team and ResPath.GetMainui("btn_task_select") or ResPath.GetMainui("btn_task_unselect"))
end

function MainuiSmallParts:ScrollHandler(sender, event_type, x, y)
	local top_pos_y = TaskGuideSize.height - self.task_listview:GetCount() * RenderWidth
	self.task_list_is_top = (self.task_listview:GetView():getInnerPosition().y - (top_pos_y >= 0 and 0 or top_pos_y)) <= 120
	self.task_list_is_top_main = (self.task_listview:GetView():getInnerPosition().y - (top_pos_y >= 0 and 0 or top_pos_y)) <= 50
	self.task_guild_top = (self.task_listview:GetView():getInnerPosition().y - (top_pos_y >= 0 and 0 or top_pos_y)) <= 210
	self.top_y = self.task_listview:GetView():getInnerPosition().y - (top_pos_y >= 0 and 0 or top_pos_y)
	self:CheckGuideEffect()
	self:CheckChumoEffect()
	self:CheckGuildEffect()
end

function MainuiSmallParts:OnClickTask(item, index)
	local data = item:GetData()
	if nil == data then return end
	if data.task_type == TASK_GUIDE_TYPE.MIAN then
		MainuiTask.HandleTask(TaskData.Instance:GetMainTaskInfo())
	elseif data.task_type == TASK_GUIDE_TYPE.CHUMO then
		if data.state == 1 then
			DailyTasksCtrl.Instance:SendDailyTasksReq(2)
		else
			MainuiTask.OnTaskTalkToNpc(data)
		end
	elseif data.task_type == TASK_GUIDE_TYPE.GUILD then
		local have_guild = GuildData.Instance:HaveGuild()
		local data = GuildData.Instance:GetShowTask()
		if have_guild then
			if data == nil or (data.task_state == 2 and data.is_reward == 0) then
				ViewManager.Instance:OpenViewByDef(ViewDef.Guild.OfferView)
			else
				if not data.open_btn then return end
				if data.open_btn.view_def ~= nil then
					ViewManager.Instance:OpenViewByDef(data.open_btn.view_def)
				elseif data.open_btn.npc_id ~= nil then
					Scene.SendQuicklyTransportReqByNpcId(self.data.npcid)
				elseif data.open_btn.boss_cfg ~= nil then
					BossCtrl.CSChuanSongBossScene(data.open_btn.boss_cfg.type, data.open_btn.boss_cfg.boss_id)
				end
			end
		else
			ViewManager.Instance:OpenViewByDef(ViewDef.Guild.GuildView)
		end
	else
		if data.view_link then 
			ViewManager.Instance:OpenViewByDef(data.view_link)
		elseif data.npc then
			MainuiTask.OnTaskTalkToNpc(data)
		end
	end
end

function MainuiSmallParts:OnTeamChange()
	local data_list = {}
	-- self.task_ui_node_list.layout_boss_list.node:setVisible(false)
	-- self.task_listview:GetView():setVisible(false)
	-- self.team_listview:GetView():setVisible(true)
	for i, v in ipairs(TeamData.Instance:GetMemberList()) do
		if v.role_id == TeamData.Instance:GetLeaderId() then
			table.insert(data_list, 1, {reander_type = "role", info = v})
		else
			table.insert(data_list, {reander_type = "role", info = v})
		end
	end
	
	local data_count = #data_list
	if data_count == 0 then
		table.insert(data_list, {reander_type = "create", info = nil})
	elseif data_count < TeamData.MaxMemberCount then
		table.insert(data_list, {reander_type = "invite", info = nil})
	end
	self.team_listview:SetDataList(data_list)

	self:FlushListBgHeight()
end

function MainuiSmallParts:ResignEvent()
	self.task_instance = TaskData.Instance
	local task_event_proxy = EventProxy.New(self.task_instance)
	task_event_proxy:AddEventListener(TaskData.ON_TASK_LIST, BindTool.Bind(self.FLushMainTask, self))
	task_event_proxy:AddEventListener(TaskData.ADD_ONE_TASK, BindTool.Bind(self.FLushMainTask, self))
	task_event_proxy:AddEventListener(TaskData.FINISH_ONE_TASK, BindTool.Bind(self.FLushMainTask, self))
	task_event_proxy:AddEventListener(TaskData.GIVEUP_ONE_TASK, BindTool.Bind(self.FLushMainTask, self))
	task_event_proxy:AddEventListener(TaskData.TASK_VALUE_CHANGE, BindTool.Bind(self.FLushMainTask, self))
	task_event_proxy:AddEventListener(TaskData.TASK_VALUE_CHANGE, BindTool.Bind(self.FLushMainTask, self))
	EventProxy.New(ExperimentData.Instance, self):AddEventListener(ExperimentData.INFO_CHANGE, BindTool.Bind(self.FLushMainTask, self))
	EventProxy.New(EscortData.Instance, self):AddEventListener(EscortData.LEFT_TIMES_CHANGE, BindTool.Bind(self.FLushMainTask, self))
	EventProxy.New(ShenDingData.Instance, self):AddEventListener(ShenDingData.TASK_DATA_CHANGE, BindTool.Bind(self.FLushMainTask, self))
	EventProxy.New(FubenMutilData.Instance, self):AddEventListener(FubenMutilData.LEFT_ENTER_TIMES, BindTool.Bind(self.FLushMainTask, self))
	
	GlobalEventSystem:Bind(OtherEventType.CAILIAO_INFO_CHANGE, BindTool.Bind(self.FLushMainTask, self))

	GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE,function ()
		self:FlushListShow(false)
		self:FLushMainTask()
		self:FlushReXueBoss()

		local scene_id = Scene.Instance:GetSceneId()
		local show_state = false
		for k, v in pairs(NewlyBossData.Instance:GetTipScene()) do
			if scene_id == v then
				show_state = true
			 end
		end
		self:FlushBossScene(show_state)
		self.task_ui_node_list.layout_scene_btn.node:setVisible(show_state and (not IS_ON_CROSSSERVER))
	end)

	--组队信息改变
	EventProxy.New(TeamData.Instance, self):AddEventListener(TeamData.TEAM_INFO_CHANGE, BindTool.Bind(self.OnTeamChange, self))
	-- 除魔状态下发监听
	EventProxy.New(DailyTasksData.Instance, self):AddEventListener(DailyTasksData.TASKS_DATA_CHANGE, BindTool.Bind(self.OnTasksDataChange, self))
	-- 钻石任务下发监听
	EventProxy.New(ZsTaskData.Instance, self):AddEventListener(ZsTaskData.REWARD_STATE, BindTool.Bind(self.OnTasksDataChange, self))
	-- 行会悬赏下发监听
	EventProxy.New(GuildData.Instance, self):AddEventListener(GuildData.GuildOffer, BindTool.Bind(self.OnTasksDataChange, self))
	-- 天书任务下发监听
	EventProxy.New(TaskData.Instance, self):AddEventListener(TaskData.TIANSHU_NUM, BindTool.Bind(self.OnTasksDataChange, self))
end

function MainuiSmallParts:ChangeScene(scene_id, scene_type, fb_id)
	local scene_config = ConfigManager.Instance:GetSceneConfig(scene_id)
	if nil == scene_config then
		Log("scene_config not find, scene_id:" .. scene_id)
		return
	end
	if scene_id == DigOreSceneId then
		
	end
end

function MainuiSmallParts:OnTasksDataChange()
	self.task_listview:SetDataList(self:GetTaskGuideData())
	self:CheckChumoEffect()
	self:CheckGuildEffect()
end

---------------------------------------------------
-- 功能条
---------------------------------------------------

function MainuiSmallParts:OnClickFuncBarArrow()
	if self.task_ui_node_list.layout_task.node:getNumberOfRunningActions() > 0 then
		return
	end
	local is_hide = self.task_ui_node_list.layout_task.node:getPositionX() == list_hide_x
	local pos_x = is_hide and list_show_x or list_hide_x
	self.list_btn = is_hide
	local pos_y = self.task_ui_node_list.layout_task.node:getPositionY()
	self.task_ui_node_list.layout_task.node:runAction(cc.Sequence:create(cc.MoveTo:create(0.15, cc.p(pos_x, pos_y)), cc.CallFunc:create(function ()
		self.task_ui_node_list.layout_show_btn.node:setVisible(not is_hide)
	end)))

	self:CheckGuideEffect()
	self:CheckChumoEffect()
	self:CheckGuildEffect()
end

-- 判断任务栏是否隐藏
function MainuiSmallParts:GetTaskListShow()
	local can_show = Scene.Instance:GetSceneLogic():CanShowMainuiTask()

	self.task_ui_node_list.layout_task.node:setVisible(can_show)

	if IS_ON_CROSSSERVER then
		self.task_ui_node_list["btn_task"].node:setEnabled(false)
		self.task_ui_node_list["btn_team"].node:setEnabled(false)
		self.task_ui_node_list["btn_arrow"].node:setEnabled(false)
	else
		self.task_ui_node_list["btn_task"].node:setEnabled(true)
		self.task_ui_node_list["btn_team"].node:setEnabled(true)
		self.task_ui_node_list["btn_arrow"].node:setEnabled(true)
	end
end

function MainuiSmallParts:FlushListBgHeight()
	-- local list_item_num = 1
	-- if self.task_listview:GetView():isVisible() then
	-- 	list_item_num = #self.task_listview:GetDataList() >= 3 and 3 or #self.task_listview:GetDataList()
	-- else
	-- 	list_item_num = #self.team_listview:GetDataList() >= 3 and 3 or #self.team_listview:GetDataList()
	-- end

	-- local height = list_item_num >= 3 and TaskGuideSize.height or RenderWidth * list_item_num
	-- self.img_list_bg:setContentSize(cc.size(TaskGuideSize.width, height))
end

-- 主线卡级任务完成特效
function MainuiSmallParts:CheckGuideEffect(pos)
	-- if RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) >= 70 then
		if self.main_effect then
			self.main_effect:removeFromParent()
			self.main_effect = nil
		end
	-- 	return 
	-- end
	local posy = self.top_y ~= 0 and self.top_y+200 or 205
	local task_data = TaskData.Instance:GetMainTaskInfo()
	if nil == task_data then return end
	local task_state = TaskData.Instance:GetTaskState(task_data)
	local is_lv_task = task_data.task_id == 30 or task_data.task_id == 36 or task_data.task_id == 44
	local is_show = self.task_list_is_top_main and self.list_btn and not (task_data.target and task_data.target.target_value > 1 and task_state ~= TaskState.Complete) and is_lv_task
	if nil == self.main_effect then
		self.main_effect = RenderUnit.CreateEffect(1162, self.task_ui_node_list.layout_task.node, 300, nil, nil, TaskGuideSize.width*1.7, posy)
	end
	self.main_effect:setVisible(is_show)
end

-- 除魔任务完成特效
function MainuiSmallParts:CheckChumoEffect(pos)
	if self.task_effect then
		self.task_effect:removeFromParent()
		self.task_effect = nil
	end

	local posy = self.top_y ~= 0 and self.top_y+120 or 125
	if nil == self.task_instance:GetMainTaskInfo() then
		posy = self.top_y ~= 0 and self.top_y+200 or 205
	end
	
	local data = DailyTasksData.Instance:GetData()

	local is_show = self.task_list_is_top and self.list_btn and data.state == 2
	if nil == self.task_effect then
		self.task_effect = RenderUnit.CreateEffect(1162, self.task_ui_node_list.layout_task.node, 300, nil, nil, TaskGuideSize.width*1.7, posy)
	end
	self.task_effect:setVisible(is_show)
end

-- 行会悬赏任务完成特效
function MainuiSmallParts:CheckGuildEffect(pos)
	if self.guild_effect then
		self.guild_effect:removeFromParent()
		self.guild_effect = nil
	end

	local data = DailyTasksData.Instance:GetData()
	local is_chumo = data.times == 0 and data.state == 0
	local posy = self.top_y ~= 0 and self.top_y+40 or 45
	if nil == self.task_instance:GetMainTaskInfo() then
		if is_chumo then
			posy = self.top_y ~= 0 and self.top_y+200 or 205
		else
			posy = self.top_y ~= 0 and self.top_y+120 or 125
		end
	else
		if is_chumo then
			posy = self.top_y ~= 0 and self.top_y+120 or 125
		end
	end
	
	local xh_data = GuildData.Instance:GetShowTask()

	local is_show = self.task_guild_top and self.list_btn and (xh_data and xh_data.task_state == 2)
	if nil == self.guild_effect then
		self.guild_effect = RenderUnit.CreateEffect(1162, self.task_ui_node_list.layout_task.node, 300, nil, nil, TaskGuideSize.width*1.7, posy)
	end
	self.guild_effect:setVisible(is_show)
end

--其他任 务可接
function MainuiSmallParts:FlushOtherTaskState(group_name, num)
	if nil == remind_group_list[group_name] then return end
	self.task_listview:SetDataList(self:GetTaskGuideData())
end

--游戏条件改变
function MainuiSmallParts:GetTaskGuideData()
	local t = {}
	for i,v in ipairs(task_guide_cfg) do
		if v.task_type == TASK_GUIDE_TYPE.MIAN then 
			table.insert(t, v)
		elseif v.task_type == TASK_GUIDE_TYPE.CHUMO then
			if GameCondMgr.Instance:GetValue(v.open_cond) then
				local data = DailyTasksData.Instance:GetData()
				if data.times == 0 and data.state == 0 then
					v.state = -1
				else
					v.state = data.state
				end
				table.insert(t, v)
			end
		elseif v.task_type == TASK_GUIDE_TYPE.GUILD then
			if GameCondMgr.Instance:GetValue(v.open_cond) then
				local vis = GuildData.Instance:GetAllTaskState()
				if vis == 0 then
					v.state = -1
				else
					v.state = 0
				end
				table.insert(t, v)
			end
		elseif v.task_type == TASK_GUIDE_TYPE.ZSTASK then
			local is_show = ZsTaskData.Instance:ZsTaskRewrdIsAllget()
			if GameCondMgr.Instance:GetValue(v.open_cond) and not is_show then
				table.insert(t, v)
			end
		else
			if GameCondMgr.Instance:GetValue(v.open_cond) then
				table.insert(t, v)
			end
		end
	end 

	if nil == self.task_instance:GetMainTaskInfo() then
		table.remove(t, 1)
	end

	table.sort( t, function (a, b)
		local a_remind = RemindManager.Instance:GetRemindGroup(a.remind_group)
		local b_remind = RemindManager.Instance:GetRemindGroup(b.remind_group)
		
		if a.state ~= b.state then
			return a.state > b.state
		else
			return a.task_type < b.task_type
		end
	end)

	return t
end

function MainuiSmallParts:FlushTaskGuide(cond_name)
	if nil == cond_list[cond_name] then return end
	self.task_listview:SetDataList(self:GetTaskGuideData())
	-- self:CheckGuideEffect()
	self:FlushListBgHeight()
end

--主任务刷新

function MainuiSmallParts:FLushMainTask(index)
	if IS_ON_CROSSSERVER then return end

	--判断主线是否完成
	if nil ~= self.task_instance:GetMainTaskInfo() then
		GlobalEventSystem:FireNextFrame(MainUIEventType.TASK_BAR_VIS, vis)
	end
	
	self.task_listview:SetDataList(self:GetTaskGuideData())
	self:CheckGuideEffect()
	self:CheckChumoEffect()
	self:CheckGuildEffect()
	self:FlushListBgHeight()
	self:GetTaskListShow()

	local task_data = TaskData.Instance:GetMainTaskInfo()
	if nil == task_data then return end
	local task_state = TaskData.Instance:GetTaskState(task_data)
	local is_show = not (task_data.target and task_data.target.target_value > 1 and task_state ~= TaskState.Complete)
	
	if is_show then
		self:FlushListShow(false)
		self:FlushBossScene(false)
	end
end

function MainuiSmallParts.SetTaskDesc(rich_node, desc, total_color, task_data, task_state)
	if nil == task_data then
		return
	end

	local color = task_state == TaskState.Complete and COLORSTR.GREEN or COLORSTR.RED
	desc = string.gsub(desc, "<target_color>", color)
	desc = string.gsub(desc, "<task_title>", task_data.title)

	if nil ~= task_data.target then
		desc = string.gsub(desc, "<cur_value>", task_data.target.cur_value)
		desc = string.gsub(desc, "<target_value>", task_data.target.target_value)
		desc = string.gsub(desc, "<name>", task_data.target.name)
		desc = string.gsub(desc, "<id>", task_data.target.id)
	end
	if nil ~= task_data.npc then
		desc = string.gsub(desc, "<npc_name>", task_data.npc.name)
	end

	RichTextUtil.ParseRichText(rich_node, desc, 20, total_color)
end

------------------------------------------------------------------------
-- 任务Reander
MainuiSmallPartsItemReander = MainuiSmallPartsItemReander or BaseClass(BaseRender)
function MainuiSmallPartsItemReander:__init()
	self.view:setContentWH(TaskGuideSize.width, RenderWidth)
	self.rich_title = nil
	self.rich_desc = nil
	self.img_type = nil
	self.cm_eff = nil
end

function MainuiSmallPartsItemReander:__delete()
end

function MainuiSmallPartsItemReander:CreateChild()
	BaseRender.CreateChild(self)
	
	self:AddClickEventListener(nil, true)
	
	local img_line = XUI.CreateImageView(TaskGuideSize.width / 2, 1, ResPath.GetMainui("task_line"), true)
	self.view:addChild(img_line, - 1)

	self.img_type = XUI.CreateImageView(33, 50, nil, true)
	self.view:addChild(self.img_type, 1)
	
	self.rich_title = XUI.CreateRichText(62, 50,TaskGuideSize.width, 20)
	-- XUI.RichTextSetCenter(self.rich_title)
	-- self.rich_title:setVerticalAlignment(RichVAlignment.VA_CENTER)
	self.rich_title:setAnchorPoint(0, 0.5)
	self.rich_title:setMaxLine(2)
	self.rich_title:setVerticalSpace(4)
	self.rich_title:setIgnoreSize(true)
	self.view:addChild(self.rich_title)	

	self.rich_desc = XUI.CreateRichText(10, 20, TaskGuideSize.width, 30)
	-- XUI.RichTextSetCenter(self.rich_desc)
	-- self.rich_desc:setVerticalAlignment(RichVAlignment.VA_CENTER)
	self.rich_desc:setAnchorPoint(0, 0.5)
	self.rich_desc:setMaxLine(2)
	self.rich_desc:setVerticalSpace(4)
	self.rich_desc:setIgnoreSize(true)
	self.view:addChild(self.rich_desc)


	self.task_state = XUI.CreateRichText(TaskGuideSize.width - 60, 60, 80, 30)
	-- XUI.RichTextSetCenter(self.task_state)
	-- self.task_state:setVerticalAlignment(RichHAlignment.HA_LEFT)
	self.task_state:setAnchorPoint(0, 1)
	self.task_state:setMaxLine(2)
	self.task_state:setVerticalSpace(4)
	self.task_state:setIgnoreSize(true)
	self.view:addChild(self.task_state)

	if self:GetIndex() == 1 or self.data.npc then
		RichTextUtil.ParseRichText(self.task_state, "", 20,  COLOR3B.GREEN)
	end

	-- if self.cm_eff == nil then
	-- 	self.cm_eff = RenderUnit.CreateEffect(23, self.view, 200, nil, nil, 120, 40)
	-- 	self.cm_eff:setScale(1.5)
	-- 	self.cm_eff:setVisible(false)
	-- end
end

-- function MainuiSmallPartsItemReander:CreateSelectEffect()
-- end

function MainuiSmallPartsItemReander:OnFlush()
	if nil == self.data then return end
	self.img_type:loadTexture(ResPath.GetMainui("task_type_" .. self.data.task_type))
	if self.data.task_type == TASK_GUIDE_TYPE.MIAN then
		local task_data = TaskData.Instance:GetMainTaskInfo()
		local task_state = TaskData.Instance:GetTaskState(task_data)
		local task_config = TaskConfig[task_data.task_id]
		local txt_content = task_config.txt_content[task_state] or task_config.txt_content[-1] or string.format("无配置任务id:%d", task_data.task_id)
		local txt_content2 = task_config.txt_content2[task_state] or task_config.txt_content2[-1] or string.format("无配置任务id:%d", task_data.task_id)

		MainuiSmallParts.SetTaskDesc(self.rich_title, txt_content, COLOR3B.ORANGE, task_data, task_state)
		MainuiSmallParts.SetTaskDesc(self.rich_desc, txt_content2, COLOR3B.WHITE, task_data, task_state)
	elseif self.data.task_type == TASK_GUIDE_TYPE.CHUMO then
		local cm_data = DailyTasksData.Instance:GetData()
		local title_str = ""
		local desc_str = ""
		if cm_data.state == 0 then
			title_str = "每日除魔{wordcolor;ff0000;(可接)}"
			desc_str = self.data.desc_str
			if DailyTasksData.Instance:GetData().times <= 0 then
				title_str = "每日除魔{wordcolor;00ff00;(已完成)}"
				desc_str = "当日无可用次数"
			end
		elseif cm_data.state == 1 then
			title_str = "每日除魔{wordcolor;ff0000;(进行中)}"
			desc_str = cm_data.goal
		elseif cm_data.state == 2 then
			title_str = "每日除魔{wordcolor;00ff00;(已完成)}"
			desc_str = "点击前往领取奖励"
		end
		RichTextUtil.ParseRichText(self.rich_title, title_str, 20, COLOR3B.ORANGE)
		RichTextUtil.ParseRichText(self.rich_desc, desc_str, 20,  COLOR3B.WHITE)
	elseif self.data.task_type == TASK_GUIDE_TYPE.GUILD then
		local data = GuildData.Instance:GetShowTask()
		local title_str = ""
		local desc_str = ""
		if data == nil then
			local is_com = GuildData.Instance:GetAllTaskState()
			if is_com == 1 then
				title_str = "行会悬赏{wordcolor;ff0000;(可接)}"
				desc_str = "点击前往悬赏"
			else
				title_str = "行会悬赏"
				desc_str = "点击前往悬赏"
			end
		else
			if data.task_state == 1 then
				title_str = "行会悬赏{wordcolor;ff0000;(进行中)}"
				local color = data.complete_num >= data.max_num and "55ff00" or "ff0000"
				local txt = data.desc .. string.format("{wordcolor;%s;(%d/%d)}", color, data.complete_num, data.max_num)
				desc_str = txt
			elseif data.task_state == 2 then
				if data.is_reward == 1 then
					title_str = "行会悬赏{wordcolor;ff0000;(可接)}"
					desc_str = "点击前往悬赏"
				else
					title_str = "行会悬赏{wordcolor;00ff00;(已完成)}"
					desc_str = "点击前往领取奖励"
				end
			end
		end

		RichTextUtil.ParseRichText(self.rich_title, title_str, 20, COLOR3B.ORANGE)
		RichTextUtil.ParseRichText(self.rich_desc, desc_str, 20,  COLOR3B.WHITE)
	elseif self.data.task_type == TASK_GUIDE_TYPE.LEVEL then
		local had_times = FubenData.Instance:GetHadFightingNum()
		local zs_lv =  RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)
		local i_num = VipConfig.VipGrade[zs_lv] and  VipConfig.VipGrade[zs_lv].expFbAddCount or 0
		local buy_time = FubenData.Instance:JyFubenBuyTime()
		local totol_times = expFubenConfig.dayEnCount  + i_num + buy_time
		local sy_times = totol_times - had_times < 0 and 0 or  totol_times - had_times
		local title_str = ""
		local desc_str = ""
		if sy_times >= 0 then
			title_str = "经验副本{wordcolor;ff0000;(可接)}"
			desc_str = "点击前往经验副本"
		else
			title_str = "经验副本{wordcolor;00ff00;(已完成)}"
			desc_str = "点击前往经验副本"
		end

		RichTextUtil.ParseRichText(self.rich_title, title_str, 20, COLOR3B.ORANGE)
		RichTextUtil.ParseRichText(self.rich_desc, desc_str, 20,  COLOR3B.WHITE)
	elseif self.data.task_type == TASK_GUIDE_TYPE.MATERIAL then
		local data = DungeonData.Instance:GetFubenCLList()
		local bool = false
		for k, v in pairs(data) do
			local act_info = DungeonData.Instance:GetFubenInfo(v.static_id) or {}
			local challge_count = act_info.challge_count or 0
			if challge_count ~= 0 then
				bool = true
				break
			end
		end

		if bool then
			title_str = "材料副本{wordcolor;ff0000;(可接)}"
			desc_str = "点击前往材料副本"
		else
			title_str = "材料副本{wordcolor;00ff00;(已完成)}"
			desc_str = "点击前往材料副本"
		end

		RichTextUtil.ParseRichText(self.rich_title, title_str, 20, COLOR3B.ORANGE)
		RichTextUtil.ParseRichText(self.rich_desc, desc_str, 20,  COLOR3B.WHITE)

	elseif self.data.task_type == TASK_GUIDE_TYPE.MULTIPLAYER then
		local bool = FubenMutilData.GetDrfbRemindIndex() > 0

		if bool then
			title_str = "多人副本{wordcolor;ff0000;(可接)}"
			desc_str = "点击前往多人副本"
		else
			title_str = "多人副本{wordcolor;00ff00;(已完成)}"
			desc_str = "点击前往多人副本"
		end

		RichTextUtil.ParseRichText(self.rich_title, title_str, 20, COLOR3B.ORANGE)
		RichTextUtil.ParseRichText(self.rich_desc, desc_str, 20,  COLOR3B.WHITE)
	elseif self.data.task_type == TASK_GUIDE_TYPE.BOOMERANG then
		local left_times = EscortData.Instance:GetEscortLeftTimes()
		if left_times > 0 then
			title_str = "护送镖车{wordcolor;ff0000;(可接)}"
			desc_str = "点击前往押镖"
		else
			title_str = "护送镖车{wordcolor;00ff00;(已完成)}"
			desc_str = "点击前往押镖"
		end

		RichTextUtil.ParseRichText(self.rich_title, title_str, 20, COLOR3B.ORANGE)
		RichTextUtil.ParseRichText(self.rich_desc, desc_str, 20,  COLOR3B.WHITE)
	elseif self.data.task_type == TASK_GUIDE_TYPE.DIGORE then
		local data = ExperimentData.Instance:GetBaseInfo()
		local max_time1 = MiningActConfig.initTimes
		local max_time2 = MiningActConfig.torob.daytimes
		local cur_time1 = max_time1 - (data.dig_num or 0)
		local cur_time2 = max_time2 - (data.plunder_num or 0)
		if cur_time1 > 0 or cur_time2 > 0 then
			title_str = "每日挖矿{wordcolor;ff0000;(可接)}"
			desc_str = "打开练功房面板"
		else
			title_str = "每日挖矿{wordcolor;00ff00;(已完成)}"
			desc_str = "打开练功房面板"
		end

		RichTextUtil.ParseRichText(self.rich_title, title_str, 20, COLOR3B.ORANGE)
		RichTextUtil.ParseRichText(self.rich_desc, desc_str, 20,  COLOR3B.WHITE)

	elseif self.data.task_type == TASK_GUIDE_TYPE.TIANSHU then
		local num = TaskData.Instance:GetRemianNum()
		if num > 0 then
			title_str = "天书任务{wordcolor;ff0000;(可接)}"
			desc_str = "点击前往接受"
		else
			title_str = "天书任务{wordcolor;00ff00;(已完成)}"
			desc_str = "点击前往接受"
		end

		RichTextUtil.ParseRichText(self.rich_title, title_str, 20, COLOR3B.ORANGE)
		RichTextUtil.ParseRichText(self.rich_desc, desc_str, 20,  COLOR3B.WHITE)
	elseif self.data.task_type == TASK_GUIDE_TYPE.DAILY then
		local rew_index = ShenDingData.Instance:GetIsRewIndex()
		local bool = false
		for i,v in ipairs(rew_index) do
			if v.state == 0 then
				bool = true
				break
			end
		end

		if bool then
			title_str = "日常活跃{wordcolor;ff0000;(可接)}"
			desc_str = "打开日常活跃面板"
		else
			title_str = "日常活跃{wordcolor;00ff00;(已完成)}"
			desc_str = "打开日常活跃面板"
		end

		RichTextUtil.ParseRichText(self.rich_title, title_str, 20, COLOR3B.ORANGE)
		RichTextUtil.ParseRichText(self.rich_desc, desc_str, 20,  COLOR3B.WHITE)
	elseif self.data.task_type == TASK_GUIDE_TYPE.ZSTASK then
		local big_index = ZsTaskData.Instance:GetBigTaskIndex() 		-- 当前处于什么任务
		local small_num = ZsTaskData.Instance:GetSmallTaskNum() 		-- 完成进度的任务数量

		local all_num = #TaskGoodGiftConfig.task[big_index].list 		-- 总共任务数量

		local title_str = Language.DailyTasks.TaskDesc[big_index]
		local desc_str = string.format(Language.DailyTasks.CompleteNum, small_num, all_num)

		RichTextUtil.ParseRichText(self.rich_title, title_str, 20, COLOR3B.ORANGE)
		RichTextUtil.ParseRichText(self.rich_desc, desc_str, 20,  COLOR3B.WHITE)
	else
		RichTextUtil.ParseRichText(self.rich_title, self.data.title_str, 20, COLOR3B.ORANGE)
		RichTextUtil.ParseRichText(self.rich_desc, self.data.desc_str, 20,  COLOR3B.WHITE)
	end
end

function MainuiSmallPartsItemReander:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("img9_285"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.select_effect, 999)
end

------------------------------------------------------------------------
-- 队伍Reander
MainuiTeamItemReander = MainuiTeamItemReander or BaseClass(BaseRender)
function MainuiTeamItemReander:__init()
	self.view:setContentWH(250, RenderWidth)
	
	self.img_icon = nil
	self.text_name = nil
end

function MainuiTeamItemReander:__delete()
	AvatarManager.Instance:CancelUpdateAvatar(self.img_head)
end

function MainuiTeamItemReander:CreateChild()
	BaseRender.CreateChild(self)
	
	self:AddClickEventListener(nil, true)
	
	local img_line = XUI.CreateImageView(TaskGuideSize.width / 2, 1, ResPath.GetMainui("task_line"), true)
	self.view:addChild(img_line, - 1)
	
	-- self.member_bg = XUI.CreateImageView(150, 44, ResPath.GetMainui("team_bg"), true)
	-- self.view:addChild(self.member_bg)
	
	self.img_icon = XUI.CreateImageView(40, 40, ResPath.GetMainui("team_head_bg"), true)
	self.view:addChild(self.img_icon)
	
	self.img_head = XUI.CreateImageView(38, 50, "", true)
	-- self.img_head:setScale(0.6)
	self.view:addChild(self.img_head)
	
	self.text_member_post = XUI.CreateText(115, 66, 80, 20, cc.TEXT_ALIGNMENT_LEFT, "", nil, 20)
	self.view:addChild(self.text_member_post)
	
	self.text_name = XUI.CreateText(80, 40, TaskGuideSize.width - 60, 20, cc.TEXT_ALIGNMENT_LEFT, "")
	self.text_name:setAnchorPoint(0, 0.5)
	self.view:addChild(self.text_name)
end

function MainuiTeamItemReander:OnFlush()
	if "create" == self.data.reander_type then
		self:SetStyle(false, ResPath.GetMainui("team_add"), Language.Team.Create)
	elseif "invite" == self.data.reander_type then
		self:SetStyle(false, ResPath.GetMainui("team_add"), Language.Team.Invite)
	elseif "role" == self.data.reander_type then
		local info = self.data.info
		self:SetStyle(true, ResPath.GetMainui("team_head_bg"), info.name)
		if self.index == 1 then
			self.text_member_post:setString(Language.Team.Leader)
		else
			self.text_member_post:setString(Language.Team.Member)
		end
		AvatarManager.Instance:UpdateAvatarImg(self.img_head, info.role_id, info.prof, false, false, info.sex)
	end
end

function MainuiTeamItemReander:SetStyle(is_visible, path, name)
	-- self.member_bg:setVisible(is_visible)
	self.text_member_post:setVisible(is_visible)
	self.img_head:setVisible(is_visible)
	self.img_icon:loadTexture(path)
	self.text_name:setString(name)
end

function MainuiTeamItemReander:OnClick()
	if "create" == self.data.reander_type then
		TeamCtrl:SendCreateTeamReq()
		ViewManager.Instance:OpenViewByDef(ViewDef.Team.MyTeam)
	elseif "invite" == self.data.reander_type then
		ViewManager.Instance:OpenViewByDef(ViewDef.Team.MyGoodFriend)
	else
		ViewManager.Instance:OpenViewByDef(ViewDef.Team.MyTeam)
	end
end

function MainuiTeamItemReander:CreateSelectEffect()
	
end
