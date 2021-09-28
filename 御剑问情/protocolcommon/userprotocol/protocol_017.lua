--返回身上的装备列表
SCEquipList = SCEquipList or BaseClass(BaseProtocolStruct)
function SCEquipList:__init()
	self.msg_type = 1700
end

function SCEquipList:Decode()
	self.equip_list = {}
	MsgAdapter.ReadInt()	--时装美观度
	MsgAdapter.ReadShort()	--是否屏蔽时装外观
	self.fabao_info = {}
	self.fabao_info.fabao_id = MsgAdapter.ReadUShort()
	self.fabao_info.fabao_gain_time = MsgAdapter.ReadUInt()
	self.min_grade = MsgAdapter.ReadShort()    --最小阶
	local count = MsgAdapter.ReadShort()
	for i=1,count do
		local index = MsgAdapter.ReadInt()
		local equip_data = ProtocolStruct.ReadItemDataWrapper()
		equip_data.index = index
		self.equip_list[index] = equip_data
	end
end

--返回身上的装备的强化与神铸等级
SCEquipmentGridInfo = SCEquipmentGridInfo or BaseClass(BaseProtocolStruct)
function SCEquipmentGridInfo:__init()
	self.msg_type = 1785
end

function SCEquipmentGridInfo:Decode()
	self.use_eternity_level = MsgAdapter.ReadShort()
	self.min_eternity_level = MsgAdapter.ReadShort()
	self.min_lianhun_level = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()

	local count = MsgAdapter.ReadInt()
	self.equip_list = {}
	for i = 0, count - 1 do
		local data = {}
		--格子真实的强化等级
		data.index = MsgAdapter.ReadInt()
		data.grid_strengthen_level = MsgAdapter.ReadShort()
		data.shenzhu_level = MsgAdapter.ReadShort()
		data.star_level = MsgAdapter.ReadShort()
		data.eternity_level = MsgAdapter.ReadShort()
		data.star_exp = MsgAdapter.ReadInt()
		data.lianhun_level = MsgAdapter.ReadShort()
		MsgAdapter.ReadShort()

		--装备有效的强化等级，比如格子强化10级，装备只有0阶，0阶装备最高强化等级为5，有效等级为5
		data.strengthen_level = ForgeData.Instance:GetGradeStrengthLevel(data.index, data.grid_strengthen_level) or 0
		self.equip_list[data.index] = data
	end
end

--角色武器颜色变化
SCNoticeTotalStrengLevel = SCNoticeTotalStrengLevel or BaseClass(BaseProtocolStruct)
function SCNoticeTotalStrengLevel:__init()
	self.msg_type = 1786
	self.obj_id = 0
	self.wuqi_color = 0
end

function SCNoticeTotalStrengLevel:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	MsgAdapter.ReadShort()
	self.wuqi_color = MsgAdapter.ReadInt()
end

--装备合成
CSEquipCompound = CSEquipCompound or BaseClass(BaseProtocolStruct)
function CSEquipCompound:__init()
	self.msg_type = 1788

	self.equi_index = 0
end

function CSEquipCompound:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.equi_index)
end

--装备合成
CSEquipUpEternity = CSEquipUpEternity or BaseClass(BaseProtocolStruct)
function CSEquipUpEternity:__init()
	self.msg_type = 1789
	self.equip_index = 0
	self.is_auto_buy = 0
end

function CSEquipUpEternity:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteShort(self.equip_index)
	MsgAdapter.WriteShort(self.is_auto_buy)
end

-- 使用永恒等级
CSEquipUseEternityLevel = CSEquipUseEternityLevel or BaseClass(BaseProtocolStruct)
function CSEquipUseEternityLevel:__init()
	self.msg_type = 1792
	self.eternity_level = 0
end

function CSEquipUseEternityLevel:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.eternity_level)
end

