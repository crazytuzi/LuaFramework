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

-- 上战斗坐骑
CSGoonFightMount = CSGoonFightMount or BaseClass(BaseProtocolStruct)

function CSGoonFightMount:__init()
	self.msg_type = 2500
	self.goon_mount = 0
end

function CSGoonFightMount:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.goon_mount)
end

-- 战斗坐骑进阶请求
CSUpgradeFightMount = CSUpgradeFightMount or BaseClass(BaseProtocolStruct)

function CSUpgradeFightMount:__init()
	self.msg_type = 2501
	self.repeat_times = 1
	self.auto_buy = 0
end

function CSUpgradeFightMount:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.repeat_times)
	MsgAdapter.WriteShort(self.auto_buy)
end

-- 战斗坐骑使用形象请求
CSUseFightMountImage = CSUseFightMountImage or BaseClass(BaseProtocolStruct)

function CSUseFightMountImage:__init()
	self.msg_type = 2502
	self.reserve_sh = 0
	self.image_id = 0
end

function CSUseFightMountImage:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.reserve_sh)
	MsgAdapter.WriteShort(self.image_id)
end

-- 战斗坐骑信息请求
CSFightMountGetInfo = CSFightMountGetInfo or BaseClass(BaseProtocolStruct)
function CSFightMountGetInfo:__init()
	self.msg_type = 2503
end

function CSFightMountGetInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 战斗坐骑升级装备请求
CSFightMountUplevelEquip = CSFightMountUplevelEquip  or BaseClass(BaseProtocolStruct)
function CSFightMountUplevelEquip:__init()
	self.msg_type = 2504
	self.equip_index = 0
end

function CSFightMountUplevelEquip:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteChar(self.equip_index)
	MsgAdapter.WriteShort(0)
end

-- 战斗坐骑技能升级请求
CSFightMountSkillUplevelReq = CSFightMountSkillUplevelReq or BaseClass(BaseProtocolStruct)
function CSFightMountSkillUplevelReq:__init()
	self.msg_type = 2505
	self.skill_idx = 0
	self.auto_buy = 0
end

function CSFightMountSkillUplevelReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.skill_idx)
	MsgAdapter.WriteShort(self.auto_buy)
end

--坐骑特殊形象进阶
CSFightMountSpecialImgUpgrade = CSFightMountSpecialImgUpgrade or BaseClass(BaseProtocolStruct)
function CSFightMountSpecialImgUpgrade:__init()
	self.msg_type = 2506
	self.special_image_id = 0
	self.reserve_sh = 0
end

function CSFightMountSpecialImgUpgrade:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.special_image_id)
	MsgAdapter.WriteShort(self.reserve_sh)
end

--坐骑升星
CSFightMountUpStarLevel = CSFightMountUpStarLevel or BaseClass(BaseProtocolStruct)
function CSFightMountUpStarLevel:__init()
	self.msg_type = 2507
	self.stuff_index = 0
	self.is_auto_buy = 0
	self.loop_times = 0
end

function CSFightMountUpStarLevel:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.stuff_index)
	MsgAdapter.WriteShort(self.is_auto_buy)
	MsgAdapter.WriteInt(self.loop_times)
end

-- 战斗坐骑信息
SCFightMountInfo = SCFightMountInfo or BaseClass(BaseProtocolStruct)

function SCFightMountInfo:__init()
	self.msg_type = 2550
end

function SCFightMountInfo:Decode()
	self.mount_flag = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.mount_level = MsgAdapter.ReadShort()
	self.grade = MsgAdapter.ReadShort()
	self.grade_bless_val = MsgAdapter.ReadInt()
	MsgAdapter.ReadShort()
	self.used_imageid = MsgAdapter.ReadShort()
	self.shuxingdan_count = MsgAdapter.ReadShort()
	self.chengzhangdan_count = MsgAdapter.ReadShort()
	-- self.grade_bless_val = MsgAdapter.ReadInt()
	self.active_image_flag = MsgAdapter.ReadInt()
	self.active_special_image_flag = MsgAdapter.ReadInt()
	self.clear_upgrade_time = MsgAdapter.ReadUInt()

	-- self.equip_skill_level = MsgAdapter.ReadInt()

	self.equip_info_list = {}
	for i = 0, GameEnum.MOUNT_EQUIP_COUNT - 1 do
		self.equip_info_list[i] = DecodeMountEquipInfo()
	end

	-- self.equip_level_list = {}
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
end

-- 战斗坐骑外观改变信息
SCFightMountAppeChange = SCFightMountAppeChange or BaseClass(BaseProtocolStruct)

function SCFightMountAppeChange:__init()
	self.msg_type = 2551
end

function SCFightMountAppeChange:Decode()
	self.objid = MsgAdapter.ReadUShort()
	self.mount_appeid = MsgAdapter.ReadUShort()
end

--新加展示宝宝的协议
SCBabyDisplayInfo = SCBabyDisplayInfo or BaseClass(BaseProtocolStruct)
function SCBabyDisplayInfo:__init( )
	self.msg_type = 2555
	self.display_baby_index = -1
end

function SCBabyDisplayInfo:Decode()
	self.display_baby_index = MsgAdapter.ReadInt()
end

-- 宝宝精通属性
SCBabyMasterValue = SCBabyMasterValue or BaseClass(BaseProtocolStruct)
function SCBabyMasterValue:__init( )
	self.msg_type = 2556
end

function SCBabyMasterValue:Decode()
	self.baby_index = MsgAdapter.ReadInt()
    self.master_type = MsgAdapter.ReadInt()
    self.master_level = MsgAdapter.ReadInt()
end