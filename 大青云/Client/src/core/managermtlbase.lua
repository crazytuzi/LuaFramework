--_dofile('materialbase.lua')

local function getARGB(color)
	local a, r, g, b
	a = math.floor(color / 0x1000000)
	r = math.floor(color % 0x1000000 / 0x10000)
	g = math.floor(color % 0x1000000 % 0x10000 / 0x100)
	b = math.floor(color % 0x1000000 % 0x10000 % 0x100)
	return a, r, g, b
end

function _Mesh:setLMaterial(filename) -- filename or _LMaterial
	local LMaterial = filename
	if type(filename) == 'string' then
		LMaterial = _LMaterial.new(filename)
	end
	self.LMaterial = LMaterial
	local tempIsMaterial = self.isMaterial
	self.isMaterial = true
	self.material = LMaterial.material
	self.material:setSpecular(LMaterial.defineSpecularR * LMaterial.mSpecularPower / 255, LMaterial.defineSpecularG * LMaterial.mSpecularPower / 255, LMaterial.defineSpecularB * LMaterial.mSpecularPower / 255, 1)
	self.diffuseTexture = self:getTexture(0) and _sys:getFileName(self:getTexture(0).resname) or ''
	self:setTexture(_Image.new(LMaterial.diffuseTexture))
	self:setBumpMap(LMaterial.normalTexture ~= '' and _Image.new(LMaterial.normalTexture) or nil)
	self:setSpecularMap(LMaterial.specularTexture ~= '' and _Image.new(LMaterial.specularTexture) or nil)
	self:setEmissiveMap(LMaterial.emissiveTexture ~= '' and _Image.new(LMaterial.emissiveTexture) or nil)
	self:setEnvironmentMap(_Image.new(LMaterial.flowingTexture), false, 1)
	self.isPaint = LMaterial.isPaint
	self.blender = _Blender.new()
	self.blender.playMode = LMaterial.playMode
	self.blender:environment(LMaterial.start_x, LMaterial.start_y, LMaterial.brightStart, LMaterial.end_x, LMaterial.end_y, LMaterial.brightEnd, LMaterial.useSpecularTexture, LMaterial.flowingLockCam, LMaterial.flowingDuration)
	self.isAdditive = LMaterial.isAdditive
	self.isAlpha = LMaterial.isAlpha
	self.isBillboard = LMaterial.isBillboard
	self.isColorKey = LMaterial.isColorKey
	self.isCommon = LMaterial.isCommon
	self.isDecal = LMaterial.isDecal
	self.isDetail = LMaterial.isDetail
	self.isNoFog = LMaterial.isNoFog
	self.isNoLight = LMaterial.isNoLight
	self.isSubtractive = LMaterial.isSubtractive
	self.isMaterial = tempIsMaterial
end

_G.fmts = {};
_G.mtls = {};
function _Mesh:loadLMaterialManager(filename)
	
	local mtmanager = fmts[filename];
	if not mtmanager then
		-- local file = _File.new()
		-- file:open(filename)
		-- if file.name == '' then return end
		mtmanager = _dofile(filename)
		fmts[filename] = mtmanager;
	end
	
	if not next(mtmanager) then return end
	self.mInfoResname = filename
	if #self:getSubMeshs() == 0 then
	
		local LMaterial = mtls[mtmanager['rootmesh']]
		if not LMaterial then
			LMaterial = _LMaterial.new(mtmanager['rootmesh'])
			if self.sketch then
				LMaterial.diffuseTexture		= 'point.png';
				LMaterial.normalTexture			= nil;
				LMaterial.specularTexture		= nil;
				LMaterial.emissiveTexture		= nil;
				LMaterial.alphaTexture			= nil;
				LMaterial.flowingTexture		= nil;
			else
				if self.closeEnvironment then
					LMaterial.flowingTexture		= nil;
				end
				mtls[mtmanager['rootmesh']] = LMaterial;
			end
		end
	
		if LMaterial and LMaterial.resname ~= '' then
			self:setLMaterial(LMaterial)
		end
	else
		for i, v in ipairs(self:getSubMeshs()) do
			if mtmanager[v.name] then
				
				local LMaterial = mtls[mtmanager[v.name]]
				if not LMaterial then
					LMaterial = _LMaterial.new(mtmanager[v.name])
					if self.sketch then
						LMaterial.diffuseTexture		= 'point.png';
						LMaterial.normalTexture			= nil;
						LMaterial.specularTexture		= nil;
						LMaterial.emissiveTexture		= nil;
						LMaterial.alphaTexture			= nil;
						LMaterial.flowingTexture		= nil;
					else
						if self.closeEnvironment then
							LMaterial.flowingTexture		= nil;
						end
						mtls[mtmanager[v.name]] = LMaterial;
					end
				end
			
				if LMaterial and LMaterial.resname ~= '' then
					v:setLMaterial(LMaterial)
				end
				
			end
		end
	end
