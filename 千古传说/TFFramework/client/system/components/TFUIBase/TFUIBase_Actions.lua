TFANIMATION_BEGIN = 1
TFANIMATION_END = 2
TFANIMATION_FRAME = 3

local function CalcValue(nexts, previous, per)
	return (nexts - previous) * per + previous
end

local function ParserCommonAttribute(target, preFrame, nextFrame, nDT, per)
	------------------------ adapt new WPF ----------------------------------
	nextFrame.color = nextFrame.mixedColor or nextFrame.color
	preFrame.color = preFrame.mixedColor or preFrame.color

	nextFrame.alpha = nextFrame.opacity or nextFrame.alpha
	preFrame.alpha = preFrame.opacity or preFrame.alpha
	
	nextFrame.rotate = nextFrame.rotation or nextFrame.rotate
	preFrame.rotate = preFrame.rotation or preFrame.rotate
	------------------------ adapt new WPF ----------------------------------
	-- base attribute
	if nextFrame.position then
		local pos = ccp((nextFrame.position.x - preFrame.position.x) * per, (nextFrame.position.y - preFrame.position.y) * per)
		target:setPosition(ccpAdd(ccp(preFrame.position.x, preFrame.position.y), pos))
	end
	if nextFrame.percentenable and nextFrame.perposition then
		target:setPositionType(1)
		local pos = ccp((nextFrame.perposition.x - preFrame.perposition.x) * per / 100, (nextFrame.perposition.y - preFrame.perposition.y) * per / 100)
		target:setPositionPercent(ccpAdd(ccp(preFrame.perposition.x / 100, preFrame.perposition.y / 100), pos))
	end
	if nextFrame.scale then
		-- target:setScaleX((nextFrame.scale.x - preFrame.scale.x) * per + preFrame.scale.x)
		-- target:setScaleY((nextFrame.scale.y - preFrame.scale.y) * per + preFrame.scale.y)
		target:setScaleX(target._actionBaseAttribute.scaleX * ((nextFrame.scale.x - preFrame.scale.x) * per + preFrame.scale.x))
		target:setScaleY(target._actionBaseAttribute.scaleY * ((nextFrame.scale.y - preFrame.scale.y) * per + preFrame.scale.y))
	end
	if nextFrame.color and target.setColor then
		local r0, g0, b0 = preFrame.color.r, preFrame.color.g, preFrame.color.b
		local r1, g1, b1 = nextFrame.color.r, nextFrame.color.g, nextFrame.color.b 
		target:setColor(ccc3((r1-r0) * per + r0, (g1-g0)*per + g0, (b1-b0)*per + b0))
	end
	if nextFrame.alpha and target.setOpacity then
		local nOpacity = (nextFrame.alpha - preFrame.alpha) * per + preFrame.alpha
		target:setOpacity(nOpacity)
	end
	if nextFrame.rotate then
		target:setRotation((nextFrame.rotate - preFrame.rotate) * per + preFrame.rotate)
	end
	if nextFrame.MixColor and target.setMixColor then
		local r0, g0, b0, a0 = preFrame.MixColor.r, preFrame.MixColor.g, preFrame.MixColor.b, preFrame.MixColor.a
		local r1, g1, b1, a1= nextFrame.MixColor.r, nextFrame.MixColor.g, nextFrame.MixColor.b, nextFrame.MixColor.a
		target:setMixColor(ccc4((r1-r0)*per + r0, (g1-g0)*per + g0, (b1-b0)*per + b0, (a1-a0)*per + a0))
	end

	-- empty frame event
	local updateData = preFrame
	if nextFrame.enterTime == nDT then
		updateData = nextFrame
	end
	updateData.srcBlendFunc = updateData.originMixed or updateData.srcBlendFunc
	updateData.dstBlendFunc = updateData.targetMixed or updateData.dstBlendFunc
	if updateData.dstBlendFunc and updateData.srcBlendFunc and target.setBlendFunc then
		local blend = ccBlendFunc()
		blend.src = updateData.srcBlendFunc
		blend.dst = updateData.dstBlendFunc
		target:setBlendFunc(blend)
	end

	if updateData.visible ~= nil then
		target:setVisible(updateData.visible)
	end
