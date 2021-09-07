CommonDataManager = CommonDataManager or {}

-- 匹配阶数（文字）
CommonDataManager.DAXIE =  { [0] = "零", "十", "一", "二", "三", "四", "五", "六", "七", "八", "九" }
CommonDataManager.FANTI =  { [0] = "零", "拾", "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖" }

CommonDataManager.attrview_t = {
								{"hp", "max_hp"}, {"gongji", "gong_ji"}, 
								{"fangyu", "fang_yu"}, {"mingzhong", "ming_zhong"}, 
								{"shanbi", "shan_bi"}, {"baoji", "bao_ji"}, 
								{"jianren", "jian_ren"}, {"per_mingzhong", "per_mingzhong"}, 
								{"per_shanbi", "per_shanbi"}, {"per_jingzhun", "per_jingzhun"}, 
								{"per_baoji", "per_baoji"}, {"per_baoji_hurt", "per_baoji_hurt"},
								{"per_kangbao", "per_kangbao"}, {"per_pofang", "per_pofang"},
								{"per_mianshang", "per_mianshang"}, {"per_xixue", "per_xixue"},
								{"per_stun", "per_stun"}
							}

CommonDataManager.suit_att_t = {{"maxhp"}, {"gongji"}, {"fangyu"}, {"mingzhong"}, {"shanbi"}, {"baoji"}, {"jianren"}, {"maxhp_attr"}, {"gongji_attr"}, {"fangyu_attr"}, {"mingzhong_attr"}, {"shanbi_attr"}, {"jianren_attr"}, {"baoji_attr"}}
CommonDataManager.base_sort_list = {["gongji"] = 1, ["gong_ji"] = 1, ["fangyu"] = 2, ["fang_yu"] = 2, 
									["hp"] = 3, ["max_hp"] = 3, ["maxhp"] = 3, ["mingzhong"] = 4, ["ming_zhong"] = 4,
									["shanbi"] = 5, ["shan_bi"] = 5, ["baoji"] = 6, ["bao_ji"] = 6, 
									["jianren"] = 7, ["jian_ren"]= 7, ["ignore_fangyu"] = 8,
									["hurt_increase"] = 9, ["hurt_reduce"] = 10,
									["pvp_hurt_increase_per"] = 11, ["pvp_hurt_reduce_per"] = 12,
									["xixue_per"] = 13, ["stun_per"] = 14,
									["ice_master"] = 15, ["fire_master"] = 16, 
									["thunder_master"] = 17, ["poison_master"] = 18}

CommonDataManager.AttrViewList = {
	"maxhp", "gongji", "fangyu", "baoji", "mingzhong", "shanbi", "jianren", "hurt_increase", "hurt_reduce", "ice_master", "fire_master", "thunder_master", "poison_master", 
}

CommonDataManager.SkillAtt = {
	["gongji"] = 0,
	["fangyu"] = 1,
	["maxhp"] = 2,
	["ignore_fangyu"] = 3,
	["hurt_increase"] = 4,
	["hurt_reduce"] = 5,
	["ice_master"] = 6,
	["fire_master"] = 7,
	["thunder_master"] = 8,
	["poison_master"] = 9,
	["gongji_per"] = 10,
	["fangyu_per"] = 11,
	["maxhp_per"] = 12,
}

CommonDataManager.no_line_sort_list = {
		["gongji"] = 1,
		["maxhp"] = 3,
		["fangyu"] = 2,
		["mingzhong"] = 4,
		["shanbi"] = 5,
		["baoji"] = 6,
		["jianren"] = 7,
		["per_jingzhun"] = 26,
		["per_gongji"] = 27,
		["per_maxhp"] = 28,
		["fujia_shanghai"] = 29,
		["ignore_fangyu"] = 8,
		["hurt_increase"] = 9,
		["hurt_reduce"] = 10,
		["ice_master"] = 11,
		["fire_master"] = 12,
		["thunder_master"] = 13,
		["poison_master"] = 14,
		["per_mingzhong"] = 15,
		["per_shanbi"] = 16,
		["per_baoji"] = 17,
		["per_baoji_hurt"] = 19,
		["per_pofang"] = 22,
		["per_mianshang"] = 23,
		["per_pvp_hurt_increase"] = 20,
		["per_pvp_hurt_reduce"] = 21,
		["per_xixue"] = 24,
		["per_stun"] = 25,
		["per_kangbao"] = 18,
		["attr_percent"] = 30,
}

local ROLE_ATTR_PER = 0.0001
function CommonDataManager.GetDaXie(num, type, show_ten)
	if nil == num or num < 0 or num >= 100 then
		return ""
	end
	local result = ""
	local index1 = num
	local index2 = -1
	if 10 == num then
		index1 = 0
	elseif num > 10 then
		index1 = math.floor(num / 10)
		index1 = (1 == index1) and 0 or index1
		index2 = num % 10
	elseif num == 0 then
		index1 = -1
	end

	local table = {}
	if nil == type then
		table = CommonDataManager.DAXIE
	else
		table = CommonDataManager.FANTI
	end

	result = table[index1 + 1]

	if index2 > -1 then
		if show_ten and index1 ~= 0 and index2 ~= 0 then
			result = result .. table[1] .. table[index2 + 1]
		else
			result = result .. table[index2 + 1]
		end
	end

	return result
end

--转换财富
function CommonDataManager.ConverMoney(value)
	value = tonumber(value)
	if value >= 100000 and value < 100000000 then
		local result = math.floor(value / 10000) .. Language.Common.Wan
		return result
	end

	if value >= 100000000 then
		local result = math.floor(value / 100000000) .. Language.Common.Yi
		return result
	end
	return value
end

--转换
function CommonDataManager.ConverNum(value)
	value = tonumber(value)
	if value >= 10000 and value < 100000000 then
		local result = math.floor(value / 1000)/10 .. Language.Common.Wan
		return result
	end

	if value >= 100000000 then
		local result = math.floor(value / 10000000)/10 .. Language.Common.Yi
		return result
	end
	return value
end

-- 转换血量
function CommonDataManager.ConverHP(value)
	local value = tonumber(value)
	if value >= 10 ^ 5 and value < 10 ^ 8 then
		value = math.floor(value / 10 ^ 4) .. Language.Common.Wan
	elseif value >= 10 ^ 8 then
		value = string.format("%.2f", value / 10 ^ 8) .. Language.Common.Yi
	end
	return value
end

--战力值
-- is_next 是否下一未获得属性（默认 false 可不传）
-- own_attr 下一属性中已拥有部分属性的
-- is_others 是否其它人（默认 false 可不传）
-- function CommonDataManager.GetCapability(value, is_next, own_attr, is_others)
-- 	value = CommonDataManager.GetAttributteByClass(value)
-- 	local capability = 0
-- 	if is_others then
-- 		capability = CommonDataManager.GetCapabilityCalculation(value)
-- 	else
-- 		local role_less_cap, role_more_cap = 0, 0
-- 		if is_next then
-- 			if own_attr then
-- 				own_attr = CommonDataManager.GetAttributteByClass(own_attr)
-- 				local less_attr = CommonDataManager.LerpAttributeAttr(own_attr, CommonDataManager.GetMainRoleAttr())
-- 				role_less_cap = CommonDataManager.GetCapabilityCalculation(less_attr)
-- 				role_more_cap = CommonDataManager.GetCapabilityCalculation(CommonDataManager.AddAttributeAttr(value, less_attr))
-- 			else
-- 				role_less_cap = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetMainRoleAttr())
-- 				role_more_cap = CommonDataManager.GetCapabilityCalculation(CommonDataManager.AddAttributeAttr(value, CommonDataManager.GetMainRoleAttr()))
-- 			end
-- 		else
-- 			role_less_cap = CommonDataManager.GetCapabilityCalculation(CommonDataManager.LerpAttributeAttr(value, CommonDataManager.GetMainRoleAttr()))
-- 			role_more_cap = CommonDataManager.GetCapabilityCalculation(CommonDataManager.GetMainRoleAttr())
-- 		end
-- 		capability = role_more_cap - role_less_cap
-- 	end
-- 	return capability
-- end
function CommonDataManager.GetCapability(value)
	local capability = CommonDataManager.GetCapabilityCalculation(value)
	return capability
