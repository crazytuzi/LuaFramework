-------------------温泉---------------------------------
-- 温泉里玩家信息
SCHotspringPlayerInfo =  SCHotspringPlayerInfo or BaseClass(BaseProtocolStruct)
function SCHotspringPlayerInfo:__init()
	self.msg_type = 5352
end

function SCHotspringPlayerInfo:Decode()
	self.popularity = MsgAdapter.ReadInt()			--玩家人气值
	self.partner_id = MsgAdapter.ReadUInt()
	self.server_id = MsgAdapter.ReadUInt()
	self.partner_uid = self.partner_id + (self.server_id * (2 ^ 32))
	self.give_free_times = MsgAdapter.ReadShort()	--已发送的免费次数
	self.swinsuit = MsgAdapter.ReadShort()
	self.role_id = MsgAdapter.ReadUInt()
	self.plat_id = MsgAdapter.ReadUInt()
	self.uuid = self.role_id + (self.plat_id * (2 ^ 32))
	self.partner_obj_id = MsgAdapter.ReadUShort()
	self.question_right_count = MsgAdapter.ReadChar()
	self.question_wrong_count = MsgAdapter.ReadChar()
	self.curr_score = MsgAdapter.ReadInt()
	self.total_exp = MsgAdapter.ReadInt()
	self.skill_use_times_1 = MsgAdapter.ReadShort()				-- 按摩技能使用次数
	self.skill_use_times_2 = MsgAdapter.ReadShort()				-- 砸雪球技能使用次数
	self.skill_1_can_perform_time = MsgAdapter.ReadUInt()		-- 按摩技能可使用时间戳
	self.skill_2_can_perform_time = MsgAdapter.ReadUInt()		-- 砸雪球技能可使用时间戳
	self.gather_times = MsgAdapter.ReadShort()					-- 采集次数
	self.reserve_sh = MsgAdapter:ReadShort()
	self.next_fresh_gather_time = MsgAdapter.ReadUInt()			-- 采集开始物刷新时间戳
end


-- 温泉玩家排名信息
SCHotspringRankInfo =  SCHotspringRankInfo or BaseClass(BaseProtocolStruct)
function SCHotspringRankInfo:__init()
	self.msg_type = 5353
end

function SCHotspringRankInfo:Decode()
	self.popularity = MsgAdapter.ReadInt()
	self.rank = MsgAdapter.ReadInt()
	self.is_open = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
	local rank_count = MsgAdapter.ReadInt()
	self.rank_list = {}
	for i = 1, rank_count do
		self.rank_list[i] = {}
		self.rank_list[i].role_id = MsgAdapter.ReadUInt()
		self.rank_list[i].server_id = MsgAdapter.ReadUInt()
		self.rank_list[i].uuid = self.rank_list[i].role_id + (self.rank_list[i].server_id * (2 ^ 32))
		self.rank_list[i].uid = MsgAdapter.ReadInt()
		self.rank_list[i].popularity = MsgAdapter.ReadInt()
		self.rank_list[i].name = MsgAdapter.ReadStrN(32)
	end
end


-- 请求送礼物
CSHotspringGivePresent =  CSHotspringGivePresent or BaseClass(BaseProtocolStruct)
function CSHotspringGivePresent:__init()
	self.msg_type = 5300
	self.opera_id = 0
	self.server_id = 0
	self.present_id = 0
	self.is_use_gold = 0
	self.is_role_id = 0
end

function CSHotspringGivePresent:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteUInt(self.opera_id)
	MsgAdapter.WriteUInt(self.server_id)
	MsgAdapter.WriteInt(self.present_id)
	MsgAdapter.WriteShort(self.is_use_gold)
	MsgAdapter.WriteShort(self.is_role_id)
end


-- 添加伙伴请求
CSHSAddPartnerReq =  CSHSAddPartnerReq or BaseClass(BaseProtocolStruct)
function CSHSAddPartnerReq:__init()
	self.msg_type = 5301
	self.obj_id = 0
	self.is_yi_jian = 0
end

function CSHSAddPartnerReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteUShort(self.obj_id)
	MsgAdapter.WriteShort(self.is_yi_jian)
end


