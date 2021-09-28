-- 大表情升级请求
CSBigChatFaceUpLevelReq = CSBigChatFaceUpLevelReq or BaseClass(BaseProtocolStruct)
function CSBigChatFaceUpLevelReq:__init()
	self.msg_type = 8275
end

function CSBigChatFaceUpLevelReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 土豪金升级请求
CSTuhaojinUpLevelReq = CSTuhaojinUpLevelReq or BaseClass(BaseProtocolStruct)
function CSTuhaojinUpLevelReq:__init()
	self.msg_type = 8276
end

function CSTuhaojinUpLevelReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--星座系统所有信息
SCChineseZodiacAllInfo = SCChineseZodiacAllInfo or BaseClass(BaseProtocolStruct)
function SCChineseZodiacAllInfo:__init()
	self.msg_type = 8200
end

function SCChineseZodiacAllInfo:Decode()
		self.zodiac_level_list = {}
	for i = 1, GameEnum.CHINESE_ZODIAC_SOUL_MAX_TYPE_LIMIT do
		self.zodiac_level_list[i] = MsgAdapter.ReadShort()
	end

	self.xinghun_level_list = {}
	for i = 1, GameEnum.CHINESE_ZODIAC_SOUL_MAX_TYPE_LIMIT do
		self.xinghun_level_list[i] = MsgAdapter.ReadShort()
	end

	self.xinghun_level_max_list = {}
	for i = 1, GameEnum.CHINESE_ZODIAC_SOUL_MAX_TYPE_LIMIT do
		self.xinghun_level_max_list[i] = MsgAdapter.ReadShort()
	end

	self.xinghun_baoji_value_list = {}
	for i = 1, GameEnum.CHINESE_ZODIAC_SOUL_MAX_TYPE_LIMIT do
		self.xinghun_baoji_value_list[i] = MsgAdapter.ReadShort()
	end

	self.chinesezodiac_equip_list = {}
	for i = 1, GameEnum.CHINESE_ZODIAC_SOUL_MAX_TYPE_LIMIT do
		local vo = {}
		for j = 1, GameEnum.CHINESE_ZODIAC_EQUIP_SLOT_MAX_LIMIT do
			vo[j] = MsgAdapter.ReadShort()
		end
		self.chinesezodiac_equip_list[i] = vo
	end

	self.miji_list = {}
	for i = 1, GameEnum.CHINESE_ZODIAC_SOUL_MAX_TYPE_LIMIT do
		local vo = {}
		for j = 1, GameEnum.MIJI_KONG_NUM do
			vo[j] = MsgAdapter.ReadChar()
		end
		self.miji_list[i] = vo
	end

	self.zodiac_progress = MsgAdapter.ReadInt()
	self.upgrade_zodiac = MsgAdapter.ReadChar()
	self.xinghun_progress = MsgAdapter.ReadChar() + 1
end

--星座系统装备信息
SCChineseZodiacEquipInfo = SCChineseZodiacEquipInfo or BaseClass(BaseProtocolStruct)
function SCChineseZodiacEquipInfo:__init()
	self.msg_type = 8201
end

function SCChineseZodiacEquipInfo:Decode()
	self.zodiac_type = MsgAdapter.ReadShort()
	self.equip_type = MsgAdapter.ReadShort()
	self.equip_level = MsgAdapter.ReadInt()
end

-- 提升星座装备等级
CSChineseZodiacPromoteEquip = CSChineseZodiacPromoteEquip or BaseClass(BaseProtocolStruct)
function CSChineseZodiacPromoteEquip:__init()
	self.msg_type = 8203
	self.zodiac_type = 0
	self.equip_slot = 0
	self.is_auto_buy = 0
	self.param_1 = 0
end

function CSChineseZodiacPromoteEquip:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.zodiac_type)
	MsgAdapter.WriteShort(self.equip_slot)
	MsgAdapter.WriteShort(self.is_auto_buy)
	MsgAdapter.WriteShort(self.param_1)
end

-- 提升星座星魂等级
CSChineseZodiacPromote = CSChineseZodiacPromote or BaseClass(BaseProtocolStruct)
function CSChineseZodiacPromote:__init()
	self.msg_type = 8204
	self.zodiac_type = 0
	self.is_auto_buy = 0
end

function CSChineseZodiacPromote:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.zodiac_type)
	MsgAdapter.WriteShort(self.is_auto_buy)
end

