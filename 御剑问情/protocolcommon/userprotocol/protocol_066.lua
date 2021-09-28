--发送离婚回复
CSDivorceRet = CSDivorceRet or BaseClass(BaseProtocolStruct)
function CSDivorceRet:__init()
	self.msg_type = 6603

	self.req_uid = 0
	self.is_accept = 0
end

function CSDivorceRet:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.req_uid)
	MsgAdapter.WriteInt(self.is_accept)
end

--结婚成功回调
SCMarryResult = SCMarryResult or BaseClass(BaseProtocolStruct)
function SCMarryResult:__init()
	self.msg_type = 6604

	self.lover_uid = 0
	self.lover_name = ""
end

function SCMarryResult:Decode()
	self.lover_uid = MsgAdapter.ReadInt()
	self.lover_name = MsgAdapter.ReadStrN(32)
end

--福利欢乐果树-领取奖励
CSWelfareFetchHappyTreeReward = CSWelfareFetchHappyTreeReward or BaseClass(BaseProtocolStruct)
function CSWelfareFetchHappyTreeReward:__init()
	self.msg_type = 6605

	self.type = 0
end

function CSWelfareFetchHappyTreeReward:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.type)
end

--王陵探险
ScWangLingExploreUserInfo = ScWangLingExploreUserInfo or BaseClass(BaseProtocolStruct)
function ScWangLingExploreUserInfo:__init()
	self.msg_type = 6606

end

function ScWangLingExploreUserInfo:Decode()
	self.boss_reflush_time = MsgAdapter.ReadInt()
	self.limit_task_time = MsgAdapter.ReadInt()
	self.boss_num = MsgAdapter.ReadInt()
	self.boss_owner_uid = MsgAdapter.ReadInt()
	self.task_list = {}
	for i=1,5 do
		table.insert(self.task_list, self:ReadTaskInfo())
	end
	self.item_list = {}
	for i=1,10 do
		table.insert(self.item_list, self:ReadItemInfo())
	end
end

function ScWangLingExploreUserInfo:ReadTaskInfo()
	local t = {}
	t.task_id = MsgAdapter.ReadShort()
	t.is_finish = MsgAdapter.ReadShort()
	t.param_count = MsgAdapter.ReadInt()
	t.cur_param_value = MsgAdapter.ReadInt()
	t.is_double_reward = MsgAdapter.ReadInt()
	print(ToColorStr(t.is_double_reward, TEXT_COLOR.RED))
	return t
end

function ScWangLingExploreUserInfo:ReadItemInfo()
	local t = {}
	t.item_id = MsgAdapter.ReadInt()
	t.num = MsgAdapter.ReadInt()
	return t
end

--水晶活动
SCShuijingTaskInfo = SCShuijingTaskInfo or BaseClass(BaseProtocolStruct)
function SCShuijingTaskInfo:__init()
	self.msg_type = 6613
end

function SCShuijingTaskInfo:Decode()
	self.gather_shuijing_total_num = MsgAdapter.ReadInt()
	self.gather_big_shuijing_total_num = MsgAdapter.ReadInt()
	self.gather_diamond_big_shuijing_num = MsgAdapter.ReadInt()
	self.gather_best_shuijing_count = MsgAdapter.ReadInt()
	self.fetch_task_reward_flag = MsgAdapter.ReadInt()
end

CSShuijingFetchTaskReward = CSShuijingFetchTaskReward or BaseClass(BaseProtocolStruct)
function CSShuijingFetchTaskReward:__init()
	self.msg_type = 6632
	self.task_id = 0
end

function CSShuijingFetchTaskReward:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.task_id)
end

--广播采集不中断buff信息
SCNoticeGatherBuffInfo = SCNoticeGatherBuffInfo or BaseClass(BaseProtocolStruct)
function SCNoticeGatherBuffInfo:__init()
	self.msg_type = 6633
end

function SCNoticeGatherBuffInfo:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.is_gather_wudi = MsgAdapter.ReadShort() --1有buff，0 没有buff
end

--跨服组队本操作
CSCrossTeamFBOption = CSCrossTeamFBOption or BaseClass(BaseProtocolStruct)
function CSCrossTeamFBOption:__init()
	self.msg_type = 6607

	self.option_type = 0
	self.layer = 0
	self.room = 0
	self.param = 0
	self.param2 = 0
	self.param3 = 0
end

