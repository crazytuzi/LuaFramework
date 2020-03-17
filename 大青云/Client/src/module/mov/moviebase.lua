_G._LMovie = {
	dx = 0,
	dy = 0,
}

local mt = {__index = _LMovie}
function _LMovie.new(fileName, scene)
	local movie = setmetatable({}, mt)
	if fileName then
		local data = _dofile(fileName)
		data.resname = fileName
		movie:load(data, scene)
	else
		movie:init()
	end
	return movie
end

_G._Trace = {}
function _Trace.new()
	local trace = {}
	trace.eyeOrbit = _Orbit.new()
	trace.lookOrbit = _Orbit.new()
	trace.name = ''
	return trace
end

local function initTrace(graData)
	graData.traces = {}
	function graData:addTrace(trace)
		table.insert(graData.traces, trace)
		graData:addOrbit(trace.eyeOrbit)
		graData:addOrbit(trace.lookOrbit)
	end
	function graData:delTrace(trace)
		for i, v in ipairs(graData.traces) do
			if v == trace then
				table.remove(graData.traces, i)
				graData:delOrbit(v.eyeOrbit)
				graData:delOrbit(v.lookOrbit)
			end
		end
	end
	function graData:clearTraces()
		graData.traces = {}
		graData:clearOrbits()
	end
	function graData:getTrace(index)
		if type(index) == 'string' then
			for i, v in pairs(graData.traces) do
				if v.name == index then
					return v
				end
			end
		elseif type(index) == 'number' then
			return graData.traces[index]
		end
	end
	function graData:getTraces()
		return graData.traces
	end
end

function _LMovie:init()
	self.scene = _Scene.new()
	self.senName = ''
	self.resname = ''
	self.roles = {}
	self.graData = _GraphicsData.new()
	initTrace(self.graData)
	self.pfxPlayer = _ParticlePlayer.new()
	self.pfxPlayer2D = _ParticlePlayer.new()
	self.pfxPlayer.terrain = self.scene.terrain
	self.actions = {}
end

local function renderSceneNode(node)
	if node.terrain then
		node.terrain:draw()
	elseif node.mesh then
		if node.blender then
			_rd:useBlender(node.blender)
		end
		node.mesh:drawMesh()
		if node.blender then
			_rd:popBlender()
		end
	end
end

