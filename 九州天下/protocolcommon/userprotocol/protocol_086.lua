-- 名将信息
SCGreateSoldierItemInfo = SCGreateSoldierItemInfo or BaseClass(BaseProtocolStruct)
function SCGreateSoldierItemInfo:__init()
	self.msg_type = 8600

	self.seq = 0
	self.item_info = {}
end

function SCGreateSoldierItemInfo:Decode()
	self.seq = MsgAdapter.ReadInt()
	self.item_info = {}
	self.item_info.seq = self.seq
	self.item_info.level = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.item_info.gongji = MsgAdapter.ReadInt()				-- 攻击潜能
	self.item_info.fangyu = MsgAdapter.ReadInt()				-- 防御潜能
	self.item_info.hp = MsgAdapter.ReadInt()					-- 生命潜能
	self.item_info.gongji_tmp = MsgAdapter.ReadInt()			-- 临时攻击潜能
	self.item_info.fangyu_tmp = MsgAdapter.ReadInt()			-- 临时防御潜能
	self.item_info.hp_tmp = MsgAdapter.ReadInt()				-- 临时生命潜能
	self.unactive_timestamp = MsgAdapter.ReadUInt()				-- 形象ID结束时间（0代表永久）

	-- 洗练属性类型（客户端自己改）
	-- enum GRAETE_SOLDIER_WASH_ATTR_TYPE
	-- {
	-- 	GRAETE_SOLDIER_WASH_ATTR_TYPE_BEGIN = 0,
	-- 	GRAETE_SOLDIER_WASH_ATTR_TYPE_GONGJI = GRAETE_SOLDIER_WASH_ATTR_TYPE_BEGIN,
	-- 	GRAETE_SOLDIER_WASH_ATTR_TYPE_FANGYU,
	-- 	GRAETE_SOLDIER_WASH_ATTR_TYPE_MAXHP,

	-- 	GRAETE_SOLDIER_WASH_ATTR_TYPE_MAX,
	-- };
	local wash_attr_points = {}
	for i = 0, 2 do
		wash_attr_points[i] = MsgAdapter.ReadInt()
	end
	self.item_info.wash_attr_points = wash_attr_points
end

--  名将其他信息
SCGreateSoldierOtherInfo = SCGreateSoldierOtherInfo or BaseClass(BaseProtocolStruct)
function SCGreateSoldierOtherInfo:__init()
	self.msg_type = 8601
	self.cur_used_seq = 0
	self.is_on_bianshen_trail = 0
	self.has_dailyfirst_draw_ten = 0
	self.bianshen_end_timestamp = 0
	self.bianshen_cd = 0
	self.bianshen_cd_reduce_s = 0
end

function SCGreateSoldierOtherInfo:Decode()
	self.cur_used_seq = MsgAdapter.ReadChar()
	self.is_on_bianshen_trail = MsgAdapter.ReadChar()
	self.has_dailyfirst_draw_ten = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	self.bianshen_end_timestamp = MsgAdapter.ReadUInt()
	self.bianshen_cd = MsgAdapter.ReadInt()						-- 变身剩余cd (ms)
	MsgAdapter.ReadLL()
	self.bianshen_cd_reduce_s = MsgAdapter.ReadInt()			-- 变身CD缩短时间
end

-- 名将将位信息
SCGreateSoldierSlotInfo = SCGreateSoldierSlotInfo or BaseClass(BaseProtocolStruct)
function SCGreateSoldierSlotInfo:__init()
	self.msg_type = 8602

	self.slot_param = {}				-- 0是主将位
end

function SCGreateSoldierSlotInfo:Decode()
	self.slot_param = {}
	for i = 0, COMMON_CONSTS.GREATE_SOLDIER_SLOT_MAX_COUNT - 1 do
		local data = {}
		data.item_seq = MsgAdapter.ReadChar()						-- 名将seq
		MsgAdapter.ReadChar()
		data.level = MsgAdapter.ReadShort()							-- 等级
		data.level_val = MsgAdapter.ReadUInt()						-- 升级祝福值
		self.slot_param[i] = data
	end
end

-----------------宝宝BOSS--------------------------------------------------
 CSBabyBossOperate =  CSBabyBossOperate or BaseClass(BaseProtocolStruct)
function  CSBabyBossOperate:__init()
	self.msg_type = 8614
	self.operate_type = 0
	self.param_0 = 0
	self.param_1 = 0

end

function  CSBabyBossOperate:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.operate_type)
	MsgAdapter.WriteInt(self.param_0)
	MsgAdapter.WriteUShort(self.param_1)
	MsgAdapter.WriteShort(0)
end

SCBabyBossRoleInfo = SCBabyBossRoleInfo or BaseClass(BaseProtocolStruct)
function SCBabyBossRoleInfo:__init()
	self.msg_type = 8615
	self.angry_value = 0 			-- 愤怒值
	self.kick_time = 0 				-- 提出时间
end

function SCBabyBossRoleInfo:Decode()
	self.angry_value = MsgAdapter.ReadInt()
	self.kick_time = MsgAdapter.ReadUInt()
end

SCAllBabyBossInfo = SCAllBabyBossInfo or BaseClass(BaseProtocolStruct)
function SCAllBabyBossInfo:__init()
	self.msg_type = 8616
	self.boss_count = 0 			
	self.boss_info_list = {} 				
end

function SCAllBabyBossInfo:Decode()
	self.boss_count = MsgAdapter.ReadInt()
	self.boss_info_list = {} 

	for i = 1, self.boss_count do
		local data = {}
		data.scene_id = MsgAdapter.ReadShort()
		data.boss_id = MsgAdapter.ReadUShort()
		data.next_refresh_time = MsgAdapter.ReadUInt()
		data.killer_info = {}

		for i = 1, GameEnum.BABY_BOSS_KILLER_LIST_MAX_COUNT do
			data.killer_info[i] = {}
			data.killer_info.killer_uid = MsgAdapter.ReadInt()
			data.killer_info.killier_time = MsgAdapter.ReadUInt()
			data.killer_info.killer_name = MsgAdapter.ReadStrN(32)
		end

		self.boss_info_list[i] = data
	end 
end

SCSingleBabyBossInfo = SCSingleBabyBossInfo or BaseClass(BaseProtocolStruct)
function SCSingleBabyBossInfo:__init()
	self.msg_type = 8617
	self.boss_info = {}
end

function SCSingleBabyBossInfo:Decode()
	self.boss_info = {}
	self.boss_info.scene_id = MsgAdapter.ReadShort()
	self.boss_info.boss_id = MsgAdapter.ReadUShort()
	self.boss_info.next_refresh_time = MsgAdapter.ReadUInt()
	self.boss_info.killer_info = {}

	for i = 1, GameEnum.BABY_BOSS_KILLER_LIST_MAX_COUNT do
		self.boss_info.killer_info[i] = {}
		self.boss_info.killer_info.killer_uid = MsgAdapter.ReadInt()
		self.boss_info.killer_info.killier_time = MsgAdapter.ReadUInt()
		self.boss_info.killer_info.killer_name = MsgAdapter.ReadStrN(32)
	end
end
