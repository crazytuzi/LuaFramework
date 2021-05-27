
-- 登录角色请求
CSLoginRoleReq = CSLoginRoleReq or BaseClass(BaseProtocolStruct)
function CSLoginRoleReq:__init()
	self:InitMsgType(0, 1)
	self.account_id = 0
	self.role_id = 0
	self.role_index = 0
end

function CSLoginRoleReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUInt(self.account_id)
	MsgAdapter.WriteUInt(self.role_id)
	MsgAdapter.WriteInt(self.role_index)
end

-- 心跳
CSHeartBeatReq = CSHeartBeatReq or BaseClass(BaseProtocolStruct)
function CSHeartBeatReq:__init()
	self:InitMsgType(0, 2)
end

function CSHeartBeatReq:Encode()
	self:WriteBegin()
end

-- 选择实体
CSSelectObjReq = CSSelectObjReq or BaseClass(BaseProtocolStruct)
function CSSelectObjReq:__init()
	self:InitMsgType(0, 3)
	self.obj_id = 0
end

function CSSelectObjReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteLL(self.obj_id)
end

-- 设置鼠标的点中场景的位置
CSClickScenePosReq = CSClickScenePosReq or BaseClass(BaseProtocolStruct)
function CSClickScenePosReq:__init()
	self:InitMsgType(0, 4)
	self.click_x = 0
	self.click_y = 0
end

function CSClickScenePosReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUShort(self.click_x)
	MsgAdapter.WriteUShort(self.click_y)
end

-- NPC对话请求
CSNpcTalkReq = CSNpcTalkReq or BaseClass(BaseProtocolStruct)
function CSNpcTalkReq:__init()
	self:InitMsgType(0, 5)
	self.obj_id = 0
	self.func_name = ""
end

function CSNpcTalkReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteLL(self.obj_id)
	MsgAdapter.WriteStr(self.func_name)
end

-- 点击NPC对话索引
CSClickNpcTalkReq = CSClickNpcTalkReq or BaseClass(BaseProtocolStruct)
function CSClickNpcTalkReq:__init()
	self:InitMsgType(0, 6)
	self.obj_id = 0
	self.index = 0
	self.msg_id = 0
end

function CSClickNpcTalkReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteLL(self.obj_id)
	MsgAdapter.WriteUChar(self.index)
	MsgAdapter.WriteInt(self.msg_id)
end

-- 测试心跳包
CSTestHeartBeatReq = CSTestHeartBeatReq or BaseClass(BaseProtocolStruct)
function CSTestHeartBeatReq:__init()
	self:InitMsgType(0, 7)
	self.cur_time = 0									-- 当前时间/毫秒
end

function CSTestHeartBeatReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteLL(self.cur_time)
end

-- 内功升级请求
CSInnerUpReq = CSInnerUpReq or BaseClass(BaseProtocolStruct)
function CSInnerUpReq:__init()
	self:InitMsgType(0, 8)
end

function CSInnerUpReq:Encode()
	self:WriteBegin()
end

-- 内功资质注入
CSInnerEquip = CSInnerEquip or BaseClass(BaseProtocolStruct)
function CSInnerEquip:__init()
	self:InitMsgType(0, 9)
	self.series = 0
end

function CSInnerEquip:Encode()
	self:WriteBegin()
	CommonReader.WriteSeries(self.series)
end

-- 神鼎升级
CSShenDingUP = CSShenDingUP or BaseClass(BaseProtocolStruct)
function CSShenDingUP:__init()
	self:InitMsgType(0, 10)
end

function CSShenDingUP:Encode()
	self:WriteBegin()
end

-- 领取开服限时任务活动奖励
CSRecTimeLimitTaskReward = CSRecTimeLimitTaskReward or BaseClass(BaseProtocolStruct)
function CSRecTimeLimitTaskReward:__init()
	self:InitMsgType(0, 11)
	self.task_type = 0	-- 限时任务类型(0开始)
end

function CSRecTimeLimitTaskReward:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.task_type)
end

--威望任务挑战
-- CSPrestigeTaskReq = CSPrestigeTaskReq or BaseClass(BaseProtocolStruct)
-- function CSPrestigeTaskReq:__init()
-- 	self:InitMsgType(0, 12)
-- 	self.task_type = 0
-- end

-- function CSPrestigeTaskReq:Encode()
-- 	self:WriteBegin()
-- 	MsgAdapter.WriteUChar(self.task_type)
-- end

--领取威望任务奖励
-- CSPrestigeTaskAwardReq = CSPrestigeTaskAwardReq or BaseClass(BaseProtocolStruct)
-- function CSPrestigeTaskAwardReq:__init()
-- 	self:InitMsgType(0, 13)
-- 	self.task_type = 0
-- end

-- function CSPrestigeTaskAwardReq:Encode()
-- 	self:WriteBegin()
-- 	MsgAdapter.WriteUChar(self.task_type)
-- end

-- 领取活跃度奖励
CSReciverRewardReq = CSReciverRewardReq or BaseClass(BaseProtocolStruct)
function CSReciverRewardReq:__init()
	self:InitMsgType(0, 12)
	self.rew_index = 0 	
end

function CSReciverRewardReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.rew_index)
end

--内功一键升级请求
CSInnerOneKeyUpReq = CSInnerOneKeyUpReq or BaseClass(BaseProtocolStruct)
function CSInnerOneKeyUpReq:__init()
	self:InitMsgType(0, 21)
end

function CSInnerOneKeyUpReq:Encode()
	self:WriteBegin()
end

-- 激活钻石萌宠
CSActivationDiamondPetReq = CSActivationDiamondPetReq or BaseClass(BaseProtocolStruct)
function CSActivationDiamondPetReq:__init()
	self:InitMsgType(0, 22)
end

function CSActivationDiamondPetReq:Encode()
	self:WriteBegin()
end

-- 挖掘怪物尸体
CSExcavateMonsterCorpseReq = CSExcavateMonsterCorpseReq or BaseClass(BaseProtocolStruct)
function CSExcavateMonsterCorpseReq:__init()
	self:InitMsgType(0, 23)
	self.obj_id = 0 -- 怪物的实体ID
end

function CSExcavateMonsterCorpseReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteLL(self.obj_id)
end

--领取任务好礼小任务奖励
CSTaskGiftSmallReq = CSTaskGiftSmallReq or BaseClass(BaseProtocolStruct)
function CSTaskGiftSmallReq:__init()
	self:InitMsgType(0, 24)
	self.gift_index = 0 		-- 小任务对应索引（从0开始	）
end

function CSTaskGiftSmallReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.gift_index)
end

--领取任务好礼大任务奖励
CSTaskGiftBigReq = CSTaskGiftBigReq or BaseClass(BaseProtocolStruct)
function CSTaskGiftBigReq:__init()
	self:InitMsgType(0, 25)
end

function CSTaskGiftBigReq:Encode()
	self:WriteBegin()
end

-- 文明度信息请求
CSCivilizationReq = CSCivilizationReq or BaseClass(BaseProtocolStruct)
function CSCivilizationReq:__init()
	self:InitMsgType(0, 57)
end

function CSCivilizationReq:Encode()
	self:WriteBegin()
end

----------------------------------------------------------------------
-- 登录角色应答
SCLoginRoleAck = SCLoginRoleAck or BaseClass(BaseProtocolStruct)
function SCLoginRoleAck:__init()
	self:InitMsgType(0, 1)
	self.result = 0
end

function SCLoginRoleAck:Decode()
	self.result = MsgAdapter.ReadUChar()
end

-- 实体出现，不包括玩家
SCVisibleObjEnter = SCVisibleObjEnter or BaseClass(BaseProtocolStruct)
function SCVisibleObjEnter:__init()
	self:InitMsgType(0, 2)
	self.entity_type = 0
	self.obj_id = 0
	self.all_name = ""
	self.attr = {}
end

