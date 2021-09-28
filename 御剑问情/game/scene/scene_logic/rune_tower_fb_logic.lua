RuneTowerFbLogic = RuneTowerFbLogic or BaseClass(BaseFbLogic)

function RuneTowerFbLogic:__init()

end

function RuneTowerFbLogic:__delete()

end

function RuneTowerFbLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Open(ViewName.RuneTowerFbInfoView)
end

-- 是否可以拉取移动对象信息
function RuneTowerFbLogic:CanGetMoveObj()
	return true
end

-- 是否可以屏蔽怪物
function RuneTowerFbLogic:CanShieldMonster()
	return false
end

-- 是否自动设置挂机
function RuneTowerFbLogic:IsSetAutoGuaji()
	return true
end

function RuneTowerFbLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.RuneTowerFbInfoView)
	if ViewManager.Instance:IsOpen(ViewName.FBVictoryFinishView) then
		ViewManager.Instance:Close(ViewName.FBVictoryFinishView)
	end
	if ViewManager.Instance:IsOpen(ViewName.FBFailFinishView) then
		GlobalEventSystem:Fire(OtherEventType.CLOSE_FUBEN_FAIL_VIEW)
	end
	if ViewManager.Instance:IsOpen(ViewName.CommonTips) then
		ViewManager.Instance:Close(ViewName.CommonTips)
	end
	GuajiCtrl.Instance:StopGuaji()

	FuBenData.Instance:ClearFBSceneLogicInfo()
end

function RuneTowerFbLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	if old_scene_type ~= new_scene_type then
		MainUICtrl.Instance:SetViewState(true)
	end
end