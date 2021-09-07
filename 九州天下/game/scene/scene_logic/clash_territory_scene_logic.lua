ClashTerritoryLogic = ClashTerritoryLogic or BaseClass(CommonActivityLogic)

function ClashTerritoryLogic:__init()

end

function ClashTerritoryLogic:__delete()

end

function ClashTerritoryLogic:Enter(old_scene_type, new_scene_type)
	CommonActivityLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Open(ViewName.ClashTerritoryInfo)
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_GUILD)
end

function ClashTerritoryLogic:Out(old_scene_type, new_scene_type)
	CommonActivityLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.ClashTerritoryInfo)
end

function ClashTerritoryLogic:GetRoleNameBoardText(role_vo)
	-- local role_kill = role_vo.special_param or 0

	local t = {}
	local index = 1

	local guild_id = PlayerData.Instance.role_vo.guild_id
	t[index] = {}
	t[index].color = role_vo.guild_id == guild_id and COLOR.WHITE or COLOR.RED
	t[index].text = role_vo.name

	-- if role_kill >= 3 then
	-- 	index = index + 1
	-- 	t[index] = {}
	-- 	t[index].color = COLOR.YELLOW
	-- 	t[index].text = string.format(Language.Dungeon.Kills, role_kill)
	-- end
	return t
end

function ClashTerritoryLogic:CanGetMoveObj()
	return true
end

function ClashTerritoryLogic:GetMoveObjAllInfoFrequency()
	return 3
end


function ClashTerritoryLogic:IsRoleEnemy(target_obj, main_role)
	if target_obj:GetType() ~= SceneObjType.Role or main_role:GetVo().guild_id == target_obj:GetVo().guild_id then			-- 同一边
		return false, Language.Fight.Side
	end
	return true
end

-- 是否是挂机打怪的敌人
function ClashTerritoryLogic:IsMonsterEnemy(target_obj, main_role)
	if nil == target_obj or target_obj:GetType() ~= SceneObjType.Monster
		or target_obj:IsRealDead() then
		return false
	end
	local territory_monster_side = ClashTerritoryData.Instance:GetTerritoryMonsterSide(target_obj.vo.monster_id)
	if territory_monster_side then
		local territory_info = ClashTerritoryData.Instance:GetTerritoryWarData()
		if territory_monster_side == 2 then
			return territory_info.center_relive_side ~= territory_info.side
		else
			return territory_monster_side ~= territory_info.side and ClashTerritoryData.Instance:CheckTerritoryMonsterKillLimit(target_obj.vo.monster_id)
		end
	end
	return true
end

-- 获取挂机打怪的敌人
function ClashTerritoryLogic:GetGuiJiMonsterEnemy()
	local x, y = Scene.Instance:GetMainRole():GetLogicPos()
	local distance_limit = COMMON_CONSTS.SELECT_OBJ_DISTANCE * COMMON_CONSTS.SELECT_OBJ_DISTANCE
	return Scene.Instance:SelectObjHelper(Scene.Instance:GetRoleList(), x, y, distance_limit, SelectType.Enemy)
end


function ClashTerritoryLogic:OnMainRoleRealive()
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
end

function ClashTerritoryLogic:GetGuajiPos()
	return ClashTerritoryData.Instance:GetGuajiXY()
end
