local tbNpc = Npc:GetClass("PrisonHelper");

function tbNpc:OnDialog()
	local szText = "只要你把钱给我，我就有本事让你提前离开这鬼地方！";
	local tbOptList = {};

	table.insert(tbOptList, { Text = "缴纳欠款", Callback = function () self:OpenRechargeWindow(); end});
	table.insert(tbOptList, { Text = "离开暗黑地牢", Callback = function () self:Leave(); end});

	Dialog:Show(
	{
		Text	= szText,
		OptList = tbOptList,
	}, me, him);
end

function tbNpc:OpenRechargeWindow()
	if me.GetMoneyDebt("Gold") <= 0 then
		me.MsgBox("您已经缴齐欠款，是否继续前往商城？", {{"继续", function ()
			me.CallClientScript("Ui:OpenWindow", "CommonShop", "Recharge", "Recharge");
		end}, {"取消"}});
		return;
	end

	me.CallClientScript("Ui:OpenWindow", "CommonShop", "Recharge", "Recharge");
end

function tbNpc:Leave()
	if me.CanPushPrison() then
		me.CenterMsg("您有欠款尚未缴纳，请补齐欠款");
	else
		Log("Leave Prison", me.dwID, me.szName);
		me.PushToPrison(0);
		Map:SwitchMapDirectly(Map.MAIN_CITY_XIANYAN_TEAMPLATE_ID, Map.MAIN_CITY_XIANYAN_TEAMPLATE_ID);
	end
end