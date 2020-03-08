Item.Obj = Item.Obj or {};
local Obj = Item.Obj;
Obj.MAX_DROP_RANGE = 3;
Obj.CELL_LENGTH = 200;

Obj.TYPE_BUFF = 1;
Obj.TYPE_CHECK_FIGHT_MODE = 2;
Obj.TYPE_CHECK_FIGHT_MODE_RIDE = 3;

Obj.tbCallBack =
{
	[Obj.TYPE_BUFF] = "OnTrapBuff";
	[Obj.TYPE_CHECK_FIGHT_MODE] = "OnTrapCheckFightMode";
	[Obj.TYPE_CHECK_FIGHT_MODE_RIDE] = "OnTrapCheckFightModeAndRide";
}

function Item:OnObjTrap(...)
	return Obj:OnTrap(...);
end

function Obj:LoadBuff()
	self.tbBuffList = LoadTabFile("Setting/Item/DropBuffList.tab", "ddddddd", "nBuffId", {"nBuffId", "nObjId", "nDeathTime", "nSkillId", "nSkillLevel", "nParam1", "nParam2"});
end
Obj:LoadBuff();

function Obj:GetPos(fnSelect, nStartPosX, nStartPosY, nWidth)
	local nIdx = fnSelect();
	return nStartPosX + (nIdx % nWidth) * self.CELL_LENGTH, nStartPosY + math.floor(nIdx / nWidth) * self.CELL_LENGTH;
end

-- 1|20;2|30;5   1号buff概率20   2号buff概率30   总共随机5次
function Obj:PraseDropInfo(szParam)
	local nCount = 0;
	local nTotalRate = 0;
	local tbInfo = {};
	local tbParam = Lib:SplitStr(szParam, ";");
	for nIdx, szInfo in ipairs(tbParam) do
		if nIdx == #tbParam then
			nCount = tonumber(szInfo);
			if not nCount then
				Log(string.format("[Obj] DropBuffer Error 1 szParam = %s", szParam));
				return;
			end
		else
			local nBuffId, nRate = string.match(szInfo, "^(%d+)|(%d+)$");
			if not nBuffId then
				Log(string.format("[Obj] DropBuffer Error 2 szParam = %s szInfo = %s", szParam, szInfo));
				return;
			end
			nBuffId = tonumber(nBuffId);
			nRate = tonumber(nRate);
			if not nBuffId or not self.tbBuffList[nBuffId] or not nRate then
				Log(string.format("[Obj] DropBuffer Error 3 szParam = %s szInfo = %s nBuffId = %s nRate = %s", szParam, szInfo, nBuffId or "nil", nRate or "nil"));
				return;
			end
			nTotalRate = nTotalRate + nRate;
			table.insert(tbInfo, {nBuffId = nBuffId, nRate = nRate});
		end
	end

	return nCount, nTotalRate, tbInfo;
end

function Obj:GetDropPos(nCount, nMapId, nX, nY)
	local nMaxRange = self.MAX_DROP_RANGE;
	if nCount <= 5 then
		nMaxRange = 2;
	end

	local nStartPosX, nStartPosY = nX - (nMaxRange * self.CELL_LENGTH), nY - (nMaxRange * self.CELL_LENGTH);
	local nWidth = nMaxRange * 2 + 1;
	local nCellCount = nWidth * nWidth;
	local fnSelect = Lib:GetRandomSelect(nCellCount);
	local tbResult = {};

	for i = 1, nCellCount do
		local nPosX, nPosY = self:GetPos(fnSelect, nStartPosX, nStartPosY, nWidth);
		local bCanUse = CheckBarrier(nMapId, nPosX, nPosY);
		if bCanUse and bCanUse == 1 then
			table.insert(tbResult, {nPosX, nPosY});
		end
	end

	local nLastCount = nCount - #tbResult;
	for i = 1, nLastCount do
		local nPosX, nPosY;
		for i = 1, nCellCount do
			nPosX, nPosY = self:GetPos(fnSelect, nStartPosX, nStartPosY, nWidth);
			local bCanUse = CheckBarrier(nMapId, nPosX, nPosY);
			if bCanUse and bCanUse == 1 then
				break;
			end
		end

		table.insert(tbResult, {nPosX, nPosY});
	end

	return tbResult;
end

