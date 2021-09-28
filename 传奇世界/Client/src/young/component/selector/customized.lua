
return { new = function(params)
local Myoung = require "src/young/young"; local M = Myoung.beginFunction()
------------------------------------------------------------------------------------
local params = params or {}
if not params.src then params.src = { 0 } end
if #params.src == 0 then params.src[1] = 0 end

local adjustSrc = function(params)
	local tmp = {}
	for i, v in ipairs(params.src) do
		tmp[math.floor( math.abs(v) )] = true
	end
	
	params.src = {}
	local src = params.src
	for k in pairs(tmp) do
		src[#src + 1] = k
	end
	
	table.sort(src)
	
end; adjustSrc(params)

mSrc = params.src

if not params.cp then params.cp = params.src[#params.src] end

--dump(params, "params")

------------------------------------------------------------------------------------

numberAtPosition = function(self, pos)
	assert(pos >= 0 and pos < #self.mSrc, "index out of range")
	return self.mSrc[pos + 1]
end

positionAtNumber = function(self, number)
	local high, low = #self.mSrc, 1
	local found = false
	local middle = low
	
	while high >= low do
		middle = math.floor( (high + low)/2 )
		if number == self.mSrc[middle] then
			found = true; break
		elseif number < self.mSrc[middle] then
			found = false; high = middle - 1
		else
			found = false; low = middle + 1
		end
	end
	
	if not found then return end
	return middle - 1
end

currentPosition = function(self, pos)
	if pos then
		assert(pos >= 0 and pos < #self.mSrc, "index out of range")
		self.mCp = pos + 1
	else
		return self.mCp - 1
	end
end; M:currentPosition( M:positionAtNumber( math.floor(math.abs(params.cp)) ) or #params.src - 1 )

count = function(self)
	return #self.mSrc
end
------------------------------------------------------------------------------------
return M
end }