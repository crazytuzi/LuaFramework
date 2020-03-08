
Require("CommonScript/AsyncBattle/AloneAsyncBattle.lua")
local tbBase = AsyncBattle:GetClass("AloneAsyncBattle");
local tbPVP = AsyncBattle:CreateClass("HeroChallengePVP", "AloneAsyncBattle");

function tbPVP:GetEnemyAsyncData()
	return KPlayer.GetHeroAsyncData(self.nEnemy);
end

function tbPVP:OnLeaveMap()
	tbBase.OnLeaveMap(self)
	me.CallClientScript("Ui:OpenWindow", "HeroChallenge", true)
end

local tbPVE = AsyncBattle:CreateClass("HeroChallengePVE", "HeroChallengePVP");

function tbPVE:GetEnemyAsyncData()
	if not self.tbFakeAsyncData then
		self.tbFakeAsyncData = RankBattle:InitFakeAsyncData(self.nEnemy)
	end
	
	return self.tbFakeAsyncData;
end
