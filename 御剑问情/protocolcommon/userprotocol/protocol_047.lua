local function DecodeMountEquipInfo()
	local t = {}
	t.equip_id = MsgAdapter.ReadUShort()
	t.level = MsgAdapter.ReadShort()
	t.exp = MsgAdapter.ReadInt()
	t.attr_list = {}
	for i = 0, GameEnum.MOUNT_EQUIP_ATTR_COUNT - 1 do
		t.attr_list[i] = MsgAdapter.ReadInt()
	end
	return t
end

--坐骑信息
SCMountInfo =  SCMountInfo or BaseClass(BaseProtocolStruct)
function SCMountInfo:__init()
	self.msg_type = 4700
end

--单个坐骑信息返回
function SCMountInfo:Decode()
	self.mount_flag = MsgAdapter.ReadShort()
	self.reserved = MsgAdapter.ReadShort()
	self.mount_level = MsgAdapter.ReadShort()
	self.grade = MsgAdapter.ReadShort()
	self.star_level = MsgAdapter.ReadShort()
	self.used_imageid = MsgAdapter.ReadShort()
	self.shuxingdan_count = MsgAdapter.ReadShort()
	self.chengzhangdan_count = MsgAdapter.ReadShort()
	self.grade_bless_val = MsgAdapter.ReadInt()		-- 祝福值
	self.active_image_flag = MsgAdapter.ReadInt()
	self.active_special_image_flag = MsgAdapter.ReadUInt()
	self.active_special_image_flag2 = MsgAdapter.ReadUInt()
	self.clear_upgrade_time = MsgAdapter.ReadUInt()
	self.temp_img_id = MsgAdapter.ReadShort()
	self.temp_img_id_has_select = MsgAdapter.ReadShort()
	self.temp_img_time = MsgAdapter.ReadUInt()
	self.equip_skill_level = MsgAdapter.ReadInt()

	-- self.equip_info_list = {}
	-- for i = 0, GameEnum.MOUNT_EQUIP_COUNT - 1 do
	-- 	self.equip_info_list[i] = DecodeMountEquipInfo()
	-- end
	self.equip_level_list = {}
	for i = 0, GameEnum.MOUNT_EQUIP_COUNT - 1 do
		self.equip_level_list[i] = MsgAdapter.ReadShort()
	end

	self.skill_level_list = {}
	for i = 0, GameEnum.MOUNT_SKILL_COUNT - 1 do
		self.skill_level_list[i] = MsgAdapter.ReadShort()
	end
	self.special_img_grade_list = {}
	for i = 0, GameEnum.MAX_MOUNT_SPECIAL_IMAGE_ID - 1  do
		self.special_img_grade_list[i] = MsgAdapter.ReadChar()
	end
end

--坐骑外观改变
SCMountAppeChange = SCMountAppeChange or BaseClass(BaseProtocolStruct)
function SCMountAppeChange:__init()
	self.msg_type = 4701
end

function SCMountAppeChange:Decode()
	self.objid = MsgAdapter.ReadUShort()
	self.mount_appeid = MsgAdapter.ReadUShort()
end

--同步月卡信息
SCMonthCardInfo =  SCMonthCardInfo or BaseClass(BaseProtocolStruct)
function SCMonthCardInfo:__init()
	self.msg_type = 4707
end

function SCMonthCardInfo:Decode()
	self.active_timestamp = MsgAdapter.ReadUInt()
	self.last_days = MsgAdapter.ReadInt()
	self.next_reward_day_idx = MsgAdapter.ReadInt()
	self.buy_times = MsgAdapter.ReadInt()
end

-- 摇钱信息
SCRollMoneyInfo = SCRollMoneyInfo or BaseClass(BaseProtocolStruct)
function SCRollMoneyInfo:__init()
	self.msg_type = 4709

	self.fetch_gold_reward_times = 0
	self.fetch_coin_reward_times = 0

	self.already_roll_gold_num = 0
	self.reserve_ch = 0
	self.reserve_sh = 0

	self.gold_roll_times = 0
	self.gold_roll_num_list = {}

	self.coin_roll_times = 0
	self.coin_roll_num_list = {}
end

function SCRollMoneyInfo:Decode()
	self.fetch_gold_reward_times = MsgAdapter.ReadShort()
	self.fetch_coin_reward_times = MsgAdapter.ReadShort()

	self.already_roll_gold_num = MsgAdapter.ReadChar()
	self.reserve_ch = MsgAdapter.ReadChar()
	self.reserve_sh = MsgAdapter.ReadShort()

	self.gold_roll_times = MsgAdapter.ReadChar()
	self.gold_roll_num_list = {}
	for i = 1, 3 do
		local gold_roll_num = MsgAdapter.ReadChar()
		table.insert(self.gold_roll_num_list, gold_roll_num)
	end

	self.coin_roll_times = MsgAdapter.ReadChar()
	self.coin_roll_num_list = {}
	for i = 1, 7 do
		local gold_roll_num = MsgAdapter.ReadChar()
		table.insert(self.coin_roll_num_list, gold_roll_num)
	end
end

--私聊模拟
SCFakePrivateChat = SCFakePrivateChat or BaseClass(BaseProtocolStruct)
function SCFakePrivateChat:__init()
	self.msg_type = 4714
end

function SCFakePrivateChat:Decode()
	self.from_uid = MsgAdapter.ReadInt()
	self.username = MsgAdapter.ReadStrN(32)
	self.sex = MsgAdapter.ReadChar()
	self.camp = MsgAdapter.ReadChar()
	self.vip_level = MsgAdapter.ReadChar()
	self.prof = MsgAdapter.ReadChar()
	self.level = MsgAdapter.ReadShort()
	self.reserve_ch = MsgAdapter.ReadShort()
	self.avatar_key_big = MsgAdapter.ReadUInt()
	self.avatar_key_small = MsgAdapter.ReadUInt()