function SCVisibleObjEnter:Decode()
	self.entity_type = MsgAdapter.ReadUChar()
	self.obj_id = MsgAdapter.ReadLL()
	self.all_name = MsgAdapter.ReadStr()
	
	self.attr = {}
	self.attr[OBJ_ATTR.ENTITY_X] = MsgAdapter.ReadUShort()
	self.attr[OBJ_ATTR.ENTITY_Y] = MsgAdapter.ReadUShort()
	self.attr[OBJ_ATTR.ENTITY_MODEL_ID] = MsgAdapter.ReadUInt()
	self.attr[OBJ_ATTR.ENTITY_DIR] = MsgAdapter.ReadUChar()
	
	if self.entity_type == EntityType.Hero
	or IsMonsterByEntityType(self.entity_type)
	or self.entity_type == EntityType.ActorSlave
	or self.entity_type == EntityType.Pet 
	or self.entity_type == EntityType.Saparation then
		
		self.attr[OBJ_ATTR.CREATURE_LEVEL] = MsgAdapter.ReadUShort()
		self.attr[OBJ_ATTR.CREATURE_HP] = MsgAdapter.ReadUInt()
		self.attr[OBJ_ATTR.CREATURE_MP] = MsgAdapter.ReadUInt()
		self.attr[OBJ_ATTR.CREATURE_MAX_HP] = MsgAdapter.ReadUInt()
		self.attr[OBJ_ATTR.CREATURE_MAX_MP] = MsgAdapter.ReadUInt()
		self.attr[OBJ_ATTR.CREATURE_MOVE_SPEED] = MsgAdapter.ReadUShort()
		self.attr[OBJ_ATTR.CREATURE_ATTACK_SPEED] = MsgAdapter.ReadUShort()
		self.attr[OBJ_ATTR.CREATURE_STATE] = MsgAdapter.ReadUInt()
		self.attr[OBJ_ATTR.CREATURE_COLOR] = MsgAdapter.ReadUInt()
		self.mabi_race = MsgAdapter.ReadUInt() 	-- 宠物攻击麻痹几率
		self.monster_race = MsgAdapter.ReadUChar()
		self.name_color = MsgAdapter.ReadUInt()
		
		self.monster_type = 0
		self.monster_id = 0
		if self.entity_type == EntityType.Pet then
			self.monster_type = MsgAdapter.ReadUChar()
		elseif IsMonsterByEntityType(self.entity_type) then
			self.monster_type = MsgAdapter.ReadUChar()
			self.monster_id = MsgAdapter.ReadInt()
			if self.monster_type == MONSTER_TYPE.BOSS then
				self.ascription = MsgAdapter.ReadStr()
			end
			self.attr[OBJ_ATTR.ACTOR_EQUIP_WEIGHT] = MsgAdapter.ReadInt()	-- 盾次数
		end
		
		self.atk_type = MsgAdapter.ReadUChar()	-- 攻击类型，如果是怪物低4位为攻击类型；高4位为怪物头衔
		
		self.attr[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE] = MsgAdapter.ReadUInt()
		self.attr[OBJ_ATTR.ACTOR_WING_APPEARANCE] = MsgAdapter.ReadUInt()
		
		self.buff_list = {}
		self.buff_count = MsgAdapter.ReadUChar()
		for i = 1, self.buff_count do
			local buff = {}
			buff.buff_id = MsgAdapter.ReadUShort()
			buff.buff_type = MsgAdapter.ReadUShort()
			buff.buff_group = MsgAdapter.ReadUChar()
			buff.buff_time = CommonReader.ReadCD()
			buff.buff_name = MsgAdapter.ReadStr()
			buff.buff_value = CommonReader.ReadObjBuffAttr(buff.buff_type)
			buff.buff_cycle = MsgAdapter.ReadUShort()
			buff.buff_icon = MsgAdapter.ReadUChar()
			self.buff_list[i] = buff
		end
		
		self.effect_count = MsgAdapter.ReadUChar()
		self.effect_list = {}
		for i = 1, self.effect_count do
			self.effect_list[i] = {
				effect_type = MsgAdapter.ReadUChar(),
				effect_id = MsgAdapter.ReadUShort(),
				remain_time = MsgAdapter.ReadUInt(),
			}
		end
		
		self.owner_obj_id = MsgAdapter.ReadLL()
		self.is_hide_name = MsgAdapter.ReadUChar()
	elseif self.entity_type == EntityType.Npc then
		self.npc_id = MsgAdapter.ReadInt()
		self.npc_type = MsgAdapter.ReadChar()
		self.task_state = MsgAdapter.ReadUChar()
		self.is_special_model = MsgAdapter.ReadUChar()
		if 1 == self.is_special_model then
			self.attr[OBJ_ATTR.ACTOR_SEX] = MsgAdapter.ReadUChar()
			self.attr[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE] = MsgAdapter.ReadInt()
			self.attr[OBJ_ATTR.ACTOR_WING_APPEARANCE] = MsgAdapter.ReadInt()
			self.attr[OBJ_ATTR.ACTOR_MAGIC_APPEARANCE] = MsgAdapter.ReadInt()
		end
	end
end

-- 创建主角
SCCreateMainRole = SCCreateMainRole or BaseClass(BaseProtocolStruct)
function SCCreateMainRole:__init()
	self:InitMsgType(0, 3)
	self.obj_id = 0
	self.attr = {}
	self.up_num = 0
	self.down_num = 0
	self.all_name = ""			-- 角色名\团体名\帮派\帮派的排名\摊位名
	self.ip_str = ""
	self.attr_other = {}
	self.create_time = 0		-- 角色创建时间
	self.primary_server_id = 0	-- 原服务器id
end

function SCCreateMainRole:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	local len = MsgAdapter.ReadUShort()
	
	for i = 0, OBJ_ATTR.MAX - 1 do
		if i == OBJ_ATTR.ACTOR_DIERRFRESHCD then
			self.attr[i] = CommonReader.ReadServerUnixTime()
		else
			self.attr[i] = CommonReader.ReadObjAttr(i)
		end
	end
	
	self.all_name = MsgAdapter.ReadStr()
	self.ip_str = MsgAdapter.ReadStr()
	self.create_time = MsgAdapter.ReadUInt()
	self.primary_server_id = MsgAdapter.ReadInt()
end

-- 角色进入视野
SCVisibleObjEnterRole = SCVisibleObjEnterRole or BaseClass(BaseProtocolStruct)
function SCVisibleObjEnterRole:__init()
	self:InitMsgType(0, 4)
	self.obj_id = 0
	self.all_name = ""
	self.name_color = 0
	self.is_transport = 0	-- 是否传送
	self.attr = {}
	self.up_num = 0
	self.down_num = 0
	self.attr_other = {}
	self.effect_count = 0
	self.effect_list = {}
end