end

local function ParserParticleAttribute(target, preFrame, nextFrame, nDT, per)
	-- change in frame
	-- this 'or' is for NewEditor
	local nextParticleData, preParticleData = nextFrame.particleData or nextFrame, preFrame.particleData or nextFrame
	local updateData = preParticleData
	if nextFrame.enterTime == nDT then
		updateData = nextParticleData
	end
	if updateData.bIsPlaying or updateData.isPlay then
		if not target._animation_play_ then
			target:play()
			target._animation_play_ = true
			-- print("play")
		end
	else
		target:stop()
		target._animation_play_ = false
		-- print("stop")
	end
	if updateData.EmitterMode and updateData.EmitterMode ~= target:getEmitterMode() then
		target:setEmitterMode(updateData.EmitterMode)
	end
	-- if nextFrame.Texture and target.setTexture then
	-- 	target:setTexture(nextFrame.szFileName)
	-- end

	-- change tween
	--kCCParticleModeGravity = 0
	if target:getEmitterMode() == kCCParticleModeGravity then
		if nextParticleData.Gravity and target.setGravity and target:getGravity() ~= nextParticleData.Gravity then
			-- print("nextParticleData.Gravity:", nextParticleData.Gravity, preParticleData.Gravity)
			local pos = ccp((nextParticleData.Gravity.x - preParticleData.Gravity.x) * per, (nextParticleData.Gravity.y - preParticleData.Gravity.y) * per)
			target:setGravity(ccpAdd(ccp(preParticleData.Gravity.x, preParticleData.Gravity.y), pos))
			-- print("end")
		end

		if nextParticleData.Speed and target.setSpeed and target:getSpeed() ~= nextParticleData.Speed then
			-- print("nextParticleData.Speed:", nextParticleData.Speed, preParticleData.Speed)
			target:setSpeed((nextParticleData.Speed - preParticleData.Speed) * per + preParticleData.Speed)
			-- print("end")
		end

		if nextParticleData.SpeedVar and target.setSpeedVar and target:getSpeedVar() ~= nextParticleData.SpeedVar then
			-- print("nextParticleData.SpeedVar:", nextParticleData.SpeedVar, preParticleData.SpeedVar)
			target:setSpeedVar((nextParticleData.SpeedVar - preParticleData.SpeedVar) * per + preParticleData.SpeedVar)
			-- print("end")
		end

		if nextParticleData.TangentialAccel and target.setTangentialAccel and target:getTangentialAccel() ~= nextParticleData.TangentialAccel then
			-- print("nextParticleData.TangentialAccel:", nextParticleData.TangentialAccel, preParticleData.TangentialAccel)
			target:setTangentialAccel((nextParticleData.TangentialAccel - preParticleData.TangentialAccel) * per + preParticleData.TangentialAccel)
			-- print("end")
		end

		if nextParticleData.TangentialAccelVar and target.setTangentialAccelVar and target:getTangentialAccelVar() ~= nextParticleData.TangentialAccelVar then
			-- print("nextParticleData.TangentialAccelVar:", nextParticleData.TangentialAccelVar, preParticleData.TangentialAccelVar)
			target:setTangentialAccelVar((nextParticleData.TangentialAccelVar - preParticleData.TangentialAccelVar) * per + preParticleData.TangentialAccelVar)
			-- print("end")
		end

		if nextParticleData.RadialAccel and target.setRadialAccel and target:getRadialAccel() ~= nextParticleData.RadialAccel then
			-- print("nextParticleData.RadialAccel:", nextParticleData.RadialAccel, preParticleData.RadialAccel)
			target:setRadialAccel((nextParticleData.RadialAccel - preParticleData.RadialAccel) * per + preParticleData.RadialAccel)
			-- print("end")
		end

		if nextParticleData.RadialAccelVar and target.setRadialAccelVar and target:getRadialAccelVar() ~= nextParticleData.RadialAccelVar then
			-- print("nextParticleData.RadialAccelVar:", nextParticleData.RadialAccelVar, preParticleData.RadialAccelVar)
			target:setRadialAccelVar((nextParticleData.RadialAccelVar - preParticleData.RadialAccelVar) * per + preParticleData.RadialAccelVar)
			-- print("end")
		end
	else
		if nextParticleData.StartRadius and target.setStartRadius and target:getStartRadius() ~= nextParticleData.StartRadius then
			-- print("nextParticleData.StartRadius:", nextParticleData.StartRadius, preParticleData.StartRadius)
			target:setStartRadius((nextParticleData.StartRadius - preParticleData.StartRadius) * per + preParticleData.StartRadius)
			-- print("end")
		end

		if nextParticleData.StartRadiusVar and target.setStartRadiusVar and target:getStartRadiusVar() ~= nextParticleData.StartRadiusVar then
			-- print("nextParticleData.StartRadiusVar:", nextParticleData.StartRadiusVar, preParticleData.StartRadiusVar)
			target:setStartRadiusVar((nextParticleData.StartRadiusVar - preParticleData.StartRadiusVar) * per + preParticleData.StartRadiusVar)
			-- print("end")
		end

		if nextParticleData.EndRadius and target.setEndRadius and target:getEndRadius() ~= nextParticleData.EndRadius then
			-- print("nextParticleData.EndRadius:", nextParticleData.EndRadius, preParticleData.EndRadius)
			target:setEndRadius((nextParticleData.EndRadius - preParticleData.EndRadius) * per + preParticleData.EndRadius)
			-- print("end")
		end

		if nextParticleData.EndRadiusVar and target.setEndRadiusVar and target:getEndRadiusVar() ~= nextParticleData.EndRadiusVar then
			-- print("nextParticleData.EndRadiusVar:", nextParticleData.EndRadiusVar, preParticleData.EndRadiusVar)
			target:setEndRadiusVar((nextParticleData.EndRadiusVar - preParticleData.EndRadiusVar) * per + preParticleData.EndRadiusVar)
			-- print("end")
		end

		if nextParticleData.RotatePerSecond and target.setRotatePerSecond and target:getRotatePerSecond() ~= nextParticleData.RotatePerSecond then
			-- print("nextParticleData.RotatePerSecond:", nextParticleData.RotatePerSecond, preParticleData.RotatePerSecond)
			target:setRotatePerSecond((nextParticleData.RotatePerSecond - preParticleData.RotatePerSecond) * per + preParticleData.RotatePerSecond)
			-- print("end")
		end

		if nextParticleData.RotatePerSecondVar and target.setRotatePerSecondVar and target:getRotatePerSecondVar() ~= nextParticleData.RotatePerSecondVar then
			-- print("nextParticleData.RotatePerSecondVar:", nextParticleData.RotatePerSecondVar, preParticleData.RotatePerSecondVar)
			target:setRotatePerSecondVar((nextParticleData.RotatePerSecondVar - preParticleData.RotatePerSecondVar) * per + preParticleData.RotatePerSecondVar)
			-- print("end")
		end
	end
	if nextParticleData.Duration and target.setDuration and target:getDuration() ~= nextParticleData.Duration then
		-- print("nextParticleData.Duration:", nextParticleData.Duration, preParticleData.Duration)
		target:setDuration((nextParticleData.Duration - preParticleData.Duration) * per + preParticleData.Duration)
		-- print("end")
	end

	if nextParticleData.SourcePosition and target.setSourcePosition and target:getSourcePosition() ~= nextParticleData.SourcePosition then
		-- print("nextParticleData.SourcePosition:", nextParticleData.SourcePosition, preParticleData.SourcePosition)
		local pos = ccp((nextParticleData.SourcePosition.x - preParticleData.SourcePosition.x) * per, (nextParticleData.SourcePosition.y - preParticleData.SourcePosition.y) * per)
		target:setSourcePosition(ccpAdd(ccp(preParticleData.SourcePosition.x, preParticleData.SourcePosition.y), pos))
		-- print("end")
	end

	if nextParticleData.PosVar and target.setPosVar and target:getPosVar() ~= nextParticleData.PosVar then
		-- print("nextParticleData.PosVar:", nextParticleData.PosVar, preParticleData.PosVar)
		local pos = ccp((nextParticleData.PosVar.x - preParticleData.PosVar.x) * per, (nextParticleData.PosVar.y - preParticleData.PosVar.y) * per)
		target:setPosVar(ccpAdd(ccp(preParticleData.PosVar.x, preParticleData.PosVar.y), pos))
		-- print("end")
	end

	if nextParticleData.Life and target.setLife and target:getLife() ~= nextParticleData.Life then
		-- print("nextParticleData.Life:", nextParticleData.Life, preParticleData.Life)
		target:setLife((nextParticleData.Life - preParticleData.Life) * per + preParticleData.Life)
		-- print("end")
	end

	if nextParticleData.LifeVar and target.setLifeVar and target:getLifeVar() ~= nextParticleData.LifeVar then
		-- print("nextParticleData.LifeVar:", nextParticleData.LifeVar, preParticleData.LifeVar)
		target:setLifeVar((nextParticleData.LifeVar - preParticleData.LifeVar) * per + preParticleData.LifeVar)
		-- print("end")
	end

	if nextParticleData.Angle and target.setAngle and target:getAngle() ~= nextParticleData.Angle then
		-- print("nextParticleData.Angle:", nextParticleData.Angle, preParticleData.Angle)
		target:setAngle((nextParticleData.Angle - preParticleData.Angle) * per + preParticleData.Angle)
		-- print("end")
	end

	if nextParticleData.AngleVar and target.setAngleVar and target:getAngleVar() ~= nextParticleData.AngleVar then
		-- print("nextParticleData.AngleVar:", nextParticleData.AngleVar, preParticleData.AngleVar)
		target:setAngleVar((nextParticleData.AngleVar - preParticleData.AngleVar) * per + preParticleData.AngleVar)
		-- print("end")
	end

	if nextParticleData.StartSize and target.setStartSize and target:getStartSize() ~= nextParticleData.StartSize then
		-- print("nextParticleData.StartSize:", nextParticleData.StartSize, preParticleData.StartSize)
		target:setStartSize((nextParticleData.StartSize - preParticleData.StartSize) * per + preParticleData.StartSize)
		-- print("end")
	end
	
	if nextParticleData.StartSizeVar and target.setStartSizeVar and target:getStartSizeVar() ~= nextParticleData.StartSizeVar then
		-- print("nextParticleData.StartSizeVar:", nextParticleData.StartSizeVar, preParticleData.StartSizeVar)
		target:setStartSizeVar((nextParticleData.StartSizeVar - preParticleData.StartSizeVar) * per + preParticleData.StartSizeVar)
		-- print("end")
	end

	if nextParticleData.EndSize and target.setEndSize and target:getEndSize() ~= nextParticleData.EndSize then
		-- print("nextParticleData.EndSize:", nextParticleData.EndSize, preParticleData.EndSize)
		target:setEndSize((nextParticleData.EndSize - preParticleData.EndSize) * per + preParticleData.EndSize)
		-- print("end")
	end

	if nextParticleData.EndSizeVar and target.setEndSizeVar and target:getEndSizeVar() ~= nextParticleData.EndSizeVar then
		-- print("nextParticleData.EndSizeVar:", nextParticleData.EndSizeVar, preParticleData.EndSizeVar)
		target:setEndSizeVar((nextParticleData.EndSizeVar - preParticleData.EndSizeVar) * per + preParticleData.EndSizeVar)
		-- print("end")
	end
	if nextParticleData.StartColor and target.setStartColor and target:getStartColor() ~= nextParticleData.StartColor then
		-- print("nextParticleData.StartColor:", nextParticleData.StartColor, preParticleData.StartColor)
		local r0, g0, b0, a0 = preParticleData.StartColor.r / 255, preParticleData.StartColor.g / 255, preParticleData.StartColor.b / 255, preParticleData.StartColor.a / 255
		local r1, g1, b1, a1 = nextParticleData.StartColor.r / 255, nextParticleData.StartColor.g / 255, nextParticleData.StartColor.b / 255, nextParticleData.StartColor.a / 255
		target:setStartColor(ccc4f((r1-r0) * per + r0, (g1-g0)*per + g0, (b1-b0)*per + b0, (a1-a0)*per + a0))
		-- print("end")
	end

	if nextParticleData.StartColorVar and target.setStartColorVar and target:getStartColorVar() ~= nextParticleData.StartColorVar then
		-- print("nextParticleData.StartColorVar:", nextParticleData.StartColorVar, preParticleData.StartColorVar)
		local r0, g0, b0, a0 = preParticleData.StartColorVar.r / 255, preParticleData.StartColorVar.g / 255, preParticleData.StartColorVar.b / 255, preParticleData.StartColorVar.a / 255
		local r1, g1, b1, a1 = nextParticleData.StartColorVar.r / 255, nextParticleData.StartColorVar.g / 255, nextParticleData.StartColorVar.b / 255, nextParticleData.StartColorVar.a / 255
		target:setStartColorVar(ccc4f((r1-r0) * per + r0, (g1-g0)*per + g0, (b1-b0)*per + b0, (a1-a0)*per + a0))
		-- print("end")
	end

	if nextParticleData.EndColor and target.setEndColor and target:getEndColor() ~= nextParticleData.EndColor then
		-- print("nextParticleData.EndColor:", nextParticleData.EndColor, preParticleData.EndColor)
		local r0, g0, b0, a0 = preParticleData.EndColor.r / 255, preParticleData.EndColor.g / 255, preParticleData.EndColor.b / 255, preParticleData.EndColor.a / 255
		local r1, g1, b1, a1 = nextParticleData.EndColor.r / 255, nextParticleData.EndColor.g / 255, nextParticleData.EndColor.b / 255, nextParticleData.EndColor.a / 255
		target:setEndColor(ccc4f((r1-r0) * per + r0, (g1-g0)*per + g0, (b1-b0)*per + b0, (a1-a0)*per + a0))
		-- print("end")
	end

	if nextParticleData.EndColorVar and target.setEndColorVar and target:getEndColorVar() ~= nextParticleData.EndColorVar then
		-- print("nextParticleData.EndColorVar:", nextParticleData.EndColorVar, preParticleData.EndColorVar)
		local r0, g0, b0, a0 = preParticleData.EndColorVar.r / 255, preParticleData.EndColorVar.g / 255, preParticleData.EndColorVar.b / 255, preParticleData.EndColorVar.a / 255
		local r1, g1, b1, a1 = nextParticleData.EndColorVar.r / 255, nextParticleData.EndColorVar.g / 255, nextParticleData.EndColorVar.b / 255, nextParticleData.EndColorVar.a / 255
		local nOpacity = (nextFrame.alpha - preFrame.alpha) * per + preFrame.alpha
		target:setEndColorVar(ccc4f((r1-r0) * per + r0, (g1-g0)*per + g0, (b1-b0)*per + b0, nOpacity))
		-- print("end")
	end

	if nextParticleData.StartSpin and target.setStartSpin and target:getStartSpin() ~= nextParticleData.StartSpin then
		-- print("nextParticleData.StartSpin:", nextParticleData.StartSpin, preParticleData.StartSpin)
		target:setStartSpin((nextParticleData.StartSpin - preParticleData.StartSpin) * per + preParticleData.StartSpin)
		-- print("end")
	end

	if nextParticleData.StartSpinVar and target.setStartSpinVar and target:getStartSpinVar() ~= nextParticleData.StartSpinVar then
		-- print("nextParticleData.StartSpinVar:", nextParticleData.StartSpinVar, preParticleData.StartSpinVar)
		target:setStartSpinVar((nextParticleData.StartSpinVar - preParticleData.StartSpinVar) * per + preParticleData.StartSpinVar)
		-- print("end")
	end

	if nextParticleData.EndSpin and target.setEndSpin and target:getEndSpin() ~= nextParticleData.EndSpin then
		-- print("nextParticleData.EndSpin:", nextParticleData.EndSpin, preParticleData.EndSpin)
		target:setEndSpin((nextParticleData.EndSpin - preParticleData.EndSpin) * per + preParticleData.EndSpin)
		-- print("end")
	end

	if nextParticleData.EndSpinVar and target.setEndSpinVar and target:getEndSpinVar() ~= nextParticleData.EndSpinVar then
		-- print("nextParticleData.EndSpinVar:", nextParticleData.EndSpinVar, preParticleData.EndSpinVar)
		target:setEndSpinVar((nextParticleData.EndSpinVar - preParticleData.EndSpinVar) * per + preParticleData.EndSpinVar)
		-- print("end")
	end
	if nextParticleData.EmissionRate and target.setEmissionRate and target:getEmissionRate() ~= nextParticleData.EmissionRate then
		-- print("nextParticleData.EmissionRate:", nextParticleData.EmissionRate, preParticleData.EmissionRate)
		target:setEmissionRate((nextParticleData.EmissionRate - preParticleData.EmissionRate) * per + preParticleData.EmissionRate)
		-- print("end")
	end

	if nextParticleData.TotalParticles and target.setTotalParticles and target:getTotalParticles() ~= nextParticleData.TotalParticles then
		-- print("nextParticleData.TotalParticles:", nextParticleData.TotalParticles, preParticleData.TotalParticles)
		target:setTotalParticles((nextParticleData.TotalParticles - preParticleData.TotalParticles) * per + preParticleData.TotalParticles)
		-- print("end")
	end
	-- print("update particle frame success")
	-- target:unscheduleUpdate()
	-- if nextFrame.enterTime == nDT then
	-- 	target:update(0)
	-- else
	-- 	-- target:setTotalParticles(target:getTotalParticles())
	-- 	for i = 0, nDT - preFrame.enterTime, 0.0167 do
	-- 		target:update(0.0167)
	-- 	end
	-- 	-- target:update(nDT - preFrame.enterTime)
	-- end