end

function CommonDataManager.GetMainRoleAttr()
	local attribute = CommonStruct.Attribute()
	local data = PlayerData.Instance and PlayerData.Instance:GetRoleVo() or {}
	attribute.gong_ji = data.gong_ji or 0
	attribute.max_hp = data.max_hp or 0
	attribute.fang_yu = data.fang_yu or 0
	attribute.ming_zhong = data.ming_zhong or 0
	attribute.shan_bi = data.shan_bi or 0
	attribute.bao_ji = data.bao_ji or 0
	attribute.jian_ren = data.jian_ren or 0
	attribute.ignore_fangyu = data.ignore_fangyu or 0						-- 无视防御
	attribute.hurt_increase = data.hurt_increase or 0						-- 伤害追加
	attribute.hurt_reduce = data.hurt_reduce or 0							-- 伤害减免
	attribute.ice_master = data.ice_master or 0								-- 冰精通
	attribute.fire_master = data.fire_master or 0							-- 火精通
	attribute.thunder_master = data.thunder_master or 0						-- 雷精通
	attribute.poison_master = data.poison_master or 0						-- 毒精通

	attribute.per_mingzhong = data.per_mingzhong or 0						-- 命中率
	attribute.per_shanbi = data.per_shanbi or 0								-- 闪避率
	attribute.per_baoji = data.per_baoji or 0								-- 暴击率
	attribute.per_baoji_hurt = data.per_baoji_hurt or 0						-- 暴击伤害率
	attribute.per_pofang = data.per_pofang or 0								-- 增伤率
	attribute.per_mianshang = data.per_mianshang or 0						-- 免伤率
	attribute.per_pvp_hurt_increase = data.per_pvp_hurt_increase or 0		-- pvp伤害增加率
	attribute.per_pvp_hurt_reduce = data.per_pvp_hurt_reduce or 0			-- pvp受伤减免率
	attribute.per_xixue = data.per_xixue or 0								-- 吸血率
	attribute.per_stun = data.per_stun or 0									-- 击晕率
	attribute.per_kangbao = data.per_kangbao or 0							-- 抗暴率
	
	return attribute
end


-- 战力值计算（外部调用CommonDataManager.GetCapability）
-- value必须为格式化后的table
function CommonDataManager.GetCapabilityCalculation(value)
	if nil == value then
		return 0
	end

	local gongji = (value.gong_ji or value.gongji or value.attack or 0)
	local fangyu = (value.fang_yu or value.fangyu or 0)
	local max_hp = (value.max_hp or value.maxhp or value.hp or 0)
	local mingzhong = (value.ming_zhong or value.mingzhong or 0)
	local shanbi = (value.shan_bi or value.shanbi or 0)
	local baoji = (value.bao_ji or value.baoji or 0)
	local jianren = (value.jian_ren or value.jianren or 0)
	local ignore_fangyu = (value.ignore_fangyu or 0)
	local hurt_increase = (value.hurt_increase or 0)
	local hurt_reduce = (value.hurt_reduce or 0)
	local ice_master = (value.ice_master or 0)
	local fire_master = (value.fire_master or 0)
	local thunder_master = (value.thunder_master or 0)
	local poison_master = (value.poison_master or 0)
	local mingzhong_per = (value.per_mingzhong or 0) * ROLE_ATTR_PER
	local shanbi_per = (value.per_shanbi or 0) * ROLE_ATTR_PER
	local baoji_per = (value.per_baoji or 0) * ROLE_ATTR_PER
	local kangbao_per = (value.per_kangbao or 0) * ROLE_ATTR_PER
	local pvp_hurt_increase_per = (value.per_pvp_hurt_increase or 0) * ROLE_ATTR_PER
	local pvp_hurt_reduce_per = (value.per_pvp_hurt_reduce or 0) * ROLE_ATTR_PER
	local hurt_increase_per = (value.per_pofang or 0) * ROLE_ATTR_PER
	local hurt_reduce_per = (value.per_mianshang or 0) * ROLE_ATTR_PER
	local xixue_per = (value.per_xixue or 0) * ROLE_ATTR_PER
	local stun_per = (value.per_stun or 0) * ROLE_ATTR_PER

	cap = gongji * 0.2 +																---攻击		
		fangyu * 0.2 +																----防御
		max_hp * 0.01 +																-----气血
		mingzhong * 0.6 +																-----命中
		shanbi * 0.6 +																-----闪避
		baoji * 0.6 +																	-----暴击
		jianren * 0.6 +																-----抗暴
		ignore_fangyu * 0.2 +															---无视防御
		hurt_increase * 0.4 +															-----伤害追加
		hurt_reduce * 0.4 +															-----伤害减免
		ice_master * 20 +															-----冰精通
		fire_master * 20 +															----火精通
		thunder_master * 20 +														----雷精通
		poison_master * 20 +														-----毒精通
		mingzhong_per * 60000 +														-----命中率
		shanbi_per * 60000 +															-----闪避率
		baoji_per * 60000 +															-----暴击率
		kangbao_per * 60000 +															-----抗暴率
		pvp_hurt_increase_per * 100000 +													------PvP伤害增加率
		pvp_hurt_reduce_per * 100000 +														------PvP受伤减免率
		hurt_increase_per * 160000 +														------伤害增加率
		hurt_reduce_per * 160000 +															------受伤减免率
		xixue_per * 100000 +																------吸血率
		stun_per * 100000																	-----击晕率

	return math.floor(cap)
end


-- 两个属性相加
function CommonDataManager.AddAttributeAttr(attribute1, attribute2)
	local m_attribute = CommonStruct.Attribute()
	m_attribute.gong_ji = attribute1.gong_ji + attribute2.gong_ji
	m_attribute.max_hp = attribute1.max_hp + attribute2.max_hp
	m_attribute.fang_yu = attribute1.fang_yu + attribute2.fang_yu
	m_attribute.ming_zhong = attribute1.ming_zhong + attribute2.ming_zhong
	m_attribute.shan_bi = attribute1.shan_bi + attribute2.shan_bi
	m_attribute.bao_ji = attribute1.bao_ji + attribute2.bao_ji
	m_attribute.jian_ren = attribute1.jian_ren + attribute2.jian_ren

	m_attribute.ignore_fangyu = (attribute1.ignore_fangyu or 0) + (attribute2.ignore_fangyu or 0)								-- 无视防御
	m_attribute.hurt_increase = (attribute1.hurt_increase or 0) + (attribute2.hurt_increase or 0)								-- 伤害追加
	m_attribute.hurt_reduce = (attribute1.hurt_reduce or 0) + (attribute2.hurt_reduce or 0)										-- 伤害减免
	m_attribute.ice_master = (attribute1.ice_master or 0) + (attribute2.ice_master or 0)										-- 冰精通
	m_attribute.fire_master = (attribute1.fire_master or 0) + (attribute2.fire_master or 0)										-- 火精通
	m_attribute.thunder_master = (attribute1.thunder_master or 0) + (attribute2.thunder_master	or 0)							-- 雷精通
	m_attribute.poison_master = (attribute1.poison_master or 0) + (attribute2.poison_master or 0)								-- 毒精通

	m_attribute.per_mingzhong = (attribute1.per_mingzhong or 0) + (attribute2.per_mingzhong or 0)								-- 命中率
	m_attribute.per_shanbi = (attribute1.per_shanbi or 0) + (attribute2.per_shanbi	 or 0)										-- 闪避率
	m_attribute.per_baoji = (attribute1.per_baoji or 0) + (attribute2.per_baoji or 0)											-- 暴击率
	m_attribute.per_baoji_hurt = (attribute1.per_baoji_hurt or 0) + (attribute2.per_baoji_hurt or 0)							-- 暴击伤害率
	m_attribute.per_pofang = (attribute1.per_pofang or 0) + (attribute2.per_pofang or 0)										-- 增伤率
	m_attribute.per_mianshang = (attribute1.per_mianshang or 0) + (attribute2.per_mianshang or 0)								-- 免伤率
	m_attribute.per_pvp_hurt_increase = (attribute1.per_pvp_hurt_increase or 0) + (attribute2.per_pvp_hurt_increase or 0)		-- pvp伤害增加率
	m_attribute.per_pvp_hurt_reduce = (attribute1.per_pvp_hurt_reduce or 0) + (attribute2.per_pvp_hurt_reduce or 0)				-- pvp受伤减免率
	m_attribute.per_xixue = (attribute1.per_xixue or 0) + (attribute2.per_xixue or 0)											-- 吸血率
	m_attribute.per_stun = (attribute1.per_stun or 0) + (attribute2.per_stun or 0)												-- 击晕率
	m_attribute.per_kangbao = (attribute1.per_kangbao or 0) + (attribute2.per_kangbao or 0)										-- 抗暴率

	return m_attribute
