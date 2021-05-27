----------------------------------------
-- 运营活动 49 普天同庆
----------------------------------------

ActPTTQView = ActPTTQView or BaseClass(ActBaseView)

function ActPTTQView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function ActPTTQView:__delete()
	if nil ~= self.cell_show_list then
		for k,v in pairs(self.cell_show_list) do
			v:DeleteMe()
			v = nil
		end
	end
	self.cell_show_list = {}

	if self.task_list then
		self.task_list:DeleteMe()
		self.task_list = nil
	end
end

function ActPTTQView:InitView()
	self:CreateTaskList()

	EventProxy.New(ShenDingData.Instance, self):AddEventListener(ShenDingData.TASK_DATA_CHANGE, BindTool.Bind(self.RefreshView, self))
end

function ActPTTQView:RefreshView(param_list)
	local task_data_list = ActivityBrilliantData.Instance:GetTaskDataList()
	self.task_list:SetDataList(task_data_list)
	self.task_list:JumpToTop()
end

function ActPTTQView:CreateTaskList()
	local ph = self.ph_list["ph_list"]
	local ph_item = self.ph_list["ph_item"] or {x = 0, y = 0, w = 10, h = 10}
	local parent = self.tree.node
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 2, ph_item.h + 1, self.TaskItemRender, ScrollDir.Vertical, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 99)
	self.task_list = grid_scroll
end

----------------------------------------
-- TaskItem渲染
----------------------------------------
local name_cfg = {
	[1] = "每日签到",
	[2] = "羽毛副本",
	[3] = "魂珠副本",
	[4] = "护盾副本",
	[5] = "宝石副本",
	[6] = "经验副本",
	[7] = "每日充值",
	[8] = "每日寻宝",
	[9] = "降妖除魔",
	[10] = "参与任意活动",
	[11] = "击杀敌人",
	[12] = "膜拜城主",
	[13] = "试练关卡",
	[14] = "护送镖车",
	[15] = "消灭专属boss",
	[16] = "使用屠魔令",
	[17] = "挖掘BOSS",
	[18] = "消灭运势boss",
	[19] = "回收装备",
	[20] = "投入蚩尤神石",
	[21] = "矿洞挖掘",
	[22] = "矿洞掠夺",
	[23] = "元宝祈福",
	[24] = "等级祈福",
}

local config = {
	[1] = {view = ViewDef.Welfare.DailyRignIn, cs_id = nil},
	[2] = {view = nil, cs_id = 48},
	[3] = {view = nil, cs_id = 48},
	[4] = {view = nil, cs_id = 48},
	[5] = {view = nil, cs_id = 48},
	[6] = {view = nil, cs_id = 48},
	[7] = {view = ViewDef.ZsVip.Recharge, cs_id = nil},
	[8] = {view = ViewDef.Explore.Xunbao, cs_id = nil},
	[9] = {view = nil, cs_id = 51},
	[10] = {view = ViewDef.Activity.Activity, cs_id = nil},
	[11] = {view = ViewDef.NewlyBossView.Wild, cs_id = nil},
	[12] = {view = nil, cs_id = 3},
	[13] = {view = ViewDef.ShiLian, cs_id = nil},
	[14] = {view = nil, cs_id = 20},
	[15] = {view = ViewDef.NewlyBossView.Wild.Specially, cs_id = nil},
	[16] = {view = ViewDef.NewlyBossView.Wild.CircleBoss, cs_id = nil},
	[17] = {view = ViewDef.NewlyBossView.Wild, cs_id = nil},
	[18] = {view = ViewDef.NewlyBossView.Rare.FortureBoss, cs_id = nil},
	[19] = {view = ViewDef.Recycle, cs_id = nil},
	[20] = {view = ViewDef.NewlyBossView.Rare.Chiyou, cs_id = nil},
	[21] = {view = ViewDef.Experiment.DigOre, cs_id = nil},
	[22] = {view = ViewDef.Experiment.DigOre, cs_id = nil},
	[23] = {view = ViewDef.Investment.Blessing, cs_id = nil},
	[24] = {view = ViewDef.Investment.Blessing, cs_id = nil},
}

ActPTTQView.TaskItemRender = BaseClass(BaseRender)
local TaskItemRender = ActPTTQView.TaskItemRender
function TaskItemRender:__init()
	
end

function TaskItemRender:__delete()
	if self.cell_list then
		self.cell_list:DeleteMe()
		self.cell_list = nil
	end
end

function TaskItemRender:CreateChild()
	BaseRender.CreateChild(self)

	local ph = self.ph_list["ph_award_list"]
	local list = ListView.New()
	list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, ActBaseCell, nil, nil, {w = BaseCell.SIZE, h = BaseCell.SIZE})
	list:SetItemsInterval(2)
	self.view:addChild(list:GetView(), 10)
	self.cell_list = list
	XUI.AddClickEventListener(self.node_tree["btn_leave_for"].node, BindTool.Bind(self.OnLeaveFor, self))
end

function TaskItemRender:OnFlush()
	if nil == self.data then return end

	local data_list = {}
	for k, v in pairs(self.data.cfg.awards or {}) do
		if type(v) == "table" then
			table.insert(data_list, ItemData.FormatItemData(v))
		end
	end
	self.cell_list:SetDataList(data_list)
	self.cell_list:SetJumpDirection(ListView.Left)

	local index = self.data.index
	local color = self.data.can_receive and COLORSTR.GREEN or COLORSTR.RED
	local name = self.data.cfg.name or name_cfg[index]
	local times = self.data.times or 0
	local times2 = self.data.times2 or 1
	local text = name .. string.format("{color;%s;(%d/%d)}", color, times, times2) -- 只能领取一次
	local rich = self.node_tree["rich_name"].node
	rich = RichTextUtil.ParseRichText(rich, text, 20, COLOR3B.GREEN)
	rich:refreshView()

	if self.data.sign == 1 then	
		self.node_tree["img_stamp"].node:setVisible(true)
		self.node_tree["btn_leave_for"].node:setVisible(false)
	else
		self.node_tree["img_stamp"].node:setVisible(false)
		
		local btn_title = self.data.can_receive and Language.Common.LingQu or Language.Common.GoTo
		self.node_tree["btn_leave_for"].node:setTitleText(btn_title)
		self.node_tree["btn_leave_for"].node:setVisible(true)
	end
end

function TaskItemRender:OnLeaveFor()
	if self.data.can_receive then
		local act_id = ACT_ID.PTTQ
		ActivityBrilliantCtrl.ActivityReq(4, act_id, self.data.index)
	else
		local cfg = config[self.data.index]
		if cfg.view == nil then
			GuajiCtrl.Instance:FlyByIndex(cfg.cs_id)
			ViewManager.Instance:CloseViewByDef(ViewDef.Activity)
		else
			ViewManager.Instance:OpenViewByDef(cfg.view)
		end
	end
end

function TaskItemRender:CreateSelectEffect()
	return
end