--------------------------------------------------------
-- 日常活动-世界boss  配置 
--------------------------------------------------------

ActWorldBossView = ActWorldBossView or BaseClass(BaseView)

function ActWorldBossView:__init()
	self.config_tab = {
		{"daily_activity_ui_cfg", 10, {0}},
	}
end

function ActWorldBossView:__delete()
end

--释放回调
function ActWorldBossView:ReleaseCallBack()

end

--加载回调
function ActWorldBossView:LoadCallBack(index, loaded_times)
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

	local size = self.node_t_list["layout_zhen_ying"].node:getContentSize()
	self.root_node:setPosition(w / 2 - size.width / 2 + 295, h - 55)
	self.root_node:setAnchorPoint(0, 0)
end

function ActWorldBossView:OpenCallBack()
end

function ActWorldBossView:CloseCallBack(is_all)
	if nil ~= self.timer then
		GlobalTimerQuest:CancelQuest(self.timer) -- 取消计时器任务
		self.timer = nil
	end
end

--显示指数回调
function ActWorldBossView:ShowIndexCallBack(index)
	self:FlushView()
	self.scene_change = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.OnSceneChangeComplete, self))
end

----------视图函数----------
function ActWorldBossView:FlushView()
	self:CheckTimer()
end


function ActWorldBossView:CheckTimer() --检查计时器任务
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

function ActWorldBossView:SecTime() --倒计时每秒回调
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

function ActWorldBossView:OnRankingDataChange()
	self:FlushView()
end

function ActWorldBossView:OnSceneChangeComplete()
	if nil ~= self.scene_change then
		GlobalEventSystem:UnBind(self.scene_change)
		self.scene_change = nil
	end
	ViewManager.Instance:CloseViewByDef(ViewDef.ActWorldBoss)
end

--------------------
