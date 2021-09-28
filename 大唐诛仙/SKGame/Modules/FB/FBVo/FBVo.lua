FBVo = BaseClass()

function FBVo:__init(vo)
	if vo then
		for k, v in pairs(vo) do
		 	self[k] = v
		end 
	end
end

function FBVo:Update(info)
	for k, v in pairs(info) do
		self:SetValue(k, v)
	end
end

function FBVo:SetValue(k, v)
	self[k] = v
end

function FBVo:GetValue(k)
	return self[k]
end

function FBVo:__delete()
	self.mapId = 0
	self.isOpen = false
end