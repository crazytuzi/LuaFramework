require "Core.Module.Pattern.BaseModule"
require "Core.Module.Yaoyuan.YaoyuanMediator"
require "Core.Module.Yaoyuan.YaoyuanProxy"
YaoyuanModule = BaseModule:New();
YaoyuanModule:SetModuleName("YaoyuanModule");
function YaoyuanModule:_Start()
	self:_RegisterMediator(YaoyuanMediator);
	self:_RegisterProxy(YaoyuanProxy);
end

function YaoyuanModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

