
-- 进入场景
SCEnterScene = SCEnterScene or BaseClass(BaseProtocolStruct)
function SCEnterScene:__init()
	self.msg_type = 1100
end

function SCEnterScene:Decode()
	self.scene_id = MsgAdapter.ReadInt()
	self.obj_id = MsgAdapter.ReadUShort()
	self.open_line = MsgAdapter.ReadShort()
	self.pos_x = MsgAdapter.ReadShort()
	self.pos_y = MsgAdapter.ReadShort()
	self.hp = MsgAdapter.ReadInt()
	self.max_hp = MsgAdapter.ReadInt()
	self.scene_key = MsgAdapter.ReadInt()
end

-- 角色进入视野
SCVisibleObjEnterRole = SCVisibleObjEnterRole or BaseClass(BaseProtocolStruct)
function SCVisibleObjEnterRole:__init()
	self.msg_type = 1102
	self.used_title_list = {}
end

function SCVisibleObjEnterRole:Decode()
	self.dir = MsgAdapter.ReadFloat()
	self.move_mode_param = MsgAdapter.ReadChar()
	self.role_status = MsgAdapter.ReadChar()
	self.obj_id = MsgAdapter.ReadUShort()
	self.role_id = MsgAdapter.ReadInt()
	self.role_name = MsgAdapter.ReadStrN(32)
	self.hp = MsgAdapter.ReadInt()
	self.max_hp = MsgAdapter.ReadInt()
	self.mp = MsgAdapter.ReadInt()
	self.max_mp = MsgAdapter.ReadInt()
	self.level = MsgAdapter.ReadShort()
	self.camp = MsgAdapter.ReadChar()
	self.prof = MsgAdapter.ReadChar()
	self.sex = MsgAdapter.ReadChar()
	self.vip_level = MsgAdapter.ReadChar()
	self.rest_partner_obj_id = MsgAdapter.ReadUShort()
	self.move_speed = MsgAdapter.ReadInt()
	self.pos_x = MsgAdapter.ReadShort()
	self.pos_y = MsgAdapter.ReadShort()
	self.distance = MsgAdapter.ReadFloat()
	self.attack_mode = MsgAdapter.ReadChar()
	self.name_color = MsgAdapter.ReadChar()
	self.move_mode = MsgAdapter.ReadChar()
	self.authority_type = MsgAdapter.ReadChar()
	self.husong_color = MsgAdapter.ReadChar()
	self.guild_post = MsgAdapter.ReadChar()
	self.mount_appeid = MsgAdapter.ReadUShort()
	self.appearance = ProtocolStruct.ReadRoleAppearance()		-- 外观
	self.husong_taskid = MsgAdapter.ReadUShort()
	self.used_sprite_id = MsgAdapter.ReadUShort()				-- 仙女id
	self.use_sprite_imageid = MsgAdapter.ReadChar()				-- 精灵飞升形象
	self.used_sprite_quality = MsgAdapter.ReadChar()			-- 仙女品质等级
	self.chengjiu_title_level = MsgAdapter.ReadShort()			-- 仙女缠绵等级
	self.sprite_name = MsgAdapter.ReadStrN(32)					-- 仙女名字
	self.avatar_key_big = MsgAdapter.ReadUInt()					-- 大头像
	self.avatar_key_small = MsgAdapter.ReadUInt()				-- 小头像
	self.flyup_use_image = MsgAdapter.ReadShort()				-- 坐骑飞升头像
	self.use_xiannv_id = MsgAdapter.ReadShort()					-- 仙女使用id
	self.used_sprite_jie = MsgAdapter.ReadShort()				-- 仙女阶数
	self.xianjie_level = MsgAdapter.ReadShort()					-- 仙阶等级
	self.tianxiange_level = MsgAdapter.ReadInt()				-- 天宫试练 通关层数
	self.user_pet_special_img = MsgAdapter.ReadShort()          -- 精灵特殊形象
	self.top_dps_flag = MsgAdapter.ReadShort()					-- 最高dps标记
	self.pet_id = MsgAdapter.ReadInt()							-- 宠物ID
	self.pet_level = MsgAdapter.ReadShort()						-- 宠物等级
	self.pet_grade = MsgAdapter.ReadShort()						-- 宠物阶数
	self.pet_name = MsgAdapter.ReadStrN(32)						-- 宠物名字
	self.user_lq_special_img = MsgAdapter.ReadShort()          	-- 宠物特殊形象
	self.use_xiannv_halo_img = MsgAdapter.ReadShort()			-- 精灵光环使用形象

	self.multi_mount_res_id = MsgAdapter.ReadInt() 			-- 双人坐骑资源id
	self.multi_mount_is_owner = MsgAdapter.ReadInt() 			-- 是否当前双人坐骑的主人
	self.multi_mount_other_uid = MsgAdapter.ReadInt() 			-- 一起骑乘的玩家role_id

	self.little_pet_name = MsgAdapter.ReadStrN(32)				-- 小宠物名字
	self.little_pet_using_id = MsgAdapter.ReadShort() 			-- 小宠物使用形象id

	self.fight_mount_appeid = MsgAdapter.ReadShort()			-- 战斗坐骑外观
	self.xiannv_name = MsgAdapter.ReadStrN(32)					-- 仙女名字
	self.xiannv_huanhua_id = MsgAdapter.ReadShort() 			-- 仙女幻化id
	self.combine_server_equip_active_special = MsgAdapter.ReadShort()		-- 屠龙装备是否激活特效, 0不是1是
	self.wuqi_color = MsgAdapter.ReadShort()						-- 武器颜色
	self.touxian = MsgAdapter.ReadShort()							-- 头衔等级
	self.total_capability = MsgAdapter.ReadInt()				-- 战力
	self.molong_rank = MsgAdapter.ReadInt() 					-- 龙行天下头衔等级
	self.shengbing_use_image_id = MsgAdapter.ReadShort()		--穿戴神兵
	self.baojia_use_image_id = MsgAdapter.ReadShort()			--穿戴宝甲
	self.jinghua_husong_type = MsgAdapter.ReadChar() 			--精华护送的类型
	MsgAdapter.ReadChar()
	self.lingzhu_use_imageid = MsgAdapter.ReadShort()			--灵珠
	self.lingchong_used_imageid = MsgAdapter.ReadShort()		--灵宠
	self.linggong_used_imageid = MsgAdapter.ReadShort()			--灵弓
	self.lingqi_used_imageid = MsgAdapter.ReadShort()			--灵骑
	MsgAdapter.ReadShort()

	self.model_size = MsgAdapter.ReadShort()					--模型大小
	self.is_invisible = MsgAdapter.ReadShort()					--0 可见 1 不可见

	self.sup_baby_id = MsgAdapter.ReadShort()					--超级宝宝id
	MsgAdapter.ReadShort()
	self.sup_baby_name = MsgAdapter.ReadStrN(32)				--超级宝宝名字

	local attach_mask = MsgAdapter.ReadInt()
	local mask_t = bit:d2b(attach_mask)

	-- 仙盟数据
	if 0 ~= mask_t[32 - 0] then
		self.guild_id = MsgAdapter.ReadInt()
		self.guild_name = MsgAdapter.ReadStrN(32)
		self.guild_avatar_key_big = MsgAdapter.ReadUInt()
		self.guild_avatar_key_small = MsgAdapter.ReadUInt()
	else
		self.guild_id = 0
		self.guild_name = ""
		self.guild_avatar_key_big = 0
		self.guild_avatar_key_small = 0
	end
	-- 头顶称号数据
	if 0 ~= mask_t[32 - 1] then
		for i=1,3 do
			self.used_title_list[i] = MsgAdapter.ReadShort()
		end
	else
		for i=1,3 do
			self.used_title_list[i] = 0
		end
	end

	if 0 ~= mask_t[32 - 2] then
		self.millionare_type = MsgAdapter.ReadChar()
	else
		self.millionare_type = 0
	end

	-- 战斗特殊效果
	if 0 ~= mask_t[32 - 3] then
		self.buff_mark_low = MsgAdapter.ReadUInt()
		self.buff_mark_high = MsgAdapter.ReadUInt()
	else
		self.buff_mark_low = 0
		self.buff_mark_high = 0
	end

	-- 特殊状态
	if 0 ~= mask_t[32 - 4] then
		self.special_param = MsgAdapter.ReadInt()
	end

	-- 跳跃高度
	if 0 ~= mask_t[32 - 5] then
		self.height = MsgAdapter.ReadShort()
	else
		self.height = 0
	end

	-- 特殊外观
	if 0 ~= mask_t[32 - 6] then
		self.special_appearance = MsgAdapter.ReadShort()
		self.appearance_param = MsgAdapter.ReadInt()
	else
		self.special_appearance = 0
	end

	-- 变身外观
	if 0 ~= mask_t[32 - 7] then
		self.bianshen_param = MsgAdapter.ReadInt()
	else
		self.bianshen_param = 0
	end

	-- 神兵外观
	if 0 ~= mask_t[32 - 8] then
		self.shenbing_flag = MsgAdapter.ReadShort()
	else
		self.shenbing_flag = 0
	end

	-- 结婚信息
	if 0 ~= mask_t[32 - 9] then
		self.lover_name = MsgAdapter.ReadStrN(32)
	else
		self.lover_name = ""
	end

	-- 祭炼信息
	if 0 ~= mask_t[32 - 10] then
		self.jilian_type = MsgAdapter.ReadChar()
	else
		self.jilian_type = 0
	end

	-- 精华护送信息
	if 0 ~= mask_t[32 - 11] then
		self.jinghua_husong_status = MsgAdapter.ReadShort()
	else
		self.jinghua_husong_status = 0
	end

	-- 精灵称号
	if 0 ~= mask_t[32 - 12] then
		self.use_jingling_titleid = MsgAdapter.ReadUShort()
	else
		self.use_jingling_titleid = 0
	end

	-- 夫妻光环
	if 0 ~= mask_t[32 - 13] then
		self.halo_type = MsgAdapter.ReadInt()
	else
		self.halo_type = 0
	end

	-- 夫妻光环对象uid
	if 0 ~= mask_t[32 - 14] then
		self.halo_lover_uid = MsgAdapter.ReadInt()
	else
		self.halo_lover_uid = 0
	end

	--  接受任务特殊外观
	if 0 ~= mask_t[32 - 15] then
		self.task_appearn = MsgAdapter.ReadChar()
		self.task_appearn_param_1 = MsgAdapter.ReadInt()
	else
		self.task_appearn = 0
		self.task_appearn_param_1 = 0
	end

	--  采集物Obj_id
	if 0 ~= mask_t[32 - 17] then
		self.gather_obj_id = MsgAdapter.ReadUShort()
	else
		self.gather_obj_id = 0x10000
	end
