SkyMoneySceneLogic = SkyMoneySceneLogic or BaseClass(BaseFbLogic)

function SkyMoneySceneLogic:__init()

end

function SkyMoneySceneLogic:__delete()

end

function SkyMoneySceneLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Open(ViewName.SkyMoneyFBInfoView)
end

-- 是否可以拉取移动对象信息
function SkyMoneySceneLogic:CanGetMoveObj()
	return true
end

function SkyMoneySceneLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.SkyMoneyFBInfoView)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)

	SkyMoneyAutoTaskEvent.CancelHightLightFunc = nil
end

function SkyMoneySceneLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end
