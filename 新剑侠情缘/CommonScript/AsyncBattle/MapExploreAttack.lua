Require("CommonScript/AsyncBattle/AloneAsyncBattle.lua")

local tbMapExplore = AsyncBattle:CreateClass("MapExploreAttack", "AloneAsyncBattle");
tbMapExplore.tbEnemyPos = 
{
	{3778, 3477,},
	
	{3759, 2934,},
	{3774, 2490,},

}

tbMapExplore.tbSelfPos = 
{
	{2361, 2939,},
	
	{2352, 3439,},
	{2357, 2504,},
}

local tbDir = {12, 43}

function tbMapExplore:GetNpcDir(nCustomMode)
	return tbDir[nCustomMode]
end

function tbMapExplore:Init(nPlayerId, nEnemy, nMapId)
	AsyncBattle.tbClass["AloneAsyncBattle"].Init(self, nPlayerId, nEnemy, nMapId)	
end


function tbMapExplore:ShowResultUi(nResult)	
end
