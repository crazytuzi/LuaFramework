_G.SpiritsAvatar = {}
setmetatable(SpiritsAvatar, {__index = CAvatar})

function SpiritsAvatar:new(spiritSkinId)
	local obj = CAvatar:new()
	obj.avtName = "spirits"
	local cfg = t_wuhunskin[spiritSkinId]
	if not cfg then
		return
	end
	obj.name = cfg.special_skl
	local mesh = cfg.submesh2
	local skl = cfg.subskl2
	local san = cfg.subsan2
    local meshtable = GetPoundTable(mesh)
    obj:SetPart("Body", meshtable[1])
    obj:AddSubMesh(meshtable[2])
    obj:ChangeSkl(skl)
    obj:SetIdleAction(san, true)
    setmetatable(obj, {__index = SpiritsAvatar})
    return obj
end

function SpiritsAvatar:SetDefAction(mainAvatar)
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