end

function _Mesh:createLMaterial()
	local function createLMaterial(mesh)
		if mesh.LMaterial and mesh.LMaterial.resname ~= '' then return end
		local m = _LMaterial.new()
		local tempIsMaterial = mesh.isMaterial
		mesh.isMaterial = true
		m.material 				=	mesh.material
		m.ambient				= 	mesh.material.ambient
		m.diffuse 				= 	mesh.material.diffuse
		m.emissive 				= 	mesh.material.emissive
		m.power 				= 	mesh.material.power
		m.shine 				= 	mesh.material.shine
		m.specular 				= 	mesh.material.specular
		m.mSpecularPower		= 	1
		local a, r, g, b = getARGB(mesh.material.specular)
		m.defineSpecularR		=	r
		m.defineSpecularG		=	g
		m.defineSpecularB		=	b
		mesh.blender 			=   _Blender.new()
		mesh.blender.playMode	=	_Blender.PlayLoop
		m.blender 				=   mesh.blender
		m.diffuseTexture  		=	mesh:getTexture(0) and _sys:getFileName(mesh:getTexture(0).resname) or ''
		m.normalTexture  		=	mesh.normalTexture		and _sys:getFileName(mesh.normalTexture.resname)	or ''
		m.specularTexture  		=	mesh.specularTexture	and _sys:getFileName(mesh.specularTexture.resname)	or ''
		m.emissiveTexture  		=	mesh.emissiveTexture	and _sys:getFileName(mesh.emissiveTexture.resname)	or ''
		local alphaTexture = _sys:getFileName(m.diffuseTexture, false) .. '-alpha.' .. _sys:getExtention(m.diffuseTexture)
		m.alphaTexture  		=	_sys:fileExist(alphaTexture) and alphaTexture or ''
		m.flowingTexture   		=	mesh.flowingTexture		and _sys:getFileName(mesh.flowingTexture.resname)	or ''
		m.start_x  				=	mesh.start_x			or 0
		m.start_y 				=	mesh.start_y			or 0
		m.brightStart			=	mesh.brightStart		or 0.6
		m.brightEnd				=	mesh.brightEnd			or 0.6
		m.end_x					=	mesh.end_x		 		or 1
		m.end_y					=	mesh.end_y		 		or 0
		m.isPaint				=	mesh.isPaint
		m.flowingDuration		=	mesh.flowingDuration	or 3000
		m.useSpecularTexture	= 	mesh.useSpecularTexture or false
		m.isAdditive			=	mesh.isAdditive			or false
		m.isAlpha				=	mesh.isAlpha			or false
		m.isBillboard			=	mesh.isBillboard		or false
		m.isColorKey			=	mesh.isColorKey			or false
		m.isCommon				=	mesh.isCommon           or false
		m.isDecal				=	mesh.isDecal            or false
		m.isDetail				=	mesh.isDetail           or false
		m.isNoFog				=	mesh.isNoFog            or false
		m.isNoLight				=	mesh.isNoLight          or false
		m.isSubtractive			=	mesh.isSubtractive      or false
		m.flowingLockCam			=	mesh.flowingLockCam      	or false
		mesh.isMaterial = tempIsMaterial
		mesh.LMaterial = m
	end
	if #self:getSubMeshs() == 0 then
		createLMaterial(self)
	else
		for i, v in ipairs(self:getSubMeshs()) do
			createLMaterial(v)
		end
	end
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
			index = '["' .. key .. '"]' .. ' = '
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

function _Mesh:saveMInfo(filename)
	local file = _File.new()
	self.mInfoResname = filename or self.mInfoResname
	file:create(self.mInfoResname)
	local t = {}
	if #self:getSubMeshs() == 0 then
		if self.LMaterial.resname and self.LMaterial.resname ~= '' then
			t['rootmesh'] = _sys:getFileName(self.LMaterial.resname)
		end
	else
		for i, v in ipairs(self:getSubMeshs()) do
			if v.LMaterial.resname  and v.LMaterial.resname ~= '' then
				t[v.name] = _sys:getFileName(v.LMaterial.resname)
			end
		end
	end
	writeTable2File(t, file)
	file:close()
end