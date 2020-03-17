_G._LMovieStep = {
	typeid = _MovieStep.typid
}

local mt = {__index = _LMovieStep}
function _LMovieStep.new()
	local ms = setmetatable({}, mt)
	ms:init()
	return ms
end

function _LMovieStep:init()
	self.anima = ''
	self.bindRole = ''
	self.bindTarget = ''
	self.camera = nil
	self.cameraLinear = _Camera.Linear
	self.event = ''
	self.fadeFrom = 0
	self.fadeTo = 0
	self.pfxdx = 0
	self.pfxdy = 0
	self.pfxScale = 1
	self.onTerrain = 0
	self.pfx = ''
	self.role = ''
	self.resourceName = ''
	self.resourceType = '3D' -- '2D'
	self.sfx = ''
	self.sfxStartType = 0
	self.sfxStopType = 0
	self.linearRolloff = _SoundDevice.LinearRolloff
	self.minDistance = 50
	self.maxDistance = 2000
	self.sfxMarker = nil
	self.sfxRole = nil
	self.shake = 0
	self.showRole = 0
	self.speed = -1
	self.start = 0
	self.stop = 0
	self.trace = ''
	self.target = nil
	self.turnTarget = nil
	self.turnRole = nil
	self.rotTarget = nil
	self.rotation = 0
	self.rotMode = 'local' -- 'world'
	self.scaleTarget = nil

	self.preMat = nil
	self.turnTime = 100
end

function _LMovieStep:print()
	print('-------------------print start-------------------')
	print(type(self.anima), 'anima', self.anima)
	print(type(self.bindRole), 'bindRole', self.bindRole)
	print(type(self.bindTarget), 'bindTarget', self.bindTarget)
	print(type(self.camera), 'camera', self.camera and self.camera.name or self.camera)
	print(type(self.cameraLinear), 'cameraLinear', self.cameraLinear)
	print(type(self.event), 'event', self.event)
	print(type(self.fadeFrom), 'fadeFrom', self.fadeFrom)
	print(type(self.fadeTo), 'fadeTo', self.fadeTo)
	print(type(self.resourceName), 'resourceName', self.resourceName)
	print(type(self.resourceType), 'resourceType', self.resourceType)
	print(type(self.pfxdx), 'pfxdx', self.pfxdx)
	print(type(self.pfxdy), 'pfxdy', self.pfxdy)
	print(type(self.pfxScale), 'pfxScale', self.pfxScale)
	print(type(self.onTerrain), 'onTerrain', self.onTerrain)
	print(type(self.pfx), 'pfx', self.pfx)
	print(type(self.role), 'role', self.role)
	print(type(self.sfx), 'sfx', self.sfx)
	print(type(self.sfxStartType), 'sfxStartType', self.sfxStartType)
	print(type(self.sfxStopType), 'sfxStopType', self.sfxStopType)
	print(type(self.linearRolloff), 'linearRolloff', self.linearRolloff)
	print(type(self.minDistance), 'minDistance', self.minDistance)
	print(type(self.maxDistance), 'maxDistance', self.maxDistance)
	print(type(self.sfxMarker), 'sfxMarker', self.sfxMarker)
	print(type(self.sfxRole), 'sfxRole', self.sfxRole)
	print(type(self.shake), 'shake', self.shake)
	print(type(self.showRole), 'showRole', self.showRole)
	print(type(self.speed), 'speed', self.speed)
	print(type(self.start), 'start', self.start)
	print(type(self.stop), 'stop', self.stop)
	print(type(self.trace), 'trace', self.trace)
	print(type(self.target), 'target', self.target and self.target.name or self.target)
	print(type(self.turnTarget), 'turnTarget', self.turnTarget and self.turnTarget.name or self.turnTarget)
	print(type(self.rotTarget), 'rotTarget', self.rotTarget and self.rotTarget.name or self.rotTarget)
	print(type(self.turnRole), 'turnRole', self.turnRole and self.turnRole.name or self.turnRole)
	print(type(self.rotation), 'rotation', self.rotation)
	print(type(self.rotMode), 'rotMode', self.rotMode)
	print(type(self.scaleTarget), 'scaleTarget', self.scaleTarget and self.scaleTarget.name or self.scaleTarget)
	print('----------------end----------------------')
end

