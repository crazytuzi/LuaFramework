-- 仙盟驻地请求
CSGuildBackToStation = CSGuildBackToStation or BaseClass(BaseProtocolStruct)
function CSGuildBackToStation:__init()
	self.msg_type = 6264
	self.guild_id = 0
end

function CSGuildBackToStation:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.guild_id)
end

-- 公会争霸主动释放护盾
CSGBAddHuDun =  CSGBAddHuDun or BaseClass(BaseProtocolStruct)
function CSGBAddHuDun:__init()
	self.msg_type = 6200
end

function CSGBAddHuDun:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 提交护送任务
CSGBRoleCalcSubmitReq =  CSGBRoleCalcSubmitReq or BaseClass(BaseProtocolStruct)
function CSGBRoleCalcSubmitReq:__init()
	self.msg_type = 6201
end

function CSGBRoleCalcSubmitReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 请求上一届公会争霸霸主信息
CSGBWinnerInfoReq =  CSGBWinnerInfoReq or BaseClass(BaseProtocolStruct)
function CSGBWinnerInfoReq:__init()
	self.msg_type = 6202
end

function CSGBWinnerInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 请求得到金箱子位置信息
CSGBGoldboxPositionReq = CSGBGoldboxPositionReq or BaseClass(BaseProtocolStruct)
function CSGBGoldboxPositionReq:__init()
	self.msg_type = 6203
end

function CSGBGoldboxPositionReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 请求膜拜
CSGBWorshipReq = CSGBWorshipReq or BaseClass(BaseProtocolStruct)
function CSGBWorshipReq:__init()
	self.msg_type = 6204
end

function CSGBWorshipReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 公会争霸变身形象广播
SCGBBianShenView =  SCGBBianShenView or BaseClass(BaseProtocolStruct)
function SCGBBianShenView:__init()
	self.msg_type = 6250
	self.obj_id = 0
	self.color = 0
end

function SCGBBianShenView:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.color = MsgAdapter.ReadShort()
end

-- 公会争霸 全局信息（广播）
SCGBGlobalInfo =  SCGBGlobalInfo or BaseClass(BaseProtocolStruct)
function SCGBGlobalInfo:__init()
	self.msg_type = 6251
	self.guild_score = 0
	self.guild_rank = 0
	self.is_finish = 0
	self.is_boss_alive = 0
	self.reserve_2 = 0
	self.husong_end_time = 0
	self.gold_box_total_count = 0
	self.sliver_box_total_count = 0
	self.boss_current_hp = 0
	self.boss_maxhp = 0
	self.RANK_NUM = 0
	self.rank_count = 0
	self.rank_list = {}
end

function SCGBGlobalInfo:Decode()
	self.rank_list = {}
	self.guild_score = MsgAdapter.ReadInt()
	self.guild_rank = MsgAdapter.ReadInt()
	self.is_finish = MsgAdapter.ReadChar()
	self.is_boss_alive = MsgAdapter.ReadChar()
	self.reserve_2 = MsgAdapter.ReadShort()
	self.husong_end_time = MsgAdapter.ReadUInt()
	self.gold_box_total_count = MsgAdapter.ReadShort()
	self.sliver_box_total_count = MsgAdapter.ReadShort()
	self.boss_current_hp = MsgAdapter.ReadInt()
	self.boss_maxhp = MsgAdapter.ReadInt()
	self.rank_count = MsgAdapter.ReadInt()
	for i = 1, self.rank_count do
		self.rank_list[i] = {}
		self.rank_list[i].guild_id = MsgAdapter.ReadInt()
		self.rank_list[i].score = MsgAdapter.ReadInt()
		self.rank_list[i].guild_name = MsgAdapter.ReadStrN(32)
	end
end

-- 公会争霸 个人信息
SCGBRoleInfo =  SCGBRoleInfo or BaseClass(BaseProtocolStruct)
function SCGBRoleInfo:__init()
	self.msg_type = 6252
	self.kill_role_num = 0
	self.husong_goods_color = 0
	self.history_get_person_credit = 0
	self.history_get_guild_credit = 0
	self.husong_goods_index = 0
	self.is_add_hudun = 0