--角色转阵营结果下发
SCChangeCampInfo = SCChangeCampInfo or BaseClass(BaseProtocolStruct)
function SCChangeCampInfo:__init()
	self.msg_type = 1711
	self.obj_id = 0
	self.camp = 0
end

function SCChangeCampInfo:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.camp = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
end

--角色转阵营请求
CSRoleChangeCamp = CSRoleChangeCamp or BaseClass(BaseProtocolStruct)
function CSRoleChangeCamp:__init()
	self.msg_type = 1769
	self.camp = 0
end

function CSRoleChangeCamp:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteChar(self.camp)
	MsgAdapter.WriteChar(0)
	MsgAdapter.WriteShort(0)
end

--神兵升级请求
CSShenBingUpLevel = CSShenBingUpLevel or BaseClass(BaseProtocolStruct)
function CSShenBingUpLevel:__init()
	self.msg_type = 1764
	self.stuff_index = 0
	self.is_auto = 0
	self.auto_uplevel_times = 0
end

function CSShenBingUpLevel:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.stuff_index)
	MsgAdapter.WriteShort(self.is_auto)
	MsgAdapter.WriteInt(self.auto_uplevel_times)
end

--神兵形象
CSShenBingUseImage = CSShenBingUseImage or BaseClass(BaseProtocolStruct)
function CSShenBingUseImage:__init()
	self.msg_type = 1765
	self.use_image = 0
	self.resevre = 0
end

function CSShenBingUseImage:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.use_image)
	MsgAdapter.WriteShort(self.resevre)
end

--神兵所有信息
SCAllShenBingInfo = SCAllShenBingInfo or BaseClass(BaseProtocolStruct)
function SCAllShenBingInfo:__init()
	self.msg_type = 1766
	self.level = 0
	self.use_image = 0
	self.shuxingdan_count = 0
	self.reserve = 0
	self.exp = 0
end

function SCAllShenBingInfo:Decode()
	self.level = MsgAdapter.ReadShort()
	self.use_image = MsgAdapter.ReadShort()
	self.shuxingdan_count = MsgAdapter.ReadInt()
	self.exp = MsgAdapter.ReadInt()
end


--单个装备信息改变
SCEquipChange = SCEquipChange or BaseClass(BaseProtocolStruct)
function SCEquipChange:__init()
	self.msg_type = 1701
end

function SCEquipChange:Decode()
	self.index = MsgAdapter.ReadShort()

	self.reason = MsgAdapter.ReadShort()

	self.equip_data = ProtocolStruct.ReadItemDataWrapper()

	self.equip_data.index = self.index

	self.min_graded = MsgAdapter.ReadInt()
end

--卸下装备
CSTakeOffEquip = CSTakeOffEquip or BaseClass(BaseProtocolStruct)
function CSTakeOffEquip:__init()
	self.msg_type = 1751
end

function CSTakeOffEquip:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.index)
end

-- 请求单个装备信息返回
SCGetOneEquipmentInfoAck = SCGetOneEquipmentInfoAck or BaseClass(BaseProtocolStruct)
function SCGetOneEquipmentInfoAck:__init()
	self.msg_type = 1702
end

function SCGetOneEquipmentInfoAck:Decode()
	self.equipment_info = ProtocolStruct.ReadItemDataWrapper()
end

-- 服务器下发宝石信息
SCStoneInfo = SCStoneInfo or BaseClass(BaseProtocolStruct)
function SCStoneInfo:__init()
	self.msg_type = 1703
end

function SCStoneInfo:Decode()
	self.reason = MsgAdapter.ReadShort()
	self.min_level = MsgAdapter.ReadShort()
	self.stone_limit_flag = MsgAdapter.ReadShort()
	self.reserve = MsgAdapter.ReadShort()
	self.stone_infos = {}
	for i = 0, COMMON_CONSTS.MAX_STONE_EQUIP_PART - 1 do
		local stone_info_list = {}
		for j = 0, COMMON_CONSTS.MAX_STONE_COUNT - 1 do
			local t = {}
			t.stone_id = MsgAdapter.ReadInt()
			MsgAdapter.ReadShort()
			MsgAdapter.ReadShort()
			stone_info_list[j] = t
		end

		self.stone_infos[i] = stone_info_list
	end
