GodTempleFbLogic = GodTempleFbLogic or BaseClass(BaseFbLogic)

function GodTempleFbLogic:__init()

end

function GodTempleFbLogic:__delete()

end

function GodTempleFbLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(false)
	ViewManager.Instance:Close(ViewName.GodTempleView)
	ViewManager.Instance:Open(ViewName.GodTempleInfoView)
end

-- 是否可以拉取移动对象信息
function GodTempleFbLogic:CanGetMoveObj()
	return true
end

function GodTempleFbLogic:IsRoleEnemy()
	return false
end

-- 是否可以屏蔽怪物
function GodTempleFbLogic:CanShieldMonster()
	return false
end

-- 是否自动设置挂机
function GodTempleFbLogic:IsSetAutoGuaji()
	return true
end

function GodTempleFbLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	if ViewManager.Instance:IsOpen(ViewName.FBVictoryFinishView) then
		ViewManager.Instance:Close(ViewName.FBVictoryFinishView)
	end
	if ViewManager.Instance:IsOpen(ViewName.FBFailFinishView) then
		GlobalEventSystem:Fire(OtherEventType.CLOSE_FUBEN_FAIL_VIEW)
	end
	ViewManager.Instance:Close(ViewName.GodTempleInfoView)
	
	GuajiCtrl.Instance:StopGuaji()
end

function GodTempleFbLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end