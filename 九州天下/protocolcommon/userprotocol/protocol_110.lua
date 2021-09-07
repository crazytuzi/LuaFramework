SCHuguozhiliInfo = SCHuguozhiliInfo or BaseClass(BaseProtocolStruct)
function SCHuguozhiliInfo:__init()
	self.msg_type = 11000
end

function SCHuguozhiliInfo:Decode()
	self.today_die_times = MsgAdapter.ReadInt()
	self.active_huguozhili_timestamp = MsgAdapter.ReadUInt()
	self.today_active_times = MsgAdapter.ReadInt()
end

CSHuguozhiliReq = CSHuguozhiliReq or BaseClass(BaseProtocolStruct)
function CSHuguozhiliReq:__init()
	self.msg_type = 11001
	self.req_type = 0
	self.param1 = 0
	self.param2 = 0
end

function CSHuguozhiliReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.req_type)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
end

-- 单个据点信息
SCCrossXYJDJudianInfo = SCCrossXYJDJudianInfo or BaseClass(BaseProtocolStruct)
function SCCrossXYJDJudianInfo:__init()
	self.msg_type = 11010
end

function SCCrossXYJDJudianInfo:Decode()   
	self.id = MsgAdapter.ReadInt()
	self.is_zhanling = MsgAdapter.ReadInt()
	self.progress = MsgAdapter.ReadInt()
end

CSCrossXYCityReq = CSCrossXYCityReq or BaseClass(BaseProtocolStruct)
function CSCrossXYCityReq:__init()
	self.msg_type = 11015
	self.opera_type = 0
    self.param1 = 0
    self.param2 = 0
end

function CSCrossXYCityReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opera_type)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
end

SCCrossXYCityFBInfo = SCCrossXYCityFBInfo or BaseClass(BaseProtocolStruct)
function SCCrossXYCityFBInfo:__init()
	self.msg_type = 11016
end

function SCCrossXYCityFBInfo:Decode()
	self.is_midao_fb_open = {}
	for i = 1, SERVER_GROUP_TYPE.SERVER_GROUP_TYPE_MAX do
		self.is_midao_fb_open[i] = MsgAdapter.ReadInt()	-- 己方的密道是否开启
	end
end

SCQiyuShopAllInfo = SCQiyuShopAllInfo or BaseClass(BaseProtocolStruct)
function SCQiyuShopAllInfo:__init()
	self.msg_type = 11020
	self.open_left_times = 0
	self.histroy_chongzhi = 0
	self.has_fetch = 0
	self.open_times = 0
	self.can_fetch = 0
	self.reward_index = -1
	self.ra_qiyushop_has_open_view = 1
end

function SCQiyuShopAllInfo:Decode()
	self.open_left_times = MsgAdapter.ReadInt()
	self.histroy_chongzhi = MsgAdapter.ReadInt()
	self.has_fetch = MsgAdapter.ReadChar()
	self.open_times = MsgAdapter.ReadChar()
	self.can_fetch = MsgAdapter.ReadChar()
	self.reward_index = MsgAdapter.ReadChar()
	self.ra_qiyushop_has_open_view = MsgAdapter.ReadInt()
end

CSQiyuShopReq = CSQiyuShopReq or BaseClass(BaseProtocolStruct)
function CSQiyuShopReq:__init()
	self.msg_type = 11021
	self.opera_type = 0
    self.param1 = 0
end

function CSQiyuShopReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(self.param1)
end

--upgrade system req
CSUgsHeadwearReq = CSUgsHeadwearReq or BaseClass(BaseProtocolStruct)
function CSUgsHeadwearReq:__init()
	self.msg_type = 11030
	self.req_type = 0
	self.param1 = 0
	self.param2 = 0
	self.param3 = 0
end

function CSUgsHeadwearReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.req_type)
	MsgAdapter.WriteShort(self.param1)
	MsgAdapter.WriteShort(self.param2)
	MsgAdapter.WriteShort(self.param3)
end

--头饰信息
SCHeadwearInfo =  SCHeadwearInfo or BaseClass(BaseProtocolStruct)
function SCHeadwearInfo:__init()
	self.msg_type = 11031
