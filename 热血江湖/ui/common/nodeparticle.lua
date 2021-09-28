local NodeParticle = {}

local function copyParticleProps(props)
	local t = { }

	t.positionType = props.positionType or 0

	t.angle = props.angle or 180
    t.angleVariance = props.angleVariance or 0
	t.blendAdditive = props.blendAdditive or 1
	t.blendFuncDestination = props.blendFuncDestination or 1
	t.blendFuncSource = props.blendFuncSource or 1
	t.duration = props.duration or -1
	t.emitterType = props.emitterType or 1
	t.emissionRate = props.emissionRate or -1
	t.rotationIsDir = props.rotationIsDir or false

	t.finishColorAlpha = props.finishColorAlpha or 1
	t.finishColorBlue = props.finishColorBlue or 1
	t.finishColorGreen = props.finishColorGreen or 1
	t.finishColorRed = props.finishColorRed or 1

	if not props.preAlpha then
		t.finishColorBlue = t.finishColorBlue * t.finishColorAlpha
		t.finishColorGreen = t.finishColorGreen * t.finishColorAlpha
		t.finishColorRed = t.finishColorRed * t.finishColorAlpha
	end

	t.finishColorVarianceAlpha = props.finishColorVarianceAlpha or 0
	t.finishColorVarianceBlue = props.finishColorVarianceBlue or 0
	t.finishColorVarianceGreen = props.finishColorVarianceGreen or 0
	t.finishColorVarianceRed = props.finishColorVarianceRed or 0

	if not props.preAlpha then
		t.finishColorVarianceBlue = t.finishColorVarianceBlue * t.finishColorVarianceAlpha
		t.finishColorVarianceGreen = t.finishColorVarianceGreen * t.finishColorVarianceAlpha
		t.finishColorVarianceRed = t.finishColorVarianceRed * t.finishColorVarianceAlpha
	end

	t.rotationStart = props.rotationStart or 0
	t.rotationStartVariance = props.rotationStartVariance or 0
	t.rotationEnd = props.rotationEnd or 0
	t.rotationEndVariance = props.rotationEndVariance or 0
	t.finishParticleSize = props.finishParticleSize or -1
	t.finishParticleSizeVariance = props.finishParticleSizeVariance or 0
	t.gravityx = props.gravityx or 0
	t.gravityy = props.gravityy or 0
	t.maxParticles = props.maxParticles or 100
	t.maxRadius = props.maxRadius or 0
	t.maxRadiusVariance = props.maxRadiusVariance or 0
	t.minRadius = props.minRadius or 100
	t.minRadiusVariance = props.minRadiusVariance or 0

	t.particleLifespan = props.particleLifespan or 5
	t.particleLifespanVariance = props.particleLifespanVariance or 0

	if props.useMiddleFrame then
		t.particleLifeMiddle = props.particleLifeMiddle or 1
	else
		t.particleLifeMiddle = 1
	end

	t.cwRectangle = props.cwRectangle or false
	t.sourceCWRectangle = props.sourceCWRectangle or false
	t.sourceSpeed = props.sourceSpeed or -1
	t.widthRectangle = props.widthRectangle or 200
	t.heightRectangle = props.heightRectangle or 100
	t.rectangleStartIndex = props.rectangleStartIndex or 0

	t.radialAccelVariance = props.radialAccelVariance or 0
	t.radialAcceleration = props.radialAcceleration or 0
	t.rotatePerSecond = props.rotatePerSecond or 0
	t.rotatePerSecondVariance = props.rotatePerSecondVariance or 0
	t.sourcePositionVariancex = props.sourcePositionVariancex or 0
	t.sourcePositionVariancey = props.sourcePositionVariancey or 0
	t.sourcePositionx = props.sourcePositionx or 0
	t.sourcePositiony = props.sourcePositiony or 0
	t.speed = props.speed or 0
	t.speedVariance = props.speedVariance or 0

	t.startColorAlpha = props.startColorAlpha or 1
	t.startColorBlue = props.startColorBlue or 0
	t.startColorGreen = props.startColorGreen or 0
	t.startColorRed = props.startColorRed or 0

	if not props.preAlpha then
		t.startColorBlue = t.startColorBlue * t.startColorAlpha
		t.startColorGreen = t.startColorGreen * t.startColorAlpha
		t.startColorRed = t.startColorRed * t.startColorAlpha
	end

	t.startColorVarianceAlpha = props.startColorVarianceAlpha or 0
	t.startColorVarianceBlue = props.startColorVarianceBlue or 0
	t.startColorVarianceGreen = props.startColorVarianceGreen or 0
	t.startColorVarianceRed = props.startColorVarianceRed or 0

	if not props.preAlpha then
		t.startColorVarianceBlue = t.startColorVarianceBlue * t.startColorVarianceAlpha
		t.startColorVarianceGreen = t.startColorVarianceGreen * t.startColorVarianceAlpha
		t.startColorVarianceRed = t.startColorVarianceRed * t.startColorVarianceAlpha
	end

	t.middleColorAlpha = props.middleColorAlpha or 0
	t.middleColorBlue = props.middleColorBlue or 0
	t.middleColorGreen = props.middleColorGreen or 0
	t.middleColorRed = props.middleColorRed or 0

	if not props.preAlpha then
		t.middleColorBlue = t.middleColorBlue * t.middleColorAlpha
		t.middleColorGreen = t.middleColorGreen * t.middleColorAlpha
		t.middleColorRed = t.middleColorRed * t.middleColorAlpha
	end

	t.middleColorVarianceAlpha = props.middleColorVarianceAlpha or 0
	t.middleColorVarianceBlue = props.middleColorVarianceBlue or 0
	t.middleColorVarianceGreen = props.middleColorVarianceGreen or 0
	t.middleColorVarianceRed = props.middleColorVarianceRed or 0

	if not props.preAlpha then
		t.middleColorVarianceBlue = t.middleColorVarianceBlue * t.middleColorVarianceAlpha
		t.middleColorVarianceGreen = t.middleColorVarianceGreen * t.middleColorVarianceAlpha
		t.middleColorVarianceRed = t.middleColorVarianceRed * t.middleColorVarianceAlpha
	end

	t.startParticleSize = props.startParticleSize or 3
	t.startParticleSizeVariance = props.startParticleSizeVariance or 0

	t.middleParticleSize = props.middleParticleSize or -1
	t.middleParticleSizeVariance = props.middleParticleSizeVariance or 0

	t.tangentialAccelVariance = props.tangentialAccelVariance or 0
	t.tangentialAcceleration = props.tangentialAcceleration or 0
	t.textureFileName = props.textureFileName or "t.jpg"

	--[[
	<key>angle</key><real>180.000000</real>
    <key>angleVariance</key><real>0.000000</real>
	<key>blendAdditive</key><real>1.000000</real>
	<key>blendFuncDestination</key><integer>1</integer>
	<key>blendFuncSource</key><integer>770</integer>
	<key>duration</key><real>-1.000000</real>
	<key>emitterType</key><real>1.000000</real>
	<key>emissionRate</key><real>40.000000</real>
	<key>finishColorAlpha</key><real>0.100000</real>
	<key>finishColorBlue</key><real>0.100000</real>
	<key>finishColorGreen</key><real>0.100000</real>
	<key>finishColorRed</key><real>0.100000</real>
	<key>finishColorVarianceAlpha</key><real>0.100000</real>
	<key>finishColorVarianceBlue</key><real>0.100000</real>
	<key>finishColorVarianceGreen</key><real>0.100000</real>
	<key>finishColorVarianceRed</key><real>0.100000</real>
	<key>rotationStart</key><real>1.000000</real>
	<key>rotationStartVariance</key><real>2.000000</real>
	<key>rotationEnd</key><real>3.000000</real>
	<key>rotationEndVariance</key><real>4.000000</real>
	<key>finishParticleSize</key><real>-1.000000</real>
	<key>finishParticleSizeVariance</key><real>0.000000</real>
	<key>gravityx</key><real>0.000000</real>
	<key>gravityy</key><real>0.000000</real>
	<key>maxParticles</key><real>200.000000</real>
	<key>maxRadius</key><real>0.000000</real>
	<key>maxRadiusVariance</key><real>0.000000</real>
	<key>minRadius</key><real>160.000000</real>
	<key>minRadiusVariance</key><real>0.000000</real>
	<key>particleLifespan</key><real>5.000000</real>
	<key>particleLifespanVariance</key><real>0.000000</real>
	<key>radialAccelVariance</key><real>0.000000</real>
	<key>radialAcceleration</key><real>0.000000</real>
	<key>rotatePerSecond</key><real>180.000000</real>
	<key>rotatePerSecondVariance</key><real>0.000000</real>
	<key>sourcePositionVariancex</key><real>0.000000</real>
	<key>sourcePositionVariancey</key><real>0.000000</real>
	<key>sourcePositionx</key><real>0.000000</real>
	<key>sourcePositiony</key><real>0.000000</real>
	<key>speed</key><real>0.000000</real>
	<key>speedVariance</key><real>0.000000</real>
	<key>startColorAlpha</key><real>1.000000</real>
	<key>startColorBlue</key><real>0.500000</real>
	<key>startColorGreen</key><real>0.500000</real>
	<key>startColorRed</key><real>0.500000</real>
	<key>startColorVarianceAlpha</key><real>1.000000</real>
	<key>startColorVarianceBlue</key><real>0.500000</real>
	<key>startColorVarianceGreen</key><real>0.500000</real>
	<key>startColorVarianceRed</key><real>0.500000</real>
	<key>startParticleSize</key><real>3.000000</real>
	<key>startParticleSizeVariance</key><real>0.000000</real>
	<key>tangentialAccelVariance</key><real>0.000000</real>
	<key>tangentialAcceleration</key><real>0.000000</real>
	<key>textureFileName</key><string>t.jpg</string>
	]]
	return t
end

function NodeParticle.createNode(prop)
	local nodeCreate = ccui.Widget:create() -- TODO
	nodeCreate._effCreator = function()
		if not nodeCreate._nodeEff then
			nodeCreate._nodeEff = cc.ParticleSystemQuad:create(copyParticleProps(prop))
			nodeCreate:addChild(nodeCreate._nodeEff)
		end
	end

	nodeCreate._play = function()
		if nodeCreate._nodeEff then
			nodeCreate._nodeEff:setVisible(true)
			nodeCreate._nodeEff:resetSystem()
		elseif nodeCreate._effCreator then
			nodeCreate._effCreator()
		end
	end

	nodeCreate._stop = function()
		if nodeCreate._nodeEff then
			nodeCreate._nodeEff:stopSystem()
			nodeCreate._nodeEff:setVisible(false)
		end
	end

	nodeCreate._duration = prop.duration or -1

	if prop.playOnInit then
		nodeCreate._effCreator()
	end
	return nodeCreate
end

return NodeParticle