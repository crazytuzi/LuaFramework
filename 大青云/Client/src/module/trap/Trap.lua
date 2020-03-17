_G.Trap = {}
local metaTrap = {__index = Trap}

function Trap:NewTrap(configId, cid, x, y, faceto)
	local cfgTrap = t_trap[configId]
	if not cfgTrap then
		Error("don't exist this Trap configId" .. configId)
		return
	end
	local trap = {}
	setmetatable(trap, metaTrap)
	trap.configId = configId
	trap.cid = cid
	trap.x = x
	trap.y = y
	trap.__type = "trap"
	trap.faceto = faceto
	
	return trap
end

function Trap:Show(born)
	local configId = self.configId
	local cfgTrap = t_trap[configId]
	if not cfgTrap then
		Error("don't exist this Trap configId" .. configId)
		return
	end
	local model = cfgTrap.model
	if born == 1 then
		model = cfgTrap.caster
	end
	if model and model ~= "" then
		--播放特效
		local z = CPlayerMap:GetSceneMap():getSceneHeight(self.x, self.y)
		local mat = _Matrix3D.new()
		mat:setTranslation(self.x, self.y, z) 
		CPlayerMap:GetSceneMap():PlayerPfxByMat(self.cid, model, mat)
	end 
end

function Trap:Delete()
	local configId = self.configId
	local cfgTrap = t_trap[configId]
	if not cfgTrap then
		Error("don't exist this Trap configId" .. configId)
		return
	end
	if cfgTrap.xiaoshi and cfgTrap.xiaoshi == 1 then 
		return
	end
	CPlayerMap:GetSceneMap():StopPfxByName(self.cid)
end