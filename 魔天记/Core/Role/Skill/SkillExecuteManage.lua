require "Core.Role.Skill.Effects.ExistEffect";
require "Core.Role.Skill.Effects.LinkEffect";
require "Core.Role.Skill.Effects.RangeEffect";

require "Core.Role.Skill.Effects.AttackEffect";
require "Core.Role.Skill.Effects.FlyEffect";
require "Core.Role.Skill.Effects.HitEffect";

require "Core.Role.Skill.Scripts.AntiChargeScript"
require "Core.Role.Skill.Scripts.ChargeScript"
require "Core.Role.Skill.Scripts.ClockwiseDmgScript"
require "Core.Role.Skill.Scripts.GhostStepScript"
require "Core.Role.Skill.Scripts.PosChargeScript"
require "Core.Role.Skill.Scripts.StraybulletScript"
require "Core.Role.Skill.Scripts.TeleportScript"
require "Core.Role.Skill.Scripts.MoveinlineScript"
require "Core.Role.Skill.Scripts.ShoveScript"
require "Core.Role.Skill.Scripts.GatherScript"
require "Core.Role.Skill.Scripts.VanishScript"
require "Core.Role.Skill.Scripts.AssaultScript"
require "Core.Role.Skill.Scripts.ClockwiseScript"

SkillExecuteManage = class("SkillExecuteManage")

SkillExecuteManage.MaxEffectNum = QualitySetting.GetEffectMax();
SkillExecuteManage.CurrEffectNum = 0
SkillExecuteManage._effects = { };
SkillExecuteManage._scripts = { };
local filterType = { "PlayerController", "PetController", "PuppetController" }
local insert = table.insert

function SkillExecuteManage._AddEffect(effect)
	if (effect) then
		effect:AddListener(SkillExecuteManage._OnEffectDisposeHandler);
		insert(SkillExecuteManage._effects, effect)
		SkillExecuteManage.CurrEffectNum = SkillExecuteManage.CurrEffectNum + 1
	end
end

function SkillExecuteManage._OnEffectDisposeHandler(effect)
	if (effect) then
		for i, v in pairs(SkillExecuteManage._effects) do
			if (v == effect) then				
				table.remove(SkillExecuteManage._effects, i);
				SkillExecuteManage.CurrEffectNum = SkillExecuteManage.CurrEffectNum - 1
				effect = nil;
				return;
			end
		end
	end
end

function SkillExecuteManage._AddScript(script)
	if (script and not script.isFinish) then
		script:AddListener(SkillExecuteManage._OnScriptDisposeHandler);
		insert(SkillExecuteManage._scripts, script)
	end
end

function SkillExecuteManage._OnScriptDisposeHandler(script)
	if (script) then
		for i, v in pairs(SkillExecuteManage._scripts) do
			if (v == script) then
				table.remove(SkillExecuteManage._scripts, i);
				script = nil;
				return;
			end
		end
	end
end


function SkillExecuteManage.Clear()
	-- 清理技能脚本
	for i, v in pairs(SkillExecuteManage._scripts) do
		v:AddListener(nil);
		v:Dispose();
		v = nil;
	end
	SkillExecuteManage._scripts = { };

	-- 清理技能特效
	for i, v in pairs(SkillExecuteManage._effects) do
		if (v.transform) then
			v:AddListener(nil);
			v:Dispose();
			v = nil;
		end
	end
	SkillExecuteManage._effects = { };
	SkillExecuteManage.CurrEffectNum = 0
end