function Obj:DropBuffer(nMapId, nX, nY, szParam)
	local nCount, nTotalRate, tbInfo = self:PraseDropInfo(szParam);
	if not nCount then
		return;
	end

	local tbPos = self:GetDropPos(nCount, nMapId, nX, nY);
	local fnPosSelect = Lib:GetRandomSelect(#tbPos);
	for i = 1, nCount do
		local nRandom = MathRandom(nTotalRate);
		for _, tbInfo in ipairs(tbInfo) do
			if nRandom > tbInfo.nRate then
				nRandom = nRandom - tbInfo.nRate;
			else
				local nPosIdx = fnPosSelect();
				AddObj(self.TYPE_BUFF, tbInfo.nBuffId, nMapId, tbPos[nPosIdx][1], tbPos[nPosIdx][2], self.tbBuffList[tbInfo.nBuffId].nDeathTime);
				break;
			end
		end
	end
end

--固定点掉落1个buff
function Obj:DropBufferInPos(nMapId, nX, nY, szParam)
	local _, nTotalRate, tbInfo = self:PraseDropInfo(szParam);
	local nRandom = MathRandom(nTotalRate);
	for _, tbInfo in ipairs(tbInfo) do
		if nRandom > tbInfo.nRate then
			nRandom = nRandom - tbInfo.nRate;
		else
			AddObj(self.TYPE_BUFF, tbInfo.nBuffId, nMapId, nX, nY, self.tbBuffList[tbInfo.nBuffId].nDeathTime);
			break;
		end
	end
end

function Obj:DropBufferInPosWhithType(nType, nMapId, nX, nY, szParam)
	local _, nTotalRate, tbInfo = self:PraseDropInfo(szParam);
	local nRandom = MathRandom(nTotalRate);
	for _, tbInfo in ipairs(tbInfo) do
		if nRandom > tbInfo.nRate then
			nRandom = nRandom - tbInfo.nRate;
		else
			AddObj(nType, tbInfo.nBuffId, nMapId, nX, nY, self.tbBuffList[tbInfo.nBuffId].nDeathTime);
			break;
		end
	end
end

function Obj:OnTrap(pPlayer, nType, nTemplateId)
	local bOK, bRet;
	local szCallBack = self.tbCallBack[nType];
	if szCallBack and self[szCallBack] then
		bOK, bRet = Lib:CallBack({self[szCallBack], self, pPlayer, nTemplateId});
	end

	if not bOK then
		Log("[Item.Obj] ERR ?? Unknow obj Info ", pPlayer.szName, nType, nTemplateId);
		return true;
	end

	return bRet and true or false;
end

function Obj:OnTrapBuff(pPlayer, nTemplateId)
	local tbBuff = self.tbBuffList[nTemplateId];
	if not tbBuff then
		Log("[Item.Obj] ERR ?? Unknow obj TemplateId ", pPlayer.szName, nType, nTemplateId);
		return true;
	end

	pPlayer.GetNpc().CastSkill(tbBuff.nSkillId, tbBuff.nSkillLevel, tbBuff.nParam1, tbBuff.nParam2);
	return true;
end

function Obj:OnTrapCheckFightMode(pPlayer, nTemplateId)
	if pPlayer.nFightMode ~= 1 then
		return false;
	end

	local tbBuff = self.tbBuffList[nTemplateId];
	if not tbBuff then
		Log("[Item.Obj] ERR ?? Unknow obj TemplateId ", pPlayer.szName, nType, nTemplateId);
		return true;
	end

	pPlayer.GetNpc().CastSkill(tbBuff.nSkillId, tbBuff.nSkillLevel, tbBuff.nParam1, tbBuff.nParam2);
	return true;
end

function Obj:OnTrapCheckFightModeAndRide(pPlayer, nTemplateId)
	if pPlayer.nFightMode ~= 1 then
		return false;
	end

	if pPlayer.GetActionMode() == Npc.NpcActionModeType.act_mode_ride then
		pPlayer.CenterMsg("骑马状态不可触发")
		return false
	end

	local tbBuff = self.tbBuffList[nTemplateId];
	if not tbBuff then
		Log("[Item.Obj] ERR ?? OnTrapCheckFightModeAndRide Unknow obj TemplateId ", pPlayer.szName, nType, nTemplateId);
		return true;
	end

	pPlayer.GetNpc().CastSkill(tbBuff.nSkillId, tbBuff.nSkillLevel, tbBuff.nParam1, tbBuff.nParam2);
	return true;
end