require "Core.Module.Pattern.BaseModule"
require "Core.Module.Notice.NoticeMediator"
require "Core.Module.Notice.NoticeProxy"
NoticeModule = BaseModule:New();
NoticeModule:SetModuleName("NoticeModule");
function NoticeModule:_Start()
	self:_RegisterMediator(NoticeMediator);
	self:_RegisterProxy(NoticeProxy);
end

function NoticeModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

