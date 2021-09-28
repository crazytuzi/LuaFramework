ExpFbLogic = ExpFbLogic or BaseClass(BaseFbLogic)

function ExpFbLogic:__init()

end

function ExpFbLogic:__delete()

end

function ExpFbLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Open(ViewName.FuBenExpInfoView)
	ViewManager.Instance:Close(ViewName.TipsEnterFbView)
	if ViewManager.Instance:IsOpen(ViewName.FBVictoryFinishView) then
		ViewManager.Instance:Close(ViewName.FBVictoryFinishView)
	end

	ViewManager.Instance:Close(ViewName.Player)
	FuBenCtrl.Instance:CloseView()
	MainUICtrl.Instance:SetAttackMode(0)
end

-- 是否可以拉取移动对象信息
function ExpFbLogic:CanGetMoveObj()
	return true
end

-- 是否自动设置挂机
function ExpFbLogic:IsSetAutoGuaji()
	return true
end

function ExpFbLogic:CanShieldMonster()
	return true
end

-- 拉取移动对象信息间隔
function ExpFbLogic:GetMoveObjAllInfoFrequency()
	return 3
end

function ExpFbLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.FuBenExpInfoView)
	if ViewManager.Instance:IsOpen(ViewName.FBFailFinishView) then
		GlobalEventSystem:Fire(OtherEventType.CLOSE_FUBEN_FAIL_VIEW)
		-- ViewManager.Instance:Close(ViewName.FBFailFinishView)
	end
	GuajiCtrl.Instance:StopGuaji()
	FuBenData.Instance:ClearFBSceneLogicInfo()
	local attr_mode = PlayerData.Instance:GetAttr("attack_mode")
  	MainUICtrl.Instance:SetAttackMode(attr_mode)
end

function ExpFbLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end

-- 角色是否是敌人
function ExpFbLogic:IsRoleEnemy(target_obj, main_role)
	return false
end