end

--征婚信息
SCMarriageSeekingInfo = SCMarriageSeekingInfo or BaseClass(BaseProtocolStruct)
function SCMarriageSeekingInfo:__init()
	self.msg_type = 4715

	self.marriage_seeking_list = {}
end

function SCMarriageSeekingInfo:Decode()
	self.marriage_seeking_list = {}
	local count = MsgAdapter.ReadInt()
	for i = 1, count do
		local data = {}
		data.gamename = MsgAdapter.ReadStrN(32)
		data.user_id = MsgAdapter.ReadInt()
		data.camp = MsgAdapter.ReadChar()
		data.sex = MsgAdapter.ReadChar()
		data.prof = MsgAdapter.ReadChar()
		data.is_online = MsgAdapter.ReadChar()
		data.level = MsgAdapter.ReadShort()
		data.reserve_sh = MsgAdapter.ReadShort()
		data.time_stamp = MsgAdapter.ReadUInt()
		data.marriage_seeking_notice = MsgAdapter.ReadStrN(128)
		table.insert(self.marriage_seeking_list, data)
	end
	SortTools.SortAsc(self.marriage_seeking_list, "time_stamp")
end

-- 摇元宝请求
CSRollMoneyOperaReq = CSRollMoneyOperaReq or BaseClass(BaseProtocolStruct)
function CSRollMoneyOperaReq:__init()
	self.msg_type = 4762
	self.opera_type = 0
	self.reserve_sh = 0
end

function CSRollMoneyOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(self.reserve_sh)
end

--寻找姻缘
CSMarriageSeekingInfo = CSMarriageSeekingInfo or BaseClass(BaseProtocolStruct)
function CSMarriageSeekingInfo:__init()
	self.msg_type = 4768

	self.type = 0
	self.marriage_seeking_notice = ""
end

function CSMarriageSeekingInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.type)
	MsgAdapter.WriteShort(0)
	MsgAdapter.WriteStrN(self.marriage_seeking_notice, 128)
end


--请求上/下坐骑
--0 下坐骑  1 上坐骑
CSGoonMount = CSGoonMount or BaseClass(BaseProtocolStruct)
function CSGoonMount:__init()
	self.msg_type = 4750
	self.mount_flag = 0
end

function CSGoonMount:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.mount_flag)
end

--坐骑进阶
CSUpgradeMount = CSUpgradeMount or BaseClass(BaseProtocolStruct)
function CSUpgradeMount:__init()
	self.msg_type = 4751
	self.repeat_times = 0
	self.auto_buy = 0
end

function CSUpgradeMount:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.repeat_times)
	MsgAdapter.WriteShort(self.auto_buy)
end

--形象使用
CSUseMountImage = CSUseMountImage or BaseClass(BaseProtocolStruct)
function CSUseMountImage:__init()
	self.msg_type = 4752
	self.is_temp_image = 0
	self.image_id = 0
end

function CSUseMountImage:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.is_temp_image)
	MsgAdapter.WriteShort(self.image_id)
end

--坐骑特殊形象进阶
CSMountSpecialImgUpgrade = CSMountSpecialImgUpgrade or BaseClass(BaseProtocolStruct)
function CSMountSpecialImgUpgrade:__init()
	self.msg_type = 4753
	self.special_image_id = 0
	self.reserve_sh = 0
end

function CSMountSpecialImgUpgrade:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.special_image_id)
	MsgAdapter.WriteShort(self.reserve_sh)
end

--坐骑升级装备请求
CSMountUplevelEquip = CSMountUplevelEquip or BaseClass(BaseProtocolStruct)
function CSMountUplevelEquip:__init()
	self.msg_type = 4754
	self.equip_index = 0
end

function CSMountUplevelEquip:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteChar(self.equip_index)
	MsgAdapter.WriteShort(0)
end

--坐骑技能升级请求
CSMountSkillUplevelReq = CSMountSkillUplevelReq or BaseClass(BaseProtocolStruct)
function CSMountSkillUplevelReq:__init()
	self.msg_type = 4755
	self.skill_idx = 0
	self.auto_buy = 0
end

function CSMountSkillUplevelReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.skill_idx)
	MsgAdapter.WriteShort(self.auto_buy)
end

-- 请求坐骑信息协议
CSMountGetInfo = CSMountGetInfo or BaseClass(BaseProtocolStruct)
function CSMountGetInfo:__init()
	self.msg_type = 4756
end

function CSMountGetInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 坐骑升星请求
CSMountUpStarLevel = CSMountUpStarLevel or BaseClass(BaseProtocolStruct)
function CSMountUpStarLevel:__init()
	self.msg_type = 4758
	self.stuff_index = 0
	self.is_auto_buy = 0
	self.loop_times = 0
end

function CSMountUpStarLevel:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.stuff_index)
	MsgAdapter.WriteShort(self.is_auto_buy)
	MsgAdapter.WriteInt(self.loop_times)
end


------------------------------- 羽翼 ------------------------------------
--羽翼信息
SCWingInfo =  SCWingInfo or BaseClass(BaseProtocolStruct)
function SCWingInfo:__init()
	self.msg_type = 4703
end

