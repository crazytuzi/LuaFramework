require "Core.Role.Skill.Effects.AbsEffect";

AttackEffect = class("AttackEffect", AbsEffect)

function AttackEffect:New(skill, stage, caster, target)
	self = { };
	setmetatable(self, { __index = AttackEffect });
	if (self:_Init(skill, stage, caster, target)) then
		self:BindTarget(caster);
		return self;
	end
	--Warning(">>> skill:"..skill.id .."(" .. skill.name .. ") stage:"..stage.."("..self.info.key..") effect_id:"..self.info.effect_id.."，在skill_effect.lua没找到对应的特效配置")
	return nil;
end