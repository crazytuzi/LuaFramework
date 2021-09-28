local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)
--------------------------------------------------------------------------
push = function(this, value)
	table.insert(this.mStack, value)
end


pop = function(this)
	table.remove(this.mStack)
end

top = function(this)
	local stack = this.mStack
	return stack[#stack]
end

size = function(this)
	return #this.mStack
end

--------------------------------------------------------------------------
local init = function(this)
	this.mStack = {}
end

new = function(self)
	local this = Myoung.newSubModule(M)
	init(this)
	return this
end