function SCVisibleObjEnterRole:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.all_name = MsgAdapter.ReadStr()
	self.is_transport = MsgAdapter.ReadUChar()
	
	self.attr[OBJ_ATTR.ENTITY_X] = MsgAdapter.ReadUShort()
	self.attr[OBJ_ATTR.ENTITY_Y] = MsgAdapter.ReadUShort()
	self.attr[OBJ_ATTR.ENTITY_MODEL_ID] = MsgAdapter.ReadInt()
	self.attr[OBJ_ATTR.CREATURE_HP] = MsgAdapter.ReadUInt()
	self.attr[OBJ_ATTR.CREATURE_MP] = MsgAdapter.ReadUInt()
	self.attr[OBJ_ATTR.CREATURE_MAX_HP] = MsgAdapter.ReadUInt()
	self.attr[OBJ_ATTR.CREATURE_MAX_MP] = MsgAdapter.ReadUInt()
	self.attr[OBJ_ATTR.ACTOR_INNER] = MsgAdapter.ReadUInt()
	self.attr[OBJ_ATTR.ACTOR_MAX_INNER] = MsgAdapter.ReadUInt()
	self.attr[OBJ_ATTR.CREATURE_MOVE_SPEED] = MsgAdapter.ReadUShort()
	self.attr[OBJ_ATTR.ACTOR_SEX] = MsgAdapter.ReadUChar()
	self.attr[OBJ_ATTR.ACTOR_PROF] = MsgAdapter.ReadUChar()
	self.attr[OBJ_ATTR.CREATURE_LEVEL] = MsgAdapter.ReadUShort()
	self.attr[OBJ_ATTR.ACTOR_CIRCLE] = MsgAdapter.ReadUInt()
	self.attr[OBJ_ATTR.ACTOR_APOTHEOSIZE_LEVEL] = MsgAdapter.ReadUInt()
	self.attr[OBJ_ATTR.ACTOR_PK_VALUE] = MsgAdapter.ReadUInt()
	self.attr[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE] = MsgAdapter.ReadInt()
	self.attr[OBJ_ATTR.ACTOR_MOUNT_APPEARANCE] = MsgAdapter.ReadInt()
	self.attr[OBJ_ATTR.ACTOR_WING_APPEARANCE] = MsgAdapter.ReadInt()
	self.attr[OBJ_ATTR.ACTOR_MAGIC_APPEARANCE] = MsgAdapter.ReadInt()
	self.attr[OBJ_ATTR.ACTOR_FOOT_APPEARANCE] = MsgAdapter.ReadUInt()
	self.attr[OBJ_ATTR.ACTOR_SOCIAL_MASK] = MsgAdapter.ReadInt()
	self.attr[OBJ_ATTR.ENTITY_AVATAR_ID] = MsgAdapter.ReadUShort()
	self.attr[OBJ_ATTR.CREATURE_ATTACK_SPEED] = MsgAdapter.ReadUShort()
	self.attr[OBJ_ATTR.ENTITY_DIR] = MsgAdapter.ReadUChar()
	self.attr[OBJ_ATTR.CREATURE_STATE] = MsgAdapter.ReadUInt()
	self.attr[OBJ_ATTR.ACTOR_VIP_GRADE] = MsgAdapter.ReadInt()
	self.attr[OBJ_ATTR.ACTOR_TEAM_ID] = MsgAdapter.ReadInt()
	self.attr[OBJ_ATTR.ACTOR_GUILD_ID] = MsgAdapter.ReadInt()
	self.attr[OBJ_ATTR.ACTOR_CAMP] = MsgAdapter.ReadUChar()
	self.attr[OBJ_ATTR.ACTOR_HEAD_TITLE] = MsgAdapter.ReadUInt()
	self.attr[OBJ_ATTR.ACTOR_CURTITLE] = MsgAdapter.ReadUInt()
	self.attr[OBJ_ATTR.ACTOR_RIDE_LEVEL] = MsgAdapter.ReadInt()
	self.attr[OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE] = MsgAdapter.ReadUInt()
	self.attr[OBJ_ATTR.ACTOR_WARPATH_ID] = MsgAdapter.ReadUInt()
	
	self.name_color = MsgAdapter.ReadUInt()
	
	self.attr[OBJ_ATTR.CREATURE_COLOR] = MsgAdapter.ReadUInt()
	self.attr[OBJ_ATTR.ACTOR_WARDROBE] = MsgAdapter.ReadUInt()
	self.attr[OBJ_ATTR.ACTOR_BATTLE_POWER] = MsgAdapter.ReadUInt()
	self.attr[OBJ_ATTR.ACTOR_CRITRATE] = MsgAdapter.ReadUInt()
	self.attr[OBJ_ATTR.ACTOR_RESISTANCECRIT] = MsgAdapter.ReadUInt()
	self.attr[OBJ_ATTR.ACTOR_RESISTANCECRITRATE] = MsgAdapter.ReadUInt()
	self.attr[OBJ_ATTR.ACTOR_BOSSCRITRATE] = MsgAdapter.ReadUInt()
	self.attr[OBJ_ATTR.ACTOR_BATTACKBOSSCRITVALUE] = MsgAdapter.ReadUInt()
	self.attr[OBJ_ATTR.ACTOR_DIERRFRESHCD] = CommonReader.ReadServerUnixTime()
	self.name_color_state = MsgAdapter.ReadUChar()
	
	self.effect_count = MsgAdapter.ReadUChar()
	self.effect_list = {}
	for i = 1, self.effect_count do
		self.effect_list[i] = {
			effect_type = MsgAdapter.ReadUChar(),
			effect_id = MsgAdapter.ReadUShort(),
			remain_time = MsgAdapter.ReadUInt(),
		}
	end
	
	self.attr[OBJ_ATTR.ACTOR_FLAMINTAPPEARANCEID] = MsgAdapter.ReadUInt()
	self.attr[OBJ_ATTR.ACTOR_ESCORT_FLAG] = MsgAdapter.ReadUInt()
	self.attr[OBJ_ATTR.ACTOR_WINGEQUIP_APPEARANCE] = MsgAdapter.ReadUInt()
	self.attr[OBJ_ATTR.ACTOR_THANOSGLOVE_APPEARANCE] = MsgAdapter.ReadUInt()
	self.attr[OBJ_ATTR.ACTOR_CUTTING_LEVEL] = MsgAdapter.ReadUInt() -- ushort: 0切割等级, ushort: 1(钻石会员等级)
	self.attr[OBJ_ATTR.ACTOR_DIAMONDSPETS_APPEARANCE] = MsgAdapter.ReadUInt() -- 萌宠等级
end

-- 实体消失
SCVisibleObjLeave = SCVisibleObjLeave or BaseClass(BaseProtocolStruct)
function SCVisibleObjLeave:__init()
	self:InitMsgType(0, 5)
	self.obj_id = 0
end

function SCVisibleObjLeave:Decode()
	self.obj_id = MsgAdapter.ReadLL()
end

-- 实体属性改变
SCEntityAttrChange = SCEntityAttrChange or BaseClass(BaseProtocolStruct)
function SCEntityAttrChange:__init()
	self:InitMsgType(0, 6)
	self.obj_id = 0
	self.attr_count = 0
	self.attr_list = {}
end

function SCEntityAttrChange:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.attr_count = MsgAdapter.ReadUChar()
	self.attr_list = {}
	for i = 1, self.attr_count do
		self.attr_list[i] = CommonReader.ReadObjAttrTable()
	end
end

-- 主角属性改变
SCMainRoleAttrChange = SCMainRoleAttrChange or BaseClass(BaseProtocolStruct)
function SCMainRoleAttrChange:__init()
	self:InitMsgType(0, 7)
	self.attr_count = 0
	self.attr_list = {}
end

function SCMainRoleAttrChange:Decode()
	self.attr_count = MsgAdapter.ReadUChar()
	self.attr_list = {}
	for i = 1, self.attr_count do
		self.attr_list[i] = CommonReader.ReadObjAttrTable()
	end
end

-- 重置位置
SCRestPos = SCRestPos or BaseClass(BaseProtocolStruct)
function SCRestPos:__init()
	self:InitMsgType(0, 8)
	self.pos_x = 0
	self.pos_y = 0
end

function SCRestPos:Decode()
	self.pos_x = MsgAdapter.ReadUShort()
	self.pos_y = MsgAdapter.ReadUShort()
end

-- 实体移动
SCObjMove = SCObjMove or BaseClass(BaseProtocolStruct)
function SCObjMove:__init()
	self:InitMsgType(0, 9)
	self.obj_id = 0
	self.pos_x = 0
	self.pos_y = 0
	self.move_speed = 0
end

function SCObjMove:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.pos_x = MsgAdapter.ReadUShort()
	self.pos_y = MsgAdapter.ReadUShort()
	self.move_speed = MsgAdapter.ReadUShort()
end

-- 心跳应答
SCHeartBeatAck = SCHeartBeatAck or BaseClass(BaseProtocolStruct)
function SCHeartBeatAck:__init()
	self:InitMsgType(0, 10)
	self.server_time = 0
end

function SCHeartBeatAck:Decode()
	self.server_time = MsgAdapter.ReadLL()
end

-- 下发npc的对话内容
SCNpcTalkAck = SCNpcTalkAck or BaseClass(BaseProtocolStruct)
function SCNpcTalkAck:__init()
	self:InitMsgType(0, 11)
	self.is_open = 0
	self.obj_id = 0
	self.dialog_type = 0
	self.talk_str = ""
end

function SCNpcTalkAck:Decode()
	self.is_open = MsgAdapter.ReadUChar()
	self.obj_id = MsgAdapter.ReadLL()
	self.dialog_type = MsgAdapter.ReadUChar()
	if 0 ~= self.is_open then
		self.talk_str = MsgAdapter.ReadStr()
	end
end

-- 通知客户端打开一个界面
SCOpenView = SCOpenView or BaseClass(BaseProtocolStruct)
function SCOpenView:__init()
	self:InitMsgType(0, 12)
	self.view_type = 0
	self.param_str = ""
end

function SCOpenView:Decode()
	self.view_type = MsgAdapter.ReadUShort()
	self.is_close = MsgAdapter.ReadUShort() -- 0打开, 1关闭
	self.param_str = MsgAdapter.ReadStr()
end

-- 切换场景
SCChangeScene = SCChangeScene or BaseClass(BaseProtocolStruct)
function SCChangeScene:__init()
	self:InitMsgType(0, 13)
	self.scene_name = ""
	self.map_name = ""
	self.scene_id = 0
	self.pos_x = 0
	self.pos_y = 0
	self.fb_id = 0
	self.scene_type = 0