function CSCrossTeamFBOption:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.option_type)
	MsgAdapter.WriteInt(self.layer)
	MsgAdapter.WriteInt(self.room)
	MsgAdapter.WriteInt(self.param)
	MsgAdapter.WriteInt(self.param2)
	MsgAdapter.WriteInt(self.param3)
end

--开服活动
SCRAOpenServerInfo = SCRAOpenServerInfo or BaseClass(BaseProtocolStruct)
function SCRAOpenServerInfo:__init()
	self.msg_type = 6608
end

function SCRAOpenServerInfo:Decode()
	self.rand_activity_type = MsgAdapter.ReadInt()
	self.reward_flag = MsgAdapter.ReadInt()
	self.complete_flag = MsgAdapter.ReadInt()
	self.today_chongzhi_role_count = MsgAdapter.ReadInt()			-- 首充团购用
end

--开服全服进阶人数
SCRAOpenServerUpgradeInfo = SCRAOpenServerUpgradeInfo or BaseClass(BaseProtocolStruct)
function SCRAOpenServerUpgradeInfo:__init()
	self.msg_type = 6609
end

function SCRAOpenServerUpgradeInfo:Decode()
	self.rand_activity_type = MsgAdapter.ReadInt()
	self.total_upgrade_record_list = {}
	for i = -1, 8 do
		self.total_upgrade_record_list[i] = {count = MsgAdapter.ReadInt()}
	end
end

--开服进阶排行榜
SCRAOpenServerRankInfo = SCRAOpenServerRankInfo or BaseClass(BaseProtocolStruct)
function SCRAOpenServerRankInfo:__init()
	self.msg_type = 6610
end

function SCRAOpenServerRankInfo:Decode()
	self.rand_activity_type = MsgAdapter.ReadInt()
	self.myself_rank = MsgAdapter.ReadInt()
	self.top1_uid = MsgAdapter.ReadInt()
	self.role_name = MsgAdapter.ReadStrN(32)
	self.role_sex = MsgAdapter.ReadChar()
	self.role_prof = MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
	self.capability = MsgAdapter.ReadInt()
	self.avatar_key_big = MsgAdapter.ReadInt()					-- 大头像
	self.avatar_key_small = MsgAdapter.ReadInt()				-- 小头像
end

--开服进阶排行榜
SCBaiBeiFanLiInfo = SCBaiBeiFanLiInfo or BaseClass(BaseProtocolStruct)
function SCBaiBeiFanLiInfo:__init()
	self.msg_type = 6611
	self.is_buy = 0
end

function SCBaiBeiFanLiInfo:Decode()
	self.is_buy = MsgAdapter.ReadInt()
end

--百倍返利购买
CSBaiBeiFanLiBuy = CSBaiBeiFanLiBuy or BaseClass(BaseProtocolStruct)
function CSBaiBeiFanLiBuy:__init()
	self.msg_type = 6612
end

function CSBaiBeiFanLiBuy:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 跨服组队本个人信息
SCCrossTeamFBSelfInfo = SCCrossTeamFBSelfInfo or BaseClass(BaseProtocolStruct)
function SCCrossTeamFBSelfInfo:__init()
	self.msg_type = 6614
	self.cross_team_fb_pass_flag = 0
	self.cross_team_fb_day_count = 0
end

function SCCrossTeamFBSelfInfo:Decode()
	self.cross_team_fb_pass_flag = MsgAdapter.ReadInt()
	self.cross_team_fb_day_count = MsgAdapter.ReadInt()
end

-- 返回对方是否同意结婚请求
SCIsAcceptMarry = SCIsAcceptMarry or BaseClass(BaseProtocolStruct)
function SCIsAcceptMarry:__init()
	self.msg_type = 6616
end

function SCIsAcceptMarry:Decode()
	self.accept_flag = MsgAdapter.ReadInt()
end

-- 跨服水晶，玩家信息通知
SCCrossShuijingPlayerInfo = SCCrossShuijingPlayerInfo or BaseClass(BaseProtocolStruct)
function SCCrossShuijingPlayerInfo:__init()
	self.msg_type = 6617
end

function SCCrossShuijingPlayerInfo:Decode()
	self.total_bind_gold = MsgAdapter.ReadInt()
	self.total_mojing = MsgAdapter.ReadInt()
	self.total_cross_honor = MsgAdapter.ReadInt()
	self.total_relive_times = MsgAdapter.ReadInt()
	self.cur_limit_gather_times = MsgAdapter.ReadInt()
	self.gather_buff_time = MsgAdapter.ReadUInt()
	self.big_shui_jing_num = MsgAdapter.ReadInt()
