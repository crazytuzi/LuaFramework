--精灵命魂猎取请求
CSLieMingHunshouOperaReq = CSLieMingHunshouOperaReq or BaseClass(BaseProtocolStruct)
function CSLieMingHunshouOperaReq:__init()
	self.msg_type = 5655
	self.opera_type = 0
	self.param_1 = 0
	self.param_2 = 0
end

function CSLieMingHunshouOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(0)
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
end

--精灵命魂槽信息
SCLieMingSlotInfo = SCLieMingSlotInfo or BaseClass(BaseProtocolStruct)
function SCLieMingSlotInfo:__init()
	self.msg_type = 5656
	self.notify_reason = 0
	self.slot_list = {}
end

function SCLieMingSlotInfo:Decode()
	self.notify_reason = MsgAdapter.ReadInt()
	self.slot_activity_flag = MsgAdapter.ReadInt()
	self.slot_list = {}
	for i = 0, GameEnum.LIEMING_FUHUN_SLOT_COUNT - 1 do
		local item = {}
		item.index = i
		item.id = MsgAdapter.ReadShort()
		item.level = MsgAdapter.ReadShort()
		item.exp = MsgAdapter.ReadLL()
		self.slot_list[i] = item
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
	MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
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
	self.exchange_source_index_list = {}	-- 命魂池index
	self.exchange_dest_index_list = {}		-- 命魂槽index
end

function CSLieMingExchangeList:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.exchange_count)

	for i = 1, GameEnum.LIEMING_FUHUN_SLOT_COUNT do
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
	for i = 1, GameEnum.JINGLING_PTHANTOM_MAX_TYPE do
		table.insert(self.phantom_level_list, MsgAdapter.ReadShort())
	end

	self.special_img_active_flag_low = MsgAdapter.ReadUInt()
	self.special_img_active_flag_high = MsgAdapter.ReadUInt()
	self.phantom_imageid = MsgAdapter.ReadInt()

	self.soul_level_list = {}
	for i = 0, GameEnum.JINGLING_CARD_MAX_TYPE -1 do
		self.soul_level_list[i] = MsgAdapter.ReadShort()
	end

	self.taozhuang_level = MsgAdapter.ReadInt()

	for i = 1, GameEnum.JINGLING_PTHANTOM_MAX_TYPE_NEW do
		table.insert(self.phantom_level_list, MsgAdapter.ReadShort())
	end

	for i = 1, GameEnum.JINGLING_PTHANTOM_MAX_TYPE_NEW_2 do
		table.insert(self.phantom_level_list, MsgAdapter.ReadShort())
	end

	self.halo_data = {}
	self.halo_data.halo_active_image_flag = MsgAdapter.ReadInt()			--光环激活的云形象列表
	self.halo_data.halo_level = MsgAdapter.ReadShort()						--光环等级
	self.halo_data.halo_use_imageid = MsgAdapter.ReadShort()				--光环当前使用的形象
	self.halo_data.halo_bless_val = MsgAdapter.ReadInt()					--光环祝福值

	self.xianzhen_level = MsgAdapter.ReadInt()
	self.xianzhen_exp = MsgAdapter.ReadInt()
	self.xianzhen_up_count = MsgAdapter.ReadInt()
	self.hunyu_level_list = {}
	for i = 0, GameEnum.XIAN_ZHEN_HUN_YU_TYPE_MAX - 1 do
		self.hunyu_level_list[i] = MsgAdapter.ReadInt()
	end
	self.skill_storage_list = {}
	for i = 0, 49 do
		local skill_t = {}
		skill_t.skill_id = MsgAdapter.ReadShort()
		skill_t.can_move = MsgAdapter.ReadChar()
		skill_t.reserved = MsgAdapter.ReadChar()
		skill_t.index = i
		self.skill_storage_list[i] = skill_t
	end

	self.skill_refresh_item_list = {}
	for i = 0, GameEnum.JING_LING_SKILL_REFRESH_ITEM_MAX - 1 do
		local item_t = {}
		item_t.refresh_count = MsgAdapter.ReadInt()
		item_t.is_active = MsgAdapter.ReadShort()
		item_t.skill_list = {}
		for k = 0, GameEnum.JING_LING_SKILL_REFRESH_SKILL_MAX - 1 do
			item_t.skill_list[k] = MsgAdapter.ReadShort()
		end
		self.skill_refresh_item_list[i] = item_t
	end

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
	self.box_id = MsgAdapter.ReadInt()									--宝箱id
	self.today_open_free_box_times = MsgAdapter.ReadInt()				--今天免费开启的宝箱次数
	self.last_open_free_box_timestamp = MsgAdapter.ReadInt()			--今天最后免费开启宝箱的时间
	self.today_help_box_num = MsgAdapter.ReadInt()						--今天协助次数
	self.box_help_uid_list = {}
	for i = 1, HunQiData.SHENZHOU_WEAPON_BOX_HELP_MAX_CONUT do
		self.box_help_uid_list[i] = MsgAdapter.ReadInt()				--协助者的uid
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