end

-- 场景对象离开视野
SCVisibleObjLeave = SCVisibleObjLeave or BaseClass(BaseProtocolStruct)
function SCVisibleObjLeave:__init()
	self.msg_type = 1103
end

function SCVisibleObjLeave:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
end

-- 场景对象移动
SCObjMove = SCObjMove or BaseClass(BaseProtocolStruct)
function SCObjMove:__init()
	self.msg_type = 1104
end

function SCObjMove:Decode()
	self.dir = MsgAdapter.ReadFloat()
	self.press_onward = MsgAdapter.ReadShort()
	self.obj_id = MsgAdapter.ReadUShort()
	self.pos_x = MsgAdapter.ReadShort()
	self.pos_y = MsgAdapter.ReadShort()
	self.distance = MsgAdapter.ReadFloat()
	self.move_mode = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	self.height = MsgAdapter.ReadShort()
end

-- 掉落物品进入视野
SCVisibleObjEnterFalling = SCVisibleObjEnterFalling or BaseClass(BaseProtocolStruct)
function SCVisibleObjEnterFalling:__init()
	self.msg_type = 1105
end

function SCVisibleObjEnterFalling:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.item_id = MsgAdapter.ReadUShort()
	self.pos_x = MsgAdapter.ReadShort()
	self.pos_y = MsgAdapter.ReadShort()
	self.owner_role_id = MsgAdapter.ReadInt()
	self.coin = MsgAdapter.ReadInt()
	self.monster_id = MsgAdapter.ReadUShort()
	self.item_num = MsgAdapter.ReadUShort()
	self.drop_time = MsgAdapter.ReadUInt()
	self.create_interval = MsgAdapter.ReadShort()
	self.is_create = MsgAdapter.ReadShort()				-- 1表示刚刚掉落
	self.is_buff_falling = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.buff_appearan = MsgAdapter.ReadInt()
