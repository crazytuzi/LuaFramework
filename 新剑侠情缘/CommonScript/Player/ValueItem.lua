
-- 定义了 ValueItem 的类型
-- 这里新增类型的时候不要忘记在 C++ 中调整 Max_Value_Item_Type_Count 的值

ValueItem.tbAllType =
{
	["ValueDecorate"] = 1,
	["EqiupDebris"]  = 2,
	["ValueCompose"] = 3,
}

function ValueItem:Init()
	for szType, tInfo in pairs(self.tbAllType) do
		if self[szType].Init then
			self[szType]:Init();
		end
	end
end

function ValueItem:SetValue(pPlayer, szType, ...)
	if not self[szType] or not self[szType]["SetValue"] then
		Log("[ValueItem] SetValue ERR ?? self[szType] is nil ??", pPlayer.szName, szType, ...);
		return;
	end
	return self[szType]:SetValue(pPlayer, ...);
end

function ValueItem:GetValue(pPlayer, szType, ...)
	if not self[szType] or not self[szType]["GetValue"] then
		Log("[ValueItem] GetValue ERR ?? self[szType] is nil ??", pPlayer.szName, szType, ...);
		return;
	end

	return self[szType]:GetValue(pPlayer, ...);
end

function ValueItem:GetAllValue(pPlayer, szType, ...)
	if not self[szType] or not self[szType]["GetAllValue"] then
		Log("[ValueItem] GetAllValue ERR ?? self[szType] is nil ??", pPlayer.szName, szType, ...);
		return;
	end

	return self[szType]:GetAllValue(pPlayer, ...);
end

--------装备碎片-----------
ValueItem.EqiupDebris = ValueItem.EqiupDebris or {};
local tbEquipDebris = ValueItem.EqiupDebris;
tbEquipDebris.nType = ValueItem.tbAllType["EqiupDebris"];
function tbEquipDebris:Init()
end

--有 nBitIndex 时 value 是 bitValue
function tbEquipDebris:SetValue(pPlayer, nId, nBitIndex, nBitVal, nVal)
	if not MODULE_GAMESERVER then
		Log("[ValueItem] not MODULE_GAMESERVER !!");
		return;
	end

	if not Debris.tbItemIndex[nId] then
		Log("[ValueItem] tbEquipDebris:SetValue ERR ?? Debris.tbItemIndex(nId) is nil !!", pPlayer.szName, nId, nBitIndex, nBitVal, nVal);
		return;
	end

	if nVal then
		pPlayer.SetValueItem(self.nType, nId, nVal);
		return nVal
	end

	local nValue = pPlayer.GetValueItem(self.nType, nId);
	nValue = KLib.SetBit(nValue, nBitIndex, nBitVal)
	pPlayer.SetValueItem(self.nType, nId, nValue);
	return nValue
end

function tbEquipDebris:GetValue(pPlayer, nId, nBitIndex)
	local nValue = pPlayer.GetValueItem(self.nType, nId);
	if not nBitIndex then
		return nValue
	end
	if nValue ~= 0 then
		return KLib.GetBit(nValue, nBitIndex)
	end
	return nValue
end

function tbEquipDebris:GetAsyncKey(pAnsyPlayer, nItemId)
	local nTop = pAnsyPlayer.GetTopDebris()
	if nTop == 0 then
		return
	end
	local nAnsyIndex = 0
	local nKind = Debris.tbItemIndex[nItemId]
	if nKind == nTop then
		nAnsyIndex = Debris.AysncTop1From
	elseif nKind == nTop - 1 then
		nAnsyIndex = Debris.AysncTop2From
	end

	if nAnsyIndex == 0 then
		return;
	end

	local tbKindInfo = Debris.tbSettingLevel[nKind]
	for i, v in ipairs(tbKindInfo.tbItems) do
		if v == nItemId then
			return  nAnsyIndex + i;
		end
	end
end

function tbEquipDebris:GetAsyncValue(pAnsyPlayer, nItemId, nBitIndex)
	--如果没设置最高T级别，是不能取值的 异步记录的道具是根据 最高级往下排的，
	local nAnsyKey = self:GetAsyncKey(pAnsyPlayer, nItemId)
	if not nAnsyKey then
		return 0
	end
	local nValue = pAnsyPlayer.GetAsyncValue(nAnsyKey)
	if nValue == 0 then
		return nValue
	end
	if nBitIndex then
		return KLib.GetBit(nValue, nBitIndex)
	else
		return nValue;
	end
end

function tbEquipDebris:SetAsyncValue(pAnsyPlayer, nItemId, nBitIndex, nBitVal, nVal)
	local nAnsyKey = self:GetAsyncKey(pAnsyPlayer, nItemId)
	if not nAnsyKey then
		return
	end
	if nVal then
		pAnsyPlayer.SetAsyncValue(nAnsyKey, nVal)
		return
	end
	local nValue = pAnsyPlayer.GetAsyncValue(nAnsyKey)
	nValue = KLib.SetBit(nValue, nBitIndex, nBitVal)
	pAnsyPlayer.SetAsyncValue(nAnsyKey, nValue)
	return nValue
