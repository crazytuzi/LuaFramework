GuildRollView = GuildRollView or BaseClass(BaseView)

local CellCount = 8          				-- 转盘上面的奖励格子数量

function GuildRollView:__init()
	self.ui_config =  {"uis/views/guildview", "GuildoRollView"}
	self.high_light = {}
	self.view_layer = UiLayer.Pop
	self.is_rolling = true
	self.is_send = false
	self.turn_complete = true
	self.active_close = false
end

function GuildRollView:LoadCallBack()
	self.wheel = self:FindObj("Wheel")
	self.time = self:FindVariable("Time")
	self.reward_cells = {}
	for i = 1, CellCount do
		self.reward_cells[i] = ItemCell.New(self:FindObj("Reward"..i))
	end

	self.button_start = self:FindObj("ButtonStart")
	self.play_ani_toggle = self:FindObj("PlayAniToggle").toggle

	self.show_highlight = {}
	for i=1,8 do
		self.show_highlight[i] = self:FindVariable("Show_HighLight"..i)
	end

	self:ListenEvent("OnClickStart", BindTool.Bind(self.OnClickStart, self))
	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickToggle", BindTool.Bind(self.OnClickToggle, self))

	if self.daily_roll_handle == nil then
		self.daily_roll_handle = GlobalEventSystem:Bind(OtherEventType.DAILY_ROOL_VIEW, BindTool.Bind(self.OnRollGetReward, self))
	end

	self:SetAutoTalkTime()
	
end

function GuildRollView:ShowIndexCallBack()
	if self.play_ani_toggle then
		self.play_ani_toggle.isOn = GuildData.Instance:ISPlayAni() or false
	end
end

function GuildRollView:ReleaseCallBack()
	if self.daily_roll_handle ~= nil then
		GlobalEventSystem:UnBind(self.daily_roll_handle)
		self.daily_roll_handle = nil
	end

	if self.timer_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end

	for k,v in pairs(self.reward_cells) do
		v:DeleteMe()
	end

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.reward_cells = {}

	-- 清理变量和对象
	self.wheel = nil
	self.time = nil
	self.show_highlight = nil
	self.button_start = nil
	self.play_ani_toggle = nil
end

function GuildRollView:OpenCallBack()
	self.is_rolling = true
	self:Flush()
end

function GuildRollView:OnClickClose()
	if self.is_send == false or self.is_rolling == false then
		if self.is_send == false then
			GuildData.Instance:SetGuildRollShowNow(true)
			GuildCtrl.Instance:SendRiChangTaskRollReq(COMMON_OPERATE_TYPE.COT_DAILY_TASK_DRAW)
			self.is_send = true
		end
		self:CloseRollView()
	end
end

function GuildRollView:CloseCallBack()
	if self.timer_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end

	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.is_send = false
	MainUICtrl.Instance:SetTaskAutoState(true)
end

function GuildRollView:__delete()
	self.is_rolling = nil 
	self.is_send = nil
	if self.daily_roll_handle then
		GlobalEventSystem:UnBind(self.daily_roll_handle)
		self.daily_roll_handle = nil
	end
end

function GuildRollView:OnClickToggle()
	if self.play_ani_toggle then
		GuildData.Instance:SetPlayAni(self.play_ani_toggle.isOn)
	end
end

-- 控制奖励栏的高亮
function GuildRollView:OpenHighLight(index)  -- index = 0  全灭
	for i = 1, CellCount do
		if index then
   			self.show_highlight[i]:SetValue(i == index)
		end
	end
end

function GuildRollView:CloseRollView()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.timer_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	self.root_node:SetActive(false)
	self.turn_complete = true

	self:CheckRichangeTask()
	self:Close()
end

