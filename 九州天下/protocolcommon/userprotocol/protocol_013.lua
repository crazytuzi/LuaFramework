
-- 血量变化
SCObjChangeBlood = SCObjChangeBlood or BaseClass(BaseProtocolStruct)
function SCObjChangeBlood:__init()
	self.msg_type = 1300
end

function SCObjChangeBlood:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.deliverer = MsgAdapter.ReadUShort()
	self.skill = MsgAdapter.ReadUShort()
	self.fighttype = MsgAdapter.ReadUChar()
	self.product_method = MsgAdapter.ReadUChar()
	self.real_blood = MsgAdapter.ReadInt()
	self.blood = MsgAdapter.ReadInt()
	self.passive_flag = MsgAdapter.ReadInt()
end

-- 播放普通技能
SCPerformSkill = SCPerformSkill or BaseClass(BaseProtocolStruct)
function SCPerformSkill:__init()
	self.msg_type = 1301
end

function SCPerformSkill:Decode()
	self.deliverer = MsgAdapter.ReadUShort()
	self.target = MsgAdapter.ReadUShort()
	self.skill = MsgAdapter.ReadUShort()
	MsgAdapter.ReadShort()
	self.skill_data = MsgAdapter.ReadInt()
end

-- 复活
SCRoleReAlive = SCRoleReAlive or BaseClass(BaseProtocolStruct)
function SCRoleReAlive:__init()
	self.msg_type = 1302
end

function SCRoleReAlive:Decode()
	MsgAdapter.ReadShort()
	self.obj_id = MsgAdapter.ReadUShort()
	self.pos_x = MsgAdapter.ReadInt()
	self.pos_y = MsgAdapter.ReadInt()
end

-- 播放AOE技能
SCPerformAOESkill = SCPerformAOESkill or BaseClass(BaseProtocolStruct)
function SCPerformAOESkill:__init()
	self.msg_type = 1303
end

function SCPerformAOESkill:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.skill = MsgAdapter.ReadUShort()
	self.pos_x = MsgAdapter.ReadInt()
	self.pos_y = MsgAdapter.ReadInt()
	self.aoe_reason = MsgAdapter.ReadShort()
	self.target = MsgAdapter.ReadUShort()
	self.skill_data = MsgAdapter.ReadInt()
end

-- 广播魔法变动消息
SCObjChangeMP = SCObjChangeMP or BaseClass(BaseProtocolStruct)
function SCObjChangeMP:__init()
	self.msg_type = 1304
end

function SCObjChangeMP:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	MsgAdapter.ReadShort()
	self.mp = MsgAdapter.ReadInt()
end

-- 增加Buff
SCBuffAdd = SCBuffAdd or BaseClass(BaseProtocolStruct)
function SCBuffAdd:__init()
	self.msg_type = 1305
end

function SCBuffAdd:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.buff_type = MsgAdapter.ReadUShort()
end

-- 移除Buff
SCBuffRemove = SCBuffRemove or BaseClass(BaseProtocolStruct)
function SCBuffRemove:__init()
	self.msg_type = 1306
end

function SCBuffRemove:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.buff_type = MsgAdapter.ReadUShort()
end

-- Effect列表
SCEffectList = SCEffectList or BaseClass(BaseProtocolStruct)
function SCEffectList:__init()
	self.msg_type = 1307
end

function SCEffectList:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.count = MsgAdapter.ReadShort()

	self.effect_list = {}
	for i = 1, self.count do
		self.effect_list[i] = {}
		self.effect_list[i].effect_type = MsgAdapter.ReadChar()
		self.effect_list[i].product_method = MsgAdapter.ReadChar()
		self.effect_list[i].product_id = MsgAdapter.ReadUShort()
		self.effect_list[i].unique_key = MsgAdapter.ReadUInt()
		self.effect_list[i].client_effect_type = MsgAdapter.ReadInt()
		self.effect_list[i].merge_layer = MsgAdapter.ReadChar()
		MsgAdapter.ReadChar()

		self.effect_list[i].param_count = MsgAdapter.ReadShort()
		self.effect_list[i].param_list = {}
		for k = 1, self.effect_list[i].param_count do
			self.effect_list[i].param_list[k] = MsgAdapter.ReadInt()
		end
	end