end

-- 装备套装信息
SCDuanzaoSuitInfo = SCDuanzaoSuitInfo or BaseClass(BaseProtocolStruct)
function SCDuanzaoSuitInfo:__init()
	self.msg_type = 1705
end

function SCDuanzaoSuitInfo:Decode()
	self.suit_level_list = {}

	for i = 0, FORGE.MAX_SUIT_EQUIP_PART - 1 do
		local t = {}
		t.suit_type = MsgAdapter.ReadShort()
		self.suit_level_list[i] = t
	end
end

-- 其它玩家在线信息改变
SCOtherUserOnlineStatus = SCOtherUserOnlineStatus or BaseClass(BaseProtocolStruct)
function SCOtherUserOnlineStatus:__init()
	self.msg_type = 1706
end

function SCOtherUserOnlineStatus:Decode()
	self.role_id = MsgAdapter.ReadInt()
	self.is_online = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
	self.last_logout_timestamp = MsgAdapter.ReadUInt()
end

-- 请求武器强化
CSEquipStrengthen = CSEquipStrengthen or BaseClass(BaseProtocolStruct)
function CSEquipStrengthen:__init()
	self.msg_type = 1752
	self.equip_index = 0
	self.is_puton = 0
	self.select_bind_first = 1 --服务器端要求这里写死1
	self.is_auto_buy = 0
	self.use_lucky_item = 0
	self.flag = 0
end

function CSEquipStrengthen:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.equip_index)
	MsgAdapter.WriteShort(self.is_puton)
	MsgAdapter.WriteShort(self.select_bind_first)
	MsgAdapter.WriteShort(self.is_auto_buy)
	MsgAdapter.WriteShort(self.use_lucky_item)
	MsgAdapter.WriteShort(self.flag)
end

-- 请求装备提升品质
CSEquipUpQuality = CSEquipUpQuality or BaseClass(BaseProtocolStruct)
function CSEquipUpQuality:__init()
	self.msg_type = 1753
	self.equip_index = 0
	self.is_puton = 0
	self.select_bind_first =  1 --服务器端要求这里写死1
	self.reserve = 0
end

function CSEquipUpQuality:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.equip_index)
	MsgAdapter.WriteShort(self.is_puton)
	MsgAdapter.WriteShort(self.select_bind_first)
	MsgAdapter.WriteShort(self.reserve)
end

-- 请求装备升级
CSEquipUpLevel = CSEquipUpLevel or BaseClass(BaseProtocolStruct)
function CSEquipUpLevel:__init()
	self.msg_type = 1754
	self.equip_index1 = 0
	self.equip_index2 = 0
	self.equip_index3 = 0
end

function CSEquipUpLevel:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteShort(self.equip_index1)
	MsgAdapter.WriteShort(self.equip_index2)
	MsgAdapter.WriteShort(self.equip_index3)
end

-- 请求装备神铸
CSEquipShenZhu = CSEquipShenZhu or BaseClass(BaseProtocolStruct)
function CSEquipShenZhu:__init()
	self.msg_type = 1755
	self.equip_index = 0
	self.is_puton = 0
	self.select_bind_first = 1 --服务器端要求这里写死1
	self.use_protect_stuff = 1
end

function CSEquipShenZhu:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.equip_index)
	MsgAdapter.WriteShort(self.is_puton)
	MsgAdapter.WriteShort(self.select_bind_first)
	MsgAdapter.WriteShort(self.use_protect_stuff)
end

