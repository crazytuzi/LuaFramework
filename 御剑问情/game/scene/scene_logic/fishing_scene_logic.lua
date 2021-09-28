FishingSceneLogic = FishingSceneLogic or BaseClass(CrossServerSceneLogic)

function FishingSceneLogic:__init()

end

function FishingSceneLogic:__delete()

end

function FishingSceneLogic:Enter(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Enter(self, old_scene_type, new_scene_type)

	MainUICtrl.Instance.view:SetViewState(false)
	local mian_view = MainUICtrl.Instance:GetView()
	if mian_view.hide_show_view and mian_view.hide_show_view.HideShowFishing then
		mian_view.hide_show_view:HideShowFishing(true)
	end

	-- 是否自动钓鱼 0不自动 1自动
	CrossFishingData.Instance:SetAutoFishing(0)
	ViewManager.Instance:Open(ViewName.FbIconView)
	ViewManager.Instance:Open(ViewName.FishingView)
end

function FishingSceneLogic:Out(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Out(self, old_scene_type, new_scene_type)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)

	MainUICtrl.Instance.view:SetViewState(true)
	local mian_view = MainUICtrl.Instance:GetView()
	if mian_view.hide_show_view and mian_view.hide_show_view.HideShowFishing then
		mian_view.hide_show_view:HideShowFishing(false)
	end
	ViewManager.Instance:Close(ViewName.FishingView)	
	ViewManager.Instance:Close(ViewName.FbIconView)
end

function FishingSceneLogic:DelayOut(old_scene_type, new_scene_type)
	CrossServerSceneLogic.DelayOut(self, old_scene_type, new_scene_type)

	-- 是否自动钓鱼 0不自动 1自动
	CrossFishingData.Instance:SetAutoFishing(0)
	ViewManager.Instance:Close(ViewName.FishingView)
end