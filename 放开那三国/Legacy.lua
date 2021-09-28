local function clone(object)
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		local new_table = {}
		lookup_table[object] = new_table
		for key, value in pairs(object) do
			new_table[_copy(key)] = _copy(value)
		end
		return setmetatable(new_table, getmetatable(object))
	end
	return _copy(object)
end

--Create an class.
local function class(classname, super)
	local superType = type(super)
	local cls

	if superType == 'table' then
		cls = clone(super)
		cls.__super = super
		cls.__tolua = super.__tolua
	else
		cls = {__construct = function() end}
	end

	cls.__cname = classname
	cls.__index = cls

	function cls.new(...)
		local instance = {}
		instance = setmetatable(instance, cls)
		instance.__class = cls
		instance:__construct(...)
		return instance
	end

	function cls:inherit(cinstance)
		if self.__tolua ~= nil then
			Logger.fatal("class:%s already has tolua binding", classname)
			return
		end

		tolua.inherit(self, cinstance)
		setmetatable(self, {__index = function(t, k)
			if cls[k] ~= nil then
				return cls[k]
			elseif cinstance[k] ~= nil then
				return cinstance[k]
			else
				return nil
			end
		end})
		self.__tolua = cinstance
	end

	return cls
end

Base64 = class("Base64")

function Base64.decodeWithZip(data)
	Logger.trace("decode:%s", data)
	data = CCCrypto:decodeBase64(data)
	return GameUtil:unzipData(data)
end

LuaEventHandler =  class("LuaEventHandler")

function LuaEventHandler:__construct(fn)
	self.mFunc = fn
end

function LuaEventHandler:create(fn)
	return LuaEventHandler.new(fn)
end

LuaTableView = class("LuaTableView")

function LuaTableView:__construct(handler, size)
	self:inherit(CCTableView:create(size))
	self:registerScriptHandler(function(table, cell)
		return handler.mFunc("cellTouched", table, cell)
	end, CCTableView.kTableCellTouched)

	self:registerScriptHandler(function(table, idx)
		local cell = self:dequeueCell()
		return handler.mFunc("cellAtIndex", table, idx, cell)
	end, CCTableView.kTableCellSizeAtIndex)

	self:registerScriptHandler(function(table, idx)
		local size = handler.mFunc("cellSize", table, idx)
		return size.height, size.width
	end, CCTableView.kTableCellSizeForIndex)

	self:registerScriptHandler(function(table)
		return handler.mFunc("numberOfCells", table)
	end, CCTableView.kNumberOfCellsInTableView)

	self:reloadData()
end

function LuaTableView:createWithHandler(handler, size)
	return LuaTableView.new(handler, size)
end

CCHttpRequest = class("CCHttpRequest")

function CCHttpRequest:__construct(request)
	self.mRequest = request
end

function CCHttpRequest:open(url, requestType)
	local request = LuaHttpRequest:newRequest()
	request:setUrl(url)
	request:setRequestType(requestType)
	return CCHttpRequest.new(request)
end

function CCHttpRequest:setRequestData(data, len)
	self.mRequest:setRequestData(data, len)
end

function CCHttpRequest:sendWithHandler(handler)
	self.mRequest:setResponseScriptFunc(function(client, response)
		handler(response, client)
	end)
	CCHttpClient:getInstance():send(self.mRequest)
	self.mRequest:release()
end