end

-- is_no_underline 是否不要下换线
function CommonDataManager.AddAttributeBaseAttr(attribute1, vo, is_no_underline)
	local m_attribute = {}
	if not is_no_underline then
		m_attribute.gong_ji = attribute1.gong_ji + vo.base_gongji
		m_attribute.max_hp = attribute1.max_hp + vo.base_max_hp
		m_attribute.fang_yu = attribute1.fang_yu + vo.base_fangyu
		m_attribute.ming_zhong = attribute1.ming_zhong + vo.ming_zhong
		m_attribute.shan_bi = attribute1.shan_bi + vo.shan_bi
		m_attribute.bao_ji = attribute1.bao_ji + vo.bao_ji
		m_attribute.jian_ren = attribute1.jian_ren + vo.base_jianren
	else
		m_attribute.gongji = attribute1.gongji + vo.base_gongji
		m_attribute.maxhp = attribute1.maxhp + vo.base_max_hp
		m_attribute.fangyu = attribute1.fangyu + vo.base_fangyu
		m_attribute.mingzhong = attribute1.mingzhong + vo.ming_zhong
		m_attribute.shanbi = attribute1.shanbi + vo.shan_bi
		m_attribute.baoji = attribute1.baoji + vo.bao_ji
		m_attribute.jianren = attribute1.jianren + vo.base_jianren
	end
	m_attribute.ignore_fangyu = (attribute1.ignore_fangyu or 0) + (vo.ignore_fangyu or 0)								-- 无视防御
	m_attribute.hurt_increase = (attribute1.hurt_increase or 0) + (vo.hurt_increase or 0)								-- 伤害追加
	m_attribute.hurt_reduce = (attribute1.hurt_reduce or 0) + (vo.hurt_reduce or 0)										-- 伤害减免
	m_attribute.ice_master = (attribute1.ice_master or 0) + (vo.ice_master or 0)										-- 冰精通
	m_attribute.fire_master = (attribute1.fire_master or 0) + (vo.fire_master or 0)										-- 火精通
	m_attribute.thunder_master = (attribute1.thunder_master or 0) + (vo.thunder_master or 0)							-- 雷精通
	m_attribute.poison_master = (attribute1.poison_master or 0) + (vo.poison_master or 0)								-- 毒精通

	m_attribute.per_mingzhong = (attribute1.per_mingzhong or 0) + (vo.per_mingzhong or 0)								-- 命中率
	m_attribute.per_shanbi = (attribute1.per_shanbi or 0) + (vo.per_shanbi or 0)										-- 闪避率
	m_attribute.per_baoji = (attribute1.per_baoji or 0) + (vo.per_baoji or 0)											-- 暴击率
	m_attribute.per_baoji_hurt = (attribute1.per_baoji_hurt or 0) + (vo.per_baoji_hurt or 0)							-- 暴击伤害率
	m_attribute.per_pofang = (attribute1.per_pofang or 0) + (vo.per_pofang or 0)										-- 增伤率
	m_attribute.per_mianshang = (attribute1.per_mianshang or 0) + (vo.per_mianshang or 0)								-- 免伤率
	m_attribute.per_pvp_hurt_increase = (attribute1.per_pvp_hurt_increase or 0) + (vo.per_pvp_hurt_increase or 0)		-- pvp伤害增加率
	m_attribute.per_pvp_hurt_reduce = (attribute1.per_pvp_hurt_reduce or 0) + (vo.per_pvp_hurt_reduce or 0)				-- pvp受伤减免率
	m_attribute.per_xixue = (attribute1.per_xixue or 0) + (vo.per_xixue or 0)											-- 吸血率
	m_attribute.per_stun = (attribute1.per_stun or 0) + (vo.per_stun or 0) 												-- 击晕率
	m_attribute.per_kangbao = (attribute1.per_kangbao or 0) + (vo.per_kangbao or 0) 									-- 抗暴率
	if attribute1.move_speed and vo.base_move_speed then
		m_attribute.move_speed = attribute1.move_speed + vo.base_move_speed
	end
	return m_attribute
end

-- 两个属性差值(attribute2 - attribute1)
function CommonDataManager.LerpAttributeAttr(attribute1, attribute2)
	local m_attribute = CommonStruct.Attribute()
	m_attribute.gong_ji = attribute2.gong_ji - attribute1.gong_ji
	m_attribute.max_hp = attribute2.max_hp - attribute1.max_hp
	m_attribute.fang_yu = attribute2.fang_yu - attribute1.fang_yu
	m_attribute.ming_zhong = attribute2.ming_zhong - attribute1.ming_zhong
	m_attribute.shan_bi = attribute2.shan_bi - attribute1.shan_bi
	m_attribute.bao_ji = attribute2.bao_ji - attribute1.bao_ji
	m_attribute.jian_ren = attribute2.jian_ren - attribute1.jian_ren

	m_attribute.ignore_fangyu = (attribute1.ignore_fangyu or 0) - (attribute2.ignore_fangyu or 0)								-- 无视防御
	m_attribute.hurt_increase = (attribute1.hurt_increase or 0) - (attribute2.hurt_increase or 0)								-- 伤害追加
	m_attribute.hurt_reduce = (attribute1.hurt_reduce or 0) - (attribute2.hurt_reduce or 0)										-- 伤害减免
	m_attribute.ice_master = (attribute1.ice_master or 0) - (attribute2.ice_master or 0)										-- 冰精通
	m_attribute.fire_master = (attribute1.fire_master or 0) - (attribute2.fire_master or 0)										-- 火精通
	m_attribute.thunder_master = (attribute1.thunder_master or 0) - (attribute2.thunder_master or 0)							-- 雷精通
	m_attribute.poison_master = (attribute1.poison_master or 0) - (attribute2.poison_master or 0)								-- 毒精通

	m_attribute.per_mingzhong = (attribute1.per_mingzhong or 0) - (attribute2.per_mingzhong or 0)								-- 命中率
	m_attribute.per_shanbi = (attribute1.per_shanbi or 0) - (attribute2.per_shanbi or 0)										-- 闪避率
	m_attribute.per_baoji = (attribute1.per_baoji or 0) - (attribute2.per_baoji or 0)											-- 暴击率
	m_attribute.per_baoji_hurt = (attribute1.per_baoji_hurt or 0) - (attribute2.per_baoji_hurt or 0)							-- 暴击伤害率
	m_attribute.per_pofang = (attribute1.per_pofang or 0) - (attribute2.per_pofang or 0)										-- 增伤率
	m_attribute.per_mianshang = (attribute1.per_mianshang or 0) - (attribute2.per_mianshang or 0)								-- 免伤率
	m_attribute.per_pvp_hurt_increase = (attribute1.per_pvp_hurt_increase or 0) - (attribute2.per_pvp_hurt_increase or 0)		-- pvp伤害增加率
	m_attribute.per_pvp_hurt_reduce = (attribute1.per_pvp_hurt_reduce or 0) - (attribute2.per_pvp_hurt_reduce or 0)				-- pvp受伤减免率
	m_attribute.per_xixue = (attribute1.per_xixue or 0) - (attribute2.per_xixue or 0)											-- 吸血率
	m_attribute.per_stun = (attribute1.per_stun or 0) - (attribute2.per_stun or 0)												-- 击晕率
	m_attribute.per_kangbao = (attribute1.per_kangbao or 0) - (attribute2.per_kangbao or 0)										-- 抗暴率

	if attribute2.move_speed and attribute1.move_speed then
		m_attribute.move_speed = attribute2.move_speed - attribute1.move_speed
	end
	return m_attribute
