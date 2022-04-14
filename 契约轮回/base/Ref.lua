--
-- Author: LaoY
-- Date: 2018-07-10 16:24:16
-- 计数器

Ref = Ref or class("Ref")
local math_max = math.max

function Ref:ctor(abName)
	-- 用于调试
	self.abName = abName
	self._referenceCount = 0
	-- self:Retain()
end

function Ref:dctor()
	self:Clear()
end

function Ref:GetReferenceCount()
	return self._referenceCount
end

function Ref:Retain(count)
	count = count or 1
	self._referenceCount = self._referenceCount + count
end

function Ref:Release(count)
	count = count or 1
	self._referenceCount = math_max(0,self._referenceCount - count)
end

function Ref:Clear()
	self._referenceCount = 0
end

function Ref:Debug()
	print('--LaoY Ref.lua,line 37-- data=',self.abName or "",self._referenceCount)
end