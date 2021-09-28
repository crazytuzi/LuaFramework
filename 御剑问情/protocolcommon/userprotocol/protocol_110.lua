----------------------灵宠-----------------------------
--灵宠数据
SCLingChongInfo = SCLingChongInfo or BaseClass(BaseProtocolStruct)
function SCLingChongInfo:__init()
	self.msg_type = 11000
end

function SCLingChongInfo:Decode()
	self.lingchong_info = {}
	self.lingchong_info.level = MsgAdapter.ReadShort()										-- 等级
	self.lingchong_info.grade = MsgAdapter.ReadShort()										-- 阶
	self.lingchong_info.star_level = MsgAdapter.ReadShort()									-- 星级
	self.lingchong_info.used_imageid = MsgAdapter.ReadShort()								-- 使用的形象
	self.lingchong_info.shuxingdan_count = MsgAdapter.ReadShort()							-- 属性丹数量
	self.lingchong_info.chengzhangdan_count = MsgAdapter.ReadShort()						-- 成长丹数量
	self.lingchong_info.grade_bless_val = MsgAdapter.ReadInt()								-- 进阶祝福值
	self.lingchong_info.active_image_flag = MsgAdapter.ReadInt()							-- 激活的形象列表
	self.lingchong_info.active_special_image_flag_high = MsgAdapter.ReadInt()				-- 激活的特殊形象列表1
	self.lingchong_info.active_special_image_flag_low = MsgAdapter.ReadInt()				-- 激活的特殊形象列表2
	self.lingchong_info.clear_upgrade_time = MsgAdapter.ReadInt()							-- 清空祝福值的时间
	self.lingchong_info.temporary_imageid = MsgAdapter.ReadShort()							-- 当前使用临时形象
	self.lingchong_info.temporary_imageid_has_select = MsgAdapter.ReadShort()				-- 已选定的临时形象
	self.lingchong_info.temporary_imageid_invalid_time = MsgAdapter.ReadInt()				-- 临时形象有效时间

	self.lingchong_info.special_img_grade_list = {}
	for i = 1, GameEnum.MAX_LINGCHONG_SPECIAL_IMAGE_COUNT do
		self.lingchong_info.special_img_grade_list[i] = MsgAdapter.ReadChar()
	end
end

-- 灵宠外观改变
SCLingChongAppeChange = SCLingChongAppeChange or BaseClass(BaseProtocolStruct)
function SCLingChongAppeChange:__init()
	self.msg_type = 11001
end

function SCLingChongAppeChange:Decode()
	self.obj_id = MsgAdapter.ReadShort()
	self.lingchong_appeid = MsgAdapter.ReadShort()
end

-- 请求使用形象
CSLingChongUseImage = CSLingChongUseImage or BaseClass(BaseProtocolStruct)
function CSLingChongUseImage:__init()
	self.msg_type = 11008
end

function CSLingChongUseImage:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.is_temporary_image)
	MsgAdapter.WriteShort(self.image_id)
end

-- 灵宠特殊形象进阶
CSLingChongSpecialImgUpgrade = CSLingChongSpecialImgUpgrade or BaseClass(BaseProtocolStruct)
function CSLingChongSpecialImgUpgrade:__init()
	self.msg_type = 11007
end

function CSLingChongSpecialImgUpgrade:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.special_image_id)
	MsgAdapter.WriteShort(0)
end

-- 请求灵宠信息
CSLingChongGetInfo = CSLingChongGetInfo or BaseClass(BaseProtocolStruct)
function CSLingChongGetInfo:__init()
	self.msg_type = 11005
end

function CSLingChongGetInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 请求灵宠进阶
CSLingChongUpgrade = CSLingChongUpgrade or BaseClass(BaseProtocolStruct)
function CSLingChongUpgrade:__init()
	self.msg_type = 11006
end

function CSLingChongUpgrade:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.repeat_times)
	MsgAdapter.WriteShort(self.auto_buy)
end

--------------------灵宠END----------------------------

----------------------灵弓-----------------------------
--灵弓数据
SCLingGongInfo = SCLingGongInfo or BaseClass(BaseProtocolStruct)
function SCLingGongInfo:__init()
	self.msg_type = 11010
end

function SCLingGongInfo:Decode()
	self.linggong_info = {}
	self.linggong_info.level = MsgAdapter.ReadShort()										-- 等级
	self.linggong_info.grade = MsgAdapter.ReadShort()										-- 阶
	self.linggong_info.star_level = MsgAdapter.ReadShort()									-- 星级
	self.linggong_info.used_imageid = MsgAdapter.ReadShort()								-- 使用的形象
	self.linggong_info.shuxingdan_count = MsgAdapter.ReadShort()							-- 属性丹数量
	self.linggong_info.chengzhangdan_count = MsgAdapter.ReadShort()							-- 成长丹数量
	self.linggong_info.grade_bless_val = MsgAdapter.ReadInt()								-- 进阶祝福值
	self.linggong_info.active_image_flag = MsgAdapter.ReadInt()								-- 激活的形象列表
	self.linggong_info.active_special_image_flag_high = MsgAdapter.ReadInt()				-- 激活的特殊形象列表1
	self.linggong_info.active_special_image_flag_low = MsgAdapter.ReadInt()					-- 激活的特殊形象列表2
	self.linggong_info.clear_upgrade_time = MsgAdapter.ReadInt()							-- 清空祝福值的时间
	self.linggong_info.temporary_imageid = MsgAdapter.ReadShort()							-- 当前使用临时形象
	self.linggong_info.temporary_imageid_has_select = MsgAdapter.ReadShort()				-- 已选定的临时形象
	self.linggong_info.temporary_imageid_invalid_time = MsgAdapter.ReadInt()				-- 临时形象有效时间

	self.linggong_info.special_img_grade_list = {}
	for i = 1, GameEnum.MAX_LINGGONG_SPECIAL_IMAGE_COUNT do
		self.linggong_info.special_img_grade_list[i] = MsgAdapter.ReadChar()
	end
