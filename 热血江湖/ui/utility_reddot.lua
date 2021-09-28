module(..., package.seeall)

--xxxtodo: add doc
--xxxtodo: test passive task
--xxxtodo: add root node query
--xxxtodo: add node map query

local i3k_callback = require("ui/utility_callback").i3k_callback

-------------红点-----------------------------
local _redots = {}

i3k_reddot = i3k_class("i3k_reddot")

--获取最新
local function mIsRed(self)
	for _, __ in pairs(self._reds) do
		return true
	end
	
	for k, _ in pairs(self._task) do
		if type(k) == "function" then
			if k() then
				return true
			end
		elseif k:queryRed() then
			return true
		end
	end
	
	for k, _ in pairs(self._children) do
		if k:isRed() then
			return true
		end
	end
	return false
end

--更新到最新并判断执行回调
local function mCheckChange(self)
	local before = self._currentRed
	local latest = mIsRed(self)	--这个函数有可能更新本节点并执行回调， 故需加判断
	if latest ~= before and self._currentRed == before then
		self._currentRed = latest
		self._onChange(self, self._currentRed)
		for k, _ in pairs(self._parents) do
			k:isRed()	--更新父红点
		end
	end
end

function i3k_reddot:ctor(...)
	self._children = {}
	self._parents = {}
	self._onChange = i3k_callback.new(true)
	self._currentRed = false
	self._reds = setmetatable({}, {__mode = 'k'})	--所有有推送的任务
	self._task = setmetatable({}, {__mode = 'k'})   --所有需要轮询是否有推送的任务
	_redots = self
	self:addParents(...)
end

function i3k_reddot:addParents(...)
	local parents = {...}
	for _, v in ipairs(parents) do
		if not self._parents[v] then
			self._parents[v] = true
			v:addChildren(self)
		end
	end
end

function i3k_reddot:removeParents(...)
	local parents = {...}
	for _, v in ipairs(parents) do
		if self._parents[v] then
			self._parents[v] = nil
			v:removeChildren(self)
		end
	end
end

function i3k_reddot:addChildren(...)
	local children = {...}
	for _, v in ipairs(children) do
		if not self._children[v] then
			self._children[v] = true
			v:addParents(self)
		end
	end
	mCheckChange(self)
end

function i3k_reddot:removeChildren(...)
	local children = {...}
	for _, v in ipairs(children) do
		if self._children[child] then
			self._children[child] = nil
			v:removeParents(self)
		end
	end
	mCheckChange(self)
end

--推送有可完成的任务
--任务使用weak table储存，因lua5.1不支持__gc，故任务销毁后需手动更新
function i3k_reddot:push(task)
	if not self._reds[task] then
		self._reds[task] = true
		mCheckChange(self)
	end
end

--清除推送
function i3k_reddot:archive(task)
	if self._reds[task] then
		self._reds[task] = nil
		mCheckChange(self)
	end
end

--添加被动任务，可以是函数也可以是有queryRed函数的表/对象，返回true则显示红点
--任务使用weak table储存，请勿使用匿名函数
function i3k_reddot:addTask(task)
	assert(type(task) == "function" or task.queryRed, "task must be a function or a table contains queryRed function")
	self._task[task] = true
	mCheckChange(self)
end

function i3k_reddot:removeTask()
	self._task[task] = nil
	mCheckChange(self)
end

--当前是否显示红点，此函数会刷新被动任务
function i3k_reddot:isRed()
	mCheckChange(self)
	return self._currentRed
end

--添加红点变化时的回调,可叠加
--回调使用weak table储存，请勿使用匿名函数
function i3k_reddot:addChangeCallback(cb, ...)
	self._onChange:add(cb, ...)
end

function i3k_reddot:removeChangeCallback(cb)
	self._onChange:remove(cb)
end
