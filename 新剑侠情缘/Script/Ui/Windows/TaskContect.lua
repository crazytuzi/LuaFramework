local tbUi = Ui:CreateClass("TaskContect");
tbUi.nMaxItemCount = 4;

function tbUi:OnOpen()
	self:ClearInfo();
end

function tbUi:OnCreate()
end

function tbUi:ClearInfo()
	self.pPanel:Label_SetText("InvalidTaskText", "");
	self.pPanel:Label_SetText("EfficientTaskText", "");

	for i = 1, self.nMaxItemCount do
		self["itemframe" .. i]:Clear();
	end
end

function tbUi:RefreshInvalidTask(nMainTaskIndex)
	self.pPanel:SetActive("InvalidTask", true);
	self.pPanel:SetActive("EfficientTask", false);
	self.pPanel:Label_SetText("InvalidTaskText", Task.tbMainTaskDesInfo[nMainTaskIndex].szDesc);

end

function tbUi:RefreshEfficientTask(nTaskId)
	local tbTask = Task:GetTask(nTaskId);
	if not tbTask then
		self:ClearInfo();
		print("Task Ui ERR ?? tbUi:RefreshTaskPanel tbTask is nil!!  nTaskId = " .. nTaskId);
		return;
	end

	self.pPanel:SetActive("InvalidTask", false);
	self.pPanel:SetActive("EfficientTask", true);

	self.pPanel:Label_SetText("EfficientTaskText", tbTask.szDetailDesc);

	local nCurBoxIdx = 1;
	for _, tbItem in pairs(tbTask.tbAward) do
		if tbItem[1] == "item" then
			local _, nItemTemplateId, nItemCount = unpack(tbItem);
			self["itemframe" .. nCurBoxIdx]:SetItemByTemplate(nItemTemplateId, nItemCount, me.nFaction);
			nCurBoxIdx = nCurBoxIdx + 1;

			if nCurBoxIdx > self.nMaxItemCount then
				break;
			end
		end
	end

	for i = nCurBoxIdx, self.nMaxItemCount do
		self["itemframe" .. i]:Clear();
	end
end