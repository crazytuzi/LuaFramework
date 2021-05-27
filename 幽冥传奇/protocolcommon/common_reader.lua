
CommonReader = CommonReader or {}

local l_read_type = 0
function CommonReader.ReadObjAttr(index)
	l_read_type = GetAttrReadType(index)

	if l_read_type == READ_TYPE.INT then
		return MsgAdapter.ReadInt()
	elseif l_read_type == READ_TYPE.FLOAT then
		return MsgAdapter.ReadFloat()
	end

	return MsgAdapter.ReadUInt()
end

local l_index = 0
function CommonReader.ReadObjAttrTable()
	l_index = MsgAdapter.ReadUChar()
	if l_index == OBJ_ATTR.ACTOR_DIERRFRESHCD then
		return {
			index = l_index,
			value = CommonReader.ReadServerUnixTime()
		}	
	end
	return {
		index = l_index,
		value = CommonReader.ReadObjAttr(l_index)
	}
end

function CommonReader.ReadObjBuffAttr(type)
	local value = MsgAdapter.ReadInt()
	if RoleData.IsFloatAttr(type) then
		value = value / 10000
	end
	return value
end

function CommonReader.ReadItemData()
	local t = CommonStruct.ItemDataWrapper()
	t.type = MsgAdapter.ReadUChar() --(uchar)物品类型
	t.icon = MsgAdapter.ReadUShort() --(ushort)图标类型
	t.series = CommonReader.ReadSeries()	--(long long)序列号

	t.item_id = MsgAdapter.ReadUShort() --(ushort)物品ID
	t.quality = MsgAdapter.ReadUChar() --(uchar)品质等级
	t.strengthen_level = MsgAdapter.ReadUChar() --(uchar)强化等级
	t.strengthen_level_max = MsgAdapter.ReadChar() --(char)物品的当前强化等级上限（初始化为-1）
	t.durability = MsgAdapter.ReadUInt() --(uint)物品的耐久度
	t.durability_max = MsgAdapter.ReadUInt() --(uint)物品的耐久度上限
	local count = MsgAdapter.ReadUChar()
	t.special_ring = {}
	for i = 1, count do
		t.special_ring[i] = {}
		t.special_ring[i].type = MsgAdapter.ReadUChar() --(uchar)特戒类型 从1开始
		t.special_ring[i].index = MsgAdapter.ReadUChar() --(uchar)配置索引
	end
	local value = MsgAdapter.ReadUShort() --(ushort) 0byte装备融合等级, 1byte真气等级
	t.fusion_lv = bit:_and(value, 0xff)
	t.zhenqi_lv = bit:_rshift(value, 8)
	t.use_time = CommonReader.ReadServerUnixTime() --(uint)物品的使用时间
	-- t.refine_count = MsgAdapter.ReadUChar() --(ushort)精锻度物品的精锻过的次数 (暂时没用到)
	-- for i = 1, t.refine_count do
	-- 	t.refine_attr[i] = {}
	-- 	t.refine_attr[i].type = MsgAdapter.ReadUChar()
	-- 	t.refine_attr[i].sign = MsgAdapter.ReadUChar()
	-- 	t.refine_attr[i].value = MsgAdapter.ReadUShort()
	-- end
	t.client_time = Status.NowTime
	t.num = MsgAdapter.ReadUShort() --(uchar)物品的数量，默认为1，当多个物品堆叠在一起的时候此值表示此物品的数量
	t.is_bind = MsgAdapter.ReadUChar() --(uchar)物品标志是否绑定，1为绑定 0不绑定	0x01=被系统发放时绑定 0x02=被用户用绑定道具绑定 0x04=穿戴绑定
	t.lucky_value = MsgAdapter.ReadChar() --(char)幸运值或者诅咒值祝福油加幸运，杀人减幸运
	t.smith_count = MsgAdapter.ReadUShort()
	t.deport_id = MsgAdapter.ReadUChar() --(uchar)装备穿戴的位置 查看(tagEquipSlot定义)
	t.hand_pos = MsgAdapter.ReadUChar() --(uchar)是左手还是右手 查看(tagEquipSlot定义)
	t.sharp = MsgAdapter.ReadUChar() --(uchar)锋利值
	t.zhuan_level = MsgAdapter.ReadUChar() --(uchar)物品转生等级(是否幻化)
	t.frozen_times = MsgAdapter.ReadUShort() --(ushort)使用的冻结时间或者使用次数
	t.xuelian_level = MsgAdapter.ReadUInt() --(uint)物品的血炼等级
	t.jipin_level = MsgAdapter.ReadUChar() --(uchar)极品等级

	return t