end

-- 两个属性差值(attribute2 - attribute1)
function CommonDataManager.LerpAttributeAttrNoUnderLine(attribute1, attribute2)
	local m_attribute = CommonStruct.Attribute()
	m_attribute.gongji = attribute2.gongji - attribute1.gongji
	m_attribute.maxhp = attribute2.maxhp - attribute1.maxhp
	m_attribute.fangyu = attribute2.fangyu - attribute1.fangyu
	m_attribute.mingzhong = attribute2.mingzhong - attribute1.mingzhong
	m_attribute.shanbi = attribute2.shanbi - attribute1.shanbi
	m_attribute.baoji = attribute2.baoji - attribute1.baoji
	m_attribute.jianren = attribute2.jianren - attribute1.jianren

	m_attribute.ignore_fangyu = (attribute1.ignore_fangyu or 0) - (attribute2.ignore_fangyu or 0)								-- 无视防御
	m_attribute.hurt_increase = (attribute1.hurt_increase or 0) - (attribute2.hurt_increase or 0)								-- 伤害追加
	m_attribute.hurt_reduce = (attribute1.hurt_reduce or 0) - (attribute2.hurt_reduce or 0)										-- 伤害减免
	m_attribute.ice_master = (attribute1.ice_master or 0) - (attribute2.ice_master or 0)										-- 冰精通
	m_attribute.fire_master = (attribute1.fire_master or 0) - (attribute2.fire_master or 0)										-- 火精通
	m_attribute.thunder_master = (attribute1.thunder_master or 0) - (attribute2.thunder_master or 0)							-- 雷精通
	m_attribute.poison_master = (attribute1.poison_master or 0) - (attribute2.poison_master or 0)								-- 毒精通

	m_attribute.per_mingzhong = (attribute1.per_mingzhong or 0) - (attribute2.per_mingzhong or 0)								-- 命中率
	m_attribute.per_shanbi = (attribute1.per_shanbi or 0) - (attribute2.per_shanbi or 0)										-- 闪避率
	m_attribute.per_baoji = (attribute1.per_baoji or 0) - (attribute2.per_baoji or 0)											-- 暴击率
	m_attribute.per_baoji_hurt = (attribute1.per_baoji_hurt or 0) - (attribute2.per_baoji_hurt or 0)							-- 暴击伤害率
	m_attribute.per_pofang = (attribute1.per_pofang or 0) - (attribute2.per_pofang	 or 0)										-- 增伤率
	m_attribute.per_mianshang = (attribute1.per_mianshang or 0) - (attribute2.per_mianshang or 0)								-- 免伤率
	m_attribute.per_pvp_hurt_increase = (attribute1.per_pvp_hurt_increase or 0) - (attribute2.per_pvp_hurt_increase or 0)		-- pvp伤害增加率
	m_attribute.per_pvp_hurt_reduce = (attribute1.per_pvp_hurt_reduce or 0) - (attribute2.per_pvp_hurt_reduce or 0)				-- pvp受伤减免率
	m_attribute.per_xixue = (attribute1.per_xixue or 0) - (attribute2.per_xixue or 0)											-- 吸血率
	m_attribute.per_stun = (attribute1.per_stun or 0) - (attribute2.per_stun or 0)												-- 击晕率
	m_attribute.kangbao = (attribute1.kangbao or 0) - (attribute2.kangbao or 0)													-- 抗暴率

	if attribute2.move_speed and attribute1.move_speed then
		m_attribute.move_speed = attribute2.move_speed - attribute1.move_speed
	end
	return m_attribute
end

-- 属性乘以一个常数
function CommonDataManager.MulAttribute(attr, num)
	local attribute = CommonStruct.Attribute()

	if nil ~= attr and num then
		attribute.max_hp = attr.max_hp * num
		attribute.gong_ji = attr.gong_ji * num
		attribute.fang_yu = attr.fang_yu * num
		attribute.ming_zhong = attr.ming_zhong * num
		attribute.shan_bi = attr.shan_bi * num
		attribute.bao_ji = attr.bao_ji * num
		attribute.jian_ren = attr.jian_ren * num
		attribute.ignore_fangyu = attribute.ignore_fangyu * num 									-- 无视防御
		attribute.hurt_increase = attribute.hurt_increase * num 									-- 伤害追加
		attribute.hurt_reduce = attribute.hurt_reduce * num 										-- 伤害减免
		attribute.ice_master = attribute.ice_master * num 											-- 冰精通
		attribute.fire_master = attribute.fire_master * num 										-- 火精通
		attribute.thunder_master = attribute.thunder_master * num 									-- 雷精通
		attribute.poison_master = attribute.poison_master * num 									-- 毒精通

		attribute.per_mingzhong = attribute.per_mingzhong * ROLE_ATTR_PER * num						-- 命中率
		attribute.per_shanbi = attribute.per_shanbi * ROLE_ATTR_PER * num							-- 闪避率
		attribute.per_baoji = attribute.per_baoji * ROLE_ATTR_PER * num								-- 暴击率
		attribute.per_baoji_hurt = attribute.per_baoji_hurt * ROLE_ATTR_PER * num					-- 暴击伤害率
		attribute.per_pofang = attribute.per_pofang * ROLE_ATTR_PER * num							-- 增伤率
		attribute.per_mianshang = attribute.per_mianshang * ROLE_ATTR_PER * num						-- 免伤率
		attribute.per_pvp_hurt_increase = attribute.per_pvp_hurt_increase * ROLE_ATTR_PER * num		-- pvp伤害增加率
		attribute.per_pvp_hurt_reduce = attribute.per_pvp_hurt_reduce * ROLE_ATTR_PER * num			-- pvp受伤减免率
		attribute.per_xixue = attribute.per_xixue * ROLE_ATTR_PER * num								-- 吸血率
		attribute.per_stun = attribute.per_stun * ROLE_ATTR_PER * num								-- 击晕率
		attribute.per_kangbao = (attribute.per_kangbao or 0) * ROLE_ATTR_PER * num					-- 抗暴率
	end

	return attribute
end


CommonDataManager.PROF_ATTR_RATE = {
	{max_hp = 1.1103, gong_ji = 0.89, fang_yu = 1},
	{max_hp = 0.9662, gong_ji = 1.03, fang_yu = 1},
	{max_hp = 1.0356, gong_ji = 0.98, fang_yu = 1},
	{max_hp = 0.8832, gong_ji = 1.09, fang_yu = 1}
}

