local tbUi = Ui:CreateClass("FakeJoyStick");

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_FAKE_JOYSTICK_GUIDING, self.ChangeGuid, self},
		{ UiNotify.emNOTIFY_FAKE_JOYSTICK_STATE, self.ChangeState, self},
	};

	return tbRegEvent;
end

function tbUi:OnOpen()
	self:ChangeGuid(false);
end

function tbUi:ChangeState(bShow)
	self.pPanel:SetActive("JoyStickTexture", bShow);
end

function tbUi:ChangeGuid(bGuid)
	self.pPanel:Texture_SetAlpha("JoyStickTexture", bGuid and 1 or 0.4);
end
