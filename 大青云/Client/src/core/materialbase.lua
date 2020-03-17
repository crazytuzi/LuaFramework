_G._LMaterial = {}

local mt = {__index = _LMaterial}
function _LMaterial.new(filename)
	local LMaterial = setmetatable({}, mt)
	if filename then
		local file = _File.new()
		file:open(filename)
		if file.name ~= '' then
			local data = _dofile(file.name)
			if data then
				data.resname = file.name
				LMaterial:load(data)
			end
		else
			LMaterial:init()
		end
	else
		LMaterial:init()
	end
	return LMaterial
end

local function getARGB(color)
	local a, r, g, b
	a = math.floor(color / 0x1000000)
	r = math.floor(color % 0x1000000 / 0x10000)
	g = math.floor(color % 0x1000000 % 0x10000 / 0x100)
	b = math.floor(color % 0x1000000 % 0x10000 % 0x100)
	return a, r, g, b
end

function _LMaterial:init()
	self.resname			= ''
	self.material 			= _Material.new()
	self.ambient			= self.material.ambient
	self.diffuse 			= self.material.diffuse
	self.emissive 			= self.material.emissive
	self.power 				= self.material.power
	self.shine 				= self.material.shine
	self.specular 			= self.material.specular
	self.mSpecularPower		= 1
	local a, r, g, b = getARGB(self.material.specular)
	self.defineSpecularR	= r
	self.defineSpecularG	= g
	self.defineSpecularB	= b
	self.diffuseTexture 	= ''
	self.normalTexture 		= ''
	self.specularTexture 	= ''
	self.emissiveTexture 	= ''
	self.alphaTexture 		= ''
	self.flowingTexture 	= ''
	self.start_x 			= 0
	self.start_y 			= 0
	self.brightStart 		= 0.6
	self.brightEnd 			= 0.6
	self.end_x 				= 1
	self.end_y 				= 0
	self.isPaint 			= true
	self.flowingDuration 	= 3000
	self.useSpecularTexture = false
	self.isAdditive			= false
	self.isAlpha			= false
	self.isBillboard		= false
	self.isColorKey			= false
	self.isCommon			= false
	self.isDecal			= false
	self.isDetail			= false
	self.isNoFog			= false
	self.isNoLight			= false
	self.isSubtractive		= false
	self.flowingLockCam			= false
	self.playMode			= _Blender.PlayLoop
end

function _LMaterial:clone()
	local newLMaterial = _LMaterial.new()
	newLMaterial.resname			= self.resname
	newLMaterial.material 			= _Material.new()
	newLMaterial.ambient			= self.material.ambient
	newLMaterial.diffuse 			= self.material.diffuse
	newLMaterial.emissive 			= self.material.emissive
	newLMaterial.power 				= self.material.power
	newLMaterial.shine 				= self.material.shine
	newLMaterial.specular 			= self.material.specular
	newLMaterial.material.ambient	= self.material.ambient
	newLMaterial.material.diffuse	= self.material.diffuse
	newLMaterial.material.emissive	= self.material.emissive
	newLMaterial.material.power		= self.material.power
	newLMaterial.material.shine		= self.material.shine
	newLMaterial.material.specular	= self.material.specular
	newLMaterial.mSpecularPower		= self.mSpecularPower
	newLMaterial.defineSpecularR	= self.defineSpecularR
	newLMaterial.defineSpecularG	= self.defineSpecularG
	newLMaterial.defineSpecularB	= self.defineSpecularB
	newLMaterial.diffuseTexture 	= self.diffuseTexture
	newLMaterial.normalTexture 		= self.normalTexture
	newLMaterial.specularTexture 	= self.specularTexture
	newLMaterial.emissiveTexture 	= self.emissiveTexture
	newLMaterial.alphaTexture 		= self.alphaTexture
	newLMaterial.flowingTexture 	= self.flowingTexture
	newLMaterial.start_x 			= self.start_x
	newLMaterial.start_y 			= self.start_y
	newLMaterial.brightStart 		= self.brightStart
	newLMaterial.brightEnd 			= self.brightEnd
	newLMaterial.end_x 				= self.end_x
	newLMaterial.end_y 				= self.end_y
	newLMaterial.isPaint 			= self.isPaint
	newLMaterial.flowingDuration 	= self.flowingDuration
	newLMaterial.useSpecularTexture = self.useSpecularTexture
	newLMaterial.isAdditive			= self.isAdditive
	newLMaterial.isAlpha			= self.isAlpha
	newLMaterial.isBillboard		= self.isBillboard
	newLMaterial.isColorKey			= self.isColorKey
	newLMaterial.isCommon			= self.isCommon
	newLMaterial.isDecal			= self.isDecal
	newLMaterial.isDetail			= self.isDetail
	newLMaterial.isNoFog			= self.isNoFog
	newLMaterial.isNoLight			= self.isNoLight
	newLMaterial.isSubtractive		= self.isSubtractive
	newLMaterial.flowingLockCam			= self.flowingLockCam
	newLMaterial.playMode			= self.playMode
	return newLMaterial