-- 读取一个对象的属性值,没有下划线
function CommonDataManager.GetAttributteNoUnderline(info)
	local attribute = CommonStruct.AttributeNoUnderline()

	if nil ~= info then
		attribute.gongji = info.gong_ji or info.attack or info.gongji or 0
		attribute.maxhp = info.max_hp or info.maxhp or info.hp or info.qixue or 0
		attribute.fangyu = info.fang_yu or info.fangyu or 0
		attribute.mingzhong = info.ming_zhong or info.mingzhong or 0
		attribute.shanbi = info.shan_bi or info.shanbi or 0
		attribute.baoji = info.bao_ji or info.baoji or 0
		attribute.jianren = info.jian_ren or info.jianren or 0
		attribute.per_jingzhun = info.per_jingzhun or info.jingzhun_per or 0
		attribute.per_gongji = info.per_gongji or info.per_gongji or 0
		attribute.per_maxhp = info.per_maxhp or info.per_maxhp or 0
		attribute.fujia_shanghai = info.fujia_shanghai or 0
		attribute.ignore_fangyu = info.ignore_fangyu or 0						-- 无视防御
		attribute.hurt_increase = info.hurt_increase or 0						-- 伤害追加
		attribute.hurt_reduce = info.hurt_reduce or 0							-- 伤害减免
		attribute.ice_master = info.ice_master or 0								-- 冰精通
		attribute.fire_master = info.fire_master or 0							-- 火精通
		attribute.thunder_master = info.thunder_master or 0						-- 雷精通
		attribute.poison_master = info.poison_master or 0						-- 毒精通
		attribute.per_mingzhong = info.per_mingzhong or 0						-- 命中率
		attribute.per_shanbi = info.per_shanbi or 0								-- 闪避率
		attribute.per_baoji = info.per_baoji or 0								-- 暴击率
		attribute.per_baoji_hurt = info.per_baoji_hurt or 0						-- 暴击伤害率
		attribute.per_pofang = info.per_pofang or 0								-- 增伤率
		attribute.per_mianshang = info.per_mianshang or 0						-- 免伤率
		attribute.per_pvp_hurt_increase = info.per_pvp_hurt_increase or 0		-- pvp伤害增加率
		attribute.per_pvp_hurt_reduce = info.per_pvp_hurt_reduce or 0			-- pvp受伤减免率
		attribute.per_xixue = info.per_xixue or 0								-- 吸血率
		attribute.per_stun = info.per_xuanyun or info.per_stun or 0				-- 击晕率
		attribute.per_kangbao = info.per_kangbao or info.per_kangbao or 0		-- 抗暴率
		attribute.attr_percent = info.attr_percent or info.attrpercent or 0		-- 诡道属性加成
	end
	return attribute
end

-- 读取一个对象的属性值，有下划线
function CommonDataManager.GetAttributteByClass(info)
	local attribute = CommonStruct.Attribute()

	if nil ~= info then
		attribute.gong_ji = info.gong_ji or info.attack or info.gongji or 0
		attribute.max_hp = info.max_hp or info.maxhp or info.hp or info.qixue or 0
		attribute.fang_yu = info.fang_yu or info.fangyu or 0
		attribute.ming_zhong = info.ming_zhong or info.mingzhong or 0
		attribute.shan_bi = info.shan_bi or info.shanbi or 0
		attribute.bao_ji = info.bao_ji or info.baoji or 0
		attribute.jian_ren = info.jian_ren or info.jianren or 0
		attribute.per_jingzhun = info.per_jingzhun or info.jingzhun_per or 0
		attribute.per_gongji = info.per_gongji or info.per_gongji or 0
		attribute.per_maxhp = info.per_maxhp or info.per_maxhp or 0
		attribute.fujia_shanghai = info.fujia_shanghai or 0

		attribute.ignore_fangyu = info.ignore_fangyu or 0						-- 无视防御
		attribute.hurt_increase = info.hurt_increase or 0						-- 伤害追加
		attribute.hurt_reduce = info.hurt_reduce or 0							-- 伤害减免
		attribute.ice_master = info.ice_master or 0								-- 冰精通
		attribute.fire_master = info.fire_master or 0							-- 火精通
		attribute.thunder_master = info.thunder_master or 0						-- 雷精通
		attribute.poison_master = info.poison_master or 0						-- 毒精通

		attribute.per_mingzhong = info.per_mingzhong or 0						-- 命中率
		attribute.per_shanbi = info.per_shanbi or 0								-- 闪避率
		attribute.per_baoji = info.per_baoji or 0								-- 暴击率
		attribute.per_baoji_hurt = info.per_baoji_hurt or 0						-- 暴击伤害率
		attribute.per_pofang = info.per_pofang or 0								-- 增伤率
		attribute.per_mianshang = info.per_mianshang or 0						-- 免伤率
		attribute.per_pvp_hurt_increase = info.per_pvp_hurt_increase or 0		-- pvp伤害增加率
		attribute.per_pvp_hurt_reduce = info.per_pvp_hurt_reduce or 0			-- pvp受伤减免率
		attribute.per_xixue = info.per_xixue or 0								-- 吸血率
		attribute.per_stun = info.per_xuanyun or info.per_stun or 0				-- 击晕率
		attribute.per_kangbao = info.per_kangbao or info.per_kangbao or 0		-- 抗暴率
	end
	return attribute
end

-- 读取一个对象的进阶属性值
function CommonDataManager.GetAdvanceAttributteByClass(info)
	local attribute = CommonStruct.AdvanceAttribute()

	if nil ~= info then
		attribute.mount_attr = info.mount_attr or info.mountattr or 0
		attribute.wing_attr = info.wing_attr or info.wingattr or 0
		attribute.halo_attr = info.halo_attr or info.haloattr or 0
		attribute.shengong_attr = info.shengong_attr or info.shengongattr or 0
		attribute.shenyi_attr = info.shenyi_attr or info.shenyiattr or 0
	end

	return attribute
end

-- 读取一个对象的进阶加成属性值
function CommonDataManager.GetAdvanceAddibutteByClass(info)
	local attribute = CommonStruct.AdvanceAddbute()

	if nil ~= info then
		attribute.mount_add = info.mount_add or info.mountadd or 0
		attribute.wing_add = info.wing_add or info.wingadd or 0
		attribute.halo_add = info.halo_add or info.haloadd or 0
		attribute.shengong_add = info.shengong_add or info.shengongadd or 0
		attribute.shenyi_add = info.shenyi_add or info.shenyiadd or 0
		attribute.footprint_add = info.footprint_add or info.shenyiadd or 0
		attribute.fightmount_add = info.fightmount_add or info.shenyiadd or 0
	end

	return attribute
end

function CommonDataManager.AttributeAddProfRate(attribute)
	if nil == attribute then return end
	local prof = PlayerData.Instance:GetRoleBaseProf()

	for k,v in pairs(attribute) do
		local prof_attr_rate = CommonDataManager.PROF_ATTR_RATE[prof] or {}
		if prof_attr_rate[k] then
			attribute[k] = math.floor(v * prof_attr_rate[k])
		end
	end
end

function CommonDataManager.GetProfAttrValue(value, attr_name)
	local prof = PlayerData.Instance:GetRoleBaseProf()
	local prof_attr_rate = CommonDataManager.PROF_ATTR_RATE[prof]
	if nil == prof_attr_rate then return value end

	if attr_name == "attack" or attr_name == "gongji" or attr_name == "gong_ji" then
		return math.floor(value * prof_attr_rate["gong_ji"])
	end

	if attr_name == "fangyu" or attr_name == "fang_yu" then
		return math.floor(value * prof_attr_rate["fang_yu"])
	end

	if attr_name == "maxhp" or attr_name == "hp" or attr_name == "qixue" or attr_name == "max_hp" then
		return math.floor(value * prof_attr_rate["max_hp"])
	end
	return value
end

