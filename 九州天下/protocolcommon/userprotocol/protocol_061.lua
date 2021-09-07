-- 魔龙信息
SCMolongInfo = SCMolongInfo or BaseClass(BaseProtocolStruct)
function SCMolongInfo:__init()
	self.msg_type = 6104
end

function SCMolongInfo:Decode()
	self.info = {}
	self.info.accumulate_consume_gold = MsgAdapter.ReadInt()
	self.info.today_consume_gold = MsgAdapter.ReadInt()
	self.info.today_move_step = MsgAdapter.ReadShort()
	self.info.total_move_step = MsgAdapter.ReadShort()
	self.info.curr_loop = MsgAdapter.ReadInt()
end

-- 宠物操作请求  6110
CSPetOperaReq = CSPetOperaReq or BaseClass(BaseProtocolStruct)
function CSPetOperaReq:__init()
	self.msg_type = 6110

	self.opera_type = 0
	self.req_type = 0
	self.param_1 = 0
	self.param_2 = 0
	self.newname = ""
end

function CSPetOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(0)
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
	MsgAdapter.WriteStrN(self.newname, 32)
end

-- 宠物升阶请求  6111
CSPetUpgradeReq = CSPetUpgradeReq or BaseClass(BaseProtocolStruct)
function CSPetUpgradeReq:__init()
	self.msg_type = 6111

	self.repeat_times = 0
	self.auto_buy = 0
end

function CSPetUpgradeReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteShort(self.repeat_times)
	MsgAdapter.WriteShort(self.auto_buy)
end

-- 宠物背包信息 6106
SCPetBackpackInfo = SCPetBackpackInfo or BaseClass(BaseProtocolStruct)
function SCPetBackpackInfo:__init()
	self.msg_type = 6106
	self.last_free_chou_timestamp = 0
	self.backpack_item_list = {}
	self.food_market_free_times = 0
end

function SCPetBackpackInfo:Decode()
	self.last_free_chou_timestamp = MsgAdapter.ReadInt()
	self.backpack_item_list = {}

	for i = 1, PET_INFO_TYPE.PET_MAX_STORE_COUNT do
		local list_item = {}
		list_item.item_id = MsgAdapter.ReadUShort()
		list_item.is_bind = MsgAdapter.ReadShort()
		list_item.num = MsgAdapter.ReadInt() or 0
		list_item.index = i - 1
		self.backpack_item_list[i] = list_item
	end
	self.food_market_free_times = MsgAdapter.ReadInt()
end

-- 使用宠物特殊形象   6112
CSPetUseSpecialImg = CSPetUseSpecialImg or BaseClass(BaseProtocolStruct)
function CSPetUseSpecialImg:__init()
	self.msg_type = 6112

	self.special_img_id = 0
	self.reserve_sh = 0
end

function CSPetUseSpecialImg:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteShort(self.special_img_id)
	MsgAdapter.WriteShort(self.reserve_sh)
end

--宠物信息 6107
SCPetInfo = SCPetInfo or BaseClass(BaseProtocolStruct)
function SCPetInfo:__init()
	self.msg_type = 6107
	self.cur_on_use_pet_id = 0
	self.own_pet_list = {}
	self.special_img_active_flag = 0
end

function SCPetInfo:Decode()
	self.cur_on_use_pet_id = MsgAdapter.ReadInt()
	self.own_pet_list = {}

	for i = 0, PET_INFO_TYPE.PET_MAX_COUNT_LIMIT - 1 do
		local pet_item = {}
		pet_item.level = MsgAdapter.ReadShort()			-- 等级
		pet_item.grade = MsgAdapter.ReadShort()			-- 阶数
		pet_item.bless = MsgAdapter.ReadShort()			--祝福值
		MsgAdapter.ReadShort()
		pet_item.name = MsgAdapter.ReadStrN(32)			-- 名字
		pet_item.skill_slot = {}
		for j = 0, PET_SKILL_SLOT_TYPE.PET_SKILL_SLOT_TYPE_COUNT - 1 do
			local passive_skill_item = {}
			passive_skill_item.slot_index = j
			passive_skill_item.skill_index = MsgAdapter.ReadChar()
			passive_skill_item.skill_level = MsgAdapter.ReadChar()
			pet_item.skill_slot[j] = passive_skill_item
		end
		MsgAdapter.ReadShort()
		self.own_pet_list[i] = pet_item
	end

	self.special_img_active_flag = MsgAdapter.ReadInt()