end

function _LMaterial:load(data)
	self.resname = data.resname
	self.material = _Material.new()
	self.material.ambient		= data.ambient 				or	self.material.ambient
	self.material.diffuse 		= data.diffuse 				or	self.material.diffuse
	self.material.emissive 		= data.emissive 			or	self.material.emissive
	self.material.power 		= data.power 				or	self.material.power
	self.material.shine			= data.shine 				or	self.material.shine	
	-- self.material.specular 		= data.specular 			or	self.material.specular
	self.mSpecularPower			= data.mSpecularPower		or	1
	local a, r, g, b = getARGB(self.material.specular)
	self.defineSpecularR		= data.defineSpecularR		or	r
	self.defineSpecularG		= data.defineSpecularG		or	g
	self.defineSpecularB		= data.defineSpecularB		or	b
	self.ambient				= self.material.ambient
	self.diffuse 				= self.material.diffuse
	self.emissive 				= self.material.emissive
	self.power 					= self.material.power
	self.shine 					= self.material.shine
	self.specular 				= self.material.specular

	self.diffuseTexture			= data.diffuseTexture		or	''
	self.normalTexture			= data.normalTexture		or	''
	self.specularTexture		= data.specularTexture 		or	''
	self.emissiveTexture		= data.emissiveTexture 		or	''
	self.alphaTexture			= data.alphaTexture 		or	''
	self.flowingTexture			= data.flowingTexture 		or	''
	self.useSpecularTexture		= data.useSpecularTexture	or	false
	self.start_x				= data.start_x 				or	0
	self.start_y				= data.start_y 				or	0
	self.brightStart			= data.brightStart			or	0.6
	self.brightEnd				= data.brightEnd			or	0.6
	self.end_x					= data.end_x				or	1
	self.end_y					= data.end_y				or	0
	self.isPaint				= data.isPaint
	self.flowingDuration		= data.flowingDuration		or	3000
	self.isAdditive				= data.isAdditive			or	false
	self.isAlpha				= data.isAlpha				or	false
	self.isBillboard			= data.isBillboard			or	false
	self.isColorKey				= data.isColorKey			or	false
	self.isCommon				= data.isCommon				or	false
	self.isDecal				= data.isDecal				or	false
	self.isDetail				= data.isDetail				or	false
	self.isNoFog				= data.isNoFog				or	false
	self.isNoLight				= data.isNoLight			or	false
	self.isSubtractive			= data.isSubtractive		or	false
	self.flowingLockCam				= data.flowingLockCam			or	false
	self.playMode				= data.playMode				or _Blender.PlayLoop
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

function _LMaterial:save(filename)
	local file = _File.new()
	self.resname = filename or self.resname
	file:create(self.resname)
	local t = {}
	t['ambient']				= self.material.ambient
	t['diffuse']				= self.material.diffuse
	t['emissive']				= self.material.emissive
	t['power']					= self.material.power
	t['shine']					= self.material.shine
	t['specular']				= self.material.specular
	t['mSpecularPower']			= self.mSpecularPower
	t['defineSpecularR']		= self.defineSpecularR
	t['defineSpecularG']		= self.defineSpecularG
	t['defineSpecularB']		= self.defineSpecularB

	t['diffuseTexture']			= self.diffuseTexture
	t['normalTexture']   		= self.normalTexture
	t['specularTexture'] 		= self.specularTexture
	t['emissiveTexture'] 		= self.emissiveTexture
	t['alphaTexture']    		= self.alphaTexture

	t['flowingTexture']  		= self.flowingTexture
	t['start_x']         		= self.start_x
	t['start_y']         		= self.start_y
	t['brightStart']     		= self.brightStart
	t['brightEnd']       		= self.brightEnd
	t['end_x']        			= self.end_x
	t['end_y']        			= self.end_y
	t['isPaint']         		= self.isPaint
	t['flowingDuration'] 		= self.flowingDuration
	t['useSpecularTexture']		= self.useSpecularTexture
	t['playMode']				= self.playMode
	t['lockCamera']				= self.flowingLockCam

	t['isAdditive']				= self.isAdditive
	t['isAlpha']				= self.isAlpha
	t['isBillboard']			= self.isBillboard
	t['isColorKey']				= self.isColorKey
	t['isCommon']				= self.isCommon
	t['isDecal']				= self.isDecal
	t['isDetail']				= self.isDetail
	t['isNoFog']				= self.isNoFog
	t['isNoLight']				= self.isNoLight
	t['isSubtractive']			= self.isSubtractive

	writeTable2File(t, file)
	file:close()
end