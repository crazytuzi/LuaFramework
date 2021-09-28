BINUtil = {}
BINUtil.__index = BINUtil

function BINUtil:new()
	local self = {}
	setmetatable(self, BINUtil)
	return self
end

function BINUtil:release()
	if self.fs then
		PFS.StreamFactory:GetStreamFactory():ReleaseStreamPtr(self.fs)
		self.fs = nil
	end
end

function BINUtil:init(filename)
	self.file = PFSX.CSyncFile()
	if not self.file:Open(filename) then
		LogErr("BINUtil:init " .. filename .. " failed!")
		return false
	end
	print("BINUtil:init " .. filename .. " ok!")
	self.fs = PFS.StreamFactory:GetStreamFactory():GetFileStreamPtr(tolua.cast(self.file, "PFS::CBaseFile"))
--	self.fs = PFS.CFileStream(tolua.cast(self.file, "PFS::CBaseFile"))
	return true
end

function BINUtil:Load_int()
	local ret =  0
	local val
	val,ret = XMLCONFIG.BeanFromBIN_int(self.fs, ret)
	if     ret == 0 then
		ret = true
	elseif ret == -1 then
		ret = false
	end
	return ret, val
end

function BINUtil:Load_long()
	local ret =  0
	local val
	val,ret = XMLCONFIG.BeanFromBIN_long(self.fs, ret)
	if     ret == 0 then
		ret = true
	elseif ret == -1 then
		ret = false
	end
	return ret, val
end

function BINUtil:Load_double()
	local ret =  0
	local val
	val,ret = XMLCONFIG.BeanFromBIN_double(self.fs, ret)
	if     ret == 0 then
		ret = true
	elseif ret == -1 then
		ret = false
	end
	return ret, val
end

function BINUtil:Load_bool()
	local ret =  0
	local val
	val,ret = XMLCONFIG.BeanFromBIN_bool(self.fs, ret)
	if     ret == 0 then
		ret = true
	elseif ret == -1 then
		ret = false
	end
	return ret, val
end

function BINUtil:Load_string()
	local ret =  0
	local val
	val,ret = XMLCONFIG.BeanFromBIN_string(self.fs, ret)
	if     ret == 0 then
		ret = true
	elseif ret == -1 then
		ret = false
	end
	return ret, val
end

function BINUtil:Load_Vint()
	local ret = 0
	local val = {}
	local size = 0
	size,ret = XMLCONFIG.BeanFromBIN_size(self.fs, ret)
	if ret == -1 then
		return false
	end
	for i=1, size do
		ret,val[i-1] = self:Load_int(self.fs, ret)
		if not ret then
			return false
		end
	end
	return ret, val
end

function BINUtil:Load_Vlong()
	local ret = 0
	local val = {}
	local size = 0
	size,ret = XMLCONFIG.BeanFromBIN_size(self.fs, ret)
	if ret == -1 then
		return false
	end
	for i=1, size do
		ret,val[i-1] = self:Load_long(self.fs, ret)
		if not ret then
			return false
		end
	end
	return ret, val
end

function BINUtil:Load_Vdouble()
	local ret = 0
	local val = {}
	local size = 0
	size,ret = XMLCONFIG.BeanFromBIN_size(self.fs, ret)
	if ret == -1 then
		return false
	end
	for i=1, size do
		ret,val[i-1] = self:Load_double(self.fs, ret)
		if not ret then
			return false
		end
	end
	return ret, val
end

function BINUtil:Load_Vbool()
	local ret = 0
	local val = {}
	local size = 0
	size,ret = XMLCONFIG.BeanFromBIN_size(self.fs, ret)
	if ret == -1 then
		return false
	end
	for i=1, size do
		ret,val[i-1] = self:Load_bool(self.fs, ret)
		if not ret then
			return false
		end
	end
	return ret, val
end

function BINUtil:Load_Vstring()
	local ret = 0
	local val = {}
	local size = 0
	size,ret = XMLCONFIG.BeanFromBIN_size(self.fs, ret)
	if ret == -1 then
		return false
	end
	for i=1, size do
		ret,val[i-1] = self:Load_string(self.fs, ret)
		if not ret then
			return false
		end
	end
	return ret, val
end

return BINUtil