function _LMovie:load(data, scene)
	self.scene = scene or _Scene.new(data.senName)
	self.senName = data.senName
	self.resname = data.resname
	self.pfxPlayer2D = _ParticlePlayer.new()
	self.pfxPlayer = _ParticlePlayer.new()
	self.pfxPlayer.terrain = self.scene.terrain
	self.roles = {}
	self.actions = {}
	for i, v in ipairs(data.roles) do
		local mesh = _Mesh.new()
		if type(v.res.skn) == 'string' then
			local subMesh = _Mesh.new(v.res.skn)
			subMesh.name = _sys:getFileName(v.res.skn, false)
			mesh:addSubMesh(subMesh)
		elseif type(v.res.skn) == 'table' then
			for p, q in ipairs(v.res.skn) do
				local subMesh = _Mesh.new(q)
				subMesh.name = _sys:getFileName(q, false)
				mesh:addSubMesh(subMesh)
			end
		end
		if v.res.skl then
			mesh.skeleton = _Skeleton.new(v.res.skl)
			for p, q in pairs(v.res.sans) do
				if _sys:fileExist(q.resname) then
					local san = mesh.skeleton:addAnima(q.resname)
					san.pri = q.pri
					san.loop = q.loop
					san.name = q.name and q.name or _sys:getFileName(q.resname, false, false)
				end
			end
		end
		local mat = _Matrix3D.new()
		if v.r then
			mat:setRotationZ(v.r):mulTranslationRight(v.x, v.y, v.z)
		elseif v.rot then
			mat:setRotation(v.rot.x, v.rot.y, v.rot.z, v.rot.r)
			mat:mulTranslationRight(v.trans.x, v.trans.y, v.trans.z)
			mat:mulScalingLeft(v.scale.x, v.scale.y, v.scale.z)
		end
		local node = self.scene:add(mesh, mat)
		node.name = v.name
		table.insert(self.roles, node)
	end
	self.graData = _GraphicsData.new()
	initTrace(self.graData)
	for i, v in ipairs(data.markers) do
		local mat = _Matrix3D.new():setRotation(v.rot.x, v.rot.y, v.rot.z, v.rot.r)
		mat:mulTranslationRight(v.trans.x, v.trans.y, v.trans.z)
		mat:mulScalingLeft(v.scale.x, v.scale.y, v.scale.z)
		mat.name = v.name
		self.graData:addMarker(mat)
	end
	for i, v in ipairs(data.cameras) do
		local c = _Camera.new()
		c.look:set(v.look.x, v.look.y, v.look.z)
		c.eye:set(v.eye.x, v.eye.y, v.eye.z)
		c.fov = v.fov or 45
		c.name = v.name
		self.graData:addCamera(c)
	end
	if not data.traces then data.traces = {} end
	for i, v in ipairs(data.traces) do
		local t = _Trace.new()
		local eyeData = {}
		for p, q in ipairs(v.eyeOrbit) do
			table.insert(eyeData, {time = q.time, pos = _Vector3.new(q.x, q.y, q.z)})
		end
		local lookData = {}
		for p, q in ipairs(v.lookOrbit) do
			table.insert(lookData, {time = q.time, pos = _Vector3.new(q.x, q.y, q.z)})
		end
		t.lookOrbit:create(lookData)
		t.eyeOrbit:create(eyeData)
		t.eyeOrbit.cubicSpline = v.eyeOrbit.cubicSpline
		t.lookOrbit.cubicSpline = v.lookOrbit.cubicSpline
		t.name = v.name
		self.graData:addTrace(t)
	end
	for i, v in pairs(data.actions) do
		local action = self:addAction(i)
		for p, q in ipairs(v) do
			local step = action:addStep()
			step.anima = q.anima and q.anima or step.anima
			step.bindRole = q.bindRole and q.bindRole or step.bindRole
			step.bindTarget = q.bindTarget and q.bindTarget or step.bindTarget
			step.camera = q.camera and self.graData:getCamera(q.camera) or step.camera
			step.cameraLinear = q.cameraLinear and q.cameraLinear or step.cameraLinear
			step.event = q.event and q.event or step.event
			step.fadeFrom = q.fadeFrom and q.fadeFrom or step.fadeFrom
			step.fadeTo = q.fadeTo and q.fadeTo or step.fadeTo
			step.resourceName = q.resourceName and q.resourceName or step.resourceName
			step.resourceType = q.resourceType and q.resourceType or step.resourceType
			step.pfxdx = q.pfxdx and q.pfxdx or step.pfxdx
			step.pfxdy = q.pfxdy and q.pfxdy or step.pfxdy
			step.pfxScale = q.pfxScale and q.pfxScale or step.pfxScale
			step.onTerrain = q.onTerrain and q.onTerrain or step.onTerrain
			step.pfx = q.pfx and q.pfx or step.pfx
			step.role = q.role and q.role or step.role
			step.sfx = q.sfx and q.sfx or step.sfx
			step.sfxStartType = q.sfxStartType and q.sfxStartType or step.sfxStartType
			step.sfxStopType = q.sfxStopType and q.sfxStopType or step.sfxStopType
			step.linearRolloff = q.linearRolloff and q.linearRolloff or step.linearRolloff
			step.minDistance = q.minDistance and q.minDistance or step.minDistance
			step.maxDistance = q.maxDistance and q.maxDistance or step.maxDistance
			step.sfxMarker = q.sfxMarker and self.graData:getMarker(q.sfxMarker) or step.sfxMarker
			step.sfxRole = q.sfxRole and q.sfxRole or step.sfxRole
			step.shake = q.shake and q.shake or step.shake
			step.showRole = q.showRole and q.showRole or step.showRole
			step.speed = q.speed and q.speed or step.speed
			step.start = q.start and q.start or step.start
			step.stop = q.stop and q.stop or step.stop
			step.trace = q.trace and q.trace or step.trace
			step.target = q.target and self.graData:getMarker(q.target) or q.target
			step.turnTarget = q.turnTarget and self.graData:getMarker(q.turnTarget) or step.turnTarget
			step.turnRole = q.turnRole and q.turnRole or step.turnRole
			step.rotTarget = q.rotTarget and self.graData:getMarker(q.rotTarget) or step.rotTarget
			step.rotation = q.rotation and q.rotation or step.rotation
			step.rotMode = q.rotMode and q.rotMode or step.rotMode
			if q.scaleTarget then
				step.scaleTarget = self.graData:getMarker(q.scaleTarget)
			end
		end
	end
	-- self.scene:onRender(renderSceneNode)
