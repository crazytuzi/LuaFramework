

AsyncBattle.ASYNC_BATTLE_MAP_TYPE = 
{
	city = 1,
	village = 1,
	fight = 1,
}

AsyncBattle.ASYNC_BATTLE_NONE 	= 0;
AsyncBattle.ASYNC_BATTLE_READY 	= 1;
AsyncBattle.ASYNC_BATTLE_GO 	= 2;
AsyncBattle.ASYNC_BATTLE_END 	= 3;


function AsyncBattle:Init()
	self.tbClass = self.tbClass or {};
	self.tbBattleArray = {}
	
	self.tbBattleType = self.tbBattleType or {};
	self.tbApplyingMap = {}		-- 正在申请的地图ID
	self.tbBattleList = {};
end

AsyncBattle:Init()

function AsyncBattle:CanStartAsyncBattle(pPlayer)
	local nTemplateId = pPlayer.nMapTemplateId
	local szMapType = Map:GetClassDesc(nTemplateId)
	if not self.ASYNC_BATTLE_MAP_TYPE[szMapType] then
		return;
	end
	
	if pPlayer.nFightMode == 1 then
		return;
	end
	
	return true;
end

function AsyncBattle:GetClass(szClass)
	return self.tbClass[szClass]
end

function AsyncBattle:CreateClass(szClass, szBaseClass)
	if szBaseClass and self.tbClass[szBaseClass] then
		self.tbClass[szClass] = Lib:NewClass(self.tbClass[szBaseClass])
	else
		self.tbClass[szClass] = {}
	end
	
	return self.tbClass[szClass];
end

function AsyncBattle:OnEnterMap(nMapId)
	if not self.tbBattleList[nMapId] then
		return;
	end
	
	self.tbBattleList[nMapId]:OnEnterMap();
end

function AsyncBattle:OnLeaveMap(nMapId)
	if not self.tbBattleList[nMapId] then
		return;
	end
	
	if self.tbBattleList[nMapId].OnLeaveMap then
		self.tbBattleList[nMapId]:OnLeaveMap()
	end
	self.tbBattleList[nMapId]:Close();
	
	self.tbBattleList[nMapId] = nil;
end

function AsyncBattle:OnLogin(nMapId)
	if not self.tbBattleList[nMapId] then
		return;
	end
	
	if self.tbBattleList[nMapId].OnLogin then
		self.tbBattleList[nMapId]:OnLogin()
	end
end

function AsyncBattle:AsyncBattleReady(pPlayer, nMapId)
	if not self.tbBattleList[nMapId] then
		return;
	end
	
	if self.tbBattleList[nMapId].nPlayerId ~= pPlayer.dwID then
		return
	end

	if self.tbBattleList[nMapId].OnPlayerReady then
		self.tbBattleList[nMapId]:OnPlayerReady();
	end
end
