--[[
宝甲：外观逻辑
liyuan
]]

_G.ArmorFigureController = {}

function ArmorFigureController:UpdateSelfMagicWeapon()
	local player = MainPlayerController:GetPlayer()
	ArmorFigureController:CreateMagicWeapon(player)
end

function ArmorFigureController:RemoveMagicWeapon(player)
	if not player then return end
	local magicWeaponID = player:GetArmor()
	if not magicWeaponID or magicWeaponID == 0 then return end
	local weaponCfg = t_newbaojia[magicWeaponID]
	if not weaponCfg then return end
	local pendantID = weaponCfg.pendant;
	player:RemovePendant(pendantID);
	player = nil
end

--创建宝甲 已有则换外观
function ArmorFigureController:CreateMagicWeapon(player)
	if not player then return end
	local magicWeaponID = player:GetArmor()
	if not magicWeaponID or magicWeaponID == 0 then return end
	local weaponCfg = t_newbaojia[magicWeaponID]
	if not weaponCfg then return end
	local pendantID = weaponCfg.pendant;
	player:AddPendant(pendantID);
	player = nil
end

-- 强制换外观
function ArmorFigureController:ResetMagicWeapon(player)
	if not player then return end
	local magicWeaponID = nil
	if player:IsSelf() then
		magicWeaponID = ArmorModel:GetLevel()
	else
		magicWeaponID = player:GetMagicWeapon()
	end
	if not magicWeaponID or magicWeaponID == 0 then return end
	local weaponCfg = t_newbaojia[magicWeaponID]
	if not weaponCfg then return end
	local pendantID = weaponCfg.pendant;
	player:AddPendant(pendantID);
	player = nil
end

-- 重置坐标
function ArmorFigureController:ResetMagicWeaponPos(player, isForce)
end

-- 更新坐标
function ArmorFigureController:UpdateMagicWeaponPos(player)
end

function ArmorFigureController:ExitMap(player)
	if not player then return end
	local magicWeaponID = player:GetArmor()
	if not magicWeaponID or magicWeaponID == 0 then return end
	local weaponCfg = t_newbaojia[magicWeaponID]
	if not weaponCfg then return end
	local pendantID = weaponCfg.pendant;
	player:RemovePendant(pendantID);
	player = nil
end