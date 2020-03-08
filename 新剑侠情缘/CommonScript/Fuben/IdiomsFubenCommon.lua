IdiomFuben.JOIN_LEVEL = 30
IdiomFuben.JOIN_MEMBER_COUNT = 2

IdiomFuben.nFubenMapTemplateId = 701

IdiomFuben.szFubenClass = "IdiomsFubenBase"

IdiomFuben.NameCol = 10
IdiomFuben.NameRow = 10

IdiomFuben.MIN_DISTANCE = 1000

IdiomFuben.tbPlayerInFuben = {}

IdiomFuben.tbNpcNameSet = {} 				-- 决定每条龙有几个成语
IdiomFuben.tbNpcPos = {};
IdiomFuben.tbNpcIdSet = {2051} 					-- 所有的npcid

IdiomFuben.REVIVE_TIME = 3

IdiomFuben.KICK_TIME = 5 					-- 延迟几秒踢玩家

IdiomFuben.tbReward = 
{
	[1] = {4, {{"Contrib", 50}}}, 		-- N名以下（包括N名）的奖励
	[2] = {9, {{"Contrib", 200}}},
	[3] = {14, {{"Contrib", 300}}},
	[4] = {19, {{"Contrib", 400}}},
	[5] = {24, {{"Contrib", 500}}},
	[6] = {29, {{"Contrib", 600}}},
	[7] = {34, {{"Contrib", 700}}},
	[8] = {39, {{"Contrib", 800}}},
	[9] = {44, {{"Contrib", 900}, {"AddTimeTitle", 5032, 10*24*60*60}}},
	[10] = {49, {{"Contrib", 1000}, {"AddTimeTitle", 5032, 10*24*60*60}}},
	[11] = {55, {{"Contrib", 1100}, {"AddTimeTitle", 5032, 10*24*60*60}}},
	
}

function IdiomFuben:GetReward(nRank)
	local tbAllReward = {}

	for _,tbInfo in ipairs(IdiomFuben.tbReward) do
		tbAllReward = Lib:CopyTB(tbInfo[2])
		if nRank <= tbInfo[1] then
			break
		end
	end

	return self:FormatReward(tbAllReward)
end

function IdiomFuben:FormatReward(tbAllReward)
	tbAllReward = Lib:CopyTB(tbAllReward) or {}

	local tbFormatReward = {}
	for _,tbReward in ipairs(tbAllReward) do
		if tbReward[1] == "AddTimeTitle" then
			tbReward[3] = tbReward[3] + GetTime()
		end
		table.insert(tbFormatReward,tbReward)
	end

	return tbFormatReward
end

function IdiomFuben:LoadSetting()

	local szTabPath,szParamType,tbParams

	if not next(self.tbNpcNameSet) then
		szTabPath = "Setting/Activity/Idioms/npc_name.tab";
		szParamType = "";
		tbParams = {};
		for i = 1, self.NameCol do
			szParamType = szParamType .. "s";
			table.insert(tbParams, "name" .. i);
		end
		self.tbNpcNameSet = LoadTabFile(szTabPath, szParamType, nil, tbParams);
		assert(#self.tbNpcNameSet == self.NameCol,string.format("[IdiomFuben] LoadSetting no match NameCol %d/%d",#self.tbNpcNameSet,self.NameCol))
		local nRow = 0
		for _,v in ipairs(self.tbNpcNameSet) do
			assert(Lib:CountTB(v) == IdiomFuben.NameCol,"[IdiomFuben] LoadSetting valid NameCol")
			nRow = nRow + 1
		end

		assert(nRow == IdiomFuben.NameRow,"[IdiomFuben] LoadSetting valid NameRow")
	end

	if not next(self.tbNpcPos) then
		szTabPath = "Setting/Activity/Idioms/npc_pos.tab";
		szParamType = "ddd";
		tbParams = {"PosX", "PosY"};
		local tbFile = LoadTabFile("Setting/Activity/Idioms/npc_pos.tab", "dd", nil, {"PosX", "PosY"});
		for _, tbInfo in ipairs(tbFile) do
			table.insert(self.tbNpcPos, {nPosX = tbInfo.PosX, nPosY = tbInfo.PosY});
		end
	end
end