end

function tbEquipDebris:GetAllValue(pPlayer)
	return pPlayer.GetAllValueItem(self.nType);
end

--------value存值合成-----------
ValueItem.ValueCompose = ValueItem.ValueCompose or {};
local tbValueCompose = ValueItem.ValueCompose;
tbValueCompose.nType = ValueItem.tbAllType["ValueCompose"];

local nBaseId = 255;
function tbValueCompose:Init()

end

function tbValueCompose:ChangeValue(pPlayer, nSeqId, nPos, nCount)
	if not MODULE_GAMESERVER then
		Log("[ValueItem] not MODULE_GAMESERVER !!");
		return;
	end

	if not nSeqId then
		Log("[ValueItem] not nSeqId !!");
		return;
	end

	nCount = nCount or 1;
	if not nPos then
		nPos = self:RandomPos(pPlayer,nSeqId);
	end

	local nStroeId = self:GetStoreId(nSeqId,nPos);
	if not Compose.ValueCompose:CheckIsValidValue(nSeqId,nPos) then
		Log("[ValueItem] tbValueCompose:SetValue ERR ?? not Compose.ValueCompose:CheckIsValidValue(nSeqId,nPos) ??", pPlayer.szName,nSeqId,nPos);
		return;
	end

	local nOldValue = self:GetValue(pPlayer,nSeqId,nPos);
	local nNewValue = nOldValue + nCount;
	pPlayer.SetValueItem(self.nType, nStroeId, nNewValue);
	if nCount > 0 then
		pPlayer.CallClientScript("Compose.ValueCompose:OnValueChange", nSeqId, nPos, nOldValue, nNewValue);
	end

	return nNewValue;
end

function tbValueCompose:RandomPos(pPlayer,nSeqId)
	local isFinish,tbUnfinishPos,tbFinishPos = Compose.ValueCompose:CheckIsFinish(pPlayer,nSeqId);
	local nHit = -1;
	local nStoreId = -1;
	local nPos = 0;
	if isFinish then			--完成搜集随机随一个
		nHit = MathRandom(1,#tbFinishPos);
		nPos = tbFinishPos[nHit]
	else 						--从未完成的Value随一个
		nHit = MathRandom(1,#tbUnfinishPos);
		nPos = tbUnfinishPos[nHit];
	end
	return nPos
end

function tbValueCompose:GetStoreId(nSeqId,nPos)
	return nBaseId*nSeqId+nPos;
end

function tbValueCompose:GetValue(pPlayer,nSeqId,nPos)
	if not pPlayer or not nSeqId or not nPos then
		Log("tbValueCompose:GetValue not nSeqId or not nPos ==== ",nSeqId,nPos)
		return 0;
	end
	local nStroeId = self:GetStoreId(nSeqId,nPos);
	return pPlayer.GetValueItem(self.nType, nStroeId);
end

function tbValueCompose:GetAllValue(pPlayer)		--一个table
	return pPlayer.GetAllValueItem(self.nType);
end

-------- 聊天装饰（主题,泡泡等）-----------
ValueItem.ValueDecorate = ValueItem.ValueDecorate or {};
local tbValueDecorate = ValueItem.ValueDecorate;
tbValueDecorate.nType = ValueItem.tbAllType["ValueDecorate"];

local ChatDecorate = ChatMgr.ChatDecorate

function tbValueDecorate:SetValue(pPlayer, nId, nVal)
	if not MODULE_GAMESERVER then
		Log("[ValueItem] tbValueDecorate not MODULE_GAMESERVER !!");
		return;
	end

	assert(pPlayer,"[ValueItem] tbValueDecorate not pPlayer")

	if not nId or not nVal then
		Log("[ValueItem] tbValueDecorate valid param !!",pPlayer.dwID,pPlayer.szName,nId or 0,nVal or 0);
		return
	end

	if not ChatDecorate.tbTheme[nId] then
		Log("[ValueItem] tbValueDecorate not Theme !!",pPlayer.dwID,pPlayer.szName,nId,nVal);
		return
	end

	pPlayer.SetValueItem(self.nType, nId, nVal);

	if nVal ~= 0 then
		pPlayer.CallClientScript("ChatMgr.ChatDecorate:OnDecorateChange")
	end

	Log("[tbValueDecorate] SetValue ok",pPlayer.dwID,pPlayer.szName,nId,nVal,nOldValue,nNewValue)
	return true
end

function tbValueDecorate:GetValue(pPlayer,nId)
	return pPlayer.GetValueItem(self.nType, nId);
end

function tbValueDecorate:GetAllValue(pPlayer)
	return pPlayer.GetAllValueItem(self.nType);
end

