--精灵命魂猎取请求
CSLieMingHunshouOperaReq = CSLieMingHunshouOperaReq or BaseClass(BaseProtocolStruct)
function CSLieMingHunshouOperaReq:__init()
	self.msg_type = 5655
	self.opera_type = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
end

function CSLieMingHunshouOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
	MsgAdapter.WriteInt(self.param_3)
end

--精灵命魂槽信息
SCLieMingInfo = SCLieMingInfo or BaseClass(BaseProtocolStruct)
function SCLieMingInfo:__init()
	self.msg_type = 5656
end

function SCLieMingInfo:Decode()
	self.notify_reason = MsgAdapter.ReadInt()
	self.lieming_list = {}
	for i = 1, GameEnum.LIEMING_SLOT_COUNT do
		local vo = {}
		vo.slot_activity_flag = MsgAdapter.ReadInt()
		vo.slot_list = {}
		for j = 1, GameEnum.LIEMING_FUHUN_SLOT_COUNT do
			local vo2 = {}
			vo2.hunshou_id = MsgAdapter.ReadShort()
			vo2.level = MsgAdapter.ReadShort()
			vo2.exp = MsgAdapter.ReadLL()
			vo.slot_list[j] = vo2
		end
		self.lieming_list[i] = vo
	end
end

--精灵命魂背包信息
SCLieMingBagInfo = SCLieMingBagInfo or BaseClass(BaseProtocolStruct)
function SCLieMingBagInfo:__init()
	self.msg_type = 5657
	self.notify_reason = 0
	self.liehun_pool = {}
	self.grid_list = {}
end

function SCLieMingBagInfo:Decode()
	self.notify_reason = MsgAdapter.ReadInt()
	self.hunshou_exp = MsgAdapter.ReadLL()
	self.liehun_color = MsgAdapter.ReadChar()
	self.daily_has_change_color = MsgAdapter.ReadChar()
	self.daily_has_free_chou = MsgAdapter.ReadShort()
	self.hunli = MsgAdapter.ReadInt()

	self.liehun_pool = {}
	for i = 0, GameEnum.LIEMING_LIEHUN_POOL_MAX_COUNT - 1 do
		local vo = {}
		vo.index = i
		vo.id = MsgAdapter.ReadShort()
		self.liehun_pool[i] = vo
	end

	self.grid_list = {}
	for i = 0, GameEnum.LIEMING_HUNSHOU_BAG_GRID_MAX_COUNT - 1 do
		local item = {}
		item.index = i
		item.id = MsgAdapter.ReadShort()
		item.level = MsgAdapter.ReadShort()
		item.exp = MsgAdapter.ReadLL()
		self.grid_list[i] = item
	end
end

-- 命魂交换请求
CSLieMingExchangeList = CSLieMingExchangeList or BaseClass(BaseProtocolStruct)
function CSLieMingExchangeList:__init()
	self.msg_type = 5658

	self.exchange_count = 0
	self.lieming_idx = 0
	self.exchange_source_index_list = {}	-- 命魂池index
	self.exchange_dest_index_list = {}		-- 命魂槽index
end

function CSLieMingExchangeList:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.exchange_count)

	for i = 1, GameEnum.LIEMING_FUHUN_SLOT_COUNT do
		MsgAdapter.WriteInt(self.lieming_idx or 0)
		MsgAdapter.WriteShort(self.exchange_source_index_list[i] or 0)
		MsgAdapter.WriteShort(self.exchange_dest_index_list[i] or 0)
	end
end

-- 精灵操作请求
CSJingLingOper = CSJingLingOper or BaseClass(BaseProtocolStruct)
function CSJingLingOper:__init()
	self.msg_type = 5670
	self.oper_type = 0
	self.param1 = 0
	self.param2 = 0
	self.param3 = 0
	self.param4 = 0
	self.jingling_name = ""
end