-- 询问被添加伙伴的对象
SCHSAddPartnerReqRoute =  SCHSAddPartnerReqRoute or BaseClass(BaseProtocolStruct)
function SCHSAddPartnerReqRoute:__init()
	self.msg_type = 5354
end

function SCHSAddPartnerReqRoute:Decode()
	self.req_gamename = MsgAdapter.ReadStrN(32)
	self.req_user_id = MsgAdapter.ReadLL()
	self.req_avatar = MsgAdapter.ReadChar()
	self.req_sex = MsgAdapter.ReadChar()
	self.req_prof = MsgAdapter.ReadChar()
	self.req_camp = MsgAdapter.ReadChar()
	self.req_level = MsgAdapter.ReadInt()
	self.req_avatar_key_big = MsgAdapter.ReadUInt()
	self.req_avatar_key_small = MsgAdapter.ReadUInt()
end


-- 被添加伙伴对象处理邀请伙伴请求
CSHSAddPartnerRet =  CSHSAddPartnerRet or BaseClass(BaseProtocolStruct)
function CSHSAddPartnerRet:__init()
	self.msg_type = 5302
	self.req_opera_id = 0
	self.req_server_id = 0
	self.req_gamename = ""
	self.is_accept = 0
	self.reserved = 0
	self.req_sex = 0
	self.req_prof = 0
end

function CSHSAddPartnerRet:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteUInt(self.req_opera_id)
	MsgAdapter.WriteUInt(self.req_server_id)
	MsgAdapter.WriteStrN(self.req_gamename, 32)
	MsgAdapter.WriteChar(self.is_accept)
	MsgAdapter.WriteChar(self.reserved)
	MsgAdapter.WriteChar(self.req_sex)
	MsgAdapter.WriteChar(self.req_prof)
end


-- 取消伙伴请求
CSHSDeleteParter =  CSHSDeleteParter or BaseClass(BaseProtocolStruct)
function CSHSDeleteParter:__init()
	self.msg_type = 5303
end

function CSHSDeleteParter:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end


-- 接收伙伴信息
SCHSSendPartnerInfo =  SCHSSendPartnerInfo or BaseClass(BaseProtocolStruct)
function SCHSSendPartnerInfo:__init()
	self.msg_type = 5350
end

function SCHSSendPartnerInfo:Decode()
	self.partner_id = MsgAdapter.ReadUInt()
	self.server_id = MsgAdapter.ReadUInt()
	self.partner_uid = self.partner_id + (self.server_id * (2 ^ 32))
	self.partner_obj_id = MsgAdapter.ReadUShort()
end

-- 接收经验信息
SCHSAddExpInfo =  SCHSAddExpInfo or BaseClass(BaseProtocolStruct)
function SCHSAddExpInfo:__init()
	self.msg_type = 5351
end

function SCHSAddExpInfo:Decode()
	self.add_exp_total = MsgAdapter.ReadInt()
	self.add_addition = MsgAdapter.ReadInt()
end

local function DecodeShuangXiuInfo()
	local t = {}
	t.role_obj_id1 = MsgAdapter.ReadUShort()
	t.role_obj_id2 = MsgAdapter.ReadUShort()
	return t
end

-- 接收双修信息
SCHSShuangxiuInfo =  SCHSShuangxiuInfo or BaseClass(BaseProtocolStruct)
function SCHSShuangxiuInfo:__init()
	self.msg_type = 5355
end

function SCHSShuangxiuInfo:Decode()
	self.role_1_obj_id = MsgAdapter.ReadUShort()
	self.role_1_partner_obj_id = MsgAdapter.ReadUShort()
	self.role_2_obj_id = MsgAdapter.ReadUShort()
	self.role_2_partner_obj_id = MsgAdapter.ReadUShort()
end
-------------------温泉end---------------------------------

-- 获取答题排名信息
SCHSQARankInfo = SCHSQARankInfo or BaseClass(BaseProtocolStruct)

function SCHSQARankInfo:__init()
	self.msg_type = 5356
	self.self_score = 0
	self.self_rank = 0
	self.is_finish = 0
	self.reserve_1 = 0
	self.reserve_2 = 0
	self.RANK_NUM = 100
	self.rank_count = 0
	self.rank_list = {}
end

