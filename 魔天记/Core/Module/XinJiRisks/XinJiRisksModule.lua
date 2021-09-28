require "Core.Module.Pattern.BaseModule"
require "Core.Module.XinJiRisks.XinJiRisksProxy"
local XinJiRisksMediator = require "Core.Module.XinJiRisks.XinJiRisksMediator"
local XinJiRisksModule = BaseModule:New();
XinJiRisksModule:SetModuleName("XinJiRisksModule");
function XinJiRisksModule:_Start()
	self:_RegisterMediator(XinJiRisksMediator);
	self:_RegisterProxy(XinJiRisksProxy);
end

function XinJiRisksModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

return XinJiRisksModule