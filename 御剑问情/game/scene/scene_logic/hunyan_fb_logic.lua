HunYanFbLogic = HunYanFbLogic or BaseClass(BaseFbLogic)

function HunYanFbLogic:__init()

end

function HunYanFbLogic:__delete()

end

function HunYanFbLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	MarriageCtrl.Instance:CloseAllView()
	ViewManager.Instance:Open(ViewName.FuBenHunYanInfoView)
	MainUICtrl.Instance.view:SetViewState(false)

	-- self.story = XinShouStorys.New(Scene.Instance:GetSceneId())
	Scene.Instance:CreateFakeNpcList()
end

function HunYanFbLogic:Out(old_scene_type, new_scene_type)
	BaseSceneLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:CloseAll()
	ViewManager.Instance:Close(ViewName.FuBenHunYanInfoView)
	MainUICtrl.Instance.view:SetViewState(true)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	MarriageData.Instance:ClearHunyanInfo()
	Scene.Instance:DeleteObjsByType(SceneObjType.FakeNpc)
end

function HunYanFbLogic:IsRoleEnemy()
	return false
end