end

function SCHeadwearInfo:Decode()
	self.star_level = MsgAdapter.ReadShort()
	self.headwear_level = MsgAdapter.ReadShort()
	self.grade = MsgAdapter.ReadShort()
	self.used_imageid = MsgAdapter.ReadShort()
	self.grade_bless_val = MsgAdapter.ReadInt()		-- 祝福值
	self.shuxingdan_count = MsgAdapter.ReadShort()
	self.chengzhangdan_count = MsgAdapter.ReadShort()
	self.active_image_flag = MsgAdapter.ReadInt()
	-- self.active_special_image_flag = MsgAdapter.ReadInt()
	self.active_special_image_flag = {}
	for i = 1, 8 do
		local value = MsgAdapter.ReadUInt()
		local tab = bit:d2blh(value)
		local len = i - 1

		for j = 1, 32 do
			-- 服务端说不读第一位
			self.active_special_image_flag[j + (32 * len) - 1] = tab[j]
		end
	end

	self.clear_upgrade_time = MsgAdapter.ReadUInt()
	-- self.equip_info_list = {}
	-- for i = 0, GameEnum.MOUNT_EQUIP_COUNT - 1 do
	-- 	self.equip_info_list[i] = DecodeHeadwearEquipInfo()
	-- end

	self.skill_level_list = {}
	for i = 0, GameEnum.MOUNT_SKILL_COUNT - 1 do
		self.skill_level_list[i] = MsgAdapter.ReadShort()
	end

	self.special_img_grade_list = {}
	for i = 0, GameEnum.MAX_DRESS_SPECIAL_IMAGE_ID  do
		self.special_img_grade_list[i] = MsgAdapter.ReadChar()
	end

	self.equip_skill_level = MsgAdapter.ReadInt()  -- 装备技能等级
	self.equip_level_list = {}
	for i = 0, GameEnum.MOUNT_EQUIP_COUNT - 1 do
		self.equip_level_list[i] = MsgAdapter.ReadShort() --  装备信息
	end
end

--upgrade system req
CSUgsMaskReq = CSUgsMaskReq or BaseClass(BaseProtocolStruct)
function CSUgsMaskReq:__init()
	self.msg_type = 11032
	self.req_type = 0
	self.param1 = 0
	self.param2 = 0
	self.param3 = 0
end

function CSUgsMaskReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.req_type)
	MsgAdapter.WriteShort(self.param1)
	MsgAdapter.WriteShort(self.param2)
	MsgAdapter.WriteShort(self.param3)
end

--面饰信息
SCMaskInfo =  SCMaskInfo or BaseClass(BaseProtocolStruct)
function SCMaskInfo:__init()
	self.msg_type = 11033
end

function SCMaskInfo:Decode()
	self.star_level = MsgAdapter.ReadShort()
	self.mask_level = MsgAdapter.ReadShort()
	self.grade = MsgAdapter.ReadShort()
	self.used_imageid = MsgAdapter.ReadShort()
	self.grade_bless_val = MsgAdapter.ReadInt()		-- 祝福值
	self.shuxingdan_count = MsgAdapter.ReadShort()
	self.chengzhangdan_count = MsgAdapter.ReadShort()
	self.active_image_flag = MsgAdapter.ReadInt()
	-- self.  = MsgAdapter.ReadInt()
	self.active_special_image_flag = {}
	for i = 1, 8 do
		local value = MsgAdapter.ReadUInt()
		local tab = bit:d2blh(value)
		local len = i - 1

		for j = 1, 32 do
			-- 服务端说不读第一位
			self.active_special_image_flag[j + (32 * len) - 1] = tab[j]
		end
	end

	self.clear_upgrade_time = MsgAdapter.ReadUInt()
	-- self.equip_info_list = {}
	-- for i = 0, GameEnum.MOUNT_EQUIP_COUNT - 1 do
	-- 	self.equip_info_list[i] = DecodeMaskEquipInfo()
	-- end

	self.skill_level_list = {}
	for i = 0, GameEnum.MOUNT_SKILL_COUNT - 1 do
		self.skill_level_list[i] = MsgAdapter.ReadShort()
	end

	self.special_img_grade_list = {}
	for i = 0, GameEnum.MAX_DRESS_SPECIAL_IMAGE_ID  do
		self.special_img_grade_list[i] = MsgAdapter.ReadChar()
	end

	self.equip_skill_level = MsgAdapter.ReadInt()  -- 装备技能等级
	self.equip_level_list = {}
	for i = 0, GameEnum.MOUNT_EQUIP_COUNT - 1 do
		self.equip_level_list[i] = MsgAdapter.ReadShort() --  装备信息
	end