end

local SERIES = {}
function CommonReader.ReadSeries()
	local series_1int = MsgAdapter.ReadUInt() --(long long)序列号
	local series_2int = MsgAdapter.ReadUInt() --(long long)序列号
	local series = series_1int .. series_2int --(long long)序列号
	SERIES[series] = {series1 = series_1int, series2 = series_2int}
	return series
end

function CommonReader.WriteSeries(series)
	if SERIES[series] then
		local series1, series2 = SERIES[series].series1, SERIES[series].series2
		MsgAdapter.WriteUInt(series1 or 0)
		MsgAdapter.WriteUInt(series2 or 0)
	else
		MsgAdapter.WriteLL(series)
	end
end

function CommonReader.ReadAchieveBabge()
	return {
		babge_id = MsgAdapter.ReadUShort(), --徽章ID
		count = MsgAdapter.ReadInt(), --完成的数量
	}
end

function CommonReader.ReadBaseAttr(vo)
	vo[OBJ_ATTR.CREATURE_PHYSICAL_ATTACK_MIN]		= MsgAdapter.ReadInt()		-- int 最小物理攻击
	vo[OBJ_ATTR.CREATURE_PHYSICAL_ATTACK_MAX]		= MsgAdapter.ReadInt()		-- int 最大物理攻击
	vo[OBJ_ATTR.CREATURE_MAGIC_ATTACK_MIN]			= MsgAdapter.ReadInt()		-- int 最小魔法攻击
	vo[OBJ_ATTR.CREATURE_MAGIC_ATTACK_MAX]			= MsgAdapter.ReadInt()		-- int 最大魔法攻击
	vo[OBJ_ATTR.CREATURE_WIZARD_ATTACK_MIN]			= MsgAdapter.ReadInt()		-- int 最小道术攻击
	vo[OBJ_ATTR.CREATURE_WIZARD_ATTACK_MAX]			= MsgAdapter.ReadInt()		-- int 最大道术攻击
	vo[OBJ_ATTR.CREATURE_PHYSICAL_DEFENCE_MIN]		= MsgAdapter.ReadInt()		-- int 最小物理防御
	vo[OBJ_ATTR.CREATURE_PHYSICAL_DEFENCE_MAX]		= MsgAdapter.ReadInt()		-- int 最大物理防御
	vo[OBJ_ATTR.CREATURE_MAGIC_DEFENCE_MIN]			= MsgAdapter.ReadInt()		-- int 最小魔法防御
	vo[OBJ_ATTR.CREATURE_MAGIC_DEFENCE_MAX]			= MsgAdapter.ReadInt()		-- int 最大魔法防御
end

