XingZuoYiJiSceneLogic = XingZuoYiJiSceneLogic or BaseClass(BaseSceneLogic)

function XingZuoYiJiSceneLogic:__init()
	self.play_ani_diif_time = 15
end

function XingZuoYiJiSceneLogic:__delete()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

end

function XingZuoYiJiSceneLogic:Enter(old_scene_type, new_scene_type)
	BaseSceneLogic.Enter(self, old_scene_type, new_scene_type)
	local scene_id = Scene.Instance:GetSceneId()
	-- 是否星座遗迹场景
	self:CheckEnterRelicScene(scene_id)

	-- 场景里面龙展示待机动画
	self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.PlayMonsterRestAnimation, self), self.play_ani_diif_time)
end

function XingZuoYiJiSceneLogic:CanGetMoveObj()
	return true
end

function XingZuoYiJiSceneLogic:PlayMonsterRestAnimation()
	local monster_list = Scene.Instance:GetMonsterList()

	if nil == next(monster_list) then return end
	for k, v in pairs(monster_list) do
		if not v:IsRealDead() and v.obj_type == SceneObjType.Monster and not v:IsFightState() then
			local main_part = v.draw_obj:GetPart(SceneObjPart.Main)
			if nil ~= main_part then
				main_part:SetTrigger("rest")
			end
		end
	end
end

-- 拉取移动对象信息间隔
function XingZuoYiJiSceneLogic:GetMoveObjAllInfoFrequency()
	return 5
end

function XingZuoYiJiSceneLogic:CheckEnterRelicScene(scene_id)
	if RelicData.Instance:IsRelicScene(scene_id) then
		RelicCtrl.Instance:OpenInfoView()
		self.has_open_info_view = true
		MainUICtrl.Instance:SetViewState(false)
	end
end

function XingZuoYiJiSceneLogic:Out(old_scene_type, new_scene_type)
	BaseSceneLogic.Out(self, old_scene_type, new_scene_type)
	RelicCtrl.Instance:CloseInfoView()
	ViewManager.Instance:Close(ViewName.FbIconView)

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function XingZuoYiJiSceneLogic:DelayOut(old_scene_type, new_scene_type)
	BaseSceneLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end