--仙女守护信息
SCXiannvShouhuInfo =  SCXiannvShouhuInfo or BaseClass(BaseProtocolStruct)
function SCXiannvShouhuInfo:__init()
	self.msg_type = 6825
	self.star_level = 0
	self.grade = 0
	self.used_imageid = 0
	self.reserve = 0
	self.active_image_flag = 0
	self.grade_bless_val = 0
end

function SCXiannvShouhuInfo:Decode()
	self.star_level = MsgAdapter.ReadShort()
	self.grade = MsgAdapter.ReadShort()
	self.used_imageid = MsgAdapter.ReadShort()
	self.reserve = MsgAdapter.ReadShort()
	self.active_image_flag = MsgAdapter.ReadInt()
	self.grade_bless_val = MsgAdapter.ReadInt()
end

--请求使用形象
CSUseXiannvShouhuImage = CSUseXiannvShouhuImage or BaseClass(BaseProtocolStruct)
function CSUseXiannvShouhuImage:__init()
	self.msg_type = 6801
	self.reserve_sh = 0
	self.image_id = 0
end

function CSUseXiannvShouhuImage:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.reserve_sh)
	MsgAdapter.WriteShort(self.image_id)
end

--请求仙女守护信息
CSXiannvShouhuGetInfo = CSXiannvShouhuGetInfo or BaseClass(BaseProtocolStruct)
function CSXiannvShouhuGetInfo:__init()
	self.msg_type = 6802
end

function CSXiannvShouhuGetInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--升星级请求
CSXiannvShouhuUpStarLevel = CSXiannvShouhuUpStarLevel or BaseClass(BaseProtocolStruct)
function CSXiannvShouhuUpStarLevel:__init()
	self.msg_type = 6800
	self.stuff_index = 0
	self.is_auto_buy = 0
end

function CSXiannvShouhuUpStarLevel:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.stuff_index)
	MsgAdapter.WriteShort(self.is_auto_buy)
end

--精灵光环升星请求
CSJinglingGuanghuanUpStarLevel =  CSJinglingGuanghuanUpStarLevel or BaseClass(BaseProtocolStruct)
function CSJinglingGuanghuanUpStarLevel:__init()
	self.msg_type = 6850
	self.is_auto_buy = 0
end

function CSJinglingGuanghuanUpStarLevel:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.is_auto_buy)
end

--请求使用精灵法阵形象
CSUseJinglingGuanghuanImage =  CSUseJinglingGuanghuanImage or BaseClass(BaseProtocolStruct)
function CSUseJinglingGuanghuanImage:__init()
	self.msg_type = 6851
	self.image_id = 0
end

function CSUseJinglingGuanghuanImage:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(0)
	MsgAdapter.WriteShort(self.image_id)
end

--请求精灵光环信息
CSJinglingGuanghuanGetInfo =  CSJinglingGuanghuanGetInfo or BaseClass(BaseProtocolStruct)
function CSJinglingGuanghuanGetInfo:__init()
	self.msg_type = 6852
end

function CSJinglingGuanghuanGetInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--请求使用精灵光环特殊形象
CSJinglingGuanghuanSpecialImgUpgrade =  CSJinglingGuanghuanSpecialImgUpgrade or BaseClass(BaseProtocolStruct)
function CSJinglingGuanghuanSpecialImgUpgrade:__init()
	self.msg_type = 6853
	self.special_image_id = 0
end

function CSJinglingGuanghuanSpecialImgUpgrade:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.special_image_id)
	MsgAdapter.WriteShort(0)
end

-- 精灵光环信息
SCJinglingGuanghuanInfo =  SCJinglingGuanghuanInfo or BaseClass(BaseProtocolStruct)

function SCJinglingGuanghuanInfo:__init()
	self.msg_type = 6875
end

function SCJinglingGuanghuanInfo:Decode()
	MsgAdapter.ReadShort()
	self.grade = MsgAdapter.ReadShort()
	self.used_imageid = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.active_image_flag = MsgAdapter.ReadInt()
	self.grade_bless_val = MsgAdapter.ReadInt()
	self.active_special_image_flag = MsgAdapter.ReadInt()

	self.special_img_grade_list = {}
	for i = 0, GameEnum.MAX_SPRITE_SPECIAL_IMAGE_ID - 1  do
		self.special_img_grade_list[i] = MsgAdapter.ReadChar()
	end
end