end

--upgrade system req
CSUgsWaistReq = CSUgsWaistReq or BaseClass(BaseProtocolStruct)
function CSUgsWaistReq:__init()
	self.msg_type = 11034
	self.req_type = 0
	self.param1 = 0
	self.param2 = 0
	self.param3 = 0
end

function CSUgsWaistReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.req_type)
	MsgAdapter.WriteShort(self.param1)
	MsgAdapter.WriteShort(self.param2)
	MsgAdapter.WriteShort(self.param3)
end

--腰饰信息
SCWaistInfo =  SCWaistInfo or BaseClass(BaseProtocolStruct)
function SCWaistInfo:__init()
	self.msg_type = 11035
end

function SCWaistInfo:Decode()
	self.star_level = MsgAdapter.ReadShort()
	self.waist_level = MsgAdapter.ReadShort()
	self.grade = MsgAdapter.ReadShort()
	self.used_imageid = MsgAdapter.ReadShort()
	self.grade_bless_val = MsgAdapter.ReadInt()		-- 祝福值
	self.shuxingdan_count = MsgAdapter.ReadShort()
	self.chengzhangdan_count = MsgAdapter.ReadShort()
	self.active_image_flag = MsgAdapter.ReadInt()
	-- self.active_special_image_flag = MsgAdapter.ReadInt()
	self.active_special_image_flag = {}
	for i = 1, 8 do
		local value = MsgAdapter.ReadUInt()
		local tab = bit:d2blh(value)
		local len = i - 1

		for j = 1, 32 do
			-- 服务端说不读第一位
			self.active_special_image_flag[j + (32 * len) - 1] = tab[j]
		end
	end
	self.clear_upgrade_time = MsgAdapter.ReadUInt()
	-- self.equip_info_list = {}
	-- for i = 0, GameEnum.MOUNT_EQUIP_COUNT - 1 do
	-- 	self.equip_info_list[i] = DecodeWaistEquipInfo()
	-- end

	self.skill_level_list = {}
	for i = 0, GameEnum.MOUNT_SKILL_COUNT - 1 do
		self.skill_level_list[i] = MsgAdapter.ReadShort()
	end

	self.special_img_grade_list = {}
	for i = 0, GameEnum.MAX_DRESS_SPECIAL_IMAGE_ID  do
		self.special_img_grade_list[i] = MsgAdapter.ReadChar()
	end

	self.equip_skill_level = MsgAdapter.ReadInt()  -- 装备技能等级
	self.equip_level_list = {}
	for i = 0, GameEnum.MOUNT_EQUIP_COUNT - 1 do
		self.equip_level_list[i] = MsgAdapter.ReadShort() --  装备信息
	end
end

--upgrade system req
CSUgsKirinArmReq = CSUgsKirinArmReq or BaseClass(BaseProtocolStruct)
function CSUgsKirinArmReq:__init()
	self.msg_type = 11036
	self.req_type = 0
	self.param1 = 0
	self.param2 = 0
	self.param3 = 0
end

function CSUgsKirinArmReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.req_type)
	MsgAdapter.WriteShort(self.param1)
	MsgAdapter.WriteShort(self.param2)
	MsgAdapter.WriteShort(self.param3)
end

--麒麟臂信息
SCKirinArmInfo =  SCKirinArmInfo or BaseClass(BaseProtocolStruct)
function SCKirinArmInfo:__init()
	self.msg_type = 11037
end

