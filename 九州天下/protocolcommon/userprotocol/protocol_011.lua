
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
	self.origin_merge_server_id = MsgAdapter.ReadShort()
	self.hold_beauty_npcid = MsgAdapter.ReadUShort()
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
	self.husong_taskid = MsgAdapter.ReadUShort()				-- 护送id
	self.used_sprite_id = MsgAdapter.ReadUShort()				-- 仙女id
	self.use_sprite_imageid = MsgAdapter.ReadChar()				-- 精灵飞升形象
	self.used_sprite_quality = MsgAdapter.ReadChar()			-- 仙女品质等级
	self.chengjiu_title_level = MsgAdapter.ReadShort()			-- 成就称号等级
	self.sprite_name = MsgAdapter.ReadStrN(32)					-- 仙女名字
	self.avatar_key_big = MsgAdapter.ReadUInt()					-- 大头像
	self.avatar_key_small = MsgAdapter.ReadUInt()				-- 小头像
	self.guild_avatar_key_big = MsgAdapter.ReadUInt()			-- 公会大头像
	self.guild_avatar_key_small = MsgAdapter.ReadUInt()			-- 公会小头像
	self.flyup_use_image = MsgAdapter.ReadShort()				-- 坐骑飞升头像
	self.use_xiannv_id = MsgAdapter.ReadShort()					-- 仙女使用id
	self.used_sprite_jie = MsgAdapter.ReadShort()				-- 仙女阶数
	self.xianjie_level = MsgAdapter.ReadShort()					-- 仙阶等级
	self.tianxiange_level = MsgAdapter.ReadInt()				-- 天宫试练 通关层数
	self.jingling_phantom_img = MsgAdapter.ReadShort()          -- 精灵特殊形象
	self.top_dps_flag = MsgAdapter.ReadChar()					-- 最高dps标记
	self.first_hurt_flag = MsgAdapter.ReadChar()				-- 首刀标记
	self.pet_id = MsgAdapter.ReadInt()							-- 宠物ID
	self.pet_level = MsgAdapter.ReadShort()						-- 宠物等级
	self.pet_grade = MsgAdapter.ReadShort()						-- 宠物阶数
	self.pet_name = MsgAdapter.ReadStrN(32)						-- 宠物名字
	self.user_lq_special_img = MsgAdapter.ReadShort()          	-- 宠物特殊形象
	self.use_xiannv_halo_img = MsgAdapter.ReadShort()			-- 精灵光环使用形象

	self.multi_mount_res_id = MsgAdapter.ReadShort() 			-- 双人坐骑资源id
	self.multi_mount_is_owner = MsgAdapter.ReadShort() 			-- 是否当前双人坐骑的主人
	self.multi_mount_other_uid = MsgAdapter.ReadInt() 			-- 一起骑乘的玩家role_id

	self.little_pet_name = MsgAdapter.ReadStrN(32)				-- 小宠物名字
	self.little_pet_using_id = MsgAdapter.ReadShort() 			-- 小宠物使用形象id
	self.fight_mount_appeid = MsgAdapter.ReadShort()			-- 战斗坐骑外观
	self.xiannv_name = MsgAdapter.ReadStrN(32)					-- 仙女名字
	self.xiannv_huanhua_id = MsgAdapter.ReadShort() 			-- 仙女幻化id
	self.citan_color = MsgAdapter.ReadChar()					-- 刺探任务拿到的颜色
	self.is_neijian = MsgAdapter.ReadChar()						-- 是否是本国的内奸
	self.banzhuan_color = MsgAdapter.ReadChar()					-- 搬砖任务拿到的颜色
	self.beauty_used_seq = MsgAdapter.ReadChar()				-- 美人seq
	self.beauty_is_active_shenwu = MsgAdapter.ReadChar()		-- 美人是否已激活神武
	self.beauty_used_huanhua_seq = MsgAdapter.ReadChar()		-- 美人幻化seq
	self.wing_used_huanhua_seq = MsgAdapter.ReadChar()			-- 羽翼幻化seq
	self.mount_used_huanhua_seq = MsgAdapter.ReadChar()			-- 坐骑幻化seq
	self.total_strengthen_level = MsgAdapter.ReadShort()		-- 全身总强换等级

	self.wuqi_color = MsgAdapter.ReadInt()						-- 武器颜色
	self.total_capability = MsgAdapter.ReadInt()				-- 总战斗力
	self.junxian_level = MsgAdapter.ReadShort() 				-- 军衔等级
	self.baojia_speical_image_id = MsgAdapter.ReadShort() 		-- 穿戴宝甲套装
	self.shenbin_use_image_id = MsgAdapter.ReadChar() 			-- 穿戴神兵
	self.server_group = MsgAdapter.ReadChar()					-- 服务器组(公族/世族)
	MsgAdapter.ReadShort()
	self.touxian_level = MsgAdapter.ReadInt()					-- 头衔等级
	self.jingling_guanghuan_img_id = self.appearance.jingling_guanghuan_imageid     -- 美人光环
	self.baby_id = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()

	local attach_mask = MsgAdapter.ReadInt()
	local mask_t = bit:d2b(attach_mask)

	-- 仙盟数据
	if 0 ~= mask_t[32 - 0] then
		self.guild_id = MsgAdapter.ReadInt()
		self.guild_name = MsgAdapter.ReadStrN(32)
	else
		self.guild_id = 0
		self.guild_name = ""
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

	-- 夫妻特效
	if 0 ~= mask_t[32 - 13] then
		self.halo_type = MsgAdapter.ReadInt()
	else
		self.halo_type = 0
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
	MsgAdapter.ReadShort()
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

	self.unique_server_camp_id = {}
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
	self.camp_type = MsgAdapter.ReadInt()			-- 怪物所属阵营类型

	self.unique_server_camp_id = {}					-- 怪物所属的服务器阵营类型（用于在跨服做判断）
	self.unique_server_camp_id.plat_type = MsgAdapter.ReadInt()
	self.unique_server_camp_id.server_id = MsgAdapter.ReadInt()
	self.unique_server_camp_id.camp_type = MsgAdapter.ReadInt()

	self.disappear_time = MsgAdapter.ReadUInt()		-- 消失时间
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
	self.used_title = MsgAdapter.ReadUShort()
	self.guild_id = MsgAdapter.ReadInt()
	self.guild_name = MsgAdapter.ReadStrN(32)
	self.avatar_timestamp = MsgAdapter.ReadLL()
	self.shadow_type = MsgAdapter.ReadShort()
	self.shadow_param = MsgAdapter.ReadShort()

	--------------- G16当前协议---------------
	-- self.obj_id = MsgAdapter.ReadUShort()
	-- MsgAdapter.ReadShort()
	-- self.role_id = MsgAdapter.ReadInt()
	-- self.role_name = MsgAdapter.ReadStrN(32)
	-- self.level = MsgAdapter.ReadInt()
	-- self.avatar = MsgAdapter.ReadChar()
	-- self.prof = MsgAdapter.ReadChar()
	-- self.sex = MsgAdapter.ReadChar()
	-- self.camp = MsgAdapter.ReadChar()
	-- self.hp = MsgAdapter.ReadInt()
	-- self.max_hp = MsgAdapter.ReadInt()
	-- self.move_speed = MsgAdapter.ReadInt()
	-- self.pos_x = MsgAdapter.ReadShort()
	-- self.pos_y = MsgAdapter.ReadShort()
	-- self.dir = MsgAdapter.ReadFloat()
	-- self.distance = MsgAdapter.ReadFloat()
	-- self.plat_type = MsgAdapter.ReadInt()
	-- self.appearance = ProtocolStruct.ReadRoleAppearance()
	-- self.vip_level = MsgAdapter.ReadChar()

	-- self.guild_post = MsgAdapter.ReadChar()
	-- MsgAdapter.ReadShort()

	-- self.guild_id = MsgAdapter.ReadInt()
	-- self.guild_name = MsgAdapter.ReadStrN(32)
	-- self.avatar_key_big = MsgAdapter.ReadInt
	-- self.avatar_key_small = MsgAdapter.ReadInt
	-- self.shadow_type = MsgAdapter.ReadShort()
	-- self.shadow_param = MsgAdapter.ReadShort()
