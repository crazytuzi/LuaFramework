--[[
vip形象
liyuan
]]
_G.VipAvatar = {}
setmetatable(VipAvatar, {__index = CAvatar})

function VipAvatar:new(modelId)
	local cfg = t_model[toint(modelId)]
	-- FPrint('-------------------------'..modelId)
	if not cfg then
		return
	end
	FPrint('-------------------------11')
	local mesh = cfg.skn
	local skl = cfg.skl
	local san = cfg.san_idle
	local obj = CAvatar:new()
	obj.avtName = "vipAvatar"
    local sm = obj:SetPart("Body", mesh)
	obj.objMesh:enumMesh('', true, function(mesh, name)
		mesh.isPaint = true
	end)
	obj:ChangeSkl(skl)
    obj:SetIdleAction(san, true)	
	
    setmetatable(obj, {__index = VipAvatar})
    return obj
end

function VipAvatar:ExitMap()
	self:ExitSceneMap();
	self:Destroy();
end