-- 星途请求
CSTianxiangReq = CSTianxiangReq or BaseClass(BaseProtocolStruct)
function CSTianxiangReq:__init()
	self.msg_type = 8205
	self.info_type = 0
	self.param1 = 0
	self.param2 = 0
	self.param3 = 0
	self.param4 = 0
	self.param5 = 0
end

function CSTianxiangReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.info_type)
	MsgAdapter.WriteShort(self.param1)
	MsgAdapter.WriteShort(self.param2)
	MsgAdapter.WriteShort(self.param3)
	MsgAdapter.WriteShort(self.param4)
	MsgAdapter.WriteShort(self.param5)
end

--全部天象信息列表
SCTianXiangAllInfo = SCTianXiangAllInfo or BaseClass(BaseProtocolStruct)
function SCTianXiangAllInfo:__init()
	self.msg_type = 8206
end

function SCTianXiangAllInfo:Decode()
	self.curr_chapter = MsgAdapter.ReadChar()
	self.active_list = {}
	for j = 1, 5 do
		self.active_list[j] = {}
		for i = 1, GameEnum.TIAN_XIANG_ALL_CHAPTER_COMBINE do
			self.active_list[j][i] = MsgAdapter.ReadChar()
		end
	end
	self.chapter_list = {}
	self.bead_by_combine_list = {}
	-- for i= 0, self.curr_chapter do
	for i= 0, GameEnum.TIAN_XIANG_CHAPTER_NUM - 1 do
		local vo = {}
		for j = 1, GameEnum.TIAN_XIANG_TABEL_ROW_COUNT do
			vo[j] = {}
			for k = 1, GameEnum.TIAN_XIANG_TABEL_MIDDLE_GRIDS do
				vo[j][k] = MsgAdapter.ReadShort()
			end
		end
		local x = 0
		local y = 0
		self.chapter_list[i + 1] = vo
		local vo = {}
		for j = 0 , GameEnum.TIAN_XIANG_ALL_CHAPTER_COMBINE - 1 do
			for k = 1 , GameEnum.TIAN_XIANG_COMBINE_MEX_BEAD_NUM  do
				x = MsgAdapter.ReadShort()
				y = MsgAdapter.ReadShort()
				if x ~= -1 and y ~= -1 then
					vo[j] = vo[j] or {}
					vo[j][y] = vo[j][y] or {}
					vo[j][y][x] = j
				end
			end
		end
		self.bead_by_combine_list[i + 1] = vo
	end
	self.is_finish_all_chapter = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
end

--天象单个珠子
SCTianXiangSignBead = SCTianXiangSignBead or BaseClass(BaseProtocolStruct)
function SCTianXiangSignBead:__init()
	self.msg_type = 8207
end

function SCTianXiangSignBead:Decode()
	self.chapter = MsgAdapter.ReadInt()
	self.x = MsgAdapter.ReadChar()
	self.y = MsgAdapter.ReadChar()
	self.type = MsgAdapter.ReadShort()
end

--天象组合信息
SCTianXiangCombind = SCTianXiangCombind or BaseClass(BaseProtocolStruct)
function SCTianXiangCombind:__init()
	self.msg_type = 8208
end

function SCTianXiangCombind:Decode()
	self.active_list = {}
	for i = 1, GameEnum.TIAN_XIANG_ALL_CHAPTER_COMBINE do
		self.active_list[i] = MsgAdapter.ReadChar()
	end
	self.curr_chapter = MsgAdapter.ReadChar()
	self.bead_by_combine_list = {}
	local x = -1
	local y = -1
	for j = 0, GameEnum.TIAN_XIANG_ALL_CHAPTER_COMBINE - 1 do
		for k = 1, GameEnum.TIAN_XIANG_COMBINE_MEX_BEAD_NUM do
			x = MsgAdapter.ReadShort()
			y = MsgAdapter.ReadShort()
			if x ~= -1 and y ~= -1 then
				self.bead_by_combine_list[j] = self.bead_by_combine_list[j] or {}
				self.bead_by_combine_list[j][y] = self.bead_by_combine_list[j][y] or {}
				self.bead_by_combine_list[j][y][x] = j
			end
		end
	end
end

--滚滚乐信息
SCGunGunLeInfo = SCGunGunLeInfo or BaseClass(BaseProtocolStruct)
function SCGunGunLeInfo:__init()
	self.msg_type = 8209
end

function SCGunGunLeInfo:Decode()
	self.today_free_ggl_times = MsgAdapter.ReadInt()
	self.count = MsgAdapter.ReadInt()
	self.last_free_ggl_time = MsgAdapter.ReadUInt()
	self.combine_type = {}
	for i = 1, self.count do
		self.combine_type[i] = MsgAdapter.ReadInt()
	end