end

local function writeTable2File(t, file, name)
	local function indent(level, ...)
		local line = table.concat({('	'):rep(level), ...})
		file:write(line .. '\r\n')
	end
	local function dumpval(level, key, value)
		local index
		if not key then
			index = 'return '
		elseif type(key) == 'number' then
			index = string.format('[%d] = ', key)
		else -- String. -- bug key is a number[string]
			index = key .. ' = '
		end
		if type(value) == 'table' then
			indent(level, index, '{')
			for k, v in next, value do
				dumpval(level + 1, k, v)
			end
			if not key then
				indent(level, '}')
			else
				indent(level, '},')
			end
		else
			if type(value) == 'string' then
				if string.len(value) > 40 then
					indent(level, index, '[[', value, ']],')
				else
					indent(level, index, string.format('%q,', value))
				end
			else
				indent(level, index, tostring(value), ',')
			end
		end
	end
	dumpval(0, name, t)
end

function _LMovie:save(fileName)
	local file = _File.new()
	self.fileName = fileName or self.fileName
	file:create(self.fileName)
	local t = {}
	t.senName = self.senName
	t.roles = {}
	for i, v in ipairs(self.roles) do
		local trans = v.transform:getTranslation()
		local rot = v.transform:getRotation()
		local scale = v.transform:getScaling()
		local res = {}
		res["sans"] = {}
		if v.mesh and v.mesh.skeleton then
			res["skl"] = v.mesh.skeleton.resname
			for p, q in ipairs(v.mesh.skeleton:getAnimas()) do
				table.insert(res["sans"], {pri = q.pri, resname = q.resname, loop = q.loop, name = q.name})
			end
		else
			res["skl"] = ""
		end
		res["skn"] = {}
		for p, q in ipairs(v.mesh:getSubMeshs()) do
			table.insert(res["skn"], q.resname)
		end
		t.roles[i] = {name = v.name, res = res, trans = {x = trans.x, y = trans.y, z = trans.z}, rot = {x = rot.x, y = rot.y, z = rot.z, r = rot.r}, scale = {x = scale.x, y = scale.y, z = scale.z}}
	end
	t.markers = {}
	for i, v in ipairs(self.graData:getMarkers()) do
		local trans = v:getTranslation()
		local rot = v:getRotation()
		local scale = v:getScaling()
		table.insert(t.markers, {trans = {x = trans.x, y = trans.y, z = trans.z}, rot = {x = rot.x, y = rot.y, z = rot.z, r = rot.r}, scale = {x = scale.x, y = scale.y, z = scale.z}, name = v.name})
	end
	t.cameras = {}
	for i, v in ipairs(self.graData:getCameras()) do
		if not v.trace then
			table.insert(t.cameras, {eye = {x = v.eye.x, y = v.eye.y, z = v.eye.z}, look = {x = v.look.x, y = v.look.y, z = v.look.z}, fov = v.fov, name = v.name})
		end
	end
	t.traces = {}
	for i, v in ipairs(self.graData:getTraces()) do
		local eyeOrbit = {}
		for p, q in ipairs(v.eyeOrbit:getKeyframes()) do
			table.insert(eyeOrbit, {time = q.time, x = q.pos.x, y = q.pos.y, z = q.pos.z})
		end
		eyeOrbit.cubicSpline = v.eyeOrbit.cubicSpline
		local lookOrbit = {}
		for p, q in ipairs(v.lookOrbit:getKeyframes()) do
			table.insert(lookOrbit, {time = q.time, x = q.pos.x, y = q.pos.y, z = q.pos.z})
		end
		lookOrbit.cubicSpline = v.lookOrbit.cubicSpline
		table.insert(t.traces, {eyeOrbit = eyeOrbit, lookOrbit = lookOrbit, name = v.name})
	end
	t.actions = {}
	for i, v in ipairs(self.actions) do
		local actTemp = {}
		for p, q in ipairs(v.steps) do
			local temp = {}
			temp.anima = q.anima
			temp.bindRole = q.bindRole
			temp.bindTarget = q.bindTarget
			if q.camera then
				temp.camera = q.camera.name
			end
			temp.cameraLinear = q.cameraLinear
			temp.event = q.event
			temp.fadeFrom = q.fadeFrom
			temp.fadeTo = q.fadeTo
			temp.resourceName = q.resourceName
			temp.resourceType = q.resourceType
			temp.pfxdx = q.pfxdx
			temp.pfxdy = q.pfxdy
			temp.pfxScale = q.pfxScale
			temp.onTerrain = q.onTerrain
			temp.pfx = q.pfx
			temp.role = q.role
			temp.sfx = q.sfx
			temp.sfxStartType = q.sfxStartType
			temp.sfxStopType = q.sfxStopType
			temp.linearRolloff = q.linearRolloff
			temp.minDistance = q.minDistance
			temp.maxDistance = q.maxDistance
			if q.sfxMarker then
				temp.sfxMarker = q.sfxMarker.name
			end
			if q.sfxRole then
				temp.sfxRole = q.sfxRole
			end
			temp.shake = q.shake
			temp.showRole = q.showRole
			temp.speed = q.speed
			temp.start = q.start
			temp.stop = q.stop
			temp.trace = q.trace
			if q.target then
				temp.target = q.target.name
			end
			if q.rotTarget then
				temp.rotTarget = q.rotTarget.name
			end
			if q.turnTarget then
				temp.turnTarget = q.turnTarget.name
			end
			if q.turnRole then
				temp.turnRole = q.turnRole
			end
			temp.rotation = q.rotation
			temp.rotMode = q.rotMode
			if q.scaleTarget then
				temp.scaleTarget = q.scaleTarget.name
			end
			table.insert(actTemp, temp)
		end
		t.actions[v.name] = actTemp
	end
	writeTable2File(t, file)
	file:close()
