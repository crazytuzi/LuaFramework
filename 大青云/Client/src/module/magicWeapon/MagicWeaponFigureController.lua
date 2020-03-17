--[[
神兵：外观逻辑
liyuan
]]

_G.MagicWeaponFigureController = {}

function MagicWeaponFigureController:UpdateSelfMagicWeapon()
	local player = MainPlayerController:GetPlayer()
	MagicWeaponFigureController:CreateMagicWeapon(player)
end

--创建神兵 已有则换外观
function MagicWeaponFigureController:CreateMagicWeapon(player)
	if not player then return end
	local magicWeaponID = player:GetMagicWeapon()
	if not magicWeaponID or magicWeaponID == 0 then return end
	-- if not magicWeaponID or magicWeaponID == 0 then return end
	local weaponCfg = t_shenbing[magicWeaponID]
	if not weaponCfg then return end
	local cfg = t_shenbingmodel[weaponCfg.model]
	if not cfg then return end
	
	if player.magicWeaponFigure then 
		player.magicWeaponFigure:ExitMap();
		player.magicWeaponFigure = nil;
	end
	local magicFigure = MagicWeaponFigure:new(cfg, weaponCfg.liuguang, weaponCfg.liu_speed)
	magicFigure.modelId = weaponCfg.model
	magicFigure:SetCfgScale(tonumber(cfg.zoom/100))
	magicFigure.airHeight = cfg.air_height
	player.magicWeaponFigure = magicFigure
	local cid = player:GetRoleID()
	magicFigure.ownerId = cid
	if MainPlayerController:GetRoleID() == cid then
		magicFigure.dnotDelete = true
	end
	player = nil
end

-- 强制换外观
function MagicWeaponFigureController:ResetMagicWeapon(player)
	if not player then return end
	local magicWeaponID = nil
	if player:IsSelf() then
		magicWeaponID = MagicWeaponModel:GetLevel()
	else
		magicWeaponID = player:GetMagicWeapon()
	end
	if not magicWeaponID or magicWeaponID == 0 then return end
	local weaponCfg = t_shenbing[magicWeaponID]
	if not weaponCfg then return end
	local cfg = t_shenbingmodel[weaponCfg.model]
	if not cfg then return end
	if not player.magicWeaponFigure then FPrint('切换神兵失败'..magicWeaponID) return end
	if player.magicWeaponFigure.modelId ~= weaponCfg.model then 
		player.magicWeaponFigure:ChangeMagicWeapon(cfg)
		player.magicWeaponFigure.modelId = weaponCfg.model
		player.magicWeaponFigure:SetCfgScale(tonumber(cfg.zoom/100))
		player.magicWeaponFigure.airHeight = cfg.air_height
	end
	player = nil
end

-- 重置坐标
function MagicWeaponFigureController:ResetMagicWeaponPos(player, isForce)
	if not player then return end
	if not player.magicWeaponFigure then return end
	local magicWeaponFigure = player.magicWeaponFigure
	
	local pos = player:GetPos()
	if isForce or not magicWeaponFigure.curPos then 
		magicWeaponFigure:StopMove()
	
		magicWeaponFigure.curPos = _Vector3.new() 
		
		local dir = player:GetDirValue();
		magicWeaponFigure.curPos.x = pos.x - magicWeaponFigure.followdis * math.sin(magicWeaponFigure.followangel + dir);
		magicWeaponFigure.curPos.y = pos.y + magicWeaponFigure.followdis * math.cos(magicWeaponFigure.followangel + dir);
		magicWeaponFigure.curPos.z = pos.z;
		
		magicWeaponFigure:SetDirValue(dir)
		magicWeaponFigure:SetPos(magicWeaponFigure.curPos)
	end
	player = nil
end

-- 更新坐标
function MagicWeaponFigureController:UpdateMagicWeaponPos(player)
	if not player then return end
	if not player.magicWeaponFigure then return end
	local magicWeaponFigure = player.magicWeaponFigure

	magicWeaponFigure.mwDiff =  magicWeaponFigure.mwDiff or  _Vector3.new();
	magicWeaponFigure.targetPos = magicWeaponFigure.targetPos or _Vector3.new();
	local pos = player:GetPos()
	local speed = player:GetSpeed() or 40
	magicWeaponFigure.targetPos.x = pos.x;
	magicWeaponFigure.targetPos.y = pos.y;
	magicWeaponFigure.targetPos.z = pos.z;
	
	if magicWeaponFigure.followangel ~= 0 then
		local fDirValue = player:GetDirValue();
		fDirValue = fDirValue + magicWeaponFigure.followangel;
		magicWeaponFigure.targetPos.x = pos.x - magicWeaponFigure.followdis * math.sin(fDirValue);
		magicWeaponFigure.targetPos.y = pos.y + magicWeaponFigure.followdis * math.cos(fDirValue);
	end
	
	magicWeaponFigure.mwDiff = _Vector3.sub( pos, magicWeaponFigure.curPos, magicWeaponFigure.mwDiff )
	local dis = magicWeaponFigure.mwDiff:magnitude()
	magicWeaponFigure.mwDiff = _Vector3.sub( magicWeaponFigure.targetPos, magicWeaponFigure.curPos, magicWeaponFigure.mwDiff )

	if dis > magicWeaponFigure.followdis then
		magicWeaponFigure.mwDiff = magicWeaponFigure.mwDiff:normalize():mul(dis - magicWeaponFigure.followdis + 0.01)
		magicWeaponFigure.curPos = magicWeaponFigure.curPos:add( magicWeaponFigure.mwDiff )
		magicWeaponFigure:MoveTo(magicWeaponFigure.curPos,function() end, speed, nil, true)
		magicWeaponFigure:ExecMoveAction()
	else
		magicWeaponFigure:StopMoveAction()
	end
	
	player = nil
end