end

--秘籍单个修改
SCMijiSingleChange = SCMijiSingleChange or BaseClass(BaseProtocolStruct)
function SCMijiSingleChange:__init()
	self.msg_type = 8210
end

function SCMijiSingleChange:Decode()
	self.zodiac_type = MsgAdapter.ReadInt()
	self.kong_index = MsgAdapter.ReadInt()
	self.miji_index = MsgAdapter.ReadInt()
end

-- 秘籍合成成功
SCMijiCombineSucc = SCMijiCombineSucc or BaseClass(BaseProtocolStruct)
function SCMijiCombineSucc:__init()
	self.msg_type = 8211
end

function SCMijiCombineSucc:Decode()
	self.miji_index = MsgAdapter.ReadInt()
end

-- 星灵信息
SCXinglingInfo = SCXinglingInfo or BaseClass(BaseProtocolStruct)
function SCXinglingInfo:__init()
	self.msg_type = 8212
end

function SCXinglingInfo:Decode()
	self.xingling_list = {}
	for i = 1, GameEnum.TIAN_XIANG_SPIRIT_CHAPTER_NUM do
		self.xingling_list[i] = {}
		self.xingling_list[i].level = MsgAdapter.ReadInt()
		self.xingling_list[i].bless = MsgAdapter.ReadInt()
	end
end

-- 请求公会红包信息列表
CSGuildRedPaperListInfoReq = CSGuildRedPaperListInfoReq or BaseClass(BaseProtocolStruct)
function CSGuildRedPaperListInfoReq:__init()
	self.msg_type = 4214
end

function CSGuildRedPaperListInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 发工会红包
CSCreateGuildRedPaperReq = CSCreateGuildRedPaperReq or BaseClass(BaseProtocolStruct)
function CSCreateGuildRedPaperReq:__init()
	self.msg_type = 9829
	self.paper_seq = 0
	self.fetech_time = 0
	self.red_paper_index = 0
end

function CSCreateGuildRedPaperReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.paper_seq)
	MsgAdapter.WriteInt(self.fetech_time)
	MsgAdapter.WriteInt(self.red_paper_index)
end

-- 公会红包信息列表
SCGuildRedPocketListInfo = SCGuildRedPocketListInfo or BaseClass(BaseProtocolStruct)
function SCGuildRedPocketListInfo:__init()
	self.msg_type = 4215
	self.red_pocket_num = 0
	self.red_pocket_list = {}
end

function SCGuildRedPocketListInfo:Decode()
	self.red_pocket_num = MsgAdapter.ReadInt()
	self.red_pocket_list = {}
 	for i = 0, self.red_pocket_num - 1 do
		self.red_pocket_list[i] = {}
		self.red_pocket_list[i].owner_role_id = MsgAdapter.ReadInt()
		self.red_pocket_list[i].owner_role_name = MsgAdapter.ReadStrN(32)
		self.red_pocket_list[i].status = MsgAdapter.ReadShort()
		self.red_pocket_list[i].red_paper_seq = MsgAdapter.ReadShort()
		self.red_pocket_list[i].id = MsgAdapter.ReadInt()
		self.red_pocket_list[i].create_timestamp = MsgAdapter.ReadUInt()
		self.red_pocket_list[i].red_paper_index = MsgAdapter.ReadShort()
		self.red_pocket_list[i].is_fetch = MsgAdapter.ReadShort()
		self.red_pocket_list[i].avatar_key_big = MsgAdapter.ReadInt()
		self.red_pocket_list[i].avatar_key_small = MsgAdapter.ReadInt()
		self.red_pocket_list[i].sex = MsgAdapter.ReadChar()
		self.red_pocket_list[i].prof = MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()
	end
end

-- 公会红包，可发红包
SCNoticeGuildPaperInfo = SCNoticeGuildPaperInfo or BaseClass(BaseProtocolStruct)
function SCNoticeGuildPaperInfo:__init()
	self.msg_type = 9828
	self.notice_reson = -1
end

function SCNoticeGuildPaperInfo:Decode()
	self.notice_reson = MsgAdapter.ReadInt()
end

-- 私聊有红包未派发的玩家
CSSingleChatRedPaperRole = CSSingleChatRedPaperRole or BaseClass(BaseProtocolStruct)
function CSSingleChatRedPaperRole:__init()
	self.msg_type = 9830
	self.red_paper_index = 0
end

function CSSingleChatRedPaperRole:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.red_paper_index)
end
