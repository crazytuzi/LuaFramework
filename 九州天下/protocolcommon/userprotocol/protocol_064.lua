local function DecodeHaloEquipInfo()
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

--光环信息
SCHaloInfo =  SCHaloInfo or BaseClass(BaseProtocolStruct)
function SCHaloInfo:__init()
	self.msg_type = 6400
end

--单个光环信息返回
function SCHaloInfo:Decode()
	self.halo_level = MsgAdapter.ReadShort()
	self.grade = MsgAdapter.ReadShort()
	self.grade_bless_val = MsgAdapter.ReadInt()
	MsgAdapter.ReadShort()
	self.used_imageid = MsgAdapter.ReadShort()
	self.shuxingdan_count = MsgAdapter.ReadShort()
	self.chengzhangdan_count = MsgAdapter.ReadShort()
	-- self.grade_bless_val = 0
	-- self.grade_bless_val = MsgAdapter.ReadInt()		-- 祝福值 -- 屏掉，协议报错,自行整理
	self.active_image_flag = MsgAdapter.ReadInt()
	self.active_special_image_flag = MsgAdapter.ReadInt()
	self.clear_upgrade_time = MsgAdapter.ReadUInt()

	-- self.equip_skill_level = MsgAdapter.ReadInt()

	-- self.equip_info_list = {}
	-- for i = 0, GameEnum.MOUNT_EQUIP_COUNT - 1 do
	-- 	self.equip_info_list[i] = DecodeHaloEquipInfo()
	-- end
	-- self.equip_level_list = {}

	-- 屏掉，协议报错,自行整理
	-- for i = 0, GameEnum.MOUNT_EQUIP_COUNT - 1 do
	-- 	self.equip_level_list[i] = MsgAdapter.ReadShort()
	-- end
	
	self.skill_level_list = {}
	for i = 0, GameEnum.MOUNT_SKILL_COUNT - 1 do
		self.skill_level_list[i] = MsgAdapter.ReadShort()
	end
	self.special_img_grade_list = {}
	for i = 0, GameEnum.MAX_MOUNT_SPECIAL_IMAGE_ID  do
		self.special_img_grade_list[i] = MsgAdapter.ReadChar()
	end

	self.equip_skill_level = MsgAdapter.ReadInt()  -- 装备技能等级
	self.equip_level_list = {}
	for i = 0, GameEnum.MOUNT_EQUIP_COUNT - 1 do
		self.equip_level_list[i] = MsgAdapter.ReadShort() --  装备信息
	end
end

--光环外观改变
SCHaloAppeChange = SCHaloAppeChange or BaseClass(BaseProtocolStruct)
function SCHaloAppeChange:__init()
	self.msg_type = 6401
end

function SCHaloAppeChange:Decode()
	self.objid = MsgAdapter.ReadUShort()
	self.halo_appeid = MsgAdapter.ReadUShort()
end

--光环进阶
CSUpgradeHalo = CSUpgradeHalo or BaseClass(BaseProtocolStruct)
function CSUpgradeHalo:__init()
	self.msg_type = 6402
	self.repeat_times = 0
	self.auto_buy = 0
end

function CSUpgradeHalo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.repeat_times)
	MsgAdapter.WriteShort(self.auto_buy)
end

--光环形象使用
CSUseHaloImage = CSUseHaloImage or BaseClass(BaseProtocolStruct)
function CSUseHaloImage:__init()
	self.msg_type = 6403
	self.reserve_sh = 0
	self.image_id = 0
end

function CSUseHaloImage:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.reserve_sh)
	MsgAdapter.WriteShort(self.image_id)
end

-- 请求光环信息协议
CSHaloGetInfo = CSHaloGetInfo or BaseClass(BaseProtocolStruct)
function CSHaloGetInfo:__init()
	self.msg_type = 6404
end

function CSHaloGetInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--光环升级装备请求
CSHaloUplevelEquip = CSHaloUplevelEquip or BaseClass(BaseProtocolStruct)
function CSHaloUplevelEquip:__init()
	self.msg_type = 6405
	self.equip_index = 0
end

function CSHaloUplevelEquip:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteChar(self.equip_index)
	MsgAdapter.WriteShort(0)
end

--光环技能升级请求
CSHaloSkillUplevelReq = CSHaloSkillUplevelReq or BaseClass(BaseProtocolStruct)
function CSHaloSkillUplevelReq:__init()
	self.msg_type = 6406
	self.skill_idx = 0
	self.auto_buy = 0
end

function CSHaloSkillUplevelReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.skill_idx)
	MsgAdapter.WriteShort(self.auto_buy)
end

--光环特殊形象进阶
CSHaloSpecialImgUpgrade = CSHaloSpecialImgUpgrade or BaseClass(BaseProtocolStruct)
function CSHaloSpecialImgUpgrade:__init()
	self.msg_type = 6407
	self.special_image_id = 0
	self.reserve_sh = 0
end

function CSHaloSpecialImgUpgrade:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.special_image_id)
	MsgAdapter.WriteShort(self.reserve_sh)
end

--光环升星
CSHaloUpStarLevel = CSHaloUpStarLevel or BaseClass(BaseProtocolStruct)
function CSHaloUpStarLevel:__init()
	self.msg_type = 6408
	self.stuff_index = 0
	self.is_auto_buy = 0
	self.loop_times = 0
end

function CSHaloUpStarLevel:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.stuff_index)
	MsgAdapter.WriteShort(self.is_auto_buy)
	MsgAdapter.WriteInt(self.loop_times)