end

-- 跨服水晶幻境，购买buff
CSCrossShuijingBuyBuff = CSCrossShuijingBuyBuff or BaseClass(BaseProtocolStruct)
function CSCrossShuijingBuyBuff:__init()
	self.msg_type = 6618
end

function CSCrossShuijingBuyBuff:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 开服活动boss猎手
SCRAOpenServerBossInfo = SCRAOpenServerBossInfo or BaseClass(BaseProtocolStruct)
function SCRAOpenServerBossInfo:__init()
	self.msg_type = 6619
end

function SCRAOpenServerBossInfo:Decode()
	self.oga_kill_boss_reward_flag = MsgAdapter.ReadInt()
	-- self.oga_kill_boss_flag = MsgAdapter.ReadLL()
	self.oga_kill_boss_flag_low= MsgAdapter.ReadInt()
	self.oga_kill_boss_flag_hight = MsgAdapter.ReadInt()
end

-- 开服活动战场争霸
SCRAOpenServerBattleInfo = SCRAOpenServerBattleInfo or BaseClass(BaseProtocolStruct)
function SCRAOpenServerBattleInfo:__init()
	self.msg_type = 6620
end

function SCRAOpenServerBattleInfo:Decode()
	self.yuansu_uid = MsgAdapter.ReadInt()				-- 元素战场
	self.guildbatte_uid= MsgAdapter.ReadInt()			-- 公会争霸
	self.gongchengzhan_uid = MsgAdapter.ReadInt()		-- 攻城战
	self.territorywar_uid = MsgAdapter.ReadInt()		-- 领土战
end

-- 领取冲级豪礼奖励
CSWelfareFetchChongjihaoliReward = CSWelfareFetchChongjihaoliReward or BaseClass(BaseProtocolStruct)
function CSWelfareFetchChongjihaoliReward:__init()
	self.msg_type = 6623
	self.level = 0
end

function CSWelfareFetchChongjihaoliReward:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.level)
end

--  魔龙秘宝请求
CSFetchMagicalPreciousRewardReq = CSFetchMagicalPreciousRewardReq or BaseClass(BaseProtocolStruct)
function CSFetchMagicalPreciousRewardReq:__init()
	self.msg_type = 6624
	self.operater_type = 0
	self.reward_index = 0
	self.param2 = 0
end

function CSFetchMagicalPreciousRewardReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.operater_type)
	MsgAdapter.WriteInt(self.reward_index)
	MsgAdapter.WriteInt(self.param2)
end

--  魔龙秘宝返回
SCSendMagicalPreciousInfo = SCSendMagicalPreciousInfo or BaseClass(BaseProtocolStruct)
function SCSendMagicalPreciousInfo:__init()
	self.msg_type = 6625
	self.current_chaper = 0							-- 当前章节
	self.chapter_invalid_time = 0					-- 章节失效时间
	self.chapter_fetch_finish_reward_flag = 0		-- 章节完成奖励标志
	self.chapter_fetch_reward_flag = {}				-- 章节奖励标志
	self.chapter_param = {}
end

function SCSendMagicalPreciousInfo:Decode()
	self.current_chaper = MsgAdapter.ReadInt()
	self.chapter_invalid_time = MsgAdapter.ReadUInt()
	self.chapter_fetch_finish_reward_flag = MsgAdapter.ReadUInt()
	for i= 0, COMMON_CONSTS.MAGICAL_PRECIOUS_CHAPTER_COUNT - 1 do
		self.chapter_fetch_reward_flag[i] = {}
		for j = 1, COMMON_CONSTS.MAGICAL_PRECIOUS_CHAPTER_FLAG_COUNT do
			self.chapter_fetch_reward_flag[i][j] = MsgAdapter.ReadUInt()
		end
	end
	self.chapter_param = {}
	local chapter_index_count = MsgAdapter.ReadInt()
	for i= 0, chapter_index_count - 1 do
		local chapter_id = MsgAdapter.ReadInt()
		local chapter_index = MsgAdapter.ReadInt()
		self.chapter_param[chapter_id] = self.chapter_param[chapter_id] or {}
		self.chapter_param[chapter_id][chapter_index] = MsgAdapter.ReadInt()
	end
end