function _LMovieStep:clone(step)
	step.anima = self.anima
	step.bindRole = self.bindRole
	step.bindTarget = self.bindTarget
	step.camera = self.camera
	step.cameraLinear = self.cameraLinear
	step.event = self.event
	step.fadeFrom = self.fadeFrom
	step.fadeTo = self.fadeTo
	step.resourceName = self.resourceName
	step.resourceType = self.resourceType
	step.pfxdx = self.pfxdx
	step.pfxdy = self.pfxdy
	step.pfxScale = self.pfxScale
	step.onTerrain = self.onTerrain
	step.pfx = self.pfx
	step.role = self.role
	step.sfx = self.sfx
	step.sfxStartType = self.sfxStartType
	step.sfxStopType = self.sfxStopType
	step.linearRolloff = self.linearRolloff
	step.minDistance = self.minDistance
	step.maxDistance = self.maxDistance
	step.sfxMarker = self.sfxMarker
	step.sfxRole = self.sfxRole
	step.shake = self.shake
	step.showRole = self.showRole
	step.speed = self.speed
	step.start = self.start
	step.stop = self.stop
	step.trace = self.trace
	step.target = self.target
	step.turnTarget = self.turnTarget
	step.rotTarget = self.rotTarget
	step.rotation = self.rotation
	step.rotMode = self.rotMode
	step.scaleTarget = self.scaleTarget
end

