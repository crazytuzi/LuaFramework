local tbUi = Ui:CreateClass("FrameSettingPanel");

function tbUi:OnOpen()
	self.pPanel:Label_SetText("Content", string.format("在自由视角下，少侠可以通过以下手势进行操作：\n\n通过[fefb1a]拖动摇杆[-]进行[fefb1a]移动[-]\n\n通过[fefb1a]左右滑动屏幕[-]进行[fefb1a]转向[-]\n\n通过[fefb1a]双指向内/向外滑动[-]进行[fefb1a]视角距离调整[-]"))
	local nType = Client:GetFlag("HidePlayerType") or 1
	self.pPanel:Toggle_SetChecked("Toggle1", nType == 2 or nType == 4); 
	self.pPanel:Toggle_SetChecked("Toggle2",  nType == 3 or nType == 4); 
end

function tbUi:OnClose()
	local bHideSystem = self.pPanel:Toggle_GetChecked("Toggle1");
	local bHidePlayer = self.pPanel:Toggle_GetChecked("Toggle2");
	local nType = 1
	if bHideSystem then
		nType = 2
	end
	if bHidePlayer then
		nType = 3
	end
	if bHideSystem and bHidePlayer then
		nType = 4
	end
	if Operation:IsAssistMap() then 
		Client:SetFlag("HidePlayerType", nType)
		Ui.Effect.ShowAllRepresentObj(nType)
		local pNpc = me.GetNpc();
		if pNpc then
			local pNpcRep = Ui.Effect.GetNpcRepresent(pNpc.nId);
			if pNpcRep then
				pNpcRep:ResetRepData();
			end
		end
	end
end
tbUi.tbOnClick = {
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end;
	BtnChange = function (self)
		if Ui:WindowVisible("ViewPanel") == 1 then
			me.CenterMsg("已经打开了切换视角距离面板")
			return
		end
		if not Operation:GetAdjustViewState() then
			Operation:DoSwitchAdjustViewState()
		end
		Ui:CloseWindow(self.UI_NAME)
		Ui:ChangeUiState(Ui.STATE_ViewAdjust);
		Operation:DisableWalking()
		Ui:OpenWindow("ViewPanel")
	end;
}
