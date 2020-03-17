--[[
法宝：外观逻辑
liyuan
]]

_G.LingQiFigureController = {}

function LingQiFigureController:UpdateSelfMagicWeapon()
	local player = MainPlayerController:GetPlayer()
	LingQiFigureController:CreateMagicWeapon(player)
end

--创建法宝 已有则换外观
function LingQiFigureController:CreateMagicWeapon(player)
	if not player then return end
	local magicWeaponID = player:GetLingQi()
	if not magicWeaponID or magicWeaponID == 0 then return end
	-- if not magicWeaponID or magicWeaponID == 0 then return end
	local weaponCfg = t_lingqi[magicWeaponID]
	if not weaponCfg then return end
	local cfg = t_lingqimodel[weaponCfg.model]
	if not cfg then return end

	if player.lingQiFigure then
		player.lingQiFigure:ExitMap();
		player.lingQiFigure = nil;
	end
	local magicFigure = LingQiFigure:new(cfg, weaponCfg.liuguang, weaponCfg.liu_speed)
	magicFigure.modelId = weaponCfg.model
	magicFigure:SetCfgScale(tonumber(cfg.zoom / 100))
	magicFigure.airHeight = cfg.air_height
	player.lingQiFigure = magicFigure
	local cid = player:GetRoleID()
	magicFigure.ownerId = cid
	if MainPlayerController:GetRoleID() == cid then
		magicFigure.dnotDelete = true
	end
	player = nil
end

-- 强制换外观
function LingQiFigureController:ResetMagicWeapon(player)
	if not player then return end
	local magicWeaponID = nil
	if player:IsSelf() then
		magicWeaponID = LingQiModel:GetLevel()
	else
		magicWeaponID = player:GetLingQi()
	end
	if not magicWeaponID or magicWeaponID == 0 then return end
	local weaponCfg = t_lingqi[magicWeaponID]
	if not weaponCfg then return end
	local cfg = t_lingqimodel[weaponCfg.model]
	if not cfg then return end
	if not player.lingQiFigure then FPrint('切换法宝失败' .. magicWeaponID) return end
	if player.lingQiFigure.modelId ~= weaponCfg.model then
		player.lingQiFigure:ChangeMagicWeapon(cfg)
		player.lingQiFigure.modelId = weaponCfg.model
		player.lingQiFigure:SetCfgScale(tonumber(cfg.zoom / 100))
		player.lingQiFigure.airHeight = cfg.air_height
	end
	player = nil
end

-- 重置坐标
function LingQiFigureController:ResetMagicWeaponPos(player, isForce)
	if not player then return end
	if not player.lingQiFigure then return end
	local magicWeaponFigure = player.lingQiFigure

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
function LingQiFigureController:UpdateMagicWeaponPos(player)
	if not player then return end
	if not player.lingQiFigure then return end
	local magicWeaponFigure = player.lingQiFigure

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
		magicWeaponFigure.curPos = magicWeaponFigure.curPos:add(magicWeaponFigure.mwDiff)
		magicWeaponFigure:MoveTo(magicWeaponFigure.curPos, function() end, speed, nil, true)
		magicWeaponFigure:ExecMoveAction()
	else
		magicWeaponFigure:StopMoveAction()
	end

	player = nil
end