end

-- 怪物进入视野
SCVisibleObjEnterMonster = SCVisibleObjEnterMonster or BaseClass(BaseProtocolStruct)
function SCVisibleObjEnterMonster:__init()
	self.msg_type = 1106
end

function SCVisibleObjEnterMonster:Decode()
	self.dir = MsgAdapter.ReadFloat()
	self.status_type = MsgAdapter.ReadShort()
	self.obj_id = MsgAdapter.ReadUShort()
	self.hp = MsgAdapter.ReadInt()
	self.max_hp = MsgAdapter.ReadInt()
	self.level = MsgAdapter.ReadInt()
	self.monster_id = MsgAdapter.ReadUShort()
	self.move_speed = MsgAdapter.ReadShort()
	self.pos_x = MsgAdapter.ReadShort()
	self.pos_y = MsgAdapter.ReadShort()
	self.distance = MsgAdapter.ReadFloat()
	self.buff_mark_low = MsgAdapter.ReadUInt()
	self.buff_mark_high = MsgAdapter.ReadUInt()
	self.special_param = MsgAdapter.ReadInt()
	self.monster_key = MsgAdapter.ReadInt()
	local is_has_dsp_name = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
	if is_has_dsp_name == 1 then
		self.dsp_name = MsgAdapter.ReadStrN(32)
	else
		self.dsp_name = ""
	end