-- 特殊魂印信息
SCShenzhouSpecialHunyinInfo = SCShenzhouSpecialHunyinInfo or BaseClass(BaseProtocolStruct)
function SCShenzhouSpecialHunyinInfo:__init()
	self.msg_type = 5699
end

function SCShenzhouSpecialHunyinInfo:Decode()
	self.special_hunyin_slot = {}
	for i = 1, HunQiData.SHENZHOU_WEAPON_COUNT do
		self.special_hunyin_slot[i] = {}
		for j = 1, HunQiData.SPECIAL_SHENZHOU_WEAPON_SLOT_COUNT_SERVER do
			temp_list = {}
			temp_list.lingshu_level = MsgAdapter.ReadInt()			-- 灵枢等级（无用， 特殊魂印暂时没有升级灵枢操作）
			temp_list.hunyin_id = MsgAdapter.ReadUShort()			-- 魂印id，实际上为道具id
			temp_list.is_bind = MsgAdapter.ReadChar()				-- 是否绑定
			temp_list.reservel = MsgAdapter.ReadChar()
			self.special_hunyin_slot[i][j] = temp_list
		end
	end
end

------------精灵家园-------------------------------------------------
--精灵操作请求
CSJingLingHomeOperReq = CSJingLingHomeOperReq or BaseClass(BaseProtocolStruct)
function CSJingLingHomeOperReq:__init()
	self.msg_type = 5695
	self.oper_type = 0
	self.role_id = 0
	self.param1 = 0
	self.param2 = 0
end

function CSJingLingHomeOperReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.oper_type)
	MsgAdapter.WriteInt(self.role_id)
	MsgAdapter.WriteShort(self.param1)
	MsgAdapter.WriteShort(self.param2)
end

--精灵家园信息
SCJingLingHomeInfo = SCJingLingHomeInfo or BaseClass(BaseProtocolStruct)
function SCJingLingHomeInfo:__init()
	self.msg_type = 5696
	self.reason = 0
	self.rob_times_of_me = 0
	self.role_id = 0
	self.name = ""
	self.item_list = {}
end

function SCJingLingHomeInfo:Decode()
	self.reason = MsgAdapter.ReadShort()
	self.rob_times_of_me = MsgAdapter.ReadShort()
	self.role_id = MsgAdapter.ReadInt()
	self.name = MsgAdapter.ReadStrN(32)

	self.item_list = {}
	for i = 1, GameEnum.JINGLING_MAX_TAKEON_NUM do
		local data = {}
		data.item_id = MsgAdapter.ReadUShort()
		data.reward_times = MsgAdapter.ReadUShort()    -- 奖励放入箱子次数
		data.capability = MsgAdapter.ReadInt()
		data.reward_beging_time = MsgAdapter.ReadUInt() -- 当前奖励时间，+上配置表的间隔来显示倒计时
		data.last_get_time = MsgAdapter.ReadUInt()    -- 上次领取奖励的时间
		data.reward_lingjing = MsgAdapter.ReadInt()
		data.reward_hunli = MsgAdapter.ReadInt()
		data.reward_item_list = {}
		for i = 1, GameEnum.JING_LING_HOME_REWARD_ITEM_MAX do
			local item_data = {}
			item_data.item_id = MsgAdapter.ReadUShort()
			item_data.item_num = MsgAdapter.ReadShort()
			table.insert(data.reward_item_list, item_data)
		end

		self.item_list[i] = data
	end