function CSJingLingOper:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.oper_type)
	MsgAdapter.WriteShort(self.param1)
	MsgAdapter.WriteShort(self.param2)
	MsgAdapter.WriteShort(self.param3)
	MsgAdapter.WriteInt(self.param4)
	MsgAdapter.WriteStrN(self.jingling_name, 32)
end

-- 精灵信息
SCJingLingInfo = SCJingLingInfo or BaseClass(BaseProtocolStruct)
function SCJingLingInfo:__init()
	self.msg_type = 5671
	self.jingling_name = ""
end

function SCJingLingInfo:Decode()
	self.jinglingcard_list = {}
	for i = 0, GameEnum.JINGLING_CARD_MAX_TYPE - 1 do
		local card_obj = {}
		card_obj.level = MsgAdapter.ReadShort()
		MsgAdapter.ReadShort()
		card_obj.exp = MsgAdapter.ReadInt()
		self.jinglingcard_list[i] = card_obj
	end

	self.shuxingdan_list = {}
	for i = 0, GameEnum.SHUXINGDAN_MAX_TYPE - 1 do
		self.shuxingdan_list[i] = MsgAdapter.ReadInt()
	end

	self.equip_strength_list = {}
	for i = 0, GameEnum.JINGLING_EQUIP_MAX_PART - 1 do
		local equip_vo = {}
		equip_vo.index = i
		equip_vo.level = MsgAdapter.ReadShort()
		self.equip_strength_list[i] = equip_vo
	end

	self.jingling_name = MsgAdapter.ReadStrN(32)
	self.use_jingling_id = MsgAdapter.ReadUShort()
	self.use_imageid = MsgAdapter.ReadShort()
	self.m_active_image_flag = MsgAdapter.ReadInt()
	self.grade = MsgAdapter.ReadInt()
	self.grade_bless = MsgAdapter.ReadInt()

	self.phantom_level_list = {}
	for i = 0, GameEnum.JINGLING_PTHANTOM_MAX_TYPE - 1 do
		self.phantom_level_list[i] = MsgAdapter.ReadShort()
	end

	self.special_img_active_flag = MsgAdapter.ReadInt()
	self.phantom_imageid = MsgAdapter.ReadInt()

	self.soul_level_list = {}
	for i = 0, GameEnum.JINGLING_CARD_MAX_TYPE -1 do
		self.soul_level_list[i] = MsgAdapter.ReadShort()
	end

	self.taozhuang_level = MsgAdapter.ReadInt()

	self.phantom_level_list_new = {}
	for i = 0, GameEnum.JINGLING_PTHANTOM_MAX_TYPE_NEW - 1 do
		self.phantom_level_list_new[i] = MsgAdapter.ReadShort()
	end

	self.halo_data = {}
	self.halo_data.halo_active_image_flag = MsgAdapter.ReadInt()			--光环激活的云形象列表
	self.halo_data.halo_level = MsgAdapter.ReadShort()						--光环等级
	self.halo_data.halo_use_imageid = MsgAdapter.ReadShort()				--光环当前使用的形象
	self.halo_data.halo_bless_val = MsgAdapter.ReadInt()					--光环祝福值

	self.jingling_list = {}
	self.count = MsgAdapter.ReadInt()
	for i = 1, self.count do
		local index = MsgAdapter.ReadInt()
		local equip_data = ProtocolStruct.ReadItemDataWrapper()
		equip_data.index = index
		self.jingling_list[index] = equip_data
	end
end

-- 精灵形象改变广播
SCJingLingViewChange = SCJingLingViewChange or BaseClass(BaseProtocolStruct)
function SCJingLingViewChange:__init()
	self.msg_type = 5672
	self.jingling_name = ""
end

