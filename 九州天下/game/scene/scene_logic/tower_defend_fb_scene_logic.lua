TowerDefendFbSceneLogic = TowerDefendFbSceneLogic or BaseClass(BaseFbLogic)

function TowerDefendFbSceneLogic:__init()

end

function TowerDefendFbSceneLogic:__delete()

end

function TowerDefendFbSceneLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(false)
	ViewManager.Instance:Open(ViewName.FuBenGuardInfoView)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	FuBenData.Instance:SetTowerIsWarning(false)
end

function TowerDefendFbSceneLogic:Update(now_time, elapse_time)
	BaseFbLogic.Update(self, now_time, elapse_time)
end

function TowerDefendFbSceneLogic:Out()
	BaseFbLogic.Out(self)
	GuajiCtrl.Instance:StopGuaji()
	ViewManager.Instance:Close(ViewName.FuBenGuardInfoView)
end

function TowerDefendFbSceneLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end