end

function SCChangeScene:Decode()
	self.scene_name = MsgAdapter.ReadStr()
	self.map_name = MsgAdapter.ReadStr()
	self.scene_id = MsgAdapter.ReadUShort()
	self.pos_x = MsgAdapter.ReadUShort()
	self.pos_y = MsgAdapter.ReadUShort()
	self.fb_id = MsgAdapter.ReadUChar()
	self.scene_type = MsgAdapter.ReadUChar()
end

-- 角色传送
SCTransmitRole = SCTransmitRole or BaseClass(BaseProtocolStruct)
function SCTransmitRole:__init()
	self:InitMsgType(0, 14)
	self.obj_id = 0
	self.pos_x = 0
	self.pos_y = 0
	self.dir = 0
end

function SCTransmitRole:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.pos_x = MsgAdapter.ReadUShort()
	self.pos_y = MsgAdapter.ReadUShort()
	self.dir = MsgAdapter.ReadUChar()
end

-- 实体跑步
SCObjRun = SCObjRun or BaseClass(BaseProtocolStruct)
function SCObjRun:__init()
	self:InitMsgType(0, 15)
	self.obj_id = 0
	self.pos_x = 0
	self.pos_y = 0
	self.move_speed = 0
end

function SCObjRun:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.pos_x = MsgAdapter.ReadUShort()
	self.pos_y = MsgAdapter.ReadUShort()
	self.move_speed = MsgAdapter.ReadUShort()
end

-- 释放技能
SCPerformSkill = SCPerformSkill or BaseClass(BaseProtocolStruct)
function SCPerformSkill:__init()
	self:InitMsgType(0, 18)
	self.obj_id = 0
	self.skill_id = 0
	self.skill_level = 0
	self.dir = 0
	self.sound_id = 0
end

function SCPerformSkill:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.skill_id = MsgAdapter.ReadUShort()
	self.skill_level = MsgAdapter.ReadUChar()
	self.dir = MsgAdapter.ReadUChar()
	self.move_speed = MsgAdapter.ReadUShort()
end

-- 给目标添加一个特效
SCAddEffect = SCAddEffect or BaseClass(BaseProtocolStruct)
function SCAddEffect:__init()
	self:InitMsgType(0, 19)
	self.deliverer_obj_id = 0
	self.obj_id = 0
	self.effect_type = 0				-- (0=无效果, 1=挥洒, 2=投掷, 3=飞行, 4=爆炸, 5=脚下持续, 6=持续, 7=左上浮动文字)
	self.effect_id = 0
	self.remain_time = 0
	self.sound_id = 0
end

function SCAddEffect:Decode()
	self.deliverer_obj_id = MsgAdapter.ReadLL()
	self.obj_id = MsgAdapter.ReadLL()
	self.effect_type = MsgAdapter.ReadUChar()
	self.effect_id = MsgAdapter.ReadUShort()
	self.remain_time = MsgAdapter.ReadUInt()
	self.sound_id = MsgAdapter.ReadUShort()
	if self.effect_id == 0 then
		Log("SCAddEffect.effect_id == 0 !")
	end
end

-- 实体受到攻击
SCEntityBeHit = SCEntityBeHit or BaseClass(BaseProtocolStruct)
function SCEntityBeHit:__init()
	self:InitMsgType(0, 20)
	self.obj_id = 0
	self.atker_obj_id = 0
	self.atk_type = 0					-- (0普通，1暴击，2boss暴击，3闪避)
	self.hurt_value = 0
end

function SCEntityBeHit:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.atker_obj_id = MsgAdapter.ReadLL()
	self.atk_type = MsgAdapter.ReadUChar()
	self.hurt_value = MsgAdapter.ReadInt()
end

-- 帮战下发敌对帮派的列表
SCEnemyGuildList = SCEnemyGuildList or BaseClass(BaseProtocolStruct)
function SCEnemyGuildList:__init()
	self:InitMsgType(0, 21)
	self.guild_id_count = 0
	self.guild_id_list = {}
end

function SCEnemyGuildList:Decode()
	self.guild_id_count = MsgAdapter.ReadInt()
	self.guild_id_list = {}
	
	for i = 1, self.guild_id_count do
		self.guild_id_list[i] = MsgAdapter.ReadInt()
	end
end

-- 弹出对话框
SCOpenDialog = SCOpenDialog or BaseClass(BaseProtocolStruct)
function SCOpenDialog:__init()
	self:InitMsgType(0, 22)
	self.npc_obj_id = 0
	self.title = ""
	self.btn_count = 0
	self.btn_text_list = {}
	self.exist_time = 0
	self.message_id = 0
	self.message_type = 0
	self.tip_text = ""
	self.icon_id = 0
	self.auto_index = 0
	self.role_id = 0
	self.is_open_sys_dialog_id = 0
end

function SCOpenDialog:Decode()
	self.npc_obj_id = MsgAdapter.ReadLL()
	self.title = MsgAdapter.ReadStr()
	self.btn_count = MsgAdapter.ReadUChar()
	self.btn_text_list = {}
	for i = 1, self.btn_count do
		self.btn_text_list[i] = MsgAdapter.ReadStr()
	end
	self.exist_time = MsgAdapter.ReadUInt()
	self.message_id = MsgAdapter.ReadInt()
	self.message_type = MsgAdapter.ReadUChar()
	self.tip_text = MsgAdapter.ReadStr()
	self.icon_id = MsgAdapter.ReadUShort()
	self.auto_index = MsgAdapter.ReadUChar()
	self.role_id = MsgAdapter.ReadInt()
	self.is_open_sys_dialog_id = MsgAdapter.ReadUShort()
end

-- 公共操作的结果
SCCommonOperateAck = SCCommonOperateAck or BaseClass(BaseProtocolStruct)
function SCCommonOperateAck:__init()
	self:InitMsgType(0, 24)
	self.is_succ = 0
	self.move_step = 0
	self.is_force = 0		-- 是否打断动作,1打断,0不打断
	self.is_stat_delay = 0
end

function SCCommonOperateAck:Decode()
	self.is_succ = MsgAdapter.ReadChar()
	self.move_step = MsgAdapter.ReadUChar()
	self.is_force = MsgAdapter.ReadChar()
	self.is_stat_delay = MsgAdapter.ReadChar()
end

-- 转向
SCChangeDir = SCChangeDir or BaseClass(BaseProtocolStruct)
function SCChangeDir:__init()
	self:InitMsgType(0, 25)
	self.obj_id = 0
	self.dir = 0
end

function SCChangeDir:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.dir = MsgAdapter.ReadUChar()
end

-- 近身攻击
SCNearAtk = SCNearAtk or BaseClass(BaseProtocolStruct)
function SCNearAtk:__init()
	self:InitMsgType(0, 26)
	self.obj_id = 0
	self.skill_level = 0
	self.dir = 0
	self.atk_effect = 0
	self.sound_id = 0
end

function SCNearAtk:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.skill_level = MsgAdapter.ReadUChar()
	self.dir = MsgAdapter.ReadUChar()
	self.atk_effect = MsgAdapter.ReadUShort()
	self.sound_id = MsgAdapter.ReadUShort()
end

-- 瞬间移动
SCMomentMove = SCMomentMove or BaseClass(BaseProtocolStruct)
function SCMomentMove:__init()
	self:InitMsgType(0, 27)
	self.obj_id = 0
	self.pos_x = 0
	self.pos_y = 0
	self.dir = 0
end

function SCMomentMove:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.pos_x = MsgAdapter.ReadUShort()
	self.pos_y = MsgAdapter.ReadUShort()
	self.dir = MsgAdapter.ReadUChar()
end

-- 冲锋
SCChongFeng = SCChongFeng or BaseClass(BaseProtocolStruct)
function SCChongFeng:__init()
	self:InitMsgType(0, 30)
	self.obj_id = 0
	self.pos_x = 0
	self.pos_y = 0
	self.target_pos_x = 0
	self.target_pos_y = 0
	self.dir = 0
end

function SCChongFeng:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.pos_x = MsgAdapter.ReadUShort()
	self.pos_y = MsgAdapter.ReadUShort()
	self.target_pos_x = MsgAdapter.ReadUShort()
	self.target_pos_y = MsgAdapter.ReadUShort()
	self.dir = MsgAdapter.ReadUChar()
