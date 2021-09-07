FishingSceneLogic = FishingSceneLogic or BaseClass(BaseFbLogic)

function FishingSceneLogic:__init()

end

function FishingSceneLogic:__delete()

end

function FishingSceneLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)

	local mian_view = MainUICtrl.Instance:GetView()
	if mian_view.hide_show_view and mian_view.hide_show_view.HideShowFishing then
		mian_view.hide_show_view:HideShowFishing(true)
	end

	-- 是否自动钓鱼 0不自动 1自动
	FishingData.Instance:SetAutoFishing(0)
	ViewManager.Instance:Open(ViewName.FbIconView)
	ViewManager.Instance:Open(ViewName.FishingView)
end

function FishingSceneLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)

	local mian_view = MainUICtrl.Instance:GetView()
	if mian_view.hide_show_view and mian_view.hide_show_view.HideShowFishing then
		mian_view.hide_show_view:HideShowFishing(false)
	end
	ViewManager.Instance:Close(ViewName.FishingView)	
	ViewManager.Instance:Close(ViewName.FbIconView)
end

function FishingSceneLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)

	-- 是否自动钓鱼 0不自动 1自动
	FishingData.Instance:SetAutoFishing(0)
	ViewManager.Instance:Close(ViewName.FishingView)
end