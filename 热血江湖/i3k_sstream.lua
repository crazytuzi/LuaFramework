
local require = require

require("i3k_global")

i3k_sstream = 
{
	STREAM_SEPARATOR = "\001",
	NIL = "\002",
	EOF_ERROR = "EOF",
	DECODE_ERROR = "DECODE ERROR"
}

local function get_table_size(t)
	local n = 0
	for _, _ in pairs(t) do
		n = n + 1
	end
	return n
end

local function split(str, d)
	local lst = { }
	local n = #str
	local start = 1
	while start <= n do
		local i = string.find(str, d, start) -- find 'next' 0
		if i == nil then 
			table.insert(lst, string.sub(str, start, n))
			break 
		end
		table.insert(lst, string.sub(str, start, i-1))
		if i == n then
			table.insert(lst, "")
			break
		end
		start = i + 1
	end
	return lst
end

local ostream = i3k_class("ostream");
function ostream:ctor()
	self._vector = { }
end

function ostream:pushString(s)
	if s == nil then
		table.insert(self._vector, i3k_sstream.NIL)
	else
		table.insert(self._vector, s)
	end
	return self
end

function ostream:pushBool(b)
	return self:pushString(b and "1" or "0")
end

function ostream:pushNumber(n)
	return self:pushString(n == nil and "0" or tostring(n))
end

function ostream:pushSizeT(n)
	return self:pushNumber(n)
end

function ostream:pushByteBuffer(bb)
	--TODO
	return self:pushString(bb)
end

function ostream:pushSet_(set, func)
	if set == nil then
		table.insert(self._vector, i3k_sstream.NIL)
		return self
	end
	self:pushSizeT(get_table_size(set))
	for k, _ in pairs(set) do
		func(self, k)
	end
	return self
end

function ostream:pushMap_(map, funcK, funcV)
	if map == nil then
		table.insert(self._vector, i3k_sstream.NIL)
		return self
	end
	self:pushSizeT(get_table_size(map))
	for k, v in pairs(map) do
		funcK(self, k)
		funcV(self, v)
	end
	return self
end

function ostream:pushBoolList(lst)
	return self:pushList_(lst, ostream.pushBool)
end

function ostream:pushBoolSet(set)
	return self:pushSet_(set, ostream.pushBool)
end

function ostream:pushNumberBoolMap(map)
	return self:pushMap_(map, ostream.pushNumber, ostream.pushBool)
end

function ostream:pushStringBoolMap(map)
	return self:pushMap_(map, ostream.pushString, ostream.pushBool)
end

function ostream:pushNumberList(lst)
	return self:pushList_(lst, ostream.pushNumber)
end

function ostream:pushNumberSet(set)
	return self:pushSet_(set, ostream.pushNumber)
end

function ostream:pushNumberNumberMap(map)
	return self:pushMap_(map, ostream.pushNumber, ostream.pushNumber)
end

function ostream:pushStringNumberMap(map)
	return self:pushMap_(map, ostream.pushString, ostream.pushNumber)
end

function ostream:pushStringList(lst)
	return self:pushList_(lst, ostream.pushString)
end

function ostream:pushStringSet(set)
	return self:pushSet_(set, ostream.pushString)
end

function ostream:pushNumberStringMap(map)
	return self:pushMap_(map, ostream.pushNumber, ostream.pushString)
end

function ostream:pushStringStringMap(map)
	return self:pushMap_(map, ostream.pushString, ostream.pushString)
end

function ostream:pushByteBufferList(lst)
	return self:pushList_(lst, ostream.pushByteBuffer)
end

function ostream:pushByteBufferSet(set)
	return self:pushSet_(set, ostream.pushByteBuffer)
end

function ostream:pushNumberByteBufferMap(map)
	return self:pushMap_(map, ostream.pushNumber, ostream.pushByteBuffer)
end

function ostream:pushStringByteBufferMap(map)
	return self:pushMap_(map, ostream.pushString, ostream.pushByteBuffer)
end

