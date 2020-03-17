--[[
玉佩：外观逻辑
liyuan
]]

_G.MingYuFigureController = {}

function MingYuFigureController:UpdateSelfMagicWeapon()
	local player = MainPlayerController:GetPlayer()
	MingYuFigureController:CreateMagicWeapon(player)
end

function MingYuFigureController:RemoveMagicWeapon(player)
	if not player then return end
	local magicWeaponID = player:GetMingYu()
	if not magicWeaponID or magicWeaponID == 0 then return end
	local weaponCfg = t_mingyu[magicWeaponID]
	if not weaponCfg then return end
	local pendantID = weaponCfg.pendant;
	player:RemovePendant(pendantID);
	player = nil
end

--创建玉佩 已有则换外观
function MingYuFigureController:CreateMagicWeapon(player)
	if not player then return end
	local magicWeaponID = player:GetMingYu()
	if not magicWeaponID or magicWeaponID == 0 then return end
	local weaponCfg = t_mingyu[magicWeaponID]
	if not weaponCfg then return end
	local pendantID = weaponCfg.pendant;
	player:AddPendant(pendantID);
	player = nil
end

-- 强制换外观
function MingYuFigureController:ResetMagicWeapon(player)
	if not player then return end
	local magicWeaponID = nil
	if player:IsSelf() then
		magicWeaponID = MingYuModel:GetLevel()
	else
		magicWeaponID = player:GetMagicWeapon()
	end
	if not magicWeaponID or magicWeaponID == 0 then return end
	local weaponCfg = t_mingyu[magicWeaponID]
	if not weaponCfg then return end
	local pendantID = weaponCfg.pendant;
	player:AddPendant(pendantID);
	player = nil
end

-- 重置坐标
function MingYuFigureController:ResetMagicWeaponPos(player, isForce)
end

-- 更新坐标
function MingYuFigureController:UpdateMagicWeaponPos(player)
end

function MingYuFigureController:ExitMap(player)
	if not player then return end
	local magicWeaponID = player:GetMingYu()
	if not magicWeaponID or magicWeaponID == 0 then return end
	local weaponCfg = t_mingyu[magicWeaponID]
	if not weaponCfg then return end
	local pendantID = weaponCfg.pendant;
	player:RemovePendant(pendantID);
	player = nil
end