end

function SCGBRoleInfo:Decode()
	self.kill_role_num = MsgAdapter.ReadShort()
	self.husong_goods_color = MsgAdapter.ReadShort()
	self.history_get_person_credit = MsgAdapter.ReadInt()
	self.history_get_guild_credit = MsgAdapter.ReadInt()
	self.husong_goods_index = MsgAdapter.ReadInt()
	self.is_add_hudun = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	self.count = MsgAdapter.ReadShort()

	self.task_list = {}
	for i = 1, self.count do
		local vo = {}
		vo.task_type = MsgAdapter.ReadShort()						-- 任务类型
		vo.cur_phase = MsgAdapter.ReadChar()						-- 任务当前阶段
		vo.is_complete = MsgAdapter.ReadChar()						-- 任务是否完成
		vo.progress = MsgAdapter.ReadInt()							-- 任务进度
		self.task_list[i] = vo
	end
end

-- 返回公会争霸上一届霸主
SCGBSendWinnerInfo =  SCGBSendWinnerInfo or BaseClass(BaseProtocolStruct)
function SCGBSendWinnerInfo:__init()
	self.msg_type = 6253
end

function SCGBSendWinnerInfo:Decode()
	self.guild_id = MsgAdapter.ReadInt() or 0
	self.camp_king_uid_list = {}

	for i = 1, GUILD_BATTLE.CAMP_TYPE_NUM do
		self.camp_king_uid_list[i] = MsgAdapter.ReadInt()
	end
end

-- 玩家膜拜信息
SCGBWorshipInfo = SCGBWorshipInfo or BaseClass(BaseProtocolStruct)
function SCGBWorshipInfo:__init()
	self.msg_type = 6254
end

function SCGBWorshipInfo:Decode()
	self.next_addexp_timestamp = MsgAdapter.ReadUInt() or 0				-- 下次加经验时间戳(以秒数为时间点)
	self.next_worship_timestamp = MsgAdapter.ReadUInt() or 0			-- 下次膜拜时间戳(以秒数为时间点)
	self.worship_time = MsgAdapter.ReadInt() or 0						-- 玩家膜拜次数
end

-- 返回金箱子位置信息
SCGBGoldBoxPositionInfo = SCGBGoldBoxPositionInfo or BaseClass(BaseProtocolStruct)
function SCGBGoldBoxPositionInfo:__init()
	self.msg_type = 6255
end

function SCGBGoldBoxPositionInfo:Decode()
	self.pos_count = MsgAdapter.ReadInt() or 0
	self.pos_list = {}
	for i = 1, self.pos_count do
		local vo = {}
		vo.x = MsgAdapter.ReadInt()
		vo.y = MsgAdapter.ReadInt()
		self.pos_list[i] = vo
	end
end

-- 膜拜活动信息
SCGBWorshipActivityInfo = SCGBWorshipActivityInfo or BaseClass(BaseProtocolStruct)
function SCGBWorshipActivityInfo:__init()
	self.msg_type = 6256
end

function SCGBWorshipActivityInfo:Decode()
	self.is_open = MsgAdapter.ReadChar() or 0						-- 活动是否开启
	MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
	self.worship_end_timestamp = MsgAdapter.ReadUInt() or 0			-- 活动结束时间戳
end

-- 公会争霸结算奖励信息
SCGuildBattleRewardInfo = SCGuildBattleRewardInfo or BaseClass(BaseProtocolStruct)
function SCGuildBattleRewardInfo:__init()
	self.msg_type = 6258
end

function SCGuildBattleRewardInfo:Decode()
	self.person_credit = MsgAdapter.ReadInt() or 0
	self.guild_credit = MsgAdapter.ReadInt() or 0
	self.count = MsgAdapter.ReadInt() or 0
	self.item_list = {}
	for i = 1, self.count do
		local vo = {}
		vo.item_id = MsgAdapter.ReadUShort()
		vo.num = MsgAdapter.ReadShort()
		vo.is_bind = MsgAdapter.ReadChar()
		MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()
		self.item_list[i] = vo
	end
end