local tbUi = Ui:CreateClass("ViewPanel");
local nMoveSpeed = 5
local nReverse = -1 		-- -1 上拉推近 1 上拉推远
function tbUi:OnOpen(bPhoto)
	self.nViewSlideValue = Client:GetFlag(Operation.szCameraSettingKey, Operation.nSaveCameraSettingViewChange) or 0
	self.pPanel:SliderBar_SetValue("Bar", self.nViewSlideValue);
	self.pPanel:SetActive("BtnClose", not bPhoto)
	self.bPhoto = bPhoto
	if not bPhoto then
		Operation.HideFakeJoystick()
	end
end

function tbUi:OnOpenEnd()
	self.pPanel:ChangeBoxColliderSize("Bar", 800, 882)
end

function tbUi:OnClose()
	if not self.bPhoto then
		Ui:ChangeUiState(Ui.STATE_DEFAULT, true)
		Operation.ShowFakeJoystick()
	end
	Operation:DoSaveCameraSetting()
	Operation:EnableWalking()
	-- Operation:UpdateAssistState()
end

function tbUi:OnCameraSettingChange()
	local nValue = Operation:GetViewChangeByDistance()
	self.nViewSlideValue = nValue
	self.pPanel:SliderBar_SetValue("Bar", nValue);
end

function tbUi:RegisterEvent()
    return {
        {UiNotify.emNOTIFY_CAMERA_SETTING_CHANGE, self.OnCameraSettingChange},
    }
end

function tbUi:ChangeCamera()
	if Operation:IsAssistMap() then
		local fValue = string.format("%0.6f", self.pPanel:SliderBar_GetValue("Bar"));
		local nChange = fValue - self.nViewSlideValue
		local nDistance, nAngle, nViewField = Operation:GetChangeByDistance(nReverse * nChange, nMoveSpeed)
		Ui.CameraMgr.ChangeCameraSetting(nDistance, nAngle, nViewField)
		self.nViewSlideValue = fValue
	end
end

tbUi.tbOnClick = {
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end;
	Bar = function (self)
		self:ChangeCamera()
	end;
}

tbUi.tbOnDrag = 
{
	Bar = function (self, szWnd, nX, nY)
		self:ChangeCamera()
	end;
}


tbUi.tbOnDragEnd =
{
	Bar = function (self)
		
	end;
}