end



---------------------------------------
------------神弓协议-------------------
local function DecodeShengongEquipInfo()
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

--神弓信息
SCShengongInfo =  SCShengongInfo or BaseClass(BaseProtocolStruct)
function SCShengongInfo:__init()
	self.msg_type = 6450
end

--单个神弓信息返回
function SCShengongInfo:Decode()
	self.star_level = MsgAdapter.ReadShort()
	self.shengong_level = MsgAdapter.ReadShort()
	self.grade = MsgAdapter.ReadShort()
	self.used_imageid = MsgAdapter.ReadShort()
	self.grade_bless_val = MsgAdapter.ReadInt()		-- 祝福值
	self.shuxingdan_count = MsgAdapter.ReadShort()
	self.chengzhangdan_count = MsgAdapter.ReadShort()
	self.active_image_flag = MsgAdapter.ReadInt()
	self.active_special_image_flag = MsgAdapter.ReadInt()
	self.clear_upgrade_time = MsgAdapter.ReadUInt()

	-- self.equip_info_list = {}
	-- for i = 0, GameEnum.MOUNT_EQUIP_COUNT - 1 do
	-- 	self.equip_info_list[i] = DecodeShengongEquipInfo()
	-- end

	self.skill_level_list = {}
	for i = 0, GameEnum.MOUNT_SKILL_COUNT - 1 do
		self.skill_level_list[i] = MsgAdapter.ReadShort()
	end

	self.special_img_grade_list = {}
	for i = 0, GameEnum.MAX_MOUNT_SPECIAL_IMAGE_ID  do
		self.special_img_grade_list[i] = MsgAdapter.ReadChar()
	end

	self.equip_skill_level = MsgAdapter.ReadInt()  -- 装备技能等级
	self.equip_level_list = {}
	for i = 0, GameEnum.MOUNT_EQUIP_COUNT - 1 do
		self.equip_level_list[i] = MsgAdapter.ReadShort() --  装备信息
	end
end

--神弓外观改变
SCShengongAppeChange = SCShengongAppeChange or BaseClass(BaseProtocolStruct)
function SCShengongAppeChange:__init()
	self.msg_type = 6451
end

function SCShengongAppeChange:Decode()
	self.objid = MsgAdapter.ReadUShort()
	self.shengong_appeid = MsgAdapter.ReadUShort()
end

--神弓进阶
CSUpgradeShengong = CSUpgradeShengong or BaseClass(BaseProtocolStruct)
function CSUpgradeShengong:__init()
	self.msg_type = 6452
	self.repeat_times = 0
	self.auto_buy = 0
end

function CSUpgradeShengong:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.repeat_times)
	MsgAdapter.WriteShort(self.auto_buy)
end

--神弓形象使用
CSUseShengongImage = CSUseShengongImage or BaseClass(BaseProtocolStruct)
function CSUseShengongImage:__init()
	self.msg_type = 6453
	self.reserve_sh = 0
	self.image_id = 0
end

function CSUseShengongImage:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.reserve_sh)
	MsgAdapter.WriteShort(self.image_id)
end

-- 请求神弓信息协议
CSShengongGetInfo = CSShengongGetInfo or BaseClass(BaseProtocolStruct)
function CSShengongGetInfo:__init()
	self.msg_type = 6454
end

function CSShengongGetInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--神弓升级装备请求
CSShengongUplevelEquip = CSShengongUplevelEquip or BaseClass(BaseProtocolStruct)
function CSShengongUplevelEquip:__init()
	self.msg_type = 6455
	self.equip_index = 0
end

function CSShengongUplevelEquip:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.equip_index)
	MsgAdapter.WriteShort(0)
end

--神弓技能升级请求
CSShengongSkillUplevelReq = CSShengongSkillUplevelReq or BaseClass(BaseProtocolStruct)
function CSShengongSkillUplevelReq:__init()
	self.msg_type = 6456
	self.skill_idx = 0
	self.auto_buy = 0
end

function CSShengongSkillUplevelReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.skill_idx)
	MsgAdapter.WriteShort(self.auto_buy)
end

--神弓特殊形象进阶
CSShengongSpecialImgUpgrade = CSShengongSpecialImgUpgrade or BaseClass(BaseProtocolStruct)
function CSShengongSpecialImgUpgrade:__init()
	self.msg_type = 6457
	self.special_image_id = 0
	self.reserve_sh = 0
end

function CSShengongSpecialImgUpgrade:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.special_image_id)
	MsgAdapter.WriteShort(self.reserve_sh)
end

--神弓升星
CSShengongUpStarLevel = CSShengongUpStarLevel or BaseClass(BaseProtocolStruct)
function CSShengongUpStarLevel:__init()
	self.msg_type = 6458
	self.stuff_index = 0
	self.is_auto_buy = 0
	self.loop_times = 0
end

function CSShengongUpStarLevel:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.stuff_index)
	MsgAdapter.WriteShort(self.is_auto_buy)
	MsgAdapter.WriteInt(self.loop_times)
end

-- 请求取消使用形象
CSUnUseShengongImage = CSUnUseShengongImage or BaseClass(BaseProtocolStruct)
function CSUnUseShengongImage:__init()
	self.msg_type = 6459
	self.image_id = 0
	self.reserve_sh = 0
end

function CSUnUseShengongImage:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.image_id)
	MsgAdapter.WriteShort(self.reserve_sh)
end