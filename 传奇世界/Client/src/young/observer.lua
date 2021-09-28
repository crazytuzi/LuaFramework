
local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)

reset = function(this)

	this.mObservers = {}
	
	this.mListToAdd = {}
	
	this.mTraversing = false
	
end


register = function(this, observer)
	--dump("register" .. tostring(observer))
	if type(observer) ~= "function" then
		error( "观察者只能是一个 'function'", 2)
	end
	
	-- 在遍历table的过程中加入原来不存在的的键值对的行为是未定义
	if not this.mTraversing then
		this.mObservers[observer] = 1
	else
		if this.mListToAdd[observer] then return end
		this.mListToAdd[observer] = 1
	end
end


unregister = function(this, observer)
	--dump("unregister" .. tostring(observer))
	-- 在遍历table的过程中修改或擦除已存在的键值对是安全的
	if this.mObservers[observer] then this.mObservers[observer] = nil end
	if this.mListToAdd[observer] then this.mListToAdd[observer] = nil end
end

-- 因为 一个观察者 可能对 一个可观察者 的多个事件感兴趣,
-- 也可能对 多个可观察者 的事件感兴趣, 因此
-- 广播事件的时候有必要把 可观察者 和 事件ID 传递给观察者
broadcast = function(this, observable, ...)
	this.mTraversing = true
	for observer in next, this.mObservers do
		observer(observable, ...)
	end
	this.mTraversing = false
	
	for observerToAdd, v in next, this.mListToAdd do
		this.mObservers[observerToAdd] = v
	end
	
	this.mListToAdd = {}
end

new = function()
	local this = Myoung.newSubModule(M)
	this:reset()
	return this
end