end

function _LMovie:addRole(role, mat)
	if role.typeid ~= _Mesh.typeid then return end
	if not self.scene then return end

	local node = self.scene:add(role, mat)
	table.insert(self.roles, node)
	return node
end

function _LMovie:clearRoles()
	for i, v in ipairs(self.roles) do
		self.scene:del(self.roles[i])
	end
	self.roles = {}
end

function _LMovie:delRole(index)
	if type(index) == 'string' then
		if not self.scene then return end

		for i, v in ipairs(self.roles) do
			if v.name == index then
				self.scene:del(v)
				table.remove(self.roles, i)
				break
			end
		end
	elseif type(index) == 'number' then
		if not self.scene or not self.roles[index] then return end

		self.scene:del(self.roles[index])
		table.remove(self.roles, index)
	end
end

function _LMovie:getRole(index)
	if type(index) == 'string' then
		for i, v in pairs(self.roles) do
			if v.name == index then
				return v
			end
		end
	elseif type(index) == 'number' then
		return self.roles[index]
	end
end

function _LMovie:getRoleCount()
	return #self.roles
end

function _LMovie:getRoles()
	return self.roles
end

function _LMovie:changeRole(roleName, newMesh)
	local oldNode = self.scene:getNode(roleName)
	local inScene = false
	for i, v in ipairs(self.scene:getNodes()) do
		if v.mesh == newMesh then
			inScene = true
		end
	end
	if inScene then
		self:delRole(roleName)
		table.insert(self.roles, newMesh.node)
		newMesh.node.name = roleName
	else
		local newNode = self:addRole(newMesh, oldNode.transform:clone())
		self:delRole(roleName)
		newNode.name = roleName
	end
