--------------------------------------------------------
-- 任务  配置 
--------------------------------------------------------

TasksView = TasksView or BaseClass(BaseView)

function TasksView:__init()
	self.texture_path_list[1] = 'res/xui/daily_tasks.png'
	-- self:SetModal(true)
	self:SetIsAnyClickClose(true)
	self.config_tab = {
		{"common2_ui_cfg", 1, {0}},
		{"tasks_ui_cfg", 1, {0}},
		{"common2_ui_cfg", 2, {0}},
	}
	self.cfg = Language.Tasks.DailyCfg
end

function TasksView:__delete()
end

--释放回调
function TasksView:ReleaseCallBack()
	if self.tasks_list then
		self.tasks_list:DeleteMe()
		self.tasks_list = nil
	end
end

--加载回调
function TasksView:LoadCallBack(index, loaded_times)
	self:CreateTasksList()

	-- 数据监听
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.OnRoleAttrChange, self))
end

function TasksView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function TasksView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

--显示指数回调
function TasksView:ShowIndexCallBack(index)
	self:Flush()
end

function TasksView:OnFlush(param_list, index)
	self:SetTasksListData()
end
----------视图函数----------

function TasksView:CreateTasksList()
	local ph = self.ph_list.ph_tasks_type_list
	self.tasks_list = ListView.New()
	self.tasks_list:Create(ph.x, ph.y, ph.w, ph.h, direction, self.TasksItemRender, nil, false, self.ph_list.ph_tasks_item)
	self.tasks_list:SetItemsInterval(3)
	self.tasks_list:SetJumpDirection(ListView.Top)
	-- self.tasks_list:SetSelectCallBack(BindTool.Bind(self.SelectActivityTypeCallback, self))
	self.node_t_list["layout_tasks"].node:addChild(self.tasks_list:GetView(), 100)
end

function TasksView:SetTasksListData()
	self.tasks_list:SetDataList(self.cfg)
end
function TasksView:OnRoleAttrChange(vo)
	local key = vo.key
	if key == OBJ_ATTR.CREATURE_LEVEL then
		self:Flush()
	end
end

----------end----------

----------------------------------------
-- 任务配置
----------------------------------------
TasksView.TasksItemRender = BaseClass(BaseRender)
local TasksItemRender = TasksView.TasksItemRender

function TasksItemRender:__init()

end

function TasksItemRender:__delete()

end

function TasksItemRender:CreateChild()
	BaseRender.CreateChild(self)
	self.node_tree["btn_challenge"].remind_eff = RenderUnit.CreateEffect(23, self.node_tree["btn_challenge"].node, 1)
	self.node_tree["btn_challenge"].remind_eff:setVisible(false)
	XUI.AddClickEventListener(self.node_tree["btn_challenge"].node, BindTool.Bind(self.OnChallenge, self))
	local path
	path = ResPath.GetBigPainting("tasks_bg_" .. self.index, false)
	self.node_tree["img_tasks_bg"].node:loadTexture(path, false)
	path = ResPath.GetDailyTasks("tasks_type_" .. self.index)
	self.node_tree["img_tasks_type"].node:loadTexture(path)

	self.cfg = Language.Tasks.DailyCfg
	if nil ~= self.cfg then
		self.node_tree["lbl_reward_type"].node:setString(self.cfg[self.index].reward)
		self.node_tree["lbl_text_1"].node:setString(self.cfg[self.index].text_1)
		self.node_tree["lbl_text_2"].node:setString(self.cfg[self.index].text_2)
		self.node_tree["lbl_open_level"].node:setString(self.cfg[self.index].open_tip)
		XUI.EnableOutline(self.node_tree["lbl_open_level"].node)
	end
end

function TasksItemRender:OnFlush()
	if nil == self.data then return end

	self:FlushView()
end

