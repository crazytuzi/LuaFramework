-- ===================================请求==================================
-- 获取英雄的列表(返回 44 3, 44 27, 44 29, 44 15)
CSGetHeroesListReq = CSGetHeroesListReq or BaseClass(BaseProtocolStruct)
function CSGetHeroesListReq:__init()
	self:InitMsgType(44, 1)
end

function CSGetHeroesListReq:Encode()
	self:WriteBegin()
end

-- 设置英雄的状态，0:休息，1放出战斗状态 2合体状态
CSSetHeroStateReq = CSSetHeroStateReq or BaseClass(BaseProtocolStruct)
function CSSetHeroStateReq:__init()
	self:InitMsgType(44, 4)
	self.hero_id = 0        -- (uchar)英雄的状态，查看 eHeroState
	self.hero_state = 0        -- (uchar)英雄的状态，查看 eHeroState
end

function CSSetHeroStateReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.hero_id)
	MsgAdapter.WriteUChar(self.hero_state)
end

-- 英雄穿上装备
CSHeroPutOnEquipReq = CSHeroPutOnEquipReq or BaseClass(BaseProtocolStruct)
function CSHeroPutOnEquipReq:__init()
	self:InitMsgType(44, 9)
	self.hero_id = 0				-- 英雄id
	self.series	= 0					-- (int64)装备物品guid
	self.equip_pos = 0				-- (uchar)装备位置 这里不分左右手，直接发0就可
end

function CSHeroPutOnEquipReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.hero_id)
	CommonReader.WriteSeries(self.series)
	MsgAdapter.WriteUChar(self.equip_pos)
end

-- 英雄脱下装备
CSHeroPutOffEquipReq = CSHeroPutOffEquipReq or BaseClass(BaseProtocolStruct)
function CSHeroPutOffEquipReq:__init()
	self:InitMsgType(44, 10)
	self.hero_id = 0				-- 英雄id
	self.series	= 0			-- (int64)装备物品guid
end

function CSHeroPutOffEquipReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.hero_id)
	CommonReader.WriteSeries(self.series)
end

-- 升级英雄等级(返回 44 24)
CSHeroUpgradeReq = CSHeroUpgradeReq or BaseClass(BaseProtocolStruct)
function CSHeroUpgradeReq:__init()
	self:InitMsgType(44, 14)
	self.hero_id = 0
end

function CSHeroUpgradeReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.hero_id)
end

-- 激活英雄(返回 44 23)
CSHeroActivateReq = CSHeroActivateReq or BaseClass(BaseProtocolStruct)
function CSHeroActivateReq:__init()
	self:InitMsgType(44, 15)
	self.hero_type =1  --默认是1
end

function CSHeroActivateReq:Encode()
	self:WriteBegin()
	--print("sssssssss激活协议上传", self.hero_type)
	MsgAdapter.WriteUChar(self.hero_type)
end

-- 获取英雄经验(返回 44 24)
CSGetHeroExpReq = CSGetHeroExpReq or BaseClass(BaseProtocolStruct)
function CSGetHeroExpReq:__init()
	self:InitMsgType(44, 16)
end

function CSGetHeroExpReq:Encode()
	self:WriteBegin()
end

-- 获取其他玩家的英雄信息(返回 44 19)
CSGetOtherPlayerHeroInfoReq = CSGetOtherPlayerHeroInfoReq or BaseClass(BaseProtocolStruct)
function CSGetOtherPlayerHeroInfoReq:__init()
	self:InitMsgType(44, 18)
	self.role_name = ""		-- (string)其他玩家的角色名字
	self.role_id = 0   		-- (uint)其他玩家的角色id
end

function CSGetOtherPlayerHeroInfoReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteStr(self.role_name)
	MsgAdapter.WriteUInt(self.role_id)
end


-- 提升练体(返回 44 28)
CSUpgradeExerciseEnergyReq = CSUpgradeExerciseEnergyReq or BaseClass(BaseProtocolStruct)
function CSUpgradeExerciseEnergyReq:__init()
	self:InitMsgType(44, 19)
	self.slot = 0
end

function CSUpgradeExerciseEnergyReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.slot)
end


-- ===================================下发==================================

