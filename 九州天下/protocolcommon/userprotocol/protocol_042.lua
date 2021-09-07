-- 仙盟捐献结果
SCAddGuildExpSucc = SCAddGuildExpSucc or BaseClass(BaseProtocolStruct)
function SCAddGuildExpSucc:__init()
	self.msg_type = 4201
end

function SCAddGuildExpSucc:Decode()
	self.add_gongxian = MsgAdapter.ReadInt()
	self.add_caifu = MsgAdapter.ReadInt()
end

-- 仙盟守护信息返回
SCGuildPartyInfo = SCGuildPartyInfo or BaseClass(BaseProtocolStruct)
function SCGuildPartyInfo:__init()
	self.msg_type = 4203
	self.got_exp = 0						-- 获得经验
	self.got_xianhun = 0					-- 获得仙魂
	self.got_gongxian = 0					-- 获得贡献
	self.gather_count = 0					-- 采集次数
	self.is_double_rewardt = 0				-- 双倍奖励否
	self.is_clear_cdt = 0					-- 采集CD清理否
	self.next_gather_timet = 0				-- 下次可以采集时间
	self.reset_gather_times = 0
end

function SCGuildPartyInfo:Decode()
	self.got_exp = MsgAdapter.ReadInt()
	self.got_xianhun = MsgAdapter.ReadInt()
	self.got_gongxian = MsgAdapter.ReadInt()
	self.gather_count = MsgAdapter.ReadShort()
	self.is_double_rewardt = MsgAdapter.ReadChar()
	self.is_clear_cdt = MsgAdapter.ReadChar()
	self.next_gather_timet = MsgAdapter.ReadUInt()
	self.reset_gather_times = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
end

--获得仙盟秘境开启状态
SCGuildFbStatus = SCGuildFbStatus or BaseClass(BaseProtocolStruct)
function SCGuildFbStatus:__init()
	self.msg_type = 4205
end

function SCGuildFbStatus:Decode()
	self.open_times = MsgAdapter.ReadShort()
	self.reserve_sh = MsgAdapter.ReadShort()
	self.finish_timestamp = MsgAdapter.ReadUInt()
end

-- 仙盟boss信息返回
SCGuildBossInfo = SCGuildBossInfo or BaseClass(BaseProtocolStruct)
function SCGuildBossInfo:__init()
	self.msg_type = 4206

	self.boss_normal_call_count = 0
	self.boss_super_call_count = 0
	self.boss_level = 0
	self.boss_exp = 0
	self.boss_super_call_uid = 0
	self.boss_super_call_name = ""
end

function SCGuildBossInfo:Decode()
	self.boss_normal_call_count = MsgAdapter.ReadChar()
	self.boss_super_call_count = MsgAdapter.ReadChar()
	self.boss_level = MsgAdapter.ReadShort()
	self.boss_exp = MsgAdapter.ReadInt()
	self.boss_super_call_uid = MsgAdapter.ReadInt()
	self.boss_super_call_name = MsgAdapter.ReadStrN(32)
end

-- 仙盟boss奖励信息
SCBossRewardInfo = SCBossRewardInfo or BaseClass(BaseProtocolStruct)
function SCBossRewardInfo:__init()
	self.msg_type = 4207
end

function SCBossRewardInfo:Decode()
	local count = MsgAdapter.ReadInt()

	self.record_list = {}
	for i = 0, count - 1 do
		local is_befetched = MsgAdapter.ReadInt()
		self.record_list[i] = is_befetched
	end
end

-- 仙盟篝火状态信息
SCGuildBonfireStatus = SCGuildBonfireStatus or BaseClass(BaseProtocolStruct)
function SCGuildBonfireStatus:__init()
	self.msg_type = 4208

	self.open_times = 0
	self.reserve_sh = 0
	self.finish_timestamp = 0
end