end

-- 角色外观改变
SCRoleVisibleChange = SCRoleVisibleChange or BaseClass(BaseProtocolStruct)
function SCRoleVisibleChange:__init()
	self.msg_type = 1108
end

function SCRoleVisibleChange:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	MsgAdapter.ReadShort()
	self.appearance = ProtocolStruct.ReadRoleAppearance()
end

-- 采集物进入视野
SCVisibleObjEnterGather = SCVisibleObjEnterGather or BaseClass(BaseProtocolStruct)
function SCVisibleObjEnterGather:__init()
	self.msg_type = 1110
end

function SCVisibleObjEnterGather:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.special_gather_type = MsgAdapter.ReadShort()
	self.gather_id = MsgAdapter.ReadInt()
	self.pos_x = MsgAdapter.ReadShort()
	self.pos_y = MsgAdapter.ReadShort()
	self.param = MsgAdapter.ReadInt()
	self.param1 = MsgAdapter.ReadInt()
	self.param2 = MsgAdapter.ReadStrN(32)
	self.param3 = MsgAdapter.ReadShort()
	self.param4 = MsgAdapter.ReadShort()
end

--开始采集动作(广播)
SCStartGather = SCStartGather or BaseClass(BaseProtocolStruct)
function SCStartGather:__init()
	self.msg_type = 1111
end

function SCStartGather:Decode()
	self.role_obj_id = MsgAdapter.ReadUShort()
	self.gather_obj_id = MsgAdapter.ReadUShort()
end

--停止采集动作(广播)
SCStopGather = SCStopGather or BaseClass(BaseProtocolStruct)
function SCStopGather:__init()
	self.msg_type = 1112
end

function SCStopGather:Decode()
	self.role_obj_id = MsgAdapter.ReadUShort()
	self.reason = MsgAdapter.ReadShort()
end

--开始采集计时
SCStartGatherTimer = SCStartGatherTimer or BaseClass(BaseProtocolStruct)
function SCStartGatherTimer:__init()
	self.msg_type = 1113
end

function SCStartGatherTimer:Decode()
	self.gather_time = MsgAdapter.ReadUInt()
end

-- 强设主角位置
SCResetPos = SCResetPos or BaseClass(BaseProtocolStruct)
function SCResetPos:__init()
	self.msg_type = 1115
end

function SCResetPos:Decode()
	self.pos_x = MsgAdapter.ReadShort()
	self.pos_y = MsgAdapter.ReadShort()
	self.reset_type = MsgAdapter.ReadShort()
end