-- 英雄的属性发生变化或者重置属性
SCHeroAttrChange = SCHeroAttrChange or BaseClass(BaseProtocolStruct)
function SCHeroAttrChange:__init()
	self:InitMsgType(44, 3)

	self.hero_id = 0			    -- (uchar)英雄id
	self.hero_type = 0			    -- (uchar)英雄类型,1 战宠 2 精灵
	self.hero_name = ""			    -- (string)英雄名称
	self.monster_id = 0				--(uint)怪物id
	self.model_id = 0				-- (uint)模型id
	self.wing_id = 0				-- (uint)翅膀id
	self.weapon_id = 0				-- (uint)武器外观id
	self.hero_level = 0		    	-- (uchar)英雄等级
	self.hunhuan_sign = 0		    -- (int)魂环标记
	self.max_hp = 0					-- (unsigned int)最大hp
	self.max_mp = 0					-- (unsigned int)最大mp
	self.min_phy_atk = 0		    -- (unsigned int)最小物理攻击
	self.max_phy_atk = 0		    -- (unsigned int)最大物理攻击
	self.min_magic_atk = 0 		    -- (unsigned int)最小魔法攻击
	self.max_magic_atk = 0			-- (unsigned int)最大魔法攻击
	self.min_daoshu_atk	= 0			-- (unsigned int)最小道术攻击
	self.max_daoshu_atk = 0			-- (unsigned int)最大道术攻击
	self.min_phy_def = 0			-- (unsigned int)最小物理防御
	self.max_phy_def = 0			-- (unsigned int)最大物理防御
	self.min_magic_def = 0 			-- (unsigned int)最小魔法防御
	self.max_magic_def = 0			-- (unsigned int)最大魔法防御
	self.paralyze_rate = 0			-- (unsigned int)麻痹几率
	self.critical_chance = 0 		-- (unsigned int)暴击几率
	self.critical_value = 0			-- (unsigned int)暴击值

end

function SCHeroAttrChange:Decode()
	self.hero_id = MsgAdapter.ReadUChar()
	self.hero_type = MsgAdapter.ReadUChar()
	self.hero_name = MsgAdapter.ReadStr()
	self.monster_id = MsgAdapter.ReadUInt()
	self.model_id = MsgAdapter.ReadUInt()		
	self.wing_id = MsgAdapter.ReadUInt()		
	self.weapon_id = MsgAdapter.ReadUInt()		
	self.hero_level = MsgAdapter.ReadUChar()
	--print("sssssssss", self.hero_level)	
	self.hunhuan_sign = MsgAdapter.ReadInt()	
	self.max_hp = MsgAdapter.ReadUInt()			
	self.max_mp = MsgAdapter.ReadUInt()			
	self.min_phy_atk = MsgAdapter.ReadUInt()	
	self.max_phy_atk = MsgAdapter.ReadUInt()	
	self.min_magic_atk = MsgAdapter.ReadUInt() 	
	self.max_magic_atk = MsgAdapter.ReadUInt()	
	self.min_daoshu_atk	= MsgAdapter.ReadUInt()	
	self.max_daoshu_atk = MsgAdapter.ReadUInt()	
	self.min_phy_def = MsgAdapter.ReadUInt()	
	self.max_phy_def = MsgAdapter.ReadUInt()	
	self.min_magic_def = MsgAdapter.ReadUInt() 	
	self.max_magic_def = MsgAdapter.ReadUInt()	
	self.paralyze_rate = MsgAdapter.ReadUInt()	
	self.critical_chance = MsgAdapter.ReadUInt()
	self.critical_value	= MsgAdapter.ReadUInt()
end

-- 英雄穿上装备
SCHeroSkill = SCHeroSkill or BaseClass(BaseProtocolStruct)
function SCHeroSkill:__init()
	self:InitMsgType(44, 4)
	self.hero_id = 0			-- (uchar)英雄id
	self.hero_type = 0			-- (uchar)英雄id
	self.skill_data = {}			-- 物品信息
end

function SCHeroSkill:Decode()
	self.hero_id = MsgAdapter.ReadUChar()
	self.hero_type = MsgAdapter.ReadUChar()
	local skill_num = MsgAdapter.ReadUChar()
	self.skill_data = {}
	for i = 1, skill_num do
		local vo = {}
		vo.id = MsgAdapter.ReadInt()
		vo.slot = MsgAdapter.ReadInt()
		vo.level = MsgAdapter.ReadInt()
		vo.is_close = MsgAdapter.ReadUChar()
		vo.no_1 = MsgAdapter.ReadUChar()
		vo.no_2 = MsgAdapter.ReadShort()
		vo.exp = MsgAdapter.ReadUInt()
		vo.next_exp = MsgAdapter.ReadUInt()
		self.skill_data[i] = vo
	end
