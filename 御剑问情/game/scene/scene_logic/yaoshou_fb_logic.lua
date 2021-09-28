YaoShouFbLogic = YaoShouFbLogic or BaseClass(BaseFbLogic)

function YaoShouFbLogic:__init()

end

function YaoShouFbLogic:__delete()

end

function YaoShouFbLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Open(ViewName.FuBenInfoYaoShouView)
	ViewManager.Instance:Close(ViewName.TipsEnterFbView)
	if ViewManager.Instance:IsOpen(ViewName.FBVictoryFinishView) then
		ViewManager.Instance:Close(ViewName.FBVictoryFinishView)
	end

	ViewManager.Instance:Close(ViewName.Player)
	
	FuBenCtrl.Instance:CloseView()
end

-- 是否可以拉取移动对象信息
function YaoShouFbLogic:CanGetMoveObj()
	return true
end

-- 是否自动设置挂机
function YaoShouFbLogic:IsSetAutoGuaji()
	return true
end

function YaoShouFbLogic:CanShieldMonster()
	return true
end

-- 拉取移动对象信息间隔
function YaoShouFbLogic:GetMoveObjAllInfoFrequency()
	return 3
end

function YaoShouFbLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.FuBenInfoYaoShouView)

	local role = Scene.Instance:GetObjByUId(GameVoManager.Instance:GetMainRoleVo().role_id)
	role:ChangeFollowUiName(role.vo.role_name)

	GuajiCtrl.Instance:StopGuaji()
	FuBenData.Instance:ClearFBSceneLogicInfo()
end

function YaoShouFbLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)

	local role = Scene.Instance:GetObjByUId(GameVoManager.Instance:GetMainRoleVo().role_id)
	role:ChangeFollowUiName(role.vo.role_name)
end

-- 角色是否是敌人
function YaoShouFbLogic:IsRoleEnemy(target_obj, main_role)
	return false
end

function YaoShouFbLogic:GetRoleNameBoardText(role_vo)
	local name_color = role_vo.name_color or 0
	local t = {}
	local index = 1
	self.role_vo_init = {}

	local camp = role_vo.camp or 0

	t[index] = {}
	if role_vo.role_id == GameVoManager.Instance:GetMainRoleVo().role_id then
		t[index].color = name_color == EvilColorList.NAME_COLOR_WHITE and ROLE_FOLLOW_UI_COLOR.ROLE_NAME or COLOR.RED
	else
		local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
		local color = COLOR.WHITE
		-- if guild_id == role_vo.guild_id and guild_id ~= 0 then
		-- 	color = COLOR.BLUE
		-- end
		t[index].color = name_color == EvilColorList.NAME_COLOR_WHITE and color or COLOR.RED
	end

	local role_name = role_vo.name or role_vo.role_name
	t[index].text = role_name -- PlayerData.ParseCrossServerUserName(role_name)

	-- local txg_cfg = PataData.Instance:GetCfgByLevel(role_vo.tianxiange_level)
	-- if txg_cfg then
	-- 	index = index + 1
	-- 	t[index] = {}
	-- 	t[index].color = COLOR.YELLOW
	-- 	t[index].text ="·" .. txg_cfg.title_name
	-- end
	local info = FuBenData.Instance:GetYsjtTeamFbSceneLogicInfo()
	if not info then
		return t
	end 
	for k,v in pairs(info.role_attrs) do
		if v.uid ~= 0 and v.uid == role_vo.role_id and not self.role_vo_init[role_vo.role_id] then
			self.role_vo_init[role_vo.role_id] = true
			t[1].text = ATTR_TYPE[v.attr].."·"..t[1].text
		end
	end
	return t
end

function YaoShouFbLogic:GetPickItemMaxDic(item_id)
	return 0
end