end

--宠物出战信息6109
SCFightOutPetInfo = SCFightOutPetInfo or BaseClass(BaseProtocolStruct)
function SCFightOutPetInfo:__init()
	self.msg_type = 6109
	self.cur_on_use_pet_id = 0
end

function SCFightOutPetInfo:Decode()
	self.cur_on_use_pet_id = MsgAdapter.ReadInt()	-- 当前出战的宠物id
end

--宠物属性改变广播 6105
SCPetViewChangeNotify = SCPetViewChangeNotify or BaseClass(BaseProtocolStruct)
function SCPetViewChangeNotify:__init()
	self.msg_type = 6105
	self.obj_id = 0
	self.pet_id = 0
	self.pet_level = 0
	self.pet_grade = 0
	self.pet_name = ""
	self.use_img_id = 0
	self.reserve_sh = 0
end

function SCPetViewChangeNotify:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.pet_id = MsgAdapter.ReadShort()
	self.pet_level = MsgAdapter.ReadShort()
	self.pet_grade = MsgAdapter.ReadShort()
	self.pet_name = MsgAdapter.ReadStrN(32)
	self.use_img_id = MsgAdapter.ReadShort()
end

--宠物抽奖结果信息
SCPetChouResult = SCPetChouResult or BaseClass(BaseProtocolStruct)
function SCPetChouResult:__init()
	self.msg_type = 6108
	self.reward_list_count = 0
	self.all_reward_index_list = {}
end

function SCPetChouResult:Decode()
	self.reward_list_count = MsgAdapter.ReadShort()
	self.all_reward_index_list = {}

	for i = 0, self.reward_list_count - 1 do
		self.all_reward_index_list[i] = MsgAdapter.ReadChar()
	end
end


-- 随机活动被整达人
SCRASpecialAppearancePassiveInfo = SCRASpecialAppearancePassiveInfo or BaseClass(BaseProtocolStruct)
function SCRASpecialAppearancePassiveInfo:__init()
	self.msg_type = 6113

	self.rank_list = {}
end

function SCRASpecialAppearancePassiveInfo:Decode()
	self.role_change_times = MsgAdapter.ReadInt()
	self.rank_count = MsgAdapter.ReadInt()

	self.rank_list = {}
	for i=1, self.rank_count do
		local rank_info = {}
		rank_info.uid = MsgAdapter.ReadInt()
		rank_info.user_name = MsgAdapter.ReadStrN(32)
		rank_info.change_num = MsgAdapter.ReadInt()
		rank_info.m_capablity = MsgAdapter.ReadInt()
		self.rank_list[i] = rank_info
	end
end


--返回整蛊专家活动玩家信息
SCRASpecialAppearanceInfo = SCRASpecialAppearanceInfo or BaseClass(BaseProtocolStruct)
function SCRASpecialAppearanceInfo:__init()
	self.msg_type = 6114

	self.role_change_times = 0
	self.rank_count = 0
	self.rank_list = {}
end

function SCRASpecialAppearanceInfo:Decode()
	self.role_change_times = MsgAdapter.ReadInt()
	self.rank_count = MsgAdapter.ReadInt()
	self.rank_list = {}
	for i=1, self.rank_count do
		local rank_info = {}
		rank_info.uid = MsgAdapter.ReadInt()
		rank_info.user_name = MsgAdapter.ReadStrN(32)
		rank_info.change_num = MsgAdapter.ReadInt()
		rank_info.m_capablity = MsgAdapter.ReadInt()
		self.rank_list[i] = rank_info
	end
