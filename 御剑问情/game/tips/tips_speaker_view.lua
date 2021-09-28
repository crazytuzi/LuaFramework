------------------------------------------------------------
--喇叭公告
------------------------------------------------------------
TipsSpeakerView = TipsSpeakerView or BaseClass(BaseView)

function TipsSpeakerView:__init()
	self.ui_config = {"uis/views/tips/speakertips_prefab", "SpeakerView"}
	self.view_layer = UiLayer.Pop
end

function TipsSpeakerView:__delete()
	self.send_state = nil
end

function TipsSpeakerView:LoadCallBack()
	self.speaker_input = self:FindObj("InputContent")
	self.world_toggle = self:FindObj("worldToggle")
	self.kuafu_toggle = self:FindObj("KuafuToggle")
	self.kl_hongbao_toggle = self:FindObj("PwHongbaoToggle")
	self.show_need = self:FindVariable("ShowNeed")
	self.need = self:FindVariable("Need")

	self.world_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, SPEAKER_TYPE.SPEAKER_TYPE_LOCAL))
	self.kuafu_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, SPEAKER_TYPE.SPEAKER_TYPE_CROSS))
	self.kl_hongbao_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, SPEAKER_TYPE.SPEAKER_TYPE_KOULING))
	self:ListenEvent("OnClickSendButton",
		BindTool.Bind(self.OnClickSendButton, self))
	self:ListenEvent("OnClickCloseButton",
		BindTool.Bind(self.OnClickCloseButton, self))
	self:ListenEvent("OnClickDecsButton",
		BindTool.Bind(self.OnClickDecsButton, self))

	-- self:OnToggleChange(SPEAKER_TYPE.SPEAKER_TYPE_KOULING)
	self:OnToggleChange(SPEAKER_TYPE.SPEAKER_TYPE_LOCAL)
end

function TipsSpeakerView:ReleaseCallBack()
	-- 清理变量和对象
	self.speaker_input = nil
	self.world_toggle = nil
	self.kuafu_toggle = nil
	self.kl_hongbao_toggle = nil
	self.show_need = nil
	self.need = nil
end

function TipsSpeakerView:OnToggleChange(send_state)
	self.send_state = send_state
	self.show_need:SetValue(self.send_state == SPEAKER_TYPE.SPEAKER_TYPE_KOULING)
	local cfg = ConfigManager.Instance:GetAutoConfig("commandspeaker_auto").other[1]
	self.need:SetValue(cfg.consume)
end

function TipsSpeakerView:CloseCallBack()
	if self.speaker_input then
		self.speaker_input.input_field.text = ""
	end
end

function TipsSpeakerView:OnClickSendButton()
	local text = self.speaker_input.input_field.text
	if text == "" then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NilContent)
		return
	end
	if ChatFilter.Instance:IsIllegal(text) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.IllegalContent)
		return
	end

	if not ChatData.Instance:IsCanChat(CHAT_OPENLEVEL_LIMIT_TYPE.SPEAKER) then
		return
	end

	local function ok_callback()
		if self.send_state == SPEAKER_TYPE.SPEAKER_TYPE_KOULING then
			ChatCtrl.Instance:SendCreateCommandRedPaper(text)
		else
			ChatCtrl.Instance:SendCurrentTransmit(1, text, nil, self.send_state)
		end
		self.speaker_input.input_field.text = ""
		self:Close()
	end

	local des = ""
	local price = 0
	local open_view_str = ""
	if self.send_state == SPEAKER_TYPE.SPEAKER_TYPE_LOCAL then
		price = 10
		des = string.format(Language.Chat.SendByGold, price)
		open_view_str = "speaker_local"
	elseif self.send_state == SPEAKER_TYPE.SPEAKER_TYPE_KOULING then
		local cfg = ConfigManager.Instance:GetAutoConfig("commandspeaker_auto").other[1]
		price = cfg.consume
		des = string.format(Language.Chat.SendKoulingHbByGold, price)
		open_view_str = "speaker_kouling"
	else
		price = 30
		des = string.format(Language.Chat.SendSrossByGold, price)
		open_view_str = "speaker_cross"
	end
	TipsCtrl.Instance:ShowCommonAutoView(open_view_str, des, ok_callback)
end

function TipsSpeakerView:OnClickCloseButton()
	self:Close()
end

function TipsSpeakerView:OnClickDecsButton()
	TipsCtrl.Instance:ShowHelpTipView(188)
end

function TipsSpeakerView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "all" and v.item_id then
			if tonumber(v.item_id) == 26907 then
				self.kuafu_toggle.toggle.isOn = true
			elseif tonumber(v.item_id) == 26908 then
				self.world_toggle.toggle.isOn = true
			end
		end
	end
end