local tbNpc = Npc:GetClass("CollectAndRobClueDialog")

function tbNpc:OnDialog()
	local nAcceptRoleId = him.nAcceptRoleId
	if not nAcceptRoleId then
		return
	end
	if me.dwID ~= nAcceptRoleId then
		local tbDialogInfo = {Text = "少侠，我好像不认识你。", OptList = {}};
		Dialog:Show(tbDialogInfo, me, him);	
		return
	end

	local OptList = {
		{Text = "接受", Callback = self.Accept, Param = {self}},
		{Text = "以后再说吧"},
	};
	local tbDialogInfo = {Text = him.szDialogMsg, OptList = OptList};
	Dialog:Show(tbDialogInfo, me, him);

end

function tbNpc:Accept()
	if me.GetMoney("Gold") < him.nSellPrice then
		me.CenterMsg("您的元宝不足")
		return
	end

	local nNpcId = him.nId;
	me.CostGold(him.nSellPrice, Env.LogWay_CollectAndRobClue, him.nTemplateId, function (nPlayerId, bSucceed)
		if not bSucceed then
			return false
		end
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
		if not pPlayer then
			return false
		end
		local pNpc = KNpc.GetById(nNpcId)
		if not pNpc then
			pPlayer.CenterMsg("商人已消失")
			return false
		end

		Activity:OnPlayerEvent(pPlayer, "Act_OnBuyFromNpc", pNpc)
	end)
end