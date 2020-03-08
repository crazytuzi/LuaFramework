--[[
Require("CommonScript/AsyncBattle/BasePvp.lua")

local tbParent = AsyncBattle:GetClass("BasePvp")
local tbBase = AsyncBattle:CreateClass("RankBattleCrossPvp", "BasePvp")

function tbBase:GetEnemyAsyncData()
	local pAsync = KPlayer.GetRankCrossAsyncData(self.nEnemy);
	local tbAsync = {};
	local tbTargetInfo = RankBattleCross:GetApplyBattleInfo(self.nPlayerId, self.nEnemy)
	if not tbTargetInfo or not pAsync then
		Log("Error RankBattleCrossPvp GetEnemyAsyncData No ApplyBattleInfo", self.nPlayerId, self.nEnemy);
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
	tbAsync.GetBattleArray =function (nIdx)
		return pAsync.GetBattleArray(nIdx)
	end
	return tbAsync;
end

function tbBase:SyncBattleTimeInfo(pPlayer)
	tbParent.SyncBattleTimeInfo(self, pPlayer)
	if self.nTimer then
		pPlayer.CallClientScript("RankBattle:UpdateLeave", true)
	else
		pPlayer.CallClientScript("RankBattle:UpdateLeave", false)
	end
end

function tbBase:OnEnterMap()
	tbParent.OnEnterMap(self)
	me.CallClientScript("Ui:CloseWindow", "RankPanel");
end

function tbBase:OnLeaveMap()
	tbParent.OnLeaveMap(self)
	me.CallClientScript("RankBattle:UpdateLeave", false)
	me.CallClientScript("Ui:OpenWindow", "RankPanel", 2);
end

function tbBase:CalcResult()
	if self.tbNpcCount[2] == 0 then
		return 1;
	else	-- 攻方败
		return 0;
	end
end
]]
