ProtocolStruct = ProtocolStruct or {}

-- 读取角色外观数据
function ProtocolStruct.ReadRoleAppearance()
	local t = {}
	t.wuqi_id = MsgAdapter.ReadUShort()
	t.fashion_wuqi = MsgAdapter.ReadChar()
	t.fashion_body = MsgAdapter.ReadChar()
	t.mount_used_imageid = MsgAdapter.ReadShort()
	t.wing_used_imageid = MsgAdapter.ReadShort()
	t.halo_used_imageid = MsgAdapter.ReadShort()
	t.shengong_used_imageid = MsgAdapter.ReadShort()
	t.shenyi_used_imageid = MsgAdapter.ReadShort()
	t.xiannvshouhu_imageid = MsgAdapter.ReadShort()
	t.jingling_guanghuan_imageid = MsgAdapter.ReadShort()
	t.jingling_fazhen_imageid = MsgAdapter.ReadShort()
	t.fight_mount_used_imageid = MsgAdapter.ReadShort()
	t.zhibao_used_imageid = MsgAdapter.ReadShort()
	t.use_eternity_level = MsgAdapter.ReadShort()
	t.footprint_used_imageid = MsgAdapter.ReadShort()
	t.cloak_used_imageid = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	t.shenbing_image_id = MsgAdapter.ReadShort()
	t.shenbing_texiao_id = MsgAdapter.ReadShort()
	t.baojia_image_id = MsgAdapter.ReadShort()
	t.baojia_texiao_id = MsgAdapter.ReadShort()

	t.yaoshi_used_imageid = MsgAdapter.ReadShort()				--腰饰
	t.toushi_used_imageid = MsgAdapter.ReadShort()				--头饰
	t.qilinbi_used_imageid = MsgAdapter.ReadShort()				--麒麟臂

	t.mask_used_imageid = MsgAdapter.ReadShort()				--面具

	--这些是预留的
	for i = 1, 40 do
		MsgAdapter.ReadChar()
	end
	return t
end

-- 背包里的物品数据
function ProtocolStruct.ReadKnapsackInfo()
	local t = {}
	t.item_id = MsgAdapter.ReadUShort()
	t.index = MsgAdapter.ReadShort()
	t.num = MsgAdapter.ReadShort()
	t.is_bind = MsgAdapter.ReadChar()
	t.has_param = MsgAdapter.ReadChar()	  --有为1，无为0
	t.invalid_time = MsgAdapter.ReadUInt()
	return t
 end

-- 读取物品参数数据
function ProtocolStruct.ReadItemParamData()
	local t = {}
	t.quality = MsgAdapter.ReadShort()
	t.strengthen_level = MsgAdapter.ReadShort()
	t.shen_level = MsgAdapter.ReadShort()
	t.fuling_level = MsgAdapter.ReadShort()
	t.star_level = MsgAdapter.ReadShort()
	t.has_lucky = MsgAdapter.ReadShort()
	t.fumo_id = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()

	-- 仙品
	t.xianpin_type_list = {}
	for i = 1, COMMON_CONSTS.XIANPIN_MAX_NUM do
		local xianpin_type = MsgAdapter.ReadUShort()
		if xianpin_type > 0 then
			table.insert(t.xianpin_type_list, xianpin_type)
		end
	end

	t.param1 = MsgAdapter.ReadInt()
	t.param2 = MsgAdapter.ReadInt()
	t.param3 = MsgAdapter.ReadInt()

	t.rand_attr_type_1 = MsgAdapter.ReadUChar()
	t.rand_attr_type_2 = MsgAdapter.ReadUChar()
	t.rand_attr_type_3 = MsgAdapter.ReadUChar()
	t.reserve_type = MsgAdapter.ReadUChar()

	t.rand_attr_val_1 = MsgAdapter.ReadUShort()		-- 精灵成长等级
	t.rand_attr_val_2 = MsgAdapter.ReadUShort()		-- 精灵悟性等级
	t.rand_attr_val_3 = MsgAdapter.ReadUShort()		-- 精灵成长经验值
	t.rand_attr_val_4 = MsgAdapter.ReadUShort()		-- 精灵悟性经验值

	-- JingLingSkillInfo
	t.jing_ling_skill_list = {}
	for i = 0, GameEnum.JING_LING_SKILL_COUNT_MAX - 1 do
		local skill_t = {}
		skill_t.skill_id = MsgAdapter.ReadShort()
		skill_t.can_move = MsgAdapter.ReadChar()
		skill_t.reserved = MsgAdapter.ReadChar()
		t.jing_ling_skill_list[i] = skill_t
	end
	return t
end

-- 读取物品数据
function ProtocolStruct.ReadItemDataWrapper()
	local t = {}
	t.item_id = MsgAdapter.ReadUShort()
	t.num = MsgAdapter.ReadShort()
	t.is_bind = MsgAdapter.ReadShort()
	t.has_param = MsgAdapter.ReadShort()
	t.invalid_time = MsgAdapter.ReadUInt()
	t.gold_price = MsgAdapter.ReadInt()
	t.param = ProtocolStruct.ReadItemParamData()
	return t
end