-- 读取一个显示属性列表
function CommonDataManager.GetAttrNameAndValueByClass(info, all_show)
	local list = {}
	local attribute = CommonDataManager.GetAttributteByClass(info)
	for k,v in pairs(attribute) do
		if all_show or v > 0 then
			local vo  = {}
			vo.attr_name = CommonDataManager.GetAttrName(k)
			vo.value = v
			list[#list + 1] = vo
		end
	end
	return list
end

-- 读取一个显示进阶加成列表
function CommonDataManager.GetAdvanceAddNameAndValueByClass(info, all_show)
	local list = {}
	local attribute = CommonDataManager.GetAdvanceAddibutteByClass(info)
	for k,v in pairs(attribute) do
		if all_show or v > 0 then
			local vo  = {}
			vo.attr_name = CommonDataManager.GetAdvanceAddName(k)
			vo.value = v
			vo.attr = k
			list[#list + 1] = vo
		end
	end
	return list
end

function CommonDataManager.GetAttrKeyList()
	return{
		[1] = "max_hp",
		[2] = "gong_ji",
		[3] = "fang_yu",
		[4] = "ming_zhong",
		[5] = "shan_bi",
		[6] = "bao_ji",
		[7] = "jian_ren",
		[8] = "move_speed",
	}
end

function CommonDataManager.FlushAttrView(widgets, attribute, showspd)
	if nil ~= widgets and nil ~= attribute then
		for k,v in pairs(CommonDataManager.attrview_t) do
			if widgets["lbl_" .. v[1] .. "_val"] then
				widgets["lbl_" .. v[1] .. "_val"].node:setString(attribute[v[2]])
			end
			if v[2] == "gong_ji" and widgets.lbl_mingongji_val then
				widgets.lbl_mingongji_val.node:setString(math.floor(attribute.gong_ji * 0.4))
			end
		end
		if true == showspd then
			-- local speed = (attribute.move_speed / COMMON_CONSTS.ROLE_MOVE_SPEED) * 100
			widgets.lbl_movespeed_val.node:setString("+" .. attribute.speed_percent .. "%")
		end
	end
end

-- 刷新下一级属性
function CommonDataManager.FlushNextAttrView(widgets, attribute, showspd)
	if nil ~= widgets and nil ~= attribute then
		for k,v in pairs(CommonDataManager.attrview_t) do
			if widgets["lbl_" .. v[1] .. "_add"] then
				local node = widgets["lbl_" .. v[1] .. "_add"].node
				node:setVisible(0 ~= attribute[v[2]])
				if 0 ~= attribute[v[2]] then
					node:setString("+" .. attribute[v[2]])
				end
				if widgets["img_" .. v[1] .. "_add"] then
					widgets["img_" .. v[1] .. "_add"].node:setVisible(0 ~= attribute[v[2]])
				end
			end
			if v[2] == "gong_ji" and widgets.lbl_mingongji_add then
				widgets.lbl_mingongji_add.node:setVisible(0 ~= math.floor(attribute.gong_ji * 0.4))
				if widgets.img_mingongji_add then
					widgets.img_mingongji_add.node:setVisible(0 ~= math.floor(attribute.gong_ji * 0.4))
				end
				if 0 ~= math.floor(attribute.gong_ji * 0.4) then
					widgets.lbl_mingongji_add.node:setString("+" .. math.floor(attribute.gong_ji * 0.4))
				end
			end
		end

		if true == showspd then
			widgets.lbl_movespeed_add.node:setVisible(0 ~= attribute.move_speed)
			widgets.img_arrow_speed.node:setVisible(0 ~= attribute.move_speed)
			if 0 ~= attribute.move_speed then
				widgets.lbl_movespeed_add.node:setString("+" .. attribute.speed_percent .. "%")
			end
		end
	end
end

-- 刷新下一级属性
function CommonDataManager.FlushArrowsNextAttrView(widgets, attribute, showspd)
	if nil ~= widgets and nil ~= attribute then
		for k,v in pairs(CommonDataManager.attrview_t) do
			if widgets["lbl_" .. v[1] .. "_add"] then
				local node = widgets["lbl_" .. v[1] .. "_add"].node
				local arrows = widgets["img_" .. v[1] .. "_add"].node
				node:setVisible(0 ~= attribute[v[2]])
				arrows:setVisible(0 ~= attribute[v[2]])
				if 0 ~= attribute[v[2]] then
					node:setString(attribute[v[2]])
				end
			end
			if v[2] == "gong_ji" and widgets.lbl_mingongji_add then
				widgets.lbl_mingongji_add.node:setVisible(0 ~= math.floor(attribute.gong_ji * 0.4))
				widgets.img_mingongji_add.node:setVisible(0 ~= math.floor(attribute.gong_ji * 0.4))
				if 0 ~= math.floor(attribute.gong_ji * 0.4) then
					widgets.lbl_mingongji_add.node:setString(math.floor(attribute.gong_ji * 0.4))
				end
			end
		end

		if true == showspd then
			widgets.lbl_movespeed_add.node:setVisible(0 ~= attribute.move_speed)
			widgets.img_movespeed_add.node:setVisible(0 ~= attribute.move_speed)
			if 0 ~= attribute.move_speed then
				widgets.lbl_movespeed_add.node:setString(attribute.speed_percent .. "%")
			end
		end
	end
end

-- 获取基础属性名字
function CommonDataManager.GetAttrName(attr_type,duiqi)
	attr_type = attr_type == "fangyu" and "fang_yu" or attr_type
	attr_type = attr_type == "gongji" and "gong_ji" or attr_type
	attr_type = attr_type == "maxhp" and "max_hp" or attr_type
	attr_type = attr_type == "jianren" and "jian_ren" or attr_type
	attr_type = attr_type == "shanbi" and "shan_bi" or attr_type
	attr_type = attr_type == "baoji" and "bao_ji" or attr_type
	attr_type = attr_type == "mingzhong" and "ming_zhong" or attr_type
	attr_type = attr_type == "ignorefangyu" and "ignore_fangyu" or attr_type
	attr_type = attr_type == "hurtincrease" and "hurt_increase" or attr_type
	attr_type = attr_type == "hurtreduce" and "hurt_reduce" or attr_type
	attr_type = attr_type == "icemaster" and "ice_master" or attr_type
	attr_type = attr_type == "firemaster" and "fire_master" or attr_type
	attr_type = attr_type == "thundermaster" and "thunder_master" or attr_type
	attr_type = attr_type == "poisenmaster" and "poison_master" or attr_type
	attr_type = attr_type == "permingzhong" and "per_mingzhong" or attr_type
	attr_type = attr_type == "pershanbi" and "per_shanbi" or attr_type
	attr_type = attr_type == "perbaoji" and "per_baoji" or attr_type
	attr_type = attr_type == "perbaoji_hurt" and "per_baoji_hurt" or attr_type
	attr_type = attr_type == "perpofang" and "per_pofang" or attr_type
	attr_type = attr_type == "permianshang" and "per_mianshang" or attr_type
	attr_type = attr_type == "perpvp_hurt_increase" and "per_pvp_hurt_increase" or attr_type
	attr_type = attr_type == "perpvp_hurt_reduce" and "per_pvp_hurt_reduce" or attr_type
	attr_type = attr_type == "perxixie" and "per_xixue" or attr_type
	attr_type = attr_type == "perstun" and "per_stun" or attr_type
	attr_type = attr_type == "attrpercent" and "attr_percent" or attr_type

	-- 显示三个字的属性名
	if duiqi then 
		return Language.Common.AttrName2[attr_type] or "nil"
	else

		return Language.Common.AttrName[attr_type] or "nil"
	end
end

-- 获取进阶属性名字
function CommonDataManager.GetAdvanceAttrName(attr_type)
	attr_type = attr_type == "mountattr" and "mount_attr" or attr_type
	attr_type = attr_type == "wingattr" and "wing_attr" or attr_type
	attr_type = attr_type == "haloattr" and "halo_attr" or attr_type
	attr_type = attr_type == "shengongattr" and "shengong_attr" or attr_type
	attr_type = attr_type == "shenyiattr" and "shenyi_attr" or attr_type
	return Language.Common.AdvanceAttrName[attr_type] or "nil"
end

-- 获取进阶加成名字
function CommonDataManager.GetAdvanceAddName(attr_type)
	attr_type = attr_type == "mountadd" and "mount_add" or attr_type
	attr_type = attr_type == "wingadd" and "wing_add" or attr_type
	attr_type = attr_type == "haloadd" and "halo_add" or attr_type
	attr_type = attr_type == "shengongadd" and "shengong_add" or attr_type
	attr_type = attr_type == "shenyiadd" and "shenyi_add" or attr_type
	attr_type = attr_type == "footprintadd" and "footprint_add" or attr_type
	attr_type = attr_type == "fightmountadd" and "fightmount_add" or attr_type
	return Language.Common.AdvanceAddName[attr_type] or "nil"
end

-- 速度换算
function CommonDataManager.CountSpeedForPercent(speed)
	local speed_percent = (speed / COMMON_CONSTS.ROLE_MOVE_SPEED) * 100
	speed_percent = GameMath.Round(speed_percent / 5) * 5

	return speed_percent
end

--通过索引获得仓库的格子对应的编号 cell_index-滚动条索引(从1开始), row-列数 column-行数
function CommonDataManager.GetCellIndexList(cell_index, row, column)
	local cell_index_list = {}
	local x = math.floor(cell_index/row)
	if x > 0 and x * row ~= cell_index then
		cell_index = cell_index + row * (column - 1) * x
	elseif x > 1 and x * row == cell_index then
		cell_index = cell_index + row * (column - 1) * (x - 1)
	end
	for i=1,column do
		if i == 1 then
			cell_index_list[i] = cell_index + i - 1
		else
			cell_index_list[i] = cell_index + row * (i - 1)
		end
	end
	return cell_index_list
end

--=============================新ui控件重写=============================--

function CommonDataManager.ParseTagContent(content, font_size)
	font_size = font_size or 32
	--有名字替换，<player_name>主角</player_name>
	local name = PlayerData.Instance.role_vo.name--HtmlTool.GetHtml(PlayerData.Instance.role_vo.name, COLOR.YELLOW , font_size)
	content = XmlUtil.RelaceTagContent(content, "player_name", name)

	--有性别替换，<sex0>女娃儿</sex0><sex1>小兄弟</sex1>
	local sex = PlayerData.Instance.role_vo.sex
	local sex_tag_content = XmlUtil.GetTagContent(content, "sex" .. sex)
	if sex_tag_content ~= nil then
		content = XmlUtil.RelaceTagContent(content, "sex0", sex_tag_content)
		content = XmlUtil.RelaceTagContent(content, "sex1", "")
	end

	local camp = PlayerData.Instance.role_vo.camp
	local camp_tag_content = XmlUtil.GetTagContent(content, "camp" .. camp)
	if camp_tag_content ~= nil then
		content = XmlUtil.RelaceTagContent(content, "camp1", camp_tag_content)
		content = XmlUtil.RelaceTagContent(content, "camp0", "")
		content = XmlUtil.RelaceTagContent(content, "camp2", "")
		content = XmlUtil.RelaceTagContent(content, "camp3", "")
	end

	return content
end

-- 解析不同平台的游戏名字
function CommonDataManager.ParseGameName(content)
	return string.gsub(content, "{gamename;}", CommonDataManager.GetGameName())
end

function CommonDataManager.GetGameName()
	if nil ~= AgentAdapter and nil ~= AgentAdapter.GetGameName then
		return AgentAdapter:GetGameName()
	end
	return Language.Common.GameName[1]
end

function CommonDataManager.GetAgentGameName()
	local game_name = ""
	local spid = AgentAdapter:GetSpid()
	for k, v in pairs(Config.agent_adapt_auto.agent_adapt) do
		if spid == v.spid then
			game_name = v.game_name
		end
	end
	return game_name
end

--解析不同平台的交流群
function CommonDataManager.ParseContectGroup(content)

	local i, j = string.find(content, "{contectgroup_2;}")
	if i ~= nil and j ~= nil then
		local contect_group = CommonDataManager.GetAgentContectGroup2()
		content =  string.gsub(content, "{contectgroup_2;}", contect_group)
	end
	i, j = string.find(content, "{contectgroup;}")
	if i == nil or j == nil then return content end

	local contect_group = CommonDataManager.GetAgentContectGroup()
	return string.gsub(content, "{contectgroup;}", contect_group)
end

function CommonDataManager.GetAgentContectGroup2()
	local contect_group = ""
	local spid = AgentAdapter:GetSpid()
	for k, v in pairs(ConfigManager.Instance:GetAutoConfig("agent_adapt_auto").agent_adapt) do
		local is_spec = CommonDataManager.IsSpecAgentContect(v.spec_id)
		if spid == v.spid then
			if is_spec then
				contect_group = v.spec_contect_2
			else
				contect_group = v.contect_2
			end
		end
	end
	return contect_group
end

function CommonDataManager.GetAgentContectGroup()
	local contect_group = ""
	local spid = AgentAdapter:GetSpid()
	for k, v in pairs(ConfigManager.Instance:GetAutoConfig("agent_adapt_auto").agent_adapt) do
		local is_spec = CommonDataManager.IsSpecAgentContect(v.spec_id)
		if spid == v.spid then
			if is_spec then
				contect_group = v.spec_contect
			else
				contect_group = v.contect
			end
		end
	end
	return contect_group
end

function CommonDataManager.IsSpecAgentContect(spec_id)
	local list = Split(spec_id, "#")
	local server_id = GameVoManager.Instance:GetUserVo().plat_server_id
	for k,v in pairs(list) do
		if tonumber(v) == server_id then
			return true
		end
	end
	return false
end

-- 转换游戏品质
function CommonDataManager.ChangeQuality(obj, level)
	if nil ~= obj and nil ~= obj.gameObject and not IsNil(obj.gameObject) then
		local control_active_list = obj.gameObject:GetComponentsInChildren(typeof(QualityControlActive))
		for i = 0, control_active_list.Length - 1 do
			local control_active = control_active_list[i]
			if control_active then
				control_active:SetOverrideLevel(level or 0)
			end
		end
	end
end

-- 还原游戏品质
function CommonDataManager.ResetQuality(obj)
	if nil ~= obj and nil ~= obj.gameObject and not IsNil(obj.gameObject) then
		local control_active_list = obj.gameObject:GetComponentsInChildren(typeof(QualityControlActive))
		for i = 0, control_active_list.Length - 1 do
			local control_active = control_active_list[i]
			if control_active then
				control_active:ResetOverrideLevel()
			end
		end
	end
end

-- 属性和
function CommonDataManager.GetAllAttrSum(value)
	if nil == value then
		return 0
	end

	local gongji = (value.gong_ji or value.gongji or value.attack or 0)
	local fangyu = (value.fang_yu or value.fangyu or 0)
	local max_hp = (value.max_hp or value.maxhp or value.hp or 0)
	local mingzhong = (value.ming_zhong or value.mingzhong or 0)
	local shanbi = (value.shan_bi or value.shanbi or 0)
	local baoji = (value.bao_ji or value.baoji or 0)
	local jianren = (value.jian_ren or value.jianren or 0)
	local ignore_fangyu = (value.ignore_fangyu or 0)
	local hurt_increase = (value.hurt_increase or 0)
	local hurt_reduce = (value.hurt_reduce or 0)
	local ice_master = (value.ice_master or 0)
	local fire_master = (value.fire_master or 0)
	local thunder_master = (value.thunder_master or 0)
	local poison_master = (value.poison_master or 0)
	local mingzhong_per = (value.per_mingzhong or 0) * ROLE_ATTR_PER
	local shanbi_per = (value.per_shanbi or 0) * ROLE_ATTR_PER
	local baoji_per = (value.per_baoji or 0) * ROLE_ATTR_PER
	local kangbao_per = (value.per_kangbao or 0) * ROLE_ATTR_PER
	local pvp_hurt_increase_per = (value.per_pvp_hurt_increase or 0) * ROLE_ATTR_PER
	local pvp_hurt_reduce_per = (value.per_pvp_hurt_reduce or 0) * ROLE_ATTR_PER
	local hurt_increase_per = (value.per_pofang or 0) * ROLE_ATTR_PER
	local hurt_reduce_per = (value.per_mianshang or 0) * ROLE_ATTR_PER
	local xixue_per = (value.per_xixue or 0) * ROLE_ATTR_PER
	local stun_per = (value.per_stun or 0) * ROLE_ATTR_PER

	local sum = gongji +																---攻击		
				fangyu +																----防御
				max_hp +																-----气血
				mingzhong +																-----命中
				shanbi +																-----闪避
				baoji +																	-----暴击
				jianren +																-----抗暴
				ignore_fangyu +															---无视防御
				hurt_increase +															-----伤害追加
				hurt_reduce +															-----伤害减免
				ice_master +															-----冰精通
				fire_master +															----火精通
				thunder_master +														----雷精通
				poison_master +															-----毒精通
				mingzhong_per +															-----命中率
				shanbi_per +															-----闪避率
				baoji_per +																-----暴击率
				kangbao_per +															-----抗暴率
				pvp_hurt_increase_per +													------PvP伤害增加率
				pvp_hurt_reduce_per +													------PvP受伤减免率
				hurt_increase_per +														------伤害增加率
				hurt_reduce_per +														------受伤减免率
				xixue_per +																------吸血率
				stun_per																-----击晕率

	return math.floor(sum)
end

function CommonDataManager.SetRoleAttr(attr_obj, attr_list, next_list)
	if not attr_obj then return end
	if not attr_list or not next(attr_list) then return end
	next_list = next_list or {}
	for k,v in pairs(CommonDataManager.AttrViewList) do
		local temp_obj = attr_obj:FindObj(v)
		if temp_obj then
			if attr_list[v] and (attr_list[v] > 0 or (next_list[v] and next_list[v] > 0))then
				temp_obj:SetActive(true)
				temp_obj.text.text = attr_list[v]
			else
				temp_obj:SetActive(false)
			end
		end
	end
end

function CommonDataManager.SetRoleChangeAttr(attr_obj, attr_list, next_list)
	if not attr_obj then return end
	local attr_list = attr_list or CommonStruct.AttributeNoUnderline()
	local next_list = next_list or CommonStruct.AttributeNoUnderline()
	local change_attr = CommonDataManager.LerpAttributeAttrNoUnderLine(attr_list, next_list)
	for _,v in pairs(CommonDataManager.AttrViewList) do
		local temp_obj = attr_obj:FindObj(v)
		if temp_obj then
			local up_icon = temp_obj:FindObj("UpIcon")
			local up_label = temp_obj:FindObj("UpLabel")
			if up_icon and up_label then
				up_icon:SetActive(change_attr[v] and change_attr[v] > 0)
				up_label:SetActive(change_attr[v] and change_attr[v] > 0)
				if change_attr[v] then
					local str = change_attr[v] > 0 and ToColorStr(change_attr[v], COLOR.GREEN) or ""
					up_label.text.text = str
				end
			end
			temp_obj:SetActive(attr_list[v] ~= nil)
			temp_obj.text.text = attr_list[v] and attr_list[v] or ""
		end
	end
end

function CommonDataManager.GetRandomName(rand_num)
	local name_cfg = ConfigManager.Instance:GetAutoConfig("randname_auto").random_name[1]
	local sex = rand_num % 2

	local name_first_list = {}	-- 前缀
	local name_last_list = {}	-- 后缀
	if sex == GameEnum.FEMALE then
		name_first_list = name_cfg.female_first
		name_last_list = name_cfg.female_last
	else
		name_first_list = name_cfg.male_first
		name_last_list = name_cfg.male_last
	end

	local name_first_index = (rand_num % #name_first_list) + 1
	local name_last_index = (rand_num % #name_last_list) + 1
	local first_name = name_first_list[name_first_index] or ""
	local last_name = name_last_list[name_last_index] or ""
	return first_name .. last_name
end

-- 设置头像(优化版)(show_image_variable是否展示默认头像的绑定变量)(image_asset_variable设置默认头像资源的绑定变量)
function CommonDataManager.NewSetAvatar(role_id, show_image_variable, image_asset_variable, raw_image_obj, sex, prof, is_big, download_callback)
	-- 如果是主角
	if role_id == GameVoManager.Instance:GetMainRoleVo().role_id then
		-- 如果是跨服中
		if IS_ON_CROSSSERVER then
			--role_id = CrossServerData.Instance:GetRoleId()
			role_id = GameVoManager.Instance:GetMainRoleVo().origin_role_id
		end
	end
	is_big = is_big or false
	if AvatarManager.Instance:isDefaultImg(role_id) == 0 then
		show_image_variable:SetValue(true)
		local bundle, asset = AvatarManager.GetDefAvatar(PlayerData.Instance:GetRoleBaseProf(prof), is_big, sex)
		image_asset_variable:SetAsset(bundle, asset)
	else
		local callback = function (path)
			if nil == raw_image_obj or IsNil(raw_image_obj.gameObject) then
				return
			end

			local avatar_path = path or AvatarManager.GetFilePath(role_id, is_big)
			raw_image_obj.raw_image:LoadSprite(avatar_path,
			function()
				if nil == raw_image_obj or IsNil(raw_image_obj.gameObject) then
					return
				end

				show_image_variable:SetValue(false)
			end)
		end
		AvatarManager.Instance:GetAvatar(role_id, is_big, download_callback or callback)
	end
end

function CommonDataManager.SetAvatarFrame(role_id, image_variable, show_default)
	local key = AvatarManager.Instance:GetAvatarFrameKey(role_id)
	CoolChatCtrl.Instance:SetAvatarFrameImage(image_variable, key, show_default)
end

-- 设置头像
function CommonDataManager.SetAvatar(role_id, raw_image_obj, default_image_obj, default_image_Assets, sex, prof, is_big)
	-- 如果是主角
	if role_id == GameVoManager.Instance:GetMainRoleVo().role_id then
		-- 如果是跨服中
		if IS_ON_CROSSSERVER then
			role_id = CrossServerData.Instance:GetRoleId()
		end
	end
	is_big = is_big or false
	if AvatarManager.Instance:isDefaultImg(role_id) == 0 then
		raw_image_obj.gameObject:SetActive(false)
		default_image_obj.gameObject:SetActive(true)
		local bundle, asset = AvatarManager.GetDefAvatar(PlayerData.Instance:GetRoleBaseProf(prof), is_big, sex)
		default_image_Assets:SetAsset(bundle, asset)
	else
		local avatar_key = AvatarManager.Instance:GetAvatarKey(role_id, is_big)
		local path = AvatarManager.GetFilePath(role_id, is_big)
		if not AvatarManager.HasCache(avatar_key, path) then
			raw_image_obj.gameObject:SetActive(false)
			default_image_obj.gameObject:SetActive(true)
			local bundle, asset = AvatarManager.GetDefAvatar(PlayerData.Instance:GetRoleBaseProf(prof), is_big, sex)
			default_image_Assets:SetAsset(bundle, asset)
		end

		local callback = function (path)
			if nil == raw_image_obj or IsNil(raw_image_obj.gameObject) then
				return
			end
			local avatar_path = path or AvatarManager.GetFilePath(role_id, is_big)
			raw_image_obj.raw_image:LoadSprite(avatar_path,
			function()
				if raw_image_obj and not IsNil(raw_image_obj.gameObject) then
					raw_image_obj.gameObject:SetActive(true)
				end
				if default_image_obj and not IsNil(default_image_obj.gameObject) then
					default_image_obj.gameObject:SetActive(false)
				end
			end)
		end
		AvatarManager.Instance:GetAvatar(role_id, is_big, callback)
	end
end