function SCGuildBonfireStatus:Decode()
	self.open_times = MsgAdapter.ReadShort()
	self.reserve_sh = MsgAdapter.ReadShort()
	self.finish_timestamp = MsgAdapter.ReadUInt()
end

-- 家族boss召唤事件
SCGuildBossEvent = SCGuildBossEvent or BaseClass(BaseProtocolStruct)
function SCGuildBossEvent:__init()
	self.msg_type = 4215
end

function SCGuildBossEvent:Decode()
	self.event = MsgAdapter.ReadInt() or 0
end

-- 创建仙盟请求
CSCreateGuild = CSCreateGuild or BaseClass(BaseProtocolStruct)
function CSCreateGuild:__init()
	self.msg_type = 4250

	self.guild_name = ""
	self.create_guild_type = 0
	self.knapsack_index = 0
	self.guild_notice = ""
end

function CSCreateGuild:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteStrN(self.guild_name, 32)
	MsgAdapter.WriteInt(self.create_guild_type)
	MsgAdapter.WriteInt(self.knapsack_index)
	MsgAdapter.WriteStrN(self.guild_notice, 256)
end

-- 解散仙盟
CSDismissGuild = CSDismissGuild or BaseClass(BaseProtocolStruct)
function CSDismissGuild:__init()
	self.msg_type = 4251

	self.guild_id = 0
end

function CSDismissGuild:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.guild_id)
end

-- 申请入盟
CSApplyForJoinGuild = CSApplyForJoinGuild or BaseClass(BaseProtocolStruct)
function CSApplyForJoinGuild:__init()
	self.msg_type = 4252

	self.guild_id = 0
	self.is_auto_join = 0
end

function CSApplyForJoinGuild:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.guild_id)
	MsgAdapter.WriteInt(self.is_auto_join)
end

-- 同意申请加入
CSApplyForJoinGuildAck = CSApplyForJoinGuildAck or BaseClass(BaseProtocolStruct)
function CSApplyForJoinGuildAck:__init()
	self.msg_type = 4253

	self.guild_id = 0
	self.result = 0					--0为同意  其他不同意
	self.count = 1
	self.list = {}
end

function CSApplyForJoinGuildAck:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.guild_id)
	MsgAdapter.WriteInt(self.result)
	MsgAdapter.WriteInt(self.count)
	for i = 1, #self.list do
		MsgAdapter.WriteInt(self.list[i])
	end
end

-- 退出仙盟
CSQuitGuild = CSQuitGuild or BaseClass(BaseProtocolStruct)
function CSQuitGuild:__init()
	self.msg_type = 4254

	self.guild_id = 0
end

function CSQuitGuild:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.guild_id)
end

-- 邀请加入军团
CSInviteGuild = CSInviteGuild or BaseClass(BaseProtocolStruct)
function CSInviteGuild:__init()
	self.msg_type = 4255

	self.guild_id = 0
	self.beinvite_uid = 0
end

function CSInviteGuild:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.guild_id)
	MsgAdapter.WriteInt(self.beinvite_uid)
end

-- 回复邀请
CSInviteGuildAck = CSInviteGuildAck or BaseClass(BaseProtocolStruct)
function CSInviteGuildAck:__init()
	self.msg_type = 4256

	self.guild_id = 0
	self.invite_uid = 0
	self.result = 0
end

function CSInviteGuildAck:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.guild_id)
	MsgAdapter.WriteInt(self.invite_uid)
	MsgAdapter.WriteInt(self.result)
end

-- 踢出仙盟
CSKickoutGuild = CSKickoutGuild or BaseClass(BaseProtocolStruct)
function CSKickoutGuild:__init()
	self.msg_type = 4257

	self.guild_id = 0
	self.bekicker_count = 0
	self.list = {}
end

function CSKickoutGuild:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.guild_id)
	MsgAdapter.WriteInt(self.bekicker_count)
	for i = 1, #self.list do
		MsgAdapter.WriteInt(self.list[i])
	end