function SCHSQARankInfo:Decode()
	self.rank_list = {}
	self.self_score = MsgAdapter.ReadInt()
	self.self_rank = MsgAdapter.ReadInt()
	self.is_finish = MsgAdapter.ReadChar()
	self.reserve_1 = MsgAdapter.ReadChar()
	self.reserve_2 = MsgAdapter.ReadShort()
	self.rank_count = MsgAdapter.ReadInt()
	self.rank_count = self.rank_count > 10 and 10 or self.rank_count
	for i = 1, self.rank_count do
		self.rank_list[i] = {}
		self.rank_list[i].uuid = MsgAdapter.ReadLL()
		self.rank_list[i].uid = MsgAdapter.ReadInt()
		self.rank_list[i].score = MsgAdapter.ReadInt()
		self.rank_list[i].name = MsgAdapter.ReadStrN(32)
	end
end

-- 获取答题内容
SCHSQAQuestionBroadcast = SCHSQAQuestionBroadcast or BaseClass(BaseProtocolStruct)

function SCHSQAQuestionBroadcast:__init()
	self.msg_type = 5357
	self.curr_question_begin_time = 0
	self.curr_question_end_time = 0
	self.next_question_start_time = 0			-- 下一题开始时间
	self.broadcast_question_total = 0
	self.curr_question_id = 0
	self.is_exchange = 0
	self.curr_question_str = ""
	self.curr_answer0_desc_str = ""
	self.curr_answer1_desc_str = ""
end

function SCHSQAQuestionBroadcast:Decode()
	self.curr_question_begin_time = MsgAdapter.ReadUInt()
	self.curr_question_end_time = MsgAdapter.ReadUInt()
	self.next_question_start_time = MsgAdapter.ReadUInt()
	self.broadcast_question_total = MsgAdapter.ReadShort()
	self.curr_question_id = MsgAdapter.ReadShort()
	self.is_exchange = MsgAdapter.ReadInt()
	self.curr_question_str = MsgAdapter.ReadStrN(128)
	self.curr_answer0_desc_str = MsgAdapter.ReadStrN(128)
	self.curr_answer1_desc_str = MsgAdapter.ReadStrN(128)
end

--请求答题榜首的信息
CSHSQAFirstPosReq = CSHSQAFirstPosReq or BaseClass(BaseProtocolStruct)
function CSHSQAFirstPosReq:__init()
	self.msg_type = 5304
end

function CSHSQAFirstPosReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--返回题榜首的位置
SCHSQASendFirstPos = SCHSQASendFirstPos or BaseClass(BaseProtocolStruct)
function SCHSQASendFirstPos:__init()
	self.msg_type = 5358
	self.pos_x = 0
	self.pos_y = 0
end

function SCHSQASendFirstPos:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	MsgAdapter.ReadShort()
	self.pos_x = MsgAdapter.ReadInt()
	self.pos_y = MsgAdapter.ReadInt()
end

-- 玩家答题请求
CSHSQAAnswerReq = CSHSQAAnswerReq or BaseClass(BaseProtocolStruct)

function CSHSQAAnswerReq:__init()
	self.msg_type = 5305
	self.is_use_item = 0
	self.choose = 0
end

function CSHSQAAnswerReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.is_use_item)
	MsgAdapter.WriteShort(self.choose)
end

-- 玩家回答结果
SCHSQAnswerResult = SCHSQAnswerResult or BaseClass(BaseProtocolStruct)

function SCHSQAnswerResult:__init()
	self.msg_type = 5359
	self.result = 0
	self.right_result = 0
end

function SCHSQAnswerResult:Decode()
	self.result = MsgAdapter.ReadInt()
	self.right_result = MsgAdapter.ReadInt()
end

-- 玩家请求使用变身卡
CSHSQAUseCardReq = CSHSQAUseCardReq or BaseClass(BaseProtocolStruct)

function CSHSQAUseCardReq:__init()
	self.msg_type = 5306
	self.target_uid = 0
end

function CSHSQAUseCardReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.target_uid)
end

-- 玩家请求使用技能
CSHSUseSkillReq = CSHSUseSkillReq or BaseClass(BaseProtocolStruct)

function CSHSUseSkillReq:__init()
	self.msg_type = 5360
	self.obj_id = 0
	self.skill_type = 0
end

function CSHSUseSkillReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteUShort(self.obj_id)
	MsgAdapter.WriteShort(self.skill_type)
end

-- 玩家使用技能对象信息
SCHSNoticeSkillInfo = SCHSNoticeSkillInfo or BaseClass(BaseProtocolStruct)

function SCHSNoticeSkillInfo:__init()
	self.msg_type = 5361
	self.use_obj_id = 0
	self.be_use_obj_id = 0
	self.skill_type = 0
	self.reserve = 0
end

function SCHSNoticeSkillInfo:Decode()
	self.use_obj_id = MsgAdapter.ReadUShort()
	self.be_use_obj_id = MsgAdapter.ReadUShort()
	self.skill_type = MsgAdapter.ReadShort()
	self.reserve = MsgAdapter.ReadShort()
end


SCCrossGuildBattleGetMonsterInfoResp = SCCrossGuildBattleGetMonsterInfoResp or BaseClass(BaseProtocolStruct)

function SCCrossGuildBattleGetMonsterInfoResp:__init()
   self.msg_type = 5379
   self.scene_list = {}
end

function SCCrossGuildBattleGetMonsterInfoResp:Decode()
   self.scene_list = {}
    for i = 1, 6 do
	    self.scene_list[i] = MsgAdapter.ReadInt()
    end
end


-- 发送答题内容
SCQuestionBroadcast = SCQuestionBroadcast or BaseClass(BaseProtocolStruct)

function SCQuestionBroadcast:__init()
	self.msg_type = 5380
	self.question_type = 0
	self.cur_question_id = 0
	self.cur_question_str = ""
	self.cur_answer_desc_1 = ""
	self.cur_answer_desc_2 = ""
	self.cur_answer_desc_3 = ""
	self.cur_answer_desc_4 = ""
	self.reserve = 0
end

function SCQuestionBroadcast:Decode()
	self.question_type = MsgAdapter.ReadShort()
	self.cur_question_id = MsgAdapter.ReadShort()

	self.cur_question_str = MsgAdapter.ReadStrN(128)
	self.cur_answer_desc_1 = MsgAdapter.ReadStrN(128)
	self.cur_answer_desc_2 = MsgAdapter.ReadStrN(128)
	self.cur_answer_desc_3 = MsgAdapter.ReadStrN(128)
	self.cur_answer_desc_4 = MsgAdapter.ReadStrN(128)

	self.cur_question_begin_time = MsgAdapter.ReadUInt()
	self.cur_question_end_time = MsgAdapter.ReadUInt()
	self.next_question_begin_time = MsgAdapter.ReadUInt()
end

-- 玩家答题请求
CSQuestionAnswerReq = CSQuestionAnswerReq or BaseClass(BaseProtocolStruct)

function CSQuestionAnswerReq:__init()
	self.msg_type = 5381
	self.answer_type = 0
	self.choose = 0
end

function CSQuestionAnswerReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.answer_type)
	MsgAdapter.WriteShort(self.choose)
end

-- 发送玩家回答结果
SCQuestionAnswerResult = SCQuestionAnswerResult or BaseClass(BaseProtocolStruct)

function SCQuestionAnswerResult:__init()
	self.msg_type = 5382
	self.result = 0
	self.right_result = 0
end

function SCQuestionAnswerResult:Decode()
	self.answer_type = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.result = MsgAdapter.ReadShort()
	self.right_result = MsgAdapter.ReadShort()
end

-- 公会答题排名信息
SCQuestionGuildRankInfo = SCQuestionGuildRankInfo or BaseClass(BaseProtocolStruct)
function SCQuestionGuildRankInfo:__init()
	self.msg_type = 5383
	self.rank_list = {}
end

function SCQuestionGuildRankInfo:Decode()
	self.rank_list = {}
	local rank_count = MsgAdapter.ReadInt()
	for i=1,rank_count do
		self.rank_list[i] = {}
		self.rank_list[i].uid = MsgAdapter.ReadInt()
		self.rank_list[i].right_answer_num = MsgAdapter.ReadInt()
		self.rank_list[i].name = MsgAdapter.ReadStrN(32)
	end
end

--发送玩家回答结果
SCQuestionRightAnswerNum = SCQuestionRightAnswerNum or BaseClass(BaseProtocolStruct)
function SCQuestionRightAnswerNum:__init()
	self.msg_type = 5384
	self.world_right_answer_num = 0
	self.guild_right_answer_num = 0