function SCKirinArmInfo:Decode()
	self.star_level = MsgAdapter.ReadShort()
	self.kirin_arm_level = MsgAdapter.ReadShort()
	self.grade = MsgAdapter.ReadShort()
	self.used_imageid = MsgAdapter.ReadShort()
	self.grade_bless_val = MsgAdapter.ReadInt()		-- 祝福值
	self.shuxingdan_count = MsgAdapter.ReadShort()
	self.chengzhangdan_count = MsgAdapter.ReadShort()
	self.active_image_flag = MsgAdapter.ReadInt()
	-- self.active_special_image_flag = MsgAdapter.ReadInt()
	self.active_special_image_flag = {}
	for i = 1, 8 do
		local value = MsgAdapter.ReadUInt()
		local tab = bit:d2blh(value)
		local len = i - 1

		for j = 1, 32 do
			-- 服务端说不读第一位
			self.active_special_image_flag[j + (32 * len) - 1] = tab[j]
		end
	end

	self.clear_upgrade_time = MsgAdapter.ReadUInt()
	-- self.equip_info_list = {}
	-- for i = 0, GameEnum.MOUNT_EQUIP_COUNT - 1 do
	-- 	self.equip_info_list[i] = DecodeKirinArmEquipInfo()
	-- end

	self.skill_level_list = {}
	for i = 0, GameEnum.MOUNT_SKILL_COUNT - 1 do
		self.skill_level_list[i] = MsgAdapter.ReadShort()
	end

	self.special_img_grade_list = {}
	for i = 0, GameEnum.MAX_DRESS_SPECIAL_IMAGE_ID  do
		self.special_img_grade_list[i] = MsgAdapter.ReadChar()
	end

	self.equip_skill_level = MsgAdapter.ReadInt()  -- 装备技能等级
	self.equip_level_list = {}
	for i = 0, GameEnum.MOUNT_EQUIP_COUNT - 1 do
		self.equip_level_list[i] = MsgAdapter.ReadShort() --  装备信息
	end
end

--upgrade system req
CSUgsBeadReq = CSUgsBeadReq or BaseClass(BaseProtocolStruct)
function CSUgsBeadReq:__init()
	self.msg_type = 11038
	self.req_type = 0
	self.param1 = 0
	self.param2 = 0
	self.param3 = 0
end

function CSUgsBeadReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.req_type)
	MsgAdapter.WriteShort(self.param1)
	MsgAdapter.WriteShort(self.param2)
	MsgAdapter.WriteShort(self.param3)
end

--灵珠信息
SCBeadInfo =  SCBeadInfo or BaseClass(BaseProtocolStruct)
function SCBeadInfo:__init()
	self.msg_type = 11039
end

function SCBeadInfo:Decode()
	self.star_level = MsgAdapter.ReadShort()
	self.bead_level = MsgAdapter.ReadShort()
	self.grade = MsgAdapter.ReadShort()
	self.used_imageid = MsgAdapter.ReadShort()
	self.grade_bless_val = MsgAdapter.ReadInt()		-- 祝福值
	self.shuxingdan_count = MsgAdapter.ReadShort()
	self.chengzhangdan_count = MsgAdapter.ReadShort()
	self.active_image_flag = MsgAdapter.ReadInt()
	-- self.active_special_image_flag = MsgAdapter.ReadInt()
	self.active_special_image_flag = {}
	for i = 1, 8 do
		local value = MsgAdapter.ReadUInt()
		local tab = bit:d2blh(value)
		local len = i - 1

		for j = 1, 32 do
			-- 服务端说不读第一位
			self.active_special_image_flag[j + (32 * len) - 1] = tab[j]
		end
	end
	self.clear_upgrade_time = MsgAdapter.ReadUInt()
	-- self.equip_info_list = {}
	-- for i = 0, GameEnum.MOUNT_EQUIP_COUNT - 1 do
	-- 	self.equip_info_list[i] = DecodeBeadEquipInfo()
	-- end

	self.skill_level_list = {}
	for i = 0, GameEnum.MOUNT_SKILL_COUNT - 1 do
		self.skill_level_list[i] = MsgAdapter.ReadShort()
	end

	self.special_img_grade_list = {}
	for i = 0, GameEnum.MAX_DRESS_SPECIAL_IMAGE_ID  do
		self.special_img_grade_list[i] = MsgAdapter.ReadChar()
	end

	self.equip_skill_level = MsgAdapter.ReadInt()  -- 装备技能等级
	self.equip_level_list = {}
	for i = 0, GameEnum.MOUNT_EQUIP_COUNT - 1 do
		self.equip_level_list[i] = MsgAdapter.ReadShort() --  装备信息
	end
