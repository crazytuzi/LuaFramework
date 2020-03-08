Require("CommonScript/AsyncBattle/AloneAsyncBattle.lua")

local tbRevenge = AsyncBattle:CreateClass("EnemyRevenge", "AloneAsyncBattle");
tbRevenge.tbEnemyPos = 
{
	{2944, 2335,},
	
	{2946, 2637,},
	{2944, 2062,},
}

tbRevenge.tbSelfPos = 
{
	{1763, 2339,},
	
	{1770, 2633,},
	{1752, 2057,},
}

local tbDir = {17, 46}

function tbRevenge:GetNpcDir(nCustomMode)
	return tbDir[nCustomMode]
end

function tbRevenge:Init(nPlayerId, nEnemy, nMapId)
	AsyncBattle.tbClass["AloneAsyncBattle"].Init(self, nPlayerId, nEnemy, nMapId)

	-- Ui:CloseWindow("SocialPanel")
end

function tbRevenge:ShowResultUi(nResult)
end


local tbWanted = AsyncBattle:CreateClass("AsyncWanted", "EnemyRevenge");

function tbWanted:ShowResultUi(nResult)
end