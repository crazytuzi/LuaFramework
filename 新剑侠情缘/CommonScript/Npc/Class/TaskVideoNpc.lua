local tbNpc = Npc:GetClass("TaskVideoNpc");
function tbNpc:OnDialog()
	local szText = "青衣白衫剑侠客，百里秦川万里豪";
	local tbOptList = {}
	local tbVideoType = Task:GetBackPlayVideoType(me)
	for _, nVideoType in ipairs(tbVideoType) do
		local tbVideoInfo = Task.tbAllVideoTask[nVideoType]
		if tbVideoInfo then
			table.insert(tbOptList, { Text = tbVideoInfo.szVideoTitle, Callback = self.ChooseVideo, Param = {self, me.dwID, nVideoType}});
		end
	end
	local bAllFinish = Task:AllFlowTaskFinish(me)
	if bAllFinish then
		table.insert(tbOptList, { Text = "忘忧酒馆叁", Callback = function () me.CallClientScript("Sdk:OpenUrl", "http://www.jxqy.org") end});
	end
	Dialog:Show(
	{
		Text	= szText,
		OptList = tbOptList,
	}, me, him);
end

function tbNpc:ChooseVideo(dwID, nVideoType)
	local pPlayer = KPlayer.GetPlayerObjById(dwID)
	if not pPlayer then
       return
	end
	pPlayer.CallClientScript("Task:OnOpenTaskVideo", nVideoType)
end