FuBenVictoryFinishView = FuBenVictoryFinishView or BaseClass(BaseView)

function FuBenVictoryFinishView:__init()
	self.ui_config = {"uis/views/fubenview", "VictoryFinishView"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self:SetMaskBg(true)
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].Shengli) or 0
	end
	self.leave_time = 0
end

function FuBenVictoryFinishView:LoadCallBack()
	self:ListenEvent("Close",
		BindTool.Bind(self.OnClickClose, self))

	self.victory_items = {}
	for i = 1, 6 do
		local item_obj = self:FindObj("VItem"..i)
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(item_obj)
		self.victory_items[i] = {item_obj = item_obj, item_cell = item_cell}
		self.victory_items[i].item_obj:SetActive(false)
	end
	self.victory_text = {}

	self.victory_text = self:FindVariable("VictoryText_" .. 1)
	self.enter_text = self:FindVariable("EnterBtnzText")

	local item_obj = self:FindObj("ExpItem"..1)
	local item_cell = ItemCell.New()
	item_cell:SetInstanceParent(item_obj)
	self.exp_items = {item_obj = item_obj, item_cell = item_cell}

	self.str_tip = self:FindVariable("StrTip")
	self.is_show_tip = self:FindVariable("IsShowTip")
	self.show_reward_text = self:FindVariable("ShowRewardText")
end

function FuBenVictoryFinishView:OpenCallBack()
	self.enter_text:SetValue(Language.Common.Confirm)
	self:Flush("finish")
end

function FuBenVictoryFinishView:ReleaseCallBack()
	for k,v in pairs(self.victory_items) do
		if v.item_cell then
			v.item_cell:DeleteMe()
		end
	end
	if self.exp_items.item_cell then
		self.exp_items.item_cell:DeleteMe()
	end
	self.victory_items = {}
	self.victory_text = nil
	self.enter_text = nil

	self.str_tip = nil
	self.is_show_tip = nil
	self.show_reward_text = nil
end

function FuBenVictoryFinishView:SetCloseCallBack(callback)
	self.close_callback = callback
end

function FuBenVictoryFinishView:CloseCallBack()
	if self.close_callback then
		self.close_callback()
		self.close_callback = nil
	end
	self.leave_time = 0
	if self.leave_timer then
		GlobalTimerQuest:CancelQuest(self.leave_timer)
		self.leave_timer = nil
	end
end

function FuBenVictoryFinishView:OnClickClose()
	if Scene.Instance:GetSceneType() == SceneType.RuneTower then
		FuBenCtrl.Instance:SendEnterNextFBReq()
	else
		FuBenCtrl.Instance:SendExitFBReq()
	end
	self:Close()
end

function FuBenVictoryFinishView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "finish" then
			if v.data ~= nil then
				--self.data = v.data
				for i, j in pairs(self.victory_items) do
					if v.data[i] then
						j.item_cell:SetData(v.data[i])
						j.item_obj:SetActive(true)
						self.show_reward_text:SetValue(true)
					else
						j.item_obj:SetActive(false)
					end
				end
			end
			
			if self.leave_timer == nil then
				self.leave_time = 8 or v.leave_time
				self:LeaveUpdate()
				self.leave_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.LeaveUpdate, self), 1)
			end

			self.is_show_tip:SetValue(v.tip_str ~= nil)
			if v.tip_str then
				self.str_tip:SetValue(v.tip_str)
			end
		elseif k == "expfinish" then
			self.victory_text:SetValue(v.data[1])
			self.exp_items.item_cell:SetData(v.data[2])
			self.exp_items.item_obj:SetActive(true)

			self.is_show_tip:SetValue(v.tip_str ~= nil)
			if v.tip_str then
				self.str_tip:SetValue(v.tip_str)
			end
		end
	end
end

function FuBenVictoryFinishView:LeaveUpdate()
	if self.leave_time <= 0 then
		GlobalTimerQuest:CancelQuest(self.leave_timer)
		self.leave_timer = nil
		FuBenCtrl.Instance:SendExitFBReq()
		self:Close()
	else
		self.enter_text:SetValue(Language.Common.Confirm .. "(" .. self.leave_time .. ")")
		self.leave_time = self.leave_time - 1
	end
end