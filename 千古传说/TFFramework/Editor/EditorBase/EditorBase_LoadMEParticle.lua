local tMEParticle = {}
-- tMEParticle.__index = tMEParticle
-- setmetatable(tMEParticle, EditLua)

function EditLua:createParticle(szId, tParams)
	print("createParticle")
	if targets[szId] ~= nil then
		print("targets is not null", targets[szId])
		return
	end
	local particle = TFParticle:create("test/particle/Flower.plist")
	-- tTouchEventManager:registerEvents(particle)
	targets[szId] = particle	
	EditLua:addToParent(szId, tParams)
	targets[szId]._animation_play_ = true

	targets[szId]:addMEListener(TFPARTICLE_STOP, function ()
		setCmdGetString(string.format("ID=%s;bIsPlaying = false|", szId))
		targets[szId]._animation_play_ = false
	end)

	if tParams.szFileName then
		targets[szId]:setParticle(tParams.szFileName)
		szGlobleResult = getParticleAttributeMsg(targets[szId])
		szGlobleResult = szGlobleResult .. string.format("nWidth = %d, nHeight = %d,", targets[szId]:getSize().width, targets[szId]:getSize().height)
		szGlobleResult = szGlobleResult .. string.format("nX = %f, nY = %f,", targets[szId]:getPosition().x, targets[szId]:getPosition().y)
		setGlobleString(szGlobleResult)
		print(szGlobleResult)
	end
	print("create success")
end

function tMEParticle:setParticleFile(szId, tParams)
	print("setParticleFile")
	if tParams.szFileName then
		if tParams.szFileName == "" then
			tParams.szFileName = "test/particle/Flower.plist"
		end
		targets[szId]:setParticle(tParams.szFileName)
		
		szGlobleResult = getParticleAttributeMsg(targets[szId])
		setGlobleString(szGlobleResult)
		-- local szRes = getParticleAttributeMsg(targets[szId])
		-- setCmdGetString(szRes)
		print('setParticleFile success ')
	end
end

function tMEParticle:playParticle(szId, tParams)
	print("playParticle")
	if targets[szId] then
		targets[szId]:play()
		targets[szId]._animation_play_ = true
		print("playParticle success")
	end
end
function tMEParticle:stopParticle(szId, tParams)
	print("stopParticle")
	if targets[szId] then
		targets[szId]:stop()
		targets[szId]._animation_play_ = false
		print("stopParticle success")
	end
end

function getParticleAttributeMsg(target)
	print("getParticleAttributeMsg")
	local function getColorString(color)
		-- print("color:", bit_lshift(color.a * 255, 24)+bit_lshift(color.r * 255, 16)+bit_lshift(color.g * 255, 8)+color.b * 255)
		return bit_lshift(color.a * 255, 24)+bit_lshift(color.r * 255, 16)+bit_lshift(color.g * 255, 8)+color.b * 255
	end
	local szStr = ""
	if target:getEmitterMode() == 0 then
		szStr = string.format("EmitterMode = %d, GravityX = %.2f, GravityY = %.2f, Speed = %.2f, SpeedVar = %.2f, TangentialAccel = %.2f, TangentialAccelVar = %.2f, RadialAccel = %.2f, RadialAccelVar = %.2f, ",
			target:getEmitterMode(), target:getGravity().x, target:getGravity().y, target:getSpeed(), target:getSpeedVar(), target:getTangentialAccel(), target:getTangentialAccelVar(), target:getRadialAccel(), target:getRadialAccelVar()
			)
	else
		szStr = string.format("EmitterMode = %d, StartRadius = %.2f, StartRadiusVar = %.2f, EndRadius = %.2f, EndRadiusVar = %.2f, RotatePerSecond = %.2f, RotatePerSecondVar = %.2f, ", 
			target:getEmitterMode(), target:getStartRadius(), target:getStartRadiusVar(), target:getEndRadius(), target:getEndRadiusVar(), target:getRotatePerSecond(), target:getRotatePerSecondVar()
			)
	end
	szStr = szStr .. string.format("Duration = %.2f, SourcePositionX = %.2f, SourcePositionY = %.2f, PosVarX = %.2f, PosVarY = %.2f, Life = %.2f, LifeVar = %.2f, Angle = %.2f, AngleVar = %.2f, StartSize = %.2f, StartSizeVar = %.2f, EndSize = %.2f, EndSizeVar = %.2f, StartColor = %u, StartColorVar = %u, EndColor = %u, EndColorVar = %u, StartSpin = %.2f, StartSpinVar = %.2f, EndSpin = %.2f, EndSpinVar = %.2f, EmissionRate = %.2f, TotalParticles = %d, BlendFuncSrc = %d, BlendFuncDst = %d, ", 
		target:getDuration(), target:getSourcePosition().x, target:getSourcePosition().y, target:getPosVar().x, target:getPosVar().y, target:getLife(), target:getLifeVar(), target:getAngle(), 
		target:getAngleVar(), target:getStartSize(), target:getStartSizeVar(), target:getEndSize(), target:getEndSizeVar(), getColorString(target:getStartColor()), 
		getColorString(target:getStartColorVar()), getColorString(target:getEndColor()), getColorString(target:getEndColorVar()), target:getStartSpin(), target:getStartSpinVar(), 
		target:getEndSpin(), target:getEndSpinVar(), target:getEmissionRate(), target:getTotalParticles(), target:getBlendFunc().src, target:getBlendFunc().dst
		)

	return szStr