end

function TFUIBase:initAction(ui, val)

	if not val then return nil end
	if not TFDirector.EditorModel and next(val) == nil then return end
	ui.animationModel__ = {}
	local model = ui.animationModel__
	model.actions = {}

	local _bIsRunning  = false

	local szAutoPlayName = ""
	local looptimes  = 0
	for name, v in pairs(val) do 
		if type(v) == 'table' then 
			model.actions[name] = {}
			model.actions[name].duration = v["duration"]
			model.actions[name].fps = v["FPS"]
			model.actions[name].actionModel = {}
			if v["autoplay"] then
				szAutoPlayName = name
				looptimes = v["looptimes"]
			end
			local actionModel = model.actions[name].actionModel
			for _, uc in pairs(v) do 
				if type(uc) == 'table' then 
					local comp = TFDirector:getChildByPath(ui, uc.name)
					if comp and uc.frames then 
						comp.animationFrames__ = comp.animationFrames__ or {}
						comp.animationFrames__[name] = comp.animationFrames__[name] or {}
						local aframes = comp.animationFrames__[name]
						local nFPSInterval = 1.0 / model.actions[name].fps
						for _, frame in pairs(uc.frames) do 
							frame.enterTime = frame.frame * nFPSInterval
							table.insert(aframes, frame)
						end
						table.insert(actionModel, comp);
					end
				end
			end
		end
	end

	function ui:updateAnimation__(target, szAction, nDT)
		local frames = target.animationFrames__[szAction]
		if not frames then return end
		-- print(nDT)
		for num, nextFrame in pairs(frames) do
			if nextFrame.enterTime >= nDT or num == #frames then
				if nextFrame.enterTime - nDT < 0.001 then nDT = nextFrame.enterTime end 
				local preFrame = frames[num-1]
				if (num == 1 and nextFrame.enterTime ~= nDT) then break end
				if (preFrame and not preFrame.tweenToNext and nDT ~= nextFrame.enterTime) then target._animation_tween_ = false; break end
				-- for editor begin
				target._animation_tween_ = true
				-- for editor end
				local per
				if num == 1 then
					preFrame = nextFrame 
					per = 0
				else
					per = (nDT - preFrame.enterTime) / (nextFrame.enterTime - preFrame.enterTime)
				end
				if isNaN(per) then
					TFLOGINFO("------------------------------------isNaN-----------------------------------------")
					TFLOGINFO(num, #frames, per)
					TFLOGINFO(compID)
					TFLOGINFO(frames)
					break
				end
				ParserCommonAttribute(target, preFrame, nextFrame, nDT, per)
				-- for partical
				if target:getDescription() == "TFParticle" then
					ParserParticleAttribute(target, preFrame, nextFrame, nDT, per)
				end
				break
			end
		end
	end

	function ui:updateToFrame(szAction, nFrame)
		if not self.animationModel__ then return nil end
		local model = self.animationModel__
		local nDT = (nFrame / model.actions[szAction].fps)

		if not model.actions[szAction] then return end
		model.curAction = szAction
		model.curTime = 0
		model.totleRound = 1
		model.curRound = 1
		self:animationUpdate(nDT)
	end

	function ui:animationUpdate(nDT)
		local model = self.animationModel__
		model.curTime = model.curTime + nDT
		if model then 
			local actionModel = model.actions[model.curAction].actionModel
			if actionModel then 
				for _, comp in pairs(actionModel) do
					self:updateAnimation__(comp, model.curAction, model.curTime)
				end
				if model.actions[model.curAction][TFANIMATION_FRAME] then
					TFFunction.call(model.actions[model.curAction][TFANIMATION_FRAME].funcCallBack, model.actions[model.curAction][TFANIMATION_FRAME].tParams)
				end
			end
		end
		if model.curTime - model.actions[model.curAction].duration > 0.0 then
			if model.curRound < model.totleRound or model.totleRound == -1 then
				model.curRound = model.curRound + 1
				model.curTime = 0
				-- restart
				if model.actions[model.curAction][TFANIMATION_BEGIN] then
					TFFunction.call(model.actions[model.curAction][TFANIMATION_BEGIN].funcCallBack, model.actions[model.curAction][TFANIMATION_END].tParams)
				end
			else
				self:removeMEListener(TFWIDGET_ENTERFRAME)
				_bIsRunning = false
				if model.actions[model.curAction][TFANIMATION_END] then
					TFFunction.call(model.actions[model.curAction][TFANIMATION_END].funcCallBack, model.actions[model.curAction][TFANIMATION_END].tParams)
				end
			end
		end
	end

	function ui:runAnimation(name, nRound)
		local model = self.animationModel__
		if not model.actions[name] then return end
		model.curAction = name
		model.curTime = 0
		model.totleRound = nRound or 1
		model.curRound = 1
		self:addMEListener(TFWIDGET_ENTERFRAME,  self.animationUpdate)

		if model then 
			local actionModel = model.actions[model.curAction].actionModel
			if actionModel then 
				for _, comp in pairs(actionModel) do
					if comp._actionBaseAttribute == nil then
						-- comp._actionBaseAttribute = comp._actionBaseAttribute or {}
						comp._actionBaseAttribute = {}
						comp._actionBaseAttribute.scaleX = comp:getScaleX()
						comp._actionBaseAttribute.scaleY = comp:getScaleY()
					end
				end
			end
		end

		if model.actions[name][TFANIMATION_BEGIN] then
			TFFunction.call(model.actions[name][TFANIMATION_BEGIN].funcCallBack, model.actions[name][TFANIMATION_END].tParams)
		end
		_bIsRunning = true
	end

	function ui:setAnimationCallBack(actionName, event, funcCallBack, ...)
		local model = self.animationModel__
		model.actions[actionName][event] = model.actions[actionName][event] or {}
		model.actions[actionName][event].funcCallBack = funcCallBack
		model.actions[actionName][event].tParams = {...}
	end

	function ui:stopAnimation(name)
		self:removeMEListener(TFWIDGET_ENTERFRAME)
		_bIsRunning = false
	end

	function ui:pause(name)
		if _bIsRunning then
			self:removeMEListener(TFWIDGET_ENTERFRAME)
		end
	end

	function ui:resume()
		if _bIsRunning then
			self:addMEListener(TFWIDGET_ENTERFRAME,  self.animationUpdate)
		end
	end

	if szAutoPlayName ~= "" then
		ui:runAnimation(szAutoPlayName, looptimes)
	end
end