function ostream:pushList_(lst, func)
	if lst == nil then
		table.insert(self._vector, i3k_sstream.NIL)
		return self
	end
	self:pushSizeT(#lst)
	for _, e in ipairs(lst) do
		func(self, e)
	end
	return self
end

function ostream:pushList(lst)
	return self:pushList_(lst, ostream.push)
end

function ostream:pushNumberMap(map)
	return self:pushMap_(map, ostream.pushNumber, ostream.push)
end

function ostream:pushStringMap(map)
	return self:pushMap_(map, ostream.pushString, ostream.push)
end

function ostream:push(obj)
	if obj == nil then
		table.insert(self._vector, i3k_sstream.NIL)
		return self
	end
	self:pushString("1")
	obj:encode(self)
	return self
end

function ostream:toString()
	local n = #self._vector
	local s = ""
	for k = 1, n do
		local e = self._vector[k]
		s = s .. e
		if k < n then
			s = s .. i3k_sstream.STREAM_SEPARATOR
		end
	end
	return s
end

function i3k_sstream.encode(obj)
	local os = ostream.new()
	os:push(obj)
	return os:toString()
end

local istream = i3k_class("istream");
function istream:ctor(src)
	self._vector = nil
	self._nextPos = 1
	if src then
		self._vector = split(src, i3k_sstream.STREAM_SEPARATOR)
	end
end

function istream:hasMoreData()
	return self._vector and self._nextPos <= #self._vector
end

function istream:popString()
	if not self:hasMoreData() then
		error(i3k_sstream.EOF_ERROR)
	end
	local s = self._vector[self._nextPos]
	if not s or s == i3k_sstream.NIL then
		self._nextPos = self._nextPos + 1
		return nil
	end
	self._nextPos = self._nextPos + 1
	return s
end

function istream:popBool()
	local s = self:popString()
	if not s or s == "0" then
		return false
	end
	return true
end

function istream:popNumber()
	local s = self:popString()
	if not s then
		return nil
	end
	return tonumber(s)
end

function istream:popSizeT()
	return self:popNumber()
end

function istream:popByteBuffer()
	local s = self:popString()
	--TODO
	return s
end

function istream:testNextNil()
	if not self:hasMoreData() then
		error(i3k_sstream.EOF_ERROR)
	end
	local s = self._vector[self._nextPos]
	if not s or s == i3k_sstream.NIL then
		self._nextPos = self._nextPos + 1
		return true
	end
	return false
end

function istream:popList_(func)
	if self:testNextNil() then
		return nil
	end
	local size = self:popSizeT()
	if size < 0 then
		error(i3k_sstream.DECODE_ERROR)
	end
	local lst = { }
	for k = 1, size do
		table.insert(lst, func(self))
	end
	return lst
end

function istream:popList(cls)
	return self:popList_(function(is)
		return is:pop(cls)
	end)
end

function istream:popBoolList()
	return self:popList_(istream.popBool)
end

function istream:popNumberList()
	return self:popList_(istream.popNumber)
end

function istream:popSet_(func)
	if self:testNextNil() then
		return nil
	end
	local size = self:popSizeT()
	if size < 0 then
		error(i3k_sstream.DECODE_ERROR)
	end
	local set = { }
	for k = 1, size do
		set[func(self)] = true
	end
	return set
end

function istream:popNumberSet()
	return self:popSet_(istream.popNumber)
end

function istream:popStringSet()
	return self:popSet_(istream.popString)
end

function istream:popMap_(funcK, funcV)
	if self:testNextNil() then
		return nil
	end
	local size = self:popSizeT()
	if size < 0 then
		error(i3k_sstream.DECODE_ERROR)
	end
	local map = { }
	for k = 1, size do
		local _k = funcK(self)
		map[_k] = funcV(self)
	end
	return map
end

function istream:popNumberMap(cls)
	return self:popMap_(istream.popNumber, function(is)
		return is:pop(cls)
	end)
end

function istream:popStringMap(cls)
	return self:popMap_(istream.popString, function(is)
		return is:pop(cls)
	end)
end

function istream:popNumberBoolMap()
	return self:popMap_(istream.popNumber, istream.popBool)
end

function istream:popNumberNumberMap()
	return self:popMap_(istream.popNumber, istream.popNumber)
end
function istream:popNumberStringMap()
	return self:popMap_(istream.popNumber, istream.popString)
end
function istream:popNumberByteBufferMap()
	return self:popMap_(istream.popNumber, istream.popByteBuffer)
end

function istream:popStringBoolMap()
	return self:popMap_(istream.popString, istream.popBool)
end

function istream:popStringNumberMap()
	return self:popMap_(istream.popString, istream.popNumber)
end
function istream:popStringStringMap()
	return self:popMap_(istream.popString, istream.popString)
end
function istream:popStringByteBufferMap()
	return self:popMap_(istream.popString, istream.popByteBuffer)
end

function istream:popStringList()
	return self:popList_(istream.popString)
end

function istream:popByteBufferList()
	return self:popList_(istream.popByteBuffer)
end

function istream:pop(cls)
	if not cls or self:testNextNil() then
		return nil
	end
	self:popString()
	local obj = cls.new()
	obj:decode(self)
	return obj
end

function i3k_sstream.decode(src, cls)
	if cls.fastDecode then
		return cls.fastDecode(split(src, i3k_sstream.STREAM_SEPARATOR))
	end
	local is = istream.new(src)
	return is:pop(cls)
end

function i3k_sstream.detectPacketName(str)
	local d = i3k_sstream.STREAM_SEPARATOR
	local n = string.len(str)
	local start = 1
	local nFound = 0
	while start <= n do
		local i = string.find(str, d, start) -- find 'next' 0
		if i == nil then 
			if nFound == 1 then
				local name = string.sub(str, start, n)
				if name == i3k_sstream.NIL then
					return nil
				end
				return name
			end
			return nil 
		end
		local name = string.sub(str, start, i-1)
		nFound = nFound + 1
		if nFound == 2 then
			if name == i3k_sstream.NIL then
				return nil
			end
			return name
		end
		start = i + 1
	end
	return nil
end

i3k_sstream.ostream = ostream
i3k_sstream.istream = istream