-- 场景超时时间
SCSceneFbTimeOut = SCSceneFbTimeOut or BaseClass(BaseProtocolStruct)
function SCSceneFbTimeOut:__init()
	self.msg_type = 1117
end

function SCSceneFbTimeOut:Decode()
	self.time_out = MsgAdapter.ReadUInt()
end

-- 组队队伍队员位置信息
SCTeamMemberPos = SCTeamMemberPos or BaseClass(BaseProtocolStruct)
function SCTeamMemberPos:__init()
	self.msg_type = 1118
end

function SCTeamMemberPos:Decode()
	self.role_id = MsgAdapter.ReadInt()
	self.obj_id = MsgAdapter.ReadUShort()
	self.reserved = MsgAdapter.ReadChar()
	self.is_leave_scene = MsgAdapter.ReadChar()
	self.pos_x = MsgAdapter.ReadShort()
	self.pos_y = MsgAdapter.ReadShort()
	self.dir = MsgAdapter.ReadFloat()
	self.distance = MsgAdapter.ReadFloat()
	self.move_speed = MsgAdapter.ReadInt()
end

-- 技能强行设置坐标 冲锋类技能
SCSkillResetPos = SCSkillResetPos or BaseClass(BaseProtocolStruct)
function SCSkillResetPos:__init()
	self.msg_type = 1119
end

function SCSkillResetPos:Decode()
	self.dir = MsgAdapter.ReadFloat()
	self.reset_pos_type = MsgAdapter.ReadShort()
	self.obj_id = MsgAdapter.ReadUShort()
	self.pos_x = MsgAdapter.ReadShort()
	self.pos_y = MsgAdapter.ReadShort()
	self.skill_id = MsgAdapter.ReadInt()
	self.deliver_obj_id = MsgAdapter.ReadUShort()
	MsgAdapter.ReadShort()
end

--战场神石对象进入可视区域
SCVisibleObjEnterBattleFieldShenShi = SCVisibleObjEnterBattleFieldShenShi or BaseClass(BaseProtocolStruct)
function SCVisibleObjEnterBattleFieldShenShi:__init()
	self.msg_type = 1120

	self.has_owner = 0
	self.hp = 0
	self.max_hp = 0
	self.pos_x = 0
	self.pos_y = 0
	self.obj_id = 0
	self.owner_obj_id = 0
	self.owner_uid = 0
end

function SCVisibleObjEnterBattleFieldShenShi:Decode()
	self.has_owner = MsgAdapter.ReadInt()
	self.hp = MsgAdapter.ReadInt()
	self.max_hp = MsgAdapter.ReadInt()
	self.pos_x = MsgAdapter.ReadShort()
	self.pos_y = MsgAdapter.ReadShort()
	self.obj_id = MsgAdapter.ReadUShort()
	self.owner_obj_id = MsgAdapter.ReadUShort()
	self.owner_uid = MsgAdapter.ReadInt()
end

-- 场景所有对象的运动信息返回
SCAllObjMoveInfo = SCAllObjMoveInfo or BaseClass(BaseProtocolStruct)
function SCAllObjMoveInfo:__init()
	self.msg_type = 1125

	self.obj_move_info_list = {}
end

function SCAllObjMoveInfo:Decode()
	self.obj_move_info_list = {}
	local count = MsgAdapter.ReadInt()
	for i = 1, count do
		local t = {}
		t.obj_id = MsgAdapter.ReadUShort()
		t.obj_type = MsgAdapter.ReadShort()
		t.type_special_id = MsgAdapter.ReadInt()
		t.dir = MsgAdapter.ReadFloat()
		t.distance = MsgAdapter.ReadFloat()
		t.pos_x = MsgAdapter.ReadShort()
		t.pos_y = MsgAdapter.ReadShort()
		t.move_speed = MsgAdapter.ReadInt()
		t.monster_key = MsgAdapter.ReadInt()
		table.insert(self.obj_move_info_list, t)
	end
end

-- 运动模式广播
SCObjMoveMode = SCObjMoveMode or BaseClass(BaseProtocolStruct)
function SCObjMoveMode:__init()
	self.msg_type = 1127
end

