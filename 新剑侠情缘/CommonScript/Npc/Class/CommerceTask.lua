local tbNpc = Npc:GetClass("CommerceTask")

function tbNpc:OnDialog()
	if me.nLevel < CommerceTask.START_LEVEL then
		local szDefaultText = string.format("少侠阅历尚浅，%d级以后再来找老夫吧。", CommerceTask.START_LEVEL);
		Dialog:Show({Text = szDefaultText, OptList = {}}, me, him);
		return;
	end

	if not CommerceTask:IsTimeFrameOpen() then
		Dialog:Show({Text = "活动尚未开放，请静候", OptList = {}}, me, him);
		return;
	end

	if CommerceTask:CanAcceptTask(me) then
		local OptList = {
			{Text = "接受", Callback = self.Accept, Param = {self}},
			{Text = "以后再说吧"},
		};
		local szDefaultText = "商会近期急缺一批货物，不知少侠是否愿意相助？";
		local tbDialogInfo = {Text = szDefaultText, OptList = OptList};
		Dialog:Show(tbDialogInfo, me, him);
	elseif CommerceTask:IsDoingTask(me) then
		CommerceTask:SyncCommerceData(me);
		local tbCommerceTask = CommerceTask:GetTaskInfo(me)
		local nFinishCount = 0
		for i = 1, 10 do
			local tbTask = tbCommerceTask.tbTask[i]
			if tbTask.bFinish then
				nFinishCount = nFinishCount + 1
			end
		end

		if nFinishCount < CommerceTask.COMPLETE_COUNT then
			me.CallClientScript("Ui:OpenWindow", "CommerceTaskPanel")
		else
			local szDefaultText = "老夫所托之事如何了？"
			local OptList = {
				{Text = "缴纳货物", Callback = CommerceTask.FinishTask, Param = {CommerceTask, me.dwID}}
			}
			local tbDialogInfo = {Text = szDefaultText, OptList = OptList};
			Dialog:Show(tbDialogInfo, me, him);
		end
	else
		local szDefaultText = "少侠今天无法再接受商会任务了";
		local tbDialogInfo = {Text = szDefaultText, OptList = {}};
		Dialog:Show(tbDialogInfo, me, him);
	end
end

function tbNpc:Accept()
	CommerceTask:AcceptTask(me);
	
	CommerceTask:SyncCommerceData(me);
	me.CallClientScript("Ui:OpenWindow", "CommerceTaskPanel")
end