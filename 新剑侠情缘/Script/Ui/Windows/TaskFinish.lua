local tbUi = Ui:CreateClass("TaskFinish");

function tbUi:OnOpen(nTaskId, nNpcId)
	nTaskId = nTaskId or 0
	local tbTask = Task:GetTask(nTaskId or 0);
	if LoverTask:IsLoverTask(nTaskId) then
		local tbLoverTask = LoverTask:GetLoverTask(me)
		if tbLoverTask then
			tbTask = {}
			tbTask.szTaskTitle = tbLoverTask[2] or ""
			tbTask.szDetailDesc = tbLoverTask[4] or ""
			tbTask.tbAward = tbLoverTask[5] or {}
		end
	end
	if not tbTask then
		return 0;
	end

	if Ui:WindowVisible("HomeScreenTask") and Ui("HomeScreenTask").nAutoFinishTaskId == nTaskId then
		RemoteServer.OnFinishTaskDialog(nTaskId, Task.STATE_CAN_FINISH, nNpcId);
		return 0;
	end

	self.nTaskId = nTaskId;
	self.nNpcId = nNpcId;
	self.pPanel:Label_SetText("TaskTitle", tbTask.szTaskTitle);
	self.pPanel:Label_SetText("TaskDesc", tbTask.szDetailDesc);

	local tbAward = tbTask.tbAward or {};
	for i = 1, 4 do
		if tbAward[i] then
			self.pPanel:SetActive("itemframe" .. i, true);
			self["itemframe" .. i]:SetGenericItem(tbAward[i]);
			self["itemframe" .. i].fnClick = self["itemframe" .. i].DefaultClick;
		else
			self.pPanel:SetActive("itemframe" .. i, false);
		end
	end
end

tbUi.tbOnClick = tbUi.tbOnClick or {};
tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick.Btnchallenge = function (self)
	Ui:CloseWindow(self.UI_NAME);
	if LoverTask:IsLoverTask(self.nTaskId) then
		RemoteServer.LoverTaskOnClientCall("DoTask", LoverTask.PROCESS_FINISH_TASK);
	else
		RemoteServer.OnFinishTaskDialog(self.nTaskId, Task.STATE_CAN_FINISH, self.nNpcId);
	end
end