function SCObjMoveMode:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.move_mode = MsgAdapter.ReadChar()
	self.move_mode_param = MsgAdapter.ReadChar()
end

-- 怪物死亡
SCSceneMonsterDie = SCSceneMonsterDie or BaseClass(BaseProtocolStruct)
function SCSceneMonsterDie:__init()
	self.msg_type = 1128

	self.obj_move_info_list = {}
end

function SCSceneMonsterDie:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	MsgAdapter.ReadShort()
	self.monster_id = MsgAdapter.ReadInt()
	self.monster_key = MsgAdapter.ReadInt()
end

SCVisibleObjEnterEffect = SCVisibleObjEnterEffect or BaseClass(BaseProtocolStruct)
function SCVisibleObjEnterEffect:__init()
	self.msg_type = 1129
end

function SCVisibleObjEnterEffect:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.product_method = MsgAdapter.ReadShort()
	self.product_id = MsgAdapter.ReadInt()
	self.pos_x = MsgAdapter.ReadShort()
	self.pos_y = MsgAdapter.ReadShort()
	self.birth_time = MsgAdapter.ReadUInt()
	self.disappear_time = MsgAdapter.ReadUInt()
	self.param1 = MsgAdapter.ReadInt()
	self.param2 = MsgAdapter.ReadInt()
	self.src_pos_x = MsgAdapter.ReadShort()
	self.src_pos_y = MsgAdapter.ReadShort()
end

-- 位置纠偏通知
SCFixPos = SCFixPos or BaseClass(BaseProtocolStruct)
function SCFixPos:__init()
	self.msg_type = 1132
end

function SCFixPos:Decode()
	self.x = MsgAdapter.ReadShort()
	self.y = MsgAdapter.ReadShort()
end

-- 触发物进去视野
SCVisibleObjEnterTrigger = SCVisibleObjEnterTrigger or BaseClass(BaseProtocolStruct)
function SCVisibleObjEnterTrigger:__init()
	self.msg_type = 1141
end

function SCVisibleObjEnterTrigger:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.action_type = MsgAdapter.ReadShort()
	self.param0 = MsgAdapter.ReadInt()
	self.param1 = MsgAdapter.ReadInt()
	self.pos_x = MsgAdapter.ReadShort()
	self.pos_y = MsgAdapter.ReadShort()
	self.affiliation = MsgAdapter.ReadInt()
	self.trigger_name = MsgAdapter.ReadStrN(32)
end

-- 角色影子进入可视区域
SCVisibleObjEnterRoleShadow = SCVisibleObjEnterRoleShadow or BaseClass(BaseProtocolStruct)
function SCVisibleObjEnterRoleShadow:__init()
	self.msg_type = 1144
end

function SCVisibleObjEnterRoleShadow:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	MsgAdapter.ReadShort()
	self.role_id = MsgAdapter.ReadInt()
	self.role_name = MsgAdapter.ReadStrN(32)
	self.level = MsgAdapter.ReadInt()
	self.avatar = MsgAdapter.ReadChar()
	self.prof = MsgAdapter.ReadChar()
	self.sex = MsgAdapter.ReadChar()
	self.camp = MsgAdapter.ReadChar()
	self.hp = MsgAdapter.ReadInt()
	self.max_hp = MsgAdapter.ReadInt()
	self.move_speed = MsgAdapter.ReadInt()
	self.pos_x = MsgAdapter.ReadShort()
	self.pos_y = MsgAdapter.ReadShort()
	self.dir = MsgAdapter.ReadFloat()
	self.distance = MsgAdapter.ReadFloat()
	self.plat_type = MsgAdapter.ReadInt()
	self.appearance = ProtocolStruct.ReadRoleAppearance()
	self.vip_level = MsgAdapter.ReadChar()

	self.guild_post = MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()

	self.guild_id = MsgAdapter.ReadInt()
	self.guild_name = MsgAdapter.ReadStrN(32)
	self.avatar_key_big = MsgAdapter.ReadInt()
	self.avatar_key_small = MsgAdapter.ReadInt()
	self.shadow_type = MsgAdapter.ReadInt()
	self.shadow_param = MsgAdapter.ReadInt()
end