function SCJingLingViewChange:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.jingling_id = MsgAdapter.ReadUShort()
	self.level = MsgAdapter.ReadShort()
	self.use_sprite_imageid = MsgAdapter.ReadShort()
	self.jingling_name = MsgAdapter.ReadStrN(32)
	self.user_pet_special_img = MsgAdapter.ReadInt()
	self.use_xiannv_halo_img = MsgAdapter.ReadShort()
end

-- 声望操作请求
CSShengWangOpera = CSShengWangOpera or BaseClass(BaseProtocolStruct)
function CSShengWangOpera:__init()
	self.msg_type = 5675
	self.oper_type = 0
	self.param1 = 0
end

function CSShengWangOpera:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(self.param1)
end

-- 声望信息
SCShengWangInfo = SCShengWangInfo or BaseClass(BaseProtocolStruct)
function SCShengWangInfo:__init()
	self.msg_type = 5676
end

function SCShengWangInfo:Decode()
	self.xianjie_level = MsgAdapter.ReadShort()
	self.xiandan_level = MsgAdapter.ReadShort()
	self.process_times = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.need_gold_on_uplevel_next_xiandan = MsgAdapter.ReadInt()

	self.shuxingdan_list = {}
	for i = 0, GameEnum.SHUXINGDAN_MAX_TYPE - 1 do
		self.shuxingdan_list[i] = MsgAdapter.ReadInt()
	end
end

-- 声阶改变
SCXianJieViewChange = SCXianJieViewChange or BaseClass(BaseProtocolStruct)
function SCXianJieViewChange:__init()
	self.msg_type = 5677
end

function SCXianJieViewChange:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.xianjie_level = MsgAdapter.ReadShort()
end

-- 成就操作请求
CSChengJiuOpera = CSChengJiuOpera or BaseClass(BaseProtocolStruct)
function CSChengJiuOpera:__init()
	self.msg_type = 5680
	self.oper_type = 0
	self.param1 = 0
end

function CSChengJiuOpera:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(self.param1)
end

-- 成就信息
SCChengJiuInfo = SCChengJiuInfo or BaseClass(BaseProtocolStruct)
function SCChengJiuInfo:__init()
	self.msg_type = 5681

	self.reward_list = {}
end

function SCChengJiuInfo:Decode()
	self.title_level = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()

	self.fuwen_level = MsgAdapter.ReadShort()
	self.fuwen_process_times = MsgAdapter.ReadShort()
	self.need_gold_on_uplevel_next_fuwen = MsgAdapter.ReadInt()

	self.shuxingdan_list = {}
	for i = 0, GameEnum.SHUXINGDAN_MAX_TYPE - 1 do
		self.shuxingdan_list[i] = MsgAdapter.ReadInt()
	end

	MsgAdapter.ReadShort()

	self.reward_list = {}
	local count = MsgAdapter.ReadShort()
	for i=1,count do
		local reward_obj = {}
		reward_obj.reward_id = MsgAdapter.ReadShort()
		reward_obj.flag = MsgAdapter.ReadChar()
		MsgAdapter.ReadChar()
		reward_obj.process = MsgAdapter.ReadUInt()
		self.reward_list[reward_obj.reward_id] = reward_obj
	end
end

-- 成就称号改变
SCChengJiuTitleViewChange = SCChengJiuTitleViewChange or BaseClass(BaseProtocolStruct)
function SCChengJiuTitleViewChange:__init()
	self.msg_type = 5682
end

function SCChengJiuTitleViewChange:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.title_level = MsgAdapter.ReadShort()
end

-- 成就有变化时下发
SCChengJiuRewardChange = SCChengJiuRewardChange or BaseClass(BaseProtocolStruct)
function SCChengJiuRewardChange:__init()
	self.msg_type = 5683

	self.reward_list = {}
end