end

-- 英雄穿上装备
SCHeroPutOnEquip = SCHeroPutOnEquip or BaseClass(BaseProtocolStruct)
function SCHeroPutOnEquip:__init()
	self:InitMsgType(44, 9)
	self.hero_id = 0			-- (uchar)英雄id
	self.equip_pos = 0			-- (uchar)装备位置 0左手, 1右手
	self.item_data = {}			-- 物品信息
end

function SCHeroPutOnEquip:Decode()
	self.hero_id = MsgAdapter.ReadUChar()
	self.equip_pos = MsgAdapter.ReadUChar()
	self.item_data = CommonReader.ReadItemData()
end

-- 英雄脱下装备
SCHeroPutOffEquip = SCHeroPutOffEquip or BaseClass(BaseProtocolStruct)
function SCHeroPutOffEquip:__init()
	self:InitMsgType(44, 10)
	self.hero_id = 0			-- (uchar)英雄id
	self.series = 0				-- (int64)物品guid
end

function SCHeroPutOffEquip:Decode()
	self.hero_id = MsgAdapter.ReadUChar()
	self.series = CommonReader.ReadSeries()
end

-- 下发已有的装备的列表
SCIssueOwnedEquipList = SCIssueOwnedEquipList or BaseClass(BaseProtocolStruct)
function SCIssueOwnedEquipList:__init()
	self:InitMsgType(44, 15)
	self.hero_id = 0			-- (uchar)英雄id
	self.equip_count = 0		-- (uchar)英雄装备数量
	self.equip_data_list = {}
end

function SCIssueOwnedEquipList:Decode()
	self.hero_id = MsgAdapter.ReadUChar()
	self.equip_count = MsgAdapter.ReadUChar()
	self.equip_data_list = {}
	for i = 1, self.equip_count do
		self.equip_data_list[i] = CommonReader.ReadItemData()
	end
end

-- 通知玩家到达三十级, 可以激活英雄
-- 空数据
SCInformPlayerActivateHero = SCInformPlayerActivateHero or BaseClass(BaseProtocolStruct)
function SCInformPlayerActivateHero:__init()
	self:InitMsgType(44, 17)
end

function SCInformPlayerActivateHero:Decode()

end

-- 英雄改变了血量
SCHeroHPChanged = SCHeroHPChanged or BaseClass(BaseProtocolStruct)
function SCHeroHPChanged:__init()
	self:InitMsgType(44, 18)
	self.hp = 0		-- (uint)血值
end

function SCHeroHPChanged:Decode()
	self.hp = MsgAdapter.ReadUInt()
end

-- 其他玩家的英雄信息
-- 44  19
SCOtherPlayerHeroInfo = SCOtherPlayerHeroInfo or BaseClass(BaseProtocolStruct)
function SCOtherPlayerHeroInfo:__init()
	self:InitMsgType(44, 19)
	self.hero_level = 0				-- (uchar)其他玩家的英雄等级
	self.hero_name = ""				-- (string)英雄名字
	self.model_id = 0				-- (uint)模型的ID
	self.wing_appearance_id	= 0		-- (uint)翅膀外观ID
	self.weapon_appearance_id = 0	-- (uint)武器外观ID
	self.hero_id = 0				-- (uchar)英雄id
	self.hero_equip_count = 0		-- (uchar)装备数量
	self.hero_equip_data_list = {}
end

function SCOtherPlayerHeroInfo:Decode()
	self.hero_level = MsgAdapter.ReadUChar()
	self.hero_name = MsgAdapter.ReadStr()
	self.model_id = MsgAdapter.ReadUInt()
	self.wing_appearance_id = MsgAdapter.ReadUInt()
	self.weapon_appearance_id = MsgAdapter.ReadUInt()
	self.hero_id = MsgAdapter.ReadUChar()
	self.hero_equip_count = MsgAdapter.ReadUChar()
	self.hero_equip_data_list = {}
	for i = 1, self.hero_equip_count do
		self.hero_equip_data_list[i] = CommonReader.ReadItemData()
	end
end