-- 点击开始
function GuildRollView:OnClickStart()
	if self.play_ani_toggle.isOn and not self.is_send or not self.is_rolling then
		GuildData.Instance:SetGuildRollShowNow(true)
		GuildCtrl.Instance:SendRiChangTaskRollReq(COMMON_OPERATE_TYPE.COT_DAILY_TASK_DRAW)
		self.button_start:GetComponent(typeof(UnityEngine.UI.Image)).raycastTarget = false
		self.is_send = true
		self.is_rolling = false
		return
	end
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
		self.time:SetValue("")
	end
	-- if self.is_rolling or DaFuHaoData.Instance:GetDaFuHaoInfo().is_turn == 1 then
	-- 	return
	-- end
	self.turn_complete = false
	self.is_rolling = true
	GlobalEventSystem:Fire(OtherEventType.TURN_COMPLETE, false)
	local time = 0
	local tween = self.wheel.transform:DORotate(
		Vector3(0, 0, -360 * 20),
		20,
		DG.Tweening.RotateMode.FastBeyond360)
	tween:SetEase(DG.Tweening.Ease.OutQuart)
	tween:OnUpdate(function ()
		time = time + UnityEngine.Time.deltaTime
		if not self.is_send then
			GuildData.Instance:SetGuildRollShowNow(false)
			GuildCtrl.Instance:SendRiChangTaskRollReq(COMMON_OPERATE_TYPE.COT_DAILY_TASK_DRAW)
			self.button_start:GetComponent(typeof(UnityEngine.UI.Image)).raycastTarget = false
			self.is_send = true
		end
		if time >= 1.5 then
			if GuildData.Instance:GetRewardSeq() then
				tween:Pause()
				local angle = GuildData.Instance:GetRewardSeq() * -45
				local tween1 = self.wheel.transform:DORotate(
						Vector3(0, 0, -360 + angle),
						3,
						DG.Tweening.RotateMode.FastBeyond360)
				-- tween1:SetEase(DG.Tweening.Ease.OutQuart)
				tween1:OnComplete(function ()
					self.is_rolling = false
					self:OpenHighLight(GuildData.Instance:GetRewardSeq() + 1)
					self.timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.CloseRollView, self), 1.5)
					ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_DAILY_TASK_DRAW)
					GlobalEventSystem:Fire(OtherEventType.TURN_COMPLETE, GuildData.Instance:GetRewardSeq() == 0)
				end)
			end
		end
	end)
end

function GuildRollView:OnFlush()
	-- if not self.root_node.gameObject.activeSelf then return end
	for k, v in pairs(self.reward_cells) do
		if k == (GuildData.Instance:GetRiChangTaskRewardCfg()[k].seq + 1) and k >= 1 then
			v:SetData(GuildData.Instance:GetRiChangTaskRewardCfg()[k].reward_item)
		end
	end
end

function GuildRollView:GetIsTrunComplete()
	return self.turn_complete
end

-- 设置倒计时
function GuildRollView:SetAutoTalkTime()
	self.auto_talk = false
	self.time:SetValue(string.format(Language.Task.GuildTaskRollReward, ToColorStr(5, TEXT_COLOR.WHITE)))
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.count_down = CountDown.Instance:AddCountDown(5, 1, BindTool.Bind(self.CountDown, self))
end

-- 倒计时函数
function GuildRollView:CountDown(elapse_time, total_time)
	self.time:SetValue(string.format(Language.Task.GuildTaskRollReward, ToColorStr(math.ceil(total_time - elapse_time), TEXT_COLOR.WHITE)))
	if elapse_time >= total_time then
		self:OnClickStart()
		self.time:SetValue("")
		-- self:Close()
	end
	MainUICtrl.Instance:SetTaskAutoState(false) --防止继续跑任务
end

function GuildRollView:CheckRichangeTask()
	local richang_id = TaskData.Instance:GetRichangTaskId()
	if TASK_RI_AUTO and richang_id then
		TaskCtrl.Instance:DoTask(richang_id)
		TaskData.Instance:SetRichangTaskId(nil)
	end
end

function GuildRollView:OnRollGetReward()
	if self.play_ani_toggle.isOn and not self.is_rolling then
		local get_seq = GuildData.Instance:GetRewardSeq()
		local angle = get_seq * -45
		self.wheel.transform.localRotation = Quaternion.Euler(0, 0, angle)
		self:OpenHighLight(get_seq + 1)
		self.timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.CloseRollView, self), 1.5)
	end
end