end

---------化神----------------
CSHuaShenOperaReq = CSHuaShenOperaReq or BaseClass(BaseProtocolStruct)
function CSHuaShenOperaReq:__init()
	self.msg_type = 6116

	self.req_type = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
end

function CSHuaShenOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteUShort(self.req_type)
	MsgAdapter.WriteUShort(self.param_1)
	MsgAdapter.WriteUShort(self.param_2)
	MsgAdapter.WriteUShort(self.param_3)
end


SCHuaShenAllInfo = SCHuaShenAllInfo or BaseClass(BaseProtocolStruct)
function SCHuaShenAllInfo:__init()
	self.msg_type = 6115
	self.activie_flag = 0
	self.cur_huashen_id = 0
	self.level_info_list = {}
end

function SCHuaShenAllInfo:Decode()
	self.activie_flag = {}
	local temp_flag_t = bit:d2b(MsgAdapter.ReadChar())
	for i = 0, 31 do
		self.activie_flag[i] = temp_flag_t[32 - i]
	end

	self.cur_huashen_id = MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
	self.level_info_list = {}

	for i = 0, GameEnum.HUASHEN_MAX_ID - 1 do
		local data = {}
		data.level = MsgAdapter.ReadShort()
		data.jinhua_val = MsgAdapter.ReadShort()
		self.level_info_list[i] = data
	end

	self.grade_list = {}
	for i = 0, GameEnum.HUASHEN_MAX_ID - 1 do
		self.grade_list[i] = MsgAdapter.ReadShort()
	end
end


-- 全部宠物亲密度信息6505
SCPetQinmiAllInfo = SCPetQinmiAllInfo or BaseClass(BaseProtocolStruct)
function SCPetQinmiAllInfo:__init()
	self.msg_type = 6117

	self.pet_qinmi_list = {}
	self.ignore_fangyu_percent_level = 0
end

function SCPetQinmiAllInfo:Decode()
	for i=0,PET_INFO_TYPE.PET_MAX_COUNT_LIMIT - 1 do
		local param = {}
		param.qinmi_val = MsgAdapter.ReadInt()
		param.level = MsgAdapter.ReadChar()
		param.star = MsgAdapter.ReadChar()
		param.reserve_sh = MsgAdapter.ReadShort()
		param.reserve_ll = MsgAdapter.ReadLL()
		self.pet_qinmi_list[i] = param
	end

	self.ignore_fangyu_percent_level = MsgAdapter.ReadInt()
end

-- 单个宠物亲密度信息6506
SCPetQinmiSingleInfo = SCPetQinmiSingleInfo or BaseClass(BaseProtocolStruct)
function SCPetQinmiSingleInfo:__init()
	self.msg_type = 6118

	self.pet_qinmi_item = {}
	self.cur_pet_id = 0
	self.ignore_fangyu_percent_level = 0
end

function SCPetQinmiSingleInfo:Decode()
	self.pet_qinmi_item = {}
	self.pet_qinmi_item.qinmi_val = MsgAdapter.ReadInt()
	self.pet_qinmi_item.level = MsgAdapter.ReadChar()
	self.pet_qinmi_item.star = MsgAdapter.ReadChar()
	self.pet_qinmi_item.reserve_sh = MsgAdapter.ReadShort()
	self.pet_qinmi_item.reserve_ll = MsgAdapter.ReadLL()

	self.cur_pet_id = MsgAdapter.ReadInt()
	self.ignore_fangyu_percent_level = MsgAdapter.ReadInt()
end

-- 宠物捕食奖励6507
SCPetFoodMarcketChouResult = SCPetFoodMarcketChouResult or BaseClass(BaseProtocolStruct)
function SCPetFoodMarcketChouResult:__init()
	self.msg_type = 6119

	self.reward_list_count = 0
	self.all_reward_index_list = {}
