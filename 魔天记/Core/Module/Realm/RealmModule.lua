require "Core.Module.Pattern.BaseModule"
require "Core.Module.Realm.RealmMediator"
require "Core.Module.Realm.RealmProxy"
RealmModule = BaseModule:New();
RealmModule:SetModuleName("RealmModule");
function RealmModule:_Start()
	self:_RegisterMediator(RealmMediator);
	self:_RegisterProxy(RealmProxy);
end

function RealmModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

