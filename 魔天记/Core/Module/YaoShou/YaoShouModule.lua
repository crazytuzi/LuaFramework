require "Core.Module.Pattern.BaseModule"
require "Core.Module.YaoShou.YaoShouProxy"
require "Core.Module.YaoShou.YaoShouManager"

local YaoShouMediator = require "Core.Module.YaoShou.YaoShouMediator"
local YaoShouModule = BaseModule:New();
YaoShouModule:SetModuleName("YaoShouModule");
function YaoShouModule:_Start()
	self:_RegisterMediator(YaoShouMediator);
	self:_RegisterProxy(YaoShouProxy);
	--YaoShouManager.InitCfg();
end

function YaoShouModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

return YaoShouModule