TeamEquipFBLogic = TeamEquipFBLogic or BaseClass(BaseFbLogic)

function TeamEquipFBLogic:__init()

end

function TeamEquipFBLogic:__delete()

end


-- 进入场景
function TeamEquipFBLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)

	if MainUICtrl.Instance.view then
		MainUICtrl.Instance.view:SetViewState(false)
	end

	if ViewManager.Instance:IsOpen(ViewName.FBVictoryFinishView) then
		ViewManager.Instance:Close(ViewName.FBVictoryFinishView)
	end

	ViewManager.Instance:Close(ViewName.FuBen)
	ViewManager.Instance:Close(ViewName.TipsEnterFbView)
	FuBenCtrl.Instance:OpenManyFbView()

	local times = FuBenData.Instance:GetManyFBCount() or 0
	local max_conut = FuBenData.Instance:GetManyFbTotalCount() or 0
	if times >= max_conut then
		self.no_drop = true
	else
		self.no_drop = false
	end
end

function TeamEquipFBLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Open(ViewName.FuBen, TabIndex.fb_many_people)

	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo() or {}
	local pick_info = FuBenData.Instance:GetFbPickItemInfo() or {}
	local data_list = {}
	for k, v in ipairs(pick_info) do
		table.insert(data_list, v)
	end
	if self:IsShowVictoryView() and next(fb_scene_info) and fb_scene_info.is_finish == 1 and fb_scene_info.is_pass == 1 then
		if not self.no_drop then
			local mojing = FuBenData.Instance:GetMoJingByLayer(layer) or 0
			table.insert(data_list, {item_id = ResPath.CurrencyToIconId.shengwang or 0, num = mojing, is_bind = 0})
			ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "finish", {data = data_list})
		end
	end
	FuBenData.Instance:ClearFBSceneLogicInfo()
	FuBenCtrl.Instance:CloseManyFbView()
end

function TeamEquipFBLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end

-- 是否可以移动
function TeamEquipFBLogic:CanMove()
	return true
end

-- 角色是否是敌人
function TeamEquipFBLogic:IsRoleEnemy(target_obj, main_role)
	return false
end

-- 是否是挂机打怪的敌人
function TeamEquipFBLogic:IsGuiJiMonsterEnemy(target_obj)
	if nil == target_obj or target_obj:GetType() ~= SceneObjType.Monster
		or target_obj:IsRealDead() or not Scene.Instance:IsEnemy(target_obj) then
		return false
	end
	return true
end

-- 获取挂机打怪的敌人
function TeamEquipFBLogic:GetGuiJiMonsterEnemy()
	local x, y = Scene.Instance:GetMainRole():GetLogicPos()
	local distance_limit = COMMON_CONSTS.SELECT_OBJ_DISTANCE * COMMON_CONSTS.SELECT_OBJ_DISTANCE
	return Scene.Instance:SelectObjHelper(Scene.Instance:GetRoleList(), x, y, distance_limit, SelectType.Enemy)
end

function TeamEquipFBLogic:CanGetMoveObj()
	return true
end

function TeamEquipFBLogic:IsShowVictoryView()
	return true
end