end

function _LMovie:refreshRoles()
	for i = 1, #self.roles do
		local role = self.roles[i]
		if role.mesh and role.mesh.skeleton then
			local animas = role.mesh.skeleton:getAnimas()
			role.mesh.skeleton = _Skeleton.new(role.mesh.skeleton.resname)
			for i, v in ipairs(animas) do
				local san = role.mesh.skeleton:addAnima(v.resname)
				san.name = v.name
			end
		end
	end
end

function _LMovie:addAction(name)
	local action = _LMovieAcition.new()
	action.name = name
	table.insert(self.actions, action)
	return action
end

function _LMovie:clearActions()
	self.actions = {}
end

function _LMovie:delAction(index)
	if type(index) == 'string' then
		for i, v in ipairs(self.actions) do
			if v.name == index then
				table.remove(self.actions, i)
				break
			end
		end
	elseif type(index) == 'number' then
		table.remove(self.actions, index)
	end
end

function _LMovie:getAction(index)
	if type(index) == 'string' then
		for i, v in pairs(self.actions) do
			if v.name == index then
				return self.actions[i]
			end
		end
	elseif type(index) == 'number' then
		return self.actions[index]
	end
end

function _LMovie:getActionCount()
	return #self.actions
end

function _LMovie:getActions()
	return self.actions
end

function _LMovie:update(elapse)
	local endFlag = true
	for i, v in pairs(self.actions) do
		if v.isPlaying then
			v:update(elapse, self)
			self.isPlaying = true
			endFlag = false
		end
	end
	if endFlag and self.isPlaying then
		for i, v in pairs(self.actions) do
			v.isPlaying = true
		end
		self:stop()
	end
end

local trans = _Vector3.new()
function _LMovie:updateScene(elapse)
	for i, v in ipairs(self.roles) do
		if v.isOnTerrain then
			v.transform:getTranslation(trans)
			self.scene.terrain.heightLayer = 1
			local dz = self.scene.terrain:getHeight(trans.x, trans.y) - trans.z
			self.scene.terrain.heightLayer = 0
			v.transform:mulTranslationRight(0, 0, dz)
		end
	end
end

function _LMovie:draw(elapse)
	self:updateScene(elapse)
	if self.scene then
		self.scene:render()
	end
	self:update(elapse)
	if self.cameraNode then
		local skeleton = self.cameraNode.mesh.skeleton
		if skeleton and skeleton.resname ~= '' then
			local cameye = skeleton:getBone('camera_eye')
			local camlook = skeleton:getBone('camera_look')
			if cameye and camlook then
				cameye.parent = self.cameraNode.transform
				camlook.parent = self.cameraNode.transform
				_rd.camera.eye = cameye:getTranslation()
				_rd.camera.look = camlook:getTranslation()
				_rd.camera.up.z = 1
			end
		end
	end
	self.pfxPlayer2D:draw2D(_rd.w/2 + self.dx, _rd.h/2 + self.dy)
end

function _LMovie:stop()
	self:onBeforeStop()
	for i, v in ipairs(self.actions) do
		if v.isPlaying then
			v:stopbyMovie(self)
			v:play()
			v:update(0, self)
			v:stop()
		end
	end
	self.isPlaying = false
	self:onStop()
end

function _LMovie:set2DXY(dx, dy)
	self.dx = dx and dx or self.dx
	self.dy = dy and dy or self.dy
end

function _LMovie:cameraStartByRole(node)
	self.cameraNode = node
end

function _LMovie:cameraEndByRole(node)
	self.cameraNode = nil
end

function _LMovie:onEvent() end
function _LMovie:onStopEvent() end
function _LMovie:onStop() end
function _LMovie:onBeforeStop() end
