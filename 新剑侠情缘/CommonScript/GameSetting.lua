
GameSetting.MAX_COUNT_IN_BAG = 200;
GameSetting.MAX_COUNT_JUEYAO = 100;
GameSetting.MAX_COUNT_JUEXUE = 200;

GameSetting.tbGolbalObjStack = {};
function GameSetting:SetGlobalObj(pPlayer, pNpc, pItem)
	self.tbGolbalObjStack[#self.tbGolbalObjStack + 1] = {pPlayer = me, pNpc = him, pItem = it};

	me = pPlayer or me;
	him = pNpc or him;
	it = pItem or it;
end

function GameSetting:RestoreGlobalObj()
	local tb = self.tbGolbalObjStack[#self.tbGolbalObjStack];
	if (not tb) then
		assert(false);
	end

	me = tb.pPlayer or me;
	him = tb.pNpc or him;
	it = tb.pItem or it;
	self.tbGolbalObjStack[#self.tbGolbalObjStack] = nil;
end