end

--列表信息
SCJingLingHomeListInfo = SCJingLingHomeListInfo or BaseClass(BaseProtocolStruct)
function SCJingLingHomeListInfo:__init()
	self.msg_type = 5697
	self.info_count = 0
	self.info_list = {}
end

function SCJingLingHomeListInfo:Decode()
	self.info_count = MsgAdapter.ReadInt()

	self.info_list = {}
	for i = 1, self.info_count do
		local data = {}
		data.role_id = MsgAdapter.ReadInt()
		data.prof = MsgAdapter.ReadChar()
		data.sex = MsgAdapter.ReadChar()
		data.camp = MsgAdapter.ReadChar()
		data.vip_level = MsgAdapter.ReadChar()
		data.avatar_key_big = MsgAdapter.ReadUInt()
		data.avatar_key_small = MsgAdapter.ReadUInt()
		data.name = MsgAdapter.ReadStrN(32)
		self.info_list[i] = data
	end
end

--掠夺记录
SCJingLingHomeRobRecord = SCJingLingHomeRobRecord or BaseClass(BaseProtocolStruct)
function SCJingLingHomeRobRecord:__init()
	self.msg_type = 5698
	self.read_rob_record_time = 0
	self.record_count = 0
	self.rob_record_list = {}
end

function SCJingLingHomeRobRecord:Decode()
	self.read_rob_record_time = MsgAdapter.ReadUInt()
	self.record_count = MsgAdapter.ReadInt()

	self.rob_record_list = {}
	for i = 1, self.record_count do
		local data = {}
		data.role_id = MsgAdapter.ReadInt()
		data.name = MsgAdapter.ReadStrN(32)
		data.rob_time = MsgAdapter.ReadUInt()
		self.rob_record_list[i] = data
	end
end


----------------精灵探险----------------------
--精灵探险操作请求
CSJinglIngExploreOperReq = CSJinglIngExploreOperReq or BaseClass(BaseProtocolStruct)
function CSJinglIngExploreOperReq:__init()
	self.msg_type = 5603
	self.oper_type = 0
	self.param1 = 0
	self.param2 = 0
end

function CSJinglIngExploreOperReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.oper_type)
	MsgAdapter.WriteShort(self.param1)
	MsgAdapter.WriteShort(self.param2)
end

--精灵探险信息
SCJinglIngExploreInfo = SCJinglIngExploreInfo or BaseClass(BaseProtocolStruct)
function SCJinglIngExploreInfo:__init()
	self.msg_type = 5604
	self.reason = 0
	self.explore_mode = 0		-- 探险模式
	self.explore_maxhp = 0		-- 最大血量
	self.explore_hp = 0 		-- 当前血量
	self.buy_buff_count = 0
	self.explore_info_list = {}
end

function SCJinglIngExploreInfo:Decode()
	self.reason = MsgAdapter.ReadShort()
	self.explore_mode = MsgAdapter.ReadShort()
	self.explore_maxhp = MsgAdapter.ReadInt()
	self.explore_hp = MsgAdapter.ReadInt()
	self.buy_buff_count = MsgAdapter.ReadInt()

	self.explore_info_list = {}
	for i = 1, GameEnum.JING_LING_EXPLORE_LEVEL_COUNT do
		local data = {}
		data.capability = MsgAdapter.ReadInt()
		data.hp = MsgAdapter.ReadInt()
		data.jingling_id = MsgAdapter.ReadUShort()
		data.name_id = MsgAdapter.ReadShort()  -- 服务端随机起的名字，对应配置表里的
		data.reward_times = MsgAdapter.ReadShort()
		MsgAdapter.ReadShort()

		self.explore_info_list[i] = data
	end
