local tbUi = Ui:CreateClass("TeamPanel");

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_TEAM_UPDATE, self.TeamUpdate, self },
		{ UiNotify.emNOTIFY_QUICK_TEAM_UPDATE, self.ActivityUpdate, self },
		{ UiNotify.emNOTIFY_MAP_LEAVE, self.Close, self },
		{ UiNotify.emNOTIFY_WND_CLOSED, self.WndClosed, self},
	};

	return tbRegEvent;
end

function tbUi:OnOpen(szType, param1, ...)
	if not TeamMgr:CanTeam(me.nMapTemplateId) then
		me.CenterMsg("当前地图不允许组队");
		return 0;
	end

	if szType == "TeamDetail" and param1 then
		if TeamMgr:HasTeam() then
			Ui:OpenWindow("TeamRequestQueue", "Apply");
		else
			Ui:OpenWindow("TeamRequestQueue", "Invite");
		end
		return 0;
	end

	TeamMgr:Ask4Activitys();
end

function tbUi:OnOpenEnd(szType, param1, ...)
	self.TeamActivity:Init(param1, ...);
end

function tbUi:Close()
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:TeamUpdate(...)
	self.TeamActivity:UpdateTeam(...);
end

function tbUi:ActivityUpdate(...)
	self.TeamActivity:UpdateActivity(...);
end

function tbUi:WndClosed(szUiName)
	if szUiName == "RightPopup" then
		self.TeamActivity:UpdateTeam();
	end
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi.tbOnClick:BtnInfo()
	Ui:OpenWindow("TeamActivityHelp")
end
