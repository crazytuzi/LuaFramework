_G._LMovieAcition = {
	typeid = _MovieAction.typid,
	tickCount = -1,
	steps,
	execStack
}

local mt = {__index = _LMovieAcition}
function _LMovieAcition.new()
	local ma = setmetatable({}, mt)
	ma.steps = {}
	ma.execStack = {}
	return ma
end

function _LMovieAcition:clone(action)
	for i, v in ipairs(self.steps) do
		action.steps[i]:clone(v)
	end
end

function _LMovieAcition:update(elapse, movie)
	local oldTick = self.tickCount
	self.tickCount = self.tickCount + elapse
	if not movie.scene or elapse <= 0 then return end

	local endFlag = true
	for i, v in ipairs(self.steps) do
		if (v.start == 0 and oldTick == 0) or (v.start > oldTick and v.start <= self.tickCount) then
			v:Start(movie)
			table.insert(self.execStack, 1, v)
		end
		if v.stop >= self.tickCount or v.start >= self.tickCount then
			endFlag = false
		end
		if v.start < self.tickCount and v.stop > self.tickCount and v.bindRole ~= '' then
			local bindNode = movie:getRole(v.bindRole)
			local node = movie:getRole(v.role)
			if bindNode and bindNode.mesh and bindNode.mesh.skeleton and node.mesh then
				local mat = _Matrix3D.new()
				mat.root = v.bindTarget ~= '' and bindNode.mesh.skeleton:getBone(v.bindTarget)
				mat.root = bindNode.transform
				node.transform = mat
			end
		end
	end

	for i, v in ipairs(self.steps) do
		if v.stop > v.start and (v.stop > oldTick and v.stop <= self.tickCount) then
			v:TimeUp(movie)
		end
	end

	for i, v in ipairs(self.execStack) do
		v:update(elapse)
	end

	if endFlag then
		self.tickCount = -1
		self.isPlaying = false
	end
end

function _LMovieAcition:stopbyMovie(movie)
	for i, v in ipairs(self.execStack) do
		v:Stop(movie)
	end

	self.execStack = {}
	self.tickCount = -1
	self.isPlaying = false
end

function _LMovieAcition:stop()
	self.tickCount = -1
	self.isPlaying = false
end

function _LMovieAcition:play()
	self.tickCount = 0
	self.isPlaying = true
end

function _LMovieAcition:addStep()
	local step = _LMovieStep.new()
	table.insert(self.steps, step)
	return step
end

function _LMovieAcition:clearSteps()
	self.steps = {}
end

function _LMovieAcition:delStep(step)
	for i, v in ipairs(self.steps) do
		if v == step then
			table.remove(self.steps, i)
			break
		end
	end
end

function _LMovieAcition:getStep(index)
	if type(index) == 'string' then
		for i, v in ipairs(self.steps) do
			if v.name == index then
				return self.steps[i]
			end
		end
	elseif type(index) == 'number' then
		return self.steps[index]
	end
end

function _LMovieAcition:getSteps()
	return self.steps
end

--------------test----------------
-- local function test()
	-- local ma = _LMovieAcition.new()
-- end
-- test()