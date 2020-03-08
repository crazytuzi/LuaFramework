
function AsyncBattle:Init()
	self.tbClass = self.tbClass or {};
	self.tbBattleArray = {}
end

AsyncBattle:Init()

function AsyncBattle:CreateClass(szClass, szBaseClass)
	if szBaseClass and self.tbClass[szBaseClass] then
		self.tbClass[szClass] = Lib:NewClass(self.tbClass[szBaseClass])
	else
		self.tbClass[szClass] = {}
	end

	return self.tbClass[szClass];
end


function AsyncBattle:OnAsyncBattle(szClass, nEnemy, nMapId, nBattleKey, ...)
--	if self.tbBattle then
--		Log("Error!! AsyncBattle Is Already exist");
--		return;
--	end
	if not self.tbClass[szClass] then
		Log("AsyncBattle Type is unexsit!! "..szClass);
		return;
	end
	self.tbBattleList = {}

	self.tbBattleList[nMapId] = Lib:NewClass(self.tbClass[szClass])
	self.tbBattleList[nMapId].nBattleKey = nBattleKey;
	self.tbBattleList[nMapId].szClassType = szClass;
	self.tbBattleList[nMapId]:Init(me.dwID, nEnemy, nMapId, ...)

	self.tbBattle = self.tbBattleList[nMapId];

	self:RegisterAsyncBattle(nMapId, nMapId, szClass)
end


function AsyncBattle:OnAsyncBattleArray(tbBattleArray)
	self.tbBattleArray[me.dwID] = tbBattleArray;	-- 跟玩家走

	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_BATTLEARRAY)
end

function AsyncBattle:GetBattleArray()
	return self.tbBattleArray[me.dwID] or {};
end

function AsyncBattle:SetBattleArray(nArrayIdx, nPosIdx)
	local tbBattleArray = self:GetBattleArray()
	if tbBattleArray[nArrayIdx] then
		local nOldPosIdx = tbBattleArray[nArrayIdx];
		for i, nCurPosIdx in ipairs(tbBattleArray) do
			if nPosIdx == nCurPosIdx then
				tbBattleArray[i] = nOldPosIdx
				break;
			end
		end
		tbBattleArray[nArrayIdx] = nPosIdx;
		RemoteServer.ChangeArrayRequest(tbBattleArray);
	end
end

function AsyncBattle:DoFun(szType, szFunctionName, ...)
	if self.tbClass[szType] and self.tbClass[szType][szFunctionName] then
		local tbClass = self.tbClass[szType]
		tbClass[szFunctionName](tbClass, ...)
	end
end

function AsyncBattle:OnEndBattle(nMapId, nResult, tbParams)
	if not self.tbBattle then
		return;
	end
	local tbResultParam;
	if self.tbBattle.GetResultParams then
		tbResultParam = self.tbBattle:GetResultParams()
	end
	Player:RemoteServer_Safe("AsyncBattleResult", self.tbBattle.nBattleKey, nResult, tbResultParam)
	--self:OnAsyncResult(pPlayer, nResult, tbBattleObj)

	if self.tbBattle.ShowResultUi then
		self.tbBattle:ShowResultUi(nResult);
	end
end

function AsyncBattle:RegisterAsyncBattle(nMapTemplateId, nMapId, szType)
	self.tbRegisterAsyncBattle = {nMapTemplateId, nMapId, szType}
end

function AsyncBattle:OnLoadMapEnd(nLoadMapId)
	if self.tbRegisterAsyncBattle then
		local nMapTemplateId, nMapId, szType = unpack(self.tbRegisterAsyncBattle)
		if nMapTemplateId == nLoadMapId then
			self.tbRegisterAsyncBattle = nil
			if nMapId > 0 then
				Player:RemoteServer_Safe("AsyncBattleReady", nMapId);
			end
			if self.tbClass[szType] and self.tbClass[szType].Client_OnMapLoaded then
				self.tbClass[szType]:Client_OnMapLoaded()
			end
		end
	end
end

function AsyncBattle:LeaveBattle()
	Player:RemoteServer_Safe("LeaveAsyncBattle");
end