function TasksItemRender:FlushView()
	if nil == self.cfg then return end

	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) -- 人物等级
	local vis, is_open, text, times_vis, btn_vis, btn_enabled, btn_eff_vis
	if self.index == 1 then -- 精英任务
		is_open = level >= GameCond.CondId60.RoleLevel
		vis = DailyTasksData.Instance.GetRemindIndex() > 0 and is_open
		local data = DailyTasksData.Instance:GetData()
		text = self.cfg[self.index].times .. data.times
		times_vis = is_open
		btn_vis = is_open
		btn_enabled = vis
		btn_eff_vis = vis
	elseif self.index == 2 then -- 未知暗殿
		is_open = level >= GameCond.CondId99.RoleLevel
		vis = UnknownDarkHouseData.Instance.GetRemindIndex() > 0 and is_open
		local data = UnknownDarkHouseData.Instance:GetData()
		local times = WeiZhiAnDianCfg.freeTimes - data.times
		text = self.cfg[self.index].times .. times
		times_vis = is_open and times > 0
		btn_vis = is_open
		btn_enabled = is_open
		btn_eff_vis = vis
	elseif self.index == 3 then -- 威望任务
		is_open = level >= GameCond.CondId100.RoleLevel
		vis = is_open--PrestigeTaskData.Instance.GetRemindIndex() > 0 and is_open
		local data = PrestigeTaskData.Instance:GetData()
		local times = 0--PrestigeSysConfig.dayMaxCount - data.times
		text = self.cfg[self.index].times .. times
		times_vis = is_open
		btn_vis = is_open
		btn_enabled = is_open
		btn_eff_vis = vis
	elseif self.index == 4 then -- 多人副本
		is_open = level >= GameCond.CondId102.RoleLevel
		local max_times = FubenMutilData.GetFubenMaxEnterTimes(FubenMutilType.Team)
		local used_times = FubenMutilData.Instance:GetFubenUsedTimes(FubenMutilType.Team)
		local times = max_times - used_times
		text = self.cfg[self.index].times .. times
		times_vis = is_open
		btn_vis = is_open
		btn_enabled = times ~= 0
		btn_eff_vis = times ~= 0
	elseif self.index == 5 then -- 行会禁地
		is_open = level >= GameCond.CondId101.RoleLevel
		local times = FubenData.Instance:GetLeftHhjdTimes()
		text = self.cfg[self.index].times .. times
		times_vis = is_open
		btn_vis = is_open
		btn_enabled = times ~= 0
		btn_eff_vis = times ~= 0
	end
	self.node_tree["lbl_times"].node:setString(text)
	self.node_tree["lbl_times"].node:setVisible(times_vis)
	self.node_tree["btn_challenge"].node:setVisible(btn_vis)
	self.node_tree["btn_challenge"].node:setEnabled(btn_enabled)
	self.node_tree["btn_challenge"].remind_eff:setVisible(btn_eff_vis)
	XUI.EnableOutline(self.node_tree["lbl_times"].node) -- 描边

	self.node_tree["img_tasks_bg"].node:setGrey(not is_open)
	self.node_tree["img_tasks_type"].node:setGrey(not is_open)

	local color1 = is_open and COLOR3B.GREEN or COLOR3B.OLIVE
	local color2 = is_open and COLOR3B.GOLD or COLOR3B.OLIVE
	self.node_tree["lbl_reward_type"].node:setColor(color1)
	self.node_tree["lbl_text_1"].node:setColor(color2)
	self.node_tree["lbl_text_2"].node:setColor(color2)
end

function TasksItemRender:OnChallenge()
	if self.index == 1 then
		ViewManager.Instance:OpenViewByDef(ViewDef.DailyTasks)
	elseif self.index == 2 then
		ViewManager.Instance:OpenViewByDef(ViewDef.UnknownDarkHouse)
	elseif self.index == 3 then
		ViewManager.Instance:OpenViewByDef(ViewDef.PrestigeTask)
	elseif self.index == 4 then
		ViewManager.Instance:OpenViewByDef(ViewDef.FubenMulti)
	elseif self.index == 5 then
		ViewManager.Instance:OpenViewByDef(ViewDef.HhjdTeam)
	end
end

function TasksItemRender:CreateSelectEffect()
	return
end

function TasksItemRender:OnClickBuyBtn()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function TasksItemRender:OnClick()
	if nil ~= self.click_callback then
		-- self.click_callback(self)
	end
end
