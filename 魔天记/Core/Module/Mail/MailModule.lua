require "Core.Module.Pattern.BaseModule"
--require "Core.Module.Mail.MailMediator"
require "Core.Module.Mail.MailProxy"
MailModule = BaseModule:New();
MailModule:SetModuleName("MailModule");
function MailModule:_Start()
	--self:_RegisterMediator(MailMediator);
	self:_RegisterProxy(MailProxy);
end

function MailModule:_Dispose()
	--self:_RemoveMediator();
	self:_RemoveProxy();
end