--模块操作返回结果
SCOperateResult = SCOperateResult or BaseClass(BaseProtocolStruct)
function SCOperateResult:__init()
	self.msg_type = 1145
end

function SCOperateResult:Decode()
	self.operate = MsgAdapter.ReadShort()
	self.result = MsgAdapter.ReadShort()
	self.param1 = MsgAdapter.ReadInt()
	self.param2 = MsgAdapter.ReadInt()
end

-- 世界事件物品进入可视区域
SCVisibleObjEnterWorldEventObj = SCVisibleObjEnterWorldEventObj or BaseClass(BaseProtocolStruct)
function SCVisibleObjEnterWorldEventObj:__init()
	self.msg_type = 1146
end

function SCVisibleObjEnterWorldEventObj:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	MsgAdapter.ReadShort()
	self.world_event_id = MsgAdapter.ReadInt()
	self.pos_x = MsgAdapter.ReadShort()
	self.pos_y = MsgAdapter.ReadShort()
	self.hp = MsgAdapter.ReadInt()
	self.max_hp = MsgAdapter.ReadInt()
end

-- 队友坐标
SCTeamMemberPosList = SCTeamMemberPosList or BaseClass(BaseProtocolStruct)
function SCTeamMemberPosList:__init()
	self.msg_type = 1147
end

function SCTeamMemberPosList:Decode()
	local member_count = MsgAdapter.ReadInt()
	self.team_member_list = {}
	for i = 1, member_count do
		local member_info = {}
		member_info.role_id = MsgAdapter.ReadInt()
		member_info.obj_id = MsgAdapter.ReadUShort()
		member_info.reserved = MsgAdapter.ReadChar()
		member_info.is_leave_scene = MsgAdapter.ReadChar()
		member_info.pos_x = MsgAdapter.ReadShort()
		member_info.pos_y = MsgAdapter.ReadShort()
		member_info.dir = MsgAdapter.ReadFloat()
		member_info.distance = MsgAdapter.ReadFloat()
		member_info.move_speed = MsgAdapter.ReadInt()
		self.team_member_list[i] = member_info
	end
end

-- 采集物信息改变
SCGatherChange = SCGatherChange or BaseClass(BaseProtocolStruct)
function SCGatherChange:__init()
	self.msg_type = 1148
end

function SCGatherChange:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.special_gather_type = MsgAdapter.ReadShort()
	self.gather_id = MsgAdapter.ReadInt()
	self.pos_x = MsgAdapter.ReadShort()
	self.pos_y = MsgAdapter.ReadShort()
	self.param = MsgAdapter.ReadInt()
	self.param1 = MsgAdapter.ReadInt()
	self.param2 = MsgAdapter.ReadStrN(32)
end

SCBossDpsFlag = SCBossDpsFlag or BaseClass(BaseProtocolStruct)
function SCBossDpsFlag:__init()
	self.msg_type = 1149
end

function SCBossDpsFlag:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.top_dps_flag = MsgAdapter.ReadShort()
	self.boss_id = MsgAdapter.ReadUShort()
	MsgAdapter.ReadShort()
end


-- 移动请求
CSObjMove = CSObjMove or BaseClass(BaseProtocolStruct)
function CSObjMove:__init()
	self.msg_type = 1150

	self.dir = 0.0
	self.pos_x = 0
	self.pos_y = 0
	self.distance = 0
	self.height = 140
	self.is_press_onward = 0
end

function CSObjMove:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteFloat(self.dir)
	MsgAdapter.WriteShort(self.pos_x)
	MsgAdapter.WriteShort(self.pos_y)
	MsgAdapter.WriteFloat(self.distance)
	MsgAdapter.WriteShort(self.height)
	MsgAdapter.WriteShort(self.is_press_onward)
end

-- 开始采集
CSStartGatherReq = CSStartGatherReq or BaseClass(BaseProtocolStruct)
function CSStartGatherReq:__init()
	self.msg_type = 1151

	self.gather_obj_id = 0
	self.gather_count = 0
end

function CSStartGatherReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteUShort(self.gather_obj_id)
	MsgAdapter.WriteShort(self.gather_count)
end

--进入副本
CSEnterFB = CSEnterFB or BaseClass(BaseProtocolStruct)
function CSEnterFB:__init()
	self.msg_type = 1152

	self.fb_type = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