function CommonReader.ReadTaskInfo()
	local info = {
		task_id = MsgAdapter.ReadUShort(),-- 任务id
		task_type = MsgAdapter.ReadUChar(),-- 任务类型
		title = MsgAdapter.ReadStr(),-- 任务名字
		day_count = MsgAdapter.ReadUChar(),-- 当天当前任务已做的次数
		task_state = TaskState.Accept,
		show_order = 1,
		targets = {},
		npc_id = 0,
		reward_count = 0,
	}

	local npc_id = MsgAdapter.ReadInt()-- npcId 接npcid,交npcid
	if npc_id > 0 then
		info.npc = {
			id = npc_id,
			name = MsgAdapter.ReadStr(),
			scene_id = MsgAdapter.ReadInt(),
			x = MsgAdapter.ReadUShort(),
			y = MsgAdapter.ReadUShort(),
		}
	end

	local target_count = MsgAdapter.ReadUChar()
	if target_count > 0 then
		info.target = {
			target_type = 0,
			id = 0,
			cur_value = 0,
			target_value = 0,
			scene_id = 0,
			x = 0,
			y = 0,
			name = "",
		}
		for i = 1, target_count do
			local vo = {
				target_index = i - 1,--目标索引
				target_type = MsgAdapter.ReadUChar(),--目标类型
				id = MsgAdapter.ReadInt(),
				cur_value = MsgAdapter.ReadInt(),--当前达到的数量
				target_value = MsgAdapter.ReadInt(),--需要完成的数量
				scene_id = MsgAdapter.ReadInt(),--场景id
				x = MsgAdapter.ReadUShort(),
				y = MsgAdapter.ReadUShort(),
				name = MsgAdapter.ReadStr(),--目标名
			}
			table.insert(info.targets, vo)

			-- if info.target.id == 0 and (vo.cur_value < vo.target_value or i == vo.target_count) then
				info.target.target_type = vo.target_type
				info.target.id = vo.id
				info.target.scene_id = vo.scene_id
				info.target.x = vo.x
				info.target.y = vo.y
				info.target.name = vo.name
			-- end
			info.target.cur_value = info.target.cur_value + vo.cur_value
			info.target.target_value = info.target.target_value + vo.target_value
		end
	end

	-- 奖励
	info.reward_count = MsgAdapter.ReadUChar()
	info.reward_list = {}
	for i = 1, info.reward_count do
		table.insert(info.reward_list, {
			reward_type = MsgAdapter.ReadUChar(),
			id = MsgAdapter.ReadUShort(),
			count = MsgAdapter.ReadInt(),
		})
	end

	-- 是否有限时
	if MsgAdapter.ReadUChar() ~= 0 then
		info.time_limit = MsgAdapter.ReadInt()--任务剩余时间
	end

	info.can_accept_level = MsgAdapter.ReadInt()--可接等级

	return info
end

function CommonReader.AchieveBabge()
	return{
		babge_id = MsgAdapter.ReadUShort(),   --徽章ID
		count = MsgAdapter.ReadInt()    	--完成的数量
	}
end

function CommonReader.ReadCD()
	local cd = MsgAdapter.ReadInt()
	if cd > 0 then
		cd = cd + Status.NowTime
	end
	return cd
end

-- 毫秒CD
function CommonReader.ReadMsCD()
	local cd = MsgAdapter.ReadInt()
	if cd > 0 then
		cd = cd / 1000 + Status.NowTime
	end
	return cd
end

function CommonReader.ReadServerUnixTime()
	local time = MsgAdapter.ReadUInt()
	time = bit:_and(time, 0x7fffffff)
	time = time + COMMON_CONSTS.SERVER_TIME_OFFSET
	return time
end

function CommonReader.ReadTeamInfo()
	return {
		role_id = MsgAdapter.ReadUInt(),
		name = MsgAdapter.ReadStr(),
		level = MsgAdapter.ReadUShort(),
		prof = MsgAdapter.ReadUChar(),
		avatar_id = MsgAdapter.ReadShort(),
		sex = MsgAdapter.ReadUChar(),
		guild_name = MsgAdapter.ReadStr(),
		is_online = MsgAdapter.ReadUChar(),
		capacity = MsgAdapter.ReadUInt(),
		zhuan = MsgAdapter.ReadUInt()
	}
end

function CommonReader.ReadActivityRankingInfo()
	local data = {}
	table.insert(data, MsgAdapter.ReadUChar()) -- 排名
	table.insert(data, MsgAdapter.ReadStr()) -- 玩家名
	table.insert(data, MsgAdapter.ReadUInt()) -- 值
	table.insert(data, MsgAdapter.ReadUInt()) -- 玩家角色ID
	table.insert(data, MsgAdapter.ReadUChar()) -- 玩家职业
	table.insert(data, MsgAdapter.ReadUChar()) -- 玩家性别
	return data
end
