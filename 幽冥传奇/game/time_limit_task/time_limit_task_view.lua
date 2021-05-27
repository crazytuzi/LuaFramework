
-- 限时任务
TimeLimitTaskView = TimeLimitTaskView or BaseClass(BaseView)

local FuwenView = require("scripts/game/fuwen/view/fuwen_view")

function TimeLimitTaskView:__init()
	self.title_img_path = ResPath.GetWord("word_time_limit_task")
	self:SetModal(true)
	self.texture_path_list = {"res/xui/fuwen.png"}
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}, nil, 999},
		{"time_limit_task_ui_cfg", 1, {0}},
	}

	self.data = TimeLimitTaskData.Instance
	self.fuwen_list = {}
end

function TimeLimitTaskView:__delete()
	self.data = nil
end

function TimeLimitTaskView:ReleaseCallBack()
	if self.list_view then
		self.list_view:DeleteMe()
		self.list_view = nil
	end

	if self.task_prog then
		self.task_prog:DeleteMe()
		self.task_prog = nil
	end

	if self.cd then
		CountDown.Instance:RemoveCountDown(self.cd)
		self.cd = nil
	end

	for k, v in pairs(self.fuwen_list) do
		v:DeleteMe()
	end
	self.fuwen_list = {}
end

function TimeLimitTaskView:LoadCallBack(index, loaded_times)
	self:CreateEff()

	local ph_list = self.ph_list.ph_list
	self.list_view = ListView.New()
	self.list_view:Create(ph_list.x, ph_list.y, ph_list.w, ph_list.h, nil, TimeLimitTaskRender, nil, nil, self.ph_list.ph_item)
	self.node_t_list.layout_time_limit_task.node:addChild(self.list_view:GetView(), 100, 100)
	self.list_view:GetView():setAnchorPoint(0.5, 0.5)
	self.list_view:SetItemsInterval(8)
	self.list_view:SetJumpDirection(ListView.Top)
	self.list_view:SetDataList(self.data:GetTaskDataList())

	self.node_t_list.btn_see_fuwen.node:setTitleText("查看符文")
	self.node_t_list.btn_see_fuwen.node:setTitleFontName(COMMON_CONSTS.FONT)
	self.node_t_list.btn_see_fuwen.node:setTitleFontSize(22)
	self.node_t_list.btn_see_fuwen.node:setTitleColor(COLOR3B.G_W2)
	XUI.AddClickEventListener(self.node_t_list.btn_see_fuwen.node, function()
		self:GetViewManager():OpenViewByDef(ViewDef.Role.RoleInfoList.BiSha)
	end)

	XUI.RichTextSetCenter(self.node_t_list.rich_prog.node)
	XUI.RichTextSetCenter(self.node_t_list.rich_time.node)

	self.task_prog = ProgressBar.New()
	self.task_prog:SetView(self.node_t_list.prog9_1.node)

	self.cd = CountDown.Instance:AddCountDown(self.data:TaskLeftTime(), 1, BindTool.Bind(self.FlushLeftTime, self))

	self:CreateFuwen()

	EventProxy.New(self.data, self):AddEventListener(TimeLimitTaskData.LIMIT_TASK_DATA_CHG, BindTool.Bind(self.OnTimeLinitTaskChange, self))
end

function TimeLimitTaskView:OpenCallBack()
end

function TimeLimitTaskView:CloseCallBack(is_all)
end

function TimeLimitTaskView:ShowIndexCallBack(index)
	self:Flush()
end

function TimeLimitTaskView:OnFlush(param_t, index)
	for k, v in pairs(self.list_view:GetAllItems()) do
		v:Flush()
	end

	local ok_count = self.data:GetOkTaskCount()
	local prog_p = ok_count / TimeLimitTaskData.MAX_TASK_COUNT * 100
	local prog_txt = string.format("%d/%d", ok_count, TimeLimitTaskData.MAX_TASK_COUNT)
	RichTextUtil.ParseRichText(self.node_t_list.rich_prog.node, prog_txt, 20, COLOR3B.OLIVE)
	self.task_prog:SetPercent(prog_p)

	-- 领取过符文后,屏蔽特效
	self.eff:setVisible(ok_count == 0)

	self:FlushLeftTime()
	self:FlushFuwen()

	RichTextUtil.ParseRichText(self.node_t_list.rich_reward_desc.node, OpenServerLimitTimeTaskCfg.runeRewardTxt, 20, COLOR3B.OLIVE)
	self.node_t_list.rich_reward_desc.node:setVerticalSpace(-4) --设置垂直间隔