end

--upgrade system req
CSUgsFaBaoReq = CSUgsFaBaoReq or BaseClass(BaseProtocolStruct)
function CSUgsFaBaoReq:__init()
	self.msg_type = 11040
	self.req_type = 0
	self.param1 = 0
	self.param2 = 0
	self.param3 = 0
end

function CSUgsFaBaoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.req_type)
	MsgAdapter.WriteShort(self.param1)
	MsgAdapter.WriteShort(self.param2)
	MsgAdapter.WriteShort(self.param3)
end

--法宝信息
SCFaBaoInfo =  SCFaBaoInfo or BaseClass(BaseProtocolStruct)
function SCFaBaoInfo:__init()
	self.msg_type = 11041
end

function SCFaBaoInfo:Decode()
	self.star_level = MsgAdapter.ReadShort()
	self.fabao_level = MsgAdapter.ReadShort()
	self.grade = MsgAdapter.ReadShort()
	self.used_imageid = MsgAdapter.ReadShort()
	self.grade_bless_val = MsgAdapter.ReadInt()		-- 祝福值
	self.shuxingdan_count = MsgAdapter.ReadShort()
	self.chengzhangdan_count = MsgAdapter.ReadShort()
	self.active_image_flag = MsgAdapter.ReadInt()
	-- self.active_special_image_flag = MsgAdapter.ReadInt()
	self.active_special_image_flag = {}
	for i = 1, 8 do
		local value = MsgAdapter.ReadUInt()
		local tab = bit:d2blh(value)
		local len = i - 1

		for j = 1, 32 do
			-- 服务端说不读第一位
			self.active_special_image_flag[j + (32 * len) - 1] = tab[j]
		end
	end
	self.clear_upgrade_time = MsgAdapter.ReadUInt()
	-- self.equip_info_list = {}
	-- for i = 0, GameEnum.MOUNT_EQUIP_COUNT - 1 do
	-- 	self.equip_info_list[i] = DecodeFaBaoEquipInfo()
	-- end

	self.skill_level_list = {}
	for i = 0, GameEnum.MOUNT_SKILL_COUNT - 1 do
		self.skill_level_list[i] = MsgAdapter.ReadShort()
	end

	self.special_img_grade_list = {}
	for i = 0, GameEnum.MAX_DRESS_SPECIAL_IMAGE_ID  do
		self.special_img_grade_list[i] = MsgAdapter.ReadChar()
	end

	self.equip_skill_level = MsgAdapter.ReadInt()  -- 装备技能等级
	self.equip_level_list = {}
	for i = 0, GameEnum.MOUNT_EQUIP_COUNT - 1 do
		self.equip_level_list[i] = MsgAdapter.ReadShort() --  装备信息
	end
end

-- 博物志卡牌通用请求
CSHoChiCommonOperateReq = CSHoChiCommonOperateReq or BaseClass(BaseProtocolStruct)
function CSHoChiCommonOperateReq:__init()
	self.msg_type = 11050
	self.opera_type = 0
    self.param1 = 0
    self.param2 = 0
    self.param3 = 0
end

function CSHoChiCommonOperateReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opera_type)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
	MsgAdapter.WriteInt(self.param3)
end

-- 博物志卡牌信息
SCHoChiCardStateInfo = SCHoChiCardStateInfo or BaseClass(BaseProtocolStruct)
function SCHoChiCardStateInfo:__init()
	self.msg_type = 11051
end

