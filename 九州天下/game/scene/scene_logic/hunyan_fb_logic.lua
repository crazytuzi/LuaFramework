HunYanFbLogic = HunYanFbLogic or BaseClass(BaseFbLogic)

function HunYanFbLogic:__init()
	self.story = nil
end

function HunYanFbLogic:__delete()
	if nil ~= self.story then
		self.story:DeleteMe()
		self.story = nil
	end
end

function HunYanFbLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_PEACE)
	ViewManager.Instance:CloseAll()
	MarriageCtrl.Instance:CloseAllView()
	ViewManager.Instance:Open(ViewName.FuBenHunYanInfoView)
	MainUICtrl.Instance.view:SetViewState(false)

	self.story = XinShouStorys.New(Scene.Instance:GetSceneId())
	Scene.Instance:CreateFakeNpcList()
end

function HunYanFbLogic:Out(old_scene_type, new_scene_type)
	BaseSceneLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:CloseAll()
	ViewManager.Instance:Close(ViewName.FuBenHunYanInfoView)
	MainUICtrl.Instance.view:SetViewState(true)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	Scene.Instance:DeleteObjsByType(SceneObjType.FakeNpc)
end
