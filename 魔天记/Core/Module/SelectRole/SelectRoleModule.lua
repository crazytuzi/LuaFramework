require "Core.Module.Pattern.BaseModule";

require "Core.Module.SelectRole.SelectRoleMediator";
require "Core.Module.SelectRole.SelectRoleProxy";

SelectRoleModule = BaseModule:New();
SelectRoleModule:SetModuleName("SelectRoleModule");
function SelectRoleModule:_Start()
	self:_RegisterMediator(SelectRoleMediator);	
	self:_RegisterProxy(SelectRoleProxy);
end

function SelectRoleModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