--  礼包限购信息
SCRAOpenGameGiftShopBuyInfo = SCRAOpenGameGiftShopBuyInfo or BaseClass(BaseProtocolStruct)
function SCRAOpenGameGiftShopBuyInfo:__init()
	self.msg_type = 6626
end

function SCRAOpenGameGiftShopBuyInfo:Decode()
	self.oga_gift_shop_flag = MsgAdapter.ReadInt()
end

--  购买限购礼包
CSRAOpenGameGiftShopBuy = CSRAOpenGameGiftShopBuy or BaseClass(BaseProtocolStruct)
function CSRAOpenGameGiftShopBuy:__init()
	self.msg_type = 6627
	self.seq = 0
end

function CSRAOpenGameGiftShopBuy:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.seq)
end

--  获取限购礼包信息
CSRAOpenGameGiftShopBuyInfoReq = CSRAOpenGameGiftShopBuyInfoReq or BaseClass(BaseProtocolStruct)
function CSRAOpenGameGiftShopBuyInfoReq:__init()
	self.msg_type = 6628
end

function CSRAOpenGameGiftShopBuyInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--  经验炼制请求
CSRAExpRefineReq = CSRAExpRefineReq or BaseClass(BaseProtocolStruct)
function CSRAExpRefineReq:__init()
	self.msg_type = 6629
	self.opera_type = 0
end

function CSRAExpRefineReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.opera_type)							-- 请求类型
end

--  魔龙秘宝返回
SCSendMagicalPreciousCurChapterInfo = SCSendMagicalPreciousCurChapterInfo or BaseClass(BaseProtocolStruct)
function SCSendMagicalPreciousCurChapterInfo:__init()
	self.msg_type = 6634
	self.change_chaper = 0							-- 改变章节
	self.chapter_fetch_reward_flag = {}				-- 章节奖励标志
end

function SCSendMagicalPreciousCurChapterInfo:Decode()
	self.change_chaper = MsgAdapter.ReadInt()
	self.chapter_fetch_reward_flag = {}
	self.chapter_fetch_reward_flag[self.change_chaper] = {}
	for j = 1, COMMON_CONSTS.MAGICAL_PRECIOUS_CHAPTER_FLAG_COUNT do
		self.chapter_fetch_reward_flag[self.change_chaper][j] = MsgAdapter.ReadUInt()
	end
end

--  魔龙秘宝进度变化返回
SCMagicalPreciousConditionParamChange = SCMagicalPreciousConditionParamChange or BaseClass(BaseProtocolStruct)
function SCMagicalPreciousConditionParamChange:__init()
	self.msg_type = 6635
	self.param_list = {}
end

function SCMagicalPreciousConditionParamChange:Decode()
	local param_list_len = MsgAdapter.ReadInt()
	self.param_list = {}
	for i=1, param_list_len do
		self.param_list[i] = {}
		self.param_list[i].charper = MsgAdapter.ReadInt()
		self.param_list[i].charper_index = MsgAdapter.ReadInt()
		self.param_list[i].param = MsgAdapter.ReadInt()
	end
end

-- 经验炼制信息
SCRAExpRefineInfo = SCRAExpRefineInfo or BaseClass(BaseProtocolStruct)
function SCRAExpRefineInfo:__init()
	self.msg_type = 6630
end

function SCRAExpRefineInfo:Decode()
	self.refine_today_buy_time = MsgAdapter.ReadShort()				-- 每日炼制次数
	MsgAdapter.ReadShort()
	self.refine_reward_gold = MsgAdapter.ReadInt()					-- 总奖励金额
end


-------------------相思树--------------------------------------
--请求浇水
CSLoveTreeWaterReq = CSLoveTreeWaterReq or BaseClass(BaseProtocolStruct)
function CSLoveTreeWaterReq:__init()
	self.msg_type = 6650
	self.is_auto_buy = 0
	self.is_water_other = 0			--自己0, 别人1
	self.repeat_times = 0			--一次性升级次数
end

function CSLoveTreeWaterReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteChar(self.is_auto_buy)
	MsgAdapter.WriteChar(self.is_water_other)
	MsgAdapter.WriteShort(self.repeat_times)
end

--请求相思树信息
CSLoveTreeInfoReq = CSLoveTreeInfoReq or BaseClass(BaseProtocolStruct)
function CSLoveTreeInfoReq:__init()
	self.msg_type = 6651
	self.is_self = 0			--自己1, 别人0
