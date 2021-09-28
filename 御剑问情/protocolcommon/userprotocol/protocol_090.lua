
-- 服务器时间返回
SCTimeAck = SCTimeAck or BaseClass(BaseProtocolStruct)
function SCTimeAck:__init()
	self.msg_type = 9001

	self.server_time = 0
	self.server_real_start_time = 0
	self.open_days = 0
	self.server_real_combine_time = 0
end

function SCTimeAck:Decode()
	self.server_time = MsgAdapter.ReadUInt()
	self.server_real_start_time = MsgAdapter.ReadUInt()
	self.open_days = MsgAdapter.ReadInt()
	self.server_real_combine_time = MsgAdapter.ReadUInt()
end

----------------------------结婚--------------------------
-- 结婚操作
CSMarryOperate = CSMarryOperate or BaseClass(BaseProtocolStruct)
function CSMarryOperate:__init()
	self.msg_type = 9010
end

function CSMarryOperate:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.ope_type)
	MsgAdapter.WriteInt(self.param1)
end

-- 结婚操作回馈
SCMarryRetInfo = SCMarryRetInfo or BaseClass(BaseProtocolStruct)
function SCMarryRetInfo:__init()
	self.msg_type = 9011
end

function SCMarryRetInfo:Decode()
	self.ret_type = MsgAdapter.ReadInt()
	self.ret_val = MsgAdapter.ReadInt()
end

-- 情缘操作请求
CSQingYuanOperaReq = CSQingYuanOperaReq or BaseClass(BaseProtocolStruct)
function CSQingYuanOperaReq:__init()
	self.msg_type = 9013
	self.opera_type = 0
	self.param1 = 0
	self.param2 = 0
end

function CSQingYuanOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opera_type)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
end

-- 情缘信息
SCQingYuanAllInfo = SCQingYuanAllInfo or BaseClass(BaseProtocolStruct)
function SCQingYuanAllInfo:__init()
	self.msg_type = 9014
	self.info_type = 0
	self.param_ch1 = 0
	self.param_ch2 = 0
	self.param_ch3 = 0
	self.param_ch4 = 0
	self.param2 = 0
	self.role_name = ""
end

function SCQingYuanAllInfo:Decode()
	self.info_type = MsgAdapter.ReadInt()
	self.param_ch1 = MsgAdapter.ReadChar()
	self.param_ch2 = MsgAdapter.ReadChar()
	self.param_ch3 = MsgAdapter.ReadChar()
	self.param_ch4 = MsgAdapter.ReadChar()
	self.param2 = MsgAdapter.ReadInt()
	self.role_name = MsgAdapter.ReadStrN(32)
end

-- 情缘婚礼信息
SCQingYuanWeddingAllInfo = SCQingYuanWeddingAllInfo or BaseClass(BaseProtocolStruct)
function SCQingYuanWeddingAllInfo:__init()
	self.msg_type = 9015
	self.role_id = 0
	self.lover_role_id = 0
	self.wedding_type = 0
	self.has_invite_guests_num = 0
	self.can_invite_guest_num = 0
	self.wedding_yuyue_seq = 0
	self.count = 0

	self.guests_list = {}
end

function SCQingYuanWeddingAllInfo:Decode()
	self.role_id = MsgAdapter.ReadInt()
	self.lover_role_id = MsgAdapter.ReadInt()
	self.wedding_type = MsgAdapter.ReadChar()
	self.has_invite_guests_num = MsgAdapter.ReadChar()
	self.can_invite_guest_num = MsgAdapter.ReadChar()
	self.wedding_yuyue_seq = MsgAdapter.ReadChar()
	self.count = MsgAdapter.ReadInt()

	self.guests_list = {}
	for i = 1, self.count do
		self.guests_list[i] = {}
		self.guests_list[i].user_id = MsgAdapter.ReadInt()
		self.guests_list[i].name = MsgAdapter.ReadStrN(32)
	end
end

-- 祝福历史记录
SCWeddingBlessingRecordInfo = SCWeddingBlessingRecordInfo or BaseClass(BaseProtocolStruct)
function SCWeddingBlessingRecordInfo:__init()
	self.msg_type = 9016
	self.bless_max_record_num = 10
	self.count = 0
end

