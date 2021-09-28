require "Core.Module.Pattern.BaseModule"
require "Core.Module.Rank.RankMediator"
require "Core.Module.Rank.RankProxy"
require "Core.Module.Rank.RankConst"

RankModule = BaseModule:New();
RankModule:SetModuleName("RankModule");
function RankModule:_Start()
	self:_RegisterMediator(RankMediator);
	self:_RegisterProxy(RankProxy);
end

function RankModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end
