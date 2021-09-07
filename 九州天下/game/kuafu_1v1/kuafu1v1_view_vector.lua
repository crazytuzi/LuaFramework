KuaFu1v1ViewVector = KuaFu1v1ViewVector or BaseClass(BaseView)

function KuaFu1v1ViewVector:__init(instance)
	self.ui_config = {"uis/views/kuafu1v1","KuaFu1v1Vector"}
	self.view_layer = UiLayer.MainUI
	self.play_audio = true
	self:SetMaskBg()
end

function KuaFu1v1ViewVector:__delete()

end

function KuaFu1v1ViewVector:LoadCallBack()
	self.ji_fen = self:FindVariable("Jifen")
	self.reward = self:FindVariable("Reward")
	self.rank = self:FindVariable("Rank")
	self.value = self:FindVariable("Value")
	self.slider = self:FindObj("Slider"):GetComponent(typeof(UnityEngine.UI.Slider))
	self.is_up_level = self:FindVariable("IsUpLevel")
	self.next_rank = self:FindVariable("NextRank")

	self:ListenEvent("OnClick",
		BindTool.Bind(self.OnClick, self))

	self.is_up_level:SetValue(false)
end

function KuaFu1v1ViewVector:ReleaseCallBack()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	self.ji_fen = nil
	self.reward = nil
	self.rank = nil
	self.value = nil
	self.slider = nil
	self.is_up_level = nil
	self.next_rank = nil
end

function KuaFu1v1ViewVector:OpenCallBack()
	self:Flush()
end

function KuaFu1v1ViewVector:OnFlush()
	self.timer_quest = GlobalTimerQuest:AddDelayTimer(function() self:OnClick() end, 5)
	local result = KuaFu1v1Data.Instance:GetFightResult()
	local add_score = 0
	if result then
		add_score = result.this_score
		self.ji_fen:SetValue("+" .. result.this_score)
		self.reward:SetValue("+" .. result.this_honor)
	end
	local info = KuaFu1v1Data.Instance:GetRoleData()
	if info then
		local score = info.cross_score_1v1
		local current_config, next_config = KuaFu1v1Data.Instance:GetRankByScore(score)
		self:SetCurInfo(score, current_config, next_config)
		GlobalTimerQuest:AddDelayTimer(function() self:SetNextInfo(score, add_score, current_config, next_config) end, 0.1)
	end
end

function KuaFu1v1ViewVector:SetCurInfo(score, current_config, next_config)
	if current_config then
		self.rank:SetValue(current_config.rank_name)
		if next_config then
			local temp = next_config.rank_score - current_config.rank_score
			self.slider.value = (score - current_config.rank_score) / temp
			self.value:SetValue(score .. "/" .. next_config.rank_score)
			self.next_rank:SetValue(next_config.rank_name)
		else
			self.slider.value = 1
			self.value:SetValue(score)
		end
	elseif next_config then
		self.rank:SetValue(Language.Common.WuDuanWei)
		self.slider.value = score / next_config.rank_score
		self.value:SetValue(score .. "/" .. next_config.rank_score)
		self.next_rank:SetValue(next_config.rank_name)
	end
end

function KuaFu1v1ViewVector:SetNextInfo(score, add_score, current_config, next_config)
	local new_score = score + add_score
	local new_current_config, new_next_config = KuaFu1v1Data.Instance:GetRankByScore(new_score)
	if current_config == new_current_config then
		if next_config and current_config then
			local temp = next_config.rank_score - current_config.rank_score
			self.slider:DOValue((new_score - current_config.rank_score) / temp, 0.5, false)
			self.value:SetValue(new_score .. "/" .. next_config.rank_score)
		end
		self.is_up_level:SetValue(false)
	else
		self.is_up_level:SetValue(true)
		local tweener = self.slider:DOValue(1, 0.25, false)
		tweener:OnComplete(function()
		 if new_current_config and new_next_config then
		 	self.value:SetValue(new_score .. "/" .. new_next_config.rank_score)
		 	local temp = new_next_config.rank_score - new_current_config.rank_score
		 	self.slider.value = 0
		 	GlobalTimerQuest:AddDelayTimer(function() self.slider:DOValue((new_score - new_current_config.rank_score) / temp, 0.25, false) end, 0.01)
		 end
		  end)
	end
end

function KuaFu1v1ViewVector:OnClick()
	self:Close()
	CrossServerCtrl.Instance:GoBack()
end