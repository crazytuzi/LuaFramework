require "Core.Module.Pattern.BaseModule"
require "Core.Module.FightSkillName.FightSkillNameMediator"
require "Core.Module.FightSkillName.FightSkillNameProxy"
FightSkillNameModule = BaseModule:New();
FightSkillNameModule:SetModuleName("FightSkillNameModule");
function FightSkillNameModule:_Start()
	self:_RegisterMediator(FightSkillNameMediator);
	self:_RegisterProxy(FightSkillNameProxy);
end

function FightSkillNameModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

