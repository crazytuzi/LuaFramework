FuBenVictoryFinishView = FuBenVictoryFinishView or BaseClass(BaseView)

function FuBenVictoryFinishView:__init()
	self.ui_config = {"uis/views/fubenview_prefab", "VictoryFinishView"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
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
	end
	self.victory_text = {}

	self.victory_text = self:FindVariable("VictoryText_" .. 1)
	self.enter_text = self:FindVariable("EnterBtnzText")
	self.is_exp = self:FindVariable("IsExp")

	local item_obj = self:FindObj("ExpItem"..1)
	local item_cell = ItemCell.New()
	item_cell:SetInstanceParent(item_obj)
	self.exp_items = {item_obj = item_obj, item_cell = item_cell}

	self.show_win_text_panel = self:FindVariable("ShowWinTextPanel")
	self.show_win_img = self:FindVariable("ShowWinImg")
	self.win_text = {}
	self.show_text = {}
	for i=1, 2 do 
		self.show_text["show_text"..i] = self:FindVariable("ShowText"..i)
		self.win_text["win_text"..i] = self:FindVariable("WinText"..i)
	end


	
end

function FuBenVictoryFinishView:OpenCallBack()
	self.do_not_exit_fb = false
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
	self.is_exp = nil

	self.show_win_text_panel = nil
	self.show_win_img = nil
	self.win_text = nil
	self.show_text = nil
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
	self:RemoveRunQuest()
end

function FuBenVictoryFinishView:OnClickClose()
	if not self.do_not_exit_fb then
		if Scene.Instance:GetSceneType() == SceneType.RuneTower then
			FuBenCtrl.Instance:SendEnterNextFBReq()
		else
			FuBenCtrl.Instance:SendExitFBReq()
		end
	end
	self:Close()
end

function FuBenVictoryFinishView:RemoveRunQuest()
	if self.leave_timer then
		GlobalTimerQuest:CancelQuest(self.leave_timer)
		self.leave_timer = nil
	end
end

function FuBenVictoryFinishView:OnFlush(param_t)
	self.is_exp:SetValue(false)
	for k, v in pairs(param_t) do
		if k == "finish" or k == "reward" then
			if v.data ~= nil then
				-- self.data = v.data
				for i, j in pairs(self.victory_items) do
					if v.data[i] then
						j.item_cell:SetData(v.data[i])
						j.item_cell:SetParentActive(true)
					else
						j.item_cell:SetParentActive(false)
					end
				end
			end
			if v.leave_time then
				if self.leave_timer == nil then
					self.leave_time = v.leave_time
					self:LeaveUpdate()
					self.leave_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.LeaveUpdate, self), 1)
				end
			end
			self:SetCloseCallBack(v.close_callback)
			if k == "reward" then
				self.do_not_exit_fb = true
			end
		elseif k == "expfinish" then
			self.is_exp:SetValue(true)
			self.victory_text:SetValue(v.data[1])
			self.exp_items.item_cell:SetData(v.data[2])
			self.exp_items.item_cell:SetParentActive(true)
			if v.leave_time then
				if self.leave_timer == nil then
					self.leave_time = v.leave_time
					self:LeaveUpdate()
					self.leave_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.LeaveUpdate, self), 1)
				end
			end
		elseif k == "Ysjtfinish" then
			self.show_win_text_panel:SetValue(true)
			self.show_win_img:SetValue(true)	
			self.show_text.show_text1:SetValue(true)
			self.win_text.win_text1:SetValue(v.data[1])

		elseif k == "teamtower" then
			self.show_win_text_panel:SetValue(true)
			self.show_win_img:SetValue(true)	
			self.show_text.show_text1:SetValue(false)
			self.show_text.show_text2:SetValue(true)
			if v.leave_time then
				if self.leave_timer == nil then
					self.leave_time = v.leave_time
					self:LeaveUpdate()
					self.leave_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.LeaveUpdate, self), 1)
				end
			end
		elseif k == "teamSpecial" then				--须臾幻境
			self.show_win_text_panel:SetValue(true)
			self.show_win_img:SetValue(true)
			self.show_text.show_text1:SetValue(false)
			self.show_text.show_text2:SetValue(false)
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