function SCChengJiuRewardChange:Decode()
	self.reward_list = {}
	MsgAdapter.ReadShort()
	local count = MsgAdapter.ReadShort()

	for i=1,count do
		local reward_obj = {}
		reward_obj.reward_id = MsgAdapter.ReadShort()
		reward_obj.flag = MsgAdapter.ReadChar()
		MsgAdapter.ReadChar()
		reward_obj.process = MsgAdapter.ReadUInt()
		self.reward_list[reward_obj.reward_id] = reward_obj
	end
end

-- 成就信息
SCChengJiuRewardInfo = SCChengJiuRewardInfo or BaseClass(BaseProtocolStruct)
function SCChengJiuRewardInfo:__init()
	self.msg_type = 5691

	self.reward_id = 0
	self.reserve_sh = 0
end

function SCChengJiuRewardInfo:Decode()
	self.reward_id = MsgAdapter.ReadShort()
	self.reserve_sh = MsgAdapter.ReadShort()
end

--单个装备猎命
SCLieMingSingleEquipInfo = SCLieMingSingleEquipInfo or BaseClass(BaseProtocolStruct)
function SCLieMingSingleEquipInfo:__init()
	self.msg_type = 5695
end

function SCLieMingSingleEquipInfo:Decode()
	self.equip_index = MsgAdapter.ReadInt()
	self.notify_reason = MsgAdapter.ReadInt()
	self.slot_activity_flag = MsgAdapter.ReadInt()
	self.slot_list = {}
	for i = 1, GameEnum.LIEMING_FUHUN_SLOT_COUNT do
		local vo = {}
		vo.hunshou_id = MsgAdapter.ReadShort()
		vo.level = MsgAdapter.ReadShort()
		vo.exp = MsgAdapter.ReadLL()
		self.slot_list[i] = vo
	end
end


--魂器操作请求
CSSHenzhouWeaponOperaReq = CSSHenzhouWeaponOperaReq or BaseClass(BaseProtocolStruct)
function CSSHenzhouWeaponOperaReq:__init()
	self.msg_type = 5684

	self.opera_type = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
	self.param_4 = 0
	self.param_5 = 0
end

function CSSHenzhouWeaponOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(0)
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
	MsgAdapter.WriteInt(self.param_3)
	MsgAdapter.WriteInt(self.param_4)
	MsgAdapter.WriteInt(self.param_5)
end

CSCardzuOperaReq = CSCardzuOperaReq or BaseClass(BaseProtocolStruct)
function CSCardzuOperaReq:__init()
	self.msg_type = 5650

	self.opera_type = 0
	self.reserve_sh = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
end
function CSCardzuOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(self.reserve_sh)
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
	MsgAdapter.WriteInt(self.param_3)
end

--卡牌组合
SCCardzuAllInfo = SCCardzuAllInfo or BaseClass(BaseProtocolStruct)

function SCCardzuAllInfo:__init()
	self.msg_type = 5600

	self.today_coin_buy_card_times = {}
	self.today_gold_bind_buy_card_times = {}
	self.all_card_count_list = {}
	self.all_zuhe_level_list = {}
end

function SCCardzuAllInfo:Decode()
	self.lingli = MsgAdapter.ReadInt()
	for i = 0, GameEnum.CARDZU_TYPE_MAX_COUNT - 1 do
		self.today_coin_buy_card_times[i] = MsgAdapter.ReadChar()
	end

	for i = 0, GameEnum.CARDZU_TYPE_MAX_COUNT - 1 do
		self.today_gold_bind_buy_card_times[i] = MsgAdapter.ReadChar()
	end

	self.all_card_count_list = {}
	for i = 0, GameEnum.CARDZU_MAX_CARD_ID do
		self.all_card_count_list[i] = MsgAdapter.ReadShort()
	end

	self.all_zuhe_level_list = {}
	for i = 0, GameEnum.CARDZU_MAX_ZUHE_ID do
		self.all_zuhe_level_list[i] = MsgAdapter.ReadShort()
	end

end

--卡组信息增量更新
SCCardzuChangeNotify = SCCardzuChangeNotify or BaseClass(BaseProtocolStruct)