--羽翼信息返回
function SCWingInfo:Decode()
	self.wing_level = MsgAdapter.ReadShort()
	self.grade = MsgAdapter.ReadShort()
	self.star_level = MsgAdapter.ReadShort()
	self.used_imageid = MsgAdapter.ReadShort()
	self.shuxingdan_count = MsgAdapter.ReadShort()
	self.chengzhangdan_count = MsgAdapter.ReadShort()
	self.grade_bless_val = MsgAdapter.ReadInt()
	self.active_image_flag = MsgAdapter.ReadInt()
	self.active_special_image_flag = MsgAdapter.ReadUInt()
	self.active_special_image_flag2 = MsgAdapter.ReadUInt()
	self.clear_upgrade_time = MsgAdapter.ReadUInt()

	self.temp_img_id = MsgAdapter.ReadShort()
	self.temp_img_id_has_select = MsgAdapter.ReadShort()
	self.temp_img_time = MsgAdapter.ReadUInt()

	self.equip_skill_level = MsgAdapter.ReadInt()

	-- self.equip_info_list = {}
	-- for i = 0, GameEnum.MOUNT_EQUIP_COUNT - 1 do
	-- 	self.equip_info_list[i] = DecodeMountEquipInfo()
	-- end

	self.equip_level_list = {}
	for i = 0, GameEnum.MOUNT_EQUIP_COUNT - 1 do
		self.equip_level_list[i] = MsgAdapter.ReadShort()
	end

	self.skill_level_list = {}
	for i = 0,GameEnum.MOUNT_SKILL_COUNT - 1 do
		self.skill_level_list[i] = MsgAdapter.ReadShort()
	end

	self.special_img_grade_list = {}
	for i = 0, GameEnum.MAX_MOUNT_SPECIAL_IMAGE_ID - 1 do
		self.special_img_grade_list[i] = MsgAdapter.ReadChar()
	end
end

-- 羽翼外观改变
SCWingAppeChange =  SCWingAppeChange or BaseClass(BaseProtocolStruct)
function SCWingAppeChange:__init()
	self.msg_type = 4705
end

function SCWingAppeChange:Decode()
	self.objid = MsgAdapter.ReadUShort()
	self.wing_appeid = MsgAdapter.ReadUShort()
end

-- 请求羽翼进阶
CSUpgradeWing = CSUpgradeWing or BaseClass(BaseProtocolStruct)
function CSUpgradeWing:__init()
	self.msg_type = 4757
	self.repeat_times = 0
	self.is_auto_buy = 0
end

function CSUpgradeWing:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.repeat_times)
	MsgAdapter.WriteShort(self.is_auto_buy)
end

--请求使用羽翼形象
CSUseWingImage = CSUseWingImage or BaseClass(BaseProtocolStruct)
function CSUseWingImage:__init()
	self.msg_type = 4774
	self.is_temp_image = 0
	self.image_id = 0
end

function CSUseWingImage:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.is_temp_image)
	MsgAdapter.WriteShort(self.image_id)
end

-- 请求羽翼信息
CSWingGetInfo = CSWingGetInfo or BaseClass(BaseProtocolStruct)
function CSWingGetInfo:__init()
	self.msg_type = 4775
	self.server_id = 0
end

function CSWingGetInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.server_id)
end

-- 请求羽翼升星
CSWingUpStarLevel = CSWingUpStarLevel or BaseClass(BaseProtocolStruct)
function CSWingUpStarLevel:__init()
	self.msg_type = 4776
	self.stuff_index = 0
	self.is_auto_buy = 0
	self.loop_times = 0
end

function CSWingUpStarLevel:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.stuff_index)
	MsgAdapter.WriteShort(self.is_auto_buy)
	MsgAdapter.WriteInt(self.loop_times)
end

-- 羽翼升级装备请求
CSWingUplevelEquip = CSWingUplevelEquip  or BaseClass(BaseProtocolStruct)
function CSWingUplevelEquip:__init()
	self.msg_type = 4786
	self.equip_index = 0
end

function CSWingUplevelEquip:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteChar(self.equip_index)
	MsgAdapter.WriteShort(0)
end

--羽翼技能升级
CSWingSkillUplevelReq = CSWingSkillUplevelReq or BaseClass(BaseProtocolStruct)
function CSWingSkillUplevelReq:__init()
	self.msg_type = 4787
	self.skill_idx = 0
	self.is_auto_buy = 0
end

function CSWingSkillUplevelReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.skill_idx)
	MsgAdapter.WriteShort(self.is_auto_buy)
end

-- 羽翼特殊形象进阶
CSWingSpecialImgUpgrade = CSWingSpecialImgUpgrade or BaseClass(BaseProtocolStruct)
function CSWingSpecialImgUpgrade:__init()
	self.msg_type = 4789
	self.special_image_id = 0
	self.reserve_sh = 0
end

function CSWingSpecialImgUpgrade:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.special_image_id)
	MsgAdapter.WriteShort(self.reserve_sh)
end


---------------------------------------

SCCloakInfo =  SCCloakInfo or BaseClass(BaseProtocolStruct)
function SCCloakInfo:__init()
	self.msg_type = 6525
end

--披风信息返回
function SCCloakInfo:Decode()
	self.cloak_level = MsgAdapter.ReadInt()
	self.cur_exp = MsgAdapter.ReadInt()
	self.used_imageid = MsgAdapter.ReadInt()
	self.shuxingdan_count = MsgAdapter.ReadInt()
	self.active_image_flag = MsgAdapter.ReadInt()
	self.active_special_image_flag = MsgAdapter.ReadInt()
	self.equip_skill_level = MsgAdapter.ReadInt()

	self.equip_level_list = {}
	for i = 0, GameEnum.MOUNT_EQUIP_COUNT - 1 do
		self.equip_level_list[i] = MsgAdapter.ReadShort()
	end

	self.skill_level_list = {}
	for i = 0, GameEnum.MOUNT_SKILL_COUNT - 1 do
		self.skill_level_list[i] = MsgAdapter.ReadShort()
	end

	self.special_img_grade_list = {}
	for i = 0, GameEnum.MAX_SPRITE_SPECIAL_IMAGE_ID - 1 do
		self.special_img_grade_list[i] = MsgAdapter.ReadChar()
	end
