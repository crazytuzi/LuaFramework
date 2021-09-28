require "Core.Module.Pattern.BaseModule"
require "Core.Module.SignIn.SignInMediator"
require "Core.Module.SignIn.SignInProxy"
SignInModule = BaseModule:New();
SignInModule:SetModuleName("SignInModule");
function SignInModule:_Start()
	self:_RegisterMediator(SignInMediator);
	self:_RegisterProxy(SignInProxy);
end

function SignInModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