function _LMovieStep:Start(movie)
	-- self:print()
	local runTime = self.stop - self.start
	if self.role ~= '' then
		local node = movie:getRole(self.role)
		if not node then return end

		if self.onTerrain ~= 0 then
			node.isOnTerrain = self.onTerrain > 0
			-- print('onTerrain')
		end
		if self.pfx ~= '' and node.mesh and node.mesh.skeleton and self.bindTarget ~= '' then
			-- print('playPfx')
			local mat = node.mesh.skeleton:getBone(self.bindTarget)
			node.mesh.pfxPlayer:play(self.resourceName, self.pfx, mat)
		end
		if self.anima ~= '' and node.mesh and node.mesh.skeleton then
			local anima = node.mesh.skeleton:getAnima(self.anima)
			if anima then
				-- print('playAnima')
				self.preCamera = _Camera.new():set(_rd.camera)
				if self.speed >= 0 then
					self.preSpeed = anima.speed
					anima.speed = self.speed
				end
				anima.loop = true
				anima:play()
				movie:cameraStartByRole(node)
			end
		elseif self.bindRole == 'empty' then
			local mat = _Matrix3D.new():set(node.transform)
			node.transform = mat
			-- print('no bindRole')
		elseif self.bindRole ~= '' then
			local bindNode = movie:getRole(self.bindRole)
			-- print(bindNode , bindNode.mesh , bindNode.mesh.skeleton , node.mesh)
			if bindNode and bindNode.mesh and bindNode.mesh.skeleton and node.mesh then
				self.preMat = _Matrix3D.new():set(node.transform)
				local mat = _Matrix3D.new()
				mat.root = self.bindTarget ~= '' and bindNode.mesh.skeleton:getBone(self.bindTarget) 
				mat.root = bindNode.transform
				node.transform = mat
				-- print('bindRole')
			end
		elseif self.target then
			if runTime < 0 then return end
			node.movieMoving = true
			node.target = _Vector3.new():set(self.target:getTranslation())
			local vec1 = _Vector3.sub(self.target:getTranslation(), node.transform:getTranslation())
			local vec1Z = vec1.z
			local faceMat = _Matrix3D.new():setRotation(node.transform:getRotation())
			local vec2 = faceMat:apply(_Vector3.new(0, -1, 0))
			self.preMat = _Matrix3D.new():set(node.transform)
			vec2.z = 0
			vec1.z = 0
			node.transform:mulFaceToLeft(vec2, vec1, self.turnTime)
			vec1.z = vec1Z
			node.transform:mulTranslationRight(vec1, runTime)
			-- print(self.target)
		elseif self.turnTarget then
			if runTime < 0 then return end
			local vec1 = _Vector3.sub(self.turnTarget:getTranslation(), node.movieMoving and node.target or node.transform:getTranslation())
			local faceMat = _Matrix3D.new():setRotation(node.transform:getRotation())
			local vec2 = faceMat:apply(_Vector3.new(0, -1, 0))
			self.preMat = _Matrix3D.new():set(node.transform)
			vec2.z = 0
			vec1.z = 0
			node.transform:mulFaceToLeft(vec2, vec1, runTime)
		elseif self.turnRole then
			if runTime < 0 then return end
			-- print(self.turnRole)
			local turnRole = movie:getRole(self.turnRole)
			local vec1 = _Vector3.sub(turnRole.movieMoving and turnRole.target or turnRole.transform:getTranslation(), node.movieMoving and node.target or node.transform:getTranslation())
			local faceMat = _Matrix3D.new():setRotation(node.transform:getRotation())
			local vec2 = faceMat:apply(_Vector3.new(0, -1, 0))
			self.preMat = _Matrix3D.new():set(node.transform)
			vec2.z = 0
			vec1.z = 0
			node.transform:mulFaceToLeft(vec2, vec1, runTime)
		elseif self.rotTarget then
			if runTime < 0 then return end

			self.preMat = _Matrix3D.new():set(node.transform)
			if self.rotMode == 'local' then
				node.transform:mulRotationLeft(self.rotTarget:getTranslation(), self.rotation * math.pi / 180, runTime)
			elseif self.rotMode == 'world' then
				node.transform:mulRotationRight(self.rotTarget:getTranslation(), self.rotation * math.pi / 180, runTime)
			end
			-- print('Rotation target')
		elseif self.scaleTarget then
			if runTime < 0 then return end

			self.preMat = _Matrix3D.new():set(node.transform)
			node.transform:mulScalingLeft(self.scaleTarget:getScaling(), runTime)
		elseif self.showRole ~= 0 then
			if not node.blender then
				node.blender = _Blender.new()
			end
			node.blender:blend(self.showRole > 0 and 0x00ffffff or 0xffffffff, self.showRole > 0 and 0xffffffff or 0x00ffffff, runTime)
		end
	elseif self.pfx ~= '' then
		if self.pfx == 'empty' then
			movie.pfxPlayer:stop(self.resourceName)
		elseif self.resourceType == '3D' then
			movie.pfxPlayer:play(self.resourceName, self.pfx, self.target)
		elseif self.resourceType == '2D' then
			movie:set2DXY(self.pfxdx, self.pfxdy)
			movie.pfxPlayer2D:play2D(self.resourceName, self.pfx, self.pfxdx, self.pfxdy, self.pfxScale)
		end
		-- print('pfx')
	elseif self.sfx ~= '' then
		self.soundGroup = _SoundGroup.new()
		if self.sfxMarker then
			self.soundGroup:play(self.sfx, self.sfxStartType + self.linearRolloff, self.sfxMarker:getTranslation(), self.minDitance, self.maxDistance)
		elseif self.sfxRole then
			self.soundGroup:play(self.sfx, self.sfxStartType + self.linearRolloff, movie:getRole(self.sfxRole).transform:getTranslation(), self.minDitance, self.maxDistance)
		else
			self.soundGroup:play(self.sfx, self.sfxStartType)
		end
		-- print('sfx')
	elseif self.fadeFrom ~= 0 or self.fadeTo ~= 0 then
		_rd.screenBlender = _Blender.new()
		if self.fadeFrom == 0 then
			self.fadeFrom = 0xffffffff
		end
		if self.fadeTo == 0 then
			self.fadeTo = 0xffffffff
		end
		_rd.screenBlender:blend(self.fadeFrom, self.fadeTo, runTime > 0 and runTime or 1)
		-- print('fade')
	elseif self.camera then
		self.preCamera = _Camera.new():set(_rd.camera)
		_rd.camera.interpolationMode = self.cameraLinear
		_rd.camera:move(self.camera, runTime > 0 and runTime or 0)
	elseif self.trace ~= '' then
		self.preCamera = _Camera.new():set(_rd.camera)
		self.cameraTrace = movie.graData:getTrace(self.trace)
		if self.cameraTrace then 
			self.cameraTrace.eyeOrbit.current = 0
			self.cameraTrace.lookOrbit.current = 0
		end
		-- for i, v in ipairs(self.cameraTrace.eyeOrbit:getKeyframes()) do
		-- end
		-- for i, v in ipairs(self.cameraTrace.lookOrbit:getKeyframes()) do
		-- end
		-- print('trace')
	elseif self.speed > 0 then
		self.preSpeed = _app.speed
		_app.speed = self.speed
		-- print('speed')
	elseif self.shake > 0 then
		self.preCamera = _Camera.new():set(_rd.camera)
		_rd.camera.interpolationMode = self.cameraLinear
		_rd.camera:shake(self.shake * 0.5, self.shake, runTime > 0 and runTime or 1)
		-- print('shake')
	elseif self.event ~= '' then
		movie:onEvent(self)
		-- print('event')
	end