end

-- 添加场景特效
SCAddSceneEffect = SCAddSceneEffect or BaseClass(BaseProtocolStruct)
function SCAddSceneEffect:__init()
	self:InitMsgType(0, 32)
	self.obj_id = 0
	self.effect_type = 0
	self.effect_id = 0
	self.pos_x = 0
	self.pos_y = 0
	self.remain_time = 0
	self.is_multi_language = 0
	self.sound_id = 0
end

function SCAddSceneEffect:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.effect_type = MsgAdapter.ReadUChar()			-- (0=无效果, 1=挥洒, 2=投掷, 3=飞行, 4=爆炸, 5=脚下持续,6=持续,秒杀BOSS)
	self.effect_id = MsgAdapter.ReadUShort()
	self.pos_x = MsgAdapter.ReadUShort()
	self.pos_y = MsgAdapter.ReadUShort()
	self.remain_time = MsgAdapter.ReadUInt()			-- 持续时间
	self.is_multi_language = MsgAdapter.ReadUChar()
	self.sound_id = MsgAdapter.ReadUShort()
	self.param = MsgAdapter.ReadInt()
end

-- npc任务状态
SCNpcTaskState = SCNpcTaskState or BaseClass(BaseProtocolStruct)
function SCNpcTaskState:__init()
	self:InitMsgType(0, 33)
	self.obj_id = 0
	self.task_state = 0
end

function SCNpcTaskState:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.task_state = MsgAdapter.ReadUChar()
end

-- 失去目标
SCLoseTarget = SCLoseTarget or BaseClass(BaseProtocolStruct)
function SCLoseTarget:__init()
	self:InitMsgType(0, 34)
	self.obj_id = 0
end

function SCLoseTarget:Decode()
	self.obj_id = MsgAdapter.ReadLL()
end

-- 实体死亡
SCEntityDie = SCEntityDie or BaseClass(BaseProtocolStruct)
function SCEntityDie:__init()
	self:InitMsgType(0, 35)
	self.obj_id = 0
	self.killer_obj_id = 0
	self.sound_id = 0
	self.pos_x = 0
	self.pos_y = 0
end

function SCEntityDie:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.killer_obj_id = MsgAdapter.ReadLL()
	self.sound_id = MsgAdapter.ReadUShort()
	self.pos_x = MsgAdapter.ReadInt()
	self.pos_y = MsgAdapter.ReadInt()
end

-- 玩家采集怪
SCRoleGatherMonster = SCRoleGatherMonster or BaseClass(BaseProtocolStruct)
function SCRoleGatherMonster:__init()
	self:InitMsgType(0, 36)
	self.obj_id = 0
	self.pos_x = 0
	self.pos_y = 0
	self.dir = 0
end

function SCRoleGatherMonster:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.pos_x = MsgAdapter.ReadUShort()
	self.pos_y = MsgAdapter.ReadUShort()
	self.dir = MsgAdapter.ReadUChar()
end

-- 更新角色名称颜色
SCChangeRoleNameColor = SCChangeRoleNameColor or BaseClass(BaseProtocolStruct)
function SCChangeRoleNameColor:__init()
	self:InitMsgType(0, 37)
	self.obj_id = 0
	self.name_color = 0
	self.name_color_state = 0
end

function SCChangeRoleNameColor:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.name_color = MsgAdapter.ReadUInt()
	self.name_color_state = MsgAdapter.ReadUChar()
end

-- 玩家连斩CDTime改变
SCChangeDoubleHitCD = SCChangeDoubleHitCD or BaseClass(BaseProtocolStruct)
function SCChangeDoubleHitCD:__init()
	self:InitMsgType(0, 38)
	self.cd_time = 0
end

function SCChangeDoubleHitCD:Decode()
	self.cd_time = MsgAdapter.ReadInt()
end

-- 删除特效
SCRemoveEffect = SCRemoveEffect or BaseClass(BaseProtocolStruct)
function SCRemoveEffect:__init()
	self:InitMsgType(0, 39)
	self.obj_id = 0
	self.effect_type = 0
	self.effect_id = 0
end

function SCRemoveEffect:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.effect_type = MsgAdapter.ReadUChar()
	self.effect_id = MsgAdapter.ReadUShort()
end

-- 改变显示的名字
SCChangeName = SCChangeName or BaseClass(BaseProtocolStruct)
function SCChangeName:__init()
	self:InitMsgType(0, 40)
	self.obj_id = 0
	self.name = 0
end

function SCChangeName:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.name = MsgAdapter.ReadStr()
end

-- 区域属性
SCAreaAttr = SCAreaAttr or BaseClass(BaseProtocolStruct)
function SCAreaAttr:__init()
	self:InitMsgType(0, 41)
	self.area_name = ""
	self.attr_t = {}
end

function SCAreaAttr:Decode()
	self.area_name = MsgAdapter.ReadStr()
	-- self.attr_str = MsgAdapter.ReadStr()
	local list = {}
	local count = MsgAdapter.ReadUChar()
	for i = 1, count do
		list[i] = MsgAdapter.ReadInt()
	end
	self.attr_t = {}
	for index, v in ipairs(list) do
		local flags = bit:d2b(v)
		for i = #flags, 1, - 1 do
			if flags[i] == 1 then
				self.attr_t[32 * index - i + 1] = true
			end
		end
	end
end

-- 屏蔽震动
SCActScreenShake = SCActScreenShake or BaseClass(BaseProtocolStruct)
function SCActScreenShake:__init()
	self:InitMsgType(0, 42)
	self.shake_val = 0
	self.keep_time = 0
end

function SCActScreenShake:Decode()
	self.shake_val = MsgAdapter.ReadUShort()
	self.keep_time = MsgAdapter.ReadUShort()
end

-- 下属属性改变
SCXiaShuAttrChange = SCXiaShuAttrChange or BaseClass(BaseProtocolStruct)
function SCXiaShuAttrChange:__init()
	self:InitMsgType(0, 43)
	self.obj_id = 0
	self.attr_count = 0
	self.attr_list = {}
end

function SCXiaShuAttrChange:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.attr_count = MsgAdapter.ReadUChar()
	self.attr_list = {}
	for i = 1, self.attr_count do
		self.attr_list[i] = CommonReader.ReadObjAttrTable()
	end
end

-- 下属位置改变
SCXiaShuPosChange = SCXiaShuPosChange or BaseClass(BaseProtocolStruct)
function SCXiaShuPosChange:__init()
	self:InitMsgType(0, 44)
	self.obj_id = 0
	self.pos_x = 0
	self.pos_y = 0
	self.scene_id = 0
end

function SCXiaShuPosChange:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.pos_x = MsgAdapter.ReadUShort()
	self.pos_y = MsgAdapter.ReadUShort()
	self.scene_id = MsgAdapter.ReadInt()
end

-- VIP剩余时间不超过24小时提醒
SCVipRemind = SCVipRemind or BaseClass(BaseProtocolStruct)
function SCVipRemind:__init()
	self:InitMsgType(0, 47)
	self.vip_type = 0
	self.is_show_btn = 0
	self.remain_time = 0
end

function SCVipRemind:Decode()
	self.vip_type = MsgAdapter.ReadInt()
	self.is_show_btn = MsgAdapter.ReadUChar()
	self.remain_time = MsgAdapter.ReadUInt()
end

-- 宠物改变攻击类型
SCPetChangeAtkType = SCPetChangeAtkType or BaseClass(BaseProtocolStruct)
function SCPetChangeAtkType:__init()
	self:InitMsgType(0, 47)
	self.obj_id = 0
	self.atk_type = 0
end

function SCPetChangeAtkType:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.atk_type = MsgAdapter.ReadUChar()
end

-- 击飞
SCHitFly = SCHitFly or BaseClass(BaseProtocolStruct)
function SCHitFly:__init()
	self:InitMsgType(0, 50)
	self.obj_id = 0
	self.pos_x = 0
	self.pos_y = 0
	self.target_pos_x = 0
	self.target_pos_y = 0
	self.dir = 0
end

function SCHitFly:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.pos_x = MsgAdapter.ReadUShort()
	self.pos_y = MsgAdapter.ReadUShort()
	self.target_pos_x = MsgAdapter.ReadUShort()
	self.target_pos_y = MsgAdapter.ReadUShort()
	self.dir = MsgAdapter.ReadUChar()
end

