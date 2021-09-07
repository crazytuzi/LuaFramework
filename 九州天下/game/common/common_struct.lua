-----------------------------------------------------
-- 通用结构体
-----------------------------------------------------
CommonStruct = CommonStruct or {}

-- 属性
function CommonStruct.AttributeNoUnderline()
	return {
		maxhp = 0,									-- 血量上限
		gongji = 0,									-- 攻击
		fangyu = 0,									-- 防御
		mingzhong = 0,								-- 命中
		shanbi = 0,									-- 闪避
		baoji = 0,									-- 暴击
		jianren = 0,								-- 抗暴
		movespeed = 0,								-- 移动速度
		per_jingzhun = 0,							-- 破甲
		fujia_shanghai = 0,							-- 附加伤害

		ignore_fangyu = 0,							-- 无视防御
		hurt_increase = 0,							-- 伤害追加
		hurt_reduce = 0,							-- 伤害减免
		ice_master = 0,								-- 冰精通
		fire_master = 0,							-- 火精通
		thunder_master = 0,							-- 雷精通
		poison_master = 0,							-- 毒精通

		per_mingzhong = 0,							-- 命中率
		per_shanbi = 0,								-- 闪避率
		per_baoji = 0,								-- 暴击率
		per_baoji_hurt = 0,							-- 暴击伤害率
		per_pofang = 0,								-- 增伤率
		per_mianshang = 0,							-- 免伤率
		per_pvp_hurt_increase = 0,					-- pvp伤害增加率
		per_pvp_hurt_reduce = 0,					-- pvp受伤减免率
		per_xixue = 0,								-- 吸血率
		per_stun = 0,								-- 击晕率
		attr_percent = 0							-- 诡道属性加成
	}
end

-- 属性
function CommonStruct.Attribute()
	return {
		max_hp = 0,									-- 血量上限
		gong_ji = 0,								-- 攻击
		fang_yu = 0,								-- 防御
		ming_zhong = 0,								-- 命中
		shan_bi = 0,								-- 闪避
		bao_ji = 0,									-- 暴击
		jian_ren = 0,								-- 抗暴
		move_speed = 0,								-- 移动速度
		per_jingzhun = 0,							-- 破甲
		fujia_shanghai = 0,							-- 附加伤害

		ignore_fangyu = 0,							-- 无视防御
		hurt_increase = 0,							-- 伤害追加
		hurt_reduce = 0,							-- 伤害减免
		ice_master = 0,								-- 冰精通
		fire_master = 0,							-- 火精通
		thunder_master = 0,							-- 雷精通
		poison_master = 0,							-- 毒精通

		per_mingzhong = 0,							-- 命中率
		per_shanbi = 0,								-- 闪避率
		per_baoji = 0,								-- 暴击率
		per_baoji_hurt = 0,							-- 暴击伤害率
		per_pofang = 0,								-- 增伤率
		per_mianshang = 0,							-- 免伤率
		per_pvp_hurt_increase = 0,					-- pvp伤害增加率
		per_pvp_hurt_reduce = 0,					-- pvp受伤减免率
		per_xixue = 0,								-- 吸血率
		per_stun = 0,								-- 击晕率
	}
end

-- 进阶属性
function CommonStruct.AdvanceAttribute()
	return {
		mount_attr = 0,							-- 坐骑
        wing_attr = 0,								-- 羽翼
        halo_attr = 0,								-- 光环
        shengong_attr = 0,							-- 神弓
        shenyi_attr = 0,							-- 神翼
	}
end

-- 进阶加成属性
function CommonStruct.AdvanceAddbute()
	return {
		mount_add = 0,								-- 坐骑
        wing_add = 0,								-- 羽翼
        halo_add = 0,								-- 光环
        shengong_add = 0,							-- 神弓
        shenyi_add = 0,								-- 神翼
        footprint_add = 0,							-- 足迹
        fightmount_add = 0,							-- 战斗坐骑
	}
end

-- 物品参数
function CommonStruct.ItemParamData()
	return {
		quality = 0,								-- 品质
		strengthen_level = 0,						-- 强化等级
		shen_level = 0,								-- 神铸等级
		fuling_level = 0,							-- 附灵等级
		star_level = 0,								-- 升星等级
		has_lucky = 0,								-- 幸运属性
		fumo_id = 0,								-- 附魔id
		xianpin_type_list = {},						-- 仙品属性
		angel_level = 0, 							-- 大天使等级（神装等级）
	}
end

-- 物品数据
function CommonStruct.ItemDataWrapper()
	return {
		item_id = 0,
		num = 0,
		is_bind = 0,
		has_param = 0,
		invalid_time = 0,
		gold_price = 0,
		index = 0,
		param = CommonStruct.ItemParamData()
	}
end

-- 铜币
function CommonStruct.CoinDataWrapper(num)
	num = num or 0
	local vo = CommonStruct.ItemDataWrapper()
	vo.item_id = COMMON_CONSTS.VIRTUAL_ITEM_BIND_COIN
	vo.num = num
	return vo
end

-- 绑定元宝
function CommonStruct.BindGoldDataWrapper(num)
	num = num or 0
	local vo = CommonStruct.ItemDataWrapper()
	vo.item_id = COMMON_CONSTS.VIRTUAL_ITEM_BINDGOL
	vo.num = num
	return vo
end

-- 经验
function CommonStruct.ExpDataWrapper(num)
	num = num or 0
	local vo = CommonStruct.ItemDataWrapper()
	vo.item_id = COMMON_CONSTS.VIRTUAL_ITEM_EXP
	vo.num = num
	return vo
end
-- 女娲石
function CommonStruct.NvWaShiDataWrapper(num)
	num = num or 0
	local vo = CommonStruct.ItemDataWrapper()
	vo.item_id = COMMON_CONSTS.VIRTUAL_ITEM_NVWASHI
	vo.num = num
	return vo
end

-- 仙魂
function CommonStruct.XianHunDataWrapper(num)
	num = num or 0
	local vo = CommonStruct.ItemDataWrapper()
	vo.item_id = COMMON_CONSTS.VIRTUAL_ITEM_XIANHUN
	vo.num = num
	return vo
end

-- 真气
function CommonStruct.YuanLiDataWrapper(num)
	num = num or 0
	local vo = CommonStruct.ItemDataWrapper()
	vo.item_id = COMMON_CONSTS.VIRTUAL_ITEM_YUANLI
	vo.num = num
	return vo
end