end

CSCloakOperate = CSCloakOperate or BaseClass(BaseProtocolStruct)
function CSCloakOperate:__init()
	self.msg_type = 6526
end

function CSCloakOperate:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.operate_type)
	MsgAdapter.WriteShort(self.param_1)
	MsgAdapter.WriteShort(self.param_2)
	MsgAdapter.WriteShort(self.param_3)
end

----------------------------------------------------------

--获得一折抢购信息
CSDiscountBuyGetInfo = CSDiscountBuyGetInfo or BaseClass(BaseProtocolStruct)
function CSDiscountBuyGetInfo:__init()
	self.msg_type = 4760
end

function CSDiscountBuyGetInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--一折抢购信息
SCDiscountBuyInfo =  SCDiscountBuyInfo or BaseClass(BaseProtocolStruct)
function SCDiscountBuyInfo:__init()
	self.msg_type = 4706
	self.phase_list = {}
end

function SCDiscountBuyInfo:Decode()
	self.phase_list = {}
	local real_count = DisCountData.Instance:GetPaseCount()
	for i = 1, real_count do
		local phase = {}
		phase.close_timestamp = MsgAdapter.ReadUInt()
		phase.buy_count_list = {}
		for j = 1, GameEnum.DISCOUNT_BUY_ITEM_PER_PHASE do
			table.insert(phase.buy_count_list, MsgAdapter.ReadChar())
		end
		MsgAdapter.ReadShort()
		table.insert(self.phase_list, phase)
	end
end

--一折抢购购买请求
CSDiscountBuyReqBuy = CSDiscountBuyReqBuy or BaseClass(BaseProtocolStruct)
function CSDiscountBuyReqBuy:__init()
	self.msg_type = 4761
	self.seq = 0
	self.reserve_sh = 0
end

function CSDiscountBuyReqBuy:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.seq)
	MsgAdapter.WriteShort(self.reserve_sh)
end


--================红包接收协议============================
--红包详细信息
SCRedPaperDetailInfo =  SCRedPaperDetailInfo or BaseClass(BaseProtocolStruct)
function SCRedPaperDetailInfo:__init()
	self.msg_type = 4712
end

function SCRedPaperDetailInfo:Decode()
	self.notify_reason = MsgAdapter.ReadInt()
	self.id = MsgAdapter.ReadInt()
	self.type = MsgAdapter.ReadInt()
	self.total_gold_num = MsgAdapter.ReadInt()
	self.fetch_gold_num = MsgAdapter.ReadInt()
	self.can_fetch_times = MsgAdapter.ReadUInt()
	self.timeount_timestamp = MsgAdapter.ReadInt()
	self.creater_uid = MsgAdapter.ReadInt()
	self.creater_name = MsgAdapter.ReadStrN(32)
	self.creater_guild_id = MsgAdapter.ReadInt()
	self.avatar_key_big = MsgAdapter.ReadInt()
	self.avatar_key_small = MsgAdapter.ReadInt()
	self.sex = MsgAdapter.ReadChar()
	self.prof = MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
	self.boss_id = MsgAdapter.ReadInt()
	self.fetch_user_count = MsgAdapter.ReadInt()
	self.log_list = {}
	for i = 1, self.fetch_user_count do
		self.log_list[i] = {}
		self.log_list[i].uid = MsgAdapter.ReadInt()
		self.log_list[i].gold_num = MsgAdapter.ReadInt()
		self.log_list[i].avatar_key_big = MsgAdapter.ReadInt()
		self.log_list[i].avatar_key_small = MsgAdapter.ReadInt()
		self.log_list[i].name = MsgAdapter.ReadStrN(32)
	end
	if self.type == RED_PAPER_TYPE.RED_PAPER_TYPE_RAND then
		local index = 0
		local gold = 0
		for k,v in pairs(self.log_list) do
			if gold < v.gold_num then
				gold = v.gold_num
				index = k
			end
		end
		if index > 0 then
			self.log_list[index].is_luck = true
		end
	end
end

--红包领取结果
SCRedPaperFetchResult =  SCRedPaperFetchResult or BaseClass(BaseProtocolStruct)
function SCRedPaperFetchResult:__init()
	self.msg_type = 4713
end

function SCRedPaperFetchResult:Decode()
	self.notify_reason = MsgAdapter.ReadInt()
	self.fetch_gold = MsgAdapter.ReadInt()
	self.creater_name = MsgAdapter.ReadStrN(32)
	self.type = MsgAdapter.ReadInt()
	self.red_paper_id = MsgAdapter.ReadInt()
end

--================红包请求协议======================================

--创建红包请求
CSRedPaperCreateReq = CSRedPaperCreateReq or BaseClass(BaseProtocolStruct)
function CSRedPaperCreateReq:__init()
	self.msg_type = 4765
	self.type = 0
	self.gold_num = 0
	self.can_fetch_times = 0
end

function CSRedPaperCreateReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.type)
	MsgAdapter.WriteInt(self.gold_num)
	MsgAdapter.WriteInt(self.can_fetch_times)
end

--领取红包请求
CSRedPaperFetchReq = CSRedPaperFetchReq or BaseClass(BaseProtocolStruct)
function CSRedPaperFetchReq:__init()
	self.msg_type = 4766
	self.red_paper_id = 0
end

function CSRedPaperFetchReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.red_paper_id)
end

--查询红包详细信息请求
CSRedPaperQueryDetailReq = CSRedPaperQueryDetailReq or BaseClass(BaseProtocolStruct)
function CSRedPaperQueryDetailReq:__init()
	self.msg_type = 4767
	self.red_paper_id = 0
end

function CSRedPaperQueryDetailReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.red_paper_id)
end

--================仙盟运势下发协议======================================
SCGuildLuckyInfo = SCGuildLuckyInfo or BaseClass(BaseProtocolStruct)
function SCGuildLuckyInfo:__init()
	self.msg_type = 4716
	self.reason = 0
	self.member_count = 0
end

function SCGuildLuckyInfo:Decode()
	self.reason = MsgAdapter.ReadInt()
	self.member_count = MsgAdapter.ReadInt()

	self.member_luckyinfo_list = {}
	for i = 1, self.member_count do
		local vo = {}
		vo.uid = MsgAdapter.ReadUInt()
		vo.lucky_color = MsgAdapter.ReadUInt()
		vo.user_name = MsgAdapter.ReadStrN(32)
		self.member_luckyinfo_list[i] = vo
	end
end


--================仙盟通知======================================
SCInviteLuckyZhufu =  SCInviteLuckyZhufu or BaseClass(BaseProtocolStruct)
function SCInviteLuckyZhufu:__init()
	self.msg_type = 4717
	self.reason = 0
	self.member_count = ""
end

function SCInviteLuckyZhufu:Decode()
	self.req_invite_uid = MsgAdapter.ReadInt()
	self.req_invite_name = MsgAdapter.ReadStrN(32)
end

--仙盟祝福变更通知
SCGuildLuckyChangeNotice = SCGuildLuckyChangeNotice or BaseClass(BaseProtocolStruct)
function SCGuildLuckyChangeNotice:__init()
	self.msg_type = 4718
	self.bless_uid = 0
	self.bless_name = ""
	self.to_color = 0
end

function SCGuildLuckyChangeNotice:Decode()
	self.bless_uid = MsgAdapter.ReadInt()
	self.bless_name = MsgAdapter.ReadStrN(32)
	self.to_color = MsgAdapter.ReadInt()
end

--===========时装协议======================================
--时装信息
SCShizhuangInfo = SCShizhuangInfo or BaseClass(BaseProtocolStruct)
function SCShizhuangInfo:__init()
	self.msg_type = 4719
end

function SCShizhuangInfo:Decode()
	self.item_list = {}
	self.item_list_upgrade = {}
	self.item_least_time = {}
	for i = 0, SHIZHUANG_TYPE.MAX - 1 do
		local vo = {}
		vo.use_idx = MsgAdapter.ReadChar()
		MsgAdapter.ReadChar()
		MsgAdapter.ReadShort(32)
		vo.active_flag = MsgAdapter.ReadUInt(32)
		vo.active_flag2 = MsgAdapter.ReadUInt(32)

		-- vo.level_list = {}
		-- for j = 0, SHIZHUANG.SHIZHUANG_MAX_INDEX do
		-- 	vo.level_list[j] = MsgAdapter.ReadChar()
		-- end
		self.item_list[i] = vo
	end

	for i = 0, SHIZHUANG_TYPE.MAX - 1 do
		local vo = {}
		vo.level_list = {}
		for j = 0, SHIZHUANG.SHIZHUANG_MAX_INDEX do
			vo.level_list[j] = MsgAdapter.ReadChar()
		end
		self.item_list_upgrade[i] = vo
	end

	for i = 0, SHIZHUANG_TYPE.MAX - 1 do
		local  vo = {}
		vo.time_list = {}
		for j = 0, SHIZHUANG.SHIZHUANG_MAX_INDEX do
			vo.time_list[j] = MsgAdapter.ReadUInt()
		end
		self.item_least_time[i] = vo
	end
end

-- 使用时装协议
CSShizhuangUseReq = CSShizhuangUseReq or BaseClass(BaseProtocolStruct)
function CSShizhuangUseReq:__init()
	self.msg_type = 4771
	self.part = 0
	self.index = 0
end

function CSShizhuangUseReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.part)
	MsgAdapter.WriteShort(self.index)
end

-- 请求领取至尊会员元宝
CSMonthCardFetchDayReward = CSMonthCardFetchDayReward or BaseClass(BaseProtocolStruct)
function CSMonthCardFetchDayReward:__init()
	self.msg_type = 4773
end

function CSMonthCardFetchDayReward:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 请求断开连接
CSDisconnectReq = CSDisconnectReq or BaseClass(BaseProtocolStruct)
function CSDisconnectReq:__init()
	self.msg_type = 4778
end

function CSDisconnectReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 请求飞升转职
CSZhuanzhiReq = CSZhuanzhiReq or BaseClass(BaseProtocolStruct)
function CSZhuanzhiReq:__init()
	self.msg_type = 4779
end

function CSZhuanzhiReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--===========情缘卡牌======================================
-- 情缘卡牌等级变更通知
SCQingyuanCardUpdate = SCQingyuanCardUpdate or BaseClass(BaseProtocolStruct)
function SCQingyuanCardUpdate:__init()
	self.msg_type = 4725
end

function SCQingyuanCardUpdate:Decode()
	self.card_id = MsgAdapter.ReadChar()
	self.card_level = MsgAdapter.ReadChar()
	self.reserve_sh = MsgAdapter.ReadShort()
end

-- 请求升级情缘卡牌
CSQingyuanCardUpgradeReq = CSQingyuanCardUpgradeReq or BaseClass(BaseProtocolStruct)
function CSQingyuanCardUpgradeReq:__init()
	self.msg_type = 4780
	self.card_id = 0
	self.reserve_ch = 0
	self.reserve_sh = 0
end

function CSQingyuanCardUpgradeReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteChar(self.card_id)
	MsgAdapter.WriteChar(self.reserve_ch)
	MsgAdapter.WriteShort(self.reserve_sh)
end