-- 下发激活英雄信息
SCIssueActivateHeroMsg = SCIssueActivateHeroMsg or BaseClass(BaseProtocolStruct)
function SCIssueActivateHeroMsg:__init()
	self:InitMsgType(44, 23)
	self.hero_type = 0						-- (uchar)1成功, 失败返回提示信息
	self.hero_id = 0						-- (uchar)1成功, 失败返回提示信息
end

function SCIssueActivateHeroMsg:Decode()
	--print("ssssssssss返回消息")
	self.hero_type = MsgAdapter.ReadUChar()
	self.hero_id = MsgAdapter.ReadUChar()
end

-- 下发英雄数据
SCIssueHeroData = SCIssueHeroData or BaseClass(BaseProtocolStruct)
function SCIssueHeroData:__init()
	self:InitMsgType(44, 24)
	self.hero_level = 0							-- (uchar)英雄等级
	self.need_bindGold = 0						-- (uint)下一级英雄等级需要的最大金钱
	self.cur_bindGold = 0						-- (uint)当前绑金
end

function SCIssueHeroData:Decode()
	self.hero_level = MsgAdapter.ReadUChar()
	self.need_bindGold = MsgAdapter.ReadUInt()
	self.cur_bindGold = MsgAdapter.ReadUInt()
	--print("sssssssss", self.hero_level)
end

-- 下发英雄状态
SCIssueHeroState = SCIssueHeroState or BaseClass(BaseProtocolStruct)
function SCIssueHeroState:__init()
	self:InitMsgType(44, 25)
	self.hero_id = 0
	self.hero_type = 0
	self.hero_state = 0		-- (uchar)英雄状态, 查看 eHeroState

end

function SCIssueHeroState:Decode()
	self.hero_id = MsgAdapter.ReadUChar()
	self.hero_type = MsgAdapter.ReadUChar()
	self.hero_state = MsgAdapter.ReadUChar()
	--print("<<<<<<<<协议下发", self.hero_id)
end

-- 升级英雄等级回发
SCUpgardeHeroPostback = SCUpgardeHeroPostback or BaseClass(BaseProtocolStruct)
function SCUpgardeHeroPostback:__init()
	self:InitMsgType(44, 26)
	self.hero_id = 0
	self.is_succeed = 0		-- (uchar)1成功, 0失败
end

function SCUpgardeHeroPostback:Decode()
	self.hero_id = MsgAdapter.ReadUChar()
	self.is_succeed = MsgAdapter.ReadUChar()
end

-- 下一级英雄属性
SCHeroNextLevAttr = SCHeroNextLevAttr or BaseClass(BaseProtocolStruct)
function SCHeroNextLevAttr:__init()
	self:InitMsgType(44, 27)
	self.attr_count = 0            -- (ushort)属性数量
	self.attr_info_list = {}
end

function SCHeroNextLevAttr:Decode()
	self.attr_count = MsgAdapter.ReadUShort()
	self.attr_info_list = {}
	for i = 1, self.attr_count do
		local vo = {}
		vo.type = MsgAdapter.ReadUShort()
		vo.value = MsgAdapter.ReadUInt()
		self.attr_info_list[i] = vo
	end
end

-- 下发提升练体结果
SCIssueUpgradeLiantiResult = SCIssueUpgradeLiantiResult or BaseClass(BaseProtocolStruct)
function SCIssueUpgradeLiantiResult:__init()
	self:InitMsgType(44, 28)
	self.is_succeed = 0			-- (uchar)1成功, 0失败    
end

function SCIssueUpgradeLiantiResult:Decode()
	self.is_succeed = MsgAdapter.ReadUChar()
end

-- 下发下一级英雄练体属性
SCIssueHeroNextLiantiAttr = SCIssueHeroNextLiantiAttr or BaseClass(BaseProtocolStruct)
function SCIssueHeroNextLiantiAttr:__init()
	self:InitMsgType(44, 29)
	self.attr_count = 0        -- (ushort)属性数量
	self.attr_info_list = {}
end

function SCIssueHeroNextLiantiAttr:Decode()
	self.attr_count = MsgAdapter.ReadUShort()
	self.attr_info_list = {}
	for i = 1, self.attr_count do
		local vo = {}
		vo.type = MsgAdapter.ReadUShort()			-- 	(ushort)属性的类型 查看tagGameAttributeType定义
		vo.value = MsgAdapter.ReadUInt()			-- 	(uint)属性值
		self.attr_info_list[i] = vo
	end
end