end

--精灵家园掠夺结果
SCJingLingHomeRobAck = SCJingLingHomeRobAck or BaseClass(BaseProtocolStruct)
function SCJingLingHomeRobAck:__init()
	self.msg_type = 5605
	self.role_id = 0
	self.rob_lingjing = 0
	self.rob_hunli = 0
	self.is_win = 0
	self.item_count = 0
	self.item_list = {}
end

function SCJingLingHomeRobAck:Decode()
	self.role_id = MsgAdapter.ReadInt()
	self.rob_lingjing = MsgAdapter.ReadInt()
	self.rob_hunli = MsgAdapter.ReadInt()
	self.is_win = MsgAdapter.ReadShort()
	self.item_count = MsgAdapter.ReadShort()

	self.item_list = {}
	for i = 1, self.item_count do
		local data = {}
		data.item_id = MsgAdapter.ReadUShort()
		data.item_num = MsgAdapter.ReadShort()
		self.item_list[i] = data
	end
end

--精灵奇遇信息
SCJingLingAdvantageInfo = SCJingLingAdvantageInfo or BaseClass(BaseProtocolStruct)
function SCJingLingAdvantageInfo:__init()
	self.msg_type = 5606
	self.pos_list = {}
end

function SCJingLingAdvantageInfo:Decode()
	self.pos_list = {}
	for i = 1, GameEnum.SPIRIT_MEET_SCENE_COUNT do
		self.pos_list[i] = {}
		self.pos_list[i].scene_id = MsgAdapter.ReadInt()
		self.pos_list[i].purple_count = MsgAdapter.ReadShort()
		self.pos_list[i].blue_count = MsgAdapter.ReadShort()
	end
end

SCJingLingAdvantageCount = SCJingLingAdvantageCount or BaseClass(BaseProtocolStruct)
function SCJingLingAdvantageCount:__init()
	self.msg_type = 5607
	self.today_gather_blue_jingling_count = 0      --今天获得的蓝色精灵数量
end

function SCJingLingAdvantageCount:Decode()
	self.today_gather_blue_jingling_count = MsgAdapter.ReadInt()
end

----------------------精灵奇遇boss----------------------
--刷新奇遇boss信息
SCJingLingAdvantageBossInfo = SCJingLingAdvantageBossInfo or BaseClass(BaseProtocolStruct)
function SCJingLingAdvantageBossInfo:__init()
	self.msg_type = 5608
	self.boss_id = 0      --boss_id
end

function SCJingLingAdvantageBossInfo:Decode()
	self.boss_id = MsgAdapter.ReadInt()
end

--飞至奇遇boss请求
CSJingLingAdvantageBossEnter = CSJingLingAdvantageBossEnter or BaseClass(BaseProtocolStruct)
function CSJingLingAdvantageBossEnter:__init()
	self.msg_type = 5609
	self.enter_bossid = 0
	self.param1 = 0
end

function CSJingLingAdvantageBossEnter:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.enter_bossid)
	MsgAdapter.WriteShort(self.param1)
end
----------------------特殊精灵操作----------------------
SCSpecialJingLingInfo = SCSpecialJingLingInfo or BaseClass(BaseProtocolStruct)
function SCSpecialJingLingInfo:__init()
	self.msg_type = 5610
	self.special_jingling_flag = 0
	self.active_jingling_timestamp = 0
	self.special_jingling_fetch_flag = 0
end

function SCSpecialJingLingInfo:Decode()
	self.special_jingling_flag = MsgAdapter.ReadUInt()                      --是否可领取
	self.special_jingling_fetch_flag = MsgAdapter.ReadUInt()                --是否领取
	self.active_jingling_timestamp = MsgAdapter.ReadUInt()               

end
