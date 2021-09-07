PushFbLogic = PushFbLogic or BaseClass(BaseFbLogic)

function PushFbLogic:__init()

end

function PushFbLogic:__delete()

end

function PushFbLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Open(ViewName.FuBenPushInfoView)
	MainUICtrl.Instance:SetViewState(false)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	FuBenCtrl.Instance:CloseView()
end

-- 是否可以拉取移动对象信息
function PushFbLogic:CanGetMoveObj()
	return true
end

-- 是否可以屏蔽怪物
function PushFbLogic:CanShieldMonster()
	return false
end

-- 是否自动设置挂机
function PushFbLogic:IsSetAutoGuaji()
	return true
end

function PushFbLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.FuBenPushInfoView)
	if ViewManager.Instance:IsOpen(ViewName.FuBenFinishStarNextView) then
		ViewManager.Instance:Close(ViewName.FuBenFinishStarNextView)
	end
	
	if ViewManager.Instance:IsOpen(ViewName.FBFinishStarView) then
		ViewManager.Instance:Close(ViewName.FBFinishStarView)
	end

	if ViewManager.Instance:IsOpen(ViewName.FBFailFinishView) then
		GlobalEventSystem:Fire(OtherEventType.CLOSE_FUBEN_FAIL_VIEW)
	end
	GuajiCtrl.Instance:StopGuaji()

	FuBenData.Instance:ClearFBSceneLogicInfo()
end

function PushFbLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end
