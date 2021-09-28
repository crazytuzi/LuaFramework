----------------------灵珠-----------------------------
--灵珠数据
SCLingZhuInfo = SCLingZhuInfo or BaseClass(BaseProtocolStruct)
function SCLingZhuInfo:__init()
	self.msg_type = 8700
end

function SCLingZhuInfo:Decode()
	self.lingzhu_info = {}
	self.lingzhu_info.level = MsgAdapter.ReadShort()										-- 等级
	self.lingzhu_info.grade = MsgAdapter.ReadShort()										-- 阶
	self.lingzhu_info.star_level = MsgAdapter.ReadShort()									-- 星级
	self.lingzhu_info.used_imageid = MsgAdapter.ReadShort()									-- 使用的形象
	self.lingzhu_info.shuxingdan_count = MsgAdapter.ReadShort()								-- 属性丹数量
	self.lingzhu_info.chengzhangdan_count = MsgAdapter.ReadShort()							-- 成长丹数量
	self.lingzhu_info.grade_bless_val = MsgAdapter.ReadInt()								-- 进阶祝福值
	self.lingzhu_info.active_image_flag = MsgAdapter.ReadInt()								-- 激活的形象列表
	self.lingzhu_info.active_special_image_flag_high = MsgAdapter.ReadInt()					-- 激活的特殊形象列表1
	self.lingzhu_info.active_special_image_flag_low = MsgAdapter.ReadInt()					-- 激活的特殊形象列表2
	self.lingzhu_info.clear_upgrade_time = MsgAdapter.ReadInt()								-- 清空祝福值的时间
	self.lingzhu_info.temporary_imageid = MsgAdapter.ReadShort()							-- 当前使用临时形象
	self.lingzhu_info.temporary_imageid_has_select = MsgAdapter.ReadShort()					-- 已选定的临时形象
	self.lingzhu_info.temporary_imageid_invalid_time = MsgAdapter.ReadInt()					-- 临时形象有效时间

	self.lingzhu_info.special_img_grade_list = {}
	for i = 1, GameEnum.MAX_LINGZHU_SPECIAL_IMAGE_COUNT do
		self.lingzhu_info.special_img_grade_list[i] = MsgAdapter.ReadChar()
	end
end

-- 灵珠外观改变
SCLingZhuAppeChange = SCLingZhuAppeChange or BaseClass(BaseProtocolStruct)
function SCLingZhuAppeChange:__init()
	self.msg_type = 8701
end

function SCLingZhuAppeChange:Decode()
	self.obj_id = MsgAdapter.ReadShort()
	self.lingzhu_appeid = MsgAdapter.ReadShort()
end

-- 请求使用形象
CSUseLingZhuImage = CSUseLingZhuImage or BaseClass(BaseProtocolStruct)
function CSUseLingZhuImage:__init()
	self.msg_type = 8702
end

function CSUseLingZhuImage:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.is_temporary_image)
	MsgAdapter.WriteShort(self.image_id)
end

-- 灵珠特殊形象进阶
CSLingZhuSpecialImgUpgrade = CSLingZhuSpecialImgUpgrade or BaseClass(BaseProtocolStruct)
function CSLingZhuSpecialImgUpgrade:__init()
	self.msg_type = 8703
end

function CSLingZhuSpecialImgUpgrade:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.special_image_id)
	MsgAdapter.WriteShort(0)
end

-- 请求灵珠信息
CSLingZhuGetInfo = CSLingZhuGetInfo or BaseClass(BaseProtocolStruct)
function CSLingZhuGetInfo:__init()
	self.msg_type = 8704
end

function CSLingZhuGetInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 请求灵珠进阶
CSUpgradeLingZhu = CSUpgradeLingZhu or BaseClass(BaseProtocolStruct)
function CSUpgradeLingZhu:__init()
	self.msg_type = 8705
end

function CSUpgradeLingZhu:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.repeat_times)
	MsgAdapter.WriteShort(self.auto_buy)
end
--------------------仙宝END----------------------------


-- 合服投资
SCCSATouzijihuaInfo = SCCSATouzijihuaInfo or BaseClass(BaseProtocolStruct)
function SCCSATouzijihuaInfo:__init()
	self.msg_type = 8710
