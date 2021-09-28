BabyFBLogic = BabyFBLogic or BaseClass(CommonActivityLogic)

function BabyFBLogic:__init()

end

function BabyFBLogic:__delete()

end

-- 进入场景
function BabyFBLogic:Enter(old_scene_type, new_scene_type)
	BaseSceneLogic.Enter(self, old_scene_type, new_scene_type)

	if MainUICtrl.Instance.view then
		MainUICtrl.Instance.view:SetViewState(false)
	end

	local scene_id = Scene.Instance:GetSceneId()
	ViewManager.Instance:Close(ViewName.Boss)
	if BossData.IsBabyBossScene(scene_id) then
		ViewManager.Instance:Open(ViewName.BabyBossFightView)
	end

	FuBenCtrl.Instance:GetFuBenIconView():Open()
	FuBenCtrl.Instance:GetFuBenIconView():Flush()
end

function BabyFBLogic:Out(old_scene_type, new_scene_type)
	BaseSceneLogic.Out(self, old_scene_type, new_scene_type)

	BossCtrl.Instance:CloseBabyBossInfoView()
	BossData.Instance:ClearCache()

	MainUICtrl.Instance:SetViewState(true)
end

function BabyFBLogic:DelayOut(old_scene_type, new_scene_type)
	BaseSceneLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end

-- 是否自动设置挂机
function BabyFBLogic:IsSetAutoGuaji()
	return true
end