--------------- G16当前协议---------------
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
	self.is_auto = 0
end

function CSObjMove:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteFloat(self.dir)
	MsgAdapter.WriteShort(self.pos_x)
	MsgAdapter.WriteShort(self.pos_y)
	MsgAdapter.WriteFloat(self.distance)
	MsgAdapter.WriteShort(self.height)
	MsgAdapter.WriteShort(self.is_auto)					-- 是否自动寻路
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

--请求所有对象的运动信息
CSGetAllObjMoveInfoReq = CSGetAllObjMoveInfoReq or BaseClass(BaseProtocolStruct)
function CSGetAllObjMoveInfoReq:__init()
	self.msg_type = 1158
end

function CSGetAllObjMoveInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--扫荡副本
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

-- boss首刀
SCBossFirstHurtInfo = SCBossFirstHurtInfo or BaseClass(BaseProtocolStruct)
function SCBossFirstHurtInfo:__init()
	self.msg_type = 1167
end

function SCBossFirstHurtInfo:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.first_hurt_flag = MsgAdapter.ReadShort()
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

-- 请求获取场景中玩家数目
CSSceneRoleCountReq = CSSceneRoleCountReq or BaseClass(BaseProtocolStruct)
function CSSceneRoleCountReq:__init()
	self.msg_type = 1168
	self.scene_key = 0