end

------------------------------------------------------------------------------------------------------- attribute --------------------------------------------------------------------------------------------------------
function tMEParticle:setEmitterMode(szId, tParams)
	print("setEmitterMode")
	targets[szId]:setEmitterMode(tParams.nModel)
	print("setEmitterMode success")
end
-------------------------------------------------------------------------------------------------------  Model A -------------------------------------------------------------------------------------------------------
function tMEParticle:setGravity(szId, tParams)
	print("setGravity")
	targets[szId]:setGravity(ccp(tParams.nX, tParams.nY))
	print("setGravity success")
end

function tMEParticle:setSpeed(szId, tParams)
	print("setSpeed")
	targets[szId]:setSpeed(tParams.nSpeed)
	print("setSpeed success")
end

function tMEParticle:setSpeedVar(szId, tParams)
	print("setSpeedVar")
	targets[szId]:setSpeedVar(tParams.nSpeedVar)
	print("setSpeedVar success")
end

function tMEParticle:setTangentialAccel(szId, tParams)
	print("setTangentialAccel")
	targets[szId]:setTangentialAccel(tParams.nT)
	print("setTangentialAccel success")
end

function tMEParticle:setTangentialAccelVar(szId, tParams)
	print("setTangentialAccelVar")
	targets[szId]:setTangentialAccelVar(tParams.nT)
	print("setTangentialAccelVar success")
end

function tMEParticle:setRadialAccel(szId, tParams)
	print("setRadialAccel")
	targets[szId]:setRadialAccel(tParams.nT)
	print("setRadialAccel success")
end

function tMEParticle:setRadialAccelVar(szId, tParams)
	print("setRadialAccelVar")
	targets[szId]:setRadialAccelVar(tParams.nT)
	print("setRadialAccelVar success")
end

-------------------------------------------------------------------------------------------------------  Model B -------------------------------------------------------------------------------------------------------
function tMEParticle:setStartRadius(szId, tParams)
	print("setStartRadius")
	targets[szId]:setStartRadius(tParams.startRadius)
	print("setStartRadius success")
end

function tMEParticle:setStartRadiusVar(szId, tParams)
	print("setStartRadiusVar")
	targets[szId]:setStartRadiusVar(tParams.startRadiusVar)
	print("setStartRadiusVar success")
end

function tMEParticle:setEndRadius(szId, tParams)
	print("setEndRadius")
	targets[szId]:setEndRadius(tParams.endRadius)
	print("setEndRadius success")
end

function tMEParticle:setEndRadiusVar(szId, tParams)
	print("setEndRadiusVar")
	targets[szId]:setEndRadiusVar(tParams.endRadiusVar)
	print("setEndRadiusVar success")
end

function tMEParticle:setRotatePerSecond(szId, tParams)
	print("setRotatePerSecond")
	targets[szId]:setRotatePerSecond(tParams.degrees)
	print("setRotatePerSecond success")
end

function tMEParticle:setRotatePerSecondVar(szId, tParams)
	print("setRotatePerSecondVar")
	targets[szId]:setRotatePerSecondVar(tParams.degreesVar)
	print("setRotatePerSecondVar success")
end

-------------------------------------------
function tMEParticle:setDuration(szId, tParams)
	print("Duration")
	targets[szId]:setDuration(tParams.fDuration)
	print("Duration success")
end

function tMEParticle:setSourcePosition(szId, tParams)
	print("SourcePosition")
	targets[szId]:setSourcePosition(ccp(tParams.nX, tParams.nY))
	print("SourcePosition success")
end

function tMEParticle:setPosVar(szId, tParams)
	print("PosVar")
	targets[szId]:setPosVar(ccp(tParams.nX, tParams.nY))
	print("PosVar success")
