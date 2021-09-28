PtCommand = {code = 0, desc=""};

function PtCommand:New()
	local o = {}
	setmetatable(o, self);
	self.__index = self;
	return o;
end

function PtCommand:Init(code, desc)
	self.code = code;
	self.desc = desc;
end

function PtCommand:WriteHeader(buffer)
	buffer:WriteInt(self.code);
	buffer:WriteInt(0);
    --增加其他需要放在协议头内的内容
    return buffer;
end

function PtCommand:WriteBody(buffer, up)
	--将up包内的内容写入buffer中
	return buffer;
end

function PtCommand:ReadHeader(buffer)
	local code = buffer:ReadInt();--协议号
	local errCode = buffer:ReadInt();
	--增加其他需要放在协议头内的内容
	return code, errCode;
end

function PtCommand:ReadBody(buffer)
	--读取数据组建down包
	return nil;
end

function PtCommand:HasBody()
	return false;
end

--Write方法由发送协议时调用
function PtCommand:Write(up)
	local buffer = ByteBuffer.New();	
	self:WriteHeader(buffer);
	self:WriteBody(buffer, up);
	return buffer;
end

--Read方法由发送协议时调用
function PtCommand:Read(buffer)
	local code, errCode = self:ReadHeader(buffer);
	local down = self:ReadBody(buffer);
	return code, errCode, down;
end