end

-- Effect信息
SCEffectInfo = SCEffectInfo or BaseClass(BaseProtocolStruct)
function SCEffectInfo:__init()
	self.msg_type = 1308
end

function SCEffectInfo:Decode()
	self.buff_type = MsgAdapter.ReadShort()
	self.obj_id = MsgAdapter.ReadUShort()

	self.effect_type = MsgAdapter.ReadChar()
	self.product_method = MsgAdapter.ReadChar()
	self.product_id = MsgAdapter.ReadUShort()
	self.unique_key = MsgAdapter.ReadUInt()
	self.client_effect_type = MsgAdapter.ReadInt()
	self.merge_layer = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()

	self.param_count = MsgAdapter.ReadShort()
	self.param_list = {}
	for i = 1, self.param_count do
		self.param_list[i] = MsgAdapter.ReadInt()
	end
end

-- 删除Effect通知
SCEffectRemove = SCEffectRemove or BaseClass(BaseProtocolStruct)
function SCEffectRemove:__init()
	self.msg_type = 1309
end

function SCEffectRemove:Decode()
	self.effect_key = MsgAdapter.ReadUInt()
end

-- Buff标记
SCBuffMark = SCBuffMark or BaseClass(BaseProtocolStruct)
function SCBuffMark:__init()
	self.msg_type = 1311
end

function SCBuffMark:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	MsgAdapter.ReadShort()
	self.buff_mark_low = MsgAdapter.ReadUInt()		-- 低位
	self.buff_mark_high = MsgAdapter.ReadUInt()		-- 高位
end

-- 击杀目标位置
SCSkillTargetPos = SCSkillTargetPos or BaseClass(BaseProtocolStruct)
function SCSkillTargetPos:__init()
	self.msg_type = 1312
end

function SCSkillTargetPos:Decode()
	self.target_obj_id = MsgAdapter.ReadUShort()
	self.reserve = MsgAdapter.ReadShort()
	self.pos_x = MsgAdapter.ReadInt()
	self.pos_y = MsgAdapter.ReadInt()
end

-- 播放技能施法阶段
SCSkillPhase = SCSkillPhase or BaseClass(BaseProtocolStruct)
function SCSkillPhase:__init()
	self.msg_type = 1314
end

-- 读条技能释放阶段
function SCSkillPhase:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.skill_id = MsgAdapter.ReadUShort()
	self.phase = MsgAdapter.ReadInt()
end

-- 战斗特殊飘字（如有防护罩被打时飘吸收的伤害）
SCFightSpecialFloat = SCFightSpecialFloat or BaseClass(BaseProtocolStruct)
function SCFightSpecialFloat:__init()
	self.msg_type = 1318
end

function SCFightSpecialFloat:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.float_type = MsgAdapter.ReadShort()
	self.float_value = MsgAdapter.ReadInt()
	self.skill_special_effect = MsgAdapter.ReadShort()
	self.deliver_obj_id = MsgAdapter.ReadUShort()
end

-- 广播世界BOSS护盾次数变化
SCSpecialShieldChangeBlood = SCSpecialShieldChangeBlood or BaseClass(BaseProtocolStruct)
function SCSpecialShieldChangeBlood:__init()
	self.msg_type = 1319
	self.obj_id = 0
	self.real_hurt = 0
	self.left_times = 0
	self.max_times = 0
end

function SCSpecialShieldChangeBlood:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	MsgAdapter.ReadShort()
	self.real_hurt = MsgAdapter.ReadInt()
	self.left_times = MsgAdapter.ReadInt()
	self.max_times = MsgAdapter.ReadInt()
end

--变身形象广播
SCBianShenView = SCBianShenView or BaseClass(BaseProtocolStruct)
function SCBianShenView:__init()
	self.msg_type = 1320
	self.obj_id = 0
	self.show_image = 0
