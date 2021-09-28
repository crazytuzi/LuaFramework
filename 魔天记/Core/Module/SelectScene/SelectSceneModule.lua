require "Core.Module.Pattern.BaseModule"
require "Core.Module.SelectScene.SelectSceneMediator"
require "Core.Module.SelectScene.SelectSceneProxy"
SelectSceneModule = BaseModule:New();
SelectSceneModule:SetModuleName("SelectSceneModule");
function SelectSceneModule:_Start()
	self:_RegisterMediator(SelectSceneMediator);
	self:_RegisterProxy(SelectSceneProxy);
end

function SelectSceneModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

