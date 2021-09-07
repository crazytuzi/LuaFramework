DaFuHaoRollView = DaFuHaoRollView or BaseClass(BaseView)

local CellCount = 8          				-- 转盘上面的奖励格子数量

function DaFuHaoRollView:__init()
	self:SetMaskBg()									-- 使用蒙板
	self.ui_config =  {"uis/views/dafuhaoview", "DaFuHaoRollView"}
	self.high_light = {}
	self.reward_cells = {}
	self.view_layer = UiLayer.Pop
	self.is_rolling = false
	self.is_send = false
	self.turn_complete = true
	self.active_close = false
end

function DaFuHaoRollView:LoadCallBack()
	self.wheel = self:FindObj("Wheel")
	for i = 1, CellCount do
		self.reward_cells[i] = ItemCell.New()
		self.reward_cells[i]:SetInstanceParent(self:FindObj("Reward" .. i))
	end

	self.show_highlight = {}
	for i=1,8 do
		self.show_highlight[i] = self:FindVariable("Show_HighLight"..i)
	end
	
	self:ListenEvent("OnClickStart",
		BindTool.Bind(self.OnClickStart, self))
end

function DaFuHaoRollView:ReleaseCallBack()
	if self.timer_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end

	for k,v in pairs(self.reward_cells) do
		v:DeleteMe()
	end
	self.reward_cells = {}

	-- 清理变量和对象
	self.wheel = nil
	self.show_highlight = {}
end

function DaFuHaoRollView:OpenCallBack()
	self.is_rolling = false
	self:Flush()
end

function DaFuHaoRollView:CloseCallBack()
	if self.timer_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	self.is_send = false
end

function DaFuHaoRollView:__delete()
	self.is_rolling = nil
	self.is_send = nil
end

-- 控制奖励栏的高亮
function DaFuHaoRollView:OpenHighLight(index)  -- index = 0  全灭
	for i = 1, CellCount do
		-- self.reward_cells[i]:ShowHighLight(i == index)
		self.show_highlight[i]:SetValue(i == index)
	end
end

function DaFuHaoRollView:CloseRollView()
	if self.timer_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	self.root_node:SetActive(false)
	self.turn_complete = true

	self:Close()
end

-- 点击开始
function DaFuHaoRollView:OnClickStart()
	if self.is_rolling or DaFuHaoData.Instance:GetDaFuHaoInfo().is_turn == 1 then
		return
	end
	self.turn_complete = false
	self.is_rolling = true
	GlobalEventSystem:Fire(OtherEventType.TURN_COMPLETE, false)
	local time = 0
	local tween = self.wheel.transform:DORotate(
		Vector3(0, 0, -366 * 20),
		20,
		DG.Tweening.RotateMode.FastBeyond360)
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
						Vector3(0, 0, -366 * 3 + angle),
						3,
						DG.Tweening.RotateMode.FastBeyond360)
				-- tween1:SetEase(DG.Tweening.Ease.OutQuart)
				tween1:OnComplete(function ()
					self.is_rolling = false
					self:OpenHighLight(DaFuHaoData.Instance:GetTurnTableRewardInfo().rewards_index + 1)
					self.timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.CloseRollView, self), 1.5)
					ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_LUCKYROLL)
					GlobalEventSystem:Fire(OtherEventType.TURN_COMPLETE, DaFuHaoData.Instance:GetTurnTableRewardInfo().rewards_index == 0)
				end)
			end
		end
	end)
	tween:OnComplete(function ()
		print_error("No Received Server Agreement :", DaFuHaoData.Instance:GetTurnTableRewardInfo().rewards_index)
			self.is_rolling = false
			self.timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.CloseRollView, self), 3)
		end)
end

function DaFuHaoRollView:OnFlush()
	local cfg = DaFuHaoData.Instance:GetTurnTableCfg()
	for i = 1, CellCount do
		if cfg[i] and cfg[i].reward_item then
			self.reward_cells[i]:SetData(cfg[i].reward_item)
		end
	end
end

function DaFuHaoRollView:GetIsTrunComplete()
	return self.turn_complete
end