function SCCardzuChangeNotify:__init()
	self.msg_type = 5601
end

function SCCardzuChangeNotify:Decode()
	self.lingli = MsgAdapter.ReadInt()
	self.today_coin_buy_card_times = {}
	self.today_gold_bind_buy_card_times = {}
	for i = 0, GameEnum.CARDZU_TYPE_MAX_COUNT - 1 do
		self.today_coin_buy_card_times[i] = MsgAdapter.ReadChar()
	end
	for i = 0, GameEnum.CARDZU_TYPE_MAX_COUNT - 1 do
		self.today_gold_bind_buy_card_times[i] = MsgAdapter.ReadChar()
	end

	self.change_zuhe_id = MsgAdapter.ReadShort()
	self.change_zuhe_level = MsgAdapter.ReadShort()
	self.change_card_count = MsgAdapter.ReadInt()
	self.change_card_list = {}
	for i = 1, self.change_card_count do
		self.change_card_list[i] = {}
		self.change_card_list[i].card_id = MsgAdapter.ReadShort()
		self.change_card_list[i].count = MsgAdapter.ReadShort()
	end
end

-- 抽卡结果统一通知
SCCardzuChouCardResult = SCCardzuChouCardResult or BaseClass(BaseProtocolStruct)

function SCCardzuChouCardResult:__init()
	self.msg_type = 5602
	self.all_card_count_list = {}
end

function SCCardzuChouCardResult:Decode()
	for i = 0, CARDZU_BATCH_CHOUCARD_TIMES - 1 do
		self.all_card_count_list[i] = MsgAdapter.ReadShort()
	end
end

-- 牧场精灵 ------------------------------------------------------------
CSPastureSpiritOperaReq = CSPastureSpiritOperaReq or BaseClass(BaseProtocolStruct)
function CSPastureSpiritOperaReq:__init()
	self.msg_type = 5685

	self.req_type = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
end

function CSPastureSpiritOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteUShort(self.req_type)
	MsgAdapter.WriteUShort(self.param_1)
	MsgAdapter.WriteUShort(self.param_2)
	MsgAdapter.WriteUShort(self.param_3)
end

-- 双人坐骑操作请求
CSMultiMountOperaReq = CSMultiMountOperaReq or BaseClass(BaseProtocolStruct)
function CSMultiMountOperaReq:__init()
	self.msg_type = 5686

	self.opera_type = 0
	self.reserve_sh = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
end

function CSMultiMountOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(self.reserve_sh)
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
	MsgAdapter.WriteInt(self.param_3)
end

-- 气泡框操作请求
CSPersonalizeWindowOperaReq = CSPersonalizeWindowOperaReq or BaseClass(BaseProtocolStruct)
function CSPersonalizeWindowOperaReq:__init()
	self.msg_type = 5687

	self.req_type = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
end

function CSPersonalizeWindowOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.req_type)
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
	MsgAdapter.WriteInt(self.param_3)
end

-- 个性化窗口 ------------------------------------------------------------
CSPersonalizeWindowOperaReq = CSPersonalizeWindowOperaReq or BaseClass(BaseProtocolStruct)
function CSPersonalizeWindowOperaReq:__init()
	self.msg_type = 5687

	self.req_type = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
end

function CSPersonalizeWindowOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.req_type)
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
	MsgAdapter.WriteInt(self.param_3)
end

---魔卡请求--------------------------------------------------------------------------
CSMagicCardOperaReq = CSMagicCardOperaReq or BaseClass(BaseProtocolStruct)
function CSMagicCardOperaReq:__init()
	self.msg_type = 5688

	self.opera_type = 0
	self.reserve = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
	self.param_4 = 0
end

function CSMagicCardOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(self.reserve)
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
	MsgAdapter.WriteInt(self.param_3)
	MsgAdapter.WriteInt(self.param_4)
end