end

function SCQuestionRightAnswerNum:Decode()
	self.world_right_answer_num = MsgAdapter.ReadInt()
	self.guild_right_answer_num = MsgAdapter.ReadInt()
end

--5743 排行榜信息
SCCrossGuildBattleSceneInfo = SCCrossGuildBattleSceneInfo or BaseClass(BaseProtocolStruct)
function SCCrossGuildBattleSceneInfo:__init()
	self.msg_type = 5373

	self.scene_id = 0
	self.flag_list = {}
	self.guild_join_num_list = {}
	self.rank_list_count = 0
	self.rank_list = {}
end

function SCCrossGuildBattleSceneInfo:Decode()
	self.scene_id = MsgAdapter.ReadInt()
	self.flag_list = {}
	for i=1,CROSS_GUILDBATTLE.CROSS_GUILDBATTLE_MAX_FLAG_IN_SCENE do 		--CROSS_GUILDBATTLE_MAX_FLAG_IN_SCENE = 3;// 最大旗子数在场景中
		local flag_vo = {}
		flag_vo.monster_id = MsgAdapter.ReadInt()
		flag_vo.plat_type = MsgAdapter.ReadInt()
		flag_vo.server_id = MsgAdapter.ReadInt()
		flag_vo.guild_name = MsgAdapter.ReadStrN(32)
		flag_vo.cur_hp = MsgAdapter.ReadInt()
		flag_vo.max_hp = MsgAdapter.ReadInt()
		self.flag_list[i] = flag_vo
	end

	self.guild_join_num_list = {}
	for i=1, CROSS_GUILDBATTLE.CROSS_GUILDBATTLE_MAX_SCENE_NUM do
		self.guild_join_num_list[i] = MsgAdapter.ReadInt()
	end

	self.rank_list_count = MsgAdapter.ReadInt()
	self.rank_list = {}
	for i=1, self.rank_list_count do 		--CROSS_GUILDBATTLE_MAX_GUILD_RANK_NUM = 5;	// 跨服帮派战前5
		local rank_vo = {}
		rank_vo.plat_type = MsgAdapter.ReadInt()
		rank_vo.server_id = MsgAdapter.ReadInt()
		rank_vo.guild_name = MsgAdapter.ReadStrN(32)
		rank_vo.score = MsgAdapter.ReadInt()
		rank_vo.own_num = MsgAdapter.ReadInt()
		self.rank_list[i] = rank_vo
	end
end

SCCrossGuildBattleNotifyInfo = SCCrossGuildBattleNotifyInfo or BaseClass(BaseProtocolStruct)
function SCCrossGuildBattleNotifyInfo:__init()
	self.msg_type = 5374
	self.notify_type = 0
	self.param_1 = 0
	self.param_2 = 0
end

function SCCrossGuildBattleNotifyInfo:Decode()
	self.notify_type = MsgAdapter.ReadInt()
	self.param_1 = MsgAdapter.ReadInt()				--个人积分
	self.param_2 = MsgAdapter.ReadInt()
end

SCCrossGuildBattleInfo = SCCrossGuildBattleInfo or BaseClass(BaseProtocolStruct)
function SCCrossGuildBattleInfo:__init()
	self.msg_type = 5375
	self.kf_reward_flag = 0
	self.guild_reward_flag = 0
	self.kf_battle_list = {}
end