end

function SCPetFoodMarcketChouResult:Decode()
	self.reward_list_count = MsgAdapter.ReadShort()
	self.all_reward_index_list = {}
	for i=1,self.reward_list_count do
		table.insert(self.all_reward_index_list, MsgAdapter.ReadChar())
	end
end

-------------牧场---------------------------------------------------------------
SCPastureSpiritAllInfo = SCPastureSpiritAllInfo or BaseClass(BaseProtocolStruct)
function SCPastureSpiritAllInfo:__init()
	self.msg_type = 6120
	self.point = 0
	self.last_free_draw_timestamp = 0
end

function SCPastureSpiritAllInfo:Decode()
	self.point = MsgAdapter.ReadInt()
	self.last_free_draw_timestamp = MsgAdapter.ReadUInt()
	self.pasture_spirit_item_list = {}
	for i = 0, GameEnum.PASTURE_SPIRIT_MAX_COUNT - 1 do
		local pasture_spirit_item = {}
		pasture_spirit_item.level = MsgAdapter.ReadChar()
		pasture_spirit_item.quality = MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()
		pasture_spirit_item.quality_val = MsgAdapter.ReadInt()
		MsgAdapter.ReadLL()
		self.pasture_spirit_item_list[i] = pasture_spirit_item
	end
end

SCPastureSpiritSinglelInfo = SCPastureSpiritSinglelInfo or BaseClass(BaseProtocolStruct)
function SCPastureSpiritSinglelInfo:__init()
	self.msg_type = 6121
	self.id = 0
end

function SCPastureSpiritSinglelInfo:Decode()
	self.id = MsgAdapter.ReadInt()

	self.pasture_spirit_item = {}
	local temp_pasture_spirit_item = {}
	temp_pasture_spirit_item.level = MsgAdapter.ReadChar()
	temp_pasture_spirit_item.quality = MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
	temp_pasture_spirit_item.quality_val = MsgAdapter.ReadInt()
	MsgAdapter.ReadLL()

	self.pasture_spirit_item = temp_pasture_spirit_item
end

SCPastureSpiritLuckyDrawResult = SCPastureSpiritLuckyDrawResult or BaseClass(BaseProtocolStruct)
function SCPastureSpiritLuckyDrawResult:__init()
	self.msg_type = 6122
	self.point = 0
	self.last_free_draw_timestamp = 0
	self.reward_count = 0
end

function SCPastureSpiritLuckyDrawResult:Decode()
	self.point = MsgAdapter.ReadInt()
	self.last_free_draw_timestamp = MsgAdapter.ReadUInt()
	self.reward_count = MsgAdapter.ReadShort()
	self.reward_seq_list = {}
	for i = 0, self.reward_count - 1 do
		self.reward_seq_list[i] = MsgAdapter.ReadChar()
	end
end
-------------牧场---------------------------------------------------------------

-- 双人坐骑信息
SCMultiMountAllInfo = SCMultiMountAllInfo or BaseClass(BaseProtocolStruct)
function SCMultiMountAllInfo:__init()
	self.msg_type = 6123

	self.cur_use_mount_id = -1
	self.count = 0
	self.mount_list = {}
end

function SCMultiMountAllInfo:Decode()
	self.cur_use_mount_id = MsgAdapter.ReadShort()
	self.count = MsgAdapter.ReadShort()

	self.mount_list = {}
	for i = 1, self.count do
		local mount_item = {}
		mount_item.grade_bless = MsgAdapter.ReadInt()
		mount_item.grade = MsgAdapter.ReadShort()
		mount_item.level = MsgAdapter.ReadShort()
		mount_item.index = i - 1
		self.mount_list[i] = mount_item
	end
end

