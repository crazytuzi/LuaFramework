QualityFbLogic = QualityFbLogic or BaseClass(BaseFbLogic)

function QualityFbLogic:__init()
	self.event_handle = BindTool.Bind(self.OnDoorCreate, self)
end

function QualityFbLogic:__delete()

end

function QualityFbLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	if ViewManager.Instance:IsOpen(ViewName.FuBen) then
		ViewManager.Instance:Close(ViewName.FuBen)
		FuBenCtrl.Instance:CloseView()
	end
	ViewManager.Instance:Open(ViewName.FuBenQualityInfoView)
	MainUICtrl.Instance:SetViewState(false)

	self.obj_create_event = GlobalEventSystem:Bind(ObjectEventType.OBJ_CREATE,
		self.event_handle)
end

-- 是否可以拉取移动对象信息
function QualityFbLogic:CanGetMoveObj()
	return true
end

-- 是否可以屏蔽怪物
function QualityFbLogic:CanShieldMonster()
	return false
end

-- 是否自动设置挂机
function QualityFbLogic:IsSetAutoGuaji()
	return true
end

function QualityFbLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.FuBenQualityInfoView)
	if ViewManager.Instance:IsOpen(ViewName.FBFinishStarView) then
		ViewManager.Instance:Close(ViewName.FBFinishStarView)
	end

	if ViewManager.Instance:IsOpen(ViewName.FBFailFinishView) then
		GlobalEventSystem:Fire(OtherEventType.CLOSE_FUBEN_FAIL_VIEW)
	else
	end
	GuajiCtrl.Instance:StopGuaji()

	if self.obj_create_event ~= nil then
		GlobalEventSystem:UnBind(self.obj_create_event)
		self.obj_create_event = nil
	end
end

function QualityFbLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end

function QualityFbLogic:OnDoorCreate(obj)
	if SceneObjType.Door ~= obj:GetType() then
		return
	end

	GlobalTimerQuest:CancelQuest(self.delay_set_attached)
	self.delay_set_attached = GlobalTimerQuest:AddDelayTimer(function ()
		for k, v in pairs(Scene.Instance:GetObjListByType(SceneObjType.Door)) do
			local door_x, door_y = v:GetLogicPos()
			local scene_id = Scene.Instance:GetSceneId()

			GuajiCtrl.Instance:MoveToPos(scene_id, door_x, door_y)
			break
		end
	end, 3.5)
end