function SCHoChiCardStateInfo:Decode()
	self.card_count = MsgAdapter.ReadInt()
	self.suit_count = MsgAdapter.ReadInt()
	self.card_info_list = {}
	for i = 1, self.card_count do
		local data = {}
		data.card_id = MsgAdapter.ReadInt()
    	data.card_state = MsgAdapter.ReadInt()
    	data.card_level = MsgAdapter.ReadInt()
    	self.card_info_list[i] = data
	end

	self.suit_info_list = {}
	for i = 1, self.suit_count do
		local data = {}
		data.suit_id = MsgAdapter.ReadInt()
    	data.card_count = MsgAdapter.ReadInt()
    	self.suit_info_list[i] = data
	end
end

----------------------五行之灵begin------------------------------
--五行之灵操作请求
CSElementHeartReq = CSElementHeartReq or BaseClass(BaseProtocolStruct)
function CSElementHeartReq:__init()
	self.msg_type = 11060
	self.info_type = 0
	self.param1 = 0
	self.param2 = 0
	self.param3 = 0
	self.param4 = 0
end

function CSElementHeartReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.info_type)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
	MsgAdapter.WriteInt(self.param3)
	MsgAdapter.WriteInt(self.param4)
end

--五行之灵信息
SCElementHeartInfo = SCElementHeartInfo or BaseClass(BaseProtocolStruct)
function SCElementHeartInfo:__init()
	self.msg_type = 11061
end

function SCElementHeartInfo:Decode()
	self.pasture_score = MsgAdapter.ReadInt()
	self.info_type = MsgAdapter.ReadChar()
	self.free_chou_times = MsgAdapter.ReadChar()
	local count = MsgAdapter.ReadShort()
	self.element_list = {}
	for i = 1, count do
		local vo = {}
		vo.grade = MsgAdapter.ReadChar()									--阶级
		vo.wuxing_type = MsgAdapter.ReadChar()								--五行类型
		vo.id = MsgAdapter.ReadChar()
		vo.tartget_wuxing_type = MsgAdapter.ReadChar()						--即将转换的五行类型
		vo.wuxing_bless = MsgAdapter.ReadInt()								--五行祝福值
		vo.element_level = SymbolData.Instance:GetElementHeartLevel(vo.wuxing_bless)
		vo.bless = MsgAdapter.ReadInt()										--祝福值
		vo.next_product_timestamp = MsgAdapter.ReadUInt()					--下次产出时间
		vo.wuxing_food_feed_times_list = {}									--记录每个食物喂养次数
		for i=1, GameEnum.ELEMENT_HEART_WUXING_TYPE_MAX do
			vo.wuxing_food_feed_times_list = MsgAdapter.ReadInt()
		end
		vo.equip_param = {}
		vo.equip_param.real_level = MsgAdapter.ReadShort()
		vo.equip_param.slot_flag = MsgAdapter.ReadShort()					--当前已激活的物品标记
		vo.equip_param.upgrade_progress = MsgAdapter.ReadShort()			--升级进度
		MsgAdapter.ReadShort()
		self.element_list[vo.id] = vo
	end
end


--元素之纹列表信息
SCElementTextureInfo = SCElementTextureInfo or BaseClass(BaseProtocolStruct)
function SCElementTextureInfo:__init()
	self.msg_type = 11062
end

function SCElementTextureInfo:Decode()
	self.charm_list = {}
	for i = 0, 9 do
		local vo = {}
		vo.wuxing_type = MsgAdapter.ReadChar()
		vo.grade = MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()
		vo.exp = MsgAdapter.ReadInt()
		self.charm_list[i] = vo
	end
end

--单个元素之纹信息
SCCharmGhostSingleCharmInfo = SCCharmGhostSingleCharmInfo or BaseClass(BaseProtocolStruct)
function SCCharmGhostSingleCharmInfo:__init()
	self.msg_type = 11063
end

function SCCharmGhostSingleCharmInfo:Decode()
	self.index = MsgAdapter.ReadInt()
	local vo = {}
	vo.wuxing_type = MsgAdapter.ReadChar()
	vo.grade = MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
	vo.exp = MsgAdapter.ReadInt()
	self.charm = vo
