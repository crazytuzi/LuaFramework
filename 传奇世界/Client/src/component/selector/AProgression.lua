return { new = function(params)
local Myoung = require "src/young/young"; local M = Myoung.beginFunction()
------------------------------------------------------------------------------------
local params = params or {}
local sp = math.max(params.sp or 0, 0)
local ep = math.max(math.max(params.ep or 0, 0), sp)
local step = math.max(params.step or 1, 1)

local phantomSp = math.floor((sp + (step - 1)) / step) * step
local phantomEp = math.floor((ep + (step - 1)) / step) * step

local total = (phantomEp - phantomSp) / step + 1

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
	if pos == (self.mCount - 1) then
		return self.mEp
	elseif pos == 0 then
		return self.mSp
	else
		return self.mSp + self.mStep * pos
	end
	
end

positionAtNumber = function(self, number)
	if number == self.mEp then
		return self.mCount - 1
	elseif number == self.mSp then
		return 0
	else
		return (number - self.mSp)/self.mStep
	end
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
------------------------------------------------------------------------------------
return M
end }