-- 坐骑信息增量更新
SCMultiMountChangeNotify = SCMultiMountChangeNotify or BaseClass(BaseProtocolStruct)
function SCMultiMountChangeNotify:__init()
	self.msg_type = 6124

	self.notify_type = 0
	self.reserve_sh = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
end

function SCMultiMountChangeNotify:Decode()
	self.notify_type = MsgAdapter.ReadShort()
	self.reserve_sh = MsgAdapter.ReadShort()
	self.param_1 = MsgAdapter.ReadInt()
	self.param_2 = MsgAdapter.ReadInt()
	self.param_3 = MsgAdapter.ReadInt()
end

------广播双人坐骑
SCMultiMountNotifyArea = SCMultiMountNotifyArea or BaseClass(BaseProtocolStruct)
function SCMultiMountNotifyArea:__init()
	self.msg_type = 6125

	self.owner_role_id = 0  							--双人坐骑主人uid
	self.partner_role_id = 0 							--跟随者uid
	self.owner_objid = COMMON_CONSTS.INVALID_OBJID 		--主人的objid
	self.parnter_objid = COMMON_CONSTS.INVALID_OBJID 	--跟随者objid
	self.owner_multi_mount_res_id = 0 					--主人双人坐骑id
	self.parnter_multi_mount_res_id = 0 				--跟随者双人坐骑id
end

function SCMultiMountNotifyArea:Decode()
	self.owner_role_id = MsgAdapter.ReadInt()
	self.partner_role_id = MsgAdapter.ReadInt()
	self.owner_objid = MsgAdapter.ReadUShort()
	self.parnter_objid = MsgAdapter.ReadUShort()
	self.parnter_objid = self.parnter_objid or COMMON_CONSTS.INVALID_OBJID
	self.owner_multi_mount_res_id = MsgAdapter.ReadInt()
	self.parnter_multi_mount_res_id = MsgAdapter.ReadInt()
end


SCBubbleWindowInfo = SCBubbleWindowInfo or BaseClass(BaseProtocolStruct)
function SCBubbleWindowInfo:__init()
	self.msg_type = 6126
	self.cur_use_bubble_type = 0
	self.reserve = 0
	self.bubble_level = {}
end

function SCBubbleWindowInfo:Decode()
	self.cur_use_bubble_type = MsgAdapter.ReadShort()
	self.reserve = MsgAdapter.ReadShort()
	self.bubble_level = {}
	for i = 1, 50 do
		self.bubble_level[i] = MsgAdapter.ReadShort()
	end
end

SCAvatarWindowInfo = SCAvatarWindowInfo or BaseClass(BaseProtocolStruct)
function SCAvatarWindowInfo:__init()
	self.msg_type = 6127
end

function SCAvatarWindowInfo:Decode()
	self.cur_use_avatar_type = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.avatar_level = {}
	for i = 1, GameEnum.AVATAR_WINDOW_MAX_TYPE do
		table.insert(self.avatar_level, MsgAdapter.ReadShort())
	end
end

SCHuaShenSpiritInfo = SCHuaShenSpiritInfo or BaseClass(BaseProtocolStruct)
function SCHuaShenSpiritInfo:__init()
	self.msg_type = 6129
	self.huashen_id = 0
	self.spirit_list = {}
end

function SCHuaShenSpiritInfo:Decode()
	self.huashen_id = MsgAdapter.ReadInt()

	self.spirit_list = {}
	for i = 0, GameEnum.HUASHEN_SPIRIT_MAX_ID_LIMIT - 1 do
		local data = {}
		data.level = MsgAdapter.ReadShort()
		data.exp_val = MsgAdapter.ReadUShort()
		self.spirit_list[i] = data
	end
end


------------------ 魔卡数据解析-----------------------
SCMagicCardAllInfo = SCMagicCardAllInfo or BaseClass(BaseProtocolStruct)
function SCMagicCardAllInfo:__init()
	self.msg_type = 6130

	self.today_purple_free_chou_card_times = 0
	self.all_card_has_exchange_flag = 0
	self.all_card_num_list = {}
	self.card_slot_list = {}