--===========卡牌======================================
CSCardOperate = CSCardOperate or BaseClass(BaseProtocolStruct)
function CSCardOperate:__init()
	self.msg_type = 4772
end

function CSCardOperate:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.operate_type)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
	MsgAdapter.WriteInt(self.param3)
	MsgAdapter.WriteInt(self.param4)
end

SCCardInfo = SCCardInfo or BaseClass(BaseProtocolStruct)
function SCCardInfo:__init()
	self.msg_type = 4720
end

function SCCardInfo:Decode()
	self.card_list = {}

	for i=0,15 do
		local card_obj = {}
		card_obj.color_list = {}

		for k=1,4 do
			table.insert(card_obj.color_list, MsgAdapter.ReadChar())
		end

		card_obj.level = MsgAdapter.ReadShort()
		MsgAdapter.ReadShort()
		card_obj.exp = MsgAdapter.ReadInt()

		self.card_list[i] = card_obj
	end
end

-- 升级时装协议
CSShizhuangUpgradeReq = CSShizhuangUpgradeReq or BaseClass(BaseProtocolStruct)
function CSShizhuangUpgradeReq:__init()
	self.msg_type = 4781
	self.part = 0
	self.index = 0
end

function CSShizhuangUpgradeReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.part)
	MsgAdapter.WriteShort(self.index)
end

--------夫妻光环激活列表
SCQingyuanCoupleHaloInfo = SCQingyuanCoupleHaloInfo or BaseClass(BaseProtocolStruct)
function SCQingyuanCoupleHaloInfo:__init()
	self.msg_type = 4783
end

function SCQingyuanCoupleHaloInfo:Decode()
	self.equiped_couple_halo_type = MsgAdapter.ReadShort()				--已装备的夫妻光环类型
	local couple_halo_max_type_count = MsgAdapter.ReadShort()

	self.couple_halo_level_list = {}									--夫妻光环等级列表
	for i = 1, MarriageData.QINGYUAN_COUPLE_HALO_MAX_TYPE do
		if i > couple_halo_max_type_count then
			MsgAdapter.ReadShort()
		else
			table.insert(self.couple_halo_level_list, MsgAdapter.ReadShort())
		end
	end

	self.couple_halo_exp_list = {}										--夫妻光环经验列表
	for i = 1, MarriageData.QINGYUAN_COUPLE_HALO_MAX_TYPE do
		table.insert(self.couple_halo_exp_list, MsgAdapter.ReadShort())
	end

	self.other_equiped_couple_halo_type = MsgAdapter.ReadShort()
	local reverse_short = MsgAdapter.ReadShort()
	self.other_couple_halo_level_list = {}							--伴侣光环等级列表
	for i = 1, MarriageData.QINGYUAN_COUPLE_HALO_MAX_TYPE do
		if i > couple_halo_max_type_count then
			MsgAdapter.ReadShort()
		else
			table.insert(self.other_couple_halo_level_list, MsgAdapter.ReadShort())
		end
	end
end

SCQingyuanCoupleHaloTrigger = SCQingyuanCoupleHaloTrigger or BaseClass(BaseProtocolStruct)
function SCQingyuanCoupleHaloTrigger:__init()
	self.msg_type = 4784
	self.role1_uid = 0
	self.role2_uid = 0
	self.halo_type = 0
end

function SCQingyuanCoupleHaloTrigger:Decode()
	self.role1_uid = MsgAdapter.ReadInt()
	self.role2_uid = MsgAdapter.ReadInt()
	self.halo_type = MsgAdapter.ReadInt()
end

-- 请求情缘夫妻光环
CSQingyuanCoupleHaloOperaReq = CSQingyuanCoupleHaloOperaReq or BaseClass(BaseProtocolStruct)
function CSQingyuanCoupleHaloOperaReq:__init()
	self.msg_type = 4785
	self.req_type = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
end

function CSQingyuanCoupleHaloOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.req_type)
	MsgAdapter.WriteShort(self.param_1)
	MsgAdapter.WriteShort(self.param_2)
	MsgAdapter.WriteShort(self.param_3)
end

--请求获取祝福奖励
CSQingyuanFetchBlessRewardReq = CSQingyuanFetchBlessRewardReq or BaseClass(BaseProtocolStruct)
function CSQingyuanFetchBlessRewardReq:__init()
	self.msg_type = 4790
end

function CSQingyuanFetchBlessRewardReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--请求购买祝福天数
CSQingyuanAddBlessDaysReq = CSQingyuanAddBlessDaysReq or BaseClass(BaseProtocolStruct)
function CSQingyuanAddBlessDaysReq:__init()
	self.msg_type = 4791
end

function CSQingyuanAddBlessDaysReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 爱情契约请求为Ta祝福
CSQingyuanBuyLoveContract = CSQingyuanBuyLoveContract or BaseClass(BaseProtocolStruct)
function CSQingyuanBuyLoveContract:__init()
	self.msg_type = 4792
end

function CSQingyuanBuyLoveContract:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteStr(self.love_contract)
end

-- 爱情契约领取奖励
CSQingyuanFetchLoveContract = CSQingyuanFetchLoveContract or BaseClass(BaseProtocolStruct)
function CSQingyuanFetchLoveContract:__init()
	self.msg_type = 4793
end

function CSQingyuanFetchLoveContract:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.day_num)
	MsgAdapter.WriteStrN(self.love_contract_notice, 64)
end

-- 爱情契约信息
SCQingyuanLoveContractInfo = SCQingyuanLoveContractInfo or BaseClass(BaseProtocolStruct)
function SCQingyuanLoveContractInfo:__init()
	self.msg_type = 4794
end