-- 开始传送
SCTransmitBegin = SCTransmitBegin or BaseClass(BaseProtocolStruct)
function SCTransmitBegin:__init()
	self:InitMsgType(0, 51)
	self.target_server_id = 0
	self.ip_str = ""
	self.port = 0
end

function SCTransmitBegin:Decode()
	self.target_server_id = MsgAdapter.ReadInt()
	self.ip_str = MsgAdapter.ReadStr()
	self.port = MsgAdapter.ReadInt()
end

-- 下发跨服开启状态
SCCrossServerState = SCCrossServerState or BaseClass(BaseProtocolStruct)
function SCCrossServerState:__init()
	self:InitMsgType(0, 52)
	self.state = 0
end

function SCCrossServerState:Decode()
	self.state = MsgAdapter.ReadUChar()
end

-- 一些特殊生物出现
SCSpecialEntity = SCSpecialEntity or BaseClass(BaseProtocolStruct)
function SCSpecialEntity:__init()
	self:InitMsgType(0, 53)
	self.obj_id = 0
	self.model_id = 0
	self.pos_x = 0
	self.pos_y = 0
	self.name = 0
end

function SCSpecialEntity:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.model_id = MsgAdapter.ReadUShort()
	self.pos_x = MsgAdapter.ReadUShort()
	self.pos_y = MsgAdapter.ReadUShort()
	self.name = MsgAdapter.ReadStr()
end

-- 按一点的速度前进
SCObjMoveForward = SCObjMoveForward or BaseClass(BaseProtocolStruct)
function SCObjMoveForward:__init()
	self:InitMsgType(0, 54)
	self.obj_id = 0
	self.pos_x = 0
	self.pos_y = 0
	self.move_speed = 0
	self.frame = 0
end

function SCObjMoveForward:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.pos_x = MsgAdapter.ReadUShort()
	self.pos_y = MsgAdapter.ReadUShort()
	self.move_speed = MsgAdapter.ReadUShort()
	self.frame = MsgAdapter.ReadUChar()
end

-- 按一点的速度后退
SCObjMoveBack = SCObjMoveBack or BaseClass(BaseProtocolStruct)
function SCObjMoveBack:__init()
	self:InitMsgType(0, 55)
	self.obj_id = 0
	self.pos_x = 0
	self.pos_y = 0
	self.move_speed = 0
	self.frame = 0
end

function SCObjMoveBack:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.pos_x = MsgAdapter.ReadUShort()
	self.pos_y = MsgAdapter.ReadUShort()
	self.move_speed = MsgAdapter.ReadUShort()
	self.frame = MsgAdapter.ReadUChar()
end

-- 文明度信息
SCCivilizationAck = SCCivilizationAck or BaseClass(BaseProtocolStruct)
function SCCivilizationAck:__init()
	self:InitMsgType(0, 57)
	self.world_civilizatio_level = 0			-- 世界文明度等级
	self.civilizatio_zhuang_times = 0			-- 文明度的转生次数
	self.cheng_zhu_revenue_limit = 0			-- 城主税收上限
	self.world_civilizatio_exp_additive = 0		-- 世界文明经验加成
end

function SCCivilizationAck:Decode()
	self.world_civilizatio_level = MsgAdapter.ReadInt()
	self.civilizatio_zhuang_times = MsgAdapter.ReadUChar()
	self.cheng_zhu_revenue_limit = MsgAdapter.ReadInt()
	self.world_civilizatio_exp_additive = MsgAdapter.ReadInt()
end

-- 发现目标，用于怪物的声音播放
SCFindTargetSound = SCFindTargetSound or BaseClass(BaseProtocolStruct)
function SCFindTargetSound:__init()
	self:InitMsgType(0, 58)
	self.obj_id = 0
	self.sound_id = 0
end

function SCFindTargetSound:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.sound_id = MsgAdapter.ReadUShort()
end

-- 道士狗死亡通知客户端挂机
SCDogDie = SCDogDie or BaseClass(BaseProtocolStruct)
function SCDogDie:__init()
	self:InitMsgType(0, 59)
end

function SCDogDie:Decode()
end

-- 头顶倒计时
SCHeadCD = SCHeadCD or BaseClass(BaseProtocolStruct)
function SCHeadCD:__init()
	self:InitMsgType(0, 60)
	self.obj_id = 0
	self.cd_time = 0
end

function SCHeadCD:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.cd_time = MsgAdapter.ReadInt()
end

-- 实体冲锋到一个坐标点位置
SCChongFeng2 = SCChongFeng2 or BaseClass(BaseProtocolStruct)
function SCChongFeng2:__init()
	self:InitMsgType(0, 61)
	self.obj_id = 0
	self.pos_x = 0
	self.pos_y = 0
	self.target_pos_x = 0
	self.target_pos_y = 0
	self.dir = 0
	self.interval = 0		-- ms
end

function SCChongFeng2:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.pos_x = MsgAdapter.ReadUShort()
	self.pos_y = MsgAdapter.ReadUShort()
	self.target_pos_x = MsgAdapter.ReadUShort()
	self.target_pos_y = MsgAdapter.ReadUShort()
	self.dir = MsgAdapter.ReadUChar()
	self.interval = MsgAdapter.ReadInt()
end

-- 打出了吸血
SCSuckBloodAtk = SCSuckBloodAtk or BaseClass(BaseProtocolStruct)
function SCSuckBloodAtk:__init()
	self:InitMsgType(0, 63)
	self.obj_id = 0
	self.hp = 0
end

function SCSuckBloodAtk:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.hp = MsgAdapter.ReadUInt()
end

-- 离线角色进入视野
SCVisibleObjEnterOfflineRole = SCVisibleObjEnterOfflineRole or BaseClass(BaseProtocolStruct)
function SCVisibleObjEnterOfflineRole:__init()
	self:InitMsgType(0, 64)
	self.obj_id = 0
	
	self.attr = {}
	self.effect_count = 0
	self.effect_list = {}
end

function SCVisibleObjEnterOfflineRole:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	
	-- self.attr[OBJ_ATTR.ENTITY_X] = MsgAdapter.ReadUShort()
	-- self.attr[OBJ_ATTR.ENTITY_Y] = MsgAdapter.ReadUShort()
	-- self.attr[OBJ_ATTR.ENTITY_MODEL_ID] = MsgAdapter.ReadInt()
	-- self.attr[OBJ_ATTR.CREATURE_HP] = MsgAdapter.ReadUInt()
	-- self.attr[OBJ_ATTR.CREATURE_MP] = MsgAdapter.ReadUInt()
	-- -- self.attr[OBJ_ATTR.CREATURE_MAX_HP] = MsgAdapter.ReadUInt()
	-- -- self.attr[OBJ_ATTR.CREATURE_MAX_MP] = MsgAdapter.ReadUInt()
	-- self.attr[OBJ_ATTR.ACTOR_INNER] = MsgAdapter.ReadUInt()
	-- self.attr[OBJ_ATTR.ACTOR_MAX_INNER] = MsgAdapter.ReadUInt()
	-- self.attr[OBJ_ATTR.CREATURE_MOVE_SPEED] = MsgAdapter.ReadUShort()
	-- self.attr[OBJ_ATTR.ACTOR_SEX] = MsgAdapter.ReadUChar()
	-- self.attr[OBJ_ATTR.ACTOR_PROF] = MsgAdapter.ReadUChar()
	-- self.attr[OBJ_ATTR.CREATURE_LEVEL] = MsgAdapter.ReadUShort()
	-- self.attr[OBJ_ATTR.ACTOR_CIRCLE] = MsgAdapter.ReadUShort()
	-- self.attr[OBJ_ATTR.ACTOR_APOTHEOSIZE_LEVEL] = MsgAdapter.ReadUShort()
	-- self.attr[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE] = MsgAdapter.ReadInt()
	-- self.attr[OBJ_ATTR.ACTOR_MOUNT_APPEARANCE] = MsgAdapter.ReadInt()
	-- self.attr[OBJ_ATTR.ACTOR_WING_APPEARANCE] = MsgAdapter.ReadInt()
	-- self.attr[OBJ_ATTR.ACTOR_MAGIC_APPEARANCE] = MsgAdapter.ReadInt()
	-- self.attr[OBJ_ATTR.ACTOR_FOOT_APPEARANCE] = MsgAdapter.ReadUInt()
	-- self.attr[OBJ_ATTR.ACTOR_SOCIAL_MASK] = MsgAdapter.ReadInt()
	-- self.attr[OBJ_ATTR.ENTITY_AVATAR_ID] = MsgAdapter.ReadUShort()
	-- self.attr[OBJ_ATTR.CREATURE_ATTACK_SPEED] = MsgAdapter.ReadUShort()
	-- self.attr[OBJ_ATTR.ENTITY_DIR] = MsgAdapter.ReadUChar()
	-- self.attr[OBJ_ATTR.CREATURE_STATE] = MsgAdapter.ReadUInt()
	-- self.attr[OBJ_ATTR.ACTOR_CURTITLE] = MsgAdapter.ReadUChar()
	-- self.attr[OBJ_ATTR.ACTOR_VIP_GRADE] = MsgAdapter.ReadInt()
	-- self.attr[OBJ_ATTR.ACTOR_TEAM_ID] = MsgAdapter.ReadInt()
	-- self.attr[OBJ_ATTR.ACTOR_CAMP] = MsgAdapter.ReadUChar()
	-- self.attr[OBJ_ATTR.ACTOR_HEAD_TITLE] = MsgAdapter.ReadUInt()
	-- self.attr[OBJ_ATTR.ACTOR_RIDE_LEVEL] = MsgAdapter.ReadInt()
	-- self.attr[OBJ_ATTR.ACTOR_RIDEONID] = MsgAdapter.ReadInt()
	-- self.attr[OBJ_ATTR.ACTOR_CURRENT_HEAD_TITLE] = MsgAdapter.ReadUInt()
	-- self.attr[OBJ_ATTR.ACTOR_OFFICE] = MsgAdapter.ReadUInt()
	-- self.attr[OBJ_ATTR.CREATURE_COLOR] = MsgAdapter.ReadUInt()
	-- self.attr[OBJ_ATTR.ACTOR_WARDROBE] = MsgAdapter.ReadUInt()
	-- self.attr[OBJ_ATTR.ACTOR_BATTLE_POWER] = MsgAdapter.ReadUInt()
	-- self.attr[OBJ_ATTR.ACTOR_FLAMINTAPPEARANCEID] = MsgAdapter.ReadUInt()
	-- self.attr[OBJ_ATTR.ACTOR_WINGEQUIP_APPEARANCE] = MsgAdapter.ReadUInt()