end

function SCMagicCardAllInfo:Decode()
	self.today_purple_free_chou_card_times = MsgAdapter.ReadInt()

	self.all_card_has_exchange_flag = MsgAdapter.ReadInt()

	for i = 0, MAGIC_CARD.MAGIC_CARD_MAX_LIMIT_COUNT do
		self.all_card_num_list[i] = MsgAdapter.ReadUShort()
	end

	for i = 1, MAGIC_CARD_COLOR_TYPE.MAGIC_CARD_COLOR_TYPE_COLOR_COUNT * MAGIC_CARD.MAGIC_CARD_SLOT_TYPE_LIMIT_COUNT do
		local card_slot = {}
		card_slot.card_id = MsgAdapter.ReadShort()
		card_slot.strength_level = MsgAdapter.ReadShort()
		card_slot.exp = MsgAdapter.ReadInt()
		self.card_slot_list[i] = card_slot
	end
end

-- 魔卡奖励信息
SCMagicCardChouCardResult = SCMagicCardChouCardResult or BaseClass(BaseProtocolStruct)
function SCMagicCardChouCardResult:__init()
	self.msg_type = 6131

	self.all_reward_index_list = {}
end

function SCMagicCardChouCardResult:Decode()
	local reward_list_count = MsgAdapter.ReadShort()

	self.all_reward_index_list = {}
	for i = 1, reward_list_count do
		self.all_reward_index_list[i] = MsgAdapter.ReadChar()
	end
end


-- 跨服神器 ---------------------------------------------------
CSWushangEquipOpearReq = CSWushangEquipOpearReq or BaseClass(BaseProtocolStruct)
function CSWushangEquipOpearReq:__init()
	self.msg_type = 6132

	self.opera_type = 0
	self.reserve_sh = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
end

function CSWushangEquipOpearReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(self.reserve_sh)
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
	MsgAdapter.WriteInt(self.param_3)
end


SCWushangEquipAllInfo = SCWushangEquipAllInfo or BaseClass(BaseProtocolStruct)
function SCWushangEquipAllInfo:__init()
	self.msg_type = 6133

	self.wushang_jifen = 0
	self.equip_id_list = {}
	self.strong_level_list = {}
	self.star_level_list = {}
	self.glory = 0
	self.jy_glory = 0
	self.cross_honor = 0
end

function SCWushangEquipAllInfo:Decode()
	self.wushang_jifen = MsgAdapter.ReadInt()
	self.equip_id_list = {}
	for i = 1, GameEnum.WUSHANGEQUIP_MAX_TYPE_LIMIT do
		self.equip_id_list[i] = MsgAdapter.ReadUShort()
	end
	self.strong_level_list = {}
	for i = 1, GameEnum.WUSHANGEQUIP_MAX_TYPE_LIMIT do
		self.strong_level_list[i] = MsgAdapter.ReadChar()
	end
	self.star_level_list = {}
	for i = 1, GameEnum.WUSHANGEQUIP_MAX_TYPE_LIMIT do
		local list = {}
		list.star_level = MsgAdapter.ReadShort()
		list.jinhua_val = MsgAdapter.ReadShort()
		self.star_level_list[i] = list
	end

	self.glory = MsgAdapter.ReadInt()
	self.jy_glory = MsgAdapter.ReadInt()
	self.cross_honor = MsgAdapter.ReadInt()
end

-- 御魂系统 ---------------------------------------------------------
CSMitamaOperaReq = CSMitamaOperaReq or BaseClass(BaseProtocolStruct)
function CSMitamaOperaReq:__init()
	self.msg_type = 6134

	self.req_type = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
end

function CSMitamaOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteUShort(self.req_type)
	MsgAdapter.WriteUShort(self.param_1)
	MsgAdapter.WriteUShort(self.param_2)
	MsgAdapter.WriteUShort(self.param_3)