function SCWeddingBlessingRecordInfo:Decode()
	self.count = MsgAdapter.ReadInt()
	self.bless_record_list = {}
	for i = 1, self.count do
		local vo = {}
		vo.role_name = MsgAdapter.ReadStrN(32)
		vo.to_role_name = MsgAdapter.ReadStrN(32)
		vo.bless_type = MsgAdapter.ReadInt()
		vo.param = MsgAdapter.ReadInt()
		vo.timestamp = MsgAdapter.ReadUInt()
		self.bless_record_list[self.count - i + 1] = vo		-- 从后往前储数据
	end
end

-- 申请者信息
SCWeddingApplicantInfo = SCWeddingApplicantInfo or BaseClass(BaseProtocolStruct)
function SCWeddingApplicantInfo:__init()
	self.msg_type = 9017
	self.guests_max_num = 30
	self.count = 0
end

function SCWeddingApplicantInfo:Decode()
	self.count = MsgAdapter.ReadInt()
	self.guests_list = {}
	for i = 1, self.count do
		self.guests_list[i] = {}
		self.guests_list[i].user_id = MsgAdapter.ReadInt()
		self.guests_list[i].role_name = MsgAdapter.ReadStrN(32)
	end
end
-- 当前婚礼信息
SCHunYanCurWeddingAllInfo = SCHunYanCurWeddingAllInfo or BaseClass(BaseProtocolStruct)
function SCHunYanCurWeddingAllInfo:__init()
	self.msg_type = 9018
end

function SCHunYanCurWeddingAllInfo:Decode()
	self.marryuser_list = {}
	for i = 1, 2 do
		local vo = {}
		vo.marry_uid = MsgAdapter.ReadInt()
		vo.marry_name = MsgAdapter.ReadStrN(32)
		vo.sex = MsgAdapter.ReadChar()
		vo.prof = MsgAdapter.ReadChar()
		vo.camp = MsgAdapter.ReadChar()
		vo.hongbao_count = MsgAdapter.ReadChar()			-- 发了多少次红包的数量
		vo.avatar_key_big = MsgAdapter.ReadInt()			-- long long avator_timestamp; 拆分成两个两个int型的
		vo.avatar_key_small = MsgAdapter.ReadInt()
		self.marryuser_list[i] = vo
	end

	self.cur_wedding_seq = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
	self.wedding_index = MsgAdapter.ReadInt()
	self.count = MsgAdapter.ReadInt()
	self.guests_uid = {}
	for i= 1, self.count do
		self.guests_uid[i] = {}
		self.guests_uid[i].user_id = MsgAdapter.ReadInt()
	end
end

-- 婚礼玩家个人信息
SCWeddingRoleInfo = SCWeddingRoleInfo or BaseClass(BaseProtocolStruct)
function SCWeddingRoleInfo:__init()
	self.msg_type = 9019
	self.wedding_liveness = 0
	self.is_baitang = 0
	self.is_in_red_bag_fulsh_time = 0
	self.banquet_has_gather_num = 0
	self.cur_turn_has_gather_red_bag = 0
	self.total_exp = 0
end

function SCWeddingRoleInfo:Decode()
	self.wedding_liveness = MsgAdapter.ReadShort()				-- 热度
	self.is_baitang = MsgAdapter.ReadChar()						-- 是否拜堂
	self.is_in_red_bag_fulsh_time = MsgAdapter.ReadChar()		-- 是否在红包刷新时间
	self.banquet_has_gather_num = MsgAdapter.ReadShort()		-- 已经采集酒席的数量
	self.cur_turn_has_gather_red_bag = MsgAdapter.ReadShort()	-- 不同热度采集红包个数
	self.total_exp = MsgAdapter.ReadLL()						-- 婚宴中挂机获得的经验
end

----------------------------结婚end--------------------------

------------------------------婚宴答题--------------------------------
-- 婚宴答题个人信息
SCHunyanQuestionUserInfo = SCHunyanQuestionUserInfo or BaseClass(BaseProtocolStruct)
function SCHunyanQuestionUserInfo:__init()
	self.msg_type = 9030
end

function SCHunyanQuestionUserInfo:Decode()
	self.user_info = {}
	self.user_info.question_count = MsgAdapter.ReadShort()			--题目总数量
	self.user_info.cur_question_idx = MsgAdapter.ReadShort()		--当前答题下标
	self.user_info.question_score = MsgAdapter.ReadInt()			--答题积分
	self.user_info.next_answer_timestamp = MsgAdapter.ReadUInt()	--下次可以答题的时间戳

	self.question_list = {}
	for i=1,self.user_info.question_count do
		local vo = {}
		vo.question_id = MsgAdapter.ReadShort()						--题目id
		vo.npc_pos_seq = MsgAdapter.ReadChar()						--npc_pos seq
		vo.answer_status = MsgAdapter.ReadChar()					--答题状态 1已答题 0未答题
		self.question_list[i] = vo
	end
