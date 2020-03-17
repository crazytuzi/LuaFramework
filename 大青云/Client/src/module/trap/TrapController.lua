_G.TrapController = setmetatable({}, {__index = IController})
TrapController.name = "TrapController"

function TrapController:Create()
	CControlBase:RegControl(self, true)
	CPlayerControl:AddPickListen(self)
	MsgManager:RegisterCallBack(MsgType.SC_TrapWarningInfo, self, self.OnTrapWarning)
	self.bCanUse = true
	return true
end

function TrapController:OnChangeSceneMap()
	TrapModel:DeleteAllTrap()
	return true
end

function TrapController:AddTrap(info)
	local id = info.configId
	local cid = info.charId
	local x = info.x
	local y = info.y
	local faceto = info.faceto
	local born = info.born
	local trap = Trap:NewTrap(id, cid, x, y, faceto)
	if not trap then
		return
	end
	trap:Show(born)
	TrapModel:AddTrap(trap)
end

function TrapController:DeleteTrap(cid)
	local trap = TrapModel:GetTrap(cid)
    if not trap then
        return
	end
	TrapModel:DeleteTrap(trap)
	trap:Delete()
	trap = nil
end

function TrapController:TrapWarning(id, x, y)
	local cfgTrap = t_trap[id]
	if not cfgTrap then
		Error("don't exist this Trap configId use TrapWarning" .. id)
		return
	end
	local pfx = cfgTrap.yujing
	if pfx and pfx ~= "" then
		local z = CPlayerMap:GetSceneMap():getSceneHeight(x, y)
		local mat = _Matrix3D.new()
		mat:setTranslation(x, y, z)
		CPlayerMap:GetSceneMap():PlayerPfxByMat(pfx, pfx, mat)
	end
end

---------------------------------------------------------
function TrapController:OnTrapWarning(msg)
	local list = msg.list
	for index, info in pairs(list) do
		TrapController:TrapWarning(info.id, info.x, info.y)
	end
end