end

function TimeLimitTaskView:CreateEff()
	local path, name = ResPath.GetEffectUiAnimPath(20)
	self.eff = AnimateSprite:create(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	local size = self.node_t_list.layout_fuwen_grid.node:getContentSize()
	local x, y = size.width / 2, size.height / 2
	self.eff:setPosition(x, y)
	self.node_t_list["layout_fuwen_grid"].node:addChild(self.eff, 50)
end

----------------------------------------------------------------------------------
function TimeLimitTaskView:FlushLeftTime()
	local left_time = self.data:TaskLeftTime()
	if left_time > 0 then
		local time_str = string.format("任务剩余时间:{color;1eff00;%s}", TimeUtil.FormatSecond(left_time))
		RichTextUtil.ParseRichText(self.node_t_list.rich_time.node, time_str, 20, COLOR3B.OLIVE)
	end
end

function TimeLimitTaskView:CreateFuwen(task_type)
	self.node_t_list.layout_fuwen_grid.node:setTouchEnabled(true)
	self.node_t_list.layout_fuwen_grid.node:addTouchEventListener(BindTool.Bind(self.OnTouchFuwenGrid, self))
	self.node_t_list.layout_fuwen_grid.node:setScale(0.90)
	self.node_t_list.img_fuwen_diamond.node:setScale(0.90)

	self.fuwen_list = {}
	local size = self.node_t_list.layout_fuwen_grid.node:getContentSize()
	local c_x, c_y = size.width / 2, size.height / 2
	local r = 80

	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(20)
    self.fuwen_suit_eff = AnimateSprite:create(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
    self.fuwen_suit_eff:setPosition(size.width / 2 + 2, size.height / 2 + 1)
    self.node_t_list.layout_fuwen_grid.node:addChild(self.fuwen_suit_eff, 10)
    self.fuwen_suit_eff:setVisible(false)

	for i = 1, FuwenData.RUNE_PARTS do
		local fuwen = TimeLimitTaskFuwenRender.New(i, self.ph_list.ph_fuwen_render, self.node_t_list.layout_fuwen_grid.node, self)
		fuwen:SetPosition(c_x, c_y)
		self.fuwen_list[i] = fuwen
	end
end

function TimeLimitTaskView:FlushFuwen()
	for k, v in pairs(self.fuwen_list) do
		v:Flush()
	end
end

function TimeLimitTaskView:OnTouchFuwenGrid(sender, event_type, touch)
	if event_type == XuiTouchEventType.Began then
		local location = sender:convertToNodeSpace(touch:getLocation())
		for k, v in pairs(TimeLimitTaskFuwenRender.FUWEN_POS) do
			if GameMath.IsInPolygon(v.points, location) then
				local fuwen_data = self.data:GetFuwenData(k)
				if nil ~= fuwen_data then
					TipCtrl.Instance:OpenItem(fuwen_data)
				end
				return
			end
		end
	end
end

function TimeLimitTaskView:OnTimeLinitTaskChange(task_type)
	self:Flush()
end

----------------------------------------------------------------------------------
TimeLimitTaskRender = TimeLimitTaskRender or BaseClass(BaseRender)
function TimeLimitTaskRender:__init()
end

function TimeLimitTaskRender:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function TimeLimitTaskRender:CreateChildCallBack()
	self.cell = BaseCell.New()
	self.cell:SetPosition(self.ph_list.ph_cell.x, self.ph_list.ph_cell.y)
	self.cell:SetAnchorPoint(0.5, 0.5)
	self.cell:SetIsShowTips(true)
	self.view:addChild(self.cell:GetView(), 10)

	self.node_tree.btn_1.node:setTitleText("")
	self.node_tree.btn_1.node:setTitleFontName(COMMON_CONSTS.FONT)
	self.node_tree.btn_1.node:setTitleFontSize(22)
	self.node_tree.btn_1.node:setTitleColor(COLOR3B.G_W2)
	-- self.node_t_list.btn_chuanshi.remind_eff = RenderUnit.CreateEffect(23, self.node_tree.btn_1.node, 1)
	XUI.AddClickEventListener(self.node_tree.btn_1.node, BindTool.Bind(self.OnClickBtn, self))
end

function TimeLimitTaskRender:OnFlush()
	local task_data = TimeLimitTaskData.Instance:GetTaskData(self.data.task_type)
	if nil == task_data then
		return
	end

	self.cell:SetData(ItemData.FormatItemData(self.data.cfg.award[1]))

	local task_desc = self.data.cfg.taskDesc or ""
	local task_state, btn_txt = TimeLimitTaskData.Instance:TaskState(self.data.task_type)
	local is_ok = task_state ~= TimeLimitTaskData.TASK_STATE.NOT_OK
	local task_state_str = string.format("{wordcolor;%s;(%d/%d)}", is_ok and COLORSTR.GREEN or COLORSTR.RED, task_data.done_times, self.data.cfg.limitTimes)

	RichTextUtil.ParseRichText(self.node_tree.rich_1.node, task_desc, 20, COLOR3B.OLIVE)
	RichTextUtil.ParseRichText(self.node_tree.rich_2.node, task_state_str, 20, COLOR3B.OLIVE)
	self.node_tree.btn_1.node:setTitleText(btn_txt)

	local is_ok_and_rec = task_state == TimeLimitTaskData.TASK_STATE.OK_AND_REC
	self.node_tree.btn_1.node:setVisible(not is_ok_and_rec)

	if is_ok_and_rec and nil == self.img_rec_stamp then
		local x, y = self.node_tree.btn_1.node:getPosition()
		self.img_rec_stamp = XUI.CreateImageView(x, y, ResPath.GetCommon("stamp_1"))
		self.img_rec_stamp:setScale(0.8)
		self.view:addChild(self.img_rec_stamp, 99)
	elseif nil ~= self.img_rec_stamp then
		self.img_rec_stamp:setVisible(is_ok_and_rec)
	end

	-- 刷新按钮红点提示
	self:SetRemind(self.node_tree.btn_1.node, is_ok)
end

-- 设置提醒
function TimeLimitTaskRender:SetRemind(node, vis, path, x, y)
	path = path or ResPath.GetMainui("remind_flag")
	local size = node:getContentSize()
	x = x or size.width - 15
	y = y or size.height - 17
	if vis and nil == self.remind_bg_sprite then
		self.remind_bg_sprite = XUI.CreateImageView(x, y, path, true)
		node:addChild(self.remind_bg_sprite, 1, 1)
	elseif self.remind_bg_sprite then
		self.remind_bg_sprite:setVisible(vis)
	end
end

function TimeLimitTaskRender:CreateSelectEffect()
end

function TimeLimitTaskRender:OnClickBtn()
	local task_state = TimeLimitTaskData.Instance:TaskState(self.data.task_type)
	if task_state == TimeLimitTaskData.TASK_STATE.OK then
		TimeLimitTaskCtrl.SendRecTimeLimitTaskReward(self.data.task_type)
	elseif task_state == TimeLimitTaskData.TASK_STATE.NOT_OK then
		local param = self.data.cfg.btnClickParam
		if param then
			if param.viewLink then
				ViewManager.Instance:OpenViewByStr(param.viewLink)
			elseif param.moveto then
				MoveCache.end_type = MoveEndType.Normal
				GuajiCtrl.Instance:FlyByIndex(param.moveto)
				ViewManager.Instance:CloseAllView()
			end
		end
	end
end

----------------------------------------------------------------------------------
TimeLimitTaskFuwenRender = TimeLimitTaskFuwenRender or BaseClass(FuwenView.FuwenRender)
function TimeLimitTaskFuwenRender:OnFlush()
	local data = TimeLimitTaskData.Instance:GetFuwenData(self:FuwenIndex())
	if data then
		local boss_index, fuwen_index = ItemData.GetItemFuwenIndex(data.item_id)
		self.node_tree.img_fuwen.node:loadTexture(ResPath.GetFuwen(string.format("boss_%d_%d", boss_index, self:FuwenIndex())))
	end

	self.node_tree.img_fuwen.node:setVisible(nil ~= data)
	self.remind_img:setVisible(false)
end
