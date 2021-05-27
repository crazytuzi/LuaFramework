
MsgAdapter = MsgAdapter or {}

function MsgAdapter.GetSendMsgType()
	return GameNet.Instance.msg_handler:GetSendMsgType()
end

function MsgAdapter.SetSendMsgType(msg_type)
	GameNet.Instance.msg_handler:SetSendMsgType(msg_type)
end

-- 读
function MsgAdapter.ReadChar()
	return GameNet.Instance.msg_handler:ReadChar()
end

function MsgAdapter.ReadUChar()
	return GameNet.Instance.msg_handler:ReadUChar()
end

function MsgAdapter.ReadShort()
	return GameNet.Instance.msg_handler:ReadShort()
end

function MsgAdapter.ReadUShort()
	return GameNet.Instance.msg_handler:ReadUShort()
end

function MsgAdapter.ReadInt()
	return GameNet.Instance.msg_handler:ReadInt()
end

function MsgAdapter.ReadUInt()
	return GameNet.Instance.msg_handler:ReadUInt()
end

function MsgAdapter.ReadLL()
	return GameNet.Instance.msg_handler:ReadLL()
end

function MsgAdapter.ReadFloat()
	return GameNet.Instance.msg_handler:ReadFloat()
end

function MsgAdapter.ReadDouble()
	return GameNet.Instance.msg_handler:ReadDouble()
end

function MsgAdapter.ReadStr()
	return GameNet.Instance.msg_handler:ReadStr()
end

function MsgAdapter.ReadStrN(str_len)
	return GameNet.Instance.msg_handler:ReadStrN(str_len)
end

function MsgAdapter.ReadResult()
	return GameNet.Instance.msg_handler:ReadResult()
end

-- 写
function MsgAdapter.WriteBegin(msg_type)
	GameNet.Instance.msg_handler:WriteBegin()
	if msg_type then
		GameNet.Instance.msg_handler:SetSendMsgType(msg_type)
	end
end

function MsgAdapter.WriteChar(value)
	GameNet.Instance.msg_handler:WriteChar(value)
end

function MsgAdapter.WriteUChar(value)
	GameNet.Instance.msg_handler:WriteUChar(value)
end

function MsgAdapter.WriteShort(value)
	GameNet.Instance.msg_handler:WriteShort(value)
end

function MsgAdapter.WriteUShort(value)
	GameNet.Instance.msg_handler:WriteUShort(value)
end

function MsgAdapter.WriteInt(value)
	GameNet.Instance.msg_handler:WriteInt(value)
end

function MsgAdapter.WriteUInt(value)
	GameNet.Instance.msg_handler:WriteUInt(value)
end

function MsgAdapter.WriteLL(value)
	GameNet.Instance.msg_handler:WriteLL(value)
end

function MsgAdapter.WriteFloat(value)
	GameNet.Instance.msg_handler:WriteFloat(value)
end

function MsgAdapter.WriteDouble(value)
	GameNet.Instance.msg_handler:WriteDouble(value)
end

function MsgAdapter.WriteStrN(str, str_len)
	return GameNet.Instance.msg_handler:WriteStrN(str, str_len)
end

-- 会自动写入一个int表示字符串长度
function MsgAdapter.WriteStr(str)
	return GameNet.Instance.msg_handler:WriteStr(str)
end


-- 发送消息
function MsgAdapter.Send(netid)
	return GameNet.Instance.msg_handler:Send(netid or GameNet.Instance.recv_msg_net_id)
end
