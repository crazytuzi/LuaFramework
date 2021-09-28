require "Core.Module.Pattern.BaseModule"
require "Core.Module.Skill.SkillMediator"
require "Core.Module.Skill.SkillProxy"
SkillModule = BaseModule:New();
SkillModule:SetModuleName("SkillModule");
function SkillModule:_Start()
	self:_RegisterMediator(SkillMediator);
	self:_RegisterProxy(SkillProxy);
end

function SkillModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