end

function CSSceneRoleCountReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.scene_id)            -- 场景ID
	MsgAdapter.WriteInt(self.scene_key)           -- 场景key
end

-- 获取场景中玩家数目返回
SCSceneRoleCountAck = SCSceneRoleCountAck or BaseClass(BaseProtocolStruct)
function SCSceneRoleCountAck:__init()
	self.msg_type = 1169
end

function SCSceneRoleCountAck:Decode()
	self.camp_role_count = {}
	self.scene_id = MsgAdapter.ReadInt()  			-- 场景ID
	self.scene_key = MsgAdapter.ReadInt() 			-- 场景key
	self.role_count = MsgAdapter.ReadInt() 			-- 玩家数量
	for i=1, CAMP_TYPE.CAMP_TYPE_MAX do
		local vo = {}
		vo[i] = MsgAdapter.ReadInt()
		self.camp_role_count[i] = vo
	end
	table.remove(self.camp_role_count, 1)
end

--组队的召集请求
CSTeamCallReq = CSTeamCallReq or BaseClass(BaseProtocolStruct)
function CSTeamCallReq:__init()
	self.msg_type = 1170
end

function CSTeamCallReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--组队召集请求信息返回
SCTeamTransferInfo = SCTeamTransferInfo or BaseClass(BaseProtocolStruct)
function SCTeamTransferInfo:__init()
	self.msg_type = 1171
	self.uid = 0
	self.post = 0
	self.name = ""
	self.scene_id = 0
	self.x = 0
	self.y = 0
end

function SCTeamTransferInfo:Decode()
	self.uid = MsgAdapter.ReadInt()
	self.post = MsgAdapter.ReadInt()
	self.name = MsgAdapter.ReadStrN(32)
	self.scene_id = MsgAdapter.ReadInt()
	self.x =  MsgAdapter.ReadInt()
	self.y = MsgAdapter.ReadInt()
end

-- boss掉落归属信息
SCMonsterFirstHitInfo = SCMonsterFirstHitInfo or BaseClass(BaseProtocolStruct)
function SCMonsterFirstHitInfo:__init()
	self.msg_type = 1172
end

function SCMonsterFirstHitInfo:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.is_show = MsgAdapter.ReadShort()
	self.first_hit_user_name = MsgAdapter.ReadStrN(32)
end

-- 采集物被采集信息广播 1173
SCGatherBeGather = SCGatherBeGather or BaseClass(BaseProtocolStruct)
function SCGatherBeGather:__init()
	self.msg_type = 1173

	self.gather_role_obj_id = 0
	self.gather_obj_id = 0
end

function SCGatherBeGather:Decode()
	self.gather_role_obj_id = MsgAdapter.ReadUShort()
	self.gather_obj_id = MsgAdapter.ReadUShort()
end