function SkillExecuteManage.ExecuteScript(skillStage)
	if (skillStage) then
		local scriptName = skillStage.info.script;
		local script = nil;
		if (scriptName == "charge") then
			script = ChargeScript:New(skillStage);
		elseif (scriptName == "anti_charge") then
			script = AntiChargeScript:New(skillStage);
		elseif (scriptName == "clockwise_dmg") then
			script = ClockwiseDmgScript:New(skillStage);
		elseif (scriptName == "pos_charge") then
			script = PosChargeScript:New(skillStage);
		elseif (scriptName == "ghoststep") then
            if (skillStage.role and skillStage.role.target and skillStage.role.target.transform) then
			    script = GhostStepScript:New(skillStage);
            end
		elseif (scriptName == "straybullet") then
			script = StraybulletScript:New(skillStage);
		elseif (scriptName == "teleport") then
			script = TeleportScript:New(skillStage);
		elseif (scriptName == "gather") then
			script = GatherScript:New(skillStage);
		elseif (scriptName == "shove") then
			script = ShoveScript:New(skillStage);
		elseif (scriptName == "moveinline") then
			script = MoveinlineScript:New(skillStage);
		elseif (scriptName == "vanish") then
			script = VanishScript:New(skillStage);
		elseif (scriptName == "assault") then
			script = AssaultScript:New(skillStage);
		elseif (scriptName == "clockwise") then
			script = ClockwiseScript:New(skillStage);		
		end
		SkillExecuteManage._AddScript(script)
		return script;
	end
	return nil;
end

function SkillExecuteManage.CanExecuteEffect(caster)
	if SkillExecuteManage.MaxEffectNum > SkillExecuteManage.CurrEffectNum or caster.id == PlayerManager.playerId then return true end
end

function SkillExecuteManage.ExecuteAttackEffect(skill, stage, caster, target)
	if (skill and stage and caster) then
		--限制特效数量
		if (not SkillExecuteManage.CanExecuteEffect(caster)) then return nil end;

		local isEffectShow = AutoFightManager.GetBaseSettingConfig().showSkillEffect

		if (not isEffectShow) then
			if (table.contains(filterType, caster.__cname)) then
				return
			end
		end
		local stageInfo = skill.stages[stage];
		if (stageInfo and stageInfo.effect_id ~= "") then
			local eff = nil;
			if (stageInfo.range_type == 2 or stageInfo.range_type == 7) then
				eff = FlyEffect:New(skill, stage, caster, target);
			else
				eff = AttackEffect:New(skill, stage, caster, target);
			end
			if (eff) then
				SkillExecuteManage._AddEffect(eff);
				return eff;
			end
		end
	end
	return nil;
end

function SkillExecuteManage.ExecuteHitEffect(skill, stage, caster, target)
	if (skill and stage and caster) then
		--限制特效数量
		if (not SkillExecuteManage.CanExecuteEffect(caster)) then return nil end;

		local isEffectShow = AutoFightManager.GetBaseSettingConfig().showSkillEffect
		if (not isEffectShow) then
			if (table.contains(filterType, caster.__cname)) then
				return
			end
		end
		local stageId = stage or 1;
		local stageInfo = skill:GetStage(stageId);
		if (stageInfo and stageInfo.hit_effect_id ~= "") then
			--保证目标只有一个相同命中特效
			for i,v in pairs(SkillExecuteManage._effects) do
				if (v.__cname=="HitEffect" and v.info.hit_effect_id == stageInfo.hit_effect_id and v.target == target) then return nil end
			end

			 local eff = HitEffect:New(skill, stageId, caster, target);
			 if (eff) then
			 	SkillExecuteManage._AddEffect(eff);
			 	return eff;
			 end
		end
	end
	return nil;
end

function SkillExecuteManage.ExecuteExistEffect(role, to, src)
	local eff = ExistEffect:New(role, to, src);
	SkillExecuteManage._AddEffect(eff);
	return eff;
end

function SkillExecuteManage.ExecuteLinkEffect(role, to, src)
	local eff = LinkEffect:New(role, to, src);
	SkillExecuteManage._AddEffect(eff);
	return eff;
end

function SkillExecuteManage.ExecuteRangeEffect(skill, role)
	local eff = RangeEffect:New(skill, role);
	SkillExecuteManage._AddEffect(eff);
	return eff;
end