--读取人物技能数据
function ProtocolStruct.ReadRoleSkillInfoItem()
	local t = {}
	t.index = MsgAdapter.ReadShort()
	t.skill_id = MsgAdapter.ReadUShort()
	t.level = MsgAdapter.ReadInt()
	t.exp = MsgAdapter.ReadInt()
	t.last_perform = MsgAdapter.ReadUInt()
	return t
end

--读取任务单条数据
function ProtocolStruct.ReadTaskInfo()
	local t = {}
	t.task_id = MsgAdapter.ReadUShort()
	t.task_ver = MsgAdapter.ReadChar()
	t.task_condition = MsgAdapter.ReadChar()
	t.progress_num = MsgAdapter.ReadShort()
	t.is_complete = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	t.accept_time = MsgAdapter.ReadUInt()
	return t
end

-- 读取仙盟信息列表数据
function ProtocolStruct.ReadAllGuildInfo()
	local item = {}
	item.guild_id = MsgAdapter.ReadInt()
	item.guild_name = MsgAdapter.ReadStrN(32)
	item.tuanzhang_uid = MsgAdapter.ReadInt()
	item.tuanzhang_name = MsgAdapter.ReadStrN(32)
	item.create_time = MsgAdapter.ReadUInt()
	item.guild_level = MsgAdapter.ReadInt()
	item.cur_member_count = MsgAdapter.ReadInt()
	item.max_member_count = MsgAdapter.ReadInt()
	item.camp = MsgAdapter.ReadChar()
	item.vip_type = MsgAdapter.ReadChar()
	item.applyfor_setup = MsgAdapter.ReadShort()
	item.union_guild_id = MsgAdapter.ReadInt()
	item.applyfor_need_capability = MsgAdapter.ReadInt()
	item.applyfor_need_level = MsgAdapter.ReadInt()
	item.active_degree = MsgAdapter.ReadInt()
	item.total_capability = MsgAdapter.ReadInt()
	item.is_apply = MsgAdapter.ReadInt()
	return item
end

-- 读取仙盟事件列表数据
function ProtocolStruct.ReadGuildEventItem()
	local item = {}
	item.event_type = MsgAdapter.ReadShort()
	item.event_owner_post = MsgAdapter.ReadShort()
	item.event_owner = MsgAdapter.ReadStrN(32)
	item.event_time = MsgAdapter.ReadUInt()

	item.big_event = MsgAdapter.ReadShort()
	item.cannot_remove = MsgAdapter.ReadShort()

	item.param0 = MsgAdapter.ReadInt()
	item.param1 = MsgAdapter.ReadInt()
	item.param2 = MsgAdapter.ReadInt()
	item.param3 = MsgAdapter.ReadInt()
	item.sparam0 = MsgAdapter.ReadStrN(32)

	return item
end

-- 读取仙盟成员列表数据
function ProtocolStruct.ReadGuildMemberItem()
	local item = {}
	item.uid = MsgAdapter.ReadInt()
	item.role_name = MsgAdapter.ReadStrN(32)
	item.level = MsgAdapter.ReadInt()
	item.sex = MsgAdapter.ReadChar()
	item.prof = MsgAdapter.ReadChar()
	item.post = MsgAdapter.ReadChar()
	item.vip_type = MsgAdapter.ReadChar()
	item.vip_level = MsgAdapter.ReadShort()
	item.is_online = MsgAdapter.ReadShort()
	item.join_time = MsgAdapter.ReadUInt()
	item.last_login_time = MsgAdapter.ReadInt()
	item.gongxian = MsgAdapter.ReadInt()
	item.total_gongxian = MsgAdapter.ReadInt()
	item.capability = MsgAdapter.ReadInt()
	item.avatar_key_big = MsgAdapter.ReadUInt()
	item.avatar_key_small = MsgAdapter.ReadUInt()

	item.guild_signin_count = MsgAdapter.ReadShort()
	item.use_head_frame = MsgAdapter.ReadShort()

	return item
end

-- 读取申请加入仙盟列表数据
function ProtocolStruct.ReadGuildApplyItem()
	local item = {}
	item.uid = MsgAdapter.ReadInt()
	item.role_name = MsgAdapter.ReadStrN(32)
	item.level = MsgAdapter.ReadInt()
	item.sex = MsgAdapter.ReadChar()
	item.prof = MsgAdapter.ReadChar()
	item.vip_type = MsgAdapter.ReadChar()
	item.vip_level = MsgAdapter.ReadChar()
	item.capability = MsgAdapter.ReadInt()
	item.applyfor_time = MsgAdapter.ReadUInt()

	return item
end

-- 读取挑战对手信息
function ProtocolStruct.ReadOpponentInfo()
	local role_vo = GameVoManager.Instance:CreateVo(RoleVo)
	role_vo.role_id = MsgAdapter.ReadInt()
	role_vo.camp = MsgAdapter.ReadChar()
	role_vo.prof = MsgAdapter.ReadChar()
	role_vo.sex = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	role_vo.capability = MsgAdapter.ReadInt()
	role_vo.name = MsgAdapter.ReadStrN(32)
	role_vo.appearance = ProtocolStruct.ReadRoleAppearance()
	return role_vo
end

-- 读取坐标信息
function ProtocolStruct.ReadPosiInfo()
	local posi = {}
	posi.x = MsgAdapter.ReadInt()
	posi.y = MsgAdapter.ReadInt()
	return posi
end