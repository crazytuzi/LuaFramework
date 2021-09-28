require "Core.Module.Pattern.BaseModule"
require "Core.Module.GuildWar.GuildWarMediator"
require "Core.Module.GuildWar.GuildWarProxy"
require "Core.Module.GuildWar.GuildWarNotes"

GuildWarModule = BaseModule:New();
GuildWarModule:SetModuleName("GuildWarModule");
function GuildWarModule:_Start()
	self:_RegisterMediator(GuildWarMediator);
    self:_RegisterProxy(GuildWarProxy);
end

function GuildWarModule:_Dispose()
	self:_RemoveMediator();
    self:_RemoveProxy();
end