
Require("CommonScript/AsyncBattle/BasePvp.lua")

local tbParent = AsyncBattle:GetClass("BasePvp")
local tbBase = AsyncBattle:CreateClass("RankBattlePvp", "BasePvp")

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
	me.CallClientScript("Ui:OpenWindow", "RankPanel");
end

function tbBase:CalcResult()
	if self.tbNpcCount[2] == 0 then
		return 1;
	else	-- 攻方败
		return 0;
	end
end
