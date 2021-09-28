require "Core.Module.Pattern.BaseModule"
require "Core.Module.Lottery.LotteryMediator"
require "Core.Module.Lottery.LotteryProxy"
LotteryModule = BaseModule:New();
LotteryModule:SetModuleName("LotteryModule");
function LotteryModule:_Start()
	self:_RegisterMediator(LotteryMediator);
	self:_RegisterProxy(LotteryProxy);
end

function LotteryModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