end

-- boss归属权改变
SCBossAscriptionChange = SCBossAscriptionChange or BaseClass(BaseProtocolStruct)
function SCBossAscriptionChange:__init()
	self:InitMsgType(0, 68)
	self.obj_id = 0
	self.ascription = ""
end

function SCBossAscriptionChange:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.ascription = MsgAdapter.ReadStr()
	self.role_id = MsgAdapter.ReadLL() 	-- 归属者id
end

-- 服务器断开通知
SCDisconnectServerNotice = SCDisconnectServerNotice or BaseClass(BaseProtocolStruct)
function SCDisconnectServerNotice:__init()
	self:InitMsgType(0, 69)
	self.reason = 0
end

function SCDisconnectServerNotice:Decode()
	self.reason = MsgAdapter.ReadUChar()
end

-- 人物特殊属性改变
SCMainRoleSpecialAttrChange = SCMainRoleSpecialAttrChange or BaseClass(BaseProtocolStruct)
function SCMainRoleSpecialAttrChange:__init()
	self:InitMsgType(0, 70)
	self.up_num = 0
	self.down_num = 0
	self.attr_other_list = {}
end

function SCMainRoleSpecialAttrChange:Decode()
	self.up_num = MsgAdapter.ReadChar()
	local all_value_add = MsgAdapter.ReadInt()
	
	for i = 0, self.up_num - 2 do
		self.attr_other_list[1003 + i] = MsgAdapter.ReadInt()
	end
	
	self.down_num = MsgAdapter.ReadChar()

	local all_value_dec = MsgAdapter.ReadInt()
	for i = 0, self.down_num - 2 do
		self.attr_other_list[1008 + i] = MsgAdapter.ReadInt()
	end
	
	self.attr_other_list[OBJ_ATTR.ACTOR_INNER_REDUCE_DAMAGE_ADD] = MsgAdapter.ReadInt()
	self.attr_other_list[OBJ_ATTR.ACTOR_INNER_RENEW_ADD] = MsgAdapter.ReadInt()
	self.attr_other_list[OBJ_ATTR.ACTOR_ARM_POWER_ADD] = MsgAdapter.ReadInt()
	-- self.attr_other_list[OBJ_ATTR.ACTOR_INNER_REDUCE_DAMAGE_RATE_ADD] = MsgAdapter.ReadInt()
	self.attr_other_list[OBJ_ATTR.ACTOR_DIZZY_RATE_ADD] = MsgAdapter.ReadInt()
	self.attr_other_list[OBJ_ATTR.ACTOR_DEF_DIZZY_RATE] = MsgAdapter.ReadInt()
	self.attr_other_list[OBJ_ATTR.ACTOR_HP_DAMAGE_2_MP_DROP_RATE_ADD] = MsgAdapter.ReadInt()
	self.attr_other_list[OBJ_ATTR.ACTOR_BAG_MAX_WEIGHT_ADD] = MsgAdapter.ReadInt()
	self.attr_other_list[OBJ_ATTR.ACTOR_DIE_REFRESH_HP_PRO] = MsgAdapter.ReadInt()
	self.attr_other_list[OBJ_ATTR.ACTOR_BROKEN_RELIVE_RATE] = MsgAdapter.ReadInt()
	self.attr_other_list[OBJ_ATTR.ACTOR_EQUIP_MAX_WEIGHT_ADD] = MsgAdapter.ReadInt()
	self.attr_other_list[OBJ_ATTR.ACTOR_EQUIP_MAX_WEIGHT_POWER] = MsgAdapter.ReadInt()
	self.attr_other_list[OBJ_ATTR.ACTOR_RESISTANCE_CRIT_RATE] = MsgAdapter.ReadInt()

	self.attr_other_list[OBJ_ATTR.ACTOR_MOUNT_MIN_ATTACK_RATE] = MsgAdapter.ReadInt()
	self.attr_other_list[OBJ_ATTR.ACTOR_MOUNT_MIN_ATTACK_VALUE] = MsgAdapter.ReadInt()
	self.attr_other_list[OBJ_ATTR.ACTOR_FATAL_HIT_RATE] = MsgAdapter.ReadInt()
	self.attr_other_list[OBJ_ATTR.ACTOR_FATAL_HIT_VALUE] = MsgAdapter.ReadInt()
	self.attr_other_list[OBJ_ATTR.ACTOR_PK_DAMAGE] = MsgAdapter.ReadInt()
	self.attr_other_list[OBJ_ATTR.ACTOR_REDUCE_PK_DAMAGE] = MsgAdapter.ReadInt()
	self.attr_other_list[OBJ_ATTR.ACTOR_MOUNT_MIN_PHY_DEFENCE_RATE_RATE] = MsgAdapter.ReadInt()
	self.attr_other_list[OBJ_ATTR.ACTOR_MOUNT_MIN_PHY_DEFENCE_RATE_VALUE] = MsgAdapter.ReadInt()
	self.attr_other_list[OBJ_ATTR.ACTOR_REDUCE_FATAL_HIT_RATE] = MsgAdapter.ReadInt()
	self.attr_other_list[OBJ_ATTR.ACTOR_REFLECT_RATE] = MsgAdapter.ReadInt()
	self.attr_other_list[OBJ_ATTR.ACTOR_MOUNT_HP_RATE_ADD] = MsgAdapter.ReadInt()
	self.attr_other_list[OBJ_ATTR.ACTOR_REDUCE_BAOJI] = MsgAdapter.ReadInt()
	self.attr_other_list[OBJ_ATTR.ACTOR_REDUCE_BAOJI_REAT] = MsgAdapter.ReadInt()
	self.attr_other_list[OBJ_ATTR.ACTOR_1077] = MsgAdapter.ReadInt()
	self.attr_other_list[OBJ_ATTR.ACTOR_1078] = MsgAdapter.ReadInt()
	self.attr_other_list[OBJ_ATTR.ACTOR_1079] = MsgAdapter.ReadInt()
	self.attr_other_list[OBJ_ATTR.ACTOR_1080] = MsgAdapter.ReadInt()
	self.attr_other_list[OBJ_ATTR.ACTOR_1081] = MsgAdapter.ReadInt()
	self.attr_other_list[OBJ_ATTR.ACTOR_1082] = MsgAdapter.ReadInt()
	self.attr_other_list[OBJ_ATTR.ACTOR_1083] = MsgAdapter.ReadInt()
	self.attr_other_list[OBJ_ATTR.ACTOR_1084] = MsgAdapter.ReadInt()