end

function SCBianShenView:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.show_image = MsgAdapter.ReadShort()
end

-- 进阶装备技能改变
SCUpGradeSkillInfo = SCUpGradeSkillInfo or BaseClass(BaseProtocolStruct)
function SCUpGradeSkillInfo:__init()
	self.msg_type = 1321
	self.upgrade_next_skill = 0
	self.upgrade_cur_calc_num = 0
end

function SCUpGradeSkillInfo:Decode()
	self.upgrade_next_skill = MsgAdapter.ReadInt()
	self.upgrade_cur_calc_num = MsgAdapter.ReadInt()
end

-- 使用技能请求
CSPerformSkillReq = CSPerformSkillReq or BaseClass(BaseProtocolStruct)
function CSPerformSkillReq:__init()
	self.msg_type = 1350

	self.skill_index = 0
	self.pos_x = 0
	self.pos_y = 0
	self.target_id = 0
	self.is_specialskill = 0
	self.client_pos_x = 0
	self.client_pos_y = 0
	self.skill_data = 0
end

function CSPerformSkillReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.skill_index)
	MsgAdapter.WriteInt(self.pos_x)
	MsgAdapter.WriteInt(self.pos_y)
	MsgAdapter.WriteUShort(self.target_id)
	MsgAdapter.WriteShort(self.is_specialskill)
	MsgAdapter.WriteShort(self.client_pos_x)
	MsgAdapter.WriteShort(self.client_pos_y)
	MsgAdapter.WriteInt(self.skill_data)
end

-- 复活请求
CSRoleReAliveReq = CSRoleReAliveReq or BaseClass(BaseProtocolStruct)
function CSRoleReAliveReq:__init()
	self.msg_type = 1351

	self.realive_type = 0	-- 0回城复活 1使用物品原地复活 2自动购买原地复活
	self.is_timeout_req = 0
	self.item_index = 0
end

function CSRoleReAliveReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteChar(self.realive_type)
	MsgAdapter.WriteChar(self.is_timeout_req)
	MsgAdapter.WriteShort(self.item_index)
end

-- 拉取EffectList请求
CSGetEffectListReq = CSGetEffectListReq or BaseClass(BaseProtocolStruct)
function CSGetEffectListReq:__init()
	self.msg_type = 1352

	self.target_obj_id = -1
end

function CSGetEffectListReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteUShort(self.target_obj_id)
	MsgAdapter.WriteShort(0)
end

------------------------ 复活 begin -------------------------
-- 返回国家复活次数
SCRoleReAliveCostType = SCRoleReAliveCostType or BaseClass(BaseProtocolStruct)
function SCRoleReAliveCostType:__init()
	self.msg_type = 1357

	self.local_revive_type = 0
	self.param2 = 0
end

function SCRoleReAliveCostType:Decode()
	self.local_revive_type = MsgAdapter.ReadUShort()	-- 0代表可用国家免费复活,1代表复活石复活,2代表绑元复活,3代表元宝复活
	self.param2 = MsgAdapter.ReadShort()				-- 可用国家免费复活时,代表剩余的复活次数,可用元宝复活时,代表花费的元宝
end
------------------------ 复活 end ---------------------------

CSChongfengReq = CSChongfengReq or BaseClass(BaseProtocolStruct)
function CSChongfengReq:__init()
	self.msg_type = 1358

	self.target_obj_id = -1
end

function CSChongfengReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteUShort(self.target_obj_id)
	MsgAdapter.WriteShort(0)
end

-- 播放击杀数值
SCContinueKillInfo = SCContinueKillInfo or BaseClass(BaseProtocolStruct)
function SCContinueKillInfo:__init()
	self.msg_type = 1323

	self.kill_count = 0
	self.trigger_continue_kill_invalid_timestamp = 0
end

function SCContinueKillInfo:Decode()
	self.kill_count = MsgAdapter.ReadInt()
	self.trigger_continue_kill_invalid_timestamp = MsgAdapter.ReadUInt()
end