
local tbTaskNpc = Npc:GetClass("ClientTaskNpc");

function tbTaskNpc:OnDialog()
	local nTaskId = him.nTaskId;
	if not nTaskId then
		local szParam = string.gsub(him.szScriptParam, "\"", "");
		nTaskId = tonumber(szParam);
	end

	local nTaskState = Task:GetTaskState(me, nTaskId, me.GetNpc().nId);

	if nTaskState == Task.STATE_CAN_FINISH or nTaskState == Task.STATE_ON_DING then
		RemoteServer.DoTaskNextStep(nTaskId, me.GetNpc().nId);
	end
end