end

-- 任命请求
CSAppointGuild = CSAppointGuild or BaseClass(BaseProtocolStruct)
function CSAppointGuild:__init()
	self.msg_type = 4258

	self.guild_id = 0
	self.beappoint_uid = 0
	self.post = 0
end

function CSAppointGuild:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.guild_id)
	MsgAdapter.WriteInt(self.beappoint_uid)
	MsgAdapter.WriteInt(self.post)
end

-- 修改仙盟公告
CSGuildChangeNotice = CSGuildChangeNotice or BaseClass(BaseProtocolStruct)
function CSGuildChangeNotice:__init()
	self.msg_type = 4260

	self.guild_id = 0
	self.notice = ""
end

function CSGuildChangeNotice:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.guild_id)
	--self.notice = AdapterToLua:utf8TruncateByByteCount(self.notice, 256)
	MsgAdapter.WriteStrN(self.notice, 256)
end

-- 发送仙盟邮件
CSGuildMailAll = CSGuildMailAll or BaseClass(BaseProtocolStruct)
function CSGuildMailAll:__init()
	self.msg_type = 4261

	self.guild_id = 0
	self.subject = ""
	self.contenttxt_len = 0
	self.contenttxt = ""
end

function CSGuildMailAll:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.guild_id)
	MsgAdapter.WriteStrN(self.subject, 128)
	-- MsgAdapter.WriteInt(self.contenttxt_len)
	MsgAdapter.WriteStr(self.contenttxt)
end

-- 请求获取仙盟基本信息
CSGetGuildInfo = CSGetGuildInfo or BaseClass(BaseProtocolStruct)
function CSGetGuildInfo:__init()
	self.msg_type = 4262

	self.guild_info_type = 0
	self.guild_id = 0
end

function CSGetGuildInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.guild_info_type)
	MsgAdapter.WriteInt(self.guild_id)
end

-- 仙盟成员弹劾请求
CSGuildDelate = CSGuildDelate or BaseClass(BaseProtocolStruct)
function CSGuildDelate:__init()
	self.msg_type = 4263

	self.guild_id = 0
	self.knapsack_index = 0
end

function CSGuildDelate:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.guild_id)
	MsgAdapter.WriteInt(self.knapsack_index)
end

-- 仙盟改名
CSGuildResetName = CSGuildResetName or BaseClass(BaseProtocolStruct)
function CSGuildResetName:__init()
	self.msg_type = 4265

	self.guild_id = 0
	self.new_name = 0
end

function CSGuildResetName:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.guild_id)
	MsgAdapter.WriteStrN(self.new_name, 32)
end

-- 仙盟设置
CSApplyforSetup = CSApplyforSetup or BaseClass(BaseProtocolStruct)
function CSApplyforSetup:__init()
	self.msg_type = 4266

	self.guild_id = 0
	self.applyfor_setup = 0
	self.need_capability = 0
	self.need_level = 0
end

function CSApplyforSetup:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.guild_id)
	MsgAdapter.WriteInt(self.applyfor_setup)
	MsgAdapter.WriteInt(self.need_capability)
	MsgAdapter.WriteInt(self.need_level)
end

-- 仙盟捐献请求
CSAddGuildExp = CSAddGuildExp or BaseClass(BaseProtocolStruct)
function CSAddGuildExp:__init()
	self.msg_type = 4267

	self.type = 0
	self.value = 0
	self.times = 0 	--捐献次数(针对铜币捐献)
	self.item_list = {}
end

function CSAddGuildExp:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.type)
	MsgAdapter.WriteShort(self.times)
	MsgAdapter.WriteInt(self.value)

	if nil == self.item_list then
		self.item_list = {}
	end

	for i=1,8 do
		local item_id = 0
		local item_num = 0
		if nil ~= self.item_list[i] then
			item_id = self.item_list[i].item_id
			item_num = self.item_list[i].item_num
		end
		MsgAdapter.WriteUShort(item_id)
		MsgAdapter.WriteShort(0)
		MsgAdapter.WriteInt(item_num)
	end