CSFairyTreeOperaReq = CSFairyTreeOperaReq or BaseClass(BaseProtocolStruct)
function CSFairyTreeOperaReq:__init()
	self.msg_type = 5689

	self.req_type = 0
	self.param_1 = 0

end

function CSFairyTreeOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteUShort(self.req_type)
	MsgAdapter.WriteUShort(self.param_1)
end

----------------------------魂器------------------------------------
SCShenzhouBoxInfo = SCShenzhouBoxInfo or BaseClass(BaseProtocolStruct)
function SCShenzhouBoxInfo:__init()
	self.msg_type = 5692
end

function SCShenzhouBoxInfo:Decode()
	self.box_id = MsgAdapter.ReadInt()								--宝箱id
	self.today_open_box_num = MsgAdapter.ReadInt()					--今天开启的宝箱次数
	self.today_help_box_num = MsgAdapter.ReadInt()					--今天协助次数
	self.box_help_uid_list = {}
	for i = 1, HunQiData.SHENZHOU_WEAPON_BOX_HELP_MAX_CONUT do
		self.box_help_uid_list[i] = MsgAdapter.ReadInt()			--协助者的uid
	end
end

--一键鉴定
CSSHenzhouWeaponOneKeyIdentifyReq = CSSHenzhouWeaponOneKeyIdentifyReq or BaseClass(BaseProtocolStruct)
function CSSHenzhouWeaponOneKeyIdentifyReq:__init()
	self.msg_type = 5693
end

function CSSHenzhouWeaponOneKeyIdentifyReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--魂印分解
CSShenzhouHunyinResolveReq = CSShenzhouHunyinResolveReq or BaseClass(BaseProtocolStruct)
function CSShenzhouHunyinResolveReq:__init()
	self.msg_type = 5694
	self.index_count = 0
	self.index_in_bag_list = {}
end

function CSShenzhouHunyinResolveReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	
	MsgAdapter.WriteInt(self.index_count)
	for i,v in ipairs(self.index_in_bag_list) do
	 	MsgAdapter.WriteShort(v)
	end
end

---------------------------形象技能------------------------------
--形象技能信息
SCImageSkillInfo = SCImageSkillInfo or BaseClass(BaseProtocolStruct)
function SCImageSkillInfo:__init()
	self.msg_type = 5696
	self.image_skills = {}
	self.skill_storage_list = {}
	self.skill_refresh_item_list= {}
end

function SCImageSkillInfo:Decode()
	self.image_skills = {}
	for i = 1, GameEnum.IMAGE_SYSTEM_MAX do
			self.image_skills[i] = {}
		for j = 1, GameEnum.JING_LING_SKILL_COUNT_MAX do
			local data = {}
			data.skill_id = MsgAdapter.ReadShort()
			data.can_move = MsgAdapter.ReadChar()
			data.index = j - 1
			MsgAdapter.ReadChar()
			self.image_skills[i][j] = data
		end
	end

	self.skill_storage_list = {}
	for i = 1, GameEnum.JING_LING_SKILL_STORAGE_MAX do
		local data = {}
		data.skill_id = MsgAdapter.ReadShort()
		data.can_move = MsgAdapter.ReadChar()
		data.index = i - 1
		MsgAdapter.ReadChar()
		self.skill_storage_list[i] = data
	end

	self.skill_refresh_item_list = {}
	for i = 1, GameEnum.JING_LING_SKILL_REFRESH_ITEM_MAX do
		local data = {}
		data.refresh_count = MsgAdapter.ReadInt()
		data.is_active = MsgAdapter.ReadShort()
		data.skill_list = {}
		for j = 1, GameEnum.JING_LING_SKILL_REFRESH_SKILL_MAX do
			data.skill_list[j] = MsgAdapter.ReadShort()
		end

		self.skill_refresh_item_list[i] = data
	end
end
---------------------------形象技能  END------------------------------