end

function CSLoveTreeInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteChar(self.is_self)
	MsgAdapter.WriteChar(0)
	MsgAdapter.WriteShort(0)
end

-- 返回水晶信息
SCShuijingPlayerInfo = SCShuijingPlayerInfo or BaseClass(BaseProtocolStruct)
function SCShuijingPlayerInfo:__init()
	self.msg_type = 6621
	self.total_bind_gold = 0												-- 总共-绑定元宝
	self.total_mojing = 0													-- 总共-魔晶
	self.total_shengwang = 0												-- 总共-跨服荣誉
	self.free_relive_times = 0												-- 已免费复活次数
	self.cur_gather_times = 0												-- 当前采集次数
	self.gather_buff_time = 0										-- 采集不被打断buff时间
	self.big_shuijing_num = 0												-- 至尊水晶数量
end

function SCShuijingPlayerInfo:Decode()
	self.total_bind_gold = MsgAdapter.ReadInt()
	self.total_mojing = MsgAdapter.ReadInt()
	self.total_shengwang = MsgAdapter.ReadInt()
	self.free_relive_times = MsgAdapter.ReadInt()
	self.cur_gather_times = MsgAdapter.ReadInt()
	self.gather_buff_time = MsgAdapter.ReadUInt()
	self.big_shuijing_num = MsgAdapter.ReadInt()
end

--水晶幻境，购买buff
CSShuijingBuyBuff = CSShuijingBuyBuff or BaseClass(BaseProtocolStruct)
function CSShuijingBuyBuff:__init()
	self.msg_type = 6622
end

function CSShuijingBuyBuff:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end


-- 返回相思树信息
SCLoveTreeInfo = SCLoveTreeInfo or BaseClass(BaseProtocolStruct)
function SCLoveTreeInfo:__init()
	self.msg_type = 6675
end

function SCLoveTreeInfo:Decode()
	self.is_self = MsgAdapter.ReadChar()			--自己1, 别人0
	MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
	self.love_tree_info = {}
	self.love_tree_info.love_tree_star_level = MsgAdapter.ReadInt()
	self.love_tree_info.love_tree_cur_exp = MsgAdapter.ReadInt()
	self.love_tree_info.free_water_self = MsgAdapter.ReadInt()
	self.love_tree_info.free_water_other = MsgAdapter.ReadInt()
	self.love_tree_info.tree_name = MsgAdapter.ReadStrN(32)
	self.love_tree_info.other_love_tree_star_level = MsgAdapter.ReadInt()
end

-------------------限时VIP-------------------------
CSFetchTimeLimitVip = CSFetchTimeLimitVip or BaseClass(BaseProtocolStruct)
function CSFetchTimeLimitVip:__init()
	self.msg_type = 6631
end

function CSFetchTimeLimitVip:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--随机活动疯狂摇钱树
SCRAShakeMoneyInfo = SCRAShakeMoneyInfo or BaseClass(BaseProtocolStruct)
function SCRAShakeMoneyInfo:__init()
	self.msg_type = 6638
	self.total_chongzhi_gold = 0
	self.chongzhi_gold = 0
end

function SCRAShakeMoneyInfo:Decode()
	self.total_chongzhi_gold = MsgAdapter.ReadInt()
	self.chongzhi_gold = MsgAdapter.ReadInt()
end

SCCrossShuijingGatherInfo = SCCrossShuijingGatherInfo or BaseClass(BaseProtocolStruct)
function SCCrossShuijingGatherInfo:__init()
	self.msg_type = 6637
end

function SCCrossShuijingGatherInfo:Decode()
	self.big_shuijing_num =  MsgAdapter.ReadInt()
	self.next_big_shuijing_refresh_timestamp = MsgAdapter.ReadUInt()
	self.shuijing_count = MsgAdapter.ReadInt()
	self.gather_item_list = {}
	for i = 1, COMMON_CONSTS.SHUIJING_LIST_MAX_NUM do
		if i <= self.shuijing_count then
			local item = {}
			item.gather_id = MsgAdapter.ReadInt()
			item.pos_x = MsgAdapter.ReadInt()
			item.pos_y = MsgAdapter.ReadInt()
			table.insert(self.gather_item_list, item)
		else
			MsgAdapter.ReadInt()
			MsgAdapter.ReadInt()
			MsgAdapter.ReadInt()
		end
	end
end