end

-- 婚宴答题排行信息MAX_RANK_COUNT = 100
SCHunyanQuestionRankInfo = SCHunyanQuestionRankInfo or BaseClass(BaseProtocolStruct)
function SCHunyanQuestionRankInfo:__init()
	self.msg_type = 9031
end

function SCHunyanQuestionRankInfo:Decode()
	self.rank_count = MsgAdapter.ReadInt()
	self.rank_list = {}
	for i=1,self.rank_count do
		local vo = {}
		vo.rank = i									--玩家排名
		vo.role_id = MsgAdapter.ReadInt()			--玩家id
		vo.name = MsgAdapter.ReadStrN(32)			--玩家名字
		vo.score = MsgAdapter.ReadInt()				--玩家积分
		vo.timestamp = MsgAdapter.ReadUInt()		--玩家上榜时间戳
		self.rank_list[i] = vo
	end
end

-- 婚宴答题对错返回
SCHunyanAnswerResult = SCHunyanAnswerResult or BaseClass(BaseProtocolStruct)
function SCHunyanAnswerResult:__init()
	self.msg_type = 9032
end

function SCHunyanAnswerResult:Decode()
	self.npc_seq = MsgAdapter.ReadShort()
	self.is_righ = MsgAdapter.ReadShort()
end
------------------------------婚宴答题end--------------------------------

-- 请求服务器时间
CSTimeReq = CSTimeReq or BaseClass(BaseProtocolStruct)
function CSTimeReq:__init()
	self.msg_type = 9051
end

function CSTimeReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

SCDisconnectNotice = SCDisconnectNotice or BaseClass(BaseProtocolStruct)
function SCDisconnectNotice:__init()
	self.msg_type = 9003
end

function SCDisconnectNotice:Decode()
	self.reason = MsgAdapter.ReadInt()
end

SCCrossShuijingUserInfo = SCCrossShuijingUserInfo or BaseClass(BaseProtocolStruct)

function SCCrossShuijingUserInfo:__init()
	self.msg_type = 9050
end

function SCCrossShuijingUserInfo:Decode()
	self.cur_gather_times = MsgAdapter.ReadShort()
	self.lastday_remain_gather_times = MsgAdapter.ReadShort()
	self.wudi_gather_buff_end_timestamp = MsgAdapter.ReadUInt()
end

---中秋连续充值
SCRAVersionContinueChongzhiInfo = SCRAVersionContinueChongzhiInfo or BaseClass(BaseProtocolStruct)

function SCRAVersionContinueChongzhiInfo:__init()
	self.msg_type = 9083

    self.today_chongzhi = 0           --今日充值数
    self.can_fetch_reward_flag = 0           -- 奖励激活标记
    self.has_fetch_reward_flag = 0           -- 奖励领取标记
    self.continue_chongzhi_days = 0           -- 连续充值天数
    self.reserve1 = 0
    self.reserve2 = 0
end

function SCRAVersionContinueChongzhiInfo:Decode()
	self.today_chongzhi = MsgAdapter.ReadUInt()           --今日充值数
    self.can_fetch_reward_flag = MsgAdapter.ReadShort()           -- 奖励激活标记
    self.has_fetch_reward_flag = MsgAdapter.ReadShort()           -- 奖励领取标记
    self.continue_chongzhi_days = MsgAdapter.ReadChar()           -- 连续充值天数
    self.reserve1 = MsgAdapter.ReadChar()
    self.reserve2 = MsgAdapter.ReadShort()
end

--中秋欢乐摇奖信息
SCRAHuanLeYaoJiangTwoInfo = SCRAHuanLeYaoJiangTwoInfo or BaseClass(BaseProtocolStruct)
function SCRAHuanLeYaoJiangTwoInfo:__init()
	self.msg_type = 9086
    self.ra_huanleyaojiang_next_free_tao_timestamp = 0
    self.chou_times = 0
    self.reward_flag = 0
end

function SCRAHuanLeYaoJiangTwoInfo:Decode()
	self.ra_huanleyaojiang_next_free_tao_timestamp = MsgAdapter.ReadUInt()
    self.chou_times = MsgAdapter.ReadInt()
    self.reward_flag = MsgAdapter.ReadInt()
