module(..., package.seeall)

local serialize = class("serialize")
serialize.open = function (self, filename, clear)
	self.saved = {}
	self.key = "v"
	self.filename = filename
	local filename = cc.FileUtils:getInstance():fullPathForFilename(filename)
	local dataModule, err = loadfile(filename)
	self.file, fileErr = io.open(filename, "w")

	if fileErr then
		error(fileErr)
	end

	local data = nil

	if not err and dataModule ~= nil then
		data = {}

		setfenv(dataModule, data)
		dataModule()

		data = data.v
	end

	data = data or {}

	if clear then
		self.file:write("v = {}\n")
		self.serialize_(self, self.key, data, self.saved)
		self.file:flush()
	end

	self.saved = {}
	local traAndCatchAll = nil

	local function catchChange(name, tbl)
		local caughtTbl = {
			__serialize_tbl = tbl
		}

		setmetatable(caughtTbl, {
			__index = tbl,
			__newindex = function (_, nk, nv)
				local nname = string.format("%s[%s]", name, serialize.basicSerialize(type(nk), nk))
				local t = type(nv)

				if nv ~= nil and not self.saved[nv] and tbl[nk] ~= nv then
					local value = nv

					if t == "table" then
						if nv.__serialize_tbl and self.saved[nv.__serialize_tbl] then
							value = nv.__serialize_tbl
						else
							nv = traAndCatchAll(nname, nv)
						end
					end

					self:serialize_(nname, value, self.saved)
					self.file:flush()
				end

				if t == "nil" and tbl[nk] then
					self:removeData_(name, nk, self.saved[nv])
				end

				rawset(tbl, nk, nv)

				return 
			end,
			__len = function ()
				return #tbl
			end
		})

		return caughtTbl
	end

	function traAndCatchAll(key, data)
		for kName, v in pairs(data) do
			if type(v) == "table" and not self.saved[v] then
				local nname = string.format("%s[%s]", key, serialize.basicSerialize(type(kName), kName))
				self.saved[v] = nname
				data[kName] = traAndCatchAll(nname, v)
			end
		end

		return catchChange(key, data)
	end

	self.data = slot7(self.key, data)

	return self.data
end
serialize.basicSerialize = function (t, o)
	if t == "number" then
		return tostring(o)
	elseif t == "string" then
		return string.format("%q", o)
	elseif t == "boolean" then
		return (o and "true") or "false"
	end

	return 
end
serialize.serialize_ = function (self, name, value, saved)
	local f = self.file

	f.write(f, name, " = ")

	local t = type(value)

	if t == "table" then
		if saved[value] then
			f.write(f, saved[value], "\n")
		else
			saved[value] = name

			f.write(f, "{}\n")

			for k, v in pairs(value) do
				if k ~= "__serialize_tbl" then
					local fieldname = nil
					local tkey = type(k)
					local strKey = serialize.basicSerialize(tkey, k)

					if strKey then
						fieldname = string.format("%s[%s]", name, strKey)
					else
						error(string.format("unsupport key type. typeis %s, value:", tkey), k)
					end

					self.serialize_(self, fieldname, v, saved)
				end
			end
		end
	else
		local strValue = serialize.basicSerialize(t, value)

		if strValue then
			f.write(f, strValue, "\n")
		else
			error(string.format("unsupport value type. typeis %s, value:", t), value)
		end
	end

	return 
end
serialize.removeData_ = function (self, name, key, tbl)
	local name = string.format("%s[%q]", name, key)

	for k, v in pairs(tbl) do
		if type(v) == "table" then
			local nname = string.format("%s[%q]", name, key)

			if self.saved[v] == nname then
				self.saved[v] = nil
			end
		end
	end

	self.file:write(name .. " = nil\n")

	return 
end
serialize.close = function (self)
	self.data = nil

	self.file:close()

	return 
end

if 0 < DEBUG and false then
	local s = serialize.new()
	local data = s.open(slot1, "../../testing.lua")
	data.testNumber = 0
	data.string = "string"
	data.testingNil = nil
	data.testingBoolean = true
	data.testingBoolean = false
	data.testtable = {
		test = "¶à²ã"
	}
	data.testremove = {}
	data.testremove = nil
	data.testref = data.testtable

	s.close(s)

	local s = serialize.new()
	local data = s.open(s, "../../testing.lua")

	assert(data.testNumber == 0, "should be number")
	assert(data.string == "string", "should be number")
	assert(data.testingNil == nil, "should be nil")
	assert(data.testingBoolean == false, "should be false")
	assert(type(data.testtable) == "table", "should be table")
	assert(data.testremove == nil, "should be nil")

	data.testtable.test2 = "should be exist"

	s.close(s)

	local s = serialize.new()
	local data = s.open(s, "../../testing.lua")

	assert(data.testtable.test2)
	s.file:close()
end

return serialize
