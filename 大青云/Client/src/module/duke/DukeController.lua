_G.DukeController = setmetatable({}, {__index = IController})
DukeController.name = "DukeController"

function DukeController:AddDuke(info)
	info.dwRoleID = info.charId
	info.charId = nil
    info.speed = 0
    info.dwCurrHP = 0
    info.dwMaxHP = 0
    info.dwCurrMP = 0
    info.dwMaxMP = 0
    info.teamId = "0_0"
	info.sitId = 0
    info.sitIndex = 0  
    info.rolePkState = 0
	info.ubit = 0
    info.roleCamp = 0
    info.lingzhi = 0
    info.title = t_consts[88].val2
    info.title1 = 0
    info.title2 = 0
    -- info.roleRealm = 0
    info.dwWing = 0
    local duke = CPlayerMap:OnAddRole(info)
    if duke then
    	local scaleValue = t_consts[88].val1
    	duke:SetScale(scaleValue)
    	duke:SetPickNull()
    end
end

function DukeController:DeleteDuke(cid)
	CPlayerMap:DelRole(cid)
end