end

-- 灵弓外观改变
SCLingGongAppeChange = SCLingGongAppeChange or BaseClass(BaseProtocolStruct)
function SCLingGongAppeChange:__init()
	self.msg_type = 11011
end

function SCLingGongAppeChange:Decode()
	self.obj_id = MsgAdapter.ReadShort()
	self.linggong_appeid = MsgAdapter.ReadShort()
end

-- 请求使用形象
CSUseLingGongImage = CSUseLingGongImage or BaseClass(BaseProtocolStruct)
function CSUseLingGongImage:__init()
	self.msg_type = 11015
end

function CSUseLingGongImage:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.is_temporary_image)
	MsgAdapter.WriteShort(self.image_id)
end

-- 灵弓特殊形象进阶
CSLingGongSpecialImgUpgrade = CSLingGongSpecialImgUpgrade or BaseClass(BaseProtocolStruct)
function CSLingGongSpecialImgUpgrade:__init()
	self.msg_type = 11016
end

function CSLingGongSpecialImgUpgrade:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.special_image_id)
	MsgAdapter.WriteShort(0)
end

-- 请求灵弓信息
CSLingGongGetInfo = CSLingGongGetInfo or BaseClass(BaseProtocolStruct)
function CSLingGongGetInfo:__init()
	self.msg_type = 11017
end

function CSLingGongGetInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 请求灵弓进阶
CSUpgradeLingGong = CSUpgradeLingGong or BaseClass(BaseProtocolStruct)
function CSUpgradeLingGong:__init()
	self.msg_type = 11018
end

function CSUpgradeLingGong:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.repeat_times)
	MsgAdapter.WriteShort(self.auto_buy)
end

--------------------灵弓END----------------------------

----------------------灵骑-----------------------------
--灵骑数据
SCLingQiInfo = SCLingQiInfo or BaseClass(BaseProtocolStruct)
function SCLingQiInfo:__init()
	self.msg_type = 11020
end

function SCLingQiInfo:Decode()
	self.lingqi_info = {}
	self.lingqi_info.level = MsgAdapter.ReadShort()										-- 等级
	self.lingqi_info.grade = MsgAdapter.ReadShort()										-- 阶
	self.lingqi_info.star_level = MsgAdapter.ReadShort()								-- 星级
	self.lingqi_info.used_imageid = MsgAdapter.ReadShort()								-- 使用的形象
	self.lingqi_info.shuxingdan_count = MsgAdapter.ReadShort()							-- 属性丹数量
	self.lingqi_info.chengzhangdan_count = MsgAdapter.ReadShort()						-- 成长丹数量
	self.lingqi_info.grade_bless_val = MsgAdapter.ReadInt()								-- 进阶祝福值
	self.lingqi_info.active_image_flag = MsgAdapter.ReadInt()							-- 激活的形象列表
	self.lingqi_info.active_special_image_flag_high = MsgAdapter.ReadInt()				-- 激活的特殊形象列表1
	self.lingqi_info.active_special_image_flag_low = MsgAdapter.ReadInt()				-- 激活的特殊形象列表2
	self.lingqi_info.clear_upgrade_time = MsgAdapter.ReadInt()							-- 清空祝福值的时间
	self.lingqi_info.temporary_imageid = MsgAdapter.ReadShort()							-- 当前使用临时形象
	self.lingqi_info.temporary_imageid_has_select = MsgAdapter.ReadShort()				-- 已选定的临时形象
	self.lingqi_info.temporary_imageid_invalid_time = MsgAdapter.ReadInt()				-- 临时形象有效时间

	self.lingqi_info.special_img_grade_list = {}
	for i = 1, GameEnum.MAX_LINGQI_SPECIAL_IMAGE_COUNT do
		self.lingqi_info.special_img_grade_list[i] = MsgAdapter.ReadChar()
	end
end

-- 灵骑外观改变
SCLingQiAppeChange = SCLingQiAppeChange or BaseClass(BaseProtocolStruct)
function SCLingQiAppeChange:__init()
	self.msg_type = 11021
end

function SCLingQiAppeChange:Decode()
	self.obj_id = MsgAdapter.ReadShort()
	self.lingqi_appeid = MsgAdapter.ReadShort()
end

-- 请求使用形象
CSUseLingQiImage = CSUseLingQiImage or BaseClass(BaseProtocolStruct)
function CSUseLingQiImage:__init()
	self.msg_type = 11025
end

function CSUseLingQiImage:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.is_temporary_image)
	MsgAdapter.WriteShort(self.image_id)
end

-- 灵骑特殊形象进阶
CSLingQiSpecialImgUpgrade = CSLingQiSpecialImgUpgrade or BaseClass(BaseProtocolStruct)
function CSLingQiSpecialImgUpgrade:__init()
	self.msg_type = 11026
end

function CSLingQiSpecialImgUpgrade:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.special_image_id)
	MsgAdapter.WriteShort(0)
end

-- 请求灵骑信息
CSLingQiGetInfo = CSLingQiGetInfo or BaseClass(BaseProtocolStruct)
function CSLingQiGetInfo:__init()
	self.msg_type = 11027
end

function CSLingQiGetInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 请求灵骑进阶
CSUpgradeLingQi = CSUpgradeLingQi or BaseClass(BaseProtocolStruct)
function CSUpgradeLingQi:__init()
	self.msg_type = 11028
end

function CSUpgradeLingQi:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.repeat_times)
	MsgAdapter.WriteShort(self.auto_buy)
end

--------------------灵骑END----------------------------