end

-- 下发命中特殊属性技能
SCTriggerSpecialAttr = SCTriggerSpecialAttr or BaseClass(BaseProtocolStruct)
function SCTriggerSpecialAttr:__init()
	self:InitMsgType(0, 71)
	self.attr_type = 0 -- 特殊属性类型 GAME_ATTRIBUTE_TYPE
end

function SCTriggerSpecialAttr:Decode()
	self.attr_type = MsgAdapter.ReadUShort()
end

-- 下发内功注入结果
SCInnerEquipResult = SCInnerEquipResult or BaseClass(BaseProtocolStruct)
function SCInnerEquipResult:__init()
	self:InitMsgType(0, 72)
	self.slot = 0
	self.item_num = 0
end

function SCInnerEquipResult:Decode()
	self.slot = MsgAdapter.ReadChar()
	self.item_num = MsgAdapter.ReadInt()
end

-- 下发内功数据
SCInnerEquipData = SCInnerEquipData or BaseClass(BaseProtocolStruct)
function SCInnerEquipData:__init()
	self:InitMsgType(0, 73)
	self.slot_list = {}
end

function SCInnerEquipData:Decode()
	self.slot_list = {}
	for i = 1, MsgAdapter.ReadChar() do
		self.slot_list[i - 1] = MsgAdapter.ReadShort()
	end
end

-- 接收所有活跃度完成进度数据
SCActiveData = SCActiveData or BaseClass(BaseProtocolStruct)
function SCActiveData:__init()
	self:InitMsgType(0, 74)
	self.task_list = {} 			--活跃度列表
	self.rew_state = 0  			-- 领取活跃度状态
end

function SCActiveData:Decode()
	self.task_list = {}
	for i = 1, MsgAdapter.ReadUChar() do
		local vo = {
			comtime = MsgAdapter.ReadChar(),
			protime = MsgAdapter.ReadChar()
		}
		-- self.task_list[i].comtime = MsgAdapter.ReadChar(), 		-- 当天完成次数
		-- self.task_list[i].protime = MsgAdapter.ReadChar(), 		-- 完成进度次数
		table.insert(self.task_list, vo)
	end
	self.rew_state = MsgAdapter.ReadUInt()
end

-- 接收活跃度数据变化
SCActiveDataChange = SCActiveDataChange or BaseClass(BaseProtocolStruct)
function SCActiveDataChange:__init()
	self:InitMsgType(0, 75)
	self.index = nil 				-- 活跃度类型
	self.com_num = nil 				-- 当天完成次数
	self.done_num = nil 			-- 完成进度次数
end

function SCActiveDataChange:Decode()
	self.index = MsgAdapter.ReadUChar()
	self.com_num = MsgAdapter.ReadUChar()
	self.done_num = MsgAdapter.ReadUChar()
end

-- 下发所有开服限时任务活动数据
SCAllTimeLimitTaskData = SCAllTimeLimitTaskData or BaseClass(BaseProtocolStruct)
function SCAllTimeLimitTaskData:__init()
	self:InitMsgType(0, 76)
	self.task_list = {}
end

function SCAllTimeLimitTaskData:Decode()
	self.task_data_list = {}
	for i = 1, MsgAdapter.ReadUChar() do
		self.task_data_list[i - 1] = {
			task_type = i - 1,							-- 任务类型
			done_times = MsgAdapter.ReadUChar(),		-- 完成次数
			rec_state = MsgAdapter.ReadUChar(),			-- 领取状态 1：已领取 0：未领取
		}
	end
end

-- 开服限时任务数据变化
SCOneTimeLimitTaskData = SCOneTimeLimitTaskData or BaseClass(BaseProtocolStruct)
function SCOneTimeLimitTaskData:__init()
	self:InitMsgType(0, 77)
	self.task_type = 0			-- 任务类型
	self.done_times = 0			-- 完成次数
	self.rec_state = 0			-- 领取状态 1：已领取 0：未领取
end

function SCOneTimeLimitTaskData:Decode()
	self.task_type = MsgAdapter.ReadUChar()
	self.done_times = MsgAdapter.ReadUChar()
	self.rec_state = MsgAdapter.ReadUChar()
end


--所有威望任务数据(登录与跨天下发)
-- SCPrestigeTaskData = SCPrestigeTaskData or BaseClass(BaseProtocolStruct)
-- function SCPrestigeTaskData:__init()
-- 	self:InitMsgType(0, 78)
-- 	self.task_counts = 0--任务数量
-- 	self.task_list = {}--任务列表
-- end

-- function SCPrestigeTaskData:Decode()
-- 	self.task_counts = MsgAdapter.ReadUChar()
-- 	self.task_list = {}
-- 	for i = 0, self.task_counts - 1 do
-- 		local info = {task_type = i}
-- 		info.complete_counts = MsgAdapter.ReadShort()
-- 		info.get_award_counts = MsgAdapter.ReadUChar()
-- 		self.task_list[i] = info
-- 	end
-- end

--威望任务数据变化
-- SCPrestigeTaskDataChange = SCPrestigeTaskDataChange or BaseClass(BaseProtocolStruct)
-- function SCPrestigeTaskDataChange:__init()
-- 	self:InitMsgType(0, 79)
-- 	self.task_type = nil--任务类型
-- 	self.complete_counts = nil--完成次数
-- 	self.get_award_counts = nil--领取奖励次数
-- end

-- function SCPrestigeTaskDataChange:Decode()
-- 	self.task_type = MsgAdapter.ReadUChar()
-- 	self.complete_counts = MsgAdapter.ReadShort()
-- 	self.get_award_counts = MsgAdapter.ReadUChar()
-- end 

-- 下发活跃度领取奖励状态
SCActivityRewardState = SCActivityRewardState or BaseClass(BaseProtocolStruct)
function SCActivityRewardState:__init()
	self:InitMsgType(0, 78)
	self.receive_state = 0 				-- 领取奖励状态
end

function SCActivityRewardState:Decode()
	self.receive_state = MsgAdapter.ReadUInt()
end

-- 接收钻石萌宠数据
SCDiamondPetData = SCDiamondPetData or BaseClass(BaseProtocolStruct)
function SCDiamondPetData:__init()
	self:InitMsgType(0, 79)
	self.pet_lv = 0 					-- uchar萌宠激活等级
	self.excavate_times = 0 			-- uchar当天已挖掘次数
	self.today_diamond = 0 				-- uint当天获得的钻石
	self.award_index = 0 				-- uchar随机中奖索引值  0:表示没有中奖(登录下发等)
end

function SCDiamondPetData:Decode()
	self.pet_lv = MsgAdapter.ReadUChar()
	self.excavate_times = MsgAdapter.ReadUChar()
	self.today_diamond = MsgAdapter.ReadUInt()
	self.award_index = MsgAdapter.ReadUChar()
end

--下发任务好礼数据
SCTaskGiftData = SCTaskGiftData or BaseClass(BaseProtocolStruct)
function SCTaskGiftData:__init()
	self:InitMsgType(0, 80)
	self.big_task = 0 			-- 大任务索引（从1开始）
	self.task_counts = 0
	self.task_list = {} --任务列表
end

function SCTaskGiftData:Decode()
	self.big_task = MsgAdapter.ReadUChar()
	self.task_counts = MsgAdapter.ReadUChar()
	self.task_list = {}
	for i = 1, self.task_counts do
		local info = {}
		info.complete_num = MsgAdapter.ReadUShort() 			--完成数量
		info.rew_state = MsgAdapter.ReadUChar() 			--领取状态
		self.task_list[i] = info
	end
end

-- 屠魔令加点时间
SCTumoAddTime = SCTumoAddTime or BaseClass(BaseProtocolStruct)
function SCTumoAddTime:__init()
	self:InitMsgType(0, 81)
	self.start_time = 0 			-- 开始加点时间（需要加上配置时间）
	self.cross_start_time = 0 		-- 跨服屠魔令开始加点时间（需要加上配置时间）
end

function SCTumoAddTime:Decode()
	self.start_time = CommonReader.ReadServerUnixTime()
	self.cross_start_time = CommonReader.ReadServerUnixTime()
end