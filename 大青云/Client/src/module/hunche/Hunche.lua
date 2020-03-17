_G.Hunche = {}
local metaHunche = {__index = Hunche}

function Hunche:New(id, cid, x, y, faceto)
	local hunche = {}
	setmetatable(hunche, metaHunche)
	hunche.id = id
	hunche.cid = cid
	hunche.x = x
	hunche.y = y
	hunche.__type = "hunche"
	hunche.faceto = faceto
	hunche.avatar = HuncheAvatar:New(id, cid)
	hunche.avatar:InitAvatar()
	return hunche
end

function Hunche:Show()
	self.avatar:EnterMap(self.x, self.y, self.faceto)
	self.avatar:ExecIdleAction()
	self:SetMainHunche()
end

function Hunche:Delete()
	if self.avatar then
		self.avatar:ExitMap()
		self.avatar = nil
	end
	self = nil
end

function Hunche:StopMove(x, y, faceto)
	local currPos = self:GetPos()
	if not currPos then
		return
	end
	local vecPos = {x = x, y = y}
	self.avatar:StopMove(vecPos, faceto)
end

function Hunche:MoveTo(x, y)
	local speed = self:GetSpeed()
	local vecPos = {x = x, y = y}
	self.avatar:MoveTo(vecPos, function()
		--self.avatar:StopMove()
	end, speed)
end

function Hunche:GetCid()
	return self.cid
end

function Hunche:GetPos()
	return self.avatar:GetPos()
end

function Hunche:GetDir()
	return self.avatar:GetDirValue()
end

function Hunche:GetAvatar()
	return self.avatar
end

function Hunche:GetSpeed()
	local config = self:GetConfig()
	return config.speed
end

local name2d = _Vector2.new()
local huncheFont = _Font.new("SIMHEI", 15, 0, 1, true)
function Hunche:Update(dwInterval)
	local avatar = self.avatar
	if not avatar then return end
	if not avatar.nanAvatar then return end
	if not avatar.nvAvatar then return end
	local manName = self.manName
	local womanName = self.womanName
	if not manName or manName == "" then return end
	if not womanName or womanName == "" then return end

    local manPos = avatar:GetPos()
    _rd:projectPoint(manPos.x, manPos.y, manPos.z + 40, name2d)
	huncheFont.edgeColor = CUICardConfig.nameColor.hunche_edgecolor
	huncheFont.textColor = CUICardConfig.nameColor.hunche_textcolor
	huncheFont:drawText(name2d.x, name2d.y,
	        name2d.x, name2d.y, manName .. " " .. womanName, _Font.hCenter + _Font.vTop)
end

function Hunche:SetPos(x, y)
	local avatar = self.avatar
	if not avatar then
		return
	end
	avatar:SetPos({x = x, y = y, z = 0})
end

function Hunche:SetMainHunche()
	self.isMainHunche = false
	local config = self:GetConfig()
	for i = 1, 4 do
		if config["prof" .. i] and config["prof" .. i] ~= 0 then
			self.isMainHunche = true
		end 
	end
end

function Hunche:GetMainHunche()
	return self.isMainHunche
end

function Hunche:GetConfig()
	return t_patrol[self.id]
end

function Hunche:SetName(manName, womanName)
	self.manName = manName
	self.womanName = womanName
end