end
--抽奖奖品
SCElementHeartChouRewardListInfo = SCElementHeartChouRewardListInfo or BaseClass(BaseProtocolStruct)
function SCElementHeartChouRewardListInfo:__init()
	self.msg_type = 11064
end

function SCElementHeartChouRewardListInfo:Decode()
	self.free_chou_times = MsgAdapter.ReadShort()
	local count = MsgAdapter.ReadShort()
	self.reward_list = {}
	for i = 1, count do
		local vo = {}
		vo.item_id = MsgAdapter.ReadUShort()
		vo.num = MsgAdapter.ReadChar()
		vo.is_bind = MsgAdapter.ReadChar()
		self.reward_list[i] = vo
	end
end

--产出列表
SCElementProductListInfo = SCElementProductListInfo or BaseClass(BaseProtocolStruct)
function SCElementProductListInfo:__init()
	self.msg_type = 11065
end

function SCElementProductListInfo:Decode()
	self.info_type = MsgAdapter.ReadShort()
	local count = MsgAdapter.ReadShort()
	self.product_list = {}
	for i = 0, count - 1 do
		self.product_list[i] = MsgAdapter.ReadUShort()
	end
end

--商店信息
SCElementShopInfo = SCElementShopInfo or BaseClass(BaseProtocolStruct)
function SCElementShopInfo:__init()
	self.msg_type = 11066
end

function SCElementShopInfo:Decode()
	self.next_refresh_timestamp = MsgAdapter.ReadUInt()
	MsgAdapter.ReadShort()
	self.today_shop_flush_times = MsgAdapter.ReadShort() 		--当天商店刷新次数
	self.shop_item_list = {}
	for i = 0, GameEnum.ELEMENT_SHOP_ITEM_COUNT - 1 do
		local vo = {}
		vo.index = i
		vo.shop_seq = MsgAdapter.ReadShort()				 -- 商店配置seq
		vo.need_gold_buy = MsgAdapter.ReadChar()			 -- 是否需要元宝购买
		vo.has_buy = MsgAdapter.ReadChar()					 -- 是否已经购买过
		self.shop_item_list[i] = vo
	end
end

--元素洗练单个信息
SCElementXiLianSingleInfo = SCElementXiLianSingleInfo or BaseClass(BaseProtocolStruct)
function SCElementXiLianSingleInfo:__init()
	self.msg_type = 11067
end

function SCElementXiLianSingleInfo:Decode()
	self.element_id = MsgAdapter.ReadInt()
	self.element_xl_info = {}
	self.element_xl_info.open_slot_flag = bit:d2b(MsgAdapter.ReadInt())
	self.element_xl_info.slot_list = {}
	for i = 1, GameEnum.ELEMENT_HEART_MAX_XILIAN_SLOT do
		local vo = {}
		vo.xilian_val = MsgAdapter.ReadInt()
		vo.element_attr_type = MsgAdapter.ReadChar()
		vo.open_slot = self.element_xl_info.open_slot_flag[33 - i]
		MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()
		self.element_xl_info.slot_list[i] = vo
	end
end


--元素洗练信息
SCElementXiLianAllInfo = SCElementXiLianAllInfo or BaseClass(BaseProtocolStruct)
function SCElementXiLianAllInfo:__init()
	self.msg_type = 11068
end

function SCElementXiLianAllInfo:Decode()
	self.xilian_list_info = {}
	for id = 0, GameEnum.ELEMENT_HEART_MAX_COUNT - 1 do
		local element_xl_info = {}
		element_xl_info.open_slot_flag = bit:d2b(MsgAdapter.ReadInt())
		element_xl_info.slot_list = {}
		for i = 1, GameEnum.ELEMENT_HEART_MAX_XILIAN_SLOT do
			local vo = {}
			vo.xilian_val = MsgAdapter.ReadInt()
			vo.element_attr_type = MsgAdapter.ReadChar()
			vo.open_slot = element_xl_info.open_slot_flag[33 - i]
			MsgAdapter.ReadChar()
			MsgAdapter.ReadShort()
			element_xl_info.slot_list[i] = vo
		end
		self.xilian_list_info[id] = element_xl_info
	end
end
----------------------五行之灵end------------------------------