function SCCrossGuildBattleInfo:Decode()
	self.kf_reward_flag = MsgAdapter.ReadInt()	
	self.guild_reward_flag = MsgAdapter.ReadInt()	
	self.is_can_reward = MsgAdapter.ReadInt()	
	self.kf_battle_list = {}					
	for i = 1, CROSS_GUILDBATTLE.CROSS_GUILDBATTLE_MAX_SCENE_NUM do 				--CROSS_GUILDBATTLE_MAX_SCENE_NUM = 6帮派场景个数	
		local vo = {}
		if i == 1 then
			vo.sort = 2
		elseif i == 2 then
			vo.sort = 1
		else
			vo.sort = i
		end
		vo.index = i
		vo.plat_type = MsgAdapter.ReadInt()
		vo.server_id = MsgAdapter.ReadInt()
		vo.guild_id = MsgAdapter.ReadInt()
		vo.is_our_guild = MsgAdapter.ReadInt()
		vo.guild_name = MsgAdapter.ReadStrN(32)
		vo.guild_tuanzhang_name = MsgAdapter.ReadStrN(32)
		vo.prof = MsgAdapter.ReadChar()
		vo.sex = MsgAdapter.ReadChar()
		vo._ = MsgAdapter.ReadShort()

		-- 服务器不知道为什么没数据 先暂时这样处理，vo.prof从1开始的 职业不为0 为0表示有问题
	    if vo.prof == 0 then
	        vo.prof = math.floor(math.random(1, 3))
	        vo.sex = math.floor(math.random(0, 1))
	    end

		self.kf_battle_list[i] = vo
	end
end

--5370跨服帮派战，操作请求
CSCrossGuildBattleOperate = CSCrossGuildBattleOperate or BaseClass(BaseProtocolStruct)
function CSCrossGuildBattleOperate:__init()
	self.msg_type = 5370
	self.req_type = 0
	self.param1 = 0
	self.param2 = 0
end

function CSCrossGuildBattleOperate:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.req_type)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
end

CSCrossGuildBattleGetRankInfoReq = CSCrossGuildBattleGetRankInfoReq or BaseClass(BaseProtocolStruct)
function CSCrossGuildBattleGetRankInfoReq:__init()
	self.msg_type = 5371
end

function CSCrossGuildBattleGetRankInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--跨服排行信息
SCCrossGuildBattleGetRankInfoResp = SCCrossGuildBattleGetRankInfoResp or BaseClass(BaseProtocolStruct)
function SCCrossGuildBattleGetRankInfoResp:__init()
	self.msg_type = 5372
end

function SCCrossGuildBattleGetRankInfoResp:Decode()
	self.info_type = MsgAdapter.ReadInt()
	self.scene_list = {}
	for i = 1, 6 do
		self.rank_list = {}
		for j = 1 ,10 do
			local guild_info = {}
			guild_info.guild_name = MsgAdapter.ReadStrN(32)
			guild_info.server_id  = MsgAdapter.ReadInt()
			guild_info.get_score  = MsgAdapter.ReadInt()
			guild_info.rank = j

			if guild_info.server_id > 0 then
				table.insert(self.rank_list, guild_info)
			end
		end
		self.scene_list[i] = self.rank_list
	end
end

SCCrossGuildBattleTaskInfo = SCCrossGuildBattleTaskInfo or BaseClass(BaseProtocolStruct)
function SCCrossGuildBattleTaskInfo:__init()
	self.msg_type = 5376
end

function SCCrossGuildBattleTaskInfo:Decode()
	self.task_finish_flag = {}
	for i=1,CROSS_GUILDBATTLE.CROSS_GUILDBATTLE_MAX_SCENE_NUM do
		self.task_finish_flag[i] = MsgAdapter.ReadInt()
	end
	self.task_record = {}
	for i=1,CROSS_GUILDBATTLE.CROSS_GUILDBATTLE_MAX_SCENE_NUM do
		self.task_record[i] = {}
		for x=1,CROSS_GUILDBATTLE.CROSS_GUILDBATTLE_MAX_TASK_NUM do
			self.task_record[i][x] = MsgAdapter.ReadInt()
		end
	end
end

SCCrossGuildBattleBossInfo = SCCrossGuildBattleBossInfo or BaseClass(BaseProtocolStruct)
function SCCrossGuildBattleBossInfo:__init()
	self.msg_type = 5377
end

function SCCrossGuildBattleBossInfo:Decode()
	self.scene_id = MsgAdapter.ReadInt()
	self.is_update = MsgAdapter.ReadChar()
	--############保留位
	self.param1 = MsgAdapter.ReadChar()
	self.param2 = MsgAdapter.ReadShort()
	--##############
	self.count = MsgAdapter.ReadInt()
	self.boss_list = {}
	for i=1,self.count do
		local v = {}
		v.boss_id = MsgAdapter.ReadInt()
		v.status = MsgAdapter.ReadInt()
		v.next_refresh_time = MsgAdapter.ReadUInt()
		self.boss_list[i] = v
	end
end