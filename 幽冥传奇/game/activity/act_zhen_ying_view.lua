--------------------------------------------------------
-- 日常活动-阵营战  配置 
--------------------------------------------------------

ActZhenYingView = ActZhenYingView or BaseClass(BaseView)

function ActZhenYingView:__init()
	self.config_tab = {
		{"daily_activity_ui_cfg", 10, {0}},
	}
end

function ActZhenYingView:__delete()
end

--释放回调
function ActZhenYingView:ReleaseCallBack()

end

--加载回调
function ActZhenYingView:LoadCallBack(index, loaded_times)
	local right_top = MainuiCtrl.Instance:GetView():GetPartLayout(MainuiView.LAYOUT_PART.BOTTOM_CENTER)
	local w, h = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()

----------更换父节点----------
	local node = self.real_root_node
	node:retain()
	node:removeFromParent()
	node:setParent(nil)
	right_top:TextLayout():addChild(node)
	node:release()
-------------end--------------

	local size = self.node_t_list["layout_zhen_ying"].node:getContentSize()
	self.root_node:setPosition(w / 2 - size.width / 2, 40)
	self.root_node:setAnchorPoint(0, 0)
end

function ActZhenYingView:OpenCallBack()
end

function ActZhenYingView:CloseCallBack(is_all)
	if nil ~= self.timer then
		GlobalTimerQuest:CancelQuest(self.timer) -- 取消计时器任务
		self.timer = nil
	end
end

--显示指数回调
function ActZhenYingView:ShowIndexCallBack(index)
	self:FlushView()
	self.scene_change = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.OnSceneChangeComplete, self))
end

----------视图函数----------
function ActZhenYingView:FlushView()
	self:CheckTimer()
end


function ActZhenYingView:CheckTimer() --检查计时器任务
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

function ActZhenYingView:SecTime() --倒计时每秒回调
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

function ActZhenYingView:OnRankingDataChange()
	self:FlushView()
end

function ActZhenYingView:OnSceneChangeComplete()
	local boor = false
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local scene_id = main_role_vo.scene_id
	if StdActivityCfg[DAILY_ACTIVITY_TYPE.ZHEN_YING].sceneId == scene_id then return end

	if nil ~= self.scene_change then
		GlobalEventSystem:UnBind(self.scene_change)
		self.scene_change = nil
	end
	ViewManager.Instance:CloseViewByDef(ViewDef.ActZhenYing)
end

--------------------
