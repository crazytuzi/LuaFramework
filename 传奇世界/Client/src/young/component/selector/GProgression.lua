
return { new = function(params)
local Myoung = require "src/young/young"; local M = Myoung.beginFunction()
------------------------------------------------------------------------------------
local params = params or {}
local sp = math.max(params.sp or 0, 0)
local ep = math.max(math.max(params.ep or 0, 0), sp)
local step = math.max(params.step or 1, 1)
local total = (ep - sp) / step + 1

local adjustStep = function()
	if total % 1 ~= 0 then
		step = 1 
		total = ep - sp + 1
	end
end; adjustStep()

local cp = math.min(math.max(params.cp or ep, sp), ep)


mSp = sp
mEp = ep
mStep = step
mCount = total

-- dump(mSp, "mSp")
-- dump(mEp, "mEp")
-- dump(mStep, "mStep")
-- dump(mCount, "mCount")
-- dump(cp, "cp")

------------------------------------------------------------------------------------

numberAtPosition = function(self, pos)
	assert(pos >= 0 and pos < self.mCount, "index out of range")
	return self.mSp + self.mStep * pos
end

positionAtNumber = function(self, number)
	return (number - self.mSp)/self.mStep
end

currentPosition = function(self, pos)
	if pos then
		assert(pos >= 0 and pos < self.mCount, "index out of range")
		self.mCp = pos
	else
		return self.mCp
	end
end; M:currentPosition( M:positionAtNumber(cp) )


count = function(self)
	return self.mCount
end

currentValue = function(self)
	return self:numberAtPosition( self:currentPosition() )
end
------------------------------------------------------------------------------------
return M
end }