require "Core.Net.PtType";

--[[
PtDemoCommand - 上行包
null

PtDemoCommand - 下行包
{
	int field1
	int field2
	object field3	{
		int field4
		string field5
	}
	array field6 {
		[i] = {}
	}
}
]]
--[[
PtDemoUp = {
	field1,	--int 
	field2	--int
};
function PtDemoUp:New()
	o = {}
	setmetatable(o, self);
	self.__index = self;
	return o;
end

--field1 int
PtDemoDown = {
	field1,	--int 
	field2	--int
};
function PtDemoDown:New()
	o = {}
	setmetatable(o, self);
	self.__index = self;
	return o;
end
--]]
PtDemoCommand = PtCommand:New();
PtDemoCommand:Init(PtType.PT_DEMO, "Just a Demo");

function PtDemoCommand:WriteBody(buffer, up)
	--将up包内的内容写入buffer中
	buffer:WriteInt(up.field1);
	buffer:WriteInt(up.field2);
	return buffer;
end

function PtDemoCommand:ReadBody(buffer)
	--读取数据组建down包
	local down = {};--PtDemoDown:New();
	down.field1 = buffer:ReadInt();
	down.field2 = buffer:ReadInt();
	return down;
end

function PtDemoCommand:HasBody()
	return true;
end
