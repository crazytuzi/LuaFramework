local function make_equiptips(_os_)
	local self = {}
	self.bNeedRequireself = false;
	self.identify = _os_:unmarshal_int32()		
	self.repairTimes = _os_:unmarshal_int32()	
	self.skillid=_os_:unmarshal_int32()		
	self.skilleffect=_os_:unmarshal_int32()	
	self.speceffectid=_os_:unmarshal_int32()
	self.maker = _os_:unmarshal_wstring(self.maker)	
	self.prefixtype = _os_:unmarshal_int32()
	local pluseffectnum = _os_:unmarshal_int32()
	self.plusEffec = {}
	for i = 1, pluseffectnum do
		if not _os_:eos() then
			local effect = {}
			effect.attrid = _os_:unmarshal_int32()
			effect.attrvalue = _os_:unmarshal_int32()
			effect.attrnum = _os_:unmarshal_int32()
			table.insert(self.plusEffec, effect)
		end
	end
	
	
	self.gemlist = {}
	self.crystalnum = 0
	if not _os_:eos() then
		local gemnum = _os_:unmarshal_int32()
		self.GemAttributeMap = {}
		for i = 1, gemnum do
			if not _os_:eos() then
				local gemid = _os_:unmarshal_int32()
				table.insert(self.gemlist, gemid)
			end
		end
		
	end
	
	if #self.gemlist ~= 0 then
		for i = 1, #self.gemlist do
			local gemconfig = knight.gsp.item.GetCGemEffectTableInstance():getRecorder(self.gemlist[i])
			if gemconfig and gemconfig.id ~= -1 then
				for j = 0, gemconfig.effecttype:size() - 1 do
					local attr = self.GemAttributeMap[gemconfig.effecttype[j] ]
					local val = gemconfig.effect[j]
					if attr then
						self.GemAttributeMap[gemconfig.effecttype[j] ] = 
						self.GemAttributeMap[gemconfig.effecttype[j] ] + val
					else
						self.GemAttributeMap[gemconfig.effecttype[j] ] = val
					end
				end
				
			end
		end
	end
	if not _os_:eos() then
		self.crystalnum = _os_:unmarshal_int32()
		self.crystalprogress = _os_:unmarshal_int32()
	end

	if not _os_:eos() then
		self.blesslv = _os_:unmarshal_int32()
	else
		self.blesslv = 0
	end

	return self 
end

return make_equiptips