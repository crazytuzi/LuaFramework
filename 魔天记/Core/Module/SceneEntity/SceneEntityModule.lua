require "Core.Module.Pattern.BaseModule"
require "Core.Module.SceneEntity.SceneEntityProxy"
local SceneEntityMediator = require "Core.Module.SceneEntity.SceneEntityMediator"
local SceneEntityModule = BaseModule:New();
SceneEntityModule:SetModuleName("SceneEntityModule");
function SceneEntityModule:_Start()
	self:_RegisterMediator(SceneEntityMediator);
	self:_RegisterProxy(SceneEntityProxy);
end

function SceneEntityModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

return SceneEntityModule