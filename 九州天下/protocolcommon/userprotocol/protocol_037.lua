
--3750发送邮件
CSMailSend = CSMailSend or BaseClass(BaseProtocolStruct)

function CSMailSend:__init()
	self.msg_type = 3750
	self.recver_uid = 0
	self.gold = 0
	self.coin = 0
	self.item_count = 0						-- 发送的数量 最大为3个 发多少个附件就填写多少个
	self.item_knapindex_list = {0, 0, 0} 	-- 长度为3,物品的索引值
	self.item_comsume_num = {0, 0, 0}  		-- 长度为3,物品索引值的数量
	self.subject = ""
	self.contenttxt = ""
end

function CSMailSend:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.recver_uid)
	MsgAdapter.WriteInt(self.gold)
	MsgAdapter.WriteInt(self.coin)
	MsgAdapter.WriteShort(self.item_count)

	for i = 1 ,3 do
		MsgAdapter.WriteShort(self.item_knapindex_list[i])
	end
	for i = 1 ,3 do
		MsgAdapter.WriteInt(self.item_comsume_num[i])
	end

	MsgAdapter.WriteStrN(self.subject, 128)
	MsgAdapter.WriteStr(self.contenttxt)
end

--3751删除邮件
CSMailDelete = CSMailDelete or BaseClass(BaseProtocolStruct)

function CSMailDelete:__init()
	self.msg_type = 3751
	self.mail_index = 0
end

function CSMailDelete:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.mail_index)
end

--3752获取邮件列表
CSMailGetList = CSMailGetList or BaseClass(BaseProtocolStruct)

function CSMailGetList:__init()
	self.msg_type = 3752
end

function CSMailGetList:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--3753读取邮件
CSMailRead = CSMailRead or BaseClass(BaseProtocolStruct)

function CSMailRead:__init()
	self.msg_type = 3753
	self.mail_index = 0
end

function CSMailRead:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.mail_index)
end

--3754获取附件
CSMailFetchAttachment = CSMailFetchAttachment or BaseClass(BaseProtocolStruct)

function CSMailFetchAttachment:__init()
	self.msg_type = 3754
	self.mail_index = 0
	self.item_index = 0		--抓取单个物品时候指定索引 整体抓取设置为-1
	--self.item_num = 0
	self.is_last = 0
end

function CSMailFetchAttachment:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.mail_index)
	MsgAdapter.WriteInt(self.item_index)
	--MsgAdapter.WriteInt(self.item_num)
	MsgAdapter.WriteInt(self.is_last)
end

--3755清空邮件
CSMailClean = CSMailClean or BaseClass(BaseProtocolStruct)

function CSMailClean:__init()
	self.msg_type = 3755
end

function CSMailClean:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--3756 一键提取附件
CSMailOneKeyFetchAttachment = CSMailOneKeyFetchAttachment or BaseClass(BaseProtocolStruct)

function CSMailOneKeyFetchAttachment:__init()
	self.msg_type = 3756
end

function CSMailOneKeyFetchAttachment:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end