end

-- 仙盟招募请求
CSGuildCallIn = CSGuildCallIn or BaseClass(BaseProtocolStruct)
function CSGuildCallIn:__init()
	self.msg_type = 4269
	self.guild_id = 0
end

function CSGuildCallIn:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.guild_id)
end

-- 检查是否能够弹劾盟主
CSGuildCheckCanDelate = CSGuildCheckCanDelate or BaseClass(BaseProtocolStruct)
function CSGuildCheckCanDelate:__init()
	self.msg_type = 4272
	self.guild_id = 0
end

function CSGuildCheckCanDelate:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.guild_id)
end

-- 仙盟守护请求
CSGuildPartyOp = CSGuildPartyOp or BaseClass(BaseProtocolStruct)
function CSGuildPartyOp:__init()
	self.msg_type = 4273
	self.do_what = 0 		-- 1 双倍收益, 2 vip取消cd, 3 重置采集次数
	self.reserve = 0
end

function CSGuildPartyOp:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.do_what)
	MsgAdapter.WriteShort(self.reserve)
end

-- 仙盟酒会开启请求
CSGuildPartyStartReq = CSGuildPartyStartReq or BaseClass(BaseProtocolStruct)
function CSGuildPartyStartReq:__init()
	self.msg_type = 4274
end

function CSGuildPartyStartReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 仙盟秘境状态请求
CSGuildFbStartReq = CSGuildFbStartReq or BaseClass(BaseProtocolStruct)
function CSGuildFbStartReq:__init()
	self.msg_type = 4275
end

function CSGuildFbStartReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 仙盟秘境进入请求
CSGuildFbEnterReq = CSGuildFbEnterReq or BaseClass(BaseProtocolStruct)
function CSGuildFbEnterReq:__init()
	self.msg_type = 4276
end

function CSGuildFbEnterReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--================仙盟运势请求协议======================================
--祝福仙盟某个人
CSGuildZhuLuckyReq = CSGuildZhuLuckyReq or BaseClass(BaseProtocolStruct)
function CSGuildZhuLuckyReq:__init()
	self.msg_type = 4277
	self.be_zhufu_uid = 0
end

function CSGuildZhuLuckyReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.be_zhufu_uid)
end

--请求仙盟所有成员运势信息
CSGetAllGuildMemberLuckyInfo = CSGetAllGuildMemberLuckyInfo or BaseClass(BaseProtocolStruct)
function CSGetAllGuildMemberLuckyInfo:__init()
	self.msg_type = 4278
end

function CSGetAllGuildMemberLuckyInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--邀请仙盟祝福请求
CSInviteLuckyZhufu = CSInviteLuckyZhufu or BaseClass(BaseProtocolStruct)
function CSInviteLuckyZhufu:__init()
	self.msg_type = 4279
	self.invite_uid = 0
end

function CSInviteLuckyZhufu:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.invite_uid)			-- 0是一键祝福
end

----仙盟召唤凶兽
CSGuildCallBeastReq = CSGuildCallBeastReq or BaseClass(BaseProtocolStruct)
function CSGuildCallBeastReq:__init()
	self.msg_type = 4280
end

function CSGuildCallBeastReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end


-- 仙盟升级
CSGuildUpLevel = CSGuildUpLevel or BaseClass(BaseProtocolStruct)
function CSGuildUpLevel:__init()
	self.msg_type = 4282

	self.hall_type = 0
end

function CSGuildUpLevel:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.hall_type)
end

-- 领取buff
CSGuildGetBuff = CSGuildGetBuff or BaseClass(BaseProtocolStruct)
function CSGuildGetBuff:__init()
	self.msg_type = 4283

	self.buff_type = 0
end

function CSGuildGetBuff:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.buff_type)
end

