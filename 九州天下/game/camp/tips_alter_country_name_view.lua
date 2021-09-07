TipsAlterCountryName = TipsAlterCountryName or BaseClass(BaseView)

function TipsAlterCountryName:__init()
	self.ui_config = {"uis/views/camp", "AlterCountryNameTip"}
	self:SetMaskBg(true)
	self.view_layer = UiLayer.Pop

	self.data = nil
	self.name = ""
	self.callback = nil
	self.is_need_pro = false
	self.play_audio = true
	self.character_limit = 1
end

function TipsAlterCountryName:__delete()
	
end

function TipsAlterCountryName:LoadCallBack()
	self.chat_input = self:FindObj("ChatInput")

	self.current_name = self:FindVariable("CurrentName")
	self.need_money = self:FindVariable("NeedMoney")
	self.is_cooling = self:FindVariable("IsCooling")
	self.cooling_time = self:FindVariable("Timer")

	self:ListenEvent("Rename", BindTool.Bind(self.RenameOnChange, self))
	self:ListenEvent("OnClickConfirm", BindTool.Bind(self.ConfirmBtnOnClick, self))
	self:ListenEvent("OnClickCancel", BindTool.Bind(self.CancelBtnOnClick, self))
end

function TipsAlterCountryName:ReleaseCallBack()
	self.chat_input = nil
	self.current_name = nil
	self.need_money = nil
	self.is_cooling = nil
	self.cooling_time = nil

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function TipsAlterCountryName:OpenCallBack()
	self.name = ""
	self.chat_input.input_field.text = self.name
	self.chat_input.input_field.characterLimit = self.character_limit
	if self.current_name_value then
		self.current_name:SetValue(self.current_name_value)
	end
	if self.need_money_value then
		self.need_money:SetValue(self.need_money_value)
	end

	self:ChangeTime()
	self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.ChangeTime, self), 1)
end

function TipsAlterCountryName:CloseCallBack()
	self.callback = nil
	self.current_name_value = nil
	self.need_money_value = nil

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

-- 国号冷却
function TipsAlterCountryName:ChangeTime()
	local time = CampData.Instance:GetCampNameCoolingTime() - TimeCtrl.Instance:GetServerTime()
	self.is_cooling:SetValue(time > 0)
	if time < 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
		return
	end
	self.cooling_time:SetValue(TimeUtil.FormatSecond(time))
end

function TipsAlterCountryName:RenameOnChange()
	self.name = self.chat_input.input_field.text
end

function TipsAlterCountryName:ConfirmBtnOnClick()
	if ChatFilter.Instance:IsIllegal(self.name, true) then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.IllegalContent)
		return
	end
	
	if self.callback ~= nil then
		self.callback(self.name)
		self.callback = nil
	end
	self:Close()
end

function TipsAlterCountryName:CancelBtnOnClick()
	self:Close()
end

function TipsAlterCountryName:SetConfig(current_name_value, need_money_value)
	self.current_name_value = current_name_value
	self.need_money_value = need_money_value
end

function TipsAlterCountryName:SetCallBack(callback)
	self.callback = callback
end

function TipsAlterCountryName:SetItemId(item_id)
	self.item_id = item_id
end