-- 任务帮助
TaskHelpView = TaskHelpView or BaseClass(XuiBaseView)
TaskHelpView.Data = {
	{index = 1, view = ViewName.RefiningExp, remind = RemindName.RefiningExp},
	{index = 2, task_id = DailyTaskType.TYPE_XYCM, npc_id = 83},
	{index = 3, task_id = DailyTaskType.TYPE_FMTF, npc_id = 79},
	{index = 4, npc_id = 90},
	{index = 5, view = ViewName.ChargeFirst},
	{index = 6, view = ViewName.Explore},
}
function TaskHelpView:__init()
	self.texture_path_list[1] = 'res/xui/consign.png'
	-- self:SetModal(true)
	self.zorder = -1
	self:SetIsAnyClickClose(true)
end

function TaskHelpView:__delete()
end

function TaskHelpView:ReleaseCallBack()
	if self.task_help_list then
		self.task_help_list:DeleteMe()
		self.task_help_list = nil
	end
end

function TaskHelpView:LoadCallBack()
	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()
	self.root_node:setPosition(300, screen_h / 2)

	-- 引导列表背景
	local bg_w = 180
	local bg_h = 150
	self.layout_list = XUI.CreateLayout(0, 0, bg_w, bg_h)
	self.layout_list:setAnchorPoint(0, 0)

	self.task_help_list_bg = XUI.CreateImageViewScale9(bg_w * 0.5, bg_h * 0.5, bg_w, bg_h, ResPath.GetCommon("img9_121"), true)
	self.layout_list:addChild(self.task_help_list_bg, 1)

	-- 引导列表
	self.task_help_list = ListView.New()
	self.task_help_list:Create(bg_w * 0.5, bg_h * 0.5, bg_w, bg_h - 8, ScrollDir.Vertical, TaskHelpRender)
	self.task_help_list:SetMargin(5)
	self.task_help_list:SetItemsInterval(10)
	self.layout_list:addChild(self.task_help_list:GetView(), 10)

	-- 界面标题背景
	self.layout_title = XUI.CreateLayout(0, bg_h, bg_w, 44)
	self.layout_title:setAnchorPoint(0, 0)

	self.title_bg = XUI.CreateImageViewScale9(bg_w * 0.5, 44 * 0.5, bg_w, 44, ResPath.GetCommon("img9_121"), true)
	self.layout_title:addChild(self.title_bg, 1)

	-- 界面标题
	self.title_text = XUI.CreateText(0, 44 * 0.5, bg_w, 28, cc.TEXT_ALIGNMENT_CENTER, Language.Task.TaskHelpTitle, nil, 21, COLOR3B.OLIVE)
	self.title_text:setAnchorPoint(0, 0.5)
	self.layout_title:addChild(self.title_text, 10)

	self.root_node:addChild(self.layout_list, 1)
	self.root_node:addChild(self.layout_title, 1)

	self:Flush(0, "open")
end

function TaskHelpView:OnFlush(param_t, index)
	local now_time = Status.NowTime
	local task_help_list = {}

	for i,v in ipairs(TaskHelpView.Data) do
		if v.view then
			if ViewManager.Instance:CanShowUi(v.view) then
				if v.remind == nil or RemindManager.Instance:GetRemind(v.remind) > 0 then
					task_help_list[#task_help_list + 1] = v
				end
			end
		elseif v.task_id then
			if TaskData.Instance:GetTaskInfo(v.task_id) then
				local count_t = TaskData.Instance:GetTaskDoCount(v.task_id)
				if count_t == nil or (type(count_t) == "table" and count_t.now_count and count_t.max_count and count_t.now_count < count_t.max_count) then
					task_help_list[#task_help_list + 1] = v
				end
			end
		else
			task_help_list[#task_help_list + 1] = v
		end
	end
	self.task_help_list:SetDataList(task_help_list)
	if param_t["open"] then
		self.task_help_list:JumpToTop(true)
	end
end

function TaskHelpView:OpenCallBack()
	self:Flush(0, "open")
end

function TaskHelpView:CloseCallBack()

end
----------------------------------------------------
-- TaskHelpRender
----------------------------------------------------
TaskHelpRender = TaskHelpRender or BaseClass(BaseRender)
TaskHelpRender.Width = 168
TaskHelpRender.Height = 52
function TaskHelpRender:__init(x, y)
	self.view:setContentWH(TaskHelpRender.Width, TaskHelpRender.Height)
end

function TaskHelpRender:__delete()
end

function TaskHelpRender:CreateChild()
	BaseRender.CreateChild(self)

	self.btn_img = XUI.CreateImageView(TaskHelpRender.Width * 0.5, TaskHelpRender.Height * 0.5, ResPath.GetCommon("btn_103"), true)
	self.text = XUI.CreateText(0, 10, 168, 28, cc.TEXT_ALIGNMENT_CENTER, "", nil, 22, COLOR3B.G_W2)
	self.text:setAnchorPoint(0, 0)
	self.view:addChild(self.btn_img, 20)
	self.view:addChild(self.text, 21)
	self:AddClickEventListener(BindTool.Bind1(self.OnClickGuide, self), true)
end

function TaskHelpRender:CreateSelectEffect()
end
	
function TaskHelpRender:OnClickGuide()
	if self.data == nil then return end
	if self.data.view then
		ViewManager.Instance:Open(self.data.view)
	elseif self.data.npc_id then
		local id = ActiveDegreeData.Instance:GetNpcQuicklyTransportId(self.data.npc_id)
		if id then 
			Scene.SendQuicklyTransportReq(id)
		end
	end
	ViewManager.Instance:Close(ViewName.TaskHelp)
end

function TaskHelpRender:OnFlush()
	if self.data == nil then return end
	self.text:setString(Language.Task.TaskHelp[self.data.index] or "")
end
