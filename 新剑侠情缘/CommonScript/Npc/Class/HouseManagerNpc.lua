
local tbNpc = Npc:GetClass("HouseManagerNpc");

function tbNpc:OnDialog()
	local szText = Npc:GetRandomTalk(him.nTemplateId, me.nMapTemplateId);
	szText = szText or "这位侠士，你需要建房么？";
	
	if me.nHouseState ~= 1 and Task:GetTaskFlag(me, House.nFinishHouseTaskId) == 1 then
		Dialog:Show(
		{
			Text	= "这位侠士，你需要建房么？",
			OptList = {{ Text = "获得家园", Callback = function ()
				House:Create(me, 1);
			end, Param = {}}},
		}, me, him);
		return;
	end

	for _, nTaskId in pairs(House.tbAllHouseTask) do
		if Task:GetPlayerTaskInfo(me, nTaskId) then
			szText = "大侠，不知所托之事如何了？切莫耽误了家园建造进度……";
			break;
		end
	end

	local tbDlg = {};

	if House:CheckOpen(me) then
		if Task:GetPlayerTaskInfo(me, House.nSecondHouseTaskId) then
			table.insert(tbDlg, { Text = "建造家园", Callback = function ()
				Task:DoAddExtPoint(me, House.nSecondHouseTaskId, 1);
			end, Param = {}});

			szText = "这位侠士，你需要建房么？";
		end

		local tbHouse = House:GetHouse(me.dwID);
		if tbHouse and tbHouse.nStartLeveupTime then
			local tbSetting = House.tbHouseSetting[tbHouse.nLevel];
			if tbHouse.nStartLeveupTime + tbSetting.nLevelupTime <= GetTime() then
				szText = "大侠，您的家园升级扩建已经完成了哦！";
				table.insert(tbDlg, { Text = "好的，有劳姑娘。[FFFE0D]（完成家园升级）[-]", Callback = self.DoHouseLevelup, Param = {self} });
			end
		end

		if tbHouse then
			table.insert(tbDlg, { Text = "我要回家", Callback = self.GoHome, Param = {self} })
		end
	end

	if House:IsTimeFrameOpen() then
		for nMapTemplateId, _ in pairs(House.tbSampleHouseSetting) do
			table.insert(tbDlg, { Text = "前往「新颖小筑」", Callback = self.GotoSampleHouse, Param = { self, nMapTemplateId } });
		end
	end

	Dialog:Show(
	{
		Text	= szText,
		OptList = tbDlg,
	}, me, him);
end

function tbNpc:DoHouseLevelup()
	House:DoLevelUp(me);
end

function tbNpc:GoHome()
	House:GoMyHome(me);
end

function tbNpc:GotoSampleHouse(nMapTemplateId)
	SampleHouse:EnterSampleHouse(me, nMapTemplateId);
end