-- 请求宝石镶嵌
CSStoneInlay = CSStoneInlay or BaseClass(BaseProtocolStruct)
function CSStoneInlay:__init()
	self.msg_type = 1784
	self.equip_part = 0
	self.stone_slot = 0
	self.stone_index = 0
	self.is_inlay = 0
end

function CSStoneInlay:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.stone_index)
	MsgAdapter.WriteChar(self.equip_part)
	MsgAdapter.WriteChar(self.stone_slot)
	MsgAdapter.WriteShort(self.is_inlay)
end

--请求宝石信息
SCReqStoneInfo = SCReqStoneInfo or BaseClass(BaseProtocolStruct)
function SCReqStoneInfo:__init()
	self.msg_type = 1787
end

function SCReqStoneInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end


-- 请求宝石升级
CSStoneUpgrade = CSStoneUpgrade or BaseClass(BaseProtocolStruct)
function CSStoneUpgrade:__init()
	self.msg_type = 1756
	self.equip_part = 0
	self.stone_slot = 0
	self.uplevel_type = 0					--0则自动购买
	self.reserve = 0
end

function CSStoneUpgrade:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteChar(self.equip_part)
	MsgAdapter.WriteChar(self.stone_slot)
	MsgAdapter.WriteChar(self.uplevel_type)
	MsgAdapter.WriteChar(self.reserve)
end

-- 锻造套装请求
CSDuanzaoSuitReq = CSDuanzaoSuitReq or BaseClass(BaseProtocolStruct)
function CSDuanzaoSuitReq:__init()
	self.msg_type = 1757
	self.operate_type = 0
	self.equip_index = 0
end

function CSDuanzaoSuitReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.operate_type)
	MsgAdapter.WriteShort(self.equip_index)
end

-- 装备附灵
CSEquipFuling = CSEquipFuling or BaseClass(BaseProtocolStruct)
function CSEquipFuling:__init()
	self.msg_type = 1771
	self.equip_index = 0
	self.reserve = 0
end

function CSEquipFuling:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.equip_index)
	MsgAdapter.WriteChar(self.is_puton)
	MsgAdapter.WriteChar(self.reserve)
end

-- 跨服装备操作
CSEquipCrossEquipOpera = CSEquipCrossEquipOpera or BaseClass(BaseProtocolStruct)
function CSEquipCrossEquipOpera:__init()
	self.msg_type = 1772
	self.is_quxia = 0
	self.reserve_ch = 0
	self.grid_idx = 0
end

function CSEquipCrossEquipOpera:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteChar(self.is_quxia)
	MsgAdapter.WriteChar(self.reserve_ch)
	MsgAdapter.WriteShort(self.grid_idx)
end


-------------------------------转职协议--------------------------------------------------
-- 请求更换职业
CSChangeProfReq = CSChangeProfReq or BaseClass(BaseProtocolStruct)
function CSChangeProfReq:__init()
	self.msg_type = 1770
	self.prof = 0
    self.sex = 0
end

function CSChangeProfReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteChar(self.prof)
	MsgAdapter.WriteChar(self.sex)
	MsgAdapter.WriteShort(0)
end

--装备升星
CSEquipUpStar = CSEquipUpStar or BaseClass(BaseProtocolStruct)
function CSEquipUpStar:__init()
	self.msg_type = 1774
	self.equip_index = 0
end

function CSEquipUpStar:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.equip_index)
	MsgAdapter.WriteShort(0)
end

--装备继承
CSEquipInherit = CSEquipInherit or BaseClass(BaseProtocolStruct)
function CSEquipInherit:__init()
	self.msg_type = 1775
	self.equip_index1 = 0
	self.equip_index2 = 0
	self.is_puton1 = 0
	self.is_puton2 = 0
	self.inherit_type = 0
	self.cost_type = 0
end

function CSEquipInherit:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.equip_index1)
	MsgAdapter.WriteShort(self.equip_index2)
	MsgAdapter.WriteChar(self.is_puton1)
	MsgAdapter.WriteChar(self.is_puton2)
	MsgAdapter.WriteChar(self.inherit_type)
	MsgAdapter.WriteChar(self.cost_type)
