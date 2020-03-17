_G.Portal = {}
local metaPortal = {__index = Portal}

function Portal:New(id, cid, x, y)
	local cfg = t_portal[id]
	if not cfg then
		return
	end
	local portal = {}
	setmetatable(portal, metaPortal)
	portal.id = id
	portal.cid = cid
	portal.x = x
	portal.y = y
	portal.__type = "portal"
	portal.avatar = PortalAvatar:NewPortalAvatar(id, cid)
	portal.avatar:InitAvatar()
	return portal
end

function Portal:Show()
	if self.avatar then
		self.avatar:EnterMap(self.x, self.y)
	end
end

function Portal:Hide()
	if self.avatar then
		self.avatar:ExitMap()
		self.avatar = nil
	end
end

function Portal:GetCid()
	return self.cid
end

function Portal:GetPos()
	if self.avatar then
		return self.avatar:GetPos()
	else
		return {x = self.x, y = self.y, z = 0}
	end
end

function Portal:GetAvatar()
	return self.avatar
end