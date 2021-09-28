require "Core.Module.Pattern.BaseModule"
require "Core.Module.XuanBao.XuanBaoProxy"
require "Core.Module.XuanBao.XuanBaoManager"

local XuanBaoMediator = require "Core.Module.XuanBao.XuanBaoMediator"
local XuanBaoModule = BaseModule:New();
XuanBaoModule:SetModuleName("XuanBaoModule");
function XuanBaoModule:_Start()
	self:_RegisterMediator(XuanBaoMediator);
	self:_RegisterProxy(XuanBaoProxy);
	XuanBaoManager.InitCfg();
end

function XuanBaoModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

return XuanBaoModule