end

function SCCSATouzijihuaInfo:Decode()
	self.csa_touzijihua_buy_flag = MsgAdapter.ReadChar()
	self.csa_touzijihua_reserve_sh = MsgAdapter.ReadChar()
	self.csa_touzjihua_login_day = MsgAdapter.ReadUShort()
	self.csa_touzijihua_total_fetch_flag = MsgAdapter.ReadUInt()
end


---------------------和服基金-----------------
SCCSAFoundationInfo = SCCSAFoundationInfo or BaseClass(BaseProtocolStruct)
function SCCSAFoundationInfo:__init()
	self.msg_type = 8711
	self.reward_flag = {}
end

function SCCSAFoundationInfo:Decode()
	for i = 1, GameEnum.COMBINE_SERVER_MAX_FOUNDATION_TYPE do
		local temp = {}
		temp.buy_level = MsgAdapter.ReadShort()
		temp.reward_phase = MsgAdapter.ReadShort()
		self.reward_flag[i] = temp
	end
end
---------------------和服基金end-----------------
--城主特权
SCCSAGONGCHENGZHANInfo = SCCSAGONGCHENGZHANInfo or BaseClass(BaseProtocolStruct)

function SCCSAGONGCHENGZHANInfo:__init()
	self.msg_type = 8712
	self.win_times = 0
end

function SCCSAGONGCHENGZHANInfo:Decode()
	self.win_times = MsgAdapter.ReadInt()
end

--匠心月饼兑换次数
SCCollectSecondExchangeInfo = SCCollectSecondExchangeInfo or BaseClass(BaseProtocolStruct)

function SCCollectSecondExchangeInfo:__init()
	self.msg_type = 8725
	self.exchange_times = {}
end

function SCCollectSecondExchangeInfo:Decode()
	self.exchange_times = {}
	for i=1,5 do
		self.exchange_times[i] = MsgAdapter.ReadInt()
	end
end


SCUpgradeCardBuyInfo = SCUpgradeCardBuyInfo or BaseClass(BaseProtocolStruct)

function SCUpgradeCardBuyInfo:__init()
	self.msg_type = 8726
end

function SCUpgradeCardBuyInfo:Decode()
	self.activity_id = MsgAdapter.ReadShort()
	self.grade = MsgAdapter.ReadShort()
	self.is_already_buy = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
end

CSUpgradeCardBuyReq = CSUpgradeCardBuyReq or BaseClass(BaseProtocolStruct)

function CSUpgradeCardBuyReq:__init()
	self.msg_type = 8727
	self.activity_id = 0
	self.item_id = 0
end

function CSUpgradeCardBuyReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.activity_id)
	MsgAdapter.WriteUShort(self.item_id)
end
---------------------小天使小恶魔装备----------------------
-- 操作请求
CSImpGuardOperaReq = CSImpGuardOperaReq or BaseClass(BaseProtocolStruct)
function CSImpGuardOperaReq:__init()
	self.msg_type = 8740
end

function CSImpGuardOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opera_type)
	MsgAdapter.WriteShort(self.param_1)
	MsgAdapter.WriteShort(self.param_2)
end

-- 信息
SCImpGuardInfo = SCImpGuardInfo or BaseClass(BaseProtocolStruct)
function SCImpGuardInfo:__init()
	self.msg_type = 8741
end

function SCImpGuardInfo:Decode()
	self.tianshi_info = {}
	self.tianshi_info.item_id = MsgAdapter.ReadShort()
	self.tianshi_info.is_pop_up = MsgAdapter.ReadChar()
	self.tianshi_info.pack_index = MsgAdapter.ReadChar()
	self.tianshi_info.invalid_time = MsgAdapter.ReadInt()				--过期的时间戳
	self.emo_info = {}
	self.emo_info.item_id = MsgAdapter.ReadShort()
	self.emo_info.is_pop_up = MsgAdapter.ReadChar()
	self.emo_info.pack_index = MsgAdapter.ReadChar()
	self.emo_info.invalid_time = MsgAdapter.ReadInt()					--过期的时间戳
end