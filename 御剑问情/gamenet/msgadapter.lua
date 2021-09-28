
MsgAdapter = MsgAdapter or {}

-- 读
local read_buf = ""
local read_index = 1
local temp_value = nil

function MsgAdapter.InitReadMsg(_read_buf)
	read_buf = _read_buf
	read_index = 1
end

function MsgAdapter.ReadChar()
	temp_value, read_index = struct.unpack("<i1", read_buf, read_index)
	return temp_value or 0
end

function MsgAdapter.ReadUChar()
	temp_value, read_index = struct.unpack("<I1", read_buf, read_index)
	return temp_value or 0
end

function MsgAdapter.ReadShort()
	temp_value, read_index = struct.unpack("<i2", read_buf, read_index)
	return temp_value or 0
end

function MsgAdapter.ReadUShort()
	temp_value, read_index = struct.unpack("<I2", read_buf, read_index)
	return temp_value or 0
end

function MsgAdapter.ReadInt()
	temp_value, read_index = struct.unpack("<i4", read_buf, read_index)
	return temp_value or 0
end

function MsgAdapter.ReadUInt()
	temp_value, read_index = struct.unpack("<I4", read_buf, read_index)
	return temp_value or 0
end

function MsgAdapter.ReadLL()
	local temp_low = MsgAdapter.ReadUInt()
	local temp_high = MsgAdapter.ReadUInt()
	return temp_low + (temp_high * (2 ^ 32))
end

function MsgAdapter.ReadFloat()
	temp_value, read_index = struct.unpack("<f", read_buf, read_index)
	return temp_value or 0
end

function MsgAdapter.ReadDouble()
	temp_value, read_index = struct.unpack("<d", read_buf, read_index)
	return temp_value or 0
end

local temp_0_index = nil
function MsgAdapter.ReadStrN(str_len)
	temp_value, read_index = struct.unpack("<c" .. str_len, read_buf, read_index)
	temp_0_index = string.find(temp_value, "\0")
	if nil ~= temp_0_index then
		temp_value = string.sub(temp_value, 1, temp_0_index - 1)
	end
	return temp_value or ""
end

-- 写
local write_fmt = ""
local write_value_list = {}

function MsgAdapter.WriteBegin(msg_type)
	write_fmt = "!4I2i2"
	write_value_list = {msg_type, 0}
end

function MsgAdapter.WriteChar(value)
	write_fmt = write_fmt .. "i1"
	table.insert(write_value_list, value)
end

function MsgAdapter.WriteUChar(value)
	write_fmt = write_fmt .. "I1"
	table.insert(write_value_list, value)
end

function MsgAdapter.WriteShort(value)
	write_fmt = write_fmt .. "i2"
	table.insert(write_value_list, value)
end

function MsgAdapter.WriteUShort(value)
	write_fmt = write_fmt .. "I2"
	table.insert(write_value_list, value)
end

function MsgAdapter.WriteInt(value)
	write_fmt = write_fmt .. "i4"
	table.insert(write_value_list, value)
end

function MsgAdapter.WriteUInt(value)
	write_fmt = write_fmt .. "I4"
	table.insert(write_value_list, value)
end

function MsgAdapter.WriteLL(value)
	write_fmt = write_fmt .. "i8"
	table.insert(write_value_list, value)
end

function MsgAdapter.WriteFloat(value)
	write_fmt = write_fmt .. "f"
	table.insert(write_value_list, value)
end

function MsgAdapter.WriteDouble(value)
	write_fmt = write_fmt .. "d"
	table.insert(write_value_list, value)
end

function MsgAdapter.WriteStrN(str, str_len)
	write_fmt = write_fmt .. "c"..str_len
	if string.len(str) < str_len then
		str = str .. string.rep("\0", str_len - string.len(str))
	end
	table.insert(write_value_list, str)
end

-- 会自动写入一个int表示字符串长度
function MsgAdapter.WriteStr(str)
	local str_len = string.len(str)
	MsgAdapter.WriteInt(str_len)
	MsgAdapter.WriteStrN(str, str_len)
end

-- 发送消息
local send_buf = ""
function MsgAdapter.Send(net)
	send_buf = struct.pack(write_fmt, unpack(write_value_list))
	net = net or GameNet.Instance:GetCurNet()
	GameNet.Instance:GetCurNet():SendMsg(send_buf, nil)
end
