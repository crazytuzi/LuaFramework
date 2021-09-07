CSCrossCallStartCross = CSCrossCallStartCross or BaseClass(BaseProtocolStruct)
function CSCrossCallStartCross:__init()
	self.msg_type = 8996
	self.call_type = 0
	self.origin_server_role_id = 0
	self.name = 0
	self.post = 0
	self.camp = 0
	self.guild_id = 0
	self.activity_type = 0
	self.scene_id = 0
	self.scene_key = 0
	self.x = 0
	self.y = 0
	self.param = 0
end

function CSCrossCallStartCross:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.call_type)
	MsgAdapter.WriteInt(self.origin_server_role_id)
	MsgAdapter.WriteStrN(self.name, 32)
	MsgAdapter.WriteShort(self.post)
	MsgAdapter.WriteShort(self.camp)
	MsgAdapter.WriteInt(self.guild_id)
	MsgAdapter.WriteInt(self.activity_type)
	MsgAdapter.WriteInt(self.scene_id)
	MsgAdapter.WriteInt(self.scene_key)
	MsgAdapter.WriteInt(self.x)
	MsgAdapter.WriteInt(self.y)
	MsgAdapter.WriteInt(self.param)
end

-- 副本结束奖励
SCCommonFbGetRewardInfo = SCCommonFbGetRewardInfo or BaseClass(BaseProtocolStruct)
function SCCommonFbGetRewardInfo:__init()
	self.msg_type = 8997
end 

function SCCommonFbGetRewardInfo:Decode()
	self.fb_type = MsgAdapter.ReadInt()
	self.param_1 = MsgAdapter.ReadInt()
	self.param_2 = MsgAdapter.ReadInt()
	self.param_3 = MsgAdapter.ReadInt()
	self.item_count = MsgAdapter.ReadInt()
	self.item_list = {}
	for i = 1, self.item_count do
		local vo = {}
		vo.item_id = MsgAdapter.ReadUShort()
		vo.num = MsgAdapter.ReadShort()
		vo.is_bind = MsgAdapter.ReadChar()
		MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()
		self.item_list[i] = vo
	end
end
	
-- 首次进入场景
SCFirstEnterScene = SCFirstEnterScene or BaseClass(BaseProtocolStruct)
function SCFirstEnterScene:__init()
	self.msg_type = 8998
end

function SCFirstEnterScene:Decode()
	self.scene_id = MsgAdapter.ReadInt()
end


--时装界面请求
CSUseImages = CSUseImages or BaseClass(BaseProtocolStruct)
function CSUseImages:__init()
	self.msg_type = 8999
	self.index_list = {}
	self.mount_img_id = 0
	self.wing_img_id = 0
end

function CSUseImages:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	for i = 1, GameEnum.SHIZHUANG_TYPE_MAX do
		MsgAdapter.WriteInt(self.index_list[i])
	end

	MsgAdapter.WriteInt(self.mount_img_id)
	MsgAdapter.WriteInt(self.wing_img_id)
end