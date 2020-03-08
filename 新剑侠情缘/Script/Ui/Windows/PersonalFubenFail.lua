
local tbUi = Ui:CreateClass("PersonalFubenFail");
tbUi.nStrongerLevel = 15;

function tbUi:OnOpen(szMsg)
	szMsg = szMsg or "胜败乃兵家常事，大侠请重新来过";
	self.pPanel:Label_SetText("Msg", szMsg);

	self.pPanel:Button_SetEnabled("BtnFightAgain", true);
	self.pPanel:SetActive("BtnClose", me.nLevel > PersonalFuben.NoviceLevel);
	self.pPanel:SetActive("BtnStronger", me.nLevel >= math.max(self.nStrongerLevel, PersonalFuben.NoviceLevel));
end

tbUi.tbOnClick = {};
tbUi.tbOnClick.BtnClose = function (self)
	PersonalFuben:DoLeaveFuben();
end

tbUi.tbOnClick.BtnStronger = function (self)
	if me.nLevel < self.nStrongerLevel then
		return;
	end

	PersonalFuben:DoLeaveFuben(true);
end

tbUi.tbOnClick.BtnLeave = function (self)
	PersonalFuben:DoLeaveFuben();
end