function SCQingyuanLoveContractInfo:Decode()
	self.is_already_get = MsgAdapter.ReadInt()                            -- 领取称号标记（0未领取 1领取）
	self.self_love_contract_reward_flag = bit:d2b(MsgAdapter.ReadInt())		-- 领取标记
	self.can_receive_day_num = MsgAdapter.ReadInt()							-- 可领取天数  -1 表示不可以领
	self.self_love_contract_timestamp = MsgAdapter.ReadUInt()				-- 是否给对方购买 0表示没有帮伴侣购买
	self.self_avatar = MsgAdapter.ReadLL()
	self.lover_avater = MsgAdapter.ReadLL()
	-- self.self_avatar = MsgAdapter.ReadLL()
	-- self.lover_avater_big = MsgAdapter.ReadUInt()
	-- self.lover_avater_small = MsgAdapter.ReadUInt()

	local self_notice_list_count = MsgAdapter.ReadInt()                     -- 我领取留言
	self.self_notice_list = {}
	for i = 0, GameEnum.MAX_NOTICE_COUNT - 1 do
		local day = MsgAdapter.ReadUInt()
		local contract_notice = MsgAdapter.ReadStrN(64)
		if i < self_notice_list_count then
			self.self_notice_list[i] = {day = day, contract_notice = contract_notice}
		end
	end

	local lover_notice_list_count = MsgAdapter.ReadInt()                    -- 伴侣领取留言
	self.lover_notice_list = {}
	for i = 0, GameEnum.MAX_NOTICE_COUNT - 1 do
		local day = MsgAdapter.ReadUInt()
		local contract_notice = MsgAdapter.ReadStrN(64)
		if i < lover_notice_list_count then
			self.lover_notice_list[i] = {day = day, contract_notice = contract_notice}
		end
	end

	self.is_buy_contract = MsgAdapter.ReadShort()
	local self_permission_count = MsgAdapter.ReadShort()                   -- 我签订契约留言
	if self_permission_count == 0 then
		self.self_permission = MsgAdapter.ReadStrN(128)
		self.self_permission = ""
	else
		self.self_permission = MsgAdapter.ReadStrN(128)
	end

	self.lover_love_contract_timestamp = MsgAdapter.ReadUInt()        -- 伴侣购买的时间戳
	self.today_remind_times = MsgAdapter.ReadInt()					 -- 提醒对面为我购买
	local lover_permission_count = MsgAdapter.ReadInt()             -- 伴侣签订契约留言
	if lover_permission_count == 0 then
		--self.self_permission = MsgAdapter.ReadStrN(128)
		self.lover_permission = ""
	else
		self.lover_permission = MsgAdapter.ReadStrN(lover_permission_count)
	end
end

-- 请求爱情契约的信息
CSQingyuanLoveContractInfoReq = CSQingyuanLoveContractInfoReq or BaseClass(BaseProtocolStruct)
function CSQingyuanLoveContractInfoReq:__init()
	self.msg_type = 4795
end

function CSQingyuanLoveContractInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

------------------零元礼包---------------

--零元礼包信息
SCZeroGiftInfo = SCZeroGiftInfo or BaseClass(BaseProtocolStruct)
function SCZeroGiftInfo:__init()
	self.msg_type = 4796
	self.phase_list = {}
end

function SCZeroGiftInfo:Decode()
	self.phase_list = {}
	for i = 0, 4 do
		local vo = {}
		vo.state = MsgAdapter.ReadInt()
		vo.reward_flag = MsgAdapter.ReadInt()
		vo.timestamp = MsgAdapter.ReadUInt()
		self.phase_list[i] = vo
	end
end

-- 4797零元礼包操作
CSZeroGiftOperate = CSZeroGiftOperate or BaseClass(BaseProtocolStruct)
function CSZeroGiftOperate:__init()
	self.msg_type = 4797
	self.operate_type = 0
	self.param_1 = 0
	self.param_2 = 0
end

function CSZeroGiftOperate:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.operate_type)
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
end

-- 4798功能预告操作
-- ADVANCE_NOTICE_OPERATE_TYPE =
-- {
-- 	ADVANCE_NOTICE_GET_INFO = 0,
-- 	ADVANCE_NOTICE_FETCH_REWARD = 1,
-- }
CSAdvanceNoitceOperate = CSAdvanceNoitceOperate or BaseClass(BaseProtocolStruct)
function CSAdvanceNoitceOperate:__init()
	self.msg_type = 4798
	self.operate_type = 0
	self.param_1 = 0
end

function CSAdvanceNoitceOperate:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.operate_type)
	MsgAdapter.WriteInt(self.param_1)
end

-- 4799 功能预告信息信息
SCAdvanceNoticeInfo = SCAdvanceNoticeInfo or BaseClass(BaseProtocolStruct)
function SCAdvanceNoticeInfo:__init()
	self.msg_type = 4799
end

function SCAdvanceNoticeInfo:Decode()
	self.notice_type = MsgAdapter.ReadInt()
	self.last_fecth_id = MsgAdapter.ReadInt()
end

--当天剩余可发钻石
SCRedPaperRoleInfo = SCRedPaperRoleInfo or BaseClass(BaseProtocolStruct)
function SCRedPaperRoleInfo:__init()
	self.msg_type = 4726
end

function SCRedPaperRoleInfo:Decode()
	self.daily_send_gold = MsgAdapter.ReadInt()
end

--口令喇叭协议
CSCreateCommandRedPaper = CSCreateCommandRedPaper or BaseClass(BaseProtocolStruct)
function CSCreateCommandRedPaper:__init()
	self.msg_type = 4727
	self.hb_msg = ""
end

function CSCreateCommandRedPaper:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteStr(self.hb_msg)
end

--口令获取口令红包
CSFetchCommandRedPaper = CSFetchCommandRedPaper or BaseClass(BaseProtocolStruct)
function CSFetchCommandRedPaper:__init()
	self.msg_type = 4728
	self.red_paper_id = 0
