CrossFBLogic = CrossFBLogic or BaseClass(CrossServerSceneLogic)

function CrossFBLogic:__init()

end

function CrossFBLogic:__delete()

end


-- 进入场景
function CrossFBLogic:Enter(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Enter(self, old_scene_type, new_scene_type)

	if MainUICtrl.Instance.view then
		MainUICtrl.Instance.view:SetViewState(false)
	end

	ViewManager.Instance:Close(ViewName.FuBen)
	FuBenCtrl.Instance:OpenManyFbView()
end

function CrossFBLogic:Out(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Out(self, old_scene_type, new_scene_type)

	FuBenData.Instance:ClearFBSceneLogicInfo()
	ViewManager.Instance:Open(ViewName.FuBen, TabIndex.fb_many_people)
end

function CrossFBLogic:DelayOut(old_scene_type, new_scene_type)
	CrossServerSceneLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end

-- 是否可以移动
function CrossFBLogic:CanMove()
	return true
end

-- 角色是否是敌人
function CrossFBLogic:IsRoleEnemy(target_obj, main_role)
	return false
end

-- 是否是挂机打怪的敌人
function CrossFBLogic:IsGuiJiMonsterEnemy(target_obj)
	if nil == target_obj or target_obj:GetType() ~= SceneObjType.Monster
		or target_obj:IsRealDead() or not Scene.Instance:IsEnemy(target_obj) then
		return false
	end
	return true
end

-- 获取挂机打怪的敌人
function CrossFBLogic:GetGuiJiMonsterEnemy()
	local x, y = Scene.Instance:GetMainRole():GetLogicPos()
	local distance_limit = COMMON_CONSTS.SELECT_OBJ_DISTANCE * COMMON_CONSTS.SELECT_OBJ_DISTANCE
	return Scene.Instance:SelectObjHelper(Scene.Instance:GetRoleList(), x, y, distance_limit, SelectType.Enemy)
end

function CrossFBLogic:CanGetMoveObj()
	return true
end

function BaseFbLogic:IsShowVictoryView()
	return true
end