-- 兑换
CSGuildExchange = CSGuildExchange or BaseClass(BaseProtocolStruct)
function CSGuildExchange:__init()
	self.msg_type = 4284

	self.buff_type = 0
	self.item_id = 0
	self.item_num = 0
end

function CSGuildExchange:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteUShort(self.item_id)
	MsgAdapter.WriteShort(self.item_num)
end

-- boss操作
CSGuildBossOperate = CSGuildBossOperate or BaseClass(BaseProtocolStruct)
function CSGuildBossOperate:__init()
	self.msg_type = 4285

	self.oper_type = 0
	self.param = 0
end

function CSGuildBossOperate:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteShort(self.oper_type)
	MsgAdapter.WriteShort(self.param)
end

-- 仙盟篝火开启请求
CSGuildBonfireStartReq = CSGuildBonfireStartReq or BaseClass(BaseProtocolStruct)
function CSGuildBonfireStartReq:__init()
	self.msg_type = 4286
end

function CSGuildBonfireStartReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 仙盟篝火前往请求
CSGuildBonfireGotoReq = CSGuildBonfireGotoReq or BaseClass(BaseProtocolStruct)
function CSGuildBonfireGotoReq:__init()
	self.msg_type = 4287
end

function CSGuildBonfireGotoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 仙盟篝火添加木材请求
CSGuildBonfireAddMucaiReq = CSGuildBonfireAddMucaiReq or BaseClass(BaseProtocolStruct)
function CSGuildBonfireAddMucaiReq:__init()
	self.msg_type = 4288
end

function CSGuildBonfireAddMucaiReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 仙盟仓库操作
CSGuildStorgeOperate = CSGuildStorgeOperate or BaseClass(BaseProtocolStruct)
function CSGuildStorgeOperate:__init()
	self.msg_type = 4289

end

function CSGuildStorgeOperate:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.operate_type)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
	MsgAdapter.WriteInt(self.param3)
	MsgAdapter.WriteInt(self.param4)
end

-- 仙盟仓库下发信息
SCGuildStorgeInfo = SCGuildStorgeInfo or BaseClass(BaseProtocolStruct)
function SCGuildStorgeInfo:__init()
	self.msg_type = 4209
end

function SCGuildStorgeInfo:Decode()
	self.open_grid_count = MsgAdapter.ReadInt()
	self.storage_score = MsgAdapter.ReadInt()
	self.item_list = {}
	local item_count = MsgAdapter.ReadInt()
	for i=0,item_count - 1 do
		local item_data = ProtocolStruct.ReadItemDataWrapper()
		item_data.index = i
		self.item_list[i] = item_data
	end
end

-- 仙盟宝箱信息
SCGuildBoxInfo = SCGuildBoxInfo or BaseClass(BaseProtocolStruct)
function SCGuildBoxInfo:__init()
	self.msg_type = 4211
	self.uplevel_count = 0
	self.assist_count = 0
	self.assist_cd_end_time = 0
	self.MAX_GUILD_BOX_COUNT = 8
	self.info_list = {}
end

function SCGuildBoxInfo:Decode()
	self.uplevel_count = MsgAdapter.ReadShort()
	self.assist_count = MsgAdapter.ReadShort()
	self.assist_cd_end_time = MsgAdapter.ReadUInt()
	for i = 1, self.MAX_GUILD_BOX_COUNT do
		self.info_list[i] = {}
		self.info_list[i].box_level = MsgAdapter.ReadShort()
		self.info_list[i].is_reward = MsgAdapter.ReadShort()
		self.info_list[i].assist_uid = {}
		for j = 1, 4 do
			self.info_list[i].assist_uid[j] = MsgAdapter.ReadInt()
		end
		self.info_list[i].open_time = MsgAdapter.ReadUInt()
		self.info_list[i].assist_name = {}
		for j = 1, 4 do
			self.info_list[i].assist_name[j] = MsgAdapter.ReadStrN(32)
		end
	end