end

function _LMovieStep:Stop(movie)
	if self.role ~= '' then
		-- print('stop role')
		local node = movie:getRole(self.role)
		if not node then return end

		if self.pfx ~= '' and node.mesh and node.mesh.skeleton and self.bindTarget ~= '' then
			local mat = node.mesh.skeleton:getBone(self.bindTarget)
			node.mesh.pfxPlayer:stop(self.resourceName, true)
		end
		if self.anima ~= '' and node.mesh and node.mesh.skeleton then
			local anima = node.mesh.skeleton:getAnima(self.anima)
			if anima then
				if self.preSpeed and self.preSpeed > 0 then
					anima.speed = self.preSpeed
				end
				anima:stop()
				movie:cameraEndByRole()
				_rd.camera:set(self.preCamera)
			end
		end
		if self.target and self.preMat then
			node.transform = self.preMat
			node.movieMoving = false
			node.target = nil
		end
		if self.turnTarget and self.preMat then
			node.transform = self.preMat
		end
		if self.turnRole and self.preMat then
			node.transform = self.preMat
		end
		if self.bindRole ~= '' and self.preMat then
			node.transform = self.preMat
		elseif self.showRole ~= 0 then
			node.blender:blend(0xffffffff)
		end
	elseif self.pfx ~= '' then
		-- print('stop pfx')
		if self.resourceType == '3D' then
			movie.pfxPlayer:stop(self.resourceName, true)
		elseif self.resourceType == '2D' then
			movie:set2DXY(0, 0)
			movie.pfxPlayer2D:stop(self.resourceName, true)
		end
	elseif self.sfx ~= '' then
		-- print('stop sfx')
		if self.soundGroup:isPlaying() then
			self.soundGroup:stop(self.sfxStopType)
		end
	elseif self.fadeFrom ~= 0 or self.fadeTo ~= 0 then
		-- print('stop fade')
		_rd.screenBlender = _Blender.new()
	elseif self.trace ~= '' then
		self.cameraTrace = nil
		-- print('stop trace')
		_rd.camera:set(self.preCamera)
	elseif self.camera then --TODO.
		-- print('stop camera')
		_rd.camera:set(self.preCamera)
	elseif self.speed > 0 then
		-- print('stop speed')
		_app.speed = self.preSpeed
	elseif self.shake > 0 then
		-- print('stop shake')
		_rd.camera:set(self.preCamera)
	elseif self.event ~= '' then
		movie:onStopEvent(self)
	end
end

function _LMovieStep:TimeUp(movie)
	if self.role ~= '' then
		local node = movie:getRole(self.role)
		if not node then return end

		if self.pfx ~= '' and node.mesh and node.mesh.skeleton and self.bindTarget ~= '' then
			local mat = node.mesh.skeleton:getBone(self.bindTarget)
			node.mesh.pfxPlayer:stop(self.resourceName)
		end
		if self.anima ~= '' and node.mesh and node.mesh.skeleton then
			local anima = node.mesh.skeleton:getAnima(self.anima)
			if anima then
				if self.preSpeed and self.preSpeed > 0 then
					anima.speed = self.preSpeed
				end
				anima:stop()
				movie:cameraEndByRole()
			end
		end
		if self.target then
			node.movieMoving = false
			node.target = nil
		end
	elseif self.pfx ~= '' then
		if self.resourceType == '3D' then
			movie.pfxPlayer:stop(self.resourceName)
		elseif self.resourceType == '2D' then
			movie:set2DXY(0, 0)
			movie.pfxPlayer2D:stop(self.resourceName)
		end
	elseif self.sfx ~= '' then
		if self.soundGroup:isPlaying() then
			self.soundGroup:stop(self.sfxStopType)
		end
	elseif self.speed > 0 then
		_app.speed = self.preSpeed
	end
end

function _LMovieStep:update(elapse)
	if self.cameraTrace then
		self.cameraTrace.eyeOrbit:update(elapse)
		self.cameraTrace.lookOrbit:update(elapse)
		_rd.camera.eye = self.cameraTrace.eyeOrbit.pos
		_rd.camera.look = self.cameraTrace.lookOrbit.pos
		if self.cameraTrace.eyeOrbit.over then
			self.cameraTrace = nil
		end
	end
end