end

function CSFetchCommandRedPaper:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.red_paper_id)
end


--查看红包信息请求
CSCommandRedPaperCheckInfo = CSCommandRedPaperCheckInfo or BaseClass(BaseProtocolStruct)
function CSCommandRedPaperCheckInfo:__init()
	self.msg_type = 4729
	self.red_paper_id = 0
end

function CSCommandRedPaperCheckInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.red_paper_id)
end

--发送红包信息
SCCommandRedPaperSendInfo = SCCommandRedPaperSendInfo or BaseClass(BaseProtocolStruct)
function SCCommandRedPaperSendInfo:__init()
	self.msg_type = 4730
	self.creater_uid = 0
	self.creater_name = ""
	self.avatar_key_big = 0
	self.avatar_key_small = 0
	self.prof = 0
	self.sex = 0
	self.kouling_msg = ""
	self.id = ""
end

function SCCommandRedPaperSendInfo:Decode()
	self.creater_uid = MsgAdapter.ReadInt()
	self.creater_name = MsgAdapter.ReadStrN(32)
	self.avatar_key_big = MsgAdapter.ReadInt()
	self.avatar_key_small = MsgAdapter.ReadInt()
	local len = MsgAdapter.ReadInt()
	self.sex = MsgAdapter.ReadChar()
	self.prof = MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
	self.id = MsgAdapter.ReadInt()
	self.kouling_msg = MsgAdapter.ReadStrN(len)
end

--卡牌信息
SCCardAllInfo = SCCardAllInfo or BaseClass(BaseProtocolStruct)
function SCCardAllInfo:__init()
	self.msg_type = 4731
	self.card_level = 0
	self.card_exp = 0
	self.card_color_list = {}
end

function SCCardAllInfo:Decode()
	self.card_level = MsgAdapter.ReadInt()
	self.card_exp = MsgAdapter.ReadInt()
	self.card_color_list = {}
	for i = 0, CardData.CARD_MAX_COUNT - 1 do
		self.card_color_list[i] = {}
		for i1 = 0, CardData.SLOT_PER_CARD - 1 do
			self.card_color_list[i][i1] = MsgAdapter.ReadUShort()
		end
	end
end

--卡牌升级
SCCardLevelUp = SCCardLevelUp or BaseClass(BaseProtocolStruct)
function SCCardLevelUp:__init()
	self.msg_type = 4732
	self.card_level = 0
	self.card_exp = 0
end

function SCCardLevelUp:Decode()
	self.card_level = MsgAdapter.ReadInt()
	self.card_exp = MsgAdapter.ReadInt()

end

--装备卡牌slot
CSCardSlotPutOn = CSCardSlotPutOn or BaseClass(BaseProtocolStruct)
function CSCardSlotPutOn:__init()
	self.msg_type = 4733
	self.card_idx = 0
	self.slot_idx = 0
	self.grid_index = 0
end

function CSCardSlotPutOn:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.card_idx)
	MsgAdapter.WriteInt(self.slot_idx)
	MsgAdapter.WriteShort(self.grid_index)
	MsgAdapter.WriteShort(0)
end

--请求卡牌信息
CSCardAllInfoReq = CSCardAllInfoReq or BaseClass(BaseProtocolStruct)
function CSCardAllInfoReq:__init()
	self.msg_type = 4734
end

function CSCardAllInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--装备卡牌slot返回单个数据的修改
SCCardSlotPutOnUpdate = SCCardSlotPutOnUpdate or BaseClass(BaseProtocolStruct)
function SCCardSlotPutOnUpdate:__init()
	self.msg_type = 4735
	self.card_idx = 0
	self.slot_idx = 0
	self.item_id = 0
end

function SCCardSlotPutOnUpdate:Decode()
	self.card_idx = MsgAdapter.ReadInt()
	self.slot_idx = MsgAdapter.ReadInt()
	self.item_id = MsgAdapter.ReadUShort()
	MsgAdapter.ReadUShort()
end

--脱下卡牌
CSCardSlotTakeOff = CSCardSlotTakeOff or BaseClass(BaseProtocolStruct)
function CSCardSlotTakeOff:__init()
	self.msg_type = 4736
	self.card_idx = 0
	self.slot_idx = 0
end

function CSCardSlotTakeOff:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.card_idx)
	MsgAdapter.WriteInt(self.slot_idx)
end

----------------------------个人目标系统------------------------------------
CSRoleGoalOperaReq = CSRoleGoalOperaReq or BaseClass(BaseProtocolStruct)
function CSRoleGoalOperaReq:__init()
	self.msg_type = 4764
	self.opera_type = 0
	self.param = 0
end

function CSRoleGoalOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opera_type)
	MsgAdapter.WriteInt(self.param)
end

SCRoleGoalInfo = SCRoleGoalInfo or BaseClass(BaseProtocolStruct)
function SCRoleGoalInfo:__init()
	self.msg_type = 4710
end

function SCRoleGoalInfo:Decode()
	self.cur_chapter = MsgAdapter.ReadInt()
	self.old_chapter = MsgAdapter.ReadInt()
	self.goal_data_list = {}
	for i = 0, GameEnum.PERSONAL_GOAL_COND_MAX - 1 do
		self.goal_data_list[i] = MsgAdapter.ReadInt()
	end

	self.field_goal_can_fetch_flag = MsgAdapter.ReadInt()
	self.field_goal_fetch_flag = MsgAdapter.ReadInt()
	self.skill_level_list = {}
	for i = 1, GameEnum.FIELD_GOAL_SKILL_TYPE_MAX do
		self.skill_level_list[i] = MsgAdapter.ReadShort()
	end
end