end

--角色转生
CSRoleZhuanSheng = CSRoleZhuanSheng or BaseClass(BaseProtocolStruct)
function CSRoleZhuanSheng:__init()
	self.msg_type = 1776
end

function CSRoleZhuanSheng:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 主动物品使用次数
SCRoleNorexItemUseTimes = SCRoleNorexItemUseTimes or BaseClass(BaseProtocolStruct)
function SCRoleNorexItemUseTimes:__init()
	self.msg_type = 1777
end

function SCRoleNorexItemUseTimes:Decode()
	self.use_times_list = {}
	local count = MsgAdapter.ReadInt()

	for i=1,count do
		local item_id = MsgAdapter.ReadUShort()
		local use_times = MsgAdapter.ReadShort()
		self.use_times_list[item_id] = use_times
	end
end

--凝聚经验
CSTransformExpToBottle = CSTransformExpToBottle or BaseClass(BaseProtocolStruct)
function CSTransformExpToBottle:__init()
	self.msg_type = 1778

	self.is_qurrey = 0
	self.seq = 0
	self.item_num = 0
end

function CSTransformExpToBottle:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.is_qurrey)
	MsgAdapter.WriteInt(self.seq)
	MsgAdapter.WriteInt(self.item_num)
end

--凝聚经验信息下发
SCExpBottleInfo = SCExpBottleInfo or BaseClass(BaseProtocolStruct)
function SCExpBottleInfo:__init()
	self.msg_type = 1715
	self.use_count = 0
	self.transform_count = 0
end

function SCExpBottleInfo:Decode()
	self.use_count = MsgAdapter.ReadInt()
	self.transform_count = MsgAdapter.ReadInt()
end

-- 接收下发转职的结果信息
SCChangeProfResult = SCChangeProfResult or BaseClass(BaseProtocolStruct)
function SCChangeProfResult:__init()
	self.msg_type = 1712
	self.obj_id = 0
	self.prof = 0
	self.sex = 0
end

function SCChangeProfResult:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.prof = MsgAdapter.ReadChar()
	self.sex = MsgAdapter.ReadChar()
end


---------------------------
-------空间----------------
---------------------------

-- 请求空间信息
CSGetRoleSpaceMasgInfo = CSGetRoleSpaceMasgInfo or BaseClass(BaseProtocolStruct)
function CSGetRoleSpaceMasgInfo:__init()
	self.msg_type = 1779
	self.type = 0
	self.target_uid = 0
	self.is_seek_byhand = 0
end

function CSGetRoleSpaceMasgInfo:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.type)
	MsgAdapter.WriteInt(self.target_uid)
	MsgAdapter.WriteInt(self.is_seek_byhand)
end

-- 操作空间请求
CSSpaceOper = CSSpaceOper or BaseClass(BaseProtocolStruct)
function CSSpaceOper:__init()
	self.msg_type = 1780
	self.who_space_uid = 0
	self.from_uid = 0
	self.to_uid = 0
	self.type = 0
	self.is_huifu = 0
	self.space_msg = 0
end

function CSSpaceOper:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.who_space_uid)
	MsgAdapter.WriteInt(self.from_uid)
	MsgAdapter.WriteInt(self.to_uid)
	MsgAdapter.WriteInt(self.type)
	MsgAdapter.WriteInt(self.is_huifu)
	MsgAdapter.WriteStrN(self.space_msg, 64)
end

-- 删除空间信息
CSSpaceRemoveRecord = CSSpaceRemoveRecord or BaseClass(BaseProtocolStruct)
function CSSpaceRemoveRecord:__init()
	self.msg_type = 1781
	self.type = 0
	self.unq_id_h = 0
	self.unq_id_l = 0
end

