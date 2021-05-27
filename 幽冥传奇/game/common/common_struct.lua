-----------------------------------------------------
-- 通用结构体
-----------------------------------------------------
CommonStruct = CommonStruct or {}

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
		fujia_shanghai = 0,							-- 附加伤害
		dikang_shanghai = 0,						-- 抵抗伤害
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
	}
end

-- 物品数据
function CommonStruct.ItemDataWrapper()
	return {	
		type = 0,	--(uchar)物品类型
		icon = 0,	--(word)图标类型
		series = 0, --(long long)序列号
		item_id = 0, --(ushort)物品ID
		quality = 0, --(uchar)品质等级
		strengthen_level = 0, --(uchar)强化等级
		strengthen_level_max = -1, --(char)物品的当前强化等级上限（初始化为-1）
		durability = 0, --(ushort)物品的耐久度
		durability_max = 0, --(ushort)物品的耐久度上限
		special_ring = {}, -- 特戒融合
		--(uchar)保留字,段暂时没用到
		--(ushort) 0byte装备融合等级, 1byte可以占用
		fusion_lv = 0, -- 0byte装备融合等级
		use_time = 0, --(uint)物品的使用时间
		precision_forging_1 = 0, --(int)精锻1, 暂时没有没用到, 查看(tagPackedGameAttribute定义)
		precision_forging_2 = 0, --精锻2, 暂时没有没用到, 查看(tagPackedGameAttribute定义)
		precision_forging_3 = 0, --精锻3, 暂时没有没用到, 查看(tagPackedGameAttribute定义)
		precision_forging_attr = 0, --(int)精锻属性值, 暂时没有没用到, 查看(tagPackedGameAttribute定义)
		num = 0, --(uchar)物品的数量，默认为1，当多个物品堆叠在一起的时候此值表示此物品的数量
		is_bind = 0, --(uchar)物品标志是否绑定，1为绑定, 0不绑定
		lucky_value = 0, --(char)幸运值或者诅咒值,祝福油加幸运，杀人减幸运
		refine_count = 0, --(ushort)精锻度,物品的精锻过的次数 (暂时没用到)
		refine_attr = {},
		smith_count = 0, --(ushort)精锻度,物品的精锻过的次数 (暂时没用到)
		deport_id = 0, --(uchar)装备穿戴的位置, 查看(tagEquipSlot定义)
		hand_pos = 0, --(uchar)是左右还是右手, 查看(tagEquipSlot定义)
		sharp = 0, --(uchar)锋利值
		zhuan_level = 0, --(uchar)物品转生等级
		frozen_times = 0, --(ushort)使用的冻结时间或者使用次数
		xuelian_level = 0, --(uint)物品的血炼等级
		jipin_level = 0, --(uchar)极品等级
		neicun_param = 0, --(uchar)用于追踪内存的使用，防止内存2次释放
		seriess = 0,		 -- 时装套
		fashion_index = 0, 	 -- 时装idnex

		cross_stars = 0, 	 -- 跨服装备总星数
		cross_grade = 0, 	 -- 跨服装备阶数
		fuling_level = 0, 	 -- 附灵等级
		fuling_exp = 0, 	 -- 附灵经验
		ring_soul_level = 0,	-- 戒魂等级

		-- 客户端自定义
		frombody = false,	-- 自身
		slot_soul = 0, -- 铸魂等级
		slot_apotheosis = 0, -- 精炼等级
	}
end

function CommonStruct.ItemConfig()
	return {
		item_id = 0,
		id = 0,
		name = "",
		desc = "",
		color = 0x000000,
		type = 0,
		icon = 0,
		shape = 0,
		dura = 0,
		useDurDrop = 0,
		dup = 0,
		dealType = 0,
		dealPrice = 0,
		time = 0,
		suitType = 0,
		suitId = 0,
		colGroup = 0,
		cdTime = 0,
		dropBroadcast = 0,
		sellBuyType = 0,
		contri = 0,
		useType = 0,
		flyType = 0,
		openUi = 0,
		effectId = 0,

		staitcAttrs = {},
		seal = {},
		conds = {},
		flags = {},
		batchStatus = 0
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