end

-- 中秋欢乐摇奖结果信息
SCRAHuanLeYaoJiangTaoResultTwoInfo = SCRAHuanLeYaoJiangTaoResultTwoInfo or BaseClass(BaseProtocolStruct)
function SCRAHuanLeYaoJiangTaoResultTwoInfo:__init()
	self.msg_type = 9087
    self.count = 0
    self.huanleyaojiang_tao_seq = {}
end

function SCRAHuanLeYaoJiangTaoResultTwoInfo:Decode()

	self.count = MsgAdapter.ReadInt()
    self.huanleyaojiang_tao_seq = {}

    for i = 1, self.count do
		self.huanleyaojiang_tao_seq[i] = MsgAdapter.ReadShort()
    end
end

-----------------------一元夺宝---------------------
-- 夺宝
SCCloudPurchaseInfo = SCCloudPurchaseInfo or BaseClass(BaseProtocolStruct)

function SCCloudPurchaseInfo:__init()
	self.msg_type = 9040

	self.can_buy_timestamp_list = {}
	self.item_list = {}
end

function SCCloudPurchaseInfo:Decode()

	self.can_buy_timestamp_list = {}
	for i = 1, 32 do
		self.can_buy_timestamp_list[i] = MsgAdapter.ReadInt()
	end

	self.item_list = {}
	for i = 1, 32 do
		self.item_list[i] = {}
		self.item_list[i].total_buy_times = MsgAdapter.ReadInt()
		self.item_list[i].give_reward_timestamp = MsgAdapter.ReadInt()
	end



end

---------- 兑换

SCCloudPurchaseConvertInfo = SCCloudPurchaseConvertInfo or BaseClass(BaseProtocolStruct)

function SCCloudPurchaseConvertInfo:__init()
	self.msg_type = 9041

	self.score = 0
	self.record_count = 0
	self.convert_record_list = {}
end

function SCCloudPurchaseConvertInfo:Decode()
	self.score = MsgAdapter.ReadInt()
	self.record_count = MsgAdapter.ReadInt()

	self.convert_record_list = {}
	for i = 1, self.record_count do
		self.convert_record_list[i] = {}
		self.convert_record_list[i].item_id = MsgAdapter.ReadUShort()
		self.convert_record_list[i].convert_count = MsgAdapter.ReadShort()
	end

end


---------- 一元夺宝个人购买记录


SCCloudPurchaseBuyRecordInfo = SCCloudPurchaseBuyRecordInfo or BaseClass(BaseProtocolStruct)

function SCCloudPurchaseBuyRecordInfo:__init()
	self.msg_type = 9042

	self.record_count = 0
	self.buy_record_list = {}
end

function SCCloudPurchaseBuyRecordInfo:Decode()

	self.record_count = MsgAdapter.ReadInt()

	self.buy_record_list = {}

	for i = 1, self.record_count do
		self.buy_record_list[i] = {}
		self.buy_record_list[i].item_id = MsgAdapter.ReadUShort()
		self.buy_record_list[i].buy_count = MsgAdapter.ReadShort()
		self.buy_record_list[i].buy_timestamp = MsgAdapter.ReadUInt()
	end

end

---------- 一元夺宝记录(全服记录（中奖信息）)

SCCloudPurchaseServerRecord = SCCloudPurchaseServerRecord or BaseClass(BaseProtocolStruct)

function SCCloudPurchaseServerRecord:__init()
	self.msg_type = 9043

	self.count = 0
	self.cloud_reward_record_list = {}
end

function SCCloudPurchaseServerRecord:Decode()

	self.count = MsgAdapter.ReadInt()

	self.cloud_reward_record_list = {}
	for i = 1, self.count do
		self.cloud_reward_record_list[i] = {}
		self.cloud_reward_record_list[i].reward_server_id = MsgAdapter.ReadInt()
		self.cloud_reward_record_list[i].user_name = MsgAdapter.ReadStrN(32)
		self.cloud_reward_record_list[i].reward_item_id = MsgAdapter.ReadUShort()
		self.cloud_reward_record_list[i].reserve_sh = MsgAdapter.ReadShort()
	end

end


-----
SCCloudPurchaseUserInfo = SCCloudPurchaseUserInfo or BaseClass(BaseProtocolStruct)

