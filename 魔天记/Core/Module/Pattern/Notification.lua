Notification = {};

function Notification:New(name, body, type)
	local o = {};
	setmetatable(o, self);
	self.__index = self;
	
	--lua中没有私有成员这个概念，我们使用下划线开头表示私有变量
	o._name = name;--string
	o._body = body;--object
	o._type = type;--string
	return o;
end

function Notification:GetName()
	return self._name;
end

function Notification:GetBody()
	return self._body;
end

function Notification:GetType()
	return self._type;
end