function CSSpaceRemoveRecord:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.type)
	MsgAdapter.WriteInt(self.unq_id_h)
	MsgAdapter.WriteInt(self.unq_id_l)
end

-- 接收空间信息
SCRoleSpaceMsgInfo = SCRoleSpaceMsgInfo or BaseClass(BaseProtocolStruct)
function SCRoleSpaceMsgInfo:__init()
	self.msg_type = 1716
	self.type = 0
	self.target_uid = 0
	self.last_seek_gift_time = 0
	self.last_seek_msg_time = 0
	self.is_new_notice = 0
	self.msg_list = {}
end

function SCRoleSpaceMsgInfo:Decode()
	self.the_type = MsgAdapter.ReadInt()
	self.target_uid = MsgAdapter.ReadInt()
	self.last_seek_gift_time = MsgAdapter.ReadUInt()
	self.last_seek_msg_time = MsgAdapter.ReadUInt()
	self.is_new_notice = MsgAdapter.ReadInt()

	local msg_count = MsgAdapter.ReadInt()

	self.msg_list = {}
	for i = 1, msg_count do
		local vo = {}
		vo.record_unq_id_h = MsgAdapter.ReadInt()
		vo.record_unq_id_l = MsgAdapter.ReadInt()
		vo.owner_uid = MsgAdapter.ReadInt()
		vo.owner_name = MsgAdapter.ReadStrN(32)
		vo.from_uid = MsgAdapter.ReadInt()
		vo.from_name = MsgAdapter.ReadStrN(32)
		vo.to_uid = MsgAdapter.ReadInt()
		vo.to_name = MsgAdapter.ReadStrN(32)
		vo.happen_timestamp = MsgAdapter.ReadUInt()
		vo.happen_space_uid = MsgAdapter.ReadUInt()
		vo.happen_space_ower_name = MsgAdapter.ReadStrN(32)
		vo.type = MsgAdapter.ReadShort()
		vo.is_huifu = MsgAdapter.ReadShort()
		vo.from_prof = MsgAdapter.ReadChar()
		vo.from_sex = MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()
		vo.avatar_key_big = MsgAdapter.ReadUInt()						-- 大头像
		vo.avatar_key_small = MsgAdapter.ReadUInt()						-- 小头像

		vo.msg = MsgAdapter.ReadStrN(64)

		self.msg_list[i] = vo
	end
end

-- 角色自己空间信息
SCSpaceSelfInfo = SCSpaceSelfInfo or BaseClass(BaseProtocolStruct)
function SCSpaceSelfInfo:__init()
	self.msg_type = 1717
	self.space_renqi = 0
	self.space_getgift_count = 0
	self.space_day_cai_addhuoli = 0
	self.space_huoli = 0
	self.space_xinqing = ""
end

function SCSpaceSelfInfo:Decode()
	self.space_renqi = MsgAdapter.ReadInt()
	self.space_getgift_count = MsgAdapter.ReadInt()
	self.space_day_cai_addhuoli = MsgAdapter.ReadInt()
	self.space_huoli = MsgAdapter.ReadInt()
	self.space_xinqing = MsgAdapter.ReadStrN(64)
end

---------------------------
-------生活技能------------
---------------------------
CSLifeSkillOpera = CSLifeSkillOpera or BaseClass(BaseProtocolStruct)
function CSLifeSkillOpera:__init()
	self.msg_type = 1782
	self.operat_type = 0
	self.param1 = 0
end

function CSLifeSkillOpera:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.operat_type)
	MsgAdapter.WriteInt(self.param1)
end

SCLifeSkillInfo = SCLifeSkillInfo or BaseClass(BaseProtocolStruct)
function SCLifeSkillInfo:__init()
	self.msg_type = 1718
end

