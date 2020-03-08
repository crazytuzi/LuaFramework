
local tbNpc = Npc:GetClass("AddBuffer");

tbNpc.tbSkillLimit = 
{
	{2215, 2216},
}

tbNpc.tbSkillInfo = {};
for _, tbInfo in pairs(tbNpc.tbSkillLimit) do
	for _, nSkillId in pairs(tbNpc.tbSkillInfo) do
		tbNpc.tbSkillInfo[nSkillId] = tbInfo;
	end
end

function tbNpc:OnDialog()
	local tbRet = Lib:SplitStr(him.szScriptParam, ",");
	local nTime = tonumber(tbRet[1]);
	local szMsg = tbRet[2];
	local nSkillId = tonumber(tbRet[3] or 0);
	local nSkillLevel = tonumber(tbRet[4] or 1);
	local nBufferTime = tonumber(tbRet[5] or 10);
	local bNotDelete = tbRet[6] and true or false;

	if not nTime or not szMsg or not nSkillId or not nSkillLevel or not nTime then
		assert(false, string.format("[Npc] AddBuffer Npc Err nNpcTemplateId = %s, szScriptParam = %s", him.nTemplateId, him.szScriptParam));
		return;
	end
	
	local tbLimitInfo = self.tbSkillInfo[nSkillId] or {};
	for _, nSkillId in pairs(tbLimitInfo) do
		local tbState = me.GetNpc().GetSkillState(nSkillId);
		if tbState then
			return;
		end
	end
	

	if nTime <= 0 then
		self:EndProcess(me.dwID, him.nId, nSkillId, nSkillLevel, nBufferTime, bNotDelete);
	else
		GeneralProcess:StartProcess(me, nTime * Env.GAME_FPS, szMsg, self.EndProcess, self, me.dwID, him.nId, nSkillId, nSkillLevel, nBufferTime, bNotDelete);
	end
end

function tbNpc:EndProcess(nPlayerId, nNpcId, nSkillId, nSkillLevel, nTime, bNotDelete)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end

	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc or pNpc.IsDelayDelete() then
		return;
	end

	if not bNotDelete then
		pNpc.Delete();
	end

	local tbFubenInst = Fuben:GetFubenInstance(pPlayer);
	if tbFubenInst then
		tbFubenInst:OnUseSkillState(nSkillId);
	end

	pPlayer.GetNpc().AddSkillState(nSkillId, nSkillLevel, 0, nTime * Env.GAME_FPS)
end

