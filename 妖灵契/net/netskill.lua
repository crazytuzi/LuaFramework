module(..., package.seeall)

--GS2C--

function GS2CLoginSkill(pbdata)
	local school = pbdata.school --门派技能
	local cultivate = pbdata.cultivate --修炼技能
	--todo
	g_SkillCtrl:LoginSchoolSkill(table.copy(pbdata))
end

function GS2CRefreshSkill(pbdata)
	local skill_info = pbdata.skill_info
	--todo
	g_SkillCtrl:RefreshSchoolSkill(skill_info)
end

function GS2CRefreshCultivateSKill(pbdata)
	local skill_info = pbdata.skill_info
	--todo
	g_SkillCtrl:RefreshCultivateSkill(skill_info)
end


--C2GS--

function C2GSLearnSkill(type, sk)
	local t = {
		type = type,
		sk = sk,
	}
	g_NetCtrl:Send("skill", "C2GSLearnSkill", t)
end

function C2GSLearnCultivateSkill(sk, count)
	local t = {
		sk = sk,
		count = count,
	}
	g_NetCtrl:Send("skill", "C2GSLearnCultivateSkill", t)
end

function C2GSWashSchoolSkill(cost_type)
	local t = {
		cost_type = cost_type,
	}
	g_NetCtrl:Send("skill", "C2GSWashSchoolSkill", t)
end