function SCLifeSkillInfo:Decode()
	self.skill_item_list = {}

	for i= 0, GameEnum.LIFESKILL_COUNT - 1 do
		local skill_item = {}
		skill_item.skill_lv = MsgAdapter.ReadShort()
		skill_item.shuliandu_lv = MsgAdapter.ReadShort()
		skill_item.shuliandu = MsgAdapter.ReadInt()
		MsgAdapter.ReadInt()
		self.skill_item_list[i] = skill_item
	end
end

---------------------------
-------洗炼------------
---------------------------
CSWash = CSWash or BaseClass(BaseProtocolStruct)
function CSWash:__init()
	self.msg_type = 1783
end

function CSWash:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.operate_type)  -- 0.洗炼 1.保存 2,请求

	MsgAdapter.WriteShort(self.index)
	MsgAdapter.WriteChar(self.is_autobuy_lock)
	MsgAdapter.WriteChar(self.is_autobuy_xls)

	--锁住属性列表
	for i=1,4 do
		MsgAdapter.WriteInt(self.is_lock_list[i] or 0)
	end
end

SCWashInfo = SCWashInfo or BaseClass(BaseProtocolStruct)
function SCWashInfo:__init()
	self.msg_type = 1719
end

function SCWashInfo:Decode()
	MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()

	self.part_list = {}
	self.notsave_part_list = {}

	SCWashInfo.ReadPartList(self.part_list)
	SCWashInfo.ReadPartList(self.notsave_part_list)
end

function SCWashInfo.ReadPartList(list)
	for i=0,11 do
		local part_obj = {}
		part_obj.lucky = MsgAdapter.ReadInt()
		part_obj.capability = MsgAdapter.ReadInt()
		part_obj.attr_list = {}

		for k=1,4 do
			local attr_obj = {}
			attr_obj.attr_type = MsgAdapter.ReadShort()
			MsgAdapter.ReadShort()
			attr_obj.attr_value = MsgAdapter.ReadInt()
			attr_obj.equip_index = i

			table.insert(part_obj.attr_list, attr_obj)
		end

		list[i] = part_obj
	end
end

function SCWashInfo:Decode()
	MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()

	self.part_list = {}
	self.notsave_part_list = {}

	SCWashInfo.ReadPartList(self.part_list)
	SCWashInfo.ReadPartList(self.notsave_part_list)
end

-- （修改）
--走棋子信息
SCMoveChessInfo = SCMoveChessInfo or BaseClass(BaseProtocolStruct)
function SCMoveChessInfo:__init()
	self.msg_type = 1720
	self.move_chess_free_times = 0 			--每日免费次数
	self.move_chess_reset_times = 0			--每日重置次数
	self.move_chess_cur_step = 0			--当前所处步数
	self.move_chess_next_free_time = 0		--下一免费时间戳
	-- self.move_chess_shake_point = 0 		--摇到的点数
end

function SCMoveChessInfo:Decode()
	self.move_chess_free_times = MsgAdapter.ReadShort()
	self.move_chess_reset_times = MsgAdapter.ReadShort()
	self.move_chess_cur_step = MsgAdapter.ReadInt()
	self.move_chess_next_free_time = MsgAdapter.ReadUInt()
	-- self.move_chess_shake_point = MsgAdapter.ReadInt()
end


-- 请求大富豪采集信息
CSMillionaireInfoReq = CSMillionaireInfoReq or BaseClass(BaseProtocolStruct)
function CSMillionaireInfoReq:__init()
	self.msg_type = 1721
end

function CSMillionaireInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--大富豪采集信息反回
SCMillionaireInfo = SCMillionaireInfo or BaseClass(BaseProtocolStruct)
function SCMillionaireInfo:__init()
	self.msg_type = 1722
end

function SCMillionaireInfo:Decode()
	self.gather_total_times = MsgAdapter.ReadShort()
	self.is_millionaire = MsgAdapter.ReadChar()
	self.is_turn = MsgAdapter.ReadChar()
	self.reward_index = MsgAdapter.ReadShort()
	self.millionaire_use_skill_times = MsgAdapter.ReadShort()	-- 冰冻技能使用次数
	self.millionaire_last_perform_skill_time = MsgAdapter.ReadUInt()	--冰冻技能下次可使用时间
