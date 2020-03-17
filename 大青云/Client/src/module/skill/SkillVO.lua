--[[
技能VO
lizhuangzhuang
2014年9月15日19:45:01
]]
_G.classlist['SkillVO'] = 'SkillVO'
_G.SkillVO = {};
SkillVO.objName = 'SkillVO'
function SkillVO:new(skillId,lv,gid)
	local obj = {};
	for k,v in pairs(SkillVO) do
		if type(v) == "function" then
			obj[k] = v;
		end
	end
	obj.skillId = skillId;
	obj.lv      = lv;
	obj.gid = gid;
	return obj;
end

function SkillVO:GetID()
	return self.skillId;
end

function SkillVO:GetLvl()
	if self.lv then
		return self.lv
	end

	local cfg = self:GetCfg();
	if not cfg then return 0; end
	return cfg.level;
	
end
----------获取技能的组id
function SkillVO:GetGid( )
	if self.gid then
		return self.gid
	else
		return 0
	end

end

function SkillVO:GetCfg()
	if self.skillId < 1000000000 then
		return t_skill[self.skillId];
	else
		return t_passiveskill[self.skillId];
	end
end

function SkillVO:GetGroup()
	local cfg = self:GetCfg();
	if not cfg then return 0; end
	return cfg.group_id;
end