
Task.tbClientNpcFunc = Task.tbClientNpcFunc or {};
local tbClientNpcFunc = Task.tbClientNpcFunc;

function tbClientNpcFunc:LoadMovePos()
	local tbPath = LoadTabFile("Setting/Task/TaskClientNpcPos.tab", "sddd", nil, {"ClassName", "nX", "nY", "nDir"});
	self.tbNpcPath = {};
	self.tbArriveDir = {};
	for _, tbRow in pairs(tbPath) do
		if tbRow.nDir and tbRow.nDir > 0 then
			self.tbArriveDir[tbRow.ClassName] = tbRow.nDir;
		end
		self.tbNpcPath[tbRow.ClassName] = self.tbNpcPath[tbRow.ClassName] or {};
		table.insert(self.tbNpcPath[tbRow.ClassName], {tbRow.nX, tbRow.nY});
	end
end
tbClientNpcFunc:LoadMovePos();

function tbClientNpcFunc:Move(pNpc, szPos)
	local tbPosInfo = self.tbNpcPath[szPos];
	if not tbPosInfo then
		Log("[Task] tbClientNpcFunc Move unknow szPos", szPos);
		return;
	end

	if self.tbArriveDir[szPos] then
		pNpc.tbOnArrive = pNpc.tbOnArrive or {self.OnArrive, self, {}};
		pNpc.tbOnArrive[3].nDir = self.tbArriveDir[szPos];
	end

	pNpc.AI_ClearMovePathPoint();
	for _,Pos in ipairs(tbPosInfo) do
		if (Pos[1] and Pos[2]) then
			Log(unpack(Pos));
			pNpc.AI_AddMovePos(Pos[1], Pos[2]);
		end
	end

	pNpc.AI_StartPath(0);
end

function tbClientNpcFunc:MoveAndDelete(pNpc, szPos)
	pNpc.tbOnArrive = {self.OnArrive, self, {bArriveDel = 1}};
	self:Move(pNpc, szPos);
end

function tbClientNpcFunc:MoveAndTalk(pNpc, szParam)
	local tbInfo = Lib:SplitStr(szParam, "|");
	pNpc.tbOnArrive = {self.OnArrive, self, {szInfo = tbInfo[2], szTime = tbInfo[3]}};
	self:Move(pNpc, tbInfo[1]);
end

function tbClientNpcFunc:OnArrive(tbParam)
	if tbParam.bArriveDel == 1 then
		him.Delete();
		return;
	end

	if tbParam.nDir then
		him.SetDir(tbParam.nDir);
	end

	if tbParam.szInfo then
		him.BubbleTalk(tbParam.szInfo, tbParam.szTime or "3");
	end
end