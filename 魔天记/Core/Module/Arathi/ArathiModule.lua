require "Core.Module.Pattern.BaseModule"
require "Core.Module.Arathi.ArathiMediator"
require "Core.Module.Arathi.ArathiProxy"
require "Core.Module.Arathi.ArathiNotes"

ArathiModule = BaseModule:New();
ArathiModule:SetModuleName("ArathiModule");
function ArathiModule:_Start()
	self:_RegisterMediator(ArathiMediator);
	self:_RegisterProxy(ArathiProxy);
end

function ArathiModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end
