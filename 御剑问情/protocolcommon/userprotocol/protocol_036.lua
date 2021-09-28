-- 称号列表返回
SCTitleList = SCTitleList or BaseClass(BaseProtocolStruct)
function SCTitleList:__init()
	self.msg_type = 3600

	self.title_list = {}
end

function SCTitleList:Decode()
	self.title_list = {}
	local title_count = MsgAdapter.ReadInt()
	self.upgrade_list = {}
	for i = 1, MAX_TITLE_COUNT_TO_SAVE do
		local vo = {}
		vo.title_id = MsgAdapter.ReadShort()
		vo.grade = MsgAdapter.ReadChar()
		MsgAdapter.ReadChar()
		self.upgrade_list[i] = vo
	end
	for i = 1, title_count do
		self.title_list[i] = {}
		self.title_list[i].title_id = MsgAdapter.ReadUShort()
		MsgAdapter.ReadShort()
		self.title_list[i].expired_time = MsgAdapter.ReadUInt()
	end
end

--激活的称号返回
SCUsedTitleList = SCUsedTitleList or BaseClass(BaseProtocolStruct)
function SCUsedTitleList:__init()
	self.msg_type = 3601
	self.use_jingling_titleid = 0
	self.count = 0
	self.used_title_list = {}
end

function SCUsedTitleList:Decode()
	self.use_jingling_titleid = MsgAdapter.ReadInt()
	self.count = MsgAdapter.ReadShort()
	for i = 1, self.count do
		local title_id = MsgAdapter.ReadUShort()
		self.used_title_list[i] = title_id
	end
end

--场景中称号的改变广播
SCRoleUsedTitleChange = SCRoleUsedTitleChange or BaseClass(BaseProtocolStruct)
function SCRoleUsedTitleChange:__init()
	self.msg_type = 3602

	self.obj_id = 0
	self.use_jingling_titleid = 0
	self.count = 0
	self.title_active_list = {}
end

function SCRoleUsedTitleChange:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.use_jingling_titleid = MsgAdapter.ReadShort()
	self.count = MsgAdapter.ReadShort()
	self.title_active_list = {}
	for i = 1, self.count do
		local title_id = MsgAdapter.ReadUShort()
		table.insert(self.title_active_list, title_id)
	end
end

-- 发送称号列表请求
CSGetTitleList = CSGetTitleList or BaseClass(BaseProtocolStruct)
function CSGetTitleList:__init()
	self.msg_type = 3650
end

function CSGetTitleList:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 发送使用称号请求
CSUseTitle = CSUseTitle or BaseClass(BaseProtocolStruct)
function CSUseTitle:__init()
	self.msg_type = 3651
	self.title_active_list = {}
end

function CSUseTitle:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	for i = 1, 3 do
		if nil ~= self.title_active_list[i] then
			MsgAdapter.WriteUShort(self.title_active_list[i])
		else
			MsgAdapter.WriteUShort(0)
		end
	end
	MsgAdapter.WriteShort(0)
end

-- 发送称号进阶请求
CSUpgradeTitle = CSUpgradeTitle or BaseClass(BaseProtocolStruct)
function CSUpgradeTitle:__init()
	self.msg_type = 3652
	self.title_id = 0
end

function CSUpgradeTitle:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteUShort(self.title_id)
	MsgAdapter.WriteShort(0)
end