end

SCMitamaAllInfo = SCMitamaAllInfo or BaseClass(BaseProtocolStruct)
function SCMitamaAllInfo:__init()
	self.msg_type = 6135

	self.hotspring_score = 0
	self.info_list = {}
end

function SCMitamaAllInfo:Decode()
	self.hotspring_score = MsgAdapter.ReadInt()

	self.info_list = {}
	for i = 1, GameEnum.MITAMA_MAX_MITAMA_COUNT do
		local data = {}
		local spirit_level_list = {}
		data.level = MsgAdapter.ReadChar()
		for j = 1, GameEnum.MITAMA_MAX_SPIRIT_COUNT do
			spirit_level_list[j] = MsgAdapter.ReadChar()
		end
		data.spirit_level_list = spirit_level_list
		data.task_status = MsgAdapter.ReadChar()
		data.task_seq = MsgAdapter.ReadChar()
		data.task_begin_timestamp = MsgAdapter.ReadUInt()
		MsgAdapter.ReadInt()

		self.info_list[i] = data
	end
end

SCMitamaSingleInfo = SCMitamaSingleInfo or BaseClass(BaseProtocolStruct)
function SCMitamaSingleInfo:__init()
	self.msg_type = 6136

	self.seq = 0
	self.info = {}
end

function SCMitamaSingleInfo:Decode()
	self.seq = MsgAdapter.ReadInt()
	self.info = {}

	local spirit_level_list = {}
	self.info.level = MsgAdapter.ReadChar()
	for i = 1, GameEnum.MITAMA_MAX_SPIRIT_COUNT do
		spirit_level_list[i] = MsgAdapter.ReadChar()
	end
	self.info.spirit_level_list = spirit_level_list
	self.info.task_status = MsgAdapter.ReadChar()
	self.info.task_seq = MsgAdapter.ReadChar()
	self.info.task_begin_timestamp = MsgAdapter.ReadUInt()
	MsgAdapter.ReadInt()
end

SCMitamaHotSpringScore = SCMitamaHotSpringScore or BaseClass(BaseProtocolStruct)
function SCMitamaHotSpringScore:__init()
	self.msg_type = 6137

	self.hotspring_score = 0
end

function SCMitamaHotSpringScore:Decode()
	self.hotspring_score = MsgAdapter.ReadInt()
end
-- /御魂系统 --------------------------------------------------------

-----仙树系统-----------
SCFairyTreeAllInfo = SCFairyTreeAllInfo or BaseClass(BaseProtocolStruct)
function SCFairyTreeAllInfo:__init()
	self.msg_type = 6139
	self.cur_gold_can_fetch = 0
	self.cur_coin_can_fetch = 0
	self.online_time_s_for_gift = 0
	self.level = 0
	self.grade = 0
	self.grade_val = 0
	self.funny_farm_score = 0
end

function SCFairyTreeAllInfo:Decode()
	self.cur_gold_can_fetch = MsgAdapter.ReadInt()
	self.cur_coin_can_fetch = MsgAdapter.ReadInt()
	self.online_time_s_for_gift = MsgAdapter.ReadUInt()
	self.level = MsgAdapter.ReadInt()
	self.grade = MsgAdapter.ReadInt()
	self.grade_val = MsgAdapter.ReadInt()
	self.funny_farm_score = MsgAdapter.ReadInt()
end

SCFairyTreeDrawRewardInfo = SCFairyTreeDrawRewardInfo or BaseClass(BaseProtocolStruct)
function SCFairyTreeDrawRewardInfo:__init()
	self.msg_type = 6140
	self.reward_count = 0
	self.reward_seq_list = {}
end

function SCFairyTreeDrawRewardInfo:Decode()
	self.reward_count = MsgAdapter.ReadShort()
	self.reward_seq_list = {}
	for i = 1, self.reward_count do
		self.reward_seq_list[i] = MsgAdapter.ReadShort()
	end
end
