--[[
技能Tips Util
lizhuangzhuang
2014年8月27日13:07:40
]]

_G.SkillTipsUtil = {};

--技能转换Map
SkillTipsUtil.Effect_SkillMap = {
	consum_num = "{u}",
	prep_time = "{maxt}",
	combo_time = "{maxt}",
	min_combo = "{mint}",
	chant_time = "{maxt}",
	chant_inter = "{min}",
	triggerOdds = "{per}",
	multi_time = "{maxt}",
}
--Effect转换map (技能特殊效果单独解析e1-e5)
SkillTipsUtil.Effect_EffectMap = {
	distance = "{l}",
	max_num = "{n}",
	damage = "{p}",
	percent = "{a}",
	ex_damage = "{b}",
	once_search_time = "{t}",
}

--获取技能的效果
function SkillTipsUtil:GetSkillEffectStr(skillId)
	local cfg = t_skill[skillId];
	if not cfg then
		cfg = t_passiveskill[skillId];
	end
	if not cfg then return ""; end
	local params = {};
	--解析技能表
	for k,v in pairs(self.Effect_SkillMap) do
		if cfg[k] then
			if not params[v] then params[v] = 0; end 
			params[v] = params[v] + tonumber(cfg[k]);
		end
	end
	--解析Effect
	local effects = {cfg.effect_1,cfg.effect_2,cfg.effect_3};
	for i,effectId in ipairs(effects) do
		if t_effect[effectId] then
			local effectCfg = t_effect[effectId];
			for k,v in pairs(self.Effect_EffectMap) do
				if effectCfg[k] then
					if not params[v] then params[v] = 0; end
					local val = tonumber(effectCfg[k]);
					if not val then val=0; end
					params[v] = params[v] + val;
				end
			end
			--单独解析特殊效果
			params["{e"..tostring(effectCfg.skill_eff).."}"] = effectCfg.skill_param;
		end
	end
	--将特殊值除1000
	for k,v in pairs(params) do
		if k=="{maxt}" or k=="{mint}" or k=="{min}" or k=="{per}" or k=="{t}" then
			params[k] = string.format("%0.1f",v/1000);
		end
		if k=="{a}" then
			params[k] = string.format("%0.1f",v);
		end
	end
	--将参数转换进描述文字
	local str = cfg.effectStr;
	-- trace(str)
	-- print("+++++++++++++++++++++++++")
	if string.find(str,"@") then
		local t = split(str,"@");
		if t[MainPlayerModel.humanDetailInfo.eaProf] then
			str = t[MainPlayerModel.humanDetailInfo.eaProf];
		end
	end
	str = string.gsub(str,"{[a-z0-9.%%]+}",
		function(s)
			if params[s] then
				-- trace(params[s])
				-- print("-------------------------")
				return "<font color='#00ff00'>" ..params[s].. "</font>";
			elseif s=="{%}" then
				return "<font color='#00ff00'>%</font>"
			else
				s = string.sub(s,2,#s-1);
				return "<font color='#00ff00'>" ..s.. "</font>";
			end
		end);
	-- trace(str)
	return str;
end

function SkillTipsUtil:GetAdditiveDesc(skillId,type,id)
	local cfg = t_skill[skillId];
	if not cfg then
		cfg = t_passiveskill[skillId];
	end
	if not cfg then return ""; end
	local str = cfg.describe;
	if not str then return ""; end
	if type == SkillConsts.ENUM_ADDITIVE_TYPE.TIANSHEN then
		local tianshen = t_tianshen[id];
		if not tianshen then
			return str;
		end
		str = string.gsub(str,"{[a-z0-9.%%]+}",
			function(s)
				return tianshen.name;
			end
		);
	end
	return str;
end