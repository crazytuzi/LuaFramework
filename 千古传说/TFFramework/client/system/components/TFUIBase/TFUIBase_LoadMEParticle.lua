local TFUIBase 					= TFUIBase
local TFUIBase_setFuncs 		= TFUIBase_setFuncs
local TFUIBase_setFuncs_new 	= TFUIBase_setFuncs_new
local TFUI_VERSION_MEEDITOR 	= TFUI_VERSION_MEEDITOR
local TFUI_VERSION_NEWMEEDITOR 	= TFUI_VERSION_NEWMEEDITOR
local TFUI_VERSION_ALPHA 		= TFUI_VERSION_ALPHA
local TF_TEX_TYPE_LOCAL 		= TF_TEX_TYPE_LOCAL
local TF_TEX_TYPE_PLIST 		= TF_TEX_TYPE_PLIST
local ccc3 						= ccc3
local ccp 						= ccp
local bit_and 					= bit_and
local bit_rshift				= bit_rshift
local CCSizeMake 				= CCSizeMake
local CCRectMake 				= CCRectMake
local string 					= string

function TFUIBase:initMEParticle(pval, parent)
	if TFUIBase.version == TFUI_VERSION_COCOSTUDIO then
		self:initMEParticle_COCOSTUDIO(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_ALPHA then
		self:initMEParticle_ALPHA(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_MEEDITOR then
		self:initMEParticle_MEEDITOR(pval, parent)
	elseif TFUIBase.version == TFUI_VERSION_NEWMEEDITOR then
		self:initMEParticle_NEWMEEDITOR(pval, parent)
	end
end

function TFUIBase:initMEParticle_MEEDITOR(val, parent)
	self:initMEWidget(val, parent)
	if val['particleViewModel'] then
		local pVal = val['particleViewModel']
		if pVal.szParticlePath and pVal.szParticlePath ~= "" then
			self:setParticle(pVal.szParticlePath)
		end
		if pVal.bIsPlaying then
			self:play()
		else
			self:stop()
		end

		if pVal.EmitterMode and self.setEmitterMode then
			self:setEmitterMode(pVal.EmitterMode)
		end

		--kCCParticleModeGravity = 0
		if self:getEmitterMode() == kCCParticleModeGravity then
			if pVal.Gravity  and self.setGravity then
				self:setGravity(pVal.Gravity)
			end

			if pVal.Speed  and self.setSpeed then
				self:setSpeed(pVal.Speed)
			end

			if pVal.SpeedVar  and self.setSpeedVar then
				self:setSpeedVar(pVal.SpeedVar)
			end

			if pVal.TangentialAccel  and self.setTangentialAccel then
				self:setTangentialAccel(pVal.TangentialAccel)
			end

			if pVal.TangentialAccelVar  and self.setTangentialAccelVar then
				self:setTangentialAccelVar(pVal.TangentialAccelVar)
			end

			if pVal.RadialAccel  and self.setRadialAccel then
				self:setRadialAccel(pVal.RadialAccel)
			end

			if pVal.RadialAccelVar  and self.setRadialAccelVar then
				self:setRadialAccelVar(pVal.RadialAccelVar)
			end
		else
			if pVal.StartRadius  and self.setStartRadius then
				self:setStartRadius(pVal.StartRadius)
			end

			if pVal.StartRadiusVar  and self.setStartRadiusVar then
				self:setStartRadiusVar(pVal.StartRadiusVar)
			end

			if pVal.EndRadius  and self.setEndRadius then
				self:setEndRadius(pVal.EndRadius)
			end

			if pVal.EndRadiusVar  and self.setEndRadiusVar then
				self:setEndRadiusVar(pVal.EndRadiusVar)
			end

			if pVal.RotatePerSecond  and self.setRotatePerSecond then
				self:setRotatePerSecond(pVal.RotatePerSecond)
			end

			if pVal.RotatePerSecondVar  and self.setRotatePerSecondVar then
				self:setRotatePerSecondVar(pVal.RotatePerSecondVar)
			end
		end

		if pVal.Duration  and self.setDuration then
			self:setDuration(pVal.Duration)
		end

		if pVal.SourcePosition  and self.setSourcePosition then
			self:setSourcePosition(pVal.SourcePosition)
		end

		if pVal.PosVar  and self.setPosVar then
			self:setPosVar(pVal.PosVar)
		end

		if pVal.Life  and self.setLife then
			self:setLife(pVal.Life)
		end

		if pVal.LifeVar  and self.setLifeVar then
			self:setLifeVar(pVal.LifeVar)
		end

		if pVal.Angle  and self.setAngle then
			self:setAngle(pVal.Angle)
		end

		if pVal.AngleVar  and self.setAngleVar then
			self:setAngleVar(pVal.AngleVar)
		end

		if pVal.StartSize  and self.setStartSize then
			self:setStartSize(pVal.StartSize)
		end

		if pVal.StartSizeVar  and self.setStartSizeVar then
			self:setStartSizeVar(pVal.StartSizeVar)
		end

		if pVal.EndSize  and self.setEndSize then
			self:setEndSize(pVal.EndSize)
		end

		if pVal.EndSizeVar and self.setEndSizeVar then
			self:setEndSizeVar(pVal.EndSizeVar)
		end

		if pVal.StartColor and self.setStartColor then
			self:setStartColor(ccc4f(pVal.StartColor.r / 255, pVal.StartColor.g / 255, pVal.StartColor.b / 255, pVal.StartColor.a / 255))
		end

		if pVal.StartColorVar and self.setStartColorVar then
			self:setStartColorVar(ccc4f(pVal.StartColorVar.r / 255, pVal.StartColorVar.g / 255, pVal.StartColorVar.b / 255, pVal.StartColorVar.a / 255))
		end

		if pVal.EndColor and self.setEndColor then
			self:setEndColor(ccc4f(pVal.EndColor.r / 255, pVal.EndColor.g / 255, pVal.EndColor.b / 255, pVal.EndColor.a / 255))
		end

		if pVal.EndColorVar  and self.setEndColorVar then
			self:setEndColorVar(ccc4f(pVal.EndColorVar.r / 255, pVal.EndColorVar.g / 255, pVal.EndColorVar.b / 255, pVal.EndColorVar.a / 255))
		end

		if pVal.StartSpin  and self.setStartSpin then
			self:setStartSpin(pVal.StartSpin)
		end

		if pVal.StartSpinVar  and self.setStartSpinVar then
			self:setStartSpinVar(pVal.StartSpinVar)
		end

		if pVal.EndSpin  and self.setEndSpin then
			self:setEndSpin(pVal.EndSpin)
		end

		if pVal.EndSpinVar  and self.setEndSpinVar then
			self:setEndSpinVar(pVal.EndSpinVar)
		end

		if pVal.EmissionRate  and self.setEmissionRate then
			self:setEmissionRate(pVal.EmissionRate)
		end

		if pVal.TotalParticles  and self.setTotalParticles then
			self:setTotalParticles(pVal.TotalParticles)
		end

		if pVal.texturePath  and self.setTexture and pVal.texturePath ~= "" then
			self:setTexture(pVal.texturePath)
		end
	end

	self:initMEColorProps(val, parent)
	self:initBaseControl(val, parent)
end

function TFUIBase:initMEParticle_NEWMEEDITOR(pval, parent)
	self:initMEWidget(pval, parent)
	if next(pval['tMEParticleProperty']) then
		local pVal = pval['tMEParticleProperty']
		if pVal.szParticlePath and pVal.szParticlePath ~= "" then
			self:setParticle(pVal.szParticlePath)
		end
		if pVal.bIsPlaying then
			self:play()
		else
			self:stop()
		end

		if pVal.EmitterMode and self.setEmitterMode then
			self:setEmitterMode(pVal.EmitterMode)
		end

		--kCCParticleModeGravity = 0
		if self:getEmitterMode() == kCCParticleModeGravity then
			if pVal.Gravity  and self.setGravity then
				self:setGravity(pVal.Gravity)
			end

			if pVal.Speed  and self.setSpeed then
				self:setSpeed(pVal.Speed)
			end

			if pVal.SpeedVar  and self.setSpeedVar then
				self:setSpeedVar(pVal.SpeedVar)
			end

			if pVal.TangentialAccel  and self.setTangentialAccel then
				self:setTangentialAccel(pVal.TangentialAccel)
			end

			if pVal.TangentialAccelVar  and self.setTangentialAccelVar then
				self:setTangentialAccelVar(pVal.TangentialAccelVar)
			end

			if pVal.RadialAccel  and self.setRadialAccel then
				self:setRadialAccel(pVal.RadialAccel)
			end

			if pVal.RadialAccelVar  and self.setRadialAccelVar then
				self:setRadialAccelVar(pVal.RadialAccelVar)
			end
		else
			if pVal.StartRadius  and self.setStartRadius then
				self:setStartRadius(pVal.StartRadius)
			end

			if pVal.StartRadiusVar  and self.setStartRadiusVar then
				self:setStartRadiusVar(pVal.StartRadiusVar)
			end

			if pVal.EndRadius  and self.setEndRadius then
				self:setEndRadius(pVal.EndRadius)
			end

			if pVal.EndRadiusVar  and self.setEndRadiusVar then
				self:setEndRadiusVar(pVal.EndRadiusVar)
			end

			if pVal.RotatePerSecond  and self.setRotatePerSecond then
				self:setRotatePerSecond(pVal.RotatePerSecond)
			end

			if pVal.RotatePerSecondVar  and self.setRotatePerSecondVar then
				self:setRotatePerSecondVar(pVal.RotatePerSecondVar)
			end
		end

		if pVal.Duration  and self.setDuration then
			self:setDuration(pVal.Duration)
		end

		if pVal.SourcePosition  and self.setSourcePosition then
			self:setSourcePosition(pVal.SourcePosition)
		end

		if pVal.PosVar  and self.setPosVar then
			self:setPosVar(pVal.PosVar)
		end

		if pVal.Life  and self.setLife then
			self:setLife(pVal.Life)
		end

		if pVal.LifeVar  and self.setLifeVar then
			self:setLifeVar(pVal.LifeVar)
		end

		if pVal.Angle  and self.setAngle then
			self:setAngle(pVal.Angle)
		end

		if pVal.AngleVar  and self.setAngleVar then
			self:setAngleVar(pVal.AngleVar)
		end

		if pVal.StartSize  and self.setStartSize then
			self:setStartSize(pVal.StartSize)
		end

		if pVal.StartSizeVar  and self.setStartSizeVar then
			self:setStartSizeVar(pVal.StartSizeVar)
		end

		if pVal.EndSize  and self.setEndSize then
			self:setEndSize(pVal.EndSize)
		end

		if pVal.EndSizeVar and self.setEndSizeVar then
			self:setEndSizeVar(pVal.EndSizeVar)
		end

		if pVal.StartColor and self.setStartColor then
			self:setStartColor(ccc4f(pVal.StartColor.r / 255, pVal.StartColor.g / 255, pVal.StartColor.b / 255, pVal.StartColor.a / 255))
		end

		if pVal.StartColorVar and self.setStartColorVar then
			self:setStartColorVar(ccc4f(pVal.StartColorVar.r / 255, pVal.StartColorVar.g / 255, pVal.StartColorVar.b / 255, pVal.StartColorVar.a / 255))
		end

		if pVal.EndColor and self.setEndColor then
			self:setEndColor(ccc4f(pVal.EndColor.r / 255, pVal.EndColor.g / 255, pVal.EndColor.b / 255, pVal.EndColor.a / 255))
		end

		if pVal.EndColorVar  and self.setEndColorVar then
			self:setEndColorVar(ccc4f(pVal.EndColorVar.r / 255, pVal.EndColorVar.g / 255, pVal.EndColorVar.b / 255, pVal.EndColorVar.a / 255))
		end

		if pVal.StartSpin  and self.setStartSpin then
			self:setStartSpin(pVal.StartSpin)
		end

		if pVal.StartSpinVar  and self.setStartSpinVar then
			self:setStartSpinVar(pVal.StartSpinVar)
		end

		if pVal.EndSpin  and self.setEndSpin then
			self:setEndSpin(pVal.EndSpin)
		end

		if pVal.EndSpinVar  and self.setEndSpinVar then
			self:setEndSpinVar(pVal.EndSpinVar)
		end

		if pVal.EmissionRate  and self.setEmissionRate then
			self:setEmissionRate(pVal.EmissionRate)
		end

		if pVal.TotalParticles  and self.setTotalParticles then
			self:setTotalParticles(pVal.TotalParticles)
		end

		if pVal.texturePath  and self.setTexture and pVal.texturePath ~= "" then
			self:setTexture(pVal.texturePath)
		end
	end

	self:initMEColorProps(pval, parent)
	self:initBaseControl(pval, parent)
end

function TFUIBase:initMEParticle_COCOSTUDIO(pval, parent)	
end

function TFUIBase:initMEParticle_ALPHA(pval, parent)
end