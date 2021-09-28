require "Core.Module.Pattern.BaseModule";
require "Core.Module.Login.LoginMediator";
require "Core.Module.Login.LoginProxy";

LoginModule = BaseModule:New();
LoginModule:SetModuleName("LoginModule");
function LoginModule:_Start()
	self:_RegisterMediator(LoginMediator);	
	self:_RegisterProxy(LoginProxy);
    
end

function LoginModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end
 