function SCCloudPurchaseUserInfo:__init()
	self.msg_type = 9044

	self.score = 0
	self.ticket_num = 0
end

function SCCloudPurchaseUserInfo:Decode()

	self.score = MsgAdapter.ReadInt()
	self.ticket_num = MsgAdapter.ReadInt()
end

-- 版本累计充值
SCRAVersionTotalChargeInfo = SCRAVersionTotalChargeInfo or BaseClass(BaseProtocolStruct)
function SCRAVersionTotalChargeInfo:__init()
	self.msg_type = 9082

	self.total_charge_value = 0
	self.reward_has_fetch_flag = 0
end

function SCRAVersionTotalChargeInfo:Decode()
	self.total_charge_value = MsgAdapter.ReadInt()  --累计充值数
	self.reward_has_fetch_flag = MsgAdapter.ReadInt()  --已领取过的奖励标记
end

-- 吉祥三宝
CSRATotalChargeFiveInfo  = CSRATotalChargeFiveInfo  or BaseClass(BaseProtocolStruct)
function CSRATotalChargeFiveInfo:__init()
	self.msg_type = 9084
end

function CSRATotalChargeFiveInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

SCRATotalChargeFiveInfo   = SCRATotalChargeFiveInfo   or BaseClass(BaseProtocolStruct)
function SCRATotalChargeFiveInfo:__init()
	self.msg_type = 9085

	self.cur_total_charge = 0
	self.cur_total_charge_has_fetch_flag = 0
end

function SCRATotalChargeFiveInfo:Decode()
	self.cur_total_charge = MsgAdapter.ReadInt()  --累计充值数
	self.cur_total_charge_has_fetch_flag = MsgAdapter.ReadInt()  --已领取过的奖励标记
end

---------------消费好礼---------------------------
SCRAExpenseNiceGiftInfo = SCRAExpenseNiceGiftInfo or BaseClass(BaseProtocolStruct)

function SCRAExpenseNiceGiftInfo:__init()
	self.msg_type = 9080

	self.grand_total_consume_gold_num = 0
	self.yao_jiang_num = 0
	self.reward_has_fetch_flag = 0
	self.reward_can_fetch_flag = 0
end

function SCRAExpenseNiceGiftInfo:Decode()
	self.grand_total_consume_gold_num = MsgAdapter.ReadLL()
	self.yao_jiang_num = MsgAdapter.ReadInt()
	self.reward_has_fetch_flag = MsgAdapter.ReadInt()
	self.reward_can_fetch_flag = MsgAdapter.ReadInt()
end


SCRAExpenseNiceGiftResultInfo = SCRAExpenseNiceGiftResultInfo or BaseClass(BaseProtocolStruct)

function SCRAExpenseNiceGiftResultInfo:__init()
	self.msg_type = 9081

	self.reward_item_id = 0
	self.reward_item_num = 0
end

function SCRAExpenseNiceGiftResultInfo:Decode()
	self.reward_item_id = MsgAdapter.ReadInt()
	self.reward_item_num = MsgAdapter.ReadInt()
end

SCRAExpenseNiceGift2ResultInfo = SCRAExpenseNiceGift2ResultInfo or BaseClass(BaseProtocolStruct)

function SCRAExpenseNiceGift2ResultInfo:__init()
	self.msg_type = 9089

	self.reward_item_id = 0
	self.reward_item_num = 0
end

function SCRAExpenseNiceGift2ResultInfo:Decode()
	TestPrint("接收")
	self.reward_item_id = MsgAdapter.ReadInt()
	self.reward_item_num = MsgAdapter.ReadInt()
end

SCRAExpenseNiceGift2Info = SCRAExpenseNiceGift2Info or BaseClass(BaseProtocolStruct)

function SCRAExpenseNiceGift2Info:__init()
	self.msg_type = 9088

	self.grand_total_consume_gold_num = 0
	self.yao_jiang_num = 0
	self.reward_has_fetch_flag = 0
	self.reward_can_fetch_flag = 0
	self.yaojiang_total_times = 0
end

function SCRAExpenseNiceGift2Info:Decode()
	self.grand_total_consume_gold_num = MsgAdapter.ReadLL()
	self.yao_jiang_num = MsgAdapter.ReadInt()
	self.reward_has_fetch_flag = MsgAdapter.ReadInt()
	self.reward_can_fetch_flag = MsgAdapter.ReadInt()
	self.yaojiang_total_times = MsgAdapter.ReadInt()
end