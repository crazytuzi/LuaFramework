require "Core.Module.Pattern.BaseModule"
require "Core.Module.DaysRank.DaysRankMediator"
require "Core.Module.DaysRank.DaysRankProxy"
require "Core.Module.DaysRank.DaysRankManager"


DaysRankModule = BaseModule:New();
DaysRankModule:SetModuleName("DaysRankModule");
function DaysRankModule:_Start()
	self:_RegisterMediator(DaysRankMediator);
	self:_RegisterProxy(DaysRankProxy);
end

function DaysRankModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

