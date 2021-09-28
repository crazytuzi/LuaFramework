return { new = function(params)
local M = Myoung.beginFunction()
------------------------------------------------------------------------------------
local params = params or { src = "+", }
if not params.src then params.src = "+" end

local switch = 
{
	-- 数据是等差数列
	["+"] = function(params)
		return require("src/component/selector/AProgression").new(params)
	end,
	
	-- 数据是等比数列
	["*"] = function(params)
		return require("src/component/selector/GProgression").new(params)
	end,
	
	-- 定制的数据
	["table"] = function(params)
		return require("src/component/selector/customized").new(params)
	end,
	
}

local case = switch[params.src] or switch[type(params.src)]
mDelegate = case(params)

------------------------------------------------------------------------------------
numberAtPosition = function(self, pos)
	return self.mDelegate:numberAtPosition(pos)
end

positionAtNumber = function(self, number)
	return self.mDelegate:positionAtNumber(number)
end

currentPosition = function(self, pos)
	return self.mDelegate:currentPosition(pos)
end

count = function(self)
	return self.mDelegate:count()
end

currentValue = function(self)
	return self.mDelegate:numberAtPosition( self.mDelegate:currentPosition() )
end
------------------------------------------------------------------------------------
return M
end }