end

-- 仙盟宝箱需要协助信息
SCGuildBoxNeedAssistInfo = SCGuildBoxNeedAssistInfo or BaseClass(BaseProtocolStruct)
function SCGuildBoxNeedAssistInfo:__init()
	self.msg_type = 4212
	self.box_count = 0
	self.info_list = {}
end

function SCGuildBoxNeedAssistInfo:Decode()
	self.box_count = MsgAdapter.ReadInt()
	for i = 1, self.box_count do
		self.info_list[i] = {}
		self.info_list[i].uid = MsgAdapter.ReadInt()
		self.info_list[i].box_index = MsgAdapter.ReadShort()
		self.info_list[i].box_level = MsgAdapter.ReadShort()
		self.info_list[i].open_time = MsgAdapter.ReadUInt()
		self.info_list[i].user_name = MsgAdapter.ReadStrN(32)
	end
end

-- 公会Boss召唤信息
SCGuildBossActivityInfo = SCGuildBossActivityInfo or BaseClass(BaseProtocolStruct)
function SCGuildBossActivityInfo:__init()
	self.msg_type = 4213
	self.boss_id = 0
	self.boss_level = 0
	self.boss_obj_id = 0
	self.is_surper_boss = 0
	self.totem_exp = 0
end

function SCGuildBossActivityInfo:Decode()
	self.boss_id = MsgAdapter.ReadInt()
	self.boss_level = MsgAdapter.ReadInt()
	self.boss_obj_id = MsgAdapter.ReadUShort()
	self.is_surper_boss = MsgAdapter.ReadShort()
	self.totem_exp = MsgAdapter.ReadInt()
end

SCFamilyCallTransferInfo = SCFamilyCallTransferInfo or BaseClass(BaseProtocolStruct)
function SCFamilyCallTransferInfo:__init()
	self.msg_type = 4214
	self.uid = 0
	self.post = 0
	self.name = ""
	self.scene_id = 0
	self.x = 0
	self.y = 0
end

function SCFamilyCallTransferInfo:Decode()
	self.uid = MsgAdapter.ReadInt()
	self.post = MsgAdapter.ReadInt()
	self.name = MsgAdapter.ReadStrN(32)
	self.scene_id = MsgAdapter.ReadInt()
	self.x =  MsgAdapter.ReadInt()
	self.y = MsgAdapter.ReadInt()
end


-- 仙盟仓库改变
SCGuildStorgeChange = SCGuildStorgeChange or BaseClass(BaseProtocolStruct)
function SCGuildStorgeChange:__init()
	self.msg_type = 4210
end

function SCGuildStorgeChange:Decode()
	self.index = MsgAdapter.ReadInt()
	self.item_data = ProtocolStruct.ReadItemDataWrapper()
	self.item_data.index = index
end

-- 仙盟总活跃度下发
SCGuildActiveDegreeInfo = SCGuildActiveDegreeInfo or BaseClass(BaseProtocolStruct)
function SCGuildActiveDegreeInfo:__init()
	self.msg_type = 4723
end

function SCGuildActiveDegreeInfo:Decode()
	self.open_times = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.finish_timestamp = MsgAdapter.ReadUInt()
	self.active_degree = MsgAdapter.ReadInt()
end

-- 升级公会技能请求
CSGuildSkillUplevel = CSGuildSkillUplevel or BaseClass(BaseProtocolStruct)
function CSGuildSkillUplevel:__init()
	self.msg_type = 4290

	self.skill_index = 0
end

function CSGuildSkillUplevel:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.skill_index)
end

-- 升级公会图腾请求
CSGuildUpTotemLevel = CSGuildUpTotemLevel or BaseClass(BaseProtocolStruct)
function CSGuildUpTotemLevel:__init()
	self.msg_type = 4291
end

