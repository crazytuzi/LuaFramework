--[[
Require("CommonScript/AsyncBattle/BasePvp.lua")

local tbParent = AsyncBattle:GetClass("BasePvp")
local tbBase = AsyncBattle:CreateClass("RankBattleCrossPve", "BasePvp")

function tbBase:GetEnemyAsyncData()
	if not self.tbFakeAsyncData then
		self.tbFakeAsyncData = RankBattleCross:InitFakeAsyncData(self.nEnemy)
	end
	
	return self.tbFakeAsyncData;
end

function tbBase:OnEnterMap()
	tbParent.OnEnterMap(self)
	me.CallClientScript("Ui:CloseWindow", "RankPanel");
end

function tbBase:OnLeaveMap()
	tbParent.OnLeaveMap(self)
	me.CallClientScript("Ui:OpenWindow", "RankPanel", 2);
end
]]