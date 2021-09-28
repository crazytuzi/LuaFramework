DaFuHaoRollView = DaFuHaoRollView or BaseClass(BaseView)

local CellCount = 8          				-- 转盘上面的奖励格子数量

function DaFuHaoRollView:__init()
	self.ui_config =  {"uis/views/dafuhaoview_prefab", "DaFuHaoRollView"}
	self.high_light = {}
	self.reward_cells = {}
	self.imageshow = {}
	self.view_layer = UiLayer.Pop
	self.is_rolling = false
	self.is_send = false
	self.turn_complete = true
	self.active_close = false
end

function DaFuHaoRollView:LoadCallBack()

	self.wheel = self:FindObj("Wheel")
	for i = 1, CellCount do
		self.reward_cells[i] = ItemCell.New(self:FindObj("Reward"..i))
	end

	for i = 1,CellCount do
		self.imageshow[i] = self:FindVariable("Image"..i)
	end

	self:ListenEvent("OnClickStart",
		BindTool.Bind(self.OnClickStart, self))
	self:ListenEvent("OnClickClose",
		BindTool.Bind(self.OnClickClose, self))
end

function DaFuHaoRollView:ReleaseCallBack()
	self:RemoveDelayTime()

	for k,v in pairs(self.reward_cells) do
		v:DeleteMe()
	end
	self.reward_cells = {}

	for k,v in pairs(self.imageshow) do
		v = nil
	end
	self.imageshow = {}

	-- 清理变量和对象
	self.wheel = nil
end

function DaFuHaoRollView:OpenCallBack()
	self.is_rolling = false
	self:Flush()
end

function DaFuHaoRollView:CloseCallBack()
	self:RemoveDelayTime()
	self.is_send = false
end

function DaFuHaoRollView:__delete()
	self.is_rolling = nil
	self.is_send = nil
end

-- 控制奖励栏的高亮
function DaFuHaoRollView:OpenHighLight(index)  -- index = 0  全灭
	for i = 1, CellCount do
		self.reward_cells[i]:ShowHighLight(i == index)
	end
end

function DaFuHaoRollView:CloseRollView()
	self:RemoveDelayTime()
	self.root_node:SetActive(false)
	self.turn_complete = true

	self:Close()
end

-- 点击开始
function DaFuHaoRollView:OnClickStart()
	if self.is_rolling or DaFuHaoData.Instance:GetDaFuHaoInfo().is_turn == 1 then
		return
	end

	local dafuhao_info = DaFuHaoData.Instance:GetDaFuHaoInfo() or {}
	local role_gather_max_time = DaFuHaoData.Instance:GetDaFuHaoOtherCfg().role_gather_max_time
	local gather_total_times = dafuhao_info.gather_total_times
	if nil == gather_total_times or gather_total_times < role_gather_max_time / 2 then
		SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.DaFuHaoGather)
		return
	end

	self.turn_complete = false
	self.is_rolling = true
	GlobalEventSystem:Fire(OtherEventType.TURN_COMPLETE, false)
	local time = 0
	local tween = self.wheel.transform:DORotate(Vector3(0, 0, -360 * 20),20,DG.Tweening.RotateMode.FastBeyond360)

	tween:SetEase(DG.Tweening.Ease.OutQuart)
	tween:OnUpdate(function ()
		time = time + UnityEngine.Time.deltaTime
		if not self.is_send then
			DaFuHaoCtrl.Instance:SendTurnTableOperaReq(GameEnum.TURNTABLE_OPERA_TYPE, 1)
			self.is_send = true
		end
		if time >= 2 then
			if DaFuHaoData.Instance:GetTurnTableRewardInfo().rewards_index then
				tween:Pause()
				local angle = DaFuHaoData.Instance:GetTurnTableRewardInfo().rewards_index * -45
				local tween1 = self.wheel.transform:DORotate(
						Vector3(0, 0, -360 * 3 + angle),
						3,
						DG.Tweening.RotateMode.FastBeyond360)
				tween1:OnComplete(function ()
					self.is_rolling = false
					self:OpenHighLight(DaFuHaoData.Instance:GetTurnTableRewardInfo().rewards_index + 1)
					self.imageshow[DaFuHaoData.Instance:GetTurnTableRewardInfo().rewards_index + 1]:SetValue(true)
					self:RemoveDelayTime()
					self.timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.CloseRollView, self), 3)
					ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_LUCKYROLL)
					GlobalEventSystem:Fire(OtherEventType.TURN_COMPLETE, DaFuHaoData.Instance:GetTurnTableRewardInfo().rewards_index == 0)
				end)
			end
		end
	end)
	tween:OnComplete(function ()
			self.is_rolling = false
			self:RemoveDelayTime()
			self.timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.CloseRollView, self), 3)
		end)
end

function DaFuHaoRollView:OnFlush()
	-- if not self.root_node.gameObject.activeSelf then return end
	for k, v in pairs(self.reward_cells) do
		if k == (DaFuHaoData.Instance:GetTurnTableCfg()[k].item_index + 1) and k > 1 then
			v:SetQualityState(2)
			v:SetData(DaFuHaoData.Instance:GetTurnTableCfg()[k].reward_item)
		end
	end
end

function DaFuHaoRollView:GetIsTrunComplete()
	return self.turn_complete
end

function DaFuHaoRollView:OnClickClose()
	self:Close()
end

function DaFuHaoRollView:RemoveDelayTime()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end