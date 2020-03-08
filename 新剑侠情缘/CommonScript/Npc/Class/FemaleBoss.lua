local tbNpc = Npc:GetClass("FemaleBoss");

function tbNpc:OnDialog()
	 Dialog:Show(
        {
            Text    = "忘忧酒馆，一醉忘忧",
            OptList = {},
        }, me, him)
end
function tbNpc:ChooseFlowTask(dwID, nFlowType)
	local pPlayer = KPlayer.GetPlayerObjById(dwID)
	if not pPlayer then
       return
	end
	Task:TryAcceptFlowTask(pPlayer, nFlowType)
end

function tbNpc:GetDirectOptList()
	local tbOptList = self:GetOptList(me)
	return tbOptList
end

function tbNpc:GetOptList(pPlayer)
	local tbOptList = {}
	if not Task:GetRunningFlowTaskType(pPlayer) then
		local tbTask = Task:GetCanAcceptFlowTask(pPlayer)
		for _, nFlowType in ipairs(tbTask) do
			local tbFlowInfo = Task.tbFlowSetting[nFlowType]
			local szTitle = tbFlowInfo and tbFlowInfo.szTitle
			if szTitle then
				table.insert(tbOptList, { Text = szTitle, Callback = self.ChooseFlowTask, Param = {self, pPlayer.dwID, nFlowType}});
			end
		end
	end
	return tbOptList
end