Require("CommonScript/AsyncBattle/BossRobBattle.lua");

local tbParent = AsyncBattle:GetClass("BossRobBattle");
local tbBase = AsyncBattle:CreateClass("CrossBossRobBattle", "BossRobBattle");

function tbBase:GetEnemyAsyncData()
	local pAsync = KPlayer.GetBossFightAsyncData(self.nEnemy);
	local tbAsync = {};
	local tbTargetInfo = Boss:ZCGetRobTargetInfo(self.nEnemy);
	if not tbTargetInfo or not pAsync then
		Log("Error BossRobBattle GetEnemyAsyncData No Target Info");
		return;
	end

	local szName = tbTargetInfo.szName;
	local nPortrait = tbTargetInfo.nPortrait;

	tbAsync.AddAsyncNpc = function (nMapId, nX, nY)
		return pAsync.AddAsyncNpcWithName(nMapId, nX, nY, szName);
	end;

	tbAsync.AddPartnerNpc = function ( ... )
		return pAsync.AddPartnerNpc(...);
	end;

	tbAsync.GetPlayerInfo = function ()
		return szName, nPortrait, pAsync.nLevel, pAsync.nFaction, pAsync.nSex;
	end;

	tbAsync.GetPartnerInfo = function ( ... )
		return pAsync.GetPartnerInfo(...);
	end;

	return tbAsync;
end