end

function tMEParticle:setLife(szId, tParams)
	print("Life")
	targets[szId]:setLife(tParams.fLife)
	print("Life success")
end

function tMEParticle:setLifeVar(szId, tParams)
	print("LifeVar")
	targets[szId]:setLifeVar(tParams.fLifeVar)
	print("LifeVar success")
end

function tMEParticle:setAngle(szId, tParams)
	print("Angle")
	targets[szId]:setAngle(tParams.fAngle)
	print("Angle success")
end

function tMEParticle:setAngleVar(szId, tParams)
	print("AngleVar")
	targets[szId]:setAngleVar(tParams.fAngleVar)
	print("AngleVar success")
end

function tMEParticle:setStartSize(szId, tParams)
	print("StartSize")
	targets[szId]:setStartSize(tParams.fStartSize)
	print("StartSize success")
end

function tMEParticle:setStartSizeVar(szId, tParams)
	print("StartSizeVar")
	targets[szId]:setStartSizeVar(tParams.fStartSizeVar)
	print("StartSizeVar success")
end

function tMEParticle:setEndSize(szId, tParams)
	print("EndSize")
	targets[szId]:setEndSize(tParams.fEndSize)
	print("EndSize success")
end

function tMEParticle:setEndSizeVar(szId, tParams)
	print("EndSizeVar")
	targets[szId]:setEndSizeVar(tParams.fEndSizeVar)
	print("EndSizeVar success")
end

function tMEParticle:setStartColor(szId, tParams)
	print("StartColor")
	targets[szId]:setStartColor(ccc4f(tParams.r / 255, tParams.g / 255, tParams.b / 255, tParams.a / 255))
	print("StartColor success")
end

function tMEParticle:setStartColorVar(szId, tParams)
	print("StartColorVar")
	targets[szId]:setStartColorVar(ccc4f(tParams.r / 255, tParams.g / 255, tParams.b / 255, tParams.a / 255))
	print("StartColorVar success")
end

function tMEParticle:setEndColor(szId, tParams)
	print("EndColor")
	targets[szId]:setEndColor(ccc4f(tParams.r / 255, tParams.g / 255, tParams.b / 255, tParams.a / 255))
	print("EndColor success")
end

function tMEParticle:setEndColorVar(szId, tParams)
	print("EndColorVar")
	targets[szId]:setEndColorVar(ccc4f(tParams.r / 255, tParams.g / 255, tParams.b / 255, tParams.a / 255))
	print("EndColorVar success")
end

function tMEParticle:setStartSpin(szId, tParams)
	print("StartSpin")
	targets[szId]:setStartSpin(tParams.fStartSpin)
	print("StartSpin success")
end

function tMEParticle:setStartSpinVar(szId, tParams)
	print("StartSpinVar")
	targets[szId]:setStartSpinVar(tParams.fStartSpinVar)
	print("StartSpinVar success")
end

function tMEParticle:setEndSpin(szId, tParams)
	print("EndSpin")
	targets[szId]:setEndSpin(tParams.fEndSpin)
	print("EndSpin success")
end

function tMEParticle:setEndSpinVar(szId, tParams)
	print("EndSpinVar")
	targets[szId]:setEndSpinVar(tParams.fEndSpinVar)
	print("EndSpinVar success")
end

function tMEParticle:setEmissionRate(szId, tParams)
	print("EmissionRate")
	targets[szId]:setEmissionRate(tParams.fEmissionRate)
	print("EmissionRate success")
end

function tMEParticle:setTotalParticles(szId, tParams)
	print("TotalParticles")
	if targets[szId]:getTotalParticles() ~= tParams.nTotalParticles then
		targets[szId]:setTotalParticles(tParams.nTotalParticles)
	end
	print("TotalParticles success")
end

function tMEParticle:setTexture(szId, tParams)
	print("Texture", targets[szId].setTexture, tParams.szFileName)
	-- local image = TFImage:create()
	-- image:setTexture(tParams.szFileName)
	-- targets[szId]:setTexture(image:getTexture())
	if tParams.szFileName ~= "" then
		targets[szId]:setTexture(tParams.szFileName)
	else
		local particle = TFParticle:create("test/particle/Flower.plist")
		targets[szId]:setTexture(particle:getTexture())
	end
	print("Texture success")
end

function tMEParticle:setBlendFunc(szId, tParams)
	print("BlendFunc")
	targets[szId]:setBlendFunc(tParams.nSrc, tParams.nDst)
	print("BlendFunc success")
end

return tMEParticle