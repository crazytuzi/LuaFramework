--------------------------------------------------------
-- 日常活动-行会boss  配置 
--------------------------------------------------------

ActGuildBossView = ActGuildBossView or BaseClass(BaseView)

function ActGuildBossView:__init()
	self.config_tab = {
		{"daily_activity_ui_cfg", 9, {0}},
	}
end

function ActGuildBossView:__delete()
end

--释放回调
function ActGuildBossView:ReleaseCallBack()

end

--加载回调
function ActGuildBossView:LoadCallBack(index, loaded_times)
	local right_top = MainuiCtrl.Instance:GetView():GetPartLayout(MainuiView.LAYOUT_PART.CENTER_TOP)
	local w, h = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()

----------更换父节点----------
	local node = self.real_root_node
	node:retain()
	node:removeFromParent()
	node:setParent(nil)
	right_top:TextLayout():addChild(node)
	node:release()
	node:setEnabled(false)
-------------end--------------

	local size = self.node_t_list["layout_guildi_boss"].node:getContentSize()
	local x, y
	x = w / 2 - size.width / 2 + 295
	y = h - 105
	self.root_node:setPosition(x, y)
	self.root_node:setAnchorPoint(0, 0)

	EventProxy.New(ActivityData.Instance, self):AddEventListener(ActivityData.RANKING_DATA_CHANGE, BindTool.Bind(self.OnRankingDataChange, self))
end

function ActGuildBossView:OpenCallBack()
end

function ActGuildBossView:CloseCallBack(is_all)
	if nil ~= self.timer then
		GlobalTimerQuest:CancelQuest(self.timer) -- 取消计时器任务
		self.timer = nil
	end
end

--显示指数回调
function ActGuildBossView:ShowIndexCallBack(index)
	self:FlushView()
	self.scene_change = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.OnSceneChangeComplete, self))

end

----------视图函数----------
function ActGuildBossView:FlushView()
	self:CheckTimer()

	local boss_order = ActivityData.Instance:GetActBossOrder()
	local text = string.format(Language.Activity.BossOrder, Language.Common.ChineseNum[boss_order])
	self.node_t_list["lbl_order"].node:setString(text)
end


function ActGuildBossView:CheckTimer() --检查计时器任务
	local data = ActivityData.Instance:GetActLeftTime()
	local time, now_time
	local left_time = 0
	if data then
		time = data.act_left_time
		now_time = data.set_act_left_time
		left_time = math.max((time + now_time - Status.NowTime), 0)
	end
	if left_time > 0 then
		self.node_t_list["lbl_time"].node:setString(TimeUtil.FormatSecond2Str(left_time)) -- 刷新剩余时间
		if nil == self.timer then
			self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.SecTime, self), 1)
		end
	else
		GlobalTimerQuest:CancelQuest(self.timer) -- 取消计时器任务
		self.timer = nil
	end
end

function ActGuildBossView:SecTime() --倒计时每秒回调
	if (not self:IsOpen()) then
		GlobalTimerQuest:CancelQuest(self.timer) -- 取消计时器任务
		self.timer = nil
		return
	end
	local data = ActivityData.Instance:GetActLeftTime()
	local left_time = 0
	if data then
		time = data.act_left_time
		now_time = data.set_act_left_time
		left_time = math.max((time + now_time - Status.NowTime), 0)
	end

	self.node_t_list["lbl_time"].node:setString(TimeUtil.FormatSecond2Str(left_time)) -- 刷新剩余时间
	if left_time <= 0 then
		self:CheckTimer()
	end
end

----------end----------

function ActGuildBossView:OnRankingDataChange()
	self:FlushView()
end

function ActGuildBossView:OnSceneChangeComplete()
	if nil ~= self.scene_change then
		GlobalEventSystem:UnBind(self.scene_change)
		self.scene_change = nil
	end
	ViewManager.Instance:CloseViewByDef(ViewDef.ActGuildBoss)
end

--------------------
