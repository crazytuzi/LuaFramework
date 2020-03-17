_G.WingAvatar = {}
setmetatable(WingAvatar, {__index = CAvatar})
local metaWingAvatar = {__index = WingAvatar}

function WingAvatar:new(skinId)
	local obj = CAvatar:new()
	obj.avtName = "wing"
	local cfg = t_wing[skinId]
	if not cfg then
		return
	end
	obj.name = cfg.special_name
	local mesh = cfg.skn_scene
	local skl = cfg.skl_scene
    obj:SetPart("Body", mesh)
    obj:ChangeSkl(skl)
    obj.skinId = skinId
    setmetatable(obj, metaWingAvatar)
    return obj
end

function WingAvatar:SetDefAction(mainAvatar)
	if not mainAvatar then
		return
	end
	local animaFile = ""
	if mainAvatar:GetMoveState() then
		animaFile = mainAvatar:GetMoveAction()
	else
		animaFile = mainAvatar:GetIdleAction()
	end
	if animaFile ~= "" then
		local nameString = self.name
        local fileName = GetWuHunAnimaTable(animaFile, nameString)
        if fileName and fileName ~= "" then
            self:ExecAction(fileName, true)
        end
	end
end

function WingAvatar:ExecDefAction()
	local skinId = self.skinId
	local cfg = t_wing[skinId]
	local san = cfg.san_scene
	self:ExecAction(san, true)
end