end

-- 走棋子奖励信息返回
SCMoveChessStepRewardInfo = SCMoveChessStepRewardInfo or BaseClass(BaseProtocolStruct)
function SCMoveChessStepRewardInfo:__init()
	self.msg_type = 1723
end

function SCMoveChessStepRewardInfo:Decode()
	self.item_count = MsgAdapter.ReadInt()
	self.reward_list = {}
	for i = 1,self.item_count do
		local attr_obj = {}
		attr_obj.step = MsgAdapter.ReadInt()
		attr_obj.item_id = MsgAdapter.ReadUShort()
		attr_obj.item_num = MsgAdapter.ReadShort()
		table.insert(self.reward_list, attr_obj)
	end
end

-------------------------炼魂-----------------------------------------
--锻造炼魂升级请求
CSEquipmentLianhunUplevel = CSEquipmentLianhunUplevel or BaseClass(BaseProtocolStruct)
function CSEquipmentLianhunUplevel:__init()
	self.msg_type = 1795
	self.equip_index = 0
	self.is_auto_buy = 0
end

function CSEquipmentLianhunUplevel:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.equip_index)
	MsgAdapter.WriteShort(self.is_auto_buy)
end

------------------------------

CSFriendExpBottleOP = CSFriendExpBottleOP or BaseClass(BaseProtocolStruct)
function CSFriendExpBottleOP:__init()
	self.msg_type = 1790
end

function CSFriendExpBottleOP:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.type)
end

SCFriendExpBottleAddExp = SCFriendExpBottleAddExp or BaseClass(BaseProtocolStruct)
function SCFriendExpBottleAddExp:__init()
	self.msg_type = 1791
end

function SCFriendExpBottleAddExp:Decode()
	self.next_broadcast_time = MsgAdapter.ReadInt()
	self.get_exp_count = MsgAdapter.ReadInt()
	self.exp = MsgAdapter.ReadLL()
	self.auto_add_friend_count = MsgAdapter.ReadInt()
end

-------------------------一键完成-----------------------------------------
CSSkipReq = CSSkipReq or BaseClass(BaseProtocolStruct)
function CSSkipReq:__init()
	self.msg_type = 1793
end

function CSSkipReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.type)
	MsgAdapter.WriteInt(self.param)
end

--彩装合成
CSColorEquipmentComposeReq = CSColorEquipmentComposeReq or BaseClass(BaseProtocolStruct)
function CSColorEquipmentComposeReq:__init()
	self.msg_type = 1794
	self.target_equipment_id = 0
	self.stuff_knapsack_index_list = {}
end

function CSColorEquipmentComposeReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.target_equipment_id)
	local count = #self.stuff_knapsack_index_list
	MsgAdapter.WriteInt(count)
	for i= 1, count do
		MsgAdapter.WriteShort(self.stuff_knapsack_index_list[i])
	end
end

----------------------------红装合成-----------------------------
CSRedColorEquipCompose = CSRedColorEquipCompose or BaseClass(BaseProtocolStruct)
function CSRedColorEquipCompose:__init()
	self.msg_type = 1796
	self.stuff_knapsack_index_list = {}				-- 材料背包下标列表
	self.stuff_index_count = 0 						-- 材料下标有效个数
	self.target_equipment_index = 0 				-- 合成目标装备下标
end

function CSRedColorEquipCompose:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	--暂定最多4个合成材料
	for i = 1, 4 do
		MsgAdapter.WriteShort(self.stuff_knapsack_index_list[i] or 0)
	end
	MsgAdapter.WriteShort(self.stuff_index_count)
	MsgAdapter.WriteShort(self.target_equipment_index)
end