require "Core.Module.Pattern.BaseModule"
require "Core.Module.NewestNotice.NewestNoticeProxy"
local NewestNoticeMediator = require "Core.Module.NewestNotice.NewestNoticeMediator"
local NewestNoticeModule = BaseModule:New();
NewestNoticeModule:SetModuleName("NewestNoticeModule");
function NewestNoticeModule:_Start()
	self:_RegisterMediator(NewestNoticeMediator);
	self:_RegisterProxy(NewestNoticeProxy);
end

function NewestNoticeModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

return NewestNoticeModule