function CSGuildUpTotemLevel:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 仙盟宝箱操作
CSGuildBoxOperate = CSGuildBoxOperate or BaseClass(BaseProtocolStruct)
function CSGuildBoxOperate:__init()
	self.msg_type = 4292
	self.operate_type = 0
	self.param1 = 0
	self.param2 = 0
end

function CSGuildBoxOperate:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.operate_type)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
end

-- 领取每日奖励
CSGuildFetchReward = CSGuildFetchReward or BaseClass(BaseProtocolStruct)
function CSGuildFetchReward:__init()
	self.msg_type = 4293
end

function CSGuildFetchReward:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 公会领地奖励
CSGuildTerritoryWelfOperate = CSGuildTerritoryWelfOperate or BaseClass(BaseProtocolStruct)
function CSGuildTerritoryWelfOperate:__init()
	self.msg_type = 4294
	self.operate_type = 0
	self.param1 = 0
end

function CSGuildTerritoryWelfOperate:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.operate_type)
	MsgAdapter.WriteInt(self.param1)
end

-- 公会仓库批量操作
CSGuildStorgeOneKeyOperate = CSGuildStorgeOneKeyOperate or BaseClass(BaseProtocolStruct)
function CSGuildStorgeOneKeyOperate:__init()
	self.msg_type = 4295000	-- 因为这是老项目的协议冲突所以后面加3个0避免重复协议号
	self.operate_type = 0
	self.item_count = 0
	self.item_list = {}
end

function CSGuildStorgeOneKeyOperate:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.operate_type)
	MsgAdapter.WriteInt(self.item_count)
	for i = 1, self.item_count do
		local item = self.item_list[i]
		if item then
			MsgAdapter.WriteShort(item.item_index or 0)
			MsgAdapter.WriteUShort(item.param_1 or 0)
		end
	end
end

--发送家族召唤请求
CSFamilyCallReq = CSFamilyCallReq or BaseClass(BaseProtocolStruct)
function CSFamilyCallReq:__init()
	self.msg_type = 4301
end

function CSFamilyCallReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 公会扩展成员请求
CSGuildExtendMemberReq = CSGuildExtendMemberReq or BaseClass(BaseProtocolStruct)
function CSGuildExtendMemberReq:__init()
	self.msg_type = 4296
	self.operate_type = 0
	self.can_use_gold = 0
	self.num = 0
end

function CSGuildExtendMemberReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteChar(self.operate_type)
	MsgAdapter.WriteChar(self.can_use_gold)
	MsgAdapter.WriteShort(self.num)
end

-- 领公会杀boss红包
CSFetchGuildBossRedbag = CSFetchGuildBossRedbag or BaseClass(BaseProtocolStruct)
function CSFetchGuildBossRedbag:__init()
	self.msg_type = 4297
	self.index = 0
end

function CSFetchGuildBossRedbag:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.index)
end

-- 公会复活次数信息
SCGulidReliveTimes = SCGulidReliveTimes or BaseClass(BaseProtocolStruct)
function SCGulidReliveTimes:__init()
	self.msg_type = 4298
end

function SCGulidReliveTimes:Decode()
	self.daily_guild_all_relive_times = MsgAdapter.ReadInt()				-- 公会总复活次数
	self.daily_guild_all_kill_boss_times = MsgAdapter.ReadInt()			-- 公会总杀boss次数
end

-- 公会领取boss红包信息
SCGulidBossRedbagInfo = SCGulidBossRedbagInfo or BaseClass(BaseProtocolStruct)
function SCGulidBossRedbagInfo:__init()
	self.msg_type = 4299
end

function SCGulidBossRedbagInfo:Decode()
	self.daily_use_guild_relive_times = MsgAdapter.ReadInt()					-- 当天已经使用了多少次公会复活次数
	self.daily_boss_redbag_reward_fetch_flag = MsgAdapter.ReadShort()			-- 当天公会的boss红包领取标记
end