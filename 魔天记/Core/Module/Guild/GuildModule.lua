require "Core.Module.Pattern.BaseModule"
require "Core.Module.Guild.GuildMediator"
require "Core.Module.Guild.GuildProxy"

GuildModule = BaseModule:New();
GuildModule:SetModuleName("GuildModule");
function GuildModule:_Start()
	self:_RegisterMediator(GuildMediator);
    self:_RegisterProxy(GuildProxy);
end

function GuildModule:_Dispose()
	self:_RemoveMediator();
    self:_RemoveProxy();
end