end

function CSEnterFB:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.fb_type)
	MsgAdapter.WriteShort(0)
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
	MsgAdapter.WriteInt(self.param_3)
end

--离开副本
CSLeaveFB = CSLeaveFB or BaseClass(BaseProtocolStruct)
function CSLeaveFB:__init()
	self.msg_type = 1153
end

function CSLeaveFB:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--改变怪物静止状态
CSCancelMonsterStaticState = CSCancelMonsterStaticState or BaseClass(BaseProtocolStruct)
function CSCancelMonsterStaticState:__init()
	self.msg_type = 1154
end

function CSCancelMonsterStaticState:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--请求所有对象的运动信息
CSGetAllObjMoveInfoReq = CSGetAllObjMoveInfoReq or BaseClass(BaseProtocolStruct)
function CSGetAllObjMoveInfoReq:__init()
	self.msg_type = 1158
end

function CSGetAllObjMoveInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--请求组队队员位置信息
CSReqTeamMemberPos = CSReqTeamMemberPos or BaseClass(BaseProtocolStruct)
function CSReqTeamMemberPos:__init()
	self.msg_type = 1164
end

function CSReqTeamMemberPos:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 停止采集
CSStopGatherReq = CSStopGatherReq or BaseClass(BaseProtocolStruct)
function CSStopGatherReq:__init()
	self.msg_type = 1165
end

function CSStopGatherReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 场景切线
CSChangeSceneLineReq = CSChangeSceneLineReq or BaseClass(BaseProtocolStruct)
function CSChangeSceneLineReq:__init()
	self.msg_type = 1166
	self.scene_key = 0
end

function CSChangeSceneLineReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.scene_key)
end

-- 采集物被采集信息广播
SCGatherBeGather = SCGatherBeGather or BaseClass(BaseProtocolStruct)
function SCGatherBeGather:__init()
	self.msg_type = 1167

	self.gather_role_obj_id = 0
	self.gather_obj_id = 0
end

function SCGatherBeGather:Decode()
	self.gather_role_obj_id = MsgAdapter.ReadUShort()
	self.gather_obj_id = MsgAdapter.ReadUShort()
	self.gather_id = MsgAdapter.ReadInt()
	self.left_gather_times = MsgAdapter.ReadShort()			-- 剩余采集次数
	MsgAdapter.ReadShort()
end

-- 角色任务形态表现
SCRoleAccetpTaskAppearn = SCRoleAccetpTaskAppearn or BaseClass(BaseProtocolStruct)
function SCRoleAccetpTaskAppearn:__init()
	self.msg_type = 1168

	self.obj_id = 0
	self.task_appearn = 0
	self.task_appearn_param_1 = 0
end

function SCRoleAccetpTaskAppearn:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.task_appearn = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	self.task_appearn_param_1 = MsgAdapter.ReadInt()
end

-- 购买经验副本次数
CSAutoFB = CSAutoFB or BaseClass(BaseProtocolStruct)
function CSAutoFB:__init()
	self.msg_type = 1163

	self.fb_type = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
	self.param_4 = 0
end

function CSAutoFB:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.fb_type)
	MsgAdapter.WriteShort(0)
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
	MsgAdapter.WriteInt(self.param_3)
	MsgAdapter.WriteInt(self.param_4)
end

SCBossDpsName = SCBossDpsName or BaseClass(BaseProtocolStruct)
function SCBossDpsName:__init()
	self.msg_type = 1169
end

function SCBossDpsName:Decode()
	self.dsp_name = MsgAdapter.ReadStrN(32)
end


SCNotifyAppearanceChangeInfo = SCNotifyAppearanceChangeInfo or BaseClass(BaseProtocolStruct)
function SCNotifyAppearanceChangeInfo:__init()
	self.msg_type = 1170
	self.reason_type = 0
	self.obj_id = 0
	self.param1 = 0
end

function SCNotifyAppearanceChangeInfo:Decode()
	self.reason_type = MsgAdapter.ReadShort()
	self.obj_id = MsgAdapter.ReadUShort()
	self.param1 = MsgAdapter.ReadInt()
end


