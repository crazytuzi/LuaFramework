TipPaTaView = TipPaTaView or BaseClass(BaseView)
function TipPaTaView:__init()
	self.ui_config = {"uis/views/tips/patatips_prefab", "PaTaTipsView"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].Shengli) or 0
	end

	self.power = 0
end

function TipPaTaView:ReleaseCallBack()
	if self.cal_time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end

	-- 清理变量和对象
	self.desc_text = nil
	self.next_fight_power = nil
end

function TipPaTaView:LoadCallBack()
	self:ListenEvent("Close",BindTool.Bind(self.OnCloseClick, self))
	self:ListenEvent("OkClick",BindTool.Bind(self.OnOkClick, self))
	self.desc_text = self:FindVariable("desc_text")
	self.next_fight_power = self:FindVariable("NextPower")
end

function TipPaTaView:OpenCallBack()
	self:Flush()
end

function TipPaTaView:CloseCallBack()
	self.no_func = nil
	self.ok_func = nil
	if self.cal_time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end
end

function TipPaTaView:OnFlush()
	self:SetNextFightPower()
	self:CalTime()
end

function TipPaTaView:OnCloseClick()
	if self.no_func ~= nil then
		self.no_func()
	end
	self:Close()
end

function TipPaTaView:SetNoCallback(func)
	self.no_func = func
end


function TipPaTaView:SetOKCallback(func)
	self.ok_func = func
end

function TipPaTaView:SetFightPower(power)
	self.power = power or 0
end

function TipPaTaView:OnOkClick()
	if self.ok_func then
		self.ok_func()
	end
	self:Close()
end

function TipPaTaView:CalTime()
	if self.cal_time_quest then return end
	local timer_cal = 5
	self.cal_time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer_cal = timer_cal - UnityEngine.Time.deltaTime
		if timer_cal <= 0 then
			self:OnOkClick()
			self.cal_time_quest = nil
		else
			self.desc_text:SetValue(math.floor(timer_cal))
		end
	end, 0)
end

function TipPaTaView:SetNextFightPower()
	local power = 0
	if self.power > 0 then
		power = self.power
	else
		local tower_fb_info = FuBenData.Instance:GetTowerFBInfo()
		local fuben_cfg = FuBenData.Instance:GetTowerFBLevelCfg()
		local temp_next_level = tower_fb_info.today_level + 1

		power = fuben_cfg[temp_next_level].capability
	end

	local capability = GameVoManager.Instance:GetMainRoleVo().capability

	local str_fight_power = string.format(Language.Mount.ShowGreenStr1, power)
	if capability < power then
		str_fight_power = string.format(Language.Mount.ShowRedStr, power)
	end
	if self.next_fight_power then
		self.next_fight_power:SetValue(str_fight_power)
	end
end



