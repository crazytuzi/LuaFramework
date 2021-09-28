TombExploreFBLogic = TombExploreFBLogic or BaseClass(BaseFbLogic)

function TombExploreFBLogic:__init()

end

function TombExploreFBLogic:__delete()

end

function TombExploreFBLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	-- ViewManager.Instance:Close(ViewName.TombExploreView)
	ViewManager.Instance:Open(ViewName.TombExploreFBView)

	MainUICtrl.Instance:SetViewState(false)
end

function TombExploreFBLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.TombExploreFBView)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
end

function TombExploreFBLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end