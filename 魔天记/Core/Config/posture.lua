local posture = {
	[11] = {
		['id'] = 11,	--ID
		['name'] = '输出',	--姿态名称
		['career_id'] = 101000,	--职业id
		['career_name'] = '太清门',	--职业名称
		['req_lev'] = 1,	--激活等级
		['attr'] = {'att_dmg_rate|10','crit_bonus|20'},	--属性提升
		['icon_id'] = 11,	--姿态图标
		['add_desc'] = '伤害 +10%\n暴击伤害 +20%',	--加成描述
		['desc'] = '超强输出，将使敌人措不及防。'	--姿态描述
		},
	[12] = {
		['id'] = 12,
		['name'] = '控制',
		['career_id'] = 101000,
		['career_name'] = '太清门',
		['req_lev'] = 1,
		['attr'] = {'att_dmg_rate|10','stun_resist_per|30','silent_resist|30','still_resist|30'},
		['icon_id'] = 12,
		['add_desc'] = '伤害 +10%\n控制抗性 +30%',
		['desc'] = '超强控制，玩弄敌人于鼓掌之间。'
		},
	[21] = {
		['id'] = 21,
		['name'] = '进攻',
		['career_id'] = 102000,
		['career_name'] = '天妖谷',
		['req_lev'] = 1,
		['attr'] = {'att_dmg_rate|10','crit_per|20'},
		['icon_id'] = 21,
		['add_desc'] = '伤害 +10%\n暴击 +20%',
		['desc'] = '攻守兼备，输出不可小觑。'
		},
	[22] = {
		['id'] = 22,
		['name'] = '防守',
		['career_id'] = 102000,
		['career_name'] = '天妖谷',
		['req_lev'] = 1,
		['attr'] = {'dmg_rate|-15','phy_bns_rate|25','phy_bns_per|35','mag_bns_rate|25','mag_bns_per|35'},
		['icon_id'] = 22,
		['add_desc'] = '伤害减免 +15%\n25%几率反伤35%',
		['desc'] = '队友的坚实依靠，最强大的生存能力。'
		},
	[31] = {
		['id'] = 31,
		['name'] = '爆发',
		['career_id'] = 103000,
		['career_name'] = '魔玄宗',
		['req_lev'] = 1,
		['attr'] = {'att_dmg_rate|10','phy_pen_per|15','mag_pen_per|15'},
		['icon_id'] = 31,
		['add_desc'] = '伤害 +10%\n防御穿透 +15%',
		['desc'] = '最高爆发，短时间输出大量伤害。'
		},
	[32] = {
		['id'] = 32,
		['name'] = '续航',
		['career_id'] = 103000,
		['career_name'] = '魔玄宗',
		['req_lev'] = 1,
		['attr'] = {'att_dmg_rate|10','phy_bld_per|10'},
		['icon_id'] = 32,
		['add_desc'] = '伤害 +10%\n吸血 +10%',
		['desc'] = '超强续航，通过迅捷走位牵制敌人。'
		},
	[41] = {
		['id'] = 41,
		['name'] = '输出',
		['career_id'] = 104000,
		['career_name'] = '天工宗',
		['req_lev'] = 1,
		['attr'] = {'att_dmg_rate|10','hit_per|20'},
		['icon_id'] = 41,
		['add_desc'] = '伤害 +10%\n命中 +20%',
		['desc'] = '强大的毒，杀敌于无形之间。'
		},
	[42] = {
		['id'] = 42,
		['name'] = '回复',
		['career_id'] = 104000,
		['career_name'] = '天工宗',
		['req_lev'] = 1,
		['attr'] = {'att_dmg_rate|10','cd_rdc|15'},
		['icon_id'] = 42,
		['add_desc'] = '伤害 +10%\n技能冷却缩减 +15%',
		['desc'] = '团队核心，拥有极强的治疗能力。'
		}
	}
return posture
