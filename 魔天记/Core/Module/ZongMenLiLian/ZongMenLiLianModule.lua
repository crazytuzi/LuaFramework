require "Core.Module.Pattern.BaseModule"
require "Core.Module.ZongMenLiLian.ZongMenLiLianMediator"
require "Core.Module.ZongMenLiLian.ZongMenLiLianProxy"
ZongMenLiLianModule = BaseModule:New();
ZongMenLiLianModule:SetModuleName("ZongMenLiLianModule");
function ZongMenLiLianModule:_Start()
	self:_RegisterMediator(ZongMenLiLianMediator);
	self:_RegisterProxy(ZongMenLiLianProxy);
end

function ZongMenLiLianModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

