
local tbUi = Ui:CreateClass("PersonalFubenDeath");

function tbUi:OnOpen()
	self:Update();
end

function tbUi:Update()
	local tbFuben = PersonalFuben:GetCurFubenInstance();
	local nCost, szMsg = PersonalFuben:GetRevivePrice(tbFuben.nFubenIndex, tbFuben.nFubenLevel, tbFuben.nDeathCount);

	if not nCost then
		self.pPanel:Label_SetText("DeathInformation", szMsg);
		self.pPanel:Button_SetEnabled("BtnOK", false);
		return;
	end

	local _, szMoneyEmotion = Shop:GetMoneyName("Gold")
	szMsg = string.format("可恶，胜败乃兵家常事，大侠岂能在这里被击倒？是否花费%d%s重新来过？", nCost, szMoneyEmotion);
	self.pPanel:Label_SetText("DeathInformation", szMsg);

end

tbUi.tbOnClick = {};
tbUi.tbOnClick.BtnOK = function (self)
	local tbFuben = PersonalFuben:GetCurFubenInstance();
	if tbFuben.bClose == 1 then
		return;
	end

	local nCurGold = me.GetMoney("Gold");
	local nCost, szMsg = PersonalFuben:GetRevivePrice(tbFuben.nFubenIndex, tbFuben.nFubenLevel, tbFuben.nDeathCount);
	if nCurGold < nCost then
		me.CenterMsg("元宝不足，无法复活！");
		Ui:OpenWindow("CommonShop", "Recharge", "Recharge");
		return;
	end

	--tbFuben:TryReviveInFuben();
end

tbUi.tbOnClick.BtnCancel = function (self)
	local tbFuben = PersonalFuben:GetCurFubenInstance();
	tbFuben:GameLost();
	me.Revive();
	Ui:CloseWindow("PersonalFubenDeath");
end